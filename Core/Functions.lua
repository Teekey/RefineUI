local R, C, L = unpack(RefineUI)


----------------------------------------------------------------------------------------
--	UTF functions
----------------------------------------------------------------------------------------
R.UTF = function(string, i, dots)
	if not string then return end
	local bytes = string:len()
	if bytes <= i then
		return string
	else
		local len, pos = 0, 1
		while (pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == i then break end
		end
		if len == i and pos <= bytes then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

----------------------------------------------------------------------------------------
--	Player's role check
----------------------------------------------------------------------------------------
local isCaster = {
	DEATHKNIGHT = {nil, nil, nil},
	DEMONHUNTER = {nil, nil},
	DRUID = {true},					-- Balance
	HUNTER = {nil, nil, nil},
	MAGE = {true, true, true},
	MONK = {nil, nil, nil},
	PALADIN = {nil, nil, nil},
	PRIEST = {nil, nil, true},		-- Shadow
	ROGUE = {nil, nil, nil},
	SHAMAN = {true},				-- Elemental
	WARLOCK = {true, true, true},
	WARRIOR = {nil, nil, nil},
	EVOKER = {true}
}

local function CheckRole()
	local spec = GetSpecialization()
	local role = spec and GetSpecializationRole(spec)

	R.Spec = spec
	if role == "TANK" then
		R.Role = "Tank"
	elseif role == "HEALER" then
		R.Role = "Healer"
	elseif role == "DAMAGER" then
		if isCaster[R.class][spec] then
			R.Role = "Caster"
		else
			R.Role = "Melee"
		end
	end
end
local RoleUpdater = CreateFrame("Frame")
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:SetScript("OnEvent", CheckRole)

R.IsHealerSpec = function()
	local healer = false
	local spec = GetSpecialization()

	if (R.class == "EVOKER" and spec == 2) or (R.class == "DRUID" and spec == 4) or (R.class == "MONK" and spec == 2) or
	(R.class == "PALADIN" and spec == 1) or (R.class == "PRIEST" and spec ~= 3) or (R.class == "SHAMAN" and spec == 3) then
		healer = true
	end

	return healer
end

----------------------------------------------------------------------------------------
--	Player's buff check
----------------------------------------------------------------------------------------
R.CheckPlayerBuff = function(spell)
	for i = 1, 40 do
		local name, _, _, _, _, _, unitCaster = UnitBuff("player", i)
		if not name then break end
		if name == spell then
			return i, unitCaster
		end
	end
	return nil
end

----------------------------------------------------------------------------------------
--	Player's level check
----------------------------------------------------------------------------------------
local function CheckLevel(_, _, level)
	R.level = level
end
local LevelUpdater = CreateFrame("Frame")
LevelUpdater:RegisterEvent("PLAYER_LEVEL_UP")
LevelUpdater:SetScript("OnEvent", CheckLevel)


R.SetFontString = function(parent, fontName, fontHeight, fontStyle)
    local fs = parent:CreateFontString(nil, "ARTWORK")
    fs:SetFont(fontName, fontHeight, fontStyle)
    return fs
end

local day, hour, minute = 86400, 3600, 60
local floor, format = math.floor, string.format

R.FormatTime = function(s)
    if s >= day then
        return format("%dd", floor(s / day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s / hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s / minute + 0.5))
    elseif s >= 5 then
        return tostring(floor(s + 0.5))
    end
    return format("%.1f", s)
end

----------------------------------------------------------------------------------------
--	Number value function
----------------------------------------------------------------------------------------
R.Round = function(number, decimals)
	if not decimals then decimals = 0 end
	if decimals and decimals > 0 then
		local mult = 10 ^ decimals
		return floor(number * mult + 0.5) / mult
	end
	return floor(number + 0.5)
end

R.ShortValue = function(value)
	if value >= 1e11 then
		return ("%.0fB"):format(value / 1e9)
	elseif value >= 1e10 then
		return ("%.1fB"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e9 then
		return ("%.2fB"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e8 then
		return ("%.0fM"):format(value / 1e6)
	elseif value >= 1e7 then
		return ("%.1fM"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e6 then
		return ("%.2fM"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e5 then
		return ("%.0fK"):format(value / 1e3)
	elseif value >= 1e3 then
		return ("%.1fK"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end


----------------------------------------------------------------------------------------
--	Colors
----------------------------------------------------------------------------------------

R.RGBToHex = function(r, g, b)
	r = tonumber(r) <= 1 and tonumber(r) >= 0 and tonumber(r) or 0
	g = tonumber(g) <= tonumber(g) and tonumber(g) >= 0 and tonumber(g) or 0
	b = tonumber(b) <= 1 and tonumber(b) >= 0 and tonumber(b) or 0
	return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

R.ColorGradient = function(perc, r1,g1,b1, r2,g2,b2, r3,g3,b3)
    if perc >= 1 then
        return r3, g3, b3
    elseif perc <= 0 then
        return r1, g1, b1
    end

    local segment, relperc = math.modf(perc * 2)
    local rr1, rg1, rb1, rr2, rg2, rb2 = select((segment * 3) + 1, r1,g1,b1, r2,g2,b2, r3,g3,b3)

    return rr1 + (rr2 - rr1) * relperc, rg1 + (rg2 - rg1) * relperc, rb1 + (rb2 - rb1) * relperc
end

----------------------------------------------------------------------------------------
--	Fade in/out functions
----------------------------------------------------------------------------------------
R.FadeIn = function(f)
    UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

R.FadeOut = function(f)
    UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end