local addonName, ns = ...

-- All 31 secrets required for Mind-Seeker Feat of Strength (achievement 62189)
-- Detection types: mount, pet, toy, quest, transmog, achievement
ns.secrets = {
    -- MOUNTS (17)
    {
        name = "Long-Forgotten Hippogryph",
        hint = "Find 5 Ephemeral Crystals in Azsuna scattered around the area.",
        type = "mount",
        id = 802,
        waypoint = { 630, 54.0, 33.0 }, -- Azsuna
        record = "Record of Ephemeral Crystals",
    },
    {
        name = "Fathom Dweller",
        hint = "Go to the Broken Shore and speak with Drak'thul",
        type = "mount",
        id = 838,
        waypoint = { 646, 37.2, 71.8 }, -- Eye of Azshara
        record = "Record of Drak'thul's Madness",
    },
    {
        name = "Riddler's Mind-Worm",
        hint = "For this secret, you will have to locate hidden pages scattered across Azeroth.",
        type = "mount",
        id = 947,
        waypoint = { 627, 14.0, 29.6 }, -- Dalaran (Broken Isles)
        record = "Record of the Riddler",
    },
    {
        name = "Lucid Nightmare",
        hint = "The Mind-Seekers seem to have a penchant for leaving their notes in obvious places. Look around in Curiosities & Moore in Dalaran.",
        type = "mount",
        id = 961,
        waypoint = { 627, 48.37, 57.53 }, 
        record = "Record of the Endless Nightmare",
    },
    {
        name = "The Hivemind",
        hint = "To start the secret you will first have to purchase Talisman of True Treasure Tracking from Griftah in Shattrath.",
        type = "mount",
        id = 1025,
        waypoint = { 111, 65.0, 69.0 },
        record = "Record of the Hivemind",
    },
    {
        name = "Nazjatar Blood Serpent",
        hint = "Combine Crystals at the Altar of the Abyss",
        type = "mount",
        id = 1057,
        waypoint = { 863, 46.6, 36.2 }, -- Stormsong Valley
        record = "Record of Abyssal Blood",
    },
    {
        name = "Crimson Tidestallion",
        hint = "Unlock Mrrl and get access to his Secret Stash",
        type = "mount",
        id = 1260,
        waypoint = { 1355, 48.0, 45.0 }, -- Nazjatar
        record = "Record of a Grggly Stash",
    },
    {
        name = "Sinrunner Blanchy",
        hint = "6-day quest chain in Revendreth",
        type = "mount",
        id = 1414,
        waypoint = { 1525, 63.13, 43.11 }, -- Revendreth 
        record = "Record of a Bad Horse",
    },
    {
        name = "Bound Shadehound",
        hint = "Hunting in the Maw",
        type = "mount",
        id = 1441,
        waypoint = { 1543, 24.0, 75.5}, -- The Maw
        record = "Record of Taming the Maw",
    },
    {
        name = "Slime Serpent",
        hint = "All the way to the end of Plaguefall, then turn around and look behind you",
        type = "mount",
        id = 1445,
        waypoint = { 1536, 59.30, 64.84 }, -- Plaguefall
        record = "Record of the Secrets Behind You",
    },
    {
        name = "Xy Trustee's Gearglider",
        hint = "Manaforge Vandals rank 8, then see about deals",
        type = "mount",
        id = 1482,
        waypoint = { 2371, 42.0, 22.2 },
        record = "Record of Cartel Cyphers",
    },
    {
        name = "Hand of Nilganihmaht",
        hint = "Gotta Hand It To Ya, Collect 5 ring pieces across Shadowlands",
        type = "mount",
        id = 1503,
        waypoint = { 1543, 25.7, 32.5 }, -- The Maw
        record = "Record of a Dominant Hand",
    },
    {
        name = "Otto",
        hint = "The Way to an Otto's Heart - The Great Swog has something you'll need.",
        type = "mount",
        id = 1656,
        waypoint = { 2023, 82.2, 73.2 }, -- Azure Span
        record = "Record of a Slippery Find",
    },
    {
        name = "Mimiron's Jumpjets",
        hint = "To forge Mimiron's Jumpjets you have to find 3 booster parts and then combine them.",
        type = "mount",
        id = 1813,
        waypoint = { 120, 59.4, 79.0 }, -- The Storm Peaks
        record = "Record of Mimiron's Master Mind",
    },
    {
        name = "Incognitro",
        hint = "Select the Detective title and speak with the Dalaran Survivor in Dornogal",
        type = "mount",
        id = 1943,
        waypoint = { 2339, 55.0, 29.0 }, -- Isle of Dorn
        record = "Record of Indecipherable Mo'arg Technology",
    },
    {
        name = "Voidfire Deathcycle",
        hint = "Equip one Faceless Mask and enter the Horrific Vision of Stormwind.",
        type = "mount",
        id = 1948,
        waypoint = { 2339, 34.77, 68.51 }, -- Isle of Dorn
        record = "Record of Visions of Void",
    },
    {
        name = "Thrayir, Eyes of the Siren",
        hint = "hrayir resides in The Forgotten Vault, which you can access by interacting with the Singing Tablet on the Siren Isle.",
        type = "mount",
        id = 2322,
        waypoint = { 2375, 72.7, 61.4 }, -- Isle of Dorn
        record = "Record of the Siren's Song",
    },

    -- PETS (9)
    {
        name = "Uuna",
        hint = "For this secret the reward is hugs, and the gratitude of a little girl. Get the doll from The Many-Faced Devourer",
        type = "pet",
        id = 2136,
        waypoint = { 885, 54.8, 39.0  }, -- Antoran Wastes
        record = "Record of a Friend in the Darkness",
    },
    {
        name = "Baa'l",
        hint = "Be done with Uuna and the find conspicuous note and dark pebbles across Azeroth",
        type = "pet",
        id = 2352,
        waypoint = { 863, 51.8, 59.1}, -- Nazmir
        record = "Record of Ominously Ordinary Pebbles",
    },
    {
        name = "Wicker Pup",
        hint = "Drustvar ritual collectibles - created by combining several items",
        type = "pet",
        id = 2411,
        waypoint = { 896, 18.5, 51.3 }, -- Drustvar
        record = "Record of Drust Rituals",
    },
    {
        name = "Jenafur",
        hint = "Locate Amara Lunastar",
        type = "pet",
        id = 2795,
        waypoint = { 62, 17.4, 49.3 }, 
        record = "Record of Karazhan's Kitten",
    },
    {
        name = "Glimr",
        hint = "Glimr is a secret purple murloc battle pet obtained from Glimrs Cracked Egg.",
        type = "pet",
        id = 2888,
        waypoint = { 116, 18.4, 88.2 },
        record = "Record of Glimmering Hope",
    },
    {
        name = "Courage",
        hint = "Head to Nemea's Retreat and look for cubs",
        type = "pet",
        id = 3065,
        waypoint = { 1533, 56.91, 39.05  }, -- The Maw
        record = "Record of Collectible Courage",
    },
    {
        name = "Phoenix Wishwing",
        hint = "A hidden quest offered by Tarjin the Blind",
        type = "pet",
        id = 3292,
        waypoint = { 2022, 16.2, 62.4 }, -- Azure Span
        record = "Record of Rising Ashes",
    },
    {
        name = "Tobias",
        hint = "Secrets of Azeroth / Community Rumor Mill",
        type = "pet",
        id = 4263,
        waypoint = {  }, -- Stormwind
        record = "Record of Rumors",
    },
    {
        name = "Sun Darter Hatchling",
        hint = "Hidden within the Caverns of Consumption",
        type = "pet",
        id = 382,
        waypoint = { 83, 57.2, 13.9 }, -- Winterspring
        record = "Record of the Caverns of Consumption",
    },

    -- TOYS (2)
    {
        name = "Lost Obsidian Cache",
        hint = "Secret treasure found in the Waking Shores on the Dragon Isles, Starts with apples...",
        type = "toy",
        id = 201933,
        waypoint = { 2022, 43.7, 71.7 }, -- Waking Shores
        record = "Record of Lost Obsidian Treasures",
    },
    {
        name = "Enlightened Hearthstone",
        hint = "The Ponderer's Portal has opened. - 6 player co-op puzzle in Zereth Mortis",
        type = "toy",
        id = 190196,
        waypoint = { 1970, 47.54, 50.05}, -- Zereth Mortis
        record = "Record of Collaborative Cogitation",
    },

    -- TRANSMOG (1)
    {
        name = "Waist of Time",
        hint = "Must have Baal and Uuna, then you will have to interact with hidden objects scattered across Azeroth, Outland and Draenor.",
        type = "transmog",
        id = 162690,
        waypoint = { 542, 35.5, 32.0 }, -- 
        record = "Record of Time Wasted",
    },

    -- QUEST (1)
    {
        name = "Wan'be's Buried Goods",
        hint = "Horde only treasure hunt.  Talk to Hoarder Jena in Voldun and get the ghostly explorer's skull.",
        type = "quest",
        id = 53657,
        waypoint = { 864, 56.6, 49.8}, 
        record = "Record of Buried Treasure",
    },

    -- ACHIEVEMENT (1)
    {
        name = "Memory of Scholomance",
        hint = "Defeat Scholomance bosses with Krastinovs Bag, then find Evas journal",
        type = "achievement",
        id = 18368,
        waypoint = { 22, 70.0, 75.0 }, -- Western Plaguelands
        record = "Record of Necromantic Knowledge",
    },
}
