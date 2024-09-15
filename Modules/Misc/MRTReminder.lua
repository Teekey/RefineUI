local R, C, L = unpack(RefineUI)
local MRTReminder = {
    data = {},
    parsedData = {}
}
R.MRTReminder = MRTReminder

if not C.mrtreminder.enable or not C_AddOns.IsAddOnLoaded("BigWigs") then
    return
end

local BigWigsLoader = _G.BigWigsLoader

local eventFrame = CreateFrame("Frame")
local eventHandlers = {}

function MRTReminder:RegisterEvent(event, handlerName)
    eventFrame:RegisterEvent(event)
    eventHandlers[event] = function(...)
        self[handlerName](self, ...)
    end
end

function MRTReminder:UnregisterEvent(event)
    eventFrame:UnregisterEvent(event)
    eventHandlers[event] = nil
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local handler = eventHandlers[event]
    if handler then
        handler(event, ...)
    end
end)

local timerFrame = CreateFrame("Frame")
local timers = {}

function MRTReminder:ScheduleTimer(func, delay, ...)
    local args = { ... }
    local timer = {
        func = func,
        args = args,
        expires = GetTime() + delay
    }
    table.insert(timers, timer)
    return timer
end

local GetTime, UnitName, GetSpellInfo, IsInInstance, GetNumGroupMembers, InCombatLockdown = 
    GetTime, UnitName, GetSpellInfo, IsInInstance, GetNumGroupMembers, InCombatLockdown

local spellCache = {}

local function getCachedSpellInfo(spellID)
    if not spellCache[spellID] then
        spellCache[spellID] = {GetSpellInfo(spellID)}
    end
    return unpack(spellCache[spellID])
end

function MRTReminder:IsNoteEnabledAndShowing()
    if not VMRT or not VMRT.Note.enabled or not VMRT.Note.Text1 or VMRT.Note.Text1 == "" then
        return false
    end

    local inInstance, instanceType = IsInInstance()
    if not (inInstance and instanceType == "raid") then
        return false
    end

    if VMRT.Note.HideOutsideRaid and GetNumGroupMembers() == 0 then
        return false
    end

    if VMRT.Note.HideInCombat and InCombatLockdown() then
        return false
    end

    return true
end

function MRTReminder:CancelTimer(timer)
    for i, t in ipairs(timers) do
        if t == timer then
            table.remove(timers, i)
            return
        end
    end
end

function MRTReminder:CancelAllTimers()
    wipe(timers)
end

timerFrame:SetScript("OnUpdate", function(self, elapsed)
    local now = GetTime()
    for i = #timers, 1, -1 do
        local timer = timers[i]
        if now >= timer.expires then
            table.remove(timers, i)
            if type(timer.func) == "function" then
                timer.func(unpack(timer.args))
            elseif type(timer.func) == "string" and type(MRTReminder[timer.func]) == "function" then
                MRTReminder[timer.func](MRTReminder, unpack(timer.args))
            end
        end
    end
end)

function MRTReminder:OnInitialize()
    if not C.mrtreminder.enable then 
        return 
    end

    self.data = {}
    self.parsedData = {}

    self:RegisterEvent("CHAT_MSG_ADDON", "OnMRTUpdate")
    self:RegisterEvent("ENCOUNTER_START", "OnBossPulled")
    self:RegisterEvent("ENCOUNTER_END", "OnBossFightEnd")

    self:InitializeBigWigs()
end


function MRTReminder:OnMRTUpdate(event, prefix, message, channel, sender)
    if prefix == "EXRTADD" and message:sub(1, 9) == "multiline" then
        self:ParseNote()
    end
end

function MRTReminder:InitializeBigWigs()
    if BigWigsLoader then
        BigWigsLoader.RegisterMessage(self, "BigWigs_StartBar", "OnBigWigsStartBar")
        BigWigsLoader.RegisterMessage(self, "BigWigs_StopBar", "OnBigWigsStopBar")
    end
end

function MRTReminder:RegisterBigWigsMessages()
    if BigWigsLoader then
        BigWigsLoader.RegisterMessage(self, "BigWigs_StartBar", "OnBigWigsStartBar")
        BigWigsLoader.RegisterMessage(self, "BigWigs_StopBar", "OnBigWigsStopBar")
    end
end

function MRTReminder:OnBigWigsStartBar(event, module, spellId, text, duration, icon)
end

function MRTReminder:OnBigWigsStopBar(event, module, text)
end

function MRTReminder:StartBigWigsBar(time, spellID, playerName)
    if not BigWigsLoader then
        return
    end
    local spellName, _, spellTexture = getCachedSpellInfo(spellID)
    if not spellName then
        return
    end
    local text = playerName .. ": " .. spellName
    BigWigsLoader.SendMessage(self, "BigWigs_StartBar", nil, spellID, text, time, spellTexture)
end

function MRTReminder:StopBigWigsBar(spellID, playerName)
    if not BigWigsLoader then
        return
    end
    local spellName = getCachedSpellInfo(spellID)
    local text = playerName .. ": " .. spellName
    BigWigsLoader.SendMessage(self, "BigWigs_StopBar", nil, text)
end

function MRTReminder:ParseNote()
    if not self:IsNoteEnabledAndShowing() then
        return
    end

    local noteText = VMRT.Note.Text1
    local playerName = UnitName("player")

    if not noteText or noteText == "" then
        return
    end

    if not self.data then self.data = {} else table.wipe(self.data) end
    if not self.parsedData then self.parsedData = {} else table.wipe(self.parsedData) end

    for line in noteText:gmatch("[^\r\n]+") do
        local timeInfo, spellInfo, playerInfo = line:match("{time:([^}]*)}{spell:(%d+)}[^-]+-(.+)")
        if timeInfo and spellInfo and playerInfo then
            local time = self:ParseTime(timeInfo)

            for entryPlayerName, playerSpellID in playerInfo:gmatch("(%S+)%s+{spell:(%d+)}") do
                if entryPlayerName == playerName then
                    local newEntry = {
                        time = time,
                        player = {
                            name = entryPlayerName,
                            spellID = tonumber(playerSpellID)
                        }
                    }
                    table.insert(self.data, newEntry)
                    table.insert(self.parsedData, newEntry)
                end
            end
        end
    end
end

function MRTReminder:ParseTime(timeInfo)
    local minutes, seconds = timeInfo:match("(%d+):(%d+)")
    return (tonumber(minutes) * 60) + tonumber(seconds)
end

function MRTReminder:SortData()
    table.sort(self.data, function(a, b) return a.time < b.time end)
end

function MRTReminder:OnMRTUpdate(event, prefix, message, channel, sender)
    if prefix == "EXRTADD" and message:sub(1, 9) == "multiline" then
        self.noteText = VMRT.Note.Text1
    end
end

function MRTReminder:StartFightTimer()
    if not self.parsedData or #self.parsedData == 0 then
        return
    end

    self.fightStartTime = GetTime()
    self:ScheduleTimer("CheckTimedReminders", 0.1)
end

function MRTReminder:CheckTimedReminders()
    if not self:IsNoteEnabledAndShowing() then
        return
    end

    if not self.parsedData or #self.parsedData == 0 then
        return
    end

    local currentTime = GetTime() - self.fightStartTime
    local playerName = UnitName("player")
    local activeReminders = false
    
    for _, data in ipairs(self.parsedData) do
        local timeToReminder = data.time - currentTime
        
        if timeToReminder <= C.mrtreminder.autoShow and timeToReminder > 0 and not data.reminded then
            self:StartBigWigsBar(timeToReminder, data.player.spellID, data.player.name)
            self:ShowReminder(data)
            data.reminded = true
            activeReminders = true
        elseif timeToReminder <= 0 and not data.reminded then
            data.reminded = true
        end
    end
    
    if activeReminders or currentTime < self.parsedData[#self.parsedData].time then
        self:ScheduleTimer("CheckTimedReminders", 0.1)
    end
end

function MRTReminder:OnBossPulled()
    if not self:IsNoteEnabledAndShowing() then
        return
    end

    self:ParseNote()
    
    if self.parsedData and #self.parsedData > 0 then
        self:StartFightTimer()
    end
end

function MRTReminder:OnBossFightEnd()
    if IsInInstance() and select(2, IsInInstance()) == "raid" then
        self:CancelAllTimers()

        if self.parsedData then
            for _, data in ipairs(self.parsedData) do
                if not data.reminded then
                    local spellName = getCachedSpellInfo(data.player.spellID)
                    local text = data.player.name .. ": " .. spellName
                    self:StopBigWigsBar(data.player.spellID, data.player.name)
                end
            end
        end

        if self.parsedData then
            for _, data in ipairs(self.parsedData) do
                data.reminded = false
            end
        end
    end
end

function MRTReminder:ShowReminder(data)
    local spellName = getCachedSpellInfo(data.player.spellID)

    if C.mrtreminder.sound then
        PlaySoundFile(C.mrtreminder.sound, "Master")
        self:ScheduleTimer(function()
            if C.mrtreminder.speech then
                if C_VoiceChat and C_VoiceChat.SpeakText then
                    C_VoiceChat.SpeakText(1, spellName, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
                elseif TextToSpeech_Speak then
                    pcall(function() TextToSpeech_Speak(spellName, Enum.VoiceTtsDestination.LocalPlayback) end)
                end
            end
        end, 1)
    elseif C.mrtreminder.speech then
        if C_VoiceChat and C_VoiceChat.SpeakText then
            C_VoiceChat.SpeakText(1, spellName, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
        elseif TextToSpeech_Speak then
            pcall(function() TextToSpeech_Speak(spellName, Enum.VoiceTtsDestination.LocalPlayback) end)
        end
    end
end

MRTReminder:OnInitialize()
