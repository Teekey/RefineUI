----------------------------------------------------------------------------------------
--	AutoItemBar Module for RefineUI
--	This module creates an automatic item bar for consumables,
--	with mouseover functionality and dynamic updating.
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)
if not C.autoitembar.enable then return end
----------------------------------------------------------------------------------------
--	Constants
----------------------------------------------------------------------------------------
local BUTTON_SIZE = C.autoitembar.buttonSize
local BUTTON_SPACING = C.autoitembar.buttonSpace
local BUTTONS_PER_ROW = 12

local frameWidth = BUTTONS_PER_ROW * (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING
local frameHeight = (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING

----------------------------------------------------------------------------------------
--	Frame Creation
----------------------------------------------------------------------------------------

-- Create a frame to hold our consumable buttons
local ConsumableButtonsFrame = CreateFrame("Frame", "RefineUI_AutoItemBar", UIParent, "BackdropTemplate")
ConsumableButtonsFrame:SetPoint(unpack(C.position.autoitembar))
ConsumableButtonsFrame:SetSize(frameWidth, frameHeight)

local ConsumableBarParent = CreateFrame("Frame", "ConsumableBarParent", UIParent)
ConsumableBarParent:SetPoint(unpack(C.position.autoitembar))
ConsumableBarParent:SetSize(frameWidth, frameHeight + 10) -- Add some extra height for mouseover area
ConsumableBarParent:SetFrameLevel(ConsumableButtonsFrame:GetFrameLevel() + 1)

----------------------------------------------------------------------------------------
--	Local Variables
----------------------------------------------------------------------------------------
C.autoitembar = C.autoitembar or {}
local consumableButtons = {}
local currentConsumables = {}

----------------------------------------------------------------------------------------
--	Helper Functions
---------------------------------------------------------- ------------------------------
local function isConsumable(itemID)
    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType = GetItemInfo(itemID)
    if not itemName then return false end
    
    -- Check if the item meets the minimum level requirement
    if itemLevel < C.autoitembar.min_consumable_item_level then return false end
    
    return (itemType == "Consumable" or itemType == "ItemEnhancement") and
        (itemSubType == "Potions" or itemSubType == "Flasks & Phials" or itemSubType == "Food & Drink" or string.find(itemName, "Rune"))
end

local function ShowBar()
    ConsumableButtonsFrame:SetAlpha(1)
end

local function HideBar()
    if C.autoitembar.consumable_mouseover then
        ConsumableButtonsFrame:SetAlpha(0)
    end
end

local function UpdateBarVisibility()
    if C.autoitembar.consumable_mouseover then
        ConsumableButtonsFrame:SetAlpha(0)
    else
        ConsumableButtonsFrame:SetAlpha(1)
    end
end

----------------------------------------------------------------------------------------
--	Button Creation and Management
----------------------------------------------------------------------------------------
local function createConsumableButton(itemID, index)
    local itemName = C_Item.GetItemInfo(itemID)
    local button = CreateFrame("Button", "ConsumableButton" .. index, ConsumableButtonsFrame, "SecureActionButtonTemplate")
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    
    -- Calculate button position
    local row = math.floor((index - 1) / BUTTONS_PER_ROW)
    local col = (index - 1) % BUTTONS_PER_ROW
    local xOffset = col * (BUTTON_SIZE + BUTTON_SPACING)
    local yOffset = -row * (BUTTON_SIZE + BUTTON_SPACING)

    button:SetPoint("TOPLEFT", xOffset, yOffset)
    button:SetFrameStrata("HIGH")
    button:SetTemplate("Default")
    button.border:SetFrameStrata("HIGH")
    button:StyleButton(true)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type1", "item")
    button:SetAttribute("item1", itemName)
    button:SetAttribute("type2", "item")
    button:SetAttribute("item2", itemName)

    -- Create button textures and fonts
    button.t = button:CreateTexture(nil, "BORDER")
    button.t:SetPoint("TOPLEFT", 2, -2)
    button.t:SetPoint("BOTTOMRIGHT", -2, 2)
    button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.t:SetTexture(C_Item.GetItemIconByID(itemID))

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetFont(unpack(C.font.actionBars))
    button.count:SetShadowOffset(1, -1)
    button.count:SetPoint("BOTTOMRIGHT", -1, 3)
    button.count:SetJustifyH("RIGHT")

    button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    button.cd:SetAllPoints(button.t)
    button.cd:SetFrameLevel(1)

    button.itemID = itemID

    -- Set up scripts for mouseover functionality
    button:SetScript("OnEnter", function(self)
        ShowBar()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(format("item:%s", self.itemID))
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip_Hide()
        C_Timer.After(0.1, function()
            if not ConsumableBarParent:IsMouseOver() and not ConsumableButtonsFrame:IsMouseOver() then
                HideBar()
            end
        end)
    end)

    return button
end

local function sortConsumables(a, b)
    local _, _, _, _, _, typeA, subtypeA = C_Item.GetItemInfo(a)
    local _, _, _, _, _, typeB, subtypeB = C_Item.GetItemInfo(b)
    
    if typeA == typeB then
        if subtypeA == subtypeB then
            return a < b  -- If type and subtype are the same, sort by itemID
        else
            return subtypeA < subtypeB
        end
    else
        return typeA < typeB
    end
end

local function updateConsumableButtons()
    wipe(currentConsumables)
    local consumableCount = {}
    local sortedConsumables = {}

    -- Scan bags for consumables
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID and isConsumable(itemID) then
                if not currentConsumables[itemID] then
                    table.insert(sortedConsumables, itemID)
                end
                currentConsumables[itemID] = true

                local info = C_Container.GetContainerItemInfo(bag, slot)
                local count = info and info.stackCount or 0
                consumableCount[itemID] = (consumableCount[itemID] or 0) + count
            end
        end
    end

    -- Sort the consumables
    table.sort(sortedConsumables, sortConsumables)

    -- Create or update buttons based on the sorted list
    for index, itemID in ipairs(sortedConsumables) do
        if not consumableButtons[itemID] then
            consumableButtons[itemID] = createConsumableButton(itemID, index)
        end

        local button = consumableButtons[itemID]
        
        -- Update button position
        local row = math.floor((index - 1) / BUTTONS_PER_ROW)
        local col = (index - 1) % BUTTONS_PER_ROW
        local xOffset = col * (BUTTON_SIZE + BUTTON_SPACING)
        local yOffset = -row * (BUTTON_SIZE + BUTTON_SPACING)
        if not InCombatLockdown() then
            button:SetPoint("TOPLEFT", xOffset, yOffset)
            button:Show()
        end
        
        -- Update count and cooldown
        button.count:SetText(consumableCount[itemID] and consumableCount[itemID] > 1 and consumableCount[itemID] or "")
        local start, duration, enable = GetItemCooldown(itemID)
        CooldownFrame_Set(button.cd, start, duration, enable)
    end

    -- Hide buttons for consumables no longer in bags
    for itemID, button in pairs(consumableButtons) do
        if not currentConsumables[itemID] and not InCombatLockdown() then
            button:Hide()
        end
    end

    -- Update frame size
    local rows = math.ceil(#sortedConsumables / BUTTONS_PER_ROW)
    local newHeight = rows * (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING
    if not InCombatLockdown() then
        ConsumableButtonsFrame:SetSize(frameWidth, newHeight)
        ConsumableBarParent:SetSize(frameWidth, newHeight + 10) -- Update parent frame size
    end

    -- Update mouseover behavior for all buttons
    for _, button in pairs(consumableButtons) do
        button:SetScript("OnEnter", function(self)
            ShowBar()
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetHyperlink(format("item:%s", self.itemID))
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function()
            GameTooltip_Hide()
            C_Timer.After(0.1, function()
                if not ConsumableBarParent:IsMouseOver() and not ConsumableButtonsFrame:IsMouseOver() then
                    HideBar()
                end
            end)
        end)
    end
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
local Scanner = CreateFrame("Frame")
Scanner:RegisterEvent("BAG_UPDATE")
Scanner:RegisterEvent("PLAYER_ENTERING_WORLD")
Scanner:SetScript("OnEvent", function()
    updateConsumableButtons()
    UpdateBarVisibility()
end)

-- Register for UNIT_INVENTORY_CHANGED event
local InventoryScanner = CreateFrame("Frame")
InventoryScanner:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
InventoryScanner:SetScript("OnEvent", function(self, event, unit)
    if unit == "player" then
        updateConsumableButtons()
    end
end)

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------
-- Force an update when the script loads
C_Timer.After(1, function()
    updateConsumableButtons()
    UpdateBarVisibility()
end)

-- Set up mouseover functionality
ConsumableBarParent:SetScript("OnEnter", ShowBar)
ConsumableBarParent:SetScript("OnLeave", HideBar)