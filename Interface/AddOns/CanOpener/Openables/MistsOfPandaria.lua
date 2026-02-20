local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local mopIDs = {
    72201,  -- Plump Intestines
    77501,  -- Blue Blizzcon Bag
    85223,  -- Enigma Seed Pack
    85224,  -- Basic Seed Pack
    85225,  -- Basic Seed Pack
    85226,  -- Basic Seed Pack
    85227,  -- Special Seed Pack
    85271,  -- Secret Stash
    85272,  -- Tree Seed Pack
    85274,  -- Gro-Pack
    85275,  -- Chee Chee's Goodie Bag
    85276,  -- Celebration Gift
    85277,  -- Nicely Packed Lunch
    85497,  -- Chirping Package
    85498,  -- Songbell Seed Pack
    86428,  -- Old Man Thistle's Treasure
    86595,  -- Bag of Helpful Things
    86623,  -- Blingtron 4000 Gift Package
    87217,  -- Small Bag of Goods
    87218,  -- Big Bag of Arms
    87219,  -- Huge Bag of Herbs
    87220,  -- Big Bag of Mysteries
    87221,  -- Big Bag of Jewels
    87222,  -- Big Bag of Linens
    87223,  -- Big Bag of Skins
    87224,  -- Big Bag of Wonders
    87225,  -- Big Bag of Food
    87391,  -- Plundered Treasure
    87533,  -- Crate of Dwarven Archaeology Fragments
    87534,  -- Crate of Draenei Archaeology Fragments
    87535,  -- Crate of Fossil Archaeology Fragments
    87536,  -- Crate of Night Elf Archaeology Fragments
    87537,  -- Crate of Nerubian Archaeology Fragments
    87538,  -- Crate of Orc Archaeology Fragments
    87539,  -- Crate of Tol'vir Archaeology Fragments
    87540,  -- Crate of Troll Archaeology Fragments
    87541,  -- Crate of Vrykul Archaeology Fragments
    87701,  -- Sack of Raw Tiger Steaks
    87702,  -- Sack of Mushan Ribs
    87703,  -- Sack of Raw Turtle Meat
    87704,  -- Sack of Raw Crab Meat
    87705,  -- Sack of Wildfowl Breasts
    87706,  -- Sack of Green Cabbages
    87707,  -- Sack of Juicycrunch Carrots
    87708,  -- Sack of Mogu Pumpkins
    87709,  -- Sack of Scallions
    87710,  -- Sack of Red Blossom Leeks
    87712,  -- Sack of Witchberries
    87713,  -- Sack of Jade Squash
    87714,  -- Sack of Striped Melons
    87715,  -- Sack of Pink Turnips
    87716,  -- Sack of White Turnips
    87721,  -- Sack of Jade Lungfish
    87722,  -- Sack of Giant Mantis Shrimp
    87723,  -- Sack of Emperor Salmon
    87724,  -- Sack of Redbelly Mandarin
    87725,  -- Sack of Tiger Gourami
    87726,  -- Sack of Jewel Danio
    87727,  -- Sack of Reef Octopus
    87728,  -- Sack of Krasarang Paddlefish
    87729,  -- Sack of Golden Carp
    87730,  -- Sack of Crocolisk Belly
    88496,  -- Sealed Crate
    89125,  -- Sack of Pet Supplies
    89427,  -- Ancient Mogu Treasure
    89428,  -- Ancient Mogu Treasure
    89607,  -- Crate of Leather
    89608,  -- Crate of Ore
    89609,  -- Crate of Dust
    89610,  -- Pandaria Herbs
    89613,  -- Cache of Treasures
    89804,  -- Cache of Mogu Riches
    89807,  -- Amber Encased Treasure Pouch
    89808,  -- Dividends of the Everlasting Spring
    89810,  -- Bounty of a Sundered Land
    89856,  -- Amber Encased Treasure Pouch
    89857,  -- Dividends of the Everlasting Spring
    89858,  -- Cache of Mogu Riches
    89991,  -- Pandaria Fireworks
    90041,  -- Spoils of Theramore
    90155,  -- Golden Chest of the Golden King
    90156,  -- Golden Chest of the Betrayer
    90157,  -- Golden Chest of Windfury
    90158,  -- Golden Chest of the Elemental Triad
    90159,  -- Golden Chest of the Silent Assassin
    90160,  -- Golden Chest of the Light
    90161,  -- Golden Chest of the Holy Warrior
    90162,  -- Golden Chest of the Regal Lord
    90163,  -- Golden Chest of the Howling Beast
    90164,  -- Golden Chest of the Cycle
    90395,  -- Facets of Research
    90397,  -- Facets of Research
    90398,  -- Facets of Research
    90399,  -- Facets of Research
    90400,  -- Facets of Research
    90401,  -- Facets of Research
    90406,  -- Facets of Research
    90537,  -- Winner's Reward
    90621,  -- Hero's Purse
    90622,  -- Hero's Purse
    90623,  -- Hero's Purse
    90624,  -- Hero's Purse
    90625,  -- Treasures of the Vale
    90626,  -- Hero's Purse
    90627,  -- Hero's Purse
    90628,  -- Hero's Purse
    90629,  -- Hero's Purse
    90630,  -- Hero's Purse
    90631,  -- Hero's Purse
    90632,  -- Hero's Purse
    90633,  -- Hero's Purse
    90634,  -- Hero's Purse
    90635,  -- Hero's Purse
    90735,  -- Goodies from Nomi
    90839,  -- Cache of Sha-Touched Gold
    90840,  -- Marauder's Gleaming Sack of Gold
    90892,  -- Winter Veil Gift
    91086,  -- Darkmoon Pet Supplies
    92718,  -- Brawler's Purse
    92744,  -- Heavy Sack of Gold
    92788,  -- Ride Ticket Book
    92789,  -- Ride Ticket Book
    92790,  -- Ride Ticket Book
    92791,  -- Ride Ticket Book
    92792,  -- Ride Ticket Book
    92793,  -- Ride Ticket Book
    92794,  -- Ride Ticket Book
    92813,  -- Greater Cache of Treasures
    92960,  -- Silkworm Cocoon
    93146,  -- Pandaren Spirit Pet Supplies
    93147,  -- Pandaren Spirit Pet Supplies
    93148,  -- Pandaren Spirit Pet Supplies
    93149,  -- Pandaren Spirit Pet Supplies
    93198,  -- Tome of the Tiger
    93199,  -- Tome of the Crane
    93200,  -- Tome of the Serpent
    93360,  -- Serpent's Cache
    93724,  -- Darkmoon Game Prize
    94158,  -- Big Bag of Zandalari Supplies
    94159,  -- Small Bag of Zandalari Supplies
    94207,  -- Fabled Pandaren Pet Supplies
    94219,  -- Arcane Trove
    94220,  -- Sunreaver Bounty
    94296,  -- Cracked Primal Egg
    94553,  -- Notes on Lightning Steel
    94566,  -- Fortuitous Coffer
    95343,  -- Treasures of the Thunder King
    95469,  -- Serpent's Heart
    95601,  -- Shiny Pile of Refuse
    95602,  -- Stormtouched Cache
    95617,  -- Dividends of the Everlasting Spring
    95618,  -- Cache of Mogu Riches
    95619,  -- Amber Encased Treasure Pouch
    97153,  -- Spoils of the Thunder King
    97948,  -- Surplus Supplies
    97949,  -- Surplus Supplies
    97950,  -- Surplus Supplies
    97951,  -- Surplus Supplies
    97952,  -- Surplus Supplies
    97953,  -- Surplus Supplies
    97954,  -- Surplus Supplies
    97955,  -- Surplus Supplies
    97956,  -- Surplus Supplies
    97957,  -- Surplus Supplies
    98095,  -- Brawler's Pet Supplies
    98096,  -- Large Sack of Coins
    98097,  -- Huge Sack of Coins
    98098,  -- Bulging Sack of Coins
    98099,  -- Giant Sack of Coins
    98100,  -- Humongous Sack of Coins
    98101,  -- Enormous Sack of Coins
    98102,  -- Overflowing Sack of Coins
    98103,  -- Gigantic Sack of Coins
    98133,  -- Greater Cache of Treasures
    98560,  -- Arcane Trove
    98562,  -- Sunreaver Bounty
    103535,  -- Bulging Bag of Charms
    103624,  -- Treasures of the Vale
    103632,  -- Lucky Box of Greatness
    104034,  -- Purse of Timeless Coins
    104035,  -- Giant Purse of Timeless Coins
    104112,  -- Curious Ticking Parcel
    104114,  -- Curious Ticking Parcel
    104198,  -- Mantid Artifact Hunter's Kit
    104258,  -- Glowing Green Ash
    104260,  -- Satchel of Savage Mysteries
    104261,  -- Glowing Blue Ash
    104263,  -- Glinting Pile of Stone
    104268,  -- Pristine Stalker Hide
    104271,  -- Coalesced Turmoil
    104272,  -- Celestial Treasure Box
    104273,  -- Flame-Scarred Cache of Offerings
    104275,  -- Twisted Treasures of the Vale
    104292,  -- Partially-Digested Meal
    104296,  -- Ordon Ceremonial Robes
    104319,  -- Winter Veil Gift
    105713,  -- Twisted Treasures of the Vale
    105714,  -- Coalesced Turmoil
    105751,  -- Kor'kron Shaman's Treasure
    106130,  -- Big Bag of Herbs
}
for _, id in ipairs(mopIDs) do openables[id] = {} end

openables[88165] = { lockbox = true }  -- Vine-Cracked Junkbox
openables[88567] = { lockbox = true }  -- Ghost Iron Lockbox
