local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
-- Upvalues
----------------------------------------------------------------------------------------
local IsShiftKeyDown = IsShiftKeyDown
local C_Timer = C_Timer

----------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------
local SCROLL_LINES = 1
local AUTO_SCROLL_DELAY = 15 -- seconds

----------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------
local autoScrollTimers = {}

----------------------------------------------------------------------------------------
-- Chat Scroll Module
----------------------------------------------------------------------------------------

--- Handles mouse scroll events for floating chat frames
-- @param self The chat frame being scrolled
-- @param delta The scroll direction and magnitude
local function FloatingChatFrame_OnMouseScroll(self, delta)
    -- Cancel any existing auto-scroll timer for this frame
    if autoScrollTimers[self] then
        autoScrollTimers[self]:Cancel()
    end

    if delta < 0 then
        -- Scroll down
        if IsShiftKeyDown() then
            -- Shift + Scroll Down: Jump to bottom
            self:ScrollToBottom()
        else
            -- Normal Scroll Down: Scroll by SCROLL_LINES
            for _ = 1, SCROLL_LINES do
                self:ScrollDown()
            end
        end
    elseif delta > 0 then
        -- Scroll up
        if IsShiftKeyDown() then
            -- Shift + Scroll Up: Jump to top
            self:ScrollToTop()
        else
            -- Normal Scroll Up: Scroll by SCROLL_LINES
            for _ = 1, SCROLL_LINES do
                self:ScrollUp()
            end
        end
    end

    -- Set a new auto-scroll timer
    autoScrollTimers[self] = C_Timer.NewTimer(AUTO_SCROLL_DELAY, function()
        self:ScrollToBottom()
        autoScrollTimers[self] = nil
    end)
end

--- Initializes auto-scroll functionality for a chat frame
-- @param chatFrame The chat frame to initialize
local function InitializeAutoScroll(chatFrame)
    chatFrame:HookScript("OnHyperlinkClick", function(self)
        -- Cancel any existing auto-scroll timer when clicking a hyperlink
        if autoScrollTimers[self] then
            autoScrollTimers[self]:Cancel()
            autoScrollTimers[self] = nil
        end
    end)
end
