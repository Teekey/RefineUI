local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Style chat frame(by Tukz and p3lim)
----------------------------------------------------------------------------------------
local origs = {}

local function Strip(info, name)
	return string.format("|Hplayer:%s|h[%s]|h", info, name:gsub("%-[^|]+", ""))
end

-- Function to rename channel and other stuff
local AddMessage = function(self, text, ...)
	if type(text) == "string" then
		text = text:gsub("|h%[(%d+)%. .-%]|h", "|h[%1]|h")
		text = text:gsub("|Hplayer:(.-)|h%[(.-)%]|h", Strip)
	end
	return origs[self](self, text, ...)
end

-- Global strings
_G.CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L_CHAT_INSTANCE_CHAT .. "]|h %s:\32"
_G.CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L_CHAT_INSTANCE_CHAT_LEADER .. "]|h %s:\32"
_G.CHAT_BN_WHISPER_GET = L_CHAT_BN_WHISPER .. " %s:\32"
_G.CHAT_GUILD_GET = "|Hchannel:GUILD|h[" .. L_CHAT_GUILD .. "]|h %s:\32"
_G.CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[" .. L_CHAT_OFFICER .. "]|h %s:\32"
_G.CHAT_PARTY_GET = "|Hchannel:PARTY|h[" .. L_CHAT_PARTY .. "]|h %s:\32"
_G.CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[" .. L_CHAT_PARTY_LEADER .. "]|h %s:\32"
_G.CHAT_PARTY_GUIDE_GET = CHAT_PARTY_LEADER_GET
_G.CHAT_RAID_GET = "|Hchannel:RAID|h[" .. L_CHAT_RAID .. "]|h %s:\32"
_G.CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[" .. L_CHAT_RAID_LEADER .. "]|h %s:\32"
_G.CHAT_RAID_WARNING_GET = "[" .. L_CHAT_RAID_WARNING .. "] %s:\32"
_G.CHAT_PET_BATTLE_COMBAT_LOG_GET = "|Hchannel:PET_BATTLE_COMBAT_LOG|h[" .. L_CHAT_PET_BATTLE .. "]|h:\32"
_G.CHAT_PET_BATTLE_INFO_GET = "|Hchannel:PET_BATTLE_INFO|h[" .. L_CHAT_PET_BATTLE .. "]|h:\32"
_G.CHAT_SAY_GET = "%s:\32"
_G.CHAT_WHISPER_GET = L_CHAT_WHISPER .. " %s:\32"
_G.CHAT_YELL_GET = "%s:\32"
_G.CHAT_FLAG_AFK = "|cffE7E716" .. L_CHAT_AFK .. "|r "
_G.CHAT_FLAG_DND = "|cffFF0000" .. L_CHAT_DND .. "|r "
_G.CHAT_FLAG_GM = "|cff4154F5" .. L_CHAT_GM .. "|r "
_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h " .. L_CHAT_COME_ONLINE
_G.ERR_FRIEND_OFFLINE_S = "[%s] " .. L_CHAT_GONE_OFFLINE

-- Hide chat bubble menu button
ChatFrameMenuButton:Kill()

-- Kill channel and voice buttons
ChatFrameChannelButton:Kill()
ChatFrameToggleVoiceDeafenButton:Kill()
ChatFrameToggleVoiceMuteButton:Kill()

-- Set chat style
local function SetChatStyle(frame)
	local id = frame:GetID()
	local chat = frame:GetName()
	local _, fontSize = FCF_GetChatWindowInfo(id)

	_G[chat]:SetFrameLevel(5)

	-- Removes crap from the bottom of the chatbox so it can go to the bottom of the screen
	_G[chat]:SetClampedToScreen(false)

	-- Stop the chat chat from fading out
	_G[chat]:SetFading(false)

	-- Move the chat edit box
	_G[chat .. "EditBox"]:ClearAllPoints()
	_G[chat .. "EditBox"]:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -10, 23)
	_G[chat .. "EditBox"]:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 11, 23)
	_G[chat .. "EditBox"]:SetFont(C.font.chat_font, fontSize, C.font.chat_font_style)
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[("ChatFrame%d"):format(i)]
		frame.editBox.header:SetFont(C.font.chat_font, fontSize + 2, C.font.chat_font_style)
	end
	-- Hide textures
	for j = 1, #CHAT_FRAME_TEXTURES do
		_G[chat .. CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
	end

	-- Removes Default ChatFrame Tabs texture
	_G[format("ChatFrame%sTab", id)].Left:Kill()
	_G[format("ChatFrame%sTab", id)].Middle:Kill()
	_G[format("ChatFrame%sTab", id)].Right:Kill()

	_G[format("ChatFrame%sTab", id)].ActiveLeft:Kill()
	_G[format("ChatFrame%sTab", id)].ActiveMiddle:Kill()
	_G[format("ChatFrame%sTab", id)].ActiveRight:Kill()

	_G[format("ChatFrame%sTab", id)].HighlightLeft:Kill()
	_G[format("ChatFrame%sTab", id)].HighlightMiddle:Kill()
	_G[format("ChatFrame%sTab", id)].HighlightRight:Kill()

	-- Killing off the new chat tab selected feature
	_G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrame", id)]:Kill()

	-- Kills off the retarded new circle around the editbox
	_G[format("ChatFrame%sEditBoxLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxRight", id)]:Kill()

	_G[format("ChatFrame%sTabGlow", id)]:Kill()

	-- Kill scroll bar
	frame.ScrollBar:Kill()
	frame.ScrollToBottomButton:Kill()

	-- Kill off editbox artwork
	local a, b, c = select(6, _G[chat .. "EditBox"]:GetRegions())
	a:Kill()
	b:Kill()
	c:Kill()

	-- Kill bubble tex/glow
	if _G[chat .. "Tab"].conversationIcon then _G[chat .. "Tab"].conversationIcon:Kill() end

	-- Disable alt key usage
	_G[chat .. "EditBox"]:SetAltArrowKeyMode(false)

	-- Hide editbox on login
	_G[chat .. "EditBox"]:Hide()

	-- Script to hide editbox instead of fading editbox to 0.35 alpha via IM Style
	_G[chat .. "EditBox"]:HookScript("OnEditFocusGained", function(self) self:Show() end)
	_G[chat .. "EditBox"]:HookScript("OnEditFocusLost", function(self) if self:GetText() == "" then self:Hide() end end)

	-- Hide edit box every time we click on a tab
	_G[chat .. "Tab"]:HookScript("OnClick", function() _G[chat .. "EditBox"]:Hide() end)

	-- Rename combat log tab
	if _G[chat] == _G["ChatFrame2"] then
		CombatLogQuickButtonFrame_Custom:StripTextures()
		CombatLogQuickButtonFrame_Custom:CreateBackdrop("Transparent")
		CombatLogQuickButtonFrame_Custom.backdrop:SetPoint("TOPLEFT", 1, -4)
		CombatLogQuickButtonFrame_Custom.backdrop:SetPoint("BOTTOMRIGHT", -22, 0)
		-- R.SkinCloseButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton,
		-- 	CombatLogQuickButtonFrame_Custom.backdrop, " ", true)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetSize(12, 12)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0, 0, 0, 0)
		CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("TOPLEFT", CombatLogQuickButtonFrame_Custom.backdrop, 2, -2)
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMRIGHT", CombatLogQuickButtonFrame_Custom.backdrop, -2,
			2)
		CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(C.media.texture)
		CombatLogQuickButtonFrameButton1:SetPoint("BOTTOM", 0, 0)
	end

	if _G[chat] ~= _G["ChatFrame2"] then
		origs[_G[chat]] = _G[chat].AddMessage
		_G[chat].AddMessage = AddMessage
		-- Custom timestamps color
		_G.TIMESTAMP_FORMAT_HHMM = "[%I:%M]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS = "[%I:%M:%S]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS_24HR = "[%H:%M:%S]|r "
		_G.TIMESTAMP_FORMAT_HHMMSS_AMPM = "[%I:%M:%S %p]|r "
		_G.TIMESTAMP_FORMAT_HHMM_24HR = "[%H:%M]|r "
		_G.TIMESTAMP_FORMAT_HHMM_AMPM = "[%I:%M %p]|r "
	end

	frame.skinned = true
end

-- Setup chatframes 1 to 10 on login
local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
	end

	-- Remember last channel
	ChatTypeInfo.SAY.sticky = 1
	ChatTypeInfo.PARTY.sticky = 1
	ChatTypeInfo.PARTY_LEADER.sticky = 1
	ChatTypeInfo.GUILD.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT_LEADER.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
end

local function SetupChatPosAndFont()
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local _, fontSize = FCF_GetChatWindowInfo(id)

		-- Min. size for chat font
		if fontSize < 11 then
			FCF_SetChatWindowFontSize(nil, chat, 11)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end

		-- Font and font style for chat
		chat:SetFont(C.font.chat_font, fontSize, C.font.chat_font_style)
		chat:SetShadowOffset(C.font.chat_font_shadow and 1 or 0, C.font.chat_font_shadow and -1 or 0)

		-- Force chat position
		if i == 1 then
			chat:ClearAllPoints()
			chat:SetSize(C.chat.width, C.chat.height)
			chat:SetPoint(C.position.chat[1], C.position.chat[2], C.position.chat[3], C.position.chat[4],
				C.position.chat[5])
			FCF_SavePositionAndDimensions(chat)
		elseif i == 2 then
			if C.chat.combatlog ~= true then
				FCF_DockFrame(chat)
				ChatFrame2Tab:EnableMouse(false)
				ChatFrame2Tab.Text:Hide()
				ChatFrame2Tab:SetWidth(0.001)
				ChatFrame2Tab.SetWidth = R.dummy
				FCF_DockUpdate()
			end
		end

		chat:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
	end

	-- Reposition Quick Join Toast
	QuickJoinToastButton:ClearAllPoints()
	QuickJoinToastButton:SetPoint("TOPLEFT", 0, 90)
	QuickJoinToastButton.ClearAllPoints = R.dummy
	QuickJoinToastButton.SetPoint = R.dummy

	QuickJoinToastButton.Toast:ClearAllPoints()
	QuickJoinToastButton.Toast:SetPoint(unpack(C.position.bnPopup))
	QuickJoinToastButton.Toast.Background:SetTexture("")
	QuickJoinToastButton.Toast:CreateBackdrop("Transparent")
	QuickJoinToastButton.Toast.backdrop:SetPoint("TOPLEFT", 0, 0)
	QuickJoinToastButton.Toast.backdrop:SetPoint("BOTTOMRIGHT", 0, 0)
	QuickJoinToastButton.Toast.backdrop:Hide()
	QuickJoinToastButton.Toast:SetWidth(C.chat.width + 7)
	QuickJoinToastButton.Toast.Text:SetWidth(C.chat.width - 20)

	hooksecurefunc(QuickJoinToastButton, "ShowToast", function() QuickJoinToastButton.Toast.backdrop:Show() end)
	hooksecurefunc(QuickJoinToastButton, "HideToast", function() QuickJoinToastButton.Toast.backdrop:Hide() end)

	-- Reposition Battle.net popup
	BNToastFrame:ClearAllPoints()
	BNToastFrame:SetPoint(unpack(C.position.bnPopup))

	hooksecurefunc(BNToastFrame, "SetPoint", function(self, _, anchor) -- not sure if it still needed
		if anchor ~= C.position.bnPopup[2] then
			self:ClearAllPoints()
			self:SetPoint(unpack(C.position.bnPopup))
		end
	end)

	-- -- /run BNToastFrame:AddToast(BN_TOAST_TYPE_ONLINE, 1)
	-- hooksecurefunc(BNToastFrame, "ShowToast", function(self)
	-- 	if not self.IsSkinned then
	-- 		R.SkinCloseButton(self.CloseButton, nil, "x")
	-- 		self.CloseButton:SetSize(16, 16)
	-- 		self.IsSkinned = true
	-- 	end
	-- end)
end

-- Reposition 3 chat frame tab if it don't fit to 1
-- for i = 3, NUM_CHAT_WINDOWS do
-- local tab = _G[format("ChatFrame%sTab", i)]
-- hooksecurefunc(tab, "SetPoint", function(self, point, anchor, attachTo, x, y)
-- if anchor == GeneralDockManagerScrollFrameChild and y == -1 then
-- self:ClearAllPoints()
-- self:SetPoint(point, anchor, attachTo, x, -2)
-- end
-- end)
-- end

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
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat(self)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatPosAndFont(self)
	end
end)

-- Setup temp chat (BN, WHISPER) when needed
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	if frame.skinned then return end
	SetChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

-- Disable pet battle tab
local old = FCFManager_GetNumDedicatedFrames
function FCFManager_GetNumDedicatedFrames(...)
	return select(1, ...) ~= "PET_BATTLE_COMBAT_LOG" and old(...) or 1
end

-- Remove player's realm name
local function RemoveRealmName(_, _, msg, author, ...)
	local realm = string.gsub(R.realm, " ", "")
	if msg:find("-" .. realm) then
		return false, gsub(msg, "%-" .. realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

----------------------------------------------------------------------------------------
--	Save slash command typo
----------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------
--	Loot icons
----------------------------------------------------------------------------------------
local function AddLootIcons(_, _, message, ...)
	local function Icon(link)
		local texture = GetItemIcon(link)
		return "\124T" .. texture .. ":12:12:0:0:64:64:5:59:5:59\124t" .. link
	end
	message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", Icon)
	return false, message, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", AddLootIcons)

----------------------------------------------------------------------------------------
--	Swith channels by Tab
----------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------
--	Role icons
----------------------------------------------------------------------------------------
local chats = {
	CHAT_MSG_SAY = 1,
	CHAT_MSG_YELL = 1,
	CHAT_MSG_WHISPER = 1,
	CHAT_MSG_WHISPER_INFORM = 1,
	CHAT_MSG_PARTY = 1,
	CHAT_MSG_PARTY_LEADER = 1,
	CHAT_MSG_INSTANCE_CHAT = 1,
	CHAT_MSG_INSTANCE_CHAT_LEADER = 1,
	CHAT_MSG_RAID = 1,
	CHAT_MSG_RAID_LEADER = 1,
	CHAT_MSG_RAID_WARNING = 1,
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

	return string.format("|T%s:16:16:0:0:16:16:0:16:0:16:%d:%d:%d|t",
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

	local colorCode = string.format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
	local coloredName = GetColoredName_orig(event, _, arg2, ...)

	if role and role ~= "NONE" then
		local roleIcon = CreateRoleIconString(role, classColor)
		return roleIcon .. colorCode .. coloredName:gsub("^%s*", "") .. "|r"
	else
		return coloredName
	end
end
_G.GetColoredName = GetColoredName_hook
----------------------------------------------------------------------------------------
--	Prevent reposition ChatFrame
----------------------------------------------------------------------------------------
hooksecurefunc(ChatFrame1, "SetPoint", function(self, _, _, _, x)
	if x ~= C.position.chat[4] then
		self:ClearAllPoints()
		self:SetSize(C.chat.width, C.chat.height)
		self:SetPoint(C.position.chat[1], C.position.chat[2], C.position.chat[3], C.position.chat[4],
			C.position.chat[5])
	end
end)
