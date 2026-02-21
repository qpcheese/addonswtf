-- Variables
local RowWidth = 90
local WindowHeight = 300
local iconSize = 12

local function addTooltip(l, fi)
    local txt = "|T" ..
    fi.iconFileID ..
    ":" .. iconSize .. ":" .. iconSize .. "|t " .. Madhouse.API.v1.ColorPrintRGB(fi.name, "FFFFFF") .. '\n\n'
    txt = txt .. (isGerman and "Gesammt: " or "Total: ") .. fi.quantity .. '\n'

    if fi.maxQuantity ~= 0 then
        txt = txt .. (isGerman and "Maximum: " or "Max: ") .. fi.maxQuantity .. '\n'
    end
    if fi.trackedQuantity ~= 0 then
        txt = txt .. (isGerman and "Insgesammt Gesammelt: " or "Collected in Total: ") .. fi.trackedQuantity .. '\n'
    end
    txt = txt .. '\n' .. Madhouse.API.v1.BreakLongTooltipText(fi.description)

    l:SetCallback("OnEnter",
        function()
            GameTooltip:SetOwner(l.frame, "ANCHOR_CURSOR")
            GameTooltip:SetText(txt)
            GameTooltip:Show()
        end)
    l:SetCallback("OnLeave", function() GameTooltip:Hide() end)
end

local elements = {
    { name = "Midnight: Pre Event",               cur = { 3319 } },
    { name = "Season 3",                         cur = { 3028, 3008, 3284, 3286, 3288, 3290 } },
    { name = "TWW",                              cur = { 2815, 3056, 2803, 3090, 3226, 3149 } },
    { name = "PvP",                              cur = { 1792, 1602, 2123 } },
    { name = (isGerman and "Andere" or "Other"), cur = { 2032, 1166, 3309 } },
}

local function Render(self, event)


    local currency_data = {}
    for _, cat in pairs(elements) do
        local header = AceGUI:Create("Heading")
        header:SetFullWidth(true)
        header:SetText(cat.name)
        self.Frame:AddChild(header)
        local group = AceGUI:Create("SimpleGroup")
        group:SetLayout("Flow")
        group:SetFullWidth(true)

        for _, e in pairs(cat.cur) do
            local fi = C_CurrencyInfo.GetCurrencyInfo(e)
            if fi == nil then
                local label = AceGUI:Create("Label")
                label:SetText((isGerman and "Fehlt" or "Missing"))
                label:SetFontObject(GameFontNormal)  -- Use a larger font
                group:AddChild(label)
            else
                currency_data[e] = fi.quantity
                local label = AceGUI:Create("InteractiveLabel")
                label:SetText("|T" ..
                fi.iconFileID ..
                ":" .. iconSize .. ":" .. iconSize .. "|t " .. Madhouse.API.v1.FormatBigNumber(fi.quantity))
                label:SetFontObject(GameFontNormalLarge)
                --[[          label:SetHeight(iconSize + 4)]]
                label:SetWidth(RowWidth)
                addTooltip(label, fi)
                group:AddChild(label)
            end
        end
        self.Frame:AddChild(group)
    end
    Madhouse.addon:SaveUserData('currency_data', currency_data)
end


local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self:Setup()
    self.Frame:SetTitle(self.Info.title)
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetWidth((RowWidth * 3) + 30)
    self.Frame:SetHeight(WindowHeight)
    -- Register Events
    self.Frame.frame:SetScript("OnEvent", function(event)
        self:FlashFrame()
        self:Render()
    end)
    self.Frame.frame:RegisterEvent('BAG_UPDATE')
    self.Frame.frame:RegisterEvent('TRADE_CURRENCY_CHANGED')
    self.Frame.frame:RegisterEvent('TRADE_PLAYER_ITEM_CHANGED')
    self.Frame.frame:RegisterEvent('ARTIFACT_UPDATE')
    self.Frame.frame:RegisterEvent('ARTIFACT_XP_UPDATE')
    self.Frame.frame:RegisterEvent('PLAYER_TRADE_CURRENCY')
    self.Frame.frame:RegisterEvent('CHAT_MSG_CURRENCY')
    self.Frame.frame:RegisterEvent('SHIPMENT_CRAFTER_REAGENT_UPDATE')
    self.Frame.frame:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
    self.Frame.frame:RegisterEvent('PLAYER_MONEY')
    self.Frame.frame:RegisterEvent('PLAYER_TRADE_MONEY')
    self.Frame.frame:RegisterEvent('TRADE_MONEY_CHANGED')
    self.Frame.frame:RegisterEvent('SEND_MAIL_MONEY_CHANGED')
    self.Frame.frame:RegisterEvent('SEND_MAIL_COD_CHANGED')
    self.Frame.frame:RegisterEvent('TRIAL_STATUS_UPDATE')
end


M_Register_Window({
    widget = "CurrencyWindow",
    short = "currency",
    init = InitWindow,
    render = Render,
    info = {
        title = isGerman and "Währungs Fenster" or "Currency Window",
        icon = 4696085,
        short = "Currency"
    }
})
