local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Upvalues
local unpack = unpack

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local PET_WIDTH = R.frameWidth / 5

----------------------------------------------------------------------------------------
-- Pet Frame Creation
----------------------------------------------------------------------------------------
local function CreatePetFrame(self)
    -- Configure base unit frame
    UF.ConfigureUnitFrame(self, "Default")

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)

    return self
end

----------------------------------------------------------------------------------------
-- Pet Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the pet frame style
oUF:RegisterStyle('RefineUI_Pet', CreatePetFrame)
oUF:SetActiveStyle('RefineUI_Pet')

-- Spawn the pet frame
local pet = oUF:Spawn("pet", "RefineUI_Pet", UIParent)

-- Set frame size and position
R.SetPixelSize(pet, PET_WIDTH, R.frameHeight)
pet:SetPoint(unpack(C.position.unitframes.pet))
R.PixelSnap(pet)

----------------------------------------------------------------------------------------
-- Expose CreatePetFrame function
----------------------------------------------------------------------------------------
UF.CreatePetFrame = CreatePetFrame