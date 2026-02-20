local function DebugPrint(message)
    --[[print("[DEBUG] " .. message)]]
end

local equipmentSlotNames = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [4] = "Shirt",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger 1",
    [12] = "Finger 2",
    [13] = "Trinket 1",
    [14] = "Trinket 2",
    [15] = "Back",
    [16] = "Main Hand",
    [17] = "Off Hand",
    [18] = "Ranged",
    [19] = "Tabard"
}

local mapping = {
    stone = 3008,
    t1 = 3284,
    t2 = 3286,
    t3 = 3288,
    t4 = 3290
}

local mappingOrder = {
    [1] = "stone",
    [2] = "t1",
    [3] = "t2",
    [4] = "t3",
    [5] = "t4"
}

local crestMapping = {
    stone = {
        [1]={ name = "HC", value = 30},
        [2]={ name = "+5", value = 69},
        [3]={ name = "+6", value = 73},
        [5]={ name = "+8", value = 82},
        [6]={ name = "+9", value = 86},
    },
    t1 = {
        [1]={ name = "HC", value = 10}
    },
    t2 = {
        [1]= { name = "+0", value = 10 },
        [2]= { name = "+2", value = 12 },
        [3]= { name = "+3", value = 14 },
    },
    t3 = {
        [1]= { name = "+4", value = 12 },
        [2]= { name = "+5", value = 14 },
        [3]= { name = "+6", value = 16 },
        [4]= { name = "+7", value = 18 },
    },
    t4 = {
        [1]= { name = "+8", value = 12 },
        [2]= { name = "+9", value = 14 },
        [3]= { name = "+10", value = 16 },
        [4]= { name = "+11", value = 18 },
        [5]= { name = "+12", value = 20 },
    },
}

local upgrade_data = nil


local function processCurrency(currencyID, totalCost)
    if not upgrade_data then
       return
    end
    if currencyID == mapping["stone"] then
        upgrade_data.stone = upgrade_data.stone + totalCost
    elseif currencyID == mapping["t1"] then
        upgrade_data.t1 = upgrade_data.t1 + totalCost
    elseif currencyID == mapping["t2"] then
        upgrade_data.t2 = upgrade_data.t2 + totalCost
    elseif currencyID == mapping["t3"] then
        upgrade_data.t3 = upgrade_data.t3 + totalCost
    elseif currencyID == mapping["t4"] then
        upgrade_data.t4 = upgrade_data.t4 + totalCost
    else
        upgrade_data.unknownCurrency[currencyID] = (upgrade_data.unknownCurrency[currencyID] or 0) +
        totalCost
    end
end

local function accumulateCosts(upgradeLevelInfos, itemName, itemLevel)
    if not upgrade_data then
       return
    end
    for _, levelInfo in ipairs(upgradeLevelInfos) do
        if levelInfo.currencyCostsToUpgrade then
            if not upgrade_data.itemUpgradeCosts[itemName] then
                upgrade_data.itemUpgradeCosts[itemName] = {}
            end

            for _, currencyCost in ipairs(levelInfo.currencyCostsToUpgrade) do
                local currencyID = currencyCost.currencyID
                local cost = currencyCost.cost
                upgrade_data.itemUpgradeCosts[itemName][currencyID] = upgrade_data
                .itemUpgradeCosts[itemName][currencyID] or 0
                upgrade_data.itemUpgradeCosts[itemName][currencyID] = upgrade_data
                .itemUpgradeCosts[itemName][currencyID] + cost
                processCurrency(currencyID, cost)
            end
        else
            DebugPrint("No currency costs to upgrade found for item: " .. (levelInfo.name or "Unknown Item"))
        end
    end
    upgrade_data.iLvl[itemName] = itemLevel
    DebugPrint("Saved itemLevel for " .. itemName .. ": " .. itemLevel)
end

local function tallyUpgradeCosts()
    upgrade_data = {
                       ["itemUpgradeCosts"] = {},
                       ["iLvl"] = {},
                       ["stone"] = 0,
                       ["t1"] = 0,
                       ["t2"] = 0,
                       ["t3"] = 0,
                       ["t4"] = 0,
                       ["unknownCurrency"] = {}
                   }

    local isUpdating = C_ItemUpgrade.GetItemUpgradeItemInfo()

    if isUpdating ~= nil then
        local i = isUpdating.highWatermarkSlot
        local currentLevel, _ = C_ItemUpgrade.GetItemUpgradeCurrentLevel()
        if isUpdating.upgradeLevelInfos and currentLevel then
            local costInfo = ItemUpgradeFrame:GetUpgradeCostTables()
            if costInfo then

                for itemID, itemCostEntry in pairs(costInfo) do
                    if itemID ~= 3008 and itemCostEntry.cost == 0 then
                        DebugPrint((equipmentSlotNames[i] or '???')  ..  " has a free crest upgrade available!")
                    end
                end

            end

            accumulateCosts(isUpdating.upgradeLevelInfos, isUpdating.name, currentLevel)
        else
            DebugPrint("No upgrade info found for item in slot " .. i)
        end

        return
    end

    for i = 1, 18 do
        C_ItemUpgrade.ClearItemUpgrade()
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(i)
        if itemLoc:IsValid() then
            C_ItemUpgrade.SetItemUpgradeFromLocation(itemLoc)
            local info = C_ItemUpgrade.GetItemUpgradeItemInfo()
            local currentLevel, _ = C_ItemUpgrade.GetItemUpgradeCurrentLevel()
            if info and info.upgradeLevelInfos and currentLevel then
                local costInfo = ItemUpgradeFrame:GetUpgradeCostTables()
                if costInfo then

                    for itemID, itemCostEntry in pairs(costInfo) do
                        if itemID ~= 3008 and itemCostEntry.cost == 0 then
                            DebugPrint(equipmentSlotNames[i] ..  " has a free crest upgrade available!")
                        end
                    end

                end

                accumulateCosts(info.upgradeLevelInfos, info.name, currentLevel)
            else
                DebugPrint("No upgrade info found for item in slot " .. i)
            end
        else
            DebugPrint("Invalid item location in slot " .. i)
        end
    end
    Madhouse.addon:SaveUserData("upgrade_data", upgrade_data)
end


local UPGRADE_WINDOW=false

local function SetWShow()
    UPGRADE_WINDOW = true
    tallyUpgradeCosts()
end
local function UnSetWShow()
    UPGRADE_WINDOW = false
end

-- Variables

local RowWidth = 144
local WindowHeight = 180

-- Local functions

-- Methods
local function Render(self)

    upgrade_data = Madhouse.addon:LoadUserData("upgrade_data")

    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    self.Frame:AddChild(row)

    if not upgrade_data then
        local label = AceGUI:Create("Label")
        label:SetText(isGerman and "Keine Daten gefunden. Bitte öffne das Item Upgrade Menü in Dronogal" or "No upgrade data found. Please open the upgrade window in Dornogal.")
        label:SetFontObject(GameFontNormalLarge)  -- Use a larger font
        label:SetFullWidth(true)
        row:AddChild(label)
        self.Frame:SetHeight(WindowHeight)
        return
    end

    local counter = 0
    for k, v in ipairs(mappingOrder) do

    local key = v
    local value = mapping[key]

        if upgrade_data[key] > 0  then
           counter = counter + 1
           local fi = C_CurrencyInfo.GetCurrencyInfo(value)

           local label = AceGUI:Create("InteractiveLabel")
           local txt = Madhouse.API.v1.ColorPrintRGB(fi.name,"FFFFFF")..'\n\n'..Madhouse.API.v1.BreakLongTooltipText(fi.description);


           local todo=""
           local defizit = upgrade_data[key] - fi.quantity

           if defizit > 0 then
           txt = txt .. "\n\n" .. (isGerman and "Mit einer der Folgenden Optionen bekommst du alle benötigten Resourcen" or "With one of the following options you can get needed resources") .. "\n"
             todo = " || "
             local cM = crestMapping[key]
             for _, mp in ipairs(cM) do
                local runs =  Madhouse.API.v1.RoundUpNumber(defizit,mp.value)
                todo = todo .. Madhouse.API.v1.ColorPrintRGB( runs .. "x ","FFFF00") .. mp.name .. " | "
                txt = txt .. "\n" .. Madhouse.API.v1.ColorPrintRGB( runs .. "x ","FFFF00") .. mp.name
             end
           end
           label:SetCallback("OnEnter", function() GameTooltip:SetOwner(label.frame, "ANCHOR_CURSOR") GameTooltip:SetText(txt) GameTooltip:Show() end)
           label:SetCallback("OnLeave", function() GameTooltip:Hide() end)
           label:SetText(Madhouse.API.v1.PrintIcon(fi.iconFileID) .. ' ' .. fi.quantity .. " / " .. upgrade_data[key]..todo)
           label:SetFontObject(GameFontNormal)  -- Use a larger font
           label:SetFullWidth(true)
           row:AddChild(label)

           local spacer =  AceGUI:Create("Label")
           spacer:SetText(" ")
           spacer:SetHeight(2)
           row:AddChild(spacer)

           local progress = AceGUI:Create("ProgressBar")
           progress:SetSize((RowWidth * 3),4)
           if defizit > 0 then
              progress:SetValue((fi.quantity / upgrade_data[key]) * 100)
           else
              progress:SetValue(100)
           end
           row:AddChild(progress)

           local spacer2 =  AceGUI:Create("Label")
           spacer2:SetText(" ")
           spacer2:SetHeight(2)
           row:AddChild(spacer2)
        end
    end

    if counter == 0 then
            local label = AceGUI:Create("Label")
            label:SetText(isGerman and "Deine Ausrüstung ist bereits auf Maximaler Stufe." or "Your gear is already at max level.")
            label:SetFontObject(GameFontNormalLarge)  -- Use a larger font
            label:SetFullWidth(true)
            row:AddChild(label)
            self.Frame:SetHeight(WindowHeight)
            return
    else
        self.Frame:SetHeight(46 + 40 * counter)
    end

end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title)
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth((RowWidth * 3) + 25)
    self.Frame:SetHeight(WindowHeight)
    self.Frame.frame:RegisterEvent("ADDON_LOADED")
    self.Frame.frame:RegisterEvent('BAG_UPDATE')
    self.Frame.frame:RegisterEvent('TRADE_CURRENCY_CHANGED')
    self.Frame.frame:RegisterEvent('TRADE_PLAYER_ITEM_CHANGED')
    self.Frame.frame:RegisterEvent('ARTIFACT_UPDATE')
    self.Frame.frame:RegisterEvent('ARTIFACT_XP_UPDATE')
    self.Frame.frame:RegisterEvent('PLAYER_TRADE_CURRENCY')
    self.Frame.frame:RegisterEvent('CHAT_MSG_CURRENCY')
    self.Frame.frame:RegisterEvent('SHIPMENT_CRAFTER_REAGENT_UPDATE')
    self.Frame.frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
    self.Frame.frame:RegisterEvent('PLAYER_MONEY')
    self.Frame.frame:RegisterEvent('PLAYER_TRADE_MONEY')
    self.Frame.frame:RegisterEvent('TRADE_MONEY_CHANGED')
    self.Frame.frame:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
    self.Frame.frame:RegisterEvent('SEND_MAIL_COD_CHANGED')
    self.Frame.frame:RegisterEvent('TRIAL_STATUS_UPDATE')
    self.Frame.frame:SetScript("OnEvent", function(_, event, addon)
        if event =="ADDON_LOADED" and addon == "Blizzard_ItemUpgradeUI" then
            hooksecurefunc("ItemUpgradeFrame_Show", SetWShow)
            hooksecurefunc("ItemUpgradeFrame_Hide", UnSetWShow)
        end
        if UPGRADE_WINDOW then
            tallyUpgradeCosts()
        end
        self:FlashFrame()
        self:Render()
    end)
end

M_Register_Window({
    widget = "UpgradeWindow",
    short = "upgrade",
    init = InitWindow,
    render = Render,
    info = {
       title = isGerman and "Aufwertungs Fenster" or "Upgrade Window",
       icon = 1455684,
       short = "Upgrade"
    }
})
