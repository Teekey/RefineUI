local R, C, L = unpack(RefineUI)

local function AutoAcceptQuest()
    if QuestFrame:IsShown() then
        if QuestFrameAcceptButton:IsVisible() then
            QuestFrameAcceptButton:Click()
        end
    end
end

local function AutoCompleteQuest()
    if QuestFrame:IsShown() and QuestFrameCompleteButton:IsVisible() then
        QuestFrameCompleteButton:Click()
    elseif QuestFrameRewardPanel:IsShown() then
        QuestFrameCompleteQuestButton:Click()
    end
end

local function CreateAutoQuestButton()
    local button = CreateFrame("Button", "RefineUI_AutoQuestButton", WorldMapFrame.BorderFrame, "UIPanelButtonTemplate")
    button:SetSize(26, 23)
    button:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame.TitleContainer, "TOPRIGHT", -25, 1)
    button:SetText("R")
    button:SetFrameStrata("DIALOG")  -- Changed from "HIGH" to "DIALOG" for better visibility

    return button
end

local function CreateAutoQuestDropdown(button)
    local dropdown = CreateFrame("Frame", "RefineUI_AutoQuestDropdown", button, "UIDropDownMenuTemplate")
    
    local function InitializeDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        info.text = "Auto Accept/Complete Quests"
        info.checked = GetCVarBool("autoQuestAcceptComplete")
        info.func = function()
            local newValue = not GetCVarBool("autoQuestAcceptComplete")
            SetCVar("autoQuestAcceptComplete", newValue)
            print("Auto Quest Accept/Complete is now " .. (newValue and "ON" or "OFF"))
        end
        UIDropDownMenu_AddButton(info)
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    
    return dropdown
end

R.InitAutoQuest = function()
    -- Register the CVar
    RegisterCVar("autoQuestAcceptComplete", "0")

    -- Create the button and dropdown
    local button = CreateAutoQuestButton()
    local dropdown = CreateAutoQuestDropdown(button)

    -- Set up the button click handler
    button:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
    end)

    -- Set up event handling for auto-accept and auto-complete
    local questFrame = CreateFrame("Frame")
    questFrame:RegisterEvent("QUEST_DETAIL")
    questFrame:RegisterEvent("QUEST_COMPLETE")
    questFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "QUEST_DETAIL" then
            if GetCVarBool("autoQuestAcceptComplete") then
                AutoAcceptQuest()
            end
        elseif event == "QUEST_COMPLETE" then
            if GetCVarBool("autoQuestAcceptComplete") then
                AutoCompleteQuest()
            end
        end
    end)

    print("Auto Accept/Complete Quests Loaded")
end

-- Call this function when your addon loads
R.InitAutoQuest()