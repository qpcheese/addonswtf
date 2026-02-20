--[[
    DreamHouse - Quality Filter
    Seltenheits-/Qualitäts-Filter für die Behausungsübersicht (Dashboard)
    
    Fügt einen "Seltenheit" Submenu zum bestehenden Filter-Dropdown hinzu
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.QualityFilter = {}

-- Qualitäts-Definitionen (WoW ItemQuality Enum)
local QUALITY_OPTIONS = {
    { id = Enum.ItemQuality.Poor or 0, name = ITEM_QUALITY0_DESC or "Schlecht", color = {0.62, 0.62, 0.62} },      -- Grau
    { id = Enum.ItemQuality.Common or 1, name = ITEM_QUALITY1_DESC or "Gewöhnlich", color = {1, 1, 1} },           -- Weiß
    { id = Enum.ItemQuality.Uncommon or 2, name = ITEM_QUALITY2_DESC or "Ungewöhnlich", color = {0.12, 1, 0} },    -- Grün
    { id = Enum.ItemQuality.Rare or 3, name = ITEM_QUALITY3_DESC or "Selten", color = {0, 0.44, 0.87} },           -- Blau
    { id = Enum.ItemQuality.Epic or 4, name = ITEM_QUALITY4_DESC or "Episch", color = {0.64, 0.21, 0.93} },        -- Lila
    { id = Enum.ItemQuality.Legendary or 5, name = ITEM_QUALITY5_DESC or "Legendär", color = {1, 0.5, 0} },        -- Orange
}

-- Aktive Filter (alle standardmäßig aktiviert)
local activeQualities = {}
for _, opt in ipairs(QUALITY_OPTIONS) do
    activeQualities[opt.id] = true
end

local isHooked = false
local originalUpdateCatalogData = nil

-- Prüft ob eine Quality aktiv ist
local function IsQualityActive(qualityID)
    return activeQualities[qualityID] == true
end

-- Quality togglen
local function ToggleQuality(qualityID)
    activeQualities[qualityID] = not activeQualities[qualityID]
    DreamHouse.Debug:Log("QualityFilter", "Quality " .. qualityID .. " toggled: " .. tostring(activeQualities[qualityID]), "DEBUG")
    
    -- Dashboard aktualisieren
    DreamHouse.QualityFilter:RefreshDashboard()
end

-- Alle Qualities aktivieren
local function CheckAllQualities()
    for _, opt in ipairs(QUALITY_OPTIONS) do
        activeQualities[opt.id] = true
    end
    DreamHouse.Debug:Log("QualityFilter", "Alle Qualities aktiviert", "DEBUG")
    DreamHouse.QualityFilter:RefreshDashboard()
    return MenuResponse.Refresh
end

-- Alle Qualities deaktivieren
local function UncheckAllQualities()
    for _, opt in ipairs(QUALITY_OPTIONS) do
        activeQualities[opt.id] = false
    end
    DreamHouse.Debug:Log("QualityFilter", "Alle Qualities deaktiviert", "DEBUG")
    DreamHouse.QualityFilter:RefreshDashboard()
    return MenuResponse.Refresh
end

-- Prüft ob ein Entry die Quality-Anforderung erfüllt
local function EntryPassesQualityFilter(entryID)
    -- Prüfe ob alle Qualities aktiv sind (= kein Filter)
    local allActive = true
    for _, opt in ipairs(QUALITY_OPTIONS) do
        if not activeQualities[opt.id] then
            allActive = false
            break
        end
    end
    
    if allActive then
        return true  -- Kein Filter aktiv
    end
    
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryID)
    if not entryInfo then
        return true  -- Wenn keine Info, durchlassen
    end
    
    local itemQuality = entryInfo.quality or Enum.ItemQuality.Common
    return activeQualities[itemQuality] == true
end

-- Dashboard aktualisieren
function DreamHouse.QualityFilter:RefreshDashboard()
    local dashboard = HousingDashboardFrame
    if dashboard and dashboard.CatalogContent and dashboard.CatalogContent:IsShown() then
        local catalogFrame = dashboard.CatalogContent
        if catalogFrame.catalogSearcher then
            catalogFrame.catalogSearcher:RunSearch()
        end
    end
end

-- Ergebnisse nach Quality filtern
function DreamHouse.QualityFilter:FilterResults(entries)
    if not entries then
        return entries
    end
    
    -- Prüfe ob alle Qualities aktiv sind
    local allActive = true
    for _, opt in ipairs(QUALITY_OPTIONS) do
        if not activeQualities[opt.id] then
            allActive = false
            break
        end
    end
    
    if allActive then
        return entries  -- Kein Filter nötig
    end
    
    local filtered = {}
    local originalCount = #entries
    
    for _, entryID in ipairs(entries) do
        if EntryPassesQualityFilter(entryID) then
            table.insert(filtered, entryID)
        end
    end
    
    DreamHouse.Debug:Log("QualityFilter", string.format("Gefiltert: %d/%d Items", #filtered, originalCount), "DEBUG")
    
    return filtered
end

-- Filter-Menü erweitern
function DreamHouse.QualityFilter:ExtendFilterMenu(filtersFrame)
    if not filtersFrame or not filtersFrame.FilterDropdown then
        DreamHouse.Debug:Log("QualityFilter", "FilterDropdown nicht gefunden", "WARN")
        return
    end
    
    local dropdown = filtersFrame.FilterDropdown
    
    -- Hook auf die interne Menu-Generierung
    -- WoW's DropdownButton ruft intern eine Funktion auf die das Menu aufbaut
    -- Wir hooken uns da rein um am Ende unseren Filter hinzuzufügen
    
    -- Methode: Überschreibe die menuGenerator Funktion im Dropdown
    if dropdown.menuGenerator then
        local originalGenerator = dropdown.menuGenerator
        
        dropdown.menuGenerator = function(dropdown, rootDescription)
            -- Original Menu erstellen
            originalGenerator(dropdown, rootDescription)
            
            -- ========== DREAMHOUSE QUALITY FILTER ==========
            rootDescription:CreateDivider()
            
                local qualitySubmenu = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["Rarity"])
                qualitySubmenu:SetGridMode(MenuConstants.VerticalGridDirection)
                
                qualitySubmenu:CreateButton(CHECK_ALL or L["Select All"], CheckAllQualities)
                qualitySubmenu:CreateButton(UNCHECK_ALL or L["Select None"], UncheckAllQualities)
            
            for _, option in ipairs(QUALITY_OPTIONS) do
                local color = option.color
                local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                    math.floor(color[1] * 255), 
                    math.floor(color[2] * 255), 
                    math.floor(color[3] * 255), 
                    option.name)
                
                local qualityID = option.id
                qualitySubmenu:CreateCheckbox(coloredName, 
                    function() return IsQualityActive(qualityID) end,
                    function() ToggleQuality(qualityID) end
                )
            end
        end
        
        DreamHouse.Debug:Log("QualityFilter", "menuGenerator überschrieben", "SUCCESS")
    else
        DreamHouse.Debug:Log("QualityFilter", "menuGenerator nicht gefunden - versuche alternativen Hook", "WARN")
        
        -- Alternative: Hook auf SetupMenu für zukünftige Aufrufe UND manuelles Re-Setup
        local originalSetupMenu = dropdown.SetupMenu
        
        dropdown.SetupMenu = function(self, menuGenerator)
            local extendedGenerator = function(dd, rootDescription)
                menuGenerator(dd, rootDescription)
                
                -- ========== DREAMHOUSE QUALITY FILTER ==========
                rootDescription:CreateDivider()
                
                local qualitySubmenu = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["Rarity"])
                qualitySubmenu:SetGridMode(MenuConstants.VerticalGridDirection)
                
                qualitySubmenu:CreateButton(CHECK_ALL or L["Select All"], CheckAllQualities)
                qualitySubmenu:CreateButton(UNCHECK_ALL or L["Select None"], UncheckAllQualities)
                
                for _, option in ipairs(QUALITY_OPTIONS) do
                    local color = option.color
                    local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                        math.floor(color[1] * 255), 
                        math.floor(color[2] * 255), 
                        math.floor(color[3] * 255), 
                        option.name)
                    
                    local qualityID = option.id
                    qualitySubmenu:CreateCheckbox(coloredName, 
                        function() return IsQualityActive(qualityID) end,
                        function() ToggleQuality(qualityID) end
                    )
                end
            end
            
            originalSetupMenu(self, extendedGenerator)
        end
        
        -- Force Re-Initialization des Filters-Frame damit unser Hook greift
        -- Wir müssen das Original-Menu nochmal aufbauen lassen
        if filtersFrame.catalogSearcher and filtersFrame.Initialize then
            DreamHouse.Debug:Log("QualityFilter", "Versuche Filter neu zu initialisieren...", "DEBUG")
            -- Re-Initialize um das Menu neu aufzubauen
            filtersFrame:Initialize(filtersFrame.catalogSearcher)
        end
    end
    
    DreamHouse.Debug:Log("QualityFilter", "Filter-Menu erweitert", "SUCCESS")
end

-- Dashboard hooken
function DreamHouse.QualityFilter:HookDashboard()
    if isHooked then 
        DreamHouse.Debug:Log("QualityFilter", "Bereits gehookt - überspringe", "DEBUG")
        return 
    end
    
    -- Warte auf HousingDashboardFrame
    if not HousingDashboardFrame then
        DreamHouse.Debug:Log("QualityFilter", "HousingDashboardFrame noch nicht verfügbar", "DEBUG")
        return
    end
    
    local dashboard = HousingDashboardFrame
    
    -- Warte auf CatalogContent (nicht CatalogPanel!)
    if not dashboard.CatalogContent then
        DreamHouse.Debug:Log("QualityFilter", "CatalogContent noch nicht verfügbar", "DEBUG")
        return
    end
    
    local catalogFrame = dashboard.CatalogContent
    
    -- Warte auf Filters (wird erst bei OneTimeInit erstellt)
    if not catalogFrame.Filters then
        DreamHouse.Debug:Log("QualityFilter", "Filters noch nicht verfügbar - versuche später...", "DEBUG")
        -- Retry nach kurzer Verzögerung
        C_Timer.After(0.5, function()
            if not isHooked then
                DreamHouse.QualityFilter:HookDashboard()
            end
        end)
        return
    end
    
    -- Warte auf catalogSearcher
    if not catalogFrame.catalogSearcher then
        DreamHouse.Debug:Log("QualityFilter", "catalogSearcher noch nicht verfügbar - versuche später...", "DEBUG")
        -- Retry nach kurzer Verzögerung
        C_Timer.After(0.5, function()
            if not isHooked then
                DreamHouse.QualityFilter:HookDashboard()
            end
        end)
        return
    end
    
    -- WICHTIG: Flag SOFORT setzen um Mehrfach-Hooks zu verhindern
    isHooked = true
    
    DreamHouse.Debug:Log("QualityFilter", "Alle Komponenten verfügbar - erweitere Filter-Menu", "SUCCESS")
    
    -- Filter-Menu erweitern
    self:ExtendFilterMenu(catalogFrame.Filters)
    
    -- Hook UpdateCatalogData um unsere Filter anzuwenden
    if catalogFrame.UpdateCatalogData and not originalUpdateCatalogData then
        originalUpdateCatalogData = catalogFrame.UpdateCatalogData
        
        catalogFrame.UpdateCatalogData = function(self)
            if not self:IsShown() then
                return
            end
            
            local entries = self.catalogSearcher:GetCatalogSearchResults()
            
            -- DreamHouse Quality Filter anwenden
            entries = DreamHouse.QualityFilter:FilterResults(entries)
            
            -- Preview aktualisieren
            if not self.PreviewFrame:IsShown() and entries and #entries > 0 then
                local firstEntry = entries[1]
                local firstEntryInfo = C_HousingCatalog.GetCatalogEntryInfo(firstEntry)
                self.PreviewFrame:PreviewCatalogEntryInfo(firstEntryInfo)
                self.PreviewFrame:Show()
            end
            
            local retainCurrentPosition = true
            self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition)
        end
        
        DreamHouse.Debug:Log("QualityFilter", "UpdateCatalogData gehookt", "SUCCESS")
    end
    
    DreamHouse.Debug:Log("QualityFilter", "Dashboard komplett gehookt", "SUCCESS")
end

-- Initialisierung
function DreamHouse.QualityFilter:Initialize()
    -- Hook wenn Dashboard geöffnet wird
    local function TryHookDashboard()
        if HousingDashboardFrame and HousingDashboardFrame.CatalogContent then
            -- Verzögert hooken damit alles geladen ist
            C_Timer.After(0.3, function()
                DreamHouse.QualityFilter:HookDashboard()
            end)
        end
    end
    
    -- Event wenn Housing-Frames geladen werden
    local hookFrame = CreateFrame("Frame")
    hookFrame:RegisterEvent("ADDON_LOADED")
    hookFrame:SetScript("OnEvent", function(self, event, loadedAddon)
        if loadedAddon == "Blizzard_HousingDashboard" then
            DreamHouse.Debug:Log("QualityFilter", "Blizzard_HousingDashboard geladen!", "INFO")
            C_Timer.After(0.5, TryHookDashboard)
        end
    end)
    
    -- Falls Dashboard bereits geladen ist (nach /reload)
    if HousingDashboardFrame then
        DreamHouse.Debug:Log("QualityFilter", "Dashboard bereits geladen", "INFO")
        
        -- OnShow Hook für CatalogContent (wird getriggert wenn Katalog-Tab gewählt wird)
        if HousingDashboardFrame.CatalogContent then
            DreamHouse.Debug:Log("QualityFilter", "CatalogContent gefunden!", "SUCCESS")
            hooksecurefunc(HousingDashboardFrame.CatalogContent, "OnShow", function()
                DreamHouse.Debug:Log("QualityFilter", "CatalogContent OnShow!", "DEBUG")
                C_Timer.After(0.3, TryHookDashboard)
            end)
        end
        
        -- Hook auf das gesamte Dashboard OnShow
        hooksecurefunc(HousingDashboardFrame, "OnShow", function()
            DreamHouse.Debug:Log("QualityFilter", "Dashboard OnShow!", "DEBUG")
            C_Timer.After(0.5, TryHookDashboard)
        end)
        
        -- Hook auf Tab-Wechsel (SetTab wird aufgerufen wenn ein Tab gewählt wird)
        hooksecurefunc(HousingDashboardFrame, "SetTab", function(self, activeTab)
            if activeTab == self.catalogTab then
                DreamHouse.Debug:Log("QualityFilter", "Katalog-Tab aktiviert!", "DEBUG")
                C_Timer.After(0.3, TryHookDashboard)
            end
        end)
        
        -- Falls bereits sichtbar
        if HousingDashboardFrame:IsShown() then
            TryHookDashboard()
        end
    end
    
    -- Storage Hook initialisieren
    self:InitializeStorageHook()
    
    DreamHouse.Debug:Log("QualityFilter", "QualityFilter initialisiert (Dashboard + Storage)", "SUCCESS")
end

-- Filter zurücksetzen
function DreamHouse.QualityFilter:Reset()
    for _, opt in ipairs(QUALITY_OPTIONS) do
        activeQualities[opt.id] = true
    end
    self:RefreshDashboard()
    self:RefreshStorage()
end

-- ============================================
-- STORAGE (EDITOR) SUPPORT
-- ============================================

local isStorageHooked = false

-- Storage aktualisieren
function DreamHouse.QualityFilter:RefreshStorage()
    local storageFrame = HouseEditorFrame and HouseEditorFrame.StoragePanel
    if storageFrame and storageFrame:IsShown() and storageFrame.catalogSearcher then
        storageFrame.catalogSearcher:RunSearch()
    end
end

-- Quality Toggle mit Storage-Refresh
local function ToggleQualityWithRefresh(qualityID)
    activeQualities[qualityID] = not activeQualities[qualityID]
    DreamHouse.Debug:Log("QualityFilter", "Quality " .. qualityID .. " toggled: " .. tostring(activeQualities[qualityID]), "DEBUG")
    
    -- Beide aktualisieren
    DreamHouse.QualityFilter:RefreshDashboard()
    DreamHouse.QualityFilter:RefreshStorage()
end

-- Alle Qualities aktivieren (mit Storage)
local function CheckAllQualitiesWithRefresh()
    for _, opt in ipairs(QUALITY_OPTIONS) do
        activeQualities[opt.id] = true
    end
    DreamHouse.Debug:Log("QualityFilter", "Alle Qualities aktiviert", "DEBUG")
    DreamHouse.QualityFilter:RefreshDashboard()
    DreamHouse.QualityFilter:RefreshStorage()
    return MenuResponse.Refresh
end

-- Alle Qualities deaktivieren (mit Storage)
local function UncheckAllQualitiesWithRefresh()
    for _, opt in ipairs(QUALITY_OPTIONS) do
        activeQualities[opt.id] = false
    end
    DreamHouse.Debug:Log("QualityFilter", "Alle Qualities deaktiviert", "DEBUG")
    DreamHouse.QualityFilter:RefreshDashboard()
    DreamHouse.QualityFilter:RefreshStorage()
    return MenuResponse.Refresh
end

-- Filter-Menü im Storage erweitern
function DreamHouse.QualityFilter:ExtendStorageFilterMenu(filtersFrame)
    if not filtersFrame or not filtersFrame.FilterDropdown then
        DreamHouse.Debug:Log("QualityFilter", "Storage FilterDropdown nicht gefunden", "WARN")
        return false
    end
    
    local dropdown = filtersFrame.FilterDropdown
    
    -- Hook auf die interne Menu-Generierung
    if dropdown.menuGenerator then
        local originalGenerator = dropdown.menuGenerator
        
        dropdown.menuGenerator = function(dropdown, rootDescription)
            -- Original Menu erstellen
            originalGenerator(dropdown, rootDescription)
            
            -- ========== DREAMHOUSE QUALITY FILTER ==========
            rootDescription:CreateDivider()
            
            local qualitySubmenu = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["Rarity"])
            qualitySubmenu:SetGridMode(MenuConstants.VerticalGridDirection)
            
            qualitySubmenu:CreateButton(CHECK_ALL or L["Select All"], CheckAllQualitiesWithRefresh)
            qualitySubmenu:CreateButton(UNCHECK_ALL or L["Select None"], UncheckAllQualitiesWithRefresh)
            
            for _, option in ipairs(QUALITY_OPTIONS) do
                local color = option.color
                local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                    math.floor(color[1] * 255), 
                    math.floor(color[2] * 255), 
                    math.floor(color[3] * 255), 
                    option.name)
                
                local qualityID = option.id
                qualitySubmenu:CreateCheckbox(coloredName, 
                    function() return IsQualityActive(qualityID) end,
                    function() ToggleQualityWithRefresh(qualityID) end
                )
            end
        end
        
        DreamHouse.Debug:Log("QualityFilter", "Storage menuGenerator überschrieben", "SUCCESS")
        return true
    else
        DreamHouse.Debug:Log("QualityFilter", "Storage menuGenerator nicht gefunden - versuche SetupMenu", "WARN")
        
        -- Alternative: Hook auf SetupMenu
        local originalSetupMenu = dropdown.SetupMenu
        if originalSetupMenu then
            dropdown.SetupMenu = function(self, menuGenerator)
                local extendedGenerator = function(dd, rootDescription)
                    menuGenerator(dd, rootDescription)
                    
                    -- ========== DREAMHOUSE QUALITY FILTER ==========
                    rootDescription:CreateDivider()
                    
                    local qualitySubmenu = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["Rarity"])
                    qualitySubmenu:SetGridMode(MenuConstants.VerticalGridDirection)
                    
                    qualitySubmenu:CreateButton(CHECK_ALL or L["Select All"], CheckAllQualitiesWithRefresh)
                    qualitySubmenu:CreateButton(UNCHECK_ALL or L["Select None"], UncheckAllQualitiesWithRefresh)
                    
                    for _, option in ipairs(QUALITY_OPTIONS) do
                        local color = option.color
                        local coloredName = string.format("|cff%02x%02x%02x%s|r", 
                            math.floor(color[1] * 255), 
                            math.floor(color[2] * 255), 
                            math.floor(color[3] * 255), 
                            option.name)
                        
                        local qualityID = option.id
                        qualitySubmenu:CreateCheckbox(coloredName, 
                            function() return IsQualityActive(qualityID) end,
                            function() ToggleQualityWithRefresh(qualityID) end
                        )
                    end
                end
                
                originalSetupMenu(self, extendedGenerator)
            end
            
            DreamHouse.Debug:Log("QualityFilter", "Storage SetupMenu gehookt", "SUCCESS")
            return true
        end
    end
    
    return false
end

-- Storage hooken
function DreamHouse.QualityFilter:HookStorage()
    if isStorageHooked then 
        return 
    end
    
    local storageFrame = HouseEditorFrame and HouseEditorFrame.StoragePanel
    if not storageFrame then
        DreamHouse.Debug:Log("QualityFilter", "StoragePanel noch nicht verfügbar", "DEBUG")
        return
    end
    
    if not storageFrame.Filters then
        DreamHouse.Debug:Log("QualityFilter", "Storage Filters noch nicht verfügbar", "DEBUG")
        return
    end
    
    if not storageFrame.catalogSearcher then
        DreamHouse.Debug:Log("QualityFilter", "Storage catalogSearcher noch nicht verfügbar", "DEBUG")
        return
    end
    
    -- Filter-Menu erweitern
    local success = self:ExtendStorageFilterMenu(storageFrame.Filters)
    if not success then
        DreamHouse.Debug:Log("QualityFilter", "Konnte Storage Filter nicht erweitern", "WARN")
        return
    end
    
    -- Hook UpdateCatalogData um unsere Filter anzuwenden
    if storageFrame.UpdateCatalogData then
        local originalUpdateCatalogData = storageFrame.UpdateCatalogData
        
        storageFrame.UpdateCatalogData = function(self)
            if not self:IsShown() then
                return
            end
            
            local entries = self.catalogSearcher:GetCatalogSearchResults()
            
            -- DreamHouse Quality Filter anwenden
            entries = DreamHouse.QualityFilter:FilterResults(entries)
            
            -- Preview aktualisieren falls vorhanden
            if self.PreviewFrame and not self.PreviewFrame:IsShown() and entries and #entries > 0 then
                local firstEntry = entries[1]
                local firstEntryInfo = C_HousingCatalog.GetCatalogEntryInfo(firstEntry)
                if firstEntryInfo then
                    self.PreviewFrame:PreviewCatalogEntryInfo(firstEntryInfo)
                    self.PreviewFrame:Show()
                end
            end
            
            local retainCurrentPosition = true
            if self.OptionsContainer and self.OptionsContainer.SetCatalogData then
                self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition)
            end
        end
        
        DreamHouse.Debug:Log("QualityFilter", "Storage UpdateCatalogData gehookt", "SUCCESS")
    end
    
    isStorageHooked = true
    DreamHouse.Debug:Log("QualityFilter", "Storage komplett gehookt", "SUCCESS")
end

-- Storage Hook bei Editor-Öffnung
function DreamHouse.QualityFilter:InitializeStorageHook()
    -- Event registrieren
    DreamHouse.Events:Register("DREAMHOUSE_STORAGE_OPENED", function()
        C_Timer.After(0.3, function()
            DreamHouse.QualityFilter:HookStorage()
        end)
    end, self)
    
    -- Falls Storage bereits offen ist
    if HouseEditorFrame and HouseEditorFrame.StoragePanel and HouseEditorFrame.StoragePanel:IsShown() then
        C_Timer.After(0.3, function()
            DreamHouse.QualityFilter:HookStorage()
        end)
    end
    
    DreamHouse.Debug:Log("QualityFilter", "Storage Hook initialisiert", "SUCCESS")
end

-- Modul registrieren
DreamHouse:RegisterModule("QualityFilter", DreamHouse.QualityFilter)
