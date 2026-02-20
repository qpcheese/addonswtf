--[[-----------------------------------------------------------------------------
Dropdown Widget without Arrows (Left/Right) and Label
-------------------------------------------------------------------------------]]
local Type, Version = "DF_Dropdown_2", 1
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
		self:SetWidth(200)
		self.list = {}
		self.items = {}
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.dropdown:EnableMouse(false)
			--self.label:SetTextColor(.5, .5, .5)
		else
			self.dropdown:EnableMouse(true)
			--self.label:SetTextColor(1, .82, 0)
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
		--self.label:SetText(text)
	end,

	["SetList"] = function(self, list, order, itemType)
		self.list = list or {}

		local function menuGenerator(owner, rootDescription)
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
	end,
}

--[[ Constructor ]] --
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)

	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)

	-- dropdown
	local dropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle2DropdownTemplate")
	dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT")
	dropdown:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	dropdown:SetHeight(23)

	dropdown:SetScript("OnEnter", Control_OnEnter)
	dropdown:SetScript("OnLeave", Control_OnLeave)

	local widget = {
		dropdown    = dropdown,
		alignoffset = 15,
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
