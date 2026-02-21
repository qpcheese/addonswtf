function Madhouse.addon:OnInitialize()
    self:OnAddonLoaded()
    self:SetupHooks()
    self:PrintStartMessage()
    self:SetupOptionsPanel()
    self:LoadSoundpack()
    self:LoadTextures()
    self:SetupMinimap()
    self:SetupBackground()
    self:SetupWindow("CurrencyWindow")
    self:SetupWindow("UpgradeWindow")
    self:SetupWindow("RatingWindow")
    self:SetupWindow("PortalRoomWindow")
    self:SetupWindow("CharStatWindow")
    self:SetupWindow("FarmingWindow")
    self:SetupWindow("AchivementWindow")
    self:SetupWindow("WindowManager")
    self:SetupWindow("PortalWindow", true)
    Madhouse.trigger.INIT()
    Madhouse.trigger.INIT_META()
    -- TODO: Implement by Option Menu

    if Madhouse.addon:LoadGlobalData("settings-oldman-cursor", false) then
        Madhouse.feature.OldManCursor.show()
    end
    -- Madhouse.feature.SimpleActionBar.setup()
end

local function MyHPCommandHandler(msg, editBox)
    Madhouse.widgets.SettingsWindow:Togle()
end

-- Register the slash command
SLASH_MHP1,SLASH_MHP2 = "/mhp", "/madhouse"
SlashCmdList["MHP"] = MyHPCommandHandler
