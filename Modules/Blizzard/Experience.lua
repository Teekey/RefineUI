local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local UF = R.UF

-- Position and size
local Experience = CreateFrame('StatusBar', nil, self)
Experience:SetPoint('BOTTOM', 0, -50)
Experience:SetSize(200, 20)
Experience:EnableMouse(true) -- for tooltip/fading support

-- Position and size the Rested sub-widget
local Rested = CreateFrame('StatusBar', nil, Experience)
Rested:SetAllPoints(Experience)

-- Text display
local Value = Experience:CreateFontString(nil, 'OVERLAY')
Value:SetAllPoints(Experience)
Value:SetFontObject(GameFontHighlight)
self:Tag(Value, '[experience:cur] / [experience:max]')

-- Add a background
local Background = Rested:CreateTexture(nil, 'BACKGROUND')
Background:SetAllPoints(Experience)
Background:SetTexture('Interface\\ChatFrame\\ChatFrameBackground')

-- Register with oUF
self.Experience = Experience
self.Experience.Rested = Rested