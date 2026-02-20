--[[-----------------------------------------------------------------------------
Dropdown Widget with multi select and Label
-------------------------------------------------------------------------------]]
local Type, Version = "DF_Dropdown_3", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs, ipairs, type, tostring = select, pairs, ipairs, type, tostring
local tsort = table.sort

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
        --self.items = {}
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
        self.value = value
    end,

    ["GetValue"] = function(self)
        return self.value
    end,

    ["SetLabel"] = function(self, text)
        self.label:SetText(text)
        if text == "" or text == nil then
            self.dropdown:ClearAllPoints()
            self.dropdown:SetPoint("LEFT", self.frame, "RIGHT", -300, 18)
            self:SetHeight(1)
        else
            self.dropdown:ClearAllPoints()
            self.dropdown:SetPoint("TOPLEFT", self.label, "TOPRIGHT", 5 + 23 + 5, 0)
            self.dropdown:SetPoint("BOTTOMLEFT", self.label, "BOTTOMRIGHT", 5 + 23 + 5, 0)
            self:SetHeight(28)
        end
    end,

    ["SetMultiselect"] = function(self, multi)
        self.multiselect = multi
    end,

    ["GetMultiselect"] = function(self)
        return self.multiselect
    end,

    ["SetItemValue"] = function(self, key, value)
        if not self.multiselect then return end
        for i, widget in ipairs(self.items) do
            if widget.userdata.key == key then
                self.items[i].value = value
                break
            end
        end
    end,

    ["SetList"] = function(self, list)
        self.list = list or {}
        self.items = self.items or {}

        local sortlist = {}
        local function sortTbl(x, y)
            local num1, num2 = tonumber(x), tonumber(y)
            if num1 and num2 then -- numeric comparison, either two numbers or numeric strings
                return num1 < num2
            else                  -- compare everything else tostring'ed
                return tostring(x) < tostring(y)
            end
        end
        for v in pairs(list) do
            sortlist[#sortlist + 1] = v
        end
        tsort(sortlist, sortTbl)

        local function IsSelected(index)
            return self.items[index].value
        end

        local function SetSelected(index)
            self.items[index].value = not self.items[index].value
            self:Fire("OnValueChanged", self.items[index].userdata.key, self.items[index].value)
        end

        local function menuGenerator(owner, rootDescription)
            rootDescription:CreateTitle("Select an Option")
            rootDescription:SetGridMode(MenuConstants.VerticalGridDirection)
            for i, option in ipairs(sortlist) do
                if self.items[i] and self.items[i].userdata and self.items[i].userdata.key == list[option] then
                    -- we keep the existing userdata
                else
                    self.items[i] = self.items[i] or {}
                    self.items[i].value = false
                    self.items[i].userdata = { index = i, key = list[option], obj = self }
                end

                --[[ self.items[i] = self.items[i] or {}
                self.items[i].value = self.items[i].value or false
                self.items[i].userdata = self.items[i].userdata or { index = i, key = list[option], obj = self } ]]

                rootDescription:CreateCheckbox(option, IsSelected, SetSelected, i)
            end
        end

        self.dropdown:SetupMenu(menuGenerator)
        self.dropdown:GenerateMenu()
        self.dropdown:SetDefaultText("Select an Option")
    end,
}

--[[ Constructor ]] --
local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", frame, "LEFT", 50, 0)
    label:SetPoint("RIGHT", frame, "RIGHT", -350, 0)
    label:SetJustifyH("LEFT")
    label:SetHeight(28)

    frame:SetScript("OnEnter", Control_OnEnter)
    frame:SetScript("OnLeave", Control_OnLeave)

    -- dropdown
    local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle2DropdownTemplate")
    dropdown:SetPoint("TOPLEFT", label, "TOPRIGHT", 5, 0)
    dropdown:SetPoint("BOTTOMLEFT", label, "BOTTOMRIGHT", 5, 0)
    dropdown:SetHeight(23)
    dropdown:SetWidth(165)

    dropdown:SetScript("OnEnter", Control_OnEnter)
    dropdown:SetScript("OnLeave", Control_OnLeave)

    local widget = {
        label       = label,
        dropdown    = dropdown,
        alignoffset = 35,
        frame       = frame,
        type        = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end
    dropdown.obj = widget

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
