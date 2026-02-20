local AddonName, Addon = ...

local L = Addon.L
local T = Addon.Templates

local function Hook_UpdateShownState(self)
    if not self then return end
    
    ABE_CastingBarMixin.ProcessShieldBorder(self)
    
    ABE_CastingBarMixin.AdjustPosition(self)
end

local function ProcessEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if BossTargetFrameContainer and Addon:GetValue("CastBarEnable", nil, "BossTargetFrames") then
            for index, bossFrame in ipairs(BossTargetFrameContainer.BossTargetFrames) do
                if bossFrame.spellbar.UpdateShownState then
                    hooksecurefunc(bossFrame.spellbar, "UpdateShownState", Hook_UpdateShownState)
                end
                ABE_CastingBarMixin.SetHooks(bossFrame.spellbar)
            end
        end
    end
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('PLAYER_LOGIN')