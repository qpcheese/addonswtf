local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local wodIDs = {
    107077,  -- Bag of Transformers
    107270,  -- Bound Traveler's Scroll
    107271,  -- Frozen Envelope
    108738,  -- Giant Draenor Clam
    108740,  -- Stolen Weapons
    110278,  -- Engorged Stomach
    110678,  -- Darkmoon Ticket Fanny Pack
    111598,  -- Gold Strongbox
    111599,  -- Silver Strongbox
    111600,  -- Bronze Strongbox
    112108,  -- Cracked Egg
    112623,  -- Pack of Fishing Supplies
    113258,  -- Blingtron 5000 Gift Package
    114028,  -- Small Pouch of Coins
    114634,  -- Icy Satchel of Helpful Goods
    114641,  -- Icy Satchel of Helpful Goods
    114648,  -- Scorched Satchel of Helpful Goods
    114655,  -- Scorched Satchel of Helpful Goods
    114662,  -- Tranquil Satchel of Helpful Goods
    114669,  -- Tranquil Satchel of Helpful Goods
    114970,  -- Small Pouch of Coins
    116062,  -- Greater Darkmoon Pet Supplies
    116111,  -- Small Pouch of Coins
    116129,  -- Desiccated Orc's Coin Pouch
    116202,  -- Pet Care Package
    116376,  -- Small Pouch of Coins
    116404,  -- Pilgrim's Bounty
    116761,  -- Winter Veil Gift
    116764,  -- Small Pouch of Coins
    116980,  -- Invader's Forgotten Treasure
    117386,  -- Crate of Pandaren Archaeology Fragments
    117387,  -- Crate of Mogu Archaeology Fragments
    117388,  -- Crate of Mantid Archaeology Fragments
    117392,  -- Loot-Filled Pumpkin
    117393,  -- Keg-Shaped Treasure Chest
    117394,  -- Satchel of Chilled Goods
    117414,  -- Stormwind Guard Armor Package
    118065,  -- Gleaming Ashmaul Strongbox
    118066,  -- Ashmaul Strongbox
    118093,  -- Dented Ashmaul Strongbox
    118094,  -- Dented Ashmaul Strongbox
    118193,  -- Mysterious Shining Lockbox
    118529,  -- Cache of Highmaul Treasures
    118530,  -- Cache of Highmaul Treasures
    118531,  -- Cache of Highmaul Treasures
    118697,  -- Big Bag of Pet Supplies
    118706,  -- Cracked Goren Egg
    118759,  -- Alchemy Experiment
    118924,  -- Cache of Arms
    118925,  -- Plundered Booty
    118926,  -- Huge Pile of Skins
    118927,  -- Maximillian's Laundry
    118928,  -- Faintly-Sparkling Cache
    118929,  -- Sack of Mined Ore
    118930,  -- Bag of Everbloom Herbs
    118931,  -- Leonid's Bag of Supplies
    119000,  -- Highmaul Lockbox
    119036,  -- Box of Storied Treasures
    119037,  -- Supply of Storied Rarities
    119040,  -- Cache of Mingled Treasures
    119041,  -- Strongbox of Mysterious Treasures
    119042,  -- Crate of Valuable Treasures
    119043,  -- Trove of Smoldering Treasures
    119188,  -- Unclaimed Payment
    119189,  -- Unclaimed Payment
    119190,  -- Unclaimed Payment
    119191,  -- Jewelcrafting Payment
    119195,  -- Jewelcrafting Payment
    119196,  -- Jewelcrafting Payment
    119197,  -- Jewelcrafting Payment
    119198,  -- Jewelcrafting Payment
    119199,  -- Jewelcrafting Payment
    119200,  -- Jewelcrafting Payment
    119201,  -- Jewelcrafting Payment
    119330,  -- Steel Strongbox
    120142,  -- Coliseum Champion's Spoils
    120146,  -- Smuggled Sack of Gold
    120147,  -- Bloody Gold Purse
    120151,  -- Gleaming Ashmaul Strongbox
    120170,  -- Partially-Digested Bag
    120184,  -- Ashmaul Strongbox
    120312,  -- Bulging Sack of Coins
    120319,  -- Invader's Damaged Cache
    120320,  -- Invader's Abandoned Sack
    120322,  -- Klinking Stacked Card Deck
    120323,  -- Bulging Stacked Card Deck
    120324,  -- Bursting Stacked Card Deck
    120325,  -- Overflowing Stacked Card Deck
    120334,  -- Satchel of Cosmic Mysteries
    120353,  -- Steel Strongbox
    120354,  -- Gold Strongbox
    120355,  -- Silver Strongbox
    120356,  -- Bronze Strongbox
    122163,  -- Routed Invader's Crate of Spoils
    122191,  -- Bloody Stack of Invitations
    122478,  -- Scouting Report: Frostfire Ridge
    122479,  -- Scouting Report: Shadowmoon Valley
    122480,  -- Scouting Report: Gorgrond
    122481,  -- Scouting Report: Talador
    122482,  -- Scouting Report: Spires of Arak
    122483,  -- Scouting Report: Nagrand
    122484,  -- Blackrock Foundry Spoils
    122485,  -- Blackrock Foundry Spoils
    122486,  -- Blackrock Foundry Spoils
    122535,  -- Traveler's Pet Supplies
    122607,  -- Savage Satchel of Cooperation
    122613,  -- Stash of Dusty Music Rolls
    122718,  -- Clinking Present
    123857,  -- Runic Pouch
    123858,  -- Follower Retraining Scroll Case
    123975,  -- Greater Bounty Spoils
    124054,  -- Time-Twisted Anomaly
    124670,  -- Sealed Darkmoon Crate
    126901,  -- Gold Strongbox
    126902,  -- Silver Strongbox
    126903,  -- Bronze Strongbox
    126904,  -- Steel Strongbox
    126905,  -- Steel Strongbox
    126906,  -- Gold Strongbox
    126907,  -- Silver Strongbox
    126908,  -- Bronze Strongbox
    126909,  -- Gold Strongbox
    126910,  -- Silver Strongbox
    126911,  -- Bronze Strongbox
    126912,  -- Steel Strongbox
    126913,  -- Steel Strongbox
    126914,  -- Gold Strongbox
    126915,  -- Silver Strongbox
    126916,  -- Bronze Strongbox
    126917,  -- Ashmaul Strongbox
    126918,  -- Ashmaul Strongbox
    126919,  -- Champion's Strongbox
    126920,  -- Champion's Strongbox
    126921,  -- Ashmaul Strongbox
    126922,  -- Ashmaul Strongbox
    126923,  -- Champion's Strongbox
    126924,  -- Champion's Strongbox
    127141,  -- Bloated Thresher
    127148,  -- Silas' Secret Stash
    127395,  -- Ripened Strange Fruit
    127751,  -- Fel-Touched Pet Supplies
    127831,  -- Challenger's Strongbox
    127853,  -- Iron Fleet Treasure Chest
    127854,  -- Iron Fleet Treasure Chest
    127855,  -- Iron Fleet Treasure Chest
    128025,  -- Rattling Iron Cage
    128213,  -- Dented Ashmaul Strongbox
    128214,  -- Dented Ashmaul Strongbox
    128652,  -- Gently Shaken Gift
    128653,  -- Winter Veil Gift
    128803,  -- Savage Satchel of Cooperation
    129928,  -- Frigid Timewarped Prism
}
for _, id in ipairs(wodIDs) do openables[id] = {} end

openables[106895] = { lockbox = true }  -- Iron-Bound Junkbox
openables[116920] = { lockbox = true }  -- True Steel Lockbox
