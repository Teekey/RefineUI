----------------------------------------------------------------------------------------
--	AutoRepair Module for RefineUI
--	This module automatically repairs equipment when interacting with a merchant
----------------------------------------------------------------------------------------

local T, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Local Variables
----------------------------------------------------------------------------------------
local f = CreateFrame("Frame")

----------------------------------------------------------------------------------------
--	Auto Repair Function
----------------------------------------------------------------------------------------
local function AutoRepair()
    -- Check if auto repair is enabled and if the merchant can repair
    if not C.automation.autoRepair or not CanMerchantRepair() then return end

    local repairAllCost, canRepair = GetRepairAllCost()
    if not canRepair or repairAllCost <= 0 then return end

    local guildRepairedItems = false
    
    -- Attempt guild repair if enabled
    if C.automation.autoGuildRepair then
        RepairAllItems(true)
        -- Check if items were repaired using guild funds
        local newRepairAllCost = select(1, GetRepairAllCost())
        guildRepairedItems = (newRepairAllCost < repairAllCost)
        repairAllCost = newRepairAllCost
    end

    -- Repair with personal funds if guild repair wasn't successful
    if not guildRepairedItems and repairAllCost <= GetMoney() then
        RepairAllItems(false)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200AAuto Repaired for:|r " .. C_CurrencyInfo.GetCoinTextureString(repairAllCost), 255, 255, 255)
    elseif guildRepairedItems then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200AAuto Repaired for:|r " .. C_CurrencyInfo.GetCoinTextureString(repairAllCost) .. " (Guild Funds)", 255, 255, 255)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFD200ANot enough money for repair|r. Required: " .. C_CurrencyInfo.GetCoinTextureString(repairAllCost), 255, 255, 255)
    end
end

----------------------------------------------------------------------------------------
--	Event Handling
----------------------------------------------------------------------------------------
local function OnEvent(self, event)
    if event == "MERCHANT_SHOW" then
        AutoRepair()
    end
end

----------------------------------------------------------------------------------------
--	Frame Setup
----------------------------------------------------------------------------------------
f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("MERCHANT_SHOW")