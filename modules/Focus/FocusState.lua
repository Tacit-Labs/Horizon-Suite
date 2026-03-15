--[[
    Horizon Suite - Focus - State
    Namespaced runtime state for the Focus module. Loaded first so all other files can reference addon.focus.*
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- Merge into existing addon.focus if Core created layout early; otherwise create fresh.
local existing = addon.focus
addon.focus = {
    enabled         = false,
    collapsed       = false,
    refreshPending  = false,
    zoneJustChanged = false,
    lastPlayerMapID = nil,
    placeholderRefreshScheduled = false,
    layoutPendingAfterCombat     = false,
    pendingDimensionsAfterCombat  = false,
    pendingHideAfterCombat       = false,
    restoreTrackerPendingAfterCombat = false,
    pendingEntryHideAfterCombat   = nil,  -- { [entry] = true } entries cleared during combat
    mplusLayoutPendingAfterCombat = false,

    rares = {
        prevKeys     = {},
        trackingInit = false,
    },

    collapse = {
        animating = false,
        animStart = 0,
        groups    = {},  -- [groupKey] = startTime
        sectionHeadersFadingOut = false,
        sectionHeadersFadingOutKeys = nil,  -- when set, only fade these groupKeys (e.g. WQ toggle)
        sectionHeadersFadingIn  = false,
        sectionHeaderFadeTime   = 0,
        expandSlideDownStarts   = nil,  -- { [key] = startY } for expand slide-down
        expandSlideDownStartsSec = nil, -- { [groupKey] = startY }
        pendingWQCollapse      = false,
        pendingWQExpand        = false, -- when showWorldQuests is toggled on for slide-down animation
        optionCollapseKeys     = nil,   -- { [questID|entryKey] = true } when animating WQ toggle off
        panelCollapsedExpandedGroups = {},  -- session-only: { [groupKey]=true } for categories expanded while panel is collapsed
    },

    combat = {
        fadeState = nil,  -- "out" | "in" | nil
        fadeTime  = 0,
        faded     = false, -- true when combat visibility mode is "fade" and fade-out completed
        fadeFromAlpha = nil,
        fadeInFromAlpha = nil,
    },

    hoverFade = {
        mouseOver = false,
        fadeState = nil,  -- "in" | "out" | nil
        fadeTime  = 0,
    },

    layout = (existing and existing.layout) or {
        targetHeight  = addon.MIN_HEIGHT,
        currentHeight = addon.MIN_HEIGHT,
        sectionIdx    = 0,
        scrollOffset  = 0,
    },

    promotion = {
        prevWorld  = {},
        prevWeekly = {},
        prevDaily  = {},
        fadeOutCount = nil,
        onFadeOutComplete = nil,
    },

    categoryChange = {
        prevGroupKey = {},  -- [key] = groupKey from last successful layout
    },

    callbacks = {
        onSlideOutComplete = nil,
    },

    unacceptedPopup = {
        dataRequestedThisSession = false,
        loadResultDebounceGen   = 0,
    },

    -- Data tables for blacklist/tracking (used by providers)
    recentlyUntrackedWorldQuests      = nil,
    recentlyUntrackedWeekliesAndDailies = nil,
    lastWorldQuestWatchSet            = nil,
    wqtTrackedQuests                 = nil,  -- [questID] = true; synced from WorldQuestTracker

    -- Recipe reagent collapse state
    recipeOptionalCollapsed   = {},
    recipeFinishingCollapsed  = {},
    recipeFinishingAnimating  = {},
    recipeFinishingAnimTime   = {},
    recipeChoiceSlotCollapsed = {},

    -- Objective signature cache for reliable quest-update flash (FocusEvents)
    lastQuestObjectiveSignature       = {},

    -- Current Quest category: [questID] = GetTime() when progress was last detected
    recentlyProgressedQuests          = {},

    -- [questID] = GetTime() when quest expired from recentlyProgressedQuests; used to route to NEARBY
    recentlyExpiredFromCurrent        = {},

    -- M+ size restore: track when we were in M+ so we can restore overworld height on zone-out
    wasInMplusDungeon                 = false,

    -- [questID] = { objectives = {...} } — last known objectives when in zone (for WQ progress outside zone)
    cachedWorldQuestObjectives        = nil,

    -- Scenario widget-step timer cache; avoids countdown jump from stale API samples on refresh.
    -- { widgetSetID, duration, startTime }; cleared on SCENARIO_COMPLETED.
    scenarioTimerCache                = nil,

    -- Quest-based timer cache for WQ/task/calling; avoids countdown jump from C_TaskQuest fallback on refresh.
    -- [questID] = { duration, startTime }; cleared when quest expires, completes, or leaves tracker.
    questTimerCache                   = {},
}

