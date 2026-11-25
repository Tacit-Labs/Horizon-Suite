--[[
    Horizon Suite - Augment / Flight Tracker
    While on a flight path: where you are going, where from, the stops on the
    way and the time left. On landing, a short arrival notice.

    FLOW.
      1. TakeTaxiNode is hooked. The flight map is still open at that moment,
         so the whole route (origin, each hop, destination) is read from the
         taxi API there and held as pending.
      2. A light ticker waits for UnitOnTaxi to turn true, then starts the clock.
         A pending route that never takes off (no money, map closed) expires.
      3. UnitOnTaxi turning false is the landing. The flight time is learned
         (AugmentFlightState.lua) unless the clock is not trustworthy: an early
         landing request, or a flight resumed after a fresh login.

    A reload mid-flight resumes from HorizonDB.flightTimes.active, which keeps
    the take-off epoch, so the clock and the learned time stay right.

    Blizzard: TakeTaxiNode, TaxiNodeName, TaxiNodePosition, TaxiNodeGetType,
    GetNumRoutes, TaxiGetNodeSlot, NumTaxiNodes, GetTaxiMapID,
    C_TaxiMap.GetAllTaxiNodes, C_Map.GetWorldPosFromMapPos, UnitOnTaxi,
    TaxiRequestEarlyLanding.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Flight then return end

local Y = addon.Augment
local F = Y.Flight
local L = addon.L

local PAD          = 12
local LINE_GAP     = 4
local BAR_HEIGHT   = 3
local DOT_SIZE     = 7
local END_DOT_SIZE = 9
local TICK         = 0.1
local PENDING_TTL  = 15
local RESUME_MAX_AGE = 3600

local enabled = false
local hooksInstalled = false
local pending          -- { route = , at = GetTime() }
local active           -- { route, est, startedAt, learn, demo, demoLength }
local editMode = false

local banner, arrival, ticker, eventFrame, editOverlay

-- ============================================================================
-- TAXI READING
-- ============================================================================

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c
end

--- slotIndex → nodeID for the open flight map.
local function NodeIdsBySlot(mapID)
    local out = {}
    if not (mapID and C_TaxiMap and C_TaxiMap.GetAllTaxiNodes) then return out end
    local nodes = SafeCall(C_TaxiMap.GetAllTaxiNodes, mapID)
    if type(nodes) ~= "table" then return out end
    for _, info in ipairs(nodes) do
        if info.slotIndex and info.nodeID then out[info.slotIndex] = info.nodeID end
    end
    return out
end

--- World yards for a slot's map position, when the client can say.
local function WorldPos(mapID, slot)
    local x, y = SafeCall(_G.TaxiNodePosition, slot)
    if not (mapID and x and y and C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then
        return nil, nil
    end
    local _, pos = SafeCall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(x, y))
    if not pos then return nil, nil end
    local wx, wy
    if pos.GetXY then
        wx, wy = pos:GetXY()
    else
        wx, wy = pos.x, pos.y
    end
    return tonumber(wx), tonumber(wy)
end

--- The route TakeTaxiNode(slot) is about to fly, read off the open flight map.
--- @param slot number
--- @return table|nil route
local function ReadRoute(slot)
    if not slot then return nil end
    local mapID = SafeCall(_G.GetTaxiMapID)
    local ids = NodeIdsBySlot(mapID)

    local slots = {}
    local hops = tonumber(SafeCall(_G.GetNumRoutes, slot)) or 0
    for hop = 1, hops do
        if hop == 1 then
            slots[#slots + 1] = SafeCall(_G.TaxiGetNodeSlot, slot, hop, true)
        end
        slots[#slots + 1] = SafeCall(_G.TaxiGetNodeSlot, slot, hop, false)
    end

    -- No hop data: origin is the node marked CURRENT, destination the slot.
    if #slots < 2 then
        slots = {}
        local n = tonumber(SafeCall(_G.NumTaxiNodes)) or 0
        for i = 1, n do
            if SafeCall(_G.TaxiNodeGetType, i) == "CURRENT" then slots[1] = i break end
        end
        slots[#slots + 1] = slot
    end
    if #slots < 2 then return nil end

    local route = { nodes = {} }
    for i, s in ipairs(slots) do
        local x, y = WorldPos(mapID, s)
        route.nodes[i] = {
            id   = ids[s],
            name = SafeCall(_G.TaxiNodeName, s) or "?",
            x    = x,
            y    = y,
        }
    end
    return route
end

-- ============================================================================
-- FONTS
-- ============================================================================

local function SetFont(fs, size)
    local path, flags = F.GetFontPath(), F.GetFontFlags()
    if flags == "NONE" then flags = "" end
    if not fs:SetFont(path, size, flags) then
        fs:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size, flags)
    end
end

-- ============================================================================
-- BANNER
-- ============================================================================

local function ApplyBackdrop(frame)
    if not frame.SetBackdrop then return end
    if not F.Opt("flightBackground") then
        frame:SetBackdrop(nil)
        return
    end
    local TS = Y.ToastStyles
    local r, g, b = F.GetAccentColor()
    if TS and TS.ApplyFramedBackdrop then
        TS.ApplyFramedBackdrop(frame, r, g, b, TS.GetFramedBorder and TS.GetFramedBorder())
    else
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.75)
        frame:SetBackdropBorderColor(r, g, b, 0.7)
    end
end

local function ApplyAnchor(frame)
    local point, relPoint, x, y = F.GetPosition()
    point = point or F.DEFAULT_ANCHOR
    relPoint = relPoint or F.DEFAULT_ANCHOR
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, tonumber(x) or F.DEFAULT_X, tonumber(y) or F.DEFAULT_Y)
end

-- StartMoving re-anchors to TOPLEFT; store the top edge's centre instead.
local function SaveBannerPosition()
    if not banner then return end
    local left, right, top = banner:GetLeft(), banner:GetRight(), banner:GetTop()
    if not (left and right and top) then return end
    local scale = banner:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local cx = (left + right) / 2 * scale
    local ux = (UIParent:GetLeft() + UIParent:GetRight()) / 2
    local x = math.floor((cx - ux) / scale + 0.5)
    local y = math.floor((top * scale - UIParent:GetTop()) / scale + 0.5)
    F.SavePosition("TOP", "TOP", x, y)
end

local function BuildBanner()
    if banner then return banner end
    banner = CreateFrame("Frame", "HorizonSuiteFlightTracker", UIParent, "BackdropTemplate")
    banner:SetFrameStrata("MEDIUM")
    banner:SetClampedToScreen(true)
    banner:Hide()

    banner.accent = banner:CreateTexture(nil, "ARTWORK")
    banner.accent:SetHeight(2)
    banner.accent:SetPoint("TOPLEFT", banner, "TOPLEFT", 3, -3)
    banner.accent:SetPoint("TOPRIGHT", banner, "TOPRIGHT", -3, -3)
    banner.accent:SetColorTexture(1, 1, 1, 1)

    banner.flyingTo = banner:CreateFontString(nil, "OVERLAY")
    banner.flyingTo:SetJustifyH("CENTER")
    banner.flyingTo:SetTextColor(0.7, 0.7, 0.7, 1)

    banner.dest = banner:CreateFontString(nil, "OVERLAY")
    banner.dest:SetJustifyH("CENTER")
    banner.dest:SetTextColor(1, 1, 1, 1)
    banner.dest:SetWordWrap(false)

    banner.track = banner:CreateTexture(nil, "ARTWORK")
    banner.track:SetColorTexture(1, 1, 1, 0.15)
    banner.fill = banner:CreateTexture(nil, "ARTWORK", nil, 1)
    banner.fill:SetColorTexture(1, 1, 1, 1)

    banner.dots = {}
    banner.startDot = banner:CreateTexture(nil, "OVERLAY")
    banner.endDot = banner:CreateTexture(nil, "OVERLAY")
    for _, d in ipairs({ banner.startDot, banner.endDot }) do
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetSize(END_DOT_SIZE, END_DOT_SIZE)
    end

    banner.origin = banner:CreateFontString(nil, "OVERLAY")
    banner.origin:SetJustifyH("LEFT")
    banner.origin:SetTextColor(0.7, 0.7, 0.7, 1)
    banner.origin:SetWordWrap(false)

    banner.time = banner:CreateFontString(nil, "OVERLAY")
    banner.time:SetJustifyH("RIGHT")
    banner.time:SetTextColor(1, 1, 1, 1)

    return banner
end

local function GetDot(i)
    local d = banner.dots[i]
    if not d then
        d = banner:CreateTexture(nil, "OVERLAY")
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetSize(DOT_SIZE, DOT_SIZE)
        banner.dots[i] = d
    end
    return d
end

--- Lay the banner out for the current options and route. Text is filled in
--- by UpdateBanner; this only sizes and places.
local function LayoutBanner()
    if not banner or not active then return end
    local width = F.GetWidth()
    local inner = width - PAD * 2
    local small, destSize, timeSize = F.GetFontSize(), F.GetDestinationSize(), F.GetTimeSize()
    local r, g, b = F.GetAccentColor()

    banner:SetScale(F.GetScale())
    banner:SetAlpha(F.GetOpacity())
    banner:SetWidth(width)
    ApplyBackdrop(banner)
    banner.accent:SetShown(F.Opt("flightAccentBar"))
    banner.accent:SetVertexColor(r, g, b, 1)

    SetFont(banner.flyingTo, small)
    SetFont(banner.dest, destSize)
    SetFont(banner.origin, small)
    SetFont(banner.time, timeSize)
    banner.dest:SetWidth(inner)

    local y = -PAD
    local showFlyingTo = F.Opt("flightShowFlyingTo")
    banner.flyingTo:SetShown(showFlyingTo)
    if showFlyingTo then
        banner.flyingTo:ClearAllPoints()
        banner.flyingTo:SetPoint("TOP", banner, "TOP", 0, y)
        y = y - small - LINE_GAP
    end

    banner.dest:ClearAllPoints()
    banner.dest:SetPoint("TOP", banner, "TOP", 0, y)
    y = y - destSize - LINE_GAP - 4

    local showRoute = F.Opt("flightShowRoute")
    local showStops = showRoute and F.Opt("flightShowStops")
    for _, t in ipairs({ banner.track, banner.fill, banner.startDot, banner.endDot }) do
        t:SetShown(showRoute)
    end
    local stops = active.est.stops or {}
    for i, d in ipairs(banner.dots) do d:SetShown(showStops and i <= #stops) end
    if showRoute then
        local barY = y - math.floor(END_DOT_SIZE / 2)
        local barLeft, barWidth = PAD + END_DOT_SIZE / 2, inner - END_DOT_SIZE
        banner.barLeft, banner.barWidth, banner.barY = barLeft, barWidth, barY
        banner.track:ClearAllPoints()
        banner.track:SetPoint("LEFT", banner, "TOPLEFT", barLeft, barY)
        banner.track:SetSize(barWidth, BAR_HEIGHT)
        banner.fill:ClearAllPoints()
        banner.fill:SetPoint("LEFT", banner, "TOPLEFT", barLeft, barY)
        banner.fill:SetHeight(BAR_HEIGHT)
        banner.fill:SetVertexColor(r, g, b, 1)
        banner.startDot:ClearAllPoints()
        banner.startDot:SetPoint("CENTER", banner, "TOPLEFT", barLeft, barY)
        banner.startDot:SetVertexColor(r, g, b, 1)
        banner.endDot:ClearAllPoints()
        banner.endDot:SetPoint("CENTER", banner, "TOPLEFT", barLeft + barWidth, barY)
        if showStops then
            for i, frac in ipairs(stops) do
                local d = GetDot(i)
                d:ClearAllPoints()
                d:SetPoint("CENTER", banner, "TOPLEFT", barLeft + barWidth * frac, barY)
                d:Show()
            end
        end
        y = y - END_DOT_SIZE - LINE_GAP - 2
    end

    local showOrigin, showTime = F.Opt("flightShowOrigin"), F.Opt("flightShowTimeLeft")
    banner.origin:SetShown(showOrigin)
    banner.time:SetShown(showTime)
    if showOrigin or showTime then
        local rowH = math.max(showOrigin and small or 0, showTime and timeSize or 0)
        banner.origin:ClearAllPoints()
        banner.origin:SetPoint("BOTTOMLEFT", banner, "TOPLEFT", PAD, y - rowH)
        banner.origin:SetWidth(showTime and inner * 0.62 or inner)
        banner.time:ClearAllPoints()
        if showOrigin then
            banner.time:SetPoint("BOTTOMRIGHT", banner, "TOPRIGHT", -PAD, y - rowH)
        else
            banner.time:SetPoint("TOP", banner, "TOP", 0, y)
        end
        y = y - rowH
    end

    banner:SetHeight(-y + PAD)
end

--- Refresh the text and progress. Cheap; runs on every tick while flying.
local function UpdateBanner()
    if not banner or not active then return end
    local nodes = active.route.nodes
    local dest = nodes[#nodes]
    local elapsed = GetTime() - active.startedAt
    if active.placeholder then elapsed = active.est.total * 0.6 end

    banner.flyingTo:SetText(L["FLIGHT_FLYING_TO"])
    banner.dest:SetText(F.ShortName(dest.name))
    banner.origin:SetText(L["FLIGHT_FROM"]:format(F.ShortName(nodes[1].name)))

    local progress, kind, seconds = F.Progress(active.est, elapsed)
    if kind == "left" then
        banner.time:SetText((active.est.exact and "" or "~") .. F.FormatTime(seconds))
    elseif kind == "due" then
        banner.time:SetText(L["FLIGHT_ARRIVING"])
    else
        banner.time:SetText(L["FLIGHT_FLOWN"]:format(F.FormatTime(seconds)))
    end

    if banner.barWidth then
        local frac = progress or 0
        banner.fill:SetShown(frac > 0 and F.Opt("flightShowRoute"))
        banner.fill:SetWidth(math.max(1, banner.barWidth * frac))
        local r, g, b = F.GetAccentColor()
        local done = frac >= 1
        banner.endDot:SetVertexColor(done and r or 0.45, done and g or 0.45, done and b or 0.45, 1)
        for i, stopFrac in ipairs(active.est.stops or {}) do
            local d = banner.dots[i]
            if d then
                if frac >= stopFrac then
                    d:SetVertexColor(r, g, b, 1)
                else
                    d:SetVertexColor(0.45, 0.45, 0.45, 1)
                end
            end
        end
    end
end

-- ============================================================================
-- ARRIVAL NOTICE
-- ============================================================================

local function BuildArrival()
    if arrival then return arrival end
    arrival = CreateFrame("Frame", nil, UIParent)
    arrival:SetSize(10, 10)
    arrival:SetFrameStrata("MEDIUM")
    arrival:Hide()
    arrival.label = arrival:CreateFontString(nil, "OVERLAY")
    arrival.label:SetPoint("TOP", arrival, "TOP", 0, 0)
    arrival.label:SetTextColor(0.75, 0.75, 0.75, 1)
    arrival.name = arrival:CreateFontString(nil, "OVERLAY")
    arrival.name:SetTextColor(1, 1, 1, 1)
    arrival:SetScript("OnUpdate", function(self)
        local t = GetTime() - (self.shownAt or 0)
        if t < F.ARRIVAL_HOLD then
            self:SetAlpha(1)
        elseif t < F.ARRIVAL_HOLD + F.ARRIVAL_FADE then
            self:SetAlpha(1 - (t - F.ARRIVAL_HOLD) / F.ARRIVAL_FADE)
        else
            self:Hide()
        end
    end)
    return arrival
end

local function ShowArrival(name)
    if not F.Opt("flightArrivalNotice") then return end
    BuildArrival()
    arrival:SetScale(F.GetScale())
    ApplyAnchor(arrival)
    SetFont(arrival.label, F.GetFontSize() + 1)
    SetFont(arrival.name, F.GetArrivalSize())
    local r, g, b = F.GetAccentColor()
    arrival.label:SetTextColor(r, g, b, 1)
    arrival.label:SetText(L["FLIGHT_ARRIVED_AT"])
    arrival.name:ClearAllPoints()
    arrival.name:SetPoint("TOP", arrival.label, "BOTTOM", 0, -LINE_GAP)
    arrival.name:SetText(F.ShortName(name))
    arrival.shownAt = GetTime()
    arrival:SetAlpha(1)
    arrival:Show()
end

-- ============================================================================
-- FLIGHT STATE
-- ============================================================================

local function PersistActive()
    local s = F.Store()
    if not s then return end
    if active and not active.demo then
        s.active = { route = active.route, epoch = active.epoch, guid = UnitGUID and UnitGUID("player") }
    else
        s.active = nil
    end
end

local function StartFlight(route, startedAt, epoch, learn)
    if arrival then arrival:Hide() end
    active = {
        route = route,
        est = F.Estimate(route),
        startedAt = startedAt or GetTime(),
        epoch = epoch or time(),
        learn = learn ~= false,
    }
    PersistActive()
    BuildBanner()
    ApplyAnchor(banner)
    LayoutBanner()
    UpdateBanner()
    banner:Show()
end

--- The still banner shown while positioning, when nothing is flying.
local Placeholder

local function EndFlight(landed)
    local done = active
    active = nil
    if done and not done.demo then PersistActive() end
    if editMode then
        active = Placeholder()
        LayoutBanner()
        UpdateBanner()
    elseif banner then
        banner:Hide()
    end
    if not done then return end
    if landed and done.learn and not done.demo then
        F.Learn(done.route, GetTime() - done.startedAt)
    end
    if landed then
        local nodes = done.route.nodes
        ShowArrival(nodes[#nodes].name)
    end
end

local function OnTick()
    local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
    if active and active.placeholder then
        -- Positioning only; a real take-off replaces it below.
        if pending and onTaxi then
            local route = pending.route
            pending = nil
            StartFlight(route)
        end
    elseif active and active.demo then
        if GetTime() - active.startedAt >= active.demoLength then EndFlight(true) end
    elseif active then
        if not onTaxi then EndFlight(true) end
    elseif pending then
        if onTaxi then
            local route = pending.route
            pending = nil
            StartFlight(route)
        elseif GetTime() - pending.at > PENDING_TTL then
            pending = nil
        end
    end
    if active then UpdateBanner() end
    if not active and not pending and ticker and not editMode then ticker:Hide() end
end

local function EnsureTicker()
    if not ticker then
        ticker = CreateFrame("Frame")
        local acc = 0
        ticker:SetScript("OnUpdate", function(_, dt)
            acc = acc + dt
            if acc < TICK then return end
            acc = 0
            OnTick()
        end)
    end
    ticker:Show()
end

--- On login or reload while already in the air, resume the saved flight.
local function TryResume(isReload)
    if active or not (UnitOnTaxi and UnitOnTaxi("player")) then return end
    local s = F.Store()
    local saved = s and s.active
    if type(saved) ~= "table" or type(saved.route) ~= "table" then return end
    if saved.guid and UnitGUID and saved.guid ~= UnitGUID("player") then return end
    local age = time() - (tonumber(saved.epoch) or 0)
    if age < 0 or age > RESUME_MAX_AGE then return end
    -- A login's clock includes time spent logged out; only a reload's is exact.
    StartFlight(saved.route, GetTime() - age, saved.epoch, isReload and true or false)
    EnsureTicker()
end

-- ============================================================================
-- HOOKS AND EVENTS
-- ============================================================================

local function InstallHooks()
    if hooksInstalled then return end
    hooksInstalled = true
    if type(_G.TakeTaxiNode) == "function" then
        hooksecurefunc("TakeTaxiNode", function(slot)
            if not enabled then return end
            local route = ReadRoute(slot)
            if not route then return end
            pending = { route = route, at = GetTime() }
            EnsureTicker()
        end)
    end
    if type(_G.TaxiRequestEarlyLanding) == "function" then
        hooksecurefunc("TaxiRequestEarlyLanding", function()
            if active then active.learn = false end
        end)
    end
end

local function OnEvent(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, isReload = ...
        TryResume(isReload)
    end
end

-- ============================================================================
-- EDIT MODE
-- ============================================================================

local function DemoRoute()
    return { nodes = {
        { name = L["FLIGHT_DEMO_ORIGIN"] },
        { name = L["FLIGHT_DEMO_STOP"] },
        { name = L["FLIGHT_DEMO_DESTINATION"] },
    } }
end

Placeholder = function()
    return {
        route = DemoRoute(), startedAt = GetTime(), learn = false, placeholder = true,
        est = { total = 90, exact = true, stops = { 0.45 } },
    }
end

local function BuildEditOverlay()
    if editOverlay then return end
    BuildBanner()
    editOverlay = CreateFrame("Frame", nil, banner, "BackdropTemplate")
    editOverlay:SetAllPoints(banner)
    editOverlay:SetFrameLevel(banner:GetFrameLevel() + 10)
    editOverlay:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editOverlay:SetBackdropColor(0, 0, 0, 0.35)
    editOverlay:SetBackdropBorderColor(0.4, 0.8, 1.0, 0.9)
    editOverlay:EnableMouse(true)
    editOverlay:RegisterForDrag("LeftButton")
    editOverlay:SetScript("OnDragStart", function()
        banner:SetMovable(true)
        banner:StartMoving()
    end)
    editOverlay:SetScript("OnDragStop", function()
        banner:StopMovingOrSizing()
        banner:SetMovable(false)
        SaveBannerPosition()
        ApplyAnchor(banner)
    end)
    local hint = editOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("BOTTOM", editOverlay, "TOP", 0, 4)
    hint:SetText(L["FLIGHT_EDIT_HINT"])
    editOverlay:Hide()
end

local function SetEditMode(on)
    if on == editMode then return end
    editMode = on
    BuildEditOverlay()
    if on then
        if not active then active = Placeholder() end
        ApplyAnchor(banner)
        LayoutBanner()
        UpdateBanner()
        banner:Show()
        editOverlay:Show()
        EnsureTicker()
    else
        editOverlay:Hide()
        SaveBannerPosition()
        if active and active.placeholder then active = nil end
        if not active and banner then banner:Hide() end
    end
end

function F.ToggleEditMode()
    if not enabled then return end
    SetEditMode(not editMode)
end

local function HookNativeEditMode()
    if F._editHooked or not EventRegistry then return end
    F._editHooked = true
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        if enabled then SetEditMode(true) end
    end, "HorizonSuiteAugmentFlight")
    EventRegistry:RegisterCallback("EditMode.Exit", function()
        C_Timer.After(0, function() SetEditMode(false) end)
    end, "HorizonSuiteAugmentFlight")
end

-- ============================================================================
-- PUBLIC
-- ============================================================================

--- @return boolean
function F.IsEnabled()
    if not addon.IsModuleEnabled or not addon:IsModuleEnabled("augment") then return false end
    return F.GetDB("augmentFlightTrackerEnabled", addon.AUGMENT_DEFAULTS.augmentFlightTrackerEnabled) ~= false
end

function F.Enable()
    if enabled then return end
    enabled = true
    F.Store()
    InstallHooks()
    HookNativeEditMode()
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnEvent)
    end
    -- Resuming waits for PLAYER_ENTERING_WORLD, which says whether this is a
    -- reload (clock exact, keep learning) or a login (clock includes time away).
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function F.Disable()
    if not enabled then return end
    if editMode then SetEditMode(false) end
    enabled = false
    pending = nil
    if active then
        active = nil
        if banner then banner:Hide() end
    end
    if arrival then arrival:Hide() end
    if eventFrame then eventFrame:UnregisterAllEvents() end
    if ticker then ticker:Hide() end
end

--- Run a short fabricated flight with the current settings.
function F.Preview()
    if not enabled then return end
    if active and not active.demo and not active.placeholder then return end
    pending = nil
    active = {
        route = DemoRoute(), startedAt = GetTime(), learn = false, demo = true, demoLength = 12,
        est = { total = 12, exact = true, stops = { 0.45 } },
    }
    if arrival then arrival:Hide() end
    BuildBanner()
    ApplyAnchor(banner)
    LayoutBanner()
    UpdateBanner()
    banner:Show()
    EnsureTicker()
end

--- Re-apply after any option change.
function F.ApplyOptions()
    if banner and active then
        ApplyAnchor(banner)
        LayoutBanner()
        UpdateBanner()
    end
end

function F.ResetPosition()
    F.ClearPosition()
    if banner then ApplyAnchor(banner) end
end

--- @return table|nil active flight (read-only)
function F.GetActive() return active end
