local ringTexture = Madhouse.API.v1.AddonFolder('Textures\\Ring.tga')

local cursorFrame,tex

local function SetColorOldManCursor(r,g,b)
    if cursorFrame and tex then
        tex:SetVertexColor(r, g, b)
    end
end

local function HideOldManCursor()
    if cursorFrame then
        cursorFrame:Hide()
    end
end

local function ShowOldManCursor()
    if cursorFrame then
        cursorFrame:Show()
    else
        -- Create overlay frame
        cursorFrame = CreateFrame("Frame", nil, UIParent)
        cursorFrame:SetFrameStrata("TOOLTIP")     -- Above most UI elements
        cursorFrame:SetSize(32, 32)

        tex = cursorFrame:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture(ringTexture)
        tex:SetBlendMode("BLEND") -- ADD option for semi transparency for white glow effect
        local _, englishClass = UnitClass("player");

        local rPerc, gPerc, bPerc  = GetClassColor(englishClass)
        print(rPerc, gPerc, bPerc)
        tex:SetVertexColor(rPerc, gPerc, bPerc)

        -- Update position each frame
        cursorFrame:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            cursorFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
        end)
    end
end


-- /run Madhouse.feature.OldManCursor.show()

-- Madhouse.feature.OldManCursor
Madhouse.feature.OldManCursor = {
    show = ShowOldManCursor,
    hide = HideOldManCursor,
    setColor = SetColorOldManCursor
}

