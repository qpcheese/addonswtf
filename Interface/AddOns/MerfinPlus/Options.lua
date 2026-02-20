-- MerfinPlus Options & Media Registration
-- Comments in English as requested.

local _, MerfinPlus = ...

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local Locale = GetLocale()
local L = MerfinPlus.L

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

MerfinPlus.GetDefaultFont = function(type)
  local toc = select(4, GetBuildInfo())
  if type == "bold" then
    return (Locale == "zhTW" or Locale == "zhCN" or toc == 38000) and "CN Merged (SF-Yahee)"
      or "SFUIDisplayCondensed-Bold"
  else
    return (Locale == "zhTW" or Locale == "zhCN" or toc == 38000) and "CN Merged (SF-Yahee)"
      or "SFUIDisplayCondensed-Semibold"
  end
end

Merfin.GetDefaultFont = MerfinPlus.GetDefaultFont

local function IsWrath()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 33000 and build < 40000
end

local function IsMoP()
  local build = MerfinPlus.BuildInfo or select(4, GetBuildInfo())
  return build > 50500 and build < 60000
end

MerfinPlus.defaults = {
  profile = {
    pullStartTime = 0,
    pullExpTime = 0,
    pullTotalTime = 0,
    pullSenderName = "Unknown",
    breakStartTime = 0,
    breakExpTime = 0,
    breakTotalTime = 0,
    breakSenderName = "Unknown",
    lfgStartTimer = 0,
    lfgExpTimer = 0,

    font1 = MerfinPlus.GetDefaultFont(),
    font2 = MerfinPlus.GetDefaultFont("bold"),
    font3 = MerfinPlus.GetDefaultFont(),
    font4 = MerfinPlus.GetDefaultFont("bold"),
    bar1 = "MerfinMainDark",
    bar2 = "MerfinMain",
    bar3 = "MerfinMainDark",

    simImports = {},
  },
  global = {
    wowSims = {
      profiles = {},
      assigned = {},
    },
  },
}

-- Helper to access the active profile table safely
function MerfinPlus:GetDB()
  return (self.db and self.db.profile) or MerfinPlus.defaults.profile
end

local function GetEffectiveSpecID()
  if IsWrath() then
    return select(2, Merfin.GetPlayerRole())
  end

  if IsMoP() then
    local classID = select(3, UnitClass("player"))
    return GetSpecializationInfoForClassID(classID, C_SpecializationInfo.GetSpecialization())
  end
end

local function GetCharKey()
  local name = UnitName("player") or "Unknown"
  local realm = GetNormalizedRealmName() or GetRealmName() or "UnknownRealm"
  return name .. "-" .. realm
end

function Merfin.GetActiveSimProfile()
  local db = MerfinPlus.db
  if not (db and db.global and db.global.wowSims) then
    return nil
  end

  local charKey = GetCharKey()
  local assigned = db.global.wowSims.assigned[charKey]
  if not assigned then
    return nil
  end

  local specID = GetEffectiveSpecID()
  if not specID then
    return nil
  end

  local profileKey = assigned[specID]
  if not profileKey then
    return nil
  end

  return db.global.wowSims.profiles[profileKey]
end

function Merfin.GetActiveItemSuffix()
  local profile = Merfin.GetActiveSimProfile()
  if not profile or not profile.itemSuffixes then
    return nil
  end

  return profile.itemSuffixes
end

-- Build and register all options (Blizzard panels + standalone window + slash commands)
function MerfinPlus:SetupOptions()
  local version = GetAddOnMetadata("MerfinPlus", "Version") or "?"
  local wowSimOptions

  -- ==== Media lists (LSM) ====
  local function GetFontList()
    local fonts = {}
    local excluded = {
      ["Merfin Font 1"] = true,
      ["Merfin Font 2"] = true,
      ["Merfin Raid Font"] = true,
      ["Merfin Raid Font (Bold)"] = true,
    }
    for name in pairs(LSM:HashTable("font")) do
      if not excluded[name] then
        fonts[name] = name
      end
    end
    return fonts
  end

  local function GetStatusBarList()
    local bars = {}
    local excluded = {
      ["Merfin Status Bar 1"] = true,
      ["Merfin Status Bar 2"] = true,
      ["Merfin Raid Status Bar"] = true,
    }
    for name in pairs(LSM:HashTable("statusbar")) do
      if not excluded[name] then
        bars[name] = name
      end
    end
    return bars
  end

  -- ==== UI reload popup ====
  local function ConfirmReload()
    StaticPopupDialogs["MERFINPLUS_RELOAD_UI"] = {
      text = L["A reload of the interface is required for this change to take effect.\n\nReload now?"],
      button1 = YES,
      button2 = NO,
      OnAccept = function()
        ReloadUI()
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }
    StaticPopup_Show("MERFINPLUS_RELOAD_UI")
  end

  -- ==== Root (Blizzard top-level) ====
  local mainOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    args = {
      version = {
        type = "description",
        name = "|cff00ccff" .. L["Version:"] .. "|r" .. version,
        fontSize = "medium",
        order = 1,
      },
      author = {
        type = "description",
        name = L["Author: "] .. "Merfin",
        fontSize = "medium",
        order = 2,
      },
      spacer = { type = "description", name = " ", order = 3 },
      description = {
        type = "description",
        name = L["MerfinPlus provides custom fonts, textures, and utilities that enhance or support WeakAuras and other Merfin UI components."],
        fontSize = "large",
        order = 4,
      },
      spacer2 = { type = "description", name = " ", order = 5 },
    },
  }

  -- ==== Media ====
  local mediaOptions = {
    type = "group",
    name = L["Media"],
    args = {
      description = {
        type = "description",
        name = L["Change primary fonts and status bar textures used by Merfin features. A UI reload is required."],
        fontSize = "medium",
        order = 0,
      },
    },
  }

  local fontNames = { "Merfin Font 1", "Merfin Font 2", "Merfin Raid Font", "Merfin Raid Font (Bold)" }
  local barNames = { "Merfin Status Bar 1", "Merfin Status Bar 2", "Merfin Raid Status Bar" }

  for i = 1, #fontNames do
    mediaOptions.args["font" .. i] = {
      type = "select",
      name = fontNames[i],
      desc = L["Select font for element "] .. i,
      values = GetFontList,
      get = function()
        return self.db.profile["font" .. i]
      end,
      set = function(_, v)
        self.db.profile["font" .. i] = v
        ConfirmReload()
      end,
      dialogControl = "LSM30_Font",
      order = i + 1,
    }
  end
  for i = 1, #barNames do
    mediaOptions.args["bar" .. i] = {
      type = "select",
      name = barNames[i],
      desc = L["Select status bar texture for element "] .. i,
      values = GetStatusBarList,
      get = function()
        return self.db.profile["bar" .. i]
      end,
      set = function(_, v)
        self.db.profile["bar" .. i] = v
        ConfirmReload()
      end,
      dialogControl = "LSM30_Statusbar",
      order = i + 10,
    }
  end

  -- ==== WoW Sim Importer ====
  local WOWSIM_INDEX_TO_SLOT = {
    [1] = 1, -- Head
    [2] = 2, -- Neck
    [3] = 3, -- Shoulder
    [4] = 15, -- Back
    [5] = 5, -- Chest
    [6] = 9, -- Wrist
    [7] = 10, -- Hands
    [8] = 6, -- Waist
    [9] = 7, -- Legs
    [10] = 8, -- Feet
    [11] = 11, -- Ring 1
    [12] = 12, -- Ring 2
    [13] = 13, -- Trinket 1
    [14] = 14, -- Trinket 2
    [15] = 16, -- Mainhand
    [16] = 17, -- Offhand
    [17] = IsWrath() and 18 or nil, -- Relic/Ranged
  }

  local SLOT_NAMES = {
    [1] = _G.INVTYPE_HEAD,
    [2] = _G.INVTYPE_NECK,
    [3] = _G.INVTYPE_SHOULDER,
    [5] = _G.INVTYPE_CHEST,
    [6] = _G.INVTYPE_WAIST,
    [7] = _G.INVTYPE_LEGS,
    [8] = _G.INVTYPE_FEET,
    [9] = _G.INVTYPE_WRIST,
    [10] = _G.INVTYPE_HAND,
    [11] = _G.INVTYPE_FINGER,
    [12] = _G.INVTYPE_FINGER,
    [13] = _G.INVTYPE_TRINKET,
    [14] = _G.INVTYPE_TRINKET,
    [15] = _G.INVTYPE_CLOAK,
    [16] = _G.INVTYPE_WEAPONMAINHAND,
    [17] = _G.INVTYPE_WEAPONOFFHAND,
    [18] = IsWrath() and _G.INVTYPE_RELIC or nil,
  }

  -- -------------------------
  -- Helpers
  -- -------------------------
  local function NormalizeSimClass(simClass)
    if type(simClass) ~= "string" then
      return nil
    end
    return strupper(simClass:gsub("^Class", "")) -- "ClassDruid" -> "DRUID"
  end

  local function ExtractSlotItemsFromSim(simData)
    local items = {}
    local suffixes = {}
    local equip = simData and simData.player and simData.player.equipment
    local list = equip and equip.items
    if type(list) ~= "table" then
      return items, suffixes
    end

    for idx, entry in ipairs(list) do
      local slotID = WOWSIM_INDEX_TO_SLOT[idx]
      local itemID = entry and entry.id

      if slotID and type(itemID) == "number" and itemID > 0 then
        items[slotID] = itemID

        if entry.randomSuffix then
          suffixes[slotID] = entry.randomSuffix
        end

        C_Item.RequestLoadItemDataByID(itemID)
      end
    end
    return items, suffixes
  end

  -- SAFE: user can type anything, GetItemInfo might be nil (cache), request load and return nil safely
  local function SafeItemInfo(itemID)
    if type(itemID) ~= "number" or itemID <= 0 then
      return nil
    end
    local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
    if not name then
      C_Item.RequestLoadItemDataByID(itemID)
      return nil
    end
    return name, icon
  end

  local function FindNextFreeProfileIndex(db, spec, class)
    local used = {}
    for k in pairs(db.global.wowSims.profiles) do
      local n = k:match("^" .. spec .. class .. "(%d+)$")
      if n then
        used[tonumber(n)] = true
      end
    end

    local i = 1
    while used[i] do
      i = i + 1
    end
    return i
  end

  local function MakeProfileKey(spec, class)
    local n = FindNextFreeProfileIndex(MerfinPlus.db, spec, class)
    return spec .. class .. n -- FeralDRUID1
  end

  local function PlayerClassMatches(profile)
    local _, playerClass = UnitClass("player") -- playerClass is uppercase token like "DRUID"
    return profile and profile.class == playerClass
  end

  -- -------------------------
  -- Spec lists
  -- -------------------------
  local specsByClassID = {
    [0] = { 74, 81, 79 },
    [1] = { 71, 72, 73, 1446 },
    [2] = { 65, 66, 70, 1451 },
    [3] = { 253, 254, 255, 1448 },
    [4] = { 259, 260, 261, 1453 },
    [5] = { 256, 257, 258, 1452 },
    [6] = { 250, 251, 252, 1455 },
    [7] = { 262, 263, 264, 1444 },
    [8] = { 62, 63, 64, 1449 },
    [9] = { 265, 266, 267, 1454 },
    [10] = { 268, 270, 269, 1450 },
    [11] = { 102, 103, 104, 105, 1447 },
  }

  local classFileByID = {
    [0] = "PET",
    [1] = "WARRIOR",
    [2] = "PALADIN",
    [3] = "HUNTER",
    [4] = "ROGUE",
    [5] = "PRIEST",
    [6] = "DEATHKNIGHT",
    [7] = "SHAMAN",
    [8] = "MAGE",
    [9] = "WARLOCK",
    [10] = "MONK",
    [11] = "DRUID",
  }

  local function GetClassPrefixFromFile(classFile)
    if classFile == "DEATHKNIGHT" then
      return "DeathKnight"
    end
    if classFile == "DEMONHUNTER" then
      return "DemonHunter"
    end
    if type(classFile) ~= "string" or classFile == "" then
      return "Class"
    end
    local lower = classFile:lower()
    return lower:sub(1, 1):upper() .. lower:sub(2)
  end

  local function BuildClassSpecIDs_MoP()
    local CLASS_SPEC_IDS = {}

    for classID, list in pairs(specsByClassID) do
      local classFile = classFileByID[classID]
      if classFile then
        local wanted = {}
        for i = 1, (#list - 1) do
          wanted[list[i]] = true
        end

        local out = {}
        local prefix = GetClassPrefixFromFile(classFile)

        for specIndex = 1, 10 do
          local specID, specName, _, icon = GetSpecializationInfoForClassID(classID, specIndex)
          if not specID then
            break
          end

          if wanted[specID] then
            local cleanName = (specName and specName:gsub("%s+", "")) or tostring(specID)
            local specKey = prefix .. cleanName
            out[#out + 1] = { specID = specID, specKey = specKey, icon = icon }
          end
        end

        CLASS_SPEC_IDS[classFile] = out
      end
    end

    return CLASS_SPEC_IDS
  end

  local CLASS_SPEC_IDS = IsWrath()
      and {

        DRUID = {
          { specID = 283, specKey = "DruidBalance", icon = 136096 }, -- Balance
          { specID = 281, specKey = "DruidFeralCombat", icon = 132276 }, -- Feral
          { specID = 282, specKey = "DruidRestoration", icon = 136041 }, -- Restoration
        },

        WARRIOR = {
          { specID = 161, specKey = "WarriorArms", icon = 132292 },
          { specID = 164, specKey = "WarriorFury", icon = 132347 },
          { specID = 163, specKey = "WarriorProtection", icon = 134952 },
        },

        PALADIN = {
          { specID = 381, specKey = "PaladinRetribution", icon = 135873 },
          { specID = 382, specKey = "PaladinHoly", icon = 135920 },
          { specID = 383, specKey = "PaladinProtection", icon = 135893 },
        },

        HUNTER = {
          { specID = 361, specKey = "HunterBeastMastery", icon = 132164 },
          { specID = 363, specKey = "HunterMarksmanship", icon = 132222 },
          { specID = 362, specKey = "HunterSurvival", icon = 132215 },
        },

        ROGUE = {
          { specID = 182, specKey = "RogueAssassination", icon = 132292 },
          { specID = 181, specKey = "RogueCombat", icon = 132090 },
          { specID = 183, specKey = "RogueSubtlety", icon = 132320 },
        },

        PRIEST = {
          { specID = 201, specKey = "PriestDiscipline", icon = 135987 },
          { specID = 202, specKey = "PriestHoly", icon = 237542 },
          { specID = 203, specKey = "PriestShadow", icon = 136207 },
        },

        SHAMAN = {
          { specID = 261, specKey = "ShamanElemental", icon = 136048 },
          { specID = 263, specKey = "ShamanEnhancement", icon = 136051 },
          { specID = 262, specKey = "ShamanRestoration", icon = 136052 },
        },

        MAGE = {
          { specID = 81, specKey = "MageArcane", icon = 135932 },
          { specID = 41, specKey = "MageFire", icon = 135810 },
          { specID = 61, specKey = "MageFrost", icon = 135846 },
        },

        WARLOCK = {
          { specID = 302, specKey = "WarlockAffliction", icon = 136145 },
          { specID = 303, specKey = "WarlockDemonology", icon = 136172 },
          { specID = 301, specKey = "WarlockDestruction", icon = 136186 },
        },

        DEATHKNIGHT = {
          { specID = 250, specKey = "DeathKnightBlood", icon = 135770 },
          { specID = 251, specKey = "DeathKnightFrost", icon = 135773 },
          { specID = 252, specKey = "DeathKnightUnholy", icon = 135775 },
        },
      }
    or IsMoP() and (function()
      return BuildClassSpecIDs_MoP()
    end)()
    or {}

  -- -------------------------
  -- Manager: dropdown + rename + items + assign
  -- -------------------------

  local selectedProfileKey = nil

  local function GetAllProfilesSorted(db)
    local out = {}
    local t = db.global.wowSims.profiles or {}
    for k, v in pairs(t) do
      if type(v) == "table" then
        v.key = v.key or k
        table.insert(out, v)
      end
    end
    table.sort(out, function(a, b)
      local an = a.displayName or a.key or ""
      local bn = b.displayName or b.key or ""
      return an < bn
    end)
    return out
  end

  local function BuildProfileDropdownValues(db)
    local vals = {}
    for _, p in ipairs(GetAllProfilesSorted(db)) do
      vals[p.key] = p.displayName or p.key
    end
    return vals
  end

  local wowSimImportBuffer = ""
  local wowSimParsedData = nil
  local wowSimImportStatus = nil

  local selectedSpec = nil
  local previewProfileKey = nil

  local importMode = "json" -- "json" | "empty"
  local selectedClass = nil

  local function NotifySimChanged()
    if WeakAuras and WeakAuras.ScanEvents then
      WeakAuras.ScanEvents("MERFIN_WOWSIM_CHANGED")
    end
  end

  local STAT_BY_ID = {
    [336] = _G.ITEM_MOD_CRIT_RATING_SHORT,
    [337] = _G.ITEM_MOD_HIT_RATING_SHORT,
    [338] = _G.ITEM_MOD_EXPERTISE_RATING_SHORT,
    [339] = _G.ITEM_MOD_MASTERY_RATING_SHORT,
    [340] = _G.ITEM_MOD_HASTE_RATING_SHORT,
    [341] = _G.ITEM_MOD_PARRY_RATING_SHORT,
    [342] = _G.ITEM_MOD_DODGE_RATING_SHORT,
    [343] = _G.ITEM_MOD_SPIRIT_SHORT,
  }

  function Merfin:GetSuffixName(suffixID)
    if not suffixID then
      return nil
    end
    return STAT_BY_ID[math.abs(suffixID)]
  end

  local function BuildWowSimManagerArgsV2()
    local args = {}
    local db = MerfinPlus.db

    -- auto select active profile into dropdown
    if not selectedProfileKey then
      local active = Merfin.GetActiveSimProfile()
      if active and active.key then
        selectedProfileKey = active.key
      end
    end

    args.header = { type = "header", name = L["Import WoWSim JSON"], order = 0 }

    args.profileSelect = {
      type = "select",
      name = L["Profiles"],
      order = 1,
      width = "full",
      values = function()
        return BuildProfileDropdownValues(MerfinPlus.db)
      end,
      get = function()
        return selectedProfileKey
      end,
      set = function(_, v)
        selectedProfileKey = v
        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.assignedInfo = {
      type = "description",
      order = 2,
      name = function()
        local charKey = GetCharKey()
        local assigned = db.global.wowSims.assigned[charKey]
        if not assigned then
          return "|cffff8800" .. L["This character has no assigned profiles."] .. "|r"
        end

        local lines = {}
        for specID, key in pairs(assigned) do
          local p = db.global.wowSims.profiles[key]
          local label = p and p.specKey or tostring(specID)
          table.insert(lines, label .. ": " .. (p.displayName or key))
        end

        table.sort(lines)
        return "|cff00ff00" .. L["Assigned profiles:"] .. "|r\n" .. table.concat(lines, "\n")
      end,
    }

    args.assign = {
      type = "execute",
      name = function()
        if not selectedProfileKey then
          return L["Assign to Current Character"]
        end

        local charKey = GetCharKey()
        local assigned = MerfinPlus.db.global.wowSims.assigned[charKey]
        local p = MerfinPlus.db.global.wowSims.profiles[selectedProfileKey]

        if assigned and p and assigned[p.specID] == selectedProfileKey then
          return L["Assigned "] .. "(" .. (p.specKey or p.specID) .. ")"
        end

        return L["Assign to Current Character"]
      end,
      order = 3,
      disabled = function()
        if not selectedProfileKey then
          return true
        end
        local p = db.global.wowSims.profiles[selectedProfileKey]
        if not p then
          return true
        end
        if not PlayerClassMatches(p) then
          return true
        end
        return false
      end,
      func = function()
        local charKey = GetCharKey()
        local p = db.global.wowSims.profiles[selectedProfileKey]
        db.global.wowSims.assigned[charKey] = db.global.wowSims.assigned[charKey] or {}

        db.global.wowSims.assigned[charKey][p.specID] = selectedProfileKey

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.rename = {
      type = "input",
      name = L["Rename (display only)"],
      order = 4,
      width = "full",
      disabled = function()
        return not selectedProfileKey
      end,
      get = function()
        local p = db.global.wowSims.profiles[selectedProfileKey]
        return p and (p.displayName or p.key) or ""
      end,
      set = function(_, v)
        local p = db.global.wowSims.profiles[selectedProfileKey]
        if p and v and v ~= "" then
          p.displayName = v
        end

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    args.itemsGroup = {
      type = "group",
      name = "Items",
      order = 10,
      inline = true,
      args = {},
      disabled = function()
        return not selectedProfileKey
      end,
    }

    local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]

    local slotIDs = {}
    for slotID in pairs(SLOT_NAMES) do
      table.insert(slotIDs, slotID)
    end
    table.sort(slotIDs)

    local o = 1
    for _, slotID in ipairs(slotIDs) do
      args.itemsGroup.args["slot_" .. slotID] = {
        type = "input",
        width = "full",
        order = o,
        name = function()
          local label = SLOT_NAMES[slotID]
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          local id = p and p.items and p.items[slotID]

          if not id then
            return label .. " - (" .. L["Empty"] .. ")"
          end

          local name, icon = SafeItemInfo(id)
          if name and icon then
            return ("|T%d:18|t %s - %s (ID: %d)"):format(icon, label, name, id)
          end

          return label .. " - (ID: " .. id .. " - " .. L["loading"] .. "...)"
        end,
        desc = L["Set itemID for "] .. (SLOT_NAMES[slotID] or (L["slot "] .. slotID)),
        get = function()
          local pp = db.global.wowSims.profiles[selectedProfileKey]
          local id = pp and pp.items and pp.items[slotID]
          return id and tostring(id) or ""
        end,
        set = function(_, v)
          local pp = db.global.wowSims.profiles[selectedProfileKey]
          if not pp then
            return
          end
          pp.items = pp.items or {}

          local n = tonumber(v)
          if n and n > 0 then
            pp.items[slotID] = n
            C_Item.RequestLoadItemDataByID(n)
          else
            pp.items[slotID] = nil
          end

          if n and n > 0 then
            pp.items[slotID] = n
            pp.itemSuffixes = pp.itemSuffixes or {}
            pp.itemSuffixes[slotID] = nil
          else
            pp.items[slotID] = nil
            if pp.itemSuffixes then
              pp.itemSuffixes[slotID] = nil
            end
          end

          NotifySimChanged()

          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
          AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_suffix"] = {
        type = "select",
        name = L["Suffix"],
        order = o + 0.1,
        width = "half",

        hidden = IsMoP() and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.itemSuffixes or p.itemSuffixes[slotID] == nil
        end or true,

        values = function()
          local vals = {}
          for id, name in pairs(STAT_BY_ID) do
            vals[-id] = name
          end
          return vals
        end,

        get = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          return p.itemSuffixes[slotID]
        end,

        set = function(_, v)
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes[slotID] = v
          NotifySimChanged()
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_addsuffix"] = {
        type = "execute",
        name = "+ Suffix",
        order = o + 0.05,
        width = 0.8,
        hidden = IsMoP() and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.items or not p.items[slotID] or (p.itemSuffixes and p.itemSuffixes[slotID])
        end or true,
        func = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes = p.itemSuffixes or {}

          p.itemSuffixes[slotID] = -336 -- crit

          NotifySimChanged()
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
      args.itemsGroup.args["slot_" .. slotID .. "_suffix_remove"] = {
        type = "execute",
        name = "|cffff4040X|r",
        desc = "|cffff4040" .. L["Delete this item entry."] .. "|r",
        order = o + 0.15,
        width = 0.3,
        hidden = IsMoP() and function()
          local p = selectedProfileKey and db.global.wowSims.profiles[selectedProfileKey]
          return not p or not p.itemSuffixes or p.itemSuffixes[slotID] == nil
        end or true,
        func = function()
          local p = db.global.wowSims.profiles[selectedProfileKey]
          p.itemSuffixes[slotID] = nil
          NotifySimChanged()
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
      o = o + 1
    end

    args.delete = {
      type = "execute",
      name = L["Delete Profile"],
      order = 999,
      confirm = true,
      confirmText = L["Delete this profile?"],
      disabled = function()
        return not selectedProfileKey
      end,
      func = function()
        db.global.wowSims.profiles[selectedProfileKey] = nil

        -- cleanup assignments
        for ck, specs in pairs(db.global.wowSims.assigned) do
          if type(specs) == "table" then
            for spec, key in pairs(specs) do
              if key == selectedProfileKey then
                specs[spec] = nil
              end
            end
            if next(specs) == nil then
              db.global.wowSims.assigned[ck] = nil
            end
          end
        end

        selectedProfileKey = nil

        NotifySimChanged()

        AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
      end,
    }

    return args
  end

  local CLASS_ICONS = {
    WARRIOR = 626008,
    PALADIN = 626003,
    HUNTER = 626000,
    ROGUE = 626005,
    PRIEST = 626004,
    DEATHKNIGHT = 135771,
    SHAMAN = 626006,
    MAGE = 626001,
    WARLOCK = 626007,
    MONK = 626002,
    DRUID = 625999,
  }

  local function BuildSpecSelectArgs()
    local args = {}

    local class = importMode == "json"
        and wowSimParsedData
        and wowSimParsedData.player
        and NormalizeSimClass(wowSimParsedData.player.class)
      or selectedClass

    local specs = class and CLASS_SPEC_IDS[class]
    if not specs then
      return args
    end

    for _, s in ipairs(specs) do
      args["spec_" .. s.specKey] = {
        type = "execute",
        name = "",
        image = s.icon,
        imageWidth = 32,
        imageHeight = 32,
        func = function()
          selectedSpec = s
          previewProfileKey = MakeProfileKey(s.specKey, class)
          AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
        end,
      }
    end
    return args
  end
  -- -------------------------
  -- Import state + UI
  -- -------------------------
  -- WoW Sim
  wowSimOptions = {
    type = "group",
    name = "WoW Sim",
    childGroups = "tab",
    hidden = function()
      return not IsWrath() and not IsMoP()
    end,
    args = {

      -- =====================
      -- TAB 1: IMPORT
      -- =====================
      Import = {
        type = "group",
        name = L["Import"],
        order = 1,
        args = {

          header = {
            type = "header",
            name = L["Import WoWSim JSON"],
            order = 1,
          },

          description = {
            type = "description",
            order = 2,
            width = 1.5,
            name = function()
              if importMode == "empty" then
                return L["Create an empty WoWSim profile.\nSelect a class, choose a specialization, then click Import."]
              end
              return L["Paste a WoWSim JSON export below.\nClick Accept, select a specialization icon, then click Import."]
            end,
          },

          emptyProfileBtn = {
            type = "execute",
            name = L["Empty Profile"],
            order = 3,
            width = 0.5,
            func = function()
              importMode = "empty"
              wowSimImportBuffer = ""
              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil
              selectedClass = nil

              wowSimOptions.args.Import.args.specSelect.args = {}
              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
            end,
          },

          jsonInput = {
            type = "input",
            name = "JSON",
            multiline = 18,
            width = "full",
            order = 10,
            get = function()
              return wowSimImportBuffer
            end,
            set = function(_, v)
              importMode = "json"
              wowSimImportBuffer = v

              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil

              if not v or v == "" then
                wowSimImportStatus = "empty"
                wowSimOptions.args.Import.args.specSelect.args = {}
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              if not C_EncodingUtil then
                wowSimImportStatus = "EncodingUtil"
                return
              end
              local ok, data = pcall(C_EncodingUtil.DeserializeJSON, v)
              if not ok or type(data) ~= "table" then
                wowSimImportStatus = "error"
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              local class = data and data.player and NormalizeSimClass(data.player.class)
              if not class or not CLASS_SPEC_IDS[class] then
                wowSimImportStatus = "unknown_class"
                wowSimParsedData = data -- keep for display
                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                return
              end

              wowSimParsedData = data
              wowSimImportStatus = "ready"

              wowSimOptions.args.Import.args.specSelect.args = BuildSpecSelectArgs()

              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
              AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
            end,
          },

          classSelect = {
            type = "group",
            name = L["Class"],
            order = 12,
            inline = true,
            hidden = function()
              return importMode ~= "empty"
            end,
            args = (function()
              local args = {}

              for classFile, specs in pairs(CLASS_SPEC_IDS) do
                local icon = CLASS_ICONS[classFile]
                if icon then
                  args["class_" .. classFile] = {
                    type = "execute",
                    name = "",
                    image = icon,
                    imageWidth = 32,
                    imageHeight = 32,
                    func = function()
                      selectedClass = classFile
                      selectedSpec = nil
                      previewProfileKey = nil

                      wowSimOptions.args.Import.args.specSelect.args = BuildSpecSelectArgs()
                      AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                    end,
                  }
                end
              end

              return args
            end)(),
          },

          specSelect = {
            type = "group",
            name = L["Specialization"],
            order = 15,
            inline = true,
            hidden = function()
              if importMode == "empty" then
                return not selectedClass
              end
              return not wowSimParsedData or wowSimImportStatus ~= "ready"
            end,
            args = {},
          },

          profileName = {
            type = "description",
            order = 16,
            name = function()
              if previewProfileKey then
                return "|cff00ff00" .. L["Profile: "] .. "|r " .. previewProfileKey
              end
              if wowSimImportStatus == "ready" then
                return "|cffff8800" .. L["Select a specialization."] .. "|r"
              end
              return " "
            end,
          },

          importBtn = {
            type = "execute",
            name = L["Import"],
            order = 20,
            disabled = function()
              if importMode == "empty" then
                return not (selectedClass and selectedSpec)
              end
              return not (wowSimParsedData and selectedSpec and previewProfileKey and wowSimImportStatus == "ready")
            end,
            func = function()
              if importMode == "empty" then
                local class = selectedClass
                local finalKey = MakeProfileKey(selectedSpec.specKey, class)

                MerfinPlus.db.global.wowSims.profiles[finalKey] = {
                  key = finalKey,
                  class = class,
                  specID = selectedSpec.specID,
                  specKey = selectedSpec.specKey,
                  icon = selectedSpec.icon,
                  items = {},
                  importedAt = time(),
                }

                selectedProfileKey = finalKey
                importMode = "json"

                NotifySimChanged()

                AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
                AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
                return
              end

              local data = wowSimParsedData
              if not data then
                return
              end

              local class = NormalizeSimClass(data.player.class)
              if not class then
                return
              end

              local finalKey = MakeProfileKey(selectedSpec.specKey, class)

              local items, suffixes = ExtractSlotItemsFromSim(data)
              MerfinPlus.db.global.wowSims.profiles[finalKey] = {
                key = finalKey,
                class = class,
                specID = selectedSpec.specID,
                specKey = selectedSpec.specKey,
                icon = selectedSpec.icon,
                items = items,
                itemSuffixes = suffixes,
                importedAt = time(),
              }

              -- AUTO-ASSIGN if same class
              local _, playerClass = UnitClass("player")
              if playerClass == class then
                local charKey = GetCharKey()
                MerfinPlus.db.global.wowSims.assigned[charKey] = MerfinPlus.db.global.wowSims.assigned[charKey] or {}

                MerfinPlus.db.global.wowSims.assigned[charKey][selectedSpec.specID] = finalKey
              end

              wowSimImportBuffer = ""
              wowSimParsedData = nil
              selectedSpec = nil
              previewProfileKey = nil
              wowSimImportStatus = "ok"

              wowSimOptions.args.Manager.args = BuildWowSimManagerArgsV2()

              NotifySimChanged()

              AceConfigRegistry:NotifyChange("MerfinPlus_WoWSim")
              AceConfigRegistry:NotifyChange("MerfinPlus_Standalone")
            end,
          },

          importStatus = {
            type = "description",
            order = 21,
            name = function()
              if wowSimImportStatus == "ok" then
                return "|cff00ff00" .. L["Import successful."] .. "|r"
              elseif wowSimImportStatus == "ready" then
                return "|cff00ff00 " .. L["Ready."] .. "|r"
              elseif wowSimImportStatus == "unknown_class" then
                return "|cffff0000 " .. L["Unknown / unsupported class in JSON."] .. "|r"
              elseif wowSimImportStatus == "error" then
                return "|cffff0000" .. L["Invalid JSON."] .. "|r"
              elseif wowSimImportStatus == "empty" then
                return "|cffff8800" .. L["No JSON provided."] .. "|r"
              elseif wowSimImportStatus == "EncodingUtil" then
                return "|cffff8800 " .. L["C_EncodingUtil not available in this WoW version."] .. "|r"
              end
              return " "
            end,
          },
        },
      },

      -- =====================
      -- TAB 2: IMPORT MANAGER
      -- =====================
      Manager = {
        type = "group",
        name = L["Import Manager"],
        order = 2,
        args = BuildWowSimManagerArgsV2(),
      },
    },
  }

  -- ==== Profiles (AceDB) ====
  local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
  profilesOptions.name = L["Profiles"] or "Profiles" -- ensure the node has a name

  -- ==== Register Blizzard panels (left AddOns pane) ====
  AceConfigRegistry:RegisterOptionsTable("MerfinPlus", mainOptions)
  self.optionsFrame = AceConfigDialog:AddToBlizOptions("MerfinPlus", "MerfinPlus v" .. version)

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Media", mediaOptions)
  AceConfigDialog:AddToBlizOptions("MerfinPlus_Media", "Media", "MerfinPlus v" .. version)

  if IsWrath() or IsMoP() then
    AceConfigRegistry:RegisterOptionsTable("MerfinPlus_WoWSim", wowSimOptions)
    AceConfigDialog:AddToBlizOptions("MerfinPlus_WoWSim", "WoW Sim", "MerfinPlus v" .. version)
  end

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Profiles", profilesOptions)
  AceConfigDialog:AddToBlizOptions("MerfinPlus_Profiles", "Profiles", "MerfinPlus v" .. version)

  -- ==== Standalone window (own AceConfigDialog frame) ====
  -- IMPORTANT: include whole profilesOptions object, not just .args, to keep its handler intact.
  local standaloneOptions = {
    type = "group",
    name = "MerfinPlus v" .. version,
    childGroups = "tree",
    args = {
      media = (function()
        mediaOptions.order = 10
        mediaOptions.childGroups = nil
        return mediaOptions
      end)(),
      profiles = (function()
        profilesOptions.order = 100
        return profilesOptions
      end)(),
    },
  }
  if IsWrath() or IsMoP() then
    standaloneOptions.args.wowSim = (function()
      wowSimOptions.order = 30
      return wowSimOptions
    end)()
  end

  AceConfigRegistry:RegisterOptionsTable("MerfinPlus_Standalone", standaloneOptions)
  AceConfigDialog:SetDefaultSize("MerfinPlus_Standalone", 700, 500)

  -- Toggle standalone and optionally preselect section/subtab
  function MerfinPlus:ToggleStandalone(which, sub)
    local ACD = AceConfigDialog
    if ACD.OpenFrames and ACD.OpenFrames["MerfinPlus_Standalone"] then
      ACD:Close("MerfinPlus_Standalone")
    else
      ACD:Open("MerfinPlus_Standalone")
    end
    if which == "media" or which == "raid" or which == "profiles" then
      if which == "raid" and sub then
        ACD:SelectGroup("MerfinPlus_Standalone", "raid", sub)
      else
        ACD:SelectGroup("MerfinPlus_Standalone", which)
      end
    end

    if which == "media" or which == "profiles" then
      ACD:SelectGroup("MerfinPlus_Standalone", which)
    end
  end

  -- ==== Slash commands ====
  local function _norm(msg)
    return strlower(strtrim(msg or ""))
  end

  -- /merfinplus [media|profiles]
  AceConsole:RegisterChatCommand("merfinplus", function(msg)
    msg = _norm(msg)
    local which, sub = strmatch(msg, "^(%S+)%s+(%S+)$")
    which = which or msg
    if which == "media" or which == "profiles" then
      MerfinPlus:ToggleStandalone(which)
    else
      MerfinPlus:ToggleStandalone(nil)
    end
  end)

  AceConsole:RegisterChatCommand("mp", function(msg)
    msg = _norm(msg)
    local which, sub = strmatch(msg, "^(%S+)%s+(%S+)$")
    which = which or msg
    if which == "media" or which == "profiles" then
      MerfinPlus:ToggleStandalone(which)
    else
      MerfinPlus:ToggleStandalone(nil)
    end
  end)
end

-- ==== Media registration ====
function MerfinPlus:RegisterCustomFonts()
  local db = self:GetDB()
  local fonts = {
    { key = "font1", name = "Merfin Font 1" },
    { key = "font2", name = "Merfin Font 2" },
    { key = "font3", name = "Merfin Raid Font" },
    { key = "font4", name = "Merfin Raid Font (Bold)" },
  }
  for _, f in ipairs(fonts) do
    local path = LSM:Fetch("font", db[f.key], true)
    if path then
      LSM:Register(
        "font",
        f.name,
        path,
        LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW
      )
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid font path", f.name))
    end
  end
end

function MerfinPlus:RegisterCustomBars()
  local db = self:GetDB()
  local bars = {
    { key = "bar1", name = "Merfin Status Bar 1" },
    { key = "bar2", name = "Merfin Status Bar 2" },
    { key = "bar3", name = "Merfin Raid Status Bar" },
  }
  for _, b in ipairs(bars) do
    local path = LSM:Fetch("statusbar", db[b.key], true)
    if path then
      LSM:Register("statusbar", b.name, path)
    else
      -- print(string.format("|cffff0000[MerfinPlus]|r Failed to register %s - invalid status bar path", b.name))
    end
  end
end

-- Mirror current selection under alias names for other addons/WA to consume
function MerfinPlus:RegisterMediaAliasesFromCallback()
  local db = self:GetDB()

  local fontMap = {
    { key = db.font1, alias = "Merfin Font 1" },
    { key = db.font2, alias = "Merfin Font 2" },
    { key = db.font3, alias = "Merfin Raid Font" },
    { key = db.font4, alias = "Merfin Raid Font (Bold)" },
  }
  local barMap = {
    { key = db.bar1, alias = "Merfin Status Bar 1" },
    { key = db.bar2, alias = "Merfin Status Bar 2" },
    { key = db.bar3, alias = "Merfin Raid Status Bar" },
  }

  LSM.RegisterCallback(self, "LibSharedMedia_Registered", function(_, mediatype, key)
    if mediatype == "font" then
      for _, e in ipairs(fontMap) do
        if e.key == key then
          local path = LSM:Fetch("font", e.key)
          if path then
            LSM:Register(
              "font",
              e.alias,
              path,
              LSM.LOCALE_BIT_western
                + LSM.LOCALE_BIT_ruRU
                + LSM.LOCALE_BIT_koKR
                + LSM.LOCALE_BIT_zhCN
                + LSM.LOCALE_BIT_zhTW
            )
          end
        end
      end
    elseif mediatype == "statusbar" or mediatype == "statusbar_atlas" then
      for _, e in ipairs(barMap) do
        if e.key == key then
          local path = LSM:Fetch("statusbar", e.key)
          if path then
            LSM:Register("statusbar", e.alias, path)
          end
        end
      end
    end
  end)
end
