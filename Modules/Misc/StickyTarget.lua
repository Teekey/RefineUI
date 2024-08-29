local R, C, L = unpack(RefineUI)
----------------------------------------------------------------------------------------
--	Sticky Targeting
----------------------------------------------------------------------------------------
if C.misc.stickyTargeting == true then
    local function toggleSticky(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            SetCVar("deselectOnClick", 0)  -- Disable deselecting on click in combat (sticky targeting ON)
        else
            SetCVar("deselectOnClick", 1)  -- Enable deselecting on click out of combat (sticky targeting OFF)
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:SetScript("OnEvent", toggleSticky)

    -- Check initial combat state and set the CVar accordingly
    if InCombatLockdown() then
        SetCVar("deselectOnClick", 0)  -- Sticky targeting ON
    else
        SetCVar("deselectOnClick", 1)  -- Sticky targeting OFF
    end
end