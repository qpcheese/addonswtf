local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local legionIDs = {
    123961,  -- Recipe List: Leysmithing
    123962,  -- Recipe List: Hardened Leystone
    123963,  -- Recipe List: Masterwork Demonsteel
    126947,  -- Nal'ryssa's Spare Mining Supplies
    129746,  -- Oddly-Shaped Stomach
    130186,  -- Intern Items - BJI
    132892,  -- Blingtron 6000 Gift Package
    133549,  -- Muck-Covered Shoes
    133721,  -- Message in a Beer Bottle
    133803,  -- Common Bag of Loot
    133804,  -- Faded Bag of Loot
    135539,  -- Crate of Battlefield Goods
    135540,  -- Crate of Battlefield Goods
    135541,  -- Crusader's Crate of Battlefield Goods
    135542,  -- Icy Crate of Battlefield Goods
    135543,  -- Rival's Crate of Battlefield Goods
    135544,  -- Tranquil Crate of Helpful Goods - Reuse Me
    135545,  -- Savage Crate of Battlefield Goods
    135546,  -- Fel-Touched Crate of Battlefield Goods
    136359,  -- Shaman's Pouch
    136362,  -- Ancient War Remnants
    136383,  -- Ravencrest Cache
    137414,  -- Pet Tournament Purse
    137560,  -- Dreamweaver Provisions
    137561,  -- Highmountain Tribute
    137562,  -- Valarjar Cache
    137563,  -- Farondis Lockbox
    137564,  -- Nightfallen Hoard
    137565,  -- Warden's Field Kit
    137590,  -- Pile of Silk
    137591,  -- Pile of Skins
    137592,  -- Pile of Ore
    137593,  -- Pile of Herbs
    137594,  -- Pile of Gems
    137600,  -- Pile of Pants
    137608,  -- Growling Sac
    138098,  -- Iron-Bound Crate of Battlefield Goods
    138469,  -- Champion's Strongbox
    138470,  -- Silver Strongbox
    138471,  -- Bronze Strongbox
    138472,  -- Steel Strongbox
    138473,  -- Steel Strongbox
    138474,  -- Champion's Strongbox
    138475,  -- Silver Strongbox
    138476,  -- Bronze Strongbox
    139048,  -- Small Legion Chest
    139049,  -- Large Legion Chest
    139137,  -- Hag's Belongings
    139284,  -- Anniversary Gift
    139341,  -- Winter Veil Gift
    139343,  -- Gently Shaken Gift
    139381,  -- Keystone Container
    139382,  -- Keystone Container
    139383,  -- Keystone Container
    139416,  -- Bloated Sewersucker
    139467,  -- Satchel of Spoils
    139484,  -- Cache of Nightmarish Treasures
    139486,  -- Cache of Nightmarish Treasures
    139487,  -- Cache of Nightmarish Treasures
    139488,  -- Cache of Nightmarish Treasures
    139771,  -- Seething Essence
    139777,  -- Strange Crate
    139879,  -- Crate of Champion Equipment
    140148,  -- Cache of Nightborne Treasures
    140150,  -- Cache of Nightborne Treasures
    140152,  -- Cache of Nightborne Treasures
    140154,  -- Cache of Nightborne Treasures
    140200,  -- Immaculate Nightshard Curio
    140220,  -- Scavenged Cloth
    140221,  -- Found Sack of Gems
    140222,  -- Harvested Goods
    140224,  -- Butchered Meat
    140225,  -- Salvaged Armor
    140226,  -- Mana-Tinged Pack
    140227,  -- Bloodhunter's Quarry
    140591,  -- Shattered Satchel of Cooperation
    140601,  -- Sixtrigger Resource Crate
    140997,  -- Alliance Strongbox
    140998,  -- Horde Strongbox
    141069,  -- Skyhold Chest of Riches
    141155,  -- Challenger's Spoils
    141156,  -- Haunted Ravencrest Keepsake
    141157,  -- Nightborne Rucksack
    141158,  -- Despoiled Keeper's Cache
    141159,  -- Watertight Salvage Bag
    141160,  -- Seaweed-Encrusted Satchel
    141161,  -- Cache of the Black Dragon
    141162,  -- Unmarked Suramar Vault Crate
    141163,  -- Bag of Confiscated Materials
    141164,  -- Violet Hold Contraband Locker
    141165,  -- Challenger's Spoils
    141166,  -- Haunted Ravencrest Keepsake
    141167,  -- Nightborne Rucksack
    141168,  -- Despoiled Keeper's Cache
    141169,  -- Watertight Salvage Bag
    141170,  -- Seaweed-Encrusted Satchel
    141171,  -- Cache of the Black Dragon
    141172,  -- Unmarked Suramar Vault Crate
    141173,  -- Bag of Confiscated Materials
    141174,  -- Violet Hold Contraband Locker
    141175,  -- Challenger's Spoils
    141176,  -- Haunted Ravencrest Keepsake
    141177,  -- Nightborne Rucksack
    141178,  -- Despoiled Keeper's Cache
    141179,  -- Watertight Salvage Bag
    141180,  -- Seaweed-Encrusted Satchel
    141181,  -- Cache of the Black Dragon
    141182,  -- Unmarked Suramar Vault Crate
    141183,  -- Bag of Confiscated Materials
    141184,  -- Violet Hold Contraband Locker
    141344,  -- Tribute of the Broken Isles
    141350,  -- Kirin Tor Chest
    142023,  -- Adventurer's Footlocker
    142113,  -- Crate of Arakkoa Archaeology Fragments
    142114,  -- Crate of Draenor Clans Archaeology Fragments
    142115,  -- Crate of Ogre Archaeology Fragments
    142342,  -- Glittering Pack
    142350,  -- Challenger's Purse
    142381,  -- Oath of Fealty
    142447,  -- Torn Sack of Pet Supplies
    143606,  -- Satchel of Battlefield Spoils
    143607,  -- Soldier's Footlocker
    143948,  -- Chilled Satchel of Vegetables
    144291,  -- Tadpole Gift
    144330,  -- Sprocket Container
    144345,  -- Pile of Pet Goodies
    144373,  -- Claw-Marked Brawler's Purse
    144374,  -- Groovy Brawler's Purse
    144375,  -- Feathered Brawler's Purse
    144376,  -- Agile Brawler's Purse
    144377,  -- Beginning Brawler's Purse
    144378,  -- Gorestained Brawler's Purse
    144379,  -- Murderous Brawler's Purse
    146317,  -- Mr. Smite's Supplies
    146799,  -- BUILDING CONTRIBUTION REWARD ITEM [NYI]
    146899,  -- Highmountain Supplies
    146900,  -- Nightfallen Cache
    146901,  -- Valarjar Strongbox
    146948,  -- Tribute of the Broken Isles
    147361,  -- Legionfall Chest
    147432,  -- Champion Equipment
    147446,  -- Brawler's Footlocker
    147518,  -- Cache of Fel Treasures
    147519,  -- Cache of Fel Treasures
    147520,  -- Cache of Fel Treasures
    147521,  -- Cache of Fel Treasures
    147573,  -- Trial of Style Reward: First Place
    147574,  -- Trial of Style Reward: Second Place
    147575,  -- Trial of Style Reward: Third Place
    147576,  -- Trial of Style Consolation Prize
    147729,  -- Netherchunk
    147876,  -- Anniversary Gift
    147905,  -- Chest of Champion Equipment
    147907,  -- Heart-Shaped Carton
    149503,  -- Stolen Gift
    149504,  -- Smokywood Pastures Special Present
    149574,  -- Loot-Stuffed Pumpkin
    149752,  -- Keg-Shaped Treasure Box
    149753,  -- Knapsack of Chilled Goods
    150924,  -- Greater Tribute of the Broken Isles
    151221,  -- Gooey Brawler's Purse
    151222,  -- Leather Brawler's Purse
    151223,  -- Booming Brawler's Purse
    151224,  -- Bitten Brawler's Purse
    151225,  -- Wet Brawler's Purse
    151229,  -- Brawler's Music Box
    151230,  -- Croc-Skin Brawler's Purse
    151231,  -- Brawler's Egg
    151232,  -- Brawler's Package
    151233,  -- Blingin' Brawler's Bag
    151235,  -- Filthy Brawler's Purse
    151238,  -- Dark Brawler's Purse
    151264,  -- Clunky Brawler's Purse
    151345,  -- Gently Shaken Gift
    151350,  -- Winter Veil Gift
    151482,  -- Time-Lost Wallet
    151550,  -- Time-Lost Keepsake Box
    151551,  -- Time-Lost Keepsake Box
    151552,  -- Time-Lost Keepsake Box
    151553,  -- Time-Lost Keepsake Box
    151554,  -- Time-Lost Keepsake Box
    151557,  -- Champion's Strongbox
    151558,  -- Champion's Strongbox
    151638,  -- Leprous Sack of Pet Supplies
    152102,  -- Farondis Chest
    152103,  -- Dreamweaver Cache
    152104,  -- Highmountain Supplies
    152105,  -- Nightfallen Cache
    152106,  -- Valarjar Strongbox
    152107,  -- Warden's Supply Kit
    152922,  -- Brittle Krokul Chest
    153116,  -- Wyrmtongue Cache of Herbs
    153117,  -- Wyrmtongue Cache of Supplies
    153118,  -- Wyrmtongue Cache of Shiny Things
    153119,  -- Wyrmtongue Cache of Finery
    153120,  -- Wyrmtongue Cache of Minerals
    153121,  -- Wyrmtongue Cache of Skins
    153122,  -- Wyrmtongue Cache of Magic
    153132,  -- Coffer of Argus Equipment
    153191,  -- Cracked Fel-Spotted Egg
    153202,  -- Argunite Cluster
    153248,  -- Light's Fortune
    153501,  -- Cache of Antoran Treasures
    153502,  -- Cache of Antoran Treasures
    153503,  -- Cache of Antoran Treasures
    153504,  -- Cache of Antoran Treasures
    154991,  -- Brawler's Footlocker
    154992,  -- Brawler's Footlocker
    156682,  -- Otherworldly Satchel of Helpful Goods
    156683,  -- Satchel of Helpful Goods
    156688,  -- Icy Satchel of Helpful Goods
    156689,  -- Scorched Satchel of Helpful Goods
    156698,  -- Tranquil Satchel of Helpful Goods
    156707,  -- Bret's Satchel of Helpful Goods
    156836,  -- Bulging Package
    157822,  -- Dreamweaver Provisions
    157824,  -- Valarjar Cache
    157827,  -- Warden's Field Kit
    157828,  -- Kirin Tor Chest
}
for _, id in ipairs(legionIDs) do openables[id] = {} end

openables[121331] = { lockbox = true }  -- Leystone Lockbox
