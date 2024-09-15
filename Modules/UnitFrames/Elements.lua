local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave = CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave
local GetSpecialization, unpack = GetSpecialization, unpack

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------
local function CategorizeUnit(self)
    if self:GetParent():GetName():match("RefineUI_Party") then
        self.isPartyRaid = true
    elseif self:GetParent():GetName():match("RefineUI_Raid") then
        self.isPartyRaid = true
    else
        self.isSingleUnit = true
    end
end

local function PositionDebuffs(self)
    if self.PlayerResources and self.PlayerResources:IsVisible() then
        self.Debuffs:SetPoint("BOTTOM", self.PlayerResources, "TOP", 0, 8)
    else
        self.Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 6)
    end
end

local function SetupTexture(parent, layer, allPoints, texture)
    local tex = parent:CreateTexture(nil, layer)
    tex:SetAllPoints(allPoints)
    tex:SetTexture(texture)
    return tex
end

local function CreateResourceBar(self, numPoints, color, name)
    self.PlayerResources = CreateFrame("Frame", self:GetName() .. "_PlayerResources", self)
    self.PlayerResources:CreateBackdrop("Default")
    self.PlayerResources:SetPoint(unpack(C.position.unitframes.classResources))
    self.PlayerResources:SetSize(C.unitframes.frameWidth - 4, 8)

    for i = 1, numPoints do
        self.PlayerResources[i] = CreateFrame("StatusBar", self:GetName() .. "_" .. name .. i, self.PlayerResources)
        self.PlayerResources[i]:SetSize((C.unitframes.frameWidth / numPoints) - 1, 8)
        if i == 1 then
            self.PlayerResources[i]:SetPoint("LEFT", self.PlayerResources)
        else
            self.PlayerResources[i]:SetPoint("LEFT", self.PlayerResources[i - 1], "RIGHT", 1, 0)
        end
        self.PlayerResources[i]:SetStatusBarTexture(C.media.texture)
        self.PlayerResources[i]:SetStatusBarColor(unpack(color))

        self.PlayerResources[i].bg = self.PlayerResources[i]:CreateTexture(nil, "BORDER")
        self.PlayerResources[i].bg:SetAllPoints()
        self.PlayerResources[i].bg:SetTexture(C.media.texture)
        self.PlayerResources[i].bg:SetVertexColor(color[1], color[2], color[3], 0.2)
    end

    return self.PlayerResources
end

----------------------------------------------------------------------------------------
-- Unit Frame Configuration
----------------------------------------------------------------------------------------
function UF.ConfigureUnitFrame(self)
    self.colors = R.oUF_colors
    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetAttribute("*type2", "togglemenu")
    self:SetTemplate("Default")
    self.border:SetFrameLevel(4)
    self:SetHitRectInsets(-10, -10, -50, -10)
    CategorizeUnit(self)
end

----------------------------------------------------------------------------------------
-- Health Bar
----------------------------------------------------------------------------------------
function UF.CreateHealthBar(self)
    local height
    self.Health = CreateFrame("StatusBar", self:GetName() .. "_Health", self)
    self.Health:SetHeight(C.unitframes.healthHeight)
    self.Health:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    self.Health:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
    self.Health:SetStatusBarTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\Health3")
    self.Health:SetFrameLevel(5)

    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.colorReaction = true
    self.Health.colorClass = true
    self.Health.Smooth = true

    self.Health.PostUpdate = UF.PostUpdateHealth
    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\HealthBG")
    self.Health.bg.multiplier = 0.5

    self.Health.value = R.SetFontString(self.Health, unpack(C.font.unitframes.health))
    self.Health.value:SetShadowOffset(1, -1)

    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, -2)
    self.Health.value:SetJustifyH("CENTER")
    -- R.PixelSnap(self.Health.value)

    local bottomLine = R.CreatePixelLine(self.Health, "HORIZONTAL", 1, .1, .1, .1, 1)
    bottomLine:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")
    bottomLine:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT")
end

----------------------------------------------------------------------------------------
-- Power Bar
----------------------------------------------------------------------------------------
function UF.CreatePowerBar(self)
    local height
    self.Power = CreateFrame("StatusBar", self:GetName() .. "_Power", self)
    self.Power:SetHeight(C.unitframes.powerHeight)
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, 0)
    self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
    self.Power:SetStatusBarTexture(C.media.texture)
    self.Power:SetFrameLevel(5)

    self.Power.frequentUpdates = true
    self.Power.colorDisconnected = true
    self.Power.colorTapping = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.PreUpdate = UF.PreUpdatePower
    self.Power.PostUpdate = UF.PostUpdatePower

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture)
    self.Power.bg.multiplier = 0.4

    self.Power.value = R.SetFontString(self.Health, unpack(C.font.unitframes.health))
    self.Power.value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
    self.Power.value:SetJustifyH("CENTER")
end

----------------------------------------------------------------------------------------
-- Name Text
----------------------------------------------------------------------------------------
function UF.CreateNameText(self)
    if self.isPartyRaid then
        self.Name = R.SetFontString(self.Health, unpack(C.font.group.name))
        self.Name:SetShadowOffset(1, -1)
    elseif self.isSingleUnit then
        self.Name = R.SetFontString(self.Health, unpack(C.font.unitframes.name))
        self.Name:SetShadowOffset(1, -1)
    end
    self.Name:SetWordWrap(false)
    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 1)
    self.Name:SetJustifyH("CENTER")
    if self.isPartyRaid then
        self:Tag(self.Name, "[GetNameColor][NameMedium]")
    else
        self:Tag(self.Name, "[GetNameColor][NameLongAbbrev]")
    end
end

function UF.CreatePortraitAndCastIcon(self)
    -- Create a frame to attach the portrait to
    local PortraitFrame = CreateFrame("Frame", nil, self)
    PortraitFrame:SetSize(48, 48)
    PortraitFrame:SetFrameLevel(self:GetFrameLevel() + 2) -- Ensure this is higher than the background
    PortraitFrame:SetFrameStrata("HIGH")
    if self.unit == "player" or self.unit == "focus" then
        PortraitFrame:SetPoint("RIGHT", self, "LEFT", 12, 0)
    elseif self.unit == "target" or self.unit == "boss" or self.unit == "arena" then
        PortraitFrame:SetPoint("LEFT", self, "RIGHT", -12, 0)
    end



    -- Create a circular border texture for the portrait
    local BorderTexture = PortraitFrame:CreateTexture(nil, 'OVERLAY')
    BorderTexture:SetAllPoints(PortraitFrame)
    BorderTexture:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBorder.blp")
    BorderTexture:SetVertexColor(unpack(C.media.borderColor))
    BorderTexture:SetDrawLayer("OVERLAY", 3)

    -- local r, g, b = unpack(R.oUF_colors.interruptible)
    -- BorderTexture:SetVertexColor(r, g, b)

    -- -- 2D Portrait
    -- local Portrait = PortraitFrame:CreateTexture(nil, 'OVERLAY')
    -- Portrait:SetSize(16, 16)
    -- Portrait:SetPoint('CENTER', PortraitFrame, 'CENTER')
    -- Portrait:SetDrawLayer("OVERLAY", 2)


    local portrait = PortraitFrame:CreateTexture(nil, 'ARTWORK')
    portrait:SetSize(36, 36)                             -- Change this to match the inner size of the frame
    portrait:SetPoint('CENTER', PortraitFrame, 'CENTER') -- Center it in the frame
    portrait:SetDrawLayer("OVERLAY", 2)

    -- Create and apply a circular mask
    local mask = PortraitFrame:CreateMaskTexture()
    mask:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitMask.blp")
    mask:SetAllPoints(BorderTexture)
    portrait:AddMaskTexture(mask)

    -- Background texture for the portrait
    local BackgroundTexture = PortraitFrame:CreateTexture(nil, 'BACKGROUND') -- Use BACKGROUND layer
    BackgroundTexture:SetAllPoints(BorderTexture)                            -- Center it over the health bar
    BackgroundTexture:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBG.blp")
    BackgroundTexture:SetVertexColor(unpack(C.media.borderColor))            -- Set a color with some transparency
    BackgroundTexture:SetDrawLayer("OVERLAY", 1)                             -- Ensure it is behind the border and portrait

    -- Background texture for the portrait
    local PortraitGlow = PortraitFrame:CreateTexture(nil, 'BACKGROUND') -- Use BACKGROUND layer
    PortraitGlow:SetAllPoints(BorderTexture)                            -- Center it over the health bar
    PortraitGlow:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitGlow.blp")
    PortraitGlow:SetVertexColor(1, 1, 1, .6)                            -- Set a color with some transparency
    PortraitGlow:SetDrawLayer("OVERLAY", 1)
    PortraitGlow:Hide()

    local radialStatusBar = R.CreateRadialStatusBar(PortraitFrame)
    radialStatusBar:SetAllPoints(PortraitFrame)
    radialStatusBar:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBorder.blp")
    radialStatusBar:SetVertexColor(0, 0.8, 0.8, 0.75) -- Teal blue color
    radialStatusBar:SetFrameStrata("HIGH")

    -- -- Create the text element for quest completion
    -- local QuestText = PortraitFrame:CreateFontString(nil, "OVERLAY")
    -- QuestText:SetPoint("CENTER", portrait, "CENTER", 0, -4)
    -- QuestText:SetJustifyH("CENTER")
    -- QuestText:SetFont(C.font.nameplates_font, 5, C.font.nameplates_font_style)
    -- QuestText:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)

    self.CombinedPortrait = portrait
    self.CombinedPortrait.Text = QuestText
    self.CombinedPortrait.radialStatusbar = radialStatusBar
    self.BorderTexture = BorderTexture
    self.PortraitFrame = PortraitFrame
    self.PortraitGlow = PortraitGlow

    portrait:Show()
    radialStatusBar:Show()

    self:HookScript("OnShow", function(self)
        if self.CombinedPortrait then
            self.CombinedPortrait:ForceUpdate()
        end
    end)
end

----------------------------------------------------------------------------------------
-- Castbar
----------------------------------------------------------------------------------------
function UF.CreateCastBar(self)
    self.Castbar = CreateFrame("StatusBar", self:GetName() .. "_Castbar", self)
    self.Castbar:SetStatusBarTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\RefineUIBlank.tga", "ARTWORK")
    self.Castbar:SetPoint("TOP", self, "BOTTOM", 0, 4)
    self.Castbar:SetWidth(C.unitframes.castbarWidth)
    self.Castbar:SetHeight(C.unitframes.castbarHeight + 10)
    self.Castbar:SetTemplate("Default")
    self.Castbar:SetFrameLevel(0)
    self.Castbar.border:SetFrameLevel(1)
    self.Castbar:SetFrameStrata("LOW")
    self.Castbar.border:SetFrameStrata("LOW")



    self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetTexture(C.media.texture)
    self.Castbar.bg.multiplier = 0.5

    if self.unit == "player" then
        self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "BORDER", nil, 1)
        self.Castbar.SafeZone:SetTexture(C.media.texture)
        self.Castbar.SafeZone:SetVertexColor(0.85, 0.27, 0.27)
    end

    self.Castbar.Text = R.SetFontString(self.Castbar, unpack(C.font.unitframes.spellname))
    self.Castbar.Text:SetShadowOffset(1, -1)
    self.Castbar.Text:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMLEFT", 4, 4)
    self.Castbar.Text:SetTextColor(1, 1, 1)
    self.Castbar.Text:SetJustifyH("LEFT")
    self.Castbar.Text:SetWordWrap(false)

    -- self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
    -- self.Castbar.Button:SetSize(48, 48)
    -- -- if self.unit == "player" or self.unit == "focus" then
    --     self.Castbar.Button:SetPoint("RIGHT", self.Castbar, "LEFT", 8, 0)
    -- -- elseif self.unit == "target" or self.unit == "boss" or self.unit == "arena" then
    -- --     self.Castbar.Button:SetPoint("LEFT", self.Castbar, "LEFT", 8, 0)
    -- -- end
    -- self.Castbar.Button:SetFrameLevel(self.Castbar.border:GetFrameLevel() + 2)
    -- self.Castbar.Button:SetFrameStrata("HIGH")


    -- -- Create a circular border texture for the portrait
    -- self.Castbar.BorderTexture = self.Castbar.Button:CreateTexture(nil, 'OVERLAY')
    -- self.Castbar.BorderTexture:SetAllPoints(self.Castbar.Button)
    -- self.Castbar.BorderTexture:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBorder.blp")
    -- self.Castbar.BorderTexture:SetVertexColor(.6, .6, .6, 1)
    -- self.Castbar.BorderTexture:SetDrawLayer("OVERLAY", 3)


    -- self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
    -- self.Castbar.Icon:SetPoint("CENTER", self.Castbar.Button, "CENTER", 0, 0)
    -- self.Castbar.Icon:SetSize(36, 36)
    -- self.Castbar.Icon:SetDrawLayer("OVERLAY", 2)



    -- -- Create and apply a circular mask
    -- local mask = self.Castbar.Button:CreateMaskTexture()
    -- mask:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitMask.blp")
    -- mask:SetAllPoints(self.Castbar.BorderTexture)
    -- self.Castbar.Icon:AddMaskTexture(mask)

    -- -- Background texture for the portrait
    -- local BackgroundTexture = self.Castbar:CreateTexture(nil, 'BACKGROUND') -- Use BACKGROUND layer
    -- BackgroundTexture:SetAllPoints(self.Castbar.BorderTexture)                            -- Center it over the health bar
    -- BackgroundTexture:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBG.blp")
    -- BackgroundTexture:SetVertexColor(unpack(C.media.borderColor))            -- Set a color with some transparency
    -- BackgroundTexture:SetDrawLayer("OVERLAY", 1)                             -- Ensure it is behind the border and portrait




    -- self.Castbar.Button.Cooldown = CreateFrame("Cooldown", nil, self.Castbar.Button, "CooldownFrameTemplate")
    -- self.Castbar.Button.Cooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CDBig.blp")
    -- self.Castbar.Button.Cooldown:SetAllPoints(self.Castbar.Button)
    -- self.Castbar.Button.Cooldown:SetDrawBling(false)
    -- self.Castbar.Button.Cooldown:SetDrawEdge(false)
    -- self.Castbar.Button.Cooldown:SetSwipeColor(0, 0, 0, 0.6)
    -- self.Castbar.Button.Cooldown:SetReverse(false)
    -- self.Castbar.Button.Cooldown:SetFrameLevel(self.Castbar.Button:GetFrameLevel() + 1)
    -- self.Castbar.Button.Cooldown:SetAlpha(0)

    self.Castbar.Time = R.SetFontString(self.Castbar, unpack(C.font.unitframes.spelltime))
    self.Castbar.Time:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMRIGHT", 0, 2)
    self.Castbar.Time:SetTextColor(1, 1, 1)
    self.Castbar.Time:SetJustifyH("CENTER")
    self.Castbar.CustomTimeText = UF.CustomCastTimeText
    self.Castbar.CustomDelayText = UF.CustomCastDelayText

    self.Castbar.PostCastStart = UF.PostCastStart
end

----------------------------------------------------------------------------------------
-- Debuffs
----------------------------------------------------------------------------------------
function UF.CreateDebuffs(self)
    self.Debuffs = CreateFrame("Frame", self:GetName() .. "_Debuffs", self)
    self.Debuffs:SetHeight(R.frameHeight * 3)
    self.Debuffs:SetWidth(C.unitframes.frameWidth + 4)
    self.Debuffs.size = R.Scale(C.player.debuffSize)
    self.Debuffs.spacing = R.Scale(3)
    self.Debuffs.initialAnchor = "BOTTOMLEFT"
    self.Debuffs["growth-y"] = "UP"
    self.Debuffs["growth-x"] = "RIGHT"

    self.Debuffs.PostCreateButton = UF.PostCreateIcon
    self.Debuffs.PostUpdateButton = UF.PostUpdateIcon

    PositionDebuffs(self)
    self.PositionDebuffs = PositionDebuffs
end

----------------------------------------------------------------------------------------
-- Auras
----------------------------------------------------------------------------------------
function UF.CreateAuras(self)
    self.Auras = CreateFrame("Frame", self:GetName() .. "_Auras", self)
    self.Auras:ClearAllPoints()
    self.Auras:SetPoint("BOTTOM", self.Health, "TOP", 0, 24)
    self.Auras.initialAnchor = "BOTTOMLEFT"
    self.Auras["growth-x"] = "RIGHT"
    self.Auras["growth-y"] = "UP"
    self.Auras.numDebuffs = 16
    self.Auras.numBuffs = 32
    self.Auras:SetHeight(R.frameHeight * 3)
    self.Auras:SetWidth(C.unitframes.frameWidth + 4)
    self.Auras.spacing = R.Scale(6)
    self.Auras.size = R.Scale(C.auras.debuffSize)
    self.Auras.gap = true
    self.Auras.PostCreateButton = UF.PostCreateIcon
    self.Auras.PostUpdateButton = UF.PostUpdateIcon
    self.Auras.FilterAura = UF.CustomFilter
end

function UF.CreateBossAuras(self)
    self.Auras = CreateFrame("Frame", self:GetName() .. "_Auras", self)
    self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -2, 24)
    self.Auras.initialAnchor = "BOTTOMLEFT"
    self.Auras["growth-x"] = "RIGHT"
    self.Auras["growth-y"] = "UP"
    self.Auras.numDebuffs = 16
    self.Auras.numBuffs = 32
    self.Auras:SetHeight(165)
    self.Auras:SetWidth(C.unitframes.frameWidth - 2)
    self.Auras.spacing = R.Scale(3)
    self.Auras.size = R.Scale(C.auras.debuffSize * 1.25)
    self.Auras.gap = true
    self.Auras.PostCreateButton = UF.PostCreateIcon
    self.Auras.PostUpdateButton = UF.PostUpdateIcon
    self.Auras.FilterAura = UF.CustomFilterBoss
end

----------------------------------------------------------------------------------------
-- Aura Watch
----------------------------------------------------------------------------------------
function UF.CreatePartyAuraWatch(self)
    UF.CreatePlayerBuffWatch(self)
    -- UF.CreatePartyBuffWatch(self)
end

function UF.CreateRaidDebuffs(self)
    -- Raid debuffs
    self.RaidDebuffs = CreateFrame("Frame", nil, self)
    self.RaidDebuffs:SetSize(19, 19)
    self.RaidDebuffs:SetPoint("BOTTOM", self, "TOP", 0, 24)
    self.RaidDebuffs:SetFrameStrata("MEDIUM")
    self.RaidDebuffs:SetFrameLevel(10)
    self.RaidDebuffs:SetTemplate("Icon")

    self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "BORDER")
    self.RaidDebuffs.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.RaidDebuffs.icon:SetPoint("TOPLEFT", 2, -2)
    self.RaidDebuffs.icon:SetPoint("BOTTOMRIGHT", -2, 2)


    self.RaidDebuffs.count = R.SetFontString(self.RaidDebuffs, unpack(C.font.auras.smallCount))
    self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 3, -1)
    self.RaidDebuffs.count:SetTextColor(1, 1, 1)


    self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs, "CooldownFrameTemplate")
    self.RaidDebuffs.cd:SetPoint("TOPLEFT", 2, -2)
    self.RaidDebuffs.cd:SetPoint("BOTTOMRIGHT", -2, 2)
    self.RaidDebuffs.cd:SetReverse(true)
    self.RaidDebuffs.cd:SetDrawEdge(false)
    self.RaidDebuffs.cd.noCooldownCount = true
    self.RaidDebuffs.parent = CreateFrame("Frame", nil, self.RaidDebuffs)
    self.RaidDebuffs.parent:SetFrameLevel(self.RaidDebuffs.cd:GetFrameLevel() + 1)
    self.RaidDebuffs.count:SetParent(self.RaidDebuffs.parent)

    self.RaidDebuffs.ShowDispellableDebuff = true
    self.RaidDebuffs.FilterDispellableDebuff = true
    self.RaidDebuffs.MatchBySpellName = true
end

----------------------------------------------------------------------------------------
-- Raid Icons
----------------------------------------------------------------------------------------
function UF.CreateRaidIcons(self)
    local unit = self.unit
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
    self.RaidTargetIndicator:SetSize(R.frameHeight * 1.5, R.frameHeight * 1.5)
    if unit == "focus" then
        self.RaidTargetIndicator:SetPoint("LEFT", self, "RIGHT", 4, 0)
    elseif unit == "target" or unit == "boss" or unit == "arena" then
        self.RaidTargetIndicator:SetPoint("RIGHT", self, "LEFT", -4, 0)
    end
end

----------------------------------------------------------------------------------------
-- Class Resources
----------------------------------------------------------------------------------------
function UF.CreateClassResources(self)
    if self.unit ~= "player" then return end

    local class = select(2, UnitClass("player"))

    -- Death Knight Runes
    if R.class == "DEATHKNIGHT" then
        self.Runes = CreateResourceBar(self, 6, { 1, 0, 0 }, "Rune")
        self.Runes.colorSpec = true
        self.Runes.sortOrder = "asc"
    end

    if R.class == "MAGE" then
        self.ArcaneCharge = CreateResourceBar(self, 4, { 0.4, 0.8, 1 }, "ArcaneCharge")
    end

    if R.class == "MONK" then
        self.HarmonyBar = CreateResourceBar(self, 6, { 0.33, 0.63, 0.33 }, "Harmony")
    end

    if R.class == "PALADIN" then
        self.HolyPower = CreateResourceBar(self, 5, { 0.89, 0.88, 0.1 }, "HolyPower")
    end

    if R.class == "WARLOCK" then
        self.SoulShards = CreateResourceBar(self, 5, { 0.9, 0.37, 0.37 }, "SoulShards")
    end

    if R.class == "EVOKER" then
        self.Essence = CreateResourceBar(self, 6, { 0.2, 0.58, 0.5 }, "Essence")
    end

    if (R.class == "ROGUE" or R.class == "DRUID") then
        self.ComboPoints = CreateResourceBar(self, 7, { 1, 0.8, 0 }, "Combo")
    end

    if R.class == "MONK" then
        self.Stagger = CreateFrame("StatusBar", self:GetName() .. "_Stagger", self)
        self.Stagger:CreateBackdrop("Default")
        self.Stagger:SetPoint("BOTTOM", self, "TOP", 0, 10)
        self.Stagger:SetSize(C.unitframes.frameWidth - 4, 7)
        self.Stagger:SetStatusBarTexture(C.media.texture)

        self.Stagger.bg = self.Stagger:CreateTexture(nil, "BORDER")
        self.Stagger.bg:SetAllPoints()
        self.Stagger.bg:SetTexture(C.media.texture)
        self.Stagger.bg.multiplier = 0.2

        -- self.Stagger.Text = UF.SetFontString(self.Stagger, C.font.unitframes_font, C.font.unitframes_font_size,
        --     C.font.unitframes_font_style)
        -- self.Stagger.Text:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
    end

    if R.class == "SHAMAN" then
        self.TotemBar = CreateResourceBar(self, 4, { 0.5, 0.5, 0.5 }, "Totem")
        self.TotemBar.Destroy = true
        for i = 1, 4 do
            self.TotemBar[i]:SetMinMaxValues(0, 1)
        end
    end

    -- if C.unitframe_class_bar.totem_other == true and R.class ~= "SHAMAN" then
    --     self.TotemBar = CreateFrame("Frame", self:GetName() .. "_TotemBar", self)
    --     self.TotemBar:SetFrameLevel(self.Health:GetFrameLevel() + 2)
    --     self.TotemBar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    --     self.TotemBar:SetSize(140, 7)
    --     self.TotemBar.Destroy = true

    --     for i = 1, 4 do
    --         self.TotemBar[i] = CreateFrame("StatusBar", self:GetName() .. "_Totem" .. i, self.TotemBar)
    --         self.TotemBar[i]:SetSize(140 / 4, 7)
    --         if i == 1 then
    --             self.TotemBar[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
    --         else
    --             self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i - 1], "TOPRIGHT", 0, 0)
    --         end
    --         self.TotemBar[i]:SetStatusBarTexture(C.media.texture)
    --         self.TotemBar[i]:SetMinMaxValues(0, 1)
    --         self.TotemBar[i]:CreateBorder(false, true)

    --         self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
    --         self.TotemBar[i].bg:SetAllPoints()
    --         self.TotemBar[i].bg:SetTexture(C.media.texture)
    --         self.TotemBar[i].bg.multiplier = 0.2
    --     end
    -- end

    -- -- Additional mana
    -- if R.class == "DRUID" or R.class == "PRIEST" or R.class == "SHAMAN" then
    --     CreateFrame("Frame"):SetScript("OnUpdate", function() UF.UpdateClassMana(self) end)
    --     self.ClassMana = UF.SetFontString(self.Power, C.font.unitframes_font, C.font.unitframes_font_size,
    --         C.font.unitframes_font_style)
    --     self.ClassMana:SetTextColor(1, 0.49, 0.04)
    -- end
end

function UF.CreateRuneBar(self)
    self.Runes = CreateFrame("Frame", self:GetName() .. "_RuneBar", self)
    self.Runes:CreateBackdrop("Default")
    self.Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.Runes:SetSize(C.unitframe.frame_width, 7)
    self.Runes.colorSpec = true
    self.Runes.sortOrder = "asc"

    for i = 1, 6 do
        self.Runes[i] = CreateFrame("StatusBar", self:GetName() .. "_Rune" .. i, self.Runes)
        self.Runes[i]:SetSize((C.unitframe.frame_width - 5) / 6, 7)
        if i == 1 then
            self.Runes[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.Runes[i]:SetPoint("TOPLEFT", self.Runes[i - 1], "TOPRIGHT", 1, 0)
        end
        self.Runes[i]:SetStatusBarTexture(C.media.texture)

        self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
        self.Runes[i].bg:SetAllPoints()
        self.Runes[i].bg:SetTexture(C.media.texture)
        self.Runes[i].bg.multiplier = 0.2
    end
end

function UF.CreateComboPoints(self)
    self.ComboPoints = CreateFrame("Frame", self:GetName() .. "_ComboBar", self)
    self.ComboPoints:CreateBackdrop("Default")
    self.ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.ComboPoints:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 7 do
        self.ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "_Combo" .. i, self.ComboPoints)
        self.ComboPoints[i]:SetSize((C.unitframe.frame_width - 6) / 7, 7)
        if i == 1 then
            self.ComboPoints[i]:SetPoint("LEFT", self.ComboPoints)
        else
            self.ComboPoints[i]:SetPoint("LEFT", self.ComboPoints[i - 1], "RIGHT", 1, 0)
        end
        self.ComboPoints[i]:SetStatusBarTexture(C.media.texture)
        self.ComboPoints[i]:SetStatusBarColor(0.9, 0.1, 0.1)

        self.ComboPoints[i].bg = self.ComboPoints[i]:CreateTexture(nil, "BORDER")
        self.ComboPoints[i].bg:SetAllPoints()
        self.ComboPoints[i].bg:SetTexture(C.media.texture)
        self.ComboPoints[i].bg:SetVertexColor(0.9, 0.1, 0.1, 0.2)
    end
end

function UF.CreateChiBar(self)
    self.HarmonyBar = CreateFrame("Frame", self:GetName() .. "_HarmonyBar", self)
    self.HarmonyBar:CreateBackdrop("Default")
    self.HarmonyBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.HarmonyBar:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 6 do
        self.HarmonyBar[i] = CreateFrame("StatusBar", self:GetName() .. "_Harmony" .. i, self.HarmonyBar)
        self.HarmonyBar[i]:SetSize((C.unitframe.frame_width - 5) / 6, 7)
        if i == 1 then
            self.HarmonyBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.HarmonyBar[i]:SetPoint("TOPLEFT", self.HarmonyBar[i - 1], "TOPRIGHT", 1, 0)
        end
        self.HarmonyBar[i]:SetStatusBarTexture(C.media.texture)
        self.HarmonyBar[i]:SetStatusBarColor(0.33, 0.63, 0.33)

        self.HarmonyBar[i].bg = self.HarmonyBar[i]:CreateTexture(nil, "BORDER")
        self.HarmonyBar[i].bg:SetAllPoints()
        self.HarmonyBar[i].bg:SetTexture(C.media.texture)
        self.HarmonyBar[i].bg:SetVertexColor(0.33, 0.63, 0.33, 0.2)
    end
end

function UF.CreateHolyPower(self)
    self.HolyPower = CreateFrame("Frame", self:GetName() .. "_HolyPowerBar", self)
    self.HolyPower:CreateBackdrop("Default")
    self.HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.HolyPower:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 5 do
        self.HolyPower[i] = CreateFrame("StatusBar", self:GetName() .. "_HolyPower" .. i, self.HolyPower)
        self.HolyPower[i]:SetSize((C.unitframe.frame_width - 4) / 5, 7)
        if i == 1 then
            self.HolyPower[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.HolyPower[i]:SetPoint("TOPLEFT", self.HolyPower[i - 1], "TOPRIGHT", 1, 0)
        end
        self.HolyPower[i]:SetStatusBarTexture(C.media.texture)
        self.HolyPower[i]:SetStatusBarColor(0.89, 0.88, 0.1)

        self.HolyPower[i].bg = self.HolyPower[i]:CreateTexture(nil, "BORDER")
        self.HolyPower[i].bg:SetAllPoints()
        self.HolyPower[i].bg:SetTexture(C.media.texture)
        self.HolyPower[i].bg:SetVertexColor(0.89, 0.88, 0.1, 0.2)
    end
end

function UF.CreateTotemBar(self)
    self.TotemBar = CreateFrame("Frame", self:GetName() .. "_TotemBar", self)
    self.TotemBar:CreateBackdrop("Default")
    self.TotemBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.TotemBar:SetSize(C.unitframe.frame_width, 7)
    self.TotemBar.Destroy = true

    for i = 1, 4 do
        self.TotemBar[i] = CreateFrame("StatusBar", self:GetName() .. "_Totem" .. i, self.TotemBar)
        self.TotemBar[i]:SetSize((C.unitframe.frame_width - 3) / 4, 7)

        if i == 1 then
            self.TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i - 1], "TOPRIGHT", 1, 0)
        end
        self.TotemBar[i]:SetStatusBarTexture(C.media.texture)
        self.TotemBar[i]:SetMinMaxValues(0, 1)

        self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
        self.TotemBar[i].bg:SetAllPoints()
        self.TotemBar[i].bg:SetTexture(C.media.texture)
        self.TotemBar[i].bg.multiplier = 0.2
    end
end

function UF.CreateSoulShards(self)
    self.SoulShards = CreateFrame("Frame", self:GetName() .. "_SoulShardsBar", self)
    self.SoulShards:CreateBackdrop("Default")
    self.SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.SoulShards:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 5 do
        self.SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "_SoulShards" .. i, self.SoulShards)
        self.SoulShards[i]:SetSize((C.unitframe.frame_width - 4) / 5, 7)
        if i == 1 then
            self.SoulShards[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.SoulShards[i]:SetPoint("TOPLEFT", self.SoulShards[i - 1], "TOPRIGHT", 1, 0)
        end
        self.SoulShards[i]:SetStatusBarTexture(C.media.texture)
        self.SoulShards[i]:SetStatusBarColor(0.9, 0.37, 0.37)

        self.SoulShards[i].bg = self.SoulShards[i]:CreateTexture(nil, "BORDER")
        self.SoulShards[i].bg:SetAllPoints()
        self.SoulShards[i].bg:SetTexture(C.media.texture)
        self.SoulShards[i].bg:SetVertexColor(0.9, 0.37, 0.37, 0.2)
    end
end

function UF.CreateArcaneCharges(self)
    self.ArcaneCharge = CreateFrame("Frame", self:GetName() .. "_ArcaneChargeBar", self)
    self.ArcaneCharge:CreateBackdrop("Default")
    self.ArcaneCharge:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.ArcaneCharge:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 4 do
        self.ArcaneCharge[i] = CreateFrame("StatusBar", self:GetName() .. "_ArcaneCharge" .. i, self.ArcaneCharge)
        self.ArcaneCharge[i]:SetSize((C.unitframe.frame_width - 3) / 4, 7)
        if i == 1 then
            self.ArcaneCharge[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
        else
            self.ArcaneCharge[i]:SetPoint("TOPLEFT", self.ArcaneCharge[i - 1], "TOPRIGHT", 1, 0)
        end
        self.ArcaneCharge[i]:SetStatusBarTexture(C.media.texture)
        self.ArcaneCharge[i]:SetStatusBarColor(0.4, 0.8, 1)

        self.ArcaneCharge[i].bg = self.ArcaneCharge[i]:CreateTexture(nil, "BORDER")
        self.ArcaneCharge[i].bg:SetAllPoints()
        self.ArcaneCharge[i].bg:SetTexture(C.media.texture)
        self.ArcaneCharge[i].bg:SetVertexColor(0.4, 0.8, 1, 0.2)
    end
end

function UF.CreateEssenceBar(self)
    self.Essence = CreateFrame("Frame", self:GetName() .. "_Essence", self)
    self.Essence:CreateBackdrop("Default")
    self.Essence:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 7)
    self.Essence:SetSize(C.unitframe.frame_width, 7)

    for i = 1, 6 do
        self.Essence[i] = CreateFrame("StatusBar", self:GetName() .. "_Essence" .. i, self.Essence)
        self.Essence[i]:SetSize((C.unitframe.frame_width - 5) / 6, 7)
        if i == 1 then
            self.Essence[i]:SetPoint("LEFT", self.Essence)
        else
            self.Essence[i]:SetPoint("TOPLEFT", self.Essence[i - 1], "TOPRIGHT", 1, 0)
        end
        self.Essence[i]:SetStatusBarTexture(C.media.texture)
        self.Essence[i]:SetStatusBarColor(0.2, 0.58, 0.5)

        self.Essence[i].bg = self.Essence[i]:CreateTexture(nil, "BORDER")
        self.Essence[i].bg:SetAllPoints()
        self.Essence[i].bg:SetTexture(C.media.texture)
        self.Essence[i].bg:SetVertexColor(0.2, 0.58, 0.5, 0.2)
    end
end

----------------------------------------------------------------------------------------
-- Info
----------------------------------------------------------------------------------------
function UF.CreateInfo(self)
    self.FlashInfo = CreateFrame("Frame", "FlashInfo", self)
    self.FlashInfo:SetScript("OnUpdate", UF.UpdateManaLevel)
    self.FlashInfo:SetFrameLevel(self.Health:GetFrameLevel() + 1)
    self.FlashInfo:SetAllPoints(self.Health)

    self.FlashInfo.ManaLevel = R.SetFontString(self.FlashInfo, unpack(C.font.unitframes.default))
    self.FlashInfo.ManaLevel:SetPoint("CENTER", self.Power, "CENTER", 0, 1)

    self.Status = R.SetFontString(self.Health, unpack(C.font.unitframes.default))
    self.Status:SetPoint("CENTER", self.Power, "CENTER", 0, 1)
    self.Status:SetTextColor(0.69, 0.31, 0.31)
    self.Status:Hide()
    self.Status.Override = R.dummy

    self:SetScript("OnEnter", function(self)
        self.FlashInfo.ManaLevel:Hide()
        UF.UpdatePvPStatus(self)
        self.Status:Show()
        UnitFrame_OnEnter(self)
    end)
    self:SetScript("OnLeave", function(self)
        self.FlashInfo.ManaLevel:Show()
        self.Status:Hide()
        UnitFrame_OnLeave(self)
    end)
end

----------------------------------------------------------------------------------------
-- Additional Elements
----------------------------------------------------------------------------------------
function UF.CreateRaidTargetIndicator(self)
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
    self.RaidTargetIndicator:SetParent(self.Health)
    self.RaidTargetIndicator:SetSize(
        (self.unit == "player" or self.unit == "target") and 15 or 12,
        (self.unit == "player" or self.unit == "target") and 15 or 12)
    self.RaidTargetIndicator:SetPoint("TOP", self.Health, 0, 0)
end

function UF.ApplyGroupSettings(self)
    -- UF.CreateHealthPrediction(self)
    self.Range = { insideAlpha = 1, outsideAlpha = C.group.rangeAlpha }
    self.Health.PostUpdate = UF.PostUpdateRaidHealth
    if UF.PostCreateHealRaidFrames then
        UF.PostCreateHealRaidFrames(self, self.unit)
    end
end

function UF.CreateDebuffHighlight(self)
    self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
    self.DebuffHighlight:SetAllPoints(self.Health)
    self.DebuffHighlight:SetTexture(C.media.highlight)
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlightAlpha = 1
    self.DebuffHighlightFilter = true
end

function UF.CreateGroupIcons(self)
    -- Raid mark
    self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.RaidTargetIndicator:SetSize(24, 24)
    self.RaidTargetIndicator:SetPoint("RIGHT", self.Health, -2, 0)

    -- LFD role icons
    self.GroupRoleIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.GroupRoleIndicator:SetSize(16, 16)
    self.GroupRoleIndicator:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -4, 2)

    -- Ready check icons
    self.ReadyCheckIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 7) -- Increased draw level to 7
    self.ReadyCheckIndicator:SetSize(36, 36)
    self.ReadyCheckIndicator:SetPoint("CENTER", self.Health, 2, 1)

    -- Summon icons
    self.SummonIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.SummonIndicator:SetSize(36, 36)
    self.SummonIndicator:SetPoint("BOTTOMRIGHT", self.Health, 7, -11)

    -- Phase icons
    self.PhaseIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.PhaseIndicator:SetSize(36, 36)
    self.PhaseIndicator:SetPoint("TOPRIGHT", self.Health, 5, 5)

    -- Leader/Assistant icons
    -- Leader icon
    self.LeaderIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.LeaderIndicator:SetSize(16, 16)
    self.LeaderIndicator:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 5, 2)
    -- Assistant icon
    self.AssistantIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.AssistantIndicator:SetSize(16, 16)
    self.AssistantIndicator:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 5, 2)

    -- Resurrect icon
    self.ResurrectIndicator = self.Health:CreateTexture(nil, "OVERLAY")
    self.ResurrectIndicator:SetSize(13 * C.group.icon_multiplier, 13 * C.group.icon_multiplier)
    self.ResurrectIndicator:SetPoint("BOTTOMRIGHT", self.Health, 2, -7)
end

function UF.CreateExperienceBar(self)
    -- Position and size
    local Experience = CreateFrame('StatusBar', "RefineUI_ExperienceBar", UIParent)
    Experience:SetPoint(unpack(C.position.unitframes.experienceBar))
    Experience:SetSize(296, 27)
    Experience:EnableMouse(true) -- for tooltip/fading support
    Experience:SetTemplate("Default")
    Experience:SetStatusBarTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\Statusbar.blp")
    Experience.bg = SetupTexture(Experience, "BORDER", Experience,
        "Interface\\AddOns\\RefineUI\\Media\\Textures\\HealthBG")
    Experience.bg:SetVertexColor(0.4, 0.4, 0.4, 1)
    -- Position and size the Rested sub-widget
    local Rested = CreateFrame('StatusBar', nil, Experience)
    Rested:SetAllPoints(Experience)

    -- Text display
    local Value = Experience:CreateFontString(nil, 'OVERLAY')
    Value:SetAllPoints(Experience)
    Value:SetFontObject(GameFontHighlight)
    self:Tag(Value, '[experience:per]' .. "%")

    -- Add a background
    local Background = Rested:CreateTexture(nil, 'BACKGROUND')
    Background:SetAllPoints(Experience)
    Background:SetTexture('Interface\\ChatFrame\\ChatFrameBackground')

    -- Register with oUF
    self.Experience = Experience
    self.Experience.Rested = Rested

    StatusTrackingBarManager:Hide()
end

return UF
