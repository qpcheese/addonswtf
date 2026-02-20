--[[-----------------------------------------------------------------------------
ColorPicker Widget with Left Label
-------------------------------------------------------------------------------]]
local Type, Version = "DF_ColorPicker", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

-- Unfortunately we have no way to realistically detect if a client uses inverted alpha
-- as no API will tell you. Wrath uses the old colorpicker, era uses the new one, both are inverted
local INVERTED_ALPHA = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE)

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function ColorCallback(self, r, g, b, a, isAlpha)
    if INVERTED_ALPHA and a then
        a = 1 - a
    end
    if not self.HasAlpha then
        a = 1
    end
    -- no change, skip update
    if r == self.r and g == self.g and b == self.b and a == self.a then
        return
    end
    self:SetColor(r, g, b, a)
    if ColorPickerFrame:IsVisible() then
        --colorpicker is still open
        self:Fire("OnValueChanged", r, g, b, a)
    else
        --colorpicker is closed, color callback is first, ignore it,
        --alpha callback is the final call after it closes so confirm now
        if isAlpha then
            self:Fire("OnValueConfirmed", r, g, b, a)
        end
    end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
    frame.obj:Fire("OnLeave")
end

local function ColorSwatch_OnClick(frame)
    ColorPickerFrame:Hide()
    local self = frame.obj
    if not self.disabled then
        ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        ColorPickerFrame:SetFrameLevel(frame:GetFrameLevel() + 10)
        ColorPickerFrame:SetClampedToScreen(true)

        if ColorPickerFrame.SetupColorPickerAndShow then -- 10.2.5 color picker overhaul
            local r2, g2, b2, a2 = self.r, self.g, self.b, (self.a or 1)
            if INVERTED_ALPHA then
                a2 = 1 - a2
            end

            local info = {
                swatchFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    local a = ColorPickerFrame:GetColorAlpha()
                    ColorCallback(self, r, g, b, a)
                end,

                hasOpacity = self.HasAlpha,
                opacityFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    local a = ColorPickerFrame:GetColorAlpha()
                    ColorCallback(self, r, g, b, a, true)
                end,
                opacity = a2,

                cancelFunc = function()
                    ColorCallback(self, r2, g2, b2, a2, true)
                end,

                r = r2,
                g = g2,
                b = b2,
            }

            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = OpacitySliderFrame:GetValue()
                ColorCallback(self, r, g, b, a)
            end

            ColorPickerFrame.hasOpacity = self.HasAlpha
            ColorPickerFrame.opacityFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = OpacitySliderFrame:GetValue()
                ColorCallback(self, r, g, b, a, true)
            end

            local r, g, b, a = self.r, self.g, self.b, 1 - (self.a or 1)
            if self.HasAlpha then
                ColorPickerFrame.opacity = a
            end
            ColorPickerFrame:SetColorRGB(r, g, b)

            ColorPickerFrame.cancelFunc = function()
                ColorCallback(self, r, g, b, a, true)
            end

            ColorPickerFrame:Show()
        end
    end
    AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
        self:SetHeight(28)
        self:SetWidth(200)
        self:SetHasAlpha(false)
        self:SetColor(0, 0, 0, 1)
        self:SetDisabled(nil)
        self:SetLabel(nil)
    end,

    -- ["OnRelease"] = nil,

    ["SetLabel"] = function(self, text)
        self.text:SetText(text)
        if text == "" or text == nil then
            self.colorSwatch:ClearAllPoints()
            self.colorSwatch:SetPoint("LEFT", self.frame, "RIGHT", -300, 18)
            self:SetHeight(1)
            self.alignoffset = 0
        else
            self.colorSwatch:ClearAllPoints()
            self.colorSwatch:SetPoint("LEFT", self.text, "RIGHT", 8, 0)
            --self.colorSwatch:SetPoint("BOTTOMLEFT", self.text, "BOTTOMRIGHT", 8, 0)
            self:SetHeight(28)
        end
    end,

    ["SetColor"] = function(self, r, g, b, a)
        self.r = r
        self.g = g
        self.b = b
        self.a = a or 1
        local normalTexture = self.colorSwatch:GetNormalTexture()
        normalTexture:SetVertexColor(r, g, b, a)
        --self.colorSwatch:SetVertexColor(r, g, b, a)
    end,

    ["SetHasAlpha"] = function(self, HasAlpha)
        self.HasAlpha = HasAlpha
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if self.disabled then
            self.frame:Disable()
            self.text:SetTextColor(0.5, 0.5, 0.5)
        else
            self.frame:Enable()
            self.text:SetTextColor(1, .82, 0)
        end
    end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    -- Widge frame
    local frame = CreateFrame("Button", nil, UIParent)
    frame:Hide()

    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    --frame:SetScript("OnClick", ColorSwatch_OnClick)

    -- Widget text
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetHeight(28)
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", frame, "LEFT", 50, 0)
    text:SetPoint("RIGHT", frame, "RIGHT", -350, 0)

    -- The actual color swatch button
    local colorSwatchButton = CreateFrame("Button", nil, frame)
    colorSwatchButton:SetSize(22, 22)
    colorSwatchButton:SetPoint("LEFT", text, "RIGHT", 80, 0)
    --colorSwatchButton:SetPoint("BOTTOMLEFT", text, "BOTTOMRIGHT", 80, 0)
    colorSwatchButton:SetNormalTexture(130939) -- Swatch texture
    colorSwatchButton:SetScript("OnClick", ColorSwatch_OnClick)
    colorSwatchButton:SetScript("OnEnter", Control_OnEnter)
    colorSwatchButton:SetScript("OnLeave", Control_OnLeave)

    -- Background texture for the color swatch
    local checkers = frame:CreateTexture(nil, "BACKGROUND")
    checkers:SetTexture(188523) -- Tileset\\Generic\\Checkers
    checkers:SetTexCoord(.25, 0, 0.5, .25)
    checkers:SetDesaturated(true)
    checkers:SetVertexColor(1, 1, 1, 0.75)
    checkers:SetAllPoints(colorSwatchButton)
    checkers:Show()

    -- Highlight when mouse is over
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetColorTexture(0.5, 0.5, 0.5, 0.5)
    highlight:SetAllPoints(frame)

    local widget = {
        colorSwatch = colorSwatchButton,
        text        = text,
        highlight   = highlight,
        frame       = frame,
        type        = Type,
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    colorSwatchButton.obj = widget

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
