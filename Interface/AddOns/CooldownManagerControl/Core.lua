local addonName, addonTable = ...

addonTable.Core             = LibStub("AceAddon-3.0"):NewAddon("CooldownManagerControl", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceHook-3.0")

local addon                 = addonTable.Core
local aceConfig             = LibStub("AceConfig-3.0")
local aceConfigDialog       = LibStub("AceConfigDialog-3.0")
local LibEditModeOverride   = LibStub("LibEditModeOverride-1.0")

function addon:OnInitialize()
    -- Register slash command
    self:RegisterChatCommand("cmc", "OptionCmd")
    self:RegisterChatCommand("cmc-rebuild", "BuildCooldownIDCache")
    self:LoadData()
end

function addon:OnEnable()
    addon.db.global.playerClass = select(2, UnitClass("player"))
    local specIndex = C_SpecializationInfo.GetSpecialization()
    addon.db.global.playerSpec = specIndex and select(1, C_SpecializationInfo.GetSpecializationInfo(specIndex)) or nil

    -- EventRegistry callbacks for settings open/close
    EventRegistry:RegisterCallback("CooldownViewerSettings.OnShow", function()
        addon:RefreshViewer()
        EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
            --print("CooldownViewerSettings.OnDataChanged triggered")
            addon:RefreshViewer()
            addon:GetOverrideOptions()
            if addonTable.GUI and addonTable.GUI:IsShown() and addonTable.GUI.activeTab then
                aceConfigDialog:Open(addonTable.GUI.activeTab, addonTable.GUI.container)
            end
        end, self)
    end, self)

    EventRegistry:RegisterCallback("CooldownViewerSettings.OnHide", function()
        addon:RefreshViewer()
        addon:GetOverrideOptions()
        if addonTable.GUI and addonTable.GUI:IsShown() and addonTable.GUI.activeTab then
            aceConfigDialog:Open(addonTable.GUI.activeTab, addonTable.GUI.container)
        end
        EventRegistry:UnregisterCallback("CooldownViewerSettings.OnDataChanged", self)
    end, self)

    -- Not usable. This will nuke the addon and put the whole cooldownViewer in secret mode
    -- EventRegistry callback for Edit Mode exit to force hide when inactive setting at the viewer level and force always show setting
    --[[ EventRegistry:RegisterCallback("EditMode.Exit", function()
        --print("|cff0099ccCooldown Manager|r Control: Edit Mode exited, applying settings.")
        if LibEditModeOverride:IsReady() then
            LibEditModeOverride:LoadLayouts()
            local changed, value = false, nil

            if addon.db.profile.essential.enable then
                value = LibEditModeOverride:GetFrameSetting(EssentialCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting)
                if value ~= Enum.CooldownViewerVisibleSetting.Always then
                    LibEditModeOverride:SetFrameSetting(EssentialCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
                    changed = true
                end
            end

            if addon.db.profile.utility.enable then
                value = LibEditModeOverride:GetFrameSetting(UtilityCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting)
                if value ~= Enum.CooldownViewerVisibleSetting.Always then
                    LibEditModeOverride:SetFrameSetting(UtilityCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
                    changed = true
                end
            end

            if addon.db.profile.buffIcon.enable then
                value = LibEditModeOverride:GetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive)
                if value ~= 1 then
                    LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
                    changed = true
                end

                value = LibEditModeOverride:GetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting)
                if value ~= Enum.CooldownViewerVisibleSetting.Always then
                    LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
                    changed = true
                end
            end

            if addon.db.profile.buffBar.enable then
                value = LibEditModeOverride:GetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive)
                if value ~= 1 then
                    LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
                    changed = true
                end

                value = LibEditModeOverride:GetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting)
                if value ~= Enum.CooldownViewerVisibleSetting.Always then
                    LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
                    changed = true
                end
            end

            if changed then
                --print("|cff0099ccCooldown Manager|r Control: Edit Mode changes detected, applying settings.")
                if not addonTable.isRestricted then
                    addonTable.savedSettings = false
                    LibEditModeOverride:ApplyChanges()
                else
                    print("|cff0099ccCooldown Manager|r Control: ", "Cannot apply Edit Mode Override due to addon restrictions in place.")
                    addonTable.savedSettings = true
                    LibEditModeOverride:SaveOnly()
                end
                addon:RefreshViewer()
            end
        end
    end, self) ]]

    -- EventRegistry callbacks for assisted combat spell highlight changes
    EventRegistry:RegisterCallback("AssistedCombatManager.OnAssistedHighlightSpellChange", function()
        local CVar = C_CVar.GetCVar("assistedCombatHighlight")
        if addon.db.profile.essential.enable and addon.db.profile.essential.layout.showAssistedHighlight and CVar == "1" then
            local spellID = C_AssistedCombat.GetNextCastSpell()
            local correspondingCooldownIDs = addon.db.global.spellIDCache[spellID]

            local itemFrameContainer = EssentialCooldownViewer:GetLayoutChildren()
            local found = nil

            for i = 1, #itemFrameContainer, 1 do
                local itemFrame = itemFrameContainer[i]
                local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

                if not found then
                    if addon:GetIndex(cooldownID, correspondingCooldownIDs or {}) then
                        addon:startAssistedHighlight(itemFrame)
                        found = true
                    else
                        addon:stopAssistedHighlight(itemFrame)
                    end
                else
                    addon:stopAssistedHighlight(itemFrame)
                end
            end
        end
    end, self);

    -- Event registrations
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEntering")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnSpecilizationChanged")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED", "OnTalentChanged")
    self:RegisterEvent("UPDATE_BINDINGS", "OnKeybindUpdate")
    self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "AcitionBarSlotChanged")
    self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED", "OnCombatChanged")
    --self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", "OnAddonRestrictionChanged")

    -- Options
    aceConfig:RegisterOptionsTable("Essential_Layout", self:GetEssentialLayoutOptions())
    aceConfig:RegisterOptionsTable("Utility_Layout", self:GetUtilityLayoutOptions())
    aceConfig:RegisterOptionsTable("BuffIcon_Layout", self:GetBuffIconLayoutOptions())
    aceConfig:RegisterOptionsTable("BuffBar_Layout", self:GetBuffBarLayoutOptions())

    aceConfig:RegisterOptionsTable("Essential_Anchor", self:GetEssentialAnchorOptions())
    aceConfig:RegisterOptionsTable("Utility_Anchor", self:GetUtilityAnchorOptions())
    aceConfig:RegisterOptionsTable("BuffIcon_Anchor", self:GetBuffIconAnchorOptions())
    aceConfig:RegisterOptionsTable("BuffBar_Anchor", self:GetBuffBarAnchorOptions())

    aceConfig:RegisterOptionsTable("Essential_Override", self:GetEssentialOverrideOptions())
    aceConfig:RegisterOptionsTable("Utility_Override", self:GetUtilityOverrideOptions())
    aceConfig:RegisterOptionsTable("BuffIcon_Override", self:GetBuffIconOverrideOptions())
    aceConfig:RegisterOptionsTable("BuffBar_Override", self:GetBuffBarOverrideOptions())

    aceConfig:RegisterOptionsTable("Essential_Item", self:GetEssentialItemOptions())
    aceConfig:RegisterOptionsTable("Utility_Item", self:GetUtilityItemOptions())
    aceConfig:RegisterOptionsTable("BuffIcon_Item", self:GetBuffIconItemOptions())
    aceConfig:RegisterOptionsTable("BuffBar_Item", self:GetBuffBarItemOptions())

    aceConfig:RegisterOptionsTable("CMC_ImportExport", self:ImportExportOptions())
end

function addon:OnDisable()
    self:UnhookAll()
end

function addon:OptionCmd()
    addon:GetOption()
    if not addonTable.GUI:IsShown() then
        addonTable.GUI:Show()
    else
        addonTable.GUI:Hide()
    end

    if InCombatLockdown() or not CooldownViewerSettings then return end

    if not CooldownViewerSettings:IsShown() then
        CooldownViewerSettings:Show()
    else
        CooldownViewerSettings:Hide()
    end
end

AddonCompartmentFrame:RegisterAddon({
    text = "|cff0099ccCooldown Manager|r Control",
    icon = "Interface\\Icons\\inv_misc_wrench_01",
    notCheckable = true,
    func = function()
        addon:OptionCmd()
    end,
})
