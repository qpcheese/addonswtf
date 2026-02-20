_G.Merfin = _G.Merfin or {}
local Merfin = _G.Merfin

local trinketData = {
  {
    name = "Abacus of Violent Odds",
    items = { 28288 },
    effects = {
      { type = "proc", spells = { 33807 } },
    },
  },
  {
    name = "Adamantine Figurine",
    items = { 27891 },
    effects = {
      { type = "proc", spells = { 33479 } },
    },
  },
  {
    name = "Airman's Ribbon of Gallantry",
    items = { 32771 },
    effects = {
      { type = "proc", spells = { 41263 }, icd = 10 },
    },
  },
  {
    name = "Ancient Aqir Artifact",
    items = { 33830 },
    effects = {
      { type = "proc", spells = { 43713 } },
    },
  },
  {
    name = "Arcanist's Stone",
    items = { 28223 },
    effects = {
      { type = "proc", spells = { 34000 } },
    },
  },
  {
    name = "Argussian Compass",
    items = { 27770 },
    effects = {
      { type = "proc", spells = { 39228 } },
    },
  },
  {
    name = "Auslese's Light Channeler",
    items = { 24390 },
    effects = {
      { type = "proc", spells = { 31794 } },
    },
  },
  {
    name = "Badge of Tenacity",
    items = { 32658 },
    effects = {
      { type = "proc", spells = { 40729 } },
    },
  },
  {
    name = "Balebrew Charm",
    items = { 37128 },
    effects = {
      { type = "proc", spells = { 48042 } },
    },
  },
  {
    name = "Bangle of Endless Blessings",
    items = { 28370 },
    effects = {
      { type = "proc", spells = { 34210 } },
    },
  },
  {
    name = "Berserker's Call",
    items = { 33831 },
    effects = {
      { type = "proc", spells = { 43716 } },
    },
  },
  {
    name = "Blackened Naaru Sliver",
    items = { 34427 },
    effects = {
      { type = "proc", spells = { 45040 }, icd = 45 },
    },
  },
  {
    name = "Bladefist's Breadth",
    items = { 28041, 31617 },
    effects = {
      { type = "proc", spells = { 33667 } },
    },
  },
  {
    name = "Bloodlust Brooch",
    items = { 29383 },
    effects = {
      { type = "proc", spells = { 35166 } },
    },
  },
  {
    name = "Brightbrew Charm",
    items = { 37127 },
    effects = {
      { type = "proc", spells = { 48041 } },
    },
  },
  {
    name = "Brooch of the Immortal King",
    items = { 32534 },
    effects = {
      { type = "proc", spells = { 40538 } },
    },
  },
  {
    name = "Charm of Alacrity",
    items = { 25787 },
    effects = {
      { type = "proc", spells = { 32600 } },
    },
  },
  {
    name = "Commander's Badge",
    items = { 32864 },
    effects = {
      { type = "proc", spells = { 40815 } },
    },
  },
  {
    name = "Commendation of Kael'thas",
    items = { 34473 },
    effects = {
      { type = "proc", spells = { 45058 }, icd = 30 },
    },
  },
  {
    name = "Core of Ar'kelos",
    items = { 29776 },
    effects = {
      { type = "proc", spells = { 35733 } },
    },
  },
  {
    name = "Coren's Lucky Coin",
    items = { 38289 },
    effects = {
      { type = "proc", spells = { 51952 } },
    },
  },
  {
    name = "Crystalforged Trinket",
    items = { 32654 },
    effects = {
      { type = "proc", spells = { 40724 } },
    },
  },
  {
    name = "Dabiri's Enigma",
    items = { 30300 },
    effects = {
      { type = "proc", spells = { 36372 } },
    },
  },
  {
    name = "Dark Iron Smoking Pipe",
    items = { 38290 },
    effects = {
      { type = "proc", spells = { 51953 } },
    },
  },
  {
    name = "Darkmoon Card: Crusade",
    items = { 31856 },
    effects = {
      { type = "proc", spells = { 39439, 39441 } },
    },
  },
  {
    name = "Darkmoon Card: Wrath",
    items = { 31857 },
    effects = {
      { type = "proc", spells = { 39443 } },
    },
  },
  {
    name = "Direbrew Hops",
    items = { 38288 },
    effects = {
      { type = "proc", spells = { 51954 } },
    },
  },
  {
    name = "Dragonspine Trophy",
    items = { 28830 },
    effects = {
      { type = "proc", spells = { 34775 }, icd = 20 },
    },
  },
  {
    name = "Earring of Soulful Meditation",
    items = { 30665 },
    effects = {
      { type = "proc", spells = { 40402 } },
    },
  },
  {
    name = "Empty Mug of Direbrew",
    items = { 38287 },
    effects = {
      { type = "proc", spells = { 51955 } },
    },
  },
  {
    name = "Essence Infused Mushroom",
    items = { 28109 },
    effects = {
      { type = "proc", spells = { 33746 } },
    },
  },
  {
    name = "Essence of the Martyr",
    items = { 29376 },
    effects = {
      { type = "proc", spells = { 35165 } },
    },
  },
  {
    name = "Eye of Gruul",
    items = { 28823 },
    effects = {
      { type = "proc", spells = { 37706 } },
    },
  },
  {
    name = "Eye of Magtheridon",
    items = { 28789 },
    effects = {
      { type = "proc", spells = { 34747 } },
    },
  },
  {
    name = "Fathom-Brooch of the Tidewalker",
    items = { 30663 },
    effects = {
      { type = "proc", spells = { 37243 }, icd = 40 },
    },
  },
  {
    name = "Fel Reaver's Piston",
    items = { 30619 },
    effects = {
      { type = "proc", spells = { 38324 }, icd = 15 },
    },
  },
  {
    name = "Fetish of the Fallen",
    items = { 27416 },
    effects = {
      { type = "proc", spells = { 33014 } },
    },
  },
  {
    name = "Figurine - Crimson Serpent",
    items = { 35700 },
    effects = {
      { type = "proc", spells = { 46783 } },
    },
  },
  {
    name = "Figurine - Dawnstone Crab",
    items = { 24125 },
    effects = {
      { type = "proc", spells = { 31039 } },
    },
  },
  {
    name = "Figurine - Empyrean Tortoise",
    items = { 35693 },
    effects = {
      { type = "proc", spells = { 46780 } },
    },
  },
  {
    name = "Figurine - Felsteel Boar",
    items = { 24124 },
    effects = {
      { type = "proc", spells = { 31038 } },
    },
  },
  {
    name = "Figurine - Khorium Boar",
    items = { 35694 },
    effects = {
      { type = "proc", spells = { 46782 } },
    },
  },
  {
    name = "Figurine - Living Ruby Serpent",
    items = { 24126 },
    effects = {
      { type = "proc", spells = { 31040 } },
    },
  },
  {
    name = "Figurine - Nightseye Panther",
    items = { 24128 },
    effects = {
      { type = "proc", spells = { 31047 } },
    },
  },
  {
    name = "Figurine - Seaspray Albatross",
    items = { 35703 },
    effects = {
      { type = "proc", spells = { 46785 } },
    },
  },
  {
    name = "Figurine - Shadowsong Panther",
    items = { 35702 },
    effects = {
      { type = "proc", spells = { 46784 } },
    },
  },
  {
    name = "Figurine - Talasite Owl",
    items = { 24127 },
    effects = {
      { type = "proc", spells = { 31045 } },
    },
  },
  {
    name = "Figurine of the Colossus",
    items = { 27529 },
    effects = {
      { type = "proc", spells = { 33089 } },
    },
  },
  {
    name = "Glimmering Naaru Sliver",
    items = { 34430 },
    effects = {
      { type = "proc", spells = { 45052 } },
    },
  },
  {
    name = "Glowing Crystal Insignia",
    items = { 25619, 25620 },
    effects = {
      { type = "proc", spells = { 32355 } },
    },
  },
  {
    name = "Gnomeregan Auto-Blocker 600",
    items = { 29387 },
    effects = {
      { type = "proc", spells = { 35169 } },
    },
  },
  {
    name = "Heavenly Inspiration",
    items = { 30293 },
    effects = {
      { type = "proc", spells = { 36347 } },
    },
  },
  {
    name = "Hex Shrunken Head",
    items = { 33829 },
    effects = {
      { type = "proc", spells = { 43712 } },
    },
  },
  {
    name = "Hourglass of the Unraveller",
    items = { 28034 },
    effects = {
      { type = "proc", spells = { 33648, 33649 }, icd = 50 },
    },
  },
  {
    name = "Icon of Unyielding Courage",
    items = { 28121 },
    effects = {
      { type = "proc", spells = { 34106 } },
    },
  },
  {
    name = "Icon of the Silver Crescent",
    items = { 29370 },
    effects = {
      { type = "proc", spells = { 35163 } },
    },
  },
  {
    name = "Jewel of Charismatic Mystique",
    items = { 27900 },
    effects = {
      { type = "proc", spells = { 33486 } },
    },
  },
  {
    name = "Living Root of the Wildheart",
    items = { 30664 },
    effects = {
      { type = "proc", spells = { 37340, 37341, 37342, 37343, 37344 } },
    },
  },
  {
    name = "Lower City Prayerbook",
    items = { 30841 },
    effects = {
      { type = "proc", spells = { 37877 } },
    },
  },
  {
    name = "Madness of the Betrayer",
    items = { 32505 },
    effects = {
      { type = "proc", spells = { 40477 } },
    },
  },
  {
    name = "Mark of Defiance",
    items = { 27922, 27924 },
    effects = {
      { type = "proc", spells = { 33511, 33513 }, icd = 17 },
    },
  },
  {
    name = "Mark of Vindication",
    items = { 27926, 27927 },
    effects = {
      { type = "proc", spells = { 33522, 33523 }, icd = 25 },
    },
  },
  {
    name = "Memento of Tyrande",
    items = { 32496 },
    effects = {
      { type = "proc", spells = { 37656 }, icd = 50 },
    },
  },
  {
    name = "Moroes' Lucky Pocket Watch",
    items = { 28528 },
    effects = {
      { type = "proc", spells = { 34519 } },
    },
  },
  {
    name = "Oculus of the Hidden Eye",
    items = { 26055 },
    effects = {
      { type = "proc", spells = { 33012 } },
    },
  },
  {
    name = "Ogre Mauler's Badge",
    items = { 25628, 25633 },
    effects = {
      { type = "proc", spells = { 32362 } },
    },
  },
  {
    name = "Oshu'gun Relic",
    items = { 25634 },
    effects = {
      { type = "proc", spells = { 32367 } },
    },
  },
  {
    name = "Pendant of the Violet Eye",
    items = { 28727 },
    effects = {
      { type = "proc", spells = { 29601 } },
      { type = "aura", spell = 35095, stacks = true },
    },
  },
  {
    name = "Power Infused Mushroom",
    items = { 28108 },
    effects = {
      { type = "proc", spells = { 33759 } },
    },
  },
  {
    name = "Quagmirran's Eye",
    items = { 27683, 28190 },
    effects = {
      { type = "proc", spells = { 33370 }, icd = 45 },
    },
  },
  {
    name = "Regal Protectorate",
    items = { 28042 },
    effects = {
      { type = "proc", spells = { 33668 } },
    },
  },
  {
    name = "Ribbon of Sacrifice",
    items = { 28590 },
    effects = {
      { type = "proc", spells = { 38332 } },
      { type = "aura", spell = 38333, stacks = true },
    },
  },
  {
    name = "Runed Fungalcap",
    items = { 24376 },
    effects = {
      { type = "proc", spells = { 31771 } },
    },
  },
  {
    name = "Scarab of Displacement",
    items = { 30629 },
    effects = {
      { type = "proc", spells = { 38351 } },
    },
  },
  {
    name = "Scryer's Bloodgem",
    items = { 29132, 29179 },
    effects = {
      { type = "proc", spells = { 35337 } },
    },
  },
  {
    name = "Serpent-Coil Braid",
    items = { 30720 },
    effects = {
      { type = "proc", spells = { 37445 } },
    },
  },
  {
    name = "Sextant of Unstable Currents",
    items = { 30626 },
    effects = {
      { type = "proc", spells = { 38348 }, icd = 45 },
    },
  },
  {
    name = "Shadowmoon Insignia",
    items = { 32501 },
    effects = {
      { type = "proc", spells = { 40464 } },
    },
  },
  {
    name = "Shard of Contempt",
    items = { 34472 },
    effects = {
      { type = "proc", spells = { 45053 }, icd = 45 },
    },
  },
  {
    name = "Shiffar's Nexus-Horn",
    items = { 28418 },
    effects = {
      { type = "proc", spells = { 34321 }, icd = 45 },
    },
  },
  {
    name = "Shifting Naaru Sliver",
    items = { 34429 },
    effects = {
      { type = "proc", spells = { 45044 } },
    },
  },
  {
    name = "Skyguard Silver Cross",
    items = { 32770 },
    effects = {
      { type = "proc", spells = { 41261 }, icd = 10 },
    },
  },
  {
    name = "Spyglass of the Hidden Fleet",
    items = { 30620 },
    effects = {
      { type = "proc", spells = { 38325 } },
    },
  },
  {
    name = "Starkiller's Bauble",
    items = { 30340 },
    effects = {
      { type = "proc", spells = { 36432 } },
    },
  },
  {
    name = "Steely Naaru Sliver",
    items = { 34428 },
    effects = {
      { type = "proc", spells = { 45049 } },
    },
  },
  {
    name = "Talisman of the Alliance",
    items = { 25829 },
    effects = {
      { type = "proc", spells = { 33828 } },
    },
  },
  {
    name = "Talisman of the Horde",
    items = { 24551 },
    effects = {
      { type = "proc", spells = { 32140 } },
    },
  },
  {
    name = "Talon of Al'ar",
    items = { 30448 },
    effects = {
      { type = "proc", spells = { 37508 } },
    },
  },
  {
    name = "Terokkar Tablet of Precision",
    items = { 25937 },
    effects = {
      { type = "proc", spells = { 39200 } },
    },
  },
  {
    name = "Terokkar Tablet of Vim",
    items = { 25936 },
    effects = {
      { type = "proc", spells = { 39201 } },
    },
  },
  {
    name = "The Lightning Capacitor",
    items = { 28785 },
    effects = {
      { type = "proc", spells = { 37658 }, icd = 2.5 },
    },
  },
  {
    name = "The Skull of Gul'dan",
    items = { 32483 },
    effects = {
      { type = "proc", spells = { 40396 } },
    },
  },
  {
    name = "Timbal's Focusing Crystal",
    items = { 34470 },
    effects = {
      { type = "proc", spells = { 45055 }, icd = 15 },
    },
  },
  {
    name = "Time-Lost Figurine",
    items = { 32782 },
    effects = {
      { type = "proc", spells = { 41301 } },
    },
  },
  {
    name = "Tiny Voodoo Mask",
    items = { 34029 },
    effects = {
      { type = "proc", spells = { 43995 } },
    },
  },
  {
    name = "Tome of Diabolic Remedy",
    items = { 33828 },
    effects = {
      { type = "proc", spells = { 43710 } },
    },
  },
  {
    name = "Tome of Fiery Redemption",
    items = { 30447 },
    effects = {
      { type = "proc", spells = { 37198 }, icd = 45 },
    },
  },
  {
    name = "Tsunami Talisman",
    items = { 30627 },
    effects = {
      { type = "proc", spells = { 42084 }, icd = 45 },
    },
  },
  {
    name = "Vengeance of the Illidari",
    items = { 28040, 31615 },
    effects = {
      { type = "proc", spells = { 33662 } },
    },
  },
  {
    name = "Vial of the Sunwell",
    items = { 34471 },
    effects = {
      { type = "proc", spells = { 45064 } },
    },
  },
  {
    name = "Warp-Scarab Brooch",
    items = { 27828 },
    effects = {
      { type = "proc", spells = { 33400 } },
    },
  },
  {
    name = "Warp-Spring Coil",
    items = { 30450 },
    effects = {
      { type = "proc", spells = { 37174 }, icd = 30 },
    },
  },
  {
    name = "Battlemaster's Same Effect Trinkets",
    items = { 33832, 34049, 34050, 34162, 34163, 34576, 34577, 34578, 34579, 34580, 35326, 35327 },
    effects = {
      { type = "proc", spells = { 44055 } },
    },
  },
  {
    name = "No Proc Effect Trinkets",
    items = {
      10725,
      23835,
      23836,
      25786,
      28234,
      28235,
      28236,
      28237,
      28238,
      28239,
      28240,
      28241,
      28242,
      28243,
      29181,
      30343,
      30344,
      30345,
      30346,
      30348,
      30349,
      30350,
      30351,
      31858,
      31859,
      37864,
      37865,
    },
    effects = {
      { type = "proc", spells = { 99999 }, noCooldown = true },
    },
  },
}

-- [enchantId] = procId
local enchants = {
  [2673] = 28093, -- Mongoose
  [3225] = 42976, -- Executioner
  [2674] = 27996, -- Spellsurge
}
-- [gemId] = procId
local gems = {
  [25893] = 18803, -- Mystical Skyfire Diamond
  [25898] = 32845, -- Tenacious Earthstorm Diamond
  [25899] = 23454, -- Brutal Earthstorm Diamond
  [32410] = 39959, -- Thundering Skyfire Diamond
}

Merfin.GetTrinketData = function()
  return trinketData or {}
end

Merfin.GetEnchantData = function()
  return enchants or {}
end

Merfin.GetGemData = function()
  return gems or {}
end
