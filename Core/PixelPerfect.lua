local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
--	PIXEL PERFECT
----------------------------------------------------------------------------------------
local function round(x)
    return math.floor(x + 0.5)
end

local function calculateUIScale(screenHeight)
    local baseScale = 768 / screenHeight
    local uiScale = math.min(2, math.max(0.20, baseScale))

    if screenHeight >= 2400 then
        uiScale = uiScale * 3
    elseif screenHeight >= 1600 then
        uiScale = uiScale * 2
    end

    return tonumber(string.format("%.5f", uiScale))
end

-- Main scaling logic
R.low_resolution = R.screenWidth <= 1440

if C.general.autoScale then
    C.general.uiScale = calculateUIScale(R.screenHeight)
end

R.mult = 768 / R.screenHeight / C.general.uiScale
R.noscalemult = R.mult * C.general.uiScale

R.Scale = function(x)
    return round(R.mult * x)
end

-- Scale fonts for all resolutions
local fontScaleFactor = R.screenHeight > 1200 and R.mult or 1
local fontTypes = { "normal", "chat_tabs", "action_bars", "threat_meter", "raid_cooldowns", "unit_frames", "auras",
    "filger", "bags", "loot", "combat_text", "stats", "stylization", "cooldown_timers" }

for _, fontType in ipairs(fontTypes) do
    if C.media[fontType .. "_font_size"] then
        C.media[fontType .. "_font_size"] = C.media[fontType .. "_font_size"] * fontScaleFactor
    elseif C.font[fontType .. "_font_size"] then
        C.font[fontType .. "_font_size"] = C.font[fontType .. "_font_size"] * fontScaleFactor
    end
end

----------------------------------------------------------------------------------------
--	PIXEL PERFECT FUNCTIONS
----------------------------------------------------------------------------------------
function R.PixelPerfect(x)
    local scale = UIParent:GetEffectiveScale()
    return floor(x / scale + 0.5) * scale
end

function R.PixelSnap(frame)
    if not frame or not frame.GetPoint then return end
    
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    if not point then return end  -- Frame doesn't have any anchor points set
    
    local scale = frame:GetEffectiveScale()
    local parentScale = relativeTo and relativeTo.GetEffectiveScale and relativeTo:GetEffectiveScale() or scale

    xOfs = R.PixelPerfect((xOfs * scale) / parentScale) / scale
    yOfs = R.PixelPerfect((yOfs * scale) / parentScale) / scale

    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
end

function R.SetPixelSize(frame, width, height)
    local scale = frame:GetEffectiveScale()
    width = width and R.PixelPerfect(width * scale) / scale or frame:GetWidth()
    height = height and R.PixelPerfect(height * scale) / scale or frame:GetHeight()
    frame:SetSize(width, height)
end

function R.SetPixelBackdrop(frame, edgeSize)
    local scale = frame:GetEffectiveScale()
    edgeSize = math.floor(edgeSize * scale + 0.5) / scale

    frame:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = edgeSize,
    })
end

function R.CreatePixelLine(parent, orientation, thickness, r, g, b, a)
    local line = parent:CreateTexture(nil, "OVERLAY")
    R.SetPixelSize(line, orientation == "HORIZONTAL" and parent:GetWidth() or thickness,
        orientation == "VERTICAL" and parent:GetHeight() or thickness)
    line:SetColorTexture(r, g, b, a)
    return line
end
