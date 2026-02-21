local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local bfaIDs = {
    152578,  -- Sack of Herbs
    152580,  -- Pile of Cloth
    152581,  -- Bag of Jewels
    152868,  -- Anglin' Art's Mudfish Bait
    153574,  -- Plain Hat Box
    159783,  -- Kane's Coin Purse
    160054,  -- War-Torn Satchel of Cooperation
    160268,  -- Bag of Armor (DNT)
    160322,  -- Pile of Ore
    160324,  -- Grumbling Sac
    160439,  -- Adventurer's Footlocker
    160485,  -- An Unforgettable Luncheon
    160514,  -- Maokka's Box
    160578,  -- Anglin' Art's Bag o' Fish
    160831,  -- Cracking Cobra Egg
    161083,  -- Satchel of Plundered Jewels
    161084,  -- Recovered Stormsong Produce
    161878,  -- Tiny Coin Purse
    162637,  -- Anniversary Gift
    162644,  -- Winter Veil Gift
    162974,  -- Gently Shaken Gift
    163059,  -- Spoils of Jani
    163139,  -- Carefully Wrapped Hat Box
    163141,  -- Spooky Hat Box
    163142,  -- Ironbound Hat Box
    163144,  -- Striped Hat Box
    163146,  -- Fancy Hat Box
    163148,  -- Luxurious Hat Box
    163611,  -- Seafarer's Coin Pouch
    163612,  -- Wayfinder's Satchel
    163613,  -- Sack of Plunder
    163633,  -- Captain Gulnaku's Treasure
    163734,  -- Bulging Coin Purse
    163825,  -- Plundered Supplies
    163826,  -- Raider's Supply Cache
    164251,  -- Champion's Strongbox
    164252,  -- Champion's Strongbox
    164253,  -- Steel Strongbox
    164254,  -- Steel Strongbox
    164257,  -- Cache of Uldir Treasures
    164258,  -- Cache of Uldir Treasures
    164259,  -- Cache of Uldir Treasures
    164260,  -- Cache of Uldir Treasures
    164261,  -- Steel Strongbox
    164262,  -- Steel Strongbox
    164263,  -- Steel Strongbox
    164264,  -- Steel Strongbox
    164625,  -- Crate of Demon Archaeology Fragments
    164626,  -- Crate of Highborne Archaeology Fragments
    164627,  -- Crate of Highmountain Tauren Archaeology Fragments
    164931,  -- Rumbler's Purse
    164938,  -- G.G. Gearbox
    164939,  -- Overstuffed Silkweave Purse
    164940,  -- Mysterious Satchel
    165711,  -- Gold Strongbox
    165712,  -- Silver Strongbox
    165713,  -- Bronze Strongbox
    165714,  -- Gold Strongbox
    165715,  -- Silver Strongbox
    165716,  -- Bronze Strongbox
    165717,  -- Steel Strongbox
    165718,  -- Steel Strongbox
    165729,  -- Cache of Dazar'alor Treasures
    165730,  -- Cache of Dazar'alor Treasures
    165731,  -- Cache of Dazar'alor Treasures
    165732,  -- Cache of Dazar'alor Treasures
    166290,  -- Voldunai Supplies
    166292,  -- Zandalari Empire Supplies
    166294,  -- Storm's Wake Supplies
    166295,  -- Proudmoore Admiralty Supplies
    166297,  -- Order of Embers Supplies
    166298,  -- Champions of Azeroth Supplies
    166299,  -- Honorbound Supplies
    166300,  -- 7th Legion Supplies
    166505,  -- Relinquished Azerite Spaulders
    166508,  -- Relinquished Azerite Spaulders
    166509,  -- Relinquished Azerite Spaulders
    166510,  -- Relinquished Azerite Helm
    166511,  -- Relinquished Azerite Helm
    166512,  -- Relinquished Azerite Helm
    166513,  -- Relinquished Azerite Chestpiece
    166514,  -- Relinquished Azerite Chestpiece
    166515,  -- Relinquished Azerite Chestpiece
    166529,  -- Relinquished Azerite Spaulders
    166530,  -- Relinquished Azerite Spaulders
    166531,  -- Relinquished Azerite Spaulders
    166532,  -- Relinquished Azerite Helm
    166533,  -- Relinquished Azerite Helm
    166534,  -- Relinquished Azerite Helm
    166535,  -- Relinquished Azerite Chestpiece
    166536,  -- Relinquished Azerite Chestpiece
    166537,  -- Relinquished Azerite Chestpiece
    166741,  -- Nomi's Grocery Tote
    167696,  -- Build-a-Computer Kit
    168057,  -- Rustbolt Requisitions
    168124,  -- Cache of War Resources
    168162,  -- Chronal Cache of Cloth
    168204,  -- Small Metal Box
    168263,  -- Mundane Recycling Requisition
    168264,  -- Recycling Requisition
    168266,  -- Strange Recycling Requisition
    168394,  -- Box of Assorted Parts
    168395,  -- Irradiated Box of Assorted Parts
    168488,  -- Seafarer's Lost Coin Pouch
    168494,  -- Blueprint: Rustbolt Resistance Insignia
    168740,  -- Blingtron 7000 Gift Package
    168833,  -- Experimental Adventurer Augmentation
    169113,  -- Advanced Adventurer Augmentation
    169133,  -- Crystallized Jelly
    169137,  -- Extraordinary Adventurer Augmentation
    169335,  -- Relinquished Azerite Spaulders
    169336,  -- Relinquished Azerite Spaulders
    169337,  -- Relinquished Azerite Spaulders
    169338,  -- Relinquished Azerite Helm
    169339,  -- Relinquished Azerite Helm
    169340,  -- Relinquished Azerite Helm
    169341,  -- Relinquished Azerite Chestpiece
    169342,  -- Relinquished Azerite Chestpiece
    169343,  -- Relinquished Azerite Chestpiece
    169430,  -- Unclaimed Black Market Container
    169471,  -- Cogfrenzy's Construction Toolkit
    169477,  -- Benthic Girdle
    169478,  -- Benthic Bracers
    169479,  -- Benthic Helm
    169480,  -- Benthic Chestguard
    169481,  -- Benthic Cloak
    169482,  -- Benthic Leggings
    169483,  -- Benthic Treads
    169484,  -- Benthic Spaulders
    169485,  -- Benthic Gauntlets
    169666,  -- Unopened Stratholme Supply Crate
    169838,  -- Azeroth Mini: Starter Pack
    169848,  -- Azeroth Mini Pack: Bondo's Yard
    169850,  -- Azeroth Mini Pack: Mechagon
    169903,  -- Nazjatar Survival Pack
    169904,  -- Ankoan Commendation Crate
    169905,  -- Faintly Glowing Supplies
    169908,  -- Cleverly Concealed Supplies
    169909,  -- Poen's Neat Things
    169910,  -- Vim's Scavenged Supplies
    169911,  -- Liberated Naga Cache
    169915,  -- Poen's Stashed Supplies
    169916,  -- Brew-Soaked Supplies
    169917,  -- Mysterious Azshari Chest
    169919,  -- Unshackled Commendation Crate
    169920,  -- Neri's Spare Supplies
    169921,  -- Spine Guarded Supplies
    169922,  -- Vim's Gift of Appreciation
    169939,  -- Ankoan Supplies
    169940,  -- Unshackled Supplies
    170061,  -- Rustbolt Supplies
    170065,  -- Re-Procedurally Generated Punchcard
    170073,  -- Dented Ashmaul Strongbox
    170074,  -- Dented Ashmaul Strongbox
    170185,  -- Intact Naga Skeleton
    170188,  -- Barnacled Bag of Goods
    170190,  -- Mardivas' Bag of Containing
    170195,  -- Voidcaster's Supply Bag
    170473,  -- Jingling Sack
    170489,  -- Mardivas's Handmade Handbag
    170502,  -- Waterlogged Toolbox
    170539,  -- Plundered Supplies
    171305,  -- Salvaged Cache of Goods
    171988,  -- Adventurer's Footlocker
    172014,  -- Anniversary Gift
    172021,  -- Marks of Sanctification Purse
    172224,  -- Winter Veil Gift
    172225,  -- Gently Shaken Gift
    173372,  -- Cache of the Black Empire
    173734,  -- Mysterious Crate
    173949,  -- Dread Chain Salvage
    173950,  -- Crestfall Salvage
    173983,  -- Vulpera Satchel of Salvage
    173987,  -- Elemental Salvage
    173988,  -- Havenswood Salvage
    173989,  -- Jorundall Salvage
    173990,  -- Molten Cay Salvage
    173991,  -- Rotting Mire Salvage
    173992,  -- Skittering Hollow Salvage
    173993,  -- Snowblossom Salvage
    173994,  -- Un'gol Ruins Salvage
    173995,  -- Venture Co. 'Salvage'
    173996,  -- Verdant Wilds Salvage
    173997,  -- Whispering Reef Salvage
    174039,  -- Crate of Cursed Mementos
    174181,  -- Bag of Herbs
    174182,  -- Bag of Ore
    174183,  -- Bag of Leather
    174184,  -- Bag of Cloth
    174194,  -- Bag of Enchanting
    174195,  -- Bag of Gems
    174358,  -- Unopened Blackrock Supply Crate
    174483,  -- Rajani Supplies
    174484,  -- Uldum Accord Supplies
    174529,  -- Crate of Coalescing Visions
    174630,  -- Relinquished Azerite Spaulders
    174633,  -- Relinquished Azerite Helm
    174634,  -- Relinquished Azerite Helm
    174635,  -- Relinquished Azerite Helm
    174637,  -- Relinquished Azerite Chestpiece
    174638,  -- Relinquished Azerite Chestpiece
    174642,  -- Corrupted Ny'alotha Raid Item
    174958,  -- Cache of the Fallen Mogu
    174959,  -- Cache of the Mantid Swarm
    174960,  -- Cache of the Aqir Swarm
    174961,  -- Cache of the Amathet
}
for _, id in ipairs(bfaIDs) do openables[id] = {} end

openables[169475] = { lockbox = true }  -- Barnacled Lockbox
openables[174636] = { lockbox = true }  -- Relinquished Azerite Chestpiece
