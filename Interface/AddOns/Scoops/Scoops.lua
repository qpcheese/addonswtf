local addonName = "Scoops"
local soundFile = "Interface\\AddOns\\Scoops\\crit.mp3"


local defaults = {
    volume = 1.0, 
    active = true,
    chat = true,
    petEnabled = true,
    healEnabled = true,
    color = "|cff00CCFF",
    recordPlayer = 0,
    recordPet = 0,
    recordHeal = 0,
    totalScoops = 0,
    showCounter = true,
    framePos = nil
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ADDON_LOADED")


local lastSoundTime = 0
local SOUND_THROTTLE = 0.1


local BATCH_INTERVAL = 0.3 
local batchTimer = nil
local critBatch = { player = {}, pet = {}, heal = {} }
local batchHasRecord = { player = false, pet = false, heal = false }


local optionsCategory = nil


local function HexToRGB(hex)
    if not hex or string.len(hex) < 10 then return 0, 0.8, 1 end 
    local rhex, ghex, bhex = string.sub(hex, 5, 6), string.sub(hex, 7, 8), string.sub(hex, 9, 10)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

local function RGBToHex(r, g, b)
    r = math.min(1, math.max(0, r))
    g = math.min(1, math.max(0, g))
    b = math.min(1, math.max(0, b))
    return string.format("|cff%02x%02x%02x", math.floor(r*255), math.floor(g*255), math.floor(b*255))
end


local function UpdateVolume(vol)
    if vol > 1 then vol = 1 end
    if vol < 0 then vol = 0 end
    if ScoopsDB then ScoopsDB.volume = vol end
    SetCVar("Sound_EnableDialog", 1)
    SetCVar("Sound_DialogVolume", vol)
end


local CounterFrame = CreateFrame("Frame", "ScoopsCounterFrame", UIParent)
CounterFrame:SetSize(140, 30)
CounterFrame:SetPoint("CENTER", 0, 0) 
CounterFrame:SetMovable(true)
CounterFrame:EnableMouse(true)
CounterFrame:RegisterForDrag("LeftButton")
CounterFrame:SetClampedToScreen(true) 


CounterFrame.bg = CounterFrame:CreateTexture(nil, "BACKGROUND")
CounterFrame.bg:SetAllPoints()
CounterFrame.bg:SetColorTexture(0, 0, 0, 0.6) 


CounterFrame.text = CounterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
CounterFrame.text:SetPoint("CENTER")
CounterFrame.text:SetText("Scoops: 0")


CounterFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

CounterFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    
    local point, _, relativePoint, x, y = self:GetPoint()
    if ScoopsDB then
        ScoopsDB.framePos = { point, relativePoint, x, y }
    end
end)


local function UpdateCounterDisplay()
    if not ScoopsDB then return end
    
    CounterFrame.text:SetText("Scoops: " .. (ScoopsDB.totalScoops or 0))
    
    if ScoopsDB.showCounter and ScoopsDB.active then
        CounterFrame:Show()
    else
        CounterFrame:Hide()
    end
end


local ScoopsPanel = CreateFrame("Frame", "ScoopsConfigPanel", UIParent)
ScoopsPanel.name = addonName

local title = ScoopsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Scoops Einstellungen")

local cbActive = CreateFrame("CheckButton", nil, ScoopsPanel, "InterfaceOptionsCheckButtonTemplate")
cbActive:SetPoint("TOPLEFT", 16, -50)
cbActive.Text:SetText("Addon Aktiviert (Global)")
cbActive:SetScript("OnClick", function(self)
    if ScoopsDB then 
        ScoopsDB.active = self:GetChecked() 
        UpdateCounterDisplay() 
    end
end)

local cbChat = CreateFrame("CheckButton", nil, ScoopsPanel, "InterfaceOptionsCheckButtonTemplate")
cbChat:SetPoint("TOPLEFT", 16, -85)
cbChat.Text:SetText("Chat Nachrichten anzeigen")
cbChat:SetScript("OnClick", function(self)
    if ScoopsDB then ScoopsDB.chat = self:GetChecked() end
end)

local cbCounter = CreateFrame("CheckButton", nil, ScoopsPanel, "InterfaceOptionsCheckButtonTemplate")
cbCounter:SetPoint("TOPLEFT", 200, -50) 
cbCounter.Text:SetText("Zeige Counter Fenster")
cbCounter:SetScript("OnClick", function(self)
    if ScoopsDB then 
        ScoopsDB.showCounter = self:GetChecked()
        UpdateCounterDisplay()
    end
end)

local cbPet = CreateFrame("CheckButton", nil, ScoopsPanel, "InterfaceOptionsCheckButtonTemplate")
cbPet:SetPoint("TOPLEFT", 16, -120)
cbPet.Text:SetText("Begleiter Krits (Sound & Chat)")
cbPet:SetScript("OnClick", function(self)
    if ScoopsDB then ScoopsDB.petEnabled = self:GetChecked() end
end)

local cbHeal = CreateFrame("CheckButton", nil, ScoopsPanel, "InterfaceOptionsCheckButtonTemplate")
cbHeal:SetPoint("TOPLEFT", 16, -155)
cbHeal.Text:SetText("Heilung Krits (Sound & Chat)")
cbHeal:SetScript("OnClick", function(self)
    if ScoopsDB then ScoopsDB.healEnabled = self:GetChecked() end
end)

local colorLabel = ScoopsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
colorLabel:SetPoint("TOPLEFT", 16, -195)
colorLabel:SetText("Chat Farbe:")

local colorButton = CreateFrame("Button", nil, ScoopsPanel)
colorButton:SetSize(20, 20)
colorButton:SetPoint("LEFT", colorLabel, "RIGHT", 10, 0)
colorButton.swatch = colorButton:CreateTexture(nil, "OVERLAY")
colorButton.swatch:SetAllPoints()
colorButton.swatch:SetColorTexture(0, 0.8, 1) 
colorButton.border = colorButton:CreateTexture(nil, "BACKGROUND")
colorButton.border:SetSize(22, 22)
colorButton.border:SetPoint("CENTER")
colorButton.border:SetColorTexture(1, 1, 1)

local function OnColorChanged(r, g, b)
    local hex = RGBToHex(r, g, b)
    ScoopsDB.color = hex
    colorButton.swatch:SetColorTexture(r, g, b)
end

colorButton:SetScript("OnClick", function()
    if not ScoopsDB then return end
    local r, g, b = HexToRGB(ScoopsDB.color)
    
    if ColorPickerFrame.SetupColorPickerAndShow then
        local info = {
            r = r, g = g, b = b,
            hasOpacity = false,
            swatchFunc = function() 
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                OnColorChanged(nr, ng, nb)
            end,
            cancelFunc = function() OnColorChanged(r, g, b) end,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    else
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.previousValues = {r, g, b}
        ColorPickerFrame.func = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            OnColorChanged(nr, ng, nb)
        end
        ColorPickerFrame.cancelFunc = function()
            local pr, pg, pb = unpack(ColorPickerFrame.previousValues)
            OnColorChanged(pr, pg, pb)
        end
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end
end)

local sliderVol = CreateFrame("Slider", "ScoopsVolumeSlider", ScoopsPanel, "OptionsSliderTemplate")
sliderVol:SetPoint("TOPLEFT", 16, -240)
sliderVol:SetMinMaxValues(0, 100)
sliderVol:SetValueStep(1)
sliderVol:SetObeyStepOnDrag(true)
sliderVol:SetWidth(200)
_G[sliderVol:GetName() .. "Low"]:SetText("0%")
_G[sliderVol:GetName() .. "High"]:SetText("100%")
_G[sliderVol:GetName() .. "Text"]:SetText("Lautst\195\164rke") 

sliderVol:SetScript("OnValueChanged", function(self, value)
    local vol = value / 100
    UpdateVolume(vol)
end)

local btnReset = CreateFrame("Button", nil, ScoopsPanel, "UIPanelButtonTemplate")
btnReset:SetPoint("TOPLEFT", 16, -280)
btnReset:SetSize(140, 30)
btnReset:SetText("Counter Reset")
btnReset:SetScript("OnClick", function()
    if ScoopsDB then
        ScoopsDB.totalScoops = 0
        print("|cff00CCFFScoops Counter wurde zur\195\188ckgesetzt!|r")
        UpdateCounterDisplay() 
    end
end)

ScoopsPanel.refresh = function()
    if not ScoopsDB then return end
    cbActive:SetChecked(ScoopsDB.active)
    cbChat:SetChecked(ScoopsDB.chat)
    cbCounter:SetChecked(ScoopsDB.showCounter) 
    cbPet:SetChecked(ScoopsDB.petEnabled)   
    cbHeal:SetChecked(ScoopsDB.healEnabled) 
    
    if ScoopsDB.volume then sliderVol:SetValue(ScoopsDB.volume * 100) end
    if ScoopsDB.color then
        local r, g, b = HexToRGB(ScoopsDB.color)
        colorButton.swatch:SetColorTexture(r, g, b)
    end
end
ScoopsPanel:SetScript("OnShow", function() ScoopsPanel.refresh() end)


if Settings and Settings.RegisterCanvasLayoutCategory then
    optionsCategory = Settings.RegisterCanvasLayoutCategory(ScoopsPanel, ScoopsPanel.name)
    Settings.RegisterAddOnCategory(optionsCategory)
else
    InterfaceOptions_AddCategory(ScoopsPanel)
end

local function OpenScoopsMenu()
    if Settings and Settings.OpenToCategory and optionsCategory then
        local categoryID = optionsCategory
        if type(optionsCategory) == "table" and optionsCategory.ID then
            categoryID = optionsCategory.ID
        end
        Settings.OpenToCategory(categoryID)
    else
        InterfaceOptionsFrame_OpenToCategory(ScoopsPanel)
        InterfaceOptionsFrame_OpenToCategory(ScoopsPanel)
    end
end


local function FlushMessages()
    batchTimer = nil 
    
    local color = ScoopsDB.color or "|cff00CCFF"
    local reset = "|r"
    local recordText = " (Neuer Rekord!)"
    local updated = false

    
    if #critBatch.player > 0 then
        local count = #critBatch.player
        local sum = 0
        for _, amount in ipairs(critBatch.player) do sum = sum + amount end
        
        
        ScoopsDB.totalScoops = ScoopsDB.totalScoops + count
        updated = true
        
        
        if ScoopsDB.chat then
            local counterText = " (" .. ScoopsDB.totalScoops .. "ter Scoops!)"
            local extra = ""
            if batchHasRecord.player then extra = recordText end
            
            if count == 1 then
                print(color .. "Scoops! Kritischen Schaden verteilt! (" .. sum .. ")" .. extra .. counterText .. reset)
            else
                print(color .. "Scoops! " .. count .. "x Kritischen Schaden verteilt! (Gesamt: " .. sum .. ")" .. extra .. counterText .. reset)
            end
        end
        
        critBatch.player = {}
        batchHasRecord.player = false
    end

    
    if #critBatch.pet > 0 then
        local count = #critBatch.pet
        local sum = 0
        for _, amount in ipairs(critBatch.pet) do sum = sum + amount end
        
        
        ScoopsDB.totalScoops = ScoopsDB.totalScoops + count
        updated = true
        
        if ScoopsDB.chat then
            local petName = UnitName("pet") or "Dein Begleiter"
            local counterText = " (" .. ScoopsDB.totalScoops .. "ter Scoops!)"
            local extra = ""
            if batchHasRecord.pet then extra = recordText end
            
            if count == 1 then
                print(color .. "Scoops! " .. petName .. " hat Kritischen Schaden verteilt! (" .. sum .. ")" .. extra .. counterText .. reset)
            else
                print(color .. "Scoops! " .. petName .. ": " .. count .. "x Kritischer Schaden! (Gesamt: " .. sum .. ")" .. extra .. counterText .. reset)
            end
        end
        
        critBatch.pet = {} 
        batchHasRecord.pet = false
    end

    
    if #critBatch.heal > 0 then
        local count = #critBatch.heal
        local sum = 0
        for _, amount in ipairs(critBatch.heal) do sum = sum + amount end
        
        
        ScoopsDB.totalScoops = ScoopsDB.totalScoops + count
        updated = true
        
        if ScoopsDB.chat then
            local counterText = " (" .. ScoopsDB.totalScoops .. "ter Scoops!)"
            local extra = ""
            if batchHasRecord.heal then extra = recordText end

            if count == 1 then
                print(color .. "Scoops! Dein Heilungs Zauber war Kritisch! (" .. sum .. ")" .. extra .. counterText .. reset)
            else
                print(color .. "Scoops! " .. count .. "x Heilung Kritisch! (Gesamt: " .. sum .. ")" .. extra .. counterText .. reset)
            end
        end
        
        critBatch.heal = {} 
        batchHasRecord.heal = false
    end

    if updated then UpdateCounterDisplay() end
end


frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if not ScoopsDB then ScoopsDB = CopyTable(defaults) end
        
        
        if ScoopsDB.chat == nil then ScoopsDB.chat = true end
        if ScoopsDB.active == nil then ScoopsDB.active = true end
        if ScoopsDB.volume == nil then ScoopsDB.volume = 1.0 end
        if ScoopsDB.color == nil then ScoopsDB.color = "|cff00CCFF" end
        if ScoopsDB.petEnabled == nil then ScoopsDB.petEnabled = true end
        if ScoopsDB.healEnabled == nil then ScoopsDB.healEnabled = true end
        if ScoopsDB.recordPlayer == nil then ScoopsDB.recordPlayer = 0 end
        if ScoopsDB.recordPet == nil then ScoopsDB.recordPet = 0 end
        if ScoopsDB.recordHeal == nil then ScoopsDB.recordHeal = 0 end
        if ScoopsDB.totalScoops == nil then ScoopsDB.totalScoops = 0 end
        if ScoopsDB.showCounter == nil then ScoopsDB.showCounter = true end
        
        UpdateVolume(ScoopsDB.volume)
        
        if ScoopsDB.framePos and type(ScoopsDB.framePos) == "table" then
            CounterFrame:ClearAllPoints()
            local point, relativePoint, x, y = unpack(ScoopsDB.framePos)
            CounterFrame:SetPoint(point, UIParent, relativePoint, x, y)
        end
        
        UpdateCounterDisplay()

        print(ScoopsDB.color .. "Scoops geladen.|r Feuer ab.")

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        if not ScoopsDB or not ScoopsDB.active then return end

        local _, subevent, _, sourceGUID = CombatLogGetCurrentEventInfo()
        local playerGUID = UnitGUID("player")
        local petGUID = UnitGUID("pet")

        if sourceGUID == playerGUID or sourceGUID == petGUID then
            local isCrit = false
            local amount = 0
            
            if subevent == "SWING_DAMAGE" then 
                amount, _, _, _, _, _, isCrit = select(12, CombatLogGetCurrentEventInfo())
            elseif subevent == "RANGE_DAMAGE" or subevent == "SPELL_DAMAGE" then 
                amount, _, _, _, _, _, isCrit = select(15, CombatLogGetCurrentEventInfo())
            elseif subevent == "SPELL_HEAL" then 
                amount, _, _, isCrit = select(15, CombatLogGetCurrentEventInfo())
            end

            if isCrit and amount then
                if sourceGUID == petGUID and not ScoopsDB.petEnabled then return end
                if subevent == "SPELL_HEAL" and not ScoopsDB.healEnabled then return end

                if subevent == "SPELL_HEAL" then
                    if amount > ScoopsDB.recordHeal then
                        ScoopsDB.recordHeal = amount
                        batchHasRecord.heal = true
                    end
                elseif sourceGUID == petGUID then
                    if amount > ScoopsDB.recordPet then
                        ScoopsDB.recordPet = amount
                        batchHasRecord.pet = true
                    end
                else
                    if amount > ScoopsDB.recordPlayer then
                        ScoopsDB.recordPlayer = amount
                        batchHasRecord.player = true
                    end
                end

                local currentTime = GetTime()
                if (currentTime - lastSoundTime) > SOUND_THROTTLE then
                    PlaySoundFile(soundFile, "Dialog") 
                    lastSoundTime = currentTime
                end
                
                
                if subevent == "SPELL_HEAL" then
                    table.insert(critBatch.heal, amount)
                elseif sourceGUID == petGUID then
                    table.insert(critBatch.pet, amount)
                else
                    table.insert(critBatch.player, amount)
                end
                
                if not batchTimer then
                    batchTimer = C_Timer.After(BATCH_INTERVAL, FlushMessages)
                end
            end
        end
    end
end)

SLASH_SCOOPS1 = "/scoops"
SlashCmdList["SCOOPS"] = function(msg)
    local msg = msg:lower()
    local volNumber = tonumber(msg)

    if volNumber then
        if volNumber > 100 then volNumber = 100 end
        if volNumber < 0 then volNumber = 0 end
        
        local decimal = volNumber / 100
        UpdateVolume(decimal)
        PlaySoundFile(soundFile, "Dialog") 
        print("Scoops Lautst\195\164rke: " .. volNumber .. "%")
        
    elseif msg == "reset" then
        ScoopsDB.recordPlayer = 0
        ScoopsDB.recordPet = 0
        ScoopsDB.recordHeal = 0
        ScoopsDB.totalScoops = 0
        print(ScoopsDB.color .. "Scoops Rekorde und Counter wurden zur\195\188ckgesetzt!|r")
        UpdateCounterDisplay()
        
    elseif msg == "off" then
        ScoopsDB.active = false
        print("Scoops deaktiviert.")
        UpdateCounterDisplay()
    elseif msg == "on" then
        ScoopsDB.active = true
        print("Scoops aktiviert.")
        UpdateCounterDisplay()
    elseif msg == "menu" or msg == "config" or msg == "options" then
        OpenScoopsMenu()
    else
        print(ScoopsDB.color .. "Scoops Befehle:|r")
        print("  /scoops 100   -> Lautst\195\164rke 100% (Max)")
        print("  /scoops on/off -> Ein/Ausschalten")
        print("  /scoops reset -> Alles zur\195\188cksetzen")
        print("  /scoops menu  -> Men\195\188 \195\182ffnen")
    end
end