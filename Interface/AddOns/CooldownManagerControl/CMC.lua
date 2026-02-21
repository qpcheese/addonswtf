local addonName, addonTable              = ...
local addon                              = addonTable.Core

local aceConfigDialog                    = LibStub("AceConfigDialog-3.0")
local LibEditModeOverride                = LibStub("LibEditModeOverride-1.0")
local LCG                                = LibStub("LibCustomGlow-1.0")

StaticPopupDialogs["CMC_SECRET_TRIGGER"] = {
    text = "Secret detected while initializing a buff/debuff. Show when inactive/desaturate may not be reflected properly \n Reloading is needed to solve the issue.",
    button1 = "Reload UI",
    button2 = "Cancel",
    OnAccept = function()
        ReloadUI()
    end,
    hideOnEscape = true,
}

--- Tables used during viewer updates
addonTable.tmp                           = {}
addonTable.stateTable                    = {}
addonTable.indexTable                    = {}
addonTable.widthTable                    = {}
addonTable.heightTable                   = {}
addonTable.addedItemsList                = {}
addonTable.sizeTable                     = {}
addonTable.callFromWithin                = false
addonTable.savedSettings                 = nil

-- Mapping addon internal names to blizz frame
addonTable.viewerFrameMap                = {
    essential = EssentialCooldownViewer,
    utility   = UtilityCooldownViewer,
    buffIcon  = BuffIconCooldownViewer,
    buffBar   = BuffBarCooldownViewer,
}

--- Reset callback for pooled item frames.
local itemResetCallback                  = function(pool, itemFrame)
    Pool_HideAndClearAnchors(pool, itemFrame)
    itemFrame.isActive = nil
    itemFrame.showWhenInactive = nil
    itemFrame.desaturateWhenInactive = nil
    if itemFrame.Bar then
        itemFrame.Bar:SetScript("OnUpdate", nil)
        itemFrame.Bar:SetValue(0)
        itemFrame.Icon.Icon:SetDesaturated(false)
    else
        itemFrame.Icon:SetDesaturated(false)
    end
    if itemFrame.Cooldown then
        CooldownFrame_Clear(itemFrame.Cooldown)
    end
end

-- Pool frames for different viewers (used when adding custom items)
local pool                               = {
    essential = CreateFramePool("FRAME", _G["EssentialCooldownViewer"], _G["EssentialCooldownViewer"].itemTemplate, itemResetCallback),
    utility   = CreateFramePool("FRAME", _G["UtilityCooldownViewer"], _G["UtilityCooldownViewer"].itemTemplate, itemResetCallback),
    buffIcon  = CreateFramePool("FRAME", _G["BuffIconCooldownViewer"], _G["BuffIconCooldownViewer"].itemTemplate, itemResetCallback),
    buffBar   = CreateFramePool("FRAME", _G["BuffBarCooldownViewer"], _G["BuffBarCooldownViewer"].itemTemplate, itemResetCallback),
}

--- Updates addon tables based on the current spells present in the viewer.
local function updateTable(itemFrameList, name)
    if not itemFrameList then return end

    local spec = addon.db.global.playerSpec

    for i = 1, #itemFrameList, 1 do
        local itemFrame = itemFrameList[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

        if cooldownID then
            -- Add to the saved variable table if not already present
            if not addon.db.profile[name].override[spec][cooldownID] then
                addon.db.profile[name].override[spec][cooldownID] = addon:deepCopy(addonTable.ItemFrameDefault)
                addon.db.profile[name].override[spec][cooldownID].cooldownID = cooldownID
                addon.db.profile[name].override[spec][cooldownID].rank = i
            else
                -- or correct to the actual rank (this is changed when the user reorders the frames)
                addon.db.profile[name].override[spec][cooldownID].rank = i
            end

            -- Extract only the currently used cooldownIDs into a temporary table for easy access by the options panel
            addonTable.tmp[name][spec][cooldownID] = addon.db.profile[name].override[spec][cooldownID]
        end
    end
end

--- Performs a full refresh of a CooldownViewer.
--- @param name string  The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:updateViewer(name)
    -- Initialize
    local spec = addon.db.global.playerSpec
    local viewer = addonTable.viewerFrameMap[name]
    addonTable.tmp[name] = {}
    addonTable.tmp[name][spec] = {}

    addonTable.stateTable[name] = {}
    addonTable.indexTable[name] = {}
    addonTable.widthTable[name] = 0
    addonTable.heightTable[name] = 0

    local triggerSecret = false
    local itemFrameContainer = viewer:GetLayoutChildren()

    -- Update the saved variable table to reflect the current frames in the viewer
    updateTable(itemFrameContainer, name)

    -- Iterate through the added frames (we need to inject the custom frames in the index table at their designated position)
    local additionalFrames = addon.db.profile[name].display[spec] or {}
    addonTable.addedItemsList[name] = {}
    addonTable.addedItemsList[name][spec] = {}

    local poolFrame = pool[name]
    poolFrame:ReleaseAll()

    for key, values in pairs(additionalFrames) do
        local frame
        if values.enable then
            if name == "buffBar" then
                frame = addon:CreateBarItemFrame(values.itemId, values, poolFrame, name)
            else
                frame = addon:CreateItemFrame(values.itemId, values, poolFrame, name)
            end

            if name == "essential" or name == "utility" then
                local outOfRangeTexture = frame:GetOutOfRangeTexture()
                outOfRangeTexture:SetShown(false);
            end
        end
        if frame then
            if name == "buffBar" then
                addon:setBarStyle(frame, additionalFrames[key])
            else
                addon:setIconStyle(frame, additionalFrames[key], name)
            end
            table.insert(addonTable.addedItemsList[name][spec], { frame = frame, rank = values.rank or 999, meta = values })
        end
    end

    -- Loop through added items to setPoint the overriden ones
    for i = 1, #addonTable.addedItemsList[name][spec], 1 do
        local addedEntry = addonTable.addedItemsList[name][spec][i]
        local addedFrame = addedEntry.frame
        local overrideSettings = addedEntry.meta

        -- Overriden frames
        if overrideSettings.enable and overrideSettings.overridePose then
            local anchor = overrideSettings.anchor
            local anchorRel = overrideSettings.anchorRel
            local xOffset = overrideSettings.xOffset
            local yOffset = overrideSettings.yOffset
            local parent = overrideSettings.parent

            addedFrame:ClearAllPoints()
            addedFrame:SetPoint(anchor, parent, anchorRel, xOffset, yOffset)
        end
    end

    -- Iterate through the viewer frames (we apply the visual settings and show/hide/desaturate hooks here)
    for i = 1, #itemFrameContainer, 1 do
        local itemFrame = itemFrameContainer[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

        if cooldownID then
            ---------------------------------------------------------------------------------------
            -- Apply Appearance Settings
            local overrideSettings = addon.db.profile[name].override[spec][cooldownID]
            local settings = overrideSettings and overrideSettings.enable and overrideSettings or nil

            if name == "buffBar" then
                addon:setBarStyle(itemFrame, settings)
            else
                addon:setIconStyle(itemFrame, settings, name)
            end

            addon:updatePandemicIcon(itemFrame, settings, name)

            if name == "essential" or name == "utility" then
                addon:updateSpellAlert(itemFrame, settings, name)
                addon:setKeybind(itemFrame, name, cooldownID)
            end

            if name == "essential" then
                addon:setAssistedHighlight(itemFrame, settings)
            end

            ---------------------------------------------------------------------------------------
            -- Apply Positioning Settings for overriden frames
            if settings and settings.overridePose then
                -- Initialize
                local anchor = settings.anchor
                local anchorRel = settings.anchorRel
                local xOffset = settings.xOffset
                local yOffset = settings.yOffset
                local parent = settings.parent

                itemFrame:ClearAllPoints()
                itemFrame:SetPoint(anchor, parent, anchorRel, xOffset, yOffset)

                -- Hook to maintain placement
                local avoidSelfCall = false
                addon:SecureHook(itemFrame, "SetPoint", function(self)
                    if avoidSelfCall then return end
                    avoidSelfCall = true
                    self:ClearAllPoints()
                    self:SetPoint(anchor, parent, anchorRel, xOffset, yOffset)
                    avoidSelfCall = false
                end)
            end

            ---------------------------------------------------------------------------------------
            -- Hooks for state-based changes
            if (name == "buffIcon" or name == "buffBar") then
                
                --[[ addon:SecureHook(itemFrame, "TriggerAuraAppliedAlert", function(self)
                    print("|cff0099ccCooldown Manager|r Control: ", "TriggerAuraAppliedAlert triggered for", cooldownID)
                end)
                
                 addon:SecureHook(itemFrame, "TriggerAuraRemovedAlert", function(self)
                    print("|cff0099ccCooldown Manager|r Control: ", "TriggerAuraRemovedAlert triggered for", cooldownID)
                end) ]]
                
                -- These viewers can use the frame state to alter the display. So we store the state and hook the active state changes
                addonTable.stateTable[name][cooldownID] = issecretvalue(itemFrame.isActive) and true or itemFrame.isActive
                local stateWasInitialized = issecretvalue(itemFrame.isActive) and false or true
                triggerSecret = issecretvalue(itemFrame.isActive)

                -- Identify if we need to handle desature and show when inactive
                local desaturateWhenInactive
                if addon.db.profile[name].override[spec][cooldownID].enable then
                    desaturateWhenInactive = addon.db.profile[name].override[spec][cooldownID].desaturateWhenInactive
                else
                    desaturateWhenInactive = addon.db.profile[name].layout.desaturateWhenInactive
                end

                local showWhenInactive
                if addon.db.profile[name].override[spec][cooldownID].enable then
                    showWhenInactive = addon.db.profile[name].override[spec][cooldownID].showWhenInactive
                else
                    showWhenInactive = addon.db.profile[name].layout.showWhenInactive
                end

                -- TODO: block if restricted? Should be handled when updateViewer is called
                local varState = 0
                if LibEditModeOverride:IsReady() then
                    LibEditModeOverride:LoadLayouts()
                    varState = LibEditModeOverride:GetFrameSetting(viewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive)
                end

                if not showWhenInactive and varState == 1 then
                    --print("|cff0099ccCooldown Manager|r Control: ", cooldownID, "in", name, "Will use Show/Hide.")
                    addonTable.stateTable[name][cooldownID] = itemFrame:IsShown()
                    triggerSecret = false
                    stateWasInitialized = true
                end

                local dynamicDisplay = addon.db.profile[name].layout.dynamicDisplayUpdate or false

                ---------------------------------------------------------------------------------------
                -- First we handle the initial state
                -- Desaturate when inactive
                if showWhenInactive then
                    if desaturateWhenInactive then
                        if name == "buffIcon" then
                            --itemFrame.Icon:SetDesaturated(not itemFrame.isActive)
                            itemFrame.Icon:SetDesaturated(not addonTable.stateTable[name][cooldownID])
                        end
                        if name == "buffBar" then
                            --itemFrame.Icon.Icon:SetDesaturated(not itemFrame.isActive)
                            itemFrame.Icon.Icon:SetDesaturated(not addonTable.stateTable[name][cooldownID])
                        end
                    else
                        if name == "buffIcon" then
                            itemFrame.Icon:SetDesaturated(false)
                        end
                        if name == "buffBar" then
                            itemFrame.Icon.Icon:SetDesaturated(false)
                        end
                    end
                end

                -- Show when inactive
                itemFrame:SetShown(showWhenInactive or addonTable.stateTable[name][cooldownID])

                -- TODO:
                -- If no show when inactive the hook can be a script hook on OnShow/OnHide to obtain the real state
                -- However, if show when inactive is enabled we need to hook the IsActive function and do the tracking ourselves
                if not showWhenInactive and varState == 1 then
                    addon:SecureHookScript(itemFrame, "OnShow", function(self)
                        --print("|cff0099ccCooldown Manager|r Control: ", "OnShow triggered for", cooldownID)
                        addonTable.stateTable[name][cooldownID] = true
                        if dynamicDisplay and (not settings or not settings.overridePose) then
                            addon:getIndexListDynamic(name)
                            local positionInIndex = addon:positionInIndexTableUpdated(name, "normal", i)

                            -- 0 means not present in the index table
                            if positionInIndex == 0 then
                                self:ClearAllPoints()
                                self:Hide()
                            end

                            -- Reposition all frames as the order may have changed
                            local indexTable  = addonTable.indexTable[name]
                            local totalFrames = #indexTable
                            local maxWidth    = addonTable.widthTable[name]
                            local maxHeight   = addonTable.heightTable[name]
                            local addedFrames = addonTable.addedItemsList[name][spec] or {}
                            for mergedIndex, entry in ipairs(indexTable) do
                                local frameToUpdate

                                if entry.kind == "normal" then
                                    frameToUpdate = itemFrameContainer[entry.index]
                                elseif entry.kind == "added" then
                                    frameToUpdate = addedFrames[entry.index] and addedFrames[entry.index].frame
                                end

                                if frameToUpdate then
                                    local anchor, parentAnchor, xOffset, yOffset =
                                        addon:returnLayoutCoordinate(name, mergedIndex, totalFrames, maxWidth, maxHeight)

                                    frameToUpdate:ClearAllPoints()
                                    frameToUpdate:SetPoint(anchor, viewer, parentAnchor, xOffset, yOffset)
                                end
                            end

                            -- Update the viewer size
                            addon:updateViewerSize(name)
                        end
                    end)
                    addon:SecureHookScript(itemFrame, "OnHide", function(self)
                        --print("|cff0099ccCooldown Manager|r Control: ", "OnHide triggered for", cooldownID)
                        addonTable.stateTable[name][cooldownID] = false

                        --[[ LCG.PixelGlow_Stop(self.Bar)
                        LCG.PixelGlow_Stop(self) ]]

                        if dynamicDisplay and (not settings or not settings.overridePose) then
                            addon:getIndexListDynamic(name)
                            local positionInIndex = addon:positionInIndexTableUpdated(name, "normal", i)

                            -- 0 means not present in the index table
                            if positionInIndex == 0 then
                                self:ClearAllPoints()
                                self:Hide()
                            end

                            -- Reposition all frames as the order may have changed
                            local indexTable  = addonTable.indexTable[name]
                            local totalFrames = #indexTable
                            local maxWidth    = addonTable.widthTable[name]
                            local maxHeight   = addonTable.heightTable[name]
                            local addedFrames = addonTable.addedItemsList[name][spec] or {}
                            for mergedIndex, entry in ipairs(indexTable) do
                                local frameToUpdate

                                if entry.kind == "normal" then
                                    frameToUpdate = itemFrameContainer[entry.index]
                                elseif entry.kind == "added" then
                                    frameToUpdate = addedFrames[entry.index] and addedFrames[entry.index].frame
                                end

                                if frameToUpdate then
                                    local anchor, parentAnchor, xOffset, yOffset =
                                        addon:returnLayoutCoordinate(name, mergedIndex, totalFrames, maxWidth, maxHeight)

                                    frameToUpdate:ClearAllPoints()
                                    frameToUpdate:SetPoint(anchor, viewer, parentAnchor, xOffset, yOffset)
                                end
                            end

                            -- Update the viewer size
                            addon:updateViewerSize(name)
                        end
                    end)
                else
                    -- Then we hook to react to state changes
                    addon:SecureHook(itemFrame, "OnActiveStateChanged", function(self)
                        --print("|cff0099ccCooldown Manager|r Control: ", "OnActiveStateChanged triggered for", cooldownID)
                        -- Update the stored state based on the new active state/initialization
                        if issecretvalue(self.isActive) and stateWasInitialized then
                            -- We cannot read the actual state, but we could determine it at init, so we flip the current state
                            addonTable.stateTable[name][cooldownID] = not addonTable.stateTable[name][cooldownID]
                        elseif issecretvalue(self.isActive) then
                            -- We cannot read the actual state, and we could not determine it at init, so we assume active at all times
                            --triggerSecret = true
                            addonTable.stateTable[name][cooldownID] = true
                        else
                            addonTable.stateTable[name][cooldownID] = self.isActive
                            stateWasInitialized = true
                        end

                        -- Case 1: dynamic display
                        if dynamicDisplay and (not settings or not settings.overridePose) then
                            addon:getIndexListDynamic(name)
                            local positionInIndex = addon:positionInIndexTableUpdated(name, "normal", i)

                            -- 0 means not present in the index table
                            if positionInIndex == 0 then
                                self:ClearAllPoints()
                                self:Hide()
                            end

                            -- Reposition all frames as the order may have changed
                            local indexTable  = addonTable.indexTable[name]
                            local totalFrames = #indexTable
                            local maxWidth    = addonTable.widthTable[name]
                            local maxHeight   = addonTable.heightTable[name]
                            local addedFrames = addonTable.addedItemsList[name][spec] or {}
                            for mergedIndex, entry in ipairs(indexTable) do
                                local frameToUpdate

                                if entry.kind == "normal" then
                                    frameToUpdate = itemFrameContainer[entry.index]
                                elseif entry.kind == "added" then
                                    frameToUpdate = addedFrames[entry.index] and addedFrames[entry.index].frame
                                end

                                if frameToUpdate then
                                    local anchor, parentAnchor, xOffset, yOffset =
                                        addon:returnLayoutCoordinate(name, mergedIndex, totalFrames, maxWidth, maxHeight)

                                    frameToUpdate:ClearAllPoints()
                                    frameToUpdate:SetPoint(anchor, viewer, parentAnchor, xOffset, yOffset)
                                end
                            end

                            -- Update the viewer size
                            addon:updateViewerSize(name)
                        end

                        -- Case 2: desaturate when inactive
                        if showWhenInactive then
                            if desaturateWhenInactive then
                                if name == "buffIcon" then
                                    --self.Icon:SetDesaturated(not self.isActive)
                                    self.Icon:SetDesaturated(not addonTable.stateTable[name][cooldownID])
                                end
                                if name == "buffBar" then
                                    --self.Icon.Icon:SetDesaturated(not self.isActive)
                                    self.Icon.Icon:SetDesaturated(not addonTable.stateTable[name][cooldownID])
                                end
                            else
                                if name == "buffIcon" then
                                    self.Icon:SetDesaturated(false)
                                end
                                if name == "buffBar" then
                                    self.Icon.Icon:SetDesaturated(false)
                                end
                            end
                        end
                        -- Case 3: show when inactive
                        self:SetShown(showWhenInactive or addonTable.stateTable[name][cooldownID])
                    end)

                    -- Show when inactive should also be hooked to the UpdateShownState function
                    addon:SecureHook(itemFrame, "UpdateShownState", function(self)
                        self:SetShown(showWhenInactive or addonTable.stateTable[name][cooldownID])
                    end)
                end
            end
        end
    end

    --[[ if triggerSecret then
        --print("|cff0099ccCooldown Manager|r Control" .. ": ", "Secret(s) detected.", "Visibility settings may not be properly reflected -- /reload to try to fix it.")
    end ]]

    -- Layout the non-overriden frames
    addon:applyLayout(name)

    --- Maintain the viewer size (this is required to keep the layout consistent)
    addon:updateViewerSize(name)

    return triggerSecret
end

--- Reposition a CooldownViewer. Inherits the scale of the parent if not UIParent.
--- @param name string  The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:anchorViewer(name)
    local viewer = addonTable.viewerFrameMap[name]
    local db = addon.db.profile[name].anchor
    local vAnchor = db.point
    local vParentAnchor = db.relativePoint
    local vXOffset = db.xOffset
    local vYOffset = db.yOffset
    local parent = db.parent

    --[[ addon:Unhook(viewer, "SetPoint")
    addon:Unhook(_G[parent], "SetScale") ]]

    if db.overridePlacement then
        viewer:ClearAllPoints()
        viewer:SetPoint(vAnchor, _G[parent], vParentAnchor, vXOffset, vYOffset)

        -- Hook to maintain placement
        local avoidSelfCall = false
        addon:SecureHook(viewer, "SetPoint", function(self)
            if avoidSelfCall then return end
            avoidSelfCall = true
            self:ClearAllPoints()
            self:SetPoint(vAnchor, _G[parent], vParentAnchor, vXOffset, vYOffset)
            avoidSelfCall = false
        end)

        -- Inherit the parent scale
        if db.inheritsScale then
            local parentScale = _G[parent]:GetScale()
            if parent == "UIParent" then
                parentScale = 1
            else
                viewer:SetScale(parentScale)
            end

            if addon:IsHooked(_G[parent], "SetScale") then
                addon:Unhook(_G[parent], "SetScale")
            end
            addon:SecureHook(_G[parent], "SetScale", function(self)
                local names = { "essential", "utility", "buffIcon", "buffBar" }
                local _parentScale = _G[parent]:GetScale()

                for _, vname in pairs(names) do
                    local viewerV = addonTable.viewerFrameMap[vname]
                    local baseDB = addon.db.profile[vname].anchor
                    if baseDB.parent == parent and baseDB.overridePlacement and baseDB.inheritsScale then
                        if parent == "UIParent" then
                            viewerV:SetScale(1)
                        else
                            viewerV:SetScale(_parentScale)
                        end
                    end
                end
            end)
        else
            viewer:SetScale(1)
        end

        -- Inherits visibility from parent
        if db.inheritsVisibility then
            if addon:IsHooked(_G[parent], "OnShow") then
                addon:Unhook(_G[parent], "OnShow")
            end
            addon:SecureHookScript(_G[parent], "OnShow", function(self)
                local names = { "essential", "utility", "buffIcon", "buffBar" }
                for _, vname in pairs(names) do
                    local viewerV = addonTable.viewerFrameMap[vname]
                    local baseDB = addon.db.profile[vname].anchor
                    if baseDB.parent == parent and baseDB.overridePlacement and baseDB.inheritsVisibility then
                        viewerV:Show()
                    end
                end
            end)

            if addon:IsHooked(_G[parent], "OnHide") then
                addon:Unhook(_G[parent], "OnHide")
            end
            addon:SecureHookScript(_G[parent], "OnHide", function(self)
                local names = { "essential", "utility", "buffIcon", "buffBar" }
                for _, vname in pairs(names) do
                    local viewerV = addonTable.viewerFrameMap[vname]
                    local baseDB = addon.db.profile[vname].anchor
                    if baseDB.parent == parent and baseDB.overridePlacement and baseDB.inheritsVisibility then
                        viewerV:Hide()
                    end
                end
            end)
        else
            --viewer:Show()
        end
    else
        --viewer:SetScale(1)
    end
end

--- Callback to refresh all enabled CooldownViewers.
function addon:RefreshViewer()
    --[[ if addonTable.isRestricted then
        print("|cff0099ccCooldown Manager|r Control: ", "Cannot refresh viewers due to addon restrictions in place.")
        return
    end ]]

    -- Clear all hooks
    addon:UnhookAll()

    -- Setup hooks for each item of the enabled viewers
    local triggerSecret = false
    if addon.db.profile.essential.enable then
        addon:updateViewer("essential")
    end
    if addon.db.profile.utility.enable then
        addon:updateViewer("utility")
    end
    if addon.db.profile.buffIcon.enable then
        local test = addon:updateViewer("buffIcon")
        if test then
            triggerSecret = true
        end
    end
    if addon.db.profile.buffBar.enable then
        local test = addon:updateViewer("buffBar")
        if test then
            triggerSecret = true
        end
    end

    if triggerSecret then
        StaticPopup_Show("CMC_SECRET_TRIGGER")
    end

    -- Setup the hooks for reacting to layout refreshes
    if addon.db.profile.essential.enable then
        addon:SecureHook(EssentialCooldownViewer, "RefreshLayout", function(self)
            addon:BuildKeybindCache(false, false)
            addon:applyStyle("essential")
            addon:applyLayout("essential")
            addon:updateViewerSize("essential")
        end)
    end

    if addon.db.profile.utility.enable then
        addon:SecureHook(UtilityCooldownViewer, "RefreshLayout", function(self)
            addon:BuildKeybindCache(false, false)
            addon:applyStyle("utility")
            addon:applyLayout("utility")
            addon:updateViewerSize("utility")
        end)
    end

    if addon.db.profile.buffIcon.enable then
        addon:SecureHook(BuffIconCooldownViewer, "RefreshLayout", function(self)
            addon:applyStyle("buffIcon")
            addon:applyLayout("buffIcon")
            addon:updateViewerSize("buffIcon")
        end)
    end

    if addon.db.profile.buffBar.enable then
        addon:SecureHook(BuffBarCooldownViewer, "RefreshLayout", function(self)
            addon:applyStyle("buffBar")
            addon:applyLayout("buffBar")
            addon:updateViewerSize("buffBar")
        end)
    end

    -- Run once to check if an icon needs assisted highlight
    local CVar = C_CVar.GetCVar("assistedCombatHighlight")
    if addon.db.profile.essential.enable and addon.db.profile.essential.layout.showAssistedHighlight and CVar == "1" then
        local spellID = C_AssistedCombat.GetNextCastSpell()
        local correspondingCooldownIDs = addon.db.global.spellIDCache[spellID]

        local itemFrameContainer = EssentialCooldownViewer:GetLayoutChildren()
        local found = nil

        for i = 1, #itemFrameContainer, 1 do
            local itemFrame = itemFrameContainer[i]
            local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

            if not found then
                if addon:GetIndex(cooldownID, correspondingCooldownIDs or {}) then
                    addon:startAssistedHighlight(itemFrame)
                    found = true
                else
                    addon:stopAssistedHighlight(itemFrame)
                end
            else
                addon:stopAssistedHighlight(itemFrame)
            end
        end
    else
        -- Ensure all highlights are stopped
        local itemFrameContainer = EssentialCooldownViewer:GetLayoutChildren()

        for i = 1, #itemFrameContainer, 1 do
            local itemFrame = itemFrameContainer[i]
            addon:stopAssistedHighlight(itemFrame)
        end
    end

    -- Setup the hooks fro the viewer placements
    addon:anchorViewer("essential")
    addon:anchorViewer("utility")
    addon:anchorViewer("buffIcon")
    addon:anchorViewer("buffBar")

    -- Combat State
    if InCombatLockdown() then
        addon:OnCombatChanged("PLAYER_IN_COMBAT_CHANGED", true)
    else
        addon:OnCombatChanged("PLAYER_IN_COMBAT_CHANGED", false)
    end

    -- Refresh the override and item options for the options panel
    addon:GetOverrideOptions()
    addon:GetItemOptions()
end

--- Handler executed when entering the game world.
--- Refreshes the viewers, initializes the cooldown ID cache if empty,
--- and rebuilds keybind lookup tables.
function addon:OnEntering()
    --[[ if LibEditModeOverride:IsReady() then
        LibEditModeOverride:LoadLayouts()

        if addon.db.profile.buffIcon.enable then
            LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
            LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
        end

        if addon.db.profile.buffBar.enable then
            LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
            LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
        end

        if addon.db.profile.essential.enable then
            LibEditModeOverride:SetFrameSetting(EssentialCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
        end

        if addon.db.profile.utility.enable then
            LibEditModeOverride:SetFrameSetting(UtilityCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
        end

        LibEditModeOverride:ApplyChanges()
    end ]]

    --[[ local frame = CreateFrame("Frame")
    frame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "EDIT_MODE_LAYOUTS_UPDATED" then
            --print("|cff0099ccCooldown Manager|r Control: ", "Reapplying Edit Mode Override settings for Buff Icon and Buff Bar viewers after layout update.")
            LibEditModeOverride:LoadLayouts()

            if addon.db.profile.buffIcon.enable then
                LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
                LibEditModeOverride:SetFrameSetting(BuffIconCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
            end

            if addon.db.profile.buffBar.enable then
                LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.HideWhenInactive, 1)
                LibEditModeOverride:SetFrameSetting(BuffBarCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
            end

            if addon.db.profile.essential.enable then
                LibEditModeOverride:SetFrameSetting(EssentialCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
            end

            if addon.db.profile.utility.enable then
                LibEditModeOverride:SetFrameSetting(UtilityCooldownViewer, Enum.EditModeCooldownViewerSetting.VisibleSetting, Enum.CooldownViewerVisibleSetting.Always)
            end

            if not addonTable.isRestricted then
                addonTable.savedSettings = false
                LibEditModeOverride:ApplyChanges()
            else
                print("|cff0099ccCooldown Manager|r Control: ", "Cannot apply Edit Mode Override due to addon restrictions in place.")
                addonTable.savedSettings = true
                LibEditModeOverride:SaveOnly()
            end
            addon:RefreshViewer()
            frame:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
        end
    end) ]]

    addon:RefreshViewer()

    if not next(addon.db.global.cooldownIDsCache) then
        addon:BuildCooldownIDCache()
    end

    addon:BuildKeybindCache(true, true)
end

--- Handler executed when the player's specialization changes.
--- Rebuilds the keybind cache and refreshes the viewers to reflect any changes.
--- @param event string The event name triggering the handler.
--- @param unit string The unit identifier (should be "player" for this handler).
function addon:OnSpecilizationChanged(event, unit)
    if unit ~= "player" then return end

    addon:BuildKeybindCache(true, true)

    -- To ensure that the viewer is updated after spec change, we register a temporary callback
    EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
        local specIndex = C_SpecializationInfo.GetSpecialization()
        addon.db.global.playerSpec = specIndex and select(1, C_SpecializationInfo.GetSpecializationInfo(specIndex)) or nil

        addon:RefreshViewer()
        addon:GetOverrideOptions()
        addon:GetItemOptions()

        if addonTable.GUI and addonTable.GUI:IsShown() and addonTable.GUI.activeTab then
            aceConfigDialog:Open(addonTable.GUI.activeTab, addonTable.GUI.container)
        end
    end, self)

    -- Delay the deregistration to ensure the viewer is updated properly
    local timer = C_Timer.After(0.5, function()
        EventRegistry:UnregisterCallback("CooldownViewerSettings.OnDataChanged", self)
    end)
end

--- Handler executed when the player's talents change.
--- Refreshes the viewers and updates override and item options to reflect any changes.
function addon:OnTalentChanged()
    addon:RefreshViewer()
    addon:GetOverrideOptions()
    addon:GetItemOptions()

    if addonTable.GUI and addonTable.GUI:IsShown() and addonTable.GUI.activeTab then
        aceConfigDialog:Open(addonTable.GUI.activeTab, addonTable.GUI.container)
    end
end

--- Handler executed when keybindings are updated.
--- Rebuilds the keybind cache and reapplies keybind displays to enabled viewers.
function addon:OnKeybindUpdate()
    local keybindShown = addon.db.profile.essential.layout.keybind.showKeybind or addon.db.profile.utility.layout.keybind.showKeybind
    if not keybindShown then
        return
    end

    -- Rebuild the keybind cache
    addon:BuildKeybindCache(true, false)

    if addon.db.profile.essential.enable and addon.db.profile.essential.layout.keybind.showKeybind then
        addon:applyKeybind("essential")
    end

    if addon.db.profile.utility.enable and addon.db.profile.utility.layout.keybind.showKeybind then
        addon:applyKeybind("utility")
    end
end

--- Handler executed when an action bar slot changes.
--- Updates the keybind for the affected slot and reapplies keybind displays to enabled viewers.
function addon:AcitionBarSlotChanged(event, slot)
    local keybindShown = addon.db.profile.essential.layout.keybind.showKeybind or addon.db.profile.utility.layout.keybind.showKeybind
    if not keybindShown then
        return
    end

    if slot then
        addon:UpdateSlot(slot)
    end

    if addon.db.profile.essential.enable and addon.db.profile.essential.layout.keybind.showKeybind then
        addon:applyKeybind("essential")
    end

    if addon.db.profile.utility.enable and addon.db.profile.utility.layout.keybind.showKeybind then
        addon:applyKeybind("utility")
    end
end

local wasPreviouslyOpen = false

--- Handler executed when the player's combat state changes.
--- Adjust the visibility of cooldown viewer items based on their "show in combat" settings.
function addon:OnCombatChanged(event, state)
    if event == "PLAYER_IN_COMBAT_CHANGED" then
        if state and addonTable.GUI and addonTable.GUI:IsShown() then
            wasPreviouslyOpen = true
            addonTable.GUI:Hide()
        else
            if wasPreviouslyOpen then
                wasPreviouslyOpen = false
                addonTable.GUI:Show()
            end
        end
    end
end

--[[ local restrictionStates = {
    [0] = 0,
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
}
addonTable.isRestricted = false

function addon:OnAddonRestrictionChanged(event, type, state)
    if event == "ADDON_RESTRICTION_STATE_CHANGED" then
        restrictionStates[type] = state
    end
    if restrictionStates[0] ~= 0 or restrictionStates[1] ~= 0 or
        restrictionStates[2] ~= 0 or restrictionStates[3] ~= 0 then
        addonTable.isRestricted = true
        --print("|cff0099ccCooldown Manager|r Control: ", "Addon restrictions in place, Changing settings will be blocked.")
        return
    end
    addonTable.isRestricted = false
    --print("|cff0099ccCooldown Manager|r Control: ", "Addon restrictions lifted, Changing settings will be allowed.")
end ]]
