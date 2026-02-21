local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local slIDs = {
    151060,  -- Keystone Container
    171209,  -- Blooded Satchel
    171210,  -- Satchel of Nature's Bounty
    171211,  -- Venthyr's Coin Purse
    174652,  -- Satchel of Forgotten Heirlooms
    175095,  -- Book of Tickets
    175135,  -- Atticus's Spare Supplies
    178078,  -- Reborn Spirit Cache
    178128,  -- Pouch of Shinies
    178513,  -- Anniversary Gift
    178528,  -- Winter Veil Gift
    178529,  -- Gently Shaken Gift
    178965,  -- Small Gardener's Satchel
    178966,  -- Gardener's Satchel
    178967,  -- Large Gardener's Satchel
    178968,  -- Weekly Gardener's Satchel
    178969,  -- Test Container
    179380,  -- Redelev Purse
    180085,  -- Kyrian Keepsake
    180128,  -- Harvester's Elite Bounty Purse
    180355,  -- Ornate Pyx
    180378,  -- Forgemaster's Crate
    180379,  -- Exquisitely Woven Rug
    180380,  -- Lace Draperies
    180386,  -- Herbalist's Pouch
    180442,  -- Bag of Sin Stones
    180646,  -- Supplies of the Undying Army
    180647,  -- Ascended Supplies
    180648,  -- Court of Harvesters Supplies
    180649,  -- Wild Hunt Supplies
    180875,  -- Carriage Cargo
    180974,  -- Novice's Satchel
    180975,  -- Journeyman's Satchel
    180976,  -- Artisan's Satchel
    180977,  -- Spirit-Tender's Satchel
    180979,  -- Artisan's Large Satchel
    180980,  -- Journeyman's Large Satchel
    180981,  -- Novice's Large Satchel
    180983,  -- Artisan's Stuffed Satchel
    180984,  -- Journeyman's Stuffed Satchel
    180985,  -- Novice's Stuffed Satchel
    180988,  -- Journeyman's Overflowing Satchel
    180989,  -- Novice's Overflowing Satchel
    181372,  -- Tribute of the Ascended
    181475,  -- Bounty of the Grove Wardens
    181476,  -- Tribute of the Wild Hunt
    181556,  -- Tribute of the Court
    181557,  -- Favor of the Court
    181732,  -- Tribute of the Ambitious
    181733,  -- Tribute of the Duty-Bound
    181739,  -- Bag of Soul Ash
    181741,  -- Tribute of the Paragon
    181767,  -- Small Coin Purse
    181778,  -- Sack of Shinies
    181779,  -- A "Wrapped" Weapon
    181780,  -- An Undelivered Tradesman's Shipment
    182114,  -- Assorted Parts and 'Things'
    182590,  -- Vinewormed Coin Pouch
    182591,  -- Vinecovered Infused Rubies
    183424,  -- Stitched Satchel of Maldraxxi Goods
    183429,  -- Stitched Satchel of Venthyr Goods
    183699,  -- Exquisite Ingredients
    183701,  -- Cleansing Rite Materials
    183702,  -- Nature's Splendor
    183703,  -- Bonesmith's Satchel
    183834,  -- Crate of Drust Archaeology Fragments
    183835,  -- Crate of Zandalari Archaeology Fragments
    183882,  -- Collection of Random Bits
    183883,  -- Bulging Collection of Random Bits
    183884,  -- Pocketful of Assorted Nuggets
    183885,  -- Sika's Spare Ore Pouch
    183886,  -- Sika's Rare Ore Pouch
    184045,  -- Martial Tithe of the Court of Harvesters
    184046,  -- Undying Army Weapon Cache
    184047,  -- Ascended Chest of Arms
    184048,  -- Weapon Satchel of the Wild Hunt
    184103,  -- Cracked Blight-Touched Egg
    184158,  -- Oozing Necroray Egg
    184395,  -- Fallen Adventurer's Cache
    184444,  -- Supplies for the Path
    184522,  -- Veiled Satchel of Cooperation
    184584,  -- Byron Test Callings Box
    184589,  -- Bag of Potions
    184627,  -- Sacrificial Red Envelope
    184630,  -- Adventurer's Tailoring Cache
    184631,  -- Adventurer's Enchanting Cache
    184632,  -- Champion's Fish Cache
    184633,  -- Champion's Meat Cache
    184634,  -- Adventurer's Herbalism Cache
    184635,  -- Adventurer's Mining Cache
    184636,  -- Adventurer's Skinning Cache
    184637,  -- Hero's Meat Cache
    184638,  -- Hero's Fish Cache
    184639,  -- Champion's Tailoring Cache
    184640,  -- Champion's Skinning Cache
    184641,  -- Champion's Mining Cache
    184642,  -- Champion's Herbalism Cache
    184643,  -- Champion's Enchanting Cache
    184644,  -- Hero's Tailoring Cache
    184645,  -- Hero's Skinning Cache
    184646,  -- Hero's Mining Cache
    184647,  -- Hero's Herbalism Cache
    184648,  -- Hero's Enchanting Cache
    184810,  -- Plundered Supplies
    184811,  -- Artemede's Bounty
    184812,  -- Apolon's Bounty
    184843,  -- Salvaged Supplies
    184866,  -- Grummlepouch
    184868,  -- Cache of Nathrian Treasures
    184869,  -- Cache of Nathrian Treasures
    185765,  -- Shipment of Heavy Callous Hide
    185832,  -- Shipment of Elethium Ore
    185833,  -- Shipment of Lightless Silk
    185834,  -- Orboreal Distinguishment
    185906,  -- Anniversary Gift
    185963,  -- Diviner's Rune Chit
    185972,  -- Tormentor's Cache
    185990,  -- Harvester's War Chest
    185991,  -- War Chest of the Wild Hunt
    185992,  -- War Chest of the Undying Army
    185993,  -- Ascended War Chest
    186196,  -- Death's Advance War Chest
    186531,  -- Cache of Sanctum Treasures
    186533,  -- Cache of Sanctum Treasures
    186650,  -- Death's Advance Supplies
    186680,  -- Gold Filled Boot
    186688,  -- Gold Filled Wash Bucket
    186690,  -- Gold Filled Barrel
    186691,  -- Gold Filled Satchel
    186692,  -- Gold Filled Helmet
    186693,  -- Gold Filled Wheelbarrow
    186694,  -- Shaded Bag of Ore
    186705,  -- Gold Filled Chalice
    186706,  -- Gold Filled Hat
    186707,  -- Gold Filled Crate
    186708,  -- Gold Filled Paint Brush Cup
    186970,  -- Feeder's Hand and Key
    186971,  -- Feeder's Hand
    187028,  -- Supplies of the Archivists' Codex
    187029,  -- Mysterious Gift from Ve'nari
    187182,  -- Hatching Corpsefly Egg
    187254,  -- Arrangement of Anima
    187278,  -- Talon-Pierced Mawsworn Lockbox
    187346,  -- Lost Memento
    187351,  -- Stygic Cluster
    187354,  -- Abandoned Broker Satchel
    187440,  -- Feather-Stuffed Helm
    187494,  -- Byron Test Relic Fragments Box
    187502,  -- Byron Test Relic Fragments Box (Immediate)
    187503,  -- Bundle of Archived Research
    187520,  -- Gently Shaken Gift
    187543,  -- Death's Advance War Chest
    187551,  -- Small Korthian Supply Chest
    187561,  -- Winter Veil Gift
    187569,  -- Brokers' Tailoring Mote of Potentiation
    187570,  -- Brokers' Skinning Mote of Potentiation
    187571,  -- Brokers' Mining Mote of Potentiation
    187572,  -- Brokers' Herbalism Mote of Potentiation
    187573,  -- Brokers' Enchanting Mote of Potentiation
    187574,  -- Brokers' Overflowing Bucket
    187575,  -- Korthian Fishing Cache
    187576,  -- Korthian Skinning Cache
    187577,  -- Korthian Meat Cache
    187596,  -- Broken Isles Meat Delivery
    187597,  -- Broken Isles Fish Delivery
    187598,  -- Broken Isles Cloth Delivery
    187599,  -- Broken Isles Herb Delivery
    187600,  -- Broken Isles Ore Delivery
    187601,  -- Broken Isles Leather Delivery
    187604,  -- Broken Isles Enchantment Delivery
    187605,  -- Broken Isles Gem Delivery
    187659,  -- Adventurer's Footlocker
    187710,  -- Anniversary Gift
    187780,  -- Enlightened Broker Supplies
    187781,  -- Olea Cache
    187787,  -- Ephemera Orb
    187817,  -- Korthite Crystal Geode
    188796,  -- Cypher Test Item
    189428,  -- 9.2 Pet Battle Playtest Bag of Goodies
    189452,  -- 9.2 Mount Crafting Bag of Goodies
    190178,  -- Pouch of Protogenic Provisions
    190382,  -- Warped Pocket Dimension
    190610,  -- Tribute of the Enlightened Elders
    190655,  -- Cache of Sepulcher Treasures
    190656,  -- Cache of Sepulcher Treasures
    190823,  -- Firim's Mysterious Cache
    191030,  -- Cosmic Flux Parcel
    191040,  -- Cache of Sepulcher Treasures
    191041,  -- Cache of Sepulcher Treasures
    191139,  -- Tribute of the Enlightened Elders
    191301,  -- Treatise on Patterns in the Purpose
    191302,  -- Bottled Night Sky
    191303,  -- Overflowing Chest of Riches
    191701,  -- Bag of Explored Souls
    192093,  -- Gently Shaken Gift
    192094,  -- Winter Veil Gift
    192437,  -- Cache of Fated Treasures
    192438,  -- Cache of Fated Treasures
}
for _, id in ipairs(slIDs) do openables[id] = {} end

openables[179311] = { lockbox = true }  -- Synvir Lockbox
openables[180522] = { lockbox = true }  -- Phaedrum Lockbox
openables[180532] = { lockbox = true }  -- Oxxein Lockbox
openables[180533] = { lockbox = true }  -- Solenium Lockbox
openables[186160] = { lockbox = true }  -- Locked Artifact Case
openables[186161] = { lockbox = true }  -- Stygian Lockbox
openables[188787] = { lockbox = true }  -- Locked Broker Luggage
