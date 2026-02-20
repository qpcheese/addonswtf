local addonName, addonTable   = ...
local addon                   = addonTable.Core

local LibEditModeOverride     = LibStub("LibEditModeOverride-1.0")

local orientation             = { "Horizontal", "Vertical", }
local direction               = { "Right to Left / Top to Bottom", "Left to Right / Bottom to Top", }
local secondDirection         = { "New entries Below / Left", "New entries Above / Right", }
local barStyle                = { "Icon and Name", "Icon Only", "Name Only", }
local iconBorderVisibility    = { "Default", "Always Show", "Always Hide", }
local pandemicStyles          = { "Border Color", "Border Flash", "Border Flash and Color", "Pixel Ants", "Marching Ants", "Fit to Non-Square Frame", "Remove" } -- "Golden Glow", "Blue Glow", "Blue Ants", "None", }
local pandemicStylesBar       = { "Border Color", "Border Flash", "Border Flash and Color", "Not Available", "Not Available", "Not Available", "Remove" }        -- "Golden Glow", "Blue Glow", "Blue Ants", "None", }
local keybindPositions        = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", }
local textPositions           = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", }
local barTextPositions        = { "LEFT", "CENTER", "RIGHT", }
local assistedhighlightStyles = { "Pixel Ants", "Marching Ants" }

local option                  = {
    name = "",
    type = "group",
    childGroups = "tab",
    args = {
        Essential = {
            order = 1,
            name = "Essential Cooldowns",
            type = "group",
            childGroups = "tab",
            args = {
                group_0 = {
                    order = 0,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        enable = {
                            order = 0,
                            name = "Enable Module",
                            desc = "When enabled, the Essential Cooldowns Viewer will use your settings. When disabled, the viewer will ignore all settings.",
                            type = "toggle",
                            get = function(info)
                                return addon.db.profile.essential.enable
                            end,
                            set = function(info, value)
                                addon.db.profile.essential.enable = value
                                addon:RefreshViewer()
                                if not value then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        --[[ SecretTest = {
                            order = 0,
                            name = "Enable Addon Restrictions Test",
                            --desc = "When enabled, the Essential Cooldowns Viewer will use your settings. When disabled, the viewer will ignore all settings.",
                            type = "toggle",
                            get = function(info)
                                local atLeastOne = false
                                local var = C_CVar.GetCVar("secretCombatRestrictionsForced")
                                if var ~= "0" then
                                    addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 0, value)
                                    atLeastOne = true
                                end
                                var = C_CVar.GetCVar("secretEncounterRestrictionsForced")
                                if var ~= "0" then
                                    addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 1, value)
                                    atLeastOne = true
                                end
                                var = C_CVar.GetCVar("secretChallengeModeRestrictionsForced")
                                if var ~= "0" then
                                    addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 2, value)
                                    atLeastOne = true
                                end
                                var = C_CVar.GetCVar("secretPvPMatchRestrictionsForced")
                                if var ~= "0" then
                                    addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 3, value)
                                    atLeastOne = true
                                end
                                var = C_CVar.GetCVar("secretMapRestrictionsForced")
                                if var ~= "0" then
                                    addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 4, value)
                                    atLeastOne = true
                                end
                                return addon.db.profile.essential.test
                            end,
                            set = function(info, value)
                                addon.db.profile.essential.test = value
                                C_CVar.SetCVar("secretCombatRestrictionsForced", value and "1" or "0")
                                C_CVar.SetCVar("secretEncounterRestrictionsForced", value and "1" or "0")
                                C_CVar.SetCVar("secretChallengeModeRestrictionsForced", value and "1" or "0")
                                C_CVar.SetCVar("secretPvPMatchRestrictionsForced", value and "1" or "0")
                                C_CVar.SetCVar("secretMapRestrictionsForced", value and "1" or "0")
                                addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 0, value)
                                addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 1, value)
                                addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 2, value)
                                addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 3, value)
                                addon:OnAddonRestrictionChanged("ADDON_RESTRICTION_STATE_CHANGED", 4, value)
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                    },
                },
                layoutHeader = {
                    order = 0.5,
                    name = "Layout Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_1 = {
                    order = 1,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        iconLimit = {
                            order = 1,
                            name = "Icon Per Line",
                            desc = "Number of icons to display per row/column before creating a new row/column.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.iconLimit
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.iconLimit = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 20,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        isHorizontal = {
                            order = 2,
                            name = "Orientation",
                            desc = "Choose whether the icons are laid out horizontally or vertically.",
                            type = "select",
                            values = orientation,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.isHorizontal + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.isHorizontal = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        growthDirection = {
                            order = 3,
                            name = "Direction",
                            desc = "Choose the direction in which icons grow.",
                            type = "select",
                            values = direction,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.growthDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.growthDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        secondDirection = {
                            order = 4,
                            name = "Multi-Row/Column Direction",
                            desc = "Choose the direction in which new rows/columns are added when the icon per line limit is reached.",
                            type = "select",
                            values = secondDirection,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.secondDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.secondDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        centerDistribution = {
                            order = 5,
                            name = "Center Multi-Row/Column",
                            desc = "When enabled, rows/columns with fewer icons will be centered instead of left/top aligned.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.centerDistribution
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.centerDistribution = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        padding = {
                            order = 6,
                            name = "Horizontal Padding",
                            desc = "Adjust the horizontal spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.padding
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.padding = value
                                addon:RefreshViewer()
                            end,
                            min = -50,
                            max = 50,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        paddingY = {
                            order = 7,
                            name = "Vertical Padding",
                            desc = "Adjust the vertical spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.paddingY
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.paddingY = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ findSpacing = {
                            order = 10,
                            name = "Find Spacing to Fit the Personal Resource Display Length",
                            desc =
                            " Calculates and outputs the spacing value needed to fit the icons within the current frame width based on your icon width, scale, and icons per line settings. Note: This assume that the viewer is anchored to the personal resource display and inherits its scale.",
                            type = "execute",
                            func = function()
                                local width = PersonalResourceDisplayFrame:GetWidth()
                                local scale = PersonalResourceDisplayFrame:GetScale()

                                local iconWidth = addon.db.profile.essential.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.essential.layout.global.iconWidth or
                                    addon.db.profile.essential.layout[addon.db.global.playerSpec].iconWidth
                                local iconScale = addon.db.profile.essential.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.essential.layout.global.scale or addon.db.profile.essential.layout[addon.db.global.playerSpec]
                                    .scale
                                local iconLimit = addon.db.profile.essential.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.essential.layout.global.iconLimit or
                                    addon.db.profile.essential.layout[addon.db.global.playerSpec].iconLimit

                                local totalIconWidth = (iconWidth * iconScale) * iconLimit
                                local totalFrameWidth = (width + 4) * scale

                                if totalIconWidth > totalFrameWidth then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", "Icons exceed the frame width. Please lower the icon width, scale, or icon per line.")
                                    return
                                end

                                local spacing = (totalFrameWidth - totalIconWidth) / ((iconLimit - 1) * iconScale)
                                print("|cff0099ccCooldown Manager|r Control" .. ": ", "Calculated Spacing is " .. string.format("%.2f", spacing))
                            end,
                            width = "full",
                            --dialogControl = "DeleteButton",
                        }, ]]
                    },
                },
                iconHeader = {
                    order = 1.5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_2 = {
                    order = 2,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 1,
                            name = "Scale",
                            desc = "Adjust the overall scale of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.scale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.scale = value
                                addon:RefreshViewer()
                            end,
                            min = 0.05,
                            max = 5,
                            step = 0.05,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconWidth = {
                            order = 2,
                            name = "Icon Width",
                            desc = "Set the width of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.iconWidth
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.iconWidth = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "Icon Height",
                            desc = "Set the height of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.iconHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.iconHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            name = "Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showIconOverlay
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.showIconOverlay = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.showIconBorder = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "Remove Icon Mask",
                            desc = "Remove the default icon mask to have square icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.removeMask
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                if not value then
                                    db.removeMask = value
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                else
                                    db.removeMask = value
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
                            dialogControl = "DF_Header",
                        },
                        addPixelBorder = {
                            order = 7,
                            name = "Add Custom Border",
                            desc = "Create a thin border around icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.addPixelBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.addPixelBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.pixelBorderSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.pixelBorderSize = value
                                addon:RefreshViewer()
                            end,
                            min = 0,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— Border Color",
                            desc = "Choose the color of the custom border.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                local input = db.pixelBorderColor
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
                                local db = addon.db.profile.essential.layout
                                local input = db.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
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
                                local db = addon.db.profile.essential.layout
                                return db.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.overridePandemicIcon = value
                                addon:RefreshViewer()
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
                                local db = addon.db.profile.essential.layout
                                return db.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.pandemicGlowType = value - 1
                                addon:RefreshViewer()
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
                                local db = addon.db.profile.essential.layout
                                local input = db.pandemicColor
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
                                local db = addon.db.profile.essential.layout
                                local input = db.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        --[[ subHeader3 = {
                            order = 12.5,
                            name = "Custom Spell Alert Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        }, ]]
                        overrideSpellAlert = {
                            order = 13,
                            name = "Override Spell Alert Fx",
                            desc = "Override the default glow effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.overrideSpellAlert
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.overrideSpellAlert = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        spellAlertType = {
                            order = 14,
                            name = "— Spell Alert Style",
                            desc = "Choose the style of the spell alert glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.spellAlertType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.spellAlertType = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        spellAlertColor = {
                            order = 15,
                            name = "— Spell Alert Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                local input = db.spellAlertColor
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
                                local db = addon.db.profile.essential.layout
                                local input = db.spellAlertColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.spellAlertColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.spellAlertColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },

                        showAssistedHighlight = {
                            order = 15.1,
                            name = "Show Assisted Highlight",
                            desc = "Icon corresponding to the currently suggested spell will have a special highlight effect.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showAssistedHighlight
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.showAssistedHighlight = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        assistedHighlightStyle = {
                            order = 15.2,
                            name = "— Assisted Highlight Style",
                            desc = "Choose the style of the assisted highlight effect.",
                            type = "select",
                            values = assistedhighlightStyles,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.assistedHighlightStyle
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.assistedHighlightStyle = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        assistedHighlightColor = {
                            order = 15.3,
                            name = "— Assisted Highlight Color",
                            desc = "Specify the color of the assisted highlight effect.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                local input = db.assistedHighlightColor
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
                                local db = addon.db.profile.essential.layout
                                local input = db.assistedHighlightColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.assistedHighlightColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.assistedHighlightColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                textHeader = {
                    order = 2.5,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_3 = {
                    order = 3,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        --[[ showOnlyInCombat = {
                            order = 1,
                            name = "Show Only In Combat",
                            desc = "Toggle the visibility of the viewer.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showOnlyInCombat
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.showOnlyInCombat = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                        --[[ showTooltip = {
                            order = 2,
                            name = "Show Tooltip",
                            desc = "Toggle the display of tooltips when hovering over icons.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showTooltip
                            end,
                            set = function(info, value)
                                if LibEditModeOverride:IsReady() then
                                    LibEditModeOverride:LoadLayouts()
                                    LibEditModeOverride:SetFrameSetting(EssentialCooldownViewer, Enum.EditModeCooldownViewerSetting.ShowTooltips, value and 1 or 0)
                                    if not addonTable.isRestricted then
                                        addonTable.savedSettings = false
                                        LibEditModeOverride:ApplyChanges()
                                    else
                                        print("|cff0099ccCooldown Manager|r Control: ", "Cannot apply Edit Mode Override due to addon restrictions in place.")
                                        addonTable.savedSettings = true
                                        LibEditModeOverride:SaveOnly()
                                    end
                                end
                                local db = addon.db.profile.essential.layout
                                db.showTooltip = value
                                --addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                        showCooldown = {
                            order = 3,
                            name = "Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on icons.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                return db.showCooldown
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.showCooldown = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        cooldownScale = {
                            order = 4,
                            name = "— Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.cooldownScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.cooldownScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 4.1,
                            name = "— Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                local index = addon:GetIndex(db.iconCooldownPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.iconCooldownPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 4.3,
                            name = "Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.essential.layout
                                local index = addon:GetIndex(db.applicationPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout
                                db.applicationPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4.2,
                            name = "Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout
                                return db.countScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout
                                db.countScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showKeybind = {
                            order = 13,
                            name = "Show Keybind",
                            desc = "Add a text showing the keybind assigned to the spell on the icon.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.essential.layout.keybind
                                return db.showKeybind
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout.keybind
                                db.showKeybind = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        keybindPosition = {
                            order = 15,
                            name = "— Keybind Position",
                            desc = "Choose the position of the keybind text on the icon.",
                            type = "select",
                            values = keybindPositions,
                            get = function(info)
                                local db = addon.db.profile.essential.layout.keybind
                                local index = addon:GetIndex(db.keybindPosition, keybindPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.essential.layout.keybind
                                db.keybindPosition = keybindPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        keybindFontSize = {
                            order = 14,
                            name = "— Keybind Font Size",
                            desc = "Adjust the font size for keybind display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.essential.layout.keybind
                                return db.keybindFontSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.essential.layout.keybind
                                db.keybindFontSize = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },

                    },
                },
            },
        },
        Utility = {
            order = 2,
            name = "Utility Cooldowns",
            type = "group",
            childGroups = "tab",
            args = {
                group_0 = {
                    order = 0,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        enable = {
                            order = 0,
                            name = "Enable Module",
                            desc = "When enabled, Utility Cooldowns will show the viewer with your configured settings. When disabled, the viewer will ignore all settings.",
                            type = "toggle",
                            get = function(info)
                                return addon.db.profile.utility.enable
                            end,
                            set = function(info, value)
                                addon.db.profile.utility.enable = value
                                addon:RefreshViewer()
                                if not value then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                layoutHeader = {
                    order = 0.5,
                    name = "Layout Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_1 = {
                    order = 1,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        iconLimit = {
                            order = 1,
                            name = "Icon Per Line",
                            desc = "Number of icons to display per row/column before creating a new row/column.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.iconLimit
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.iconLimit = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 20,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        isHorizontal = {
                            order = 2,
                            name = "Orientation",
                            desc = "Choose whether the icons are laid out horizontally or vertically.",
                            type = "select",
                            values = orientation,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.isHorizontal + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.isHorizontal = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        growthDirection = {
                            order = 3,
                            name = "Direction",
                            desc = "Choose the direction in which the icons grow.",
                            type = "select",
                            values = direction,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.growthDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.growthDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        secondDirection = {
                            order = 4,
                            name = "Multi-Row/Column Direction",
                            desc = "Choose the direction in which new rows/columns are added when the icon limit is reached.",
                            type = "select",
                            values = secondDirection,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.secondDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.secondDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        centerDistribution = {
                            order = 5,
                            name = "Center Multi-Row/Column",
                            desc = "When enabled, rows/columns with fewer icons will be centered instead of left/top aligned.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.centerDistribution
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.centerDistribution = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        padding = {
                            order = 6,
                            name = "Horizontal Padding",
                            desc = "Adjust the horizontal spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.padding
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.padding = value
                                addon:RefreshViewer()
                            end,
                            min = -50,
                            max = 50,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        paddingY = {
                            order = 7,
                            name = "Vertical Padding",
                            desc = "Adjust the vertical spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.paddingY
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.paddingY = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ findSpacing = {
                            order = 10,
                            name = "Find Spacing to Fit the Personal Resource Display Length",
                            desc =
                            " Calculates and outputs the spacing value needed to fit the icons within the current frame width based on your icon width, scale, and icons per line settings. Note: This assume that the viewer is anchored to the personal resource display and inherits its scale.",
                            type = "execute",
                            func = function()
                                local width = PersonalResourceDisplayFrame:GetWidth()
                                local scale = PersonalResourceDisplayFrame:GetScale()

                                local iconWidth = addon.db.profile.utility.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.utility.layout.global.iconWidth or
                                    addon.db.profile.utility.layout[addon.db.global.playerSpec].iconWidth
                                local iconScale = addon.db.profile.utility.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.utility.layout.global.scale or addon.db.profile.utility.layout[addon.db.global.playerSpec]
                                    .scale
                                local iconLimit = addon.db.profile.utility.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.utility.layout.global.iconLimit or
                                    addon.db.profile.utility.layout[addon.db.global.playerSpec].iconLimit

                                local totalIconWidth = (iconWidth * iconScale) * iconLimit
                                local totalFrameWidth = (width + 4) * scale

                                if totalIconWidth > totalFrameWidth then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", "Icons exceed the frame width. Please lower the icon width, scale, or icon per line.")
                                    return
                                end

                                local spacing = (totalFrameWidth - totalIconWidth) / ((iconLimit - 1) * iconScale)
                                print("|cff0099ccCooldown Manager|r Control" .. ": ", "Calculated Spacing is " .. string.format("%.2f", spacing))
                            end,
                            width = "full",
                            --dialogControl = "DeleteButton",
                        }, ]]
                    },
                },
                iconHeader = {
                    order = 1.5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_2 = {
                    order = 2,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 1,
                            name = "Scale",
                            desc = "Adjust the overall scale of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.scale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.scale = value
                                addon:RefreshViewer()
                            end,
                            min = 0.05,
                            max = 5,
                            step = 0.05,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconWidth = {
                            order = 2,
                            name = "Icon Width",
                            desc = "Set the width of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.iconWidth
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.iconWidth = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "Icon Height",
                            desc = "Set the height of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.iconHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.iconHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            name = "Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showIconOverlay
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.showIconOverlay = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.showIconBorder = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 7,
                            name = "Remove Icon Mask",
                            desc = "Remove the default icon mask to have square icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.removeMask
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                if not value then
                                    db.removeMask = value
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                else
                                    db.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 7.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        addPixelBorder = {
                            order = 8,
                            name = "Add Custom Border",
                            desc = "Create a thin border around icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.addPixelBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.addPixelBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 9,
                            name = "— Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.pixelBorderSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.pixelBorderSize = value
                                addon:RefreshViewer()
                            end,
                            min = 0,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 10,
                            name = "— Border Color",
                            desc = "Choose the color of the custom border.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                local input = db.pixelBorderColor
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
                                local db = addon.db.profile.utility.layout
                                local input = db.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 10.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 11,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.overridePandemicIcon = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 12,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.pandemicGlowType = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 13,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                local input = db.pandemicColor
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
                                local db = addon.db.profile.utility.layout
                                local input = db.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
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
                            desc = "Override the default glow effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.overrideSpellAlert
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.overrideSpellAlert = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        spellAlertType = {
                            order = 15,
                            name = "— Spell Alert Style",
                            desc = "Choose the style of the spell alert glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.spellAlertType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.spellAlertType = value - 1
                                addon:RefreshViewer()
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
                                local db = addon.db.profile.utility.layout
                                local input = db.spellAlertColor
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
                                local db = addon.db.profile.utility.layout
                                local input = db.spellAlertColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.spellAlertColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.spellAlertColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                textHeader = {
                    order = 2.5,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_3 = {
                    order = 3,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        --[[ showOnlyInCombat = {
                            order = 1,
                            name = "Show Only In Combat",
                            desc = "Toggle the visibility of the viewer.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showOnlyInCombat
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.showOnlyInCombat = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                        --[[ showTooltip = {
                            order = 2,
                            name = "Show Tooltip",
                            desc = "Toggle the display of tooltips when hovering over icons.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showTooltip
                            end,
                            set = function(info, value)
                                if LibEditModeOverride:IsReady() then
                                    LibEditModeOverride:LoadLayouts()
                                    LibEditModeOverride:SetFrameSetting(UtilityCooldownViewer, Enum.EditModeCooldownViewerSetting.ShowTooltips, value and 1 or 0)
                                    if not addonTable.isRestricted then
                                        addonTable.savedSettings = false
                                        LibEditModeOverride:ApplyChanges()
                                    else
                                        print("|cff0099ccCooldown Manager|r Control: ", "Cannot apply Edit Mode Override due to addon restrictions in place.")
                                        addonTable.savedSettings = true
                                        LibEditModeOverride:SaveOnly()
                                    end
                                end
                                local db = addon.db.profile.utility.layout
                                db.showTooltip = value
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                        showCooldown = {
                            order = 3,
                            name = "Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on icons.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showCooldown
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.showCooldown = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        cooldownScale = {
                            order = 4,
                            name = "— Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.cooldownScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.cooldownScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 4.1,
                            name = "— Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                local index = addon:GetIndex(db.iconCooldownPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.iconCooldownPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 4.3,
                            name = "Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                local index = addon:GetIndex(db.applicationPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.applicationPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4.2,
                            name = "Charge/Count Font Size",
                            desc = "Adjust the font size of the charge/count display on the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout
                                return db.countScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout
                                db.countScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showKeybind = {
                            order = 13,
                            name = "Show Keybind",
                            desc = "Add a text showing the keybind assigned to the spell on the icon.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout.keybind
                                return db.showKeybind
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout.keybind
                                db.showKeybind = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        keybindPosition = {
                            order = 15,
                            name = "— Keybind Position",
                            desc = "Choose the position of the keybind text on the icon.",
                            type = "select",
                            values = keybindPositions,
                            get = function(info)
                                local db = addon.db.profile.utility.layout.keybind
                                local index = addon:GetIndex(db.keybindPosition, keybindPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout.keybind
                                db.keybindPosition = keybindPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        keybindFontSize = {
                            order = 14,
                            name = "— Keybind Font Size",
                            desc = "Adjust the font size for keybind display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.utility.layout.keybind
                                return db.keybindFontSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.utility.layout.keybind
                                db.keybindFontSize = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 60,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ showTooltip = {
                            order = 13,
                            name = "Show Tooltip",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.utility.layout
                                return db.showTooltip
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.utility.layout
                                db.showTooltip = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                    },
                },
            },
        },
        BuffIcon = {
            order = 3,
            name = "Buff Icon",
            type = "group",
            args = {
                group_0 = {
                    order = 0,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        enable = {
                            order = 0,
                            name = "Enable Module",
                            desc = "When enabled, Buff Icons will show the viewer with your configured settings. When disabled, the viewer will ignore all settings.",
                            type = "toggle",
                            get = function(info)
                                return addon.db.profile.buffIcon.enable
                            end,
                            set = function(info, value)
                                addon.db.profile.buffIcon.enable = value
                                addon:RefreshViewer()
                                if not value then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                layoutHeader = {
                    order = 0.5,
                    name = "Layout Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_1 = {
                    order = 1,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        iconLimit = {
                            order = 1,
                            name = "Icon Per Line",
                            desc = "Number of icons to display per row/column before creating a new row/column.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.iconLimit
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.iconLimit = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 20,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        isHorizontal = {
                            order = 2,
                            name = "Orientation",
                            desc = "Choose whether the icons are laid out horizontally or vertically.",
                            type = "select",
                            values = orientation,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.isHorizontal + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.isHorizontal = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        growthDirection = {
                            order = 3,
                            name = "Direction",
                            desc = "Choose the direction in which icons grow.",
                            type = "select",
                            values = direction,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.growthDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.growthDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        secondDirection = {
                            order = 4,
                            name = "Multi-Row/Column Direction",
                            desc = "Choose the direction in which new rows/columns are created when the icon limit is reached.",
                            type = "select",
                            values = secondDirection,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.secondDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.secondDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        centerDistribution = {
                            order = 5,
                            name = "Center Multi-Row/Column",
                            desc = "When enabled, rows/columns with fewer icons will be centered instead of left/top aligned.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.centerDistribution
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.centerDistribution = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        padding = {
                            order = 6,
                            name = "Horizontal Padding",
                            desc = "Adjust the horizontal spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.padding
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.padding = value
                                addon:RefreshViewer()
                            end,
                            min = -50,
                            max = 50,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        paddingY = {
                            order = 7,
                            name = "Vertical Padding",
                            desc = "Adjust the vertical spacing between icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.paddingY
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.paddingY = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showWhenInactive = {
                            order = 8,
                            name = "Show When Inactive",
                            desc = "When enabled, the icons will be visible even when there are no active buffs to display.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showWhenInactive
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showWhenInactive = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        desaturateWhenInactive = {
                            order = 9,
                            name = "Desaturate When Inactive",
                            desc = "When enabled, icons will appear desaturated when there are no active buffs to display.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.desaturateWhenInactive
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.desaturateWhenInactive = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        dynamicUpdate = {
                            order = 10,
                            name = "Dynamic Display",
                            desc = "Position of icons are dynamically updated based on active buffs.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.dynamicDisplayUpdate
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.dynamicDisplayUpdate = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        --[[ findSpacing = {
                            order = 10,
                            name = "Find Spacing to Fit the Personal Resource Display Length",
                            desc =
                            " Calculates and outputs the spacing value needed to fit the icons within the current frame width based on your icon width, scale, and icons per line settings. Note: This assume that the viewer is anchored to the personal resource display and inherits its scale.",
                            type = "execute",
                            func = function()
                                local width = PersonalResourceDisplayFrame:GetWidth()
                                local scale = PersonalResourceDisplayFrame:GetScale()

                                local iconWidth = addon.db.profile.buffIcon.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.buffIcon.layout.global.iconWidth or
                                    addon.db.profile.buffIcon.layout[addon.db.global.playerSpec].iconWidth
                                local iconScale = addon.db.profile.buffIcon.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.buffIcon.layout.global.scale or addon.db.profile.buffIcon.layout[addon.db.global.playerSpec]
                                    .scale
                                local iconLimit = addon.db.profile.buffIcon.layout[addon.db.global.playerSpec].useGlobalSettings and addon.db.profile.buffIcon.layout.global.iconLimit or
                                    addon.db.profile.buffIcon.layout[addon.db.global.playerSpec].iconLimit

                                local totalIconWidth = (iconWidth * iconScale) * iconLimit
                                local totalFrameWidth = (width + 4) * scale

                                if totalIconWidth > totalFrameWidth then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", "Icons exceed the frame width. Please lower the icon width, scale, or icon per line.")
                                    return
                                end

                                local spacing = (totalFrameWidth - totalIconWidth) / ((iconLimit - 1) * iconScale)
                                print("|cff0099ccCooldown Manager|r Control" .. ": ", "Calculated Spacing is " .. string.format("%.2f", spacing))
                            end,
                            width = "full",
                            --dialogControl = "DeleteButton",
                        }, ]]
                    },
                },
                iconHeader = {
                    order = 1.5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_2 = {
                    order = 2,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 1,
                            name = "Scale",
                            desc = "Adjust the overall scale of the buff icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.scale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.scale = value
                                addon:RefreshViewer()
                            end,
                            min = 0.05,
                            max = 5,
                            step = 0.05,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconWidth = {
                            order = 2,
                            name = "Icon Width",
                            desc = "Set the width of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.iconWidth
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.iconWidth = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 3,
                            name = "Icon Height",
                            desc = "Set the height of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.iconHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.iconHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 4,
                            name = "Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showIconOverlay
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showIconOverlay = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showDebuffBorder = {
                            order = 4.5,
                            name = "Show Debuff Border",
                            desc = "By default a colored border is shown around debuffs to indicate the type of debuff.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showDebuffBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showDebuffBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 5,
                            name = "Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showIconBorder = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 6,
                            name = "Remove Icon Mask",
                            desc = "Remove the default icon mask to have square icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.removeMask
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                if not value then
                                    db.removeMask = value
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                    --StaticPopup_Show("CMC_RELOADUI")
                                else
                                    db.removeMask = value
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
                            name = "Add Custom Border",
                            desc = "Create a thin border around icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.addPixelBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.addPixelBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 8,
                            name = "— Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.pixelBorderSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.pixelBorderSize = value
                                addon:RefreshViewer()
                            end,
                            min = 0,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 9,
                            name = "— Border Color",
                            desc = "Choose the color of the custom border.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                local input = db.pixelBorderColor
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
                                local db = addon.db.profile.buffIcon.layout
                                local input = db.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 10.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        overridePandemicIcon = {
                            order = 11,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.overridePandemicIcon = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 12,
                            name = "—  Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStyles,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.pandemicGlowType = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 13,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants..",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                local input = db.pandemicColor
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
                                local db = addon.db.profile.buffIcon.layout
                                local input = db.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                textHeader = {
                    order = 2.5,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_3 = {
                    order = 3,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        showCooldown = {
                            order = 1,
                            name = "Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on icons.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showCooldown
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showCooldown = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.cooldownScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.cooldownScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 30,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 4.1,
                            name = "— Cooldown Position",
                            desc = "Choose the position of the cooldown text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                local index = addon:GetIndex(db.iconCooldownPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.iconCooldownPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 4.3,
                            name = "Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                local index = addon:GetIndex(db.applicationPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.applicationPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4.2,
                            name = "Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffIcon.layout
                                return db.countScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.countScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 30,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },

                        --[[ showTooltip = {
                            order = 13,
                            name = "Show Tooltip",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffIcon.layout
                                return db.showTooltip
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffIcon.layout
                                db.showTooltip = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                    },
                },
            },
        },
        BuffBar = {
            order = 4,
            name = "Buff Bar",
            type = "group",
            args = {
                group_0 = {
                    order = 0,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        enable = {
                            order = 0,
                            name = "Enable Module",
                            desc = "When enabled, Buff Bars will show the viewer with your configured settings. When disabled, the viewer will ignore all settings.",
                            type = "toggle",
                            get = function(info)
                                return addon.db.profile.buffBar.enable
                            end,
                            set = function(info, value)
                                addon.db.profile.buffBar.enable = value
                                addon:RefreshViewer()
                                if not value then
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                layoutHeader = {
                    order = 0.5,
                    name = "Layout Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_1 = {
                    order = 1,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        iconLimit = {
                            order = 1,
                            name = "Bar Per Line",
                            desc = "Number of bars to display per row/column before creating a new row/column.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.iconLimit
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.iconLimit = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 20,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        displayType = {
                            order = 2,
                            name = "Display Style",
                            desc = "Choose how the icon-bar are displayed.",
                            type = "select",
                            values = barStyle,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.displayType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.displayType = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        isHorizontal = {
                            order = 3,
                            name = "Orientation",
                            desc = "Choose whether the bars are laid out horizontally or vertically.",
                            type = "select",
                            values = orientation,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.isHorizontal + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.isHorizontal = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        growthDirection = {
                            order = 4,
                            name = "Direction",
                            desc = "Choose the primary growth direction of the bars.",
                            type = "select",
                            values = direction,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.growthDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.growthDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        secondDirection = {
                            order = 5,
                            name = "Multi-Row/Column Direction",
                            desc = "Choose the direction in which new rows/columns are added when the bar per line limit is reached.",
                            type = "select",
                            values = secondDirection,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.secondDirection + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.secondDirection = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        centerDistribution = {
                            order = 6,
                            name = "Center Multi-Row/Column",
                            desc = "When enabled, rows/columns with fewer bars will be centered instead of left/top aligned.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.centerDistribution
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.centerDistribution = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        padding = {
                            order = 7,
                            name = "Horizontal Padding",
                            desc = "Adjust the horizontal spacing between bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.padding
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.padding = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        paddingY = {
                            order = 8,
                            name = "Vertical Padding",
                            desc = "Adjust the vertical spacing between bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.paddingY
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.paddingY = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showWhenInactive = {
                            order = 9,
                            name = "Show When Inactive",
                            desc = "When enabled, the buff bar will be visible even when there are no active buffs to display.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showWhenInactive
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showWhenInactive = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        desaturateWhenInactive = {
                            order = 10,
                            name = "Desaturate When Inactive",
                            desc = "When enabled, icons and bars will appear desaturated when there are no active buffs to display.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.desaturateWhenInactive
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.desaturateWhenInactive = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        dynamicUpdate = {
                            order = 11,
                            name = "Dynamic Display",
                            desc = "Position of bars are dynamically updated based on active buffs.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.dynamicDisplayUpdate
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.dynamicDisplayUpdate = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                    },
                },
                frameHeader = {
                    order = 1.5,
                    name = "Frame Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_2 = {
                    order = 2,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 7,
                            name = "Scale (Overall)",
                            desc = "Adjust the overall scale of the items, i.e. the combo bar and icon.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.scale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.scale = value
                                addon:RefreshViewer()
                            end,
                            min = 0.05,
                            max = 5,
                            step = 0.05,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        barIconSpacing = {
                            order = 11.5001,
                            name = "Icon-Bar Spacing",
                            desc = "Adjust the spacing between the icon and the bar.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.barIconSpacing
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barIconSpacing = value
                                addon:RefreshViewer()
                            end,
                            min = -20,
                            max = 20,
                            step = 0.1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                    },
                },
                iconHeader = {
                    order = 2.5,
                    name = "Icon Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_3 = {
                    order = 3,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        iconWidth = {
                            order = 1,
                            name = "Icon Width",
                            desc = "Set the width of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.iconWidth
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.iconWidth = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        iconHeight = {
                            order = 2,
                            name = "Icon Height",
                            desc = "Set the height of the icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.iconHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.iconHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showIconOverlay = {
                            order = 3,
                            name = "Show Icon Overlay",
                            desc = "Show/Hide the shadow overlay on icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showIconOverlay
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showIconOverlay = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showDebuffBorder = {
                            order = 3.5,
                            name = "Show Debuff Border",
                            desc = "By default a colored border is shown around debuffs to indicate the type of debuff.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showDebuffBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showDebuffBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        showIconBorder = {
                            order = 4,
                            name = "Show Icon Border",
                            desc = "Base behavior shows a kind of border only when out of range. You can change that behavior here.",
                            type = "select",
                            values = iconBorderVisibility,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showIconBorder + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showIconBorder = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        removeMask = {
                            order = 5,
                            name = "Remove Icon Mask",
                            desc = "Remove the default icon mask to have square icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.removeMask
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                if not value then
                                    db.removeMask = value
                                    print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the viewer.")
                                else
                                    db.removeMask = value
                                    addon:RefreshViewer()
                                end
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        subHeader = {
                            order = 5.5,
                            name = "Border Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorder = {
                            order = 6,
                            name = "Add Custom Border",
                            desc = "Create a thin border around icons",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.addPixelBorder
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.addPixelBorder = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSize = {
                            order = 7,
                            name = "— Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.pixelBorderSize
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.pixelBorderSize = value
                                addon:RefreshViewer()
                            end,
                            min = 0,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColor = {
                            order = 8,
                            name = "— Border Color",
                            desc = "Choose the color of the custom border.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pixelBorderColor
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
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pixelBorderColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pixelBorderColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
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
                    order = 3.5,
                    name = "Bar Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_4 = {
                    order = 4,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {
                        retexture = {
                            order = 1,
                            name = "Override Texture",
                            desc = "Enable to override the default bar texture with a custom one. Full path required.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.barTextureOverride
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barTextureOverride = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        texture = {
                            order = 2,
                            name = "",
                            desc = "",
                            type = "input",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.barTexture
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barTexture = value
                                addon:RefreshViewer()
                            end,
                            width = "full",
                            dialogControl = "DF_EditBox",
                        },
                        recolor = {
                            order = 3,
                            name = "Override Color",
                            desc = "Enable to override the default bar color with a custom one.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.barColorOverride
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barColorOverride = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        color = {
                            order = 4,
                            name = "",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local input = db.barColor
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
                                local db = addon.db.profile.buffBar.layout
                                local input = db.barColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.barColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.barColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = false,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        classColor = {
                            order = 5,
                            name = "— Class Color",
                            desc = "Use class color for the bars instead as a custom color.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.classColor
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.classColor = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        barWidth = {
                            order = 6,
                            name = "Bar Width",
                            desc = "Set the width of the bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.barWidth
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barWidth = value
                                addon:RefreshViewer()
                            end,
                            min = 50,
                            max = 400,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        barHeight = {
                            order = 7,
                            name = "Bar Height",
                            desc = "Set the height of the bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.barHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 5,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        showPip = {
                            order = 7.5,
                            name = "Show Progress Spark",
                            desc = "Display a spark effect on the bar to indicate progress.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showPip
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showPip = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pipHeight = {
                            order = 8,
                            name = "Pip Height",
                            desc = "Set the height of the progress spark.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.pipHeight
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.pipHeight = value
                                addon:RefreshViewer()
                            end,
                            min = 1,
                            max = 100,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        subHeader = {
                            order = 9.5,
                            name = "Border/Background Settings",
                            type = "header",
                            dialogControl = "DF_Sub_Header",
                        },
                        addPixelBorderBar = {
                            order = 10,
                            name = "Add Custom Border",
                            desc = "Create a thin border around bars",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.addPixelBorderBar
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.addPixelBorderBar = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pixelBorderSizeBar = {
                            order = 11,
                            name = "— Border Size",
                            desc = "Adjust the thickness of the custom border.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.pixelBorderSizeBar
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.pixelBorderSizeBar = value
                                addon:RefreshViewer()
                            end,
                            min = 0,
                            max = 10,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        pixelBorderColorBar = {
                            order = 12,
                            name = "— Border Color",
                            desc = "Choose the color of the custom border.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pixelBorderColorBar
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
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pixelBorderColorBar
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pixelBorderColorBar = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pixelBorderColorBar = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        showBackground = {
                            order = 12.5,
                            name = "Show Default Background",
                            desc = "Enable/Disable the background of the bars.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showBackground
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showBackground = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        customBackground = {
                            order = 13,
                            name = "Add Custom Background",
                            desc = "Create a custom background texture for bars",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.customBackground
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.customBackground = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        backgroundColor = {
                            order = 14,
                            name = "",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local input = db.backgroundColor
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
                                local db = addon.db.profile.buffBar.layout
                                local input = db.backgroundColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.backgroundColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.backgroundColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                        subHeader2 = {
                            order = 15.5,
                            name = "Animation Settings",
                            type = "header",
                            dialogControl = "DF_Header",
                        },
                        overridePandemicIcon = {
                            order = 16,
                            name = "Override Pandemic Fx",
                            desc = "Override the default pandemic effect with custom settings",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.overridePandemicIcon
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.overridePandemicIcon = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        pandemicGlowType = {
                            order = 17,
                            name = "— Pandemic Style",
                            desc = "Choose the style of the pandemic glow effect. May require the additional border.",
                            type = "select",
                            values = pandemicStylesBar,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.pandemicGlowType + 1
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.pandemicGlowType = value - 1
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        pandemicColor = {
                            order = 18,
                            name = "— Pandemic Color",
                            desc = "Only used by border color and pixel ants.",
                            type = "color",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pandemicColor
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
                                local db = addon.db.profile.buffBar.layout
                                local input = db.pandemicColor
                                local hex = input:gsub('#', '')
                                if #hex == 8 then
                                    db.pandemicColor = string.format("#%02X%02X%02X%02X", a * 255, r * 255, g * 255, b * 255)
                                elseif #hex == 6 then
                                    db.pandemicColor = string.format("#%02X%02X%02X", r * 255, g * 255, b * 255)
                                end
                                addon:RefreshViewer()
                            end,
                            hasAlpha = true,
                            width = "full",
                            dialogControl = "DF_ColorPicker",
                        },
                    },
                },
                textHeader = {
                    order = 4.5,
                    name = "Text and Toggle Settings",
                    type = "header",
                    dialogControl = "DF_Header",
                },
                group_5 = {
                    order = 5,
                    name = "",
                    type = "group",
                    inline = true,
                    args = {

                        showCooldown = {
                            order = 1,
                            name = "Show Cooldown",
                            desc = "Toggle the visibility of cooldown text on bars.",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showCooldown
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showCooldown = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        },
                        cooldownScale = {
                            order = 2,
                            name = "— Cooldown Font Size",
                            desc = "Adjust the font size for cooldown display on bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.cooldownScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.cooldownScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 30,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ cooldownPosition = {
                            order = 4.1,
                            name = "— Cooldown Position",
                            desc = "Choose the position of the cooldown text on the bar.",
                            type = "select",
                            values = barTextPositions,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local index = addon:GetIndex(db.barCooldownPosition, barTextPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barCooldownPosition = barTextPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        applicationPosition = {
                            order = 4.3,
                            name = "Charge Position",
                            desc = "Choose the position of the charge/stack text on the icon.",
                            type = "select",
                            values = textPositions,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local index = addon:GetIndex(db.applicationPosition, textPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.applicationPosition = textPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        },
                        countScale = {
                            order = 4.2,
                            name = "Charge/Count Font Size",
                            desc = "Adjust the font size for charge/count display on icons.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.countScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.countScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 30,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },
                        --[[ namePosition = {
                            order = 14,
                            name = "Name Position",
                            desc = "Choose the position of the spell text on the bar.",
                            type = "select",
                            values = barTextPositions,
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                local index = addon:GetIndex(db.barNamePosition, barTextPositions)
                                return index
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.barNamePosition = barTextPositions[value]
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Dropdown",
                            width = "full",
                        }, ]]
                        nameScale = {
                            order = 13,
                            name = "Name Font Size",
                            desc = "Adjust the font size for the name displayed on bars.",
                            type = "range",
                            get = function()
                                local db = addon.db.profile.buffBar.layout
                                return db.nameScale
                            end,
                            set = function(_, value)
                                local db = addon.db.profile.buffBar.layout
                                db.nameScale = value
                                addon:RefreshViewer()
                            end,
                            min = 6,
                            max = 30,
                            step = 1,
                            width = "full",
                            dialogControl = "DF_Slider",
                        },

                        --[[ showTooltip = {
                            order = 16,
                            name = "Show Tooltip",
                            type = "toggle",
                            get = function(info)
                                local db = addon.db.profile.buffBar.layout
                                return db.showTooltip
                            end,
                            set = function(info, value)
                                local db = addon.db.profile.buffBar.layout
                                db.showTooltip = value
                                addon:RefreshViewer()
                            end,
                            dialogControl = "DF_Checkbox_Left_Label",
                            width = "full",
                        }, ]]
                    },
                },
            },
        },
    }
}

function addon:GetLayoutOptions()
    return option
end

function addon:GetEssentialLayoutOptions()
    return option.args.Essential
end

function addon:GetUtilityLayoutOptions()
    return option.args.Utility
end

function addon:GetBuffIconLayoutOptions()
    return option.args.BuffIcon
end

function addon:GetBuffBarLayoutOptions()
    return option.args.BuffBar
end
