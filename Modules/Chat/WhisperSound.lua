local R, C, L = unpack(RefineUI)
if not C.chat.whisperSound then return end

----------------------------------------------------------------------------------------
-- Upvalues
----------------------------------------------------------------------------------------
local CreateFrame = CreateFrame
local PlaySoundFile = PlaySoundFile

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local WHISPER_EVENTS = {
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_BN_WHISPER"
}

----------------------------------------------------------------------------------------
-- Whisper Sound System
----------------------------------------------------------------------------------------
local function OnWhisperReceived(_, event)
    if C.media.whisperSound then
        PlaySoundFile(C.media.whisperSound, "Master")
    end
end

local WhisperSoundSystem = CreateFrame("Frame")

for _, event in ipairs(WHISPER_EVENTS) do
    WhisperSoundSystem:RegisterEvent(event)
end

WhisperSoundSystem:SetScript("OnEvent", OnWhisperReceived)