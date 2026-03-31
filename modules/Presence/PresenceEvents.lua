--[[
    Horizon Suite - Presence - Event Dispatch
    Thin dispatcher: registers events, delegates to domain modules (Quest, Zone, Scenario, Achievement).
    Owns: ADDON_LOADED, PLAYER_LEVEL_UP, RAID_BOSS_EMOTE, RARE_DEFEATED, PLAYER_ENTERING_WORLD.
    Step-by-step flow notes: notes/PresenceEvents.md
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local function Strip(s)
    return addon.Presence.StripMarkup and addon.Presence.StripMarkup(s) or (s or "")
end

-- ============================================================================
-- Event frame and handlers
-- ============================================================================

local eventFrame = CreateFrame("Frame")
local eventsRegistered = false

--- Rare defeated detection state.
local rareVignetteSnapshot = {}
local rareSnapshotInit = false
local lastCombatTime = 0
local RARE_COMBAT_WINDOW = 6
local RARE_DEBOUNCE = 0.5
local RARE_COOLDOWN = 10
local rareDefeatedCooldowns = {}

--- Build current rare entryKey -> title map. Uses addon.GetRaresOnMap when Focus loaded, else addon.GetRareNamesOnMap.
--- @return table entryKey -> name
local function BuildRareSnapshot()
    local out = {}
    if addon.GetRaresOnMap then
        local rares = addon.GetRaresOnMap()
        if rares then
            for _, e in ipairs(rares) do
                if e.entryKey and e.title and e.title ~= "" then
                    out[e.entryKey] = Strip(e.title)
                end
            end
            return out
        end
    end
    if addon.GetRareNamesOnMap then
        local names = addon.GetRareNamesOnMap()
        if names then
            for k, v in pairs(names) do
                if k and v and v ~= "" then
                    out[k] = Strip(v)
                end
            end
        end
    end
    return out
end

local function ShouldSuppress()
    return addon.Presence and addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType()
end

local function IsPresenceTypeEnabled(key, fallbackKey, fallbackDefault)
    return addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled(key, fallbackKey, fallbackDefault) or fallbackDefault
end

local PRESENCE_EVENTS = {
    "ADDON_LOADED",
    "ZONE_CHANGED",
    "ZONE_CHANGED_INDOORS",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_LEVEL_UP",
    "RAID_BOSS_EMOTE",
    "ACHIEVEMENT_EARNED",
    "QUEST_ACCEPTED",
    "QUEST_TURNED_IN",
    "QUEST_REMOVED",
    "QUEST_WATCH_UPDATE",
    "QUEST_LOG_UPDATE",
    "UI_INFO_MESSAGE",
    "PLAYER_ENTERING_WORLD",
    "SCENARIO_UPDATE",
    "SCENARIO_CRITERIA_UPDATE",
    "SCENARIO_COMPLETED",
    "CRITERIA_UPDATE",
    "CRITERIA_EARNED",
    "TRACKED_ACHIEVEMENT_UPDATE",
    "ACTIVE_DELVE_DATA_UPDATE",
    "WALK_IN_DATA_UPDATE",
    "VIGNETTES_UPDATED",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
}

local function OnAddonLoaded(addonName)
    if addonName == "Blizzard_WorldQuestComplete" and addon.Presence.KillWorldQuestBanner then
        C_Timer.After(0.1, function()
            addon.Presence.KillWorldQuestBanner()
        end)
    end
    if addonName == "Blizzard_LevelUpDisplay" or addonName == "Blizzard_RaidBossEmoteFrame" or addonName == "Blizzard_EventToastManager" then
        if addon:IsModuleEnabled("presence") and addon.Presence.ApplyBlizzardSuppression then
            -- Suppress immediately (no delay) so Blizzard can't show frames in between
            addon.Presence.ApplyBlizzardSuppression()
            if addonName == "Blizzard_EventToastManager" and addon.Presence.HookEventToastManager then
                addon.Presence.HookEventToastManager()
            end
            -- Also sweep after a short delay to catch deferred init
            C_Timer.After(0.05, function()
                if addon:IsModuleEnabled("presence") and addon.Presence.ApplyBlizzardSuppression then
                    addon.Presence.ApplyBlizzardSuppression()
                end
            end)
        end
    end
end

local function OnPlayerLevelUp(_, level)
    if not IsPresenceTypeEnabled("presenceLevelUp", nil, true) then return end
    if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    local L = addon.L or {}
    addon.Presence.QueueOrPlay("LEVEL_UP", L["PRESENCE_LEVEL_UP"], L["PRESENCE_YOU_HAVE_REACHED_LEVEL_X"]:format(level or "??"))
end

local function OnRaidBossEmote(_, msg, unitName)
    if not IsPresenceTypeEnabled("presenceBossEmote", nil, true) then return end
    if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    local bossName = unitName or "Boss"
    local formatted = msg or ""
    formatted = formatted:gsub("|T.-|t", "")
    formatted = formatted:gsub("|c%x%x%x%x%x%x%x%x", "")
    formatted = formatted:gsub("|r", "")
    formatted = formatted:gsub("%%s", bossName)
    formatted = strtrim(formatted)
    addon.Presence.QueueOrPlay("BOSS_EMOTE", bossName, formatted)
end

local function OnPlayerEnteringWorld()
    if addon.Presence.Zone_OnInit then addon.Presence.Zone_OnInit() end

    -- Seed rare vignette baseline (prevents false "defeated" toasts on login/reload)
    rareVignetteSnapshot = BuildRareSnapshot()
    rareSnapshotInit = true

    -- Seed achievement progress cache (prevents false progress toasts on login/reload)
    C_Timer.After(1, function()
        if addon.Presence._seedAchievementProgress then
            addon.Presence._seedAchievementProgress()
        end
    end)

    if addon.Presence.Scenario_OnInit then
        addon.Presence.Scenario_OnInit()
    end
end

local function OnScenarioUpdate()
    if addon.Presence.Scenario_OnScenarioUpdate then
        addon.Presence.Scenario_OnScenarioUpdate()
    end
end

local function OnScenarioCriteriaUpdate()
    if addon.Presence.Scenario_OnScenarioCriteriaUpdate then
        addon.Presence.Scenario_OnScenarioCriteriaUpdate()
    end
end

local function OnScenarioCompleted()
    if addon.Presence.Scenario_OnScenarioCompleted then
        addon.Presence.Scenario_OnScenarioCompleted()
    end
end

local function OnZoneChangedNewArea()
    if addon.Presence.Zone_OnZoneChangedNewArea then
        addon.Presence.Zone_OnZoneChangedNewArea()
    end
end

local function OnZoneChanged()
    if addon.Presence.Zone_OnZoneChanged then
        addon.Presence.Zone_OnZoneChanged()
    end
end

local function OnDelveDataUpdate()
    if addon.Presence.Zone_OnDelveDataUpdate then
        addon.Presence.Zone_OnDelveDataUpdate()
    end
    -- Delves may use ACTIVE_DELVE_DATA_UPDATE / WALK_IN_DATA_UPDATE instead of SCENARIO_CRITERIA_UPDATE for objective progress
    if addon.IsDelveActive and addon.IsDelveActive() and addon.Presence.Scenario_OnScenarioCriteriaUpdate then
        addon.Presence.Scenario_OnScenarioCriteriaUpdate()
    end
end

local function OnAchievementEarned(_, achID)
    if addon.Presence.Achievement_OnAchievementEarned then
        addon.Presence.Achievement_OnAchievementEarned(achID)
    end
end

local function OnAchievementCriteriaUpdate(event, ...)
    if addon.Presence.Achievement_OnCriteriaUpdate then
        addon.Presence.Achievement_OnCriteriaUpdate(event, ...)
    end
end

-- ============================================================================
-- RARE DEFEATED DETECTION
-- ============================================================================

local function OnPlayerRegenDisabled()
    lastCombatTime = GetTime()
end

local function OnPlayerRegenEnabled()
    lastCombatTime = GetTime()
end

--- Detect disappeared rares; show toast when one vanishes within combat window.
local function ExecuteRareDefeatedCheck()
    if not IsPresenceTypeEnabled("presenceRareDefeated", nil, true) then return end
    if not addon.GetRaresOnMap and not addon.GetRareNamesOnMap then return end

    local current = BuildRareSnapshot()

    -- First call: seed baseline only (no toasts)
    if not rareSnapshotInit then
        rareVignetteSnapshot = current
        rareSnapshotInit = true
        return
    end

    -- Diff: find rares that were in snapshot but are no longer present
    local now = GetTime()
    if (now - lastCombatTime) > RARE_COMBAT_WINDOW then
        rareVignetteSnapshot = current
        return
    end

    for entryKey, name in pairs(rareVignetteSnapshot) do
        if not current[entryKey] and name and name ~= "" then
            local cooldownKey = name
            if (rareDefeatedCooldowns[cooldownKey] or 0) + RARE_COOLDOWN <= now then
                rareDefeatedCooldowns[cooldownKey] = now
                local L = addon.L or {}
                addon.Presence.QueueOrPlay("RARE_DEFEATED", L["PRESENCE_RARE_DEFEATED"] or "RARE DEFEATED", name, { source = "VIGNETTES_UPDATED" })
            end
        end
    end

    rareVignetteSnapshot = current
end

local function OnVignettesUpdated()
    if not IsPresenceTypeEnabled("presenceRareDefeated", nil, true) then return end

    if addon.Presence and addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("rare", RARE_DEBOUNCE, ExecuteRareDefeatedCheck)
    end
end

local eventHandlers = {
    ADDON_LOADED             = function(_, addonName) OnAddonLoaded(addonName) end,
    PLAYER_LEVEL_UP          = function(_, level) OnPlayerLevelUp(_, level) end,
    RAID_BOSS_EMOTE          = function(_, msg, unitName) OnRaidBossEmote(_, msg, unitName) end,
    ACHIEVEMENT_EARNED       = function(_, achID) OnAchievementEarned(_, achID) end,
    QUEST_ACCEPTED           = function(_, questID) if addon.Presence.Quest_OnQuestAccepted then addon.Presence.Quest_OnQuestAccepted(questID) end end,
    QUEST_TURNED_IN          = function(_, questID) if addon.Presence.Quest_OnQuestTurnedIn then addon.Presence.Quest_OnQuestTurnedIn(questID) end end,
    QUEST_REMOVED            = function(_, questID) if addon.Presence.Quest_OnQuestRemoved then addon.Presence.Quest_OnQuestRemoved(questID) end end,
    QUEST_WATCH_UPDATE       = function(_, questID) if addon.Presence.Quest_OnQuestWatchUpdate then addon.Presence.Quest_OnQuestWatchUpdate(questID) end end,
    QUEST_LOG_UPDATE         = function() if addon.Presence.Quest_OnQuestLogUpdate then addon.Presence.Quest_OnQuestLogUpdate() end end,
    UI_INFO_MESSAGE          = function(_, msgType, msg) if addon.Presence.Quest_OnUIInfoMessage then addon.Presence.Quest_OnUIInfoMessage(msgType, msg) end end,
    PLAYER_ENTERING_WORLD   = function() OnPlayerEnteringWorld() end,
    SCENARIO_UPDATE          = function() OnScenarioUpdate() end,
    SCENARIO_CRITERIA_UPDATE = function() OnScenarioCriteriaUpdate() end,
    SCENARIO_COMPLETED       = function() OnScenarioCompleted() end,
    ZONE_CHANGED_NEW_AREA    = function() OnZoneChangedNewArea() end,
    ZONE_CHANGED             = function() OnZoneChanged() end,
    ZONE_CHANGED_INDOORS     = function() OnZoneChanged() end,
    VIGNETTES_UPDATED        = function() OnVignettesUpdated() end,
    PLAYER_REGEN_DISABLED    = function() OnPlayerRegenDisabled() end,
    PLAYER_REGEN_ENABLED     = function() OnPlayerRegenEnabled() end,
    CRITERIA_UPDATE            = function(event, ...) OnAchievementCriteriaUpdate(event, ...) end,
    CRITERIA_EARNED            = function(event, ...) OnAchievementCriteriaUpdate(event, ...) end,
    TRACKED_ACHIEVEMENT_UPDATE = function(event, ...) OnAchievementCriteriaUpdate(event, ...) end,
    ACTIVE_DELVE_DATA_UPDATE = function() OnDelveDataUpdate() end,
    WALK_IN_DATA_UPDATE      = function() OnDelveDataUpdate() end,
}

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if not addon:IsModuleEnabled("presence") then return end
    local fn = eventHandlers[event]
    if fn then fn(event, ...) end
end)

--- Register all Presence events. Idempotent.
--- @return nil
local function EnableEvents()
    if eventsRegistered then return end
    for _, evt in ipairs(PRESENCE_EVENTS) do
        eventFrame:RegisterEvent(evt)
    end
    eventsRegistered = true
    addon.Presence._suppressQuestUpdateOnReload = true
    C_Timer.After(2, function()
        addon.Presence._suppressQuestUpdateOnReload = nil
    end)
end

--- Unregister all Presence events.
--- @return nil
local function DisableEvents()
    if not eventsRegistered then return end
    for _, evt in ipairs(PRESENCE_EVENTS) do
        eventFrame:UnregisterEvent(evt)
    end
    eventsRegistered = false
end

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.EnableEvents   = EnableEvents
addon.Presence.DisableEvents = DisableEvents
addon.Presence.eventFrame    = eventFrame
