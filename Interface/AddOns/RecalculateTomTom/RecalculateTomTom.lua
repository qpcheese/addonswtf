-- RecalculateTomTom
-- Left-click the CrazyArrow to run /cway (SetClosestWaypoint)
-- Middle-click the CrazyArrow to remove the active arrow waypoint

local RecalculateTomTom = {}
RecalculateTomTom.ENABLED = true

local activeArrowRef = nil
local hookInstalled = false
local arrowHookInstalled = false

-- Double-click protection
local lastActionTime = 0
local ACTION_COOLDOWN = 0.5

-- Checks
local function IsCoordinateUID(uid)
    return type(uid) == "table" and type(uid[2]) == "number" and type(uid[3]) == "number"
end

local function LooksLikeTomTomModule(t)
    return type(t) == "table" and type(t.SetCrazyArrow) == "function" and type(t.RemoveWaypoint) == "function"
end

-- TomTom calls 
local function TryRemoveWaypoint(uid)
    if not uid then return false, "nil" end
    if LooksLikeTomTomModule(uid) then return false, "looks like module" end
    if not TomTom or type(TomTom.RemoveWaypoint) ~= "function" then return false, "TomTom API missing" end
    local ok, err = pcall(function() TomTom:RemoveWaypoint(uid) end)
    return ok, err
end

local function RemoveActiveArrowWaypoint()
    local now = GetTime()
    if now - lastActionTime < ACTION_COOLDOWN then
        return
    end
    lastActionTime = now

    if not activeArrowRef then
        return
    end
    if IsCoordinateUID(activeArrowRef) then
        local ok, err = TryRemoveWaypoint(activeArrowRef)
        if ok then
            activeArrowRef = nil
        end
        return
    end
end


local function SetArrowToClosest(ignoreCooldown)
    local now = GetTime()
    if not ignoreCooldown and (now - lastActionTime < ACTION_COOLDOWN) then
        return
    end
    lastActionTime = now

    if not TomTom or type(TomTom.SetClosestWaypoint) ~= "function" then
        return
    end
    pcall(function() TomTom:SetClosestWaypoint(false) end)
end

local function RemoveActiveArrowWaypoint()
    local now = GetTime()
    if now - lastActionTime < ACTION_COOLDOWN then
        return
    end
    lastActionTime = now

    if not activeArrowRef then
        return
    end
    if IsCoordinateUID(activeArrowRef) then
        local ok, err = TryRemoveWaypoint(activeArrowRef)
        if ok then
            activeArrowRef = nil
            -- Let TomTom update, then force arrow to closest without cooldown blocking
            C_Timer.After(0.05, function()
                -- Optional: guard to avoid doing this if no waypoints remain
                if TomTom and TomTom.waypoints and next(TomTom.waypoints) then
                    SetArrowToClosest(true)
                end
            end)
        end
        return
    end
end

-- SetCrazyArrow hook
local function InstallSetCrazyArrowHook()
    if hookInstalled then return end
    if not TomTom then C_Timer.After(1, InstallSetCrazyArrowHook); return end
    if type(TomTom.SetCrazyArrow) ~= "function" then C_Timer.After(1, InstallSetCrazyArrowHook); return end

    hooksecurefunc(TomTom, "SetCrazyArrow", function(...)
        local a1, a2 = ...
        local captured = nil
        if LooksLikeTomTomModule(a1) then captured = a2 else captured = a1 end
        if captured == nil then
            for i = 2, select("#", ...) do
                local v = select(i, ...)
                if v ~= nil then captured = v; break end
            end
        end
        activeArrowRef = captured
    end)

    hookInstalled = true
end

-- arrow frame hook
-- LeftButton => SetClosestWaypoint (cway)
-- MiddleButton => remove active arrow waypoint
local function InstallArrowFrameHook()
    if arrowHookInstalled then return end
    local arrow = _G.TomTomCrazyArrow
    if not arrow then C_Timer.After(1, InstallArrowFrameHook); return end
    if arrow.__TomTomClickHookInstalled then arrowHookInstalled = true; return end
    arrow.__TomTomClickHookInstalled = true

    arrow:EnableMouse(true)

    arrow:SetScript("OnMouseUp", function(self, button)
        if not RecalculateTomTom.ENABLED then return end
		if not IsModifierKeyDown() then return end

		 -- captured ref 
        local ref = activeArrowRef
        if self.waypoint ~= nil then ref = self.waypoint end
        if self.uid ~= nil then ref = self.uid end
        if TomTom and TomTom.lastCrazyArrow ~= nil then ref = TomTom.lastCrazyArrow end
        activeArrowRef = ref

        if button == "LeftButton" then
            SetArrowToClosest()
            return
        elseif button == "MiddleButton" then
            if LooksLikeTomTomModule(activeArrowRef) then
                return
            end
            RemoveActiveArrowWaypoint()
            return
        end
    end)

    arrowHookInstalled = true
end

-- SavedVariables handling and ADDON_LOADED 
local function LoadSavedVars()
    RecalculateTomTomDB = RecalculateTomTomDB or {}
    if type(RecalculateTomTomDB.enabled) == "boolean" then
        RecalculateTomTom.ENABLED = RecalculateTomTomDB.enabled
    else
        RecalculateTomTomDB.enabled = RecalculateTomTom.ENABLED
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, name)
    if name ~= "RecalculateTomTom" then return end

    LoadSavedVars()

    -- Install hooks 
    InstallSetCrazyArrowHook()
    InstallArrowFrameHook()

    self:UnregisterEvent("ADDON_LOADED")
end)

-- Fallback timers 
C_Timer.After(1, function()
    if not hookInstalled or not arrowHookInstalled then
        InstallSetCrazyArrowHook()
        InstallArrowFrameHook()
    end
end)
C_Timer.After(3, function()
    if not hookInstalled or not arrowHookInstalled then
        InstallSetCrazyArrowHook()
        InstallArrowFrameHook()
    end
end)

-- Slash commands (primary /rtt, alias /recaltt) 
SLASH_RECALCULATETT1 = "/rtt"
SLASH_RECALCULATETT2 = "/recaltt"
SlashCmdList["RECALCULATETT"] = function(msg)
    local cmd = (msg or ""):match("^%s*(%S*)") or ""
    cmd = cmd:lower()

    if cmd == "toggle" then
        RecalculateTomTom.ENABLED = not RecalculateTomTom.ENABLED
        RecalculateTomTomDB = RecalculateTomTomDB or {}
        RecalculateTomTomDB.enabled = RecalculateTomTom.ENABLED
        print("RecalculateTomTom enabled =", tostring(RecalculateTomTom.ENABLED))
        return
    end

    -- help output
    print("|cffffd700[RTT]|r|cff00ff00  /rtt or /recaltt toggle|r - To enable / disable")
    print("|cffffd700[RTT]|r|cff00ff00  MOD+Left click the arrow to set closest waypoint to the arrow; MOD+Middle click clears the arrow's current waypoint|r")
end
