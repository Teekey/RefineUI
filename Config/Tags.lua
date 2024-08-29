local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF

-- Upvalues
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitReaction = UnitReaction
local UnitIsPlayer = UnitIsPlayer
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitClassification = UnitClassification
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitAffectingCombat = UnitAffectingCombat
local UnitThreatSituation = UnitThreatSituation
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local GetNumGroupMembers = GetNumGroupMembers
local IsInRaid = IsInRaid
local string = string
local math = math
local unpack = unpack

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------
local function FormatColor(r, g, b)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function GetColorForNPC(npcID, threatStatus)
    if npcID == "120651" then     -- Explosives affix
        return C.nameplate.extraColor
    elseif npcID == "174773" then -- Spiteful Shade affix
        return threatStatus == 3 and C.nameplate.extraColor or C.nameplate.good_color
    end
    return nil
end

local function GetThreatColor(unit, threatStatus)
    if R.Role == "Tank" then
        if threatStatus == 3 then
            return C.nameplate.mobColorEnable and R.ColorPlate[uniR.npcID] or C.nameplate.good_color
        elseif threatStatus == 0 then
            return IsOffTankTanking(unit) and C.nameplate.offtank_color or C.nameplate.bad_color
        end
    else
        if threatStatus == 3 then
            return C.nameplate.bad_color
        elseif threatStatus == 0 then
            return C.nameplate.mobColorEnable and R.ColorPlate[uniR.npcID] or C.nameplate.good_color
        end
    end
    return C.nameplate.near_color
end

local function IsOffTankTanking(unit)
    if not IsInRaid() then return false end
    for i = 1, GetNumGroupMembers() do
        if UnitExists("raid" .. i) and not UnitIsUnit("raid" .. i, "player") and
            UnitGroupRolesAssigned("raid" .. i) == "TANK" then
            local isTanking = UnitDetailedThreatSituation("raid" .. i, unit)
            if isTanking then return true end
        end
    end
    return false
end

----------------------------------------------------------------------------------------
-- Tags
----------------------------------------------------------------------------------------

-- oUF.Tags.Methods["RaidIcon"] = function(unit)
--     local iconIndex = GetRaidTargetIndex(unit)  -- Get the raid icon index
--     return iconIndex and string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:25|t", iconIndex) or ""  -- Format the icon with increased size
-- end
-- oUF.Tags.Events["RaidIcon"] = "RAID_TARGET_UPDATE"



oUF.Tags.Methods["Threat"] = function()
    local _, status, percent = UnitDetailedThreatSituation("player", "target")
    if percent and percent > 0 then
        return ("%s%d%%|r"):format(Hex(GetThreatStatusColor(status)), percent)
    end
end
oUF.Tags.Events["Threat"] = "UNIT_THREAT_LIST_UPDATE"

oUF.Tags.Methods["DiffColor"] = function(unit)
    local level = UnitLevel(unit)
    local r, g, b
    if level < 1 then
        r, g, b = 0.69, 0.31, 0.31
    else
        local DiffColor = level - UnitLevel("player")
        if DiffColor >= 5 then
            r, g, b = 0.69, 0.31, 0.31
        elseif DiffColor >= 3 then
            r, g, b = 0.71, 0.43, 0.27
        elseif DiffColor >= -2 then
            r, g, b = 0.84, 0.75, 0.65
        elseif -DiffColor <= 5 then
            r, g, b = 0.33, 0.59, 0.33
        else
            r, g, b = 0.55, 0.57, 0.61
        end
    end
    return FormatColor(r, g, b)
end
oUF.Tags.Events["DiffColor"] = "UNIT_LEVEL"

oUF.Tags.Methods["PetNameColor"] = function()
    return FormatColor(R.color.r, R.color.g, R.color.b)
end
oUF.Tags.Events["PetNameColor"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["GetNameColor"] = function(unit)
    local reaction = UnitReaction(unit, "player")
    local name = UnitName(unit)  -- Get the unit name

    -- Check if the name is valid
    if not name then
        return FormatColor(0.5, 0.5, 0.5)  -- Return a default color (gray) if the name is nil
    end

    if UnitIsPlayer(unit) then
        return _TAGS["raidcolor"](unit)
    elseif reaction then
        local c = R.oUF_colors.reaction[reaction]
        return FormatColor(unpack(c))
    else
        return FormatColor(0.33, 0.59, 0.33)
    end
end
-- Name tags
local function CreateNameTag(length, ellipsis)
    return function(unit)
        local name = UnitName(unit)
        name = string.upper(name)
        return R.UTF(name, length, ellipsis)
    end
end

oUF.Tags.Methods["NameArena"] = CreateNameTag(4, false)
oUF.Tags.Methods["NameShort"] = CreateNameTag(8, false)
oUF.Tags.Methods["NameMedium"] = CreateNameTag(12, false)
oUF.Tags.Methods["NameLong"] = CreateNameTag(18, true)

oUF.Tags.Events["NameArena"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["NameShort"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["NameMedium"] = "UNIT_NAME_UPDATE"
oUF.Tags.Events["NameLong"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["NameLongAbbrev"] = function(unit)
    local name = UnitName(unit)
    if string.len(name) > 18 then
        name = string.gsub(name, "-", "")
        name = string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ")
    end
    name = string.upper(name)
    return R.UTF(name, 18, false)
end
oUF.Tags.Events["NameLongAbbrev"] = "UNIT_NAME_UPDATE"

local function GetNPCTitle(unit)
    if UnitIsPlayer(unit) or not UnitExists(unit) then return "" end
    
    GameTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    GameTooltip:SetUnit(unit)
    
    local secondLine = GameTooltipTextLeft2:GetText()
    local title = ""
    
    if secondLine and not secondLine:match("%d") then
        title = "<" .. secondLine .. ">"
    end
    
    GameTooltip:Hide()
    return title
end

oUF.Tags.Methods['NPCTitle'] = function(unit)
    return GetNPCTitle(unit)
end
oUF.Tags.Events['NPCTitle'] = 'UNIT_NAME_UPDATE'

oUF.Tags.Methods["LFD"] = function(unit)
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
        return "|cff0070DE[T]|r"
    elseif role == "HEALER" then
        return "|cff00CC12[H]|r"
    elseif role == "DAMAGER" then
        return "|cffFF3030[D]|r"
    end
end
oUF.Tags.Events["LFD"] = "PLAYER_ROLES_ASSIGNED GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["AltPower"] = function(unit)
    local min = UnitPower(unit, ALTERNATE_POWER_INDEX)
    local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
    if max > 0 and not UnitIsDeadOrGhost(unit) then
        return ("%s%%"):format(math.floor(min / max * 100 + 0.5))
    end
end
oUF.Tags.Events["AltPower"] = "UNIT_POWER_UPDATE"

oUF.Tags.Methods["NameplateLevel"] = function(unit)
    local level = UnitLevel(unit)
    local c = UnitClassification(unit)
    if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
        level = UnitBattlePetLevel(unit)
    end

    if level == R.level and c == "normal" then return end
    if level > 0 then
        return level
    else
        return "??"
    end
end
oUF.Tags.Events["NameplateLevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["NameplateNameColor"] = function(unit)
    local reaction = UnitReaction(unit, "player")
    local threatStatus = UnitThreatSituation("player", unit)
    -- TKUI Name Threat Color--
    if UnitAffectingCombat("player") and UnitAffectingCombat(unit) then
        if unit.npcID == "120651" then -- Explosives affix
            local c = {unpack(C.nameplate.extraColor)} -- Updated to extraColor
            return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
        elseif unit.npcID == "174773" then -- Spiteful Shade affix
            if threatStatus == 3 then
                local c = {unpack(C.nameplate.extraColor)} -- Updated to extraColor
                return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
            else
                local c = {unpack(C.nameplate.goodColor)} -- Updated to goodColor
                return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
            end
        elseif threatStatus == 3 then -- securely tanking, highest threat
            if R.Role == "Tank" then
                if C.nameplate.enhanceThreat == true then
                    if C.nameplate.mobColorEnable and R.ColorPlate[unit.npcID] then
                        local c = {unpack(R.ColorPlate[unit.npcID])}
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    else
                        local c = {unpack(C.nameplate.goodColor)} -- Updated to goodColor
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    end
                end
            else
                if C.nameplate.enhanceThreat == true then
                    local c = {unpack(C.nameplate.badColor)} -- Updated to badColor
                    return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                end
            end
        elseif threatStatus == 2 then -- insecurely tanking, another unit has higher threat but not tanking
            if C.nameplate.enhanceThreat == true then
                local c = {unpack(C.nameplate.nearColor)} -- Updated to nearColor
                return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
            end
        elseif threatStatus == 1 then -- not tanking, higher threat than tank
            if C.nameplate.enhanceThreat == true then
                local c = {unpack(C.nameplate.nearColor)} -- Updated to nearColor
                return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
            end
        elseif threatStatus == 0 then -- not tanking, lower threat than tank
            if C.nameplate.enhanceThreat == true then
                if R.Role == "Tank" then
                    local offTank = false
                    if IsInRaid() then
                        for i = 1, GetNumGroupMembers() do
                            if UnitExists("raid" .. i) and not UnitIsUnit("raid" .. i, "player") and
                                UnitGroupRolesAssigned("raid" .. i) == "TANK" then
                                local isTanking = UnitDetailedThreatSituation("raid" .. i, unit)
                                if isTanking then
                                    offTank = true
                                    break
                                end
                            end
                        end
                    end
                    if offTank then
                        local c = {unpack(C.nameplate.offtankColor)} -- Updated to offtankColor
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    else
                        local c = {unpack(C.nameplate.badColor)} -- Updated to badColor
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    end
                else
                    if C.nameplate.mobColorEnable and R.ColorPlate[unit.npcID] then
                        local c = {unpack(R.ColorPlate[unit.npcID])}
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    else
                        local c = {unpack(C.nameplate.goodColor)} -- Updated to goodColor
                        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
                    end
                end
            end
        elseif reaction then
            local c = R.oUF_colors.reaction[reaction]
            return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
        end

    elseif not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (reaction and reaction >= 5) then
        if C.nameplate.onlyName then
            return _TAGS["raidcolor"](unit)
        else
            local c = R.oUF_colors.power["MANA"]
            return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
        end
    elseif UnitIsPlayer(unit) then
        return _TAGS["raidcolor"](unit)
    elseif UnitIsDeadOrGhost(unit) then
        local r, g, b = 0.6, 0.6, 0.6
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    elseif reaction then
        local c = R.oUF_colors.reaction[reaction]
        return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
    else
        local r, g, b = 0.33, 0.59, 0.33
        return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end
end
oUF.Tags.Events["NameplateNameColor"] =
    "UNIT_POWER_UPDATE UNIT_FLAGS UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE"
    
oUF.Tags.Methods["NameplateNameShort"] = function(unit)
    local name = UnitName(unit)
    name = R.ShortNames[name] or name
    return R.UTF(name, 18, true)
end
oUF.Tags.Events["NameplateNameShort"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["NameplateHealth"] = function(unit)
    local hp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    if maxhp == 0 then
        return 0
    else
        return math.floor(hp / maxhp * 100 + .5)
    end
end
oUF.Tags.Events["NameplateHealth"] = "UNIT_HEALTH UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"

oUF.Tags.Methods["Absorbs"] = function(unit)
    local absorb = UnitGetTotalAbsorbs(unit)
    if absorb and absorb > 0 then
        return R.ShortValue(absorb)
    end
end
oUF.Tags.Events["Absorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED"
