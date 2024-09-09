local addonName, RefineUI = ...
local R, C, L = unpack(RefineUI)
if not C.lootfilter or C.lootfilter.enable ~= true then return end

----------------------------------------------------------------------------------------
--  LootFilter for RefineUI
--  This module provides selective auto-looting functionality for World of Warcraft.
--  It filters loot based on various criteria including item quality, price, and type.
--  Based on Ghuul Addons: Selective Autoloot v1.7.2
----------------------------------------------------------------------------------------

local LootFilter = CreateFrame("Frame")
LootFilter:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

local LootableSlots = {}
local PlayerClass

-- Localize global functions for performance
local GetItemInfo, GetDetailedItemLevelInfo = C_Item.GetItemInfo, C_Item.GetDetailedItemLevelInfo
local GetItemIcon = C_Item.GetItemIconByID
local tinsert, wipe, select, tonumber, pairs = table.insert, table.wipe, select, tonumber, pairs
local GetLootSlotType, GetLootSlotLink, GetLootSlotInfo = GetLootSlotType, GetLootSlotLink, GetLootSlotInfo
local GetNumLootItems, LootSlot, CloseLoot = GetNumLootItems, LootSlot, CloseLoot
local print, format = print, string.format

-- Local utility functions
local function GoldToCopper(gold)
    return math.floor(gold * 10000)
end

local itemIDPattern = "item:(%d+)"
local function GetItemIDFromLink(link)
    return link and tonumber(link:match(itemIDPattern))
end

-- Local item cache
local ItemCache = setmetatable({}, {__mode = "v"})

local function GetItemDetails(link)
    if not link then return nil end
    local itemID = GetItemIDFromLink(link)
    if not itemID then return nil end

    if not ItemCache[itemID] then
        local itemName, _, itemQuality, _, _, itemType, itemSubType, _, itemEquipLoc, _, itemPrice, _, itemSubTypeID, itemBindType, itemExpansion = GetItemInfo(link)
        if not itemName then return nil end -- Item info not available

        ItemCache[itemID] = {
            Name = itemName,
            Quality = itemQuality,
            Type = itemType,
            Subtype = itemSubType,
            EquipSlot = itemEquipLoc,
            Price = itemPrice,
            SubtypeID = itemSubTypeID,
            Bind = itemBindType,
            Expansion = itemExpansion or 0
        }
    end

    return ItemCache[itemID]
end

-- Transmog data (unchanged)
local Transmog = {
    -- ... (keep the existing Transmog table)
}

-- Main loot filter logic
local function ShouldLootItem(itemDetails, isFishingLoot)
    if not itemDetails then return false end

    local itemID = GetItemIDFromLink(itemDetails.Link)

    -- Check filter lists
    if R.LootFilterItems[itemID] or R.LootFilterCustom[itemID] then
        return false
    end

    -- Quality threshold
    if itemDetails.Quality >= C.lootfilter.min_quality then
        return true
    end

    -- Vendor price override
    if (itemDetails.Price or 0) >= GoldToCopper(C.lootfilter.gear_price_override) then
        return true
    end

    -- Tier tokens
    if itemDetails.Type == "Miscellaneous" and itemDetails.Subtype == "Junk" and itemDetails.Quality >= 3 then
        return true
    end

    -- Enchanting materials
    if itemDetails.Type == "Tradeskill" and itemDetails.Subtype == "Enchanting" then
        return true
    end

    -- Fishing loot
    if isFishingLoot then
        return (itemDetails.Type == "Tradeskill" and itemDetails.Subtype == "Cooking")
            or (itemDetails.Quality == 0 and (itemDetails.Price or 0) >= GoldToCopper(C.lootfilter.junk_minprice))
    end

    -- Tradeskill reagents
    if itemDetails.Type == "Tradeskill" and tContains(C.lootfilter.tradeskill_subtypes, itemDetails.Subtype) then
        return itemDetails.Quality >= C.lootfilter.tradeskill_min_quality
    end

    -- Armor/weapon
    if itemDetails.Type == "Weapon" or itemDetails.Type == "Armor" then
        local isUsableTransmog = itemDetails.EquipSlot == "INVTYPE_CLOAK" or
            (itemDetails.Type == "Weapon" and tContains(Transmog[PlayerClass]["Weapons"], itemDetails.SubtypeID)) or
            (itemDetails.Type == "Armor" and tContains(Transmog[PlayerClass]["Armor"], itemDetails.SubtypeID))

        if isUsableTransmog then
            local sourceID = select(2, C_TransmogCollection.GetItemInfo(itemDetails.Link))
            if sourceID then
                local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
                if C.lootfilter.gear_unknown and not sourceInfo.isCollected then
                    return true
                end
            end
        end

        if itemDetails.Quality >= C.lootfilter.gear_min_quality then
            return true
        end
    end

    return false
end

local function ProcessLoot()
    local numItems = GetNumLootItems()
    for i = numItems, 1, -1 do
        local slotType = GetLootSlotType(i)
        local link = GetLootSlotLink(i)
        local _, _, _, _, _, locked, isQuestItem = GetLootSlotInfo(i)

        if not locked then
            local itemDetails = GetItemDetails(link)
            if itemDetails then
                itemDetails.Link = link
            end

            local itemID = GetItemIDFromLink(link)
            local iconString = itemID and ("|T" .. (GetItemIcon(itemID) or "") .. ":0|t ") or ""

            if R.LootFilterItems[itemID] then
                print("|cFFFFD200Filtered:|r " .. iconString .. (link or "Unknown Item") .. " (Ignored item)")
            elseif slotType == 3 and R.LootFilterCurrency[itemID] then
                print("|cFFFFD200Filtered:|r " .. iconString .. (link or "Unknown Currency") .. " (Ignored currency)")
            elseif isQuestItem or slotType == 2 or slotType == 3 then
                tinsert(LootableSlots, i)
            elseif itemDetails and itemDetails.Quality == 0 and not IsFishingLoot() then
                if (itemDetails.Price or 0) < GoldToCopper(C.lootfilter.junk_minprice) then
                    print(format("|cFFFFD200Filtered:|r %s%s (Below junk min price)", iconString, link or "Unknown Junk Item"))
                else
                    tinsert(LootableSlots, i)
                end
            elseif ShouldLootItem(itemDetails, IsFishingLoot()) then
                tinsert(LootableSlots, i)
            else
                print("|cFFFFD200Filtered:|r " .. iconString .. (link or "Unknown Item") .. " (Does not meet loot criteria)")
            end
        end
    end
end

-- Event handlers
function LootFilter:PLAYER_LOGIN()
    PlayerClass = select(2, UnitClass("player"))
    self:UnregisterEvent("PLAYER_LOGIN")
end

function LootFilter:LOOT_READY()
    wipe(LootableSlots)
    ProcessLoot()
end

function LootFilter:LOOT_OPENED()
    if #LootableSlots > 0 then
        for i = 1, #LootableSlots do
            LootSlot(LootableSlots[i])
        end
        CloseLoot()
    end
end

function LootFilter:LOOT_CLOSED()
    wipe(LootableSlots)
end

-- Register events
LootFilter:RegisterEvent("PLAYER_LOGIN")
LootFilter:RegisterEvent("LOOT_READY")
LootFilter:RegisterEvent("LOOT_OPENED")
LootFilter:RegisterEvent("LOOT_CLOSED")

-- Custom filter functions
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
        SaveCustomFilters()
        print(format("Added %s to custom exclusion list. This item will not be looted.", itemLink or itemName))
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
        SaveCustomFilters()
        print(format("Removed %s from custom exclusion list. This item can now be looted.",
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
        print(format("- %s", itemLink or itemName or format("Unknown Item (ID: %d)", itemID)))
        count = count + 1
    end
    if count == 0 then
        print("The custom exclusion list is empty.")
    end
end

-- Slash command handler
SLASH_LOOTFILTER1 = "/lootfilter"
SLASH_LOOTFILTER2 = "/lf"
SlashCmdList["LOOTFILTER"] = function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()

    local commands = {
        add = AddToCustomFilter,
        remove = RemoveFromCustomFilter,
        list = ListCustomFilter,
        clear = ClearCustomFilter
    }

    if commands[command] then
        commands[command](rest ~= "" and rest or nil)
    else
        print("|cFFFFD200Loot Filter Commands:|r")
        print("|cFFFFD200/lf add [itemID or item link]|r - Add an item to the custom filter")
        print("|cFFFFD200/lf remove [itemID or item link]|r - Remove an item from the custom filter")
        print("|cFFFFD200/lf list|r - List all items in the custom filter")
        print("|cFFFFD200/lf clear|r - Clear all items from the custom filter")
    end
end

-- Initialization
local function Initialize()
    TKUILootFilter = TKUILootFilter or {}
    for itemID, value in pairs(TKUILootFilter) do
        R.LootFilterCustom[itemID] = value
    end
end

LootFilter:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](self, ...)
    end
end)

Initialize()