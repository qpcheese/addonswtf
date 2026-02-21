local addonName, addonTable = ...
local addon                 = addonTable.Core

local aceConfigDialog       = LibStub("AceConfigDialog-3.0")

local barStyle              = { "Icon and Name", "Icon Only", "Name Only", }
local iconBorderVisibility  = { "Default", "Always Show", "Always Hide", }
local anchorList            = { "TOPLEFT", "LEFT", "BOTTOMLEFT", "TOP", "CENTER", "BOTTOM", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT" }
local pandemicStyles        = { "Border Color", "Border Flash", "Border Flash and Color", "Pixel Ants", "Marching Ants", "Fit to Frame", "None" }
local pandemicStylesBar     = { "Border Color", "Border Flash", "Border Flash and Color", "Not Available", "Not Available", "Not Available", "None" } -- "Golden Glow", "Blue Glow", "Blue Ants", "None", }
local textPositions         = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", }
local barTextPositions      = { "LEFT", "CENTER", "RIGHT", }

local option                = {
    name = "",
    type = "group",
    childGroups = "tab",
    --inline = true,
    args = {
        description = {
            order = 0,
            name = "    This panel allows you to customize the display/behavior of each element independently and selectively\n    The lists are automatically refreshed after you close the blizzard cooldown settings.",
            type = "description",
            width = "full",
            fontSize = "medium",
            --dialogControl = "DF_Header",
        },
        Group_1 = {
            order       = 1,
            name        = "Essential Cooldown",
            type        = "group",
            childGroups = "tab",
            --inline = true,
            args        = {
                description = {
                    order = 0,
                    name = "    This panel allows you to customize the display/behavior of each element independently and selectively\n    The lists are automatically refreshed after you close the blizzard cooldown settings.",
                    type = "description",
                    width = "full",
                    fontSize = "medium",
                    --dialogControl = "DF_Header",
                },
                additionalItems = {
                    order = 1,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select a Cooldown ID to override above",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                enable = {
                    order = 3,
                    type = "toggle",
                    name = "Enable Override",
                    desc = "This entry will have its settings overridden",
                    width = "full",
                    get = function()
                        local selectedID = addon.db.profile.essential.override.selectedCooldownId
                        local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                        return entry and entry.enable
                    end,
                    set = function(_, val)
                        local selectedID = addon.db.profile.essential.override.selectedCooldownId
                        local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                        if entry then
                            entry.enable = val
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                },
                poseHeader = {
                    order = 4,
                    name = "Positioning Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                poseOptions = {
                    order = 5,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overridePose = {
                            order = 1,
                            type = "toggle",
                            name = "Override Placement",
                            desc = "This entry will use its own predetermined placement",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePose
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePose = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable
                            end, ]]
                        },
                        anchor = {
                            order = 2,
                            name = "— Anchor On Cooldown Frame",
                            desc = "Select the point on the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchor, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchor = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        anchorRel = {
                            order = 3,
                            name = "— Anchor On Parent",
                            desc = "Select the point on the parent frame to anchor the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchorRel, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchorRel = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        xOffset = {
                            order = 4,
                            name = "— Horizontal Offset",
                            desc = "Adjust the horizontal offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.xOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.xOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        yOffset = {
                            order = 5,
                            name = "— Vertical Offset",
                            desc = "Adjust the vertical offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.yOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.yOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        parent = {
                            order = 6,
                            name = "— Anchored to (Frame)",
                            desc = "Input the name of the parent frame (default is UIParent)",
                            type = "input",
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.parent = value
                                    addon:RefreshViewer()
                                end
                            end,
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.parent
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        }
                    },
                },
                iconHeader = {
                    order = 6,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                iconOptions = {
                    order = 7,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideIcon = {
                            order = 1,
                            type = "toggle",
                            name = "Override Icon Settings",
                            desc = "This entry will use its own icon settings",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideIcon
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideIcon = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable
                            end, ]]
                        },
                        iconWidth = {
                            order = 2,
                            name = "— Icon Width",
                            desc = "Set the width of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconWidth
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconWidth = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        iconHeight = {
                            order = 3,
                            name = "— Icon Height",
                            desc = "Set the height of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                            --[[ disabled = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return not entry or not entry.enable or not entry.overridePose
                            end, ]]
                        },
                        showIconOverlay = {
                            order = 4,
                            type = "toggle",
                            name = "— Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on the icon",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconOverlay
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconOverlay = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        --[[ showIconBorder = {
                            order = 5,
                            type = "toggle",
                            name = "Show Icon Border",
                            desc = "Show at all time the border visible when out of range",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconBorder
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconBorder = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
                        showIconBorder = {
                            order = 5,
                            name = "— Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconBorder = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "— Remove Icon Mask",
                            desc = "Remove the default icon mask to have a square icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.removeMask
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 6.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorder = {
                            order = 7,
                            name = "— Add Custom Border",
                            desc = "Create a thin pixel border around the icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.addPixelBorder
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.addPixelBorder = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— — Border Size",
                            desc = "Adjust the thickness of the border",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pixelBorderSize
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pixelBorderSize = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— — Border Color",
                            desc = "Choose the color of the border",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 9.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 10,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePandemicIcon = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 11,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pandemicGlowType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 12,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        --[[ subHeader3 = {
                            order = 13.5,
                            name = "Custom Spell Alert Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        }, ]]
                        overrideSpellAlert = {
                            order = 14,
                            name = "Override Spell Alert Fx",
                            desc = "Override the default spell alert effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideSpellAlert
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideSpellAlert = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        spellAlertType = {
                            order = 15,
                            name = "— Spell Alert Style",
                            desc = "Choose the style of the glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.spellAlertType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.spellAlertType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        spellAlertColor = {
                            order = 16,
                            name = "— Spell Alert Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.spellAlertColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.spellAlertColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.spellAlertColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.spellAlertColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                toggleHeader = {
                    order = 8,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                toggleOptions = {
                    order = 9,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideFontSizes = {
                            order = 0,
                            type = "toggle",
                            name = "Override Fonts",
                            desc = "This entry will use its own font sizes",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideFontSizes
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideFontSizes = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showCooldown = {
                            order = 1,
                            type = "toggle",
                            name = "— Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on the icon.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showCooldown
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showCooldown = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— — Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.cooldownScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.cooldownScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 3,
                            name = "— — Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.iconCooldownPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconCooldownPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 5,
                            name = "— Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.applicationPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4,
                            name = "— Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.applicationScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },




                        --[[ showTooltip = {
                            order = 4,
                            type = "toggle",
                            name = "Show tooltip Text",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showTooltip
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.essential.override.selectedCooldownId
                                local entry = addon.db.profile.essential.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showTooltip = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
                    },
                },
            },
        },
        Group_2 = {
            order       = 2,
            name        = "Utility Cooldown",
            type        = "group",
            childGroups = "tab",
            --inline = true,
            args        = {
                description = {
                    order = 0,
                    name = "    This panel allows you to customize the display/behavior of each element independently and selectively\n    The lists are automatically refreshed after you close the blizzard cooldown settings.",
                    type = "description",
                    width = "full",
                    fontSize = "medium",
                    --dialogControl = "DF_Header",
                },
                additionalItems = {
                    order = 0.1,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 1,
                    name = "Select a Cooldown ID to override above",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                enable = {
                    order = 2,
                    type = "toggle",
                    name = "Enable Override",
                    desc = "This entry will have its settings overridden",
                    width = "full",
                    get = function()
                        local selectedID = addon.db.profile.utility.override.selectedCooldownId
                        local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                        return entry and entry.enable
                    end,
                    set = function(_, val)
                        local selectedID = addon.db.profile.utility.override.selectedCooldownId
                        local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                        if entry then
                            entry.enable = val
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                },
                poseHeader = {
                    order = 3,
                    name = "Positioning Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                poseOptions = {
                    order = 4,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overridePose = {
                            order = 1,
                            type = "toggle",
                            name = "Override Placement",
                            desc = "This entry will use its own predetermined placement",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePose
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePose = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        anchor = {
                            order = 2,
                            name = "— Anchor On Cooldown Frame",
                            desc = "Select the point on the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchor, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchor = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        anchorRel = {
                            order = 3,
                            name = "— Anchor On Parent",
                            desc = "Select the point on the parent frame to anchor the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchorRel, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchorRel = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        xOffset = {
                            order = 4,
                            name = "— Horizontal Offset",
                            desc = "Adjust the horizontal offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.xOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.xOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        yOffset = {
                            order = 5,
                            name = "— Vertical Offset",
                            desc = "Adjust the vertical offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.yOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.yOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        parent = {
                            order = 6,
                            name = "— Anchored to (Frame)",
                            desc = "Input the name of the parent frame (default is UIParent)",
                            type = "input",
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.parent = value
                                    addon:RefreshViewer()
                                end
                            end,
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.parent
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                        }
                    },
                },
                iconHeader = {
                    order = 5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                iconOptions = {
                    order = 6,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideIcon = {
                            order = 1,
                            type = "toggle",
                            name = "Override Icon Settings",
                            desc = "This entry will use its own icon settings",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideIcon
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideIcon = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        iconWidth = {
                            order = 2,
                            name = "— Icon Width",
                            desc = "Set the width of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconWidth
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconWidth = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "— Icon Height",
                            desc = "Set the height of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            type = "toggle",
                            name = "— Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on the icon",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconOverlay
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconOverlay = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "— Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconBorder = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "— Remove Icon Mask",
                            desc = "Remove the default icon mask to have a square icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.removeMask
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 6.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorder = {
                            order = 7,
                            name = "— Add Custom Border",
                            desc = "Create a thin pixel border around the icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.addPixelBorder
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.addPixelBorder = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— — Border Size",
                            desc = "Adjust the thickness of the border",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pixelBorderSize
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pixelBorderSize = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— — Border Color",
                            desc = "Choose the color of the border",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 9.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 10,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePandemicIcon = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 11,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pandemicGlowType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 12,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        --[[ subHeader3 = {
                            order = 13.5,
                            name = "Custom Spell Alert Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        }, ]]
                        overrideSpellAlert = {
                            order = 14,
                            name = "Override Spell Alert Fx",
                            desc = "Override the default spell alert effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideSpellAlert
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideSpellAlert = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        spellAlertType = {
                            order = 15,
                            name = "— Spell Alert Style",
                            desc = "Choose the style of the glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.spellAlertType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.spellAlertType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        spellAlertColor = {
                            order = 16,
                            name = "— Spell Alert Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.spellAlertColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.spellAlertColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.spellAlertColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.spellAlertColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                toggleHeader = {
                    order = 6,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                toggleOptions = {
                    order = 7,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideFontSizes = {
                            order = 0,
                            type = "toggle",
                            name = "Override Fonts",
                            desc = "This entry will use its own font sizes",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideFontSizes
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideFontSizes = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showCooldown = {
                            order = 1,
                            type = "toggle",
                            name = "— Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on the icon.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showCooldown
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showCooldown = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— — Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.cooldownScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.cooldownScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 3,
                            name = "— — Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.iconCooldownPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconCooldownPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 5,
                            name = "— Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.applicationPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4,
                            name = "— Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.applicationScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },




                        --[[ showTooltip = {
                            order = 4,
                            type = "toggle",
                            name = "Show tooltip Text",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showTooltip
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.utility.override.selectedCooldownId
                                local entry = addon.db.profile.utility.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showTooltip = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
                    },
                },
            },
        },
        Group_3 = {
            order       = 3,
            name        = "Buff Icon",
            type        = "group",
            childGroups = "tab",
            --inline = true,
            args        = {
                description = {
                    order = 0,
                    name = "    This panel allows you to customize the display/behavior of each element independently and selectively\n    The lists are automatically refreshed after you close the blizzard cooldown settings.",
                    type = "description",
                    width = "full",
                    fontSize = "medium",
                    --dialogControl = "DF_Header",
                },
                additionalItems = {
                    order = 0.1,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 1,
                    name = "Select a Cooldown ID to override above",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                enable = {
                    order = 2,
                    type = "toggle",
                    name = "Enable Override",
                    desc = "This entry will have its settings overridden",
                    width = "full",
                    get = function()
                        local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                        local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                        return entry and entry.enable
                    end,
                    set = function(_, val)
                        local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                        local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                        if entry then
                            entry.enable = val
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                },
                poseHeader = {
                    order = 3,
                    name = "Positioning Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                poseOptions = {
                    order = 4,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overridePose = {
                            order = 1,
                            type = "toggle",
                            name = "Override Placement",
                            desc = "This entry will use its own predetermined placement",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePose
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePose = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        anchor = {
                            order = 2,
                            name = "— Anchor On Buff Frame",
                            desc = "The anchor point on the icon/bar",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchor, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchor = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        anchorRel = {
                            order = 3,
                            name = "— Anchor On Parent",
                            desc = "The anchor point on the parent frame",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchorRel, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchorRel = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        xOffset = {
                            order = 4,
                            name = "— Horizontal Offset",
                            desc = "Adjust the horizontal offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.xOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.xOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        yOffset = {
                            order = 5,
                            name = "— Vertical Offset",
                            desc = "Adjust the vertical offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.yOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.yOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        parent = {
                            order = 6,
                            name = "— Anchored to (Frame)",
                            desc = "Input the name of the parent frame (default is UIParent)",
                            type = "input",
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.parent = value
                                    addon:RefreshViewer()
                                end
                            end,
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.parent
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                        }
                    },
                },
                iconHeader = {
                    order = 5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                iconOptions = {
                    order = 6,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideIcon = {
                            order = 1,
                            type = "toggle",
                            name = "Override Icon Settings",
                            desc = "This entry will use its own icon settings",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideIcon
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideIcon = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        iconWidth = {
                            order = 2,
                            name = "— Icon Width",
                            desc = "Set the width of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconWidth
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconWidth = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "— Icon Height",
                            desc = "Set the height of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            type = "toggle",
                            name = "— Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on the icon",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconOverlay
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconOverlay = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showDebuffBorder = {
                            order = 4.5,
                            name = "Show Debuff Border",
                            desc = "By default a colored border is shown around debuffs to indicate the type of debuff.",
                            type = "toggle",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showDebuffBorder
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showDebuffBorder = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "— Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconBorder = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "— Remove Icon Mask",
                            desc = "Remove the default icon mask to have a square icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.removeMask
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 6.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorder = {
                            order = 7,
                            name = "— Add Custom Border",
                            desc = "Create a thin pixel border around the icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.addPixelBorder
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.addPixelBorder = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— — Border Size",
                            desc = "Adjust the thickness of the border",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pixelBorderSize
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pixelBorderSize = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— — Border Color",
                            desc = "Choose the color of the border",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 9.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 10,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePandemicIcon = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 11,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pandemicGlowType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 12,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                toggleHeader = {
                    order = 7,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                toggleOptions = {
                    order = 8,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideFontSizes = {
                            order = 0,
                            type = "toggle",
                            name = "Override Fonts",
                            desc = "This entry will use its own font sizes",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideFontSizes
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideFontSizes = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showCooldown = {
                            order = 1,
                            type = "toggle",
                            name = "— Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on the icon.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showCooldown
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showCooldown = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— — Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.cooldownScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.cooldownScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 3,
                            name = "— — Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.iconCooldownPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconCooldownPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 5,
                            name = "— Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.applicationPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4,
                            name = "— Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on the icon.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.applicationScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showWhenInactive = {
                            order = 6,
                            type = "toggle",
                            name = "Show When Inactive",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showWhenInactive
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showWhenInactive = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        desaturateWhenInactive = {
                            order = 7,
                            type = "toggle",
                            name = "Desaturate When Inactive",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.desaturateWhenInactive
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.desaturateWhenInactive = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },

                        --[[ showTooltip = {
                            order = 6,
                            type = "toggle",
                            name = "Show tooltip Text",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showTooltip
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffIcon.override.selectedCooldownId
                                local entry = addon.db.profile.buffIcon.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showTooltip = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
                    },
                },
            },
        },
        Group_4 = {
            order       = 4,
            name        = "Buff Bar",
            type        = "group",
            childGroups = "tab",
            --inline = true,
            args        = {
                description = {
                    order = 0,
                    name = "    This panel allows you to customize the display/behavior of each element independently and selectively\n    The lists are automatically refreshed after you close the blizzard cooldown settings.",
                    type = "description",
                    width = "full",
                    fontSize = "medium",
                    --dialogControl = "DF_Header",
                },
                additionalItems = {
                    order = 1,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select a Cooldown ID to override above",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                enable = {
                    order = 3,
                    type = "toggle",
                    name = "Enable Override",
                    desc = "This entry will have its settings overridden",
                    width = "full",
                    get = function()
                        local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                        local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                        return entry and entry.enable
                    end,
                    set = function(_, val)
                        local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                        local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                        if entry then
                            entry.enable = val
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                },
                poseHeader = {
                    order = 4,
                    name = "Positioning Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                poseOptions = {
                    order = 5,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overridePose = {
                            order = 1,
                            type = "toggle",
                            name = "Override Placement",
                            desc = "This entry will use its own predetermined placement",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePose
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePose = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        anchor = {
                            order = 2,
                            name = "— Anchor On Bar Frame",
                            desc = "Select the point on the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchor, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchor = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        anchorRel = {
                            order = 3,
                            name = "— Anchor On Parent",
                            desc = "Select the point on the parent frame to anchor the cooldown frame.",
                            type = "select",
                            values = anchorList,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.anchorRel, anchorList)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.anchorRel = anchorList[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        xOffset = {
                            order = 4,
                            name = "— Horizontal Offset",
                            desc = "Adjust the horizontal offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.xOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.xOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        yOffset = {
                            order = 5,
                            name = "— Vertical Offset",
                            desc = "Adjust the vertical offset of the frame from the anchor point.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.yOffset
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.yOffset = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -1000,
                            max = 1000,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        parent = {
                            order = 6,
                            name = "— Anchored to (Frame)",
                            desc = "Input the name of the parent frame (default is UIParent)",
                            type = "input",
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.parent = value
                                    addon:RefreshViewer()
                                end
                            end,
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.parent
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                        }
                    },
                },
                frameHeader = {
                    order = 5.1,
                    name = "Frame Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                frameOptions = {
                    order = 5.2,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        displayType = {
                            order = 1,
                            name = "Display Style",
                            desc = "Choose how the icon-bar are displayed.",
                            type = "select",
                            values = barStyle,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.displayType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.displayType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        barIconSpacing = {
                            order = 2,
                            name = "Icon-Bar Spacing",
                            desc = "Adjust the spacing between the icon and the bar.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.barIconSpacing
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.barIconSpacing = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = -20,
                            max = 20,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                    },
                },
                iconHeader = {
                    order = 6,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                iconOptions = {
                    order = 7,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideIcon = {
                            order = 1,
                            type = "toggle",
                            name = "Override Icon Settings",
                            desc = "This entry will use its own icon settings",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideIcon
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideIcon = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        iconWidth = {
                            order = 2,
                            name = "— Icon Width",
                            desc = "Set the width of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconWidth
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconWidth = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "— Icon Height",
                            desc = "Set the height of the icon",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.iconHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            type = "toggle",
                            name = "— Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on the icon",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconOverlay
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconOverlay = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showDebuffBorder = {
                            order = 4.5,
                            name = "Show Debuff Border",
                            desc = "By default a colored border is shown around debuffs to indicate the type of debuff.",
                            type = "toggle",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showDebuffBorder
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showDebuffBorder = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "— Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showIconBorder = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "— Remove Icon Mask",
                            desc = "Remove the default icon mask to have a square icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.removeMask
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 6.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorder = {
                            order = 7,
                            name = "— Add Custom Border",
                            desc = "Create a thin pixel border around the icon",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.addPixelBorder
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.addPixelBorder = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— — Border Size",
                            desc = "Adjust the thickness of the border",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pixelBorderSize
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pixelBorderSize = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— — Border Color",
                            desc = "Choose the color of the border",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                barHeader = {
                    order = 8,
                    name = "Bar Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                barOptions = {
                    order = 9,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideBar = {
                            order = 1,
                            type = "toggle",
                            name = "Override Bar Settings",
                            desc = "This entry will use its own bar settings",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideBar
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideBar = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        overrideTexture = {
                            order = 2,
                            type = "toggle",
                            name = "— Override Bar Texture",
                            desc = "Enable to override the default bar texture with a custom one. Full path required.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideTexture
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideTexture = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        texture = {
                            order = 3,
                            name = "",
                            desc = "",
                            type = "input",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.texture
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.texture = value
                                    addon:RefreshViewer()
                                end
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                        },
                        overrideColor = {
                            order = 4,
                            type = "toggle",
                            name = "— Override Bar Color",
                            desc = "Enable to override the default bar color with a custom one.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideColor
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideColor = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        color = {
                            order = 5,
                            name = "",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    local input = entry.color
                                    local hex = input:gsub('#', '')
                                    local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                    if #hex == 8 then
                                        a = tonumber(hex:sub(1, 2), 16) / 255
                                        r = tonumber(hex:sub(3, 4), 16) / 255
                                        g = tonumber(hex:sub(5, 6), 16) / 255
                                        b = tonumber(hex:sub(7, 8), 16) / 255
                                    elseif #hex == 6 then
                                        r = tonumber(hex:sub(1, 2), 16) / 255
                                        g = tonumber(hex:sub(3, 4), 16) / 255
                                        b = tonumber(hex:sub(5, 6), 16) / 255
                                    end
                                    return r, g, b, a
                                else
                                    return 1, 1, 1, 1
                                end
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    local input = entry.color
                                    local hex = input:gsub('#', '')
                                    if #hex == 8 then
                                        entry.color = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                    elseif #hex == 6 then
                                        entry.color = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                    end
                                    addon:RefreshViewer()
                                end
                            end,
                            hasAlpha = false,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        classColor = {
                            order = 6,
                            name = "— — Class Color",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.classColor
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                entry.classColor = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        barWidth = {
                            order = 7,
                            name = "— Bar Width",
                            desc = "Set the width of the bars.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.barWidth
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.barWidth = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 50,
                            max = 400,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        barHeight = {
                            order = 8,
                            name = "— Bar Height",
                            desc = "Set the height of the bars.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.barHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.barHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 5,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showPip = {
                            order = 8.5,
                            name = "— Show Progress Spark",
                            desc = "Display a spark effect on the bar to indicate progress.",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showPip
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showPip = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pipHeight = {
                            order = 9,
                            name = "— Pip Height",
                            desc = "Set the height of the progress spark.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pipHeight
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pipHeight = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        subHeader = {
                            order = 10.5,
                            name = "Border/Background Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorderBar = {
                            order = 11,
                            name = "— Add Custom Border",
                            desc = "Create a thin border around bars",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.addPixelBorderBar
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.addPixelBorderBar = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSizeBar = {
                            order = 12,
                            name = "— — Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pixelBorderSizeBar
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pixelBorderSizeBar = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColorBar = {
                            order = 13,
                            name = "— —Border Color",
                            desc = "Choose the color of the border",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pixelBorderColorBar
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pixelBorderColorBar
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pixelBorderColorBar = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pixelBorderColorBar = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        showBackground = {
                            order = 13.1,
                            type = "toggle",
                            name = "— Show Default Background",
                            desc = "Enable/Disable the background of the bars.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showBackground
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showBackground = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        customBackground = {
                            order = 13.2,
                            name = "— Add Custom Background",
                            desc = "Create a custom background texture for bars",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.customBackground
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.customBackground = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        backgroundColor = {
                            order = 13.3,
                            name = "",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.backgroundColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.backgroundColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.backgroundColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.backgroundColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 13.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 14,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overridePandemicIcon = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 15,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStylesBar,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.pandemicGlowType = value - 1
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 16,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry == nil then return 1, 1, 1, 1 end
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
                                if #hex == 8 then
                                    a = tonumber(hex:sub(1, 2), 16) / 255
                                    r = tonumber(hex:sub(3, 4), 16) / 255
                                    g = tonumber(hex:sub(5, 6), 16) / 255
                                    b = tonumber(hex:sub(7, 8), 16) / 255
                                elseif #hex == 6 then
                                    r = tonumber(hex:sub(1, 2), 16) / 255
                                    g = tonumber(hex:sub(3, 4), 16) / 255
                                    b = tonumber(hex:sub(5, 6), 16) / 255
                                end
                                return r, g, b, a
                            end,
                            set = function(info, r, g, b, a)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                local input = entry.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    entry.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                toggleHeader = {
                    order = 10,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                toggleOptions = {
                    order = 11,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        overrideFontSizes = {
                            order = 0,
                            type = "toggle",
                            name = "Override Fonts",
                            desc = "This entry will use its own font sizes",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.overrideFontSizes
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.overrideFontSizes = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        showCooldown = {
                            order = 1,
                            type = "toggle",
                            name = "— Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on the icon.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showCooldown
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showCooldown = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— — Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on the bar.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.cooldownScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.cooldownScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 3,
                            name = "— — Cooldown Position",
                            desc = "Choose the position of the cooldown text on the bar.",
                            type = "select",
                            values = barTextPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.iconCooldownPosition, barTextPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.iconCooldownPosition = barTextPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 5,
                            name = "— Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.applicationPosition, textPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationPosition = textPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4,
                            name = "— Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on the bar.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.applicationScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.applicationScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ namePosition = {
                            order = 7,
                            name = "— Name Position",
                            desc = "Choose the position of the spell text on the bar.",
                            type = "select",
                            values = barTextPositions,
                            get = function(info)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and addon:GetIndex(entry.barNamePosition, barTextPositions)
                            end,
                            set = function(info, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.barNamePosition = barTextPositions[value]
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        nameScale = {
                            order = 6,
                            name = "— Name Font Size",
                            desc = "Adjust the font size for the spell name displayed on the bar.",
                            type = "range",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.nameScale
                            end,
                            set = function(_, value)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.nameScale = value
                                    addon:RefreshViewer()
                                end
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showWhenInactive = {
                            order = 8,
                            type = "toggle",
                            name = "Show When Inactive",
                            desc = "When enabled, the buff bar will be visible even when there are no active buffs to display.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showWhenInactive
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showWhenInactive = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },
                        desaturateWhenInactive = {
                            order = 9,
                            type = "toggle",
                            name = "Desaturate When Inactive",
                            desc = "When enabled, the icon and the bar will appear desaturated when there are no active buffs to display.",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.desaturateWhenInactive
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.desaturateWhenInactive = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        },





                        --[[ showTooltip = {
                            order = 6,
                            type = "toggle",
                            name = "Show tooltip Text",
                            --desc = "This entry will use custom dimensions",
                            width = "full",
                            get = function()
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showTooltip
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile.buffBar.override.selectedCooldownId
                                local entry = addon.db.profile.buffBar.override[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showTooltip = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
                    },
                },
            },
        },
    },
}

local function GenerateLineGUI(optionList, dataTable, name)
    -- Wipe the displayed option
    for k in pairs(optionList) do
        optionList[k] = nil
    end

    -- Sort IDs to keep UI order consistent
    local sortedIDs = {}
    for id in pairs(dataTable) do
        table.insert(sortedIDs, id)
    end

    -- Sort by rank field (lowest first). Fallback to ID if priorities are equal/missing.
    table.sort(sortedIDs, function(a, b)
        local ra = dataTable[a].rank or 999
        local rb = dataTable[b].rank or 999
        if ra ~= rb then
            return ra < rb
        end
        return a < b -- fallback to numeric ID
    end)

    optionList["group_"] = {
        order = 1,
        type = "group",
        inline = true,
        name = "Cooldown IDs",
        args = {},
    }

    for i, id in ipairs(sortedIDs) do
        local key = tostring(id)
        local lineData = dataTable[id]
        addon:SanitizeData(lineData, addonTable.ItemFrameDefault)

        local cooldownInfo                        = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)

        local target                              = name == "essential" and option.args.Group_1.args.settingsHeader
            or name == "utility" and option.args.Group_2.args.settingsHeader
            or name == "buffIcon" and option.args.Group_3.args.settingsHeader
            or name == "buffBar" and option.args.Group_4.args.settingsHeader
        local order                               = 1
        local cancelOrder                         = 0

        optionList["group_"].args["desc_" .. key] = {
            order       = lineData.rank,
            name        = key,
            type        = "execute",
            desc        = key .. " (Spell ID: " .. cooldownInfo.spellID .. ")",
            image       = C_Spell.GetSpellTexture(tonumber(cooldownInfo.spellID)),
            imageWidth  = 40,
            imageHeight = 40,
            func        = function()
                addon.db.profile[name].override.selectedCooldownId = id
                target.name = "Override for" .. " " .. key .. " (Spell ID: " .. cooldownInfo.spellID .. ")"

                addon:GetOverrideOptions()
                if addonTable.GUI and addonTable.GUI:IsShown() and addonTable.GUI.activeTab then
                    aceConfigDialog:Open(addonTable.GUI.activeTab, addonTable.GUI.container)
                end
            end,
            --dialogControl = "DF_Icon",
            width       = 0.3,
        }
        order                                     = order + 1
    end
end

local updateListOverrideEssential = function()
    local optionList = option.args.Group_1.args.additionalItems.args
    local dataTable = addonTable.tmp.essential and addonTable.tmp.essential[addon.db.global.playerSpec] or {}
    GenerateLineGUI(optionList, dataTable, "essential")
end
local updateListOverrideUtility   = function()
    local optionList = option.args.Group_2.args.additionalItems.args
    local dataTable = addonTable.tmp.utility and addonTable.tmp.utility[addon.db.global.playerSpec] or {}
    GenerateLineGUI(optionList, dataTable, "utility")
end
local updateListOverrideIcon      = function()
    local optionList = option.args.Group_3.args.additionalItems.args
    local dataTable = addonTable.tmp.buffIcon and addonTable.tmp.buffIcon[addon.db.global.playerSpec] or {}
    GenerateLineGUI(optionList, dataTable, "buffIcon")
end
local updateListOverrideBar       = function()
    local optionList = option.args.Group_4.args.additionalItems.args
    local dataTable = addonTable.tmp.buffBar and addonTable.tmp.buffBar[addon.db.global.playerSpec] or {}
    GenerateLineGUI(optionList, dataTable, "buffBar")
end

function addon:GetOverrideOptions()
    updateListOverrideEssential()
    updateListOverrideUtility()
    updateListOverrideIcon()
    updateListOverrideBar()
    return option
end

function addon:GetEssentialOverrideOptions()
    updateListOverrideEssential()
    return option.args.Group_1
end

function addon:GetUtilityOverrideOptions()
    updateListOverrideUtility()
    return option.args.Group_2
end

function addon:GetBuffIconOverrideOptions()
    updateListOverrideIcon()
    return option.args.Group_3
end

function addon:GetBuffBarOverrideOptions()
    updateListOverrideBar()
    return option.args.Group_4
end
