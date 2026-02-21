local _, CanOpenerGlobal = ...;
local buttons = {};

------------------------------------------------
-- Slash Commands
------------------------------------------------
local function toggleSavedVar(varName, description)
	CanOpenerSavedVars[varName] = not CanOpenerSavedVars[varName];
	CanOpenerGlobal.ForceButtonRefresh();
	CanOpenerGlobal.CanOut(": " .. description .. " " ..
		CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars[varName], "will", "will not") .. " be shown");
end

local function slashHandler(msg)
	CanOpenerGlobal.DebugLog("slashHandler - Start");
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	command = command:lower()
	CanOpenerGlobal.DebugLog("slashHandler - Command " .. command);

	if (command == "rousing") then
		toggleSavedVar("showRousing", "Elemental Rousings");
	elseif (CanOpenerGlobal.IsRemixActive and command == "remixgem") then
		toggleSavedVar("showRemixGems", "Remix Gems");
	elseif (CanOpenerGlobal.IsRemixActive and command == "remixepicgems") then
		CanOpenerSavedVars.remixEpicGems = not CanOpenerSavedVars.remixEpicGems;
		CanOpenerGlobal.ForceButtonRefresh();
		CanOpenerGlobal.CanOut(": Remix Gems " ..
			CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars.remixEpicGems, "will", "will not") ..
			" be combined higher than Epic");
	elseif (command == "levelrestricted") then
		toggleSavedVar("showLevelRestrictedItems", "Level-Restricted Items");
	elseif (command == "reset") then
		CanOpenerGlobal.DebugLog("slashHandler - Start Reset");
		CanOpenerGlobal.CanOut(": Resetting settings and position.");
		CanOpenerGlobal.ResetSavedVariables();
		CanOpenerGlobal.DebugLog("slashHandler - End Reset");
	elseif (command == "debug") then
		CanOpenerGlobal.DebugLog("slashHandler - Start Debug");
		CanOpenerGlobal.CanOut(": Turning Debug Mode " .. (CanOpenerGlobal.DebugMode and "off" or "on") .. ".");
		CanOpenerGlobal.DebugMode = not CanOpenerGlobal.DebugMode;
		CanOpenerGlobal.DebugLog("slashHandler - End Debug");
	elseif command == "ignore" and rest then
		CanOpenerGlobal.DebugLog("slashHandler - Start Ignore");
		local itemID = tonumber(rest)
		if itemID then
			CanOpenerSavedVars.excludedItems[itemID] = true
			CanOpenerGlobal.CanOut(": Ignoring item ID " .. itemID)
		else
			CanOpenerGlobal.CanOut(": Invalid item ID.")
		end
		CanOpenerGlobal.DebugLog("slashHandler - End Ignore");
	elseif command == "unignore" and rest then
		CanOpenerGlobal.DebugLog("slashHandler - Start Unignore");
		local itemID = tonumber(rest)
		if itemID and CanOpenerSavedVars.excludedItems[itemID] then
			CanOpenerSavedVars.excludedItems[itemID] = nil
			CanOpenerGlobal.CanOut(": Removed item ID " .. itemID .. " from ignore list.")
		else
			CanOpenerGlobal.CanOut(": Item ID not found in ignore list.")
		end
		CanOpenerGlobal.DebugLog("slashHandler - End Unignore");
	elseif command == "list" then
		CanOpenerGlobal.DebugLog("slashHandler - Start Ignore List");
		CanOpenerGlobal.CanOut(": Ignored Items List:")
		CanOpenerGlobal.CanOut(CanOpenerSavedVars.excludedItems);
		CanOpenerGlobal.DebugLog("slashHandler - End Ignore List");
	else
        CanOpenerGlobal.DebugLog("slashHandler - Unknown command " .. (command or "<None>"));
        CanOpenerGlobal.CanOut("Commands for |cffffa500/CanOpener|r :");
        local rousingState = CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars.showRousing, "On", "Off");
        CanOpenerGlobal.CanOut("  |cffffa500 rousing|r - Toggle showing Elemental Rousings (" .. rousingState .. ")");
        if (CanOpenerGlobal.IsRemixActive) then
            local remixGemsState = CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars.showRemixGems, "On", "Off");
            CanOpenerGlobal.CanOut("  |cffffa500 remixGem|r - Toggle showing Remix Gems (" .. remixGemsState .. ")");
            local remixEpicGemsState = CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars.remixEpicGems, "On", "Off");
            CanOpenerGlobal.CanOut("  |cffffa500 remixEpicGems|r - Toggle combining gems higher than Epic (" ..
                remixEpicGemsState .. ")");
        end
        local levelRestrictedState = CanOpenerGlobal.PosOrNegColor(CanOpenerSavedVars.showLevelRestrictedItems, "On", "Off");
        CanOpenerGlobal.CanOut("  |cffffa500 levelrestricted|r - Toggle showing level-restricted items (" .. levelRestrictedState .. ")");
        CanOpenerGlobal.CanOut("  |cffffa500 ignore|r <itemID> - Ignore a specific item");
        CanOpenerGlobal.CanOut("  |cffffa500 unignore|r <itemID> - Remove an item from the ignore list");
        CanOpenerGlobal.CanOut("  |cffffa500 list|r - Show ignored items");
        CanOpenerGlobal.CanOut("  |cffffa500 reset|r - Reset all settings!");
    end
	CanOpenerGlobal.DebugLog("slashHandler - End");
end

SlashCmdList.CanOpener = function(msg) slashHandler(msg) end;
SLASH_CanOpener1 = "/CanOpener";
SLASH_CanOpener2 = "/CO";

------------------------------------------------
-- Main Frame
------------------------------------------------
local frame = CreateFrame("Frame", "CanOpener_Frame", UIParent);
frame.ButtonCount = 0;
CanOpenerGlobal.Frame = frame;

frame:Hide();
frame:SetWidth(120);
frame:SetHeight(38);
frame:SetClampedToScreen(true);
frame:SetFrameStrata("BACKGROUND");
frame:SetMovable(true);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("BAG_UPDATE");
frame:RegisterEvent("BAG_UPDATE_DELAYED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_LEAVING_WORLD");
frame:RegisterEvent("PLAYER_REGEN_DISABLED");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");

frame:SetScript("OnEvent", function(self, event, ...)
	CanOpenerGlobal.DebugLog("OnEvent - Start");
	local eventAction = CanOpenerGlobal.Events[event];

	if (eventAction) then
		CanOpenerGlobal.DebugLog("OnEvent - Matched Event " .. event, ...);
		eventAction(...);
	end
	CanOpenerGlobal.DebugLog("OnEvent - End");
end);

frame:SetScript("OnShow", function(self, event, ...)
	CanOpenerGlobal.DebugLog("OnShow - Start");
	--Restore position
	self:ClearAllPoints();
	self:SetPoint(CanOpenerSavedVars.position[1], UIParent, CanOpenerSavedVars.position[2],
		CanOpenerSavedVars.position[3], CanOpenerSavedVars.position[4]);
	CanOpenerGlobal.DebugLog("OnShow - End");
end);

local function buttonOnLeave(btn)
	GameTooltip:Hide();
end

local function buttonOnEnter(btn)
	GameTooltip:SetOwner(btn, "ANCHOR_TOP");
	GameTooltip:SetItemByID(btn.itemID);
end

local function createButton(cacheDetails, id)
	CanOpenerGlobal.DebugLog("createButton - Start");
	CanOpenerGlobal.DebugLog("createButton - id " .. id);
	local btn = CreateFrame("Button", "CanOpener_" .. id, frame, "SecureActionButtonTemplate");
	cacheDetails.button = btn;
	btn.itemID = id;

	btn:Hide();
	btn:SetWidth(38);
	btn:SetHeight(38);
	btn:SetClampedToScreen(true);
	--Right click to drag
	btn:EnableMouse(true);
	btn:RegisterForDrag("RightButton");
	btn:SetMovable(true);
	btn:SetScript("OnDragStart", function(self) self:GetParent():StartMoving(); end);
	btn:SetScript("OnDragStop", function(self)
		self:GetParent():StopMovingOrSizing();
		self:GetParent():SetUserPlaced(false);
		local point, relativeTo, relativePoint, xOfs, yOfs = self:GetParent():GetPoint();
		CanOpenerSavedVars.position = { point, relativePoint, xOfs, yOfs };
	end);
	--Setup macro
	btn:SetAttribute("type", "macro");
	btn:SetAttribute("macrotext", format("/use item:%d", id));

	btn.countString = btn:CreateFontString(btn:GetName() .. "Count", "OVERLAY", "NumberFontNormal");
	btn.countString:SetPoint("BOTTOMRIGHT", btn, -0, 2);
	btn.countString:SetJustifyH("RIGHT");
	btn.icon = btn:CreateTexture(nil, "BACKGROUND");
	btn.icon:SetTexture(C_Item.GetItemIconByID(id));
	btn.texture = btn.icon;
	btn.texture:SetAllPoints();
	btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown");

	--Tooltip
	btn:SetScript("OnEnter", buttonOnEnter);
	btn:SetScript("OnLeave", buttonOnLeave);

	-- Hook a shift-right click to add the item to the per–character ignore list.
	btn:HookScript("OnMouseUp", function(self, button)
		if button == "RightButton" and IsShiftKeyDown() then
			local itemID = self.itemID
			local itemName = C_Item.GetItemNameByID(itemID);
			-- If not already ignored, add it; otherwise notify the user.
			if not CanOpenerSavedVars.excludedItems[itemID] then
				CanOpenerSavedVars.excludedItems[itemID] = true
				CanOpenerGlobal.CanOut(itemName .. " added to your ignore list.")
			else
				CanOpenerGlobal.CanOut(itemName .. " is already in your ignore list.")
			end
			CanOpenerGlobal.ForceButtonRefresh()
			-- Prevent any further processing of the click.
			return
		end
	end)

	CanOpenerGlobal.DebugLog("createButton - End");
end

local RefreshButtons = function()
	CanOpenerGlobal.DebugLog("RefreshButtons - Start");
	-- Don't do anything if we are in combat. Daddy Blizz says so.
	if (CanOpenerGlobal.LockDown) then
		CanOpenerGlobal.DebugLog("RefreshButtons - LOCK DOWN");
		return;
	end

	-- Hide all existing buttons
	for _, tbl in ipairs(buttons) do
		tbl.button:Hide();
	end
	wipe(buttons);

	-- Scan bags for openable items
	local visibleItems = {};
	local seen = {};
	for bagID = CanOpenerGlobal.BagIndicies.Backpack, CanOpenerGlobal.BagIndicies.ReagentBag, 1 do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemID = C_Container.GetContainerItemID(bagID, slot);
			local cacheDetails = CanOpenerGlobal.openables[itemID];
			local onExcludeList = CanOpenerSavedVars.excludedItems[itemID] or false;
			if itemID and cacheDetails and not onExcludeList and not seen[itemID] then
				local count = C_Item.GetItemCount(itemID);
				if count > 0 and CanOpenerGlobal.CriteriaContext:evaluateAll(itemID, cacheDetails, count) then
					table.insert(visibleItems, itemID);
					seen[itemID] = true;
				end
			end
		end
	end

	-- Sort by item ID for stable ordering
	table.sort(visibleItems);

	-- Create/show buttons
	local buttonIndex = 0;
	for _, itemID in ipairs(visibleItems) do
		local cacheDetails = CanOpenerGlobal.openables[itemID];

		if not cacheDetails.button then
			createButton(cacheDetails, itemID);
		end

		local button = cacheDetails.button;
		button:ClearAllPoints();
		SetButton(button, buttonIndex, itemID);
		button:Show();

		table.insert(buttons, { button = button, itemID = itemID });
		buttonIndex = buttonIndex + 1;
	end
	CanOpenerGlobal.DebugLog("RefreshButtons - End");
end
CanOpenerGlobal.RefreshButtons = RefreshButtons;

function SetButton(button, buttonIndex, itemID)
	button:SetPoint("LEFT", frame, "LEFT", buttonIndex * 38, 0);
	local count = C_Item.GetItemCount(itemID) or 0;
	button.countString:SetText(tostring(count));
	button.texture:SetDesaturated(false);
end
