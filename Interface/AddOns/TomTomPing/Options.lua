local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Options module
local Options = Addon:NewModule("Options")

-- internal event handling
Options.callbacks = LibStub("CallbackHandler-1.0"):New(Options)

-- local functions
local pairs   = pairs
local tinsert = table.insert

local _

local LibStub   = LibStub

-- config libraries
local AceConfig 		= LibStub:GetLibrary("AceConfig-3.0")
local AceConfigReg 		= LibStub:GetLibrary("AceConfigRegistry-3.0")
local AceConfigDialog	= LibStub:GetLibrary("AceConfigDialog-3.0")

-- translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- modules
local RaidTargets = nil
local Units       = nil

-- local variables
local defaults = {
	profile = {
        Ping                = true,
        Minimap             = false,
        HideHint            = false,
		Destination         = "none",
		RaidTarget          = 1,
        TargetUnit          = "target",
        TargetName          = "",
		RangeCheck          = false,
		ShowNoDest          = false,
        ArrivalRange        = 1,
        Duration            = 10,
		RangePrecision      = 1,
		TimePrecision       = 1,
        Release             = false,
		MouseButton         = nil,
		InCombat            = "always",
		OutOfCombat         = "always",
		WhenTargetAlive     = "always",
		WhenTargetDead      = "always",
		InRange             = "always",
		OutOfRange          = "always",
		UnitIsPlayer        = "never",
		UnitIsPet           = "never",
        Compass             = true,
		Icon                = "compass",
		CheckInstanceFloor  = false,
		CustomCmd1          = "",
		CustomCmd2          = "",
	},
}

-- bookkeeping for targeting type 
-- (needed to achieve ordered combobox, named option value and translated display value)
local destType = {
	opt2txt = {
		[0]           	= L["none"], 
		[1]				= L["mouseover"], 
		[2]				= L["mouseoverclick"], 
		[3]				= L["name"], 
		[4]				= L["raidtarget"], 
		[5]				= L["unit"], 
		[6]				= L["waypoint"], 
	},
	opt2val = {
		[0]				= "none", 
		[1]				= "mouseover", 
		[2]				= "mouseoverclick", 
		[3]				= "name", 
		[4]				= "raidtarget", 
		[5]				= "unit", 
		[6]				= "waypoint", 
	},
	val2opt = {
		none			= 0, 
		mouseover		= 1, 
		mouseoverclick	= 2, 
		name 			= 3, 
		raidtarget		= 4, 
		unit			= 5, 
		waypoint		= 6, 
	}
}

local modificators = {
	opt2txt = {
		[0]					= L["never"], 
		[1]					= L["always"], 
		[2]					= L["alt"], 
		[3]					= L["ctrl"], 
		[4]					= L["shift"], 
		[5]					= L["alt-ctrl"], 
		[6]					= L["alt-shift"], 
		[7]					= L["ctrl-shift"], 
		[8]					= L["alt-ctrl-shift"], 
	},
	opt2val = {
		[0]					= "never", 
		[1]					= "always", 
		[2]					= "alt", 
		[3]					= "ctrl", 
		[4]					= "shift", 
		[5]					= "alt-ctrl", 
		[6]					= "alt-shift", 
		[7]					= "ctrl-shift", 
		[8]					= "alt-ctrl-shift", 
	},
	val2opt = {
		["never"]			= 0, 
		["always"]			= 1, 
		["alt"]				= 2, 
		["ctrl"]			= 3, 
		["shift"]			= 4, 
		["alt-ctrl"]		= 5, 
		["alt-shift"]		= 6, 
		["ctrl-shift"]		= 7, 
		["alt-ctrl-shift"]	= 8, 
	}
}

local mouseButtons = {
	opt2txt = {
		[0]           	= L["AnyButton"], 
		[1]				= L["LeftButton"], 
		[2]				= L["RightButton"], 
		[3]				= L["MiddleButton"], 
		[4]				= L["Button4"], 
		[5]				= L["Button5"], 
	},
	opt2val = {
		[0]				= "AnyButton", 
		[1]				= "LeftButton", 
		[2]				= "RightButton", 
		[3]				= "MiddleButton", 
		[4]				= "Button4", 
		[5]				= "Button5", 
	},
	val2opt = {
		AnyButton		= 0, 
		LeftButton		= 1, 
		RightButton		= 2, 
		MiddleButton	= 3, 
		Button4			= 4, 
		Button5			= 5, 
	}
}

local compassIcons = {
	opt2txt = {
		[0]     = L["Arrow"], 
		[1]		= L["Compass"], 
	},
	opt2val = {
		[0]		= "arrow", 
		[1]		= "compass", 
	},
	val2opt = {
		arrow	= 0, 
		compass	= 1, 
	}
}

local raidTargets = {
}

local defaultUnitIds = {"focus", "focustarget", "target", "targettarget"}

local targetUnits = {
	opt2txt = {},
	opt2val = {},
	val2opt = {}
}

-- module handling
function Options:OnInitialize()
	-- set module references
	RaidTargets = Addon:GetModule("RaidTargets")
	Units       = Addon:GetModule("Units")

    -- setup raid targets
    for i = 1, RaidTargets.RAID_TARGET_COUNT do
        raidTargets[i] = RaidTargets:GetRaidTargetTextIcon(i, 12) .. " " .. L[RaidTargets:GetRaidTargetName(i)]
    end
    
	-- options
	self.options = {}
	
	-- options
	self.db = LibStub:GetLibrary("AceDB-3.0"):New(Addon.MODNAME.."_DB", defaults, "Default")
	
    self:RefreshTargetUnits()
    
	self:Setup()
		
	-- profile support
	self.options.args.profile = LibStub:GetLibrary("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied",  "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset",   "OnProfileChanged")

	AceConfigReg:RegisterOptionsTable(Addon.FULLNAME, self.options)
	AceConfigDialog:AddToBlizOptions(Addon.FULLNAME)
end

function Options:OnEnable()
	-- empty
end

function Options:OnDisable()
	-- empty
end

function Options:OnProfileChanged(event, database, newProfileKey)
	self.db.profile = database.profile
	
	Addon:OnOptionsReloaded()
end

function Options:Setup()	
    self.options = {
		handler = Options,
		type = 'group',
		args = {
			minimap = {
				type = 'toggle',
				name = L["Minimap Button"],
				desc = L["Show Minimap Button"],
				get  = function() return self:GetSetting("Minimap") end,
				set  = function()
					self:ToggleSetting("Minimap")
				end,
				order = 1,
			},
			hint = {
				type = 'toggle',
				name = L["Hide Hint"],
				desc = L["Hide usage hint in tooltip"],
				get  = function() return self:GetSetting("HideHint") end,
				set  = function()
					self:ToggleSetting("HideHint") 
				end,
				order = 2,
			},
			keyHint = {
				type = "description",
				name = L["Also check the key bindings!"],
				order = 3,
			},
			arrow = {
				type = 'group',
				name = L["Arrow"],
				desc = L["Arrow Display Settings"],
				order = 4,
				args = {
					timeprec = {
						type = 'range',
						name = L["Time Precision"],
						desc = L["Positions after decimal point"],
						get = function() return self:GetSetting("TimePrecision") end,
						set = function(info, value) 
							self:SetSetting("TimePrecision", value)
						end,
						min = 0,
						max = 2,
						step = 1,
						bigStep = 1,
						order = 1,
					},
					rangeprec = {
						type = 'range',
						name = L["Range Precision"],
						desc = L["Positions after decimal point"],
						get = function() return self:GetSetting("RangePrecision") end,
						set = function(info, value) 
							self:SetSetting("RangePrecision", value)
						end,
						min = 0,
						max = 2,
						step = 1,
						bigStep = 1,
						order = 2,
					},
				},
			},
			ping = {
				type = 'group',
				name = L["Ping"],
				desc = L["Ping Settings"],
				order = 5,
				args = {
					ping = {
						type = 'toggle',
						name = L["Activate Ping"],
						desc = L["Show arrow on ping"],
						get  = function() return self:GetSetting("Ping") end,
						set  = function()
							self:ToggleSetting("Ping")
						end,
						order = 1,
					},
					release = {
						type = 'toggle',
						name = L["Hide on arrival"],
						desc = L["Hide arrow when within distance"],
						get  = function() return self:GetSetting("Release") end,
						set  = function()
							self:ToggleSetting("Release")
						end,
						order = 2,
					},
					duration = {
						type = 'range',
						name = L["Duration"],
						desc = L["Duration before fade out"],
						get = function() return self:GetSetting("Duration") end,
						set = function(info, value) 
							self:SetSetting("Duration", value)
						end,
						min = 0,
						max = 60,
						step = 1,
						bigStep = 1,
						order = 3,
					},
					range = {
						type = 'range',
						name = L["Arrival Range"],
						desc = L["Arrow points down to indicate arrival when within this distance"],
						get = function() return self:GetSetting("ArrivalRange") end,
						set = function(info, value) 
							self:SetSetting("ArrivalRange", value)
						end,
						min = 0,
						max = 100,
						step = 1,
						bigStep = 1,
						order = 4,
					},
				},
			},
			targeting = {
				type = 'group',
				name = L["Targeting"],
				desc = L["Target Settings"],
				order = 6,
				args = {
					destination = {
						type = 'select',
						name = L["Destination Type"],
						desc = L["Destination type instructions"],
						get = function() return destType.val2opt[self:GetSetting("Destination")] end,
						set = function(info, value) 
							self:SetSetting("Destination", destType.opt2val[value])
						end,
						values = destType.opt2txt,
						order = 1,
					},
					raidTarget = {
						type = 'select',
						name = L["Raid Target"],
						desc = L["Select raid target to track when destination 'Raid Target' is active."],
						get = function() return self:GetSetting("RaidTarget") end,
						set = function(info, value) 
							self:SetSetting("RaidTarget", value)
						end,
						values = raidTargets,
						order = 2,
					},
                    targetName = {
                        type = 'input',
                        name = L["Character Name"],
                        desc = L["Name of character to track when destination 'Name' is active."],
                        get = function() return self:GetSetting("TargetName") end,
                        set = function(info, value)
                            self:SetSetting("TargetName", value)
                        end,
                        order = 3,
                    },
					targetUnit = {
						type = 'select',
						name = L["Target Unit"],
						desc = L["Select unit to track when destination 'Unit' is active."],
						get = function() return targetUnits.val2opt[self:GetSetting("TargetUnit")] end,
						set = function(info, value) 
							self:SetSetting("TargetUnit", targetUnits.opt2val[value])
						end,
						values = targetUnits.opt2txt,
						order = 4,
					},
					mouseButton = {
						type = 'select',
						name = L["Mouse Button"],
						desc = L["Select mouse button to use when destination 'Mouse-Over-Click' is active."],
						get = function() return mouseButtons.val2opt[self:GetSetting("MouseButton") or "AnyButton"] end,
						set = function(info, value)
							local button = mouseButtons.opt2val[value]
							
							if value == 0 then
								button = nil
							end
							
							self:SetSetting("MouseButton", button)
						end,
						values = mouseButtons.opt2txt,
						order = 5,
					},
					rangeCheck = {
						type = 'toggle',
						name = L["Range Check"],
						desc = L["Range check for healing"],
						get  = function() return self:GetSetting("RangeCheck") end,
						set  = function()
							self:ToggleSetting("RangeCheck")
						end,
						order = 6,
					},
					showNoDest = {
						type = 'toggle',
						name = L["Show Empty Destination"],
						desc = L["Show arrow when no destination is set"],
						get  = function() return self:GetSetting("ShowNoDest") end,
						set  = function()
							self:ToggleSetting("ShowNoDest")
						end,
						order = 7,
					},
					checkInstanceLevel = {
						type = 'toggle',
						name = L["Check Instance Floor"],
						desc = L["Check whether target is on the same floor in instances and shows path error for arrow if not."],
						get  = function() return self:GetSetting("CheckInstanceFloor") end,
						set  = function()
							self:ToggleSetting("CheckInstanceFloor")
						end,
						order = 8,
					},
					modificators = {
						type = 'group',
						name = L["Modificator keys"],
						desc = L["Modificator keys for mouse-over settings."],
						order = 9,
						args = {
							modInCombat = {
								type = 'select',
								name = L["In Combat"],
								desc = string.format(L["Show mouse-over target %s."], L["in combat"]),
								get = function() return modificators.val2opt[self:GetSetting("InCombat")] end,
								set = function(info, value) 
									self:SetSetting("InCombat", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 1,
							},
							modOutOfCombat = {
								type = 'select',
								name = L["Out of Combat"],
								desc = string.format(L["Show mouse-over target %s."], L["out of combat"]),
								get = function() return modificators.val2opt[self:GetSetting("OutOfCombat")] end,
								set = function(info, value) 
									self:SetSetting("OutOfCombat", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 2,
							},
							modWhenTargetAlive = {
								type = 'select',
								name = L["Target Alive"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["alive"]),
								get = function() return modificators.val2opt[self:GetSetting("WhenTargetAlive")] end,
								set = function(info, value) 
									self:SetSetting("WhenTargetAlive", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 3,
							},
							modWhenTargetDead = {
								type = 'select',
								name = L["Target Dead"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["dead"]),
								get = function() return modificators.val2opt[self:GetSetting("WhenTargetDead")] end,
								set = function(info, value) 
									self:SetSetting("WhenTargetDead", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 4,
							},
							modInRange = {
								type = 'select',
								name = L["In Range"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["in healing range"]),
								get = function() return modificators.val2opt[self:GetSetting("InRange")] end,
								set = function(info, value) 
									self:SetSetting("InRange", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 5,
							},
							modOutOfRange = {
								type = 'select',
								name = L["Out of Range"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["out of healing range"]),
								get = function() return modificators.val2opt[self:GetSetting("OutOfRange")] end,
								set = function(info, value) 
									self:SetSetting("OutOfRange", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 6,
							},
							modUnitIsPlayer = {
								type = 'select',
								name = L["Unit is Player"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["yourself"]),
								get = function() return modificators.val2opt[self:GetSetting("UnitIsPlayer")] end,
								set = function(info, value) 
									self:SetSetting("UnitIsPlayer", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 7,
							},
							modUnitIsPet = {
								type = 'select',
								name = L["Unit is Pet"],
								desc = string.format(L["Show mouse-over target when target is %s."], L["a pet"]),
								get = function() return modificators.val2opt[self:GetSetting("UnitIsPet")] end,
								set = function(info, value) 
									self:SetSetting("UnitIsPet", modificators.opt2val[value])
								end,
								values = modificators.opt2txt,
								order = 8,
							},
						},
					},
				},
			},
			icon = {
				type = 'group',
				name = L["Icon"],
				desc = L["Icon Settings"],
				order = 5,
				args = {
					compass = {
						type = 'toggle',
						name = L["Compass"],
						desc = L["Use compass icon that shows player direction."],
						get  = function() return self:GetSetting("Compass") end,
						set  = function()
							self:ToggleSetting("Compass")
						end,
						order = 1,
					},
					icon = {
						type = 'select',
						name = L["Compass Icon"],
						desc = L["Select compass icon."],
						get = function() return compassIcons.val2opt[self:GetSetting("Icon")] end,
						set = function(info, value) 
							self:SetSetting("Icon", compassIcons.opt2val[value])
						end,
						values = compassIcons.opt2txt,
						order = 2,
					},
				},
			},
			commands = {
				type = 'group',
				name = L["Custom Commands"],
				desc = L["Custom Command Settings"],
				order = 6,
				args = {
					customCmd1 = {
                        type = 'input',
                        name = string.format(L["Custom Command %d"], 1),
                        desc = string.format(L["Command for keybinding for custom command %d. You can use any valid /ttp console command (without the '/ttp'). Use console command '/ttp help' for more info."], 1),
                        get = function() return self:GetSetting("CustomCmd1") end,
                        set = function(info, value)
                            self:SetSetting("CustomCmd1", value)
                        end,
						order = 1,
					},
					customCmd2 = {
                        type = 'input',
                        name = string.format(L["Custom Command %d"], 2),
                        desc = string.format(L["Command for keybinding for custom command %d. You can use any valid /ttp console command (without the '/ttp'). Use console command '/ttp help' for more info."], 2),
                        get = function() return self:GetSetting("CustomCmd2") end,
                        set = function(info, value)
                            self:SetSetting("CustomCmd2", value)
                        end,
						order = 2,
					},
				},
			},
		},
	}
end

function Options:RefreshTargetUnits()
    NS:ClearTable(targetUnits.opt2txt)
    NS:ClearTable(targetUnits.opt2val)
    NS:ClearTable(targetUnits.val2opt)
    
    for i = 1, #defaultUnitIds do
        local unitId = defaultUnitIds[i]
        
        targetUnits.opt2txt[i] = Units:GetUnitIdLabel(unitId)
        targetUnits.opt2val[i] = unitId
        targetUnits.val2opt[unitId] = i
    end
    
    local targetUnit = self:GetSetting("TargetUnit")

    -- if non basic unit id was manually set
    if not targetUnits.val2opt[targetUnit] then
        local index = #targetUnits.opt2txt + 1
        
        targetUnits.opt2txt[index] = Units:GetUnitIdLabel(targetUnit)
        targetUnits.opt2val[index] = targetUnit
        targetUnits.val2opt[targetUnit] = index
    end
end

-- settings
function Options:GetSetting(option)
	return self.db.profile[option]
end

function Options:SetSetting(option, value)
	local current = self:GetSetting(option)

	if current == value then
		return
	end
	
	self.db.profile[option] = value

	-- fire event when setting changed
	self.callbacks:Fire(ADDON .. "_SETTING_CHANGED", option, value, current)
end

function Options:ToggleSetting(option)
	self:SetSetting(option, not self:GetSetting(option) and true or false)
end

function Options:ToggleSettingTrueNil(option)
	self:SetSetting(option, not self:GetSetting(option) and true or nil)
end

-- utilities
function Options:IterateDestinations()
	return ipairs(destType.opt2val)
end

function Options:IterateTargetUnits()
	return ipairs(targetUnits.opt2val)
end

function Options:IsValidDestination(destination)
	return destType.val2opt[destination] and true or false
end

-- test
function Options:Debug(msg)
	Addon:Debug("(Options) " .. msg)
end
