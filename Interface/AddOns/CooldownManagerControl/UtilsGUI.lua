local addonName, addonTable = ...
local addon                 = addonTable.Core

local aceGUI                = LibStub("AceGUI-3.0")
local aceConfigDialog       = LibStub("AceConfigDialog-3.0")

addonTable.GUI              = nil

function addon:CreateScrollFrame(optionFrame)
    local container = aceGUI:Create("DF_ScrollFrame")
    container:SetLayout("Fill")
    container.frame:SetParent(optionFrame)
    container.frame:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 210, -68)
    container.frame:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -5, 8)
    container.content:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 210, -68)
    container.content:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -15, 8)
    container.frame:SetClipsChildren(true)
    container.frame:Show()
    return container
end

function addon:ClearOptionFrame(optionFrame)
    optionFrame.container:ReleaseChildren()
end

function addon:CreateBasePanel(name, firstHeader)
    if addonTable.GUI then return addonTable.GUI end

    -- Create the main GUI frame
    addonTable.GUI = CreateFrame("Frame", addonName .. "GUI", UIParent, "DefaultPanelFlatTemplate")
    addonTable.GUI.container = addon:CreateScrollFrame(addonTable.GUI)
    addonTable.GUI:Hide()

    -- Set frame properties
    addonTable.GUI:SetFrameStrata("MEDIUM")
    addonTable.GUI:SetToplevel(true)
    addonTable.GUI:SetSize(900, 700)
    addonTable.GUI:SetPoint("CENTER", UIParent, "CENTER", 700, 0)
    addonTable.GUI:SetMovable(true)
    addonTable.GUI:EnableMouse(true)
    addonTable.GUI:SetClampedToScreen(true)
    addonTable.GUI:RegisterForDrag("LeftButton")

    -- Title bar
    local text = addonTable.GUI.TitleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetPoint("TOPRIGHT", 0, 0)
    text:SetJustifyH("CENTER")
    text:SetHeight(20)
    text:SetText(name)

    -- Dragging functionality
    addonTable.GUI.TitleContainer:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            addonTable.GUI:StartMoving()
            addonTable.GUI:SetAlpha(0.5)
        end
    end)
    addonTable.GUI.TitleContainer:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            addonTable.GUI:StopMovingOrSizing()
            addonTable.GUI:SetAlpha(1)
        end
    end)

    -- Close button functionality
    addonTable.GUI.CloseButton = CreateFrame("Button", nil, addonTable.GUI, "UIPanelCloseButtonDefaultAnchors")

    -- Reload UI button
    addonTable.GUI.ReloadButton = CreateFrame("Button", nil, addonTable.GUI.TitleContainer)
    addonTable.GUI.ReloadButton:SetSize(22, 22)
    addonTable.GUI.ReloadButton:SetNormalAtlas("UI-RefreshButton")
    addonTable.GUI.ReloadButton:SetHighlightAtlas("128-RedButton-Refresh-Highlight")
    addonTable.GUI.ReloadButton:SetPoint('TOPRIGHT', addonTable.GUI.TitleContainer, "TOPLEFT", 0, -0)
    addonTable.GUI.ReloadButton:SetScript("OnClick", ReloadUI)

    -- Background textures
    addonTable.GUI.BgTexture = addonTable.GUI:CreateTexture(nil, "BACKGROUND")
    addonTable.GUI.BgTexture:SetPoint('TOPLEFT', addonTable.GUI, 5, -22)
    addonTable.GUI.BgTexture:SetPoint('BOTTOMRIGHT', addonTable.GUI, -2, 2)
    addonTable.GUI.BgTexture:SetAtlas("Options_InnerFrame")

    -- Left Panel Header
    addonTable.GUI.CategoryHeader = addonTable.GUI:CreateTexture(nil, "BACKGROUND")
    addonTable.GUI.CategoryHeader:SetPoint('TOPLEFT', addonTable.GUI.BgTexture, 1, -0)
    addonTable.GUI.CategoryHeader:SetPoint('BOTTOMRIGHT', addonTable.GUI.BgTexture, -691, 500)
    addonTable.GUI.CategoryHeader:SetAtlas("Options_CategoryHeader_2")

    local Header_txt = addonTable.GUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    Header_txt:SetPoint("TOPLEFT", addonTable.GUI.CategoryHeader, 15, -9)
    Header_txt:SetPoint("TOPRIGHT", addonTable.GUI.CategoryHeader, 0, -9)
    Header_txt:SetJustifyH("LEFT")
    Header_txt:SetHeight(20)
    Header_txt:SetText(firstHeader or "Options")

    --print(addonTable.GUI.CategoryHeader:GetWidth(), addonTable.GUI.CategoryHeader:GetHeight())

    -- Main Panel Header
    addonTable.GUI.CurrentHeader = addonTable.GUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    addonTable.GUI.CurrentHeader:SetPoint("BOTTOMLEFT", addonTable.GUI.container.frame, "TOPLEFT", 15, 8)
    addonTable.GUI.CurrentHeader:SetPoint("BOTTOMRIGHT", addonTable.GUI.container.frame, "TOPRIGHT", 0, 8)
    addonTable.GUI.CurrentHeader:SetJustifyH("LEFT")
    addonTable.GUI.CurrentHeader:SetText("")

    addonTable.GUI.CurrentHeaderTexture = addonTable.GUI:CreateTexture(nil, "BACKGROUND")
    addonTable.GUI.CurrentHeaderTexture:SetPoint("BOTTOMLEFT", addonTable.GUI.container.frame, "TOPLEFT", 15, 5)
    addonTable.GUI.CurrentHeaderTexture:SetPoint("BOTTOMRIGHT", addonTable.GUI.container.frame, "TOPRIGHT", -15, 5)
    addonTable.GUI.CurrentHeaderTexture:SetAtlas("Options_HorizontalDivider")
    addonTable.GUI.CurrentHeaderTexture:SetHeight(1)

    -- Create Tabs
    addonTable.GUI.layout = {}
    addonTable.GUI.tabs = {}
    addonTable.GUI.headers = {}

    -- Show/Hide
    addonTable.GUI:SetScript("OnHide", function()
        addon:ClearOptionFrame(addonTable.GUI)
    end)

    addonTable.GUI:SetScript("OnShow", function()
        -- Clear
        addon:ClearOptionFrame(addonTable.GUI)
        for _, tab in ipairs(addonTable.GUI.tabs) do
            tab:ClearNormalTexture()
        end

        -- Reset Header
        addonTable.GUI.CurrentHeader:SetText("Select an Option Category")
        addonTable.GUI.activeTab = nil
    end)
end

local function InsertLayoutFrame(position, frame, kind, offset)
    local layout = addonTable.GUI.layout
    table.insert(layout, position, { frame = frame, kind = kind })

    frame:ClearAllPoints()

    -- Anchor this element
    if position == 1 then
        frame:SetPoint("TOP", addonTable.GUI.CategoryHeader, "BOTTOM", 0, 137)
    else
        local prev = layout[position - 1]
        if prev.kind == "header" then
            offset = offset - 137
        end

        if kind == "header" then
            frame:SetPoint("TOP", prev.frame, "BOTTOM", 0, -offset)
        else
            frame:SetPoint("TOP", prev.frame, "BOTTOM", 0, -offset)
        end
    end
end

function addon:CreateTab(position, optionTableName, tabName, headerText, refreshFunc)
    local tabs = addonTable.GUI.tabs

    local tab = CreateFrame("Button", nil, addonTable.GUI)
    tab:SetSize(195, 22)
    tab:SetHighlightAtlas("Options_List_Hover")
    tab:SetPushedAtlas("Options_List_Active")

    -- Text
    local tabTxt = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tabTxt:SetText(tabName)
    tabTxt:SetPoint("LEFT", 30, 0)
    tabTxt:SetJustifyH("LEFT")
    tabTxt:SetTextColor(1, 0.8, 0)

    tab:SetScript("OnClick", function()
        addon:ClearOptionFrame(addonTable.GUI)
        for _, entry in ipairs(tabs) do
            entry:ClearNormalTexture()
        end

        if refreshFunc then
            refreshFunc()
        end

        tab:SetNormalAtlas("Options_List_Active")
        aceConfigDialog:Open(optionTableName, addonTable.GUI.container)
        addonTable.GUI.CurrentHeader:SetText(headerText or tabName)
        addonTable.GUI.activeTab = optionTableName
    end)

    -- Insert into layout and tabs
    InsertLayoutFrame(position, tab, "tab", 0)
    table.insert(tabs, tab)
end

function addon:CreateSubHeader(position, text)
    local headers = addonTable.GUI.headers

    local header = addonTable.GUI:CreateTexture(nil, "BACKGROUND")
    header:SetAtlas("Options_CategoryHeader_2")
    header:SetSize(201, 176)

    local headerTxt = addonTable.GUI:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    headerTxt:SetPoint("TOPLEFT", header, 15, -9)
    headerTxt:SetJustifyH("LEFT")
    headerTxt:SetHeight(20)
    headerTxt:SetText(text or "Options")

    InsertLayoutFrame(position, header, "header", 0)
    table.insert(headers, header)
end
