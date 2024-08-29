local R, C, L = unpack(RefineUI)

local addonName, addon = ...
local f = CreateFrame("Frame", "GuildOnlineCountFrame", UIParent)

-- Create a separate frame for the text overlay
local textFrame = CreateFrame("Frame", nil, UIParent)
textFrame:SetFrameStrata("HIGH")
textFrame:SetFrameLevel(100)  -- Set a high frame level to ensure it's on top

-- Create text overlay
local text = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetFont(C.media.normalFont, 12, "OUTLINE")
text:SetTextColor(1, 1, 1) -- White color

-- Table to store class colors
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS

-- Function to get online guild members
local function GetOnlineGuildMembers()
    local onlineMembers = {}
    local numTotalMembers, numOnlineMembers = GetNumGuildMembers()
    for i = 1, numTotalMembers do
        local name, rank, rankIndex, level, _, _, _, _, online, status, class = GetGuildRosterInfo(i)
        if online then
            table.insert(onlineMembers, {
                name = name,
                rank = rank,
                rankIndex = rankIndex,
                level = level,
                status = status,
                class = class
            })
        end
    end
    -- Sort by rank index (lower index means higher rank)
    table.sort(onlineMembers, function(a, b)
        return a.rankIndex < b.rankIndex
    end)
    return onlineMembers, numOnlineMembers
end

-- Function to update guild online count and text position
local function UpdateGuildOnlineCount()
    local numOnline = 0
    if IsInGuild() then
        _, numOnline = GetOnlineGuildMembers()
    end
    text:SetText(numOnline > 0 and numOnline or "")
    
    -- Update text position
    textFrame:SetAllPoints(GuildMicroButton)
    text:ClearAllPoints()
    text:SetPoint("BOTTOM", textFrame, "BOTTOM", 1, 2)
    text:SetJustifyH("CENTER")
end

-- Function to request guild roster update
local function RequestGuildRosterUpdate()
    if IsInGuild() then
        C_GuildInfo.GuildRoster()
    end
end

-- Register events
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("GUILD_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Event handler
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        RequestGuildRosterUpdate()
    end
    UpdateGuildOnlineCount()
end)

-- Update guild info every 5 minutes
C_Timer.NewTicker(300, RequestGuildRosterUpdate)

-- Error handling wrapper
local function SafeCall(func, ...)
    local success, error = pcall(func, ...)
    if not success then
        print("|cFFFF0000GuildOnlineCount Error:|r " .. tostring(error))
    end
end

-- Wrap our main functions with error handling
local SafeUpdateGuildOnlineCount = function() SafeCall(UpdateGuildOnlineCount) end
local SafeRequestGuildRosterUpdate = function() SafeCall(RequestGuildRosterUpdate) end

-- Replace direct function calls with safe versions
f:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        SafeRequestGuildRosterUpdate()
    end
    SafeUpdateGuildOnlineCount()
end)

C_Timer.NewTicker(300, SafeRequestGuildRosterUpdate)

-- Adjust text position when micro menu is moved
hooksecurefunc("UpdateMicroButtons", UpdateGuildOnlineCount)

-- Modify the Guild button tooltip
GuildMicroButton:HookScript("OnEnter", function(self)
    if not IsInGuild() then return end
    
    local onlineMembers, numOnlineMembers = GetOnlineGuildMembers()
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Online Guild Members (" .. numOnlineMembers .. ")")
    
    local currentRank = nil
    for i, member in ipairs(onlineMembers) do
        if i > 30 then  -- Limit to 30 names to prevent tooltip from becoming too large
            GameTooltip:AddLine("... and " .. (numOnlineMembers - 30) .. " more")
            break
        end
        
        -- Add rank header if it's a new rank
        if currentRank ~= member.rank then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("----" .. member.rank .. "----")  -- Yellow color for rank headers
            currentRank = member.rank
        end
        
        local classColor = RAID_CLASS_COLORS[member.class] or RAID_CLASS_COLORS["PRIEST"]  -- Default to priest color if unknown
        local statusIcon = (member.status == 1 and "|TInterface\\FriendsFrame\\StatusIcon-Away:14:14:0:0|t")
                        or (member.status == 2 and "|TInterface\\FriendsFrame\\StatusIcon-DnD:14:14:0:0|t")
                        or ""
        GameTooltip:AddDoubleLine(
            statusIcon .. member.name,
            "Level " .. member.level,
            classColor.r, classColor.g, classColor.b,
            1, 1, 1  -- White color for level
        )
    end
    
    GameTooltip:Show()  -- Refresh the tooltip to show new lines
end)


-- FriendsMicroButton.lua

FriendsMicroButtonMixin = CreateFromMixins(MainMenuBarMicroButtonMixin);

function FriendsMicroButtonMixin:OnLoad()
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UPDATE_BINDINGS");
    self:RegisterEvent("FRIENDLIST_UPDATE");
    self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE");
    self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE");
    self:RegisterEvent("BN_FRIEND_INFO_CHANGED");
    
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    self:SetScript("OnClick", self.OnClick);
    self:SetScript("OnEnter", self.OnEnter);
    self:SetScript("OnLeave", self.OnLeave);
    
    -- Set up custom textures
    self.iconPath = "interface/chatframe/ui-chaticon-battlenet.blp"
    
    -- Create background textures
    self.Background = self:CreateTexture(nil, "BACKGROUND");
    self.Background:SetAtlas("UI-HUD-MicroMenu-SocialJournal-Up", true);
    self.Background:SetAllPoints(self);

    self.PushedBackground = self:CreateTexture(nil, "BACKGROUND");
    self.PushedBackground:SetAtlas("UI-HUD-MicroMenu-SocialJournal-Down", true);
    self.PushedBackground:SetAllPoints(self);
    self.PushedBackground:Hide();

    -- Create icon texture
    self.Icon = self:CreateTexture(nil, "ARTWORK");
    self.Icon:SetTexture(self.iconPath);
    self.Icon:SetPoint("CENTER", self, "CENTER", 0, 2);
    self.Icon:SetSize(24, 24);

    -- Create friend count text
    self.FriendCount = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
    self.FriendCount:SetFont(C.media.normalFont, 12, "OUTLINE")
    self.FriendCount:SetPoint("BOTTOM", 1, 2);
    self.FriendCount:SetTextColor(1, 1, 1);
    self.FriendCount:SetJustifyH("CENTER")

    self:UpdateMicroButton();
end

function FriendsMicroButtonMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UpdateMicroButton();
    elseif event == "UPDATE_BINDINGS" then
        self.tooltipText = MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL");
    elseif event == "FRIENDLIST_UPDATE" or event == "BN_FRIEND_ACCOUNT_ONLINE" or
           event == "BN_FRIEND_ACCOUNT_OFFLINE" or event == "BN_FRIEND_INFO_CHANGED" then
        self:UpdateFriendCount();
    end
    self:UpdateMicroButton();
end

function FriendsMicroButtonMixin:OnClick(button, down)
    if not KeybindFrames_InQuickKeybindMode() then
        ToggleFriendsFrame(1);
    end
end

-- Ensure GetFriendsTooltip is defined within the FriendsMicroButtonMixin
function FriendsMicroButtonMixin:GetFriendsTooltip()
    local tooltip = "";
    local numBNetTotal, numBNetOnline = BNGetNumFriends()
    local totalOnlineFriends = C_FriendList.GetNumOnlineFriends()

    tooltip = tooltip .. string.format("Total Online Friends: %d", numBNetOnline + totalOnlineFriends) .. "\n\n";

    -- Battle.net friends
    if numBNetOnline > 0 then
        tooltip = tooltip .. "Battle.net Friends:\n";
        for i = 1, numBNetTotal do
            local friendAccInfo = C_BattleNet.GetFriendAccountInfo(i)
            if friendAccInfo and friendAccInfo.gameAccountInfo.isOnline then
                local gameAccount = friendAccInfo.gameAccountInfo
                local charName = gameAccount.characterName or "N/A"
                local zone = gameAccount.areaName or "N/A"
                tooltip = tooltip .. string.format("%s - %s\n", friendAccInfo.accountName, charName .. " (" .. zone .. ")");
            end
        end
        tooltip = tooltip .. "\n";
    end

    -- WoW friends
    if totalOnlineFriends > 0 then
        tooltip = tooltip .. "World of Warcraft Friends:\n";
        for i = 1, C_FriendList.GetNumFriends() do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            if friendInfo.connected then
                local name = friendInfo.name
                local level = friendInfo.level
                local class = friendInfo.className
                local area = friendInfo.area
                tooltip = tooltip .. string.format("%s (%d %s) - %s\n", name, level, class, area);
            end
        end
    end

    return tooltip;
end

-- Update the OnEnter method to call GetFriendsTooltip from the mixin
function FriendsMicroButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(SOCIAL_BUTTON, 1, 1, 1);
    GameTooltip:AddLine(self:GetFriendsTooltip(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
    GameTooltip:Show();
end

function FriendsMicroButtonMixin:OnLeave()
    GameTooltip:Hide();
end

function FriendsMicroButtonMixin:SetNormal()
    self.Background:Show();
    self.PushedBackground:Hide();
    self.Icon:SetVertexColor(1, 1, 1);
    self:SetButtonState("NORMAL");
end

function FriendsMicroButtonMixin:SetPushed()
    self.Background:Hide();
    self.PushedBackground:Show();
    self.Icon:SetVertexColor(0.5, 0.5, 0.5);
    self:SetButtonState("PUSHED");
end

function FriendsMicroButtonMixin:UpdateMicroButton()
    if FriendsFrame and FriendsFrame:IsShown() then
        self:SetPushed();
        -- Move the icon when the social menu is open
        self.Icon:SetPoint("CENTER", self, "CENTER", 1, 1)  -- Adjusted position
    else
        self:SetNormal();
        -- Reset the icon position when the social menu is closed
        self.Icon:SetPoint("CENTER", self, "CENTER", 0, 2)  -- Original position
    end

    -- Check if the game menu is open
    if GameMenuFrame and GameMenuFrame:IsShown() then
        self:DisableButton()  -- Disable the button when the game menu is open
    else
        self:EnableButton()  -- Enable the button when the game menu is closed
        self:UpdateFriendCount();  -- Update friend count if the menu is not open
    end
end

function FriendsMicroButtonMixin:DisableButton()
    self:EnableMouse(false)  -- Make the button non-interactive
    self.Icon:SetDesaturated(true)  -- Desaturate the icon
    self.Icon:SetAlpha(0.5)  -- Set alpha to 50%
end

function FriendsMicroButtonMixin:EnableButton()
    self:EnableMouse(true)  -- Make the button interactive
    self.Icon:SetDesaturated(false)  -- Restore the icon color
    self.Icon:SetAlpha(1)  -- Set alpha to full (100%)
end

function FriendsMicroButtonMixin:SetNormal()
    self.Background:Show();
    self.PushedBackground:Hide();
    self.Icon:SetVertexColor(1, 1, 1);
    self:SetButtonState("NORMAL");
end

function FriendsMicroButtonMixin:SetPushed()
    self.Background:Hide();
    self.PushedBackground:Show();
    self.Icon:SetVertexColor(0.5, 0.5, 0.5);
    self:SetButtonState("PUSHED");
end

function FriendsMicroButtonMixin:UpdateFriendCount()
    local numBNetOnline = 0
    local numBNetTotal = BNGetNumFriends()

    -- Count only online Battle.net friends
    for i = 1, numBNetTotal do
        local friendAccInfo = C_BattleNet.GetFriendAccountInfo(i)
        if friendAccInfo and friendAccInfo.gameAccountInfo.isOnline then
            numBNetOnline = numBNetOnline + 1
        end
    end

    local numWoWOnline = C_FriendList.GetNumOnlineFriends() or 0;  -- Ensure numWoWOnline is not nil
    local totalOnline = numBNetOnline + numWoWOnline;  -- Calculate total online friends
    self.FriendCount:SetText(totalOnline > 0 and totalOnline or "");  -- Update button text to show online count
end

-- Function to create a tooltip for friends
local function CreateFriendsTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Friends", 1, 1, 1)
    GameTooltip:AddLine(" ")

    local numBNetTotal, numBNetOnline = BNGetNumFriends()
    local totalOnlineFriends = C_FriendList.GetNumOnlineFriends()

    GameTooltip:AddDoubleLine("Total Online Friends:", numBNetOnline + totalOnlineFriends, 1, 1, 1, 1, 1, 1)
    GameTooltip:AddLine(" ")

    -- Battle.net friends
    if numBNetOnline > 0 then
        GameTooltip:AddLine("Battle.net Friends", 0.1, 0.6, 0.8)
        for i = 1, numBNetTotal do
            local friendAccInfo = C_BattleNet.GetFriendAccountInfo(i)
            if friendAccInfo and friendAccInfo.gameAccountInfo.isOnline then
                local gameAccount = friendAccInfo.gameAccountInfo
                local charName = gameAccount.characterName
                local realmName = gameAccount.realmName
                local zone = gameAccount.areaName
                local statusIcon = FRIENDS_TEXTURE_ONLINE
                if friendAccInfo.isAFK or gameAccount.isGameAFK then
                    statusIcon = FRIENDS_TEXTURE_AFK
                elseif friendAccInfo.isDND or gameAccount.isGameBusy then
                    statusIcon = FRIENDS_TEXTURE_DND
                end

                local lineLeft = string.format("|T%s:16|t %s", statusIcon, friendAccInfo.accountName)
                local lineRight = string.format("%s %s", charName or "N/A", zone or "N/A")

                GameTooltip:AddDoubleLine(lineLeft, lineRight, 1, 1, 1, 1, 1, 1)
            end
        end
        GameTooltip:AddLine(" ")
    end

    -- WoW friends
    if totalOnlineFriends > 0 then
        GameTooltip:AddLine("World of Warcraft Friends", 0.1, 0.6, 0.8)
        for i = 1, C_FriendList.GetNumFriends() do
            local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
            if friendInfo.connected then
                local name = friendInfo.name
                local level = friendInfo.level
                local class = friendInfo.className
                local area = friendInfo.area
                local statusIcon = FRIENDS_TEXTURE_ONLINE
                if friendInfo.afk then
                    statusIcon = FRIENDS_TEXTURE_AFK
                elseif friendInfo.dnd then
                    statusIcon = FRIENDS_TEXTURE_DND
                end
                local classColor = RAID_CLASS_COLORS[class] or NORMAL_FONT_COLOR
                local lineLeft = string.format("|T%s:16|t %s, " .. LEVEL .. ":%s %s", statusIcon, name, level, class)
                local lineRight = area
                GameTooltip:AddDoubleLine(lineLeft, lineRight, classColor.r, classColor.g, classColor.b, 1, 1, 1)
            end
        end
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-Click: Open Friends List", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Shift-Click: Invite to Group", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Right-Click: Whisper", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

-- Hook the tooltip function to the FriendsMicroButton


-- Create and initialize the button
local function InitializeFriendsMicroButton()
    local parentFrame = MicroMenuContainer or UIParent
    FriendsMicroButton = CreateFrame("Button", "FriendsMicroButton", parentFrame, "MainMenuBarMicroButton");
    Mixin(FriendsMicroButton, FriendsMicroButtonMixin);
    FriendsMicroButton:OnLoad();

    -- Insert FriendsMicroButton into the MICRO_BUTTONS table
    local guildIndex = tIndexOf(MICRO_BUTTONS, "GuildMicroButton");
    if guildIndex then
        table.insert(MICRO_BUTTONS, guildIndex + 1, "FriendsMicroButton");
    end

    -- Ensure the button is properly initialized
    if parentFrame then
        FriendsMicroButton:SetFrameLevel(parentFrame:GetFrameLevel() + 1);
    end
    FriendsMicroButton:EnableMouse(true);
    FriendsMicroButton:Show();

    -- Hook the tooltip function to the FriendsMicroButton
    FriendsMicroButton:HookScript("OnEnter", CreateFriendsTooltip)  -- Moved here

    return FriendsMicroButton
end


-- hook the UpdateMicroButtons function to include our new button
hooksecurefunc("UpdateMicroButtons", function()
    if FriendsMicroButton then
        FriendsMicroButton:UpdateMicroButton();
    end
end);

-- hook the layout function to properly position our button and adjust others
hooksecurefunc(MicroMenuContainer, "Layout", function(self)
    if FriendsMicroButton then
        -- Position FriendsMicroButton
        FriendsMicroButton:ClearAllPoints();
        FriendsMicroButton:SetPoint("TOPLEFT", GuildMicroButton, "TOPRIGHT", -2, 0);

        -- Adjust positions of subsequent buttons
        local buttonsToMove = {
            LFDMicroButton,
            CollectionsMicroButton,
            EJMicroButton,
            StoreMicroButton,
            MainMenuMicroButton
        };

        for i, button in ipairs(buttonsToMove) do
            if button then
                button:ClearAllPoints();
                if i == 1 then
                    button:SetPoint("TOPLEFT", FriendsMicroButton, "TOPRIGHT", -2, 0);
                else
                    button:SetPoint("TOPLEFT", buttonsToMove[i-1], "TOPRIGHT", -2, 0);
                end
            end
        end
    end
end);

-- Initialize the button
FriendsMicroButton = InitializeFriendsMicroButton()


