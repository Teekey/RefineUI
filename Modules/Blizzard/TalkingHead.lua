local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Hide TalkingHeadFrame
----------------------------------------------------------------------------------------
if C.general.hideTalkingHead == true then
	hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function()
		TalkingHeadFrame:Hide()
	end)
	return
end

------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local Load = CreateFrame("Frame")
Load:RegisterEvent("PLAYER_ENTERING_WORLD")
Load:SetScript("OnEvent", function()
	TalkingHeadFrame.ignoreFramePositionManager = true
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint(unpack(C.position.talkingHead))
	Load:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

hooksecurefunc(TalkingHeadFrame, "SetPoint", function(self, _, _, _, x)
	if x ~= C.position.talkingHead[4] then
		self:ClearAllPoints()
		self:SetPoint(unpack(C.position.talkingHead))
	end
end)