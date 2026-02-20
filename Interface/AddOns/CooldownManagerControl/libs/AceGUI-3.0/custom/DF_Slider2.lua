local Type, Version = "DF_Slider_2", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local min, max, floor = math.min, math.max, math.floor
local tonumber, pairs = tonumber, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function UpdateText(self)
	local value = self.value or 0
	if self.ispercent then
		self.editbox:SetText(("%s%%"):format(floor(value * 1000 + 0.5) / 10))
	else
		self.editbox:SetText(floor(value * 100 + 0.5) / 100)
	end
end

local function RoundInteger(value)
	return RoundToSignificantDigits(value, 0);
end

local function RoundOneDecimal(value)
	return RoundToSignificantDigits(value, 1);
end

local function RoundTwoDecimal(value)
	return RoundToSignificantDigits(value, 2);
end

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
Scripts
-------------------------------------------------------------------------------]]
local function OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function OnMouseDown(frame)
	AceGUI:ClearFocus()
end

local function OnValueChanged(frame, newvalue)
	local self = frame.obj
	if not frame.setup then
		if self.step and self.step > 0 then
			local min_value = self.min or 0
			newvalue = floor((newvalue - min_value) / self.step + 0.5) * self.step + min_value
		end
		if newvalue ~= self.value and not self.disabled then
			self.value = newvalue
			self:Fire("OnValueChanged", newvalue)
		end
		if self.value then
			UpdateText(self)
		end
	end
	frame.RightText:Hide()
end

local function OnMouseUp(frame)
	local self = frame.obj
	self:Fire("OnMouseUp", self.value)
end

local function EditBox_OnEscapePressed(frame)
	frame:ClearFocus()
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local value = frame:GetText()
	if self.ispercent then
		value = value:gsub('%%', '')
		value = tonumber(value) / 100
	else
		value = tonumber(value)
	end

	if value then
		self.slider:SetValue(value)
		self:Fire("OnMouseUp", value)
	end
end

local function EditBox_OnEnter(frame)
	frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function EditBox_OnLeave(frame)
	frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(200)
		self:SetHeight(28)
		self:SetDisabled(false)
		self:SetIsPercent(nil)
		self:SetSliderValues(0, 100, 1)
		self:SetValue(0)
	end,

	["OnRelease"] = function(self)
		local frame = self.slider
		if frame.OnValueChangedCallback then
			frame:UnregisterCallback("OnValueChanged", frame.OnValueChangedCallback)
		end
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.slider:EnableMouse(false)
			self.label:SetTextColor(.5, .5, .5)
			self.editbox:SetTextColor(.5, .5, .5)
			self.editbox:EnableMouse(false)
			self.editbox:ClearFocus()
		else
			self.slider:EnableMouse(true)
			self.label:SetTextColor(1, .82, 0)
			self.editbox:SetTextColor(1, 1, 1)
			self.editbox:EnableMouse(true)
		end
	end,

	["SetValue"] = function(self, value)
		self.slider.setup = true
		self.slider:SetValue(value)
		self.value = value
		UpdateText(self)
		self.slider.setup = nil
	end,

	["GetValue"] = function(self)
		return self.value
	end,

	["SetLabel"] = function(self, text)
		self.label:SetText(text)
	end,

	["SetSliderValues"] = function(self, min_value, max_value, step)
		local formatters = {}
		local format = MinimalSliderWithSteppersMixin.Label.Right

		if step and step >= 1 then
			formatters[format] = CreateMinimalSliderFormatter(format, RoundInteger)
		elseif step and step > 0.1 and step < 1 then
			formatters[format] = CreateMinimalSliderFormatter(format, RoundOneDecimal)
		elseif step and step < 0.1 and step > 0 then
			formatters[format] = CreateMinimalSliderFormatter(format, RoundTwoDecimal)
		end

		local frame = self.slider
		frame.setup = true
		self.min = min_value
		self.max = max_value
		self.step = step

		frame:Init(self.value or 0, self.min, self.max, (self.max - self.min) / self.step, formatters)
		
		if not frame._onValueChangedRegistered then
			frame:RegisterCallback("OnValueChanged", function(_, newvalue)
				OnValueChanged(frame, newvalue)
			end)
			frame._onValueChangedRegistered = true
		end

		frame.RightText:Hide()

		if self.value then
			frame:SetValue(self.value)
		end
		frame.setup = nil
	end,

	["SetIsPercent"] = function(self, value)
		self.ispercent = value
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local ManualBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true,
	edgeSize = 1,
	tileSize = 5,
}

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", OnMouseDown)

	-- Slider header
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOPLEFT", 0, 0)
	label:SetPoint("TOPRIGHT", 0, 0)
	label:SetJustifyH("CENTER")
	label:SetHeight(28)
	label:SetScript("OnEnter", OnEnter)
	label:SetScript("OnLeave", OnLeave)

	-- Slider
	local slider = CreateFrame("Slider", nil, frame, "MinimalSliderWithSteppersTemplate")
	slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT")
	slider:SetPoint("LEFT", 3, 0)
	slider:SetPoint("RIGHT", -3, 0)
	slider:SetScript("OnValueChanged", OnValueChanged)
	slider:SetScript("OnMouseUp", OnMouseUp)
	slider:SetHeight(15)

	local editbox = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
	editbox:SetAutoFocus(false)
	editbox:SetFontObject(GameFontHighlightSmall)
	editbox:SetPoint("TOP", slider, "BOTTOM")
	editbox:SetHeight(22)
	editbox:SetWidth(70)
	editbox:SetJustifyH("CENTER")
	editbox:EnableMouse(true)
	editbox:SetBackdrop(ManualBackdrop)
	editbox:SetBackdropColor(0, 0, 0, 0.5)
	editbox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
	editbox:SetScript("OnEnter", EditBox_OnEnter)
	editbox:SetScript("OnLeave", EditBox_OnLeave)
	editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)

	--[[ DisplayCorners(frame)
	DisplayCorners(slider)
	DisplayCorners(editbox)
 ]]
	local widget = {
		label       = label,
		slider      = slider,
		editbox     = editbox,
		alignoffset = 30,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	slider.obj, editbox.obj, label.obj = widget, widget, widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
