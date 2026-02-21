local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local dfIDs = {
    189765,  -- Maruuk Centaur Supply Satchel
    190233,  -- Maruuk Centaur Supplies
    191203,  -- Dragonscale Expedition Supplies
    192111,  -- Renewed Proto-Drake: Red Scales
    192131,  -- Valdrakken Weapon Chain
    192132,  -- Draconium Blade Sharpener
    192890,  -- Keeper's Glory
    192891,  -- Earthwarden's Prize
    192892,  -- Timewatcher's Patience
    192893,  -- Jeweled Dragon's Heart
    193205,  -- Ohuna Companion Color: Brown
    193376,  -- Adenedal's Tidy Purse
    193891,  -- Experimental Substance
    193897,  -- Reawakened Catalyst
    193898,  -- Umbral Bone Needle
    193899,  -- Primalweave Spindle
    193900,  -- Prismatic Focusing Shard
    193901,  -- Primal Dust
    193902,  -- Eroded Titan Gizmo
    193903,  -- Watcher Power Core
    193904,  -- Phoenix Feather Quill
    193905,  -- Iskaaran Trading Ledger
    193907,  -- Chipped Tyrstone
    193909,  -- Ancient Gem Fragments
    193910,  -- Molted Dragon Scales
    193913,  -- Preserved Animal Parts
    194034,  -- Renewed Proto-Drake
    194039,  -- Heated Ore Sample
    194062,  -- Unyielding Stone Chunk
    194072,  -- Sack of Gold
    194087,  -- Ohuna Companion Color: Red
    194088,  -- Ohuna Companion Color: Dark
    194089,  -- Bakar Companion Color: Orange
    194090,  -- Bakar Companion Color: White
    194091,  -- Bakar Companion Color: Golden Brown
    194093,  -- Bakar Companion Color: Brown
    194094,  -- Bakar Companion Color: Black
    194095,  -- Ohuna Companion Color: Sepia
    194419,  -- Life Pool Herb Pouch
    194741,  -- Earthbound Tome
    194750,  -- Professional Equipment
    194838,  -- Highland Drake Manuscript: Spined Head
    196961,  -- Cliffside Wylderdrake: Armor
    196962,  -- Cliffside Wylderdrake: Silver and Purple Armor
    196963,  -- Cliffside Wylderdrake: Silver and Blue Armor
    196964,  -- Cliffside Wylderdrake: Gold and Black Armor
    196965,  -- Cliffside Wylderdrake: Bronze and Teal Armor
    196966,  -- Cliffside Wylderdrake: Gold and Orange Armor
    196967,  -- Cliffside Wylderdrake: Gold and White Armor
    196968,  -- Cliffside Wylderdrake: Steel and Yellow Armor
    196969,  -- Cliffside Wylderdrake: Finned Back
    196970,  -- Cliffside Wylderdrake: Spiked Back
    196971,  -- Cliffside Wylderdrake: Spiked Brow
    196972,  -- Cliffside Wylderdrake: Plated Brow
    196973,  -- Cliffside Wylderdrake: Dual Horned Chin
    196974,  -- Cliffside Wylderdrake: Four-Horned Chin
    196975,  -- Cliffside Wylderdrake: Head Fin
    196976,  -- Cliffside Wylderdrake: Head Mane
    196977,  -- Cliffside Wylderdrake: Split Head Horns
    196978,  -- Cliffside Wylderdrake: Small Head Spikes
    196979,  -- Cliffside Wylderdrake: Curled Head Horns
    196980,  -- Cliffside Wylderdrake: Triple Head Horns
    196981,  -- Cliffside Wylderdrake: Conical Head
    196982,  -- Cliffside Wylderdrake: Ears
    196983,  -- Cliffside Wylderdrake: Maned Jaw
    196984,  -- Cliffside Wylderdrake: Finned Jaw
    196985,  -- Cliffside Wylderdrake: Horned Jaw
    196986,  -- Cliffside Wylderdrake: Black Hair
    196987,  -- Cliffside Wylderdrake: Blonde Hair
    196988,  -- Cliffside Wylderdrake: Red Hair
    196989,  -- Cliffside Wylderdrake: White Hair
    196990,  -- Cliffside Wylderdrake: Helm
    196991,  -- Cliffside Wylderdrake: Black Horns
    196992,  -- Cliffside Wylderdrake: Heavy Horns
    196993,  -- Cliffside Wylderdrake: Sleek Horns
    196994,  -- Cliffside Wylderdrake: Short Horns
    196995,  -- Cliffside Wylderdrake: Spiked Horns
    196996,  -- Cliffside Wylderdrake: Branched Horns
    196997,  -- Cliffside Wylderdrake: Split Horns
    196998,  -- Cliffside Wylderdrake: Hook Horns
    196999,  -- Cliffside Wylderdrake: Swept Horns
    197000,  -- Cliffside Wylderdrake: Coiled Horns
    197001,  -- Cliffside Wylderdrake: Finned Cheek
    197002,  -- Cliffside Wylderdrake: Flared Cheek
    197003,  -- Cliffside Wylderdrake: Spiked Cheek
    197004,  -- Cliffside Wylderdrake: Spiked Legs
    197005,  -- Cliffside Wylderdrake: Horned Nose
    197006,  -- Cliffside Wylderdrake: Plated Nose
    197007,  -- Cliffside Wylderdrake: Wide Stripes Pattern
    197008,  -- Cliffside Wylderdrake: Narrow Stripes Pattern
    197009,  -- Cliffside Wylderdrake: Scaled Pattern
    197010,  -- Cliffside Wylderdrake: Red Scales
    197011,  -- Cliffside Wylderdrake: Green Scales
    197012,  -- Cliffside Wylderdrake: Blue Scales
    197013,  -- Cliffside Wylderdrake: Black Scales
    197014,  -- Cliffside Wylderdrake: White Scales
    197015,  -- Cliffside Wylderdrake: Dark Skin Variation
    197016,  -- Cliffside Wylderdrake: Maned Tail
    197017,  -- Cliffside Wylderdrake: Large Tail Spikes
    197018,  -- Cliffside Wylderdrake: Finned Tail
    197019,  -- Cliffside Wylderdrake: Blunt Spiked Tail
    197022,  -- Cliffside Wylderdrake: Finned Neck
    197023,  -- Cliffside Wylderdrake: Maned Neck
    197090,  -- Highland Drake: Gold and Black Armor
    197091,  -- Highland Drake: Silver and Blue Armor
    197093,  -- Highland Drake: Silver and Purple Armor
    197094,  -- Highland Drake: Gold and Red Armor
    197095,  -- Highland Drake: Gold and White Armor
    197096,  -- Highland Drake: Steel and Yellow Armor
    197097,  -- Highland Drake: Spined Back
    197098,  -- Highland Drake: Finned Back
    197099,  -- Highland Drake: Armor
    197100,  -- Highland Drake: Crested Brow
    197101,  -- Highland Drake: Bushy Brow
    197102,  -- Highland Drake: Horned Chin
    197103,  -- Highland Drake: Maned Chin
    197104,  -- Highland Drake: Tapered Chin
    197105,  -- Highland Drake: Spined Chin
    197106,  -- Highland Drake: Finned Head
    197107,  -- Highland Drake: Triple Finned Head
    197108,  -- Highland Drake: Spined Head
    197109,  -- Highland Drake: Spiked Head
    197110,  -- Highland Drake: Plated Head
    197111,  -- Highland Drake: Maned Head
    197112,  -- Highland Drake: Single Horned Head
    197113,  -- Highland Drake: Swept Spiked Head
    197114,  -- Highland Drake: Multi-Horned Head
    197115,  -- Highland Drake: Thorned Jaw
    197116,  -- Highland Drake: Ears
    197117,  -- Highland Drake: Black Hair
    197118,  -- Highland Drake: Brown Hair
    197119,  -- Highland Drake: Helm
    197120,  -- Highland Drake: Ornate Helm
    197121,  -- Highland Drake: Tan Horns
    197122,  -- Highland Drake: Heavy Horns
    197123,  -- Highland Drake: Thorn Horns
    197124,  -- Highland Drake: Swept Horns
    197125,  -- Highland Drake: Coiled Horns
    197126,  -- Highland Drake: Hooked Horns
    197127,  -- Highland Drake: Grand Thorn Horns
    197128,  -- Highland Drake: Curled Back Horns
    197129,  -- Highland Drake: Sleek Horns
    197130,  -- Highland Drake: Stag Horns
    197131,  -- Highland Drake: Hairy Cheek
    197132,  -- Highland Drake: Spiked Cheek
    197133,  -- Highland Drake: Spined Cheek
    197134,  -- Highland Drake: Spiked Legs
    197135,  -- Highland Drake: Toothy Mouth
    197136,  -- Highland Drake: Tapered Nose
    197137,  -- Highland Drake: Spined Nose
    197138,  -- Highland Drake: Striped Pattern
    197139,  -- Highland Drake: Large Spotted Pattern
    197140,  -- Highland Drake: Small Spotted Pattern
    197141,  -- Highland Drake: Scaled Pattern
    197142,  -- Highland Drake: Black Scales
    197143,  -- Highland Drake: Green Scales
    197144,  -- Highland Drake: Red Scales
    197145,  -- Highland Drake: Bronze Scales
    197146,  -- Highland Drake: White Scales
    197147,  -- Highland Drake: Heavy Scales
    197148,  -- Highland Drake: Vertical Finned Tail
    197149,  -- Highland Drake: Club Tail
    197150,  -- Highland Drake: Spiked Club Tail
    197151,  -- Highland Drake: Spiked Tail
    197152,  -- Highland Drake: Hooked Tail
    197153,  -- Highland Drake: Bladed Tail
    197154,  -- Highland Drake: Spined Neck
    197155,  -- Highland Drake: Finned Neck
    197156,  -- Highland Drake: Bronze and Green Armor
    197346,  -- Renewed Proto-Drake: Gold and Black Armor
    197347,  -- Renewed Proto-Drake: Silver and Blue Armor
    197348,  -- Renewed Proto-Drake: Black and Red Armor
    197349,  -- Renewed Proto-Drake: Gold and White Armor
    197350,  -- Renewed Proto-Drake: Silver and Purple Armor
    197351,  -- Renewed Proto-Drake: Gold and Red Armor
    197352,  -- Renewed Proto-Drake: Steel and Yellow Armor
    197353,  -- Renewed Proto-Drake: Bronze and Pink Armor
    197356,  -- Renewed Proto-Drake: Hairy Back
    197357,  -- Renewed Proto-Drake: Armor
    197358,  -- Renewed Proto-Drake: Curved Spiked Brow
    197359,  -- Renewed Proto-Drake: Hairy Brow
    197360,  -- Renewed Proto-Drake: Spined Brow
    197361,  -- Renewed Proto-Drake: Spiked Crest
    197362,  -- Renewed Proto-Drake: Spined Crest
    197363,  -- Renewed Proto-Drake: Maned Crest
    197364,  -- Renewed Proto-Drake: Short Spiked Crest
    197365,  -- Renewed Proto-Drake: Finned Crest
    197366,  -- Renewed Proto-Drake: Dual Horned Crest
    197367,  -- Renewed Proto-Drake: Gray Hair
    197368,  -- Renewed Proto-Drake: Blue Hair
    197369,  -- Renewed Proto-Drake: Brown Hair
    197370,  -- Renewed Proto-Drake: Red Hair
    197371,  -- Renewed Proto-Drake: Green Hair
    197372,  -- Renewed Proto-Drake: Purple Hair
    197373,  -- Renewed Proto-Drake: Helm
    197374,  -- Renewed Proto-Drake: Swept Horns
    197375,  -- Renewed Proto-Drake: Curled Horns
    197376,  -- Renewed Proto-Drake: Ears
    197377,  -- Renewed Proto-Drake: Bovine Horns
    197378,  -- Renewed Proto-Drake: Subtle Horns
    197379,  -- Renewed Proto-Drake: Impaler Horns
    197380,  -- Renewed Proto-Drake: Curved Horns
    197381,  -- Renewed Proto-Drake: Gradient Horns
    197382,  -- Renewed Proto-Drake: White Horns
    197383,  -- Renewed Proto-Drake: Heavy Horns
    197384,  -- Renewed Proto-Drake: Thick Spined Jaw
    197385,  -- Renewed Proto-Drake: Horned Jaw
    197386,  -- Renewed Proto-Drake: Spiked Jaw
    197387,  -- Renewed Proto-Drake: Thin Spined Jaw
    197388,  -- Renewed Proto-Drake: Finned Jaw
    197389,  -- Renewed Proto-Drake: Green Scales
    197390,  -- Renewed Proto-Drake: Blue Scales
    197391,  -- Renewed Proto-Drake: Bronze Scales
    197392,  -- Renewed Proto-Drake: Black Scales
    197393,  -- Renewed Proto-Drake: White Scales
    197394,  -- Renewed Proto-Drake: Predator Pattern
    197395,  -- Renewed Proto-Drake: Harrier Pattern
    197396,  -- Renewed Proto-Drake: Skyterror Pattern
    197397,  -- Renewed Proto-Drake: Heavy Scales
    197398,  -- Renewed Proto-Drake: Snub Snout
    197399,  -- Renewed Proto-Drake: Razor Snout
    197400,  -- Renewed Proto-Drake: Shark Snout
    197401,  -- Renewed Proto-Drake: Beaked Snout
    197402,  -- Renewed Proto-Drake: Spiked Club Tail
    197403,  -- Renewed Proto-Drake: Club Tail
    197404,  -- Renewed Proto-Drake: Finned Tail
    197405,  -- Renewed Proto-Drake: Maned Tail
    197406,  -- Renewed Proto-Drake: Spined Tail
    197407,  -- Renewed Proto-Drake: Spiked Throat
    197408,  -- Renewed Proto-Drake: Finned Throat
    197577,  -- Windborne Velocidrake: Bronze and Green Armor
    197578,  -- Windborne Velocidrake: Silver and Blue Armor
    197579,  -- Windborne Velocidrake: Steel and Orange Armor
    197580,  -- Windborne Velocidrake: Gold and Red Armor
    197581,  -- Windborne Velocidrake: Silver and Purple Armor
    197582,  -- Windborne Velocidrake: White and Pink Armor
    197583,  -- Windborne Velocidrake: Exposed Finned Back
    197584,  -- Windborne Velocidrake: Finned Back
    197585,  -- Windborne Velocidrake: Maned Back
    197586,  -- Windborne Velocidrake: Spiked Back
    197587,  -- Windborne Velocidrake: Feathered Back
    197588,  -- Windborne Velocidrake: Armor
    197589,  -- Windborne Velocidrake: Large Head Fin
    197592,  -- Windborne Velocidrake: Spined Head
    197593,  -- Windborne Velocidrake: Feathery Head
    197594,  -- Windborne Velocidrake: Small Ears
    197595,  -- Windborne Velocidrake: Finned Ears
    197596,  -- Windborne Velocidrake: Horned Jaw
    197597,  -- Windborne Velocidrake: Black Fur
    197598,  -- Windborne Velocidrake: Gray Hair
    197599,  -- Windborne Velocidrake: Red Hair
    197600,  -- Windborne Velocidrake: Helm
    197601,  -- Windborne Velocidrake: Wavy Horns
    197602,  -- Windborne Velocidrake: Cluster Horns
    197603,  -- Windborne Velocidrake: Curved Horns
    197604,  -- Windborne Velocidrake: Ox Horns
    197605,  -- Windborne Velocidrake: Curled Horns
    197606,  -- Windborne Velocidrake: Swept Horns
    197607,  -- Windborne Velocidrake: Split Horns
    197608,  -- Windborne Velocidrake: Gray Horns
    197609,  -- Windborne Velocidrake: White Horns
    197610,  -- Windborne Velocidrake: Yellow Horns
    197611,  -- Windborne Velocidrake: Black Scales
    197612,  -- Windborne Velocidrake: Blue Scales
    197613,  -- Windborne Velocidrake: Bronze Scales
    197614,  -- Windborne Velocidrake: Red Scales
    197615,  -- Windborne Velocidrake: Teal Scales
    197616,  -- Windborne Velocidrake: White Scales
    197617,  -- Windborne Velocidrake: Heavy Scales
    197618,  -- Windborne Velocidrake: Long Snout
    197619,  -- Windborne Velocidrake: Hooked Snout
    197620,  -- Windborne Velocidrake: Beaked Snout
    197621,  -- Windborne Velocidrake: Exposed Finned Tail
    197622,  -- Windborne Velocidrake: Finned Tail
    197623,  -- Windborne Velocidrake: Spiked Tail
    197624,  -- Windborne Velocidrake: Club Tail
    197625,  -- Windborne Velocidrake: Feathery Tail
    197626,  -- Windborne Velocidrake: Exposed Finned Neck
    197627,  -- Windborne Velocidrake: Finned Neck
    197628,  -- Windborne Velocidrake: Plated Neck
    197629,  -- Windborne Velocidrake: Spiked Neck
    197630,  -- Windborne Velocidrake: Feathered Neck
    197634,  -- Windborne Velocidrake: Windswept Pattern
    197635,  -- Windborne Velocidrake: Reaver Pattern
    197636,  -- Windborne Velocidrake: Shrieker Pattern
    198166,  -- Suspiciously Ticking Crate
    198167,  -- Suspiciously Ticking Crate
    198168,  -- Suspiciously Ticking Crate
    198169,  -- Suspiciously Silent Crate
    198170,  -- Suspiciously Silent Crate
    198171,  -- Suspiciously Silent Crate
    198172,  -- Bundle of Fireworks
    198395,  -- Dull Spined Clam
    198438,  -- Draconic Recipe in a Bottle
    198439,  -- Aged Recipe in a Bottle
    198538,  -- Magically Bound Message
    198599,  -- Experimental Decay Sample
    198606,  -- Blacksmith's Writ
    198607,  -- Scribe's Glyphs
    198608,  -- Alchemy Notes
    198609,  -- Tailoring Examples
    198610,  -- Enchanter's Script
    198611,  -- Engineering Details
    198612,  -- Jeweler's Cuts
    198613,  -- Leatherworking Designs
    198614,  -- Soggy Clump of Darkmoon Cards
    198656,  -- Painter's Pretty Jewel
    198658,  -- Decay-Infused Tanning Oil
    198659,  -- Forgetful Apprentice's Tome
    198660,  -- Fragmented Key
    198662,  -- Intriguing Bolt of Blue Cloth
    198663,  -- Frostforged Potion
    198664,  -- Crystalline Overgrowth
    198667,  -- Spare Djaradin Tools
    198669,  -- How to Train Your Whelpling
    198670,  -- Lofty Malygite
    198675,  -- Lava-Infused Seed
    198680,  -- Decaying Brackenhide Blanket
    198682,  -- Alexstraszite Cluster
    198683,  -- Treated Hides
    198685,  -- Well-Insulated Mug
    198686,  -- Frosted Parchment
    198687,  -- Closely Guarded Shiny
    198689,  -- Stormbound Horn
    198690,  -- Decayed Scales
    198692,  -- Noteworthy Scrap of Carpet
    198693,  -- Dusty Darkmoon Card
    198694,  -- Enriched Earthen Shard
    198696,  -- Wind-Blessed Hide
    198697,  -- Contraband Concoction
    198699,  -- Mysterious Banner
    198702,  -- Itinerant Singed Fabric
    198703,  -- Sign Language Reference Sheet
    198704,  -- Pulsing Earth Rune
    198710,  -- Canteen of Suspicious Water
    198711,  -- Poacher's Pack
    198790,  -- I.O.U.
    198798,  -- Flashfrozen Scroll
    198799,  -- Forgotten Arcane Tome
    198800,  -- Fractured Titanic Sphere
    198837,  -- Curious Hide Scraps
    198841,  -- Large Sample of Curious Hide
    198863,  -- Small Dragon Expedition Supply Pack
    198864,  -- Large Maruuk Centaur Supply Satchel
    198865,  -- Large Dragon Expedition Supply Pack
    198866,  -- Small Iskaaran Supply Pack
    198867,  -- Large Iskaaran Supply Pack
    198868,  -- Small Valdrakken Accord Supply Pack
    198869,  -- Large Valdrakken Accord Supply Pack
    198891,  -- Technique: Cliffside Wylderdrake: Conical Head
    198892,  -- Technique: Cliffside Wylderdrake: Red Hair
    198894,  -- Technique: Highland Drake: Black Hair
    198895,  -- Technique: Highland Drake: Spined Head
    198896,  -- Technique: Highland Drake: Spined Neck
    198899,  -- Technique: Renewed Proto-Drake: Predator Pattern
    198901,  -- Technique: Renewed Proto-Drake: Spined Crest
    198903,  -- Technique: Windborne Velocidrake: Spined Head
    198963,  -- Decaying Phlegm
    198964,  -- Elementious Splinter
    198965,  -- Primeval Earth Fragment
    198966,  -- Molten Globule
    198967,  -- Primordial Aether
    198968,  -- Primalist Charm
    198969,  -- Keeper's Mark
    198970,  -- Infinitely Attachable Pair o' Docks
    198971,  -- Curious Djaradin Rune
    198972,  -- Draconic Glamour
    198973,  -- Incandescent Curio
    198974,  -- Elegantly Engraved Embellishment
    198975,  -- Ossified Hide
    198976,  -- Exceedingly Soft Skin
    198977,  -- Ohn'arhan Weave
    198978,  -- Stupidly Effective Stitchery
    199108,  -- Bag of Discount Goods
    199115,  -- Herbalism Field Notes
    199122,  -- Mining Field Notes
    199128,  -- Skinning Field Notes
    199192,  -- Dragon Racer's Purse
    199341,  -- Regurgitated Sac of Swog Treasures
    199342,  -- Weighted Sac of Swog Treasures
    199472,  -- Overflowing Dragon Expedition Supply Pack
    199473,  -- Overflowing Iskaaran Supply Pack
    199474,  -- Overflowing Maruuk Centaur Supply Satchel
    199475,  -- Overflowing Valdrakken Accord Supply Pack
    200069,  -- Obsidian Cache
    200070,  -- Obsidian Strongbox
    200072,  -- Dragonbane Keep Strongbox
    200073,  -- Valdrakken Treasures
    200094,  -- Caravan Strongbox
    200095,  -- Supply-Laden Soup Pot
    200156,  -- Amethyzarite Geode
    200285,  -- Dragonscale Expedition Insignia
    200287,  -- Iskaara Tuskarr Insignia
    200288,  -- Maruuk Centaur Insignia
    200289,  -- Valdrakken Accord Insignia
    200300,  -- Sack of Looted Treasures
    200452,  -- Dragonscale Expedition Insignia
    200453,  -- Iskaara Tuskarr Insignia
    200454,  -- Maruuk Centaur Insignia
    200455,  -- Valdrakken Accord Insignia
    200468,  -- Grand Hunt Spoils
    200477,  -- Stack of VIP Passes
    200513,  -- Grand Hunt Spoils
    200609,  -- Dragon Racing Purse - First Place
    200610,  -- Dragon Racing Purse - Second Place
    200611,  -- Dragon Racing Purse - Third Place
    200677,  -- Dreambloom Petal
    200678,  -- Dreambloom
    200931,  -- Encaged Fiery Soul
    200932,  -- Encaged Airy Soul
    200934,  -- Encaged Frosty Soul
    200936,  -- Encaged Earthen Soul
    200972,  -- Dusty Blacksmith's Diagrams
    200973,  -- Dusty Scribe's Runic Drawings
    200974,  -- Dusty Alchemist's Research
    200975,  -- Dusty Tailor's Diagrams
    200976,  -- Dusty Enchanter's Research
    200977,  -- Dusty Engineer's Scribblings
    200978,  -- Dusty Jeweler's Illustrations
    200979,  -- Dusty Leatherworker's Diagrams
    200980,  -- Dusty Herbalist's Notes
    200981,  -- Dusty Miner's Notes
    200982,  -- Dusty Skinner's Notes
    201003,  -- Furry Gloop
    201004,  -- Ancient Spear Shards
    201005,  -- Curious Ingots
    201006,  -- Draconic Flux
    201007,  -- Ancient Monument
    201008,  -- Molten Ingot
    201009,  -- Falconer Gauntlet Drawings
    201010,  -- Qalashi Weapon Diagram
    201011,  -- Spelltouched Tongs
    201012,  -- Enchanted Debris
    201013,  -- Faintly Enchanted Remains
    201014,  -- Boomthyr Rocket
    201015,  -- Counterfeit Darkmoon Deck
    201016,  -- Harmonic Crystal Harmonizer
    201017,  -- Igneous Gem
    201018,  -- Well-Danced Drum
    201019,  -- Ancient Dragonweave Bolt
    201020,  -- Silky Surprise
    201250,  -- Victorious Contender's Strongbox
    201251,  -- Pillaged Contender's Strongbox
    201252,  -- 10.0 Bronze PvP Chest (DNT)
    201268,  -- Rare Blacksmith's Diagrams
    201269,  -- Rare Scribe's Runic Drawings
    201270,  -- Rare Alchemist's Research
    201271,  -- Rare Tailor's Diagrams
    201272,  -- Rare Enchanter's Research
    201273,  -- Rare Engineer's Scribblings
    201274,  -- Rare Jeweler's Illustrations
    201275,  -- Rare Leatherworker's Diagrams
    201276,  -- Rare Herbalist's Notes
    201277,  -- Rare Miner's Notes
    201278,  -- Rare Skinner's Notes
    201279,  -- Ancient Blacksmith's Diagrams
    201280,  -- Ancient Scribe's Runic Drawings
    201281,  -- Ancient Alchemist's Research
    201282,  -- Ancient Tailor's Diagrams
    201283,  -- Ancient Enchanter's Research
    201284,  -- Ancient Engineer's Scribblings
    201285,  -- Ancient Jeweler's Illustrations
    201286,  -- Ancient Leatherworker's Diagrams
    201287,  -- Ancient Herbalist's Notes
    201288,  -- Ancient Miner's Notes
    201289,  -- Ancient Skinner's Notes
    201296,  -- Docile Airy Soul
    201297,  -- Docile Earthen Soul
    201298,  -- Docile Fiery Soul
    201299,  -- Docile Frosty Soul
    201300,  -- Iridescent Ore Fragments
    201301,  -- Iridescent Ore
    201326,  -- Draconic Satchel of Cooperation
    201343,  -- Bag of Cloth Armor Reagents
    201352,  -- Bag of Leather Reagents
    201353,  -- Bag of Mail Armor Reagents
    201354,  -- Bag of Plate Armor Reagents
    201439,  -- Renewed Dream
    201462,  -- Curiously-Shaped Stomach
    201700,  -- Notebook of Crafting Knowledge
    201705,  -- Notebook of Crafting Knowledge
    201706,  -- Notebook of Crafting Knowledge
    201708,  -- Notebook of Crafting Knowledge
    201709,  -- Notebook of Crafting Knowledge
    201710,  -- Notebook of Crafting Knowledge
    201715,  -- Notebook of Crafting Knowledge
    201716,  -- Notebook of Crafting Knowledge
    201717,  -- Notebook of Crafting Knowledge
    201718,  -- Notebook of Crafting Knowledge
    201728,  -- Vakril's Strongbox
    201736,  -- Technique: Cliffside Wylderdrake: Steel and Yellow Armor
    201737,  -- Technique: Highland Drake: Steel and Yellow Armor
    201738,  -- Technique: Renewed Proto-Drake: Steel and Yellow Armor
    201739,  -- Technique: Windborne Velocidrake: Steel and Orange Armor
    201754,  -- Obsidian Forgemaster's Cache
    201755,  -- Obsidian Forgemaster's Strongbox
    201756,  -- Bulging Coin Purse
    201757,  -- Plundered Supplies
    201779,  -- Merithra's Blessing
    201783,  -- Tutaqan's Commendation
    201790,  -- Renewed Proto-Drake: Embodiment of the Storm-Eater
    201792,  -- Highland Drake: Embodiment of the Crimson Gladiator
    201817,  -- Twilight Cache
    201818,  -- Twilight Strongbox
    201921,  -- Dragonscale Expedition Insignia
    201922,  -- Iskaara Tuskarr Insignia
    201923,  -- Maruuk Centaur Insignia
    201924,  -- Valdrakken Accord Insignia
    202011,  -- Elementally Charged Stone
    202014,  -- Infused Pollen
    202016,  -- Saturated Bone
    202048,  -- Queen's Gift
    202049,  -- Dreamer's Vision
    202050,  -- Keeper's Glory
    202051,  -- Earthwarden's Prize
    202052,  -- Timewatcher's Patience
    202054,  -- Queen's Gift
    202055,  -- Dreamer's Vision
    202056,  -- Keeper's Glory
    202057,  -- Earthwarden's Prize
    202058,  -- Timewatcher's Patience
    202079,  -- Cache of Vault Treasures
    202080,  -- Cache of Vault Treasures
    202092,  -- Iskaara Tuskarr Insignia
    202094,  -- Maruuk Centaur Insignia
    202097,  -- Bulging Box of Skins and Scales
    202098,  -- Crowded Crate of Mined Materials
    202099,  -- Stocked Sack of Hale Herbs
    202100,  -- Populous Pack of Castoff Cloth
    202101,  -- Topped Trunk of Disenchanted Detritus
    202102,  -- Immaculate Sac of Swog Treasures
    202122,  -- Primal Chaos Cluster
    202142,  -- Dragonbane Keep Strongbox
    202171,  -- Obsidian Flightstone
    202172,  -- Overflowing Satchel of Coins
    202183,  -- Small Rumble Purse
    202371,  -- Glowing Primalist Cache
    203210,  -- Dragonscale Supply Box
    203217,  -- Dragonscale Surplus Crate
    203218,  -- Iskaara Supply Pouch
    203220,  -- Iskaara Surplus Bag
    203221,  -- Maruuk Supply Sack
    203222,  -- Maruuk Surplus Bundle
    203223,  -- Valdrakken Supply Coffer
    203224,  -- Valdrakken Surplus Chest
    203323,  -- Winding Slitherdrake: Brown Hair
    203324,  -- Winding Slitherdrake: White Hair
    203325,  -- Winding Slitherdrake: Red Hair
    203327,  -- Winding Slitherdrake: Tan Horns
    203328,  -- Winding Slitherdrake: White Horns
    203338,  -- Winding Slitherdrake: Antler Horns
    203341,  -- Winding Slitherdrake: Long Jaw Horns
    203342,  -- Winding Slitherdrake: Triple Jaw Horns
    203343,  -- Winding Slitherdrake: Hairy Jaw
    203344,  -- Winding Slitherdrake: Single Jaw Horn
    203345,  -- Winding Slitherdrake: Split Jaw Horns
    203346,  -- Winding Slitherdrake: Curled Nose
    203347,  -- Winding Slitherdrake: Large Spiked Nose
    203348,  -- Winding Slitherdrake: Pointed Nose
    203349,  -- Winding Slitherdrake: Curved Nose Horn
    203350,  -- Winding Slitherdrake: Blue Scales
    203351,  -- Winding Slitherdrake: Bronze Scales
    203352,  -- Winding Slitherdrake: Green Scales
    203353,  -- Winding Slitherdrake: Red Scales
    203354,  -- Winding Slitherdrake: White Scales
    203355,  -- Winding Slitherdrake: Yellow Scales
    203476,  -- Primalist Cache
    203681,  -- Stormed Primalist Cache
    203699,  -- Tattered Gift Package
    203700,  -- Tattered Gift Package
    203724,  -- Field Medic's Hazard Payout
    203730,  -- Rustic Winterpelt Supplies
    203742,  -- Waterlogged Gurubashi Cache
    203774,  -- Big Bag o' Bijous
    203912,  -- Penny Pouch o' Paragons
    203959,  -- Gurubashi Tribute
    204346,  -- Arclight Rumble Foil Box
    204359,  -- Reach Racer's Purse
    204378,  -- Brimming Dragonscale Expedition Supply Pack
    204379,  -- Brimming Iskaaran Supply Pack
    204380,  -- Brimming Maruuk Centaur Supply Satchel
    204381,  -- Brimming Valdrakken Accord Supply Pack
    204383,  -- Sack of Oddities
    204403,  -- Sack of Sack of Oddities
    204636,  -- Snarfang's Stomach Sac
    204712,  -- Brimming Loamm Niffen Supply Satchel
    204721,  -- Whelpling's Small Chest
    204722,  -- Whelpling's Bountiful Chest
    204723,  -- Whelpling's Hefty Chest
    204724,  -- Drake's Small Chest
    204725,  -- Drake's Hefty Chest
    204726,  -- Drake's Bountiful Chest
    204911,  -- Propagated Spore
    205212,  -- Marrow-Ripened Slime
    205226,  -- Cavern Racer's Purse
    205247,  -- Clinking Dirt-Covered Pouch
    205248,  -- Clanging Dirt-Covered Pouch
    205249,  -- Pungent Niffen Incense
    205250,  -- Gift of the High Redolence
    205251,  -- Champion's Rock Bar
    205252,  -- Momento of Rekindled Bonds
    205253,  -- Farmhand's Abundant Harvest
    205254,  -- Honorary Explorer's Compass
    205288,  -- Buried Niffen Collection
    205342,  -- Loamm Niffen Insignia
    205346,  -- Hidden Niffen Treasure
    205347,  -- Gathered Niffen Resources
    205349,  -- Niffen Notebook of Engineering Knowledge
    205351,  -- Niffen Notebook of Enchanting Knowledge
    205352,  -- Niffen Notebook of Blacksmithing Knowledge
    205353,  -- Niffen Notebook of Alchemy Knowledge
    205354,  -- Niffen Notebook of Inscription Knowledge
    205355,  -- Niffen Notebook of Tailoring Knowledge
    205356,  -- Niffen Notebook of Mining Knowledge
    205367,  -- Indebted Researcher's Gift
    205368,  -- Thankful Researcher's Gift
    205369,  -- Appreciative Researcher's Gift
    205370,  -- Researcher's Gift
    205371,  -- Appreciative Researcher's Scrounged Goods
    205372,  -- Indebted Researcher's Scrounged Goods
    205373,  -- Researcher's Scrounged Goods
    205374,  -- Thankful Researcher's Scrounged Goods
    205423,  -- Shadowflame Residue Sack
    205682,  -- Large Shadowflame Residue Sack
    205877,  -- Adventurer's Footlocker
    205962,  -- Echoing Storm Flightstone
    205964,  -- Small Loammian Supply Pack
    205965,  -- Large Loammian Supply Pack
    205968,  -- Overflowing Loammian Supply Pack
    205970,  -- Azure Flightstone
    205983,  -- Scentsational Niffen Treasures
    205985,  -- Loamm Niffen Insignia
    205989,  -- Symbol of Friendship
    205991,  -- Shiny Token of Gratitude
    205992,  -- Regurgitated Half-Digested Fish
    205998,  -- Sign of Respect
    206006,  -- Earth-Warder's Thanks
    206028,  -- Chest of Gold
    206030,  -- Exquisitely Embroidered Banner
    206037,  -- Ruby Flightstone
    206039,  -- Enmity Bundle
    206135,  -- Heroic Dungeon Delver's Trophy Chest
    206136,  -- Heroic Dungeon Delver's Trophy Crest
    206271,  -- Malicia's Hoard
    207050,  -- Warmonger's Plate Gear Bag
    207051,  -- Warmonger's Plate Equipment Bag
    207052,  -- Jingoist's Plate Equipment Bag
    207053,  -- Jingoist's Plate Gear Bag
    207063,  -- Jingoist's Mail Equipment Bag
    207064,  -- Jingoist's Mail Gear Bag
    207065,  -- Warmonger's Mail Gear Bag
    207066,  -- Warmonger's Mail Equipment Bag
    207067,  -- Jingoist's Leather Gear Bag
    207068,  -- Jingoist's Leather Equipment Bag
    207069,  -- Warmonger's Leather Equipment Bag
    207070,  -- Warmonger's Leather Gear Bag
    207071,  -- Jingoist's Cloth Gear Bag
    207072,  -- Jingoist's Cloth Equipment Bag
    207073,  -- Warmonger's Cloth Equipment Bag
    207074,  -- Warmonger's Cloth Gear Bag
    207075,  -- Jingoist's Plate Armor Bag
    207076,  -- Warmonger's Plate Armor Bag
    207077,  -- Warmonger's Mail Armor Bag
    207078,  -- Jingoist's Mail Armor Bag
    207079,  -- Warmonger's Leather Armor Bag
    207080,  -- Jingoist's Leather Armor Bag
    207081,  -- Warmonger's Cloth Armor Bag
    207082,  -- Jingoist's Cloth Armor Bag
    207093,  -- Jingoist's Mail Suit Bag
    207094,  -- Warmonger's Leather Suit Bag
    207096,  -- Paracausal Chest
    207582,  -- Box of Tampered Reality
    207583,  -- Box of Collapsed Reality
    207584,  -- Box of Volatile Reality
    207594,  -- Looter's Purse
    208006,  -- Greater Paracausal Chest
    208015,  -- Stuffed Deviate Scale Pouch
    208028,  -- Knot Thimblejack's Cache
    208054,  -- A Mystery Box
    208090,  -- Contained Paracausality
    208091,  -- Cache of Timewarped Treasures
    208094,  -- Cache of Timewarped Treasures
    208095,  -- Cache of Timewarped Treasures
    208142,  -- Buried Satchel
    208211,  -- Anniversary Gift
    208390,  -- Bronze Archive Stone
    208691,  -- Argunite Cluster
    208878,  -- Adventurer's Footlocker
    208951,  -- Paracausal Cluster
    208952,  -- Soridormi's Letter of Commendation
    209024,  -- Loot-Filled Pumpkin
    209026,  -- Loot-Stuffed Pumpkin
    209036,  -- Cache of Amirdrassil Treasures
    209037,  -- Cache of Amirdrassil Treasures
    209831,  -- Wyrm's Bountiful Chest
    209832,  -- Crate of Dreambound Leather
    209835,  -- Crate of Dreambound Plate
    209871,  -- Winter Veil Gift
    210062,  -- Ironbound Satchel of Helpful Goods
    210063,  -- Invader's Satchel of Helpful Goods
    210180,  -- Emerald Flightstone
    210217,  -- Small Dreamy Bounty
    210218,  -- Plump Dreamy Bounty
    210219,  -- Gigantic Dreamy Bounty
    210224,  -- Small Emerald Bloom
    210225,  -- Medium Emerald Bloom
    210226,  -- Large Emerald Bloom
    210549,  -- Dream Racer's Purse
    210657,  -- Gently Shaken Gift
    210726,  -- Ruby Flightstone
    210758,  -- Honorable Satchel of Fabrics
    210759,  -- Honorable Satchel of Ore
    210760,  -- Honorable Satchel of Herbs
    210872,  -- Satchel of Dreams
    210982,  -- Thread of Power
    210983,  -- Thread of Stamina
    210984,  -- Thread of Critical Strike
    210985,  -- Thread of Haste
    210986,  -- Thread of Speed
    210987,  -- Thread of Leech
    210989,  -- Thread of Mastery
    210990,  -- Thread of Versatility
    210991,  -- Small Box of Vials
    210992,  -- Overflowing Dream Warden Trove
    211279,  -- Cache of Infinite Treasure
    211303,  -- Dryad's Supply Pouch
    211373,  -- Bag of Many Wonders
    211388,  -- Timerunner's Starter Kit
    211389,  -- Cache of Overblooming Treasures
    211394,  -- Harvested Dreamseed Cache
    211410,  -- Bloomed Wildling Cache
    211411,  -- Sprouting Dreamtrove
    211413,  -- Budding Dreamtrove
    211414,  -- Blossoming Dreamtrove
    211429,  -- Bundle of Love Tokens
    211430,  -- Bundle of Love Tokens
    212157,  -- An Invitation
    212458,  -- Awakened Flightstone
    212924,  -- Stolen Hearthstone Card
    212979,  -- Hearthstone Starter Pack
    213175,  -- Dusty Djaradin Tome
    213176,  -- Preserved Isles Tome
    213177,  -- Immaculate Tome
    213185,  -- Dusty Centaur Tome
    213186,  -- Dusty Niffen Tome
    213187,  -- Dusty Drakonid Tome
    213188,  -- Dusty Dracthyr Tome
    213189,  -- Preserved Dragonkin Tome
    213190,  -- Preserved Djaradin Tome
    213428,  -- Loot-Stuffed Basket
    213429,  -- Meticulous Archivist's Appendix
    213541,  -- Whelpling's Bountiful Chest
    215160,  -- The Big Dig Rig
    215363,  -- Cache of Embers
    215364,  -- Cache of Dreams
    216638,  -- Timerunner's Intro Kit
    216874,  -- Loot-Filled Basket
    217109,  -- Cache of Awakened Storms
    217110,  -- Cache of Awakened Embers
    217111,  -- Cache of Awakened Dreams
    217242,  -- Awakening Stone Wing
    217243,  -- Awakening Ruby Wing
    217382,  -- Ruby Flightstone
    217411,  -- Blackened Flightstone
    217412,  -- Blackened Flightstone
    217705,  -- Pirate's Booty
    217722,  -- Thread of Experience
    217728,  -- Cache of Awakened Treasures
    217729,  -- Cache of Awakened Treasures
    218130,  -- Adventurer's Footlocker
    219218,  -- Timerunner's Starter Kit
    219219,  -- Timerunner's Starter Kit
    219256,  -- Temporal Thread of Power
    219257,  -- Temporal Thread of Stamina
    219258,  -- Temporal Thread of Critical Strike
    219259,  -- Temporal Thread of Haste
    219260,  -- Temporal Thread of Speed
    219261,  -- Temporal Thread of Leech
    219262,  -- Temporal Thread of Mastery
    219263,  -- Temporal Thread of Versatility
    219264,  -- Temporal Thread of Experience
    219265,  -- Perpetual Thread of Power
    219266,  -- Perpetual Thread of Stamina
    219267,  -- Perpetual Thread of Critical Strike
    219268,  -- Perpetual Thread of Haste
    219269,  -- Perpetual Thread of Speed
    219270,  -- Perpetual Thread of Leech
    219273,  -- Perpetual Thread of Experience
    219274,  -- Infinite Thread of Power
    219275,  -- Infinite Thread of Stamina
    219276,  -- Infinite Thread of Critical Strike
    219277,  -- Infinite Thread of Haste
    219278,  -- Infinite Thread of Speed
    219279,  -- Infinite Thread of Leech
    219280,  -- Infinite Thread of Mastery
    219281,  -- Infinite Thread of Versatility
    219282,  -- Infinite Thread of Experience
    221509,  -- Timerunner's Weaponry
    223904,  -- Asynchronized Cogwheel Gem
    223905,  -- Asynchronized Meta Gem
    223906,  -- Asynchronized Tinker Gem
    223907,  -- Asynchronized Prismatic Gem
    223908,  -- Minor Bronze Cache
    223909,  -- Lesser Bronze Cache
    223910,  -- Bronze Cache
    223911,  -- Greater Bronze Cache
    223953,  -- Timerunner's Parting Pack
    224120,  -- Timerunner's Gem Box
    224296,  -- Basket of Draconic Flowers
    224547,  -- Timewarped Pouch
    226142,  -- Greater Spool of Eternal Thread
    226143,  -- Spool of Eternal Thread
    226144,  -- Lesser Spool of Eternal Thread
    226145,  -- Minor Spool of Eternal Thread
}
for _, id in ipairs(dfIDs) do openables[id] = {} end

openables[190315] = { isRousing = true, threshold = 10 }  -- Rousing Earth
openables[190320] = { isRousing = true, threshold = 10 }  -- Rousing Fire
openables[190322] = { isRousing = true, threshold = 10 }  -- Rousing Order
openables[190326] = { isRousing = true, threshold = 10 }  -- Rousing Air
openables[190328] = { isRousing = true, threshold = 10 }  -- Rousing Frost
openables[190330] = { isRousing = true, threshold = 10 }  -- Rousing Decay
openables[190451] = { isRousing = true, threshold = 10 }  -- Rousing Ire
openables[190954] = { lockbox = true }  -- Serevite Lockbox
openables[191296] = { lockbox = true }  -- Enchanted Lockbox
openables[194037] = { lockbox = true }  -- Heavy Chest
openables[198657] = { lockbox = true }  -- Forgotten Jewelry Box
openables[203743] = { lockbox = true }  -- Jostled Gurubashi Cache
openables[204075] = { threshold = 15 }  -- Whelpling's Shadowflame Crest Fragment
openables[204076] = { threshold = 15 }  -- Drake's Shadowflame Crest Fragment
openables[204077] = { threshold = 15 }  -- Wyrm's Shadowflame Crest Fragment
openables[204078] = { threshold = 15 }  -- Aspect's Shadowflame Crest Fragment
openables[204307] = { lockbox = true }  -- Ornate Bronze Lockbox
openables[204717] = { threshold = 2 }  -- Splintered Spark of Shadowflame
openables[210681] = { mopRemixGem = true, threshold = 3 }  -- Chipped Quick Topaz
openables[210714] = { mopRemixGem = true, threshold = 3 }  -- Chipped Deadly Sapphire
openables[210715] = { mopRemixGem = true, threshold = 3 }  -- Chipped Masterful Amethyst
openables[210716] = { mopRemixGem = true, threshold = 3 }  -- Chipped Swift Opal
openables[210717] = { mopRemixGem = true, threshold = 3 }  -- Chipped Hungering Ruby
openables[210718] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Hungering Ruby
openables[211106] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Masterful Amethyst
openables[211107] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Quick Topaz
openables[211109] = { mopRemixGem = true, threshold = 3 }  -- Chipped Sustaining Emerald
openables[211123] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Deadly Sapphire
openables[211124] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Swift Opal
openables[211125] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Sustaining Emerald
openables[216639] = { mopRemixGem = true, threshold = 3 }  -- Flawed Swift Opal
openables[216640] = { mopRemixGem = true, threshold = 3 }  -- Flawed Masterful Amethyst
openables[216641] = { mopRemixGem = true, threshold = 3 }  -- Flawed Hungering Ruby
openables[216642] = { mopRemixGem = true, threshold = 3 }  -- Flawed Sustaining Emerald
openables[216643] = { mopRemixGem = true, threshold = 3 }  -- Flawed Quick Topaz
openables[216644] = { mopRemixGem = true, threshold = 3 }  -- Flawed Deadly Sapphire
openables[220367] = { mopRemixGem = true, threshold = 3 }  -- Chipped Stalwart Pearl
openables[220368] = { mopRemixGem = true, threshold = 3 }  -- Flawed Stalwart Pearl
openables[220370] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Stalwart Pearl
openables[220371] = { mopRemixGem = true, threshold = 3 }  -- Chipped Versatile Diamond
openables[220372] = { mopRemixGem = true, threshold = 3 }  -- Flawed Versatile Diamond
openables[220374] = { mopRemixGem = true, mopRemixEpicGem = true, threshold = 3 }  -- Versatile Diamond
