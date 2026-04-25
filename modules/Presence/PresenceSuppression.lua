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
        -- Catch-all for EventToastManagerFrame templates not claimed by a more
        -- specific category. EventToastManagerFrame is no longer whole-frame
        -- killed; suppression is per-toast in PresenceBlizzard's GetToastFrame
        -- post-hook, dispatched by toastInfo.template via GetCategoryForTemplate.
        -- Also gates AlertFrame muting via PresenceErrors.
        -- Scenario types are listed here as a non-contextual fallback so any
        -- scenario that is neither a delve nor abundance still dispatches here.
        dbKey         = "presenceSuppressEventToasts",
        default       = true,
        label         = "Achievements, quests, scenarios",
        presenceTypes = {
            "ACHIEVEMENT", "ACHIEVEMENT_PROGRESS",
            "QUEST_ACCEPT", "QUEST_COMPLETE", "QUEST_UPDATE", "WORLD_QUEST_ACCEPT",
            "RARE_DEFEATED",
            "SCENARIO_START", "SCENARIO_UPDATE", "SCENARIO_COMPLETE",
        },
        catchAllToastTemplates = true,
    },
    ABUNDANCE = {
        -- Active only inside an Abundance scenario. Both ABUNDANCE and DELVE
        -- claim the same templates and scenario Presence types; the
        -- `contextCheck` predicate disambiguates at runtime so a Blizzard
        -- delve toast routes to DELVE and an abundance toast routes to
        -- ABUNDANCE, even though they use the same Blizzard UI templates.
        dbKey         = "presenceSuppressAbundance",
        default       = true,
        label         = "Abundance",
        presenceTypes = { "SCENARIO_START", "SCENARIO_UPDATE", "SCENARIO_COMPLETE" },
        templates     = { "EventToastScenarioExpandToastTemplate", "EventToastDialogToastTemplate" },
        contextCheck  = function() return addon.IsAbundanceScenario and addon.IsAbundanceScenario() and true or false end,
    },
    DELVE = {
        -- Active only inside a Delve.
        dbKey         = "presenceSuppressDelve",
        default       = true,
        label         = "Delve start / summary",
        presenceTypes = { "SCENARIO_START", "SCENARIO_UPDATE", "SCENARIO_COMPLETE" },
        templates     = { "EventToastScenarioExpandToastTemplate", "EventToastDialogToastTemplate" },
        contextCheck  = function() return addon.IsDelveActive and addon.IsDelveActive() and true or false end,
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

local function categoryClaimsType(entry, typeName)
    if not entry.presenceTypes then return false end
    for _, t in ipairs(entry.presenceTypes) do
        if t == typeName then return true end
    end
    return false
end

local function categoryClaimsTemplate(entry, template)
    if not entry.templates then return false end
    for _, t in ipairs(entry.templates) do
        if t == template then return true end
    end
    return false
end

local function contextHolds(entry)
    if not entry.contextCheck then return true end
    local ok, isMatch = pcall(entry.contextCheck)
    return ok and isMatch and true or false
end

--- Resolve whether Presence should render its toast for a Presence type.
--- When multiple categories claim the same Presence type, contextual ones
--- (those with a `contextCheck`) win when their predicate holds; otherwise
--- the first non-contextual claimant decides. This lets ABUNDANCE and
--- DELVE both claim SCENARIO_* types and dispatch by current scenario.
--- @param typeName string Presence type id (e.g. "LEVEL_UP", "QUEST_COMPLETE")
--- @return boolean rendered True when Presence should show its toast
local function IsTypeRendered(typeName)
    if not typeName then return false end
    for _, entry in pairs(CATEGORIES) do
        if entry.contextCheck and categoryClaimsType(entry, typeName) and contextHolds(entry) then
            return categoryEnabled(entry)
        end
    end
    for _, entry in pairs(CATEGORIES) do
        if not entry.contextCheck and categoryClaimsType(entry, typeName) then
            return categoryEnabled(entry)
        end
    end
    return false
end

--- Iterate all categories; useful for options panel and debug dumps.
--- @return table CATEGORIES
local function GetCategories()
    return CATEGORIES
end

--- Map a Blizzard toast template name to its registry category, taking
--- runtime scenario context into account. Resolution order:
---  1. Categories that claim the template AND whose `contextCheck` holds
---     (e.g. ABUNDANCE only when in an abundance scenario).
---  2. Categories that claim the template without a `contextCheck`.
---  3. The category flagged `catchAllToastTemplates = true` (EVENT_TOASTS).
--- @param template string Blizzard toast template (e.g. `EventToastScenarioExpandToastTemplate`)
--- @return string|nil category id, or nil when nothing claims it
local function GetCategoryForTemplate(template)
    if not template then return nil end
    for category, entry in pairs(CATEGORIES) do
        if entry.contextCheck and categoryClaimsTemplate(entry, template) and contextHolds(entry) then
            return category
        end
    end
    for category, entry in pairs(CATEGORIES) do
        if not entry.contextCheck and categoryClaimsTemplate(entry, template) then
            return category
        end
    end
    for category, entry in pairs(CATEGORIES) do
        if entry.catchAllToastTemplates then return category end
    end
    return nil
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
    IsSuppressed           = IsSuppressed,
    IsSuppressAllOn        = IsSuppressAllOn,
    IsTypeRendered         = IsTypeRendered,
    GetCategoryForTemplate = GetCategoryForTemplate,
    GetCategories          = GetCategories,
    GetFrames              = GetFrames,
    MASTER_KEY             = MASTER_KEY,
    MASTER_DEFAULT         = MASTER_DEFAULT,
}
