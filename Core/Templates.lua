local R, C, L = unpack(RefineUI)

----------------------------------------------------------------------------------------
-- Upvalues
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame, Mixin, unpack, pairs, gsub, strmatch = CreateFrame, Mixin, unpack, pairs, string.gsub, string.match
local rad, min, max = math.rad, math.min, math.max
local UIFrameFadeIn, UIFrameFadeOut = UIFrameFadeIn, UIFrameFadeOut
local BackdropTemplateMixin = BackdropTemplateMixin

----------------------------------------------------------------------------------------
-- Local variables
----------------------------------------------------------------------------------------
local backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdropColor)
local borderr, borderg, borderb, bordera = unpack(C.media.borderColor)

local Mult = R.screenHeight > 1200 and R.PixelPerfect(1) or R.mult

----------------------------------------------------------------------------------------
-- Utility functions
----------------------------------------------------------------------------------------
local function SetColor(r, g, b, a)
    return { r = r, g = g, b = b, a = a }
end

----------------------------------------------------------------------------------------
-- Position functions
----------------------------------------------------------------------------------------
local function SetOutside(obj, anchor, xOffset, yOffset)
    xOffset, yOffset = xOffset or 2, yOffset or 2
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end
    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
    xOffset, yOffset = xOffset or 2, yOffset or 2
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then obj:ClearAllPoints() end
    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

----------------------------------------------------------------------------------------
-- Font functions
----------------------------------------------------------------------------------------
local function FontString(parent, name, fontName, fontHeight, fontStyle)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(fontName, fontHeight, fontStyle)
    fs:SetJustifyH("LEFT")

    if name then
        parent[name] = fs
    else
        parent.text = fs
    end

    return fs
end

----------------------------------------------------------------------------------------
-- Template functions
----------------------------------------------------------------------------------------
local function CreateOverlay(f)
    if f.overlay then return end
    local overlay = f:CreateTexture("$parentOverlay", "BORDER")
    overlay:SetInside()
    overlay:SetTexture(C.media.blank)
    overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
    f.overlay = overlay
end

local function CreateBorder(f, insetX, insetY)
    insetX = insetX or 6  -- Default inset value for X
    insetY = insetY or 6  -- Default inset value for Y
    f.border = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", -insetX, insetY)
    f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", insetX, -insetY)
    f.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 12,
    })
    f.border:SetBackdropBorderColor(unpack(C.media.borderColor))
    f.border:SetFrameStrata("MEDIUM")
end

local function GetTemplate(t)
    if t == "ClassColor" then
        borderr, borderg, borderb, bordera = unpack(C.media.borderColor)
    else
        borderr, borderg, borderb, bordera = unpack(C.media.borderColor)
    end
    backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdropColor)
end

local function SetTemplate(f, t)
    Mixin(f, BackdropTemplateMixin)
    GetTemplate(t)

    f:SetBackdrop({
        bgFile = C.media.blank,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })

    if t == "Anchor" then
        backdropa = 0
    elseif t == "Icon" then
        backdropa = 0
        f:CreateBorder(5, 5)  -- Example of using smaller insets for transparent
    elseif t == "Aura" then
        backdropa = 1
        f:CreateBorder(4, 4)  -- Example of using smaller insets for transparent
    elseif t == "Transparent" then
        backdropa = .5
        f:CreateBorder(4, 4)  -- Example of using smaller insets for transparent
    elseif t == "Zero" then
        backdropa = 0
        f:CreateBorder(4, 4)  -- Example of using smaller insets for transparent
    elseif t == "Overlay" then
        backdropa = 1
        f:CreateBorder(4, 4)  -- Example of using smaller insets for overlay
        f:CreateOverlay()
    else
        f:CreateBorder()  -- Default border
        backdropa = C.media.backdropColor[4]
    end

    f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    if f.border then
        f.border:SetBackdropBorderColor(borderr, borderg, borderb, bordera)
    end
end

local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
    Mixin(f, BackdropTemplateMixin)
    GetTemplate(t)

    f:SetSize(w, h)
    f:SetFrameLevel(3)
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint(a1, p, a2, x, y)
    f:SetBackdrop({ bgFile = C.media.blank })

    f.border = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", -4, 4)
    f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 4, -4)
    f.border:SetBackdrop({
        edgeFile = C.media.border,
        edgeSize = 12,
    })

    if t == "Transparent" then
        backdropa = C.media.backdrop_alpha
        f:CreateBorder(true, true)
    elseif t == "Overlay" then
        backdropa = 1
        f:CreateOverlay()
    elseif t == "Invisible" then
        backdropa, bordera = 0, 0
    else
        backdropa = C.media.backdropColor[4]
    end

    f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    f.border:SetBackdropBorderColor(borderr, borderg, borderb, bordera)
end

local function CreateBackdrop(f, t)
    if f.backdrop then return end
    t = t or "Default"

    local b = CreateFrame("Frame", "$parentBackdrop", f)
    b:SetOutside()
    b:SetTemplate(t)

    if f:GetFrameLevel() - 1 >= 0 then
        b:SetFrameLevel(f:GetFrameLevel() - 1)
    else
        b:SetFrameLevel(0)
    end

    f.backdrop = b
end

----------------------------------------------------------------------------------------
-- StripTextures function
----------------------------------------------------------------------------------------
local StripTexturesBlizzFrames = {
    "Inset", "inset", "InsetFrame", "LeftInset", "RightInset", "NineSlice", "BG", "Bg", "border", "Border",
    "BorderFrame", "bottomInset", "BottomInset", "bgLeft", "bgRight", "FilligreeOverlay", "PortraitOverlay",
    "ArtOverlayFrame", "Portrait", "portrait", "ScrollFrameBorder",
}

local function StripTextures(object, kill)
    if object.GetNumRegions then
        for _, region in next, { object:GetRegions() } do
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                if kill then
                    region:Kill()
                else
                    region:SetTexture("")
                    region:SetAtlas("")
                end
            end
        end
    end

    local frameName = object.GetName and object:GetName()
    for _, blizzard in pairs(StripTexturesBlizzFrames) do
        local blizzFrame = object[blizzard] or frameName and _G[frameName .. blizzard]
        if blizzFrame then
            blizzFrame:StripTextures(kill)
        end
    end
end

----------------------------------------------------------------------------------------
-- Kill object function
----------------------------------------------------------------------------------------
local HiddenFrame = CreateFrame("Frame")
HiddenFrame:Hide()
R.Hider = HiddenFrame

local function Kill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(HiddenFrame)
    else
        object.Show = R.dummy
    end
    object:Hide()
end

----------------------------------------------------------------------------------------
-- Style functions
----------------------------------------------------------------------------------------
local function StyleButton(button, t, size, setBackdrop)
    size = size or 2
    if button.SetHighlightTexture and not button.hover then
        local hover = button:CreateTexture()
        hover:SetColorTexture(1, 1, 1, 0.3)
        hover:SetPoint("TOPLEFT", button, size, -size)
        hover:SetPoint("BOTTOMRIGHT", button, -size, size)
        button.hover = hover
        button:SetHighlightTexture(hover)
    end

    if not t and button.SetPushedTexture and not button.pushed then
        local pushed = button:CreateTexture()
        pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
        pushed:SetPoint("TOPLEFT", button, size, -size)
        pushed:SetPoint("BOTTOMRIGHT", button, -size, size)
        button.pushed = pushed
        button:SetPushedTexture(pushed)
    end

    if button.SetCheckedTexture and not button.checked then
        local checked = button:CreateTexture()
        checked:SetColorTexture(0, 1, 0, 0.3)
        checked:SetPoint("TOPLEFT", button, size, -size)
        checked:SetPoint("BOTTOMRIGHT", button, -size, size)
        button.checked = checked
        button:SetCheckedTexture(checked)
    end

    local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"]
    if cooldown then
        cooldown:ClearAllPoints()
        cooldown:SetPoint("TOPLEFT", button, size, -size)
        cooldown:SetPoint("BOTTOMRIGHT", button, -size, size)
    end
end

local function SetModifiedBackdrop(self)
    if self:IsEnabled() then
        self:SetBackdropBorderColor(unpack(C.media.borderColor))
        if self.overlay then
            self.overlay:SetVertexColor(C.media.borderColor[1] * 0.3, C.media.borderColor[2] * 0.3,
                C.media.borderColor[3] * 0.3, 1)
        end
    end
end

local function SetOriginalBackdrop(self)
    self:SetBackdropBorderColor(unpack(C.media.borderColor))
    if self.overlay then
        self.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
    end
end

local function SkinButton(f, strip)
    if strip then f:StripTextures() end

    f:SetNormalTexture(0)
    f:SetHighlightTexture(0)
    f:SetPushedTexture(0)
    f:SetDisabledTexture(0)

    if f.Left then f.Left:SetAlpha(0) end
    if f.Right then f.Right:SetAlpha(0) end
    if f.Middle then f.Middle:SetAlpha(0) end
    if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
    if f.RightSeparator then f.RightSeparator:SetAlpha(0) end
    if f.Flash then f.Flash:SetAlpha(0) end

    if f.TopLeft then f.TopLeft:Hide() end
    if f.TopRight then f.TopRight:Hide() end
    if f.BottomLeft then f.BottomLeft:Hide() end
    if f.BottomRight then f.BottomRight:Hide() end
    if f.TopMiddle then f.TopMiddle:Hide() end
    if f.MiddleLeft then f.MiddleLeft:Hide() end
    if f.MiddleRight then f.MiddleRight:Hide() end
    if f.BottomMiddle then f.BottomMiddle:Hide() end
    if f.MiddleMiddle then f.MiddleMiddle:Hide() end

    f:SetTemplate("Overlay")
    f:HookScript("OnEnter", SetModifiedBackdrop)
    f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinIcon(icon, t, parent)
    parent = parent or icon:GetParent()

    if t then
        icon.b = CreateFrame("Frame", nil, parent)
        icon.b:SetTemplate("Default")
        icon.b:SetOutside(icon)
    else
        parent:CreateBackdrop("Default")
        parent.backdrop:SetOutside(icon)
    end

    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetParent(t and icon.b or parent)
end

local function CropIcon(icon)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    icon:SetInside()
end

local function SkinCloseButton(f, point, text, pixel)
    f:StripTextures()
    f:SetTemplate("Overlay")
    f:SetSize(18, 18)

    if not text then text = "x" end
    if text == "-" then
        f.text = f:CreateTexture(nil, "OVERLAY")
        f.text:SetSize(7, 1)
        f.text:SetPoint("CENTER")
        f.text:SetTexture(C.media.blank)
    else
        f.text = R.FontString(f, nil, C.media.normalFont, C.media.normalFontSize, C.media.normalFontStyle)
        f.text:SetPoint("CENTER", 2, 3)
        f.text:SetText(text)
    end

    if point then
        f:SetPoint("TOPRIGHT", point, "TOPRIGHT", -4, -4)
    else
        f:SetPoint("TOPRIGHT", -4, -4)
    end

    f:HookScript("OnEnter", SetModifiedBackdrop)
    f:HookScript("OnLeave", SetOriginalBackdrop)
end

----------------------------------------------------------------------------------------
-- Scroll Bar Skinning
----------------------------------------------------------------------------------------
local function SkinScrollBar(frame, isMinimal)
    frame:StripTextures()

    local frameName = frame.GetName and frame:GetName()
    local UpButton = frame.ScrollUpButton or frame.ScrollUp or frame.UpButton or frame.Back or
        _G[frameName and frameName .. "ScrollUpButton"] or frame:GetParent().scrollUp
    local DownButton = frame.ScrollDownButton or frame.ScrollDown or frame.DownButton or frame.Forward or
        _G[frameName and frameName .. "ScrollDownButton"] or frame:GetParent().scrollDown
    local ThumbTexture = frame.ThumbTexture or frame.thumbTexture or _G[frameName and frameName .. "ThumbTexture"]
    local newThumb = frame.Back and frame:GetThumb()

    local minimal = isMinimal or (frame.GetWidth and frame:GetWidth() < 10)

    local function SetScrollBarAlpha(self, alpha)
        self:SetAlpha(alpha)
    end

    local function UpdateScrollBarVisibility(self)
        local _, maxValue = self:GetMinMaxValues()
        SetScrollBarAlpha(self, maxValue == 0 and 0 or 1)
    end

    if UpButton and DownButton then
        if not minimal then
            if not UpButton.icon then
                R.SkinNextPrevButton(UpButton, nil, "Up")
                UpButton:SetSize(UpButton:GetWidth() + 7, UpButton:GetHeight() + 7)
            end
            if not DownButton.icon then
                R.SkinNextPrevButton(DownButton, nil, "Down")
                DownButton:SetSize(DownButton:GetWidth() + 7, DownButton:GetHeight() + 7)
            end
        end

        if ThumbTexture then
            ThumbTexture:SetTexture(nil)
            if not frame.thumbbg then
                frame.thumbbg = CreateFrame("Frame", nil, frame)
                frame.thumbbg:SetPoint("TOPLEFT", ThumbTexture, "TOPLEFT", 0, -3)
                frame.thumbbg:SetPoint("BOTTOMRIGHT", ThumbTexture, "BOTTOMRIGHT", 0, 3)
                frame.thumbbg:SetTemplate("Overlay")

                frame:HookScript("OnShow", UpdateScrollBarVisibility)
                frame:HookScript("OnMinMaxChanged", UpdateScrollBarVisibility)
                frame:HookScript("OnDisable", function(self) SetScrollBarAlpha(self, 0) end)
                frame:HookScript("OnEnable", function(self) SetScrollBarAlpha(self, 1) end)
            end
        elseif newThumb then
            if frame.Background then frame.Background:Hide() end
            if frame.Track then frame.Track:DisableDrawLayer("ARTWORK") end
            newThumb:DisableDrawLayer("BACKGROUND")
            newThumb:DisableDrawLayer("ARTWORK")
            
            if not frame.thumbbg then
                frame.thumbbg = CreateFrame("Frame", nil, newThumb)
                frame.thumbbg:SetPoint("TOPLEFT", newThumb, "TOPLEFT", 0, -3)
                frame.thumbbg:SetPoint("BOTTOMRIGHT", newThumb, "BOTTOMRIGHT", 0, 3)
                frame.thumbbg:SetTemplate("Overlay")

                SetScrollBarAlpha(frame, newThumb:IsShown() and 1 or 0)

                hooksecurefunc(newThumb, "Hide", function() SetScrollBarAlpha(frame, 0) end)
                hooksecurefunc(newThumb, "Show", function() SetScrollBarAlpha(frame, 1) end)
                hooksecurefunc(newThumb, "SetShown", function(_, showThumb)
                    SetScrollBarAlpha(frame, showThumb and 1 or 0)
                end)
            end

            if minimal then
                newThumb:SetWidth(12)
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- More style functions
----------------------------------------------------------------------------------------
function R.SkinTab(tab, bg)
    if not tab then return end

    for _, object in pairs({ "LeftDisabled", "MiddleDisabled", "RightDisabled", "Left", "Middle", "Right" }) do
        local tex = tab:GetName() and _G[tab:GetName() .. object]
        if tex then
            tex:SetTexture(nil)
        end
    end

    if tab.GetHighlightTexture and tab:GetHighlightTexture() then
        tab:GetHighlightTexture():SetTexture(nil)
    else
        tab:StripTextures()
    end

    tab.backdrop = CreateFrame("Frame", nil, tab)
    tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
    if bg then
        tab.backdrop:SetTemplate("Overlay")
        tab.backdrop:SetPoint("TOPLEFT", 2, -9)
        tab.backdrop:SetPoint("BOTTOMRIGHT", -2, -2)
    else
        tab.backdrop:SetTemplate("Transparent")
        tab.backdrop:SetPoint("TOPLEFT", 0, -3)
        tab.backdrop:SetPoint("BOTTOMRIGHT", 0, 3)
    end
end

function R.SkinNextPrevButton(btn, left, scroll)
    local normal, pushed, disabled
    local frameName = btn.GetName and btn:GetName()
    local isPrevButton = frameName and
        (string.find(frameName, "Left") or string.find(frameName, "Prev") or string.find(frameName, "Decrement") or string.find(frameName, "Back")) or
        left
    local isScrollUpButton = frameName and string.find(frameName, "ScrollUp") or scroll == "Up"
    local isScrollDownButton = frameName and string.find(frameName, "ScrollDown") or scroll == "Down"

    btn:StripTextures()

    if scroll == "Up" or scroll == "Down" or scroll == "Any" then
        normal = nil
        pushed = nil
        disabled = nil
    end

    if not normal then
        if isPrevButton then
            normal = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
        elseif isScrollUpButton then
            normal = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up"
        elseif isScrollDownButton then
            normal = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"
        else
            normal = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"
        end
    end

    btn:SetNormalTexture(normal)
    btn:SetPushedTexture(pushed)
    btn:SetDisabledTexture(disabled)

    btn:SetTemplate("Overlay")
    btn:SetSize(btn:GetWidth() - 7, btn:GetHeight() - 7)

    if normal and pushed and disabled then
        btn:GetNormalTexture():SetTexCoord(0.3, 0.29, 0.3, 0.81, 0.65, 0.29, 0.65, 0.81)
        if btn:GetPushedTexture() then
            btn:GetPushedTexture():SetTexCoord(0.3, 0.35, 0.3, 0.81, 0.65, 0.35, 0.65, 0.81)
        end
        if btn:GetDisabledTexture() then
            btn:GetDisabledTexture():SetTexCoord(0.3, 0.29, 0.3, 0.75, 0.65, 0.29, 0.65, 0.75)
        end

        btn:GetNormalTexture():ClearAllPoints()
        btn:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
        btn:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
        if btn:GetDisabledTexture() then
            btn:GetDisabledTexture():SetAllPoints(btn:GetNormalTexture())
        end
        if btn:GetPushedTexture() then
            btn:GetPushedTexture():SetAllPoints(btn:GetNormalTexture())
        end
        if btn:GetHighlightTexture() then
            btn:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
            btn:GetHighlightTexture():SetAllPoints(btn:GetNormalTexture())
        end
    end
end

----------------------------------------------------------------------------------------
-- Add API to objects
----------------------------------------------------------------------------------------
local function addAPI(object)
    local mt = getmetatable(object).__index
    for k, func in pairs({
        SetOutside = SetOutside,
        SetInside = SetInside,
        CreateOverlay = CreateOverlay,
        CreateBorder = CreateBorder,
        SetTemplate = SetTemplate,
        FontString = R.FontString,
        CreatePanel = CreatePanel,
        CreateBackdrop = CreateBackdrop,
        StripTextures = StripTextures,
        Kill = Kill,
        StyleButton = StyleButton,
        SkinButton = SkinButton,
        SkinIcon = SkinIcon,
        CropIcon = CropIcon,
        SkinCloseButton = SkinCloseButton,
        SkinTab = R.SkinTab,
        SkinNextPrevButton = R.SkinNextPrevButton,
        SkinRotateButton = R.SkinRotateButton,
        SkinEditBox = R.SkinEditBox,
        SkinDropDownBox = R.SkinDropDownBox,
        SkinScrollBar = R.SkinScrollBar
    }) do
        if not object[k] then mt[k] = func end
    end
end

SkinCloseButton = R.SkinCloseButton

----------------------------------------------------------------------------------------
-- Apply API to game objects
----------------------------------------------------------------------------------------
local handled = { ["Frame"] = true }
local object = CreateFrame("Frame")

addAPI(object)
addAPI(object:CreateTexture())
addAPI(object:CreateFontString())

object = EnumerateFrames()
while object do
    if not object:IsForbidden() and not handled[object:GetObjectType()] then
        addAPI(object)
        handled[object:GetObjectType()] = true
    end
    object = EnumerateFrames(object)
end

-- Fix for scroll frames
local scrollFrame = CreateFrame("ScrollFrame")
addAPI(scrollFrame)

----------------------------------------------------------------------------------------
-- Skin functions
----------------------------------------------------------------------------------------
R.SkinFuncs = {}
R.SkinFuncs["RefineUI"] = {}
R.SkinScrollBar = SkinScrollBar
R.FontString = FontString
local function LoadBlizzardSkin(_, event, addon)
    if event == "ADDON_LOADED" then
        for _addon, skinfunc in pairs(R.SkinFuncs) do
            if _addon == addon then
                if type(skinfunc) == "function" then
                    pcall(skinfunc)
                elseif type(skinfunc) == "table" then
                    for _, func in pairs(skinfunc) do
                        pcall(func)
                    end
                end
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        for _addon, skinfunc in pairs(R.SkinFuncs) do
            if C_AddOns.IsAddOnLoaded(_addon) then
                if type(skinfunc) == "function" then
                    pcall(skinfunc)
                elseif type(skinfunc) == "table" then
                    for _, func in pairs(skinfunc) do
                        pcall(func)
                    end
                end
            end
        end
        R.SkinFuncs["RefineUI"] = nil
    end
end

local BlizzardSkinLoader = CreateFrame("Frame")
BlizzardSkinLoader:RegisterEvent("ADDON_LOADED")
BlizzardSkinLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
BlizzardSkinLoader:SetScript("OnEvent", LoadBlizzardSkin)

----------------------------------------------------------------------------------------
-- Additional utility functions
----------------------------------------------------------------------------------------
function R.ReplaceIconString(frame, text)
    if not text then text = frame:GetText() end
    if not text or text == "" then return end

    local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
    if count > 0 then frame:SetFormattedText("%s", newText) end
end

----------------------------------------------------------------------------------------
-- Icon border coloring
----------------------------------------------------------------------------------------
local iconColors = {
    ["uncollected"] = { r = borderr, g = borderg, b = borderb },
    ["gray"]        = { r = borderr, g = borderg, b = borderb },
    ["white"]       = { r = borderr, g = borderg, b = borderb },
    ["green"]       = BAG_ITEM_QUALITY_COLORS[2],
    ["blue"]        = BAG_ITEM_QUALITY_COLORS[3],
    ["purple"]      = BAG_ITEM_QUALITY_COLORS[4],
    ["orange"]      = BAG_ITEM_QUALITY_COLORS[5],
    ["artifact"]    = BAG_ITEM_QUALITY_COLORS[6],
    ["account"]     = BAG_ITEM_QUALITY_COLORS[7]
}

function R.SkinIconBorder(frame, parent)
    local border = parent or frame:GetParent().backdrop
    frame:SetAlpha(0)
    hooksecurefunc(frame, "SetVertexColor", function(self, r, g, b)
        if r ~= BAG_ITEM_QUALITY_COLORS[1].r or g ~= BAG_ITEM_QUALITY_COLORS[1].g then
            border:SetBackdropBorderColor(r, g, b)
        else
            border:SetBackdropBorderColor(unpack(C.media.borderColor))
        end
    end)

    hooksecurefunc(frame, "SetAtlas", function(self, atlas)
        local atlasAbbr = atlas and strmatch(atlas, "%-(%w+)$")
        local color = atlasAbbr and iconColors[atlasAbbr]
        if color then
            border:SetBackdropBorderColor(color.r, color.g, color.b)
        end
    end)

    hooksecurefunc(frame, "Hide", function(self)
        border:SetBackdropBorderColor(unpack(C.media.borderColor))
    end)

    hooksecurefunc(frame, "SetShown", function(self, show)
        if not show then
            border:SetBackdropBorderColor(unpack(C.media.borderColor))
        end
    end)
end

----------------------------------------------------------------------------------------
-- Pet Battle Hider
----------------------------------------------------------------------------------------
R_PetBattleFrameHider = CreateFrame("Frame", "RefineUI_PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
R_PetBattleFrameHider:SetAllPoints(UIParent)
R_PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(R_PetBattleFrameHider, "visibility", "[petbattle] hide; show")

return R
