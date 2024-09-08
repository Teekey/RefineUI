local R, C, L = unpack(RefineUI)

-- Initialize database
RefineUIItems = RefineUIItems or {}

-- Frame for event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

-- Event handling function
local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == "RefineUI" then
        -- Initialize character data
        RefineUIItems[GetRealmName()] = RefineUIItems[GetRealmName()] or {}
        RefineUIItems[GetRealmName()][UnitName("player")] = RefineUIItems[GetRealmName()][UnitName("player")] or {
            faction = UnitFactionGroup("player"),
            class = select(2, UnitClass("player")),
            bags = {},
            bank = {},
            equipped = {}
        }
    elseif event == "PLAYER_ENTERING_WORLD" or event == "BAG_UPDATE" then
        R:UpdateBagCounts()
    elseif event == "BANKFRAME_OPENED" or event == "PLAYERBANKSLOTS_CHANGED" then
        R:UpdateBankCounts()
    end
end

frame:SetScript("OnEvent", OnEvent)

-- Function to update bag counts
function R:UpdateBagCounts()
    local realm = GetRealmName()
    local player = UnitName("player")
    
    -- Reset bag counts
    RefineUIItems[realm][player].bags = {}
    
    for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo and itemInfo.itemID then
                local count = itemInfo.stackCount or 1  -- Use stackCount if available, otherwise default to 1
                RefineUIItems[realm][player].bags[itemInfo.itemID] = (RefineUIItems[realm][player].bags[itemInfo.itemID] or 0) + count
            end
        end
    end
end

-- Function to update bank counts
function R:UpdateBankCounts()
    local realm = GetRealmName()
    local player = UnitName("player")
    
    -- Reset bank counts
    RefineUIItems[realm][player].bank = {}
    
    for slot = 1, NUM_BANKGENERIC_SLOTS do
        local itemID = GetInventoryItemID("player", slot + CONTAINER_BAG_OFFSET)
        if itemID then
            local count = GetInventoryItemCount("player", slot + CONTAINER_BAG_OFFSET) or 1
            RefineUIItems[realm][player].bank[itemID] = (RefineUIItems[realm][player].bank[itemID] or 0) + count
        end
    end
end

-- Function to get item counts across characters
local function GetItemCounts(itemID)
    local realm = GetRealmName()
    local currentPlayer = UnitName("player")
    local counts = {}
    
    for player, data in pairs(RefineUIItems[realm]) do
        if data.faction == UnitFactionGroup("player") then
            local bagCount = data.bags[itemID] or 0
            local bankCount = data.bank[itemID] or 0
            local equippedCount = data.equipped[itemID] or 0
            local total = bagCount + bankCount + equippedCount
            if total > 0 then
                local color = RAID_CLASS_COLORS[data.class].colorStr
                local name = player == currentPlayer and L["YOU"] or player
                counts[#counts + 1] = string.format("|c%s%s|r: %d", color, name, total)
            end
        end
    end
    
    return counts
end
-- Hook the GameTooltip
local function OnTooltipSetItem(tooltip, data)
    if tooltip ~= GameTooltip or tooltip:IsForbidden() then return end
    
    local itemID = data.id
    if not itemID then return end
    
    local counts = GetItemCounts(itemID)
    if #counts > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine(L["ITEM_COUNT"])
        for _, count in ipairs(counts) do
            tooltip:AddLine(count)
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)