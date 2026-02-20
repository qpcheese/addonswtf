local addonName, addonTable = ...
local addon                 = addonTable.Core

local anchorList            = { "TOPLEFT", "LEFT", "BOTTOMLEFT", "TOP", "CENTER", "BOTTOM", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT" }

local option                = {
    name = "",
    type = "group",
    childGroups = "tab",
    --inline = true,
    args = {
        Essential = {
            order = 1,
            name = "Essential Cooldowns",
            type = "group",
            args = {
                overridePlacement = {
                    order = 1.2,
                    name = "Override Placement",
                    desc = "Let the addon handle the position of the viewer. Note: You will not be able to move it in EditMode when enabled.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.essential.anchor
                        return db.overridePlacement
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.essential.anchor
                            db.overridePlacement = value
                            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                        else
                            local db = addon.db.profile.essential.anchor
                            db.overridePlacement = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                point = {
                    order = 2,
                    name = "— Anchor on Essential Cooldown Frame",
                    desc = "Select the point on the Essential Cooldown frame.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.essential.anchor
                        local index = addon:GetIndex(db.point, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.essential.anchor
                        db.point = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                relativePoint = {
                    order = 3,
                    name = "— Anchor on Parent",
                    desc = "Select the point on the parent frame to anchor the viewer.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.essential.anchor
                        local index = addon:GetIndex(db.relativePoint, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.essential.anchor
                        db.relativePoint = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                xOffset = {
                    order = 4,
                    name = "— Horizontal Offset",
                    desc = "Adjust the horizontal offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.essential.anchor
                        return db.xOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.essential.anchor
                        db.xOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                yOffset = {
                    order = 6,
                    name = "— Vertical Offset",
                    desc = "Adjust the vertical offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.essential.anchor
                        return db.yOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.essential.anchor
                        db.yOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                parent = {
                    order = 7,
                    name = "— Anchored to (Frame)",
                    desc = "Input the name of the parent frame (default is UIParent)",
                    type = "input",
                    set = function(_, value)
                        local db = addon.db.profile.essential.anchor
                        db.parent = value
                        addon:RefreshViewer()
                    end,
                    get = function()
                        local db = addon.db.profile.essential.anchor
                        return db.parent
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                inheritsVisibility = {
                    order = 8,
                    name = "— Inherit Visibility",
                    desc = "If toogled on, the viewer will inherit the visibility state of the parent frame.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.essential.anchor
                        return db.inheritsVisibility
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.essential.anchor
                            db.inheritsVisibility = value
                        else
                            local db = addon.db.profile.essential.anchor
                            db.inheritsVisibility = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                inheritsScale = {
                    order = 9,
                    name = "— Inherit Scale",
                    desc = "If toogled on, the viewer will inherit the scale of the parent frame (excluding UIParent).",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.essential.anchor
                        return db.inheritsScale
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.essential.anchor
                            db.inheritsScale = value
                        else
                            local db = addon.db.profile.essential.anchor
                            db.inheritsScale = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
            },
        },
        Utility = {
            order = 2,
            name = "Utility Cooldowns",
            type = "group",
            args = {
                overridePlacement = {
                    order = 1.2,
                    name = "Override Placement",
                    desc = "Let the addon handle the position of the viewer. Note: You will not be able to move it in EditMode when enabled.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.utility.anchor
                        return db.overridePlacement
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.utility.anchor
                            db.overridePlacement = value
                            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                        else
                            local db = addon.db.profile.utility.anchor
                            db.overridePlacement = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                point = {
                    order = 2,
                    name = "— Anchor on Utility Cooldown Frame",
                    desc = "Select the point on the Utility Cooldown frame.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.utility.anchor
                        local index = addon:GetIndex(db.point, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.utility.anchor
                        db.point = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                relativePoint = {
                    order = 3,
                    name = "— Anchor on Parent",
                    desc = "Select the point on the parent frame to anchor the viewer.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.utility.anchor
                        local index = addon:GetIndex(db.relativePoint, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.utility.anchor
                        db.relativePoint = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                xOffset = {
                    order = 4,
                    name = "— Horizontal Offset",
                    desc = "Adjust the horizontal offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.utility.anchor
                        return db.xOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.utility.anchor
                        db.xOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                yOffset = {
                    order = 6,
                    name = "— Vertical Offset",
                    desc = "Adjust the vertical offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.utility.anchor
                        return db.yOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.utility.anchor
                        db.yOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                parent = {
                    order = 7,
                    name = "— Anchored to (Frame)",
                    desc = "Input the name of the parent frame (default is UIParent)",
                    type = "input",
                    set = function(_, value)
                        local db = addon.db.profile.utility.anchor
                        db.parent = value
                        addon:RefreshViewer()
                    end,
                    get = function()
                        local db = addon.db.profile.utility.anchor
                        return db.parent
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                inheritsVisibility = {
                    order = 8,
                    name = "— Inherit Visibility",
                    desc = "If toogled on, the viewer will inherit the visibility state of the parent frame.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.utility.anchor
                        return db.inheritsVisibility
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.utility.anchor
                            db.inheritsVisibility = value
                        else
                            local db = addon.db.profile.utility.anchor
                            db.inheritsVisibility = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                inheritsScale = {
                    order = 9,
                    name = "— Inherit Scale",
                    desc = "If toogled on, the viewer will inherit the scale of the parent frame (excluding UIParent).",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.utility.anchor
                        return db.inheritsScale
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.utility.anchor
                            db.inheritsScale = value
                        else
                            local db = addon.db.profile.utility.anchor
                            db.inheritsScale = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
            },
        },
        BuffList = {
            order = 3,
            name = "Buff Icons",
            type = "group",
            args = {
                overridePlacement = {
                    order = 1.2,
                    name = "Override Placement",
                    desc = "Let the addon handle the position of the viewer. Note: You will not be able to move it in EditMode when enabled.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffIcon.anchor
                        return db.overridePlacement
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffIcon.anchor
                            db.overridePlacement = value
                            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                        else
                            local db = addon.db.profile.buffIcon.anchor
                            db.overridePlacement = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                point = {
                    order = 2,
                    name = "— Anchor on Buff Icon Frame",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.buffIcon.anchor
                        local index = addon:GetIndex(db.point, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.buffIcon.anchor
                        db.point = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                relativePoint = {
                    order = 3,
                    name = "— Anchor on Parent",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.buffIcon.anchor
                        local index = addon:GetIndex(db.relativePoint, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.buffIcon.anchor
                        db.relativePoint = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                xOffset = {
                    order = 4,
                    name = "— Horizontal Offset",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.buffIcon.anchor
                        return db.xOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.buffIcon.anchor
                        db.xOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                yOffset = {
                    order = 6,
                    name = "— Vertical Offset",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.buffIcon.anchor
                        return db.yOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.buffIcon.anchor
                        db.yOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                parent = {
                    order = 7,
                    name = "— Anchored to (Frame)",
                    desc = "Input the name of the parent frame (default is UIParent)",
                    type = "input",
                    set = function(_, value)
                        local db = addon.db.profile.buffIcon.anchor
                        db.parent = value
                        addon:RefreshViewer()
                    end,
                    get = function()
                        local db = addon.db.profile.buffIcon.anchor
                        return db.parent
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                inheritsVisibility = {
                    order = 8,
                    name = "— Inherit Visibility",
                    desc = "If toogled on, the viewer will inherit the visibility state of the parent frame.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffIcon.anchor
                        return db.inheritsVisibility
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffIcon.anchor
                            db.inheritsVisibility = value
                        else
                            local db = addon.db.profile.buffIcon.anchor
                            db.inheritsVisibility = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                inheritsScale = {
                    order = 9,
                    name = "— Inherit Scale",
                    desc = "If toogled on, the viewer will inherit the scale of the parent frame (excluding UIParent).",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffIcon.anchor
                        return db.inheritsScale
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffIcon.anchor
                            db.inheritsScale = value
                        else
                            local db = addon.db.profile.buffIcon.anchor
                            db.inheritsScale = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
            },
        },
        BuffBar = {
            order = 4,
            name = "Buff Bars",
            type = "group",
            args = {
                overridePlacement = {
                    order = 1.2,
                    name = "Override Placement",
                    desc = "Let the addon handle the position of the viewer. Note: You will not be able to move it in EditMode when enabled.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffBar.anchor
                        return db.overridePlacement
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffBar.anchor
                            db.overridePlacement = value
                            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                        else
                            local db = addon.db.profile.buffBar.anchor
                            db.overridePlacement = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                point = {
                    order = 2,
                    name = "— Anchor on Buff Bar Frame",
                    desc = "Select the point on the Buff Bar frame.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.buffBar.anchor
                        local index = addon:GetIndex(db.point, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.buffBar.anchor
                        db.point = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                relativePoint = {
                    order = 3,
                    name = "— Anchor on Parent",
                    desc = "Select the point on the parent frame to anchor the viewer.",
                    type = "select",
                    values = anchorList,
                    get = function(info)
                        local db = addon.db.profile.buffBar.anchor
                        local index = addon:GetIndex(db.relativePoint, anchorList)
                        return index
                    end,
                    set = function(info, value)
                        local db = addon.db.profile.buffBar.anchor
                        db.relativePoint = anchorList[value]
                        addon:RefreshViewer()
                    end,
                    dialogControl = "DF_Dropdown",
                    width = "full",
                },
                xOffset = {
                    order = 4,
                    name = "— Horizontal Offset",
                    desc = "Adjust the horizontal offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.buffBar.anchor
                        return db.xOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.buffBar.anchor
                        db.xOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                yOffset = {
                    order = 6,
                    name = "— Vertical Offset",
                    desc = "Adjust the vertical offset of the viewer from the anchor point.",
                    type = "range",
                    get = function()
                        local db = addon.db.profile.buffBar.anchor
                        return db.yOffset
                    end,
                    set = function(_, value)
                        local db = addon.db.profile.buffBar.anchor
                        db.yOffset = value
                        addon:RefreshViewer()
                    end,
                    min = -1000,
                    max = 1000,
                    step = 1,
                    dialogControl = "DF_Slider",
                    width = "full",
                },
                parent = {
                    order = 7,
                    name = "— Anchored to (Frame)",
                    desc = "Input the name of the parent frame (default is UIParent)",
                    type = "input",
                    set = function(_, value)
                        local db = addon.db.profile.buffBar.anchor
                        db.parent = value
                        addon:RefreshViewer()
                    end,
                    get = function()
                        local db = addon.db.profile.buffBar.anchor
                        return db.parent
                    end,
                    width = "full",
                    dialogControl = "DF_EditBox",
                },
                inheritsVisibility = {
                    order = 8,
                    name = "— Inherit Visibility",
                    desc = "If toogled on, the viewer will inherit the visibility state of the parent frame.",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffBar.anchor
                        return db.inheritsVisibility
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffBar.anchor
                            db.inheritsVisibility = value
                        else
                            local db = addon.db.profile.buffBar.anchor
                            db.inheritsVisibility = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
                inheritsScale = {
                    order = 9,
                    name = "— Inherit Scale",
                    desc = "If toogled on, the viewer will inherit the scale of the parent frame (excluding UIParent).",
                    type = "toggle",
                    get = function(info)
                        local db = addon.db.profile.buffBar.anchor
                        return db.inheritsScale
                    end,
                    set = function(info, value)
                        if not value then
                            local db = addon.db.profile.buffBar.anchor
                            db.inheritsScale = value
                        else
                            local db = addon.db.profile.buffBar.anchor
                            db.inheritsScale = value
                            addon:RefreshViewer()
                        end
                    end,
                    dialogControl = "DF_Checkbox_Left_Label",
                    width = "full",
                },
            },
        },
    }
}

function addon:GetAnchorOptions()
    return option
end

function addon:GetEssentialAnchorOptions()
    return option.args.Essential
end

function addon:GetUtilityAnchorOptions()
    return option.args.Utility
end

function addon:GetBuffIconAnchorOptions()
    return option.args.BuffList
end

function addon:GetBuffBarAnchorOptions()
    return option.args.BuffBar
end
