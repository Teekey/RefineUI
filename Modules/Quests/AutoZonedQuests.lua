local R, C, L = unpack(RefineUI)
if C.automation.autoZoneTrack ~= true then return end

----------------------------------------------------------------------------------------
--	Auto Track Quests by Zone (based on Zoned Quests by zestyquarks)
----------------------------------------------------------------------------------------

local questLog = C_QuestLog
local createFrame, timerAfter, addQuestWatch, removeQuestWatch, isWorldQuest, getQuestInfo, getNumQuestLogEntries, updateQuestFrame, getQuestID, inCombatLockdown, hookSecureFunc, delayFlag, questDB = CreateFrame, C_Timer.After, questLog.AddQuestWatch, questLog.RemoveQuestWatch, questLog.IsWorldQuest, questLog.GetInfo, questLog.GetNumQuestLogEntries, QuestFrameProgressItems_Update, GetQuestID, InCombatLockdown, hooksecurefunc

local hiddenQuests = {
  [24636] = true}

hookSecureFunc(questLog, "AddQuestWatch",    function(questID, _, isComplete) if questDB and not isComplete then questDB[questID]    = true end end)
hookSecureFunc(questLog, "RemoveQuestWatch", function(questID, _, isComplete) if questDB and not isComplete then questDB[questID]    = nil  end end)
hookSecureFunc(    "CompleteQuest",    function()        if questDB           then questDB[getQuestID()] = nil  end end)

local autoTrackCheckbox -- Declare the checkbox variable

local function createAutoTrackCheckbox()
  local checkbox = CreateFrame("CheckButton", "AutoTrackCheckbox", ObjectiveTrackerFrame, "ChatConfigCheckButtonTemplate")
  checkbox:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", -20, -4) -- Position it relative to the QuestFrame
  checkbox:SetChecked(C.automation.autoZoneTrack) -- Set initial state based on current setting

  checkbox:SetHitRectInsets(0, 0, 0, 0)

  -- Tooltip setup
  checkbox:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine("Enable or disable auto tracking of quests based on your current zone.")
      GameTooltip:Show()
  end)

  checkbox:SetScript("OnLeave", function()
      GameTooltip:Hide()
  end)

  checkbox:SetScript("OnClick", function(self)
      C.automation.autoZoneTrack = self:GetChecked() -- Update the setting
      if self:GetChecked() then
          print("|cFFFFD200Auto Track Quests by Zone:|r Enabled")
      else
          print("|cFFFFD200Auto Track Quests by Zone:|r Disabled")
      end
  end)

  return checkbox
end

-- Create the checkbox when the addon loads
autoTrackCheckbox = createAutoTrackCheckbox()

local function updateQuestTracking()
  if not C.automation.autoZoneTrack or inCombatLockdown() or not delayFlag then
    timerAfter(0.5, updateQuestTracking)
    delayFlag = true
    return
  end

  if not questDB then
    ZonedQuestsDB = ZonedQuestsDB or {}
    questDB       = ZonedQuestsDB
  end

  local questInfo, questFunction

  for i = 1, getNumQuestLogEntries() do
    questInfo = getQuestInfo(i)

    if questInfo and not questInfo.isHidden and not questInfo.isHeader and not isWorldQuest(questInfo.questID) then
      questFunction = (questInfo.isOnMap or hiddenQuests[questInfo.questID] or questDB[questInfo.questID]) and addQuestWatch or removeQuestWatch 
      questFunction(questInfo.questID, nil, true)
    end
  end

  updateQuestFrame() delayFlag = nil
end


local frame = createFrame("Frame")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("AREA_POIS_UPDATED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", updateQuestTracking)