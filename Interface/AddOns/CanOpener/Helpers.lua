local _, CanOpenerGlobal = ...
local shouldUpdateBags = false;
local addonName = "Can Opener";

------------------------------------------------
-- Global Settings
------------------------------------------------
CanOpenerGlobal.IsRemixActive = false;
CanOpenerGlobal.DebugMode = false;

------------------------------------------------
-- Debug Methods
------------------------------------------------
local canOut;
local canOutTable;

canOut = function(msg, premsg)
	premsg = premsg or "[Can Opener]";
	if type(msg) == "table" then
		canOutTable(msg, nil, premsg);
	else
		print("|cC0FFEE69" .. premsg .. "|r " .. msg);
	end
end
CanOpenerGlobal.CanOut = canOut;

canOutTable = function(table, indent, premsg)
	indent = indent or 0
	for key, value in pairs(table) do
		-- Format the indentation
		local formatting = string.rep("  ", indent) .. tostring(key) .. ": "

		-- If the value is a table, recursively call canOutTable
		if type(value) == "table" then
			canOut(formatting, premsg)
			canOutTable(value, indent + 1, premsg)
		else
			-- Otherwise, just print the value
			canOut(formatting .. tostring(value), premsg)
		end
	end
end

local function debugLog(...)
	if CanOpenerGlobal and CanOpenerGlobal.DebugMode and DLAPI and DLAPI.DebugLog then DLAPI.DebugLog(addonName, ...) end
end
CanOpenerGlobal.DebugLog = debugLog;

local colors = {
	LIGHTBLUE = 'ff00ccff',
	LIGHTRED = 'ffff6060',
	SPRINGGREEN = 'ff00FF7F',
	GREENYELLOW = 'ffADFF2F',
	BLUE = 'ff0000ff',
	PURPLE = 'ffDA70D6',
	GREEN = 'ff00ff00',
	RED = 'ffff0000',
	GOLD = 'ffffcc00',
	GOLD2 = 'ffFFC125',
	GREY = 'ff888888',
	WHITE = 'ffffffff',
	SUBWHITE = 'ffbbbbbb',
	MAGENTA = 'ffff00ff',
	YELLOW = 'ffffff00',
	ORANGEY = 'ffFF4500',
	CHOCOLATE = 'ffCD661D',
	CYAN = 'ff00ffff',
	IVORY = 'ff8B8B83',
	LIGHTYELLOW = 'ffFFFFE0',
	SEXGREEN = 'ff71C671',
	SEXTEAL = 'ff388E8E',
	SEXPINK = 'ffC67171',
	SEXBLUE = 'ff00E5EE',
	SEXHOTPINK = 'ffFF6EB4',
	CANOPENERBUMBER = 'c0ffee69'
};
CanOpenerGlobal.Colors = colors;

local function colorizeText(text, color)
	return "|c" .. colors[color] .. text .. "|r";
end
CanOpenerGlobal.ColorizeText = colorizeText;

local function posOrNegColor(test, positiveText, negativeText)
    local color = test and "SPRINGGREEN" or "LIGHTRED"
    local text = test and positiveText or negativeText
    return colorizeText(text, color)
end
CanOpenerGlobal.PosOrNegColor = posOrNegColor;

------------------------------------------------
-- Saved Variable Management
------------------------------------------------
local function initSavedVariables()
	CanOpenerSavedVars = {
		enable = true,
		showRousing = true,
		showRemixGems = true,
		remixEpicGems = true,
		showLevelRestrictedItems = true,
		position = { "CENTER", "CENTER", 0, 0 },
		excludedItems = { },
	};
end
local function UpdateSavedVars()
	-- Added Excluded Items
	if CanOpenerSavedVars.excludedItems == nil then
		CanOpenerSavedVars.excludedItems = {};
	end
end
local function resetSavedVariables()
	debugLog(CanOpenerGlobal.Frame);
	CanOpenerGlobal.DebugLog("resetSavedVariables - Start");
	initSavedVariables();
	CanOpenerGlobal.DebugLog(CanOpenerSavedVars);
	CanOpenerGlobal.Frame:Hide();
	CanOpenerGlobal.Frame:Show();
	CanOpenerGlobal.ForceButtonRefresh();
	CanOpenerGlobal.DebugLog("resetSavedVariables - End");
end
CanOpenerGlobal.ResetSavedVariables = resetSavedVariables;

------------------------------------------------
-- Event actions
------------------------------------------------
local function addon_Loaded(addOnName)
	CanOpenerGlobal.DebugLog("resetSavedVariables - Start");
	if addOnName == "CanOpener" then
		CanOpenerGlobal.DebugLog("0 - Addon Loaded");
		CanOpenerGlobal.Frame:UnregisterEvent("ADDON_LOADED");
		if CanOpenerSavedVars == nil then
			initSavedVariables();
		end
		UpdateSavedVars();
        InitSettingsMenu();
	end
	CanOpenerGlobal.DebugLog("resetSavedVariables - End");
end

local function bag_update(bagID)
	CanOpenerGlobal.DebugLog("bag_update - Start");
	CanOpenerGlobal.DebugLog("bag_update - bagID " .. bagID);
	if (CanOpenerGlobal.BagIndicies.Backpack <= bagID and bagID <= CanOpenerGlobal.BagIndicies.ReagentBag) then
		shouldUpdateBags = true;
	end
	CanOpenerGlobal.DebugLog("bag_update - End");
end

local function bag_update_delayed()
	CanOpenerGlobal.DebugLog("bag_update_delayed - Start");
	if not CanOpenerGlobal.LockDown and shouldUpdateBags then
		shouldUpdateBags = false;
		CanOpenerGlobal.RefreshButtons();
	end
	CanOpenerGlobal.DebugLog("bag_update_delayed - End");
end

local function player_entering_world(isInitialLogin, isReloadingUi)
	CanOpenerGlobal.DebugLog("player_entering_world - Start");
	CanOpenerGlobal.DebugLog(
		"player_entering_world - isInitialLogin " ..
		tostring(isInitialLogin) .. " | isReloadingUi " .. tostring(isReloadingUi));

	CanOpenerGlobal.Frame:Show();
	CanOpenerGlobal.DebugLog("player_entering_world - End");
end

local function player_leaving_world()
	CanOpenerGlobal.DebugLog("player_leaving_world - Start");
	CanOpenerGlobal.DebugLog("player_leaving_world - End");
end

local function player_regen_disabled()
	CanOpenerGlobal.DebugLog("player_regen_disabled - Start");
	CanOpenerGlobal.Frame:Hide();
	CanOpenerGlobal.LockDown = true;
	CanOpenerGlobal.DebugLog("player_regen_disabled - End");
end

local function player_regen_enabled()
	CanOpenerGlobal.DebugLog("player_regen_enabled - Start");
	CanOpenerGlobal.LockDown = false;
	bag_update_delayed();
	CanOpenerGlobal.Frame:Show();
	CanOpenerGlobal.DebugLog("player_regen_enabled - End");
end

CanOpenerGlobal.Events = {
	["ADDON_LOADED"] = addon_Loaded,
	["BAG_UPDATE"] = bag_update,
	["BAG_UPDATE_DELAYED"] = bag_update_delayed,
	["PLAYER_ENTERING_WORLD"] = player_entering_world,
	["PLAYER_LEAVING_WORLD"] = player_leaving_world,
	["PLAYER_REGEN_DISABLED"] = player_regen_disabled,
	["PLAYER_REGEN_ENABLED"] = player_regen_enabled,
};

CanOpenerGlobal.ForceButtonRefresh = function()
	shouldUpdateBags = true;
	bag_update_delayed();
end
------------------------------------------------
-- Enums
------------------------------------------------
CanOpenerGlobal.BagIndicies = {
	["Backpack"] = 0,
	["Bag_1"] = 1,
	["Bag_2"] = 2,
	["Bag_3"] = 3,
	["Bag_4"] = 4,
	["ReagentBag"] = 5,
};
