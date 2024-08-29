local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Move vehicle indicator
----------------------------------------------------------------------------------------
local VehicleAnchor = CreateFrame("Frame", "VehicleAnchor", UIParent)
VehicleAnchor:SetPoint(unpack(C.position.vehicle))
VehicleAnchor:SetSize(130, 130)

hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(_, _, parent)
	if parent and parent ~= VehicleAnchor then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("BOTTOM", VehicleAnchor, "BOTTOM", 0, 24)
		VehicleSeatIndicator:SetFrameStrata("LOW")
	end
end)

----------------------------------------------------------------------------------------
--	Vehicle indicator on mouseover
----------------------------------------------------------------------------------------
if C.general.vehicle_mouseover then
	local function VehicleSeatMouseover(self, vehicleID)
		if self:IsShown() then
			self:SetAlpha(0)
			self:HookScript("OnEnter", function() self:SetAlpha(1) end)
			self:HookScript("OnLeave", function() self:SetAlpha(0) end)

			local _, numSeat = GetVehicleUIIndicator(vehicleID)
			for i = 1, numSeat do
				local b = _G["VehicleSeatIndicatorButton"..i]
				b:HookScript("OnEnter", function() self:SetAlpha(1) end)
				b:HookScript("OnLeave", function() self:SetAlpha(0) end)
			end
		end
	end
	hooksecurefunc(VehicleSeatIndicator, "SetupVehicle", VehicleSeatMouseover)
end

----------------------------------------------------------------------------------------
--	Strip Override Action Bar textures
----------------------------------------------------------------------------------------

_G["OverrideActionBarEndCapL"]:Hide()
_G["OverrideActionBarEndCapR"]:Hide()
_G["OverrideActionBarMicroBGL"]:Hide()
_G["OverrideActionBarExpBar"]:SetAlpha(0)
_G["OverrideActionBarExpBar"]:Hide()

_G["OverrideActionBarButtonBGL"]:SetAlpha(0)
_G["OverrideActionBarButtonBGL"]:Hide()
_G["OverrideActionBarButtonBGMid"]:SetAlpha(0)
_G["OverrideActionBarButtonBGMid"]:Hide()
_G["OverrideActionBarButtonBGR"]:SetAlpha(0)
_G["OverrideActionBarButtonBGR"]:Hide()

_G["OverrideActionBarBG"]:SetAlpha(0)
_G["OverrideActionBarBG"]:Hide()
_G["OverrideActionBarBorder"]:Hide()
_G["OverrideActionBarMicroBGR"]:Hide()
_G["OverrideActionBarMicroBGMid"]:Hide()

----------------------------------------------------------------------------------------
--	Prevent micromenu from moving in vehicles
----------------------------------------------------------------------------------------
local function LockMicroMenuPosition()
    -- Store the original position of the micro menu
    if not MicroButtonAndBagsBar.originalPoint then
        MicroButtonAndBagsBar.originalPoint = {MicroButtonAndBagsBar:GetPoint()}
    end
end

local function RestoreMicroMenuPosition()
    if MicroButtonAndBagsBar.originalPoint then
        MicroButtonAndBagsBar:ClearAllPoints()
        MicroButtonAndBagsBar:SetPoint(unpack(MicroButtonAndBagsBar.originalPoint))
    end
end

-- Hook the OverrideActionBar's OnShow
hooksecurefunc(OverrideActionBar, "OnShow", function()
    LockMicroMenuPosition()
end)

-- Hook the OverrideActionBar's OnHide
hooksecurefunc(OverrideActionBar, "OnHide", function()
    RestoreMicroMenuPosition()
end)

-- Completely override the UpdateMicroButtons function
function OverrideActionBar:UpdateMicroButtons()
    -- Do nothing to prevent any movement
end

-- Create a frame to watch for relevant events
local watcherFrame = CreateFrame("Frame")
watcherFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
watcherFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
watcherFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
watcherFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        LockMicroMenuPosition()
    elseif event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" then
        local unit = ...
        if unit == "player" then
            C_Timer.After(0.1, RestoreMicroMenuPosition)
        end
    end
end)

-- Override the OverrideMicroMenuPosition function
function OverrideMicroMenuPosition(...)
    if HasVehicleActionBar() then
        RestoreMicroMenuPosition()
    else
        -- Call the original function only if not in a vehicle
        OverrideActionBar.OverrideMicroMenuPosition_Original(...)
    end
end

-- Store the original function and replace it
if not OverrideActionBar.OverrideMicroMenuPosition_Original then
    OverrideActionBar.OverrideMicroMenuPosition_Original = _G.OverrideMicroMenuPosition
    _G.OverrideMicroMenuPosition = OverrideMicroMenuPosition
end

----------------------------------------------------------------------------------------
--	Reposition OverrideActionBar Buttons
----------------------------------------------------------------------------------------
local function RepositionOverrideActionBar()
    if InCombatLockdown() then
        -- If in combat, delay the repositioning
        C_Timer.After(1, RepositionOverrideActionBar)  -- Retry after 1 second
        return
    end

    if not ActionButton1 then return end

    local point, relativeTo, relativePoint, xOfs, yOfs = ActionButton1:GetPoint()
    if not point then return end

    -- Adjust the position of OverrideActionBar
    OverrideActionBar:ClearAllPoints()
    OverrideActionBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0) -- Reset to bottom center

    -- Reposition spell buttons
    for i = 1, NUM_OVERRIDE_BUTTONS do
        local button = OverrideActionBar["SpellButton" .. i]
        button:ClearAllPoints()
        if i == 1 then
            button:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        else
            local prevButton = OverrideActionBar["SpellButton" .. (i-1)]
            button:SetPoint("LEFT", prevButton, "RIGHT", 6, 0)
        end
    end
    -- Reposition leave button (optional)
    OverrideActionBar.LeaveButton:ClearAllPoints()
    OverrideActionBar.LeaveButton:SetPoint("LEFT", OverrideActionBar["SpellButton" .. NUM_OVERRIDE_BUTTONS], "RIGHT", 6, 0)
end

-- Hook into OverrideActionBar setup
hooksecurefunc(OverrideActionBarMixin, "Setup", function(self)
    C_Timer.After(0, RepositionOverrideActionBar)
end)

-- Watch for action bar visibility changes
watcherFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
watcherFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
watcherFrame:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
watcherFrame:SetScript("OnEvent", function(self, event, ...)
    C_Timer.After(0, RepositionOverrideActionBar)
end)