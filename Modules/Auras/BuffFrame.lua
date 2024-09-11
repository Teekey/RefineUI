----------------------------------------------------------------------------------------
--	Player Buff Frame for TKUI
--	This module styles and manages the player's buff frame, including layout, duration,
--	and visual elements like cooldown swipes and border colors.
--	Based on Tukz's original buff styling
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Constants and Configuration
----------------------------------------------------------------------------------------
local rowbuffs = 16
local alpha = 0

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------
local GetFormattedTime = function(s)
    if s >= 86400 then
        return format("%dd", floor(s / 86400 + 0.5))
    elseif s >= 3600 then
        return format("%dh", floor(s / 3600 + 0.5))
    elseif s >= 60 then
        return format("%dm", floor(s / 60 + 0.5))
    end
    return floor(s + 0.5)
end

----------------------------------------------------------------------------------------
--	Buff Frame Anchor
----------------------------------------------------------------------------------------
local BuffsAnchor = CreateFrame("Frame", "RefineUI_Buffs", UIParent)
BuffsAnchor:SetPoint(unpack(C.position.playerBuffs))
BuffsAnchor:SetSize((16 * C.aura.playerBuffSize) + 42, (C.aura.playerBuffSize * 2) + 3)

----------------------------------------------------------------------------------------
--	Aura Update Functions
----------------------------------------------------------------------------------------
local function FlashAura(aura, timeLeft)
    if timeLeft and timeLeft < 10 then  -- Check if the remaining time is less than 10 seconds
        local alpha = (math.sin(GetTime() * 3) + 1) / 2  -- Create a flashing effect
        alpha = alpha * 0.5 + 0.5  -- Scale to ensure alpha is between 0.5 and 1
        aura:SetAlpha(alpha)  -- Set the aura's alpha based on the sine wave
    else
        aura:SetAlpha(1)  -- Reset alpha to fully visible if more than 10 seconds or no duration
    end
end

local function UpdateDuration(aura, timeLeft)
    local duration = aura.Duration
    if timeLeft and C.aura.showTimer == true then
        duration:SetVertexColor(1, 1, 1)
        duration:SetFormattedText(GetFormattedTime(timeLeft))
        FlashAura(aura, timeLeft)  -- Call the FlashAura function
    else
        duration:Hide()
        aura:SetAlpha(1)  -- Reset alpha when duration is hidden
    end
end

local function UpdateBorderColor(aura)
    if aura.TempEnchantBorder:IsShown() then
        aura.border:SetBackdropBorderColor(0.6, 0.1, 0.6) -- Purple for temporary enchant
    elseif aura.buttonInfo and aura.buttonInfo.duration and aura.buttonInfo.duration > 0 then
        if C.aura.playerBuffClassColor == true then
            aura.border:SetBackdropBorderColor(unpack(C.media.classBorderColor)) -- Class color for buffs with duration
        else
            aura.border:SetBackdropBorderColor(0, 1, 0, 1)                       -- Green for timed buffs
        end
    else
        aura.border:SetBackdropBorderColor(unpack(C.media.borderColor)) -- Default for permanent buffs
    end
end

local function UpdateCooldownSwipe(aura)
    if aura.buttonInfo and aura.buttonInfo.duration and aura.buttonInfo.duration > 0 then
        local start = aura.buttonInfo.expirationTime - aura.buttonInfo.duration
        aura.cooldown:SetCooldown(start, aura.buttonInfo.duration)
        aura.cooldown:Show()
    else
        aura.cooldown:Hide()
    end
    UpdateBorderColor(aura)
end

----------------------------------------------------------------------------------------
--	Buff Frame Styling and Layout
----------------------------------------------------------------------------------------
hooksecurefunc(BuffFrame.AuraContainer, "UpdateGridLayout", function(self, auras)
    local previousBuff, aboveBuff
    for index, aura in ipairs(auras) do
        -- Set size and template
        aura:SetSize(C.aura.playerBuffSize, C.aura.playerBuffSize)
        aura:SetTemplate("Zero")

        aura.TempEnchantBorder:SetAlpha(0)
        -- Update the hook for the temporary enchant border
        hooksecurefunc(aura.TempEnchantBorder, "Show", function(self)
            aura.border:SetBackdropBorderColor(0.6, 0.1, 0.6) -- Set to purple when shown
        end)

        hooksecurefunc(aura.TempEnchantBorder, "Hide", function(self)
            UpdateBorderColor(aura) -- Call UpdateBorderColor to set the correct color when hidden
        end)

        -- Position auras in grid layout
        aura:ClearAllPoints()
        if (index > 1) and (mod(index, rowbuffs) == 1) then
            aura:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -6)
            aboveBuff = aura
        elseif index == 1 then
            aura:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
            aboveBuff = aura
        else
            aura:SetPoint("RIGHT", previousBuff, "LEFT", -6, 0)
        end

        previousBuff = aura

        -- Style icon
        aura.Icon:CropIcon()
        aura.border:SetFrameStrata("LOW")

        -- Create and configure cooldown swipe
        if not aura.cooldown then
            aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
            aura.cooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CDBig.blp")
            aura.cooldown:SetAllPoints(aura)
            aura.cooldown:SetDrawBling(false)
            aura.cooldown:SetDrawEdge(false)
            aura.cooldown:SetSwipeColor(0, 0, 0, 0.6)
            aura.cooldown:SetReverse(true)
            aura.cooldown:SetFrameLevel(aura:GetFrameLevel() + 1)
        end

        if not aura.iconFrame then
            aura.iconFrame = CreateFrame("Frame", nil, aura)
            aura.iconFrame:SetAllPoints(aura)
            aura.iconFrame:SetFrameLevel(aura.cooldown:GetFrameLevel() + 1)
        end

        -- Configure duration text
        local duration = aura.Duration
        if duration then -- Check if duration exists
            duration:ClearAllPoints()
            duration:SetPoint("CENTER", 0, 0)
            duration:SetParent(aura.iconFrame)
            duration:SetFont(C.media.normalFont, 18, "OUTLINE")
            duration:SetShadowOffset(1, -1)
            duration:SetDrawLayer("OVERLAY") -- Set draw layer to overlay
        end

        -- Configure stack count
        if aura.Count then
            aura.Count:ClearAllPoints()
            aura.Count:SetPoint("BOTTOMRIGHT", 0, 1)
            aura.Count:SetParent(aura.iconFrame)
            aura.Count:SetFont(C.media.normalFont, 14, "OUTLINE")
            aura.Count:SetShadowOffset(1, -1)
            aura.Count:SetDrawLayer("OVERLAY") -- Set draw layer to overlay
        end

        -- Hook duration update function
        if not aura.hook then
            hooksecurefunc(aura, "UpdateDuration", function(aura, timeLeft)
                UpdateDuration(aura, timeLeft)
            end)
            aura.hook = true
        end

        UpdateCooldownSwipe(aura)

        -- Hook Update function for cooldown swipe
        if not aura.cooldownHook then
            hooksecurefunc(aura, "Update", function(self, buttonInfo)
                self.buttonInfo = buttonInfo
                UpdateCooldownSwipe(self)
            end)
            aura.cooldownHook = true
        end

        -- Initial update of cooldown swipe and border color
        UpdateCooldownSwipe(aura)
    end
end)

BuffFrame.Selection:SetAllPoints(BuffsAnchor)
DebuffFrame:Hide()
----------------------------------------------------------------------------------------
--	Hide Default UI Elements
----------------------------------------------------------------------------------------
-- Hide collapse button
BuffFrame.CollapseAndExpandButton:Kill()

-- Hide debuffs
DebuffFrame.AuraContainer:Hide()