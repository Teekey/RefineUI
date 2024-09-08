local R, C, L = unpack(RefineUI)
local UF = R.UF
local LibEditModeOverride = LibStub("LibEditModeOverride-1.0")
local LEM = LibStub('LibEditMode')

-- Initialize RefineUIPositions at the top level
RefineUIPositions = RefineUIPositions or {}

local function onPositionChanged(frame, layoutName, point, x, y)
    print("Frame:", frame)
    print("Frame Name:", frame:GetName())
    print("Layout Name:", layoutName)
    print("Point:", point)
    print("X:", x)
    print("Y:", y)

    if not frame or not layoutName then
        print("Error: Invalid frame or layoutName in onPositionChanged")
        return
    end

    -- Initialize the table structure if it doesn't exist
    RefineUIPositions[layoutName] = RefineUIPositions[layoutName] or {}
    local frameName = frame:GetName()
    if not frameName then
        print("Error: Frame has no name in onPositionChanged")
        return
    end
    RefineUIPositions[layoutName][frameName] = RefineUIPositions[layoutName][frameName] or {}

    -- Now we can safely save the position
    local frameData = RefineUIPositions[layoutName][frameName]
    frameData.point = point
    frameData.x = x
    frameData.y = y

    -- Apply the new position immediately
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, point, x, y)

    print("Position saved and applied for frame:", frameName)
end

-- Assuming defaultPosition is defined somewhere
local function ConvertPosition(positionTable)
    return {
        point = positionTable[1],
        x = positionTable[4],
        y = positionTable[5]
    }
end

    local customFrames = {
        {"RefineUI_Player", C.position.unitframes.player},
        {"RefineUI_Target", C.position.unitframes.target},
        {"RefineUI_Focus", C.position.unitframes.focus},
        {"RefineUI_Party", C.position.unitframes.party},
        {"RefineUI_Raid", C.position.unitframes.raid},
        {"RefineUI_Boss", C.position.unitframes.boss},
        {"RefineUI_Arena", C.position.unitframes.arena},
        {"RefineUI_ExperienceBar", C.position.unitframes.experienceBar},
        {"RefineUI_Buffs", C.position.playerBuffs},
        {"RefineUI_SelfBuffsReminder", C.position.selfBuffs},
        {"DetailsBaseFrame1", C.position.details},
        {"RefineUI_AutoItemBar", C.position.autoitembar},
        {"RefineUI_LeftBuff", C.position.filger.left_buff},
        {"RefineUI_RightBuff", C.position.filger.right_buff},
        {"RefineUI_BottomBuff", C.position.filger.bottom_buff},
        {"RefineUI_BWTimeline", C.position.bwtimeline},
    }

    for _, frameInfo in ipairs(customFrames) do
        local frame = _G[frameInfo[1]]
        if frame then
            pcall(function()
                LEM:AddFrame(frame, onPositionChanged, ConvertPosition(frameInfo[2]))
            end)
        end
    end

-- if _G['RefineUI_Player'] then LEM:AddFrame(_G['RefineUI_Player'], onPositionChanged, ConvertPosition(C.position.unitframes.player)) end
-- if _G['RefineUI_Target'] then LEM:AddFrame(_G['RefineUI_Target'], onPositionChanged, ConvertPosition(C.position.unitframes.target)) end
-- if _G['RefineUI_ExperienceBar'] then LEM:AddFrame(_G['RefineUI_ExperienceBar'], onPositionChanged, ConvertPosition(C.position.unitframes.experienceBar)) end

-- if _G['DetailsBaseFrame1'] then LEM:AddFrame(_G['DetailsBaseFrame1'], onPositionChanged, ConvertPosition(C.position.details)) end

-- additional (anonymous) callbacks
LEM:RegisterCallback('enter', function()
    -- Add any enter logic here
end)

LEM:RegisterCallback('exit', function()
    -- Add any exit logic here
end)

LEM:RegisterCallback('layout', function(layoutName)
    -- Initialize the layout table if it doesn't exist
    RefineUIPositions[layoutName] = RefineUIPositions[layoutName] or {}

    -- Apply saved positions to all registered frames
    for frameName, frameData in pairs(RefineUIPositions[layoutName]) do
        local frame = _G[frameName]
        if frame then
            frame:ClearAllPoints()
            frame:SetPoint(frameData.point, UIParent, frameData.point, frameData.x, frameData.y)
        end
    end
end)


local function ConfigureRefineUILayout()
    LibEditModeOverride:LoadLayouts()
    if LibEditModeOverride:GetActiveLayout() == "RefineUI" then
        -- Set HideBarArt for MainBar
        LibEditModeOverride:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.HideBarArt, 1)
        
        -- Set HideBarScrolling for MainBar
        LibEditModeOverride:SetFrameSetting(MainMenuBar, Enum.EditModeActionBarSetting.HideBarScrolling, 1)
        
        -- Set VisibleSetting to Hidden for ExtraBar1, ExtraBar2, and ExtraBar3
        LibEditModeOverride:SetFrameSetting(MultiBar5, Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.Hidden)
        LibEditModeOverride:SetFrameSetting(MultiBar6, Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.Hidden)
        LibEditModeOverride:SetFrameSetting(MultiBar7, Enum.EditModeActionBarSetting.VisibleSetting, Enum.ActionBarVisibleSetting.Hidden)
        
        -- Apply the changes
        LibEditModeOverride:ApplyChanges()
    end
end

local function PositionRefineUILayout()
    LibEditModeOverride:LoadLayouts()
    if LibEditModeOverride:GetActiveLayout() == "RefineUI" then
        LibEditModeOverride:ReanchorFrame(_G['MinimapCluster'], unpack(C.position.minimap))
        LibEditModeOverride:ReanchorFrame(_G['MainMenuBar'], unpack(C.position.mainBar))
        LibEditModeOverride:ReanchorFrame(_G['MultiBarBottomLeft'], unpack(C.position.multiBarBottomLeft))
        LibEditModeOverride:ReanchorFrame(_G['MultiBarBottomRight'], unpack(C.position.multiBarBottomRight))
        LibEditModeOverride:ReanchorFrame(_G['MultiBarRight'], unpack(C.position.multiBarRight))
        LibEditModeOverride:ReanchorFrame(_G['MultiBarLeft'], unpack(C.position.multiBarLeft))
        LibEditModeOverride:ReanchorFrame(_G['MainMenuBarVehicleLeaveButton'], unpack(C.position.vehicle))
        LibEditModeOverride:ReanchorFrame(_G['PetActionBar'], unpack(C.position.petBar))
        LibEditModeOverride:ReanchorFrame(_G['StanceBar'], unpack(C.position.stanceBar))
        LibEditModeOverride:ReanchorFrame(_G['MicroMenuContainer'], unpack(C.position.microMenu))
        LibEditModeOverride:ReanchorFrame(_G['ObjectiveTrackerFrame'], unpack(C.position.objectiveTracker))
        LibEditModeOverride:ReanchorFrame(_G['ChatFrame1'], unpack(C.position.chat))
        LibEditModeOverride:ReanchorFrame(_G['GameTooltipDefaultContainer'], unpack(C.position.tooltip))
        LibEditModeOverride:ApplyChanges()
    end
end

local function InitializeRefineUILayout()
    LibEditModeOverride:LoadLayouts()
    if not LibEditModeOverride:DoesLayoutExist("RefineUI") then
        LibEditModeOverride:AddLayout(Enum.EditModeLayoutType.Account, "RefineUI")
        LibEditModeOverride:ApplyChanges()
        PositionRefineUILayout()
        ConfigureRefineUILayout()
    end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" and LibEditModeOverride:IsReady() then
        InitializeRefineUILayout()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

if _G['DetailsBaseFrame1'] then _G['DetailsBaseFrame1']:SetSize(300, 279) end

-- local framesToReanchor = {
--     { "MinimapCluster",                 C.position.minimap },
--     { "MainMenuBar",                    C.position.mainBar },
--     { "MultiBarBottomLeft",             C.position.multiBarBottomLeft },
--     { "MultiBarBottomRight",            C.position.multiBarBottomRight },
--     { "MultiBarRight",                  C.position.multiBarRight },
--     { "MultiBarLeft",                   C.position.multiBarLeft },
--     { "MainMenuBarVehicleLeaveButton",  C.position.vehicle },
--     { "PetActionBar",                   C.position.petBar },
--     { "StanceBar",                      C.position.stanceBar },
--     { "MicroMenuContainer",             C.position.microMenu },
--     { "ObjectiveTrackerFrame",          C.position.objectiveTracker },
--     { "ChatFrame1",                     C.position.chat },
--     { "GameTooltipDefaultContainer",    C.position.tooltip },
--     { "RefineUI_ExperienceBarAnchor",   C.position.experienceBar },
--     { "RefineUI_Player",                C.position.unitframes.player },
--     { "RefineUI_Target",                C.position.unitframes.target },
--     { "ZoneAbilityFrame",               C.position.zoneButton },
--     { "UIWidgetPowerBarContainerFrame", C.position.uiwidgetTop },
--     { "VigorBar",                       C.position.uiwidgetTop },
--     { "DetailsBaseFrame1",              C.position.details },
-- }


-- local function InitializeRefineUILayout()
--     LibEditModeOverride:LoadLayouts()
--     if not LibEditModeOverride:DoesLayoutExist("RefineUI") then
--         LibEditModeOverride:AddLayout(Enum.EditModeLayoutType.Account, "RefineUI")
--         LibEditModeOverride:ApplyChanges()
--     end

--     if LibEditModeOverride:GetActiveLayout() == "RefineUI" then
--         print("Reanchoring frames")
--         for _, frameInfo in ipairs(framesToReanchor) do
--             local frame = _G[frameInfo[1]]
--             if frame then
--                 pcall(function()
--                     LibEditModeOverride:ReanchorFrame(frame, unpack(frameInfo[2]))
--                 end)
--             end
--         end
--     end
-- end



-- -- Table to store frame configurations
-- local editModeFrames = {}

-- -- Function to get position from C.position
-- local function GetPosition(positionPath)
--     local position = C.position
--     for _, key in ipairs(positionPath) do
--         position = position[key]
--         if not position then return nil end
--     end
--     return position
-- end

-- -- Function to convert position table to LibEditMode format
-- local function ConvertPosition(positionTable)
--     return {
--         point = positionTable[1],
--         relativePoint = positionTable[2],
--         x = positionTable[4],
--         y = positionTable[5]
--     }
-- end

-- -- Function to add a frame to the edit mode system
-- local function AddEditModeFrame(frameName, frame, positionPath)
--     local position = GetPosition(positionPath)
--     if not position then
--         print("Warning: Position not found for " .. frameName)
--         return
--     end

--     editModeFrames[frameName] = {
--         frame = frame,
--         defaultPosition = ConvertPosition(position),
--         positionPath = positionPath
--     }
-- end

-- RefineUIPositions = RefineUIPositions or {}

-- -- Function to initialize all added frames with LibEditMode
-- local function InitializeEditModeFrames()
--     for frameName, frameConfig in pairs(editModeFrames) do
--         local frame = frameConfig.frame
--         local defaultPosition = frameConfig.defaultPosition

--         local function onPositionChanged(_, layoutName, point, x, y)
--             if not RefineUIPositions[frameName] then
--                 RefineUIPositions[frameName] = {}
--             end
--             RefineUIPositions[frameName][layoutName] = {point = point, x = x, y = y}
--         end

--         LEM:AddFrame(frame, onPositionChanged, defaultPosition)

--         LEM:RegisterCallback('layout', function(layoutName)
--             if not RefineUIPositions[frameName] then
--                 RefineUIPositions[frameName] = {}
--             end
--             if not RefineUIPositions[frameName][layoutName] then
--                 RefineUIPositions[frameName][layoutName] = CopyTable(defaultPosition)
--             end

--             local savedPosition = RefineUIPositions[frameName][layoutName]
--             frame:ClearAllPoints()
--             frame:SetPoint(savedPosition.point, UIParent, savedPosition.point, savedPosition.x, savedPosition.y)
--         end)
--     end

--     -- Additional callbacks (enter, exit) remain the same
-- end

-- -- Example usage:
-- AddEditModeFrame('Player', _G['RefineUI_Player'], {'unitframes', 'player'})
-- AddEditModeFrame('Target', _G['RefineUI_Target'], {'unitframes', 'target'})
-- AddEditModeFrame('Details', _G['DetailsBaseFrame1'], {'details'})
-- AddEditModeFrame('ZoneAbility', _G['ZoneAbilityFrame'], {'zoneButton'})
-- AddEditModeFrame('UIWidget', _G['UIWidgetPowerBarContainerFrame'], {'uiwidgetTop'})
-- AddEditModeFrame('VigorBar', _G['VigorBar'], {'uiwidgetTop'})




-- -- Initialize all added frames with LibEditMode
-- InitializeEditModeFrames()

-- local function ResetAllFrames()
--     for frameName, frameConfig in pairs(editModeFrames) do
--         local defaultPosition = frameConfig.defaultPosition

--         -- Reset saved positions
--         RefineUIPositions[frameName] = {
--             ["RefineUI"] = {  -- Assuming "RefineUI" is your layout name
--                 point = defaultPosition.point,
--                 relativePoint = defaultPosition.relativePoint,
--                 x = defaultPosition.x,
--                 y = defaultPosition.y
--             }
--         }
--     end

--     print("All frame positions have been reset to default in settings.")
--     print("Please reload your UI to apply the changes.")

--     -- Show reload UI popup
--     StaticPopup_Show("REFINEUI_RESET_RELOAD")
-- end

-- StaticPopupDialogs["REFINEUI_RESET_RELOAD"] = {
--     text = "Frame positions have been reset to default. Reload UI to apply changes?",
--     button1 = "Reload UI",
--     button2 = "Later",
--     OnAccept = function()
--         ReloadUI()
--     end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = true,
--     preferredIndex = 3,
-- }

-- -- Slash command to reset frames
-- SLASH_RESETUF1 = "/resetuf"
-- SlashCmdList["RESETUF"] = function(msg)
--     ResetAllFrames()
-- end

-- local function ApplyLayoutChanges()
--     local layoutName = "RefineUI"
--     local LibEditModeOverride = LibStub("LibEditModeOverride-1.0")
--     local layoutExists = LibEditModeOverride:DoesLayoutExist(layoutName)

--     print("Checking for RefineUI layout...")
--     print("Layout exists:", layoutExists)

--     if not layoutExists then
--         print("RefineUI layout doesn't exist. Creating layout and reinstalling UI...")
--         local success, errorMsg = pcall(function()
--             LibEditModeOverride:AddLayout(Enum.EditModeLayoutType.Account, layoutName)
--         end)

--         if not success then
--             print("Error creating layout:", errorMsg)
--             return
--         end

--         print("Layout created successfully.")
--         -- Trigger UI installation
--         -- This will cause a reload, so we don't need to continue execution
--         return
--     end

--     LibEditModeOverride:LoadLayouts()
--     LibEditModeOverride:SetActiveLayout(layoutName)

--     local framesToReanchor = {
--         {"MinimapCluster", C.position.minimap},
--         {"MainMenuBar", C.position.mainBar},
--         {"MultiBarBottomLeft", C.position.multiBarBottomLeft},
--         {"MultiBarBottomRight", C.position.multiBarBottomRight},
--         {"MultiBarRight", C.position.multiBarRight},
--         {"MultiBarLeft", C.position.multiBarLeft},
--         {"MainMenuBarVehicleLeaveButton", C.position.vehicle},
--         {"PetActionBar", C.position.petBar},
--         {"StanceBar", C.position.stanceBar},
--         {"MicroMenuContainer", C.position.microMenu},
--         {"ObjectiveTrackerFrame", C.position.objectiveTracker},
--         {"ChatFrame1", C.position.chat},
--         {"GameTooltipDefaultContainer", C.position.tooltip},
--         {"RefineUI_ExperienceBarAnchor", C.position.experienceBar},
--         {"RefineUI_Player", C.position.unitframes.player},
--         {"RefineUI_Target", C.position.unitframes.target},
--         {"ZoneAbilityFrame", C.position.zoneButton},
--         {"UIWidgetPowerBarContainerFrame", C.position.uiwidgetTop},
--         {"VigorBar", C.position.uiwidgetTop},
--         {"DetailsBaseFrame1", C.position.details},
--     }

--     for _, frameInfo in ipairs(framesToReanchor) do
--         local frame = _G[frameInfo[1]]
--         if frame then
--             pcall(function()
--                 LibEditModeOverride:ReanchorFrame(frame, unpack(frameInfo[2]))
--             end)
--         end
--     end

--     _G["DetailsBaseFrame1"]:SetHeight(280)
--     _G["DetailsBaseFrame1"]:SetWidth(300)

--     LibEditModeOverride:ApplyChanges()
--     print("Layout changes applied successfully.")
-- end

-- local function InitializeEditMode()
--     if LibEditModeOverride:IsReady() then
--         LibEditModeOverride:LoadLayouts()
--         InitializeEditModeFrames()
--         ApplyLayoutChanges()
--     end
-- end

-- C_Timer.After(1, function()
--     local success, error = pcall(InitializeEditMode)
--     if not success then
--         print("Error in InitializeEditMode:", error)
--     end
-- end)
