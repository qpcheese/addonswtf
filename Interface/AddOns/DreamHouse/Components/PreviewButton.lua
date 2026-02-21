--[[
    DreamHouse - 3D Preview Button
    Lupe-Button für Katalog-Einträge um 3D-Vorschau anzuzeigen
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.PreviewButton = {}

-- Pool für Preview-Buttons
local buttonPool = {}
local activeButtons = {}

-- Preview-Button erstellen
local function CreatePreviewButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(18, 18)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(parent:GetFrameLevel() + 10)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")
    
    -- Lupe-Textur
    btn.normalTexture = btn:CreateTexture(nil, "ARTWORK")
    btn.normalTexture:SetAllPoints()
    btn.normalTexture:SetAtlas("talents-search-exactmatch")
    btn.normalTexture:SetAlpha(0.7)
    
    -- Highlight beim Hover
    btn.highlightTexture = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.highlightTexture:SetAllPoints()
    btn.highlightTexture:SetAtlas("talents-search-exactmatch")
    btn.highlightTexture:SetAlpha(0.4)
    btn.highlightTexture:SetBlendMode("ADD")
    
    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["3D Preview"] or "3D Vorschau")
        GameTooltip:AddLine(L["Click to show 3D model"] or "Klicken für 3D-Modell", 0.7, 0.7, 0.7)
        GameTooltip:Show()
        
        -- Button hervorheben
        self.normalTexture:SetAlpha(1)
    end)
    
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self.normalTexture:SetAlpha(0.7)
    end)
    
    -- Klick-Handler
    btn:SetScript("OnClick", function(self, button)
        local entryID = self.entryID
        local entryInfo = self.entryInfo
        
        if not entryID and not entryInfo then
            local parent = self:GetParent()
            if parent then
                entryID = parent.entryID
                entryInfo = parent.entryInfo
            end
        end
        
        if entryInfo or entryID then
            local recordID, entryType, itemName
            
            if entryInfo then
                recordID = entryInfo.entryID and entryInfo.entryID.recordID or entryInfo.recordID
                entryType = entryInfo.entryID and entryInfo.entryID.entryType or Enum.HousingCatalogEntryType.Decor
                itemName = entryInfo.name
            elseif entryID then
                recordID = entryID.recordID or entryID
                entryType = entryID.entryType or Enum.HousingCatalogEntryType.Decor
            end
            
            if recordID and DreamHouse.Hooks and DreamHouse.Hooks.Storage then
                DreamHouse.Hooks.Storage:Show3DPreview(entryType, recordID, itemName)
                DreamHouse.Debug:Log("Preview", "3D Vorschau geöffnet für: " .. (itemName or tostring(recordID)), "SUCCESS")
            end
        else
            DreamHouse.Debug:Log("Preview", "Keine Entry-Daten gefunden!", "WARN")
        end
    end)
    
    -- Verhindere dass der Klick an das Parent weitergegeben wird
    btn:SetScript("OnMouseDown", function() end)
    btn:SetScript("OnMouseUp", function() end)
    
    -- SetEntryData Methode
    function btn:SetEntryData(entryID, entryInfo)
        self.entryID = entryID
        self.entryInfo = entryInfo
    end
    
    return btn
end

-- Button aus Pool holen oder erstellen
local function AcquireButton(parent)
    local btn = table.remove(buttonPool)
    if not btn then
        btn = CreatePreviewButton(parent)
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
    btn.entryInfo = nil
    table.insert(buttonPool, btn)
end

-- Preview-Button an Katalog-Eintrag anhängen (NUR im Editor, nicht im Dashboard)
function DreamHouse.PreviewButton:AttachToEntry(catalogEntry)
    if not catalogEntry then 
        return 
    end
    
    -- Prüfen ob es ein gültiger Katalog-Eintrag ist
    if not catalogEntry.ModelScene and not catalogEntry.Icon then
        return
    end
    
    -- Nur im Editor anzeigen, NICHT in der Behausungsübersicht (Dashboard)
    if HousingDashboardFrame and HousingDashboardFrame:IsShown() then
        -- Im Dashboard - keinen Button anzeigen
        if catalogEntry.dreamhousePreviewButton then
            catalogEntry.dreamhousePreviewButton:Hide()
        end
        return
    end
    
    -- Prüfen ob bereits ein Button existiert
    if catalogEntry.dreamhousePreviewButton then
        -- Nur Entry-Daten aktualisieren und anzeigen
        catalogEntry.dreamhousePreviewButton:Show()
        local entryID = catalogEntry.entryID
        local entryInfo = catalogEntry.entryInfo
        if entryID or entryInfo then
            catalogEntry.dreamhousePreviewButton:SetEntryData(entryID, entryInfo)
        end
        return
    end
    
    -- Neuen Button erstellen
    local btn = AcquireButton(catalogEntry)
    -- Position: Links oben (neben dem Favoriten-Stern der rechts oben ist)
    btn:SetPoint("TOPLEFT", catalogEntry, "TOPLEFT", 4, -4)
    btn:SetFrameLevel(catalogEntry:GetFrameLevel() + 10)
    btn:Raise()
    btn:Show() -- Explizit anzeigen!
    
    -- Entry-Daten setzen (kann nil sein - wird später aktualisiert)
    local entryID = catalogEntry.entryID
    local entryInfo = catalogEntry.entryInfo
    if entryID or entryInfo then
        btn:SetEntryData(entryID, entryInfo)
    end
    
    catalogEntry.dreamhousePreviewButton = btn
    activeButtons[catalogEntry] = btn
    
    DreamHouse.Debug:Log("Preview", "🔍 Preview-Button angehängt", "SUCCESS")
end

-- Button von Entry entfernen
function DreamHouse.PreviewButton:DetachFromEntry(catalogEntry)
    if catalogEntry and catalogEntry.dreamhousePreviewButton then
        ReleaseButton(catalogEntry.dreamhousePreviewButton)
        activeButtons[catalogEntry] = nil
        catalogEntry.dreamhousePreviewButton = nil
    end
end

-- Initialisierung
function DreamHouse.PreviewButton:Initialize()
    DreamHouse.Debug:Log("Preview", "3D-Vorschau-Button-System initialisiert", "SUCCESS")
end

-- Modul registrieren
DreamHouse:RegisterModule("PreviewButton", DreamHouse.PreviewButton)

