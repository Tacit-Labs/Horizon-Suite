--[[
    Horizon Suite - Augment / Skyriding - Derby Racing
    Dragonriding Derby races drive Vigor through a UI widget
    (UPDATE_UI_WIDGET + C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo)
    instead of the normal spell-charge API the rest of this mini-module reads,
    so it needs its own path. Hides Blizzard's native fill-up-frame widget the
    same way Glider does and feeds the same snapshot shape Core.UpdateUI
    produces into whichever style renderer is active, so BarStyle/CircularStyle
    stay agnostic of which data source fed them.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

S.Derby = S.Derby or {}
local Derby = S.Derby

local VIGOR_WIDGET_SET_ID = 283
local FALLBACK_WIDGET_ID  = 4460

-- Empirically the four/five/six-charge variants of this widget don't reach
-- 100% fill at numFullFrames == numTotalFrames; these multipliers (one per
-- possible numTotalFrames) normalise the widget's own fill percentage into a
-- clean 0-1 range.
local PERCENT_MULTI = { [1] = 0.1666, [2] = 0.3333, [3] = 0.4998, [4] = 0.6664, [5] = 0.8330, [6] = 1.0 }

local widgetID
local isWidgetShown = false
local lastFill = 100
local lastNumFullFrames = 0

local function ProcessWidgets()
    if not UIWidgetPowerBarContainerFrame or not UIWidgetPowerBarContainerFrame.widgetFrames then return end
    local shown = false
    for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
        if widget and widget.widgetType == 24 and widget.widgetSetID == VIGOR_WIDGET_SET_ID then
            local info = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widget.widgetID)
            if info then
                shown = shown or (info.shownState == 1 and info.numTotalFrames > 0)
                widgetID = (info.shownState == 1 and info.numTotalFrames > 0) and widget.widgetID or FALLBACK_WIDGET_ID
            end
            -- Our own gauge replaces this widget entirely during Derby races.
            widget:Hide()
        end
    end
    isWidgetShown = shown
end

-- @param widget table  the single widget payload from the UPDATE_UI_WIDGET event
function Derby.Update(widget)
    if not S.API:IsDerbyRacing() then return end
    if not widget or widget.widgetSetID ~= VIGOR_WIDGET_SET_ID then return end

    ProcessWidgets()
    if widget.widgetID ~= widgetID then return end

    local D = addon.AUGMENT_DEFAULTS
    if not S.GetDB("skyridingDerbyEnabled", D.skyridingDerbyEnabled) then return end

    if not S.API:IsSkyriding() or not isWidgetShown then
        lastNumFullFrames = 6
        S.HideAnim()
        return
    end

    local info = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(widgetID)
    if not info then
        S.HideAnim()
        return
    end

    if info.numTotalFrames > 0 then
        S.ShowAnim()
    end

    -- The widget initially reports numFullFrames using the previous race's
    -- stale fillValue for one tick; treat that specific combination as zero.
    local fillValue = (info.numFullFrames + info.fillValue == 1 + lastFill) and 0 or info.fillValue
    lastFill = info.numFullFrames + info.fillValue
    lastNumFullFrames = lastNumFullFrames or info.numFullFrames

    local rawPercent = info.numTotalFrames == 0 and 0
        or (info.numFullFrames + fillValue / (info.fillMax + 0.0000001)) / info.numTotalFrames
    local adjustedPercent = (PERCENT_MULTI[info.numTotalFrames] or 0) * rawPercent

    local snapshot = {
        isCharging = adjustedPercent < 1, charges = adjustedPercent * 6, maxCharges = 6,
        chargeStart = 0, chargeDuration = 0, chargeModRate = 1,
        isThrill = false, isGroundSkimming = false,
        swCharges = 0, swMaxCharges = 0,
        surgeStart = 0, surgeDuration = 0,
        forwardSpeed = S.API:GetForwardSpeed(), speedScale = S.API:GetSpeedScaleReciprocal(),
    }

    if S.NotifyCharges then S.NotifyCharges(snapshot.charges) end
    local style = S.GetActiveStyleModule()
    if style and style.Update then style.Update(snapshot) end

    lastNumFullFrames = info.numFullFrames
end
