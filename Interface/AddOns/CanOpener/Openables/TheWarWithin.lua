local _, CanOpenerGlobal = ...
local openables = CanOpenerGlobal.openables

local twwIDs = {
    213779,  -- Algari Amber Prism
    213780,  -- Algari Amber Prism
    213781,  -- Algari Amber Prism
    213782,  -- Algari Emerald Prism
    213783,  -- Algari Emerald Prism
    213784,  -- Algari Emerald Prism
    213785,  -- Algari Ruby Prism
    213786,  -- Algari Ruby Prism
    213787,  -- Algari Ruby Prism
    213788,  -- Algari Onyx Prism
    213789,  -- Algari Onyx Prism
    213790,  -- Algari Onyx Prism
    213791,  -- Algari Sapphire Prism
    213792,  -- Algari Sapphire Prism
    213793,  -- Algari Sapphire Prism
    217011,  -- Amateur Actor's Chest
    217012,  -- Novice Actor's Chest
    217013,  -- Expert Actor's Chest
    218309,  -- Gently Shaken Gift
    218311,  -- Winter Veil Gift
    218738,  -- Bizarrely Shaped Stomach
    219192,  -- Comprehensibly Organized Ideas
    220148,  -- Pale Huskfish
    220767,  -- Triumphant Satchel of Carved Harbinger Crests
    220773,  -- Celebratory Pack of Runed Harbinger Crests
    220776,  -- Glorious Cluster of Gilded Harbinger Crests
    221268,  -- Pouch of Weathered Harbinger Crests
    221269,  -- Crimson Valorstone
    221373,  -- Satchel of Carved Harbinger Crests
    221375,  -- Pack of Runed Harbinger Crests
    221502,  -- Adventurer's Warbound Battlegear Drop
    221503,  -- Explorer's Warbound Battlegear Drop
    222977,  -- Scorched Junk
    223619,  -- Bronze Celebration Goodie Bag
    223620,  -- 20th Anniversary Cache
    223621,  -- 20th Anniversary Cache
    223622,  -- 20th Anniversary Cache
    224007,  -- Uses for Leftover Husks (How to Take Them Apart)
    224023,  -- Herbal Embalming Techniques
    224024,  -- Theories of Bodily Transmutation, Chapter 8
    224027,  -- Bottomless Bag of Khaz Algar Herbs
    224028,  -- Bottomless Bag of Khaz Algar Ore
    224029,  -- Bottomless Bag of Khaz Algar Skins
    224030,  -- Bottomless Bag of Khaz Algar Alchemy Goods
    224031,  -- Bottomless Bag of Khaz Algar Blacksmithing Goods
    224032,  -- Bottomless Bag of Khaz Algar Enchanting Goods
    224033,  -- Bottomless Bag of Khaz Algar Engineering Goods
    224034,  -- Bottomless Bag of Khaz Algar Inscription Goods
    224035,  -- Bottomless Bag of Khaz Algar Jewelcrafting Goods
    224036,  -- And That's A Web-Wrap!
    224037,  -- Bottomless Bag of Khaz Algar Leatherworking Goods
    224038,  -- Smithing After Saronite
    224039,  -- Bottomless Bag of Khaz Algar Tailoring Goods
    224040,  -- Bottomless Bag of Khaz Algar Optional Goods
    224050,  -- Web Sparkles: Pretty and Powerful
    224052,  -- Clocks, Gears, Sprockets, and Legs
    224053,  -- Eight Views on Defense against Hostile Runes
    224054,  -- Emergent Crystals of the Surface-Dwellers
    224055,  -- A Rocky Start
    224056,  -- Uses for Leftover Husks (After You Take Them Apart)
    224100,  -- Bottomless Bag of Khaz Algar General Goods
    224156,  -- Bottomless Bag of Khaz Algar General Goods
    224264,  -- Deepgrove Petal
    224265,  -- Deepgrove Rose
    224556,  -- Glorious Contender's Strongbox
    224557,  -- Field Medic's Hazard Payout
    224573,  -- Crystal Satchel of Cooperation
    224583,  -- Slab of Slate
    224584,  -- Erosion-Polished Slate
    224586,  -- Box o' Booms
    224587,  -- Box o' Booms
    224588,  -- Box o' Booms
    224645,  -- Jewel-Etched Alchemy Notes
    224647,  -- Jewel-Etched Blacksmithing Notes
    224648,  -- Jewel-Etched Tailoring Notes
    224650,  -- Wax-Sealed Pouch
    224651,  -- Machine-Learned Mining Notes
    224652,  -- Jewel-Etched Enchanting Notes
    224653,  -- Machine-Learned Engineering Notes
    224654,  -- Machine-Learned Inscription Notes
    224655,  -- Void-Lit Jewelcrafting Notes
    224656,  -- Void-Lit Herbalism Notes
    224657,  -- Void-Lit Skinning Notes
    224658,  -- Void-Lit Leatherworking Notes
    224721,  -- Wax-Sealed Box
    224722,  -- Waxy Bundle of Resonance Crystals
    224723,  -- Waxy Bundle of Leather
    224724,  -- Waxy Bundle of Dust
    224725,  -- Waxy Bundle of Herbs
    224726,  -- Waxy Box of Rocks
    224780,  -- Toughened Tempest Pelt
    224784,  -- Pinnacle Cache
    224807,  -- Algari Skinner's Notes
    224817,  -- Algari Herbalist's Notes
    224818,  -- Algari Miner's Notes
    224835,  -- Deepgrove Roots
    224838,  -- Null Sliver
    224913,  -- Radiant Fuel Cache
    224941,  -- Radiant Fuel Cache
    225220,  -- Chitin Needle
    225221,  -- Spool of Webweave
    225222,  -- Stone-Leather Swatch
    225223,  -- Sturdy Nerubian Carapace
    225224,  -- Diaphanous Gem Shards
    225225,  -- Deepstone Fragment
    225226,  -- Striated Inkstone
    225227,  -- Wax-Sealed Records
    225228,  -- Rust-Locked Mechanism
    225229,  -- Earthen Induction Coil
    225230,  -- Crystalline Repository
    225231,  -- Powdered Fulgurance
    225232,  -- Coreway Billet
    225233,  -- Dense Bladestone
    225234,  -- Alchemical Sediment
    225235,  -- Deepstone Crucible
    225239,  -- Overflowing Council of Dornogal Trove
    225245,  -- Overflowing Trove of the Deeps
    225246,  -- Overflowing Hallowfall Trove
    225247,  -- Overflowing Severed Threads Trove
    225249,  -- Rattling Bag o' Gold
    225571,  -- The Weaver's Gratuity
    225572,  -- The General's War Chest
    225573,  -- The Vizier's Capital
    225896,  -- Void-Touched Valorstone
    226045,  -- The General's Trove
    226100,  -- The Vizier's Trove
    226101,  -- Chromie's Tour Goodie Bag
    226102,  -- Chromie's Tour Goodie Bag
    226103,  -- The Weaver's Trove
    226146,  -- Handful of Humming Shinies
    226147,  -- Bunch of Brave Rocks
    226148,  -- Wax-Sealed Weathered Crests
    226149,  -- Pile of Humming Shinies
    226150,  -- Gem-Studded Candelabra
    226151,  -- Wax-Coated Coffer Unlocker
    226152,  -- Wax-sealed Crests
    226153,  -- Big Pile of Humming Shinies
    226154,  -- Wax-Sealed Crafty Crest
    226193,  -- Cache of Nerubian Treasures
    226194,  -- Cache of Nerubian Treasures
    226195,  -- Resonance Crystal Cluster
    226196,  -- Silk Kej Pouch
    226198,  -- Resonance Crystal Agglomeration
    226199,  -- Silk Kej Purse
    226256,  -- Token of the Remembrancers
    226257,  -- Delver's Pouch of Valorstones
    226263,  -- Theater Troupe's Trove
    226264,  -- Radiant Cache
    226265,  -- Earthen Iron Powder
    226268,  -- Engraved Stirring Rod
    226269,  -- Chemist's Purified Water
    226270,  -- Sanctified Mortar and Pestle
    226271,  -- Nerubian Mixing Salts
    226272,  -- Dark Apothecary's Vial
    226273,  -- Awakened Mechanical Cache
    226276,  -- Ancient Earthen Anvil
    226277,  -- Dornogal Hammer
    226278,  -- Ringing Hammer Vise
    226279,  -- Earthen Chisels
    226280,  -- Holy Flame Forge
    226281,  -- Radiant Tongs
    226282,  -- Nerubian Smith's Kit
    226283,  -- Spiderling's Wire Brush
    226284,  -- Grinded Earthen Gem
    226285,  -- Silver Dornogal Rod
    226286,  -- Soot-Coated Orb
    226287,  -- Animated Enchanting Dust
    226288,  -- Essence of Holy Fire
    226289,  -- Enchanted Arathi Scroll
    226290,  -- Book of Dark Magic
    226291,  -- Void Shard
    226292,  -- Rock Engineer's Wrench
    226293,  -- Dornogal Spectacles
    226294,  -- Inert Mining Bomb
    226295,  -- Earthen Construct Blueprints
    226296,  -- Holy Firework Dud
    226297,  -- Arathi Safety Gloves
    226298,  -- Puppeted Mechanical Spider
    226299,  -- Emptied Venom Canister
    226300,  -- Ancient Flower
    226301,  -- Dornogal Gardening Scythe
    226302,  -- Earthen Digging Fork
    226303,  -- Fungarian Slicer's Knife
    226304,  -- Arathi Garden Trowel
    226305,  -- Arathi Herb Pruner
    226306,  -- Web-Entangled Lotus
    226307,  -- Tunneler's Shovel
    226308,  -- Dornogal Scribe's Quill
    226309,  -- Historian's Dip Pen
    226310,  -- Runic Scroll
    226311,  -- Blue Earthen Pigment
    226312,  -- Informant's Fountain Pen
    226313,  -- Calligrapher's Chiseled Marker
    226314,  -- Nerubian Texts
    226315,  -- Venomancer's Ink Well
    226316,  -- Gentle Jewel Hammer
    226317,  -- Earthen Gem Pliers
    226318,  -- Carved Stone File
    226319,  -- Jeweler's Delicate Drill
    226320,  -- Arathi Sizing Gauges
    226321,  -- Librarian's Magnifiers
    226322,  -- Ritual Caster's Crystal
    226323,  -- Nerubian Bench Blocks
    226324,  -- Earthen Lacing Tools
    226325,  -- Dornogal Craftsman's Flat Knife
    226326,  -- Underground Stropping Compound
    226327,  -- Earthen Awl
    226328,  -- Arathi Beveler Set
    226329,  -- Arathi Leather Burnisher
    226330,  -- Nerubian Tanning Mallet
    226331,  -- Curved Nerubian Skinning Knife
    226332,  -- Earthen Miner's Gavel
    226333,  -- Dornogal Chisel
    226334,  -- Earthen Excavator's Shovel
    226335,  -- Regenerating Ore
    226336,  -- Arathi Precision Drill
    226337,  -- Devout Archaeologist's Excavator
    226338,  -- Heavy Spider Crusher
    226339,  -- Nerubian Mining Supplies
    226340,  -- Dornogal Carving Knife
    226341,  -- Earthen Worker's Beams
    226342,  -- Artisan's Drawing Knife
    226343,  -- Fungarian's Rich Tannin
    226344,  -- Arathi Tanning Agent
    226345,  -- Arathi Craftsman's Spokeshave
    226346,  -- Nerubian's Slicking Iron
    226347,  -- Carapace Shiner
    226348,  -- Dornogal Seam Ripper
    226349,  -- Earthen Tape Measure
    226350,  -- Runed Earthen Pins
    226351,  -- Earthen Stitcher's Snips
    226352,  -- Arathi Rotary Cutter
    226353,  -- Royal Outfitter's Protractor
    226354,  -- Nerubian Quilt
    226355,  -- Nerubian's Pincushion
    226813,  -- Golden Valorstone
    226814,  -- Chest of Gold
    227407,  -- Faded Blacksmith's Diagrams
    227408,  -- Faded Scribe's Runic Drawings
    227409,  -- Faded Alchemist's Research
    227410,  -- Faded Tailor's Diagrams
    227411,  -- Faded Enchanter's Research
    227414,  -- Faded Leatherworker's Diagrams
    227415,  -- Faded Herbalist's Notes
    227416,  -- Faded Miner's Notes
    227417,  -- Faded Skinner's Notes
    227418,  -- Exceptional Blacksmith's Diagrams
    227419,  -- Exceptional Scribe's Runic Drawings
    227420,  -- Exceptional Alchemist's Research
    227421,  -- Exceptional Tailor's Diagrams
    227422,  -- Exceptional Enchanter's Research
    227423,  -- Exceptional Engineer's Scribblings
    227424,  -- Exceptional Jeweler's Illustrations
    227425,  -- Exceptional Leatherworker's Diagrams
    227426,  -- Exceptional Herbalist's Notes
    227427,  -- Exceptional Miner's Notes
    227428,  -- Exceptional Skinner's Notes
    227429,  -- Pristine Blacksmith's Diagrams
    227430,  -- Pristine Scribe's Runic Drawings
    227431,  -- Pristine Alchemist's Research
    227432,  -- Pristine Tailor's Diagrams
    227433,  -- Pristine Enchanter's Research
    227434,  -- Pristine Engineer's Scribblings
    227435,  -- Pristine Jeweler's Illustrations
    227436,  -- Pristine Leatherworker's Diagrams
    227437,  -- Pristine Herbalist's Notes
    227438,  -- Pristine Miner's Notes
    227439,  -- Pristine Skinner's Notes
    227450,  -- Sky Racer's Purse
    227659,  -- Fleeting Arcane Manifestation
    227661,  -- Gleaming Telluric Crystal
    227662,  -- Shimmering Dust
    227667,  -- Algari Enchanter's Folio
    227668,  -- Delver's Bounty
    227675,  -- Satchel of Surplus Herbs
    227676,  -- Satchel of Surplus Ore
    227677,  -- zzOld Do Not Use (DNT)
    227678,  -- zzOld Do Not Use (DNT)
    227679,  -- zzOld Do Not Use (DNT)
    227680,  -- zzOld Do Not Use (DNT)
    227681,  -- Satchel of Surplus Leather
    227682,  -- Satchel of Surplus Cloth
    227713,  -- Artisan's Consortium Payout
    227778,  -- Delver's Bounty
    227779,  -- Delver's Bounty
    227780,  -- Delver's Bounty
    227781,  -- Delver's Bounty
    227782,  -- Delver's Bounty
    227783,  -- Delver's Bounty
    227784,  -- Delver's Bounty
    227792,  -- Everyday Cache
    228220,  -- Waxy Bundle
    228337,  -- Satchel of Surplus Dust
    228361,  -- Seasoned Adventurer's Cache
    228724,  -- Flicker of Alchemy Knowledge
    228725,  -- Glimmer of Alchemy Knowledge
    228726,  -- Flicker of Blacksmithing Knowledge
    228727,  -- Glimmer of Blacksmithing Knowledge
    228728,  -- Flicker of Enchanting Knowledge
    228729,  -- Glimmer of Enchanting Knowledge
    228730,  -- Flicker of Engineering Knowledge
    228731,  -- Glimmer of Engineering Knowledge
    228732,  -- Flicker of Inscription Knowledge
    228733,  -- Glimmer of Inscription Knowledge
    228734,  -- Flicker of Jewelcrafting Knowledge
    228735,  -- Glimmer of Jewelcrafting Knowledge
    228736,  -- Flicker of Leatherworking Knowledge
    228737,  -- Glimmer of Leatherworking Knowledge
    228738,  -- Flicker of Tailoring Knowledge
    228739,  -- Glimmer of Tailoring Knowledge
    228741,  -- Lamplighter Supply Satchel
    228773,  -- Algari Alchemist's Notebook
    228774,  -- Algari Blacksmith's Journal
    228775,  -- Algari Engineer's Notepad
    228776,  -- Algari Scribe's Journal
    228777,  -- Algari Jewelcrafter's Notebook
    228778,  -- Algari Leatherworker's Journal
    228779,  -- Algari Tailor's Notebook
    228910,  -- Cache of Nerubian Treasures
    228916,  -- Algari Tailor's Satchel
    228917,  -- Satchel of Ore
    228918,  -- Satchel of Leather
    228919,  -- Satchel of Algari Herbs
    228920,  -- Satchel of Chitin
    228931,  -- Algari Enchanter's Satchel
    228932,  -- Algari Engineer's Satchel
    228933,  -- Algari Leatherworker's Satchel
    228959,  -- Pile of Unidentified Meat
    229005,  -- Cache of Earthen Treasures
    229006,  -- Cache of Earthen Treasures
    229129,  -- Cache of Delver's Spoils
    229130,  -- Cache of Delver's Spoils
    229354,  -- Algari Adventurer's Cache
    229355,  -- Chromie's Premium Goodie Bag
    229359,  -- Chromie's Goodie Bag
    230032,  -- Overflowing K'aresh Trust Trove
    231153,  -- Triumphant Satchel of Carved Undermine Crests
    231154,  -- Celebratory Pack of Runed Undermine Crests
    231264,  -- Glorious Cluster of Gilded Undermine Crests
    231267,  -- Pouch of Weathered Undermine Crests
    231269,  -- Satchel of Carved Undermine Crests
    231270,  -- Pack of Runed Undermine Crests
    232076,  -- Adventurer's Warbound Battlegear Drop
    232372,  -- Crate of Bygone Riches
    232382,  -- Golden Valorstone
    232463,  -- Overflowing Undermine Trove
    232465,  -- Darkfuse Trove
    232471,  -- Cache of Dark Iron Treasures
    232472,  -- Cache of Dark Iron Treasures
    232473,  -- Cache of Dark Iron Treasures
    232598,  -- Bag of Timewarped Badges
    232602,  -- Forged Gladiator's Coin Pouch
    232615,  -- Prized Gladiator's Coin Pouch
    232616,  -- Astral Gladiator's Coin Pouch
    232631,  -- Wrapped Spear
    232877,  -- Timely Goodie Bag
    232927,  -- [DNT] Small Surge Chest
    232928,  -- [DNT] Medium Surge Chest
    232929,  -- [DNT] Large Surge Chest
    233014,  -- Bronze Celebration Cache of Treasures
    233276,  -- Delver's Starter Kit
    233281,  -- Delver's Cosmetic Surprise Bag
    233557,  -- Sifted Pile of Scrap
    233558,  -- S.C.R.A.P. Scrubber Deluxe
    234413,  -- Satchel of Exotic Mysteries
    234425,  -- Forgotten Folio
    234744,  -- Blackwater's Trove
    234745,  -- Bilgewater's Trove
    234746,  -- Venture Co.'s Trove
    234816,  -- Overflowing Bag of Iron
    235052,  -- Weathered Mysterious Satchel
    235054,  -- Pristine Mysterious Satchel
    235151,  -- Distinguished Actor's Chest
    235258,  -- Bilgewater's Trove
    235259,  -- Bilgewater's Trove
    235260,  -- Blackwater's Trove
    235261,  -- Blackwater's Trove
    235262,  -- Steamwheedle's Trove
    235263,  -- Steamwheedle's Trove
    235264,  -- Venture Co.'s Trove
    235265,  -- Venture Co.'s Trove
    235505,  -- Satchel of Timewarped Badges
    235506,  -- Box of Timewarped Badges
    235548,  -- Earthen Landlubber's Cache
    235558,  -- Box of Darkfuse Miscellany
    235610,  -- Seasoned Adventurer's Cache
    235631,  -- [NOT USED] Mysterious Large Satchel of Goodies
    235639,  -- Seasoned Adventurer's Cache
    235911,  -- Weathered Mysterious Satchel
    236632,  -- Pouch of Voidbane Gems
    236756,  -- Socially Expected Tip Chest
    236757,  -- Generous Tip Chest
    236758,  -- Extravagant Tip Chest
    236877,  -- Crystallized Essence of Kaja'mite
    236944,  -- Weathered Mysterious Satchel
    236953,  -- Crimson Valorstone
    236954,  -- Void-Touched Valorstone
    237134,  -- Steamwheedle Trove
    237135,  -- Blackwater Trove
    237743,  -- Arathi Soldier's Coffer
    237759,  -- Arathi Cleric's Chest
    237760,  -- Arathi Champion's Spoils
    237812,  -- Cache of Infinite Treasure
    238207,  -- Nanny's Surge Dividends
    238208,  -- Nanny's Surge Dividends
    239004,  -- Radiant Service Satchel
    239118,  -- Pinnacle Cache
    239120,  -- Seasoned Adventurer's Cache
    239121,  -- Awakened Mechanical Cache
    239122,  -- The General's War Chest
    239124,  -- The Vizier's Capital
    239125,  -- The Weaver's Gratuity
    239126,  -- Radiant Cache
    239128,  -- Theater Troupe's Trove
    239224,  -- Cache of Infinite Treasure
    239303,  -- Cache of Infinite Treasure
    239440,  -- Dastardly Prize Purse
    239489,  -- Radiant Officer's Cache
    239546,  -- Confiscated Cultist's Bag
    239594,  -- Crimson Valorstone
    240175,  -- Crystallized Ethereal Voidsplinter
    240207,  -- Golden Valorstone
    240208,  -- Void-Touched Valorstone
    240926,  -- Pack of Runed Ethereal Crests
    240927,  -- Satchel of Carved Ethereal Crests
    240928,  -- Pouch of Weathered Ethereal Crests
    240929,  -- Glorious Cluster of Gilded Ethereal Crests
    240930,  -- Celebratory Pack of Runed Ethereal Crests
    240931,  -- Triumphant Satchel of Carved Ethereal Crests
    242386,  -- Lorewalker's Crate of Memorabilia
    243235,  -- Adventurer's Footlocker
    243291,  -- Bag of Brewfest Merchandise
    243292,  -- Bag of Brewfest Merchandise
    243293,  -- Bag of Brewfest Merchandise
    243347,  -- Keg of Curiosities
    243373,  -- Timerunner's Weaponry
    244335,  -- K'aresh Box of Valorstones
    244336,  -- K'aresh Box of Resonance Crystals
    244457,  -- Keystone Container
    244466,  -- Dagran's Pouch of Shards
    244696,  -- Overcharged Chest
    244842,  -- Fabled Veteran's Cache
    244865,  -- Pinnacle Cache
    244883,  -- Seasoned Undermine Adventurer's Cache
    245280,  -- Seasoned Khaz Algar Adventurer's Cache
    245553,  -- Heroic Cache of Infinite Treasure
    245589,  -- Hellcaller Chest
    245611,  -- Wriggling Pinnacle Cache
    245925,  -- Artifactium Sand
    246697,  -- Self-Assembling Homeware Kit
    246812,  -- Minor Bronze Cache
    246813,  -- Greater Bronze Cache
    246814,  -- Bronze Cache
    246815,  -- Lesser Bronze Cache
    246936,  -- Resonant Epoch Memento
    246937,  -- Perfected Epoch Memento
    247820,  -- Cache of K'areshi Treasures
    247821,  -- Cache of K'areshi Treasures
    248126,  -- Delver's Starter Kit
    248127,  -- Delver's Cosmetic Surprise Bag
    248247,  -- Cache of Infinite Power
    249891,  -- Mound of Artifactium Sand
    250763,  -- Theater Troupe's Trove
    250764,  -- Nanny's Surge Dividends
    250765,  -- Awakened Mechanical Cache
    250766,  -- Radiant Cache
    250767,  -- The General's War Chest
    250768,  -- The Vizier's Capital
    250769,  -- The Weaver's Gratuity
    250975,  -- Hellcaller Chest
    251821,  -- Cache of Infinite Power
    253357,  -- Felscorned Arsenal
    254847,  -- Minor Bronze Cache
    254848,  -- Minor Bronze Cache
    254849,  -- Minor Bronze Cache
    254850,  -- Minor Bronze Cache
    255676,  -- Phase Diver's Cache
    256763,  -- Cache from the Infinite's Armory
    264675,  -- Cache from the Infinite's Armory
}
for _, id in ipairs(twwIDs) do openables[id] = {} end

openables[220376] = { lockbox = true }  -- Bismuth Lockbox
openables[253224] = { threshold = 10 }  -- Mote of a Broken Time
openables[253227] = { threshold = 10 }  -- Flawless Thread of Time
openables[254267] = { threshold = 100 }  -- Fragmented Memento of Epoch Challenges
