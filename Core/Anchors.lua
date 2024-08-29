-- local R, C, L = unpack(RefineUI)
-- local TP = R:GetModule('Templates')
-- R.anchors = {}

-- -- Helper function to create anchors
-- local function CreateAnchor(name, data)
--     local anchor = CreateFrame("Frame", "RefineUI_"..name.."Anchor", UIParent)
--     local width, height = unpack(data.size or {100, 100})
--     anchorSetSize(anchor, width, height)
--     anchor:SetPoint(unpack(data.position))
--     R.PixelSnap(anchor)
--     anchor:SetFrameStrata("BACKGROUND")
--     anchor:SetFrameLevel(0)
    
--     -- anchor:SetAlpha(0)
--     -- anchor:Hide()
--     R:SetTemplate(anchor, "Default")
--     -- local texture = anchor:CreateTexture(nil, "BACKGROUND")
--     -- texture:SetAllPoints()
--     -- texture:SetColorTexture(1, 0, 0, 0.5)
    
--     local text = anchor:CreateFontString(nil, "OVERLAY")
--     text:SetFont(C.media.normalFont, 1, "OUTLINE")
--     text:SetPoint("CENTER")
--     text:SetText(name)
    
--     function anchor:ToggleVisibility()
--         if self:IsShown() then
--             self:Hide()
--         else
--             self:Show()
--         end
--     end
    
--     return anchor
-- end

-- -- Create anchors for all positions
-- for name, data in pairs(C.position) do
--     if type(data) == "table" and data.position then
--         R.anchors[name] = CreateAnchor(name, data)
--     elseif type(data) == "table" then
--         for subname, subdata in pairs(data) do
--             if type(subdata) == "table" and subdata.position then
--                 R.anchors[name .. "_" .. subname] = CreateAnchor(name .. "_" .. subname, subdata)
--             end
--         end
--     end
-- end

-- -- Function to toggle all anchors' visibility
-- function R.Toggleanchors()
--     for _, anchor in pairs(R.anchors) do
--         anchor:ToggleVisibility()
--     end
-- end

-- -- Slash command to toggle anchors
-- SLASH_REFINEANCHORS1 = "/refineanchors"
-- SlashCmdList["REFINEANCHORS"] = R.Toggleanchors

-- -- Function to reset all anchors to their default positions
-- function R.Resetanchors()
--     for name, anchor in pairs(R.anchors) do
--         local position
--         if string.find(name, "_") then
--             local main, sub = string.match(name, "(.+)_(.+)")
--             position = C.position[main][sub]
--         else
--             position = C.position[name]
--         end
--         if position then
--             anchor:SetPoint(unpack(position))
--             R.PixelSnap(anchor)
--         end
--     end
-- end

-- -- Slash command to reset anchors
-- SLASH_REFINERESETANCHORS1 = "/refineresetanchors"
-- SlashCmdList["REFINERESETANCHORS"] = R.Resetanchors