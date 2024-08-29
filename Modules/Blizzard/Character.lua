local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	Character skin
----------------------------------------------------------------------------------------
local function LoadSkin()
    local slots = {
        "HeadSlot",
        "NeckSlot",
        "ShoulderSlot",
        "BackSlot",
        "ChestSlot",
        "ShirtSlot",
        "TabardSlot",
        "WristSlot",
        "HandsSlot",
        "WaistSlot",
        "LegsSlot",
        "FeetSlot",
        "Finger0Slot",
        "Finger1Slot",
        "Trinket0Slot",
        "Trinket1Slot",
        "MainHandSlot",
        "SecondaryHandSlot"
    }

    select(16, CharacterMainHandSlot:GetRegions()):Hide()
    select(16, CharacterSecondaryHandSlot:GetRegions()):Hide()

    local function UpdateSlotQuality(slot)
        local slotName = slot:GetName():gsub("Character", "")
        local slotId = GetInventorySlotInfo(slotName)
        local itemLink = GetInventoryItemLink("player", slotId)

        if itemLink then
            local quality = select(3, C_Item.GetItemInfo(itemLink))
            local r, g, b = C_Item.GetItemQualityColor(quality)
            slot.border:SetBackdropBorderColor(r, g, b)
        else
            slot.border:SetBackdropBorderColor(unpack(C.media.borderColor))
        end
    end

    for _, i in pairs(slots) do
        _G["Character" .. i .. "Frame"]:Hide()
        local icon = _G["Character" .. i .. "IconTexture"]
        local slot = _G["Character" .. i]
        local border = _G["Character" .. i].IconBorder

        -- border:SetAlpha(0)
        -- slot:StyleButton()
        -- slot:SetNormalTexture(0)
        -- slot.SetHighlightTexture = R.dummy
        -- slot:GetHighlightTexture().SetAllPoints = R.dummy
        -- slot:SetFrameLevel(slot:GetFrameLevel() + 2)
        slot:SetTemplate("Icon")

        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)

        if slot.popoutButton:GetPoint() == "TOP" then
            slot.popoutButton:SetPoint("TOP", slot, "BOTTOM", 0, 2)
        else
            slot.popoutButton:SetPoint("LEFT", slot, "RIGHT", -2, 0)
        end

        -- Add this line to update the border color when the item changes
        hooksecurefunc(slot, "SetItem", function() UpdateSlotQuality(slot) end)
    end

    CharacterFrame:HookScript("OnShow", function()
        for _, i in pairs(slots) do
            UpdateSlotQuality(_G["Character" .. i])
        end
    end)

    CharacterFrame:HookScript("OnUpdate", function()
        for _, i in pairs(slots) do
            UpdateSlotQuality(_G["Character" .. i])
        end
    end)


    local function UpdateFlyoutItemQuality(button)
        if not button.border then return end
    
        local location = button.location
        if not location or type(location) ~= "table" then return end  -- Ensure location is a table
    
        -- Ensure the location table has the expected keys
        local slotIndex = location.slotIndex
        local bagID = location.bagID
    
        if not slotIndex or not bagID then return end  -- Ensure slotIndex and bagID are present
    
        local link
        if bagID >= 0 then  -- Check if bagID is valid
            link = C_Container.GetContainerItemLink(bagID, slotIndex)
        else
            link = GetInventoryItemLink("player", slotIndex)
        end
    
        if link then
            local quality = select(3, C_Item.GetItemInfo(link))
            if quality and quality > 1 then
                local r, g, b = C_Item.GetItemQualityColor(quality)
                button.border:SetBackdropBorderColor(r, g, b)
            else
                button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
            end
        else
            button.border:SetBackdropBorderColor(unpack(C.media.borderColor))
        end
    end

    local function SkinItemFlyouts()
        EquipmentFlyoutFrameButtons:StripTextures()

        for i = 1, 23 do
            local button = _G["EquipmentFlyoutFrameButton" .. i]
            local icon = _G["EquipmentFlyoutFrameButton" .. i .. "IconTexture"]
            if button then
                if not button.isSkinned then
                    button:StyleButton()
                    button:SetNormalTexture(0)
                    button.IconBorder:SetAlpha(0)

                    icon:SetTexCoord(0, 1, 0, 1)
                    icon:ClearAllPoints()
                    icon:SetPoint("TOPLEFT", 2, -2)
                    icon:SetPoint("BOTTOMRIGHT", -2, 2)
                    icon:SetDrawLayer("ARTWORK")

                    button:SetFrameLevel(button:GetFrameLevel() + 2)
                    button:SetFrameStrata("DIALOG")

                    if not button.border then
                        button:SetTemplate("Icon")
                        button.border:SetFrameStrata("HIGH")
                    end

                    button.isSkinned = true
                end

                -- Add a check to ensure UpdateFlyoutItemQuality runs only once per event
                if not button.isUpdated then
                    UpdateFlyoutItemQuality(button)
                    button.isUpdated = true
                end
            end
        end
    end

    -- Swap item flyout frame (shown when holding alt over a slot)
    EquipmentFlyoutFrame:HookScript("OnShow", SkinItemFlyouts)
    hooksecurefunc("EquipmentFlyout_Show", SkinItemFlyouts)
    hooksecurefunc("EquipmentFlyout_DisplayButton", UpdateFlyoutItemQuality)
end

tinsert(R.SkinFuncs["RefineUI"], LoadSkin)
