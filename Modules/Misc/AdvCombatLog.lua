----------------------------------------------------------------------------------------
--	Adv Combat Log for RefineUI
--	This module analyzes the combat log and outputs messages based on configured events.
--  It tracks taunts, interrupts, dispels, crowd control, deaths, and resurrections.
--  It also includes damage tracking over a short period to provide context for death events.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Constants and Variables
----------------------------------------------------------------------------------------
local DAMAGE_HISTORY_SECONDS = 5                 -- How many seconds of damage history to keep
local DAMAGE_HISTORY_SIZE = 10                   -- Adjust this value based on your needs (number of entries to track)
local THROTTLE_INTERVAL = 0.1                    -- Minimum interval between processing the same event type for the same units
local PLAYER_FLAG = COMBATLOG_OBJECT_TYPE_PLAYER -- Constant for player flag

-- Local variables
local recentDamage = {}      -- Table to store recent damage taken by units
local classColorCache = {}   -- Cache for class colors
local spellInfoCache = {}    -- Cache for spell information (icon and link)
local eventHandlers = {}     -- Table of functions to handle combat log events
local lastProcessedTime = {} -- Table to track the last time an event was processed (for throttling)


----------------------------------------------------------------------------------------
--	Upvalues
----------------------------------------------------------------------------------------
local GetTime = GetTime
local GetSpellInfo = C_Spell.GetSpellInfo
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local UnitGUID = UnitGUID
local UnitReaction = UnitReaction
local bit_band = bit.band
local table_insert = table.insert
local string_format = string.format
local date = date

----------------------------------------------------------------------------------------
--	Options
----------------------------------------------------------------------------------------
C.options = {
    enableTaunt = true,
    enableInterrupt = true,
    enableDispel = true,
    enableCrowdControl = true,
    enableDeath = true,
    enableResurrect = true,
    filterPlayers = true,     -- Whether to filter events involving players
    filterPets = true,        -- Whether to filter events involving pets
    outputLocal = true,       -- Whether to output messages to the local chat frame
    outputChat = false,       -- Whether to output messages to a specific chat channel
    chatChannel = "SAY",      -- The chat channel to output messages to (if outputChat is true)
    iconSize = 14,            -- Size of inline icons in messages
    showTimestamps = true,    -- Whether to show timestamps in messages
    groupMembersOnly = false, -- Option for group filtering (not implemented)
}

----------------------------------------------------------------------------------------
--	Spell Databases
----------------------------------------------------------------------------------------
R.spells = {
    taunts = {
        -- Death Knight
        [56222] = true,  -- Dark Command
        [49576] = true,  -- Death Grip (for Blood death knights)
        -- Demon Hunter
        [185245] = true, -- Torment
        -- Druid
        [6795] = true,   -- Growl (Bear Form)
        -- Hunter
        [2649] = true,   -- Growl (pet ability)
        -- Monk
        [115546] = true, -- Provoke
        -- Paladin
        [62124] = true,  -- Hand of Reckoning
        -- Warrior
        [355] = true,    -- Taunt
        -- Warlock
        [17735] = true,  -- Suffering (Voidwalker minion)
    },
    interrupts = {
        -- Death Knight
        [47528] = true,   -- Mind Freeze
        [91802] = true,   -- Shambling Rush (Abomination Limb)
        -- Demon Hunter
        [183752] = true,  -- Disrupt
        [217832] = true,  -- Imprison
        -- Druid
        [93985] = true,   -- Skull Bash
        [106839] = true,  -- Skull Bash (Feral)
        [97547] = true,   -- Solar Beam
        -- Evoker
        [351338] = true,  -- Quell
        -- Hunter
        [147362] = true,  -- Counter Shot
        [187707] = true,  -- Muzzle
        -- Mage
        [2139] = true,    -- Counterspell
        -- Monk
        [116705] = true,  -- Spear Hand Strike
        -- Paladin
        [96231] = true,   -- Rebuke
        [31935] = true,   -- Avenger's Shield
        -- Priest
        [15487] = true,   -- Silence
        -- Rogue
        [1766] = true,    -- Kick
        -- Shaman
        [57994] = true,   -- Wind Shear
        -- Warlock
        [19647] = true,   -- Spell Lock (Felhunter)
        [115781] = true,  -- Optical Blast (Observer)
        [132409] = true,  -- Spell Lock (Command Demon)
        -- Warrior
        [6552] = true,    -- Pummel
    },
    dispels = {
        -- Druid
        [2782] = true,   -- Remove Corruption
        [88423] = true,  -- Nature's Cure
        -- Evoker
        [365585] = true, -- Expunge
        [360823] = true, -- Naturalize
        -- Mage
        [475] = true,    -- Remove Curse
        -- Monk
        [115450] = true, -- Detox
        -- Paladin
        [4987] = true,   -- Cleanse
        -- Priest
        [527] = true,    -- Purify
        [213634] = true, -- Purify Disease
        [32375] = true,  -- Mass Dispel
        -- Shaman
        [51886] = true,  -- Cleanse Spirit
        [77130] = true,  -- Purify Spirit
        -- Warlock
        [89808] = true,  -- Singe Magic (Imp)
        [119905] = true, -- Command Demon (when Imp is active)
    },
    crowdControl = {
        -- Warrior
        [5246] = true,   -- Intimidating Shout
        [132168] = true, -- Shockwave
        [6552] = true,   -- Pummel
        [132169] = true, -- Storm Bolt

        -- Warlock
        [118699] = true, -- Fear
        [6789] = true,   -- Mortal Coil
        [19647] = true,  -- Spelllock
        [30283] = true,  -- Shadowfury
        [710] = true,    -- Banish
        [212619] = true, -- Call Felhunter
        [5484] = true,   -- Howl of Terror

        -- Mage
        [118] = true,    -- Polymorph
        [61305] = true,  -- Polymorph (black cat)
        [28271] = true,  -- Polymorph Turtle
        [161354] = true, -- Polymorph Monkey
        [161353] = true, -- Polymorph Polar Bear Cub
        [126819] = true, -- Polymorph Porcupine
        [277787] = true, -- Polymorph Direhorn
        [61721] = true,  -- Polymorph Rabbit
        [28272] = true,  -- Polymorph Pig
        [277792] = true, -- Polymorph Bumblebee
        [391622] = true, -- Polymorph Duck
        [82691] = true,  -- Ring of Frost
        [122] = true,    -- Frost Nova
        [157997] = true, -- Ice Nova
        [31661] = true,  -- Dragon's Breath
        [157981] = true, -- Blast Wave

        -- Priest
        [205364] = true, -- Mind Control (talent)
        [605] = true,    -- Mind Control
        [8122] = true,   -- Psychic Scream
        [9484] = true,   -- Shackle Undead
        [200196] = true, -- Holy Word: Chastise
        [200200] = true, -- Holy Word: Chastise (talent)
        [226943] = true, -- Mind Bomb
        [64044] = true,  -- Psychic Horror
        [15487] = true,  -- Silence

        -- Rogue
        [2094] = true,   -- Blind
        [427773] = true, -- Blind (AoE)
        [1833] = true,   -- Cheap Shot
        [408] = true,    -- Kidney Shot
        [6770] = true,   -- Sap
        [1776] = true,   -- Gouge

        -- Paladin
        [853] = true,    -- Hammer of Justice
        [20066] = true,  -- Repentance
        [105421] = true, -- Blinding Light
        [217824] = true, -- Shield of Virtue
        [10326] = true,  -- Turn Evil

        -- Death Knight
        [221562] = true, -- Asphyxiate
        [108194] = true, -- Asphyxiate (talent)
        [91807] = true,  -- Shambling Rush
        [207167] = true, -- Blinding Sleet
        [334693] = true, -- Absolute Zero

        -- Druid
        [339] = true,    -- Entangling Roots
        [2637] = true,   -- Hibernate
        [61391] = true,  -- Typhoon
        [102359] = true, -- Mass Entanglement
        [99] = true,     -- Incapacitating Roar
        [236748] = true, -- Intimidating Roar
        [5211] = true,   -- Mighty Bash
        [45334] = true,  -- Immobilized
        [203123] = true, -- Maim
        [50259] = true,  -- Dazed (from Wild Charge)
        [209753] = true, -- Cyclone (PvP talent)
        [33786] = true,  -- Cyclone (PvP talent - resto druid)
        [163505] = true, -- Rake
        [127797] = true, -- Ursol's Vortex

        -- Hunter
        [187707] = true, -- Muzzle
        [3355] = true,   -- Freezing Trap / Diamond Ice
        [19577] = true,  -- Intimidation
        [190927] = true, -- Harpoon
        [162480] = true, -- Steel Trap
        [24394] = true,  -- Intimidation
        [117405] = true, -- Binding Shot (trigger)
        [117526] = true, -- Binding Shot (triggered)
        [1513] = true,   -- Scare Beast

        -- Monk
        [119381] = true, -- Leg Sweep
        [115078] = true, -- Paralysis
        [198909] = true, -- Song of Chi-Ji
        [116706] = true, -- Disable
        [107079] = true, -- Quaking Palm (racial)
        [116705] = true, -- Spear Hand Strike

        -- Shaman
        [118905] = true, -- Static Charge (Capacitor Totem)
        [51514] = true,  -- Hex
        [210873] = true, -- Hex (Compy)
        [211004] = true, -- Hex (Spider)
        [211010] = true, -- Hex (Snake)
        [211015] = true, -- Hex (Cockroach)
        [269352] = true, -- Hex (Skeletal Hatchling)
        [277778] = true, -- Hex (Zandalari Tendonripper)
        [277784] = true, -- Hex (Wicker Mongrel)
        [309328] = true, -- Hex (Living Honey)
        [64695] = true,  -- Earthgrab
        [197214] = true, -- Sundering

        -- Demon Hunter
        [179057] = true, -- Chaos Nova
        [217832] = true, -- Imprison
        [200166] = true, -- Metamorphosis
        [207685] = true, -- Sigil of Misery
        [211881] = true, -- Fel Eruption

        -- Evoker
        [372245] = true, -- Terror of the Skies
        [360806] = true, -- Sleep Walk

        -- Covenant (Venthyr)
        [331866] = true, -- Agent of Chaos (Nadia soulbind)
    },
}

----------------------------------------------------------------------------------------
--  Environmental Damage Types
----------------------------------------------------------------------------------------
local ENVIRONMENTAL_DAMAGE_TYPES = {
    DROWNING = "Drowning",
    FALLING = "Falling",
    FATIGUE = "Fatigue",
    FIRE = "Fire",
    LAVA = "Lava",
    SLIME = "Slime"
}

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------

local function IsRelevantUnit(guid)
    if UnitGUID("player") == guid then
        return true
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if UnitGUID("raid" .. i) == guid or UnitGUID("raidpet" .. i) == guid then
                return true
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            if UnitGUID("party" .. i) == guid or UnitGUID("partypet" .. i) == guid then
                return true
            end
        end
    end

    return false
end

-- Checks if the provided flags indicate a player unit
local function IsPlayer(flags)
    if type(flags) == "string" then
        return flags == "player"
    elseif type(flags) == "number" then
        return bit_band(flags, PLAYER_FLAG) ~= 0
    end
    return false
end

-- Checks if the provided flags indicate a pet unit
local function IsPet(flags)
    if type(flags) == "string" then
        return flags == "pet"
    elseif type(flags) == "number" then
        return bit.band(flags, COMBATLOG_OBJECT_TYPE_PET) ~= 0
    end
    return false
end

-- Checks if the provided flags indicate an NPC unit
local function IsNPC(flags)
    if type(flags) == "string" then
        return flags == "npc"
    elseif type(flags) == "number" then
        return bit.band(flags, COMBATLOG_OBJECT_TYPE_NPC) ~= 0
    end
    return false
end

-- Checks if a unit with the given GUID is a member of the player's group
local function IsGroupMember(unitGUID)
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if UnitGUID("raid" .. i) == unitGUID then
                return true
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            if UnitGUID("party" .. i) == unitGUID then
                return true
            end
        end
        -- Don't forget to check the player as well when in a party
        if UnitGUID("player") == unitGUID then
            return true
        end
    else
        -- If not in a group, only process events for the player
        return UnitGUID("player") == unitGUID
    end
    return false
end

-- Determines if a unit should be processed based on its flags and whether it's the source or destination
-- of the event.  This function helps filter out irrelevant events.
local function ShouldProcessUnit(sourceFlags, destFlags, isSource)
    local guid = isSource and sourceGUID or destGUID
    return IsRelevantUnit(guid)
end


-- Throttles event processing to prevent duplicate messages for the same event within a short timeframe
local function ShouldProcessEvent(eventType, sourceGUID, destGUID)
    local now = GetTime()
    local key = eventType .. sourceGUID .. destGUID
    if not lastProcessedTime[key] or (now - lastProcessedTime[key] >= THROTTLE_INTERVAL) then
        lastProcessedTime[key] = now
        return true
    end
    return false
end

-- Retrieves the class color for a unit based on its GUID
local function GetClassColor(unitGUID)
    if not unitGUID then
        return "|cffffffff" -- Default to white if GUID is nil
    end

    if classColorCache[unitGUID] then
        return classColorCache[unitGUID]
    end

    local _, class, _ = pcall(GetPlayerInfoByGUID, unitGUID)
    if class and type(class) == "string" then
        local color = RAID_CLASS_COLORS[class]
        if color then
            local colorString = string_format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
            classColorCache[unitGUID] = colorString
            return colorString
        end
    end
    return "|cffffffff" -- Default to white if class not found or invalid
end

-- Colors a player's name based on their class
local function ColorPlayerName(name, guid)
    return GetClassColor(guid) .. name .. "|r"
end

local function ColorUnitName(name, guid)
    if not name then
        return "Unknown"
    end

    local colorString

    if guid then
        local unitType = strsplit("-", guid)
        if unitType == "Player" then
            local _, class = GetPlayerInfoByGUID(guid)
            if class and RAID_CLASS_COLORS[class] then
                local color = RAID_CLASS_COLORS[class]
                colorString = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
            end
        elseif unitType == "Creature" or unitType == "Vehicle" then
            -- Color all enemy NPCs as hostile
            local hostileColor = R.oUF_colors.reaction[2] -- Assuming 2 is the index for hostile
            colorString = string.format("|cff%02x%02x%02x", hostileColor[1] * 255, hostileColor[2] * 255, hostileColor[3] * 255)
        end
    end

    -- If no color was determined, use white as default
    if not colorString then
        colorString = "|cffffffff"
    end

    return colorString .. name .. "|r"
end

-- Creates a custom spell link (used for unknown spells)
local function CreateCustomSpellLink(spellId, spellName)
    if type(spellName) == "table" then
        spellName = spellName.name or tostring(spellId)
    end
    return string_format("|Hspell:%d|h[%s]|h", spellId, spellName)
end

-- Returns a formatted spell link with an icon, using cached information if available
local function GetSpellLinkWithIcon(spellId, classColor)
    if spellInfoCache[spellId] then
        local cachedInfo = spellInfoCache[spellId]
        local coloredLink = "|c" .. (classColor or "ff71d5ff") .. cachedInfo.link .. "|r"
        return cachedInfo.icon .. coloredLink
    end

    local spellInfo = C_Spell.GetSpellInfo(spellId)
    local name = spellInfo and spellInfo.name
    local icon = C_Spell.GetSpellTexture(spellId)

    if name and icon then
        local iconString = "|T" ..
            icon .. ":" .. C.options.iconSize .. ":" .. C.options.iconSize .. ":0:0:64:64:4:60:4:60|t "
        local customLink = CreateCustomSpellLink(spellId, name)

        spellInfoCache[spellId] = {
            icon = iconString,
            link = customLink
        }

        local coloredLink = "|c" .. (classColor or "ff71d5ff") .. customLink .. "|r"
        return iconString .. coloredLink
    end
    return "[Unknown Spell]" -- Return a default value if name or icon is nil
end

-- Gets the current timestamp in the format [HH:MM]
local function GetTimestamp()
    return date("[%H:%M]")
end

-- Outputs a message to the local chat frame and/or a specified chat channel
local function OutputMessage(message)
    local fullMessage = message
    if C.options.showTimestamps then
        local timestamp = GetTimestamp()
        fullMessage = ">> " .. timestamp .. " " .. message
    end

    if C.options.outputLocal then
        print(fullMessage)
    end
    if C.options.outputChat then
        -- Strip color codes and icons for chat channel messages
        local strippedMessage = fullMessage:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|R.-|t", "")
        SendChatMessage(strippedMessage, C.options.chatChannel)
    end
end

----------------------------------------------------------------------------------------
--	Damage Tracking Functions
----------------------------------------------------------------------------------------

-- Initialize a circular buffer for a unit
local function InitializeDamageBuffer(guid)
    recentDamage[guid] = {
        entries = {},
        nextIndex = 1,
        totalDamage = 0
    }
    for i = 1, DAMAGE_HISTORY_SIZE do
        recentDamage[guid].entries[i] = { time = 0, source = "", spellId = 0, amount = 0, damageType = "" }
    end
end

-- Optimized TrackDamage function
local function TrackDamage(destGUID, sourceName, spellId, amount, damageType)
    local now = GetTime()

    if not recentDamage[destGUID] then
        InitializeDamageBuffer(destGUID)
    end

    local buffer = recentDamage[destGUID]
    local index = buffer.nextIndex
    local oldestEntry = buffer.entries[index]

    -- Remove old damage from total
    if now - oldestEntry.time <= DAMAGE_HISTORY_SECONDS then
        buffer.totalDamage = buffer.totalDamage - oldestEntry.amount
    end

    -- Update entry
    oldestEntry.time = now
    oldestEntry.source = sourceName or "Environment"
    oldestEntry.spellId = spellId or 0
    oldestEntry.amount = amount
    oldestEntry.damageType = damageType or ""

    -- Update total damage and next index
    buffer.totalDamage = buffer.totalDamage + amount
    buffer.nextIndex = (index % DAMAGE_HISTORY_SIZE) + 1
end

-- Function to get recent damage info
local function GetRecentDamageInfo(guid)
    local buffer = recentDamage[guid]
    if not buffer then return 0, nil end

    local now = GetTime()
    local validEntries = {}
    local totalDamage = 0

    for _, entry in ipairs(buffer.entries) do
        if now - entry.time <= DAMAGE_HISTORY_SECONDS then
            table_insert(validEntries, entry)
            totalDamage = totalDamage + entry.amount
        end
    end

    table.sort(validEntries, function(a, b) return a.time > b.time end)

    return totalDamage, validEntries[1] -- Return total damage and most recent valid entry
end

----------------------------------------------------------------------------------------
--	Event Handlers
----------------------------------------------------------------------------------------
local interruptedSpells = {}

-- Handles spell cast events, checking for taunts, interrupts, dispels, and crowd control
local function HandleSpellCast(spellId, sourceName, sourceGUID, destName, destGUID, extraSpellId, extraSpellName, isInterrupt)
    local sourceColor = ColorUnitName(sourceName, sourceGUID)
    local destColor = ColorUnitName(destName, destGUID)

    local spellLink = GetSpellLinkWithIcon(spellId)
    local extraSpellLink = extraSpellId and GetSpellLinkWithIcon(extraSpellId) or (extraSpellName and extraSpellName) or "a spell"

    local message
    if C.options.enableTaunt and R.spells.taunts[spellId] then
        message = sourceColor .. " taunted " .. destColor .. " with " .. spellLink .. "."
    elseif C.options.enableInterrupt and R.spells.interrupts[spellId] and isInterrupt then
        message = sourceColor .. " interrupted " .. destColor .. "'s " .. extraSpellLink .. " with " .. spellLink .. "."
    elseif C.options.enableDispel and R.spells.dispels[spellId] then
        message = sourceColor .. " dispelled " .. destColor .. "'s " .. extraSpellLink .. " with " .. spellLink .. "."
    elseif C.options.enableCrowdControl and R.spells.crowdControl[spellId] then
        message = sourceColor .. " CC'ed " .. destColor .. " with " .. spellLink .. "."
    end

    if message then
        OutputMessage(message)
    end
end

local function HandleFailedInterrupt(sourceName, sourceGUID, destName, destGUID, spellId)
    local sourceColor = ColorUnitName(sourceName, sourceGUID)
    local destColor = ColorUnitName(destName, destGUID)
    local spellLink = GetSpellLinkWithIcon(spellId)
    
    local message = string_format("%s failed %s on %s.", sourceColor, spellLink, destColor)
    OutputMessage(message)
end

-- Handles unit death events, outputting a message with the cause of death and total damage taken
local function HandleDeath(destName, destGUID)
    if C.options.enableDeath then
        local destColor = ColorUnitName(destName, destGUID)
        local totalDamage, lastDamage = GetRecentDamageInfo(destGUID)

        local deathMessage
        if lastDamage then
            local sourceColor = lastDamage.source and ColorUnitName(lastDamage.source, nil) or "Unknown"

            if lastDamage.spellId == 0 and lastDamage.damageType == "Melee" then
                deathMessage = string_format("%s died to %s (%d Melee).", destColor, sourceColor, lastDamage.amount)
            elseif lastDamage.damageType ~= "" then
                local schoolString = lastDamage.school and C_Spell.GetSchoolString(lastDamage.school) or "Unknown"
                deathMessage = string_format("%s died to %d %s Damage.", destColor, lastDamage.amount, lastDamage.damageType or "Unknown")
            else
                local spellLink = GetSpellLinkWithIcon(lastDamage.spellId)
                local schoolString = lastDamage.school and C_Spell.GetSchoolString(lastDamage.school) or "Unknown" -- Ensure schoolString is defined
                deathMessage = string_format("%s died to %s %s (%d %s Damage).", destColor, sourceColor, spellLink, lastDamage.amount, schoolString)
            end
        else
            deathMessage = string_format("%s has died.", destColor)
        end

        OutputMessage(deathMessage)
        recentDamage[destGUID] = nil -- Clear the damage history for this player
    end
end

local function HandleCrowdControlBreak(sourceName, sourceGUID, destName, destGUID, spellId)
    local sourceColor = ColorUnitName(sourceName, sourceGUID)
    local destColor = ColorUnitName(destName, destGUID)
    local spellLink = GetSpellLinkWithIcon(spellId)
    
    local message = string_format("%s broke %s's %s.", sourceColor, destColor, spellLink)
    OutputMessage(message)
end

local function HandleResurrect(sourceName, sourceGUID, destName, destGUID, spellId)
    if C.options.enableResurrect then
        local sourceClassColor = GetClassColor(sourceGUID):gsub("|c", "")
        local coloredSourceName = ColorPlayerName(sourceName, sourceGUID)
        local coloredDestName = ColorPlayerName(destName, destGUID)
        local spellLink = GetSpellLinkWithIcon(spellId, sourceClassColor)

        local message
        if sourceName == destName then
            if spellId == 20707 then     -- Soulstone
                message = string_format("%s resurrected with %s's %s.", coloredDestName, coloredSourceName, spellLink)
            elseif spellId == 20608 then -- Reincarnation
                message = string_format("%s resurrected with %s.", coloredDestName, spellLink)
            else
                message = string_format("%s self-resurrected.", coloredDestName)
            end
        else
            message = string_format("%s %s resurrected %s.", coloredSourceName, spellLink, coloredDestName)
        end

        OutputMessage(message)
    end
end

local function HandleInstakill(sourceName, sourceGUID, destName, destGUID, spellId)
    local sourceColor = ColorUnitName(sourceName, sourceGUID)
    local destColor = ColorUnitName(destName, destGUID)
    local spellLink = GetSpellLinkWithIcon(spellId)
    
    local message = string_format("%s was instakilled by %s's %s.", destColor, sourceColor, spellLink)
    OutputMessage(message)
end

-- Handles resurrection events, outputting a message with the resurrector and spell used
local function HandleResurrect(sourceName, sourceGUID, destName, destGUID, spellId)
    if C.options.enableResurrect then
        local sourceColor = ColorUnitName(sourceName, sourceGUID)
        local destColor = ColorUnitName(destName, destGUID)
        local spellLink = GetSpellLinkWithIcon(spellId)

        local message
        if sourceName == destName then
            if spellId == 20707 then -- Soulstone
                message = string_format("%s resurrected with %s's %s.", destColor, sourceColor, spellLink)
            elseif spellId == 20608 then -- Reincarnation
                message = string_format("%s resurrected with %s.", destColor, spellLink)
            else
                message = string_format("%s self-resurrected.", destColor)
            end
        else
            message = string_format("%s %s resurrected %s.", sourceColor, spellLink, destColor)
        end

        OutputMessage(message)
    end
end

----------------------------------------------------------------------------------------
--	Main Event Processing
----------------------------------------------------------------------------------------

-- Optimized ProcessCombatLogEvent function
local function ProcessCombatLogEvent(...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
    destGUID, destName, destFlags, destRaidFlags = ...

    -- Check if either the source or destination is a relevant unit
    if IsRelevantUnit(sourceGUID) or IsRelevantUnit(destGUID) then
        local handler = eventHandlers[subevent]
        if handler then
            handler(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, select(12, ...))
        end
    end
end

-- Event Frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
    end
end)

-- Event Handler Table (Organized by Event)
eventHandlers = {
    SPELL_INTERRUPT = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, _, _, extraSpellId, extraSpellName)
        if ShouldProcessUnit(sourceFlags, destFlags, true) then
            HandleSpellCast(spellId, sourceName, sourceGUID, destName, destGUID, extraSpellId, extraSpellName, true)
        end
    end,

    SPELL_CAST_SUCCESS = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId)
        if ShouldProcessUnit(sourceFlags, destFlags, true) then
            HandleSpellCast(spellId, sourceName, sourceGUID, destName, destGUID)
        end
    end,

    SPELL_CAST_FAILED = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, _, _,
                                 failedType)
        if failedType == "INTERRUPTED" and ShouldProcessUnit(sourceFlags, destFlags, true) then
            HandleFailedInterrupt(sourceName, sourceGUID, destName, destGUID, spellId)
        end
    end,

    SPELL_AURA_BROKEN = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId)
        if ShouldProcessUnit(sourceFlags, destFlags, true) and R.spells.crowdControl[spellId] then
            HandleCrowdControlBreak(sourceName, sourceGUID, destName, destGUID, spellId)
        end
    end,

    SPELL_INSTAKILL = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId)
        if ShouldProcessUnit(sourceFlags, destFlags, false) then
            HandleInstakill(sourceName, sourceGUID, destName, destGUID, spellId)
        end
    end,

    ENVIRONMENTAL_DAMAGE = function(_, _, _, destGUID, destName, destFlags, damageType, amount)
        if ShouldProcessUnit(PLAYER_FLAG, destFlags, false) then
            TrackDamage(destGUID, nil, nil, amount, ENVIRONMENTAL_DAMAGE_TYPES[damageType] or "Environment")
        end
    end,

    SPELL_DAMAGE = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, _, _, amount)
        if ShouldProcessEvent("SPELL_DAMAGE", sourceGUID, destGUID) and
            (ShouldProcessUnit(sourceFlags, destFlags, true) or ShouldProcessUnit(sourceFlags, destFlags, false)) then
            TrackDamage(destGUID, sourceName, spellId, amount)
        end
    end,

    SWING_DAMAGE = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, amount)
        if ShouldProcessEvent("SWING_DAMAGE", sourceGUID, destGUID) and
            (ShouldProcessUnit(sourceFlags, destFlags, true) or ShouldProcessUnit(sourceFlags, destFlags, false)) then
            TrackDamage(destGUID, sourceName, 6603, amount, "Melee")
        end
    end,

    RANGE_DAMAGE = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, _, _, amount)
        if ShouldProcessEvent("RANGE_DAMAGE", sourceGUID, destGUID) and
            (ShouldProcessUnit(sourceFlags, destFlags, true) or ShouldProcessUnit(sourceFlags, destFlags, false)) then
            TrackDamage(destGUID, sourceName, spellId, amount)
        end
    end,

    UNIT_DIED = function(_, _, _, destGUID, destName, destFlags)
        if ShouldProcessUnit(PLAYER_FLAG, destFlags, false) then
            HandleDeath(destName, destGUID)
        end
    end,

    SPELL_RESURRECT = function(sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId)
        if ShouldProcessUnit(sourceFlags, destFlags, true) or ShouldProcessUnit(sourceFlags, destFlags, false) then
            HandleResurrect(sourceName, sourceGUID, destName, destGUID, spellId)
        end
    end
}

----------------------------------------------------------------------------------------
--	Chat Link Handling
----------------------------------------------------------------------------------------
local chatFrame = DEFAULT_CHAT_FRAME

-- Store original handlers
local originalOnHyperlinkClick = chatFrame:GetScript("OnHyperlinkClick")
local originalOnHyperlinkEnter = chatFrame:GetScript("OnHyperlinkEnter")
local originalOnHyperlinkLeave = chatFrame:GetScript("OnHyperlinkLeave")

-- Custom OnHyperlinkClick handler
local function CustomOnHyperlinkClick(self, link, text, button)
    if not link then
        return originalOnHyperlinkClick and originalOnHyperlinkClick(self, link, text, button)
    end

    local linkType, spellId = link:match("^([^:]+):(%d+)")
    if linkType == "spell" and spellId then
        spellId = tonumber(spellId)
        if IsModifiedClick("CHATLINK") and GetSpellLink then
            local spellLink = GetSpellLink(spellId)
            if spellLink then
                ChatEdit_InsertLink(spellLink)
            end
        else
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:Show()
        end
    elseif originalOnHyperlinkClick then
        -- Call original handler for other link types
        originalOnHyperlinkClick(self, link, text, button)
    end
end

-- Custom OnHyperlinkEnter handler
local function CustomOnHyperlinkEnter(self, link, text)
    if not link then
        return originalOnHyperlinkEnter and originalOnHyperlinkEnter(self, link, text)
    end

    local linkType, spellId = link:match("^([^:]+):(%d+)")
    if linkType == "spell" and spellId then
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetSpellByID(tonumber(spellId))
        GameTooltip:Show()
    elseif originalOnHyperlinkEnter then
        -- Call original handler for other link types
        originalOnHyperlinkEnter(self, link, text)
    end
end

-- Custom OnHyperlinkLeave handler
local function CustomOnHyperlinkLeave(self, link, text)
    GameTooltip:Hide()
    if originalOnHyperlinkLeave then
        -- Call original handler
        originalOnHyperlinkLeave(self, link, text)
    end
end

-- Set custom handlers
chatFrame:SetScript("OnHyperlinkClick", CustomOnHyperlinkClick)
chatFrame:SetScript("OnHyperlinkEnter", CustomOnHyperlinkEnter)
chatFrame:SetScript("OnHyperlinkLeave", CustomOnHyperlinkLeave)
