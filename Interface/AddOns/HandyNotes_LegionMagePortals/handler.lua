local myname, ns = ...

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")
local HL = LibStub("AceAddon-3.0"):NewAddon(myname, "AceEvent-3.0")
-- local L = LibStub("AceLocale-3.0"):GetLocale(myname, true)
ns.HL = HL

local next = next
local GameTooltip = GameTooltip
local HandyNotes = HandyNotes

-- Debug function
local function debug_print(msg)
    if ns.db and ns.db.debug then
        print("[LegionMagePortals] " .. tostring(msg))
    end
end

-- Updated texture function with fallbacks and debugging
local function work_out_texture(atlas)
    debug_print("Attempting to load atlas: " .. tostring(atlas))
    
    -- Try the new API first
    local atlasInfo = C_Texture.GetAtlasInfo(atlas)
    if atlasInfo then
        debug_print("Successfully loaded atlas: " .. atlas)
        return {
            icon = atlasInfo.file or atlasInfo.filename,
            tCoordLeft = atlasInfo.leftTexCoord or 0,
            tCoordRight = atlasInfo.rightTexCoord or 1,
            tCoordTop = atlasInfo.topTexCoord or 0,
            tCoordBottom = atlasInfo.bottomTexCoord or 1,
        }
    else
        debug_print("Failed to load atlas: " .. atlas .. ", using fallback")
        -- Fallback to a simple icon
        return {
            icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran",
            tCoordLeft = 0,
            tCoordRight = 1,
            tCoordTop = 0,
            tCoordBottom = 1,
        }
    end
end

-- Try multiple atlas names for portals
local function get_portal_texture(enabled)
    local atlas_attempts = {
        enabled and "MagePortalAlliance" or "MagePortalHorde",
        enabled and "ui-hud-minimap-raid-heroic" or "ui-hud-minimap-raid-normal",
        "Garr_Building_MageTower_1_Map",
        "Garr_Building_MageTower_2_Map",
        "Garr_Building_MageTower_3_Map"
    }
    
    for _, atlas in ipairs(atlas_attempts) do
        local atlasInfo = C_Texture.GetAtlasInfo(atlas)
        if atlasInfo then
            debug_print("Using atlas: " .. atlas .. " for " .. (enabled and "enabled" or "disabled"))
            return work_out_texture(atlas)
        end
    end
    
    debug_print("All atlas attempts failed, using fallback icon")
    local texture = {
        icon = "Interface\\Icons\\Spell_Arcane_PortalDalaran",
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
    }
    
    if enabled then
        texture.r = 0
        texture.g = 1
        texture.b = 0
    else
        texture.r = 1
        texture.g = 0
        texture.b = 0
    end
    
    return texture
end

local enabled_texture = get_portal_texture(true)
local disabled_texture = get_portal_texture(false)

-- Simplified entrance textures
local enabled_entrance_texture = {
    icon = "Interface\\Icons\\Spell_Arcane_TeleportDalaran",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    r = 0,
    g = 0,
    b = 1
}

local disabled_entrance_texture = {
    icon = "Interface\\Icons\\Spell_Arcane_TeleportDalaran",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    r = 1,
    g = 0,
    b = 0
}

local get_point_info = function(point)
    if point then
        debug_print("Checking point: " .. tostring(point.label) .. ", quest: " .. tostring(point.quest))
        
        local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(point.quest)
        debug_print("Quest " .. tostring(point.quest) .. " completed: " .. tostring(questCompleted))
        
        local texture
        if questCompleted then
            texture = point.entrance and enabled_entrance_texture or enabled_texture
            debug_print("Using enabled texture")
        else
            texture = point.entrance and disabled_entrance_texture or disabled_texture
            debug_print("Using disabled texture")
        end
        return point.label, texture
    else
        debug_print("No point data found")
    end
end

local get_point_info_by_coord = function(mapFile, coord)
    debug_print("Looking for point at coord " .. tostring(coord) .. " in map " .. tostring(mapFile))
    
    -- Remove terrain suffix
    local cleanMapFile = string.gsub(mapFile, "_terrain%d+$", "")
    debug_print("Clean map file: " .. tostring(cleanMapFile))
    
    if ns.points[cleanMapFile] then
        debug_print("Found map data for " .. cleanMapFile)
        if ns.points[cleanMapFile][coord] then
            debug_print("Found point data at coordinate")
            return get_point_info(ns.points[cleanMapFile][coord])
        else
            debug_print("No point data at coordinate " .. tostring(coord))
        end
    else
        debug_print("No map data found for " .. tostring(cleanMapFile))
        debug_print("Available maps: " .. table.concat(tInvert(ns.points) and {} or {"none"}, ", "))
    end
end

local function handle_tooltip(tooltip, point)
    if point then
        tooltip:AddLine(point.label)
        local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(point.quest)
        if questCompleted then
            tooltip:AddLine("Active", 0, 1, 0) -- Green text
        else
            tooltip:AddLine("Inactive", 1, 0, 0) -- Red text
        end
        tooltip:AddLine("Quest ID: " .. tostring(point.quest), 0.5, 0.5, 0.5) -- Debug info
    else
        tooltip:SetText("Unknown Location")
    end
    tooltip:Show()
end

local handle_tooltip_by_coord = function(tooltip, mapFile, coord)
    local cleanMapFile = string.gsub(mapFile, "_terrain%d+$", "")
    return handle_tooltip(tooltip, ns.points[cleanMapFile] and ns.points[cleanMapFile][coord])
end

---------------------------------------------------------
-- Plugin Handlers to HandyNotes
local HLHandler = {}
local info = {}

function HLHandler:OnEnter(mapFile, coord)
    debug_print("OnEnter called for " .. tostring(mapFile) .. " at " .. tostring(coord))
    
    -- Updated tooltip handling for current WoW
    local tooltip = GameTooltip
    if WorldMapFrame and WorldMapFrame:IsShown() then
        tooltip = WorldMapTooltip or GameTooltip
    end
    
    if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
        tooltip:SetOwner(self, "ANCHOR_LEFT")
    else
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
    end
    handle_tooltip_by_coord(tooltip, mapFile, coord)
end

local function createWaypoint(button, mapFile, coord)
    if TomTom then
        local mapId = HandyNotes:GetMapFiletoMapID(mapFile)
        local x, y = HandyNotes:getXY(coord)
        TomTom:AddMFWaypoint(mapId, nil, x, y, {
            title = get_point_info_by_coord(mapFile, coord),
            persistent = nil,
            minimap = true,
            world = true
        })
    end
end

local function hideNode(button, mapFile, coord)
    ns.hidden[mapFile][coord] = true
    HL:Refresh()
end

local function closeAllDropdowns()
    CloseDropDownMenus(1)
end

do
    local currentZone, currentCoord
    local function generateMenu(button, level)
        if (not level) then return end
        wipe(info)
        if (level == 1) then
            -- Create the title of the menu
            info.isTitle      = 1
            info.text         = "HandyNotes - " .. myname:gsub("HandyNotes_", "")
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)

            if TomTom then
                -- Waypoint menu item
                info.text = "Create waypoint"
                info.notCheckable = 1
                info.func = createWaypoint
                info.arg1 = currentZone
                info.arg2 = currentCoord
                UIDropDownMenu_AddButton(info, level)
                wipe(info)
            end

            -- Close menu item
            info.text         = "Close"
            info.func         = closeAllDropdowns
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
            wipe(info)
        end
    end
    local HL_Dropdown = CreateFrame("Frame", myname.."DropdownMenu")
    HL_Dropdown.displayMode = "MENU"
    HL_Dropdown.initialize = generateMenu

    function HLHandler:OnClick(button, down, mapFile, coord)
        if button == "RightButton" and not down then
            currentZone = string.gsub(mapFile, "_terrain%d+$", "")
            currentCoord = coord
            ToggleDropDownMenu(1, nil, HL_Dropdown, self, 0, 0)
        end
    end
end

function HLHandler:OnLeave(mapFile, coord)
    debug_print("OnLeave called")
    -- Updated for current WoW
    if WorldMapTooltip then
        WorldMapTooltip:Hide()
    end
    GameTooltip:Hide()
end

do
    -- This is a custom iterator we use to iterate over every node in a given zone
    local currentLevel, currentZone
    local function iter(t, prestate)
        if not t then 
            debug_print("No table data for iteration")
            return nil 
        end
        
        local state, value = next(t, prestate)
        while state do -- Have we reached the end of this zone?
            debug_print("Iterating: state=" .. tostring(state) .. ", entrance=" .. tostring(value and value.entrance))
            
            if value and (ns.db.entrances or not value.entrance) then
                local label, icon = get_point_info(value)
                debug_print("Returning node: " .. tostring(label))
                return state, nil, icon, ns.db.icon_scale, ns.db.icon_alpha
            end
            state, value = next(t, state) -- Get next data
        end
        debug_print("End of iteration")
        return nil, nil, nil, nil
    end
    
    function HLHandler:GetNodes(mapFile, minimap, level)
        debug_print("GetNodes called for " .. tostring(mapFile) .. ", minimap=" .. tostring(minimap) .. ", level=" .. tostring(level))
        
        currentLevel = level
        local cleanMapFile = string.gsub(mapFile, "_terrain%d+$", "")
        currentZone = cleanMapFile
        
        debug_print("Clean map file: " .. cleanMapFile)
        
        -- Debug: show all available map keys
        debug_print("Available maps in ns.points:")
        for mapName, _ in pairs(ns.points) do
            debug_print("  - " .. tostring(mapName))
        end
        
        -- Try exact match first
        if ns.points[cleanMapFile] then
            local count = 0
            for _ in pairs(ns.points[cleanMapFile]) do count = count + 1 end
            debug_print("Found " .. count .. " points for " .. cleanMapFile)
            return iter, ns.points[cleanMapFile], nil
        else
            -- Try case-insensitive match
            local lowerMapFile = string.lower(cleanMapFile)
            for mapName, mapData in pairs(ns.points) do
                if string.lower(mapName) == lowerMapFile then
                    local count = 0
                    for _ in pairs(mapData) do count = count + 1 end
                    debug_print("Found case-insensitive match: " .. mapName .. " (" .. count .. " points)")
                    return iter, mapData, nil
                end
            end
            
            debug_print("No points found for " .. cleanMapFile .. " (tried case-insensitive too)")
            return iter, nil, nil
        end
    end
end

---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HL:OnInitialize()
    debug_print("Addon initializing...")
    
    -- Set up our database
    self.db = LibStub("AceDB-3.0"):New(myname.."DB", ns.defaults)
    ns.db = self.db.profile
    ns.hidden = self.db.char.hidden or {}
    
    debug_print("Database initialized, debug mode: " .. tostring(ns.db.debug))
    
    -- Initialize our database with HandyNotes
    HandyNotes:RegisterPluginDB(myname:gsub("HandyNotes_", ""), HLHandler, ns.options)
    debug_print("Plugin registered with HandyNotes")

    -- watch for LOOT_CLOSED
    self:RegisterEvent("LOOT_CLOSED")
    debug_print("Events registered")
end

function HL:Refresh()
    debug_print("Refreshing addon")
    self:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
end

function HL:LOOT_CLOSED()
    debug_print("LOOT_CLOSED event fired")
    self:Refresh()
end
