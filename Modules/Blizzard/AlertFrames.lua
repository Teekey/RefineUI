local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	AlertFrameMove(by Gethe)
----------------------------------------------------------------------------------------
local AchievementAnchor = CreateFrame("Frame", "AchievementAnchor", UIParent)
AchievementAnchor:SetWidth(230)
AchievementAnchor:SetHeight(50)
AchievementAnchor:SetPoint(unpack(C.position.achievement))

local alertBlacklist = {
	GroupLootContainer = true,
	TalkingHeadFrame = true
}

local POSITION, ANCHOR_POINT, YOFFSET, FIRST_YOFFSET = "BOTTOM", "TOP", -9

local function CheckGrow()
	local point = AchievementAnchor:GetPoint()

	if string.find(point, "TOP") or point == "CENTER" or point == "LEFT" or point == "RIGHT" then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = 9
		FIRST_YOFFSET = YOFFSET - 2
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = -9
		FIRST_YOFFSET = YOFFSET + 2
	end
end

local ReplaceAnchors do
	local function QueueAdjustAnchors(self, relativeAlert)
		CheckGrow()

		for alertFrame in self.alertFramePool:EnumerateActive() do
			alertFrame:ClearAllPoints()
			alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
			relativeAlert = alertFrame
		end

		return relativeAlert
	end

	local function SimpleAdjustAnchors(self, relativeAlert)
		CheckGrow()

		if self.alertFrame:IsShown() then
			self.alertFrame:ClearAllPoints()
			self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
			return self.alertFrame
		end
		return relativeAlert
	end

	local function AnchorAdjustAnchors(self, relativeAlert)
		if self.anchorFrame:IsShown() then
			return self.anchorFrame
		end
		return relativeAlert
	end

	function ReplaceAnchors(alertFrameSubSystem)
		if alertFrameSubSystem.alertFramePool then
			if alertBlacklist[alertFrameSubSystem.alertFramePool.frameTemplate] then
				return alertFrameSubSystem.alertFramePool.frameTemplate, true
			else
				alertFrameSubSystem.AdjustAnchors = QueueAdjustAnchors
			end
		elseif alertFrameSubSystem.alertFrame then
			local frame = alertFrameSubSystem.alertFrame
			if alertBlacklist[frame:GetName()] then
				return frame:GetName(), true
			else
				alertFrameSubSystem.AdjustAnchors = SimpleAdjustAnchors
			end
		elseif alertFrameSubSystem.anchorFrame then
			local frame = alertFrameSubSystem.anchorFrame
			if alertBlacklist[frame:GetName()] then
				return frame:GetName(), true
			else
				alertFrameSubSystem.AdjustAnchors = AnchorAdjustAnchors
			end
		end
	end
end

local function SetUpAlert()
    GroupLootContainer:EnableMouse(false)

    -- Create a separate anchor frame for AlertFrame
    local AlertFrameAnchor = CreateFrame("Frame", "AlertFrameAnchor", UIParent)
    AlertFrameAnchor:SetPoint(POSITION, AchievementAnchor, POSITION, 2, FIRST_YOFFSET)
    AlertFrameAnchor:SetSize(1, 1)

    hooksecurefunc(AlertFrame, "UpdateAnchors", function(self)
        CheckGrow()
        self:ClearAllPoints()
        self:SetPoint(POSITION, AlertFrameAnchor, POSITION)
    end)

    hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
        local _, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)
        if isBlacklisted then
            for i, alertSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
                if alertFrameSubSystem == alertSubSystem then
                    table.remove(AlertFrame.alertFrameSubSystems, i)
                    break
                end
            end
        end
    end)

    local remove = {}
    for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        local name, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)
        if isBlacklisted then
            remove[i] = name
        end
    end

    for i = #remove, 1, -1 do
        table.remove(AlertFrame.alertFrameSubSystems, i)
    end

    -- Force an update of the AlertFrame anchors
    AlertFrame:UpdateAnchors()
end

SetUpAlert()