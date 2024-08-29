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
local BOSS_SPACING = R.frameHeight * 2

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

-- Create and position boss frames
local bossFrames = {}
for i = 1, MAX_BOSS_FRAMES do
    bossFrames[i] = oUF:Spawn("boss" .. i, "RefineUI_Boss" .. i)
    R.SetPixelSize(bossFrames[i], R.frameWidth, R.frameHeight)
    
    if i == 1 then
        bossFrames[i]:SetPoint("CENTER", UIParent, "CENTER", C.position.unitframes.boss, C.position.unitframes.boss)
    else
        bossFrames[i]:SetPoint("TOP", bossFrames[i-1], "BOTTOM", 0, -BOSS_SPACING)
    end
    
    R.PixelSnap(bossFrames[i])
end

----------------------------------------------------------------------------------------
-- Expose CreateBossFrame function and boss frames
----------------------------------------------------------------------------------------
UF.CreateBossFrame = CreateBossFrame
UF.BossFrames = bossFrames