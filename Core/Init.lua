----------------------------------------------------------------------------------------
--	Initiation of RefineUI
----------------------------------------------------------------------------------------
-- Including system
local addon, engine = ...
engine[1] = {}	-- R, Functions
engine[2] = {}	-- C, Config
engine[3] = {}	-- L, Localization

RefineUI = engine	-- Allow other addons to use Engine

--[[
	This should be at the top of every file inside of the RefineUI AddOn:
	local T, C, L = unpack(RefineUI)

	This is how another addon imports the RefineUI engine:
	local T, C, L, _ = unpack(RefineUI)
]]

-- function R:Initialize()
--     self:RegisterEvent('PLAYER_LOGIN')
--     self:SetupDatabase()
-- end

-- function R:SetupDatabase()
--     local defaults = {
--         profile = {},
--         char = {}
--     }
--     self.db = LibStub("AceDB-3.0"):New("RefineUIDB", defaults, true)
--     self.chardb = LibStub("AceDB-3.0"):New("RefineUICharDB", defaults, true)
-- end

-- function R:PLAYER_LOGIN()
--     self:InitializeModules()
--     self:RegisterChatCommand('refineui', 'HandleSlashCommands')
-- end

-- function R:InitializeModules()
--     for name, module in self:IterateModules() do
--         if type(module.Initialize) == "function" then
--             module:Initialize()
--         end
--     end
-- end

-- function R:HandleSlashCommands(input)
--     -- Handle slash commands here
-- end

-- R:RegisterEvent('PLAYER_LOGIN')