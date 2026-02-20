local Addon, T = ...
local EV = T.Evie
local KR = OPie.ActionBook:compatible("Kindred", 1, 0)

-- setup `[map]` condition
-- parameters: <mapName>
do
	local function GetState()
		local cz
		local map = C_Map.GetBestMapForUnit("player")
		while map and map ~= 0 do
			local mapInfo = C_Map.GetMapInfo(map)
			if mapInfo then
				cz = (cz and (cz .. "/") or "") .. mapInfo.name:gsub("%s*[,/%[%]][[,/%[%]]%s]*", " ")
				map = mapInfo.parentMapID
			end
		end
		return cz or false
	end

	local function Update()
		KR:SetStateConditionalValue("map", GetState())
	end

	Update()
	EV.ZONE_CHANGED = Update
	EV.ZONE_CHANGED_INDOORS = Update
	EV.ZONE_CHANGED_NEW_AREA = Update
	EV.PLAYER_ENTERING_WORLD = Update
end

-- setup `[riding]` condition
-- parameters: <rank>
-- - `rank` can be:
--   - `apprentice`/`journeyman`/`expert`/`artisan`/`master`
--   - `60`/`100`/`150`/`280`/`310` - only those exact values, matching above ranks
--   - `flying` - same as `expert`
do
	local spells = {
		{
			SpellID = 33388,
			Values = {"apprentice", "60"}
		},
		{
			SpellID = 33391,
			Values = {"journeyman", "100"}
		},
		{
			SpellID = 34090,
			Values = {"expert", "150", "flying"}
		},
		{
			SpellID = 34091,
			Values = {"artisan", "280"}
		},
		{
			SpellID = 90265,
			Values = {"master", "310"}
		}
	}

	local function GetState()
		local cz
		local someRankKnown = false
		for i = 1, #spells do
			local spellData = spells[#spells + 1 - i]
			if (not someRankKnown) and IsSpellKnown(spellData.SpellID) then
				someRankKnown = true
			end
			if someRankKnown then
				for _, rankName in pairs(spellData.Values) do
					cz = (cz and (cz .. "/") or "") .. rankName:gsub("%s*[,/%[%]][[,/%[%]]%s]*", " ")
				end
			end
		end
		return cz or false
	end

	local function Update()
		KR:SetStateConditionalValue("riding", GetState())
	end

	Update()
	EV.SPELLS_CHANGED = Update
	EV.PLAYER_ENTERING_WORLD = Update
end

-- setup `[dragonridable]` condition
-- no parameters
do
	local function GetState()
		local instanceID = select(8, GetInstanceInfo())
		local isDragonIslesInstance = instanceID == 2444
		local isZaralekCavernsInstance = instanceID == 2454
		if (not isDragonIslesInstance) and (not isZaralekCavernsInstance) then
			local foundUsable = false
			local mountIds = C_MountJournal.GetCollectedDragonridingMounts()
			if mountIds then
				for _, id in pairs(mountIds) do
					local _, spellId, _, _, isUsableMount = C_MountJournal.GetMountInfoByID(id)
					if isUsableMount and IsUsableSpell(spellId) then
						foundUsable = true
						break
					end
				end
			end
			if not foundUsable then
				return false
			end
		end

		local mapId = C_Map.GetBestMapForUnit("player")
		while mapId and mapId ~= 0 do
			if mapId == 1978 then -- Dragon Isles
				return true
			end
			local mapInfo = C_Map.GetMapInfo(mapId)
			if mapInfo then
				mapId = mapInfo.parentMapID
			end
		end

		return false
	end

	local function Update()
		KR:SetStateConditionalValue("dragonridable", GetState())
	end

	Update()
	EV.ZONE_CHANGED = Update
	EV.ZONE_CHANGED_INDOORS = Update
	EV.ZONE_CHANGED_NEW_AREA = Update
	EV.PLAYER_ENTERING_WORLD = Update
end