--[[-----------------------------------------------------------------------------
Icon Widget
-------------------------------------------------------------------------------]]
local Type, Version = "IconButton", 1
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
			self:SetHeight(self.image:GetHeight() + 25)
		else
			self.label:Hide()
			self:SetHeight(self.image:GetHeight() + 10)
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
		self.image:SetWidth(width)
		self.image:SetHeight(height)
		--self.frame:SetWidth(width + 30)
		if self.label:IsShown() then
			self:SetHeight(height + 25)
		else
			self:SetHeight(height + 10)
		end
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
    end,
	["SetSize"] = function(self, size)
        self.image:SetSize(size, size)

        self:SetHeight(size)
        self:SetWidth(size)
        if self.cooldown then
            self.cooldown:SetHeight(size)
            self.cooldown:SetWidth(size)
        end
	end,
	["SetSpell"] = function(self, value)
        local info = C_Spell.GetSpellInfo(value)
        self:SetImage(info.iconID)
        self.frame:SetAttribute("type", "spell")
        self.frame:SetAttribute("spell", info.name)
        local tt = Madhouse.API.v1.TooltipToText(C_TooltipInfo.GetSpellByID(value))
        if IsSpellKnown(value) then
            self.image:SetDesaturated(false)
        else
            self.image:SetDesaturated(true)
            tt = tt .. "\n" .. Madhouse.API.v1.ColorPrintRGB((isGerman and "Nicht bekannt" or "Not known"),"FF0000")
        end

        self.frame:SetScript("OnEnter", function() GameTooltip:SetOwner(self.frame, "ANCHOR_CURSOR") GameTooltip:SetText(tt) GameTooltip:Show() end)
        self.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

        if not self.cooldown then
            self.cooldown = CreateFrame("Cooldown", nil, self.frame, "CooldownFrameTemplate")
            -- self.cooldown:SetAllPoints(self.frame)
            self.cooldown:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -6)
            self.cooldown:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", 0, -6)
            self.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            local info = C_Spell.GetSpellCooldown(value);
            -- TODO: fix cooldown display
            local enable =  false -- info.isEnabled
            local duration = info.duration
            local start = info.startTime
            if enable then
                CooldownFrame_Set(self.cooldown, start, duration, enable)
            end
        end
        self.frame:SetScript("OnShow", function()
            local info = C_Spell.GetSpellCooldown(value);
            local enable = info.isEnabled
            local duration = info.duration
            local start = info.startTime
            if enable then
                CooldownFrame_Set(self.cooldown, start, duration, enable)
            end
        end)

        self.frame:SetScript("OnEvent", function(_, event)
            if event == "SPELL_UPDATE_COOLDOWN" then
                local info = C_Spell.GetSpellCooldown(value);
                -- TODO: fix cooldown display
                local enable =  false -- info.isEnabled
                local duration = info.duration
                local start = info.startTime
                if enable then
                    CooldownFrame_Set(self.cooldown, start, duration, enable)
                end
            end
        end)
	end,
	["SetItem"] = function(self, value)
        self:SetImage(C_Item.GetItemIconByID(value))
        self.frame:SetAttribute("type", "item")
        self.frame:SetAttribute("item", "item:"..value)
        local tt = Madhouse.API.v1.TooltipToText(C_TooltipInfo.GetItemByID(value))
        self.frame:SetScript("OnEnter", function() GameTooltip:SetOwner(self.frame, "ANCHOR_CURSOR") GameTooltip:SetText(tt) GameTooltip:Show() end)
        self.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", "secureBtnTest", UIParent, "SecureActionButtonTemplate")

    frame:RegisterForClicks("AnyUp", "AnyDown")
    frame:SetMouseClickEnabled(true)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("BOTTOMLEFT")
	label:SetPoint("BOTTOMRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetHeight(18)

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(image)
	highlight:SetTexture(136580) -- Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight
	highlight:SetTexCoord(0, 1, 0.23, 0.77)
	highlight:SetBlendMode("ADD")

	local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
