------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/Item.lua - Item prices and conversions
--
-- Author: Expelliarm5s / November 2025 / All Rights Reserved
--
-- Version 1.5.1
------------------------------------------------------------------------------
-- luacheck: ignore 212 globals OEMarketInfo
-- luacheck: globals C_CurrencyInfo C_Item


local addonName, addon = ...
local Item = addon:NewModule("Item", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local private = {}
------------------------------------------------------------------------------

local GetItemInfo = GetItemInfo
if C_Item and C_Item.GetItemInfo then
	GetItemInfo = C_Item.GetItemInfo
end

------------------------------------------------------------------------------
-- Debug Stuff

function Item:DebugPrintf(...)
	if addon.isDebug then
		local status, res = pcall(format, ...)
		if status then
			addon:DebugLog("ITEM~" .. res)
		end
	end
end

-- load current session data
function Item:Login()
	Item:DebugPrintf("OnEnable()")
	Item.cache = {}
	Item.gotNIL = false

	-- check available price sources
	addon.priceSourcesList = addon.Item:GetPriceSources() or {}
end

function Item:GotNIL()
	return Item.gotNIL
end

function Item:ResetNILTry()
	Item:DebugPrintf("ResetNILTry()")
	Item.gotNIL = false
end

-- return a list of price sources
function Item:GetPriceSources()
	Item:DebugPrintf("GetPriceSources()")
	local ps = {}
	ps.VendorSell = L["VendorSell"]
	Item:DebugPrintf("  add VendorSell (%s)", tostring(ps.VendorSell))

	-- for TSM4
	local tsm4 = {}
	if TSM_API and TSM_API.GetPriceSourceKeys and TSM_API.GetPriceSourceDescription then
		local status, res = pcall(TSM_API.GetPriceSourceKeys, tsm4)
		if not status then
			Item:DebugPrintf("ERR~Broken TSM4 API: pcall of TSM_API.GetPriceSourceKeys=%s", tostring(res))
		end
	end

	local tsmSources = {}
	tsmSources["DBMarket"] = 1
	tsmSources["DBMinBuyout"] = 1
	tsmSources["DBHistorical"] = 0
	tsmSources["DBRegionMarketAvg"] = 1
	tsmSources["DBRegionHistorical"] = 0
	tsmSources["DBRegionMinBuyoutAvg"] = 0
	tsmSources["DBRegionSaleAvg"] = 1
	tsmSources["AtrValue"] = 1

	for _, k in ipairs(tsm4) do
		if tsmSources[k] and tsmSources[k] == 1 then
			-- The TSM4 API is broken, we have to strlower() the keys from TSM_API.GetPriceSourceKeys() to
			-- access the description, because the keys from TSM_API.GetPriceSourceKeys() are not the
			-- real keys of private.priceSourceInfo (in Core/Lib/CustomPrice.lua)
			-- TSM4 API it's even more broken: we have to pcall() TSM_API.GetPriceSourceDescription to have it not break
			-- this addon if something went wrong _inside_ TSM4s TSM.CustomPrice.GetDescription we have no influence of!
			local status, res = pcall(TSM_API.GetPriceSourceDescription, strlower(k))
			if status then
				ps["TSM:" .. k] = "TSM: " .. tostring(res) .. " (" .. k .. ")"
				Item:DebugPrintf("  add %s (%s)", "TSM:" .. k, ps["TSM:" .. k])
			else
				Item:DebugPrintf("Broken TSM4 API: pcall of TSM_API.GetPriceSourceDescription=%s", tostring(res))
				break
			end
		end
	end

	-- for Undermine Journal
	local uj = {}
	if TUJMarketInfo then
		uj["globalMean"] = L["Region Market Average (globalMean)"]
		uj["globalMedian"] = L["Region Market Median (globalMedian)"]
		uj["market"] = L["14-Days Market Average (market)"]
		uj["recent"] = L["3-Days Market Average (recent)"]
	end
	for k, name in pairs(uj) do
		ps["UJ:" .. k] = "UJ: " .. name
		Item:DebugPrintf("  add %s (%s)", "UJ:" .. k, ps["UJ:" .. k])
	end

	-- for OribosExchange
	local oe = {}
	if OEMarketInfo then
		oe["region"] = L["Median market price across all realms in this region (region)"]
		oe["market"] = L["Median market price on this AH over the past 4 days (market)"]
	end
	for k, name in pairs(oe) do
		ps["OE:" .. k] = "OE: " .. name
		Item:DebugPrintf("  add %s (%s)", "OE:" .. k, ps["OE:" .. k])
	end

	-- for Auction Database
	local ahdb = {}
	if AuctionDB and AuctionDB.AHGetAuctionInfoByLink then
		ahdb["minBid"] = L["minbid"]
		ahdb["minBuyout"] = L["buyout"]
	end
	for k, name in pairs(ahdb) do
		ps["AHDB:" .. k] = "AHDB: " .. name
		Item:DebugPrintf("  add %s (%s)", "AHDB:" .. k, ps["AHDB:" .. k])
	end

	return ps
end

-- get item value of ItemID/ItemLink/BaseItemString or nil
function Item:GetItemValue(link, source)
	Item:DebugPrintf("GetItemValue(%s, %s)", tostring(link), tostring(source))
	if not link or not source then
		Item:DebugPrintf("ERR~  link=%s, source=%s", tostring(link), tostring(source))
		return
	end

	private.itemValueCache = private.itemValueCache or {}
	if private.itemValueCache[tostring(link) .. tostring(source)] then
		Item:DebugPrintf("  = %s (cached)", tostring(private.itemValueCache[tostring(link) .. tostring(source)]))
		return private.itemValueCache[tostring(link) .. tostring(source)]
	end

	-- trigger cache
	Item:GetItemInfo(link)

	if source == "VendorSell" then
		local itemName, itemLink, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(link)
		if itemName and itemLink and itemRarity then
			Item:DebugPrintf("  = %s", tostring(itemSellPrice))
			if itemSellPrice and itemSellPrice == 0 then
				itemSellPrice = nil
			end
			private.itemValueCache[tostring(link) .. tostring(source)] = itemSellPrice
			return itemSellPrice
		else
			Item:DebugPrintf("ERR~  itemName=%s itemLink=%s itemRarity=%s", tostring(itemName), tostring(itemLink), tostring(itemRarity))
			return
		end
	end

	if source:match("^TSM:(.+)$") then
		local itemString
		if TSM_API and TSM_API.ToItemString then
			-- again we have to pcall() TSM_API.ToItemString to have it not break
			-- this addon if something went wrong _inside_ TSM4s TSM_API.ToItemString we have no influence of!
			-- a proper API would return just nil and we could just check against that nil!
			local status, res = pcall(TSM_API.ToItemString, link)
			if status then
				itemString = res
			else
				Item:DebugPrintf("ERR~  broken TSM4 API: pcall of TSM_API.ToItemString=%s", tostring(res))
			end
		end
		if itemString and TSM_API and TSM_API.GetCustomPriceValue and TSM_API.ToItemString then
			-- again we have to pcall() TSM_API.GetCustomPriceValue to have it not break
			-- this addon if something went wrong _inside_ TSM4s TSMAPI_FOUR.CustomPrice.GetValue we have no influence of!
			-- a proper API would return just nil and we could just check against that nil!
			local status, res = pcall(TSM_API.GetCustomPriceValue, strlower(source:match("^TSM:(.+)$")), itemString)
			if status then
				Item:DebugPrintf("  = %s", tostring(res))
				private.itemValueCache[tostring(link) .. tostring(source)] = res
				return res
			else
				Item:DebugPrintf("ERR~  broken TSM4 API: pcall of TSM_API.GetCustomPriceValue=%s", tostring(res))
			end
		end
		Item:DebugPrintf("ERR~  invalid TSM price source %s or invalid itemStringt %s", tostring(source), tostring(itemString))
		return
	end

	if source:match("^UJ:(.+)$") then
		if TUJMarketInfo then
			local s = TUJMarketInfo(link)
			local ujsource = source:match("^UJ:(.+)$")
			if s and type(s[ujsource]) == "number" then
				Item:DebugPrintf("  = %s", tostring(s[ujsource]))
				private.itemValueCache[tostring(link) .. tostring(source)] = s[ujsource]
				return s[ujsource]
			end
		end
		Item:DebugPrintf("ERR~  invalid UJ price source: %s", tostring(source))
		return
	end

	if source:match("^OE:(.+)$") then
		if OEMarketInfo then
			local s = {}
			OEMarketInfo(link,s)
			local oesource = source:match("^OE:(.+)$")
			if s and type(s[oesource]) == "number" then
				Item:DebugPrintf("  = %s", tostring(s[oesource]))
				private.itemValueCache[tostring(link) .. tostring(source)] = s[oesource]
				return s[oesource]
			end
		end
		Item:DebugPrintf("ERR~  invalid OE price source: %s", tostring(source))
		return
	end

	if source:match("^AHDB:(.+)$") then
		if AuctionDB and AuctionDB.AHGetAuctionInfoByLink then
			local auctionData = AuctionDB:AHGetAuctionInfoByLink(link)
			local ahdbsource = source:match("^AHDB:(.+)$")
			if auctionData and type(auctionData[ahdbsource]) == "number" then
				Item:DebugPrintf("  = %s", tostring(auctionData[ahdbsource]))
				private.itemValueCache[tostring(link) .. tostring(source)] = auctionData[ahdbsource]
				return auctionData[ahdbsource]
			end
		end
		Item:DebugPrintf("ERR~  invalid AHDB price source: %s", tostring(source))
		return
	end
end

-- trigger online item info cache for ItemID/ItemString/ItemLink
function Item:GetItemInfo(val)
	local req
	local key = val

	if type(val) == "number" then
		req = "item:" .. val
		key = Item:GetBaseItemString(val)
	elseif type(val) == "string" then
		if val:match("item:([0-9]+)") then
			req = val
			key = val
		elseif val:match("^i:([0-9]+)") then
			req = "item:" .. Item:GetItemID(val)
			key = Item:GetBaseItemString(val)
		end
	end

	if not (req and key) then
		return
	end

	if key and Item.cache[key] and Item.cache[key].ok then
--		Item:DebugPrintf("GetItemInfo(%s) cached n=%s, l=%s, q=%s, v=%s, bop=%s",
--			val, Item.cache[key].name, Item.cache[key].link, tostring(Item.cache[key].quality),
--			tostring(Item.cache[key].vendorSell), tostring(Item.cache[key].bop))
		return true
	end

	if type(req) == "string" then
		local name, link, quality, _, _, _, _, _, _, _, vendorSell, _, _, bindType = GetItemInfo(req)
		if name and link then
			local item = {}
			item.ok = true
			item.name = name
			item.link = link
			item.quality = quality
			item.vendorSell = vendorSell
			item.bop = (bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST) and 1
			Item.cache[key] = item
--			Item:DebugPrintf("GetItemInfo(%s) n=%s, l=%s, q=%s, v=%s, bop=%s",
--				val, Item.cache[key].name, Item.cache[key].link, tostring(Item.cache[key].quality),
--				tostring(Item.cache[key].vendorSell), tostring(Item.cache[key].bop))
			return true
		else
			Item.gotNIL = true
--			Item:DebugPrintf("GetItemInfo(%s) req=%s key=%s is nil ?!", tostring(val), req, key)
		end
	end
end

-- get offline ItemID/ItemString/ItemLink/PetString/PetLink to a TSM ItemString/PetString or nil
function Item:GetItemString(val)
	-- Item:DebugPrintf("GetItemString(%s)", tostring(val))
	if not val then
		return
	end

	-- ItemID
	if type(val) == "number" then
		-- Item:DebugPrintf("  is ID >> i:%s" .. tostring(val))
		return "i:" .. tostring(val)
	end

	-- item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:suffixID:uniqueID:linkLevel:specializationID:
	--   upgradeTypeID:instanceDifficultyID:numBonusIDs[:bonusID1:bonusID2:...][:upgradeValue1:upgradeValue2:...]:
	--   relic1NumBonusIDs[:relic1BonusID1:relic1BonusID2:...]:relic2NumBonusIDs[:relic2BonusID1:relic2BonusID2:...]:
	--   relic3NumBonusIDs[:relic3BonusID1:relic3BonusID2:...]

	if type(val) == "string" then
		-- Link
		-- item:14942::::::1030:679869824:43:::::::
		local itemString = val:match("item:([0-9:%-]+)\124")
		if itemString then
			local s = itemString:match("^([0-9]+)::::::::[0-9]+:[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1a >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+)::::::::[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1aa >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+):::::::[0-9]+:[0-9]+:[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1b >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+)::::::::[0-9]+:[0-9]+::[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1c >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+::::::::[0-9]+:[0-9]+:::1:[0-9]+:::)$")
			if s then
				-- Item:DebugPrintf("  is Link/1d >> i:%s", s)
				return "i:" .. s
			end
			-- Item:DebugPrintf("  is Link/1 >> i:%s", itemString)
			return "i:" .. itemString

		end

		itemString = val:match("^item:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is Link/2 >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- ItemString
		itemString = val:match("^i:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is ItemString >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- ItemString
		itemString = val:match("^i:([0-9:%-]+)[% ]+$")
		if itemString then
			-- Item:DebugPrintf("  is ItemString >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- battle pet link
		itemString = val:match("battlepet:([0-9]+:[0-9]+:[0-9]+)")
		if itemString then
			-- Item:DebugPrintf("  is PetLink >> p:%s", itemString)
			return "p:" .. itemString
		end

		-- PetString
		itemString = val:match("^p:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is PetString >> p:%s", itemString)
			return "p:" .. itemString
		end
	end

	Item:DebugPrintf("  GetItemString(%s) = nil ?!", tostring(val))
end

-- get offline ItemID/ItemString/ItemLink/PetString/PetLink to a TSM BaseItemString/BasePetString or nil
function Item:GetBaseItemString(val)
--	Item:DebugPrintf("GetBaseItemString(%s)", tostring(val))
	if not val then
		return
	end

	local itemString = Item:GetItemString(val)
--	Item:Printf("  GetItemString(%s)=%s", tostring(val), tostring(itemString))

	if itemString and type(itemString) == "string" and itemString ~= "" then
		local baseItemString = itemString:match("^([pi]:%d+)")
		if baseItemString then
--			Item:DebugPrintf("  is Item/PetString >> %s", itemString)
			return baseItemString
		end
	end

	Item:DebugPrintf("  GetBaseItemString(%s) = nil ?!", tostring(val))
end

-- get online quality of ItemID/ItemString/ItemLink/PetString/PetLink or nil
-- get offline quality of ItemLink or nil
function Item:GetItemQuality(val, link)
--	Item:DebugPrintf("GetItemQuality(%s, %s)", tostring(val), tostring(link))

	-- try online
	Item:GetItemInfo(val)
	if val and Item.cache[val] and Item.cache[val].ok then
		return Item.cache[val].quality
	end

	-- offline
	if link and type(link) == "string" then
		for i = 0, 8 do
			if link:match(ITEM_QUALITY_COLORS[i].hex) then
				return i
			end
		end
		if link:match("cffa335ee") then
			return 4
		end
		local v = strmatch(link, "^\124cnIQ([0-9]):\124")
		if v then return v end
	end
end

-- get online name of ItemID/ItemString/ItemLink/PetString/PetLink or nil
-- get offline name of ItemLink or nil
function Item:GetItemName(val, link)
--	Item:DebugPrintf("GetItemName(%s, %s)", tostring(val), tostring(link))

	-- try online
	Item:GetItemInfo(val)
	if val and Item.cache[val] and Item.cache[val].ok then
		return Item.cache[val].name
	end

	-- offline
	if link and type(link) == "string" then
		local name = link:match("\124h%[(.+)%]\124h")
		if name then
			return name
		end
	end
end

-- get offline ItemID of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemID(val)
--	Item:DebugPrintf("GetItemID(%s)", tostring(val))

	if type(val) == "number" then
		return val
	end

	local lval = Item:GetBaseItemString(val)
	if type(lval) == "string" then
		local id = lval:match("^i:([0-9]+)")
		if id and tonumber(id) then
			return tonumber(id)
		end
	end
end

-- get online ItemLink of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemLink(val)
--	Item:DebugPrintf("GetItemLink(%s)", tostring(val))

	-- try online
	Item:GetItemInfo(val)
	if val and Item.cache[val] and Item.cache[val].ok then
		return Item.cache[val].link
	end
end

-- get online soulbound status of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemIsBOP(val)
--	Item:DebugPrintf("GetItemIsBOP(%s)", tostring(val))

	-- try online
	Item:GetItemInfo(val)
	if val and Item.cache[val] and Item.cache[val].ok then
		return Item.cache[val].bop
	end
end

-- get offline ItemLink of Currency or nil
-- FIXME: put into cache
function Item:GetCurrencyLink(val)
--	Item:DebugPrintf("GetCurrencyLink(%s)", tostring(val))

	local res = nil
	if val and type(val) == "string" and val:match("|Hcurrency") then
		if val:match(":(%d+)|h") then
			res = gsub(val, ":(%d+)|h", ":0|h")
		end
	end
	return res
end

-- EOF
