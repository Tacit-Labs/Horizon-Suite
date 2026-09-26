--[[
    Horizon Suite - Platform
    Client detection and the capability table modules consult before touching a
    game system that only some clients have.

    Two clients share the Retail (Mainline) UI API today:
      - Retail / Midnight  - interface 12xxxx, WOW_PROJECT_MAINLINE
      - WoW: Forever       - interface 16001 (build 1.60.x), also WOW_PROJECT_MAINLINE

    Forever ships the full Retail namespace set, so "does C_ChallengeMode exist"
    is not enough to know whether Mythic+ exists as a game system there. Each
    capability below is namespace presence AND what the client is known to have.
    Prefer addon.Platform.Has("key") over ad-hoc GetBuildInfo checks: the
    interface number is beta-stage and may move at launch, so it lives here only.

    /h platform prints the table in-game.
]]

local addon = _G.HorizonSuite

local Platform = {}
addon.Platform = Platform

local _, build, _, interface = GetBuildInfo()
Platform.interfaceVersion = tonumber(interface) or 0
Platform.buildNumber      = tonumber(build) or 0
Platform.projectID        = WOW_PROJECT_ID

-- Forever is the only Mainline-project client below interface 20000; Classic
-- flavours carry their own project IDs, so the pair is unambiguous.
local isMainline = (WOW_PROJECT_ID == nil) or (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Platform.isForever = isMainline and Platform.interfaceVersion > 0 and Platform.interfaceVersion < 20000
Platform.isRetail  = isMainline and not Platform.isForever
Platform.name      = Platform.isForever and "Forever" or (Platform.isRetail and "Retail" or "Unknown")

local function HasFunction(namespace, key)
    return type(namespace) == "table" and type(namespace[key]) == "function"
end

-- Systems the Forever beta is known not to have (captured API baseline, September 2026),
-- even though the namespaces are still present in the client.
local ABSENT_ON_FOREVER = {
    specs       = true,
    heroTalents = true,
    mythicPlus  = true,
    delves      = true,
    housing     = true,
    weeklyVault = true,
    adventureGuide = true,  -- Traveler's Log: probe returned 0 activities (Trading Post is Retail-only)
}

-- Systems Forever exposes through the API whose content has not been verified on
-- the beta. They default to present; the in-game spike settles each one.
-- Verified present on the Forever beta (2026-09-18 probe): achievements (111 in 29
-- categories), transmog (237 head appearances), professions (20 tradeskill lines with
-- recipe schematics), content tracking enums. Still open: nothing on the beta has yet
-- shown a task quest or a scenario, so both stay flagged until one is seen.
Platform.unverified = {
    worldQuests    = true,
    scenarios      = true,
    -- Group loot: every call is tagged for both Midnight 12.1.5 and Forever
    -- 1.60.1. The 2026-09-24 probes found Forever defaulting to method=Group (3)
    -- where Retail defaults to Personal (5) — the one value that differs by
    -- client; threshold and enum are identical on both. Still flagged,
    -- because nobody has watched a roll actually open: configuration being
    -- right is not the same as the system firing, and a present namespace has
    -- proven nothing here before (see the delve note above).
    groupLootRolls = true,
    lootHistory    = true,
    -- Echo (2026-09-25): settled by /h echo probe on each client.
    bnetWhispers = true,
    secretChat   = true,
}

local detected = {
    specs           = type(GetSpecialization) == "function" and type(GetSpecializationInfo) == "function",
    heroTalents     = HasFunction(C_ClassTalents, "GetActiveHeroTalentSpec") and HasFunction(C_Traits, "GetSubTreeInfo"),
    mythicPlus      = HasFunction(C_ChallengeMode, "GetActiveKeystoneInfo") and C_MythicPlus ~= nil,
    delves          = C_DelvesUI ~= nil,
    housing         = C_HousingDecor ~= nil or C_Endeavors ~= nil,
    weeklyVault     = HasFunction(C_WeeklyRewards, "HasAvailableRewards"),
    worldQuests     = C_TaskQuest ~= nil and HasFunction(C_QuestLog, "IsWorldQuest"),
    scenarios       = C_ScenarioInfo ~= nil or C_Scenario ~= nil,
    achievements    = type(GetAchievementInfo) == "function",
    transmog        = C_TransmogCollection ~= nil,
    professions     = C_TradeSkillUI ~= nil,
    adventureGuide  = HasFunction(C_PerksActivities, "GetPerksActivitiesInfo"),  -- Traveler's Log
    contentTracking = C_ContentTracking ~= nil,
    -- Group loot rolls: the roll frame needs only these three globals. Which
    -- *buttons* a given roll offers is answered per-item by GetLootRollItemInfo's
    -- can* flags, not by this key (see Augment/LootRoll).
    groupLootRolls  = type(RollOnLoot) == "function"
                      and type(GetLootRollItemInfo) == "function"
                      and type(GetLootRollTimeLeft) == "function",
    -- Loot history backs the live roll tally only. Kept separate from
    -- groupLootRolls so a client that rolls but reports no history loses the
    -- tally row and keeps the working buttons.
    lootHistory     = HasFunction(C_LootHistory, "GetSortedDropsForEncounter")
                      and HasFunction(C_LootHistory, "GetSortedInfoForDrop"),
    -- Echo: Battle.net whisper sending, and Midnight secret chat payloads. Both stay
    -- in Platform.unverified until /h echo probe has been run on the Forever beta.
    bnetWhispers    = type(BNSendWhisper) == "function" or HasFunction(C_BattleNet, "SendWhisper"),
    secretChat      = type(issecretvalue) == "function",
}

Platform.has = {}
for key, present in pairs(detected) do
    local absent = Platform.isForever and ABSENT_ON_FOREVER[key]
    Platform.has[key] = (present and not absent) and true or false
end

-- @param key string  Capability key (see Platform.has)
-- @return boolean
function Platform.Has(key)
    return Platform.has[key] == true
end

-- Print the client and capability table to chat (/h platform).
function Platform.Print()
    local out = addon.HSPrint or print
    out(("Platform: %s (interface %d, build %d, project %s)"):format(
        Platform.name, Platform.interfaceVersion, Platform.buildNumber, tostring(Platform.projectID)))
    local keys = {}
    for key in pairs(Platform.has) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
        local state = Platform.has[key] and "|cFF00FF00yes|r" or "|cFFFF4444no|r"
        local note = Platform.unverified[key] and "  (unverified on Forever)" or ""
        out(("  %-16s %s%s"):format(key, state, note))
    end
    -- Module state: saved (what the DB says) against running (what actually started).
    -- A saved=yes / running=no pair means the module threw while starting; the
    -- error is kept on the module record and printed at load.
    local db = _G[addon.DATABASE]
    local moduleKeys = {}
    for key in pairs(addon.modules or {}) do moduleKeys[#moduleKeys + 1] = key end
    table.sort(moduleKeys)
    local charKey = addon._GetCurrentCharacterProfileKey and addon._GetCurrentCharacterProfileKey()
    local activeKey = addon.GetActiveProfileKey and addon.GetActiveProfileKey()
    local profileKeys = {}
    if db and type(db.profiles) == "table" then
        for k in pairs(db.profiles) do profileKeys[#profileKeys + 1] = tostring(k) end
        table.sort(profileKeys)
    end
    out(("Profile: character=%s active=%s; saved profiles: %s"):format(
        tostring(charKey), tostring(activeKey), #profileKeys > 0 and table.concat(profileKeys, ", ") or "none"))
    local restored = addon._dbRestoredFromDisk
    local dbState = restored == true and "restored from disk"
        or restored == false and "|cFFFF4444NOT restored: the client handed back no SavedVariables|r"
        or "unknown"
    out(("Modules (saved / running), HorizonDB %s:"):format(dbState))
    for _, key in ipairs(moduleKeys) do
        local saved = db and db.modules and db.modules[key] and db.modules[key].enabled
        local m = addon.modules[key]
        local savedText = saved == nil and "unset" or (saved and "yes" or "no")
        local runText = m.enabled and "|cFF00FF00yes|r" or "|cFFFF4444no|r"
        local errText = m.enableError and ("  error: " .. m.enableError) or ""
        out(("  %-10s %-6s %s%s"):format(key, savedText, runText, errText))
    end
end

-- ---------------------------------------------------------------------------
-- Live probes (/h platform probe): ask each system what it actually returns on
-- this client, so "unverified" capabilities can be settled from one paste.
-- Every probe is pcall-wrapped; a thrown error is itself a useful answer.
-- ---------------------------------------------------------------------------

local function CountKeys(t)
    if type(t) ~= "table" then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local PROBES = {
    { "client", function()
        local level = UnitLevel and UnitLevel("player") or "?"
        local cap = GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or "?"
        local exp = GetExpansionLevel and GetExpansionLevel() or "?"
        local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        local mapName = mapID and C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name or "?"
        return ("level %s / cap %s, expansion %s, map %s (%s)"):format(level, cap, exp, tostring(mapID), mapName)
    end },
    { "secrets", function()
        local auras = C_Secrets and C_Secrets.ShouldAurasBeSecret and tostring(C_Secrets.ShouldAurasBeSecret()) or "n/a"
        return ("ShouldAurasBeSecret=%s, issecretvalue=%s"):format(auras, type(issecretvalue))
    end },
    { "achievements", function()
        local cats = GetCategoryList and GetCategoryList() or {}
        local total, completed = 0, 0
        if GetNumCompletedAchievements then total, completed = GetNumCompletedAchievements() end
        local tracked = GetTrackedAchievements and select("#", GetTrackedAchievements()) or 0
        return ("%d categories, %s/%s completed, %d tracked"):format(#cats, tostring(completed), tostring(total), tracked)
    end },
    { "adventureGuide", function()
        local info = C_PerksActivities.GetPerksActivitiesInfo()
        local n = info and info.activities and #info.activities or 0
        return ("Traveler's Log: %d activities"):format(n)
    end },
    { "contentTracking", function()
        local T = Enum.ContentTrackingType
        local app = T and T.Appearance and #C_ContentTracking.GetTrackedIDs(T.Appearance) or -1
        local ach = T and T.Achievement and #C_ContentTracking.GetTrackedIDs(T.Achievement) or -1
        return ("tracked appearances=%d achievements=%d (-1 = enum missing)"):format(app, ach)
    end },
    { "professions", function()
        local names = {}
        if GetProfessions and GetProfessionInfo then
            local idx = { GetProfessions() }
            for i = 1, 5 do
                if idx[i] then names[#names + 1] = (GetProfessionInfo(idx[i])) or "?" end
            end
        end
        local lines = C_TradeSkillUI.GetAllProfessionTradeSkillLines and #C_TradeSkillUI.GetAllProfessionTradeSkillLines() or -1
        return ("known: %s; %d tradeskill lines; GetRecipeSchematic=%s"):format(
            #names > 0 and table.concat(names, ", ") or "none", lines, type(C_TradeSkillUI.GetRecipeSchematic))
    end },
    { "scenarios", function()
        local info = C_ScenarioInfo and C_ScenarioInfo.GetScenarioInfo and C_ScenarioInfo.GetScenarioInfo()
        return ("GetScenarioInfo=%s, in scenario now: %s"):format(
            type(C_ScenarioInfo and C_ScenarioInfo.GetScenarioInfo), info and (info.name or "yes") or "no")
    end },
    { "transmog", function()
        local T = Enum.TransmogCollectionType
        local total = T and T.Head and C_TransmogCollection.GetCategoryTotal(T.Head) or -1
        local got = T and T.Head and C_TransmogCollection.GetCategoryCollectedCount(T.Head) or -1
        return ("head appearances %d/%d, PlayerHasTransmogByItemInfo=%s"):format(
            got, total, type(C_TransmogCollection.PlayerHasTransmogByItemInfo))
    end },
    { "worldQuests", function()
        local mapID = C_Map.GetBestMapForUnit("player")
        local onMap = mapID and C_TaskQuest.GetQuestsOnMap and C_TaskQuest.GetQuestsOnMap(mapID)
        local entries = C_QuestLog.GetNumQuestLogEntries and select(1, C_QuestLog.GetNumQuestLogEntries()) or -1
        return ("task quests on map: %s, quest log entries: %d, IsWorldQuest=%s, GetQuestClassification=%s"):format(
            onMap and #onMap or "nil", entries, type(C_QuestLog.IsWorldQuest),
            type(C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification))
    end },
    -- Group loot. Namespace presence is already in the capability table; what
    -- this probe adds is whether the client has anything to SAY. On a client
    -- with no group loot the globals still answer (that is the whole reason
    -- Platform exists) — but rolls in progress and encounter count stay at 0
    -- forever, including immediately after a dungeon boss dies. Run it once
    -- standing over a fresh group-loot corpse on each client.
    { "groupLootRolls", function()
        -- Roll IDs are server-assigned and increment across the session, so
        -- they cannot be guessed. Blizzard's own frames carry the live ones.
        local open = 0
        for i = 1, 4 do
            local frame = _G["GroupLootFrame" .. i]
            if frame and frame.rollID and frame:IsShown() then open = open + 1 end
        end
        local horizon = 0
        local R = addon.Augment and addon.Augment.Roll
        if R and R.HasActiveRows and R.HasActiveRows() then horizon = 1 end
        -- Distinguish "no such function" from "the function answered nil". On a
        -- client being probed for a system it may not have, those mean opposite
        -- things, and collapsing both into "?" throws the answer away.
        local function Ask(fn)
            if type(fn) ~= "function" then return "ABSENT" end
            local ok, value = pcall(fn)
            if not ok then return "threw" end
            if value == nil then return "nil" end
            return tostring(value)
        end

        -- The loot method, via C_PartyInfo. The bare GetLootMethod global was
        -- removed in 11.2.0, so asking for it reports ABSENT on Retail and
        -- Forever alike and says nothing about either — a probe that answers
        -- the same on a client with the system and one without is not a probe.
        local method = "ABSENT"
        if C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
            local ok, value = pcall(C_PartyInfo.GetLootMethod)
            if not ok then
                method = "threw"
            elseif value == nil then
                method = "nil"
            else
                method = tostring(value)
                for name, enumValue in pairs((Enum and Enum.LootMethod) or {}) do
                    if enumValue == value then method = ("%s (%s)"):format(name, value) end
                end
            end
        end

        -- Which loot methods this client's enum even knows about. Group and
        -- Needbeforegreed are the two that produce Need/Greed rolls; a client
        -- with neither cannot roll, whatever the roll functions claim.
        local methods = {}
        for name in pairs((Enum and Enum.LootMethod) or {}) do methods[#methods + 1] = name end
        table.sort(methods)

        local grouped = (IsInGroup and IsInGroup()) and "yes" or "no"
        return ("RollOnLoot=%s GetLootRollItemInfo=%s, method=%s, threshold=%s, grouped=%s, frames open=%d, Horizon drawing=%s\n                   LootMethod enum: %s"):format(
            type(RollOnLoot), type(GetLootRollItemInfo),
            method, Ask(GetLootThreshold), grouped,
            open, horizon == 1 and "yes" or "no",
            #methods > 0 and table.concat(methods, ", ") or "|cFFFF4444MISSING|r")
    end },
    { "lootHistory", function()
        local infos = C_LootHistory.GetAllEncounterInfos and C_LootHistory.GetAllEncounterInfos() or {}
        local drops, unfinished = 0, 0
        for _, info in ipairs(infos) do
            local list = C_LootHistory.GetSortedDropsForEncounter and
                C_LootHistory.GetSortedDropsForEncounter(info.encounterID) or {}
            drops = drops + #list
            for _, drop in ipairs(list) do
                if not (drop.winner or drop.allPassed) then unfinished = unfinished + 1 end
            end
        end
        return ("%d encounters, %d drops (%d still rolling), RollState enum=%s"):format(
            #infos, drops, unfinished,
            (Enum and Enum.EncounterLootDropRollState) and "present" or "MISSING")
    end },
    { "reputation", function()
        local n = C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetNumFactions() or -1
        return ("%d factions, C_MajorFactions=%s"):format(n, type(C_MajorFactions))
    end },
    -- Baseline confirmations for systems marked absent on Forever.
    { "mythicPlus", function()
        local maps = C_ChallengeMode.GetMapTable and C_ChallengeMode.GetMapTable() or {}
        return ("%d keystone maps"):format(#maps)
    end },
    { "specs", function()
        return ("GetNumSpecializations=%s, GetSpecialization=%s, PlayerUtil.GetCurrentSpecID=%s"):format(
            type(GetNumSpecializations), type(GetSpecialization),
            type(PlayerUtil and PlayerUtil.GetCurrentSpecID))
    end },
    { "weeklyVault", function()
        return ("CanClaimRewards=%s"):format(C_WeeklyRewards.CanClaimRewards and tostring(C_WeeklyRewards.CanClaimRewards()) or "n/a")
    end },
    { "delves/housing", function()
        return ("C_DelvesUI keys=%d, C_HousingDecor keys=%d, C_Endeavors keys=%d"):format(
            CountKeys(C_DelvesUI), CountKeys(C_HousingDecor), CountKeys(C_Endeavors))
    end },
}

-- Run every probe and print one line each (/h platform probe).
function Platform.Probe()
    local out = addon.HSPrint or print
    out(("Platform probe on %s (interface %d):"):format(Platform.name, Platform.interfaceVersion))
    for _, probe in ipairs(PROBES) do
        local ok, result = pcall(probe[2])
        local text = ok and tostring(result) or ("|cFFFF4444error:|r " .. tostring(result))
        out(("  %-16s %s"):format(probe[1], text))
    end
end
