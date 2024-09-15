local R, C, L = unpack(RefineUI)

local GAS = {
    queue = {},
    hideDuration = 2,
}

local function isGuildAchievement(achievementID)
    local _, _, _, _, _, _, _, _, _, _, _, isGuild = GetAchievementInfo(achievementID)
    return isGuild
end

local function hideGuildAchievement(_, _, achievementID)
    if not isGuildAchievement(achievementID) then return end
    
    table.insert(GAS.queue, achievementID)
    return true
end

local function processQueue()
    if #GAS.queue == 0 then return end
    
    for _, achievementID in ipairs(GAS.queue) do
        AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED")
        MuteSoundFile(569143)
    end
    wipe(GAS.queue)
end

local function onAchievementEarned(self, event, achievementID)
    if hideGuildAchievement(self, event, achievementID) then
        C_Timer.After(GAS.hideDuration, processQueue)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventFrame:SetScript("OnEvent", onAchievementEarned)

hooksecurefunc(AchievementAlertSystem, "AddAlert", function(self, achievementID, alreadyEarned)
    if isGuildAchievement(achievementID) then
        return true
    end
end)