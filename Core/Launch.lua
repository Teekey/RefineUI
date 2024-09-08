local R, C, L = unpack(RefineUI)

-- Spells lists initialization

C.nameplate.debuffsList = {}
C.nameplate.buffsList = {}
C.filger.buff_spells_list = {}
C.filger.proc_spells_list = {}
C.filger.debuff_spells_list = {}
C.filger.aura_bar_spells_list = {}
C.filger.cd_spells_list = {}
C.filger.ignore_spells_list = {}

----------------------------------------------------------------------------------------
--	First Time Launch and On Login file
----------------------------------------------------------------------------------------
local function InstallUI()
	-- Don't need to set CVar multiple time
	SetCVar("screenshotQuality", 8)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("showTutorials", 0)
	SetCVar("gameTip", "0")
	SetCVar("UberTooltips", 1)
	SetCVar("chatMouseScroll", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("WhisperMode", "inline")
	SetCVar("colorblindMode", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoLootDefault", 0)
	SetCVar("RotateMinimap", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("taintLog", 0)
	SetCVar("buffDurations", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("lossOfControl", 0)
	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateShowFriendlyNPCs", 1)



	-- Reset saved variables on char
	RefineUISettings = {}

	RefineUISettings.Install = true
	RefineUISettings.FogOfWar = true
	RefineUISettings.Coords = true
	RefineUISettings.Archaeology = false
	RefineUISettings.BarsLocked = false
	RefineUISettings.SplitBars = true
	RefineUISettings.RightBars = 3
	RefineUISettings.MainBars = 3
	RefineUISettings.BottomBars = 2

	ReloadUI()
end

----------------------------------------------------------------------------------------
--	Boss Banner Hider
----------------------------------------------------------------------------------------
BossBanner.PlayBanner = function() end
BossBanner:UnregisterAllEvents()

----------------------------------------------------------------------------------------
--	Easy delete good items
----------------------------------------------------------------------------------------
local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
if deleteDialog.OnShow then
	hooksecurefunc(deleteDialog, "OnShow",
		function(s)
			s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			s.editBox:SetAutoFocus(false)
			s.editBox:ClearFocus()
		end)
end

----------------------------------------------------------------------------------------
--	Popups
----------------------------------------------------------------------------------------
StaticPopupDialogs.INSTALL_UI = {
	text = L_POPUP_INSTALLUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() RefineUISettings.Install = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 5,
}

StaticPopupDialogs.RESET_UI = {
	text = L_POPUP_RESETUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() RefineUISettings.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("RESET_UI") end


----------------------------------------------------------------------------------------
--	On logon function
----------------------------------------------------------------------------------------
local OnLogon = CreateFrame("Frame")
OnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
OnLogon:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	-- Create empty CVar if they doesn't exist
	if RefineUISettings == nil then RefineUISettings = {} end
	if RefineUIPositions == nil then RefineUIPositions = {} end
	if RefineUISettings == nil then RefineUISettings = {} end
	if RefineUIItems == nil then RefineUIItems = {} end
	if RefineUISettings.FogOfWar == nil then RefineUISettings.FogOfWar = true end
	if RefineUISettings.Coords == nil then RefineUISettings.Coords = true end
	if RefineUISettings.Archaeology == nil then RefineUISettings.Archaeology = false end
	if RefineUISettings.BarsLocked == nil then RefineUISettings.BarsLocked = false end
	if RefineUISettings.SplitBars == nil then RefineUISettings.SplitBars = true end
	if RefineUISettings.RightBars == nil then RefineUISettings.RightBars = 3 end
	if RefineUISettings.MainBars == nil then RefineUISettings.MainBars = 3 end
	if RefineUISettings.BottomBars == nil then RefineUISettings.BottomBars = 2 end

	if R.screenWidth < 1024 and GetCVar("gxMonitor") == "0" then
		SetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
	else
		SetCVar("useUiScale", 1)
		if C.general.uiScale > 1.28 then C.general.uiscale = 1.28 end

		-- Set our uiScale
		if tonumber(GetCVar("uiScale")) ~= tonumber(C.general.uiScale) then
			SetCVar("uiScale", C.general.uiScale)
		end

		-- Hack for 4K and WQHD Resolution
		if C.general.uiScale < 0.64 then
			UIParent:SetScale(C.general.uiScale)
		end

		-- Install default if we never ran RefineUI on this character
		if not RefineUISettings.Install then
			StaticPopup_Show("INSTALL_UI")
		end
	end

	-- Hide the bag button
	if BagsBar then
		BagsBar:Hide()
	end
end)
