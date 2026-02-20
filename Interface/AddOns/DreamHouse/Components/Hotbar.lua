--[[
    DreamHouse - Hotbar
    Drag & Drop Schnellzugriff-Leiste für häufig genutzte Items
]]

local addonName, DreamHouse = ...

-- Localization shortcut
local L = DreamHouse.L

DreamHouse.Hotbar = {}

local NUM_SLOTS = 10
local SLOT_SIZE = 40
local SLOT_SPACING = 4

local hotbarTopFrame = nil    -- Obere Hälfte (Slots 1-5)
local hotbarBottomFrame = nil -- Untere Hälfte (Slots 6-10)
local slots = {}
local isDragging = false
local dragData = nil
local dragIconFrame = nil  -- Visuelles Drag-Icon
local placingFromHotbar = false  -- Flag: Platzierung wurde von Hotbar gestartet (verhindert Flackern)
local placingResetTimerID = 0    -- Timer-ID um alte Reset-Timer zu invalidieren

-- Drag-Icon erstellen (folgt dem Cursor)
function DreamHouse.Hotbar:CreateDragIcon()
    -- Falls Frame existiert aber icon fehlt, neu erstellen
    if dragIconFrame and not dragIconFrame.iconTexture then
        dragIconFrame:Hide()
        dragIconFrame = nil
    end
    
    if dragIconFrame then return dragIconFrame end
    
    -- Einfacher Frame ohne kompliziertes Backdrop
    dragIconFrame = CreateFrame("Frame", "DreamHouseDragIcon", UIParent)
    dragIconFrame:SetSize(SLOT_SIZE, SLOT_SIZE)
    dragIconFrame:SetFrameStrata("TOOLTIP")
    dragIconFrame:SetFrameLevel(9999)
    
    -- Hintergrund (einfache Farbe)
    dragIconFrame.bg = dragIconFrame:CreateTexture(nil, "BACKGROUND")
    dragIconFrame.bg:SetAllPoints()
    dragIconFrame.bg:SetColorTexture(0, 0, 0, 0.8)
    
    -- Dezenter Rand (1px, halbtransparent)
    dragIconFrame.borderTop = dragIconFrame:CreateTexture(nil, "BORDER")
    dragIconFrame.borderTop:SetColorTexture(0.3, 0.8, 0.3, 0.6)
    dragIconFrame.borderTop:SetPoint("TOPLEFT", 0, 0)
    dragIconFrame.borderTop:SetPoint("TOPRIGHT", 0, 0)
    dragIconFrame.borderTop:SetHeight(1)
    
    dragIconFrame.borderBottom = dragIconFrame:CreateTexture(nil, "BORDER")
    dragIconFrame.borderBottom:SetColorTexture(0.3, 0.8, 0.3, 0.6)
    dragIconFrame.borderBottom:SetPoint("BOTTOMLEFT", 0, 0)
    dragIconFrame.borderBottom:SetPoint("BOTTOMRIGHT", 0, 0)
    dragIconFrame.borderBottom:SetHeight(1)
    
    dragIconFrame.borderLeft = dragIconFrame:CreateTexture(nil, "BORDER")
    dragIconFrame.borderLeft:SetColorTexture(0.3, 0.8, 0.3, 0.6)
    dragIconFrame.borderLeft:SetPoint("TOPLEFT", 0, 0)
    dragIconFrame.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    dragIconFrame.borderLeft:SetWidth(1)
    
    dragIconFrame.borderRight = dragIconFrame:CreateTexture(nil, "BORDER")
    dragIconFrame.borderRight:SetColorTexture(0.3, 0.8, 0.3, 0.6)
    dragIconFrame.borderRight:SetPoint("TOPRIGHT", 0, 0)
    dragIconFrame.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    dragIconFrame.borderRight:SetWidth(1)
    
    -- Icon Texture
    dragIconFrame.iconTexture = dragIconFrame:CreateTexture(nil, "ARTWORK")
    dragIconFrame.iconTexture:SetSize(SLOT_SIZE - 8, SLOT_SIZE - 8)
    dragIconFrame.iconTexture:SetPoint("CENTER")
    dragIconFrame.iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- OnUpdate: Folge dem Cursor mit Klick-Offset
    dragIconFrame:SetScript("OnUpdate", function(self)
        if not self:IsShown() then return end
        
        -- Cursor-Position holen
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        local screenX = x / scale
        local screenY = y / scale
        
        -- Klick-Offset anwenden (wo im Icon wurde geklickt)
        local offsetX = dragData and dragData.offsetX or 0
        local offsetY = dragData and dragData.offsetY or 0
        
        local parent = self:GetParent()
        local halfSize = SLOT_SIZE / 2
        
        if parent and parent ~= UIParent and parent.GetLeft then
            -- Parent ist z.B. HouseEditorFrame - berechne relative Position
            local parentLeft = parent:GetLeft() or 0
            local parentBottom = parent:GetBottom() or 0
            
            -- Position so dass Cursor an der geklickten Stelle bleibt
            local relX = screenX - parentLeft - offsetX
            local relY = screenY - parentBottom - offsetY
            
            self:ClearAllPoints()
            self:SetPoint("CENTER", parent, "BOTTOMLEFT", relX, relY)
        else
            -- Fallback: direkt zu UIParent
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", screenX - offsetX, screenY - offsetY)
        end
    end)
    
    dragIconFrame:Hide()
    
    DreamHouse.Debug:Log("Hotbar", "DragIcon Frame erstellt", "DEBUG")
    
    return dragIconFrame
end

-- Drag-Icon anzeigen
function DreamHouse.Hotbar:ShowDragIcon(icon)
    -- Frame erstellen falls nicht vorhanden
    if not dragIconFrame or not dragIconFrame.iconTexture then
        self:CreateDragIcon()
    end
    
    -- Sicherheitscheck
    if not dragIconFrame or not dragIconFrame.iconTexture then
        DreamHouse.Debug:Log("Hotbar", "DragIcon konnte nicht erstellt werden!", "ERROR")
        return
    end
    
    -- Icon setzen (mit Fallback)
    local textureID = icon or 134400  -- 134400 = Fragezeichen
    dragIconFrame.iconTexture:SetTexture(textureID)
    
    -- WICHTIG: Parent muss HouseEditorFrame sein wenn aktiv!
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
        dragIconFrame:SetParent(HouseEditorFrame)
    else
        dragIconFrame:SetParent(UIParent)
    end
    
    dragIconFrame:SetFrameStrata("TOOLTIP")
    dragIconFrame:SetFrameLevel(9999)
    dragIconFrame:Show()
    dragIconFrame:SetAlpha(1)
    dragIconFrame:Raise()
    
    DreamHouse.Debug:Log("Hotbar", "ShowDragIcon: " .. tostring(textureID) .. ", Parent: " .. (dragIconFrame:GetParent():GetName() or "?"), "SUCCESS")
end

-- Drag-Icon verstecken
function DreamHouse.Hotbar:HideDragIcon()
    if dragIconFrame then
        dragIconFrame:Hide()
    end
end

-- Hotbar erstellen (ZWEI SEPARATE FRAMES - oben und unten am Storage)
local SLOTS_TOP = 5      -- Slots 1-5 (obere rechte Ecke)
local SLOTS_BOTTOM = 5   -- Slots 6-10 (untere rechte Ecke)

function DreamHouse.Hotbar:Create()
    if hotbarTopFrame then return end
    
    local PADDING = 6  -- Abstand oben/unten zwischen Slots und Rand
    local frameWidth = SLOT_SIZE + (SLOT_SPACING * 2) + 6
    local topHeight = (SLOT_SIZE * SLOTS_TOP) + (SLOT_SPACING * (SLOTS_TOP - 1)) + (PADDING * 2)
    local bottomHeight = (SLOT_SIZE * SLOTS_BOTTOM) + (SLOT_SPACING * (SLOTS_BOTTOM - 1)) + (PADDING * 2)
    
    -- Sauberes, dunkles Design passend zum WoW UI
    local backdropSettings = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    }
    
    -- ============ OBERER FRAME (Slots 1-5) ============
    hotbarTopFrame = CreateFrame("Frame", "DreamHouseHotbarTop", UIParent, "BackdropTemplate")
    hotbarTopFrame:SetSize(frameWidth, topHeight)
    hotbarTopFrame:SetPoint("RIGHT", UIParent, "RIGHT", -20, 100)
    hotbarTopFrame:SetBackdrop(backdropSettings)
    hotbarTopFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    hotbarTopFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    hotbarTopFrame:SetFrameStrata("DIALOG")
    
    -- Kein Titel, kein Schließen-Button - clean und kompakt
    
    -- Obere Slots (1-5) - mit Padding oben
    for i = 1, SLOTS_TOP do
        local slot = self:CreateSlot(hotbarTopFrame, i)
        local yOffset = -PADDING - ((i - 1) * (SLOT_SIZE + SLOT_SPACING))
        slot:SetPoint("TOP", hotbarTopFrame, "TOP", 0, yOffset)
        slots[i] = slot
        
        local savedEntryID = DreamHouse.Settings:GetHotbarSlot(i)
        if savedEntryID then
            self:SetSlotItem(i, savedEntryID)
        end
    end
    
    hotbarTopFrame:Hide()
    
    -- ============ UNTERER FRAME (Slots 6-10) ============
    hotbarBottomFrame = CreateFrame("Frame", "DreamHouseHotbarBottom", UIParent, "BackdropTemplate")
    hotbarBottomFrame:SetSize(frameWidth, bottomHeight)
    hotbarBottomFrame:SetPoint("RIGHT", UIParent, "RIGHT", -20, -100)
    hotbarBottomFrame:SetBackdrop(backdropSettings)
    hotbarBottomFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    hotbarBottomFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    hotbarBottomFrame:SetFrameStrata("DIALOG")
    
    -- Untere Slots (6-10) - mit Padding unten, von unten nach oben
    for i = SLOTS_TOP + 1, NUM_SLOTS do
        local slot = self:CreateSlot(hotbarBottomFrame, i)
        local localIndex = i - SLOTS_TOP
        -- Von unten nach oben positionieren
        local yOffset = PADDING + ((SLOTS_BOTTOM - localIndex) * (SLOT_SIZE + SLOT_SPACING))
        slot:SetPoint("BOTTOM", hotbarBottomFrame, "BOTTOM", 0, yOffset)
        slots[i] = slot
        
        local savedEntryID = DreamHouse.Settings:GetHotbarSlot(i)
        if savedEntryID then
            self:SetSlotItem(i, savedEntryID)
        end
    end
    
    hotbarBottomFrame:Hide()
    
    DreamHouse.Debug:Log("Hotbar", "Hotbar erstellt: 2 Frames mit " .. NUM_SLOTS .. " Slots", "SUCCESS")
end

-- Einzelnen Slot erstellen (Clean Style)
function DreamHouse.Hotbar:CreateSlot(parent, slotIndex)
    local slot = CreateFrame("Button", "DreamHouseHotbarSlot" .. slotIndex, parent, "BackdropTemplate")
    slot:SetSize(SLOT_SIZE, SLOT_SIZE)
    slot:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    slot:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    slot:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    
    slot.slotIndex = slotIndex
    slot.entryID = nil
    slot.entryInfo = nil
    
    -- Icon
    slot.icon = slot:CreateTexture(nil, "ARTWORK")
    slot.icon:SetSize(SLOT_SIZE - 8, SLOT_SIZE - 8)
    slot.icon:SetPoint("CENTER")
    slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    slot.icon:Hide()
    
    -- Slot-Nummer (dezent, unten rechts)
    slot.number = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot.number:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -2, 2)
    slot.number:SetText(slotIndex == 10 and "0" or tostring(slotIndex))
    slot.number:SetTextColor(0.6, 0.6, 0.6, 0.8)
    
    -- Quantity
    slot.quantity = slot:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot.quantity:SetPoint("TOPLEFT", slot, "TOPLEFT", 2, -2)
    slot.quantity:SetTextColor(1, 1, 1)
    slot.quantity:Hide()
    
    -- Highlight (dezent)
    slot.highlight = slot:CreateTexture(nil, "HIGHLIGHT")
    slot.highlight:SetAllPoints()
    slot.highlight:SetColorTexture(1, 1, 1, 0.15)
    
    -- Drop-Highlight für Drag&Drop
    slot.dropHighlight = slot:CreateTexture(nil, "OVERLAY")
    slot.dropHighlight:SetAllPoints()
    slot.dropHighlight:SetColorTexture(0, 0.8, 0, 0.3)
    slot.dropHighlight:Hide()
    
    -- Events
    slot:RegisterForDrag("LeftButton")
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    slot:SetScript("OnClick", function(self, button)
        DreamHouse.Debug:Log("Hotbar", "Slot " .. self.slotIndex .. " geklickt: " .. button, "DEBUG")
        
        if button == "LeftButton" then
            if self.entryID then
                -- WICHTIG: Flag SOFORT setzen um Flackern zu verhindern!
                -- Das Storage kann zwischen Klick und UseSlot OnShow triggern
                placingFromHotbar = true
                DreamHouse.Hotbar:Hide()  -- Sofort verstecken
                
                -- Item platzieren - mit Verzögerung damit der Klick nicht als Platzierung gilt
                DreamHouse.Debug:Log("Hotbar", "Linksklick -> UseSlot " .. self.slotIndex .. " (verzögert)", "DEBUG")
                C_Timer.After(0.1, function()
                    DreamHouse.Hotbar:UseSlot(self.slotIndex)
                end)
            else
                DreamHouse.Debug:Log("Hotbar", "Slot " .. self.slotIndex .. " ist leer", "DEBUG")
            end
        elseif button == "RightButton" then
            -- Rechtsklick = Kontextmenü nur wenn Slot belegt ist
            if self.entryID then
                DreamHouse.Hotbar:ShowSlotContextMenu(self)
            end
        end
    end)
    
    slot:SetScript("OnEnter", function(self)
        -- Drop-Highlight anzeigen wenn wir von einem ANDEREN Slot draggen
        if isDragging and dragData and dragData.fromSlot ~= self.slotIndex then
            self.dropHighlight:Show()
            -- Keinen Tooltip während Drag
            return
        end
        
        -- Tooltip anzeigen (links vom Slot da vertikal)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        
            if self.entryInfo or self.entryID then
            GameTooltip:SetText(self.itemName or self.entryInfo and self.entryInfo.name or "Item")
            
            local qty = self.entryInfo and self.entryInfo.quantity or 0
            if qty > 0 then
                GameTooltip:AddLine(L["In possession"] .. ": |cff00ff00" .. qty .. "|r", 1, 1, 1)
            else
                GameTooltip:AddLine(L["In possession"] .. ": |cffff0000" .. L["Not available"] .. "|r", 1, 1, 1)
            end
            
            -- Hotkey anzeigen
            local hotkeyNum = self.slotIndex == 10 and "0" or tostring(self.slotIndex)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff88ccffCtrl+" .. hotkeyNum .. ":|r " .. L["Quick place"], 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cff00ff00" .. L["Left-click: Place"] .. "|r", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cffffcc00" .. L["Right-click: Menu"] .. "|r", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cff88ccff" .. L["Drag: Rearrange"] .. "|r", 0.7, 0.7, 0.7)
        else
            GameTooltip:SetText(L.Format("Empty Slot X", self.slotIndex))
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Hotbar empty slot hint"], 0.6, 0.6, 0.6, true)
        end
        
        GameTooltip:Show()
    end)
    
    slot:SetScript("OnLeave", function(self)
        -- Highlight immer verstecken wenn Maus den Slot verlässt
        self.dropHighlight:Hide()
        GameTooltip:Hide()
    end)
    
    -- MouseDown: Speichere Klick-Position für späteren Drag-Offset
    slot:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and self.entryID then
            -- Klick-Position relativ zum Slot-Zentrum speichern
            local cursorX, cursorY = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            local slotLeft = self:GetLeft() or 0
            local slotBottom = self:GetBottom() or 0
            local slotWidth = self:GetWidth() or SLOT_SIZE
            local slotHeight = self:GetHeight() or SLOT_SIZE
            
            -- Offset vom Zentrum des Slots berechnen
            local clickX = (cursorX / scale) - slotLeft
            local clickY = (cursorY / scale) - slotBottom
            
            self.dragOffsetX = clickX - (slotWidth / 2)
            self.dragOffsetY = clickY - (slotHeight / 2)
        end
    end)
    
    -- Drag & Drop mit Halten + Ziehen
    slot:SetScript("OnDragStart", function(self)
        if self.entryID then
            -- Item aus Hotbar ziehen
            isDragging = true
            
            -- Verwende den gespeicherten Klick-Offset vom MouseDown
            local offsetX = self.dragOffsetX or 0
            local offsetY = self.dragOffsetY or 0
            
            dragData = { 
                fromSlot = self.slotIndex, 
                entryID = self.entryID,
                offsetX = offsetX,
                offsetY = offsetY
            }
            
            -- Visuelles Feedback: Slot ausblenden während Drag
            self:SetAlpha(0.4)
            self:SetBackdropBorderColor(1, 1, 0, 1) -- Gelb (Quelle)
            
            -- Drag-Icon anzeigen - Icon direkt von der Slot-Textur holen!
            local icon = self.icon:GetTexture()
            DreamHouse.Hotbar:ShowDragIcon(icon)
            
            DreamHouse.Debug:Log("Hotbar", "Drag von Slot " .. self.slotIndex .. ", Offset: " .. math.floor(offsetX) .. "," .. math.floor(offsetY), "DEBUG")
        end
    end)
    
    slot:SetScript("OnDragStop", function(self)
        -- Prüfen ob wir über einem anderen Slot sind
        if dragData and dragData.fromSlot then
            -- GetMouseFoci() gibt eine Tabelle zurück (WoW 11.x)
            local mouseFoci = GetMouseFoci and GetMouseFoci() or {}
            local targetFrame = mouseFoci[1]
            
            -- Prüfen ob Ziel ein Hotbar-Slot ist
            if targetFrame and targetFrame.slotIndex and targetFrame.slotIndex ~= dragData.fromSlot then
                -- Slots tauschen!
                DreamHouse.Hotbar:SwapSlots(dragData.fromSlot, targetFrame.slotIndex)
                DreamHouse.Debug:Log("Hotbar", "Drop auf Slot " .. targetFrame.slotIndex .. " - getauscht!", "SUCCESS")
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
            else
                DreamHouse.Debug:Log("Hotbar", "Drop außerhalb eines Slots", "DEBUG")
            end
        end
        
        -- Visuelles Feedback zurücksetzen
        self:SetAlpha(1)
        if self.entryID then
            local qty = self.entryInfo and self.entryInfo.quantity or 0
            if qty > 0 then
                self:SetBackdropBorderColor(0.3, 0.6, 0.3, 1)
            else
                self:SetBackdropBorderColor(0.6, 0.3, 0.3, 1)
            end
        else
            self:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
        end
        
        -- Alle Slots zurücksetzen (falls Highlight aktiv)
        for i, s in ipairs(slots) do
            s.dropHighlight:Hide()
        end
        
        -- Drag-Icon verstecken
        DreamHouse.Hotbar:HideDragIcon()
        
        isDragging = false
        dragData = nil
        
        DreamHouse.Debug:Log("Hotbar", "Drag beendet", "DEBUG")
    end)
    
    slot:SetScript("OnReceiveDrag", function(self)
        if dragData and dragData.fromSlot then
            -- Item von anderem Hotbar-Slot
            if dragData.fromSlot ~= self.slotIndex then
                DreamHouse.Hotbar:SwapSlots(dragData.fromSlot, self.slotIndex)
                DreamHouse.Debug:Log("Hotbar", "Slots getauscht: " .. dragData.fromSlot .. " <-> " .. self.slotIndex, "SUCCESS")
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_APPEARANCE_CHANGE)
            end
            
            -- Quell-Slot visuell zurücksetzen
            local sourceSlot = slots[dragData.fromSlot]
            if sourceSlot then
                sourceSlot:SetAlpha(1)
                sourceSlot:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
            end
        elseif DreamHouse.Hotbar.pendingDragItem then
            -- Item aus Katalog (falls wir das später aktivieren)
            DreamHouse.Hotbar:SetSlotItem(self.slotIndex, DreamHouse.Hotbar.pendingDragItem)
            DreamHouse.Hotbar.pendingDragItem = nil
        end
        
        -- Drag-Icon verstecken
        DreamHouse.Hotbar:HideDragIcon()
        
        isDragging = false
        dragData = nil
    end)
    
    return slot
end

-- Item in Slot setzen
function DreamHouse.Hotbar:SetSlotItem(slotIndex, entryID)
    local slot = slots[slotIndex]
    if not slot then return end
    
    slot.entryID = entryID
    
    -- Entry-Info holen
    local entryInfo = DreamHouse.Utils:GetCatalogEntryInfo(entryID)
    slot.entryInfo = entryInfo
    
    DreamHouse.Debug:Log("Hotbar", "SetSlotItem: " .. tostring(slotIndex) .. ", entryInfo: " .. tostring(entryInfo ~= nil), "DEBUG")
    
    -- Icon ermitteln - mit mehreren Fallbacks
    local icon = nil
    
    -- 1. Versuche aus entryInfo
    if entryInfo then
        icon = entryInfo.icon or entryInfo.iconID
    end
    
    -- 2. Versuche über Decor API
    if not icon and C_HousingDecor and C_HousingDecor.GetDecorIcon then
        local recordID = entryID.recordID or entryID
        local success, result = pcall(C_HousingDecor.GetDecorIcon, recordID)
        if success and result then
            icon = result
        end
    end
    
    -- 3. Nutze gecachtes Icon falls vorhanden
    if not icon and slot.cachedIcon then
        icon = slot.cachedIcon
        DreamHouse.Debug:Log("Hotbar", "Nutze gecachtes Icon für Slot " .. slotIndex, "DEBUG")
    end
    
    -- Icon cachen wenn gefunden (für spätere Refreshes wenn quantity=0)
    if icon then
        slot.cachedIcon = icon
        slot.icon:SetTexture(icon)
        slot.icon:Show()
        DreamHouse.Debug:Log("Hotbar", "Icon gesetzt: " .. tostring(icon), "DEBUG")
    else
        -- Letzter Fallback: Fragezeichen
        slot.icon:SetTexture(134400) -- Question mark
        slot.icon:Show()
        DreamHouse.Debug:Log("Hotbar", "Kein Icon gefunden, nutze Fallback", "WARN")
    end
    
    -- Quantity ermitteln
    local qty = 0
    if entryInfo then
        qty = entryInfo.quantity or 0
    end
    
    -- Quantity anzeigen
    if qty > 1 then
        slot.quantity:SetText(qty)
        slot.quantity:Show()
    elseif qty == 1 then
        slot.quantity:Hide()  -- Bei 1 keine Zahl anzeigen
    else
        -- Bei 0: "0" anzeigen damit man sieht dass nichts mehr da ist
        slot.quantity:SetText("0")
        slot.quantity:SetTextColor(1, 0.3, 0.3)  -- Rot für 0
        slot.quantity:Show()
    end
    
    -- Border-Farbe basierend auf Verfügbarkeit
    if qty > 0 then
        slot:SetBackdropBorderColor(0.3, 0.6, 0.3, 1) -- Grün (verfügbar)
        slot.quantity:SetTextColor(1, 1, 1)  -- Weiß für normale Menge
    else
        slot:SetBackdropBorderColor(0.6, 0.3, 0.3, 1) -- Rot (nicht verfügbar)
    end
    
    -- Name speichern für Tooltip (auch cachen)
    if entryInfo and entryInfo.name then
        slot.itemName = entryInfo.name
        slot.cachedName = entryInfo.name
    elseif slot.cachedName then
        slot.itemName = slot.cachedName
    else
        slot.itemName = "Unbekannt"
    end
    
    -- In SavedVariables speichern
    DreamHouse.Settings:SetHotbarSlot(slotIndex, entryID)
    
    DreamHouse.Debug:Log("Hotbar", "Slot " .. slotIndex .. " gesetzt (qty: " .. qty .. ")", "DEBUG")
end

-- Slot leeren
function DreamHouse.Hotbar:ClearSlot(slotIndex)
    local slot = slots[slotIndex]
    if not slot then return end
    
    slot.entryID = nil
    slot.entryInfo = nil
    slot.cachedIcon = nil    -- Cache löschen
    slot.cachedName = nil    -- Cache löschen
    slot.itemName = nil
    slot.icon:Hide()
    slot.quantity:Hide()
    slot.quantity:SetTextColor(1, 1, 1)  -- Farbe zurücksetzen
    slot:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)  -- Zurück zu default
    
    DreamHouse.Settings:SetHotbarSlot(slotIndex, nil)
    
    DreamHouse.Debug:Log("Hotbar", "Slot " .. slotIndex .. " geleert", "DEBUG")
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
end

-- Slots tauschen
function DreamHouse.Hotbar:SwapSlots(fromSlot, toSlot, skipCollectionSync)
    local fromEntry = slots[fromSlot].entryID
    local toEntry = slots[toSlot].entryID
    
    if toEntry then
        self:SetSlotItem(fromSlot, toEntry)
    else
        self:ClearSlot(fromSlot)
    end
    
    if fromEntry then
        self:SetSlotItem(toSlot, fromEntry)
    end
    
    DreamHouse.Debug:Log("Hotbar", "Slots " .. fromSlot .. " <-> " .. toSlot .. " getauscht", "DEBUG")
    
    -- Wenn KHM aktiv ist, auch die Kollektion synchronisieren (außer wenn skipCollectionSync gesetzt)
    if not skipCollectionSync and DreamHouse.Hooks and DreamHouse.Hooks.Storage then
        local isCHMActive = DreamHouse.Hooks.Storage.collectionHotbarModeActive
        local activeCollectionID = DreamHouse.Hooks.Storage.activeCollectionID
        
        if isCHMActive and activeCollectionID and DreamHouse.Collections then
            -- Nur die ersten 10 Slots sind mit der Kollektion verknüpft
            if fromSlot <= 10 and toSlot <= 10 then
                DreamHouse.Collections:SwapItemsInCollection(activeCollectionID, fromSlot, toSlot)
                DreamHouse.Debug:Log("Hotbar", "Kollektion synchronisiert: " .. fromSlot .. " <-> " .. toSlot, "SUCCESS")
                
                -- UI aktualisieren falls Set-Ansicht offen ist
                if DreamHouse.Hooks.Storage.currentCollection and 
                   DreamHouse.Hooks.Storage.currentCollection.id == activeCollectionID then
                    -- Kollektion neu laden aus DB
                    DreamHouse.Hooks.Storage.currentCollection = DreamHouse.Collections:GetCollectionByID(activeCollectionID)
                    DreamHouse.Hooks.Storage:RenderCollectionDetails(DreamHouse.Hooks.Storage.currentCollection)
                end
            end
        end
    end
end

-- Kontextmenü für Hotbar-Slot (nur für belegte Slots)
function DreamHouse.Hotbar:ShowSlotContextMenu(slot)
    if not slot or not slot.entryID then return end -- Nur für belegte Slots
    
    -- Prüfen ob KHM aktiv ist
    local isCHMActive = DreamHouse.Hooks and DreamHouse.Hooks.Storage and DreamHouse.Hooks.Storage.collectionHotbarModeActive
    
    MenuUtil.CreateContextMenu(slot, function(owner, rootDescription)
        rootDescription:SetTag("MENU_DREAMHOUSE_HOTBAR_SLOT")
        
        -- Slot leeren
        local removeBtn = rootDescription:CreateButton("|cffff6666" .. L["Remove from Hotbar"] .. "|r", function()
            if isCHMActive then return end
            DreamHouse.Hotbar:ClearSlot(slot.slotIndex)
        end)
        -- Ausgegraut wenn KHM aktiv
        if isCHMActive then
            removeBtn:SetEnabled(false)
            removeBtn:SetTooltip(function(tooltip, elementDescription)
                tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
                tooltip:SetFrameLevel(9999)
                GameTooltip_SetTitle(tooltip, L["CHM active - disable first"])
            end)
        end
        
        -- Trennlinie
        rootDescription:CreateDivider()
        
        -- Alle Slots leeren
        local clearAllBtn = rootDescription:CreateButton("|cffff3333" .. L["Clear all slots"] .. "|r", function()
            if isCHMActive then return end
            StaticPopup_Show("DREAMHOUSE_CLEAR_HOTBAR")
        end)
        -- Ausgegraut wenn KHM aktiv
        if isCHMActive then
            clearAllBtn:SetEnabled(false)
            clearAllBtn:SetTooltip(function(tooltip, elementDescription)
                tooltip:SetFrameStrata("FULLSCREEN_DIALOG")
                tooltip:SetFrameLevel(9999)
                GameTooltip_SetTitle(tooltip, L["CHM active - disable first"])
            end)
        end
    end)
    
    DreamHouse.Debug:Log("Hotbar", "Kontextmenü für Slot " .. slot.slotIndex .. " geöffnet", "DEBUG")
end

-- Popup für "Alle Slots leeren"
StaticPopupDialogs["DREAMHOUSE_CLEAR_HOTBAR"] = {
    text = DreamHouse.L["Clear all items from hotbar?"],
    button1 = DreamHouse.L["Yes"],
    button2 = DreamHouse.L["No"],
    OnAccept = function()
        for i = 1, NUM_SLOTS do
            DreamHouse.Hotbar:ClearSlot(i)
        end
        DreamHouse.Debug:Log("Hotbar", "Alle Slots geleert", "SUCCESS")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Slot verwenden (Item platzieren)
function DreamHouse.Hotbar:UseSlot(slotIndex)
    local slot = slots[slotIndex]
    if not slot then 
        DreamHouse.Debug:Log("Hotbar", "Slot " .. slotIndex .. " existiert nicht!", "ERROR")
        return 
    end
    
    if not slot.entryID then
        DreamHouse.Debug:Log("Hotbar", "Slot " .. slotIndex .. " ist leer!", "WARN")
        return
    end
    
    DreamHouse.Debug:Log("Hotbar", "UseSlot " .. slotIndex .. " - entryID: " .. tostring(slot.entryID), "DEBUG")
    
    -- Prüfen ob Editor aktiv
    local editorActive = DreamHouse.Utils:IsEditorActive()
    DreamHouse.Debug:Log("Hotbar", "Editor aktiv: " .. tostring(editorActive), "DEBUG")
    
    if not editorActive then
        DreamHouse.Debug:Log("Hotbar", "Editor nicht aktiv", "WARN")
        return
    end
    
    -- WICHTIG: Flag setzen BEVOR wir verstecken!
    -- Diese Flag verhindert dass OnStorageShown/OnStorageCollapsed die Hotbar wieder einblendet
    -- während wir zwischen Items wechseln (kurzes Timing-Fenster wo IsPlacingDecor() false ist)
    placingFromHotbar = true
    
    -- Timer-ID erhöhen um alte Timer zu invalidieren
    placingResetTimerID = placingResetTimerID + 1
    local currentTimerID = placingResetTimerID
    
    -- Polling-Funktion die prüft ob Platzierung beendet ist
    -- Wird alle 0.2s aufgerufen bis Platzierung beendet oder neuer UseSlot
    local function CheckPlacingEnded()
        -- Abbrechen wenn neuer UseSlot aufgerufen wurde
        if currentTimerID ~= placingResetTimerID then return end
        
        -- Prüfen ob Platzierung beendet
        if not DreamHouse.Hotbar:IsPlacingDecor() then
            -- Platzierung beendet! Flag zurücksetzen und Hotbar anzeigen
            placingFromHotbar = false
            DreamHouse.Debug:Log("Hotbar", "Platzierung beendet (Polling) - zeige Hotbar", "DEBUG")
            
            -- Hotbar an der richtigen Position anzeigen
            if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
                local storageFrame = DreamHouse.Hotbar.storagePanel
                if storageFrame and storageFrame:IsShown() then
                    -- Storage ist sichtbar -> Position am Storage
                    DreamHouse.Hotbar:PositionAtStorage()
                else
                    -- Storage ist eingeklappt -> Position am Rand
                    DreamHouse.Hotbar:PositionAtScreenEdge()
                end
                if hotbarTopFrame then hotbarTopFrame:Show() end
                if hotbarBottomFrame then hotbarBottomFrame:Show() end
            end
            return
        end
        
        -- Noch am Platzieren -> nochmal prüfen nach 0.2s
        C_Timer.After(0.2, CheckPlacingEnded)
    end
    
    -- Starte Polling nach kurzer Verzögerung (damit StartPlacingNewDecor Zeit hat)
    C_Timer.After(0.3, CheckPlacingEnded)
    
    -- WICHTIG: Hotbar SOFORT verstecken um Flackern zu vermeiden!
    -- (Verhindert kurzes Aufblitzen wenn man während des Platzierens ein anderes Item wählt)
    self:Hide()
    
    -- EntryInfo aktualisieren
    local entryInfo = DreamHouse.Utils:GetCatalogEntryInfo(slot.entryID)
    DreamHouse.Debug:Log("Hotbar", "EntryInfo: " .. tostring(entryInfo ~= nil) .. ", qty: " .. tostring(entryInfo and entryInfo.quantity or "nil"), "DEBUG")
    
    -- Item zum Platzieren aktivieren
    if C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor then
        local entryID = slot.entryID
        
        -- Wenn entryID unser selbst erstelltes Format ist (aus KHM mit nur recordID+entryType),
        -- müssen wir die vollständige entryID über die API holen
        if type(entryID) == "table" and entryID.recordID and entryID.entryType and not entryID.entrySubtype then
            local recordID = entryID.recordID
            local entryType = entryID.entryType
            
            DreamHouse.Debug:Log("Hotbar", "Unvollständige entryID erkannt, hole vollständige via API...", "DEBUG")
            
            -- Vollständige entryInfo holen (enthält die korrekte entryID)
            local fullEntryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, true)
            if fullEntryInfo and fullEntryInfo.entryID then
                entryID = fullEntryInfo.entryID
                DreamHouse.Debug:Log("Hotbar", "Vollständige entryID geholt: recordID=" .. recordID, "SUCCESS")
            else
                DreamHouse.Debug:Log("Hotbar", "Konnte vollständige entryID nicht holen!", "ERROR")
                return
            end
        end
        
        DreamHouse.Debug:Log("Hotbar", "EntryID Typ: " .. type(entryID), "DEBUG")
        
        -- Prüfen ob wir im BasicDecor-Modus sind
        local isBasicMode = C_HouseEditor.IsHouseEditorModeActive(Enum.HouseEditorMode.BasicDecor)
        DreamHouse.Debug:Log("Hotbar", "BasicDecor-Modus aktiv: " .. tostring(isBasicMode), "DEBUG")
        
        if not isBasicMode then
            -- Modus wechseln
            DreamHouse.Debug:Log("Hotbar", "Wechsle zu BasicDecor-Modus...", "INFO")
            C_HouseEditor.ActivateHouseEditorMode(Enum.HouseEditorMode.BasicDecor)
            
            -- Verzögerung für Modus-Wechsel
            C_Timer.After(0.2, function()
                local success, err = pcall(function()
                    C_HousingBasicMode.StartPlacingNewDecor(entryID)
                end)
                if success then
                    DreamHouse.Debug:Log("Hotbar", "Item wird platziert!", "SUCCESS")
                else
                    DreamHouse.Debug:Log("Hotbar", "Platzieren Fehler: " .. tostring(err), "ERROR")
                end
            end)
        else
            -- Direkt platzieren
            local success, err = pcall(function()
                C_HousingBasicMode.StartPlacingNewDecor(entryID)
            end)
            if success then
                DreamHouse.Debug:Log("Hotbar", "Item wird platziert!", "SUCCESS")
            else
                DreamHouse.Debug:Log("Hotbar", "Platzieren Fehler: " .. tostring(err), "ERROR")
            end
        end
    else
        DreamHouse.Debug:Log("Hotbar", "C_HousingBasicMode.StartPlacingNewDecor nicht verfügbar!", "ERROR")
    end
end

-- Drag von Katalog starten
function DreamHouse.Hotbar:OnItemDragStart(catalogEntry)
    if catalogEntry and catalogEntry.entryID then
        self.pendingDragItem = catalogEntry.entryID
        isDragging = true
        DreamHouse.Debug:Log("Hotbar", "Drag von Katalog gestartet", "DEBUG")
    end
end

-- Item zur Hotbar hinzufügen (findet ersten freien Slot)
function DreamHouse.Hotbar:AddItem(entryID)
    if not entryID then return false end
    
    -- Prüfen ob bereits in Hotbar
    for i = 1, NUM_SLOTS do
        if slots[i].entryID then
            local existingID = slots[i].entryID.recordID or slots[i].entryID
            local newID = entryID.recordID or entryID
            if existingID == newID then
                DreamHouse.Debug:Log("Hotbar", "Item bereits in Hotbar (Slot " .. i .. ")", "INFO")
                return false
            end
        end
    end
    
    -- Ersten freien Slot finden
    for i = 1, NUM_SLOTS do
        if not slots[i].entryID then
            self:SetSlotItem(i, entryID)
            PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED)
            DreamHouse.Debug:Log("Hotbar", "Item zu Slot " .. i .. " hinzugefügt", "SUCCESS")
            return true
        end
    end
    
    DreamHouse.Debug:Log("Hotbar", "Hotbar voll!", "WARN")
    return false
end

-- Prüfen ob Item bereits in Hotbar ist
function DreamHouse.Hotbar:IsItemInHotbar(entryID)
    if not entryID then return false, nil end
    
    local checkID = entryID.recordID or entryID
    
    for i = 1, NUM_SLOTS do
        if slots[i] and slots[i].entryID then
            local slotID = slots[i].entryID.recordID or slots[i].entryID
            if slotID == checkID then
                return true, i
            end
        end
    end
    
    return false, nil
end

-- Item aus Hotbar entfernen (nach entryID)
function DreamHouse.Hotbar:RemoveItemByEntryID(entryID)
    if not entryID then return false end
    
    local isInHotbar, slotIndex = self:IsItemInHotbar(entryID)
    if isInHotbar and slotIndex then
        self:ClearSlot(slotIndex)
        PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_REMOVED)
        DreamHouse.Debug:Log("Hotbar", "Item aus Slot " .. slotIndex .. " entfernt", "SUCCESS")
        return true
    end
    
    return false
end

-- An Storage-Panel anhängen (Oberer Frame oben rechts, Unterer Frame unten rechts)
function DreamHouse.Hotbar:AttachToStoragePanel(storagePanel)
    if not hotbarTopFrame then
        self:Create()
    end
    
    -- Storage-Panel merken für spätere Updates
    self.storagePanel = storagePanel
    
    -- Parent auf HouseEditorFrame setzen
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
        hotbarTopFrame:SetParent(HouseEditorFrame)
        hotbarTopFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        hotbarTopFrame:SetFrameLevel(50)
        
        hotbarBottomFrame:SetParent(HouseEditorFrame)
        hotbarBottomFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        hotbarBottomFrame:SetFrameLevel(50)
        
        DreamHouse.Debug:Log("Hotbar", "Parent -> HouseEditorFrame", "DEBUG")
    end
    
    -- Position setzen (am Storage-Panel)
    self:PositionAtStorage()
    
    -- Nicht anzeigen wenn gerade platziert wird
    if self:IsPlacingDecor() then
        DreamHouse.Debug:Log("Hotbar", "AttachToStoragePanel: Platzierung aktiv, Hotbar bleibt versteckt", "DEBUG")
        return
    end
    
    -- Wenn Platzierung von Hotbar gestartet wurde, verzögert prüfen ob wirklich beendet
    if placingFromHotbar then
        DreamHouse.Debug:Log("Hotbar", "AttachToStoragePanel: placingFromHotbar aktiv, verzögerte Prüfung...", "DEBUG")
        C_Timer.After(0.15, function()
            if not self:IsPlacingDecor() then
                placingFromHotbar = false
                DreamHouse.Debug:Log("Hotbar", "Platzierung wirklich beendet - zeige Hotbar", "DEBUG")
                if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
                    self:PositionAtStorage()
                    hotbarTopFrame:Show()
                    hotbarBottomFrame:Show()
                end
            end
        end)
        return
    end
    
    if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
        hotbarTopFrame:Show()
        hotbarBottomFrame:Show()
        DreamHouse.Debug:Log("Hotbar", "Hotbar angezeigt (2 Frames)!", "SUCCESS")
    end
end

-- Hotbar am Storage-Panel positionieren
function DreamHouse.Hotbar:PositionAtStorage()
    if not hotbarTopFrame or not self.storagePanel then return end
    
    -- OBERER Frame: An oberer rechter Ecke des Storage-Panels
    hotbarTopFrame:ClearAllPoints()
    hotbarTopFrame:SetPoint("TOPLEFT", self.storagePanel, "TOPRIGHT", 3, 0)
    
    -- UNTERER Frame: An unterer rechter Ecke des Storage-Panels
    hotbarBottomFrame:ClearAllPoints()
    hotbarBottomFrame:SetPoint("BOTTOMLEFT", self.storagePanel, "BOTTOMRIGHT", 3, 0)
    
    DreamHouse.Debug:Log("Hotbar", "Position: Am Storage-Panel", "DEBUG")
end

-- Hotbar am linken Rand positionieren (wenn Storage eingeklappt) - relativ zum StorageButton
function DreamHouse.Hotbar:PositionAtScreenEdge()
    if not hotbarTopFrame then return end
    
    -- StorageButton (Truhe) als Referenz nehmen
    local storageButton = HouseEditorFrame and HouseEditorFrame.StorageButton
    
    if storageButton and storageButton:IsShown() then
        -- Relativ zum StorageButton positionieren - gleiche Abstände wie beim Storage-Panel
        hotbarTopFrame:ClearAllPoints()
        hotbarTopFrame:SetPoint("BOTTOMLEFT", storageButton, "TOPLEFT", 3, 5)
        
        hotbarBottomFrame:ClearAllPoints()
        hotbarBottomFrame:SetPoint("TOPLEFT", storageButton, "BOTTOMLEFT", 3, -5)
        
        DreamHouse.Debug:Log("Hotbar", "Position: Relativ zum StorageButton", "DEBUG")
    else
        -- Fallback: Am linken Rand
        hotbarTopFrame:ClearAllPoints()
        hotbarTopFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -200)
        
        hotbarBottomFrame:ClearAllPoints()
        hotbarBottomFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 200)
        
        DreamHouse.Debug:Log("Hotbar", "Position: Fallback linker Rand", "DEBUG")
    end
end

-- Hotbar an aktueller absoluter Position fixieren (verhindert Mitgleiten bei Animation)
function DreamHouse.Hotbar:FreezeAtCurrentPosition()
    if not hotbarTopFrame then return end
    
    -- Aktuelle absolute Position ermitteln
    local topLeft = hotbarTopFrame:GetLeft()
    local topTop = hotbarTopFrame:GetTop()
    local bottomLeft = hotbarBottomFrame and hotbarBottomFrame:GetLeft()
    local bottomBottom = hotbarBottomFrame and hotbarBottomFrame:GetBottom()
    
    -- Hotbar temporär an UIParent anchoren mit absoluten Koordinaten
    -- Das "löst" sie vom Storage-Panel
    if topLeft and topTop then
        hotbarTopFrame:ClearAllPoints()
        hotbarTopFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", topLeft, topTop)
        DreamHouse.Debug:Log("Hotbar", "Top fixiert bei: " .. math.floor(topLeft) .. ", " .. math.floor(topTop), "DEBUG")
    end
    
    if hotbarBottomFrame and bottomLeft and bottomBottom then
        hotbarBottomFrame:ClearAllPoints()
        hotbarBottomFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", bottomLeft, bottomBottom)
        DreamHouse.Debug:Log("Hotbar", "Bottom fixiert bei: " .. math.floor(bottomLeft) .. ", " .. math.floor(bottomBottom), "DEBUG")
    end
end

-- Storage wird angezeigt -> Hotbar am Storage positionieren
function DreamHouse.Hotbar:OnStorageShown()
    if not hotbarTopFrame then return end
    
    self:PositionAtStorage()
    
    -- Nicht anzeigen wenn gerade platziert wird
    if self:IsPlacingDecor() then return end
    
    -- Wenn Platzierung von Hotbar gestartet wurde, verzögert prüfen ob wirklich beendet
    -- (verhindert Flackern beim Item-Wechsel, erlaubt aber Anzeige wenn Platzierung wirklich beendet)
    if placingFromHotbar then
        DreamHouse.Debug:Log("Hotbar", "OnStorageShown - placingFromHotbar aktiv, verzögerte Prüfung...", "DEBUG")
        C_Timer.After(0.15, function()
            -- Nach kurzer Verzögerung prüfen: Ist immer noch kein Platzieren aktiv?
            -- Wenn ja, war es ein echtes Ende der Platzierung
            if not self:IsPlacingDecor() then
                placingFromHotbar = false
                DreamHouse.Debug:Log("Hotbar", "Platzierung wirklich beendet - zeige Hotbar", "DEBUG")
                if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
                    self:PositionAtStorage()
                    hotbarTopFrame:Show()
                    hotbarBottomFrame:Show()
                end
            else
                DreamHouse.Debug:Log("Hotbar", "Platzierung noch aktiv - Hotbar bleibt versteckt", "DEBUG")
            end
        end)
        return
    end
    
    if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
        hotbarTopFrame:Show()
        hotbarBottomFrame:Show()
    end
    DreamHouse.Debug:Log("Hotbar", "Hotbar am Storage positioniert", "DEBUG")
end

-- Storage wird eingeklappt (aber Editor noch aktiv) -> Hotbar an Bildschirmrand
function DreamHouse.Hotbar:OnStorageCollapsed()
    if not hotbarTopFrame then return end
    
    self:PositionAtScreenEdge()
    
    -- Nicht anzeigen wenn gerade platziert wird
    if self:IsPlacingDecor() then return end
    
    -- Wenn Platzierung von Hotbar gestartet wurde, verzögert prüfen ob wirklich beendet
    if placingFromHotbar then
        DreamHouse.Debug:Log("Hotbar", "OnStorageCollapsed - placingFromHotbar aktiv, verzögerte Prüfung...", "DEBUG")
        C_Timer.After(0.15, function()
            if not self:IsPlacingDecor() then
                placingFromHotbar = false
                DreamHouse.Debug:Log("Hotbar", "Platzierung wirklich beendet - zeige Hotbar am Rand", "DEBUG")
                if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
                    self:PositionAtScreenEdge()
                    hotbarTopFrame:Show()
                    hotbarBottomFrame:Show()
                end
            end
        end)
        return
    end
    
    -- Hotbar bleibt SICHTBAR!
    if DreamHouse.Settings:IsFeatureEnabled("hotbar") then
        hotbarTopFrame:Show()
        hotbarBottomFrame:Show()
    end
    DreamHouse.Debug:Log("Hotbar", "Hotbar am Bildschirmrand (Storage collapsed)", "DEBUG")
end

-- Storage komplett versteckt (Platzieren-Modus oder Editor geschlossen) -> Hotbar verstecken
function DreamHouse.Hotbar:OnStorageHidden()
    if not hotbarTopFrame then return end
    
    hotbarTopFrame:Hide()
    hotbarBottomFrame:Hide()
    DreamHouse.Debug:Log("Hotbar", "Hotbar versteckt (Storage hidden)", "DEBUG")
end

-- Prüft ob gerade ein Item platziert wird (UI ist dann ausgeblendet)
function DreamHouse.Hotbar:IsPlacingDecor()
    if C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor then
        return C_HousingBasicMode.IsPlacingNewDecor()
    end
    return false
end

-- Anzeigen/Verstecken
function DreamHouse.Hotbar:Show()
    if not hotbarTopFrame then
        self:Create()
    end
    
    -- NICHT anzeigen wenn gerade ein Item platziert wird!
    if self:IsPlacingDecor() then
        DreamHouse.Debug:Log("Hotbar", "Show() abgebrochen - Platzierung aktiv", "DEBUG")
        return
    end
    
    -- NICHT anzeigen wenn Platzierung von Hotbar gestartet wurde (verhindert Flackern beim Item-Wechsel)
    if placingFromHotbar then
        DreamHouse.Debug:Log("Hotbar", "Show() abgebrochen - placingFromHotbar aktiv", "DEBUG")
        return
    end
    
    hotbarTopFrame:Show()
    hotbarBottomFrame:Show()
end

function DreamHouse.Hotbar:Hide()
    if hotbarTopFrame then
        hotbarTopFrame:Hide()
    end
    if hotbarBottomFrame then
        hotbarBottomFrame:Hide()
    end
end

function DreamHouse.Hotbar:Toggle()
    if hotbarTopFrame and hotbarTopFrame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function DreamHouse.Hotbar:IsShown()
    return hotbarTopFrame and hotbarTopFrame:IsShown()
end

-- Storage-Update (Mengen aktualisieren)
function DreamHouse.Hotbar:RefreshSlots()
    for i, slot in ipairs(slots) do
        if slot.entryID then
            self:SetSlotItem(i, slot.entryID)
        end
    end
end

-- Keybindings für Hotbar (Shift+1 bis Shift+0)
function DreamHouse.Hotbar:SetupKeybindings()
    if self.keybindFrame then return end
    
    -- Owner-Frame für Override-Bindings
    self.keybindFrame = CreateFrame("Frame", "DreamHouseKeybindOwner", UIParent)
    
    -- Unsichtbare Buttons für Keybindings erstellen
    -- Diese werden IMMER existieren und von SetOverrideBindingClick aufgerufen
    self.keybindButtons = {}
    for i = 1, NUM_SLOTS do
        local btn = CreateFrame("Button", "DreamHouseKeybind" .. i, UIParent, "SecureActionButtonTemplate")
        btn:SetSize(1, 1)
        btn:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
        btn:EnableMouse(false)
        btn:Hide() -- Versteckt aber existiert!
        
        -- Beim "Klick" durch Keybinding wird OnClick ausgeführt
        local slotIndex = i
        btn:SetScript("PreClick", function()
            DreamHouse.Debug:Log("Hotbar", "Keybind-Button " .. slotIndex .. " gedrückt!", "DEBUG")
            DreamHouse.Hotbar:UseSlot(slotIndex)
        end)
        
        self.keybindButtons[i] = btn
    end
    
    DreamHouse.Debug:Log("Hotbar", "Keybinding-Buttons erstellt", "DEBUG")
end

-- Keybindings aktivieren (wenn Editor geöffnet)
function DreamHouse.Hotbar:EnableKeybindings()
    if self.keybindsActive then return end
    
    if not self.keybindFrame then
        self:SetupKeybindings()
    end
    
    -- Override-Bindings für Strg+1-0 setzen
    for i = 1, NUM_SLOTS do
        local key = i == 10 and "0" or tostring(i)
        SetOverrideBindingClick(self.keybindFrame, true, "CTRL-" .. key, "DreamHouseKeybind" .. i, "LeftButton")
    end
    
    self.keybindsActive = true
    DreamHouse.Debug:Log("Hotbar", "Keybindings aktiviert (Strg+1-0)", "SUCCESS")
end

-- Keybindings deaktivieren (wenn Editor geschlossen)
function DreamHouse.Hotbar:DisableKeybindings()
    if not self.keybindsActive then return end
    
    -- Alle Override-Bindings entfernen
    if self.keybindFrame then
        ClearOverrideBindings(self.keybindFrame)
    end
    
    self.keybindsActive = false
    DreamHouse.Debug:Log("Hotbar", "Keybindings deaktiviert", "DEBUG")
end

-- Initialisierung
function DreamHouse.Hotbar:Initialize()
    self:Create()
    self:CreateDragIcon()  -- Drag-Icon vorbereiten
    self:SetupKeybindings()
    
    -- Auf Storage-Updates hören
    DreamHouse.Events:Register("DREAMHOUSE_STORAGE_UPDATED", function()
        self:RefreshSlots()
        DreamHouse.Debug:Log("Hotbar", "Slots aktualisiert (Storage Update)", "DEBUG")
    end, self)
    
    -- Auf Decor-Platzierung hören (Mengen aktualisieren)
    DreamHouse.Events:Register("DREAMHOUSE_DECOR_PLACED", function()
        -- Kurze Verzögerung damit die API die neuen Mengen hat
        C_Timer.After(0.2, function()
            self:RefreshSlots()
            DreamHouse.Debug:Log("Hotbar", "Slots aktualisiert (Decor platziert)", "DEBUG")
        end)
    end, self)
    
    -- Auf Decor-Entfernung hören (Mengen aktualisieren)
    DreamHouse.Events:Register("DREAMHOUSE_DECOR_REMOVED", function()
        -- Kurze Verzögerung damit die API die neuen Mengen hat
        C_Timer.After(0.2, function()
            self:RefreshSlots()
            DreamHouse.Debug:Log("Hotbar", "Slots aktualisiert (Decor entfernt)", "DEBUG")
        end)
    end, self)
    
    -- Keybindings aktivieren wenn Editor geöffnet wird
    DreamHouse.Events:Register("DREAMHOUSE_EDITOR_OPENED", function()
        self:EnableKeybindings()
        self:EnableScrollBindings()  -- Shift+Mousewheel für Kollektionen
    end, self)
    
    -- Keybindings deaktivieren wenn Editor geschlossen wird
    DreamHouse.Events:Register("DREAMHOUSE_EDITOR_CLOSED", function()
        self:DisableKeybindings()
        self:DisableScrollBindings()  -- Shift+Mousewheel entfernen
    end, self)
    
    -- Kollektions-Scrolling Buttons vorbereiten (Shift+Mausrad)
    self:SetupCollectionScrolling()
    
    -- Falls Editor bereits offen ist
    if DreamHouse.Utils:IsEditorActive() then
        self:EnableKeybindings()
        self:EnableScrollBindings()
    end
    
    DreamHouse.Debug:Log("Hotbar", "Hotbar initialisiert", "SUCCESS")
end

-- Holt die Daten eines Slots
function DreamHouse.Hotbar:GetSlotData(slotIndex)
    local slot = slots[slotIndex]
    if not slot then return nil end
    
    return {
        entryID = slot.entryID,
        entryInfo = slot.entryInfo,
        itemName = slot.itemName
    }
end

-- Setzt einen Slot per EntryID (Alias für SetSlotItem)
function DreamHouse.Hotbar:SetSlotByEntryID(slotIndex, entryID)
    self:SetSlotItem(slotIndex, entryID)
end

-- ============================================
-- KOLLEKTIONS-WECHSEL MIT SHIFT+SCROLLRAD (nicht Ctrl, da das der WoW-Zoom ist!)
-- ============================================

-- Wechselt zur nächsten/vorherigen Kollektion
function DreamHouse.Hotbar:CycleCollection(direction)
    -- Nur aktiv wenn Kollektions-Hotbar-Modus an ist
    if not DreamHouse.Hooks or not DreamHouse.Hooks.Storage then return false end
    if not DreamHouse.Hooks.Storage.collectionHotbarModeActive then return false end
    
    -- Alle Kollektionen holen
    local collections = DreamHouse.Collections and DreamHouse.Collections:GetAllCollections() or {}
    if #collections == 0 then
        DreamHouse.Debug:Log("Hotbar", "Keine Kollektionen vorhanden", "DEBUG")
        return false
    end
    
    -- Aktuelle Kollektion finden
    local currentID = DreamHouse.Hooks.Storage.activeCollectionID
    local currentIndex = nil
    
    for i, col in ipairs(collections) do
        if col.id == currentID then
            currentIndex = i
            break
        end
    end
    
    -- Wenn keine aktive, starte bei der ersten
    if not currentIndex then
        currentIndex = 0
    end
    
    -- Neue Index berechnen (mit Wrap-Around)
    local newIndex = currentIndex + direction
    if newIndex < 1 then
        newIndex = #collections
    elseif newIndex > #collections then
        newIndex = 1
    end
    
    -- Zur neuen Kollektion wechseln
    local newCollection = collections[newIndex]
    if newCollection then
        DreamHouse.Hooks.Storage:SetActiveCollection(newCollection.id)
        
        -- Visuelles Feedback: Kollektions-Name anzeigen
        self:ShowCollectionSwitchNotification(newCollection.name, newIndex, #collections)
        
        DreamHouse.Debug:Log("Hotbar", "Kollektion gewechselt: " .. newCollection.name .. " (" .. newIndex .. "/" .. #collections .. ")", "SUCCESS")
        return true
    end
    
    return false
end

-- Timer-ID für Notification (um alte Timer zu ignorieren)
local notificationTimerID = 0

-- Zeigt kurze Benachrichtigung beim Kollektions-Wechsel
function DreamHouse.Hotbar:ShowCollectionSwitchNotification(collectionName, index, total)
    -- Notification Frame erstellen falls nicht vorhanden
    if not self.collectionNotifyFrame then
        local frame = CreateFrame("Frame", "DreamHouseCollectionNotify", UIParent, "BackdropTemplate")
        frame:SetSize(250, 40)
        frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        frame:SetBackdropColor(0, 0, 0, 0.85)
        frame:SetBackdropBorderColor(0.4, 0.8, 1, 0.8)
        
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetSize(24, 24)
        frame.icon:SetPoint("LEFT", 8, 0)
        
        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.text:SetPoint("LEFT", frame.icon, "RIGHT", 8, 6)
        frame.text:SetTextColor(1, 1, 1)
        
        frame.subtext = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.subtext:SetPoint("TOPLEFT", frame.text, "BOTTOMLEFT", 0, -2)
        frame.subtext:SetTextColor(0.6, 0.6, 0.6)
        
        frame:Hide()
        self.collectionNotifyFrame = frame
    end
    
    local frame = self.collectionNotifyFrame
    
    -- Alte Fade-Animationen stoppen
    UIFrameFadeRemoveFrame(frame)
    
    -- Kollektions-Icon setzen (falls vorhanden)
    local collection = DreamHouse.Collections:GetCollectionByID(DreamHouse.Hooks.Storage.activeCollectionID)
    if collection and collection.icon then
        frame.icon:SetAtlas(collection.icon)
        frame.icon:Show()
    else
        frame.icon:SetAtlas("Garr_Building_Inventory")
        frame.icon:Show()
    end
    
    -- Text setzen
    frame.text:SetText(collectionName or "?")
    frame.subtext:SetText(L["Collection"] .. " " .. index .. "/" .. total)
    
    -- Parent an HouseEditorFrame wenn aktiv
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
        frame:SetParent(HouseEditorFrame)
        frame:ClearAllPoints()
        frame:SetPoint("TOP", HouseEditorFrame, "TOP", 0, -100)
    else
        frame:SetParent(UIParent)
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    end
    
    -- Neue Timer-ID generieren (macht alte Timer ungültig)
    notificationTimerID = notificationTimerID + 1
    local currentTimerID = notificationTimerID
    
    -- Sofort sichtbar machen
    frame:SetAlpha(1)
    frame:Show()
    
    -- Nach 1.2 Sekunden ausblenden (nur wenn kein neuer Timer gestartet wurde)
    C_Timer.After(1.2, function()
        if currentTimerID ~= notificationTimerID then return end  -- Veraltet, ignorieren
        
        UIFrameFadeOut(frame, 0.25, 1, 0)
        C_Timer.After(0.25, function()
            if currentTimerID ~= notificationTimerID then return end  -- Veraltet, ignorieren
            frame:Hide()
        end)
    end)
end

-- Erstellt den Scrollrad-Handler für Shift+Wheel
-- WICHTIG: Wir nutzen Override-Bindings statt Frame-Hooks, damit der normale Zoom nicht blockiert wird!
function DreamHouse.Hotbar:SetupCollectionScrolling()
    if self.collectionScrollingSetup then return end
    self.collectionScrollingSetup = true
    
    -- Unsichtbare Buttons für Shift+Mousewheel Up/Down
    self.scrollUpBtn = CreateFrame("Button", "DreamHouseScrollUp", UIParent, "SecureActionButtonTemplate")
    self.scrollUpBtn:SetSize(1, 1)
    self.scrollUpBtn:Hide()
    self.scrollUpBtn:SetScript("PreClick", function()
        if DreamHouse.Hooks and DreamHouse.Hooks.Storage and DreamHouse.Hooks.Storage.collectionHotbarModeActive then
            DreamHouse.Hotbar:CycleCollection(-1)  -- Vorherige Kollektion
        end
    end)
    
    self.scrollDownBtn = CreateFrame("Button", "DreamHouseScrollDown", UIParent, "SecureActionButtonTemplate")
    self.scrollDownBtn:SetSize(1, 1)
    self.scrollDownBtn:Hide()
    self.scrollDownBtn:SetScript("PreClick", function()
        if DreamHouse.Hooks and DreamHouse.Hooks.Storage and DreamHouse.Hooks.Storage.collectionHotbarModeActive then
            DreamHouse.Hotbar:CycleCollection(1)  -- Nächste Kollektion
        end
    end)
    
    DreamHouse.Debug:Log("Hotbar", "Kollektions-Scrolling Buttons erstellt", "DEBUG")
end

-- Aktiviert Shift+Mousewheel Bindings (wenn Editor geöffnet)
function DreamHouse.Hotbar:EnableScrollBindings()
    if self.scrollBindingsActive then return end
    
    if not self.scrollUpBtn then
        self:SetupCollectionScrolling()
    end
    
    -- Sicherstellen dass keybindFrame existiert
    if not self.keybindFrame then
        self:SetupKeybindings()
    end
    
    -- Shift+Mousewheel Up/Down an unsere Buttons binden
    SetOverrideBindingClick(self.keybindFrame, false, "SHIFT-MOUSEWHEELUP", "DreamHouseScrollUp", "LeftButton")
    SetOverrideBindingClick(self.keybindFrame, false, "SHIFT-MOUSEWHEELDOWN", "DreamHouseScrollDown", "LeftButton")
    
    self.scrollBindingsActive = true
    DreamHouse.Debug:Log("Hotbar", "Shift+Mousewheel Bindings aktiviert", "SUCCESS")
end

-- Deaktiviert Shift+Mousewheel Bindings (wenn Editor geschlossen)
function DreamHouse.Hotbar:DisableScrollBindings()
    if not self.scrollBindingsActive then return end
    
    -- Bindings entfernen (ClearOverrideBindings entfernt ALLE, also müssen wir sie einzeln setzen)
    if self.keybindFrame then
        -- Nur die Scroll-Bindings entfernen, nicht die Ctrl+1-0!
        SetOverrideBinding(self.keybindFrame, false, "SHIFT-MOUSEWHEELUP", nil)
        SetOverrideBinding(self.keybindFrame, false, "SHIFT-MOUSEWHEELDOWN", nil)
    end
    
    self.scrollBindingsActive = false
    DreamHouse.Debug:Log("Hotbar", "Shift+Mousewheel Bindings deaktiviert", "DEBUG")
end

-- Modul registrieren
DreamHouse:RegisterModule("Hotbar", DreamHouse.Hotbar)
