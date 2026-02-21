local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

BagHiderDB = BagHiderDB or {}

local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()

local function UpdateVisibility()
    if InCombatLockdown() then return end
    
    -- Si hideBags est true, on parent au frame caché, sinon au UIParent (visible)
    local bagParent = BagHiderDB.hideBags and HiddenFrame or UIParent
    for i = 0, 3 do
        local slot = _G["CharacterBag"..i.."Slot"]
        if slot then slot:SetParent(bagParent) end
    end
    if CharacterReagentBag0Slot then CharacterReagentBag0Slot:SetParent(bagParent) end
    if BagBarExpandToggle then BagBarExpandToggle:SetParent(bagParent) end

    local backpackParent = BagHiderDB.hideBackpack and HiddenFrame or UIParent
    if MainMenuBarBackpackButton then
        MainMenuBarBackpackButton:SetParent(backpackParent)
    end
end

local f = CreateFrame("Frame", "HideBagBarMainFrame", UIParent, "BasicFrameTemplateWithInset")
f:SetSize(300, 190)
f:SetPoint("CENTER")
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 10, 0)
f.title:SetText("Hide Bag Bar")
f:Hide()

local cb1 = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
cb1:SetPoint("TOPLEFT", 20, -40)
cb1.text = cb1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cb1.text:SetPoint("LEFT", cb1, "RIGHT", 5, 0)
cb1.text:SetText("Masquer le sac principal")
cb1:SetScript("OnClick", function(self)
    BagHiderDB.hideBackpack = self:GetChecked()
    UpdateVisibility()
end)

local cb2 = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
cb2:SetPoint("TOPLEFT", 20, -80)
cb2.text = cb2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cb2.text:SetPoint("LEFT", cb2, "RIGHT", 5, 0)
cb2.text:SetText("Masquer les sacs secondaires")
cb2:SetScript("OnClick", function(self)
    BagHiderDB.hideBags = self:GetChecked()
    UpdateVisibility()
end)

local cb3 = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
cb3:SetPoint("TOPLEFT", 20, -120)
cb3.text = cb3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cb3.text:SetPoint("LEFT", cb3, "RIGHT", 5, 0)
cb3.text:SetText("Masquer l'icône minimap")
cb3:SetScript("OnClick", function(self)
    BagHiderDB.minimap.hide = self:GetChecked()
    if BagHiderDB.minimap.hide then
        icon:Hide("BagHider")
    else
        icon:Show("BagHider")
    end
end)

local function ToggleUI()
    if f:IsShown() then f:Hide() else 
        cb1:SetChecked(BagHiderDB.hideBackpack)
        cb2:SetChecked(BagHiderDB.hideBags)
        cb3:SetChecked(BagHiderDB.minimap.hide)
        f:Show() 
    end
end

-- Commandes et Evénements
SLASH_HIDEBAGBAR1 = "/hbf"
SlashCmdList["HIDEBAGBAR"] = function() ToggleUI() end

local e = CreateFrame("Frame")
e:RegisterEvent("PLAYER_LOGIN")
e:RegisterEvent("PLAYER_REGEN_ENABLED")
e:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        BagHiderDB = BagHiderDB or {}
        
        -- CHANGEMENT ICI : Initialisation à TRUE (Caché) par défaut
        if BagHiderDB.hideBags == nil then BagHiderDB.hideBags = true end
        if BagHiderDB.hideBackpack == nil then BagHiderDB.hideBackpack = true end
        if BagHiderDB.minimap == nil then BagHiderDB.minimap = { hide = false } end
        
        local obj = LDB:NewDataObject("BagHider", {
            type = "launcher",
            icon = "Interface\\Icons\\inv_misc_bag_10",
            OnClick = function() ToggleUI() end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("Hide Bag Bar")
                tooltip:AddLine("|cFFCFCFCFClic pour ouvrir les options|r")
            end,
        })
        icon:Register("BagHider", obj, BagHiderDB.minimap)
        UpdateVisibility()
    else
        UpdateVisibility()
    end
end)