----------------------------------------------------------------------------------------
--	Combat Cursor for RefineUI
--	This module displays a ring around the cursor when the player is in combat.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)
if C.combatcursor.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Cursor Frame Creation
----------------------------------------------------------------------------------------

local combatCursor = CreateFrame("Frame", nil, UIParent)
combatCursor:SetFrameStrata("BACKGROUND")
combatCursor:SetWidth(C.combatcursor.size)
combatCursor:SetHeight(C.combatcursor.size)
combatCursor:Hide()

----------------------------------------------------------------------------------------
--	Cursor Texture
----------------------------------------------------------------------------------------

local combatCursorTex = combatCursor:CreateTexture(nil, "BACKGROUND")
combatCursorTex:SetTexture(C.combatcursor.texture)
combatCursorTex:SetAllPoints(combatCursor)
combatCursorTex:SetVertexColor(1, 1, 1, .9)
combatCursor.texture = combatCursorTex

----------------------------------------------------------------------------------------
--	Cursor Position Update
----------------------------------------------------------------------------------------

combatCursor:SetScript("OnUpdate", function(self)
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        x, y = x / scale, y / scale
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end)

----------------------------------------------------------------------------------------
--	Combat Event Handling
----------------------------------------------------------------------------------------

combatCursor:RegisterEvent("PLAYER_REGEN_DISABLED")
combatCursor:RegisterEvent("PLAYER_REGEN_ENABLED")

combatCursor:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
                combatCursor:Show()
        elseif event == "PLAYER_REGEN_ENABLED" then
                combatCursor:Hide()
        end
end)
