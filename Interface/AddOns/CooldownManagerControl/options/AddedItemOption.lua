local addonName, addonTable = ...
local addon                 = addonTable.Core

local priorities            = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
local anchorList            = { "TOPLEFT", "LEFT", "BOTTOMLEFT", "TOP", "CENTER", "BOTTOM", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT" }
local barStyle              = { "Icon and Name", "Icon Only", "Name Only", }
local iconBorderVisibility  = { "Default", "Always Show", "Always Hide", }

local updateListEssential   = function() end
local updateListUtility     = function() end
local updateListIcon        = function() end
local updateListBar         = function() end

local option                = {
    name = "",
    type = "group",
    childGroups = "tab",
    --inline = true,
    args = {
        Group_1 = {
            order = 1,
            name  = "Essential Cooldown",
            type  = "group",
            --inline = true,
            args  = {
                inputID = {
                    order = 0,
                    name = "Item ID",
                    desc = "Input the ID for which you want to add a new entry",
                    type = "input",
                    set = function(_, ID)
                        updateListEssential(ID)
                        addon:RefreshViewer()
                    end,
                    get = function()
                        return nil
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                additionalItems = {
                    order = 0.5,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select an item above to edit its settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
            },
        },
        Group_2 = {
            order = 2,
            name  = "Utility Cooldown",
            type  = "group",
            --inline = true,
            args  = {
                inputID = {
                    order = 0,
                    name = "Item ID",
                    desc = "Input the ID for which you want to add a new entry",
                    type = "input",
                    set = function(_, ID)
                        updateListUtility(ID)
                        addon:RefreshViewer()
                    end,
                    get = function()
                        return nil
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                additionalItems = {
                    order = 0.5,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select an item above to edit its settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
            },
        },
        Group_3 = {
            order = 3,
            name  = "Buff Icon",
            type  = "group",
            --inline = true,
            args  = {
                inputID = {
                    order = 0,
                    name = "Item ID",
                    desc = "Input the ID for which you want to add a new entry",
                    type = "input",
                    set = function(_, ID)
                        updateListIcon(ID)
                        addon:RefreshViewer()
                    end,
                    get = function()
                        return nil
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                additionalItems = {
                    order = 0.5,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select an item above to edit its settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
            },
        },
        Group_4 = {
            order = 4,
            name  = "Buff Bar",
            type  = "group",
            --inline = true,
            args  = {
                inputID = {
                    order = 0,
                    name = "Item ID",
                    desc = "Input the ID for which you want to add a new entry",
                    type = "input",
                    set = function(_, ID)
                        updateListBar(ID)
                        addon:RefreshViewer()
                    end,
                    get = function()
                        return nil
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                additionalItems = {
                    order = 0.5,
                    name = "",
                    --desc = "",
                    type = "group",
                    inline = true,
                    args = {
                    },
                },
                settingsHeader = {
                    order = 2,
                    name = "Select an item above to edit its settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
            },
        },
    }
}

local function buildSelectedEntryOptions(optionTable, flag, refreshFunc)
    local itemOption = {
        order = 4,
        name = "Item Parameters",
        type = "group",
        inline = true,
        args = {
            showCharge = {
                order = 1,
                name = "Show Stack Count",
                desc = "Enable/Disable stack count display",
                type = "toggle",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showCharge
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.showCharge = value
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
                width = "full",
            }
        },
    }
    local poseOptions = {
        order = 5,
        name = "",
        type = "group",
        inline = true,
        args = {
            poseHeader = {
                order = 1,
                name = "Positioning Settings",
                type = "header",
                dialogControl = "DF_Header",
            },
            overridePose = {
                order = 2,
                type = "toggle",
                name = "Override Placement",
                desc = "This entry will use its own predetermined placement",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overridePose
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.overridePose = val
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
            },
            anchor = {
                order = 8,
                name = "— Anchor On Cooldown Frame",
                desc = "Select the point on the cooldown frame.",
                type = "select",
                values = anchorList,
                get = function(info)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and addon:GetIndex(entry.anchor, anchorList)
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.anchor = anchorList[value]
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Dropdown",
                width = "full",
            },
            anchorRel = {
                order = 9,
                name = "— Anchor On Parent",
                desc = "Select the point on the parent frame to anchor the cooldown frame.",
                type = "select",
                values = anchorList,
                get = function(info)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and addon:GetIndex(entry.anchorRel, anchorList)
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.anchorRel = anchorList[value]
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Dropdown",
                width = "full",
            },
            xOffset = {
                order = 10,
                name = "— Horizontal Offset",
                desc = "Adjust the horizontal offset of the frame from the anchor point.",
                type = "range",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.xOffset
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                order = 11,
                name = "— Vertical Offset",
                desc = "Adjust the vertical offset of the frame from the anchor point.",
                type = "range",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.yOffset
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                order = 12,
                name = "— Anchored to (Frame)",
                desc = "Input the name of the parent frame (default is UIParent)",
                type = "input",
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.parent = value
                        addon:RefreshViewer()
                    end
                end,
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.parent
                end,
                width = "full",
                dialogControl = "DF_EditBox",
            }
        },
    }
    local frameOptions = {
        order = 5.2,
        name = "",
        type = "group",
        inline = true,
        args = {
            frameHeader = {
                order = 0,
                name = "Frame Settings",
                type = "header",
                dialogControl = "DF_Header",
            },
            displayType = {
                order = 1,
                name = "Display Style",
                desc = "Choose how the icon-bar are displayed.",
                type = "select",
                values = barStyle,
                get = function(info)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.displayType + 1
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.barIconSpacing
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
    }
    local iconOptions = {
        order = 6,
        name = "",
        type = "group",
        inline = true,
        args = {
            iconHeader = {
                order = 0,
                name = "Icon Settings",
                type = "header",
                dialogControl = "DF_Header",
            },
            overrideIcon = {
                order = 1,
                type = "toggle",
                name = "Override Icon Settings",
                desc = "This entry will use its own icon settings",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overrideIcon
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.iconWidth
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.iconWidth = value
                        addon:RefreshViewer()
                    end
                end,
                min = 1,
                max = 80,
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.iconHeight
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.iconHeight = value
                        addon:RefreshViewer()
                    end
                end,
                min = 1,
                max = 80,
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showIconOverlay
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.showIconOverlay = val
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
            },
            showDebuffBorder = {
                order = 4.5,
                name = "— Show Debuff Border",
                desc = "By default a colored border is shown around debuffs to indicate the type of debuff.",
                type = "toggle",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showDebuffBorder
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showIconBorder + 1
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.removeMask
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.addPixelBorder
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.pixelBorderSize
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
    }
    local barOptions = {
        order = 7,
        name = "",
        type = "group",
        inline = true,
        args = {
            barHeader = {
                order = 0,
                name = "Bar Settings",
                type = "header",
                dialogControl = "DF_Header",
            },
            overrideBar = {
                order = 1,
                type = "toggle",
                name = "Override Bar Settings",
                desc = "This entry will use its own bar settings",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overrideBar
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overrideTexture
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.texture
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overrideColor
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.classColor
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.barWidth
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.barHeight
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showPip
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.pipHeight
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.addPixelBorderBar
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.addPixelBorderBar = value
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
                width = "full",
            },
            pixelBorderSize = {
                order = 12,
                name = "— — Border Size",
                desc = "Adjust the thickness of the custom border.",
                type = "range",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.pixelBorderSize
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
            pixelBorderColorBar = {
                order = 13,
                name = "— —Border Color",
                desc = "Choose the color of the border",
                type = "color",
                get = function(info)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showBackground
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile.buffBar.display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.customBackground
                end,
                set = function(info, value)
                    local selectedID = addon.db.profile.buffBar.display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile.buffBar.display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
                    local selectedID = addon.db.profile.buffBar.display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
        },
    }
    local toggleOptions = {
        order = 8,
        name = "",
        type = "group",
        inline = true,
        args = {
            toggleHeader = {
                order = 0,
                name = "Text and Toggle Settings",
                type = "header",
                dialogControl = "DF_Header",
            },
            overrideFontSizes = {
                order = 0.1,
                type = "toggle",
                name = "Override Fonts",
                desc = "This entry will use its own font sizes",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.overrideFontSizes
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.overrideFontSizes = val
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
            },
            countScale = {
                order = 1,
                name = "— Charge/Count Font Size",
                desc = "Adjust the font size for charge/count display on the bar.",
                type = "range",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.applicationScale
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
            cooldownScale = {
                order = 2,
                name = "— Cooldown Font Size",
                desc = "Adjust the font size for cooldown display on the bar.",
                type = "range",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.cooldownScale
                end,
                set = function(_, value)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
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
            showWhenInactive = {
                order = 3,
                type = "toggle",
                name = "Show When Inactive",
                desc = "When enabled, the buff bar will be visible even when there are no active buffs to display.",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showWhenInactive
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.showWhenInactive = val
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
            },
            desaturateWhenInactive = {
                order = 4,
                type = "toggle",
                name = "Desaturate When Inactive",
                desc = "When enabled, the icon and the bar will appear desaturated when there are no active buffs to display.",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.desaturateWhenInactive
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.desaturateWhenInactive = val
                        addon:RefreshViewer()
                    end
                end,
                dialogControl = "DF_Checkbox_Left_Label",
            },
            showCooldown = {
                order = 2.5,
                type = "toggle",
                name = "— Show Cooldown",
                desc = "Toggle the visibility of cooldown text on the icon.",
                width = "full",
                get = function()
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    return entry and entry.showCooldown
                end,
                set = function(_, val)
                    local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                    if entry then
                        entry.showCooldown = val
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
                                local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                                return entry and entry.showTooltip
                            end,
                            set = function(_, val)
                                local selectedID = addon.db.profile[flag].display.selectedEntry
                    local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
                                if entry then
                                    entry.showTooltip = val
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                        }, ]]
        },
    }
    local settingsHeader = {
        order = 2,
        name = "Select an item above to edit its settings",
        type = "header",
        dialogControl = "DF_Header",
    }
    local enable = {
        order = 3.1,
        type = "toggle",
        name = "Enable Entry",
        desc = "This entry will be added to the CoolDownManager",
        width = "full",
        get = function()
            local selectedID = addon.db.profile[flag].display.selectedEntry
            local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
            return entry and entry.enable
        end,
        set = function(_, val)
            local selectedID = addon.db.profile[flag].display.selectedEntry
            local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
            if entry then
                entry.enable = val
                addon:RefreshViewer()
            end
        end,
        dialogControl = "DF_Checkbox_Left_Label",
    }
    local rank = {
        order = 3.2,
        name = "Rank",
        desc = "Place of this entry in the display",
        type = "select",
        values = priorities,
        get = function(info)
            local selectedID = addon.db.profile[flag].display.selectedEntry
            local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
            return entry and entry.rank
        end,
        set = function(info, value)
            local selectedID = addon.db.profile[flag].display.selectedEntry
            local entry = addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID]
            if entry then
                entry.rank = priorities[value]
                addon:RefreshViewer()
                refreshFunc()
            end
        end,
        dialogControl = "DF_Dropdown",
        width = "full",
    }
    local delete = {
        order = 3.3,
        name = "Remove Entry",
        type = "execute",
        func = function()
            local selectedID = addon.db.profile[flag].display.selectedEntry
            addon.db.profile[flag].display[addon.db.global.playerSpec][selectedID] = nil
            optionTable.args.settingsHeader.name = "Select an item above to edit its settings"
            optionTable.args["delete"] = nil
            optionTable.args["enable"] = nil
            optionTable.args["rank"] = nil
            optionTable.args["auraOptions"] = nil
            optionTable.args["itemOptions"] = nil
            optionTable.args["poseOptions"] = nil
            optionTable.args["iconOptions"] = nil
            optionTable.args["barOptions"] = nil
            optionTable.args["frameOptions"] = nil
            optionTable.args["toggleOptions"] = nil
            refreshFunc()
            addon:RefreshViewer()
        end,
        width = "full",
        --dialogControl = "DeleteButton",
    }
    --optionTable.args["settingsHeader"] = settingsHeader

    optionTable.args["delete"] = delete
    optionTable.args["enable"] = enable
    optionTable.args["rank"] = rank

    optionTable.args["toggleOptions"] = toggleOptions
    optionTable.args["itemOptions"] = itemOption
    optionTable.args["poseOptions"] = poseOptions
    optionTable.args["iconOptions"] = iconOptions

    if flag == "buffBar" then
        optionTable.args["frameOptions"] = frameOptions
        optionTable.args["barOptions"] = barOptions
    else
        optionTable.args["frameOptions"] = nil
        optionTable.args["barOptions"] = nil
    end
end

local function GenerateLineGUI(optionList, inputId, dataTable, name, refreshFunc)
    -- Wipe the displayed option
    for k in pairs(optionList.args.additionalItems.args) do
        optionList.args.additionalItems.args[k] = nil
    end

    -- Process input ID(s)
    local idList = addon:ExtractIntegersFromString(inputId)
    for _, id in ipairs(idList) do
        dataTable[id] = dataTable[id] or addon:deepCopy(addonTable.ItemFrameDefault)
        dataTable[id].type = "item"
        dataTable[id].itemId = id
        print("|cff0099ccCooldown Manager|r Control" .. ": ", "Added Item ID:", id)
    end

    -- Sort IDs to keep UI order consistent
    local sortedIDs = {}
    for id in pairs(dataTable) do
        table.insert(sortedIDs, id)
    end

    -- Sort by rank field (lowest first). Fallback to ID if priorities are equal/missing.
    table.sort(sortedIDs, function(a, b)
        local pa = dataTable[a].rank or 0
        local pb = dataTable[b].rank or 0
        if pa == pb then
            return a < b -- fallback to numeric ID
        else
            return pa < pb
        end
    end)

    optionList.args.additionalItems.args["group_"] = {
        order = 1,
        type = "group",
        inline = true,
        name = "Added Items",
        args = {},
    }

    for i, id in ipairs(sortedIDs) do
        local key = tostring(id)
        local lineData = dataTable[id]
        addon:SanitizeData(lineData, addonTable.ItemFrameDefault)
        local itemID = C_Item.GetItemNameByID(id) or nil
        local entryName = itemID and itemID or "Unknown"
        local texture = itemID and C_Item.GetItemIconByID(id) or nil

        -- Create the button entry
        optionList.args.additionalItems.args["group_"].args["desc_" .. key] = {
            order       = lineData.rank,
            name        = key,
            type        = "execute",
            desc        = key .. " (Name: " .. entryName .. ")",
            image       = texture,
            imageWidth  = 40,
            imageHeight = 40,
            func        = function()
                addon.db.profile[name].display.selectedEntry = id
                optionList.args.settingsHeader.name = "Settings for" .. " " .. key .. " (Name: " .. entryName .. ")"
                buildSelectedEntryOptions(optionList, name, refreshFunc)
            end,
            width       = 0.3,
        }
    end
end

updateListEssential = function(inputId)
    local optionList = option.args.Group_1
    local dataTable = addon.db.profile.essential.display[addon.db.global.playerSpec]
    GenerateLineGUI(optionList, inputId, dataTable, "essential", updateListEssential)
end

updateListUtility = function(inputId)
    local optionList = option.args.Group_2
    local dataTable = addon.db.profile.utility.display[addon.db.global.playerSpec]
    GenerateLineGUI(optionList, inputId, dataTable, "utility", updateListUtility)
end

updateListIcon = function(inputId)
    local optionList = option.args.Group_3
    local dataTable = addon.db.profile.buffIcon.display[addon.db.global.playerSpec]
    GenerateLineGUI(optionList, inputId, dataTable, "buffIcon", updateListIcon)
end

updateListBar = function(inputId)
    local optionList = option.args.Group_4
    local dataTable = addon.db.profile.buffBar.display[addon.db.global.playerSpec]
    GenerateLineGUI(optionList, inputId, dataTable, "buffBar", updateListBar)
end

function addon:GetItemOptions()
    updateListEssential()
    updateListUtility()
    updateListIcon()
    updateListBar()
    return option
end

function addon:GetEssentialItemOptions()
    updateListEssential()
    return option.args.Group_1
end

function addon:GetUtilityItemOptions()
    updateListUtility()
    return option.args.Group_2
end

function addon:GetBuffIconItemOptions()
    updateListIcon()
    return option.args.Group_3
end

function addon:GetBuffBarItemOptions()
    updateListBar()
    return option.args.Group_4
end
