local _, CanOpenerGlobal = ...

local function createStrategy(filterFn)
    return { shouldFilter = filterFn }
end

local CriteriaContext = {}
CriteriaContext.__index = CriteriaContext

function CriteriaContext:evaluateAll(itemID, cacheDetails, count)
    for _, strategy in ipairs(self.strategies) do
        if strategy.shouldFilter(itemID, cacheDetails, count) then
            return false
        end
    end
    return true
end

-- Define filter strategies
local skipRousing = createStrategy(function(itemID, cacheDetails, count)
    return not CanOpenerSavedVars.showRousing and cacheDetails.isRousing
end)

local skipRemixGems = createStrategy(function(itemID, cacheDetails, count)
    return not CanOpenerSavedVars.showRemixGems and cacheDetails.mopRemixGem
end)

local skipRemixEpicGems = createStrategy(function(itemID, cacheDetails, count)
    return not CanOpenerSavedVars.remixEpicGems and cacheDetails.mopRemixEpicGem
end)

local threshold = createStrategy(function(itemID, cacheDetails, count)
    return (cacheDetails.threshold or 1) > count
end)

local levelRequirement = createStrategy(function(itemID, cacheDetails, count)
    local _,_,_,_,itemMinLevel = C_Item.GetItemInfo(itemID)
    if not itemMinLevel then
        return false
    end
    CanOpenerGlobal.DebugLog("LevelRequirement - itemMinLevel: " .. tostring(itemMinLevel) .. ", playerLevel: " .. tostring(UnitLevel("player")))
    return not CanOpenerSavedVars.showLevelRestrictedItems and itemMinLevel > UnitLevel("player")
end)

-- Build strategy list
local strategies = { skipRousing, threshold }
if CanOpenerGlobal.IsRemixActive then
    table.insert(strategies, skipRemixGems)
    table.insert(strategies, skipRemixEpicGems)
end
table.insert(strategies, levelRequirement)

CanOpenerGlobal.CriteriaContext = setmetatable({ strategies = strategies }, CriteriaContext)
