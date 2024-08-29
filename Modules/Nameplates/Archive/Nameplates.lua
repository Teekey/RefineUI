local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local NP = R.NP or {}
R.NP = NP

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
                local time = R.FormatTime(self.timeLeft)
                if C.unitframes.auraTimer == true then
                    self.remaining:SetText(time)
                end
            else
                if C.unitframes.auraTimer == true then
                    self.remaining:Hide()
                end
                self:SetScript("OnUpdate", nil)
            end
            self.elapsed = 0
        end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, ...)
end)
if C.nameplate.combat == true then
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    function frame:PLAYER_REGEN_ENABLED()
        SetCVar("nameplateMotion", 0)
        local inInstance, instanceType = IsInInstance();
        if ((instanceType == 'party') or (instanceType == 'raid')) then
        else
            SetCVar("nameplateShowFriends", 1)
            -- SetCVar("UnitNameFriendlyPlayerName", 1)
        end
    end

    function frame:PLAYER_REGEN_DISABLED()
        SetCVar("nameplateMotion", 1)
        local inInstance, instanceType = IsInInstance();
        if ((instanceType == 'party') or (instanceType == 'raid')) then
        else
            SetCVar("nameplateShowFriends", 0)
            -- SetCVar("UnitNameFriendlyPlayerName", 0)
        end
    end

    function frame:PLAYER_ENTERING_WORLD()
        _G.SystemFont_NamePlate:SetFont("Interface\\AddOns\\RefineUI\\Media\\Fonts\\Barlow-Bold-Upper.ttf", 8, "OUTLINE")
        _G.SystemFont_NamePlateFixed:SetFont("Interface\\AddOns\\RefineUI\\Media\\Fonts\\Barlow-Bold-Upper.ttf", 8,
            "OUTLINE")
        _G.SystemFont_LargeNamePlate:SetFont("Interface\\AddOns\\RefineUI\\Media\\Fonts\\Barlow-Bold-Upper.ttf", 10,
            "OUTLINE")
        _G.SystemFont_LargeNamePlateFixed:SetFont("Interface\\AddOns\\RefineUI\\Media\\Fonts\\Barlow-Bold-Upper.ttf",
            10, "OUTLINE")
        local inInstance, instanceType = IsInInstance();
        local inBattleground = UnitInBattleground("player")
        if ((instanceType == 'party') or (instanceType == 'raid')) or inBattleground ~= nil then
            SetCVar("nameplateShowFriendlyNPCs", 0)
            SetCVar("nameplateShowFriends", 0)
            -- SetCVar("UnitNameFriendlyPlayerName", 0)
        else
            SetCVar("nameplateShowFriendlyNPCs", 1)
            SetCVar("nameplateShowFriends", 1)
            -- SetCVar("UnitNameFriendlyPlayerName", 1)
        end
    end
end

-- local frame = CreateFrame("Frame")
-- frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
-- if C.nameplate.combat == true then
-- 	frame:RegisterEvent("PLAYER_REGEN_ENABLED")
-- 	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
-- 	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- 	function frame:PLAYER_REGEN_ENABLED()
-- 		SetCVar("nameplateShowEnemies", 0)
-- 	end

-- 	function frame:PLAYER_REGEN_DISABLED()
-- 		SetCVar("nameplateShowEnemies", 1)
-- 	end

-- 	function frame:PLAYER_ENTERING_WORLD()
-- 		if InCombatLockdown() then
-- 			SetCVar("nameplateShowEnemies", 1)
-- 		else
-- 			SetCVar("nameplateShowEnemies", 0)
-- 		end
-- 	end
-- end

frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN()
    if C.nameplate.enhanceThreat == true then
        SetCVar("threatWarning", 3)
    end
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("namePlateMinScale", 1)
    SetCVar("namePlateMaxScale", 1)
    SetCVar("nameplateLargerScale", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateMinAlpha", .5)
    SetCVar("nameplateMaxAlpha", 1)
    SetCVar("nameplateMaxDistance", 60)
    SetCVar("nameplateMinAlphaDistance", 0)
    SetCVar("nameplateMaxAlphaDistance", 40)
    SetCVar("nameplateOccludedAlphaMult", .1)
    SetCVar("nameplateSelectedAlpha", 1)
    SetCVar("nameplateNotSelectedAlpha", .9)
    SetCVar("nameplateLargeTopInset", 0.08)

    SetCVar("nameplateOtherTopInset", C.nameplate.clamp and 0.08 or -1)
    SetCVar("nameplateOtherBottomInset", C.nameplate.clamp and 0.1 or -1)
    SetCVar("clampTargetNameplateToScreen", C.nameplate.clamp and "1" or "0")

    SetCVar("nameplatePlayerMaxDistance", 60)

    if C.nameplate.only_name then
        SetCVar("nameplateShowOnlyNames", 1) -- This option bugged new Afflicted affix
    else
        SetCVar("nameplateShowOnlyNames", 0)
    end

    local function changeFont(self, size)
        local mult = size or 1
        self:SetFont(C.font.nameplates_font, C.font.nameplates_font_size, C.font.nameplates_font_style)
        self:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
    end
    changeFont(SystemFont_NamePlateFixed)
    changeFont(SystemFont_LargeNamePlateFixed, 2)
end

local healList, exClass, healerSpecs = {}, {}, {}

exClass.DEATHKNIGHT = true
exClass.DEMONHUNTER = true
exClass.HUNTER = true
exClass.MAGE = true
exClass.ROGUE = true
exClass.WARLOCK = true
exClass.WARRIOR = true
if C.nameplate.healer_icon == true then
    local t = CreateFrame("Frame")
    t.factions = {
        ["Horde"] = 1,
        ["Alliance"] = 0
    }
    local healerSpecIDs = { 105, -- Druid Restoration
        1468,                   -- Evoker Preservation
        270,                    -- Monk Mistweaver
        65,                     -- Paladin Holy
        256,                    -- Priest Discipline
        257,                    -- Priest Holy
        264                     -- Shaman Restoration
    }
    for _, specID in pairs(healerSpecIDs) do
        local _, name = GetSpecializationInfoByID(specID)
        if name and not healerSpecs[name] then
            healerSpecs[name] = true
        end
    end

    local lastCheck = 20
    local function CheckHealers(_, elapsed)
        lastCheck = lastCheck + elapsed
        if lastCheck > 25 then
            lastCheck = 0
            healList = {}
            for i = 1, GetNumBattlefieldScores() do
                local name, _, _, _, _, faction, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)

                if name and healerSpecs[talentSpec] and t.factions[UnitFactionGroup("player")] == faction then
                    name = name:match("(.+)%-.+") or name
                    healList[name] = talentSpec
                end
            end
        end
    end

    local function CheckArenaHealers(_, elapsed)
        lastCheck = lastCheck + elapsed
        if lastCheck > 10 then
            lastCheck = 0
            healList = {}
            for i = 1, 5 do
                local specID = GetArenaOpponentSpec(i)
                if specID and specID > 0 then
                    local name = UnitName(format("arena%d", i))
                    local _, talentSpec = GetSpecializationInfoByID(specID)
                    if name and healerSpecs[talentSpec] then
                        healList[name] = talentSpec
                        local nameplate = C_NamePlate.GetNamePlateForUnit(format("arena%d", i))
                        if nameplate then
                            nameplate.unitFrame:UpdateAllElements("UNIT_NAME_UPDATE")
                        end
                    end
                end
            end
        end
    end

    local function CheckLoc(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            local _, instanceType = IsInInstance()
            if instanceType == "pvp" then
                t:SetScript("OnUpdate", CheckHealers)
            elseif instanceType == "arena" then
                t:SetScript("OnUpdate", CheckArenaHealers)
            else
                healList = {}
                t:SetScript("OnUpdate", nil)
            end
        end
    end

    t:RegisterEvent("PLAYER_ENTERING_WORLD")
    t:SetScript("OnEvent", CheckLoc)
end

local totemData = {
    [C_Spell.GetSpellInfo(192058)] = 136013, -- Capacitor Totem
    [C_Spell.GetSpellInfo(98008)] = 237586,  -- Spirit Link Totem
    [C_Spell.GetSpellInfo(192077)] = 538576, -- Wind Rush Totem
    [C_Spell.GetSpellInfo(204331)] = 511726, -- Counterstrike Totem
    [C_Spell.GetSpellInfo(204332)] = 136114, -- Windfury Totem
    [C_Spell.GetSpellInfo(204336)] = 136039, -- Grounding Totem
    [C_Spell.GetSpellInfo(157153)] = 971076, -- Cloudburst Totem
    [C_Spell.GetSpellInfo(5394)] = 135127,   -- Healing Stream Totem
    [C_Spell.GetSpellInfo(108280)] = 538569, -- Healing Tide Totem
    [C_Spell.GetSpellInfo(207399)] = 136080, -- Ancestral Protection Totem
    [C_Spell.GetSpellInfo(198838)] = 136098, -- Earthen Wall Totem
    [C_Spell.GetSpellInfo(51485)] = 136100,  -- Earthgrab Totem
    [C_Spell.GetSpellInfo(196932)] = 136232, -- Voodoo Totem
    [C_Spell.GetSpellInfo(192222)] = 971079, -- Liquid Magma Totem
    [C_Spell.GetSpellInfo(204330)] = 135829  -- Skyfury Totem
}

local function CreateBorderFrame(frame, point)
    if point == nil then
        point = frame
    end
    if point.backdrop then
        return
    end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 7
    })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
end

local function CreateBorderFrameIcon(frame, point)
    if point == nil then
        point = frame
    end
    if point.backdrop then
        return
    end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", point, "TOPLEFT", -4, 4)
    frame.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", 4, -4)
    frame.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 8
    })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
end

local function SetColorBorder(frame, r, g, b)
    frame.border:SetBackdropBorderColor(r, g, b, 1)
end

-- Auras functions
local AurasCustomFilter = function(element, unit, data)
    local allow = false

    if not UnitIsFriend("player", unit) then
        if data.isHarmful then
            if C.nameplate.trackDebuffs and data.isPlayerAura or data.sourceUnit == "pet" then
                if ((data.nameplateShowAll or data.nameplateShowPersonal) and not R.DebuffBlackList[data.name]) then
                    allow = true
                elseif R.DebuffWhiteList[data.name] then
                    allow = true
                end
            end
        else
            if R.BuffWhiteList[data.name] then
                allow = true
            elseif data.isStealable then
                allow = true
            end
        end
    end

    return allow
end

local Mult = 1
if R.screenHeight > 1200 then
    Mult = R.mult
end

local AurasPostCreateIcon = function(element, button)
    CreateBorderFrame(button)
    button.remaining = R.SetFontString(button, C.font.auras_font, 6, C.font.auras_font_style)
    button.remaining:SetShadowOffset(C.font.auras_font_shadow and 1 or 0, C.font.auras_font_shadow and -1 or 0)
    button.remaining:SetPoint("CENTER", button, "CENTER", 1, 0)
    button.remaining:SetJustifyH("CENTER")

    button.Cooldown.noCooldownCount = true

    button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    button.Count:SetJustifyH("RIGHT")
    button.Count:SetFont(C.font.auras_font, C.font.auras_font_size / Mult, C.font.auras_font_style)
    button.Count:SetShadowOffset(C.font.auras_font_shadow and 1 or 0, C.font.auras_font_shadow and -1 or 0)

    element.disableCooldown = false
    button.Cooldown:SetReverse(true)
    button.parent = CreateFrame("Frame", nil, button)
    button.parent:SetFrameLevel(button.Cooldown:GetFrameLevel() + 1)
    button.Count:SetParent(button.parent)
    button.remaining:SetParent(button.parent)
end

local AurasPostUpdateIcon = function(_, button, unit, data)
    if not UnitIsFriend("player", unit) then
        if data.isHarmful then
            if C.nameplate.trackDebuffs and data.isPlayerAura or data.sourceUnit == "pet" then
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

local function UpdateTarget(self)
    local isTarget = UnitIsUnit(self.unit, "target")
    local isMe = UnitIsUnit(self.unit, "player")

    if C.nameplate.enhanceThreat ~= true then
        threatColor(main, true)
    end

    if isTarget and not isMe then
        if C.nameplate.targetBorder then
            SetColorBorder(self.Health, unpack(C.nameplate.targetBorderColor))
        end
        if C.nameplate.targetGlow then
            self.Glow:Show()
        end
        self:SetAlpha(1)
        if C.nameplate.target_indicator then
            if UnitIsFriend("player", self.unit) then
                self.RTargetIndicator:SetPoint("LEFT", self.Name, "RIGHT", 2, 0)
                self.LTargetIndicator:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
            else
                self.RTargetIndicator:SetPoint("LEFT", self.Health, "RIGHT", -1, 0)
                self.LTargetIndicator:SetPoint("RIGHT", self.Health, "LEFT", 1, 0)
            end
            self.RTargetIndicator:Show()
            self.LTargetIndicator:Show()
        end
    else
        if C.nameplate.targetBorder then
            SetColorBorder(self.Health, unpack(C.media.borderColor))
        end
        if C.nameplate.targetGlow then
            self.Glow:Hide()
        end
        if not UnitExists("target") or isMe then
            self:SetAlpha(1)
        else
            self:SetAlpha(C.nameplate.alpha)
        end
        if C.nameplate.target_indicator then
            self.RTargetIndicator:Hide()
            self.LTargetIndicator:Hide()
        end
    end
end

local function UpdateName(self)
    if C.nameplate.healer_icon == true then
        local name = self.unitName
        if name then
            if healList[name] then
                if exClass[healList[name]] then
                    self.HealerIcon:Hide()
                else
                    self.HealerIcon:Show()
                end
            else
                self.HealerIcon:Hide()
            end
        end
    end

    if C.nameplate.class_icons == true then
        local reaction = UnitReaction(self.unit, "player")
        if UnitIsPlayer(self.unit) and (reaction and reaction <= 4) then
            local _, class = UnitClass(self.unit)
            local texcoord = CLASS_ICON_TCOORDS[class]
            self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
            self.Class:Show()
            -- self.Level:SetPoint("RIGHT", self.Name, "LEFT", -2, 0)
        else
            self.Class.Icon:SetTexCoord(0, 0, 0, 0)
            self.Class:Hide()
            -- self.Level:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
        end
    end

    if C.nameplate.totem_icons == true then
        local name = self.unitName
        if name then
            if totemData[name] then
                self.Totem.Icon:SetTexture(totemData[name])
                self.Totem:Show()
            else
                self.Totem:Hide()
            end
        end
    end
end

local kickID = 0
if C.nameplate.kick_color then
    if R.class == "DEATHKNIGHT" then
        kickID = 47528
    elseif R.class == "DEMONHUNTER" then
        kickID = 183752
    elseif R.class == "DRUID" then
        kickID = 106839
    elseif R.class == "EVOKER" then
        kickID = 351338
    elseif R.class == "HUNTER" then
        kickID = GetSpecialization() == 3 and 187707 or 147362
    elseif R.class == "MAGE" then
        kickID = 2139
    elseif R.class == "MONK" then
        kickID = 116705
    elseif R.class == "PALADIN" then
        kickID = 96231
    elseif R.class == "PRIEST" then
        kickID = 15487
    elseif R.class == "ROGUE" then
        kickID = 1766
    elseif R.class == "SHAMAN" then
        kickID = 57994
    elseif R.class == "WARLOCK" then
        kickID = 119910
    elseif R.class == "WARRIOR" then
        kickID = 6552
    end
end

-- Cast color
local function PostCastStart(self)
    self.Text:SetText(string.upper(self.Text:GetText()))

    if self.notInterruptible then
        local r, g, b = unpack(R.oUF_colors.notinterruptible)
        self:SetStatusBarColor(r, g, b)
        self.bg:SetColorTexture(r * .2, g * .2, b * .2)
        SetColorBorder(self, r, g, b)
        SetColorBorder(self.Button, r, g, b)
    else
        if C.nameplate.kick_color then
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

    if C.nameplate.cast_color then
        if R.InterruptCast[self.spellID] then
            SetColorBorder(self, 1, 0.8, 0)
        elseif R.ImportantCast[self.spellID] then
            SetColorBorder(self, 1, 0, 0)
        else
            SetColorBorder(self, unpack(C.media.borderColor))
        end
    end
end

-- Health color
local function threatColor(self, forced)
    if UnitIsPlayer(self.unit) then
        return
    end

    -- if C.nameplate.enhanceThreat ~= true then
    -- 	SetColorBorder(self.Health, unpack(C.media.borderColor))
    -- end
    if UnitIsTapDenied(self.unit) then
        self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
        -- self.Health.bg:SetVertexColor(0.6 , 0.6 , 0.6)
    elseif UnitAffectingCombat("player") then
        local threatStatus = UnitThreatSituation("player", self.unit)
        if self.npcID == "120651" then     -- Explosives affix
            self.Health:SetStatusBarColor(unpack(C.nameplate.extra_color))
        elseif self.npcID == "174773" then -- Spiteful Shade affix
            if threatStatus == 3 then
                self.Health:SetStatusBarColor(unpack(C.nameplate.extra_color))
            else
                self.Health:SetStatusBarColor(unpack(C.nameplate.good_color))
                -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
            end
        elseif threatStatus == 3 then -- securely tanking, highest threat
            if R.Role == "Tank" then
                if C.nameplate.enhanceThreat == true then
                    if C.nameplate.mob_color_enable and R.ColorPlate[self.npcID] then
                        self.Health:SetStatusBarColor(unpack(R.ColorPlate[self.npcID]))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.good_color))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
                    end
                else
                    -- SetColorBorder(self.Health, unpack(C.nameplate.bad_color))
                end
            else
                if C.nameplate.enhanceThreat == true then
                    self.Health:SetStatusBarColor(unpack(C.nameplate.bad_color))
                    -- self.Health.bg:SetVertexColor(unpack(C.nameplate.bad_colorbg))
                else
                    -- SetColorBorder(self.Health, unpack(C.nameplate.bad_color))
                end
            end
        elseif threatStatus == 2 then -- insecurely tanking, another unit have higher threat but not tanking
            if C.nameplate.enhanceThreat == true then
                self.Health:SetStatusBarColor(unpack(C.nameplate.near_color))
                -- self.Health.bg:SetVertexColor(unpack(C.nameplate.near_colorbg))
            else
                -- SetColorBorder(self.Health, unpack(C.nameplate.near_color))
            end
        elseif threatStatus == 1 then -- not tanking, higher threat than tank
            if C.nameplate.enhanceThreat == true then
                self.Health:SetStatusBarColor(unpack(C.nameplate.near_color))
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
                        self.Health:SetStatusBarColor(unpack(C.nameplate.offtank_color))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.offtank_colorbg))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.bad_color))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.bad_colorbg))
                    end
                else
                    if C.nameplate.mob_color_enable and R.ColorPlate[self.npcID] then
                        self.Health:SetStatusBarColor(unpack(R.ColorPlate[self.npcID]))
                    else
                        self.Health:SetStatusBarColor(unpack(C.nameplate.good_color))
                        -- self.Health.bg:SetVertexColor(unpack(C.nameplate.good_colorbg))
                    end
                end
            end
        end
    elseif not forced then
        self.Health:ForceUpdate()
    end
end

local function HealthPostUpdate(self, unit, cur, max)
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
            if C.nameplate.mob_color_enable and R.ColorPlate[main.npcID] then
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
            -- elseif not isPlayer and C.nameplate.enhanceThreat == true then
            -- 	if C.nameplate.low_health then
            -- 		if perc < C.nameplate.low_healthValue then
            -- 			SetColorBorder(self, unpack(C.nameplate.low_health_color))
            -- 		else
            -- 			SetColorBorder(self, unpack(C.media.borderColor))
            -- 		end
            -- 	else
            -- 		SetColorBorder(self, unpack(C.media.borderColor))
            -- 	end
        end
    else
        threatColor(main, true)
    end
end

local function callback(self, event, unit)
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
            self.Power:Show()
            self.Name:Hide()
            self.Castbar:SetAlpha(0)
            self.RaidTargetIndicator:SetAlpha(0)
        else
            self.Power:Hide()
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

            if C.nameplate.only_name then
                if UnitIsFriend("player", unit) then
                    self.Health:SetAlpha(0)
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("CENTER", self, "CENTER", 0, 0)
                    -- self.Level:SetAlpha(0)
                    self.Castbar:SetAlpha(0)
                    if C.nameplate.targetGlow then
                        self.Glow:SetAlpha(0)
                    end
                else
                    self.Health:SetAlpha(1)
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
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

local function style(self, unit)
    local main = self
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    local isDead = UnitIsDead(unit)
    local visisble = nameplate:IsVisible()
    if not isDead and not visisble then
        RunNextFrame(function() main:Show(); end)
    end

    self.unit = unit

    self:SetPoint("CENTER", nameplate, "CENTER")
    self:SetSize(C.nameplate.width, C.nameplate.height)

    -- Health Bar
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetAllPoints(self)
    self.Health:SetStatusBarTexture(C.media.texture)
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorHealth = true
    self.Health.Smooth = true
    CreateBorderFrame(self.Health)

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetTexture(C.media.texture)
    self.Health.bg.multiplier = 0.2

    self.Health.mask = self.Health:CreateMaskTexture()
    self.Health.mask:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\MaskTest2.blp", "CLAMPTOWHITEADDITIVE",
        "CLAMPTOWHITEADDITIVE")
    self.Health.mask:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
    self.Health.mask:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
    self.Health:GetStatusBarTexture():AddMaskTexture(self.Health.mask)

    self.Health.bgmask = self.Health:CreateMaskTexture()
    self.Health.bgmask:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\MaskTest2.blp", "CLAMPTOWHITEADDITIVE",
        "CLAMPTOWHITEADDITIVE")
    self.Health.bgmask:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
    self.Health.bgmask:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
    self.Health.bg:AddMaskTexture(self.Health.bgmask)

    -- mask = self:CreateMaskTexture()
    -- mask:SetAllPoints(self.Health)
    -- mask:SetTexture("/Interface/AddOns/RefineUI/Media/Textures/MaskTest.blp", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    -- self.Health:GetStatusBarTexture():AddMaskTexture(mask)

    -- local mask = self:CreateMaskTexture()
    -- mask:SetTexture("/Interface/AddOns/RefineUI/Media/Textures/MaskTest.blp", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    -- mask:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
    -- mask:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)

    -- self.Health:GetStatusBarTexture():AddMaskTexture(mask)

    -- local mask = self.Health:CreateMaskTexture()
    -- mask:SetTexture("Interface/CastingBar/UICastingBarFullMask.blp")
    -- mask:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
    -- mask:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
    -- mask:SetHeight(C.nameplate.height + 8)
    -- self.Health:GetStatusBarTexture():AddMaskTexture(mask)

    -- Health Text
    if C.nameplate.healthValue == true then
        self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.value:SetFont(C.font.nameplates_health_font, C.font.nameplates_health_font_size,
            C.font.nameplates_health_font_style)
        self.Health.value:SetShadowOffset(C.font.nameplates_health_font_shadow and 1 or 0,
            C.font.nameplates_health_font_shadow and -1 or 0)
        self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
        self:Tag(self.Health.value, "[NameplateHealth]")
    end

    -- Player Power Bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetStatusBarTexture(C.media.texture)
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
    self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -6 - (C.nameplate.height / 2))
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.PostUpdate = R.PreUpdatePower
    CreateBorderFrame(self.Power)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture)
    self.Power.bg.multiplier = 0.2

    -- Hide Blizzard Power Bar
    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
        if not frame or frame:IsForbidden() then
            return
        end
        if frame.classNamePlatePowerBar then
            frame.classNamePlatePowerBar:Hide()
            frame.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)

    -- Name Text
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(C.font.nameplates_name_font, C.font.nameplates_name_font_size, C.font.nameplates_name_font_style)
    self.Name:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
    self.Name:SetWordWrap(false)

    if C.nameplate.name_abbrev then
        self:Tag(self.Name, "[NameplateNameColor][NameLongAbbrev]")
    elseif C.nameplate.short_name then
        self:Tag(self.Name, "[NameplateNameColor][NameplateNameShort]")
    else
        self:Tag(self.Name, "[NameplateNameColor][NameLong]")
    end

    -- Target Glow
    if C.nameplate.targetGlow then
        self.Glow = CreateFrame("Frame", nil, self, "BackdropTemplate")
        self.Glow:SetBackdrop({
            edgeFile = [[Interface\AddOns\RefineUI\Media\Textures\Glow.tga]],
            edgeSize = 4
        })
        self.Glow:SetPoint("TOPLEFT", -3, 3)
        self.Glow:SetPoint("BOTTOMRIGHT", 3, -3)
        self.Glow:SetBackdropBorderColor(0.9, 0.9, 0.9)
        self.Glow:SetFrameLevel(0)
        self.Glow:Hide()
    end

    -- -- Level Text
    -- self.Level = self:CreateFontString(nil, "ARTWORK")
    -- self.Level:SetFont(C.font.nameplates_font, C.font.nameplates_font_size, C.font.nameplates_font_style)
    -- self.Level:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
    -- self.Level:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
    -- self:Tag(self.Level, "[DiffColor][NameplateLevel][shortclassification]")

    -- Cast Bar
    self.Castbar = CreateFrame("StatusBar", nil, self)
    self.Castbar:SetFrameLevel(3)
    self.Castbar:SetStatusBarTexture(C.media.texture)
    self.Castbar:SetStatusBarColor(1, 0.8, 0)
    self.Castbar:SetPoint("TOP", self.Health, "BOTTOM", 0, -2)
    self.Castbar:SetSize(C.nameplate.width, C.nameplate.height)
    CreateBorderFrame(self.Castbar)

    self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetTexture(C.media.texture)
    self.Castbar.bg:SetColorTexture(1, 0.8, 0)
    self.Castbar.bg.multiplier = 0.2

    self.Castbar.PostCastStart = PostCastStart
    self.Castbar.PostCastInterruptible = PostCastStart

    -- -- Cast Time Text
    -- self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
    -- self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", 0, 0)
    -- self.Castbar.Time:SetFont(C.font.nameplates_font, C.font.nameplates_font_size, C.font.nameplates_font_style)
    -- self.Castbar.Time:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0,
    --     C.font.nameplates_font_shadow and -1 or 0)

    -- self.Castbar.CustomTimeText = function(self, duration)
    --     self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
    -- end

    -- Cast Name Text
    if C.nameplate.show_castbar_name == true then
        self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER", 0, 0)
        self.Castbar.Text:SetFont(C.font.nameplates_spell_font, C.font.nameplates_spell_size,
            C.font.nameplates_spell_style)
        self.Castbar.Text:SetShadowOffset(C.font.nameplates_spell_shadow and 1 or 0,
            C.font.nameplates_spell_shadow and -1 or 0)
        self.Castbar.Text:SetHeight(C.font.nameplates_spell_size)
        self.Castbar.Text:SetJustifyH("LEFT")
    end

    -- Cast Bar Icon
    self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
    self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Castbar.Icon:SetDrawLayer("ARTWORK")
    self.Castbar.Icon:SetSize((C.nameplate.height) * 2, (C.nameplate.height) * 2)
    self.Castbar.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, 0)
    self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -4, 0)
    self.Castbar.Icon:SetWidth(self.Castbar.Icon:GetHeight())
    CreateBorderFrameIcon(self.Castbar.Button, self.Castbar.Icon)

    -- Cast Time Text
    self.Castbar.Time = self.Castbar.Button:CreateFontString(nil, "OVERLAY")
    self.Castbar.Time:SetPoint("CENTER", self.Castbar.Icon, "CENTER", 0, 0)
    self.Castbar.Time:SetJustifyH("CENTER")
    self.Castbar.Time:SetFont(C.font.nameplates_spelltime_font, C.font.nameplates_spelltime_size,
        C.font.nameplates_spelltime_style)
    self.Castbar.Time:SetShadowOffset(C.font.nameplates_spelltime_shadow and 1 or 0,
        C.font.nameplates_spelltime_shadow and -1 or 0)

    self.Castbar.CustomTimeText = function(self, duration)
        if duration > 600 then
            self.Time:SetText("∞")
        else
            self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
        end
    end

    -- Raid Icon
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RaidTargetIndicator:SetSize((C.nameplate.height * 2), (C.nameplate.height * 2))
    if UnitIsFriend("player", unit) then
        self.RaidTargetIndicator:SetPoint("LEFT", self.Name, "RIGHT", 2, 0)
    else
        self.RaidTargetIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 4)
    end

    -- Target Indicator
    if C.nameplate.target_indicator then
        self.RTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
        self.RTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/RTargetArrow.blp")
        self.RTargetIndicator:SetSize(C.nameplate.height, C.nameplate.height)
        self.RTargetIndicator:Hide()

        self.LTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
        self.LTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/LTargetArrow.blp")
        self.LTargetIndicator:SetSize(C.nameplate.height, C.nameplate.height)
        self.LTargetIndicator:Hide()
    end

    -- Class Icon
    if C.nameplate.class_icons == true then
        self.Class = CreateFrame("Frame", nil, self)
        self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
        self.Class.Icon:SetSize((C.nameplate.height * 2) + 8, (C.nameplate.height * 2) + 8)
        self.Class.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -8, 0)
        self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
        self.Class.Icon:SetTexCoord(0, 0, 0, 0)
        CreateBorderFrame(self.Class, self.Class.Icon)
    end

    -- Totem Icon
    if C.nameplate.totem_icons == true then
        self.Totem = CreateFrame("Frame", nil, self)
        self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
        self.Totem.Icon:SetSize((C.nameplate.height * 2) + 8, (C.nameplate.height * 2) + 8)
        self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
        self.Totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        CreateBorderFrame(self.Totem, self.Totem.Icon)
    end

    -- Healer Icon
    if C.nameplate.healer_icon == true then
        self.HealerIcon = self.Health:CreateFontString(nil, "OVERLAY")
        self.HealerIcon:SetFont(C.font.nameplates_font, 32, C.font.nameplates_font_style)
        self.HealerIcon:SetText("|cFFD53333+|r")
        self.HealerIcon:SetPoint("BOTTOM", self.Name, "TOP", 0, C.nameplate.trackDebuffs == true and 13 or 0)
    end

    -- Quest Icon
    if C.nameplate.quests then
        self.QuestIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
        self.QuestIcon:SetSize((C.nameplate.height * 2), (C.nameplate.height * 2))
        self.QuestIcon:SetPoint("RIGHT", self.Health, "LEFT", -5, 0)
        self.QuestIcon:Hide()

        self.QuestIcon.Text = self:CreateFontString(nil, "OVERLAY")
        self.QuestIcon.Text:SetPoint("RIGHT", self.QuestIcon, "LEFT", -1, 0)
        self.QuestIcon.Text:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * 2,
            C.font.nameplates_font_style)
        self.QuestIcon.Text:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0,
            C.font.nameplates_font_shadow and -1 or 0)

        self.QuestIcon.Item = self:CreateTexture(nil, "OVERLAY")
        self.QuestIcon.Item:SetSize((C.nameplate.height * 2) - 2, (C.nameplate.height * 2) - 2)
        self.QuestIcon.Item:SetPoint("RIGHT", self.QuestIcon.Text, "LEFT", -2, 0)
        self.QuestIcon.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    -- Aura tracking
    if C.nameplate.trackDebuffs == true or C.nameplate.trackBuffs == true then
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, C.font.nameplates_font_size + 5)
        self.Auras.initialAnchor = "BOTTOMRIGHT"
        self.Auras["growth-y"] = "UP"
        self.Auras["growth-x"] = "LEFT"
        self.Auras.numDebuffs = C.nameplate.trackDebuffs and 6 or 0
        self.Auras.numBuffs = C.nameplate.trackBuffs and 4 or 0
        self.Auras:SetSize(20 + C.nameplate.width, C.nameplate.aurasSize)
        self.Auras.spacing = 5
        self.Auras.size = C.nameplate.aurasSize - 3
        self.Auras.disableMouse = true

        self.Auras.FilterAura = AurasCustomFilter
        self.Auras.PostCreateButton = AurasPostCreateIcon
        self.Auras.PostUpdateButton = AurasPostUpdateIcon
    end

    -- Health color
    self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self.Health:RegisterEvent("UNIT_HEALTH")

    self.Health:SetScript("OnEvent", function()
        if C.nameplate.enhanceThreat ~= true then
            threatColor(main)
        end
    end)

    self.Health.PostUpdate = HealthPostUpdate

    -- Absorb
    -- if C.raidframe.pluginsGealcomm == true then
    --     local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
    --     ahpb:SetTexture(C.media.texture)
    --     ahpb:SetVertexColor(1, 1, 1, .5)
    --     self.HealthPrediction = {
    --         absorbBar = ahpb
    --     }
    -- end

    -- Every event should be register with this
    table.insert(self.__elements, UpdateName)
    self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)

    table.insert(self.__elements, UpdateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget, true)

    -- Disable movement via /moveui
    self.disableMovement = true

    if R.PostCreateNameplates then
        R.PostCreateNameplates(self, unit)
    end
end

oUF:RegisterStyle("RefineUINameplates", style)
oUF:SetActiveStyle("RefineUINameplates")
oUF:SpawnNamePlates("RefineUINameplates", callback)
