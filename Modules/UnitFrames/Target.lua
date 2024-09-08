local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local unpack = unpack

----------------------------------------------------------------------------------------
-- Target Frame Creation
----------------------------------------------------------------------------------------
local function CreateTargetFrame(self)
    -- Configure base unit frame
    UF.ConfigureUnitFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateNameText(self)
    UF.CreatePortraitAndCastIcon(self)
    UF.CreateCastBar(self)
    UF.CreateAuras(self)
    UF.CreateInfo(self)
    UF.CreateRaidIcons(self)

    return self
end

----------------------------------------------------------------------------------------
-- Target Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the target frame style
oUF:RegisterStyle('RefineUI_Target', CreateTargetFrame)
oUF:SetActiveStyle('RefineUI_Target')

-- Spawn the target frame
local target = oUF:Spawn("target", "RefineUI_Target", UIParent)

-- Set frame size and position
R.SetPixelSize(target, R.frameWidth, R.frameHeight)
target:SetPoint(unpack(C.position.unitframes.target))
R.PixelSnap(target)

----------------------------------------------------------------------------------------
-- Expose CreateTargetFrame function
----------------------------------------------------------------------------------------
UF.CreateTargetFrame = CreateTargetFrame