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
local CreateFrame, hooksecurefunc, UIParent = CreateFrame, hooksecurefunc, UIParent
local UnitIsFriend, UnitIsPlayer, UnitClass, UnitCanAttack, UnitIsUnit = UnitIsFriend, UnitIsPlayer, UnitClass,
    UnitCanAttack, UnitIsUnit
local GetTime, select, unpack = GetTime, select, unpack
local C_NamePlate = C_NamePlate
local GetNamePlateForUnit, GetNamePlates = C_NamePlate.GetNamePlateForUnit, C_NamePlate.GetNamePlates

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
-- local NameplateContextFrame = CreateFrame("Frame", nil, UIParent)
-- NameplateContextFrame:Hide()
-- NameplateContextFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
-- NameplateContextFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- -- Create a single context menu button
-- local function CreateContextButton()
--     local button = CreateFrame("BUTTON", "NameplateContextButton", UIParent, "SecureActionButtonTemplate")
--     button:SetSize(200, 50)
--     button:RegisterForClicks('RightButtonUp', 'RightButtonDown')
--     button:SetAttribute('shift-type2', 'togglemenu')

--     -- Add texture to the button
--     local texture = button:CreateTexture(nil, "BACKGROUND")
--     texture:SetAllPoints(button)
--     texture:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
--     texture:SetTexCoord(0, 0.625, 0, 0.6875)
--     button.texture = texture

--     button:Hide()
--     return button
-- end

-- local ContextButton = CreateContextButton()

-- -- Helper functions
-- local function AnchorButton(frame, unit)
--     ContextButton:ClearAllPoints()
--     ContextButton:SetPoint("CENTER", frame, "CENTER", 0, 0)
--     ContextButton:SetAttribute('unit', unit)
--     ContextButton:Show()
-- end

-- local function HandleTargetChanged()
--     local unit = "target"
--     local frame = C_NamePlate.GetNamePlateForUnit(unit)

--     if frame then
--         -- Always attempt to anchor the button to the nameplate if it exists
--         AnchorButton(frame, unit)
--     else
--         ContextButton:Hide()
--     end
-- end

-- local function OnEvent(self, event)
--     if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
--         HandleTargetChanged()
--     end
-- end

-- -- Register the event handler
-- NameplateContextFrame:SetScript("OnEvent", OnEvent)


-- Nameplate configuration function
function NP.ConfigureNameplate(self, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    self:SetPoint("CENTER", nameplate, "CENTER")
    self:SetSize(C.nameplate.width, C.nameplate.height)

    table.insert(self.__elements, NP.UpdateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", NP.UpdateTarget, true)

    -- Disable movement via /moveui
    self.disableMovement = true

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
    self.Health:SetStatusBarTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\Health3")
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorHealth = true
    self.Health.Smooth = true
    CreateBorderFrame(self.Health)

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\HealthBG")
    self.Health.bg.multiplier = 0.5

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
    self.Health.value:SetFont(unpack(C.font.nameplates.health))
    self.Health.value:SetShadowOffset(1, -1)
    self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, -1)
    self:Tag(self.Health.value, "[NameplateHealth]")

    -- Register events for threat updates
    -- self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
    -- self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    -- self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    -- self.Health:RegisterEvent("UNIT_HEALTH")
    -- self.Health:SetScript("OnEvent", function()
    --     if C.nameplate.enhanceThreat then
    --         NP.UpdateThreat(self)
    --     end
    -- end)

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
    self.Name:SetFont(unpack(C.font.nameplates.name))
    self.Name:SetShadowOffset(1, -1)
    self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -4 * R.noscalemult, -2 * R.noscalemult)
    self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 4 * R.noscalemult, -2 * R.noscalemult)
    self.Name:SetWordWrap(false)
    self.Name:SetJustifyH("CENTER")
    self:Tag(self.Name, "[NameplateNameColor][NameLongAbbrev]")


    self.Title = self:CreateFontString(nil, "OVERLAY")
    self.Title:SetFont(unpack(C.font.nameplates.title))
    self.Title:SetShadowOffset(1, -1)
    self.Title:SetPoint("TOP", self.Name, "BOTTOM", 0, 0)
    self.Title:SetWordWrap(false)
    self.Title:SetJustifyH("CENTER")                 -- Center the text horizontally
    self.Title:SetTextColor(0.8, 0.8, 0.8)           -- Set text color to slightly off white
    self:Tag(self.Title, "[NPCTitle]")
    self.Title:SetWidth(self.Title:GetStringWidth()) -- Set width to the text width
end

function NP.CreatePortraitAndQuestIcon(self)

        -- Create a frame to attach the portrait to
        local PortraitFrame = CreateFrame("Frame", nil, self)
        PortraitFrame:SetSize(20, 20)
        PortraitFrame:SetPoint("RIGHT", self.Health, "LEFT", 5, 0)
        PortraitFrame:SetFrameLevel(self.Health:GetFrameLevel() + 2) -- Ensure this is higher than the background

        -- Create a circular border texture for the portrait
        local BorderTexture = PortraitFrame:CreateTexture(nil, 'OVERLAY')
        BorderTexture:SetAllPoints(PortraitFrame)
        BorderTexture:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\PortraitBorder.blp")
        BorderTexture:SetVertexColor(.6, .6, .6, 1)
        BorderTexture:SetDrawLayer("OVERLAY", 3)

        -- local r, g, b = unpack(R.oUF_colors.interruptible)
        -- BorderTexture:SetVertexColor(r, g, b)

        -- -- 2D Portrait
        -- local Portrait = PortraitFrame:CreateTexture(nil, 'OVERLAY')
        -- Portrait:SetSize(16, 16)
        -- Portrait:SetPoint('CENTER', PortraitFrame, 'CENTER')
        -- Portrait:SetDrawLayer("OVERLAY", 2)


        local portrait = PortraitFrame:CreateTexture(nil, 'ARTWORK')
        portrait:SetSize(16, 16)                             -- Change this to match the inner size of the frame
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
        self.PortraitBorder = BorderTexture
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
        self.Castbar:SetStatusBarTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\Castbar3.blp")
        self.Castbar:SetStatusBarColor(1, 0.8, 0)
        self.Castbar:SetPoint("TOP", self.Health, "BOTTOM", 0, 2)
        self.Castbar:SetSize(C.nameplate.width, C.nameplate.height + 2)
        CreateBorderFrame(self.Castbar)
        -- self.Castbar.border:SetFrameLevel(self.Health.border:GetFrameLevel() - 1)
        self.Castbar:SetFrameLevel(self.Health:GetFrameLevel() - 1)


        self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
        self.Castbar.bg:SetAllPoints()
        self.Castbar.bg:SetTexture(C.media.texture)
        self.Castbar.bg:SetColorTexture(1, 0.8, 0)
        self.Castbar.bg.multiplier = 0.5

        self.Castbar.PostCastStart = NP.PostCastStart
        self.Castbar.PostCastStop = NP.PostCastStop
        self.Castbar.PostCastInterruptible = NP.PostCastStart

        -- Cast Name Text
        self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Text:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMLEFT", 2, 1)
        self.Castbar.Text:SetFont(unpack(C.font.nameplates.spell))
        self.Castbar.Text:SetShadowOffset(1, -1)
        self.Castbar.Text:SetJustifyH("LEFT")

        -- -- -- Cast Bar Icon
        -- -- self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
        -- self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
        -- self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        -- self.Castbar.Icon:SetDrawLayer("ARTWORK")
        -- self.Castbar.Icon:SetSize((C.nameplate.height) * 2, (C.nameplate.height) * 2)
        -- self.Castbar.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, 0)
        -- self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -4, 0)
        -- self.Castbar.Icon:SetWidth(self.Castbar.Icon:GetHeight())

        -- self.Castbar.Icon:Hide()
        -- -- Cooldown frame
        -- self.Castbar.IconCooldown = CreateFrame("Cooldown", nil, self.Castbar.Button, "CooldownFrameTemplate") -- Ensure it's parented to Button
        -- self.Castbar.IconCooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CD.blp")
        -- self.Castbar.IconCooldown:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -2, 2)
        -- self.Castbar.IconCooldown:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 2, -2)
        -- self.Castbar.IconCooldown:SetDrawBling(false)
        -- self.Castbar.IconCooldown:SetDrawEdge(false)
        -- self.Castbar.IconCooldown:SetSwipeColor(0, 0, 0, 0.6)
        -- self.Castbar.IconCooldown:SetReverse(true)
        -- self.Castbar.IconCooldown:SetFrameLevel(self.Castbar.Button:GetFrameLevel() + 1) -- Set to the same level as the button


        -- Cast Time Text
        self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Time:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMRIGHT", 0, 1)
        self.Castbar.Time:SetJustifyH("RIGHT")
        self.Castbar.Time:SetFont(unpack(C.font.nameplates.spelltime))
        self.Castbar.Time:SetShadowOffset(1, -1)

        self.Castbar.CustomTimeText = function(self, duration)
            self.Time:SetText(duration > 600 and "∞" or
                ("%.1f"):format(self.channeling and duration or self.max - duration))
        end
end

----------------------------------------------------------------------------------------
-- Auras
----------------------------------------------------------------------------------------
function NP.CreateAuras(self)
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, C.font.nameplates.name[2] + 2)
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
-- Target Indicator
----------------------------------------------------------------------------------------
function NP.CreateTargetIndicator(self)
    self.RTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/RTargetArrow2.blp")
    self.RTargetIndicator:SetSize(C.nameplate.height + 2, C.nameplate.height + 2)
    self.RTargetIndicator:Hide()

    self.LTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.LTargetIndicator:SetTexture("Interface/AddOns/RefineUI/Media/Textures/LTargetArrow2.blp")
    self.LTargetIndicator:SetSize(C.nameplate.height + 2, C.nameplate.height + 2)
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
    -- self.QuestIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
    -- self.QuestIcon:SetSize((C.font.nameplates_name_font_size * 5), (C.font.nameplates_name_font_size * 5))
    -- self.QuestIcon:SetPoint("CENTER", self.Portrait, "CENTER", 0, 0)
    -- self.QuestIcon:Hide()

    -- self.QuestIcon.Text = self:CreateFontString(nil, "OVERLAY")
    -- self.QuestIcon.Text:SetPoint("CENTER", self.QuestIcon, "CENTER", .5, 0)
    -- self.QuestIcon.Text:SetJustifyH("CENTER")
    -- self.QuestIcon.Text:SetFont(C.font.nameplates_font, 6,
    --     C.font.nameplates_font_style)
    -- self.QuestIcon.Text:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0,
    --     C.font.nameplates_font_shadow and -1 or 0)

    -- self.QuestIcon.Item = self:CreateTexture(nil, "OVERLAY")
    -- self.QuestIcon.Item:SetSize((C.font.nameplates_name_font_size * 5.5), (C.font.nameplates_name_font_size * 5.5))
    -- self.QuestIcon.Item:SetPoint("CENTER", self.Portrait, "CENTER", 0, 0)
    -- self.QuestIcon.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

return NP
