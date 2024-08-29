local R, C, L = unpack(RefineUI)

-- Cache frequently used global functions
local CreateFrame, CreateVector2D, UnitPosition, UnitName = CreateFrame, CreateVector2D, UnitPosition, UnitName
local C_Map, C_QuestLog = C_Map, C_QuestLog
local select, pairs = select, pairs

-- Font replacement
MapQuestInfoRewardsFrame.XPFrame.Name:SetFont(C.media.normalFont, 13, "")

-- Count of quests
local maxQuest = 35
local numQuest = CreateFrame("Frame", nil, QuestMapFrame)
numQuest.text = numQuest:CreateFontString(nil, "ARTWORK", "GameFontNormal")
numQuest.text:SetPoint("TOP", QuestMapFrame, "TOP", 0, C.skins.blizzardFrames and -21 or -17)
numQuest.text:SetJustifyH("LEFT")

-- Creating coordinate
local coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
coords:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
coords:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())

coords.PlayerText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "BOTTOM", -40, 20)
coords.PlayerText:SetJustifyH("LEFT")

coords.MouseText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
coords.MouseText:SetJustifyH("LEFT")
coords.MouseText:SetPoint("BOTTOMLEFT", coords.PlayerText, "TOPLEFT", 0, 5)

local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
local function GetPlayerMapPos(mapID)
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then return end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not pos1 or not pos2 then return end
        mapRect = {pos1, pos2}
        mapRect[2]:Subtract(mapRect[1])
        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end

local updateInterval = 0.33 -- Update every 1/3 second
local timeSinceLastUpdate = 0
local playerName = UnitName("player")

WorldMapFrame:HookScript("OnUpdate", function(_, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate < updateInterval then return end
    timeSinceLastUpdate = 0

    local unitMap = C_Map.GetBestMapForUnit("player")
    local x, y = 0, 0

    if unitMap then
        x, y = GetPlayerMapPos(unitMap)
    end

    if x and y and x >= 0 and y >= 0 then
        coords.PlayerText:SetFormattedText("%s: %.0f,%.0f", R.name, x * 100, y * 100)
    else
        coords.PlayerText:SetFormattedText("%s: |cffff0000%s|r", playerName, L_MAP_BOUNDS)
    end

    if WorldMapFrame.ScrollContainer:IsMouseOver() then
        local mouseX, mouseY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
        if mouseX and mouseY and mouseX >= 0 and mouseY >= 0 then
            coords.MouseText:SetFormattedText("%s %.0f,%.0f", L_MAP_CURSOR, mouseX * 100, mouseY * 100)
        else
            coords.MouseText:SetFormattedText("%s|cffff0000%s|r", L_MAP_CURSOR, L_MAP_BOUNDS)
        end
    else
        coords.MouseText:SetFormattedText("%s|cffff0000%s|r", L_MAP_CURSOR, L_MAP_BOUNDS)
    end

    numQuest.text:SetFormattedText("%d/%d", select(2, C_QuestLog.GetNumQuestLogEntries()), maxQuest)
end)

coords:RegisterEvent("PLAYER_ENTERING_WORLD")
coords:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event)
    if RefineUISettings and RefineUISettings.Coords ~= true then
        coords:SetAlpha(0)
    end
end)

-- ----------------------------------------------------------------------------------------
-- --	Added options to map tracking button
-- ----------------------------------------------------------------------------------------
-- hooksecurefunc(WorldMapFrame.overlayFrames[2], "InitializeDropDown", function(self)
-- 	UIDropDownMenu_AddSeparator()
-- 	local info = UIDropDownMenu_CreateInfo()

-- 	info.isTitle = true
-- 	info.notCheckable = true
-- 	info.text = "RefineUI"

-- 	UIDropDownMenu_AddButton(info)
-- 	info.text = nil

-- 	info.isTitle = nil
-- 	info.disabled = nil
-- 	info.notCheckable = nil
-- 	info.isNotRadio = true
-- 	info.keepShownOnClick = true

-- 	info.text = L_MAP_COORDS
-- 	info.checked = function()
-- 		return RefineUISettings.Coords == true
-- 	end

-- 	info.func = function()
-- 		if RefineUISettings.Coords == true then
-- 			RefineUISettings.Coords = false
-- 			coords:SetAlpha(0)
-- 		else
-- 			RefineUISettings.Coords = true
-- 			coords:SetAlpha(1)
-- 		end
-- 	end
-- 	UIDropDownMenu_AddButton(info)

-- 	if C.minimap.fog_of_war == true then
-- 		info.text = L_MAP_FOG
-- 		info.checked = function()
-- 			return RefineUISettings.FogOfWar == true
-- 		end

-- 		info.func = function()
-- 			if RefineUISettings.FogOfWar == true then
-- 				RefineUISettings.FogOfWar = false
-- 				for i = 1, #R.overlayTextures do
-- 					R.overlayTextures[i]:Hide()
-- 				end
-- 			else
-- 				RefineUISettings.FogOfWar = true
-- 				for i = 1, #R.overlayTextures do
-- 					R.overlayTextures[i]:Show()
-- 				end
-- 			end
-- 		end
-- 		UIDropDownMenu_AddButton(info)
-- 	end
-- end)