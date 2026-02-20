--- Missing Class Buff
--- Written by Kaloryth

local ADDON_NAME, MCB = ...
local MyAddon = MCB.MyAddon
MCB.MISSING_TEXT = "MISSING"
MCB.WRONG_TEXT = "WRONG"
MCB.MISSING_STANCE_TEXT = "USE STANCE"
MCB.MISSING_AURA_TEXT = "USE AURA"
MCB.MISSING_ATTUNEMENT_TEXT = "USE ATTUNEMENT"
MCB.MISSING_PET_TEXT = "SUMMON PET"
MCB.PET_DEAD_TEXT = "REVIVE PET"
MCB.APPLY_LETHAL_TEXT = "APPLY LETHAL"
MCB.APPLY_NON_LETHAL_TEXT = "APPLY NON-LETHAL"
MCB.REAPPLY_TEXT = "REAPPLY"
MCB.BUFF_ALLY_TEXT = "BUFF ALLY"
MCB.USE_FLASK_TEXT = "USE FLASK"
MCB.EAT_FOOD_TEXT = "EAT FOOD"
MCB.USE_OIL_TEXT = "USE WEAPON BUFF"
MCB.DEFAULT_BUFF = {
    spellId = 455050, showInCombat = false, text = MCB.MISSING_TEXT
}
MCB.instanceId = nil
MCB.instanceDifficultyId = nil
MCB.instanceType = nil
--spellbook id is the id to check if the spell is learned, this could be a talent
--clickable id is the id to use for the clickable icon, this is relevant when spellbook id is a talent and therefore not a spell
--priority is currently unused
--settingsId is an id to reference the buff in the settings, doesn't matter what it is as long as it DOESN'T CHANGE and is unique per entry, try not to use id 1 -> leads to dictionary storage shenanigans
--CURRENT SETTINGS_ID MAX IS 35 IN WARLOCK
MCB.BALANCE_MOONKIN = {priority = 10, settingsId = 33, spellId = 24858, showInCombat = true, ignoreAsBuff = true, learned = false, specIds = {102}, additionalSettingsText = "Only checks as Balance", text = MCB.MISSING_TEXT} -- Moonkin form
MCB.SHADOW_FORM = {priority = 10, settingsId = 11, spellId = 232698, showInCombat = true, ignoreAsBuff = true, learned = false, ignoreDuration = true, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {258}, extraBuffSpellIds = {194249}} -- shadowform
MCB.CLASS_BUFFS = {
    ["DRUID"] = {
        MCB.BALANCE_MOONKIN,
        {priority = 20, settingsId = 31, spellId = 1126, learned = true, showInCombat = false, text = MCB.MISSING_TEXT}, -- Mark of the Wild
        {priority = 30, settingsId = 34, spellId = 474750, learned = true, showInCombat = false, onlyOnePerGroup = true, ignoreSelf = true, overrideIgnoreAllies = true, playerCanHaveMultiples = true, clickingUsesTarget = true, text = MCB.BUFF_ALLY_TEXT}, -- Symbiotic Relationship
    },
    ["EVOKER"] = {      
        {priority = 10, settingsId = 2, spellId = 381748, spellbookId = 364342, learned = true, showInCombat = false, text = MCB.MISSING_TEXT, ignoreRangeCheck = true,
            extraBuffSpellIds = {381732, 381741, 381746, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758, 442744, 432658, 432652, 432655}}, --Blessing of the Bronze
        {priority = 20, settingsId = 3, spellId = 369459, learned = false, showInCombat = false, clickingUsesTarget = true, overrideIgnoreAllies = true, ignoreSelf = true, text = MCB.BUFF_ALLY_TEXT, requiresHealerInGroup = true, additionalSettingsText = "Uses the role system for detection. See below for more info."}, -- source of magic
        {priority = 30, settingsId = 4, spellId = 412710, learned = false, showInCombat = false, clickingUsesTarget = true, text = MCB.MISSING_TEXT, onlyOnePerGroup = true, specIds = {1473}}, --Timelessness
    },
    ["MAGE"] = {
        {priority = 10, settingsId = 5, spellId = 1459, learned = true, showInCombat = false, text = MCB.MISSING_TEXT}, -- Arcane Intellect
        {priority = 20, settingsId = 6, spellId = 210126, spellbookId = 205022, clickableId = 1459, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT} -- Arcane Familiar
    },
    ["PALADIN"] = {
        {priority = 10, settingsId = 7, spellId = 53563,  spellOverlayCompatible = true, showInCombat = true, excludeIfKnown = {200025}, learned = false, onlyOnePerGroup = true, playerCanHaveMultiples = true, clickingUsesTarget = true, mutuallyExclusiveWith = {156910}, ignoreDuration = true, text = MCB.MISSING_TEXT}, -- Beacon of Light
        {priority = 20, settingsId = 8, spellId = 156910,  spellOverlayCompatible = true, spellOverlayNeedsParty = true, showInCombat = true, learned = false, onlyOnePerGroup = true, playerCanHaveMultiples = true,  clickingUsesTarget = true, mutuallyExclusiveWith = {53563}, ignoreDuration = true, text = MCB.MISSING_TEXT}, -- Beacon of Faith
        {priority = 30, settingsId = 9, spellId = 433550, spellbookId = 433568, learned = false, onlySelf = true, text = MCB.MISSING_TEXT}, --rite of sanctification talent
        {priority = 40, settingsId = 10, spellId = 433584, spellbookId = 433583, learned = false, onlySelf = true, text = MCB.MISSING_TEXT}  --rite of adjuration talent
    },
    ["PRIEST"] = {
        MCB.SHADOW_FORM,
        {priority = 20, settingsId = 12, spellId = 21562, learned = true, showInCombat = false, text = MCB.MISSING_TEXT}, -- power word: fortitude
    },
    ["SHAMAN"] = {
        {priority = 10, settingsId = 13, spellId = 462854, learned = true, showInCombat = false, text = MCB.MISSING_TEXT}, -- Skyfury
        {priority = 20, settingsId = 14, spellId = 192106, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {263, 262}, additionalSettingsText = "Only checks as Elemental and Enhancement"}, --lightning shield
        {priority = 30, settingsId = 15, spellId = 52127, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {264}, additionalSettingsText = "Only checks as Restoration"}, --water shield
        {priority = 40, settingsId = 16, spellId = 383648, spellbookId = 383010, clickableId = 974, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, additionalSettingsText = "Only checks on self with talent 'Elemental Orbit'"}, --earth shield on self if have talents for 2 shields
        {priority = 50, settingsId = 17, spellId = 383648, spellbookId = 974, clickingUsesTarget = true, showInCombat = false, ignoreSelf = true, onlyOnePerGroup = true, playerCanHaveMultiples = true, text = MCB.BUFF_ALLY_TEXT,
            extraBuffSpellIds = {974}, additionalSettingsText = "For allies in your group"}, --earth shield on ally in group
        {priority = 60, settingsId = 18, spellId = 318038, weaponEnchantSlot = "main", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {262}, additionalSettingsText = "Only checks as Elemental",}, --flametongue on ele is main hand
        {priority = 70, settingsId = 19, spellId = 462757, weaponEnchantSlot = "off", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {262}}, --thunderstrike ward
        {priority = 80, settingsId = 20, spellId = 33757, weaponEnchantSlot = "main", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT}, --windfury weapon imbue
        {priority = 90, settingsId = 21, spellId = 318038, weaponEnchantSlot = "off", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT, specIds = {263}, additionalSettingsText = "Only checks as Enhancement",}, --flametongue on enhance is offhand
        {priority = 100, settingsId = 22, spellId = 382021, weaponEnchantSlot = "main", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT}, --earthliving weapon imbue
        {priority = 110, settingsId = 23, spellId = 457481, weaponEnchantSlot = "off", learned = false, showInCombat = false, onlySelf = true, text = MCB.MISSING_TEXT}, --tide guard shield imbue
    },
    ["WARLOCK"] = {
        {priority = 10, settingsId = 35, spellId = 196099, spellbookId = 108503, onlySelf = true, ignoreDuration = true, showInCombat = false, text = MCB.MISSING_TEXT, specIds = {265, 267}} -- Grimoire of Sacrifice
    },
    ["WARRIOR"] = {
        {priority = 10, settingsId = 24, spellId = 6673, learned = true, ignoreRangeCheck = true, showInCombat = false, text = MCB.MISSING_TEXT} -- Battle Shout
    },
    --THE ORDER OF THE ROGUE BUFFS MATTERS BECAUSE OF THIS -> we put the defaults LAST(ish) so that defaultLethal and defaultNonLethal are ONLY populated at the last 
    --look of these buffs by the default tag, otherwise the dragon tempered code will not pick up the right poison to use as dragon tempered
    -- REFERENCE THE MESS THAT IS MCB.HandleRoguePoisons
    ["ROGUE"] = {
        {settingsId = 25, spellId = 381637, poisonType = "nonlethal", onlySelf = true, text = MCB.APPLY_NON_LETHAL_TEXT}, --atrophic
        {settingsId = 27, spellId = 5761, poisonType = "nonlethal", onlySelf = true, text = MCB.APPLY_NON_LETHAL_TEXT}, --numbing
        {settingsId = 26, spellId = 3408, poisonType = "nonlethal", default = true, onlySelf = true, text = MCB.APPLY_NON_LETHAL_TEXT}, --crippling
        {settingsId = 28, spellId = 381664, poisonType = "lethal", onlySelf = true, text = MCB.APPLY_LETHAL_TEXT}, --amplifying
        {settingsId = 30, spellId = 2823, poisonType = "lethal", onlySelf = true, text = MCB.APPLY_LETHAL_TEXT}, --deadly
        {settingsId = 29, spellId = 315584, poisonType = "lethal", default = true, onlySelf = true, text = MCB.APPLY_LETHAL_TEXT}, --instant
        {settingsId = 32, spellId = 8679, poisonType = "lethal", onlySelf = true, text = MCB.APPLY_LETHAL_TEXT}, --wound
    }
}

MCB.FLASK_DEFAULT_BUFF = {spellId = 432021, disableClicking = true, onlySelf = true, text = MCB.USE_FLASK_TEXT }
MCB.FOOD_DEFAULT_BUFF = {spellId = 19705, disableClicking = true, onlySelf = true, text = MCB.EAT_FOOD_TEXT}
MCB.OIL_DEFAULT_BUFF = {spellId = 451874, disableClicking = true, onlySelf = true, text = MCB.USE_OIL_TEXT}

MCB.WELL_FED_NAME = C_Spell.GetSpellName(19705)
MCB.HEARTY_WELL_FED_NAME = C_Spell.GetSpellName(462187)

-- need to have a list of player provided weapon enchants to ignore when looking for oil data
MCB.OIL_MAIN_HAND_IGNORE_LIST = {
    [7144] = true, -- rite of adjuration
    [7143] = true, --rite of sanctification
    [6498] = true, --earthliving
    [5400] = true, --flametongue
    [5401] = true, -- windfury
}

MCB.OIl_OFF_HAND_IGNORE_LIST = {
    [5400] = true, -- flametongue
    [7587] = true, --thunderstrike ward
    [7528] = true, --tide guard
}

MCB.FLASK_DATA = { --TWW FLASKS
    [432021] = true, -- Alchemical Chaos
    [431971] = true, -- Aggression
    [431972] = true, -- Swiftness
    [431974] = true, -- Mastery
    [431973] = true, -- Versatility
    --Midnight Flasks - ids not final
    [1235057] = true, -- Thalassian Resistance
    [1235110] = true, -- Blood Knights
    [1235111] = true, -- Shattered Sun
}

MCB.BATTLE_STANCE = {priority = 1, spellId = 386164, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_STANCE_TEXT} -- battle
MCB.BERSERKER_STANCE = {priority = 2, spellId = 386196, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_STANCE_TEXT} -- berserker
MCB.DEFENSIVE_STANCE = {priority = 3, spellId = 386208, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_STANCE_TEXT, default = true} -- defensive

MCB.WARRIOR_STANCES = {
    MCB.BATTLE_STANCE,
    MCB.BERSERKER_STANCE,
    MCB.DEFENSIVE_STANCE
}

MCB.CRUSADER_AURA = {priority = 3, spellId = 32223, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_AURA_TEXT} -- crusader
MCB.PALADIN_AURAS = {
    {priority = 1, spellId = 465, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_AURA_TEXT, default = true}, -- devotion
    {priority = 2, spellId = 317920, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_AURA_TEXT}, -- concentration
    MCB.CRUSADER_AURA,
    {priority = 4, spellId = 210323, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_AURA_TEXT} -- vengeance
}

MCB.EVOKER_ATTUNEMENTS = {
    {priority = 1, spellId = 403264, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_ATTUNEMENT_TEXT, default = true}, -- black
    {priority = 2, spellId = 403265, learned = false, ignoreDuration = true, showInCombat = true, onlySelf = true, text = MCB.MISSING_ATTUNEMENT_TEXT} -- bronze
}

MCB.HUNTER_PET_MISSING = {
    spellId = 883, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT
}

MCB.HUNTER_PET_DEAD = {
    spellId = 982, showInCombat = true, isPet = true, text = MCB.PET_DEAD_TEXT
}

MCB.HUNTER_ALL_PETS = {
    {spellId = 883, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT, default = true }, -- call pet 1
    {spellId = 83242, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- call pet 2
    {spellId = 83243, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- call pet 3
    {spellId = 83244, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- call pet 4
    {spellId = 83245, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- call pet 5
}

MCB.WARLOCK_PET = {
    spellId = 688, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT
}
MCB.WARLOCK_ALL_PETS = {
    {spellId = 688, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT, default = true}, -- Imp
    {spellId = 697, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- Voidwalker
    {spellId = 691, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- Felhunter
    {spellId = 366222, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- Sayaad
    {spellId = 30146, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT}, -- Felguard
}

MCB.UNHOLY_GHOUL_MISSING = {
    spellId = 46584, clickableNeedsName = 46584, isPet = true, showInCombat = true, text = MCB.MISSING_PET_TEXT
}

MCB.FROST_ELEMENTAL_MISSING = {
    spellId = 31687, showInCombat = true, isPet = true, text = MCB.MISSING_PET_TEXT
}

MCB.BUFFS = {}
MCB.NEEDS_BUFFS_CHECKED = false
MCB.HAS_SPELL_OVERLAY_COMPATIBLE_BUFF = false
MCB.MISC_DATA = {
    isEarthen = false
}
MCB.CLASS_STATE = {
    isDeathKnight = false,
    isDemonHunter = false,
    isUnholyDk = false,
    isDruid = false,
    isBalanceDruidWithMoonkin = false,
    isEvoker = false,
    isAugmentationEvoker = false,
    isHunter = false,
    isMarksmanHunter = false,
    isMarksmanHunterWithPet = false,
    isMage = false,
    isFrostMageWithPet = false,
    isMonk = false,
    isPaladin = false,
    isPriest = false,
    isShadowPriestWithForm = false,
    isRogue = false,
    isDragonTemperedRogue = false,
    isShaman = false,
    isWarlock = false,
    isSacrificeWarlock = false,
    isWarrior = false
}
MCB.CLASS_NAME = ""
MCB.CURRENT_SPEC_ID = 0

MCB.HEALER_SPECS = {
    [105] = true, -- Druid: Restoration
    [1468] = true, -- Evoker: Preservation
    [270] = true, -- Monk: Mistweaver
    [65]  = true, -- Paladin: Holy
    [256] = true, -- Priest: Discipline
    [257] = true, -- Priest: Holy
    [264] = true, -- Shaman: Restoration
}

MCB.DUNGEON_DIFFICULTIES = {
    [1] = "normal",
    [2] = "heroic",
    [23] = "mythic",
    [8] = "mythicplus"
}

MCB.RAID_DIFFICULTIES = {
    [14] = "normal",
    [15] = "heroic",
    [16] = "mythic",
    [17] = "lfr"
}

MCB.difficultyNames = {
    ["normal"] = "Normal",
    ["heroic"] = "Heroic",
    ["mythic"] = "Mythic",
    ["mythicplus"] = "Mythic+*",
    ["other"] = "Other",
    ["lfr"] = "LFR"
}

MCB.CURRENT_MYTHIC_PLUS_DUNGEONS = {

}

function MCB.isLegacyContent()
    local function IsDungeonInCurrentMPlusPool()
        --we are literally in m+ right now
        if MCB.instanceDifficultyId == 8 then
            return true
        end
        return MCB.CURRENT_MYTHIC_PLUS_DUNGEONS[MCB.instanceId] or false
    end
    if MCB.instanceId then
        local expansionLevel = GetExpansionLevel() -- 11 for Midnight, 10 for TWW
        local instanceIdsForExpansion = 9999
        if expansionLevel == 10 then
            instanceIdsForExpansion = 2600
        elseif expansionLevel == 11 then
            instanceIdsForExpansion = 2750
        else
            instanceIdsForExpansion = 2900 --this is a wild guess for next expac
        end
        if MCB.instanceId < instanceIdsForExpansion then
            --backup check
            if IsDungeonInCurrentMPlusPool() then
                return false
            else
                return true
            end
        end
        return false
    else
        MCB.setInstanceInformation()
    end
    return true
end

function MCB.ShouldCheckForPet()
    local hunterShowPet = MCB.CLASS_STATE.isHunter and not MyAddon.db.profile.ignoreHunterPets and
        (not MCB.CLASS_STATE.isMarksmanHunter
            or (not MyAddon.db.profile.ignoreHunterPetsWhenMarksman and MCB.CLASS_STATE.isMarksmanHunterWithPet) )
    return hunterShowPet or (MCB.CLASS_STATE.isWarlock and not MyAddon.db.profile.ignoreWarlockPets and not MCB.CLASS_STATE.isSacrificeWarlock) or
        (MCB.CLASS_STATE.isDeathKnight and MCB.CLASS_STATE.isUnholyDk  and not MyAddon.db.profile.ignoreDeathKnightPets) or
        (MCB.CLASS_STATE.isMage and MCB.CLASS_STATE.isFrostMageWithPet and not MyAddon.db.profile.ignoreMagePets)
end

--unused atm
function MCB.HasWeaponEnchantsInList(buffs)
    for _, buff in ipairs(buffs) do
        if buff.weaponEnchantSlot then
            return true
        end
    end
    return false
end

function MCB.needsShapeshiftFormCheck()
    local inCombat = InCombatLockdown()
    return (MCB.CLASS_STATE.isWarrior and not MyAddon.db.profile.ignoreWarriorStance) 
        or (MCB.CLASS_STATE.isPaladin and not MyAddon.db.profile.ignorePaladinAuras)
        or (MCB.CLASS_STATE.isAugmentationEvoker and not MyAddon.db.profile.ignoreEvokerAttunements)
        or (MCB.CLASS_STATE.isBalanceDruidWithMoonkin and (inCombat or not MyAddon.db.profile.ignoreMoonkinFormOOC) and not MCB.GetSettingsValue("ignoredSettingsIds")[MCB.BALANCE_MOONKIN.settingsId])
        or (MCB.CLASS_STATE.isShadowPriestWithForm and (inCombat or not MyAddon.db.profile.ignoreShadowFormOOC) and not MCB.GetSettingsValue("ignoredSettingsIds")[MCB.SHADOW_FORM.settingsId])
end

--MCB.needsShapeshiftFormCheck() needs to be called first to make sure you are not doing a check when you shouldn't on Moonkin/Shadow
function MCB.doShapeshiftFormCheck()
    local currentFormIndex = GetShapeshiftForm()
    local stancesDefaultdisplay = nil
    if MCB.CLASS_STATE.isAugmentationEvoker then
        stancesDefaultdisplay = MCB.getStanceDisplayAura(MCB.EVOKER_ATTUNEMENTS)
    elseif MCB.CLASS_STATE.isPaladin then
        stancesDefaultdisplay = MCB.getStanceDisplayAura(MCB.PALADIN_AURAS)
    elseif MCB.CLASS_STATE.isWarrior then
        stancesDefaultdisplay = MCB.getStanceDisplayAura(MCB.WARRIOR_STANCES)
    elseif MCB.CLASS_STATE.isBalanceDruidWithMoonkin then
        stancesDefaultdisplay = MCB.BALANCE_MOONKIN
    elseif MCB.CLASS_STATE.isShadowPriestWithForm then
        stancesDefaultdisplay = MCB.SHADOW_FORM
    end

    -- there was no aura, so we definitely need to notify
    if (not currentFormIndex or currentFormIndex == 0) and stancesDefaultdisplay then
        MCB.ShowMissingMessage(stancesDefaultdisplay)
        return true, stancesDefaultdisplay
    end

    --need to check that druid is in moonkin form and not something else
    if MCB.CLASS_STATE.isBalanceDruidWithMoonkin then
        local _, active, _, spellId = GetShapeshiftFormInfo(currentFormIndex)
        if spellId ~= MCB.BALANCE_MOONKIN.spellId then
            MCB.ShowMissingMessage(MCB.BALANCE_MOONKIN)
            return true, MCB.BALANCE_MOONKIN
        end
    elseif MCB.CLASS_STATE.isPaladin and MyAddon.db.profile.checkForCrusaderInCombat and InCombatLockdown() then
        local _, active, _, spellId = GetShapeshiftFormInfo(currentFormIndex)
        if active and spellId == MCB.CRUSADER_AURA.spellId then
            MCB.ShowMissingMessage(MCB.CRUSADER_AURA, MCB.WRONG_TEXT)
            return true, MCB.CRUSADER_AURA
        end
    elseif MCB.CLASS_STATE.isWarrior and MyAddon.db.profile.checkForWrongWarriorStance then
        local _, active, _, spellId = GetShapeshiftFormInfo(currentFormIndex)
        if MCB.CURRENT_SPEC_ID == 73 and active and spellId ~= MCB.DEFENSIVE_STANCE.spellId then --prot
            MCB.ShowMissingMessage(MCB.DEFENSIVE_STANCE)
            return true, MCB.DEFENSIVE_STANCE
        elseif MCB.CURRENT_SPEC_ID == 71 and active and spellId == MCB.DEFENSIVE_STANCE.spellId then --arms
            MCB.ShowMissingMessage(MCB.BATTLE_STANCE)
            return true, MCB.BATTLE_STANCE
        elseif MCB.CURRENT_SPEC_ID == 72 and active and spellId == MCB.DEFENSIVE_STANCE.spellId then -- fury
            MCB.ShowMissingMessage(MCB.BERSERKER_STANCE)
            return true, MCB.BERSERKER_STANCE
        end
    end

    return false, nil
end

function MCB.getStanceDisplayAura(stances)
    local overrideDefaultSpellId = false
    local hasLearnedAStance = false
    local buffToDisplay = nil
    local hasOverrideDefaultDisplaying = false
    if MCB.CLASS_STATE.isPaladin and MyAddon.db.profile.overrideDefaultPaladinAura then
        overrideDefaultSpellId = MyAddon.db.profile.overrideDefaultPaladinAura
    elseif MCB.CLASS_STATE.isAugmentationEvoker and MyAddon.db.profile.overrideEvokerAttunement then
        overrideDefaultSpellId =  MyAddon.db.profile.overrideEvokerAttunement
    end
    for _, stance in ipairs(stances) do
        if stance.learned then
            hasLearnedAStance = true
            if stance.default and not hasOverrideDefaultDisplaying then
                buffToDisplay = stance
            end
            if overrideDefaultSpellId and overrideDefaultSpellId == stance.spellId then
                buffToDisplay = stance
                hasOverrideDefaultDisplaying = true
            end
        end
    end
    if hasLearnedAStance then
        return buffToDisplay
    end
    return nil
end

function MCB.doSpellOverlayChecks()
    local zoneSetting = MCB.getZoneSettings(MCB.instanceType) 
    return MCB.HAS_SPELL_OVERLAY_COMPATIBLE_BUFF and zoneSetting.showInCombatGlows and zoneSetting.showInCombatGlows[MCB.CLASS_NAME]
        and C_SpellActivationOverlay and C_SpellActivationOverlay.IsSpellOverlayed and MyAddon.db.profile.useBuffGlows and MyAddon.db.profile.useBuffGlows[MCB.CLASS_NAME]
end

function MCB.checkSpellOverlayInCombat(buff)
    local zoneSetting = MCB.getZoneSettings(MCB.instanceType)
    return zoneSetting.showInCombatGlows and zoneSetting.showInCombatGlows[MCB.CLASS_NAME]
end

function MCB.NeedAuraStanceNotification(stances, auraInfoCache)
    local buffToDisplay = nil
    local hasMissingBuff = nil
    local buffWasFound = false
    local hasLearnedAStance = false
    local overrideDefaultSpellId = false
    local hasOverrideDefaultDisplaying = false
    --these values can be "true" if user did not select a spell and only selected the checkbox to override
    --still works as expected because "true" will not match any spellIds
    if MCB.CLASS_STATE.isPaladin and MyAddon.db.profile.overrideDefaultPaladinAura then
        overrideDefaultSpellId = MyAddon.db.profile.overrideDefaultPaladinAura
    elseif MCB.CLASS_STATE.isAugmentationEvoker and MyAddon.db.profile.overrideEvokerAttunement then
        overrideDefaultSpellId =  MyAddon.db.profile.overrideEvokerAttunement
    end
    for _, stance in ipairs(stances) do
        if stance.learned then
            hasLearnedAStance = true
            if stance.default and not hasOverrideDefaultDisplaying  then
                buffToDisplay = stance
            end
            if overrideDefaultSpellId and overrideDefaultSpellId == stance.spellId then
                buffToDisplay = stance
                hasOverrideDefaultDisplaying = true
            end
            if MCB.CheckUnit("player", stance, auraInfoCache) then
                buffWasFound = false

            else
                buffWasFound = true
                break;
            end
        end
    end
    hasMissingBuff = not buffWasFound and hasLearnedAStance
    if hasMissingBuff and not buffToDisplay then
        buffToDisplay = stances[1]
    end
    if hasMissingBuff then
        MCB.ShowMissingMessage(buffToDisplay)
    else
        buffToDisplay = nil
    end
    return hasMissingBuff, buffToDisplay
end

function MCB.isPlayerMounted()
    return IsMounted() or UnitOnTaxi("player") or UnitInVehicle("player") or UnitHasVehicleUI("player") or MCB.isDruidConsideredMounted()
end

function MCB.isDruidConsideredMounted()
    if MCB.CLASS_STATE.isDruid and MyAddon.db.profile.treatTravelFormAsMount then
        local shapeShiftId = GetShapeshiftFormID()
        if shapeShiftId and (shapeShiftId == 29 or shapeShiftId == 27 or shapeShiftId == 3) then
            return true
        end
    end
    return false
end

function MCB.isUnitWeCareAbout(unit)
    if unit == "player" or (unit and (unit:find("party") or unit:find("raid"))) then
        return true
    end
    return false
end

function MCB.NeedPetMissingNotification()
    local function petShouldBeMissingState()
        if MCB.isPlayerMounted() then
            return true
        end
        return false
    end
    local function getDeadNotification()
        if MCB.CLASS_STATE.isWarlock then
            return MCB.handleWarlockPetNotificationChoice(MCB.WARLOCK_PET)
        elseif MCB.CLASS_STATE.isDeathKnight then
            return MCB.UNHOLY_GHOUL_MISSING
        elseif MCB.CLASS_STATE.isHunter then
            return MCB.HUNTER_PET_DEAD
        elseif MCB.CLASS_STATE.isMage then
            return MCB.FROST_ELEMENTAL_MISSING
        end
    end

    local function getMissingNotification()
        if MCB.CLASS_STATE.isWarlock then
            return MCB.handleWarlockPetNotificationChoice(MCB.WARLOCK_PET)
        elseif MCB.CLASS_STATE.isDeathKnight then
                return MCB.UNHOLY_GHOUL_MISSING
        elseif MCB.CLASS_STATE.isHunter then
            return MCB.handleHunterPetNotificationChoice(MCB.HUNTER_PET_MISSING)
        elseif MCB.CLASS_STATE.isMage then
            return MCB.FROST_ELEMENTAL_MISSING
        end
    end
    if MCB.ShouldCheckForPet() and not petShouldBeMissingState() then
        local notificationBuff = nil
        if UnitExists("pet") then
            if UnitIsDead("pet") then
                notificationBuff = getDeadNotification()
            end
        else
            notificationBuff = getMissingNotification()
        end
        if notificationBuff and notificationBuff.learned then
            return notificationBuff
        end
    end
    return nil
end

function MCB.handleHunterPetNotificationChoice(defaultChoice)
    if MyAddon.db.profile.overrideHunterCallPet then
        for _, petData in ipairs(MCB.HUNTER_ALL_PETS) do
            if petData.spellId == MyAddon.db.profile.overrideHunterCallPet and petData.learned then
                return petData
            end
        end
    end
    return defaultChoice
end

function MCB.handleWarlockPetNotificationChoice(defaultChoice)
    if MyAddon.db.profile.overrideWarlockSummonPet then
        for _, petData in ipairs(MCB.WARLOCK_ALL_PETS) do
            if petData.spellId == MyAddon.db.profile.overrideWarlockSummonPet and petData.learned then
                return petData
            end
        end
    end
    return defaultChoice
end

function MCB.isUnitEarthen()
    local _, raceFile = UnitRace("player")
    return raceFile == "EarthenDwarf"
end

function MCB.setPlayerIsUnholy()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 252 then
        MCB.CLASS_STATE.isUnholyDk = true
        return true
    end
    MCB.CLASS_STATE.isUnholyDk = false
    return false
end

function MCB.setPlayerIsAugmentation()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 1473 then
        MCB.CLASS_STATE.isAugmentationEvoker = true
        return true
    end
    MCB.CLASS_STATE.isAugmentationEvoker = false
    return false
end

function MCB.setPlayerIsBalanceWithForm()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 102 then
        local known = C_SpellBook.IsSpellKnown(24858)
        if known then
            MCB.CLASS_STATE.isBalanceDruidWithMoonkin = true
            return true
        end
    end
    MCB.CLASS_STATE.isBalanceDruidWithMoonkin = false
    return false
end

function MCB.setPlayerIsShadowWithForm()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 258 then
        local known = C_SpellBook.IsSpellKnown(232698)
        if known then
            MCB.CLASS_STATE.isShadowPriestWithForm = true
            return true
        end
    end
    MCB.CLASS_STATE.isShadowPriestWithForm = false
    return false
end

function MCB.setPlayerIsMarksman()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 254 then
        MCB.CLASS_STATE.isMarksmanHunter = true
        return true
    end
    MCB.CLASS_STATE.isMarksmanHunter = false
    return false
end

function MCB.setPlayerIsMarksmanWithPet()
    local isMarksman  = MCB.setPlayerIsMarksman()
    if isMarksman then
        local known = C_SpellBook.IsSpellKnown(1223323)
        if known then
            MCB.CLASS_STATE.isMarksmanHunterWithPet = true
            return true
        end
    end
    MCB.CLASS_STATE.isMarksmanHunterWithPet = false
    return false
end

function MCB.setPlayerIsFrostWithPet()
    local isFrostMage = false
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 64 then
        isFrostMage = true
    end
    if isFrostMage then
        local known = C_SpellBook.IsSpellKnown(MCB.FROST_ELEMENTAL_MISSING.spellId)
        if known then
            MCB.CLASS_STATE.isFrostMageWithPet = true
            return true
        end
    end
    MCB.CLASS_STATE.isFrostMageWithPet = false
    return false
end

function MCB.setWarlockWithSacrifice()
    local specID = GetSpecializationInfo(GetSpecialization())
    if specID == 265 or specID == 267 then
        local known = C_SpellBook.IsSpellKnown(108503)
        if known then
            MCB.CLASS_STATE.isSacrificeWarlock = true
            return true
        end
    end
    MCB.CLASS_STATE.isSacrificeWarlock = false
    return false
end

function MCB.setRogueWithDragonTempered()
    local known = C_SpellBook.IsSpellKnown(381801)
    if known then
        MCB.CLASS_STATE.isDragonTemperedRogue = true
        return true
    end
    MCB.CLASS_STATE.isDragonTemperedRogue = false
    return false
end

function MCB.cacheCustomItemIds()
    if MyAddon.db.profile.customSpellIds and #MyAddon.db.profile.customSpellIds > 0 then
         for _, spellEntry in ipairs(MyAddon.db.profile.customSpellIds) do
            if spellEntry.clickableType and spellEntry.clickableType == MCB.CLICK_TO_CAST_SPELL_TYPES.ITEM then
                C_Item.RequestLoadItemDataByID(spellEntry.clickableId)
            end
         end
    end
end