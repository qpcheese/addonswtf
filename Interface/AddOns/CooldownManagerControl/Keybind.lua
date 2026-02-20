local addonName, addonTable = ...
local addon                 = addonTable.Core

local cmdToKB               = {}
local sltToCmd              = {}
local sltToCmdHash          = 0
local sltToKB               = {}
local sltToSpell            = {}
local spellToKeybind        = {}
local spellNameToKeybind    = {}

local cachedStateData       = {
    page = 1,
    bonusOffset = 0,
    form = 0,
    hash = 0,
    valid = false
}

--- Abbreviates a full keybinding string to a shorter format for display.
local function abreviateKeybing(key)
    local abrv = key
    abrv = abrv:gsub("ALT%-", "A")
    abrv = abrv:gsub("CTRL%-", "C")
    abrv = abrv:gsub("SHIFT%-", "S")
    abrv = abrv:gsub("NUMPAD", "NP")
    abrv = abrv:gsub("BUTTON", "B")
    abrv = abrv:gsub("MOUSEWHEELUP", "MWU")
    abrv = abrv:gsub("MOUSEWHEELDOWN", "MWD")
    return abrv
end

-- Update the cached state data for action bar page, bonus offset, and form and generate a corresponding hash
local function UpdateCachedState()
    cachedStateData.page = GetActionBarPage and GetActionBarPage() or 1
    cachedStateData.bonusOffset = GetBonusBarOffset and GetBonusBarOffset() or 0
    cachedStateData.form = GetShapeshiftFormID and GetShapeshiftFormID() or 0
    cachedStateData.hash = cachedStateData.page + (cachedStateData.bonusOffset * 100) + (cachedStateData.form * 10000)
    cachedStateData.valid = true
end

-- Retrieve the current hash of the cached state data
local function GetHashState()
    UpdateCachedState()
    return cachedStateData.hash
end

-- Calculate the action slot number of a specific bar type and button ID based on the current cached state
local function CalculateActionSlot(buttonID, barType)
    if not cachedStateData.valid then
        UpdateCachedState()
    end
    local page = 1

    -- Expansion-specific paging logic
    if barType == "main" then
        page = cachedStateData.page
        if cachedStateData.bonusOffset > 0 then
            page = 6 + cachedStateData.bonusOffset
        end
    elseif barType == "multibarbottomleft" then
        page = 5  -- Action Bar 2
    elseif barType == "multibarbottomright" then
        page = 6  -- Action Bar 3
    elseif barType == "multibarright" then
        page = 3  -- Action Bar 4
    elseif barType == "multibarleft" then
        page = 4  -- Action Bar 5
    elseif barType == "multibar5" then
        page = 13 -- Action Bar 6
    elseif barType == "multibar6" then
        page = 14 -- Action Bar 7
    elseif barType == "multibar7" then
        page = 15 -- Action Bar 8
    end

    local safePage = math.max(1, page)
    local safeButtonID = math.max(1, math.min(buttonID, 12))
    return safeButtonID + ((safePage - 1) * 12)
end

-- Map command strings to keybindings
local function mapCmdToKB(reset)
    if reset or not next(cmdToKB) then
        cmdToKB = {}
        local bars = {
            "ACTIONBUTTON",
            "MULTIACTIONBAR1BUTTON", -- Bar 2
            "MULTIACTIONBAR2BUTTON", -- Bar 3
            "MULTIACTIONBAR3BUTTON", -- Bar 4
            "MULTIACTIONBAR4BUTTON", -- Bar 5
            "MULTIACTIONBAR5BUTTON", -- Bar 6
            "MULTIACTIONBAR6BUTTON", -- Bar 7
            "MULTIACTIONBAR7BUTTON"  -- Bar 8
        }
        -- Get default UI bindings
        for i, bar in ipairs(bars) do
            for button = 1, 12 do
                local bindingKey = bar .. button
                cmdToKB[bindingKey] = GetBindingKey(bindingKey) or ""
            end
        end
    end
    return cmdToKB
end

-- Map action bar slots to command strings
local function mapSltToCmd(reset)
    if reset or not next(sltToCmd) then
        sltToCmd = {}
        local barMappings = {
            { barType = "main",                pattern = "ACTIONBUTTON" },
            { barType = "multibarbottomleft",  pattern = "MULTIACTIONBAR2BUTTON" },
            { barType = "multibarbottomright", pattern = "MULTIACTIONBAR1BUTTON" },
            { barType = "multibarright",       pattern = "MULTIACTIONBAR3BUTTON" },
            { barType = "multibarleft",        pattern = "MULTIACTIONBAR4BUTTON" },
            { barType = "multibar5",           pattern = "MULTIACTIONBAR5BUTTON" },
            { barType = "multibar6",           pattern = "MULTIACTIONBAR6BUTTON" },
            { barType = "multibar7",           pattern = "MULTIACTIONBAR7BUTTON" }
        }

        for _, barData in ipairs(barMappings) do
            for buttonID = 1, 12 do
                local slot = CalculateActionSlot(buttonID, barData.barType)
                sltToCmd[slot] = barData.pattern .. buttonID
            end
        end
    end
    sltToCmdHash = cachedStateData.hash
    return sltToCmd
end

--- Builds and refreshes internal keybinding lookup caches for spells and action bar slots.
---
--- This function can selectively rebuild:
--- - command → keybind mappings,
--- - slot → command mappings,
--- - slot → keybind mappings,
--- - spellID → keybind mappings,
--- depending on whether keybinds or action bar state has changed.
---
--- @param keybindReset boolean?  If true, keybinds are considered changed and command mappings are rebuilt.
--- @param forceRebuild boolean?  If true, forces a full rebuild of all mapping tables.
--- @param forceSlotReset boolean? If true, forces slot remapping.
---
--- @return nil
function addon:BuildKeybindCache(keybindReset, forceRebuild, forceSlotReset)
    local slotReset = false
    if forceSlotReset then
        UpdateCachedState()
        slotReset = true
    else
        local currentHash = GetHashState()
        if currentHash ~= sltToCmdHash then
            slotReset = true
        end
    end
    -- Generate or Reuse: Command to keybind map ("ACTIONBUTTON1" -> key)
    mapCmdToKB(keybindReset or forceRebuild)

    -- Generate or Reuse: Bar slot to command map (1 -> "ACTIONBUTTON1")
    mapSltToCmd(slotReset or forceRebuild)

    -- Generate or Reuse: Bar slot to keybind map
    if (forceRebuild or keybindReset or slotReset) or not next(sltToKB) then
        sltToKB = {}
        for slot, command in pairs(sltToCmd) do
            local keybind = cmdToKB[command] or ""
            sltToKB[slot] = keybind
        end
    end

    -- Generate or Reuse: Slot to spellID map & SpellID to keybind map & SpellName to keybind map
    if (forceRebuild or keybindReset or slotReset) or not next(spellToKeybind) then
        sltToSpell = {}
        spellToKeybind = {}
        --spellNameToKeybind = {}
        for slot, keybind in pairs(sltToKB) do
            local actionType, id = GetActionInfo(slot)
            local spellID
            if actionType == "spell" then
                spellID = id
            elseif actionType == "macro" then
                if C_Spell.GetSpellInfo(id) then
                    spellID = id
                else
                    spellID = GetMacroSpell(id)
                end
                --[[ local name, icon, body = GetMacroInfo(id)
                print("Macro detected in slot ", slot, " with id ", id, " with spellID ", spellID) ]]
            end
            if spellID then
                sltToSpell[slot] = spellID
                spellToKeybind[spellID] = keybind
                --local spellname = C_Spell.GetSpellInfo(spellID) or "Unknown"
                --spellNameToKeybind[spellname.name] = keybind
            end
        end
    end

    --[[ DevTool:AddData(cmdToKB, "cmdToKB")
    DevTool:AddData(sltToCmd, "slotToCmd")
    DevTool:AddData(sltToKB, "slotToKB")
    DevTool:AddData(sltToSpell, "slotToSpell")
    DevTool:AddData(spellToKeybind, "spellToKB") ]]

    --DevTool:AddData(spellNameToKeybind, "CMC_SpellNameToKeybind")
end

--- Updates the cached keybinding lookup for a single action bar slot.
---
--- Extracts the command and associated keybind for the slot, resolves its spellID,
--- and updates the spellID → keybind mapping if applicable.
---
--- @param slot number Action bar slot index to update.
---
--- @return nil
function addon:UpdateSlot(slot)
    local command = sltToCmd[slot]
    local keybind = cmdToKB[command] or ""
    local actionType, id = GetActionInfo(slot)
    local spellID
    if actionType == "spell" then
        spellID = id
    elseif actionType == "macro" then
        spellID = GetMacroSpell(id)
    end
    if spellID then
        spellToKeybind[spellID] = keybind
    end
end

--- Builds global lookup tables mapping cooldown IDs to spell information, and spellIDs back to cooldown IDs.
---
--- Scans a wide range of potential cooldownIDs, queries spell information,
--- and constructs both forward and reverse caches:
--- - `cooldownIDsCache[id] = { spellID, overrideSpellID, name }`
--- - `spellIDCache[spellID] = { cooldownID1, cooldownID2, ... }`
---
--- @return nil
function addon:BuildCooldownIDCache()
    addon.db.global.cooldownIDsCache = {}
    addon.db.global.spellIDCache = {}
    local cache = addon.db.global.cooldownIDsCache
    local reverseCache = addon.db.global.spellIDCache
    for i = 1, 200000, 1 do
        local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(i)
        if cooldownInfo and cooldownInfo.spellID then
            local spellID = cooldownInfo.spellID
            local overrideSpellID = C_Spell.GetOverrideSpell(spellID)
            local nameT = C_Spell.GetSpellInfo(cooldownInfo.spellID) or "Unknown"
            cache[i] = {
                spellID = cooldownInfo.spellID,
                overrideSpellID = (overrideSpellID and overrideSpellID ~= 0) and overrideSpellID or nil,
                name = nameT and nameT.name or "Unknown",
            }
            reverseCache[spellID] = reverseCache[spellID] or {}
            table.insert(reverseCache[spellID], i)
            if overrideSpellID and overrideSpellID ~= 0 then
                reverseCache[overrideSpellID] = reverseCache[overrideSpellID] or {}
                table.insert(reverseCache[overrideSpellID], i)
            end
        end
    end

    --DevTool:AddData(cache, "CMC_CooldownIDCache")
    --DevTool:AddData(reverseCache, "CMC_SpellIDCache")

    print("|cff0099ccCooldown Manager|r Control: ", "Cooldown ID cache rebuilt")
end

--- Returns the formatted keybind associated with a given cooldownID, if any.
---
--- Resolves the cooldownID to its spellID (and overrideSpellID if present),
--- checks keybind mappings, and returns an abbreviated keybind string.
--- If no keybind exists, an empty string is returned.
---
--- @param cooldownID number The cooldown identifier to resolve.
---
--- @return string keybindText The abbreviated keybind string or an empty string.
function addon:GetKeybindForCooldownID(cooldownID)
    local cache = addon.db.global.cooldownIDsCache
    local keybindText = ""
    if cache and cache[cooldownID] then
        local spellID = cache[cooldownID].spellID
        --local overrideSpellID = cache[cooldownID].overrideSpellID
        local overrideID = C_SpellBook.FindSpellOverrideByID(spellID)

        --if overrideSpellID and spellToKeybind[overrideSpellID] then
        -- keybindText = spellToKeybind[overrideSpellID]
        --else
        if overrideID and spellToKeybind[overrideID] then
            keybindText = spellToKeybind[overrideID]
        else
            keybindText = spellToKeybind[spellID] or ""
        end
        if keybindText ~= "" then
            keybindText = abreviateKeybing(keybindText)
        end

        --[[ if cooldownID == 67842 then
            print("Debug: Getting keybind for cooldownID ", cooldownID, " with spellID ", spellID, " and overrideSpellID ", overrideSpellID, " and overrideID ", overrideID, " resulting in keybindText '", keybindText, "'")
        end ]]
    end
    return keybindText
end
