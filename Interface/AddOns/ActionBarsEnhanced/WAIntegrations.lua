local AddonName, Addon = ...

local T = Addon.Templates

local IntegratedWA = {}

local function AddMaskToWA(region)
    if not Addon.C.AddWAMask then return end

    if not region.mask then
        region.mask = region:CreateMaskTexture()
    end

    region.mask:SetTexture(6707800)
    region.mask:SetAllPoints()
    region.icon:AddMaskTexture(region.mask)
end

local function ReSkinWAGlow(region)
    if not region then return end

    --if region.ABE_Modified then return end

    local loopAnim = T.LoopGlow[Addon.C.CurrentWALoopGlow] or nil
    local procAnim = T.ProcGlow[Addon.C.CurrentWAProcGlow] or nil

    local startProc = region.ProcStartAnim.flipbookStart or nil

    if region.startAnim then
        if procAnim.atlas then
            region.ProcStart:SetAtlas(procAnim.atlas)
        elseif procAnim.texture then
            region.ProcStart:SetTexture(procAnim.texture)
        end
        if procAnim then
            startProc:SetFlipBookRows(procAnim.rows or 6)
            startProc:SetFlipBookColumns(procAnim.columns or 5)
            startProc:SetFlipBookFrames(procAnim.frames or 30)
            startProc:SetDuration(procAnim.duration or 0.702)
            startProc:SetFlipBookFrameWidth(procAnim.frameW or 0.0)
            startProc:SetFlipBookFrameHeight(procAnim.frameH or 0.0)
            region.ProcStart:SetScale(procAnim.scale or 1)
        end
        region.ProcStart:SetDesaturated(Addon.C.DesaturateWAProc)

        if Addon.C.UseWAProcColor then
            region.ProcStart:SetVertexColor(Addon:GetRGB("WAProcColor"))
        else
            region.ProcStart:SetVertexColor(1.0, 1.0, 1.0)
        end
    end

    if loopAnim.atlas then
        region.ProcLoop:SetAtlas(loopAnim.atlas)
    elseif loopAnim.texture then
        region.ProcLoop:SetTexture(loopAnim.texture)
    end
    if loopAnim then
        --region.ProcLoop:ClearAllPoints()
        --local frameWidth, frameHeight = region:GetSize()
        --region.ProcLoop:SetSize(frameWidth * 1.1, frameHeight * 1.1)
        --region.ProcLoop:SetPoint("CENTER", region, "CENTER", 0, 0)
        region.ProcLoopAnim.flipbookRepeat:SetFlipBookRows(loopAnim.rows or 6)
        region.ProcLoopAnim.flipbookRepeat:SetFlipBookColumns(loopAnim.columns or 5)
        region.ProcLoopAnim.flipbookRepeat:SetFlipBookFrames(loopAnim.frames or 30)
        region.ProcLoopAnim.flipbookRepeat:SetDuration(loopAnim.duration or 1.0)
        region.ProcLoopAnim.flipbookRepeat:SetFlipBookFrameWidth(loopAnim.frameW or 0.0)
        region.ProcLoopAnim.flipbookRepeat:SetFlipBookFrameHeight(loopAnim.frameH or 0.0)
        region.ProcLoop:SetScale(loopAnim.scale or 1)
    end
    region.ProcLoop:SetDesaturated(Addon.C.DesaturateWALoop)
    if Addon.C.UseWALoopColor then
        region.ProcLoop:SetVertexColor(Addon:GetRGB("WALoopColor"))
    else
        region.ProcLoop:SetVertexColor(1.0, 1.0, 1.0)
    end

    --region.ABE_Modified = true
end

local function WA_GlowStartHook(self)
    ReSkinWAGlow(self._ProcGlow)
end

function ABE_WAIntegration(self)

    if not Addon.C.ModifyWAGlow then return end

    local WAName = self.id
    local region = self.region or WeakAuras.GetRegion(WAName)

    if region then
        if not IntegratedWA[WAName] then
            if region.subRegions then
                for _, value in pairs(region.subRegions) do
                    if value.glowType == "Proc" then
                        if value.glowStart then
                            --Addon.Print("WA Integration", WAName)
                            hooksecurefunc(value, "glowStart", WA_GlowStartHook)
                            IntegratedWA[WAName] = true
                        end
                    end
                end
                if region.regionType == "icon" then
                    AddMaskToWA(region)
                end
            end
        end
    end
end


function ABE_WAIntegrationParse()
    for id, aura in pairs(WeakAurasSaved.displays) do
        if WeakAuras.IsAuraLoaded(id) then
            ABE_WAIntegration(aura)
        end
    end
end