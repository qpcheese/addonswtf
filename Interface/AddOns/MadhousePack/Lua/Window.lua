-- Window Functions
function M_Window_SetShow(self, value)
    self.ShowWindow = value
    Madhouse.addon:SaveUserData("window_" .. self.WindowName .. "_show", value)
end

function M_Window_Togle(self)
    if self.ShowWindow then
        self:Hide()
    else
        self:Show()
    end
end

function M_Window_Hide(self)
    self:setShow(false)
    if self.Frame then
        self:FlashFrame()
        self.Frame:Hide()
    end
end

function M_Window_Reload(self)
    self:FlashFrame()
    self:Render()
end

function M_Window_FlashFrame(self)
    if self.Frame then
        if self.Frame.ReleaseChildren then
            self.Frame:ReleaseChildren()
        else
            for _, child in pairs(self.Frame.children) do
                child:Release()
            end
            self.Frame.children = {}
        end
    end
end

function M_Window_Show(self)
    self:setShow(true)
    -- Create the main frame
    if not self.Frame then
        -- Create frame
        self:InitWindow()
    else
        self:FlashFrame(self)
        self.Frame:Show()
    end
    self:Render()
end

function M_Window_Render(self)
    --if not self.Frame or not self.ShowWindow then
    if not self.Frame then
        return
    end
    self:RenderFunction()
end

-- Global Functions
local function PointsChanged(self)
    self.LastPoint = self.LastPoint or { self.Frame.frame:GetPoint() }
    self.LastPoint[2] = nil

    local changed = false
    local points = { self.Frame.frame:GetPoint() } -- Get current points
    points[2] = nil

    if #points ~= #self.LastPoint then
        changed = true
    else
        for i = 1, #points do
            if points[i] ~= self.LastPoint[i] then
                changed = true
                break
            end
        end
    end
    if changed then
        self.LastPoint = points
    end
    return changed
end
function M_Window_Setup(self)
    self.Frame.frame:SetScript("OnHide", function(this)
        self:setShow(false)
    end)
    self.Frame:OnRelease(function()
        self:setShow(false)
        self.Frame = nil
    end)
    self.Frame.frame:SetFrameStrata("MEDIUM")
    local LastPoint = Madhouse.addon:LoadUserData("window_" .. self.WindowName .. "_pos")

    if LastPoint then
        self.Frame.frame:SetPoint(LastPoint[1], UIParent, LastPoint[3], LastPoint[4], LastPoint[5])
        self.LastPoint = LastPoint
    end

    self.Frame.frame:SetScript("OnUpdate", function(a, b)
        if PointsChanged(self) then
            Madhouse.addon:SaveUserData("window_" .. self.WindowName .. "_pos", self.LastPoint)
        end
    end)
end

function M_Register_Window(config)
    Madhouse.widgets[config.widget] = Madhouse.API.v1.MergeTable({
        Info = config.info,
        Frame = nil,
        InitWindow = config.init,
        RenderFunction = config.render,
        Render = M_Window_Render,
        setShow = M_Window_SetShow,
        Setup = M_Window_Setup,
        Show = M_Window_Show,
        Hide = M_Window_Hide,
        FlashFrame = M_Window_FlashFrame,
        Togle = M_Window_Togle,
        Reload = M_Window_Reload,
        ShowWindow = false,
        WindowName = config.short
    },config.extra or {})
end
