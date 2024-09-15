----------------------------------------------------------------------------------------
--	Combat Crosshair for RefineUI
--	This module displays a crosshair on the screen when the player enters combat.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)
if C.combatcrosshair.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Crosshair Frame Creation
----------------------------------------------------------------------------------------

local combatCrosshair = CreateFrame("Frame", nil, UIParent)
combatCrosshair:SetFrameStrata("DIALOG")
combatCrosshair:SetWidth(C.combatcrosshair.size)
combatCrosshair:SetHeight(C.combatcrosshair.size)
combatCrosshair:SetPoint("CENTER", C.combatcrosshair.offsetx, C.combatcrosshair.offsety)
combatCrosshair:Hide()

----------------------------------------------------------------------------------------
--	Crosshair Texture
----------------------------------------------------------------------------------------

local combatCrosshairTex = combatCrosshair:CreateTexture(nil, "BACKGROUND")
combatCrosshairTex:SetTexture(C.combatcrosshair.texture)
combatCrosshairTex:SetAllPoints(combatCrosshair)
combatCrosshairTex:SetVertexColor(1, 1, 1, .6)
combatCrosshair.texture = combatCrosshairTex

----------------------------------------------------------------------------------------
--	Combat Event Handling
----------------------------------------------------------------------------------------

combatCrosshair:RegisterEvent("PLAYER_REGEN_DISABLED")
combatCrosshair:RegisterEvent("PLAYER_REGEN_ENABLED")

combatCrosshair:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
        combatCrosshair:Show()
	elseif event == "PLAYER_REGEN_ENABLED" then
        combatCrosshair:Hide()
	end
end)