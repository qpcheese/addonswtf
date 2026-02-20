-- Variables

local RowWidth = 450
local WindowHeight = 310
local checkBoxOptionGeneral = {
    [1] = {
        key = "settings-auto-queue",
        label = isGerman and "Automatische Anmeldung" or "Auto Queue",
        tooltip = isGerman and "Automatische bestätigung der Rollenabfrage während ihr in einer Gruppe seid." or
            "Auto accept the role check while you are in a group.",
        default = false,
        fc = nil
    },
    [2] = {
        key = "settings-auto-ready-check",
        label = isGerman and "Allzeit Bereit" or "Always Ready",
        tooltip = isGerman and "Bestätige automatisch den Bereitschaftscheck" or "Automatically confirm the ready check",
        default = false,
        fc = nil
    },
    [3] = {
        key = "settings-portal-show",
        label = isGerman and "Portal Fenster anzeigen" or "Show Portal Window",
        tooltip = isGerman and "Zeigt das Portalfenster für die Season neben dem PvE Fenster an" or
            "Show the portal window for the season next to the PvE window",
        default = true,
        fc = nil
    },
    [4] = {
        key = "settings-social-points",
        label = isGerman and "Madhouse Wertung" or "Madhouse Score",
        tooltip = isGerman and "Aktiviere die Madhouse Wertung für M+" or "Enable the Madhouse Score for M+",
        default = false,
        fc = nil
    },
    [5] = {
        key = "settings-oldman-cursor",
        label = isGerman and "Altherren Cursor" or "Oldman Cursor",
        tooltip = isGerman and "Aktiviere den Altherren cursor" or "Enable the Oldman Cursor",
        default = false,
        fc = function(val) if val then Madhouse.feature.OldManCursor.show() else Madhouse.feature.OldManCursor.hide() end end
    },
}
local checkBoxOptionAlert = {
    [1] = {
        key = "bloodlost-alert",
        label = isGerman and "Blutrausch Alarm" or "Bloodlust Alert",
        tooltip = isGerman and "Zeige einen Alarm für den Blutrausch an. Dieser ist von der Fraktion abhänig." or
            "Show an alert for the bloodlust. This is faction dependent.",
        default = false,
        fc = nil
    },
    [2] = {
        key = "level-up-alert",
        label = isGerman and "Level Up Alarm" or "Level Up Alert",
        tooltip = isGerman and "Zeige einen Alarm für einen Level UP." or "Show an alert for a level up.",
        default = false,
        fc = nil
    },
    [3] = {
        key = "encounter-end-alert",
        label = isGerman and "Boss Alarm" or "Boss Alert",
        tooltip = isGerman and "Zeige eine Katze nachdem ein Boss besiegt wurde" or "Show a cat after a boss is defeated",
        default = false,
        fc = nil
    },
}


function RenderCheckbox(target, checkBoxOption)
    for _, value in ipairs(checkBoxOption) do
        local checkOption = AceGUI:Create("CheckBox")
        checkOption:SetLabel(value.label)
        checkOption:SetValue(Madhouse.addon:LoadGlobalData(value.key, value.default))
        checkOption:SetCallback("OnValueChanged", function(_, _, val)
            Madhouse.addon:SaveGlobalData(value.key, val)
            if value.fc ~= nil then
                value.fc(val)
            end
        end)
        checkOption:SetCallback("OnEnter",
            function()
                GameTooltip:SetOwner(checkOption.frame, "ANCHOR_CURSOR")
                GameTooltip:SetText(value.tooltip)
                GameTooltip:Show()
            end)
        checkOption:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        target:AddChild(checkOption)
    end
end

-- Methods

local function Render(self, event)

    local tabGroup = AceGUI:Create("TabGroup")
    tabGroup:SetLayout("Flow") -- Use 'Flow' to allow widgets inside the tab
    local tabs = {
        [1] = { text = isGerman and "Info" or "About", value = "about" },
        [2] = { text = isGerman and "Allgemein" or "General", value = "general" },
        [3] = { text = isGerman and "Alarm" or "Alert", value = "alert" },
    }
    tabGroup:SetTabs(tabs)

    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        container:ReleaseChildren()
        if group == "about" then
            local hGroup = AceGUI:Create("SimpleGroup")
            hGroup:SetLayout("Flow")
            hGroup:SetWidth(RowWidth + 25)

            local image = AceGUI:Create("Label")
            image:SetImage(Madhouse.API.v1.AddonFolder("Textures\\Logo.tga"))
            image:SetImageSize(80, 80)
            hGroup:AddChild(image)


            local Header = AceGUI:Create("Label")
            Header:SetText("The Madhouse Pack")
            Header:SetFontObject(GameFontHighlightLarge)
            hGroup:AddChild(Header)

            container:AddChild(hGroup)

            local divider = AceGUI:Create("Heading")
            divider:SetFullWidth(true)

            container:AddChild(divider)

            local waGroup = AceGUI:Create("SimpleGroup")
            waGroup:SetLayout("Flow")
            waGroup:SetWidth(RowWidth + 25)
            container:AddChild(waGroup)

            local waText = AceGUI:Create("Label")
            waText:SetText(isGerman and "Bereit für Midnight" or "Ready for Midnight")
            waText:SetFontObject(GameFontHighlightLarge) -- Use a larger font
            waText:SetFullWidth(true)
            waGroup:AddChild(waText)

            local group = AceGUI:Create("InlineGroup")
            group:SetWidth(RowWidth)
            container:AddChild(group)

            local largeText2 = AceGUI:Create("Label")
            largeText2:SetText("Version: " .. AddonVersion)
            largeText2:SetFontObject(GameFontHighlightLarge) -- Use a larger font
            largeText2:SetFullWidth(true)
            largeText2:SetColor(1, 0, 0)
            group:AddChild(largeText2)

            local largeText = AceGUI:Create("Label")
            largeText:SetText("Addon created by\n" ..
                Madhouse.API.v1.ColorPrintRGB("Elschnagoo [Astrastar-Blackhand-EU]", "FF7C0A"))
            largeText:SetFontObject(GameFontHighlightLarge) -- Use a larger font
            largeText:SetFullWidth(true)
            group:AddChild(largeText)
        elseif group == "general" then
            local h01 = AceGUI:Create("Heading")
            h01:SetFullWidth(true)
            h01:SetText(isGerman and "Funktionen" or "Features")
            container:AddChild(h01)
            RenderCheckbox(container, checkBoxOptionGeneral)

            local h02 = AceGUI:Create("Heading")
            h02:SetFullWidth(true)
            h02:SetText(isGerman and "Anpassungen" or "Adjustments")
            container:AddChild(h02)

            local buttonGroup = AceGUI:Create("SimpleGroup")
            buttonGroup:SetLayout("Flow")
            buttonGroup:SetWidth(RowWidth)
            container:AddChild(buttonGroup)

            local SyncButton = AceGUI:Create("Button")
            SyncButton:SetText(isGerman and "Wertung Syncronisieren" or "Syncronize Score")
            SyncButton:SetCallback("OnClick", function()
                Madhouse.widgets.RatingWindow:syncAllData()
            end)
            buttonGroup:AddChild(SyncButton)

            local AnchorButton = AceGUI:Create("Button")
            AnchorButton:SetText(isGerman and "Ankerpunkte umschalten" or "Toggle Anchor Points")
            AnchorButton:SetCallback("OnClick", function()
                for _, anchor in pairs(Madhouse.anchor) do
                    anchor:ToggleEditMode()
                end
            end)
            buttonGroup:AddChild(AnchorButton)
        elseif group == "alert" then
            local h01 = AceGUI:Create("Heading")
            h01:SetFullWidth(true)
            h01:SetText(isGerman and "Alarm Ein und Auschalten" or "Alert On and Off")
            container:AddChild(h01)
            RenderCheckbox(container, checkBoxOptionAlert)

            local h02 = AceGUI:Create("Heading")
            h02:SetFullWidth(true)
            h02:SetText(isGerman and "Alarm Optionen" or "Alert Options")
            container:AddChild(h02)

            local dropdown = AceGUI:Create("Dropdown")
            dropdown:SetLabel(isGerman and "Blutrausch Typ" or "Bloodlost Type")
            dropdown:SetList({
                ["faction"] = isGerman and "Nach Fraktion" or "By Faction",
                ["horde"] = "Horde",
                ["alliance"] = isGerman and "Allianz" or "Allience"
            })
            dropdown:SetValue(Madhouse.addon:LoadGlobalData("settings-bloodlost-mode", "faction"))
            dropdown:SetCallback("OnValueChanged", function(_, _, key)
                Madhouse.addon:SaveGlobalData("settings-bloodlost-mode", key)
            end)
            container:AddChild(dropdown)

            local buttonGroup = AceGUI:Create("SimpleGroup")
            buttonGroup:SetLayout("Flow")
            buttonGroup:SetWidth(RowWidth)
            container:AddChild(buttonGroup)

            local TestButton = AceGUI:Create("Button")
            TestButton:SetText(isGerman and "Test: Blutrausch" or "Test: Bloodlust")
            TestButton:SetCallback("OnClick", function()
                Madhouse.trigger.Bloodlust()
            end)
            buttonGroup:AddChild(TestButton)

            local TestButton2 = AceGUI:Create("Button")
            TestButton2:SetText(isGerman and "Test: Level Up" or "Test: Level Up")
            TestButton2:SetCallback("OnClick", function()
                Madhouse.trigger.LevelUp()
            end)
            buttonGroup:AddChild(TestButton2)

            local TestButton3 = AceGUI:Create("Button")
            TestButton3:SetText(isGerman and "Test: Boss Alarm" or "Test: Boss Alert")
            TestButton3:SetCallback("OnClick", function()
                Madhouse.trigger.EncounterEnd()
            end)
            buttonGroup:AddChild(TestButton3)
        end
    end)
    tabGroup:SelectTab("about")
    self.Frame:AddChild(tabGroup)
end

local function InitWindow(self)
    -- Create frame

    self.Frame = AceGUI:Create("WindowX")
    self.Frame.frame:SetScript("OnHide", function(this)
        self:setShow(false)
    end)
    self.Frame:SetTitle("The Madhouse Pack - " .. self.Info.title)
    self.Frame:SetLayout("Fill")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth(RowWidth + 25)
    self.Frame:SetHeight(WindowHeight)
    self.Frame:OnRelease(function()
        ShowWindow = false
        self.Frame = nil
    end)
end

M_Register_Window({
    widget = "SettingsWindow",
    short = "settings",
    init = InitWindow,
    render = Render,
    info = {
        title = isGerman and "Einstellungen" or "Settings",
        icon = 134520,
        short = "Setting"
    }
})
