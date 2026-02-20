------------------------------------------------------------------------------
-- Rematch_TSMPetValues - Add TSM market values to the Rematch pet list
------------------------------------------------------------------------------
-- PetItem_Value.lua - Pet Item Functions
--
-- Author: Expelliarm5s / November 2025 / All Rights Reserved
--
-- Version 1.3.2
------------------------------------------------------------------------------
-- luacheck: ignore 212 globals DLAPI OEMarketInfo C_CurrencyInfo

local addonName, addon = ...
local PetItem_Value = addon:NewModule("PetItem_Value", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
-- local private = {}

------------------------------------------------------------------------------
-- Debug Stuff

function PetItem_Value:DebugPrintf(...)
	if addon.isDebug then
		local status, res = pcall(format, ...)
		if status then
			addon:DebugLog("PITSM~" .. res)
		end
	end
end

------------------------------------------------------------------------------
-- Addon Loading / Player Login/Logout

function PetItem_Value:Login()
	PetItem_Value:DebugPrintf("Login()")

	----------------------------------------------------------------------------------------------------
	-- Check for TSM4
	addon.db.global[PetItem_Value.moduleName] = true
	if TSM_API and TSM_API.IsCustomPriceValid and TSM_API.GetCustomPriceValue then
		PetItem_Value:DebugPrintf("  found TSM4 and TSM_API.IsCustomPriceValid and TSM_API.GetCustomPriceValue")
	elseif OEMarketInfo then
		PetItem_Value:DebugPrintf("  found OEMarketInfo")
	else
		addon.db.global[PetItem_Value.moduleName] = false
	end

	-- check price availability
	C_Timer.After(10, function()
		if TSM_API then
			if TSM_API.GetCustomPriceValue then
				local val1 = PetItem_Value.GetPetGoldValue("p:141", "DBRegionMarketAvg")
				local val2 = PetItem_Value.GetPetGoldValue("p:1628", "DBRegionMarketAvg")

				if (val1 and val1 > 0) or (val2 and val2 > 0) then
					addon:Printf("|cff88ff88" .. L["Found usable data from TradeSkillMaster."] .. "|r")
					addon:DebugPrintf("  found pet data for p:141 or p:1628 (%s / %s)", tostring(val1), tostring(val2))
				else
					addon:Printf("|cffff8888" .. L["No usable data from TradeSkillMaster found! Please check your TradeSkillMaster Desktop App."] .. "|r")
				end
			else
				addon:Printf("|cffff8888" .. L["TradeSkillMaster not found!"] .. "|r")
			end
		else
			addon:Printf("|cffff8888" .. L["TradeSkillMaster not found!"] .. "|r")
			if OEMarketInfo then
				local info = {}
				local ok = pcall(OEMarketInfo, "battlepet:1624:1:3:152:13:10:", info)
				if ok then
					addon:DebugPrintf("  info(region): %s", tostring(info["region"]))
					if (info["region"] and tonumber(info["region"]) and info["region"] > 0) then
						addon:Printf("|cff88ff88" .. L["Found usable data from Oribos Exchange."] .. "|r")
						addon:DebugPrintf("  found pet data for p:141 (%s)", tostring(info["region"]))
					end
				else
					addon:DebugPrintf("  API-Error OEMarketInfo)")
				end
			else
				addon:Printf("|cffff8888" .. L["Oribos Exchange not found!"] .. "|r")
			end
		end
	end)
end

addon.petGoldValueC = {}

-- goldValue = GetPetGoldValue(petItemString, priceSource)
function PetItem_Value.GetPetGoldValue(petItemString, priceSource, priceSource2)
	PetItem_Value:DebugPrintf("GetPetGoldValue(%s, %s)", tostring(petItemString), tostring(priceSource))
	local price = 0
	if not priceSource then
		addon.aError = L["check empty price source"]
		return price
	end
	if petItemString then
		if priceSource and addon.petGoldValueC[petItemString .. priceSource] then
			return addon.petGoldValueC[petItemString .. priceSource]
		end
		if priceSource2 and addon.petGoldValueC[petItemString .. priceSource2] then
			return addon.petGoldValueC[petItemString .. priceSource2]
		end
		if TSM_API and TSM_API.IsCustomPriceValid and TSM_API.GetCustomPriceValue then
				-- TSM4 API is broken: we have to pcall() IsCustomPriceValid and GetCustomPriceValue to have it not break
				-- this addon if something went wrong _inside_ TSM4 we have no influence of!
				local status1, res1 = pcall(TSM_API.IsCustomPriceValid, priceSource)
				if status1 then
					if res1 then
						local status2, res2 = pcall(TSM_API.GetCustomPriceValue, priceSource, petItemString)
						if status2 then
							if tonumber(res2) then
								price = floor(res2 / COPPER_PER_GOLD)
							end
						else
							PetItem_Value:DebugPrintf("ERR~TSM API error: %s", tostring(res2))
							addon.aError = L["TSM API error"] .. ": " .. res2
						end
					else
						PetItem_Value:DebugPrintf("ERR~TSM price source error: %s", tostring(priceSource))
						priceSource = priceSource or L["invalid price source"]
						addon.aError = L["TSM price source error"] .. ": " .. priceSource
					end
				else
					PetItem_Value:DebugPrintf("ERR~TSM API error: %s", tostring(res1))
					addon.aError = L["TSM API error"] .. ": " .. res1
				end
				addon.petGoldValueC[petItemString .. priceSource] = price
		elseif OEMarketInfo then
			local info = {}
			local petItemString2 = string.gsub(petItemString, "^p", "battlepet")
			PetItem_Value:DebugPrintf("  pcall(OEMarketInfo, %s, info)", tostring(petItemString2))
			OEMarketInfo(petItemString2, info)
			PetItem_Value:DebugPrintf("  OEMarketInfo: %s %s", tostring(info), tostring(info["input"]))
			if info and info["market"] and tonumber(info[priceSource2]) and tonumber(info[priceSource2]) > 0 then
				price = floor(tonumber(info[priceSource2]) / COPPER_PER_GOLD)
			end
			addon.petGoldValueC[petItemString .. priceSource2] = price
		end

		-- debugging without loaded TSM
		-- price = 1234
		-- addon.petGoldValueC[petItemString .. priceSource] = price
		-- MoneyToString = function(w) return tostring(w) end

	end
	return price
end

local GetCoinTextureString =  GetCoinTextureString
if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then
	GetCoinTextureString = C_CurrencyInfo.GetCoinTextureString
end

local MoneyToString = function(value)
	local v
	if value and tonumber(value) then
		v = GetCoinTextureString(value)
	else
		v = "0|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t"
	end
	return v
end

-- priceInfoString = GetPriceInfo(petItemString)
function PetItem_Value.GetPriceInfo(petItemString, link)
	PetItem_Value:DebugPrintf("GetPriceInfo(%s)", tostring(petItemString))
	local priceInfo = ""
	local fps = 0
	local sps = 0

	if TSM_API and addon.db.global.valA then
		local itemValue = PetItem_Value.GetPetGoldValue(petItemString, addon.db.global.valA, "market")
		if itemValue and itemValue > 0 then
			local itemValueString = MoneyToString(itemValue * COPPER_PER_GOLD) or tostring(itemValue)
			priceInfo = itemValueString
			fps = itemValue
		else
			priceInfo = "0"
		end
	elseif OEMarketInfo then
		local info = {}
		-- link = "battlepet:1624:1:3:152:13:10:"
		petItemString = string.gsub(petItemString, "^p", "battlepet")
		PetItem_Value:DebugPrintf("  pcall(OEMarketInfo, %s, info)", tostring(petItemString))
		OEMarketInfo(petItemString, info)
		PetItem_Value:DebugPrintf("  OEMarketInfo: %s %s", tostring(info), tostring(info["input"]))
		if info and info["market"] and tonumber(info["market"]) and tonumber(info["market"]) > 0 then
			priceInfo = MoneyToString(floor(tonumber(info["market"]) / COPPER_PER_GOLD) * COPPER_PER_GOLD) or tostring(info["market"])
		else
			priceInfo = "0"
		end
	end

	if TSM_API and addon.db.global.valB then
		local itemValue = PetItem_Value.GetPetGoldValue(petItemString, addon.db.global.valB, "region")
		if itemValue and itemValue > 0 then
			local itemValueString = MoneyToString(itemValue * COPPER_PER_GOLD) or tostring(itemValue)
			priceInfo = priceInfo .. " / " .. itemValueString
			sps = itemValue
		else
			priceInfo = priceInfo .. " / 0"
		end
	elseif OEMarketInfo then
		local info = {}
		-- link = "battlepet:1624:1:3:152:13:10:"
		petItemString = string.gsub(petItemString, "^p", "battlepet")
		PetItem_Value:DebugPrintf("  pcall(OEMarketInfo, %s, info)", tostring(petItemString))
		local ok = pcall(OEMarketInfo, petItemString, info)
		PetItem_Value:DebugPrintf("  OEMarketInfo: %s %s", tostring(info), tostring(info["input"]))
		if ok then
			if info["region"] and tonumber(info["region"]) and tonumber(info["region"]) > 0 then
				priceInfo = priceInfo .. " / " .. MoneyToString(floor(tonumber(info["region"]) / COPPER_PER_GOLD) * COPPER_PER_GOLD) or tostring(info["region"])
			else
				priceInfo = priceInfo .. " / 0"
			end
		end
	end

	local aTrigger
	local fixedTrigger = tonumber(addon.db.global.valTH)
	if fixedTrigger ~= nil then
		aTrigger = fixedTrigger
	else
		if TSM_API then
			aTrigger = PetItem_Value.GetPetGoldValue(petItemString, addon.db.global.valTH)
		end
	end

	if (priceInfo == "0" or priceInfo == "0 / 0" or priceInfo == "0c / 0c") then
		priceInfo = nil
	else
		if fps > 0 and sps > 0 and aTrigger then
			if ((fps - sps) >= 0) then
				if ((fps - sps) >= (aTrigger * 3)) then
					priceInfo = "+++ " .. priceInfo
				elseif ((fps - sps) >= (aTrigger * 2)) then
					priceInfo = "++ " .. priceInfo
				elseif ((fps - sps) >= (aTrigger * 1)) then
					priceInfo = "+ " .. priceInfo
				end
			end
			if ((sps - fps) > 0) then
				if ((sps - fps) > (aTrigger * 3)) then
					priceInfo = "--- " .. priceInfo
				elseif ((sps - fps) > (aTrigger * 2)) then
					priceInfo = "-- " .. priceInfo
				elseif ((sps - fps) > (aTrigger * 1)) then
					priceInfo = "- " .. priceInfo
				end
			end
		end
	end

	PetItem_Value:DebugPrintf("  %s", tostring(priceInfo))
	return priceInfo
end

