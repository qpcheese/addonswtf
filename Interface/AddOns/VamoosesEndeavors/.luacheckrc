-- luacheck configuration for VamoosesEndeavors
-- WoW Lua 5.1 environment with addon-specific globals

std = "lua51"
max_line_length = false
codes = true

-- Globals DEFINED by this addon
globals = {
    "VE",
    "VE_DB",
    "VE_EndeavorQuotes",
    "SLASH_VE1",
    "SLASH_VE2",
    "SlashCmdList",
}

-- Globals READ by this addon (WoW API + third-party)
read_globals = {
    -- WoW C_* namespaced APIs
    "C_AddOns",
    "C_ChatInfo",
    "C_CurrencyInfo",
    "C_Housing",
    "C_HousingNeighborhood",
    "C_Map",
    "C_NeighborhoodInitiative",
    "C_QuestLog",
    "C_SuperTrack",
    "C_Timer",

    -- Frame creation & UI
    "CreateFrame",
    "CreateFromMixins",
    "CreateColor",
    "CreateAtlasMarkup",
    "CreateVector3D",
    "Mixin",
    "UIParent",
    "GameTooltip",
    "GameTooltip_Hide",
    "Minimap",
    "BackdropTemplateMixin",
    "UISpecialFrames",
    "AddonCompartmentFrame",
    "HousingDashboardFrame",

    -- Animation
    "UIFrameFadeIn",
    "UIFrameFadeOut",

    -- Unit/Player APIs
    "UnitName",
    "UnitGUID",
    "UnitClass",
    "UnitFactionGroup",
    "GetRealmName",
    "GetNormalizedRealmName",
    "GetLocale",
    "InCombatLockdown",
    "GetCursorPosition",

    -- Chat
    "SendChatMessage",
    "GetChannelName",
    "JoinTemporaryChannel",
    "JoinChannelByName",
    "LeaveChannelByName",
    "DEFAULT_CHAT_FRAME",
    "BNGetInfo",

    -- Time
    "GetTime",
    "GetServerTime",
    "time",
    "date",

    -- Sound
    "PlaySound",
    "SOUNDKIT",

    -- Formatting & fonts
    "STANDARD_TEXT_FONT",
    "GameFontNormal",
    "GameFontNormalSmall",
    "GameFontNormalLarge",
    "GameFontHighlightSmall",
    "GameFontHighlightLarge",
    "ChatFontNormal",

    -- Color constants
    "NORMAL_FONT_COLOR",
    "HIGHLIGHT_FONT_COLOR",

    -- Dropdown menus
    "EasyMenu",
    "UIDropDownMenu_Initialize",
    "UIDropDownMenu_AddButton",
    "UIDropDownMenu_CreateInfo",
    "UIDropDownMenu_SetWidth",
    "UIDropDownMenu_SetText",
    "ToggleDropDownMenu",
    "CloseDropDownMenus",

    -- Popup dialogs
    "StaticPopupDialogs",
    "StaticPopup_Show",

    -- System
    "ReloadUI",
    "hooksecurefunc",
    "GetMinimapShape",
    "IsShiftKeyDown",
    "IsControlKeyDown",
    "IsModifiedClick",
    "IsQuestFlaggedCompleted",
    "GetAddOnMemoryUsage",
    "UpdateAddOnMemoryUsage",
    "GetNumQuestLogRewardCurrencies",
    "NUM_CHAT_WINDOWS",
    "ChatFrame_RemoveChannel",

    -- Minimap compat (third-party addons)
    "SexyMapCustomBackdrop",
    "SexyMapSuperTrackerBackground",
    "BasicMinimapSquare",

    -- WoW Lua extensions
    "wipe",
    "tinsert",
    "tremove",
    "strsplit",
    "strtrim",
    "strjoin",
    "format",
    "tContains",

    -- WoW constants
    "Enum",

    -- Shared scheme constants
    "VAMOOSE_SchemeConstants",

    -- Third-party (optional)
    "LibStub",
    "ElvUI",
}

-- Exclude non-code files
exclude_files = {
    "Core/_signatures.lua",
    "Utilities/*",
}

-- Allow unused self parameter (common in WoW OnClick/OnScript patterns)
self = false

-- Ignore specific warnings
ignore = {
    "211/addonName",   -- Unused 'addonName' from varargs
    "212/_.*",         -- Unused variables starting with underscore
    "212/self",        -- Unused self (WoW callback pattern)
    "611",             -- Lines with only whitespace
}
