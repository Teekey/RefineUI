----------------------------------------------------------------------------------------
--	BWTimeline for RefineUI
--	This module provides a timeline interface for BigWigs boss mods in World of Warcraft.
--	It displays upcoming boss abilities and events on a graphical timeline.
--	Based on ElWigo by Oillamp, adapted and enhanced for RefineUI.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)
if C.bwtimeline.enable ~= true or not C_AddOns.IsAddOnLoaded("BigWigs") then
    return
end

----------------------------------------------------------------------------------------
--	Initialization and Setup
----------------------------------------------------------------------------------------

local anchor = CreateFrame("Frame", "RefineUI_BWTimeline", UIParent)
anchor:SetSize(C.bwtimeline.bar_width + C.bwtimeline.icons_width, C.bwtimeline.bar_length)
anchor:SetPoint(unpack(C.position.bwtimeline))

TKUITimeline = LibStub("AceAddon-3.0"):NewAddon("TKUITimeline", "AceTimer-3.0")

local BWT = TKUITimeline
local pairs, ipairs = pairs, ipairs
local tremove = table.remove
local tsort = table.sort
local tinsert = table.insert
local unpack = unpack
local frameTemplate = "BackdropTemplate"
local IsEncounterInProgress = IsEncounterInProgress

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------

local dirToAnchors = {
    ABOVE = {"TOP", "BOTTOM"},
    BELOW = {"BOTTOM", "TOP"},
    LEFT = {"LEFT", "RIGHT"},
    RIGHT = {"RIGHT", "LEFT"},
    CENTER = {"CENTER", "CENTER"}
}

local function createTimelineBar()
    local f = CreateFrame("Frame", "TKUITimeline", UIParent, frameTemplate)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(5)
    f:SetTemplate("Transparent")
    
    f.frames = {}

    f.texture = f:CreateTexture(nil, "BACKGROUND")
    f.texture:SetAllPoints()

    return f
end

BWT.bar = createTimelineBar()

----------------------------------------------------------------------------------------
--	Timeline Bar Management
----------------------------------------------------------------------------------------

function BWT:updateTimelineBar()
    local bar = BWT.bar

    bar.max_time = C.bwtimeline.bar_max_time
    bar.scheduledAnchorUpdate = 0

    bar:ClearAllPoints()
    bar:SetPoint("CENTER", anchor)
    bar:SetSize(C.bwtimeline.bar_width, C.bwtimeline.bar_length)
    -- bar:SetTemplate("Transparent")

    bar.startAnchor = C.bwtimeline.bar_reverse and "BOTTOM" or "TOP"
    bar.endAnchor = C.bwtimeline.bar_reverse and "TOP" or "BOTTOM"
    bar.x_mul = 0
    bar.y_mul = C.bwtimeline.bar_reverse and -1 or 1
    bar.lengthPerTime = C.bwtimeline.bar_length / C.bwtimeline.bar_max_time

    self:updateTimelineBarVisibility()

    -- Create and update ticks
    bar.ticks = bar.ticks or {}
    local ticks = bar.ticks
    local maxBars = floor(C.bwtimeline.bar_max_time / C.bwtimeline.bar_tick_spacing)
    if C.bwtimeline.bar_max_time % C.bwtimeline.bar_tick_spacing == 0 then
        maxBars = maxBars - 1
    end
    local N = max(#ticks, maxBars)

    for i = 1, N do
        ticks[i] = ticks[i] or CreateFrame("Frame", nil, bar, frameTemplate)
        ticks[i]:SetFrameStrata("MEDIUM")
        local t = ticks[i]
        if (not C.bwtimeline.bar_has_ticks) or i > maxBars then
            t:Hide()
        else
            t:Show()
            t:SetFrameLevel(bar:GetFrameLevel() + (C.bwtimeline.bar_above_icons and 6 or 1))

            local thicknessOffset = floor(C.bwtimeline.bar_tick_width / 2)
            local l = i * C.bwtimeline.bar_tick_spacing * bar.lengthPerTime + thicknessOffset
            t:ClearAllPoints()
            t:SetPoint("TOP", bar, bar.endAnchor, bar.x_mul * l, bar.y_mul * l)

            t:SetSize(C.bwtimeline.bar_tick_length, C.bwtimeline.bar_tick_width)

            if not t.texture then
                t.texture = t:CreateTexture(nil, "BACKGROUND")
            end
            t.texture:SetAllPoints()
            t.texture:SetColorTexture(unpack(C.bwtimeline.bar_tick_color))

            if not t.text then
                t.text = t:CreateFontString(nil, "BACKGROUND")
            end
            if C.bwtimeline.bar_tick_text then
                t.text:Show()
                local a1, a2 = unpack(dirToAnchors[C.bwtimeline.bar_tick_text_position])
                t.text:ClearAllPoints()
                t.text:SetPoint(a2, t, a1)
                t.text:SetTextColor(unpack(C.bwtimeline.bar_tick_text_color))

                t.text:SetFont(unpack(C.font.bwt.tick))
                t.text:SetText(i * C.bwtimeline.bar_tick_spacing)
            else
                t.text:Hide()
            end
        end
    end
end

----------------------------------------------------------------------------------------
--	Icon Frame Management
----------------------------------------------------------------------------------------

local FRAME_ID_COUNTER = 0
local framePool = {}

local function createIconFrame()
    if #framePool > 0 then
        return tremove(framePool)
    end

    local f = CreateFrame("Frame", nil, UIParent, frameTemplate)
    f:SetFrameStrata("MEDIUM")

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetAllPoints()

    f.nameText = f:CreateFontString(nil, "OVERLAY")
    f.durationText = f:CreateFontString(nil, "OVERLAY")
    f.durationText:SetPoint("CENTER")

    FRAME_ID_COUNTER = FRAME_ID_COUNTER + 1
    f.id = FRAME_ID_COUNTER

    return f
end

function BWT:updateFrameParameters(frame)
    frame:SetSize(C.bwtimeline.icons_width, C.bwtimeline.icons_height)
    frame:SetFrameLevel(frame.bar_:GetFrameLevel() + 4)

    if C.bwtimeline.icons_name then
        frame.nameText:Show()
        frame.nameText:SetFont(unpack(C.font.bwt.default))
        frame.nameText:ClearAllPoints()
        local a1, a2 = unpack(dirToAnchors[C.bwtimeline.icons_name_position])
        frame.nameText:SetPoint(a2, frame, a1)
        frame.nameText:SetTextColor(unpack(C.bwtimeline.icons_name_color))

        local name = frame.name
        if C.bwtimeline.icons_name_number then
            name = name .. " " .. frame.number
        end
        frame.nameText:SetText(name)
        frame.nameText:SetJustifyH("LEFT")
        frame.nameText:SetJustifyV("MIDDLE")
    else
        frame.nameText:Hide()
    end

    if C.bwtimeline.icons_duration then
        frame.durationText:Show()
        frame.durationText:SetFont(unpack(C.font.bwt.duration))
        local a1, a2 = unpack(dirToAnchors[C.bwtimeline.icons_duration_position])
        frame.durationText:SetPoint(a2, frame, a1)
        frame.durationText:SetTextColor(unpack(C.bwtimeline.icons_duration_color))
    else
        frame.durationText:Hide()
    end

    frame.icon:SetTexture(frame.iconID)
    frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    frame.icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
end

function BWT:removeFrame(frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(nil)
    tinsert(framePool, frame)

    local frames = frame.bar_.frames
    for i, v in ipairs(frames) do
        if v.id == frame.id then
            tremove(frames, i)
            break
        end
    end

    if #frames == 0 then
        self:updateTimelineBarVisibility()
    end

    self:scheduleAnchorUpdate(frame.bar_)
end

----------------------------------------------------------------------------------------
--	Frame Update and Positioning
----------------------------------------------------------------------------------------

local function moveFrame(frame, bar)
    local t = frame.remDuration * bar.lengthPerTime
    frame:SetPoint("CENTER", bar, bar.endAnchor, t * bar.x_mul, t * bar.y_mul)
end

local function formatDuration(dur)
    if dur <= 60 then
        return ("%d"):format(dur)
    else
        return ("%d:%02d"):format(dur / 60, dur % 60)
    end
end

function frameOnUpdate(frame)
    local t = GetTime()
    if t - frame.lastUpdated < frame.refresh_rate then
        return
    end

    frame.lastUpdated = t
    local dur = frame.expTime - t
    frame.remDuration = dur

    if C.bwtimeline.icons_duration then
        frame.durationText:SetText(formatDuration(dur))
    end

    local bar = frame.bar_
    local maxTime = bar.max_time or 0

    if dur <= maxTime then
        -- The actual positioning is handled in updateAnchors
        BWT:scheduleAnchorUpdate(bar)
    end

    if t > frame.expTime then
        BWT:removeFrame(frame)
    end
end

function BWT:createTimelineIcon(spellID, name, duration, iconID, customSettings)
    local frame = createIconFrame()
    local bar = self.bar

    frame.bar_ = bar
    frame.iconSettings = customSettings or C.bwtimeline.icons
    frame.name = name
    frame.spellID = spellID
    frame.size = frame.iconSettings.width or C.bwtimeline.icons_width
    frame.duration = duration
    frame.spawnTime = GetTime()
    frame.expTime = frame.spawnTime + duration
    frame.iconID = iconID
    frame.max_time = bar.max_time
    frame.anchored = true
    frame.lastUpdated = 0
    frame.refresh_rate = C.bwtimeline.refresh_rate

    self:updateFrameParameters(frame)

    tinsert(bar.frames, frame)
    if #bar.frames == 1 then
        self:updateTimelineBarVisibility()
    end
    self:scheduleAnchorUpdate(bar)

    frame:SetParent(bar)
    frame:SetFrameLevel(bar:GetFrameLevel() + 4)
    frame:SetScript("OnUpdate", frameOnUpdate)
    frame:SetTemplate("Icon")
    frame:Show()
end

----------------------------------------------------------------------------------------
--	Anchor and Position Management
----------------------------------------------------------------------------------------

local function compareExpTime(frame1, frame2)
    return frame1.expTime < frame2.expTime or (frame1.expTime == frame2.expTime and frame1.id < frame2.id)
end

function BWT:scheduleAnchorUpdate(bar)
    if not bar.pendingUpdate then
        bar.pendingUpdate = true
        C_Timer.After(0.01, function()
            bar.pendingUpdate = false
            self:updateAnchors(bar)
        end)
    end
end

function BWT:anchorQueuedIconToStart(frame)
    local bar = frame.bar_
    frame.pinned = true
    frame.anchored = true
    frame.anchor = bar
    frame.effectiveExpTime = frame.expTime
    frame:SetPoint("CENTER", bar, bar.startAnchor)
end

function BWT:setIconPosition(frame1, frame2, outOfSight)
    if outOfSight then
        frame1.anchored = true
        frame1.anchor = UIParent
        frame1.effectiveExpTime = frame1.expTime
        frame1:SetPoint("CENTER", UIParent, "CENTER", 0, 20000)
    elseif not frame2 then
        -- Position at the top of the bar
        frame1.anchored = true
        frame1.anchor = nil
        frame1.effectiveExpTime = frame1.expTime
        local bar = frame1.bar_
        frame1:SetPoint("TOP", bar, bar.startAnchor, 0, 0)  -- Position at the top of the bar
    else
        frame1.anchored = true
        frame1.anchor = frame2

        local bar = frame1.bar_
        local dist = frame1.size / 2 + frame2.size / 2 + C.bwtimeline.icons_spacing

        frame1:SetPoint("CENTER", frame2, "CENTER", dist * bar.x_mul, dist * bar.y_mul)

        frame1.effectiveExpTime = frame2.effectiveExpTime + dist / bar.lengthPerTime
    end
    frame1.pinned = false
end

function BWT:scheduleAnchorUpdate(bar)
    local t = GetTime()
    if bar.scheduledAnchorUpdate == t then
        return
    end
    bar.scheduledAnchorUpdate = t
    self:ScheduleTimer(self.updateAnchors, 0, self, bar)
end


function BWT:updateAnchors(bar)
    local frames = bar.frames
    local frameCount = #frames

    if frameCount == 0 then return end

    tsort(frames, compareExpTime)

    local lengthPerTime = bar.lengthPerTime
    local maxTime = bar.max_time or 0
    local currentTime = GetTime()
    local maxExp = currentTime + maxTime
    local iconSpacing = C.bwtimeline.icons_spacing

    local lastVisibleFrame = nil
    local lastVisiblePosition = 0
    local queuedIcons = {}

    for i = 1, frameCount do
        local frame = frames[i]
        local frameSize = frame.size or C.bwtimeline.icons_width

        if frame.expTime <= maxExp then
            -- Calculate the ideal position for the frame
            local idealPosition = (frame.expTime - currentTime) * lengthPerTime

            -- Check for overlap with the previous frame
            if lastVisibleFrame then
                local minDistance = (lastVisibleFrame.size + frameSize) / 2 + iconSpacing
                local actualDistance = idealPosition - lastVisiblePosition

                if actualDistance < minDistance then
                    -- Adjust the position to prevent overlap
                    idealPosition = lastVisiblePosition + minDistance
                end
            end

            -- Position the frame on the bar
            frame:SetPoint("CENTER", bar, bar.endAnchor, idealPosition * bar.x_mul, idealPosition * bar.y_mul)
            frame.anchored = true
            lastVisibleFrame = frame
            lastVisiblePosition = idealPosition
        else
            -- Queue icons exceeding max time
            tinsert(queuedIcons, frame)
        end
    end

    -- Position queued icons
    local queuedCount = #queuedIcons
    for i = 1, queuedCount do
        local frame = queuedIcons[i]
        local yOffset = (i - 1) * (frame.size + iconSpacing)
        frame:SetPoint("CENTER", bar, bar.startAnchor, 0, yOffset * bar.y_mul)
        frame.anchored = true
    end

    self:updateTimelineBarVisibility()
end

----------------------------------------------------------------------------------------
--	Icon Management Functions
----------------------------------------------------------------------------------------

function BWT:removeAllIcons()
    for i = #self.bar.frames, 1, -1 do
        self:removeFrame(self.bar.frames[i])
    end
    BWT:CancelAllTimers()
    BWT:updateTimelineBarVisibility()

    local t = GetTime()
    if self.bar.scheduledAnchorUpdate == t then
        self.bar.scheduledAnchorUpdate = 0
        self:scheduleAnchorUpdate(self.bar)
    end
end

function BWT:removeIconByName(name, all)
    if not name then
        return
    end
    local bar = self.bar
    for i = #bar.frames, 1, -1 do
        if bar.frames[i].name == name then
            self:removeFrame(bar.frames[i])
            if not all then
                break
            end
        end
    end
    self:scheduleAnchorUpdate(bar)
end

function BWT:removeIconByID(ID, all)
    if not ID then
        return
    end
    local bar = self.bar
    for i = #bar.frames, 1, -1 do
        if bar.frames[i].spellID == ID then
            self:removeFrame(bar.frames[i])
            if not all then
                break
            end
        end
    end
    self:scheduleAnchorUpdate(bar)
end

function BWT:removeIconFromBarByID(bar, ID, all)
    if not ID then
        return
    end
    local v = self.bar
    for i = #v.frames, 1, -1 do
        if v.frames[i].spellID == ID then
            self:removeFrame(v.frames[i])
            if not all then
                return
            end
        end
    end
end

function BWT:removeIconFromBarByName(bar, name, all)
    if not name then
        return
    end
    local v = self.bar
    for i = #v.frames, 1, -1 do
        if v.frames[i].name == name then
            self:removeFrame(v.frames[i])
            if not all then
                return
            end
        end
    end
end

----------------------------------------------------------------------------------------
--	Custom Timer Initialization
----------------------------------------------------------------------------------------

function BWT:initializeCustomTimers()
    if not self.engageID then
        return
    end
    local bossSettings = C.bwtimeline.bosses and C.bwtimeline.bosses[self.engageID]
    if not bossSettings then
        return
    end

    for _, extraKey in ipairs(bossSettings.__extras or {}) do
        local p = C.bwtimeline.icons

        if p then
            local icon
            if p.automaticIcon then
                icon = 134400
            end

            local prevTime = 0

            if p.customType == "Time" then
                for i, t in ipairs(p.customTimes) do
                    if i == 1 then
                        self:createTimelineIcon(extraKey, extraKey, t, icon, p)
                    else
                        BWT:ScheduleTimer(BWT.createTimelineIcon, prevTime, BWT, extraKey, extraKey, t - prevTime, icon, p)
                    end
                    prevTime = t
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------
--	Phase Management
----------------------------------------------------------------------------------------

function BWT:updatePhase(stage)
    if type(stage) == "string" then
        stage = getNumberAfterSpace(stage)
    end

    if type(stage) == "number" then
        self.phase = stage
        self.phaseCount = (self.phaseCount or 0) + 1  -- Use 0 as default if phaseCount is nil
    end
end

----------------------------------------------------------------------------------------
--	Visibility Management
----------------------------------------------------------------------------------------

function BWT:updateTimelineBarVisibility()
    local bar = self.bar
    if IsEncounterInProgress() or self.optionsOpened then
        bar:Show()
    elseif #bar.frames < 1 then
        bar:Hide()
    else
        bar:Show()
    end
end

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------

function BWT:OnInitialize()
    self.encounterID = nil
    self.phase = 1
    self.phaseCount = 0  -- Initialize phaseCount here
    self.bigWigs:registerAllMessages()

    self:updateTimelineBar()
end

----------------------------------------------------------------------------------------
--	BigWigs Integration
----------------------------------------------------------------------------------------

BWT.bigWigs = {}
local BW = BWT.bigWigs
LibStub("AceEvent-3.0"):Embed(BW)

function BW:registerAllMessages()
    local register = BigWigsLoader.RegisterMessage
    register(self, "BigWigs_StartBar", self.startBar)
    register(self, "BigWigs_StopBar", self.stopBar)
    register(self, "BigWigs_StopBars", self.stopBars)
    register(self, "BigWigs_OnBossDisable", self.onBossDisable)
    register(self, "BigWigs_SetStage", self.stage)
    register(self, "BigWigs_BarCreated", self.barCreated)
    register(self, "BigWigs_BarEmphasized", self.barCreated)
    register(self, "BigWigs_OnBossEngaged", self.onEncounterStart)
end

function BW:startBar(_, spellID, name, duration, icon)
    BWT:resetTimer(spellID, name, duration, icon)
end

function BW:stopBar(_, name)
    BWT:removeIconByName(name, true)
end

function BW:stopBars()
    BWT:removeAllIcons()
end

function BWT:resetTimer(spellID, name, duration, icon)
    self:removeIconByName(name, true)
    self:createTimelineIcon(spellID, name, duration, icon)
end

function BW:onBossDisable()
    BWT:removeAllIcons()
    BWT.phase = 1
    BWT.phaseCount = 0
end

function BW:barCreated(_, bar)
    if C.bwtimeline.BW_Alerts then
        bar:SetAlpha(0)
    else
        bar:Hide()
    end
    -- bar:Show()  -- Always show the bar for testing

end

function BW:stage(_, stage)
    if type(stage) == "string" then
        stage = tonumber(stage:match("%d+$"))
    end
    
    if type(stage) == "number" then
        BWT.phase = stage
        BWT.phaseCount = (BWT.phaseCount or 0) + 1  -- Use 0 as default if phaseCount is nil
    end
end

function BW:onEncounterStart(_, encounterID)
    BWT.encounterID = encounterID
    BWT.phase = 1
    BWT.phaseCount = 0  -- Ensure phaseCount is reset here
    BWT:initializeCustomTimers()
end

function BWT:InitializeBigWigs()
    self.bigWigs:registerAllMessages()
end