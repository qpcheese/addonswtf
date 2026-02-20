local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local midnightIDs = {
    238531,  -- Radiant Stomach
    239077,  -- Mound of Mildly-Meaningful Meat
    254677,  -- Apex Cache
    255666,  -- Huge Bag of Midnight General Goods
    255678,  -- Huge Bag of Midnight Herbs
    255679,  -- Huge Bag of Midnight Minerals
    255682,  -- Huge Bag of Midnight Skins
    255683,  -- Huge Bag of Midnight Jewelcrafting Goods
    255684,  -- Huge Bag of Midnight Leatherworking Goods
    255686,  -- Huge Bag of Midnight Alchemy Goods
    255687,  -- Huge Bag of Midnight Optional Goods
    255689,  -- Huge Bag of Midnight Engineering Goods
    255690,  -- Huge Bag of Midnight Enchanting Goods
    255691,  -- Huge Bag of Midnight Tailoring Goods
    255703,  -- Huge Bag of Midnight Blacksmithing Goods
    255704,  -- Huge Bag of Midnight Inscription Goods
    257023,  -- Preyseeker's Adventurer Chest
    257026,  -- Preyseeker's Veteran Chest
    258534,  -- Illustrious Contender's Strongbox
    258620,  -- Field Medic's Hazard Payout
    260193,  -- Fabled Veteran's Cache
    260534,  -- Master Alchemist's Surplus Reagents
    260536,  -- Master Smith's Surplus Reagents
    260537,  -- Master Enchanter's Surplus Reagents
    260538,  -- Master Engineer's Surplus Reagents
    260539,  -- Master Herbalist's Surplus Reagents
    260540,  -- Master Scribe's Surplus Reagents
    260541,  -- Master Jewelcrafter's Surplus Reagents
    260542,  -- Master Leatherworker's Surplus Reagents
    260543,  -- Master Miner's Surplus Reagents
    260544,  -- Master Skinner's Surplus Reagents
    260545,  -- Master Tailor's Surplus Reagents
    260940,  -- Victorious Stormarion Pinnacle Cache
    260979,  -- Victorious Stormarion Cache
    262346,  -- Preyseeker's Champion Chest
    262349,  -- Satchel of Compensation
    262596,  -- Preyseeker's Satchel of Voidlight Marl
    262622,  -- Preyseeker's Satchel of Coffer Key Shards
    262623,  -- Preyseeker's Satchel of Adventurer Dawncrests
    262624,  -- Preyseeker's Satchel of Anguish
    262626,  -- Preyseeker's Box of Anguish
    262627,  -- Preyseeker's Box of Coffer Key Shards
    262629,  -- Preyseeker's Box of Veteran Dawncrests
    262630,  -- Preyseeker's Box of Voidlight Marl
    262631,  -- Preyseeker's Cache of Anguish
    262632,  -- Preyseeker's Cache of Coffer Key Shards
    262633,  -- Preyseeker's Cache of Champion Dawncrests
    262634,  -- Preyseeker's Cache of Voidlight Marl
    262662,  -- Thalassian Distinguishment
    262928,  -- Preyseeker's Adventurer Sack
    262936,  -- Preyseeker's Veteran Sack
    262938,  -- Preyseeker's Champion Sack
    263178,  -- Delver's Starter Kit
    263179,  -- Delver's Cosmetic Surprise Bag
    263465,  -- Surplus Bag of Party Favors
    263466,  -- Overflowing Abundant Satchel
    263467,  -- Avid Learner's Supply Pack
    263468,  -- Stormarion Spoils
    264274,  -- Fabled Adventurer's Cache
    264972,  -- Voidstorm Victuals
    264988,  -- Endgame Essentials
    265995,  -- Quel'Thalas Adventurer's Cache
    268485,  -- Victorious Stormarion Pinnacle Cache
    268487,  -- Avid Learner's Supply Pack
    268488,  -- Overflowing Abundant Satchel
    268489,  -- Surplus Bag of Party Favors
    268490,  -- Apex Cache
    268545,  -- Aspiring Preyseeker's Chest
    269005,  -- Preyseeker's Glinting Coin Pouch
    269006,  -- Preyseeker's Gleaming Coin Pouch
    269007,  -- Preyseeker's Glittering Coin Pouch
    269701,  -- Surplus Bag of Party Favors
    269702,  -- Overflowing Abundant Satchel
    269703,  -- Avid Learner's Supply Pack
    269704,  -- Victorious Stormarion Cache
}
for _, id in ipairs(midnightIDs) do openables[id] = {} end
