local name,addon=...

-- Define Globals
local SMDGT = LibStub("AceAddon-3.0"):NewAddon(name)
_G.Madhouse.addon = SMDGT
_G.Madhouse.widgets = {}
_G.Madhouse.db = {}
_G.Madhouse.feature = {}

AddonVersion = C_AddOns.GetAddOnMetadata(name, "Version")
charName = UnitName("player")
realmName = GetRealmName()
fullName = charName .. "-" .. realmName

isGerman =  GetLocale() == "deDE"
isHorde = "Horde" == UnitFactionGroup("player")

local Lib = Madhouse.API.v1

-- Load Libsf
AceGUI = LibStub('AceGUI-3.0')
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)


-- OnAddonLoaded event handler
function SMDGT:OnAddonLoaded()
    if not MadhouseAddonConfig then
        MadhouseAddonConfig = {
            global = {}
        }
    end
    if not MadhouseAddonSocial then
        MadhouseAddonSocial = {}
    end
    if not MadhouseAddonConfig[fullName] then
        MadhouseAddonConfig[fullName] = {}
    end
    if not MadhouseAddonConfig[fullName]["meta"] then
        MadhouseAddonConfig[fullName]["meta"] = {}
    end
end

-- SetupHooks event handler
function SMDGT:SetupHooks()
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
       -- Pass the tooltip and unit to our function
        --  print("Detecting unit")
        if not Madhouse.addon:LoadGlobalData("settings-social-points",false) then
          return
        end
        if not InCombatLockdown() then
            local _, unit = tooltip:GetUnit()
            if Madhouse.API.v1.ValueExist(unit) and UnitIsPlayer(unit) then
                local guid = UnitGUID(unit);
                if guid  then
                    -- Append custom text to the tooltip
                    tooltip:AddLine(" ")
                    tooltip:AddLine(Madhouse.API.v1.ColorPrintRGB("Madhouse Points:",addon.static.color.accent))
                    tooltip:AddLine(SMDGT:SocialPointsString(guid))
                    tooltip:AddLine(" ")
                    tooltip:Show() -- Refresh the tooltip to display changes
            --    else
            --        print("No guid found")
                end

            end
        end
    end)

    hooksecurefunc("LFGListUtil_SetSearchEntryTooltip", function(tooltip,resultID)
            if not Madhouse.addon:LoadGlobalData("settings-social-points",false) then
              return
            end
           local leaderName = C_LFGList.GetSearchResultInfo(resultID)["leaderName"];

           local guid = Madhouse.addon:PlayerGUIDByName(leaderName)

           tooltip:AddLine(" ")
           tooltip:AddLine(Madhouse.API.v1.ColorPrintRGB("Madhouse Points:",addon.static.color.accent))
           tooltip:AddLine(SMDGT:SocialPointsString(guid))
           tooltip:Show() -- Refresh the tooltip to display changes
    end)

    hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", function(member, appID, memberIdx)
            if not Madhouse.addon:LoadGlobalData("settings-social-points",false) then
              return
            end
           	local name  = C_LFGList.GetApplicantMemberInfo(appID, memberIdx);

           local guid = Madhouse.addon:PlayerGUIDByName(name)

           	if not member.MH_POINTS then
           		member.MH_POINTS = member:CreateFontString("$parentFlag", "ARTWORK", "GameFontNormalSmall")
           		member.MH_POINTS:SetPoint("LEFT", member.Name, "RIGHT", 3, 0)
           	end
           	if guid ~="none" then
           	    member.MH_POINTS:SetText(SMDGT:SocialPointsString(guid,true))
           	end
    end)
    Menu.ModifyMenu("MENU_UNIT_PLAYER", function(_, rootDescription, contextData)
        Madhouse.API.v1.Inspect(rootDescription)
        rootDescription:CreateDivider()
        rootDescription:CreateTitle("Madhouse")
        rootDescription:CreateButton(isGerman and "Bewerten: Gut" or  "Rate: Good", function()
            local guid = contextData.playerLocation.guid;
            local name = contextData.name;
            local server = contextData.server or GetRealmName();
            local _, englishClass = UnitClass(contextData.unit);
            SMDGT:SocialPointsVote(guid, 1, {
                name = name,
                realm = server,
                class = englishClass
            })
            local msg = isGerman and "Gut" or "Good"
            local color = "00FF00"
            print(Madhouse.API.v1.ColorPrintRGB((isGerman and "Abgestimmt:  " or "Voted:  ") ..
                        msg .. (isGerman and " für " or " for ") .. name, color))
        end)
        rootDescription:CreateButton(isGerman and "Bewerten: Schlecht" or  "Rate: Bad", function()
            local guid = contextData.playerLocation.guid;
            local name = contextData.name;
            local server = contextData.server or GetRealmName();
            local _, englishClass = UnitClass(contextData.unit);

            SMDGT:SocialPointsVote(guid, 0, {
                name = name,
                realm = server,
                class = englishClass
            })
            msg = isGerman and "Schlecht" or "Bad"
            color = "FF0000"
            print(Madhouse.API.v1.ColorPrintRGB((isGerman and "Abgestimmt:  " or "Voted:  ") ..
                        msg .. (isGerman and " für " or " for ") .. name, color))
        end)
    end)

end

-- ############################# END LOAD/SAVE ###################################

function SMDGT:SaveGlobalData(key, value)
    if not key then return end
    MadhouseAddonConfig.global[key] = value
end

function SMDGT:LoadGlobalData(key,fallback)
    if not key then return nil end
    if MadhouseAddonConfig.global[key]  == nil then
        return fallback
    end
    return MadhouseAddonConfig.global[key]
end

function SMDGT:SaveUserData(key, value)
    if not key then return end
    MadhouseAddonConfig[fullName][key] = value
end

function SMDGT:LoadUserData(key,fallback)
    if not key then return nil end
    if not MadhouseAddonConfig[fullName] then return fallback end
    return MadhouseAddonConfig[fullName][key]
end

function SMDGT:SaveUserMeta(key, value)
    if not key then return end
    MadhouseAddonConfig[fullName]["meta"][key] = value
end

function SMDGT:LoadUserMeta(key,fallback)
    if not key then return nil end
    if not MadhouseAddonConfig[fullName] then return fallback end
    return MadhouseAddonConfig[fullName]["meta"][key]
end

local PlayerLookupCache = {}

function SMDGT:PlayerGUIDByName(aName)
    local name = aName or ""
    if PlayerLookupCache[name] then
        return PlayerLookupCache[name]
    end
    -- extract name+realm and (only) name
    local shortname = Ambiguate(name, "short")
    local fullname = Ambiguate(name, "mail")

    -- if:     shortname and fullname are equal -> applicant is from user's own realm
    -- else:   extract realm from
    local realm
    if shortname == fullname then
        realm = realmName
    else
        realm = string.sub(fullname, string.len(shortname)+2)
    end

    for i,v in pairs(MadhouseAddonSocial) do
        if v.meta.name == shortname and v.meta.realm == realm then
            PlayerLookupCache[name] = i
            return i
        end
    end
    return "none"
end

function SMDGT:SocialPointsVote(guid,value,data)
    local id = guid or "error"
    if MadhouseAddonSocial[id]  == nil then
        MadhouseAddonSocial[id] = {
            up = 0,
            myUp = 0,
            down = 0,
            myDown = 0,
            lastVote = 0,
            leave = 0,
            meta = {
                name = data.name,
                realm = data.realm,
                class = data.class,
            },
            history = {}
        }
    end
    if value == 0 then
        MadhouseAddonSocial[id].down = MadhouseAddonSocial[id].down + 1
        MadhouseAddonSocial[id].myDown = MadhouseAddonSocial[id].myDown + 1
    elseif value == 1 then
        MadhouseAddonSocial[id].up = MadhouseAddonSocial[id].up + 1
        MadhouseAddonSocial[id].myUp = MadhouseAddonSocial[id].myUp + 1
    elseif value == 2 then
        MadhouseAddonSocial[id].leave = MadhouseAddonSocial[id].leave + 1
    end

    if value ~= -1  then
        local time = time();
        MadhouseAddonSocial[id].lastVote = time
        local line = time .. ":" .. tostring(value)
        line = line .. ":" .. "1"
        table.insert(MadhouseAddonSocial[id].history, line)
    end
end

function SMDGT:SocialPointsMerge(data)
    if not data then
        Madhouse.API.v1.Dprint("Error: No data to merge")
        return
    end
    local function splitter(spl)
        -- "1737247922:1:1"
        local t =  tonumber(string.sub(spl,1,10)) -- time
        local v =  tonumber(string.sub(spl,12,12)) -- value
        local o =  tonumber(string.sub(spl,14,14)) -- version
        return t,v,o
    end

    for key, value in pairs(data) do
        if not MadhouseAddonSocial[key] then
            MadhouseAddonSocial[key] = {
                 up = 0,
                 myUp = 0,
                 down = 0,
                 myDown = 0,
                 lastVote = 0,
                 leave = 0,
                 meta = value.meta,
                 history = {}
             }
        end
        -- Iterate over the new data
        for _, v in pairs(value.history) do
            local t1,v1 = splitter(v);
            local found = false
            -- Search for the data in the old data
            for _,y in pairs(MadhouseAddonSocial[key].history) do
                local t2 = splitter(y);
                if t1 == t2 then
                    found = true
                    break
                end
            end
            -- Add the data if not found
            if not found then
                local line = t1 .. ":" .. v1 .. ":0"
                if t1 > MadhouseAddonSocial[key].lastVote then
                    MadhouseAddonSocial[key].lastVote = t1
                end
                table.insert(MadhouseAddonSocial[key].history, line)
                if v1 == 0 then
                    MadhouseAddonSocial[key].down = MadhouseAddonSocial[key].down + 1
                elseif v1 == 1 then
                    MadhouseAddonSocial[key].up = MadhouseAddonSocial[key].up + 1
                elseif v1 == 2 then
                    MadhouseAddonSocial[key].leave = MadhouseAddonSocial[key].leave + 1
                end
            end
        end
    end
end


function SMDGT:SocialPointsString(guid,oneline)
    local ol = oneline or false
    -- print("DB:Voting for: " .. guid .. " with " .. (data and "up" or "down"))
    local id = guid or "error"
    if MadhouseAddonSocial[id]  == nil then
        return Lib.ColorPrintRGB(isGerman and "Keine Daten" or "No Data",addon.static.color.red)
    end
    local data = MadhouseAddonSocial[id];

    if (ol) then
        return Lib.ColorPrintRGB(data.up, addon.static.color.green) .. " | " .. Lib.ColorPrintRGB(data.down, addon.static.color.red) .. " | " .. Lib.ColorPrintRGB(data.leave, addon.static.color.blue)
    end

    local line = Lib.ColorPrintRGB(data.up - data.down,addon.static.color.accent) ..  " | " .. Lib.ColorPrintRGB(data.up,addon.static.color.green) .. " | " .. Lib.ColorPrintRGB(data.down,addon.static.color.red).. " | " .. Lib.ColorPrintRGB(data.leave,addon.static.color.blue)
    local myLine = Lib.ColorPrintRGB(data.myUp - data.myDown,addon.static.color.accent) ..  " | " .. Lib.ColorPrintRGB(data.myUp,addon.static.color.green) .. " | " .. Lib.ColorPrintRGB(data.myDown,addon.static.color.red)

    local timeString = SecondsToTime(time() - data.lastVote)
    return (isGerman and "Ges: " or "Sum: ").. line ..'\n'.. (isGerman and "Meine:" or "My:   ") .. myLine ..'\n' .. (isGerman and "Zuletzt: " or "Last: ") .. timeString
end

-- ############################# END LOAD/SAVE ###################################

function SMDGT:PrintStartMessage()
    print(Lib.ColorPrintRGB(name .. " V: "..AddonVersion, addon.static.color.accent))
end

function SMDGT:SetupOptionsPanel()
	local panel = AceGUI:Create("BlizOptionsGroup")
	panel:SetName(name)
	panel:SetLayout("List")
	local header = AceGUI:Create("Heading")

	header:SetText("MadhousePack Settings Page")
	header:SetFullWidth(true) -- Sorgt dafür, dass der Header die volle Breite des Frames einnimmt
	panel:AddChild(header)

    local image = AceGUI:Create("Label")
    image:SetImage(Lib.AddonFolder("Textures\\Logo.tga"))
    image:SetImageSize(160, 160)
    panel:AddChild(image)

	local largeText = AceGUI:Create("Label")
    largeText:SetText("Addon created by "..Madhouse.API.v1.ColorPrintRGB("Elschnagoo [Astrastar]", "FF7C0A"))
    largeText:SetFontObject(GameFontHighlightLarge)  -- Use a larger font
    largeText:SetFullWidth(true)
    panel:AddChild(largeText)

	local largeText2 = AceGUI:Create("Label")
    largeText2:SetText("Version: " .. AddonVersion)
    largeText2:SetFontObject(GameFontHighlightLarge)  -- Use a larger font
    largeText2:SetFullWidth(true)
    largeText2:SetColor(1, 0, 0)
    panel:AddChild(largeText2)



	local button = AceGUI:Create("Button")
	button:SetText(isGerman and "Öffnet die Einstellungen" or "Open settings window")
	button:SetWidth(200)
	button:SetCallback("OnClick", function() Madhouse.widgets.SettingsWindow:Togle() end)
	panel:AddChild(button)

    local category = _G.Settings.RegisterCanvasLayoutCategory(panel.frame, panel.frame.name)
    _G.Settings.RegisterAddOnCategory(category)
end

function SMDGT:LoadSoundpack()
    local basePath = Lib.AddonFolder("Sounds\\")

    for name, path in pairs(addon.sounds) do
        LSM:Register("sound", "|cffff6060Madhouse:|r " .. name, basePath .. path .. ".mp3")
    end

    print(Lib.ColorPrintRGB(name .. ": Sound pack loaded", addon.static.color.accent))
end

function SMDGT:LoadTextures()
    local basePath = Lib.AddonFolder("Textures\\")

    for name, path in pairs(addon.textures) do
        LSM:Register("statusbar", name, basePath .. path .. ".tga")
    end

    print(Lib.ColorPrintRGB(name .. ": Texture pack loaded", addon.static.color.accent))
end

function SMDGT:SetupBackground()
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:RegisterEvent('READY_CHECK')
    frame:RegisterEvent('LFG_ROLE_CHECK_SHOW')
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "READY_CHECK" then
            if not InCombatLockdown() and SMDGT:LoadGlobalData("settings-auto-ready-check",false) then
                ReadyCheckFrameYesButton:Click()
            end
        elseif event == "LFG_ROLE_CHECK_SHOW" and SMDGT:LoadGlobalData("settings-auto-queue",false)  then
            CompleteLFGRoleCheck(true)
        end
    end)
end

function SMDGT:SetupMinimap()
     local minimapLDB = LDB:NewDataObject(name, {
        type = "launcher",
        text = name,
        icon = Lib.AddonFolder("Textures\\Logo.tga"),
        OnClick = function(clickedframe, button)
            if button == "LeftButton" then
              Madhouse.widgets.CurrencyWindow:Togle()
            elseif button == "RightButton" then
              Madhouse.widgets.WindowManager:Togle()
            elseif button == "MiddleButton" then
              Madhouse.widgets.SettingsWindow:Togle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(name)
            if isGerman then
                tooltip:AddLine(Lib.ColorPrintRGB("Links Klick:", addon.static.color.accent) .. " Öffnet das Währungsfenster")
                tooltip:AddLine(Lib.ColorPrintRGB("Rechts Klick:", addon.static.color.accent) .." Öffnet die Fensterübersicht")
                tooltip:AddLine(Lib.ColorPrintRGB("Mittel Klick:", addon.static.color.accent) .. " Öffnet das Einstellungsfenster")
            else
                tooltip:AddLine(Lib.ColorPrintRGB("Left Click", addon.static.color.accent) .. " to open currency window")
                tooltip:AddLine(Lib.ColorPrintRGB("Right Click", addon.static.color.accent) .. " to open window overview")
                tooltip:AddLine(Lib.ColorPrintRGB("Middle Click", addon.static.color.accent) .. " to open settings window")
            end
        end,
    })
    if not MadhouseAddonConfig.global.minimap then
        MadhouseAddonConfig.global.minimap = {
            hide = false
        }
    end
    LDBIcon:Register(name, minimapLDB, MadhouseAddonConfig.global.minimap)
    LDBIcon:AddButtonToCompartment(name)
    LDBIcon:Refresh(name)
end


function SMDGT:SetupWindow(windowKey,init)
    local window = Madhouse.widgets[windowKey]
    local isShown = self:LoadUserData("window_"..window.WindowName.."_show") or false;

    if init then
        window:InitWindow()
    else
        window:Show()
        if not isShown then
            window:Hide()
        end
    end
end
