--[[-----------------------------------------------------------------------------
Checkbox Widget with no label
-------------------------------------------------------------------------------]]
local Type, Version = "DF_Checkbox_Right_Label", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
    frame.obj:Fire("OnLeave")
end

local function CheckBox_OnMouseDown(frame)
    AceGUI:ClearFocus()
end

local function CheckBox_OnMouseUp(frame)
    local self = frame.obj
    if not self.disabled then
        self:ToggleChecked()
        self:Fire("OnValueChanged", self.checked)
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
    ["OnAcquire"] = function(self)
        self:SetValue(false)
        self:SetWidth(200)
        self:SetDisabled(nil)
        self:SetDescription(nil)
    end,

    -- ["OnRelease"] = nil

    ["OnWidthSet"] = function(self, width)
        if self.desc then
            self.desc:SetWidth(width - 30)
            if self.desc:GetText() and self.desc:GetText() ~= "" then
                self:SetHeight(28 + self.desc:GetStringHeight())
            end
        end
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.frame:EnableMouse(false)
            self.text:SetTextColor(0.5, 0.5, 0.5)
            if self.desc then
                self.desc:SetTextColor(0.5, 0.5, 0.5)
            end
        else
            self.frame:EnableMouse(true)
            self.text:SetTextColor(1, 1, 1)
            if self.desc then
                self.desc:SetTextColor(1, 1, 1)
            end
        end
    end,

    ["SetValue"] = function(self, value)
        local check = self.checkbox
        self.checked = value
        check:SetChecked(value)
        self:SetDisabled(self.disabled)
    end,

    ["GetValue"] = function(self)
        return self.checked
    end,

    ["SetTriState"] = function(self, enabled)
        self.tristate = enabled
        self:SetValue(self:GetValue())
    end,

    ["ToggleChecked"] = function(self)
        local value = self:GetValue()
        self:SetValue(not self:GetValue())
    end,

    ["SetLabel"] = function(self, label)
        self.text:SetText(label)
    end,

    ["SetDescription"] = function(self, desc)
        if desc then
            if not self.desc then
                local f = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", self.checkbox, "TOPRIGHT", 5, -21)
                f:SetWidth(self.frame.width - 30)
                f:SetPoint("RIGHT", self.frame, "RIGHT", -30, 0)
                f:SetJustifyH("LEFT")
                f:SetJustifyV("TOP")
                self.desc = f
            end
            self.desc:Show()
            self.desc:SetText(desc)
            self:SetHeight(28 + self.desc:GetStringHeight())
        else
            if self.desc then
                self.desc:SetText("")
                self.desc:Hide()
            end
            self:SetHeight(28)
        end
    end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    -- Widget frame
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:EnableMouse(true)
    --[[ frame:SetScript("OnMouseDown", CheckBox_OnMouseDown)
    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)
    frame:SetScript("OnMouseUp", CheckBox_OnMouseUp) ]]

    -- The actual checkbox
    local checkbox = CreateFrame("CheckButton", nil, frame, "SettingsCheckBoxTemplate")
    checkbox:SetPoint("LEFT", frame, "LEFT", 0, 0)
    checkbox:SetSize(30, 29)
    checkbox:SetScript("OnClick", CheckBox_OnMouseUp)
    checkbox:SetScript("OnEnter", Control_OnEnter)
    checkbox:SetScript("OnLeave", Control_OnLeave)

    -- Widget Text
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", checkbox, "RIGHT")
    text:SetPoint("RIGHT", frame, "RIGHT")
    text:SetJustifyH("LEFT")
    text:SetHeight(28)
    text:SetScript("OnEnter", Control_OnEnter)
    text:SetScript("OnLeave", Control_OnLeave)

    -- Highlight when mouse is over
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetColorTexture(0.5, 0.5, 0.5, 0.5)
    highlight:SetAllPoints(frame)

    local widget = {
        checkbox  = checkbox,
        text      = text,
        highlight = highlight,
        frame     = frame,
        type      = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    checkbox.obj = widget
    text.obj = widget

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
