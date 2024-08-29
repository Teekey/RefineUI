local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Quest skin
----------------------------------------------------------------------------------------
local function LoadSkin()
	-- Skin quest reward icons
	local function SkinReward(button, mapReward)
		if button.NameFrame then button.NameFrame:Hide() end
		if button.CircleBackground then button.CircleBackground:Hide() end
		if button.CircleBackgroundGlow then button.CircleBackgroundGlow:Hide() end
		if button.ValueText then button.ValueText:SetPoint("BOTTOMRIGHT", button.Icon, 0, 0) end
		if button.IconBorder then button.IconBorder:SetAlpha(0) end
		button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button:CreateBackdrop("Icon")
		button.backdrop:ClearAllPoints()
		button.backdrop:SetPoint("TOPLEFT", button.Icon, -2, 2)
		button.backdrop:SetPoint("BOTTOMRIGHT", button.Icon, 2, -2)
		if mapReward then
			button.Icon:SetSize(26, 26)
		end
	end

	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local button = rewardsFrame.RewardButtons[index]
		if not button.backdrop then
			SkinReward(button, rewardsFrame == MapQuestInfoRewardsFrame)

			-- Add a flag to track if the button has been styled
			if not button.styled then
				button.styled = true  -- Set the flag to true

				hooksecurefunc(button.IconBorder, "SetVertexColor", function(self, r, g, b)
					if r ~= BAG_ITEM_QUALITY_COLORS[1].r ~= r and g ~= BAG_ITEM_QUALITY_COLORS[1].g then
						self:GetParent().backdrop.border:SetBackdropBorderColor(r, g, b)
					else
						self:GetParent().backdrop.border:SetBackdropBorderColor(unpack(C.media.borderColor))
					end
					self:SetTexture("")
				end)

				hooksecurefunc(button.IconBorder, "Hide", function(self)
					self:GetParent().backdrop.border:SetBackdropBorderColor(unpack(C.media.borderColor))
				end)
			end
		end
	end)
end

tinsert(R.SkinFuncs["RefineUI"], LoadSkin)