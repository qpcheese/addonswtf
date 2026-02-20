local vlevel = 0;
local clasa = "";
local desired = nil;
local merchantopen = false;
local skills = {};
local gimme = nil;
venbuysettings = {};
local vbenabled = true;
local recipes = true;
local wanted = true;
local heirlooms = 7;
local undesired = true;
local playerClass = "";

function Vchattext(txt)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00e0ffVendorBuy|r: " .. txt)
    end
end

function VendorBuy_OnLoad(self, event, ...)
    playerClass, clasa = UnitClass("player");
    vlevel = UnitLevel("player");
    desired = nil;
    gimme = nil;
    merchantopen = false;

    skills = {};

    self:RegisterEvent("MERCHANT_SHOW");
    self:RegisterEvent("MERCHANT_UPDATE");
    hooksecurefunc("MerchantFrame_Update", VendorBuy_UpdateMerchantButtons);
    self:RegisterEvent("MERCHANT_CLOSED");
    self:RegisterEvent("VARIABLES_LOADED");

    self:RegisterEvent("PLAYER_LEVEL_UP");

    Vchattext("Loaded");

    VendorBuy_UpdateDesired();

    SlashCmdList["VENBUY"] = VendorParseCommand;
    SLASH_VENBUY1 = "/venbuy";
end

function VendorBuy_UpdateSettings()
    venbuysettings['vbenabled'] = vbenabled;
    venbuysettings['recipes'] = recipes;
    venbuysettings['wanted'] = wanted;
    venbuysettings['heirlooms'] = heirlooms;
    venbuysettings['undesired'] = undesired;
end

function VendorBuy_LoadSettings()
    if (venbuysettings['vbenabled'] ~= nil) then
        vbenabled = venbuysettings['vbenabled'];
    end
    if (venbuysettings['recipes'] ~= nil) then
        recipes = venbuysettings['recipes'];
    end
    if (venbuysettings['wanted'] ~= nil) then
        wanted = venbuysettings['wanted'];
    end
    if (venbuysettings['heirlooms'] ~= nil) then
        heirlooms = venbuysettings['heirlooms'];
    end
    if (venbuysettings['undesired'] ~= nil) then
        undesired = venbuysettings['undesired'];
    end
end

function updateskills()
    skills = {};
    local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions();
    if (archaeology ~= nil) then
        skills["Archaeology"] = "Archaeology";
    end
    if (fishing ~= nil) then
        skills["Fishing"] = "Fishing";
    end
    if (cooking ~= nil) then
        skills["Cooking"] = "Cooking";
    end
    if (firstAid ~= nil) then
        skills["First Aid"] = "First Aid";
    end
    if (prof1 ~= nil) then
        local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier = GetProfessionInfo(prof1);
        skills[name] = name;
    end
    if (prof2 ~= nil) then
        local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier = GetProfessionInfo(prof2);
        skills[name] = name;
    end
end

function VendorParseCommand(cmd)
    local goodcmd = false;
    if (cmd:upper() == "OFF") then
        goodcmd = true;
        vbenabled = false;
        Vchattext("VendorBuy Disabled");
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end
    if (cmd:upper() == "ON") then
        goodcmd = true;
        vbenabled = true;
        Vchattext("VendorBuy Enabled");
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end
    if (cmd:upper() == "RECIPES") then
        goodcmd = true;
        if (recipes) then
            recipes = false;
        else
            recipes = true;
        end
        if (recipes) then
            Vchattext("Recipes filtering enabled");
        else
            Vchattext("Recipes filtering disabled");
        end
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end
    if (cmd:upper() == "UNDESIRED") then
        goodcmd = true;
        if (undesired) then
            undesired = false;
        else
            undesired = true;
        end
        if (undesired) then
            Vchattext("Undesirable filtering enabled");
        else
            Vchattext("Undesirable filtering disabled");
        end
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end
    if ((cmd:upper() == "STATS") or (cmd:upper() == "WANTED")) then
        goodcmd = true;
        if (wanted) then
            wanted = false;
        else
            wanted = true;
        end
        if (wanted) then
            Vchattext("Wanted stats filtering enabled");
        else
            Vchattext("Wanted stats filtering disabled");
        end
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end

    if ((cmd:upper() == "HEIRLOOMS") or (cmd:upper() == "LOOMS")) then
        goodcmd = true;
        if (heirlooms == 8) then
            heirlooms = 7;
        else
            heirlooms = 8;
        end
        if (heirlooms == 8) then
            Vchattext("Heirloom filtering enabled");
        else
            Vchattext("Heirloom filtering disabled");
        end
        if (merchantopen) then
            for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
                local item = getglobal("MerchantItem" .. i);
                local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
                SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                SetItemButtonSlotVertexColor(item, 1, 1, 1);
                SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
                SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);

                item:SetAlpha(1);
            end
            update();
        end
    end

    if (goodcmd == false) then
        Vchattext("CLI commands:");
        Vchattext("/venbuy off => disable VendorBuy");
        Vchattext("/venbuy on => enable VendorBuy");
        Vchattext("/venbuy recipes => enable/disable highlighting of already known recipes");
        Vchattext("/venbuy undesired => enable/disable highlighting of usable but undesired gear");
        Vchattext("/venbuy heirlooms => enable/disable filtering of heirlooms");
        Vchattext("/venbuy wanted => enable highlighting by desired stat");
        Vchattext("/venbuy stats => same as *wanted*");
        Vchattext("/venbuy looms => same as *heirlooms*");
        if (vbenabled == false) then
            Vchattext("VendorBuy is now Disabled");
        else
            Vchattext("VendorBuy is now Enabled");
        end
    end
    if (goodcmd) then
        VendorBuy_UpdateSettings();
        if ((cmd:upper() ~= "OFF") and (cmd:upper() ~= "ON") and (vbenabled == false)) then
            Vchattext("But VendorBuy is Disabled");
        end
    end
end

function VendorBuy_UpdateDesired()
    desired = nil;
    gimme = nil;

    if ((clasa == "WARRIOR") or (clasa == "PALADIN") or (clasa == "DEATHKNIGHT")) then
        desired = "Plate";
    end
    if ((clasa == "HUNTER") or (clasa == "SHAMAN")) then
        desired = "Mail";
    end
    if ((clasa == "PRIEST") or (clasa == "MAGE") or (clasa == "WARLOCK")) then
        desired = "Cloth";
    end
    if ((clasa == "ROGUE") or (clasa == "DRUID") or (clasa == "MONK") or (clasa == "DEMONHUNTER") or (clasa=="Dracthyr")) then
        desired = "Leather";
    end

    if ((clasa == "WARRIOR") or (clasa == "DEATHKNIGHT")) then
        gimme = "STR";
    end
    if ((clasa == "HUNTER") or (clasa == "ROGUE") or (clasa == "DEMONHUNTER")) then
        gimme = "AGI";
    end
    if ((clasa == "PRIEST") or (clasa == "MAGE") or (clasa == "WARLOCK")) then
        gimme = "INT";
    end
end

function VendorBuy_OnEvent(self, event, arg1, ...)
    if (event == "VARIABLES_LOADED") then
        VendorBuy_LoadSettings();
    end
    if (event == "MERCHANT_SHOW") then
        merchantopen = true;
        updateskills();
    end

    if ((event == "MERCHANT_CLOSED") and (merchantopen)) then
        merchantopen = false;
        for i = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
            local item = getglobal("MerchantItem" .. i);
            local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
            SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
            SetItemButtonSlotVertexColor(item, 1, 1, 1);
            SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
            SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);
            item:SetAlpha(1);
        end
    end

    if (event == "PLAYER_LEVEL_UP") then
        VendorBuy_UpdateDesired();
    end
end

function VendorBuy_UpdateMerchantButtons()
    if ((merchantopen == false) or (vbenabled == false)) then
        return ;
    end

    if (MerchantFrame.selectedTab == 2) then
        for i = 1, BUYBACK_ITEMS_PER_PAGE, 1 do
            local item = getglobal("MerchantItem" .. i);
            local itemButton = _G["MerchantItem" .. i .. "ItemButton"];
            SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
            SetItemButtonSlotVertexColor(item, 1, 1, 1);
            SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
            SetItemButtonNormalTextureVertexColor(itemButton, 1, 1, 1);
            item:SetAlpha(1);
        end
        return ;
    end

    for m = 1, MERCHANT_ITEMS_PER_PAGE, 1 do
        local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + m);
        local item = _G["MerchantItem" .. m];
        local itemButton = _G["MerchantItem" .. m .. "ItemButton"];
        item:SetAlpha(1);

        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, textureID, vendorPrice, itemCategory, categoryVersion;
        local name, texture, price, quantity, numAvailable, isUsable, extendedCost = C_MerchantFrame.GetItemInfo(index);
        local link = GetMerchantItemLink(index);

        local notCollected = false;
        local known = false;
        local legionUpgrade = false;
        local tooltipLines = {}

        if (link) then
            itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, textureID, vendorPrice, itemCategory, categoryVersion = GetItemInfo(link);

            local tooltipData = C_TooltipInfo.GetHyperlink(link)
            for _, line in ipairs(tooltipData.lines) do
                if (line.leftText and (line.leftText ~= "") and line.leftColor) then
                    local lineData = {}
                    lineData['text'] = line.leftText:gsub('^"*(.-)"*$', '%1')
                    lineData['r'] = line.leftColor['r']
                    lineData['g'] = line.leftColor['g']
                    lineData['b'] = line.leftColor['b']

                    table.insert(tooltipLines, lineData)
                end
                if (line.rightText and line.rightColor) then
                    local lineData = {}

                    lineData['text'] = line.rightText:gsub('^"*(.-)"*$', '%1')
                    lineData['r'] = line.rightColor['r']
                    lineData['g'] = line.rightColor['g']
                    lineData['b'] = line.rightColor['b']

                    table.insert(tooltipLines, lineData)
                end
            end
            --
            --DevTools_Dump(tooltipLines)
            --
            if ((itemType == 'Recipe') and (skills[itemSubType])) then
                isUsable = true;
            end

            for pos, val in pairs(tooltipLines) do
                local text = val['text'];
                if ((text) and (text == "Already known")) then
                    known = true;
                end
                if ((text) and (string.find(text, "Collected") ~= nil)) then
                    known = true;
                end
                if ((text) and (string.find(text, "You haven't collected this appearance") ~= nil)) then
                    notCollected = true;
                end
                if ((text) and (text == "Requires Previous Rank")) then
                    legionUpgrade = true;
                end
                if (text) then
                    local a = val['r']
                    local b = val['g']
                    local c = val['b']
                    a = round(a);
                    b = round(b);
                    c = round(c);
                    if ((a > b) and (b == c)) then
                        isUsable = false;
                    end
                end
            end

            if ((itemType == 'Recipe') and (skills[itemSubType])) then
                isUsable = true;
            end
        end

        if ((not isUsable) and (link)) then
            local gasit = false;
            if (itemRarity < heirlooms) then
                for pos, val in pairs(tooltipLines) do
                    local text = val['text'];
                    if (text) then
                        local a = val['r']
                        local b = val['g']
                        local c = val['b']
                        a = round(a);
                        b = round(b);
                        c = round(c);
                        if ((a > b) and (b == c)) then
                            if ((string.find(text, "Collected") ~= nil)) then
                                gasit = true;
                            end
                            if ((string.find(text, "Requires ") ~= nil) and (string.find(text, "Requires Level") == nil) and (string.find(text, "Friendly") == nil) and (string.find(text, "Honored") == nil) and (string.find(text, "Revered") == nil) and (string.find(text, "Exalted") == nil)) then
                                local isskill = false;
                                for si, sv in pairs(skills) do
                                    if (string.find(text, si) ~= nil) then
                                        isskill = true;
                                        break ;
                                    end
                                end
                                if (isskill == false) then
                                    gasit = true;
                                    break ;
                                end
                            end
                        end
                    end
                end
            end
            if (gasit == true) then
                item:SetAlpha(0.1);
            end

            if ((itemRarity < heirlooms) and (link) and (gasit == false)) then
                if ((itemType == "Armor") and (itemSubType ~= "Miscellaneous") and (itemEquipLoc ~= "INVTYPE_CLOAK") and (itemEquipLoc ~= "INVTYPE_SHIELD") and (itemEquipLoc ~= "INVTYPE_RELIC")) then
                    if ((undesired) and (itemSubType ~= desired)) then
                        item:SetAlpha(0.5);
                    end
                end
            end
            if (itemRarity == heirlooms) then
                if (known) then
                    item:SetAlpha(0.3);
                else
                    SetItemButtonNameFrameVertexColor(item, 0.6, 1, 0.6);
                    SetItemButtonSlotVertexColor(item, 0.6, 1, 0.6);
                    SetItemButtonTextureVertexColor(itemButton, 0.6, 1, 0.6);
                    SetItemButtonNormalTextureVertexColor(itemButton, 0.6, 1, 0.6);
                    item:SetAlpha(1);
                end
            end
        else
            if (link) then
                if (notCollected) then
                    SetItemButtonNameFrameVertexColor(item, 0.3, 1, 0.3);
                    SetItemButtonSlotVertexColor(item, 0.3, 1, 0.3);
                    SetItemButtonTextureVertexColor(itemButton, 0.3, 1, 0.3);
                    SetItemButtonNormalTextureVertexColor(itemButton, 0.3, 1, 0.3);
                    item:SetAlpha(1);
                else
                    if ((itemRarity) and (itemRarity < heirlooms)) then
                        if ((itemType == "Armor") and (itemSubType ~= "Miscellaneous") and (itemEquipLoc ~= "INVTYPE_CLOAK") and (itemEquipLoc ~= "INVTYPE_SHIELD") and (itemEquipLoc ~= "INVTYPE_RELIC")) then
                            if ((undesired) and (itemSubType ~= desired)) then
                                item:SetAlpha(0.5);
                            end
                            if ((gimme) and (wanted)) then
                                local stats = C_Item.GetItemStats(itemLink);
                                local str = tonumber(stats["ITEM_MOD_STRENGTH_SHORT"] or 0);
                                local agi = tonumber(stats["ITEM_MOD_AGILITY_SHORT"] or 0);
                                local int = tonumber(stats["ITEM_MOD_INTELLECT_SHORT"] or 0);
                                local isgood = false;

                                if ((gimme == 'STR') and (str > 0)) then
                                    isgood = true;
                                end
                                if ((gimme == 'AGI') and (agi > 0)) then
                                    isgood = true;
                                end
                                if ((gimme == 'INT') and (int > 0)) then
                                    isgood = true;
                                end

                                if (isgood) then
                                    SetItemButtonNameFrameVertexColor(item, 1, 1, 1);
                                    SetItemButtonSlotVertexColor(item, 0, 1, 0);
                                    SetItemButtonTextureVertexColor(itemButton, 0, 1, 0);
                                    SetItemButtonNormalTextureVertexColor(itemButton, 0, 1, 0);
                                    item:SetAlpha(1);
                                end
                            end
                        else
                            if ((recipes) and (itemType == 'Recipe')) then
                                if (legionUpgrade and not known) then
                                    SetItemButtonNameFrameVertexColor(item, 0.6, 0.6, 1.0);
                                    SetItemButtonSlotVertexColor(item, 0.6, 0.6, 0.9);
                                    SetItemButtonTextureVertexColor(itemButton, 0.6, 0.6, 1.0);
                                    SetItemButtonNormalTextureVertexColor(itemButton, 0.6, 0.6, 1.0);
                                    item:SetAlpha(0.7);
                                end
                            end
                        end
                    end
                end
                if (known) then
                    SetItemButtonNameFrameVertexColor(item, 1.0, 0.0, 1.0);
                    SetItemButtonSlotVertexColor(item, 1.0, 0.0, 1.0);
                    SetItemButtonTextureVertexColor(itemButton, 1.0, 0, 1.0);
                    SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 0, 1.0);
                    item:SetAlpha(0.4);
                end
            end
        end

    end
end

function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
