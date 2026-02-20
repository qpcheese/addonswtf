local addonName, ns = ...

local frame = CreateFrame("Frame")
local MIND_SEEKER_ACHIEVEMENT = 62189

ns.completedCount = 0
ns.confirmedCount = 0
ns.achievementEarned = false
ns.results = {}
ns.confirmed = {}

-- Build reverse lookup: "Record of XXXX" -> secret index
ns.recordLookup = {}
for i, secret in ipairs(ns.secrets) do
    if secret.record then
        ns.recordLookup[secret.record] = i
    end
end

-- Detection logic per secret type
local function CheckSecret(secret)
    local t, id = secret.type, secret.id
    if t == "mount" then
        local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
        return isCollected or false
    elseif t == "pet" then
        local numCollected = C_PetJournal.GetNumCollectedInfo(id)
        return (numCollected or 0) > 0
    elseif t == "toy" then
        return PlayerHasToy(id)
    elseif t == "quest" then
        return C_QuestLog.IsQuestFlaggedCompleted(id)
    elseif t == "transmog" then
        return C_TransmogCollection.PlayerHasTransmogByItemInfo(id)
    elseif t == "achievement" then
        local _, _, _, completed = GetAchievementInfo(id)
        return completed or false
    end
    return false
end

function ns:CheckAllSecrets()
    local count = 0
    for i, secret in ipairs(ns.secrets) do
        local done = CheckSecret(secret)
        ns.results[i] = done
        if done then
            count = count + 1
        end
    end
    ns.completedCount = count
    -- Check if the actual FoS has been earned
    local _, _, _, completed = GetAchievementInfo(MIND_SEEKER_ACHIEVEMENT)
    ns.achievementEarned = completed or false
    return ns.results, count
end

-- Scan the active tooltip for Record holograms in the Seat of Knowledge (mapID 947)
local SEAT_OF_KNOWLEDGE_MAP = 947

function ns:ScanTooltipForRecord()
    if not WorldMapFrame then return end
    local mapID = WorldMapFrame:GetMapID()
    if mapID ~= SEAT_OF_KNOWLEDGE_MAP then return end

    local raw = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
    local line = raw and tostring(raw)
    if not line then return end

    local idx = ns.recordLookup[line]
    if not idx then return end
    if ns.confirmed[idx] then return end

    ns.confirmed[idx] = true
    ns.confirmedCount = ns.confirmedCount + 1
    local db = ns:GetDB()
    db.confirmed = db.confirmed or {}
    db.confirmed[idx] = true

    if ns.RefreshUI then
        ns:RefreshUI()
    end
    print("|cff00ccffMind-Seekers Tracker:|r Confirmed: " .. ns.secrets[idx].name)
end

-- Hook GameTooltip to detect Record holograms via text change detection
local lastScannedText = nil
local scanDebug = false
GameTooltip:HookScript("OnUpdate", function(self)
    if not self:IsShown() then return end
    if not WorldMapFrame or WorldMapFrame:GetMapID() ~= SEAT_OF_KNOWLEDGE_MAP then return end
    local raw = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
    local text = raw and tostring(raw)
    if text and text ~= lastScannedText then
        lastScannedText = text
        if scanDebug then
            local mapID = WorldMapFrame:GetMapID()
            local match = ns.recordLookup[text] and "MATCH" or "no match"
            print(("|cff00ccffMST Scan:|r mapID=%d text=\"%s\" [%s]"):format(mapID, text, match))
        end
        ns:ScanTooltipForRecord()
    end
end)
GameTooltip:HookScript("OnHide", function()
    lastScannedText = nil
end)

-- Debug: print raw API results for every secret so we can find bad IDs
local function DebugSecrets()
    local PREFIX = "|cff00ccffMST Debug:|r "
    for i, s in ipairs(ns.secrets) do
        local t, id = s.type, s.id
        local raw, result
        if t == "mount" then
            local name, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
            raw = ("name=%s collected=%s"):format(tostring(name), tostring(isCollected))
            result = isCollected or false
        elseif t == "pet" then
            local numCollected, numMax = C_PetJournal.GetNumCollectedInfo(id)
            raw = ("collected=%s max=%s"):format(tostring(numCollected), tostring(numMax))
            result = (numCollected or 0) > 0
        elseif t == "toy" then
            local has = PlayerHasToy(id)
            raw = ("hasToy=%s"):format(tostring(has))
            result = has
        elseif t == "quest" then
            local done = C_QuestLog.IsQuestFlaggedCompleted(id)
            raw = ("questDone=%s"):format(tostring(done))
            result = done
        elseif t == "transmog" then
            local has = C_TransmogCollection.PlayerHasTransmogByItemInfo(id)
            raw = ("hasTransmog=%s"):format(tostring(has))
            result = has
        elseif t == "achievement" then
            local _, achName, _, completed = GetAchievementInfo(id)
            raw = ("achName=%s completed=%s"):format(tostring(achName), tostring(completed))
            result = completed or false
        end
        local status = result and "|cff00ff00YES|r" or "|cffff4444NO|r"
        print(PREFIX .. ("%d. %s [%s id=%s] %s — %s"):format(i, s.name, t, tostring(id), status, raw or "?"))
    end
end

-- Saved variables defaults
local defaults = {
    point = "RIGHT",
    x = -50,
    y = 0,
    shown = true,
    collapsed = false,
}

function ns:GetDB()
    if not MindSeekersTrackerDB then
        MindSeekersTrackerDB = {}
    end
    for k, v in pairs(defaults) do
        if MindSeekersTrackerDB[k] == nil then
            MindSeekersTrackerDB[k] = v
        end
    end
    return MindSeekersTrackerDB
end

-- Event handling
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        local db = ns:GetDB()
        -- Restore confirmed state from saved variables
        if db.confirmed then
            local count = 0
            for idx, val in pairs(db.confirmed) do
                if val then
                    ns.confirmed[idx] = true
                    count = count + 1
                end
            end
            ns.confirmedCount = count
        end
        ns:CheckAllSecrets()
        if ns.BuildUI then
            ns:BuildUI()
        end
        -- Journal-ready events (data not available at PLAYER_LOGIN)
        self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
        self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
        self:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
        -- Ongoing update events
        self:RegisterEvent("NEW_MOUNT_ADDED")
        self:RegisterEvent("NEW_PET_ADDED")
        self:RegisterEvent("QUEST_TURNED_IN")
        self:RegisterEvent("NEW_TOY_ADDED")
        self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")
        self:RegisterEvent("ACHIEVEMENT_EARNED")
        -- Delayed recheck for anything that loads late
        C_Timer.After(3, function()
            ns:CheckAllSecrets()
            if ns.RefreshUI then ns:RefreshUI() end
        end)
    else
        ns:CheckAllSecrets()
        if ns.RefreshUI then
            ns:RefreshUI()
        end
    end
end)

-- Slash commands
SLASH_MINDSEEKER1 = "/mst"
SLASH_MINDSEEKER2 = "/mindseeker"
SlashCmdList["MINDSEEKER"] = function(msg)
    msg = strtrim(msg):lower()
    if msg == "reset" then
        local db = ns:GetDB()
        db.point = defaults.point
        db.x = defaults.x
        db.y = defaults.y
        if ns.tracker then
            ns.tracker:ClearAllPoints()
            ns.tracker:SetPoint(db.point, UIParent, db.point, db.x, db.y)
        end
        print("|cff00ccffMind-Seekers Tracker:|r Position reset.")
        return
    end
    if msg == "debug" then
        DebugSecrets()
        return
    end
    if ns.tracker then
        local db = ns:GetDB()
        if ns.tracker:IsShown() then
            ns.tracker:Hide()
            db.shown = false
        else
            ns:CheckAllSecrets()
            ns:RefreshUI()
            ns.tracker:Show()
            db.shown = true
        end
    end
end
