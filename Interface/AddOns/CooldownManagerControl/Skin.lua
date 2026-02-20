local addonName, addonTable = ...
local addon                 = addonTable.Core

local antAtlas              =
{
    atlasName = "VisualAlert_Ants_Flipbook",
    cols = 5,
    rows = 6,
    numFrame = 30,
    duration = 1.0,
    scale = 0.3,
    scaleMask = 0.25,
    scaleBar = 0.4,
}

-- Custom Glow Library
local LCG                   = LibStub("LibCustomGlow-1.0")

---------------------------------------------------------------------------------------
-- Helper Functions
local function maintainAspectRatio(texture, width, height)
    local aspectRatio = width / height
    local left, right, top, bottom

    if aspectRatio > 1 then
        -- The container is wider than it is tall, so we need to adjust the horizontal coordinates
        local inset = (width - height) / (2 * width)
        left, right, top, bottom = 0.05, 0.95, inset + 0.05, 1 - inset - 0.05
    elseif aspectRatio < 1 then
        -- The container is taller than it is wide, so we need to adjust the vertical coordinates
        local inset = (height - width) / (2 * height)
        left, right, top, bottom = inset + 0.05, 1 - inset - 0.05, 0.05, 0.95
    else
        -- The container is square, no adjustment needed
        left, right, top, bottom = 0.05, 0.95, 0.05, 0.95
    end

    texture:SetTexCoord(left, right, top, bottom)
end

local function findRegionByAtlas(frame, atlasName)
    for _, region in ipairs({ frame:GetRegions() }) do
        if region.GetAtlas and region:GetAtlas() == atlasName then
            return region
        end
    end
end

local function addBorder(frame, thickness, r, g, b, a, name)
    r, g, b, a = r or 1, g or 1, b or 1, a or 1

    -- Hide and return if thickness is zero or less
    if not thickness or thickness <= 0 then
        if frame.borderFrame then
            frame.borderFrame:Hide()
        end
        return
    end

    -- Create the frame that will hold the border textures if it doesn't exist
    if not frame.borderFrame then
        frame.borderFrame = CreateFrame("Frame", nil, frame)
    end
    frame.borderFrame:Show()
    local borderFrame = frame.borderFrame

    -- Ensure the border frame covers the entire frame
    borderFrame:SetAllPoints(frame)

    -- Set the correct strata and level
    local frameStrata_frame = frame:GetFrameStrata()
    local frameLevel_frame = frame:GetFrameLevel()
    local frameStrata_cooldown = frame.Cooldown and frame.Cooldown:GetFrameStrata() or nil
    local frameLevel_cooldown = frame.Cooldown and frame.Cooldown:GetFrameLevel() or nil

    if name == "essential" then
        borderFrame:SetFrameStrata(frameStrata_cooldown)
        borderFrame:SetFrameLevel(frameLevel_cooldown)
    elseif name == "buffBar" then
        borderFrame:SetFrameStrata(frameStrata_frame)
        borderFrame:SetFrameLevel(frameLevel_frame)
    elseif name == "utility" then
        borderFrame:SetFrameStrata(frameStrata_cooldown)
        borderFrame:SetFrameLevel(frameLevel_cooldown)
    elseif name == "buffIcon" then
        borderFrame:SetFrameStrata(frameStrata_cooldown)
        borderFrame:SetFrameLevel(frameLevel_cooldown)
    end

    -- Create the border textures if they don't exist
    if not borderFrame.BorderTextures then
        borderFrame.BorderTextures = {}
    end

    -- 4 lines
    local minPixels = 2
    local upwardExtendHeightPixels = thickness
    local upwardExtendHeightMinPixels = minPixels

    -- Top
    if not borderFrame.BorderTextures[1] then
        borderFrame.BorderTextures[1] = borderFrame:CreateTexture(nil, "OVERLAY")
    end
    local top = borderFrame.BorderTextures[1]
    top:SetColorTexture(r, g, b, a)
    top:ClearAllPoints()
    PixelUtil.SetHeight(top, thickness, minPixels)
    PixelUtil.SetPoint(top, "TOPLEFT", frame, "TOPLEFT", 0, 0, 0, 0)
    PixelUtil.SetPoint(top, "TOPRIGHT", frame, "TOPRIGHT", 0, 0, 0, 0)

    -- Bottom
    if not borderFrame.BorderTextures[2] then
        borderFrame.BorderTextures[2] = borderFrame:CreateTexture(nil, "OVERLAY")
    end
    local bottom = borderFrame.BorderTextures[2]
    bottom:SetColorTexture(r, g, b, a)
    bottom:ClearAllPoints()
    PixelUtil.SetHeight(bottom, thickness, minPixels)
    PixelUtil.SetPoint(bottom, "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0, 0, 0)
    PixelUtil.SetPoint(bottom, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0, 0, 0)

    -- Left
    if not borderFrame.BorderTextures[3] then
        borderFrame.BorderTextures[3] = borderFrame:CreateTexture(nil, "OVERLAY")
    end
    local left = borderFrame.BorderTextures[3]
    left:SetColorTexture(r, g, b, a)
    left:ClearAllPoints()
    PixelUtil.SetWidth(left, thickness, minPixels)
    PixelUtil.SetPoint(left, "TOPLEFT", frame, "TOPLEFT", 0, -thickness, 0, upwardExtendHeightMinPixels)
    PixelUtil.SetPoint(left, "BOTTOMLEFT", frame, "BOTTOMLEFT", 0, thickness, 0, minPixels)

    -- Right
    if not borderFrame.BorderTextures[4] then
        borderFrame.BorderTextures[4] = borderFrame:CreateTexture(nil, "OVERLAY")
    end
    local right = borderFrame.BorderTextures[4]
    right:SetColorTexture(r, g, b, a)
    right:ClearAllPoints()
    PixelUtil.SetWidth(right, thickness, minPixels)
    PixelUtil.SetPoint(right, "TOPRIGHT", frame, "TOPRIGHT", 0, -thickness, 0, upwardExtendHeightMinPixels)
    PixelUtil.SetPoint(right, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, thickness, 0, minPixels)
end

local function addBackground(frame, r, g, b, a)
    r, g, b, a = r or 0, g or 0, b or 0, a or 0.5

    if not frame.backgroundTexture then
        frame.backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
    end
    frame.backgroundTexture:SetColorTexture(r, g, b, a)
    frame.backgroundTexture:SetAllPoints(frame)
end
---------------------------------------------------------------------------------------

local barWarningShown = false
local warningShown = false

--- Updates the visual appearance of a bar frame
--- @param frame Frame  The bar frame to be styled.
--- @param override table|nil Overriden settings specific for this frame only. Nil if no override.
--- @return nil
function addon:setBarStyle(frame, override)
    -- Each frame includes an icon and a bar that need to be styled according to settings.
    local db = addon.db.profile["buffBar"].layout

    -- Extract the settings for easier access
    local scale = db.scale -- Scale is a global setting, width and height are per-bar

    -- icon settings
    local iconWidth = (override and override.overrideIcon) and override.iconWidth or db.iconWidth
    local iconHeight = (override and override.overrideIcon) and override.iconHeight or db.iconHeight
    local showIconOverlay = db.showIconOverlay
    if override and override.overrideIcon then showIconOverlay = override.showIconOverlay end
    local showIconBorder = db.showIconBorder
    if override and override.overrideIcon then showIconBorder = override.showIconBorder end
    local removeMask = db.removeMask
    if override and override.overrideIcon then removeMask = override.removeMask end
    local addPixelBorder = db.addPixelBorder
    if override and override.overrideIcon then addPixelBorder = override.addPixelBorder end
    local pixelBorderSize = (override and override.overrideIcon) and override.pixelBorderSize or db.pixelBorderSize
    local pixelBorderColor = (override and override.overrideIcon) and override.pixelBorderColor or db.pixelBorderColor
    local showDebuffBorder = db.showDebuffBorder
    if override and override.overrideIcon then debuffBorder = override.showDebuffBorder end

    -- bar settings
    local barWidth = (override and override.overrideBar) and override.barWidth or db.barWidth
    local barHeight = (override and override.overrideBar) and override.barHeight or db.barHeight
    local pipHeight = (override and override.overrideBar) and override.pipHeight or db.pipHeight
    local showPip = db.showPip
    if override and override.overrideBar then showPip = override.showPip end
    local showBackground = db.showBackground
    if override and override.overrideBar then showBackground = override.showBackground end
    local barColor = (override and override.overrideBar and override.overrideColor) and override.color or (db.barColorOverride and db.barColor or nil)
    local barTexture = (override and override.overrideBar and override.overrideTexture) and override.texture or (db.barTextureOverride and db.barTexture or nil)
    local addPixelBorderBar = db.addPixelBorderBar
    if override and override.overrideBar then addPixelBorderBar = override.addPixelBorderBar end
    local pixelBorderSizeBar = (override and override.overrideBar) and override.pixelBorderSizeBar or db.pixelBorderSizeBar
    local pixelBorderColorBar = (override and override.overrideBar) and override.pixelBorderColorBar or db.pixelBorderColorBar
    local customBackground = db.customBackground
    if override and override.overrideBar then customBackground = override.customBackground end
    local backgroundColor = (override and override.overrideBar) and override.backgroundColor or (db.backgroundColor or nil)

    -- font settings
    local nameScale = (override and override.overrideFontSizes) and override.nameScale or db.nameScale
    local cooldownScale = (override and override.overrideFontSizes) and override.cooldownScale or db.cooldownScale
    local applicationScale = (override and override.overrideFontSizes) and override.applicationScale or db.countScale
    local cooldownPosition = (override and override.overrideFontSizes) and override.barCooldownPosition or db.barCooldownPosition
    local applicationPosition = (override and override.overrideFontSizes) and override.applicationPosition or db.applicationPosition

    -- other
    local barIconSpacing = override and override.barIconSpacing or db.barIconSpacing
    local displayType = override and override.displayType or db.displayType
    local showCooldown = db.showCooldown
    if override then showCooldown = override.showCooldown end
    --[[ local showTooltip = db.showTooltip
    if override then showTooltip = override.showTooltip end ]]

    -- Quick references to frame components
    local barFrame = frame:GetBarFrame()
    local iconFrame = frame:GetIconFrame()
    local pipTexture = frame:GetPipTexture()
    local nameFontString = frame:GetNameFontString()
    local durationFontString = frame:GetDurationFontString()
    local applicationsFontString = frame:GetApplicationsFontString()

    -- Apply the settings to the frame
    frame:SetScale(scale)
    local frameWidth, frameHeight
    if displayType == Enum.CooldownViewerBarContent.NameOnly then
        frameWidth = barWidth
        frameHeight = barHeight + 4
    else
        frameWidth = iconWidth + barIconSpacing + barWidth
        frameHeight = math.max(iconHeight, barHeight + 4)
    end
    frame:SetSize(frameWidth, frameHeight)

    -- Icon
    iconFrame:SetWidth(iconWidth)
    iconFrame:SetHeight(iconHeight)
    maintainAspectRatio(frame.Icon.Icon, iconWidth, iconHeight)

    -- Shadow overlay
    local overlay = findRegionByAtlas(iconFrame, "UI-HUD-CoolDownManager-IconOverlay")
    if overlay then
        overlay:ClearAllPoints()
        overlay:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -iconWidth * 0.18, iconHeight * 0.18)
        overlay:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", iconWidth * 0.18, -iconHeight * 0.18)
        overlay:SetShown(showIconOverlay)
    end

    if showDebuffBorder and displayType ~= Enum.CooldownViewerBarContent.NameOnly then
        if frame.DebuffBorder then
            frame.DebuffBorder:ClearAllPoints()
            frame.DebuffBorder:SetPoint("TOPLEFT", frame.Icon.Icon, "TOPLEFT", -iconWidth * 0.1, iconHeight * 0.1)
            frame.DebuffBorder:SetPoint("BOTTOMRIGHT", frame.Icon.Icon, "BOTTOMRIGHT", iconWidth * 0.1, -iconHeight * 0.1)
        end
    else
        if frame.DebuffBorder then
            frame.DebuffBorder:Hide()
            addon:Unhook(frame.DebuffBorder, "Show")
            addon:SecureHook(frame.DebuffBorder, "Show", function(self)
                frame.DebuffBorder:Hide()
            end)
        end
    end

    -- Icon Mask
    if removeMask then
        local mask = frame.Icon.Icon:GetMaskTexture(1)
        if mask then
            frame.Icon.Icon:RemoveMaskTexture(mask)
        end
    else
        local mask = frame.Icon.Icon:GetMaskTexture(1)
        if not mask and not barWarningShown then
            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the mask.")
            barWarningShown = true
        end
    end

    -- Atlas based border
    local border = iconFrame.OutOfRange
    if showIconBorder == 0 then
        if border then
            border:Hide()
            --border = nil
        end
    elseif showIconBorder == 1 then
        -- the bar viewer does not provide a border by default, so we create one if needed
        if not border then
            border = iconFrame:CreateTexture(nil, "OVERLAY")
            border:SetAllPoints(iconFrame)
            border:SetAtlas("UI-CooldownManager-OORshadow")
            border:SetVertexColor(1, 1, 1, 0.5)
            iconFrame.OutOfRange = border
        end
        border:Show()
    elseif showIconBorder == 2 then
        if border then
            border:Hide()
            --border = nil
        end
    end

    -- Pixel Border
    if addPixelBorder then
        local r, g, b, a = addon:HexToRGB(pixelBorderColor)
        addBorder(iconFrame, pixelBorderSize, r, g, b, a, "buffBar")
    else
        if iconFrame.borderFrame then
            iconFrame.borderFrame:Hide()
            --iconFrame.borderFrame = nil
        end
    end

    -- Bar
    barFrame:SetWidth(barWidth)
    barFrame:SetHeight(barHeight)
    pipTexture:SetHeight(pipHeight)

    -- Pip visibility
    if not showPip then
        pipTexture:SetAlpha(0)
    else
        pipTexture:SetAlpha(1)
    end

    -- Bar Background
    local background = findRegionByAtlas(barFrame, "UI-HUD-CoolDownManager-Bar-BG")
    background:SetHeight(barHeight + 10)
    background:ClearAllPoints()
    background:SetPoint("LEFT", barFrame, "LEFT", -2, -2)
    background:SetPoint("RIGHT", barFrame, "RIGHT", 6, -2)
    background:SetShown(showBackground)

    --addon:DisplayCorners(barFrame)
    if customBackground then
        local r, g, b, a
        if backgroundColor then
            r, g, b, a = addon:HexToRGB(backgroundColor)
        else
            r, g, b, a = 0, 0, 0, 0.5
        end
        addBackground(barFrame, r, g, b, a)
    else
        if barFrame.backgroundTexture then
            barFrame.backgroundTexture:Hide()
            --barFrame.backgroundTexture = nil
        end
    end

    -- Calculate widths for name and duration
    local nameWidth = (barWidth * 3 / 4) - 2     -- name takes 75% of the bar
    local durationWidth = (barWidth * 1 / 4) - 2 -- duration takes 25% of the bar

    -- Padding between icon and bar + display type
    barFrame:ClearAllPoints()
    local point, relativeTo, relativePoint, offsetX, offsetY = "LEFT", iconFrame, "RIGHT", 0, 0;
    if displayType == Enum.CooldownViewerBarContent.NameOnly then
        iconFrame:Hide()
        nameFontString:Show();
        relativeTo = frame
        relativePoint = "LEFT"
    elseif displayType == Enum.CooldownViewerBarContent.IconOnly then
        iconFrame:Show()
        nameFontString:Hide();
        offsetX = barIconSpacing
    elseif displayType == Enum.CooldownViewerBarContent.IconAndName then
        iconFrame:Show()
        nameFontString:Show();
        offsetX = barIconSpacing
    end
    barFrame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)

    -- Hook to maintain the padding/display type
    addon:Unhook(frame, "SetBarContent")
    addon:SecureHook(frame, "SetBarContent", function(self)
        barFrame:ClearAllPoints()
        local p, r, rp, x, y = "LEFT", iconFrame, "RIGHT", 0, 0;
        if displayType == Enum.CooldownViewerBarContent.NameOnly then
            iconFrame:Hide()
            nameFontString:Show();
            r = self
            rp = "LEFT"
        elseif displayType == Enum.CooldownViewerBarContent.IconOnly then
            iconFrame:Show()
            nameFontString:Hide();
            x = barIconSpacing
        elseif displayType == Enum.CooldownViewerBarContent.IconAndName then
            iconFrame:Show()
            nameFontString:Show();
            x = barIconSpacing
        end
        barFrame:SetPoint(p, r, rp, x, y)
    end)

    -- Bar color
    if barColor then
        local r, g, b, a
        local _, englishClass = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[englishClass]

        if override and override.overrideBar and override.overrideColor and override.classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        elseif not override or not override.overrideBar or not override.overrideColor then
            if db.barColorOverride and db.classColor then
                r, g, b = classColor.r, classColor.g, classColor.b
            else
                r, g, b = addon:HexToRGB(barColor)
            end
        else
            r, g, b = addon:HexToRGB(barColor)
        end

        barFrame:SetStatusBarColor(r, g, b, 1)
    else
        barFrame:SetStatusBarColor(1, 0.5, 0.25, 1)
    end

    -- Bar texture
    if barTexture then
        barFrame:SetStatusBarTexture(barTexture)
    else
        barFrame:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    end

    -- Pixel Border
    if addPixelBorderBar then
        local r, g, b, a = addon:HexToRGB(pixelBorderColorBar)
        addBorder(barFrame, pixelBorderSizeBar, r, g, b, a, "buffBar")
    else
        if barFrame.borderFrame then
            barFrame.borderFrame:Hide()
            --barFrame.borderFrame = nil
        end
    end

    -- Fonts
    nameFontString:ClearAllPoints()
    nameFontString:SetPoint("LEFT", frame.Bar, "LEFT", 2, 0)
    nameFontString:SetJustifyH("LEFT")
    nameFontString:SetWordWrap(false)
    nameFontString:SetWidth(nameWidth)
    nameFontString:SetHeight(barFrame:GetHeight())
    nameFontString:SetFontHeight(nameScale)

    durationFontString:ClearAllPoints()
    durationFontString:SetPoint("RIGHT", frame.Bar, "RIGHT", -2, 0)
    durationFontString:SetJustifyH("RIGHT")
    durationFontString:SetWordWrap(false)
    durationFontString:SetWidth(durationWidth)
    durationFontString:SetHeight(barFrame:GetHeight())
    durationFontString:SetFontHeight(cooldownScale)

    applicationsFontString:ClearAllPoints()

    local xOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "LEFT") and 2 or
        ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "TOPRIGHT" or applicationPosition == "RIGHT") and -2 or 0)
    local yOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "TOP" or applicationPosition == "TOPRIGHT") and -2 or
        ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "BOTTOM") and 2 or 0)

    applicationsFontString:SetPoint(applicationPosition, frame.Icon, applicationPosition, xOffset, yOffset)

    --applicationsFontString:SetPoint("TOPLEFT", frame.Icon)
    --applicationsFontString:SetPoint("BOTTOMRIGHT", frame.Icon)
    applicationsFontString:SetJustifyH("CENTER")
    applicationsFontString:SetFontHeight(applicationScale)

    -- Cooldown visibility
    durationFontString:SetShown(showCooldown);
    addon:Unhook(frame, "SetTimerShown")
    addon:SecureHook(frame, "SetTimerShown", function(self)
        durationFontString:SetShown(showCooldown);
    end)

    -- Hide when inactive and desaturate when inactive are handled via hooks in another part of the addon

    --return frameWidth, frameHeight
end

--- Updates the visual appearance of an icon frame
--- @param frame        Frame  The icon frame to be styled.
--- @param override     table|nil Overriden settings specific for this frame only.
--- @param name         string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`).
--- @return nil
function addon:setIconStyle(frame, override, name)
    local db = addon.db.profile[name].layout

    -- Extract the settings for easier access
    local scale = db.scale

    -- icon settings
    local iconWidth = (override and override.overrideIcon) and override.iconWidth or db.iconWidth
    local iconHeight = (override and override.overrideIcon) and override.iconHeight or db.iconHeight
    local showIconOverlay = db.showIconOverlay
    if override and override.overrideIcon then showIconOverlay = override.showIconOverlay end
    local showIconBorder = db.showIconBorder
    if override and override.overrideIcon then showIconBorder = override.showIconBorder end
    local removeMask = db.removeMask
    if override and override.overrideIcon then removeMask = override.removeMask end
    local addPixelBorder = db.addPixelBorder
    if override and override.overrideIcon then addPixelBorder = override.addPixelBorder end
    local pixelBorderSize = (override and override.overrideIcon) and override.pixelBorderSize or db.pixelBorderSize
    local pixelBorderColor = (override and override.overrideIcon) and override.pixelBorderColor or db.pixelBorderColor

    local showDebuffBorder = db.showDebuffBorder
    if override and override.overrideIcon then showDebuffBorder = override.showDebuffBorder end

    -- font settings
    local cooldownScale = (override and override.overrideFontSizes) and override.cooldownScale or db.cooldownScale
    local applicationScale = (override and override.overrideFontSizes) and override.applicationScale or db.countScale
    local cooldownPosition = (override and override.overrideFontSizes) and override.iconCooldownPosition or db.iconCooldownPosition
    local applicationPosition = (override and override.overrideFontSizes) and override.applicationPosition or db.applicationPosition

    -- other
    local showCooldown = db.showCooldown
    if override then showCooldown = override.showCooldown end
    --[[ local showTooltip = db.showTooltip
    if override then showTooltip = override.showTooltip end ]]

    -- Quick references to frame components
    local cooldownFrame = frame:GetCooldownFrame();

    -- Apply the settings to the frame
    frame:SetScale(scale)
    frame:SetWidth(iconWidth)
    frame:SetHeight(iconHeight)
    frame.Icon:SetAllPoints(frame)
    maintainAspectRatio(frame.Icon, iconWidth, iconHeight)

    -- Shadow overlay
    local overlay = findRegionByAtlas(frame, "UI-HUD-CoolDownManager-IconOverlay")
    if overlay then
        overlay:ClearAllPoints()
        overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -iconWidth * 0.18, iconHeight * 0.18)
        overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", iconWidth * 0.18, -iconHeight * 0.18)
        overlay:SetShown(showIconOverlay)
    end

    if showDebuffBorder then
        if frame.DebuffBorder then
            frame.DebuffBorder:ClearAllPoints()
            frame.DebuffBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -iconWidth * 0.1, iconHeight * 0.1)
            frame.DebuffBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", iconWidth * 0.1, -iconHeight * 0.1)
        end
    else
        if frame.DebuffBorder then
            frame.DebuffBorder:Hide()
            addon:Unhook(frame.DebuffBorder, "Show")
            addon:SecureHook(frame.DebuffBorder, "Show", function(self)
                frame.DebuffBorder:Hide()
            end)
        end
    end


    if removeMask then
        local mask = frame.Icon:GetMaskTexture(1)
        if mask then
            frame.Icon:RemoveMaskTexture(mask)
        end
        frame.Cooldown:SetSwipeTexture("Interface\\BUTTONS\\WHITE8X8")
    else
        local mask = frame.Icon:GetMaskTexture(1)
        if not mask and not warningShown then
            warningShown = true
            print("|cff0099ccCooldown Manager|r Control" .. ": ", " /reload required to reset the mask.")
        end
    end

    -- Atlas based border
    if name == "buffIcon" then
        -- Atlas based border
        local border = frame.OutOfRange
        if showIconBorder == 0 then
            -- no base behavior for this viewer, so we delete any existing border
            if border then
                border:Hide()
                --border = nil
            end
        elseif showIconBorder == 1 then
            -- the bar viewer does not provide a border by default, so we create one if needed
            if not border then
                border = frame:CreateTexture(nil, "OVERLAY")
                border:SetAllPoints(frame)
                border:SetAtlas("UI-CooldownManager-OORshadow")
                border:SetVertexColor(1, 1, 1, 0.5)
                frame.OutOfRange = border
            end
            border:Show()
        elseif showIconBorder == 2 then
            if border then
                border:Hide()
                --border = nil
            end
        end
    else
        local border = frame.OutOfRange
        if showIconBorder == 0 then
            addon:Unhook(border, "SetShown")
            border:Hide()
        elseif showIconBorder == 1 then
            border:Show()
            addon:Unhook(border, "SetShown")
            addon:SecureHook(border, "SetShown", function(self)
                border:Show()
            end)
        elseif showIconBorder == 2 then
            border:Hide()
            addon:Unhook(border, "SetShown")
            addon:SecureHook(border, "SetShown", function(self)
                border:Hide()
            end)
        end
    end

    -- Pixel Border
    if addPixelBorder then
        local r, g, b, a = addon:HexToRGB(pixelBorderColor)
        addBorder(frame, pixelBorderSize, r, g, b, a, name)
    else
        if frame.borderFrame then
            frame.borderFrame:Hide()
            --frame.borderFrame = nil
        end
    end

    -- Cooldown visibility
    if cooldownFrame then
        cooldownFrame:SetHideCountdownNumbers(not showCooldown)
        addon:Unhook(frame, "SetTimerShown")
        addon:SecureHook(frame, "SetTimerShown", function(self)
            cooldownFrame:SetHideCountdownNumbers(not showCooldown)
        end)
    end

    -- Cooldown Scale
    local cdText = frame.Cooldown:GetRegions()
    cdText:SetFontHeight(cooldownScale)

    --[[ cdText:ClearAllPoints()
    cdText:SetPoint(cooldownPosition, frame, cooldownPosition, 0, 0) ]]

    -- Charge Scale
    if name == "essential" or name == "utility" then
        frame.ChargeCount.Current:SetFontHeight(applicationScale)
        frame.ChargeCount.Current:ClearAllPoints()

        local xOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "LEFT") and 2 or
            ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "TOPRIGHT" or applicationPosition == "RIGHT") and -2 or 0)
        local yOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "TOP" or applicationPosition == "TOPRIGHT") and -2 or
            ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "BOTTOM") and 2 or 0)

        frame.ChargeCount.Current:SetPoint(applicationPosition, frame, applicationPosition, xOffset, yOffset)
    else
        frame.Applications.Applications:SetFontHeight(applicationScale)
        frame.Applications.Applications:ClearAllPoints()

        local xOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "LEFT") and 2 or
            ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "TOPRIGHT" or applicationPosition == "RIGHT") and -2 or 0)
        local yOffset = (applicationPosition == "TOPLEFT" or applicationPosition == "TOP" or applicationPosition == "TOPRIGHT") and -2 or
            ((applicationPosition == "BOTTOMRIGHT" or applicationPosition == "BOTTOMLEFT" or applicationPosition == "BOTTOM") and 2 or 0)

        frame.Applications.Applications:SetPoint(applicationPosition, frame, applicationPosition, xOffset, yOffset)
    end

    --return iconWidth, iconHeight
end

--- Displays or updates the keybind text on a frame having a given cooldownID.
--- @param frame      Frame  The frame on which to display the keybind.
--- @param name       string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @param cooldownID number Cooldown ID used to resolve the corresponding keybind.
--- @return nil
function addon:setKeybind(frame, name, cooldownID)
    if addon.db.profile[name].layout.keybind.showKeybind then
        local text = addon:GetKeybindForCooldownID(cooldownID)
        if not frame.__keybindFont then
            frame.__keybindFont = frame:CreateFontString(nil, "OVERLAY", "NumberFont_OutlineThick_Mono_Small")
        end
        local anchor = addon.db.profile[name].layout.keybind.keybindPosition
        local size = addon.db.profile[name].layout.keybind.keybindFontSize
        local xOffset = anchor == "TOPLEFT" and 2 or (anchor == "BOTTOMLEFT" and 2 or (anchor == "TOPRIGHT" and -2 or -2))
        local yOffset = anchor == "TOPLEFT" and -2 or (anchor == "BOTTOMLEFT" and 2 or (anchor == "TOPRIGHT" and -2 or 2))

        frame.__keybindFont:ClearAllPoints()
        frame.__keybindFont:SetPoint(anchor, frame, anchor, xOffset, yOffset)
        frame.__keybindFont:SetText(text)
        frame.__keybindFont:SetFontHeight(size)
    else
        if frame.__keybindFont then
            frame.__keybindFont:SetText("")
        end
    end
end

--- Setup the assisted highlight animation on a frame in the Essential Cooldown Viewer
--- @param frame    Frame  The frame to update.
--- @param override table|nil Overriden settings specific for this frame only.
--- @return nil
function addon:setAssistedHighlight(frame, override)
    local db = addon.db.profile.essential.layout
    local style = db.assistedHighlightStyle or 2
    if style == 2 then
        local width     = (override and override.overrideIcon) and override.iconWidth or db.iconWidth
        local height    = (override and override.overrideIcon) and override.iconHeight or db.iconHeight

        local scale     = antAtlas.scale
        local atlasName = antAtlas.atlasName
        local smooth    = "NONE"
        local loop      = "REPEAT"
        local cols      = antAtlas.cols
        local rows      = antAtlas.rows
        local numFrame  = antAtlas.numFrame
        local duration  = antAtlas.duration

        local color     = addon.db.profile.essential.layout.assistedHighlightColor or "#FFFFFF"

        if not frame.__assistedHighlightIcon then
            if not frame.__PlaceholderAssistedHighlight then
                frame.__PlaceholderAssistedHighlight = CreateFrame("Frame", nil, frame)
                frame.__PlaceholderAssistedHighlight:SetAllPoints(frame)
                frame.__PlaceholderAssistedHighlight:Show()
                frame.__PlaceholderAssistedHighlight:SetFrameStrata("MEDIUM")
                frame.__PlaceholderAssistedHighlight:SetFrameLevel(5)
            end
            frame.__assistedHighlightIcon = frame.__PlaceholderAssistedHighlight:CreateTexture(nil, "ARTWORK")
        end

        frame.__assistedHighlightIcon:SetTexCoord(0, 1, 0, 1)
        frame.__assistedHighlightIcon:ClearAllPoints()
        frame.__assistedHighlightIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", -width * scale, height * scale)
        frame.__assistedHighlightIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", width * scale, -height * scale)
        frame.__assistedHighlightIcon:SetAtlas(atlasName)

        local r, g, b, a = addon:HexToRGB(color)
        frame.__assistedHighlightIcon:SetVertexColor(r, g, b, a)
        frame.__assistedHighlightIcon:Hide()


        if not frame.__assistedHighlightAnimationGroup then
            frame.__assistedHighlightAnimationGroup = frame:CreateAnimationGroup()
            frame.__assistedHighlightFlipbookStart = frame.__assistedHighlightAnimationGroup:CreateAnimation("FlipBook")
            frame.__assistedHighlightFlipbookStart:SetChildKey("__assistedHighlightIcon")
        end

        frame.__assistedHighlightFlipbookStart:SetDuration(duration) -- loop length
        frame.__assistedHighlightFlipbookStart:SetFlipBookRows(rows)
        frame.__assistedHighlightFlipbookStart:SetFlipBookColumns(cols)
        frame.__assistedHighlightFlipbookStart:SetFlipBookFrames(numFrame)
        frame.__assistedHighlightFlipbookStart:SetSmoothing(smooth)
        frame.__assistedHighlightFlipbookStart:SetOrder(1)
        frame.__assistedHighlightAnimationGroup:SetLooping(loop)
        frame.__assistedHighlightAnimationGroup:Stop()
    else
        if frame.__assistedHighlightIcon then
            frame.__assistedHighlightIcon:Hide()
            if frame.__assistedHighlightAnimationGroup then
                frame.__assistedHighlightAnimationGroup:Stop()
            end
        end
    end
end

--- Start the assisted highlight on a frame
--- @param frame Frame  The frame to update.
--- @return nil
function addon:startAssistedHighlight(frame)
    local db = addon.db.profile.essential.layout
    local style = db.assistedHighlightStyle or 2
    if style == 1 then
        LCG.PixelGlow_Start(frame, { addon:HexToRGB(db.assistedHighlightColor or "FFFFFF") }, nil, nil, nil, 2)
    elseif style == 2 and frame.__assistedHighlightIcon then
        frame.__assistedHighlightIcon:Show()
        if not frame.__assistedHighlightAnimationGroup:IsPlaying() then
            frame.__assistedHighlightAnimationGroup:Play()
        end
    end
end

--- Stop the assisted highlight on a frame
--- @param frame Frame  The frame to update.
--- @return nil
function addon:stopAssistedHighlight(frame)
    LCG.PixelGlow_Stop(frame)
    if frame.__assistedHighlightIcon then
        frame.__assistedHighlightIcon:Hide()
        if frame.__assistedHighlightAnimationGroup:IsPlaying() then
            frame.__assistedHighlightAnimationGroup:Stop()
        end
    end
end

--- Updates the pandemic appearance on a frame
--- @param frame    Frame  The frame to update.
--- @param override table|nil Overriden settings specific for this frame only.
--- @param name     string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:updatePandemicIcon(frame, override, name)
    local db = addon.db.profile[name].layout

    local overridePandemicIcon, pandemicGlowType, hasCustomBorder
    local width, height, color, originalBorderColor, thickness

    if name == "buffBar" then
        overridePandemicIcon = db.overridePandemicIcon
        if override then overridePandemicIcon = override.overridePandemicIcon end
        pandemicGlowType = (override and override.overrideBar) and override.pandemicGlowType or db.pandemicGlowType
        hasCustomBorder = db.addPixelBorderBar
        if override and override.overrideBar then hasCustomBorder = override.addPixelBorderBar end
        width = (override and override.overrideBar) and override.barWidth or db.barWidth
        height = (override and override.overrideBar) and override.barHeight or db.barHeight
        color = (override) and override.pandemicColor or db.pandemicColor
        originalBorderColor = (override and override.overrideBar) and override.pixelBorderColorBar or db.pixelBorderColorBar
        thickness = (override and override.overrideBar) and override.pixelBorderSizeBar or db.pixelBorderSizeBar
    else
        overridePandemicIcon = db.overridePandemicIcon
        if override then overridePandemicIcon = override.overridePandemicIcon end
        pandemicGlowType = (override and override.overrideIcon) and override.pandemicGlowType or db.pandemicGlowType
        hasCustomBorder = db.addPixelBorder
        if override and override.overrideIcon then hasCustomBorder = override.addPixelBorder end
        width = (override and override.overrideIcon) and override.iconWidth or db.iconWidth
        height = (override and override.overrideIcon) and override.iconHeight or db.iconHeight
        color = (override) and override.pandemicColor or db.pandemicColor
        originalBorderColor = (override and override.overrideIcon) and override.pixelBorderColor or db.pixelBorderColor
        thickness = (override and override.overrideIcon) and override.pixelBorderSize or db.pixelBorderSize
    end

    addon:Unhook(frame, "ShowPandemicStateFrame")
    addon:Unhook(frame, "HidePandemicStateFrame")

    if not overridePandemicIcon then
        return
    end

    if name == "buffBar" and (pandemicGlowType == 3 or pandemicGlowType == 4 or pandemicGlowType == 5) then
        return
    end

    if hasCustomBorder and pandemicGlowType == 0 then
        -- Border Color only
        local r, g, b, a = addon:HexToRGB(color)
        local orR, orG, orB, orA = addon:HexToRGB(originalBorderColor)
        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end

            if name == "buffBar" then
                for _, tex in ipairs(self.Bar.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
            else
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
            end
        end)

        addon:SecureHook(frame, "HidePandemicStateFrame", function(self)
            if name == "buffBar" then
                for _, tex in ipairs(self.Bar.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
            else
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
            end
        end)
        return
    end

    if hasCustomBorder and pandemicGlowType == 1 then
        -- Border Animation only
        if name == "buffBar" then
            if not frame.Bar.borderFrame.animationGroup then
                local animGroup = frame.Bar.borderFrame:CreateAnimationGroup()

                local fadeIn = animGroup:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0)
                fadeIn:SetToAlpha(1)
                fadeIn:SetDuration(1)
                fadeIn:SetOrder(1)

                local fadeOut = animGroup:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(1)
                fadeOut:SetOrder(2)

                animGroup:SetLooping("REPEAT")
                frame.Bar.borderFrame.animationGroup = animGroup
            end
        else
            if not frame.borderFrame.animationGroup then
                local animGroup = frame.borderFrame:CreateAnimationGroup()

                local fadeIn = animGroup:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0)
                fadeIn:SetToAlpha(1)
                fadeIn:SetDuration(1)
                fadeIn:SetOrder(1)

                local fadeOut = animGroup:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(1)
                fadeOut:SetOrder(2)

                animGroup:SetLooping("REPEAT")
                frame.borderFrame.animationGroup = animGroup
            end
        end

        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end
            if name == "buffBar" then
                if not self.Bar.borderFrame.animationGroup:IsPlaying() then
                    self.Bar.borderFrame.animationGroup:Play()
                end
            else
                if not self.borderFrame.animationGroup:IsPlaying() then
                    self.borderFrame.animationGroup:Play()
                end
            end
        end)

        addon:SecureHook(frame, "HidePandemicStateFrame", function(self)
            --frame.borderFrame.animationGroup:Pause()
            if name == "buffBar" then
                self.Bar.borderFrame.animationGroup:Stop()
            else
                self.borderFrame.animationGroup:Stop()
            end
        end)

        frame.Bar.borderFrame.animationGroup:Stop()

        return
    end

    if hasCustomBorder and pandemicGlowType == 2 then
        -- Border Animation and Color
        local r, g, b, a = addon:HexToRGB(color)
        local orR, orG, orB, orA = addon:HexToRGB(originalBorderColor)

        if name == "buffBar" then
            if not frame.Bar.borderFrame.animationGroup then
                local animGroup = frame.Bar.borderFrame:CreateAnimationGroup()

                local fadeIn = animGroup:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0)
                fadeIn:SetToAlpha(1)
                fadeIn:SetDuration(1)
                fadeIn:SetOrder(1)

                local fadeOut = animGroup:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(1)
                fadeOut:SetOrder(2)

                animGroup:SetLooping("REPEAT")
                frame.Bar.borderFrame.animationGroup = animGroup
            end
        else
            if not frame.borderFrame.animationGroup then
                local animGroup = frame.borderFrame:CreateAnimationGroup()

                local fadeIn = animGroup:CreateAnimation("Alpha")
                fadeIn:SetFromAlpha(0)
                fadeIn:SetToAlpha(1)
                fadeIn:SetDuration(1)
                fadeIn:SetOrder(1)

                local fadeOut = animGroup:CreateAnimation("Alpha")
                fadeOut:SetFromAlpha(1)
                fadeOut:SetToAlpha(0)
                fadeOut:SetDuration(1)
                fadeOut:SetOrder(2)

                animGroup:SetLooping("REPEAT")
                frame.borderFrame.animationGroup = animGroup
            end
        end

        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end
            if name == "buffBar" then
                for _, tex in ipairs(self.Bar.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
                if not self.Bar.borderFrame.animationGroup:IsPlaying() then
                    self.Bar.borderFrame.animationGroup:Play()
                end
            else
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
                if not self.borderFrame.animationGroup:IsPlaying() then
                    self.borderFrame.animationGroup:Play()
                end
            end
        end)

        addon:SecureHook(frame, "HidePandemicStateFrame", function(self)
            --frame.borderFrame.animationGroup:Pause()
            if name == "buffBar" then
                for _, tex in ipairs(self.Bar.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
                self.Bar.borderFrame.animationGroup:Stop()
            else
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
                self.borderFrame.animationGroup:Stop()
            end
        end)

        frame.Bar.borderFrame.animationGroup:Stop()

        return
    end

    if pandemicGlowType == 3 then
        local started = false
        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end
            if not started then
                started = true
                if name == "buffBar" then
                    print("Starting Pixel Glow on Bar")
                    LCG.PixelGlow_Start(self.Bar, { addon:HexToRGB(color) }, nil, nil, nil, thickness)
                else
                    LCG.PixelGlow_Start(self, { addon:HexToRGB(color) }, nil, nil, nil, thickness)
                    --LCG.AutoCastGlow_Start(self, { addon:HexToRGB(color) })
                    --LCG.ButtonGlow_Start(self, { addon:HexToRGB(color) })
                end
            end
        end)
        addon:SecureHook(frame, "HidePandemicStateFrame", function(self)
            started = false
            if viewer == "buffBar" then
                print("Stopping Pixel Glow on Bar")
                LCG.PixelGlow_Stop(self.Bar)
            else
                LCG.PixelGlow_Stop(self)
                --LCG.AutoCastGlow_Stop(self)
                --LCG.ButtonGlow_Stop(self)
            end
        end)

        if viewer == "buffBar" then
            LCG.PixelGlow_Stop(frame.Bar)
        else
            LCG.PixelGlow_Stop(frame)
        end

        return
    end

    if pandemicGlowType == 4 then
        local atlasName, cols, rows, numFrame, duration, smooth, loop, scale

        smooth               = "NONE"
        loop                 = "REPEAT"
        atlasName            = antAtlas.atlasName
        cols                 = antAtlas.cols
        rows                 = antAtlas.rows
        numFrame             = antAtlas.numFrame
        duration             = antAtlas.duration

        local hasMaskRemoved = db.removeMask

        if override and override.overrideIcon then hasMaskRemoved = override.removeMask end
        scale = hasMaskRemoved and antAtlas.scale or antAtlas.scaleMask

        if not frame.__PandemicIcon then
            if not frame.__Placeholder then
                frame.__Placeholder = CreateFrame("Frame", nil, frame)
                frame.__Placeholder:SetAllPoints(frame)
                frame.__Placeholder:Show()
                frame.__Placeholder:SetFrameStrata("MEDIUM")
                frame.__Placeholder:SetFrameLevel(5)
            end

            frame.__PandemicIcon = frame.__Placeholder:CreateTexture(nil, "ARTWORK")
        end
        frame.__PandemicIcon:SetTexCoord(0, 1, 0, 1)
        frame.__PandemicIcon:ClearAllPoints()
        frame.__PandemicIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", -width * scale, height * scale)
        frame.__PandemicIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", width * scale, -height * scale)
        frame.__PandemicIcon:SetAtlas(atlasName)
        local r, g, b, a = addon:HexToRGB(color)
        frame.__PandemicIcon:SetVertexColor(r, g, b, a)
        frame.__PandemicIcon:Hide()

        if not frame.__AnimationGroup then
            frame.__AnimationGroup = frame:CreateAnimationGroup()
            frame.__FlipbookStart = frame.__AnimationGroup:CreateAnimation("FlipBook")
            frame.__FlipbookStart:SetChildKey("__PandemicIcon")
        end

        frame.__FlipbookStart:SetDuration(duration) -- loop length
        frame.__FlipbookStart:SetFlipBookRows(rows)
        frame.__FlipbookStart:SetFlipBookColumns(cols)
        frame.__FlipbookStart:SetFlipBookFrames(numFrame)
        frame.__FlipbookStart:SetSmoothing(smooth)
        frame.__FlipbookStart:SetOrder(1)
        frame.__AnimationGroup:SetLooping(loop)

        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end
            self.__PandemicIcon:Show()
            if not self.__AnimationGroup:IsPlaying() then
                self.__AnimationGroup:Play()
            end
        end)

        addon:SecureHook(frame, "HidePandemicStateFrame", function(self)
            self.__PandemicIcon:Hide()
            if self.__AnimationGroup:IsPlaying() then
                self.__AnimationGroup:Pause()
            end
        end)

        frame.__AnimationGroup:Stop()

        return
    end

    if pandemicGlowType == 5 then
        -- change the setPoint of the pandemic icon/bar to fit the frame
        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:SetFrameLevel(5)
                self.PandemicIcon:ClearAllPoints()
                self.PandemicIcon:SetPoint("TOPLEFT", self, "TOPLEFT", -width * 0.2, height * 0.2)
                self.PandemicIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
            end
        end)
        return
    end

    if pandemicGlowType == 6 then
        -- Hide Pandemic Icon/Bar
        addon:SecureHook(frame, "ShowPandemicStateFrame", function(self)
            if self.PandemicIcon then
                self.PandemicIcon:Hide()
            end
        end)

        return
    end
end

--- Updates the spell alert appearance on a frame
--- @param frame    Frame  The frame to update.
--- @param override table|nil Overriden settings specific for this frame only.
--- @param name     string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:updateSpellAlert(frame, override, name)
    -- Spell alert are only possible on essential and utility viewers
    if name == "buffBar" or name == "buffIcon" then
        return
    end

    local db = addon.db.profile[name].layout

    addon:Unhook(frame, "OnSpellActivationOverlayGlowHideEvent")
    addon:Unhook(frame, "OnSpellActivationOverlayGlowShowEvent")

    -- Remove existing spell alert
    LCG.PixelGlow_Stop(frame)
    if frame.borderFrame then
        LCG.PixelGlow_Stop(frame.borderFrame)
    end

    if frame.__SpellAlertAnimationGroup then
        frame.__SpellAlertAnimationGroup:Stop()
    end

    if frame.__SpellAlertIcon then
        frame.__SpellAlertIcon:Hide()
    end

    local targetFrameLevel = frame.borderFrame and frame.borderFrame:GetFrameLevel() + 1 or 5

    -- Variables
    local overrideSpellAlert = db.overrideSpellAlert
    if override then overrideSpellAlert = override.overrideSpellAlert end
    local spellAlertType = (override and override.overrideIcon) and override.spellAlertType or db.spellAlertType
    local hasCustomBorder = db.addPixelBorder
    if override and override.overrideIcon then hasCustomBorder = override.addPixelBorder end
    local color = (override) and override.spellAlertColor or db.spellAlertColor
    local originalBorderColor = (override and override.overrideIcon) and override.pixelBorderColor or db.pixelBorderColor
    local thickness = (override and override.overrideIcon) and override.pixelBorderSize or db.pixelBorderSize
    local width = (override and override.overrideIcon) and override.iconWidth or db.iconWidth
    local height = (override and override.overrideIcon) and override.iconHeight or db.iconHeight

    if not overrideSpellAlert then
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                self.SpellActivationAlert:SetAlpha(1)
            end
        end)
        return
    end

    if hasCustomBorder and spellAlertType == 0 then
        -- Border Color only
        local r, g, b, a = addon:HexToRGB(color)
        local orR, orG, orB, orA = addon:HexToRGB(originalBorderColor)
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
                self.SpellActivationAlert:SetAlpha(0)
            end
        end)

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowHideEvent", function(self)
            if self.SpellActivationAlert and not self.SpellActivationAlert:IsShown() then
                -- add a test to check if the color is not already the original color?
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
            end
        end)
        return
    end

    if hasCustomBorder and spellAlertType == 1 then
        -- Border Animation only
        if not frame.borderFrame.animationGroupSpellAlert then
            local animGroup = frame.borderFrame:CreateAnimationGroup()

            local fadeIn = animGroup:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0.25)
            fadeIn:SetToAlpha(1)
            fadeIn:SetDuration(0.25)
            fadeIn:SetOrder(1)

            local fadeOut = animGroup:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(1)
            fadeOut:SetToAlpha(0.25)
            fadeOut:SetDuration(0.25)
            fadeOut:SetOrder(2)

            animGroup:SetLooping("REPEAT")
            frame.borderFrame.animationGroupSpellAlert = animGroup
        end

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                if not self.borderFrame.animationGroupSpellAlert:IsPlaying() then
                    self.borderFrame.animationGroupSpellAlert:Play()
                end
                self.SpellActivationAlert:SetAlpha(0)
            end
        end)

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowHideEvent", function(self)
            if self.SpellActivationAlert and not self.SpellActivationAlert:IsShown() then
                self.borderFrame.animationGroupSpellAlert:Stop()
            end
        end)

        return
    end

    if hasCustomBorder and spellAlertType == 2 then
        -- Border Animation and Color
        local r, g, b, a = addon:HexToRGB(color)
        local orR, orG, orB, orA = addon:HexToRGB(originalBorderColor)

        if not frame.borderFrame.animationGroupSpellAlert then
            local animGroup = frame.borderFrame:CreateAnimationGroup()

            local fadeIn = animGroup:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0.25)
            fadeIn:SetToAlpha(1)
            fadeIn:SetDuration(0.25)
            fadeIn:SetOrder(1)

            local fadeOut = animGroup:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(1)
            fadeOut:SetToAlpha(0.25)
            fadeOut:SetDuration(0.25)
            fadeOut:SetOrder(2)

            animGroup:SetLooping("REPEAT")
            frame.borderFrame.animationGroupSpellAlert = animGroup
        end

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(r, g, b, a)
                end
                if not self.borderFrame.animationGroupSpellAlert:IsPlaying() then
                    self.borderFrame.animationGroupSpellAlert:Play()
                end
                self.SpellActivationAlert:SetAlpha(0)
            end
        end)

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowHideEvent", function(self)
            if self.SpellActivationAlert and not self.SpellActivationAlert:IsShown() then
                for _, tex in ipairs(self.borderFrame.BorderTextures) do
                    tex:SetColorTexture(orR, orG, orB, orA)
                end
                self.borderFrame.animationGroupSpellAlert:Stop()
            end
        end)

        return
    end

    if spellAlertType == 3 then
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)

                if hasCustomBorder then
                    LCG.PixelGlow_Start(self.borderFrame, { addon:HexToRGB(color) }, nil, nil, nil, thickness)
                else
                    LCG.PixelGlow_Start(self, { addon:HexToRGB(color) }, nil, nil, nil, thickness)
                end

                self.SpellActivationAlert:SetAlpha(0)
            end
        end)
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowHideEvent", function(self)
            if self.SpellActivationAlert and not self.SpellActivationAlert:IsShown() then
                LCG.PixelGlow_Stop(self)
                if frame.borderFrame then
                    LCG.PixelGlow_Stop(self.borderFrame)
                end
            end
        end)
        return
    end

    if spellAlertType == 4 then
        local atlasName, cols, rows, numFrame, duration, smooth, loop, scale
        smooth               = "NONE"
        loop                 = "REPEAT"

        atlasName            = antAtlas.atlasName
        cols                 = antAtlas.cols
        rows                 = antAtlas.rows
        numFrame             = antAtlas.numFrame
        duration             = antAtlas.duration

        local hasMaskRemoved = db.removeMask

        if override and override.overrideIcon then hasMaskRemoved = override.removeMask end
        scale = hasMaskRemoved and antAtlas.scale or antAtlas.scaleMask

        if not frame.__SpellAlertIcon then
            if not frame.__PlaceholderSpellAlert then
                frame.__PlaceholderSpellAlert = CreateFrame("Frame", nil, frame)
                frame.__PlaceholderSpellAlert:SetAllPoints(frame)
                frame.__PlaceholderSpellAlert:Show()
                frame.__PlaceholderSpellAlert:SetFrameStrata("MEDIUM")
                frame.__PlaceholderSpellAlert:SetFrameLevel(targetFrameLevel)

                frame.__SpellAlertIcon = frame.__PlaceholderSpellAlert:CreateTexture(nil, "ARTWORK")
            end
        end
        frame.__SpellAlertIcon:SetTexCoord(0, 1, 0, 1)
        frame.__SpellAlertIcon:ClearAllPoints()
        frame.__SpellAlertIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", -width * scale, height * scale)
        frame.__SpellAlertIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", width * scale, -height * scale)
        frame.__SpellAlertIcon:SetAtlas(atlasName)
        local r, g, b, a = addon:HexToRGB(color)
        frame.__SpellAlertIcon:SetVertexColor(r, g, b, a)
        frame.__SpellAlertIcon:Hide()

        if not frame.__SpellAlertAnimationGroup then
            frame.__SpellAlertAnimationGroup = frame:CreateAnimationGroup()
            frame.__SpellAlertFlipbookStart = frame.__SpellAlertAnimationGroup:CreateAnimation("FlipBook")
            frame.__SpellAlertFlipbookStart:SetChildKey("__SpellAlertIcon")
        end
        frame.__SpellAlertFlipbookStart:SetDuration(duration) -- loop length
        frame.__SpellAlertFlipbookStart:SetFlipBookRows(rows)
        frame.__SpellAlertFlipbookStart:SetFlipBookColumns(cols)
        frame.__SpellAlertFlipbookStart:SetFlipBookFrames(numFrame)
        frame.__SpellAlertFlipbookStart:SetSmoothing(smooth)
        frame.__SpellAlertFlipbookStart:SetOrder(1)
        frame.__SpellAlertAnimationGroup:SetLooping(loop)

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                self.__SpellAlertIcon:Show()
                if not self.__SpellAlertAnimationGroup:IsPlaying() then
                    self.__SpellAlertAnimationGroup:Play()
                end
                self.SpellActivationAlert:SetAlpha(0)
            end
        end)

        addon:SecureHook(frame, "OnSpellActivationOverlayGlowHideEvent", function(self)
            if self.SpellActivationAlert and not self.SpellActivationAlert:IsShown() then
                self.__SpellAlertIcon:Hide()
                if self.__SpellAlertAnimationGroup:IsPlaying() then
                    self.__SpellAlertAnimationGroup:Pause()
                end
            end
        end)

        return
    end

    if spellAlertType == 5 then
        -- change the setPoint of the spell alert to fit the frame
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:SetFrameLevel(targetFrameLevel)
                self.SpellActivationAlert:ClearAllPoints()
                self.SpellActivationAlert:SetPoint("TOPLEFT", self, "TOPLEFT", -width * 0.2, height * 0.2)
                self.SpellActivationAlert:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", width * 0.2, -height * 0.2)
                self.SpellActivationAlert:SetAlpha(1)
            end
        end)
        return
    end

    if spellAlertType == 6 then
        -- Hide Spell Alert
        addon:SecureHook(frame, "OnSpellActivationOverlayGlowShowEvent", function(self)
            if self.SpellActivationAlert and self.SpellActivationAlert:IsShown() then
                self.SpellActivationAlert:Hide()
            end
        end)

        return
    end
end

--- Applies visual styles to all item frames in a viewer.
--- @param name     string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:applyStyle(name)
    local viewer = addonTable.viewerFrameMap[name]
    local itemFrameContainer = viewer:GetLayoutChildren()
    local spec = addon.db.global.playerSpec

    for i = 1, #itemFrameContainer, 1 do
        local itemFrame = itemFrameContainer[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

        if cooldownID then
            local overrideSettings = addon.db.profile[name].override[spec][cooldownID]
            local settings = overrideSettings and overrideSettings.enable and overrideSettings or nil

            if name == "buffBar" then
                addon:setBarStyle(itemFrame, settings)
            else
                addon:setIconStyle(itemFrame, settings, name)
            end

            addon:updatePandemicIcon(itemFrame, settings, name)

            if name == "essential" or name == "utility" then
                addon:updateSpellAlert(itemFrame, settings, name)
                addon:setKeybind(itemFrame, name, cooldownID)
            end

            if name == "essential" then
                addon:setAssistedHighlight(itemFrame, settings)
            end
        end
    end
end

--- Updates keybind text for all item frames in a viewer.
--- @param name     string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:applyKeybind(name)
    local viewer = addonTable.viewerFrameMap[name]
    local itemFrameContainer = viewer:GetLayoutChildren()
    for i = 1, #itemFrameContainer, 1 do
        local itemFrame = itemFrameContainer[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()

        if cooldownID then
            if (name == "essential" or name == "utility") and addon.db.profile[name].layout.keybind.showKeybind then
                local text = addon:GetKeybindForCooldownID(cooldownID)
                if not itemFrame.__keybindFont then
                    itemFrame.__keybindFont = itemFrame:CreateFontString(nil, "OVERLAY", "NumberFont_OutlineThick_Mono_Small")
                end
                local anchor = addon.db.profile[name].layout.keybind.keybindPosition
                local size = addon.db.profile[name].layout.keybind.keybindFontSize
                local xOffset = anchor == "TOPLEFT" and 2 or (anchor == "BOTTOMLEFT" and 2 or (anchor == "TOPRIGHT" and -2 or -2))
                local yOffset = anchor == "TOPLEFT" and -2 or (anchor == "BOTTOMLEFT" and 2 or (anchor == "TOPRIGHT" and -2 or 2))

                itemFrame.__keybindFont:ClearAllPoints()
                itemFrame.__keybindFont:SetPoint(anchor, itemFrame, anchor, xOffset, yOffset)
                itemFrame.__keybindFont:SetText(text)
                itemFrame.__keybindFont:SetFontHeight(size)
            else
                if itemFrame.__keybindFont then
                    itemFrame.__keybindFont:SetText("")
                end
            end
        end
    end
end
