--- Missing Class Buff
--- Written by Kaloryth

local ADDON_NAME, MCB = ...
local MyAddon = MCB.MyAddon
local LEM = LibStub('LibEditMode')
MissingClassBuffDB = MissingClassBuffDB or {}

MCB.CLICK_TO_CAST_SPELL_TYPES = {TOY = "toy", SPELL = "spell", ITEM = "item"}

MCB.customSpellIdsError = ""
MCB.flaskClickToCastError = ""
MCB.foodClickToCastError = ""
MCB.oilClickToCastError = ""

MCB.DEFAULT_SETTINGS = {
    alpha = .8,
    iconHeight = 80,
    iconWidth = 80,
    textFont = "GameFontNormal",
    fontSize = 16,
    frameHeight = 100,
    frameWidth = 100,
    point = 'CENTER',
    x = 0,
    y = 250,
    hideText = false,
    iconZoom = 0,
    zoomLeft = 0,
    zoomRight = 1,
    zoomTop = 0,
    zoomBottom = 1
}

MCB.EDIT_MODE_SETTINGS = {
    {
        name = 'Icon Width',
        kind = LEM.SettingType.Slider,
        default = MCB.DEFAULT_SETTINGS.iconWidth,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "iconWidth")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "iconWidth", value)
            MCB.SetLayoutSettingValue(layoutName, "frameWidth", value)
            MCB.MISSING_FRAME.iconFrame:SetWidth(value)
            MCB.MISSING_FRAME:SetWidth(value + 20)
            if not InCombatLockdown() then
                MCB.SECURE_BUTTON:SetWidth(value)
            end
            if MCB.MasqueGroup then
                MCB.MasqueGroup:ReSkin()
            end
        end,
        minValue = 10,
        maxValue = 300,
        valueStep = 1,
        formatter = function(value)
        return value
        end,
  },
  {
        name = 'Icon Height',
        kind = LEM.SettingType.Slider,
        default = MCB.DEFAULT_SETTINGS.iconHeight,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "iconHeight")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "iconHeight", value)
            MCB.SetLayoutSettingValue(layoutName, "frameHeight", value + 20)
            MCB.MISSING_FRAME.iconFrame:SetHeight(value)
            MCB.MISSING_FRAME:SetHeight(value + 20)
            if not InCombatLockdown() then
                MCB.SECURE_BUTTON:SetHeight(value)
            end
            if MCB.MasqueGroup then
                MCB.MasqueGroup:ReSkin()
            end
        end,
        minValue = 10,
        maxValue = 300,
        valueStep = 1,
        formatter = function(value)
        return value
        end,
  },
  {
        name = 'Icon Alpha',
        kind = LEM.SettingType.Slider,
        default = MCB.DEFAULT_SETTINGS.alpha,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "alpha")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "alpha", value)
            MCB.MISSING_FRAME.icon:SetAlpha(value)
        end,
        minValue = .1,
        maxValue = 1.0,
        valueStep = .05,
        formatter = function(value)
            local function roundToSecondDecimal(n)
                return math.floor(n * 100 + 0.5) / 100
            end
            return roundToSecondDecimal(value)
        end,
  },
  {
        name = 'Icon Zoom',
        kind = LEM.SettingType.Slider,
        default = MCB.DEFAULT_SETTINGS.iconZoom,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "iconZoom")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "iconZoom", value)
            local zoomPercent = value
            -- defaults to 0 if nil -- keep between 0 and 100
            zoomPercent = math.max(0, math.min(100, zoomPercent or 0))
            
            -- converting from 0-100 scale to 0-0.5
            local zoomValue = (zoomPercent / 100) * 0.5
            
            -- in case measure
            if zoomValue > 0.49 then zoomValue = 0.49 end

            local left   = 0 + zoomValue
            local right  = 1 - zoomValue
            local top    = 0 + zoomValue
            local bottom = 1 - zoomValue
            
            MCB.SetLayoutSettingValue(layoutName, "zoomLeft", left)
            MCB.SetLayoutSettingValue(layoutName, "zoomRight", right)
            MCB.SetLayoutSettingValue(layoutName, "zoomTop", top)
            MCB.SetLayoutSettingValue(layoutName, "zoomBottom", bottom)

            MCB.MISSING_FRAME.icon:SetTexCoord(left, right, top, bottom)
        end,
        minValue = 0,
        maxValue = 100,
        valueStep = 1,
        formatter = function(value)
            return math.floor(value)
        end,
  },
  {
        name = 'Font Size',
        kind = LEM.SettingType.Slider,
        default = MCB.DEFAULT_SETTINGS.fontSize,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "fontSize")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "fontSize", value)
            local fontObject = _G[MCB.DEFAULT_SETTINGS.textFont]
            local font, _, flags = fontObject:GetFont()
            MCB.MISSING_FRAME.text:SetFont(font, value, "OUTLINE")
        end,
        minValue = 6,
        maxValue = 50,
        valueStep = 1,
  },
  {
        name = 'Hide Text',
        kind = LEM.SettingType.Checkbox,
        default = false,
        get = function(layoutName)
            return MCB.GetLayoutSettingValue(layoutName, "hideText")
        end,
        set = function(layoutName, value)
            MCB.SetLayoutSettingValue(layoutName, "hideText", value)
            if value then
                MCB.MISSING_FRAME.text:Hide()
            else
                MCB.MISSING_FRAME.text:Show()
            end
        end
  }
}


MCB.ZONE_NAME_MAPPING = {
    ["party"] = {name = "Dungeons", order = 1 },
    ["raid"] = {name = "Raids", order = 2},
    ["scenario"] = {name = "Scenarios/Delves", order = 3},
    ["pvp"] = {name = "Battlegrounds", order = 4},
    ["arena"] = {name = "Arena", order = 5},
    ["none"] = {name = "Open World", order = 6}
}

function MCB.GetLayoutSettingValue(layoutName, settingName)
    return MissingClassBuffDB["layouts"][layoutName][settingName]
end

function MCB.SetLayoutSettingValue(layoutName, settingName, value)
    MissingClassBuffDB["layouts"][layoutName][settingName] = value
end

function MCB.addToSettingsTable(settingsName, value)
    local setting = MCB.GetSettingsValue(settingsName)
    if not setting then
        MyAddon.db.profile[settingsName] = {}
        setting = MyAddon.db.profile[settingsName]
    end
    setting[value] = true
    MCB.CheckForMissings()
end

function MCB.removeFromSettingsTable(settingsName, value)
    local setting = MCB.GetSettingsValue(settingsName)
    if setting then
        setting[value] = false
    end
    MCB.CheckForMissings()
end

function MCB.checkIfSettingsTableContains(settingName, value)
    local setting = MCB.GetSettingsValue(settingName) or {}
    return setting[value]
end


function MCB.InstantiateSettings()
    local defaults = {
        profile = {
            ignoreLethalPoisons = false,
            ignoreNonLethalPoisons = false,
            overrideDefaultLethalPoison = 381664,
            overrideDefaultNonLethalPoison = true,
            overrideNonLethalWithTalent = true,
            ignoreWarriorStances = false,
            ignorePaladinAuras = false,
            overrideDefaultPaladinAura = nil,
            ignoreEvokerAttunements = false,
            overrideEvokerAttunement = nil,
            ignoreHunterPets = false,
            ignoreHunterPetsWhenMarksman = false,
            overrideHunterCallPet = nil,
            ignoreWarlockPets = false,
            overrideWarlockSummonPet = nil,
            ignoreDeathKnightPets = false,
            ignoreMagePets = false,
            ignoreMoonkinFormOOC = true,
            ignoreShadowFormOOC = false,
            treatTravelFormAsMount = true,
            checkForCrusaderInCombat = true,
            checkForWrongWarriorStance = true,
            notifyWhenDurationLow = true,
            durationLeft = 5,
            makeIconClickable = true,
            trackFood = false,
            trackFlask = false,
            trackOil = false,
            notifyForConsumables = false,
            durationForConsumables = 2,
            ignoreLegacyContentForFood = true,
            ignoreLegacyContentForFlask = true,
            ignoreLegacyContentForOil = true,
            ignoreLegacyContentForCustom = true,
            showCustomSpellIds = false,
            flaskClickToCastId = nil,
            foodClickToCastId = nil,
            oilClickToCastId = nil,
            customSpellIds = {},
            notifyForCustom = false,
            durationForCustom = 2,
            hideCustomIfItemOnCD = false,
            hideCustomIfItemNotInInventory = false,
            ignoreBuffsWhileMounted = true,
            ignoreWhileResting = false,
            ignoredSettingsIds = {
                [33] = false
            },
            useBuffGlows = {
                ["PALADIN"] = true
            },
            advancedSettingsAcknowledgement = false,
            debounceCheckThrottle = .25,
            difficultySettings = {
                ["party"] = {
                    ["normal"] = {
                        order = 1,
                        showFlask = false,
                        showFood = false,
                        showOil = false,
                        showCustom = false
                    },
                    ["heroic"] = {
                        order = 3,
                        showFlask = false,
                        showFood = false,
                        showOil = false,
                        showCustom = false
                    },
                    ["mythic"] = {
                        order = 5,
                        showFlask = true,
                        showFood = true,
                        showOil = true,
                        showCustom = true
                    },
                    ["mythicplus"] = {
                        order = 7,
                        showFlask = false,
                        showFood = false,
                        showOil = true,
                        showCustom = false
                    },
                    ["other"] = {
                        order = 9,
                        showFlask = false,
                        showFood = false,
                        showOil = false,
                        showCustom = false
                    }
                },
                ["raid"] = {
                    ["lfr"] = {
                        order = 1,
                        showFlask = false,
                        showFood = false,
                        showOil = false,
                        showCustom = false
                    },
                    ["normal"] = {
                        order = 3,
                        showFlask = true,
                        showFood = true,
                        showOil = true,
                        showCustom = true
                    },
                    ["heroic"] = {
                        order = 5,
                        showFlask = true,
                        showFood = true,
                        showOil = true,
                        showCustom = true
                    },
                    ["mythic"] = {
                        order = 7,
                        showFlask = true,
                        showFood = true,
                        showOil = true,
                        showCustom = true
                    },
                    ["other"] = {
                        order = 9,
                        showFlask = false,
                        showFood = false,
                        showOil = false,
                        showCustom = false
                    }
                }
            },
            zoneSettings = {
                ["party"] = {
                    trackFood = true,
                    trackFlask = true,
                    trackOil = true,
                    showCustomSpellIds = true,
                    ignoreAlliesGlobally = false,
                    ignoreAllies = {
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                        ["PALADIN"] = true
                    }
                },
                ["raid"] = {
                    trackFood = true,
                    trackFlask = true,
                    trackOil = true,
                    showCustomSpellIds = true,
                    ignoreAlliesGlobally = false,
                    ignoreAllies = {
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                        ["PALADIN"] = true
                    }
                },
                ["scenario"] = {
                    trackFood = false,
                    trackFlask = false,
                    trackOil = false,
                    showCustomSpellIds = false,
                    ignoreAlliesGlobally = false,
                    ignoreAllies = {
                        ["EVOKER"] = true,
                        ["WARRIOR"] = true
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                        ["PALADIN"] = true
                    }
                },
                ["pvp"] = {
                    trackFood = false,
                    trackFlask = false,
                    trackOil = false,
                    showCustomSpellIds = false,
                    ignoreAlliesGlobally = true,
                    ignoreAllies = {
                        ["EVOKER"] = true,
                        ["WARRIOR"] = true
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                    }
                },
                ["arena"] = {
                    trackFood = false,
                    trackFlask = false,
                    trackOil = false,
                    showCustomSpellIds = false,
                    ignoreAlliesGlobally = true,
                    ignoreAllies = {
                        ["EVOKER"] = true,
                        ["WARRIOR"] = true
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                    }
                },
                ["none"] = {
                    trackFood = false,
                    trackFlask = false,
                    trackOil = false,
                    showCustomSpellIds = false,
                    ignoreAlliesGlobally = false,
                    ignoreAllies = {
                        ["EVOKER"] = true,
                        ["WARRIOR"] = true
                    },
                    ignoreRangeGlobally = false,
                    ignoreRange = {
                    },
                    showInCombatGlows = {
                    }
                }
            }
        }
    }

    MyAddon.db = LibStub("AceDB-3.0"):New("MissingClassBuffDB", defaults, true)
    MyAddon.db.RegisterCallback(MyAddon, "OnProfileChanged", "OnProfileChanged")
    MyAddon.db.RegisterCallback(MyAddon, "OnProfileCopied", "OnProfileChanged")
    MyAddon.db.RegisterCallback(MyAddon, "OnProfileReset", "OnProfileChanged")
    local AceDBOptions = LibStub("AceDBOptions-3.0")

    MCB.runSettingsMigrationCheck()

    MCB.settings = {
        name = "MissingClassBuff",
        handler = MCB,
        type = "group",
		childGroups = "tab",
        args = {
            general = {
                name = "General",
                inline = false,
                order = 1,
                type = "group",
                args = {
                    linebreak1 = {
                        type = "description",
                        name = " ",
                        order = 1,
                    },
                    iconClickable = {
                        name = "Make Icon Clickable",
                        order = 2,
                        desc = "Allows you to click on the notification icon to attempt to cast the missing buff",
                        type = "toggle",
                        width = "full",
                        get = function(_)
                            return MyAddon.db.profile.makeIconClickable
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.makeIconClickable = value
                            if not value and not InCombatLockdown() then
                                MCB.SECURE_BUTTON:Hide()
                            end
                            MCB.CheckForMissings()
                        end
                    },
                    ignoreWhileMounted = {
                        name = "Ignore Buffs While Mounted",
                        order = 3,
                        desc = "Don't show buff display while mounted",
                        type = "toggle",
                        width = "full",
                        get = function(_)
                            return MyAddon.db.profile.ignoreBuffsWhileMounted
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.ignoreBuffsWhileMounted = value
                            MCB.CheckForMissings()
                        end
                    },
                    ignoreWhileRested = {
                        name = "Ignore Buffs in Rested Areas",
                        order = 4,
                        desc = "Don't show buff display while in rested areas like cities/inns",
                        type = "toggle",
                        width = "full",
                        get = function(_)
                            return MyAddon.db.profile.ignoreWhileResting
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.ignoreWhileResting = value
                            MCB.CheckForMissings()
                        end
                    },
                    linebreak2 = {
                        type = "description",
                        name = " ",
                        order = 6,
                    },
                    ignoreAllies = {
                        name = "Ignore allies on all classes",
                        inline = true,
                        order = 7,
                        type = "group",
                        args = MCB.createIgnoreGlobalCheckboxes("ignoreAlliesGlobally")
                    },
                    ignoreRange = {
                        name = "Display notification anyway when allies out of range on all classes",
                        inline = true,
                        order = 8,
                        type = "group",
                        args = MCB.createIgnoreGlobalCheckboxes("ignoreRangeGlobally")
                    },
                    notifyDuration = {
                        name = "Notify when buff duration is low on self",
                        inline = true,
                        order = 9,
                        type = "group",
                        args = {
                            enable = {
                                name = "Enable",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.notifyWhenDurationLow
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.notifyWhenDurationLow = value
                                    MCB.CheckForMissings()
                                end
                            },
                            duration = {
                                name = "Duration Remaining",
                                type = "range",
                                desc = "Select minutes",
                                min = 1,
                                max = 45,
                                step = 1,
                                get = function(_)
                                    return MyAddon.db.profile.durationLeft
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.durationLeft = value
                                    MCB.CheckForMissings()
                                end
                            }
                        }
                    },
                    linebreak3 = {
                        type = "description",
                        name = " ",
                        order = 15,
                    },
                    advanced = {
                        type = "description",
                        name = "ADVANCED",
                        fontSize = "large",
                        order = 16
                    },
                    acknowledgement = {
                        type = "toggle",
                        name = "I know what I am doing and want to change advanced settings",
                        width = "full",
                        order = 18,
                        get = function(_)
                            return MyAddon.db.profile.advancedSettingsAcknowledgement
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.advancedSettingsAcknowledgement = value
                        end
                    },
                    linebreak4 = {
                        type = "description",
                        name = " ",
                        order = 19,
                    },
                    debounceCheckThrottle = {
                        name = "Delay in seconds between notification checks",
                        type = "range",
                        desc = "How frequently the addon will scan buffs/relevant player state to refresh the notification",
                        width = 2.0,
                        order = 20, 
                        min = .1,
                        max = 10,
                        step = .05,
                        get = function(_)
                            return MyAddon.db.profile.debounceCheckThrottle
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.debounceCheckThrottle = value
                            MCB.CHECK_THROTTLE = value
                            MCB.CheckForMissings()
                        end,
                        disabled = function() return not MyAddon.db.profile.advancedSettingsAcknowledgement end,
                    },
                    throttleDesc = {
                        type = "description",
                        name = "How frequently the addon will scan buffs/relevant player state to refresh the notification. Longer delays will make the addon seem less snappy and less responsive. Longer delays can help with performance if you are concerned about memory. This addon uses very little CPU. Recommended setting is between .25 and .5 seconds.",
                        order = 21,
                    },
                }
            },
            class = {
                name = "Class Specific",
                inline = false,
                order = 2,
                type = "group",
                args = {
                    deathknight = {
                        name = "Death Knight",
                        type = "group",
                        args = {
                            ignorePet = {
                                name = "Ignore Pet",
                                desc = "Ignore Unholy Ghoul Pet",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreDeathKnightPets
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreDeathKnightPets = value
                                    MCB.CheckForMissings()
                                end
                            }
                        }
                    },
                    druid = {
                        name = "Druid",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("DRUID")
                            },
                            -- linebreak = {
                            --     type = "description",
                            --     name = " ",
                            --     order = 2,
                            -- },
                            ignoreMoonkinOOC = {
                                name = "Only check Moonkin Form in combat",
                                order = 2,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreMoonkinFormOOC
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreMoonkinFormOOC = value
                                    MCB.CheckForMissings()
                                end
                            },
                            treatTravelFormAsMount = {
                                name = "Treat Travel Form as a mount",
                                order = 3,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.treatTravelFormAsMount
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.treatTravelFormAsMount = value
                                    MCB.CheckForMissings()
                                end
                            },
                            -- linebreak2 = {
                            --     type = "description",
                            --     name = " ",
                            --     order = 4,
                            -- },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 5,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "DRUID")
                            },
                            ignoreRange = {
                                name = "Display notification anyway when allies out of range",
                                order = 6,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreRange", "DRUID")
                            }
                        }
                    },
                    evoker = {
                        name = "Evoker",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("EVOKER")
                            },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 3,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "EVOKER")
                            },
                            ignoreRange = {
                                name = "Display notification anyway when allies out of range",
                                order = 4,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreRange", "EVOKER")
                            },
                            ignoreAttunements = {
                                name = "Ignore Attunements",
                                order = 9,
                                desc = "Ignore Augmentation Evoker attunements",
                                width = "full",
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreEvokerAttunements
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreEvokerAttunements = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak2 = {
                                type = "description",
                                name = " ",
                                order = 10,
                            },
                            attunementHeader = {
                                type = "description",
                                name = function() return MCB.GetDefaultStanceText(MCB.EVOKER_ATTUNEMENTS) end,
                                order = 11,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignoreEvokerAttunements end,
                            },
                            overrideAttunement = {
                                name = "Override Default Attunement (If Learned)",
                                desc = "Choose a specific attunement to display as the attunement notification instead of the default attunement. Will only override correctly if the spell is learned.",
                                order = 12,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideEvokerAttunement end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideEvokerAttunement = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignoreEvokerAttunements end,
                            },
                            attunementSelect = {
                                name = "Select Preferred Attunement",
                                type = "select",
                                order = 13,
                                width = "double",
                                values = function() return MCB.GetSelectionOptionsFromStance(MCB.EVOKER_ATTUNEMENTS) end,
                                get = function() return MyAddon.db.profile.overrideEvokerAttunement end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideEvokerAttunement = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideEvokerAttunement end,
                                hidden = function() return MyAddon.db.profile.ignoreEvokerAttunements end,
                            },
                            linebreak4 = {
                                type = "description",
                                name = " ",
                                order = 19,
                            },
                            explanation = {
                                type = "description",
                                name = "Due to API limitations and issues with Blessing of the Bronze, this addon is unable to do range checks correctly on an Evoker. No range check will be done when checking allies for Blessing of the Bronze. Please select Ignore Allies for the appropriate zones to avoid annoyances with the notification. Range checks will be done for other Evoker buffs.",
                                order = 20,
                            },
                            linebreak3 = {
                                type = "description",
                                name = " ",
                                order = 21,
                            },
                            explanation2 = {
                                type = "description",
                                name = "Source of Magic detection is done by looking for a player in your party or raid with the healer role set. If players do not have their roles set correctly, detection can go wrong. EX: No healers in group but a shadow priest has their role set to healer, this addon will think they are a valid target.",
                                order = 25,
                            }
                        }
                    },
                    hunter = {
                        name = "Hunter",
                        type = "group",
                        args = {
                            ignorePet = {
                                name = "Ignore Pet",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreHunterPets
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreHunterPets = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak = {
                                type = "description",
                                name = " ",
                                order = 2,
                            },
                            ignorePetWhileMarksman = {
                                name = "Ignore Pet While Marksman",
                                order = 3,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreHunterPetsWhenMarksman
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreHunterPetsWhenMarksman = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak2 = {
                                type = "description",
                                name = " ",
                                order = 5,
                            },
                            callPetHeader = {
                                type = "description",
                                name = function() return MCB.GetTextForBuff(MCB.HUNTER_PET_MISSING) end,
                                order = 11,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignoreHunterPets end,
                            },
                            overrideSummonPets = {
                                name = "Override Default Summon Pet (If Learned)",
                                desc = "Choose a specific call pet to display as the missing pet notification instead of the default call pet. Will only override correctly if the spell is learned.",
                                order = 12,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideHunterCallPet end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideHunterCallPet = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignoreHunterPets end,
                            },
                            petSelect = {
                                name = "Select Preferred Pet",
                                type = "select",
                                order = 13,
                                width = "double",
                                values = function() return MCB.GetSelectionOptionsFromPetTable(MCB.HUNTER_ALL_PETS) end,
                                get = function() return MyAddon.db.profile.overrideHunterCallPet end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideHunterCallPet = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideHunterCallPet end,
                                hidden = function() return MyAddon.db.profile.ignoreHunterPets end,
                            }
                        }
                    },
                    mage = {
                        name = "Mage",
                        type = "group",
                        args = {
                            ignorePet = {
                                name = "Ignore Pet",
                                desc = "Ignore Frost Elemental Pet",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreMagePets
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreMagePets = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak = {
                                type = "description",
                                name = " ",
                                order = 2,
                            },
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 3,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("MAGE")
                            },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 4,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "MAGE")
                            },
                            ignoreRange = {
                                name = "Display notification anyway when allies out of range",
                                order = 5,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreRange", "MAGE")
                            }
                        }
                    },
                    paladin = {
                        name = "Paladin",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("PALADIN")
                            },
                            linebreak = {
                                type = "description",
                                name = " ",
                                order = 2,
                            },
                            ignoreAuras = {
                                name = "Ignore Auras",
                                order = 3,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignorePaladinAuras
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignorePaladinAuras = value
                                    MCB.CheckForMissings()
                                end
                            },
                            checkForCrusaderIC = {
                                name = "Notify if Crusader Aura is active in combat",
                                order = 3.5,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.checkForCrusaderInCombat
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.checkForCrusaderInCombat = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak2 = {
                                type = "description",
                                name = " ",
                                order = 10,
                            },
                            auraHeader = {
                                type = "description",
                                name = function() return MCB.GetDefaultStanceText(MCB.PALADIN_AURAS) end,
                                order = 11,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignorePaladinAuras end,
                            },
                            overrideAura = {
                                name = "Override Default Aura (If Learned)",
                                desc = "Choose a specific aura to display as the aura notification instead of the default aura. Will only override correctly if the spell is learned.",
                                order = 12,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideDefaultPaladinAura end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultPaladinAura = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignorePaladinAuras end,
                            },
                            auraSelect = {
                                name = "Select Preferred Aura",
                                type = "select",
                                order = 13,
                                width = "double",
                                values = function() return MCB.GetSelectionOptionsFromStance(MCB.PALADIN_AURAS) end,
                                get = function() return MyAddon.db.profile.overrideDefaultPaladinAura end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultPaladinAura = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideDefaultPaladinAura end,
                                hidden = function() return MyAddon.db.profile.ignorePaladinAuras end,
                            },
                             linebreak3 = {
                                type = "description",
                                name = " ",
                                order = 20,
                            },
                            affectedGlowSpellsd = {
                                type = "description",
                                order = 21,
                                fontSize = "large",
                                name = "For " .. MCB.createSpellNameWithIcon(53563) .. " and  " .. MCB.createSpellNameWithIcon(156910) .. ":"
                            },
                            useBuffGlows = {
                                name = "Use Blizzard Buff Glows to display missing buffs",
                                desc = "when in combat or secret zones (Mythic+)",
                                descStyle = "inline",
                                order = 22,
                                type = "toggle",
                                width = "full",
                                get = function (_)
                                    return MyAddon.db.profile.useBuffGlows["PALADIN"] == true
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.useBuffGlows["PALADIN"] = value
                                    MCB.CheckForMissings()
                                end
                            },
                            glowDescription = {
                                type = "description",
                                order = 23,
                                name = "When the addon is unable to check player buffs due to combat lockdown or API secret zone restrictions, it can fallback on using Blizzard's buff glow system which glows buffs that are missing. However, Blizzard does not do reasonable checking such as range checking or party size checking, so glows can get annoying in combat due to those issues. Turn off in combat glow checking to deal with those issues."
                            },
                            showInCombatGlows = {
                                name = "Use Blizzard Buff Glows in combat in these zones only",
                                order = 24,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("showInCombatGlows", "PALADIN")
                            },
                        }
                    },
                    priest = {
                        name = "Priest",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("PRIEST")
                            },
                            ignoreFormOOC = {
                                name = "Only check Shadow Form in combat",
                                order = 2,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreShadowFormOOC
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreShadowFormOOC = value
                                    MCB.CheckForMissings()
                                end
                            },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 5,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "PRIEST")
                            },
                            ignoreRange = {
                                name = "Display notification anyway when allies out of range",
                                order = 6,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreRange", "PRIEST")
                            }
                        }
                    },
                    rogue = {
                        name = "Rogue",
                        type = "group",
                        args = {
                            ignoreLethal = {
                                name = "Ignore Lethal Poisons",
                                order = 1,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreLethalPoisons
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreLethalPoisons = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak = {
                                type = "description",
                                name = " ",
                                order = 2,
                            },
                            ignoreNonLethal = {
                                name = "Ignore Non-Lethal Poisons",
                                order = 3,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreNonLethalPoisons
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreNonLethalPoisons = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebrea2 = {
                                type = "description",
                                name = " ",
                                order = 4,
                            },
                            linebrea3 = {
                                type = "description",
                                name = " ",
                                order = 5,
                            },
                            lethalHeader = {
                                type = "description",
                                name = function() return MCB.GetDefaultPoisonText("lethal") end,
                                order = 9,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignoreLethalPoisons end,
                            },
                            overrideLethal = {
                                name = "Override Default Lethal Poison (If Learned)",
                                desc = "Choose a specific poison to display as the lethal notification instead of the default lethal poison. Will only override correctly if the spell is learned.",
                                order = 10,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideDefaultLethalPoison end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultLethalPoison = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignoreLethalPoisons end,
                            },
                            lethalPoisonSelect = {
                                name = "Select Preferred Lethal Poison",
                                type = "select",
                                order = 11,
                                width = "double",
                                values = function() return MCB.GetPoisonOptionsByType("lethal") end,
                                get = function() return MyAddon.db.profile.overrideDefaultLethalPoison end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultLethalPoison = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideDefaultLethalPoison end,
                                hidden = function() return MyAddon.db.profile.ignoreLethalPoisons end,
                            },
                            linebreak5 = {
                                type = "description",
                                name = " ",
                                order = 11.5,
                            },
                            nonLethalHeader = {
                                type = "description",
                                name = function() return MCB.GetDefaultPoisonText("nonlethal") end,
                                order = 12,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignoreNonLethalPoisons end,
                            },
                            overrideNonLethal = {
                                name = "Override Default Non-Lethal Poison (If Learned)",
                                desc = "Choose a specific poison to display as the non-lethal notification instead of the default non-lethal poison. Will only override correctly if the spell is learned.",
                                order = 15,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideDefaultNonLethalPoison end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultNonLethalPoison = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignoreNonLethalPoisons end,
                            },
                            overrideNonLethalWithTalent = {
                                type = "toggle",
                                order = 15.5,
                                width = "full",
                                name = "Use class talent choice node to choose override",
                                desc = "Override Crippling with either Numbing or Atrophic poison depending on the choice node selected in the talent tree",
                                descStyle = "inline",
                                get = function() return MyAddon.db.profile.overrideNonLethalWithTalent end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideNonLethalWithTalent = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideDefaultNonLethalPoison end,
                                hidden = function() return MyAddon.db.profile.ignoreNonLethalPoisons end,
                            },
                            nonLethalPoisonSelect = {
                                name = "Select Preferred Non-Lethal Poison",
                                type = "select",
                                order = 16,
                                width = "double",
                                values = function() return MCB.GetPoisonOptionsByType("nonlethal") end,
                                get = function() return MyAddon.db.profile.overrideDefaultNonLethalPoison end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideDefaultNonLethalPoison = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideDefaultNonLethalPoison end,
                                hidden = function() return MyAddon.db.profile.ignoreNonLethalPoisons or MyAddon.db.profile.overrideNonLethalWithTalent  end,
                            },
                            linebreak6 = {
                                type = "description",
                                name = " ",
                                order = 20
                            },
                            suggestion = {
                                type = "description", 
                                name = "SUGGESTED SETTINGS: Override both poisons. Set Lethal Override to 'Amplifying Poison'. Set Non-Lethal to 'Use class talent choice node to choose override'. This should provide the correct poison setup for all specs in PvE at max level."
                            }
                        }
                    },
                    shaman = {
                        name = "Shaman",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("SHAMAN")
                            },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 2,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "SHAMAN")
                            },
                            ignoreRange = {
                                name = "Display notification anyway when allies out of range",
                                order = 3,
                                inline = true,
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreRange", "SHAMAN")
                            }
                        }
                    },
                    warlock = {
                        name = "Warlock",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = .5,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("WARLOCK")
                            },
                            ignorePet = {
                                name = "Ignore Pet",
                                order = 1,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreWarlockPets
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreWarlockPets = value
                                    MCB.CheckForMissings()
                                end
                            },
                            linebreak2 = {
                                type = "description",
                                name = " ",
                                order = 5,
                            },
                            callPetHeader = {
                                type = "description",
                                name = function() return MCB.GetTextForBuff(MCB.WARLOCK_PET) end,
                                order = 11,
                                fontSize = "medium",
                                hidden = function() return MyAddon.db.profile.ignoreWarlockPets end,
                            },
                            overrideSummonPets = {
                                name = "Override Default Summon Pet (If Learned)",
                                desc = "Choose a specific pet to display as the missing pet notification instead of the default pet. Will only override correctly if the spell is learned.",
                                order = 12,
                                type = "toggle",
                                width = "full",
                                get = function() return MyAddon.db.profile.overrideWarlockSummonPet end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideWarlockSummonPet = value
                                    MCB.CheckForMissings()
                                end,
                                hidden = function() return MyAddon.db.profile.ignoreWarlockPets end,
                            },
                            petSelect = {
                                name = "Select Preferred Pet",
                                type = "select",
                                order = 13,
                                width = "double",
                                values = function() return MCB.GetSelectionOptionsFromPetTable(MCB.WARLOCK_ALL_PETS) end,
                                get = function() return MyAddon.db.profile.overrideWarlockSummonPet end,
                                set = function(_, value)
                                    MyAddon.db.profile.overrideWarlockSummonPet = value
                                    MCB.CheckForMissings()
                                end,
                                disabled = function() return not MyAddon.db.profile.overrideWarlockSummonPet end,
                                hidden = function() return MyAddon.db.profile.ignoreWarlockPets end,
                            }
                        }
                    },
                    warrior = {
                        name = "Warrior",
                        type = "group",
                        args = {
                            ignoreBuffs ={
                                name = "Ignore Buffs",
                                inline = true,
                                order = 1,
                                type = "group",
                                args = MCB.createIgnoreBuffsCheckboxes("WARRIOR")
                            },
                            ignoreStances = {
                                name = "Ignore Stances",
                                order = 2,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreWarriorStances
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreWarriorStances = value
                                    MCB.CheckForMissings()
                                end
                            },
                            checkForWrongStance = {
                                name = "Notify if wrong stance is being used for current specialization",
                                order = 2.5,
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.checkForWrongWarriorStance
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.checkForWrongWarriorStance = value
                                    MCB.CheckForMissings()
                                end
                            },
                            ignoreAllies = {
                                name = "Ignore Allies",
                                inline = true,
                                order = 3,
                                desc = "Will not notify you if other members of your party or raid are missing your class buffs",
                                type = "group",
                                args = MCB.createZoneSettingsCheckboxes("ignoreAllies", "WARRIOR")
                            },
                            explanation = {
                                type = "description",
                                name = "Due to API limitations, this addon is unable to do range checks correctly on a Warrior. No range check will be done when checking allies for missing buffs. Please select Ignore Allies for the appropriate zones to avoid annoyances with the notification.",
                                order = 4,
                            }
                        }
                    }
                }
            },
            consumables = {
                name = "Consumables",
                inline = false,
                order = 3,
                type = "group",
                args = {
                    flaskgroup = {
                        name = "Flasks",
                        inline = true,
                        order = 1,
                        type = "group",
                        args = {
                            trackFlask = {
                                name = "Check for Flask",
                                order = 15,
                                desc = "Check if the player has a flask on",
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.trackFlask
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.trackFlask = value
                                    MCB.CheckForMissings()
                                end
                            },
                            trackFlaskZones = {
                                name = "Zones to Track Flask",
                                inline = true,
                                order = 16,
                                type = "group",
                                args = MCB.createIgnoreGlobalCheckboxes("trackFlask")
                            },
                            dungeonDifficulties = { type = "group",
                                name = "Dungeon Difficulties to Track In",
                                inline = true,
                                order = 20,
                                args = MCB.GetDifficultyToggles("party", "showFlask")
                            },
                            raidDifficulties = { type = "group",
                                name = "Raid Difficulties to Track In",
                                inline = true,
                                order = 25,
                                args = MCB.GetDifficultyToggles("raid", "showFlask")
                            },
                            legacyContent = {
                                type = "toggle",
                                order = 30,
                                name = "Ignore Legacy Dungeons and Raids (old expansions)",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreLegacyContentForFlask
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreLegacyContentForFlask = value
                                    MCB.CheckForMissings()
                                end
                            },
                            mythicplusDisclaimer = {
                                type = "description",
                                order = 45,
                                name = "*Tracking of buffs will not work in Mythic+ at the moment due to heavy API restrictions in Mythic+. If Blizzard lifts these restrictions, tracking should work immediately.",
                            }
                        }
                    },
                    linebreak3 = {
                        type = "description",
                        name = " ",
                        order = 5,
                    },
                    foodgroup = {
                        name = "Food",
                        inline = true,
                        order = 10,
                        type = "group",
                        args = {
                            trackFood = {
                                name = "Check for Food",
                                order = 26,
                                desc = "Check if the player has the Well Fed buff. Ignores Earthen",
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.trackFood
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.trackFood = value
                                    MCB.CheckForMissings()
                                end
                            },
                            trackFoodZones = {
                                name = "Zones to Track Food",
                                inline = true,
                                order = 27,
                                type = "group",
                                args = MCB.createIgnoreGlobalCheckboxes("trackFood")
                            },
                            dungeonDifficulties = { type = "group",
                                name = "Dungeon Difficulties to Track In",
                                inline = true,
                                order = 30,
                                args = MCB.GetDifficultyToggles("party", "showFood")
                            },
                            raidDifficulties = { type = "group",
                                name = "Raid Difficulties to Track In",
                                inline = true,
                                order = 35,
                                args = MCB.GetDifficultyToggles("raid", "showFood")
                            },
                            legacyContent = {
                                type = "toggle",
                                order = 40,
                                name = "Ignore Legacy Dungeons and Raids (old expansions)",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreLegacyContentForFood
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreLegacyContentForFood = value
                                    MCB.CheckForMissings()
                                end
                            },
                            mythicplusDisclaimer = {
                                type = "description",
                                order = 45,
                                name = "*Tracking of buffs will not work in Mythic+ at the moment due to heavy API restrictions in Mythic+. If Blizzard lifts these restrictions, tracking should work immediately.",
                            }
                        }
                    },
                    linebreak = {
                        type = "description",
                        name = " ",
                        order = 15,
                    },
                    oilgroup = {
                        name = "Oil, Whetstones and Waxes (Weapon Buffs)",
                        inline = true,
                        order = 20,
                        type = "group",
                        args = {
                            trackoil = {
                                name = "Check for Weapon Buffs",
                                order = 26,
                                desc = "Check if the player has weapon buffs in main hand and off hand (if applicable)",
                                type = "toggle",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.trackOil
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.trackOil = value
                                    MCB.CheckForMissings()
                                end
                            },
                            trackOilZones = {
                                name = "Zones to Track Weapon Buffs",
                                inline = true,
                                order = 27,
                                type = "group",
                                args = MCB.createIgnoreGlobalCheckboxes("trackOil")
                            },
                            dungeonDifficulties = { type = "group",
                                name = "Dungeon Difficulties to Track In",
                                inline = true,
                                order = 30,
                                args = MCB.GetDifficultyToggles("party", "showOil")
                            },
                            raidDifficulties = { type = "group",
                                name = "Raid Difficulties to Track In",
                                inline = true,
                                order = 35,
                                args = MCB.GetDifficultyToggles("raid", "showOil")
                            },
                            legacyContent = {
                                type = "toggle",
                                order = 40,
                                name = "Ignore Legacy Dungeons and Raids (old expansions)",
                                width = "full",
                                get = function(_)
                                    return MyAddon.db.profile.ignoreLegacyContentForOil
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.ignoreLegacyContentForOil = value
                                    MCB.CheckForMissings()
                                end
                            },
                            mythicplusDisclaimer = {
                                type = "description",
                                order = 45,
                                name = "*Tracking of weapon buffs DOES WORK in mythic+ because it does not use the buff system for tracking.",
                            }
                        }
                    },
                    linebreak5 = {
                        type = "description",
                        name = " ",
                        order = 25,
                    },
                    notifyDuration = {
                        name = "Notify when consumable duration is low",
                        inline = true,
                        order = 30,
                        type = "group",
                        args = {
                            enable = {
                                name = "Enable",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.notifyForConsumables
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.notifyForConsumables = value
                                    MCB.CheckForMissings()
                                end
                            },
                            duration = {
                                name = "Duration Remaining",
                                type = "range",
                                desc = "Select minutes",
                                min = 1,
                                max = 45,
                                step = 1,
                                get = function(_)
                                    return MyAddon.db.profile.durationForConsumables
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.durationForConsumables = value
                                    MCB.CheckForMissings()
                                end
                            }
                        }
                    },
                    linebreak6 = {
                        type = "description",
                        name = " ",
                        order = 32,
                    },
                    advanced = {
                        name = "Advanced - Click to Cast Options",
                        inline = true,
                        order = 35,
                        type = "group",
                        args = {
                            generalDesc = {
                                type="description",
                                name = "Input one item id per notification type to be used as the click to cast for when Flasks, Food or Weapon Buffs are missing. Addon author is not liable for consumable waste due to spam clicking icons. Use with caution.",
                                order = 1
                            },
                            flaskGroup = {
                                name = "Flasks",
                                inline = true,
                                order = 2, 
                                type = "group",
                                args = {
                                     flaskDesc = {
                                        type = "description",
                                        name = function() return MCB.GetConsumableClickToCastDisplay(MyAddon.db.profile.flaskClickToCastId) end,
                                        order = 3,
                                        fontSize = "medium",
                                        width = 1.8
                                    },
                                    removeFlask = {
                                        type = "execute",
                                        name = "",
                                        order = 3.5,
                                        width = 0.2,
                                        image = [[Interface\Buttons\UI-GroupLoot-Pass-Up]],
                                        imageWidth = 20,
                                        imageHeight = 20,
                                        confirm = true,
                                        confirmText = "Delete this flask item ID?",
                                        func = function()
                                            MyAddon.db.profile.flaskClickToCastId = nil
                                            MCB.flaskClickToCastError = "" 
                                            MCB.CheckForMissings()
                                        end,
                                        hidden = function() return not MyAddon.db.profile.flaskClickToCastId end,
                                    },
                                    flaskInput = {
                                        type = "input",
                                        name = "Set Flask Item ID",
                                        order = 4,
                                        width = "full",
                                        get = function() return "" end,
                                        set = function(_, value)
                                            local clickToCastId = nil
                                            clickToCastId, MCB.flaskClickToCastError = MCB.handleSettingConsumableClickToCast(value)
                                            if clickToCastId then
                                                MyAddon.db.profile.flaskClickToCastId = clickToCastId
                                                MCB.CheckForMissings()
                                            end
                                        end,
                                    },
                                    flaskErrorMessage = {
                                        type = "description",
                                        name = function() return MCB.flaskClickToCastError end,
                                        hidden = function() return (MCB.flaskClickToCastError or "") == "" end,
                                        order = 5
                                    },
                                }
                            },
                            foodGroup = {
                                name = "Food",
                                inline = true,
                                order = 5,
                                type = "group",
                                args = {
                                    foodDesc = {
                                        type = "description",
                                        name = function() return MCB.GetConsumableClickToCastDisplay(MyAddon.db.profile.foodClickToCastId) end,
                                        order = 10,
                                        fontSize = "medium",
                                        width = 1.8
                                    },
                                    removeFood = {
                                        type = "execute",
                                        name = "",
                                        order = 10.5,
                                        width = 0.2,
                                        image = [[Interface\Buttons\UI-GroupLoot-Pass-Up]],
                                        imageWidth = 20,
                                        imageHeight = 20,
                                        confirm = true,
                                        confirmText = "Delete this food item ID?",
                                        func = function()
                                            MyAddon.db.profile.foodClickToCastId = nil
                                            MCB.foodClickToCastError = ""
                                            MCB.CheckForMissings()
                                        end,
                                        hidden = function() return not MyAddon.db.profile.foodClickToCastId end,
                                    },
                                    foodInput = {
                                        type = "input",
                                        name = "Set Food Item ID",
                                        order = 11,
                                        width = "full",
                                        get = function() return "" end,
                                        set = function(_, value)
                                            local clickToCastId = nil
                                            clickToCastId, MCB.foodClickToCastError = MCB.handleSettingConsumableClickToCast(value)
                                            if clickToCastId then
                                                MyAddon.db.profile.foodClickToCastId = clickToCastId
                                                 MCB.CheckForMissings()
                                            end
                                        end,
                                    },
                                    foodErrorMessage = {
                                        type = "description",
                                        name = function() return MCB.foodClickToCastError end,
                                        hidden = function() return (MCB.foodClickToCastError or "") == "" end,
                                        order = 12
                                    },
                                }
                            },
                            oilGroup = {
                                name = "Weapon Buffs",
                                inline = true,
                                order = 10,
                                type = "group",
                                args = {
                                    oilDesc = {
                                        type = "description",
                                        name = function() return MCB.GetConsumableClickToCastDisplay(MyAddon.db.profile.oilClickToCastId) end,
                                        order = 20,
                                        fontSize = "medium",
                                        width = 1.8
                                    },
                                    removeFood = {
                                        type = "execute",
                                        name = "",
                                        order = 20.5,
                                        width = 0.2,
                                        image = [[Interface\Buttons\UI-GroupLoot-Pass-Up]],
                                        imageWidth = 20,
                                        imageHeight = 20,
                                        confirm = true,
                                        confirmText = "Delete this weapon buff item ID?",
                                        func = function()
                                            MyAddon.db.profile.oilClickToCastId = nil
                                            MCB.oilClickToCastError = ""
                                            MCB.CheckForMissings()
                                        end,
                                        hidden = function() return not MyAddon.db.profile.oilClickToCastId end,
                                    },
                                    oilInput = {
                                        type = "input",
                                        name = "Set Weapon Buff Item ID",
                                        order = 21,
                                        width = "full",
                                        get = function() return "" end,
                                        set = function(_, value)
                                            local clickToCastId = nil
                                            clickToCastId, MCB.oilClickToCastError = MCB.handleSettingConsumableClickToCast(value)
                                            if clickToCastId then
                                                MyAddon.db.profile.oilClickToCastId = clickToCastId
                                                 MCB.CheckForMissings()
                                            end
                                        end,
                                    },
                                    oilErrorMessage = {
                                        type = "description",
                                        name = function() return MCB.oilClickToCastError end,
                                        hidden = function() return (MCB.oilClickToCastError or "") == "" end,
                                        order = 22
                                    },
                                }
                            },
                           
                            
                            
                        }
                    }
                },
            },
            customSpellIds = {
                name = "Custom Buffs",
                inline = false,
                order = 4,
                type = "group",
                args = {
                    enableSpellIds = {
                        name = "Enable Custom Spell IDs",
                        order = 1,
                        desc = "Turn on the check for the custom spell ids in the list",
                        type = "toggle",
                        width = "full",
                        get = function(_)
                            return MyAddon.db.profile.showCustomSpellIds
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.showCustomSpellIds = value
                            MCB.CheckForMissings()
                        end
                    },
                    description = {
                        type="description",
                        order = 2,
                        name = "Add buff spell IDs to this list to have them tracked if they are missing. Will always be checked last."
                    },
                    removeSpellIds = {
                        type = "group",
                        name = "Currently Tracked Buffs",
                        inline = true,
                        order = 3,
                        args = {}, -- handled dynamically by MCB.UpdateCustomSpellOptions
                    },
                    description2 = {
                        type="description",
                        order = 4,
                        name = "To add a buff to track with no click to cast, simply submit a buff spell ID. EX: '1234' \n\nIf you would like the buff to have a click to cast, add it after a comma. " ..
                        "EX: '1234,5678' 1234 will be the buff spell ID, 5678 will be the the click to cast spell ID. \n\nIf your click to cast is an item or a toy, you MUST pass in a third parameter that " ..
                        "specifies you are passing in an item or toy with an item ID instead of spell ID. The valid types are 'spell', 'item' and 'toy'. EX: '1234,5678,toy' 1234 will be the buff spell ID, 5678 will be the item id, toy will be what we are trying to cast"
                    },
                    addSpellId = {
                        type = "input",
                        name = "Add Buff Spell ID (and optional Click to Cast Spell ID and Click to Cast Type)",
                        desc = "Enter a Spell IDs to track manually. Spell IDs must be separated by a comma with Buff Spell ID first followed by Click to Cast ID.",
                        width = "full",
                        order = 5,
                        get = function() return "" end,
                        set = function(info, value)
                            local success = MCB.handleCustomBuffInput(value)
                            if not success then
                                return
                            end
                        end,
                    },
                    errorMessage = {
                        type = "description",
                        name = function() return MCB.customSpellIdsError end,
                        hidden = function() return (MCB.customSpellIdsError or "") == "" end,
                        order = 6
                    },
                    linebreak2 = {
                        type = "description",
                        name = "",
                        order = 7,
                    },
                    hideOnCd = {
                        type = "toggle",
                        width = "full",
                        order = 8,
                        name = "Hide notification if item or toy for click-to-cast is on cooldown",
                        get = function(_)
                            return MyAddon.db.profile.hideCustomIfItemOnCD
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.hideCustomIfItemOnCD = value
                            MCB.CheckForMissings()
                        end
                    },
                    hideNotInInventory = {
                        type = "toggle",
                        width = "full",
                        order = 9,
                        name = "Hide notification if item for click-to-cast is not in the character's inventory",
                        get = function(_)
                            return MyAddon.db.profile.hideCustomIfItemNotInInventory
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.hideCustomIfItemNotInInventory = value
                            MCB.CheckForMissings()
                        end
                    },
                    customZones = {
                        name = "Zones to Track Custom Spell IDs",
                        inline = true,
                        order = 10,
                        type = "group",
                        args = MCB.createIgnoreGlobalCheckboxes("showCustomSpellIds")
                    },
                    dungeonDifficulties = { type = "group",
                        name = "Dungeon Difficulties to Track In",
                        inline = true,
                        order = 20,
                        args = MCB.GetDifficultyToggles("party", "showCustom")
                    },
                    raidDifficulties = { type = "group",
                        name = "Raid Difficulties to Track In",
                        inline = true,
                        order = 25,
                        args = MCB.GetDifficultyToggles("raid", "showCustom")
                    },
                    legacyContent = {
                        type = "toggle",
                        order = 30,
                        name = "Ignore Legacy Dungeons and Raids (old expansions)",
                        width = "full",
                        get = function(_)
                            return MyAddon.db.profile.ignoreLegacyContentForCustom
                        end,
                        set = function(_, value)
                            MyAddon.db.profile.ignoreLegacyContentForCustom = value
                            MCB.CheckForMissings()
                        end
                    },
                    mythicplusDisclaimer = {
                        type = "description",
                        order = 31,
                        name = "*Tracking of buffs will not work in Mythic+ at the moment due to heavy API restrictions in Mythic+. If Blizzard lifts these restrictions, tracking should work immediately.",
                    },
                    linebreak = {
                        type = "description",
                        name = "",
                        order = 35,
                    },
                    notifyDuration = {
                        name = "Notify when custom buff duration is low",
                        inline = true,
                        order = 50,
                        type = "group",
                        args = {
                            enable = {
                                name = "Enable",
                                order = 1,
                                type = "toggle",
                                get = function(_)
                                    return MyAddon.db.profile.notifyForCustom
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.notifyForCustom = value
                                    MCB.CheckForMissings()
                                end
                            },
                            duration = {
                                name = "Duration Remaining",
                                type = "range",
                                desc = "Select minutes",
                                min = 1,
                                max = 45,
                                step = 1,
                                get = function(_)
                                    return MyAddon.db.profile.durationForCustom
                                end,
                                set = function(_, value)
                                    MyAddon.db.profile.durationForCustom = value
                                    MCB.CheckForMissings()
                                end
                            }
                        }
                    },
                }
            },
            profile = AceDBOptions:GetOptionsTable(MyAddon.db)
        }
    }

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    LibStub("AceConfigDialog-3.0"):SetDefaultSize("MissingClassBuff", 700, 700)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MissingClassBuff", MCB.settings)
    AceConfigDialog:AddToBlizOptions("MissingClassBuff", "Missing Class Buff")
    MyAddon:RegisterChatCommand("mcb", function(_)
        AceConfigDialog:Open("MissingClassBuff")
    end)

    -- Add multi-spec support to profiles
    local LibDualSpec = LibStub('LibDualSpec-1.0')
    LibDualSpec:EnhanceDatabase(MyAddon.db, "myAddon")
    LibDualSpec:EnhanceOptions(MCB.settings.args.profile, MyAddon.db)

    MCB:UpdateCustomSpellOptions()
end

function MCB.GetSettingsValue(settingName)
    return MyAddon.db.profile[settingName]
end

function MCB.SetSettingsValue(settingName, value)
    MyAddon.db.profile[settingName] = value
    MCB.CheckForMissings()
end

function MCB.addUniqueToArray(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return false
        end
    end

    table.insert(array, value)
    return true 
end

function MCB.contains(array, value)
    array = array or {}
    for i = 1, #array do
        if array[i] == value then
            return true
        end
    end
    return false
end

function MCB.removeValueFromArray(array, value)
    for i, v in ipairs(array) do
        if v == value then
            table.remove(array, i)
            return true
        end
    end
    return false
end

function MyAddon:OnProfileChanged(event, dbName)
    MCB.CheckForMissings()
end

function MCB.createIgnoreBuffsCheckboxes(classArrayName)
    local args = {}
    local buffList = MCB.CLASS_BUFFS[classArrayName]


    if not buffList then return args end
    for _, buff in ipairs(buffList) do
        local displayName = MCB.createSpellNameWithIcon(buff.spellId)
        local description = ""
        if buff.additionalSettingsText then
            description = tostring(buff.additionalSettingsText)
        end
        local arg = {
            type = "toggle",
            name = displayName,
            desc = description,
            get = function(_)
                return MCB.checkIfSettingsTableContains("ignoredSettingsIds", buff.settingsId)
            end,
            set = function(_, value)
                if value then
                    MCB.addToSettingsTable("ignoredSettingsIds", buff.settingsId)
                else
                    MCB.removeFromSettingsTable("ignoredSettingsIds", buff.settingsId)
                end
            end
        }
        local toggleName = "s" .. buff.settingsId
        args[toggleName] = arg
    end
    return args
end

function MCB.createSpellNameWithIcon(spellId)
    local spellName = C_Spell.GetSpellName(spellId)
    local spellTexture = C_Spell.GetSpellTexture(spellId)
    return string.format("|T%s:0|t %s", spellTexture, spellName)
end

function MCB.createZoneSettingsCheckboxes(zoneSetting, classArrayName)
    local args = {}
    for zoneName, _ in pairs(MCB.ZONE_NAME_MAPPING) do
        local arg = MCB.createZoneSettingsCheckbox(zoneSetting, classArrayName, zoneName)
        args[zoneName] = arg
    end
    return args
end

function MCB.createZoneSettingsCheckbox(zoneSetting, classArrayName, zoneName)
    local zoneNameDisplay = MCB.ZONE_NAME_MAPPING[zoneName].name
    local zoneNameOrder = MCB.ZONE_NAME_MAPPING[zoneName].order
    local args = {
        type = "toggle",
        name = zoneNameDisplay,
        order = zoneNameOrder,
        get = function(_)
            if MyAddon.db.profile.zoneSettings[zoneName][zoneSetting] then
                return MyAddon.db.profile.zoneSettings[zoneName][zoneSetting][classArrayName]
            end
            return false
        end,
        set = function(_, value)
            if not MyAddon.db.profile.zoneSettings[zoneName][zoneSetting] then
                MyAddon.db.profile.zoneSettings[zoneName][zoneSetting] = {}
            end

            MyAddon.db.profile.zoneSettings[zoneName][zoneSetting][classArrayName] = value
            MCB.CheckForMissings()
        end
    }
    return args
end

function MCB.createIgnoreGlobalCheckbox(settingName, zoneName)
    local zoneNameDisplay = MCB.ZONE_NAME_MAPPING[zoneName].name
    local zoneNameOrder = MCB.ZONE_NAME_MAPPING[zoneName].order
    local args = {
        type = "toggle",
        name = zoneNameDisplay,
        order = zoneNameOrder,
        get = function(_)
            return MyAddon.db.profile.zoneSettings[zoneName][settingName]
        end,
        set = function(_, value)
            MyAddon.db.profile.zoneSettings[zoneName][settingName] = value
            MCB.CheckForMissings()
        end
    }
    return args
end

function MCB.createIgnoreGlobalCheckboxes(settingName)
    local args = {}
    for zoneName, _ in pairs(MCB.ZONE_NAME_MAPPING) do
        local arg = MCB.createIgnoreGlobalCheckbox(settingName, zoneName)
        args[zoneName] = arg
    end
    return args
end

function MCB.handleCustomBuffInput(value)
    if not value then
        MCB.customSpellIdsError = "|cFFFF0000Please enter a numeric ID.|r"
        return false
    end
    local buffValue, clickToCastValue, spellType = value:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%a*)%s*$")
    if buffValue and clickToCastValue then
        local spellTypeInputLower = spellType:lower()
        if spellTypeInputLower == MCB.CLICK_TO_CAST_SPELL_TYPES.SPELL then
            spellType = MCB.CLICK_TO_CAST_SPELL_TYPES.SPELL
        elseif spellTypeInputLower == MCB.CLICK_TO_CAST_SPELL_TYPES.TOY then
            spellType = MCB.CLICK_TO_CAST_SPELL_TYPES.TOY
        elseif spellTypeInputLower == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM then
            spellType = MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM
        else
            MCB.customSpellIdsError = "|cFFFF0000Please enter a valid spell type as the third parameter. Valid spell types are 'spell', 'item' or 'toy'.|r"
            return false
        end
    end
    if not spellType then
        buffValue, clickToCastValue = value:match("^%s*(%d+)[%s,]+(%d+)%s*$")
        if not clickToCastValue then
            buffValue = value:match("^%s*(%d+)%s*$")
        end
    end
    local buffId = tonumber(buffValue)
    local clickToCastId = nil
    if not buffId then
        MCB.customSpellIdsError = "|cFFFF0000Please enter a numeric ID.|r"
        return false
    end
    if clickToCastValue then
        clickToCastId = tonumber(clickToCastValue)
        if not clickToCastId then
            MCB.customSpellIdsError = "|cFFFF0000Your second value after the comma was not a numeric ID.|r"
        return false
        end
    end

    if not C_Spell.GetSpellInfo(buffId) then 
        MCB.customSpellIdsError = "|cFFFF0000Invalid Buff Spell ID - Spell not found. ID = " .. tostring(buffId) .. "|r"
        return false
    end
    
    if clickToCastId then
        local doItemCheck = spellType and (spellType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM or spellType == MCB.CLICK_TO_CAST_SPELL_TYPES.TOY)
        if doItemCheck then
            if not C_Item.DoesItemExistByID(clickToCastId) then
                MCB.customSpellIdsError = "|cFFFF0000Invalid Click to Cast Item ID (2nd number) - Item/Toy not found. ID = " .. tostring(clickToCastId) .. "|r"
                return false
            end
        else
            if not C_Spell.DoesSpellExist(clickToCastId) then
                MCB.customSpellIdsError = "|cFFFF0000Invalid Click to Cast Spell ID (2nd number) - Spell not found. ID = " .. tostring(clickToCastId) .. "|r"
                return false
            end
        end
    end

    -- no duplicates
    for _, spellEntry in ipairs(MyAddon.db.profile.customSpellIds) do
        if spellEntry.spellId == buffId then
            MCB.customSpellIdsError = "|cFFFF0000This buff spell is already being tracked. ID = " .. tostring(buffId) .. "|r"
            return false
        end
    end

    table.insert(MyAddon.db.profile.customSpellIds, {spellId = buffId, clickableId = clickToCastId, clickableType = spellType})
    if spellType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM then
        C_Item.RequestLoadItemDataByID(clickToCastId)
    end
    MCB.customSpellIdsError = ""
    MCB.UpdateCustomSpellOptions()
    MCB.CheckForMissings()
    return true
end


function MCB.UpdateCustomSpellOptions()
    local args = MCB.settings.args.customSpellIds.args.removeSpellIds.args

    wipe(args)
    local spellTable = MyAddon.db.profile.customSpellIds
    local totalSpells = #spellTable
    for i, spellEntry in ipairs(MyAddon.db.profile.customSpellIds) do
        local spellId = spellEntry.spellId
        local spellClickableId = spellEntry.clickableId
        local spellType = spellEntry.clickableType
        local spellInfo = C_Spell.GetSpellInfo(spellId);
        
        if spellInfo then
            local ids = ""
            if spellClickableId then
                if spellType then
                    ids = spellInfo.name .. "\n(Buff ID: " .. spellId .. ", Click to Cast ID: " .. spellClickableId .. ", Cast Type: " .. spellType .. ")"
                else
                    ids = spellInfo.name .. "\n(Buff ID: " .. spellId .. ", Click to Cast ID: " .. spellClickableId .. ")"
                end
            else
                ids = spellInfo.name .. "\n(Buff ID: " .. spellId .. ")"
            end

            args["desc" .. i] = {
                type = "description",
                name = ids,
                image = spellInfo.iconID,
                fontSize = "medium",
                width = 2.2, -- Use most of the width
                order = (i * 10) + 1,
            }

            args["up" .. i] = {
                type = "execute",
                name = "",
                image = [[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]],
                imageWidth = 40,
                imageHeight = 40,
                order = (i * 10) + 2,
                width = 0.2,
                disabled = (i == 1), -- Can't move the first item up
                func = function()
                    local item = table.remove(spellTable, i)
                    table.insert(spellTable, i - 1, item)
                    MCB.UpdateCustomSpellOptions()
                    MCB.CheckForMissings()
                end,
            }

            args["down" .. i] = {
                type = "execute",
                name = "", 
                image = [[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]],
                imageWidth = 40,
                imageHeight = 40,
                order = (i * 10) + 3,
                width = 0.2,
                disabled = (i == totalSpells), -- Can't move the last item down
                func = function()
                    local item = table.remove(spellTable, i)
                    table.insert(spellTable, i + 1, item)
                    MCB.UpdateCustomSpellOptions()
                    MCB.CheckForMissings()
                end,
            }

            args["remove" .. i] = {
                type = "execute",
                name = "",
                image = [[Interface\Buttons\UI-GroupLoot-Pass-Up]],
                imageWidth = 25,
                imageHeight = 25,
                confirm = true,
                confirmText = "Delete this buff?",
                order = (i * 10) + 4,
                width = 0.2,
                func = function()
                    table.remove(spellTable, i)
                    MCB.UpdateCustomSpellOptions()
                    MCB.CheckForMissings()
                end,
            }

            --force next buff onto new line
            args["spacer" .. i] = {
                type = "description",
                name = " ",
                order = (i * 10) + 5,
                width = "full"
            }
        end
    end
end

function MCB.GetConsumableClickToCastDisplay(itemId)
    if not itemId or itemId == 0 then return "" end
    
    local itemApiId, _, _, _, itemIcon = C_Item.GetItemInfoInstant(itemId)
    local itemName = C_Item.GetItemInfo(itemId)
    if not itemName then itemName = "" end

    if itemApiId and itemIcon then
        return string.format("|T%d:20:20:0:0|t %s [ID: %d]", itemIcon, itemName, itemApiId)
    end
    return "|cFFFF0000Invalid ID: " .. itemId .. "|r"
end

function MCB.handleSettingConsumableClickToCast(itemIdValue)
    local itemId = tonumber(itemIdValue)

    if not itemId then
        return nil, "|cFFFF0000Please enter a numeric ID.|r"
    end
    
    local itemName, _, _, _, itemIcon = C_Item.GetItemInfoInstant(itemId)
    if not (itemName and itemIcon) then
        return nil, "|cFFFF0000Please enter a valid item.|r"
    end
    
    return itemId, ""
end

function MCB.GetPoisonOptionsByType(poisonType)
    local options = {}
    local rogueData = MCB.CLASS_BUFFS["ROGUE"]
    
    if not rogueData then return options end

    for _, entry in ipairs(rogueData) do
        if entry.poisonType == poisonType and not entry.default then
            local spellId = entry.spellId
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local name = spellInfo and spellInfo.name
            local icon = C_Spell.GetSpellTexture(spellId)

            if name and icon then
                options[spellId] = string.format("|T%d:0|t %s", icon, name)
            else
                options[spellId] = "Poison Spell ID: " .. spellId
            end
        end
    end
    return options
end

function MCB.GetDefaultPoisonText(poisonType)
    local rogueData = MCB.CLASS_BUFFS["ROGUE"]
    if not rogueData then return "" end

    for _, entry in ipairs(rogueData) do
        if entry.poisonType == poisonType and entry.default then
            local spellId = entry.spellId
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local name = spellInfo and spellInfo.name or "Unknown"
            local icon = C_Spell.GetSpellTexture(spellId)
            local defaultText = ""
            if poisonType == "lethal" then
                defaultText = "Default Lethal Poison"
            elseif poisonType == "nonlethal" then
                defaultText = "Default Non-Lethal Poison"
            end
        
            return string.format(defaultText .. ": |T%d:0|t %s", icon or 0, name)
        end
    end
    return ""
end

function MCB.GetSelectionOptionsFromStance(stanceTable)
    local options = {}
    if not stanceTable then return options end

    for _, entry in ipairs(stanceTable) do
        if not entry.default then
            local spellId = entry.spellId
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local name = spellInfo and spellInfo.name or spellId
            local icon = C_Spell.GetSpellTexture(spellId)

            if icon then
                options[spellId] = string.format("|T%d:0|t %s", icon, name)
            else
                options[spellId] = name
            end
        end
    end
    return options
end

function MCB.GetSelectionOptionsFromPetTable(petTable)
    local options = {}
    if not petTable then return options end

    for _, entry in ipairs(petTable) do
        if not entry.default then
            local spellId = entry.spellId
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local name = spellInfo and spellInfo.name or spellId
            local icon = C_Spell.GetSpellTexture(spellId)

            if icon then
                options[spellId] = string.format("|T%d:0|t %s", icon, name)
            else
                options[spellId] = name
            end
        end
    end
    return options
end

function MCB.GetDefaultStanceText(stanceTable)
    for _, entry in ipairs(stanceTable) do
        if entry.default then
            local spellInfo = C_Spell.GetSpellInfo(entry.spellId)
            local icon = C_Spell.GetSpellTexture(entry.spellId)
            return string.format("Default: |T%d:0|t %s", icon or 0, spellInfo and spellInfo.name or "")
        end
    end
    return ""
end

function MCB.GetTextForBuff(buff)
    local spellInfo = C_Spell.GetSpellInfo(buff.spellId)
    local icon = C_Spell.GetSpellTexture(buff.spellId)
    return string.format("Default: |T%d:0|t %s", icon or 0, spellInfo and spellInfo.name or "")
end

function MCB.GetDifficultyToggles(category, showBuffVariableName)
    local toggles = {}
    
    for difficultyKey, data in pairs(MyAddon.db.profile.difficultySettings[category]) do
        toggles[difficultyKey] = {
            type = "toggle",
            name = MCB.difficultyNames[difficultyKey] or difficultyKey,
            order = data.order,
            get = function(info)
                return MyAddon.db.profile.difficultySettings[category][difficultyKey][showBuffVariableName]
            end,
            set = function(info, value)
                MyAddon.db.profile.difficultySettings[category][difficultyKey][showBuffVariableName] = value
                MCB.CheckForMissings()
            end,
        }
    end
    
    return toggles
end

function MCB.runSettingsMigrationCheck()
    local profileList = MyAddon.db:GetProfiles()
    local dbVersion = tonumber(C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-DB-Version"))

    if not MissingClassBuffDB.lastRunDBVersion or MissingClassBuffDB.lastRunDBVersion < 137 then
        MissingClassBuffDB.lastRunDBVersion = dbVersion
        --may show message here ..
        --we will run the migration
    else
        MissingClassBuffDB.lastRunDBVersion = dbVersion
        --we've run the migration already, don't do anything
        return
    end

    local spellToSettingsMap = {}
    for className, buffs in pairs(MCB.CLASS_BUFFS) do
        for _, buffData in ipairs(buffs) do
            if buffData.spellId and buffData.settingsId then
                spellToSettingsMap[buffData.spellId] = spellToSettingsMap[buffData.spellId] or {}
                table.insert(spellToSettingsMap[buffData.spellId], buffData.settingsId)
            end
        end
    end

    local hadAProfileWithData = false
    for _, profileName in ipairs(profileList) do
        local profile = MyAddon.db.profiles[profileName]
        if profile and next(profile) ~= nil then
            hadAProfileWithData = true
            -- do the actual migration
            MCB.handleZoneSettingsMigration(profile)
            MCB.handleIgnoredSpellIdsToSettingsIdMigration(profile, spellToSettingsMap)

        end
    end
    if hadAProfileWithData then
        MyAddon:Print("Ran a settings migration. Some Evoker and Warrior Ignore Allies settings may be changed/lost. Please check your class specific settings again. My apologies for the inconvenience. If this is your first time loading the addon, ignore this message.")
    end

    --handle versioning
end

function MCB.handleZoneSettingsMigration(profile)
    if profile and profile.zoneSettings then
        for zoneType, settings in pairs(profile.zoneSettings) do
            local function migrateToDictionary(targetTable)
                -- check if it's an old-style array (has a value at index 1) and if that value is a string (is a class name like EVOKER)
                if targetTable and targetTable[1] and type(targetTable[1]) == "string" then
                    local newDict = {}
                    for _, className in ipairs(targetTable) do
                        newDict[className] = true
                    end
                    return newDict
                end
                -- If it's already a dict or empty, return it as is
                return targetTable
            end

            settings.ignoreAllies = migrateToDictionary(settings.ignoreAllies)
            settings.ignoreRange = migrateToDictionary(settings.ignoreRange)
        end
    end
end

function MCB.handleIgnoredSpellIdsToSettingsIdMigration(profile, spellToSettingsMap)
    if profile.ignoredSpellIds and #profile.ignoredSpellIds > 0 then
        profile.ignoredSettingsIds = profile.ignoredSettingsIds or {}

        for _, oldSpellId in ipairs(profile.ignoredSpellIds) do
            local idsToMigrate = spellToSettingsMap[oldSpellId]
            
            if idsToMigrate then
                -- need to make sure to find every settingsId associated with this spell id
                for _, id in ipairs(idsToMigrate) do
                    profile.ignoredSettingsIds[id] = true
                end
            end
        end

        -- clear it out just in case
        profile.ignoredSpellIds = {}
    end
end