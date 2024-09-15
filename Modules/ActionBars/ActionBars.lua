local R, C, L = unpack(RefineUI)
local _G = _G

-- Localize frequently used functions
local CreateFrame, hooksecurefunc, pairs, ipairs = CreateFrame, hooksecurefunc, pairs, ipairs

local function StyleButton(button)
    if button.isSkinned then return end

    button:SetTemplate("Zero")

    local name = button:GetName()
    local icon = _G[name .. "Icon"]
    local count = _G[name .. "Count"]
    local cooldown = _G[name .. "Cooldown"]

    -- Create border cooldown effect
    local borderCooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    borderCooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CD.blp")
    borderCooldown:SetDrawEdge(false)
    borderCooldown:SetDrawSwipe(true)
    borderCooldown:SetReverse(false)
    borderCooldown:SetSwipeColor(0, 0, 0, 0.5)
    borderCooldown:SetAllPoints(button)
    borderCooldown:SetFrameLevel(button:GetFrameLevel() + 1)

    -- Set up the icon
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", -2, 2)

    -- Ensure count is on top
    count:SetParent(button)
	count:SetJustifyH("RIGHT")
    count:SetPoint("BOTTOMRIGHT", -3, 3)
    count:SetDrawLayer("OVERLAY", 1)

    -- Hook the SetCooldown function
    hooksecurefunc(cooldown, "SetCooldown", function(self, start, duration)
        borderCooldown:SetCooldown(start, duration)
    end)

    button.isSkinned = true
end

local function StyleButtons(buttonNames, count)
    for _, name in ipairs(buttonNames) do
        for i = 1, count do
            local button = _G[name .. i]
            if button then StyleButton(button) end
        end
    end
end

local function SetupActionBars()
    if InCombatLockdown() then return end

    local buttonGroups = {
        { names = {
            "ActionButton", "MultiBarBottomLeftButton", "MultiBarLeftButton",
            "MultiBarRightButton", "MultiBarBottomRightButton", "MultiBar5Button",
            "MultiBar6Button", "MultiBar7Button"
        }, count = 12 },
        { names = {"PetActionButton"}, count = NUM_PET_ACTION_SLOTS },
        { names = {"StanceButton"}, count = 10 },
        { names = {"OverrideActionBarButton"}, count = NUM_OVERRIDE_BUTTONS },
    }

    for _, group in ipairs(buttonGroups) do
        StyleButtons(group.names, group.count)
    end

    StyleButton(ExtraActionButton1)
end

local function SetupHotkeys()
    if not C.actionbars.hotkey then return end

    local patterns = {
        ["Middle Mouse"] = "M3", ["Mouse Wheel Down"] = "WD", ["Mouse Wheel Up"] = "WU",
        ["Mouse Button "] = "M", ["Num Pad "] = "N", ["Spacebar"] = "SB",
        ["Capslock"] = "CL", ["Num Lock"] = "NL", ["a%-"] = "A", ["c%-"] = "C", ["s%-"] = "S",
    }

    local function UpdateHotkey(self)
        local hotkey = self.HotKey
        local text = hotkey:GetText()
        for k, v in pairs(patterns) do
            text = text:gsub(k, v)
        end
        hotkey:SetText(text)
        hotkey:SetTextColor(unpack(C.media.borderColor))
        hotkey:SetFont(unpack(C.font.actionbars.hotkey))
    end

    local buttons = {
        "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
        "MultiBarLeftButton", "MultiBarRightButton", "MultiBar5Button",
        "MultiBar6Button", "MultiBar7Button",
    }

    for _, btn in pairs(buttons) do
        for i = 1, NUM_ACTIONBAR_BUTTONS do
            local button = _G[btn .. i]
            hooksecurefunc(button, "UpdateHotkeys", UpdateHotkey)
        end
    end
end

local function HideButtonText()
    if C.actionbars.hotkey then return end

    local function HideText(button)
        for _, textType in ipairs({"HotKey", "Name"}) do
            local text = _G[button .. textType]
            if text then
                text:Hide()
                text.Show = function() end
            end
        end
    end

    local bars = {"Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"}
    for _, bar in ipairs(bars) do
        for i = 1, 12 do
            local btn = bar .. "Button" .. i
            if _G[btn] then HideText(btn) end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_UPDATE_STATE" then
        SetupActionBars()
    elseif event == "ADDON_LOADED" and arg1 == "RefineUI" then
        SetupHotkeys()
        HideButtonText()
    end
end)

-- Hide extra styles
ExtraActionButton1.style:SetAlpha(0)
ExtraActionButton1.style:Hide()
ZoneAbilityFrame.Style:SetAlpha(0)
ZoneAbilityFrame.Style:Hide()