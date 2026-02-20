--[[-----------------------------------------------------------------------------
ScrollFrame Container
Plain container that scrolls its content and doesn't grow in height.
-------------------------------------------------------------------------------]]
local Type, Version = "DF_ScrollFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local min, max, floor = math.min, math.max, math.floor

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function FixScrollOnUpdate(frame)
	frame:SetScript("OnUpdate", nil)
	frame.obj:FixScroll()
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
local function ScrollFrame_OnMouseWheel(frame, value)
	frame.obj:MoveScroll(value)
end

local function ScrollFrame_OnSizeChanged(frame)
	frame:SetScript("OnUpdate", FixScrollOnUpdate)
end

--[[ local function ScrollBar_OnScrollValueChanged(frame, value)
	frame.obj:SetScroll(value)
end ]]

--[[ local function ScrollBar_OnScrollValueChanged(frame)
	local value = frame.obj.scrollbar:GetScrollPercentage() or 0
	frame.obj:SetScroll(value * 1000)
end ]]

local function ScrollBar_OnScrollValueChanged(frame, offset)
	--local value = frame.obj.scrollbar:GetScrollPercentage() or 0
	frame.obj:SetOffset(offset)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetScroll(0)
		self.scrollframe:SetScript("OnUpdate", FixScrollOnUpdate)
	end,

	["OnRelease"] = function(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
		self.scrollframe:SetPoint("BOTTOMRIGHT")
		self.scrollbar:Hide()
		self.scrollBarShown = nil
		self.content.height, self.content.width, self.content.original_width = nil, nil, nil
	end,

	["SetScroll"] = function(self, value)
		local status = self.status or self.localstatus
		local viewheight = self.scrollframe:GetHeight()
		local height = self.content:GetHeight()
		local offset

		if viewheight > height then
			offset = 0
		else
			offset = floor((height - viewheight) / 1000.0 * value)
		end
		self.content:ClearAllPoints()
		self.content:SetPoint("TOPLEFT", 0, offset)
		self.content:SetPoint("TOPRIGHT", 0, offset)

		status.offset = offset
		status.scrollvalue = value
	end,

	["SetOffset"] = function(self, offset)
		local status = self.status or self.localstatus
		self.content:ClearAllPoints()
		self.content:SetPoint("TOPLEFT", 0, offset)
		self.content:SetPoint("TOPRIGHT", 0, offset)
		status.offset = offset
	end,

	["MoveScroll"] = function(self, value)
		local status = self.status or self.localstatus
		local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()

		if self.scrollBarShown then
			local diff = height - viewheight
			local delta = 1
			if value < 0 then
				delta = -1
			end
			self.scrollbar:SetScrollPercentage(min(max(status.scrollvalue + delta * (1000 / (diff / 45)), 0), 1000) / 1000)
			self:SetScroll(min(max(status.scrollvalue + delta * (1000 / (diff / 45)), 0), 1000))
		end
	end,

	["FixScroll"] = function(self)
		if self.updateLock then return end
		self.updateLock = true
		local status = self.status or self.localstatus
		local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()
		local offset = status.offset or 0
		-- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
		-- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!
		if viewheight < height + 2 then
			if self.scrollBarShown then
				self.scrollBarShown = nil
				self.scrollbar:Hide()
				self.scrollbar:SetScrollPercentage(0 / 1000)
				self.scrollframe:SetPoint("BOTTOMRIGHT")
				if self.content.original_width then
					self.content.width = self.content.original_width
				end
				self:DoLayout()
			end
		else
			if not self.scrollBarShown then
				self.scrollBarShown = true
				self.scrollbar:Show()
				self.scrollframe:SetPoint("BOTTOMRIGHT", -20, 0)
				if self.content.original_width then
					self.content.width = self.content.original_width - 20
				end
				self:DoLayout()
			end
			local value = (offset / (viewheight - height) * 1000)
			if value > 1000 then value = 1000 end
			self.scrollbar:SetScrollPercentage(value / 1000)
			self:SetScroll(value)
			if value < 1000 then
				self.content:ClearAllPoints()
				self.content:SetPoint("TOPLEFT", 0, offset)
				self.content:SetPoint("TOPRIGHT", 0, offset)
				status.offset = offset
			end
		end
		self.updateLock = nil
	end,

	["LayoutFinished"] = function(self, width, height)
		self.content:SetHeight(height or 0 + 20)

		-- update the scrollframe
		self:FixScroll()

		-- schedule another update when everything has "settled"
		self.scrollframe:SetScript("OnUpdate", FixScrollOnUpdate)
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		if not status.scrollvalue then
			status.scrollvalue = 0
		end
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		content.width = width - (self.scrollBarShown and 20 or 0)
		content.original_width = width
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		content.height = height
	end
}
--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)

	local scrollframe = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
	scrollframe:SetPoint("TOPLEFT")
	scrollframe:SetPoint("BOTTOMRIGHT")
	scrollframe:EnableMouseWheel(true)

	scrollframe.ScrollBar.scrollBarHideIfUnscrollable = true

	scrollframe:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
	scrollframe:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged)

	local scrollbar = scrollframe.ScrollBar
	scrollframe:HookScript("OnVerticalScroll", ScrollBar_OnScrollValueChanged)

	--Container Support
	local content = CreateFrame("Frame", nil, scrollframe)
	content:SetPoint("TOPLEFT")
	content:SetPoint("TOPRIGHT")
	content:SetHeight(400)
	scrollframe:SetScrollChild(content)

	local widget = {
		localstatus = { scrollvalue = 0 },
		scrollframe = scrollframe,
		scrollbar   = scrollbar,
		content     = content,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	scrollframe.obj, scrollbar.obj = widget, widget

	return AceGUI:RegisterAsContainer(widget)
end


AceGUI:RegisterWidgetType(Type, Constructor, Version)
