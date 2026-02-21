local addonName, addonTable = ...
local addon                 = addonTable.Core

local LibSerialize          = LibStub("LibSerialize")
local LibDeflate            = LibStub("LibDeflate")

function addon:encodeForExport(data)
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded    = LibDeflate:EncodeForPrint(compressed)
    return encoded
end

function addon:decodeFromImport(text)
    local decoded = LibDeflate:DecodeForPrint(text)
    if not decoded then return nil, "Decoding failed" end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return nil, "Decompression failed" end

    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return nil, "Deserialization failed" end

    return data
end

function addon:GetIndex(entry, list)
    for i, v in ipairs(list) do
        if v == entry then
            return i
        end
    end
    return nil -- not found
end

function addon:deepCopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    else
        local copy = {}
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                copy[k] = addon:deepCopy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end
end

function addon:DisplayCorners(frame)
    local parent = frame
    local layer, subLayer = "OVERLAY", 1
    if frame:GetObjectType() == "Texture" or frame:GetObjectType() == "FontString" then
        parent = frame:GetParent()
        layer, subLayer = frame:GetDrawLayer()
    end

    if not frame.cornerTextures then
        frame.cornerTextures = {}

        if not frame.backgroundTexture then
            frame.backgroundTexture = parent:CreateTexture(nil, "BACKGROUND")
            frame.backgroundTexture:SetColorTexture(0.5, 0.5, 0.5, 0.5)
            frame.backgroundTexture:SetAllPoints(frame)
        end

        for i = 1, 4 do
            frame.cornerTextures[i] = parent:CreateTexture(nil, "OVERLAY")
            frame.cornerTextures[i]:SetSize(5, 5)
        end
    end

    local r, g, b = math.random(), math.random(), math.random()
    local positions = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }

    for i, point in ipairs(positions) do
        frame.cornerTextures[i]:SetColorTexture(r, g, b, 1)
        frame.cornerTextures[i]:ClearAllPoints()
        frame.cornerTextures[i]:SetPoint(point, frame, point)
        frame.cornerTextures[i]:SetDrawLayer(layer, subLayer)
    end
end

function addon:SanitizeData(data, standardData)
    local isArray = #data > 0
    if isArray then
        data = {}
    end

    -- Clean or correct all expected fields
    for key, default in pairs(standardData) do
        local val = data[key]
        if val == nil or type(val) ~= type(default) then
            data[key] = default
        end
    end

    -- Remove unexpected keys
    for key in pairs(data) do
        if standardData[key] == nil then
            data[key] = nil
        end
    end
end

function addon:ExtractIntegersFromString(input)
    local result = {}
    if input == nil or type(input) ~= "string" then
        return result
    end
    for num in string.gmatch(input, "%-?%d+") do
        table.insert(result, tonumber(num))
    end
    return result
end

function addon:HexToRGB(input)
    local r, g, b, a = 0, 0, 0, 1 -- Default alpha to 1
    if type(input) == 'string' then
        local hex = input:gsub('#', '')
        if #hex == 8 then
            a = tonumber(hex:sub(1, 2), 16) / 255
            r = tonumber(hex:sub(3, 4), 16) / 255
            g = tonumber(hex:sub(5, 6), 16) / 255
            b = tonumber(hex:sub(7, 8), 16) / 255
        elseif #hex == 6 then
            r = tonumber(hex:sub(1, 2), 16) / 255
            g = tonumber(hex:sub(3, 4), 16) / 255
            b = tonumber(hex:sub(5, 6), 16) / 255
        else
            error("Invalid hex color format. Use #RRGGBB or #AARRGGBB.")
        end
    end
    return r, g, b, a
end
