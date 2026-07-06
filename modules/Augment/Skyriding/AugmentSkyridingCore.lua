--[[
    Horizon Suite - Augment / Skyriding - Core
    Frame creation, style dispatch (Bar vs Circular — AugmentSkyridingBarStyle.lua
    / AugmentSkyridingCircularStyle.lua own the actual visuals), position
    persistence, and native Blizzard Edit Mode integration. Mirrors
    AugmentAlertsCore.lua's HookNativeEditMode/ApplyStoredAnchor pattern, and
    attaches to the Loot Frame's shared Edit Mode checkbox via
    Augment.AddEditModePanelListener (modules/Augment/LootFrame/AugmentCore.lua)
    instead of creating a second one.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

local API = S.API
S.Core = S.Core or {}
local Core = S.Core

local Frame
local editOverlay, editTitle, editHint
local framesCreated = false
local editMode = false
local nativeEditMode = false
local previewTicker
local lastChargeCount = 0

-- Plays the shared "Vigor charge gained" sound (Blizzard's own SFX kit used
-- by the game's default Skyriding UI) whenever the floored charge count goes
-- up. Called from both Core.UpdateUI and Derby.lua so the sound fires
-- regardless of which data path produced the snapshot.
-- @param charges number  current (possibly fractional, mid-charge) charge count
function S.NotifyCharges(charges)
    local D = addon.AUGMENT_DEFAULTS
    local floored = math.floor(charges or 0)
    if floored > lastChargeCount and S.GetDB("skyridingSoundEnabled", D.skyridingSoundEnabled) then
        pcall(PlaySound, 201528, "SFX")
    end
    lastChargeCount = floored
end

-- ============================================================================
-- SCALE
-- ============================================================================

function S.Scale(v)
    local D = addon.AUGMENT_DEFAULTS
    local scale = tonumber(S.GetDB("skyridingScale", D.skyridingScale)) or D.skyridingScale
    return v * scale
end

-- ============================================================================
-- POSITION
-- ============================================================================

function S.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, y = S.GetPosition()
    point    = point    or S.DEFAULT_ANCHOR
    relPoint = relPoint or S.DEFAULT_ANCHOR
    x = tonumber(x) or S.DEFAULT_X
    y = tonumber(y) or S.DEFAULT_Y
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, x, y)
end

-- After StartMoving/StopMovingOrSizing, WoW re-anchors internally to
-- ("TOPLEFT", UIParent, "BOTTOMLEFT", screenX, screenTopY). Recompute
-- explicitly for our BOTTOM/BOTTOM default instead of trusting GetPoint()
-- (same reasoning as AugmentAlertsCore.lua's SaveFramePosition).
local function SaveFramePosition()
    local left, right, bottom = Frame:GetLeft(), Frame:GetRight(), Frame:GetBottom()
    if not left or not right or not bottom then return end
    local centerX = (left + right) / 2
    local x = math.floor(centerX - (UIParent:GetLeft() + UIParent:GetRight()) / 2 + 0.5)
    local y = math.floor(bottom - UIParent:GetBottom() + 0.5)
    S.SavePosition("BOTTOM", "BOTTOM", x, y)
end

function S.RestoreSavedPosition()
    if not framesCreated then return end
    S.ApplyStoredAnchor(Frame)
end

function S.ResetPosition()
    if not framesCreated then return end
    S.ClearPosition()
    S.ApplyStoredAnchor(Frame)
end

-- ============================================================================
-- STYLE DISPATCH
-- ============================================================================

function S.GetActiveStyleModule()
    if S.GetStyle() == S.STYLE_CIRCULAR then return S.CircularStyle end
    return S.BarStyle
end

function S.ApplyActiveStyle()
    if not framesCreated then return end
    local active = S.GetStyle()
    if S.BarStyle and S.BarStyle.SetActive then S.BarStyle.SetActive(active == S.STYLE_BAR) end
    if S.CircularStyle and S.CircularStyle.SetActive then S.CircularStyle.SetActive(active == S.STYLE_CIRCULAR) end
end

-- ============================================================================
-- SHOW / HIDE ANIMATION
-- ============================================================================

local function CreateAnimations()
    Frame.AnimShow = Frame:CreateAnimationGroup()
    Frame.AnimShow:SetToFinalAlpha(true)
    Frame.AnimShow:SetScript("OnPlay", function() Frame:Show() end)
    local showAlpha = Frame.AnimShow:CreateAnimation("Alpha")
    showAlpha:SetFromAlpha(0)
    showAlpha:SetToAlpha(1)
    showAlpha:SetDuration(0.3)
    showAlpha:SetSmoothing("OUT")

    Frame.AnimHide = Frame:CreateAnimationGroup()
    Frame.AnimHide:SetToFinalAlpha(true)
    Frame.AnimHide:SetScript("OnFinished", function()
        C_Timer.After(0, function()
            if editMode or nativeEditMode then return end
            Frame:Hide()
        end)
    end)
    local hideAlpha = Frame.AnimHide:CreateAnimation("Alpha")
    hideAlpha:SetFromAlpha(1)
    hideAlpha:SetToAlpha(0)
    hideAlpha:SetDuration(0.4)
    hideAlpha:SetSmoothing("OUT")
end

function S.ShowAnim()
    if not framesCreated then return end
    if not (Frame:IsShown() or Frame.AnimShow:IsPlaying()) then
        Frame.AnimHide:Stop()
        Frame.AnimShow:Play()
    end
end

function S.HideAnim()
    if not framesCreated then return end
    if editMode or nativeEditMode then return end
    if Frame:IsShown() and not Frame.AnimHide:IsPlaying() then
        Frame.AnimShow:Stop()
        Frame.AnimHide:Play()
    end
end

-- ============================================================================
-- LAZY INIT — called once from Module.lua's Enable() (DB is ready at that point)
-- ============================================================================

function S.InitFrames()
    if framesCreated then return end
    framesCreated = true

    Frame = CreateFrame("Frame", "HorizonSuiteSkyridingAnchor", UIParent)
    Frame:SetSize(S.Scale(220), S.Scale(90))
    S.ApplyStoredAnchor(Frame)
    Frame:Hide()
    Frame:SetClampedToScreen(true)
    Frame:SetFrameLevel(1000)

    editOverlay = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
    editOverlay:SetAllPoints(Frame)
    editOverlay:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editOverlay:SetBackdropColor(0, 0, 0, 0.5)
    editOverlay:SetBackdropBorderColor(0.45, 0.85, 0.55, 0.8)
    editOverlay:SetFrameLevel(Frame:GetFrameLevel() + 10)
    editOverlay:EnableMouse(false)
    editOverlay:RegisterForDrag("LeftButton")
    editOverlay:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        Frame:SetMovable(true)
        Frame:StartMoving()
    end)
    editOverlay:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        Frame:StopMovingOrSizing()
        Frame:SetMovable(false)
        SaveFramePosition()
    end)
    editOverlay:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            S.Preview()
        end
    end)
    editOverlay:Hide()

    editTitle = editOverlay:CreateFontString(nil, "OVERLAY")
    editTitle:SetFontObject(GameFontNormalLarge)
    editTitle:SetTextColor(0.45, 0.85, 0.55, 1)
    editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
    editTitle:SetText("SKYRIDING VIGOR AREA")

    editHint = editOverlay:CreateFontString(nil, "OVERLAY")
    editHint:SetFontObject(GameFontNormalSmall)
    editHint:SetTextColor(0.7, 0.7, 0.7, 1)
    editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
    editHint:SetText("Drag · Shift-click preview")

    CreateAnimations()

    if S.BarStyle and S.BarStyle.Init then S.BarStyle.Init(Frame) end
    if S.CircularStyle and S.CircularStyle.Init then S.CircularStyle.Init(Frame) end
    S.ApplyActiveStyle()

    S.Frame = Frame
    S.HookNativeEditMode()
end

-- ============================================================================
-- MAIN REFRESH
-- ============================================================================

-- @param event string|nil  the triggering event, unused beyond logging today
function Core.UpdateUI(event)
    if not framesCreated then return end
    if editMode or nativeEditMode then return end
    if not addon:IsModuleEnabled("augment") then return end

    if API:IsDerbyRacing() or not API:IsSkyriding() then
        S.HideAnim()
        return
    end

    local isCharging, charges, maxCharges, chargeStart, chargeDuration, chargeModRate, isThrill, isGroundSkimming = API:GetVigorInfo()

    local D = addon.AUGMENT_DEFAULTS
    if (not API:IsGliding()) and (not isCharging) and S.GetDB("skyridingHideWhenGroundedFull", D.skyridingHideWhenGroundedFull) then
        S.HideAnim()
        return
    end

    local _, swCharges, swMaxCharges = API:GetSecondWindInfo()
    local surgeStart, surgeDuration = API:GetWhirlingSurgeInfo()

    local snapshot = {
        isCharging = isCharging, charges = charges, maxCharges = maxCharges,
        chargeStart = chargeStart, chargeDuration = chargeDuration, chargeModRate = chargeModRate,
        isThrill = isThrill, isGroundSkimming = isGroundSkimming,
        swCharges = swCharges, swMaxCharges = swMaxCharges,
        surgeStart = surgeStart, surgeDuration = surgeDuration,
        forwardSpeed = API:GetForwardSpeed(), speedScale = API:GetSpeedScaleReciprocal(),
    }

    S.ShowAnim()
    S.NotifyCharges(charges)
    local style = S.GetActiveStyleModule()
    if style and style.Update then style.Update(snapshot) end
end
-- Exposed as a plain global-style function too (Events.lua calls S.Core.UpdateUI).
S.Core.UpdateUI = Core.UpdateUI

-- ============================================================================
-- PREVIEW
-- Fakes one in-flight snapshot so the active style can be checked out of
-- combat/flight, matching Alerts' PreviewAlerts() — bypasses the
-- enabled/grounded checks that gate Core.UpdateUI.
-- ============================================================================

function S.Preview()
    if not addon:IsModuleEnabled("augment") then
        if addon.HSPrint then addon.HSPrint("Augment: Module is disabled — enable it first.") end
        return
    end
    S.InitFrames()
    S.RestoreSavedPosition()

    local snapshot = {
        isCharging = true, charges = 4, maxCharges = 6,
        chargeStart = GetTime(), chargeDuration = 10.35, chargeModRate = 1,
        isThrill = false, isGroundSkimming = false,
        swCharges = 1, swMaxCharges = 2,
        surgeStart = 0, surgeDuration = 0,
        forwardSpeed = 6, speedScale = 0.011764,
    }

    local function Apply()
        local style = S.GetActiveStyleModule()
        if style and style.Update then style.Update(snapshot) end
    end

    S.ShowAnim()
    Apply()
    if previewTicker then previewTicker:Cancel() end
    previewTicker = C_Timer.NewTicker(0.1, Apply, 30)
    C_Timer.After(3, function()
        if previewTicker then previewTicker:Cancel(); previewTicker = nil end
        if not (editMode or nativeEditMode) then S.HideAnim() end
    end)
end

-- ============================================================================
-- BLIZZARD NATIVE EDIT MODE
-- ============================================================================

function S.ToggleEditMode()
    if not framesCreated then return end
    editMode = not editMode
    if editMode then
        editOverlay:EnableMouse(true)
        editOverlay:Show()
        Frame:Show()
        S.Preview()
    else
        if not nativeEditMode then editOverlay:EnableMouse(false) end
        editOverlay:Hide()
    end
end

function S.HookNativeEditMode()
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        if not framesCreated then return end
        nativeEditMode = true
        local D = addon.AUGMENT_DEFAULTS
        local showOverlay = not addon.GetDB or addon.GetDB("skyridingEditModeShow", D.skyridingEditModeShow) ~= false
        if showOverlay then
            editOverlay:EnableMouse(true)
            editOverlay:Show()
            Frame:Show()
            S.Preview()
        end
    end, "HorizonSuiteAugmentSkyriding")

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        if not framesCreated then return end
        -- Defer to next frame: Blizzard's synchronous EditMode exit chain can
        -- taint secure frame state if we react inline (same reasoning as
        -- LootFrame/Alerts).
        C_Timer.After(0, function()
            nativeEditMode = false
            if not editMode then
                editOverlay:EnableMouse(false)
                editOverlay:Hide()
            end
            SaveFramePosition()
            if not editMode then S.HideAnim() end
        end)
    end, "HorizonSuiteAugmentSkyriding")

    if Y.AddEditModePanelListener then
        Y.AddEditModePanelListener("Skyriding", function(checked)
            if addon.SetDB then addon.SetDB("skyridingEditModeShow", checked) end
            if nativeEditMode and framesCreated then
                if checked then
                    editOverlay:EnableMouse(true)
                    editOverlay:Show()
                    Frame:Show()
                else
                    editOverlay:EnableMouse(false)
                    editOverlay:Hide()
                end
            end
        end)
    end
end
