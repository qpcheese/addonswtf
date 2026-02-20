--[[
    DreamHouse - Core
    Haupt-Initialisierung und Event-Handling
    
    Erweitert das native WoW Housing UI mit zusätzlichen Features
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

-- Addon-Version
DreamHouse.version = "1.5.0"
DreamHouse.name = "DreamHouse"

-- Event-System
DreamHouse.Events = {}
local eventCallbacks = {}

function DreamHouse.Events:Register(event, callback, owner)
    if not eventCallbacks[event] then
        eventCallbacks[event] = {}
    end
    table.insert(eventCallbacks[event], { callback = callback, owner = owner })
end

function DreamHouse.Events:Unregister(event, owner)
    if not eventCallbacks[event] then return end
    
    for i = #eventCallbacks[event], 1, -1 do
        if eventCallbacks[event][i].owner == owner then
            table.remove(eventCallbacks[event], i)
        end
    end
end

function DreamHouse.Events:Fire(event, ...)
    if not eventCallbacks[event] then return end
    
    for _, registration in ipairs(eventCallbacks[event]) do
        local success, err = pcall(registration.callback, registration.owner, ...)
        if not success then
            DreamHouse.Debug:Log("Events", "Callback-Fehler bei " .. event .. ": " .. tostring(err), "ERROR")
        end
    end
end

-- Haupt-Event-Frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

-- Housing-spezifische Events
local housingEvents = {
    "HOUSE_PLOT_ENTERED",
    "HOUSE_PLOT_EXITED",
    "HOUSE_EDITOR_MODE_CHANGED",
    "HOUSE_EDITOR_AVAILABILITY_CHANGED",
    "HOUSING_STORAGE_UPDATED",
    "HOUSING_STORAGE_ENTRY_UPDATED",
    "HOUSING_DECOR_PLACE_SUCCESS",
    "HOUSING_DECOR_REMOVED",
    "CURRENT_HOUSE_INFO_RECIEVED",
    "HOUSE_INFO_UPDATED",
}

-- Module-Registry
DreamHouse.modules = {}

function DreamHouse:RegisterModule(name, module)
    self.modules[name] = module
    DreamHouse.Debug:Log("Core", "Modul registriert: " .. name, "DEBUG")
end

function DreamHouse:GetModule(name)
    return self.modules[name]
end

-- Initialisierung
local function OnAddonLoaded(loadedAddon)
    if loadedAddon ~= addonName then return end
    
    -- Settings initialisieren (muss zuerst sein!)
    DreamHouse.Settings:Initialize()
    
    -- Debug-Konsole erstellen
    DreamHouse.Debug:CreateConsole()
    
    DreamHouse.Debug:Log("Core", "DreamHouse v" .. DreamHouse.version .. " geladen", "SUCCESS")
    DreamHouse.Debug:Log("Core", "Housing-Erweiterungen werden initialisiert...", "INFO")
    
    -- Housing-Events registrieren
    for _, event in ipairs(housingEvents) do
        eventFrame:RegisterEvent(event)
    end
    
    DreamHouse.Debug:Log("Core", #housingEvents .. " Housing-Events registriert", "DEBUG")
end

-- Login-Handler
local function OnPlayerLogin()
    DreamHouse.Debug:Log("Core", "Spieler eingeloggt - Module werden aktiviert", "INFO")
    
    -- Module initialisieren
    C_Timer.After(0.5, function()
        DreamHouse:InitializeModules()
    end)
    
    -- Slash-Commands registrieren
    DreamHouse:RegisterSlashCommands()
end

-- Module initialisieren
function DreamHouse:InitializeModules()
    -- Alle registrierten Module initialisieren
    for name, module in pairs(self.modules) do
        if module.Initialize then
            local success, err = pcall(module.Initialize, module)
            if success then
                DreamHouse.Debug:Log("Core", "Modul initialisiert: " .. name, "SUCCESS")
            else
                DreamHouse.Debug:Log("Core", "Modul-Fehler " .. name .. ": " .. tostring(err), "ERROR")
            end
        end
    end
    
    -- Hooks anwenden
    self:ApplyHooks()
end

-- Blizzard-Hooks anwenden
function DreamHouse:ApplyHooks()
    DreamHouse.Debug:Log("Core", "Wende Blizzard-Hooks an...", "INFO")
    
    -- Storage-Panel Hooks
    if DreamHouse.Hooks and DreamHouse.Hooks.Storage then
        DreamHouse.Hooks.Storage:Apply()
    end
    
    -- Editor-Frame Hooks
    if DreamHouse.Hooks and DreamHouse.Hooks.Editor then
        DreamHouse.Hooks.Editor:Apply()
    end
    
    -- Favoriten-Kategorie Hook
    if DreamHouse.FavoritesCategory then
        DreamHouse.FavoritesCategory:Apply()
    end
    
    -- Vendor-Datenbank Hook
    if DreamHouse.VendorDatabase then
        DreamHouse.VendorDatabase:Apply()
    end
    
    DreamHouse.Debug:Log("Core", "Hooks angewendet", "SUCCESS")
end

-- Housing-Event Handler
local function OnHousingEvent(event, ...)
    DreamHouse.Debug:Log("Housing", event, "DEBUG")
    
    if event == "HOUSE_PLOT_ENTERED" then
        DreamHouse.Debug:Log("Housing", "Plot betreten", "INFO")
        DreamHouse.Events:Fire("DREAMHOUSE_ENTERED_PLOT")
        
    elseif event == "HOUSE_PLOT_EXITED" then
        DreamHouse.Debug:Log("Housing", "Plot verlassen", "INFO")
        DreamHouse.Events:Fire("DREAMHOUSE_EXITED_PLOT")
        
    elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
        local newMode = ...
        local modeName = DreamHouse.Utils:GetEditorModeName(newMode)
        DreamHouse.Debug:Log("Housing", "Editor-Modus: " .. modeName, "INFO")
        DreamHouse.Events:Fire("DREAMHOUSE_MODE_CHANGED", newMode, modeName)
        
    elseif event == "HOUSING_DECOR_PLACE_SUCCESS" then
        local decorGUID, size, isNew = ...
        if isNew then
            DreamHouse.Debug:Log("Housing", "Neues Decor platziert", "INFO")
        end
        DreamHouse.Events:Fire("DREAMHOUSE_DECOR_PLACED", decorGUID, size, isNew)
        
    elseif event == "HOUSING_DECOR_REMOVED" then
        local decorGUID = ...
        DreamHouse.Debug:Log("Housing", "Decor entfernt", "INFO")
        DreamHouse.Events:Fire("DREAMHOUSE_DECOR_REMOVED", decorGUID)
        
    elseif event == "HOUSING_STORAGE_UPDATED" then
        DreamHouse.Debug:Log("Housing", "Storage aktualisiert", "DEBUG")
        DreamHouse.Events:Fire("DREAMHOUSE_STORAGE_UPDATED")
    end
end

-- Slash-Commands
function DreamHouse:RegisterSlashCommands()
    SLASH_DREAMHOUSE1 = "/dreamhouse"
    SLASH_DREAMHOUSE2 = "/dh"
    
    SlashCmdList["DREAMHOUSE"] = function(msg)
        local cmd, args = msg:match("^(%S*)%s*(.-)$")
        cmd = cmd:lower()
        
        if cmd == "" or cmd == "help" then
            print("|cff00ccff[DreamHouse]|r " .. L["Commands"])
            print("  " .. L["/dh debug"])
            print("  " .. L["/dh export"])
            print("  " .. L["/dh stats"])
            print("  " .. L["/dh favorites"])
            print("  " .. L["/dh hotbar"])
            print("  " .. L["/dh vendordb"])
            print("  " .. L["/dh reset"])
            print("  " .. L["/dh test"])
            
        elseif cmd == "debug" then
            DreamHouse.Debug:Toggle()
            
        elseif cmd == "export" then
            DreamHouse.Debug:ShowExportPopup()
            
        elseif cmd == "test" then
            DreamHouse.Debug:Log("Test", "Das ist eine Test-Nachricht!", "INFO")
            DreamHouse.Debug:Log("Test", "Debug Level", "DEBUG")
            DreamHouse.Debug:Log("Test", "Warning Level", "WARN")
            DreamHouse.Debug:Log("Test", "Error Level", "ERROR")
            DreamHouse.Debug:Log("Test", "Success Level", "SUCCESS")
            print("|cff00ccff[DreamHouse]|r " .. L.Format("X test messages written", 5))
            
        elseif cmd == "stats" then
            if DreamHouse.StatsPanel then
                DreamHouse.StatsPanel:Toggle()
            else
                print("|cff00ccff[DreamHouse]|r " .. L["Stats Panel not available yet"])
            end
            
        elseif cmd == "favorites" then
            local favs = DreamHouse.Settings:GetAllFavorites()
            local count = DreamHouse.Utils:TableCount(favs)
            print("|cff00ccff[DreamHouse]|r " .. L.Format("You have X favorites", count))
            
        elseif cmd == "hotbar" then
            if DreamHouse.Hotbar then
                DreamHouse.Hotbar:Toggle()
            else
                print("|cff00ccff[DreamHouse]|r " .. L["Hotbar not available yet"])
            end
            
        elseif cmd == "vendordb" then
            if DreamHouse.VendorDatabase then
                DreamHouse.VendorDatabase:HandleCommand(args)
            else
                print("|cff00ccff[DreamHouse]|r " .. L["VendorDB not available"])
            end
            
        elseif cmd == "reset" then
            StaticPopup_Show("DREAMHOUSE_RESET_CONFIRM")
            
        elseif cmd == "diagnose" or cmd == "diag" then
            -- API & Frame Diagnose für Patch 12.0.0 Kompatibilität
            print("|cff00ccff[DreamHouse]|r |cffffcc00=== DIAGNOSE 12.0.0 ===|r")
            print("")
            
            -- Blizzard Frames prüfen
            print("|cff88ccff--- Blizzard Frames ---|r")
            local frames = {
                "HouseEditorFrame",
                "HousingControlsFrame", 
                "HousingStorageFrame",
                "HousingCatalogFrame",
            }
            for _, frameName in ipairs(frames) do
                local frame = _G[frameName]
                if frame then
                    print("  |cff00ff00✓|r " .. frameName .. " existiert")
                else
                    print("  |cffff4444✗|r " .. frameName .. " = nil (FEHLT!)")
                end
            end
            
            -- Blizzard Mixins prüfen
            print("")
            print("|cff88ccff--- Blizzard Mixins ---|r")
            local mixins = {
                "HouseEditorFrameMixin",
                "HouseEditorBasicDecorModeMixin",
                "HouseEditorExpertDecorModeMixin",
                "HouseEditorLayoutModeMixin",
            }
            for _, mixinName in ipairs(mixins) do
                local mixin = _G[mixinName]
                if mixin then
                    print("  |cff00ff00✓|r " .. mixinName .. " existiert")
                else
                    print("  |cffff4444✗|r " .. mixinName .. " = nil (FEHLT!)")
                end
            end
            
            -- Housing APIs prüfen
            print("")
            print("|cff88ccff--- Housing APIs ---|r")
            local apis = {
                { name = "C_Housing", check = C_Housing },
                { name = "C_HouseEditor", check = C_HouseEditor },
                { name = "C_HousingCatalog", check = C_HousingCatalog },
                { name = "C_HousingDecor", check = C_HousingDecor },
                { name = "C_HousingBasicMode", check = C_HousingBasicMode },
                { name = "Enum.HouseEditorMode", check = Enum and Enum.HouseEditorMode },
            }
            for _, api in ipairs(apis) do
                if api.check then
                    print("  |cff00ff00✓|r " .. api.name .. " verfügbar")
                else
                    print("  |cffff4444✗|r " .. api.name .. " = nil (FEHLT!)")
                end
            end
            
            -- Wichtige Funktionen prüfen
            print("")
            print("|cff88ccff--- Wichtige Funktionen ---|r")
            local funcs = {
                { name = "C_HouseEditor.IsHouseEditorActive", check = C_HouseEditor and C_HouseEditor.IsHouseEditorActive },
                { name = "C_HousingCatalog.GetCatalogEntryInfo", check = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfo },
                { name = "C_HousingBasicMode.StartPlacingNewDecor", check = C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor },
                { name = "C_Housing.IsInsideHouseOrPlot", check = C_Housing and C_Housing.IsInsideHouseOrPlot },
            }
            for _, func in ipairs(funcs) do
                if func.check then
                    print("  |cff00ff00✓|r " .. func.name)
                else
                    print("  |cffff4444✗|r " .. func.name .. " (FEHLT!)")
                end
            end
            
            print("")
            print("|cff00ccff[DreamHouse]|r Diagnose abgeschlossen. Rote Einträge = Problem!")
            
        else
            print("|cff00ccff[DreamHouse]|r " .. L["Unknown command"])
        end
    end
    
    -- Reset-Bestätigung
    StaticPopupDialogs["DREAMHOUSE_RESET_CONFIRM"] = {
        text = L["Reset all settings?"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function()
            DreamHouseDB = nil
            DreamHouse.Settings:Initialize()
            print("|cff00ccff[DreamHouse]|r " .. L["Settings reset"])
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    
    DreamHouse.Debug:Log("Core", "Slash-Commands registriert (/dh, /dreamhouse)", "DEBUG")
end

-- Event-Dispatcher
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()
    elseif event == "PLAYER_LOGOUT" then
        DreamHouse.Debug:Log("Core", "Spieler ausgeloggt", "INFO")
    else
        -- Housing-Events
        OnHousingEvent(event, ...)
    end
end)

-- Global verfügbar machen
_G.DreamHouse = DreamHouse

DreamHouse.Debug:Log("Core", "Core.lua geladen", "DEBUG")

