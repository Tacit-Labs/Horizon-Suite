--[[
    Horizon Suite - Presence - Zone
    Zone and subzone change notifications. ZONE_CHANGE, SUBZONE_CHANGE.
    APIs: GetZoneText, GetSubZoneText, addon.IsDelveActive, addon.IsInPartyDungeon.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local ZONE_DEBOUNCE = 0.25
local SUBZONE_DEDUP_TIME = 2.0
local DELVE_TIER_WAIT_INTERVAL = 0.15
local DELVE_TIER_WAIT_MAX = 2.0

-- ============================================================================
-- State
-- ============================================================================

local lastKnownZone = nil
local lastSubzoneTitleShown = nil
local lastSubzoneTitleTime = 0
local pendingDelveZoneTimer = nil
local pendingDelveZoneRetryCount = 0

-- ============================================================================
-- Helpers
-- ============================================================================

local function Strip(s)
    return addon.Presence.StripMarkup and addon.Presence.StripMarkup(s) or (s or "")
end

local function ShouldSuppress()
    return addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType()
end

local function IsTypeEnabled(key, fallbackKey, fallbackDefault)
    return addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled(key, fallbackKey, fallbackDefault) or fallbackDefault
end

local function CancelPendingDelveZone()
    if pendingDelveZoneTimer then
        pendingDelveZoneTimer:Cancel()
        pendingDelveZoneTimer = nil
    end
    pendingDelveZoneRetryCount = 0
end

local function tryFireDelveZoneNotification()
    if not addon:IsModuleEnabled("presence") then
        CancelPendingDelveZone()
        return
    end
    if ShouldSuppress() then
        CancelPendingDelveZone()
        return
    end
    if not addon.IsDelveActive or not addon.IsDelveActive() then
        CancelPendingDelveZone()
        return
    end

    local zoneText = GetZoneText() or "Unknown Zone"
    local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()

    if tier then
        CancelPendingDelveZone()
        if addon.Presence.CancelZoneAnim then addon.Presence.CancelZoneAnim() end
        lastKnownZone = zoneText
        lastSubzoneTitleShown = nil
        lastSubzoneTitleTime = 0
        local opts = { category = "DELVES", source = "ZONE_CHANGED_NEW_AREA" }
        addon.Presence.QueueOrPlay("ZONE_CHANGE", Strip(zoneText), "Tier " .. tier, opts)
        if addon.Presence.pendingDiscovery then
            addon.Presence.ShowDiscoveryLine()
            addon.Presence.pendingDiscovery = nil
        end
    else
        pendingDelveZoneRetryCount = pendingDelveZoneRetryCount + 1
        if pendingDelveZoneRetryCount * DELVE_TIER_WAIT_INTERVAL >= DELVE_TIER_WAIT_MAX then
            CancelPendingDelveZone()
            if addon.Presence.CancelZoneAnim then addon.Presence.CancelZoneAnim() end
            lastKnownZone = zoneText
            lastSubzoneTitleShown = nil
            lastSubzoneTitleTime = 0
            local opts = { category = "DELVES", source = "ZONE_CHANGED_NEW_AREA" }
            addon.Presence.QueueOrPlay("ZONE_CHANGE", Strip(zoneText), "Delve", opts)
            if addon.Presence.pendingDiscovery then
                addon.Presence.ShowDiscoveryLine()
                addon.Presence.pendingDiscovery = nil
            end
        else
            pendingDelveZoneTimer = C_Timer.After(DELVE_TIER_WAIT_INTERVAL, tryFireDelveZoneNotification)
        end
    end
end

-- ============================================================================
-- Zone notification
-- ============================================================================

local function ScheduleZoneNotification(isNewArea)
    local zone = GetZoneText() or "Unknown Zone"
    local sub = GetSubZoneText() or ""

    if not isNewArea and sub ~= "" and zone == sub then return end

    if isNewArea then
        lastKnownZone = zone
        CancelPendingDelveZone()
    end

    local function fireZoneNotification()
        if not addon:IsModuleEnabled("presence") then return end
        if ShouldSuppress() then return end

        zone = GetZoneText() or "Unknown Zone"
        sub = GetSubZoneText() or ""

        if addon.Presence.CancelZoneAnim then addon.Presence.CancelZoneAnim() end

        local opts = {}

        if isNewArea then
            lastKnownZone = zone
            if not IsTypeEnabled("presenceZoneChange", nil, true) then return end
            local displaySub = sub
            if addon.IsDelveActive and addon.IsDelveActive() then
                opts.category = "DELVES"
                local tier = addon.GetActiveDelveTier and addon.GetActiveDelveTier()
                if tier then
                    displaySub = "Tier " .. tier
                else
                    pendingDelveZoneRetryCount = 0
                    pendingDelveZoneTimer = C_Timer.After(DELVE_TIER_WAIT_INTERVAL, tryFireDelveZoneNotification)
                    return
                end
            elseif addon.IsInPartyDungeon and addon.IsInPartyDungeon() then
                opts.category = "DUNGEON"
            end
            opts.source = "ZONE_CHANGED_NEW_AREA"
            lastSubzoneTitleShown = nil
            lastSubzoneTitleTime = 0
            addon.Presence.QueueOrPlay("ZONE_CHANGE", Strip(zone), Strip(displaySub), opts)
        else
            if not IsTypeEnabled("presenceSubzoneChange", "presenceZoneChange", true) then return end
            if sub == "" then return end
            if addon.IsDelveActive and addon.IsDelveActive() then return end
            if addon.IsInPartyDungeon and addon.IsInPartyDungeon() then
                opts.category = "DUNGEON"
            end
            opts.source = "ZONE_CHANGED"

            local isInterior = lastKnownZone and sub ~= "" and sub == lastKnownZone
            local displayTitle = isInterior and zone or sub
            local displayParent = isInterior and sub or zone

            local hideZoneForSubzone = addon.GetDB and addon.GetDB("presenceHideZoneForSubzone", false)
            local sameZone = lastKnownZone and (
                (not isInterior and zone ~= "" and zone == lastKnownZone) or
                (isInterior and sub ~= "" and sub == lastKnownZone)
            )

            local notifTitle = Strip(displayTitle)
            local notifSub = hideZoneForSubzone and sameZone and "" or Strip(displayParent)

            local now = GetTime()
            if notifTitle == lastSubzoneTitleShown and (now - lastSubzoneTitleTime) < SUBZONE_DEDUP_TIME then
                return
            end
            lastSubzoneTitleShown = notifTitle
            lastSubzoneTitleTime = now
            addon.Presence.QueueOrPlay("SUBZONE_CHANGE", notifTitle, notifSub, opts)
        end

        if addon.Presence.pendingDiscovery then
            addon.Presence.ShowDiscoveryLine()
            addon.Presence.pendingDiscovery = nil
        end
    end
    if addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("zone", ZONE_DEBOUNCE, fireZoneNotification)
    end
end

-- ============================================================================
-- Event handlers
-- ============================================================================

function addon.Presence.Zone_OnZoneChangedNewArea()
    if addon.Presence.ReapplyZoneSuppression and C_Timer and C_Timer.After then
        C_Timer.After(0, addon.Presence.ReapplyZoneSuppression)
    end
    ScheduleZoneNotification(true)
end

function addon.Presence.Zone_OnZoneChanged()
    if addon.Presence.ReapplyZoneSuppression and C_Timer and C_Timer.After then
        C_Timer.After(0, addon.Presence.ReapplyZoneSuppression)
    end
    local zone = GetZoneText() or ""
    local sub = GetSubZoneText()
    if sub and sub ~= "" and sub ~= zone then
        ScheduleZoneNotification(false)
    end
end

function addon.Presence.Zone_OnDelveDataUpdate()
    if not pendingDelveZoneTimer then return end
    if not addon.IsDelveActive or not addon.IsDelveActive() then return end

    pendingDelveZoneTimer:Cancel()
    pendingDelveZoneTimer = nil
    tryFireDelveZoneNotification()
end

-- ============================================================================
-- Init (called from OnPlayerEnteringWorld)
-- ============================================================================

function addon.Presence.Zone_OnInit()
    lastKnownZone = GetZoneText() or nil
end
