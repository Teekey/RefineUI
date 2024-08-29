local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local unpack = unpack

----------------------------------------------------------------------------------------
-- Focus Frame Creation
----------------------------------------------------------------------------------------
local function CreateFocusFrame(self)
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
-- Focus Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the focus frame style
oUF:RegisterStyle('RefineUI_Focus', CreateFocusFrame)
oUF:SetActiveStyle('RefineUI_Focus')

-- Spawn the focus frame
local focus = oUF:Spawn("focus", "RefineUI_Focus", UIParent)

-- Set frame size and position
R.SetPixelSize(focus, R.frameWidth, R.frameHeight)
focus:SetPoint(unpack(C.position.unitframes.focus))
R.PixelSnap(focus)

----------------------------------------------------------------------------------------
-- Expose CreateFocusFrame function
----------------------------------------------------------------------------------------
UF.CreateFocusFrame = CreateFocusFrame