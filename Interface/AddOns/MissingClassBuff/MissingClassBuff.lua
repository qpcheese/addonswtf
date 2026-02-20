--- Missing Class Buff
--- Written by Kaloryth

local ADDON_NAME, MCB = ...
local LEM = LibStub('LibEditMode')
local MSQ = LibStub("Masque", true)

local MyAddon = LibStub("AceAddon-3.0"):NewAddon(
    ADDON_NAME,
    "AceConsole-3.0",
    "AceEvent-3.0"
)
MCB.MyAddon = MyAddon
MCB.MISSING_FRAME = CreateFrame('Frame', 'MCBFrame', UIParent)
MCB.MISSING_FRAME:Hide()

MCB.SECURE_BUTTON = CreateFrame("Button", "MCBSecureCastButton", UIParent, "SecureActionButtonTemplate")
--hides the clickable button during combat -- leaves it hidden after combat ends
RegisterStateDriver(MCB.SECURE_BUTTON, "visibility", "[combat] hide; nil")

MCB.BUFF_IN_FRAME = {}
MCB.ONE_TIME_SETUP = false
MCB.MasqueGroup = nil

MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES = true
MCB.FOUND_SECRET_VALUE_ISSUE = false

MCB.AURA_INFO_CACHE = {intialized = {}, hasSecretValueIssues = {}, arrays = {}}
MCB.EMPTY_TABLE = {}
MCB.UNITS_TABLE = {}
MCB.UNIT_STRINGS = {
    raid = {},
    party = {}
}
for i = 1, 40 do
    MCB.UNIT_STRINGS.raid[i] = "raid" .. i
    if i <= 5 then
        MCB.UNIT_STRINGS.party[i] = "party" .. i
    end
end

MCB.CHECK_THROTTLE = 0.25

--Handling how the frames are setup and displayed to show the missing buffs
function MCB.InitializeFrame()
    MissingClassBuffDB = MissingClassBuffDB or {}
    local function onPositionChanged(frame, layoutName, point, x, y)
        MissingClassBuffDB["layouts"][layoutName].point = point
        MissingClassBuffDB["layouts"][layoutName].x = x
        MissingClassBuffDB["layouts"][layoutName].y = y
    end

    local function handleSettingUpFrame(layoutName)
        MissingClassBuffDB = MissingClassBuffDB or {}
        if not MissingClassBuffDB["layouts"] then
            MissingClassBuffDB["layouts"] = {}
        end
        if not MissingClassBuffDB["layouts"][layoutName] then
            MissingClassBuffDB["layouts"][layoutName] = CopyTable(MCB.DEFAULT_SETTINGS)
        else
            local function copyMissingElements(target, source)
                for key, value in pairs(source) do
                    if target[key] == nil then
                        target[key] = value
                    end
                end
            end
            copyMissingElements(MissingClassBuffDB["layouts"][layoutName], MCB.DEFAULT_SETTINGS)
        end

        local layoutSettings = MissingClassBuffDB["layouts"][layoutName]
        MCB.MISSING_FRAME:ClearAllPoints()
        MCB.MISSING_FRAME:SetPoint(layoutSettings.point, layoutSettings.x, layoutSettings.y)
        MCB.MISSING_FRAME:SetSize(layoutSettings.frameWidth, layoutSettings.frameHeight)

        MCB.MISSING_FRAME.iconFrame = MCB.MISSING_FRAME.iconFrame or CreateFrame("Frame", nil, MCB.MISSING_FRAME)
        MCB.MISSING_FRAME.iconFrame:SetSize(layoutSettings.iconWidth, layoutSettings.iconHeight)
        MCB.MISSING_FRAME.iconFrame:SetPoint("TOP", MCB.MISSING_FRAME, "TOP")

        MCB.MISSING_FRAME.icon = MCB.MISSING_FRAME.icon or MCB.MISSING_FRAME.iconFrame:CreateTexture(nil, "ARTWORK")
        MCB.MISSING_FRAME.icon:SetAllPoints(MCB.MISSING_FRAME.iconFrame)
        MCB.MISSING_FRAME.icon:SetAlpha(layoutSettings.alpha)

        MCB.MISSING_FRAME.text = MCB.MISSING_FRAME.text or MCB.MISSING_FRAME:CreateFontString(nil, "OVERLAY")
        MCB.MISSING_FRAME.text:ClearAllPoints()
        
        local fontObject = _G[MCB.DEFAULT_SETTINGS.textFont] or GameFontNormal
        local font = fontObject:GetFont()
        MCB.MISSING_FRAME.text:SetFont(font, layoutSettings.fontSize, "OUTLINE")
        MCB.MISSING_FRAME.text:SetPoint("TOP", MCB.MISSING_FRAME.iconFrame, "BOTTOM", 0, -4)

        if layoutSettings.hideText then
            MCB.MISSING_FRAME.text:Hide()
        else
            MCB.MISSING_FRAME.text:Show()
        end
        if not MCB.ONE_TIME_SETUP then
            MCB.ONE_TIME_SETUP = true
            local clickableButton = MCB.SECURE_BUTTON
            clickableButton:ClearAllPoints()
            MCB.SECURE_BUTTON:EnableMouse(true)
            MCB.SECURE_BUTTON:RegisterForClicks("AnyUp", "AnyDown")
            clickableButton:SetFrameStrata("MEDIUM")
            clickableButton:SetFrameLevel(MCB.MISSING_FRAME:GetFrameLevel() + 20)

            MCB.MISSING_FRAME:EnableMouse(false)

            if MSQ then
                MCB.MasqueGroup = MSQ:Group(ADDON_NAME, "MCB Icon")
                local buttonData = {
                    Icon = MCB.MISSING_FRAME.icon,
                }
                MCB.MasqueGroup:AddButton(MCB.MISSING_FRAME.iconFrame, buttonData)
            end
        end

        if MSQ and MCB.MasqueGroup then
            MCB.MasqueGroup:ReSkin()
        end

        if not InCombatLockdown() then
            local iconCenterOffset = (layoutSettings.frameHeight / 2) - (layoutSettings.iconHeight / 2)
            MCB.SECURE_BUTTON:ClearAllPoints()
            MCB.SECURE_BUTTON:SetPoint(
                layoutSettings.point,
                layoutSettings.x,
                layoutSettings.y + iconCenterOffset
            )
            MCB.SECURE_BUTTON:SetSize(layoutSettings.iconWidth, layoutSettings.iconHeight)
        end
    end

    LEM:RegisterCallback('layout', function(layoutName)
        handleSettingUpFrame(layoutName)
    end)

    LEM:RegisterCallback('enter', function()
        MCB.ShowMissingMessage(MCB.DEFAULT_BUFF)
        MCB.MISSING_FRAME:Show()
    end)

    LEM:RegisterCallback('exit', function(layoutName)
        if not layoutName then
            layoutName = LEM:GetActiveLayoutName() or "Modern"
        end
        handleSettingUpFrame(layoutName)
        MCB.CheckForMissings()
    end)

    local defaultPosition = {
        point = MCB.DEFAULT_SETTINGS.point,
        x = MCB.DEFAULT_SETTINGS.x,
        y = MCB.DEFAULT_SETTINGS.y
    }

    LEM:AddFrame(MCB.MISSING_FRAME, onPositionChanged, defaultPosition)
    LEM:AddFrameSettings(MCB.MISSING_FRAME, MCB.EDIT_MODE_SETTINGS)

    --this is to deal with a really stupid bug having to do with talent swapping where Blizzard forcibly changes your layout
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:SetScript("OnEvent", function(self, event, unit)
        if unit == "player" then
            -- We wait 1 second because Blizzard's forced layout swap 
            -- happens slightly AFTER the spec change event finishes.
            C_Timer.After(1, function()
                local layoutName = LEM:GetActiveLayoutName() or "Modern"
                handleSettingUpFrame(layoutName)
            end)
        end
    end)
end


--Setup for actually doing the buff checking
function MyAddon:OnEnable()
    MCB.LoadPlayerData()
    MCB.CheckAllLearned()
    MCB.cacheCustomItemIds()
    MCB.CHECK_THROTTLE = MyAddon.db.profile.debounceCheckThrottle
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function(self, ...)
        MCB.instanceId = nil
        MCB.instanceDifficultyId = nil
        MCB.instanceType = nil
        --WoW can be laggy in getting instance information so we need a delayed backup
        MCB.setInstanceInformation()
        C_Timer.After(.5, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
        --this is a super backup
        C_Timer.After(5, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function(self, ...)
        MCB.instanceId = nil
        MCB.instanceDifficultyId = nil
        MCB.instanceType = nil
        --WoW can be laggy in getting instance information so we need a delayed backup
        MCB.setInstanceInformation()
        C_Timer.After(.5, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("SCENARIO_UPDATE", function(self, ...)
        MCB.instanceId = nil
        MCB.instanceDifficultyId = nil
        MCB.instanceType = nil
        --WoW can be laggy in getting instance information so we need a delayed backup
        MCB.setInstanceInformation()
        C_Timer.After(1, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
    end)
    --to catch transition from mythic to m+
    self:RegisterEvent("CHALLENGE_MODE_START", function(self, ...)
        MCB.instanceId = nil
        MCB.instanceDifficultyId = nil
        MCB.instanceType = nil
        --WoW can be laggy in getting instance information so we need a delayed backup
        MCB.setInstanceInformation()
        MCB.CheckForMissings()
        C_Timer.After(1, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
    end)
    --to catch transition from mythic to m+
    self:RegisterEvent("START_TIMER", function(self, ...)
        MCB.instanceId = nil
        MCB.instanceDifficultyId = nil
        MCB.instanceType = nil
        --WoW can be laggy in getting instance information so we need a delayed backup
        MCB.setInstanceInformation()
        MCB.CheckForMissings()
        C_Timer.After(1, function()
            MCB.setInstanceInformation()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("UNIT_AURA", function(self, unit, updateInfo, ...)
        MCB.handleEventUnitAura(unit, updateInfo)
    end)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", function(self, ...)
        MCB.CheckForMissings(true)
    end)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", function(self, ...)
        MCB.CheckForMissings()
    end)
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function(self, ...)
        MCB.CheckForMissings()
    end)
    self:RegisterEvent("PLAYER_DEAD", function(self, ...)
        MCB.CheckForMissings()
    end)
    self:RegisterEvent("PLAYER_UNGHOST", function(self, ...)
        MCB.CheckForMissings()
    end)
    self:RegisterEvent("PLAYER_ALIVE", function(self, ...)
        MCB.CheckForMissings()
    end)
    self:RegisterEvent("UNIT_CONNECTION", function(self, ...)
        MCB.CheckForMissings(true)
    end)
    self:RegisterEvent("PLAYER_CONTROL_LOST", function(self, ...)
        C_Timer.After(.5, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("PLAYER_CONTROL_GAINED", function(self, ...)
        C_Timer.After(.5, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("PET_BATTLE_OPENING_START", function(self, ...)
        C_Timer.After(.5, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("PET_BATTLE_CLOSE", function(self, ...)
        C_Timer.After(1, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", function(self, unit, ...)
        if not (unit == "player") then
            return
        end
        C_Timer.After(1, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("UNIT_EXITED_VEHICLE", function(self, unit,...)
        if not (unit == "player") then
            return
        end
        C_Timer.After(1, function()
            MCB.CheckForMissings()
        end)
    end)
    self:RegisterEvent("INCOMING_RESURRECT_CHANGED", function(self, unit)
        local targetUnit = unit
        -- need to wait for accept to happen
        C_Timer.After(2, function()
            if targetUnit and UnitExists(targetUnit) and not UnitIsDeadOrGhost(targetUnit) and not InCombatLockdown() then
                MCB.CheckForMissings(true)
            end
        end)
    end)
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", function(self, ...)
        if MCB.BuffsHaveAnEnchant() then
            MCB.CheckForMissings(true)
        end
    end)
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", function(self, ...)
        if MCB.CLASS_STATE.isDruid and MyAddon.db.profile.treatTravelFormAsMount then
            C_Timer.After(.25, function()
                MCB.CheckForMissings()
            end)
        end
    end)

    self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatEntered")
    self:RegisterEvent("TRAIT_CONFIG_UPDATED", "TalentsUpdated")
    self:RegisterEvent("PLAYER_LEVEL_UP", "TalentsUpdated")
    self:RegisterEvent("SPELLS_CHANGED", "TalentsUpdated")
    --want to register if it's a pet class, can figure out if we need to do logic based on character state at run time
    if MCB.CLASS_STATE.isDeathKnight or MCB.CLASS_STATE.isHunter or MCB.CLASS_STATE.isWarlock or MCB.CLASS_STATE.isMage then
        self:RegisterEvent("UNIT_PET", "PetEventFired")
    end

    local function populateMPlusDungeons()
        local activeChallengeMapIDs = C_ChallengeMode.GetMapTable()
        
        for _, challengeID in ipairs(activeChallengeMapIDs) do
            local _, _, _, _, _, instanceID = C_ChallengeMode.GetMapUIInfo(challengeID)
            
            if instanceID then
                MCB.CURRENT_MYTHIC_PLUS_DUNGEONS[instanceID] = true
            end
        end
    end
    populateMPlusDungeons()
end

function MyAddon:OnInitialize()
    MCB.InitializeFrame()
    MCB.InstantiateSettings()
end

function MCB.setInstanceInformation()
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
    if instanceID then
        if instanceID > 0 then
            MCB.instanceId = instanceID
            MCB.instanceType = instanceType
            MCB.instanceDifficultyId = difficultyID
        else
            if instanceType then
                MCB.instanceType = instanceType
            end
            if difficultyID then
                MCB.instanceDifficultyId = difficultyID
            end
        end
        
    end
end

function MCB.handleEventUnitAura(unit, updateInfo)
    --we will ignore except on pet classes or shapeshift form classes in combat -- cannot reliably detect mount/dismounts otherwise -- doesn't matter if buff is private, dismount will still send an aura update
    --we are in combat and (we don't care about pets or it's not the player)
    --then skip it!
    if not MCB.isUnitWeCareAbout(unit) or (InCombatLockdown() and (not (MCB.ShouldCheckForPet() or MCB.needsShapeshiftFormCheck() or MCB.doSpellOverlayChecks()) or (not (unit == "player") and not MCB.doSpellOverlayChecks()))) then
        return
    end

    if MCB.shouldSkipUpdate(updateInfo) then
        return
    end

    --delay checks to make mounting/dismounting less annoying
    if unit == "player" and MCB.ShouldCheckForPet() then
        MCB.IGNORE_PETS_IMPORTANT = true
        C_Timer.After(.75, function()
            MCB.IGNORE_PETS_IMPORTANT = false
            MCB.CheckForMissings(false)
        end)
        --this is to make sure we display buffs like arcane intellect properly on classes with both pets and buffs
        --true to ignore pets because we don't want that check done until the timer goes off, though something else could trigger it early
        --which is not a huge deal -- if I wanted to make this more "guaranteed" ignore, I should make ignorePets a global and have the timer
        --set it to false when it's okay to look at pets again
        if MCB.BUFFS and #MCB.BUFFS > 0 then
            MCB.CheckForMissings(true)
        end
    else
        MCB.CheckForMissings(false)
    end
end

function MCB.shouldSkipUpdate(updateInfo)
    -- if no updateInfo (old API) or full update, do not skip.
    if not updateInfo or updateInfo.isFullUpdate then
        return false
    end

    -- check added auras -- if any are helpful, do NOT skip
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            -- if aura information is secret, we'll have to just send a check through, if it's helpful we obviously want to check
            if (issecretvalue and issecretvalue(aura.isHelpful)) or aura.isHelpful then return false end
        end
    end

    --changing durations -> notifications needed maybe
    if updateInfo.updatedAuraInstanceIDs and #updateInfo.updatedAuraInstanceIDs > 0 then
        return false
    end

    -- any removal is worth checking to see if it was a buff we care about or mount
    if updateInfo.removedAuraInstanceIDs and #updateInfo.removedAuraInstanceIDs > 0 then
        return false
    end

    -- this is a debuff change we don't care about 
    return true
end

function MCB.LoadPlayerData()
    local _, class = UnitClass("player")
    MCB.BUFFS = MCB.CLASS_BUFFS[class] or {}
    if #MCB.BUFFS > 0 then
        MCB.NEEDS_BUFFS_CHECKED = true
    end

    MCB.CURRENT_SPEC_ID = GetSpecializationInfo(GetSpecialization())

    MCB.MISC_DATA.isEarthen = MCB.isUnitEarthen()

    MCB.CLASS_NAME = class
    if class == "DEATHKNIGHT" then
        MCB.CLASS_STATE.isDeathKnight = true
        MCB.setPlayerIsUnholy()
    elseif class == "DEMONHUNTER" then
        MCB.CLASS_STATE.isDemonHunter = true
    elseif class == "DRUID" then
        MCB.CLASS_STATE.isDruid = true
        MCB.setPlayerIsBalanceWithForm()
    elseif class == "EVOKER" then
        MCB.CLASS_STATE.isEvoker = true
        MCB.setPlayerIsAugmentation()
    elseif class == "HUNTER" then
        MCB.CLASS_STATE.isHunter = true
        MCB.setPlayerIsMarksmanWithPet()
    elseif class == "MAGE" then
        MCB.CLASS_STATE.isMage = true
        MCB.setPlayerIsFrostWithPet()
    elseif class == "MONK" then
        MCB.CLASS_STATE.isMonk = true
    elseif class == "PALADIN" then
        MCB.CLASS_STATE.isPaladin = true
    elseif class == "PRIEST" then
        MCB.CLASS_STATE.isPriest = true
        MCB.setPlayerIsShadowWithForm()
    elseif class == "ROGUE" then
        MCB.CLASS_STATE.isRogue = true
        MCB.setRogueWithDragonTempered()
    elseif class == "SHAMAN" then
        MCB.CLASS_STATE.isShaman = true
    elseif class == "WARLOCK" then
        MCB.CLASS_STATE.isWarlock = true
        MCB.setWarlockWithSacrifice()
    elseif class == "WARRIOR" then
        MCB.CLASS_STATE.isWarrior = true
    end
end

MCB.IGNORE_PETS_IMPORTANT = false
--debouncing checkMissing variables
local isTickerRunning = false
local lastCheckTime = 0
--This is the main function that does all the heavy lifting in events
function MCB.CheckForMissings(ignorePets)
--DEBOUNCE/DELAY CODE HERE
    local currentTime = GetTime()
    local timeSinceLast = currentTime - lastCheckTime

    -- if we are within the throttle window, schedule a delayed check and exit
    if timeSinceLast < MCB.CHECK_THROTTLE then
        if not isTickerRunning then
            isTickerRunning = true
            C_Timer.After(MCB.CHECK_THROTTLE, function()
                isTickerRunning = false
                MCB.CheckForMissings(false)
            end)
        end
        return
    end

    lastCheckTime = currentTime
--END DEBOUNCE/DELAY STUFF

    local hasMissingBuff = false;
    local buffToDisplay = nil
    local hadPetNotification = false
    local petNotificationSpellId = nil
    local showingLowDurationBuff = false

    --these must be reset otherwise the code will not work properly
    --if an entry point other than CheckForMissings is ever used, these must be reset there as well
    MCB.FOUND_SECRET_VALUE_ISSUE = false
    MCB.resetAuraCache(MCB.AURA_INFO_CACHE)
    local auraInfoCache = MCB.AURA_INFO_CACHE

    --if we are in a pet battle or dead...
    if UnitIsDeadOrGhost("player") or C_PetBattles.IsInBattle() then
        MCB.hideFrame()
        return
    end

    if MyAddon.db.profile.ignoreBuffsWhileMounted and MCB.isPlayerMounted()  then
        MCB.hideFrame()
        return
    end

    if MyAddon.db.profile.ignoreWhileResting and IsResting and IsResting() then
        MCB.hideFrame()
        return
    end

    --paladin auras, warrior stances, evoker attunements, moonkin form, shadow form checks
    if MCB.needsShapeshiftFormCheck() then
        hasMissingBuff, buffToDisplay = MCB.doShapeshiftFormCheck()
    end

    if not hasMissingBuff then
        if MCB.CLASS_STATE.isRogue and not InCombatLockdown() then
            hasMissingBuff, buffToDisplay, showingLowDurationBuff = MCB.HandleRoguePoisons(auraInfoCache)
        elseif MCB.ShouldCheckForPet() and not (ignorePets or MCB.IGNORE_PETS_IMPORTANT) then
            local petMissing, petBuffInfo = MCB.handleMissingPetChecking()
            if petMissing then
                hadPetNotification = true
                petNotificationSpellId = petBuffInfo and petBuffInfo.spellId
                hasMissingBuff = true
                buffToDisplay = petBuffInfo
            end
            if MCB.CLASS_STATE.isMage and not InCombatLockdown() then
                local missingBuff, buffFromCheck, showingLowDuration = MCB.CheckForMissingBuff(auraInfoCache)
                if missingBuff then
                    hasMissingBuff = true
                    buffToDisplay = buffFromCheck
                    showingLowDurationBuff = showingLowDuration
                end
            end
        else
            hasMissingBuff, buffToDisplay, showingLowDurationBuff = MCB.CheckForMissingBuff(auraInfoCache)
        end
    end

    --if we are ignoring pets, that means we have a delayed check coming in -- we only want to handle showing the buff if it's not a pet notification, otherwise it will hide the frame
    --or we are ignoring pets and there isn't a missing buff but there is currently a summon pet showing, we still want to keep that showing otherwise it causes
    -- the summon pet to flicker for the user
    -- the next checkMissing that fires after the delay without ignorePets should take care of hiding/showing anything important
    if (ignorePets or MCB.IGNORE_PETS_IMPORTANT) and ((hadPetNotification and buffToDisplay and buffToDisplay.spellId == petNotificationSpellId) or
        (not hasMissingBuff and MCB.BUFF_IN_FRAME and MCB.BUFF_IN_FRAME.isPet)) then
        return
    end

    --do consumable checks last only if there isn't another buff to display that needs application
    if not InCombatLockdown() and not hasMissingBuff or showingLowDurationBuff then
        local consumableNeedsNotifying = false
        local consumableBuff = nil
        local showedNeededConsumable = false
        if MyAddon.db.profile.trackFlask and MCB.needFlaskCheckInZone() then
            local needsFlask, needsNotifying = MCB.needsConsumableBuff(MCB.FLASK_DATA, auraInfoCache)
            if needsFlask then
                hasMissingBuff = true
                buffToDisplay = MCB.FLASK_DEFAULT_BUFF
                buffToDisplay = MCB.overrideConsumableBuffWithClickToCast(buffToDisplay, MyAddon.db.profile.flaskClickToCastId)
                local textToShow = buffToDisplay.text
                MCB.ShowMissingMessage(buffToDisplay, textToShow)
                showingLowDurationBuff = false
                showedNeededConsumable = true
            elseif needsNotifying then
                consumableNeedsNotifying = true
                local buffToUse = MCB.FLASK_DEFAULT_BUFF
                buffToUse = MCB.overrideConsumableBuffWithClickToCast(buffToUse, MyAddon.db.profile.flaskClickToCastId)
                consumableBuff = consumableBuff or buffToUse
            end
        end
        if not showedNeededConsumable and MyAddon.db.profile.trackFood and MCB.needFoodCheckInZone() then
            local needsFoodBuff, needsNotifying = MCB.needsFoodBuff(auraInfoCache)
            if needsFoodBuff then
                hasMissingBuff = true
                buffToDisplay = MCB.FOOD_DEFAULT_BUFF
                buffToDisplay = MCB.overrideConsumableBuffWithClickToCast(buffToDisplay, MyAddon.db.profile.foodClickToCastId)
                local textToShow = buffToDisplay.text
                MCB.ShowMissingMessage(buffToDisplay, textToShow)
                showingLowDurationBuff = false
                showedNeededConsumable = true
            elseif needsNotifying then
                consumableNeedsNotifying = true
                local buffToUse = MCB.FOOD_DEFAULT_BUFF
                buffToUse = MCB.overrideConsumableBuffWithClickToCast(buffToUse, MyAddon.db.profile.foodClickToCastId)
                consumableBuff = consumableBuff or  buffToUse
            end
        end

        if not showedNeededConsumable and MyAddon.db.profile.trackOil and MCB.needOilCheckInZone() then
            local needsOilBuff, needsNotifying = MCB.needsOilBuff()
            if needsOilBuff then
                hasMissingBuff = true
                buffToDisplay = MCB.OIL_DEFAULT_BUFF
                buffToDisplay = MCB.overrideConsumableBuffWithClickToCast(buffToDisplay, MyAddon.db.profile.oilClickToCastId)
                local textToShow = buffToDisplay.text
                MCB.ShowMissingMessage(buffToDisplay, textToShow)
                showingLowDurationBuff = false
                showedNeededConsumable = true
            elseif needsNotifying then
                consumableNeedsNotifying = true
                local buffToUse = MCB.OIL_DEFAULT_BUFF
                buffToUse = MCB.overrideConsumableBuffWithClickToCast(buffToUse, MyAddon.db.profile.oilClickToCastId)
                consumableBuff = consumableBuff or  buffToUse
            end
        end

        if not showedNeededConsumable and MyAddon.db.profile.showCustomSpellIds and MCB.needCustomSpellIdsInZone() then
            local needsCustomSpellIdBuff, spellId, clickableId, clickableType, needsNotifying = MCB.needsCustomSpellIdBuff(auraInfoCache)
            if needsCustomSpellIdBuff then
                local disableClicking = true
                if clickableId then disableClicking = false end
                hasMissingBuff = true
                local fakedBuff = {spellId = spellId, clickableId = clickableId, disableClicking = disableClicking, clickableType = clickableType, text = MCB.MISSING_TEXT}
                buffToDisplay = fakedBuff
                MCB.ShowMissingMessage(fakedBuff, fakedBuff.text)
                showingLowDurationBuff = false
                showedNeededConsumable = true
            elseif needsNotifying then
                consumableNeedsNotifying = true
                local disableClicking = true
                if clickableId then disableClicking = false end
                local fakedBuff = {spellId = spellId, clickableId = clickableId, disableClicking = disableClicking, clickableType = clickableType, text = MCB.REAPPLY_TEXT}
                consumableBuff = consumableBuff or fakedBuff
            end
        end

        if not showedNeededConsumable and not showingLowDurationBuff and consumableNeedsNotifying and consumableBuff then
            hasMissingBuff = true
            buffToDisplay = consumableBuff
            MCB.ShowMissingMessage(consumableBuff, MCB.REAPPLY_TEXT)
            showingLowDurationBuff = true
        end
    end

    MCB.handleShowHideFrame(hasMissingBuff, buffToDisplay)
end

function MCB.resetAuraCache(cache)
    if cache.arrays then
        for _, unitArray in pairs(cache.arrays) do
            for i = 1, #unitArray do
                local auraObject = unitArray[i]
                if type(auraObject) == "table" then
                    MCB.releaseTableToPool(auraObject)
                end
            end
            wipe(unitArray) -- Now empty the unit's list after releasing all the tables back to the pool
        end
    end

    for key, unitTable in pairs(cache) do
        -- Only wipe if the key isn't one of our three management tables
        if key ~= "hasSecretValueIssues" and key ~= "initialized" and key ~= "arrays" then
            wipe(unitTable)
        end
    end
    
    if cache.hasSecretValueIssues then wipe(cache.hasSecretValueIssues) end
    if cache.initialized then wipe(cache.initialized) end
    
    cache.hasSecretValueIssues = cache.hasSecretValueIssues or {}
    cache.arrays = cache.arrays or {}
    cache.initialized = cache.initialized or {}
end

function MCB.getUnitAurasFromCache(unitName, auraCache)
    if unitName and auraCache then
        if auraCache.initialized and auraCache.initialized[unitName] and auraCache[unitName] then
            return auraCache[unitName]
        else
            MCB.handleCreatingAuraCache(unitName, auraCache)
        end
        return auraCache[unitName]
    end
    return MCB.EMPTY_TABLE
end

function MCB.getUnitAurasArrayFromCache(unitName, auraCache)
    if unitName and auraCache then
        if auraCache.initialized and auraCache.initialized[unitName] and auraCache.arrays[unitName] then
            return auraCache.arrays[unitName]
        else
            MCB.handleCreatingAuraCache(unitName, auraCache)
        end
        return auraCache.arrays[unitName]
    end
    return MCB.EMPTY_TABLE
end

MCB.TABLE_POOL = {}
function MCB.getTableFromPool()
    return table.remove(MCB.TABLE_POOL) or {}
end

function MCB.releaseTableToPool(auraTable)
    wipe(auraTable)
    table.insert(MCB.TABLE_POOL, auraTable)
end

function MCB.handleCreatingAuraCache(unitName, auraCache)
    --consider trying to handle this with a table pool
    auraCache[unitName] = auraCache[unitName] or {}
    auraCache.arrays = auraCache.arrays or {}
    auraCache.arrays[unitName] = auraCache.arrays[unitName] or {}
    auraCache.initialized = auraCache.initialized or {}
    auraCache.initialized[unitName] = true
    wipe(auraCache[unitName])
    wipe(auraCache.arrays[unitName])

    local hasSecretValueIssues = false

    AuraUtil.ForEachAura(unitName, "HELPFUL", nil, function(auraInfo)
        if not auraInfo or (issecretvalue and issecretvalue(auraInfo.spellId))  then
            hasSecretValueIssues = true
            MCB.FOUND_SECRET_VALUE_ISSUE = true
            if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES then
                return true
            end
            return false
        end

        -- copy data into a table from our table of pools
        local cacheEntry = MCB.getTableFromPool()
        for k, v in pairs(auraInfo) do cacheEntry[k] = v end
        
        table.insert(auraCache.arrays[unitName], cacheEntry)
        auraCache[unitName][cacheEntry.spellId] = cacheEntry
        if MCB.FOUND_SECRET_VALUE_ISSUE and MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES then
            return true
        end
    end, true)

    if hasSecretValueIssues and auraCache.hasSecretValueIssues then
        auraCache.hasSecretValueIssues[unitName] = true
    end
end

-- returns needsBuff, spellId, clickableId, clickableType, needsNotifying
function MCB.needsCustomSpellIdBuff(auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE then
        return false, false
    end 
    if MyAddon.db.profile.customSpellIds and #MyAddon.db.profile.customSpellIds > 0 then
        if not InCombatLockdown() and UnitExists("player") and not UnitIsDeadOrGhost("player") then
            local haveBuffThatNeedsNotification = false
            local notificationSpellEntry = nil
            local auraInfoList = MCB.getUnitAurasFromCache("player", auraInfoCache)
            local hasSecretValueIssues = true
            if auraInfoCache.hasSecretValueIssues then
                hasSecretValueIssues = auraInfoCache.hasSecretValueIssues["player"]
            end
            for _, spellEntry in ipairs(MyAddon.db.profile.customSpellIds) do
                local aura = auraInfoList[spellEntry.spellId]
                local hideNotInInventory = MyAddon.db.profile.hideCustomIfItemNotInInventory and spellEntry.clickableType and spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM
                local itemInInventory = false
                if hideNotInInventory then
                    itemInInventory = C_Item.GetItemCount(spellEntry.clickableId) > 0
                end

                if not aura then
                    --check if item associated with spell entry is on CD
                    if MyAddon.db.profile.hideCustomIfItemOnCD and spellEntry.clickableType and (spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM or spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.TOY) then
                        local _, duration, _ = C_Item.GetItemCooldown(spellEntry.clickableId)
                        if duration == 0 and (not hideNotInInventory or itemInInventory) then
                            return true, spellEntry.spellId, spellEntry.clickableId, spellEntry.clickableType, false
                        end
                    else
                        if not hideNotInInventory or itemInInventory then
                            return true, spellEntry.spellId, spellEntry.clickableId, spellEntry.clickableType, false
                        end
                    end
                else
                    --check if we need to send this as a notification
                    if not haveBuffThatNeedsNotification and MCB.doesCustomBuffDurationNeedNotifyingSec(aura.expirationTime) then
                        if MyAddon.db.profile.hideCustomIfItemOnCD and spellEntry.clickableType and (spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM or spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.TOY) then
                            local _, duration, _ = C_Item.GetItemCooldown(spellEntry.clickableId)
                            if duration == 0 and (not hideNotInInventory or itemInInventory) then
                                haveBuffThatNeedsNotification = true
                                notificationSpellEntry = spellEntry
                            end
                        else
                            if not hideNotInInventory or itemInInventory then
                                haveBuffThatNeedsNotification = true
                                notificationSpellEntry = spellEntry
                            end
                        end
                    end
                end
            end
            if haveBuffThatNeedsNotification and notificationSpellEntry then
                return false, notificationSpellEntry.spellId, notificationSpellEntry.clickableId, notificationSpellEntry.clickableType, true
            else
                if hasSecretValueIssues then
                    return false, nil, nil, nil, false
                end
                return false, nil, nil, nil, false
            end         
        end
    end
end

function MCB.needsOilBuff()
    local hasMainHandEnchant, mainHandExpiration, _, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, _, offHandEnchantID = GetWeaponEnchantInfo()
    --if the values are secret, we're just going to assume the player has the enchants
    if issecretvalue and (issecretvalue(hasMainHandEnchant) or issecretvalue(mainHandEnchantID)) then
        return false, false
    end
    if not hasMainHandEnchant then
        return true, false
    end
    if not hasOffHandEnchant then
        --now we need to make sure the player even has a valid off hand to enchant
        local itemID = GetInventoryItemID("player", 17)
        if itemID then
            local itemClassId = select(6, C_Item.GetItemInfoInstant(itemID))
            if itemClassId == Enum.ItemClass.Weapon then
                return true, false
            end
        end
    end
    if (hasMainHandEnchant and not MCB.OIL_MAIN_HAND_IGNORE_LIST[mainHandEnchantID] and MCB.doesConsumableDurationNeedNotifyingMs(mainHandExpiration)) or
        (hasOffHandEnchant and not MCB.OIl_OFF_HAND_IGNORE_LIST[offHandEnchantID] and MCB.doesConsumableDurationNeedNotifyingMs(offHandExpiration)) then
           return false, true
    end

    return false, false
end

function MCB.needsFoodBuff(auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE then
        return false, false
    end
    if not MCB.MISC_DATA.isEarthen and not InCombatLockdown() and UnitExists("player") and not UnitIsDeadOrGhost("player") then
        local needsFoodBuff = true
        local needsNotifying = false
        local hasSecretValueIssues = true
        local auraInfoList = MCB.getUnitAurasArrayFromCache("player", auraInfoCache)
        if auraInfoCache.hasSecretValueIssues then
            hasSecretValueIssues = auraInfoCache.hasSecretValueIssues["player"]
        end

        for _, auraInfo in ipairs(auraInfoList) do
            -- Check if this aura is the consumable we are looking for
            if auraInfo.name == MCB.WELL_FED_NAME or auraInfo.name == MCB.HEARTY_WELL_FED_NAME then
                if MCB.doesConsumableDurationNeedNotifyingSec(auraInfo.expirationTime) then
                    needsNotifying = true
                end
                needsFoodBuff = false
                break
            end
        end
        if hasSecretValueIssues then
            return false, false
        end
        return needsFoodBuff, needsNotifying
    end
    return false, false
end

function MCB.needsConsumableBuff(consumableList, auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE then
        return false, false
    end
    local consumablesToCheck = consumableList
    if not InCombatLockdown() and UnitExists("player") and not UnitIsDeadOrGhost("player") then
        local needsConsumable = true
        local needsNotifying = false
        local auraInfoList = MCB.getUnitAurasArrayFromCache("player", auraInfoCache)
        local hasSecretValueIssues = true
        if auraInfoCache.hasSecretValueIssues then
            hasSecretValueIssues = auraInfoCache.hasSecretValueIssues["player"]
        end

        for _, auraInfo in ipairs(auraInfoList) do
            if auraInfo and auraInfo.spellId and consumablesToCheck[auraInfo.spellId] then
                if MCB.doesConsumableDurationNeedNotifyingSec(auraInfo.expirationTime) then
                    needsNotifying = true
                end
                needsConsumable = false
                break
            end
        end
        if hasSecretValueIssues then
            return false, false
        end
        return needsConsumable, needsNotifying
    end
    return false, false
end

function MCB.handleMissingPetChecking()
    local hasMissingBuff = false;
    local buffToDisplay = nil
    local petInfo = MCB.NeedPetMissingNotification()
    if petInfo then
        MCB.ShowMissingMessage(petInfo)
        buffToDisplay = petInfo
        hasMissingBuff = true
    end
    return hasMissingBuff, buffToDisplay
end

function MCB.handleShowHideFrame(hasMissingBuff, buff)
    if LEM:IsInEditMode() then return end
    local function combatCheck(buff)
        if not buff.showInCombat and InCombatLockdown() then
            return false
        else
            return true
        end
    end

    if hasMissingBuff and buff and combatCheck(buff) then
        MCB.MISSING_FRAME:Show()
        MCB.BUFF_IN_FRAME = buff
        local showButtonSetting = MyAddon.db.profile.makeIconClickable
        if not InCombatLockdown() then
            if showButtonSetting and not buff.disableClicking then
                MCB.SECURE_BUTTON:Show()
            else
                MCB.SECURE_BUTTON:Hide()
            end
        end
    else
        MCB.hideFrame()
    end
end

function MCB.hideFrame()
    MCB.BUFF_IN_FRAME = MCB.EMPTY_TABLE
    if MCB.MISSING_FRAME:IsShown() then
        MCB.MISSING_FRAME:Hide()
    end
    if not InCombatLockdown() and MCB.SECURE_BUTTON:IsShown() then
        MCB.SECURE_BUTTON:Hide()
    end
end

--this sets the icon to the spellId and adds the text directly below it
function MCB.ShowMissingMessage(buff, text)
    text = text or buff.text
    if buff.useClickableItemForIcon then
        local itemIcon = C_Item.GetItemIconByID(buff.clickableId)
        MCB.MISSING_FRAME.icon:SetTexture(itemIcon)
    else
        MCB.MISSING_FRAME.icon:SetTexture(MCB.GetSpellTexture(buff.spellId))
    end
    MCB.MISSING_FRAME.text:SetText(text)
    local activeLayout = LEM:GetActiveLayoutName()
    local left, right, top, bottom = 0, 1, 0, 1
    if activeLayout then
        left = MissingClassBuffDB["layouts"][activeLayout].zoomLeft or left
        right = MissingClassBuffDB["layouts"][activeLayout].zoomRight or right
        top = MissingClassBuffDB["layouts"][activeLayout].zoomTop or top
        bottom = MissingClassBuffDB["layouts"][activeLayout].zoomBottom or bottom
    end
    MCB.MISSING_FRAME.icon:SetTexCoord(left, right, top, bottom)
    MCB.setClickableButton(buff)
end

function MCB.setClickableButton(buff)
    local showButtonSetting = MyAddon.db.profile.makeIconClickable
    local spellId = buff.spellId
    if buff.clickableNeedsName then
        local spellInfo = C_Spell.GetSpellInfo(buff.clickableNeedsName)
        spellId = spellInfo.name
    elseif buff.clickableId then
        spellId = buff.clickableId
    elseif buff.spellbookId then
        spellId = buff.spellbookId
    end
    if not InCombatLockdown() then
        if showButtonSetting and not buff.disableClicking then
            local spellType = buff.clickableType or "spell"
            MCB.SECURE_BUTTON:SetAttribute("type", spellType)
            if spellType == MCB.CLICK_TO_CAST_SPELL_TYPES.TOY then
                MCB.SECURE_BUTTON:SetAttribute("toy", spellId)
            elseif spellType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM then
                MCB.SECURE_BUTTON:SetAttribute("item", "item:" .. spellId)
            else
                MCB.SECURE_BUTTON:SetAttribute("spell", spellId)
            end
            if buff.clickingUsesTarget then
                local spellName = C_Spell.GetSpellName(buff.spellId)
                MCB.SECURE_BUTTON:SetAttribute("type", "macro")
                MCB.SECURE_BUTTON:SetAttribute("macrotext", string.format("/cast [@target,help,nodead,exists][@player] %s", spellName))
            else
                MCB.SECURE_BUTTON:SetAttribute("unit", "player")
            end
        end
    end
end

function MCB.CheckForMissingBuff(auraInfoCache)
    local hasMissingBuff = false
    local buffToDisplay = nil
    local lowDurationBuff = nil
    local displayingLowDurationBuff = false
    for _, buff in ipairs(MCB.BUFFS) do
        if (not buff.ignoreAsBuff and buff.learned and not MCB.GetSettingsValue("ignoredSettingsIds")[buff.settingsId]) and
            (not InCombatLockdown() or buff.showInCombat) then
            local needsBuff, needsNotifying = MCB.AnyoneMissingBuff(buff, auraInfoCache)
            if needsBuff then
                MCB.ShowMissingMessage(buff)
                buffToDisplay = buff
                hasMissingBuff = true
                break
            elseif needsNotifying then
                --want to display the FIRST low duration buff
                lowDurationBuff = lowDurationBuff or buff
            end
        end
    end
    if not hasMissingBuff and lowDurationBuff then
        MCB.ShowMissingMessage(lowDurationBuff, MCB.REAPPLY_TEXT)
        hasMissingBuff = true
        buffToDisplay = lowDurationBuff
        displayingLowDurationBuff = true
    end
    return hasMissingBuff, buffToDisplay, displayingLowDurationBuff
end

function MCB.CheckAllLearned()
    MCB.HAS_SPELL_OVERLAY_COMPATIBLE_BUFF = false
    if MCB.NEEDS_BUFFS_CHECKED then
        MCB.CheckIfLearned(MCB.BUFFS)
    end

    if MCB.CLASS_STATE.isWarrior then
        MCB.CheckIfLearned(MCB.WARRIOR_STANCES)
    elseif MCB.CLASS_STATE.isPaladin then
        MCB.CheckIfLearned(MCB.PALADIN_AURAS)
    elseif MCB.CLASS_STATE.isEvoker then
        MCB.CheckIfLearned(MCB.EVOKER_ATTUNEMENTS)
    elseif MCB.CLASS_STATE.isWarlock then
        MCB.CheckIfLearned(MCB.WARLOCK_ALL_PETS)
        MCB.CheckIfLearned({MCB.WARLOCK_PET})
    elseif MCB.CLASS_STATE.isHunter then
        MCB.CheckIfLearned(MCB.HUNTER_ALL_PETS)
        MCB.CheckIfLearned({MCB.HUNTER_PET_MISSING})
        MCB.CheckIfLearned({MCB.HUNTER_PET_DEAD})
    elseif MCB.CLASS_STATE.isUnholyDk then
        MCB.CheckIfLearned({MCB.UNHOLY_GHOUL_MISSING})
    elseif MCB.CLASS_STATE.isFrostMageWithPet then
        MCB.CheckIfLearned({MCB.FROST_ELEMENTAL_MISSING})
    end
end

function MCB.CheckIfLearned(BUFFS)
    local hasLearnedBuffs = false
    local hasSpellOverlayCompatible = false
    for _, buff in ipairs(BUFFS) do
        local spellToCheck = buff.spellbookId or buff.spellId
        local known = C_SpellBook.IsSpellKnown(spellToCheck)
        local hasExcludeIfKnown = false
        if buff.excludeIfKnown and #buff.excludeIfKnown > 0 then
            for _, excludeSpellId in ipairs(buff.excludeIfKnown) do
                local excludeKnown = C_SpellBook.IsSpellKnown(excludeSpellId)
                if excludeKnown then
                    hasExcludeIfKnown = true
                    break
                end
            end
        end
        if not hasExcludeIfKnown then
            buff.learned = known
            if known then
                hasLearnedBuffs = true
                if buff.spellOverlayCompatible then
                    hasSpellOverlayCompatible = true
                end
            end
        else
            buff.learned = false
        end
    end
    MCB.HAS_SPELL_OVERLAY_COMPATIBLE_BUFF = MCB.HAS_SPELL_OVERLAY_COMPATIBLE_BUFF or hasSpellOverlayCompatible
    return hasLearnedBuffs
end

--this will check units in the group and raid to see if they're missing a specific spellId
--first checks player, then tries to see if it's a raid, then tries group
-- returns whether anyone was missing buff, second parameter is if the buff was low duration on the player
function MCB.AnyoneMissingBuff(buffWeNeed, auraInfoCache)
    MCB.ANYONE_MISSING_BUFF_CHECK_UNIT_SPELL_OVERLAY_CHECKED = false
    --immediately skip checking anyone if there's secret issues unless the buff is a weapon enchant which can be tracked out of combat in secret environments
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE and not buffWeNeed.weaponEnchantSlot and not buffWeNeed.spellOverlayCompatible then
        return false, false
    end

    local groupSize = GetNumGroupMembers()

    --if the buff requires a healer in the group and player is not in a group, we're not going to check
    if not (groupSize > 0) and buffWeNeed.requiresHealerInGroup then
        return false, false
    end

    --basically custom code for Timelessness
    if buffWeNeed.onlyOnePerGroup then
        return MCB.handleOnlyOnePerGroupBuff(buffWeNeed, auraInfoCache)
    end
    
    local needsBuff, needsNotifying = MCB.CheckUnit("player", buffWeNeed, auraInfoCache)
    if needsBuff then
        return true, needsNotifying
    end

    local ignoreAllies = MCB.ignoreAlliesBasedOnSettings()
    if not ignoreAllies then
        if groupSize > 0 then
            --basically custom code for Source of Magic
            if buffWeNeed.requiresHealerInGroup then
                return MCB.checkIfHealerInGroupInZoneWithoutBuff(buffWeNeed, auraInfoCache)
            end

            if IsInRaid() then
                for i = 1, groupSize do
                    --we already did this check, but it must have come back false but if we DID check it was a fallback because normal buff checking does not work
                    if buffWeNeed.spellOverlayCompatible and MCB.ANYONE_MISSING_BUFF_CHECK_UNIT_SPELL_OVERLAY_CHECKED then
                        return false, false
                    end
                    local unit = MCB.UNIT_STRINGS.raid[i]
                    if MCB.CheckUnit(unit, buffWeNeed, auraInfoCache) then
                        return true, needsNotifying
                    end
                end
            else
                for i = 1, groupSize - 1 do
                    --we already did this check, but it must have come back false but if we DID check it was a fallback because normal buff checking does not work
                    if buffWeNeed.spellOverlayCompatible and MCB.ANYONE_MISSING_BUFF_CHECK_UNIT_SPELL_OVERLAY_CHECKED then
                        return false, false
                    end
                    local unit = MCB.UNIT_STRINGS.party[i]
                    if MCB.CheckUnit(unit, buffWeNeed, auraInfoCache) then
                        return true, needsNotifying
                    end
                end
            end
        end
    end
    return false, needsNotifying
end

function MCB.handleOnlyOnePerGroupBuff(buffWeNeed, auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE and not buffWeNeed.spellOverlayCompatible then
        return false, false
    end
    local needsNotifying = false
    local secretValueIssuesOccurred = false

    --if we are in combat, we won't be able to do an aura check, so immediately return false
    if InCombatLockdown() and not buffWeNeed.spellOverlayCompatible then
        return false, false
    end

    --don't do any further checking if we already know there's secret issues
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and auraInfoCache.hasSecretValueIssues and auraInfoCache.hasSecretValueIssues["player"] and not buffWeNeed.spellOverlayCompatible  then
        return false, false
    end

    -- we are ignoring this buff, so we don't want to show a message
    if MCB.GetSettingsValue("ignoredSettingsIds")[buffWeNeed.settingsId] then
        return false, false
    end
    --if there is a specId field, we want to make sure we're on the right spec to check this buff
    if(buffWeNeed.specIds and #buffWeNeed.specIds > 0) and not MCB.contains(buffWeNeed.specIds, MCB.CURRENT_SPEC_ID) then
        return false, false
    end

    local ignoreRange = MCB.ignoreRangeCheckBasedOnSettings() or buffWeNeed.ignoreRangeCheck
    local ignoreAllies = MCB.ignoreAlliesBasedOnSettings() or buffWeNeed.ignoreAllies

    local numMembers = GetNumGroupMembers()
    wipe(MCB.UNITS_TABLE)
    local units = MCB.UNITS_TABLE
    local foundValidTarget = false
    local canHaveCompanion = false
    if not buffWeNeed.ignoreSelf then
        table.insert(units, "player")
    else
        -- if we are ignoring self and there are no group members or we're ignoring allies -- then we don't need to message
        if not (numMembers > 0) or (ignoreAllies and not buffWeNeed.overrideIgnoreAllies) then
            return false, false
        end
    end

    --normally we would check for ignore allies, but we're checking that the buff exists in the group so we don't want to miss if it's on someone
    --I changed this because of Earth shield, but I gave overrideIgnoreAllies to Source of Magic and Symbiotic Relationship
    if not (ignoreAllies and not buffWeNeed.overrideIgnoreAllies) then
        if IsInRaid() then
            for i = 1, numMembers do table.insert(units, MCB.UNIT_STRINGS.raid[i]) end
        elseif numMembers > 0 then
            for i = 1, numMembers - 1 do table.insert(units, MCB.UNIT_STRINGS.party[i]) end
        end
    end
    -- this is to deal with Brann and Valeera being valid party members
    if MCB.instanceType then
        if MCB.instanceType == "scenario" then
            canHaveCompanion = true
        end
    else
        MCB.setInstanceInformation()
    end

    --now that all other validity checking is done, we want to do a spell overlay check if it's what we should be doing:
    if buffWeNeed.spellOverlayCompatible and ((MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE) or InCombatLockdown()) then
        return MCB.checkSpellOverlay(buffWeNeed)
    end

    for _, unit in ipairs(units) do
        if MCB.isUnitAValidTarget(unit, buffWeNeed, canHaveCompanion) then
            local hasSomeoneElsesBuff = false
            local hasMutuallyExclusiveBuff = false
            local foundBuff = false
            local auraInfoArray = MCB.getUnitAurasArrayFromCache(unit, auraInfoCache)
            local hasSecretValueIssues = true
            if auraInfoCache.hasSecretValueIssues then
                hasSecretValueIssues = auraInfoCache.hasSecretValueIssues[unit]
            end
            if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and hasSecretValueIssues then
                if buffWeNeed.spellOverlayCompatible then
                    return MCB.checkSpellOverlay(buffWeNeed)
                else
                    return false, false
                end
            end
            secretValueIssuesOccurred = secretValueIssuesOccurred or hasSecretValueIssues
            if auraInfoArray then
                for _, auraInfo in ipairs(auraInfoArray) do
                    if auraInfo.spellId == buffWeNeed.spellId or (buffWeNeed.extraBuffSpellIds and MCB.contains(buffWeNeed.extraBuffSpellIds, auraInfo.spellId)) then
                        --found the buff on someone, but it needs to be ours
                        if auraInfo.sourceUnit and UnitIsUnit(auraInfo.sourceUnit, "player") then
                            --also check if duration is low for notification
                            if not buffWeNeed.ignoreDuration and MCB.doesDurationNeedNotifyingSec(auraInfo.expirationTime) then
                                needsNotifying = true
                            end
                            foundBuff = true
                        else
                            if not buffWeNeed.playerCanHaveMultiples then
                                hasSomeoneElsesBuff = true
                            end
                        end
                    else
                        --check if aura is a mutually exclusive one we own
                        if MCB.auraSpellInExtraSpellIds(auraInfo.spellId, buffWeNeed.mutuallyExclusiveWith) and auraInfo.sourceUnit
                            and UnitIsUnit(auraInfo.sourceUnit, "player") then
                            hasMutuallyExclusiveBuff = true
                        end
                    end
                end
            end
            if foundBuff then
                return false, needsNotifying
            end
            local isThisPlayerAValidTarget = not hasSomeoneElsesBuff and not hasMutuallyExclusiveBuff and (ignoreRange or MCB.passesRangeCheck(unit, buffWeNeed))
            foundValidTarget = foundValidTarget or isThisPlayerAValidTarget
        end
    end
    if secretValueIssuesOccurred then
        if buffWeNeed.spellOverlayCompatible then
            return MCB.checkSpellOverlay(buffWeNeed)
        else
            return false, false
        end
    end
    return foundValidTarget, false
end

--only works with spells that have a spell overlay glow when missing
function MCB.checkSpellOverlay(buff)
    MCB.ANYONE_MISSING_BUFF_CHECK_UNIT_SPELL_OVERLAY_CHECKED = true
    if MCB.doSpellOverlayChecks() and C_SpellActivationOverlay.IsSpellOverlayed(buff.spellId) then
        if buff.spellOverlayNeedsParty and GetNumGroupMembers() < 2 then
            return false, false
        end
        if not InCombatLockdown() or MCB.checkSpellOverlayInCombat(buff) then
            return true, false
        end
    end
    return false, false
end

--returns true if missing buff, returns false if buff is there or we don't want to show message
function MCB.CheckUnit(unit, buffWeNeed, auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE and not buffWeNeed.weaponEnchantSlot and not buffWeNeed.spellOverlayCompatible then
        return false, false
    end
    local needsNotifying = false
     

    --if we are ignoring self, then obviously don't check self
    if unit == "player" and buffWeNeed.ignoreSelf then
        return false, false
    end

    --if we are in combat, we won't be able to do an aura check, so immediately return false
    if InCombatLockdown() and not buffWeNeed.spellOverlayCompatible then
        return false, false
    end


    -- we are ignoring this buff, so we don't want to show a message
    if MCB.GetSettingsValue("ignoredSettingsIds")[buffWeNeed.settingsId] then
        return false, false
    end

    --if there is a specId field, we want to make sure we're on the right spec to check this buff
    if(buffWeNeed.specIds and #buffWeNeed.specIds > 0) and not MCB.contains(buffWeNeed.specIds, MCB.CURRENT_SPEC_ID) then
        return false, false
    end

    --now that all other validity checking is done, we want to do a spell overlay check if it's what we should be doing:
    if buffWeNeed.spellOverlayCompatible and ((MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE) or InCombatLockdown()) then
        return MCB.checkSpellOverlay(buffWeNeed)
    end

    if MCB.isUnitAValidTarget(unit, buffWeNeed) then
        if MCB.passesRangeCheck(unit, buffWeNeed) then
            local hasBuff = false
            if buffWeNeed.weaponEnchantSlot then
                --weapon enchants need to be checked differently
                local enchantNeedsNotifying
                hasBuff, enchantNeedsNotifying = MCB.HasWeaponEnchant(buffWeNeed)
                needsNotifying = enchantNeedsNotifying or needsNotifying
            else
                local auraInfoList = MCB.getUnitAurasFromCache(unit, auraInfoCache)
                local hasSecretValueIssues = true
                if auraInfoCache.hasSecretValueIssues then
                    hasSecretValueIssues = auraInfoCache.hasSecretValueIssues[unit]
                end
                if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and hasSecretValueIssues then
                    if buffWeNeed.spellOverlayCompatible then
                        return MCB.checkSpellOverlay(buffWeNeed)
                    else
                        return false, false
                    end
                end
                if auraInfoList then
                    local auraInfo = auraInfoList[buffWeNeed.spellId]
                    if not auraInfo then
                        auraInfo = MCB.auraCacheHasAnExtraSpellId(auraInfoList, buffWeNeed.extraBuffSpellIds)
                    end
                    if auraInfo then
                        hasBuff = true
                        if unit == "player" and not buffWeNeed.ignoreDuration and MCB.doesDurationNeedNotifyingSec(auraInfo.expirationTime) then
                            needsNotifying = true
                        end
                    end
                end
                if not (hasBuff or needsNotifying) and hasSecretValueIssues then
                    if buffWeNeed.spellOverlayCompatible then
                        return MCB.checkSpellOverlay(buffWeNeed)
                    else
                        return false, false
                    end
                end
            end

            if not hasBuff then
                return true, false
            end
        end
    end
    return false, needsNotifying
end

function MCB.passesRangeCheck(unit, buffWeNeed)
    if unit == "player" then
        return true
    else
        local inSameZone, mapApiWorked = MCB.IsInSameZone(unit)
        if not inSameZone and mapApiWorked then
            return false
        elseif buffWeNeed.ignoreRangeCheck then
            return true
        elseif MCB.ignoreRangeCheckBasedOnSettings() then
            return true
        else
            local spellIdToCheck = buffWeNeed.spellbookId or buffWeNeed.spellId
            local inRange = C_Spell.IsSpellInRange(spellIdToCheck, unit)
            return inRange
        end
    end
end   

function MCB.isUnitAValidTarget(unit, buffWeNeed, canHaveCompanion)
    return UnitExists(unit) and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) and (UnitIsPlayer(unit) or canHaveCompanion) and (unit == "player" or not buffWeNeed.onlySelf) and UnitCanAssist("player", unit)
end

function MCB.auraSpellInExtraSpellIds(spellId, extraSpellIds)
    local extraSpells = extraSpellIds or {}
    return MCB.contains(extraSpells, spellId)
end

function MCB.auraCacheHasAnExtraSpellId(auraInfoList, extraSpellIds)
    local extraSpells = extraSpellIds or {}
    for _, extraSpellId in ipairs(extraSpells) do
       if auraInfoList[extraSpellId] then
            return auraInfoList[extraSpellId]
       end
    end
    return false
end

function MCB.HasWeaponEnchant(enchant)
    local hasMainHandEnchant, mainHandExpiration, _, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, _, offHandEnchantID, hasRangedEnchant, rangedExpiration, _, rangedEnchantID = GetWeaponEnchantInfo()
    --if the values are secret, we're just going to assume the player has the enchants
    if issecretvalue and (issecretvalue(hasMainHandEnchant) or issecretvalue(mainHandEnchantID)) then
        return true
    end
    if (hasMainHandEnchant and enchant.weaponEnchantSlot == "main") then
        return true, MCB.doesDurationNeedNotifyingMs(mainHandExpiration)
    elseif (hasOffHandEnchant and enchant.weaponEnchantSlot == "off") then
        return true, MCB.doesDurationNeedNotifyingMs(offHandExpiration)
    elseif (hasRangedEnchant and enchant.weaponEnchantSlot == "ranged") then
        return true, MCB.doesDurationNeedNotifyingMs(rangedExpiration)
    else
        return false, false
    end
end

function MCB.doesDurationNeedNotifyingMs(durationLeftInMs)
    local durationMinutes = durationLeftInMs / 1000 / 60
    if MyAddon.db.profile.notifyWhenDurationLow and durationMinutes <= MyAddon.db.profile.durationLeft then
        return true
    end
    return false
end

function MCB.doesConsumableDurationNeedNotifyingMs(durationLeftInMs)
    if not durationLeftInMs or durationLeftInMs <= 0 then
        return false
    end
    local durationMinutes = durationLeftInMs / 1000 / 60
    if MyAddon.db.profile.notifyForConsumables and durationMinutes <= MyAddon.db.profile.durationForConsumables then
        return true
    end
    return false
end

function MCB.doesDurationNeedNotifyingSec(expirationTimeInSeconds)
    if not expirationTimeInSeconds or expirationTimeInSeconds <= 0 then
        return false 
    end
    local timeLeft = expirationTimeInSeconds - GetTime()
    local durationMinutes = timeLeft / 60
    if MyAddon.db.profile.notifyWhenDurationLow and durationMinutes <= MyAddon.db.profile.durationLeft then
        return true
    end
    return false
end

function MCB.doesConsumableDurationNeedNotifyingSec(expirationTimeInSeconds)
    if not expirationTimeInSeconds or expirationTimeInSeconds <= 0 then
        return false 
    end
    local timeLeft = expirationTimeInSeconds - GetTime()
    local durationMinutes = timeLeft / 60
    if MyAddon.db.profile.notifyForConsumables and durationMinutes <= MyAddon.db.profile.durationForConsumables then
        return true
    end
    return false
end

function MCB.doesCustomBuffDurationNeedNotifyingSec(expirationTimeInSeconds)
    if not expirationTimeInSeconds or expirationTimeInSeconds <= 0 then
        return false 
    end
    local timeLeft = expirationTimeInSeconds - GetTime()
    local durationMinutes = timeLeft / 60
    if MyAddon.db.profile.notifyForCustom and durationMinutes <= MyAddon.db.profile.durationForCustom then
        return true
    end
    return false
end

function MCB.GetSpellTexture(spellId)
    local iconTexture = C_Spell.GetSpellTexture(spellId)
    return iconTexture
end

--may the gods help us all, this needs a rework, it does work though...
--the locals have gotten a little out of hand...
function MCB.HandleRoguePoisons(auraInfoCache)
    local isDragonTempered = MCB.CLASS_STATE.isDragonTemperedRogue
    local hasMissingBuff = false
    local hasLethal = false
    local hasNonLethal = false
    local hasDragonTemperedLethal = false
    local hasDragonTemperedNonLethal = false
    local defaultLethal = nil
    local defaultNonLethal = nil
    local dragonTemperedLethal = nil
    local dragonTemperedNonLethal = nil
    local hasDefaultLethalOverride = false
    local hasDefaultNonLethalOverride = false
    local buff = nil;
    local hasLearnedLethal = false
    local hasLearnedNonLethal = false
    local lethalLowDuration = false
    local nonLethalLowDuration = false
    local currentLethal = nil
    local currentNonLethal = nil
    local showingLowDurationBuff = false
    for _, buff in ipairs(MCB.BUFFS) do
        local needsBuff, needsNotifying = MCB.CheckUnit("player", buff, auraInfoCache)
        if not needsBuff then
            if buff.poisonType == "nonlethal" then
                -- we already had a nonlethal, that means this is a dragon tempered buff
                if hasNonLethal then
                    hasDragonTemperedNonLethal = true
                    nonLethalLowDuration = nonLethalLowDuration or needsNotifying or false
                    if not currentNonLethal or needsNotifying then
                        currentNonLethal = buff
                    end
                else
                    hasNonLethal = true
                    nonLethalLowDuration = needsNotifying or false
                    if not currentNonLethal or needsNotifying then
                        currentNonLethal = buff
                    end
                end
            else
                -- we already had a lethal, that means this is a dragon tempered buff
                if hasLethal then
                    hasDragonTemperedLethal = true
                    lethalLowDuration = lethalLowDuration or needsNotifying or false
                    if not currentLethal or needsNotifying then
                        currentLethal = buff
                    end
                else
                    hasLethal = true
                    lethalLowDuration = needsNotifying or false
                    if not currentLethal or needsNotifying then
                        currentLethal = buff
                    end
                end
               
            end
        end

        --THE ORDER OF THE ROGUE BUFFS MATTERS BECAUSE OF THIS -> we put the defaults LAST(ish) so that defaultLethal and defaultNonLethal are ONLY populated at the last 
        --look of these buffs by the default tag, otherwise the dragon tempered code will not pick up the right poison to use as dragon tempered
        if buff.poisonType == "nonlethal" and buff.default and not hasDefaultNonLethalOverride then
            defaultNonLethal = buff
        elseif buff.poisonType == "lethal" and buff.default and not hasDefaultLethalOverride then
            defaultLethal = buff
        end

        --these override values can be "true" if user did not select a spell and only selected the checkbox to override
        --still works as expected because "true" will not match any spellIds
        if buff.poisonType == "nonlethal" and MyAddon.db.profile.overrideDefaultNonLethalPoison and MyAddon.db.profile.overrideNonLethalWithTalent then
            if (buff.spellId == 381637 or buff.spellId == 5761) and buff.learned then
                defaultNonLethal = buff
                hasDefaultNonLethalOverride = true
            end
        elseif buff.poisonType == "nonlethal" and MyAddon.db.profile.overrideDefaultNonLethalPoison and MyAddon.db.profile.overrideDefaultNonLethalPoison == buff.spellId and buff.learned then
            defaultNonLethal = buff
            hasDefaultNonLethalOverride = true
        elseif buff.poisonType == "lethal" and MyAddon.db.profile.overrideDefaultLethalPoison and MyAddon.db.profile.overrideDefaultLethalPoison == buff.spellId and buff.learned then
            defaultLethal = buff
            hasDefaultLethalOverride = true
        end

        if buff.poisonType == "nonlethal" and buff.learned then
            hasLearnedNonLethal = true
            --look for a valid dragon tempered buff, aka a learned poison that isn't the default
            if not dragonTemperedNonLethal and (not defaultNonLethal or defaultNonLethal.spellId ~= buff.spellId) then
                -- if there isn't a default or the default doesn't match this buff, then this is a valid target for dragon tempered
                dragonTemperedNonLethal = buff
            end
        elseif buff.poisonType == "lethal" and buff.learned then
            hasLearnedLethal = true
            --look for a valid dragon tempered buff, aka a learned poison that isn't the default
            if not dragonTemperedLethal and (not defaultLethal or defaultLethal.spellId ~= buff.spellId) then
                -- if there isn't a default or the default doesn't match this buff, then this is a valid target for dragon tempered
                dragonTemperedLethal = buff
            end
        end
    end

    if isDragonTempered then
        --if the player is using dragon tempered, we need to fudge the variables to display the correct missing buffs
        if not hasDragonTemperedNonLethal and hasNonLethal then
            -- figure out between the default and the extra poison we pulled for dragon tempered what the user is missing
            if currentNonLethal and defaultNonLethal and currentNonLethal.spellId == defaultNonLethal.spellId then
                --if the current non lethal matches the default, we want to display the dragon tempered
                if dragonTemperedNonLethal then
                    defaultNonLethal = dragonTemperedNonLethal
                end
            end
            --need to set this to make sure the missing message gets shown
            hasNonLethal = false
        end

        if not hasDragonTemperedLethal and hasLethal then
            if currentLethal and defaultLethal and currentLethal.spellId == defaultLethal.spellId then
                if dragonTemperedLethal then
                    defaultLethal = dragonTemperedLethal
                end
            end
            hasLethal = false
        end
    end

    if hasLearnedNonLethal and not MyAddon.db.profile.ignoreNonLethalPoisons then
        if not hasNonLethal then
            MCB.ShowMissingMessage(defaultNonLethal)
            showingLowDurationBuff = false
            hasMissingBuff = true
            buff = defaultNonLethal
        elseif nonLethalLowDuration then
            MCB.ShowMissingMessage(currentNonLethal, MCB.REAPPLY_TEXT)
            showingLowDurationBuff = true
            buff = currentNonLethal
            hasMissingBuff = true
        end
    end
    if hasLearnedLethal and not MyAddon.db.profile.ignoreLethalPoisons then
        if not hasLethal then
            MCB.ShowMissingMessage(defaultLethal)
            showingLowDurationBuff = false
            hasMissingBuff = true
            buff = defaultLethal
        elseif lethalLowDuration and not hasMissingBuff then
            MCB.ShowMissingMessage(currentLethal, MCB.REAPPLY_TEXT)
            showingLowDurationBuff = true
            buff = currentLethal
            hasMissingBuff = true
        end
    end

    return hasMissingBuff, buff, showingLowDurationBuff
end

function MCB.ignoreAlliesBasedOnSettings()
    if MCB.instanceType then
        if MCB.getZoneSettings(MCB.instanceType).ignoreAlliesGlobally or 
            (MCB.getZoneSettings(MCB.instanceType).ignoreAllies and MCB.getZoneSettings(MCB.instanceType).ignoreAllies[MCB.CLASS_NAME]) then
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.ignoreRangeCheckBasedOnSettings()
    if MCB.instanceType then
        if  MCB.getZoneSettings(MCB.instanceType).ignoreRangeGlobally or
            (MCB.getZoneSettings(MCB.instanceType).ignoreRange and MCB.getZoneSettings(MCB.instanceType).ignoreRange[MCB.CLASS_NAME]) then
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.needFoodCheckInZone()
    if MCB.instanceType then
        if MCB.getZoneSettings(MCB.instanceType).trackFood then
            if MCB.instanceType == "party" or MCB.instanceType == "raid" then
                if MyAddon.db.profile.ignoreLegacyContentForFood and MCB.isLegacyContent() then
                    return false
                else
                    return MCB.checkDifficultySettingsAndCurrentZone("showFood")
                end
            end
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.needFlaskCheckInZone()
    if MCB.instanceType then
        if MCB.getZoneSettings(MCB.instanceType).trackFlask then
            if MCB.instanceType == "party" or MCB.instanceType == "raid" then
                if MyAddon.db.profile.ignoreLegacyContentForFlask and MCB.isLegacyContent() then
                    return false
                else
                    return MCB.checkDifficultySettingsAndCurrentZone("showFlask")
                end
            end
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.needOilCheckInZone()
    if MCB.instanceType then
        if MCB.getZoneSettings(MCB.instanceType).trackOil then
            if MCB.instanceType == "party" or MCB.instanceType == "raid" then
                if MyAddon.db.profile.ignoreLegacyContentForOil and MCB.isLegacyContent() then
                    return false
                else
                    return MCB.checkDifficultySettingsAndCurrentZone("showOil")
                end
            end
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.needCustomSpellIdsInZone()
    if MCB.instanceType then
        if MCB.getZoneSettings(MCB.instanceType).showCustomSpellIds then
            if MCB.instanceType == "party" or MCB.instanceType == "raid" then
                if MyAddon.db.profile.ignoreLegacyContentForCustom and MCB.isLegacyContent() then
                    return false
                else
                    return MCB.checkDifficultySettingsAndCurrentZone("showCustom")
                end
            end
            return true
        end
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.isMythicDungeon(ignoreMythicPlus)
    if MCB.instanceDifficultyId then
        return not MCB.isLegacyContent() and ((MCB.instanceDifficultyId  == 8 and not ignoreMythicPlus)  or MCB.instanceDifficultyId  == 23)
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.isNotLFRRaid()
    if MCB.instanceDifficultyId then
        return not MCB.isLegacyContent() and (MCB.instanceDifficultyId == 14 or MCB.instanceDifficultyId == 15 or MCB.instanceDifficultyId == 16)
    else
        MCB.setInstanceInformation()
    end
    return false
end

function MCB.checkDifficultySettingsAndCurrentZone(buffSettingName)
    if MCB.instanceDifficultyId and MCB.instanceDifficultyId then
        local diffKey
        local category = ""

        if MCB.instanceType == "raid" then
            category = "raid"
            diffKey = MCB.RAID_DIFFICULTIES[MCB.instanceDifficultyId]
        elseif MCB.instanceType == "party" then
            category = "party"
            diffKey = MCB.DUNGEON_DIFFICULTIES[MCB.instanceDifficultyId]
        else
            return false
        end

        if not diffKey then
            diffKey = "other"
        end

        local settings = MyAddon.db.profile.difficultySettings[category]

        if settings and settings[diffKey] then
            return settings[diffKey][buffSettingName] == true
        end
        return false
    else
        MCB.setInstanceInformation()
    end
    return false
end


function MyAddon:TalentsUpdated()
    MCB.CURRENT_SPEC_ID = GetSpecializationInfo(GetSpecialization())
    if MCB.CLASS_STATE.isHunter then
        MCB.setPlayerIsMarksmanWithPet()
    elseif MCB.CLASS_STATE.isDeathKnight then
        MCB.setPlayerIsUnholy()
    elseif MCB.CLASS_STATE.isRogue then
        MCB.setRogueWithDragonTempered()
    elseif MCB.CLASS_STATE.isMage then
        MCB.setPlayerIsFrostWithPet()
    elseif MCB.CLASS_STATE.isEvoker then
        MCB.setPlayerIsAugmentation()
    elseif MCB.CLASS_STATE.isWarlock then
        MCB.setWarlockWithSacrifice()
    elseif MCB.CLASS_STATE.isDruid then
        MCB.setPlayerIsBalanceWithForm()
    elseif MCB.CLASS_STATE.isPriest then
        MCB.setPlayerIsShadowWithForm()
    end
    MCB.CheckAllLearned()
    --delay check to let talents settle first
    C_Timer.After(.1, function()
        MCB.CheckForMissings()
    end)
end

function MyAddon:PetEventFired()
    if MCB.ShouldCheckForPet() then
        --giving the engine time to set the pet state data correctly
        C_Timer.After(.1, function()
            MCB.CheckForMissings()
        end)
        
    end
end

function MyAddon:CombatEntered()
    if not (MCB.BUFF_IN_FRAME and MCB.BUFF_IN_FRAME.showInCombat) then
        MCB.hideFrame()
    end
    -- InCombatLockdown() does not get set properly immediately after event is fired
    C_Timer.After(.1, function()
        if MCB.ShouldCheckForPet() or MCB.needsShapeshiftFormCheck() or MCB.doSpellOverlayChecks() then
            MCB.CheckForMissings()
        end
    end)
end

function MCB.getZoneSettings(instanceType)
    local settings = MyAddon.db.profile.zoneSettings[instanceType]
    if not settings then
        return MyAddon.db.profile.zoneSettings["none"]
    end
    return settings
end

-- first variable returns whether we can conclude the unit is in the same zone as the player
-- second variable returns whether the map checking worked
function MCB.IsInSameZone(unit)
    local playerMap = C_Map.GetBestMapForUnit("player")
    local unitMap = C_Map.GetBestMapForUnit(unit)
    local isInSameZone = playerMap and unitMap and playerMap == unitMap
    if playerMap == nil and unitMap == nil then
        if UnitIsVisible(unit) then
            return true, true
        end
    end
    return isInSameZone, (playerMap ~= nil or unitMap ~= nil)
end

function MCB.BuffsHaveAnEnchant()
    if MyAddon.db.profile.trackOil then return true end
    local buffs = MCB.BUFFS or {}
    for _, buff in ipairs(buffs) do
        if buff.weaponEnchantSlot then
            return true
        end
    end
    return false
end

function MCB.checkIfHealerInGroupInZoneWithoutBuff(cantHaveBuff, auraInfoCache)
    if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and MCB.FOUND_SECRET_VALUE_ISSUE then
        return false, false
    end
    if InCombatLockdown() then
        return false, false
    end

    local ignoreRange = MCB.ignoreRangeCheckBasedOnSettings() or cantHaveBuff.ignoreRangeCheck
    local ignoreAllies = MCB.ignoreAlliesBasedOnSettings() or cantHaveBuff.ignoreAllies
    if ignoreAllies then
        -- if we're ignoring allies, this buff won't work so just skip it
        return false, false
    end

    local healerExistsWithoutBuffInMyZone = false
    wipe(MCB.UNITS_TABLE)
    local units = MCB.UNITS_TABLE
    local numMembers = GetNumGroupMembers()
    if IsInRaid() then
        for i = 1, numMembers do table.insert(units, MCB.UNIT_STRINGS.raid[i]) end
    elseif numMembers > 0 then
        for i = 1, numMembers - 1 do table.insert(units, MCB.UNIT_STRINGS.party[i]) end
    end

    local secretValueIssuesOccurred = false
    for _, unit in ipairs(units) do
        --don't do any further checking if we already know there's secret issues
        if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and auraInfoCache.hasSecretValueIssues and auraInfoCache.hasSecretValueIssues[unit] then
            return false, false
        end
        --we're passing in false to canHaveCompanion since we don't want them to be valid targets even though
        --healer spec companions can actually be buffed
        if not UnitIsUnit(unit, "player") and MCB.isUnitAValidTarget(unit, cantHaveBuff, false)  then
            if UnitGroupRolesAssigned(unit) == "HEALER" then
                local hasOtherPlayersBuff = false
                local foundBuff = false
                local needsNotifying = false
                local auraInfoArray = MCB.getUnitAurasArrayFromCache(unit, auraInfoCache)
                local hasSecretValueIssues = true
                if auraInfoCache.hasSecretValueIssues then
                    hasSecretValueIssues = auraInfoCache.hasSecretValueIssues[unit]
                end
                secretValueIssuesOccurred = secretValueIssuesOccurred or hasSecretValueIssues
                if MCB.IGNORE_BUFF_CHECKING_IMMEDIATELY_ON_SECRET_ISSUES and hasSecretValueIssues then
                    return false, false
                end
                if auraInfoArray then
                    for _, auraInfo in ipairs(auraInfoArray) do
                        if auraInfo.spellId == cantHaveBuff.spellId or
                            (cantHaveBuff.extraBuffSpellIds and MCB.auraSpellInExtraSpellIds(auraInfo.spellId, cantHaveBuff.extraBuffSpellIds)) then
                            --found my buff on someone, we're good
                            if auraInfo.sourceUnit and UnitIsUnit(auraInfo.sourceUnit, "player") then
                                if not cantHaveBuff.ignoreDuration and MCB.doesDurationNeedNotifyingSec(auraInfo.expirationTime) then
                                    needsNotifying = true
                                end
                                foundBuff = true
                                break
                            else
                                -- this is someone else's buff
                                hasOtherPlayersBuff = true
                                break
                            end
                        end
                    end
                end
                if foundBuff then
                    return false, needsNotifying
                end

                -- we found a healer that doesn't have MY buff AND isn't buffed by others that's in range
                if not hasOtherPlayersBuff and (ignoreRange or MCB.passesRangeCheck(unit, cantHaveBuff)) then
                    healerExistsWithoutBuffInMyZone = true
                end
            end
        end
    end
    if secretValueIssuesOccurred then
        return false, false
    end
    return healerExistsWithoutBuffInMyZone, false
end

function MCB.overrideConsumableBuffWithClickToCast(originalBuff, clicktoCastItemId)
    if clicktoCastItemId then
        local newBuff = CopyTable(originalBuff)
        newBuff.clickableId = clicktoCastItemId
        newBuff.disableClicking = false
        newBuff.clickableType = "item"
        newBuff.useClickableItemForIcon = true
        return newBuff
    end
    return originalBuff
end