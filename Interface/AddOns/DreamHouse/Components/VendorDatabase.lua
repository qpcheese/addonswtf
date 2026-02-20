--[[
    DreamHouse - Vendor Database
    Sammelt automatisch Händler-Informationen für Housing-Items
    
    Wenn ein Spieler einen Händler öffnet, werden alle Housing-Items gescannt
    und mit Position (Map, Koordinaten) gespeichert.
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.VendorDatabase = {}

local isApplied = false
local scanFrame = nil

-- Datenbank-Struktur in SavedVariables:
-- DreamHouseVendorDB = {
--     [recordID] = {
--         itemName = "Fancy Chair",
--         vendorName = "Harold the Decorator",
--         vendorGUID = "Creature-0-...",
--         mapID = 2248,
--         mapName = "Dornogal",
--         x = 0.45,
--         y = 0.62,
--         lastSeen = timestamp,
--     }
-- }

-- Initialisiert die Datenbank wenn noch nicht vorhanden
function DreamHouse.VendorDatabase:InitDB()
    if not DreamHouseVendorDB then
        DreamHouseVendorDB = {}
        DreamHouse.Debug:Log("VendorDB", "Neue Vendor-Datenbank erstellt", "SUCCESS")
    end
    return DreamHouseVendorDB
end

-- Holt einen Eintrag aus der Datenbank
function DreamHouse.VendorDatabase:GetEntry(recordID)
    local db = self:InitDB()
    return db[recordID]
end

-- Speichert einen Eintrag in der Datenbank (nur wenn neu oder geändert)
-- Gibt true zurück wenn gespeichert wurde, false wenn bereits vorhanden
function DreamHouse.VendorDatabase:SaveEntry(recordID, data)
    local db = self:InitDB()
    local existing = db[recordID]
    
    -- Prüfe ob bereits identischer Eintrag existiert
    if existing then
        -- Gleicher Händler am gleichen Ort? Dann nicht neu speichern
        if existing.vendorName == data.vendorName and 
           existing.mapID == data.mapID and
           existing.vendorGUID == data.vendorGUID then
            -- Nur lastSeen aktualisieren (ohne Log-Spam)
            existing.lastSeen = data.lastSeen
            return false
        end
        -- Anderer Händler/Ort → Update (neuer Händler gefunden!)
        DreamHouse.Debug:Log("VendorDB", string.format("Update: %s jetzt auch bei %s (%s)", 
            data.itemName or "?", data.vendorName or "?", data.mapName or "?"), "INFO")
    else
        -- Komplett neuer Eintrag
        DreamHouse.Debug:Log("VendorDB", string.format("Neu: %s bei %s (%s)", 
            data.itemName or "?", data.vendorName or "?", data.mapName or "?"), "SUCCESS")
    end
    
    db[recordID] = data
    return true
end

-- Prüft ob ein Item ein Housing-Dekor ist und gibt die recordID zurück
function DreamHouse.VendorDatabase:GetHousingRecordID(itemLink)
    if not itemLink or not C_HousingCatalog then
        return nil
    end
    
    -- Versuche Housing-Info für dieses Item zu bekommen
    local tryGetOwnedInfo = false
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink, tryGetOwnedInfo)
    
    if entryInfo and entryInfo.entryID and entryInfo.entryID.recordID then
        return entryInfo.entryID.recordID, entryInfo.name
    end
    
    return nil
end

-- Scannt den aktuellen Händler nach Housing-Items
function DreamHouse.VendorDatabase:ScanCurrentMerchant()
    if not MerchantFrame or not MerchantFrame:IsShown() then
        DreamHouse.Debug:Log("VendorDB", L["No vendor open"], "WARN")
        return 0
    end
    
    -- Händler-Informationen holen
    local vendorName = UnitName("npc") or L["Unknown Vendor"]
    local vendorGUID = UnitGUID("npc")
    
    -- Aktuelle Position holen
    local mapID = C_Map.GetBestMapForUnit("player")
    local mapName = L["Unknown"]
    local x, y = 0, 0
    
    if mapID then
        local mapInfo = C_Map.GetMapInfo(mapID)
        mapName = mapInfo and mapInfo.name or "Unbekannt"
        
        local position = C_Map.GetPlayerMapPosition(mapID, "player")
        if position then
            x, y = position:GetXY()
        end
    end
    
    DreamHouse.Debug:Log("VendorDB", string.format("Scanne Händler: %s in %s (%.2f, %.2f)", 
        vendorName, mapName, x * 100, y * 100), "INFO")
    
    -- Alle Items im Händler-Fenster durchgehen
    local numItems = GetMerchantNumItems()
    local housingItemsTotal = 0
    local newItemsAdded = 0
    
    for i = 1, numItems do
        local itemLink = GetMerchantItemLink(i)
        if itemLink then
            local recordID, itemName = self:GetHousingRecordID(itemLink)
            
            if recordID then
                housingItemsTotal = housingItemsTotal + 1
                
                -- Housing-Item gefunden! Speichern (nur wenn neu/geändert)
                local wasNew = self:SaveEntry(recordID, {
                    itemName = itemName or "Unbekannt",
                    vendorName = vendorName,
                    vendorGUID = vendorGUID,
                    mapID = mapID,
                    mapName = mapName,
                    x = x,
                    y = y,
                    lastSeen = time(),
                })
                
                if wasNew then
                    newItemsAdded = newItemsAdded + 1
                end
            end
        end
    end
    
    if newItemsAdded > 0 then
        DreamHouse.Debug:Log("VendorDB", string.format("%d neue Housing-Items bei %s gespeichert!", 
            newItemsAdded, vendorName), "SUCCESS")
        print("|cff00ccff[DreamHouse]|r " .. L.Format("X new housing items from Y saved", newItemsAdded, "|cff00ff00" .. vendorName .. "|r"))
    elseif housingItemsTotal > 0 then
        DreamHouse.Debug:Log("VendorDB", string.format("%s: %d Housing-Items bereits bekannt", 
            vendorName, housingItemsTotal), "DEBUG")
    else
        DreamHouse.Debug:Log("VendorDB", "Keine Housing-Items bei diesem Händler", "DEBUG")
    end
    
    return newItemsAdded
end

-- Versucht einen Wegpunkt aus der eigenen Datenbank zu setzen
function DreamHouse.VendorDatabase:TryShowOnMap(recordID, itemName)
    local entry = self:GetEntry(recordID)
    
    if not entry then
        DreamHouse.Debug:Log("VendorDB", "Kein Eintrag für recordID " .. tostring(recordID), "DEBUG")
        return false
    end
    
    DreamHouse.Debug:Log("VendorDB", string.format("Datenbank-Eintrag gefunden: %s bei %s", 
        entry.itemName or "?", entry.vendorName or "?"), "SUCCESS")
    
    -- Wegpunkt setzen wenn möglich
    if entry.mapID and entry.x and entry.y and entry.x > 0 and entry.y > 0 then
        local waypointTitle = string.format("%s - %s", entry.vendorName or "Händler", itemName or entry.itemName or "Item")
        local usedTomTom = false
        
        -- PRIORITÄT 1: TomTom (benannter Wegpunkt!)
        if TomTom and TomTom.AddWaypoint then
            -- Entferne alte DreamHouse-Waypoints (optional)
            if TomTom.RemoveWaypoint and DreamHouse.lastTomTomWaypoint then
                pcall(function() TomTom:RemoveWaypoint(DreamHouse.lastTomTomWaypoint) end)
            end
            
            -- Debug: Zeige was wir haben
            DreamHouse.Debug:Log("VendorDB", string.format("TomTom Input: mapID=%s, x=%.4f, y=%.4f", 
                tostring(entry.mapID), entry.x, entry.y), "DEBUG")
            
            -- Neuen Waypoint erstellen (Koordinaten 0-1)
            local success, waypoint = pcall(function()
                return TomTom:AddWaypoint(entry.mapID, entry.x, entry.y, {
                    title = waypointTitle,
                    persistent = false,
                    minimap = true,
                    world = true,
                    crazy = true,  -- Aktiviert den TomTom-Pfeil!
                })
            end)
            
            if success and waypoint then
                DreamHouse.lastTomTomWaypoint = waypoint
                usedTomTom = true
                
                -- Setze diesen Waypoint als aktiven/nächsten Waypoint
                if TomTom.SetClosestWaypoint then
                    TomTom:SetClosestWaypoint()
                end
                
                DreamHouse.Debug:Log("VendorDB", string.format("TomTom Waypoint erstellt: %s", waypointTitle), "SUCCESS")
            else
                DreamHouse.Debug:Log("VendorDB", "TomTom Waypoint fehlgeschlagen: " .. tostring(waypoint), "ERROR")
            end
        
        -- PRIORITÄT 2: Standard WoW Waypoint
        elseif C_Map.CanSetUserWaypointOnMap(entry.mapID) then
            local point = UiMapPoint.CreateFromCoordinates(entry.mapID, entry.x, entry.y)
            C_Map.SetUserWaypoint(point)
            
            -- Super-Tracking aktivieren
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
            
            DreamHouse.Debug:Log("VendorDB", "Standard WoW Waypoint gesetzt", "DEBUG")
        else
            DreamHouse.Debug:Log("VendorDB", "Kann keinen Waypoint auf Map " .. entry.mapID .. " setzen", "WARN")
        end
        
        -- Karte öffnen
        if not WorldMapFrame:IsShown() then
            ToggleWorldMap()
        end
        
        if WorldMapFrame.SetMapID then
            WorldMapFrame:SetMapID(entry.mapID)
        end
        
        -- Chat-Nachricht
        if usedTomTom then
            print("|cff00ccff[DreamHouse]|r |cff00ff00" .. L["TomTom Waypoint"] .. "|r: |cffffff00" .. waypointTitle .. "|r")
        else
            print("|cff00ccff[DreamHouse]|r " .. L.Format("Waypoint for X set", "|cff00ff00" .. (itemName or entry.itemName) .. "|r"))
            print("|cff00ccff[DreamHouse]|r " .. L.Format("Vendor: X in Y", "|cffffff00" .. (entry.vendorName or "?") .. "|r", "|cffffff00" .. (entry.mapName or "?") .. "|r"))
        end
        
        return true
    end
    
    -- Fallback: Zeige zumindest die Information
    print(string.format("|cff00ccff[DreamHouse]|r |cff00ff00%s|r: Händler |cffffff00%s|r in |cffffff00%s|r", 
        itemName or entry.itemName, entry.vendorName or "?", entry.mapName or "?"))
    print("|cff00ccff[DreamHouse]|r |cff888888" .. L["No waypoint possible"] .. "|r")
    
    return true
end

-- Statistiken ausgeben
function DreamHouse.VendorDatabase:GetStats()
    local db = self:InitDB()
    local count = 0
    local vendors = {}
    
    for recordID, entry in pairs(db) do
        count = count + 1
        if entry.vendorName then
            vendors[entry.vendorName] = (vendors[entry.vendorName] or 0) + 1
        end
    end
    
    local vendorCount = 0
    for _ in pairs(vendors) do
        vendorCount = vendorCount + 1
    end
    
    return count, vendorCount
end

-- Hook anwenden
function DreamHouse.VendorDatabase:Apply()
    if isApplied then return end
    
    DreamHouse.Debug:Log("VendorDB", "Initialisiere Vendor-Datenbank...", "INFO")
    
    -- Datenbank initialisieren
    self:InitDB()
    
    -- Event-Frame erstellen
    scanFrame = CreateFrame("Frame")
    scanFrame:RegisterEvent("MERCHANT_SHOW")
    scanFrame:RegisterEvent("MERCHANT_UPDATE")
    
    local lastScanTime = 0
    local SCAN_COOLDOWN = 2 -- Sekunden zwischen Scans
    
    scanFrame:SetScript("OnEvent", function(self, event, ...)
        local currentTime = GetTime()
        
        -- Cooldown um Spam zu verhindern
        if currentTime - lastScanTime < SCAN_COOLDOWN then
            return
        end
        
        if event == "MERCHANT_SHOW" then
            -- Kurze Verzögerung damit alle Items geladen sind
            C_Timer.After(0.5, function()
                DreamHouse.VendorDatabase:ScanCurrentMerchant()
            end)
            lastScanTime = currentTime
        elseif event == "MERCHANT_UPDATE" then
            -- Bei Update auch scannen (für Händler mit mehreren Seiten)
            C_Timer.After(0.3, function()
                DreamHouse.VendorDatabase:ScanCurrentMerchant()
            end)
            lastScanTime = currentTime
        end
    end)
    
    -- Statistiken beim Laden anzeigen
    local itemCount, vendorCount = self:GetStats()
    if itemCount > 0 then
        DreamHouse.Debug:Log("VendorDB", string.format("Datenbank geladen: %d Items von %d Händlern", 
            itemCount, vendorCount), "SUCCESS")
    end
    
    isApplied = true
    DreamHouse.Debug:Log("VendorDB", "Vendor-Datenbank aktiviert", "SUCCESS")
end

-- Slash-Command Handler
function DreamHouse.VendorDatabase:HandleCommand(args)
    if args == "stats" then
        local itemCount, vendorCount = self:GetStats()
        print("|cff00ccff[DreamHouse Vendor-DB]|r " .. L["Statistics"] .. ":")
        print(string.format("  " .. L["Items"] .. ": |cff00ff00%d|r", itemCount))
        print(string.format("  " .. L["Vendors"] .. ": |cff00ff00%d|r", vendorCount))
    elseif args == "scan" then
        local found = self:ScanCurrentMerchant()
        if found == 0 then
            print("|cff00ccff[DreamHouse]|r " .. L["No vendor open"] .. " / " .. L["No housing items at this vendor"])
        end
    elseif args == "clear" then
        DreamHouseVendorDB = {}
        print("|cff00ccff[DreamHouse]|r " .. L["Vendor database cleared"])
    else
        print("|cff00ccff[DreamHouse Vendor-DB]|r " .. L["VendorDB Commands"])
        print("  |cffffff00/dh vendordb stats|r - " .. L["Statistics"])
        print("  |cffffff00/dh vendordb scan|r - Scan vendor")
        print("  |cffffff00/dh vendordb clear|r - Clear database")
    end
end

-- Modul registrieren
DreamHouse:RegisterModule("VendorDatabase", DreamHouse.VendorDatabase)

