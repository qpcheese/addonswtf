-- ============================================================================
-- Vamoose's Endeavors - EndeavorTracker
-- Fetches and tracks housing endeavor data using C_NeighborhoodInitiative API
-- XP calculations delegated to VE_XPEngine (loaded before this file)
-- ============================================================================

VE = VE or {}
VE.EndeavorTracker = {}

local Tracker = VE.EndeavorTracker
Tracker.frame = CreateFrame("Frame")

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function Tracker:Initialize()
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.frame:RegisterEvent("NEIGHBORHOOD_INITIATIVE_UPDATED")
    self.frame:RegisterEvent("INITIATIVE_TASKS_TRACKED_UPDATED")
    self.frame:RegisterEvent("INITIATIVE_TASKS_TRACKED_LIST_CHANGED")
    self.frame:RegisterEvent("INITIATIVE_TASK_COMPLETED")
    self.frame:RegisterEvent("INITIATIVE_COMPLETED")
    self.frame:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")

    self.activityLogLoaded = false
    self.cachedActivityLog = nil
    self.activityLogLastUpdated = nil
    self.activityLogStale = false
    self.currentHouseGUID = nil

    self.fetchStatus = {
        state = "pending",
        attempt = 0,
        lastAttempt = nil,
        nextRetry = nil,
    }

    self.pendingRetryTimer = nil
    self.pendingRefreshTimer = nil
    self.lastFetchTime = nil
    self.lastRequestTime = nil
    self.lastManualSelectionTime = nil
    self.lastKnownActiveGUID = nil

    self.houseList = {}
    self.selectedHouseIndex = 1
    self.houseListLoaded = false

    self._taskCompletionRetryGen = 0
    self._couponRetryScheduled = false

    self.frame:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)

    -- Debounced character progress save on task/endeavor state changes
    VE.EventBus:Register("VE_STATE_CHANGED", function(payload)
        if payload.action == "SET_TASKS" or payload.action == "SET_ENDEAVOR_INFO" then
            if self.saveCharProgressTimer then
                self.saveCharProgressTimer:Cancel()
            end
            self.saveCharProgressTimer = C_Timer.NewTimer(0.5, function()
                self.saveCharProgressTimer = nil
                self:SaveCurrentCharacterProgress()
            end)
        end
    end)

    VE.EventBus:Register("VE_COUPON_GAINED", function()
        VE.EndeavorTracker:QueueDataRefresh()
    end)

    -- Legacy VE_DB cleanup (one-time migration)
    VE_DB = VE_DB or {}
    VE_DB.learnedFormula = nil
    VE_DB.taskRules = nil
    VE_DB.formulaCheckpoint = nil

    if VE.Store:GetState().config.debug then
        print("|cFF2aa198[VE Tracker]|r Initialized with C_NeighborhoodInitiative API")
    end
end

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================

function Tracker:OnEvent(event, ...)
    local debug = VE.Store:GetState().config.debug

    if event == "PLAYER_ENTERING_WORLD" then
        -- Register current character for account-wide tracking
        VE_DB = VE_DB or {}
        VE_DB.myCharacters = VE_DB.myCharacters or {}
        local charName = UnitName("player")
        if charName then VE_DB.myCharacters[charName] = true end

        -- Trigger house list fetch (PLAYER_HOUSE_LIST_UPDATED handles the rest)
        C_Timer.After(2, function()
            if C_Housing and C_Housing.GetPlayerOwnedHouses then
                if debug then
                    print("|cFF2aa198[VE Tracker]|r Requesting player house list to initialize housing system...")
                end
                C_Housing.GetPlayerOwnedHouses()
            end
        end)

    elseif event == "NEIGHBORHOOD_INITIATIVE_UPDATED" then
        self:QueueDataRefresh()

    elseif event == "INITIATIVE_TASKS_TRACKED_UPDATED" then
        self:QueueDataRefresh()

    elseif event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
        if debug then
            print("|cFF2aa198[VE Tracker]|r Task tracking list changed")
        end
        self:RefreshTrackedTasks()

    elseif event == "INITIATIVE_TASK_COMPLETED" then
        local taskName = ...
        if debug then
            print("|cFF2aa198[VE Tracker]|r Task completed: |cFFFFD100" .. tostring(taskName) .. "|r")
        end

        -- Look up task info from current state, then fall back to fresh API
        local taskID, isRepeatable = nil, false
        local state = VE.Store:GetState()
        if state and state.tasks then
            for _, task in ipairs(state.tasks) do
                if task.name == taskName then
                    taskID = task.id
                    isRepeatable = task.isRepeatable or false
                    break
                end
            end
        end
        if not taskID and C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo then
            local freshInfo = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo()
            if freshInfo and freshInfo.tasks then
                for _, task in ipairs(freshInfo.tasks) do
                    if task.taskName == taskName then
                        taskID = task.ID
                        isRepeatable = task.taskType and task.taskType > 0 or false
                        break
                    end
                end
            end
        end

        -- Queue for coupon correlation (CURRENCY_DISPLAY_UPDATE fires after this)
        VE._pendingTaskCompletions = VE._pendingTaskCompletions or {}
        table.insert(VE._pendingTaskCompletions, {
            taskName = taskName,
            taskID = taskID,
            isRepeatable = isRepeatable,
            timestamp = time(),
        })

        if VE.Vamoose and VE.Vamoose.OnTaskCompleted then
            VE.Vamoose.OnTaskCompleted(taskID, taskName)
        end

        -- Mark activity log as stale (new data available)
        self.activityLogStale = true

        -- Retry until the new task appears in the activity log
        self:RequestActivityLog()
        local playerName = UnitName("player")
        local preMatches = 0
        if self.cachedActivityLog and self.cachedActivityLog.taskActivity then
            for _, e in ipairs(self.cachedActivityLog.taskActivity) do
                if e.playerName == playerName and e.taskName == taskName then
                    preMatches = preMatches + 1
                end
            end
        end
        self._taskCompletionRetryGen = self._taskCompletionRetryGen + 1
        local gen = self._taskCompletionRetryGen
        local retries = { 30, 60, 120, 300 }
        for _, delay in ipairs(retries) do
            C_Timer.After(delay, function()
                if self._taskCompletionRetryGen ~= gen then return end
                self:RequestActivityLog()
                self:RefreshActivityLogCache()
                local postMatches = 0
                if self.cachedActivityLog and self.cachedActivityLog.taskActivity then
                    for _, e in ipairs(self.cachedActivityLog.taskActivity) do
                        if e.playerName == playerName and e.taskName == taskName then
                            postMatches = postMatches + 1
                        end
                    end
                end
                if postMatches > preMatches then
                    self._taskCompletionRetryGen = gen + 1  -- Cancel remaining retries
                end
            end)
        end

        if VE.HousingTracker then
            VE.HousingTracker:RequestHouseInfo(true)
        end

    elseif event == "INITIATIVE_COMPLETED" then
        local initiativeTitle = ...
        if debug then
            print("|cFF2aa198[VE Tracker]|r Initiative completed: " .. tostring(initiativeTitle))
        end
        self:FetchEndeavorData(true)

    elseif event == "PLAYER_HOUSE_LIST_UPDATED" then
        local houseInfoList = ...
        if debug then
            print("|cFF2aa198[VE Tracker]|r House list updated with " .. (houseInfoList and #houseInfoList or 0) .. " houses")
        end

        self.houseList = houseInfoList or {}
        self.houseListLoaded = true

        -- Preserve user's dropdown selection if still valid
        local recentManualSelection = self.lastManualSelectionTime and (GetTime() - self.lastManualSelectionTime) < 2
        if recentManualSelection and self.selectedHouseIndex then
            if debug then
                print("|cFF2aa198[VE Tracker]|r Preserving recent manual selection despite house list update")
            end
            return
        end

        -- Priority 1: Active neighborhood (the one earning XP)
        local selectedIndex, neighborhoodGUID = nil, nil
        local activeNeighborhood = C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetActiveNeighborhood and C_NeighborhoodInitiative.GetActiveNeighborhood()
        if activeNeighborhood and houseInfoList then
            for i, houseInfo in ipairs(houseInfoList) do
                if houseInfo.neighborhoodGUID == activeNeighborhood then
                    neighborhoodGUID = activeNeighborhood
                    selectedIndex = i
                    break
                end
            end
        end

        -- Priority 2: Saved houseGUID from last session
        if not selectedIndex then
            VE_DB = VE_DB or {}
            local savedGUID = VE_DB.selectedHouseGUID
            if savedGUID and houseInfoList then
                for i, houseInfo in ipairs(houseInfoList) do
                    if houseInfo.houseGUID == savedGUID then
                        neighborhoodGUID = houseInfo.neighborhoodGUID
                        selectedIndex = i
                        break
                    end
                end
            end
        end

        -- Priority 3: First house (fallback)
        if not selectedIndex and houseInfoList and #houseInfoList > 0 then
            neighborhoodGUID = houseInfoList[1].neighborhoodGUID
            selectedIndex = 1
        end

        if selectedIndex then
            self.selectedHouseIndex = selectedIndex
            self.currentHouseGUID = houseInfoList[selectedIndex].houseGUID
            VE_DB = VE_DB or {}
            VE_DB.selectedHouseGUID = self.currentHouseGUID

            -- Point XPEngine at this GUID; restore cached values for instant display
            VE.XPEngine:SetActiveGUID(self.currentHouseGUID)
            VE.XPEngine:RestoreFromSaved(self.currentHouseGUID)
        end

        -- Update house GUID and request fresh level data
        local selectedHouseInfo = houseInfoList and houseInfoList[selectedIndex]
        if selectedHouseInfo and selectedHouseInfo.houseGUID then
            VE.Store:Dispatch("SET_HOUSE_GUID", { houseGUID = selectedHouseInfo.houseGUID })
            if C_Housing and C_Housing.GetCurrentHouseLevelFavor then
                pcall(C_Housing.GetCurrentHouseLevelFavor, selectedHouseInfo.houseGUID)
            end
        end

        VE.EventBus:Trigger("VE_HOUSE_LIST_UPDATED", { houseList = self.houseList, selectedIndex = selectedIndex })

        -- Set viewing neighborhood and request data
        if C_NeighborhoodInitiative and neighborhoodGUID then
            C_NeighborhoodInitiative.SetViewingNeighborhood(neighborhoodGUID)
            C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
            self:RequestActivityLog()
        end
    end
end

-- ============================================================================
-- DATA FETCHING
-- ============================================================================

function Tracker:UpdateFetchStatus(state, attempt, nextRetryTime)
    local prevState = self.fetchStatus.state
    self.fetchStatus.state = state
    self.fetchStatus.attempt = attempt or self.fetchStatus.attempt
    self.fetchStatus.lastAttempt = time()
    self.fetchStatus.nextRetry = nextRetryTime
    if prevState ~= state then
        VE.EventBus:Trigger("VE_FETCH_STATUS_CHANGED", self.fetchStatus)
    end
end

function Tracker:GetViewingNeighborhoodGUID()
    if self.houseList and self.selectedHouseIndex and self.houseList[self.selectedHouseIndex] then
        return self.houseList[self.selectedHouseIndex].neighborhoodGUID
    end
    return nil
end

function Tracker:IsViewingActiveNeighborhood()
    if not C_NeighborhoodInitiative then return false end
    local activeGUID = C_NeighborhoodInitiative.GetActiveNeighborhood and C_NeighborhoodInitiative.GetActiveNeighborhood()
    local viewingGUID = self:GetViewingNeighborhoodGUID()
    if not activeGUID or not viewingGUID then return false end
    return activeGUID == viewingGUID
end

function Tracker:QueueDataRefresh()
    if not VE.MainFrame or not VE.MainFrame:IsShown() then return end
    if self.pendingRefreshTimer then
        self.pendingRefreshTimer:Cancel()
    end
    self.pendingRefreshTimer = C_Timer.NewTimer(0.3, function()
        self.pendingRefreshTimer = nil
        self:FetchEndeavorData()
        if VE.RefreshUI then
            VE:RefreshUI()
        end
    end)
end

function Tracker:ValidateRequirements()
    if not C_NeighborhoodInitiative then return "api_unavailable" end
    if not C_NeighborhoodInitiative.IsInitiativeEnabled() then return "disabled" end
    if not C_NeighborhoodInitiative.PlayerMeetsRequiredLevel() then return "low_level" end
    if not C_NeighborhoodInitiative.PlayerHasInitiativeAccess() then return "no_access" end
    return "ok"
end

function Tracker:ClearEndeavorData()
    self:UpdateFetchStatus("loaded", 0, nil)
    VE.Store:Dispatch("SET_ENDEAVOR_INFO", {
        seasonName = "Not Active Endeavor",
        daysRemaining = 0,
        currentProgress = 0,
        maxProgress = 0,
        milestones = {},
    })
    VE.Store:Dispatch("SET_TASKS", { tasks = {} })
    self.activityLogLoaded = false
    VE.EventBus:Trigger("VE_ACTIVITY_LOG_UPDATED", { timestamp = nil })
end

function Tracker:FetchEndeavorData(_, attempt)
    local debug = VE.Store:GetState().config.debug
    attempt = attempt or 0

    -- Debounce: skip if fetched within last 1 second (unless retry)
    local now = GetTime()
    if attempt == 0 and self.lastFetchTime and (now - self.lastFetchTime) < 1 then
        return
    end
    self.lastFetchTime = now

    local skipRequest = self.lastRequestTime and (now - self.lastRequestTime) < 2

    if self.pendingRetryTimer then
        self.pendingRetryTimer:Cancel()
        self.pendingRetryTimer = nil
    end

    if debug and attempt > 0 then
        print("|cFF2aa198[VE Tracker]|r Fetching endeavor data (attempt " .. attempt .. ")")
    end

    self:UpdateFetchStatus(attempt > 0 and "retrying" or "fetching", attempt, nil)

    -- Validate API access
    local req = self:ValidateRequirements()
    if req ~= "ok" then
        if debug then
            print("|cFFdc322f[VE Tracker]|r API check failed: " .. req)
        end
        return
    end

    -- Request fresh data if not recently requested
    if not skipRequest then
        self.lastRequestTime = now
        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
    end

    local initiativeInfo = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo()

    if not initiativeInfo or not initiativeInfo.isLoaded then
        if debug then
            print("|cFF2aa198[VE Tracker]|r Initiative data not loaded yet, waiting...")
        end
        if self.houseListLoaded and attempt >= 0 and attempt < 3 then
            local nextRetry = time() + 10
            self:UpdateFetchStatus("retrying", attempt + 1, nextRetry)
            if debug then
                print("|cFF2aa198[VE Tracker]|r Scheduling retry " .. (attempt + 1) .. "/3 in 10s...")
            end
            if self.pendingRetryTimer then
                self.pendingRetryTimer:Cancel()
            end
            self.pendingRetryTimer = C_Timer.NewTimer(10, function()
                self.pendingRetryTimer = nil
                C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
                self:RequestActivityLog()
            end)
        end
        return
    end

    self:UpdateFetchStatus("loaded", attempt, nil)

    -- Detect active neighborhood changes
    local activeGUID = C_NeighborhoodInitiative.GetActiveNeighborhood and C_NeighborhoodInitiative.GetActiveNeighborhood()
    local dataGUID = initiativeInfo.neighborhoodGUID

    if activeGUID and activeGUID ~= self.lastKnownActiveGUID then
        self.lastKnownActiveGUID = activeGUID
        VE.EventBus:Trigger("VE_ACTIVE_NEIGHBORHOOD_CHANGED")
    end

    -- Sync dropdown if Blizzard dashboard changed the viewing neighborhood
    if dataGUID and self.houseList then
        local selectedGUID = self.selectedHouseIndex and self.houseList[self.selectedHouseIndex]
                             and self.houseList[self.selectedHouseIndex].neighborhoodGUID
        if dataGUID ~= selectedGUID then
            for i, houseInfo in ipairs(self.houseList) do
                if houseInfo.neighborhoodGUID == dataGUID then
                    if debug then
                        print("|cFF2aa198[VE Tracker]|r Syncing dropdown to match Blizzard's selection: house " .. i)
                    end
                    self.selectedHouseIndex = i
                    self.currentHouseGUID = houseInfo.houseGUID
                    VE_DB = VE_DB or {}
                    VE_DB.selectedHouseGUID = houseInfo.houseGUID
                    VE.EventBus:Trigger("VE_HOUSE_LIST_UPDATED", { houseList = self.houseList, selectedIndex = i })
                    break
                end
            end
        end
    end

    -- If viewing a non-active neighborhood, clear data
    if dataGUID and activeGUID and dataGUID ~= activeGUID then
        if debug then
            print("|cFF2aa198[VE Tracker]|r Viewing non-active neighborhood, clearing data")
        end
        self:UpdateFetchStatus("loaded", 0, nil)
        VE.Store:Dispatch("SET_ENDEAVOR_INFO", {
            seasonName = "Not Active Endeavor",
            daysRemaining = 0,
            currentProgress = 0,
            maxProgress = 0,
            milestones = {},
        })
        VE.Store:Dispatch("SET_TASKS", { tasks = {} })
        self.activityLogLoaded = false
        VE.EventBus:Trigger("VE_ACTIVITY_LOG_UPDATED", { timestamp = nil })
        return
    end

    if initiativeInfo.initiativeID == 0 then
        if debug then
            print("|cFF2aa198[VE Tracker]|r No active initiative (choosing phase)")
        end
        VE.Store:Dispatch("SET_ENDEAVOR_INFO", {
            seasonName = "No Active Endeavor",
            daysRemaining = 0,
            currentProgress = 0,
            maxProgress = 0,
            milestones = {},
        })
        VE.Store:Dispatch("SET_TASKS", { tasks = {} })
        return
    end

    self:ProcessInitiativeInfo(initiativeInfo)
end

function Tracker:RequestActivityLog()
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RequestInitiativeActivityLog then
        C_NeighborhoodInitiative.RequestInitiativeActivityLog()
    end
end

function Tracker:RefreshAll()
    local debug = VE.Store:GetState().config.debug

    if self.pendingRetryTimer then
        self.pendingRetryTimer:Cancel()
        self.pendingRetryTimer = nil
    end

    self:UpdateFetchStatus("fetching", 0, nil)

    if not C_NeighborhoodInitiative then
        if debug then
            print("|cFFdc322f[VE Tracker]|r RefreshAll: C_NeighborhoodInitiative not available")
        end
        return
    end

    if debug then
        print("|cFF2aa198[VE Tracker]|r RefreshAll: Requesting data for current viewing neighborhood")
    end
    C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
    self:RequestActivityLog()
end

-- ============================================================================
-- DATA PROCESSING
-- ============================================================================

function Tracker:ProcessInitiativeInfo(info)
    local daysRemaining = 0
    if info.duration and info.duration > 0 then
        daysRemaining = math.ceil(info.duration / 86400)
    end

    -- Process milestones
    local milestones = {}
    local maxProgress = 0
    if info.milestones then
        for _, milestone in ipairs(info.milestones) do
            local threshold = milestone.requiredContributionAmount or 0
            maxProgress = math.max(maxProgress, threshold)
            table.insert(milestones, {
                threshold = threshold,
                reached = (info.currentProgress or 0) >= threshold,
                rewards = milestone.rewards,
            })
        end
    end
    if maxProgress == 0 then
        maxProgress = info.progressRequired or 100
    end

    VE.Store:Dispatch("SET_ENDEAVOR_INFO", {
        seasonName = info.title or "Unknown Endeavor",
        seasonEndTime = info.duration and (time() + info.duration) or 0,
        daysRemaining = daysRemaining,
        currentProgress = info.currentProgress or 0,
        maxProgress = maxProgress,
        milestones = milestones,
        description = info.description,
        initiativeID = info.initiativeID,
        playerTotalContribution = info.playerTotalContribution or 0,
    })

    -- Record initiative for collection
    if info.initiativeID and info.initiativeID > 0 and info.title then
        VE.Store:Dispatch("RECORD_INITIATIVE", {
            initiativeID = info.initiativeID,
            title = info.title,
            description = info.description,
        })
    end

    -- Process tasks
    local tasks = {}
    local hasMissingCoupons = false
    if info.tasks then
        for _, task in ipairs(info.tasks) do
            if not task.supersedes or task.supersedes == 0 then
                local isRepeatable = task.taskType and task.taskType > 0
                local couponReward, couponBase = self:GetTaskCouponReward(task)
                if couponReward == nil then
                    hasMissingCoupons = true
                    couponReward = 0
                    couponBase = 0
                end
                table.insert(tasks, {
                    id = task.ID,
                    name = task.taskName,
                    description = task.description or "",
                    points = task.progressContributionAmount or 0,
                    progressContributionAmount = task.progressContributionAmount or 0,
                    completed = task.completed or false,
                    current = self:GetTaskProgress(task),
                    max = self:GetTaskMax(task),
                    taskType = task.taskType,
                    tracked = task.tracked or false,
                    sortOrder = task.sortOrder or 999,
                    requirementsList = task.requirementsList,
                    timesCompleted = task.timesCompleted,
                    isRepeatable = isRepeatable,
                    rewardQuestID = task.rewardQuestID,
                    couponReward = couponReward,
                    couponBase = couponBase or couponReward,
                })
            end
        end

        table.sort(tasks, function(a, b)
            if a.completed ~= b.completed then
                return not a.completed
            end
            return (a.sortOrder or 999) < (b.sortOrder or 999)
        end)
    end

    -- Check for task progress changes (squirrel quotes)
    if VE.Vamoose and VE.Vamoose.OnTaskProgress then
        local oldTasks = VE.Store:GetState().tasks or {}
        local oldProgress = {}
        for _, task in ipairs(oldTasks) do
            if task.id and task.current and task.max then
                oldProgress[task.id] = task.current
            end
        end
        for _, task in ipairs(tasks) do
            if task.id and task.current and task.max and not task.completed then
                local oldCurrent = oldProgress[task.id]
                if oldCurrent and task.current > oldCurrent then
                    VE.Vamoose.OnTaskProgress(task.id, task.name, task.current, task.max)
                end
            end
        end
    end

    VE.Store:Dispatch("SET_TASKS", { tasks = tasks })

    -- Feed live task data into XPEngine for scale derivation + XP recalculation
    if self.currentHouseGUID then
        VE.XPEngine:IngestLiveTasks(
            self.currentHouseGUID,
            info.tasks or {},
            info.playerTotalContribution or 0,
            VE_DB.myCharacters or {},
            UnitName("player")
        )
    end

    -- Retry if coupon data wasn't ready
    if hasMissingCoupons and not self._couponRetryScheduled then
        self._couponRetryScheduled = true
        C_Timer.After(2, function()
            self._couponRetryScheduled = false
            VE.EndeavorTracker:FetchEndeavorData()
        end)
    end
end

function Tracker:GetTaskProgress(task)
    if task.requirementsList and #task.requirementsList > 0 then
        local req = task.requirementsList[1]
        if req.requirementText then
            local current = req.requirementText:match("(%d+)%s*/%s*%d+")
            if current then return tonumber(current) or 0 end
        end
    end
    return task.completed and 1 or 0
end

function Tracker:GetTaskMax(task)
    if task.requirementsList and #task.requirementsList > 0 then
        local req = task.requirementsList[1]
        if req.requirementText then
            local max = req.requirementText:match("%d+%s*/%s*(%d+)")
            if max then return tonumber(max) or 1 end
        end
    end
    return 1
end

function Tracker:GetTaskCouponReward(task)
    local taskName = task.taskName or task.name
    local base = 0

    if not task.rewardQuestID or task.rewardQuestID == 0 then
        return 0, 0
    end

    if C_QuestLog and C_QuestLog.GetQuestRewardCurrencies then
        local rewards = C_QuestLog.GetQuestRewardCurrencies(task.rewardQuestID)
        if rewards and #rewards > 0 then
            for _, reward in ipairs(rewards) do
                local couponID = VE.Constants and VE.Constants.CURRENCY_IDS and VE.Constants.CURRENCY_IDS.COMMUNITY_COUPONS or 3363
                if reward.currencyID == couponID then
                    base = reward.totalRewardAmount or 0
                    break
                end
            end
        else
            return nil, nil  -- API not ready (nil or empty table)
        end
    end

    -- Check for tracked actual reward (from CURRENCY_DISPLAY_UPDATE correlation)
    VE_DB = VE_DB or {}
    local history = VE_DB.taskActualCoupons and VE_DB.taskActualCoupons[taskName]
    if history and type(history) ~= "table" then
        VE_DB.taskActualCoupons[taskName] = nil
        history = nil
    end
    local actual = history and #history > 0 and history[#history].amount

    return actual or base, base
end

function Tracker:RefreshTrackedTasks()
    if not C_NeighborhoodInitiative then return end
    local trackedInfo = C_NeighborhoodInitiative.GetTrackedInitiativeTasks()
    if not trackedInfo or not trackedInfo.trackedIDs then return end

    local state = VE.Store:GetState()
    local tasks = state.tasks
    for _, task in ipairs(tasks) do
        task.tracked = tContains(trackedInfo.trackedIDs, task.id)
    end
    VE.Store:Dispatch("SET_TASKS", { tasks = tasks })
end

-- ============================================================================
-- ACTIVITY LOG
-- ============================================================================

function Tracker:RefreshActivityLogCache()
    if not C_NeighborhoodInitiative then return end
    if not C_NeighborhoodInitiative.GetInitiativeActivityLogInfo then return end

    local debug = VE.Store:GetState().config.debug
    if not self:IsViewingActiveNeighborhood() then
        if debug then
            print("|cFFffd700[VE Tracker]|r Skipping activity log refresh for non-active neighborhood")
        end
        return
    end

    if debug then
        print("|cFF2aa198[VE Tracker]|r Refreshing activity log cache...")
    end

    self.cachedActivityLog = C_NeighborhoodInitiative.GetInitiativeActivityLogInfo()
    self.activityLogLoaded = true
    self.activityLogLastUpdated = time()
    self.activityLogStale = false

    -- Feed activity log into XPEngine for full XP recalculation
    if self.currentHouseGUID and self.cachedActivityLog then
        VE.XPEngine:IngestActivityLog(
            self.currentHouseGUID,
            self.cachedActivityLog,
            VE_DB.myCharacters or {},
            UnitName("player")
        )
    end

    VE.EventBus:Trigger("VE_ACTIVITY_LOG_UPDATED", { timestamp = self.activityLogLastUpdated })
end

function Tracker:IsActivityLogLoaded()
    return self.activityLogLoaded
end

-- ============================================================================
-- XP ENGINE DELEGATION
-- All XP calculations are owned by VE.XPEngine. These wrappers maintain the
-- method signatures that UI code already calls on EndeavorTracker.
-- Data flows in via IngestActivityLog (RefreshActivityLogCache) and
-- IngestLiveTasks (ProcessInitiativeInfo). GUID set via SetActiveGUID.
-- ============================================================================

function Tracker:GetCachedHouseXP()
    return VE.XPEngine:GetHouseXP()
end

function Tracker:GetCachedPlayerContribution()
    return VE.XPEngine:GetPlayerContribution()
end

function Tracker:GetAccountCompletionCount(taskID)
    return VE.XPEngine:GetAccountCompletionCount(taskID)
end

function Tracker:GetPlayerCompletionCount(taskID)
    return VE.XPEngine:GetPlayerCompletionCount(taskID)
end

function Tracker:CalculateNextContribution(taskName, completions)
    return VE.XPEngine:CalculateNextContribution(taskName, completions)
end

function Tracker:GetTaskRankings()
    return VE.XPEngine:GetTaskRankings()
end

function Tracker:GetActivityLogData()
    return VE.XPEngine:GetActivityLogData() or self.cachedActivityLog
end

-- ============================================================================
-- CHARACTER PROGRESS
-- ============================================================================

function Tracker:SaveCurrentCharacterProgress()
    local charKey = VE:GetCharacterKey()
    local name = UnitName("player")
    local realm = GetRealmName()
    local _, class = UnitClass("player")

    local state = VE.Store:GetState()
    local taskProgress = {}
    for _, task in ipairs(state.tasks) do
        taskProgress[task.id] = {
            completed = task.completed,
            current = task.current,
            max = task.max,
        }
    end

    VE.Store:Dispatch("UPDATE_CHARACTER_PROGRESS", {
        charKey = charKey,
        name = name,
        realm = realm,
        class = class,
        tasks = taskProgress,
        endeavorInfo = {
            seasonName = state.endeavor.seasonName,
            currentProgress = state.endeavor.currentProgress,
            maxProgress = state.endeavor.maxProgress,
        },
    })
end

function Tracker:GetTrackedCharacters()
    local state = VE.Store:GetState()
    local characters = {}
    if not state.characters then return characters end

    for charKey, charData in pairs(state.characters) do
        table.insert(characters, {
            key = charKey,
            name = charData.name,
            realm = charData.realm,
            class = charData.class,
            lastUpdated = charData.lastUpdated,
        })
    end

    table.sort(characters, function(a, b)
        return a.name < b.name
    end)

    return characters
end

function Tracker:GetCharacterProgress(charKey)
    local state = VE.Store:GetState()
    return state.characters[charKey]
end

-- ============================================================================
-- TASK TRACKING API
-- ============================================================================

function Tracker:TrackTask(taskID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.AddTrackedInitiativeTask then
        C_NeighborhoodInitiative.AddTrackedInitiativeTask(taskID)
    end
end

function Tracker:UntrackTask(taskID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RemoveTrackedInitiativeTask then
        C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(taskID)
    end
end

function Tracker:GetTaskLink(taskID)
    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetInitiativeTaskChatLink then
        return C_NeighborhoodInitiative.GetInitiativeTaskChatLink(taskID)
    end
    return nil
end

function Tracker:GetTaskByName(taskName)
    local state = VE.Store:GetState()
    if not state or not state.tasks then return nil end
    for _, task in ipairs(state.tasks) do
        if task.name == taskName then return task end
    end
    return nil
end

-- ============================================================================
-- HOUSE MANAGEMENT
-- ============================================================================

function Tracker:SelectHouse(index)
    if not self.houseList or #self.houseList == 0 then return end
    if index < 1 or index > #self.houseList then return end

    local houseInfo = self.houseList[index]
    if not houseInfo or not houseInfo.neighborhoodGUID then return end

    if self.pendingRetryTimer then
        self.pendingRetryTimer:Cancel()
        self.pendingRetryTimer = nil
    end

    self.selectedHouseIndex = index
    self.lastManualSelectionTime = GetTime()
    VE_DB = VE_DB or {}
    VE_DB.selectedHouseGUID = houseInfo.houseGUID
    self.currentHouseGUID = houseInfo.houseGUID

    -- Switch XPEngine to this GUID; restore cached values for instant display
    VE.XPEngine:SetActiveGUID(houseInfo.houseGUID)
    VE.XPEngine:RestoreFromSaved(houseInfo.houseGUID)

    local debug = VE.Store:GetState().config.debug

    if debug then
        print("|cFF2aa198[VE Tracker]|r Selecting house: " .. (houseInfo.houseName or "Unknown") .. " in neighborhood " .. tostring(houseInfo.neighborhoodGUID))
    end

    self:UpdateFetchStatus("fetching", 0, nil)

    -- Clear old data to prevent cross-contamination
    VE.Store:Dispatch("SET_TASKS", { tasks = {} })
    self.activityLogLoaded = false
    self.cachedActivityLog = nil

    if VE.Vamoose and VE.Vamoose.ResetTracking then
        VE.Vamoose.ResetTracking()
    end
    VE.EventBus:Trigger("VE_ACTIVITY_LOG_UPDATED", { timestamp = nil })

    if houseInfo.houseGUID then
        VE.Store:Dispatch("SET_HOUSE_GUID", { houseGUID = houseInfo.houseGUID })
        if C_Housing and C_Housing.GetCurrentHouseLevelFavor then
            pcall(C_Housing.GetCurrentHouseLevelFavor, houseInfo.houseGUID)
        end
    end

    if C_NeighborhoodInitiative then
        C_NeighborhoodInitiative.SetViewingNeighborhood(houseInfo.neighborhoodGUID)
        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
        self:RequestActivityLog()

        C_Timer.After(1.5, function()
            self:RefreshActivityLogCache()
            self:QueueDataRefresh()
        end)

        if debug then
            print("|cFF2aa198[VE Tracker]|r Called SetViewingNeighborhood and RequestNeighborhoodInitiativeInfo (not active yet)")
        end
    end
end

function Tracker:SetAsActiveEndeavor()
    if not self.selectedHouseIndex or not self.houseList then return end
    local houseInfo = self.houseList[self.selectedHouseIndex]
    if not houseInfo or not houseInfo.neighborhoodGUID then return end

    local debug = VE.Store:GetState().config.debug

    if C_NeighborhoodInitiative and C_NeighborhoodInitiative.SetActiveNeighborhood then
        C_NeighborhoodInitiative.SetActiveNeighborhood(houseInfo.neighborhoodGUID)

        if debug then
            print("|cFF2aa198[VE Tracker]|r Set active neighborhood: " .. tostring(houseInfo.neighborhoodGUID))
        end

        self.currentHouseGUID = houseInfo.houseGUID
        self.activityLogLoaded = false

        -- Switch XPEngine to new active GUID
        VE.XPEngine:SetActiveGUID(houseInfo.houseGUID)

        print("|cFF2aa198[VE]|r Active Endeavor switched to |cFFffd700" .. (houseInfo.houseName or "Unknown") .. "|r. |cFFcb4b16All task progress/XP now applies to this house.|r")

        self:UpdateFetchStatus("fetching", 0, nil)
        VE.EventBus:Trigger("VE_ACTIVE_NEIGHBORHOOD_CHANGED")

        C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
        self:RequestActivityLog()

        C_Timer.After(1.5, function()
            self:RefreshActivityLogCache()
            self:QueueDataRefresh()
        end)
    end
end

function Tracker:GetHouseList()
    return self.houseList or {}
end

function Tracker:GetSelectedHouseIndex()
    return self.selectedHouseIndex or 1
end
