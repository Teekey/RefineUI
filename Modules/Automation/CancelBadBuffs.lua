----------------------------------------------------------------------------------------
--	CancelBadBuffs Module for TKUI
--	This module automatically cancels specified buffs on the player
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)

-- Check if the feature is enabled in the configuration
if C.automation.cancel_bad_buffs ~= true then return end

----------------------------------------------------------------------------------------
--	Local Variables
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")

----------------------------------------------------------------------------------------
--	Helper Functions
----------------------------------------------------------------------------------------
local function PrintBuffRemoved(name)
	print("|cffffff00"..ACTION_SPELL_AURA_REMOVED.." ["..name.."].|r")
end


----------------------------------------------------------------------------------------
--	Event Registration
----------------------------------------------------------------------------------------
frame:RegisterEvent("UNIT_AURA")

----------------------------------------------------------------------------------------
--	Core Functionality
----------------------------------------------------------------------------------------
local function CancelBadBuffs(unit)
	local i = 1
	while true do
		local name = UnitBuff(unit, i)
		if not name then return end
		
		if T.BadBuffs[name] then
			CancelSpellByName(name)
			PrintBuffRemoved(name)
		end
		
		i = i + 1
	end
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
frame:SetScript("OnEvent", function(_, event, unit)
	if event == "UNIT_AURA" and unit == "player" and not InCombatLockdown() then
		CancelBadBuffs(unit)
	end
end)

