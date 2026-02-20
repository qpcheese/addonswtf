local addonName, ns = ...

local FRAME_WIDTH = 260
local ROW_HEIGHT = 22
local TITLE_HEIGHT = 28
local PADDING = 8
local MAX_VISIBLE_ROWS = 16
local SCROLL_STEP = 3

local COLORS = {
    done = { 0.3, 1.0, 0.3 },           -- Green: confirmed via hologram
    unconfirmed = { 1.0, 0.82, 0.0 },    -- Yellow: detected but not yet confirmed
    todo = { 1.0, 1.0, 1.0 },
    hint = { 0.6, 0.6, 0.6 },
    title = { 0.6, 0.85, 1.0 },
    bg = { 0.08, 0.08, 0.08, 0.85 },
    border = { 0.3, 0.3, 0.3, 0.8 },
    titleBg = { 0.12, 0.12, 0.12, 0.95 },
    highlight = { 1, 1, 1, 0.05 },
}

-- Map ID to zone name for /way display
local MAP_NAMES = {
    [22] = "Western Plaguelands", [62] = "Darkshore", [83] = "Winterspring",
    [111] = "Shattrath City", [116] = "Grizzly Hills", [120] = "The Storm Peaks",
    [542] = "Spires of Arak", [627] = "Dalaran", [630] = "Azsuna",
    [646] = "Broken Shore", [863] = "Nazmir", [864] = "Vol'dun",
    [885] = "Antoran Wastes", [896] = "Drustvar", [1355] = "Nazjatar",
    [1525] = "Revendreth", [1533] = "Bastion", [1536] = "Maldraxxus",
    [1543] = "The Maw", [1970] = "Zereth Mortis", [2022] = "Waking Shores",
    [2023] = "Ohn'ahran Plains", [2339] = "Dornogal", [2371] = "K'aresh",
    [2375] = "Siren Isle",
}

-- Pearl of the Abyss: the final destination when 17+ secrets are done
local PEARL_WAYPOINT = { mapID = 203, x = 0.2645, y = 0.7167 }  -- Vashj'ir: Abyssal Depths
local PEARL_SAFE_WP  = { mapID = 203, x = 0.2645, y = 0.6620 }  -- Safe spot before fatigue
local BANNER_HEIGHT = 40

local function GetSortedIndices()
    local incomplete, unconfirmed, confirmed = {}, {}, {}
    for i, secret in ipairs(ns.secrets) do
        if ns.confirmed[i] then
            table.insert(confirmed, i)
        elseif ns.results[i] then
            table.insert(unconfirmed, i)
        else
            table.insert(incomplete, i)
        end
    end
    -- Incomplete first, then unconfirmed (yellow), then confirmed (green)
    local sorted = {}
    for _, idx in ipairs(incomplete) do table.insert(sorted, idx) end
    for _, idx in ipairs(unconfirmed) do table.insert(sorted, idx) end
    for _, idx in ipairs(confirmed) do table.insert(sorted, idx) end
    return sorted
end

local function HasWaypoint(secret)
    return secret.waypoint and secret.waypoint[1] ~= nil
end

local function SetTomTomWaypoint(secret)
    if not HasWaypoint(secret) then return end
    local mapID, x, y = secret.waypoint[1], secret.waypoint[2], secret.waypoint[3]
    -- TomTom needs numeric mapID and 0-1 coords; skip if mapID is a string
    if TomTom and TomTom.AddWaypoint and type(mapID) == "number" then
        -- Normalize coords: if > 1, they're in xx.x format, convert to 0-1
        local tx = x > 1 and (x / 100) or x
        local ty = y > 1 and (y / 100) or y
        TomTom:AddWaypoint(mapID, tx, ty, { title = secret.name })
        print("|cff00ccffMind-Seekers Tracker:|r Waypoint set for " .. secret.name)
    else
        local zoneName = type(mapID) == "string" and mapID or (MAP_NAMES[mapID] or ("Map " .. mapID))
        local dx = x > 1 and x or (x * 100)
        local dy = y > 1 and y or (y * 100)
        print("|cff00ccffMind-Seekers Tracker:|r TomTom not found. Use: /way " ..
            zoneName .. " " .. string.format("%.1f", dx) .. " " .. string.format("%.1f", dy))
    end
end

-- Build the tracker frame
function ns:BuildUI()
    local db = ns:GetDB()

    -- Main frame
    local tracker = CreateFrame("Frame", "MindSeekersTrackerFrame", UIParent, "BackdropTemplate")
    tracker:SetSize(FRAME_WIDTH, TITLE_HEIGHT + PADDING)
    tracker:SetPoint(db.point, UIParent, db.point, db.x, db.y)
    tracker:SetFrameStrata("MEDIUM")
    tracker:SetClampedToScreen(true)
    tracker:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    tracker:SetBackdropColor(unpack(COLORS.bg))
    tracker:SetBackdropBorderColor(unpack(COLORS.border))
    ns.tracker = tracker

    -- Title bar (separate frame for dragging)
    local titleBar = CreateFrame("Frame", nil, tracker, "BackdropTemplate")
    titleBar:SetHeight(TITLE_HEIGHT)
    titleBar:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    titleBar:SetBackdropColor(unpack(COLORS.titleBg))

    -- Make draggable via title bar
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        tracker:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        tracker:StopMovingOrSizing()
        local point, _, _, x, y = tracker:GetPoint()
        db.point = point
        db.x = x
        db.y = y
    end)
    tracker:SetMovable(true)

    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", PADDING, 0)
    titleText:SetTextColor(unpack(COLORS.title))
    ns.titleText = titleText

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(TITLE_HEIGHT - 6, TITLE_HEIGHT - 6)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
    closeBtn:SetNormalFontObject("GameFontNormal")
    closeBtn:SetText("x")
    closeBtn:GetFontString():SetTextColor(0.7, 0.7, 0.7)
    closeBtn:SetScript("OnClick", function()
        tracker:Hide()
        db.shown = false
    end)
    closeBtn:SetScript("OnEnter", function(self)
        self:GetFontString():SetTextColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:GetFontString():SetTextColor(0.7, 0.7, 0.7)
    end)

    -- Info button
    local infoBtn = CreateFrame("Button", nil, titleBar)
    infoBtn:SetSize(TITLE_HEIGHT - 6, TITLE_HEIGHT - 6)
    infoBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    infoBtn:SetNormalFontObject("GameFontNormal")
    infoBtn:SetText("i")
    infoBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
    infoBtn:SetScript("OnEnter", function(self)
        self:GetFontString():SetTextColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Mind-Seeker Notes", 0.6, 0.85, 1.0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff4ce64cGreen|r = Confirmed via hologram in the Seat of Knowledge", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("|cffd1d100Yellow|r = Detected (you have the item) but not yet confirmed", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("|cffff4d4dRed|r = Incomplete", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Hover over the Record holograms in the Seat of Knowledge to confirm your completed secrets. AH purchases (e.g. Phoenix Wishwing, Courage) won't show holograms.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("The hidden tracking quest for the Sun Darter Hatchling currently resets weekly due to a bug. Once confirmed via hologram, it stays green.", 1, 0.5, 0.3, true)
        GameTooltip:Show()
    end)
    infoBtn:SetScript("OnLeave", function(self)
        self:GetFontString():SetTextColor(0.5, 0.5, 0.5)
        GameTooltip:Hide()
    end)

    -- Collapse button
    local collapseBtn = CreateFrame("Button", nil, titleBar)
    collapseBtn:SetSize(TITLE_HEIGHT - 6, TITLE_HEIGHT - 6)
    collapseBtn:SetPoint("RIGHT", infoBtn, "LEFT", -2, 0)
    collapseBtn:SetNormalFontObject("GameFontNormal")
    ns.collapseBtn = collapseBtn
    collapseBtn:SetScript("OnEnter", function(self)
        self:GetFontString():SetTextColor(1, 1, 0.3)
    end)
    collapseBtn:SetScript("OnLeave", function(self)
        self:GetFontString():SetTextColor(0.7, 0.7, 0.7)
    end)

    -- Content container (below title bar)
    local content = CreateFrame("Frame", nil, tracker)
    content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    ns.content = content

    -- Ready banner — shown when 17+ secrets complete
    local banner = CreateFrame("Button", nil, content, "BackdropTemplate")
    banner:SetHeight(BANNER_HEIGHT)
    banner:SetPoint("TOPLEFT", content, "TOPLEFT", 1, 0)
    banner:SetPoint("TOPRIGHT", content, "TOPRIGHT", -1, 0)
    banner:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    banner:SetBackdropColor(0.1, 0.25, 0.1, 0.9)
    banner:Hide()
    ns.banner = banner

    -- Achievement icon (shown only when earned)
    local bannerIcon = banner:CreateTexture(nil, "ARTWORK")
    bannerIcon:SetSize(BANNER_HEIGHT - 6, BANNER_HEIGHT - 6)
    bannerIcon:SetPoint("LEFT", banner, "LEFT", 6, 0)
    bannerIcon:SetTexture(6035316)
    bannerIcon:Hide()
    ns.bannerIcon = bannerIcon

    local bannerLine1 = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bannerLine1:SetPoint("TOP", banner, "TOP", 0, -5)
    bannerLine1:SetTextColor(0.3, 1.0, 0.3)
    bannerLine1:SetText("Go to the Pearl of the Abyss!")
    ns.bannerLine1 = bannerLine1

    local bannerLine2 = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bannerLine2:SetPoint("TOP", bannerLine1, "BOTTOM", 0, -2)
    bannerLine2:SetTextColor(0.6, 0.6, 0.6)
    bannerLine2:SetText("Vashj'ir - Abyssal Depths (click for waypoint)")
    ns.bannerLine2 = bannerLine2

    banner:RegisterForClicks("AnyUp")
    banner:SetScript("OnClick", function()
        if TomTom and TomTom.AddWaypoint then
            TomTom:AddWaypoint(PEARL_SAFE_WP.mapID, PEARL_SAFE_WP.x, PEARL_SAFE_WP.y,
                { title = "Pearl of the Abyss (safe spot)" })
            TomTom:AddWaypoint(PEARL_WAYPOINT.mapID, PEARL_WAYPOINT.x, PEARL_WAYPOINT.y,
                { title = "Pearl of the Abyss" })
            print("|cff00ccffMind-Seekers Tracker:|r Waypoints set for Pearl of the Abyss in Vashj'ir")
        else
            print("|cff00ccffMind-Seekers Tracker:|r TomTom not found. Use:")
            print("  /way Vashj'ir: Abyssal Depths 26.5 66.2  (safe spot)")
            print("  /way Vashj'ir: Abyssal Depths 26.5 71.7  (pearl)")
        end
    end)
    banner:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Pearl of the Abyss", 0.3, 1.0, 0.3)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Head to Vashj'ir and swim to the Pearl in", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("fatigue waters south of the Abyssal Depths.", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("Bring water breathing + aquatic mount!", 1, 0.8, 0.3)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("/way #13 26.45 70.6  Safe Location", 0.8, 0.8, 0.5)
        GameTooltip:AddLine("/way #13 26.45 71.67  Pearl", 0.8, 0.8, 0.5)
        GameTooltip:AddLine(" ")
        if TomTom and TomTom.AddWaypoint then
            GameTooltip:AddLine("Click to set TomTom waypoints", 0.2, 1, 0.2)
        else
            GameTooltip:AddLine("Install TomTom for click-to-waypoint", 0.5, 0.5, 0.5)
        end
        GameTooltip:Show()
    end)
    banner:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Create row pool
    ns.rows = {}
    ns.scrollOffset = 0
    ns.sortedIndices = {}

    for i = 1, MAX_VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, content)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i - 1) * ROW_HEIGHT))
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((i - 1) * ROW_HEIGHT))

        -- Highlight texture
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(unpack(COLORS.highlight))

        -- Status icon (checkmark or X)
        local icon = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        icon:SetPoint("LEFT", row, "LEFT", PADDING, 0)
        icon:SetWidth(16)
        row.icon = icon

        -- Name text
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        name:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", row, "RIGHT", -PADDING, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        row.name = name

        row:RegisterForClicks("AnyUp")
        row:SetScript("OnClick", function(self)
            if self.secretIndex then
                local secret = ns.secrets[self.secretIndex]
                if secret and not ns.results[self.secretIndex] and not ns.confirmed[self.secretIndex] then
                    SetTomTomWaypoint(secret)
                end
            end
        end)

        row:SetScript("OnEnter", function(self)
            if not self.secretIndex then return end
            local secret = ns.secrets[self.secretIndex]
            if not secret then return end

            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()

            local status
            if ns.confirmed[self.secretIndex] then
                status = "|cff00ff00Confirmed|r"
            elseif ns.results[self.secretIndex] then
                status = "|cffd1d100Detected — not yet confirmed|r"
            else
                status = "|cffff4444Incomplete|r"
            end
            GameTooltip:AddLine(secret.name, unpack(COLORS.title))
            GameTooltip:AddLine(status, 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(secret.hint, unpack(COLORS.hint))

            if HasWaypoint(secret) then
                local mapID, x, y = secret.waypoint[1], secret.waypoint[2], secret.waypoint[3]
                local zoneName = type(mapID) == "string" and mapID or (MAP_NAMES[mapID] or ("Map " .. mapID))
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("/way " .. zoneName .. " " ..
                    string.format("%.1f", x) .. " " .. string.format("%.1f", y),
                    0.8, 0.8, 0.5)
            end

            if not ns.results[self.secretIndex] and not ns.confirmed[self.secretIndex] then
                GameTooltip:AddLine(" ")
                if TomTom and TomTom.AddWaypoint then
                    GameTooltip:AddLine("Click to set TomTom waypoint", 0.2, 1, 0.2)
                else
                    GameTooltip:AddLine("Install TomTom for click-to-waypoint", 0.5, 0.5, 0.5)
                end
            end

            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        ns.rows[i] = row
    end

    -- Mouse wheel scrolling
    tracker:EnableMouseWheel(true)
    tracker:SetScript("OnMouseWheel", function(self, delta)
        if db.collapsed then return end
        local maxOffset = math.max(0, #ns.sortedIndices - MAX_VISIBLE_ROWS)
        ns.scrollOffset = math.max(0, math.min(ns.scrollOffset - delta * SCROLL_STEP, maxOffset))
        ns:RefreshRows()
    end)

    -- Collapse toggle
    collapseBtn:SetScript("OnClick", function()
        db.collapsed = not db.collapsed
        ns:RefreshUI()
    end)

    -- Initial refresh
    ns:RefreshUI()

    -- Show/hide based on saved state
    if db.shown then
        tracker:Show()
    else
        tracker:Hide()
    end
end

function ns:RefreshUI()
    if not ns.tracker then return end
    local db = ns:GetDB()
    -- Update title with achievement / confirmed / detected status
    local titleStr
    if ns.achievementEarned then
        titleStr = "|cff00ff00Mind-Seeker|r (" .. ns.completedCount .. "/31)"
    else
        titleStr = "Mind-Seeker (" .. ns.completedCount .. "/31)"
        if ns.confirmedCount >= 17 then
            titleStr = titleStr .. " |cff00ff00Ready!|r"
        elseif ns.completedCount >= 17 then
            titleStr = titleStr .. " |cffd1d100Ready?|r"
        else
            local needed = math.max(0, 17 - ns.completedCount)
            titleStr = titleStr .. " — need " .. needed
        end
    end
    ns.titleText:SetText(titleStr)

    -- Update collapse button
    ns.collapseBtn:SetText(db.collapsed and "+" or "-")
    ns.collapseBtn:GetFontString():SetTextColor(0.7, 0.7, 0.7)

    if db.collapsed then
        ns.content:Hide()
        ns.tracker:SetHeight(TITLE_HEIGHT)
    else
        ns.content:Show()
        ns.sortedIndices = GetSortedIndices()

        -- Show/hide ready banner
        local bannerOffset = 0
        if ns.banner then
            if ns.achievementEarned then
                ns.banner:Show()
                bannerOffset = BANNER_HEIGHT
                ns.banner:SetBackdropColor(0.15, 0.1, 0.25, 0.9)
                ns.bannerIcon:Show()
                ns.bannerLine1:ClearAllPoints()
                ns.bannerLine1:SetPoint("TOP", ns.banner, "TOP", 14, -5)
                ns.bannerLine1:SetText("Mind-Seeker Achieved!")
                ns.bannerLine1:SetTextColor(0.7, 0.5, 1.0)
                ns.bannerLine2:SetText("Click for Pearl of the Abyss waypoint")
                ns.bannerLine2:SetTextColor(0.5, 0.5, 0.5)
            elseif ns.completedCount >= 17 then
                ns.banner:Show()
                bannerOffset = BANNER_HEIGHT
                ns.bannerIcon:Hide()
                ns.bannerLine1:ClearAllPoints()
                ns.bannerLine1:SetPoint("TOP", ns.banner, "TOP", 0, -5)
                ns.bannerLine1:SetText("Go to the Pearl of the Abyss!")
                ns.bannerLine2:SetText("Vashj'ir - Abyssal Depths (click for waypoint)")
                if ns.confirmedCount >= 17 then
                    ns.banner:SetBackdropColor(0.1, 0.25, 0.1, 0.9)
                    ns.bannerLine1:SetTextColor(0.3, 1.0, 0.3)
                else
                    ns.banner:SetBackdropColor(0.25, 0.2, 0.05, 0.9)
                    ns.bannerLine1:SetTextColor(1.0, 0.82, 0.0)
                end
            else
                ns.banner:Hide()
            end
        end

        -- Reposition rows below banner
        for i = 1, MAX_VISIBLE_ROWS do
            local row = ns.rows[i]
            row:SetPoint("TOPLEFT", ns.content, "TOPLEFT", 0, -(bannerOffset + (i - 1) * ROW_HEIGHT))
            row:SetPoint("TOPRIGHT", ns.content, "TOPRIGHT", 0, -(bannerOffset + (i - 1) * ROW_HEIGHT))
        end

        local visibleRows = math.min(#ns.sortedIndices, MAX_VISIBLE_ROWS)
        local contentHeight = bannerOffset + visibleRows * ROW_HEIGHT
        ns.content:SetHeight(contentHeight)
        ns.tracker:SetHeight(TITLE_HEIGHT + contentHeight + 2)
        ns:RefreshRows()
    end
end

function ns:RefreshRows()
    if not ns.rows then return end
    local sorted = ns.sortedIndices

    for i = 1, MAX_VISIBLE_ROWS do
        local row = ns.rows[i]
        local dataIndex = i + ns.scrollOffset
        if dataIndex <= #sorted then
            local secretIdx = sorted[dataIndex]
            local secret = ns.secrets[secretIdx]
            local done = ns.results[secretIdx]
            row.secretIndex = secretIdx

            local confirmed = ns.confirmed[secretIdx]
            if confirmed then
                -- Green: confirmed via hologram in Seat of Knowledge
                row.icon:SetText("|cff4ce64cO|r")
                row.icon:SetTextColor(0.3, 1.0, 0.3)
                row.name:SetText(secret.name)
                row.name:SetTextColor(0.4, 0.7, 0.4)
            elseif done then
                -- Yellow: detected (have the collectible) but not confirmed
                row.icon:SetText("|cffd1d100O|r")
                row.icon:SetTextColor(1.0, 0.82, 0.0)
                row.name:SetText(secret.name)
                row.name:SetTextColor(0.8, 0.65, 0.1)
            else
                -- Red: incomplete
                row.icon:SetText("|cffff4d4dX|r")
                row.icon:SetTextColor(1.0, 0.3, 0.3)
                row.name:SetText(secret.name)
                row.name:SetTextColor(1, 1, 1)
            end

            row:Show()
        else
            row.secretIndex = nil
            row:Hide()
        end
    end
end
