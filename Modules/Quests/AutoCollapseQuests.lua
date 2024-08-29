local addonName, addon = ...

-- Initialize default settings
addon.defaultSettings = {
    autoCollapseMode = "NONE" -- Default to no auto-collapse
}

-- Initialize saved variables
function addon:OnAddonLoaded(event, loadedAddonName)
    if loadedAddonName ~= addonName then return end
    
    -- Initialize or load saved variables
    ObjectiveTrackerCollapseSettings = ObjectiveTrackerCollapseSettings or addon.defaultSettings
    
    addon:SetupMenu()
    addon:SetupAutoCollapse()
end

-- Create the right-click menu
function addon:SetupMenu()
    local menuFrame = CreateFrame("Frame", "ObjectiveTrackerCollapseMenu", UIParent, "UIDropDownMenuTemplate")
    
    local function MenuOnClick(self, arg1, arg2, checked)
        ObjectiveTrackerCollapseSettings.autoCollapseMode = arg1
        CloseDropDownMenus()
        addon:SetupAutoCollapse() -- Refresh auto-collapse behavior
    end
    
    local menuList = {
        {text = "Auto Collapse Mode", isTitle = true, notCheckable = true},
        {text = "None", arg1 = "NONE", func = MenuOnClick, checked = function() return ObjectiveTrackerCollapseSettings.autoCollapseMode == "NONE" end},
        {text = "In Raid", arg1 = "RAID", func = MenuOnClick, checked = function() return ObjectiveTrackerCollapseSettings.autoCollapseMode == "RAID" end},
        {text = "In Scenario", arg1 = "SCENARIO", func = MenuOnClick, checked = function() return ObjectiveTrackerCollapseSettings.autoCollapseMode == "SCENARIO" end},
        {text = "On Reload", arg1 = "RELOAD", func = MenuOnClick, checked = function() return ObjectiveTrackerCollapseSettings.autoCollapseMode == "RELOAD" end},
    }
    
    local minimizeButton = ObjectiveTrackerFrame.Header.MinimizeButton
    
    -- Store the original OnClick script
    local originalOnClick = minimizeButton:GetScript("OnClick")
    
    -- Replace the OnClick script
    minimizeButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            -- Call the original OnClick function for left-click
            if originalOnClick then
                originalOnClick(self, button)
            end
        elseif button == "RightButton" then
            -- Only open the menu for right-click
            EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU")
        end
    end)
    
    -- Enable right-click on the MinimizeButton
    minimizeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Add tooltip functionality
    minimizeButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Objective Tracker Controls")
        GameTooltip:AddLine("Left-click: Collapse/Expand", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Auto-collapse Settings", 1, 1, 1)
        GameTooltip:Show()
    end)

    minimizeButton:HookScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

-- Setup auto-collapse behavior
function addon:SetupAutoCollapse()
    local function CollapseObjectiveTracker()
        C_Timer.After(0.1, function()
            if not ObjectiveTrackerFrame.isCollapsed then
                ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:Click()
            end
        end)
    end
    
    local function ExpandObjectiveTracker()
        C_Timer.After(0.1, function()
            if ObjectiveTrackerFrame.isCollapsed then
                ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:Click()
            end
        end)
    end
    
    local function OnEvent()
        local mode = ObjectiveTrackerCollapseSettings.autoCollapseMode
        local inInstance, instanceType = IsInInstance()
        
        if mode == "RAID" and inInstance then
            CollapseObjectiveTracker()
        elseif mode == "SCENARIO" then
            if inInstance then
                if instanceType == "party" or instanceType == "scenario" then
                    -- Collapse only specific headers
                    C_Timer.After(0.1, function()
                        for i = 3, #ObjectiveTrackerFrame.MODULES do
                            if ObjectiveTrackerFrame.MODULES[i].SetCollapsed then
                                ObjectiveTrackerFrame.MODULES[i]:SetCollapsed(true)
                            end
                        end
                    end)
                else
                    CollapseObjectiveTracker()
                end
            else
                ExpandObjectiveTracker()
            end
        elseif mode == "RELOAD" then
            CollapseObjectiveTracker()
        else
            ExpandObjectiveTracker()
        end
    end
    
    -- Remove existing event listener if any
    if addon.autoCollapseFrame then
        addon.autoCollapseFrame:UnregisterAllEvents()
        addon.autoCollapseFrame:SetScript("OnEvent", nil)
    end
    
    -- Setup new event listener
    addon.autoCollapseFrame = addon.autoCollapseFrame or CreateFrame("Frame")
    addon.autoCollapseFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.autoCollapseFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    addon.autoCollapseFrame:SetScript("OnEvent", OnEvent)
    
    -- Initial setup
    OnEvent()
end

-- Register events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    addon:OnAddonLoaded(event, ...)
end)