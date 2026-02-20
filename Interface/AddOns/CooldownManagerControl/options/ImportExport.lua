local addonName, addonTable = ...
local addon                 = addonTable.Core

local importString, exportString
local dataToExport          = {
    layout = {
        false,
    },
    anchor = {
        false,
    },
    override = {
        [250]  = false,
        [251]  = false,
        [252]  = false,
        [577]  = false,
        [581]  = false,
        [102]  = false,
        [103]  = false,
        [104]  = false,
        [105]  = false,
        [1467] = false,
        [1468] = false,
        [1473] = false,
        [253]  = false,
        [254]  = false,
        [255]  = false,
        [62]   = false,
        [63]   = false,
        [64]   = false,
        [268]  = false,
        [270]  = false,
        [269]  = false,
        [65]   = false,
        [66]   = false,
        [70]   = false,
        [256]  = false,
        [257]  = false,
        [258]  = false,
        [259]  = false,
        [260]  = false,
        [261]  = false,
        [262]  = false,
        [263]  = false,
        [264]  = false,
        [265]  = false,
        [266]  = false,
        [267]  = false,
        [71]   = false,
        [72]   = false,
        [73]   = false,
    },
    display = {
        [250]  = false,
        [251]  = false,
        [252]  = false,
        [577]  = false,
        [581]  = false,
        [102]  = false,
        [103]  = false,
        [104]  = false,
        [105]  = false,
        [1467] = false,
        [1468] = false,
        [1473] = false,
        [253]  = false,
        [254]  = false,
        [255]  = false,
        [62]   = false,
        [63]   = false,
        [64]   = false,
        [268]  = false,
        [270]  = false,
        [269]  = false,
        [65]   = false,
        [66]   = false,
        [70]   = false,
        [256]  = false,
        [257]  = false,
        [258]  = false,
        [259]  = false,
        [260]  = false,
        [261]  = false,
        [262]  = false,
        [263]  = false,
        [264]  = false,
        [265]  = false,
        [266]  = false,
        [267]  = false,
        [71]   = false,
        [72]   = false,
        [73]   = false,
    },
}

local function BuildSpecNumberMap(specIDs, iconSize)
    iconSize = iconSize or 16
    local map = {}
    for _, specID in ipairs(specIDs) do
        local id, name, _, icon = GetSpecializationInfoByID(specID)
        if name and icon then
            map[specID] = ("|T%d:%d:%d|t %s"):format(icon, iconSize, iconSize, name)
        else
            map[specID] = tostring(specID)
        end
    end
    return map
end

-- list the spec IDs you use
local specIDs        = {
    250, 251, 252,      -- DK
    577, 581, 1480,     -- Demon Hunter
    102, 103, 104, 105, -- Druid
    1467, 1468, 1473,   -- Evoker
    253, 254, 255,      -- Hunter
    62, 63, 64,         -- Mage
    268, 270, 269,      -- Monk
    65, 66, 70,         -- Paladin
    256, 257, 258,      -- Priest
    259, 260, 261,      -- Rogue
    262, 263, 264,      -- Shaman
    265, 266, 267,      -- Warlock
    71, 72, 73,         -- Warrior
}

-- create the table
local specNumberMap2 = BuildSpecNumberMap(specIDs, 28)

local function importPayload(payload)
    if not payload then
        print("|cff0099cc" .. addonName .. "|r" .. ": ", "Import failed: No data found.")
        return
    end
    
    local profile = addon.db.profile

    local function DeepMerge(target, source)
        for k, v in pairs(source) do
            if type(v) == "table" then
                if type(target[k]) ~= "table" then
                    target[k] = {}
                end
                DeepMerge(target[k], v)
            else
                target[k] = v
            end
        end
    end

    local function Ensure(pathTable, key)
        if type(pathTable[key]) ~= "table" then
            pathTable[key] = {}
        end
        return pathTable[key]
    end

    -- Merge layout
    if payload.layout then
        for key, entry in pairs(payload.layout) do
            DeepMerge(profile[key].layout, payload.layout[key])
        end
    end

    -- Merge anchor
    if payload.anchor then
        for key, entry in pairs(payload.anchor) do
            DeepMerge(profile[key].anchor, payload.anchor[key])
        end
    end

    -- Merge override
    if payload.override then
        for key, entry in pairs(payload.override) do
            if entry.essential then
                DeepMerge(Ensure(profile.essential.override, key), entry.essential)
            end
            if entry.utility then
                DeepMerge(Ensure(profile.utility.override, key), entry.utility)
            end
            if entry.buffIcon then
                DeepMerge(Ensure(profile.buffIcon.override, key), entry.buffIcon)
            end
            if entry.buffBar then
                DeepMerge(Ensure(profile.buffBar.override, key), entry.buffBar)
            end
        end
    end

    -- Merge display
    if payload.display then
        for key, entry in pairs(payload.display) do
            if entry.essential then
                DeepMerge(Ensure(profile.essential.display, key), entry.essential)
            end
            if entry.utility then
                DeepMerge(Ensure(profile.utility.display, key), entry.utility)
            end
            if entry.buffIcon then
                DeepMerge(Ensure(profile.buffIcon.display, key), entry.buffIcon)
            end
            if entry.buffBar then
                DeepMerge(Ensure(profile.buffBar.display, key), entry.buffBar)
            end
        end
    end

    print("|cff0099cc" .. addonName .. "|r" .. ": ", "Importing settings... (/reload may be required)")
end

local option = {
    name = "",
    type = "group",
    childGroups = "tab",
    --inline = true,
    args = {
        Export = {
            order = 1,
            name = "Export",
            type = "group",
            childGroups = "tab",
            --inline = true,
            args = {
                exportButton = {
                    order = 0,
                    name = "Export Selected Settings",
                    desc = "Click to export the selected settings. A window will open with the export string that you can copy.",
                    type = "execute",
                    func = function(info)
                        -- implement the export functionality here
                        -- dataToExport table contains the user's selections
                        -- you can serialize this data and show it in a popup or copy to clipboard
                        local payload = {}
                        payload.layout = {}
                        payload.anchor = {}
                        payload.override = {}
                        payload.display = {}

                        local atLeastOneSelected = false
                        if dataToExport.layout then
                            payload.layout = {
                                essential = addon:deepCopy(addon.db.profile.essential.layout),
                                utility = addon:deepCopy(addon.db.profile.utility.layout),
                                buffIcon = addon:deepCopy(addon.db.profile.buffIcon.layout),
                                buffBar = addon:deepCopy(addon.db.profile.buffBar.layout),
                            }
                            atLeastOneSelected = true
                        end

                        if dataToExport.layout then
                            payload.anchor = {
                                essential = addon:deepCopy(addon.db.profile.essential.anchor),
                                utility = addon:deepCopy(addon.db.profile.utility.anchor),
                                buffIcon = addon:deepCopy(addon.db.profile.buffIcon.anchor),
                                buffBar = addon:deepCopy(addon.db.profile.buffBar.anchor),
                            }
                            atLeastOneSelected = true
                        end

                        for key, value in pairs(dataToExport.override) do
                            if value then
                                payload.override[key] = {
                                    essential = addon:deepCopy(addon.db.profile.essential.override[key]),
                                    utility = addon:deepCopy(addon.db.profile.utility.override[key]),
                                    buffIcon = addon:deepCopy(addon.db.profile.buffIcon.override[key]),
                                    buffBar = addon:deepCopy(addon.db.profile.buffBar.override[key]),
                                }
                                atLeastOneSelected = true
                            end
                        end

                        for key, value in pairs(dataToExport.display) do
                            if value then
                                payload.display[key] = {
                                    essential = addon:deepCopy(addon.db.profile.essential.display[key]),
                                    utility = addon:deepCopy(addon.db.profile.utility.display[key]),
                                    buffIcon = addon:deepCopy(addon.db.profile.buffIcon.display[key]),
                                    buffBar = addon:deepCopy(addon.db.profile.buffBar.display[key]),
                                }
                                atLeastOneSelected = true
                            end
                        end

                        if not atLeastOneSelected then
                            print("|cff0099cc" .. addonName .. "|r" .. ": ", "Export failed: No settings selected.")
                            return
                        end

                        exportString = addon:encodeForExport(payload)

                        print("|cff0099cc" .. addonName .. "|r" .. ": ", "Exporting settings...")
                    end,
                    width = "full",
                },
                exportBox = {
                    order = 1,
                    name = "Export String",
                    desc = "Paste the export string here to import settings.",
                    type = "input",
                    multiline = 10,
                    width = "full",
                    set = function(info, value)
                        --read only?
                    end,
                    get = function(info)
                        return exportString or ""
                    end,
                },
                Layout = {
                    order = 2,
                    name = "Layout to Export",
                    type = "group",
                    childGroups = "tab",
                    inline = true,
                    args = {
                        global = {
                            order = 1.1,
                            name = "All Layouts (Essential, Utility, Buff Icon, Buff Bar)",
                            type = "toggle",
                            get = function(info)
                                return dataToExport.layout
                            end,
                            set = function(info, value)
                                dataToExport.layout = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                Anchor = {
                    order = 3,
                    name = "Position to Export",
                    type = "group",
                    childGroups = "tab",
                    inline = true,
                    args = {

                        global = {
                            order = 1.1,
                            name = "All Position (Essential, Utility, Buff Icon, Buff Bar)",
                            type = "toggle",
                            get = function(info)
                                return dataToExport.anchor
                            end,
                            set = function(info, value)
                                dataToExport.anchor = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                override = {
                    order = 4,
                    name = "Override to Export",
                    type = "group",
                    childGroups = "tab",
                    inline = true,
                    args = {
                        bloodDK = {
                            order = 2,
                            name = specNumberMap2[250],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[250]
                            end,
                            set = function(info, value)
                                dataToExport.override[250] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        frostDK = {
                            order = 3,
                            name = specNumberMap2[251],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[251]
                            end,
                            set = function(info, value)
                                dataToExport.override[251] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        unholyDK = {
                            order = 4,
                            name = specNumberMap2[252],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[252]
                            end,
                            set = function(info, value)
                                dataToExport.override[252] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        havocDH = {
                            order = 5,
                            name = specNumberMap2[577],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[577]
                            end,
                            set = function(info, value)
                                dataToExport.override[577] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        vengeanceDH = {
                            order = 6,
                            name = specNumberMap2[581],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[581]
                            end,
                            set = function(info, value)
                                dataToExport.override[581] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        devourerDH = {
                            order = 6.5,
                            name = specNumberMap2[1480],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[1480]
                            end,
                            set = function(info, value)
                                dataToExport.override[1480] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        balanceDR = {
                            order = 7,
                            name = specNumberMap2[102],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[102]
                            end,
                            set = function(info, value)
                                dataToExport.override[102] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        feralDR = {
                            order = 8,
                            name = specNumberMap2[103],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[103]
                            end,
                            set = function(info, value)
                                dataToExport.override[103] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        guardianDR = {
                            order = 9,
                            name = specNumberMap2[104],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[104]
                            end,
                            set = function(info, value)
                                dataToExport.override[104] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        restorationDR = {
                            order = 10,
                            name = specNumberMap2[105],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[105]
                            end,
                            set = function(info, value)
                                dataToExport.override[105] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        devastationEvoker = {
                            order = 11,
                            name = specNumberMap2[1467],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[1467]
                            end,
                            set = function(info, value)
                                dataToExport.override[1467] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        preservationEvoker = {
                            order = 12,
                            name = specNumberMap2[1468],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[1468]
                            end,
                            set = function(info, value)
                                dataToExport.override[1468] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        augmentationEvoker = {
                            order = 13,
                            name = specNumberMap2[1473],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[1473]
                            end,
                            set = function(info, value)
                                dataToExport.override[1473] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        beastMasteryHunter = {
                            order = 14,
                            name = specNumberMap2[253],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[253]
                            end,
                            set = function(info, value)
                                dataToExport.override[253] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        marksmanshipHunter = {
                            order = 15,
                            name = specNumberMap2[254],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[254]
                            end,
                            set = function(info, value)
                                dataToExport.override[254] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        survivalHunter = {
                            order = 16,
                            name = specNumberMap2[255],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[255]
                            end,
                            set = function(info, value)
                                dataToExport.override[255] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        arcaneMage = {
                            order = 17,
                            name = specNumberMap2[62],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[62]
                            end,
                            set = function(info, value)
                                dataToExport.override[62] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        fireMage = {
                            order = 18,
                            name = specNumberMap2[63],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[63]
                            end,
                            set = function(info, value)
                                dataToExport.override[63] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        frostMage = {
                            order = 19,
                            name = specNumberMap2[64],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[64]
                            end,
                            set = function(info, value)
                                dataToExport.override[64] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        brewmasterMonk = {
                            order = 20,
                            name = specNumberMap2[268],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[268]
                            end,
                            set = function(info, value)
                                dataToExport.override[268] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        mistweaverMonk = {
                            order = 21,
                            name = specNumberMap2[270],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[270]
                            end,
                            set = function(info, value)
                                dataToExport.override[270] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        windwalkerMonk = {
                            order = 22,
                            name = specNumberMap2[269],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[269]
                            end,
                            set = function(info, value)
                                dataToExport.override[269] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        holyPaladin = {
                            order = 23,
                            name = specNumberMap2[65],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[65]
                            end,
                            set = function(info, value)
                                dataToExport.override[65] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        protectionPaladin = {
                            order = 24,
                            name = specNumberMap2[66],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[66]
                            end,
                            set = function(info, value)
                                dataToExport.override[66] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        retributionPaladin = {
                            order = 25,
                            name = specNumberMap2[70],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[70]
                            end,
                            set = function(info, value)
                                dataToExport.override[70] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        diciplinePriest = {
                            order = 26,
                            name = specNumberMap2[256],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[256]
                            end,
                            set = function(info, value)
                                dataToExport.override[256] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        holyPriest = {
                            order = 27,
                            name = specNumberMap2[257],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[257]
                            end,
                            set = function(info, value)
                                dataToExport.override[257] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        shadowPriest = {
                            order = 28,
                            name = specNumberMap2[258],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[258]
                            end,
                            set = function(info, value)
                                dataToExport.override[258] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        assassinationRogue = {
                            order = 29,
                            name = specNumberMap2[259],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[259]
                            end,
                            set = function(info, value)
                                dataToExport.override[259] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        outlawRogue = {
                            order = 30,
                            name = specNumberMap2[260],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[260]
                            end,
                            set = function(info, value)
                                dataToExport.override[260] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subtletyRogue = {
                            order = 31,
                            name = specNumberMap2[261],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[261]
                            end,
                            set = function(info, value)
                                dataToExport.override[261] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        elementalShaman = {
                            order = 32,
                            name = specNumberMap2[262],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[262]
                            end,
                            set = function(info, value)
                                dataToExport.override[262] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        enhancementShaman = {
                            order = 33,
                            name = specNumberMap2[263],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[263]
                            end,
                            set = function(info, value)
                                dataToExport.override[263] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        restorationShaman = {
                            order = 34,
                            name = specNumberMap2[264],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[264]
                            end,
                            set = function(info, value)
                                dataToExport.override[264] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        afflictionWarlock = {
                            order = 35,
                            name = specNumberMap2[265],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[265]
                            end,
                            set = function(info, value)
                                dataToExport.override[265] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        demonologyWarlock = {
                            order = 36,
                            name = specNumberMap2[266],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[266]
                            end,
                            set = function(info, value)
                                dataToExport.override[266] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        destructionWarlock = {
                            order = 37,
                            name = specNumberMap2[267],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[267]
                            end,
                            set = function(info, value)
                                dataToExport.override[267] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        armsWarrior = {
                            order = 38,
                            name = specNumberMap2[71],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[71]
                            end,
                            set = function(info, value)
                                dataToExport.override[71] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        furyWarrior = {
                            order = 39,
                            name = specNumberMap2[72],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[72]
                            end,
                            set = function(info, value)
                                dataToExport.override[72] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        protectionWarrior = {
                            order = 40,
                            name = specNumberMap2[73],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.override[73]
                            end,
                            set = function(info, value)
                                dataToExport.override[73] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                display = {
                    order = 5,
                    name = "Additional Items to Export",
                    type = "group",
                    childGroups = "tab",
                    inline = true,
                    args = {
                        bloodDK = {
                            order = 2,
                            name = specNumberMap2[250],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[250]
                            end,
                            set = function(info, value)
                                dataToExport.display[250] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        frostDK = {
                            order = 3,
                            name = specNumberMap2[251],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[251]
                            end,
                            set = function(info, value)
                                dataToExport.display[251] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        unholyDK = {
                            order = 4,
                            name = specNumberMap2[252],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[252]
                            end,
                            set = function(info, value)
                                dataToExport.display[252] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        havocDH = {
                            order = 5,
                            name = specNumberMap2[577],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[577]
                            end,
                            set = function(info, value)
                                dataToExport.display[577] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        vengeanceDH = {
                            order = 6,
                            name = specNumberMap2[581],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[581]
                            end,
                            set = function(info, value)
                                dataToExport.display[581] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        devourerDH = {
                            order = 6.5,
                            name = specNumberMap2[1480],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[1480]
                            end,
                            set = function(info, value)
                                dataToExport.display[1480] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        balanceDR = {
                            order = 7,
                            name = specNumberMap2[102],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[102]
                            end,
                            set = function(info, value)
                                dataToExport.display[102] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        feralDR = {
                            order = 8,
                            name = specNumberMap2[103],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[103]
                            end,
                            set = function(info, value)
                                dataToExport.display[103] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        guardianDR = {
                            order = 9,
                            name = specNumberMap2[104],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[104]
                            end,
                            set = function(info, value)
                                dataToExport.display[104] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        restorationDR = {
                            order = 10,
                            name = specNumberMap2[105],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[105]
                            end,
                            set = function(info, value)
                                dataToExport.display[105] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        devastationEvoker = {
                            order = 11,
                            name = specNumberMap2[1467],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[1467]
                            end,
                            set = function(info, value)
                                dataToExport.display[1467] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        preservationEvoker = {
                            order = 12,
                            name = specNumberMap2[1468],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[1468]
                            end,
                            set = function(info, value)
                                dataToExport.display[1468] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        augmentationEvoker = {
                            order = 13,
                            name = specNumberMap2[1473],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[1473]
                            end,
                            set = function(info, value)
                                dataToExport.display[1473] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        beastMasteryHunter = {
                            order = 14,
                            name = specNumberMap2[253],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[253]
                            end,
                            set = function(info, value)
                                dataToExport.display[253] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        marksmanshipHunter = {
                            order = 15,
                            name = specNumberMap2[254],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[254]
                            end,
                            set = function(info, value)
                                dataToExport.display[254] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        survivalHunter = {
                            order = 16,
                            name = specNumberMap2[255],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[255]
                            end,
                            set = function(info, value)
                                dataToExport.display[255] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        arcaneMage = {
                            order = 17,
                            name = specNumberMap2[62],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[62]
                            end,
                            set = function(info, value)
                                dataToExport.display[62] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        fireMage = {
                            order = 18,
                            name = specNumberMap2[63],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[63]
                            end,
                            set = function(info, value)
                                dataToExport.display[63] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        frostMage = {
                            order = 19,
                            name = specNumberMap2[64],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[64]
                            end,
                            set = function(info, value)
                                dataToExport.display[64] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        brewmasterMonk = {
                            order = 20,
                            name = specNumberMap2[268],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[268]
                            end,
                            set = function(info, value)
                                dataToExport.display[268] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        mistweaverMonk = {
                            order = 21,
                            name = specNumberMap2[270],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[270]
                            end,
                            set = function(info, value)
                                dataToExport.display[270] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        windwalkerMonk = {
                            order = 22,
                            name = specNumberMap2[269],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[269]
                            end,
                            set = function(info, value)
                                dataToExport.display[269] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        holyPaladin = {
                            order = 23,
                            name = specNumberMap2[65],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[65]
                            end,
                            set = function(info, value)
                                dataToExport.display[65] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        protectionPaladin = {
                            order = 24,
                            name = specNumberMap2[66],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[66]
                            end,
                            set = function(info, value)
                                dataToExport.display[66] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        retributionPaladin = {
                            order = 25,
                            name = specNumberMap2[70],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[70]
                            end,
                            set = function(info, value)
                                dataToExport.display[70] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        diciplinePriest = {
                            order = 26,
                            name = specNumberMap2[256],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[256]
                            end,
                            set = function(info, value)
                                dataToExport.display[256] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        holyPriest = {
                            order = 27,
                            name = specNumberMap2[257],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[257]
                            end,
                            set = function(info, value)
                                dataToExport.display[257] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        shadowPriest = {
                            order = 28,
                            name = specNumberMap2[258],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[258]
                            end,
                            set = function(info, value)
                                dataToExport.display[258] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        assassinationRogue = {
                            order = 29,
                            name = specNumberMap2[259],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[259]
                            end,
                            set = function(info, value)
                                dataToExport.display[259] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        outlawRogue = {
                            order = 30,
                            name = specNumberMap2[260],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[260]
                            end,
                            set = function(info, value)
                                dataToExport.display[260] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subtletyRogue = {
                            order = 31,
                            name = specNumberMap2[261],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[261]
                            end,
                            set = function(info, value)
                                dataToExport.display[261] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        elementalShaman = {
                            order = 32,
                            name = specNumberMap2[262],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[262]
                            end,
                            set = function(info, value)
                                dataToExport.display[262] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        enhancementShaman = {
                            order = 33,
                            name = specNumberMap2[263],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[263]
                            end,
                            set = function(info, value)
                                dataToExport.display[263] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        restorationShaman = {
                            order = 34,
                            name = specNumberMap2[264],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[264]
                            end,
                            set = function(info, value)
                                dataToExport.display[264] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        afflictionWarlock = {
                            order = 35,
                            name = specNumberMap2[265],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[265]
                            end,
                            set = function(info, value)
                                dataToExport.display[265] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        demonologyWarlock = {
                            order = 36,
                            name = specNumberMap2[266],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[266]
                            end,
                            set = function(info, value)
                                dataToExport.display[266] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        destructionWarlock = {
                            order = 37,
                            name = specNumberMap2[267],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[267]
                            end,
                            set = function(info, value)
                                dataToExport.display[267] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        armsWarrior = {
                            order = 38,
                            name = specNumberMap2[71],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[71]
                            end,
                            set = function(info, value)
                                dataToExport.display[71] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        furyWarrior = {
                            order = 39,
                            name = specNumberMap2[72],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[72]
                            end,
                            set = function(info, value)
                                dataToExport.display[72] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        protectionWarrior = {
                            order = 40,
                            name = specNumberMap2[73],
                            type = "toggle",
                            get = function(info)
                                return dataToExport.display[73]
                            end,
                            set = function(info, value)
                                dataToExport.display[73] = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
            },
        },
        Import = {
            order = 2,
            name = "Import",
            type = "group",
            childGroups = "tab",
            --inline = true,
            args = {
                importButton = {
                    order = 0,
                    name = "Import Pasted Settings",
                    desc = "Click to import the pasted settings.",
                    type = "execute",
                    func = function(info)
                        if not importString or importString == "" then
                            print("|cff0099cc" .. addonName .. "|r" .. ": ", "No import string provided.")
                            return
                        end
                        local decodedData = addon:decodeFromImport(importString)

                        importPayload(decodedData)

                        addon:RefreshViewer()
                    end,
                    width = "full",
                },
                importBox = {
                    order = 1,
                    name = "Import String",
                    desc = "Paste the export string here to import settings.",
                    type = "input",
                    multiline = 30,
                    width = "full",
                    set = function(info, value)
                        importString = value
                    end,
                    get = function(info)
                        return importString or ""
                    end,
                },
            },
        },
    },
}

function addon:ImportExportOptions()
    local AceDBOptions = LibStub("AceDBOptions-3.0")
    option.args.profiles = AceDBOptions:GetOptionsTable(self.db)

    return option
end
