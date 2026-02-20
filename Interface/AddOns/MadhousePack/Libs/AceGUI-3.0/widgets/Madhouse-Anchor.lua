local AceGUI = LibStub("AceGUI-3.0")

-- Lua APIs
local pairs, assert, type = pairs, assert, type

-- WoW APIs
local PlaySound = PlaySound
local CreateFrame, UIParent = CreateFrame, UIParent


do
	local Type = "Anchor"
	local Version = 1

	local function frameOnShow(this)
		this.obj:Fire("OnShow")
	end

	local function frameOnClose(this)
		this.obj:Fire("OnClose")
	end

    local function titleOnMouseDown(this,self)
	    if self.EditMode then
	        this:GetParent():StartMoving()
        end
		AceGUI:ClearFocus()
	end

	local function frameOnMouseUp(this)
		local frame = this:GetParent()
		frame:StopMovingOrSizing()
		local self = frame.obj
		local status = self.status or self.localstatus
		status.width = frame:GetWidth()
		status.height = frame:GetHeight()
		status.top = frame:GetTop()
		status.left = frame:GetLeft()
	end

	local function SetTitle(self,title)
		self.titletext:SetText(title)
	end

	local function SetStatusText(self,text)
		-- self.statustext:SetText(text)
	end

	local function Hide(self)
		self.frame:Hide()
	end

	local function Show(self)
		self.frame:Show()
	end

	local function OnAcquire(self)
		self.frame:SetParent(UIParent)
		self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
		self:ApplyStatus()
 		self:Show()
	end

	local function OnRelease(self)
		self.status = nil
		for k in pairs(self.localstatus) do
			self.localstatus[k] = nil
		end
	end

	-- called to set an external table to store status in
	local function SetStatusTable(self, status)
		assert(type(status) == "table")
		self.status = status
		self:ApplyStatus()
	end

	local function ApplyStatus(self)
		local status = self.status or self.localstatus
		local frame = self.frame
		self:SetWidth(status.width or 700)
		self:SetHeight(status.height or 500)
		if status.top and status.left then
			frame:SetPoint("TOP",UIParent,"BOTTOM",0,status.top)
			frame:SetPoint("LEFT",UIParent,"LEFT",status.left,0)
		else
			frame:SetPoint("CENTER",UIParent,"CENTER")
		end
	end

	local function OnWidthSet(self, width)
		local content = self.content
		local contentwidth = width - 34
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth
	end


	local function OnHeightSet(self, height)
		local content = self.content
		local contentheight = height - 57
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
	end


    local function SetEditMode(self, editMode)
        self.EditMode = editMode
        if editMode then
            -- Enable dragging
            self.titlebg:SetVertexColor(0, 0, 0, .75)
            self.titletext:Show()
            self.title:EnableMouse(true)
        else
            -- Disable dragging
            self.titlebg:SetVertexColor(0, 0, 0, 0)
            self.titletext:Hide()
            self.title:EnableMouse(false)
        end
    end

    local function ToggleEditMode(self)
        SetEditMode(self, not self.EditMode)
    end

    local function Constructor(props)
        local frame
		if props and props.name then
            -- print("contructor props AnchorX", props.name)
            frame = CreateFrame("Frame", props.name, UIParent)
        else
            frame = CreateFrame("Frame", nil, UIParent)
        end
		local self = {}
		self.type = "Anchor"

		self.Hide = Hide
		self.Show = Show
		self.SetTitle =  SetTitle
		self.OnRelease = OnRelease
		self.OnAcquire = OnAcquire
		self.SetStatusText = SetStatusText
		self.SetStatusTable = SetStatusTable
		self.ApplyStatus = ApplyStatus
		self.OnWidthSet = OnWidthSet
		self.OnHeightSet = OnHeightSet
        self.SetEditMode = SetEditMode
        self.ToggleEditMode = ToggleEditMode
        self.EditMode = false

		self.localstatus = {}

		self.frame = frame
		frame.obj = self
		frame:SetWidth(300)
		frame:SetHeight(200)
		frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
--[[		frame:EnableMouse()]]
		frame:SetMovable(true)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")

		frame:SetScript("OnShow",frameOnShow)
		frame:SetScript("OnHide",frameOnClose)
		if frame.SetResizeBounds then -- WoW 10.0
			frame:SetResizeBounds(240,240)
		else
			frame:SetMinResize(300,200)
		end
		frame:SetToplevel(true)

		local titlebg = frame:CreateTexture(nil, "BACKGROUND")
		titlebg:SetTexture(251966) -- Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background
		titlebg:SetPoint("TOPLEFT", 9, -6)
        titlebg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -6, -24)
		self.titlebg = titlebg

		local title = CreateFrame("Button", nil, frame)
		title:SetPoint("TOPLEFT", titlebg)
		title:SetPoint("BOTTOMRIGHT", titlebg)
		title:EnableMouse(false)
		title:SetScript("OnMouseDown",function (this)titleOnMouseDown(this,self)end)
		title:SetScript("OnMouseUp", frameOnMouseUp)
		self.title = title

		local titletext = frame:CreateFontString(nil, "ARTWORK")
		titletext:SetFontObject(GameFontNormal)
		titletext:SetPoint("TOPLEFT", 12, -8)
		titletext:SetPoint("TOPRIGHT", -32, -8)
        self.titletext = titletext

		--Container Support
		local content = CreateFrame("Frame",nil,frame)
		self.content = content
		content.obj = self
		content:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-32)
		content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-12,13)

        SetEditMode(self, false)
		AceGUI:RegisterAsContainer(self)
		return self
	end

	AceGUI:RegisterWidgetType(Type,Constructor,Version)
end
