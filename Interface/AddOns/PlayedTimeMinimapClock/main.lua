local brokerPlayedTime = LibStub:GetLibrary("LibDataBroker-1.1"):GetDataObjectByName("Time Played")

local timeManagerFrame = CreateFrame("Frame")
local clockButtonUpdateTooltipHooked = false
timeManagerFrame:RegisterEvent("ADDON_LOADED")
timeManagerFrame:SetScript("OnEvent", function(self, event, ...)

  local name = ...
  if not clockButtonUpdateTooltipHooked and name == "Blizzard_TimeManager" then

    -- The Blizzard UI only updates the TimeManagerClockButton (and with it the tooltip) once per second.
    -- But we want the tooltip to be shown immediately!
    TimeManagerClockButton:HookScript("OnEnter", function()
      TimeManagerClockButton_UpdateTooltip()
    end)


    -- Add PlayedTime to clock button tooltip!
    hooksecurefunc("TimeManagerClockButton_UpdateTooltip", function ()

      if not GameTooltip:IsShown() then return end

      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(" ")

      brokerPlayedTime.OnTooltipShow(GameTooltip)

      -- Adjust tooltip size.
      GameTooltip:Show()
    end)

    -- Add PlayedTime options to right click!
    TimeManagerClockButton:SetScript("OnClick", function (self, button)

      GameTooltip:Hide()

      if button == "RightButton" then
        brokerPlayedTime.OnClick(self, button)
        if TimeManagerFrame:IsVisible() then
          GameTooltip:Hide()
        end
      else
        TimeManagerClockButton_OnClick(self)
        if not TimeManagerFrame:IsVisible() then
          self:GetScript("OnEnter")(self)
        end
      end

    end)

    clockButtonUpdateTooltipHooked = true
  end

end)
