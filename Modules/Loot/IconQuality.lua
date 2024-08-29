local R, C, L = unpack(RefineUI)

-- -- Function to skin the loot icon border
-- local function SkinLootButton(button, quality)
--     -- if not button or button.IconBorderSkinned then return end
    
--     -- Determine which icon to use
--     local iconTexture = button.icon or button.Icon or button.IconTexture
    
--     -- if not iconTexture then
--     --     -- If we can't find an icon, we can't skin it
--     --     return
--     -- end
    
--     -- Strip existing border textures
--     if button.IconBorder then
--         button.IconBorder:SetTexture(nil)
--         button.IconBorder:Hide()
--     end
    
--     if button.IconOverlay then
--         button.IconOverlay:SetTexture(nil)
--         button.IconOverlay:Hide()
--     end
    
--         button.Border:SetTexture(nil)
--         button.Border:Hide()
--     end
    
--     -- Remove the default item border
--     iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    
--     button:SetTemplate("Icon")
    
--     -- Check if quality is valid
--     if quality and ITEM_QUALITY_COLORS[quality] then
--         local color = ITEM_QUALITY_COLORS[quality]
--         local r, g, b = color.r, color.g, color.b
--         button.border:SetBackdropBorderColor(r, g, b)
--     else
--         -- Fallback color if quality is invalid
--         button.border:SetBackdropBorderColor(unpack(C.media.borderColor))  -- Default to white
--     end
    
--     button.border:SetFrameStrata("MEDIUM")  -- Set the frame strata to HIGH

--     -- Mark the button as skinned
--     button.IconBorderSkinned = true
-- end

-- -- Hook the SetItemButtonQuality function
-- hooksecurefunc("SetItemButtonQuality", function(button, quality, itemIDOrLink)
--     SkinLootButton(button, quality)
-- end)

-- -- Hook the LootFrameElementMixin:Init function
-- if LootFrameElementMixin and LootFrameElementMixin.Init then
--     hooksecurefunc(LootFrameElementMixin, "Init", function(self)
--         if self.Item then
--             SkinLootButton(self.Item)
--         end
--     end)
-- end

