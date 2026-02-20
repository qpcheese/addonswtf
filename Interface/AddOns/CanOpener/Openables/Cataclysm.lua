local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local cataIDs = {
    49369,  -- Red Blizzcon Bag
    50238,  -- Cracked Un'Goro Coconut
    50409,  -- Spark's Fossil Finding Kit
    52274,  -- Earthen Ring Supplies
    52304,  -- Fire Prism
    52340,  -- Abyssal Clam
    52344,  -- Earthen Ring Supplies
    54516,  -- Loot-Filled Pumpkin
    57540,  -- Coldridge Mountaineer's Pouch
    60681,  -- Cannary's Cache
    61387,  -- Hidden Stash
    62062,  -- Bulging Sack of Gold
    64491,  -- Royal Reward
    64657,  -- Canopic Jar
    65513,  -- Crate of Tasty Meat
    66943,  -- Treasures from Grim Batol
    67248,  -- Satchel of Helpful Goods
    67250,  -- Satchel of Helpful Goods
    67414,  -- Bag of Shiny Things
    67443,  -- Winter Veil Gift
    67495,  -- Strange Bloated Stomach
    67539,  -- Tiny Treasure Chest
    67597,  -- Sealed Crate
    68384,  -- Moonkin Egg
    68598,  -- Very Fat Sack of Coins
    68689,  -- Imported Supplies
    68795,  -- Stendel's Bane
    68813,  -- Satchel of Freshly-Picked Herbs
    69817,  -- Hive Queen's Honeycomb
    69818,  -- Giant Sack
    69822,  -- Master Chef's Groceries
    69823,  -- Gub's Catch
    69886,  -- Bag of Coins
    69903,  -- Satchel of Exotic Mysteries
    69999,  -- Moat Monster Feeding Kit
    70719,  -- Water-Filled Gills
    70931,  -- Scrooge's Payoff
    71631,  -- Zen'Vorka's Cache
    77956,  -- Spectral Mount Crate
    78897,  -- Pouch o' Tokens
    78898,  -- Sack o' Tokens
    78899,  -- Pouch o' Tokens
    78900,  -- Pouch o' Tokens
    78901,  -- Pouch o' Tokens
    78902,  -- Pouch o' Tokens
    78903,  -- Pouch o' Tokens
    78904,  -- Pouch o' Tokens
    78905,  -- Sack o' Tokens
    78906,  -- Sack o' Tokens
    78907,  -- Sack o' Tokens
    78908,  -- Sack o' Tokens
    78909,  -- Sack o' Tokens
    78910,  -- Sack o' Tokens
    78930,  -- Sealed Crate
}
for _, id in ipairs(cataIDs) do openables[id] = {} end

openables[63349] = { lockbox = true }  -- Flame-Scarred Junkbox
openables[68729] = { lockbox = true }  -- Elementium Lockbox
