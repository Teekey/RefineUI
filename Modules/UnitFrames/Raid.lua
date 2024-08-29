local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R:GetModule('UnitFrames')

----------------------------------------------------------------------------------------
--	RAID FRAME
----------------------------------------------------------------------------------------
function R.CreateRaidFrame(self)
    R.ConfigureUnitFrame(self, "Default")
    R.CreateHealthBar(self)
    R.CreatePowerBar(self)
    R.CreateNameText(self)
    R.CreateRaidIcons(self)
    R.CreateInfo(self)

    -- Raid-specific elements
    self:SetSize(C.raidframe.raid_width, C.raidframe.raid_height)
    self.Health:SetHeight(C.raidframe.raid_height - C.raidframe.raid_power_height - 1)
    self.Power:SetHeight(C.raidframe.raid_power_height)

    -- Add raid-specific indicators
    if C.raidframe.plugins_aura_watch then
        R.CreateAuraWatch(self)
    end
    if C.raidframe.plugins_debuffhighlight_icon then
        R.CreateRaidDebuffs(self)
    end
end