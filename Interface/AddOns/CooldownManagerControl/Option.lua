local addonName, addonTable = ...
local addon                 = addonTable.Core

function addon:GetOption()
    if addonTable.GUI then return addonTable.GUI end

    -- Create the main GUI frame
    addon:CreateBasePanel("|cff0099ccCooldown Manager|r Control", "Essential Cooldowns")

    -- Layout
    --addon:CreateTab(1, "CMC_Layout", "Viewer Layout")
    addon:CreateTab(1, "Essential_Layout", "Layout", "Viewer Layout for Essential Cooldowns")
    addon:CreateTab(2, "Essential_Anchor", "Position", "Viewer Positioning for Essential Cooldowns")
    addon:CreateTab(3, "Essential_Override", "Override", "Selective Override for Essential Cooldowns", function() addon:GetEssentialOverrideOptions() end)
    addon:CreateTab(4, "Essential_Item", "Item Tracking", "Item Tracking for Essential Cooldowns", function() addon:GetEssentialItemOptions() end)

    addon:CreateSubHeader(5, "Utility Cooldowns")
    addon:CreateTab(6, "Utility_Layout", "Layout", "Viewer Layout for Utility Cooldowns")
    addon:CreateTab(7, "Utility_Anchor", "Position", "Viewer Positioning for Utility Cooldowns")
    addon:CreateTab(8, "Utility_Override", "Override", "Selective Override for Utility Cooldowns", function() addon:GetUtilityOverrideOptions() end)
    addon:CreateTab(9, "Utility_Item", "Item Tracking", "Item Tracking for Utility Cooldowns", function() addon:GetUtilityItemOptions() end)

    addon:CreateSubHeader(10, "Buff Icons")
    addon:CreateTab(11, "BuffIcon_Layout", "Layout", "Viewer Layout for Buff Icons")
    addon:CreateTab(12, "BuffIcon_Anchor", "Position", "Viewer Positioning for Buff Icons")
    addon:CreateTab(13, "BuffIcon_Override", "Override", "Selective Override for Buff Icons", function() addon:GetBuffIconOverrideOptions() end)
    addon:CreateTab(14, "BuffIcon_Item", "Item Tracking", "Item Tracking for Buff Icons", function() addon:GetBuffIconItemOptions() end)

    addon:CreateSubHeader(15, "Buff Bars")
    addon:CreateTab(16, "BuffBar_Layout", "Layout", "Viewer Layout for Buff Bars")
    addon:CreateTab(17, "BuffBar_Anchor", "Position", "Viewer Positioning for Buff Bars")
    addon:CreateTab(18, "BuffBar_Override", "Override", "Selective Override for Buff Bars", function() addon:GetBuffBarOverrideOptions() end)
    addon:CreateTab(19, "BuffBar_Item", "Item Tracking", "Item Tracking for Buff Bars", function() addon:GetBuffBarItemOptions() end)

    addon:CreateSubHeader(20, "Miscellaneous")
    addon:CreateTab(21, "CMC_ImportExport", "Import/Export")
end
