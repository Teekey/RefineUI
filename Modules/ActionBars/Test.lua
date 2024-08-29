local R, C, L = unpack(RefineUI)

local function StyleNormalButton(button, size)
	if not button.isSkinned then
		local name = button:GetName()
		local icon = _G[name .. "Icon"]
		local count = _G[name .. "Count"]
		local hotkey = _G[name .. "HotKey"]
		local cooldown = _G[name .. "Cooldown"]

        button:SetTemplate("Zero")

		-- if C.actionbar.hotkey == true then
		-- 	hotkey:ClearAllPoints()
		-- 	hotkey:SetPoint("TOPRIGHT", 0, -1)
		-- 	hotkey:SetFont(C.font.action_bars_font, C.font.action_bars_font_size, C.font.action_bars_font_style)
		-- 	hotkey:SetShadowOffset(C.font.action_bars_font_shadow and 1 or 0, C.font.action_bars_font_shadow and -1 or 0)
		-- 	hotkey:SetWidth(C.actionbar.button_size - 1)
		-- 	hotkey:SetHeight(C.font.action_bars_font_size)
		-- else
		-- 	hotkey:Kill()
		-- end
		-- Create a new frame for the border cooldown effect
		local borderCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        borderCooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CD.blp")
		borderCooldown:SetDrawEdge(false)
		borderCooldown:SetDrawSwipe(true)
		borderCooldown:SetReverse(false)
		borderCooldown:SetSwipeColor(0, 0, 0, 0.5)
		borderCooldown:SetAllPoints(button)
		borderCooldown:SetFrameLevel(button:GetFrameLevel()+1)

		-- -- Set up the icon
		-- icon:SetDrawLayer("ARTWORK", 1)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)


		-- Ensure count and hotkey are on top
		count:SetParent(button)
		count:SetDrawLayer("OVERLAY", 1)
		hotkey:SetParent(button)
		hotkey:SetDrawLayer("OVERLAY", 1)

		-- Hook the SetCooldown function to update both cooldown frames
		hooksecurefunc(cooldown, "SetCooldown", function(self, start, duration)
			borderCooldown:SetCooldown(start, duration)
		end)

		button.isSkinned = true
	end
end

local function StyleButtons(buttonNames, count)
    for _, name in ipairs(buttonNames) do
        for i = 1, count do
            local button = _G[name .. i]
            if button then
                StyleNormalButton(button)
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_UPDATE_STATE" then
        if InCombatLockdown() then return end  -- Prevent changes during combat

        -- Style main action bars
        StyleButtons({
            "ActionButton",
            "MultiBarBottomLeftButton",
            "MultiBarLeftButton",
            "MultiBarRightButton",
            "MultiBarBottomRightButton",
            "MultiBar5Button",
            "MultiBar6Button",
            "MultiBar7Button"
        }, 12)

        -- Style pet action buttons
        StyleButtons({"PetActionButton"}, NUM_PET_ACTION_SLOTS)

        -- Style stance buttons
        StyleButtons({"StanceButton"}, 10)

        -- Style override action buttons
        StyleButtons({"OverrideActionBarButton"}, NUM_OVERRIDE_BUTTONS)

        -- Style extra action button
        StyleNormalButton(ExtraActionButton1)
    end
end)