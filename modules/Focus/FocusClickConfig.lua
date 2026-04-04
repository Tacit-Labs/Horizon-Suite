--[[
    Horizon Suite - Focus - Click Config
    Unified click shortcut system: profiles, dispatcher, combo options.
    Quest and tracked-appearance rows share PROFILES and focusClick_*; executors differ in FocusInteractions.lua.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- When true: only blizzardDefault is active; Horizon+ and Custom are hidden and DB is normalized.
-- Set false when those presets are ready to ship again.
local FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD = true

-- ============================================================================
-- Action registry: maps action keys to localization keys for dropdown labels.
-- ============================================================================

local ACTION_LABELS = {
    none           = "OPTIONS_FOCUS_CLICK_ACTION_NONE",
    superTrack     = "OPTIONS_FOCUS_CLICK_ACTION_SUPER_TRACK",
    openProfession = "OPTIONS_FOCUS_CLICK_ACTION_OPEN_PROFESSION",
    openQuestLog   = "OPTIONS_FOCUS_CLICK_ACTION_OPEN_QUEST_LOG",
    untrack        = "OPTIONS_FOCUS_CLICK_ACTION_UNTRACK",
    contextMenu    = "OPTIONS_FOCUS_CLICK_ACTION_CONTEXT_MENU",
    share          = "OPTIONS_FOCUS_CLICK_ACTION_SHARE",
    abandon        = "OPTIONS_FOCUS_CLICK_ACTION_ABANDON",
    wowhear        = "OPTIONS_FOCUS_CLICK_ACTION_WOWHEAD",
    chatLink       = "OPTIONS_FOCUS_CLICK_ACTION_CHAT_LINK",
}

-- ============================================================================
-- Combo → available actions: only sensible actions per modifier+button combo.
-- ============================================================================

local COMBO_OPTIONS = {
    left       = { "superTrack", "openProfession", "openQuestLog", "none" },
    shiftLeft  = { "openProfession", "openQuestLog", "untrack", "chatLink", "none" },
    ctrlLeft   = { "share", "none" },
    altLeft    = { "wowhear", "chatLink", "none" },
    right      = { "untrack", "contextMenu", "none" },
    shiftRight = { "abandon", "untrack", "none" },
    ctrlRight  = { "share", "contextMenu", "none" },
}

-- ============================================================================
-- Combo keys (ordered for display in options).
-- ============================================================================

local COMBO_KEYS = {
    "left",
    "shiftLeft",
    "ctrlLeft",
    "altLeft",
    "right",
    "shiftRight",
    "ctrlRight",
}

-- Default per-combo action for the "Custom" profile falls back to Horizon+.

-- ============================================================================
-- Built-in profiles.
-- ============================================================================

local PROFILES = {
    -- Current Horizon behaviour.
    horizonPlus = {
        left       = "superTrack",
        shiftLeft  = "openProfession",
        ctrlLeft   = "share",
        altLeft    = "wowhear",
        right      = "untrack",
        shiftRight = "abandon",
        ctrlRight  = "none",
    },
    -- Blizzard-style baseline plus Horizon tweaks (Blizzard+); Ctrl+click share removed — share lives elsewhere.
    blizzardDefault = {
        left       = "openProfession",
        shiftLeft  = "untrack",
        ctrlLeft   = "none",
        altLeft    = "wowhear",
        right      = "contextMenu",
        shiftRight = "abandon",
        ctrlRight  = "none",
    },
    -- "custom" profile has no entry here; it reads per-combo DB keys.
}

-- ============================================================================
-- Private helpers.
-- ============================================================================

--- Build the combo key string from button + modifiers.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @return string e.g. "shiftLeft", "right", "ctrlRight"
local function ResolveComboKey(button, mods)
    local prefix = mods.shift and "shift" or mods.ctrl and "ctrl" or mods.alt and "alt" or ""
    if prefix == "" then
        -- Plain clicks: keys are "left" / "right" (lowercase).
        return (button == "RightButton") and "right" or "left"
    end
    -- Modifier combos: camelCase keys match PROFILES / COMBO_KEYS / focusClick_* (e.g. shiftLeft, ctrlRight).
    local side = (button == "RightButton") and "Right" or "Left"
    return prefix .. side
end

--- If DB/profile returned an unknown action, fall back to preset default for this combo.
--- @param action any
--- @param comboKey string
--- @return string
local function SanitizeQuestClickAction(action, comboKey)
    if type(action) ~= "string" or action == "" or not ACTION_LABELS[action] then
        local preset = FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD and PROFILES.blizzardDefault or PROFILES.horizonPlus
        return preset[comboKey] or "none"
    end
    return action
end

-- ============================================================================
-- Exported: dispatcher.
-- ============================================================================

--- Resolve button + modifiers to combo key (e.g. "shiftLeft") for logging and tools.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @return string
function addon.focus.GetQuestClickComboKey(button, mods)
    return ResolveComboKey(button, mods)
end

--- True when the quest/appearance type icon is shown and super-tracks on left click (legacy classic toggle or Blizzard+ profile).
--- @return boolean
function addon.focus.UseBlizzardStyleQuestIconClicks()
    if FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD then return true end
    if addon.GetDB("useClassicClickBehaviour", false) then return true end
    return addon.GetDB("focusClickProfile", "blizzardDefault") == "blizzardDefault"
end

--- Return the action name for a quest-row click.
--- Called from FocusInteractions.lua on every quest-row mouse event.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @param profile string|nil If already read by caller, pass it to skip a second DB read.
--- @return string action key (e.g. "superTrack", "untrack", "none")
function addon.focus.GetQuestClickAction(button, mods, profile)
    if not profile then profile = addon.GetDB("focusClickProfile", "blizzardDefault") end
    if FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD then
        profile = "blizzardDefault"
    end
    local comboKey = ResolveComboKey(button, mods)

    local raw
    if profile == "custom" then
        local dbKey   = "focusClick_" .. comboKey
        local default = (PROFILES["horizonPlus"][comboKey] or "none")
        raw = addon.GetDB(dbKey, default)
    else
        local t = PROFILES[profile] or PROFILES["horizonPlus"]
        raw = t[comboKey] or "none"
    end

    return SanitizeQuestClickAction(raw, comboKey)
end

--- Same resolution as GetQuestClickAction (shared PROFILES and focusClick_*); appearance row handling differs only in ExecuteAppearanceAction.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @param profile string|nil
--- @return string action key
function addon.focus.GetAppearanceClickAction(button, mods, profile)
    return addon.focus.GetQuestClickAction(button, mods, profile)
end

-- ============================================================================
-- Exported: combo options builder (used by OptionsData.lua at load time).
-- ============================================================================

--- Return a dropdown options table for a given combo key.
--- Each entry is { displayLabel, actionKey }.
--- @param comboKey string
--- @return table
local function GetComboOptions(comboKey)
    local result = {}
    local L = addon.L
    for _, actionKey in ipairs(COMBO_OPTIONS[comboKey] or {}) do
        local labelKey = ACTION_LABELS[actionKey]
        local label = (L and labelKey and L[labelKey]) or actionKey
        result[#result + 1] = { label, actionKey }
    end
    return result
end

-- ============================================================================
-- Export table (read by OptionsData.lua after this file loads).
-- ============================================================================

addon.focus.clickConfig = {
    GetComboOptions          = GetComboOptions,
    COMBO_KEYS               = COMBO_KEYS,
    PROFILES                 = PROFILES,
    profilesLockedToBlizzard = FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD,
}

-- ============================================================================
-- One-time migration: map old useClassicClickBehaviour → focusClickProfile.
-- Runs at file load (after addon.GetDB / addon.SetDB are available via Core.lua).
-- ============================================================================

local function MigrateClickProfile()
    -- Skip if already migrated (focusClickProfile is set).
    if addon.GetDB("focusClickProfile", nil) ~= nil then return end

    local wasClassic = addon.GetDB("useClassicClickBehaviour", false)
    if FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD or wasClassic then
        addon.SetDB("focusClickProfile", "blizzardDefault")
    else
        addon.SetDB("focusClickProfile", "horizonPlus")
    end
    -- useClassicClickBehaviour is intentionally left in DB for safe rollback.
end

--- While profiles are locked to Blizzard, coerce horizonPlus/custom saves to blizzardDefault.
--- @return nil
local function NormalizeFocusClickProfileToBlizzard()
    if not FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD then return end
    local p = addon.GetDB("focusClickProfile", "blizzardDefault")
    if p ~= "blizzardDefault" then
        addon.SetDB("focusClickProfile", "blizzardDefault")
    end
end

MigrateClickProfile()
NormalizeFocusClickProfileToBlizzard()
