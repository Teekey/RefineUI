local R, C, L = unpack(RefineUI)

-- Cache frequently used global functions
local _G = _G
local select = select
local string = string
local unpack = unpack
local pairs = pairs
local ipairs = ipairs
local format = string.format
local gsub = string.gsub
local strfind = string.find
local match = string.match
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local IsInGuild = IsInGuild
local UnitName = UnitName
local GetNumGroupMembers = GetNumGroupMembers
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGUID = UnitGUID
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetRealmName = GetRealmName

-- Local functions for performance
local function Strip(info, name)
	return format("|Hplayer:%s|h[%s]|h", info, name:gsub("%-[^|]+", ""))
end

local origs = {}

local function AddMessage(self, text, ...)
	if type(text) == "string" then
		text = text:gsub("|h%[(%d+)%. .-%]|h", "|h[%1]|h")
		text = text:gsub("|Hplayer:(.-)|h%[(.-)%]|h", Strip)
	end
	return origs[self](self, text, ...)
end

-- Global strings
local GLOBAL_STRINGS = {
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L_CHAT_INSTANCE_CHAT .. "]|h %s:\32",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L_CHAT_INSTANCE_CHAT_LEADER .. "]|h %s:\32",
	CHAT_BN_WHISPER_GET = L_CHAT_BN_WHISPER .. " %s:\32",
	CHAT_GUILD_GET = "|Hchannel:GUILD|h[" .. L_CHAT_GUILD .. "]|h %s:\32",
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[" .. L_CHAT_OFFICER .. "]|h %s:\32",
	CHAT_PARTY_GET = "|Hchannel:PARTY|h[" .. L_CHAT_PARTY .. "]|h %s:\32",
	CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[" .. L_CHAT_PARTY_LEADER .. "]|h %s:\32",
	CHAT_PARTY_GUIDE_GET = CHAT_PARTY_LEADER_GET,
	CHAT_RAID_GET = "|Hchannel:RAID|h[" .. L_CHAT_RAID .. "]|h %s:\32",
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[" .. L_CHAT_RAID_LEADER .. "]|h %s:\32",
	CHAT_RAID_WARNING_GET = "[" .. L_CHAT_RAID_WARNING .. "] %s:\32",
	CHAT_PET_BATTLE_COMBAT_LOG_GET = "|Hchannel:PET_BATTLE_COMBAT_LOG|h[" .. L_CHAT_PET_BATTLE .. "]|h:\32",
	CHAT_PET_BATTLE_INFO_GET = "|Hchannel:PET_BATTLE_INFO|h[" .. L_CHAT_PET_BATTLE .. "]|h:\32",
	CHAT_SAY_GET = "%s:\32",
	CHAT_WHISPER_GET = L_CHAT_WHISPER .. " %s:\32",
	CHAT_YELL_GET = "%s:\32",
	CHAT_FLAG_AFK = "|cffE7E716" .. L_CHAT_AFK .. "|r ",
	CHAT_FLAG_DND = "|cffFF0000" .. L_CHAT_DND .. "|r ",
	CHAT_FLAG_GM = "|cff4154F5" .. L_CHAT_GM .. "|r ",
	ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h " .. L_CHAT_COME_ONLINE,
	ERR_FRIEND_OFFLINE_S = "[%s] " .. L_CHAT_GONE_OFFLINE
}

setmetatable(GLOBAL_STRINGS, { __index = _G })
_G = GLOBAL_STRINGS

-- Hide chat bubble menu button
ChatFrameMenuButton:Kill()

-- Kill channel and voice buttons
ChatFrameChannelButton:Kill()
ChatFrameToggleVoiceDeafenButton:Kill()
ChatFrameToggleVoiceMuteButton:Kill()

local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()
	local _, fontSize = FCF_GetChatWindowInfo(id)

	local chatFrame = _G[chat]
	local editBox = _G[chat .. "EditBox"]
	local tab = _G[format("ChatFrame%sTab", id)]

	chatFrame:SetFrameLevel(5)
	chatFrame:SetClampedToScreen(false)
	chatFrame:SetFading(false)

	editBox:ClearAllPoints()
	editBox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -10, 23)
	editBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 11, 23)
	editBox:SetFont(C.font.chat[1], fontSize, C.font.chat[3])

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%d", i)]
		frame.editBox.header:SetFont(C.font.chat[1], fontSize + 2, C.font.chat[3])
	end

	for _, textureName in ipairs(CHAT_FRAME_TEXTURES) do
		_G[chat .. textureName]:SetTexture(nil)
	end

	local elementsToKill = {
		tab.Left, tab.Middle, tab.Right,
		tab.ActiveLeft, tab.ActiveMiddle, tab.ActiveRight,
		tab.HighlightLeft, tab.HighlightMiddle, tab.HighlightRight,
		_G[format("ChatFrame%sButtonFrameMinimizeButton", id)],
		_G[format("ChatFrame%sButtonFrame", id)],
		_G[format("ChatFrame%sEditBoxLeft", id)],
		_G[format("ChatFrame%sEditBoxMid", id)],
		_G[format("ChatFrame%sEditBoxRight", id)],
		_G[format("ChatFrame%sTabGlow", id)]
	}

	for _, element in ipairs(elementsToKill) do
		element:Kill()
	end

	frame.ScrollBar:Kill()
	frame.ScrollToBottomButton:Kill()

	local a, b, c = select(6, editBox:GetRegions())
	a:Kill(); b:Kill(); c:Kill()

	if tab.conversationIcon then tab.conversationIcon:Kill() end

	editBox:SetAltArrowKeyMode(false)
	editBox:Hide()

	local function EditBoxToggle(self, gained)
		if gained or self:GetText() ~= "" then
			self:Show()
		else
			self:Hide()
		end
	end

	editBox:HookScript("OnEditFocusGained", function(self) EditBoxToggle(self, true) end)
	editBox:HookScript("OnEditFocusLost", function(self) EditBoxToggle(self, false) end)

	tab:HookScript("OnClick", function() editBox:Hide() end)

	if _G[chat] == _G["ChatFrame2"] then
		local combatLog = CombatLogQuickButtonFrame_Custom
		combatLog:StripTextures()
		combatLog:CreateBackdrop("Transparent")
		combatLog.backdrop:SetPoint("TOPLEFT", 1, -4)
		combatLog.backdrop:SetPoint("BOTTOMRIGHT", -22, 0)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetSize(12, 12)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0, 0, 0, 0)
		CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("TOPLEFT", combatLog.backdrop, 2, -2)
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMRIGHT", combatLog.backdrop, -2, 2)
		CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(C.media.texture)
		CombatLogQuickButtonFrameButton1:SetPoint("BOTTOM", 0, 0)
	end

	if _G[chat] ~= _G["ChatFrame2"] then
		origs[_G[chat]] = _G[chat].AddMessage
		_G[chat].AddMessage = AddMessage
		_G.TIMESTAMP_FORMAT_HHMM = "[%I:%M]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS = "[%I:%M:%S]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS_24HR = "[%H:%M:%S]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS_AMPM = "[%I:%M:%S %p]|r "
		_G.TIMESTAMP_FORMAT_HHMM_24HR = "[%H:%M]|r "
		_G.TIMESTAMP_FORMAT_HHMM_AMPM = "[%I:%M %p]|r "
	end

	frame.skinned = true
end

local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
	end

	-- Remember last channel
	local stickyTypes = {
		"SAY", "PARTY", "PARTY_LEADER", "GUILD", "OFFICER", "RAID",
		"RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "WHISPER",
		"BN_WHISPER", "CHANNEL"
	}
	for _, chatType in ipairs(stickyTypes) do
		ChatTypeInfo[chatType].sticky = 1
	end
end

local function SetupChatPosAndFont()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local _, fontSize = FCF_GetChatWindowInfo(id)

		fontSize = math.max(fontSize, 11)
		FCF_SetChatWindowFontSize(nil, chat, fontSize)

		chat:SetFont(C.font.chat[1], fontSize, C.font.chat[3])
		chat:SetShadowOffset(1, -1)

		if i == 1 then
			chat:ClearAllPoints()
			chat:SetSize(C.chat.width, C.chat.height)
			chat:SetPoint(unpack(C.position.chat))
			FCF_SavePositionAndDimensions(chat)
			ChatFrame1.Selection:SetAllPoints(chat)
		elseif i == 2 and C.chat.combatlog ~= true then
			FCF_DockFrame(chat)
			ChatFrame2Tab:EnableMouse(false)
			ChatFrame2Tab.Text:Hide()
			ChatFrame2Tab:SetWidth(0.001)
			ChatFrame2Tab.SetWidth = R.dummy
			FCF_DockUpdate()
		end

		chat:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
	end

	QuickJoinToastButton:ClearAllPoints()
	QuickJoinToastButton:SetPoint("TOPLEFT", 0, 90)
	QuickJoinToastButton.ClearAllPoints = R.dummy
	QuickJoinToastButton.SetPoint = R.dummy

	QuickJoinToastButton.Toast:ClearAllPoints()
	QuickJoinToastButton.Toast:SetPoint(unpack(C.position.bnPopup))
	QuickJoinToastButton.Toast.Background:SetTexture("")
	QuickJoinToastButton.Toast:SetWidth(C.chat.width + 7)
	QuickJoinToastButton.Toast.Text:SetWidth(C.chat.width - 20)

	BNToastFrame:ClearAllPoints()
	BNToastFrame:SetPoint(unpack(C.position.bnPopup))

	hooksecurefunc(BNToastFrame, "SetPoint", function(self, _, anchor)
		if anchor ~= C.position.bnPopup[2] then
			self:ClearAllPoints()
			self:SetPoint(unpack(C.position.bnPopup))
		end
	end)
end

GeneralDockManagerOverflowButton:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 5)
hooksecurefunc(GeneralDockManagerScrollFrame, "SetPoint", function(self, point, anchor, attachTo, x, y)
	if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
		self:SetPoint(point, anchor, attachTo, 0, -4)
	end
end)

local UIChat = CreateFrame("Frame")
UIChat:RegisterEvent("ADDON_LOADED")
UIChat:RegisterEvent("PLAYER_ENTERING_WORLD")
UIChat:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_CombatLog" then
		self:UnregisterEvent("ADDON_LOADED")
		SetupChat(self)
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatPosAndFont(self)
	end
end)

local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	if not frame.skinned then
		SetChatStyle(frame)
	end
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

local old = FCFManager_GetNumDedicatedFrames
function FCFManager_GetNumDedicatedFrames(...)
	return select(1, ...) ~= "PET_BATTLE_COMBAT_LOG" and old(...) or 1
end

local function RemoveRealmName(_, _, msg, author, ...)
	local realm = gsub(R.realm, " ", "")
	if msg:find("-" .. realm) then
		return false, gsub(msg, "%-" .. realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

local function TypoHistory_Posthook_AddMessage(chat, text)
	if text and strfind(text, HELP_TEXT_SIMPLE) then
		ChatEdit_AddHistory(chat.editBox)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then
		hooksecurefunc(_G["ChatFrame" .. i], "AddMessage", TypoHistory_Posthook_AddMessage)
	end
end

if C.chat.lootIcons == true then
	local function AddLootIcons(_, _, message, ...)
		local function Icon(link)
			local itemID = link:match("item:(%d+)")
			local texture = C_Item.GetItemIconByID(itemID)
			-- Increase these numbers to make the icon bigger
			local size = 16 -- Change this to your desired size
			return format("\124T%s:%d:%d:0:0:64:64:5:59:5:59\124t%s", texture, size, size, link)
		end
		message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", Icon)
		return false, message, ...
	end

	-- Add the filter to multiple chat message types
	local chatEvents = {
		"CHAT_MSG_LOOT",
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_SAY",
		"CHAT_MSG_YELL",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_PARTY",
		"CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_INSTANCE_CHAT",
		"CHAT_MSG_INSTANCE_CHAT_LEADER",
		"CHAT_MSG_GUILD",
		"CHAT_MSG_OFFICER",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_AFK",
		"CHAT_MSG_DND",
	}

	for _, event in ipairs(chatEvents) do
		ChatFrame_AddMessageEventFilter(event, AddLootIcons)
	end
end

-- Switch channels by Tab
local cycles = {
	{ chatType = "SAY",           use = function() return 1 end },
	{ chatType = "PARTY",         use = function() return not IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME) end },
	{ chatType = "RAID",          use = function() return IsInRaid(LE_PARTY_CATEGORY_HOME) end },
	{ chatType = "INSTANCE_CHAT", use = function() return IsPartyLFG() end },
	{ chatType = "GUILD",         use = function() return IsInGuild() end },
	{ chatType = "SAY",           use = function() return 1 end },
}

local function UpdateTabChannelSwitch(self)
	if strsub(tostring(self:GetText()), 1, 1) == "/" then return end
	local currChatType = self:GetAttribute("chatType")
	for i, curr in ipairs(cycles) do
		if curr.chatType == currChatType then
			local h, r, step = i + 1, #cycles, 1
			if IsShiftKeyDown() then h, r, step = i - 1, 1, -1 end
			for j = h, r, step do
				if cycles[j]:use(self, currChatType) then
					self:SetAttribute("chatType", cycles[j].chatType)
					ChatEdit_UpdateHeader(self)
					return
				end
			end
		end
	end
end
hooksecurefunc("ChatEdit_CustomTabPressed", UpdateTabChannelSwitch)

-- Role icons
local chats = {
	CHAT_MSG_SAY = true,
	CHAT_MSG_YELL = true,
	CHAT_MSG_WHISPER = true,
	CHAT_MSG_WHISPER_INFORM = true,
	CHAT_MSG_PARTY = true,
	CHAT_MSG_PARTY_LEADER = true,
	CHAT_MSG_INSTANCE_CHAT = true,
	CHAT_MSG_INSTANCE_CHAT_LEADER = true,
	CHAT_MSG_RAID = true,
	CHAT_MSG_RAID_LEADER = true,
	CHAT_MSG_RAID_WARNING = true,
}

local role_tex = {
	TANK = [[Interface\AddOns\TKUI\Media\Textures\Tank.tga]],
	HEALER = [[Interface\AddOns\TKUI\Media\Textures\Healer.tga]],
	DAMAGER = [[Interface\AddOns\TKUI\Media\Textures\Damager.tga]],
}

local playerCache = {}

local function GetPlayerClass(fullName)
	if playerCache[fullName] then
		return playerCache[fullName]
	end

	local name = fullName:match("([^-]+)")
	local class

	if name == UnitName("player") then
		_, class = UnitClass("player")
	elseif IsInGroup() then
		for i = 1, GetNumGroupMembers() do
			local rosterName, _, _, _, _, className = GetRaidRosterInfo(i)
			if rosterName == name or rosterName == fullName then
				class = className
				break
			end
		end
	end

	if not class then
		local guid = UnitGUID(name) or UnitGUID(fullName)
		if guid then
			_, class = GetPlayerInfoByGUID(guid)
		end
	end

	if class then
		playerCache[fullName] = class
	end
	return class
end

local function CreateRoleIconString(role, classColor)
	if not role or role == "NONE" or not role_tex[role] then
		return ""
	end

	return format("|T%s:16:16:0:0:16:16:0:16:0:16:%d:%d:%d|t",
		role_tex[role],
		classColor.r * 255,
		classColor.g * 255,
		classColor.b * 255
	)
end

local GetColoredName_orig = _G.GetColoredName
local function GetColoredName_hook(event, _, arg2, ...)
	if not chats[event] then
		return GetColoredName_orig(event, _, arg2, ...)
	end

	local name, realm = arg2:match("([^-]+)-?(.*)")
	local fullName = realm ~= "" and arg2 or name .. "-" .. GetRealmName()

	local role = UnitGroupRolesAssigned(name) or UnitGroupRolesAssigned(fullName)
	local class = GetPlayerClass(fullName)
	local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR

	local colorCode = format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
	local coloredName = GetColoredName_orig(event, _, arg2, ...)

	if role and role ~= "NONE" then
		local roleIcon = CreateRoleIconString(role, classColor)
		return roleIcon .. colorCode .. coloredName:gsub("^%s*", "") .. "|r"
	else
		return coloredName
	end
end
_G.GetColoredName = GetColoredName_hook

-- Return the module
return UIChat
