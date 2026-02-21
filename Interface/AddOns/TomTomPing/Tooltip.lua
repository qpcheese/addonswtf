local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Tooltip module
local Tooltip = Addon:NewModule("Tooltip")

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- tooltip library
local QT = LibStub:GetLibrary("LibQTip-1.0")

-- local functions
local pairs             = pairs
local next              = next
local floor             = floor

-- modules
local MapHandler    = nil
local Options       = nil
local RaidTargets   = nil
local Units         = nil

-- local variables
local _

local tooltip = nil

-- icons
local ICON_PLUS	 = [[|TInterface\BUTTONS\UI-PlusButton-Up:16:16|t]]
local ICON_MINUS = [[|TInterface\BUTTONS\UI-MinusButton-Up:16:16|t]]

-- callbacks
local function HandleToggleFoldClicked(cell, target, button)
	Tooltip:ToggleUnfold(target)
	Tooltip:Refresh()
end

local function HandleDestinationTypeClicked(cell, destination, button)
    Options:SetSetting("Destination", destination)
    
    Tooltip:Refresh()
end

local function HandleRaidTargetClicked(cell, raidTarget, button)
    Options:SetSetting("RaidTarget", raidTarget)
    
    Tooltip:Refresh()
end

local function HandleTargetUnitClicked(cell, unitId, button)
    Options:SetSetting("TargetUnit", unitId)
    
    Tooltip:Refresh()
end

local function HandleCheckInstanceFloorClicked(cell, button)
    Options:ToggleSetting("CheckInstanceFloor")
    
    Tooltip:Refresh()
end

-- module handling
function Tooltip:OnInitialize()
	-- set module references
	MapHandler    = Addon:GetModule("MapHandler")
	Options       = Addon:GetModule("Options")
	RaidTargets   = Addon:GetModule("RaidTargets")
	Units         = Addon:GetModule("Units")

	self.unfolded = {}
end

function Tooltip:OnEnable()
	-- empty
end

function Tooltip:OnDisable()
	self:Remove()
end

function Tooltip:Create(obj, autoHideDelay)
	if not self:IsEnabled() then
		return
	end

	autoHideDelay = autoHideDelay and autoHideDelay or 0.1

	tooltip = QT:Acquire(ADDON.."TT", 3)
	
	tooltip:Hide()
	tooltip:Clear()
	tooltip:SetScale(1)
		
	self:Draw()

	tooltip:SetAutoHideDelay(autoHideDelay, obj)
	tooltip:EnableMouse()
	tooltip:SmartAnchorTo(obj)
	tooltip:Show()
end

function Tooltip:Remove()
	if tooltip then
		tooltip:Hide()
		QT:Release(tooltip)
		tooltip = nil
	end
end

function Tooltip:Refresh()
	if not self:IsEnabled() then
		self:Remove()
		return
	end
	
	self:Draw()
	
	tooltip:Show()
end

function Tooltip:Draw()
	if not tooltip then
		return
	end

	tooltip:Hide()
	tooltip:Clear()

	local colcount = tooltip:GetColumnCount()	

	-- module header
	local lineNum = tooltip:AddHeader(" ")
	tooltip:SetCell(lineNum, 1, NS:Colorize("White", Addon.FULLNAME), "CENTER", tooltip:GetColumnCount())
	tooltip:AddLine(" ")
	
	local typeSetting = Options:GetSetting("Destination")
	
	local destination = nil
	local distance    = "--"
	local target      = L[typeSetting]
	local ping        = "--"
	
	if Addon:GetSticky() then
		destination = Addon:ColorizeChar(Addon.destinationName)
		target = L["Sticky"] .. " (" .. target .. ")"
	elseif typeSetting == "waypoint" then
		if Addon:ValidCoords(Addon.waypoint) then
			local x, y = MapHandler:GetPlayerZoneCoordinatesFromWorld(Addon.waypoint.x, Addon.waypoint.y)
			
			if x and y then
				destination = NS:PrecisionTxt(x, 2) .. ", " .. NS:PrecisionTxt(y, 2)
			else
				destination = L["no path"]
			end
		end
	else -- if self.db.profile.Destination ~= "none" then
		if Addon.destinationName then
			destination = Units:ColorizeChar(Addon.destinationName)
		end
	end
	
	if destination then
		local dist = Addon:GetDistanceToDestination()

		if dist then
			distance = NS:PrecisionTxt(dist, 2) .. " " .. L["yards"]
		end
	else	
		destination = "none"
	end
	
	if Addon.pingerName then
		ping = Units:ColorizeChar(Addon.pingerName)
	end

	lineNum = tooltip:AddLine(" ")
	tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Destination"] .. ":"), "LEFT" )
	tooltip:SetCell(lineNum, 2, destination,  "LEFT" )

	lineNum = tooltip:AddLine(" ")
	tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Distance"] .. ":"), "LEFT")
	tooltip:SetCell(lineNum, 2, distance, "LEFT")
	
	tooltip:AddLine(" ")
	
	lineNum = tooltip:AddLine(" ")
	tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Type"] .. ":"), "LEFT")
	
	-- toggle type setting +/-
    tooltip:SetCell(lineNum, 3, self:GetUnfold("Destination") and ICON_MINUS or ICON_PLUS, "RIGHT")
    tooltip:SetCellScript(lineNum, 3, "OnMouseDown", HandleToggleFoldClicked, "Destination")
	
	if self:GetUnfold("Destination") then
		for _, destinationType in Options:IterateDestinations() do
			if destinationType == typeSetting then
				tooltip:SetCell(lineNum, 2, L[destinationType],  "LEFT")
			else
				tooltip:SetCell(lineNum, 2, NS:Colorize("GrayOut", L[destinationType]),  "LEFT")
			end
			
			tooltip:SetCellScript(lineNum, 2, "OnMouseDown", HandleDestinationTypeClicked, destinationType)
			lineNum = tooltip:AddLine(" ")
		end
	else
		tooltip:SetCell(lineNum, 2, target,  "LEFT")
		lineNum = tooltip:AddLine(" ")
	end

	if typeSetting == "raidtarget" then
		tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Raid Target"] .. ":"), "LEFT")
		
		-- toggle raid target setting +/-
        tooltip:SetCell(lineNum, 3, self:GetUnfold("DestinationSubSelection") and ICON_MINUS or ICON_PLUS, "RIGHT")
        tooltip:SetCellScript(lineNum, 3, "OnMouseDown", HandleToggleFoldClicked, "DestinationSubSelection")
		
		local raidTarget = Options:GetSetting("RaidTarget")
		
		if self:GetUnfold("DestinationSubSelection") then
			for rt = 1, RaidTargets.RAID_TARGET_COUNT do
				if rt == raidTarget then
					tooltip:SetCell(lineNum, 2, RaidTargets:GetRaidTargetTextIcon(rt, 12) .. " " .. L[RaidTargets:GetRaidTargetName(rt)],  "LEFT")
				else
					tooltip:SetCell(lineNum, 2, RaidTargets:GetRaidTargetTextIcon(rt, 12) .. " " .. NS:Colorize("GrayOut", L[RaidTargets:GetRaidTargetName(rt)]),  "LEFT")
				end
				
				tooltip:SetCellScript(lineNum, 2, "OnMouseDown", HandleRaidTargetClicked, rt)
				lineNum = tooltip:AddLine(" ")
			end
		else
			tooltip:SetCell(lineNum, 2, RaidTargets:GetRaidTargetTextIcon(raidTarget, 12) .. " " .. L[RaidTargets:GetRaidTargetName(raidTarget)],  "LEFT")
			lineNum = tooltip:AddLine(" ")
		end		
	elseif typeSetting == "unit" then
		tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Target Unit"] .. ":"), "LEFT")
		
		-- toggle raid target setting +/-
        tooltip:SetCell(lineNum, 3, self:GetUnfold("DestinationSubSelection") and ICON_MINUS or ICON_PLUS, "RIGHT")
        tooltip:SetCellScript(lineNum, 3, "OnMouseDown", HandleToggleFoldClicked, "DestinationSubSelection")
		
		local targetUnit = Options:GetSetting("TargetUnit")
		
		if self:GetUnfold("DestinationSubSelection") then
            for _, unitId in Options:IterateTargetUnits() do
                if unitId == targetUnit then
                    tooltip:SetCell(lineNum, 2, Units:GetUnitIdLabel(unitId),  "LEFT")
                else
                    tooltip:SetCell(lineNum, 2, NS:Colorize("GrayOut", Units:GetUnitIdLabel(unitId)),  "LEFT")
                end
                
                tooltip:SetCellScript(lineNum, 2, "OnMouseDown", HandleTargetUnitClicked, unitId)
                lineNum = tooltip:AddLine(" ")
            end
		else
			tooltip:SetCell(lineNum, 2, Units:GetUnitIdLabel(targetUnit),  "LEFT")
			lineNum = tooltip:AddLine(" ")
		end		
	end
	
    tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Check Instance Floor"] .. ":"), "LEFT" )
    tooltip:SetCell(lineNum, 2, Options:GetSetting("CheckInstanceFloor") and L["enabled"] or L["disabled"],  "LEFT" )
    tooltip:SetCellScript(lineNum, 2, "OnMouseDown", HandleCheckInstanceFloorClicked)
    lineNum = tooltip:AddLine(" ")
    	
	lineNum = tooltip:AddLine(" ")
	tooltip:SetCell(lineNum, 1, NS:Colorize("LightBlue", L["Last Ping"] .. ":"), "LEFT")
	tooltip:SetCell(lineNum, 2, ping,  "LEFT")

	-- And a hint to show options
	if not Options:GetSetting("HideHint") then
		tooltip:AddLine(" ")

		lineNum = tooltip:AddLine(" ")		
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Left-Click"] .. ": "),        nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Set target as destination"]), nil, "LEFT")

		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Right-Click"] .. ": "), nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Open options menu"]),   nil, "LEFT")
 
		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Ctrl-Left-Click"] .. ": "),   nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Stick/unstick destination"]), nil, "LEFT")

		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Ctrl-Right-Click"] .. ": "), nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Release arrow"]),            nil, "LEFT")

		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Shift-Left-Click"] .. ": "), nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Ping your position"]), nil, "LEFT")

		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Alt-Left-Click"] .. ": "),           nil, "LEFT")
		tooltip:SetCell(lineNum, 2, NS:Colorize("Yellow",   L["Set waypoint at target location"]), nil, "LEFT")
	end
end

-- folding
function Tooltip:GetUnfold(target)
	return target and self.unfolded[target] and true or false
end

function Tooltip:SetUnfold(target, unfold)
	if not target then
		return
	end
	
	self.unfolded[target] = unfold and true
end

function Tooltip:ToggleUnfold(target)
	self:SetUnfold(target, not self:GetUnfold(target))
end

-- test
function Tooltip:Debug(msg)
	Addon:Debug("(Tooltip) " .. msg)
end
