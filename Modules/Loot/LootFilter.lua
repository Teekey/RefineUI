----------------------------------------------------------------------------------------
--	LootFilter for TKUI
--	This module provides selective auto-looting functionality for World of Warcraft.
--	It filters loot based on various criteria including item quality, price, and type.
--	Based on Ghuul Addons: Selective Autoloot v1.7.2
----------------------------------------------------------------------------------------

local R, C, L = unpack(RefineUI)
if C.lootfilter.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Constants and Variables
----------------------------------------------------------------------------------------

local LootFilter = CreateFrame("Frame")

local LootableSlots = {}
local GetItemInfo = C_Item.GetItemInfo
local GetDetailedItemLevelInfo = C_Item.GetDetailedItemLevelInfo
local EventList = { "PLAYER_LOGIN", "LOOT_READY", "LOOT_OPENED", "LOOT_CLOSED" }
local ItemCount, PlayerClass
local GetItemIcon = C_Item.GetItemIconByID
local tinsert, wipe, select, tonumber, pairs = table.insert, wipe, select, tonumber, pairs
local GetLootSlotType, GetLootSlotLink, GetLootSlotInfo = GetLootSlotType, GetLootSlotLink, GetLootSlotInfo
local GetNumLootItems, LootSlot, CloseLoot = GetNumLootItems, LootSlot, CloseLoot
local print, format = print, string.format
local C_TransmogCollection = C_TransmogCollection
local C_Item = C_Item

----------------------------------------------------------------------------------------
--	Item Metatable
----------------------------------------------------------------------------------------

local ItemMetatable = {
    __index = function(t, k)
        return rawget(t, k) or nil
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
}
setmetatable(Item, ItemMetatable)

----------------------------------------------------------------------------------------
--	Utility Functions
----------------------------------------------------------------------------------------

local function GoldToCopper(gold)
    return math.floor(gold * 10000) -- 1 gold = 100 silver = 10000 copper
end

local itemIDPattern = "item:(%d+)"
local function GetItemIDFromLink(link)
    return link and tonumber(link:match(itemIDPattern))
end

----------------------------------------------------------------------------------------
--	Custom Filter Functions
----------------------------------------------------------------------------------------

local function SaveCustomFilters()
    TKUILootFilter = TKUILootFilter or {}
    wipe(TKUILootFilter)
    for itemID, value in pairs(R.LootFilterCustom) do
        TKUILootFilter[itemID] = value
    end
end

local function AddToCustomFilter(input)
    local itemID = tonumber(input) or GetItemIDFromLink(input)
    if not itemID then
        print("Invalid input. Please use an item ID or item link.")
        return
    end
    local itemName, itemLink = GetItemInfo(itemID)
    if itemName then
        R.LootFilterCustom[itemID] = true
        SaveCustomFilters() -- Save changes
        print(string.format("Added %s to custom exclusion list. This item will not be looted.", itemLink or itemName))
    else
        print("Invalid item. Item not found.")
    end
end

local function RemoveFromCustomFilter(input)
    local itemID = tonumber(input) or GetItemIDFromLink(input)
    if not itemID then
        print("Invalid input. Please use an item ID or item link.")
        return
    end
    if R.LootFilterCustom[itemID] then
        local itemName, itemLink = GetItemInfo(itemID)
        R.LootFilterCustom[itemID] = nil
        SaveCustomFilters() -- Save changes
        print(string.format("Removed %s from custom exclusion list. This item can now be looted.",
            itemLink or itemName or "Unknown Item"))
    else
        print("Item not found in custom exclusion list.")
    end
end

local function ClearCustomFilter()
    wipe(R.LootFilterCustom)
    wipe(TKUILootFilter)
    print("Cleared all items from the custom exclusion list.")
end

local function ListCustomFilter()
    print("Custom Exclusion List (items that will not be looted):")
    local count = 0
    for itemID in pairs(R.LootFilterCustom) do
        local itemName, itemLink = GetItemInfo(itemID)
        print(string.format("- %s", itemLink or itemName or string.format("Unknown Item (ID: %d)", itemID)))
        count = count + 1
    end
    if count == 0 then
        print("The custom exclusion list is empty.")
    end
end

----------------------------------------------------------------------------------------
--	Transmog Data
----------------------------------------------------------------------------------------

local Transmog = {
    ["DRUID"] = { ["Armor"] = { 2, 5 }, ["Weapons"] = { 4, 5, 6, 10, 13, 15 } },
    ["DEATHKNIGHT"] = { ["Armor"] = { 4, 5 }, ["Weapons"] = { 0, 1, 4, 5, 6, 7, 8 } },
    ["DEMONHUNTER"] = { ["Armor"] = { 2, 5 }, ["Weapons"] = { 0, 7, 9, 13 } },
    ["HUNTER"] = { ["Armor"] = { 3, 5 }, ["Weapons"] = { 0, 1, 2, 3, 6, 7, 8, 10, 13, 15, 18 } },
    ["MAGE"] = { ["Armor"] = { 1, 5 }, ["Weapons"] = { 7, 10, 15, 19 } },
    ["MONK"] = { ["Armor"] = { 2, 5 }, ["Weapons"] = { 0, 4, 6, 7, 10, 13 } },
    ["PALADIN"] = { ["Armor"] = { 4, 5, 6 }, ["Weapons"] = { 0, 1, 4, 5, 6, 7, 8 } },
    ["PRIEST"] = { ["Armor"] = { 1, 5 }, ["Weapons"] = { 4, 10, 15, 19 } },
    ["ROGUE"] = { ["Armor"] = { 2, 5 }, ["Weapons"] = { 0, 2, 3, 4, 7, 13, 15, 16 } },
    ["SHAMAN"] = { ["Armor"] = { 3, 5, 6 }, ["Weapons"] = { 0, 1, 4, 5, 10, 13, 15 } },
    ["WARLOCK"] = { ["Armor"] = { 1, 5 }, ["Weapons"] = { 4, 10, 15, 19 } },
    ["WARRIOR"] = { ["Armor"] = { 4, 5, 6 }, ["Weapons"] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16, 18 } },
    ["EVOKER"] = { ["Armor"] = { 3, 5 }, ["Weapons"] = { 0, 4, 7, 10, 13, 15 } }
}

----------------------------------------------------------------------------------------
--	Main Loot Filter Logic
----------------------------------------------------------------------------------------
for e = 1, #EventList do LootFilter:RegisterEvent(EventList[e]) end

local function AddLootableSlot(slot)
    tinsert(LootableSlots, slot)
end

local function LootFilteredItems()
    for i = 1, #LootableSlots do
        LootSlot(LootableSlots[i])
    end
    CloseLoot()
end

local function ShouldLootItem()
    local itemID = GetItemIDFromLink(Item["Link"])

    -- Check if the item is in any of the filter lists (should be ignored)
    if R.LootFilterItems[itemID] or R.LootFilterCustom[itemID] then
        return false -- Do not loot items in these lists
    end

    -- Check if the item meets the minimum quality threshold
    if Item["Quality"] >= C.lootfilter.min_quality then
        return true
    end

    -- Check if the item's vendor price meets the override threshold
    local vendorPrice = Item["Price"] or 0
    if vendorPrice >= (GoldToCopper(C.lootfilter.gear_price_override)) then -- Convert gold to copper
        return true
    end

    -- Check for tier tokens
    if Item["Type"] == "Miscellaneous" and Item["Subtype"] == "Junk" and Item["Quality"] >= 3 then
        return true
    end

    -- Is the item used for Enchanting?
    if Item["Type"] == "Tradeskill" and Item["Subtype"] == "Enchanting" then
        return true
    end

    -- Analyze fishing loot:
    if IsFishingLoot() then
        return (Item["Type"] == "Tradeskill" and Item["Subtype"] == "Cooking")
            or (Item["Quality"] == 0 and Item["Price"] >= GoldToCopper(C.lootfilter.junk_minprice))
    end

    -- Tradeskill reagent - check the subtype and rarity of the item:
    if Item["Type"] == "Tradeskill" and tContains(C.lootfilter.tradeskill_subtypes, Item["Subtype"]) then
        return Item["Quality"] >= C.lootfilter.tradeskill_min_quality
    end

    -- Armor/weapon - check all the required parameters:
    if (Item["Type"] == "Weapon" or Item["Type"] == "Armor") then
        -- Check if the transmog appearance is usable:
        local isUsableTransmog = Item["EquipSlot"] == "INVTYPE_CLOAK" or
            (Item["Type"] == "Weapon" and tContains(Transmog[PlayerClass]["Weapons"], Item["SubtypeID"])) or
            (Item["Type"] == "Armor" and tContains(Transmog[PlayerClass]["Armor"], Item["SubtypeID"]))

        if isUsableTransmog then
            -- Check if the appearance is known for the entire account
            local sourceID = select(2, C_TransmogCollection.GetItemInfo(Item["Link"]))
            if sourceID then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                -- If it's an unknown appearance and we're looting unknown appearances, loot it
                if C.lootfilter.gear_unknown and not sourceInfo.isCollected then
                    return true
                end
            end
        end

        -- Check if it meets the quality criteria
        if Item["Quality"] >= C.lootfilter.gear_min_quality then
            return true
        end
    end

    -- Item does not fit any of the operations above, do not loot!
    return false
end

local function ProcessLoot()
    for i = ItemCount, 1, -1 do
        -- Get some basic info about the current item:
        local SlotType = GetLootSlotType(i)
        Item["Link"] = GetLootSlotLink(i)
        _, Item["Name"], _, _, Item["Quality"], Locked, QuestItem = GetLootSlotInfo(i)

        -- Check if CreateFromBagAndSlot is available
        if C_Item.CreateFromBagAndSlot then
            Item["Expansion"] = 0
            if SlotType ~= 3 and SlotType ~= 2 and not QuestItem then
                -- Fetch additional required info about the item:
                Item["Type"], Item["Subtype"], _, Item["EquipSlot"], _, Item["Price"], _, Item["SubtypeID"],
                Item["Bind"], Item["Expansion"] = select(6, GetItemInfo(Item["Link"]))
                if Item["Expansion"] == nil then Item["Expansion"] = 0 end
            end

            -- Get the item icon
            local iconString = ""
            if Item["Link"] then
                local itemID = GetItemIDFromLink(Item["Link"])
                if itemID then
                    local iconTexture = GetItemIcon(itemID)
                    iconString = iconTexture and ("|T" .. iconTexture .. ":t ") or ""
                end
            end

            -- Check if the item is locked or should be ignored:
            if not Locked then
                local itemID = GetItemIDFromLink(Item["Link"])
                if R.LootFilterItems[itemID] then
                    print("|cFFFFD200Filtered:|r " .. iconString .. (Item["Link"] or "Unknown Item") .. " (Ignored item)")
                elseif SlotType == 3 and R.LootFilterCurrency[itemID] then
                    print("|cFFFFD200Filtered:|r " ..
                        iconString .. (Item["Link"] or "Unknown Currency") .. " (Ignored currency)")
                elseif QuestItem then
                    -- Always loot quest items
                    AddLootableSlot(i)
                elseif SlotType == 2 or SlotType == 3 then
                    -- Always loot currency (including gold)
                    AddLootableSlot(i)
                elseif Item["Quality"] == 0 and not IsFishingLoot() then
                    Item["Price"] = select(11, GetItemInfo(Item["Link"]))
                    if Item["Price"] < GoldToCopper(C.lootfilter.junk_minprice) then
                        print("|cFFFFD200Filtered:|r " ..
                            iconString .. (Item["Link"] or "Unknown Junk Item") .. " (Below junk min price)")
                    else
                        AddLootableSlot(i)
                    end
                elseif ShouldLootItem() then
                    AddLootableSlot(i)
                else
                    print("|cFFFFD200Filtered:|r " ..
                        iconString .. (Item["Link"] or "Unknown Item") .. " (Does not meet loot criteria)")
                end
            end
        else
            print("Warning: CreateFromBagAndSlot is not available. Using fallback logic.")
            -- Implement fallback logic here if necessary
            -- For example, you can skip processing or handle items differently
        end
        -- Clear the current item:
        wipe(Item)
    end
    CloseLoot()
end
----------------------------------------------------------------------------------------
--	Event Handlers
----------------------------------------------------------------------------------------
local eventHandlers = {
    PLAYER_LOGIN = function()
        PlayerClass = select(2, UnitClass("player"))
    end,
    LOOT_READY = function()
        ItemCount = GetNumLootItems()
        if ItemCount > 0 then ProcessLoot() end
    end,
    LOOT_OPENED = function()
        if #LootableSlots > 0 then LootFilteredItems() end
    end,
    LOOT_CLOSED = function()
        ItemCount = 0
        wipe(LootableSlots)
    end
}

LootFilter:SetScript("OnEvent", function(_, event)
    local handler = eventHandlers[event]
    if handler then handler() end
end)

----------------------------------------------------------------------------------------
--	Slash Commands
----------------------------------------------------------------------------------------
SLASH_LOOTFILTER1 = "/lootfilter"
SLASH_LOOTFILTER2 = "/lf"
SlashCmdList["LOOTFILTER"] = function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()

    if command == "add" then
        if rest ~= "" then
            AddToCustomFilter(rest)
        else
            print("Usage: /lf add [itemID or item link]")
        end
    elseif command == "remove" then
        if rest ~= "" then
            RemoveFromCustomFilter(rest)
        else
            print("Usage: /lf remove [itemID or item link]")
        end
    elseif command == "list" then
        ListCustomFilter()
    elseif command == "clear" then
        ClearCustomFilter()
    else
        print("|cFFFFD200Loot Filter Commands:|r")
        print("|cFFFFD200/lf add [itemID or item link]|r - Add an item to the custom filter")
        print("|cFFFFD200/lf remove [itemID or item link]|r - Remove an item from the custom filter")
        print("|cFFFFD200/lf list|r - List all items in the custom filter")
        print("|cFFFFD200/lf clear|r - Clear all items from the custom filter")
    end
end

----------------------------------------------------------------------------------------
--	Initialization
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        TKUILootFilter = TKUILootFilter or {}
        -- Re-merge saved filters in case they weren't available when this file first loaded
        for itemID, value in pairs(TKUILootFilter) do
            R.LootFilterCustom[itemID] = value
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)
