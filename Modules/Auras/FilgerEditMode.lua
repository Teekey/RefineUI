local R, C, L = unpack(RefineUI)
local LEM = LibStub('LibEditMode')

-- Ensure R.Filger exists
R.Filger = R.Filger or {}

-- Initialize custom spell lists
R.Filger.CustomSpells = R.Filger.CustomSpells or {
    LEFT_BUFF = {},
    RIGHT_BUFF = {},
    BOTTOM_BUFF = {}
}

local function AddSpell(location, spellID)
    -- Add spell to custom list
    table.insert(R.Filger.CustomSpells[location], spellID)
    -- Update Filger
    if R.Filger.UpdateAuras then
        R.Filger:UpdateAuras()
    else
        print("Filger:UpdateAuras not available")
    end
end

local function RemoveSpell(location, spellID)
    -- Remove spell from custom list
    for i, id in ipairs(R.Filger.CustomSpells[location]) do
        if id == spellID then
            table.remove(R.Filger.CustomSpells[location], i)
            break
        end
    end
    -- Update Filger
    if R.Filger.UpdateAuras then
        R.Filger:UpdateAuras()
    else
        print("Filger:UpdateAuras not available")
    end
end

local function CreateSpellEditUI(frame, location)
    local spellInput, addButton, spellList, removeButton

    -- Create a panel for the spell management UI
    local panel = CreateFrame("Frame", nil, frame)
    panel:SetSize(250, 300)
    panel:SetPoint("CENTER", frame, "CENTER")
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    panel:SetBackdropColor(0, 0, 0, 0.8)

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Manage " .. location .. " Spells")

    -- Spell Input
    spellInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    spellInput:SetSize(150, 20)
    spellInput:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    spellInput:SetAutoFocus(false)

    -- Add Button
    addButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    addButton:SetSize(60, 22)
    addButton:SetPoint("LEFT", spellInput, "RIGHT", 10, 0)
    addButton:SetText("Add")
    addButton:SetScript("OnClick", function()
        local spellID = tonumber(spellInput:GetText())
        if spellID then
            AddSpell(location, spellID)
            spellInput:SetText("")
            RefreshSpellList()
        end
    end)

    -- Spell List
    spellList = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    spellList:SetSize(200, 180)
    spellList:SetPoint("TOPLEFT", spellInput, "BOTTOMLEFT", 0, -20)

    local listContent = CreateFrame("Frame", nil, spellList)
    listContent:SetSize(180, 1) -- Height will be adjusted dynamically
    spellList:SetScrollChild(listContent)

    -- Remove Button
    removeButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    removeButton:SetSize(100, 22)
    removeButton:SetPoint("TOPLEFT", spellList, "BOTTOMLEFT", 0, -10)
    removeButton:SetText("Remove Selected")
    removeButton:SetScript("OnClick", function()
        local selected = listContent.selected
        if selected then
            RemoveSpell(location, selected)
            RefreshSpellList()
        end
    end)

    local function RefreshSpellList()
        -- Clear existing entries
        for _, child in ipairs({listContent:GetChildren()}) do
            child:Hide()
        end

        -- Add current spells
        local yOffset = 0
        for _, spellID in ipairs(R.Filger.CustomSpells[location]) do
            local spellName = GetSpellInfo(spellID)
            local button = CreateFrame("Button", nil, listContent)
            button:SetSize(180, 20)
            button:SetPoint("TOPLEFT", 0, -yOffset)
            button:SetText(spellName .. " (" .. spellID .. ")")
            button:SetNormalFontObject("GameFontNormal")
            button:SetHighlightFontObject("GameFontHighlight")
            button:SetScript("OnClick", function()
                listContent.selected = spellID
            end)
            yOffset = yOffset + 22
        end

        listContent:SetHeight(yOffset)
    end

    RefreshSpellList()

    -- Close Button
    local closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -5, -5)

    panel:Hide() -- Initially hide the panel

    -- Show/Hide toggle function
    local function TogglePanel()
        if panel:IsShown() then
            panel:Hide()
        else
            panel:Show()
            RefreshSpellList()
        end
    end

    -- Return the toggle function
    return TogglePanel
end

-- Modify RegisterFilgerFrames to use the new CreateSpellEditUI
local function RegisterFilgerFrames()
    local frames = {
        {name = "LEFT_BUFF", frame = LEFT_BUFF_Anchor},
        {name = "RIGHT_BUFF", frame = RIGHT_BUFF_Anchor},
        {name = "BOTTOM_BUFF", frame = BOTTOM_BUFF_Anchor}
    }

    for _, frameInfo in ipairs(frames) do
        if LEM.AddFrame then
            LEM:AddFrame(frameInfo.frame, function(_, _, point, x, y)
                if R.Filger.UpdateAnchorPosition then
                    R.Filger:UpdateAnchorPosition(frameInfo.name, point, x, y)
                else
                    print("Filger:UpdateAnchorPosition not available")
                end
            end, {
                point = "CENTER",
                x = 0,
                y = 0
            })
        else
            print("LibEditMode:AddFrame not available")
        end

        local toggleSpellUI = CreateSpellEditUI(frameInfo.frame, frameInfo.name)

        if LEM.AddFrameOption then
            LEM:AddFrameOption(frameInfo.frame, {
                type = "custom",
                name = "Manage Spells",
                callback = toggleSpellUI
            })
        else
            print("LibEditMode:AddFrameOption not available")
            frameInfo.frame:SetScript("OnMouseUp", function(self, button)
                if button == "RightButton" then
                    toggleSpellUI()
                end
            end)
        end
    end
end

-- Initialize
R.Filger.InitializeEditMode = function()
    RegisterFilgerFrames()
end

-- You can also add this at the end of the file to ensure it runs after everything is loaded
C_Timer.After(0, function()
    if R.Filger.InitializeEditMode then
        R.Filger:InitializeEditMode()
    else
        print("Filger:InitializeEditMode not available")
    end
end)