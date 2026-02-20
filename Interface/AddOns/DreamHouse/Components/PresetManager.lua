--[[
    DreamHouse - Preset Manager
    Speichern und Laden von Raum-Layouts
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.PresetManager = {}

local presetFrame = nil
local layoutButton = nil

-- Preset-Manager Frame erstellen
function DreamHouse.PresetManager:Create()
    if presetFrame then return presetFrame end
    
    -- Haupt-Frame
    presetFrame = CreateFrame("Frame", "DreamHousePresetManager", UIParent, "BackdropTemplate")
    presetFrame:SetSize(350, 400)
    presetFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    presetFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    presetFrame:SetBackdropColor(0.1, 0.1, 0.15, 0.98)
    presetFrame:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)
    presetFrame:SetMovable(true)
    presetFrame:EnableMouse(true)
    presetFrame:SetClampedToScreen(true)
    presetFrame:RegisterForDrag("LeftButton")
    presetFrame:SetScript("OnDragStart", presetFrame.StartMoving)
    presetFrame:SetScript("OnDragStop", presetFrame.StopMovingOrSizing)
    presetFrame:SetFrameStrata("DIALOG")
    
    -- Titel
    local title = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", presetFrame, "TOP", 0, -10)
    title:SetText("|cff00ccff" .. L["Preset Manager"] .. "|r")
    
    -- Schließen-Button
    local closeBtn = CreateFrame("Button", nil, presetFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", presetFrame, "TOPRIGHT", -2, -2)
    
    -- Preset-Name Eingabe
    local nameLabel = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", presetFrame, "TOPLEFT", 15, -40)
    nameLabel:SetText(L["Save new preset"])
    
    local nameInput = CreateFrame("EditBox", "DreamHousePresetNameInput", presetFrame, "InputBoxTemplate")
    nameInput:SetSize(200, 20)
    nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 5, -5)
    nameInput:SetAutoFocus(false)
    nameInput:SetMaxLetters(50)
    presetFrame.nameInput = nameInput
    
    -- Speichern-Button
    local saveBtn = CreateFrame("Button", nil, presetFrame, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 22)
    saveBtn:SetPoint("LEFT", nameInput, "RIGHT", 10, 0)
    saveBtn:SetText(L["Save"])
    saveBtn:SetScript("OnClick", function()
        local name = nameInput:GetText()
        if name and name ~= "" then
            DreamHouse.PresetManager:SaveCurrentLayout(name)
            nameInput:SetText("")
        end
    end)
    
    -- Preset-Liste
    local listLabel = presetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listLabel:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", -5, -20)
    listLabel:SetText(L["Saved Presets"])
    
    -- ScrollFrame für Presets
    local scrollFrame = CreateFrame("ScrollFrame", nil, presetFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listLabel, "BOTTOMLEFT", 0, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", presetFrame, "BOTTOMRIGHT", -30, 60)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(280, 1)
    scrollFrame:SetScrollChild(content)
    
    presetFrame.scrollFrame = scrollFrame
    presetFrame.content = content
    presetFrame.presetButtons = {}
    
    -- Export/Import Buttons
    local exportBtn = CreateFrame("Button", nil, presetFrame, "UIPanelButtonTemplate")
    exportBtn:SetSize(100, 24)
    exportBtn:SetPoint("BOTTOMLEFT", presetFrame, "BOTTOMLEFT", 15, 15)
    exportBtn:SetText(L["Export"])
    exportBtn:SetScript("OnClick", function()
        DreamHouse.PresetManager:ShowExportDialog()
    end)
    
    local importBtn = CreateFrame("Button", nil, presetFrame, "UIPanelButtonTemplate")
    importBtn:SetSize(100, 24)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 10, 0)
    importBtn:SetText(L["Import"])
    importBtn:SetScript("OnClick", function()
        DreamHouse.PresetManager:ShowImportDialog()
    end)
    
    presetFrame:Hide()
    
    DreamHouse.Debug:Log("PresetManager", "Manager erstellt", "SUCCESS")
    
    return presetFrame
end

-- Preset-Liste aktualisieren
function DreamHouse.PresetManager:RefreshPresetList()
    if not presetFrame then return end
    
    -- Alte Buttons entfernen
    for _, btn in ipairs(presetFrame.presetButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(presetFrame.presetButtons)
    
    -- Presets laden
    local presets = DreamHouse.Settings:GetAllPresets()
    local yOffset = 0
    
    for name, preset in pairs(presets) do
        local btn = self:CreatePresetButton(presetFrame.content, name, preset)
        btn:SetPoint("TOPLEFT", presetFrame.content, "TOPLEFT", 0, -yOffset)
        table.insert(presetFrame.presetButtons, btn)
        yOffset = yOffset + 35
    end
    
    -- Content-Höhe anpassen
    presetFrame.content:SetHeight(math.max(yOffset, 100))
end

-- Preset-Button erstellen
function DreamHouse.PresetManager:CreatePresetButton(parent, name, preset)
    local btn = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    btn:SetSize(280, 32)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
    })
    btn:SetBackdropColor(0.15, 0.15, 0.2, 1)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
    
    -- Name
    local nameText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", btn, "LEFT", 10, 0)
    nameText:SetText(name)
    nameText:SetWidth(150)
    nameText:SetJustifyH("LEFT")
    
    -- Datum
    local dateText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dateText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
    dateText:SetText("|cff888888" .. date("%d.%m.%y", preset.created) .. "|r")
    
    -- Laden-Button
    local loadBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
    loadBtn:SetSize(50, 20)
    loadBtn:SetPoint("RIGHT", btn, "RIGHT", -35, 0)
    loadBtn:SetText(L["Load"])
    loadBtn:SetScript("OnClick", function()
        DreamHouse.PresetManager:LoadPreset(name)
    end)
    
    -- Löschen-Button
    local delBtn = CreateFrame("Button", nil, btn)
    delBtn:SetSize(20, 20)
    delBtn:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
    delBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    delBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
    delBtn:SetScript("OnClick", function()
        StaticPopup_Show("DREAMHOUSE_DELETE_PRESET", name, nil, { presetName = name })
    end)
    
    return btn
end

-- Layout-Button für den Layout-Modus
function DreamHouse.PresetManager:CreateLayoutButton()
    if layoutButton then return layoutButton end
    
    layoutButton = CreateFrame("Button", "DreamHouseLayoutPresetButton", UIParent, "UIPanelButtonTemplate")
    layoutButton:SetSize(100, 24)
    layoutButton:SetText(L["Presets"])
    layoutButton:SetScript("OnClick", function()
        DreamHouse.PresetManager:Toggle()
    end)
    layoutButton:Hide()
    
    return layoutButton
end

-- Layout-Button anzeigen
function DreamHouse.PresetManager:ShowLayoutButton()
    if not layoutButton then
        self:CreateLayoutButton()
    end
    
    -- Position im Layout-Modus Frame
    DreamHouse.Utils:WaitForFrame("HouseEditorFrame", function(editorFrame)
        layoutButton:SetParent(editorFrame)
        layoutButton:ClearAllPoints()
        layoutButton:SetPoint("TOPRIGHT", editorFrame, "TOPRIGHT", -60, -10)
        layoutButton:Show()
    end)
end

function DreamHouse.PresetManager:HideLayoutButton()
    if layoutButton then
        layoutButton:Hide()
    end
end

-- Aktuelles Layout speichern
function DreamHouse.PresetManager:SaveCurrentLayout(name)
    if not name or name == "" then
        DreamHouse.Debug:Log("PresetManager", "Kein Name angegeben", "WARN")
        return false
    end
    
    -- Alle platzierten Items sammeln
    local placedDecor = DreamHouse.Utils:GetAllPlacedDecor()
    
    if #placedDecor == 0 then
        DreamHouse.Debug:Log("PresetManager", "Keine Items zum Speichern", "WARN")
        UIErrorsFrame:AddExternalErrorMessage("|cff00ccff[DreamHouse]|r " .. L["No items to save"])
        return false
    end
    
    local data = {
        items = {},
        itemCount = #placedDecor,
        savedInHouse = DreamHouse.Utils:IsHousingActive(),
    }
    
    -- Item-Daten sammeln (vereinfacht - echte Positions-Daten wären API-abhängig)
    for _, decor in ipairs(placedDecor) do
        local itemData = {
            decorGUID = decor.decorGUID,
            name = decor.name,
            -- Position/Rotation würde hier gespeichert werden
        }
        table.insert(data.items, itemData)
    end
    
    DreamHouse.Settings:SavePreset(name, data)
    
    UIErrorsFrame:AddExternalErrorMessage("|cff00ccff[DreamHouse]|r " .. L.Format("Preset X saved", name, #placedDecor))
    PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED)
    
    self:RefreshPresetList()
    return true
end

-- Preset laden
function DreamHouse.PresetManager:LoadPreset(name)
    local preset = DreamHouse.Settings:GetPreset(name)
    
    if not preset then
        DreamHouse.Debug:Log("PresetManager", "Preset nicht gefunden: " .. name, "ERROR")
        return false
    end
    
    DreamHouse.Debug:Log("PresetManager", "Preset laden: " .. name .. " (" .. preset.data.itemCount .. " Items)", "INFO")
    
    -- Hinweis: Das tatsächliche Laden/Platzieren von Items ist API-abhängig
    -- und würde in der echten Implementation die Housing-API nutzen
    
    UIErrorsFrame:AddExternalErrorMessage("|cff00ccff[DreamHouse]|r " .. L["Preset load not implemented"])
    
    return true
end

-- Export-Dialog
function DreamHouse.PresetManager:ShowExportDialog()
    -- Vereinfachte Export-Funktion
    local presets = DreamHouse.Settings:GetAllPresets()
    local exportString = ""
    
    for name, preset in pairs(presets) do
        exportString = exportString .. name .. ": " .. preset.data.itemCount .. " Items\n"
    end
    
    if exportString == "" then
        exportString = L["No presets to export"]
    end
    
    -- In Chat ausgeben (vereinfacht)
    print("|cff00ccff[DreamHouse]|r Export:")
    print(exportString)
end

-- Import-Dialog
function DreamHouse.PresetManager:ShowImportDialog()
    UIErrorsFrame:AddExternalErrorMessage("|cff00ccff[DreamHouse]|r " .. L["Import not implemented"])
end

-- Anzeigen/Verstecken
function DreamHouse.PresetManager:Show()
    if not presetFrame then
        self:Create()
    end
    self:RefreshPresetList()
    presetFrame:Show()
end

function DreamHouse.PresetManager:Hide()
    if presetFrame then
        presetFrame:Hide()
    end
end

function DreamHouse.PresetManager:Toggle()
    if presetFrame and presetFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Initialisierung
function DreamHouse.PresetManager:Initialize()
    self:Create()
    self:CreateLayoutButton()
    
    -- Preset-Löschen Dialog
    StaticPopupDialogs["DREAMHOUSE_DELETE_PRESET"] = {
        text = L["Delete preset X?"],
        button1 = L["Yes"],
        button2 = L["No"],
        OnAccept = function(self, data)
            DreamHouse.Settings:DeletePreset(data.presetName)
            DreamHouse.PresetManager:RefreshPresetList()
            PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    
    DreamHouse.Debug:Log("PresetManager", "Preset-Manager initialisiert", "SUCCESS")
end

-- Modul registrieren
DreamHouse:RegisterModule("PresetManager", DreamHouse.PresetManager)


