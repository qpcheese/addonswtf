--[[
    DreamHouse - Favorites Category
    Fügt eine "Favoriten"-Kategorie zur linken Kategorie-Leiste hinzu
    
    v1.3.0: Vollständige Filter- und Such-Integration für Editor UND Dashboard
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.FavoritesCategory = {}

local favoritesButton = nil          -- Hauptkategorie-Button
local favoritesSubcategoryButton = nil -- Unterkategorie-Button innerhalb anderer Kategorien
local isApplied = false

-- Favoriten-Modus Tracking
local isInFavoritesMode = false
local currentFavoriteEntries = {}     -- Alle Favoriten (ungefiltert)
local currentFilteredFavorites = {}   -- Gefilterte Favoriten
local currentSearchText = ""          -- Aktueller Suchtext
local currentPanelType = nil          -- "editor" oder "dashboard"

-- Flags um rekursive Aufrufe zu verhindern
local isUpdatingFavorites = false

-- Pfade zu unseren Custom-Texturen
local TEXTURE_PATH = "Interface\\AddOns\\DreamHouse\\Textures\\"
local TEXTURE_INACTIVE = TEXTURE_PATH .. "category-favorites_inactive"
local TEXTURE_ACTIVE = TEXTURE_PATH .. "category-favorites_active"
local TEXTURE_PRESSED = TEXTURE_PATH .. "category-favorites_pressed"

-- Favoriten-Button erstellen (mit eigenen Texturen im Blizzard-Style)
local function CreateFavoritesButton(parent)
    local btn = CreateFrame("Button", "DreamHouseFavoritesCategoryButton", parent)
    -- Größe vom Parent übernehmen (wie Blizzard es macht)
    local size = parent.categoryButtonSize or 64
    btn:SetSize(size, size)
    
    -- Icon (unsere Custom-Textur) - etwas kleiner um den Rand anzupassen
    btn.Icon = btn:CreateTexture(nil, "ARTWORK")
    btn.Icon:SetSize(size - 6, size - 6)  -- 3px Rand auf jeder Seite
    btn.Icon:SetPoint("CENTER", 0, 0)
    btn.Icon:SetTexture(TEXTURE_INACTIVE)
    
    -- Hover-Glow (gleiche Textur mit ADD-Blending)
    btn.HoverIcon = btn:CreateTexture(nil, "OVERLAY")
    btn.HoverIcon:SetSize(size - 6, size - 6)
    btn.HoverIcon:SetPoint("CENTER", 0, 0)
    btn.HoverIcon:SetTexture(TEXTURE_INACTIVE)
    btn.HoverIcon:SetAlpha(0.4)
    btn.HoverIcon:SetBlendMode("ADD")
    btn.HoverIcon:Hide()
    
    -- Selection Background (Glow wenn aktiv)
    btn.SelectedBackground = btn:CreateTexture(nil, "BACKGROUND", nil, -1)
    btn.SelectedBackground:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.SelectedBackground:SetSize(75, size + 20)  -- Feste Breite statt Parent-Referenz
    btn.SelectedBackground:SetAtlas("house-chest-active-nav_selected-bg-glow")
    btn.SelectedBackground:Hide()
    
    -- State
    btn.isActive = false
    btn.isDreamHouseFavorites = true  -- Flag für unsere Erkennung
    btn.enabledTooltip = L["Favorites"]
    
    -- Hover-Effekte (wie Blizzard)
    btn:SetScript("OnEnter", function(self)
        self.HoverIcon:Show()
        -- Pressed-Textur beim Hover (heller)
        if not self.isActive then
            self.Icon:SetTexture(TEXTURE_PRESSED)
            self.HoverIcon:SetTexture(TEXTURE_PRESSED)
        end
        
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -12)
        
        local favCount = 0
        local favorites = DreamHouse.Settings:GetAllFavorites()
        for _ in pairs(favorites) do
            favCount = favCount + 1
        end
        
        GameTooltip:SetText("|cffffcc00" .. L["Favorites"] .. "|r")
        GameTooltip:AddLine(L.Format("X items marked", favCount), 1, 1, 1)
        GameTooltip:Show()
        
        PlaySound(SOUNDKIT.HOUSING_CATALOG_CATEGORY_HOVER)
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.HoverIcon:Hide()
        -- Zurück zur normalen Textur
        if self.isActive then
            self.Icon:SetTexture(TEXTURE_ACTIVE)
        else
            self.Icon:SetTexture(TEXTURE_INACTIVE)
        end
        GameTooltip:Hide()
    end)
    
    -- Mouse-Down Effekt
    btn:SetScript("OnMouseDown", function(self)
        self.Icon:SetTexture(TEXTURE_PRESSED)
    end)
    
    btn:SetScript("OnMouseUp", function(self)
        if self.isActive then
            self.Icon:SetTexture(TEXTURE_ACTIVE)
        else
            self.Icon:SetTexture(TEXTURE_INACTIVE)
        end
    end)
    
    -- Klick-Handler
    btn:SetScript("OnClick", function(self)
        DreamHouse.FavoritesCategory:OnClick()
    end)
    
    return btn
end


-- Filter auf Favoriten anwenden
function DreamHouse.FavoritesCategory:ApplyFiltersToFavorites()
    if not isInFavoritesMode then return end
    if isUpdatingFavorites then return end -- Rekursion verhindern
    
    isUpdatingFavorites = true
    
    local catalogPanel, panelType = self:GetCatalogPanel()
    if not catalogPanel then 
        isUpdatingFavorites = false
        return 
    end
    
    -- Aktuelle Filter aus dem CatalogSearcher holen
    local catalogSearcher = catalogPanel.catalogSearcher
    local activeFilters = {
        indoorOnly = false,  -- true = NUR Indoor zeigen (Outdoor ausfiltern)
        outdoorOnly = false, -- true = NUR Outdoor zeigen (Indoor ausfiltern)
        customizableOnly = false,
        collectedOnly = false,
        uncollectedOnly = false,
    }
    
    if catalogSearcher then
        -- Indoor/Outdoor Filter abfragen
        local indoorActive, outdoorActive = true, true
        
        if catalogSearcher.IsAllowedIndoorsActive then
            local success, result = pcall(function() return catalogSearcher:IsAllowedIndoorsActive() end)
            if success then indoorActive = result end
        end
        
        if catalogSearcher.IsAllowedOutdoorsActive then
            local success, result = pcall(function() return catalogSearcher:IsAllowedOutdoorsActive() end)
            if success then outdoorActive = result end
        end
        
        -- Filter-Logik:
        -- Beide true = kein Filter (alle anzeigen)
        -- Indoor true, Outdoor false = nur Indoor
        -- Indoor false, Outdoor true = nur Outdoor
        -- Beide false = KEINE Items anzeigen!
        if not indoorActive and not outdoorActive then
            activeFilters.indoorOnly = true  -- Erzwinge Indoor-Filter
            activeFilters.outdoorOnly = true -- UND Outdoor-Filter (unmöglich zu erfüllen)
        elseif indoorActive and not outdoorActive then
            activeFilters.indoorOnly = true
        elseif outdoorActive and not indoorActive then
            activeFilters.outdoorOnly = true
        end
        
        -- Customizable Filter
        if catalogSearcher.IsCustomizableOnlyActive then
            local success, result = pcall(function() return catalogSearcher:IsCustomizableOnlyActive() end)
            if success then activeFilters.customizableOnly = result end
        end
        
        -- Collected/Uncollected Filter
        if catalogSearcher.IsCollectedActive and catalogSearcher.IsUncollectedActive then
            local successC, collected = pcall(function() return catalogSearcher:IsCollectedActive() end)
            local successU, uncollected = pcall(function() return catalogSearcher:IsUncollectedActive() end)
            
            if successC and successU then
                if collected and not uncollected then
                    activeFilters.collectedOnly = true
                elseif uncollected and not collected then
                    activeFilters.uncollectedOnly = true
                end
            end
        end
        
        -- Debug: Zeige Filter-Status
        DreamHouse.Debug:Log("FavCat", string.format("Filter: In=%s Out=%s Cust=%s (IndoorAPI=%s OutdoorAPI=%s)", 
            tostring(activeFilters.indoorOnly), tostring(activeFilters.outdoorOnly), 
            tostring(activeFilters.customizableOnly),
            tostring(indoorActive), tostring(outdoorActive)), "DEBUG")
    end
    
    -- Gefilterte Liste erstellen
    currentFilteredFavorites = {}
    
    for _, entryID in ipairs(currentFavoriteEntries) do
        local passesFilter = true
        
        -- EntryInfo holen für Filter-Checks
        local entryInfo = nil
        local success, result = pcall(C_HousingCatalog.GetCatalogEntryInfo, entryID)
        if success then
            entryInfo = result
        end
        
        if entryInfo then
            -- Suchtext-Filter (Name enthält Suchtext)
            if currentSearchText and currentSearchText ~= "" then
                local searchLower = currentSearchText:lower()
                local nameLower = (entryInfo.name or ""):lower()
                if not nameLower:find(searchLower, 1, true) then
                    passesFilter = false
                end
            end
            
            -- Indoor/Outdoor Filter
            -- Wenn BEIDE Filter aktiv sind (beide Checkboxen deaktiviert), zeige nichts
            if activeFilters.indoorOnly and activeFilters.outdoorOnly then
                passesFilter = false  -- Unmöglich zu erfüllen
            elseif passesFilter and activeFilters.indoorOnly then
                if not entryInfo.isAllowedIndoors then
                    passesFilter = false
                end
            elseif passesFilter and activeFilters.outdoorOnly then
                if not entryInfo.isAllowedOutdoors then
                    passesFilter = false
                end
            end
            
            -- Customizable Filter
            if passesFilter and activeFilters.customizableOnly then
                if not entryInfo.isCustomizable then
                    passesFilter = false
                end
            end
            
            -- Collected Filter (nur Items die wir besitzen)
            if passesFilter and activeFilters.collectedOnly then
                if not entryInfo.quantity or entryInfo.quantity <= 0 then
                    passesFilter = false
                end
            end
            
            -- Uncollected Filter (nur Items die wir NICHT besitzen)
            if passesFilter and activeFilters.uncollectedOnly then
                if entryInfo.quantity and entryInfo.quantity > 0 then
                    passesFilter = false
                end
            end
        else
            -- Wenn keine EntryInfo verfügbar, Item trotzdem anzeigen (Fail-Safe)
            DreamHouse.Debug:Log("FavCat", "Keine EntryInfo für " .. tostring(entryID.recordID), "WARN")
        end
        
        if passesFilter then
            table.insert(currentFilteredFavorites, entryID)
        end
    end
    
    -- Immer loggen wie viele Favoriten angezeigt werden
    DreamHouse.Debug:Log("FavCat", string.format("Zeige: %d/%d Favoriten%s", 
        #currentFilteredFavorites, #currentFavoriteEntries, 
        (currentSearchText and currentSearchText ~= "") and (" (Suche: \"" .. currentSearchText .. "\")") or ""), "INFO")
    
    -- Gefilterte Favoriten anzeigen
    self:DisplayFilteredFavorites(catalogPanel, panelType)
    
    isUpdatingFavorites = false
end

-- Gefilterte Favoriten im Panel anzeigen
function DreamHouse.FavoritesCategory:DisplayFilteredFavorites(catalogPanel, panelType)
    if not catalogPanel then return end
    
    -- Header-Text generieren
    local headerText = "|cffffcc00" .. L["Favorites"] .. "|r"
    if currentSearchText and currentSearchText ~= "" then
        headerText = headerText .. " - \"" .. currentSearchText .. "\""
    end
    if #currentFilteredFavorites ~= #currentFavoriteEntries then
        headerText = headerText .. string.format(" (%d/%d)", #currentFilteredFavorites, #currentFavoriteEntries)
    end
    
    if panelType == "editor" then
        -- Editor: SetCustomCatalogData nutzen
        if catalogPanel.SetCustomCatalogData then
            -- Wichtig: customCatalogData setzen damit UpdateCatalogData() nicht überschreibt
            catalogPanel.customCatalogData = currentFilteredFavorites
            catalogPanel.OptionsContainer:SetCatalogData(currentFilteredFavorites, false, headerText)
            
            -- CategoryText aktualisieren
            if catalogPanel.OptionsContainer.CategoryText then
                catalogPanel.OptionsContainer.CategoryText:SetText(headerText)
            end
            
            -- UpdateCategoryText/UpdateCategoryTotal aufrufen
            if catalogPanel.UpdateCategoryText then
                catalogPanel:UpdateCategoryText()
            end
        end
    else
        -- Dashboard: Direkt SetCatalogData aufrufen
        if catalogPanel.OptionsContainer and catalogPanel.OptionsContainer.SetCatalogData then
            -- Dashboard hat kein customCatalogData - wir setzen es manuell
            catalogPanel._dreamhouseCustomData = currentFilteredFavorites
            catalogPanel.OptionsContainer:SetCatalogData(currentFilteredFavorites, false)
            if catalogPanel.OptionsContainer.CategoryText then
                catalogPanel.OptionsContainer.CategoryText:SetText(headerText)
            end
        end
    end
end

-- Prüfen ob wir im Favoriten-Modus sind
function DreamHouse.FavoritesCategory:IsInFavoritesMode()
    return isInFavoritesMode
end

-- Suchtext aktualisieren (wird von Hooks aufgerufen)
function DreamHouse.FavoritesCategory:SetSearchText(newText)
    currentSearchText = newText or ""
end

-- Dashboard-Hooks on-demand installieren
local dashboardHooksInstalledOnDemand = false
local dashboardSearchBoxHookedOnDemand = false

function DreamHouse.FavoritesCategory:EnsureDashboardHooks(catalogPanel)
    if not catalogPanel then return end
    
    -- Mixin-Hooks installieren
    if not dashboardHooksInstalledOnDemand and HousingCatalogFrameMixin then
        local originalOnCategoryFocusChanged = HousingCatalogFrameMixin.OnCategoryFocusChanged
        HousingCatalogFrameMixin.OnCategoryFocusChanged = function(self, focusedCategoryID, focusedSubcategoryID)
            if isInFavoritesMode and currentPanelType == "dashboard" then
                DreamHouse.Debug:Log("FavCat", "Dashboard OnCategoryFocusChanged geblockt", "DEBUG")
                return
            end
            return originalOnCategoryFocusChanged(self, focusedCategoryID, focusedSubcategoryID)
        end
        
        local originalOnEntryResultsUpdated = HousingCatalogFrameMixin.OnEntryResultsUpdated
        HousingCatalogFrameMixin.OnEntryResultsUpdated = function(self)
            if isInFavoritesMode and currentPanelType == "dashboard" then
                DreamHouse.Debug:Log("FavCat", "Dashboard OnEntryResultsUpdated geblockt", "DEBUG")
                return
            end
            return originalOnEntryResultsUpdated(self)
        end
        
        local originalUpdateCatalogData = HousingCatalogFrameMixin.UpdateCatalogData
        HousingCatalogFrameMixin.UpdateCatalogData = function(self)
            if isInFavoritesMode and currentPanelType == "dashboard" and self._dreamhouseCustomData then
                DreamHouse.Debug:Log("FavCat", "Dashboard UpdateCatalogData geblockt", "DEBUG")
                return
            end
            return originalUpdateCatalogData(self)
        end
        
        dashboardHooksInstalledOnDemand = true
        DreamHouse.Debug:Log("FavCat", "Dashboard Mixin-Hooks installiert (on-demand)", "SUCCESS")
    end
    
    -- SearchBox hooken - WICHTIG: Blizzard's Code blockieren wenn im Favoriten-Modus!
    if not dashboardSearchBoxHookedOnDemand and catalogPanel.SearchBox then
        local searchBox = catalogPanel.SearchBox
        if searchBox.GetText then
            -- Hook UpdateTextSearch um den Callback zu blockieren
            if searchBox.UpdateTextSearch then
                local originalUpdateTextSearch = searchBox.UpdateTextSearch
                searchBox.UpdateTextSearch = function(self, text)
                    if isInFavoritesMode and currentPanelType == "dashboard" then
                        -- Im Favoriten-Modus: Callback NICHT aufrufen, nur unsere Logik
                        local newText = text or ""
                        if newText ~= currentSearchText then
                            currentSearchText = newText
                            DreamHouse.Debug:Log("FavCat", "Dashboard Suche: \"" .. currentSearchText .. "\"", "INFO")
                            DreamHouse.FavoritesCategory:ApplyFiltersToFavorites()
                        end
                        return  -- Blizzard's Callback NICHT aufrufen!
                    end
                    return originalUpdateTextSearch(self, text)
                end
                DreamHouse.Debug:Log("FavCat", "Dashboard UpdateTextSearch gehookt", "SUCCESS")
            end
            
            dashboardSearchBoxHookedOnDemand = true
            DreamHouse.Debug:Log("FavCat", "Dashboard SearchBox gehookt (on-demand)", "SUCCESS")
        end
    end
end

-- Favoriten-Modus beenden
function DreamHouse.FavoritesCategory:ExitFavoritesMode()
    if not isInFavoritesMode then return end
    
    DreamHouse.Debug:Log("FavCat", "Favoriten-Modus wird beendet...", "DEBUG")
    
    -- Speichere Panel-Typ und Panel BEVOR wir die Variablen zurücksetzen
    local wasInDashboard = (currentPanelType == "dashboard")
    local catalogPanel, panelType = self:GetCatalogPanel()
    
    -- Variablen zurücksetzen
    isInFavoritesMode = false
    currentFavoriteEntries = {}
    currentFilteredFavorites = {}
    currentSearchText = ""
    currentPanelType = nil
    
    -- Custom-Data Flag zurücksetzen
    if catalogPanel then
        if panelType == "editor" then
            -- Editor: customCatalogData wird von Blizzard selbst gehandelt
            -- Wir setzen es nur auf nil wenn wir es selbst gesetzt haben
            if catalogPanel.customCatalogData then
                -- Nicht setzen - Blizzard macht das über SetCustomCatalogData(nil)
            end
        else
            -- Dashboard: Unser eigenes Flag zurücksetzen
            catalogPanel._dreamhouseCustomData = nil
            
            -- WICHTIG: Dashboard-Katalog muss explizit aktualisiert werden!
            -- OnCategoryFocusChanged wurde geblockt während wir im Favoriten-Modus waren,
            -- also müssen wir das Update manuell triggern
            if wasInDashboard then
                DreamHouse.Debug:Log("FavCat", "Dashboard: Trigger UpdateCatalogData nach Exit", "DEBUG")
                -- Kurze Verzögerung damit Blizzard's interne Zustände aktualisiert sind
                C_Timer.After(0.05, function()
                    if catalogPanel and catalogPanel.UpdateCatalogData then
                        catalogPanel:UpdateCatalogData()
                        DreamHouse.Debug:Log("FavCat", "Dashboard: UpdateCatalogData ausgeführt", "SUCCESS")
                    end
                end)
            end
        end
    end
    
    DreamHouse.Debug:Log("FavCat", "Favoriten-Modus beendet", "DEBUG")
end

-- Katalog-Panel finden (Editor ODER Dashboard)
function DreamHouse.FavoritesCategory:GetCatalogPanel()
    -- Dashboard hat Priorität wenn es sichtbar ist
    if HousingDashboardFrame and HousingDashboardFrame:IsShown() and HousingDashboardFrame.CatalogContent then
        return HousingDashboardFrame.CatalogContent, "dashboard"
    end
    
    -- Dann Editor-StoragePanel prüfen
    if HouseEditorFrame and HouseEditorFrame:IsShown() and HouseEditorFrame.StoragePanel then
        return HouseEditorFrame.StoragePanel, "editor"
    end
    
    return nil, nil
end

-- Favoriten-Hauptkategorie anzeigen (zeigt ALLE Favoriten direkt)
function DreamHouse.FavoritesCategory:OnClick()
    local catalogPanel, panelType = self:GetCatalogPanel()
    
    if not catalogPanel then
        DreamHouse.Debug:Log("FavCat", "Kein Katalog-Panel gefunden!", "ERROR")
        return
    end
    
    local catalogSearcher = catalogPanel.catalogSearcher
    if not catalogSearcher then
        DreamHouse.Debug:Log("FavCat", "CatalogSearcher nicht verfügbar!", "ERROR")
        return
    end
    
    DreamHouse.Debug:Log("FavCat", "Verwende Panel-Typ: " .. panelType, "DEBUG")
    
    -- Suchtext zurücksetzen bei Panel-Wechsel oder neuem Favoriten-Klick
    currentSearchText = ""
    if catalogPanel.SearchBox then
        catalogPanel.SearchBox:SetText("")
    end
    
    -- Hooks on-demand installieren falls noch nicht geschehen
    if panelType == "dashboard" then
        self:EnsureDashboardHooks(catalogPanel)
    end
    
    -- Favoriten-recordIDs sammeln
    local favoriteRecordIDs = {}
    local favorites = DreamHouse.Settings:GetAllFavorites()
    for key, data in pairs(favorites) do
        if type(data) == "table" and data.recordID then
            favoriteRecordIDs[data.recordID] = true
        elseif type(data) == "boolean" then
            local recordID = tonumber(string.match(key, "^(%d+)"))
            if recordID then
                favoriteRecordIDs[recordID] = true
            end
        end
    end
    
    -- Alle Favoriten aus dem Katalog sammeln
    local allItems = catalogSearcher:GetAllSearchItems()
    local favoriteEntries = {}
    
    for _, entryID in ipairs(allItems) do
        if entryID.recordID and favoriteRecordIDs[entryID.recordID] then
            table.insert(favoriteEntries, entryID)
        end
    end
    
    if #favoriteEntries == 0 then
        DreamHouse.Debug:Log("FavCat", "Keine Favoriten vorhanden!", "WARN")
        print("|cff00ccff[DreamHouse]|r " .. L["No favorites marked yet"])
        print("|cff00ccff[DreamHouse]|r " .. L["Click star or use context menu"])
        return
    end
    
    -- FAVORITEN-MODUS AKTIVIEREN
    isInFavoritesMode = true
    currentFavoriteEntries = favoriteEntries
    currentFilteredFavorites = favoriteEntries  -- Initial ungefiltert
    currentSearchText = ""  -- Suche zurücksetzen
    currentPanelType = panelType
    
    -- Suchbox leeren wenn vorhanden
    if catalogPanel.SearchBox then
        catalogPanel.SearchBox:SetText("")
    end
    
    DreamHouse.Debug:Log("FavCat", "Zeige " .. #favoriteEntries .. " Favoriten (Favoriten-Modus aktiviert)", "INFO")
    
    -- Favoriten anzeigen - je nach Panel-Typ
    if panelType == "editor" then
        -- Editor: SetCustomCatalogData verwenden
        if catalogPanel.SetCustomCatalogData then
            catalogPanel:SetCustomCatalogData(favoriteEntries, "|cffffcc00" .. L["Favorites"] .. "|r")
        end
    else
        -- Dashboard: Direkt SetCatalogData + eigenes Flag setzen
        catalogPanel._dreamhouseCustomData = favoriteEntries
        if catalogPanel.OptionsContainer and catalogPanel.OptionsContainer.SetCatalogData then
            catalogPanel.OptionsContainer:SetCatalogData(favoriteEntries, false)
            if catalogPanel.OptionsContainer.CategoryText then
                catalogPanel.OptionsContainer.CategoryText:SetText("|cffffcc00" .. L["Favorites"] .. "|r")
            end
        end
    end
    
    -- Button als aktiv markieren
    self:SetActive(true)
    
    PlaySound(SOUNDKIT.HOUSING_CATALOG_CATEGORY_SELECT)
end


-- Button als aktiv/inaktiv markieren (Hauptkategorie)
function DreamHouse.FavoritesCategory:SetActive(active)
    if not favoritesButton then return end
    
    favoritesButton.isActive = active
    favoritesButton.SelectedBackground:SetShown(active)
    
    if active then
        favoritesButton.Icon:SetTexture(TEXTURE_ACTIVE)
        favoritesButton.HoverIcon:SetTexture(TEXTURE_ACTIVE)
    else
        favoritesButton.Icon:SetTexture(TEXTURE_INACTIVE)
        favoritesButton.HoverIcon:SetTexture(TEXTURE_INACTIVE)
    end
end

-- Unterkategorie-Button als aktiv/inaktiv markieren
function DreamHouse.FavoritesCategory:SetSubcategoryActive(active)
    if not favoritesSubcategoryButton then return end
    
    favoritesSubcategoryButton.isActive = active
    favoritesSubcategoryButton.SelectedBackground:SetShown(active)
    
    if active then
        favoritesSubcategoryButton.Icon:SetTexture(TEXTURE_ACTIVE)
        favoritesSubcategoryButton.HoverIcon:SetTexture(TEXTURE_ACTIVE)
    else
        favoritesSubcategoryButton.Icon:SetTexture(TEXTURE_INACTIVE)
        favoritesSubcategoryButton.HoverIcon:SetTexture(TEXTURE_INACTIVE)
    end
end

-- Unterkategorie-Button erstellen (kleiner, 54x54)
local function CreateFavoritesSubcategoryButton(parent)
    local btn = CreateFrame("Button", "DreamHouseFavoritesSubcategoryButton", parent)
    local size = parent.subcategoryButtonSize or 54
    btn:SetSize(size, size)
    
    -- Icon (unsere Custom-Textur) - etwas kleiner für Rand
    btn.Icon = btn:CreateTexture(nil, "ARTWORK")
    btn.Icon:SetSize(size - 6, size - 6)
    btn.Icon:SetPoint("CENTER", 0, 0)
    btn.Icon:SetTexture(TEXTURE_INACTIVE)
    
    -- Hover-Glow
    btn.HoverIcon = btn:CreateTexture(nil, "OVERLAY")
    btn.HoverIcon:SetSize(size - 6, size - 6)
    btn.HoverIcon:SetPoint("CENTER", 0, 0)
    btn.HoverIcon:SetTexture(TEXTURE_INACTIVE)
    btn.HoverIcon:SetAlpha(0.4)
    btn.HoverIcon:SetBlendMode("ADD")
    btn.HoverIcon:Hide()
    
    -- Selection Background
    btn.SelectedBackground = btn:CreateTexture(nil, "BACKGROUND", nil, -1)
    btn.SelectedBackground:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.SelectedBackground:SetSize(75, size + 20)  -- Feste Breite statt Parent-Referenz
    btn.SelectedBackground:SetAtlas("house-chest-active-nav_selected-bg-glow")
    btn.SelectedBackground:Hide()

    -- State
    btn.isActive = false
    btn.isDreamHouseFavorites = true  -- Flag für unsere Erkennung
    btn.isSubcategory = true  -- Wichtig für OnCategoryClicked!
    btn.align = "center"
    
    -- Hover-Effekte
    btn:SetScript("OnEnter", function(self)
        self.HoverIcon:Show()
        if not self.isActive then
            self.Icon:SetTexture(TEXTURE_PRESSED)
            self.HoverIcon:SetTexture(TEXTURE_PRESSED)
        end
        
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -12, -12)
        GameTooltip:SetText("|cffffcc00" .. L["Favorites"] .. "|r")
        GameTooltip:AddLine(L["Favorites from this category only"], 1, 1, 1)
        GameTooltip:Show()
        
        PlaySound(SOUNDKIT.HOUSING_CATALOG_SUBCATEGORY_HOVER)
    end)
    
    btn:SetScript("OnLeave", function(self)
        self.HoverIcon:Hide()
        if self.isActive then
            self.Icon:SetTexture(TEXTURE_ACTIVE)
        else
            self.Icon:SetTexture(TEXTURE_INACTIVE)
        end
        GameTooltip:Hide()
    end)
    
    btn:SetScript("OnMouseDown", function(self)
        self.Icon:SetTexture(TEXTURE_PRESSED)
    end)
    
    btn:SetScript("OnMouseUp", function(self)
        if self.isActive then
            self.Icon:SetTexture(TEXTURE_ACTIVE)
        else
            self.Icon:SetTexture(TEXTURE_INACTIVE)
        end
    end)
    
    -- Klick-Handler - filtert nach aktueller Kategorie
    btn:SetScript("OnClick", function(self)
        DreamHouse.FavoritesCategory:OnSubcategoryClick()
    end)
    
    return btn
end

-- Favoriten aus aktueller Kategorie anzeigen (Unterkategorie-Klick)
function DreamHouse.FavoritesCategory:OnSubcategoryClick()
    local storagePanel = HouseEditorFrame and HouseEditorFrame.StoragePanel
    if not storagePanel then return end
    
    local categories = storagePanel.Categories
    if not categories then return end
    
    -- Aktuelle Kategorie-ID holen
    local currentCategoryID = categories.focusedCategoryID
    if not currentCategoryID then
        DreamHouse.Debug:Log("FavCat", "Keine Kategorie fokussiert!", "WARN")
        return
    end
    
    DreamHouse.Debug:Log("FavCat", "Zeige Favoriten für Kategorie: " .. tostring(currentCategoryID), "INFO")
    
    -- Favoriten-recordIDs sammeln
    local favoriteRecordIDs = {}
    local favorites = DreamHouse.Settings:GetAllFavorites()
    for key, data in pairs(favorites) do
        if type(data) == "table" and data.recordID then
            favoriteRecordIDs[data.recordID] = true
        elseif type(data) == "boolean" then
            local recordID = tonumber(string.match(key, "^(%d+)"))
            if recordID then
                favoriteRecordIDs[recordID] = true
            end
        end
    end
    
    -- CatalogSearcher verwenden
    local catalogSearcher = storagePanel.catalogSearcher
    if not catalogSearcher then return end
    
    -- Nur Items aus der aktuellen Kategorie holen (nicht alle!)
    -- Der Searcher sollte bereits auf die Kategorie gefiltert sein
    local categoryItems = catalogSearcher:GetCatalogSearchResults()
    local favoriteEntries = {}
    
    for _, entryID in ipairs(categoryItems) do
        if entryID.recordID and favoriteRecordIDs[entryID.recordID] then
            table.insert(favoriteEntries, entryID)
        end
    end
    
    -- Kategorie-Name holen für Header
    local categoryName = "Kategorie"
    local categoryData = categories.categories and categories.categories[currentCategoryID]
    if categoryData and categoryData.categoryInfo and categoryData.categoryInfo.name then
        categoryName = categoryData.categoryInfo.name
    end
    
    DreamHouse.Debug:Log("FavCat", "Zeige " .. #favoriteEntries .. " Favoriten in " .. categoryName, "INFO")
    
    if #favoriteEntries > 0 then
        storagePanel:SetCustomCatalogData(favoriteEntries, "|cffffcc00" .. L["Favorites"] .. "|r - " .. categoryName)
        self:SetSubcategoryActive(true)
        
        -- "Alle" Button von Blizzard ausblenden und Layout neu berechnen
        if categories.AllSubcategoriesStandIn then
            categories.AllSubcategoriesStandIn:Hide()
            -- Unser Button nach oben schieben (nimmt den Platz von "Alle")
            if favoritesSubcategoryButton then
                favoritesSubcategoryButton.layoutIndex = categories.AllSubcategoriesStandIn.layoutIndex or 3
            end
            categories:Layout()
        end
        PlaySound(SOUNDKIT.HOUSING_CATALOG_SUBCATEGORY_SELECT)
    else
        print("|cff00ccff[DreamHouse]|r " .. L["No favorites in this category"])
    end
end

-- Hilfsfunktion: Prüft ob wir im Layout-Modus sind (Bauplan bearbeiten)
local function IsInLayoutMode()
    -- Layout-Modus ist für Raumauswahl, nicht für Dekor-Favoriten
    local currentMode = C_HouseEditor.GetActiveHouseEditorMode()
    return currentMode == Enum.HouseEditorMode.Layout
end

-- Hook anwenden
function DreamHouse.FavoritesCategory:Apply()
    if isApplied then return end
    
    DreamHouse.Debug:Log("FavCat", "Wende Favoriten-Kategorie Hook an...", "INFO")
    
    -- Hook ClearCategoryFrames um unsere Buttons vor dem Layout zu verstecken
    -- WICHTIG: Dies verhindert "Duplicate layoutIndex" Fehler!
    if HousingCatalogCategoriesMixin then
        hooksecurefunc(HousingCatalogCategoriesMixin, "ClearCategoryFrames", function(self)
            -- Unsere Buttons verstecken und layoutIndex entfernen
            -- damit sie nicht im Layout() mitgezählt werden
            if favoritesButton then
                favoritesButton:Hide()
                favoritesButton.layoutIndex = nil
            end
            if favoritesSubcategoryButton then
                favoritesSubcategoryButton:Hide()
                favoritesSubcategoryButton.layoutIndex = nil
            end
            DreamHouse.Debug:Log("FavCat", "ClearCategoryFrames - Buttons versteckt", "DEBUG")
        end)
        DreamHouse.Debug:Log("FavCat", "ClearCategoryFrames gehookt", "SUCCESS")
    end
    
    -- Hook DisplayTopLevelCategories
    if HousingCatalogCategoriesMixin then
        hooksecurefunc(HousingCatalogCategoriesMixin, "DisplayTopLevelCategories", function(self)
            -- Unterkategorie-Button VERSTECKEN in Hauptkategorie-Ansicht
            if favoritesSubcategoryButton then
                favoritesSubcategoryButton:Hide()
            end
            
            -- *** LAYOUT-MODUS CHECK ***
            -- Im Layout-Modus (Bauplan bearbeiten) werden Räume ausgewählt, keine Dekor-Items
            -- Favoriten-Button sollte dort nicht erscheinen
            if IsInLayoutMode() then
                if favoritesButton then
                    favoritesButton:Hide()
                end
                DreamHouse.Debug:Log("FavCat", "Layout-Modus erkannt - Favoriten-Button versteckt", "DEBUG")
                return
            end
            
            -- Favoriten-Button erstellen falls nicht vorhanden
            if not favoritesButton then
                favoritesButton = CreateFavoritesButton(self)
                DreamHouse.Debug:Log("FavCat", "Favoriten-Button erstellt", "SUCCESS")
            end
            
            -- Button in das Layout einfügen (am Ende)
            -- Finde den höchsten layoutIndex
            local maxIndex = 0
            for _, frame in pairs(self.categoryFramesByID or {}) do
                if frame.layoutIndex and frame.layoutIndex > maxIndex then
                    maxIndex = frame.layoutIndex
                end
            end
            
            -- Favoriten-Button am Ende einfügen
            favoritesButton.layoutIndex = maxIndex + 1
            favoritesButton:SetParent(self)
            
            -- Größe vom Parent übernehmen (falls sich was geändert hat)
            local size = self.categoryButtonSize or 64
            favoritesButton:SetSize(size, size)
            
            -- Auch die Icon-Texturen updaten
            favoritesButton.Icon:SetSize(size - 6, size - 6)
            favoritesButton.HoverIcon:SetSize(size - 6, size - 6)
            favoritesButton.SelectedBackground:SetSize(75, size + 20)
            
            -- Layout-Properties wie bei Blizzard-Buttons
            favoritesButton.align = "center"
            
            favoritesButton:Show()
            
            -- NUR als inaktiv markieren wenn wir NICHT im Favoriten-Modus sind
            if not isInFavoritesMode then
                DreamHouse.FavoritesCategory:SetActive(false)
            end
            
            -- Layout aktualisieren
            self:Layout()
            
            DreamHouse.Debug:Log("FavCat", "Favoriten-Button eingefügt (Index: " .. favoritesButton.layoutIndex .. ")", "DEBUG")
        end)
        
        DreamHouse.Debug:Log("FavCat", "DisplayTopLevelCategories gehookt", "SUCCESS")
        
        -- Hook für andere Kategorie-Klicks (deaktiviert unsere Buttons + beendet Favoriten-Modus)
        hooksecurefunc(HousingCatalogCategoriesMixin, "OnCategoryClicked", function(self, categoryFrame)
            -- Prüfe ob es einer unserer Buttons ist
            local isOurFavoritesButton = (categoryFrame == favoritesButton) or 
                                          (categoryFrame == favoritesSubcategoryButton) or
                                          (categoryFrame and categoryFrame.isDreamHouseFavorites)
            
            DreamHouse.Debug:Log("FavCat", string.format("OnCategoryClicked: isOur=%s, isInFavMode=%s", 
                tostring(isOurFavoritesButton), tostring(isInFavoritesMode)), "DEBUG")
            
            if not isOurFavoritesButton then
                -- Wenn eine andere Kategorie geklickt wurde, Favoriten-Modus beenden
                if isInFavoritesMode then
                    DreamHouse.Debug:Log("FavCat", "Andere Kategorie geklickt -> Favoriten-Modus wird beendet", "INFO")
                end
                DreamHouse.FavoritesCategory:SetActive(false)
                DreamHouse.FavoritesCategory:SetSubcategoryActive(false)
                DreamHouse.FavoritesCategory:ExitFavoritesMode()
            end
        end)
        
        -- Hook für ClearFocus (wenn zurück zur normalen Ansicht)
        hooksecurefunc(HousingCatalogCategoriesMixin, "ClearFocus", function(self)
            DreamHouse.Debug:Log("FavCat", "ClearFocus aufgerufen, isInFavoritesMode=" .. tostring(isInFavoritesMode), "DEBUG")
            
            -- Im Favoriten-Modus ignorieren wir ClearFocus
            -- (wird z.B. bei Tab-Wechsel aufgerufen)
            if isInFavoritesMode then
                DreamHouse.Debug:Log("FavCat", "ClearFocus ignoriert (Favoriten-Modus aktiv)", "DEBUG")
                return
            end
            
            DreamHouse.FavoritesCategory:SetActive(false)
            DreamHouse.FavoritesCategory:SetSubcategoryActive(false)
        end)
        
        -- Hook für SetFocus - sicherstellen dass UI nach Favoriten-Ansicht korrekt aktualisiert wird
        hooksecurefunc(HousingCatalogCategoriesMixin, "SetFocus", function(self, focusedCategoryID, focusedSubcategoryID)
            -- Wenn wir von Custom-Daten (Favoriten) zu einer normalen Kategorie wechseln
            local storagePanel = HouseEditorFrame and HouseEditorFrame.StoragePanel
            if storagePanel then
                -- UpdateCategoryText aufrufen um die Anzeige zu aktualisieren
                if storagePanel.UpdateCategoryText then
                    storagePanel:UpdateCategoryText()
                end
            end
        end)
        
        DreamHouse.Debug:Log("FavCat", "Kategorie-Klick Hooks registriert", "SUCCESS")
        
        -- Hook DisplaySubcategoriesUnderCategory - Favoriten als Unterkategorie
        hooksecurefunc(HousingCatalogCategoriesMixin, "DisplaySubcategoriesUnderCategory", function(self, category)
            -- Hauptkategorie-Button VERSTECKEN in Unterkategorie-Ansicht
            if favoritesButton then
                favoritesButton:Hide()
            end
            
            -- *** LAYOUT-MODUS CHECK ***
            -- Im Layout-Modus (Bauplan bearbeiten) werden Räume ausgewählt, keine Dekor-Items
            -- Favoriten-Unterkategorie sollte dort nicht erscheinen
            if IsInLayoutMode() then
                if favoritesSubcategoryButton then
                    favoritesSubcategoryButton:Hide()
                end
                DreamHouse.Debug:Log("FavCat", "Layout-Modus erkannt - Favoriten-Unterkategorie versteckt", "DEBUG")
                return
            end
            
            -- Unterkategorie-Button erstellen falls nicht vorhanden
            if not favoritesSubcategoryButton then
                favoritesSubcategoryButton = CreateFavoritesSubcategoryButton(self)
                DreamHouse.Debug:Log("FavCat", "Favoriten-Unterkategorie-Button erstellt", "SUCCESS")
            end
            
            -- Höchsten layoutIndex finden (von subcategoryFramesByID)
            local maxIndex = 3  -- Start nach AllSubcategoriesStandIn (layoutIndex 3)
            for _, frame in pairs(self.subcategoryFramesByID or {}) do
                if frame.layoutIndex and frame.layoutIndex > maxIndex then
                    maxIndex = frame.layoutIndex
                end
            end
            
            -- Favoriten-Button am Ende einfügen
            favoritesSubcategoryButton.layoutIndex = maxIndex + 1
            favoritesSubcategoryButton:SetParent(self)
            
            -- Größe vom Parent übernehmen
            local size = self.subcategoryButtonSize or 54
            favoritesSubcategoryButton:SetSize(size, size)
            favoritesSubcategoryButton.Icon:SetSize(size - 6, size - 6)
            favoritesSubcategoryButton.HoverIcon:SetSize(size - 6, size - 6)
            
            favoritesSubcategoryButton.align = "center"
            favoritesSubcategoryButton:Show()
            
            -- NUR als inaktiv markieren wenn wir NICHT im Favoriten-Modus sind
            if not isInFavoritesMode then
                DreamHouse.FavoritesCategory:SetSubcategoryActive(false)
            end
            
            -- Layout aktualisieren
            self:Layout()
            
            DreamHouse.Debug:Log("FavCat", "Favoriten-Unterkategorie eingefügt für: " .. (category.categoryInfo.name or "?"), "DEBUG")
        end)
        
        DreamHouse.Debug:Log("FavCat", "DisplaySubcategoriesUnderCategory gehookt", "SUCCESS")
        
        
    else
        DreamHouse.Debug:Log("FavCat", "HousingCatalogCategoriesMixin nicht verfügbar!", "ERROR")
    end
    
    -- ===============================================
    -- SUCH- UND FILTER-HOOKS FÜR FAVORITEN
    -- ===============================================
    
    -- Debounce-System um Spam zu verhindern
    local pendingFilterUpdate = false
    local function ScheduleFilterUpdate()
        if pendingFilterUpdate then 
            DreamHouse.Debug:Log("FavCat", "Filter-Update bereits geplant", "DEBUG")
            return 
        end
        if not isInFavoritesMode then 
            DreamHouse.Debug:Log("FavCat", "Nicht im Favoriten-Modus - Skip", "DEBUG")
            return 
        end
        
        DreamHouse.Debug:Log("FavCat", "Filter-Update geplant...", "DEBUG")
        pendingFilterUpdate = true
        C_Timer.After(0.1, function()
            pendingFilterUpdate = false
            if isInFavoritesMode then
                DreamHouse.Debug:Log("FavCat", "Führe Filter-Update aus", "DEBUG")
                DreamHouse.FavoritesCategory:ApplyFiltersToFavorites()
            end
        end)
    end
    
    -- Funktion um Editor-Hooks zu installieren (wird aufgerufen wenn Mixin verfügbar)
    local editorHooksInstalled = false
    local function InstallEditorHooks()
        if editorHooksInstalled then return end
        if not HouseEditorStorageFrameMixin then return end
        
        editorHooksInstalled = true
        
        -- KRITISCH: Hook OnCategoryFocusChanged BEVOR es customCatalogData löscht
        local originalOnCategoryFocusChanged = HouseEditorStorageFrameMixin.OnCategoryFocusChanged
        HouseEditorStorageFrameMixin.OnCategoryFocusChanged = function(self, focusedCategoryID, focusedSubcategoryID)
            if isInFavoritesMode and currentPanelType == "editor" then
                DreamHouse.Debug:Log("FavCat", "OnCategoryFocusChanged geblockt", "DEBUG")
                return
            end
            return originalOnCategoryFocusChanged(self, focusedCategoryID, focusedSubcategoryID)
        end
        DreamHouse.Debug:Log("FavCat", "Editor OnCategoryFocusChanged Override", "SUCCESS")
        
        -- POST-Hook für OnSearchTextUpdated
        hooksecurefunc(HouseEditorStorageFrameMixin, "OnSearchTextUpdated", function(self, newSearchText)
            if isInFavoritesMode and currentPanelType == "editor" then
                currentSearchText = newSearchText or ""
                DreamHouse.Debug:Log("FavCat", "Editor Suche: \"" .. currentSearchText .. "\"", "INFO")
                DreamHouse.FavoritesCategory:ApplyFiltersToFavorites()
            end
        end)
        DreamHouse.Debug:Log("FavCat", "Editor OnSearchTextUpdated Hook", "SUCCESS")
        
        -- Override OnEntryResultsUpdated
        local originalOnEntryResultsUpdated = HouseEditorStorageFrameMixin.OnEntryResultsUpdated
        HouseEditorStorageFrameMixin.OnEntryResultsUpdated = function(self)
            if isInFavoritesMode and currentPanelType == "editor" then
                DreamHouse.Debug:Log("FavCat", "OnEntryResultsUpdated geblockt", "DEBUG")
                return
            end
            return originalOnEntryResultsUpdated(self)
        end
        DreamHouse.Debug:Log("FavCat", "Editor OnEntryResultsUpdated Override", "SUCCESS")
        
        -- Hook UpdateCatalogData
        hooksecurefunc(HouseEditorStorageFrameMixin, "UpdateCatalogData", function(self)
            if isInFavoritesMode and currentPanelType == "editor" and not self.customCatalogData then
                DreamHouse.Debug:Log("FavCat", "UpdateCatalogData Schutz", "WARN")
                ScheduleFilterUpdate()
            end
        end)
        DreamHouse.Debug:Log("FavCat", "Editor UpdateCatalogData Hook", "SUCCESS")
    end
    
    -- Versuche Editor-Hooks sofort zu installieren
    InstallEditorHooks()
    
    -- Falls Editor noch nicht verfügbar, auf Events warten
    if not editorHooksInstalled then
        DreamHouse.Debug:Log("FavCat", "Editor-Mixin noch nicht verfügbar - warte auf Event", "DEBUG")
        DreamHouse.Events:Register("DREAMHOUSE_MODE_CHANGED", function()
            InstallEditorHooks()
        end, DreamHouse.FavoritesCategory)
    end
    
    -- Dashboard-Hooks werden on-demand installiert via EnsureDashboardHooks()
    DreamHouse.Debug:Log("FavCat", "Dashboard-Hooks werden bei Bedarf installiert", "DEBUG")
    
    -- ===== DIREKTE SEARCHBOX HOOKS =====
    -- Die SearchBox ruft den Callback über einen Closure auf, nicht über self:Method()
    -- Deshalb müssen wir die SearchBox direkt hooken
    
    local editorSearchBoxHooked = false
    
    local function HookEditorSearchBox(storagePanel)
        if editorSearchBoxHooked then return end
        if not storagePanel or not storagePanel.SearchBox then return end
        
        local searchBox = storagePanel.SearchBox
        
        if searchBox.GetText then
            -- Hook UpdateTextSearch um den Callback zu blockieren
            if searchBox.UpdateTextSearch then
                local originalUpdateTextSearch = searchBox.UpdateTextSearch
                searchBox.UpdateTextSearch = function(self, text)
                    if isInFavoritesMode and currentPanelType == "editor" then
                        -- Im Favoriten-Modus: Callback NICHT aufrufen, nur unsere Logik
                        local newText = text or ""
                        if newText ~= currentSearchText then
                            currentSearchText = newText
                            DreamHouse.Debug:Log("FavCat", "Editor Suche: \"" .. currentSearchText .. "\"", "INFO")
                            ScheduleFilterUpdate()
                        end
                        return  -- Blizzard's Callback NICHT aufrufen!
                    end
                    return originalUpdateTextSearch(self, text)
                end
                DreamHouse.Debug:Log("FavCat", "Editor UpdateTextSearch gehookt", "SUCCESS")
            end
            
            editorSearchBoxHooked = true
            DreamHouse.Debug:Log("FavCat", "Editor SearchBox gehookt", "SUCCESS")
        end
    end
    
    -- Hook wenn Storage-Frame verfügbar wird (Editor)
    DreamHouse.Events:Register("DREAMHOUSE_STORAGE_OPENED", function()
        if HouseEditorFrame and HouseEditorFrame.StoragePanel then
            HookEditorSearchBox(HouseEditorFrame.StoragePanel)
        end
    end, DreamHouse.FavoritesCategory)
    
    -- Falls Storage bereits existiert
    if HouseEditorFrame and HouseEditorFrame.StoragePanel then
        HookEditorSearchBox(HouseEditorFrame.StoragePanel)
    end
    
    -- Dashboard-Hooks werden on-demand via EnsureDashboardHooks() installiert
    -- wenn der Favoriten-Button im Dashboard geklickt wird
    
    -- ===== FILTER-HOOKS (NUR für Toggle-Funktionen, NICHT für Getter!) =====
    
    -- Liste der Funktionen die TATSÄCHLICH Filter ändern (Toggle/Set, NICHT Get!)
    local actualFilterChangeFuncs = {
        ["ToggleAllowedIndoors"] = true,
        ["ToggleAllowedOutdoors"] = true,
        ["ToggleCollected"] = true,
        ["ToggleUncollected"] = true,
        ["ToggleCustomizableOnly"] = true,
        ["ToggleFilterTag"] = true,
        ["SetAllInFilterTagGroup"] = true,
        ["SetAllowedIndoors"] = true,
        ["SetAllowedOutdoors"] = true,
        ["SetCollected"] = true,
        ["SetUncollected"] = true,
        ["SetCustomizableOnly"] = true,
    }
    
    -- Hook für Filter-Änderungen über die Filter-Mixin Methoden
    if HousingCatalogFiltersMixin then
        hooksecurefunc(HousingCatalogFiltersMixin, "TryCallSearcherFunc", function(self, funcName, ...)
            -- NUR bei tatsächlichen Änderungen, NICHT bei Gettern!
            if isInFavoritesMode and actualFilterChangeFuncs[funcName] then
                DreamHouse.Debug:Log("FavCat", "Filter geändert: " .. tostring(funcName), "INFO")
                ScheduleFilterUpdate()
            end
        end)
        DreamHouse.Debug:Log("FavCat", "HousingCatalogFiltersMixin Hook installiert", "SUCCESS")
        
        -- Hook für Filter-Reset (Zurücksetzen-Button)
        hooksecurefunc(HousingCatalogFiltersMixin, "ResetFiltersToDefault", function(self)
            if isInFavoritesMode then
                DreamHouse.Debug:Log("FavCat", "Filter zurückgesetzt!", "INFO")
                ScheduleFilterUpdate()
            end
        end)
        DreamHouse.Debug:Log("FavCat", "ResetFiltersToDefault Hook installiert", "SUCCESS")
    end
    
    -- Direkte Hooks auf Searcher (als Backup)
    local function HookCatalogSearcher(panel, panelName)
        if not panel or not panel.catalogSearcher then return end
        
        local searcher = panel.catalogSearcher
        if searcher._dreamhouseHooked then return end
        
        for funcName, _ in pairs(actualFilterChangeFuncs) do
            if searcher[funcName] then
                hooksecurefunc(searcher, funcName, function()
                    if isInFavoritesMode then
                        DreamHouse.Debug:Log("FavCat", panelName .. "." .. funcName, "DEBUG")
                        ScheduleFilterUpdate()
                    end
                end)
            end
        end
        
        searcher._dreamhouseHooked = true
        DreamHouse.Debug:Log("FavCat", panelName .. " Searcher Hooks registriert", "SUCCESS")
    end
    
    -- Hook wenn Panels initialisiert werden
    if HouseEditorStorageFrameMixin then
        hooksecurefunc(HouseEditorStorageFrameMixin, "OnLoad", function(self)
            C_Timer.After(0.1, function()
                HookCatalogSearcher(self, "Editor")
            end)
        end)
    end
    
    if HousingCatalogFrameMixin then
        hooksecurefunc(HousingCatalogFrameMixin, "OneTimeInit", function(self)
            C_Timer.After(0.1, function()
                HookCatalogSearcher(self, "Dashboard")
            end)
        end)
    end
    
    -- Falls Panels bereits existieren
    if HouseEditorFrame and HouseEditorFrame.StoragePanel then
        HookCatalogSearcher(HouseEditorFrame.StoragePanel, "Editor")
    end
    if HousingDashboardFrame and HousingDashboardFrame.CatalogContent then
        HookCatalogSearcher(HousingDashboardFrame.CatalogContent, "Dashboard")
    end
    
    -- ===== MODUS-WECHSEL HANDLER =====
    -- Wenn wir vom Dekor-Modus in den Layout-Modus wechseln,
    -- muss der Favoriten-Modus beendet werden damit die Raumauswahl angezeigt wird
    
    -- Event-Frame erstellen für HOUSE_EDITOR_MODE_CHANGED
    local modeChangeFrame = CreateFrame("Frame")
    modeChangeFrame:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    modeChangeFrame:SetScript("OnEvent", function(self, event, newMode)
        if event == "HOUSE_EDITOR_MODE_CHANGED" then
            DreamHouse.Debug:Log("FavCat", "Editor-Modus gewechselt zu: " .. tostring(newMode), "DEBUG")
            
            -- Wenn wir in den Layout-Modus wechseln, Favoriten-Modus beenden
            if newMode == Enum.HouseEditorMode.Layout then
                if isInFavoritesMode then
                    DreamHouse.Debug:Log("FavCat", "Wechsel zu Layout-Modus - beende Favoriten-Modus", "INFO")
                    DreamHouse.FavoritesCategory:SetActive(false)
                    DreamHouse.FavoritesCategory:SetSubcategoryActive(false)
                    DreamHouse.FavoritesCategory:ExitFavoritesMode()
                    
                    -- Categories neu aufbauen lassen damit Raumauswahl angezeigt wird
                    if HouseEditorFrame and HouseEditorFrame.StoragePanel and HouseEditorFrame.StoragePanel.Categories then
                        local categories = HouseEditorFrame.StoragePanel.Categories
                        if categories.ClearFocus then
                            categories:ClearFocus()
                        end
                    end
                end
            end
        end
    end)
    DreamHouse.Debug:Log("FavCat", "HOUSE_EDITOR_MODE_CHANGED Handler registriert", "SUCCESS")
    
    isApplied = true
end

-- Modul registrieren
DreamHouse:RegisterModule("FavoritesCategory", DreamHouse.FavoritesCategory)

