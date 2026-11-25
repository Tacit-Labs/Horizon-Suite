--[[
    Horizon Suite - Augment / Loot Roll - Tally
    Turns C_LootHistory into a per-roll summary: how many people needed, greeded
    or passed, who is currently leading, and who won.

    THE JOIN PROBLEM. Loot history carries no rollID. EncounterLootDropInfo has
    lootListID, itemHyperlink, rollInfos, currentLeader, isTied, winner,
    allPassed, startTime and duration — and nothing that names the roll our
    frame is showing. Blizzard never needs the join: its roll frame
    (GroupLootFrame.lua) and its history window (LootHistory.lua) are separate
    surfaces that never talk to each other. We need it because we are putting
    history data onto the roll frame.

    The only key available is the item link. That is ambiguous when two rolls
    run at once for the identical link (two copies of one token off a boss).
    PairCopies handles that case: the history numbers a boss's drops in the
    order they dropped, and the rolls start in that same order, so the oldest
    open roll takes the lowest unclaimed drop key. It still FAILS CLOSED when
    the counts disagree (a copy already finished, one not yet in history):
    a missing tally costs one line, a tally naming the wrong winner would be
    believed. FindMisPair then checks the guess against the one thing we know
    for certain, which copy YOU pressed a button on, and asks for a swap when
    the history recorded your choice on the other one.

    SECRET VALUES. Every field read from C_LootHistory goes through Plain():
    under the client's restrictions a field can come back secret, and testing
    or comparing a secret value throws.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local R = addon.Augment.Roll
R.Tally = R.Tally or {}
local T = R.Tally

-- Seconds of slack allowed around a drop's own startTime+duration window when
-- deciding whether it could be the roll on screen. Server and client clocks
-- agree closely here (both come from GetLootHistoryTime), so this only absorbs
-- the gap between START_LOOT_ROLL arriving and the drop appearing in history.
local WINDOW_SLACK = 5

local function Has(capability)
    return addon.Platform and addon.Platform.Has(capability)
end

--- A loot-history field as a plain Lua value, or nil when it is secret or not
--- of the expected type.
--- @param v any
--- @param kind string|nil  Lua type name; nil accepts any non-secret value
--- @return any
local function Plain(v, kind)
    local secret = _G.issecretvalue
    if secret and secret(v) then return nil end
    if kind == nil or type(v) == kind then return v end
    return nil
end
T.Plain = Plain

--- A drop's list key. Retail names it lootListID; WoW: Forever's addons read
--- lootListKey. Either one, whichever this client fills in.
--- @param drop table|nil  EncounterLootDropInfo
--- @return number|nil
function T.DropKey(drop)
    if type(drop) ~= "table" then return nil end
    return Plain(drop.lootListID, "number") or Plain(drop.lootListKey, "number")
end

-- ============================================================================
-- ROLL STATES
-- Enum.EncounterLootDropRollState: NeedMainSpec 0, NeedOffSpec 1, Transmog 2,
-- Greed 3, NoRoll 4, Pass 5. Read defensively — this is exactly the kind of
-- enum a client can ship without the system behind it.
-- ============================================================================

local function State(name)
    local E = Enum and Enum.EncounterLootDropRollState
    return E and E[name] or nil
end

--- Bucket a raw roll state into what the frame actually renders.
--- Main-spec and off-spec Need collapse into one bucket where the client has no
--- specialisations: Forever reports Platform.has.specs == false, and an
--- "off-spec" label on a client with no off-spec is noise, not information.
--- @param state number|nil Enum.EncounterLootDropRollState
--- @return string|nil "need"|"needOff"|"transmog"|"greed"|"pass"|"waiting"
function T.BucketForState(state)
    if state == nil then return nil end
    if state == State("NeedMainSpec") then return "need" end
    if state == State("NeedOffSpec") then
        return Has("specs") and "needOff" or "need"
    end
    if state == State("Transmog") then return "transmog" end
    if state == State("Greed")    then return "greed" end
    if state == State("Pass")     then return "pass" end
    if state == State("NoRoll")   then return "waiting" end
    return nil
end

-- ============================================================================
-- DROP RESOLUTION
-- ============================================================================

local function IsUnfinished(drop)
    -- Same filter Blizzard uses in LootHistory.lua to decide a roll is still
    -- running: no winner recorded and not everyone passed.
    return Plain(drop.winner, "table") == nil and Plain(drop.allPassed, "boolean") ~= true
end

local function InWindow(drop, now)
    local start = Plain(drop.startTime, "number")
    if not now or not start then return true end
    local elapsed = now - start
    if elapsed < -WINDOW_SLACK then return false end
    local duration = Plain(drop.duration, "number") or 0
    if duration <= 0 then return true end
    return elapsed <= (duration + WINDOW_SLACK)
end

--- Every unfinished history drop that could be the roll for this link, lowest
--- drop key first (the order the boss dropped them). Drops with no readable
--- key keep the order history gave them, after the keyed ones.
--- @param itemLink string|nil From GetLootRollItemLink(rollID)
--- @return table list  Array of { drop, encounterID, key }
function T.Candidates(itemLink)
    if not itemLink or itemLink == "" then return {} end
    if not Has("lootHistory") then return {} end

    local ok, found = pcall(function()
        local now = C_LootHistory.GetLootHistoryTime and Plain(C_LootHistory.GetLootHistoryTime(), "number") or nil
        local out = {}
        for _, encounter in ipairs(C_LootHistory.GetAllEncounterInfos() or {}) do
            local encounterID = Plain(encounter.encounterID, "number")
            local drops = encounterID and C_LootHistory.GetSortedDropsForEncounter(encounterID) or {}
            for _, drop in ipairs(drops) do
                if Plain(drop.itemHyperlink, "string") == itemLink and IsUnfinished(drop) and InWindow(drop, now) then
                    out[#out + 1] = { drop = drop, encounterID = encounterID, key = T.DropKey(drop), seq = #out }
                end
            end
        end
        table.sort(out, function(a, b)
            if a.key and b.key and a.key ~= b.key then return a.key < b.key end
            if (a.key ~= nil) ~= (b.key ~= nil) then return a.key ~= nil end
            return a.seq < b.seq
        end)
        return out
    end)
    if ok and type(found) == "table" then return found end
    return {}
end

--- Find the loot-history drop matching an open roll, when only one can match.
--- @param itemLink string|nil From GetLootRollItemLink(rollID)
--- @return table|nil dropInfo  nil when absent, unavailable, or ambiguous
--- @return number|nil encounterID  With the drop key, finds this drop again
---         after the roll ends, when the link join can no longer see it
function T.ResolveDrop(itemLink)
    local matches = T.Candidates(itemLink)
    -- Exactly one candidate, or nothing. Two copies go through PairCopies.
    if #matches ~= 1 then return nil end
    return matches[1].drop, matches[1].encounterID
end

--- "encounterID:key", the identity of one drop across the whole history.
--- @return string|nil
function T.KeyString(encounterID, key)
    if encounterID == nil or key == nil then return nil end
    return tostring(encounterID) .. ":" .. tostring(key)
end

--- Pair open rolls for one item link with that link's history drops.
--- The oldest roll takes the lowest drop key: a boss's drops are numbered in
--- the order they dropped, and their rolls start in that order. Fails closed
--- (returns no pairs) when the number of rolls and drops disagree, or when a
--- drop has no readable key to remember it by.
--- @param rolls table  Array of { rollID, startedAt } still without a drop
--- @param candidates table  From T.Candidates, drops other rolls hold removed
--- @return table pairs  rollID -> candidate
function T.PairCopies(rolls, candidates)
    local out = {}
    if type(rolls) ~= "table" or type(candidates) ~= "table" then return out end
    if #rolls == 0 or #rolls ~= #candidates then return out end
    for _, c in ipairs(candidates) do
        if c.key == nil or c.encounterID == nil then return out end
    end
    local ordered = {}
    for i, r in ipairs(rolls) do ordered[i] = r end
    table.sort(ordered, function(a, b)
        local sa, sb = a.startedAt or 0, b.startedAt or 0
        if sa ~= sb then return sa < sb end
        return (a.rollID or 0) < (b.rollID or 0)
    end)
    for i, r in ipairs(ordered) do out[r.rollID] = candidates[i] end
    return out
end

--- Your own choice as history recorded it on a drop.
--- @param drop table|nil  EncounterLootDropInfo
--- @return string|nil  A bucket ("need", "pass", "waiting", ...), nil if you are not on it
function T.SelfBucket(drop)
    if type(drop) ~= "table" then return nil end
    for _, info in ipairs(Plain(drop.rollInfos, "table") or {}) do
        if Plain(info.isSelf, "boolean") == true then
            return T.BucketForState(Plain(info.state, "number"))
        end
    end
    return nil
end

--- Check a pairing of copies against what you pressed. A drop that records a
--- choice of yours on a roll you never pressed, while a roll you did press
--- sits on a drop with no choice of yours, means those two were paired the
--- wrong way round.
--- @param entries table  Array of { pressed = boolean, selfBucket = string|nil }
--- @return number|nil i, number|nil j  Indexes whose drops should swap
function T.FindMisPair(entries)
    if type(entries) ~= "table" then return nil end
    local function chose(e) return e.selfBucket ~= nil and e.selfBucket ~= "waiting" end
    for i, x in ipairs(entries) do
        if not x.pressed and chose(x) then
            for j, y in ipairs(entries) do
                if j ~= i and y.pressed and not chose(y) then return i, j end
            end
        end
    end
    return nil
end

--- Find a drop again by its key. Unlike Candidates this does not skip
--- finished drops: finding the finished one is the point. The key names
--- exactly one drop, so there is no ambiguity to fail closed on.
--- @param encounterID number
--- @param lootListID number  The drop key (T.DropKey)
--- @return table|nil dropInfo
function T.FindDrop(encounterID, lootListID)
    if encounterID == nil or lootListID == nil then return nil end
    if not Has("lootHistory") then return nil end
    local ok, found = pcall(function()
        for _, drop in ipairs(C_LootHistory.GetSortedDropsForEncounter(encounterID) or {}) do
            if T.DropKey(drop) == lootListID then return drop end
        end
    end)
    if ok then return found end
    return nil
end

-- ============================================================================
-- SUMMARY
-- ============================================================================

local EMPTY_COUNTS = { need = 0, needOff = 0, transmog = 0, greed = 0, pass = 0, waiting = 0 }

--- Summarise one drop into what the frame renders.
--- @param drop table|nil EncounterLootDropInfo
--- `players` carries the names behind each count, so the frame can answer
--- "who needed?" — the counts alone cannot be checked against chat in a raid.
--- @return table|nil summary { counts, players, total, rolled, leaderName, leaderRoll, isTied, winnerName, winnerRoll, allPassed, youRolled }
function T.Summarise(drop)
    if type(drop) ~= "table" then return nil end

    local counts, players = {}, {}
    for k, v in pairs(EMPTY_COUNTS) do
        counts[k] = v
        players[k] = {}
    end

    local total, rolled, youRolled = 0, 0, nil
    for _, info in ipairs(Plain(drop.rollInfos, "table") or {}) do
        local bucket = T.BucketForState(Plain(info.state, "number"))
        if bucket then
            local isSelf = Plain(info.isSelf, "boolean") == true
            counts[bucket] = (counts[bucket] or 0) + 1
            local list = players[bucket]
            list[#list + 1] = {
                name   = R.SafeString(Plain(info.playerName, "string")),
                class  = R.SafeString(Plain(info.playerClass, "string")),
                roll   = Plain(info.roll, "number"),
                isSelf = isSelf,
                isWinner = Plain(info.isWinner, "boolean") == true,
                bucket = bucket,
            }
            total = total + 1
            if bucket ~= "waiting" then rolled = rolled + 1 end
            if isSelf then youRolled = bucket end
        end
    end

    for _, list in pairs(players) do T.SortPlayers(list) end

    local leader = Plain(drop.currentLeader, "table")
    local winner = Plain(drop.winner, "table")
    local function Name(p) return p and R.SafeString(Plain(p.playerName, "string")) or nil end
    local function Class(p) return p and R.SafeString(Plain(p.playerClass, "string")) or nil end
    local function Roll(p) return p and Plain(p.roll, "number") or nil end

    return {
        counts     = counts,
        players    = players,
        total      = total,
        rolled     = rolled,
        youRolled  = youRolled,
        isTied     = Plain(drop.isTied, "boolean") == true,
        allPassed  = Plain(drop.allPassed, "boolean") == true,
        leaderName = Name(leader),
        leaderRoll = Roll(leader),
        leaderClass = Class(leader),
        winnerName = Name(winner),
        winnerRoll = Roll(winner),
        winnerClass = Class(winner),
    }
end

--- Highest roll first, then by name, so the list reads like the standings.
--- Players with no roll yet (the number arrives when the roll ends) sort by
--- name after anyone who has one.
--- @param list table  Array of { name, class, roll, isSelf }
--- @return table list  Sorted in place
function T.SortPlayers(list)
    table.sort(list, function(a, b)
        local ra, rb = a.roll or -1, b.roll or -1
        if ra ~= rb then return ra > rb end
        return (a.name or "") < (b.name or "")
    end)
    return list
end

--- Resolve and summarise in one step.
--- @param itemLink string|nil
--- @return table|nil summary
function T.ForItemLink(itemLink)
    return T.Summarise(T.ResolveDrop(itemLink))
end

-- ============================================================================
-- RENDERING
-- Kept here rather than in the frame layer so the demo can exercise exactly the
-- same formatting against a synthetic summary.
-- ============================================================================

local L = addon.L

local BUCKET_ORDER = { "need", "needOff", "transmog", "greed", "pass" }
local BUCKET_LABEL = {
    need     = "LOOT_ROLL_TALLY_NEED",
    needOff  = "LOOT_ROLL_TALLY_NEED_OFF",
    transmog = "LOOT_ROLL_TALLY_TRANSMOG",
    greed    = "LOOT_ROLL_TALLY_GREED",
    pass     = "LOOT_ROLL_TALLY_PASS",
}
local BUCKET_COLOR = {
    need     = "|cFF40C040",
    needOff  = "|cFF8FD18F",
    transmog = "|cFFFF80FF",
    greed    = "|cFFE6CC52",
    pass     = "|cFF999999",
}

--- Build the tally line shown under the item name.
---
--- Choice counts are NOT here: they sit on the roll buttons' icons, and
--- repeating them on the line was noise (feedback, 2026-11-25). Nor is the
--- current leader: the numbers are only rolled once everyone has chosen, so a
--- "leads with" mid-roll was a result shown before there was one. The line
--- says who is still to choose while the roll runs, and the outcome after.
--- @param summary table|nil
--- @return string  "" when there is nothing worth saying
function T.FormatLine(summary)
    if not summary then return "" end

    if summary.allPassed then
        return (L and L["LOOT_ROLL_TALLY_ALL_PASSED"]) or "Everyone passed"
    end

    if summary.winnerName then
        local template = (L and L["LOOT_ROLL_TALLY_WON"]) or "%s won with %d"
        return template:format(summary.winnerName, summary.winnerRoll or 0)
    end

    local waiting = summary.counts and summary.counts.waiting or 0
    if waiting > 0 then
        local template = (L and L["LOOT_ROLL_TALLY_WAITING"]) or "waiting on %d"
        return template:format(waiting)
    end
    return ""
end

-- ============================================================================
-- WHO ROLLED WHAT
-- Names behind the counts, for the roll buttons' tooltips and the tally line's.
-- In a dungeon you can match five names against chat; in a raid you cannot,
-- which is the whole reason this exists.
-- ============================================================================

-- Buttons are RollOnLoot types; summaries are EncounterLootDropRollState
-- buckets. Need covers off-spec Need as well: both came from the Need button.
local BUTTON_BUCKETS = {
    [R.ROLL_NEED]       = { "need", "needOff" },
    [R.ROLL_GREED]      = { "greed" },
    [R.ROLL_TRANSMOG]   = { "transmog" },
    [R.ROLL_PASS]       = { "pass" },
}

--- @param rollType number  R.ROLL_*
--- @return table buckets  Empty for a button with no matching history state
function T.BucketsForButton(rollType)
    return BUTTON_BUCKETS[rollType] or {}
end

--- How many players chose a roll button, for the number drawn on its icon.
--- @param summary table|nil
--- @param rollType number  R.ROLL_*
--- @return number
function T.CountForButton(summary, rollType)
    if not (summary and summary.counts) then return 0 end
    local n = 0
    for _, bucket in ipairs(T.BucketsForButton(rollType)) do
        n = n + (summary.counts[bucket] or 0)
    end
    return n
end

--- @param class string|nil  Class file token, e.g. "MAGE"
--- @return number r, number g, number b
function T.ClassColor(class)
    if class and class ~= "" then
        if C_ClassColor and C_ClassColor.GetClassColor then
            local ok, c = pcall(C_ClassColor.GetClassColor, class)
            if ok and c and c.r then return c.r, c.g, c.b end
        end
        local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if rc and rc.r then return rc.r, rc.g, rc.b end
    end
    return 1, 1, 1
end

--- A player's name in their class colour, with "(you)" on your own.
--- @param p table  { name, class, isSelf }
--- @return string
function T.FormatPlayerName(p)
    local r, g, b = T.ClassColor(p.class)
    local name = p.name ~= "" and p.name or "?"
    if p.isSelf then
        name = name .. " " .. ((L and L["LOOT_ROLL_WHO_YOU"]) or "(you)")
    end
    return ("|cFF%02X%02X%02X%s|r"):format(
        math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), name)
end

--- Players in the given buckets, merged and sorted.
--- @param summary table|nil
--- @param buckets table
--- @return table list
function T.PlayersIn(summary, buckets)
    local out = {}
    if not (summary and summary.players) then return out end
    for _, bucket in ipairs(buckets) do
        for _, p in ipairs(summary.players[bucket] or {}) do out[#out + 1] = p end
    end
    return T.SortPlayers(out)
end

--- Add one bucket group's names to a tooltip.
--- @param tooltip table  GameTooltip
--- @param list table  From T.PlayersIn
--- @return number added
local function AddPlayerLines(tooltip, list)
    for _, p in ipairs(list) do
        if p.roll then
            tooltip:AddDoubleLine(T.FormatPlayerName(p), tostring(p.roll), 1, 1, 1, 0.8, 0.8, 0.8)
        else
            tooltip:AddLine(T.FormatPlayerName(p), 1, 1, 1)
        end
    end
    return #list
end

--- Names for a single roll button, under whatever the button tooltip already
--- says. Says "nobody yet" rather than nothing, so an empty list is visibly an
--- answer and not a missing feature.
--- @param tooltip table  GameTooltip
--- @param summary table|nil
--- @param rollType number  R.ROLL_*
--- @return boolean added
function T.AddButtonRollers(tooltip, summary, rollType)
    if not (tooltip and summary and summary.players) then return false end
    local buckets = T.BucketsForButton(rollType)
    if #buckets == 0 then return false end
    local list = T.PlayersIn(summary, buckets)
    tooltip:AddLine(" ")
    if #list == 0 then
        tooltip:AddLine((L and L["LOOT_ROLL_WHO_NOBODY"]) or "Nobody yet", 0.6, 0.6, 0.6)
    else
        AddPlayerLines(tooltip, list)
    end
    return true
end

--- Every bucket with its names, for hovering the tally line.
--- @param tooltip table  GameTooltip
--- @param summary table|nil
--- @return boolean added
function T.AddAllRollers(tooltip, summary)
    if not (tooltip and summary and summary.players) then return false end
    local any = false
    for _, bucket in ipairs(BUCKET_ORDER) do
        local list = summary.players[bucket] or {}
        if #list > 0 then
            if any then tooltip:AddLine(" ") end
            local label = (L and L[BUCKET_LABEL[bucket]]) or bucket
            tooltip:AddLine(("%s%s (%d)|r"):format(BUCKET_COLOR[bucket] or "|cFFFFFFFF", label, #list))
            AddPlayerLines(tooltip, list)
            any = true
        end
    end
    local waiting = summary.players.waiting or {}
    if #waiting > 0 then
        if any then tooltip:AddLine(" ") end
        local template = (L and L["LOOT_ROLL_WHO_WAITING"]) or "Still choosing (%d)"
        tooltip:AddLine(template:format(#waiting), 0.6, 0.6, 0.6)
        AddPlayerLines(tooltip, waiting)
        any = true
    end
    if not any then
        tooltip:AddLine((L and L["LOOT_ROLL_WHO_NOBODY"]) or "Nobody yet", 0.6, 0.6, 0.6)
    end
    return true
end
