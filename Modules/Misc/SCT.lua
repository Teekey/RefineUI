----------------------------------------------------------------------------------------
--	Scrolling Combat Text (SCT) for RefineUI
--	This module provides a customizable scrolling combat text system for World of Warcraft.
--	It displays damage, misses, and other combat events with various animation options.
--	Features include customizable text size, colors, animations, and filtering options.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Libraries
----------------------------------------------------------------------------------------
local LibEasing = LibStub("LibEasing-1.0")

----------------------------------------------------------------------------------------
--	Addon Initialization
----------------------------------------------------------------------------------------
local TKUI_SCT = {}
TKUI_SCT.frame = CreateFrame("Frame", nil, UIParent)

-- Disable default floating combat text
SetCVar("floatingCombatTextCombatDamage", 0)
SetCVar("floatingCombatTextCombatHealing", 0)

----------------------------------------------------------------------------------------
--	Local Variables and Constants
----------------------------------------------------------------------------------------
local playerGUID
local unitToGuid = {}
local guidToUnit = {}
local animating = {}

-- Cache frequently used functions
local GetTime = GetTime
local math_random = math.random
local math_max = math.max
local math_min = math.min
local string_format = string.format
local string_find = string.find
local strconcat = table.concat
local string_match = string.match

-- Lookup table for power of 10 calculations
local POW10 = setmetatable({ [0] = 1 }, {
    __index = function(t, k)
        if k > 0 then
            local v = t[k - 1] * 10
            t[k] = v
            return v
        end
        return 1 / POW10[-k]
    end
})

-- Lookup tables for various settings
local SIZE_MULTIPLIERS = {
    small_hits = C.sct.size_small_hits_scale or 0.75,
    crits = C.sct.size_crit_scale or 1.5,
    miss = C.sct.size_miss_scale or 1.25
}

local ANIMATION_TYPES = {
    autoattack = {
        normal = C.sct.animations_autoattack,
        crit = C.sct.animations_autoattackcrit
    },
    ability = {
        normal = C.sct.animations_ability,
        crit = C.sct.animations_crit
    },
    miss = C.sct.animations_miss,
    personal = {
        normal = C.sct.personalanimations_normal,
        crit = C.sct.personalanimations_crit,
        miss = C.sct.personalanimations_miss
    }
}

-- Table recycling system
local tablePools = {}

local function getRecycledTable(poolName)
    local pool = tablePools[poolName]
    if not pool then
        pool = {}
        tablePools[poolName] = pool
    end
    return table.remove(pool) or {}
end

local function recycleTable(t, poolName)
    if type(t) ~= "table" then return end
    for k in pairs(t) do t[k] = nil end
    table.insert(tablePools[poolName] or {}, t)
end

-- Animation constants
local ANIMATION = {
    VERTICAL_DISTANCE = 75,
    ARC_X_MIN = 50,
    ARC_X_MAX = 150,
    ARC_Y_TOP_MIN = 10,
    ARC_Y_TOP_MAX = 50,
    ARC_Y_BOTTOM_MIN = 10,
    ARC_Y_BOTTOM_MAX = 50,
    RAINFALL_X_MAX = 75,
    RAINFALL_Y_MIN = 50,
    RAINFALL_Y_MAX = 100,
    RAINFALL_Y_START_MIN = 5,
    RAINFALL_Y_START_MAX = 15
}

-- Small hit constants
local SMALL_HIT = {
    EXPIRY_WINDOW = 30,
    MULTIPLIER = 0.5
}

-- Frame strata levels
local STRATAS = { "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "TOOLTIP" }

-- Inverse positions for icon placement
local INVERSE_POSITIONS = {
    ["BOTTOM"] = "TOP",
    ["LEFT"] = "RIGHT",
    ["TOP"] = "BOTTOM",
    ["RIGHT"] = "LEFT",
    ["TOPLEFT"] = "BOTTOMRIGHT",
    ["TOPRIGHT"] = "BOTTOMLEFT",
    ["BOTTOMLEFT"] = "TOPRIGHT",
    ["BOTTOMRIGHT"] = "TOPLEFT",
    ["CENTER"] = "CENTER"
}

-- Damage school masks (for 9.1 PTR Support)
if not SCHOOL_MASK_PHYSICAL then
    SCHOOL_MASK_PHYSICAL = Enum.Damageclass.MaskPhysical
    SCHOOL_MASK_HOLY = Enum.Damageclass.MaskHoly
    SCHOOL_MASK_FIRE = Enum.Damageclass.MaskFire
    SCHOOL_MASK_NATURE = Enum.Damageclass.MaskNature
    SCHOOL_MASK_FROST = Enum.Damageclass.MaskFrost
    SCHOOL_MASK_SHADOW = Enum.Damageclass.MaskShadow
    SCHOOL_MASK_ARCANE = Enum.Damageclass.MaskArcane
end

-- Damage type colors
local DAMAGE_TYPE_COLORS = {
    [SCHOOL_MASK_PHYSICAL] = "FFFF00",
    [SCHOOL_MASK_HOLY] = "FFE680",
    [SCHOOL_MASK_FIRE] = "FF8000",
    [SCHOOL_MASK_NATURE] = "4DFF4D",
    [SCHOOL_MASK_FROST] = "80FFFF",
    [SCHOOL_MASK_SHADOW] = "8080FF",
    [SCHOOL_MASK_ARCANE] = "FF80FF",
    -- ... (other color combinations)
    ["melee"] = "FFFFFF",
    ["pet"] = "CC8400"
}

-- Miss event strings
local MISS_EVENT_STRINGS = {
    ["ABSORB"] = "Absorbed",
    ["BLOCK"] = "Blocked",
    ["DEFLECT"] = "Deflected",
    ["DODGE"] = "Dodged",
    ["EVADE"] = "Evaded",
    ["IMMUNE"] = "Immune",
    ["MISS"] = "Missed",
    ["PARRY"] = "Parried",
    ["REFLECT"] = "Reflected",
    ["RESIST"] = "Resisted"
}

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------
local function commaSeparate(number)
    local left, num, right = string.match(tostring(number), '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

local function adjustStrata()
    if C.sct.strata_enable then return end

    if C.sct.strata_target == "BACKGROUND" then
        C.sct.strata_offtarget = "BACKGROUND"
    else
        for k, v in ipairs(STRATAS) do
            if v == C.sct.strata_target then
                C.sct.strata_offtarget = STRATAS[k - 1]
                break
            end
        end
    end
end

----------------------------------------------------------------------------------------
--	FontString Management
----------------------------------------------------------------------------------------
local fontStringCache = {}
local frameCounter = 0

local function getFontString()
    local fontString = table.remove(fontStringCache)
    if not fontString then
        frameCounter = frameCounter + 1
        local fontStringFrame = CreateFrame("Frame", nil, UIParent)
        fontStringFrame:SetFrameStrata(C.sct.strata_target)
        fontStringFrame:SetFrameLevel(frameCounter)
        fontString = fontStringFrame:CreateFontString()
        fontString:SetParent(fontStringFrame)
    end

    fontString:SetFont(unpack(C.font.sct))
    fontString:SetShadowOffset(1, -1)
    fontString:SetAlpha(1)
    fontString:SetDrawLayer("BACKGROUND")
    fontString:SetText("")
    fontString:Show()

    if C.sct.icon_enable then
        if not fontString.icon then
            fontString.icon = TKUI_SCT.frame:CreateTexture(nil, "BACKGROUND")
        end
        fontString.icon:SetAlpha(1)
        fontString.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        fontString.icon:Hide()
        if fontString.icon.button then
            fontString.icon.button:Show()
        end
    end

    return fontString
end

local function recycleFontString(fontString)
    fontString:SetAlpha(0)
    fontString:Hide()

    animating[fontString] = nil

    -- Reset properties
    fontString.distance = nil
    fontString.arcTop = nil
    fontString.arcBottom = nil
    fontString.arcXDist = nil
    fontString.deflection = nil
    fontString.numShakes = nil
    fontString.animation = nil
    fontString.animatingDuration = nil
    fontString.animatingStartTime = nil
    fontString.anchorFrame = nil
    fontString.unit = nil
    fontString.guid = nil
    fontString.pow = nil
    fontString.startHeight = nil

    if fontString.icon then
        fontString.icon:ClearAllPoints()
        fontString.icon:SetAlpha(0)
        fontString.icon:Hide()
        if fontString.icon.button then
            fontString.icon.button:Hide()
            fontString.icon.button:ClearAllPoints()
        end
        fontString.icon.anchorFrame = nil
        fontString.icon.unit = nil
        fontString.icon.guid = nil
    end

    fontString:SetFont(unpack(C.font.sct))
    fontString:SetShadowOffset(1, -1)
    fontString:ClearAllPoints()

    table.insert(fontStringCache, fontString)
end

----------------------------------------------------------------------------------------
--	Animation Functions
----------------------------------------------------------------------------------------
local function verticalPath(elapsed, duration, distance)
    return 0, LibEasing.InQuad(elapsed, 0, distance, duration)
end

local function arcPath(elapsed, duration, xDist, yStart, yTop, yBottom)
    local progress = elapsed / duration
    local x = progress * xDist

    local a = -2 * yStart + 4 * yTop - 2 * yBottom
    local b = -3 * yStart + 4 * yTop - yBottom

    local y = -a * progress ^ 2 + b * progress + yStart

    return x, y
end

local function powSizing(elapsed, duration, start, middle, finish)
    if elapsed >= duration then return finish end

    if elapsed / duration < 0.5 then
        return LibEasing.OutQuint(elapsed, start, middle - start, duration / 2)
    else
        return LibEasing.InQuint(elapsed - duration / 2, middle, finish - middle, duration / 2)
    end
end

local function calculateOffset(fontString, elapsed)
    local xOffset, yOffset = 0, 0
    if fontString.animation == "verticalUp" then
        xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, fontString.distance)
    elseif fontString.animation == "verticalDown" then
        xOffset, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
    elseif fontString.animation == "fountain" then
        xOffset, yOffset = arcPath(elapsed, fontString.animatingDuration, fontString.arcXDist, 0,
            fontString.arcTop, fontString.arcBottom)
    elseif fontString.animation == "rainfall" then
        _, yOffset = verticalPath(elapsed, fontString.animatingDuration, -fontString.distance)
        xOffset = fontString.rainfallX
        yOffset = yOffset + fontString.rainfallStartY
    end
    return xOffset, yOffset
end

local function updateFontStringPosition(fontString, elapsed)
    local xOffset, yOffset = calculateOffset(fontString, elapsed)

    if not UnitExists(fontString.unit) then
        return false
    end

    local anchorFrame = fontString.unit == "player" and UIParent or C_NamePlate.GetNamePlateForUnit(fontString.unit)
    if not anchorFrame then
        return false
    end

    local baseX = fontString.unit == "player" and C.sct.personal_x_offset or C.sct.x_offset
    local baseY = fontString.unit == "player" and C.sct.personal_y_offset or C.sct.y_offset
    fontString:SetPoint("CENTER", anchorFrame, "CENTER", baseX + xOffset, baseY + yOffset)

    return true
end

local function AnimationOnUpdate()
    local currentTime = GetTime()
    local toRemove = {}

    for fontString in pairs(animating) do
        if not fontString.animatingDuration or not fontString.animatingStartTime or not fontString.unit then
            table.insert(toRemove, fontString)
        elseif not UnitExists(fontString.unit) then
            table.insert(toRemove, fontString)
        else
            local elapsed = currentTime - fontString.animatingStartTime
            if elapsed > fontString.animatingDuration then
                recycleFontString(fontString)
                table.insert(toRemove, fontString)
            else
                if not updateFontStringPosition(fontString, elapsed) then
                    table.insert(toRemove, fontString)
                else
                    -- Update alpha
                    local progress = elapsed / fontString.animatingDuration
                    local startAlpha = fontString.startAlpha or C.sct.alpha
                    local endAlpha = 0
                    local currentAlpha = startAlpha + (endAlpha - startAlpha) * progress
                    fontString:SetAlpha(currentAlpha)
                    if fontString.icon then
                        fontString.icon:SetAlpha(currentAlpha)
                    end
                end
            end
        end
    end

    -- Remove invalid entries
    for _, fontString in ipairs(toRemove) do
        animating[fontString] = nil
        recycleFontString(fontString)
    end
end

local arcDirection = 1
function TKUI_SCT:Animate(fontString, anchorFrame, duration, animation)
    fontString.animation = animation
    fontString.animatingDuration = duration
    fontString.animatingStartTime = GetTime()
    fontString.anchorFrame = anchorFrame == "player" and UIParent or anchorFrame

    if animation == "verticalUp" or animation == "verticalDown" then
        fontString.distance = ANIMATION.VERTICAL_DISTANCE
    elseif animation == "fountain" then
        fontString.arcTop = math_random(ANIMATION.ARC_Y_TOP_MIN, ANIMATION.ARC_Y_TOP_MAX)
        fontString.arcBottom = -math_random(ANIMATION.ARC_Y_BOTTOM_MIN, ANIMATION.ARC_Y_BOTTOM_MAX)
        fontString.arcXDist = arcDirection * math_random(ANIMATION.ARC_X_MIN, ANIMATION.ARC_X_MAX)
        arcDirection = -arcDirection
    elseif animation == "rainfall" then
        fontString.distance = math_random(ANIMATION.RAINFALL_Y_MIN, ANIMATION.RAINFALL_Y_MAX)
        fontString.rainfallX = math_random(-ANIMATION.RAINFALL_X_MAX, ANIMATION.RAINFALL_X_MAX)
        fontString.rainfallStartY = -math_random(ANIMATION.RAINFALL_Y_START_MIN, ANIMATION.RAINFALL_Y_START_MAX)
    end

    animating[fontString] = true

    if not TKUI_SCT.frame:GetScript("OnUpdate") then
        TKUI_SCT.frame:SetScript("OnUpdate", AnimationOnUpdate)
    end
end

----------------------------------------------------------------------------------------
--	Event Handlers
----------------------------------------------------------------------------------------
function TKUI_SCT:NAME_PLATE_UNIT_ADDED(_, unitID)
    local guid = UnitGUID(unitID)
    unitToGuid[unitID] = guid
    guidToUnit[guid] = unitID
end

function TKUI_SCT:NAME_PLATE_UNIT_REMOVED(_, unitID)
    local guid = unitToGuid[unitID]
    unitToGuid[unitID] = nil
    guidToUnit[guid] = nil

    -- Recycle any fontStrings attached to this unit
    for fontString in pairs(animating) do
        if fontString.unit == unitID then
            recycleFontString(fontString)
            animating[fontString] = nil -- Ensure it's removed from the animating table
        end
    end
end

local function shouldProcessEvent(sourceGUID, sourceFlags, destGUID)
    if C.sct.personal_only and C.sct.personal_enable and playerGUID ~= destGUID then
        return false
    end

    local isPlayerEvent = (playerGUID == sourceGUID or (C.sct.personal_enable and playerGUID == destGUID))
    local isPetEvent = (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or
            bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and
        bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0

    return isPlayerEvent or isPetEvent
end

-- Create a lookup table for event handlers
local eventHandlers = {
    SWING_DAMAGE = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, amount, overkill, school, _, _, _, critical)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            local eventData = getRecycledTable("damageEvent")
            eventData.destGUID = destGUID
            eventData.spellName = "melee"
            eventData.amount = amount
            eventData.overkill = overkill
            eventData.school = school or "physical"
            eventData.critical = critical
            self:DamageEvent(eventData)
            recycleTable(eventData, "damageEvent")
        end
    end,
    RANGE_DAMAGE = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, spellId, spellName, _, amount, overkill,
                            school, _, _, _, critical)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            local eventData = getRecycledTable("damageEvent")
            eventData.destGUID = destGUID
            eventData.spellName = spellName
            eventData.amount = amount
            eventData.overkill = overkill
            eventData.school = school
            eventData.critical = critical
            eventData.spellId = spellId
            self:DamageEvent(eventData)
            recycleTable(eventData, "damageEvent")
        end
    end,
    SPELL_DAMAGE = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, spellId, spellName, _, amount, overkill,
                            school, _, _, _, critical)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            local eventData = getRecycledTable("damageEvent")
            eventData.destGUID = destGUID
            eventData.spellName = spellName
            eventData.amount = amount
            eventData.overkill = overkill
            eventData.school = school
            eventData.critical = critical
            eventData.spellId = spellId
            self:DamageEvent(eventData)
            recycleTable(eventData, "damageEvent")
        end
    end,
    SPELL_PERIODIC_DAMAGE = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, spellId, spellName, _, amount,
                                     overkill, school, _, _, _, critical)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            local eventData = getRecycledTable("damageEvent")
            eventData.destGUID = destGUID
            eventData.spellName = spellName
            eventData.amount = amount
            eventData.overkill = overkill
            eventData.school = school
            eventData.critical = critical
            eventData.spellId = spellId
            self:DamageEvent(eventData)
            recycleTable(eventData, "damageEvent")
        end
    end,
    SWING_MISSED = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, missType)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            self:MissEvent(destGUID, "melee", missType)
        end
    end,
    SPELL_MISSED = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, spellId, spellName, _, missType)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            self:MissEvent(destGUID, spellName, missType, spellId)
        end
    end,
    RANGE_MISSED = function(self, sourceGUID, _, sourceFlags, destGUID, _, _, spellId, spellName, _, missType)
        if shouldProcessEvent(sourceGUID, sourceFlags, destGUID) then
            self:MissEvent(destGUID, spellName, missType, spellId)
        end
    end
}

function TKUI_SCT:ShouldProcessEvent(sourceGUID, sourceFlags, destGUID)
    if C.sct.personal_only and C.sct.personal_enable and playerGUID ~= destGUID then
        return false
    end

    local isPlayerEvent = (playerGUID == sourceGUID or (C.sct.personal_enable and playerGUID == destGUID))
    local isPetEvent = (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_GUARDIAN) > 0 or
            bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) > 0) and
        bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0

    return isPlayerEvent or isPetEvent
end

function TKUI_SCT:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags =
        CombatLogGetCurrentEventInfo()

    local handler = eventHandlers[eventType]
    if handler then
        handler(self, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags,
            select(12, CombatLogGetCurrentEventInfo()))
    end
end

----------------------------------------------------------------------------------------
--	Display Functions
----------------------------------------------------------------------------------------
local numDamageEvents = 0
local lastDamageEventTime
local runningAverageDamageEvents = 0

function TKUI_SCT:DamageEvent(eventData)
    local text, animation, pow, size, alpha
    local autoattack = eventData.spellName == "melee" or eventData.spellName == "pet"
    local isPersonal = eventData.destGUID == playerGUID

    -- Select animation using lookup table
    if isPersonal then
        animation = eventData.critical and ANIMATION_TYPES.personal.crit or ANIMATION_TYPES.personal.normal
    else
        if autoattack then
            animation = eventData.critical and ANIMATION_TYPES.autoattack.crit or ANIMATION_TYPES.autoattack.normal
        else
            animation = eventData.critical and ANIMATION_TYPES.ability.crit or ANIMATION_TYPES.ability.normal
        end
    end

    pow = eventData.critical

    -- Skip if this damage event is disabled
    if animation == "disabled" then return end

    local unit = guidToUnit[eventData.destGUID]
    local isTarget = unit and UnitIsUnit(unit, "target")

    -- Determine size and alpha
    if C.sct.offtarget_enable and not isTarget and not isPersonal then
        size = C.sct.offtarget_size
        alpha = C.sct.offtarget_alpha
    else
        size = C.font.sct_font_size
        alpha = C.sct.alpha
    end

    -- Truncate and format text
    text = self:FormatDamageText(eventData.amount)

    -- Color text
    text = self:ColorText(text, eventData.destGUID, playerGUID, eventData.school, eventData.spellName)

    -- Handle small hits
    if (C.sct.size_small_hits or C.sct.size_small_hits_hide) and not isPersonal then
        size = self:HandleSmallHits(eventData.amount, eventData.critical, size)
        if not size then return end -- Skip this damage event, it's too small
    end

    -- Adjust crit size using lookup table
    if C.sct.size_crits and eventData.critical and not isPersonal then
        if not (autoattack and not C.sct.size_crits) then
            size = size * SIZE_MULTIPLIERS.crits
        end
    end

    -- Ensure minimum size
    size = math_max(size, 5)

    -- Handle overkill
    if eventData.overkill > 0 and C.sct.overkill then
        local overkillText = string_format(" Overkill(%d)", eventData.overkill)
        text = self:ColorText(strconcat({ text, overkillText }), eventData.destGUID, playerGUID, eventData.school,
            eventData.spellName)
        self:DisplayTextOverkill(eventData.destGUID, text, size, animation, eventData.spellId, pow, eventData.spellName)
    else
        self:DisplayText(eventData.destGUID, text, size, animation, eventData.spellId, pow, eventData.spellName)
    end
end

function TKUI_SCT:FormatDamageText(amount)
    if C.sct.truncate_enable then
        if amount >= POW10[6] and C.sct.truncate_letter then
            return string_format("%.1fM", amount / POW10[6])
        elseif amount >= POW10[4] then
            local text = string_format("%.0f", amount / POW10[3])
            return C.sct.truncate_letter and text .. "k" or text
        elseif amount >= POW10[3] then
            local text = string_format("%.1f", amount / POW10[3])
            return C.sct.truncate_letter and text .. "k" or text
        end
    end
    return C.sct.truncate_comma and commaSeparate(amount) or tostring(amount)
end

function TKUI_SCT:HandleSmallHits(amount, crit, size)
    local currentTime = GetTime()
    if not lastDamageEventTime or (lastDamageEventTime + SMALL_HIT.EXPIRY_WINDOW < currentTime) then
        numDamageEvents = 0
        runningAverageDamageEvents = 0
    end

    runningAverageDamageEvents = ((runningAverageDamageEvents * numDamageEvents) + amount) / (numDamageEvents + 1)
    numDamageEvents = numDamageEvents + 1
    lastDamageEventTime = currentTime

    local threshold = SMALL_HIT.MULTIPLIER * runningAverageDamageEvents
    if (not crit and amount < threshold) or (crit and amount / 2 < threshold) then
        if C.sct.size_small_hits_hide then
            return nil -- Skip this damage event
        else
            return size * SIZE_MULTIPLIERS.small_hits
        end
    end
    return size
end

function TKUI_SCT:MissEvent(guid, spellName, missType, spellId)
    local text, animation, pow, size, alpha, color
    local isPersonal = guid == playerGUID

    animation = isPersonal and ANIMATION_TYPES.personal.miss or ANIMATION_TYPES.miss
    color = isPersonal and C.sct.personal_default_color or C.sct.default_color

    -- No animation set, cancel out
    if animation == "disabled" then return end

    local unit = guidToUnit[guid]
    local isTarget = unit and UnitIsUnit(unit, "target")

    if C.sct.offtarget_enable and not isTarget and not isPersonal then
        size = C.sct.offtarget_size
        alpha = C.sct.offtarget_alpha
    else
        size = C.font.sct_font_size
        alpha = C.sct.alpha
    end

    -- Adjust miss size using lookup table
    if C.sct.size_miss and not isPersonal then
        size = size * SIZE_MULTIPLIERS.miss
    end

    pow = true

    text = MISS_EVENT_STRINGS[missType] or "Missed"
    text = string_format("|Cff%s%s|r", color, text)

    self:DisplayText(guid, text, size, animation, spellId, pow, spellName)
end

function TKUI_SCT:DisplayText(guid, text, size, animation, spellId, pow, spellName)
    local fontString = getFontString()
    local unit = guidToUnit[guid]
    local nameplate = unit and C_NamePlate.GetNamePlateForUnit(unit) or (playerGUID == guid and "player")

    if not nameplate then return end

    fontString.scttext = text
    fontString:SetText(text)

    fontString:SetFont(unpack(C.font.sct))
    fontString:SetShadowOffset(1, -1)
    fontString.startHeight = math_max(fontString:GetStringHeight(), 5)
    fontString.pow = pow

    fontString.unit = unit
    fontString.guid = guid

    -- Calculate and apply alpha
    local isTarget = unit and UnitIsUnit(unit, "target")
    local alpha
    if C.sct.offtarget_enable and not isTarget and guid ~= playerGUID then
        alpha = C.sct.offtarget_alpha
    else
        alpha = C.sct.alpha
    end
    fontString:SetAlpha(alpha)
    fontString.startAlpha = alpha

    if C.sct.icon_enable then
        local texture
        if type(spellId) == "number" then
            texture = C_Spell.GetSpellTexture(spellId)
        elseif type(spellName) == "string" then
            local spellID = select(7, C_Spell.GetSpellInfo(spellName))
            if spellID then
                texture = C_Spell.GetSpellTexture(spellID)
            end
        end
        
        if texture then
            local icon = fontString.icon or TKUI_SCT.frame:CreateTexture(nil, "BACKGROUND")
            icon:Show()
            icon:SetTexture(texture)
            icon:SetSize(size * C.sct.icon_scale, size * C.sct.icon_scale)
            icon:SetPoint(INVERSE_POSITIONS[C.sct.icon_position], fontString, C.sct.icon_position,
                C.sct.icon_x_offset, C.sct.icon_y_offset)
            icon:SetAlpha(alpha) -- Also apply alpha to the icon
            fontString.icon = icon
        elseif fontString.icon then
            fontString.icon:Hide()
        end
    end
    
    self:Animate(fontString, nameplate, C.sct.animations_speed, animation)
    end
    
    function TKUI_SCT:DisplayTextOverkill(guid, text, size, animation, spellId, pow, spellName)
        self:DisplayText(guid, text, size, animation, spellId, pow, spellName)
    end
    
    local function getColor(guid, school, spellName)
        return (guid ~= playerGUID and DAMAGE_TYPE_COLORS[school]) or
            DAMAGE_TYPE_COLORS[spellName] or
            "ffffff"
    end
    
    function TKUI_SCT:ColorText(startingText, guid, school, spellName)
        return string_format("|Cff%s%s|r", getColor(guid, school, spellName), startingText)
    end
    
    ----------------------------------------------------------------------------------------
    --	Initialization
    ----------------------------------------------------------------------------------------
    function TKUI_SCT:Init()
        -- Setup db
        TKUI_SCTDB = TKUI_SCTDB or {}
        self.db = TKUI_SCTDB
    
        -- If the addon is turned off in db, turn it off
        if C.sct.enable == false then
            self:Disable()
            self.frame:UnregisterAllEvents()
            for fontString in pairs(animating) do
                recycleFontString(fontString)
            end
        else
            playerGUID = UnitGUID("player")
            self.frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
            self.frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
            self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            self.frame:SetScript("OnEvent", function(_, event, ...)
                if self[event] then
                    self[event](self, event, ...)
                end
            end)
        end
    end
    
    function TKUI_SCT:Disable()
        -- Implement disable logic here
    end
    
    -- Initialize the addon
    TKUI_SCT:Init()