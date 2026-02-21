local _, CanOpenerGlobal = ...;

local function RegisterBooleanSetting(category, varName, displayName, tooltip, defaultValue)
    local setting = Settings.RegisterProxySetting(
        category,
        "CanOpener_" .. varName,
        Settings.VarType.Boolean,
        displayName,
        defaultValue,
        function() return CanOpenerSavedVars[varName] end,
        function(value)
            CanOpenerSavedVars[varName] = value
            CanOpenerGlobal.ForceButtonRefresh()
        end
    )
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Initialize the settings for the addon
function InitSettingsMenu()
    local category = Settings.RegisterVerticalLayoutCategory("CanOpener")

    RegisterBooleanSetting(category, "showRousing", "Show Rousing Items",
        "If Checked, Rousing Elements will be shown.", true)

    RegisterBooleanSetting(category, "showLevelRestrictedItems", "Show Level-Restricted Items",
        "If Checked, items with a level requirement higher than your character's level will be shown.", true)

    if (CanOpenerGlobal.IsRemixActive) then
        RegisterBooleanSetting(category, "showRemixGems", "Show Remix Gems",
            "Display Remix Gems in the CanOpener UI.", true)

        RegisterBooleanSetting(category, "remixEpicGems", "Include Epic Gems in Remix",
            "Show Epic Remix Gems.", true)
    end

    local ignoreFrame = CreateFrame("Frame", "CanOpener_IgnoreFrame", UIParent)
    ignoreFrame:Hide()
    ignoreFrame.name = "Ignore Lists"

    Settings.RegisterCanvasLayoutSubcategory(category, ignoreFrame, "Ignore Lists")

    do
        local title = ignoreFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 10, -10)
        title:SetText("Ignore Lists")

        local charHeader = ignoreFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        charHeader:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
        charHeader:SetText("This Character's Ignore List")

        local charScroll = CreateFrame("ScrollFrame", "CanOpener_CharacterIgnoreScroll", ignoreFrame,
            "UIPanelScrollFrameTemplate")
        charScroll:SetSize(300, 200)
        charScroll:SetPoint("TOPLEFT", charHeader, "BOTTOMLEFT", 0, -10)

        local charContent = CreateFrame("Frame", "CanOpener_CharacterIgnoreContent", charScroll)
        charContent:SetSize(300, 200)
        charScroll:SetScrollChild(charContent)

        local rowPool = {}

        local function RefreshCharIgnoreList()
            -- Return existing rows to pool
            for _, child in ipairs({ charContent:GetChildren() }) do
                child:Hide()
                table.insert(rowPool, child)
            end

            local y = -10
            for itemID in pairs(CanOpenerSavedVars.excludedItems or {}) do
                local row = table.remove(rowPool)
                if not row then
                    row = CreateFrame("Frame", nil, charContent)
                    row:SetSize(280, 30)

                    row.icon = row:CreateTexture(nil, "ARTWORK")
                    row.icon:SetSize(30, 30)
                    row.icon:SetPoint("LEFT")

                    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    row.label:SetPoint("LEFT", row.icon, "RIGHT", 10, 0)

                    row.removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
                    row.removeBtn:SetSize(60, 20)
                    row.removeBtn:SetPoint("RIGHT")
                    row.removeBtn:SetText("Remove")
                end

                row:SetPoint("TOPLEFT", 10, y)
                row.icon:SetTexture(C_Item.GetItemIconByID(itemID) or "Interface\\Icons\\INV_Misc_QuestionMark")
                local itemName = C_Item.GetItemNameByID(itemID) or ("Item " .. itemID)
                row.label:SetText(itemName)
                row.removeBtn:SetScript("OnClick", function()
                    CanOpenerSavedVars.excludedItems[itemID] = nil
                    RefreshCharIgnoreList()
                    CanOpenerGlobal.CanOut("Removed item " .. itemID .. " from your ignore list.")
                    CanOpenerGlobal.ForceButtonRefresh()
                end)
                row:Show()

                y = y - 35
            end
        end
        RefreshCharIgnoreList()
    end
    Settings.RegisterAddOnCategory(category)
end
