local _G = _G

-- addon name and namespace
local ADDON, NS = ...

-- setup libs
local LibStub   = LibStub

-- get translations
local L         = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- local functions
local GetCVar                      = _G.GetCVar
local GetMouseFocus                = _G.GetMouseFocus
local GetPlayerFacing              = _G.GetPlayerFacing
local GetUnitSpeed                 = _G.GetUnitSpeed
local IsAltKeyDown                 = _G.IsAltKeyDown
local InCombatLockdown             = _G.InCombatLockdown
local IsControlKeyDown             = _G.IsControlKeyDown
local IsInGroup                    = _G.IsInGroup
local IsInInstance                 = _G.IsInInstance
local IsInRaid                     = _G.IsInRaid
local IsMouseButtonDown            = _G.IsMouseButtonDown
local IsShiftKeyDown               = _G.IsShiftKeyDown
local IsSpellInRange               = _G.IsSpellInRange
local SecureButton_GetModifiedUnit = _G.SecureButton_GetModifiedUnit
local UnitIsDead                   = _G.UnitIsDead
local UnitIsUnit                   = _G.UnitIsUnit
local UnitName                     = _G.UnitName
local UnitClass                    = _G.UnitClass
local UnitIsFriend                 = _G.UnitIsFriend
local UnitIsPlayer                 = _G.UnitIsPlayer

local sqrt, abs, floor = math.sqrt, math.abs, math.floor
local gsub, strsub = gsub, string.sub
local cos     = math.cos
local sin     = math.sin

local _

-- constants

-- direction calculation
local PI    = math.pi
local FRAD  = 180 / PI
local CRAD  = FRAD / 10

-- binding descriptions
BINDING_HEADER_TOM_TOM_PING            = ADDON
BINDING_NAME_TOMTOMPING_TARGET         = L["Track character of current target"]
BINDING_NAME_TOMTOMPING_STICK          = L["(Un)Stick current destination"]
BINDING_NAME_TOMTOMPING_PING           = L["Ping your position"]
BINDING_NAME_TOMTOMPING_CLEAR          = L["Release CrazyArrow"]
BINDING_NAME_TOMTOMPING_WAYPOINT       = L["Set waypoint at target location"]
BINDING_NAME_TOMTOMPING_CUSTOM_ONE     = string.format(L["Executes custom command %d"], 1)
BINDING_NAME_TOMTOMPING_CUSTOM_TWO     = string.format(L["Executes custom command %d"], 2)

-- addon and locals
local Addon = LibStub:GetLibrary("AceAddon-3.0"):NewAddon(ADDON, "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

TomTomPing = Addon

-- addon constants
Addon.MODNAME   = "TomTomPing"
Addon.FULLNAME  = "TomTomPing"
Addon.SHORTNAME = "TTP"

-- modules
local CrazyArrow    = nil
local DataBroker    = nil
local MapHandler    = nil
local Options       = nil
local MinimapButton = nil
local RaidTargets   = nil
local Tooltip       = nil
local Units         = nil

-- constants
local ICON_DEFAULT = "Interface\\Addons\\"..ADDON.."\\icon.tga"
local ICON_COMPASS = "Interface\\Addons\\"..ADDON.."\\compass.tga"
local ICON_ARROW   = "Interface\\Addons\\"..ADDON.."\\arrow.tga"

-- error codes related to distance calculation
Addon.NO_PATH        = 1
Addon.MISSING_DATA   = 2
Addon.INVALID_COORDS = 3

-- local variables
local targetCoords = {}
local playerCoords = {}

local aliases = {
	lookup = {
		destination = {"dest"},
		raidtarget = {"rt"},
		waypoint = {"way", "wp"},
	},
	reverse = {},
}

-- reverse lookup for aliases
do
	for cmd, aliasList in pairs(aliases.lookup) do
		for _, alias in ipairs(aliasList) do
			aliases.reverse[alias] = cmd
		end
	end
end

-- invisible dummy frame for OnUpdate (only used when target tracking is "mouseover*")
do
	local onUpdateFrame = CreateFrame("Frame", ADDON .. "_Dummy", UIParent)
	onUpdateFrame:SetHeight(1)
	onUpdateFrame:SetWidth(1)
	onUpdateFrame:SetFrameStrata("BACKGROUND")
	onUpdateFrame:SetPoint("TOPLEFT", 0, 0)
	onUpdateFrame:Show()

    local isActive = false
    
	function Addon:ActivateOnUpdate(activate)
        if isActive == activate and true or false then
            return
        end
    
		if activate then
			onUpdateFrame:SetScript("OnUpdate", function() TomTomPing:UpdateDestination() end)
            isActive = true
		else
			onUpdateFrame:SetScript("OnUpdate", nil)
            isActive = false
		end
	end
end

-- label data
local compass = "NW---N---NE---E---SE---S---SW---W---NW---N---NE---E---"

-- yellow North
local NORTH = NS:Colorize("Yellow", "N")

-- modificator key check
local function ValidModificatorKeys(alt, ctrl, shift, modificators)
	if modificators == "never" then
		return false
	elseif modificators == "always" then
		return true
	elseif modificators == "alt" then
		return alt and true
	elseif modificators == "ctrl" then
		return ctrl and true
	elseif modificators == "shift" then
		return shift and true
	elseif modificators == "ctrl-alt" or modificators == "alt-ctrl" then
		return ctrl and alt
	elseif modificators == "ctrl-shift" or modificators == "shift-ctrl" then
		return ctrl and shift
	elseif modificators == "alt-shift" or modificators == "shift-alt" then
		return alt and shift
	elseif modificators == "ctrl-alt-shift" or modificators == "ctrl-alt-shift" or modificators == "alt-ctrl-shift" or modificators == "alt-shift-ctrl" or modificators == "shift-ctrl-alt" or modificators == "shift-alt-ctrl" then
		return ctrl and alt and shift
	end
	
	return false
end

-- infrastructure functions
function Addon:OnInitialize()
	-- set module references
	CrazyArrow    = self:GetModule("CrazyArrow")
	DataBroker    = self:GetModule("DataBroker")
	MapHandler    = self:GetModule("MapHandler")
	MinimapButton = self:GetModule("MinimapButton")
	Options       = self:GetModule("Options")
	RaidTargets   = self:GetModule("RaidTargets")
	Tooltip       = self:GetModule("Tooltip")
	Units         = self:GetModule("Units")

	self:SetupVariables()

	self:RegisterChatCommand("tomtomping", "ChatCommand")
    self:RegisterChatCommand("ttp",        "ChatCommand")
end

function Addon:OnEnable()
	self:SetupEventHandlers()
	self:SetupPingEventHandler(Options:GetSetting("Ping"))
	self:SetupDestinationEventHandler(Options:GetSetting("Destination"))
	
	self:UpdateIcon()

	MinimapButton:SetShow(Options:GetSetting("Minimap"))
	
	-- set initial combat state
	self:UpdateCombatState()
		
	self:ScheduleRepeatingTimer("UpdateDirection", 0.1)
end

function Addon:OnDisable()
	self:ResetEventHandlers()
	self:SetupPingEventHandler(false)
	self:SetupDestinationEventHandler("none")

	MinimapButton:SetShow(false)	

	self:CancelAllTimers()
end

function Addon:OnOptionsReloaded()
	MinimapButton:SetShow(Options:GetSetting("Minimap"))

	self:SetupPingEventHandler(Options:GetSetting("Ping"))

	-- setup new destination event
	self:SetupDestinationEventHandler(Options:GetSetting("Destination"))
	
	self:UpdateDestination()
	
	self:Refresh()
end

function Addon:ChatCommand(input)
    if input then  
		args = NS:GetArgs(input)
		
		self:TriggerAction(unpack(args))
        
        NS:ReleaseTable(args)
	else
		self:TriggerAction("help")
	end
	
end

function Addon:OnClick(button)
    if button == "RightButton" then 
		if IsShiftKeyDown() then
			-- unused
		elseif IsControlKeyDown() then
			-- release arrow
			self:TriggerAction("clear")
		elseif IsAltKeyDown() then
			-- unused
		else
			-- open options menu
			self:TriggerAction("menu")
		end
	elseif button == "LeftButton" then 
		if IsShiftKeyDown() then
			-- ping at self
			self:TriggerAction("ping")
		elseif IsControlKeyDown() then
			-- (un)stick destination
			self:TriggerAction("sticky")
		elseif IsAltKeyDown() then
			-- set waypoint at target
			local name = UnitName("target")
			TomTomPing:TriggerAction("destination", "waypoint", name)
		else
			-- target as destination
			self:TriggerAction("destination", "name", UnitName("target"))
		end
	end
end

function Addon:TriggerAction(action, ...)
    local args = NS:NewTable(...)

	action = self:LookupAlias(action)
	
	if action == "destination" then
		local destination = self:LookupAlias(args[1]) or ""
		
		if not Options:IsValidDestination(destination) then
			return
		end
		
		Options:SetSetting("Destination", destination)
		
		if #args > 1 or destination == "name" or destination == "waypoint" then
			if destination == "name" or destination == "raidtarget" or destination == "unit" or destination == "waypoint" then
				self:TriggerAction(destination, args[2], args[3])
			end
		end
	elseif action == "name" then
		local name = args[1] or ""
		
        Options:SetSetting("TargetName", name)
	elseif action == "unit" then
		local unitId = args[1] or ""
		
		if Units:IsValidUnitId(unitId) then
			Options:SetSetting("TargetUnit", unitId)
			
			Options:RefreshTargetUnits()
		end		
	elseif action == "raidtarget" then
		local raidTarget = args[1] or ""
		
		local rt = RaidTargets:GetRaidTargetId(raidTarget) or tonumber(raidTarget)
		
		if rt and rt > 0 and rt <= RaidTargets.RAID_TARGET_COUNT then
			Options:SetSetting("RaidTarget", rt)
		end		
	elseif action == "sticky" then
		if #args == 0 then
			-- (un)stick destination
			self:ToggleSticky()
		else
			-- stick to destination
			local destination = self:LookupAlias(args[1]) or ""
			
			if not Options:IsValidDestination(destination) then
				return
			end
			
			self:SetStickyDestination(destination, args[2])
		end
	elseif action == "clear" then
		-- release arrow
		self:TriggerAction("destination", "none")
	elseif action == "ping" then
		-- ping at self
		self:Ping()
	elseif action == "waypoint" then
		if #args == 2 then
			-- waypoint on position
			local map, level = MapHandler:GetPlayerZonePosition()
			
			local x = tonumber(args[1])
			local y = tonumber(args[2])
	
			if x and y then	
				if x > 1 or x < -1 or y > 1 or y < -1 then
					x = x / 100
					y = y / 100
				end
				
				self:SetWaypoint(MapHandler:GetWorldCoordinatesFromZone(map, level, x, y))
			end
		else
			-- set waypoint on unit
			self:SetWaypointOnUnit(args[1])
		end
	elseif action == "custom" then
		local customCmd = NS:LeftTrim(Options:GetSetting(args[1]))
		
		if customCmd and customCmd:sub(1, 6) ~= "custom" then
			self:ChatCommand(customCmd)
		end	
	elseif action == "menu" then
		-- open options menu
		InterfaceOptionsFrame_OpenToCategory(self.FULLNAME)
		-- call twice because otherwise first time options are opened it will not switch to the addon
		InterfaceOptionsFrame_OpenToCategory(self.FULLNAME)
	elseif action == "version" then
		-- print version information
		self:PrintVersionInfo()
	elseif action == "mouse" then
		self:Output("Mouse over: " .. tostring(self:GetMouseOverUnit()))
	elseif action == "debug" then
		if args[1] == "on" then
			self:Output("debug mode turned on")
			self.debug = true
		end
		if args[1] == "off" then
			self:Output("debug mode turned off")
			self.debug = false
		end
	elseif action == "alias" then
		-- display aliases
		self:PrintAliases()
	elseif action == "help" then
		-- display help
        self:Help(args[1])
	else
		self:Output(L["Unknown command."])
        self:Help()
	end
    
    NS:ReleaseTable(args)
end

function Addon:CreateTooltip(obj, autoHideDelay)
	Tooltip:Create(obj, autoHideDelay)
end

function Addon:RemoveTooltip()
	Tooltip:Remove()
end

-- setup functions
function Addon:SetupVariables()
	-- destination data
	self.destinationUnit = nil
	self.destinationName = nil
	self.sticky = false

	-- ping data
	self.pingerName = nil

	-- waypoints
	self.waypoint = {}

	-- track combat 
	self.inCombat = false
	
	-- debugging
	self.debug = false
	
	-- class cache
	self.classCache = {}

	-- direction
	self.facing = 0
	self.directionLabelIndex = nil
end

function Addon:SetupEventHandlers()
	Options.RegisterCallback(self, ADDON .. "_SETTING_CHANGED", "UpdateSetting")	
	Units.RegisterCallback(self, ADDON .. "_RAIDUNITS_CHANGED", "UpdateDestination")	
	RaidTargets.RegisterCallback(self, ADDON .. "_RAIDTARGETS_CHANGED", "UpdateDestination")	

	-- register events to track combat
	self:RegisterEvent("PLAYER_REGEN_ENABLED",  "UpdateCombatState", false)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombatState", true)
end

function Addon:ResetEventHandlers()
	Options.UnregisterCallback(self, ADDON .. "_SETTING_CHANGED")	
	Units.UnregisterCallback(self, ADDON .. "_RAIDUNITS_CHANGED")	
	RaidTargets.UnregisterCallback(self, ADDON .. "_RAIDTARGETS_CHANGED")	
	
	-- unregister events to track combat
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function Addon:SetupPingEventHandler(activate)
	if activate then
		self:RegisterEvent("MINIMAP_PING", "OnEventPing")
	else
		self:UnregisterEvent("MINIMAP_PING")
	end
end

function Addon:SetupDestinationEventHandler(destination)
    local activate = destination == "unit" or destination == "name" or destination == "mouseover" or destination == "mouseoverclick"

    self:ActivateOnUpdate(activate)
end

-- update functions
function Addon:Refresh()
	CrazyArrow:Point()
end

function Addon:UpdateDirection()
	local facing = GetPlayerFacing()
	
	if facing == self.facing then
		return
	end
	
	self.facing = facing
	
	local i = floor(facing * CRAD)	
	
	if i ~= self.directionLabelIndex then
		self.directionLabelIndex = i
		
		self:UpdateLabel()
	end
	
	if Options:GetSetting("Compass") then
		local xUL, yUL, xLL, yLL, xUR, yUR, xLR, yLR
		
		local cosDir = cos(facing)
		local sinDir = sin(facing)
		
		local gX = (sinDir + cosDir) * 0.5
		local gY = (sinDir - cosDir) * 0.5
		
		xUL = 0.5 - gX
		yUL = 0.5 + gY
		xLL = 0.5 + gY
		yLL = 0.5 + gX
		xUR = 0.5 - gY
		yUR = 0.5 - gX
		xLR = 0.5 + gX
		yLR = 0.5 - gY
		
		DataBroker:SetIconTexCoord(xUL, yUL, xLL, yLL, xUR, yUR, xLR, yLR)
		MinimapButton:SetIconTexCoord(xUL, yUL, xLL, yLL, xUR, yUR, xLR, yLR)		
	end
end

function Addon:UpdateLabel()
	local i = self.directionLabelIndex	
	local label = compass:sub((36-i)+1, (36-i)+11)
	
	if i == 5 then
		label = label:gsub("NW[-][-][-]N", "NW---" .. NORTH, 1)
	else
		label = label:gsub("N[-]", NORTH .. "-", 1)
	end

	DataBroker:SetText(NS:Colorize("White", label))	
end

function Addon:UpdateIcon()
	local icon = self:GetIcon()
	
	DataBroker:SetIcon(icon)
	MinimapButton:SetIcon(icon)
	
	if not Options:GetSetting("Compass") then
		DataBroker:SetIconTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
		MinimapButton:SetIconTexCoord(0, 0, 0, 1, 1, 0, 1, 1)			
	end
end

function Addon:GetIcon()
	local icon = ICON_DEFAULT
	
	if Options:GetSetting("Compass") then
		local selected = Options:GetSetting("Icon")
		
		if selected == "arrow" then
			icon = ICON_ARROW
		elseif selected == "compass" then
			icon = ICON_COMPASS
		end
	end
	
	return icon
end

-- settings
function Addon:UpdateSetting(event, setting, value, old)
	if setting == "MonitoringActive" then
		self:UpdateMonitoring()
		self:UpdateIcon()
		self:Update()	
	elseif setting == "TimePrecision" then
		self:Refresh()
	elseif setting == "RangePrecision" then
		self:Refresh()
	elseif setting == "Release" then
		self:Refresh()
	elseif setting == "Duration" then
		self:Refresh()
	elseif setting == "ArrivalRange" then
		self:Refresh()
	elseif setting == "RangeCheck" then
		self:Refresh()
	elseif setting == "ShowNoDest" then
		self:Refresh()
	elseif setting == "Destination" then
		self:SetupDestinationEventHandler(value)
		
		self:UpdateDestination()
	elseif setting == "RaidTarget" then
        if Options:GetSetting("Destination") == "raidtarget" then
            self:UpdateDestination()
        end
	elseif setting == "TargetName" then
        if Options:GetSetting("Destination") == "name" then
            self:UpdateDestination()
        end
	elseif setting == "TargetUnit" then
        if Options:GetSetting("Destination") == "unit" then
            self:UpdateDestination()
        end
	elseif setting == "Compass" then
		self:UpdateIcon()		
	elseif setting == "Icon" then
		self:UpdateIcon()
	elseif setting == "Ping" then
		self:SetupPingEventHandler(Options:GetSetting("Ping"))
		self:Refresh() 
	elseif setting == "Minimap" then
		MinimapButton:SetShow(Options:GetSetting("Minimap"))
	end
end

function Addon:GetSetting(setting)
	return Options:GetSetting(setting)
end

function Addon:SetSetting(setting, value)
	return Options:SetSetting(setting, value)
end

-- event callbacks
function Addon:OnEventPing(event, unit) 
    self.pingerName = UnitName(unit)
	
    if not self.pingerName then 
		return
	end
	
	CrazyArrow:Ping()
end 

function Addon:UpdateDestination()
	if self.sticky then
		return
	end
	
	local unit = nil
	local click = nil
	
	local destination = Options:GetSetting("Destination")
	
	if destination == "unit" then
		unit = Options:GetSetting("TargetUnit")
	elseif destination == "name" then
		unit = Units:GetRaidUnitByName(Options:GetSetting("TargetName"))
	elseif destination == "mouseover" or destination == "mouseoverclick" then
        click = IsMouseButtonDown(Options:GetSetting("MouseButton"))
		if destination == "mouseover" or click then
			unit = self:GetMouseOverUnit()			
		end
	elseif destination == "raidtarget" then
		unit = RaidTargets:GetUnit(Options:GetSetting("RaidTarget"))
	end

	-- map unit to raid unit if possible
	if Units:UnitIsValid(unit) then
		-- make sure the modificator keys are valid for mouse-over destination
		if destination == "mouseover" or destination == "mouseoverclick" then
			if not self:ValidMouseOverUnit(unit) then
				unit = nil
			end
		end
	else
		unit = nil
	end
		
	-- mouseover* refreshes OnUpdate, make sure we keep the work low
	if destination ~= "mouseoverclick" or click then
		local same = false
		if unit and self.destinationUnit then
			same = UnitIsUnit(unit, self.destinationUnit)
		else
			same = unit == self.destinationUnit
		end
		
		if not same then
			self:SetDestination(unit)
		end
	end
end

-- user functions
function Addon:GetValidUnit(identifier)
	local unit

    if Units:UnitIsValid(identifier) then
		unit = identifier
	else
        -- try to get unit by name
        local unitByName = Units:GetRaidUnitByName(identifier)

        if unitByName then
			unit = unitByName
		else
			local rt = RaidTargets:GetRaidTargetId(identifier)
						
            unit = Units:GetRaidUnitByName(RaidTargets:GetUnit(rt))
        end
    end
    
    return unit
end

function Addon:SetStickyDestination(destination, target)
	local unit = nil

	if destination == "name" then
		unit = Units:GetRaidUnitByName(target)
	elseif destination == "raidtarget" then
		local rt = RaidTargets:GetRaidTargetId(target) or tonumber(target)
		
		unit = RaidTargets:GetUnit(rt)
	elseif destination == "unit" then
		unit = self:GetValidUnit(target)
	end

	if not unit then
		return
	end
	
    self:SetDestination(unit, true)
end

function Addon:SetDestination(unit, sticky)
	local name = unit and UnitName(unit) or nil

	unit = Units:GetRaidUnitByName(name)

	if unit then
		self.destinationName = name
		self.destinationUnit = unit

		if sticky == nil then
			self:Refresh()
		else
			self:SetSticky(sticky)
		end
	else
		self:Release()
	end
end

function Addon:GetSticky()
	return self.sticky
end

function Addon:SetSticky(sticky)
	-- if there is no destination we don't make it sticky
	sticky = sticky and self.destinationUnit
	
	if sticky == self.sticky then
		return
	end
	
	self.sticky = sticky
	
	if not sticky then
		self:UpdateDestination()
	end
	
	self:Refresh()	
end

function Addon:ToggleSticky()
	self:SetSticky(not self:GetSticky())
end

function Addon:Release()
	self.destinationName = nil
	self.destinationUnit = nil
	self:SetSticky(false)

	CrazyArrow:Release()
end

function Addon:Ping()
    Minimap:PingLocation(0, 0)
end

function Addon:SetWaypointOnUnit(unit)
	if not unit then
		unit = "player"
    else
        unit = self:GetValidUnit(unit)
	end
	
	if not unit then
		return
	end
	
    local instanceID, x, y = MapHandler:GetUnitPosition(unit)
	
	self:SetWaypoint(instanceID, x, y)
end

function Addon:SetWaypoint(instanceID, x, y)
    self.waypoint["instanceID"] = instanceID
	self.waypoint["x"]          = x
	self.waypoint["y"]          = y
		
	if MapHandler:ValidCoords(self.waypoint) then
		self:Refresh()
	else
		self:ClearWaypoint()
	end
end

function Addon:ClearWaypoint()
	NS:ClearTable(self.waypoint)

	self:Refresh()
end

function Addon:PrintVersionInfo()
    self:Output(L["Version"] .. " " .. NS:Colorize("White", GetAddOnMetadata(ADDON, "Version")))
end

-- auxillary functions	
function Addon:GetMouseOverUnit()
	local frame = GetMouseFocus()

	if frame then
		local unit = SecureButton_GetModifiedUnit(frame)
		
		if unit and Units:UnitIsValid(unit) then
			return unit
		end
	end
	
	return nil
end

function Addon:UpdateCombatState(inCombat)
	if inCombat == nil then
		self.inCombat = InCombatLockdown()
	else
		self.inCombat = inCombat and true
	end
end

function Addon:InCombat()
	return self.inCombat
end

function Addon:ValidMouseOverUnit(unit)
	if not unit then
		return false
	end

	local alt   = IsAltKeyDown()
	local ctrl  = IsControlKeyDown()
	local shift = IsShiftKeyDown()

	-- check combat
	if self:InCombat() then
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("InCombat")) then
			return false
		end
	else
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("OutOfCombat")) then
			return false
		end
	end
	
	-- check alive
	if UnitIsDead(unit) then
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("WhenTargetDead")) then
			return false
		end
	else
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("WhenTargetAlive")) then
			return false
		end
	end
	
	-- check range
	if self:InHealRange(unit) then
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("InRange")) then
			return false
		end
	else
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("OutOfRange")) then
			return false
		end
	end
	
	-- check player
	if UnitIsUnit(unit, "player") then
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("UnitIsPlayer")) then
			return false
		end
	-- check pet
	elseif not UnitIsPlayer(unit) then
		if not ValidModificatorKeys(alt, ctrl, shift, Options:GetSetting("UnitIsPet")) then
			return false
		end
	end
	
	return true
end

-- distance related functions
function Addon:ValidCoords(coords)
	return MapHandler:ValidCoords(coords)
end

function Addon:GetDistanceToDestination(outStatus)
	NS:ClearTable(targetCoords)
	
	if not self.sticky and Options:GetSetting("Destination") == "waypoint" then
		targetCoords.instanceID, targetCoords.x, targetCoords.y = self.waypoint.instanceID, self.waypoint.x, self.waypoint.y
	elseif self.destinationUnit then
		targetCoords.instanceID, targetCoords.x, targetCoords.y = MapHandler:GetUnitPosition(self.destinationUnit)
	end
	
	if MapHandler:ValidCoords(targetCoords) then
		NS:ClearTable(playerCoords)
				
        -- if in instance attach floor information
        if IsInInstance() and Options:GetSetting("CheckInstanceFloor") then
            local _
            _, playerCoords.level = MapHandler:GetPlayerZonePosition()
        end

		playerCoords.instanceID, playerCoords.x, playerCoords.y = MapHandler:GetUnitPosition("player")
		
		return MapHandler:GetDistance(playerCoords, targetCoords, outStatus)
	else
		if type(outStatus) == "table" then
			outStatus.errorCode = self.INVALID_COORDS
		end
	end
	
	return
end

function Addon:GetDirectionToDestination(outStatus)
	local distance, dx, dy = self:GetDistanceToDestination(outStatus)
	local angle = MapHandler:GetViewAngle(dx, dy)
	
	return angle, distance
end

function Addon:GetDirectionToPing()
	local distance, dx, dy = MapHandler:GetDistanceToPing()
	local angle = MapHandler:GetViewAngle(dx, dy, true)
	
	return angle, distance
end

function Addon:InHealRange(target)
    local _, _, isHealer, spellName, rezSpellName = Units:GetPlayerInfo()
    
    if not Options:GetSetting("RangeCheck") or not isHealer then 
		return true
	end
	
	
    if UnitIsDead(target) then 
		spellName = rezSpellName
	end
	
    if IsSpellInRange(spellName, target) == 1 then 
		return true
    else 
		return false
    end
end

-- utilities
function Addon:LookupAlias(alias)
	return alias and aliases.reverse[alias] or alias
end

function Addon:PrintAliases()
		self:Output(L["Aliases:"])
		
		-- first sort commands alphabetically
		local commands = {}
		
		for cmd, _ in pairs(aliases.lookup) do
			local index = 1
			
			for _, otherCmd in ipairs(commands) do
				if cmd < otherCmd then
					break
				end
				
				index = index + 1
			end
			
			table.insert(commands, index, cmd)
		end
		
		-- then print them with aliases
		for _, cmd in ipairs(commands) do
			local aliases = aliases.lookup[cmd]
			local aliasString = ""
			
			for _, alias in ipairs(aliases) do
				aliasString = aliasString .. ", " .. alias
			end
			
			self:Output(string.format("%s - %s", cmd, aliasString:sub(2)))
		end
end

function Addon:Help(topic)
    if topic == "alias" then
		self:Output(L["alias - list aliases for commands"])
    elseif topic == "clear" then
		self:Output(L["clear - setting destination to none (releases the crazy arrow)"])
    elseif topic == "destination" then
		self:Output(L["destination target [args] - set the specified target as destination"])
		self:Output(L["Arguments:"])
		self:Output(string.format(L["target - either of (%s)"], "none|mouseover|mouseoverclick|name|raidtarget|unit|waypoint"))
		self:Output(L["args - depend on the selected target"])
		self:Output(string.format(L["%s) target is '%s'"], "1", "name"))
		self:Output(L["char - name of any friendly player character"])
		self:Output(string.format(L["Check help topic '%s'."], "name"))
		self:Output(string.format(L["%s) target is '%s'"], "2", "raidtarget"))
		self:Output(L["rt - any valid raid target id"])
		self:Output(string.format(L["Check help topic '%s'."], "raidtarget"))
		self:Output(string.format(L["%s) target is '%s'"], "3", "unit"))
		self:Output(L["unitId - any valid unit id"])
		self:Output(string.format(L["Check help topic '%s'."], "unit"))
		self:Output(string.format(L["%s) target is '%s'"], "4", "waypoint"))
		self:Output(L["args - any of the 3 above or specific coords"])
		self:Output(string.format(L["Check help topic '%s'."], "waypoint"))
		self:Output(string.format(L["%s) target is one of (%s)"], "5", "none|mouseover|mouseoverclick"))
		self:Output(L["args - none required"])
    elseif topic == "help" then
		self:Output(L["help [topic] - display this help, specify topic for any specific command"])
    elseif topic == "menu" then
		self:Output(L["menu - display options menu"])
    elseif topic == "name" then
		self:Output(L["name char - set specified char as target destination 'Name' is active"])
		self:Output(L["Arguments:"])
		self:Output(L["char - name of any friendly player character"])
    elseif topic == "ping" then
		self:Output(L["ping - ping on self"])
    elseif topic == "raidtarget" then
		self:Output(L["raidtarget rt - set specified raid target as target when destination 'Raid Target' is active"])
		self:Output(L["Arguments:"])
		self:Output(L["rt - any valid raid target id"])
		self:Output(L["Raid target ids:"])
		
		for rt = 1, RaidTargets.RAID_TARGET_COUNT do
			self:Output(string.format("%s: %s or %s or %d", RaidTargets:GetRaidTargetChatIdent(rt), RaidTargets:GetRaidTargetName(rt), RaidTargets:GetRaidTargetShort(rt),  rt))
		end		
    elseif topic == "sticky" then
		self:Output(L["sticky [target] [args] - stick/unstick current arrow target or set specific sticky target"])
		self:Output(L["Arguments:"])
		self:Output(L["If omitted current destination will stick/unstick."])
		self:Output(string.format(L["target - either of (%s)"], "name|raidtarget|unit"))
		self:Output(L["args - depend on the selected target"])
		self:Output(string.format(L["%s) target is '%s'"], "1", "name"))
		self:Output(L["char - name of any friendly player character"])
		self:Output(string.format(L["Check help topic '%s'."]), "name")
		self:Output(string.format(L["%s) target is '%s'"], "2", "raidtarget"))
		self:Output(L["rt - any valid raid target id"])
		self:Output(string.format(L["Check help topic '%s'."]), "raidtarget")
		self:Output(string.format(L["%s) target is '%s'"], "3", "unit"))
		self:Output(L["unitId - any valid unit id"])
		self:Output(string.format(L["Check help topic '%s'."]), "unit")
		self:Output(string.format(L["%s) target is '%s'"], "4", "waypoint"))
		self:Output(L["args - any of the 3 above or specific coords"])
		self:Output(string.format(L["Check help topic '%s'."]), "waypoint")
    elseif topic == "unit" then
		self:Output(L["unit unitId - set specified unit id as target when destination 'Unit' is active"])
		self:Output(L["Arguments:"])
		self:Output(L["unitId - any valid unit id"])
		self:Output(L["Valid unit ids:"])
		self:Output("player, target, focus, party1..4, raid1..40")
		self:Output(L["Each of those can be extended by an arbitrary number of 'target' at the end."])
    elseif topic == "version" then
		self:Output(L["version - display version information"])
    elseif topic == "waypoint" then
		self:Output(L["waypoint [args] - set a waypoint"])
		self:Output(L["Arguments:"])
		self:Output(L["If omitted current player position is set."])
		self:Output(L["x y - coordinates of waypoint, range is either 0..1 or 0..100"])
		self:Output(L["name - position of player character with specified name"])
		self:Output(L["raidtarget - position of unit with specified raid target"])
		self:Output(L["unit - position of specified unit"])
    elseif topic ~= nil then
		self:Output(L["Unknown help topic. Specify any valid command as topic."])
		topic = nil
    end

    if not topic then
		self:Output(L["Usage:"])
		self:Output("/tomtomping args")
		self:Output("/ttp args")
		self:Output(L["Arguments:"])
		self:Output(L["alias - list aliases for commands"])
		self:Output(L["clear - setting destination to none (releases the crazy arrow)"])
		self:Output(L["destination target [args] - set the specified target as destination"])
		self:Output(L["help [topic] - display this help, specify topic for any specific command"])
		self:Output(L["menu - display options menu"])
		self:Output(L["name char - set specified char as target destination 'Name' is active"])
		self:Output(L["ping - ping on self"])
		self:Output(L["raidtarget rt - set specified raid target as target when destination 'Raid Target' is active"])
		self:Output(L["sticky [target] [args] - stick/unstick current arrow target or set specific sticky target"])
		self:Output(L["unit unitId - set specified unit id as target when destination 'Unit' is active"])
		self:Output(L["version - display version information"])
		self:Output(L["waypoint [args] - set a waypoint as target when destination 'Waypoint' is active"])
    end
end

function Addon:Output(msg)
	if (msg ~= nil and DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage( self.MODNAME..": "..msg, 0.6, 1.0, 1.0 )
	end
end

-- testing
function Addon:Debug(msg)
	if ( self.debug and msg ~= nil and DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( self.MODNAME .. " (dbg): " .. msg, 1.0, 0.37, 0.37 )
	end
end
