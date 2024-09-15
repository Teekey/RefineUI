local R, C, L = unpack(RefineUI)

local function CreateConfigurableFeature(name, enabledSetting, setup)
    if enabledSetting then
        setup()
    end
end

-- Sticky Targeting
CreateConfigurableFeature("StickyTargeting", C.misc.stickyTargeting, function()
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(_, event)
        Settings.SetValue("deselectOnClick", event == "PLAYER_REGEN_DISABLED")
    end)
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
end)

-- Disable Right Click Camera Rotation in Combat
CreateConfigurableFeature("DisableRightClickCombat", C.misc.disableRightClickCombat, function()
    local combatFrame = CreateFrame("Frame")
    local originalOnMouseUp = WorldFrame:GetScript("OnMouseUp")

    local function customOnMouseUp(self, button)
        if button == "RightButton" then
            MouselookStop()
        end
        if originalOnMouseUp then
            originalOnMouseUp(self, button)
        end
    end

    combatFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_DISABLED" then
            WorldFrame:SetScript("OnMouseUp", customOnMouseUp)
        else
            WorldFrame:SetScript("OnMouseUp", originalOnMouseUp)
        end
    end)

    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
end)