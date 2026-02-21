--[[
    DreamHouse - Tooltip Enhancer
    Erweiterte Tooltips mit zusätzlichen Informationen
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.TooltipEnhancer = {}

-- Tooltip für Katalog-Einträge erweitern
function DreamHouse.TooltipEnhancer:Enhance(catalogEntry)
    if not catalogEntry then return end
    
    -- Entry-Info holen (defensiv - verschiedene Quellen probieren)
    local entryInfo = catalogEntry.entryInfo
    
    -- Fallback: Über API holen wenn entryID vorhanden
    if not entryInfo and catalogEntry.entryID then
        local success, result = pcall(C_HousingCatalog.GetCatalogEntryInfo, catalogEntry.entryID)
        if success then
            entryInfo = result
        end
    end
    
    if not entryInfo then return end
    
    -- Warte kurz bis der Standard-Tooltip da ist
    C_Timer.After(0.01, function()
        if not GameTooltip:IsShown() then return end
        
        -- Separator
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00ccff" .. L["--- DreamHouse Info ---"] .. "|r")
        
        -- Indoor/Outdoor Status
        if entryInfo.isAllowedIndoors ~= nil or entryInfo.isAllowedOutdoors ~= nil then
            local placement = {}
            if entryInfo.isAllowedIndoors then
                table.insert(placement, "|cff88cc88" .. L["Indoor"] .. "|r")
            end
            if entryInfo.isAllowedOutdoors then
                table.insert(placement, "|cff88cc88" .. L["Outdoor"] .. "|r")
            end
            if #placement > 0 then
                GameTooltip:AddLine(L["Placement"] .. ": " .. table.concat(placement, " / "))
            end
        end
        
        -- Größe (Enum.HousingCatalogEntrySize: Tiny=65, Small=66, Medium=67, Large=68, Huge=69)
        if entryInfo.size and entryInfo.size > 0 then
            local sizeNames = {
                [65] = L["Size_Tiny"],
                [66] = L["Size_Small"],
                [67] = L["Size_Medium"],
                [68] = L["Size_Large"],
                [69] = L["Size_Huge"],
            }
            local sizeName = sizeNames[entryInfo.size]
            if sizeName then
                GameTooltip:AddLine(L["Size"] .. ": |cffcccccc" .. sizeName .. "|r")
            end
        end
        
        -- Herkunft (Verkäufer, Zone, Kosten)
        if entryInfo.sourceText and entryInfo.sourceText ~= "" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff88ccff" .. L["Source"] .. ":|r")
            -- sourceText kann mehrere Zeilen haben, formatiere sie schön
            for line in entryInfo.sourceText:gmatch("[^\n]+") do
                local trimmedLine = line:match("^%s*(.-)%s*$")  -- Whitespace trimmen
                if trimmedLine and trimmedLine ~= "" then
                    GameTooltip:AddLine("|cffcccccc" .. trimmedLine .. "|r")
                end
            end
        end
        
        -- Kategorie
        if entryInfo.categoryID then
            local categoryInfo = C_HousingCatalog.GetCatalogCategoryInfo and 
                                C_HousingCatalog.GetCatalogCategoryInfo(entryInfo.categoryID)
            if categoryInfo and categoryInfo.name then
                GameTooltip:AddLine(L["Category"] .. ": |cffcccccc" .. categoryInfo.name .. "|r")
            end
        end
        
        -- Favoriten-Status
        local isFavorite = DreamHouse.Settings:IsFavorite(catalogEntry.entryID or entryInfo.entryID)
        if isFavorite then
            GameTooltip:AddLine("|cffffcc00" .. L["Favorite"] .. "|r")
        end
        
        -- Entry-Typ
        if entryInfo.entryType then
            local typeNames = {
                [Enum.HousingCatalogEntryType.Decor] = L["Type_Decoration"],
                [Enum.HousingCatalogEntryType.Room] = L["Type_Room"],
            }
            local typeName = typeNames[entryInfo.entryType] or L["Unknown"]
            GameTooltip:AddLine(L["Type"] .. ": |cff888888" .. typeName .. "|r")
        end
        
        -- RecordID (für Debug)
        if DreamHouse.Settings:Get("settings", "debugVerbose") then
            if entryInfo.entryID then
                local recordID = entryInfo.entryID.recordID or entryInfo.entryID
                GameTooltip:AddLine("|cff666666ID: " .. tostring(recordID) .. "|r")
            end
        end
        
        -- Tooltip neu anzeigen um Größe anzupassen
        GameTooltip:Show()
    end)
end

-- Tooltip für platzierte Decor-Items
function DreamHouse.TooltipEnhancer:EnhancePlacedDecor(decorGUID)
    if not decorGUID then return end
    
    local decorInfo = C_HousingDecor.GetDecorInstanceInfoForGUID and 
                      C_HousingDecor.GetDecorInstanceInfoForGUID(decorGUID)
    
    if not decorInfo then return end
    
    C_Timer.After(0.01, function()
        if not GameTooltip:IsShown() then return end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00ccff" .. L["--- Placed ---"] .. "|r")
        
        -- Status-Infos
        if decorInfo.isLocked then
            GameTooltip:AddLine("|cffff4444" .. L["Locked"] .. "|r")
        end
        
        if not decorInfo.canBeRemoved then
            GameTooltip:AddLine("|cffff8844" .. L["Cannot be removed"] .. "|r")
        end
        
        if DreamHouse.Settings:Get("settings", "debugVerbose") then
            GameTooltip:AddLine("|cff666666GUID: " .. tostring(decorGUID) .. "|r")
        end
        
        GameTooltip:Show()
    end)
end

-- Initialisierung
function DreamHouse.TooltipEnhancer:Initialize()
    DreamHouse.Debug:Log("TooltipEnhancer", "Tooltip-Erweiterungen initialisiert", "SUCCESS")
end

-- Modul registrieren
DreamHouse:RegisterModule("TooltipEnhancer", DreamHouse.TooltipEnhancer)

