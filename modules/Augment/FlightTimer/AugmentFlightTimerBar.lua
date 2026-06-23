--[[
    Horizon Suite - Augment / FlightTimer - Bar
    The live status bar shown while on a taxi flight: frame creation, layout/
    colour application, the per-frame ticker that advances the bar and
    records the actual flight duration on completion, Shift+Drag positioning,
    and the Preview/ResetPosition pair the Dashboard's Preview/Reset buttons
    call into (see the isAugmentFlightTimer branch in DashboardDetailView.lua).

    Built entirely from Blizzard-native primitives (WHITE8X8 + BackdropTemplate
    + the stock casting-bar spark texture) tinted with flat colours, the same
    restriction Skyriding's bar style applies - no textures/atlases copied
    from InFlight.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local F = Y and Y.FlightTimer
if not F then return end

local L = addon.L
local floor, format, min = math.floor, string.format, math.min

F.Bar = F.Bar or {}
local Bar = F.Bar

local sb, spark, border, timeText, locText
local ratio = 0
local elapsed, totalTime, startTime, throttle = 0, 0, 0, 0
local takeoff, inworld, outworld, ontaxi = nil, nil, nil, nil
local activeEndTime, activeEndText

function Bar.FormatTime(secs)
    if not secs then return "??" end
    secs = floor(secs + 0.5)
    return format(TIMER_MINUTES_DISPLAY, floor(secs / 60), secs % 60)
end

-- ============================================================================
-- FRAME CREATION + LAYOUT
-- ============================================================================

local function EnsureFrame()
    if sb then return end

    sb = CreateFrame("StatusBar", "HorizonFlightTimerBar", UIParent)
    sb:Hide()
    sb:SetMovable(true)
    sb:EnableMouse(true)
    sb:SetClampedToScreen(true)
    sb:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")

    border = CreateFrame("Frame", nil, sb, "BackdropTemplate")
    border:SetFrameStrata("LOW")

    spark = sb:CreateTexture(nil, "OVERLAY")
    spark:Hide()
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    spark:SetWidth(16)
    spark:SetBlendMode("ADD")

    timeText = sb:CreateFontString(nil, "OVERLAY")
    locText  = sb:CreateFontString(nil, "OVERLAY")

    sb:RegisterForDrag("LeftButton")
    sb:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then self:StartMoving() end
    end)
    sb:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        F.SavePosition(point, relPoint, floor(x + 0.5), floor(y + 0.5))
    end)
end

local function RestorePosition()
    local point, relPoint, x, y = F.GetPosition()
    sb:ClearAllPoints()
    if point then
        sb:SetPoint(point, UIParent, relPoint, x, y)
    else
        sb:SetPoint(F.DEFAULT_ANCHOR, UIParent, F.DEFAULT_ANCHOR, x, y)
    end
end

local function SetUnknown()
    sb:SetMinMaxValues(0, 1)
    sb:SetValue(1)
    local r, g, b = F.GetColor("flightTimerUnknownColor")
    sb:SetStatusBarColor(r, g, b, 1)
    spark:Hide()
end

function Bar.ApplyLayout()
    if not sb then return end
    local D = addon.AUGMENT_DEFAULTS

    local width  = tonumber(F.GetDB("flightTimerWidth", D.flightTimerWidth)) or D.flightTimerWidth
    local height = tonumber(F.GetDB("flightTimerHeight", D.flightTimerHeight)) or D.flightTimerHeight
    sb:SetSize(width, height)

    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", sb, "TOPLEFT", -5, 5)
    border:SetPoint("BOTTOMRIGHT", sb, "BOTTOMRIGHT", 5, -5)
    border:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    border:SetBackdropColor(0.05, 0.05, 0.05, 0.7)
    border:SetBackdropBorderColor(0, 0, 0, 0.9)

    local barR, barG, barB = F.GetColor("flightTimerBarColor")
    if activeEndTime then
        sb:SetStatusBarColor(barR, barG, barB, 1)
    else
        SetUnknown()
    end

    spark:SetHeight(height * 2.4)

    local fontPath = F.GetDB("flightTimerFontPath", D.flightTimerFontPath)
    local fontSize = tonumber(F.GetDB("flightTimerFontSize", D.flightTimerFontSize)) or D.flightTimerFontSize
    local fr, fg, fb = F.GetColor("flightTimerFontColor")

    for _, fs in ipairs({ timeText, locText }) do
        fs:SetFont(fontPath, fontSize, "OUTLINE")
        fs:SetShadowColor(0, 0, 0, 1)
        fs:SetShadowOffset(1, -1)
        fs:SetTextColor(fr, fg, fb, 1)
    end

    local layout = F.GetLayout()
    if layout == F.LAYOUT_INLINE then
        timeText:SetJustifyH("RIGHT"); timeText:SetJustifyV("MIDDLE")
        timeText:ClearAllPoints(); timeText:SetPoint("RIGHT", sb, "RIGHT", -4, 0)
        locText:SetJustifyH("LEFT"); locText:SetJustifyV("MIDDLE")
        locText:ClearAllPoints()
        locText:SetPoint("LEFT", sb, "LEFT", 4, 0)
        locText:SetPoint("RIGHT", timeText, "LEFT", -2, 0)
    else
        timeText:SetJustifyH("CENTER"); timeText:SetJustifyV("MIDDLE")
        timeText:ClearAllPoints(); timeText:SetPoint("CENTER", sb, "CENTER", 0, 0)
        locText:SetJustifyH("CENTER"); locText:SetJustifyV("BOTTOM")
        locText:ClearAllPoints()
        locText:SetPoint("BOTTOMLEFT", sb, "TOPLEFT", -24, 3)
        locText:SetPoint("BOTTOMRIGHT", sb, "TOPRIGHT", 24, 3)
    end
end

-- ============================================================================
-- TICKER
-- ============================================================================

local function UpdateTimeDisplay()
    local layout = F.GetLayout()
    local srcName = F.taxiSrcName or "??"
    local dstName = F.taxiDstName or "??"

    if layout == F.LAYOUT_INLINE then
        locText:SetText(dstName)
    elseif layout == F.LAYOUT_TWOLINE then
        locText:SetFormattedText("%s\n%s %s", srcName, L["FLIGHT_TIMER_TO_TEXT"], dstName)
    else
        locText:SetFormattedText("%s %s %s", srcName, L["FLIGHT_TIMER_TO_TEXT"], dstName)
    end
end

local function FinishFlight()
    local D = addon.AUGMENT_DEFAULTS

    if not F.porttaken and F.taxiSrc then
        local bucket = F.noFactionZoneNodes[F.taxiSrc] and "FactionlessZones" or F.playerFaction
        local oldTime = F.GetDstNodes(F.taxiSrc)
        oldTime = oldTime and oldTime[F.taxiDst]
        local newTime = floor(totalTime + 0.5)

        if not oldTime or math.abs(newTime - oldTime) > 2 then
            F.SetLearnedTime(bucket, F.taxiSrc, F.taxiDst, newTime)
            if F.GetDB("flightTimerChatLog", D.flightTimerChatLog) then
                addon.HSPrint(format(
                    oldTime and L["FLIGHT_TIMER_TIME_UPDATED"] or L["FLIGHT_TIMER_TIME_ADDED"],
                    F.taxiSrcName or "??", F.taxiDstName or "??", Bar.FormatTime(newTime)))
            end
        end
    end

    F.taxiSrcName, F.taxiSrc, F.taxiDstName, F.taxiDst = nil, nil, nil, nil
    activeEndTime, activeEndText = nil, nil
    sb:Hide()
end

local function OnUpdate(self, dt)
    elapsed = elapsed + dt
    if elapsed < throttle then return end
    totalTime = GetTime() - startTime
    elapsed = 0

    if takeoff then
        if UnitOnTaxi("player") then
            takeoff, ontaxi = nil, true
            elapsed, totalTime, startTime = throttle - 0.01, 0, GetTime()
        elseif totalTime > 5 then
            sb:Hide()
            self:SetScript("OnUpdate", nil)
        end
        return
    end

    if ontaxi and not inworld then return end
    if not UnitOnTaxi("player") then ontaxi = nil end

    if not ontaxi then
        FinishFlight()
        self:SetScript("OnUpdate", nil)
        return
    end

    local D = addon.AUGMENT_DEFAULTS
    if activeEndTime then
        if totalTime - 2 > activeEndTime then
            SetUnknown()
            activeEndTime, activeEndText = nil, nil
        else
            local curTime = math.max(0, math.min(totalTime, activeEndTime))
            sb:SetValue(activeEndTime - curTime)
            spark:SetPoint("CENTER", sb, "LEFT", curTime * ratio, 0)

            local value = F.GetDB("flightTimerCountUp", D.flightTimerCountUp) and curTime or (activeEndTime - curTime)
            timeText:SetFormattedText("%s / %s", Bar.FormatTime(value), activeEndText)
        end
    else
        timeText:SetFormattedText("%s / %s", Bar.FormatTime(totalTime), activeEndText or "??")
    end
end

-- ============================================================================
-- WORLD-TRANSITION BOOKKEEPING (mounts/portals can briefly drop the player out
-- of the world mid-flight; keep the elapsed-time base consistent across it)
-- ============================================================================

local watcherFrame = CreateFrame("Frame")

watcherFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LEAVING_WORLD" then
        inworld = nil
        outworld = GetTime()
    elseif event == "PLAYER_ENTERING_WORLD" then
        inworld = true
        if outworld then startTime = startTime - (outworld - GetTime()) end
        outworld = nil
    elseif event == "PLAYER_CONTROL_GAINED" then
        if inworld and sb and sb:IsShown() then
            ontaxi = nil
            OnUpdate(sb, 3)
        end
        watcherFrame:UnregisterEvent("LFG_PROPOSAL_DONE")
        watcherFrame:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED")
        watcherFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        watcherFrame:UnregisterEvent("PLAYER_LEAVING_WORLD")
        watcherFrame:UnregisterEvent("PLAYER_CONTROL_GAINED")
    elseif event == "LFG_PROPOSAL_DONE" or event == "LFG_PROPOSAL_SUCCEEDED" then
        F.porttaken = true
    end
end)

-- ============================================================================
-- PUBLIC API
-- ============================================================================

-- @param endTime number|nil  seconds, or nil if unknown (shows the
--   "unknown duration" fill instead of a countdown/up)
function Bar.Start(endTime)
    local D = addon.AUGMENT_DEFAULTS
    local width = tonumber(F.GetDB("flightTimerWidth", D.flightTimerWidth)) or D.flightTimerWidth

    EnsureFrame()
    RestorePosition()
    Bar.ApplyLayout()

    activeEndTime = endTime
    activeEndText = Bar.FormatTime(endTime)

    if endTime then
        sb:SetMinMaxValues(0, endTime)
        sb:SetValue(endTime)
        ratio = width / endTime
        spark:SetPoint("CENTER", sb, "LEFT", 0, 0)
        local r, g, b = F.GetColor("flightTimerBarColor")
        sb:SetStatusBarColor(r, g, b, 1)
        spark:Show()
    else
        SetUnknown()
    end

    UpdateTimeDisplay()
    timeText:SetFormattedText("%s / %s", Bar.FormatTime(0), activeEndText)
    sb:Show()

    F.porttaken = nil
    elapsed, totalTime, startTime = 0, 0, GetTime()
    takeoff, inworld, outworld = true, true, nil
    throttle = min(0.2, (endTime or 50) / width)

    watcherFrame:RegisterEvent("LFG_PROPOSAL_DONE")
    watcherFrame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
    watcherFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    watcherFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcherFrame:RegisterEvent("PLAYER_LEAVING_WORLD")

    sb:SetScript("OnUpdate", OnUpdate)
end

-- Hides the bar immediately without recording a learned time. Called from
-- AugmentFlightTimerEvents.lua's DisableEvents().
function Bar.Stop()
    if not sb then return end
    sb:SetScript("OnUpdate", nil)
    sb:Hide()
    watcherFrame:UnregisterEvent("LFG_PROPOSAL_DONE")
    watcherFrame:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED")
    watcherFrame:UnregisterEvent("PLAYER_CONTROL_GAINED")
    watcherFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    watcherFrame:UnregisterEvent("PLAYER_LEAVING_WORLD")
    activeEndTime, activeEndText = nil, nil
end

-- Briefly shows the bar with sample data so the player can position it. No-ops
-- while disabled (showing a "working" bar would contradict the disabled
-- state) or while a real flight's ticker is already running (Preview would
-- otherwise overwrite the live flight's `ratio`/display state, corrupting it
-- for the rest of that flight).
function Bar.Preview()
    if not F.enabled then return end
    if sb and sb:GetScript("OnUpdate") then return end

    EnsureFrame()
    RestorePosition()
    Bar.ApplyLayout()

    F.taxiSrcName = F.taxiSrcName or L["FLIGHT_TIMER_PREVIEW_SOURCE"]
    F.taxiDstName = F.taxiDstName or L["FLIGHT_TIMER_PREVIEW_DEST"]
    UpdateTimeDisplay()

    local D = addon.AUGMENT_DEFAULTS
    local width = tonumber(F.GetDB("flightTimerWidth", D.flightTimerWidth)) or D.flightTimerWidth
    local previewEnd = 90
    sb:SetMinMaxValues(0, previewEnd)
    sb:SetValue(previewEnd * 0.4)
    ratio = width / previewEnd
    spark:SetPoint("CENTER", sb, "LEFT", previewEnd * 0.6 * ratio, 0)
    spark:Show()
    local r, g, b = F.GetColor("flightTimerBarColor")
    sb:SetStatusBarColor(r, g, b, 1)
    timeText:SetFormattedText("%s / %s", Bar.FormatTime(previewEnd * 0.6), Bar.FormatTime(previewEnd))
    sb:Show()

    F.taxiSrcName, F.taxiDstName = nil, nil
    C_Timer.After(4, function()
        if sb and not sb:GetScript("OnUpdate") then sb:Hide() end
    end)
end

function Bar.ResetPosition()
    F.ClearPosition()
    if sb then RestorePosition() end
end
