-- Variables

local RowWidth = 300
local WindowHeight = 400

-- Functions


local function RgbToHex(col)
    return ("ff%.2x%.2x%.2x"):format(Round(col.r * 255), Round(col.g * 255), Round(col.b * 255));
end

local function TooltipToText(data)
    if data and data.lines then
        local tooltip = ''
        for _, d in pairs(data.lines) do
            tooltip = tooltip .. '|c' .. RgbToHex(d.leftColor) .. d.leftText .. '|r\n'
        end
        return tooltip
    end
    return ''
end

-- Function

function PlayerInZone(zone_id)
    if not zone_id then
        return false, ""
    end

    local zone = C_Map.GetBestMapForUnit("player")


    local f = zone_id:sub(1, 1)


    if f == "c" or f == "g" then
        local fx = tonumber(zone_id:sub(2, #zone_id))
        local group_childs = C_Map.GetMapChildrenInfo(fx)
        local z_names = ""
        local match = zone == fx
        for _, v in pairs(group_childs) do
            z_names = z_names .. v.name .. "\n"
            if v.mapID == zone then
                match = true
            end
        end
        return match, z_names
    else
        local fx = tonumber(zone_id)
        if fx == zone then
            local mInfo = C_Map.GetMapInfo(zone_id)
            return true, mInfo.name
        end
    end

    return false, ""
end

function AchievementDetails(id, lookup, base)
    local outTable = base or {}
    local _, name, _, completed, _, _, _, _, flags, icon, RewardText = GetAchievementInfo(id)
    if not name then
        return nil
    end

    local numCriteria = GetAchievementNumCriteria(id)

    local criteria = {}
    local subAc = {}
    for y = 1, numCriteria do
        local description, criteriaType, citeriaCompleted, quantity, reqQuantity, _, _, assetID, _, criteriaID =
            GetAchievementCriteriaInfo(id, y)
        criteria[y] = {
            id = criteriaID,
            description = description,
            criteriaType = criteriaType,
            completed = citeriaCompleted,
            quantity = quantity,
            reqQuantity = reqQuantity,
            assetID = assetID,
            isAchievement = criteriaType == 8 and assetID
        }
        if criteria[y].isAchievement then
            table.insert(subAc, criteria[y].assetID)
        end
    end

    local tt = C_TooltipInfo.GetAchievementByID(id)

    if lookup[id] ~= true then
        lookup[id] = true
        table.insert(outTable, {
            id = id,
            name = name,
            completed = completed,
            flags = flags,
            icon = icon,
            RewardText = RewardText,
            numCriteria = numCriteria,
            criteria = criteria,
            tooltip = TooltipToText(tt)
        })
    end

    if not completed then
        for _, value in ipairs(subAc) do
            AchievementDetails(value, lookup, outTable)
        end
    end
    return outTable
end

local function PrintLabelTxt(name, icon, collapse, done)
    local txt = name
    local ico = Madhouse.API.v1.PrintIcon(icon)
    local col = ''
    if collapse ~= nil then
        col = Madhouse.API.v1.PrintIcon(collapse and 135768 or 135769) .. " "
    end
    if done then
        return col .. ico .. Madhouse.API.v1.ColorPrintRGB(txt, "00FF00")
    end
    return col .. ico .. txt
end

local showDone = false
local cat = {}
local catJ = {}
local fontPath, _, fontFlags = GameFontNormal:GetFont()

local fontObject = CreateFont("MadhouseFont")
fontObject:SetFont(fontPath, 13, fontFlags)



local function Render(self)

    local labelGroup = AceGUI:Create("ScrollFrame")
    labelGroup:SetLayout("List")
    self.Frame:AddChild(labelGroup)

    local ModeBox = AceGUI:Create("CheckBox")
    ModeBox:SetLabel("Show Done")
    ModeBox:SetValue(showDone)
    ModeBox:SetCallback("OnValueChanged", function(_, _, val)
        showDone = val
        self:Reload()
    end)

    labelGroup:AddChild(ModeBox)

    local headerIt = AceGUI:Create("Heading")
    headerIt:SetFullWidth(true)
    headerIt:SetText(isGerman and "Erfolge" or "Achivements")
    labelGroup:AddChild(headerIt)

    -- ######################## LIST ##############################
    for i, value in ipairs(Madhouse.db.achivement.cat) do
        local isActive = cat[i] or false
        local lookup = {}
        local label = AceGUI:Create("InteractiveLabel")
        label:SetText(PrintLabelTxt(value.n, value.i, isActive, false))
        label:SetFullWidth(true)
        label:SetFontObject(GameFontHighlightLarge)
        label:SetCallback("OnClick", function()
            cat[i] = not isActive
            self:Reload()
        end)
        labelGroup:AddChild(label)
        if isActive then
            for _, cur in ipairs(Madhouse.db.achivement.element) do
                if cur.c == i then
                    local acData = AchievementDetails(cur.a, lookup)
                    for _, data in ipairs(acData or {}) do
                        if data and not data.completed or showDone then
                            local isActiveJ = catJ[data.id] or false
                            local quantity = 0
                            local reqQuantity = 0
                            if data.numCriteria and data.numCriteria > 0 then
                                for _, z in pairs(data.criteria) do
                                    if z.reqQuantity > 1 then
                                        quantity = quantity + z.quantity
                                        reqQuantity = reqQuantity + z.reqQuantity
                                    else
                                        if z.completed then
                                            quantity = quantity + 1
                                        end
                                        reqQuantity = reqQuantity + 1
                                    end
                                end
                            end
                            local ac = AceGUI:Create("InteractiveLabel")
                            ac:SetCallback("OnEnter",
                                function()
                                    GameTooltip:SetOwner(ac.frame, "ANCHOR_CURSOR")
                                    GameTooltip:SetText(data.tooltip)
                                    GameTooltip:Show()
                                end)
                            ac:SetCallback("OnLeave", function() GameTooltip:Hide() end)
                            ac:SetFullWidth(true)
                            ac:SetFontObject(fontObject)
                            if reqQuantity > 1 then
                                ac:SetText('   ' .. PrintLabelTxt(data.name, data.icon, isActiveJ, data.completed))
                                ac:SetCallback("OnClick", function(_, _, button)
                                    if button == "LeftButton" then
                                        catJ[data.id] = not isActiveJ
                                        self:Reload()
                                    elseif button == "RightButton" then
                                        if AchievementFrame then
                                            -- Ensure the Achievement Frame is loaded
                                            if not AchievementFrame:IsShown() then
                                                ToggleAchievementFrame() -- Open the Achievement window
                                            end
                                        else
                                            ToggleAchievementFrame()
                                        end
                                        -- Select the specific achievement
                                        AchievementFrame_SelectAchievement(data.id)
                                    end
                                end)
                                if isActiveJ then
                                    local progress = math.floor((quantity / reqQuantity) * 10)
                                    local pg_txt = "     ["
                                    for z = 1, 20 do
                                        if progress * 2 >= z then
                                            pg_txt = pg_txt .. '|cFF00FF00#|r'
                                        else
                                            pg_txt = pg_txt .. '|cFFFFFF00#|r'
                                        end
                                    end
                                    pg_txt = pg_txt .. ']'
                                    local ad = AceGUI:Create("InteractiveLabel")
                                    ad:SetFullWidth(true)
                                    ad:SetFontObject(fontObject)
                                    ad:SetText(pg_txt .. " (" .. quantity .. "/" .. reqQuantity .. ")")
                                    labelGroup:AddChild(ac)
                                    labelGroup:AddChild(ad)
                                    for _, valueSub in ipairs(data.criteria) do
                                        if valueSub.isAchievement == false and valueSub.completed == false and valueSub.reqQuantity >= 1 then
                                            local sub = AceGUI:Create("InteractiveLabel")
                                            sub:SetFullWidth(true)
                                            sub:SetFontObject(fontObject)
                                            sub:SetText('     - ' .. valueSub.description)
                                            labelGroup:AddChild(sub)
                                        end
                                    end
                                    -- Madhouse.API.v1.Inspect(data.criteria)
                                else
                                    labelGroup:AddChild(ac)
                                end
                            else
                                ac:SetText('   ' .. PrintLabelTxt(data.name, data.icon, nil, data.completed))
                                ac:SetCallback("OnClick", function(_, _, button)
                                    if button == "RightButton" then
                                        if AchievementFrame then
                                            -- Ensure the Achievement Frame is loaded
                                            if not AchievementFrame:IsShown() then
                                                ToggleAchievementFrame() -- Open the Achievement window
                                            end
                                        else
                                            ToggleAchievementFrame()
                                        end
                                        -- Select the specific achievement
                                        AchievementFrame_SelectAchievement(cur.a)
                                    end
                                end)
                                labelGroup:AddChild(ac)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title)
    self.Frame:SetLayout("Fill")
    self.Frame:EnableResize(true)
    self.Frame:SetWidth(RowWidth + 30)
    self.Frame:SetHeight(WindowHeight)
    self.Frame.frame:RegisterEvent("ACHIEVEMENT_EARNED")
    self.Frame.frame:RegisterEvent("ACHIEVEMENT_PLAYER_NAME")
    self.Frame.frame:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED")
    self.Frame.frame:RegisterEvent("CRITERIA_COMPLETE")
    self.Frame.frame:RegisterEvent("CRITERIA_EARNED")
    self.Frame.frame:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
    self.Frame.frame:RegisterEvent("RECEIVED_ACHIEVEMENT_LIST")
    self.Frame.frame:RegisterEvent("RECEIVED_ACHIEVEMENT_MEMBER_LIST")
    self.Frame.frame:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED")
    self.Frame.frame:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE")
    -- self.Frame.frame:RegisterEvent("ZONE_CHANGED")
    self.Frame.frame:SetScript("OnEvent", function()
        self:Reload()
    end)
end

M_Register_Window({
    widget = "AchivementWindow",
    short = "achivement",
    init = InitWindow,
    render = Render,
    info = {
        title = "Achivements",
        icon = 4279397,
        short = "Achivement"
    }
})
