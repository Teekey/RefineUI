local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local NP = R.NP or {}
R.NP = NP

----------------------------------------------------------------------------------------
-- Style Function
----------------------------------------------------------------------------------------
local function CreateNameplate(self, unit)
    local main = self
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    local isDead = UnitIsDead(unit)
    local visible = nameplate:IsVisible()
    if not isDead and not visible then
        RunNextFrame(function() main:Show() end)
    end
    
    NP.ConfigureNameplate(self, unit)

    NP.CreateHealthBar(self, unit)

    NP.CreatePowerBar(self, unit)

    NP.CreateNameText(self)

    NP.CreatePortraitAndQuestIcon(self)

    NP.CreateCastBar(self)

    NP.CreateRaidIcon(self, unit)

    if C.nameplate.targetIndicator then
        NP.CreateTargetIndicator(self)
    end

    if C.nameplate.targetGlow then
        NP.CreateTargetGlow(self)
    end

    if C.nameplate.quests then
        NP.CreateQuestIcon(self)
    end

    NP.CreateAuras(self)

    return self
end

----------------------------------------------------------------------------------------
-- Register Style and Spawn NamePlates
----------------------------------------------------------------------------------------
oUF:RegisterStyle("RefineUINameplates", CreateNameplate)
oUF:SetActiveStyle("RefineUINameplates")
oUF:SpawnNamePlates("RefineUINameplates", NP.Callback)
