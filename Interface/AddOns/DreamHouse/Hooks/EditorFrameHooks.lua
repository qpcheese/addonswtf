--[[
    DreamHouse - Editor Frame Hooks
    Hooks für das Blizzard House Editor Frame
    
    Features:
    - Hotbar anzeigen wenn Editor aktiv
    - Stats aktualisieren bei Decor-Änderungen
    - Preset-Manager im Layout-Modus
]]

local addonName, DreamHouse = ...

DreamHouse.Hooks = DreamHouse.Hooks or {}
DreamHouse.Hooks.Editor = {}

local isApplied = false

function DreamHouse.Hooks.Editor:Apply()
    if isApplied then return end
    
    DreamHouse.Debug:Log("Hooks", "Wende Editor-Frame Hooks an...", "INFO")
    
    -- HousingControlsFrame existiert früher - direkt hooken wenn vorhanden
    if HousingControlsFrame then
        self:HookControlsFrame(HousingControlsFrame)
    else
        DreamHouse.Utils:WaitForFrame("HousingControlsFrame", function(controlsFrame)
            self:HookControlsFrame(controlsFrame)
        end)
    end
    
    -- Mode-Frame Hooks (Mixins existieren früh)
    self:HookModeFrames()
    
    -- Decor-Platzierung tracken für Stats
    self:HookDecorPlacement()
    
    -- Editor-Frame wird lazy geladen - warte auf Editor-Mode Event
    DreamHouse.Events:Register("DREAMHOUSE_MODE_CHANGED", function(self, newMode)
        if newMode and newMode ~= Enum.HouseEditorMode.None then
            -- Editor ist aktiv - jetzt sollte das Frame existieren
            C_Timer.After(0.3, function()
                if HouseEditorFrame and not self.editorFrameHooked then
                    DreamHouse.Hooks.Editor:HookEditorFrame(HouseEditorFrame)
                    self.editorFrameHooked = true
                    DreamHouse.Debug:Log("Hooks", "HouseEditorFrame jetzt gehookt!", "SUCCESS")
                end
            end)
        end
    end, self)
    
    -- Falls Frame bereits existiert (z.B. nach /reload im Editor)
    if HouseEditorFrame then
        self:HookEditorFrame(HouseEditorFrame)
        self.editorFrameHooked = true
    end
    
    isApplied = true
end

function DreamHouse.Hooks.Editor:HookEditorFrame(editorFrame)
    DreamHouse.Debug:Log("Hooks", "HouseEditorFrame gefunden", "SUCCESS")
    
    -- Funktion um Features zu aktivieren
    local function ActivateEditorFeatures()
        DreamHouse.Debug:Log("Hooks", "Aktiviere Editor-Features...", "INFO")
        
        -- Stats-Panel Daten aktualisieren (falls sichtbar)
        if DreamHouse.StatsPanel and DreamHouse.StatsPanel.Refresh then
            DreamHouse.StatsPanel:Refresh()
            DreamHouse.Debug:Log("Hooks", "StatsPanel aktualisiert", "DEBUG")
        end
        
        DreamHouse.Events:Fire("DREAMHOUSE_EDITOR_OPENED")
    end
    
    -- Funktion um Features zu deaktivieren
    local function DeactivateEditorFeatures()
        DreamHouse.Debug:Log("Hooks", "Deaktiviere Editor-Features...", "INFO")
        DreamHouse.Events:Fire("DREAMHOUSE_EDITOR_CLOSED")
    end
    
    -- OnShow Hook für zukünftige Opens
    DreamHouse.Utils:SafeHookScript(editorFrame, "OnShow", function()
        DreamHouse.Debug:Log("Hooks", "Editor-Frame OnShow Event", "DEBUG")
        ActivateEditorFeatures()
    end)
    
    -- OnHide Hook
    DreamHouse.Utils:SafeHookScript(editorFrame, "OnHide", function()
        DreamHouse.Debug:Log("Hooks", "Editor-Frame OnHide Event", "DEBUG")
        DeactivateEditorFeatures()
    end)
    
    -- WICHTIG: Wenn Editor bereits sichtbar ist, Features JETZT aktivieren!
    if editorFrame:IsShown() then
        DreamHouse.Debug:Log("Hooks", "Editor bereits sichtbar - aktiviere Features sofort!", "INFO")
        ActivateEditorFeatures()
    end
    
    -- Mode-Change Hook über das Mixin
    if HouseEditorFrameMixin then
        hooksecurefunc(HouseEditorFrameMixin, "OnActiveModeChanged", function(self, newMode)
            DreamHouse.Debug:Log("Hooks", "Modus gewechselt zu: " .. DreamHouse.Utils:GetEditorModeName(newMode), "INFO")
            DreamHouse.Events:Fire("DREAMHOUSE_MODE_CHANGED", newMode)
        end)
        
        DreamHouse.Debug:Log("Hooks", "HouseEditorFrameMixin.OnActiveModeChanged gehookt", "SUCCESS")
    end
end

function DreamHouse.Hooks.Editor:HookControlsFrame(controlsFrame)
    DreamHouse.Debug:Log("Hooks", "HousingControlsFrame gefunden", "SUCCESS")
    
    -- OnShow Hook
    DreamHouse.Utils:SafeHookScript(controlsFrame, "OnShow", function()
        DreamHouse.Debug:Log("Hooks", "Controls-Frame sichtbar", "DEBUG")
        DreamHouse.Events:Fire("DREAMHOUSE_CONTROLS_SHOWN")
    end)
    
    -- OnHide Hook
    DreamHouse.Utils:SafeHookScript(controlsFrame, "OnHide", function()
        DreamHouse.Debug:Log("Hooks", "Controls-Frame versteckt", "DEBUG")
        DreamHouse.Events:Fire("DREAMHOUSE_CONTROLS_HIDDEN")
    end)
end

function DreamHouse.Hooks.Editor:HookModeFrames()
    -- BasicDecor Mode Hooks
    if HouseEditorBasicDecorModeMixin then
        -- Decor ausgewählt
        hooksecurefunc(HouseEditorBasicDecorModeMixin, "OnTargetSelected", function(self)
            DreamHouse.Debug:Log("Hooks", "Decor ausgewählt (Basic)", "DEBUG")
            
            local decorInfo = C_HousingBasicMode.GetSelectedDecorInfo()
            DreamHouse.Events:Fire("DREAMHOUSE_DECOR_SELECTED", decorInfo, "Basic")
        end)
        
        hooksecurefunc(HouseEditorBasicDecorModeMixin, "OnTargetUnselected", function(self)
            DreamHouse.Debug:Log("Hooks", "Decor abgewählt (Basic)", "DEBUG")
            DreamHouse.Events:Fire("DREAMHOUSE_DECOR_DESELECTED", "Basic")
        end)
        
        DreamHouse.Debug:Log("Hooks", "BasicDecor-Mode Hooks angewendet", "SUCCESS")
    end
    
    -- ExpertDecor Mode Hooks
    if HouseEditorExpertDecorModeMixin then
        -- Diese werden über Events behandelt
        DreamHouse.Debug:Log("Hooks", "ExpertDecor-Mode Events werden überwacht", "DEBUG")
    end
    
    -- Layout Mode Hooks
    if HouseEditorLayoutModeMixin then
        hooksecurefunc(HouseEditorLayoutModeMixin, "OnShow", function(self)
            DreamHouse.Debug:Log("Hooks", "Layout-Modus aktiviert", "INFO")
            DreamHouse.Events:Fire("DREAMHOUSE_LAYOUT_MODE_ENTERED")
            
            -- Preset-Manager Button anzeigen
            if DreamHouse.PresetManager then
                DreamHouse.PresetManager:ShowLayoutButton()
            end
        end)
        
        hooksecurefunc(HouseEditorLayoutModeMixin, "OnHide", function(self)
            DreamHouse.Debug:Log("Hooks", "Layout-Modus verlassen", "INFO")
            DreamHouse.Events:Fire("DREAMHOUSE_LAYOUT_MODE_EXITED")
            
            if DreamHouse.PresetManager then
                DreamHouse.PresetManager:HideLayoutButton()
            end
        end)
        
        DreamHouse.Debug:Log("Hooks", "Layout-Mode Hooks angewendet", "SUCCESS")
    end
end

-- Hook für Decor-Platzierung (für Statistics)
function DreamHouse.Hooks.Editor:HookDecorPlacement()
    -- Diese Events werden bereits in Core.lua behandelt
    -- Hier nur für erweiterte Tracking-Funktionen
    
    DreamHouse.Events:Register("DREAMHOUSE_DECOR_PLACED", function(self, decorGUID, size, isNew)
        if isNew and DreamHouse.StatsPanel then
            DreamHouse.StatsPanel:OnDecorPlaced()
        end
    end, self)
    
    DreamHouse.Events:Register("DREAMHOUSE_DECOR_REMOVED", function(self, decorGUID)
        if DreamHouse.StatsPanel then
            DreamHouse.StatsPanel:OnDecorRemoved()
        end
    end, self)
end

-- Modul registrieren
DreamHouse:RegisterModule("EditorHooks", DreamHouse.Hooks.Editor)
