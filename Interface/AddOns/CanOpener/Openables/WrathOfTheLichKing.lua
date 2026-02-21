local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local wotlkIDs = {
    34119,  -- Black Conrad's Treasure
    34871,  -- Crafty's Sack
    35792,  -- Mage Hunter Personal Effects
    36781,  -- Darkwater Clam
    37168,  -- Mysterious Tarot
    39418,  -- Ornately Jeweled Box
    39883,  -- Cracked Egg
    41426,  -- Magically Wrapped Gift
    41888,  -- Small Velvet Bag
    43346,  -- Large Satchel of Spoils
    43347,  -- Satchel of Spoils
    43556,  -- Patroller's Pack
    44113,  -- Small Spice Bag
    44142,  -- Strange Tarot
    44161,  -- Arcane Tarot
    44163,  -- Shadowy Tarot
    44475,  -- Reinforced Crate
    44663,  -- Abandoned Adventurer's Satchel
    44700,  -- Brooding Darkwater Clam
    44718,  -- Ripe Disgusting Jar
    44751,  -- Hyldnir Spoils
    44943,  -- Icy Prism
    44951,  -- Box of Bombs
    45072,  -- Brightly Colored Egg
    45328,  -- Bloated Slippery Eel
    45724,  -- Champion's Purse
    45875,  -- Sack of Ulduar Spoils
    45878,  -- Large Sack of Ulduar Spoils
    45909,  -- Giant Darkwater Clam
    46007,  -- Bag of Fishing Treasures
    46110,  -- Alchemist's Cache
    46740,  -- Winter Veil Gift
    46809,  -- Bountiful Cookbook
    46810,  -- Bountiful Cookbook
    46812,  -- Northrend Mystery Gem Pouch
    49294,  -- Ashen Sack of Gems
    49631,  -- Standard Apothecary Serving Kit
    49926,  -- Brazie's Black Book of Secrets
    50160,  -- Lovely Dress Box
    50161,  -- Dinner Suit Box
    51316,  -- Unsealed Chest
    51999,  -- Satchel of Helpful Goods
    52000,  -- Satchel of Helpful Goods
    52001,  -- Satchel of Helpful Goods
    52002,  -- Satchel of Helpful Goods
    52003,  -- Satchel of Helpful Goods
    52004,  -- Satchel of Helpful Goods
    52005,  -- Satchel of Helpful Goods
    52006,  -- Sack of Frosty Treasures
    52676,  -- Cache of the Ley-Guardian
    54535,  -- Keg-Shaped Treasure Chest
    54536,  -- Satchel of Chilled Goods
    54537,  -- Heart-Shaped Box
}
for _, id in ipairs(wotlkIDs) do openables[id] = {} end

openables[43575] = { lockbox = true }  -- Reinforced Junkbox
openables[43622] = { lockbox = true }  -- Froststeel Lockbox
openables[43624] = { lockbox = true }  -- Titanium Lockbox
openables[45986] = { lockbox = true }  -- Tiny Titanium Lockbox
