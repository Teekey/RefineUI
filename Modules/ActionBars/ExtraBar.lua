local R, C, L = unpack(RefineUI)

for i = 1, 3 do
    if _G["ExtraActionButton" .. i] then
        _G["ExtraActionButton" .. i]:SetScale(1.25)
    end
end

_G["ZoneAbilityFrame"]:SetScale(1.25)


-- -- Upvalue globals for efficiency
-- local CreateFrame, RegisterStateDriver, hooksecurefunc = CreateFrame, RegisterStateDriver, hooksecurefunc
-- local C_Timer, HasExtraActionBar = C_Timer, HasExtraActionBar
-- local UIParent, ExtraActionBarFrame, ZoneAbilityFrame = UIParent, ExtraActionBarFrame, ZoneAbilityFrame

-- ----------------------------------------------------------------------------------------
-- -- Constants
-- ----------------------------------------------------------------------------------------
-- local SIZE = 48 -- Adjust this multiplier as needed
-- local SPACING = 8 -- Adjust this value to change the space between buttons

-- ----------------------------------------------------------------------------------------
-- -- Extra Action Button Setup
-- ----------------------------------------------------------------------------------------
-- local function SetupExtraActionButton()
--     local anchor = CreateFrame("Frame", "ExtraButtonAnchor", UIParent)
--     anchor:SetPoint(unpack(C.position.extraButton))
--     R.PixelSnap(anchor)
--     anchor:SetSize(SIZE, SIZE)
--     anchor:SetFrameStrata("LOW")
--     RegisterStateDriver(anchor, "visibility", "[petbattle] hide; show")

--     ExtraActionBarFrame:SetParent(anchor)
--     ExtraActionBarFrame:ClearAllPoints()
--     ExtraActionBarFrame:SetAllPoints()

--     -- Prevent reanchor
--     ExtraAbilityContainer.ignoreFramePositionManager = true
--     hooksecurefunc(ExtraActionBarFrame, "SetParent", function(self, parent)
--         if parent == ExtraAbilityContainer then
--             self:SetParent(anchor)
--         end
--     end)

--     return anchor
-- end

-- ----------------------------------------------------------------------------------------
-- -- Zone Ability Button Setup
-- ----------------------------------------------------------------------------------------
-- local function SetupZoneAbilityButton(anchor)
--     local zoneAnchor = CreateFrame("Frame", "ZoneButtonAnchor", UIParent)
--     zoneAnchor:SetPoint(unpack(C.position.zoneButton))
--     zoneAnchor:SetSize(SIZE * 3 + SPACING * 2, SIZE) -- Adjust for maximum expected buttons
--     zoneAnchor:SetFrameStrata("LOW")
--     RegisterStateDriver(zoneAnchor, "visibility", "[petbattle] hide; show")

--     ZoneAbilityFrame:SetParent(zoneAnchor)
--     ZoneAbilityFrame:ClearAllPoints()
--     ZoneAbilityFrame:SetAllPoints()
--     ZoneAbilityFrame.ignoreInLayout = true

--     hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
--         if parent == ExtraAbilityContainer then
--             self:SetParent(zoneAnchor)
--         end
--     end)

--     C_Timer.After(0.1, function()
--         ZoneAbilityFrame.SpellButtonContainer:SetSize(SIZE, SIZE)
--     end)

--     hooksecurefunc("ExtraActionBar_Update", function()
--         if HasExtraActionBar() then
--             zoneAnchor:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -3, 0)
--         else
--             zoneAnchor:SetPoint(unpack(C.position.zoneButton))
--         end
--     end)

--     return zoneAnchor
-- end

-- ----------------------------------------------------------------------------------------
-- -- Skin ExtraActionBarFrame
-- ----------------------------------------------------------------------------------------
-- local function SkinExtraActionButton()
--     local button = ExtraActionButton1
--     local texture = button.style
--     local function disableTexture(style, texture)
--         if texture then
--             style:SetTexture(nil)
--         end
--     end
--     button.style:SetTexture(nil)
--     hooksecurefunc(texture, "SetTexture", disableTexture)

--     button:SetSize(SIZE, SIZE)

--     button.Count:SetFont(C.font.cooldown_timers_font, C.font.cooldown_timers_font_size, C.font.cooldown_timers_font_style)
--     button.Count:SetShadowOffset(C.font.cooldown_timers_font_shadow and 1 or 0,
--         C.font.cooldown_timers_font_shadow and -1 or 0)
--     button.Count:SetPoint("BOTTOMRIGHT", 0, 1)
--     button.Count:SetJustifyH("RIGHT")

--     button:SetAttribute("showgrid", 1)
-- end

-- ----------------------------------------------------------------------------------------
-- -- Skin ZoneAbilityFrame
-- ----------------------------------------------------------------------------------------
-- local function SkinZoneAbilities()
--     C_Timer.After(0.01, function() -- Add a small delay
--         local buttons = {}
--         local buttonCount = 0

--         for button in ZoneAbilityFrame.SpellButtonContainer:EnumerateActive() do
--             buttonCount = buttonCount + 1
--             buttons[buttonCount] = button

--             if not button.IsSkinned then
--                 button.NormalTexture:SetAlpha(0)

--                 button:StyleButton()

--                 button:SetSize(SIZE, SIZE)
--                 button:SetTemplate("Transparent")
--                 if C.actionbars.classcolor_border == true then
--                     button:SetBackdropBorderColor(unpack(C.media.classBorderColor))
--                 end

--                 button.Icon:CropIcon()
--                 button.Icon:SetPoint("TOPLEFT", button, 2, -2)
--                 button.Icon:SetPoint("BOTTOMRIGHT", button, -2, 2)
--                 button.Icon:SetDrawLayer("BACKGROUND", 7)

--                 button.Count:SetFont(C.font.cooldown_timers_font, C.font.cooldown_timers_font_size,
--                     C.font.cooldown_timers_font_style)
--                 button.Count:SetShadowOffset(C.font.cooldown_timers_font_shadow and 1 or 0,
--                     C.font.cooldown_timers_font_shadow and -1 or 0)
--                 button.Count:SetPoint("BOTTOMRIGHT", 0, 1)
--                 button.Count:SetJustifyH("RIGHT")

--                 button.Cooldown:SetAllPoints(button.Icon)

--                 if button.Flash then
--                     button.Flash:SetColorTexture(1, 1, 1, 0.8)
--                     button.Flash:SetAllPoints(button)
--                     button.Flash:SetBlendMode("ADD")
--                     button.Flash:SetDrawLayer("OVERLAY", 1)
--                 end

--                 button.IsSkinned = true
--             end
--         end

--         -- Calculate total width
--         local totalWidth = buttonCount * SIZE + (buttonCount - 1) * SPACING

--         -- Resize the container to fit all buttons
--         ZoneAbilityFrame.SpellButtonContainer:SetSize(totalWidth, SIZE)

--         -- Position buttons
--         if buttonCount == 1 then
--             buttons[1]:ClearAllPoints()
--             buttons[1]:SetPoint("CENTER", ZoneAbilityFrame.SpellButtonContainer, "CENTER")
--         elseif buttonCount == 2 then
--             buttons[1]:ClearAllPoints()
--             buttons[1]:SetPoint("LEFT", ZoneAbilityFrame.SpellButtonContainer, "LEFT", 0, 0)
--             buttons[2]:ClearAllPoints()
--             buttons[2]:SetPoint("RIGHT", ZoneAbilityFrame.SpellButtonContainer, "RIGHT", 0, 0)
--         else
--             for i, button in ipairs(buttons) do
--                 button:ClearAllPoints()
--                 if i == 1 then
--                     button:SetPoint("LEFT", ZoneAbilityFrame.SpellButtonContainer, "LEFT", 0, 0)
--                 else
--                     button:SetPoint("LEFT", buttons[i - 1], "RIGHT", SPACING, 0)
--                 end
--             end
--         end

--         -- Center the SpellButtonContainer within the ZoneAbilityFrame
--         ZoneAbilityFrame.SpellButtonContainer:ClearAllPoints()
--         ZoneAbilityFrame.SpellButtonContainer:SetPoint("CENTER", ZoneAbilityFrame, "CENTER")

--         -- Resize ZoneAbilityFrame to match the SpellButtonContainer
--         ZoneAbilityFrame:SetSize(totalWidth, SIZE)

--         -- Update zoneAnchor size
--         ZoneButtonAnchor:SetSize(totalWidth, SIZE)
--     end)
-- end

-- ----------------------------------------------------------------------------------------
-- -- Initialization
-- ----------------------------------------------------------------------------------------
-- local function InitializeExtraBar()
--     local anchor = SetupExtraActionButton()
--     local zoneAnchor = SetupZoneAbilityButton(anchor)
--     SkinExtraActionButton()

--     -- Hooks for ZoneAbilityFrame
--     hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", SkinZoneAbilities)
--     ZoneAbilityFrame:HookScript("OnShow", SkinZoneAbilities)
--     ZoneAbilityFrame.SpellButtonContainer:HookScript("OnSizeChanged", SkinZoneAbilities)
--     ZoneAbilityFrame.Style:SetAlpha(0)

--     -- Initial setup
--     C_Timer.After(0.1, SkinZoneAbilities)

--     -- Update positioning when ExtraActionBar changes
--     hooksecurefunc("ExtraActionBar_Update", function()
--         C_Timer.After(0.01, function()
--             if HasExtraActionBar() then
--                 zoneAnchor:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -3, 0)
--             else
--                 zoneAnchor:SetPoint(unpack(C.position.zoneButton))
--             end
--             SkinZoneAbilities()
--         end)
--     end)
-- end

-- InitializeExtraBar()
