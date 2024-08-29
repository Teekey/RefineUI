local R, C, L = unpack(RefineUI)
local frame = CreateFrame("Frame")

local function UpdateNameplateCVars(inCombat)
    local inInstance, instanceType = IsInInstance()
    local inBattleground = UnitInBattleground("player")
    local inGroupContent = (instanceType == 'party' or instanceType == 'raid') or inBattleground

    SetCVar("nameplateMotion", inCombat and 1 or 0)
    SetCVar("nameplateShowFriends", (not inGroupContent and not inCombat) and 1 or 0)
    SetCVar("nameplateShowFriendlyNPCs", inGroupContent and 0 or 1)
end

local function InitializeNameplates()
    -- Set nameplate fonts
    local fontPath = "Interface\\AddOns\\RefineUI\\Media\\Fonts\\Barlow-Bold-Upper.ttf"
    local fontObjects = {
        _G.SystemFont_NamePlate,
        _G.SystemFont_NamePlateFixed,
        _G.SystemFont_LargeNamePlate,
        _G.SystemFont_LargeNamePlateFixed
    }
    for i, fontObject in ipairs(fontObjects) do
        local size = i > 2 and 10 or 8
        fontObject:SetFont(fontPath, size, "OUTLINE")
    end

    -- Set threat-related CVars
    if C.nameplate.enhanceThreat then
        SetCVar("threatWarning", 3)
    end

    -- Set general nameplate CVars
    local generalCVars = {
        nameplateGlobalScale = 1,
        namePlateMinScale = 1,
        namePlateMaxScale = 1,
        nameplateLargerScale = 1,
        nameplateSelectedScale = 1,
        nameplateMinAlpha = .5,
        nameplateMaxAlpha = 1,
        nameplateMaxDistance = 60,
        nameplateMinAlphaDistance = 0,
        nameplateMaxAlphaDistance = 40,
        nameplateOccludedAlphaMult = .1,
        nameplateSelectedAlpha = 1,
        nameplateNotSelectedAlpha = .9,
        nameplateLargeTopInset = 0.08,
        nameplateOtherTopInset = C.nameplate.clamp and 0.08 or -1,
        nameplateOtherBottomInset = C.nameplate.clamp and 0.1 or -1,
        clampTargetNameplateToScreen = C.nameplate.clamp and "1" or "0",
        nameplatePlayerMaxDistance = 60,
        nameplateShowOnlyNames = C.nameplate.onlyName and 1 or 0
    }

    for cvar, value in pairs(generalCVars) do
        SetCVar(cvar, value)
    end

    -- Change nameplate fonts
    local function changeFont(fontObject, size)
        local mult = size or 1
        fontObject:SetFont(C.font.nameplates_font, C.font.nameplates_font_size * mult, C.font.nameplates_font_style)
        fontObject:SetShadowOffset(C.font.nameplates_font_shadow and 1 or 0, C.font.nameplates_font_shadow and -1 or 0)
    end
    changeFont(SystemFont_NamePlateFixed)
    changeFont(SystemFont_LargeNamePlateFixed, 2)

    UpdateNameplateCVars(false)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializeNameplates()
    elseif C.nameplate.combat then
        UpdateNameplateCVars(event == "PLAYER_REGEN_DISABLED")
    end
end)

frame:RegisterEvent("PLAYER_LOGIN")
if C.nameplate.combat then
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end