local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the MapHandler module
local MapHandler = Addon:NewModule("MapHandler", "AceEvent-3.0")

-- local functions
local GetCurrentMapAreaID           = _G.GetCurrentMapAreaID
local GetCurrentMapDungeonLevel     = _G.GetCurrentMapDungeonLevel
local GetMapInfo                    = _G.GetMapInfo
local GetPlayerFacing               = _G.GetPlayerFacing
local GetPlayerMapPosition          = _G.GetPlayerMapPosition 
local IsInInstance                  = _G.IsInInstance
local SetDungeonMapLevel            = _G.SetDungeonMapLevel
local SetMapByID                    = _G.SetMapByID
local SetMapToCurrentZone           = _G.SetMapToCurrentZone
local WorldMapZoomOutButton_OnClick = _G.WorldMapZoomOutButton_OnClick

local atan2 = math.atan2
local sqrt  = math.sqrt

local pairs   = pairs
local tinsert = table.insert

-- aux variables
local _

-- setup libs
local LibStub   = LibStub

-- translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- lib containing map data
local LibHBD = LibStub("HereBeDragons-1.0")
local LibTBD = LibStub("ThereBeDragons-1.0")

-- constants
local PI         = math.pi
local TWOPI      = PI * 2
local FRAD       = 180 / PI
local CRAD       = FRAD / 10

-- modules
local Options = nil

-- module data
local moduleData = {
	indoors        = false,
	dungeonLvl     = nil,
	actMap         = nil,
}

-- scaling data
local MinimapSize = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}

-- module handling
function MapHandler:OnInitialize()	
	-- set module references
	Options = Addon:GetModule("Options")

	-- create the minimap button
	self:Setup()
end

function MapHandler:OnEnable()
	self:SetupEventHandlers()

	-- update indoor state
	self:UpdateIndoors()
end

function MapHandler:OnDisable()
	self:ResetEventHandlers()
end

function MapHandler:Setup()
	-- empty
end

function MapHandler:SetupEventHandlers()
	-- register event to track zone changes
	LibHBD.RegisterCallback(MapHandler, "PlayerZoneChanged", "UpdateZone")

	-- zoning events
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateIndoors")
	self:RegisterEvent("ZONE_CHANGED",          "UpdateIndoors")
	self:RegisterEvent("ZONE_CHANGED_INDOORS",  "UpdateIndoors")
end

function MapHandler:ResetEventHandlers()
	-- unregister event to track zone changes
	LibHBD.UnregisterCallback(MapHandler, "PlayerZoneChanged")

	-- zoning events
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
end

-- event callbacks
function MapHandler:UpdateZone(event, mapId, floor, map)
    moduleData.actMap     = mapId
    moduleData.dungeonLvl = floor
end

function MapHandler:UpdateIndoors()
	local curZoom = Minimap:GetZoom()
	
	if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
		if curZoom < 2 then 
			Minimap:SetZoom(curZoom + 1)
		else 
			Minimap:SetZoom(curZoom - 1)
		end
	end
	
	if GetCVar("minimapZoom")+0 == Minimap:GetZoom() then 
		moduleData.indoors = false
    else 
		moduleData.indoors = true
	end
	
	Minimap:SetZoom(curZoom)
end

-- user functions
function MapHandler:GetIndoors()
	return moduleData.indoors
end

function MapHandler:GetUnitPosition(unit)
    local x, y, instanceID = LibHBD:GetUnitWorldPosition(unit)
	
	return instanceID, x, y
end

function MapHandler:GetPlayerZonePosition()
	local x, y, mapID, level = LibHBD:GetPlayerZonePosition()

	return mapID, level, x, y
end

function MapHandler:GetWorldCoordinatesFromZone(map, level, x, y)
	local x, y, instanceID = LibHBD:GetWorldCoordinatesFromZone(x, y, map, level)

	return instanceID, x, y
end

function MapHandler:GetMinimapSize(zoom)
	if moduleData.indoors then
		return MinimapSize["indoor"][zoom]
	else
		return MinimapSize["outdoor"][zoom]
	end
end

function MapHandler:GetDistance(srcCoords, tgtCoords, outStatus)
	local errorCode = nil

	if self:ValidCoords(srcCoords) and self:ValidCoords(tgtCoords) then
		if srcCoords.instanceID == tgtCoords.instanceID and (not srcCoords.level or LibTBD:AreCoordsOnFloor(srcCoords.instanceID, tgtCoords.x, tgtCoords.y, srcCoords.level)) then
			local distance, dX, dY = LibHBD:GetWorldDistance(instanceID, srcCoords.x, srcCoords.y, tgtCoords.x, tgtCoords.y)
			
			return distance, -dX, -dY
		else
			errorCode = Addon.NO_PATH
		end
	else
		errorCode = Addon.INVALID_COORDS
	end

	if type(outStatus) == "table" then
		outStatus.errorCode = errorCode
	end
	
	return
end

function MapHandler:GetMapDimensions(map, floor)
    return LibHBD:GetZoneSize(map, floor)
end

function MapHandler:ValidCoords(coords)
	if not coords or type(coords) ~= "table" then
		return false
	end

	return coords.instanceID and coords.x and coords.y and true or false
end

function MapHandler:AreIdenticalCoords(srcCoords, tgtCoords)
	-- coords are more likely to be different and will be checked first
	return srcCoords.instanceID == tgtCoords.instanceID and srcCoords.x == tgtCoords.x and srcCoords.y == tgtCoords.y
end

function MapHandler:MapAvailable(map, floor)
	return self:GetMapDimensions(map, floor) and true or false
end

function MapHandler:GetViewAngle(dx, dy, minimap)
	if not dx or not dy then
		return
	end

    local miniRotate = minimap and GetCVar("rotateMinimap") ~= "0"
	
	dy = minimap and dy or -dy

	local facing = miniRotate and 0 or GetPlayerFacing()
	local angle  = atan2(dx, dy)

	if angle < 0 then
		angle = angle * -1
	else
		angle = TWOPI - angle
	end

	return angle - facing 
end

function MapHandler:GetDistanceToPing()
	local dx, dy = Minimap:GetPingPosition()

	if not dx or not dy then
		return
	end
	
	local distance = sqrt(dx * dx + dy * dy) * self:GetMinimapSize(Minimap:GetZoom())
	
	return distance, dx, dy
end

function MapHandler:GetPlayerZoneCoordinatesFromWorld(x, y)
	local _, _, zone, level = LibHBD:GetPlayerZonePosition()	

    return LibHBD:GetZoneCoordinatesFromWorld(x, y, zone, level, true)
end

-- test
function MapHandler:Debug(msg)
	Addon:Debug("(MapHandler) " .. msg)
end
