local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local tbcIDs = {
    21979,  -- Gift of Adoration: Darnassus
    22156,  -- Pledge of Adoration: Orgrimmar
    22158,  -- Pledge of Adoration: Thunder Bluff
    22159,  -- Pledge of Friendship: Darnassus
    22160,  -- Pledge of Friendship: Ironforge
    22161,  -- Pledge of Friendship: Orgrimmar
    22162,  -- Pledge of Friendship: Thunder Bluff
    22163,  -- Pledge of Friendship: Undercity
    22164,  -- Gift of Adoration: Orgrimmar
    22165,  -- Gift of Adoration: Thunder Bluff
    22166,  -- Gift of Adoration: Undercity
    22167,  -- Gift of Friendship: Darnassus
    22168,  -- Gift of Friendship: Ironforge
    22169,  -- Gift of Friendship: Orgrimmar
    22170,  -- Gift of Friendship: Stormwind
    22172,  -- Gift of Friendship: Undercity
    22178,  -- Pledge of Friendship: Stormwind
    23846,  -- Nolkai's Box
    23921,  -- Bulging Sack of Silver
    24336,  -- Fireproof Satchel
    24402,  -- Package of Identified Plants
    24476,  -- Jaggal Clam
    25419,  -- Unmarked Bag of Gems
    25422,  -- Bulging Sack of Gems
    25423,  -- Bag of Premium Gems
    25424,  -- Gem-Stuffed Envelope
    27446,  -- Mr. Pinchy's Gift
    27481,  -- Heavy Supply Crate
    27511,  -- Inscribed Scrollcase
    27513,  -- Curious Crate
    30260,  -- Voren'thal's Package
    30320,  -- Bundle of Nether Spikes
    30650,  -- Dertrok's Wand Case
    31408,  -- Offering of the Sha'tar
    31522,  -- Primal Mooncloth Supplies
    31800,  -- Outcast's Cache
    31955,  -- Arelion's Knapsack
    32064,  -- Protectorate Treasure Cache
    32462,  -- Morthis' Materials
    32624,  -- Large Iron Metamorphosis Geode
    32625,  -- Small Iron Metamorphosis Geode
    32626,  -- Large Copper Metamorphosis Geode
    32627,  -- Small Copper Metamorphosis Geode
    32628,  -- Large Silver Metamorphosis Geode
    32629,  -- Large Gold Metamorphosis Geode
    32630,  -- Small Gold Metamorphosis Geode
    32631,  -- Small Silver Metamorphosis Geode
    32724,  -- Sludge-Covered Object
    32777,  -- Kronk's Grab Bag
    32835,  -- Ogri'la Care Package
    33045,  -- Renn's Supplies
    33844,  -- Barrel of Fish
    33857,  -- Crate of Meat
    33926,  -- Sealed Scroll Case
    33928,  -- Hollowed Bone Decanter
    34077,  -- Crudely Wrapped Gift
    34583,  -- Aldor Supplies Package
    34584,  -- Scryer Supplies Package
    34585,  -- Scryer Supplies Package
    34587,  -- Aldor Supplies Package
    34592,  -- Aldor Supplies Package
    34593,  -- Scryer Supplies Package
    34594,  -- Scryer Supplies Package
    34595,  -- Aldor Supplies Package
    34846,  -- Black Sack of Gems
    34863,  -- Bag of Fishing Treasures
    35232,  -- Shattered Sun Supplies
    35286,  -- Bloated Giant Sunfish
    35313,  -- Bloated Barbed Gill Trout
    35348,  -- Bag of Fishing Treasures
    35512,  -- Pocket Full of Snow
    35945,  -- Brilliant Glass
    37586,  -- Handful of Treats
}
for _, id in ipairs(tbcIDs) do openables[id] = {} end

openables[29569] = { lockbox = true }  -- Strong Junkbox
openables[31952] = { lockbox = true }  -- Khorium Lockbox
