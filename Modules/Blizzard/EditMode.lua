local function CreateDirectionButton(parent, direction, x, y)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(20, 20)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(direction)
    return button
end

local function CreateCoordinateInputs(parent)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(240, 80)

    local xLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    xLabel:SetText("X:")
    xLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -5)

    local xInput = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    xInput:SetSize(60, 20)
    xInput:SetPoint("LEFT", xLabel, "RIGHT", 5, 0)
    xInput:SetAutoFocus(false)
    xInput:SetNumeric(true)

    local yLabel = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yLabel:SetText("Y:")
    yLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 120, -5)

    local yInput = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    yInput:SetSize(60, 20)
    yInput:SetPoint("LEFT", yLabel, "RIGHT", 5, 0)
    yInput:SetAutoFocus(false)
    yInput:SetNumeric(true)

    local updateButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    updateButton:SetText("Update Position")
    updateButton:SetSize(120, 22)
    updateButton:SetPoint("TOP", xInput, "BOTTOM", 30, -25)

    -- Create direction buttons
    local leftButton = CreateDirectionButton(container, "<", 30, -30)
    local rightButton = CreateDirectionButton(container, ">", 70, -30)
    local upButton = CreateDirectionButton(container, "^", 150, -30)
    local downButton = CreateDirectionButton(container, "v", 190, -30)

    container.xInput = xInput
    container.yInput = yInput
    container.updateButton = updateButton
    container.leftButton = leftButton
    container.rightButton = rightButton
    container.upButton = upButton
    container.downButton = downButton

    return container
end

local function UpdateFramePosition(frame, x, y)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -y)
end

local function GetFramePosition(frame)
    local scale = frame:GetEffectiveScale()
    local x, y = frame:GetLeft(), frame:GetTop()
    return math.floor(x / scale + 0.5), math.floor(y / scale + 0.5)
end

local function AdjustPosition(frame, dx, dy)
    local x, y = GetFramePosition(frame)
    UpdateFramePosition(frame, x + dx, y - dy)
    return x + dx, y - dy
end

local function HookEditModeDialog()
    hooksecurefunc(EditModeSystemSettingsDialog, "UpdateDialog", function(self)
        if not self.coordinateInputs then
            self.coordinateInputs = CreateCoordinateInputs(self)
            
            -- Position the container at the bottom of the dialog
            self.coordinateInputs:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 15, 15)
            
            -- Add extra space above the coordinate inputs
            local spacer = self:CreateTexture(nil, "BACKGROUND")
            spacer:SetHeight(20)
            spacer:SetPoint("BOTTOMLEFT", self.coordinateInputs, "TOPLEFT", 0, 5)
            spacer:SetPoint("BOTTOMRIGHT", self.coordinateInputs, "TOPRIGHT", 0, 5)
        end

        local frame = self.attachedToSystem
        if frame then
            local x, y = GetFramePosition(frame)
            self.coordinateInputs.xInput:SetText(tostring(x))
            self.coordinateInputs.yInput:SetText(tostring(y))
        end
    end)
end

local function InitializeXYCoordinates()
    HookEditModeDialog()

    -- Hook into the coordinate inputs
    hooksecurefunc(EditModeSystemSettingsDialog, "AttachToSystemFrame", function(self, systemFrame)
        if self.coordinateInputs then
            local function UpdateInputs(x, y)
                self.coordinateInputs.xInput:SetText(tostring(x))
                self.coordinateInputs.yInput:SetText(tostring(y))
                systemFrame:SetHasActiveChanges(true)
            end

            self.coordinateInputs.updateButton:SetScript("OnClick", function()
                local x = tonumber(self.coordinateInputs.xInput:GetText()) or 0
                local y = tonumber(self.coordinateInputs.yInput:GetText()) or 0
                UpdateFramePosition(systemFrame, x, y)
                UpdateInputs(x, y)
            end)

            -- Set up direction button scripts
            self.coordinateInputs.leftButton:SetScript("OnClick", function()
                local x, y = AdjustPosition(systemFrame, -1, 0)
                UpdateInputs(x, y)
            end)

            self.coordinateInputs.rightButton:SetScript("OnClick", function()
                local x, y = AdjustPosition(systemFrame, 1, 0)
                UpdateInputs(x, y)
            end)

            self.coordinateInputs.upButton:SetScript("OnClick", function()
                local x, y = AdjustPosition(systemFrame, 0, 1)
                UpdateInputs(x, y)
            end)

            self.coordinateInputs.downButton:SetScript("OnClick", function()
                local x, y = AdjustPosition(systemFrame, 0, -1)
                UpdateInputs(x, y)
            end)

            -- Update coordinate inputs when the frame is moved
            systemFrame:HookScript("OnDragStop", function()
                local x, y = GetFramePosition(systemFrame)
                UpdateInputs(x, y)
            end)
        end
    end)
end

-- Call this function when your addon loads
InitializeXYCoordinates()