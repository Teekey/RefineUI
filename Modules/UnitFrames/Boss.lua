local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local UIParent = UIParent

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local MAX_BOSS_FRAMES = 8
local BOSS_SPACING = R.frameHeight * 3

----------------------------------------------------------------------------------------
-- Boss Frame Creation
----------------------------------------------------------------------------------------
local function CreateBossFrame(self)
    -- Configure base unit frame
    UF.ConfigureUnitFrame(self, "Default")

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateNameText(self)
    UF.CreateCastBar(self, "Default")
    UF.CreateAuras(self)
    UF.CreateInfo(self)
    UF.CreateRaidIcons(self)

    return self
end

----------------------------------------------------------------------------------------
-- Boss Frames Initialization
----------------------------------------------------------------------------------------
-- Register and set the boss frame style
oUF:RegisterStyle('RefineUI_Boss', CreateBossFrame)
oUF:SetActiveStyle('RefineUI_Boss')

-- Create anchor
local bossAnchor = CreateFrame("Frame", "RefineUI_Boss", UIParent)
bossAnchor:SetPoint(unpack(C.position.unitframes.boss))
R.PixelSnap(bossAnchor)

-- Calculate total height for all boss frames
local totalHeight = (R.frameHeight * MAX_BOSS_FRAMES) + (BOSS_SPACING * (MAX_BOSS_FRAMES - 1))

-- Set the size of the boss anchor
bossAnchor:SetSize(R.PixelPerfect(R.frameWidth), R.PixelPerfect(totalHeight))

-- Create and position boss frames
local bossFrames = {}
for i = 1, MAX_BOSS_FRAMES do
    bossFrames[i] = oUF:Spawn("boss" .. i, "RefineUI_Boss" .. i)
    R.SetPixelSize(bossFrames[i], R.frameWidth, R.frameHeight)

    if i == 1 then
        bossFrames[i]:SetPoint("TOPLEFT", bossAnchor, "TOPLEFT", 0, 0)
    else
        bossFrames[i]:SetPoint("TOP", bossFrames[i - 1], "BOTTOM", 0, -BOSS_SPACING)
    end

    R.PixelSnap(bossFrames[i])
end

-- Make sure the boss anchor is pixel-perfect
R.PixelSnap(bossAnchor)

----------------------------------------------------------------------------------------
-- Expose CreateBossFrame function and boss frames
----------------------------------------------------------------------------------------
UF.CreateBossFrame = CreateBossFrame
UF.BossFrames = bossFrames
UF.BossAnchor = bossAnchor