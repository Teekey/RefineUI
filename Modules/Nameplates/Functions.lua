local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local NP = R.NP
NP = {}

----------------------------------------------------------------------------------------
-- Aura Timer
----------------------------------------------------------------------------------------
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

local function CreateAuraTimer(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.1 then return end

    if self.first then
        self.timeLeft = self.timeLeft - GetTime()
        self.first = false
    else
        self.timeLeft = self.timeLeft - self.elapsed
    end

    if self.timeLeft > 0 then
        self.remaining:SetText(FormatTime(self.timeLeft))
    else
        self:SetScript("OnUpdate", nil)
    end
    self.elapsed = 0
end

----------------------------------------------------------------------------------------
-- Name Functions
----------------------------------------------------------------------------------------
function NP.threatColor(self, forced)
    if UnitIsPlayer(self.unit) then
        return
    end

    -- if C.nameplate.enhance_threat ~= true then
    -- 	SetColorBorder(self.Health, unpack(C.media.borderColor))
    -- end
    if UnitIsTapDenied(self.unit) then
        self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
        -- self.Health.bg:SetVertexColor(0.6 , 0.6 , 0.6)
    elseif UnitAffectingCombat("player") then
        local threatStatus = UnitThreatSituation("player", self.unit)
        if self.npcID == "120651" then     -- Explosives affix
            self.Health:SetStatusBarColor(unpack(C.nameplate.extraColor))
        elseif self.npcID == "174773" then -- Spiteful Shade affix
            if threatStatus == 3 then
                self.Health:SetStatusBarColor(unpack(C.nameplate.extraColor))
            else
                self.Health:SetStatusBarColor(unpack(C.nameplate.goodColor))
                -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
            end
        elseif threatStatus == 3 then -- securely tanking, highest threat
            if R.Role == "Tank" then
                if C.nameplate.enhanceThreat == true then
                    if C.nameplate.mobColorEnable and R.ColorPlate[self.npcID] then
                        self.Health:SetStatusBarColor(unpack(R.ColorPlate[self.npcID]))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.goodColor))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
                    end
                else
                    -- SetColorBorder(self.Health, unpack(C.nameplate.bad_color))
                end
            else
                if C.nameplate.enhanceThreat == true then
                    self.Health:SetStatusBarColor(unpack(C.nameplate.badColor))
                    -- self.Health.bg:SetVertexColor(unpack(C.nameplate.bad_colorbg))
                else
                    -- SetColorBorder(self.Health, unpack(C.nameplate.bad_color))
                end
            end
        elseif threatStatus == 2 then -- insecurely tanking, another unit have higher threat but not tanking
            if C.nameplate.enhanceThreat == true then
                self.Health:SetStatusBarColor(unpack(C.nameplate.nearColor))
                -- self.Health.bg:SetVertexColor(unpack(C.nameplate.near_colorbg))
            else
                -- SetColorBorder(self.Health, unpack(C.nameplate.near_color))
            end
        elseif threatStatus == 1 then -- not tanking, higher threat than tank
            if C.nameplate.enhanceThreat == true then
                self.Health:SetStatusBarColor(unpack(C.nameplate.nearColor))
                -- self.Health.bg:SetVertexColor(unpack(C.nameplate.near_colorbg))
            else
                -- SetColorBorder(self.Health, unpack(C.nameplate.near_color))
            end
        elseif threatStatus == 0 then -- not tanking, lower threat than tank
            if C.nameplate.enhanceThreat == true then
                if R.Role == "Tank" then
                    local offTank = false
                    if IsInRaid() then
                        for i = 1, GetNumGroupMembers() do
                            if UnitExists("raid" .. i) and not UnitIsUnit("raid" .. i, "player") and
                                UnitGroupRolesAssigned("raid" .. i) == "TANK" then
                                local isTanking = UnitDetailedThreatSituation("raid" .. i, self.unit)
                                if isTanking then
                                    offTank = true
                                    break
                                end
                            end
                        end
                    end
                    if offTank then
                        self.Health:SetStatusBarColor(unpack(C.nameplate.offTankColor))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.offtank_colorbg))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.badColor))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.bad_colorbg))
                    end
                else
                    if C.nameplate.mobColorEnable and R.ColorPlate[self.npcID] then
                        self.Health:SetStatusBarColor(unpack(R.ColorPlate[self.npcID]))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.goodColor))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
                    end
                end
            end
        end
    elseif not forced then
        self.Health:ForceUpdate()
    end
end

----------------------------------------------------------------------------------------
-- Utility Functions
----------------------------------------------------------------------------------------
function NP.CreateBorderFrame(frame, point)
    point = point or frame
    if point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 7
    })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 1)
end

function NP.CreateBorderFrameIcon(frame, point)
    point = point or frame
    if point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", point, "TOPLEFT", -4, 4)
    frame.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", 4, -4)
    frame.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 8
    })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
    frame.border:SetFrameStrata("MEDIUM")
end

local function SetColorBorder(frame, r, g, b)
    frame.border:SetBackdropBorderColor(r, g, b, 1)
end

----------------------------------------------------------------------------------------
-- Auras Functions
----------------------------------------------------------------------------------------
function NP.AurasCustomFilter(element, unit, data)
    if UnitIsFriend("player", unit) then return false end

    if data.isHarmful then
        if C.nameplate.trackDebuffs and (data.isPlayerAura or data.sourceUnit == "pet") then
            return (data.nameplateShowAll or data.nameplateShowPersonal) and not R.DebuffBlackList[data.name] or
                R.DebuffWhiteList[data.name]
        end
    else
        return R.BuffWhiteList[data.name] or data.isStealable
    end

    return false
end

function NP.AurasPostCreateIcon(element, button)
    NP.CreateBorderFrame(button)
    button.remaining = R.SetFontString(button, unpack(C.font.nameplates.auras))
    button.remaining:SetShadowOffset(1, -1)
    button.remaining:SetPoint("CENTER", button, "CENTER", 1, 0)
    button.remaining:SetJustifyH("CENTER")

    button.Cooldown.noCooldownCount = true

    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button.Count:SetPoint("BOTTOM", button, "TOP", 1, 0)
    button.Count:SetJustifyH("CENTER")
    button.Count:SetFont(unpack(C.font.nameplates.auras))
    button.Count:SetShadowOffset(1, -1)

    element.disableCooldown = false
    button.Cooldown:SetReverse(true)
    button.Cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    button.Cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

    button.parent = CreateFrame("Frame", nil, button)
    button.parent:SetFrameLevel(button.Cooldown:GetFrameLevel() + 1)
    button.Count:SetParent(button.parent)
    button.remaining:SetParent(button.parent)
end

function NP.AurasPostUpdateIcon(_, button, unit, data)
    if not UnitIsFriend("player", unit) then
        if data.isHarmful then
            if C.nameplate.trackDebuffs and (data.isPlayerAura or data.sourceUnit == "pet") then
                if C.nameplate.trackBuffs then
                    SetColorBorder(button, unpack(C.media.borderColor))
                end
            end
        else
            if R.BuffWhiteList[data.name] then
                SetColorBorder(button, 0, 0.5, 0)
            elseif data.isStealable then
                SetColorBorder(button, 1, 0.85, 0)
            end
        end
    end

    if data.duration and data.duration > 0 then
        button.remaining:Show()
        button.timeLeft = data.expirationTime
        button:SetScript("OnUpdate", CreateAuraTimer)
    else
        button.remaining:Hide()
        button.timeLeft = math.huge
        button:SetScript("OnUpdate", nil)
    end
    button.first = true
end

----------------------------------------------------------------------------------------
-- Post Updates
----------------------------------------------------------------------------------------
function NP.PostCastStart(self)
    self.Text:SetText(string.upper(self.Text:GetText()))

    if self.notInterruptible then
        local r, g, b = unpack(R.oUF_colors.notinterruptible)
        self:SetStatusBarColor(r, g, b)
        self.bg:SetColorTexture(r * .2, g * .2, b * .2)
        SetColorBorder(self, r, g, b)
        SetColorBorder(self.Button, r, g, b)
    else
        if C.nameplate.kickColor then
            local start = GetSpellCooldown(kickID)
            if start ~= 0 then
                self:SetStatusBarColor(1, 0.5, 0)
                self.bg:SetColorTexture(1 * .2, 0.5 * .2, 0 * .2)
                SetColorBorder(self, 1, 0.5, 0, 0.2)
                SetColorBorder(self.Button, 1, 0.5, 0, 1)
            else
                self:SetStatusBarColor(1, 0.8, 0)
                self.bg:SetColorTexture(1 * .2, 0.8 * .2, 0, 0.52 * .2)
                SetColorBorder(self, 1, 0.8, 0)
                SetColorBorder(self.Button, 1, 0.8, 0)
            end
        else
            local r, g, b = unpack(R.oUF_colors.interruptible)
            self:SetStatusBarColor(r, g, b)
            self.bg:SetColorTexture(r * .2, g * .2, b * .2)
            SetColorBorder(self, r, g, b)
            SetColorBorder(self.Button, r, g, b)
        end
    end

    if C.nameplate.castColor then
        if R.InterruptCast[self.spellID] then
            SetColorBorder(self, 1, 0.8, 0)
        elseif R.ImportantCast[self.spellID] then
            SetColorBorder(self, 1, 0, 0)
        else
            SetColorBorder(self, unpack(C.media.borderColor))
        end
    end

    if self.IconCooldown then
        self.IconCooldown:SetCooldown(GetTime(), self.max)
    end
end

function NP.HealthPostUpdate(self, unit, cur, max)
    local main = self:GetParent()
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    local isDead = UnitIsDead(unit)
    local visisble = nameplate:IsVisible()
    if isDead and visisble then
        RunNextFrame(function() main:Hide(); end)
    end

    local perc = 0
    if max and max > 0 then
        perc = cur / max
    end

    local r, g, b
    local mu = self.bg.multiplier
    local isPlayer = UnitIsPlayer(unit)
    local unitReaction = UnitReaction(unit, "player")
    if C.nameplate.enhanceThreat ~= true then
        if not UnitIsUnit("player", unit) and isPlayer and (unitReaction and unitReaction >= 5) then
            r, g, b = unpack(R.oUF_colors.power["MANA"])
            self:SetStatusBarColor(r, g, b)
            -- self.bg:SetVertexColor(r * mu, g * mu, b * mu)
        elseif not UnitIsTapDenied(unit) and not isPlayer then
            if C.nameplate.mobColorEnable and R.ColorPlate[main.npcID] then
                r, g, b = unpack(R.ColorPlate[main.npcID])
            else
                local reaction = R.oUF_colors.reaction[unitReaction]
                if reaction then
                    r, g, b = reaction[1], reaction[2], reaction[3]
                else
                    r, g, b = UnitSelectionColor(unit, true)
                end
            end

            self:SetStatusBarColor(r, g, b)
            -- self.bg:SetVertexColor(r * mu, g * mu, b * mu)
        end

        if isPlayer then
            if perc <= 0.5 and perc >= 0.2 then
                SetColorBorder(self, 1, 1, 0)
            elseif perc < 0.2 then
                SetColorBorder(self, 1, 0, 0)
            else
                SetColorBorder(self, unpack(C.media.borderColor))
            end
            -- elseif not isPlayer and C.nameplate.enhance_threat == true then
            -- 	if C.nameplate.low_health then
            -- 		if perc < C.nameplate.low_health_value then
            -- 			SetColorBorder(self, unpack(C.nameplate.low_health_color))
            -- 		else
            -- 			SetColorBorder(self, unpack(C.media.borderColor))
            -- 		end
            -- 	else
            -- 		SetColorBorder(self, unpack(C.media.borderColor))
            -- 	end
        end
    else
        NP.threatColor(main, true)
    end
end

----------------------------------------------------------------------------------------
-- Update Functions
----------------------------------------------------------------------------------------
function NP.UpdateTarget(self)
    local isTarget = UnitIsUnit(self.unit, "target")
    local isMe = UnitIsUnit(self.unit, "player")

    if isTarget and not isMe then
        -- SetColorBorder(self.Health, unpack(C.nameplate.targetBorderColor))
        self:SetAlpha(1)
        if C.nameplate.targetGlow then
            self.Glow:Show()
        end

        if C.nameplate.targetIndicator then
            if UnitIsFriend("player", self.unit) then
                self.RTargetIndicator:SetPoint("LEFT", self.Name, "RIGHT", 1, 1)
                self.LTargetIndicator:SetPoint("RIGHT", self.Name, "LEFT", -1, 1)
            else
                self.RTargetIndicator:SetPoint("LEFT", self.Health, "RIGHT", 1, 0)
                self.LTargetIndicator:SetPoint("RIGHT", self.Health, "LEFT", -1, 0)
            end
            self.RTargetIndicator:Show()
            self.LTargetIndicator:Show()
        end
    else
        -- SetColorBorder(self.Health, unpack(C.media.borderColor))
        if not UnitExists("target") or isMe then
            self:SetAlpha(1)
        else
            self:SetAlpha(C.nameplate.alpha)
        end
        if C.nameplate.targetGlow then
            self.Glow:Hide()
        end
        if C.nameplate.targetIndicator then
            self.RTargetIndicator:Hide()
            self.LTargetIndicator:Hide()
        end
    end
end

function NP.Callback(self, event, unit, nameplate)
    if not self then
        return
    end
    if unit then
        local unitGUID = UnitGUID(unit)
        self.npcID = unitGUID and select(6, strsplit('-', unitGUID))
        self.unitName = UnitName(unit)
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)
        self:Show()

        if UnitIsUnit(unit, "player") then
            if self.Power then self.Power:Show() end
            self.Name:Hide()
            self.Castbar:SetAlpha(0)
            self.RaidTargetIndicator:SetAlpha(0)
        else
            if self.Power then self.Power:Hide() end
            self.Name:Show()
            self.Castbar:SetAlpha(1)
            self.RaidTargetIndicator:SetAlpha(1)

            if self.widgetsOnly or (UnitWidgetSet(unit) and UnitIsOwnerOrControllerOfUnit("player", unit)) then
                self.Health:SetAlpha(0)
                -- self.Level:SetAlpha(0)
                self.Name:SetAlpha(0)
                self.Castbar:SetAlpha(0)
            else
                self.Health:SetAlpha(1)
                -- self.Level:SetAlpha(1)
                self.Name:SetAlpha(1)
                self.Castbar:SetAlpha(1)
            end

            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate.UnitFrame then
                if nameplate.UnitFrame.WidgetContainer then
                    nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
                end
            end

            if C.nameplate.onlyName then
                if UnitIsFriend("player", unit) then
                    self.Health:SetAlpha(0)
                    self.Title:Show()
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("CENTER", self, "CENTER", 0, 0)
                    -- self.Level:SetAlpha(0)
                    self.Castbar:SetAlpha(0)
                    if C.nameplate.targetGlow then
                        self.Glow:SetAlpha(0)
                    end
                else
                    self.Health:SetAlpha(1)
                    self.Title:Hide()
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 1)
                    -- self.Level:SetAlpha(1)
                    self.Castbar:SetAlpha(1)
                    if C.nameplate.targetGlow then
                        self.Glow:SetAlpha(1)
                    end
                end
            end
        end
    end
end

-- Set the metatable to R
setmetatable(R, {
    __index = function(t, k)
        if NP[k] then
            return NP[k]
        else
            return rawget(t, k)
        end
    end
})

R.NP = NP
return R
