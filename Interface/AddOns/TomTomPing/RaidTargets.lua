local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the RaidTargets module
local RaidTargets = Addon:NewModule("RaidTargets", "AceEvent-3.0")

-- internal event handling
RaidTargets.callbacks = LibStub("CallbackHandler-1.0"):New(RaidTargets)

-- local functions
local GetRaidTargetIndex    = _G.GetRaidTargetIndex

local pairs   = pairs
local tinsert = table.insert

-- aux variables
local _

-- setup libs
local LibStub   = LibStub

-- translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- modules
local Units = nil

-- constants
RaidTargets.RAID_TARGET_COUNT = 8

-- local variables
local raidTargets = {
	idents = {
		[1] = "star",
		[2] = "circle",
		[3] = "diamond",
		[4] = "triangle",
		[5] = "moon",
		[6] = "square",
		[7] = "cross",
		[8] = "skull",
	},
	reverseIdents = {
		star     = 1,
		circle   = 2,
		diamond  = 3,
		triangle = 4,
		moon     = 5,
		square   = 6,
		cross    = 7,
		skull    = 8,
	},
	reverseShortIdents = {
		rt1 = 1,
		rt2 = 2,
		rt3 = 3,
		rt4 = 4,
		rt5 = 5,
		rt6 = 6,
		rt7 = 7,
		rt8 = 8,
	},
}

local rtChatIdTemplate = "{rt%s}"

local raidTargetIconBase = [[Interface\TargetingFrame\UI-RaidTargetingIcon_]]

-- module data
local moduleData = {
	units   = {},
}

-- module handling
function RaidTargets:OnInitialize()	
	-- set module references
	Units = Addon:GetModule("Units")
end

function RaidTargets:OnEnable()
	self:SetupEventHandlers()

	self:UpdateRaidTargets()
end

function RaidTargets:OnDisable()
	self:ResetEventHandlers()
end

function RaidTargets:SetupEventHandlers()
	-- raid/party events
	self:RegisterEvent("RAID_TARGET_UPDATE", "UpdateRaidTargets")	
end

function RaidTargets:ResetEventHandlers()
	-- raid/party events
	self:UnregisterEvent("RAID_TARGET_UPDATE")	
end

function RaidTargets:UpdateRaidTargets()
	NS:ClearTable(moduleData.units)

	for _, unit in Units:IterateGroupUnits() do
		local rt = GetRaidTargetIndex(unit)

		if rt then
			moduleData.units[rt] = UnitName(unit)
		end				
	end
	
	if IsInGroup() and not IsInRaid() then
		local rt = GetRaidTargetIndex("player")

		if rt then
			moduleData.units[rt] = UnitName("player")
		end				
	end
	
	-- fire event when raid units changed
	self.callbacks:Fire(ADDON .. "_RAIDTARGETS_CHANGED")
end

function RaidTargets:GetUnit(raidTarget)
	return raidTarget and moduleData.units[raidTarget] or nil
end

function RaidTargets:GetRaidTargetChatIdent(raidTarget)
	return string.format(rtChatIdTemplate, tostring(raidTarget))
end

function RaidTargets:GetRaidTargetIcon(raidTarget)
	return raidTargetIconBase .. tostring(raidTarget)
end

function RaidTargets:GetRaidTargetTextIcon(raidTarget, size)
	local icon = self:GetRaidTargetIcon(raidTarget)
	
	if type(size) == "number" then
		icon = string.format("%s:%d:%d", icon, size, size)
	end
	
	return string.format("|T%s|t", icon)
end

function RaidTargets:GetRaidTargetId(raidTargetName)
	if type(raidTargetName) ~= "string" then
		return
	end

	local rt = raidTargets.reverseIdents[raidTargetName]
	
	if rt then
		return rt
	end
	
	return raidTargets.reverseShortIdents[raidTargetName]
end

function RaidTargets:GetRaidTargetName(raidTarget)
	return raidTarget and raidTargets.idents[raidTarget]
end

function RaidTargets:GetRaidTargetShort(raidTarget)
	return type(raidTarget) == "number" and rt > 0 and rt <= self.RAID_TARGET_COUNT and "rt" .. raidTarget or nil
end

-- test
function RaidTargets:Debug(msg)
	Addon:Debug("(RaidTargets) " .. msg)
end
