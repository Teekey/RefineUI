local R, C, L = unpack(RefineUI)

local createItemLevelText = function(self)
    if not self.oGlowItemLevel then
        self.oGlowItemLevel = self:CreateFontString(nil, "OVERLAY")
        self.oGlowItemLevel:SetFont(C.media.normalFont, 12, "OUTLINE")
		self.oGlowItemLevel:SetShadowOffset(1, -1)
        self.oGlowItemLevel:SetPoint("TOPRIGHT", 1, -3)
    end
    return self.oGlowItemLevel
end

local itemLevelDisplay = function(frame, itemLevel, itemLink)
    if itemLevel and type(itemLevel) == "number" then
        local text = createItemLevelText(frame)
        local quality = 1  -- Default to common quality
        
        if itemLink then
            local itemID = C_Item.GetItemInfoInstant(itemLink)
            if itemID then
                quality = C_Item.GetItemQualityByID(itemID) or 1
            end
        elseif frame.itemLink then
            local itemID = C_Item.GetItemInfoInstant(frame.itemLink)
            if itemID then
                quality = C_Item.GetItemQualityByID(itemID) or 1
            end
        end
        
        local r, g, b = C_Item.GetItemQualityColor(quality)
        text:SetText(itemLevel)
        text:SetTextColor(r, g, b)
        text:Show()
        return true
    else
        if frame.oGlowItemLevel then
            frame.oGlowItemLevel:Hide()
        end
    end
end

oGlow:RegisterDisplay("ItemLevel", itemLevelDisplay)
