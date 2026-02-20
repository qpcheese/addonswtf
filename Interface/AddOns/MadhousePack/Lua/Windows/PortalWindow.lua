local portals = {
    [1] = 354465,
    [2] = 367416,
    [3] = 445414,
    [4] = 445417,
    [5] = 445444,
    [6] = 1216786,
    [7] = 1237215,
    [8] = 1239155,
}

-- Methods
local function Render(self)




    -- Set position
    if C_AddOns.IsAddOnLoaded("RaiderIO") then -- RAIDER IO
        self.Frame:SetPoint("LEFT", "RaiderIO_ProfileTooltip", "TOPRIGHT", 0, -70)
    else -- PVE Frame
        self.Frame:SetPoint("LEFT", PVEFrame, "TOPRIGHT", 10, -70)
    end

    for _, value in ipairs(portals) do
        local button = AceGUI:Create("IconButton")
        button:SetSpell(value)
        button:SetSize(36)

        self.Frame:AddChild(button)
    end
end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("WindowX")
    self.Frame:Hide()
    self.Frame:SetTitle(isGerman and "Portale" or "Portals")
    self:Setup()
    self.Frame:SetLayout("Flow")
    self.Frame:EnableResize(false)
    self.Frame:SetHeight(140)
    self.Frame:SetWidth(175)

    self.Frame.frame:SetMovable(false)
    self.Frame.frame:SetResizable(false)
    self.Frame.closebutton:SetScript("OnClick",function () self:Hide()end)
    self.Frame.title:SetScript("OnMouseDown",function () end)
    self.Frame.title:SetScript("OnMouseUp", function () end)

    PVEFrame:HookScript("OnShow", function()
        if Madhouse.addon:LoadGlobalData("settings-portal-show",true) then
            self:Show()
        end
    end)
    PVEFrame:HookScript("OnHide", function()
         self:Hide()
    end)

end

M_Register_Window({
    widget = "PortalWindow",
    short = "portal",
    init = InitWindow,
    render = Render,
    info = nil
})
