--[[
    Horizon Suite - Focus - Achievement / Instance matching (experimental probe)

    Feasibility probe for an "achievements for this instance only" filter, the
    achievement counterpart of the Current Zone filter for quests.

    The client data has Achievement.Instance_ID, but no Lua API exposes it, so this
    infers the link from what the API does expose. Signals, strongest first:
      encounter  a criterion of type 97/165 (Defeat Encounter) whose assetID is one
                 of the instance's DungeonEncounter IDs from the Encounter Journal
      name       the instance name appears in the achievement title or description
      boss       a criterion's text is one of the instance's boss/creature names, or
                 a boss name appears as whole words in the description
      category   an ancestor achievement category carries the instance name

    Not wired into the tracker. Driven by /h debug focus achinstdebug [scan].
]]

local addon = _G.HorizonSuite
if not addon then return end

local AI = {}
addon.AchievementInstance = AI

-- CriteriaType values whose assetID is a DungeonEncounter ID
-- (DefeatDungeonEncounterWhileElegibleForLoot = 97, DefeatDungeonEncounter = 165).
local ENCOUNTER_CRITERIA_TYPES = { [97] = true, [165] = true }
local CRITERIA_TYPE_ACHIEVEMENT = 8
local DUNGEONS_AND_RAIDS_CATEGORY = 168
-- Boss names shorter than this are too likely to appear inside unrelated text.
local MIN_BOSS_NAME_LEN = 4
local MAX_ENCOUNTERS = 60
local MAX_CREATURES = 9
local SCAN_BATCH = 20

-- ============================================================================
-- Text helpers
-- ============================================================================

-- Lowercase, strip colour codes and punctuation, collapse spaces. A leading "the" is
-- dropped only when two or more words remain, so "The Eye" stays "the eye" and does
-- not match every "eye" in other text.
local function Normalize(s)
    if type(s) ~= "string" or s == "" then return nil end
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower()
    s = s:gsub("%p", "")
    s = s:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
    local rest = s:match("^the (.+)$")
    if rest and rest:find(" ", 1, true) then s = rest end
    if s == "" then return nil end
    return s
end
AI.Normalize = Normalize

-- Whole-word containment on normalized text.
local function ContainsWords(haystack, needle)
    if not haystack or not needle then return false end
    return (" " .. haystack .. " "):find(" " .. needle .. " ", 1, true) ~= nil
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

-- ============================================================================
-- Encounter Journal index
-- ============================================================================

local instanceIndex = nil  -- { list = { inst... }, byJournalID = {}, byMapID = {} }

-- Journal pages for world bosses ("Pandaria", "Draenor", "Midnight") sit in the raid
-- list but point at a continent map; they are not instances.
local function IsWorldBossPage(journalID)
    local ok, _, _, _, _, _, _, dungeonAreaMapID = SafeCall(EJ_GetInstanceInfo, journalID)
    if not ok or type(dungeonAreaMapID) ~= "number" or dungeonAreaMapID <= 0 then return false end
    if not (C_Map and C_Map.GetMapInfo) then return false end
    local mOk, info = pcall(C_Map.GetMapInfo, dungeonAreaMapID)
    if not mOk or not info or type(info.mapType) ~= "number" then return false end
    local continent = (Enum and Enum.UIMapType and Enum.UIMapType.Continent) or 2
    return info.mapType <= continent
end

local function BuildInstanceRecord(journalID, name, isRaid)
    local inst = {
        journalID    = journalID,
        name         = name,
        norm         = Normalize(name),
        aliases      = {},
        isRaid       = isRaid and true or false,
        mapID        = nil,
        encounterIDs = {},
        bossNames    = {},  -- norm -> display name
        numBosses    = 0,
    }
    if inst.norm then inst.aliases[#inst.aliases + 1] = inst.norm end
    -- "Stratholme - Main Gate" is still "Stratholme" in older achievement text.
    local base = type(name) == "string" and name:match("^(.-)%s+[-:]%s+")
    local baseNorm = Normalize(base)
    if baseNorm and baseNorm ~= inst.norm then inst.aliases[#inst.aliases + 1] = baseNorm end

    -- EJ_GetEncounterInfoByIndex reads the selected instance even when given an ID.
    SafeCall(EJ_SelectInstance, journalID)
    for i = 1, MAX_ENCOUNTERS do
        local ok, encName, _, journalEncounterID, _, _, _, dungeonEncounterID, mapID =
            SafeCall(EJ_GetEncounterInfoByIndex, i, journalID)
        if not ok or not encName then break end
        inst.numBosses = inst.numBosses + 1
        if type(dungeonEncounterID) == "number" and dungeonEncounterID > 0 then
            inst.encounterIDs[dungeonEncounterID] = encName
        end
        if type(mapID) == "number" and mapID > 0 then inst.mapID = inst.mapID or mapID end
        local n = Normalize(encName)
        if n and #n >= MIN_BOSS_NAME_LEN then inst.bossNames[n] = encName end
        if journalEncounterID then
            for c = 1, MAX_CREATURES do
                local cOk, _, creatureName = SafeCall(EJ_GetCreatureInfo, c, journalEncounterID)
                if not cOk or not creatureName then break end
                local cn = Normalize(creatureName)
                if cn and #cn >= MIN_BOSS_NAME_LEN then inst.bossNames[cn] = creatureName end
            end
        end
    end
    return inst
end

-- Walks every Encounter Journal tier once and caches the result for the session.
-- Restores the journal's selected tier afterwards so an open Adventure Guide keeps its view.
function AI.GetInstanceIndex()
    if instanceIndex then return instanceIndex end
    local idx = { list = {}, byJournalID = {}, byMapID = {} }
    if C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_EncounterJournal")
    end
    if type(EJ_GetNumTiers) ~= "function" or type(EJ_SelectTier) ~= "function"
        or type(EJ_GetInstanceByIndex) ~= "function" then
        instanceIndex = idx
        return idx
    end
    idx.numEncounters, idx.numBossNames, idx.skipped = 0, 0, {}
    local _, savedTier = SafeCall(EJ_GetCurrentTier)
    local _, numTiers = SafeCall(EJ_GetNumTiers)
    for tier = 1, (tonumber(numTiers) or 0) do
        SafeCall(EJ_SelectTier, tier)
        for _, isRaid in ipairs({ false, true }) do
            for i = 1, 200 do
                local ok, journalID, name = SafeCall(EJ_GetInstanceByIndex, i, isRaid)
                if not ok or not journalID then break end
                if not idx.byJournalID[journalID] and not idx.skipped[journalID] then
                    if isRaid and IsWorldBossPage(journalID) then
                        idx.skipped[journalID] = name or true
                    else
                        local inst = BuildInstanceRecord(journalID, name, isRaid)
                        inst.tier = tier
                        idx.list[#idx.list + 1] = inst
                        idx.byJournalID[journalID] = inst
                        if inst.mapID then idx.byMapID[inst.mapID] = inst end
                        idx.numEncounters = idx.numEncounters + inst.numBosses
                        for _ in pairs(inst.bossNames) do idx.numBossNames = idx.numBossNames + 1 end
                    end
                end
            end
        end
    end
    if savedTier then SafeCall(EJ_SelectTier, savedTier) end
    instanceIndex = idx
    return idx
end

function AI.ResetIndex()
    instanceIndex = nil
end

-- Returns the instance record for where the player stands, or nil plus a reason.
function AI.GetCurrentInstance()
    local ok, name, instanceType, _, difficultyName, _, _, _, mapID = SafeCall(GetInstanceInfo)
    if not ok then return nil, "GetInstanceInfo unavailable" end
    if not instanceType or instanceType == "none" then return nil, "not in an instance" end
    local idx = AI.GetInstanceIndex()
    local inst
    if C_Map and C_Map.GetBestMapForUnit and type(EJ_GetInstanceForMap) == "function" then
        local mOk, uiMapID = pcall(C_Map.GetBestMapForUnit, "player")
        if mOk and uiMapID then
            local jOk, journalID = pcall(EJ_GetInstanceForMap, uiMapID)
            if jOk and journalID and journalID > 0 then inst = idx.byJournalID[journalID] end
        end
    end
    if not inst and mapID then inst = idx.byMapID[mapID] end
    if not inst then
        local n = Normalize(name)
        for _, cand in ipairs(idx.list) do
            if cand.norm and cand.norm == n then inst = cand; break end
        end
    end
    if not inst then
        return nil, ("in %s (%s, map %s) but no Encounter Journal entry found"):format(
            tostring(name), tostring(instanceType), tostring(mapID))
    end
    return inst, nil, { name = name, instanceType = instanceType, difficultyName = difficultyName, mapID = mapID }
end

-- ============================================================================
-- Achievement facts
-- ============================================================================

local categoryCache = {}

local function GetCategoryChain(categoryID)
    local chain = {}
    local guard = 0
    while categoryID and categoryID > 0 and guard < 10 do
        guard = guard + 1
        local cached = categoryCache[categoryID]
        if not cached then
            local ok, title, parentID = SafeCall(GetCategoryInfo, categoryID)
            cached = { title = ok and title or nil, norm = ok and Normalize(title) or nil, parentID = ok and parentID or -1 }
            categoryCache[categoryID] = cached
        end
        chain[#chain + 1] = { id = categoryID, title = cached.title, norm = cached.norm }
        categoryID = cached.parentID
    end
    return chain
end

-- Everything the matcher needs about one achievement, read once.
function AI.GetAchievementFacts(achievementID)
    local ok, _, title, _, completed, _, _, _, description = SafeCall(GetAchievementInfo, achievementID)
    if not ok or not title then return nil end
    local facts = {
        id          = achievementID,
        title       = title,
        completed   = completed and true or false,
        titleNorm   = Normalize(title),
        descNorm    = Normalize(description),
        criteria    = {},
        categories  = {},
    }
    local nOk, num = SafeCall(GetAchievementNumCriteria, achievementID)
    for i = 1, ((nOk and tonumber(num)) or 0) do
        local cOk, text, criteriaType, _, _, _, _, _, assetID = SafeCall(GetAchievementCriteriaInfo, achievementID, i)
        if cOk then
            facts.criteria[#facts.criteria + 1] = {
                text = text, norm = Normalize(text), type = criteriaType, assetID = assetID,
            }
        end
    end
    local catOk, categoryID = SafeCall(GetAchievementCategory, achievementID)
    if catOk and categoryID then facts.categories = GetCategoryChain(categoryID) end
    return facts
end

-- ============================================================================
-- Matching
-- ============================================================================

-- Returns nil when nothing links facts to inst, else { encounter=, name=, boss=, category=, detail = { ... } }.
function AI.Match(facts, inst)
    if not facts or not inst then return nil end
    local hit = { detail = {} }
    local any = false

    for _, c in ipairs(facts.criteria) do
        if ENCOUNTER_CRITERIA_TYPES[c.type] and c.assetID and inst.encounterIDs[c.assetID] then
            hit.encounter = true; any = true
            hit.detail[#hit.detail + 1] = "encounter " .. tostring(c.assetID) .. " (" .. inst.encounterIDs[c.assetID] .. ")"
            break
        end
    end

    for _, alias in ipairs(inst.aliases or {}) do
        if ContainsWords(facts.titleNorm, alias) or ContainsWords(facts.descNorm, alias) then
            hit.name = true; any = true
            hit.nameNorm = alias
            hit.detail[#hit.detail + 1] = "name \"" .. alias .. "\""
            break
        end
    end

    for _, c in ipairs(facts.criteria) do
        if c.norm and c.type ~= CRITERIA_TYPE_ACHIEVEMENT and inst.bossNames[c.norm] then
            hit.boss = true; any = true
            hit.detail[#hit.detail + 1] = "criterion \"" .. tostring(c.text) .. "\""
            break
        end
    end
    if not hit.boss and facts.descNorm then
        for bossNorm, bossName in pairs(inst.bossNames) do
            if ContainsWords(facts.descNorm, bossNorm) then
                hit.boss = true; any = true
                hit.detail[#hit.detail + 1] = "boss in description \"" .. bossName .. "\""
                break
            end
        end
    end

    if inst.norm then
        for _, cat in ipairs(facts.categories) do
            if cat.norm and cat.norm == inst.norm then
                hit.category = true; any = true
                hit.detail[#hit.detail + 1] = "category \"" .. tostring(cat.title) .. "\""
                break
            end
        end
    end

    if not any then return nil end
    return hit
end

local SIGNALS = { "encounter", "name", "boss", "category" }

-- All instances an achievement links to: list of { inst = , hit = , journalIDs = set }.
-- Journal entries sharing a name count once, and a name-only match is dropped when a
-- longer matched name contains it ("karazhan" inside "return to karazhan").
function AI.FindInstances(facts)
    local out = {}
    if not facts then return out end
    local byNorm = {}
    for _, inst in ipairs(AI.GetInstanceIndex().list) do
        local hit = AI.Match(facts, inst)
        if hit then
            local key = inst.norm or tostring(inst.journalID)
            local m = byNorm[key]
            if m then
                m.journalIDs[inst.journalID] = true
                for _, k in ipairs(SIGNALS) do
                    if hit[k] and not m.hit[k] then
                        m.hit[k] = true
                        for _, d in ipairs(hit.detail) do m.hit.detail[#m.hit.detail + 1] = d end
                    end
                end
                m.hit.nameNorm = m.hit.nameNorm or hit.nameNorm
            else
                m = { inst = inst, hit = hit, journalIDs = { [inst.journalID] = true } }
                byNorm[key] = m
                out[#out + 1] = m
            end
        end
    end
    if #out < 2 then return out end
    local text = (facts.titleNorm or "") .. " | " .. (facts.descNorm or "")
    local kept = {}
    for _, m in ipairs(out) do
        local h = m.hit
        local nameOnly = h.name and not h.encounter and not h.boss and not h.category
        local shadowed = false
        if nameOnly and h.nameNorm then
            -- Blank out every longer matched name (and a "the" in front of it), then see
            -- whether this name still appears anywhere on its own.
            local rest = " " .. text .. " "
            for _, other in ipairs(out) do
                local on = other.hit.nameNorm
                if other ~= m and on and #on > #h.nameNorm then
                    rest = rest:gsub(" the " .. on:gsub("%p", "%%%0") .. " ", " # ")
                    rest = rest:gsub(" " .. on:gsub("%p", "%%%0") .. " ", " # ")
                end
            end
            shadowed = not rest:find(" " .. h.nameNorm .. " ", 1, true)
        end
        if not shadowed then kept[#kept + 1] = m end
    end
    return kept
end

local function SignalList(hit)
    local s = {}
    for _, k in ipairs(SIGNALS) do
        if hit[k] then s[#s + 1] = k end
    end
    return table.concat(s, "+")
end

-- ============================================================================
-- Reports (lines of plain text)
-- ============================================================================

function AI.IndexSummary(idx)
    local skipped = 0
    for _ in pairs(idx.skipped or {}) do skipped = skipped + 1 end
    return ("Encounter Journal: %d instances, %d encounters, %d boss names (%d world-boss pages skipped)"):format(
        #idx.list, idx.numEncounters or 0, idx.numBossNames or 0, skipped)
end

local function GetTrackedAchievementIDs()
    local ids = {}
    local trackingType = (Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement) or 2
    if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
        local ok, list = pcall(C_ContentTracking.GetTrackedIDs, trackingType)
        if ok and type(list) == "table" then
            for _, id in ipairs(list) do
                if type(id) == "number" and id > 0 then ids[#ids + 1] = id end
            end
        end
    elseif GetTrackedAchievements then
        local list = { GetTrackedAchievements() }
        for _, id in ipairs(list) do
            if type(id) == "number" and id > 0 then ids[#ids + 1] = id end
        end
    end
    return ids
end
AI.GetTrackedAchievementIDs = GetTrackedAchievementIDs

-- Tracked achievements: which instances each links to, and whether an instance
-- filter would keep it where the player stands now.
function AI.TrackedReport(trackedIDs)
    local lines = {}
    local idx = AI.GetInstanceIndex()
    lines[#lines + 1] = AI.IndexSummary(idx)
    local current, reason, info = AI.GetCurrentInstance()
    if current then
        lines[#lines + 1] = ("Current instance: %s (journal %s, map %s, %s, %d bosses)"):format(
            tostring(current.name), tostring(current.journalID), tostring(info and info.mapID),
            tostring(info and info.difficultyName), current.numBosses)
    else
        lines[#lines + 1] = "Current instance: none (" .. tostring(reason) .. ")"
    end
    local ids = trackedIDs or GetTrackedAchievementIDs()
    if #ids == 0 then
        lines[#lines + 1] = "No tracked achievements. Track a few and run this again."
        return lines
    end
    for _, achID in ipairs(ids) do
        local facts = AI.GetAchievementFacts(achID)
        if not facts then
            lines[#lines + 1] = ("[%d] unreadable"):format(achID)
        else
            local matches = AI.FindInstances(facts)
            local verdict = ""
            if current then
                local keep = false
                for _, m in ipairs(matches) do
                    if m.journalIDs[current.journalID] then keep = true; break end
                end
                verdict = keep and "  -> SHOW here" or "  -> HIDE here"
            end
            lines[#lines + 1] = ("[%d] %s%s"):format(achID, facts.title, verdict)
            if #matches == 0 then
                lines[#lines + 1] = "    no instance link found"
            else
                for i, m in ipairs(matches) do
                    if i > 6 then
                        lines[#lines + 1] = ("    ... %d more"):format(#matches - 6)
                        break
                    end
                    lines[#lines + 1] = ("    %s [%s] %s"):format(m.inst.name, SignalList(m.hit), table.concat(m.hit.detail, "; "))
                end
            end
        end
    end
    return lines
end

-- Achievement IDs in every category under Dungeons & Raids.
function AI.CollectDungeonRaidAchievementIDs()
    local ids = {}
    local ok, cats = SafeCall(GetCategoryList)
    if not ok or type(cats) ~= "table" then return ids end
    local seen = {}
    for _, catID in ipairs(cats) do
        local inTree = false
        for _, node in ipairs(GetCategoryChain(catID)) do
            if node.id == DUNGEONS_AND_RAIDS_CATEGORY then inTree = true; break end
        end
        if inTree then
            local nOk, num = SafeCall(GetCategoryNumAchievements, catID, true)
            for i = 1, ((nOk and tonumber(num)) or 0) do
                local aOk, achID = SafeCall(GetAchievementInfo, catID, i)
                if aOk and achID and not seen[achID] then
                    seen[achID] = true
                    ids[#ids + 1] = achID
                end
            end
        end
    end
    return ids
end

local function ScanSummary(results)
    local lines = {}
    local total, one, multi, none = #results, 0, 0, 0
    local bySignal = { encounter = 0, name = 0, boss = 0, category = 0 }
    local onlyWeak = 0
    local unmatched, ambiguous = {}, {}
    for _, r in ipairs(results) do
        local n = #r.matches
        if n == 0 then
            none = none + 1
            unmatched[#unmatched + 1] = r
        elseif n == 1 then
            one = one + 1
        else
            multi = multi + 1
            ambiguous[#ambiguous + 1] = r
        end
        local seenSignal = {}
        for _, m in ipairs(r.matches) do
            for k in pairs(bySignal) do
                if m.hit[k] then seenSignal[k] = true end
            end
        end
        for k in pairs(seenSignal) do bySignal[k] = bySignal[k] + 1 end
        if n > 0 and not seenSignal.encounter and not seenSignal.name then onlyWeak = onlyWeak + 1 end
    end
    local function pct(x) return total > 0 and math.floor(100 * x / total + 0.5) or 0 end
    lines[#lines + 1] = ("Scanned %d Dungeons & Raids achievements"):format(total)
    lines[#lines + 1] = ("  one instance:  %d (%d%%)"):format(one, pct(one))
    lines[#lines + 1] = ("  several:       %d (%d%%)"):format(multi, pct(multi))
    lines[#lines + 1] = ("  no link:       %d (%d%%)"):format(none, pct(none))
    lines[#lines + 1] = ("  by signal: encounter %d, name %d, boss %d, category %d; boss/category only %d"):format(
        bySignal.encounter, bySignal.name, bySignal.boss, bySignal.category, onlyWeak)
    lines[#lines + 1] = "No link (first 40):"
    for i = 1, math.min(40, #unmatched) do
        lines[#lines + 1] = ("  [%d] %s"):format(unmatched[i].id, unmatched[i].title)
    end
    lines[#lines + 1] = "Several instances (first 25):"
    for i = 1, math.min(25, #ambiguous) do
        local names = {}
        for j, m in ipairs(ambiguous[i].matches) do
            if j > 4 then names[#names + 1] = "..."; break end
            names[#names + 1] = m.inst.name .. " [" .. SignalList(m.hit) .. "]"
        end
        lines[#lines + 1] = ("  [%d] %s: %s"):format(ambiguous[i].id, ambiguous[i].title, table.concat(names, ", "))
    end
    return lines
end
AI.ScanSummary = ScanSummary

-- Matches every Dungeons & Raids achievement against every instance, a batch per frame,
-- then calls onDone(lines). Run anywhere; no need to be inside an instance.
function AI.RunScan(onDone, onProgress)
    local idx = AI.GetInstanceIndex()
    local ids = AI.CollectDungeonRaidAchievementIDs()
    local results = {}
    local pos = 1
    local function step()
        local stop = math.min(#ids, pos + SCAN_BATCH - 1)
        for i = pos, stop do
            local facts = AI.GetAchievementFacts(ids[i])
            if facts then
                results[#results + 1] = { id = facts.id, title = facts.title, matches = AI.FindInstances(facts) }
            end
        end
        pos = stop + 1
        if pos <= #ids then
            if onProgress then onProgress(pos - 1, #ids) end
            C_Timer.After(0, step)
        else
            local lines = { AI.IndexSummary(idx) }
            for _, l in ipairs(ScanSummary(results)) do lines[#lines + 1] = l end
            onDone(lines, results)
        end
    end
    step()
end
