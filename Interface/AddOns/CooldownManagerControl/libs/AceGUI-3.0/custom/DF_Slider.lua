local Type, Version = "DF_Slider", 1
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
        --self:SetSliderValues(0, 100, 1)
        --self:SetValue(0)
    end,

    ["OnRelease"] = function(self)
        local frame = self.slider
        if frame._onValueChangedRegistered then
            frame:UnregisterCallback("OnValueChanged", frame)
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
        if text == "" or text == nil then
            self.slider:ClearAllPoints()
            --self.slider:SetPoint("LEFT", self.frame, "RIGHT", -350, 0)

            self.slider:SetPoint("LEFT", self.frame, "RIGHT", -300, 18)
            --self.slider:SetPoint("RIGHT", self.frame, "RIGHT", -50, 17)
            self:SetHeight(1)
            self.alignoffset = 0
        else
            self.slider:ClearAllPoints()
            self.slider:SetPoint("LEFT", self.label, "RIGHT", 5, 0)
            self:SetHeight(28)
        end
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

        --[[ if not frame._onValueChangedRegistered then
            frame:RegisterCallback("OnValueChanged", function(_, newvalue)
                OnValueChanged(frame, newvalue)
            end, frame)
            frame._onValueChangedRegistered = true
        end

        frame:UnregisterCallback("OnValueChanged", frame)
        frame:RegisterCallback("OnValueChanged", function(_, newvalue)
            print("RegisterCallback -- DF_Slider OnValueChanged:", newvalue)
            --OnValueChanged(frame, newvalue)
        end) ]]

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
    frame:SetScript("OnEnter", OnEnter)
    frame:SetScript("OnLeave", OnLeave)


    -- Slider header
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", frame, "LEFT", 50, 0)
    label:SetPoint("RIGHT", frame, "RIGHT", -350, 0)
    label:SetJustifyH("LEFT")
    label:SetHeight(28)

    -- Slider
    local slider = CreateFrame("Slider", nil, frame, "MinimalSliderWithSteppersTemplate")
    slider:SetPoint("LEFT", label, "RIGHT", 5, 0)
    slider:SetSize(200, 20)
    slider:SetHeight(15)

    local lastCall = 0
    slider:RegisterCallback("OnValueChanged", function(self, value)
        if GetTime() - lastCall < 0.1 then
            slider.RightText:Hide()
            return
        end
        lastCall = GetTime()
        OnValueChanged(slider, value)
    end, slider)

    local editbox = CreateFrame("EditBox", nil, frame, "BackdropTemplate")
    editbox:SetAutoFocus(false)
    editbox:SetFontObject(GameFontHighlightSmall)
    editbox:SetPoint("LEFT", slider, "RIGHT", 5, 0)
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

    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetColorTexture(0.5, 0.5, 0.5, 0.25)
    highlight:SetAllPoints(frame)

    --[[ DisplayCorners(frame)
	DisplayCorners(slider)
	DisplayCorners(editbox)
 ]]
    local widget = {
        label       = label,
        slider      = slider,
        editbox     = editbox,
        highlight   = highlight,
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
