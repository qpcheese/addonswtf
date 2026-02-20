
-- Variables

local RowWidth = 336
local WindowHeight = 190

-- Functions

local WindowList = {
    [1] = "CharStatWindow",
    [2] = "UpgradeWindow",
    [3] = "CurrencyWindow",
    [4] = "FarmingWindow",
    [5] = "AchivementWindow",
    [6] = "SettingsWindow"
}

local function Render(self, event)

    local iconGroup = AceGUI:Create("SimpleGroup")
    iconGroup:SetLayout("Flow")
    iconGroup:SetWidth(RowWidth)
    self.Frame:AddChild(iconGroup)

    for _, elementKey in ipairs(WindowList) do
        local element = Madhouse.widgets[elementKey].Info
        local itemIcon = AceGUI:Create("Icon")
        itemIcon:SetImage(element.icon)
        itemIcon:SetImageSize(64, 64)
        if element.short ~= nil then
            itemIcon:SetLabel(element.short)
        end
        itemIcon:SetWidth(64)
        itemIcon:SetHeight(64)
        itemIcon:SetCallback("OnEnter", function() GameTooltip:SetOwner(itemIcon.frame, "ANCHOR_CURSOR") GameTooltip:SetText(element.title) GameTooltip:Show() end)
        itemIcon:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        itemIcon:SetCallback("OnClick", function() Madhouse.widgets[elementKey]:Togle() end)
        iconGroup:AddChild(itemIcon)
        local spacer = AceGUI:Create("Label")
        spacer:SetText(" ")
        spacer:SetWidth(4)
        iconGroup:AddChild(spacer)
    end
 end


local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title)
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth(RowWidth + 30)
    self.Frame:SetHeight(WindowHeight)
    -- Register Events
end

M_Register_Window({
    widget = "WindowManager",
    short = "manager",
    init = InitWindow,
    render = Render,
    info = {
       title = isGerman and "Fenster Übersicht" or "Window Overview",
       icon = nil,
       short = nil
    }
})
