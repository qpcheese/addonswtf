local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local classicIDs = {
    5335,  -- A Sack of Coins
    5523,  -- Small Barnacled Clam
    5524,  -- Thick-Shelled Clam
    5738,  -- Covert Ops Pack
    6307,  -- Message in a Bottle
    6351,  -- Dented Crate
    6352,  -- Waterlogged Crate
    6353,  -- Small Chest
    6356,  -- Battered Chest
    6357,  -- Sealed Crate
    6643,  -- Bloated Smallfish
    6645,  -- Bloated Mud Snapper
    6647,  -- Bloated Catfish
    6715,  -- Ruined Jumper Cables
    6755,  -- A Small Container of Gems
    6827,  -- Box of Supplies
    7190,  -- Scorched Rocket Boots
    7209,  -- Tazan's Satchel
    7870,  -- Thaumaturgy Vessel Lockbox
    7973,  -- Big-Mouth Clam
    8049,  -- Gnarlpine Necklace
    8366,  -- Bloated Trout
    8484,  -- Gadgetzan Water Co. Care Package
    8647,  -- Egg Crate
    9265,  -- Cuergo's Hidden Treasure
    9276,  -- Pirate's Footlocker
    9363,  -- Sparklematic-Wrapped Box
    9539,  -- Box of Rations
    9540,  -- Box of Spells
    9541,  -- Box of Goodies
    10456,  -- A Bulging Coin Purse
    10479,  -- Kovic's Trading Satchel
    10569,  -- Hoard of the Black Dragonflight
    10695,  -- Box of Empty Vials
    10752,  -- Emerald Encrusted Chest
    10773,  -- Hakkari Urn
    10834,  -- Felhound Tracker Kit
    11024,  -- Evergreen Herb Casing
    11107,  -- A Small Pack
    11422,  -- Goblin Engineer's Renewal Gift
    11423,  -- Gnome Engineer's Renewal Gift
    11568,  -- Torwa's Pouch
    11617,  -- Eridan's Supplies
    11883,  -- A Dingy Fanny Pack
    11887,  -- Cenarion Circle Cache
    11912,  -- Package of Empty Ooze Containers
    11937,  -- Fat Sack of Coins
    11938,  -- Sack of Gems
    11955,  -- Bag of Empty Ooze Containers
    11966,  -- Small Sack of Coins
    12122,  -- Kum'isha's Junk
    12339,  -- Vaelan's Gift
    12849,  -- Demon Kissed Sack
    13874,  -- Heavy Crate
    13881,  -- Bloated Redgill
    13891,  -- Bloated Salmon
    15102,  -- Un'Goro Tested Sample
    15103,  -- Corrupt Tested Sample
    15699,  -- Small Brown-Wrapped Package
    15876,  -- Nathanos' Chest
    15902,  -- A Crazy Grab Bag
    16885,  -- Heavy Junkbox
    17685,  -- Smokywood Pastures Sampler
    17962,  -- Blue Sack of Gems
    17963,  -- Green Sack of Gems
    17964,  -- Gray Sack of Gems
    17965,  -- Yellow Sack of Gems
    17969,  -- Red Sack of Gems
    18804,  -- Lord Grayson's Satchel
    19035,  -- Lard's Special Picnic Basket
    19150,  -- Sentinel Basic Care Package
    19151,  -- Sentinel Standard Care Package
    19152,  -- Sentinel Advanced Care Package
    19153,  -- Outrider Advanced Care Package
    19154,  -- Outrider Basic Care Package
    19155,  -- Outrider Standard Care Package
    19296,  -- Greater Darkmoon Prize
    19297,  -- Lesser Darkmoon Prize
    19298,  -- Minor Darkmoon Prize
    19422,  -- Darkmoon Faire Fortune
    19425,  -- Mysterious Lockbox
    20228,  -- Defiler's Advanced Care Package
    20229,  -- Defiler's Basic Care Package
    20230,  -- Defiler's Standard Care Package
    20231,  -- Arathor Advanced Care Package
    20233,  -- Arathor Basic Care Package
    20236,  -- Arathor Standard Care Package
    20469,  -- Decoded True Believer Clippings
    20601,  -- Sack of Spoils
    20602,  -- Chest of Spoils
    20603,  -- Bag of Spoils
    20708,  -- Tightly Sealed Trunk
    20766,  -- Slimy Bag
    20767,  -- Scum Covered Bag
    20768,  -- Oozing Bag
    20805,  -- Followup Logistics Assignment
    20808,  -- Combat Assignment
    20809,  -- Tactical Assignment
    21042,  -- Narain's Special Kit
    21113,  -- Watertight Trunk
    21131,  -- Followup Combat Assignment
    21132,  -- Logistics Assignment
    21133,  -- Followup Tactical Assignment
    21150,  -- Iron Bound Trunk
    21156,  -- Scarab Bag
    21164,  -- Bloated Rockscale Cod
    21191,  -- Carefully Wrapped Present
    21216,  -- Smokywood Pastures Extra-Special Gift
    21228,  -- Mithril Bound Trunk
    21266,  -- Logistics Assignment
    21315,  -- Smokywood Satchel
    21386,  -- Followup Logistics Assignment
    21509,  -- Ahn'Qiraj War Effort Supplies
    21510,  -- Ahn'Qiraj War Effort Supplies
    21511,  -- Ahn'Qiraj War Effort Supplies
    21512,  -- Ahn'Qiraj War Effort Supplies
    21513,  -- Ahn'Qiraj War Effort Supplies
    21528,  -- Colossal Bag of Loot
    21740,  -- Small Rocket Recipes
    21741,  -- Cluster Rocket Recipes
    21742,  -- Large Rocket Recipes
    21743,  -- Large Cluster Rocket Recipes
    21746,  -- Lucky Red Envelope
    21812,  -- Box of Chocolates
    21975,  -- Pledge of Adoration: Stormwind
    21980,  -- Gift of Adoration: Ironforge
    21981,  -- Gift of Adoration: Stormwind
    22137,  -- Ysida's Satchel
    22154,  -- Pledge of Adoration: Ironforge
    22155,  -- Pledge of Adoration: Darnassus
    22157,  -- Pledge of Adoration: Undercity
    22171,  -- Gift of Friendship: Thunder Bluff
    22320,  -- Mux's Quality Goods
    22568,  -- Sealed Craftsman's Writ
    22648,  -- Hive'Ashi Dossier
    22649,  -- Hive'Regal Dossier
    22650,  -- Hive'Zora Dossier
    22746,  -- Buccaneer's Uniform
    23022,  -- Curmudgeon's Payoff
}
for _, id in ipairs(classicIDs) do openables[id] = {} end

openables[4632] = { lockbox = true }  -- Ornate Bronze Lockbox
openables[4633] = { lockbox = true }  -- Heavy Bronze Lockbox
openables[4634] = { lockbox = true }  -- Iron Lockbox
openables[4636] = { lockbox = true }  -- Strong Iron Lockbox
openables[4637] = { lockbox = true }  -- Steel Lockbox
openables[4638] = { lockbox = true }  -- Reinforced Steel Lockbox
openables[5758] = { lockbox = true }  -- Mithril Lockbox
openables[5759] = { lockbox = true }  -- Thorium Lockbox
openables[5760] = { lockbox = true }  -- Eternium Lockbox
openables[6354] = { lockbox = true }  -- Small Locked Chest
openables[6355] = { lockbox = true }  -- Sturdy Locked Chest
openables[12033] = { lockbox = true }  -- Thaurissan Family Jewels
openables[13875] = { lockbox = true }  -- Ironbound Locked Chest
openables[13918] = { lockbox = true }  -- Reinforced Locked Chest
openables[16882] = { lockbox = true }  -- Battered Junkbox
openables[16883] = { lockbox = true }  -- Worn Junkbox
openables[16884] = { lockbox = true }  -- Sturdy Junkbox
