-- ============================================================================
-- Vamoose's Endeavors - XP Engine
-- Pure XP calculation module with strict per-GUID isolation.
-- No events, no UI, no Store dispatches. EndeavorTracker feeds data in;
-- UI reads results out via public API.
--
-- XP MODEL:  xp = amount / neighborhood_scale
--
-- SCALE is per-neighborhood (varies with roster size).
--   Persisted in VE_DB.neighborhoodScales; updated by EndeavorTracker.
--
-- NON-REPEATABLE tasks (Profession Rare, Weekly Quests, Faction Envoy):
--   Excluded from XP calculation entirely.
--
-- ZERO-AMOUNT FALLBACK: When the house hits the weekly XP cap, Blizzard
--   reports amount=0 for new completions. We substitute the oldest known
--   positive amount for the same task (post-cutoff only).
--
-- CAPS:
--   Pre-Jan29 cap: 1000 XP (cutoff: ~Jan 28 2026 17:00 UTC)
--   Cumulative cap: 2250 XP (pre + post combined)
-- ============================================================================

VE = VE or {}
VE.XPEngine = {}

local XPEngine = VE.XPEngine

-- ============================================================================
-- Constants
-- ============================================================================

local SCALE_CHANGE_CUTOFF   = 1769620000  -- ~Jan 28, 2026 17:00 UTC
local PRE_JAN29_CAP         = 1000
local POST_JAN29_CAP        = 2250
local COMPLETIONS_TO_FLOOR  = 5           -- used by CalculateNextContribution

-- Non-repeatable tasks: excluded from XP calculation entirely.
local NON_REPEATABLE = {
    ["Kill a Profession Rare"]                    = true,
    ["Home: Complete Weekly Neighborhood Quests"] = true,
    ["Champion a Faction Envoy"]                  = true,
}

-- ============================================================================
-- Private State
-- ============================================================================

local contexts  = {}   -- [guid] -> GUIDContext
local activeGUID = nil -- output queries read from this

-- ============================================================================
-- Persistence Helpers
-- ============================================================================

local function saveScale(guid, scale)
    if not guid then return end
    if not scale or scale <= 0 or scale ~= scale or scale == math.huge then return end
    VE_DB = VE_DB or {}
    VE_DB.neighborhoodScales = VE_DB.neighborhoodScales or {}
    VE_DB.neighborhoodScales[guid] = { scale = scale, timestamp = time() }
end

local function loadScale(guid)
    if not guid then return nil end
    local saved = VE_DB and VE_DB.neighborhoodScales and VE_DB.neighborhoodScales[guid]
    return saved and saved.scale or nil
end

-- ============================================================================
-- Task Rules Builder (for CalculateNextContribution)
-- ============================================================================

-- Scans the log + live tasks to identify floor tasks (completed >= COMPLETIONS_TO_FLOOR).
-- For each, records the most recent log amount as the floor amount.
-- Returns: taskRules { [taskName] = { atFloor=true, floorAmount=N, floorTime=T } }
local function buildTaskRules(log)
    local recentByTask = {}    -- taskName -> { amount, time }
    local completionCount = {} -- taskName -> count (all players, from log)
    for i = 1, #log do
        local entry    = log[i]
        local taskName = entry.taskName
        if taskName then
            completionCount[taskName] = (completionCount[taskName] or 0) + 1
            local amount = entry.amount or 0
            local t      = entry.completionTime or 0
            if amount > 0 then
                local prev = recentByTask[taskName]
                if not prev or t > prev.time then
                    recentByTask[taskName] = { amount = amount, time = t }
                end
            end
        end
    end

    local taskRules = {}
    for taskName, count in pairs(completionCount) do
        if count >= COMPLETIONS_TO_FLOOR then
            local recent = recentByTask[taskName]
            if recent then
                taskRules[taskName] = {
                    atFloor     = true,
                    floorAmount = recent.amount,
                    floorTime   = recent.time,
                }
            end
        end
    end

    return taskRules
end

-- ============================================================================
-- XP Index Builders (O(1) lookups for per-task queries)
-- ============================================================================

local function buildXPIndexes(log, myCharacters, currentPlayer)
    local xpCache       = {} -- taskID -> { amount, completionTime }
    local xpByPlayer    = {} -- taskID -> playerName -> { amount, completionTime }
    local playerCounts  = {} -- taskID -> count (currentPlayer only)
    local accountCounts = {} -- taskID -> count (all myCharacters)

    for i = 1, #log do
        local entry = log[i]
        local tid   = entry.taskID
        local amt   = entry.amount or 0
        local pn    = entry.playerName
        local t     = entry.completionTime or 0

        if tid then
            local cached = xpCache[tid]
            if not cached or t > (cached.completionTime or 0) then
                xpCache[tid] = { amount = amt, completionTime = t }
            end
            if pn then
                if not xpByPlayer[tid] then xpByPlayer[tid] = {} end
                local byP = xpByPlayer[tid][pn]
                if not byP or t > (byP.completionTime or 0) then
                    xpByPlayer[tid][pn] = { amount = amt, completionTime = t }
                end
                if pn == currentPlayer then
                    playerCounts[tid] = (playerCounts[tid] or 0) + 1
                end
                if myCharacters[pn] then
                    accountCounts[tid] = (accountCounts[tid] or 0) + 1
                end
            end
        end
    end

    return xpCache, xpByPlayer, playerCounts, accountCounts
end

-- ============================================================================
-- House XP Calculation
-- ============================================================================

-- Calculates total house XP for myCharacters from the activity log.
--   xp = amount / scale (single scale, all eras)
--
-- Pass 1: build lastKnown amounts for zero-amount fallback.
--   When the house hits the XP cap, Blizzard reports amount=0 for new entries.
--   We substitute the last known positive amount for the same task.
--
-- Pass 2: sum XP. Non-repeatable tasks are excluded entirely.
--
-- Returns: total (number), breakdown (table)
local function calcHouseXP(log, myCharacters, scale)
    if not scale or scale <= 0 then return 0, nil end

    -- Pass 1: lastKnown[taskName] = oldest positive amount (post-cutoff only)
    local lastKnown = {}
    for i = #log, 1, -1 do
        local entry = log[i]
        local amt   = entry.amount or 0
        local t     = entry.completionTime or 0
        if amt > 0 and t >= SCALE_CHANGE_CUTOFF and not lastKnown[entry.taskName] then
            lastKnown[entry.taskName] = amt
        end
    end

    -- Pass 2: xp = amount / scale for all entries
    local preTotal  = 0
    local postTotal = 0

    for i = 1, #log do
        local entry = log[i]
        if myCharacters[entry.playerName] then
            local task   = entry.taskName
            local t      = entry.completionTime or 0

            if not NON_REPEATABLE[task] then
                local contrib = entry.amount or 0

                -- Zero-amount fallback for post-cap entries
                if contrib == 0 and t >= SCALE_CHANGE_CUTOFF and lastKnown[task] then
                    contrib = lastKnown[task]
                end

                if contrib > 0 then
                    local xp = contrib / scale
                    if t < SCALE_CHANGE_CUTOFF then
                        preTotal = preTotal + xp
                    else
                        postTotal = postTotal + xp
                    end
                end
            end
        end
    end

    -- Apply caps: pre capped at 1000, cumulative capped at 2250
    local cappedPre    = math.min(preTotal, PRE_JAN29_CAP)
    local remainingCap = POST_JAN29_CAP - cappedPre
    local cappedPost   = math.min(postTotal, math.max(0, remainingCap))

    local breakdown = {
        preRaw    = preTotal,
        preCapped = cappedPre,
        post      = cappedPost,
        preCap    = PRE_JAN29_CAP,
        postCap   = POST_JAN29_CAP,
    }

    return cappedPre + cappedPost, breakdown
end

-- ============================================================================
-- Scale Derivation (from live API + log, no hardcoded values)
-- ============================================================================

-- Derives scale by comparing a floor task's log amount to its live API contribution.
-- For tasks completed >= COMPLETIONS_TO_FLOOR times, both the log and the API report
-- the floor-level contribution. Their ratio gives the neighborhood scale.
-- Returns: scale (number or nil)
local function deriveLiveScale(taskRules, liveTasks)
    for _, task in ipairs(liveTasks or {}) do
        local taskName = task.taskName or task.name
        local rules = taskRules[taskName]
        if rules and (rules.floorAmount or 0) > 0 then
            local apiContrib = task.progressContributionAmount or 0
            if apiContrib > 0 then
                local s = rules.floorAmount / apiContrib
                if s > 0 and s == s then return s end
            end
        end
    end
    return nil
end

-- ============================================================================
-- Context Factory (full rebuild, never incremental)
-- ============================================================================

local function rebuildContext(guid, log, myCharacters, currentPlayer, liveTasks, ptc)
    local ctx = {
        guid               = guid,
        log                = log,
        myCharacters       = myCharacters,
        currentPlayer      = currentPlayer,
        taskRules          = {},
        taskXPCache        = {},
        taskXPByPlayer     = {},
        playerCompletions  = {},
        accountCompletions = {},
        houseXP            = 0,
        houseXPBreakdown   = nil,
        playerContribution = 0,
        scale              = 0,
        scaleLevel         = 0,
        _liveTasks         = liveTasks or {},
        _ptc               = ptc or 0,
    }

    -- Step 1: build task rules for CalculateNextContribution
    ctx.taskRules = buildTaskRules(log)

    -- Step 2: determine scale (live > saved)
    local liveScale = deriveLiveScale(ctx.taskRules, liveTasks)
    if liveScale then
        ctx.scale = liveScale
        ctx.scaleLevel = 1
        saveScale(guid, liveScale)
    else
        local saved = loadScale(guid)
        if saved and saved > 0 then
            ctx.scale = saved
            ctx.scaleLevel = 2
        end
    end

    -- Step 3: O(1) lookup indexes for per-task queries
    ctx.taskXPCache, ctx.taskXPByPlayer, ctx.playerCompletions, ctx.accountCompletions =
        buildXPIndexes(log, myCharacters, currentPlayer)

    -- Step 4: house XP calculation (xp = amount / scale, single scale)
    ctx.houseXP, ctx.houseXPBreakdown =
        calcHouseXP(log, myCharacters, ctx.scale)

    -- Step 5: player's raw contribution sum (for UI display)
    local contrib = 0
    for i = 1, #log do
        if log[i].playerName == currentPlayer then
            contrib = contrib + (log[i].amount or 0)
        end
    end
    ctx.playerContribution = contrib

    -- Step 6: persist to VE_DB.houseData for instant display on next login
    VE_DB = VE_DB or {}
    VE_DB.houseData = VE_DB.houseData or {}
    VE_DB.houseData[guid] = {
        houseXP            = ctx.houseXP,
        playerContribution = ctx.playerContribution,
        lastUpdated        = time(),
    }

    return ctx
end

-- ============================================================================
-- Public API: Lifecycle / Ingest
-- ============================================================================

function XPEngine:SetActiveGUID(guid)
    activeGUID = guid
end

function XPEngine:GetActiveGUID()
    return activeGUID
end

-- Called by EndeavorTracker after activity log is fetched.
-- Rebuilds the entire context for this guid from scratch.
function XPEngine:IngestActivityLog(guid, logEntries, myCharacters, currentPlayer)
    local log = (logEntries and logEntries.taskActivity) or {}

    -- Carry forward live task data from prior IngestLiveTasks call
    local prev = contexts[guid]
    local liveTasks = prev and prev._liveTasks or {}
    local ptc       = prev and prev._ptc or 0

    contexts[guid] = rebuildContext(guid, log, myCharacters, currentPlayer, liveTasks, ptc)
end

-- Called by EndeavorTracker after FetchEndeavorData.
-- Triggers scale re-derivation with fresh live task data.
function XPEngine:IngestLiveTasks(guid, tasks, ptc, myCharacters, currentPlayer)
    local prev = contexts[guid]
    local log  = prev and prev.log or {}

    contexts[guid] = rebuildContext(guid, log, myCharacters, currentPlayer, tasks or {}, ptc or 0)
end

-- ============================================================================
-- Public API: Output Queries (always scoped to activeGUID)
-- ============================================================================

function XPEngine:GetHouseXP()
    local ctx = contexts[activeGUID]
    if not ctx then return 0, nil end
    return ctx.houseXP, ctx.houseXPBreakdown
end

function XPEngine:GetPlayerContribution()
    local ctx = contexts[activeGUID]
    return ctx and ctx.playerContribution or 0
end

function XPEngine:GetAccountCompletionCount(taskID)
    local ctx = contexts[activeGUID]
    return ctx and ctx.accountCompletions[taskID] or 0
end

function XPEngine:GetPlayerCompletionCount(taskID)
    local ctx = contexts[activeGUID]
    return ctx and ctx.playerCompletions[taskID] or 0
end

-- Returns the predicted raw progress contribution for the next completion.
-- taskName: string, completions: number (unused, kept for API compat)
function XPEngine:CalculateNextContribution(taskName, completions)
    local ctx = contexts[activeGUID]
    if not ctx then return 0 end

    local task
    for _, t in ipairs(ctx._liveTasks or {}) do
        local name = t.taskName or t.name
        if name == taskName then
            task = t
            break
        end
    end
    if not task then return 0 end

    -- At floor (per log): return the observed floor contribution from the log
    local rules = ctx.taskRules[taskName]
    if rules and rules.atFloor and (rules.floorAmount or 0) > 0 then
        return rules.floorAmount
    end

    -- Not at floor: API's progressContributionAmount is the decayed value for next
    return task.progressContributionAmount or 0
end

-- Returns top 3 incomplete repeatable tasks ranked by next contribution.
function XPEngine:GetTaskRankings()
    local ctx = contexts[activeGUID]
    if not ctx then return {} end

    local candidates = {}
    for _, task in ipairs(ctx._liveTasks or {}) do
        local taskType = task.taskType or 0
        local isRepeatable = taskType > 0
        local completed = task.completed
        local taskName = task.taskName or task.name
        local taskID = task.ID or task.id

        if isRepeatable and taskID and not completed then
            local nextXP = self:CalculateNextContribution(taskName)
            if nextXP > 0 then
                candidates[#candidates + 1] = { id = taskID, nextXP = nextXP }
            end
        end
    end

    table.sort(candidates, function(a, b) return a.nextXP > b.nextXP end)

    local rankings = {}
    for rank = 1, math.min(3, #candidates) do
        rankings[candidates[rank].id] = { rank = rank, nextXP = candidates[rank].nextXP }
    end
    return rankings
end

function XPEngine:GetActivityLogData()
    local ctx = contexts[activeGUID]
    if not ctx or not ctx.log or #ctx.log == 0 then return nil end
    return { taskActivity = ctx.log }
end

function XPEngine:GetScale()
    local ctx = contexts[activeGUID]
    if not ctx then return 0, 0 end
    return ctx.scale, ctx.scaleLevel
end

-- Debug: show why deriveLiveScale succeeded or failed
function XPEngine:DebugScaleDerivation()
    local ctx = contexts[activeGUID]
    if not ctx then print("  No context for active GUID"); return end

    local liveTasks = ctx._liveTasks or {}
    local rules = ctx.taskRules or {}
    local ruleCount = 0
    for _ in pairs(rules) do ruleCount = ruleCount + 1 end

    print(string.format("  Live tasks: %d, Task rules: %d, Log: %d", #liveTasks, ruleCount, #(ctx.log or {})))

    for _, task in ipairs(liveTasks) do
        local name = task.taskName or task.name or "?"
        local pca = task.progressContributionAmount or 0
        local r = rules[name]
        local fa = r and r.floorAmount or 0
        local atFloor = r and r.atFloor
        local marker = atFloor and "FLOOR" or "     "
        print(string.format("  %s: %s  pca=%.4f fa=%.4f%s",
            marker, name, pca, fa,
            (fa > 0 and pca > 0) and string.format(" => scale=%.10f", fa / pca) or ""))
    end
end

-- ============================================================================
-- Public API: Persistence Wrappers
-- ============================================================================

function XPEngine:SaveScale(guid)
    local ctx = contexts[guid or activeGUID]
    if ctx and ctx.scale > 0 then
        saveScale(ctx.guid, ctx.scale)
    end
end

function XPEngine:LoadScale(guid)
    return loadScale(guid or activeGUID)
end

-- ============================================================================
-- Public API: Utilities
-- ============================================================================

-- Decay multiplier for the Nth completion (1-based). Used by UI for prediction.
-- Steps: 1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2 (floors at 1/COMPLETIONS_TO_FLOOR)
local function decayMultiplier(run)
    if run < 1 then run = 1 end
    local floorPct  = 1 / COMPLETIONS_TO_FLOOR
    local decayRate = (1 - floorPct) / (COMPLETIONS_TO_FLOOR - 1)
    return math.max(floorPct, 1 - decayRate * (run - 1))
end

function XPEngine:GetDecayMultiplier(run)
    return decayMultiplier(run)
end

-- Wipes context for a guid (used when switching houses to free memory).
function XPEngine:ClearContext(guid)
    contexts[guid] = nil
end

-- Returns whether a context exists for a guid.
function XPEngine:HasContext(guid)
    return contexts[guid] ~= nil
end

-- Restores cached values from VE_DB.houseData (for instant display before API responds).
function XPEngine:RestoreFromSaved(guid)
    if not guid then return end
    VE_DB = VE_DB or {}
    local saved = VE_DB.houseData and VE_DB.houseData[guid]
    if not saved then return end

    if not contexts[guid] then
        contexts[guid] = {
            guid               = guid,
            log                = {},
            myCharacters       = {},
            currentPlayer      = "",
            taskRules          = {},
            taskXPCache        = {},
            taskXPByPlayer     = {},
            playerCompletions  = {},
            accountCompletions = {},
            houseXP            = saved.houseXP or 0,
            houseXPBreakdown   = nil,
            playerContribution = saved.playerContribution or 0,
            scale              = 0,
            scaleLevel         = 0,
            _liveTasks         = {},
            _ptc               = 0,
        }
    end
end
