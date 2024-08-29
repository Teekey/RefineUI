local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------RefineUI	RefineUI variables
----------------------------------------------------------------------------------------
R.dummy = function() return end
R.name = UnitName("player")
R.class = select(2, UnitClass("player"))
R.level = UnitLevel("player")
R.client = GetLocale()
R.realm = GetRealmName()
R.color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[R.class]
-- R.version = C_AddOns.GetAddOnRefineUIdata("RefineUI", "Version")
R.screenWidth, R.screenHeight = GetPhysicalScreenSize()
R.newPatch = select(4, GetBuildInfo()) >= 110000

-- BETA
GetContainerItemInfo = function(bagIndex, slotIndex)
	local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
	if info then
		return info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound
	end
end

UnitAura = function(unit, auraIndex, filter)
	return AuraUtil.UnpackAuraData(C_UnitAuras.GetAuraDataByIndex(unit, auraIndex, filter))
end

UnitBuff = function(unit, auraIndex, filter)
	return AuraUtil.UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unit, auraIndex, filter))
end

GetSpellInfo = function(data)
	local spellInfo = C_Spell.GetSpellInfo(data)
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
	end
end

local function EasyMenu_Initialize( frame, level, menuList )
	for index = 1, #menuList do
		local value = menuList[index]
		if (value.text) then
			value.index = index;
			UIDropDownMenu_AddButton( value, level );
		end
	end
end

function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay )
	if ( displayMode == "MENU" ) then
		menuFrame.displayMode = displayMode;
	end
	UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList);
	ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay);
end