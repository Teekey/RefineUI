local R, C, L = unpack(RefineUI)

-- Color definitions
local COLORS = {
    NORMAL = {1, 1, 1},
    COOLDOWN = {.9, .9, .9},
    OUT_OF_RANGE = {1, 0.3, 0.3},
    OUT_OF_POWER = {0.3, 0.3, 1},
    UNUSABLE = {0.4, 0.4, 0.4}
}

-- Function to update button appearance
local function UpdateButtonState(button)
    if not button.icon then return end

    local action = button.action
    local isUsable, notEnoughMana = IsUsableAction(action)
    local inRange = IsActionInRange(action)
    local cooldownStart, cooldownDuration = GetActionCooldown(action)

    if cooldownStart > 0 and cooldownDuration > 1.5 then
        -- On cooldown
        button.icon:SetVertexColor(unpack(COLORS.COOLDOWN))
        button.icon:SetDesaturated(true)  -- Desaturate the icon
    elseif notEnoughMana then
        -- Not enough power/resources
        button.icon:SetVertexColor(unpack(COLORS.OUT_OF_POWER))
        button.icon:SetDesaturated(true)  -- Ensure icon is not desaturated
    elseif not isUsable then  -- Check if the action is unusable
        -- Unusable action
        button.icon:SetVertexColor(unpack(COLORS.UNUSABLE))  -- Use the OUT_OF_POWER color for unusable
        button.icon:SetDesaturated(false)  -- Desaturate the icon
    elseif inRange == false then
        -- Out of range
        button.icon:SetVertexColor(unpack(COLORS.OUT_OF_RANGE))
        button.icon:SetDesaturated(true)  -- Ensure icon is not desaturated
    else
        -- Normal state
        button.icon:SetVertexColor(unpack(COLORS.NORMAL))
        button.icon:SetDesaturated(false)  -- Ensure icon is not desaturated
    end
end

-- Function to hook into action button updates
local function HookActionButton(button)
    if not button:GetScript("OnUpdate") then
        button:HookScript("OnUpdate", function(self, elapsed)
            self.updateTimer = (self.updateTimer or 0) + elapsed
            if self.updateTimer >= 0.1 then
                UpdateButtonState(self)
                self.updateTimer = 0
            end
        end)
    end
end

-- Hook into existing action buttons
local function HookExistingButtons()
    local buttonTypes = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton"}
    for _, buttonType in ipairs(buttonTypes) do
        for i = 1, 12 do
            local button = _G[buttonType..i]
            if button then
                HookActionButton(button)
            end
        end
    end
end

-- Main frame for the addon
local frame = CreateFrame("Frame")

-- Initialize the addon
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        HookExistingButtons()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "ACTIONBAR_SLOT_CHANGED" then
        local slot = ...
        if slot then
            local buttonTypes = {"ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton"}
            for _, buttonType in ipairs(buttonTypes) do
                local button = _G[buttonType..slot]
                if button then
                    UpdateButtonState(button)
                end
            end
        end
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

-- Expose the update function for manual updates if needed
R.UpdateButtonState = UpdateButtonState


ExtraActionButton1.style:SetAlpha(0)
ExtraActionButton1.style:Hide()

ZoneAbilityFrame.Style:SetAlpha(0)
ZoneAbilityFrame.Style:Hide()