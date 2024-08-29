local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

----------------------------------------------------------------------------------------
-- Upvalues and Constants
----------------------------------------------------------------------------------------
local UnitCanAttack, UnitIsPlayer, UnitClass, UnitReaction, GetTime, GetNetStats, UnitChannelInfo, CreateFrame =
    UnitCanAttack, UnitIsPlayer, UnitClass, UnitReaction, GetTime, GetNetStats, UnitChannelInfo, CreateFrame
local UnitIsConnected, UnitIsDead, UnitIsGhost, UnitIsTapDenied, UnitPower, UnitPowerMax, UnitPowerType =
    UnitIsConnected, UnitIsDead, UnitIsGhost, UnitIsTapDenied, UnitPower, UnitPowerMax, UnitPowerType
local UnitIsFriend, UnitFactionGroup, UnitIsPVPFreeForAll, UnitIsPVP =
    UnitIsFriend, UnitFactionGroup, UnitIsPVPFreeForAll, UnitIsPVP
local floor, abs, string, math, pairs, ipairs, next, unpack =
    floor, abs, string, math, pairs, ipairs, next, unpack

local PLAYER = "player"
local MAGIC = "Magic"

----------------------------------------------------------------------------------------
-- Globals
----------------------------------------------------------------------------------------
R.frameWidth = C.unitframes.frameWidth
R.frameHeight = C.unitframes.healthHeight + C.unitframes.powerHeight

R.partyWidth = C.group.partyWidth
R.partyHeight = C.group.partyHealthHeight + C.group.partyPowerHeight

C.group.icon_multiplier = (C.group.partyHealthHeight + C.group.partyPowerHeight) / 26

-- R.raidWidth = C.raid.frameWidth
-- R.raidHeight = C.raid.healthHeight + C.raid.powerHeight

----------------------------------------------------------------------------------------
--	General Functions
----------------------------------------------------------------------------------------
UF.UpdateAllElements = function(frame)
    for _, v in ipairs(frame.__elements) do
        v(frame, "UpdateElement", frame.unit)
    end
end

----------------------------------------------------------------------------------------
-- Local Variables
----------------------------------------------------------------------------------------
local UF = {}

local playerUnits = {
    player = true,
    pet = true,
    vehicle = true
}

local ticks = {}

local day, hour, minute = 86400, 3600, 60
local FormatTime = function(s)
    if s >= day then
        return format("%dd", floor(s / day + 1))
    elseif s >= hour then
        return format("%dh", floor(s / hour + 1))
    elseif s >= minute then
        return format("%dm", floor(s / minute + 1))
    elseif s >= 5 then
        return floor(s + 1)
    end
    return format("%d", s)
end

----------------------------------------------------------------------------------------
--	Unit Categorization Function
----------------------------------------------------------------------------------------
-- local unitPatterns = {
--     { "^player$",      "player" },
--     { "^target$",      "target" },
--     { "^focus$",       "focus" },
--     { "^pet$",         "pet" },
--     { "^arena%d+$",    "arena" },
--     { "^boss%d+$",     "boss" },
--     { "^party%d+$",    "party" },
--     { "^raid%d+$",     "raid" },
--     { "^partypet%d+$", "pet" },
--     { "^raidpet%d+$",  "pet" },
-- }

-- local singleUnits = {
--     player = true,
--     target = true,
--     focus = true,
--     pet = true,
--     arena = true,
--     boss = true
-- }

-- -- This function categorizes a unit based on its name.
-- function UF.CategorizeUnit(self)
-- 	if self:GetParent():GetName():match("RefineUI_Party") then
-- 		self.isPartyRaid = true
-- 	elseif self:GetParent():GetName():match("RefineUI_Raid") then
-- 		self.isPartyRaid = true
--     else
--         self.isSingleUnit = true
-- 	end

--     for _, pattern in ipairs(unitPatterns) do
--         if string.match(unit, pattern[1]) then
--             local genericType = pattern[2]
--             return {
--                 isSingleUnit = singleUnits[genericType] or false,  -- True if it's a single unit like player, target, etc.
--                 isPartyRaid = genericType == "party" or genericType == "raid", -- True if it's a party or raid member
--                 genericType =
--                     genericType                                    -- The generic type of the unit (e.g., "player", "target", "raid")
--             }
--         end
--     end

--     -- If no match found, treat it as a single unit (default behavior)
--     return {
--         isSingleUnit = true,
--         isPartyRaid = false,
--         genericType = unit
--     }
-- end

----------------------------------------------------------------------------------------
-- Local Functions
----------------------------------------------------------------------------------------
local function SetHealthColor(health, r, g, b)
    health:SetStatusBarColor(r, g, b)
    if health.bg and health.bg.multiplier then
        local mu = health.bg.multiplier
        health.bg:SetVertexColor(r * mu, g * mu, b * mu)
    end
end

local function FormatHealthText(min, max, r, g, b)
    if C.unitframes.colorValue then
        if min ~= max then
            return string.format("|cffAF5050%d|r |cffD7BEA5-|r |cff%02x%02x%02x%d|r",
                floor(min / max * 100),
                r * 255, g * 255, b * 255, floor(min / max * 100))
        else
            return string.format("|cffr")
        end
    else
        return string.format("|cffffffff%d|r", floor(min / max * 100 + 0.5))
    end
end

local function SetCastbarColor(Castbar, r, g, b)
    Castbar:SetStatusBarColor(r, g, b)
    Castbar.bg:SetVertexColor(C.media.backdropColor[1], C.media.backdropColor[2], C.media.backdropColor[3], 1)
    Castbar.border:SetBackdropBorderColor(r, g, b)
    Castbar.Button.border:SetBackdropBorderColor(r, g, b)
end

local function SetButtonColor(button, r, g, b)
    button:SetBackdropBorderColor(r, g, b)
    if button.backdrop and button.backdrop.border then
        button.backdrop.border:SetBackdropBorderColor(r, g, b)
    end
end

local function CreateAuraTimer(self, elapsed)
    if self.timeLeft then
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            if not self.first then
                self.timeLeft = self.timeLeft - self.elapsed
            else
                self.timeLeft = self.timeLeft - GetTime()
                self.first = false
            end
            if self.timeLeft > 0 then
                self.remaining:Show()
                local time = FormatTime(self.timeLeft)
                self.remaining:SetText(time)
            else
                self.remaining:Hide()
                self:SetScript("OnUpdate", nil)
            end
            self.elapsed = 0
        end
    end
end

local function setBarTicks(Castbar, numTicks)
    local width = Castbar:GetWidth()
    local height = Castbar:GetHeight()

    for i = 1, #ticks do
        ticks[i]:Hide()
    end

    if numTicks and numTicks > 0 then
        local delta = width / numTicks

        for i = 1, numTicks do
            local tick = ticks[i]
            if not tick then
                tick = Castbar:CreateTexture(nil, "ARTWORK")
                tick:SetTexture(C.media.texture)
                tick:SetVertexColor(0, 0, 0, 0.5)
                tick:SetWidth(2)
                tick:SetDrawLayer("ARTWORK", 1)
                ticks[i] = tick
            end

            tick:SetHeight(height)
            tick:SetPoint("CENTER", Castbar, "RIGHT", -delta * i, 0)
            tick:Show()
        end
    end
end

----------------------------------------------------------------------------------------
-- UnitFrame Functions
----------------------------------------------------------------------------------------
-- Update Health
UF.PostUpdateHealth = function(health, unit, min, max)
    if unit and unit:find("arena%dtarget") then return end
    if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
        health:SetValue(0)
        if not UnitIsConnected(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_OFFLINE .. "|r")
        elseif UnitIsDead(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_DEAD .. "|r")
        elseif UnitIsGhost(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_GHOST .. "|r")
        end
    else
        local r, g, b
        if UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            if class then
                local color = R.oUF_colors.class[class]
                if color then
                    r, g, b = color[1], color[2], color[3]
                    health:SetStatusBarColor(r, g, b)
                end
            end
        else
            local reaction = UnitReaction(unit, "player")
            if reaction then
                local color = R.oUF_colors.reaction[reaction]
                if color then
                    r, g, b = color[1], color[2], color[3]
                    health:SetStatusBarColor(r, g, b)
                end
            end
        end

        if unit == "pet" then
            local _, class = UnitClass("player")
            r, g, b = unpack(R.oUF_colors.class[class])
            health:SetStatusBarColor(r, g, b)
            if health.bg and health.bg.multiplier then
                local mu = health.bg.multiplier
                health.bg:SetVertexColor(r * mu, g * mu, b * mu)
            end
        end

        if C.unitframes.barColorValue == true and not UnitIsTapDenied(unit) then
            r, g, b = health:GetStatusBarColor()
            local newr, newg, newb = oUF:ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

            health:SetStatusBarColor(newr, newg, newb)
            if health.bg and health.bg.multiplier then
                local mu = health.bg.multiplier
                health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
            end
        end

        if min ~= max then
            local percent = floor(min / max * 100)
            r, g, b = oUF:ColorGradient(min, max, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
            if C.unitframes.colorValue == true then
                health.value:SetFormattedText("|cff%02x%02x%02x%d|r", r * 255, g * 255, b * 255, percent)
            else
                health.value:SetFormattedText("|cffffffff%d|r", percent)
            end
        else
            if C.unitframes.colorValue == true then
                health.value:SetFormattedText("|cff559655%d|r", 100)
            else
                health.value:SetFormattedText("|cffffffff%d|r", 100)
            end
        end
    end
end

UF.PostUpdateRaidHealth = function(health, unit, min, max)
    local self = health:GetParent()
    local power = self.Power
    local border = self.backdrop
    if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
        health:SetValue(0)
        if not UnitIsConnected(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_OFFLINE .. "|r")
        elseif UnitIsDead(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_DEAD .. "|r")
        elseif UnitIsGhost(unit) then
            health.value:SetText("|cffD7BEA5" .. L_UF_GHOST .. "|r")
        end
    else
        local r, g, b
        if not UnitIsPlayer(unit) and UnitIsFriend(unit, "player") and C.unitframes.own_color ~= true then
            local c = R.oUF_colors.reaction[5]
            if c then
                r, g, b = c[1], c[2], c[3]
                health:SetStatusBarColor(r, g, b)
                if health.bg and health.bg.multiplier then
                    local mu = health.bg.multiplier
                    health.bg:SetVertexColor(r * mu, g * mu, b * mu)
                end
            end
        end
        if C.unitframes.bar_color_value == true and not UnitIsTapDenied(unit) then
            if C.unitframes.own_color == true then
                r, g, b = C.unitframes.uf_color[1], C.unitframes.uf_color[2], C.unitframes.uf_color[3]
            else
                r, g, b = health:GetStatusBarColor()
            end
            local newr, newg, newb = oUF:ColorGradient(min, max, 1, 0, 0, 1, 1, 0, r, g, b)

            health:SetStatusBarColor(newr, newg, newb)
            if health.bg and health.bg.multiplier then
                local mu = health.bg.multiplier
                health.bg:SetVertexColor(newr * mu, newg * mu, newb * mu)
            end
        end
        health.value:SetText("|cffffffff" .. math.floor(min / max * 100 + .5) .. "|r")
    end
    local _, class = UnitClass(unit)
    local color = R.oUF_colors.class[class]
    if color then
        self.GroupRoleIndicator:SetVertexColor(color[1], color[2], color[3])
        self.LeaderIndicator:SetVertexColor(color[1], color[2], color[3])
        self.AssistantIndicator:SetVertexColor(color[1], color[2], color[3])
    end
end

----------------------------------------------------------------------------------------
--	Power Functions
----------------------------------------------------------------------------------------
UF.PreUpdatePower = function(power, unit)
    local _, pToken = UnitPowerType(unit)

    local color = R.oUF_colors.power[pToken]
    if color then
        power:SetStatusBarColor(color[1], color[2], color[3])
    end
end

UF.PostUpdatePower = function(power, unit, cur, _, max)
    if unit and unit:find("arena%dtarget") then return end
    local self = power:GetParent()
    local pType, pToken = UnitPowerType(unit)
    local color = R.oUF_colors.power[pToken]

    if color then
        power.value:SetTextColor(color[1], color[2], color[3])
    end

    if not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit) then
        power:SetValue(0)
    end

    if unit == "focus" or unit == "focustarget" or unit == "targettarget" or (self:GetParent():GetName():match("oUF_RaidDPS")) then return end

    if not UnitIsConnected(unit) then
        power.value:SetText()
    elseif UnitIsDead(unit) or UnitIsGhost(unit) or max == 0 then
        power.value:SetText()
    end
end

----------------------------------------------------------------------------------------
--	Mana Level Functions
----------------------------------------------------------------------------------------
local SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup()
    self.anim:SetLooping("BOUNCE")
    self.anim.fade = self.anim:CreateAnimation("Alpha")
    self.anim.fade:SetFromAlpha(1)
    self.anim.fade:SetToAlpha(0)
    self.anim.fade:SetDuration(0.6)
    self.anim.fade:SetSmoothing("IN_OUT")
end

local Flash = function(self)
    if not self.anim then
        SetUpAnimGroup(self)
    end

    if not self.anim:IsPlaying() then
        self.anim:Play()
    end
end

local StopFlash = function(self)
    if self.anim then
        self.anim:Finish()
    end
end

UF.UpdateManaLevel = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.2 then return end
    self.elapsed = 0

    if UnitPowerType("player") == 0 then
        local cur = UnitPower("player", 0)
        local max = UnitPowerMax("player", 0)
        local percMana = max > 0 and (cur / max * 100) or 100
        if percMana <= 20 and not UnitIsDeadOrGhost("player") then
            self.ManaLevel:SetText("|cffaf5050" .. MANA_LOW:upper() .. "|r")
            Flash(self)
        else
            self.ManaLevel:SetText()
            StopFlash(self)
        end
    elseif R.class ~= "DRUID" and R.class ~= "PRIEST" and R.class ~= "SHAMAN" then
        self.ManaLevel:SetText()
        StopFlash(self)
    end
end

UF.UpdateClassMana = function(self)
    if self.unit ~= "player" then return end

    -- Ensure FlashInfo is initialized
    if not self.FlashInfo then
        self.FlashInfo = {} -- Initialize FlashInfo if it doesn't exist
    end

    if UnitPowerType("player") ~= 0 then
        local min = UnitPower("player", 0)
        local max = UnitPowerMax("player", 0)
        local percMana = max > 0 and (min / max * 100) or 100
        if percMana <= 20 and not UnitIsDeadOrGhost("player") then
            if not self.FlashInfo.ManaLevel then
                self.FlashInfo.ManaLevel = self:CreateFontString(nil, "OVERLAY") -- Create ManaLevel if it doesn't exist
                self.FlashInfo.ManaLevel:SetPoint("CENTER", self, "CENTER") -- Set position as needed
                self.FlashInfo.ManaLevel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") -- Set font as needed
            end
            self.FlashInfo.ManaLevel:SetText("|cffaf5050" .. MANA_LOW .. "|r")
            Flash(self.FlashInfo)
        else
            if self.FlashInfo.ManaLevel then
                self.FlashInfo.ManaLevel:SetText()
            end
            StopFlash(self.FlashInfo)
        end

        if min ~= max then
            if self.Power.value:GetText() then
                self.ClassMana:SetPoint("RIGHT", self.Power.value, "LEFT", -1, 0)
                self.ClassMana:SetFormattedText("%d%%|r |cffD7BEA5-|r", floor(min / max * 100))
                self.ClassMana:SetJustifyH("RIGHT")
            else
                self.ClassMana:SetPoint("LEFT", self.Power, "LEFT", 4, 0)
                self.ClassMana:SetFormattedText("%d%%", floor(min / max * 100))
            end
        else
            self.ClassMana:SetText()
        end

        self.ClassMana:SetAlpha(1)
    else
        self.ClassMana:SetAlpha(0)
    end
end

----------------------------------------------------------------------------------------
--	PvP Status Functions
----------------------------------------------------------------------------------------
UF.UpdatePvPStatus = function(self)
    local unit = self.unit

    if self.Status then
        local factionGroup = UnitFactionGroup(unit)
        if UnitIsPVPFreeForAll(unit) then
            self.Status:SetText(PVP)
        elseif factionGroup and UnitIsPVP(unit) then
            self.Status:SetText(PVP)
        else
            self.Status:SetText("")
        end
    end
end

----------------------------------------------------------------------------------------
--	Cast Bar Functions
----------------------------------------------------------------------------------------
local ticks = {}
local setBarTicks = function(Castbar, numTicks)
    for _, v in pairs(ticks) do
        v:Hide()
    end
    if numTicks and numTicks > 0 then
        local delta = Castbar:GetWidth() / numTicks
        for i = 1, numTicks do
            if not ticks[i] then
                ticks[i] = Castbar:CreateTexture(nil, "OVERLAY")
                ticks[i]:SetTexture(C.media.texture)
                ticks[i]:SetVertexColor(unpack(C.media.borderColor))
                ticks[i]:SetWidth(1)
                ticks[i]:SetHeight(Castbar:GetHeight())
                ticks[i]:SetDrawLayer("OVERLAY", 7)
            end
            ticks[i]:ClearAllPoints()
            ticks[i]:SetPoint("CENTER", Castbar, "RIGHT", -delta * i, 0)
            ticks[i]:Show()
        end
    end
end

local function castColor(unit)
    local r, g, b
    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        local color = R.oUF_colors.class[class]
        if color then
            r, g, b = color[1], color[2], color[3]
        end
    else
        local reaction = UnitReaction(unit, "player")
        local color = R.oUF_colors.reaction[reaction]
        if color and reaction >= 5 then
            r, g, b = color[1], color[2], color[3]
        else
            r, g, b = 0.85, 0.77, 0.36
        end
    end

    return r, g, b
end

local function SetCastbarColor(Castbar, r, g, b)
    Castbar:SetStatusBarColor(r, g, b)
    Castbar.bg:SetVertexColor(r, g, b)
    Castbar.border:SetBackdropBorderColor(r, g, b)
    Castbar.Button.border:SetBackdropBorderColor(r, g, b)
end

local function SetButtonColor(button, r, g, b)
    button:SetBackdropBorderColor(r, g, b)
    if button.backdrop and button.backdrop.border then
        button.backdrop.border:SetBackdropBorderColor(r, g, b)
    end
end

UF.PostCastStart = function(Castbar, unit)
    unit = unit == "vehicle" and PLAYER or unit

    local r, g, b
    if UnitCanAttack(PLAYER, unit) then
        r, g, b = unpack(Castbar.notInterruptible and R.oUF_colors.notinterruptible or
            R.oUF_colors.interruptible)
    elseif UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        r, g, b = unpack(R.oUF_colors.class[class])
    else
        local color = R.oUF_colors.reaction[UnitReaction(unit, PLAYER)]
        r, g, b = color[1], color[2], color[3]
    end
    SetCastbarColor(Castbar, r, g, b)
    Castbar.bg:SetVertexColor(r, g, b, 0.1)

    -- Safely set the button border color
    if Castbar.Button then
        if Castbar.Button.SetBackdropBorderColor then
            Castbar.Button:SetBackdropBorderColor(r, g, b, 1)
        elseif Castbar.Button.SetBorderColor then
            Castbar.Button:SetBorderColor(r, g, b, 1)
        elseif Castbar.Button.Border then
            Castbar.Button.Border:SetVertexColor(r, g, b, 1)
        end
    end

    if not Castbar.Button.Cooldown then
        Castbar.Button.Cooldown = CreateFrame("Cooldown", nil, Castbar.Button, "CooldownFrameTemplate")
        Castbar.Button.Cooldown:SetAllPoints()
        Castbar.Button.Cooldown:SetReverse(false)
        Castbar.Button.Cooldown:SetDrawEdge(false)
        Castbar.Button.Cooldown:SetSwipeColor(0, 0, 0, 0.8)
    end

    local start = GetTime()
    local duration = Castbar.max or 0

    if Castbar.channeling then
        local name, _, _, startTimeMS = UnitChannelInfo(unit)
        if name and startTimeMS then
            start = startTimeMS / 1000
            duration = Castbar.max or (Castbar.endTime and (Castbar.endTime - start)) or 0
        end
    end
    Castbar.Button.Cooldown:SetCooldown(start, duration)

    if unit == PLAYER then
        if C.unitframes.castbarLatency and Castbar.Latency then
            local _, _, _, ms = GetNetStats()
            Castbar.Latency:SetFormattedText("%dms", ms)
            Castbar.SafeZone:SetDrawLayer(Castbar.casting and "BORDER" or "ARTWORK")
            Castbar.SafeZone:SetVertexColor(0.85, 0.27, 0.27, Castbar.casting and 1 or 0.75)
        end

        if C.unitframes.castbarTicks then
            if Castbar.casting then
                setBarTicks(Castbar, 0)
            else
                local spell = UnitChannelInfo(unit)
                Castbar.channelingTicks = R.CastBarTicks[spell] or 0
                setBarTicks(Castbar, Castbar.channelingTicks)
            end
        end
    end
end

UF.CustomCastTimeText = function(self, duration)
    if duration > 600 then
        self.Time:SetText("∞")
    else
        self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
    end
end

UF.CustomCastDelayText = function(self, duration)
    self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration,
        self.channeling and "-" or "+", abs(self.delay)))
end

----------------------------------------------------------------------------------------
--	Aura Tracking Functions
----------------------------------------------------------------------------------------
UF.AuraTrackerTime = function(self, elapsed)
    if self.active then
        self.timeleft = self.timeleft - elapsed
        if self.timeleft <= 5 then
            self.text:SetTextColor(1, 0, 0)
        else
            self.text:SetTextColor(1, 1, 1)
        end
        if self.timeleft <= 0 then
            self.icon:SetTexture("")
            self.text:SetText("")
        end
        self.text:SetFormattedText("%.1f", self.timeleft)
    end
end

UF.HideAuraFrame = function(self)
    if self.unit == "player" then
        BuffFrame:Hide()
        self.Debuffs:Hide()
    elseif self.unit == "pet" or self.unit == "focus" or self.unit == "focustarget" or self.unit == "targettarget" then
        self.Debuffs:Hide()
    end
end

UF.PostCreateIcon = function(element, button)
    button:SetTemplate("Icon")
    button.border:SetFrameStrata("LOW")

    button.remaining = R.SetFontString(button, C.font.auras_font, C.font.auras_font_size, C.font.auras_font_style)
    button.remaining:SetPoint("CENTER", button, "CENTER", 1, 1)
    button.remaining:SetJustifyH("CENTER")

    button.Cooldown.noCooldownCount = true
    button.Icon:SetPoint("TOPLEFT", 2, -2)
    button.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 3)
    button.Count:SetJustifyH("RIGHT")
    button.Count:SetFont(C.font.auras_font, C.font.auras_font_size, C.font.auras_font_style)

    element.disableCooldown = false
    local cooldown = button.Cooldown
    cooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CDAura.blp")
    cooldown:SetParent(button)
    cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
    cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(false)
    cooldown:SetSwipeColor(0, 0, 0, .6)


    -- Castbar.Button.Cooldown = CreateFrame("Cooldown", nil, Castbar.Button, "CooldownFrameTemplate")
    -- Castbar.Button.Cooldown:SetAllPoints()
    -- Castbar.Button.Cooldown:SetReverse(true)
    -- Castbar.Button.Cooldown:SetDrawEdge(false)
    -- Castbar.Button.Cooldown:SetSwipeColor(0, 0, 0, 0.8)


    local parent = CreateFrame("Frame", nil, button)
    parent:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    button.Count:SetParent(parent)

    button.remaining:SetParent(parent)
    button.parent = parent
end

local day, hour, minute = 86400, 3600, 60
local FormatTime = function(s)
    if s >= day then
        return format("%dd", floor(s / day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s / hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s / minute + 0.5))
    elseif s >= 5 then
        return floor(s + 0.5)
    end
    return format("%.1f", s)
end

UF.CreateAuraTimer = function(self, elapsed)
    if self.timeLeft then
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            if not self.first then
                self.timeLeft = self.timeLeft - self.elapsed
            else
                self.timeLeft = self.timeLeft - GetTime()
                self.first = false
            end
            if self.timeLeft > 0 then
                local time = FormatTime(self.timeLeft)
                self.remaining:SetText(time)
            else
                self.remaining:Hide()
                self:SetScript("OnUpdate", nil)
            end
            self.elapsed = 0
        end
    end
end


local playerUnits = {
    player = true,
    pet = true,
    vehicle = true,
}

UF.PostUpdateIcon = function(_, button, unit, data)
    local isPlayerUnit = (unit == "player" or unit == "pet")

    if data.isHarmful then
        if not UnitIsFriend("player", unit) and not isPlayerUnit then
            if not C.aura.playerAuraOnly then
                button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
                button.Icon:SetDesaturated(true)
            end
        else
            if C.aura.debuffColorType == true then
                local color = DebuffTypeColor[data.dispelName] or DebuffTypeColor.none
                button.border:SetBackdropBorderColor(color.r, color.g, color.b)
                button.Icon:SetDesaturated(false)
            else
                button:SetBackdropBorderColor(1, 0, 0)
            end
        end
    else
        -- This is the buff section
        if (data.isStealable or ((R.class == "MAGE" or R.class == "PRIEST" or R.class == "SHAMAN" or R.class == "HUNTER") and data.dispelName == "Magic")) and not UnitIsFriend("player", unit) then
            button.border:SetBackdropBorderColor(1, 0.85, 0)
        elseif data.duration and data.duration > 0 then
            -- Set the border color to green for buffs with duration
            button.border:SetBackdropBorderColor(0, 1, 0) -- RGB values for green
        else
            -- Use default border color for permanent/passive buffs
            button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
        end
        button.Icon:SetDesaturated(false)
    end

    -- button.remaining:Hide()
    button.timeLeft = math.huge
    button:SetScript("OnUpdate", nil)

    button.first = true
end

UF.CustomFilter = function(element, unit, data)
    if C.aura.player_aura_only then
        if data.isHarmful then
            if not UnitIsFriend("player", unit) and not playerUnits[data.sourceUnit] then
                return false
            end
        end
    end
    return true
end

UF.CustomFilterBoss = function(element, unit, data)
    if data.isHarmful then
        if (playerUnits[data.sourceUnit] or data.sourceUnit == unit) then
            if (R.DebuffBlackList and not R.DebuffBlackList[data.name]) or not R.DebuffBlackList then
                return true
            end
        end
        return false
    end
    return true
end

----------------------------------------------------------------------------------------
-- Flash Animations
----------------------------------------------------------------------------------------
local function SetUpAnimGroup(self)
    self.anim = self:CreateAnimationGroup()
    self.anim:SetLooping("BOUNCE")
    self.anim.fade = self.anim:CreateAnimation("Alpha")
    self.anim.fade:SetFromAlpha(1)
    self.anim.fade:SetToAlpha(0)
    self.anim.fade:SetDuration(0.6)
    self.anim.fade:SetSmoothing("IN_OUT")
end

local function Flash(self)
    if not self.anim then
        SetUpAnimGroup(self)
    end

    if not self.anim:IsPlaying() then
        self.anim:Play()
    end
end

local function StopFlash(self)
    if self.anim then
        self.anim:Finish()
    end
end

function UF.UpdateManaLevel(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.2 then return end
    self.elapsed = 0

    if UnitPowerType(PLAYER) == 0 then
        local cur = UnitPower(PLAYER, 0)
        local max = UnitPowerMax(PLAYER, 0)
        local percMana = max > 0 and (cur / max * 100) or 100
        if percMana <= 25 and not UnitIsDeadOrGhost(PLAYER) then
            self.ManaLevel:SetText("|cffaf5050" .. L_UF_MANA .. "|r")
            Flash(self)
        else
            self.ManaLevel:SetText()
            StopFlash(self)
        end
    elseif R.class ~= "DRUID" and R.class ~= "PRIEST" and R.class ~= "SHAMAN" then
        self.ManaLevel:SetText()
        StopFlash(self)
    end
end

----------------------------------------------------------------------------------------
-- PvP Status
----------------------------------------------------------------------------------------
function UF.UpdatePvPStatus(self)
    local unit = self.unit

    if self.Status then
        local factionGroup = UnitFactionGroup(unit)
        if UnitIsPVPFreeForAll(unit) then
            self.Status:SetText(PVP)
        elseif factionGroup and UnitIsPVP(unit) then
            self.Status:SetText(PVP)
        else
            self.Status:SetText("")
        end
    end
end

----------------------------------------------------------------------------------------
--	Aura Watch Functions
----------------------------------------------------------------------------------------
local CountOffSets = {
    Normal = {
        [1] = { "TOPRIGHT", "TOPRIGHT", 0, 0 }, -- Top Right
        [2] = { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0 }, -- Bottom Right
        [3] = { "BOTTOMLEFT", "BOTTOMLEFT", 0, 0 }, -- Bottom Left
        [4] = { "TOPLEFT", "TOPLEFT", 0, 0 },   -- Top Left
    },
    Reversed = {
        [1] = { "TOPLEFT", "TOPLEFT", 0, 0 },   -- Top Left
        [2] = { "BOTTOMLEFT", "BOTTOMLEFT", 0, 0 }, -- Bottom Left
        [3] = { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0 }, -- Bottom Right
        [4] = { "TOPRIGHT", "TOPRIGHT", 0, 0 }, -- Top Right
    }
}

UF.CreateAuraWatch = function(self, buffs, name, anchorPoint, size, filter, reverseGrowth)
    local auras = CreateFrame("Frame", nil, self)
    auras:SetPoint(anchorPoint[1], self[anchorPoint[2]], anchorPoint[3], anchorPoint[4], anchorPoint[5])
    auras:SetSize(size, size)

    auras.icons = {}
    auras.PostCreateIcon = UF.CreateAuraWatchIcon

    -- Create icons for all buffs
    for _, spell in ipairs(buffs) do
        local icon = CreateFrame("Frame", nil, auras)
        icon.spellID = spell[1]
        icon.anyUnit = spell[4]
        icon.strictMatching = spell[5]
        icon:SetSize(size / 2 - 1, size / 2 - 1)

        -- Set frame level for each icon
        -- icon:SetFrameLevel(auras:GetFrameLevel() + 1)

        icon:SetTemplate("Icon")
        icon.border:SetFrameStrata("LOW")

        local borderColor = spell[2] or C.media.borderColor
        icon.border:SetBackdropBorderColor(unpack(borderColor))


        -- local texFrame = CreateFrame("Frame", nil, icon)
        -- texFrame:SetAllPoints(icon)
        -- texFrame:SetFrameLevel(icon:GetFrameLevel() + 1)

        -- local tex = texFrame:CreateTexture(nil, "OVERLAY")
        -- tex:SetSize(size / 2 - 7, size / 2 - 7)
        -- tex:SetPoint("CENTER", texFrame, "CENTER", 0, 0)
        -- icon.icon = tex

        -- local spellTexture = C_Spell.GetSpellTexture(icon.spellID)
        -- if spellTexture then
        --     icon:SetTexture(spellTexture)
        --     icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        -- end

        -- local count = UF.SetFontString(icon, C.font.unit_frames_font, C.font.unit_frames_font_size,
        -- 	C.font.unit_frames_font_style)
        -- count:SetPoint("CENTER", icon, "CENTER", 0, 0)
        -- icon.count = count

                -- Create cooldown frame
        -- icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        -- icon.cooldown:SetPoint("TOPLEFT", icon, "TOPLEFT", -2, 2)
        -- icon.cooldown:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
        -- icon.cooldown:SetReverse(true)  -- Set to reverse if desired
        -- icon.cooldown.noCooldownCount = true  -- Disable the default cooldown count
        -- icon.cooldown:SetFrameLevel(icon:GetFrameLevel() + 10)
        

        icon:Hide() -- Hide all icons initially

        auras.icons[spell[1]] = icon
    end

    -- Function to update auras and manage visibility
    auras.UpdateAuras = function(self, unit)
        if not unit then
            return
        end

        local visibleIcons = {}
        for i = 1, 40 do
            local name, icon, count, _, duration, expirationTime, unitCaster, _, _, spellID = UnitAura(unit, i, filter)
            if not name then break end

            local watchIcon = self.icons[spellID]
            if watchIcon then
                if (filter == "HELPFUL|PLAYER") or (filter == "HELPFUL" and (not UnitIsUnit(unitCaster, "player"))) then
                    watchIcon.count:SetText(count > 1 and count or "")
                    watchIcon.expirationTime = expirationTime
                    watchIcon.duration = duration
                    -- watchIcon.cooldown:SetCooldown(expirationTime - duration, duration)  -- Set cooldown here
                    watchIcon:SetScript("OnUpdate", UF.UpdateAuraTimer)
                    table.insert(visibleIcons, watchIcon)
                end
            end
        end

        -- Sort visible icons by expiration time (oldest first)
        table.sort(visibleIcons, function(a, b)
            return (a.expirationTime or 0) < (b.expirationTime or 0)
        end)

        -- Show and position the first 4 visible icons
        local offsetSet = reverseGrowth and CountOffSets.Reversed or CountOffSets.Normal
        for i = 1, math.min(4, #visibleIcons) do
            local icon = visibleIcons[i]
            local point, anchorPoint, x, y = unpack(offsetSet[i])
            icon:ClearAllPoints()
            icon:SetPoint(point, self, anchorPoint, x, y)
            icon:SetAlpha(1)
            icon:Show()
        end

        -- Hide any remaining icons
        for i = 5, #visibleIcons do
            visibleIcons[i]:Hide()
            visibleIcons[i]:ClearAllPoints()
        end

        -- Hide all unused icons
        for _, icon in pairs(self.icons) do
            if not tContains(visibleIcons, icon) then
                icon:Hide()
                icon:ClearAllPoints()
            end
        end
    end

    auras:RegisterEvent("UNIT_AURA")
    auras:SetScript("OnEvent", function(frame, event, unit)
        if unit == self.unit or (self.unit == "player" and unit == "vehicle") then
            frame.UpdateAuras(frame, unit)
        end
    end)

    self[name] = auras

    -- Initial update
    auras.UpdateAuras(auras, self.unit)

    return auras
end

-- Function to create the original AuraWatch (player buffs)
UF.CreatePlayerBuffWatch = function(self)
    local buffs = {}

    -- Collect buffs
    if R.RaidBuffs["ALL"] then
        for _, value in pairs(R.RaidBuffs["ALL"]) do
            tinsert(buffs, value)
        end
    end

    if R.RaidBuffs[R.class] then
        for _, value in pairs(R.RaidBuffs[R.class]) do
            tinsert(buffs, value)
        end
    end

    return UF.CreateAuraWatch(self, buffs, "AuraWatch", { "BOTTOMRIGHT", "Health", "TOPRIGHT", 4, 6 }, 40,
        "HELPFUL|PLAYER")
end

-- Function to create a new AuraWatch for other players' buffs
UF.CreatePartyBuffWatch = function(self)
    local buffs = {}

    -- Collect all buffs from R.RaidBuffs, regardless of category
    for category, buffList in pairs(R.RaidBuffs) do
        for _, value in pairs(buffList) do
            tinsert(buffs, value)
        end
    end

    return UF.CreateAuraWatch(self, buffs, "OtherPlayersAuraWatch", { "BOTTOMLEFT", "Health", "TOPLEFT", -4, 6 }, 40,
        "HELPFUL", true)
end

-- Check for existing buffs when entering world or reloading UI
local function InitialAuraCheck(frame)
    if frame.AuraWatch then
        frame.AuraWatch.UpdateAuras(frame.AuraWatch, frame.unit)
    end
    if frame.OtherPlayersAuraWatch then
        frame.OtherPlayersAuraWatch.UpdateAuras(frame.OtherPlayersAuraWatch, frame.unit)
    end
end

-- Register for PLAYER_ENTERING_WORLD event
local initialCheckFrame = CreateFrame("Frame")
initialCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initialCheckFrame:SetScript("OnEvent", function()
    for _, frame in pairs(oUF.objects) do
        InitialAuraCheck(frame)
    end
    -- Unregister the event after the initial check
    initialCheckFrame:UnregisterAllEvents()
end)

----------------------------------------------------------------------------------------
--	Health Prediction Functions
----------------------------------------------------------------------------------------
-- UF.CreateHealthPrediction = function(self)
--     local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
--     mhpb:SetTexture(C.media.texture)
--     mhpb:SetVertexColor(0, 1, 0.5, 0.2)

--     local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
--     ohpb:SetTexture(C.media.texture)
--     ohpb:SetVertexColor(0, 1, 0, 0.2)

--     local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
--     ahpb:SetTexture(C.media.texture)
--     ahpb:SetVertexColor(1, 1, 0, 0.2)

--     local hab = self.Health:CreateTexture(nil, "ARTWORK")
--     hab:SetTexture(C.media.texture)
--     hab:SetVertexColor(1, 0, 0, 0.4)

--     local oa = self.Health:CreateTexture(nil, "ARTWORK")
--     oa:SetTexture([[Interface\AddOns\TKUI\Media\Textures\Cross.tga]], "REPEAT", "REPEAT")
--     oa:SetVertexColor(0.5, 0.5, 1)
--     oa:SetHorizTile(true)
--     oa:SetVertTile(true)
--     oa:SetAlpha(0.4)
--     oa:SetBlendMode("ADD")

--     local oha = self.Health:CreateTexture(nil, "ARTWORK")
--     oha:SetTexture([[Interface\AddOns\TKUI\Media\Textures\Cross.tga]], "REPEAT", "REPEAT")
--     oha:SetVertexColor(1, 0, 0)
--     oha:SetHorizTile(true)
--     oha:SetVertTile(true)
--     oha:SetAlpha(0.4)
--     oha:SetBlendMode("ADD")

--     self.HealthPrediction = {
--         myBar = mhpb,                                           -- Represents predicted health from your heals
--         otherBar = ohpb,                                        -- Represents predicted health from other heals
--         absorbBar = ahpb,                                       -- Represents predicted absorb shields
--         healAbsorbBar = hab,                                    -- Represents predicted heals that will be absorbed
--         overAbsorb = C.raidframe.plugins_over_absorb and oa,    -- Texture for over-absorption
--         overHealAbsorb = C.raidframe.plugins_over_heal_absorb and oha -- Texture for over-heal-absorb
--     }
-- end

-- Create a metatable
local mt = {
    __index = function(t, k)
        if UF[k] then
            return UF[k]
        else
            return rawget(t, k)
        end
    end
}

-- Set the metatable to R
setmetatable(R, mt)

-- Return R at the end of your file
R.UF = UF
return R
