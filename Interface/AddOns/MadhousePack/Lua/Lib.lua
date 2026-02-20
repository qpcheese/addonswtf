local name,addon=...

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

if DLAPI then DLAPI.DebugLog(addonName, ...) end
-- Madhouse.API.v1.Dprint
local function dprint(a,b)
    if DLAPI then
        if b ~= nil then
            DLAPI.DebugLog("Madhouse", a .. ' '.. tostring(b))
        else
            DLAPI.DebugLog("Madhouse", a)
        end
    else
        -- print(a,b)
    end
end

-- Madhouse.API.v1.AddonFolder
local function AddonFolder(v)
    return "Interface\\AddOns\\".. name .."\\".. (v or "")
end
-- Madhouse.API.v1.FormatBigNumber @param int @return string
local function FormatBigNumber(v)
    if v >= 1000 then
        if math.fmod(v,1000) == 0 then
            return v/1000 ..'K'
        end
        return string.format("%.1f", v/1000) ..'K'
    end
    return v
end

-- Madhouse.API.v1.RoundUpNumber @param int @return string
local function RoundUpNumber(exact, quantum)
    local quant,frac = math.modf(exact/quantum)
    return (quant + (frac > 0 and 1 or 0))
end

-- Madhouse.API.v1.BreakLongTooltipText @param string @return string
local function BreakLongTooltipText(v,max)
    local m = max or 50
    local out = ''
    local line = ''
    for token in string.gmatch(v, "[^%s]+") do
       if string.len(line) < m then
          line = line .. token .. ' '
       else
            out = out .. line .. '\n'
            line = token .. ' '
       end
    end
    out = out .. line
    return out
end

-- Madhouse.API.v1.TableKeySize @return int
local function TableKeySize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Madhouse.API.v1.Inspect @return void
local function Inspect(table,dep,level)
    local d = dep or 5
    local l = level or 0
    local pre = "|-"

    for i=1,l do
        pre = pre.."--"
    end

    local cur = type(table)

    if l==0 then
        dprint(pre.."Inspecting: "..cur)
    end

    if cur == "table" then
        dprint(pre.."TSize", TableKeySize(table))
        for k,v in pairs(table) do
            local ccur = type(v)
            if  ccur == "string" or ccur == "boolean" or ccur == "number" then
                dprint(pre..k,v)
            elseif  ccur == "function" then
                dprint(pre.."function",k)
            elseif  ccur == "table" then
                dprint(pre..k)
                if l < d then
                    Inspect(v,d,l+1)
                else
                    dprint("################ Max depth reached ################")
                end
            else
                dprint(pre.."Unknown type: "..ccur)
            end
        end
    elseif cur == "string" or cur == "boolean" or cur == "number" then
        dprint(pre..cur,table)
    elseif  cur == "function" then
        dprint(pre.."function")
    else
        dprint(pre.."Unknown type: "..cur)
    end
end

-- Madhouse.API.v1.ColorPrint @param string, table @return string
local function ColorPrintRGB(text, color)
    return '|cFF'..color .. text .. '|r';
end


-- Madhouse.API.v1.PrintIcon @param number @return string
local function PrintIcon(icon)
    return '|T'.. icon ..':0|t';
end


-- Madhouse.API.v1.RgbToHex @return string
local function RgbToHex(col)
    return ("ff%.2x%.2x%.2x"):format(Round(col.r * 255),Round(col.g * 255),Round(col.b * 255));
end

-- Madhouse.API.v1.ColorFromClassName @return string
local function ColorFromClassName(className)
    local rPerc, gPerc, bPerc  = GetClassColor(className)
    return RgbToHex({ r = rPerc, g = gPerc, b = bPerc});
end

-- Madhouse.API.v1.HexColorToRGB @return r,g,b
local function HexColorToRGB(hex)
    -- remove '#' if present
    hex = hex:gsub("#", "")

    -- extract components
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255

    return r, g, b
end


-- Madhouse.API.v1.BreakLongTooltipText @param string @return string
local function BreakLongTooltipTextToArray(v,max, color)
    local m = max or 50
    local out = ''
    local line = '|c'.. RgbToHex(color)
    for token in string.gmatch(v, "[^%s]+") do
       if string.len(line) < m then
          line = line .. token .. ' '
       else
            out = out .. line .. '|r\n'
            line =  '|c'.. RgbToHex(color) .. token .. ' '
       end
    end
    out = out .. line .. '|r'
    return out
end


-- Madhouse.API.v1.TooltipToText @return string
local function TooltipToText(data)
    if data and data.lines then
        local tooltip = ''
        for _,d in pairs(data.lines) do
            tooltip =  tooltip .. BreakLongTooltipTextToArray(d.leftText,50,d.leftColor)  ..'\n'
        end
        return tooltip
    end
    return ''
end

-- Madhouse.API.v1.ItemInBag @return bool, table
local function ItemInBag(idd)
    for bag = 0, NUM_BAG_SLOTS do
        local bagSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, bagSlots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemName and info.itemID == idd then
                return true, info
            end
        end
    end
    return false, nil
end

-- Madhouse.API.v1.ItemIsEquiped @return bool, table
local function ItemIsEquiped(idd)
   local eq = C_TooltipInfo.GetInventoryItemByID(idd)
   local equiped = eq ~= nil
    return equiped, eq
end

-- Madhouse.API.v1.PlayerInZone
local function PlayerInZone(zone_id)

        if not zone_id then
            return false, ""
        end

        local zone = C_Map.GetBestMapForUnit("player")


        local f = zone_id:sub(1, 1)


        if f == "c" or f =="g" then
            local fx = tonumber(zone_id:sub(2, #zone_id))
            local group_childs = C_Map.GetMapChildrenInfo(fx)
            local z_names = ""
            local match = false
            for _, v in pairs(group_childs) do
                z_names = z_names .. v.name .."\n"
                if v.mapID == zone then
                    match = true
                end
            end
            return match, z_names
        else
            local fx = tonumber(zone_id)
            if fx == zone then
                local mInfo= C_Map.GetMapInfo(zone_id)
                return true , mInfo.name
            end
        end

        return false, ""
end
-- Madhouse.API.v1.AchievementDetails
local function AchievementDetails(id)
    local _, name, _, completed, _, _, _, _, flags, icon,RewardText = GetAchievementInfo(id)
    if not name then
        return nil
    end

    local numCriteria = GetAchievementNumCriteria(id)

    local criteria = {}

    for y = 1, numCriteria do
        local description, criteriaType, citeriaCompleted, quantity, reqQuantity, _, _, assetID, _, criteriaID = GetAchievementCriteriaInfo(id, y)
        criteria[y]={
            id = criteriaID,
            description = description,
            criteriaType = criteriaType,
            completed = citeriaCompleted,
            quantity = quantity,
            reqQuantity = reqQuantity,
            assetID = assetID,
            isAchievement = criteriaType == 8 and assetID
        }
    end

     local tt = C_TooltipInfo.GetAchievementByID(id)

    return {
        id = id,
        name = name,
        completed = completed,
        flags = flags,
        icon = icon,
        RewardText = RewardText,
        numCriteria = numCriteria,
        criteria = criteria,
        tooltip = TooltipToText(tt)
    }
end

-- Madhouse.API.v1.GetGroupDetails
function GetGroupDetails(dev)
    dev = dev or false
    -- Function to get specialization name
    local function GetSpecializationName(unit)
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            local _, specName = GetSpecializationInfoByID(specID)
            return specName
        end
        return "Unknown"
    end

    -- Function to get Mythic+ rating
    local function GetMythicPlusRating(unit)
        local score = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
        return score and score.currentSeasonScore or 0
    end

    -- Function to get role
    local function GetPlayerRole(unit)
        local role = UnitGroupRolesAssigned(unit)
        return role and (role ~= "NONE" and role or "Unknown")
    end

    dprint("Party Members:")

    local result ={}
    local self = UnitGUID("player")
    local count = 0;
    if IsInGroup() then
        for i = 1, GetNumGroupMembers() do
            local unit = (i == 1 and "player") or "party" .. (i - 1) -- "player" for yourself, "party1"..."partyN" for others
            local name, realm = UnitName(unit)
            name = name or "Unknown"
            realm = realm or GetRealmName() or "Unknown"
            local spec = GetSpecializationName(unit) or "Unknown"
            local mythicRating = GetMythicPlusRating(unit)
            local role = GetPlayerRole(unit) or "Unknown"
            local guid = UnitGUID(unit) or "0"
            local _, englishClass = UnitClass(unit);

            local roleID = 0
            if role == "TANK" then
                roleID = 1
            elseif role == "HEALER" then
                roleID = 2
            elseif role == "DAMAGER" then
                roleID = 3
            end

            if dev then
                dprint(string.format("Name: %s-%s (%s)| Spec: %s | Role: %s | Mythic+ Rating: %d", name, realm, guid, spec, role, mythicRating))
            end
            count = count + 1
            result[i] = {
                name = name,
                realm = realm,
                guid = guid,
                spec = spec,
                role = roleID,
                mythicRating = mythicRating,
                class = englishClass,
                isPlayer = guid == self
            }
        end
        return result, count
    else
        dprint("You are not in a party.")
        return nil, nil
    end
end
-- Madhouse.API.v1.CompressData
local function CompressData(payload)
    local serialized = LibSerialize:Serialize(payload)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    -- print(string.len(encoded))
    return encoded;
end
-- 122284
-- Madhouse.API.v1.ExtractData
local function ExtractData(payload)
    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then return end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return end
    return data;
end
-- Madhouse.API.v1.ShowStopMotion
local function ShowStopMotion(data,loop,scale,pos,x,y,callback)
    local animation_loop = loop or 0 -- 0 = one time , -1 endless loop , >0 = loop counter
    local loopCounter = 0
    local amimation_scale = scale or 1
    local animated = CreateFrame("Button",nil,UIParent)
    animated.texture = animated:CreateTexture()
    animated.texture:SetAllPoints()
    animated.texture:SetTexture(data.img)
    animated:SetFrameStrata("DIALOG")

    local cols = data.cols or 4
    local rows = data.rows or 4
    local ww = 1 / cols
    local wh = 1 / rows

    animated.specialeffect = animated:CreateTexture(nil,"BACKGROUND")
    animated.specialeffect:SetAllPoints(UIParent)
    animated.specialeffect:SetColorTexture(.12,.52,1,0)

    local positon = pos or "CENTER"
    local x_offset = x or 0
    local y_offset = y or 0
    animated:SetPoint(positon,"MHAlarmAnchor",positon,x_offset,y_offset)
    animated:SetSize(data.w * amimation_scale ,data.h * amimation_scale)
    animated.texture:SetTexCoord(0,ww,0,wh)

    animated.frame = 0
    animated.frame_max = data.max_frames or (cols * rows) - 1
    animated.timer = 1

    animated:SetScript("OnUpdate",function(self,elapsed)
        self.timer = self.timer + elapsed
        if self.timer > data.speed then
            self.timer = 0
            self.frame = self.frame + 1
            if self.frame > self.frame_max then
                if animation_loop == -1 or loopCounter < animation_loop then
                    loopCounter = loopCounter + 1
                    self.frame = 0
                else
                    self:Hide()
                    if callback then
                        callback()
                    end
                    return
                end
            end
            local w = self.frame % cols
            local h = floor(self.frame / cols)
            self.texture:SetTexCoord(w * ww,(w + 1) * ww,h * wh,(h + 1) * wh)
            if data.effect then
                local c = data.effect[self.frame]
                if c then
                    if c == -1 then for i=self.frame-1,0,-1 do c = data.effect[i] if c~=-1 then break end end end
                    animated.specialeffect:SetColorTexture(unpack(c))
                else
                    animated.specialeffect:SetColorTexture(0,0,0,0)
                end
            end
        end
    end)
    if animation_loop == -1 then
        animated:SetScript("OnClick",function(self)
            self:Hide()
            if callback then
                callback()
            end
        end)
    end
    return animated;
end
-- Madhouse.API.v1.ShowStaticStopMotion
local function ShowStaticStopMotion(number,loop,scale,pos,x,y)
    ShowStopMotion(addon.static.stopMotion[number],loop,scale,pos,x,y,function () print("StopMotion ended")end)
end
-- Madhouse.API.v1.GetCastInfo
local function GetCastInfo(self,unit)
    local name, startC, endC, icon, notInterruptible, spellID, duration, expirationTime, _, castType
    if UnitCastingInfo(unit) then
        name, _, icon, startC, endC, _, _, notInterruptible, spellID = UnitCastingInfo(unit)
        castType = "cast"
    elseif UnitChannelInfo(unit) then
        name, _, icon, startC, endC, _, notInterruptible, spellID = UnitChannelInfo(unit)
        castType = "channel"
    end
    if startC and endC then
        duration = (endC - startC) / 1000
        expirationTime = endC / 1000
    end
    return name, duration, expirationTime, icon, notInterruptible, spellID, castType
end

-- Madhouse.API.v1.MergeTable
local function MergeTable(a,b)
    local out = {}
    for k, v in pairs(a) do
        out[k] = v
    end
    for k, v in pairs(b) do
        out[k] = v
    end
    return out
end

-- Madhouse.API.v1.AppendTable
local function AppendTable(a, b)
    local out = {}
    for _, v in pairs(a) do
        table.insert(out, v)
    end
    for _, v in pairs(b) do
        table.insert(out, v)
    end
    return out
end

-- Madhouse.API.v1.GetAddonVersion
local function GetAddonVersion(name)
    local ver = C_AddOns.GetAddOnMetadata(name, "Version") or -1
    if ver ~= -1 then
        ver = C_AddOns.IsAddOnLoaded(name) and ver or -2
    end
    return ver
end

-- Madhouse.API.v1.GetWAVersion
local function GetWAVersion(name)
    local ver = -1
    if WeakAuras and WeakAuras.GetData then
        local waData = WeakAuras.GetData(name)
        if waData then
            ver = 0
            local url = waData["url"]
            if url then
                ver = tonumber(url:match('.*/(%d+)$')) or -1
            end
        end
    end
    return ver
end

local tokenPrice = nil
local priceForOneCopper = nil
local fallback = 3600000000
local useFallback = false
-- Madhouse.API.v1.TokenCurrentMarketPrice
local function TokenCurrentMarketPrice()
    if tokenPrice == nil or priceForOneCopper == nil or useFallback == true then
        tokenPrice = C_WowTokenPublic.GetCurrentMarketPrice()
        if not tokenPrice then
            tokenPrice = fallback
            useFallback = true
        elseif useFallback then
            print("Madhouse: Token price is back to normal, using it now.")
            useFallback = false
        end
        priceForOneCopper = 20000 / tokenPrice
    end
    return tokenPrice, priceForOneCopper, useFallback
end
-- Madhouse.API.v1.getEuroCentFromCopper
local function getEuroCentFromCopper(copper)
    local _, pfoc = TokenCurrentMarketPrice()
    return copper * pfoc
end

local scannerTable = {}
-- Madhouse.API.v1.GetEquippedItemTooltip
local function GetEquippedItemTooltip(slotId)
    local scanner
    if not scannerTable[slotId] then
        scanner = CreateFrame("GameTooltip", "MyScanningTooltip_"..slotId, nil, "GameTooltipTemplate")
        scanner:SetOwner(UIParent, "ANCHOR_NONE")
        scannerTable[slotId] = scanner
    else
        scanner = scannerTable[slotId]
    end
    scanner:ClearLines()
    scanner:SetInventoryItem("player", slotId)
    local lines = {}
    for i = 1, scanner:NumLines() do
        local leftText = _G["MyScanningTooltip_"..slotId.."TextLeft" .. i]
        if leftText and leftText:GetText() then
            table.insert(lines, leftText:GetText())
        end
    end
    return lines
end

local function StringStartsWith(String, Start)
   local equals = string.sub(String, 1, string.len(Start)) == Start
   if equals then
     return true, string.sub(String,string.len(Start),string.len(String))
   end
   return false, nil
end
-- Madhouse.API.v1.ShowExportWindow
local function ShowExportWindow(text,title)
    -- Create a container frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(title)
    frame:SetStatusText('|cFFFF7C0A'..'By Elschnagoo [Astrastar-Blackhand-EU]'..'|r')
    frame:SetLayout("Fill")
    frame:SetWidth(500)
    frame:SetHeight(200)

    -- Create a scroll frame
    local scrollContainer = AceGUI:Create("ScrollFrame")
    scrollContainer:SetLayout("Flow") -- Layout type inside the scroll frame
    frame:AddChild(scrollContainer)

    -- Create a multiline edit box
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel("Talent String")
    editBox:SetNumLines(5)
    editBox:SetWidth(450)
    editBox:SetFullWidth(true)
    editBox:SetFullHeight(true)
    editBox:SetMaxLetters(0) -- 0 means no limit

    -- Add the edit box to the scroll frame
    scrollContainer:AddChild(editBox)

    -- Optional: Set initial text
    editBox:SetText(text)
    editBox:HighlightText(0,string.len(text))
    editBox:SetFocus()

    editBox:SetCallback("OnTextChanged", function(w,event)
            if w:GetText() == "" then
                frame:Hide()
            end
    end)

    -- Close button behavior
    frame:SetCallback("OnClose", function(widget)
            AceGUI:Release(widget)
    end)

    -- Show the frame
    frame:Show()
end

local function AddonVersionCheck(addonNo)
    local _, _, _, toc = GetBuildInfo()
    return toc >= addonNo
end
-- Madhouse.API.v1.ValueExist
local function ValueExist(value)
    return value ~= nil and not issecretvalue(value)
end

local function IsMidnight()
    return AddonVersionCheck(120000)
end
-- Madhouse.API.v1.Contains
local function Contains(table,element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end


_G.Madhouse = {
    API = {
        v1 = {
            AddonFolder = AddonFolder,
            Dprint = dprint,
            Inspect = Inspect,
            TableSize = TableKeySize,
            RgbToHex = RgbToHex,
            TooltipToText = TooltipToText,
            ItemInBag = ItemInBag,
            ItemIsEquiped = ItemIsEquiped,
            ColorPrintRGB = ColorPrintRGB,
            FormatBigNumber = FormatBigNumber,
            RoundUpNumber = RoundUpNumber,
            BreakLongTooltipText = BreakLongTooltipText,
            PrintIcon = PrintIcon,
            AchievementDetails = AchievementDetails,
            PlayerInZone = PlayerInZone,
            GetGroupDetails = GetGroupDetails,
            ColorFromClassName = ColorFromClassName,
            CompressData = CompressData,
            ExtractData = ExtractData,
            ShowStopMotion = ShowStopMotion,
            ShowStaticStopMotion = ShowStaticStopMotion,
            GetCastInfo = GetCastInfo,
            MergeTable = MergeTable,
            AppendTable = AppendTable,
            GetAddonVersion= GetAddonVersion,
            GetWAVersion= GetWAVersion,
            TokenCurrentMarketPrice= TokenCurrentMarketPrice,
            getEuroCentFromCopper = getEuroCentFromCopper,
            GetEquippedItemTooltip = GetEquippedItemTooltip,
            StringStartsWith = StringStartsWith,
            HexColorToRGB = HexColorToRGB,
            ShowExportWindow = ShowExportWindow,
            IsMidnight = IsMidnight,
            Contains = Contains,
            ValueExist = ValueExist,
        }
    },
    static = addon.static
}
