local R, C, L = unpack(RefineUI)

-- Helper function to create sections
local function CreateSection(name)
    C[name] = C[name] or {}
    return setmetatable({}, {
        __newindex = function(t, k, v)
            rawset(C[name], k, v)
        end
    })
end

----------------------------------------------------------------------------------------
-- General options
----------------------------------------------------------------------------------------
local general = CreateSection("general")

general.autoScale = true          -- Auto UI Scale
general.uiScale = 0.53333         -- Your value (between 0.2 and 1) if "autoScale" is disabled
general.moveBlizzard = false      -- Move some Blizzard frames
general.vehicleMouseover = false  -- Vehicle frame on mouseover
general.minimizeMouseover = false -- Mouseover for quest minimize button
general.hideBanner = true         -- Hide Boss Banner Loot Frame
general.hideTalkingHead = true    -- Hide Talking Head Frame

----------------------------------------------------------------------------------------
-- Media options
----------------------------------------------------------------------------------------
local media = CreateSection("media")

media.path = "Interface\\AddOns\\RefineUI\\Media\\"
media.normalFont = [[Interface\AddOns\RefineUI\Media\Fonts\ITCAvantGardeStd-Demi.ttf]] -- Normal font
media.normalFontStyle = "OUTLINE"                                               -- Pixel font style ("MONOCHROMEOUTLINE" or "OUTLINE")
media.normalFontSize = 16                                                       -- Pixel font size for those places where it is not specified
media.boldFont = [[Interface\AddOns\RefineUI\Media\Fonts\ITCAvantGardeStd-Bold.ttf]] -- Bold font
media.pixelFont = [[Interface\AddOns\RefineUI\Media\Fonts\m5x7.ttf]]            -- Pixel font
media.pixelFontStyle = "MONOCHROMEOUTLINE"                                      -- Pixel font style ("MONOCHROMEOUTLINE" or "OUTLINE")
media.pixelFontSize = 16                                                        -- Pixel font size for those places where it is not specified
media.blank = [[Interface\AddOns\RefineUI\Media\Textures\RefineUIBlank.tga]]    -- Texture for borders
media.texture = [[Interface\AddOns\RefineUI\Media\Textures\RefineUIBlank.tga]]  -- Texture for status bars
media.border = [[Interface\AddOns\RefineUI\Media\Textures\RefineBorder.blp]]
media.highlight = [[Interface\AddOns\RefineUI\Media\Textures\Highlight.tga]]    -- Texture for debuffs highlight
media.whispSound = [[Interface\AddOns\RefineUI\Media\Sounds\Whisper.ogg]]       -- Sound for whispers
media.warningSound = [[Interface\AddOns\RefineUI\Media\Sounds\Warning.ogg]]     -- Sound for warning
media.procSound = [[Interface\AddOns\RefineUI\Media\Sounds\Proc.ogg]]           -- Sound for procs
media.classBorderColor = {R.color.r, R.color.g, R.color.b, 1}                 -- Color for class borders
media.borderColor = { 0.5, 0.5, 0.5, 1 }                                        -- Color for borders
media.backdropColor = { 0.094, 0.094, 0.094, .75 }                              -- Color for borders backdrop
media.backdropAlpha = 0.75                                                       -- Alpha for transparent backdrop

----------------------------------------------------------------------------------------
-- Unit Frames options
----------------------------------------------------------------------------------------
local unitframes = CreateSection("unitframes")

R.UF = {}
unitframes.frameWidth = 180         -- Player and Target width
unitframes.healthHeight = 20        -- Additional height for health
unitframes.powerHeight = 4          -- Additional height for power
unitframes.castbarWidth = 180       -- Player and Target castbar width
unitframes.castbarHeight = 16       -- Player and Target castbar height
unitframes.colorValue = false        -- Health/mana value is colored
unitframes.barColorValue = true     -- Health bar color by current health remaining
unitframes.unitCastbar = true        -- Show castbars
unitframes.castbarLatency = true     -- Castbar latency
unitframes.castbarTicks = true       -- Castbar ticks
unitframes.showPet = true            -- Show pet frame
unitframes.showTargetTarget = false  -- Show target target frame
unitframes.showBoss = true           -- Show boss frames
unitframes.bossOnRight = true        -- Boss frames on the right
unitframes.showArena = true          -- Show arena frames
unitframes.arenaOnRight = true       -- Arena frames on the right
unitframes.auraTimer = true          -- Unit Frame Aura Timer
unitframes.iconsCombat = false       -- Combat icon
unitframes.iconsResting = false      -- Resting icon
unitframes.pluginSmoothBar = true    -- Smooth bar
unitframes.pluginEnemySpec = false   -- Enemy specialization in BG and Arena
unitframes.pluginAbsorbs = false      -- Absorbs value on player frame

----------------------------------------------------------------------------------------
-- Auras/Buffs/Debuffs options
----------------------------------------------------------------------------------------
local auras = CreateSection("auras")

auras.playerBuffSize = 48            -- Player buffs size
auras.playerBuffSpacing = 4           -- Player buffs spacing
auras.playerDebuffSize = 32          -- Debuffs size on unitframes
auras.showSpiral = true               -- Spiral on aura icons
auras.showTimer = true                -- Show cooldown timer on aura icons
auras.playerAuraOnly = false          -- Only your debuff on target frame
auras.debuffColorType = true          -- Color debuff by type
auras.debuffSize = 20                 -- Debuffs size on unitframes

----------------------------------------------------------------------------------------
-- Raid Frames options
----------------------------------------------------------------------------------------
local group = CreateSection("group")

group.showParty = true                 -- Show party frames
group.showRaid = true                  -- Show raid frames
group.showTarget = false               -- Show target frames
group.showPet = false                  -- Show pet frames
group.soloMode = false                 -- Show player frame always
group.playerInParty = true             -- Show player frame in party
group.raidGroups = 5                   -- Number of groups in raid
group.autoPosition = "DYNAMIC"         -- Auto reposition raid frame
group.partyVertical = true              -- Vertical party (only for Heal layout)
group.raidGroupsVertical = true        -- Vertical raid groups (only for Heal layout)
group.verticalHealth = false            -- Vertical orientation of health (only for Heal layout)
group.byRole = true                     -- Sorting players in group by role
group.aggroBorder = true                -- Aggro border
group.deficitHealth = false             -- Raid deficit health
group.hideHealthValue = false          -- Hide raid health value
group.alphaHealth = false               -- Alpha of healthbars when 100%hp
group.showRange = true                  -- Show range opacity for raidframes
group.rangeAlpha = 0.5                  -- Alpha of unitframes when unit is out of range
group.iconsRole = true                  -- Role icon on frames
group.iconsRaidMark = true              -- Raid mark icons on frames
group.iconsReadyCheck = true            -- Ready check icons on frames
group.iconsLeader = true                -- Leader icon and assistant icon on frames
group.iconsSummon = true                -- Summon icons on frames
group.iconsPhase = true                 -- Phase icons on frames
group.pluginDebuffHighlight = true      -- Show texture for dispellable debuff
group.pluginAuraWatch = true            -- Raid debuff icons (from the list)
group.pluginAuraWatchTimer = false      -- Timer on raid debuff icons
group.pluginDebuffHighlightIcon = true  -- Show dispellable debuff icon
group.pluginPvpDebuffs = false          -- Show PvP debuff icons (from the list)
group.pluginHealPredict = true          -- Incoming heal bar on raid frame
group.pluginOverAbsorb = false          -- Show over absorb bar on raid frame
group.pluginOverHealAbsorb = false      -- Show over heal absorb on raid frame (from enemy debuffs)
group.pluginAutoResurrection = false    -- Auto cast resurrection on middle-click (doesn't work with Clique)
group.partyWidth = 160                   -- Party width
group.partyHealthHeight = 20                  -- Party height
group.partyPowerHeight = 3                    -- Party power height
group.raidWidth = 140                    -- Raid width
group.raidHealthHeight = 18                    -- Raid height
group.raidPowerHeight = 2                 -- Raid power height

----------------------------------------------------------------------------------------
-- ActionBar options
----------------------------------------------------------------------------------------
local actionbars = CreateSection("actionbars")

actionbars.enable = true               -- Enable actionbars
actionbars.hotkey = false              -- Show hotkey on buttons
actionbars.macro = false               -- Show macro name on buttons
actionbars.showGrid = false            -- Show empty action bar buttons
actionbars.buttonSize = 36             -- Buttons size
actionbars.buttonSpace = 8             -- Buttons space
actionbars.classcolorBorder = false    -- Enable classcolor border
actionbars.hideHighlight = false       -- Hide proc highlight
actionbars.mainBarsMouseover = false   -- Bottom bars on mouseover
actionbars.rightBarsMouseover = true   -- Right bars on mouseover
actionbars.bottomBarsMouseover = true  -- Bottom bars on mouseover
actionbars.petBarHide = false          -- Hide pet bar
actionbars.petBarHorizontal = true     -- Enable horizontal pet bar
actionbars.petBarMouseover = false     -- Pet bar on mouseover (only for horizontal pet bar)
actionbars.stanceBarHide = false       -- Hide stance bar
actionbars.stanceBarHorizontal = true  -- Enable horizontal stance bar
actionbars.stanceBarMouseover = true   -- Stance bar on mouseover (only for horizontal stance bar)
actionbars.stanceBarMouseoverAlpha = 0 -- Stance bar mouseover alpha
actionbars.editor = false               -- Allow to move and change each panel individually

----------------------------------------------------------------------------------------
-- AutoBar options
----------------------------------------------------------------------------------------
local autoitembar = CreateSection("autoitembar")

autoitembar.enable = true                  -- Enable actionbars
autoitembar.buttonSize = 36             -- Buttons size
autoitembar.buttonSpace = 8             -- Buttons space
autoitembar.consumable_mouseover = true    -- Set to false to always show the bar
autoitembar.min_consumable_item_level = 60 -- Set the minimum item level for consumables

----------------------------------------------------------------------------------------
-- Chat options
----------------------------------------------------------------------------------------
local chat = CreateSection("chat")

chat.enable = true                     -- Enable chat
chat.width = 600                       -- Chat width
chat.height = 300                      -- Chat height
chat.filter = true                     -- Removing some systems spam
chat.spam = false                      -- Removing some players spam (gold/portals/etc)
chat.chatBar = false                   -- Lite Button Bar for switch chat channel
chat.chatBarMouseOver = false          -- Lite Button Bar on mouseover
chat.whisperSound = true               -- Sound when whisper
chat.combatLog = true                  -- Show CombatLog tab
chat.tabsMouseOver = true              -- Chat tabs on mouseover
chat.sticky = true                     -- Remember last channel
chat.damageMeterSpam = true            -- Merge damage meter spam in one line-link
chat.lootIcons = true                  -- Icons for loot
chat.roleIcons = true                  -- Role Icons
chat.history = true                     -- Chat history
chat.hideCombat = false                -- Hide chat in combat
chat.customTimeColor = true            -- Enable custom timestamp coloring
chat.timeColor = { 1, 1, 0 }           -- Timestamp coloring

----------------------------------------------------------------------------------------
-- Tooltip options
----------------------------------------------------------------------------------------
local tooltip = CreateSection("tooltip")

tooltip.cursor = true          -- Tooltip above cursor
tooltip.hidebuttons = false    -- Hide tooltip for actions bars
tooltip.hide_combat = true     -- Hide tooltip in combat
-- Plugins
tooltip.title = false          -- Player title in tooltip
tooltip.realm = true           -- Player realm name in tooltip
tooltip.rank = true            -- Player guild-rank in tooltip
tooltip.target = true          -- Target player in tooltip
tooltip.average_lvl = false    -- Average items level
tooltip.show_shift = true      -- Show items level and spec when Shift is pushed
tooltip.raid_icon = false      -- Raid icon
tooltip.unit_role = false      -- Unit role in tooltip
tooltip.mount = true           -- Show source of mount

----------------------------------------------------------------------------------------
-- Minimap options
----------------------------------------------------------------------------------------
local minimap = CreateSection("minimap")

minimap.enable = true                  -- Enable minimap
minimap.onTop = false                   -- Move minimap on top right corner
minimap.trackingIcon = true             -- Tracking icon
minimap.garrisonIcon = false            -- Covenant icon
minimap.size = 294                     -- Minimap size
minimap.addonButtonSize = 28           -- Minimap Addon Button size
minimap.hideCombat = false              -- Hide minimap in combat
minimap.toggleMenu = false              -- Show toggle menu
minimap.zoomReset = true                -- Show toggle menu
minimap.resetTime = 15                  -- Show toggle menu
minimap.bgMapStylization = true         -- BG map stylization
minimap.fogOfWar = false                -- Remove fog of war on World Map

----------------------------------------------------------------------------------------
-- Loot options
----------------------------------------------------------------------------------------
local loot = CreateSection("loot")

loot.icon_size = 22         -- Icon size
loot.width = 221            -- Loot window width
loot.auto_greed = false     -- Push "greed" or "disenchant" button for green item roll at max level
loot.auto_confirm_de = true -- Auto confirm disenchant and take BoP loot

----------------------------------------------------------------------------------------
-- Loot Filter options
----------------------------------------------------------------------------------------
local lootfilter = CreateSection("lootfilter")

lootfilter.enable = true                                -- Enable loot frame
lootfilter.min_quality = 3                              -- Minimum quality to always loot (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
-- User Configuration
lootfilter.junk_minprice = 10                           -- Minimum value (in gold) of grey items to loot
lootfilter.tradeskill_subtypes = { "Parts", "Jewelcrafting", "Cloth", "Leather", "Metal & Stone", "Cooking", "Herb",
    "Elemental", "Other", "Enchanting", "Inscription" } -- Tradeskill subtypes to always loot
lootfilter.tradeskill_min_quality = 1                   -- Quality cap for autolooting tradeskill items (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
lootfilter.gear_min_quality = 2                         -- Minimum quality of BoP weapons and armor to autoloot (0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic)
lootfilter.gear_unknown = true                          -- Override other gear settings to loot unknown appearances
lootfilter.gear_price_override = 20                     -- Minimum vendor price (in gold) to loot gear regardless of other criteria


----------------------------------------------------------------------------------------
-- Skins options
----------------------------------------------------------------------------------------
local skins = CreateSection("skins")

skins.blizzardFrames = true             -- Blizzard frames skin
skins.bubbles = true                     -- Skin Blizzard chat bubbles
skins.minimapButtons = true              -- Skin addons icons on minimap
skins.minimapButtonsMouseOver = true     -- Addons icons on mouseover

----------------------------------------------------------------------------------------
-- Auras/Buffs/Debuffs options
----------------------------------------------------------------------------------------
local aura = CreateSection("aura")

aura.playerBuffSize = 48                -- Player buffs size
aura.playerBuffSpacing = 4               -- Player buffs spacing
aura.playerDebuffSize = 32              -- Debuffs size on unitframes
aura.buffSize = 24                       -- Buffs size on unitframes
aura.debuffSize = 24                     -- Debuffs size on unitframes
aura.showSpiral = true                   -- Spiral on aura icons
aura.showTimer = true                    -- Show cooldown timer on aura icons
aura.playerAuras = true                  -- Auras on player frame
aura.targetAuras = true                  -- Auras on target frame
aura.focusDebuffs = false                 -- Debuffs on focus frame
aura.fotDebuffs = false                   -- Debuffs on focustarget frame
aura.petDebuffs = false                   -- Debuffs on pet frame
aura.totDebuffs = false                   -- Debuffs on targettarget frame
aura.bossAuras = true                     -- Auras on boss frame
aura.bossDebuffs = 0                      -- Number of debuffs on the boss frames
aura.bossBuffs = 3                        -- Number of buffs on the boss frames
aura.playerAuraOnly = false               -- Only your debuff on target frame
aura.debuffColorType = true               -- Color debuff by type
aura.classcolorBorder = false             -- Enable classcolor border for player buffs
aura.castBy = true                        -- Show who cast a buff/debuff in its tooltip

----------------------------------------------------------------------------------------
-- Buffs reminder options
----------------------------------------------------------------------------------------
local reminder = CreateSection("reminder")

reminder.soloBuffsEnable = true          -- Enable buff reminder
reminder.soloBuffsSound = false          -- Enable warning sound notification for buff reminder
reminder.soloBuffsSize = 64              -- Icon size
reminder.soloBuffsFlash = true           -- Icon flash
reminder.raidBuffsEnable = true          -- Show missing raid buffs
reminder.raidBuffsAlways = true          -- Show frame always (default show only in raid)
reminder.raidBuffsSize = 28              -- Icon size
reminder.raidBuffsAlpha = 1              -- Transparent icons when the buff is present

----------------------------------------------------------------------------------------
-- Nameplate options
----------------------------------------------------------------------------------------
local nameplate = CreateSection("nameplate")

nameplate.enable = true                                -- Enable nameplate
nameplate.width = 80                                   -- Nameplate width
nameplate.height = 9                                   -- Nameplate height
nameplate.adWidth = 0                                  -- Additional width for selected nameplate
nameplate.adHeight = 0                                 -- Additional height for selected nameplate
nameplate.alpha = .75                                  -- Non-target nameplate alpha
nameplate.combat = true                                -- Automatically hide nameplates in combat
nameplate.healthValue = true                           -- Numeral health value
nameplate.showCastbarName = true                       -- Show castbar name
nameplate.classIcons = false                           -- Icons by class in PvP
nameplate.nameAbbrev = true                            -- Display abbreviated names
nameplate.shortName = true                             -- Replace names with short ones
nameplate.clamp = true                                 -- Clamp nameplates to the top of the screen when outside of view
nameplate.trackDebuffs = true                          -- Show your debuffs (from the list)
nameplate.trackBuffs = false                           -- Show dispellable enemy buffs and buffs from the list
nameplate.aurasSize = 14                               -- Auras size
nameplate.auraTimer = true                             -- Show cooldown timer on aura icons
nameplate.healerIcon = false                           -- Show icon above enemy healers nameplate in battlegrounds
nameplate.totemIcons = false                           -- Show icon above enemy totems nameplate
nameplate.targetGlow = true                            -- Show glow texture for target
nameplate.targetIndicator = true                       -- Show target arrows for target
nameplate.onlyName = true                              -- Show only name for friendly units
nameplate.quests = true                               -- Show quest icon
nameplate.lowHealth = false                            -- Show red border when low health
nameplate.lowHealthValue = 0.2                         -- Value for low health (between 0.1 and 1)
nameplate.lowHealthColor = { 0.8, 0, 0 }               -- Color for low health border
nameplate.targetBorder = true                          -- Color for low health border
nameplate.targetBorderColor = { .8, .8, .8 }           -- Color for low health border
nameplate.castColor = false                            -- Show color border for casting important spells
nameplate.kickColor = false                            -- Change cast color if interrupt on cd
-- Threat
nameplate.enhanceThreat = true                         -- Enable threat feature, automatically changes by your role
nameplate.goodColor = { 0.2, 0.8, 0.2 }                -- Good threat color
nameplate.nearColor = { 1, 1, 0 }                      -- Near threat color
nameplate.badColor = { 1, 0, 0 }                       -- Bad threat color
nameplate.offtankColor = { 0, 0.5, 1 }                 -- Offtank threat color
nameplate.goodColorbg = { 0.2 * .2, 0.8 * .2, 0.2 * .2 } -- Good threat color
nameplate.nearColorbg = { 1 * .2, 1 * .2, 0 * .2 }     -- Near threat color
nameplate.badColorbg = { 1 * .2, 0 * .2, 0 * .2 }      -- Bad threat color
nameplate.offtankColorbg = { 0 * .2, 0.5 * .2, 1 * .2 } -- Offtank threat color
nameplate.extraColor = { 1, 0.3, 0 }                   -- Explosive and Spiteful affix color
nameplate.mobColorEnable = false                       -- Change color for important mobs in dungeons
nameplate.mobColor = { 0, 0.5, 0.8 }                    -- Color for mobs

----------------------------------------------------------------------------------------
-- Automation options
----------------------------------------------------------------------------------------
local automation = CreateSection("automation")

automation.autoRelease = true           -- Auto release the spirit in battlegrounds
automation.autoScreenshot = false       -- Take screenshot when player get achievement
automation.autoAcceptInvite = false     -- Auto accept invite
automation.autoZoneTrack = true         -- Auto-Track Quests by Zone
automation.autoCollapse = "NONE"        -- Auto collapse Objective Tracker (RAID, RELOAD, SCENARIO, NONE)
automation.autoSkipCinematic = true     -- Auto skip cinematics/movies that have been seen (disabled if hold Ctrl)
automation.autoSetRole = false          -- Auto set your role
automation.autoCancelBadBuffs = false   -- Auto cancel annoying holiday buffs (from the list)
automation.autoResurrection = false     -- Auto confirm resurrection
automation.autoWhisperInvite = false    -- Auto invite when whisper keyword
automation.inviteKeyword = "inv +"      -- List of keyword (separated by space)
automation.autoRepair = true            -- Auto repair
automation.autoGuildRepair = true       -- Auto repair with guild funds first (if able)

----------------------------------------------------------------------------------------
-- Filger options
----------------------------------------------------------------------------------------
local filger = CreateSection("filger")

filger.enable = true           -- Enable Filger
filger.show_tooltip = false    -- Show tooltip
filger.expiration = true       -- Sort cooldowns by expiration time
-- Elements
filger.show_buff = true        -- Player buffs
filger.show_proc = true        -- Player procs
filger.show_debuff = false     -- Debuffs on target
filger.show_aura_bar = false   -- Aura bars on target
filger.show_special = true     -- Special buffs on player
filger.show_pvp_player = false -- PvP debuffs on player
filger.show_pvp_target = false -- PvP auras on target
filger.show_cd = true         -- Cooldowns
-- Icons size
filger.buffs_size = 48         -- Buffs size
filger.buffs_space = 3         -- Buffs space
filger.pvp_size = 60           -- PvP auras size
filger.pvp_space = 3           -- PvP auras space
filger.cooldown_size = 30      -- Cooldowns size
filger.cooldown_space = 3      -- Cooldowns space
-- Testing
filger.test_mode = false       -- Test icon mode
filger.max_test_icon = 5       -- Number of icons in test mode

----------------------------------------------------------------------------------------
-- Scrolling Combat Text options
----------------------------------------------------------------------------------------
local sct = CreateSection("sct")

sct.enable = true            -- Global enable combat text
sct.overkill = false         -- Use blizzard damage/healing output (above mob/player head)
sct.x_offset = 0             -- Horizontal offset for text
sct.y_offset = 35            -- Vertical offset for text
sct.default_color = "ffff00" -- Default text color
sct.alpha = 1              -- Text transparency

-- Off-target options
sct.offtarget_enable = true -- Enable off-target text
sct.offtarget_size = 12     -- Off-target text size
sct.offtarget_alpha = 0.6   -- Off-target text transparency

-- Personal text options
sct.personal_enable = false           -- Enable personal text
sct.personal_only = false             -- Show only personal text
sct.personal_default_color = "ffff00" -- Personal text color
sct.personal_x_offset = 0             -- Personal text horizontal offset
sct.personal_y_offset = 0             -- Personal text vertical offset

-- Strata options
sct.strata_enable = false       -- Enable custom strata
sct.strata_target = "HIGH"      -- Target strata level
sct.strata_offtarget = "MEDIUM" -- Off-target strata level

-- Icon options
sct.icon_enable = true      -- Enable icons
sct.icon_scale = 1          -- Icon scale
sct.icon_shadow = true      -- Show icon shadow
sct.icon_position = "RIGHT" -- Icon position relative to text
sct.icon_x_offset = 0       -- Icon horizontal offset
sct.icon_y_offset = 0       -- Icon vertical offset

-- Truncate options
sct.truncate_enable = true -- Enable text truncation
sct.truncate_letter = true -- Use letter abbreviations (K, M, etc.)
sct.truncate_comma = true  -- Use comma for thousands separator

-- Size options
sct.size_crits = true                  -- Enlarge critical hits
sct.size_crit_scale = 1                -- Critical hit scale factor
sct.size_miss = false                  -- Enlarge misses
sct.size_miss_scale = 1                -- Miss scale factor
sct.size_small_hits = true             -- Reduce size of small hits
sct.size_small_hits_scale = 0.9        -- Small hit scale factor
sct.size_small_hits_hide = true        -- Hide small hits
sct.size_autoattack_crit_sizing = true -- Use crit sizing for auto-attack crits

-- Animation options
sct.animations_ability = "verticalUp"        -- Animation for ability text
sct.animations_crit = "verticalUp"           -- Animation for critical hits
sct.animations_miss = "verticalUp"           -- Animation for misses
sct.animations_autoattack = "verticalUp"     -- Animation for auto-attacks
sct.animations_autoattackcrit = "verticalUp" -- Animation for auto-attack crits
sct.animations_speed = 1                     -- Animation speed

-- Personal animation options
sct.personalanimations_normal = "verticalUp" -- Animation for normal personal text
sct.personalanimations_crit = "verticalUp"   -- Animation for personal crits
sct.personalanimations_miss = "verticalUp"   -- Animation for personal misses

----------------------------------------------------------------------------------------
-- Miscellaneous options
----------------------------------------------------------------------------------------
local misc = CreateSection("misc")

misc.afk = true  -- Spin camera while afk
misc.stickyTargeting = true -- Sticky targeting in combat

----------------------------------------------------------------------------------------
-- Combat Crosshair options
----------------------------------------------------------------------------------------
local combatcrosshair = CreateSection("combatcrosshair")

combatcrosshair.enable = true                                                    -- Enable combat crosshair
combatcrosshair.texture = [[Interface\AddOns\RefineUI\Media\Textures\Crosshair.tga]] -- Crosshair texture
combatcrosshair.color = { 1, 1, 1 }                                              -- Crosshair color (RGB)
combatcrosshair.size = 20                                                        -- Crosshair size
combatcrosshair.offsetx = 0                                                      -- Horizontal offset
combatcrosshair.offsety = -25                                                    -- Vertical offset

----------------------------------------------------------------------------------------
-- Combat Cursor options
----------------------------------------------------------------------------------------
local combatcursor = CreateSection("combatcursor")
combatcursor.enable = true                                                       -- Enable combat cursor
combatcursor.texture = [[Interface\AddOns\RefineUI\Media\Textures\CursorCircle.blp]] -- Cursor texture
combatcursor.color = { 1, 1, 1, 1 }                                              -- Cursor color (RGBA)
combatcursor.size = 50                                                           -- Cursor size

----------------------------------------------------------------------------------------
-- BigWigs Timeline options
----------------------------------------------------------------------------------------
local bwtimeline = CreateSection("bwtimeline")

bwtimeline.enable = true           -- Enable BigWigs Timeline
bwtimeline.refresh_rate = 0.05     -- Refresh rate for the timeline
bwtimeline.smooth_queueing = true  -- Enable smooth queueing
bwtimeline.bw_alerts = true        -- Enable BigWigs alerts
bwtimeline.invisible_queue = false -- Enable BigWigs alerts

-- Bar settings
bwtimeline.bar = {}
bwtimeline.bar_reverse = false                  -- Reverse bar direction
bwtimeline.bar_length = 316                     -- Length of the bar
bwtimeline.bar_width = 8                        -- Width of the bar
bwtimeline.bar_max_time = 20                    -- Maximum time displayed on the bar
bwtimeline.bar_hide_out_of_combat = true        -- Hide bar when out of combat
bwtimeline.bar_has_ticks = false                -- Show ticks on the bar
bwtimeline.bar_above_icons = true               -- Display bar above icons
bwtimeline.bar_tick_spacing = 5                 -- Spacing between ticks
bwtimeline.bar_tick_length = 20                 -- Length of ticks
bwtimeline.bar_tick_width = 1                   -- Width of ticks
bwtimeline.bar_tick_color = { 1, 1, 1, 1 }      -- Color of ticks (RGBA)
bwtimeline.bar_tick_text = true                 -- Show text on ticks
bwtimeline.bar_tick_text_font_size = 10         -- Font size of tick text
bwtimeline.bar_tick_text_position = "LEFT"      -- Position of tick text
bwtimeline.bar_tick_text_color = { 1, 1, 1, 1 } -- Color of tick text (RGBA)

-- Icon settings
bwtimeline.icons = {}
bwtimeline.icons_width = 35                      -- Width of icons
bwtimeline.icons_height = 35                     -- Height of icons
bwtimeline.icons_spacing = 3                     -- Adjust this value to increase/decrease spacing
bwtimeline.icons_duration = true                 -- Show duration on icons
bwtimeline.icons_duration_position = "CENTER"    -- Position of duration text on icons
bwtimeline.icons_duration_color = { 1, 1, 1, 1 } -- Color of duration text (RGBA)
bwtimeline.icons_name = true                     -- Show name on icons
bwtimeline.icons_name_position = "RIGHT"         -- Position of name text on icons
bwtimeline.icons_name_color = { 1, 1, 1, 1 }     -- Color of name text (RGBA)
bwtimeline.icons_name_acronym = false            -- Use acronyms for names
bwtimeline.icons_name_number = false             -- Show number on icons

----------------------------------------------------------------------------------------
-- Trade options
----------------------------------------------------------------------------------------
local trade = CreateSection("trade")

trade.profession_tabs = true -- Professions tabs on TradeSkill frames
trade.already_known = true   -- Colorizes recipes/mounts/pets/toys that is already known
trade.sum_buyouts = true     -- Sum up all current auctions