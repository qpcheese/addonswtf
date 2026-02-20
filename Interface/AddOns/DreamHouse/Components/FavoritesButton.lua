--[[
    DreamHouse - Favorites System
    Stern-Button für Katalog-Einträge um Favoriten zu markieren
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.Favorites = {}

-- Pool für Favoriten-Buttons
local buttonPool = {}
local activeButtons = {}

-- Favoriten-Button erstellen
local function CreateFavoriteButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(20, 20)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(parent:GetFrameLevel() + 10)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")
    
    -- Glow-Effekt (hinter dem Stern)
    btn.glowTexture = btn:CreateTexture(nil, "BACKGROUND")
    btn.glowTexture:SetSize(28, 28)
    btn.glowTexture:SetPoint("CENTER", 0, 0)
    btn.glowTexture:SetAtlas("bonusobjectives-glow-star")
    btn.glowTexture:SetAlpha(0)
    btn.glowTexture:SetBlendMode("ADD")
    
    -- Stern-Textur (Blizzard's Bonus-Objective-Star)
    btn.normalTexture = btn:CreateTexture(nil, "ARTWORK")
    btn.normalTexture:SetAllPoints()
    btn.normalTexture:SetAtlas("Bonus-Objective-Star")
    btn.normalTexture:SetDesaturated(true)
    btn.normalTexture:SetAlpha(0.5)
    
    -- Highlight beim Hover
    btn.highlightTexture = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlightTexture:SetAllPoints()
    btn.highlightTexture:SetAtlas("Bonus-Objective-Star")
    btn.highlightTexture:SetAlpha(0.3)
    btn.highlightTexture:SetBlendMode("ADD")
    
    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.isFavorite then
            GameTooltip:SetText(L["Remove from Favorites"])
        else
            GameTooltip:SetText(L["Add to Favorites"])
        end
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Klick-Handler
    btn:SetScript("OnClick", function(self, button)
        -- Hole entryID direkt vom Parent falls nicht gesetzt
        local entryID = self.entryID
        if not entryID then
            local parent = self:GetParent()
            if parent then
                entryID = parent.entryID or (parent.entryInfo and parent.entryInfo.entryID)
                if entryID then
                    self:SetEntryID(entryID)
                end
            end
        end
        
        if entryID then
            local newState = not self.isFavorite
            DreamHouse.Favorites:SetFavorite(entryID, newState)
            self:UpdateVisual(newState)
            
            -- Sound abspielen
            if newState then
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED)
            else
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
            end
            
            DreamHouse.Debug:Log("Favorites", "Favorit " .. (newState and "gesetzt" or "entfernt"), "SUCCESS")
        else
            DreamHouse.Debug:Log("Favorites", "Kein entryID gefunden!", "WARN")
        end
    end)
    
    -- Verhindere dass der Klick an das Parent weitergegeben wird
    btn:SetScript("OnMouseDown", function(self, button)
        DreamHouse.Debug:Log("Favorites", "MouseDown auf Stern", "DEBUG")
    end)
    
    btn:SetScript("OnMouseUp", function(self, button)
        DreamHouse.Debug:Log("Favorites", "MouseUp auf Stern", "DEBUG")
    end)
    
    -- Visual-Update Methode
    function btn:UpdateVisual(isFavorite)
        self.isFavorite = isFavorite
        if isFavorite then
            -- Aktiver Favorit: Goldener Stern mit Glow
            self.normalTexture:SetDesaturated(false)
            self.normalTexture:SetAlpha(1)
            self.normalTexture:SetVertexColor(1, 0.85, 0) -- Warmes Gold
            self.glowTexture:SetAlpha(0.6)
        else
            -- Inaktiv: Grauer, dezenter Stern
            self.normalTexture:SetDesaturated(true)
            self.normalTexture:SetAlpha(0.5)
            self.normalTexture:SetVertexColor(1, 1, 1)
            self.glowTexture:SetAlpha(0)
        end
    end
    
    -- SetEntryID Methode
    function btn:SetEntryID(entryID)
        self.entryID = entryID
        local isFavorite = DreamHouse.Settings:IsFavorite(entryID)
        self:UpdateVisual(isFavorite)
    end
    
    return btn
end

-- Button aus Pool holen oder erstellen
local function AcquireButton(parent)
    local btn = table.remove(buttonPool)
    if not btn then
        btn = CreateFavoriteButton(parent)
    else
        btn:SetParent(parent)
    end
    btn:Show()
    return btn
end

-- Button zurück in Pool geben
local function ReleaseButton(btn)
    btn:Hide()
    btn:ClearAllPoints()
    btn.entryID = nil
    table.insert(buttonPool, btn)
end

-- Favoriten-Button an Katalog-Eintrag anhängen
function DreamHouse.Favorites:AttachToEntry(catalogEntry)
    if not catalogEntry then 
        return 
    end
    
    -- Prüfen ob es ein gültiger Katalog-Eintrag ist
    if not catalogEntry.ModelScene and not catalogEntry.Icon then
        return
    end
    
    -- Prüfen ob bereits ein Button existiert
    if catalogEntry.dreamhouseFavButton then
        -- Nur Entry-ID aktualisieren und sicherstellen, dass er sichtbar ist
        local entryID = catalogEntry.entryID or (catalogEntry.entryInfo and catalogEntry.entryInfo.entryID)
        if entryID then
            catalogEntry.dreamhouseFavButton:SetEntryID(entryID)
        end
        catalogEntry.dreamhouseFavButton:Show()
        return
    end
    
    -- Neuen Button erstellen
    local btn = AcquireButton(catalogEntry)
    btn:SetPoint("TOPRIGHT", catalogEntry, "TOPRIGHT", -4, -4)
    btn:SetFrameLevel(catalogEntry:GetFrameLevel() + 10)
    btn:Raise() -- Nach vorne bringen
    btn:Show() -- Explizit anzeigen!
    
    -- Entry-ID setzen (kann nil sein - wird später aktualisiert)
    local entryID = catalogEntry.entryID or (catalogEntry.entryInfo and catalogEntry.entryInfo.entryID)
    if entryID then
        btn:SetEntryID(entryID)
    end
    
    catalogEntry.dreamhouseFavButton = btn
    activeButtons[catalogEntry] = btn
    
    DreamHouse.Debug:Log("Favorites", "⭐ Favoriten-Button angehängt", "SUCCESS")
end

-- Button von Entry entfernen
function DreamHouse.Favorites:DetachFromEntry(catalogEntry)
    if catalogEntry and catalogEntry.dreamhouseFavButton then
        ReleaseButton(catalogEntry.dreamhouseFavButton)
        activeButtons[catalogEntry] = nil
        catalogEntry.dreamhouseFavButton = nil
    end
end

-- Favorit setzen/entfernen
function DreamHouse.Favorites:SetFavorite(entryID, isFavorite)
    DreamHouse.Settings:SetFavorite(entryID, isFavorite)
    
    -- Alle Buttons für dieses Entry aktualisieren
    for entry, btn in pairs(activeButtons) do
        if btn.entryID == entryID or 
           (type(btn.entryID) == "table" and type(entryID) == "table" and 
            btn.entryID.recordID == entryID.recordID) then
            btn:UpdateVisual(isFavorite)
        end
    end
    
    DreamHouse.Events:Fire("DREAMHOUSE_FAVORITE_CHANGED", entryID, isFavorite)
end

-- Prüfen ob Favorit
function DreamHouse.Favorites:IsFavorite(entryID)
    return DreamHouse.Settings:IsFavorite(entryID)
end

-- Alle Favoriten holen
function DreamHouse.Favorites:GetAll()
    return DreamHouse.Settings:GetAllFavorites()
end

-- Anzahl Favoriten
function DreamHouse.Favorites:GetCount()
    return DreamHouse.Utils:TableCount(self:GetAll())
end

-- Favoriten-Filter für Katalog (gibt gefilterte Entry-Liste zurück)
function DreamHouse.Favorites:FilterCatalogEntries(entries)
    if not entries then return {} end
    
    local filtered = {}
    local favorites = self:GetAll()
    
    for _, entry in ipairs(entries) do
        local entryID = entry.recordID or entry
        if favorites[tostring(entryID)] then
            table.insert(filtered, entry)
        end
    end
    
    return filtered
end

-- Initialisierung
function DreamHouse.Favorites:Initialize()
    DreamHouse.Debug:Log("Favorites", "Favoriten-System initialisiert", "SUCCESS")
    
    -- Keybind für schnelles Favorisieren (wenn über Item)
    -- Dies würde normalerweise über Bindings.xml gemacht werden
end

-- Modul registrieren
DreamHouse:RegisterModule("Favorites", DreamHouse.Favorites)

