-- Variables

local RowWidth = 280
local WindowHeight = 400

-- Functions

local WoodDB = {
    248012,
    251767,
    245586,
    251773,
    251763,
    242691,
    251766,
    251772,
    251764,
    251768,
    251762,
    256963
}

local PopContainerItems = {
    -- TWW
    228959, -- Haufen Fleisch
    218738, -- geformter Magen
    224780, -- Gehärteter GewitterPelz
    -- MN
}

local special = false

local function getBagList()
    local totalStacks = {}
    local totalContainer = {}
    local totalContainerV = 0

    -- Iterate through the bags (0 to 4 represent the main backpack and additional bags)
    for bag = 0, 5 do
        -- Get the number of slots in the current bag
        local bagSlots = C_Container.GetContainerNumSlots(bag)
        -- Iterate through the slots in the current bag
        for slot = 1, bagSlots do
            local dat = C_Container.GetContainerItemInfo(bag, slot)
            -- dat.itemID == idd
            if dat then
                local itemName, itemLink, itemQuality, itemLevel, itemRarity, itemType, itemSubType, itemStackCount, _, _, _, classID, subclassID, bindType, _, _, isCraft =
                    GetItemInfo(dat.itemID)

                local additional = special and
                    (itemQuality == 0 or ((classID == 2 or classID == 4) and not dat.isBound))

                if isCraft or additional then
                    local last = totalStacks[dat.itemID] or 0
                    if dat.stackCount then
                        totalStacks[dat.itemID] = last + dat.stackCount
                    else
                        totalStacks[dat.itemID] = last + 1
                    end
                elseif Madhouse.API.v1.Contains(PopContainerItems, dat.itemID) then
                    totalContainerV = totalContainerV + 1
                    local last = totalContainer[dat.itemID] or 0
                    if dat.stackCount then
                        totalContainer[dat.itemID] = last + dat.stackCount
                    else
                        totalContainer[dat.itemID] = last + 1
                    end
                end
            end
        end
    end
    --    print(idd,totalStacks)
    return totalStacks, totalContainer, totalContainerV
end

local function toPrice(price, short)
    local gold = math.floor(price / 10000);
    if gold > 999 and short then
        return "\124cffFFFF00" .. string.format("%.1fk", gold / 1000) .. "\124r"
    elseif gold > 0 then
        return "\124cffFFFF00" .. string.format("%dg", gold) .. "\124r"
    end

    local silver = math.floor((price % 10000) / 100)

    return "\124cffC0C0C0" .. string.format("%ds", silver) .. "\124r"
end

local function getItemPrice(itemID, count)
    local _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)

    if itemRarity == 0 and itemSellPrice > 0 and count > 0 then
        return toPrice(itemSellPrice * count), itemSellPrice, itemSellPrice * count, toPrice(itemSellPrice * count, true)
    end
    -- Check if Auctionator is available
    if Auctionator and Auctionator.API and count > 0 then
        -- Use Auctionator's API to get the price for the specific item by ID
        local price = Auctionator.API.v1.GetAuctionPriceByItemID("YourWeakAuraName", itemID)

        -- If price is found, convert it to a gold/silver/copper string
        if price then
            return toPrice(price * count), price, price * count, toPrice(price * count, true)
        end
    end
    return "", 0
end

local last_bag

local total_time = GetTime()
local start_price = nil
local last_time = GetTime()
local last_price = 0

local function Render(self, event)


    local infoText = AceGUI:Create("InteractiveLabel")
    infoText:SetText("")
    infoText:SetFontObject(GameFontHighlightLarge) -- Use a larger font
    infoText:SetFullWidth(true)
    self.Frame:AddChild(infoText)

    local space = AceGUI:Create("Label")
    space:SetText(" ")
    self.Frame:AddChild(space)

    local iconGroup = AceGUI:Create("ScrollFrame")
    iconGroup:SetLayout("Flow") -- Stack children vertically
    iconGroup:SetWidth(RowWidth)
    iconGroup:SetHeight(WindowHeight - 60)
    self.Frame:AddChild(iconGroup)

    -- ######################## LIST ##############################

    local list, container, cv = getBagList()


    if not last_bag then
        last_bag = list
    end

    local dif = 0

    local map = {}
    local wood = {}

    local totalText = 0

    for i, j in pairs(list) do
        local icon = C_Item.GetItemIconByID(i)

        local price, raw, total, roundPrice = getItemPrice(i, j)

        local l_count = last_bag[i] or 0
        if j > l_count then
            dif = dif + ((j - l_count) * raw)
        end
        local tooltip = Madhouse.API.v1.TooltipToText(C_TooltipInfo.GetItemByID(i))

        tooltip = tooltip .. '\n' .. (j or "") .. ' x ' .. (toPrice(raw) or "") .. ' = ' .. (price or "")

        local _, _, itemRarity = GetItemInfo(i)


        if Madhouse.API.v1.Contains(WoodDB, i) then
            table.insert(wood, {
                changed = true,
                icon = icon,
                stacks = j,
                price = roundPrice,
                raw = raw,
                total = total or 0,
                quality = itemRarity,
                tooltip = tooltip
            })
        elseif raw ~= 0 or not Auctionator then
            totalText = totalText + (total or 0)
            table.insert(map, {
                changed = true,
                icon = icon,
                stacks = j,
                price = roundPrice,
                raw = raw,
                total = total or 0,
                quality = itemRarity,
                tooltip = tooltip
            })
        end
    end
    table.sort(map, function(a, b)
        return a.total > b.total
    end)


    if cv > 0 then
        local headerContainer = AceGUI:Create("Heading")
        headerContainer:SetFullWidth(true)
        headerContainer:SetText(isGerman and "Behälter" or "Container")
        iconGroup:AddChild(headerContainer)
        for data in pairs(container) do
            local itemIcon = AceGUI:Create("IconButton")
            itemIcon:SetItem(data)
            itemIcon:SetSize(36)
            iconGroup:AddChild(itemIcon)
        end
    end

    if #wood > 0 then
        local headerWood = AceGUI:Create("Heading")
        headerWood:SetFullWidth(true)
        headerWood:SetText(isGerman and "Holz" or "Wood")
        iconGroup:AddChild(headerWood)
        for _, data in pairs(wood) do
            local ww = 40
            local itemIcon = AceGUI:Create("SellIcon")
            itemIcon:SetImage(data.icon)
            itemIcon:SetImageSize(ww, ww)
            itemIcon:SetBorderColor(Madhouse.API.v1.HexColorToRGB('#737373'))
            itemIcon:SetLabel(Madhouse.API.v1.ColorPrintRGB(data.stacks, "FFFFFF"))
            itemIcon:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_CURSOR")
                GameTooltip:SetText(data.tooltip)
                GameTooltip:Show()
            end)
            itemIcon:SetCallback("OnLeave", function() GameTooltip:Hide() end)
            iconGroup:AddChild(itemIcon)
        end
    end

    local headerIt = AceGUI:Create("Heading")
    headerIt:SetFullWidth(true)
    headerIt:SetText(isGerman and "Gegenstände" or "Items")
    iconGroup:AddChild(headerIt)

    for _, data in pairs(map) do
        local ww = 39
        local itemIcon = AceGUI:Create("SellIcon")
        itemIcon:SetImage(data.icon)
        itemIcon:SetImageSize(ww, ww)
        if data.quality == 0 then
            itemIcon:SetBorderColor(Madhouse.API.v1.HexColorToRGB('#737373'))
        elseif data.quality == 1 then
            itemIcon:SetBorderColor(Madhouse.API.v1.HexColorToRGB('#38FF00'))
        elseif data.quality == 2 then
            itemIcon:SetBorderColor(Madhouse.API.v1.HexColorToRGB('#0052FF'))
        elseif data.quality == 3 then
            itemIcon:SetBorderColor(Madhouse.API.v1.HexColorToRGB('#AD00FF'))
        end

        itemIcon:SetLabel(data.price)

        itemIcon:SetCallback("OnEnter", function()
            GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_CURSOR")
            GameTooltip:SetText(data.tooltip)
            GameTooltip:Show()
        end)
        itemIcon:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        iconGroup:AddChild(itemIcon)
    end

    local cur_time = GetTime()
    local gph = ""
    if start_price ~= nil then
        local dif_price = totalText - start_price
        local tempP = dif_price / 10000 / 1000
        local tempT = (cur_time - total_time) / 3600
        local temp
        if tempT <= 0 then
            temp = 0
        else
            temp = tempP / tempT
        end
        if temp > 0 and temp < 100000 then
            gph = "- " .. math.floor(temp) .. "k/h"
            infoText:SetCallback("OnEnter", function()
                GameTooltip:SetOwner(infoText.frame, "ANCHOR_CURSOR")
                GameTooltip:SetText("T: ".. (math.floor((cur_time - total_time)/60)).."min - " .. toPrice(dif_price))
                GameTooltip:Show()
            end)
            infoText:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        end
    end
    infoText:SetCallback("OnClick", function()
        print(isGerman and  "Zähler zurückgesetzt" or "Counter reseted.")
        total_time = GetTime()
        start_price = totalText or 0
        self:Reload()
    end)
    infoText:SetText((isGerman and 'Gesammt: ' or 'Total: ') .. toPrice(totalText) .. " " .. gph)
    last_bag = list

    local dif_time = cur_time - last_time
    local new_price = dif or 0
    if dif_time < 2.5 then
        last_price = new_price + (last_price or 0)
    else
        last_price = new_price
    end
    if last_price >= 100 and self.ShowWindow then
        Madhouse.trigger.PostMessage('+' .. GetCoinTextureString(last_price))
    end
    last_time = cur_time
end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title)
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth(RowWidth + 30)
    self.Frame:SetHeight(WindowHeight)
    self.Frame.frame:RegisterEvent("ADDON_LOADED")
    self.Frame.frame:RegisterEvent("BAG_UPDATE_DELAYED")
    -- self.Frame.frame:RegisterEvent("REAGENTBANK_UPDATE")
    -- self.Frame.frame:RegisterEvent("AFH_RESET_CLICK")
    self.Frame.frame:SetScript("OnEvent", function(_, event, addon)
        self:FlashFrame()
        self:Render()
    end)
    -- Register Events
end

M_Register_Window({
    widget = "FarmingWindow",
    short = "farming",
    init = InitWindow,
    render = Render,
    info = {
        title = "Farming Helper",
        icon = 4625027,
        short = "Farm"
    }
})
