--[[
    Horizon Suite - Presence - Suppression Registry

    Singular source of truth: each category's per-DB toggle controls BOTH
    whether Presence renders for the matching presenceTypes AND whether
    Blizzard's matching frame is hidden. There is intentionally no path
    to "Presence on top of Blizzard".

    Per-area toggle:
      ON  -> Presence shows + Blizzard frame hidden
      OFF -> No Presence + Blizzard frame shows

    Master `presenceSuppressAll`:
      ON  -> Forces Blizzard suppression for every category regardless of
             per-area toggle. Per-area toggle still controls whether
             Presence shows. (Per-area OFF + master ON = silence.)
      OFF -> Per-area toggle is the only suppression input.

    Categories without `presenceTypes` (BOSS_BANNER, OBJECTIVE_BANNERS) have
    no Presence equivalent, so their toggle is purely Blizzard suppression.
    AlertFrame muting (achievement/quest/criteria small popups) is handled
    by PresenceErrors and gates on the EVENT_TOASTS category, since both
    surfaces fire for the same underlying user events.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end
addon.Presence = addon.Presence or {}

-- ============================================================================
-- Registry
-- ============================================================================

local CATEGORIES = {
    ZONE_TEXT = {
        dbKey         = "presenceSuppressZoneText",
        default       = true,
        label         = "Zone entry",
        frames        = { "ZoneTextFrame" },
        presenceTypes = { "ZONE_CHANGE" },
    },
    SUBZONE_TEXT = {
        dbKey         = "presenceSuppressSubzoneText",
        default       = true,
        label         = "Subzone change",
        frames        = { "SubZoneTextFrame" },
        presenceTypes = { "SUBZONE_CHANGE" },
    },
    LEVEL_UP = {
        dbKey         = "presenceSuppressLevelUp",
        default       = true,
        label         = "Level up",
        frames        = { "LevelUpDisplay" },
        presenceTypes = { "LEVEL_UP" },
    },
    BOSS_EMOTE = {
        dbKey         = "presenceSuppressBossEmote",
        default       = true,
        label         = "Boss emote",
        frames        = { "RaidBossEmoteFrame" },
        presenceTypes = { "BOSS_EMOTE" },
    },
    EVENT_TOASTS = {
        -- Shared Blizzard frame for achievements / quests / scenarios / rares.
        -- Also gates AlertFrame muting (small achievement/quest popups) via PresenceErrors.
        dbKey         = "presenceSuppressEventToasts",
        default       = true,
        label         = "Achievements, quests, scenarios",
        frames        = { "EventToastManagerFrame" },
        presenceTypes = {
            "ACHIEVEMENT", "ACHIEVEMENT_PROGRESS",
            "QUEST_ACCEPT", "QUEST_COMPLETE", "QUEST_UPDATE", "WORLD_QUEST_ACCEPT",
            "SCENARIO_START", "SCENARIO_UPDATE", "SCENARIO_COMPLETE",
            "RARE_DEFEATED",
        },
    },
    WORLD_QUEST_BANNER = {
        dbKey         = "presenceSuppressWorldQuestBanner",
        default       = true,
        label         = "World quest complete",
        frames        = { "WorldQuestCompleteBannerFrame" },
        presenceTypes = { "WORLD_QUEST" },
    },
    BOSS_BANNER = {
        -- No Presence equivalent; pure Blizzard suppression.
        dbKey   = "presenceSuppressBossBanner",
        default = true,
        label   = "Boss kill banner (no Presence equivalent)",
        frames  = { "BossBanner" },
    },
    OBJECTIVE_BANNERS = {
        -- No Presence equivalent; pure Blizzard suppression.
        dbKey   = "presenceSuppressObjectiveBanners",
        default = true,
        label   = "Objective tracker banners (no Presence equivalent)",
        frames  = { "ObjectiveTrackerBonusBannerFrame", "ObjectiveTrackerTopBannerFrame" },
    },
}

-- ============================================================================
-- Public API
-- ============================================================================

local MASTER_KEY     = "presenceSuppressAll"
local MASTER_DEFAULT = true

local function getDB(key, default)
    if addon.GetDB then return addon.GetDB(key, default) end
    return default
end

local function asBool(v, fallback)
    if v == nil then return fallback end
    return v and true or false
end

--- Is the master "Suppress all Blizzard popups" toggle on?
--- Default true so the out-of-box behavior matches the legacy "hard suppress everything".
--- @return boolean
local function IsSuppressAllOn()
    return asBool(getDB(MASTER_KEY, MASTER_DEFAULT), MASTER_DEFAULT)
end

local function categoryEnabled(entry)
    return asBool(getDB(entry.dbKey, entry.default), entry.default)
end

--- Resolve the Blizzard suppression decision for a category.
--- Order: master > per-category toggle > false.
--- @param category string Category id (e.g. "LEVEL_UP")
--- @return boolean suppressed True when Presence should hide Blizzard's frame
local function IsSuppressed(category)
    local entry = CATEGORIES[category]
    if not entry then return false end
    if IsSuppressAllOn() then return true end
    return categoryEnabled(entry)
end

--- Resolve whether Presence should render its toast for a Presence type.
--- Driven by the same per-category toggle that suppresses Blizzard's frame
--- for this type, so display and suppression cannot diverge.
--- @param typeName string Presence type id (e.g. "LEVEL_UP", "QUEST_COMPLETE")
--- @return boolean rendered True when Presence should show its toast
local function IsTypeRendered(typeName)
    if not typeName then return false end
    for _, entry in pairs(CATEGORIES) do
        if entry.presenceTypes then
            for _, t in ipairs(entry.presenceTypes) do
                if t == typeName then return categoryEnabled(entry) end
            end
        end
    end
    return false
end

--- Iterate all categories; useful for options panel and debug dumps.
--- @return table CATEGORIES
local function GetCategories()
    return CATEGORIES
end

--- Resolve registered Blizzard frame globals for a category (skips nils).
--- @param category string
--- @return table list of frame objects
local function GetFrames(category)
    local entry = CATEGORIES[category]
    if not entry or not entry.frames then return {} end
    local out = {}
    for _, name in ipairs(entry.frames) do
        local f = _G[name]
        if f then out[#out + 1] = f end
    end
    return out
end

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.Suppression = {
    IsSuppressed    = IsSuppressed,
    IsSuppressAllOn = IsSuppressAllOn,
    IsTypeRendered  = IsTypeRendered,
    GetCategories   = GetCategories,
    GetFrames       = GetFrames,
    MASTER_KEY      = MASTER_KEY,
    MASTER_DEFAULT  = MASTER_DEFAULT,
}
