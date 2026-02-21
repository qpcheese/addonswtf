LFGMythicPlus = LibStub("AceAddon-3.0"):NewAddon("MythicPlusKeyAnnouncer", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("MythicPlusKeyAnnouncer")

local currentLFGResults = ''
local currentPlainLFGResults = ''

-- Default settings for AceDB
local defaults = {
	profile = {
		messageColor = { r = 1, g = 0.76, b = 0.15 }, -- gold default
		showPopup = true,                       -- show popup by default
		announceToChat = true,                  -- send chat announcements by default
		sendChannel = "SAY",                    -- default channel for announcements (use Say)
		sendTarget = "",                        -- target for whisper or channel number
	}
}

-- Options table for AceConfig
local options = {
	name = L["Mythic Plus Key Announcer"],
	handler = LFGMythicPlus,
	type = 'group',
	args = {
		sendChannel = {
			type = "select",
			name = L["Announcement Channel"],
			desc = L["Configure how group announcements are sent and displayed."],
			values = {
				SAY = L["Say"],
				PARTY = L["Party"],
				RAID = L["Raid"],
				GUILD = L["Guild"],
				INSTANCE_CHAT = L["Instance"],
				YELL = L["Yell"],
				WHISPER = L["Whisper (requires target)"],
				CHANNEL = L["Channel (requires channel number)"],
			},
			get = function(info)
				return LFGMythicPlus.db.profile.sendChannel
			end,
			set = function(info, val)
				LFGMythicPlus.db.profile.sendChannel = val
				-- refresh the options UI so the change is visible
				if AceConfigRegistry then AceConfigRegistry:NotifyChange("MythicPlusKeyAnnouncer") end
			end,
		},
		sendTarget = {
			type = "input",
			name = L["Target"],
			desc = L["Target"],
			get = function(info)
				return LFGMythicPlus.db.profile.sendTarget
			end,
			set = function(info, val)
				LFGMythicPlus.db.profile.sendTarget = val
				if AceConfigRegistry then AceConfigRegistry:NotifyChange("MythicPlusKeyAnnouncer") end
			end,
			hidden = function()
				local db = LFGMythicPlus.db and LFGMythicPlus.db.profile
				if not db then return true end
				local ch = db.sendChannel
				return not (ch == "WHISPER" or ch == "CHANNEL")
			end,
		},
		-- Test button to send a test announcement using current settings
		testAnnouncement = {
			type = "execute",
			name = L["Test Announcement"],
			desc = L["Test the configured announcement and popup."],
			func = "TestAnnouncement",
		},
		showPopup = {
			type = "toggle",
			name = L["Show popup on join"],
			desc = L["Show a popup window when you join a Mythic+ group."],
			get = function(info)
				return LFGMythicPlus.db.profile.showPopup
			end,
			set = function(info, val)
				LFGMythicPlus.db.profile.showPopup = val
				if AceConfigRegistry then AceConfigRegistry:NotifyChange("MythicPlusKeyAnnouncer") end
			end,
		},
		messageColor = {
			type = "color",
			name = L["Message Color"],
			desc = L["Set the color for the group filled chat message."],
			get = function(info)
				local c = LFGMythicPlus.db.profile.messageColor
				return c.r, c.g, c.b
			end,
			set = function(info, r, g, b)
				local c = LFGMythicPlus.db.profile.messageColor
				c.r, c.g, c.b = r, g, b
				if AceConfigRegistry then AceConfigRegistry:NotifyChange("MythicPlusKeyAnnouncer") end
			end,
		},
		announceToChat = {
			type = "toggle",
			name = L["Send chat announcements"],
			desc = L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."],
			get = function(info)
				return LFGMythicPlus.db.profile.announceToChat
			end,
			set = function(info, val)
				LFGMythicPlus.db.profile.announceToChat = val
				if AceConfigRegistry then AceConfigRegistry:NotifyChange("MythicPlusKeyAnnouncer") end
			end,
		},
	},
}

-- Initialize Addon
-- Create a simple Blizzard options panel to show the icon (AceConfigDialog:AddToBlizOptions will still register the option table)
-- Initialize Addon
function LFGMythicPlus:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MythicPlusKeyAnnouncerDB", defaults, true)
	AceConfig:RegisterOptionsTable("MythicPlusKeyAnnouncer", options)
	AceConfigDialog:AddToBlizOptions("MythicPlusKeyAnnouncer", L["Mythic Plus Key Announcer"])
	-- create Blizzard options panel when Blizzard UI is guaranteed to be ready
	local loader = CreateFrame("Frame")
	loader:RegisterEvent("PLAYER_LOGIN")
	loader:SetScript("OnEvent", function(self, event)
		-- using AceConfigDialog built-in to register options in Blizzard Interface Options
		self:UnregisterEvent(event)
	end)
	self:RegisterChatCommand("mpk", "ChatCommand")
	self:RegisterEvent("LFG_LIST_JOINED_GROUP")
	self:RegisterEvent("GROUP_LEFT")
end

-- Path to addon media icon
local ADDON_ICON = "Interface\\AddOns\\Mythic-Plus-Key-Announcer\\media\\637494804482635620.png"

-- Create a simple Blizzard options panel to show the icon (AceConfigDialog:AddToBlizOptions will still register the option table)
-- custom Blizzard options panel removed; using AceConfigDialog built-in registration only

-- Helper to get hex color from db
local function GetColorHex()
	local c = LFGMythicPlus.db.profile.messageColor
	return string.format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

-- Show popup window with group info using WoW API
local popupFrame = nil
local function ShowGroupPopup(msg)
	if popupFrame and popupFrame:IsShown() then
		popupFrame:Hide()
	end
	popupFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
	popupFrame:SetSize(420, 120)
	popupFrame:SetPoint("CENTER")
	-- icon
	popupFrame.icon = popupFrame:CreateTexture(nil, "ARTWORK")
	popupFrame.icon:SetSize(48, 48)
	popupFrame.icon:SetPoint("TOPLEFT", 10, -10)
	popupFrame.icon:SetTexture(ADDON_ICON)
	-- title
	popupFrame.title = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	popupFrame.title:SetPoint("TOPLEFT", popupFrame.icon, "TOPRIGHT", 8, -6)
	popupFrame.title:SetText(L["Joined Mythic+ Group"])
	-- message
	popupFrame.text = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	popupFrame.text:SetPoint("TOPLEFT", popupFrame.icon, "BOTTOMLEFT", 0, -6)
	popupFrame.text:SetPoint("RIGHT", -10, 0)
	popupFrame.text:SetJustifyH("LEFT")
	popupFrame.text:SetText(msg)
	popupFrame:SetScript("OnMouseDown", function(self, button) self:StartMoving() end)
	popupFrame:SetScript("OnMouseUp", function(self, button) self:StopMovingOrSizing() end)
	popupFrame:SetMovable(true)
	popupFrame:EnableMouse(true)
	popupFrame:SetClampedToScreen(true)
	popupFrame.close = CreateFrame("Button", nil, popupFrame, "UIPanelCloseButton")
	popupFrame.close:SetPoint("TOPRIGHT", popupFrame, "TOPRIGHT")
	C_Timer.After(5, function() if popupFrame and popupFrame:IsShown() then popupFrame:Hide() end end)
end

-- Helper to send a message to the configured channel with safe fallbacks
local function SendToConfiguredChannel(msg)
	-- Respect the announceToChat setting
	if not LFGMythicPlus.db.profile.announceToChat then
		return
	end
	-- Remove Blizzard escape codes (pipes) to avoid invalid escape code errors
	msg = msg:gsub("|", "")
	local chan = LFGMythicPlus.db.profile.sendChannel or "SAY"
	local target = LFGMythicPlus.db.profile.sendTarget or ""

	-- Delay the chat message to avoid protected function errors in WoW 12.01+
	-- Chat functions can't be called directly from certain event handlers
	C_Timer.After(0.1, function()
		-- WHISPER
		if chan == "WHISPER" then
			if strtrim(target) ~= "" then
				C_ChatInfo.SendChatMessage(msg, "WHISPER", nil, target)
				return
			else
				print(("MythicPlusKeyAnnouncer: %s"):format(L["No whisper target set; sending to SAY."]))
				C_ChatInfo.SendChatMessage(msg, "SAY")
				return
			end
		end

		-- CHANNEL (expects numeric channel id)
		if chan == "CHANNEL" then
			local num = tonumber(target)
			if num and num > 0 then
				C_ChatInfo.SendChatMessage(msg, "CHANNEL", nil, tostring(num))
				return
			else
				print(("MythicPlusKeyAnnouncer: %s"):format(L["Invalid channel number; sending to SAY."]))
				C_ChatInfo.SendChatMessage(msg, "SAY")
				return
			end
		end

		-- Party/Raid/Instance/Guild/Yell/Say fallbacks
		if chan == "PARTY" and not IsInGroup() then
			C_ChatInfo.SendChatMessage(msg, "SAY")
			return
		elseif chan == "RAID" and not IsInRaid() then
			C_ChatInfo.SendChatMessage(msg, "SAY")
			return
		elseif chan == "INSTANCE_CHAT" and not IsInGroup() then
			C_ChatInfo.SendChatMessage(msg, "SAY")
			return
		end

		-- Default send
		C_ChatInfo.SendChatMessage(msg, chan)
	end)
end

-- Advanced /mpk handler placed after helpers so they are in scope
function LFGMythicPlus:ChatCommand(input)
	-- commands: /mpk, /mpk testpopup, /mpk last, /mpk resend
	local text = (input or ""):trim()
	if text == "" then
		AceConfigDialog:Open("MythicPlusKeyAnnouncer")
		return
	end
	local cmd, rest = text:match("^(%S+)%s*(.-)$")
	cmd = cmd and cmd:lower()

	if cmd == "testpopup" then
		local msg = currentLFGResults
		if not msg or msg == '' then
			msg = ("|cffFFD000 %s|r |cffDA70D6 TestDungeon:TestKey:15 |r"):format(L["Mythic Plus Key Group:"])
		end
		ShowGroupPopup(msg)
		return
	elseif cmd == "last" or cmd == "show" then
		if currentLFGResults and currentLFGResults ~= '' then
			print(currentLFGResults)
			ShowGroupPopup(currentLFGResults)
		else
			print(("MythicPlusKeyAnnouncer: %s"):format(L["No recent group found."]))
		end
		return
	elseif cmd == "resend" then
		if currentPlainLFGResults and currentPlainLFGResults ~= '' then
			if LFGMythicPlus.db.profile.announceToChat then
				SendToConfiguredChannel(currentPlainLFGResults)
				print(("MythicPlusKeyAnnouncer: %s"):format(L["Re-sent last announcement."]))
			else
				print(("MythicPlusKeyAnnouncer: %s"):format(L["Announcements are disabled; popup only."]))
			end
		else
			print(("MythicPlusKeyAnnouncer: %s"):format(L["No plain announcement available to resend."]))
		end
		return
	else
		-- unknown subcommand: open options
		AceConfigDialog:Open("MythicPlusKeyAnnouncer")
		return
	end
end

-- Handle LFG Join Group Event
function LFGMythicPlus:LFG_LIST_JOINED_GROUP(event, ...)
	local searchResultID = ...
	local msg = ''

	if searchResultID then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
		if searchResultInfo then
			for _, activitiID in pairs(searchResultInfo.activityIDs) do
				local activityInfoTable = C_LFGList.GetActivityInfoTable(activitiID)
				msg = (GetColorHex() .. " %s|r |cffDA70D6  %s:%s:%s |r"):format(
					L["Mythic Plus Key Group:"],
					activityInfoTable.fullName,
					tostring(searchResultInfo.name), tostring(searchResultInfo.comment))
				currentLFGResults = msg
				-- Send and store a plain-text version to the configured chat channel (strip color codes)
				local plainMsg = ("%s %s:%s:%s"):format(L["Mythic Plus Key Group:"],
					activityInfoTable.fullName,
					tostring(searchResultInfo.name), tostring(searchResultInfo.comment))
				currentPlainLFGResults = plainMsg
				SendToConfiguredChannel(plainMsg)
			end
		end
	end

	print(msg)
	if msg ~= '' and self.db.profile.showPopup then
		ShowGroupPopup(msg)
	end
end

-- Handle Group Leave
function LFGMythicPlus:GROUP_LEFT(event, ...)
	currentLFGResults = ''
end

-- Test announcement method invoked by the options panel button
function LFGMythicPlus:TestAnnouncement()
	local testDungeon, testKey, testLevel = "TestDungeon", "TestKey", "15"
	local colored = (GetColorHex() .. " %s|r |cffDA70D6  %s:%s:%s |r"):format(L["Mythic Plus Key Group:"], testDungeon,
		testKey,
		testLevel)
	local plain = ("%s %s:%s:%s"):format(L["Mythic Plus Key Group:"], testDungeon, testKey, testLevel)
	SendToConfiguredChannel(plain)
	ShowGroupPopup(colored)
end
