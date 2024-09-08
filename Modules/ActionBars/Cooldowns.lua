local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
-- Upvalues and Constants
----------------------------------------------------------------------------------------

-- Localize global functions for performance
local format, floor, GetTime = string.format, math.floor, GetTime
local CreateFrame, hooksecurefunc = CreateFrame, hooksecurefunc
local UIParent = UIParent
local day, hour, minute = 86400, 3600, 60

----------------------------------------------------------------------------------------
-- Time Formatting
----------------------------------------------------------------------------------------

local function GetFormattedTime(s)
    if s >= day then
        return format("%dd", floor(s / day + 0.5)), s % day
    elseif s >= hour then
        return format("%dh", floor(s / hour + 0.5)), s % hour
    elseif s >= minute then
        return format("%dm", floor(s / minute + 0.5)), s % minute
    end
    return floor(s + 0.5), s - floor(s)
end

----------------------------------------------------------------------------------------
-- Timer Methods
----------------------------------------------------------------------------------------

local function Timer_Stop(self)
    self.enabled = nil
    self:Hide()
end

local function Timer_ForceUpdate(self)
    self.nextUpdate = 0
    self:Show()
end

local function Timer_OnSizeChanged(self, width)
    local fontScale = R.Round(width) / 40
    if fontScale == self.fontScale then return end

    self.fontScale = fontScale
    if fontScale < 0.5 then
        self:Hide()
    else
        self.text:SetFont(unpack(C.font.cooldownTimers))
        self.text:SetShadowOffset(1, -1)
        if self.enabled then Timer_ForceUpdate(self) end
    end
end

local function Timer_OnUpdate(self, elapsed)
    if not self.text:IsShown() then return end

    self.nextUpdate = self.nextUpdate - elapsed
    if self.nextUpdate > 0 then return end

    if (self:GetEffectiveScale() / UIParent:GetEffectiveScale()) < 0.5 then
        self.text:SetText("")
        self.nextUpdate = 1
    else
        local remain = self.duration - (GetTime() - self.start)
        if remain > 0 then
            local time, nextUpdate = GetFormattedTime(remain)
            self.text:SetText(time)
            self.nextUpdate = nextUpdate
            self.text:SetTextColor(remain > 5 and 1 or 0.85, remain > 5 and 1 or 0.27, remain > 5 and 1 or 0.27)
        else
            Timer_Stop(self)
        end
    end
end

----------------------------------------------------------------------------------------
-- Timer Creation
----------------------------------------------------------------------------------------

local function Timer_Create(self)
    local scaler = CreateFrame("Frame", nil, self)
    scaler:SetAllPoints(self)

    local timer = CreateFrame("Frame", nil, scaler)
    timer:Hide()
    timer:SetAllPoints(scaler)
    timer:SetScript("OnUpdate", Timer_OnUpdate)

    local text = timer:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 0, 0)
    text:SetJustifyH("CENTER")
    timer.text = text

    Timer_OnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript("OnSizeChanged", function(_, ...) Timer_OnSizeChanged(timer, ...) end)

    self.timer = timer
    return timer
end

----------------------------------------------------------------------------------------
-- Cooldown Handling
----------------------------------------------------------------------------------------

local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
local hideNumbers = {}

local function deactivateDisplay(cooldown)
    if cooldown.timer then Timer_Stop(cooldown.timer) end
end

local function setHideCooldownNumbers(cooldown, hide)
    hideNumbers[cooldown] = hide or nil
    if hide then deactivateDisplay(cooldown) end
end

hooksecurefunc(Cooldown_MT, "SetCooldown", function(cooldown, start, duration, modRate)
    local parent = cooldown:GetParent()
    if not parent or not parent:GetName() then
        return
    end

    -- Check if the parent button is one of the action buttons
    if not parent:GetName():match("ActionButton") and
        not parent:GetName():match("MultiBarBottomLeftButton") and
        not parent:GetName():match("MultiBarLeftButton") and
        not parent:GetName():match("MultiBarRightButton") and
        not parent:GetName():match("MultiBarBottomRightButton") and
        not parent:GetName():match("MultiBar5Button") and
        not parent:GetName():match("MultiBar6Button") and
        not parent:GetName():match("MultiBar7Button") and
        not parent:GetName():match("OverrideActionBarButton") then
        return
    end

    if cooldown.noCooldownCount or cooldown:IsForbidden() or hideNumbers[cooldown] then return end

    if start and start > 0 and duration and duration > 2 and (modRate == nil or modRate > 0) then
        if parent and parent.chargeCooldown == cooldown then return end

        local timer = cooldown.timer or Timer_Create(cooldown)
        timer.start = start
        timer.duration = duration
        timer.enabled = true
        timer.nextUpdate = 0
        if timer.fontScale >= 0.5 then timer:Show() end
    else
        deactivateDisplay(cooldown)
    end
end)

hooksecurefunc(Cooldown_MT, "Clear", deactivateDisplay)
hooksecurefunc(Cooldown_MT, "SetHideCountdownNumbers", setHideCooldownNumbers)
hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
    setHideCooldownNumbers(cooldown, true)
end)
