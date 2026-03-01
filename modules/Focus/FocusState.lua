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

    -- M+ size restore: track when we were in M+ so we can restore overworld height on zone-out
    wasInMplusDungeon                 = false,
}

