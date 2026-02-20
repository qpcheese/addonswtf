--[[-----------------------------------------------------------------------------
Label Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "ProgressBar", 29
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
        self:SetValue(0)
	end,

	["SetValue"] = function(self,val)
        self.value = math.max(0, math.min(val, self.max)) -- Clamp between 0 and max
        self.valueRaw = val
        self:Update()
	end,

	["SetMax"] = function(self,max)
        self.max = math.max(1, max) -- Ensure max is at least 1
        self:Update()
	end,

	["SetSize"] = function(self,width, height)
        self.frame:SetSize(width, height)
        self.bar:SetHeight(height)
        self:Update()
	end,
	["SetColor"] = function(self,r,g,b)
        self.bar:SetColorTexture(r,g,b, 1)
        self.labelBackground:SetColorTexture(r,g,b, 1)
        self:Update()
	end,
	["Update"] = function(self)
        if self.max > 0 then
            local percentage = (self.value / self.max) * 100
            local percentageRaw = (self.valueRaw / self.max) * 100
            self.bar:SetWidth(self.frame:GetWidth() * (percentage / 100))
            self.label:SetText(string.format("%d%%", percentageRaw))
        else
            self.bar:SetWidth(0)
            self.label:SetText("0%")
        end
	end,


}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()
    frame:SetSize(200, 20)


    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.2, 0.2, 0.2, 1)


    local bar = frame:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("LEFT", frame, "LEFT", 0, 0)
    bar:SetSize(1, 20) -- Initial size; updated later

    local _, englishClass = UnitClass("player");

    local rPerc, gPerc, bPerc  = GetClassColor(englishClass)
    bar:SetColorTexture(rPerc, gPerc, bPerc, 1)
    -- bar:SetTexture("Unit_Druid_AstralPower_Fill")

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("CENTER", frame, "CENTER", 0, 0)

    local labelBackground = frame:CreateTexture(nil, "ARTWORK")
    labelBackground:SetPoint("TOPLEFT", label, "TOPLEFT", -2, 2)
    labelBackground:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 2, -2)
    if englishClass == "PRIEST" then
        labelBackground:SetColorTexture(0, 0, 0, 1)
    else
        labelBackground:SetColorTexture(rPerc, gPerc, bPerc, 1)
    end


    local widget = {
        frame = frame,
        bar = bar,
        label = label,
        labelBackground = labelBackground,
        value = 0,
        valueRaw = 0,
        max = 100,
        type = Type
    }
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
