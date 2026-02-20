-- Methods

local groupData = nil
local groupDataCount = nil

local lastRating = nil
local lastRatingCount = nil

local function setupRating()
    groupData, groupDataCount = Madhouse.API.v1.GetGroupDetails(true)
    lastRatingCount = 1
    Madhouse.widgets.RatingWindow.Frame:SetHeight(60 + (groupDataCount - 1) * 50)
    lastRating = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,
    }
end

local function sendSyncData(partital)
    local pckSize = 231
    local data = Madhouse.API.v1.CompressData(partital)
    local parts = {}
    local count = 0
    for i = 1, string.len(data), pckSize do
        count = count + 1
        table.insert(parts, string.sub(data, i, i + pckSize - 1))
    end

    Madhouse.API.v1.Dprint("Sync size: " .. string.len(data) .. " in " .. count)
    --[[    local test = ""


    for _,v in pairs(parts) do
        test = test .. v
    end

    Madhouse.API.v1.Dprint("Data size: " .. string.len(data) .. " " .. string.len(test))]]

    -- sender = 13
    local sender = string.sub(UnitGUID("player"), 8, 20)
    -- version = 2
    local version = "01"
    -- package = 4
    local package = "0000"
    -- data = 231
    local info = sender .. version .. package .. tostring(count)
    --- print(string.len(data) .. " " .. string.len(test))

    local messageChannel = "GUILD" -- "PARTY"
    C_ChatInfo.SendAddonMessage("mhpsync", info, messageChannel)

    for i, v in pairs(parts) do
        local pck = string.format("%04d", i)
        local payload = sender .. version .. pck .. v
        C_ChatInfo.SendAddonMessage("mhpsync", payload, messageChannel)
    end
end

local function syncAllData()
    sendSyncData(MadhouseAddonSocial)
end

local function wipeAllData()
    MadhouseAddonSocial = {}
end

local reciveDate = {}


local function reciveSyncData(payload)
    local self = string.sub(UnitGUID("player"), 8, 20)
    -- sender = 13
    local sender = string.sub(payload, 1, 13)
    -- version = 2
    local version = string.sub(payload, 14, 15)
    -- package = 4
    local package = string.sub(payload, 16, 19)

    local data = string.sub(payload, 20)

    if self == sender or version ~= "01" then
        return
    end

    if package == "0000" then
        reciveDate[sender] = {
            data = {},
            max = tonumber(data),
            cur = 0
        }
    elseif reciveDate[sender] then
        reciveDate[sender].data[tonumber(package)] = data
        reciveDate[sender].cur = reciveDate[sender].cur + 1
        if reciveDate[sender].cur == reciveDate[sender].max then
            Madhouse.API.v1.Dprint("Data recived")
            local textLoad = ""
            for _, value in pairs(reciveDate[sender].data) do
                textLoad = textLoad .. value
            end
            local payloadData = Madhouse.API.v1.ExtractData(textLoad)
            -- Madhouse.API.v1.Inspect(payloadData)
            reciveDate[sender].data = nil
            Madhouse.addon:SocialPointsMerge(payloadData)
        end
    else
        print("Error: Package not found")
    end

    -- print(sender,version,package,data)
end


local function handleClick(index, value, data)
    if groupData then
        Madhouse.addon:SocialPointsVote(groupData[index].guid, value, data)

        local msg = "skip"
        local color = "FFFFFF"
        if value == 0 then
            msg = isGerman and "Schlecht" or "Bad"
            color = "FF0000"
        elseif value == 1 then
            msg = isGerman and "Gut" or "Good"
            color = "00FF00"
        elseif value == 2 then
            msg = "Leaver"
            color = "0000FF"
        end

        if value >= 0 then
            print(Madhouse.API.v1.ColorPrintRGB(
            (isGerman and "Abgestimmt:  " or "Voted:  ") ..
            msg .. (isGerman and " für " or " for ") .. groupData[index].name, color))
        end

        lastRating[index] = true
        lastRatingCount = lastRatingCount + 1
        if lastRatingCount == groupDataCount then
            print("All voted - Syncing")
            Madhouse.widgets.RatingWindow:Hide()
            local partital = {}
            if lastRating then
                for k, v in pairs(lastRating) do
                    if v then
                        local dat = groupData[k]
                        partital[dat.guid] = {
                            ["meta"]    = MadhouseAddonSocial[dat.guid].meta,
                            ["history"] = MadhouseAddonSocial[dat.guid].history,
                        }
                        -- Madhouse.API.v1.Inspect(partital[dat.guid])
                    end
                end
            end
            sendSyncData(partital)
            Madhouse.widgets.RatingWindow.ButtonFrame:Hide()
        else
            Madhouse.widgets.RatingWindow:FlashFrame()
            Madhouse.widgets.RatingWindow:Render()
        end
    end
end

local function Render(self, event)


    if not groupData or not lastRating then
        return
    end


    for i, v in pairs(groupData) do
        if not v.isPlayer then
            if lastRating and not lastRating[i] then
                local row = AceGUI:Create("SimpleGroup")
                row:SetFullWidth(true) -- Make the group take the full width
                row:SetLayout("Flow") -- Set layout to horizontal flow

                self.Frame:AddChild(row)
                local label = AceGUI:Create("Label")

                local icon = 132223
                if v.role == 1 then
                    icon = 132341
                elseif v.role == 2 then
                    icon = 136041
                end

                icon        = Madhouse.API.v1.PrintIcon(icon)
                local color = Madhouse.API.v1.ColorFromClassName(v.class)
                label:SetText(icon .. ' |c' .. color .. v.name .. '-' .. v.realm .. '|r')

                label:SetFontObject(GameFontNormalLarge)
                row:AddChild(label)
                local buttonWidth = 50
                local buttonGood  = AceGUI:Create("Button")
                buttonGood:SetWidth(buttonWidth)
                buttonGood:SetText(Madhouse.API.v1.ColorPrintRGB("+", "00FF00"))
                buttonGood:SetCallback("OnClick", function()
                    handleClick(i, 1, v)
                end)
                buttonGood.frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(buttonGood.frame, "ANCHOR_CURSOR")
                    GameTooltip:SetText(isGerman and "Bewete den Spieler positiv" or "Rate the player positive")
                    GameTooltip:Show()
                end)
                buttonGood.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
                row:AddChild(buttonGood)

                local buttonBad = AceGUI:Create("Button")
                buttonBad:SetWidth(buttonWidth)
                buttonBad:SetText(Madhouse.API.v1.ColorPrintRGB("-", "FF0000"))
                row:AddChild(buttonBad)
                buttonBad:SetCallback("OnClick", function()
                    handleClick(i, 0, v)
                end)
                buttonBad.frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(buttonBad.frame, "ANCHOR_CURSOR")
                    GameTooltip:SetText(isGerman and "Bewete den Spieler negative" or "Rate the player negative")
                    GameTooltip:Show()
                end)
                buttonBad.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

                local buttonLeave = AceGUI:Create("Button")
                buttonLeave:SetWidth(buttonWidth)
                buttonLeave:SetText(Madhouse.API.v1.ColorPrintRGB("L", "0000FF"))
                row:AddChild(buttonLeave)
                buttonLeave:SetCallback("OnClick", function()
                    handleClick(i, 2, v)
                end)
                buttonLeave.frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(buttonLeave.frame, "ANCHOR_CURSOR")
                    GameTooltip:SetText(isGerman and
                    "Markiere den Spieler der den Key frühzeigig verlassen oder sabotiert hat." or
                    "Mark the player who left the key early or sabotaged it.")
                    GameTooltip:Show()
                end)
                buttonLeave.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

                local buttonSkip = AceGUI:Create("Button")
                buttonSkip:SetWidth(buttonWidth)
                buttonSkip:SetText("X")
                row:AddChild(buttonSkip)
                buttonSkip:SetCallback("OnClick", function()
                    handleClick(i, -1, v)
                end)
                buttonSkip.frame:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(buttonSkip.frame, "ANCHOR_CURSOR")
                    GameTooltip:SetText(isGerman and "Überspringe die Spieler Bewertung" or "Skip the player rating")
                    GameTooltip:Show()
                end)
                buttonSkip.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
        end
    end
end

local function InitWindow(self)
    -- Create frame
    local syncChannel = "mhpsync"

    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(isGerman and "Bewetungs Fenster" or "Rating Window")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth(260)
    self.Frame:SetHeight(350)
    -- self.Frame:SetLayout("Fill")

    C_ChatInfo.RegisterAddonMessagePrefix(syncChannel)

    self.Frame.frame:SetScript("OnEvent", function(_, event, channel, msg, _, sender, ...)
        if Madhouse.addon:LoadGlobalData("settings-social-points", false) then
            if event == "CHALLENGE_MODE_COMPLETED" then
                C_Timer.After(4, function()
                    Madhouse.API.v1.Dprint("CHALLENGE_MODE_COMPLETED")
                    self:FlashFrame()
                    self:Render()
                    self:Show()
                    self.ButtonFrame:Hide()
                end)
            elseif event == "CHALLENGE_MODE_START" then
                Madhouse.API.v1.Dprint("CHALLENGE_MODE_START")
                self:setupRating()
                self.ButtonFrame:Show()
            elseif event == "CHAT_MSG_ADDON" and channel == syncChannel then
                reciveSyncData(msg)
                --    Madhouse.API.v1.Inspect(Madhouse.API.v1.ExtractData(msg))
                -- print(sender, channel, msg)
            end
        end
    end)
    self.Frame.frame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
    self.Frame.frame:RegisterEvent('CHALLENGE_MODE_START')
    self.Frame.frame:RegisterEvent('CHAT_MSG_ADDON')

    self.ButtonFrame = AceGUI:Create("EmptyFrame")
    self.ButtonFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -20, 0)

    self.ButtonFrame.frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.ButtonFrame.frame, "ANCHOR_CURSOR")
        GameTooltip:SetText(isGerman and "Öffne Bewertungsfenster" or "Open Rating Window")
        GameTooltip:Show()
    end)
    self.ButtonFrame.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.ButtonFrame:SetHeight(40)
    self.ButtonFrame:SetWidth(50)
    self.Button = AceGUI:Create("IconButton")
    --self.Button:SetImage(5926319)
    self.Button:SetImage("Interface\\AddOns\\madhousepack\\Textures\\Logo.tga")
    self.Button.frame:SetAttribute("type", "macro")
    self.Button.frame:SetAttribute("macrotext", "/run Madhouse.widgets.RatingWindow:Show()")

    self.Button.image:SetSize(24, 24)
    self.ButtonFrame:AddChild(self.Button)
    self.ButtonFrame:Hide()
end

M_Register_Window({
    widget = "RatingWindow",
    short = "rating",
    init = InitWindow,
    render = Render,
    info = nil,
    extra = {
        ButtonFrame = nil,
        setupRating = setupRating,
        sendSyncData = sendSyncData,
        syncAllData = syncAllData,
        wipeAllData = wipeAllData,
    }
})
