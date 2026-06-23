--[[
    Horizon Suite - Augment / FlightTimer - Events
    Source-node caching, taxi-button/flight-map-pin tooltip hook install
    (actual tooltip text lives in AugmentFlightTimerTooltip.lua), the
    TakeTaxiNode override that starts a flight's timer, and the
    gossip/Immersion/port/summon/LFG detection that stops bad data being
    recorded for non-taxi "flights". Mirrors AugmentSkyridingEvents.lua's
    EnableEvents/DisableEvents lifecycle shape.

    Session state (current source/destination node, computed end time, the
    "did the player actually fly the whole route" flag) lives as named fields
    on F itself rather than file-local closures, since it's read and written
    from this file, AugmentFlightTimerTooltip.lua, and AugmentFlightTimerBar.lua.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local F = Y and Y.FlightTimer
if not F then return end

local L = addon.L

local frame = CreateFrame("Frame")
F.eventFrame = frame

local oldTakeTaxiNode

-- GetTaxiMapID() doesn't account for the map having changed underneath the
-- player (Dragon Isles <-> Zaralek Cavern, etc).
function F.GetViewedTaxiMapID()
    if FlightMapFrame and FlightMapFrame.GetMapID then
        return FlightMapFrame:GetMapID()
    end
    return GetTaxiMapID()
end

-- ============================================================================
-- SOURCE CACHING
-- ============================================================================

local function CacheSourceFromTaxiButtons()
    for i = 1, NumTaxiNodes() do
        if F.Tooltip and F.Tooltip.HookTaxiButton then F.Tooltip.HookTaxiButton(i) end
        if TaxiNodeGetType(i) == "CURRENT" then
            F.taxiSrcName = F.ShortenName(TaxiNodeName(i))
            F.taxiSrc = F.GetNodeIDForSlot and F.GetNodeIDForSlot(i) or nil
        end
    end
end

local function CacheSourceFromFlightMapPins()
    local pool = FlightMapFrame and FlightMapFrame.pinPools
        and FlightMapFrame.pinPools.FlightMap_FlightPointPinTemplate
    if not pool then return end

    for pin in pool:EnumerateActive() do
        if F.Tooltip and F.Tooltip.HookFlightMapPin then F.Tooltip.HookFlightMapPin(pin) end
        if pin.taxiNodeData.state == Enum.FlightPathState.Current then
            F.taxiSrcName = F.ShortenName(pin.taxiNodeData.name)
            F.taxiSrc = pin.taxiNodeData.nodeID
        end
    end
end

-- Resolves a taxi button's slot index to its node ID via the currently
-- viewed taxi map's node list.
function F.GetNodeIDForSlot(slot)
    local taximapNodes = C_TaxiMap.GetAllTaxiNodes(F.GetViewedTaxiMapID())
    for _, taxiNodeData in ipairs(taximapNodes) do
        if slot == taxiNodeData.slotIndex then return taxiNodeData.nodeID end
    end
end

-- @param isTaxiMap boolean  true when the taxi map (not the world map's
--   flight tab) is open - the two use different button/pin frames.
function F.InitSource(isTaxiMap)
    -- Remember the last source, for flights spanning several maps
    -- (Dragon Isles <-> Zaralek Cavern).
    local lastSrcName, lastSrc = F.taxiSrcName, F.taxiSrc
    F.taxiSrcName, F.taxiSrc = nil, nil

    if isTaxiMap then
        CacheSourceFromTaxiButtons()
    else
        CacheSourceFromFlightMapPins()
    end

    if F.taxiSrc then return end

    local taxiMapID = F.GetViewedTaxiMapID()
    if taxiMapID == 1467 and GetMinimapZoneText() == L["FLIGHT_TIMER_SHATTER_POINT"] then
        -- Workaround for a long-standing Blizzard bug on the Outland flight map.
        F.taxiSrcName = L["FLIGHT_TIMER_SHATTER_POINT"]
        F.taxiSrc = "Shatter Point"
    elseif taxiMapID == 2057 or taxiMapID == 2175 then
        -- Dragon Isles <-> Zaralek Cavern.
        F.taxiSrcName, F.taxiSrc = lastSrcName, lastSrc
    end
end

-- ============================================================================
-- GOSSIP / IMMERSION SCENIC FLIGHTS
-- Some flight points are started from an NPC's gossip dialogue rather than
-- the taxi map (e.g. the Amber Ledge scenic route). Ported lookup table from
-- InFlight.lua, keyed by the localized gossip button text so the right
-- source/destination pair gets passed to StartMiscFlight.
-- ============================================================================

local gossipFlights = {
    [L["FLIGHT_TIMER_AMBER_LEDGE"]]               = {{ find = L["FLIGHT_TIMER_GOSSIP_AMBER_LEDGE"],          s = "Amber Ledge",                d = "Transitus Shield (Scenic Route)" }},
    [L["FLIGHT_TIMER_ARGENT_TOURNAMENT_GROUNDS"]] = {{ find = L["FLIGHT_TIMER_GOSSIP_ARGENT_TOURNAMENT"],     s = "Argent Tournament Grounds",  d = "Return" }},
    [L["FLIGHT_TIMER_BLACKWIND_LANDING"]]         = {{ find = L["FLIGHT_TIMER_GOSSIP_BLACKWIND_LANDING"],     s = "Blackwind Landing",          d = "Skyguard Outpost" }},
    [L["FLIGHT_TIMER_CAVERNS_OF_TIME"]]           = {{ find = L["FLIGHT_TIMER_GOSSIP_CAVERNS_OF_TIME"],       s = "Caverns of Time",            d = "Nozdormu's Lair" }},
    [L["FLIGHT_TIMER_EXPEDITION_POINT"]]          = {{ find = L["FLIGHT_TIMER_GOSSIP_EXPEDITION_POINT"],      s = "Expedition Point",           d = "Shatter Point" }},
    [L["FLIGHT_TIMER_HELLFIRE_PENINSULA"]]        = {{ find = L["FLIGHT_TIMER_GOSSIP_HELLFIRE_PENINSULA"],    s = "Honor Point",                d = "Shatter Point" }},
    [L["FLIGHT_TIMER_NIGHTHAVEN"]]                = {{ find = L["FLIGHT_TIMER_GOSSIP_NIGHTHAVEN_A"],          s = "Nighthaven",                 d = "Rut'theran Village" },
                                                       { find = L["FLIGHT_TIMER_GOSSIP_NIGHTHAVEN_H"],          s = "Nighthaven",                 d = "Thunder Bluff" }},
    [L["FLIGHT_TIMER_OLD_HILLSBRAD"]]             = {{ find = L["FLIGHT_TIMER_GOSSIP_OLD_HILLSBRAD"],         s = "Old Hillsbrad Foothills",    d = "Durnholde Keep" }},
    [L["FLIGHT_TIMER_REAVERS_FALL"]]              = {{ find = L["FLIGHT_TIMER_GOSSIP_REAVERS_FALL"],          s = "Reaver's Fall",              d = "Spinebreaker Post" }},
    [L["FLIGHT_TIMER_RING_OF_TRANSFERENCE"]]      = {{ find = L["FLIGHT_TIMER_GOSSIP_BASTION_1"],             s = "Oribos",                     d = "Bastion" },
                                                       { find = L["FLIGHT_TIMER_GOSSIP_BASTION_2"],             s = "Oribos",                     d = "Bastion" }},
    [L["FLIGHT_TIMER_SHATTER_POINT"]]             = {{ find = L["FLIGHT_TIMER_GOSSIP_SHATTER_POINT"],         s = "Shatter Point",              d = "Honor Point" }},
    [L["FLIGHT_TIMER_SKYGUARD_OUTPOST"]]          = {{ find = L["FLIGHT_TIMER_GOSSIP_SKYGUARD_OUTPOST"],      s = "Skyguard Outpost",           d = "Blackwind Landing" }},
    [L["FLIGHT_TIMER_STORMWIND_CITY"]]            = {{ find = L["FLIGHT_TIMER_GOSSIP_STORMWIND_CITY"],        s = "Stormwind City",             d = "Return" }},
    [L["FLIGHT_TIMER_SUNS_REACH_HARBOR"]]         = {{ find = L["FLIGHT_TIMER_GOSSIP_SSSA_1"],                 s = "Shattered Sun Staging Area", d = "Return" },
                                                       { find = L["FLIGHT_TIMER_GOSSIP_SSSA_2"],                 s = "Shattered Sun Staging Area", d = "The Sin'loren" }},
    [L["FLIGHT_TIMER_SIN_LOREN"]]                 = {{ find = L["FLIGHT_TIMER_GOSSIP_SIN_LOREN"],             s = "The Sin'loren",              d = "Shattered Sun Staging Area" }},
    [L["FLIGHT_TIMER_VALGARDE"]]                  = {{ find = L["FLIGHT_TIMER_GOSSIP_VALGARDE"],              s = "Valgarde",                   d = "Explorers' League Outpost" }},
}

local function PrepareMiscFlight(buttonText)
    if not F.enabled then return end
    if not buttonText or buttonText == "" then return end

    local subzone = GetMinimapZoneText()
    local candidates = gossipFlights[subzone]
    if not candidates then return end

    for _, c in ipairs(candidates) do
        if c.find and buttonText:find(c.find, 1, true) then
            F.StartMiscFlight(c.s, c.d)
            return
        end
    end
end

local immersionHookFrame
local gossipHooked = false

local function HookImmersion()
    if immersionHookFrame then return end
    immersionHookFrame = CreateFrame("Frame")
    immersionHookFrame:SetScript("OnEvent", function()
        if not (ImmersionFrame and ImmersionFrame.TitleButtons) then return end
        for _, child in ipairs({ ImmersionFrame.TitleButtons:GetChildren() }) do
            if not child.flightTimerHooked then
                child:HookScript("OnClick", function(this) PrepareMiscFlight(this:GetText()) end)
                child.flightTimerHooked = true
            end
        end
    end)
    immersionHookFrame:RegisterEvent("GOSSIP_SHOW")
    immersionHookFrame:RegisterEvent("QUEST_GREETING")
    immersionHookFrame:RegisterEvent("QUEST_PROGRESS")
end

local function HookGossip()
    if gossipHooked then return end
    gossipHooked = true
    if C_AddOns.IsAddOnLoaded("Immersion") then
        HookImmersion()
    else
        hooksecurefunc(GossipOptionButtonMixin, "OnClick", function(this)
            local elementData = this:GetElementData()
            if elementData.buttonType ~= GOSSIP_BUTTON_TYPE_OPTION then return end
            PrepareMiscFlight(this:GetText())
        end)
    end
end

-- @param src string  bundled-data source key (a node ID or a special string
--   key like "Shatter Point" for the few zones with no proper nodeID)
function F.StartMiscFlight(src, dst)
    F.taxiSrcName, F.taxiSrc = src, src
    F.taxiDstName, F.taxiDst = dst, dst

    local dstNodes = F.GetDstNodes(src)
    local endTime = dstNodes and dstNodes[dst]
    if endTime then
        endTime = endTime * F.KhazAlgarFlightMasterFactor(src)
    end

    if F.Bar then F.Bar.Start(endTime) end
end

-- ============================================================================
-- TAKETAXINODE OVERRIDE
-- There's no secure hook point for TakeTaxiNode, so - like InFlight - we
-- replace the global function while enabled and restore the original on
-- disable.
-- ============================================================================

local function ConfirmAndStart(slot, endTime, endText)
    local D = addon.AUGMENT_DEFAULTS
    if F.GetDB("flightTimerConfirmFlight", D.flightTimerConfirmFlight) then
        StaticPopupDialogs.HORIZONFLIGHTTIMERCONFIRM = StaticPopupDialogs.HORIZONFLIGHTTIMERCONFIRM or {
            button1 = OKAY, button2 = CANCEL,
            OnAccept = function(_, data) F.Bar.Start(data.endTime); oldTakeTaxiNode(data.slot) end,
            timeout = 0, exclusive = 1, hideOnEscape = 1,
        }
        StaticPopupDialogs.HORIZONFLIGHTTIMERCONFIRM.text =
            format(L["FLIGHT_TIMER_CONFIRM_POPUP"], "|cffffff00" .. F.taxiDstName .. (endTime and (" (" .. endText .. ")") or "") .. "|r")

        local dialog = StaticPopup_Show("HORIZONFLIGHTTIMERCONFIRM")
        if dialog then dialog.data = { slot = slot, endTime = endTime } end
    else
        F.Bar.Start(endTime)
        oldTakeTaxiNode(slot)
    end
end

local function InstallTakeTaxiNodeOverride()
    if oldTakeTaxiNode then return end
    oldTakeTaxiNode = TakeTaxiNode
    F.oldTakeTaxiNode = oldTakeTaxiNode

    TakeTaxiNode = function(slot)
        if TaxiNodeGetType(slot) ~= "REACHABLE" then return end

        -- Argus has no flight-time data and its taxi behaves oddly; don't time it.
        if GetTaxiMapID() == 994 then return oldTakeTaxiNode(slot) end

        if not F.taxiSrc then
            -- Another addon may have auto-taken the taxi before InitSource ran.
            for i = 1, NumTaxiNodes() do
                if TaxiNodeGetType(i) == "CURRENT" then
                    F.taxiSrcName = F.ShortenName(TaxiNodeName(i))
                    F.taxiSrc = F.GetNodeIDForSlot(i)
                    break
                end
            end
            if not F.taxiSrc then return oldTakeTaxiNode(slot) end
        end

        F.taxiDstName = F.ShortenName(TaxiNodeName(slot))
        F.taxiDst = F.GetNodeIDForSlot(slot)
        if not F.taxiDst then return oldTakeTaxiNode(slot) end

        local dstNodes = F.GetDstNodes(F.taxiSrc)
        local endTime, endText
        if dstNodes and dstNodes[F.taxiDst] and dstNodes[F.taxiDst] > 0 then
            endTime = dstNodes[F.taxiDst] * F.KhazAlgarFlightMasterFactor(F.taxiDst)
            endText = F.Bar.FormatTime(endTime)
        else
            endTime = F.GetEstimatedTime(F.taxiSrc, slot, F.GetViewedTaxiMapID())
            endText = (endTime and "~" or "") .. F.Bar.FormatTime(endTime)
        end

        ConfirmAndStart(slot, endTime, endText)
    end
end

local function RestoreTakeTaxiNodeOverride()
    if not oldTakeTaxiNode then return end
    TakeTaxiNode = oldTakeTaxiNode
    oldTakeTaxiNode = nil
    F.oldTakeTaxiNode = nil
end

-- ============================================================================
-- PORT / SUMMON / LFG SUPPRESSION
-- These all complete a "flight" without actually flying the route, so the
-- timer must not record whatever elapsed time happened to pass as a learned
-- duration. F.porttaken is read by AugmentFlightTimerBar.lua's ticker.
-- ============================================================================

local suppressionHooked = false

local function HookSuppression()
    if suppressionHooked then return end
    suppressionHooked = true

    hooksecurefunc("TaxiRequestEarlyLanding", function() if F.enabled then F.porttaken = true end end)
    hooksecurefunc("AcceptBattlefieldPort", function(_, accept) if F.enabled then F.porttaken = accept and true or F.porttaken end end)
    hooksecurefunc(C_SummonInfo, "ConfirmSummon", function() if F.enabled then F.porttaken = true end end)
    hooksecurefunc("CompleteLFGRoleCheck", function(bool) if F.enabled then F.porttaken = bool end end)
    hooksecurefunc("CompleteLFGReadyCheck", function(bool) if F.enabled then F.porttaken = bool end end)
end

-- ============================================================================
-- LIFECYCLE
-- ============================================================================

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "TAXIMAP_OPENED" then
        if FlightMapFrame and not FlightMapFrame.flightTimerHooked then
            hooksecurefunc(FlightMapFrame, "SetMapID", function() if F.enabled then F.InitSource(false) end end)
            FlightMapFrame.flightTimerHooked = true
        end
        local uiMapSystem = ...
        F.InitSource(uiMapSystem == Enum.UIMapSystem.Taxi)
    elseif event == "PLAYER_ENTERING_WORLD" then
        F.RefreshFactionlessZoneNodes()
    end
end)

function F.EnableEvents()
    InstallTakeTaxiNodeOverride()
    HookGossip()
    HookSuppression()
    frame:RegisterEvent("TAXIMAP_OPENED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    F.RefreshFactionlessZoneNodes()
end

function F.DisableEvents()
    RestoreTakeTaxiNodeOverride()
    frame:UnregisterEvent("TAXIMAP_OPENED")
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if F.Bar and F.Bar.Stop then F.Bar.Stop() end
end
