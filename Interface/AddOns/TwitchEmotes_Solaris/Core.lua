
---@diagnostic disable: deprecated
TwitchEmotes_Solaris = LibStub("AceAddon-3.0"):NewAddon("TwitchEmotes_Solaris", "AceConsole-3.0", "AceEvent-3.0")
local AddonName = ...

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local _ = nil

local default_db = {
    profile = {
        minimap = {
            hide = true,
        },
        features = {
            autocomplete = {
                enabled = true,
                with_tab = false, -- TODO
            }
        }
    }
}

-- Create minimap button
local minimapHeadingColor = "|cFFFFFFFF"
local minimapIconRegistered = false

local TES_LDB = LDB:NewDataObject("TwitchEmotes_Solaris", {
    type = "data source",
    text = "Twitch Emotes Solaris",
    icon = "Interface\\AddOns\\TwitchEmotes_Solaris\\logo",
    OnClick = function(_, buttonPressed)
        if buttonPressed == "RightButton" then
            TwitchEmotes_Solaris:ToggleMinimapLock()
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then
            return
        end
        tooltip:AddLine(minimapHeadingColor .. "Twitch Emotes Solaris|r")
        --tooltip:AddLine("Click to toggle AddOn Window")
        tooltip:AddLine(" ")
        tooltip:AddLine("Right-click to lock Minimap Button")
        tooltip:AddLine("To toggle minimap button, type /tes minimap")
        tooltip:AddLine("More features to come in the future!")
    end
})

--Init
function TwitchEmotes_Solaris:OnInitialize()
    --Register DB
    TwitchEmotes_Solaris:RegisterDatabase()

    LDBIcon:Register("TwitchEmotes_Solaris", TES_LDB, self.db.profile.minimap)

    --Register UI Options
    TwitchEmotes_Solaris:RegisterOptions()

    --Load Features
    TwitchEmotes_Solaris:ToggleMinimapButton()
    TwitchEmotes_Solaris:SetAutoComplete(self.db.profile.features.autocomplete.enabled)

    --Register chat commands
    TwitchEmotes_Solaris:RegisterChatCommand("tes", "SlashCommand")
	TwitchEmotes_Solaris:RegisterChatCommand("twitchemotessolaris", "SlashCommand")
end

function TwitchEmotes_Solaris:SlashCommand(msg)
    if not msg or msg:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end

    if msg == "minimap" then
        TwitchEmotes_Solaris:ToggleMinimapButton(_, self.db.profile.minimap.hide)
    end
end

function TwitchEmotes_Solaris:RegisterDatabase()
    self.db = LibStub("AceDB-3.0"):New("TwitchEmotes_Solaris_Settings", default_db, true)
end


function TwitchEmotes_Solaris:RegisterOptions()
    local options = {
        name = "Twitch Emotes Solaris",
        handler = TwitchEmotes_Solaris,
        type = "group",
        args = {
            enable = {
                type = 'toggle',
                name = "Enable Minimap Button",
                desc = "If the Minimap Button is enabled",
                get = "IsMinimapButtonShown",
                set = "ToggleMinimapButton",
                order = 1,
                width = "full"
            },
            locked = {
                type = 'toggle',
                name = "Lock Minimap Button",
                desc = "If the Minimap Button is locked",
                get = "IsMinimapLocked",
                set = "ToggleMinimapLock",
                order = 2,
                width = "full"
            }
        }
    }

    AC:RegisterOptionsTable("TwitchEmotes_Solaris_options", options)
    self.optionsFrame = ACD:AddToBlizOptions("TwitchEmotes_Solaris_options", "TwitchEmotes_Solaris")
end

function TwitchEmotes_Solaris:IsMinimapButtonShown(info)
    return not self.db.profile.minimap.hide
end

function TwitchEmotes_Solaris:ToggleMinimapButton(_,toggle)
    if (toggle ~= nil) then
        self.db.profile.minimap.hide = not toggle
    end

    if(self.db.profile.minimap.hide) then
        LDBIcon:Hide("TwitchEmotes_Solaris")
    else
        LDBIcon:Show("TwitchEmotes_Solaris")
    end
end

function TwitchEmotes_Solaris:IsMinimapLocked(info)
    return self.db.profile.minimap.lock
end

function TwitchEmotes_Solaris:ToggleMinimapLock(info)
    if(self.db.profile.minimap.lock) then
        LDBIcon:Unlock("TwitchEmotes_Solaris")
    else
        LDBIcon:Lock("TwitchEmotes_Solaris")
    end

end
