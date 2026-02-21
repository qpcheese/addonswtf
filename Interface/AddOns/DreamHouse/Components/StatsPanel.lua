--[[
    DreamHouse - Stats Panel
    Statistik-Übersicht für platzierte Items und Kapazitäten
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.StatsPanel = {}

local statsFrame = nil
local isCollapsed = false

-- Stats-Panel erstellen
function DreamHouse.StatsPanel:Create()
    if statsFrame then return statsFrame end
    
    -- Haupt-Frame
    statsFrame = CreateFrame("Frame", "DreamHouseStatsPanel", UIParent, "BackdropTemplate")
    statsFrame:SetSize(280, 280) -- Größer für alle Inhalte!
    statsFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -100)
    statsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    statsFrame:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    statsFrame:SetBackdropBorderColor(0.3, 0.5, 0.7, 1)
    statsFrame:SetMovable(true)
    statsFrame:EnableMouse(true)
    statsFrame:SetClampedToScreen(true)
    statsFrame:RegisterForDrag("LeftButton")
    statsFrame:SetScript("OnDragStart", statsFrame.StartMoving)
    statsFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        DreamHouse.Settings:SaveWindowPosition("statsPanel", point, nil, relativePoint, x, y)
    end)
    
    -- Titel-Bar
    local titleBar = CreateFrame("Frame", nil, statsFrame)
    titleBar:SetHeight(24)
    titleBar:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", statsFrame, "TOPRIGHT", -4, -4)
    
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    title:SetText("|cff00ccff" .. L["Housing Statistics"] .. "|r")
    
    -- Schließen-Button
    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() statsFrame:Hide() end)
    
    -- Refresh-Button
    local refreshBtn = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    refreshBtn:SetSize(20, 20)
    refreshBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    refreshBtn:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
    refreshBtn:SetScript("OnClick", function()
        DreamHouse.StatsPanel:Refresh()
        PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
    end)
    refreshBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Refresh"])
        GameTooltip:Show()
    end)
    refreshBtn:SetScript("OnLeave", GameTooltip_Hide)
    
    -- Content-Container
    local content = CreateFrame("Frame", nil, statsFrame)
    content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 5, -10)
    content:SetPoint("BOTTOMRIGHT", statsFrame, "BOTTOMRIGHT", -10, 10)
    statsFrame.content = content
    
    -- Budget-Sektion
    self:CreateBudgetSection(content)
    
    -- Storage-Sektion
    self:CreateStorageSection(content)
    
    -- Kategorien-Sektion
    self:CreateCategoriesSection(content)
    
    -- Gespeicherte Position laden
    local pos = DreamHouse.Settings:GetWindowPosition("statsPanel")
    if pos then
        statsFrame:ClearAllPoints()
        statsFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    end
    
    statsFrame:Hide()
    
    DreamHouse.Debug:Log("StatsPanel", "Panel erstellt", "SUCCESS")
    
    return statsFrame
end

-- Budget-Sektion (platzierte Items)
function DreamHouse.StatsPanel:CreateBudgetSection(parent)
    local section = CreateFrame("Frame", nil, parent)
    section:SetHeight(50)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    section:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    
    local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    label:SetText(L["Placed Decorations"])
    label:SetTextColor(0.8, 0.8, 0.5)
    
    -- Progress-Bar
    local barBg = CreateFrame("Frame", nil, section, "BackdropTemplate")
    barBg:SetHeight(16)
    barBg:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    barBg:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, -15)
    barBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    barBg:SetBackdropColor(0.1, 0.1, 0.1, 1)
    barBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local bar = barBg:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", barBg, "TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMLEFT", barBg, "BOTTOMLEFT", 2, 2)
    bar:SetWidth(1)
    bar:SetColorTexture(0.2, 0.6, 0.8, 1)
    section.budgetBar = bar
    section.budgetBarBg = barBg
    
    local text = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", barBg, "CENTER", 0, 0)
    section.budgetText = text
    
    statsFrame.budgetSection = section
end

-- Storage-Sektion
function DreamHouse.StatsPanel:CreateStorageSection(parent)
    local section = CreateFrame("Frame", nil, parent)
    section:SetHeight(50)
    section:SetPoint("TOPLEFT", statsFrame.budgetSection, "BOTTOMLEFT", 0, -15)
    section:SetPoint("TOPRIGHT", statsFrame.budgetSection, "BOTTOMRIGHT", 0, -15)
    
    local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    label:SetText(L["Storage Capacity"])
    label:SetTextColor(0.8, 0.8, 0.5)
    
    -- Progress-Bar
    local barBg = CreateFrame("Frame", nil, section, "BackdropTemplate")
    barBg:SetHeight(16)
    barBg:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    barBg:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, -15)
    barBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    barBg:SetBackdropColor(0.1, 0.1, 0.1, 1)
    barBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local bar = barBg:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", barBg, "TOPLEFT", 2, -2)
    bar:SetPoint("BOTTOMLEFT", barBg, "BOTTOMLEFT", 2, 2)
    bar:SetWidth(1)
    bar:SetColorTexture(0.6, 0.4, 0.8, 1)
    section.storageBar = bar
    section.storageBarBg = barBg
    
    local text = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", barBg, "CENTER", 0, 0)
    section.storageText = text
    
    statsFrame.storageSection = section
end

-- Kategorien-Übersicht
function DreamHouse.StatsPanel:CreateCategoriesSection(parent)
    local section = CreateFrame("Frame", nil, parent)
    section:SetPoint("TOPLEFT", statsFrame.storageSection, "BOTTOMLEFT", 0, -15)
    section:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    
    local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    label:SetText(L["Quick Info"])
    label:SetTextColor(0.8, 0.8, 0.5)
    
    -- Info-Zeilen
    local infoLines = {}
    local yOffset = -20
    
    for i = 1, 5 do
        local line = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        line:SetPoint("TOPLEFT", section, "TOPLEFT", 0, yOffset)
        line:SetJustifyH("LEFT")
        infoLines[i] = line
        yOffset = yOffset - 14
    end
    
    section.infoLines = infoLines
    statsFrame.categoriesSection = section
end

-- Stats aktualisieren
function DreamHouse.StatsPanel:Refresh()
    if not statsFrame then return end
    
    -- Budget (platzierte Items)
    local spent, max = DreamHouse.Utils:GetDecorBudget()
    local budgetPercent = DreamHouse.Utils:CalcPercent(spent, max)
    
    if statsFrame.budgetSection then
        local barWidth = math.max(1, (statsFrame.budgetSection.budgetBarBg:GetWidth() - 4) * (budgetPercent / 100))
        statsFrame.budgetSection.budgetBar:SetWidth(barWidth)
        statsFrame.budgetSection.budgetText:SetText(string.format("%d / %d (%d%%)", spent, max, budgetPercent))
        
        -- Farbe basierend auf Füllstand
        if budgetPercent >= 90 then
            statsFrame.budgetSection.budgetBar:SetColorTexture(0.8, 0.2, 0.2, 1)
        elseif budgetPercent >= 70 then
            statsFrame.budgetSection.budgetBar:SetColorTexture(0.8, 0.6, 0.2, 1)
        else
            statsFrame.budgetSection.budgetBar:SetColorTexture(0.2, 0.6, 0.8, 1)
        end
    end
    
    -- Storage
    local owned, maxOwned, exempt = DreamHouse.Utils:GetStorageCapacity()
    local storagePercent = DreamHouse.Utils:CalcPercent(owned, maxOwned)
    
    if statsFrame.storageSection then
        local barWidth = math.max(1, (statsFrame.storageSection.storageBarBg:GetWidth() - 4) * (storagePercent / 100))
        statsFrame.storageSection.storageBar:SetWidth(barWidth)
        statsFrame.storageSection.storageText:SetText(string.format("%d / %d (%d%%)", owned, maxOwned, storagePercent))
        
        if storagePercent >= 90 then
            statsFrame.storageSection.storageBar:SetColorTexture(0.8, 0.2, 0.2, 1)
        elseif storagePercent >= 70 then
            statsFrame.storageSection.storageBar:SetColorTexture(0.8, 0.6, 0.2, 1)
        else
            statsFrame.storageSection.storageBar:SetColorTexture(0.6, 0.4, 0.8, 1)
        end
    end
    
    -- Schnellinfo
    if statsFrame.categoriesSection and statsFrame.categoriesSection.infoLines then
        local lines = statsFrame.categoriesSection.infoLines
        
        -- Favoriten-Anzahl
        local favCount = DreamHouse.Favorites and DreamHouse.Favorites:GetCount() or 0
        lines[1]:SetText("|cffffcc00" .. L["Favorites"] .. ":|r " .. favCount)
        
        -- Hotbar-Belegung
        local hotbarUsed = 0
        for i = 1, 10 do
            if DreamHouse.Settings:GetHotbarSlot(i) then
                hotbarUsed = hotbarUsed + 1
            end
        end
        lines[2]:SetText("|cff88ccff" .. L["Hotbar"] .. ":|r " .. L.Format("Hotbar X/10 used", hotbarUsed))
        
        -- Editor-Status
        if DreamHouse.Utils:IsEditorActive() then
            local mode = DreamHouse.Utils:GetCurrentEditorMode()
            local modeName = DreamHouse.Utils:GetEditorModeName(mode)
            lines[3]:SetText("|cff88ff88" .. L["Editor"] .. ":|r " .. modeName)
        else
            lines[3]:SetText("|cff888888" .. L["Editor"] .. ":|r " .. L["Inactive"])
        end
        
        -- Housing-Status
        if DreamHouse.Utils:IsHousingActive() then
            lines[4]:SetText("|cff88ff88" .. L["Status"] .. ":|r " .. L["In Housing Area"])
        else
            lines[4]:SetText("|cff888888" .. L["Status"] .. ":|r " .. L["Outside"])
        end
        
        -- Platzierte Items (aus API)
        local placedCount = DreamHouse.Utils:GetNumPlacedDecor()
        local maxPlaced = DreamHouse.Utils:GetMaxDecorPlaced()
        if maxPlaced > 0 then
            lines[5]:SetText("|cffcccccc" .. L["Placed"] .. ":|r " .. placedCount .. " / " .. maxPlaced)
        else
            lines[5]:SetText("|cffcccccc" .. L["Placed"] .. ":|r " .. placedCount)
        end
    end
    
    DreamHouse.Debug:Log("StatsPanel", "Stats aktualisiert", "DEBUG")
end

-- Event-Handler
function DreamHouse.StatsPanel:OnDecorPlaced()
    if statsFrame and statsFrame:IsShown() then
        self:Refresh()
    end
end

function DreamHouse.StatsPanel:OnDecorRemoved()
    if statsFrame and statsFrame:IsShown() then
        self:Refresh()
    end
end

-- Anzeigen/Verstecken
function DreamHouse.StatsPanel:Show()
    if not statsFrame then
        self:Create()
    end
    self:Refresh()
    statsFrame:Show()
end

function DreamHouse.StatsPanel:Hide()
    if statsFrame then
        statsFrame:Hide()
    end
end

function DreamHouse.StatsPanel:Toggle()
    if statsFrame and statsFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Initialisierung
function DreamHouse.StatsPanel:Initialize()
    self:Create()
    
    -- Auto-Refresh bei Housing-Events
    DreamHouse.Events:Register("DREAMHOUSE_STORAGE_UPDATED", function()
        if statsFrame and statsFrame:IsShown() then
            self:Refresh()
        end
    end, self)
    
    DreamHouse.Debug:Log("StatsPanel", "Stats-Panel initialisiert", "SUCCESS")
end

-- Modul registrieren
DreamHouse:RegisterModule("StatsPanel", DreamHouse.StatsPanel)

