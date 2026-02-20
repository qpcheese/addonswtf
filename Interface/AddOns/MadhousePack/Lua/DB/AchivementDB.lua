Madhouse.db.achivement = {
    cat = {
        [1] = { n = "Raid & M+ (S3)", i = 5779391 },
        [2] = { n = "PvP (S3)", i = isHorde and 236629 or 236593 },
        [3] = { n = isGerman and "Tiefen" or "Delve", i = 6025441 },
        [4] = { n = isGerman and "Events" or "Events", i = 5010359 },
        [5] = { n = isGerman and "Meta Erfolg" or "Meta Achiev", i = 6029029 },
        [6] = { n = isGerman and "Sonstige" or "Other", i = 1002574 },
        [7] = { n = isGerman and "Reittiere" or "Mounts", i = 413588 },
        [8] = { n = "Midnight: Pre Patch", i = 135777 }
    },
    element = {
        --------------PvE-------------
        { a = 41937, c = 1 },              -- Season Default
        { a = 42170, c = 1 },              -- 1.5k Rating M+
        { a = 41973, c = 1 },              -- 2k Rating M+
        { a = 42171, c = 1 },              -- 2.5k Rating M+
        { a = 42172, c = 1 },              -- 3k Rating M+
        { a = 40139, c = 1 },              -- DD All
        { a = 40140, c = 1 },              -- Heal All
        { a = 40141, c = 1 },              -- Tank All
        { a = 42325, c = 1 },              -- Season Master m+ raid pvp
        { a = 41886, c = 1 },              -- Verwitterte Wappen 681
        { a = 41887, c = 1 },              -- Geschnitzte Wappen 691
        { a = 41888, c = 1 },              -- Runenverzierte Wappen 704
        { a = 41892, c = 1 },              -- Geschnitzte Wappen 720
        --------------PvP-------------
        { a = 41048, c = 2 },              -- PvP Waffen - S3
        { a = 40085, c = 2, l = "c2215" }, -- WM Heisturz
        { a = 40086, c = 2, l = "c2255" }, -- WM AzjKahed
        { a = 40084, c = 2, l = "c2214" }, -- WM Tiefen
        { a = 40083, c = 2, l = "c2248" }, -- WM Insel
        { a = 40088, c = 2 },              -- WM World Quests
        { a = 40096, c = 2 },              -- WM Quests
        { a = 40097, c = 2 },              -- WM Full + Mount
        --------------DELVE-------------
        -- Global
        { a = 40506, c = 3 }, -- Delve alle kisten
        { a = 40449, c = 3 }, -- Erforschung der Tiefen IV
        { a = 40098, c = 3 }, -- Unsterblicher Höhlenforscher
        { a = 40537, c = 3 }, -- Alle Geschichten
        { a = 40438, c = 3 },
        { a = 40537, c = 5 }, -- Meister der Lehren
        --------------Events-------------
        { a=61394, c=4 }, -- Turbulente Zeitwege
        --------- META  -------------
        { a = 61451, c = 5 },              -- Meta Achivement
        --------- OTHER -------------
        { a = 40939, c = 6 },              -- Max Gear
        { a = 40723, c = 6 },              -- 2.5k Ach
        { a = 40147, c = 6 },              -- TWW Epic
        { a = 41162, c = 6, l = "c2248" }, -- Max Rep Insel
        { a = 41166, c = 6, l = "c2214" }, -- Max Rep Tiefen
        { a = 41168, c = 6, l = "c2215" }, -- Max Rep Arathi
        { a = 41164, c = 6, l = "c2255" }, -- Max Rep Fäden
        { a = 40874, c = 6, l = "c2255" }, -- Max Rep Fäden - Weber
        { a = 40875, c = 6, l = "c2255" }, -- Max Rep Fäden - General
        { a = 40876, c = 6, l = "c2255" }, -- Max Rep Fäden - Wesir
        { a = 42187, c = 6 },              -- Lehrensuche #1
        { a = 42188, c = 6 },              -- Lehrensuche #2
        { a = 42189, c = 6 },              -- Lehrensuche #3
        { a = 61318, c = 6 },              -- Hosing Collection
        --------- MOUNTS -----------
        { a = 2537,  c = 7 },
        { a = 7862,  c = 7 },
        { a = 8302,  c = 7 },
        { a = 9599,  c = 7 },
        { a = 10355, c = 7 },
        { a = 12931, c = 7 },
        { a = 12934, c = 7 },
        { a = 15833, c = 7 }, -- Mount count 500
        { a = 9713,  c = 7 }, -- Dragon
        -- Midnight Pre-Patch
        { a = 42300, c = 8 }, -- two-minutes-to-midnight
        { a = 61430, c = 8 }, -- crunching-for-cultists
        { a = 61916, c = 8 }, -- DH Spec freischalten
    },
    delve_renown = {
        { id = 2722, name = "Delve S3" },
    },
    pvp_ranks = {
        [1] =  41020 ,
        [2] =  41021 ,
        [3] =  41022 ,
        [4] =  41023 ,
        [5] =  41016 ,
        [6] =  41017 ,
    }
}