--[[
    DreamHouse - Storage Panel Hooks
    Hooks für das Blizzard Housing Storage/Katalog Panel
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.Hooks = DreamHouse.Hooks or {}
DreamHouse.Hooks.Storage = {}

-- ============================================
-- QUELLE AUF KARTE ZEIGEN - Feature
-- ============================================

-- Prüft ob für ein Item eine Quelle auf der Karte angezeigt werden kann
function DreamHouse.Hooks.Storage:CanShowSourceOnMap(entryID)
    if not entryID then 
        DreamHouse.Debug:Log("Map", "CanShowSourceOnMap: entryID ist nil", "WARN")
        return false, nil 
    end
    
    local recordID = entryID.recordID or entryID
    DreamHouse.Debug:Log("Map", "CanShowSourceOnMap für recordID: " .. tostring(recordID), "DEBUG")
    
    -- PRIORITÄT 1: Eigene Vendor-Datenbank prüfen
    -- Diese ist zuverlässiger da wir die Daten selbst gesammelt haben
    if DreamHouse.VendorDatabase then
        local entry = DreamHouse.VendorDatabase:GetEntry(recordID)
        if entry then
            DreamHouse.Debug:Log("Map", "Item " .. recordID .. " in eigener Datenbank gefunden: " .. (entry.vendorName or "?"), "SUCCESS")
            return true, nil  -- Button aktivieren!
        end
    end
    
    -- PRIORITÄT 2: Blizzard Content Tracking prüfen
    if C_ContentTracking then
        local isTrackable = C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, recordID)
        DreamHouse.Debug:Log("Map", "IsTrackable(" .. tostring(recordID) .. ") = " .. tostring(isTrackable), "DEBUG")
        
        if isTrackable then
            return true, nil
        end
    end
    
    -- Weder in DB noch trackbar
    DreamHouse.Debug:Log("Map", "Item " .. recordID .. " weder in DB noch trackbar", "DEBUG")
    return false, "nicht_trackbar"
end

-- Zeigt die Quelle eines Items auf der Weltkarte
function DreamHouse.Hooks.Storage:ShowSourceOnMap(entryID, entryInfo)
    if not entryID then 
        DreamHouse.Debug:Log("Map", "Keine entryID übergeben", "ERROR")
        return false 
    end
    
    local recordID = entryID.recordID or entryID
    local itemName = entryInfo and entryInfo.name or "Item"
    
    DreamHouse.Debug:Log("Map", "Zeige Quelle für: " .. itemName .. " (ID: " .. recordID .. ")", "INFO")
    
    -- PRIORITÄT 1: Eigene Vendor-Datenbank (zuverlässiger!)
    if DreamHouse.VendorDatabase then
        local success = DreamHouse.VendorDatabase:TryShowOnMap(recordID, itemName)
        if success then
            DreamHouse.Debug:Log("Map", "Quelle aus eigener Datenbank angezeigt!", "SUCCESS")
            return true
        end
    end
    
    -- PRIORITÄT 2: Blizzard Content Tracking
    if not C_ContentTracking then
        -- Kein Content-Tracking und nicht in unserer DB
        local sourceText = entryInfo and entryInfo.sourceText
        if sourceText and sourceText ~= "" then
            print("|cff00ccff[DreamHouse]|r Quelle für |cff00ff00" .. itemName .. "|r: |cffffff00" .. sourceText .. "|r")
            print("|cff00ccff[DreamHouse]|r |cff888888(Besuche den Händler um die Position zu speichern!)|r")
            return true
        end
        print("|cff00ccff[DreamHouse]|r " .. L["Content tracking not available"])
        return false
    end
    
    -- Prüfe ob das Item trackbar ist
    local isTrackable = C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, recordID)
    if not isTrackable then
        DreamHouse.Debug:Log("Map", "Item nicht trackbar und nicht in eigener Datenbank", "DEBUG")
        
        -- FALLBACK: sourceText anzeigen (ohne Karten-Marker)
        local sourceText = entryInfo and entryInfo.sourceText
        if sourceText and sourceText ~= "" then
            print("|cff00ccff[DreamHouse]|r " .. L.Format("Source for X", "|cff00ff00" .. itemName .. "|r") .. ": |cffffff00" .. sourceText .. "|r")
            print("|cff00ccff[DreamHouse]|r |cff888888" .. L["Visit vendor to save position"] .. "|r")
            DreamHouse.Debug:Log("Map", "Nicht trackbar, aber sourceText: " .. sourceText, "INFO")
            return true
        else
            print("|cff00ccff[DreamHouse]|r " .. L.Format("X has no known source", "|cffff6666" .. itemName .. "|r"))
            print("|cff00ccff[DreamHouse]|r |cff888888" .. L["Visit vendors to collect items"] .. "|r")
            DreamHouse.Debug:Log("Map", "Item nicht trackbar und kein sourceText", "WARN")
            return false
        end
    end
    
    -- NEUER ANSATZ: Erst Tracking starten, dann Map-Position holen
    -- Das lädt die notwendigen Daten für GetBestMapForTrackable
    
    -- Starte Tracking (falls nicht bereits aktiv)
    local wasAlreadyTracking = C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID)
    if not wasAlreadyTracking then
        local trackingError = C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, recordID)
        if trackingError then
            DreamHouse.Debug:Log("Map", "StartTracking Fehler: " .. tostring(trackingError), "WARN")
        else
            DreamHouse.Debug:Log("Map", "Tracking gestartet für " .. itemName, "SUCCESS")
        end
    end
    
    -- Kurze Verzögerung damit die API die Daten laden kann
    C_Timer.After(0.1, function()
        -- Finde die beste Map
        local result, mapID = C_ContentTracking.GetBestMapForTrackable(Enum.ContentTrackingType.Decor, recordID)
        
        DreamHouse.Debug:Log("Map", "GetBestMapForTrackable: Result=" .. tostring(result) .. ", MapID=" .. tostring(mapID), "DEBUG")
        
        if result == Enum.ContentTrackingResult.Success and mapID then
            -- Hole Waypoint-Info für diese Map
            local waypointResult, mapInfo = C_ContentTracking.GetNextWaypointForTrackable(
                Enum.ContentTrackingType.Decor, 
                recordID, 
                mapID
            )
            
            if waypointResult == Enum.ContentTrackingResult.Success and mapInfo and mapInfo.position then
                DreamHouse.Debug:Log("Map", string.format("Waypoint: Map %d, Pos %.2f/%.2f", 
                    mapInfo.uiMapID or mapID, mapInfo.position.x, mapInfo.position.y), "SUCCESS")
                
                local targetMapID = mapInfo.uiMapID or mapID
                local posX, posY = mapInfo.position.x, mapInfo.position.y
                
                -- TomTom ODER Standard-Waypoint (OpenMapAtLocation handhabt beides)
                if not (TomTom and TomTom.AddWaypoint) then
                    -- Kein TomTom → Standard WoW Waypoint setzen
                    if C_Map.CanSetUserWaypointOnMap(targetMapID) then
                        local point = UiMapPoint.CreateFromCoordinates(targetMapID, posX, posY)
                        C_Map.SetUserWaypoint(point)
                        
                        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                            C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                        end
                    end
                end
                
                -- Öffne die Weltkarte (mit TomTom-Support wenn verfügbar)
                DreamHouse.Hooks.Storage:OpenMapAtLocation(targetMapID, itemName, posX, posY)
            else
                -- Kein exakter Waypoint, aber wir haben eine Map
                DreamHouse.Debug:Log("Map", "Kein Waypoint, aber Map " .. mapID .. " gefunden", "DEBUG")
                DreamHouse.Hooks.Storage:OpenMapAtLocation(mapID, itemName)
            end
        else
            -- Keine Map gefunden - öffne trotzdem die Weltkarte mit Tracking aktiv
            DreamHouse.Debug:Log("Map", "Keine Map gefunden, öffne Weltkarte mit aktivem Tracking", "INFO")
            
            if not WorldMapFrame:IsShown() then
                ToggleWorldMap()
            end
            
            print("|cff00ccff[DreamHouse]|r " .. L.Format("X is being tracked", "|cff00ff00" .. itemName .. "|r"))
        end
        
        -- Stoppe Tracking wieder wenn wir es gestartet haben (optional - User kann entscheiden)
        -- if not wasAlreadyTracking then
        --     C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, recordID, Enum.ContentTrackingStopType.Manual)
        -- end
    end)
    
    return true
end

-- Hilfsfunktion: Öffnet die Weltkarte an einer bestimmten Position
-- Optional: Mit TomTom Waypoint wenn x, y übergeben werden
function DreamHouse.Hooks.Storage:OpenMapAtLocation(mapID, itemName, x, y, vendorName)
    local mapName = C_Map.GetMapInfo(mapID)
    local mapNameStr = mapName and mapName.name or "Unbekannt"
    local usedTomTom = false
    
    -- TomTom Waypoint erstellen wenn Koordinaten vorhanden
    if x and y and x > 0 and y > 0 then
        local waypointTitle = vendorName 
            and string.format("%s - %s", vendorName, itemName)
            or string.format("Quelle: %s", itemName)
        
        -- PRIORITÄT 1: TomTom (benannter Wegpunkt!)
        if TomTom and TomTom.AddWaypoint then
            -- Entferne alte DreamHouse-Waypoints
            if TomTom.RemoveWaypoint and DreamHouse.lastTomTomWaypoint then
                pcall(function() TomTom:RemoveWaypoint(DreamHouse.lastTomTomWaypoint) end)
            end
            
            DreamHouse.Debug:Log("Map", string.format("TomTom Input: mapID=%s, x=%.4f, y=%.4f", 
                tostring(mapID), x, y), "DEBUG")
            
            local success, waypoint = pcall(function()
                return TomTom:AddWaypoint(mapID, x, y, {
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
                
                DreamHouse.Debug:Log("Map", "TomTom Waypoint erstellt: " .. waypointTitle, "SUCCESS")
            else
                DreamHouse.Debug:Log("Map", "TomTom Waypoint fehlgeschlagen: " .. tostring(waypoint), "ERROR")
            end
        end
    end
    
    -- Öffne die Weltkarte
    if not WorldMapFrame:IsShown() then
        ToggleWorldMap()
    end
    
    -- Navigiere zur richtigen Map
    if WorldMapFrame.SetMapID and mapID then
        WorldMapFrame:SetMapID(mapID)
    end
    
    -- Erfolgs-Nachricht
    if usedTomTom then
        print("|cff00ccff[DreamHouse]|r |cff00ff00" .. L["TomTom Waypoint"] .. "|r: |cffffff00" .. itemName .. "|r in " .. mapNameStr)
    else
        print("|cff00ccff[DreamHouse]|r " .. L.Format("Source for X", "|cff00ff00" .. itemName .. "|r") .. ": " .. mapNameStr)
    end
    DreamHouse.Debug:Log("Map", "Karte geöffnet: " .. mapNameStr, "SUCCESS")
end

-- ============================================
-- ORIGINAL STORAGE HOOKS
-- ============================================

local isApplied = false

local catalogEntriesHooked = false

function DreamHouse.Hooks.Storage:Apply()
    if isApplied then return end
    
    DreamHouse.Debug:Log("Hooks", "Wende Storage-Panel Hooks an...", "INFO")
    
    -- Hook für Katalog-Einträge (Mixin existiert früh)
    self:HookCatalogEntries()
    
    -- Falls Hook nicht geklappt hat, später nochmal versuchen
    if not catalogEntriesHooked then
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin nicht gefunden - warte auf ADDON_LOADED...", "WARN")
        
        -- Event-Frame für ADDON_LOADED erstellen
        local waitFrame = CreateFrame("Frame")
        waitFrame:RegisterEvent("ADDON_LOADED")
        waitFrame:SetScript("OnEvent", function(self, event, loadedAddon)
            if loadedAddon == "Blizzard_HousingTemplates" or loadedAddon == "Blizzard_HouseEditor" then
                DreamHouse.Debug:Log("Hooks", loadedAddon .. " geladen - versuche Hook erneut...", "INFO")
                C_Timer.After(0.5, function()
                    DreamHouse.Hooks.Storage:HookCatalogEntries()
                end)
            end
        end)
        
        -- Auch nach kurzer Zeit nochmal versuchen (falls AddOn schon geladen)
        C_Timer.After(2, function()
            if not catalogEntriesHooked then
                DreamHouse.Debug:Log("Hooks", "Verzögerter Hook-Versuch...", "INFO")
                DreamHouse.Hooks.Storage:HookCatalogEntries()
            end
        end)
    end
    
    -- Storage-Frame ist HouseEditorFrame.StoragePanel (NICHT HouseEditorStorageFrame!)
    
    -- Funktion um Storage-Frame zu finden
    local function GetStorageFrame()
        if HouseEditorFrame and HouseEditorFrame.StoragePanel then
            return HouseEditorFrame.StoragePanel
        end
        return nil
    end
    
    DreamHouse.Events:Register("DREAMHOUSE_MODE_CHANGED", function(_, newMode)
        if newMode and newMode ~= Enum.HouseEditorMode.None then
            -- Editor ist aktiv - jetzt sollte das Frame existieren
            C_Timer.After(0.5, function()
                local storageFrame = GetStorageFrame()
                if storageFrame and not DreamHouse.Hooks.Storage.storageFrameHooked then
                    DreamHouse.Debug:Log("Hooks", "Storage-Frame gefunden via Event!", "SUCCESS")
                    DreamHouse.Hooks.Storage:HookStorageFrame(storageFrame)
                    DreamHouse.Hooks.Storage.storageFrameHooked = true
                end
            end)
        end
    end, DreamHouse.Hooks.Storage)
    
    -- Falls Frame bereits existiert (z.B. nach /reload im Editor)
    local storageFrame = GetStorageFrame()
    if storageFrame then
        DreamHouse.Debug:Log("Hooks", "Storage-Frame bereits vorhanden!", "SUCCESS")
        self:HookStorageFrame(storageFrame)
        self.storageFrameHooked = true
    else
        DreamHouse.Debug:Log("Hooks", "Storage-Frame noch nicht geladen - warte auf Event", "DEBUG")
    end
    
    isApplied = true
end

function DreamHouse.Hooks.Storage:HookStorageFrame(storageFrame)
    DreamHouse.Debug:Log("Hooks", "HouseEditorStorageFrame gefunden", "SUCCESS")
    
    -- ============================================
    -- KOLLEKTIONEN-TAB HINZUFÜGEN
    -- ============================================
    self:AddCollectionsTab(storageFrame)
    self:HookTabChanges(storageFrame)
    
    -- Funktion um Storage-Features zu aktivieren
    local function ActivateStorageFeatures()
        DreamHouse.Debug:Log("Hooks", "Aktiviere Storage-Features...", "INFO")
        
        -- Hotbar anzeigen wenn aktiviert
        if DreamHouse.Settings:IsFeatureEnabled("hotbar") and DreamHouse.Hotbar then
            DreamHouse.Hotbar:AttachToStoragePanel(storageFrame)
            DreamHouse.Debug:Log("Hooks", "Hotbar angehängt", "SUCCESS")
        end
        
        DreamHouse.Events:Fire("DREAMHOUSE_STORAGE_OPENED")
    end
    
    -- OnShow Hook für zukünftige Opens
    DreamHouse.Utils:SafeHookScript(storageFrame, "OnShow", function()
        DreamHouse.Debug:Log("Hooks", "Storage-Panel OnShow Event", "DEBUG")
        ActivateStorageFeatures()
        
        -- Tab-Wiederherstellung: Wenn zuletzt Kollektionen offen war, wiederherstellen
        if DreamHouse.Hooks.Storage.lastSelectedTab == "collections" and DreamHouse.Hooks.Storage.collectionsTabID then
            C_Timer.After(0.05, function()
                if storageFrame.TabSystem and storageFrame.SetTab then
                    storageFrame:SetTab(DreamHouse.Hooks.Storage.collectionsTabID)
                    DreamHouse.Debug:Log("Hooks", "Kollektionen-Tab wiederhergestellt", "SUCCESS")
                end
            end)
        end
        
        -- Hotbar am Storage positionieren und anzeigen
        -- WICHTIG: Bei Ausklappen läuft eine 0.2s Animation
        if DreamHouse.Hotbar then
            if DreamHouse.Hooks.Storage.expandAnimationPending then
                -- Kam aus collapsed Zustand - Animation läuft!
                -- Hotbar kurz verstecken und nach Animation positionieren
                DreamHouse.Hotbar:Hide()
                DreamHouse.Debug:Log("Hooks", "OnShow: Expand-Animation läuft - warte...", "DEBUG")
                
                C_Timer.After(0.22, function()
                    if storageFrame:IsShown() and DreamHouse.Hotbar then
                        DreamHouse.Hotbar:OnStorageShown()
                        DreamHouse.Debug:Log("Hooks", "OnShow: Hotbar nach Animation positioniert", "DEBUG")
                    end
                end)
            else
                -- Erstes Öffnen oder keine Animation - sofort positionieren
                DreamHouse.Hotbar:OnStorageShown()
                DreamHouse.Debug:Log("Hooks", "OnShow: Hotbar sofort positioniert", "DEBUG")
            end
        end
    end)
    
    -- Flag um zu tracken ob gerade eine Expand-Animation läuft
    DreamHouse.Hooks.Storage.expandAnimationPending = false
    
    -- Hook für SetCollapsed - verhindert das "Mitgleiten" der Hotbar während der Animation
    if storageFrame.SetCollapsed then
        hooksecurefunc(storageFrame, "SetCollapsed", function(self, shouldCollapse)
            if shouldCollapse then
                -- Storage wird eingeklappt → Hotbar SOFORT vom Storage lösen
                -- Damit sie nicht mit der Slide-Animation mitgleitet
                DreamHouse.Debug:Log("Hooks", "SetCollapsed(true) - Löse Hotbar vom Storage", "DEBUG")
                DreamHouse.Hooks.Storage.expandAnimationPending = false
                
                if DreamHouse.Hotbar then
                    -- Hotbar an aktueller Position fixieren (verhindert Mitgleiten)
                    DreamHouse.Hotbar:FreezeAtCurrentPosition()
                    
                    -- Nach Animation (0.22s) an finale Position setzen (wenn StorageButton sichtbar ist)
                    C_Timer.After(0.22, function()
                        if DreamHouse.Hotbar then
                            DreamHouse.Hotbar:OnStorageCollapsed()
                        end
                    end)
                end
            else
                -- Storage wird ausgeklappt - Flag setzen für OnShow Hook
                DreamHouse.Debug:Log("Hooks", "SetCollapsed(false) - Expand Animation pending", "DEBUG")
                DreamHouse.Hooks.Storage.expandAnimationPending = true
                
                -- Flag nach Animation zurücksetzen
                C_Timer.After(0.25, function()
                    DreamHouse.Hooks.Storage.expandAnimationPending = false
                end)
            end
        end)
        DreamHouse.Debug:Log("Hooks", "SetCollapsed gehookt für sofortige Hotbar-Reaktion", "SUCCESS")
    end
    
    -- OnHide Hook - für Fälle wo Storage komplett versteckt wird (nicht nur eingeklappt)
    DreamHouse.Utils:SafeHookScript(storageFrame, "OnHide", function()
        DreamHouse.Debug:Log("Hooks", "Storage-Panel OnHide Event", "DEBUG")
        DreamHouse.Events:Fire("DREAMHOUSE_STORAGE_CLOSED")
        
        -- Unterscheide: Eingeklappt vs. komplett versteckt (Platzieren/Modi)
        -- Blizzard-Logik: Bei Collapse bleibt StorageButton sichtbar, bei Hide wird beides versteckt
        if DreamHouse.Hotbar then
            -- WICHTIG: Längere Verzögerung damit SetCollapsed Hook Zeit hat die Position zu setzen
            C_Timer.After(0.25, function()  -- Nach Animation (0.22s) + etwas Puffer
                local storageButton = HouseEditorFrame and HouseEditorFrame.StorageButton
                local isCollapsed = storageButton and storageButton:IsShown()
                local editorStillActive = HouseEditorFrame and HouseEditorFrame:IsShown()
                
                if not editorStillActive then
                    -- Editor geschlossen → Hotbar verstecken
                    DreamHouse.Hotbar:OnStorageHidden()
                    DreamHouse.Debug:Log("Hooks", "Editor geschlossen -> Hotbar versteckt", "DEBUG")
                elseif isCollapsed then
                    -- Storage wurde eingeklappt - SetCollapsed Hook hat bereits alles erledigt
                    -- Nichts tun, Position und Sichtbarkeit wurden bereits gesetzt
                    DreamHouse.Debug:Log("Hooks", "Storage eingeklappt (SetCollapsed hat es erledigt)", "DEBUG")
                else
                    -- Storage komplett versteckt (StorageButton auch weg) → Hotbar verstecken
                    DreamHouse.Hotbar:OnStorageHidden()
                    DreamHouse.Debug:Log("Hooks", "Storage versteckt (Platzieren/Modus) -> Hotbar versteckt", "DEBUG")
                end
            end)
        end
    end)
    
    -- WICHTIG: Prüfe aktuellen Status beim Hook
    if storageFrame:IsShown() then
        -- Storage ist sichtbar (nicht eingeklappt)
        DreamHouse.Debug:Log("Hooks", "Storage bereits sichtbar - aktiviere Features sofort!", "INFO")
        ActivateStorageFeatures()
    elseif HouseEditorFrame and HouseEditorFrame:IsShown() then
        -- Editor ist aktiv aber Storage ist eingeklappt
        local storageButton = HouseEditorFrame.StorageButton
        if storageButton and storageButton:IsShown() then
            DreamHouse.Debug:Log("Hooks", "Storage eingeklappt bei Start - Hotbar am Button positionieren!", "INFO")
            if DreamHouse.Hotbar then
                DreamHouse.Hotbar:AttachToStoragePanel(storageFrame)
                DreamHouse.Hotbar:OnStorageCollapsed()
            end
        end
    end
    
    -- Hook für Sucheingabe
    if storageFrame.SearchBox then
        DreamHouse.Utils:SafeHookScript(storageFrame.SearchBox, "OnTextChanged", function(self)
            local text = self:GetText()
            DreamHouse.Events:Fire("DREAMHOUSE_SEARCH_CHANGED", text)
        end)
        DreamHouse.Debug:Log("Hooks", "SearchBox gehookt", "DEBUG")
    end
end

function DreamHouse.Hooks.Storage:HookCatalogEntries()
    -- Bereits gehookt?
    if catalogEntriesHooked then 
        DreamHouse.Debug:Log("Hooks", "Katalog-Einträge bereits gehookt - überspringe", "DEBUG")
        return 
    end
    
    -- Hook für HousingCatalogEntryMixin (wenn verfügbar)
    if HousingCatalogEntryMixin then
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin gefunden - installiere Hooks...", "INFO")
        catalogEntriesHooked = true
        
        -- Hilfsfunktion um Buttons anzuhängen
        local function AttachButtonsToEntry(self)
            -- Nur prüfen ob self existiert - entryID kann später kommen
            if not self then return end
            
            -- Prüfen ob es ein gültiger Katalog-Eintrag ist (hat ModelScene oder Icon)
            if not self.ModelScene and not self.Icon then return end
            
            -- Favoriten-Button hinzufügen/aktualisieren
            if DreamHouse.Settings:IsFeatureEnabled("favorites") and DreamHouse.Favorites then
                DreamHouse.Favorites:AttachToEntry(self)
            end
            -- 3D-Vorschau-Button hinzufügen/aktualisieren
            if DreamHouse.PreviewButton then
                DreamHouse.PreviewButton:AttachToEntry(self)
            end
        end
        
        -- UpdateVisuals-Hook
        hooksecurefunc(HousingCatalogEntryMixin, "UpdateVisuals", function(self)
            AttachButtonsToEntry(self)
        end)
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.UpdateVisuals gehookt", "SUCCESS")
        
        -- OnShow-Hook
        hooksecurefunc(HousingCatalogEntryMixin, "OnShow", function(self)
            AttachButtonsToEntry(self)
        end)
        
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.OnShow gehookt", "SUCCESS")
        
        -- Init-Hook für neue Einträge (wird bei jedem Recycle aufgerufen!)
        hooksecurefunc(HousingCatalogEntryMixin, "Init", function(self, elementData)
            -- Favoriten-Button hinzufügen/aktualisieren
            if DreamHouse.Settings:IsFeatureEnabled("favorites") and DreamHouse.Favorites then
                DreamHouse.Favorites:AttachToEntry(self)
                -- State sofort aktualisieren mit neuer entryID!
                if self.dreamhouseFavButton and self.entryID then
                    self.dreamhouseFavButton:SetEntryID(self.entryID)
                end
            end
            -- 3D-Vorschau-Button hinzufügen/aktualisieren
            if DreamHouse.PreviewButton then
                DreamHouse.PreviewButton:AttachToEntry(self)
                -- State sofort aktualisieren mit neuen Daten
                if self.dreamhousePreviewButton then
                    self.dreamhousePreviewButton:SetEntryData(self.entryID, self.entryInfo)
                end
            end
            
            -- Entry-ID speichern
            if elementData then
                self.dreamhouseEntryData = elementData
            end
        end)
        
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.Init gehookt", "SUCCESS")
        
        -- UpdateEntryData Hook - wird aufgerufen wenn Item-Daten sich ändern
        hooksecurefunc(HousingCatalogEntryMixin, "UpdateEntryData", function(self, forceUpdate)
            -- Favoriten-Button State aktualisieren
            if self.dreamhouseFavButton and self.entryID then
                self.dreamhouseFavButton:SetEntryID(self.entryID)
            end
        end)
        
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.UpdateEntryData gehookt", "SUCCESS")
        
        -- Tooltip-Enhancement
        hooksecurefunc(HousingCatalogEntryMixin, "OnEnter", function(self)
            if DreamHouse.Settings:IsFeatureEnabled("tooltipsEnhanced") and DreamHouse.TooltipEnhancer then
                DreamHouse.TooltipEnhancer:Enhance(self)
            end
        end)
        
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.OnEnter gehookt", "SUCCESS")
        
        -- Drag-Start für Hotbar
        hooksecurefunc(HousingCatalogEntryMixin, "OnDragStart", function(self)
            if DreamHouse.Settings:IsFeatureEnabled("hotbar") and DreamHouse.Hotbar then
                DreamHouse.Hotbar:OnItemDragStart(self)
            end
        end)
        
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin.OnDragStart gehookt", "SUCCESS")
    end
    
    -- Hook für ScrollingHousingCatalogMixin - durchläuft alle sichtbaren Frames nach Daten-Update
    if ScrollingHousingCatalogMixin then
        -- Hook SetCatalogElements - wird aufgerufen wenn Daten geladen werden
        hooksecurefunc(ScrollingHousingCatalogMixin, "SetCatalogElements", function(self, catalogElements, retainCurrentPosition)
            -- Kurze Verzögerung damit die Frames erstellt sind
            C_Timer.After(0.1, function()
                if self.ScrollBox then
                    for _, frame in self.ScrollBox:EnumerateFrames() do
                        if frame and (frame.ModelScene or frame.Icon) then
                            -- Favoriten-Button
                            if DreamHouse.Settings:IsFeatureEnabled("favorites") and DreamHouse.Favorites then
                                DreamHouse.Favorites:AttachToEntry(frame)
                            end
                            -- Preview-Button
                            if DreamHouse.PreviewButton then
                                DreamHouse.PreviewButton:AttachToEntry(frame)
                            end
                        end
                    end
                    DreamHouse.Debug:Log("Hooks", "Buttons an ScrollBox-Frames angehängt", "SUCCESS")
                end
            end)
        end)
        DreamHouse.Debug:Log("Hooks", "ScrollingHousingCatalogMixin.SetCatalogElements gehookt", "SUCCESS")
        
        -- Hook RefreshFrames - wird aufgerufen bei Updates
        hooksecurefunc(ScrollingHousingCatalogMixin, "RefreshFrames", function(self)
            if self.ScrollBox then
                for _, frame in self.ScrollBox:EnumerateFrames() do
                    if frame and (frame.ModelScene or frame.Icon) then
                        if DreamHouse.Settings:IsFeatureEnabled("favorites") and DreamHouse.Favorites then
                            DreamHouse.Favorites:AttachToEntry(frame)
                        end
                        if DreamHouse.PreviewButton then
                            DreamHouse.PreviewButton:AttachToEntry(frame)
                        end
                    end
                end
            end
        end)
        DreamHouse.Debug:Log("Hooks", "ScrollingHousingCatalogMixin.RefreshFrames gehookt", "SUCCESS")
    else
        DreamHouse.Debug:Log("Hooks", "ScrollingHousingCatalogMixin nicht gefunden!", "WARN")
    end
    
    -- Hook für Kontextmenü - wir ersetzen es komplett um unsere Options hinzuzufügen
    if HousingCatalogDecorEntryMixin then
        local originalShowContextMenu = HousingCatalogDecorEntryMixin.ShowContextMenu
        
        HousingCatalogDecorEntryMixin.ShowContextMenu = function(self)
            -- WICHTIG: Prüfe ob entryInfo existiert!
            if not self.entryInfo then
                DreamHouse.Debug:Log("Context", "ShowContextMenu: entryInfo ist nil!", "WARN")
                return
            end
            
            local totalInStorage = (self.entryInfo.quantity or 0) + (self.entryInfo.remainingRedeemable or 0)
            local hasItemsInStorage = totalInStorage > 0
            
            -- Prüfen ob wir in der Behausungsübersicht (Dashboard) sind
            local isInDashboard = HousingDashboardFrame and HousingDashboardFrame:IsShown() and 
                                  DoesAncestryInclude(HousingDashboardFrame, self)
            
            DreamHouse.Debug:Log("Context", string.format("ShowContextMenu: Dashboard=%s, Items=%d, Entry=%s", 
                tostring(isInDashboard), totalInStorage, self.entryInfo.name or "?"), "DEBUG")
            
            -- Im Editor: Kein Menü wenn keine Items UND kein Bundle/Market
            -- Im Dashboard: Menü immer erlauben für "Quelle auf Karte"
            if not isInDashboard then
                if not hasItemsInStorage then
                    return
                end
                
                if self:IsBundleItem() or self:IsInMarketView() then
                    return
                end
            end
            
            local canDestroyEntry = hasItemsInStorage and C_HousingCatalog.CanDestroyEntry(self.entryID)
            
            local showDisabledTooltip = function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY)
            end
            
            MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                rootDescription:SetTag("MENU_HOUSING_CATALOG_ENTRY")
                
                -- ========== DREAMHOUSE OPTIONS ==========
                
                -- Quelle auf Karte zeigen (IMMER verfügbar - auch für Items die man nicht hat!)
                local canShowOnMap, mapReason = DreamHouse.Hooks.Storage:CanShowSourceOnMap(self.entryID)
                local mapButtonDesc = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["[DH] Show source on map"], function()
                    DreamHouse.Hooks.Storage:ShowSourceOnMap(self.entryID, self.entryInfo)
                end)
                
                if not canShowOnMap then
                    mapButtonDesc:SetEnabled(false)
                    mapButtonDesc:SetTooltip(function(tooltip, elementDescription)
                        GameTooltip_SetTitle(tooltip, L["No map position available"])
                        if mapReason == "nicht_trackbar" then
                            GameTooltip_AddNormalLine(tooltip, L["Item not in database"])
                            GameTooltip_AddHighlightLine(tooltip, L["Visit vendor tip"])
                            GameTooltip_AddHighlightLine(tooltip, L["Visit vendor tip2"])
                        elseif mapReason == "keine_map" then
                            GameTooltip_AddNormalLine(tooltip, L["No map position for item"])
                        else
                            GameTooltip_AddNormalLine(tooltip, L["Source cannot be shown on map"])
                        end
                    end)
                end
                
                -- Favorit hinzufügen/entfernen
                if DreamHouse.Settings:IsFeatureEnabled("favorites") and DreamHouse.Favorites then
                    local isFav = DreamHouse.Favorites:IsFavorite(self.entryID)
                    local favText = isFav and ("|cff00ccff[DH]|r " .. L["[DH] Remove Favorite"]) or ("|cff00ccff[DH]|r " .. L["[DH] Mark as Favorite"])
                    rootDescription:CreateButton(favText, function()
                        DreamHouse.Favorites:SetFavorite(self.entryID, not isFav)
                    end)
                end
                
                -- Schnellleiste: Nur wenn Item im Besitz ist
                if hasItemsInStorage and DreamHouse.Settings:IsFeatureEnabled("hotbar") and DreamHouse.Hotbar then
                    local isInHotbar, slotIndex = DreamHouse.Hotbar:IsItemInHotbar(self.entryID)
                    local isCHMActive = DreamHouse.Hooks.Storage.collectionHotbarModeActive
                    
                    if isInHotbar then
                        local removeBtn = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["[DH] Remove from Hotbar"], function()
                            if isCHMActive then return end -- Blockieren wenn KHM aktiv
                            local success = DreamHouse.Hotbar:RemoveItemByEntryID(self.entryID)
                            if success then
                                DreamHouse.Debug:Log("Hotbar", "Item via Kontextmenü entfernt", "SUCCESS")
                            end
                        end)
                        -- Ausgegraut wenn KHM aktiv
                        if isCHMActive then
                            removeBtn:SetEnabled(false)
                            removeBtn:SetTooltip(function(tooltip, elementDescription)
                                tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
                                tooltip:SetFrameLevel(9999)
                                GameTooltip_SetTitle(tooltip, L["CHM active - disable first"])
                            end)
                        end
                    else
                        -- Hauptbutton: Klick = nächster freier Slot
                        local entryID = self.entryID
                        local addBtn = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["[DH] Add to Hotbar"], function()
                            if isCHMActive then return end
                            local success = DreamHouse.Hotbar:AddItem(entryID)
                            if success then
                                DreamHouse.Debug:Log("Hotbar", "Item via Kontextmenü hinzugefügt (freier Slot)", "SUCCESS")
                            end
                        end)
                        
                        if isCHMActive then
                            addBtn:SetEnabled(false)
                            addBtn:SetTooltip(function(tooltip, elementDescription)
                                tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
                                tooltip:SetFrameLevel(9999)
                                GameTooltip_SetTitle(tooltip, L["CHM active - disable first"])
                            end)
                        else
                            -- Submenu für spezifische Slot-Auswahl
                            addBtn:CreateTitle(L["Select Slot"])
                            
                            -- Slots 1-10 einzeln
                            for i = 1, 10 do
                                local slotNum = i == 10 and "0" or tostring(i)
                                local slotData = DreamHouse.Hotbar:GetSlotData(i)
                                local slotText = L["Slot"] .. " " .. slotNum
                                
                                -- Zeige was aktuell im Slot ist
                                if slotData and slotData.entryID then
                                    local itemName = slotData.itemName or "?"
                                    if #itemName > 15 then
                                        itemName = itemName:sub(1, 15) .. "..."
                                    end
                                    slotText = slotText .. " |cff888888(" .. itemName .. ")|r"
                                else
                                    slotText = slotText .. " |cff00ff00(" .. L["Empty"] .. ")|r"
                                end
                                
                                local slotIndex = i
                                addBtn:CreateButton(slotText, function()
                                    DreamHouse.Hotbar:SetSlotItem(slotIndex, entryID)
                                    DreamHouse.Debug:Log("Hotbar", "Item via Kontextmenü in Slot " .. slotIndex .. " gesetzt", "SUCCESS")
                                    PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED)
                                end)
                            end
                        end
                    end
                end
                
                -- Kollektion: Zu Kollektion hinzufügen (Submenu)
                if DreamHouse.Collections then
                    local collections = DreamHouse.Collections:GetAllCollections() or {}
                    
                    if #collections > 0 then
                        local collectionSubmenu = rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["[DH] Add to Collection"])
                        
                        for _, collection in ipairs(collections) do
                            -- Prüfen ob Item bereits in Kollektion
                            local isInCollection = DreamHouse.Collections:IsItemInCollection(collection.id, self.entryID)
                            local displayName = isInCollection and ("|cff00ff00" .. collection.name .. "|r |cff888888(enthalten)|r") or collection.name
                            
                            collectionSubmenu:CreateButton(displayName, function()
                                if isInCollection then
                                    -- Item entfernen
                                    DreamHouse.Collections:RemoveItemFromCollection(collection.id, self.entryID)
                                    DreamHouse.Debug:Log("Collections", "Item aus Kollektion entfernt: " .. collection.name, "SUCCESS")
                                else
                                    -- Item hinzufügen
                                    DreamHouse.Collections:AddItemToCollection(collection.id, self.entryID)
                                    DreamHouse.Debug:Log("Collections", "Item zu Kollektion hinzugefügt: " .. collection.name, "SUCCESS")
                                end
                            end)
                        end
                        
                        -- Trennlinie und neue Kollektion erstellen
                        collectionSubmenu:CreateDivider()
                        collectionSubmenu:CreateButton("|cffffd100+ " .. L["Create new collection"], function()
                            DreamHouse.Hooks.Storage:ShowCreateCollectionDialog(self.entryID)
                        end)
                    else
                        -- Keine Kollektionen vorhanden - direkt neue erstellen anbieten
                        rootDescription:CreateButton("|cff00ccff[DH]|r " .. L["[DH] Add to Collection"] .. " |cff888888(" .. L["Create new collection"] .. ")|r", function()
                            DreamHouse.Hooks.Storage:ShowCreateCollectionDialog(self.entryID)
                        end)
                    end
                end
                
                -- ========== ORIGINAL BLIZZARD OPTIONS (nur wenn Items im Besitz) ==========
                if hasItemsInStorage and not self:IsBundleItem() and not self:IsInMarketView() then
                    -- Trennlinie
                    rootDescription:CreateDivider()
                    
                    local destroySingleButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY, function()
                        local popupData = {
                            destroyAll = false,
                            owner = self,
                            confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
                        }
                        local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)
                        StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData)
                    end)
                    destroySingleButtonDesc:SetEnabled(canDestroyEntry)
                    if not canDestroyEntry then
                        destroySingleButtonDesc:SetTooltip(showDisabledTooltip)
                    end
                    
                    if self.entryInfo.quantity > 1 then
                        local destroyAllButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_STORAGE_ITEM_DESTROY_ALL, function()
                            local popupData = {
                                destroyAll = true,
                                owner = self,
                                confirmationString = HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING,
                            }
                            local promptText = string.format(HOUSING_DECOR_STORAGE_ITEM_CONFIRM_DESTROY_ALL, self.entryInfo.quantity, self.entryInfo.name, HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)
                            StaticPopup_Show("CONFIRM_DESTROY_DECOR", promptText, nil, popupData)
                        end)
                        destroyAllButtonDesc:SetEnabled(canDestroyEntry)
                        if not canDestroyEntry then
                            destroyAllButtonDesc:SetTooltip(showDisabledTooltip)
                        end
                    end
                end
            end)
        end
        
        DreamHouse.Debug:Log("Hooks", "Kontextmenü erweitert (Editor + Dashboard)", "SUCCESS")
    else
        -- Wenn nicht sofort verfügbar, später nochmal versuchen
        DreamHouse.Debug:Log("Hooks", "HousingCatalogEntryMixin noch nicht verfügbar - warte...", "WARN")
        
        C_Timer.After(1, function()
            if HousingCatalogEntryMixin then
                DreamHouse.Hooks.Storage:HookCatalogEntries()
            end
        end)
    end
end

-- ============================================
-- KOLLEKTIONEN-TAB Feature
-- ============================================

-- Flag um zu tracken ob wir im Kollektionen-Modus sind
DreamHouse.Hooks.Storage.isInCollectionsMode = false
DreamHouse.Hooks.Storage.collectionsTabID = nil

-- Fügt den Kollektionen-Tab zum Storage-Panel hinzu
function DreamHouse.Hooks.Storage:AddCollectionsTab(storageFrame)
    if not storageFrame or not storageFrame.TabSystem then
        DreamHouse.Debug:Log("Collections", "Kann Tab nicht hinzufügen - TabSystem nicht verfügbar", "ERROR")
        return
    end
    
    -- Prüfe ob Tab bereits existiert
    if self.collectionsTabID then
        DreamHouse.Debug:Log("Collections", "Kollektionen-Tab bereits vorhanden", "DEBUG")
        return
    end
    
    -- Speichere Original-Tab-IDs
    self.storageTabID = storageFrame.storageTabID
    self.marketTabID = storageFrame.marketTabID
    DreamHouse.Debug:Log("Collections", "Gespeicherte Tab-IDs: storage=" .. tostring(self.storageTabID) .. ", market=" .. tostring(self.marketTabID), "DEBUG")
    
    -- Hooke die Original-Callbacks um Kollektionen-Modus zu beenden
    if storageFrame.storageTabID then
        local originalStorageCallback = storageFrame.internalTabTracker.tabIDToTabCallback[storageFrame.storageTabID]
        storageFrame:SetTabCallback(storageFrame.storageTabID, function()
            DreamHouse.Debug:Log("Collections", "Lager-Tab Callback aufgerufen!", "INFO")
            -- Erst Kollektionen-Modus beenden
            if DreamHouse.Hooks.Storage.isInCollectionsMode then
                DreamHouse.Hooks.Storage:ExitCollectionsMode()
            end
            -- Dann Original-Callback
            if originalStorageCallback then
                originalStorageCallback()
            end
        end)
        DreamHouse.Debug:Log("Collections", "Lager-Tab Callback gehookt", "SUCCESS")
    end
    
    if storageFrame.marketTabID then
        local originalMarketCallback = storageFrame.internalTabTracker.tabIDToTabCallback[storageFrame.marketTabID]
        storageFrame:SetTabCallback(storageFrame.marketTabID, function()
            DreamHouse.Debug:Log("Collections", "Markt-Tab Callback aufgerufen!", "INFO")
            -- Erst Kollektionen-Modus beenden
            if DreamHouse.Hooks.Storage.isInCollectionsMode then
                DreamHouse.Hooks.Storage:ExitCollectionsMode()
            end
            -- Dann Original-Callback
            if originalMarketCallback then
                originalMarketCallback()
            end
        end)
        DreamHouse.Debug:Log("Collections", "Markt-Tab Callback gehookt", "SUCCESS")
    end
    
    -- Tab-Namen aus Lokalisierung
    local tabName = L["Collections"]
    
    -- Neuen Tab hinzufügen - nach "Lager" und "Markt"
    -- AddNamedTab gibt die tabID zurück
    self.collectionsTabID = storageFrame:AddNamedTab(tabName)
    
    -- Callback für Tab-Auswahl setzen
    storageFrame:SetTabCallback(self.collectionsTabID, function()
        self:OnCollectionsTabSelected(storageFrame)
    end)
    
    DreamHouse.Debug:Log("Collections", "Kollektionen-Tab hinzugefügt (ID: " .. tostring(self.collectionsTabID) .. ")", "SUCCESS")
    
    -- Speichere Referenz zum StorageFrame für späteren Zugriff
    self.hookedStorageFrame = storageFrame
end

-- Wird aufgerufen wenn der Kollektionen-Tab ausgewählt wird
function DreamHouse.Hooks.Storage:OnCollectionsTabSelected(storageFrame)
    DreamHouse.Debug:Log("Collections", "Kollektionen-Tab ausgewählt!", "INFO")
    
    self.isInCollectionsMode = true
    self.lastSelectedTab = "collections" -- Für Wiederherstellung beim Öffnen
    
    -- Alle Storage-UI-Elemente verstecken und mit Hooks absichern
    local elementsToHide = {
        {frame = storageFrame.Filters, name = "Filters"},
        {frame = storageFrame.SearchBox, name = "SearchBox"},
        {frame = storageFrame.Categories, name = "Categories"},
        {frame = storageFrame.OptionsContainer, name = "OptionsContainer"},
    }
    
    for _, element in ipairs(elementsToHide) do
        if element.frame then
            element.frame:Hide()
            
            -- Hook um es versteckt zu halten wenn Blizzard es wieder zeigen will
            local hookKey = element.name .. "Hooked"
            if not self[hookKey] then
                hooksecurefunc(element.frame, "Show", function()
                    if self.isInCollectionsMode then
                        element.frame:Hide()
                    end
                end)
                self[hookKey] = true
            end
        end
    end
    
    -- Header-Text "Kollektionen" anzeigen
    self:ShowCollectionsHeader(storageFrame)
    
    -- Eigenes Kollektionen-UI erstellen/anzeigen
    self:ShowCollectionsUI(storageFrame)
    
    DreamHouse.Events:Fire("DREAMHOUSE_COLLECTIONS_TAB_SELECTED")
end

-- Zeigt den "Kollektionen" Header-Text im gelb/schwarzen Bereich
function DreamHouse.Hooks.Storage:ShowCollectionsHeader(storageFrame)
    if not storageFrame then return end
    
    -- Header-Text erstellen falls noch nicht vorhanden oder ungültig
    local needsRecreate = false
    if not self.collectionsHeaderText then
        needsRecreate = true
    elseif not self.collectionsHeaderText.GetParent then
        needsRecreate = true
    elseif not self.collectionsHeaderText:GetParent() then
        needsRecreate = true
    end
    
    if needsRecreate then
        self.collectionsHeaderText = nil
        
        -- "BonusLoot-Chest" Icon VOR dem Text (für Listenansicht)
        local listHeaderIcon = storageFrame:CreateTexture(nil, "ARTWORK")
        listHeaderIcon:SetSize(16, 16)
        listHeaderIcon:SetPoint("LEFT", storageFrame, "LEFT", 8, 0)
        listHeaderIcon:SetPoint("TOP", storageFrame, "TOP", 0, -26)
        listHeaderIcon:SetAtlas("BonusLoot-Chest")
        listHeaderIcon:Hide()
        self.listHeaderIcon = listHeaderIcon
        
        -- Kollektion-Icon Button (nur in Set-Ansicht sichtbar, klickbar zum Ändern)
        -- Exakt gleiche Position und Größe wie listHeaderIcon
        local collectionIconBtn = CreateFrame("Button", nil, storageFrame)
        collectionIconBtn:SetSize(16, 16)
        collectionIconBtn:SetPoint("LEFT", storageFrame, "LEFT", 8, 0)
        collectionIconBtn:SetPoint("TOP", storageFrame, "TOP", 0, -26)
        collectionIconBtn:SetFrameLevel(storageFrame:GetFrameLevel() + 50) -- Über allem anderen
        collectionIconBtn:Hide()
        
        local collectionIcon = collectionIconBtn:CreateTexture(nil, "ARTWORK")
        collectionIcon:SetAllPoints()
        collectionIconBtn.icon = collectionIcon
        
        -- Highlight bei Hover
        local iconHighlight = collectionIconBtn:CreateTexture(nil, "HIGHLIGHT")
        iconHighlight:SetAllPoints()
        iconHighlight:SetColorTexture(1, 1, 1, 0.2)
        
        -- Klickbar zum Icon ändern
        collectionIconBtn:SetScript("OnClick", function()
            DreamHouse.Debug:Log("Collections", "Header-Icon geklickt", "DEBUG")
            if DreamHouse.Hooks.Storage.currentCollection then
                DreamHouse.Hooks.Storage:ShowChangeIconDialog(DreamHouse.Hooks.Storage.currentCollection)
            end
        end)
        collectionIconBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Change icon"])
            GameTooltip:Show()
        end)
        collectionIconBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        self.collectionHeaderIcon = collectionIconBtn
        
        -- Klickbarer "Kollektionen" Button mit unterstrichen Text (in Listenansicht neben BonusLoot-Icon)
        local headerBtn = CreateFrame("Button", nil, storageFrame)
        headerBtn:SetPoint("LEFT", listHeaderIcon, "RIGHT", 3, 0)
        
        local header = headerBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header:SetPoint("LEFT", 0, 0)
        header:SetText(L["Collections"])
        header:SetTextColor(1, 0.82, 0)  -- Gold wie andere Header
        self.collectionsHeaderText = header
        
        -- Button-Größe an Text anpassen
        headerBtn:SetSize(header:GetStringWidth() + 4, header:GetStringHeight() + 4)
        
        -- Unterstreichung (dicker, immer sichtbar)
        local underline = headerBtn:CreateTexture(nil, "ARTWORK")
        underline:SetHeight(2)
        underline:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, -3)
        underline:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, -3)
        underline:SetColorTexture(1, 0.82, 0, 0.9)
        self.headerUnderline = underline -- Immer sichtbar
        
        -- Klick-Handler: Zurück zur Liste
        headerBtn:SetScript("OnClick", function()
            if DreamHouse.Hooks.Storage.currentCollection then
                DreamHouse.Hooks.Storage:CloseCollection()
            end
        end)
        
        -- Hover-Effekt (nur wenn in Set)
        headerBtn:SetScript("OnEnter", function(self)
            if DreamHouse.Hooks.Storage.currentCollection then
                header:SetTextColor(1, 1, 0.6) -- Heller beim Hover
            end
        end)
        headerBtn:SetScript("OnLeave", function(self)
            header:SetTextColor(1, 0.82, 0)
        end)
        
        self.collectionsHeaderBtn = headerBtn
        
        -- Breadcrumb-Pfeil (horizontal gespiegelt, dichter)
        local arrow = storageFrame:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(14, 14)
        arrow:SetPoint("LEFT", header, "RIGHT", 4, 0)
        arrow:SetAtlas("CovenantSanctum-Renown-Arrow-Depressed")
        arrow:SetTexCoord(1, 0, 0, 1) -- Horizontal spiegeln (zeigt jetzt nach rechts)
        arrow:Hide()
        self.breadcrumbArrow = arrow
        
        -- Set-Name (direkt neben dem Kollektion-Icon in Set-Ansicht)
        local setName = storageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        setName:SetPoint("LEFT", collectionIconBtn, "RIGHT", 3, 0)
        setName:SetTextColor(1, 0.82, 0)
        setName:Hide()
        self.collectionNameText = setName
        
        -- Zurück-Pfeil rechts im Header (nur in Set-Ansicht)
        local backArrow = CreateFrame("Button", nil, storageFrame)
        backArrow:SetSize(24, 24)
        backArrow:SetPoint("RIGHT", storageFrame, "RIGHT", -14, 0)
        backArrow:SetPoint("TOP", storageFrame, "TOP", 0, -22)
        
        local backArrowTex = backArrow:CreateTexture(nil, "ARTWORK")
        backArrowTex:SetAllPoints()
        backArrowTex:SetAtlas("poi-traveldirections-arrow2")
        backArrow.texture = backArrowTex
        
        -- Hover-Effekt
        backArrow:SetScript("OnEnter", function(self)
            self.texture:SetVertexColor(1, 1, 0.6)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(L["Back to list"])
            GameTooltip:Show()
        end)
        backArrow:SetScript("OnLeave", function(self)
            self.texture:SetVertexColor(1, 1, 1)
            GameTooltip:Hide()
        end)
        
        -- Klick: Zurück zur Liste
        backArrow:SetScript("OnClick", function()
            DreamHouse.Hooks.Storage:CloseCollection()
        end)
        
        backArrow:Hide()
        self.headerBackArrow = backArrow
        
        -- Settings-Button (links neben dem Zurückpfeil) - Toggle für Kollektions-Hotbar-Modus
        local settingsBtn = CreateFrame("Button", nil, storageFrame)
        settingsBtn:SetSize(24, 24)
        settingsBtn:SetPoint("RIGHT", backArrow, "LEFT", -2, 0)
        settingsBtn:SetNormalAtlas("decor-controls-settings-default")
        settingsBtn:SetPushedAtlas("decor-controls-settings-pressed")
        settingsBtn.isActive = false
        
        -- Aktiv-Textur (wird über Normal-Textur gelegt wenn aktiv)
        local activeTex = settingsBtn:CreateTexture(nil, "OVERLAY")
        activeTex:SetAllPoints()
        activeTex:SetAtlas("decor-controls-settings-active")
        activeTex:Hide()
        settingsBtn.activeTex = activeTex
        
        settingsBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if self.isActive then
                GameTooltip:SetText(L["Collection Hotbar Mode"] .. " |cff00ff00(" .. L["Active"] .. ")|r")
                GameTooltip:AddLine(L["Click to deactivate"], 0.7, 0.7, 0.7)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["Shift+Scroll to cycle collections"], 0.4, 0.8, 1)
            else
                GameTooltip:SetText(L["Collection Hotbar Mode"])
                GameTooltip:AddLine(L["Click to activate"], 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
        end)
        settingsBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        settingsBtn:SetScript("OnClick", function(self)
            DreamHouse.Hooks.Storage:ToggleCollectionHotbarMode()
            -- Tooltip sofort aktualisieren wenn noch sichtbar
            if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
                GameTooltip:ClearLines()
                if self.isActive then
                    GameTooltip:SetText(L["Collection Hotbar Mode"] .. " |cff00ff00(" .. L["Active"] .. ")|r")
                    GameTooltip:AddLine(L["Click to deactivate"], 0.7, 0.7, 0.7)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(L["Shift+Scroll to cycle collections"], 0.4, 0.8, 1)
                else
                    GameTooltip:SetText(L["Collection Hotbar Mode"])
                    GameTooltip:AddLine(L["Click to activate"], 0.7, 0.7, 0.7)
                end
                GameTooltip:Show()
            end
        end)
        
        self.headerSettingsBtn = settingsBtn
        
        -- Nur initialisieren wenn noch nicht gesetzt (damit Reload-Wert nicht überschrieben wird)
        if self.collectionHotbarModeActive == nil then
            self.collectionHotbarModeActive = false
        end
    end
    
    -- Button-Zustand aus gespeichertem Wert wiederherstellen
    if self.headerSettingsBtn and self.collectionHotbarModeActive then
        self.headerSettingsBtn.isActive = true
        self.headerSettingsBtn.activeTex:Show()
    end
    
    -- Button anzeigen (enthält den Header-Text)
    if self.collectionsHeaderBtn then
        self.collectionsHeaderBtn:Show()
    end
    -- BonusLoot-Chest Icon zeigen (Listenansicht)
    if self.listHeaderIcon then
        self.listHeaderIcon:Show()
    end
end

-- Versteckt den Kollektionen Header-Text
function DreamHouse.Hooks.Storage:HideCollectionsHeader()
    if self.collectionsHeaderBtn then
        self.collectionsHeaderBtn:Hide()
    end
    -- Kollektion-Icon verstecken
    if self.collectionHeaderIcon then
        self.collectionHeaderIcon:Hide()
    end
    -- BonusLoot-Chest Icon verstecken
    if self.listHeaderIcon then
        self.listHeaderIcon:Hide()
    end
    -- Auch Breadcrumb-Elemente verstecken
    if self.breadcrumbArrow then
        self.breadcrumbArrow:Hide()
    end
    if self.collectionNameText then
        self.collectionNameText:Hide()
    end
    -- Zurück-Pfeil verstecken
    if self.headerBackArrow then
        self.headerBackArrow:Hide()
    end
    -- Settings-Button verstecken
    if self.headerSettingsBtn then
        self.headerSettingsBtn:Hide()
    end
    -- Add-Button im Header verstecken
    if self.headerAddButton then
        self.headerAddButton:Hide()
    end
    -- Suchleisten verstecken
    if self.listSearchBox then
        self.listSearchBox:Hide()
        self.listSearchBox:SetText("")
    end
    if self.detailSearchBox then
        self.detailSearchBox:Hide()
        self.detailSearchBox:SetText("")
    end
    self.listSearchText = ""
    self.detailSearchText = ""
end

-- ============================================
-- KOLLEKTIONEN-UI
-- ============================================

-- Erstellt oder zeigt das Kollektionen-UI an
function DreamHouse.Hooks.Storage:ShowCollectionsUI(storageFrame)
    if not storageFrame then return end
    
    -- Container für Kollektionen-UI erstellen (falls nicht vorhanden oder ungültig nach Reload)
    -- Prüfe ob Container noch existiert und gültig ist
    local needsRecreate = false
    if not self.collectionsContainer then
        needsRecreate = true
    elseif not self.collectionsContainer.GetParent then
        -- Ungültige Referenz nach Reload
        needsRecreate = true
    elseif not self.collectionsContainer:GetParent() then
        -- Container hat keinen Parent mehr
        needsRecreate = true
    end
    
    if needsRecreate then
        self.collectionsContainer = nil  -- Reset
        self:CreateCollectionsContainer(storageFrame)
    end
    
    -- Container positionieren - unter dem Header-Bereich (wie OptionsContainer)
    self.collectionsContainer:SetParent(storageFrame)
    self.collectionsContainer:ClearAllPoints()
    -- Gleiche Position wie OptionsContainer: unter HeaderBackground
    if storageFrame.HeaderBackground then
        self.collectionsContainer:SetPoint("TOPLEFT", storageFrame.HeaderBackground, "BOTTOMLEFT", 5, -5)
    else
        self.collectionsContainer:SetPoint("TOPLEFT", storageFrame, "TOPLEFT", 5, -68)
    end
    self.collectionsContainer:SetPoint("BOTTOMRIGHT", storageFrame, "BOTTOMRIGHT", -5, 10)
    self.collectionsContainer:Show()
    
    -- Inhalt aktualisieren
    self:UpdateCollectionsUI()
    
    -- Settings-Button im Header anzeigen (für Kollektions-Hotbar-Modus)
    if self.headerSettingsBtn then
        self.headerSettingsBtn:Show()
    end
    
    DreamHouse.Debug:Log("Collections", "Kollektionen-UI angezeigt", "DEBUG")
end

-- Erstellt den Kollektionen-Container mit allen UI-Elementen
function DreamHouse.Hooks.Storage:CreateCollectionsContainer(storageFrame)
    -- Hauptcontainer
    local container = CreateFrame("Frame", "DreamHouseCollectionsContainer", storageFrame)
    container:SetFrameLevel(storageFrame:GetFrameLevel() + 10)
    
    -- Subtile Hintergrund-Textur (füllt komplett aus, auch Ränder)
    local bgTexture = container:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetPoint("TOPLEFT", container, "TOPLEFT", -5, 5)
    bgTexture:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 5, -5)
    bgTexture:SetAtlas("Garr_InfoBoxMission-BackgroundTile")
    bgTexture:SetAlpha(0.28) -- Etwas transparenter
    bgTexture:SetHorizTile(true)
    bgTexture:SetVertTile(true)
    container.bgTexture = bgTexture
    
    -- KEIN separater Titel - der Header-Bereich des Storage-Panels wird genutzt
    
    -- Leere-Ansicht Container (wenn keine Kollektionen vorhanden)
    local emptyView = CreateFrame("Frame", nil, container)
    emptyView:SetAllPoints()
    container.emptyView = emptyView
    
    -- "+" Button für neue Kollektion
    local addButton = CreateFrame("Button", "DreamHouseAddCollectionButton", emptyView)
    addButton:SetSize(100, 100)
    addButton:SetPoint("CENTER", emptyView, "CENTER", 0, 20)
    
    -- Button-Icon
    addButton:SetNormalAtlas("AnimCreate_Icon_Add")
    addButton:SetPushedAtlas("AnimCreate_Icon_Add")
    addButton:GetPushedTexture():SetAlpha(0.7)
    
    -- Button-Funktionalität
    addButton:SetScript("OnClick", function()
        DreamHouse.Debug:Log("Collections", "Neue Kollektion erstellen geklickt", "INFO")
        DreamHouse.Hooks.Storage:ShowCreateCollectionDialog()
    end)
    
    addButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Create new collection"])
        GameTooltip:AddLine(L["Click to create your first collection"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    
    addButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    container.addButton = addButton
    
    -- Info-Text unter dem Button
    local infoText = emptyView:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoText:SetPoint("TOP", addButton, "BOTTOM", 0, -20)
    infoText:SetText(L["No collections yet"])
    infoText:SetTextColor(0.7, 0.7, 0.7)
    container.infoText = infoText
    
    local subText = emptyView:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subText:SetPoint("TOP", infoText, "BOTTOM", 0, -8)
    subText:SetText(L["Create a collection to organize your decor"])
    subText:SetTextColor(0.5, 0.5, 0.5)
    container.subText = subText
    
    -- Kollektionen-Liste Container (wenn Kollektionen vorhanden)
    local listView = CreateFrame("Frame", nil, container)
    listView:SetAllPoints()
    listView:Hide()  -- Standardmäßig versteckt
    container.listView = listView
    
    -- ScrollFrame für Kollektionen-Liste (einfaches ScrollFrame ohne doppelte Scrollbar)
    local scrollFrame = CreateFrame("ScrollFrame", nil, listView)
    scrollFrame:SetPoint("TOPLEFT", listView, "TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", listView, "BOTTOMRIGHT", -5, 5)
    scrollFrame:EnableMouseWheel(true)
    container.scrollFrame = scrollFrame
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(500)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)
    container.scrollChild = scrollChild
    
    -- Mausrad-Scrolling
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local step = 40
        local newScroll = current - (delta * step)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        self:SetVerticalScroll(newScroll)
    end)
    
    -- Moderne Scrollbar für Liste
    local listScrollBar = CreateFrame("EventFrame", nil, scrollFrame, "MinimalScrollBar")
    listScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -12, -3)
    listScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -12, 3)
    ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, listScrollBar)
    container.listScrollBar = listScrollBar
    
    -- Breite anpassen wenn scrollFrame Größe hat
    scrollFrame:SetScript("OnSizeChanged", function(self, width, height)
        scrollChild:SetWidth(width - 5)
    end)
    
    -- "+" Button im Header (gleiche Position wie Zurück-Pfeil in Set-Ansicht) - Parent ist storageFrame für Header-Platzierung
    local listAddButton = CreateFrame("Button", nil, storageFrame)
    listAddButton:SetSize(22, 22)
    -- Gleiche Position wie backArrow (ganz rechts im Header)
    listAddButton:SetPoint("RIGHT", storageFrame, "RIGHT", -14, 0)
    listAddButton:SetPoint("TOP", storageFrame, "TOP", 0, -22)
    listAddButton:SetFrameLevel(storageFrame:GetFrameLevel() + 20) -- Über allem anderen
    listAddButton:Hide() -- Nur in Listenansicht sichtbar
    
    -- Normal-Textur
    listAddButton:SetNormalAtlas("128-RedButton-Plus")
    -- Pressed-Textur (Animation beim Klicken)
    listAddButton:SetPushedAtlas("128-RedButton-Plus-Pressed")
    
    listAddButton:SetScript("OnClick", function()
        DreamHouse.Hooks.Storage:ShowCreateCollectionDialog()
    end)
    listAddButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Create new collection"])
        GameTooltip:Show()
    end)
    listAddButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    self.headerAddButton = listAddButton
    container.listAddButton = listAddButton
    
    -- Settings-Button Position anpassen (links vom Add-Button)
    self.headerSettingsBtn:ClearAllPoints()
    self.headerSettingsBtn:SetPoint("RIGHT", listAddButton, "LEFT", -2, 0)
    
    -- === SUCHLEISTE FÜR LISTENANSICHT ===
    local listSearchBox = CreateFrame("EditBox", nil, storageFrame, "SearchBoxTemplate")
    listSearchBox:SetSize(90, 18)
    listSearchBox:SetPoint("RIGHT", self.headerSettingsBtn, "LEFT", -4, 0)
    listSearchBox:SetFrameLevel(storageFrame:GetFrameLevel() + 20)
    listSearchBox:SetAutoFocus(false)
    listSearchBox:Hide()
    
    -- Placeholder-Text beim Tippen ausblenden + Suche bei X-Klick zurücksetzen
    listSearchBox:SetScript("OnTextChanged", function(self, userInput)
        local text = self:GetText()
        -- Placeholder (Instructions) ein-/ausblenden
        if self.Instructions then
            if text ~= "" then
                self.Instructions:Hide()
            else
                self.Instructions:Show()
            end
        end
        -- Immer filtern (auch bei X-Klick wo userInput=false aber Text leer ist)
        local searchText = text:lower()
        DreamHouse.Hooks.Storage.listSearchText = searchText
        DreamHouse.Hooks.Storage:FilterCollectionsList(searchText)
    end)
    listSearchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        if self.Instructions then self.Instructions:Show() end
        DreamHouse.Hooks.Storage.listSearchText = ""
        DreamHouse.Hooks.Storage:FilterCollectionsList("")
    end)
    
    self.listSearchBox = listSearchBox
    container.listSearchBox = listSearchBox
    
    -- === DETAIL ANSICHT (Set) ===
    -- Detail-Container (einfaches ScrollFrame ohne Template-Scrollbar)
    local detailContainer = CreateFrame("ScrollFrame", nil, container)
    detailContainer:SetPoint("TOPLEFT", 0, -5)
    detailContainer:SetPoint("BOTTOMRIGHT", -5, 5)
    detailContainer:Hide()
    detailContainer:EnableMouseWheel(true)
    self.detailContainer = detailContainer
    
    local detailScrollChild = CreateFrame("Frame", nil, detailContainer)
    detailScrollChild:SetSize(container:GetWidth() - 10, 800) -- Höhe für Inhalt
    detailContainer:SetScrollChild(detailScrollChild)
    self.detailScrollChild = detailScrollChild
    
    -- === SUCHLEISTE FÜR SET-ANSICHT (Items) ===
    -- Gleiche Größe und Position wie Listen-Suchleiste (relativ zum Settings-Button)
    local detailSearchBox = CreateFrame("EditBox", nil, storageFrame, "SearchBoxTemplate")
    detailSearchBox:SetSize(90, 18)
    detailSearchBox:SetPoint("RIGHT", self.headerSettingsBtn, "LEFT", -4, 0)
    detailSearchBox:SetFrameLevel(storageFrame:GetFrameLevel() + 20)
    detailSearchBox:SetAutoFocus(false)
    detailSearchBox:Hide()
    
    -- Placeholder-Text beim Tippen ausblenden + Suche bei X-Klick zurücksetzen
    detailSearchBox:SetScript("OnTextChanged", function(self, userInput)
        local text = self:GetText()
        -- Placeholder (Instructions) ein-/ausblenden
        if self.Instructions then
            if text ~= "" then
                self.Instructions:Hide()
            else
                self.Instructions:Show()
            end
        end
        -- Immer filtern (auch bei X-Klick wo userInput=false aber Text leer ist)
        local searchText = text:lower()
        DreamHouse.Hooks.Storage.detailSearchText = searchText
        if DreamHouse.Hooks.Storage.currentCollection then
            DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
        end
    end)
    detailSearchBox:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
        if self.Instructions then self.Instructions:Show() end
        DreamHouse.Hooks.Storage.detailSearchText = ""
        if DreamHouse.Hooks.Storage.currentCollection then
            DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
        end
    end)
    
    self.detailSearchBox = detailSearchBox
    container.detailSearchBox = detailSearchBox
    
    -- Mausrad-Scrolling
    detailContainer:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local step = 40
        local newScroll = current - (delta * step)
        newScroll = math.max(0, math.min(newScroll, maxScroll))
        self:SetVerticalScroll(newScroll)
    end)
    
    -- Moderne Scrollbar
    local scrollBar = CreateFrame("EventFrame", nil, detailContainer, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", detailContainer, "TOPRIGHT", -14, -3)
    scrollBar:SetPoint("BOTTOMLEFT", detailContainer, "BOTTOMRIGHT", -14, 3)
    ScrollUtil.InitScrollFrameWithScrollBar(detailContainer, scrollBar)
    self.detailScrollBar = scrollBar
    
    -- ===== DRAG & DROP SYSTEM FÜR KOLLEKTIONEN =====
    -- Drag-Icon (folgt der Maus während des Drags) - wie in der Hotbar
    local collectionDragIcon = CreateFrame("Frame", "DreamHouseCollectionDragIcon", UIParent, "BackdropTemplate")
    collectionDragIcon:SetSize(50, 50)
    collectionDragIcon:SetFrameStrata("TOOLTIP")
    collectionDragIcon:SetFrameLevel(500)
    collectionDragIcon:Hide()
    
    -- Hintergrund (wie Hotbar)
    local bgTex = collectionDragIcon:CreateTexture(nil, "BACKGROUND")
    bgTex:SetAllPoints()
    bgTex:SetColorTexture(0, 0, 0, 0.85)
    collectionDragIcon.bg = bgTex
    
    -- Dezenter Rand
    local borderTex = collectionDragIcon:CreateTexture(nil, "BORDER")
    borderTex:SetPoint("TOPLEFT", -1, 1)
    borderTex:SetPoint("BOTTOMRIGHT", 1, -1)
    borderTex:SetColorTexture(0.4, 0.35, 0.2, 0.8)
    collectionDragIcon.borderBg = borderTex
    
    -- Icon (mit Padding)
    local dragIconTex = collectionDragIcon:CreateTexture(nil, "ARTWORK")
    dragIconTex:SetPoint("TOPLEFT", 3, -3)
    dragIconTex:SetPoint("BOTTOMRIGHT", -3, 3)
    collectionDragIcon.icon = dragIconTex
    
    -- Goldener Rahmen wie beim Item
    local dragIconBorder = collectionDragIcon:CreateTexture(nil, "OVERLAY")
    dragIconBorder:SetAllPoints()
    dragIconBorder:SetAtlas("transmog-set-border-collected")
    collectionDragIcon.border = dragIconBorder
    
    self.collectionDragIcon = collectionDragIcon
    self.collectionDragData = nil
    self.collectionIsDragging = false
    self.collectionSlotButtons = {} -- Referenz zu allen Top 10 Slots für Drop-Target-Erkennung
    
    -- Responsive: Bei Größenänderung Layout neu berechnen
    container:SetScript("OnSizeChanged", function(self, width, height)
        -- ScrollChild-Breite anpassen
        if detailScrollChild then
            detailScrollChild:SetWidth(width - 25)
        end
        -- Wenn Kollektion offen, neu rendern
        local hooks = DreamHouse.Hooks.Storage
        if hooks.currentCollection and detailContainer:IsShown() then
            hooks:RenderCollectionDetails(hooks.currentCollection)
        end
        -- ListView auch anpassen
        if listView then
            listView:SetWidth(width)
        end
    end)
    
    -- Zurück-Button (im Header-Bereich)
    -- Wir platzieren ihn links vom Titel, wenn sichtbar
    -- WICHTIG: Parent muss der Header-Hintergrund sein, damit er beim Tab-Wechsel sichtbar bleibt/versteckt wird
    local headerParent = self.collectionsHeaderText and self.collectionsHeaderText:GetParent() or container
    local backBtn = CreateFrame("Button", nil, headerParent)
    backBtn:SetSize(32, 32)
    backBtn:SetPoint("RIGHT", self.collectionsHeaderText, "LEFT", -10, 0)
    backBtn:SetNormalAtlas("Navigation-BackArrow-Large")
    backBtn:SetHighlightAtlas("Navigation-BackArrow-Large")
    backBtn:GetHighlightTexture():SetAlpha(0.5)
    backBtn:Hide()
    backBtn:SetScript("OnClick", function()
        DreamHouse.Hooks.Storage:CloseCollection()
    end)
    self.backButton = backBtn
    
    self.collectionsContainer = container
    DreamHouse.Debug:Log("Collections", "Kollektionen-Container erstellt", "SUCCESS")
end

-- Aktualisiert das Kollektionen-UI basierend auf vorhandenen Kollektionen
function DreamHouse.Hooks.Storage:UpdateCollectionsUI()
    if not self.collectionsContainer then return end
    
    -- Nur aktualisieren wenn wir wirklich im Kollektionen-Tab sind
    if not self.isInCollectionsMode then return end
    
    -- Wenn wir in der Detail-Ansicht sind (Set-Ansicht), NUR die Liste aktualisieren aber nicht anzeigen
    local isInDetailView = self.detailContainer and self.detailContainer:IsShown()
    
    local collections = {}
    if DreamHouse.Collections then
        -- Sicherstellen dass Kollektionen geladen sind (falls Init noch nicht lief)
        if not DreamHouse.Collections.customCollections or #DreamHouse.Collections.customCollections == 0 then
            DreamHouse.Collections:LoadSavedCollections()
        end
        collections = DreamHouse.Collections:GetAllCollections() or {}
    end
    
    DreamHouse.Debug:Log("Collections", "UpdateCollectionsUI: " .. #collections .. " Kollektionen gefunden, inDetailView: " .. tostring(isInDetailView), "DEBUG")
    
    -- Wenn wir in der Detail-Ansicht sind, nur die interne Liste aktualisieren
    if isInDetailView then
        -- Liste im Hintergrund aktualisieren (für wenn wir zurück zur Liste gehen)
        self:PopulateCollectionsList(collections)
        return
    end
    
    if #collections == 0 then
        -- Keine Kollektionen -> Leere Ansicht mit großem "+" Button
        self.collectionsContainer.emptyView:Show()
        self.collectionsContainer.listView:Hide()
        if self.collectionsContainer.listAddButton then
            self.collectionsContainer.listAddButton:Hide() -- Großer "+" ist schon in emptyView
        end
        if self.listSearchBox then
            self.listSearchBox:Hide() -- Keine Suche wenn keine Kollektionen
        end
        DreamHouse.Debug:Log("Collections", "Zeige leere Ansicht (keine Kollektionen)", "DEBUG")
    else
        -- Kollektionen vorhanden -> Liste anzeigen
        self.collectionsContainer.emptyView:Hide()
        self.collectionsContainer.listView:Show()
        if self.collectionsContainer.listAddButton then
            self.collectionsContainer.listAddButton:Show() -- Kleiner "+" für neue Kollektion
        end
        if self.listSearchBox then
            self.listSearchBox:Show() -- Suchleiste zeigen
        end
        self:PopulateCollectionsList(collections)
        DreamHouse.Debug:Log("Collections", "Zeige " .. #collections .. " Kollektionen", "DEBUG")
    end
end

-- Filtert die Kollektionen-Liste nach Suchbegriff (Live-Suche)
function DreamHouse.Hooks.Storage:FilterCollectionsList(searchText)
    if not self.collectionsContainer then return end
    
    local collections = {}
    if DreamHouse.Collections then
        collections = DreamHouse.Collections:GetAllCollections() or {}
    end
    
    -- Filtern nach Suchtext
    local filteredCollections = {}
    if searchText and searchText ~= "" then
        for _, collection in ipairs(collections) do
            if collection.name and collection.name:lower():find(searchText, 1, true) then
                table.insert(filteredCollections, collection)
            end
        end
        DreamHouse.Debug:Log("Collections", "Suche '" .. searchText .. "': " .. #filteredCollections .. " von " .. #collections .. " Treffern", "DEBUG")
    else
        filteredCollections = collections
    end
    
    -- Liste aktualisieren
    if #filteredCollections == 0 and searchText and searchText ~= "" then
        -- Keine Treffer - Liste ausblenden, Hinweis zeigen
        self.collectionsContainer.listView:Hide()
        if not self.noSearchResultsText then
            self.noSearchResultsText = self.collectionsContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            self.noSearchResultsText:SetPoint("CENTER", self.collectionsContainer, "CENTER", 0, 0)
            self.noSearchResultsText:SetTextColor(0.5, 0.5, 0.5)
        end
        self.noSearchResultsText:SetText("Keine Treffer für \"" .. searchText .. "\"")
        self.noSearchResultsText:Show()
    else
        if self.noSearchResultsText then
            self.noSearchResultsText:Hide()
        end
        self.collectionsContainer.listView:Show()
        self:PopulateCollectionsList(filteredCollections)
    end
end

-- Füllt die Kollektionen-Liste
function DreamHouse.Hooks.Storage:PopulateCollectionsList(collections)
    DreamHouse.Debug:Log("Collections", "PopulateCollectionsList: " .. #collections .. " Kollektionen", "DEBUG")
    
    local scrollChild = self.collectionsContainer.scrollChild
    if not scrollChild then 
        DreamHouse.Debug:Log("Collections", "FEHLER: scrollChild ist nil!", "ERROR")
        return 
    end
    
    -- Alte Einträge entfernen
    local children = {scrollChild:GetChildren()}
    DreamHouse.Debug:Log("Collections", "Entferne " .. #children .. " alte Einträge", "DEBUG")
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local yOffset = 0
    local entryHeight = 50
    local entrySpacing = 4
    
    for i, collection in ipairs(collections) do
        DreamHouse.Debug:Log("Collections", "Erstelle Eintrag " .. i .. ": " .. (collection.name or "?"), "DEBUG")
        local entry = self:CreateCollectionEntry(scrollChild, collection, i)
        entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
        entry:SetPoint("RIGHT", scrollChild, "RIGHT", -25, 0) -- Mehr Platz für Scrollbar
        entry:Show()
        yOffset = yOffset + entryHeight + entrySpacing
    end
    
    -- ScrollChild Höhe anpassen
    scrollChild:SetHeight(math.max(yOffset, 1))
    DreamHouse.Debug:Log("Collections", "Liste gefüllt, Höhe: " .. yOffset, "SUCCESS")
end

-- Erstellt einen einzelnen Kollektions-Eintrag
function DreamHouse.Hooks.Storage:CreateCollectionEntry(parent, collection, index)
    local entry = CreateFrame("Button", "DreamHouseCollectionEntry" .. index, parent)
    entry:SetHeight(50)
    entry:EnableMouse(true)
    entry.collectionData = collection  -- Referenz speichern
    
    -- Hintergrund
    local bg = entry:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
    entry.bg = bg
    
    -- Linker Akzent-Streifen (Gold)
    local accent = entry:CreateTexture(nil, "ARTWORK")
    accent:SetSize(3, 40)
    accent:SetPoint("LEFT", entry, "LEFT", 5, 0)
    accent:SetColorTexture(0.8, 0.6, 0.2, 1)
    entry.accent = accent
    
    -- Icon-Rahmen (Quadratisch)
    local iconFrame = CreateFrame("Frame", nil, entry, "BackdropTemplate")
    iconFrame:SetSize(38, 38)
    iconFrame:SetPoint("LEFT", accent, "RIGHT", 8, 0)
    
    -- Hintergrund
    local iconBg = iconFrame:CreateTexture(nil, "BACKGROUND")
    iconBg:SetAllPoints()
    iconBg:SetColorTexture(0, 0, 0, 0.4)
    iconFrame.bg = iconBg
    
    -- Icon (Quadratisch, zentriert)
    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    local iconAtlas = collection.icon or "Garr_Building-AddFollowerPlus"
    pcall(function() icon:SetAtlas(iconAtlas) end)
    entry.icon = icon
    
    -- Rahmen (Simpler Rand)
    iconFrame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    iconFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1) -- Subtiler Rand
    entry.iconFrame = iconFrame
    
    -- Name
    local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("LEFT", iconFrame, "RIGHT", 10, 6)
    name:SetText(collection.name or L["Unknown"])
    name:SetTextColor(1, 0.82, 0)
    entry.nameText = name
    
    -- Item-Anzahl
    local itemCount = collection.items and #collection.items or 0
    local progress = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    progress:SetPoint("LEFT", iconFrame, "RIGHT", 10, -8)
    progress:SetText(string.format("%d %s", itemCount, L["Items"]))
    progress:SetTextColor(0.6, 0.6, 0.6)
    entry.progress = progress
    
    -- "Aktiv"-Anzeige (grün, in der Mitte)
    local activeText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    activeText:SetPoint("CENTER", entry, "CENTER", 40, 0)
    activeText:SetText("|cff00ff00" .. L["Active"] .. "|r")
    activeText:Hide()
    entry.activeText = activeText
    entry.collectionID = collection.id
    
    -- Prüfen ob aktiv und anzeigen
    if DreamHouse.Hooks.Storage.activeCollectionID == collection.id then
        activeText:Show()
    end
    
    -- Löschen-Button (X)
    local deleteBtn = CreateFrame("Button", nil, entry)
    deleteBtn:SetSize(24, 24)
    deleteBtn:SetPoint("RIGHT", entry, "RIGHT", -10, 0)
    deleteBtn:SetNormalAtlas("transmog-icon-remove")
    deleteBtn:SetHighlightAtlas("transmog-icon-remove")
    deleteBtn:GetHighlightTexture():SetAlpha(0.5)
    deleteBtn:Hide()  -- Nur bei Hover anzeigen
    deleteBtn.collectionID = collection.id  -- ID speichern
    deleteBtn.collectionName = collection.name  -- Name speichern
    entry.deleteBtn = deleteBtn
    
    deleteBtn:SetScript("OnClick", function(btn, mouseButton)
        DreamHouse.Debug:Log("Collections", "Löschen-Button geklickt für: " .. (btn.collectionName or "?"), "INFO")
        
        local colID = btn.collectionID
        local colName = btn.collectionName or "?"
        
        -- Bestätigungs-Dialog
        StaticPopupDialogs["DREAMHOUSE_DELETE_COLLECTION"] = {
            text = L["Delete collection X?"]:format(colName),
            button1 = L["Delete"],
            button2 = L["Cancel"],
            OnAccept = function()
                DreamHouse.Debug:Log("Collections", "Lösche Kollektion: " .. colName .. " (ID: " .. tostring(colID) .. ")", "INFO")
                if DreamHouse.Collections then
                    local success = DreamHouse.Collections:DeleteCollection(colID)
                    if success then
                        DreamHouse.Debug:Log("Collections", "Kollektion gelöscht!", "SUCCESS")
                    else
                        DreamHouse.Debug:Log("Collections", "Löschen fehlgeschlagen!", "ERROR")
                    end
                    DreamHouse.Hooks.Storage:UpdateCollectionsUI()
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("DREAMHOUSE_DELETE_COLLECTION")
    end)
    
    deleteBtn:SetScript("OnEnter", function(btn)
        -- Hover-State des Entry beibehalten
        entry.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        entry.accent:SetColorTexture(1, 0.82, 0, 1)
        entry.arrow:SetVertexColor(1, 0.82, 0)
        btn:Show()
        
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Delete"])
        GameTooltip:Show()
    end)
    
    deleteBtn:SetScript("OnLeave", function(btn)
        GameTooltip:Hide()
        -- Prüfe ob Maus noch über Entry ist
        if not entry:IsMouseOver() then
            entry.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
            entry.accent:SetColorTexture(0.8, 0.6, 0.2, 1)
            entry.arrow:SetVertexColor(0.6, 0.6, 0.6)
            btn:Hide()
        end
    end)
    
    -- Pfeil rechts (zum Öffnen) - neben Löschen-Button
    local arrow = entry:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(16, 16)
    arrow:SetPoint("RIGHT", deleteBtn, "LEFT", -8, 0)
    arrow:SetAtlas("arrow_right-default")
    arrow:SetVertexColor(0.6, 0.6, 0.6)
    entry.arrow = arrow
    
    -- Hover-Effekt für Entry
    entry:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
        self.accent:SetColorTexture(1, 0.82, 0, 1)
        self.arrow:SetVertexColor(1, 0.82, 0)
        self.deleteBtn:Show()
    end)
    
    entry:SetScript("OnLeave", function(self)
        -- Prüfe ob Maus über deleteBtn ist
        if self.deleteBtn:IsMouseOver() then
            return  -- Nicht verstecken wenn über Delete-Button
        end
        self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
        self.accent:SetColorTexture(0.8, 0.6, 0.2, 1)
        self.arrow:SetVertexColor(0.6, 0.6, 0.6)
        self.deleteBtn:Hide()
    end)
    
    -- Für Links- und Rechtsklick registrieren
    entry:RegisterForClicks("AnyUp")
    
    -- Klick -> Kollektion öffnen (Linksklick) oder Kontextmenü (Rechtsklick)
    entry:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            -- Kontextmenü anzeigen
            DreamHouse.Hooks.Storage:ShowCollectionContextMenu(collection, self)
        else
            -- Kollektion öffnen
            DreamHouse.Hooks.Storage:OpenCollection(collection)
        end
    end)
    
    return entry
end

-- Zeigt das Kontextmenü für eine Kollektion (Standard Blizzard Menü)
function DreamHouse.Hooks.Storage:ShowCollectionContextMenu(collection, anchorFrame)
    DreamHouse.Debug:Log("Collections", "ShowCollectionContextMenu aufgerufen für: " .. (collection.name or "?"), "INFO")
    
    local isActive = (self.activeCollectionID == collection.id)
    
    MenuUtil.CreateContextMenu(anchorFrame or UIParent, function(owner, rootDescription)
        rootDescription:SetTag("MENU_DREAMHOUSE_COLLECTION")
        
        -- Aktiv-Status Toggle
        if isActive then
            rootDescription:CreateButton("|cff00ff00" .. L["Remove active status"] .. "|r", function()
                DreamHouse.Hooks.Storage:ClearActiveCollection()
            end)
        else
            rootDescription:CreateButton(L["Set as active collection"], function()
                DreamHouse.Hooks.Storage:SetActiveCollection(collection.id)
            end)
        end
        
        rootDescription:CreateDivider()
        
        -- Icon ändern
        rootDescription:CreateButton(L["Change icon"], function()
            DreamHouse.Hooks.Storage:ShowChangeIconDialog(collection)
        end)
        
        -- Umbenennen
        rootDescription:CreateButton(L["Rename collection"], function()
            DreamHouse.Hooks.Storage:ShowRenameCollectionDialog(collection)
        end)
        
        rootDescription:CreateDivider()
        
        -- Löschen (rot)
        rootDescription:CreateButton("|cffff4444" .. L["Delete"] .. "|r", function()
            StaticPopupDialogs["DREAMHOUSE_DELETE_COLLECTION"] = {
                text = L["Delete collection X?"]:format(collection.name or "?"),
                button1 = L["Delete"],
                button2 = L["Cancel"],
                OnAccept = function()
                    if DreamHouse.Collections then
                        DreamHouse.Collections:DeleteCollection(collection.id)
                        if DreamHouse.Hooks.Storage.activeCollectionID == collection.id then
                            DreamHouse.Hooks.Storage:ClearActiveCollection()
                        end
                        DreamHouse.Hooks.Storage:UpdateCollectionsUI()
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("DREAMHOUSE_DELETE_COLLECTION")
        end)
    end)
    
    DreamHouse.Debug:Log("Collections", "Blizzard-Kontextmenü angezeigt", "SUCCESS")
end

-- Dialog zum Icon ändern einer bestehenden Kollektion
function DreamHouse.Hooks.Storage:ShowChangeIconDialog(collection)
    -- Speichere aktuelle Kollektion
    self.editingCollection = collection
    self.selectedAtlas = collection.icon or "Garr_Building-AddFollowerPlus"
    
    -- Erstelle Atlas-Browser falls nicht vorhanden
    if not self.atlasBrowserFrame then
        self:CreateAtlasBrowserFrame()
    end
    
    -- Suche zurücksetzen beim Öffnen
    if self.atlasBrowserFrame.searchBox then
        self.atlasBrowserFrame.searchBox:SetText("")
        if self.atlasBrowserFrame.searchBox.placeholder then
            self.atlasBrowserFrame.searchBox.placeholder:Show()
        end
    end
    
    -- Modifiziere den Bestätigen-Button für Icon-Änderung
    if self.atlasBrowserFrame.confirmBtn then
        self.atlasBrowserFrame.confirmBtn:SetScript("OnClick", function()
            if DreamHouse.Hooks.Storage.editingCollection then
                -- Icon in Kollektion speichern
                DreamHouse.Hooks.Storage.editingCollection.icon = DreamHouse.Hooks.Storage.selectedAtlas
                if DreamHouse.Collections then
                    DreamHouse.Collections:SaveCollections()
                end
                DreamHouse.Hooks.Storage:UpdateCollectionsUI()
                -- Auch Header-Icon aktualisieren falls in Kollektionsansicht
                if DreamHouse.Hooks.Storage.collectionHeaderIcon and DreamHouse.Hooks.Storage.currentCollection then
                    if DreamHouse.Hooks.Storage.currentCollection.id == DreamHouse.Hooks.Storage.editingCollection.id then
                        if DreamHouse.Hooks.Storage.collectionHeaderIcon.icon then
                            DreamHouse.Hooks.Storage.collectionHeaderIcon.icon:SetAtlas(DreamHouse.Hooks.Storage.selectedAtlas)
                        end
                    end
                end
                DreamHouse.Debug:Log("Collections", "Icon geändert: " .. DreamHouse.Hooks.Storage.selectedAtlas, "SUCCESS")
            end
            DreamHouse.Hooks.Storage.editingCollection = nil
            DreamHouse.Hooks.Storage.atlasBrowserFrame:Hide()
        end)
    end
    
    self.atlasBrowserFrame:Show()
    self:LoadAtlasIcons()
    self:UpdateIconHighlights()
end

-- Dialog zum Umbenennen einer Kollektion
function DreamHouse.Hooks.Storage:ShowRenameCollectionDialog(collection)
    StaticPopupDialogs["DREAMHOUSE_RENAME_COLLECTION"] = {
        text = L["Enter new name"] .. " (max. 15)",
        button1 = L["Rename"],
        button2 = L["Cancel"],
        hasEditBox = true,
        OnShow = function(self)
            self.EditBox:SetText(collection.name or "")
            self.EditBox:SetMaxLetters(15) -- Maximal 15 Zeichen
            self.EditBox:HighlightText()
        end,
        OnAccept = function(self)
            local newName = self.EditBox:GetText()
            if newName and newName ~= "" then
                collection.name = newName
                if DreamHouse.Collections then
                    DreamHouse.Collections:SaveCollections()
                end
                DreamHouse.Hooks.Storage:UpdateCollectionsUI()
                -- Header-Text aktualisieren falls in dieser Kollektion
                if DreamHouse.Hooks.Storage.currentCollection and DreamHouse.Hooks.Storage.currentCollection.id == collection.id then
                    if DreamHouse.Hooks.Storage.collectionNameText then
                        DreamHouse.Hooks.Storage.collectionNameText:SetText(newName)
                    end
                end
                DreamHouse.Debug:Log("Collections", "Kollektion umbenannt: " .. newName, "SUCCESS")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("DREAMHOUSE_RENAME_COLLECTION")
end

-- Ausgewähltes Icon für neue Kollektion (Atlas-Name)
DreamHouse.Hooks.Storage.selectedAtlas = "Garr_Building-AddFollowerPlus"

-- Beliebte/Empfohlene Icons für Schnellauswahl
DreamHouse.Hooks.Storage.QUICK_ICONS = {
    "Garr_Building-AddFollowerPlus",
    "bag-border-highlight",
    "communities-icon-addgroupplus",
    "mechagon-projects",
    "poi-workorders",
    "worldquest-icon-enchanting",
    "auctionhouse-icon-favorite",
    "VignetteKill",
    "poi-door-arrow-up",
    "groupfinder-icon-class-warrior",
}

-- Zeigt den Dialog zum Erstellen einer neuen Kollektion
function DreamHouse.Hooks.Storage:ShowCreateCollectionDialog(pendingEntryID)
    DreamHouse.Debug:Log("Collections", "Zeige Dialog: Neue Kollektion erstellen", "INFO")
    
    -- Reset Icon-Auswahl
    self.selectedAtlas = "Garr_Building-AddFollowerPlus"
    
    -- Speichere optionales Item das hinzugefügt werden soll
    self.pendingCollectionItem = pendingEntryID
    
    -- Erstelle Custom-Dialog falls nicht vorhanden
    if not self.createCollectionFrame then
        self:CreateCollectionDialogFrame()
    end
    
    -- Dialog anzeigen
    self.createCollectionFrame:Show()
    self.createCollectionFrame.nameEditBox:SetText("")
    self.createCollectionFrame.nameEditBox:SetFocus()
    self:UpdatePreviewIcon()
end

-- Erstellt das Custom-Dialog-Frame für Kollektionen (kompakt)
function DreamHouse.Hooks.Storage:CreateCollectionDialogFrame()
    -- Im Housing Editor ist HouseEditorFrame der TopLevelParent
    local parent = HouseEditorFrame or GetAppropriateTopLevelParent() or UIParent
    
    local frame = CreateFrame("Frame", "DreamHouseCreateCollectionFrame", parent, "BasicFrameTemplateWithInset")
    frame:SetSize(340, 140)
    frame:SetPoint("CENTER", parent, "CENTER", 0, 50)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    -- Titel
    frame.TitleText:SetText(L["Create new collection"])
    
    -- Icon-Vorschau Button
    local previewBtn = CreateFrame("Button", nil, frame)
    previewBtn:SetSize(50, 50)
    previewBtn:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 18, -18)
    
    -- 1. Hintergrund (Quadratisch)
    local previewBg = previewBtn:CreateTexture(nil, "BACKGROUND")
    previewBg:SetAllPoints()
    previewBg:SetColorTexture(0, 0, 0, 0.6)

    -- 2. Das Icon (Quadratisch, zentriert)
    local previewIcon = previewBtn:CreateTexture(nil, "ARTWORK")
    previewIcon:SetSize(40, 40)
    previewIcon:SetPoint("CENTER", previewBtn, "CENTER", 0, 0)
    previewIcon:SetAtlas("Garr_Building-AddFollowerPlus")
    frame.previewIcon = previewIcon
    
    -- 3. Rahmen (Quadratisch, simpler Rand)
    local previewBorder = CreateFrame("Frame", nil, previewBtn, "BackdropTemplate")
    previewBorder:SetAllPoints()
    previewBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    previewBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    frame.previewBorder = previewBorder
    
    -- Hover-Effekt
    previewBtn:SetScript("OnEnter", function(self)
        previewBorder:SetBackdropBorderColor(1, 0.82, 0, 1) -- Gold bei Hover
        previewBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Select icon"])
        GameTooltip:Show()
    end)
    previewBtn:SetScript("OnLeave", function()
        previewBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        previewBg:SetColorTexture(0, 0, 0, 0.6)
        GameTooltip:Hide()
    end)
    previewBtn:SetScript("OnClick", function()
        DreamHouse.Hooks.Storage:ShowAtlasBrowser()
    end)
    
    -- Name Label & EditBox
    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", previewBtn, "TOPRIGHT", 18, -2)
    nameLabel:SetText(L["Enter collection name"])
    
    local nameEditBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    nameEditBox:SetSize(220, 28)
    nameEditBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 5, -5)
    nameEditBox:SetAutoFocus(false)
    nameEditBox:SetMaxLetters(15) -- Maximal 15 Zeichen für Kollektionsnamen
    frame.nameEditBox = nameEditBox
    
    -- Buttons (Erstellen links, Abbrechen rechts)
    local createBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    createBtn:SetSize(110, 24)
    createBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 14)
    createBtn:SetText(L["Create"])
    createBtn:SetScript("OnClick", function()
        local name = nameEditBox:GetText()
        if name and name ~= "" then
            local atlas = DreamHouse.Hooks.Storage.selectedAtlas
            if DreamHouse.Collections then
                local newCollection = DreamHouse.Collections:CreateCollection(name, nil, atlas)
                
                -- Wenn ein Item auf das Hinzufügen wartet, füge es jetzt hinzu
                if DreamHouse.Hooks.Storage.pendingCollectionItem and newCollection then
                    DreamHouse.Collections:AddItemToCollection(newCollection.id, DreamHouse.Hooks.Storage.pendingCollectionItem)
                    DreamHouse.Debug:Log("Collections", "Item automatisch zur neuen Kollektion hinzugefügt", "SUCCESS")
                    DreamHouse.Hooks.Storage.pendingCollectionItem = nil
                end
                
                DreamHouse.Hooks.Storage:UpdateCollectionsUI()
                DreamHouse.Debug:Log("Collections", "Kollektion erstellt: " .. name .. " mit Icon: " .. atlas, "SUCCESS")
            end
            frame:Hide()
            -- Atlas-Browser auch schließen
            if DreamHouse.Hooks.Storage.atlasBrowserFrame then
                DreamHouse.Hooks.Storage.atlasBrowserFrame:Hide()
            end
        end
    end)
    
    local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(110, 24)
    cancelBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 14)
    cancelBtn:SetText(L["Cancel"])
    cancelBtn:SetScript("OnClick", function()
        frame:Hide()
        if DreamHouse.Hooks.Storage.atlasBrowserFrame then
            DreamHouse.Hooks.Storage.atlasBrowserFrame:Hide()
        end
    end)
    
    -- Enter zum Erstellen
    nameEditBox:SetScript("OnEnterPressed", function()
        createBtn:Click()
    end)
    
    -- Escape zum Schließen
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
            if DreamHouse.Hooks.Storage.atlasBrowserFrame then
                DreamHouse.Hooks.Storage.atlasBrowserFrame:Hide()
            end
        end
    end)
    frame:SetPropagateKeyboardInput(true)
    
    self.createCollectionFrame = frame
    DreamHouse.Debug:Log("Collections", "Erstellungs-Dialog erstellt (kompakt)", "SUCCESS")
end

-- Zeigt den Atlas-Browser als separates großes Fenster
function DreamHouse.Hooks.Storage:ShowAtlasBrowser()
    if not self.atlasBrowserFrame then
        self:CreateAtlasBrowserFrame()
    end
    
    -- Suche zurücksetzen beim Öffnen
    if self.atlasBrowserFrame.searchBox then
        self.atlasBrowserFrame.searchBox:SetText("")
        if self.atlasBrowserFrame.searchBox.placeholder then
            self.atlasBrowserFrame.searchBox.placeholder:Show()
        end
    end
    
    self.atlasBrowserFrame:Show()
    self:LoadAtlasIcons()
end

-- Erstellt das Atlas-Browser-Fenster
function DreamHouse.Hooks.Storage:CreateAtlasBrowserFrame()
    local parent = HouseEditorFrame or GetAppropriateTopLevelParent() or UIParent
    
    local frame = CreateFrame("Frame", "DreamHouseAtlasBrowser", parent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 450)
    frame:SetPoint("CENTER", parent, "CENTER", 200, 0)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")  -- Höher als DIALOG
    frame:SetFrameLevel(200)  -- Deutlich höher
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    -- Titel
    frame.TitleText:SetText(L["Select icon"])
    
    -- Suchleiste oben (eigene EditBox statt SearchBoxTemplate)
    local searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    searchBox:SetSize(340, 22)
    searchBox:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 15, -12)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(100)
    frame.searchBox = searchBox
    
    -- Placeholder-Text für Suchfeld
    local placeholder = searchBox:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    placeholder:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
    placeholder:SetText(L["Search atlas"])
    searchBox.placeholder = placeholder
    
    -- Placeholder ein/ausblenden
    searchBox:SetScript("OnTextChanged", function(self)
        local text = self:GetText()
        if text and text ~= "" then
            self.placeholder:Hide()
        else
            self.placeholder:Show()
        end
        DreamHouse.Hooks.Storage:FilterAtlasIcons(text)
    end)
    searchBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "" then
            self.placeholder:SetTextColor(0.3, 0.3, 0.3)
        end
    end)
    searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.placeholder:SetTextColor(0.5, 0.5, 0.5)
        end
    end)
    
    -- Bestätigen-Button rechts neben Suchleiste
    local confirmBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    confirmBtn:SetSize(100, 22)
    confirmBtn:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
    confirmBtn:SetText(L["Confirm"])
    confirmBtn:SetScript("OnClick", function()
        frame:Hide()
        DreamHouse.Debug:Log("Collections", "Icon bestätigt: " .. (DreamHouse.Hooks.Storage.selectedAtlas or "nil"), "INFO")
    end)
    frame.confirmBtn = confirmBtn
    
    -- Icon-Container
    local iconContainer = CreateFrame("Frame", nil, frame)
    iconContainer:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -5, -10)
    iconContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
    
    local iconBg = iconContainer:CreateTexture(nil, "BACKGROUND")
    iconBg:SetAllPoints()
    iconBg:SetColorTexture(0, 0, 0, 0.3)
    
    -- ScrollFrame für Icons
    local scrollFrame = CreateFrame("ScrollFrame", nil, iconContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 5)
    frame.iconScrollFrame = scrollFrame
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(420, 1)  -- Etwas schmaler für Scrollbar
    scrollFrame:SetScrollChild(scrollChild)
    frame.iconScrollChild = scrollChild
    
    frame.iconButtons = {}
    
    -- Escape zum Schließen
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)
    frame:SetPropagateKeyboardInput(true)
    
    -- Suche zurücksetzen beim Schließen
    frame:SetScript("OnHide", function(self)
        if self.searchBox then
            self.searchBox:SetText("")
            if self.searchBox.placeholder then
                self.searchBox.placeholder:Show()
            end
        end
        -- Icons ohne Filter neu laden
        DreamHouse.Hooks.Storage:FilterAtlasIcons("")
    end)
    
    self.atlasBrowserFrame = frame
    DreamHouse.Debug:Log("Collections", "Atlas-Browser erstellt", "SUCCESS")
end

-- Lädt alle verfügbaren Atlas-Icons
function DreamHouse.Hooks.Storage:LoadAtlasIcons()
    if self.atlasListLoaded then
        self:FilterAtlasIcons("")
        return
    end
    
    -- Hole alle Atlas-Namen
    self.allAtlases = C_Texture.GetAtlasElements() or {}
    self.atlasListLoaded = true
    
    DreamHouse.Debug:Log("Collections", "Atlas-Liste geladen: " .. #self.allAtlases .. " Einträge", "SUCCESS")
    
    -- Zeige initiale Liste
    self:FilterAtlasIcons("")
end

-- Filtert und zeigt Atlas-Icons basierend auf Suchtext
function DreamHouse.Hooks.Storage:FilterAtlasIcons(searchText)
    if not self.atlasBrowserFrame then return end
    
    local scrollChild = self.atlasBrowserFrame.iconScrollChild
    if not scrollChild then return end
    
    -- Alte Icons entfernen
    for _, btn in ipairs(self.atlasBrowserFrame.iconButtons or {}) do
        btn:Hide()
        btn:SetParent(nil)
    end
    self.atlasBrowserFrame.iconButtons = {}
    
    -- Gefilterte Liste erstellen
    local filteredAtlases = {}
    local searchLower = searchText and searchText:lower() or ""
    local maxIcons = 500  -- Mehr Icons im großen Browser
    
    if searchLower == "" then
        -- Zeige Quick-Icons zuerst
        for _, atlas in ipairs(self.QUICK_ICONS) do
            table.insert(filteredAtlases, atlas)
        end
        -- Dann alle anderen bis zum Limit
        local count = 0
        for _, atlas in ipairs(self.allAtlases or {}) do
            if count < maxIcons then
                local isDuplicate = false
                for _, qa in ipairs(self.QUICK_ICONS) do
                    if qa == atlas then isDuplicate = true break end
                end
                if not isDuplicate then
                    table.insert(filteredAtlases, atlas)
                    count = count + 1
                end
            end
        end
    else
        -- Suche in allen Atlases
        for _, atlas in ipairs(self.allAtlases or {}) do
            if #filteredAtlases < maxIcons and atlas:lower():find(searchLower, 1, true) then
                table.insert(filteredAtlases, atlas)
            end
        end
    end
    
    -- Icons erstellen
    local iconsPerRow = 10
    local iconSize = 40
    local iconSpacing = 2
    local row, col = 0, 0
    
    for i, atlas in ipairs(filteredAtlases) do
        local iconBtn = CreateFrame("Button", nil, scrollChild)
        iconBtn:SetSize(iconSize, iconSize)
        iconBtn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", col * (iconSize + iconSpacing), -row * (iconSize + iconSpacing))
        
        -- Das Icon selbst (füllend)
        local iconTex = iconBtn:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(iconSize - 6, iconSize - 6)  -- Etwas Padding
        iconTex:SetPoint("CENTER")
        
        -- Versuche Atlas zu setzen
        local success = pcall(function() iconTex:SetAtlas(atlas) end)
        if not success then
            iconTex:SetColorTexture(0.3, 0.3, 0.3, 1)
        end
        iconBtn.iconTex = iconTex
        iconBtn.atlasName = atlas
        
        -- Highlight-Rahmen bei Hover/Auswahl
        local highlight = iconBtn:CreateTexture(nil, "OVERLAY")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.15)
        highlight:Hide()
        iconBtn.highlight = highlight
        
        -- Viereckiger goldener Rahmen wenn ausgewählt (innerhalb des Icons)
        local border = CreateFrame("Frame", nil, iconBtn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
        })
        border:SetBackdropBorderColor(1, 0.82, 0, 1) -- Gold
        border:Hide()
        iconBtn.border = border
        
        -- Highlight wenn ausgewählt
        if atlas == self.selectedAtlas then
            border:Show()
        end
        
        iconBtn:SetScript("OnClick", function(btn)
            DreamHouse.Hooks.Storage.selectedAtlas = btn.atlasName
            DreamHouse.Hooks.Storage:UpdatePreviewIcon()
            DreamHouse.Hooks.Storage:UpdateIconHighlights()
            DreamHouse.Debug:Log("Collections", "Icon ausgewählt: " .. btn.atlasName, "INFO")
        end)
        
        iconBtn:SetScript("OnEnter", function(btn)
            highlight:Show()
            GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
            GameTooltip:SetText(btn.atlasName)
            GameTooltip:Show()
        end)
        
        iconBtn:SetScript("OnLeave", function(btn)
            highlight:Hide()
            GameTooltip:Hide()
        end)
        
        table.insert(self.atlasBrowserFrame.iconButtons, iconBtn)
        
        col = col + 1
        if col >= iconsPerRow then
            col = 0
            row = row + 1
        end
    end
    
    -- ScrollChild Höhe anpassen
    local totalRows = math.ceil(#filteredAtlases / iconsPerRow)
    scrollChild:SetHeight(math.max(totalRows * (iconSize + iconSpacing), 1))
end

-- Aktualisiert das Vorschau-Icon im Erstellungs-Dialog
function DreamHouse.Hooks.Storage:UpdatePreviewIcon()
    if self.createCollectionFrame and self.createCollectionFrame.previewIcon then
        pcall(function()
            self.createCollectionFrame.previewIcon:SetAtlas(self.selectedAtlas)
        end)
    end
end

-- Aktualisiert die Highlights der Icon-Buttons im Atlas-Browser
function DreamHouse.Hooks.Storage:UpdateIconHighlights()
    if not self.atlasBrowserFrame then return end
    
    for _, btn in ipairs(self.atlasBrowserFrame.iconButtons or {}) do
        if btn.border then
            if btn.atlasName == self.selectedAtlas then
                btn.border:Show()
            else
                btn.border:Hide()
            end
        end
    end
end

-- Öffnet eine Kollektion und zeigt deren Items (Set-Ansicht)
function DreamHouse.Hooks.Storage:OpenCollection(collection)
    if not collection then return end
    
    self.currentCollection = collection
    DreamHouse.Debug:Log("Collections", "Öffne Kollektion: " .. (collection.name or "?"), "INFO")
    
    -- UI umschalten
    if self.collectionsContainer then
        -- Liste explizit verstecken
        if self.collectionsContainer.listView then
            self.collectionsContainer.listView:Hide()
        end
        if self.collectionsContainer.emptyView then
            self.collectionsContainer.emptyView:Hide()
        end
        if self.collectionsContainer.listAddButton then
            self.collectionsContainer.listAddButton:Hide()
        end
        
        -- Listen-Suchleiste verstecken, Detail-Suchleiste zeigen
        if self.listSearchBox then
            self.listSearchBox:Hide()
        end
        if self.detailSearchBox then
            self.detailSearchBox:SetText("") -- Suchtext zurücksetzen
            self.detailSearchText = ""
            self.detailSearchBox:Show()
        end
        
        -- Detailansicht zeigen
        if self.detailContainer then
            self.detailContainer:Show()
            -- ScrollChild Größe aktualisieren (wichtig für Layout!)
            if self.detailScrollChild then
                self.detailScrollChild:SetWidth(self.collectionsContainer:GetWidth() - 25)
            end
            self:RenderCollectionDetails(collection)
        else
            DreamHouse.Debug:Log("Collections", "FEHLER: detailContainer nicht gefunden!", "ERROR")
        end
    end
    
    -- In Set-Ansicht: "Kollektionen" Text, Pfeil und BonusLoot-Icon verstecken
    if self.collectionsHeaderBtn then
        self.collectionsHeaderBtn:Hide()
    end
    if self.breadcrumbArrow then
        self.breadcrumbArrow:Hide()
    end
    if self.listHeaderIcon then
        self.listHeaderIcon:Hide()
    end
    
    -- Nur Kollektion-Icon + Name zeigen
    if self.collectionHeaderIcon then
        local iconAtlas = collection.icon or "Garr_Building-AddFollowerPlus"
        if self.collectionHeaderIcon.icon then
            self.collectionHeaderIcon.icon:SetAtlas(iconAtlas)
        end
        self.collectionHeaderIcon:Show()
    end
    
    -- Set-Name direkt neben dem Icon anzeigen
    if self.collectionNameText then
        self.collectionNameText:SetText(collection.name or L["Collection"])
        self.collectionNameText:Show()
        DreamHouse.Debug:Log("Collections", "Set-Ansicht: " .. (collection.name or "?"), "DEBUG")
    end
    
    -- Zurück-Pfeil rechts anzeigen
    if self.headerBackArrow then
        self.headerBackArrow:Show()
    end
    
    -- Zurück-Button anzeigen
    if self.backButton then
        self.backButton:Show()
    end
end

-- Schließt die Kollektion und kehrt zur Liste zurück
function DreamHouse.Hooks.Storage:CloseCollection()
    self.currentCollection = nil
    
    -- UI zurücksetzen
    if self.collectionsContainer then
        self.detailContainer:Hide()
        self.collectionsContainer.listView:Show()
        if self.collectionsContainer.listAddButton then
            self.collectionsContainer.listAddButton:Show()
        end
        
        -- Detail-Suchleiste verstecken, Listen-Suchleiste zeigen
        if self.detailSearchBox then
            self.detailSearchBox:Hide()
            self.detailSearchBox:SetText("")
            self.detailSearchText = ""
        end
        if self.listSearchBox then
            self.listSearchBox:Show()
        end
        
        -- Liste neu laden falls nötig (um Änderungen zu zeigen)
        self:UpdateCollectionsUI()
    end
    
    -- Header für Listenansicht wiederherstellen
    if self.collectionsHeaderBtn then
        self.collectionsHeaderBtn:Show()
    end
    if self.listHeaderIcon then
        self.listHeaderIcon:Show()
    end
    
    -- Set-Ansicht-Elemente verstecken
    if self.collectionHeaderIcon then
        self.collectionHeaderIcon:Hide()
    end
    if self.collectionNameText then
        self.collectionNameText:Hide()
    end
    -- Breadcrumb-Pfeil wird in Set-Ansicht nicht mehr verwendet, aber zur Sicherheit verstecken
    if self.breadcrumbArrow then
        self.breadcrumbArrow:Hide()
    end
    
    -- Zurück-Pfeil verstecken
    if self.headerBackArrow then
        self.headerBackArrow:Hide()
    end
    
    -- Zurück-Button verstecken
    if self.backButton then
        self.backButton:Hide()
    end
end

-- Rendert die Items in der Detail-Ansicht (Top 10 feste Slots | Linie | Rest)
function DreamHouse.Hooks.Storage:RenderCollectionDetails(collection)
    local scrollChild = self.detailScrollChild
    if not scrollChild then 
        DreamHouse.Debug:Log("Collections", "FEHLER: detailScrollChild nicht gefunden!", "ERROR")
        return 
    end
    
    -- Alte Frames entfernen (Release)
    if not self.detailItemPool then
        self.detailItemPool = CreateFramePool("Button", scrollChild)
    end
    self.detailItemPool:ReleaseAll()
    
    -- Slot-Referenzen leeren
    self.collectionSlotButtons = {}
    
    local items = collection.items or {}
    
    -- Echte Item-Anzahl zählen (nicht #items weil Lua-Tabellen mit Lücken problematisch sind)
    local itemCount = 0
    local maxIndex = 0
    for idx, item in pairs(items) do
        if type(idx) == "number" and item then
            itemCount = itemCount + 1
            if idx > maxIndex then maxIndex = idx end
        end
    end
    DreamHouse.Debug:Log("Collections", "RenderDetails: " .. itemCount .. " Items (maxIndex: " .. maxIndex .. ")", "DEBUG")
    
    -- Suchtext für Item-Filter (nur für Items unterhalb der Top 10, aber Treffer in Top 10 hervorheben)
    local searchText = self.detailSearchText or ""
    local hasSearchText = searchText ~= ""
    local top10MatchCount = 0 -- Zählt Treffer in den Top 10
    
    local itemSize = 62 -- Etwas kleiner damit sie nicht mit Scrollbar überlappen
    local itemSpacing = 8
    local itemsPerRow = 5 -- 5 Spalten für 2x5 Grid
    local topSlotCount = 10 -- Immer 10 feste Slots oben
    local currentY = -15
    
    -- Zentrieren: Grid-Breite berechnen und startX dynamisch setzen
    local gridWidth = (itemsPerRow * itemSize) + ((itemsPerRow - 1) * itemSpacing)
    local containerWidth = scrollChild:GetWidth() or 350
    local startX = math.floor((containerWidth - gridWidth) / 2)
    
    -- ===== TOP 10 FESTE SLOTS (2x5 Grid) =====
    for i = 1, topSlotCount do
        local btn = self.detailItemPool:Acquire()
        btn:SetParent(scrollChild)
        btn:SetSize(itemSize, itemSize)
        btn:Show()
        
        -- Slot-UI aufbauen (VIERECKIG)
        if not btn.bg then
            -- Hintergrund (viereckig)
            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.05, 0.05, 0.05, 0.8)
            
            -- Icon (mit Padding für Rahmen)
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetPoint("TOPLEFT", 3, -3)
            btn.icon:SetPoint("BOTTOMRIGHT", -3, 3)
            
            -- Rahmen (dezent)
            btn.border = btn:CreateTexture(nil, "OVERLAY")
            btn.border:SetAllPoints()
            btn.border:SetAtlas("transmog-set-border-collected")
            
            -- Highlight
            btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            btn.highlight:SetAllPoints()
            btn.highlight:SetAtlas("housing-catalog-item-border-hover")
            btn.highlight:SetBlendMode("ADD")
            
            -- Menge (unten rechts)
            btn.countText = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
            btn.countText:SetPoint("BOTTOMRIGHT", -4, 4)
            btn.countText:SetJustifyH("RIGHT")
            
            -- Löschen-Button (oben rechts)
            btn.deleteBtn = CreateFrame("Button", nil, btn)
            btn.deleteBtn:SetSize(11, 11)  -- Kleiner
            btn.deleteBtn:SetPoint("TOPRIGHT", -4, -2)  -- Angepasst
            btn.deleteBtn:SetNormalAtlas("common-icon-redx")
            btn.deleteBtn:SetHighlightAtlas("common-icon-redx")
            btn.deleteBtn:GetHighlightTexture():SetAlpha(0.5)
            btn.deleteBtn:Hide()
            btn.deleteBtn:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent.recordID and DreamHouse.Hooks.Storage.currentCollection then
                    local collectionID = DreamHouse.Hooks.Storage.currentCollection.id
                    DreamHouse.Collections:RemoveItemFromCollection(collectionID, parent.recordID)
                    -- UI neu laden
                    DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
                    DreamHouse.Debug:Log("Collections", "Item aus Kollektion entfernt", "SUCCESS")
                end
            end)
            btn.deleteBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["Remove from collection"])
                GameTooltip:Show()
            end)
            btn.deleteBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            -- 3D Vorschau-Button (oben links)
            btn.previewBtn = CreateFrame("Button", nil, btn)
            btn.previewBtn:SetSize(16, 16)  -- Größer
            btn.previewBtn:SetPoint("TOPLEFT", 4, 0)  -- Angepasst
            btn.previewBtn:SetNormalAtlas("talents-search-exactmatch")
            btn.previewBtn:SetHighlightAtlas("talents-search-exactmatch")
            btn.previewBtn:GetHighlightTexture():SetAlpha(0.5)
            btn.previewBtn:Hide()
            btn.previewBtn:SetScript("OnClick", function(self)
                local parent = self:GetParent()
                if parent.recordID and parent.entryType then
                    -- 3D Modell Vorschau öffnen
                    DreamHouse.Hooks.Storage:Show3DPreview(parent.entryType, parent.recordID, parent.entryName)
                end
            end)
            btn.previewBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("3D Vorschau")
                GameTooltip:Show()
            end)
            btn.previewBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        
        -- Item vorhanden?
        local itemData = items[i]
        if itemData then
            local recordID = itemData.recordID or itemData
            local entryType = itemData.entryType or Enum.HousingCatalogEntryType.Decor
            btn.recordID = recordID
            btn.entryType = entryType
            
            -- Icon aus Housing Catalog holen (via recordID, true = mit Besitz-Info)
            local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
            if entryInfo then
                if entryInfo.iconTexture then
                    btn.icon:SetTexture(entryInfo.iconTexture)
                elseif entryInfo.iconAtlas then
                    btn.icon:SetAtlas(entryInfo.iconAtlas)
                else
                    btn.icon:SetTexture(134400)
                end
                btn.entryName = entryInfo.name
                -- Menge anzeigen (immer, auch bei 0)
                if btn.countText then
                    local qty = entryInfo.quantity or 0
                    btn.countText:SetText(qty)
                    if qty > 0 then
                        btn.countText:SetTextColor(1, 1, 1) -- Weiß
                    else
                        btn.countText:SetTextColor(1, 0.3, 0.3) -- Rot bei 0
                    end
                    btn.countText:Show()
                end
            else
                btn.icon:SetTexture(134400)
                btn.entryName = nil
                if btn.countText then btn.countText:Hide() end
            end
            btn.icon:Show()
            btn.border:SetDesaturated(false)
            btn.border:SetAlpha(1)
            btn.border:SetVertexColor(1, 1, 1) -- Farbe zurücksetzen (wichtig nach Drag!)
            
            -- Such-Highlight für Treffer
            if not btn.searchHighlight then
                btn.searchHighlight = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
                btn.searchHighlight:SetPoint("TOPLEFT", 2, -2)
                btn.searchHighlight:SetPoint("BOTTOMRIGHT", -2, 2)
                btn.searchHighlight:SetColorTexture(1, 0.82, 0, 0.25) -- Goldener Hintergrund
                btn.searchHighlight:Hide()
            end
            
            if hasSearchText and btn.entryName and btn.entryName:lower():find(searchText, 1, true) then
                top10MatchCount = top10MatchCount + 1
                btn.searchHighlight:Show()
                btn.border:SetVertexColor(1, 0.82, 0) -- Goldener Border
                btn.isSearchMatch = true
            else
                if btn.isSearchMatch then
                    btn.searchHighlight:Hide()
                    btn.border:SetVertexColor(1, 1, 1)
                    btn.isSearchMatch = false
                end
            end
            
            -- Löschen-Button und Vorschau-Button zeigen
            if btn.deleteBtn then btn.deleteBtn:Show() end
            if btn.previewBtn then btn.previewBtn:Show() end
            
            btn:SetScript("OnEnter", function(self)
                -- Drop-Highlight zeigen wenn wir von einem ANDEREN Slot draggen
                if DreamHouse.Hooks.Storage.collectionIsDragging and 
                   DreamHouse.Hooks.Storage.collectionDragData and 
                   DreamHouse.Hooks.Storage.collectionDragData.fromSlot ~= self.slotIndex then
                    if self.dropHighlight then self.dropHighlight:Show() end
                    return -- Kein Tooltip während Drag
                end
                
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.recordID then
                    local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(self.entryType, self.recordID, true)
                    if info then
                        GameTooltip:SetText(info.name or "Unknown", 1, 1, 1)
                        if info.quantity then
                            GameTooltip:AddLine("Im Besitz: " .. info.quantity, 0.5, 0.5, 0.5)
                        end
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cff88ccff" .. L["Drag: Rearrange"] .. "|r", 0.7, 0.7, 0.7)
                    end
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function(self)
                if self.dropHighlight then self.dropHighlight:Hide() end
                GameTooltip:Hide()
            end)
        else
            -- Leerer Slot (abgedunkelt)
            btn.recordID = nil
            btn.entryType = nil
            btn.entryName = nil
            btn.icon:SetTexture(nil)
            btn.icon:Hide()
            btn.border:SetDesaturated(true)
            btn.border:SetAlpha(0.3)
            if btn.countText then btn.countText:Hide() end
            if btn.deleteBtn then btn.deleteBtn:Hide() end
            if btn.previewBtn then btn.previewBtn:Hide() end
            -- Such-Highlight zurücksetzen
            if btn.searchHighlight then btn.searchHighlight:Hide() end
            btn.border:SetVertexColor(1, 1, 1)
            btn.isSearchMatch = false
            
            -- Auch leere Slots brauchen Drop-Highlight Handler
            btn:SetScript("OnEnter", function(self)
                if DreamHouse.Hooks.Storage.collectionIsDragging and 
                   DreamHouse.Hooks.Storage.collectionDragData and 
                   DreamHouse.Hooks.Storage.collectionDragData.fromSlot ~= self.slotIndex then
                    if self.dropHighlight then self.dropHighlight:Show() end
                end
            end)
            btn:SetScript("OnLeave", function(self)
                if self.dropHighlight then self.dropHighlight:Hide() end
            end)
        end
        
        -- ===== DRAG & DROP für Top 10 Slots =====
        btn.slotIndex = i
        btn.isTopSlot = true -- Markierung für Top 10 Slots
        btn:RegisterForDrag("LeftButton")
        
        -- Slot in Referenz-Tabelle speichern
        self.collectionSlotButtons[i] = btn
        
        -- Drop-Highlight (für Ziel-Slots)
        if not btn.dropHighlight then
            btn.dropHighlight = btn:CreateTexture(nil, "OVERLAY", nil, 7)
            btn.dropHighlight:SetAllPoints()
            btn.dropHighlight:SetAtlas("transmog-set-border-collected")
            btn.dropHighlight:SetVertexColor(0, 1, 0) -- Grün
            btn.dropHighlight:SetBlendMode("ADD")
            btn.dropHighlight:Hide()
        end
        
        btn:SetScript("OnDragStart", function(self)
            if not self.recordID then return end -- Nur Items mit Inhalt draggen
            
            local hooks = DreamHouse.Hooks.Storage
            hooks.collectionIsDragging = true
            hooks.collectionDragData = {
                fromSlot = self.slotIndex,
                recordID = self.recordID,
                entryType = self.entryType,
                isFromTopSlot = self.isTopSlot,
            }
            
            -- Drag-Icon vorbereiten
            if hooks.collectionDragIcon then
                -- Parent auf HouseEditorFrame setzen wenn aktiv
                if HouseEditorFrame and HouseEditorFrame:IsShown() then
                    hooks.collectionDragIcon:SetParent(HouseEditorFrame)
                else
                    hooks.collectionDragIcon:SetParent(UIParent)
                end
                hooks.collectionDragIcon:SetFrameStrata("TOOLTIP")
                hooks.collectionDragIcon:SetFrameLevel(500)
                
                if self.icon:GetTexture() then
                    hooks.collectionDragIcon.icon:SetTexture(self.icon:GetTexture())
                elseif self.icon:GetAtlas() then
                    hooks.collectionDragIcon.icon:SetAtlas(self.icon:GetAtlas())
                end
                hooks.collectionDragIcon:Show()
                
                -- Icon folgt der Maus
                hooks.collectionDragIcon:SetScript("OnUpdate", function(dragFrame)
                    local x, y = GetCursorPosition()
                    local scale = dragFrame:GetParent():GetEffectiveScale()
                    dragFrame:ClearAllPoints()
                    dragFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
                end)
            end
            
            -- Quell-Slot visuell markieren
            self:SetAlpha(0.4)
            self.border:SetVertexColor(1, 1, 0) -- Gelb (Quelle)
            GameTooltip:Hide()
            
            DreamHouse.Debug:Log("Collections", "Drag gestartet von Slot " .. self.slotIndex, "DEBUG")
        end)
        
        btn:SetScript("OnDragStop", function(self)
            local hooks = DreamHouse.Hooks.Storage
            
            if hooks.collectionDragIcon then
                hooks.collectionDragIcon:Hide()
                hooks.collectionDragIcon:SetScript("OnUpdate", nil)
                hooks.collectionDragIcon:ClearAllPoints()
            end
            
            -- Drop-Ziel finden
            if hooks.collectionDragData then
                local mouseFoci = GetMouseFoci and GetMouseFoci() or {GetMouseFocus()}
                local targetFrame = mouseFoci[1]
                
                -- Prüfen ob Ziel ein Kollektions-Slot ist (Top 10)
                if targetFrame and targetFrame.slotIndex and targetFrame.isTopSlot then
                    if targetFrame.slotIndex ~= hooks.collectionDragData.fromSlot then
                        hooks:SwapCollectionItems(hooks.collectionDragData.fromSlot, targetFrame.slotIndex)
                        DreamHouse.Debug:Log("Collections", "Drop auf Slot " .. targetFrame.slotIndex .. " - getauscht!", "SUCCESS")
                        PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
                    end
                else
                    DreamHouse.Debug:Log("Collections", "Drop außerhalb eines gültigen Slots", "DEBUG")
                end
            end
            
            -- Visuelles Feedback zurücksetzen
            self:SetAlpha(1)
            self.border:SetVertexColor(1, 1, 1) -- Weiß (normal)
            
            -- Alle Drop-Highlights verstecken
            for _, slotBtn in pairs(hooks.collectionSlotButtons or {}) do
                if slotBtn.dropHighlight then
                    slotBtn.dropHighlight:Hide()
                end
            end
            
            hooks.collectionIsDragging = false
            hooks.collectionDragData = nil
        end)
        
        btn:SetScript("OnReceiveDrag", function(self)
            local hooks = DreamHouse.Hooks.Storage
            if hooks.collectionDragData and hooks.collectionDragData.fromSlot ~= self.slotIndex then
                hooks:SwapCollectionItems(hooks.collectionDragData.fromSlot, self.slotIndex)
                DreamHouse.Debug:Log("Collections", "Slots getauscht via ReceiveDrag: " .. hooks.collectionDragData.fromSlot .. " <-> " .. self.slotIndex, "SUCCESS")
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
            end
            
            -- Drag beenden
            if hooks.collectionDragIcon then
                hooks.collectionDragIcon:Hide()
                hooks.collectionDragIcon:SetScript("OnUpdate", nil)
            end
            
            -- Alle Drop-Highlights verstecken
            for _, slotBtn in pairs(hooks.collectionSlotButtons or {}) do
                if slotBtn.dropHighlight then
                    slotBtn.dropHighlight:Hide()
                end
            end
            
            hooks.collectionIsDragging = false
            hooks.collectionDragData = nil
        end)
        
        -- Positionierung (2 Reihen x 5 Spalten)
        local row = math.floor((i - 1) / itemsPerRow)
        local col = (i - 1) % itemsPerRow
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", startX + col * (itemSize + itemSpacing), currentY - row * (itemSize + itemSpacing))
    end
    
    -- Y-Position nach den 10 Slots berechnen (2 Reihen)
    currentY = currentY - (2 * (itemSize + itemSpacing)) - 8
    
    -- ===== TRENNBALKEN =====
    if not self.separatorLine then
        local line = scrollChild:CreateTexture(nil, "ARTWORK")
        line:SetHeight(2)
        line:SetColorTexture(0.6, 0.5, 0.2, 0.8) -- Goldfarben passend zum UI
        self.separatorLine = line
    end
    self.separatorLine:ClearAllPoints()
    self.separatorLine:SetPoint("LEFT", scrollChild, "TOPLEFT", 10, currentY)
    self.separatorLine:SetPoint("RIGHT", scrollChild, "TOPRIGHT", -10, currentY)
    self.separatorLine:Show()
    
    currentY = currentY - 12
    
    -- ===== RESTLICHE ITEMS (ab Index 11) =====
    local remainingItems = {}
    for i = topSlotCount + 1, maxIndex do
        if items[i] then
            local itemData = items[i]
            local recordID = itemData.recordID or itemData
            local entryType = itemData.entryType or Enum.HousingCatalogEntryType.Decor
            
            -- Item-Name für Filterung holen
            local shouldInclude = true
            if hasSearchText then
                local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
                if entryInfo and entryInfo.name then
                    shouldInclude = entryInfo.name:lower():find(searchText, 1, true) ~= nil
                else
                    shouldInclude = false -- Kein Name = nicht filtern
                end
            end
            
            if shouldInclude then
                table.insert(remainingItems, { data = itemData, originalIndex = i })
            end
        end
    end
    
    local contentHeight = 0
    
    -- "Keine Treffer" oder "Keine Items" oder "X Treffer" Text
    if #remainingItems == 0 then
        if not scrollChild.noItemsText then
            local noItems = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            noItems:SetTextColor(0.5, 0.5, 0.5, 1)
            scrollChild.noItemsText = noItems
        end
        scrollChild.noItemsText:ClearAllPoints()
        scrollChild.noItemsText:SetPoint("TOP", scrollChild, "TOP", 0, currentY - 30)
        if hasSearchText then
            if top10MatchCount > 0 then
                -- Treffer in Top 10, aber keine unterhalb
                scrollChild.noItemsText:SetText(top10MatchCount .. " Treffer für \"" .. searchText .. "\"")
                scrollChild.noItemsText:SetTextColor(0.6, 0.8, 0.6, 1) -- Leicht grün
            else
                -- Keine Treffer nirgends
                scrollChild.noItemsText:SetText("Keine Treffer für \"" .. searchText .. "\"")
                scrollChild.noItemsText:SetTextColor(0.5, 0.5, 0.5, 1)
            end
        else
            scrollChild.noItemsText:SetText(L["No items in collection"])
            scrollChild.noItemsText:SetTextColor(0.5, 0.5, 0.5, 1)
        end
        scrollChild.noItemsText:Show()
        
        -- Höhe: Bis zum "Keine Items" Text + etwas Puffer
        contentHeight = math.abs(currentY) + 60
    else
        if scrollChild.noItemsText then scrollChild.noItemsText:Hide() end
        
        -- Restliche Items als Grid
        for i, itemData in ipairs(remainingItems) do
            local btn = self.detailItemPool:Acquire()
            btn:SetParent(scrollChild)
            btn:SetSize(itemSize, itemSize)
            btn:Show()
            
            if not btn.bg then
                -- Hintergrund (viereckig)
                btn.bg = btn:CreateTexture(nil, "BACKGROUND")
                btn.bg:SetAllPoints()
                btn.bg:SetColorTexture(0.05, 0.05, 0.05, 0.8)
                
                -- Icon (mit Padding für Rahmen)
                btn.icon = btn:CreateTexture(nil, "ARTWORK")
                btn.icon:SetPoint("TOPLEFT", 3, -3)
                btn.icon:SetPoint("BOTTOMRIGHT", -3, 3)
                
                -- Rahmen (dezent)
                btn.border = btn:CreateTexture(nil, "OVERLAY")
                btn.border:SetAllPoints()
                btn.border:SetAtlas("transmog-set-border-collected")
                
                -- Highlight
                btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
                btn.highlight:SetAllPoints()
                btn.highlight:SetAtlas("housing-catalog-item-border-hover")
                btn.highlight:SetBlendMode("ADD")
                
                -- Menge (unten rechts)
                btn.countText = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
                btn.countText:SetPoint("BOTTOMRIGHT", -4, 4)
                btn.countText:SetJustifyH("RIGHT")
                
                -- Löschen-Button (oben rechts) - kleiner und weiter links
                btn.deleteBtn = CreateFrame("Button", nil, btn)
                btn.deleteBtn:SetSize(11, 11)  -- Kleiner
                btn.deleteBtn:SetPoint("TOPRIGHT", -4, -2)  -- Angepasst
                btn.deleteBtn:SetNormalAtlas("common-icon-redx")
                btn.deleteBtn:SetHighlightAtlas("common-icon-redx")
                btn.deleteBtn:GetHighlightTexture():SetAlpha(0.5)
                btn.deleteBtn:SetScript("OnClick", function(self)
                    local parent = self:GetParent()
                    if parent.recordID and DreamHouse.Hooks.Storage.currentCollection then
                        local collectionID = DreamHouse.Hooks.Storage.currentCollection.id
                        DreamHouse.Collections:RemoveItemFromCollection(collectionID, parent.recordID)
                        DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
                    end
                end)
                btn.deleteBtn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L["Remove from collection"])
                    GameTooltip:Show()
                end)
                btn.deleteBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                
                -- 3D Vorschau-Button (oben links) - größer und weiter rechts
                btn.previewBtn = CreateFrame("Button", nil, btn)
                btn.previewBtn:SetSize(16, 16)  -- Größer
                btn.previewBtn:SetPoint("TOPLEFT", 4, 0)  -- Angepasst
                btn.previewBtn:SetNormalAtlas("talents-search-exactmatch")
                btn.previewBtn:SetHighlightAtlas("talents-search-exactmatch")
                btn.previewBtn:GetHighlightTexture():SetAlpha(0.5)
                btn.previewBtn:SetScript("OnClick", function(self)
                    local parent = self:GetParent()
                    if parent.recordID and parent.entryType then
                        DreamHouse.Hooks.Storage:Show3DPreview(parent.entryType, parent.recordID, parent.entryName)
                    end
                end)
                btn.previewBtn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText("3D Vorschau")
                    GameTooltip:Show()
                end)
                btn.previewBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
            
            -- itemData ist jetzt { data = ..., originalIndex = ... }
            local actualItemData = itemData.data
            local origIndex = itemData.originalIndex
            local recordID = actualItemData.recordID or actualItemData
            local entryType = actualItemData.entryType or Enum.HousingCatalogEntryType.Decor
            btn.recordID = recordID
            btn.entryType = entryType
            
            -- Icon aus Housing Catalog holen (via recordID, true = mit Besitz-Info)
            local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
            if entryInfo then
                if entryInfo.iconTexture then
                    btn.icon:SetTexture(entryInfo.iconTexture)
                elseif entryInfo.iconAtlas then
                    btn.icon:SetAtlas(entryInfo.iconAtlas)
                else
                    btn.icon:SetTexture(134400)
                end
                btn.entryName = entryInfo.name
                -- Menge anzeigen (immer, auch bei 0)
                if btn.countText then
                    local qty = entryInfo.quantity or 0
                    btn.countText:SetText(qty)
                    if qty > 0 then
                        btn.countText:SetTextColor(1, 1, 1) -- Weiß
                    else
                        btn.countText:SetTextColor(1, 0.3, 0.3) -- Rot bei 0
                    end
                    btn.countText:Show()
                end
            else
                btn.icon:SetTexture(134400)
                btn.entryName = nil
                if btn.countText then btn.countText:Hide() end
            end
            btn.icon:Show()
            btn.border:SetDesaturated(false)
            btn.border:SetVertexColor(1, 1, 1) -- Farbe zurücksetzen (wichtig nach Drag!)
            if btn.deleteBtn then btn.deleteBtn:Show() end
            if btn.previewBtn then btn.previewBtn:Show() end

            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.recordID then
                    local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(self.entryType, self.recordID, true)
                    if info then
                        GameTooltip:SetText(info.name or "Unknown", 1, 1, 1)
                        if info.quantity then
                            GameTooltip:AddLine("Im Besitz: " .. info.quantity, 0.5, 0.5, 0.5)
                        end
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cff88ccff" .. "In Top 10 ziehen" .. "|r", 0.7, 0.7, 0.7)
                    end
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            -- ===== DRAG für Items unterhalb der Trennlinie =====
            btn.originalIndex = origIndex -- Der echte Index in der Kollektion (aus itemData.originalIndex)
            btn.isTopSlot = false -- Nicht in den Top 10
            btn:RegisterForDrag("LeftButton")
            
            btn:SetScript("OnDragStart", function(self)
                if not self.recordID then return end
                
                local hooks = DreamHouse.Hooks.Storage
                hooks.collectionIsDragging = true
                hooks.collectionDragData = {
                    fromSlot = self.originalIndex,
                    recordID = self.recordID,
                    entryType = self.entryType,
                    isFromTopSlot = false,
                }
                
                -- Drag-Icon vorbereiten
                if hooks.collectionDragIcon then
                    if HouseEditorFrame and HouseEditorFrame:IsShown() then
                        hooks.collectionDragIcon:SetParent(HouseEditorFrame)
                    else
                        hooks.collectionDragIcon:SetParent(UIParent)
                    end
                    hooks.collectionDragIcon:SetFrameStrata("TOOLTIP")
                    hooks.collectionDragIcon:SetFrameLevel(500)
                    
                    if self.icon:GetTexture() then
                        hooks.collectionDragIcon.icon:SetTexture(self.icon:GetTexture())
                    elseif self.icon:GetAtlas() then
                        hooks.collectionDragIcon.icon:SetAtlas(self.icon:GetAtlas())
                    end
                    hooks.collectionDragIcon:Show()
                    
                    hooks.collectionDragIcon:SetScript("OnUpdate", function(dragFrame)
                        local x, y = GetCursorPosition()
                        local scale = dragFrame:GetParent():GetEffectiveScale()
                        dragFrame:ClearAllPoints()
                        dragFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
                    end)
                end
                
                self:SetAlpha(0.4)
                self.border:SetVertexColor(1, 1, 0) -- Gelb
                GameTooltip:Hide()
                
                -- Drop-Highlights auf Top 10 Slots zeigen
                for _, slotBtn in pairs(hooks.collectionSlotButtons or {}) do
                    if slotBtn.dropHighlight then
                        slotBtn.dropHighlight:Show()
                    end
                end
                
                DreamHouse.Debug:Log("Collections", "Drag gestartet von unterem Item (Index " .. self.originalIndex .. ")", "DEBUG")
            end)
            
            btn:SetScript("OnDragStop", function(self)
                local hooks = DreamHouse.Hooks.Storage
                
                if hooks.collectionDragIcon then
                    hooks.collectionDragIcon:Hide()
                    hooks.collectionDragIcon:SetScript("OnUpdate", nil)
                    hooks.collectionDragIcon:ClearAllPoints()
                end
                
                -- Drop-Ziel finden (nur Top 10 Slots)
                if hooks.collectionDragData then
                    local mouseFoci = GetMouseFoci and GetMouseFoci() or {GetMouseFocus()}
                    local targetFrame = mouseFoci[1]
                    
                    if targetFrame and targetFrame.slotIndex and targetFrame.isTopSlot then
                        -- In Top 10 gezogen - Items tauschen
                        hooks:SwapCollectionItems(hooks.collectionDragData.fromSlot, targetFrame.slotIndex)
                        DreamHouse.Debug:Log("Collections", "Item von unten in Top Slot " .. targetFrame.slotIndex .. " gezogen!", "SUCCESS")
                        PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
                    else
                        DreamHouse.Debug:Log("Collections", "Drop außerhalb eines Top-Slots", "DEBUG")
                    end
                end
                
                self:SetAlpha(1)
                self.border:SetVertexColor(1, 1, 1)
                
                -- Alle Drop-Highlights verstecken
                for _, slotBtn in pairs(hooks.collectionSlotButtons or {}) do
                    if slotBtn.dropHighlight then
                        slotBtn.dropHighlight:Hide()
                    end
                end
                
                hooks.collectionIsDragging = false
                hooks.collectionDragData = nil
            end)
            
            -- Positionierung
            local row = math.floor((i - 1) / itemsPerRow)
            local col = (i - 1) % itemsPerRow
            btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", startX + col * (itemSize + itemSpacing), currentY - row * (itemSize + itemSpacing))
        end
        
        -- Höhe berechnen: Top-Slots + Separator + Restliche Items
        local remainingRows = math.ceil(#remainingItems / itemsPerRow)
        contentHeight = math.abs(currentY) + (remainingRows * (itemSize + itemSpacing)) + 20
    end
    
    -- ScrollChild-Höhe auf tatsächlichen Inhalt setzen (verhindert leeres Scrollen)
    scrollChild:SetHeight(contentHeight)
end

-- Versteckt das Kollektionen-UI
function DreamHouse.Hooks.Storage:HideCollectionsUI()
    if self.collectionsContainer then
        self.collectionsContainer:Hide()
    end
    if self.detailContainer then
        self.detailContainer:Hide()
    end
end

-- Prüft ob wir im Kollektionen-Modus sind
function DreamHouse.Hooks.Storage:IsInCollectionsMode()
    return self.isInCollectionsMode
end

-- Verlässt den Kollektionen-Modus
function DreamHouse.Hooks.Storage:ExitCollectionsMode()
    if not self.isInCollectionsMode then
        return
    end
    
    DreamHouse.Debug:Log("Collections", "ExitCollectionsMode wird ausgeführt...", "DEBUG")
    
    self.isInCollectionsMode = false
    self.lastSelectedTab = "storage" -- Tab-Zustand speichern
    
    -- Kollektionen-UI verstecken
    self:HideCollectionsUI()
    self:HideCollectionsHeader()
    
    -- Detailansicht verstecken & Header Reset
    if self.detailContainer then self.detailContainer:Hide() end
    if self.backButton then self.backButton:Hide() end
    self.currentCollection = nil
    
    local storageFrame = self.hookedStorageFrame
    if storageFrame then
        -- Original UI-Elemente wieder anzeigen
        if storageFrame.Filters then
            storageFrame.Filters:Show()
            storageFrame.Filters:SetEnabled(true)
            DreamHouse.Debug:Log("Collections", "Filters wieder sichtbar", "DEBUG")
        end
        
        if storageFrame.SearchBox then
            storageFrame.SearchBox:Show()
            DreamHouse.Debug:Log("Collections", "SearchBox wieder sichtbar", "DEBUG")
        end
        
        if storageFrame.Categories then
            storageFrame.Categories:Show()
            storageFrame.Categories:ClearFocus()
            DreamHouse.Debug:Log("Collections", "Categories wieder sichtbar", "DEBUG")
        end
        
        if storageFrame.OptionsContainer then
            storageFrame.OptionsContainer:Show()
            DreamHouse.Debug:Log("Collections", "OptionsContainer wieder sichtbar", "DEBUG")
        end
        
        -- LoadingSpinner verstecken falls sichtbar
        if storageFrame.LoadingSpinner then
            storageFrame.LoadingSpinner:Hide()
        end
    end
    
    DreamHouse.Debug:Log("Collections", "Kollektionen-Modus beendet", "SUCCESS")
    DreamHouse.Events:Fire("DREAMHOUSE_COLLECTIONS_TAB_DESELECTED")
end

-- Hook für Tab-Wechsel (um Kollektionen-Modus zu beenden wenn anderer Tab gewählt)
function DreamHouse.Hooks.Storage:HookTabChanges(storageFrame)
    if not storageFrame then return end
    
    -- Prüfe ob bereits gehookt
    if self.tabChangesHooked then
        DreamHouse.Debug:Log("Collections", "Tab-Wechsel bereits gehookt", "DEBUG")
        return
    end
    
    DreamHouse.Debug:Log("Collections", "HookTabChanges - collectionsTabID: " .. tostring(self.collectionsTabID), "DEBUG")
    
    -- Hook auf das TabSystem selbst (SetTabVisuallySelected wird bei Klick aufgerufen)
    if storageFrame.TabSystem then
        hooksecurefunc(storageFrame.TabSystem, "SetTabVisuallySelected", function(tabSystem, tabID)
            DreamHouse.Debug:Log("Collections", "TabSystem.SetTabVisuallySelected: tabID = " .. tostring(tabID), "DEBUG")
            
            -- Wenn wir im Kollektionen-Modus waren und ein anderer Tab gewählt wird
            if DreamHouse.Hooks.Storage.isInCollectionsMode then
                if tabID ~= DreamHouse.Hooks.Storage.collectionsTabID then
                    DreamHouse.Debug:Log("Collections", "Verlasse Kollektionen-Modus für Tab " .. tostring(tabID), "INFO")
                    DreamHouse.Hooks.Storage:ExitCollectionsMode()
                    
                    -- Triggere Daten-Refresh für den neuen Tab
                    C_Timer.After(0.1, function()
                        if storageFrame.catalogSearcher then
                            DreamHouse.Debug:Log("Collections", "Triggere catalogSearcher:RunSearch()", "DEBUG")
                            storageFrame.catalogSearcher:RunSearch()
                        end
                    end)
                end
            end
        end)
        DreamHouse.Debug:Log("Collections", "TabSystem Hook auf SetTabVisuallySelected installiert", "SUCCESS")
    else
        DreamHouse.Debug:Log("Collections", "WARNUNG: TabSystem nicht gefunden!", "WARN")
    end
    
    -- Zusätzlich: Hook auf internalTabTracker falls vorhanden
    if storageFrame.internalTabTracker then
        hooksecurefunc(storageFrame.internalTabTracker, "SetTab", function(tracker, tabID)
            DreamHouse.Debug:Log("Collections", "internalTabTracker.SetTab: tabID = " .. tostring(tabID), "DEBUG")
        end)
        DreamHouse.Debug:Log("Collections", "internalTabTracker Hook installiert", "SUCCESS")
    end
    
    self.tabChangesHooked = true
    DreamHouse.Debug:Log("Collections", "Tab-Wechsel Hooks installiert", "SUCCESS")
end

-- =====================================
-- KOLLEKTIONS-HOTBAR-MODUS
-- =====================================

-- Toggle für Kollektions-Hotbar-Modus
function DreamHouse.Hooks.Storage:ToggleCollectionHotbarMode()
    self.collectionHotbarModeActive = not self.collectionHotbarModeActive
    
    -- Button-Zustand aktualisieren
    if self.headerSettingsBtn then
        self.headerSettingsBtn.isActive = self.collectionHotbarModeActive
        if self.collectionHotbarModeActive then
            self.headerSettingsBtn.activeTex:Show()
        else
            self.headerSettingsBtn.activeTex:Hide()
        end
    end
    
    -- Status speichern
    self:SaveCollectionSettings()
    
    if self.collectionHotbarModeActive then
        -- Modus aktiviert: Standard-Layout speichern
        self:SaveStandardHotbarLayout()
        DreamHouse.Debug:Log("Collections", "Kollektions-Hotbar-Modus AKTIVIERT", "SUCCESS")
        
        -- Wenn eine aktive Kollektion existiert, Items laden
        if self.activeCollectionID then
            self:LoadCollectionToHotbar(self.activeCollectionID)
        end
    else
        -- Modus deaktiviert: Standard-Layout wiederherstellen
        self:RestoreStandardHotbarLayout()
        DreamHouse.Debug:Log("Collections", "Kollektions-Hotbar-Modus DEAKTIVIERT", "INFO")
    end
    
    -- UI aktualisieren (für Aktiv-Anzeige)
    self:UpdateCollectionsUI()
end

-- Speichert das aktuelle Hotbar-Layout als Standard
function DreamHouse.Hooks.Storage:SaveStandardHotbarLayout()
    if not DreamHouse.Hotbar then return end
    
    local layout = {}
    for i = 1, 10 do
        local slotData = DreamHouse.Hotbar:GetSlotData(i)
        if slotData and slotData.entryID then
            layout[i] = {
                entryID = slotData.entryID,
                entryType = slotData.entryType,
                recordID = slotData.recordID
            }
        end
    end
    
    -- In SavedVariables speichern
    if not DreamHouseDB then DreamHouseDB = {} end
    DreamHouseDB.hb_standard_layout = layout
    
    DreamHouse.Debug:Log("Collections", "Standard-Hotbar-Layout gespeichert", "SUCCESS")
end

-- Stellt das Standard-Hotbar-Layout wieder her
function DreamHouse.Hooks.Storage:RestoreStandardHotbarLayout()
    if not DreamHouse.Hotbar then return end
    if not DreamHouseDB or not DreamHouseDB.hb_standard_layout then
        DreamHouse.Debug:Log("Collections", "Kein Standard-Layout gespeichert", "WARN")
        return
    end
    
    local layout = DreamHouseDB.hb_standard_layout
    
    -- Alle Slots leeren
    for i = 1, 10 do
        DreamHouse.Hotbar:ClearSlot(i)
    end
    
    -- Layout wiederherstellen
    for i, data in pairs(layout) do
        if data.entryID then
            DreamHouse.Hotbar:SetSlotByEntryID(i, data.entryID)
        end
    end
    
    DreamHouse.Debug:Log("Collections", "Standard-Hotbar-Layout wiederhergestellt", "SUCCESS")
end

-- Lädt die ersten 10 Items einer Kollektion in die Hotbar
function DreamHouse.Hooks.Storage:LoadCollectionToHotbar(collectionID)
    if not DreamHouse.Hotbar then return end
    if not DreamHouse.Collections then return end
    
    local collection = DreamHouse.Collections:GetCollectionByID(collectionID)
    if not collection then
        DreamHouse.Debug:Log("Collections", "Kollektion nicht gefunden: " .. tostring(collectionID), "ERROR")
        return
    end
    
    -- Alle Slots leeren
    for i = 1, 10 do
        DreamHouse.Hotbar:ClearSlot(i)
    end
    
    -- Erste 10 Items in Hotbar setzen
    local items = collection.items or {}
    for i = 1, math.min(10, #items) do
        local itemData = items[i]
        if itemData then
            local recordID = itemData.recordID or itemData
            local entryType = itemData.entryType or Enum.HousingCatalogEntryType.Decor
            
            -- EntryID aus recordID erstellen
            local entryID = { entryType = entryType, recordID = recordID }
            DreamHouse.Hotbar:SetSlotByEntryID(i, entryID)
        end
    end
    
    DreamHouse.Debug:Log("Collections", "Kollektion in Hotbar geladen: " .. (collection.name or "?"), "SUCCESS")
end

-- Tauscht zwei Items in der aktuellen Kollektion (für Drag & Drop)
function DreamHouse.Hooks.Storage:SwapCollectionItems(fromSlot, toSlot)
    if not self.currentCollection then
        DreamHouse.Debug:Log("Collections", "SwapCollectionItems: Keine aktive Kollektion", "ERROR")
        return
    end
    
    local collectionID = self.currentCollection.id
    DreamHouse.Debug:Log("Collections", "SwapCollectionItems: " .. fromSlot .. " <-> " .. toSlot .. " in " .. collectionID, "DEBUG")
    
    -- Items in der Kollektion tauschen
    if DreamHouse.Collections then
        local success = DreamHouse.Collections:SwapItemsInCollection(collectionID, fromSlot, toSlot)
        if not success then
            DreamHouse.Debug:Log("Collections", "SwapItemsInCollection fehlgeschlagen!", "ERROR")
            return
        end
    end
    
    -- currentCollection aktualisieren (zeigt auf die gleiche Tabelle, wurde schon geändert)
    -- NICHT LoadSavedCollections aufrufen - das würde die Änderungen überschreiben!
    self.currentCollection = DreamHouse.Collections:GetCollectionByID(collectionID)
    
    if not self.currentCollection then
        DreamHouse.Debug:Log("Collections", "FEHLER: Kollektion nach Swap nicht gefunden!", "ERROR")
        return
    end
    
    -- Debug: Items vor dem Render
    DreamHouse.Debug:Log("Collections", "=== ITEMS VOR RENDER ===", "DEBUG")
    for idx = 1, 10 do
        local item = self.currentCollection.items[idx]
        DreamHouse.Debug:Log("Collections", "  currentCollection.items[" .. idx .. "] = " .. (item and tostring(item.recordID) or "nil"), "DEBUG")
    end
    
    -- UI aktualisieren (mit kleinem Delay für sauberen Render)
    C_Timer.After(0.01, function()
        DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
    end)
    
    -- Wenn KHM aktiv ist UND dies die aktive Kollektion ist, Hotbar synchronisieren
    if self.collectionHotbarModeActive and self.activeCollectionID == collectionID then
        if DreamHouse.Hotbar then
            -- Nur wenn BEIDE Slots innerhalb der Top 10 sind, können wir swappen
            if fromSlot <= 10 and toSlot <= 10 then
                DreamHouse.Hotbar:SwapSlots(fromSlot, toSlot, true) -- true = skipCollectionSync
                DreamHouse.Debug:Log("Collections", "Hotbar Slots getauscht: " .. fromSlot .. " <-> " .. toSlot, "SUCCESS")
            else
                -- Ein Slot ist außerhalb der Top 10 - Hotbar komplett neu laden
                self:LoadCollectionToHotbar(collectionID)
                DreamHouse.Debug:Log("Collections", "Hotbar komplett neu geladen (Item von/nach außerhalb Top 10)", "SUCCESS")
            end
        end
    end
    
    DreamHouse.Debug:Log("Collections", "SwapCollectionItems abgeschlossen: " .. fromSlot .. " <-> " .. toSlot, "SUCCESS")
end

-- Setzt eine Kollektion als aktiv
function DreamHouse.Hooks.Storage:SetActiveCollection(collectionID)
    local previousActive = self.activeCollectionID
    self.activeCollectionID = collectionID
    
    -- In SavedVariables speichern
    if not DreamHouseDB then DreamHouseDB = {} end
    DreamHouseDB.activeCollectionID = collectionID
    
    -- Wenn Hotbar-Modus aktiv, Items laden
    if self.collectionHotbarModeActive and collectionID then
        self:LoadCollectionToHotbar(collectionID)
    end
    
    -- UI aktualisieren
    self:UpdateCollectionsUI()
    
    DreamHouse.Debug:Log("Collections", "Aktive Kollektion gesetzt: " .. tostring(collectionID), "SUCCESS")
end

-- ============================================
-- 3D VORSCHAU
-- ============================================

-- Erstellt oder zeigt das 3D-Vorschau-Fenster
function DreamHouse.Hooks.Storage:Show3DPreview(entryType, recordID, itemName)
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
    if not entryInfo then
        DreamHouse.Debug:Log("Collections", "3D Vorschau: Keine entryInfo gefunden", "WARN")
        return
    end
    
    -- Debug: Alle verfügbaren Felder der entryInfo loggen
    DreamHouse.Debug:Log("Collections", "3D Vorschau entryInfo für " .. (itemName or "?") .. ":", "DEBUG")
    for key, value in pairs(entryInfo) do
        local valueStr = tostring(value)
        if type(value) == "table" then
            valueStr = "table[" .. #value .. "]"
        end
        DreamHouse.Debug:Log("Collections", "  " .. key .. " = " .. valueStr, "DEBUG")
    end
    
    -- Model-Daten ermitteln (verschiedene mögliche Quellen)
    local modelSceneID = entryInfo.uiModelSceneID or entryInfo.modelScene or entryInfo.modelSceneID or entryInfo.displayModelSceneID
    local modelFileID = entryInfo.asset or entryInfo.modelFileID or entryInfo.displayID or entryInfo.fileDataID
    
    -- Versuche über C_HousingDecor API (falls verfügbar)
    if not modelSceneID and not modelFileID and C_HousingDecor then
        if C_HousingDecor.GetDecorModelScene then
            local success, result = pcall(C_HousingDecor.GetDecorModelScene, recordID)
            if success and result then
                modelSceneID = result
                DreamHouse.Debug:Log("Collections", "ModelScene via C_HousingDecor: " .. tostring(result), "DEBUG")
            end
        end
        if not modelSceneID and C_HousingDecor.GetDecorModelFileID then
            local success, result = pcall(C_HousingDecor.GetDecorModelFileID, recordID)
            if success and result then
                modelFileID = result
                DreamHouse.Debug:Log("Collections", "ModelFileID via C_HousingDecor: " .. tostring(result), "DEBUG")
            end
        end
    end
    
    -- Parent bestimmen - HouseEditorFrame wenn aktiv (damit sichtbar wenn UI ausgeblendet)
    local parentFrame = UIParent
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
        parentFrame = HouseEditorFrame
    end
    
    -- Frame erstellen falls nicht vorhanden
    if not self.preview3DFrame then
        local frame = CreateFrame("Frame", "DreamHouse3DPreview", parentFrame, "BackdropTemplate")
        frame:SetSize(350, 400)  -- Größer für bessere 3D-Ansicht
        -- Position relativ zu UIParent damit sie konsistent bleibt
        frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
        frame:SetFrameStrata("FULLSCREEN_DIALOG")
        frame:SetFrameLevel(500)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetClampedToScreen(true)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        frame:Hide()
        
        -- DressUpModel für 3D Anzeige - FÜLLT DAS GANZE FENSTER AUS
        local model = CreateFrame("DressUpModel", nil, frame)
        model:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
        model:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
        model:SetFrameLevel(frame:GetFrameLevel() + 1)
        frame.model = model
        
        -- Dunkler Hintergrund für Model (hinter dem Model)
        local modelBg = frame:CreateTexture(nil, "BACKGROUND")
        modelBg:SetAllPoints(model)
        modelBg:SetColorTexture(0.03, 0.03, 0.03, 0.95)
        modelBg:SetDrawLayer("BACKGROUND", -1)
        
        -- Titel-Container (über dem Model, mit halbtransparentem Hintergrund)
        local titleBg = frame:CreateTexture(nil, "ARTWORK")
        titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
        titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -35, -10)  -- Platz für Close-Button
        titleBg:SetHeight(36)
        titleBg:SetColorTexture(0, 0, 0, 0.7)
        frame.titleBg = titleBg
        
        -- Titel - kleiner, mit Zeilenumbruch, max. Breite
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", titleBg, "TOPLEFT", 8, -4)
        title:SetPoint("TOPRIGHT", titleBg, "TOPRIGHT", -8, -4)
        title:SetTextColor(1, 0.82, 0)
        title:SetJustifyH("LEFT")
        title:SetJustifyV("TOP")
        title:SetWordWrap(true)
        title:SetMaxLines(2)
        frame.title = title
        
        -- Close Button (über allem)
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
        closeBtn:SetFrameLevel(frame:GetFrameLevel() + 10)
        closeBtn:SetScript("OnClick", function() frame:Hide() end)
        
        -- Info-Text unten (über dem Model, mit halbtransparentem Hintergrund)
        local infoBg = frame:CreateTexture(nil, "ARTWORK")
        infoBg:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
        infoBg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
        infoBg:SetHeight(20)
        infoBg:SetColorTexture(0, 0, 0, 0.7)
        frame.infoBg = infoBg
        
        local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        infoText:SetPoint("CENTER", infoBg, "CENTER", 0, 0)
        infoText:SetTextColor(0.8, 0.8, 0.8)
        infoText:SetText("Mausrad: Zoom | Ziehen: Drehen")
        frame.infoText = infoText
        
        -- Rotation-Tracking für Drag
        frame.rotation = 0
        frame.isDragging = false
        frame.camDistance = 2.5  -- Start-Kameradistanz
        
        -- Drag zum Drehen
        model:EnableMouse(true)
        model:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                frame.isDragging = true
                frame.lastX = GetCursorPosition()
            end
        end)
        model:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                frame.isDragging = false
            end
        end)
        model:SetScript("OnUpdate", function(self)
            if frame.isDragging then
                local currentX = GetCursorPosition()
                local delta = (currentX - (frame.lastX or currentX)) * 0.01
                frame.rotation = (frame.rotation or 0) + delta
                self:SetFacing(frame.rotation)
                frame.lastX = currentX
            end
        end)
        
        -- Mausrad-Zoom (Kamera-Distanz ändern)
        model:EnableMouseWheel(true)
        model:SetScript("OnMouseWheel", function(self, delta)
            -- Versuche Kamera-Distanz zu ändern (besser für große Objekte)
            if self.SetCamDistanceScale then
                local currentDist = frame.camDistance or 2.5
                local newDist = currentDist - (delta * 0.3)
                if newDist < 0.5 then newDist = 0.5 end
                if newDist > 10 then newDist = 10 end
                frame.camDistance = newDist
                self:SetCamDistanceScale(newDist)
            else
                -- Fallback: Model-Scale ändern
                local scale = self:GetModelScale() or 0.5
                local newScale = scale + (delta * 0.05)
                if newScale < 0.05 then newScale = 0.05 end
                if newScale > 2 then newScale = 2 end
                self:SetModelScale(newScale)
            end
        end)
        
        -- Escape zum Schließen
        frame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                self:Hide()
                self:SetPropagateKeyboardInput(false)
            else
                self:SetPropagateKeyboardInput(true)
            end
        end)
        
        self.preview3DFrame = frame
        DreamHouse.Debug:Log("Collections", "3D Vorschau Frame erstellt", "DEBUG")
    end
    
    -- Frame aktualisieren und anzeigen
    local frame = self.preview3DFrame
    
    -- Parent aktualisieren (wichtig: HouseEditorFrame wenn Editor aktiv, damit Frame sichtbar bleibt)
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
        frame:SetParent(HouseEditorFrame)
    else
        frame:SetParent(UIParent)
    end
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(500)
    
    frame.title:SetText(itemName or "3D Vorschau")
    
    -- Model laden (mit den ermittelten Werten)
    local modelLoaded = false
    
    -- Reset: Rotation, Scale und Kamera zurücksetzen
    frame.rotation = 0
    frame.camDistance = 2.5
    pcall(function() frame.model:SetFacing(0) end)
    pcall(function() frame.model:SetModelScale(0.5) end)
    
    -- Versuche verschiedene Methoden um das Model zu laden
    
    -- Methode 1: SetModelByFileID (für FileDataIDs)
    if modelFileID and not modelLoaded then
        if frame.model.SetModelByFileID then
            local success, err = pcall(function()
                frame.model:SetModelByFileID(modelFileID)
            end)
            if success then
                modelLoaded = true
                DreamHouse.Debug:Log("Collections", "3D Vorschau: SetModelByFileID " .. modelFileID .. " erfolgreich", "SUCCESS")
            else
                DreamHouse.Debug:Log("Collections", "3D Vorschau: SetModelByFileID Fehler: " .. tostring(err), "DEBUG")
            end
        end
    end
    
    -- Methode 2: SetModel (klassisch)
    if modelFileID and not modelLoaded then
        local success, err = pcall(function()
            frame.model:SetModel(modelFileID)
        end)
        if success then
            modelLoaded = true
            DreamHouse.Debug:Log("Collections", "3D Vorschau: SetModel " .. modelFileID .. " erfolgreich", "SUCCESS")
        else
            DreamHouse.Debug:Log("Collections", "3D Vorschau: SetModel Fehler: " .. tostring(err), "DEBUG")
        end
    end
    
    -- Methode 3: SetDisplayInfo (falls asset eine DisplayID ist)
    if modelFileID and not modelLoaded then
        if frame.model.SetDisplayInfo then
            local success, err = pcall(function()
                frame.model:SetDisplayInfo(modelFileID)
            end)
            if success then
                modelLoaded = true
                DreamHouse.Debug:Log("Collections", "3D Vorschau: SetDisplayInfo " .. modelFileID .. " erfolgreich", "SUCCESS")
            else
                DreamHouse.Debug:Log("Collections", "3D Vorschau: SetDisplayInfo Fehler: " .. tostring(err), "DEBUG")
            end
        end
    end
    
    -- Kamera/Position anpassen wenn Model geladen
    if modelLoaded then
        -- Funktion um Kamera anzupassen (wird sofort und verzögert aufgerufen)
        local function ApplyCameraSettings()
            pcall(function()
                -- Model zentrieren
                frame.model:SetPosition(0, 0, 0)
                
                -- Kamera weiter weg setzen
                if frame.model.SetCamDistanceScale then
                    frame.model:SetCamDistanceScale(frame.camDistance or 2.5)
                end
                
                -- Portrait-Zoom deaktivieren (zeigt ganzes Objekt)
                if frame.model.SetPortraitZoom then
                    frame.model:SetPortraitZoom(0)
                end
                
                -- Model-Skalierung anpassen
                if frame.model.SetModelScale then
                    frame.model:SetModelScale(0.5)
                end
                
                -- Kamera-Position anpassen falls möglich
                if frame.model.RefreshCamera then
                    frame.model:RefreshCamera()
                end
            end)
        end
        
        -- Sofort anwenden
        ApplyCameraSettings()
        
        -- Und nochmal nach kurzer Verzögerung (für langsam ladende Models)
        C_Timer.After(0.1, ApplyCameraSettings)
        C_Timer.After(0.3, ApplyCameraSettings)
        
        DreamHouse.Debug:Log("Collections", "3D Vorschau: Kamera angepasst", "DEBUG")
    end
    
    if not modelLoaded then
        -- Kein Model gefunden
        DreamHouse.Debug:Log("Collections", "3D Vorschau: Kein Model geladen für " .. (itemName or "?") .. " (asset: " .. tostring(modelFileID) .. ", sceneID: " .. tostring(modelSceneID) .. ")", "WARN")
        
        -- Zeige Frame mit Fehlermeldung (Model auf nil setzen um es zu leeren)
        pcall(function() frame.model:SetModel(0) end)  -- Leeres Model
        frame.title:SetText((itemName or "?") .. "\n|cffff6666Kein 3D-Model verfügbar|r")
        frame.infoText:SetText("|cff888888Asset: " .. tostring(modelFileID) .. "|r")
    else
        frame.infoText:SetText("Mausrad: Zoom | Ziehen: Drehen")
    end
    
    frame:Show()
    frame:Raise()
end

-- Entfernt den Aktiv-Status
function DreamHouse.Hooks.Storage:ClearActiveCollection()
    self.activeCollectionID = nil
    
    -- In SavedVariables speichern
    if DreamHouseDB then
        DreamHouseDB.activeCollectionID = nil
    end
    
    -- Wenn Hotbar-Modus aktiv, Standard-Layout wiederherstellen
    if self.collectionHotbarModeActive then
        self:RestoreStandardHotbarLayout()
    end
    
    -- UI aktualisieren
    self:UpdateCollectionsUI()
    
    DreamHouse.Debug:Log("Collections", "Aktive Kollektion entfernt", "INFO")
end

-- Lädt gespeicherte Einstellungen
function DreamHouse.Hooks.Storage:LoadCollectionSettings()
    if DreamHouseDB then
        self.activeCollectionID = DreamHouseDB.activeCollectionID
        self.collectionHotbarModeActive = DreamHouseDB.collectionHotbarModeActive or false
        
        -- Button-Zustand aktualisieren wenn er existiert
        if self.headerSettingsBtn then
            self.headerSettingsBtn.isActive = self.collectionHotbarModeActive
            if self.collectionHotbarModeActive then
                self.headerSettingsBtn.activeTex:Show()
            else
                self.headerSettingsBtn.activeTex:Hide()
            end
        end
        
        DreamHouse.Debug:Log("Collections", "Settings geladen: KHM=" .. tostring(self.collectionHotbarModeActive) .. ", activeCollection=" .. tostring(self.activeCollectionID), "DEBUG")
    end
end

-- Speichert Kollektions-Einstellungen
function DreamHouse.Hooks.Storage:SaveCollectionSettings()
    if not DreamHouseDB then DreamHouseDB = {} end
    DreamHouseDB.activeCollectionID = self.activeCollectionID
    DreamHouseDB.collectionHotbarModeActive = self.collectionHotbarModeActive
    DreamHouse.Debug:Log("Collections", "Settings gespeichert: KHM=" .. tostring(self.collectionHotbarModeActive), "DEBUG")
end

-- Modul registrieren
DreamHouse:RegisterModule("StorageHooks", DreamHouse.Hooks.Storage)
