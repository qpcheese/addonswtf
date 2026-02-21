-- ThereBeDragons is an extension for HereBeDragons providing functionalita to get the postion of units in party or raid

local MAJOR, MINOR = "ThereBeDragons-1.0", 2
assert(LibStub, MAJOR .. " requires LibStub")

local ThereBeDragons, oldversion = LibStub:NewLibrary(MAJOR, MINOR)
if not ThereBeDragons then return end

local CBH = LibStub("CallbackHandler-1.0")

ThereBeDragons.eventFrame       = ThereBeDragons.eventFrame or CreateFrame("Frame")

ThereBeDragons.mapData          = ThereBeDragons.mapData or {}
ThereBeDragons.continentZoneMap = ThereBeDragons.continentZoneMap or { [-1] = { [0] = WORLDMAP_COSMIC_ID }, [0] = { [0] = WORLDMAP_AZEROTH_ID }}
ThereBeDragons.mapToID          = ThereBeDragons.mapToID or { Cosmic = WORLDMAP_COSMIC_ID, World = WORLDMAP_AZEROTH_ID }
ThereBeDragons.microDungeons    = ThereBeDragons.microDungeons or {}
ThereBeDragons.transforms       = ThereBeDragons.transforms or {}

ThereBeDragons.callbacks        = CBH:New(ThereBeDragons, nil, nil, false)

local IsLegion = select(4, GetBuildInfo()) >= 70000

-- constants
local TERRAIN_MATCH = "_terrain%d+$"

-- Lua upvalues
local PI2 = math.pi * 2
local atan2 = math.atan2
local pairs, ipairs = pairs, ipairs
local type = type

-- WoW API upvalues
local UnitPosition = UnitPosition

-- data table upvalues
local mapData          = ThereBeDragons.mapData -- table { width, height, left, top }
local continentZoneMap = ThereBeDragons.continentZoneMap
local mapToID          = ThereBeDragons.mapToID
local microDungeons    = ThereBeDragons.microDungeons
local transforms       = ThereBeDragons.transforms

local currentPlayerZoneMapID, currentPlayerLevel, currentMapFile, currentMapIsMicroDungeon

-- Override instance ids for phased content
local instanceIDOverrides = {
    -- Draenor
    [1152] = 1116, -- Horde Garrison 1
    [1330] = 1116, -- Horde Garrison 2
    [1153] = 1116, -- Horde Garrison 3
    [1154] = 1116, -- Horde Garrison 4 (unused)
    [1158] = 1116, -- Alliance Garrison 1
    [1331] = 1116, -- Alliance Garrison 2
    [1159] = 1116, -- Alliance Garrison 3
    [1160] = 1116, -- Alliance Garrison 4 (unused)
    [1191] = 1116, -- Ashran PvP Zone
    [1203] = 1116, -- Frostfire Finale Scenario
    [1207] = 1116, -- Talador Finale Scenario
    [1277] = 1116, -- Defense of Karabor Scenario (SMV)
    [1402] = 1116, -- Gorgrond Finale Scenario
    [1464] = 1116, -- Tanaan
    [1465] = 1116, -- Tanaan
    -- Legion
    [1478] = 1220, -- Temple of Elune Scenario (Val'Sharah)
    [1502] = 1220, -- Dalaran Underbelly
    [1533] = 0,    -- Karazhan Artifact Scenario
    [1612] = 1220, -- Feral Druid Artifact Scenario (Suramar)
}

-- unregister and store all WORLD_MAP_UPDATE registrants, to avoid excess processing when
-- retrieving info from stateful map APIs
local wmuRegistry
local function UnregisterWMU()
    wmuRegistry = {GetFramesRegisteredForEvent("WORLD_MAP_UPDATE")}
    for _, frame in ipairs(wmuRegistry) do
        frame:UnregisterEvent("WORLD_MAP_UPDATE")
    end
end

-- restore WORLD_MAP_UPDATE to all frames in the registry
local function RestoreWMU()
    assert(wmuRegistry)
    for _, frame in ipairs(wmuRegistry) do
        frame:RegisterEvent("WORLD_MAP_UPDATE")
    end
    wmuRegistry = nil
end

-- gather map info, but only if this isn't an upgrade (or the upgrade version forces a re-map)
if not oldversion or oldversion < 2 then
    -- wipe old data, if required, otherwise the upgrade path isn't triggered
    if oldversion then
        wipe(mapData)
        wipe(microDungeons)
    end

    local MAPS_TO_REMAP = {
         -- alliance garrison
        [973] = 971,
        [974] = 971,
        [975] = 971,
        [991] = 971,
        -- horde garrison
        [980] = 976,
        [981] = 976,
        [982] = 976,
        [990] = 976,
    }

    -- some zones will remap initially, but have a fixup later
    local REMAP_FIXUP_EXEMPT = {
        -- main draenor garrison maps
        [971] = true,
        [976] = true,
    }

    local function processTransforms()
        wipe(transforms)
        for _, tID in ipairs(GetWorldMapTransforms()) do
            local terrainMapID, newTerrainMapID, _, _, transformMinY, transformMaxY, transformMinX, transformMaxX, offsetY, offsetX = GetWorldMapTransformInfo(tID)
            if offsetY ~= 0 or offsetX ~= 0 then
                local transform = {
                    instanceID = terrainMapID,
                    newInstanceID = newTerrainMapID,
                    minY = transformMinY,
                    maxY = transformMaxY,
                    minX = transformMinX,
                    maxX = transformMaxX,
                    offsetY = offsetY,
                    offsetX = offsetX
                }
                table.insert(transforms, transform)
            end
        end
    end

    local function applyMapTransforms(instanceID, left, right, top, bottom)
        for _, transformData in ipairs(transforms) do
            if transformData.instanceID == instanceID then
                if left < transformData.maxX and right > transformData.minX and top < transformData.maxY and bottom > transformData.minY then
                    instanceID = transformData.newInstanceID
                    left   = left   + transformData.offsetX
                    right  = right  + transformData.offsetX
                    top    = top    + transformData.offsetY
                    bottom = bottom + transformData.offsetY
                    break
                end
            end
        end
        return instanceID, left, right, top, bottom
    end

    -- gather the data of one zone (by mapID)
    local function processZone(id)
        if not id or mapData[id] then return end

        -- set the map and verify it could be set
        local success = SetMapByID(id)
        if not success then
            return
        elseif id ~= GetCurrentMapAreaID() and not REMAP_FIXUP_EXEMPT[id] then
            -- this is an alias zone (phasing terrain changes), just skip it and remap it later
            if not MAPS_TO_REMAP[id] then
                MAPS_TO_REMAP[id] = GetCurrentMapAreaID()
            end
            return
        end

        -- dimensions of the map
        local originalInstanceID, _, _, left, right, top, bottom = GetAreaMapInfo(id)
        local instanceID = originalInstanceID
        if (left and top and right and bottom and (left ~= 0 or top ~= 0 or right ~= 0 or bottom ~= 0)) then
            instanceID, left, right, top, bottom = applyMapTransforms(originalInstanceID, left, right, top, bottom)
            mapData[id] = { left - right, top - bottom, left, top }
        else
            mapData[id] = { 0, 0, 0, 0 }
        end

        mapData[id].instance = instanceID
        mapData[id].name = GetMapNameByID(id)

        -- store the original instance id (ie. not remapped for map transforms) for micro dungeons
        mapData[id].originalInstance = originalInstanceID

        local mapFile = GetMapInfo()
        if mapFile then
            -- remove phased terrain from the map names
            mapFile = mapFile:gsub(TERRAIN_MATCH, "")

            if not mapToID[mapFile] then mapToID[mapFile] = id end
            mapData[id].mapFile = mapFile
        end

        local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()
        mapData[id].C = C or -100
        mapData[id].Z = Z or -100

        if mapData[id].C > 0 and mapData[id].Z >= 0 then
            -- store C/Z lookup table
            if not continentZoneMap[C] then
                continentZoneMap[C] = {}
            end
            if not continentZoneMap[C][Z] then
                continentZoneMap[C][Z] = id
            end
        end

        local floors
        if IsLegion then
            floors = { GetNumDungeonMapLevels() }

            -- offset floors for terrain map
            if DungeonUsesTerrainMap() then
                for i = 1, #floors do
                    floors[i] = floors[i] + 1
                end
            end
        else
            floors = {}
            for f = 1, GetNumDungeonMapLevels() do
                floors[f] = f
            end
        end
        if #floors == 0 and GetCurrentMapDungeonLevel() > 0 then
            floors[1] = GetCurrentMapDungeonLevel()
            mapData[id].fakefloor = GetCurrentMapDungeonLevel()
        end

        mapData[id].floors = {}
        mapData[id].numFloors = #floors
        for i = 1, mapData[id].numFloors do
            local f = floors[i]
            SetDungeonMapLevel(f)
            local _, right, bottom, left, top = GetCurrentMapDungeonLevel()
            if left and top and right and bottom then
                instanceID, left, right, top, bottom = applyMapTransforms(originalInstanceID, left, right, top, bottom)
                mapData[id].floors[f] = { left - right, top - bottom, left, top }
                mapData[id].floors[f].instance = mapData[id].instance
            elseif f == 1 and DungeonUsesTerrainMap() then
                mapData[id].floors[f] = { mapData[id][1], mapData[id][2], mapData[id][3], mapData[id][4] }
                mapData[id].floors[f].instance = mapData[id].instance
            end
        end

        -- setup microdungeon storage if the its a zone map or has no floors of its own
        if (mapData[id].C > 0 and mapData[id].Z > 0) or mapData[id].numFloors == 0 then
            if not microDungeons[originalInstanceID] then
                microDungeons[originalInstanceID] = {}
            end
        end
    end

    local function processMicroDungeons()
        for _, dID in ipairs(GetDungeonMaps()) do
            local floorIndex, minX, maxX, minY, maxY, terrainMapID, parentWorldMapID, flags = GetDungeonMapInfo(dID)

            -- apply transform
            local originalTerrainMapID = terrainMapID
            terrainMapID, maxX, minX, maxY, minY = applyMapTransforms(terrainMapID, maxX, minX, maxY, minY)

            -- check if this zone can have microdungeons
            if microDungeons[originalTerrainMapID] then
                microDungeons[originalTerrainMapID][floorIndex] = { maxX - minX, maxY - minY, maxX, maxY }
                microDungeons[originalTerrainMapID][floorIndex].instance = terrainMapID
            end
        end
    end

    local function fixupZones()
        -- fake cosmic map
        mapData[WORLDMAP_COSMIC_ID] = {0, 0, 0, 0}
        mapData[WORLDMAP_COSMIC_ID].instance = -1
        mapData[WORLDMAP_COSMIC_ID].mapFile = "Cosmic"
        mapData[WORLDMAP_COSMIC_ID].floors = {}
        mapData[WORLDMAP_COSMIC_ID].C = -1
        mapData[WORLDMAP_COSMIC_ID].Z = 0
        mapData[WORLDMAP_COSMIC_ID].name = WORLD_MAP

        -- fake azeroth world map
        -- the world map has one "floor" per continent it contains, which allows
        -- using these floors to translate coordinates from and to the world map.
        -- note: due to artistic differences in the drawn azeroth maps, the values
        -- used for the continents are estimates and not perfectly accurate
        mapData[WORLDMAP_AZEROTH_ID] = { 63570, 42382, 53730, 19600 } -- Eastern Kingdoms, or floor 0
        mapData[WORLDMAP_AZEROTH_ID].floors = {
            -- Kalimdor
            [1] =    { 65700, 43795, 11900, 23760, instance = 1    },
            -- Northrend
            [571] =  { 65700, 43795, 33440, 11960, instance = 571  },
            -- Pandaria
            [870] =  { 58520, 39015, 29070, 34410, instance = 870  },
            -- Broken Isles
            [1220] = { 96710, 64476, 63100, 29960, instance = 1220 },
        }
        mapData[WORLDMAP_AZEROTH_ID].instance = 0
        mapData[WORLDMAP_AZEROTH_ID].mapFile = "World"
        mapData[WORLDMAP_AZEROTH_ID].C = 0
        mapData[WORLDMAP_AZEROTH_ID].Z = 0
        mapData[WORLDMAP_AZEROTH_ID].name = WORLD_MAP

        -- we only have data for legion clients, zeroing the coordinates
        -- and niling out the floors temporarily disables the logic on live
        if not IsLegion then
            mapData[WORLDMAP_AZEROTH_ID][1] = 0
            mapData[WORLDMAP_AZEROTH_ID][2] = 0
            mapData[WORLDMAP_AZEROTH_ID][3] = 0
            mapData[WORLDMAP_AZEROTH_ID][4] = 0
            mapData[WORLDMAP_AZEROTH_ID].floors = {}
        end

        -- alliance draenor garrison
        if mapData[971] then
            mapData[971].Z = 5

            mapToID["garrisonsmvalliance_tier1"] = 971
            mapToID["garrisonsmvalliance_tier2"] = 971
            mapToID["garrisonsmvalliance_tier3"] = 971
        end

        -- horde draenor garrison
        if mapData[976] then
            mapData[976].Z = 3

            mapToID["garrisonffhorde_tier1"] = 976
            mapToID["garrisonffhorde_tier2"] = 976
            mapToID["garrisonffhorde_tier3"] = 976
        end

        -- remap zones with alias IDs
        for remapID, validMapID in pairs(MAPS_TO_REMAP) do
            if mapData[validMapID] then
                mapData[remapID] = mapData[validMapID]
            end
        end
    end

    local function gatherMapData()
        -- unregister WMU to reduce the processing burden
        UnregisterWMU()

        -- load transforms
        processTransforms()

        -- load the main zones
        -- these should be processed first so they take precedence in the mapFile lookup table
        local continents = {GetMapContinents()}
        for i = 1, #continents, 2 do
            processZone(continents[i])
            local zones = {GetMapZones((i + 1) / 2)}
            for z = 1, #zones, 2 do
                processZone(zones[z])
            end
        end

        -- process all other zones, this includes dungeons and more
        local areas = GetAreaMaps()
        for idx, zoneID in pairs(areas) do
            processZone(zoneID)
        end

        -- fix a few zones with data lookup problems
        fixupZones()

        -- and finally, the microdungeons
        processMicroDungeons()

        -- restore WMU
        RestoreWMU()
    end

    gatherMapData()
end

-- Transform a set of coordinates based on the defined map transformations
local function applyCoordinateTransforms(x, y, instanceID)
    for _, transformData in ipairs(transforms) do
        if transformData.instanceID == instanceID then
            if transformData.minX <= x and transformData.maxX >= x and transformData.minY <= y and transformData.maxY >= y then
                instanceID = transformData.newInstanceID
                x = x + transformData.offsetX
                y = y + transformData.offsetY
                break
            end
        end
    end
    if instanceIDOverrides[instanceID] then
        instanceID = instanceIDOverrides[instanceID]
    end
    return x, y, instanceID
end

-- get mapID by instanceID provided by UnitPosition(unit)
local function getMapIdByInstanceId(instanceID)
	if not instanceID then
		return nil
	end

	for mapID, mapData in pairs(mapData) do
		if mapData.instance == instanceID then
			return mapID
		end
	end

	return nil
end

-- get level by instanceID and coords provided by UnitPosition(unit)
local function checkIsOnFloor(instanceID, x, y, level)
	if not instanceID or not x or not y then
		return false
	end

    local mapID = getMapIdByInstanceId(instanceID)
    
    if not mapID then 
		return false 
	end
	
    local data = mapData[mapID]
	
    if not data then 
		return false 
	end
	
    if level and level > 0 then
        data = data.floors[level]
    end
	
	return data and data[1] > x and data[1] - data[3] < x and data[2] > y and data[2] - data[4] < y
end

--- Get the current world position of the player
-- The position is transformed to the current continent, if applicable
-- @return x, y, instanceID
function ThereBeDragons:GetUnitWorldPosition(unit)
    -- get the current position
    local y, x, z, instanceID = UnitPosition(unit)
	
    -- return transformed coordinates
    return applyCoordinateTransforms(x, y, instanceID)
end

--- Get the current position of the player on a zone level
-- The returned values are local point coordinates, 0-1. The mapFile can represent a micro dungeon.
-- @return x, y, mapID, level, mapFile, isMicroDungeon
function ThereBeDragons:IsUnitOnFloor(unit, level)
    local x, y, instanceID = self:GetUnitWorldPosition(unit)
    
    return self:AreCoordsOnFloor(instanceID, x, y, level)
end

--- Get the current position of the player on a zone level
-- The returned values are local point coordinates, 0-1. The mapFile can represent a micro dungeon.
-- @return x, y, mapID, level, mapFile, isMicroDungeon
function ThereBeDragons:AreCoordsOnFloor(instanceID, x, y, level)
    return checkIsOnFloor(instanceID, x, y, level)
end
