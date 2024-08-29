----------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------
local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local NP = R.NP or {}
R.NP = NP

-- Upvalue globals for efficiency
local CreateFrame, hooksecurefunc = CreateFrame, hooksecurefunc
local UnitIsFriend, UnitIsPlayer, UnitClass = UnitIsFriend, UnitIsPlayer, UnitClass
local GetTime, select, unpack = GetTime, select, unpack

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------
local function CreateBorderFrame(frame, point)
    if point and point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({ edgeFile = C.media.border, edgeSize = 7 })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 1)
end

local function CreateBorderFrameIcon(frame, point)
    if point.backdrop then return end
    frame.border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", point, "TOPLEFT", -4, 4)
    frame.border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", 4, -4)
    frame.border:SetBackdrop({ edgeFile = C.media.border, edgeSize = 8 })
    frame.border:SetBackdropBorderColor(unpack(C.media.borderColor))
    frame.border:SetFrameStrata("MEDIUM")
end

----------------------------------------------------------------------------------------
-- Nameplate Configuration
----------------------------------------------------------------------------------------
function NP.ConfigureNameplate(self, unit)
    self.unit = unit
    self:SetSize(C.nameplate.width, C.nameplate.height)

    -- Hide Blizzard Power Bar
    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
        if frame and not frame:IsForbidden() and frame.classNamePlatePowerBar then
            frame.classNamePlatePowerBar:Hide()
            frame.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)
end

----------------------------------------------------------------------------------------
-- Health Bar
----------------------------------------------------------------------------------------
function NP.CreateHealthBar(self)
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

    -- Health Text
    self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
    self.Health.value:SetFont(C.font.nameplates_health_font, C.font.nameplates_health_font_size,
        C.font.nameplates_health_font_style)
    self.Health.value:SetShadowOffset(C.font.nameplates_health_font_shadow and 1 or 0,
        C.font.nameplates_health_font_shadow and -1 or 0)
    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, -1)
    self:Tag(self.Health.value, "[NameplateHealth]")

    -- Register events for threat updates
    self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self.Health:RegisterEvent("UNIT_HEALTH")
    self.Health:SetScript("OnEvent", function()
        if C.nameplate.enhance_threat then
            NP.UpdateThreat(self)
        end
    end)

    self.Health.PostUpdate = NP.HealthPostUpdate

    -- Absorb
    local absorb = self.Health:CreateTexture(nil, "ARTWORK")
    absorb:SetTexture(C.media.texture)
    absorb:SetVertexColor(1, 1, 1, .5)
    self.HealthPrediction = {
        absorbBar = absorb
    }
end

----------------------------------------------------------------------------------------
-- Power Bar
----------------------------------------------------------------------------------------
function NP.CreatePowerBar(self)
    if self.unit == "player" then
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
    end
end

----------------------------------------------------------------------------------------
-- Name Text
----------------------------------------------------------------------------------------
function NP.CreateNameText(self)
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(C.font.nameplates_name_font, C.font.nameplates_name_font_size, C.font.nameplates_name_font_style)
    self.Name:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
    self.Name:SetWordWrap(false)

    self:Tag(self.Name, "[NameplateNameColor][NameLongAbbrev]")
end

----------------------------------------------------------------------------------------
-- Target Glow
----------------------------------------------------------------------------------------
function NP.CreateTargetGlow(self)
    self.Glow = CreateFrame("Frame", nil, self, "BackdropTemplate")
    self.Glow:SetBackdrop({
        edgeFile = [[Interface\AddOns\RefineUI\Media\Textures\RefineGlow.blp]],
        edgeSize = 6
    })
    self.Glow:SetPoint("TOPLEFT", -3, 3)
    self.Glow:SetPoint("BOTTOMRIGHT", 3, -3)
    self.Glow:SetBackdropBorderColor(0.9, 0.9, 0.9)
    self.Glow:SetFrameLevel(0)
    self.Glow:Hide()
end

----------------------------------------------------------------------------------------
-- Cast Bar
----------------------------------------------------------------------------------------
function NP.CreateCastBar(self)
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

    self.Castbar.PostCastStart = NP.PostCastStart
    self.Castbar.PostCastInterruptible = NP.PostCastStart

    -- Cast Name Text
    self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
    self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER", 0, 0)
    self.Castbar.Text:SetFont(C.font.nameplates_spell_font, C.font.nameplates_spell_size,
        C.font.nameplates_spell_style)
    self.Castbar.Text:SetShadowOffset(C.font.nameplates_spell_shadow and 1 or 0,
        C.font.nameplates_spell_shadow and -1 or 0)
    self.Castbar.Text:SetHeight(C.font.nameplates_spell_size)
    self.Castbar.Text:SetJustifyH("LEFT")

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
        self.Time:SetText(duration > 600 and "∞" or ("%.1f"):format(self.channeling and duration or self.max - duration))
    end
end

----------------------------------------------------------------------------------------
-- Auras
----------------------------------------------------------------------------------------
function NP.CreateAuras(self)
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

    self.Auras.FilterAura = NP.AurasCustomFilter
    self.Auras.PostCreateButton = NP.AurasPostCreateIcon
    self.Auras.PostUpdateButton = NP.AurasPostUpdateIcon
end

----------------------------------------------------------------------------------------
-- Debuffs
----------------------------------------------------------------------------------------
function NP.CreateDebuffs(self)
    self.Debuffs = CreateFrame("Frame", self:GetName() .. "_Debuffs", self)
    self.Debuffs:SetHeight(R.frameHeight * 3)
    self.Debuffs:SetWidth(C.unitframes.frameWidth + 4)
    self.Debuffs.size = C.auras.playerDebuffSize
    self.Debuffs.spacing = 3
    self.Debuffs.initialAnchor = "BOTTOMLEFT"
    self.Debuffs["growth-y"] = "UP"
    self.Debuffs["growth-x"] = "RIGHT"
    if (R.class == "DEATHKNIGHT" or R.class == "DRUID" or R.class == "ROGUE" or R.class == "SHAMAN" or R.class == "WARLOCK") then
        self.Debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 2, 6)
    end

    self.Debuffs.PostCreateButton = NP.PostCreateIcon
    self.Debuffs.PostUpdateButton = NP.PostUpdateIcon
end

----------------------------------------------------------------------------------------
-- Target Indicator
----------------------------------------------------------------------------------------
function NP.CreateTargetIndicator(self)
    self.RTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/RTargetArrow2.blp")
    self.RTargetIndicator:SetSize(C.nameplate.height, C.nameplate.height)
    self.RTargetIndicator:Hide()

    self.LTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.LTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/LTargetArrow2.blp")
    self.LTargetIndicator:SetSize(C.nameplate.height, C.nameplate.height)
    self.LTargetIndicator:Hide()
end

----------------------------------------------------------------------------------------
-- Raid Icons
----------------------------------------------------------------------------------------
function NP.CreateRaidIcon(self, unit)
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RaidTargetIndicator:SetSize((C.nameplate.height * 2), (C.nameplate.height * 2))
    -- self.RaidTargetIndicator:SetPoint(UnitIsFriend("player", unit) and "LEFT" or "RIGHT",
    --     UnitIsFriend("player", unit) and self.Name or self.Health,
    --     UnitIsFriend("player", unit) and "RIGHT" or "LEFT",
    --     UnitIsFriend("player", unit) and 2 or -2,
    --     UnitIsFriend("player", unit) and 0 or 4)

        self.RaidTargetIndicator:SetPoint("BOTTOM", self.Name, "TOP", 0, 0)
end

----------------------------------------------------------------------------------------
-- Class Icon
----------------------------------------------------------------------------------------
function NP.CreateQuestIcon(self)
    self.QuestIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.QuestIcon:SetSize(10, 10)
    self.QuestIcon:SetPoint("RIGHT", self.Health, "LEFT", -5, 0)
    self.QuestIcon:Hide()

    self.QuestIcon.Text = self:CreateFontString(nil, "OVERLAY")
    self.QuestIcon.Text:SetPoint("RIGHT", self.QuestIcon, "LEFT", -1, 0)
    self.QuestIcon.Text:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * 2,
        C.font.nameplates_font_style)
    self.QuestIcon.Text:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0,
        C.font.nameplates_font_shadow and -1 or 0)

    self.QuestIcon.Item = self:CreateTexture(nil, "OVERLAY")
    self.QuestIcon.Item:SetSize((C.nameplate.height / 2), (C.nameplate.height / 2))
    self.QuestIcon.Item:SetPoint("RIGHT", self.QuestIcon.Text, "LEFT", -2, 0)
    self.QuestIcon.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

return NP
