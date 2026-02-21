-- Variables

local RowWidth = 134
local WindowHeight = 330

-- Functions


--local mode = 1 -- 1 = Raid, 2 = M+

local function getCharacterStats(mode)
    local _, _, classIndex = UnitClass("player");
    local classSpec = GetSpecialization()
    local stats = nil
    if Madhouse.db.archon.class_list and Madhouse.db.archon.class_list[classIndex] then
        if Madhouse.db.archon.class_list[classIndex][classSpec] then
            if Madhouse.db.archon.class_list[classIndex][classSpec][mode] then
                stats = Madhouse.db.archon.class_list[classIndex][classSpec][mode]
            end
        end
    end
    return stats
end

local currentMode = 1



local function Render(self, event)


    local stats = getCharacterStats(currentMode)

    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetWidth(RowWidth * 3)
    self.Frame:AddChild(buttonGroup)

    local ModeButton = AceGUI:Create("Button")
    ModeButton:SetText(currentMode == 1 and ("Raid") or ("Mythic+"))
    ModeButton:SetCallback("OnClick", function()
        if currentMode == 1 then
            currentMode = 2
        else
            currentMode = 1
        end
        self:Reload()
    end)
    buttonGroup:AddChild(ModeButton)

    local TalentButton = AceGUI:Create("Button")
    TalentButton:SetText(isGerman and "Talente" or "Talents")
    TalentButton:SetCallback("OnClick", function()
        local class = UnitClass("player");
        local name = currentMode == 1 and "Raid" or "Mythic+"
        local title = class .. " " .. stats["spec"] .. " Talents " .. name
        Madhouse.API.v1.ShowExportWindow(stats["talents"], title)
    end)
    buttonGroup:AddChild(TalentButton)

    local header = AceGUI:Create("Heading")
    header:SetFullWidth(true)
    header:SetText(isGerman and "Werte" or "Stats")
    self.Frame:AddChild(header)

    if stats == nil then
        local labelX = AceGUI:Create("InteractiveLabel")
        labelX:SetText("No Data")
        labelX:SetFontObject(GameFontNormal) -- Use a larger font
        labelX:SetFullWidth(true)
        self.Frame:AddChild(labelX)
        return
    end


    -- ############################# Start Rendering Stats #############################

    -- Mastery
    local masteryRating = GetCombatRating(CR_MASTERY)
    local masteryPerc = GetMasteryEffect()
    -- print("M",masteryRating,masteryPerc)

    -- Haste

    local hasteRating = GetCombatRating(CR_HASTE_SPELL)
    local hastePerc = GetRangedHaste()
    -- print("H",hasteRating,hastePerc)

    -- Versatility

    local versaRating = GetCombatRating(30)
    local versaPerc = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) -- ???
    -- print("V",versaRating,versaPerc)

    -- Crit
    local critRating = GetCombatRating(CR_CRIT_SPELL)
    local critPerc = GetCritChance()
    -- print("C",critRating,critPerc)

    local mastery = stats["mastery"] or 1
    local haste = stats["haste"] or 1
    local crit = stats["crit"] or 1
    local vers = stats["vers"] or 1

    local data = {
        [1] = {
            name = isGerman and "Meisterschaft" or "Mastery",
            rating = masteryRating,
            perc = masteryPerc,
            total = mastery,
            color = "#128f0b"
        },
        [2] = {
            name = isGerman and "Tempo" or "Haste",
            rating = hasteRating,
            perc = hastePerc,
            total = haste,
            color = "#0043FF"
        },
        [3] = {
            name = isGerman and "Krit" or "Crit",
            rating = critRating,
            perc = critPerc,
            total = crit,
            color = "#FF008C"
        },
        [4] = {
            name = isGerman and "Vielseitigkeit" or "Versatility",
            rating = versaRating,
            perc = versaPerc,
            total = vers,
            color = "#FF6D00"
        },
    }

    table.sort(data, function(a, b)
        return a.total > b.total
    end)

    for _, value in ipairs(data) do
        local label = AceGUI:Create("InteractiveLabel")
        label:SetText(value.name .. string.format(": %.0f / %.0f (%.2f%%)", value.rating, value.total, value.perc))
        label:SetFontObject(GameFontNormal) -- Use a larger font
        label:SetFullWidth(true)
        self.Frame:AddChild(label)

        local spacer = AceGUI:Create("Label")
        spacer:SetText(" ")
        spacer:SetHeight(4)
        self.Frame:AddChild(spacer)

        local v = (value.rating / value.total) * 100
        local progress = AceGUI:Create("ProgressBar")
        progress:SetSize((RowWidth * 3), 4)
        progress:SetValue(v)
        local r, g, b = Madhouse.API.v1.HexColorToRGB(value.color)
        progress:SetColor(r, g, b)
        self.Frame:AddChild(progress)
        local spacer2 = AceGUI:Create("Label")
        spacer2:SetText(" ")
        spacer2:SetHeight(2)
        self.Frame:AddChild(spacer2)
    end

    -- ############################# Start Rendering items #############################

    local headerIt = AceGUI:Create("Heading")
    headerIt:SetFullWidth(true)
    headerIt:SetText(isGerman and "Gegenstände" or "Items")
    self.Frame:AddChild(headerIt)

    local iconGroup = AceGUI:Create("SimpleGroup")
    iconGroup:SetLayout("Flow")
    iconGroup:SetWidth(RowWidth * 3)
    self.Frame:AddChild(iconGroup)

    for _, key in ipairs(stats.items) do
        local icon = C_Item.GetItemIconByID(key)
        local tooltip = Madhouse.API.v1.TooltipToText(C_TooltipInfo.GetItemByID(key))
        local equiped = Madhouse.API.v1.ItemIsEquiped(key)

        local itemIcon = AceGUI:Create("Icon")
        itemIcon:SetImage(icon)
        itemIcon:SetImageSize(32, 32)
        itemIcon:SetWidth(32)
        itemIcon:SetHeight(32)
        itemIcon:SetCallback("OnEnter",
            function()
                GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_CURSOR")
                GameTooltip:SetText(tooltip)
                GameTooltip:Show()
            end)
        itemIcon:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        if not equiped then
            itemIcon.label:SetTextColor(0.5, 0.5, 0.7)
            itemIcon.image:SetVertexColor(0.5, 0.5, 0.5, 0.7)
        end
        iconGroup:AddChild(itemIcon)
    end
end


local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title .. " - " .. Madhouse.db.archon.data_date)
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth((RowWidth * 3) + 30)
    self.Frame:SetHeight(WindowHeight)
    -- Register Events
    self.Frame.frame:SetScript("OnEvent", function(event)
        self:Reload()
    end)

    self.Frame.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    self.Frame.frame:RegisterEvent('ADDON_LOADED')
    self.Frame.frame:RegisterEvent('ARTIFACT_UPDATE')
    self.Frame.frame:RegisterEvent('ARTIFACT_XP_UPDATE')
    self.Frame.frame:RegisterEvent('SHIPMENT_CRAFTER_REAGENT_UPDATE')
    self.Frame.frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
    self.Frame.frame:RegisterEvent('TRADE_MONEY_CHANGED')
    self.Frame.frame:RegisterEvent('TRIAL_STATUS_UPDATE')
    self.Frame.frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
end

M_Register_Window({
    widget = "CharStatWindow",
    short = "charstat",
    init = InitWindow,
    render = Render,
    info = {
        title = isGerman and "Charakterstatistiken" or "Character Stats",
        icon = 892828,
        short = "Sats"
    }
})
