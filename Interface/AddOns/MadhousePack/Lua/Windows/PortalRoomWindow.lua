 local portals = {
    [1] = { icon = 3024540, map = nil , name = "Mechagon" }, -- Meachagon
    [2] = { icon = 3601550, map = 1683 , name = nil }, -- Theater
    [3] = { icon = 2011121, map = 1010 , name = nil }, -- Riesenfötz
}

-- Methods
local function Render(self)


    for _, value in ipairs(portals) do
        local button = AceGUI:Create("Icon")
        button:SetImage(value.icon)
        if value.name ~= nil then
            button:SetLabel(value.name)
        elseif value.map ~= nil then
            button:SetLabel(C_Map.GetMapInfo(value.map).name)
        else
            button:SetLabel("???")
        end
        self.Frame:AddChild(button)
     end
end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("EmptyFrame")
    self.Frame:Hide()
    self.Frame:SetLayout("Flow")
    self:Setup()
    self.Frame:SetHeight(140)
    self.Frame:SetWidth(400)

    self.Frame.frame:SetMovable(false)
    self.Frame.frame:SetResizable(false)
    self.Frame.frame:SetResizable(false)

    self.Frame.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
end

M_Register_Window({
    widget = "PortalRoomWindow",
    short = "portal-room",
    init = InitWindow,
    render = Render,
    info = nil
})
