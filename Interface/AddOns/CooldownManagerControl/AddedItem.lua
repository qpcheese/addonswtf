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
    elseif cooldown.start ~= 0 or charges <= 0 then
        itemFrame.isActive = false
        itemFrame:Hide()
    else
        itemFrame.isActive = true
        itemFrame:Show()
    end

    itemFrame.Icon:SetDesaturated(itemFrame.desaturateWhenInactive and (cooldown.start ~= 0 or charges <= 0))

    if itemFrame.dynamicDisplay then
        addon:applyLayout(name)
        addon:updateViewerSize(name)
    end
end

local function setupItemFrame(storageData)
    local cooldown = storageData.cooldownInfo
    local charge = storageData.chargeInfo
    local showCharge = storageData.showCharge

    if cooldown and cooldown.start ~= 0 then
        CooldownFrame_Set(storageData.frame.Cooldown, cooldown.start, cooldown.duration, cooldown.duration > 0, true)
    else
        CooldownFrame_Clear(storageData.frame.Cooldown)
    end

    --storageData.frame.Cooldown:SetHideCountdownNumbers(not storageData.frame.showCooldown )
    if (showCharge) then
        if storageData.frame.ChargeCount then
            storageData.frame.ChargeCount.Current:SetText(charge);
            storageData.frame.ChargeCount:SetShown(true);
        end

        if storageData.frame.Applications then
            storageData.frame.Applications.Applications:SetText(charge);
            storageData.frame.Applications:SetShown(true);
        end
    else
        if storageData.frame.ChargeCount then
            storageData.frame.ChargeCount:SetShown(false);
        end

        if storageData.frame.Applications then
            storageData.frame.Applications:SetShown(false);
        end
    end
end

local function updateItemState(storageData, origin)
    local cooldownInfo = {}
    local oldCooldown = storageData.cooldownInfo
    local oldCharge = storageData.chargeInfo

    cooldownInfo.start, cooldownInfo.duration, cooldownInfo.enable = C_Item.GetItemCooldown(storageData.itemId)
    local chargeInfo = C_Item.GetItemCount(storageData.itemId, nil, true)

    if origin == "initial" or origin == "final" or oldCooldown.start ~= cooldownInfo.start or oldCooldown.duration ~= cooldownInfo.duration or oldCharge ~= chargeInfo then
        storageData.cooldownInfo = cooldownInfo
        storageData.chargeInfo = chargeInfo
        setupItemFrame(storageData)
        updateIconState(storageData.frame, storageData.chargeInfo)
    end
end

local function OnEventItem(self, event, ...)
    if event == "BAG_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
        local storageData = self.obj
        if storageData then
            updateItemState(storageData)
        end
    end
end

--- Create a custom Icon frame to be injected into a Cooldown Viewer.
---
--- @param itemId string Item ID of the item frame to create.
--- @param info table Configuration info for the item frame.
--- @param poolFrame Frame Pool from which to acquire the item frame.
--- @param flag string Flag indicating the viewer type (e.g., "essential", "utility").
--- @return Frame Frame The created item frame.
function addon:CreateItemFrame(itemId, info, poolFrame, flag)
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
    itemFrame:Show()
    itemFrame.Icon:SetTexture(texture)
    itemFrame.Cooldown:SetSwipeColor(0, 0, 0, 0.5)

    itemFrame.isActive = true
    itemFrame.showWhenInactive = info.showWhenInactive or false
    itemFrame.desaturateWhenInactive = info.desaturateWhenInactive or false
    itemFrame.showCooldown = info.showCooldown or false
    if name == "buffIcon" then
        local DB                 = addon.db.profile[flag].layout
        local spec               = addon.db.global.playerSpec
        local db                 = DB[spec].useGlobalSettings and DB.global or DB[spec]
        local dynamicDisplay     = db.dynamicDisplayUpdate
        itemFrame.dynamicDisplay = dynamicDisplay
    end

    itemFrame:UnregisterAllEvents()
    itemFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
    itemFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    itemFrame:SetScript("OnEvent", OnEventItem)

    updateItemState(createdFrames[flag][itemId], "initial")


    itemFrame:GetCooldownFrame():SetScript("OnCooldownDone", function()
        updateItemState(createdFrames[flag][itemId], "final")
    end);

    return createdFrames[flag][itemId].frame
end
