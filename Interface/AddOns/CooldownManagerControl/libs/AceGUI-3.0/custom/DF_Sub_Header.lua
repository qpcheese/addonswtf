--[[-----------------------------------------------------------------------------
Heading Widget
-------------------------------------------------------------------------------]]
local Type, Version = "DF_Sub_Header", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

local function DisplayCorners(frame)
	if not frame.cornerTextures then
		frame.cornerTextures = {}

		if not frame.backgroundTexture then
			frame.backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
			frame.backgroundTexture:SetColorTexture(0.5, 0.5, 0.5, 0.5)
			frame.backgroundTexture:SetAllPoints(frame)
		end
		for i = 1, 4 do
			frame.cornerTextures[i] = frame:CreateTexture(nil, "OVERLAY")
			frame.cornerTextures[i]:SetSize(5, 5)
		end
	end

	local r = math.random()
	local g = math.random()
	local b = math.random()

	local positions = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }
	for i, point in ipairs(positions) do
		frame.cornerTextures[i]:SetColorTexture(r, g, b, 1) -- Random color
		frame.cornerTextures[i]:SetPoint(point, frame, point, 0, 0)
	end
end


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetText()
		self:SetFullWidth()
		self:SetHeight(40)
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.label:SetText(text or "")
		if text and text ~= "" then
			--self.left:SetPoint("RIGHT", self.label, "LEFT", -5, 0)
			--self.right:Show()
		else
			self.right:SetPoint("RIGHT", -3, 0)
			--self.right:Hide()
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightHuge")
	label:SetPoint("LEFT",frame,"LEFT", 50, 0)
	label:SetJustifyH("CENTER")

	--[[ local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(15)
	left:SetPoint("LEFT", 3, 0)
	left:SetPoint("RIGHT", label, "LEFT", -5, 0)
	left:SetAtlas("_UI-HUD-ActionBar-Frame-Divider-Threeslice-Center") -- Interface\\Tooltips\\UI-Tooltip-Border ]]
	--left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(15)
	right:SetPoint("RIGHT", -3, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetAtlas("_UI-HUD-ActionBar-Frame-Divider-Threeslice-Center") -- Interface\\Tooltips\\UI-Tooltip-Border
	--right:SetTexCoord(0.81, 0.94, 0.5, 1)

	local widget = {
		label = label,
		left  = left,
		right = right,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
