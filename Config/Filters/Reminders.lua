local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
--	Example: Well Fed -> http://www.wowhead.com/spell=104280
--	Take the number ID at the end of the URL, and add it to the list
----------------------------------------------------------------------------------------
local function SpellInfo(id)
    local spellInfo = C_Spell.GetSpellInfo(id)
    local texture = C_Spell.GetSpellTexture(id)
    if spellInfo then
        return {spellInfo.name, texture or "Interface\\Icons\\INV_Misc_QuestionMark", id}
    else
        print("|cffff0000RefineUI: Reminders spell ID ["..tostring(id).."] no longer exists!|r")
        return {"Empty", "Interface\\Icons\\INV_Misc_QuestionMark", 0}
    end
end

if C.reminder.raidBuffsEnable == true then
    R.ReminderBuffs = R.ReminderBuffs or {}  -- Initialize if not already presen
	R.ReminderBuffs = {
		Flask = {
			SpellInfo(370652),	-- Phial of Static Empowerment
			SpellInfo(373257),	-- Phial of Glacial Fury
			SpellInfo(374000),	-- Iced Phial of Corrupting Rage
			SpellInfo(371036),	-- Phial of Icy Preservation
			SpellInfo(371186),	-- Charged Phial of Alacrity
			SpellInfo(371339),	-- Phial of Elemental Chaos
			SpellInfo(371204),	-- Phial of Still Air
			SpellInfo(371354),	-- Phial of the Eye in the Storm
			SpellInfo(371386),	-- Phial of Charged Isolation
			SpellInfo(371172),	-- Phial of Tepid Versatility
		},
		BattleElixir = {
			-- SpellInfo(spellID),	-- Spell name

		},
		GuardianElixir = {
			-- SpellInfo(spellID),	-- Spell name
		},
		Food = {
			SpellInfo(104280),	-- Well Fed
		},
		Stamina = {
			SpellInfo(21562),	-- Power Word: Fortitude
		},
		Vers = {
			SpellInfo(1126),	-- Mark of the Wild
		},
		Reduce = {
			SpellInfo(381748),	-- Blessing of the Bronze
		},
		Custom = {
			-- SpellInfo(spellID),	-- Spell name
		}
	}

	-- Caster buffs
	function R.ReminderCasterBuffs()
		Spell4Buff = {	-- Intellect
			SpellInfo(1459),	-- Arcane Intellect
		}
	end

	-- Physical buffs
	function R.ReminderPhysicalBuffs()
		Spell4Buff = {	-- Attack Power
			SpellInfo(6673),	-- Battle Shout
		}
	end
end

----------------------------------------------------------------------------------------
--[[------------------------------------------------------------------------------------
	Spell Reminder Arguments

	Type of Check:
		spells - List of spells in a group, if you have anyone of these spells the icon will hide.

	Spells only Requirements:
		reversecheck - only works if you provide a role or a spec, instead of hiding the frame when you have the buff, it shows the frame when you have the buff
		negate_reversecheck - if reversecheck is set you can set a spec to not follow the reverse check

	Requirements:
		role - you must be a certain role for it to display (Tank, Melee, Caster)
		spec - you must be active in a specific spec for it to display (1, 2, 3) note: spec order can be viewed from top to bottom when you open your talent pane
		level - the minimum level you must be (most of the time we don't need to use this because it will register the spell learned event if you don't know the spell, but in some cases it may be useful)

	Additional Checks: (Note we always run a check when gaining/losing an aura)
		combat - check when entering combat
		instance - check when entering a party/raid instance
		pvp - check when entering a bg/arena

	For every group created a new frame is created, it's a lot easier this way.
]]--------------------------------------------------------------------------------------
if C.reminder.soloBuffsEnable == true then
    R.ReminderSelfBuffs = R.ReminderSelfBuffs or {}  -- Initialize if not already present
	R.ReminderSelfBuffs = {
		DRUID = {
			[1] = {	-- Mark of the Wild group
				["spells"] = {
					SpellInfo(1126),	-- Mark of the Wild
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
		},
		EVOKER = {
			[1] = {	-- Blessing of the Bronze
				["spells"] = {
					SpellInfo(381748),	-- Blessing of the Bronze
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
		},
		MAGE = {
			[1] = {	-- Intellect group
				["spells"] = {
					SpellInfo(1459),	-- Arcane Intellect
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
		},
		PALADIN = {
			[1] = {	-- Auras group
				["spells"] = {
					SpellInfo(465),		-- Devotion Aura
					SpellInfo(183435),	-- Retribution Aura
					SpellInfo(317920),	-- Concentration Aura
					SpellInfo(32223),	-- Crusaader Aura
				},
				["instance"] = true
			},
		},
		PRIEST = {
			[1] = {	-- Stamina group
				["spells"] = {
					SpellInfo(21562),	-- Power Word: Fortitude
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true
			},
		},
		ROGUE = {
			[1] = {	-- Lethal Poisons group
				["spells"] = {
					SpellInfo(2823),	-- Deadly Poison
					SpellInfo(315584),	-- Instant Poison
					SpellInfo(8679),	-- Wound Poison
					SpellInfo(381664),	-- Amplifying Poison
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
			[2] = {	-- Non-Lethal Poisons group
				["spells"] = {
					SpellInfo(3408),	-- Crippling Poison
					SpellInfo(5761),	-- Numbing Poison
					SpellInfo(381637),	-- Atrophic Poison
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
		},
		SHAMAN = {
			[1] = {	-- Shields group
				["spells"] = {
					SpellInfo(52127),	-- Water Shield
					SpellInfo(974),		-- Earth Shield
					SpellInfo(192106),	-- Lightning Shield
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
			[2] = {	-- Windfury Weapon group
				["spells"] = {
					SpellInfo(33757),	-- Windfury Weapon
				},
				["mainhand"] = true,
				["spec"] = 2,
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
				["level"] = 10,
			},
			[3] = {	-- Flametongue Weapon group
				["spells"] = {
					SpellInfo(318038),	-- Flametongue Weapon
				},
				["offhand"] = true,
				["spec"] = 2,
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
				["level"] = 10,
			},
		},
		WARRIOR = {
			[1] = {	-- Battle Shout group
				["spells"] = {
					SpellInfo(6673),	-- Battle Shout
				},
				["combat"] = true,
				["instance"] = true,
				["pvp"] = true,
			},
		},
	}
end