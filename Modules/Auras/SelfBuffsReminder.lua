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
        local name = spell[1]
        if AuraUtil.FindAuraByName(name, "player") then
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
for i, group in ipairs(tab) do
    local frame = CreateFrame("Frame", "ReminderFrame"..i, UIParent)
    frame:SetSize(C.reminder.soloBuffsSize, C.reminder.soloBuffsSize)
    frame:SetPoint(unpack(C.position.selfBuffs))
    frame:SetTemplate("Default")
    frame:SetFrameLevel(6)
    frame.id = i

    -- Create and setup icon texture
    frame.icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.icon:CropIcon()
    frame.icon:SetAllPoints()

    -- Setup flash animation if enabled
    if C.reminder.soloBuffsFlash then
        local ag = frame:CreateAnimationGroup()
        ag:SetLooping("REPEAT")
        
        local fadeOut = ag:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.1)
        fadeOut:SetDuration(0.5)
        fadeOut:SetSmoothing("IN_OUT")
        
        local fadeIn = ag:CreateAnimation("Alpha")
        fadeIn:SetFromAlpha(0.1)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.5)
        fadeIn:SetSmoothing("IN_OUT")
        fadeIn:SetOrder(2)
        
        ag:Play()
    end

    -- Set up event handling
    frame:Hide()
    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("UNIT_AURA")
end