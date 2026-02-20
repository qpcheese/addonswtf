--[[
    DreamHouse - Utility Helpers
    Allgemeine Hilfsfunktionen für das Addon
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.Utils = {}

-- Sichere Frame-Referenz holen
function DreamHouse.Utils:GetFrame(frameName)
    local frame = _G[frameName]
    if not frame then
        DreamHouse.Debug:Log("Utils", "Frame nicht gefunden: " .. frameName, "WARN")
    end
    return frame
end

-- Warte bis ein Frame existiert
function DreamHouse.Utils:WaitForFrame(frameName, callback, maxAttempts)
    maxAttempts = maxAttempts or 50
    local attempts = 0
    
    local function CheckFrame()
        attempts = attempts + 1
        local frame = _G[frameName]
        
        if frame then
            DreamHouse.Debug:Log("Utils", "Frame gefunden: " .. frameName, "DEBUG")
            callback(frame)
            return
        end
        
        if attempts < maxAttempts then
            C_Timer.After(0.1, CheckFrame)
        else
            DreamHouse.Debug:Log("Utils", "Frame nicht gefunden nach " .. maxAttempts .. " Versuchen: " .. frameName, "ERROR")
        end
    end
    
    CheckFrame()
end

-- Sichere Hook-Funktion
function DreamHouse.Utils:SafeHook(object, method, hookFunc)
    if not object then
        DreamHouse.Debug:Log("Utils", "SafeHook: Object ist nil", "ERROR")
        return false
    end
    
    if type(object) == "string" then
        -- Globale Funktion hooken
        if _G[object] then
            hooksecurefunc(object, hookFunc)
            DreamHouse.Debug:Log("Utils", "Globale Funktion gehookt: " .. object, "DEBUG")
            return true
        end
    elseif type(object) == "table" then
        if method and object[method] then
            hooksecurefunc(object, method, hookFunc)
            DreamHouse.Debug:Log("Utils", "Methode gehookt: " .. (method or "unknown"), "DEBUG")
            return true
        end
    end
    
    DreamHouse.Debug:Log("Utils", "Hook fehlgeschlagen", "ERROR")
    return false
end

-- Frame-Script sicher hooken
function DreamHouse.Utils:SafeHookScript(frame, scriptType, hookFunc)
    if not frame or not frame.HookScript then
        DreamHouse.Debug:Log("Utils", "SafeHookScript: Frame ungültig", "ERROR")
        return false
    end
    
    frame:HookScript(scriptType, hookFunc)
    DreamHouse.Debug:Log("Utils", "Script gehookt: " .. scriptType, "DEBUG")
    return true
end

-- Farbe aus Hex-String
function DreamHouse.Utils:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1,2), 16) / 255,
           tonumber(hex:sub(3,4), 16) / 255,
           tonumber(hex:sub(5,6), 16) / 255
end

-- RGB zu Hex
function DreamHouse.Utils:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Formatierte Zahl (1000 -> 1.000)
function DreamHouse.Utils:FormatNumber(num)
    if not num then return "0" end
    
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return formatted
end

-- Prozent berechnen
function DreamHouse.Utils:CalcPercent(current, max)
    if not max or max == 0 then return 0 end
    return math.floor((current / max) * 100)
end

-- Tabelle flach kopieren
function DreamHouse.Utils:ShallowCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = v
    end
    return copy
end

-- Prüfen ob Housing aktiv ist
function DreamHouse.Utils:IsHousingActive()
    return C_Housing and C_Housing.IsInsideHouseOrPlot and C_Housing.IsInsideHouseOrPlot()
end

-- Prüfen ob Editor aktiv ist
function DreamHouse.Utils:IsEditorActive()
    return C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive()
end

-- Aktuellen Editor-Modus holen
function DreamHouse.Utils:GetCurrentEditorMode()
    if not self:IsEditorActive() then return nil end
    return C_HouseEditor.GetActiveHouseEditorMode()
end

-- Editor-Modus Name
function DreamHouse.Utils:GetEditorModeName(mode)
    local modeNames = {
        [Enum.HouseEditorMode.None] = L["Mode_None"],
        [Enum.HouseEditorMode.BasicDecor] = L["Mode_BasicDecor"],
        [Enum.HouseEditorMode.ExpertDecor] = L["Mode_ExpertDecor"],
        [Enum.HouseEditorMode.Layout] = L["Mode_Layout"],
        [Enum.HouseEditorMode.Customize] = L["Mode_Customize"],
        [Enum.HouseEditorMode.Cleanup] = L["Mode_Cleanup"],
        [Enum.HouseEditorMode.ExteriorCustomization] = L["Mode_ExteriorCustomization"],
    }
    return modeNames[mode] or L["Unknown"]
end

-- Katalog-Entry Info holen (sicher, unterstützt beide Formate)
function DreamHouse.Utils:GetCatalogEntryInfo(entryID)
    if not C_HousingCatalog or not entryID then return nil end
    
    -- Prüfen ob entryID ein Table mit recordID ist (unser Format)
    if type(entryID) == "table" and entryID.recordID then
        local entryType = entryID.entryType or Enum.HousingCatalogEntryType.Decor
        local recordID = entryID.recordID
        return C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
    end
    
    -- Sonst das originale WoW-Format verwenden
    local success, result = pcall(C_HousingCatalog.GetCatalogEntryInfo, entryID)
    if success then
        return result
    end
    return nil
end

-- Anzahl platzierter Decor-Items holen (sichere Version)
-- GetAllPlacedDecor ist restricted, nutze stattdessen GetNumDecorPlaced
function DreamHouse.Utils:GetNumPlacedDecor()
    if not C_HousingDecor then return 0 end
    
    -- GetNumDecorPlaced ist nicht restricted
    if C_HousingDecor.GetNumDecorPlaced then
        return C_HousingDecor.GetNumDecorPlaced() or 0
    end
    
    return 0
end

-- Max platzierbare Decor-Items
function DreamHouse.Utils:GetMaxDecorPlaced()
    if not C_HousingDecor then return 0 end
    
    if C_HousingDecor.GetMaxDecorPlaced then
        return C_HousingDecor.GetMaxDecorPlaced() or 0
    end
    
    return 0
end

-- Decor-Budget Info
function DreamHouse.Utils:GetDecorBudget()
    if not C_HousingDecor then return 0, 0 end
    
    local spent = C_HousingDecor.GetSpentPlacementBudget and C_HousingDecor.GetSpentPlacementBudget() or 0
    local max = C_HousingDecor.GetMaxPlacementBudget and C_HousingDecor.GetMaxPlacementBudget() or 0
    
    return spent, max
end

-- Storage-Kapazität Info
function DreamHouse.Utils:GetStorageCapacity()
    if not C_HousingCatalog then return 0, 0, 0 end
    
    local total, exempt = C_HousingCatalog.GetDecorTotalOwnedCount and C_HousingCatalog.GetDecorTotalOwnedCount() or 0, 0
    local max = C_HousingCatalog.GetDecorMaxOwnedCount and C_HousingCatalog.GetDecorMaxOwnedCount() or 0
    
    return total - exempt, max, exempt
end

-- String teilen
function DreamHouse.Utils:Split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- String trimmen
function DreamHouse.Utils:Trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Tabelle hat Wert
function DreamHouse.Utils:TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- Tabelle zählen
function DreamHouse.Utils:TableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

