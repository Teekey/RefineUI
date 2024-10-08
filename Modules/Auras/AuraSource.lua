local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
-- Upvalues
----------------------------------------------------------------------------------------
local format, select, UnitIsPlayer, UnitClass, UnitReaction, GetUnitName = 
    format, select, UnitIsPlayer, UnitClass, UnitReaction, GetUnitName
local C_UnitAuras, AuraUtil = C_UnitAuras, AuraUtil
local DONE_BY, RAID_CLASS_COLORS = DONE_BY, RAID_CLASS_COLORS
local pairs, hooksecurefunc = pairs, hooksecurefunc

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local PLAYER_COLOR = format("|cff%02x%02x%02x", R.color.r * 255, R.color.g * 255, R.color.b * 255)

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------
local function getColoredName(unit, name)
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local color = RAID_CLASS_COLORS[class]
        return color and format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name) or name
    else
        local reaction = UnitReaction(unit, "player")
        local color = reaction and R.oUF_colors.reaction[reaction]
        return color and format("|cff%02x%02x%02x%s|r", color[1] * 255, color[2] * 255, color[3] * 255, name) or name
    end
end

----------------------------------------------------------------------------------------
-- Aura Source Function
----------------------------------------------------------------------------------------
local function addAuraSource(self, func, unit, index, filter, instanceID)
    local srcUnit = instanceID and (C_UnitAuras.GetAuraDataByAuraInstanceID(unit, index) or {}).sourceUnit
                    or select(7, func(unit, index, filter))
    
    if not srcUnit then return end

    local src = GetUnitName(srcUnit, true)
    if srcUnit == "pet" or srcUnit == "vehicle" then
        src = format("%s (%s%s|r)", src, PLAYER_COLOR, GetUnitName("player", true))
    else
        local petOwner = srcUnit:match("^(party)pet(%d+)$") or srcUnit:match("^(raid)pet(%d+)$")
        if petOwner then
            src = format("%s (%s)", src, GetUnitName(petOwner .. srcUnit:match("%d+"), true))
        end
    end

    src = getColoredName(srcUnit, src)
    self:AddLine(DONE_BY .. " " .. src)
    self:Show()
end

----------------------------------------------------------------------------------------
-- Hook GameTooltip Functions
----------------------------------------------------------------------------------------
local funcs = {
    SetUnitAura = AuraUtil.FindAuraByName,
    SetUnitBuff = AuraUtil.FindAuraByName,
    SetUnitDebuff = AuraUtil.FindAuraByName,
    SetUnitBuffByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID,
    SetUnitDebuffByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID,
}

for k, v in pairs(funcs) do
    hooksecurefunc(GameTooltip, k, function(self, unit, index, filter)
        addAuraSource(self, v, unit, index, filter, k:find("ByAuraInstanceID"))
    end)
end