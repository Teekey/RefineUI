-- local R, C, L = unpack(RefineUI)

-- ----------------------------------------------------------------------------------------
-- -- Upvalues
-- ----------------------------------------------------------------------------------------
-- local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
-- local IsResting = IsResting
-- local Ambiguate = Ambiguate
-- local UnitIsInMyGuild = UnitIsInMyGuild
-- local pairs = pairs
-- local strlower = string.lower
-- local strmatch = string.match

-- ----------------------------------------------------------------------------------------
-- -- Local variables
-- ----------------------------------------------------------------------------------------
-- local playerName = UnitName("player")

-- ----------------------------------------------------------------------------------------
-- -- System spam filter
-- ----------------------------------------------------------------------------------------
-- if C.chat.filter then
--     local function filterIfResting() return IsResting() end
--     local function alwaysFilter() return true end

--     -- Filter out specific chat messages
--     local filterEvents = {
--         CHAT_MSG_MONSTER_SAY = filterIfResting,
--         CHAT_MSG_MONSTER_YELL = filterIfResting,
--         CHAT_MSG_CHANNEL_JOIN = alwaysFilter,
--         CHAT_MSG_CHANNEL_LEAVE = alwaysFilter,
--         CHAT_MSG_CHANNEL_NOTICE = alwaysFilter,
--         CHAT_MSG_AFK = alwaysFilter,
--         CHAT_MSG_DND = alwaysFilter,
--     }

--     for event, filterFunc in pairs(filterEvents) do
--         ChatFrame_AddMessageEventFilter(event, filterFunc)
--     end

--     -- Clear specific system messages
--     local clearMessages = {
--         "DUEL_WINNER_KNOCKOUT", "DUEL_WINNER_RETREAT",
--         "DRUNK_MESSAGE_ITEM_OTHER1", "DRUNK_MESSAGE_ITEM_OTHER2", "DRUNK_MESSAGE_ITEM_OTHER3", "DRUNK_MESSAGE_ITEM_OTHER4",
--         "DRUNK_MESSAGE_OTHER1", "DRUNK_MESSAGE_OTHER2", "DRUNK_MESSAGE_OTHER3", "DRUNK_MESSAGE_OTHER4",
--         "DRUNK_MESSAGE_ITEM_SELF1", "DRUNK_MESSAGE_ITEM_SELF2", "DRUNK_MESSAGE_ITEM_SELF3", "DRUNK_MESSAGE_ITEM_SELF4",
--         "DRUNK_MESSAGE_SELF1", "DRUNK_MESSAGE_SELF2", "DRUNK_MESSAGE_SELF3", "DRUNK_MESSAGE_SELF4",
--         "ERR_PET_LEARN_ABILITY_S", "ERR_PET_LEARN_SPELL_S", "ERR_PET_SPELL_UNLEARNED_S",
--         "ERR_LEARN_ABILITY_S", "ERR_LEARN_SPELL_S", "ERR_LEARN_PASSIVE_S", "ERR_SPELL_UNLEARNED_S"
--     }

--     for _, msg in ipairs(clearMessages) do
--         _G[msg] = ""
--     end

--     -- Prevent empty lines in system messages
--     local function systemFilter(_, _, text)
--         return text and text == ""
--     end

--     ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter)
-- end

-- ----------------------------------------------------------------------------------------
-- -- Players spam filter
-- ----------------------------------------------------------------------------------------
-- if C.chat.spam then
--     -- Repeat spam filter
--     local function repeatMessageFilter(self, _, text, sender)
--         sender = Ambiguate(sender, "guild")
--         if sender == playerName or UnitIsInMyGuild(sender) then return end

--         if not self.repeatMessages or self.repeatCount > 20 then
--             self.repeatCount = 0
--             self.repeatMessages = {}
--         end

--         local lastMessage = self.repeatMessages[sender]
--         if lastMessage == text then
--             return true
--         end

--         self.repeatMessages[sender] = text
--         self.repeatCount = self.repeatCount + 1
--     end

--     -- Gold/portals spam filter
--     local function tradeFilter(_, _, text, sender)
--         sender = Ambiguate(sender, "guild")
--         if sender == playerName or UnitIsInMyGuild(sender) then return end

--         local lowerText = strlower(text)
--         for _, value in pairs(R.ChatSpamList) do
--             if strmatch(lowerText, value) then
--                 return true
--             end
--         end
--     end

--     -- Apply filters to specific chat types
--     for _, chatType in ipairs({"CHAT_MSG_CHANNEL", "CHAT_MSG_YELL"}) do
--         ChatFrame_AddMessageEventFilter(chatType, repeatMessageFilter)
--         ChatFrame_AddMessageEventFilter(chatType, tradeFilter)
--     end
-- end