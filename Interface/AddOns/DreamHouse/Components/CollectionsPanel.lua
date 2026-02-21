--[[
    DreamHouse - Collections Panel
    Verwaltung von Item-Kollektionen im Housing Storage
    
    Features:
    - Kollektionen-Tab im Storage-Panel
    - Gruppierung von Items nach Sets/Themen
    - Fortschrittsanzeige für Kollektionen
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.Collections = {}

-- Kollektions-Definitionen
-- Können später aus einer Datenbank oder Config geladen werden
DreamHouse.Collections.definitions = {}

-- Benutzerdefinierte Kollektionen (wird aus SavedVariables geladen)
DreamHouse.Collections.customCollections = {}

-- ============================================
-- INITIALISIERUNG
-- ============================================

function DreamHouse.Collections:Init()
    DreamHouse.Debug:Log("Collections", "Initialisiere Kollektionen-System...", "INFO")
    
    -- Lade gespeicherte Kollektionen aus SavedVariables
    self:LoadSavedCollections()
    
    -- Event-Handler registrieren
    DreamHouse.Events:Register("DREAMHOUSE_COLLECTIONS_TAB_SELECTED", function()
        self:OnTabSelected()
    end, self)
    
    DreamHouse.Events:Register("DREAMHOUSE_COLLECTIONS_TAB_DESELECTED", function()
        self:OnTabDeselected()
    end, self)
    
    -- Aktive Kollektion laden
    if DreamHouse.Hooks and DreamHouse.Hooks.Storage then
        DreamHouse.Hooks.Storage:LoadCollectionSettings()
    end
    
    DreamHouse.Debug:Log("Collections", "Kollektionen-System initialisiert", "SUCCESS")
end

-- ============================================
-- KOLLEKTIONS-VERWALTUNG
-- ============================================

-- Lädt gespeicherte Kollektionen
function DreamHouse.Collections:LoadSavedCollections()
    DreamHouse.Debug:Log("Collections", "LoadSavedCollections aufgerufen", "DEBUG")
    DreamHouse.Debug:Log("Collections", "DreamHouseDB exists: " .. tostring(DreamHouseDB ~= nil), "DEBUG")
    
    if DreamHouseDB then
        DreamHouse.Debug:Log("Collections", "DreamHouseDB.collections exists: " .. tostring(DreamHouseDB.collections ~= nil), "DEBUG")
        if DreamHouseDB.collections then
            DreamHouse.Debug:Log("Collections", "DreamHouseDB.collections count: " .. #DreamHouseDB.collections, "DEBUG")
            self.customCollections = DreamHouseDB.collections
        else
            self.customCollections = {}
        end
    else
        self.customCollections = {}
    end
    
    DreamHouse.Debug:Log("Collections", "Gespeicherte Kollektionen geladen: " .. #self.customCollections, "SUCCESS")
    
    -- Debug: Zeige Namen der geladenen Kollektionen
    for i, col in ipairs(self.customCollections) do
        DreamHouse.Debug:Log("Collections", "  [" .. i .. "] " .. (col.name or "?"), "DEBUG")
    end
end

-- Speichert Kollektionen
function DreamHouse.Collections:SaveCollections()
    if not DreamHouseDB then
        DreamHouseDB = {}
    end
    DreamHouseDB.collections = self.customCollections
    DreamHouse.Debug:Log("Collections", "Kollektionen gespeichert: " .. #self.customCollections .. " in DreamHouseDB", "SUCCESS")
end

-- Erstellt eine neue benutzerdefinierte Kollektion
function DreamHouse.Collections:CreateCollection(name, description, icon)
    -- Sicherstellen dass customCollections existiert
    if not self.customCollections then
        self.customCollections = {}
    end
    
    local collection = {
        id = time() .. "_" .. math.random(1000, 9999),
        name = name or L["Unknown"],
        description = description or "",
        icon = icon or "bag-border-highlight",  -- Standard-Icon
        items = {},
        created = date("%Y-%m-%d %H:%M:%S"),
        modified = date("%Y-%m-%d %H:%M:%S"),
    }
    
    table.insert(self.customCollections, collection)
    self:SaveCollections()
    
    DreamHouse.Debug:Log("Collections", "Kollektion erstellt: " .. name .. " (Icon: " .. (icon or "default") .. ")", "SUCCESS")
    return collection
end

-- Fügt ein Item zu einer Kollektion hinzu
function DreamHouse.Collections:AddItemToCollection(collectionID, entryID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        DreamHouse.Debug:Log("Collections", "Kollektion nicht gefunden: " .. tostring(collectionID), "ERROR")
        return false
    end
    
    -- Prüfe ob Item bereits in Kollektion
    local recordID = entryID.recordID or entryID
    for _, item in ipairs(collection.items) do
        if item.recordID == recordID then
            DreamHouse.Debug:Log("Collections", "Item bereits in Kollektion", "DEBUG")
            return false
        end
    end
    
    -- Item hinzufügen
    table.insert(collection.items, {
        recordID = recordID,
        entryType = entryID.entryType or Enum.HousingCatalogEntryType.Decor,
        addedAt = date("%Y-%m-%d %H:%M:%S"),
    })
    
    collection.modified = date("%Y-%m-%d %H:%M:%S")
    self:SaveCollections()
    
    DreamHouse.Debug:Log("Collections", "Item zu Kollektion hinzugefügt: " .. recordID, "SUCCESS")
    return true
end

-- Entfernt ein Item aus einer Kollektion
function DreamHouse.Collections:RemoveItemFromCollection(collectionID, entryID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        return false
    end
    
    -- entryID kann eine Zahl oder ein Table sein
    local recordID
    if type(entryID) == "table" then
        recordID = entryID.recordID or entryID
    else
        recordID = entryID
    end
    
    for i, item in ipairs(collection.items) do
        if item.recordID == recordID then
            table.remove(collection.items, i)
            collection.modified = date("%Y-%m-%d %H:%M:%S")
            self:SaveCollections()
            DreamHouse.Debug:Log("Collections", "Item aus Kollektion entfernt: " .. recordID, "SUCCESS")
            return true
        end
    end
    
    return false
end

-- Findet eine Kollektion anhand der ID
function DreamHouse.Collections:GetCollectionByID(collectionID)
    for _, collection in ipairs(self.customCollections) do
        if collection.id == collectionID then
            return collection
        end
    end
    return nil
end

-- Gibt alle Kollektionen zurück
function DreamHouse.Collections:GetAllCollections()
    local cols = self.customCollections or {}
    DreamHouse.Debug:Log("Collections", "GetAllCollections: " .. #cols .. " Kollektionen", "DEBUG")
    return cols
end

-- Löscht eine Kollektion
function DreamHouse.Collections:DeleteCollection(collectionID)
    for i, collection in ipairs(self.customCollections) do
        if collection.id == collectionID then
            table.remove(self.customCollections, i)
            self:SaveCollections()
            DreamHouse.Debug:Log("Collections", "Kollektion gelöscht: " .. collectionID, "SUCCESS")
            return true
        end
    end
    return false
end

-- ============================================
-- KATALOG-EINTRÄGE HOLEN
-- ============================================

-- Holt alle entryIDs für eine bestimmte Kollektion
function DreamHouse.Collections:GetCollectionEntryIDs(collectionID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        return {}
    end
    
    local entryIDs = {}
    for _, item in ipairs(collection.items) do
        table.insert(entryIDs, {
            recordID = item.recordID,
            entryType = item.entryType or Enum.HousingCatalogEntryType.Decor,
        })
    end
    
    return entryIDs
end

-- Holt alle Items aus allen Kollektionen (für den Kollektionen-Tab)
function DreamHouse.Collections:GetAllCollectionItems()
    local allItems = {}
    local seenIDs = {}
    
    for _, collection in ipairs(self.customCollections) do
        for _, item in ipairs(collection.items) do
            if not seenIDs[item.recordID] then
                table.insert(allItems, {
                    recordID = item.recordID,
                    entryType = item.entryType or Enum.HousingCatalogEntryType.Decor,
                })
                seenIDs[item.recordID] = true
            end
        end
    end
    
    return allItems
end

-- ============================================
-- SET-ERKENNUNG (Automatisch)
-- ============================================

-- Versucht Sets automatisch zu erkennen basierend auf Item-Namen
function DreamHouse.Collections:DetectSetsFromOwnedItems()
    -- Diese Funktion kann später implementiert werden
    -- um automatisch Sets anhand von Item-Namen-Mustern zu erkennen
    -- z.B. "Arathi [Tisch/Stuhl/Lampe]" → "Arathi Set"
    
    DreamHouse.Debug:Log("Collections", "Set-Erkennung: Feature in Entwicklung", "DEBUG")
    return {}
end

-- ============================================
-- EVENT-HANDLER
-- ============================================

function DreamHouse.Collections:OnTabSelected()
    DreamHouse.Debug:Log("Collections", "Kollektionen-Tab aktiviert", "DEBUG")
    
    -- Hier können UI-Updates gemacht werden wenn der Tab sichtbar wird
end

function DreamHouse.Collections:OnTabDeselected()
    DreamHouse.Debug:Log("Collections", "Kollektionen-Tab deaktiviert", "DEBUG")
end

-- ============================================
-- HILFSFUNKTIONEN
-- ============================================

-- Prüft ob ein Item in einer bestimmten Kollektion ist
function DreamHouse.Collections:IsItemInCollection(collectionID, entryID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then return false end
    
    local recordID = entryID.recordID or entryID
    for _, item in ipairs(collection.items) do
        if item.recordID == recordID then
            return true
        end
    end
    return false
end

-- Prüft ob ein Item in irgendeiner Kollektion ist
function DreamHouse.Collections:IsItemInAnyCollection(entryID)
    local recordID = entryID.recordID or entryID
    
    for _, collection in ipairs(self.customCollections) do
        for _, item in ipairs(collection.items) do
            if item.recordID == recordID then
                return true, collection
            end
        end
    end
    
    return false, nil
end

-- Tauscht zwei Items in einer Kollektion (für Hotbar-Sync)
function DreamHouse.Collections:SwapItemsInCollection(collectionID, index1, index2)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        DreamHouse.Debug:Log("Collections", "SwapItems: Kollektion nicht gefunden", "ERROR")
        return false
    end
    
    -- Sicherstellen dass beide Indizes gültig sind
    if index1 < 1 or index2 < 1 then
        DreamHouse.Debug:Log("Collections", "SwapItems: Ungültiger Index (" .. tostring(index1) .. ", " .. tostring(index2) .. ")", "ERROR")
        return false
    end
    
    -- Debug: Zeige alle Items vor dem Swap
    DreamHouse.Debug:Log("Collections", "=== VOR SWAP ===", "DEBUG")
    for idx = 1, 10 do
        local item = collection.items[idx]
        DreamHouse.Debug:Log("Collections", "  [" .. idx .. "] = " .. (item and tostring(item.recordID) or "nil"), "DEBUG")
    end
    
    -- Items direkt mit den Indizes zugreifen (auch wenn Lücken entstehen)
    local item1 = collection.items[index1]
    local item2 = collection.items[index2]
    
    DreamHouse.Debug:Log("Collections", "SwapItems: Tausche Index " .. index1 .. " (" .. tostring(item1 and item1.recordID or "nil") .. ") <-> " .. index2 .. " (" .. tostring(item2 and item2.recordID or "nil") .. ")", "DEBUG")
    
    -- WICHTIG: Tiefe Kopie der Items machen, nicht nur Referenzen tauschen!
    local item1Copy = item1 and { recordID = item1.recordID, entryType = item1.entryType, addedAt = item1.addedAt } or nil
    local item2Copy = item2 and { recordID = item2.recordID, entryType = item2.entryType, addedAt = item2.addedAt } or nil
    
    -- Items tauschen (mit Kopien)
    collection.items[index1] = item2Copy
    collection.items[index2] = item1Copy
    
    -- Debug: Zeige alle Items nach dem Swap
    DreamHouse.Debug:Log("Collections", "=== NACH SWAP ===", "DEBUG")
    for idx = 1, 10 do
        local item = collection.items[idx]
        DreamHouse.Debug:Log("Collections", "  [" .. idx .. "] = " .. (item and tostring(item.recordID) or "nil"), "DEBUG")
    end
    
    collection.modified = date("%Y-%m-%d %H:%M:%S")
    self:SaveCollections()
    
    DreamHouse.Debug:Log("Collections", "Items getauscht: " .. index1 .. " <-> " .. index2, "SUCCESS")
    return true
end

-- Setzt ein Item an einer bestimmten Position in der Kollektion
function DreamHouse.Collections:SetItemAtIndex(collectionID, index, entryID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        return false
    end
    
    -- Erstelle temporäre nil-Platzhalter wenn nötig
    while #collection.items < index do
        table.insert(collection.items, nil)
    end
    
    if entryID then
        local recordID = entryID.recordID or entryID
        local entryType = entryID.entryType or Enum.HousingCatalogEntryType.Decor
        collection.items[index] = {
            recordID = recordID,
            entryType = entryType,
            addedAt = date("%Y-%m-%d %H:%M:%S"),
        }
    else
        collection.items[index] = nil
    end
    
    collection.modified = date("%Y-%m-%d %H:%M:%S")
    self:SaveCollections()
    
    return true
end

-- Holt das Item an einem bestimmten Index
function DreamHouse.Collections:GetItemAtIndex(collectionID, index)
    local collection = self:GetCollectionByID(collectionID)
    if not collection or index < 1 or index > #collection.items then
        return nil
    end
    return collection.items[index]
end

-- Zählt Items in einer Kollektion
function DreamHouse.Collections:GetCollectionItemCount(collectionID)
    local collection = self:GetCollectionByID(collectionID)
    if collection then
        return #collection.items
    end
    return 0
end

-- Berechnet Fortschritt einer Kollektion (wie viele Items besitzt der Spieler)
function DreamHouse.Collections:GetCollectionProgress(collectionID)
    local collection = self:GetCollectionByID(collectionID)
    if not collection then
        return 0, 0
    end
    
    local owned = 0
    local total = #collection.items
    
    for _, item in ipairs(collection.items) do
        local entryType = item.entryType or Enum.HousingCatalogEntryType.Decor
        local recordID = item.recordID
        
        local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
        if entryInfo and entryInfo.quantity and entryInfo.quantity > 0 then
            owned = owned + 1
        end
    end
    
    return owned, total
end

-- ============================================
-- SLASH-BEFEHLE
-- ============================================

-- Fügt Slash-Befehle für Kollektionen hinzu
function DreamHouse.Collections:RegisterSlashCommands()
    -- /dh collections - Zeigt Kollektionen-Info
    -- Wird in Core.lua registriert
end

-- Modul registrieren
DreamHouse:RegisterModule("Collections", DreamHouse.Collections)

-- Initialisierung bei PLAYER_LOGIN (wenn SavedVariables verfügbar sind)
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        DreamHouse.Collections:Init()
        self:UnregisterAllEvents()
    end
end)

