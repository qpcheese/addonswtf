local addonName, addonTable = ...
local addon                 = addonTable.Core

local createdFrames         = {}

local function updateIconState(itemFrame, charges)
    local cooldown = itemFrame.obj.cooldownInfo
    local name = itemFrame.obj.flag
    local viewer = addonTable.viewerFrameMap[name]

    if itemFrame.showWhenInactive then
        itemFrame.isActive = true
        itemFrame:Show()
    elseif cooldown.start == 0 then
        itemFrame.isActive = false
        itemFrame:Hide()
    else
        itemFrame.isActive = true
        itemFrame:Show()
    end

    itemFrame.Icon.Icon:SetDesaturated(itemFrame.desaturateWhenInactive and (cooldown.start == 0))

    if itemFrame.dynamicDisplay then
        addon:applyLayout(name)
        addon:updateViewerSize(name)
    end
end

local function setupItemFrame(storageData)
    local cooldown = storageData.cooldownInfo
    local charge = storageData.chargeInfo
    local showCharge = storageData.showCharge

    local applicationsFontString = storageData.frame:GetApplicationsFontString();
    local durationFontString = storageData.frame:GetDurationFontString();
    local pipTexture = storageData.frame:GetPipTexture();

    if cooldown.start ~= 0 then
        storageData.frame.Bar:SetMinMaxValues(0, cooldown.duration)
        storageData.frame.Bar:SetScript("OnUpdate", function()
            if cooldown.start == 0 or cooldown.duration == 0 then
                storageData.frame.Bar:SetValue(0)
                return
            end
            local timeLeft = (cooldown.start + cooldown.duration) - GetTime()
            if timeLeft > 0 then
                storageData.frame.Bar:SetValue(timeLeft) -- assuming min/max set to max duration
            else
                storageData.frame.Bar:SetValue(0)
                storageData.frame.Bar:SetScript("OnUpdate", nil) -- stop updating when aura ends
            end

            if storageData.frame.showCooldown then
                -- COOLDOWN_DURATION_TEN_SEC for one decimal place
                durationFontString:Show()
                local time = string.format(COOLDOWN_DURATION_TEN_SEC, timeLeft);
                durationFontString:SetText(time);
            else
                durationFontString:SetText("");
            end

            pipTexture:SetShown(true);

            -- Can handle the end state here if needed so no need to rely on an event
            if timeLeft <= 0 then
                --     update the frame to reflect that the cooldown has ended
                local cooldownInfo = {}
                cooldownInfo.start, cooldownInfo.duration, cooldownInfo.enable = C_Item.GetItemCooldown(storageData.itemId)
                storageData.cooldownInfo = cooldownInfo
                local chargeInfo = C_Item.GetItemCount(storageData.itemId, nil, true)
                storageData.chargeInfo = chargeInfo
                setupItemFrame(storageData)
                updateIconState(storageData.frame, storageData.chargeInfo)
            end
        end)
        if applicationsFontString then
            applicationsFontString:SetText(charge);
            applicationsFontString:SetShown(showCharge);
        end
    else
        storageData.frame.Bar:SetMinMaxValues(0, 0)
        storageData.frame.Bar:SetScript("OnUpdate", nil)
        storageData.frame.Bar:SetValue(0)

        durationFontString:SetText("");

        pipTexture:SetShown(false);

        if applicationsFontString then
            applicationsFontString:SetText(charge);
            applicationsFontString:SetShown(showCharge);
        end
    end
end

local function updateItemState(storageData, origin)
    local cooldownInfo = {}
    local oldCooldown = storageData.cooldownInfo
    local oldCharge = storageData.chargeInfo

    cooldownInfo.start, cooldownInfo.duration, cooldownInfo.enable = C_Item.GetItemCooldown(storageData.itemId)
    local chargeInfo = C_Item.GetItemCount(storageData.itemId, nil, true)

    if origin == "initial" or oldCooldown.start ~= cooldownInfo.start or oldCooldown.duration ~= cooldownInfo.duration or oldCharge ~= chargeInfo then
        storageData.cooldownInfo = cooldownInfo
        storageData.chargeInfo = chargeInfo
        setupItemFrame(storageData)
        updateIconState(storageData.frame, storageData.chargeInfo)
    end
end

local function OnEventItem(self, event, ...)
    if event == "BAG_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_USABLE" then
        local storageData = self.obj
        if storageData then
            updateItemState(storageData)
        end
    end
end

--- Create a custom bar frame to be injected into a Cooldown Viewer.
---
--- @param itemId string Item ID of the item frame to create.
--- @param info table Configuration info for the item frame.
--- @param poolFrame Frame Pool from which to acquire the item frame.
--- @param flag string Flag indicating the viewer type (e.g., "essential", "utility").
--- @return Frame Frame The created item frame.
function addon:CreateBarItemFrame(itemId, info, poolFrame, flag)
    local cooldownInfo = {}
    cooldownInfo.start, cooldownInfo.duration, cooldownInfo.enable = C_Item.GetItemCooldown(itemId)
    local chargeInfo = C_Item.GetItemCount(itemId, nil, true)
    local texture = C_Item.GetItemIconByID(itemId)

    createdFrames[flag] = createdFrames[flag] or {}
    createdFrames[flag][itemId] = {
        itemId = itemId,
        frame = poolFrame:Acquire(),
        showCharge = info.showCharge,
        cooldownInfo = cooldownInfo,
        chargeInfo = chargeInfo,
        flag = flag,
    }
    createdFrames[flag][itemId].frame.obj = createdFrames[flag][itemId]

    local itemFrame = createdFrames[flag][itemId].frame

    itemFrame:UnregisterAllEvents()
    --ActionButton_HideOverlayGlow(itemFrame.Icon)
    itemFrame:Show()
    itemFrame.Icon.Icon:SetTexture(texture)
    --itemFrame.Cooldown:SetSwipeColor(0, 0, 0, 0.5)
    itemFrame.isActive               = false
    itemFrame.showWhenInactive       = info.showWhenInactive or false
    itemFrame.desaturateWhenInactive = info.desaturateWhenInactive or false
    itemFrame.showCooldown           = info.showCooldown or false

    local DB                         = addon.db.profile[flag].layout
    local spec                       = addon.db.global.playerSpec
    local db                         = DB[spec].useGlobalSettings and DB.global or DB[spec]
    local dynamicDisplay             = db.dynamicDisplayUpdate
    itemFrame.dynamicDisplay         = dynamicDisplay

    itemFrame.Bar:SetMinMaxValues(0, 1)
    itemFrame.Bar:SetValue(0)
    --itemFrame.Bar:ClearAllPoints()

    local item = Item:CreateFromItemID(itemId)

    local name
    item:ContinueOnItemLoad(function()
        name = item:GetItemName()
        --local icon = item:GetItemIcon()
    end)

    local nameFontString = itemFrame:GetNameFontString();
    if nameFontString then
        nameFontString:SetText(name or "")
    end

    itemFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
    itemFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    itemFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
    itemFrame:SetScript("OnEvent", OnEventItem)

    updateItemState(createdFrames[flag][itemId], "initial")
    return createdFrames[flag][itemId].frame
end
