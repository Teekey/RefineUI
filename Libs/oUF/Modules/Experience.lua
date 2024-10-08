--[[ Home:header
# Element: Experience

Adds support for an element that updates and displays the player's experience or honor as a
StatusBar widget.

## Widgets

- `Experience`
	A statusbar which displays the player's current experience or honor until the next level.  
	Has drop-in support for `AnimatedStatusBarTemplate`.
- `Experience.Rested`
	An optional background-layered statusbar which displays the exhaustion the player current has.  
	**Must** be parented to the `Experience` widget if used.

## Options

- `inAlpha` - Alpha used when the mouse is over the element (default: `1`)
- `outAlpha` - Alpha used when the mouse is outside of the element (default: `1`)
- `restedAlpha` - Alpha used for the `Rested` sub-widget (default: `0.15`)
- `tooltipAnchor` - Anchor for the tooltip (default: `"ANCHOR_BOTTOMRIGHT"`)

## Extras

- [Callbacks](Callbacks)
- [Overrides](Overrides)
- [Tags](Tags)

## Colors

This plug-in adds colors for experience (normal and rested) as well as honor.  
Accessible through `oUF.colors.experience` and `oUF.colors.honor`.

## Notes

- A default texture will be applied if the widget(s) is a StatusBar and doesn't have a texture set.
- Tooltip and mouse interaction options are only enabled if the element is mouse-enabled.
- Backgrounds/backdrops **must** be parented to the `Rested` sub-widget if used.
- Toggling honor-tracking is done through the PvP UI
- Remember to set the plug-in as an optional dependency for the layout if not embedding.

## Example implementation

```lua
-- Position and size
local Experience = CreateFrame('StatusBar', nil, self)
Experience:SetPoint('BOTTOM', 0, -50)
Experience:SetSize(200, 20)
Experience:EnableMouse(true) -- for tooltip/fading support

-- Position and size the Rested sub-widget
local Rested = CreateFrame('StatusBar', nil, Experience)
Rested:SetAllPoints(Experience)

-- Text display
local Value = Experience:CreateFontString(nil, 'OVERLAY')
Value:SetAllPoints(Experience)
Value:SetFontObject(GameFontHighlight)
self:Tag(Value, '[experience:cur] / [experience:max]')

-- Add a background
local Background = Rested:CreateTexture(nil, 'BACKGROUND')
Background:SetAllPoints(Experience)
Background:SetTexture('Interface\\ChatFrame\\ChatFrameBackground')

-- Register with oUF
self.Experience = Experience
self.Experience.Rested = Rested
```
--]]

local _, addon = ...
local oUF = addon.oUF or oUF
assert(oUF, 'oUF Experience was unable to locate oUF install')

oUF.colors.experience = {
	oUF:CreateColor(0.58, 0, 0.55), -- Normal
	oUF:CreateColor(0, 0.39, 0.88), -- Rested
}

oUF.colors.honor = {
	oUF:CreateColor(1, 0.71, 0), -- Normal
}

local function playerIsMaxLevel()
	local maxLevel = GetRestrictedAccountData()
	if maxLevel == 0 then
		maxLevel = GetMaxLevelForPlayerExpansion()
	end

	return maxLevel == UnitLevel('player')
end

local function playerIsMaxHonorLevel()
	return not C_PvP.GetNextHonorLevelForReward(UnitHonorLevel('player'))
end

local function getTrackedReputation()
    local watchedFactionData = C_Reputation.GetWatchedFactionData()
    if watchedFactionData then
        return watchedFactionData.name, watchedFactionData.factionID
    end
    return nil, nil
end

local function shouldShowHonor()
    if playerIsMaxLevel() then
        local trackedRep = getTrackedReputation()
        if trackedRep then
            return false -- Show reputation instead
        else
            return IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP()
        end
    end
    return false
end

--[[ Tags:header
A few basic tags are included:
- `[experience:cur]`       - the player's current experience/honor
- `[experience:max]`       - the player's maximum experience/honor
- `[experience:per]`       - the player's percentage of experience/honor in to the current level
- `[experience:level]`     - the player's current experience/honor level
- `[experience:currested]` - the player's current exhaustion
- `[experience:perrested]` - the player's percentage of exhaustion

See the [Examples](./#example-implementation) section on how to use the tags.
--]]
for tag, func in next, {
	['experience:cur'] = function(unit)
		return (shouldShowHonor() and UnitHonor or UnitXP)('player')
	end,
	['experience:max'] = function(unit)
		return (shouldShowHonor() and UnitHonorMax or UnitXPMax)('player')
	end,
	['experience:per'] = function(unit)
		return math.floor(_TAGS['experience:cur'](unit) / _TAGS['experience:max'](unit) * 100 + 0.5)
	end,
	['experience:level'] = function(unit)
		return (shouldShowHonor() and UnitHonorLevel or UnitLevel)('player')
	end,
	['experience:currested'] = function()
		return not shouldShowHonor() and GetXPExhaustion()
	end,
	['experience:perrested'] = function(unit)
		local rested = _TAGS['experience:currested']()
		if(rested and rested > 0) then
			return math.floor(rested / _TAGS['experience:max'](unit) * 100 + 0.5)
		end
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'PLAYER_XP_UPDATE UPDATE_EXHAUSTION HONOR_XP_UPDATE ZONE_CHANGED ZONE_CHANGED_NEW_AREA'
end

local function getValues()
    local isHonor = shouldShowHonor()
    local watchedFactionData = C_Reputation.GetWatchedFactionData()
    
    if playerIsMaxLevel() and watchedFactionData then
        local cur = watchedFactionData.currentStanding - watchedFactionData.currentReactionThreshold
        local max = watchedFactionData.nextReactionThreshold - watchedFactionData.currentReactionThreshold
        local perc = max > 0 and math.floor(cur / max * 100 + 0.5) or 0
        return cur, max, perc, 0, 0, watchedFactionData.reaction, false, watchedFactionData.name
    elseif isHonor then
        local cur = UnitHonor('player')
        local max = UnitHonorMax('player')
        local level = UnitHonorLevel('player')
        local perc = math.floor(cur / max * 100 + 0.5)
        return cur, max, perc, 0, 0, level, true
    else
        local cur = UnitXP('player')
        local max = UnitXPMax('player')
        local level = UnitLevel('player')
        local rested = GetXPExhaustion() or 0
        local perc = math.floor(cur / max * 100 + 0.5)
        local restedPerc = math.floor(rested / max * 100 + 0.5)
        return cur, max, perc, rested, restedPerc, level, false
    end
end

local function UpdateTooltip(element)
    local cur, max, perc, rested, restedPerc, level, isHonor, repName = getValues()

    if repName then
        GameTooltip:SetText(repName)
        GameTooltip:AddLine(string.format('%s / %s (%d%%)', BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), perc), 1, 1, 1)
        -- Optionally, you can add more reputation-specific information here
    elseif isHonor then
        GameTooltip:SetText(HONOR_LEVEL_LABEL:format(level))
        GameTooltip:AddLine(string.format('%s / %s (%d%%)', BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), perc), 1, 1, 1)
    else
        GameTooltip:SetText(COMBAT_XP_GAIN)
        GameTooltip:AddLine(string.format('%s / %s (%d%%)', BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), perc), 1, 1, 1)
        if rested > 0 then
            GameTooltip:AddLine(string.format('%s: %s (%d%%)', TUTORIAL_TITLE26, BreakUpLargeNumbers(rested), restedPerc), 1, 1, 1)
        end
    end

    GameTooltip:Show()
end

local function OnEnter(element)
	element:SetAlpha(element.inAlpha)
	GameTooltip:SetOwner(element, element.tooltipAnchor)

	--[[ Overrides:header
	### element:OverrideUpdateTooltip()

	Used to completely override the internal function for updating the tooltip.

	- `self` - the Experience element
	--]]
	if element.OverrideUpdateTooltip then
		element:OverrideUpdateTooltip()
	else
		UpdateTooltip(element)
	end
end

local function OnLeave(element)
	GameTooltip:Hide()
	element:SetAlpha(element.outAlpha)
end

local function UpdateColor(element, isHonor, isRested)
	local colors = element.__owner.colors
	if isHonor then
		colors = colors.honor[isRested and 2 or 1]
	else
		colors = colors.experience[isRested and 2 or 1]
	end

	local r, g, b = colors:GetRGB()
	element:SetStatusBarColor(r, g, b)
	if element.SetAnimatedTextureColors then
		element:SetAnimatedTextureColors(r, g, b)
	end

	if element.Rested then
		element.Rested:SetStatusBarColor(r, g, b, element.restedAlpha)
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit or unit ~= 'player' then
		return
	end

	local element = self.Experience
	if element.PreUpdate then
		--[[ Callbacks:header
		### element:PreUpdate(_unit_)

		Called before the element has been updated.

		- `self` - the Experience element
		- `unit` - the unit for which the update has been triggered _(string)_
		--]]
		element:PreUpdate(unit)
	end

    local cur, max, _, rested, _, level, isHonor, repName = getValues()
    if element.SetAnimatedValues then
        element:SetAnimatedValues(cur, 0, max, level)
    else
        element:SetMinMaxValues(0, max)
        element:SetValue(cur)
    end

    if repName then
        -- Set color for reputation bar (you can customize this)
        element:SetStatusBarColor(0, 0.5, 1)
    else
        (element.OverrideUpdateColor or UpdateColor)(element, isHonor, rested > 0)
    end

	if element.Rested then
		element.Rested:SetMinMaxValues(0, max)
		element.Rested:SetValue(math.min(cur + rested, max))
	end

	--[[ Overrides:header
	### element:OverrideUpdateColor(_isHonor, isRested_)

	Used to completely override the internal function for updating the widget's colors.

	- `self`     - the Experience element
	- `isHonor`  - indicates if the player is currently tracking honor or not _(boolean)_
	- `isRested` - indicates if the player has any exhaustion _(boolean)_
	--]]
	(element.OverrideUpdateColor or UpdateColor)(element, isHonor, rested > 0)

	if element.PostUpdate then
		--[[ Callbacks:header
		### element:PostUpdate(_unit, cur, max, rested, level, isHonor_)

		Called after the element has been updated.

		- `self`    - the Experience element
		- `unit`    - the unit for which the update has been triggered _(string)_
		- `cur`     - the unit's current experience/honor _(number)_
		- `max`     - the unit's maximum experience/honor _(number)_
		- `rested`  - the player's current exhaustion _(number)_
		- `level`   - the unit's current experience/honor level _(number)_
		- `isHonor` - indicates if the player is currently tracking honor or not _(boolean)_
		--]]
		return element:PostUpdate(unit, cur, max, rested, level, isHonor)
	end
end

local function Path(self, ...)
	--[[ Overrides:header
	### element.Override(_self, event, unit_)

	Used to completely override the internal update function.  
	Overriding this function also disables the [Callbacks](Callbacks).

	- `self`  - the parent object
	- `event` - the event triggering the update _(string)_
	- `unit`  - the unit accompanying the event _(variable(s))_
	--]]
	return (self.Experience.Override or Update)(self, ...)
end

local function ElementEnable(self)
	local element = self.Experience
	self:RegisterEvent('PLAYER_XP_UPDATE', Path, true)
	self:RegisterEvent('HONOR_XP_UPDATE', Path, true)
	self:RegisterEvent('ZONE_CHANGED', Path, true)
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', Path, true)

	if element.Rested then
		self:RegisterEvent('UPDATE_EXHAUSTION', Path, true)
	end

	element:Show()
	element:SetAlpha(element.outAlpha or 1)

	Path(self, 'ElementEnable', 'player')
end

local function ElementDisable(self)
	self:UnregisterEvent('PLAYER_XP_UPDATE', Path)
	self:UnregisterEvent('HONOR_XP_UPDATE', Path)
	self:UnregisterEvent('ZONE_CHANGED', Path)
	self:UnregisterEvent('ZONE_CHANGED_NEW_AREA', Path)

	if self.Experience.Rested then
		self:UnregisterEvent('UPDATE_EXHAUSTION', Path)
	end

	self.Experience:Hide()

	Path(self, 'ElementDisable', 'player')
end

local function Visibility(self, event, unit)
    local shouldEnable
    if not UnitHasVehicleUI('player') then
        if not playerIsMaxLevel() and not IsXPUserDisabled() then
            shouldEnable = true
        elseif shouldShowHonor() and not playerIsMaxHonorLevel() then
            shouldEnable = true
        elseif playerIsMaxLevel() and getTrackedReputation() then
            shouldEnable = true
        end
    end

    if shouldEnable then
        ElementEnable(self)
    else
        ElementDisable(self)
    end
end

local function VisibilityPath(self, ...)
	--[[ Overrides:header
	### element.OverrideVisibility(_self, event, unit_)

	Used to completely override the element's visibility update process.  
	The internal function is also responsible for (un)registering events related to the updates.

	- `self`  - the parent object
	- `event` - the event triggering the update _(string)_
	- `unit`  - the unit accompanying the event _(variable(s))_
	--]]
	return (self.Experience.OverrideVisibility or Visibility)(self, ...)
end

local function ForceUpdate(element)
	return VisibilityPath(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Experience
	if element and unit == 'player' then
		element.__owner = self

		element.ForceUpdate = ForceUpdate
		element.restedAlpha = element.restedAlpha or 0.15

		self:RegisterEvent('PLAYER_LEVEL_UP', VisibilityPath, true)
		self:RegisterEvent('HONOR_LEVEL_UPDATE', VisibilityPath, true)
		self:RegisterEvent('DISABLE_XP_GAIN', VisibilityPath, true)
		self:RegisterEvent('ENABLE_XP_GAIN', VisibilityPath, true)
		self:RegisterEvent('UPDATE_EXPANSION_LEVEL', VisibilityPath, true)
		self:RegisterEvent('UPDATE_FACTION', VisibilityPath, true)

		hooksecurefunc('SetWatchingHonorAsXP', function()
			if self:IsElementEnabled('Experience') then
				VisibilityPath(self, 'SetWatchingHonorAsXP', 'player')
			end
		end)

		local child = element.Rested
		if child then
			child:SetFrameLevel(element:GetFrameLevel() - 1)

			if not child:GetStatusBarTexture() then
				child:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if not element:GetStatusBarTexture() then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		if element:IsMouseEnabled() then
			element.tooltipAnchor = element.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'
			element.inAlpha = element.inAlpha or 1
			element.outAlpha = element.outAlpha or 1

			if not element:GetScript('OnEnter') then
				element:SetScript('OnEnter', OnEnter)
			end

			if not element:GetScript('OnLeave') then
				element:SetScript('OnLeave', OnLeave)
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.Experience
	if element then
		self:UnregisterEvent('PLAYER_LEVEL_UP', VisibilityPath)
		self:UnregisterEvent('HONOR_LEVEL_UPDATE', VisibilityPath)
		self:UnregisterEvent('DISABLE_XP_GAIN', VisibilityPath)
		self:UnregisterEvent('ENABLE_XP_GAIN', VisibilityPath)
		self:UnregisterEvent('UPDATE_EXPANSION_LEVEL', VisibilityPath)

		ElementDisable(self)
	end
end

oUF:AddElement('Experience', VisibilityPath, Enable, Disable)
