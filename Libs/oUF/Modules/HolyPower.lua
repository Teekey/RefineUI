local R, C, L = unpack(RefineUI)
if R.class ~= "PALADIN" then return end

local _, ns = ...
local oUF = ns.oUF
local LCG = LibStub("LibCustomGlow-1.0")

local AutoCastGlow_Start = LCG.AutoCastGlow_Start
local AutoCastGlow_Stop = LCG.AutoCastGlow_Stop


local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower or 9

local function Update(self, _, unit, powerType)
    if(self.unit ~= unit or (powerType and powerType ~= "HOLY_POWER")) then return end

    local element = self.HolyPower

    if(element.PreUpdate) then
        element:PreUpdate(unit)
    end

    local cur = UnitPower("player", SPELL_POWER_HOLY_POWER)
    local max = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)

    for i = 1, max do
        if element[i] then
            if i <= cur then
                element[i]:SetValue(1)
                element[i]:SetAlpha(1)
            else
                element[i]:SetValue(0)
                element[i]:SetAlpha(0.2)
            end
        end
    end

    if cur == max then
		-- PixelGlow_Start(self.Maelstrom.backdrop.border, {0.65, 0.52, 0.94}, 20, .2, 6, 2, -6, -6, true)
		AutoCastGlow_Start(element, { 1, 1, 0 }, 10, .25, 2, 4, 4)
	else
		-- PixelGlow_Stop(self.Maelstrom.backdrop.border)
		AutoCastGlow_Stop(element)
	end

    if(element.PostUpdate) then
        return element:PostUpdate(cur)
    end
end

local function Path(self, ...)
    return (self.HolyPower.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit, "HOLY_POWER")
end

local function Enable(self)
    local element = self.HolyPower
    if(element) then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        self:RegisterEvent("UNIT_POWER_UPDATE", Path)
        self:RegisterEvent("UNIT_DISPLAYPOWER", Path)

        return true
    end
end

local function Disable(self)
    local element = self.HolyPower
    if(element) then
        self:UnregisterEvent("UNIT_POWER_UPDATE", Path)
        self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
    end
end

oUF:AddElement("HolyPower", Path, Enable, Disable)