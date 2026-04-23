--[[
    Horizon Suite - Focus - Click Config
    Unified click shortcut system: profiles, dispatcher, combo options.
    Quest and tracked-appearance rows share PROFILES and focusClick_*; executors differ in FocusInteractions.lua.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- When true: only blizzardDefault is active; Horizon+ and Custom are hidden and DB is normalized.
local FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD = false

-- ============================================================================
-- Action registry: maps action keys to localization keys for dropdown labels.
-- ============================================================================

local ACTION_LABELS = {
    none           = "FOCUS_CLICK_ACTION_NONE",
    superTrack     = "FOCUS_CLICK_ACTION_SUPER_TRACK",
    openDetails    = "FOCUS_CLICK_ACTION_OPEN_DETAILS",
    untrack        = "FOCUS_CLICK_ACTION_UNTRACK",
    contextMenu    = "FOCUS_CLICK_ACTION_CONTEXT_MENU",
    share          = "FOCUS_CLICK_ACTION_SHARE",
    abandon        = "FOCUS_CLICK_ACTION_ABANDON",
    wowhear        = "FOCUS_CLICK_ACTION_WOWHEAD",
    chatLink       = "FOCUS_CLICK_ACTION_CHAT_LINK",
    preview        = "FOCUS_CLICK_ACTION_PREVIEW",
}

-- ============================================================================
-- Combo → available actions: only sensible actions per modifier+button combo.
-- ============================================================================

local COMBO_OPTIONS = {
    left       = { "superTrack", "openDetails", "none" },
    shiftLeft  = { "openDetails", "untrack", "chatLink", "none" },
    ctrlLeft   = { "preview", "share", "none" },
    altLeft    = { "wowhear", "chatLink", "none" },
    right      = { "untrack", "contextMenu", "none" },
    shiftRight = { "abandon", "untrack", "none" },
    ctrlRight  = { "share", "contextMenu", "none" },
    altRight   = { "contextMenu", "wowhear", "chatLink", "none" },
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
    "altRight",
}

-- Every action in ACTION_LABELS; used for Custom profile dropdowns (full list per combo).
local ALL_COMBO_ACTION_KEYS = {
    "superTrack",
    "openDetails",
    "untrack",
    "contextMenu",
    "share",
    "abandon",
    "wowhear",
    "chatLink",
    "preview",
    "none",
}

-- Icon button uses a smaller curated list than full Custom row combos.
local ICON_ACTION_KEYS = {
    "superTrack",
    "openDetails",
    "contextMenu",
    "untrack",
    "wowhear",
    "none",
}

-- Default per-combo action for the "Custom" profile falls back to Blizzard+ (PROFILES.blizzardDefault).

-- ============================================================================
-- Built-in profiles.
-- ============================================================================

local PROFILES = {
    -- Horizon+: super-track first, quest log on Shift+left, plain right untrack; Ctrl+right opens context menu as escape hatch.
    horizonPlus = {
        left       = "superTrack",
        shiftLeft  = "openDetails",
        ctrlLeft   = "share",
        altLeft    = "wowhear",
        right      = "untrack",
        shiftRight = "abandon",
        ctrlRight  = "contextMenu",
        altRight   = "none",
    },
    -- Blizzard-style baseline plus Horizon tweaks (Blizzard+); Ctrl+click previews collection rows (dressing room / decor preview).
    blizzardDefault = {
        left       = "openDetails",
        shiftLeft  = "untrack",
        ctrlLeft   = "preview",
        altLeft    = "wowhear",
        right      = "contextMenu",
        shiftRight = "abandon",
        ctrlRight  = "none",
        altRight   = "none",
    },
    -- "custom" profile has no entry here; it reads per-combo DB keys.
}

-- ============================================================================
-- Private helpers.
-- ============================================================================

--- Build the combo key string from button + modifiers.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @return string e.g. "shiftLeft", "right", "ctrlRight", "altRight"
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

--- Normalize legacy action keys to the current canonical action names.
--- @param action any
--- @return any
local function NormalizeQuestClickAction(action)
    if action == "openQuestLog" or action == "openProfession" then
        return "openDetails"
    end
    return action
end

--- Normalize stored icon action to a valid supported action key.
--- @param action any
--- @return string
local function NormalizeIconClickAction(action)
    action = NormalizeQuestClickAction(action)
    if type(action) ~= "string" or not ACTION_LABELS[action] then
        return "superTrack"
    end
    for _, actionKey in ipairs(ICON_ACTION_KEYS) do
        if actionKey == action then
            return action
        end
    end
    return "superTrack"
end

--- If DB/profile returned an unknown action, fall back to preset default for this combo.
--- @param action any
--- @param comboKey string
--- @param profile string focusClickProfile value (e.g. custom, blizzardDefault, horizonPlus)
--- @return string
local function SanitizeQuestClickAction(action, comboKey, profile)
    action = NormalizeQuestClickAction(action)
    if type(action) ~= "string" or action == "" or not ACTION_LABELS[action] then
        local preset
        if FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD then
            preset = PROFILES.blizzardDefault
        elseif profile == "custom" then
            preset = PROFILES.blizzardDefault
        else
            preset = PROFILES[profile] or PROFILES.horizonPlus
        end
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

--- True when the dedicated quest/appearance icon button should be shown and clickable.
--- @return boolean
function addon.focus.UseFocusIconClickButton()
    return addon.GetDB("focusIconClickAction", "superTrack") ~= "none"
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
        local default = (PROFILES.blizzardDefault[comboKey] or "none")
        raw = addon.GetDB(dbKey, default)
    else
        local t = PROFILES[profile] or PROFILES["horizonPlus"]
        raw = t[comboKey] or "none"
    end

    return SanitizeQuestClickAction(raw, comboKey, profile)
end

--- Same resolution as GetQuestClickAction (shared PROFILES and focusClick_*); appearance row handling differs only in ExecuteAppearanceAction.
--- @param button string "LeftButton" | "RightButton"
--- @param mods table { shift=bool, ctrl=bool, alt=bool }
--- @param profile string|nil
--- @return string action key
function addon.focus.GetAppearanceClickAction(button, mods, profile)
    return addon.focus.GetQuestClickAction(button, mods, profile)
end

-- Combo key → (button, mods) for resolving actions without a live mouse event.
local COMBO_MOUSE = {
    left       = { "LeftButton",  { shift = false, ctrl = false, alt = false } },
    shiftLeft  = { "LeftButton",  { shift = true,  ctrl = false, alt = false } },
    ctrlLeft   = { "LeftButton",  { shift = false, ctrl = true,  alt = false } },
    altLeft    = { "LeftButton",  { shift = false, ctrl = false, alt = true  } },
    right      = { "RightButton", { shift = false, ctrl = false, alt = false } },
    shiftRight = { "RightButton", { shift = true,  ctrl = false, alt = false } },
    ctrlRight  = { "RightButton", { shift = false, ctrl = true,  alt = false } },
    altRight   = { "RightButton", { shift = false, ctrl = false, alt = true  } },
}

local COMBO_LABEL_KEYS = {
    left       = "FOCUS_COMBO_LEFT",
    shiftLeft  = "FOCUS_COMBO_SHIFT_LEFT",
    ctrlLeft   = "FOCUS_COMBO_CTRL_LEFT",
    altLeft    = "FOCUS_COMBO_ALT_LEFT",
    right      = "FOCUS_COMBO_RIGHT",
    shiftRight = "FOCUS_COMBO_SHIFT_RIGHT",
    ctrlRight  = "FOCUS_COMBO_CTRL_RIGHT",
    altRight   = "FOCUS_COMBO_ALT_RIGHT",
}

--- Localized description of which click combo(s) run the WoWhead action (for tooltips).
--- @param profile string|nil Optional; defaults to current focusClickProfile from DB.
--- @return string Empty when no combo is bound to WoWhead.
function addon.focus.GetWoWheadClickBindingHint(profile)
    local parts = {}
    local L = addon.L
    for _, comboKey in ipairs(COMBO_KEYS) do
        local mouse = COMBO_MOUSE[comboKey]
        if mouse then
            local action = addon.focus.GetQuestClickAction(mouse[1], mouse[2], profile)
            if action == "wowhear" then
                local lk = COMBO_LABEL_KEYS[comboKey]
                local label = (L and lk and L[lk]) or comboKey
                parts[#parts + 1] = label
            end
        end
    end
    if #parts == 0 then
        return ""
    end
    local sep = (L and L["FOCUS_WOWHEAD_HINT_LIST_SEPARATOR"]) or " · "
    return table.concat(parts, sep)
end

-- ============================================================================
-- Exported: combo options builder (used by OptionsData.lua; presets vs Custom full list).
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

--- Full action list for Custom profile (same options on every combo dropdown).
--- @return table Array of { displayLabel, actionKey }.
local function GetAllComboActionOptions()
    local result = {}
    local L = addon.L
    for _, actionKey in ipairs(ALL_COMBO_ACTION_KEYS) do
        local labelKey = ACTION_LABELS[actionKey]
        local label = (L and labelKey and L[labelKey]) or actionKey
        result[#result + 1] = { label, actionKey }
    end
    return result
end

--- Curated icon-button actions shared by quest and appearance icons.
--- @return table Array of { displayLabel, actionKey }.
local function GetIconActionOptions()
    local result = {}
    local L = addon.L
    for _, actionKey in ipairs(ICON_ACTION_KEYS) do
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
    GetComboOptions            = GetComboOptions,
    GetAllComboActionOptions   = GetAllComboActionOptions,
    GetIconActionOptions       = GetIconActionOptions,
    COMBO_KEYS                 = COMBO_KEYS,
    PROFILES                   = PROFILES,
    NormalizeAction            = NormalizeQuestClickAction,
    NormalizeIconAction        = NormalizeIconClickAction,
    profilesLockedToBlizzard   = FOCUS_CLICK_PROFILES_LOCKED_TO_BLIZZARD,
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
