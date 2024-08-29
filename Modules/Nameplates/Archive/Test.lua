local R, C, L = unpack(RefineUI)
local _, ns = ...
local oUF = ns.oUF
local NP = R.NP or {}
R.NP = NP

----------------------------------------------------------------------------------------
-- Style Function
----------------------------------------------------------------------------------------
local function CreateNameplate(self, unit)
    local main = self
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    local isDead = UnitIsDead(unit)
    local visible = nameplate:IsVisible()
    if not isDead and not visible then
        RunNextFrame(function() main:Show() end)
    end

    self:SetPoint("CENTER", nameplate, "CENTER")
    self:SetSize(C.nameplate.width, C.nameplate.height)

    NP.CreateHealthBar(self, unit)

    NP.CreatePowerBar(self, unit)

    NP.CreateNameText(self)

    if C.nameplate.targetGlow then
        NP.CreateTargetGlow(self)
    end

    NP.CreateCastBar(self)

    NP.CreateRaidIcon(self, unit)

    if C.nameplate.targetIndicator then
        NP.CreateTargetIndicator(self)
    end

    if C.nameplate.classIcons then
        NP.CreateClassIcon(self)
    end

    if C.nameplate.quests then
        NP.CreateQuestIcon(self)
    end


    NP.CreateAuras(self)
    
    table.insert(self.__elements, NP.UpdateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", NP.UpdateTarget, true)

    -- Disable movement via /moveui
    self.disableMovement = true

    if R.PostCreateNameplates then
        R.PostCreateNameplates(self, unit)
    end

    return self
    
end

local function NameplateCallback(self, event, unit, nameplate)
    if not self then
        return
    end
    if unit then
        local unitGUID = UnitGUID(unit)
        self.npcID = unitGUID and select(6, strsplit('-', unitGUID))
        self.unitName = UnitName(unit)
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)
        self:Show()

        if UnitIsUnit(unit, "player") then
            if self.Power then self.Power:Show() end
            self.Name:Hide()
            self.Castbar:SetAlpha(0)
            self.RaidTargetIndicator:SetAlpha(0)
        else
            if self.Power then self.Power:Hide() end
            self.Name:Show()
            self.Castbar:SetAlpha(1)
            self.RaidTargetIndicator:SetAlpha(1)

            if self.widgetsOnly or (UnitWidgetSet(unit) and UnitIsOwnerOrControllerOfUnit("player", unit)) then
                self.Health:SetAlpha(0)
                -- self.Level:SetAlpha(0)
                self.Name:SetAlpha(0)
                self.Castbar:SetAlpha(0)
            else
                self.Health:SetAlpha(1)
                -- self.Level:SetAlpha(1)
                self.Name:SetAlpha(1)
                self.Castbar:SetAlpha(1)
            end

            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate.UnitFrame then
                if nameplate.UnitFrame.WidgetContainer then
                    nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
                end
            end

            if C.nameplate.onlyName then
                if UnitIsFriend("player", unit) then
                    self.Health:SetAlpha(0)
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("CENTER", self, "CENTER", 0, 0)
                    -- self.Level:SetAlpha(0)
                    self.Castbar:SetAlpha(0)
                    if C.nameplate.targetGlow then
                        self.Glow:SetAlpha(0)
                    end
                else
                    self.Health:SetAlpha(1)
                    self.Name:ClearAllPoints()
                    self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 3)
                    -- self.Level:SetAlpha(1)
                    self.Castbar:SetAlpha(1)
                    if C.nameplate.targetGlow then
                        self.Glow:SetAlpha(1)
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- Register Style and Spawn NamePlates
----------------------------------------------------------------------------------------
oUF:RegisterStyle("RefineUINameplates", CreateNameplate)
oUF:SetActiveStyle("RefineUINameplates")
oUF:SpawnNamePlates("RefineUINameplates", NameplateCallback)
