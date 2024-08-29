local R, C, L = unpack(RefineUI)
----------------------------------------------------------------------------------------
--	RefineUI fonts configuration file
--	BACKUP THIS FILE BEFORE UPDATING!
----------------------------------------------------------------------------------------
--	Configuration example:
----------------------------------------------------------------------------------------
-- C["font"] = {
--		-- Stats font
--		["stats_font"] = "Interface\\AddOns\\RefineUI\\Media\\Fonts\\Normal.ttf",
--		["stats_font_size"] = 11,
--		["stats_font_style"] = "",
--		["stats_font_shadow"] = true,
-- }
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--	Fonts options
----------------------------------------------------------------------------------------
C["font"] = {
	-- Stats font
	["stats_font"] = C.media.normalFont,
	["stats_font_size"] = 16,
	["stats_font_style"] = "OUTLINE",
	["stats_font_shadow"] = false,

	-- Combat text font
	["combat_text_font"] = C.media.normalFont,
	["combat_text_font_size"] = 16,
	["combat_text_font_style"] = "OUTLINE",
	["combat_text_font_shadow"] = false,

	-- Chat font
	["chat_font"] = C.media.normalFont,
	["chat_font_style"] = "OUTLINE",
	["chat_font_shadow"] = true,

	-- Chat tabs font
	["chat_tabs_font"] = C.media.normalFont,
	["chat_tabs_font_size"] = 16,
	["chat_tabs_font_style"] = "OUTLINE",
	["chat_tabs_font_shadow"] = false,

	-- Action bars font
	["action_bars_font"] = C.media.normalFont,
	["action_bars_font_size"] = 12,
	["action_bars_font_style"] = "OUTLINE",
	["action_bars_font_shadow"] = true,

	-- Threat meter font
	["threat_meter_font"] = C.media.normalFont,
	["threat_meter_font_size"] = 8,
	["threat_meter_font_style"] = "OUTLINE",
	["threat_meter_font_shadow"] = false,

	-- Raid cooldowns font
	["raid_cooldowns_font"] = C.media.normalFont,
	["raid_cooldowns_font_size"] = 12,
	["raid_cooldowns_font_style"] = "OUTLINE",
	["raid_cooldowns_font_shadow"] = false,

	-- Raid UnitFrame font
	["group_name_font"] = C.media.normalFont,
	["group_name_size"] = 16,
	["group_name_style"] = "THICKOUTLINE",
	["group_name_shadow"] = false,

	-- Cooldowns timer font
	["cooldown_timers_font"] = C.media.boldFont,
	["cooldown_timers_font_size"] = 20,
	["cooldown_timers_font_style"] = "THICK, OUTLINE",
	["cooldown_timers_font_shadow"] = false,

	-- Loot font
	["loot_font"] = C.media.normalFont,
	["loot_font_size"] = 14,
	["loot_font_style"] = "OUTLINE",
	["loot_font_shadow"] = true,

	-- Nameplates font
	["nameplates_font"] = C.media.normalFont,
	["nameplates_font_size"] = 8,
	["nameplates_font_style"] = "OUTLINE",
	["nameplates_font_shadow"] = true,

	-- Nameplates font
	["nameplates_name_font"] = C.media.normalFont,
	["nameplates_name_font_size"] = 8,
	["nameplates_name_font_style"] = "OUTLINE",
	["nameplates_name_font_shadow"] = false,

	["nameplates_health_font"] = C.media.normalFont,
	["nameplates_health_font_size"] = 8,
	["nameplates_health_font_style"] = "OUTLINE",
	["nameplates_health_font_shadow"] = false,

	["nameplates_spell_font"] = C.media.normalFont,
	["nameplates_spell_size"] = 6,
	["nameplates_spell_style"] = "OUTLINE",
	["nameplates_spell_shadow"] = true,

	["nameplates_spelltime_font"] = C.media.boldFont,
	["nameplates_spelltime_size"] = 8,
	["nameplates_spelltime_style"] = "OUTLINE",
	["nameplates_spelltime_shadow"] = true,

	-- Unit frames font
	["unit_frames_font"] = C.media.normalFont,
	["unit_frames_font_size"] = 10,
	["unit_frames_font_style"] = "OUTLINE",
	["unit_frames_font_shadow"] = false,

	["unit_frames_health_font"] = C.media.normalFont,
	["unit_frames_health_font_size"] = 16,
	["unit_frames_health_font_style"] = "OUTLINE",
	["unit_frames_health_font_shadow"] = true,

	["unit_frames_name_font"] = C.media.normalFont,
	["unit_frames_name_font_size"] = 18,
	["unit_frames_name_font_style"] = "THICKOUTLINE",
	["unit_frames_name_font_shadow"] = false,

	["unit_frames_spell_font"] = C.media.normalFont,
	["unit_frames_spell_font_size"] = 12,
	["unit_frames_spell_font_style"] = "OUTLINE",
	["unit_frames_spell_font_shadow"] = true,

	["unit_frames_casttime_font"] = C.media.boldFont,
	["unit_frames_casttime_font_size"] = 18,
	["unit_frames_casttime_font_style"] = "OUTLINE",
	["unit_frames_casttime_font_shadow"] = true,

	-- Auras font
	["auras_font"] = C.media.boldFont,
	["auras_font_size"] = 10,
	["auras_font_style"] = "OUTLINE",
	["auras_font_shadow"] = true,

	["player_auras_duration_font"] = C.media.boldFont,
	["player_auras_duration_size"] = 18,
	["player_auras_duration_style"] = "THICKOUTLINE",
	["player_auras_duration_shadow"] = false,

	["player_auras_count_font"] = C.media.boldFont,
	["player_auras_count_size"] = 12,
	["player_auras_count_style"] = "OUTLINE",
	["player_auras_count_shadow"] = false,

	["player_debuffs_duration_font"] = C.media.normalFont,
	["player_debuffs_duration_size"] = 8,
	["player_debuffs_duration_style"] =  "OUTLINE",
	["player_debuffs_duration_shadow"] = false,

	-- Minimap font
	["minimap_font"] = C.media.normalFont,
	["minimap_font_size"] = 16,
	["minimap_font_style"] = "THICKOUTLINE",
	["minimap_font_shadow"] = false,

	-- Filger bar font
	["filger_font"] = C.media.normalFont,
	["filger_font_size"] = 8,
	["filger_font_style"] = "OUTLINE",
	["filger_font_shadow"] = false,

	["filger_time_font"] = C.media.boldFont,
	["filger_time_size"] = 20,
	["filger_time_style"] = "THICKOUTLINE",
	["filger_time_shadow"] = false,

	["filger_count_font"] = C.media.normalFont,
	["filger_count_size"] = 12,
	["filger_count_style"] = "OUTLINE",
	["filger_count_shadow"] = false,

	-- Stylization font
	["stylization_font"] = C.media.normalFont,
	["stylization_font_size"] = 15,
	["stylization_font_style"] = "OUTLINE",
	["stylization_font_shadow"] = false,

	-- Bags font
	["bags_font"] = C.media.normalFont,
	["bags_font_size"] = 12,
	["bags_font_style"] = "OUTLINE",
	["bags_font_shadow"] = false,

	-- Blizzard fonts
	["tooltip_header_font_size"] = 13,
	["tooltip_font_size"] = 11,
	["bubble_font_size"] = 10,
	["quest_tracker_font_mult"] = 1,

	["quest_font"] = C.media.normalFont,
	["quest_font_size"] = 14,
	["quest_font_style"] = "OUTLINE",
	["quest_font_shadow"] = true,

	-- Databar Fonts
	["databar_font"] = C.media.normalFont,
	["databar_font_size"] = 16,
	["databar_font_style"] = "OUTLINE",

	-- Databar Small Fonts
	["databar_smallfont"] = C.media.normalFont,
	["databar_smallfont_size"] = 10,
	["databar_smallfont_style"] = "OUTLINE",

	-- Databar Small Fonts
	["sct_font"] = C.media.normalFont,
	["sct_font_size"] = 10,
	["sct_font_style"] = "OUTLINE",
	["sct_font_shadow"] = false,

	-- BW Timeline
	["bwt_font"] = C.media.normalFont,
	["bwt_font_size"] = 12,
	["bwt_font_style"] = "OUTLINE",
	["bwt_font_shadow"] = false,

	["bwt_duration_font"] = C.media.normalFont,
	["bwt_duration_size"] = 12,
	["bwt_duration_style"] = "OUTLINE",
	["bwt_duration_shadow"] = true,

	["bwt_tick_font"] = C.media.normalFont,
	["bwt_tick_font_size"] = 10,
	["bwt_tick_font_style"] = "OUTLINE",
	["bwt_tick_font_shadow"] = false,
}

----------------------------------------------------------------------------------------
--	Font replacement for zhTW, zhCN, and koKR clients
----------------------------------------------------------------------------------------
local locale_font
if R.client == "zhTW" then
	locale_font = "Fonts\\bLEI00D.ttf"
elseif R.client == "zhCN" then
	locale_font = "Fonts\\ARKai_R.ttf"
elseif R.client == "koKR" then
	locale_font = "Fonts\\2002.ttf"
end

if locale_font then
	C["media"].normalFont = locale_font
	C["media"].pixel_font = locale_font
	C["media"].pixel_font_style = "OUTLINE"
	C["media"].pixel_font_size = 11

	C["font"].stats_font = locale_font
	C["font"].stats_font_size = 12
	C["font"].stats_font_style = "OUTLINE"
	C["font"].stats_font_shadow = true

	C["font"].combat_text_font = locale_font
	C["font"].combat_text_font_size = 16
	C["font"].combat_text_font_style = "OUTLINE"
	C["font"].combat_text_font_shadow = true

	C["font"].chat_font = locale_font
	C["font"].chat_font_style = "OUTLINE"
	C["font"].chat_font_shadow = true

	C["font"].chat_tabs_font = locale_font
	C["font"].chat_tabs_font_size = 16
	C["font"].chat_tabs_font_style = "OUTLINE"
	C["font"].chat_tabs_font_shadow = true

	C["font"].action_bars_font = locale_font
	C["font"].action_bars_font_size = 12
	C["font"].action_bars_font_style = "OUTLINE"
	C["font"].action_bars_font_shadow = true

	C["font"].threat_meter_font = locale_font
	C["font"].threat_meter_font_size = 12
	C["font"].threat_meter_font_style = "OUTLINE"
	C["font"].threat_meter_font_shadow = true

	C["font"].raid_cooldowns_font = locale_font
	C["font"].raid_cooldowns_font_size = 12
	C["font"].raid_cooldowns_font_style = "OUTLINE"
	C["font"].raid_cooldowns_font_shadow = true

	C["font"].cooldown_timers_font = locale_font
	C["font"].cooldown_timers_font_size = 13
	C["font"].cooldown_timers_font_style = "OUTLINE"
	C["font"].cooldown_timers_font_shadow = true

	C["font"].loot_font = locale_font
	C["font"].loot_font_size = 13
	C["font"].loot_font_style = "OUTLINE"
	C["font"].loot_font_shadow = true

	C["font"].nameplates_font = locale_font
	C["font"].nameplates_font_size = 13
	C["font"].nameplates_font_style = "OUTLINE"
	C["font"].nameplates_font_shadow = true

	C["font"].unit_frames_font = locale_font
	C["font"].unit_frames_font_size = 12
	C["font"].unit_frames_font_style = "OUTLINE"
	C["font"].unit_frames_font_shadow = true

	C["font"].auras_font = locale_font
	C["font"].auras_font_size = 11
	C["font"].auras_font_style = "OUTLINE"
	C["font"].auras_font_shadow = true

	C["font"].filger_font = locale_font
	C["font"].filger_font_size = 14
	C["font"].filger_font_style = "OUTLINE"
	C["font"].filger_font_shadow = true

	C["font"].stylization_font = locale_font
	C["font"].stylization_font_size = 12
	C["font"].stylization_font_style = ""
	C["font"].stylization_font_shadow = true

	C["font"].bags_font = locale_font
	C["font"].bags_font_size = 11
	C["font"].bags_font_style = "OUTLINE"
	C["font"].bags_font_shadow = true

	C["font"].tooltip_header_font_size = 14
	C["font"].tooltip_font_size = 12
	C["font"].bubble_font_size = 14
end