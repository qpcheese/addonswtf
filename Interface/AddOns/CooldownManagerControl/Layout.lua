local addonName, addonTable = ...
local addon                 = addonTable.Core


--- Builds an ordered index list of frames for a given viewer (non-dynamic), including normal and added frames, and computes the maximum width and height among them.
--- The index list is written into `addonTable.indexTable[name]`, and size data into `addonTable.widthTable[name]` and `addonTable.heightTable[name]`.
--- @param name string  The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:getIndexList(name)
    local db = addon.db.profile[name]
    local spec = addon.db.global.playerSpec
    local viewer = addonTable.viewerFrameMap[name]

    addonTable.indexTable[name] = {}
    addonTable.widthTable[name] = 0
    addonTable.heightTable[name] = 0

    addonTable.sizeTable[name] = {}

    local itemFrameContainer = viewer:GetLayoutChildren()
    local normalCount = #itemFrameContainer

    -- Prepare added frames list
    local addedList = {}
    if addonTable.addedItemsList[name] and addonTable.addedItemsList[name][spec] then
        for idx, entry in ipairs(addonTable.addedItemsList[name][spec]) do
            if entry.frame and entry.rank and (entry.rank >= 1) then
                -- keep srcIndex so we can refer back
                table.insert(addedList, { srcIndex = idx, frame = entry.frame, rank = entry.rank, meta = entry.meta })
            end
        end
    end
    table.sort(addedList, function(a, b)
        if a.rank == b.rank then
            return a.srcIndex < b.srcIndex
        end
        return a.rank < b.rank
    end)

    -- insertion pointer for addedList
    local addedPtr = 1
    local addedTotal = #addedList

    -- iterate through normal frames and insert added frames before the appropriate normal frame
    for i = 1, normalCount do
        -- Insert any added frames whose rank == i (or rank < = i but we maintain sorted order)
        while addedPtr <= addedTotal and addedList[addedPtr].rank <= i do
            local addedEntry = addedList[addedPtr]
            local meta = addedEntry.meta
            if meta.enable and not meta.overridePose then
                local f = addedEntry.frame
                local w = (f.GetWidth and f:GetWidth()) or 0
                local h = (f.GetHeight and f:GetHeight()) or 0
                addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                table.insert(addonTable.indexTable[name], { kind = "added", index = addedEntry.srcIndex })

                table.insert(addonTable.sizeTable[name], { width = w, height = h, index = addedEntry.srcIndex })
            end
            addedPtr = addedPtr + 1
        end

        -- Now handle the normal frame i
        local itemFrame = itemFrameContainer[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()
        if cooldownID then
            if not db.override[spec][cooldownID] or not db.override[spec][cooldownID].enable or not db.override[spec][cooldownID].overridePose then
                local w = (itemFrame.GetWidth and itemFrame:GetWidth()) or 0
                local h = (itemFrame.GetHeight and itemFrame:GetHeight()) or 0
                addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                table.insert(addonTable.indexTable[name], { kind = "normal", index = i })
                table.insert(addonTable.sizeTable[name], { width = w, height = h, index = i })
            end
        end
    end

    -- Any remaining added frames with rank > normalCount should be appended (placed after last normal frame)
    while addedPtr <= addedTotal do
        local addedEntry = addedList[addedPtr]
        local meta = addedEntry.meta
        if meta.enable and not meta.overridePose then
            local f = addedEntry.frame
            local w = (f.GetWidth and f:GetWidth()) or 0
            local h = (f.GetHeight and f:GetHeight()) or 0
            addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
            addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
            table.insert(addonTable.indexTable[name], { kind = "added", index = addedEntry.srcIndex })
            table.insert(addonTable.sizeTable[name], { width = w, height = h, index = addedEntry.srcIndex })
        end
        addedPtr = addedPtr + 1
    end
end

--- Builds a dynamically ordered index list of visible/active frames for a given viewer, including normal and added frames, and computes the maximum width and height among them.
--- The resulting index list is written into `addonTable.indexTable[name]`, and size data to `addonTable.widthTable[name]` and `addonTable.heightTable[name]`.
--- @param name string  The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:getIndexListDynamic(name)
    local db                     = addon.db.profile[name]
    local spec                   = addon.db.global.playerSpec
    local viewer                 = addonTable.viewerFrameMap[name]
    local layoutDB               = db.layout

    --local previousStateTable     = addon:deepCopy(addonTable.stateTable[name]) or {}

    addonTable.indexTable[name]  = {}
    addonTable.widthTable[name]  = 0
    addonTable.heightTable[name] = 0

    addonTable.sizeTable[name]   = {}

    local itemFrameContainer     = viewer:GetLayoutChildren()
    local normalCount            = #itemFrameContainer

    -- Prepare added frames list
    local addedList              = {}
    if addonTable.addedItemsList[name] and addonTable.addedItemsList[name][spec] then
        for idx, entry in ipairs(addonTable.addedItemsList[name][spec]) do
            if entry.frame and entry.rank and (entry.rank >= 1) then
                -- keep srcIndex so we can refer back
                table.insert(addedList, { srcIndex = idx, frame = entry.frame, rank = entry.rank, meta = entry.meta })
            end
        end
    end
    table.sort(addedList, function(a, b)
        if a.rank == b.rank then
            return a.srcIndex < b.srcIndex
        end
        return a.rank < b.rank
    end)

    -- pointer for addedList
    local addedPtr = 1
    local addedTotal = #addedList

    -- iterate normal frames and inject added frames before target positions
    for i = 1, normalCount do
        while addedPtr <= addedTotal and addedList[addedPtr].rank <= i do
            local addedEntry = addedList[addedPtr]
            local meta = addedEntry.meta
            -- If enabled and not overridden in pose, apply dynamic visibility rules (like other frames)
            if meta.enable and not meta.overridePose then
                local shouldShow = meta.showWhenInactive or addedEntry.frame.isActive
                if shouldShow then
                    local f = addedEntry.frame
                    local w = (f.GetWidth and f:GetWidth()) or 0
                    local h = (f.GetHeight and f:GetHeight()) or 0
                    addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                    addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                    table.insert(addonTable.indexTable[name], { kind = "added", index = addedEntry.srcIndex })
                    table.insert(addonTable.sizeTable[name], { width = w, height = h, index = addedEntry.srcIndex })
                end
            end
            addedPtr = addedPtr + 1
        end

        -- handle normal frame
        local itemFrame = itemFrameContainer[i]
        local cooldownID = itemFrame.GetCooldownID and itemFrame:GetCooldownID()
        if cooldownID then
            if (name == "buffIcon" or name == "buffBar") then
                if db.override and db.override[spec] and db.override[spec][cooldownID] and db.override[spec][cooldownID].enable and not db.override[spec][cooldownID].overridePose then
                    -- This frame is overridden, we follow the overriden showWhenInactive setting
                    if addonTable.stateTable[name] and addonTable.stateTable[name][cooldownID] or db.override[spec][cooldownID].showWhenInactive then
                        local w = (itemFrame.GetWidth and itemFrame:GetWidth()) or 0
                        local h = (itemFrame.GetHeight and itemFrame:GetHeight()) or 0
                        addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                        addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                        table.insert(addonTable.indexTable[name], { kind = "normal", index = i })
                        table.insert(addonTable.sizeTable[name], { width = w, height = h, index = i })
                    end
                elseif addonTable.stateTable[name] and addonTable.stateTable[name][cooldownID] or layoutDB.showWhenInactive then
                    -- This frame is not overridden, we follow the global showWhenInactive setting
                    local w = (itemFrame.GetWidth and itemFrame:GetWidth()) or 0
                    local h = (itemFrame.GetHeight and itemFrame:GetHeight()) or 0
                    addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                    addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                    table.insert(addonTable.indexTable[name], { kind = "normal", index = i })
                    table.insert(addonTable.sizeTable[name], { width = w, height = h, index = i })
                end
            else
                -- These viewers do not have dynamic display
            end
        end
    end

    -- Any remaining added frames with rank > normalCount should be appended (placed after last normal frame)
    while addedPtr <= addedTotal do
        local addedEntry = addedList[addedPtr]
        local meta = addedEntry.meta
        if meta.enable and not meta.overridePose then
            local shouldShow = meta.showWhenInactive or addedEntry.frame.isActive

            if shouldShow then
                local f = addedEntry.frame
                local w = (f.GetWidth and f:GetWidth()) or 0
                local h = (f.GetHeight and f:GetHeight()) or 0
                addonTable.widthTable[name] = (addonTable.widthTable[name] == 0 or w > addonTable.widthTable[name]) and w or addonTable.widthTable[name]
                addonTable.heightTable[name] = (addonTable.heightTable[name] == 0 or h > addonTable.heightTable[name]) and h or addonTable.heightTable[name]
                table.insert(addonTable.indexTable[name], { kind = "added", index = addedEntry.srcIndex })
                table.insert(addonTable.sizeTable[name], { width = w, height = h, index = addedEntry.srcIndex })
            end
        end
        addedPtr = addedPtr + 1
    end
end

--- Returns the position of a frame in the computed index table for a given layout.
--- @param name      string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @param kind      string Frame type: "normal" or "added".
--- @param realIndex number Original index of the frame in its non-merged list.
--- @return number position The 1-based position in the index table, or 0 if not found.
function addon:positionInIndexTableUpdated(name, kind, realIndex)
    local indexTable = addonTable.indexTable[name]
    if not indexTable then return 0 end

    for j, entry in ipairs(indexTable) do
        if entry.kind == kind and entry.index == realIndex then
            return j
        end
    end

    return 0
end

--- Computes the layout coordinates and anchor points for a frame in a viewer. Assumes a uniform size for all frames.
--- @param name        string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @param i           number The 1-based index of the frame in the index list (as returned by positionInIndexTableUpdated).
--- @param totalFrames number Total number of frames in the layout.
--- @param maxWidth    number Maximum width among frames in the current layout (used for spacing).
--- @param maxHeight   number Maximum height among frames in the current layout (used for spacing).
--- @return string anchorPoint The anchor point of the frame relative to its parent.
--- @return string parentPoint The corresponding point on the parent frame.
--- @return number x X offset from the parent anchor point.
--- @return number y Y offset from the parent anchor point.
function addon:returnLayoutCoordinate(name, i, totalFrames, maxWidth, maxHeight)
    local db                       = addon.db.profile[name].layout

    local stride                   = db.iconLimit
    local padding                  = db.padding
    local paddingY                 = db.paddingY
    local isHorizontal             = db.isHorizontal == 0 and true or false
    local iconDirection            = db.growthDirection == Enum.CooldownViewerIconDirection.Right -- or db.growthDirection == Enum.CooldownViewerIconDirection.Up
    local secondDirection          = db.secondDirection
    local centerDistribution       = db.centerDistribution

    local itemSizeX                = maxWidth
    local itemSizeY                = maxHeight

    stride                         = math.min(stride, totalFrames) > 0 and math.min(stride, totalFrames) or 1
    local iconXOffset, iconYOffset = itemSizeX + padding, itemSizeY + paddingY
    local totalLines               = stride ~= 0 and math.ceil(totalFrames / stride) or 1

    local displayIndex             = i - 1
    local primaryIndex             = displayIndex % stride
    local secondaryIndex           = math.floor(displayIndex / stride)
    local itemsInLine              = (secondaryIndex + 1 < totalLines) and stride or (totalFrames % stride)
    if itemsInLine == 0 then itemsInLine = stride end

    -- Centering offset
    local centerOffsetX, centerOffsetY = 0, 0
    if centerDistribution then
        if isHorizontal then
            local totalLineWidth = itemsInLine * itemSizeX + (itemsInLine - 1) * padding
            centerOffsetX = iconDirection
                and (-totalLineWidth / 2 + itemSizeX / 2)
                or (totalLineWidth / 2 - itemSizeX / 2)
        else
            local totalLineHeight = itemsInLine * itemSizeY + (itemsInLine - 1) * paddingY
            centerOffsetY = (not iconDirection)
                and (totalLineHeight / 2 - itemSizeY / 2)
                or (-totalLineHeight / 2 + itemSizeY / 2)
        end
    end

    -- Get the offsets
    local x, y
    if isHorizontal then
        x = (iconDirection and primaryIndex or -primaryIndex) * iconXOffset + centerOffsetX
        y = (secondDirection == 1 and secondaryIndex or -secondaryIndex) * iconYOffset
    else
        x = (secondDirection == 1 and secondaryIndex or -secondaryIndex) * iconXOffset
        y = (not iconDirection and -primaryIndex or primaryIndex) * iconYOffset + centerOffsetY
    end

    -- anchor point logic
    local anchorPoint, parentPoint
    if centerDistribution then
        if isHorizontal then
            anchorPoint = (secondDirection == 1) and "BOTTOM" or "TOP"
            parentPoint = anchorPoint
        else
            anchorPoint = (secondDirection == 1) and "LEFT" or "RIGHT"
            parentPoint = anchorPoint
        end
    else
        if isHorizontal then
            if secondDirection == 1 then
                anchorPoint = iconDirection and "BOTTOMLEFT" or "BOTTOMRIGHT"
            else
                anchorPoint = iconDirection and "TOPLEFT" or "TOPRIGHT"
            end
        else
            if secondDirection == 1 then
                anchorPoint = iconDirection and "BOTTOMLEFT" or "TOPLEFT"
            else
                anchorPoint = iconDirection and "BOTTOMRIGHT" or "TOPRIGHT"
            end
        end
        parentPoint = anchorPoint
    end

    return anchorPoint, parentPoint, x, y
end

--- Computes the layout coordinates and anchor points for a frame in a viewer. Handles variable frame sizes. Does not work with center distribution.
--- @param name        string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @param i           number The 1-based index of the frame in the index list (as returned by positionInIndexTableUpdated).
--- @param totalFrames number Total number of frames in the layout.
--- @return string anchorPoint The anchor point of the frame relative to its parent.
--- @return string parentPoint The corresponding point on the parent frame.
--- @return number x X offset from the parent anchor point.
--- @return number y Y offset from the parent anchor point.
function addon:returnLayoutCoordinateNonCentered(name, i, totalFrames)
    local db                 = addon.db.profile[name].layout

    local stride             = db.iconLimit
    local padding            = db.padding
    local paddingY           = db.paddingY
    local isHorizontal       = db.isHorizontal == 0 and true or false
    local iconDirection      = db.growthDirection == Enum.CooldownViewerIconDirection.Right -- or db.growthDirection == Enum.CooldownViewerIconDirection.Up
    local secondDirection    = db.secondDirection

    local function computeLineMetrics()
        local sizes      = addonTable.sizeTable[name]

        local rowHeights = {}
        local colWidths  = {}

        for k = 1, totalFrames do
            local displayIndex = k - 1
            local col, row

            if isHorizontal then
                -- horizontal fill: across first
                col = (displayIndex % stride) + 1
                row = math.floor(displayIndex / stride) + 1
            else
                -- vertical fill: down first
                row = (displayIndex % stride) + 1
                col = math.floor(displayIndex / stride) + 1
            end

            local w         = sizes[k].width
            local h         = sizes[k].height

            rowHeights[row] = math.max(rowHeights[row] or 0, h)
            colWidths[col]  = math.max(colWidths[col] or 0, w)
        end

        return rowHeights, colWidths
    end

    local rowHeights, colWidths = computeLineMetrics(name, totalFrames, stride)
    stride                      = math.min(stride, totalFrames) > 0 and math.min(stride, totalFrames) or 1
    local displayIndex          = i - 1
    local col, row
    if isHorizontal then
        -- fill across first
        col = (displayIndex % stride) + 1
        row = math.floor(displayIndex / stride) + 1
    else
        -- fill down first
        row = (displayIndex % stride) + 1
        col = math.floor(displayIndex / stride) + 1
    end

    local totalLines
    local itemsInLine
    if isHorizontal then
        totalLines  = math.ceil(totalFrames / stride)
        itemsInLine = (row < totalLines) and stride or (totalFrames % stride)
        if itemsInLine == 0 then itemsInLine = stride end
    else
        totalLines  = math.ceil(totalFrames / stride)
        itemsInLine = (col < totalLines) and stride or (totalFrames % stride)
        if itemsInLine == 0 then itemsInLine = stride end
    end

    -- Get the offsets
    local x, y
    if isHorizontal then
        -- X offset: sum max widths of previous columns
        x = 0
        for c = 1, col - 1 do
            x = x + colWidths[c] + padding
        end

        -- Y offset: sum max heights of previous rows
        y = 0
        for r = 1, row - 1 do
            y = y + rowHeights[r] + paddingY
        end

        -- Apply direction
        if not iconDirection then x = -x end
        if secondDirection ~= 1 then y = -y end
    else
        x = 0
        for c = 1, col - 1 do
            x = x + colWidths[c] + padding
        end

        -- stack rows vertically
        y = 0
        for r = 1, row - 1 do
            y = y + rowHeights[r] + paddingY
        end

        if secondDirection ~= 1 then y = -y end
        if iconDirection then x = -x end
    end

    -- anchor point logic
    local anchorPoint, parentPoint
    if isHorizontal then
        if secondDirection == 1 then
            anchorPoint = iconDirection and "BOTTOMLEFT" or "BOTTOMRIGHT"
        else
            anchorPoint = iconDirection and "TOPLEFT" or "TOPRIGHT"
        end
    else
        if secondDirection == 1 then
            anchorPoint = iconDirection and "BOTTOMLEFT" or "TOPLEFT"
        else
            anchorPoint = iconDirection and "BOTTOMRIGHT" or "TOPRIGHT"
        end
    end
    parentPoint = anchorPoint

    return anchorPoint, parentPoint, x, y
end

--- Refresh the layout of a viewer by repositioning all of its frames according to the current layout settings.
--- @param name      string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:applyLayout(name)
    local spec           = addon.db.global.playerSpec
    local viewer         = addonTable.viewerFrameMap[name]
    local db             = addon.db.profile[name].layout
    local dynamicDisplay = db.dynamicDisplayUpdate

    if dynamicDisplay then
        addon:getIndexListDynamic(name)
    else
        addon:getIndexList(name)
    end

    local indexTable   = addonTable.indexTable[name]
    local totalFrames  = #indexTable
    local maxWidth     = addonTable.widthTable[name]
    local maxHeight    = addonTable.heightTable[name]

    -- Get normal frames and added frames
    local normalFrames = viewer:GetLayoutChildren()
    local addedFrames  = addonTable.addedItemsList[name][spec] or {}

    -- Place every frame according to its merged index
    for mergedIndex, entry in ipairs(indexTable) do
        local itemFrame

        if entry.kind == "normal" then
            itemFrame = normalFrames[entry.index]
        elseif entry.kind == "added" then
            itemFrame = addedFrames[entry.index] and addedFrames[entry.index].frame
        end

        if itemFrame then
            local anchor, parentAnchor, xOffset, yOffset =
                addon:returnLayoutCoordinate(name, mergedIndex, totalFrames, maxWidth, maxHeight)

            itemFrame:ClearAllPoints()
            itemFrame:SetPoint(anchor, viewer, parentAnchor, xOffset, yOffset)
        end
    end
end

--- Updates the size of a viewer based on the frames it contains and layout settings.
--- @param name        string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:updateViewerSize(name)
    addonTable.callFromWithin = true
    local viewer              = addonTable.viewerFrameMap[name]
    local db                  = addon.db.profile[name].layout
    local dynamicDisplay      = db.dynamicDisplayUpdate

    local totalFrames, maxWidth, maxHeight
    if dynamicDisplay then
        addon:getIndexListDynamic(name)
    else
        addon:getIndexList(name)
    end

    totalFrames = #addonTable.indexTable[name]
    maxWidth    = addonTable.widthTable[name]
    maxHeight   = addonTable.heightTable[name]

    if totalFrames == 0 then
        if name == "buffBar" then
            viewer:SetSize((db.iconWidth + db.barWidth + db.barIconSpacing) * db.scale, math.max(db.iconHeight, db.barHeight + 4) * db.scale)
            return
        end
        viewer:SetSize((db.iconWidth) * db.scale, (db.iconHeight) * db.scale)
        return
    end

    local stride       = db.iconLimit
    stride             = math.min(stride, totalFrames) > 0 and math.min(stride, totalFrames) or 1
    local isHorizontal = db.isHorizontal == 0 and true or false
    local numCols      = stride ~= 0 and (isHorizontal and stride or math.ceil(totalFrames / stride)) or 1
    local numRows      = stride ~= 0 and (isHorizontal and math.ceil(totalFrames / stride) or stride) or 1
    local padding      = db.padding
    local paddingY     = db.paddingY
    local scale        = db.scale

    local totalWidth   = (numCols * maxWidth + (numCols - 1) * padding) * scale
    local totalHeight  = (numRows * maxHeight + (numRows - 1) * paddingY) * scale

    viewer:SetSize(totalWidth, totalHeight)

    addonTable.callFromWithin = false
end

--[[ --- Updates the size of a viewer based on the frames it contains and layout settings.
--- @param name        string The name of the viewer to be updated (`essential`, `utility`, `buffIcon`, `buffBar`).
--- @return nil
function addon:updateViewerSize(name)
    addonTable.callFromWithin = true
    local viewer              = addonTable.viewerFrameMap[name]
    local db                  = addon.db.profile[name].layout
    local dynamicDisplay      = db.dynamicDisplayUpdate

    local totalFrames, maxWidth, maxHeight
    if dynamicDisplay then
        addon:getIndexListDynamic(name)
    else
        addon:getIndexList(name)
    end

    totalFrames = #addonTable.indexTable[name]

    if totalFrames == 0 then
        if name == "buffBar" then
            viewer:SetSize((db.iconWidth + db.barWidth + db.barIconSpacing) * db.scale, math.max(db.iconHeight, db.barHeight + 4) * db.scale)
            return
        end
        viewer:SetSize((db.iconWidth) * db.scale, (db.iconHeight) * db.scale)
        return
    end

    local stride       = db.iconLimit
    stride             = math.min(stride, totalFrames) > 0 and math.min(stride, totalFrames) or 1
    local isHorizontal = db.isHorizontal == 0 and true or false
    local padding      = db.padding
    local paddingY     = db.paddingY
    local scale        = db.scale

    local function computeLineMetrics()
        local sizes = addonTable.sizeTable[name]
        totalFrames = #sizes

        local rowHeights = {}
        local colWidths = {}

        for k = 1, totalFrames do
            local idx = k - 1
            local row, col

            if isHorizontal then
                col = (idx % stride) + 1
                row = math.floor(idx / stride) + 1
            else
                row = (idx % stride) + 1
                col = math.floor(idx / stride) + 1
            end

            local w         = sizes[k].width
            local h         = sizes[k].height

            rowHeights[row] = math.max(rowHeights[row] or 0, h)
            colWidths[col]  = math.max(colWidths[col] or 0, w)
        end

        return rowHeights, colWidths
    end

    local rowHeights, colWidths = computeLineMetrics(name, stride, isHorizontal)

    -- Sum widths/heights
    local summedWidth = 0
    for col = 1, #colWidths do
        summedWidth = summedWidth + colWidths[col]
    end

    local summedHeight = 0
    for row = 1, #rowHeights do
        summedHeight = summedHeight + rowHeights[row]
    end

    -- Add padding between columns/rows if >1
    summedWidth       = summedWidth + math.max(0, (#colWidths - 1) * padding)
    summedHeight      = summedHeight + math.max(0, (#rowHeights - 1) * paddingY)

    -- Apply scale
    local totalWidth  = summedWidth * scale
    local totalHeight = summedHeight * scale

    viewer:SetSize(totalWidth, totalHeight)

    addonTable.callFromWithin = false
end ]]
