local ADDON_NAME = "Loadout Summary"

local DEFAULTS = {
  x = nil,
  y = nil,
  width = 250,
  height = 50,
  locked = true,
  fontsize = 16,
  font = "Fonts\\FRIZQT__.TTF",
  color = {1, 1, 1, 1},
  autoscale = true,
  updateInterval = 0.5,
  anchorPoint = "TOPLEFT",
  showItemLevel = true,
  showStats = true,
  autoReminder = true,
  groupDetection = true,
  animations = true,
  flashOnMismatch = true,
  alpha = 1,
  borderAlpha = 1,
  showFrameBg = true,
}

local db

local function SafeSetFont(fontString, fontPath, fontSize, flags)
  fontPath = fontPath or db.font
  fontSize = fontSize or db.fontsize
  flags = flags or "OUTLINE"
  local ok = pcall(fontString.SetFont, fontString, fontPath, fontSize, flags)
  if not ok then
    fontString:SetFont(DEFAULTS.font, fontSize, flags)
  end
end

local function GetEquippedSet()
  for i = 0, C_EquipmentSet.GetNumEquipmentSets() - 1 do
    local name, _, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(i)
    if equipped then
      return name
    end
  end
  return nil
end

local function GetTalentLoadout()
  local specIndex = GetSpecialization()
  if not specIndex then return "Unknown" end
  local specID = GetSpecializationInfo(specIndex)
  if not specID then return "Unknown" end
  local configID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
  if not configID then configID = C_ClassTalents.GetActiveConfigID() end
  if configID then
    local info = C_Traits.GetConfigInfo(configID)
    if info and info.name and info.name ~= "" then
      return info.name
    end
  end
  return "Active"
end

local function GetItemLevels()
  local overall, equipped = GetAverageItemLevel()
  local avg = math.floor(overall or 0)
  local eq = math.floor(equipped or 0)
  return eq, avg
end

-- Primary stats
local function GetPrimaryStats()
  local stats = {}

  -- Use PaperDollFrame stats - same as character sheet
  -- Crit
  local critChance = GetCritChance()
  local rangedCrit = GetRangedCritChance() 
  local spellCrit = GetSpellCritChance(2) -- Holy school

  -- Some classes need to check all spell schools
  for i = 2, 6 do
    local schoolCrit = GetSpellCritChance(i)
    if schoolCrit and schoolCrit > (spellCrit or 0) then
      spellCrit = schoolCrit
    end
  end

  -- Use the highest crit value
  local finalCrit = math.max(critChance, rangedCrit or 0, spellCrit or 0)
  stats.crit = string.format("%.0f%%", finalCrit)

  -- Haste - Use melee haste as base, but check ranged and spell too
  local haste = GetHaste()
  local rangedHaste = GetRangedHaste()
  local spellHaste = UnitSpellHaste("player")
  haste = math.max(haste, rangedHaste or 0, spellHaste or 0)
  stats.haste = string.format("%.0f%%", haste)

  -- Mastery
  local mastery = GetMasteryEffect()
  stats.mastery = string.format("%.0f%%", mastery)

  -- Versatility - damage bonus
  local versDamage = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
  local versReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)

  versReduction = math.ceil(versReduction)
  versDamage = math.floor(versDamage + 0.5)

  stats.vers = string.format("%.0f%% / %.0f%%", versDamage, versReduction)

  return stats
end

local function CheckMismatch(gearName, talentName)
  if not db.autoReminder or not gearName or not talentName then return false end
  local gear, talent = gearName:lower(), talentName:lower()

  local gearIsRaid = gear:find("raid")
  local gearIsKeys = gear:find("key") or gear:find("mythic%+") or gear:match("%sm%+")
  local gearIsPvP = gear:find("pvp") or gear:find("arena")

  local talentIsRaid = talent:find("raid")
  local talentIsKeys = talent:find("key") or talent:find("mythic%+") or talent:match("%sm%+")
  local talentIsPvP = talent:find("pvp") or talent:find("arena")

  if gearIsRaid and talentIsKeys then return true end
  if gearIsKeys and talentIsRaid then return true end
  if gearIsPvP and (talentIsRaid or talentIsKeys) then return true end
  if (gearIsRaid or gearIsKeys) and talentIsPvP then return true end

  return false
end

local function GetDisplayText()
  local equippedSet = GetEquippedSet()
  local talentLoadout = GetTalentLoadout()
  local eqIlvl, avgIlvl = GetItemLevels()
  local stats = db.showStats and GetPrimaryStats() or nil

  local text = string.format(
    "|cFFFFA500Equipped Set:|r %s\n|cFF00FF00Talent Loadout:|r %s",
    equippedSet or "None",
    talentLoadout
  )

  if db.showItemLevel then
    text = text .. string.format("\n|cffb366ffItem Level:|r %d / %d", eqIlvl, avgIlvl)
  end

  if stats then
    text = text .. string.format("\n|cff00ccffStats:|r C: %s | H: %s | M: %s | V: %s",
    stats.crit, stats.haste, stats.mastery, stats.vers
  )
end

return text
end

local function InitUI()
  AursUI_TLNDB = AursUI_TLNDB or {}
  for k, v in pairs(DEFAULTS) do
    if AursUI_TLNDB[k] == nil then
      AursUI_TLNDB[k] = v
    end
  end
  db = AursUI_TLNDB

  -- Options Panel
  local optionsFrame = CreateFrame("Frame", "AursUI_TLN_Options", UIParent, BackdropTemplateMixin and "BackdropTemplate")
optionsFrame:SetSize(400, 420)
optionsFrame:SetPoint("CENTER")
optionsFrame:SetMovable(true)
optionsFrame:EnableMouse(true)
optionsFrame:RegisterForDrag("LeftButton")
optionsFrame:SetClampedToScreen(true)
optionsFrame:Hide()

if not optionsFrame.NineSlice then
  optionsFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
  optionsFrame:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
  optionsFrame:SetBackdropBorderColor(0.73, 0.60, 0.97, 1)
end

optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)

local title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("|cff00d9ff" .. ADDON_NAME .. " Options|r")

local closeBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local function CreateCheckbox(parent, label, yOffset, getValue, setValue)
  local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 20, yOffset)
  cb.Text:SetText(label)
  cb:SetChecked(getValue())
  cb:SetScript("OnClick", function(self)
    setValue(self:GetChecked())
    UpdateDisplay(true)
  end)
  return cb
end

local function CreateSlider(parent, label, yOffset, min, max, getValue, setValue)
  local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", 20, yOffset)
  slider:SetMinMaxValues(min, max)
  slider:SetValue(getValue())
  slider:SetValueStep(1)
  slider:SetObeyStepOnDrag(true)
  slider:SetWidth(200)

  slider.Text:SetText(label)
  slider.Low:SetText(min)
  slider.High:SetText(max)

  local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  valueText:SetPoint("TOP", slider, "BOTTOM", 0, 0)
  valueText:SetText(getValue())

  slider:SetScript("OnValueChanged", function(_, value)
    value = math.floor(value)
    valueText:SetText(value)
    setValue(value)
    UpdateDisplay(true)
  end)

  return slider
end

local editModeText = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
editModeText:SetPoint("TOP", 0, -50)
editModeText:SetText("Open Edit mode to move the frame")
editModeText:SetTextColor(1, 1, 1, 1)

CreateCheckbox(optionsFrame, "Auto-Scale", -80,
function() return db.autoscale end,
function(val) db.autoscale = val end)

CreateCheckbox(optionsFrame, "Show Item Level", -110,
function() return db.showItemLevel end,
function(val) db.showItemLevel = val end)

CreateCheckbox(optionsFrame, "Show Stats (Crit/Haste/Mastery/Vers)", -140,
function() return db.showStats end,
function(val) db.showStats = val end)

CreateCheckbox(optionsFrame, "Mismatch Warning", -170,
function() return db.autoReminder end,
function(val) db.autoReminder = val end)

CreateCheckbox(optionsFrame, "Animations", -200,
function() return db.animations end,
function(val) db.animations = val end)

CreateCheckbox(optionsFrame, "Flash on Mismatch", -230,
function() return db.flashOnMismatch end,
function(val) db.flashOnMismatch = val end)

CreateCheckbox(optionsFrame, "Show background and border", -260,
function() return db.showFrameBg end,
function(val) db.showFrameBg = val; ApplyFrameBackdrop() end)

CreateSlider(optionsFrame, "Font Size", -300, 8, 32,
function() return db.fontsize end,
function(val) db.fontsize = val end)

-- Frame setup
local frame = CreateFrame("Frame", "LoadoutSummary", UIParent,"BackdropTemplate")
frame:SetSize(db.width, db.height)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)

local BACKDROP_TEMPLATE = {
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

function ApplyFrameBackdrop()
  if not db.showFrameBg then
    frame:SetBackdrop(nil)
    return
  end
  if not frame.NineSlice then
    frame:SetBackdrop(BACKDROP_TEMPLATE)
  end
  frame:SetBackdropColor(0.05, 0.05, 0.08, db.alpha or 1)
  frame:SetBackdropBorderColor(0.73, 0.60, 0.97, db.borderAlpha or 1)
end

ApplyFrameBackdrop()

if db.x and db.y then
  frame:SetPoint(db.anchorPoint or "TOPLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
else
  frame:SetPoint("TOPLEFT", UIParent, "CENTER", 0, 200)
end

frame:SetScript("OnDragStart", function(self)
  if not db.locked then self:StartMoving() end
end)
frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local _, _, _, x, y = self:GetPoint(1)
  db.x, db.y = x, y
end)

-- Right-click to open
frame:SetScript("OnMouseUp", function(self, button)
  if button == "RightButton" then
    if optionsFrame:IsShown() then
      optionsFrame:Hide()
    else
      optionsFrame:Show()
    end
  end
end)

CreateSlider(optionsFrame, "Background Alpha", -340, 0, 100,
function() return math.floor((db.alpha or 1) * 100) end,
function(val) db.alpha = val / 100; if db.showFrameBg then frame:SetBackdropColor(0.05, 0.05, 0.08, db.alpha) end end)

CreateSlider(optionsFrame, "Border Alpha", -380, 0, 100,
function() return math.floor((db.borderAlpha or 1) * 100) end,
function(val) db.borderAlpha = val / 100; if db.showFrameBg then frame:SetBackdropBorderColor(0.73, 0.60, 0.97, db.borderAlpha) end end)

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetPoint("TOPLEFT", 8, -8)
text:SetPoint("BOTTOMRIGHT", -8, 8)
text:SetJustifyH("LEFT")
text:SetJustifyV("TOP")

local warningText = frame:CreateFontString(nil, "OVERLAY")
warningText:SetPoint("TOP", frame, "BOTTOM", 0, -5)
SafeSetFont(warningText, db.font, 12, "OUTLINE")
warningText:SetTextColor(1, 0.2, 0.2, 1)
warningText:Hide()

local fadeIn = frame:CreateAnimationGroup()
local fadeInAlpha = fadeIn:CreateAnimation("Alpha")
fadeInAlpha:SetFromAlpha(0)
fadeInAlpha:SetToAlpha(1)
fadeInAlpha:SetDuration(0.3)
fadeInAlpha:SetSmoothing("IN")

local flashAnim = frame:CreateAnimationGroup()
flashAnim:SetLooping("REPEAT")
local flash1 = flashAnim:CreateAnimation("Alpha")
flash1:SetFromAlpha(1)
flash1:SetToAlpha(0.3)
flash1:SetDuration(0.5)
flash1:SetOrder(1)
local flash2 = flashAnim:CreateAnimation("Alpha")
flash2:SetFromAlpha(0.3)
flash2:SetToAlpha(1)
flash2:SetDuration(0.5)
flash2:SetOrder(2)

-- Update
local lastEquippedSet, lastTalent = nil, nil
local lastDisplayText = ""

function UpdateDisplay(force)
  local eq = GetEquippedSet()
  local tl = GetTalentLoadout()
  local currentDisplayText = GetDisplayText()

  -- Check if only stats changed (gear/talent stayed the same)
  local onlyStatsChanged = (eq == lastEquippedSet and tl == lastTalent and currentDisplayText ~= lastDisplayText)

  -- Update if forced, gear/talent changed, OR display text changed (catches stat changes)
  if force or eq ~= lastEquippedSet or tl ~= lastTalent or currentDisplayText ~= lastDisplayText then
    lastEquippedSet, lastTalent = eq, tl
    lastDisplayText = currentDisplayText

    SafeSetFont(text, db.font, db.fontsize, "OUTLINE")
    local c = db.color or DEFAULTS.color
    text:SetTextColor(c[1], c[2], c[3], c[4])
    text:SetText(currentDisplayText)

    if CheckMismatch(eq, tl) and db.autoReminder then
      warningText:SetText(" >Loadout Mismatch!< ")
      warningText:Show()
      if db.flashOnMismatch then flashAnim:Play() end
    else
      warningText:Hide()
      flashAnim:Stop()
      frame:SetAlpha(1)
    end

    -- Only play animation if gear/talent changed, not just stats
    if db.animations and not force and not onlyStatsChanged then 
      fadeIn:Play() 
    end

    -- Auto-scale: hug text perfectly
    if db.autoscale then
      local textWidth = math.ceil(text:GetStringWidth())
      local textHeight = math.ceil(text:GetStringHeight())

      local paddingX = 10
      local paddingY = 8

      local totalWidth = textWidth + paddingX * 2
      local totalHeight = textHeight + paddingY * 2

      if warningText:IsShown() then
        totalHeight = totalHeight + warningText:GetStringHeight() + 4
      end

      frame:SetSize(totalWidth, totalHeight)
      db.width, db.height = totalWidth, totalHeight
    else
      frame:SetSize(db.width, db.height)
    end
  end
end

-- Events & Timer
local ticker = C_Timer.NewTicker(db.updateInterval, function() UpdateDisplay(false) end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
frame:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
frame:RegisterEvent("UNIT_STATS")
frame:RegisterEvent("COMBAT_RATING_UPDATE")
frame:RegisterEvent("MASTERY_UPDATE")
frame:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")

frame:SetScript("OnEvent", function(_, event, unit)
  -- For UNIT events, only respond to player
  if event == "UNIT_STATS" and unit ~= "player" then
    return
  end

  if event == "PLAYER_ENTERING_WORLD" then
    C_Timer.After(0.3, function() UpdateDisplay(true) end)

    -- Hook into Edit Mode
    local LEM = LibStub('LibEditMode')

    if LEM then
      local function onPositionChanged(frame, layoutName, point, x, y)
        if not AursUI_TLNDB.layouts then
          AursUI_TLNDB.layouts = {}
        end
        if not AursUI_TLNDB.layouts[layoutName] then
          AursUI_TLNDB.layouts[layoutName] = {}
        end

        AursUI_TLNDB.layouts[layoutName].point = point
        AursUI_TLNDB.layouts[layoutName].x = x
        AursUI_TLNDB.layouts[layoutName].y = y
      end

      local defaultPosition = {
        point = 'CENTER',
        x = 0,
        y = 0,
      }

      LEM:RegisterCallback('layout', function(layoutName)
        if not AursUI_TLNDB.layouts then
          AursUI_TLNDB.layouts = {}
        end
        if not AursUI_TLNDB.layouts[layoutName] then
          AursUI_TLNDB.layouts[layoutName] = {point = "CENTER", x = 0, y = 0}
        end

        frame:ClearAllPoints()
        frame:SetPoint(
          AursUI_TLNDB.layouts[layoutName].point or "CENTER",
          UIParent,
          AursUI_TLNDB.layouts[layoutName].point or "CENTER", 
          AursUI_TLNDB.layouts[layoutName].x or 0,
          AursUI_TLNDB.layouts[layoutName].y or 0)
        end)
        LEM:AddFrame(frame, onPositionChanged, defaultPosition)
      end

    elseif event == "PLAYER_EQUIPMENT_CHANGED" 
      or event == "EQUIPMENT_SETS_CHANGED" 
      or event == "EQUIPMENT_SWAP_FINISHED"
      or event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
      C_Timer.After(0.25, function() UpdateDisplay(true) end)
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED"
      or event == "PLAYER_SPECIALIZATION_CHANGED"
      or event == "ZONE_CHANGED_NEW_AREA"
      or event == "TRAIT_CONFIG_UPDATED" then
      C_Timer.After(0.15, function() UpdateDisplay(true) end)
    elseif event == "UNIT_STATS"
      or event == "COMBAT_RATING_UPDATE"
      or event == "MASTERY_UPDATE" then
      -- Stat changes should update immediately
      UpdateDisplay(false)
    else
      UpdateDisplay(true)
    end
  end)

  C_Timer.After(0.3, function() UpdateDisplay(true) end)
  frame:Show()

  -- Slash Commands
  SLASH_LSOPTIONS1 = "/ls"
  SlashCmdList["LSOPTIONS"] = function()
    if optionsFrame:IsShown() then
      optionsFrame:Hide()
    else
      optionsFrame:Show()
    end
  end

  C_Timer.After(1, function()
    print("|cff00d9ff" .. ADDON_NAME .. " loaded!|r |cffFFFFFF Right-click the frame or type /ls for options.|r")
  end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, addonName)
  if addonName ~= "Loadout_Summary" then return end
  InitUI()
end)
