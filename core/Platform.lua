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
}

-- Systems Forever exposes through the API whose content has not been verified on
-- the beta. They default to present; the in-game spike settles each one.
Platform.unverified = {
    worldQuests     = true,
    scenarios       = true,
    achievements    = true,
    transmog        = true,
    professions     = true,
    adventureGuide  = true,
    contentTracking = true,
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
