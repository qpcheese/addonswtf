
local function Bloodlust()
    local mode = Madhouse.addon:LoadGlobalData("settings-bloodlost-mode", "faction")

    local sound
    local text
    local color
    local image

    if mode == "horde" or (mode=="faction" and isHorde)  then
        sound = "Sounds\\For-the-hord.mp3"
        text  = isGerman and "Blutrausch!" or "Bloodlust!"
        color = "FF0000"
        image = 4
    elseif mode == "alliance" or (mode=="faction" and not isHorde) then
        sound = "Sounds\\ForTheA.mp3"
        text = isGerman and "Heldentum!" or "Heroism!"
        color = "0000FF"
        image = 5
    end

    PlaySoundFile(Madhouse.API.v1.AddonFolder(sound), "Master");
    local MadhouseBLText = UIParent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    MadhouseBLText:SetPoint("TOP","MHAlarmAnchor","TOP",20,-60)
    MadhouseBLText:SetText(Madhouse.API.v1.ColorPrintRGB(text,color))
    MadhouseBLText:SetTextScale(4)
    Madhouse.API.v1.ShowStopMotion(Madhouse.static.stopMotion[image],0,0.4,"TOP",-165,-30,function () MadhouseBLText:Hide() end)
end

local function LevelUp()
    PlaySoundFile(Madhouse.API.v1.AddonFolder("Sounds\\Nokotan.mp3"), "Master");
    local MadhouseUPText = UIParent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    MadhouseUPText:SetPoint("TOP","MHAlarmAnchor","TOP",15,-60)
    MadhouseUPText:SetText(Madhouse.API.v1.ColorPrintRGB("LEVEL UP!","FFFF00"))
    MadhouseUPText:SetTextScale(4)
    Madhouse.API.v1.ShowStopMotion(Madhouse.static.stopMotion[6],1,0.4,"TOP",-165,-30,function () MadhouseUPText:Hide() end)
end

local MadhouseGizmoText
local MadhouseGizmoImg

local function EncounterEnd()
    if not MadhouseGizmoImg then
        MadhouseGizmoText = UIParent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        MadhouseGizmoText:SetPoint("TOP","MHAlarmAnchor","TOP",15,-60)
        MadhouseGizmoText:SetText(Madhouse.API.v1.ColorPrintRGB(isGerman and "Gut Gemacht" or "Boss Defeated" ,"FFFFFF"))
        MadhouseGizmoText:SetTextScale(4)

        MadhouseGizmoImg = CreateFrame("Frame", nil, UIParent)
        MadhouseGizmoImg:SetSize(128, 128)
        MadhouseGizmoImg:SetPoint("LEFT", MadhouseGizmoText, "LEFT", -132, 0)

        MadhouseGizmoImg.texture = MadhouseGizmoImg:CreateTexture(nil,"BACKGROUND")
        MadhouseGizmoImg.texture:SetAllPoints(MadhouseGizmoImg)
        MadhouseGizmoImg.texture:SetTexture(Madhouse.API.v1.AddonFolder("Textures\\Gizmo.tga"))
    else
        MadhouseGizmoText:Show()
        MadhouseGizmoImg:Show()
    end

    -- Madhouse.API.v1.ShowStopMotion(Madhouse.static.stopMotion[6],1,0.4,"TOP",-165,-30,function () MadhouseUPText:Hide() end)
    C_Timer.After(3, function()
        MadhouseGizmoText:Hide()
        MadhouseGizmoImg:Hide()
    end)
end


local MadhouseInfoText
local hideNo = 0

local function PostMessage(message)
    hideNo = hideNo + 1
    local curNo = hideNo
    if not MadhouseInfoText then
        MadhouseInfoText = UIParent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        MadhouseInfoText:SetPoint("TOP", "MHMessageAnchor", "TOP", 15, -60)
        MadhouseInfoText:SetText(message)
        MadhouseInfoText:SetTextScale(2)
    else
        MadhouseInfoText:SetText(message)
        MadhouseInfoText:Show()
    end

    C_Timer.After(3, function()
        if hideNo == curNo then
            MadhouseInfoText:Hide()
        end
    end)
end



local function SearchMPKey()
    for bag = 0, NUM_BAG_SLOTS do
        local bagSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, bagSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemName and info.itemID == 180653 then
--[[             Madhouse.API.v1.Inspect(info.hyperlink)
                 Madhouse.API.v1.Inspect(string.match(info.hyperlink, "%[(.-)%]"))]]
                 Madhouse.addon:SaveUserMeta("mpKey",string.match(info.hyperlink, "%[(.-)%]"))
                 Madhouse.addon:SaveUserMeta("mpKey_timeout",C_DateAndTime.GetSecondsUntilWeeklyReset() + time())
            end
        end
    end
end

local function GetCurrentSpec()
    local currentSpec = GetSpecialization()
    local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec))
    Madhouse.addon:SaveUserMeta("specName",currentSpecName)
    Madhouse.addon:SaveUserMeta("specID",currentSpec)
end

local function ProfessionDetail(id)
    if not id then
        return nil
    end
    local name, _, skillLevel, maxSkillLevel, _, _, _, _, specializationIndex, _ =
        GetProfessionInfo(id)
    return {
        id = id,
        name = name,
        specializationIndex = specializationIndex,
        skillLevel = skillLevel,
        maxSkillLevel = maxSkillLevel,
    }
end

local function GetPlayerProffesion()
    local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    Madhouse.addon:SaveUserMeta("profession",{
       prof1 = ProfessionDetail(prof1) or nil,
       prof2 = ProfessionDetail(prof2) or nil,
       archaeology = ProfessionDetail(archaeology) or nil,
       fishing = ProfessionDetail(fishing) or nil,
       cooking = ProfessionDetail(cooking) or nil,
    })
end

local function GetWarbankGold()
    Madhouse.addon:SaveGlobalData("warbank-gold",C_Bank.FetchDepositedMoney(Enum.BankType.Account))
end

local function initUserMeta()
    local metaFrame = CreateFrame("Frame")

    metaFrame:RegisterEvent("TIME_PLAYED_MSG")
    metaFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
    metaFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    metaFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    metaFrame:RegisterEvent('PLAYER_MONEY')
    metaFrame:RegisterEvent('PLAYER_LOGOUT')
    metaFrame:RegisterEvent('PLAYER_TRADE_MONEY')
    metaFrame:RegisterEvent('BAG_UPDATE_DELAYED')
    metaFrame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')

    metaFrame:SetScript("OnEvent", function (self, event,...)
        -- MP Key
        if event == "PLAYER_SPECIALIZATION_CHANGED"  then
            GetCurrentSpec()
        end
        if event == "BAG_UPDATE_DELAYED"  then
            SearchMPKey()
        end
        -- Level UP
        if event == "PLAYER_LEVEL_CHANGED"  then
            local _, newLevel = ...
            Madhouse.addon:SaveUserMeta("level",newLevel)
        end
        -- Get Current Zone
        if event == "ZONE_CHANGED_NEW_AREA" then
            Madhouse.addon:SaveUserMeta("zone",GetRealZoneText())
        end
        -- Get Total Played time
        if event == "TIME_PLAYED_MSG" then
            local arg1 = ... -- in minutes
            Madhouse.addon:SaveUserMeta("playedTotal", arg1)
        end
        -- Get Guild Info
        if event == "TIME_PLAYED_MSG" or event == "PLAYER_LOGOUT" then
            local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
            Madhouse.addon:SaveUserMeta("guildName",guildName or "none")
            Madhouse.addon:SaveUserMeta("guildRankName",guildRankName or "none")
            Madhouse.addon:SaveUserMeta("guildRankIndex",guildRankIndex)
        end
        -- Get Money
        if event == "PLAYER_MONEY" or event == "PLAYER_TRADE_MONEY" then
            Madhouse.addon:SaveUserMeta("money",GetMoney())
        end

        -- Login or reload refresh
        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGOUT" then
            local isLogin, isReload = ...
            if isLogin or isReload then
                local update = {
                    ["version"]  = 1,
                    ["money"]    = GetMoney(),
                    ["level"]    = UnitLevel("player"),
                    ["resting"]  = IsResting(),
                    ["warMode"]  = C_PvP.IsWarModeDesired(),
                    ["zone"]     = GetRealZoneText(),
                    ["lastSeen"] = time(),
                    ["guid"]     = UnitGUID("player"),
                    ["faction"]  = UnitFactionGroup("player")
                }

                local _,equippedItemLevel = GetAverageItemLevel()
                update["il"] = equippedItemLevel

                local data = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
                update["mp"] = data["currentSeasonScore"]

                local className,_,classID = UnitClass("player")
                update["className"] = className
                update["classID"] = classID

                local raceName,_,raceID = UnitRace("player")
                update["raceName"] = raceName
                update["raceID"] = raceID

                local _, hasHeritageArmorUnlocked = UnitAlliedRaceInfo("player")
                update["heritageArmor"] = hasHeritageArmorUnlocked or false

                for key, value in pairs(update) do
                    Madhouse.addon:SaveUserMeta(key,value)
                end
                -- More calls
                SearchMPKey()
                GetCurrentSpec()
                GetPlayerProffesion()
                GetWarbankGold()
            else
                print("zoned between map instances")
            end
        end
    end)

    -- Rquest Played
    RequestTimePlayed()
end

local function INIT()
    local eventFrame = CreateFrame("Frame")
    if not Madhouse.API.v1.IsMidnight() then
        eventFrame:RegisterEvent("UNIT_AURA")
    end
    eventFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
    eventFrame:RegisterEvent("ENCOUNTER_END")
    eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "UNIT_AURA" then
            local target, data = ...
            if event == "UNIT_AURA" and data.addedAuras and target == "player" and Madhouse.addon:LoadGlobalData("bloodlost-alert", false) then
                for _, aura in ipairs(data.addedAuras) do
                    if Madhouse.API.v1.Contains({ 80353, 23951, 90355, 65983, 178207, 230935, 381301, 264667, 397744, 444257, 466904, 2825 }, aura.spellId) then
                        Bloodlust()
                    end
                end
            end
        elseif event == "PLAYER_LEVEL_CHANGED" and Madhouse.addon:LoadGlobalData("level-up-alert", false) then
            LevelUp()
        elseif event == "ENCOUNTER_END" then
            local _, _, _, _, success = ...
            if success == 1 and Madhouse.addon:LoadGlobalData("encounter-end-alert", false) then
                EncounterEnd()
            end
        end
    end)
end

Madhouse.trigger = {
    Bloodlust = Bloodlust,
    LevelUp = LevelUp,
    PostMessage = PostMessage,
    EncounterEnd = EncounterEnd,
    INIT = INIT,
    INIT_META = initUserMeta
}
