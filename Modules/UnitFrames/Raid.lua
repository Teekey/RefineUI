local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = R.oUF or ns.oUF or oUF
local UF = R.UF

-- Upvalues
local unpack = unpack


----------------------------------------------------------------------------------------
-- Party Frame Creation
----------------------------------------------------------------------------------------
local function CreateRaidFrame(self)
    -- Configure base unit frame
    UF.ConfigureUnitFrame(self)

    -- Create frame elements
    UF.CreateHealthBar(self)
    UF.CreatePowerBar(self)
    UF.CreateNameText(self)
    UF.CreateRaidDebuffs(self)
    UF.CreateRaidTargetIndicator(self)
    UF.CreateDebuffHighlight(self)
	UF.CreatePartyAuraWatch(self)
    UF.CreateGroupIcons(self)
    UF.ApplyGroupSettings(self)

    return self
end

local frameWidth = C.group.partyWidth
local frameHeight = C.group.partyHealthHeight + C.group.partyPowerHeight
local spacing = C.group.spacing or 5 -- Adjust spacing as needed

oUF:Factory(function(self)
	oUF:RegisterStyle("RefineUI_Raid", CreateRaidFrame)
	oUF:SetActiveStyle("RefineUI_Raid")
	local raid = {}
		local raidgroup = self:SpawnHeader("RefineUI_Raid", nil, "custom [@raid6,exists] show;hide",
			"oUF-initialConfigFunction", [[
					local header = self:GetParent()
					self:SetWidth(header:GetAttribute("initial-width"))
					self:SetHeight(header:GetAttribute("initial-height"))
				]],
			"initial-width", frameWidth - 15,
			"initial-height", R.Scale(frameHeight),
			"showRaid", false,
			-- "groupFilter", tostring(i),
			"groupBy", "ASSIGNEDROLE",
			"groupingOrder", "TANK,HEALER,DAMAGER,NONE",
			"sortMethod", "NAME",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", R.Scale(14),
			"yOffset", R.Scale(-60),
			"point", "TOP",
			"columnAnchorPoint", "RIGHT"
		)
		raidgroup:SetPoint("RIGHT", _G["RaidAnchor"])
		_G["RaidAnchor"]:SetSize(frameWidth, R.Scale(frameHeight) * 5 + R.Scale(7) * 4)
		_G["RaidAnchor"]:SetPoint(unpack(C.position.unitframes.raid))
end)

local raid = CreateFrame("Frame", "RaidAnchor", UIParent)

----------------------------------------------------------------------------------------
-- Expose CreateTargetFrame function
----------------------------------------------------------------------------------------
R.CreateRaidFrame = CreateRaidFrame