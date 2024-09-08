local R, C, L = unpack(RefineUI)


-- local function IsFramePositionedLeft(frame)
-- 	local x = frame:GetCenter()
-- 	local screenWidth = GetScreenWidth()
-- 	local positionedLeft = false

-- 	if x and x < (screenWidth / 2) then
-- 		positionedLeft = true
-- 	end

-- 	return positionedLeft
-- end

-- ----------------------------------------------------------------------------------------
-- --	Difficulty color for quest headers
-- ----------------------------------------------------------------------------------------
-- hooksecurefunc(QuestObjectiveTracker, "Update", function()
-- 	for i = 1, C_QuestLog.GetNumQuestWatches() do
-- 		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
-- 		if not questID then
-- 			break
-- 		end
-- 		local block = QuestObjectiveTracker:GetExistingBlock(questID)
-- 		if block then
-- 			local col = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID))
-- 			block.HeaderText:SetTextColor(col.r, col.g, col.b)
-- 			block.HeaderText.col = col
-- 		end
-- 	end
-- end)

-- local function colorQuest(_, block)
-- 	C_Timer.After(0.01, function()
-- 		local poi = block.poiButton
-- 		if poi then
-- 			poi:SetScale(0.85)
-- 			poi:SetPoint("TOP")
-- 			if poi.Glow and poi.Glow:IsShown() then -- quest is selected
-- 				poi:SetAlpha(1)
-- 			else
-- 				poi:SetAlpha(0.7)
-- 			end
-- 			local style = poi:GetStyle()
-- 			if style == POIButtonUtil.Style.WorldQuest then
-- 				local questID = poi:GetQuestID()
-- 				local info = C_QuestLog.GetQuestTagInfo(questID)
-- 				if info then
-- 					local col = {r = 1, g = 1, b = 1}
-- 					if info.quality == Enum.WorldQuestQuality.Epic then
-- 						col = BAG_ITEM_QUALITY_COLORS[4]
-- 					elseif info.quality == Enum.WorldQuestQuality.Rare then
-- 						col = BAG_ITEM_QUALITY_COLORS[3]
-- 					end
-- 					block.HeaderText:SetTextColor(col.r, col.g, col.b)
-- 					block.HeaderText.col = col
-- 				end
-- 			end
-- 		end
-- 	end)
-- end

-- ----------------------------------------------------------------------------------------
-- --	Skin quest item buttons
-- ----------------------------------------------------------------------------------------
-- local function HotkeyShow(self)
-- 	local item = self:GetParent()
-- 	if item.rangeOverlay then item.rangeOverlay:Show() end
-- end

-- local function HotkeyHide(self)
-- 	local item = self:GetParent()
-- 	if item.rangeOverlay then item.rangeOverlay:Hide() end
-- end

-- local function HotkeyColor(self, r)
-- 	local item = self:GetParent()
-- 	if item.rangeOverlay then
-- 		if r == 1 then
-- 			item.rangeOverlay:Show()
-- 		else
-- 			item.rangeOverlay:Hide()
-- 		end
-- 	end
-- end

-- local function SkinQuestIcons(_, block)
-- 	local item = block and block.ItemButton

-- 	if item and not item.skinned then
-- 		item:SetSize(25, 25)
-- 		item:SetTemplate("Default")
-- 		item:StyleButton()

-- 		item:SetNormalTexture(0)

-- 		item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
-- 		item.icon:SetPoint("TOPLEFT", item, 2, -2)
-- 		item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

-- 		item.Cooldown:SetAllPoints(item.icon)

-- 		item.Count:ClearAllPoints()
-- 		item.Count:SetPoint("BOTTOMRIGHT", 0, 2)
-- 		item.Count:SetFont(unpack(C.font.actionBars))
-- 		item.Count:SetShadowOffset(1, -1)

-- 		local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
-- 		rangeOverlay:SetTexture(C.media.texture)
-- 		rangeOverlay:SetInside()
-- 		rangeOverlay:SetVertexColor(1, 0.3, 0.1, 0.6)
-- 		item.rangeOverlay = rangeOverlay

-- 		hooksecurefunc(item.HotKey, "Show", HotkeyShow)
-- 		hooksecurefunc(item.HotKey, "Hide", HotkeyHide)
-- 		hooksecurefunc(item.HotKey, "SetVertexColor", HotkeyColor)
-- 		HotkeyColor(item.HotKey, item.HotKey:GetTextColor())
-- 		item.HotKey:SetAlpha(0)

-- 		item.skinned = true
-- 	end

-- 	local finder = block and block.rightEdgeFrame
-- 	if finder and not finder.skinned then
-- 		finder:SetSize(26, 26)
-- 		finder:SetNormalTexture(0)
-- 		finder:SetHighlightTexture(0)
-- 		finder:SetPushedTexture(0)
-- 		finder.b = CreateFrame("Frame", nil, finder)
-- 		finder.b:SetTemplate("Overlay")
-- 		finder.b:SetPoint("TOPLEFT", finder, "TOPLEFT", 2, -3)
-- 		finder.b:SetPoint("BOTTOMRIGHT", finder, "BOTTOMRIGHT", -4, 3)
-- 		finder.b:SetFrameLevel(1)

-- 		finder:HookScript("OnEnter", function(self)
-- 			if self:IsEnabled() then
-- 				self.b:SetBackdropBorderColor(unpack(C.media.classBorderColor))
-- 				if self.b.overlay then
-- 					self.b.overlay:SetVertexColor(C.media.classBorderColor[1] * 0.3, C.media.classBorderColor[2] * 0.3, C.media.classBorderColor[3] * 0.3, 1)
-- 				end
-- 			end
-- 		end)

-- 		finder:HookScript("OnLeave", function(self)
-- 			self.b:SetBackdropBorderColor(unpack(C.media.borderColor))
-- 			if self.b.overlay then
-- 				self.b.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
-- 			end
-- 		end)

-- 		hooksecurefunc(finder, "Show", function(self)
-- 			self.b:SetFrameLevel(1)
-- 		end)

-- 		finder.skinned = true
-- 	end
-- end

-- -- WorldQuestsList button skin
-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("PLAYER_LOGIN")
-- frame:SetScript("OnEvent", function()
-- 	if not C_AddOns.IsAddOnLoaded("WorldQuestsList") then return end

-- 	local orig = _G.WorldQuestList.ObjectiveTracker_Update_hook
-- 	local function orig_hook(...)
-- 		orig(...)
-- 		for _, b in pairs(WorldQuestList.LFG_objectiveTrackerButtons) do
-- 			if b and not b.skinned then
-- 				b:SetSize(20, 20)
-- 				b.texture:SetAtlas("socialqueuing-icon-eye")
-- 				b.texture:SetSize(12, 12)
-- 				b:SetHighlightTexture(0)

-- 				local point, anchor, point2, x, y = b:GetPoint()
-- 				if x == -18 then
-- 					b:SetPoint(point, anchor, point2, -13, y)
-- 				end

-- 				b.b = CreateFrame("Frame", nil, b)
-- 				b.b:SetTemplate("Overlay")
-- 				b.b:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
-- 				b.b:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
-- 				b.b:SetFrameLevel(1)
-- 				b.skinned = true
-- 			end
-- 		end
-- 	end
-- 	_G.WorldQuestList.ObjectiveTracker_Update_hook = orig_hook
-- end)


-- ----------------------------------------------------------------------------------------
-- --	Skin quest objective progress bar
-- ----------------------------------------------------------------------------------------
local function SkinProgressBar(tracker, key)
	local progressBar = tracker.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar
	local label = bar and bar.Label
	local icon = bar and bar.Icon

	if not progressBar.styled then
		if bar.BarFrame then bar.BarFrame:Hide() end
		if bar.BarFrame2 then bar.BarFrame2:Hide() end
		if bar.BarFrame3 then bar.BarFrame3:Hide() end
		if bar.BarGlow then bar.BarGlow:Hide() end
		if bar.Sheen then bar.Sheen:Hide() end
		if bar.IconBG then bar.IconBG:SetAlpha(0) end
		if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
		if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
		if bar.BorderMid then bar.BorderMid:SetAlpha(0) end
		if progressBar.PlayFlareAnim then progressBar.PlayFlareAnim  = R.dummy end -- hide animation

		bar:SetSize(200, 16)
		bar:SetStatusBarTexture(C.media.texture)
		bar:CreateBackdrop("Transparent")

		label:ClearAllPoints()
		label:SetPoint("CENTER", 0, -1)
		label:SetFont(unpack(C.font.quest))
		label:SetShadowOffset(1, -1)
		label:SetDrawLayer("OVERLAY")

		if icon then
			icon:SetPoint("RIGHT", 26, 0)
			icon:SetSize(20, 20)
			icon:SetMask("")

			local border = CreateFrame("Frame", "$parentBorder", bar)
			border:SetAllPoints(icon)
			border:SetTemplate("Transparent")
			border:SetBackdropColor(0, 0, 0, 0)
			bar.newIconBg = border

			hooksecurefunc(bar.AnimIn, "Play", function()
				bar.AnimIn:Stop()
			end)
		end

		progressBar.styled = true
	end

	if bar.newIconBg then bar.newIconBg:SetShown(icon:IsShown()) end
end

-- ----------------------------------------------------------------------------------------
-- --	Skin Timer bar
-- ----------------------------------------------------------------------------------------
local function SkinTimer(tracker, key)
	local timerBar = tracker.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if not timerBar.styled then
		if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
		if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
		if bar.BorderMid then bar.BorderMid:SetAlpha(0) end

		bar:SetStatusBarTexture(C.media.texture)
		bar:CreateBackdrop("Transparent")
		timerBar.styled = true
	end
end

-- ----------------------------------------------------------------------------------------
-- --	Skin and hook all trackers
-- ----------------------------------------------------------------------------------------
local headers = {
	ScenarioObjectiveTracker,
	BonusObjectiveTracker,
	UIWidgetObjectiveTracker,
	CampaignQuestObjectiveTracker,
	QuestObjectiveTracker,
	AdventureObjectiveTracker,
	AchievementObjectiveTracker,
	MonthlyActivitiesObjectiveTracker,
	ProfessionsRecipeTracker,
	WorldQuestObjectiveTracker,
}

for i = 1, #headers do
	local header = headers[i].Header
	-- if header then
	-- 	header.Background:SetTexture(nil)
	-- end

	local tracker = headers[i]
	if tracker then
		-- hooksecurefunc(tracker, "AddBlock", SkinQuestIcons)
		hooksecurefunc(tracker, "GetProgressBar", SkinProgressBar)
		hooksecurefunc(tracker, "GetTimerBar", SkinTimer)

		hooksecurefunc(tracker, "OnBlockHeaderLeave", function(_, block)
			if block.HeaderText and block.HeaderText.col then
				block.HeaderText:SetTextColor(block.HeaderText.col.r, block.HeaderText.col.g, block.HeaderText.col.b)
			end
		end)
		-- hooksecurefunc(tracker, "AddBlock", colorQuest)
	end
end

-- ----------------------------------------------------------------------------------------
-- --	Skin Torghast ablities
-- ----------------------------------------------------------------------------------------
-- local Maw = ScenarioObjectiveTracker.MawBuffsBlock.Container
-- Maw:SkinButton()
-- Maw:SetPoint("TOPRIGHT", ScenarioObjectiveTracker.MawBuffsBlock, "TOPRIGHT", -23, 0)
-- Maw.List.button:SetSize(234, 30)
-- Maw.List:StripTextures()
-- Maw.List:SetTemplate("Overlay")

-- Maw.List:HookScript("OnShow", function(self)
-- 	self.button:SetPushedTexture(0)
-- 	self.button:SetHighlightTexture(0)
-- 	self.button:SetWidth(234)
-- 	self.button:SetButtonState("NORMAL")
-- 	self.button:SetPushedTextOffset(0, 0)
-- 	self.button:SetButtonState("PUSHED", true)
-- end)

-- Maw.List:HookScript("OnHide", function(self)
-- 	self.button:SetPushedTexture(0)
-- 	self.button:SetHighlightTexture(0)
-- 	self.button:SetWidth(234)
-- end)

-- Maw:HookScript("OnClick", function(container)
-- 	container.List:ClearAllPoints()
-- 	if IsFramePositionedLeft(ObjectiveTrackerFrame) then
-- 		container.List:SetPoint("TOPLEFT", container, "TOPRIGHT", 30, 1)
-- 	else
-- 		container.List:SetPoint("TOPRIGHT", container, "TOPLEFT", -15, 1)
-- 	end
-- end)