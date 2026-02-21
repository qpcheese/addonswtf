local addonName, addon = ...
RandomMog = addon

-- SavedVariables defaults
local defaults = {
    selectedSlots = {
        [1] = true,   -- Head
        [3] = true,   -- Shoulder (backward compatibility - now means both)
        ["3_left"] = true,   -- Left Shoulder
        ["3_right"] = true,  -- Right Shoulder
        [15] = true,  -- Back/Cloak
        [5] = true,   -- Chest
        [4] = false,  -- Shirt (disabled by default)
        [19] = false, -- Tabard (disabled by default)
        [9] = true,   -- Wrist
        [10] = true,  -- Hands
        [6] = true,   -- Waist
        [7] = true,   -- Legs
        [8] = true,   -- Feet
        [16] = true,  -- Main Hand
        [17] = true   -- Off Hand
    }
}

local frame = CreateFrame("Frame")
local button
local selectAllButton
local deselectAllButton
local slotCheckboxes = {}
local db

-- These are the actual inventory slot IDs used by WoW
-- Ordered for natural top-to-bottom animation flow
local transmogSlots = {
    1,  -- Head
    3,  -- Shoulder (handles both left and right)
    15, -- Back/Cloak
    5,  -- Chest
    4,  -- Shirt (often hidden)
    19, -- Tabard
    9,  -- Wrist
    10, -- Hands
    6,  -- Waist
    7,  -- Legs
    8,  -- Feet
    16, -- Main Hand
    17  -- Off Hand
    -- Note: Weapon enchants (illusions) will be handled after weapons
}

-- Separate shoulder slots for independent randomization
local shoulderSlots = {
    {slotID = 3, modification = Enum.TransmogModification.Main},      -- Left shoulder
    {slotID = 3, modification = Enum.TransmogModification.Secondary}  -- Right shoulder
}

-- Slot names for tooltips and display
local slotNames = {
    [0] = "Ammo", -- Old slot, might not be used
    [1] = "Head", 
    [2] = "Neck", -- Not transmoggable usually
    [3] = "Shoulder", -- Legacy, kept for compatibility
    ["3_left"] = "Left Shoulder",
    ["3_right"] = "Right Shoulder",
    [15] = "Back", 
    [5] = "Chest",
    [4] = "Shirt", 
    [19] = "Tabard", 
    [9] = "Wrist", 
    [10] = "Hands",
    [6] = "Waist", 
    [7] = "Legs", 
    [8] = "Feet", 
    [11] = "Finger 1", -- Ring, not transmoggable
    [12] = "Finger 2", -- Ring, not transmoggable  
    [13] = "Trinket 1", -- Not transmoggable
    [14] = "Trinket 2", -- Not transmoggable
    [16] = "Main Hand", 
    [17] = "Off Hand",
    [18] = "Ranged" -- Might be used for hunters/legacy
}

-- Map slot IDs to their button names in the UI
local slotButtonNames = {
    [1] = "HeadButton",
    [3] = "ShoulderButton",
    ["3_secondary"] = "SecondaryShoulderButton",  -- Right shoulder when split is enabled
    [15] = "BackButton",
    [5] = "ChestButton",
    [4] = "ShirtButton",
    [19] = "TabardButton",
    [9] = "WristButton",
    [10] = "HandsButton",
    [6] = "WaistButton",
    [7] = "LegsButton",
    [8] = "FeetButton",
    [16] = "MainHandButton",
    [17] = "SecondaryHandButton",
    ["16_enchant"] = "MainHandEnchantButton",  -- Main hand enchant
    ["17_enchant"] = "SecondaryHandEnchantButton"  -- Off hand enchant
}

local function CreateSlotCheckbox(parent, slotID, isRightShoulder, isEnchant)
    local checkboxKey = slotID
    local slotName = slotNames[slotID] or "Unknown"
    
    -- Handle shoulder slots specially
    if slotID == 3 then
        if isRightShoulder == true then  -- Explicitly check for true
            checkboxKey = "3_right"
            slotName = "Right Shoulder"
        elseif isRightShoulder == false then  -- Explicitly false means left shoulder
            checkboxKey = "3_left"
            slotName = "Left Shoulder"
        else
            -- nil means regular shoulder slot (not split)
            checkboxKey = 3
            slotName = "Shoulders"
        end
    elseif isEnchant then
        -- Handle enchant slots
        if slotID == 16 then
            checkboxKey = "16_enchant"
            slotName = "Main Hand Enchant"
        elseif slotID == 17 then
            checkboxKey = "17_enchant"
            slotName = "Off Hand Enchant"
        end
    end
    
    -- Create a background frame for better visibility
    local frameName
    if isRightShoulder then
        frameName = "RandomMogCheckFrameRightShoulder"
    elseif isEnchant then
        frameName = "RandomMogCheckFrameEnchant" .. slotID
    else
        frameName = "RandomMogCheckFrame" .. slotID
    end
    local frame = CreateFrame("Frame", frameName, parent:GetParent())
    frame:SetSize(32, 32)
    
    -- Position checkboxes based on actual slot locations
    -- Special handling for dual shoulders
    if slotID == 3 then
        if isRightShoulder then
            -- Right shoulder checkbox - always align like other left-side slots
            frame:SetPoint("LEFT", parent, "RIGHT", 2, 0)
        else
            -- Left shoulder - same position
            frame:SetPoint("LEFT", parent, "RIGHT", 2, 0)
        end
    -- LEFT SIDE SLOTS - put checkbox on RIGHT (inside):
    elseif slotID == 1 or     -- Head
       slotID == 15 or    -- Back
       slotID == 5 or     -- Chest
       slotID == 4 or     -- Shirt
       slotID == 19 or    -- Tabard
       slotID == 9 then   -- Wrist (moved to left side)
        frame:SetPoint("LEFT", parent, "RIGHT", 2, 0)
    
    -- RIGHT SIDE SLOTS - put checkbox on LEFT (inside):
    elseif slotID == 10 or  -- Hands
           slotID == 6 or   -- Waist
           slotID == 7 or   -- Legs
           slotID == 8 then -- Feet
        frame:SetPoint("RIGHT", parent, "LEFT", -2, 0)
    
    -- WEAPON SLOTS - put on top:
    elseif slotID == 16 or  -- Main Hand
           slotID == 17 then -- Off Hand
        if isEnchant then
            -- Enchant checkboxes go to the left of the enchant button, very close spacing
            frame:SetPoint("RIGHT", parent, "LEFT", 5, 0)
        else
            -- Weapon checkboxes go on top
            frame:SetPoint("BOTTOM", parent, "TOP", 0, 2)
        end
    end
    
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(parent:GetFrameLevel() + 10)
    
    -- Create the actual checkbox
    local checkboxName
    if isRightShoulder then
        checkboxName = "RandomMogCheckboxRightShoulder"
    elseif isEnchant then
        checkboxName = "RandomMogCheckboxEnchant" .. slotID
    else
        checkboxName = "RandomMogCheckbox" .. slotID
    end
    local checkbox = CreateFrame("CheckButton", checkboxName, frame, "UICheckButtonTemplate")
    checkbox:SetSize(28, 28)
    checkbox:SetPoint("CENTER")
    
    -- Set initial state
    checkbox:SetChecked(db.selectedSlots[checkboxKey])
    if DEBUG_MODE then
        print("|cFFFF00FF[DEBUG CHECKBOX CREATE]|r Creating checkbox for key '" .. tostring(checkboxKey) .. "' with initial state: " .. tostring(db.selectedSlots[checkboxKey]))
    end
    
    -- Apply ElvUI skinning if available
    local ElvUI = _G.ElvUI
    if ElvUI then
        local E = ElvUI[1]
        if E and E.GetModule then
            local S = E:GetModule('Skins', true)
            if S and S.HandleCheckBox then
                S:HandleCheckBox(checkbox)
            end
        end
    else
        -- Default textures when ElvUI is not present
        checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        
        -- Make the textures bigger
        checkbox:GetNormalTexture():SetSize(32, 32)
        checkbox:GetPushedTexture():SetSize(32, 32)
        checkbox:GetHighlightTexture():SetSize(32, 32)
        checkbox:GetCheckedTexture():SetSize(32, 32)
    end
    
    -- Click handler
    checkbox:SetScript("OnClick", function(self)
        db.selectedSlots[checkboxKey] = self:GetChecked()
        
        if DEBUG_MODE then
            print("|cFFFF00FF[CHECKBOX CLICK]|r Checkbox '" .. tostring(checkboxKey) .. "' clicked. New state: " .. tostring(self:GetChecked()))
            
            -- Print current database state for shoulders
            if slotID == 3 then
                print("|cFFFF00FF[SHOULDER STATE]|r After click - slot[3]=" .. tostring(db.selectedSlots[3]) .. 
                      ", slot[3_left]=" .. tostring(db.selectedSlots["3_left"]) .. 
                      ", slot[3_right]=" .. tostring(db.selectedSlots["3_right"]))
            end
        end
        
        PlaySound(self:GetChecked() and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)
    
    -- Store the checkbox key for later reference
    checkbox.checkboxKey = checkboxKey
    
    -- Tooltip
    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("RandomMog: " .. slotName, 1, 1, 1)
        if self:GetChecked() then
            GameTooltip:AddLine("Will be randomized", 0, 1, 0)
        else
            GameTooltip:AddLine("Will NOT be randomized", 1, 0.5, 0)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to toggle", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    
    checkbox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Store the frame for hiding/showing
    checkbox.bgFrame = frame
    
    return checkbox
end

local function CreateSlotCheckboxes()
    if not WardrobeTransmogFrame then return end
    
    if DEBUG_MODE then
        print("|cFFFF00FF[DEBUG CREATE]|r CreateSlotCheckboxes called - clearing old checkboxes")
    end
    
    -- Clear existing checkboxes first - COMPLETELY DESTROY THEM
    for key, checkbox in pairs(slotCheckboxes) do
        if checkbox then
            if DEBUG_MODE then
                print("|cFFFF00FF[DEBUG DESTROY]|r Destroying old checkbox: " .. tostring(key))
            end
            
            -- Get the parent frame
            local parent = checkbox:GetParent()
            
            -- Completely remove the checkbox
            checkbox:Hide()
            checkbox:SetScript("OnClick", nil)
            checkbox:SetScript("OnEnter", nil)
            checkbox:SetScript("OnLeave", nil)
            checkbox:ClearAllPoints()
            checkbox:SetParent(nil)
            
            -- Destroy the background frame if it exists
            if checkbox.bgFrame then
                checkbox.bgFrame:Hide()
                checkbox.bgFrame:ClearAllPoints()
                checkbox.bgFrame:SetParent(nil)
            end
            
            -- Destroy the parent frame completely
            if parent then
                parent:Hide()
                parent:ClearAllPoints()
                parent:SetParent(nil)
                -- If the parent has a specific name, try to set the global to nil
                local parentName = parent:GetName()
                if parentName and parentName:match("RandomMogCheckFrame") then
                    _G[parentName] = nil
                end
            end
            
            -- Also clear the checkbox global name if it exists
            local checkboxName = checkbox:GetName()
            if checkboxName then
                _G[checkboxName] = nil
            end
        end
    end
    wipe(slotCheckboxes)
    
    -- Create checkbox for each slot
    for _, slotID in ipairs(transmogSlots) do
        local buttonName = slotButtonNames[slotID]
        if buttonName then
            local slotButton = WardrobeTransmogFrame[buttonName]
            if slotButton then
                if slotID == 3 then
                    -- Forcibly remove ANY existing checkboxes from the shoulder button
                    -- Check for any checkbox frames that might be children of the button
                    for i = 1, slotButton:GetNumChildren() do
                        local child = select(i, slotButton:GetChildren())
                        if child and child.GetName then
                            local name = child:GetName()
                            if name and (name:match("RandomMog") or name:match("Checkbox")) then
                                if DEBUG_MODE then
                                    print("|cFFFF0000[DEBUG]|r Found orphan checkbox frame: " .. name .. " - destroying it")
                                end
                                child:Hide()
                                child:SetParent(nil)
                            end
                        end
                    end
                    
                    -- Also check the parent for shoulder-specific checkbox frames
                    local buttonParent = slotButton:GetParent()
                    if buttonParent then
                        for i = 1, buttonParent:GetNumChildren() do
                            local child = select(i, buttonParent:GetChildren())
                            if child and child.GetName then
                                local name = child:GetName()
                                -- Only destroy shoulder-related orphan frames (slot 3)
                                if name and name:match("RandomMogCheckFrame3") then
                                    if DEBUG_MODE then
                                        print("|cFFFF0000[DEBUG]|r Found orphan shoulder checkbox parent frame: " .. name .. " - destroying it")
                                    end
                                    child:Hide()
                                    child:SetParent(nil)
                                end
                            end
                        end
                    end
                    
                    -- Check if there's a separate SecondaryShoulderButton (when split shoulders is enabled)
                    local secondaryShoulderButton = WardrobeTransmogFrame["SecondaryShoulderButton"]
                    
                    if secondaryShoulderButton and secondaryShoulderButton:IsShown() then
                        -- Split shoulders mode - create separate left and right checkboxes
                        if DEBUG_MODE then
                            print("|cFFFF00FF[DEBUG CREATE]|r Split shoulders ENABLED - creating 3_left and 3_right checkboxes")
                        end
                        local leftCheckbox = CreateSlotCheckbox(slotButton, slotID, false)  -- Creates with key "3_left"
                        slotCheckboxes["3_left"] = leftCheckbox
                        
                        local rightCheckbox = CreateSlotCheckbox(secondaryShoulderButton, slotID, true)  -- Creates with key "3_right"
                        slotCheckboxes["3_right"] = rightCheckbox
                        if DEBUG_MODE then
                            print("|cFF00FF00RandomMog:|r Created separate left and right shoulder checkboxes")
                        end
                    else
                        -- Single shoulder mode - create regular slot 3 checkbox
                        local checkbox = CreateSlotCheckbox(slotButton, slotID)  -- Pass nil for isRightShoulder to get slot 3
                        slotCheckboxes[3] = checkbox
                        
                        if secondaryShoulderButton then
                            if DEBUG_MODE then
                                print("|cFFFFFF00RandomMog:|r Secondary shoulder button hidden")
                            end
                        elseif DEBUG_MODE then
                            print("|cFFFFFF00RandomMog:|r Secondary shoulder button not available")
                        end
                    end
                else
                    -- Create single checkbox for other slots
                    local checkbox = CreateSlotCheckbox(slotButton, slotID)
                    slotCheckboxes[slotID] = checkbox
                    
                    -- If this is a weapon slot, also create an enchant checkbox
                    if slotID == 16 or slotID == 17 then
                        local enchantButtonName = slotButtonNames[slotID .. "_enchant"]
                        local enchantButton = WardrobeTransmogFrame[enchantButtonName]
                        if enchantButton then
                            local enchantCheckbox = CreateSlotCheckbox(enchantButton, slotID, false, true)
                            slotCheckboxes[slotID .. "_enchant"] = enchantCheckbox
                        end
                    end
                end
            end
        end
    end
end

local function UpdateCheckboxStates()
    if DEBUG_MODE then
        print("|cFFFF00FF[DEBUG UPDATE]|r UpdateCheckboxStates called")
    end
    for key, checkbox in pairs(slotCheckboxes) do
        if checkbox and checkbox.checkboxKey then
            local newState = db.selectedSlots[checkbox.checkboxKey]
            checkbox:SetChecked(newState)
            if DEBUG_MODE then
                print("|cFFFF00FF[DEBUG UPDATE]|r Setting checkbox key '" .. tostring(checkbox.checkboxKey) .. "' to " .. tostring(newState))
            end
        elseif checkbox then
            -- Fallback for slots without checkboxKey
            local newState = db.selectedSlots[key]
            checkbox:SetChecked(newState)
            if DEBUG_MODE then
                print("|cFFFF00FF[DEBUG UPDATE]|r Setting checkbox key '" .. tostring(key) .. "' to " .. tostring(newState) .. " (fallback)")
            end
        end
    end
end

local function SelectAllSlots()
    for _, slotID in ipairs(transmogSlots) do
        if slotID == 3 then
            -- Check if split shoulders mode is active
            local secondaryShoulderButton = WardrobeTransmogFrame and WardrobeTransmogFrame["SecondaryShoulderButton"]
            if secondaryShoulderButton and secondaryShoulderButton:IsShown() then
                -- Split mode - set both left and right
                db.selectedSlots["3_left"] = true
                db.selectedSlots["3_right"] = true
            else
                -- Single mode - set regular slot 3
                db.selectedSlots[3] = true
                -- Also ensure split keys are set for consistency
                db.selectedSlots["3_left"] = true
                db.selectedSlots["3_right"] = true
            end
        else
            db.selectedSlots[slotID] = true
        end
        
        -- Also select weapon enchants if this is a weapon slot
        if slotID == 16 or slotID == 17 then
            db.selectedSlots[slotID .. "_enchant"] = true
        end
    end
    UpdateCheckboxStates()
    if DEBUG_MODE then
        print("|cFF00FF00RandomMog:|r All slots selected for randomization")
    end
end

local function DeselectAllSlots()
    for _, slotID in ipairs(transmogSlots) do
        if slotID == 3 then
            -- Check if split shoulders mode is active
            local secondaryShoulderButton = WardrobeTransmogFrame and WardrobeTransmogFrame["SecondaryShoulderButton"]
            if secondaryShoulderButton and secondaryShoulderButton:IsShown() then
                -- Split mode - clear both left and right
                db.selectedSlots["3_left"] = false
                db.selectedSlots["3_right"] = false
            else
                -- Single mode - clear regular slot 3
                db.selectedSlots[3] = false
                -- Also ensure split keys are cleared for consistency
                db.selectedSlots["3_left"] = false
                db.selectedSlots["3_right"] = false
            end
        else
            db.selectedSlots[slotID] = false
        end
        
        -- Also deselect weapon enchants if this is a weapon slot
        if slotID == 16 or slotID == 17 then
            db.selectedSlots[slotID .. "_enchant"] = false
        end
    end
    UpdateCheckboxStates()
    if DEBUG_MODE then
        print("|cFFFF0000RandomMog:|r All slots deselected")
    end
end

local function GetRandomAppearance(slotID)
    local category = C_TransmogCollection.GetCategoryInfo(slotID)
    if not category then return nil end
    
    local visualsList = C_TransmogCollection.GetCategoryAppearances(category.categoryID)
    if not visualsList or #visualsList == 0 then return nil end
    
    local usableAppearances = {}
    for _, visualInfo in ipairs(visualsList) do
        if visualInfo.isCollected and visualInfo.isUsable then
            table.insert(usableAppearances, visualInfo.visualID)
        end
    end
    
    if #usableAppearances == 0 then return nil end
    
    return usableAppearances[math.random(#usableAppearances)]
end

local function GetRandomIllusion()
    -- Get all collected illusions
    local illusions = C_TransmogCollection.GetIllusions()
    if not illusions or #illusions == 0 then return nil end
    
    local collectedIllusions = {}
    for _, illusionInfo in ipairs(illusions) do
        if illusionInfo.isCollected and illusionInfo.isUsable then
            table.insert(collectedIllusions, illusionInfo.sourceID)
        end
    end
    
    if #collectedIllusions == 0 then return nil end
    
    return collectedIllusions[math.random(#collectedIllusions)]
end


local DEBUG_MODE = false  -- Set to true to enable debug output

-- Improved appearance finding (inspired by BetterWardrobe's approach)
-- Moved outside RandomizeTransmog so it can be called from slash commands
local function GetRandomSourceForSlot(slotID, modification)
    if not db then
        return nil  -- DB not initialized yet
    end
        modification = modification or Enum.TransmogModification.Main
        local transmogLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, modification)
        if not transmogLocation then
            if DEBUG_MODE then
                if DEBUG_MODE then
                    print("|cFFFF0000[DEBUG]|r Slot " .. slotID .. ": No transmog location")
                end
            end
            return nil
        end
        
        -- Check if slot can be transmogrified
        local canTransmogrify, cannotTransmogrifyReason = C_Transmog.GetSlotInfo(transmogLocation)
        if DEBUG_MODE then
            if DEBUG_MODE then
                print("|cFF888888[DEBUG]|r Slot " .. slotID .. ": canTransmog=" .. tostring(canTransmogrify) .. ", reason=" .. tostring(cannotTransmogrifyReason))
            end
        end
        -- Don't skip slots just because canTransmogrify is false
        -- This can happen when nothing is equipped but transmog can still be applied
        
        local collectedAppearances = {}
        
        -- Get base category
        local baseSourceID = C_Transmog.GetSlotVisualInfo(transmogLocation)
        local categoryID = nil
        
        if baseSourceID and baseSourceID ~= 0 and baseSourceID ~= NO_TRANSMOG_SOURCE_ID then
            categoryID = C_TransmogCollection.GetAppearanceSourceInfo(baseSourceID)
        end
        
        -- For weapons, check all valid weapon categories (inspired by BetterWardrobe)
        if slotID == 16 or slotID == 17 then  -- Main hand or off hand
            local equippedItemID = GetInventoryItemID('player', slotID)
            
            -- Check all weapon categories including Legion Artifacts
            -- Legion artifacts use a special category ID (typically 29)
            local LEGION_ARTIFACT_CATEGORY = 29
            
            -- First check regular weapon categories
            for weaponCategoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
                local name, isWeapon, _, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(weaponCategoryID)
                
                if name and isWeapon then
                    local validForSlot = (slotID == 16 and canMainHand) or (slotID == 17 and canOffHand)
                    
                    if validForSlot and equippedItemID and C_TransmogCollection.IsCategoryValidForItem(weaponCategoryID, equippedItemID) then
                        local appearances = C_TransmogCollection.GetCategoryAppearances(weaponCategoryID, transmogLocation)
                        if appearances then
                            for _, appearance in ipairs(appearances) do
                                if appearance.isCollected and appearance.isUsable then
                                    local sources = C_TransmogCollection.GetAppearanceSources(appearance.visualID, weaponCategoryID, transmogLocation)
                                    if sources then
                                        for _, source in ipairs(sources) do
                                            if source.isCollected then
                                                table.insert(collectedAppearances, source.sourceID)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Also check Legion Artifacts category
            if equippedItemID and C_TransmogCollection.IsCategoryValidForItem(LEGION_ARTIFACT_CATEGORY, equippedItemID) then
                local appearances = C_TransmogCollection.GetCategoryAppearances(LEGION_ARTIFACT_CATEGORY, transmogLocation)
                if appearances then
                    for _, appearance in ipairs(appearances) do
                        if appearance.isCollected and appearance.isUsable then
                            local sources = C_TransmogCollection.GetAppearanceSources(appearance.visualID, LEGION_ARTIFACT_CATEGORY, transmogLocation)
                            if sources then
                                for _, source in ipairs(sources) do
                                    if source.isCollected then
                                        table.insert(collectedAppearances, source.sourceID)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            -- For armor slots, use the standard category
            if categoryID then
                local appearances = C_TransmogCollection.GetCategoryAppearances(categoryID, transmogLocation)
                if appearances then
                    for _, appearance in ipairs(appearances) do
                        if appearance.isCollected and appearance.isUsable then
                            local sources = C_TransmogCollection.GetAppearanceSources(appearance.visualID, categoryID, transmogLocation)
                            if sources then
                                for _, source in ipairs(sources) do
                                    if source.isCollected then
                                        table.insert(collectedAppearances, source.sourceID)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if #collectedAppearances == 0 then
            if DEBUG_MODE then
                if DEBUG_MODE then
                    print("|cFFFF0000[DEBUG]|r Slot " .. slotID .. ": No collected appearances found!")
                end
            end
            return nil
        end
        
        local selected = collectedAppearances[math.random(#collectedAppearances)]
        if DEBUG_MODE then
            if DEBUG_MODE then
                print("|cFF00FF00[DEBUG]|r Slot " .. slotID .. ": Found " .. #collectedAppearances .. " appearances, selected source " .. selected)
            end
        end
        return selected
    end
    
local function RandomizeTransmog(instant)
    if DEBUG_MODE then
        local _, class = UnitClass("player")
        local race = UnitRace("player")
        local level = UnitLevel("player")
        if DEBUG_MODE then
            print("|cFFFFFF00[DEBUG]|r Starting RandomizeTransmog - Class: " .. (class or "Unknown") .. ", Race: " .. (race or "Unknown") .. ", Level: " .. level)
            print("|cFFFFFF00[DEBUG]|r Instant mode: " .. tostring(instant))
        end
    end
    
    if instant then
        -- Instant mode (for slash command)
        local changedCount = 0
        local attemptedCount = 0
        local failedSlots = {}
        
        for _, slotID in ipairs(transmogSlots) do
            -- Skip shoulders in main loop, handle them after
            if slotID == 3 then
                -- Do nothing here, we'll handle shoulders after the loop
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFF888888[DEBUG]|r Skipping shoulder slot (handled separately)")
                    end
                end
            elseif db.selectedSlots[slotID] then
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFF00FFFF[DEBUG]|r Processing slot " .. slotID .. " (" .. (slotNames[slotID] or "Unknown") .. ")")
                    end
                end
                local transmogLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
                
                if transmogLocation then
                    local randomSource = GetRandomSourceForSlot(slotID)
                    
                    if randomSource then
                        attemptedCount = attemptedCount + 1
                        local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, randomSource)
                        local success = C_Transmog.SetPending(transmogLocation, pendingInfo)
                        if DEBUG_MODE then
                            if DEBUG_MODE then
                                print("|cFFFFFF00[DEBUG]|r Slot " .. slotID .. ": source=" .. randomSource .. ", success=" .. tostring(success))
                            end
                        end
                        -- Count as successful even if SetPending returns nil (WoW API quirk)
                        changedCount = changedCount + 1
                        
                        -- If this is a weapon slot and enchant is selected, also randomize the illusion
                        if (slotID == 16 or slotID == 17) and db.selectedSlots[slotID .. "_enchant"] then
                            local illusionLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Illusion, Enum.TransmogModification.Main)
                            if illusionLocation then
                                -- Check if the weapon can have an illusion
                                local canTransmog, cannotReason = C_Transmog.GetSlotInfo(illusionLocation)
                                if canTransmog then
                                    local randomIllusion = GetRandomIllusion()
                                    if randomIllusion then
                                        local illusionPending = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, randomIllusion)
                                        C_Transmog.SetPending(illusionLocation, illusionPending)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Now handle shoulders separately
        local secondaryShoulderButton = WardrobeTransmogFrame and WardrobeTransmogFrame["SecondaryShoulderButton"]
        local splitShouldersEnabled = secondaryShoulderButton and secondaryShoulderButton:IsShown()
        
        -- Handle left shoulder
        -- When split shoulders is enabled, ONLY check 3_left (ignore slot 3)
        -- When split shoulders is disabled, ONLY check slot 3 (ignore 3_left and 3_right)
        local shouldProcessLeft = false
        local shouldProcessRight = false
        
        if splitShouldersEnabled then
            -- Split mode: ONLY use 3_left and 3_right, completely ignore slot 3
            shouldProcessLeft = db.selectedSlots["3_left"]
            shouldProcessRight = db.selectedSlots["3_right"]
        else
            -- Single mode: ONLY use slot 3, completely ignore 3_left and 3_right
            shouldProcessLeft = db.selectedSlots[3]
            shouldProcessRight = false  -- In single mode, we don't process right separately
        end
        if shouldProcessLeft then
            local transmogLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            if transmogLocation then
                local source = GetRandomSourceForSlot(3, Enum.TransmogModification.Main)
                if source then
                    attemptedCount = attemptedCount + 1
                    local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, source)
                    C_Transmog.SetPending(transmogLocation, pendingInfo)
                    -- Count as successful even if SetPending returns nil (WoW API quirk)
                    changedCount = changedCount + 1
                end
            end
        end
        
        -- Handle right shoulder if enabled
        if shouldProcessRight then
            local transmogLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary)
            if transmogLocation then
                -- Get a different source than left shoulder (using Main pool)
                local source = nil
                local attempts = 0
                local leftSource = nil
                
                -- Get what was set for left shoulder
                if shouldProcessLeft then
                    local leftLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
                    leftSource = C_Transmog.GetPending(leftLocation)
                    if leftSource then
                        leftSource = leftSource.appliedSourceID
                    end
                end
                
                repeat
                    source = GetRandomSourceForSlot(3, Enum.TransmogModification.Main)
                    attempts = attempts + 1
                until (source ~= leftSource) or attempts > 10 or not leftSource
                
                if source then
                    attemptedCount = attemptedCount + 1
                    local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, source)
                    C_Transmog.SetPending(transmogLocation, pendingInfo)
                    -- Count as successful even if SetPending returns nil (WoW API quirk)
                    changedCount = changedCount + 1
                end
            end
        end
        
        -- Just set pending changes for preview, don't apply (purchase)!
        if attemptedCount > 0 then
            -- Force update of transmog UI to show the changes
            if WardrobeTransmogFrame then
                C_Timer.After(0.1, function()
                    if WardrobeTransmogFrame.Update then
                        WardrobeTransmogFrame:Update()
                    end
                end)
            end
            if DEBUG_MODE then
                if DEBUG_MODE then
                    print("|cFFFFFF00[DEBUG]|r Final counts - Attempted: " .. attemptedCount .. ", Changed: " .. changedCount)
                end
            end
            if DEBUG_MODE then
                print("|cFF00FF00RandomMog:|r Randomization complete! Preview updated.")
            end
        else
            if DEBUG_MODE then
                print("|cFFFFFF00RandomMog:|r No eligible slots found for randomization.")
            end
        end
    else
        -- Animated mode with delay (for button)
        local slotIndex = 1
        local changedCount = 0
        local attemptedCount = 0
        
        if DEBUG_MODE then
            if DEBUG_MODE then
                print("|cFFFFFF00[DEBUG]|r Starting animated mode, processing " .. #transmogSlots .. " slots")
            end
            -- Print which slots are selected
            local selectedList = {}
            for k, v in pairs(db.selectedSlots) do
                if v == true then
                    table.insert(selectedList, tostring(k))
                end
            end
            if DEBUG_MODE then
                print("|cFFFFFF00[DEBUG]|r Selected slots: " .. table.concat(selectedList, ", "))
            end
        end
        
        local function ProcessNextSlot()
            if slotIndex > #transmogSlots then
                -- All slots processed, show completion message
                C_Timer.After(0.1, function()
                    if DEBUG_MODE then
                        if DEBUG_MODE then
                    print("|cFFFFFF00[DEBUG]|r Final counts - Attempted: " .. attemptedCount .. ", Changed: " .. changedCount)
                end
                    end
                    if attemptedCount > 0 then
                        if DEBUG_MODE then
                print("|cFF00FF00RandomMog:|r Randomization complete! Preview updated.")
            end
                    else
                        if DEBUG_MODE then
                print("|cFFFFFF00RandomMog:|r No eligible slots found for randomization.")
            end
                    end
                end)
                return
            end
            
            local slotID = transmogSlots[slotIndex]
            
            if not slotID then
                slotIndex = slotIndex + 1
                C_Timer.After(0.01, ProcessNextSlot)
                return
            end
            
            -- Handle shoulders specially
            if slotID == 3 then
                local secondaryShoulderButton = WardrobeTransmogFrame and WardrobeTransmogFrame["SecondaryShoulderButton"]
                local splitShouldersEnabled = secondaryShoulderButton and secondaryShoulderButton:IsShown()
                local processedShoulder = false
                local leftShoulderSource = nil
                
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Split shoulders enabled: " .. tostring(splitShouldersEnabled))
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Slot 3 checked: " .. tostring(db.selectedSlots[3]))
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Slot 3_left checked: " .. tostring(db.selectedSlots["3_left"]))
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Slot 3_right checked: " .. tostring(db.selectedSlots["3_right"]))
                    end
                end
                
                -- Handle left shoulder
                -- When split shoulders is enabled, ONLY check 3_left (ignore slot 3)
                -- When split shoulders is disabled, ONLY check slot 3 (ignore 3_left and 3_right)
                local shouldProcessLeft = false
                local shouldProcessRight = false
                
                if splitShouldersEnabled then
                    -- Split mode: ONLY use 3_left and 3_right, completely ignore slot 3
                    shouldProcessLeft = db.selectedSlots["3_left"]
                    shouldProcessRight = db.selectedSlots["3_right"]
                else
                    -- Single mode: ONLY use slot 3, completely ignore 3_left and 3_right
                    -- In single mode, setting Main affects both shoulders automatically
                    shouldProcessLeft = db.selectedSlots[3]
                    shouldProcessRight = false  -- In single mode, we don't process right separately
                end
                
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Should process left: " .. tostring(shouldProcessLeft))
                    end
                end
                
                if shouldProcessLeft then
                    local transmogLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
                    if transmogLocation then
                        leftShoulderSource = GetRandomSourceForSlot(3, Enum.TransmogModification.Main)
                        if leftShoulderSource then
                            attemptedCount = attemptedCount + 1
                            local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, leftShoulderSource)
                            local result = C_Transmog.SetPending(transmogLocation, pendingInfo)
                            changedCount = changedCount + 1
                            processedShoulder = true
                            
                            -- In split mode, WoW handles each shoulder independently
                            -- We don't need to preserve the other shoulder
                        end
                    end
                end
                
                -- Handle right shoulder if split shoulders enabled (separate from left shoulder logic)
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG SHOULDER]|r Should process right: " .. tostring(shouldProcessRight))
                    end
                end
                
                if shouldProcessRight then
                    local rightLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary)
                    if rightLocation then
                        local rightShoulderSource = nil
                        local attempts = 0
                        repeat
                            rightShoulderSource = GetRandomSourceForSlot(3, Enum.TransmogModification.Main)
                            attempts = attempts + 1
                        until (rightShoulderSource ~= leftShoulderSource) or attempts > 10 or not leftShoulderSource
                        
                        if rightShoulderSource then
                            attemptedCount = attemptedCount + 1
                            local rightPending = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, rightShoulderSource)
                            local result = C_Transmog.SetPending(rightLocation, rightPending)
                            changedCount = changedCount + 1
                            processedShoulder = true
                            
                            -- In split mode, WoW handles each shoulder independently
                            -- We don't need to preserve the other shoulder
                        end
                    end
                end
                
                slotIndex = slotIndex + 1
                if processedShoulder then
                    C_Timer.After(0.1, ProcessNextSlot)  -- Standard delay if we processed shoulders
                else
                    C_Timer.After(0.01, ProcessNextSlot)  -- Quick skip if no shoulders to process
                end
                return
            elseif not db.selectedSlots[slotID] then
                -- Skip if slot is not selected
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFF888888[DEBUG]|r Skipping unselected slot " .. slotID .. " (" .. (slotNames[slotID] or "Unknown") .. ")")
                    end
                end
                slotIndex = slotIndex + 1
                C_Timer.After(0.01, ProcessNextSlot)
                return
            else
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFF00FFFF[DEBUG]|r Processing slot " .. slotID .. " (" .. (slotNames[slotID] or "Unknown") .. ")")
                    end
                end
                local transmogLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
                
                if transmogLocation then
                    local randomSource = GetRandomSourceForSlot(slotID)
                    
                    if randomSource then
                        attemptedCount = attemptedCount + 1
                        local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, randomSource)
                        local success = C_Transmog.SetPending(transmogLocation, pendingInfo)
                        if DEBUG_MODE then
                            if DEBUG_MODE then
                                print("|cFFFFFF00[DEBUG]|r Slot " .. slotID .. " (" .. (slotNames[slotID] or "Unknown") .. "): source=" .. randomSource .. ", success=" .. tostring(success))
                            end
                        end
                        -- Count as successful even if SetPending returns nil (WoW API quirk)
                        changedCount = changedCount + 1
                        
                        -- If this is a weapon slot and enchant is selected, also randomize the illusion
                        if (slotID == 16 or slotID == 17) and db.selectedSlots[slotID .. "_enchant"] then
                            local illusionLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Illusion, Enum.TransmogModification.Main)
                            if illusionLocation then
                                -- Check if the weapon can have an illusion
                                local canTransmog, cannotReason = C_Transmog.GetSlotInfo(illusionLocation)
                                if canTransmog then
                                    local randomIllusion = GetRandomIllusion()
                                    if randomIllusion then
                                        local illusionPending = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, randomIllusion)
                                        C_Transmog.SetPending(illusionLocation, illusionPending)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            slotIndex = slotIndex + 1
            C_Timer.After(0.1, ProcessNextSlot)  -- 100ms delay between slots
        end
        
        ProcessNextSlot()
    end
end

local function CreateRandomButton()
    if button then 
        button:Show()
        return 
    end
    
    button = CreateFrame("Button", "RandomMogButton", WardrobeTransmogFrame, "UIPanelButtonTemplate")
    button:SetSize(80, 22)
    button:SetText("Random!")
    
    -- Apply ElvUI skinning if available
    local ElvUI = _G.ElvUI
    if ElvUI then
        local E = ElvUI[1]
        if E and E.GetModule then
            local S = E:GetModule('Skins', true)
            if S and S.HandleButton then
                S:HandleButton(button)
            end
        end
    end
    
    -- Check if ElvUI or BetterWardrobe is loaded and adjust position
    local ElvUILoaded = _G.ElvUI and true or false
    if C_AddOns.IsAddOnLoaded("BetterWardrobe") then
        -- BetterWardrobe modifies the frame, shift our buttons left to avoid overlap
        -- Moving left by about 60 pixels (width of None button + spacing)
        if ElvUILoaded then
            button:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "BOTTOMRIGHT", -65, 5)
        else
            button:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "BOTTOMRIGHT", -65, 10)
        end
    else
        -- Standard position when BetterWardrobe is not present
        if ElvUILoaded then
            button:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", 0, 5)
        else
            button:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", 0, 10)
        end
    end
    
    button:SetFrameStrata("HIGH")
    button:SetFrameLevel(100)
    button:EnableMouse(true)
    button:Show()
    
    button:SetScript("OnClick", function()
        if IsShiftKeyDown() then
            -- Shift-click for instant randomization
            RandomizeTransmog(true)
        else
            -- Normal click for animated randomization
            RandomizeTransmog()
        end
    end)
    
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("RandomMog", 1, 1, 1)
        GameTooltip:AddLine("Click to randomize selected slots", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("Shift-Click for instant randomization", 0.8, 0.8, 0.8, true)
        
        -- Show which slots are selected
        local selectedSlots = {}
        for _, slotID in ipairs(transmogSlots) do
            if db.selectedSlots[slotID] then
                table.insert(selectedSlots, slotNames[slotID])
            end
        end
        
        if #selectedSlots > 0 then
            GameTooltip:AddLine("Selected: " .. table.concat(selectedSlots, ", "), 0.6, 1, 0.6, true)
        else
            GameTooltip:AddLine("No slots selected!", 1, 0.3, 0.3, true)
        end
        
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function CreateSelectionButtons()
    if selectAllButton and deselectAllButton then
        selectAllButton:Show()
        deselectAllButton:Show()
        return
    end
    
    -- Select All button
    selectAllButton = CreateFrame("Button", "RandomMogSelectAll", WardrobeTransmogFrame, "UIPanelButtonTemplate")
    selectAllButton:SetSize(50, 22)
    selectAllButton:SetText("All")
    
    -- Apply ElvUI skinning if available
    local ElvUI = _G.ElvUI
    if ElvUI then
        local E = ElvUI[1]
        if E and E.GetModule then
            local S = E:GetModule('Skins', true)
            if S and S.HandleButton then
                S:HandleButton(selectAllButton)
            end
        end
    end
    
    -- Adjust position based on BetterWardrobe presence
    if C_AddOns.IsAddOnLoaded("BetterWardrobe") then
        selectAllButton:SetPoint("RIGHT", RandomMogButton, "LEFT", -5, 0)
    else
        selectAllButton:SetPoint("RIGHT", RandomMogButton, "LEFT", -5, 0)
    end
    
    selectAllButton:SetFrameStrata("HIGH")
    selectAllButton:SetFrameLevel(100)
    
    selectAllButton:SetScript("OnClick", SelectAllSlots)
    
    selectAllButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Select All Slots", 1, 1, 1)
        GameTooltip:AddLine("Enable randomization for all equipment slots", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    
    selectAllButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Deselect All button
    deselectAllButton = CreateFrame("Button", "RandomMogDeselectAll", WardrobeTransmogFrame, "UIPanelButtonTemplate")
    deselectAllButton:SetSize(50, 22)
    deselectAllButton:SetText("None")
    
    -- Apply ElvUI skinning if available
    local ElvUI = _G.ElvUI
    if ElvUI then
        local E = ElvUI[1]
        if E and E.GetModule then
            local S = E:GetModule('Skins', true)
            if S and S.HandleButton then
                S:HandleButton(deselectAllButton)
            end
        end
    end
    deselectAllButton:SetPoint("LEFT", RandomMogButton, "RIGHT", 5, 0)
    deselectAllButton:SetFrameStrata("HIGH")
    deselectAllButton:SetFrameLevel(100)
    
    deselectAllButton:SetScript("OnClick", DeselectAllSlots)
    
    deselectAllButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Deselect All Slots", 1, 1, 1)
        GameTooltip:AddLine("Disable randomization for all equipment slots", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    
    deselectAllButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end


-- Initialize SavedVariables
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        -- Initialize SavedVariables
        RandomMogDB = RandomMogDB or {}
        db = RandomMogDB
        
        -- Initialize missing values with defaults
        if not db.selectedSlots then
            db.selectedSlots = {}
        end
        for slotID, defaultValue in pairs(defaults.selectedSlots) do
            if db.selectedSlots[slotID] == nil then
                db.selectedSlots[slotID] = defaultValue
            end
        end
        
        
    elseif event == "ADDON_LOADED" and loadedAddon == "Blizzard_Collections" then
        if WardrobeTransmogFrame then
            WardrobeTransmogFrame.RandomMogHooked = true  -- Mark that we've hooked it
            WardrobeTransmogFrame:HookScript("OnShow", function()
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG]|r WardrobeTransmogFrame OnShow - recreating UI")
                    end
                end
                CreateRandomButton()
                CreateSelectionButtons()
                -- Always recreate checkboxes when showing transmog window
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG]|r About to call CreateSlotCheckboxes")
                    end
                end
                local success, err = pcall(CreateSlotCheckboxes)
                if not success then
                    if DEBUG_MODE then
                        print("|cFFFF0000[ERROR]|r CreateSlotCheckboxes failed: " .. tostring(err))
                    end
                end
                -- Update checkbox states to match current character's saved values
                if DEBUG_MODE then
                    if DEBUG_MODE then
                        print("|cFFFF00FF[DEBUG]|r About to call UpdateCheckboxStates")
                    end
                end
                local success2, err2 = pcall(UpdateCheckboxStates)
                if not success2 then
                    if DEBUG_MODE then
                        print("|cFFFF0000[ERROR]|r UpdateCheckboxStates failed: " .. tostring(err2))
                    end
                end
                
                -- Hook the SecondaryShoulderButton to detect when it becomes visible
                local secondaryButton = WardrobeTransmogFrame.SecondaryShoulderButton
                if secondaryButton then
                    secondaryButton:HookScript("OnShow", function()
                        if DEBUG_MODE then
                            if DEBUG_MODE then
                                print("|cFF00FF00RandomMog:|r Split shoulders enabled - recreating shoulder checkboxes")
                            end
                        end
                        
                        -- Hide and remove the single shoulder checkbox
                        if slotCheckboxes[3] then
                            slotCheckboxes[3]:Hide()
                            if slotCheckboxes[3]:GetParent() then
                                slotCheckboxes[3]:GetParent():Hide()
                            end
                            slotCheckboxes[3] = nil
                        end
                        
                        -- Create left shoulder checkbox on the main shoulder button
                        local shoulderButton = WardrobeTransmogFrame.ShoulderButton
                        if shoulderButton and not slotCheckboxes["3_left"] then
                            local leftCheckbox = CreateSlotCheckbox(shoulderButton, 3, false)
                            slotCheckboxes["3_left"] = leftCheckbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots["3_left"] ~= nil then
                                leftCheckbox:SetChecked(db.selectedSlots["3_left"])
                            end
                            -- Ensure checkbox is shown
                            leftCheckbox:Show()
                            if leftCheckbox.bgFrame then
                                leftCheckbox.bgFrame:Show()
                            end
                        end
                        
                        -- Create right shoulder checkbox on the secondary button
                        if not slotCheckboxes["3_right"] then
                            local rightCheckbox = CreateSlotCheckbox(secondaryButton, 3, true)
                            slotCheckboxes["3_right"] = rightCheckbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots["3_right"] ~= nil then
                                rightCheckbox:SetChecked(db.selectedSlots["3_right"])
                            end
                            -- Ensure checkbox is shown
                            rightCheckbox:Show()
                            if rightCheckbox.bgFrame then
                                rightCheckbox.bgFrame:Show()
                            end
                        else
                            -- Show existing checkbox
                            slotCheckboxes["3_right"]:Show()
                            if slotCheckboxes["3_right"].bgFrame then
                                slotCheckboxes["3_right"].bgFrame:Show()
                            end
                        end
                    end)
                    
                    secondaryButton:HookScript("OnHide", function()
                        if DEBUG_MODE then
                            print("|cFFFFFF00RandomMog:|r Split shoulders disabled - recreating single checkbox")
                        end
                        
                        -- Hide both split shoulder checkboxes
                        if slotCheckboxes["3_left"] then
                            slotCheckboxes["3_left"]:Hide()
                            if slotCheckboxes["3_left"]:GetParent() then
                                slotCheckboxes["3_left"]:GetParent():Hide()
                            end
                            slotCheckboxes["3_left"] = nil
                        end
                        if slotCheckboxes["3_right"] then
                            slotCheckboxes["3_right"]:Hide()
                            if slotCheckboxes["3_right"]:GetParent() then
                                slotCheckboxes["3_right"]:GetParent():Hide()
                            end
                            slotCheckboxes["3_right"] = nil
                        end
                        
                        -- Recreate the single shoulder checkbox
                        local shoulderButton = WardrobeTransmogFrame.ShoulderButton
                        if shoulderButton and not slotCheckboxes[3] then
                            local checkbox = CreateSlotCheckbox(shoulderButton, 3)  -- nil for isRightShoulder creates slot 3
                            slotCheckboxes[3] = checkbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots[3] ~= nil then
                                checkbox:SetChecked(db.selectedSlots[3])
                            end
                        end
                    end)
                end
            end)
            
            WardrobeTransmogFrame:HookScript("OnHide", function()
                -- Hide checkboxes when window closes
                for _, checkbox in pairs(slotCheckboxes) do
                    if checkbox then
                        checkbox:Hide()
                        if checkbox.bgFrame then
                            checkbox.bgFrame:Hide()
                        end
                    end
                end
            end)
        end
        self:UnregisterEvent("ADDON_LOADED")
        
    elseif event == "PLAYER_LOGIN" then
        -- If Blizzard_Collections was already loaded at login, set up the hooks
        if C_AddOns.IsAddOnLoaded("Blizzard_Collections") and WardrobeTransmogFrame then
            -- Check if we already hooked it in ADDON_LOADED
            if not WardrobeTransmogFrame.RandomMogHooked then
                WardrobeTransmogFrame.RandomMogHooked = true
                WardrobeTransmogFrame:HookScript("OnShow", function()
                    if DEBUG_MODE then
                        if DEBUG_MODE then
                            print("|cFFFF00FF[DEBUG]|r WardrobeTransmogFrame OnShow - recreating UI (from PLAYER_LOGIN)")
                        end
                    end
                    CreateRandomButton()
                    CreateSelectionButtons()
                    CreateSlotCheckboxes()
                    UpdateCheckboxStates()  -- This was missing!
                    
                    -- Hook the SecondaryShoulderButton to detect when it becomes visible
                    local secondaryButton = WardrobeTransmogFrame.SecondaryShoulderButton
                    if secondaryButton then
                        secondaryButton:HookScript("OnShow", function()
                        if DEBUG_MODE then
                            if DEBUG_MODE then
                                print("|cFF00FF00RandomMog:|r Split shoulders enabled - recreating shoulder checkboxes")
                            end
                        end
                        
                        -- Hide and remove the single shoulder checkbox
                        if slotCheckboxes[3] then
                            slotCheckboxes[3]:Hide()
                            if slotCheckboxes[3]:GetParent() then
                                slotCheckboxes[3]:GetParent():Hide()
                            end
                            slotCheckboxes[3] = nil
                        end
                        
                        -- Create left shoulder checkbox on the main shoulder button
                        local shoulderButton = WardrobeTransmogFrame.ShoulderButton
                        if shoulderButton and not slotCheckboxes["3_left"] then
                            local leftCheckbox = CreateSlotCheckbox(shoulderButton, 3, false)
                            slotCheckboxes["3_left"] = leftCheckbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots["3_left"] ~= nil then
                                leftCheckbox:SetChecked(db.selectedSlots["3_left"])
                            end
                            -- Ensure checkbox is shown
                            leftCheckbox:Show()
                            if leftCheckbox.bgFrame then
                                leftCheckbox.bgFrame:Show()
                            end
                        end
                        
                        -- Create right shoulder checkbox on the secondary button
                        if not slotCheckboxes["3_right"] then
                            local rightCheckbox = CreateSlotCheckbox(secondaryButton, 3, true)
                            slotCheckboxes["3_right"] = rightCheckbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots["3_right"] ~= nil then
                                rightCheckbox:SetChecked(db.selectedSlots["3_right"])
                            end
                            -- Ensure checkbox is shown
                            rightCheckbox:Show()
                            if rightCheckbox.bgFrame then
                                rightCheckbox.bgFrame:Show()
                            end
                        else
                            -- Show existing checkbox
                            slotCheckboxes["3_right"]:Show()
                            if slotCheckboxes["3_right"].bgFrame then
                                slotCheckboxes["3_right"].bgFrame:Show()
                            end
                        end
                    end)
                    
                    secondaryButton:HookScript("OnHide", function()
                        if DEBUG_MODE then
                            print("|cFFFFFF00RandomMog:|r Split shoulders disabled - recreating single checkbox")
                        end
                        
                        -- Hide both split shoulder checkboxes
                        if slotCheckboxes["3_left"] then
                            slotCheckboxes["3_left"]:Hide()
                            if slotCheckboxes["3_left"]:GetParent() then
                                slotCheckboxes["3_left"]:GetParent():Hide()
                            end
                            slotCheckboxes["3_left"] = nil
                        end
                        if slotCheckboxes["3_right"] then
                            slotCheckboxes["3_right"]:Hide()
                            if slotCheckboxes["3_right"]:GetParent() then
                                slotCheckboxes["3_right"]:GetParent():Hide()
                            end
                            slotCheckboxes["3_right"] = nil
                        end
                        
                        -- Recreate the single shoulder checkbox
                        local shoulderButton = WardrobeTransmogFrame.ShoulderButton
                        if shoulderButton and not slotCheckboxes[3] then
                            local checkbox = CreateSlotCheckbox(shoulderButton, 3)  -- nil for isRightShoulder creates slot 3
                            slotCheckboxes[3] = checkbox
                            -- Set the checkbox state from saved values
                            if db and db.selectedSlots[3] ~= nil then
                                checkbox:SetChecked(db.selectedSlots[3])
                            end
                        end
                    end)
                    end
                end)
                
                WardrobeTransmogFrame:HookScript("OnHide", function()
                    for _, checkbox in pairs(slotCheckboxes) do
                        if checkbox then
                            checkbox:Hide()
                            if checkbox.bgFrame then
                                checkbox.bgFrame:Hide()
                            end
                        end
                    end
                end)
            end
        else
            self:RegisterEvent("ADDON_LOADED")
        end
    end
end)

SLASH_RANDOMMOG1 = "/randommog"
SLASH_RANDOMMOG2 = "/rm"
SlashCmdList["RANDOMMOG"] = function(msg)
    if msg == "debug" then
        -- Toggle debug mode
        DEBUG_MODE = not DEBUG_MODE
        print("|cFF00FF00RandomMog:|r Debug mode " .. (DEBUG_MODE and "ENABLED" or "DISABLED"))
    elseif msg == "slots" then
        -- Debug slot selections
        print("|cFF00FF00RandomMog Debug:|r Current slot selections:")
        for slotID, enabled in pairs(db.selectedSlots) do
            if enabled then
                local name = slotNames[slotID] or tostring(slotID)
                print("  - " .. name .. " [" .. tostring(slotID) .. "]: ENABLED")
            end
        end
        return
    elseif msg == "reset" then
        -- Reset all slot selections to defaults
        print("|cFFFFFF00RandomMog:|r Resetting slot selections to defaults...")
        for slotID, defaultValue in pairs(defaults.selectedSlots) do
            db.selectedSlots[slotID] = defaultValue
        end
        if WardrobeTransmogFrame and WardrobeTransmogFrame:IsShown() then
            UpdateCheckboxStates()
        end
        print("|cFF00FF00RandomMog:|r Slot selections reset!")
        return
    elseif msg:match("^test%s+(%d+)") then
        -- Test a specific slot
        local slotID = tonumber(msg:match("^test%s+(%d+)"))
        if not WardrobeTransmogFrame or not WardrobeTransmogFrame:IsShown() then
            print("|cFFFF0000RandomMog:|r Please open the transmog window first!")
            return
        end
        print("|cFFFFFF00RandomMog:|r Testing slot " .. slotID .. " (" .. (slotNames[slotID] or "Unknown") .. ")")
        
        local transmogLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
        if not transmogLocation then
            print("|cFFFF0000RandomMog:|r Cannot create transmog location for slot " .. slotID)
            return
        end
        
        local canTransmog, reason = C_Transmog.GetSlotInfo(transmogLocation)
        print("  Can transmog: " .. tostring(canTransmog) .. ", Reason: " .. tostring(reason))
        
        local currentSource = C_Transmog.GetSlotVisualInfo(transmogLocation)
        print("  Current source: " .. tostring(currentSource))
        
        -- Try to get a random source
        local randomSource = GetRandomSourceForSlot(slotID)
        if randomSource then
            print("  Random source found: " .. randomSource)
            local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, randomSource)
            local success = C_Transmog.SetPending(transmogLocation, pendingInfo)
            print("  SetPending result: " .. tostring(success))
            if success and WardrobeTransmogFrame.Update then
                WardrobeTransmogFrame:Update()
            end
        else
            print("  No random source found!")
        end
        return
    elseif msg == "trace" then
        -- Trace transmog events
        print("|cFF00FF00RandomMog:|r Starting event trace. Change the right shoulder manually to see what happens.")
        
        local eventFrame = CreateFrame("Frame")
        local events = {
            "TRANSMOGRIFY_UPDATE",
            "TRANSMOGRIFY_SUCCESS", 
            "TRANSMOG_COLLECTION_UPDATED",
            "TRANSMOG_COLLECTION_SOURCE_ADDED",
            "TRANSMOG_COLLECTION_SOURCE_REMOVED",
            "PLAYER_EQUIPMENT_CHANGED"
        }
        
        for _, event in ipairs(events) do
            eventFrame:RegisterEvent(event)
        end
        
        eventFrame:SetScript("OnEvent", function(self, event, ...)
            local args = {...}
            print("|cFFFFFF00Event:|r " .. event .. " Args: " .. table.concat(args, ", "))
        end)
        
        -- Hook C_Transmog functions to see what gets called
        local origSetPending = C_Transmog.SetPending
        C_Transmog.SetPending = function(location, pending)
            print("|cFF00FFFF[SetPending Called]|r SlotID=" .. tostring(location.slotID) .. 
                  ", Mod=" .. tostring(location.modification) .. 
                  ", Pending=" .. tostring(pending and pending.type or "nil"))
            return origSetPending(location, pending)
        end
        
        -- Hook the SecondaryShoulderButton click
        local secondaryButton = WardrobeTransmogFrame.SecondaryShoulderButton
        if secondaryButton then
            secondaryButton:HookScript("OnClick", function(self, button)
                print("|cFF00FF00[SecondaryShoulderButton Clicked]|r Button: " .. tostring(button))
            end)
            
            -- Check what methods the button has
            print("|cFFFFFF00SecondaryShoulderButton methods:|r")
            for k, v in pairs(getmetatable(secondaryButton).__index) do
                if type(v) == "function" and k:match("Transmog") then
                    print("  " .. k)
                end
            end
        end
        
        print("|cFF00FF00Trace started.|r Now manually change the right shoulder to see what happens.")
        
        C_Timer.After(30, function()
            eventFrame:UnregisterAllEvents()
            C_Transmog.SetPending = origSetPending
            print("|cFFFF0000Trace stopped after 30 seconds.|r")
        end)
        
    elseif msg == "debug" then
        -- Debug mode to show slot information
        print("|cFF00FF00RandomMog Debug:|r Showing transmog slot information")
        
        if not WardrobeTransmogFrame or not WardrobeTransmogFrame:IsShown() then
            print("|cFFFF0000RandomMog:|r Please open the transmog window first for debug!")
            return
        end
        
        -- Check all transmog slot buttons
        print("|cFFFFFF00Checking All Transmog Buttons:|r")
        
        -- Check specific known buttons
        local buttonsToCheck = {
            "HeadButton", "ShoulderButton", "SecondaryShoulderButton", "BackButton", 
            "ChestButton", "ShirtButton", "TabardButton", "WristButton", 
            "HandsButton", "WaistButton", "LegsButton", "FeetButton",
            "MainHandButton", "SecondaryHandButton"
        }
        
        for _, buttonName in ipairs(buttonsToCheck) do
            local button = WardrobeTransmogFrame[buttonName]
            if button then
                print("  " .. buttonName .. " exists, Shown: " .. tostring(button:IsShown()))
                if button.transmogLocation then
                    print("    TransmogLocation: SlotID=" .. tostring(button.transmogLocation.slotID) .. 
                          ", Modification=" .. tostring(button.transmogLocation.modification))
                end
            else
                if buttonName == "SecondaryShoulderButton" then
                    print("  " .. buttonName .. " does NOT exist (split shoulders not enabled?)")
                end
            end
        end
        
        -- Scan for ALL possible slot IDs (0-30 should cover everything, including slot 2)
        print("|cFFFFFF00Scanning All Possible Slot IDs (0-30):|r")
        local foundSlots = {}
        for slotID = 0, 30 do
            -- Try Main modification
            local mainLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
            if mainLocation then
                local mainSource = C_Transmog.GetSlotVisualInfo(mainLocation)
                local canTransmog, reason = C_Transmog.GetSlotInfo(mainLocation)
                if canTransmog or (mainSource and mainSource ~= 0) then
                    foundSlots[slotID] = foundSlots[slotID] or {}
                    foundSlots[slotID].main = true
                    foundSlots[slotID].mainSource = mainSource
                end
            end
            
            -- Try Secondary modification
            local secondaryLocation = TransmogUtil.GetTransmogLocation(slotID, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary)
            if secondaryLocation then
                local secondarySource = C_Transmog.GetSlotVisualInfo(secondaryLocation)
                local canTransmog, reason = C_Transmog.GetSlotInfo(secondaryLocation)
                if canTransmog or (secondarySource and secondarySource ~= 0) then
                    foundSlots[slotID] = foundSlots[slotID] or {}
                    foundSlots[slotID].secondary = true
                    foundSlots[slotID].secondarySource = secondarySource
                end
            end
        end
        
        -- Report found slots
        for slotID, data in pairs(foundSlots) do
            local slotName = slotNames[slotID] or "Unknown"
            print("  Slot " .. slotID .. " (" .. slotName .. "):")
            if data.main then
                print("    Main: Source=" .. tostring(data.mainSource or "none"))
            end
            if data.secondary then
                print("    Secondary: Source=" .. tostring(data.secondarySource or "none"))
            end
        end
        
        -- Test shoulder slots
        print("|cFFFFFF00Testing Shoulder Slots:|r")
        
        -- Left shoulder (Main)
        local leftLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
        if leftLocation then
            local leftSource = C_Transmog.GetSlotVisualInfo(leftLocation)
            print("  Left Shoulder (Main): SlotID=3, Modification=Main, CurrentSource=" .. tostring(leftSource or "none"))
            
            local canTransmog, reason = C_Transmog.GetSlotInfo(leftLocation)
            print("    Can Transmog: " .. tostring(canTransmog) .. ", Reason: " .. tostring(reason))
        end
        
        -- Right shoulder (Secondary)
        local rightLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary)
        if rightLocation then
            local rightSource = C_Transmog.GetSlotVisualInfo(rightLocation)
            print("  Right Shoulder (Secondary): SlotID=3, Modification=Secondary, CurrentSource=" .. tostring(rightSource or "none"))
            
            local canTransmog, reason = C_Transmog.GetSlotInfo(rightLocation)
            print("    Can Transmog: " .. tostring(canTransmog) .. ", Reason: " .. tostring(reason))
        end
        
        -- Check if they support different sources
        print("|cFFFFFF00Testing Random Sources:|r")
        local sources1, sources2  -- Define in outer scope
        local testCategoryID = C_TransmogCollection.GetAppearanceSourceInfo(C_Transmog.GetSlotVisualInfo(leftLocation))
        if testCategoryID then
            local appearances = C_TransmogCollection.GetCategoryAppearances(testCategoryID, leftLocation)
            if appearances and #appearances > 0 then
                print("  Found " .. #appearances .. " appearances for shoulders")
                
                -- Try setting different appearances
                for i, appearance in ipairs(appearances) do
                    if appearance.isCollected and appearance.isUsable then
                        local sources = C_TransmogCollection.GetAppearanceSources(appearance.visualID, testCategoryID, leftLocation)
                        if sources and #sources > 0 then
                            if not sources1 then
                                sources1 = sources[1].sourceID
                                print("  Test Source 1: " .. sources1)
                            elseif not sources2 and sources[1].sourceID ~= sources1 then
                                sources2 = sources[1].sourceID
                                print("  Test Source 2: " .. sources2)
                                break
                            end
                        end
                    end
                end
            end
        end
        
        -- Test actually setting different appearances
        print("|cFFFFFF00Testing Set Different Shoulders:|r")
        if sources1 and sources2 and leftLocation and rightLocation then
            print("  Attempting to set different appearances...")
            
            -- Check if we're actually in split mode
            local secondaryButton = WardrobeTransmogFrame.SecondaryShoulderButton
            if secondaryButton and secondaryButton:IsShown() then
                print("  Split mode is ACTIVE")
                
                -- Try using the button's SetPendingTransmog method if it exists
                local leftButton = WardrobeTransmogFrame.ShoulderButton
                if leftButton and leftButton.SetPendingTransmog then
                    print("  Using button's SetPendingTransmog method")
                    leftButton:SetPendingTransmog(sources1)
                    secondaryButton:SetPendingTransmog(sources2)
                else
                    -- Try standard method
                    local leftPending = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, sources1)
                    local leftSuccess = C_Transmog.SetPending(leftLocation, leftPending)
                    print("  Left shoulder set to " .. sources1 .. ": " .. tostring(leftSuccess))
                    
                    local rightPending = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, sources2)
                    local rightSuccess = C_Transmog.SetPending(rightLocation, rightPending)
                    print("  Right shoulder set to " .. sources2 .. ": " .. tostring(rightSuccess))
                end
            else
                print("  Split mode is NOT active - cannot set different shoulders")
            end
            
            -- Check what's actually pending
            C_Timer.After(0.1, function()
                local leftNow = C_Transmog.GetSlotVisualInfo(leftLocation)
                local rightNow = C_Transmog.GetSlotVisualInfo(rightLocation)
                print("  After setting - Left: " .. tostring(leftNow) .. ", Right: " .. tostring(rightNow))
                
                -- Also check pending info
                local leftPending = C_Transmog.GetPending(leftLocation)
                local rightPending = C_Transmog.GetPending(rightLocation)
                print("  Pending - Left: " .. tostring(leftPending) .. ", Right: " .. tostring(rightPending))
            end)
        end
        
        print("|cFF00FF00Debug complete!|r")
    elseif msg == "test" then
        -- Test different methods to set right shoulder
        if not WardrobeTransmogFrame or not WardrobeTransmogFrame:IsShown() then
            print("|cFFFF0000RandomMog:|r Please open the transmog window first!")
            return
        end
        
        local secondaryButton = WardrobeTransmogFrame.SecondaryShoulderButton
        if not secondaryButton or not secondaryButton:IsShown() then
            print("|cFFFF0000RandomMog:|r Secondary shoulder button not visible. Enable split shoulders first!")
            return
        end
        
        print("|cFF00FF00RandomMog:|r Testing right shoulder methods...")
        
        -- Method 1: Direct SetPending
        local rightLocation = TransmogUtil.GetTransmogLocation(3, Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary)
        local testSource = 1480  -- Use a known source ID
        
        print("Method 1: Direct SetPending with source " .. testSource)
        local pendingInfo = TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, testSource)
        C_Transmog.SetPending(rightLocation, pendingInfo)
        
        -- Method 2: Try clicking the button programmatically
        C_Timer.After(1, function()
            print("Method 2: Trying button click simulation")
            if secondaryButton.OnClick then
                secondaryButton:OnClick("LeftButton")
            end
        end)
        
        -- Method 3: Try using the button's own methods
        C_Timer.After(2, function()
            print("Method 3: Looking for button's own transmog methods")
            for k, v in pairs(secondaryButton) do
                if type(k) == "string" and (k:match("transmog") or k:match("Transmog") or k:match("pending") or k:match("Pending")) then
                    print("  Found: " .. k .. " = " .. tostring(v))
                end
            end
        end)
        
    elseif WardrobeTransmogFrame and WardrobeTransmogFrame:IsShown() then
        RandomizeTransmog(true)  -- Use instant mode for slash command
    else
        print("|cFFFF0000RandomMog:|r Please open the transmog window first!")
    end
end

if C_AddOns.IsAddOnLoaded("BetterWardrobe") then
    print("|cFF00FF00RandomMog|r loaded with BetterWardrobe compatibility mode! Both random buttons are available.")
else
    print("|cFF00FF00RandomMog|r loaded! Open transmog to see slot checkboxes. Use /rm or /randommog to randomize.")
end