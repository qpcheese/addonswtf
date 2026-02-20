--[[-----------------------------------------------------------------------------
Dropdown Widget with Arrows (Left/Right) and Label (if no label, placed on line above)
-------------------------------------------------------------------------------]]
local Type, Version = "DF_Dropdown", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Control_OnEnter(this)
    this.obj:Fire("OnEnter")
end

local function Control_OnLeave(this)
    this.obj:Fire("OnLeave")
end

local function OnMouseDown(frame)
    AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self:SetHeight(28)
        self:SetWidth(400)
        self.list = {}
        self.items = {}
    end,

    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        if disabled then
            self.dropdown:EnableMouse(false)
            self.label:SetTextColor(.5, .5, .5)
        else
            self.dropdown:EnableMouse(true)
            self.label:SetTextColor(1, .82, 0)
        end
    end,

    ["SetValue"] = function(self, value)
        if self.value == value then return end
        self.value = value

        if self.list and self.list[value] and self.dropdown then
            self.dropdown:SetDefaultText(self.list[value])
        end
    end,

    ["GetValue"] = function(self)
        return self.value
    end,

    ["SetLabel"] = function(self, text)
        self.label:SetText(text)
        if text == "" or text == nil then
            self.leftButton:ClearAllPoints()
            self.leftButton:SetPoint("LEFT", self.frame, "RIGHT", -300, 18)
            self:SetHeight(1)
        else
            self.leftButton:ClearAllPoints()
            self.leftButton:SetPoint("TOPLEFT", self.label, "TOPRIGHT", 5, 0)
            self.leftButton:SetPoint("BOTTOMLEFT", self.label, "BOTTOMRIGHT", 5, 0)
            self:SetHeight(28)
        end
    end,

    ["SetList"] = function(self, list, order, itemType)
        self.list = list or {}

        local function menuGenerator(_, rootDescription)
            rootDescription:CreateTitle("Select an Option")
            rootDescription:SetGridMode(MenuConstants.VerticalGridDirection)
            for i, option in ipairs(self.list) do
                rootDescription:CreateButton(option, function()
                    self:SetValue(i)
                    self:Fire("OnValueChanged", i)
                end)
            end
        end

        self.dropdown:SetupMenu(menuGenerator)
        self.dropdown:GenerateMenu()
        self.dropdown:SetDefaultText(self.list[self.value] or "Select an Option")

        self.leftButton:SetScript("OnClick", function()
            local index = self:GetValue()
            local newIndex = index - 1
            if index - 1 < 1 then newIndex = #self.list end
            self:SetValue(newIndex)
            self:Fire("OnValueChanged", newIndex)
        end)

        self.rightButton:SetScript("OnClick", function()
            local index = self:GetValue()
            local newIndex = index + 1
            if index + 1 > #self.list then newIndex = 1 end
            self:SetValue(newIndex)
            self:Fire("OnValueChanged", newIndex)
        end)
    end,
}

--[[ Constructor ]] --
local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)

    --
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", frame, "LEFT", 50, 0)
    label:SetPoint("RIGHT", frame, "RIGHT", -350, 0)
    label:SetJustifyH("LEFT")
    label:SetHeight(28)

    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)

    -- left button
    local leftButton = CreateFrame("Button", nil, frame)
    leftButton:SetSize(23, 23)
    leftButton:SetPoint("TOPLEFT", label, "TOPRIGHT", 5, 0)
    leftButton:SetPoint("BOTTOMLEFT", label, "BOTTOMRIGHT", 5, 0)
    leftButton:SetNormalAtlas("common-dropdown-icon-back")

    -- right button
    local rightButton = CreateFrame("Button", nil, frame)
    rightButton:SetSize(23, 23)
    rightButton:SetPoint("TOPLEFT", leftButton, "TOPRIGHT", 175, 0)
    rightButton:SetPoint("BOTTOMLEFT", leftButton, "BOTTOMRIGHT", 175, 0)
    rightButton:SetNormalAtlas("common-dropdown-icon-next")

    -- dropdown
    local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle2DropdownTemplate")
    dropdown:SetPoint("LEFT", leftButton, "RIGHT", 5, 0)
    dropdown:SetPoint("RIGHT", rightButton, "LEFT", -5, 0)
    --dropdown:SetPoint("BOTTOMLEFT", leftButton, "BOTTOMRIGHT", 5, 0)
    --dropdown:SetPoint("BOTTOMRIGHT", rightButton, "BOTTOMLEFT", -5, 0)
    dropdown:SetHeight(23)

    local widget = {
        label       = label,
        dropdown    = dropdown,
        alignoffset = 35,
        frame       = frame,
        leftButton  = leftButton,
        rightButton = rightButton,
        type        = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end
    dropdown.obj, label.obj, leftButton.obj, rightButton.obj = widget, widget, widget, widget


    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
