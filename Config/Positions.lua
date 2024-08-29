local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Position options
--	BACKUP THIS FILE BEFORE UPDATING!
----------------------------------------------------------------------------------------
C["position"] = {
	-- ActionBar positions
    ["mainBars"] = { "BOTTOM", UIParent, "BOTTOM", 0, 200 },            -- Bottom bars
	["rightBars"] = { "RIGHT", UIParent, "RIGHT", 0, 0 },                 -- Right bars
    ["bottomBars"] = { "BOTTOM", UIParent, "BOTTOM", 0, 40 },            -- Bottom bars
	["petBar"] = {"BOTTOM", UIParent, "BOTTOM", 0, 100},                    -- Horizontal pet bar
	["stanceBar"] = { "BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 0 }, -- Stance bar
	["vehicleBar"] = { "BOTTOMRIGHT", ActionButton1, "BOTTOMLEFT", -3, 0 }, -- Vehicle button
	["extraButton"] = { "BOTTOM", UIParent, "BOTTOM", 0, 150 },     -- Extra action button
	["zoneButton"] = { "BOTTOM", UIParent, "BOTTOM", 0, 150 },      -- Zone action button
	["microMenu"] = { "TOPLEFT", UIParent, "TOPLEFT", 2, -2 },            -- Micro menu
	-- UnitFrame positions
	unitframes = {
		["player"] = { "CENTER", PlayerFrame, "CENTER", 0, 0 },      -- Player frame
		["classResources"] = {"BOTTOM", "RefineUI_Player", "TOP", 0, 9},  -- PlayerResources bar
		["target"] = { "LEFT", "RefineUI_Player", "RIGHT", 165, 0 },          -- Target frame
		["targetTarget"] = { "TOPRIGHT", "RefineUI_Target", "BOTTOMRIGHT", 0, -11 }, -- ToT frame
		["pet"] = { "LEFT", "RefineUI_Player", "RIGHT", 6, 0 },               -- Pet frame
		["focus"] = { "RIGHT", "RefineUI_Player", "LEFT", -165, 0 },          -- Focus frame
		["focusTarget"] = { "TOPLEFT", "RefineUI_Target", "BOTTOMLEFT", 0, -11 }, -- Focus target frame
		["party"] = { "CENTER", UIParent, "CENTER", -550, 2 },           -- Heal layout Party frames
		["raid"] = { "CENTER", UIParent, "CENTER", -550, 0 },            -- Heal layout Raid frames
		["arena"] = { "BOTTOMRIGHT", UIParent, "RIGHT", -60, -70 },      -- Arena frames
		["boss"] = { "CENTER", UIParent, "CENTER", 800, 0 },             -- Boss frames
		["tank"] = { "BOTTOMLEFT", "MainActionBarAnchor", "BOTTOMRIGHT", 10, 18 }, -- Tank frames
		["playerPortrait"] = { "TOPRIGHT", "RefineUI_Player", "TOPLEFT", -12, 27 }, -- Player Portrait
		["targetPortrait"] = { "TOPLEFT", "RefineUI_Target", "TOPRIGHT", 12, 27 }, -- Target Portrait
		["playerCastbar"] = { "TOP", "RefineUI_Player", "BOTTOM", 0, -7 },   -- Player Castbar
		["targetCastbar"] = { "TOP", "RefineUI_Target", "BOTTOM", 0, -7 },   -- Target Castbar
		["focusCastbar"] = { "TOP", "RefineUI_Focus", "BOTTOM", 0, -9 },     -- Focus Castbar icon
	},
	-- Filger positions
	filger = {
		["playerBuffIcon"] = { "CENTER", "UIParent", "CENTER", -224, 0 },  -- "P_BUFF_ICON"
		["playerProcIcon"] = { "CENTER", "UIParent", "CENTER", 224, 0 },   -- "P_PROC_ICON"
		["specialProcIcon"] = { "BOTTOMRIGHT", "RefineUI_Player", "TOPRIGHT", 2, 213 }, -- "SPECIAL_P_BUFF_ICON"
		["targetDebuffIcon"] = { "BOTTOMLEFT", "RefineUI_Target", "TOPLEFT", -2, 213 }, -- "T_DEBUFF_ICON"
		["targetBuffIcon"] = { "BOTTOMLEFT", "RefineUI_Target", "TOPLEFT", -2, 253 }, -- "T_BUFF"
		["pveDebuff"] = { "BOTTOMRIGHT", "RefineUI_Player", "TOPRIGHT", 2, 253 }, -- "PVE/PVP_DEBUFF"
		["pveCc"] = { "TOPLEFT", "RefineUI_Player", "BOTTOMLEFT", -2, -44 },     -- "PVE/PVP_CC"
		["cooldown"] = { "BOTTOMRIGHT", "RefineUI_Player", "TOPRIGHT", 63, 17 },  -- "COOLDOWN"
		["targetBar"] = { "BOTTOMLEFT", "RefineUI_Target", "BOTTOMRIGHT", 9, -41 }, -- "T_DE/BUFF_BAR"
	},
	-- Miscellaneous positions
	["minimap"] = { "CENTER", MinimapCluster, "CENTER", 0, 0 },             -- Minimap
	["minimapButtons"] = { "BOTTOMLEFT", Minimap, "TOPLEFT", -2, 8 },            -- Minimap buttons
	["tooltip"] = { "BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5 },                   -- Tooltip
	["vehicle"] = { "BOTTOM", Minimap, "TOP", 0, 27 },                            -- Vehicle frame
	["ghost"] = { "BOTTOM", Minimap, "TOP", 0, 5 },                               -- Ghost frame
	["bag"] = { "BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5 },                       -- Bag
	["bank"] = { "LEFT", UIParent, "LEFT", 23, 150 },                             -- Bank
	["archaeology"] = { "BOTTOMRIGHT", Minimap, "TOPRIGHT", 2, 5 },               -- Archaeology frame
	["autoButton"] = { "BOTTOMLEFT", Minimap, "TOPLEFT", -2, 27 },               -- Quest Item auto button
	["autoitembar"] = { "BOTTOM", ChatFrame1, "TOP", 0, 4 },               -- Quest Item auto button
	["chat"] = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 40 },                  -- Chat
	["bnPopup"] = { "BOTTOMLEFT", ChatFrame1, "TOPLEFT", -3, 27 },               -- Battle.net popup
	["bwtimeline"] = { "LEFT", "PartyAnchor", "RIGHT", 50, 0 },                   -- Battle.net popup
	-- ["map"] = {"BOTTOM", UIParent, "BOTTOM", 0, 320},								-- Map
	["quest"] = { "TOPLEFT", UIParent, "TOPLEFT", 3, -3 },                        -- Quest log
	["loot"] = { "TOPLEFT", UIParent, "TOPLEFT", 245, -220 },                     -- Loot
	["groupLoot"] = { "TOP", "UIParent", "TOP", 0, -50 },                        -- Group roll loot
	["threatMeter"] = { "BOTTOMLEFT", "MainActionBarAnchor", "BOTTOMRIGHT", 7, 16 }, -- Threat meter
	["bgScore"] = { "BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 10, -2 },       -- BG stats
	["raidCooldown"] = { "TOPLEFT", ChatFrame1, "TOPRIGHT", 7, 1 },              -- Raid cooldowns
	["enemyCooldown"] = { "BOTTOMLEFT", "RefineUI_Player", "TOPRIGHT", 33, 62 },      -- Enemy cooldowns
	["pulseCooldown"] = { "CENTER", UIParent, "CENTER", 0, 0 },                  -- Pulse cooldowns
	["playerBuffs"] = { "TOPRIGHT", UIParent, "TOPRIGHT", -3, -3 },              -- Player buffs
	["selfBuffs"] = { "CENTER", UIParent, "CENTER", 0, 0 },                    -- Self buff reminder
	["raidBuffs"] = { "TOPLEFT", Minimap, "BOTTOMLEFT", 0, -10},                 -- Raid buff reminder
	["raidUtility"] = { "TOP", UIParent, "TOP", 0, 0 },                          -- Raid utility
	["topPanel"] = { "TOP", UIParent, "TOP", 0, -21 },                           -- Top panel
	["achievement"] = { "TOP", UIParent, "TOP", 0, -21 },                         -- Achievements frame
	["uierror"] = { "TOP", UIParent, "TOP", 0, -30 },                             -- Errors frame
	["talkingHead"] = { "TOP", UIParent, "TOP", 0, -21 },                        -- Talking Head
	["altPowerBar"] = { "TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -7 }, -- Alt power bar
	["uiwidgetTop"] = { "TOP", UIParent, "TOP", 1, -21 },                        -- Top Widget
	["uiwidgetBelow"] = { "TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -15 }, -- Below Widget
}
