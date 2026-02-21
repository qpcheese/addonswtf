local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Units module
local Units = Addon:NewModule("Units", "AceEvent-3.0")

-- internal event handling
Units.callbacks = LibStub("CallbackHandler-1.0"):New(Units)

-- local functions
local UnitClass    = _G.UnitClass
local UnitInParty  = _G.UnitInParty
local UnitInRaid   = _G.UnitInRaid
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit   = _G.UnitIsUnit
local UnitName     = _G.UnitName

local pairs   = pairs
local tinsert = table.insert

-- aux variables
local _

-- setup libs
local LibStub   = LibStub

-- translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- class color when unknown
local GRAY = {r = 0.535, g = 0.535, b = 0.535}

-- reference spell for range test
local classHealSpells = { 
	["DRUID"]   = GetSpellInfo(5185)   or "Healing Touch",
	["MONK"]    = GetSpellInfo(115175) or "Soothing Mist",
	["PRIEST"]  = GetSpellInfo(2061)   or "Flash Heal",
	["PALADIN"] = GetSpellInfo(19750)  or "Flash of Light",
	["SHAMAN"]  = GetSpellInfo(8004)   or "Lesser Healing Wave"
}

local classRezSpells = { 
	["DRUID"]   = GetSpellInfo(20484)  or "Rebirth",
	["MONK"]    = GetSpellInfo(115178) or "Resuscitate",
	["PRIEST"]  = GetSpellInfo(2006)   or "Resurrection",
	["PALADIN"] = GetSpellInfo(7328)   or "Redemption",
	["SHAMAN"]  = GetSpellInfo(2008)   or "Ancestral Spirit"
}

local basicUnitIds = {
    player = 1,
    target = 1,
    focus  = 1,
    party  = MAX_PARTY_MEMBERS,
    raid   = MAX_RAID_MEMBERS,
}

local targetLabel = "Target"

-- module data
local moduleData = {
	name2Unit   = {},
    player      = {
        name            = nil,
        class           = nil,
        isHealer        = false,
        healSpellName   = nil,
        rezSpellName    = nil,
    },
    classCache  = {},
}

-- local functions
function FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

do --Do-end block for iterators
	local emptyTbl = {}
	local tablestack = setmetatable({}, {__mode = 'k'})

	local function EnumerateIter(t, prestate)
		if not t then 
			return nil 
		end

		if prestate < t.count then
			local index = prestate + 1

			return index, string.format("%s%d", t.prefix, index)
		end
		
		tablestack[t] = true
		return nil, nil		
	end

	function Units:IterateGroupUnits()
		local tbl = next(tablestack) or {}		
		tablestack[tbl] = nil
		
		if IsInRaid() then
			tbl.count = 40
			tbl.prefix = "raid"			
		elseif IsInGroup() then
			tbl.count = 4
			tbl.prefix = "party"
		else
			tbl.count = 0
		end
		
		return EnumerateIter, tbl, 0
	end
end

-- module handling
function Units:OnInitialize()	
end

function Units:OnEnable()
	self:SetupEventHandlers()

    self:SetupPlayer()
	self:UpdateRaidUnits()
end

function Units:OnDisable()
	self:ResetEventHandlers()
end

function Units:SetupPlayer()
	local _, class = UnitClass("player")
    moduleData.player.class = class
	moduleData.player.name  = UnitName("player")
	
	moduleData.classCache[moduleData.player.name] = class
	
	if class == "DRUID" or 
	   class == "MONK" or
	   class == "PRIEST" or
	   class == "PALADIN" or 
	   class == "SHAMAN" then 
		moduleData.player.isHealer = true
		moduleData.player.healSpellName = classHealSpells[class]
		moduleData.player.rezSpellName  = classRezSpells[class]
	end
end

function Units:SetupEventHandlers()
	-- raid/party events
	self:RegisterEvent("PARTY_CONVERTED_TO_RAID", "UpdateRaidUnits")
	self:RegisterEvent("GROUP_ROSTER_UPDATE",     "UpdateRaidUnits")	
end

function Units:ResetEventHandlers()
	-- raid/party events
	self:UnregisterEvent("PARTY_CONVERTED_TO_RAID")
	self:UnregisterEvent("PARTY_MEMBERS_CHANGED")	
end

function Units:UpdateRaidUnits()
	NS:ClearTable(moduleData.name2Unit)

	for _, unit in self:IterateGroupUnits() do
		local name = UnitName(unit)

		if name then
			moduleData.name2Unit[name] = unit
			
			self:GetClass(name)
		end				
	end

	moduleData.name2Unit[moduleData.player.name] = "player"
	
	-- fire event when raid units changed
	self.callbacks:Fire(ADDON .. "_RAIDUNITS_CHANGED")
end

function Units:UnitIsValid(unit)
    return unit and (UnitInRaid(unit) or UnitInParty(unit) or UnitIsUnit(unit, "player"))
end

function Units:GetRaidUnitByName(name)
	return moduleData.name2Unit[name]
end

function Units:GetClass(name)
	local class = moduleData.classCache[name]
	
	if not class then
		local unit = self:GetRaidUnitByName(name)
		if unit and UnitIsPlayer(unit) or UnitIsFriend("player", unit) then
			_, class = UnitClass(unit)
			
			moduleData.classCache[name] = class
		end
	end

	return class
end

function Units:ColorizeChar(name)
	local unit = self:GetRaidUnitByName(name)
	
	if unit then
		local class = self:GetClass(name)
		
		local colortable = _G["CUSTOM_CLASS_COLORS"] or _G["RAID_CLASS_COLORS"]
		local color = colortable[class] or GRAY
		return "|cff" .. string.format("%02x%02x%02x", color.r*255, color.g*255, color.b*255) .. name .. "|r"
	end
	
	return NS:Colorize("Red", name)
end

function Units:GetPlayerInfo()
    local player = moduleData.player
    
    return player.name, player.class, player.isHealer, player.healSpellName, player.rezSpellName
end

-- unit id utilities
function Units:GetUnitIdStructure(unitId)
    if type(unitId) ~= "string" then
        return nil, 0
    end

    -- match all "target" occurences at the end
    local count = 0
    
    count, unitId = self:GetUnitIdTargetIndirections(unitId)
    
    -- if unit id consists only of "target" sequence
    if unitId:len() == 0 then
        return nil, count
    end
        
    -- check prefix
    if not self:CheckBasicUnitId(unitId) then
        return nil, 0
    end
    
    return unitId, count
end

function Units:GetUnitIdTargetIndirections(unitId)
    if type(unitId) ~= "string" then
        return 0, unitId
    end

    -- match all "target" occurences at the end
    local count = 0
    local matches = 0
    
    repeat
        unitId, matches = unitId:gsub("(target)$", "")
        
        if matches > 0 then
            count = count + 1
        end
    until (matches == 0)
    
    return count, unitId
end

function Units:CheckBasicUnitId(unitId)
    if type(unitId) ~= "string" then
        return false
    end

    local posStart, posEnd, number = unitId:find("(%d+)$")    
    
    if number then
        -- check group unit id has proper index
        local index = tonumber(number)
        local groupId = unitId:sub(1, posStart - 1)
                
        if not basicUnitIds[groupId] or basicUnitIds[groupId] == 1 or index < 1 or index > basicUnitIds[groupId] then
            return false
        end
    else
        -- check is single unit id
        if not basicUnitIds[unitId] or basicUnitIds[unitId] ~= 1 then
            return false
        end
    end
    
    return true
end

function Units:IsValidUnitId(unitId)
    local prefix, targetCount = self:GetUnitIdStructure(unitId)

    return prefix and true or targetCount > 0
end

function Units:GetUnitIdLabel(unitId)
    local prefix, targetCount = self:GetUnitIdStructure(unitId)

    if not prefix and targetCount <= 0 then
        return
    end
    
    return (prefix and FirstToUpper(prefix) or "") .. targetLabel:rep(targetCount)
end

-- test
function Units:Debug(msg)
	Addon:Debug("(Units) " .. msg)
end
