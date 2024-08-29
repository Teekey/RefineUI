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