local R, C, L = unpack(RefineUI)
----------------------------------------------------------------------------------------
--	Spin camera while afk(by Telroth and Eclipse)
----------------------------------------------------------------------------------------
if C.misc.afk == true then
    local spinning
    local originalZoom

    local function ZoomIn()
        originalZoom = GetCameraZoom()
        local targetZoom = 4  -- Adjust this value to set how close you want to zoom
        local zoomSpeed = 0.1  -- Adjust this to change how fast the camera zooms

        local zoomFrame = CreateFrame("Frame")
        zoomFrame:SetScript("OnUpdate", function(self)
            local currentZoom = GetCameraZoom()
            if currentZoom > targetZoom then
                CameraZoomIn(zoomSpeed)
            else
                self:SetScript("OnUpdate", nil)
            end
        end)
    end

    local function ZoomOut()
        if originalZoom then
            local zoomFrame = CreateFrame("Frame")
            zoomFrame:SetScript("OnUpdate", function(self)
                local currentZoom = GetCameraZoom()
                if currentZoom < originalZoom then
                    CameraZoomOut(0.1)
                else
                    self:SetScript("OnUpdate", nil)
                end
            end)
        end
    end

    local function SpinStart()
        spinning = true
        MoveViewRightStart(0.1)
        UIParent:Hide()
        ZoomIn()
        DoEmote("SIT")
    end

    local function SpinStop()
        if not spinning then return end
        spinning = nil
        MoveViewRightStop()
        if InCombatLockdown() then return end
        UIParent:Show()
        ZoomOut()
    end

    local SpinCam = CreateFrame("Frame")
    SpinCam:RegisterEvent("PLAYER_LEAVING_WORLD")
    SpinCam:RegisterEvent("PLAYER_FLAGS_CHANGED")
    SpinCam:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LEAVING_WORLD" then
            SpinStop()
        else
            if UnitIsAFK("player") and not InCombatLockdown() then
                SpinStart()
            else
                SpinStop()
            end
        end
    end)
end
