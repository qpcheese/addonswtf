-- ═══════════════════════════════════════════════════════════════════════════
-- ArcUI CDM Spell Usability
-- Runtime module for spell usability visuals on CDM (Cooldown Manager) frames.
-- Handles:
--   1. Usability tinting via RefreshIconColor hook
--   2. Usable glow via overlay pattern (Ellesmere method)
--
-- Settings are stored in cfg.spellUsability (managed by SpellUsabilityOptions).
-- Integration: CDMEnhance calls HookFrame() during enhancement and
--              UpdateGlow() from the 20Hz cooldown state ticker.
-- ═══════════════════════════════════════════════════════════════════════════

local addonName, ns = ...

ns.CDMSpellUsability = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- LCG ACCESS
-- ═══════════════════════════════════════════════════════════════════════════

local cachedLCG
local function GetLCG()
    if cachedLCG then return cachedLCG end
    cachedLCG = LibStub and LibStub("LibCustomGlow-1.0", true)
    return cachedLCG
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DEFAULT COLORS (match CDM constants and ArcAurasCooldown defaults)
-- ═══════════════════════════════════════════════════════════════════════════

local NOT_ENOUGH_MANA  = { r = 0.5, g = 0.5, b = 1.0, a = 1.0 }
local NOT_USABLE_COLOR = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 }

-- ═══════════════════════════════════════════════════════════════════════════
-- OPTIONS PANEL STATE
-- ═══════════════════════════════════════════════════════════════════════════

local function IsOptionsPanelOpen()
    return ns.CDMEnhance and ns.CDMEnhance.IsOptionsPanelOpen
        and ns.CDMEnhance.IsOptionsPanelOpen() or false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

local function GetSpellIDFromFrame(frame)
    if frame.cooldownInfo then
        return frame.cooldownInfo.overrideSpellID or frame.cooldownInfo.spellID
    end
    if frame.GetSpellID then
        local ok, id = pcall(frame.GetSpellID, frame)
        if ok then return id end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- USABILITY TINTING (RefreshIconColor hook)
--
-- Runs AFTER CDM sets its native colors. Overrides vertex color based
-- on spell usability state and user's custom tint settings.
-- Skip when out of range (range indicator handles that independently).
-- We do NOT check cooldown state here — cooldownDesaturated is SECRET.
-- CDM's own desaturation makes colors subtle during cooldown anyway.
-- ═══════════════════════════════════════════════════════════════════════════

function ns.CDMSpellUsability.OnRefreshIconColor(frame)
    if frame._arcBypassUsabilityHook then return end

    -- Skip Arc Auras frames (they handle their own usability)
    if frame._arcConfig or frame._arcAuraID then return end

    -- Get settings
    local cfg
    if ns.CDMEnhance and ns.CDMEnhance.GetEffectiveIconSettingsForFrame then
        cfg = ns.CDMEnhance.GetEffectiveIconSettingsForFrame(frame)
    end
    if not cfg then return end

    local su = cfg.spellUsability
    if not su or su.enabled == false then return end

    -- Skip if spell is out of range (range indicator takes priority)
    if frame.spellOutOfRange then return end

    local spellID = GetSpellIDFromFrame(frame)
    if not spellID then return end

    -- C_Spell.IsSpellUsable returns non-secret booleans
    local isUsable, notEnoughMana = C_Spell.IsSpellUsable(spellID)

    local iconTex = frame.Icon or frame.icon
    if not iconTex then return end
    -- Bar-style icons: frame.Icon is a Frame container with .Icon child texture
    if not iconTex.SetVertexColor and iconTex.Icon then
        iconTex = iconTex.Icon
    end
    if not iconTex or not iconTex.SetVertexColor then return end

    if isUsable then
        -- Usable → CDM already set ITEM_USABLE_COLOR, nothing to override
        -- But we MUST restore alpha if we previously dimmed it
        if frame._arcUsabilityAlphaOverride then
            frame._arcUsabilityAlphaOverride = nil
            frame._arcBypassFrameAlphaHook = true
            frame:SetAlpha(frame._arcTargetAlpha or 1.0)
            frame._arcBypassFrameAlphaHook = false
        end
        return
    elseif notEnoughMana then
        local c = su.notEnoughResourceColor or NOT_ENOUGH_MANA
        iconTex:SetVertexColor(c.r or 0.5, c.g or 0.5, c.b or 1.0, c.a or 1.0)
        -- Apply custom alpha if set
        local alpha = su.notEnoughResourceAlpha
        if alpha then
            -- OPTIONS PANEL PREVIEW: Show dimmed icons at 0.35 so user can see them while editing
            if alpha <= 0 and IsOptionsPanelOpen() then
                alpha = 0.35
            end
            frame._arcUsabilityAlphaOverride = true
            frame._arcBypassFrameAlphaHook = true
            frame:SetAlpha(alpha)
            frame._arcBypassFrameAlphaHook = false
        end
    else
        local c = su.notUsableColor or NOT_USABLE_COLOR
        iconTex:SetVertexColor(c.r or 0.4, c.g or 0.4, c.b or 0.4, c.a or 1.0)
        -- Apply custom alpha if set
        local alpha = su.notUsableAlpha
        if alpha then
            -- OPTIONS PANEL PREVIEW: Show dimmed icons at 0.35 so user can see them while editing
            if alpha <= 0 and IsOptionsPanelOpen() then
                alpha = 0.35
            end
            frame._arcUsabilityAlphaOverride = true
            frame._arcBypassFrameAlphaHook = true
            frame:SetAlpha(alpha)
            frame._arcBypassFrameAlphaHook = false
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HOOK INSTALLER
-- Called from CDMEnhance during frame enhancement.
-- Installs RefreshIconColor hook for usability tinting.
-- ═══════════════════════════════════════════════════════════════════════════

function ns.CDMSpellUsability.HookFrame(frame)
    if not frame then return end
    if frame._arcUsabilityTintHooked then return end
    if not frame.RefreshIconColor then return end

    frame._arcUsabilityTintHooked = true

    hooksecurefunc(frame, "RefreshIconColor", function(self)
        ns.CDMSpellUsability.OnRefreshIconColor(self)
    end)

    -- ═══════════════════════════════════════════════════════════════
    -- SHADOW COOLDOWN FRAME (mirrors desatCooldown in ArcAuras)
    --
    -- Converts secret cooldown data into a non-secret boolean:
    --   IsShown() = true  → spell is on FULL cooldown (all charges depleted)
    --   IsShown() = false → spell is ready or has charges available
    --
    -- Fed with GetSpellCooldownDuration (main CD only, not recharge).
    -- GCD is filtered out so the shadow doesn't flash during GCD.
    -- ═══════════════════════════════════════════════════════════════
    local shadowCD = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    shadowCD:SetAllPoints(frame)
    shadowCD:SetDrawSwipe(false)
    shadowCD:SetDrawEdge(false)
    shadowCD:SetDrawBling(false)
    shadowCD:SetHideCountdownNumbers(true)
    shadowCD:SetAlpha(0)  -- INVISIBLE! But IsShown() still reflects CD state.
    frame._arcCDMShadowCooldown = shadowCD
end

-- ═══════════════════════════════════════════════════════════════════════════
-- USABLE GLOW OVERLAY (Ellesmere pattern)
--
-- Dedicated child frame per icon for usable glow. Gives usable glow its
-- own _ButtonGlow, eliminating conflicts with ready glow on the parent.
-- ═══════════════════════════════════════════════════════════════════════════

local function GetUsableGlowOverlay(frame)
    if frame._arcCDMUsableGlowOverlay then return frame._arcCDMUsableGlowOverlay end
    local overlay = CreateFrame("Frame", nil, frame)
    overlay:SetAllPoints(frame)
    overlay:SetFrameLevel(frame:GetFrameLevel() + 10)
    overlay:Show()
    frame._arcCDMUsableGlowOverlay = overlay
    return overlay
end

local function StartGlowOnOverlay(overlay, glowType, color, opts)
    if not overlay then return end
    local LCG = GetLCG()
    if not LCG then return end
    opts = opts or {}
    local ca = color and { color.r or 1, color.g or 1, color.b or 1, color.a or 1 } or nil
    local key = opts.key or ""

    if glowType == "button" then
        LCG.ButtonGlow_Start(overlay, ca, opts.frequency)
    elseif glowType == "pixel" then
        LCG.PixelGlow_Start(overlay, ca, opts.lines or 8, opts.frequency or 0.25, opts.length, opts.thickness or 2, 0, 0, true, key)
    elseif glowType == "autocast" then
        LCG.AutoCastGlow_Start(overlay, ca, opts.particles or 4, opts.frequency or 0.25, opts.scale or 1, 0, 0, key)
    elseif glowType == "glow" then
        LCG.ProcGlow_Start(overlay, { color = ca, startAnim = false, key = key })
        local gf = overlay["_ProcGlow" .. key]
        if gf then
            if gf.ProcStart then gf.ProcStart:Hide() end
            if gf.ProcLoop then
                gf.ProcLoop:Show()
                gf.ProcLoop:SetAlpha(1.0)
            end
        end
    end

    -- Elevate glow frames above swipe
    local baseLevel = overlay:GetFrameLevel()
    local gf
    if glowType == "button" then gf = overlay._ButtonGlow
    elseif glowType == "pixel" then gf = overlay["_PixelGlow" .. key]
    elseif glowType == "autocast" then gf = overlay["_AutoCastGlow" .. key]
    elseif glowType == "glow" then gf = overlay["_ProcGlow" .. key]
    end
    if gf and gf.SetFrameLevel then gf:SetFrameLevel(baseLevel + 15) end
end

local function StopUsableGlow(frame)
    local overlay = frame._arcCDMUsableGlowOverlay
    if not overlay then return end
    -- Hide overlay FIRST — LCG's ButtonGlow_Stop checks r:IsVisible().
    -- When hidden: skips fade, releases to pool, clears _ButtonGlow.
    overlay:Hide()
    overlay:SetAlpha(0)
    -- Stop all glow types (keyed + unkeyed)
    local LCG = GetLCG()
    if LCG then
        LCG.ButtonGlow_Stop(overlay)              -- unkeyed (button glow)
        LCG.PixelGlow_Stop(overlay, "usable")
        LCG.AutoCastGlow_Stop(overlay, "usable")
        if LCG.ProcGlow_Stop then LCG.ProcGlow_Stop(overlay, "usable") end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SHADOW COOLDOWN FEEDER
--
-- Feeds the shadow Cooldown frame with GetSpellCooldownDuration.
-- Filters GCD (same as ArcAurasCooldown.UpdateCooldownDisplay):
--   isOnGCD → SetCooldown(0,0) → IsShown()=false → "not on CD"
--   real CD → SetCooldownFromDurationObject → IsShown()=true → "on CD"
-- ═══════════════════════════════════════════════════════════════════════════

local function FeedShadowCooldown(frame, spellID)
    local shadowCD = frame._arcCDMShadowCooldown
    if not shadowCD then return end

    -- GCD filter: during GCD, force shadow off so glow doesn't flash.
    -- GetSpellCooldown().isOnGCD is NeverSecret per SpellSharedDocumentation.
    local cdInfo = C_Spell.GetSpellCooldown(spellID)
    if cdInfo and cdInfo.isOnGCD then
        shadowCD:SetCooldown(0, 0)
        return
    end

    -- Feed main cooldown duration (NOT charge duration).
    -- GetSpellCooldownDuration returns the MAIN CD — for charge spells this
    -- only fires when ALL charges are depleted, not during recharge.
    local durObj = nil
    pcall(function() durObj = C_Spell.GetSpellCooldownDuration(spellID) end)
    if durObj then
        shadowCD:Clear()
        pcall(function()
            shadowCD:SetCooldownFromDurationObject(durObj, true)
        end)
    else
        -- No duration = spell ready
        shadowCD:SetCooldown(0, 0)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GLOW UPDATE (called from ApplyCooldownStateVisuals relay + ApplyIconVisuals)
--
-- Manages usable glow overlay based on spell state:
--   Show glow when: spell has resources (IsSpellUsable)
--                   AND not all charges depleted (shadow CD not shown)
--   Hide glow when: no resources OR all charges consumed
-- ═══════════════════════════════════════════════════════════════════════════

function ns.CDMSpellUsability.UpdateGlow(frame, cfg)
    if not frame then return end
    -- Skip Arc Auras frames
    if frame._arcConfig or frame._arcAuraID then return end

    if not cfg then
        if ns.CDMEnhance and ns.CDMEnhance.GetEffectiveIconSettingsForFrame then
            cfg = ns.CDMEnhance.GetEffectiveIconSettingsForFrame(frame)
        end
    end
    if not cfg then return end

    local su = cfg.spellUsability

    -- Check preview mode
    local cdID = frame.cooldownID
    local isPreview = cdID
        and ns.CDMEnhanceOptions
        and ns.CDMEnhanceOptions.IsUsableGlowPreviewActive
        and ns.CDMEnhanceOptions.IsUsableGlowPreviewActive(cdID)

    local shouldGlow = false

    if isPreview then
        -- Preview always shows glow
        shouldGlow = true
    elseif su and su.usableGlow then
        local spellID = GetSpellIDFromFrame(frame)
        if spellID then
            -- Feed shadow Cooldown with current spell state
            FeedShadowCooldown(frame, spellID)

            -- Shadow frame converts secret cooldown into non-secret boolean:
            --   IsShown()=true  → all charges depleted / full CD active
            --   IsShown()=false → has charges available / spell ready
            local shadowCD = frame._arcCDMShadowCooldown
            local allDepleted = shadowCD and shadowCD:IsShown() or false

            -- IsSpellUsable checks resources (mana/energy/etc) — non-secret
            local isUsable = C_Spell.IsSpellUsable(spellID)

            -- Glow when: has resources AND not fully on cooldown
            if isUsable and not allDepleted then
                local combatOnly = su.usableGlowCombatOnly
                shouldGlow = not combatOnly or InCombatLockdown()
            end
        end
    end

    if shouldGlow then
        local glowSu = su or {}
        local glowType = glowSu.usableGlowType or "button"
        if glowType == "blizzard" then glowType = "glow" end  -- migrate
        -- Only restart if type changed or not active
        if not frame._arcCDMUsableGlowActive or frame._arcCDMUsableGlowType ~= glowType then
            -- Stop old glow if type changed
            if frame._arcCDMUsableGlowActive then
                StopUsableGlow(frame)
            end
            local gc = glowSu.usableGlowColor
            local overlay = GetUsableGlowOverlay(frame)
            overlay:Show()
            overlay:SetAlpha(1)
            StartGlowOnOverlay(overlay, glowType, gc, {
                key = "usable",
                lines = glowSu.usableGlowLines or 8,
                frequency = glowSu.usableGlowSpeed or 0.25,
                thickness = glowSu.usableGlowThickness or 2,
                particles = glowSu.usableGlowParticles or 4,
                scale = glowSu.usableGlowScale or 1,
            })
            frame._arcCDMUsableGlowActive = true
            frame._arcCDMUsableGlowType = glowType
        end
    elseif frame._arcCDMUsableGlowActive then
        StopUsableGlow(frame)
        frame._arcCDMUsableGlowActive = false
        frame._arcCDMUsableGlowType = nil
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CLEANUP HELPERS
-- ═══════════════════════════════════════════════════════════════════════════

-- Force-stop all usable glows (for settings refresh)
function ns.CDMSpellUsability.StopAllGlows()
    if not ns.CDMEnhance or not ns.CDMEnhance.GetEnhancedFrames then return end
    local enhanced = ns.CDMEnhance.GetEnhancedFrames()
    if not enhanced then return end
    for _, entry in pairs(enhanced) do
        local frame = entry.frame
        if frame and frame._arcCDMUsableGlowActive then
            StopUsableGlow(frame)
            frame._arcCDMUsableGlowActive = false
            frame._arcCDMUsableGlowType = nil
        end
    end
end

-- Refresh all CDM frame usability visuals
-- IMPORTANT: Never call Blizzard's RefreshIconColor from here — it does a
-- boolean test on IsSpellUsable which is SECRET and taint persists even
-- after InCombatLockdown() returns false. Call our hook directly.
function ns.CDMSpellUsability.RefreshAll()
    if not ns.CDMEnhance or not ns.CDMEnhance.GetEnhancedFrames then return end
    local enhanced = ns.CDMEnhance.GetEnhancedFrames()
    if not enhanced then return end
    for _, entry in pairs(enhanced) do
        local frame = entry.frame
        if frame then
            ns.CDMSpellUsability.OnRefreshIconColor(frame)
            ns.CDMSpellUsability.UpdateGlow(frame)
        end
    end
end

-- Refresh a single CDM frame by cooldownID
function ns.CDMSpellUsability.RefreshFrame(cdID)
    if not ns.CDMEnhance or not ns.CDMEnhance.GetEnhancedFrames then return end
    local enhanced = ns.CDMEnhance.GetEnhancedFrames()
    if not enhanced or not enhanced[cdID] then return end
    local frame = enhanced[cdID].frame
    if frame then
        -- Force glow restart
        if frame._arcCDMUsableGlowActive then
            StopUsableGlow(frame)
            frame._arcCDMUsableGlowActive = false
            frame._arcCDMUsableGlowType = nil
        end
        -- Re-evaluate
        ns.CDMSpellUsability.UpdateGlow(frame)
        ns.CDMSpellUsability.OnRefreshIconColor(frame)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- OPTIONS PANEL STATE TICKER + USABILITY RECOVERY POLLING
-- ═══════════════════════════════════════════════════════════════════════════

local lastPanelOpenState = false
C_Timer.NewTicker(0.5, function()
    local isOpen = IsOptionsPanelOpen()
    if isOpen ~= lastPanelOpenState then
        lastPanelOpenState = isOpen
        ns.CDMSpellUsability.RefreshAll()
        return
    end
    if ns.CDMEnhance and ns.CDMEnhance.GetEnhancedFrames then
        local enhanced = ns.CDMEnhance.GetEnhancedFrames()
        if enhanced then
            for _, entry in pairs(enhanced) do
                if entry.frame and entry.frame._arcUsabilityAlphaOverride then
                    ns.CDMSpellUsability.RefreshAll()
                    return
                end
            end
        end
    end
end)

-- SPELL_UPDATE_USABLE fires on resource change, form/stance swap, etc.
local usabilityEventFrame = CreateFrame("Frame")
usabilityEventFrame:RegisterEvent("SPELL_UPDATE_USABLE")
usabilityEventFrame:SetScript("OnEvent", function()
    ns.CDMSpellUsability.RefreshAll()
end)