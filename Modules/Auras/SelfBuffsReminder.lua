local R, C, L = unpack(RefineUI)
if not C.reminder.soloBuffsEnable then return end

local tab = R.ReminderSelfBuffs[R.class]
if not tab then return end

----------------------------------------------------------------------------------------
-- Upvalues
----------------------------------------------------------------------------------------
local CreateFrame, PlaySoundFile, unpack = CreateFrame, PlaySoundFile, unpack
local AuraUtil, C_Spell = AuraUtil, C_Spell
local ipairs, type = ipairs, type

----------------------------------------------------------------------------------------
-- Helper Functions
----------------------------------------------------------------------------------------
local function UpdateIcon(self, group)
    for _, spellData in ipairs(group.spells) do
        local name, icon, spellID = unpack(spellData)
        if spellID and type(spellID) == "number" then
            icon = C_Spell.GetSpellTexture(spellID) or icon
            if icon then
                self.icon:SetTexture(icon)
                return
            end
        end
    end
    self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
end

local function CheckBuffs(self, group)
    local buffMissing = true
    for _, spell in ipairs(group.spells) do
        local name, _, spellID = unpack(spell)
        if group.mainhand or group.offhand then
            -- Check for weapon enchants
            local enchantID = GetWeaponEnchantInfo()
            if (group.mainhand and enchantID) or (group.offhand and select(5, GetWeaponEnchantInfo())) then
                buffMissing = false
                break
            end
        elseif AuraUtil.FindAuraByName(name, "player") then
            buffMissing = false
            break
        end
    end

    if buffMissing then
        self:Show()
        if C.reminder.solo_buffs_sound then
            PlaySoundFile(C.media.warningSound, "Master")
        end
    else
        self:Hide()
    end
end

----------------------------------------------------------------------------------------
-- Event Handler
----------------------------------------------------------------------------------------
local function OnEvent(self, event, arg1)
    if (event == "UNIT_AURA" or event == "PLAYER_ENTERING_WORLD") and arg1 ~= "player" then return end
    
    local group = tab[self.id]
    if not group or not group.spells then return end

    UpdateIcon(self, group)
    CheckBuffs(self, group)
end

----------------------------------------------------------------------------------------
-- Frame Creation and Setup
----------------------------------------------------------------------------------------
-- Create the primary frame
local primaryFrame = CreateFrame("Frame", "RefineUI_SelfBuffsReminder", UIParent)
primaryFrame:SetPoint(unpack(C.position.selfBuffs))
primaryFrame:SetFrameLevel(5)

-- Calculate total width based on number of buffs and their size
local totalWidth = #tab * C.reminder.soloBuffsSize + (#tab - 1) * 5  -- 5 pixel spacing between icons
primaryFrame:SetSize(totalWidth, C.reminder.soloBuffsSize)

-- Create individual buff frames
for i, group in ipairs(tab) do
    local frame = CreateFrame("Frame", "ReminderFrame"..i, primaryFrame)
    frame:SetSize(C.reminder.soloBuffsSize, C.reminder.soloBuffsSize)
    frame:SetPoint("LEFT", primaryFrame, "LEFT", (i-1) * (C.reminder.soloBuffsSize + 5), 0)
    frame:SetTemplate("Default")
    frame:SetFrameLevel(6)
    frame.id = i

    -- Create and setup icon texture
    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:CropIcon()
    frame.icon:SetAllPoints()

    -- Setup flash animation if enabled
    if C.reminder.soloBuffsFlash then
        local frameAG = frame:CreateAnimationGroup()
        local iconAG = frame.icon:CreateAnimationGroup()
        frameAG:SetLooping("REPEAT")
        iconAG:SetLooping("REPEAT")
        
        local frameFadeOut = frameAG:CreateAnimation("Alpha")
        local iconFadeOut = iconAG:CreateAnimation("Alpha")
        frameFadeOut:SetFromAlpha(1)
        frameFadeOut:SetToAlpha(0.1)
        frameFadeOut:SetDuration(0.5)
        frameFadeOut:SetSmoothing("IN_OUT")
        iconFadeOut:SetFromAlpha(1)
        iconFadeOut:SetToAlpha(0.1)
        iconFadeOut:SetDuration(0.5)
        iconFadeOut:SetSmoothing("IN_OUT")
        
        local frameFadeIn = frameAG:CreateAnimation("Alpha")
        local iconFadeIn = iconAG:CreateAnimation("Alpha")
        frameFadeIn:SetFromAlpha(0.1)
        frameFadeIn:SetToAlpha(1)
        frameFadeIn:SetDuration(0.5)
        frameFadeIn:SetSmoothing("IN_OUT")
        frameFadeIn:SetOrder(2)
        iconFadeIn:SetFromAlpha(0.1)
        iconFadeIn:SetToAlpha(1)
        iconFadeIn:SetDuration(0.5)
        iconFadeIn:SetSmoothing("IN_OUT")
        iconFadeIn:SetOrder(2)
        
        frameAG:Play()
        iconAG:Play()
    end

    -- Set up event handling
    frame:Hide()
    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_AURA")
end

-- Center the primary frame
primaryFrame:ClearAllPoints()
primaryFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)