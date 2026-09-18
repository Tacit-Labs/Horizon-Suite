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
    adventureGuide  = C_AdventureGuide ~= nil or C_EncounterJournal ~= nil,
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
