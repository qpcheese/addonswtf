--[[
    DreamHouse - Settings & SavedVariables
    Verwaltet alle Addon-Einstellungen und persistenten Daten
]]

local addonName, DreamHouse = ...

-- Default-Einstellungen
local defaults = {
    -- Feature-Toggles (nur die wirklich nützlichen!)
    settings = {
        debugEnabled = true,
        debugVerbose = false,
        hotbarEnabled = true,
        favoritesEnabled = true,
        tooltipsEnhanced = true,
        statsEnabled = true,
        presetsEnabled = true,
    },
    
    -- Favoriten (entryID -> true)
    favorites = {},
    
    -- Hotbar Slots (slot -> entryID)
    hotbar = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
        [5] = nil,
        [6] = nil,
        [7] = nil,
        [8] = nil,
        [9] = nil,
        [10] = nil,
    },
    
    -- Gespeicherte Presets
    presets = {},
    
    -- Fenster-Positionen
    windowPositions = {
        debugConsole = nil,
        hotbar = nil,
        statsPanel = nil,
        presetManager = nil,
    },
    
    -- Statistik-Cache (wird bei jedem Login aktualisiert)
    statsCache = {
        lastUpdate = 0,
        totalPlaced = 0,
        totalOwned = 0,
        categoryBreakdown = {},
    },
}

-- Tiefes Kopieren für Tabellen
local function DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = DeepCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

-- Merge von Defaults in bestehende Daten (fügt fehlende Keys hinzu)
local function MergeDefaults(data, defaults)
    if type(data) ~= "table" then
        return DeepCopy(defaults)
    end
    
    for key, defaultValue in pairs(defaults) do
        if data[key] == nil then
            data[key] = DeepCopy(defaultValue)
        elseif type(defaultValue) == "table" and type(data[key]) == "table" then
            MergeDefaults(data[key], defaultValue)
        end
    end
    
    return data
end

-- Settings-Modul
DreamHouse.Settings = {}

function DreamHouse.Settings:Initialize()
    -- SavedVariables laden oder erstellen
    if not DreamHouseDB then
        DreamHouseDB = DeepCopy(defaults)
        DreamHouse.Debug:Log("Settings", "Neue Datenbank erstellt", "INFO")
    else
        -- Fehlende Defaults hinzufügen (für Updates)
        MergeDefaults(DreamHouseDB, defaults)
        DreamHouse.Debug:Log("Settings", "Bestehende Datenbank geladen", "INFO")
    end
    
    -- Shortcut für einfacheren Zugriff
    self.db = DreamHouseDB
end

-- Getter für Einstellungen
function DreamHouse.Settings:Get(category, key)
    if not self.db then return nil end
    
    if key then
        return self.db[category] and self.db[category][key]
    else
        return self.db[category]
    end
end

-- Setter für Einstellungen
function DreamHouse.Settings:Set(category, key, value)
    if not self.db then return end
    
    if not self.db[category] then
        self.db[category] = {}
    end
    
    local oldValue = self.db[category][key]
    self.db[category][key] = value
    
    DreamHouse.Debug:Log("Settings", string.format("%s.%s: %s -> %s", category, key, tostring(oldValue), tostring(value)), "DEBUG")
    
    -- Event für Settings-Änderung auslösen
    if DreamHouse.Events then
        DreamHouse.Events:Fire("DREAMHOUSE_SETTING_CHANGED", category, key, value, oldValue)
    end
end

-- Favoriten-Helfer
-- Key-Format: "recordID_entryType" für eindeutige Identifikation
function DreamHouse.Settings:GetFavoriteKey(entryID)
    if not entryID then return nil end
    local recordID = entryID.recordID or entryID
    local entryType = entryID.entryType or 0
    return tostring(recordID) .. "_" .. tostring(entryType)
end

function DreamHouse.Settings:IsFavorite(entryID)
    if not self.db or not entryID then return false end
    
    local key = self:GetFavoriteKey(entryID)
    return self.db.favorites[key] ~= nil
end

function DreamHouse.Settings:SetFavorite(entryID, isFavorite)
    if not self.db or not entryID then return end
    
    local key = self:GetFavoriteKey(entryID)
    
    if isFavorite then
        -- Speichere vollständige entryID-Daten
        self.db.favorites[key] = {
            recordID = entryID.recordID or entryID,
            entryType = entryID.entryType or 0
        }
    else
        self.db.favorites[key] = nil
    end
    
    DreamHouse.Debug:Log("Favorites", string.format("Item %s: %s", key, isFavorite and "favorisiert" or "entfernt"), "INFO")
    
    if DreamHouse.Events then
        DreamHouse.Events:Fire("DREAMHOUSE_FAVORITE_CHANGED", entryID, isFavorite)
    end
end

function DreamHouse.Settings:GetAllFavorites()
    if not self.db then return {} end
    return self.db.favorites
end

-- Gibt alle Favoriten als Liste von entryID-Objekten zurück
function DreamHouse.Settings:GetAllFavoriteEntryIDs()
    if not self.db then return {} end
    
    local entries = {}
    for key, data in pairs(self.db.favorites) do
        if type(data) == "table" and data.recordID then
            table.insert(entries, data)
        elseif type(data) == "boolean" then
            -- Alte Format-Kompatibilität (nur recordID als Key)
            local recordID = tonumber(string.match(key, "^(%d+)"))
            if recordID then
                table.insert(entries, { recordID = recordID, entryType = 0 })
            end
        end
    end
    return entries
end

-- Hotbar-Helfer
function DreamHouse.Settings:GetHotbarSlot(slot)
    if not self.db or not slot then return nil end
    return self.db.hotbar[slot]
end

function DreamHouse.Settings:SetHotbarSlot(slot, entryID)
    if not self.db or not slot then return end
    
    self.db.hotbar[slot] = entryID
    
    DreamHouse.Debug:Log("Hotbar", string.format("Slot %d: %s", slot, entryID and tostring(entryID) or "leer"), "INFO")
    
    if DreamHouse.Events then
        DreamHouse.Events:Fire("DREAMHOUSE_HOTBAR_CHANGED", slot, entryID)
    end
end

-- Preset-Helfer
function DreamHouse.Settings:SavePreset(name, data)
    if not self.db or not name then return false end
    
    self.db.presets[name] = {
        name = name,
        created = time(),
        data = data,
    }
    
    DreamHouse.Debug:Log("Presets", string.format("Preset '%s' gespeichert", name), "INFO")
    return true
end

function DreamHouse.Settings:GetPreset(name)
    if not self.db or not name then return nil end
    return self.db.presets[name]
end

function DreamHouse.Settings:DeletePreset(name)
    if not self.db or not name then return false end
    
    self.db.presets[name] = nil
    DreamHouse.Debug:Log("Presets", string.format("Preset '%s' gelöscht", name), "INFO")
    return true
end

function DreamHouse.Settings:GetAllPresets()
    if not self.db then return {} end
    return self.db.presets
end

-- Fenster-Position speichern
function DreamHouse.Settings:SaveWindowPosition(windowName, point, relativeTo, relativePoint, x, y)
    if not self.db or not windowName then return end
    
    self.db.windowPositions[windowName] = {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

function DreamHouse.Settings:GetWindowPosition(windowName)
    if not self.db or not windowName then return nil end
    return self.db.windowPositions[windowName]
end

-- Feature-Toggle Helfer
function DreamHouse.Settings:IsFeatureEnabled(featureName)
    return self:Get("settings", featureName .. "Enabled") ~= false
end

-- Export Addon-Namespace
_G.DreamHouse = DreamHouse

