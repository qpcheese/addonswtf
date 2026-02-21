--[[-----------------------------------------------------------------------------
Icon Widget
-------------------------------------------------------------------------------]]
local Type, Version = "SellIcon", 22
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs, print = select, pairs, print

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

local function Button_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(110)
		self:SetWidth(110)
		self:SetLabel()
		self:SetImage(nil)
		self:SetImageSize(64, 64)
		self:SetDisabled(false)
	end,

	-- ["OnRelease"] = nil,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
			self.label:Show()
			self.label:SetText(text)
		else
			self.label:Hide()
		end
	end,

	["SetImage"] = function(self, path, ...)
		local image = self.image
		image:SetTexture(path)

		if image:GetTexture() then
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		end
	end,

	["SetImageSize"] = function(self, width, height)
        self:SetWidth(width + self.thickness + 2)
        self:SetHeight(height + self.thickness + 2)
		self.image:SetWidth(width)
        self.image:SetHeight(height)
		self.label:SetWidth(width + self.thickness + 2)
        self.label:SetHeight(height)
	end,

	["SetBorderColor"] = function(self,r,g,b)
        self.border_left:SetVertexColor(r,g,b)
        self.border_right:SetVertexColor(r,g,b)
        self.border_top:SetVertexColor(r,g,b)
        self.border_bottom:SetVertexColor(r,g,b)
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
			self.label:SetTextColor(0.5, 0.5, 0.5)
			self.image:SetVertexColor(0.5, 0.5, 0.5, 0.5)
		else
			self.frame:Enable()
			self.label:SetTextColor(1, 1, 1)
			self.image:SetVertexColor(1, 1, 1, 1)
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnClick", Button_OnClick)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
    label:SetPoint("CENTER", frame, "CENTER")  -- center on the frame
	label:SetJustifyH("CENTER")
	label:SetJustifyV("MIDDLE")
    label:SetHeight(18)
    label:SetFontObject(GameFontHighlightLarge) -- Use a larger font

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(image)
	highlight:SetTexture(136580) -- Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight
	highlight:SetTexCoord(0, 1, 0.23, 0.77)
	highlight:SetBlendMode("ADD")

    local borderTexture = "Interface\\Buttons\\WHITE8X8"
    local thickness = 2
    local r,g,b  = 1,1,1

    local left = frame:CreateTexture(nil, "OVERLAY")
    local right = frame:CreateTexture(nil, "OVERLAY")
    local top = frame:CreateTexture(nil, "OVERLAY")
    local bottom = frame:CreateTexture(nil, "OVERLAY")

    left:SetTexture(borderTexture)
    left:SetVertexColor(r,g,b)
    left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    left:SetWidth(thickness)

    right:SetTexture(borderTexture)
    right:SetVertexColor(r,g,b)
    right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    right:SetWidth(thickness)

    top:SetTexture(borderTexture)
    top:SetVertexColor(r,g,b)
    top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    top:SetHeight(thickness)

    bottom:SetTexture(borderTexture)
    bottom:SetVertexColor(r,g,b)
    bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bottom:SetHeight(thickness)


	local widget = {
		label = label,
		image = image,
		frame = frame,
        type  = Type,
        border_left = left,
        border_right = right,
        border_top = top,
        border_bottom = bottom,
        thickness = thickness
    }

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
