local _, HighLevelAlert = ...
local DEBUG = false
local COLR = "|cffff0000"
local COLY = "|cffffff00"
local function getFontName()
	if GetLocale() == "koKR" or GetLocale() == "zhCN" or GetLocale() == "zhTW" then return "Fonts\\2002.TTF" end

	return "Fonts\\FRIZQT__.TTF"
end

--[[FRAME]]
local hla = CreateFrame("Frame", "HighLevelAlertFrame", UIParent)
hla:SetSize(800, 50)
hla:SetPoint("CENTER", 0, 240)
hla:Hide()
--[[TEXT]]
hla.text = hla:CreateFontString(nil, "ARTWORK", "GameFontNormal")
hla.text:SetAllPoints(true)
hla.text:SetFont(getFontName(), 42, "OUTLINE")
hla.text:SetText("")
function HighLevelAlert:SetShowText(val)
	if val then
		hla:Show()
	else
		hla:Hide()
	end
end

function HighLevelAlert:SetTextScale(val)
	if val then
		hla:SetScale(val)
	end
end

--[[TEXTURE]]
hla.texv = hla:CreateTexture(nil, "OVERLAY")
hla.texv:SetColorTexture(1, 1, 1, 1)
hla.texv:SetSize(2, hla:GetHeight())
hla.texv:SetPoint("CENTER", hla, "CENTER")
hla.texh = hla:CreateTexture(nil, "OVERLAY")
hla.texh:SetColorTexture(1, 1, 1, 1)
hla.texh:SetSize(hla:GetWidth(), 2)
hla.texh:SetPoint("CENTER", hla, "CENTER")
local texv = UIParent:CreateTexture(nil, "OVERLAY")
texv:SetColorTexture(1, 1, 1, 0.5)
texv:SetSize(2, UIParent:GetHeight())
texv:SetPoint("CENTER", UIParent, "CENTER")
texv:Hide()
local texh = UIParent:CreateTexture(nil, "OVERLAY")
texh:SetColorTexture(1, 1, 1, 0.5)
texh:SetSize(UIParent:GetWidth(), 2)
texh:SetPoint("CENTER", UIParent, "CENTER")
texh:Hide()
local hlaShown = nil
local fThink = CreateFrame("FRAME")
fThink:HookScript(
	"OnUpdate",
	function(self)
		if hla:IsShown() ~= hlaShown then
			hlaShown = hla:IsShown()
			local hlaMoving = hla.isMoving
			if hlaShown and hlaMoving then
				hla.texv:Show()
				hla.texh:Show()
				texv:Show()
				texh:Show()
			else
				hla.texv:Hide()
				hla.texh:Hide()
				texv:Hide()
				texh:Hide()
			end
		end
	end
)

function HighLevelAlert:SetPosition()
	local point, relativeTo, relativePoint, x, y = HLATAB.hlaPosition[1], HLATAB.hlaPosition[2], HLATAB.hlaPosition[3], HLATAB.hlaPosition[4], HLATAB.hlaPosition[5]
	x = HighLevelAlert:Grid(x, 10)
	y = HighLevelAlert:Grid(y, 10)
	hla:SetPoint(point, relativeTo, relativePoint, x, y)
end

hla:SetScript(
	"OnMouseDown",
	function(self, button)
		if button == "LeftButton" and not self.isMoving then
			if not HighLevelAlert:GV(HLATAB, "lockedText", true) then
				self:EnableMouse(true)
				self:SetMovable(true)
				self:StartMoving()
				self.isMoving = true
				HighLevelAlert:ShowGrid(self)
			else
				HighLevelAlert:MSG(HighLevelAlert:Trans("LID_HELPTEXTLOCKED"))
			end
		end
	end
)

hla:SetScript(
	"OnMouseUp",
	function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
			local point, _, relPoint, x, y = self:GetPoint()
			x = HighLevelAlert:Grid(x, 10)
			y = HighLevelAlert:Grid(y, 10)
			HLATAB.hlaPosition = {point, "UIParent", relPoint, x, y}
			HighLevelAlert:SetPosition()
			HighLevelAlert:HideGrid(self)
		end
	end
)

function HighLevelAlert:ToggleFrame()
	if hla then
		HighLevelAlert:SV(HLATAB, "lockedText", not HighLevelAlert:GV(HLATAB, "lockedText", true))
		if HighLevelAlert:GV(HLATAB, "lockedText", true) then
			hla:EnableMouse(false)
			hla:SetMovable(false)
			HighLevelAlert:MSG("Text is now locked.")
		else
			hla:EnableMouse(true)
			hla:SetMovable(true)
			HighLevelAlert:MSG("Text is now unlocked.")
		end
	else
		C_Timer.After(
			1,
			function()
				HighLevelAlert:ToggleFrame()
			end
		)
	end
end

--[[EVENTS]]
hla:RegisterEvent("PLAYER_LOGIN")
hla:SetScript(
	"OnEvent",
	function(self, event, ...)
		HLATAB = HLATAB or {}
		if event == "PLAYER_LOGIN" then
			hla:ClearAllPoints()
			if HLATAB.hlaPosition then
				HighLevelAlert:SetPosition()
			else
				hla:SetPoint("CENTER", UIParent, "CENTER", 0, 240)
			end

			if HighLevelAlert:GV(HLATAB, "lockedText", true) then
				hla:EnableMouse(false)
				hla:SetMovable(false)
			else
				hla:EnableMouse(true)
				hla:SetMovable(true)
			end

			for i = 1, 100 do
				if GetCVar("nameplateMaxDistance", i) ~= nil then
					local currentDist = tonumber(GetCVar("nameplateMaxDistance", i))
					if i > currentDist then
						SetCVar("nameplateMaxDistance", i)
						currentDist = tonumber(GetCVar("nameplateMaxDistance", i))
						if currentDist ~= i then break end
					end
				end
			end

			if GetCVarBool("nameplateShowAll") == false then
				HighLevelAlert:MSG(format(HighLevelAlert:Trans("LID_NPSCVAR"), UNIT_NAMEPLATES_AUTOMODE))
			end

			SetCVar("ShowClassColorInNameplate", 1)
			HLATAB["TEXTSCALE"] = HLATAB["TEXTSCALE"] or 1
			HighLevelAlert:SetTextScale(HLATAB["TEXTSCALE"])
			if HLATAB["SHOWTEXT"] == nil then
				HLATAB["SHOWTEXT"] = true
			end

			HighLevelAlert:SetShowText(HLATAB["SHOWTEXT"])
			HighLevelAlert:InitSettings()
			self:UnregisterEvent("PLAYER_LOGIN")
		end
	end
)

local NPPvp = {}
local NPSkullElite = {}
local NPSkull = {}
local NPRedElite = {}
local NPRed = {}
function HighLevelAlert:UpdateText()
	local NPPvpCount = #NPPvp
	local NPSkullEliteCount = #NPSkullElite
	local NPSkullCount = #NPSkull
	local NPRedEliteCount = #NPRedElite
	local NPRedCount = #NPRed
	if HLATAB["SHOWTEXT"] and not UnitOnTaxi("player") then
		if NPPvpCount > 0 then
			if NPPvpCount == 1 then
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_PVPNEARBY"), NPPvpCount)))
			else
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_PVPNEARBYS"), NPPvpCount)))
			end

			hla:Show()
		elseif NPSkullEliteCount > 0 then
			if NPSkullEliteCount == 1 then
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_SKULLELITESNEARBY"), NPSkullEliteCount, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0:0|t")))
			else
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_SKULLELITESNEARBYS"), NPSkullEliteCount, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0:0|t")))
			end

			hla:Show()
		elseif NPSkullCount > 0 then
			if NPSkullCount == 1 then
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_SKULLSNEARBY"), NPSkullCount, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0:0|t")))
			else
				hla.text:SetText(format("[%s%s|r] %s", COLR, HighLevelAlert:Trans("LID_WARNING"), format(HighLevelAlert:Trans("LID_SKULLSNEARBYS"), NPSkullCount, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0:0|t")))
			end

			hla:Show()
		elseif NPRedEliteCount > 0 then
			if NPRedEliteCount == 1 then
				hla.text:SetText(format("[%s%s|r] %s", COLY, HighLevelAlert:Trans("LID_CAUTION"), format(HighLevelAlert:Trans("LID_REDELITESNEARBY"), NPRedEliteCount)))
			else
				hla.text:SetText(format("[%s%s|r] %s", COLY, HighLevelAlert:Trans("LID_CAUTION"), format(HighLevelAlert:Trans("LID_REDELITESNEARBYS"), NPRedEliteCount)))
			end

			hla:Show()
		elseif NPRedCount > 0 then
			if NPRedCount == 1 then
				hla.text:SetText(format("[%s%s|r] %s", COLY, HighLevelAlert:Trans("LID_CAUTION"), format(HighLevelAlert:Trans("LID_REDSNEARBY"), NPRedCount)))
			else
				hla.text:SetText(format("[%s%s|r] %s", COLY, HighLevelAlert:Trans("LID_CAUTION"), format(HighLevelAlert:Trans("LID_REDSNEARBYS"), NPRedCount)))
			end

			hla:Show()
		else
			hla.text:SetText("")
			hla:Hide()
		end
	else
		hla.text:SetText("")
		hla:Hide()
	end
end

local FUA = CreateFrame("Frame")
FUA:RegisterEvent("NAME_PLATE_UNIT_ADDED")
FUA:SetScript(
	"OnEvent",
	function(self, event, unit)
		local level = UnitLevel(unit)
		local classification = UnitClassification(unit)
		local isElite = classification == "worldboss" or classification == "rareelite" or classification == "elite"
		local isEnemy = UnitIsEnemy("player", unit)
		local isPlayer = UnitIsPlayer(unit)
		if DEBUG then
			isEnemy = true
		end

		if level and isEnemy then
			local playerLevel = UnitLevel("player")
			local isSkull = level == -1 or level >= playerLevel + 10
			local isRed = level >= playerLevel + 3
			if isPlayer and UnitIsPVP(unit) and HighLevelAlert:GV(HLATAB, "SHOWWARNINGFORPLAYERS", true) then
				if not UnitOnTaxi("player") then
					PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE or SOUNDKIT.RAID_WARNING, "Ambience")
					table.insert(NPPvp, unit)
				end
			elseif not isPlayer then
				if isSkull and isElite then
					if not UnitOnTaxi("player") then
						PlaySound(SOUNDKIT.RAID_WARNING, "Ambience")
					end

					table.insert(NPSkullElite, unit)
				elseif isSkull then
					if not UnitOnTaxi("player") then
						PlaySound(SOUNDKIT.READY_CHECK or SOUNDKIT.RAID_WARNING, "Ambience")
					end

					table.insert(NPSkull, unit)
				elseif isRed and isElite then
					if not UnitOnTaxi("player") then
						PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_2 or SOUNDKIT.RAID_WARNING, "Ambience")
					end

					table.insert(NPRedElite, unit)
				elseif isRed then
					if not UnitOnTaxi("player") then
						PlaySound(SOUNDKIT.GS_LOGIN or SOUNDKIT.RAID_WARNING, "Ambience")
					end

					table.insert(NPRed, unit)
				end
			end

			HighLevelAlert:UpdateText()
		end
	end
)

local FUR = CreateFrame("Frame")
FUR:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
FUR:SetScript(
	"OnEvent",
	function(self, event, unit)
		local removed = false
		for i, u in ipairs(NPPvp) do
			if u == unit then
				table.remove(NPPvp, i)
				removed = true
				break
			end
		end

		if not removed then
			for i, u in ipairs(NPSkullElite) do
				if u == unit then
					table.remove(NPSkullElite, i)
					removed = true
					break
				end
			end
		end

		if not removed then
			for i, u in ipairs(NPSkull) do
				if u == unit then
					table.remove(NPSkull, i)
					removed = true
					break
				end
			end
		end

		if not removed then
			for i, u in ipairs(NPRedElite) do
				if u == unit then
					table.remove(NPRedElite, i)
					removed = true
					break
				end
			end
		end

		if not removed then
			for i, u in ipairs(NPRed) do
				if u == unit then
					table.remove(NPRed, i)
					break
				end
			end
		end

		HighLevelAlert:UpdateText()
	end
)
