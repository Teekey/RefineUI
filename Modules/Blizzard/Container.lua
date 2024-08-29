local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Bank/Container skin
----------------------------------------------------------------------------------------
local function LoadSkin()
    local function SkinBagSlots(button)
        if not button.styled then
            local icon = button.icon

            button:SetNormalTexture(0)
            button:StyleButton()
            button:SetTemplate("Icon")

            icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            icon:ClearAllPoints()
            icon:SetPoint("TOPLEFT", 2, -2)
            icon:SetPoint("BOTTOMRIGHT", -2, 2)

            button.Count:SetFont(C.font.bags_font, C.font.bags_font_size, C.font.bags_font_style)
            button.Count:SetShadowOffset(C.font.bags_font_shadow and 1 or 0, C.font.bags_font_shadow and -1 or 0)
            button.Count:SetPoint("BOTTOMRIGHT", 1, 1)

            R.SkinIconBorder(button.IconBorder, button)

            button.IconQuestTexture:SetAlpha(0)
            if button.Background then
                button.Background:SetAlpha(0)
            end

            button.styled = true
        end
    end

    local function SkinItemSlots(self)
        for button in self.itemButtonPool:EnumerateActive() do
            SkinBagSlots(button)
        end
    end

    local function UpdateQuality(self)
        for _, button in self:EnumerateValidItems() do
            if button.IconQuestTexture:IsShown() then
                if button.IconQuestTexture:GetTexture() == 368362 then
                    if button.border then
                        button.border:SetBackdropBorderColor(1, 0.3, 0.3)
                    end
                else
                    if button.border then
                        button.border:SetBackdropBorderColor(1, 1, 0)
                    end
                end
            else
                local quality

                -- Try to get the item location
                local itemLocation
                if button.GetItemLocation then
                    itemLocation = button:GetItemLocation()
                elseif button.bagID ~= nil and button.slotIndex ~= nil then
                    itemLocation = ItemLocation:CreateFromBagAndSlot(button.bagID, button.slotIndex)
                end

                -- If we have a valid item location, try to get the quality
                if itemLocation and C_Item.DoesItemExist(itemLocation) then
                    quality = C_Item.GetItemQuality(itemLocation)
                end

                if quality then
                    if quality > 1 then
                        local r, g, b = C_Item.GetItemQualityColor(quality)
                        if button.border then
                            button.border:SetBackdropBorderColor(r, g, b)
                        end
                    else
                        -- Set default color for low-quality items
                        if button.border and C and C.media and C.media.borderColor then
                            button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
                        else
                            -- Fallback to a default color if C.media.borderColor is not available
                            if button.border then
                                button.border:SetBackdropBorderColor(0.5, 0.5, 0.5)
                            end
                        end
                    end
                else
                    -- Set default color for empty slots
                    if button.border and C and C.media and C.media.borderColor then
                        button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
                    else
                        -- Fallback to a default color if C.media.borderColor is not available
                        if button.border then
                            button.border:SetBackdropBorderColor(0.5, 0.5, 0.5)
                        end
                    end
                end
            end
        end
    end

    hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemSlots", SkinItemSlots)
    hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemSlots", UpdateQuality)
    hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", UpdateQuality)
    hooksecurefunc(ContainerFrameCombinedBags, "OnShow", UpdateQuality)

    -- Bank Frame
    BankFrame:StripTextures(true)
    BankFrame:CreateBackdrop("Transparent")
    BankFrame.backdrop:SetAllPoints()
    BankFramePortrait:SetAlpha(0)

    BankItemSearchBox:StripTextures(true)
    BankItemSearchBox:CreateBackdrop("Overlay")
    BankItemSearchBox.backdrop:SetPoint("TOPLEFT", 13, 0)
    BankItemSearchBox.backdrop:SetPoint("BOTTOMRIGHT", -2, 0)

    BankItemAutoSortButton:StyleButton()
    BankItemAutoSortButton:SetTemplate("Default")
    BankItemAutoSortButton:SetSize(20, 20)
    BankItemAutoSortButton:SetPoint("TOPLEFT", BankItemSearchBox, "TOPRIGHT", 3, 0)
    BankItemAutoSortButton:GetNormalTexture():SetTexture("Interface\\Icons\\inv_pet_broom")
    BankItemAutoSortButton:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
    BankItemAutoSortButton:GetNormalTexture():ClearAllPoints()
    BankItemAutoSortButton:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
    BankItemAutoSortButton:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)

    BankFrameMoneyFrameBorder:Hide()

    BankFramePurchaseButton:SkinButton()
    R.SkinCloseButton(BankFrameCloseButton, BankFrame.backdrop)

    BankSlotsFrame:StripTextures()

    for i = 1, 28 do
        local item = _G["BankFrameItem" .. i]
        SkinBagSlots(item)
    end

    for i = 1, 7 do
        local bag = BankSlotsFrame["Bag" .. i]
        local icon = bag.icon

        bag.IconBorder:SetAlpha(0)

        bag:StripTextures()
        bag:StyleButton()
        bag:SetTemplate("Default")

        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
    end

    -- Tabs
    for i = 1, 3 do
        R.SkinTab(_G["BankFrameTab" .. i])
    end

    -- ReagentBank
    ReagentBankFrame:StripTextures()
    ReagentBankFrame:DisableDrawLayer("BACKGROUND")
    ReagentBankFrame:DisableDrawLayer("ARTWORK")

    ReagentBankFrameUnlockInfo:StripTextures()
    ReagentBankFrameUnlockInfo:CreateBackdrop("Overlay")
    ReagentBankFrameUnlockInfo.backdrop:SetPoint("TOPLEFT", 4, -2)
    ReagentBankFrameUnlockInfo.backdrop:SetPoint("BOTTOMRIGHT", -4, 2)
    ReagentBankFrameUnlockInfo.backdrop:SetFrameLevel(ReagentBankFrameUnlockInfo.backdrop:GetFrameLevel() + 1)

    ReagentBankFrameUnlockInfoPurchaseButton:SkinButton()
    ReagentBankFrameUnlockInfoPurchaseButton:SetFrameLevel(ReagentBankFrameUnlockInfo:GetFrameLevel() + 3)
    ReagentBankFrame.DespositButton:SkinButton()

    ReagentBankFrame:HookScript("OnShow", function()
        for i = 1, 98 do
            local item = _G["ReagentBankFrameItem" .. i]
            SkinBagSlots(item)
            BankFrameItemButton_Update(item)
        end
    end)

    hooksecurefunc("BankFrameItemButton_Update", function(frame)
        if not frame.isBag and frame.IconQuestTexture:IsShown() then
            if frame.IconQuestTexture:GetTexture() == 368362 then
                frame:SetBackdropBorderColor(1, 0.3, 0.3)
            else
                frame:SetBackdropBorderColor(1, 1, 0)
            end
        end
    end)


    -- Warband
    AccountBankPanel:StripTextures()

    hooksecurefunc(AccountBankPanel, "GenerateItemSlotsForSelectedTab", SkinItemSlots)

    local function SkinBankTab(button)
        if not button.styled then
            button.Border:SetAlpha(0)

            if button.Background then
                button.Background:SetAlpha(0)
            end

            button:SetTemplate("Default")
            button:StyleButton()

            button.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
            button.SelectedTexture:SetPoint("TOPLEFT", 2, -2)
            button.SelectedTexture:SetPoint("BOTTOMRIGHT", -2, 2)

            button.Icon:ClearAllPoints()
            button.Icon:SetPoint("TOPLEFT", 2, -2)
            button.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
            button.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

            button.styled = true
        end
    end

    hooksecurefunc(AccountBankPanel, "RefreshBankTabs", function(self)
        for tab in self.bankTabPool:EnumerateActive() do
            SkinBankTab(tab)
        end
    end)
    SkinBankTab(AccountBankPanel.PurchaseTab)

    AccountBankPanel.ItemDepositFrame.DepositButton:SkinButton()
    R.SkinCheckBox(AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox)
    AccountBankPanel.MoneyFrame.Border:Hide()
    AccountBankPanel.MoneyFrame.WithdrawButton:SkinButton()
    AccountBankPanel.MoneyFrame.DepositButton:SkinButton()

    AccountBankPanel.PurchasePrompt:StripTextures()
    AccountBankPanel.PurchasePrompt:CreateBackdrop("Overlay")
    AccountBankPanel.PurchasePrompt.backdrop:SetPoint("TOPLEFT", 4, -2)
    AccountBankPanel.PurchasePrompt.backdrop:SetPoint("BOTTOMRIGHT", -4, 2)
    AccountBankPanel.PurchasePrompt.backdrop:SetFrameLevel(AccountBankPanel.PurchasePrompt.backdrop:GetFrameLevel() + 1)

    AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SkinButton()
    AccountBankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetFrameLevel(AccountBankPanel.PurchasePrompt
        :GetFrameLevel() + 3)

    R.SkinIconSelectionFrame(AccountBankPanel.TabSettingsMenu)
end

tinsert(R.SkinFuncs["RefineUI"], LoadSkin)
