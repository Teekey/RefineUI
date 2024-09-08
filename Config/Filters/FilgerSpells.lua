local R, C, L = unpack(RefineUI)
if C.filger.enable ~= true then return end

----------------------------------------------------------------------------------------
--	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
--	Example: Renew -> http://www.wowhead.com/spell=139
--	Take the number ID at the end of the URL, and add it to the list
----------------------------------------------------------------------------------------
LEFT_BUFF_Anchor = CreateFrame("Frame", "RefineUI_LeftBuff", UIParent)
RIGHT_BUFF_Anchor = CreateFrame("Frame", "RefineUI_RightBuff", UIParent)
BOTTOM_BUFF_Anchor = CreateFrame("Frame", "RefineUI_BottomBuff", UIParent)

C["filger_spells"] = {
	["DEATHKNIGHT"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Empower Rune Weapon
			{ spellID = 47568,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Death's Advance
			{ spellID = 48265,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Remorseless Winter
			{ spellID = 196770, unitID = "player", caster = "player", filter = "BUFF" },
			-- Hungering Rune Weapon
			{ spellID = 207127, unitID = "player", caster = "player", filter = "BUFF" },
			-- Bone Shield
			{ spellID = 195181, unitID = "player", caster = "player", filter = "BUFF" },
			-- Vampiric Blood
			{ spellID = 55233,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Icebound Fortitude
			{ spellID = 48792,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Anti-Magic Shell
			{ spellID = 48707,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Dancing Rune Weapon
			{ spellID = 81256,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Lichborne
			{ spellID = 287081, unitID = "player", caster = "player", filter = "BUFF" },
			-- Rune Tap
			{ spellID = 194679, unitID = "player", caster = "player", filter = "BUFF" },
			-- Pillar of Frost
			{ spellID = 51271,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Desecrated Ground
			{ spellID = 115018, unitID = "player", caster = "player", filter = "BUFF" },
			-- Unholy Blight
			{ spellID = 115989, unitID = "player", caster = "player", filter = "BUFF" },
			-- Summon Gargoyle
			{ spellID = 49206,  filter = "ICD",    trigger = "NONE",  duration = 30 },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Icy Talons
			{ spellID = 194879, unitID = "player", caster = "player", filter = "BUFF" },
			-- Crimson Scourge
			{ spellID = 81141,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Freezing Fog
			{ spellID = 59052,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Killing Machine
			{ spellID = 51124,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Sudden Doom
			{ spellID = 81340,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Unholy Strength
			{ spellID = 53365,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Dark Transformation
			{ spellID = 63560,  unitID = "pet",    caster = "player", filter = "BUFF" },
		},
	},
	["DEMONHUNTER"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Metamorphosis
			{ spellID = 187827, unitID = "player", caster = "player", filter = "BUFF" },
			-- Immolation Aura
			{ spellID = 258920, unitID = "player", caster = "player", filter = "BUFF" },
			-- Demon Spikes
			{ spellID = 203720, unitID = "player", caster = "player", filter = "BUFF" },
			-- Soul Barrier
			{ spellID = 263648, unitID = "player", caster = "player", filter = "BUFF" },
			-- Blur
			{ spellID = 212800, unitID = "player", caster = "player", filter = "BUFF" },
			-- Netherwalk
			{ spellID = 196555, unitID = "player", caster = "player", filter = "BUFF" },
			-- Nether Bond
			{ spellID = 207810, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Soul Fragments
			{ spellID = 203981, unitID = "player", caster = "player", filter = "BUFF" },
			-- Momentum
			{ spellID = 208628, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["DRUID"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Incarnation: Chosen of Elune
			{ spellID = 102560, unitID = "player", caster = "player", filter = "BUFF" },
			-- Incarnation: King of the Jungle
			{ spellID = 102543, unitID = "player", caster = "player", filter = "BUFF" },
			-- Incarnation: Son of Ursoc
			{ spellID = 102558, unitID = "player", caster = "player", filter = "BUFF" },
			-- Incarnation: Tree of Life
			{ spellID = 117679, unitID = "player", caster = "player", filter = "BUFF" },
			-- Survival Instincts
			{ spellID = 61336,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Barkskin
			{ spellID = 22812,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Savage Roar
			{ spellID = 52610,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Berserk
			{ spellID = 106951, unitID = "player", caster = "player", filter = "BUFF", absID = true },
			-- Tiger's Fury
			{ spellID = 5217,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Celestial Alignment
			{ spellID = 194223, unitID = "player", caster = "player", filter = "BUFF" },
			-- Nature's Vigil
			{ spellID = 124974, unitID = "player", caster = "player", filter = "BUFF" },
			-- Rage of the Sleeper
			{ spellID = 200851, unitID = "player", caster = "player", filter = "BUFF" },
			-- Ironfur
			{ spellID = 192081, unitID = "player", caster = "player", filter = "BUFF" },
			-- Nature's Grasp
			{ spellID = 170856, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dash
			{ spellID = 1850,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Starfall
			{ spellID = 191034, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Warrior of Elune
			{ spellID = 202425, unitID = "player", caster = "player", filter = "BUFF" },
			-- Starlord
			{ spellID = 279709, unitID = "player", caster = "player", filter = "BUFF" },
			-- Bloodtalons
			{ spellID = 145152, unitID = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting
			{ spellID = 16870,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Soul of the Forest
			{ spellID = 114108, unitID = "player", caster = "player", filter = "BUFF" },
			-- Predatory Swiftness
			{ spellID = 69369,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Guardian of Elune
			{ spellID = 213680, unitID = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Solar)
			{ spellID = 48517,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Lunar)
			{ spellID = 48518,  unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["EVOKER"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Tip the scales
			{ spellID = 370553, unitID = "player", caster = "player", filter = "BUFF" },
			-- Living Flame Healing
			{ spellID = 361509, unitID = "player", caster = "player", filter = "BUFF" },
			-- Obsidian Scales
			{ spellID = 363916, unitID = "player", caster = "player", filter = "BUFF" },
			-- Time Spiral
			{ spellID = 375234, unitID = "player", caster = "player", filter = "BUFF" },
			-- Renewing Blaze
			{ spellID = 374348, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dragonrage
			{ spellID = 375087, unitID = "player", caster = "player", filter = "BUFF" },
			-- Hover
			{ spellID = 358267, unitID = "player", caster = "player", filter = "BUFF" },
			-- Deep Breath
			{ spellID = 357210, unitID = "player", caster = "player", filter = "BUFF" },
			-- Recall
			{ spellID = 371807, unitID = "player", caster = "player", filter = "BUFF" },
			-- Time Dilation
			{ spellID = 357170, unitID = "player", caster = "player", filter = "BUFF" },
			-- Time Stop (PVP Talent)
			{ spellID = 378441, unitID = "player", caster = "player", filter = "BUFF" },
			-- Echo
			{ spellID = 364343, unitID = "player", caster = "player", filter = "BUFF" },
			-- Reversion
			{ spellID = 366155, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dream Flight
			{ spellID = 363502, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dream Breath
			{ spellID = 355941, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Snapfire
			{ spellID = 370818, unitID = "player", caster = "player", filter = "BUFF" },
			-- Essence Burst
			{ spellID = 359618, unitID = "player", caster = "player", filter = "BUFF" },
			-- Leaping Flames
			{ spellID = 370901, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["HUNTER"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Coordinated Assault
			{ spellID = 266779, unitID = "player", caster = "player", filter = "BUFF" },
			-- Aspect of the Turtle
			{ spellID = 186265, unitID = "player", caster = "player", filter = "BUFF" },
			-- Bestial Wrath
			{ spellID = 19574,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Aspect of the Wild
			{ spellID = 193530, unitID = "player", caster = "player", filter = "BUFF" },
			-- Aspect of the Eagle
			{ spellID = 186289, unitID = "player", caster = "player", filter = "BUFF" },
			-- Aspect of the Cheetah
			{ spellID = 186257, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dire Beast
			{ spellID = 120694, unitID = "player", caster = "player", filter = "BUFF" },
			-- Camouflage
			{ spellID = 199483, unitID = "player", caster = "player", filter = "BUFF", absID = true },
			-- Spirit Mend
			{ spellID = 90361,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Posthaste
			{ spellID = 118922, unitID = "player", caster = "player", filter = "BUFF" },
			-- Volley
			-- {spellID = 194386, unitID = "player", caster = "player", filter = "BUFF"}, -- Delete after while
			-- Misdirection
			{ spellID = 35079,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Survivalist
			{ spellID = 164857, unitID = "player", caster = "player", filter = "BUFF" },
			-- Bombardment
			{ spellID = 82921,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Spitting Cobra
			{ spellID = 194407, unitID = "player", caster = "player", filter = "BUFF" },
			-- Trueshot
			{ spellID = 288613, unitID = "player", caster = "player", filter = "BUFF" },
			-- Survival of the Fittest
			{ spellID = 264735, unitID = "player", caster = "player", filter = "BUFF" },
			-- Fortitude of the Bear
			{ spellID = 272679, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Viper's Venom
			{ spellID = 268552, unitID = "player", caster = "player", filter = "BUFF" },
			-- Trick Shots
			{ spellID = 257622, unitID = "player", caster = "player", filter = "BUFF" },
			-- Lethal Shots
			{ spellID = 260395, unitID = "player", caster = "player", filter = "BUFF" },
			-- Lock and Load
			{ spellID = 194594, unitID = "player", caster = "player", filter = "BUFF" },
			-- Deathblow
			{ spellID = 378770, unitID = "player", caster = "player", filter = "BUFF" },
			-- Precise Shots
			{ spellID = 260242, unitID = "player", caster = "player", filter = "BUFF" },
			-- Frenzy
			{ spellID = 272790, unitID = "pet",    caster = "player", filter = "BUFF" },
			-- Steady Focus
			{ spellID = 193533, unitID = "player", caster = "player", filter = "BUFF" },
			-- Mok'Nathal Tactics
			{ spellID = 201081, unitID = "player", caster = "player", filter = "BUFF" },
			-- Mongoose Fury
			{ spellID = 190931, unitID = "player", caster = "player", filter = "BUFF" },
			-- Beast Cleave
			{ spellID = 118455, unitID = "pet",    caster = "player", filter = "BUFF" },
			-- Mend Pet
			{ spellID = 136,    unitID = "pet",    caster = "player", filter = "BUFF" },
		},
	},
	["MAGE"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Ice Block
			{ spellID = 45438,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Invisibility
			{ spellID = 66,     unitID = "player", caster = "player", filter = "BUFF", absID = true },
			-- Invisibility
			{ spellID = 32612,  unitID = "player", caster = "player", filter = "BUFF", absID = true },
			-- Greater Invisibility
			{ spellID = 110960, unitID = "player", caster = "player", filter = "BUFF", absID = true },
			-- Icy Veins
			{ spellID = 12472,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Arcane Power
			{ spellID = 12042,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Combustion
			{ spellID = 190319, unitID = "player", caster = "player", filter = "BUFF" },
			-- Infernal Cascade
			{ spellID = 336832, unitID = "player", caster = "player", filter = "BUFF" },
			-- Blazing Barrier
			{ spellID = 235313, unitID = "player", caster = "player", filter = "BUFF" },
			-- Prismatic Barrier
			{ spellID = 235450, unitID = "player", caster = "player", filter = "BUFF" },
			-- Ice Barrier
			{ spellID = 11426,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Ice Floes
			{ spellID = 108839, unitID = "player", caster = "player", filter = "BUFF" },
			-- Alter Time
			{ spellID = 108978, unitID = "player", caster = "player", filter = "BUFF" },
			-- Temporal Shield
			{ spellID = 198111, unitID = "player", caster = "player", filter = "BUFF" },
			-- Rune of Power
			{ spellID = 116011, filter = "ICD",    trigger = "NONE",  totem = true },
			-- Mirror Image
			{ spellID = 55342,  filter = "ICD",    trigger = "NONE",  duration = 40 },
			-- Icicles
			{ spellID = 205473, unitID = "player", caster = "player", filter = "BUFF", requireSpell = 199786 },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Fingers of Frost
			{ spellID = 44544,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Brain Freeze
			{ spellID = 190446, unitID = "player", caster = "player", filter = "BUFF" },
			-- Glacial Spike!
			{ spellID = 199844, unitID = "player", caster = "player", filter = "BUFF" },
			-- Heating Up
			{ spellID = 48107,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Hot Streak!
			{ spellID = 48108,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Pyroclasm
			{ spellID = 269651, unitID = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting
			{ spellID = 263725, unitID = "player", caster = "player", filter = "BUFF" },
			-- Rune of Power
			{ spellID = 116014, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["MONK"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Fortifying Brew
			{ spellID = 120954, unitID = "player", caster = "player", filter = "BUFF" },
			-- Ironskin Brew
			{ spellID = 215479, unitID = "player", caster = "player", filter = "BUFF" },
			-- Touch of Karma
			{ spellID = 125174, unitID = "player", caster = "player", filter = "BUFF" },
			-- Diffuse Magic
			{ spellID = 122783, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dampen Harm
			{ spellID = 122278, unitID = "player", caster = "player", filter = "BUFF" },
			-- Nimble Brew
			{ spellID = 213664, unitID = "player", caster = "player", filter = "BUFF" },
			-- Storm, Earth, and Fire
			{ spellID = 137639, unitID = "player", caster = "player", filter = "BUFF" },
			-- Mana Tea
			{ spellID = 197908, unitID = "player", caster = "player", filter = "BUFF" },
			-- Thunder Focus Tea
			{ spellID = 116680, unitID = "player", caster = "player", filter = "BUFF" },
			-- Brew-Stache
			{ spellID = 214372, unitID = "player", caster = "player", filter = "BUFF" },
			-- Lifecycles (Vivify)
			{ spellID = 197916, unitID = "player", caster = "player", filter = "BUFF" },
			-- Lifecycles (Enveloping Mist)
			{ spellID = 197919, unitID = "player", caster = "player", filter = "BUFF" },
			-- Fortification
			{ spellID = 213341, unitID = "player", caster = "player", filter = "BUFF" },
			-- Chi Torpedo
			{ spellID = 119085, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Rushing Jade Wind
			{ spellID = 116847, unitID = "player", caster = "player", filter = "BUFF" },
			-- Blackout Kick!
			{ spellID = 116768, unitID = "player", caster = "player", filter = "BUFF" },
			-- The Mists of Sheilun
			{ spellID = 199888, unitID = "player", caster = "player", filter = "BUFF" },
			-- Surge of Mists
			{ spellID = 246328, unitID = "player", caster = "player", filter = "BUFF" },
			-- Teachings of the Monastery
			{ spellID = 202090, unitID = "player", caster = "player", filter = "BUFF" },
			-- Transfer the Power
			{ spellID = 195321, unitID = "player", caster = "player", filter = "BUFF" },
			-- Hit Combo
			{ spellID = 196741, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["PALADIN"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Inquisition
			{ spellID = 84963,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Shield of Vengeance
			{ spellID = 184662, unitID = "player", caster = "player", filter = "BUFF" },
			-- Eye for an Eye
			{ spellID = 205191, unitID = "player", caster = "player", filter = "BUFF" },
			-- Crusade
			{ spellID = 231895, unitID = "player", caster = "player", filter = "BUFF" },
			-- Divine Shield
			{ spellID = 642,    unitID = "player", caster = "player", filter = "BUFF" },
			-- Guardian of Ancient Kings
			{ spellID = 86659,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Holy Avenger
			{ spellID = 105809, unitID = "player", caster = "player", filter = "BUFF" },
			-- Avenging Wrath
			{ spellID = 31884,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Ardent Defender
			{ spellID = 31850,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Divine Protection
			{ spellID = 498,    unitID = "player", caster = "player", filter = "BUFF" },
			-- Rule of Law
			{ spellID = 214202, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shield of the Righteous
			{ spellID = 132403, unitID = "player", caster = "player", filter = "BUFF" },
			-- Speed of Light
			{ spellID = 85499,  unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Divine Purpose
			{ spellID = 223819, unitID = "player", caster = "player", filter = "BUFF" },
			-- Righteous Verdict
			{ spellID = 267611, unitID = "player", caster = "player", filter = "BUFF" },
			-- Blade of Wrath
			{ spellID = 281178, unitID = "player", caster = "player", filter = "BUFF" },
			-- Infusion of Light
			{ spellID = 54149,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Grand Crusader
			{ spellID = 85416,  unitID = "player", caster = "player", filter = "BUFF" },
			-- The Fires of Justice
			{ spellID = 209785, unitID = "player", caster = "player", filter = "BUFF" },
			-- Empyrean Power (Azerite Traits)
			{ spellID = 286393, unitID = "player", caster = "player", filter = "BUFF" },
			-- Selfless Healer
			{ spellID = 114250, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shining Light
			{ spellID = 327510, unitID = "player", caster = "player", filter = "BUFF", absID = true },
		},
	},
	["PRIEST"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Atonement
			{ spellID = 194384, unitID = "player", caster = "player", filter = "BUFF" },
			-- Rapture
			{ spellID = 47536,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Desperate Prayer
			{ spellID = 19236,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Voidform
			{ spellID = 194249, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dispersion
			{ spellID = 47585,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Apotheosis
			{ spellID = 200183, unitID = "player", caster = "player", filter = "BUFF" },
			-- Blessing of T'uure
			{ spellID = 196644, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dark Ascension
			{ spellID = 391109, unitID = "player", caster = "player", filter = "BUFF" },
			-- Spirit of Redemption
			{ spellID = 20711,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Divinity
			{ spellID = 197030, unitID = "player", caster = "player", filter = "BUFF" },
			-- Power of the Naaru
			{ spellID = 196490, unitID = "player", caster = "player", filter = "BUFF" },
			-- Archangel
			{ spellID = 197862, unitID = "player", caster = "player", filter = "BUFF" },
			-- Vampiric Embrace
			{ spellID = 15286,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Focused Will
			{ spellID = 45242,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Fade
			{ spellID = 586,    unitID = "player", caster = "player", filter = "BUFF" },
			-- Power Word: Shield
			{ spellID = 17,     unitID = "player", caster = "all",    filter = "BUFF" },
			-- Renew
			{ spellID = 139,    unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Power of the Dark Side
			{ spellID = 198069, unitID = "player", caster = "player", filter = "BUFF" },
			-- Surge of Light
			{ spellID = 114255, unitID = "player", caster = "player", filter = "BUFF" },
			-- Twist of Fate
			{ spellID = 123254, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["ROGUE"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Slice and Dice
			{ spellID = 5171,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Adrenaline Rush
			{ spellID = 13750,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Evasion
			{ spellID = 5277,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Envenom
			{ spellID = 32645,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Shadow Dance
			{ spellID = 185313, unitID = "player", caster = "player", filter = "BUFF" },
			-- Symbols of Death
			{ spellID = 212283, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shadow Blades
			{ spellID = 121471, unitID = "player", caster = "player", filter = "BUFF" },
			-- Curse of the Dreadblades
			{ spellID = 208245, unitID = "player", caster = "player", filter = "DEBUFF" },
			-- Alacrity
			{ spellID = 193539, unitID = "player", caster = "player", filter = "BUFF" },
			-- Master of Subtlety
			{ spellID = 31665,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Cloak of Shadows
			{ spellID = 31224,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Vanish
			{ spellID = 1856,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Combat Readiness
			{ spellID = 74001,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Combat Insight
			{ spellID = 74002,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Shadow Reflection
			{ spellID = 152151, unitID = "player", caster = "player", filter = "BUFF" },
			-- Cheating Death
			{ spellID = 45182,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Blade Flurry
			{ spellID = 13877,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Burst of Speed
			{ spellID = 108212, unitID = "player", caster = "player", filter = "BUFF" },
			-- Sprint
			{ spellID = 2983,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Feint
			{ spellID = 1966,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Subterfuge
			{ spellID = 115192, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dreadblades
			{ spellID = 343142, unitID = "player", caster = "player", filter = "DEBUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Shuriken Combo
			{ spellID = 245640, unitID = "player", caster = "player", filter = "BUFF" },
			-- Jolly Roger
			{ spellID = 199603, unitID = "player", caster = "player", filter = "BUFF" },
			-- Grand Melee
			{ spellID = 193358, unitID = "player", caster = "player", filter = "BUFF" },
			-- True Bearing
			{ spellID = 193359, unitID = "player", caster = "player", filter = "BUFF" },
			-- Buried Treasure
			{ spellID = 199600, unitID = "player", caster = "player", filter = "BUFF" },
			-- Broadsides
			{ spellID = 193356, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shark Infested Waters
			{ spellID = 193357, unitID = "player", caster = "player", filter = "BUFF" },
			-- Opportunity
			{ spellID = 195627, unitID = "player", caster = "player", filter = "BUFF" },
			-- Audacity
			{ spellID = 386270, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["SHAMAN"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Elemental Mastery
			{ spellID = 16166,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Ascendance
			{ spellID = 114049, unitID = "player", caster = "player", filter = "BUFF" },
			-- Spiritwalker's Grace
			{ spellID = 79206,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Unleash Life
			{ spellID = 73685,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Doom Winds
			{ spellID = 204945, unitID = "player", caster = "player", filter = "BUFF" },
			-- Landslide
			{ spellID = 202004, unitID = "player", caster = "player", filter = "BUFF" },
			-- Stone Bulwark
			{ spellID = 114893, unitID = "player", caster = "player", filter = "BUFF" },
			-- Ancestral Guidance
			{ spellID = 108281, unitID = "player", caster = "player", filter = "BUFF" },
			-- Astral Shift
			{ spellID = 108271, unitID = "player", caster = "player", filter = "BUFF" },
			-- Fury of Air
			{ spellID = 197211, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Lava Surge
			{ spellID = 77762,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Elemental Blast
			{ spellID = 118522, unitID = "player", caster = "player", filter = "BUFF" },
			-- Tidal Waves
			{ spellID = 53390,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Stormlash
			{ spellID = 195222, unitID = "player", caster = "player", filter = "BUFF" },
			-- Stormbringer
			{ spellID = 201846, unitID = "player", caster = "player", filter = "BUFF" },
			-- Crash Lightning
			{ spellID = 187878, unitID = "player", caster = "player", filter = "BUFF" },
			-- Flametongue
			{ spellID = 194084, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["WARLOCK"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- Dark Soul: Misery
			{ spellID = 113860, unitID = "player", caster = "player", filter = "BUFF" },
			-- Dark Soul: Instability
			{ spellID = 113858, unitID = "player", caster = "player", filter = "BUFF" },
			-- Deadwind Harvester
			{ spellID = 216708, unitID = "player", caster = "player", filter = "BUFF" },
			-- Unending Resolve
			{ spellID = 104773, unitID = "player", caster = "player", filter = "BUFF" },
			-- Soul Harvest
			{ spellID = 196098, unitID = "player", caster = "player", filter = "BUFF" },
			-- Empowered Life Tap
			{ spellID = 235156, unitID = "player", caster = "player", filter = "BUFF" },
			-- Soul Swap
			{ spellID = 86211,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Dark Regeneration
			{ spellID = 108359, unitID = "player", caster = "player", filter = "BUFF" },
			-- Burning Rush
			{ spellID = 111400, unitID = "player", caster = "player", filter = "BUFF" },
			-- Sacrificial Pact
			{ spellID = 108416, unitID = "player", caster = "player", filter = "BUFF" },
			-- Healthstone
			{ spellID = 6262,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Nether Ward
			{ spellID = 212295, unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Buffs
			-- Backdraft
			{ spellID = 117828, unitID = "player", caster = "player", filter = "BUFF" },
			-- Grimore of Synergy
			{ spellID = 171982, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["WARRIOR"] = {
		{
			Name = "LEFT_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", LEFT_BUFF_Anchor },

			-- In For The Kill
			{ spellID = 248622, unitID = "player", caster = "player", filter = "BUFF" },
			-- Deadly Calm
			{ spellID = 262228, unitID = "player", caster = "player", filter = "BUFF" },
			-- Sweeping Strikes
			{ spellID = 260708, unitID = "player", caster = "player", filter = "BUFF" },
			-- Ignore Pain
			{ spellID = 190456, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shield Wall
			{ spellID = 871,    unitID = "player", caster = "player", filter = "BUFF" },
			-- Last Stand
			{ spellID = 12975,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Enraged Regeneration
			{ spellID = 184364, unitID = "player", caster = "player", filter = "BUFF" },
			-- Shield Block
			{ spellID = 2565,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Spell Reflection
			{ spellID = 23920,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Die by the Sword
			{ spellID = 118038, unitID = "player", caster = "player", filter = "BUFF" },
			-- Berserker Rage
			{ spellID = 18499,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Avatar
			{ spellID = 107574, unitID = "player", caster = "player", filter = "BUFF" },
			-- Recklesness
			{ spellID = 1719,   unitID = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "RIGHT_BUFF",
			Direction = "RIGHT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", RIGHT_BUFF_Anchor },

			-- Victorious
			{ spellID = 32216,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Overpower
			{ spellID = 7384,   unitID = "player", caster = "player", filter = "BUFF" },
			-- Frothing Berserker
			{ spellID = 215572, unitID = "player", caster = "player", filter = "BUFF" },
			-- Furious Slash
			{ spellID = 202539, unitID = "player", caster = "player", filter = "BUFF" },
			-- Vengeance: Ignore Pain
			{ spellID = 202574, unitID = "player", caster = "player", filter = "BUFF" },
			-- Sudden Death
			{ spellID = 52437,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Meat Cleaver
			{ spellID = 85739,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Enrage
			{ spellID = 184362, unitID = "player", caster = "player", filter = "BUFF" },
		},
	},
	["ALL"] = {
		{
			Name = "BOTTOM_BUFF",
			Direction = "LEFT",
			Mode = "ICON",
			Interval = C.filger.buffs_space,
			Alpha = 1,
			IconSize = C.filger.buffs_size,
			Position = { "TOP", BOTTOM_BUFF_Anchor },

			-- Potions: Power
			-- Elemental Potion of Power
			{ spellID = 371024, unitID = "player", caster = "player", filter = "BUFF" },
			-- Elemental Potion of Ultimate Power
			{ spellID = 371028, unitID = "player", caster = "player", filter = "BUFF" },

			-- Potions: Miscellaneous
			-- Invisible [Potion of the Hushed Zephyr]
			{ spellID = 371124, unitID = "player", caster = "player", filter = "BUFF",   absID = true },

			-- Raid Amplifiers
			-- Bloodlust
			{ spellID = 2825,   unitID = "player", caster = "all",    filter = "BUFF" },
			-- Heroism
			{ spellID = 32182,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Primal Rage [Hunter's pet]
			{ spellID = 264667, unitID = "player", caster = "all",    filter = "BUFF",   absID = true },
			-- Time Warp
			{ spellID = 80353,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Fury of the Aspects
			{ spellID = 390386, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Feral Hide Drums
			{ spellID = 381301, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Mallet of Thunderous Skins
			{ spellID = 292686, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Power Infusion
			{ spellID = 10060,  unitID = "player", caster = "all",    filter = "BUFF" },

			-- Engineering
			-- Goblin Glider [Goblin Glider Kit]
			{ spellID = 126389, unitID = "player", caster = "all",    filter = "BUFF",   absID = true },
			-- Nitro Boosts
			{ spellID = 54861,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Parachute
			{ spellID = 55001,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Shieldtronic Shield
			{ spellID = 173260, unitID = "player", caster = "all",    filter = "BUFF",   absID = true },

			-- Racial
			-- Berserking (Troll)
			{ spellID = 26297,  unitID = "player", caster = "player", filter = "BUFF",   absID = true },
			-- Blood Fury (Orc)
			{ spellID = 20572,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Darkflight (Worgen)
			{ spellID = 68992,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Gift of the Naaru (Draenei)
			{ spellID = 28880,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Shadowmeld (Night Elf)
			{ spellID = 58984,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Stoneform (Dwarf)
			{ spellID = 65116,  unitID = "player", caster = "player", filter = "BUFF" },
			-- Fireblood (Dark Iron Dwarf)
			{ spellID = 265221, unitID = "player", caster = "player", filter = "BUFF" },

			-- Zone Buffs
			-- Inactive (Battlegrounds)
			{ spellID = 43681,  unitID = "player", caster = "all",    filter = "DEBUFF", absID = true },
			-- Speed (Battlegrounds)
			{ spellID = 23451,  unitID = "player", caster = "all",    filter = "BUFF",   absID = true },
			-- Strange Feeling (Brawler's Guild)
			{ spellID = 134851, unitID = "player", caster = "all",    filter = "DEBUFF", absID = true },

			-- Damage Reduction
			-- Life Cocoon
			{ spellID = 116849, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Guardian Spirit
			{ spellID = 47788,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Pain Suppression
			{ spellID = 33206,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Ironbark
			{ spellID = 102342, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Aura Mastery
			{ spellID = 31821,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Blessing of Protection
			{ spellID = 1022,   unitID = "player", caster = "all",    filter = "BUFF" },
			-- Blessing of Sacrifice
			{ spellID = 6940,   unitID = "player", caster = "all",    filter = "BUFF" },
			-- Blessing of Spellwarding
			{ spellID = 204018, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Vigilance
			{ spellID = 114030, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Rallying Cry
			{ spellID = 97463,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Darkness
			{ spellID = 209426, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Anti-Magic Zone
			{ spellID = 145629, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Zephyr
			{ spellID = 374227, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Rewind
			{ spellID = 363534, unitID = "player", caster = "all",    filter = "BUFF" },

			-- Other
			-- Symbol of Hope
			{ spellID = 64901,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Innervate
			{ spellID = 29166,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Grounding Totem
			{ spellID = 8178,   unitID = "player", caster = "all",    filter = "BUFF" },
			-- Mass Spell Reflection
			{ spellID = 213915, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Tiger's Lust
			{ spellID = 116841, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Body and Soul
			{ spellID = 65081,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Angelic Feather
			{ spellID = 121557, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Stampeding Roar
			{ spellID = 77764,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Blessing of Freedom
			{ spellID = 1044,   unitID = "player", caster = "all",    filter = "BUFF", color = {0, 1, 0}},
			-- Time Spiral
			{ spellID = 375226, unitID = "player", caster = "all",    filter = "BUFF" },
			-- Tricks of the Trade
			{ spellID = 57934,  unitID = "player", caster = "all",    filter = "BUFF" },
			-- Slow Fall
			{ spellID = 130,    unitID = "player", caster = "all",    filter = "BUFF" },
			-- Levitate
			{ spellID = 1706,   unitID = "player", caster = "all",    filter = "BUFF" },
		},
	},
}

-- Common colldowns for all classes
R.CustomFilgerSpell = R.CustomFilgerSpell or {}
R.FilgerIgnoreSpell = R.FilgerIgnoreSpell or {}
do
	-- Racial
	local _, race = UnitRace("player")
	if race == "Human" then
		-- Will to Survive
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 59752, filter = "CD" } })
	elseif race == "Orc" then
		-- Blood Fury
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 20572, filter = "CD" } })
	elseif race == "Dwarf" then
		-- Stoneform
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 20594, filter = "CD" } })
	elseif race == "NightElf" then
		-- Shadowmeld
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 58984, filter = "CD" } })
	elseif race == "Scourge" then
		-- Will of the Forsaken
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 7744, filter = "CD" } })
		-- Cannibalize
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 20577, filter = "CD" } })
	elseif race == "Tauren" then
		-- War Stomp
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 20549, filter = "CD" } })
	elseif race == "Gnome" then
		-- Escape Artist
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 20589, filter = "CD" } })
	elseif race == "Troll" then
		-- Berserking
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 26297, filter = "CD", absID = true } })
	elseif race == "Goblin" then
		-- Rocket Jump
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 69070, filter = "CD" } })
	elseif race == "BloodElf" then
		-- Arcane Torrent
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 69179, filter = "CD" } })
	elseif race == "Draenei" then
		-- Gift of the Naaru
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 28880, filter = "CD" } })
	elseif race == "Worgen" then
		-- Darkflight
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 68992, filter = "CD" } })
	elseif race == "Pandaren" then
		-- Quaking Palm
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 107079, filter = "CD" } })
	elseif race == "DarkIronDwarf" then
		-- Fireblood
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 265221, filter = "CD" } })
	elseif race == "KulTiran" then
		-- Haymaker
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 287712, filter = "CD" } })
	elseif race == "HighmountainTauren" then
		-- Bull Rush
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 255654, filter = "CD" } })
	elseif race == "Vulpera" then
		-- Bag of Tricks
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 312411, filter = "CD" } })
	elseif race == "LightforgedDraenei" then
		-- Light's Judgment
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 255647, filter = "CD" } })
	elseif race == "ZandalariTroll" then
		-- Regeneratin'
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 291944, filter = "CD" } })
	elseif race == "MagharOrc" then
		-- Ancestral Call
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 274738, filter = "CD" } })
	elseif race == "Dracthyr" then
		-- Tail Swipe
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 368970, filter = "CD" } })
		-- Wing Buffet
		tinsert(R.CustomFilgerSpell, { "COOLDOWN", { spellID = 357214, filter = "CD" } })
	end

	-- Items
	-- Back
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 15, filter = "CD" } })
	-- Belt
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 6, filter = "CD" } })
	-- Gloves
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 10, filter = "CD" } })
	-- Neck
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 2, filter = "CD" } })
	-- Rings
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 11, filter = "CD" } })
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 12, filter = "CD" } })
	-- Trinkets
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 13, filter = "CD" } })
	tinsert(R.CustomFilgerSpell, { "COOLDOWN", { slotID = 14, filter = "CD" } })

	local isTank = { ["DEATHKNIGHT"] = true, ["DEMONHUNTER"] = true, ["DRUID"] = true, ["MONK"] = true, ["PALADIN"] = true,
		["WARRIOR"] = true }
	local isHealer = { ["DRUID"] = true, ["EVOKER"] = true, ["MONK"] = true, ["PALADIN"] = true, ["PRIEST"] = true,
		["SHAMAN"] = true }
	local strengthClass = { ["DEATHKNIGHT"] = true, ["PALADIN"] = true, ["WARRIOR"] = true }
	local agilityClass = { ["DEMONHUNTER"] = true, ["DRUID"] = true, ["HUNTER"] = true, ["MONK"] = true, ["ROGUE"] = true,
		["SHAMAN"] = true }
	local intellectClass = { ["DRUID"] = true, ["EVOKER"] = true, ["MAGE"] = true, ["MONK"] = true, ["PALADIN"] = true,
		["PRIEST"] = true, ["SHAMAN"] = true, ["WARLOCK"] = true }

	-- Trinkets
	if strengthClass[R.class] then
		-- Bound by Fire and Blaze [Blazebinder's Hoof]
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 383926, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
		-- Bonemaw's Big Toe
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 397400, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	end

	if agilityClass[R.class] then
		-- Bottle of Spiraling Winds
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 383751, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
		-- Windswept Pages
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 126483, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	end

	if agilityClass[R.class] or strengthClass[R.class] then
		-- Scent of Blood [Hunger of the Pack]
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 213888, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
		-- Algeth'ar Puzzle
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 383781, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	end

	if intellectClass[R.class] then
		-- Power Theft
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 382126, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	end

	if isHealer[R.class] then
		-- Broodkeeper's Promise
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 377462, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
		-- Voidmender's Shadowgem
		tinsert(R.CustomFilgerSpell,
			{ "RIGHT_BUFF", { spellID = 397399, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	end

	-- Crumbling Power [Irideus Fragment]
	tinsert(R.CustomFilgerSpell,
		{ "RIGHT_BUFF", { spellID = 383941, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	-- Whispering Incarnate Icon
	tinsert(R.CustomFilgerSpell,
		{ "RIGHT_BUFF", { spellID = 377452, unitID = "player", caster = "all", filter = "BUFF", absID = true } })
	-- Valarjar's Path [Horn of Valor]
	tinsert(R.CustomFilgerSpell,
		{ "RIGHT_BUFF", { spellID = 215956, unitID = "player", caster = "all", filter = "BUFF", absID = true } })

	-- Remove Serpent Sting if Serpentstalker's Trickery is pick up
	if IsPlayerSpell(378888) then
		R.FilgerIgnoreSpell[C_Spell.GetSpellInfo(271788)] = true
	end
end
