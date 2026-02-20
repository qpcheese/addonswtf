--[[
    DreamHouse - Debug Console
    Live-Feed Konsole für Debugging und Logging
    
    Features:
    - Kopierbare Logs (Ctrl+A, Ctrl+C)
    - Bleibt im Housing-Modus sichtbar
    - Export in Chat oder als String
]]

local addonName, DreamHouse = ...

-- Localization shortcut (may not exist yet during early load)
local function GetL()
    return DreamHouse.L or {}
end

DreamHouse.Debug = {}

-- Log-Buffer für die Konsole
local logBuffer = {}
local MAX_LOG_ENTRIES = 500 -- Mehr Einträge speichern

-- Log-Levels mit Farben
local LOG_LEVELS = {
    DEBUG = { priority = 1, color = "|cff888888", name = "DEBUG" },
    INFO = { priority = 2, color = "|cffffffff", name = "INFO" },
    WARN = { priority = 3, color = "|cffffcc00", name = "WARN" },
    ERROR = { priority = 4, color = "|cffff4444", name = "ERROR" },
    SUCCESS = { priority = 2, color = "|cff44ff44", name = "SUCCESS" },
}

-- Interne Log-Funktion
function DreamHouse.Debug:Log(category, message, level)
    level = level or "INFO"
    local levelInfo = LOG_LEVELS[level] or LOG_LEVELS.INFO
    
    -- Zeitstempel
    local timestamp = date("%H:%M:%S")
    
    -- Log-Entry erstellen
    local entry = {
        timestamp = timestamp,
        category = category,
        message = message,
        level = level,
        color = levelInfo.color,
    }
    
    -- Zum Buffer hinzufügen
    table.insert(logBuffer, entry)
    
    -- Buffer-Limit einhalten
    while #logBuffer > MAX_LOG_ENTRIES do
        table.remove(logBuffer, 1)
    end
    
    -- Konsole aktualisieren falls sichtbar
    if self.console and self.console:IsShown() then
        self:UpdateConsole()
    end
    
    -- Auch in den Chat ausgeben wenn verbose
    if DreamHouse.Settings and DreamHouse.Settings.db and DreamHouse.Settings:Get("settings", "debugVerbose") then
        local formattedMsg = string.format("|cff00ccff[DH]|r %s[%s]|r %s", levelInfo.color, category, message)
        print(formattedMsg)
    end
end

-- Konsole erstellen
function DreamHouse.Debug:CreateConsole()
    if self.console then return self.console end
    
    -- Haupt-Frame - WICHTIG: Hoher FrameStrata damit es über Housing-UI bleibt!
    local console = CreateFrame("Frame", "DreamHouseDebugConsole", UIParent, "BackdropTemplate")
    console:SetSize(500, 300)
    console:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 200)
    console:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    console:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    console:SetBackdropBorderColor(0.3, 0.5, 0.8, 1)
    console:SetMovable(true)
    console:EnableMouse(true)
    console:SetClampedToScreen(true)
    console:RegisterForDrag("LeftButton")
    console:SetScript("OnDragStart", console.StartMoving)
    console:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        if DreamHouse.Settings and DreamHouse.Settings.db then
            DreamHouse.Settings:SaveWindowPosition("debugConsole", point, nil, relativePoint, x, y)
        end
    end)
    
    -- WICHTIG: Hoher Strata damit es über dem Housing-Editor bleibt!
    console:SetFrameStrata("FULLSCREEN_DIALOG")
    console:SetFrameLevel(100)
    
    -- Titel-Bar
    local titleBar = CreateFrame("Frame", nil, console)
    titleBar:SetHeight(26)
    titleBar:SetPoint("TOPLEFT", console, "TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", console, "TOPRIGHT", -4, -4)
    
    -- Titel-Text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 5, 0)
    local L = GetL()
    titleText:SetText("|cff00ccffDreamHouse|r " .. (L["Debug"] or "Debug") .. " (" .. #logBuffer .. " " .. (L["Entries"] or "Entries") .. ")")
    console.titleText = titleText
    
    -- Schließen-Button
    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", 2, 0)
    closeBtn:SetScript("OnClick", function() console:Hide() end)
    
    -- Clear-Button
    local clearBtn = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    clearBtn:SetSize(50, 20)
    clearBtn:SetPoint("RIGHT", closeBtn, "LEFT", -5, 0)
    clearBtn:SetText(L["Clear"] or "Clear")
    clearBtn:SetScript("OnClick", function()
        wipe(logBuffer)
        DreamHouse.Debug:UpdateConsole()
        DreamHouse.Debug:Log("Debug", "Log geleert", "INFO")
    end)
    
    -- "Alles -> Chat" Button
    local chatBtn = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    chatBtn:SetSize(80, 20)
    chatBtn:SetPoint("RIGHT", clearBtn, "LEFT", -5, 0)
    chatBtn:SetText(L["-> Chat"] or "-> Chat")
    chatBtn:SetScript("OnClick", function()
        print("|cff00ccff========== DreamHouse Debug Log ==========|r")
        for i, entry in ipairs(logBuffer) do
            print(string.format("[%s] [%s] [%s] %s", entry.timestamp, entry.level, entry.category, entry.message))
        end
        print("|cff00ccff========== Ende (" .. #logBuffer .. " Einträge) ==========|r")
    end)
    chatBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        local L = GetL()
        GameTooltip:SetText((L.Format and L.Format("Output X entries to chat", #logBuffer)) or ("Output " .. #logBuffer .. " entries to chat"))
        GameTooltip:Show()
    end)
    chatBtn:SetScript("OnLeave", GameTooltip_Hide)
    
    -- Info-Text
    local infoText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("RIGHT", chatBtn, "LEFT", -10, 0)
    infoText:SetText("|cff888888" .. (L["Ctrl+A = All, Ctrl+C = Copy"] or "Ctrl+A = All, Ctrl+C = Copy") .. "|r")
    
    -- Scroll-Frame
    local scrollFrame = CreateFrame("ScrollFrame", "DreamHouseDebugScroll", console, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", console, "BOTTOMRIGHT", -26, 8)
    
    -- EditBox für kopierbaren Text
    local editBox = CreateFrame("EditBox", "DreamHouseDebugEditBox", scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetWidth(scrollFrame:GetWidth() - 10)
    editBox:SetAutoFocus(false)
    editBox:EnableMouse(true)
    editBox:SetTextInsets(5, 5, 5, 5)
    
    -- Hintergrund für EditBox
    local editBg = editBox:CreateTexture(nil, "BACKGROUND")
    editBg:SetAllPoints()
    editBg:SetColorTexture(0, 0, 0, 0.3)
    
    scrollFrame:SetScrollChild(editBox)
    
    -- EditBox Events - Nur Lesen erlauben, kein Editieren
    editBox:SetScript("OnEscapePressed", function(self) 
        self:ClearFocus() 
    end)
    
    editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            -- Wenn User etwas tippt, Text wiederherstellen
            DreamHouse.Debug:UpdateConsole()
        end
    end)
    
    -- Ctrl+A zum Alles-Auswählen
    editBox:SetScript("OnKeyDown", function(self, key)
        if IsControlKeyDown() then
            if key == "A" then
                self:HighlightText()
            elseif key == "C" then
                -- Kopieren passiert automatisch
            end
        end
    end)
    
    -- Klick = Fokus für Kopieren
    editBox:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:SetFocus()
        end
    end)
    
    console.editBox = editBox
    console.scrollFrame = scrollFrame
    
    -- Resize Handle
    local resizer = CreateFrame("Button", nil, console)
    resizer:SetSize(16, 16)
    resizer:SetPoint("BOTTOMRIGHT", console, "BOTTOMRIGHT", -2, 2)
    resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    
    resizer:SetScript("OnMouseDown", function()
        console:StartSizing("BOTTOMRIGHT")
    end)
    resizer:SetScript("OnMouseUp", function()
        console:StopMovingOrSizing()
        editBox:SetWidth(scrollFrame:GetWidth() - 10)
        DreamHouse.Debug:UpdateConsole()
    end)
    
    console:SetResizable(true)
    console:SetResizeBounds(350, 150, 800, 600)
    
    self.console = console
    
    -- Gespeicherte Position laden
    if DreamHouse.Settings and DreamHouse.Settings.db then
        local pos = DreamHouse.Settings:GetWindowPosition("debugConsole")
        if pos then
            console:ClearAllPoints()
            console:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
        end
    end
    
    -- Initial versteckt
    console:Hide()
    
    -- WICHTIG: Wenn Housing-Editor aktiv wird, Parent wechseln!
    self:SetupParentSwitching(console)
    
    local L = GetL()
    self:Log("Debug", L["Console initialized"] or "Console initialized (Ctrl+A, Ctrl+C to copy)", "SUCCESS")
    
    return console
end

-- Parent-Wechsel Setup damit Konsole im Housing-Editor sichtbar bleibt
function DreamHouse.Debug:SetupParentSwitching(console)
    -- Event-Frame für Parent-Wechsel
    local parentWatcher = CreateFrame("Frame")
    parentWatcher:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    
    parentWatcher:SetScript("OnEvent", function(self, event, newMode)
        if not console then return end
        
        -- Aktuelle Position merken
        local point, _, relativePoint, x, y = console:GetPoint()
        
        if newMode and newMode ~= Enum.HouseEditorMode.None then
            -- Editor aktiv - zu HouseEditorFrame wechseln
            C_Timer.After(0.1, function()
                if HouseEditorFrame and HouseEditorFrame:IsShown() then
                    console:SetParent(HouseEditorFrame)
                    console:SetFrameStrata("FULLSCREEN_DIALOG")
                    console:SetFrameLevel(500)
                    -- Position wiederherstellen relativ zu UIParent
                    console:ClearAllPoints()
                    console:SetPoint(point, UIParent, relativePoint, x, y)
                    DreamHouse.Debug:Log("Debug", "Konsole -> HouseEditorFrame", "DEBUG")
                end
            end)
        else
            -- Editor inaktiv - zurück zu UIParent
            C_Timer.After(0.1, function()
                console:SetParent(UIParent)
                console:SetFrameStrata("FULLSCREEN_DIALOG")
                console:SetFrameLevel(100)
                console:ClearAllPoints()
                console:SetPoint(point, UIParent, relativePoint, x, y)
                DreamHouse.Debug:Log("Debug", "Konsole -> UIParent", "DEBUG")
            end)
        end
    end)
    
    -- Auch beim ersten Öffnen des Editors prüfen
    hooksecurefunc("ShowUIPanel", function(frame)
        if frame and frame == HouseEditorFrame and console:IsShown() then
            C_Timer.After(0.2, function()
                if HouseEditorFrame and HouseEditorFrame:IsShown() then
                    local point, _, relativePoint, x, y = console:GetPoint()
                    console:SetParent(HouseEditorFrame)
                    console:SetFrameStrata("FULLSCREEN_DIALOG")
                    console:SetFrameLevel(500)
                    console:ClearAllPoints()
                    console:SetPoint(point, UIParent, relativePoint, x, y)
                end
            end)
        end
    end)
    
    self.parentWatcher = parentWatcher
end

-- Konsole aktualisieren
function DreamHouse.Debug:UpdateConsole()
    if not self.console then return end
    
    local lines = {}
    
    for _, entry in ipairs(logBuffer) do
        if self.filters and self.filters[entry.level] == false then
            -- Filter ist explizit auf false gesetzt, überspringen
        else
            local line = string.format(
                "[%s] [%s] [%s] %s",
                entry.timestamp,
                entry.level,
                entry.category,
                entry.message
            )
            table.insert(lines, line)
        end
    end
    
    local text = table.concat(lines, "\n")
    
    -- Text setzen ohne Events auszulösen
    self.console.editBox:SetText(text)
    
    -- Titel aktualisieren
    if self.console.titleText then
        local L = GetL()
        self.console.titleText:SetText("|cff00ccffDreamHouse|r " .. (L["Debug"] or "Debug") .. " (" .. #logBuffer .. " " .. (L["Entries"] or "Entries") .. ")")
    end
    
    -- EditBox Höhe anpassen
    local numLines = #lines
    local lineHeight = 12
    local height = math.max((numLines * lineHeight) + 20, 100)
    self.console.editBox:SetHeight(height)
    
    -- Nach unten scrollen
    C_Timer.After(0.02, function()
        if self.console and self.console.scrollFrame then
            local maxScroll = self.console.scrollFrame:GetVerticalScrollRange()
            self.console.scrollFrame:SetVerticalScroll(maxScroll)
        end
    end)
end

-- Konsole ein-/ausblenden
function DreamHouse.Debug:Toggle()
    if not self.console then
        self:CreateConsole()
    end
    
    if self.console:IsShown() then
        self.console:Hide()
    else
        self.console:Show()
        self:UpdateConsole()
    end
end

-- Konsole anzeigen
function DreamHouse.Debug:Show()
    if not self.console then
        self:CreateConsole()
    end
    self.console:Show()
    self:UpdateConsole()
end

-- Konsole verstecken
function DreamHouse.Debug:Hide()
    if self.console then
        self.console:Hide()
    end
end

-- Log-Buffer holen
function DreamHouse.Debug:GetLogBuffer()
    return logBuffer
end

-- Alles als String exportieren (für Kopieren)
function DreamHouse.Debug:ExportAsString()
    local L = GetL()
    local lines = {}
    table.insert(lines, "========== " .. (L["DreamHouse Debug Log"] or "DreamHouse Debug Log") .. " ==========")
    table.insert(lines, (L["Exported"] or "Exported") .. ": " .. date("%Y-%m-%d %H:%M:%S"))
    table.insert(lines, (L["Entries"] or "Entries") .. ": " .. #logBuffer)
    table.insert(lines, "")
    
    for _, entry in ipairs(logBuffer) do
        table.insert(lines, string.format("[%s] [%s] [%s] %s", 
            entry.timestamp, entry.level, entry.category, entry.message))
    end
    
    table.insert(lines, "")
    table.insert(lines, "========== Ende ==========")
    
    return table.concat(lines, "\n")
end

-- In einem Popup-Fenster anzeigen zum einfachen Kopieren
function DreamHouse.Debug:ShowExportPopup()
    local exportText = self:ExportAsString()
    
    -- Einfaches Popup mit kopierbarem Text
    if not self.exportPopup then
        local popup = CreateFrame("Frame", "DreamHouseExportPopup", UIParent, "BackdropTemplate")
        popup:SetSize(500, 400)
        popup:SetPoint("CENTER")
        popup:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        popup:SetBackdropColor(0.1, 0.1, 0.1, 1)
        popup:SetFrameStrata("FULLSCREEN_DIALOG")
        popup:SetFrameLevel(200)
        popup:EnableMouse(true)
        
        local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        local L = GetL()
        title:SetText(L["Debug Log Export"] or "Debug Log Export - Ctrl+A, Ctrl+C to copy")
        
        local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -2, -2)
        
        local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 10, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
        
        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(GameFontHighlight)
        editBox:SetWidth(440)
        editBox:SetAutoFocus(true)
        scrollFrame:SetScrollChild(editBox)
        
        popup.editBox = editBox
        self.exportPopup = popup
    end
    
    self.exportPopup.editBox:SetText(exportText)
    self.exportPopup.editBox:HighlightText() -- Direkt alles auswählen
    self.exportPopup:Show()
end
