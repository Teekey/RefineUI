local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF not loaded")

----------------------------------------------------------------------------------------
--	Radial Statusbar functions
----------------------------------------------------------------------------------------

local cos, sin, pi2, halfpi = math.cos, math.sin, math.rad(360), math.rad(90)

local function TransformTexture(tx, x, y, angle, aspect)
    local c, s = cos(angle), sin(angle)
    local y, oy = y / aspect, 0.5 / aspect
    local ULx, ULy = 0.5 + (x - 0.5) * c - (y - oy) * s, (oy + (y - oy) * c + (x - 0.5) * s) * aspect
    local LLx, LLy = 0.5 + (x - 0.5) * c - (y + oy) * s, (oy + (y + oy) * c + (x - 0.5) * s) * aspect
    local URx, URy = 0.5 + (x + 0.5) * c - (y - oy) * s, (oy + (y - oy) * c + (x + 0.5) * s) * aspect
    local LRx, LRy = 0.5 + (x + 0.5) * c - (y + oy) * s, (oy + (y + oy) * c + (x + 0.5) * s) * aspect
    tx:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

-- Permanently pause our rotation animation after it starts playing
local function OnPlayUpdate(self)
    self:SetScript('OnUpdate', nil)
    self:Pause()
end

local function OnPlay(self)
    self:SetScript('OnUpdate', OnPlayUpdate)
end

local function SetRadialStatusBarValue(self, value)
    value = math.max(0, math.min(1, value))

    if self._reverse then
        value = 1 - value
    end

    local q = self._clockwise and (1 - value) or value
    local quadrant = q >= 0.75 and 1 or q >= 0.5 and 2 or q >= 0.25 and 3 or 4

    if self._quadrant ~= quadrant then
        self._quadrant = quadrant
        for i = 1, 4 do
            self._textures[i]:SetShown(self._clockwise and i < quadrant or not self._clockwise and i > quadrant)
        end
        self._scrollframe:SetAllPoints(self._textures[quadrant])
    end

    local rads = value * pi2
    if not self._clockwise then rads = -rads + halfpi end
    TransformTexture(self._wedge, -0.5, -0.5, rads, self._aspect)
    self._rotation:SetRadians(-rads)
end

local function OnSizeChanged(self, width, height)
    self._wedge:SetSize(width, height)
    self._aspect = width / height
end

-- Creates a function that calls a method on all textures at once
local function CreateTextureFunction(func)
    return function(self, ...)
        for i = 1, 4 do
            self._textures[i][func](self._textures[i], ...)
        end
        self._wedge[func](self._wedge, ...)
    end
end

-- Pass calls to these functions on our frame to its textures
local TextureFunctions = {
    SetTexture = CreateTextureFunction('SetTexture'),
    SetBlendMode = CreateTextureFunction('SetBlendMode'),
    SetVertexColor = CreateTextureFunction('SetVertexColor'),
}

local function CreateRadialStatusBar(parent)
    local bar = CreateFrame('Frame', nil, parent)

    local scrollframe = CreateFrame('ScrollFrame', nil, bar)
    scrollframe:SetPoint('BOTTOMLEFT', bar, 'CENTER')
    scrollframe:SetPoint('TOPRIGHT')
    bar._scrollframe = scrollframe

    local scrollchild = CreateFrame('frame', nil, scrollframe)
    scrollframe:SetScrollChild(scrollchild)
    scrollchild:SetAllPoints(scrollframe)

    local wedge = scrollchild:CreateTexture()
    wedge:SetPoint('BOTTOMRIGHT', bar, 'CENTER')
    bar._wedge = wedge

    -- Create quadrant textures
    local textures = {
        bar:CreateTexture(), -- Top Right
        bar:CreateTexture(), -- Bottom Right
        bar:CreateTexture(), -- Bottom Left
        bar:CreateTexture() -- Top Left
    }

    textures[1]:SetPoint('BOTTOMLEFT', bar, 'CENTER')
    textures[1]:SetPoint('TOPRIGHT')
    textures[1]:SetTexCoord(0.5, 1, 0, 0.5)

    textures[2]:SetPoint('TOPLEFT', bar, 'CENTER')
    textures[2]:SetPoint('BOTTOMRIGHT')
    textures[2]:SetTexCoord(0.5, 1, 0.5, 1)

    textures[3]:SetPoint('TOPRIGHT', bar, 'CENTER')
    textures[3]:SetPoint('BOTTOMLEFT')
    textures[3]:SetTexCoord(0, 0.5, 0.5, 1)

    textures[4]:SetPoint('BOTTOMRIGHT', bar, 'CENTER')
    textures[4]:SetPoint('TOPLEFT')
    textures[4]:SetTexCoord(0, 0.5, 0, 0.5)

    bar._textures = textures
    bar._quadrant = nil
    bar._clockwise = true
    bar._reverse = false
    bar._aspect = 1
    bar:HookScript('OnSizeChanged', OnSizeChanged)

    for method, func in pairs(TextureFunctions) do
        bar[method] = func
    end

    bar.SetRadialStatusBarValue = SetRadialStatusBarValue

    local group = wedge:CreateAnimationGroup()
    local rotation = group:CreateAnimation('Rotation')
    bar._rotation = rotation
    rotation:SetDuration(0)
    rotation:SetEndDelay(1)
    rotation:SetOrigin('BOTTOMRIGHT', 0, 0)
    group:SetScript('OnPlay', OnPlay)
    group:Play()

    return bar
end

R.CreateRadialStatusBar = CreateRadialStatusBar

----------------------------------------------------------------------------------------
--	CombinedPortrait element
----------------------------------------------------------------------------------------

local CombinedPortrait = {
    indexByID = {}, --[questID] = questIndex
    activeQuests = {} --[questTitle] = questID
}

local ScanTooltip = CreateFrame("GameTooltip", "oUF_CombinedPortraitTooltip", UIParent, "GameTooltipTemplate")
local ThreatTooltip = THREAT_TOOLTIP:gsub("%%d", "%%d-")

local function CheckTextForQuest(text)
    local x, y = strmatch(text, "(%d+)/(%d+)")
    if x and y then
        return tonumber(x) / tonumber(y), x == y  -- Return progress (0 to 1) and whether it's complete
    elseif not strmatch(text, ThreatTooltip) then
        local progress = tonumber(strmatch(text, "([%d%.]+)%%"))
        if progress and progress <= 100 then
            return progress / 100, progress == 100, true  -- Return progress (0 to 1), whether it's complete, and isPercent
        end
    end
    return nil, false  -- Return nil if no quest info found, and false for not complete
end

local function GetQuests(unitID)
    local _, instanceType = IsInInstance()
    if instanceType == "arena" or instanceType == "pvp" or instanceType == "raid" then return end

    ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    ScanTooltip:SetUnit(unitID)
    ScanTooltip:Show()

    local QuestList, notMyQuest, activeID
    for i = 3, ScanTooltip:NumLines() do
        local str = _G["oUF_CombinedPortraitTooltipTextLeft" .. i]
        local text = str and str:GetText()
        if not text or text == "" then break end

        if UnitIsPlayer(text) then
            notMyQuest = text ~= UnitName("player")
        elseif text and not notMyQuest then
            local progress, isComplete, isPercent = CheckTextForQuest(text)
            local activeQuest = CombinedPortrait.activeQuests[text]
            if activeQuest then activeID = activeQuest end

            if progress and not isComplete then
                local questType, index, texture, _
                if activeID then
                    index = CombinedPortrait.indexByID[activeID]
                    _, texture = GetQuestLogSpecialItemInfo(index)
                    for i = 1, GetNumQuestLeaderBoards(index) or 0 do
                        local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(activeID, i, false)
                        if objectiveText and not finished then
                            if objectiveType == "item" or objectiveType == "object" then
                                questType = "LOOT_ITEM"
                            elseif objectiveType == "monster" then
                                questType = "KILL"
                            end
                        end
                    end
                end

                if texture then
                    questType = "QUEST_ITEM"
                end

                if not QuestList then QuestList = {} end
                QuestList[#QuestList + 1] = {
                    isPercent = isPercent,
                    itemTexture = texture,
                    objectiveProgress = progress,
                    questType = questType or "DEFAULT",
                    questLogIndex = index,
                    questID = activeID
                }
            end
        end
    end

    ScanTooltip:Hide()
    return QuestList
end

local function Update(self, event, unit)
    if not unit or not self.unit or not UnitIsUnit(self.unit, unit) then return end

    local element = self.CombinedPortrait
    if not element then return end

    if element.PreUpdate then
        element:PreUpdate(unit)
    end

    local guid = UnitGUID(unit)
    local isAvailable = UnitIsConnected(unit) and UnitIsVisible(unit)

    -- Reset isQuestMob property
    self.isQuestMob = false

    -- Check for spell cast (highest priority)
    local castName, _, castTexture = UnitCastingInfo(unit)
    if not castName then
        castName, _, castTexture = UnitChannelInfo(unit)
    end

    if castName and castTexture then
        element:SetTexture(castTexture)
        if element.Text then element.Text:SetText("") end
        element.currentState = 'cast'
        element.radialStatusbar:SetRadialStatusBarValue(0) -- Reset radial status bar for cast
    else
        -- Check for quest status (medium priority)
        local questList = GetQuests(unit)
        if questList and #questList > 0 then
            self.isQuestMob = true  -- Set isQuestMob property
            local quest = questList[1]
            element.radialStatusbar:SetRadialStatusBarValue(quest.objectiveProgress)

            if quest.questType == "LOOT_ITEM" then
                element:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\QuestLoot.blp")
            elseif quest.questType == "KILL" then
                element:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\QuestKill.blp")
            elseif quest.questType == "QUEST_ITEM" then
                element:SetTexture(quest.itemTexture)
            else
                element:SetTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\QuestIcon.blp")
            end
            
            if element.Text then
                local newText = quest.isPercent and (math.floor(quest.objectiveProgress * 100) .. "%") or tostring(math.floor(quest.objectiveProgress * 100))
                element.Text:SetText(newText)
                element.Text:SetTextColor(1, 0.82, 0)
                element.Text:Show()
            end
            element.currentState = 'quest'
        else
            -- Default to normal portrait (lowest priority)
            SetPortraitTexture(element, unit)
            if element.Text then element.Text:SetText("") end
            element.currentState = 'portrait'
            element.radialStatusbar:SetRadialStatusBarValue(0) -- Reset radial status bar if no quests
        end
    end

    element:Show()
    element.guid = guid
    element.state = isAvailable

    if element.PostUpdate then
        return element:PostUpdate(unit)
    end
end

local function Path(self, ...)
    return (self.CombinedPortrait.Override or Update) (self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
    local element = self.CombinedPortrait
    if element then
        element.__owner = self
        element.ForceUpdate = ForceUpdate

        -- Initialize isQuestMob property
        self.isQuestMob = false

        self:RegisterEvent('UNIT_PORTRAIT_UPDATE', Path)
        self:RegisterEvent('UNIT_MODEL_CHANGED', Path)
        self:RegisterEvent('UNIT_CONNECTION', Path)
        self:RegisterEvent('UNIT_SPELLCAST_START', Path)
        self:RegisterEvent('UNIT_SPELLCAST_STOP', Path)
        self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START', Path)
        self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Path)
        self:RegisterEvent('QUEST_LOG_UPDATE', Path, true)
        self:RegisterEvent('UNIT_NAME_UPDATE', Path)

        SetCVar("showQuestTrackingTooltips", 1)

        element:Show()

        return true
    end
end

local function Disable(self)
    local element = self.CombinedPortrait
    if element then
        element:Hide()

        self:UnregisterEvent('UNIT_PORTRAIT_UPDATE', Path)
        self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
        self:UnregisterEvent('UNIT_CONNECTION', Path)
        self:UnregisterEvent('UNIT_SPELLCAST_START', Path)
        self:UnregisterEvent('UNIT_SPELLCAST_STOP', Path)
        self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_START', Path)
        self:UnregisterEvent('UNIT_SPELLCAST_CHANNEL_STOP', Path)
        self:UnregisterEvent('QUEST_LOG_UPDATE', Path)
        self:UnregisterEvent('UNIT_NAME_UPDATE', Path)
    end
end


local frame = CreateFrame("Frame")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", function(self, event)
    wipe(CombinedPortrait.indexByID)
    wipe(CombinedPortrait.activeQuests)

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local id = C_QuestLog.GetQuestIDForLogIndex(i)
        if id and id > 0 then
            CombinedPortrait.indexByID[id] = i

            local title = C_QuestLog.GetTitleForLogIndex(i)
            if title then CombinedPortrait.activeQuests[title] = id end
        end
    end

    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent(event)
    end

    if event == "QUEST_LOG_UPDATE" then
        for _, nameplate in pairs(oUF.objects) do
            if nameplate and nameplate.CombinedPortrait then
                nameplate.CombinedPortrait:ForceUpdate() -- Force update for each nameplate
            end
        end
    end
end)

oUF:AddElement('CombinedPortrait', Path, Enable, Disable)