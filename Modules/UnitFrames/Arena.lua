local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local UIParent = UIParent

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local MAX_ARENA_FRAMES = 3
local ARENA_SPACING = R.frameHeight * 2

----------------------------------------------------------------------------------------
-- Arena Frame Creation
----------------------------------------------------------------------------------------
local function CreateArenaFrame(self)
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
-- Arena Frames Initialization
----------------------------------------------------------------------------------------
-- Register and set the arena frame style
oUF:RegisterStyle('RefineUI_Arena', CreateArenaFrame)
oUF:SetActiveStyle('RefineUI_Arena')

-- Create anchor
local arenaAnchor = CreateFrame("Frame", "RefineUI_Arena", UIParent)
arenaAnchor:SetPoint("CENTER", UIParent, "CENTER", C.position.unitframes.arena, C.position.unitframes.arena)
R.PixelSnap(arenaAnchor)

-- Calculate total height for all arena frames
local totalHeight = (R.frameHeight * MAX_ARENA_FRAMES) + (ARENA_SPACING * (MAX_ARENA_FRAMES - 1))

-- Set the size of the arena anchor
arenaAnchor:SetSize(R.PixelPerfect(R.frameWidth), R.PixelPerfect(totalHeight))

-- Create and position arena frames
local arenaFrames = {}
for i = 1, MAX_ARENA_FRAMES do
    arenaFrames[i] = oUF:Spawn("arena" .. i, "RefineUI_Arena" .. i)
    R.SetPixelSize(arenaFrames[i], R.frameWidth, R.frameHeight)
    
    if i == 1 then
        arenaFrames[i]:SetPoint("TOPLEFT", arenaAnchor, "TOPLEFT", 0, 0)
    else
        arenaFrames[i]:SetPoint("TOP", arenaFrames[i-1], "BOTTOM", 0, -ARENA_SPACING)
    end
    
    R.PixelSnap(arenaFrames[i])
end

-- Make sure the arena anchor is pixel-perfect
R.PixelSnap(arenaAnchor)

----------------------------------------------------------------------------------------
-- Expose CreateArenaFrame function and arena frames
----------------------------------------------------------------------------------------
UF.CreateArenaFrame = CreateArenaFrame
UF.ArenaFrames = arenaFrames
UF.ArenaAnchor = arenaAnchor