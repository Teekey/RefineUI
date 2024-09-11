local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = R.oUF or ns.oUF or oUF
local UF = R.UF

-- Upvalues
local unpack = unpack


----------------------------------------------------------------------------------------
-- Party Frame Creation
----------------------------------------------------------------------------------------
local function CreatePartyFrame(self)
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

----------------------------------------------------------------------------------------
-- Target Frame Initialization
----------------------------------------------------------------------------------------
-- Register and set the target frame style
oUF:Factory(function(self)
    oUF:RegisterStyle("RefineUI_Party", CreatePartyFrame)
    oUF:SetActiveStyle("RefineUI_Party")
    local party = self:SpawnHeader("RefineUI_Party", nil, "custom [@raid6,exists] hide;show",
        "oUF-initialConfigFunction", [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute("initial-width"))
				self:SetHeight(header:GetAttribute("initial-height"))
			]],
        "initial-width", C.group.partyWidth,
        "initial-height", R.Scale(C.group.partyHealthHeight + C.group.partyPowerHeight),
        "showSolo", false,
        "showPlayer", true,
        "groupBy",  "ASSIGNEDROLE",
        "groupingOrder", "TANK,HEALER,DAMAGER,NONE",
        "sortMethod", "NAME",
        "showParty", true,
        "showRaid", true,
        "xOffset",  R.PixelPerfect(0),
        "yOffset",  R.PixelPerfect(-52),
        "point", "TOP"
    )
    party:SetPoint("CENTER", _G["RefineUI_Party"])
    _G["RefineUI_Party"]:SetSize(C.group.partyWidth, C.group.partyHealthHeight * 5 + 7 * 4)
    R.PixelSnap(party)
end)

-- Create anchors
local party = CreateFrame("Frame", "RefineUI_Party", UIParent)
party:SetPoint(unpack(C.position.unitframes.party))
R.PixelSnap(party)

-- local partyHolder = _G["RefineUI_Party"] -- Adjust this to match your party frame holder name
-- if not partyHolder then return end

local frameWidth = C.group.partyWidth
local frameHeight = C.group.partyHealthHeight + C.group.partyPowerHeight
local spacing = C.group.spacing or 5 -- Adjust spacing as needed

for i = 1, 5 do -- Assuming max 5 party members
    local frame = _G["RefineUI_Party"..i]
    if frame then
        frame:ClearAllPoints()
        if i == 1 then
            frame:SetPoint("TOPLEFT", party, "TOPLEFT", 0, 0)
        else
            local previousFrame = _G["RefineUI_Party"..(i-1)]
            frame:SetPoint("TOP", previousFrame, "BOTTOM", 0, -spacing)
        end
        
        -- Ensure pixel-perfect positioning
        R.PixelSnap(frame)
        
        -- Set size
        frame:SetSize(R.PixelPerfect(frameWidth), R.PixelPerfect(frameHeight))
    end
end



----------------------------------------------------------------------------------------
-- Expose CreateTargetFrame function
----------------------------------------------------------------------------------------
UF.CreatePartyFrame = CreatePartyFrame
