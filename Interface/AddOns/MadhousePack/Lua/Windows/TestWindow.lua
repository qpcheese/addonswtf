-- Methods
local function Render(self,event)


end

local function InitWindow(self)
    -- Create frame
    self.Frame = AceGUI:Create("Anchor", { name = "MHAnchor04" })
    self:Setup()
    self.Frame:SetTitle("Anchor04")
    self.Frame:SetWidth(300)
    self.Frame:SetHeight(100)
end

M_Register_Window({
    widget = "TestWindow",
    short = "test",
    init = InitWindow,
    render = Render,
    info = {
        title = "Achivements",
        icon = 4279397,
        short = "Achivement"
    }
})
