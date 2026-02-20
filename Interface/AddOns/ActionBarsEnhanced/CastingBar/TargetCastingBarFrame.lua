local AddonName, Addon = ...

local L = Addon.L
local T = Addon.Templates

local function GetStartOffset(castBar, pip)
    if not castBar or not pip then
        return
    end

    local barLeft = castBar:GetLeft()
    local barRight = castBar:GetRight()
    local pipStart = pip:GetCenter()

    local barWidth = barRight - barLeft

    local pipRel = pipStart - barLeft

    return pipRel
end


local function Hook_UpdateShownState(self)
    if not self then return end
    local frameName = self.boss and "BossTargetFrames" or self:GetName()
    --self:SetWidth(200)
    --self:SetHeight(20)

    ABE_CastingBarMixin.ProcessShieldBorder(self)
    ABE_CastingBarMixin.AdjustPosition(self)
end

local function ProcessEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        local CastBarFrames = {
            "TargetFrameSpellBar",
            "FocusFrameSpellBar",
        }

        for i, framName in ipairs(CastBarFrames) do
            if Addon:GetValue("CastBarEnable", nil, framName) then
                local frame = _G[framName]
                if frame then
                    if frame.UpdateShownState then
                        hooksecurefunc(frame, "UpdateShownState", Hook_UpdateShownState)
                    end
                    ABE_CastingBarMixin.SetHooks(frame)
                end
            end
        end
    end
end

local eventHandlerFrame = CreateFrame('Frame')
eventHandlerFrame:SetScript('OnEvent', ProcessEvent)
eventHandlerFrame:RegisterEvent('PLAYER_LOGIN')