 function Madhouse.addon:SettingsAddChest()
    local Options = Madhouse.widgets.SettingsWindow.Frame.frame
    local OptionsFrame= {}
	local sf = OptionsFrame.ChestFrame or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.ChestFrame = sf
	sf:SetPoint("TOPLEFT")
	sf:SetPoint("BOTTOMRIGHT")

	sf.C = sf.C or CreateFrame("Frame", nil, sf)
	sf:SetScrollChild(sf.C)
	sf.C:SetSize(Options:GetWidth(),Options:GetHeight())

	local SCALE = 0.4

	local captured
	local function AddCaptured()
		if captured then
			return captured
		end

		-- local data = list[math.random(1,#list)]
		local data = Madhouse.static.stopMotion[1]
		captured = Madhouse.API.v1.ShowStopMotion(data)
	end

	local chest = CreateFrame("Button",nil,sf.C)
	OptionsFrame.chestBut = chest
	chest:SetSize(175*SCALE,130*SCALE)
	local x,y = math.random(130,Options:GetWidth()-175*SCALE),math.random(0,Options:GetHeight()-130*SCALE)
	chest:SetPoint("TOPLEFT",x,-y)
	chest:RegisterForClicks("LeftButtonDown","RightButtonDown")
	chest:SetScript("OnClick",function(self,button)
		AddCaptured()
		captured:Show()
		self:Hide()
	end)
	chest.t = chest:CreateTexture()
	chest.t:SetAllPoints()
	chest.t:SetAtlas("ChallengeMode-Chest")

	chest:RotateTextures(math.pi*2/360*(math.random(0,360)))
end
