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
    run at once for the identical link, so ResolveDrop FAILS CLOSED: more than
    one surviving candidate returns nil and the row renders blank. A missing
    tally costs one line. A tally naming the wrong winner would be believed,
    and is worse than showing nothing at all.
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
    return not (drop.winner or drop.allPassed)
end

local function InWindow(drop, now)
    if not now or not drop.startTime then return true end
    local elapsed = now - drop.startTime
    if elapsed < -WINDOW_SLACK then return false end
    local duration = tonumber(drop.duration) or 0
    if duration <= 0 then return true end
    return elapsed <= (duration + WINDOW_SLACK)
end

--- Find the loot-history drop matching an open roll.
--- @param itemLink string|nil From GetLootRollItemLink(rollID)
--- @return table|nil dropInfo  nil when absent, unavailable, or ambiguous
function T.ResolveDrop(itemLink)
    if not itemLink or itemLink == "" then return nil end
    if not Has("lootHistory") then return nil end

    local ok, matches = pcall(function()
        local now = C_LootHistory.GetLootHistoryTime and C_LootHistory.GetLootHistoryTime() or nil
        local found = {}
        local encounters = C_LootHistory.GetAllEncounterInfos() or {}
        for _, encounter in ipairs(encounters) do
            local drops = C_LootHistory.GetSortedDropsForEncounter(encounter.encounterID) or {}
            for _, drop in ipairs(drops) do
                if drop.itemHyperlink == itemLink and IsUnfinished(drop) and InWindow(drop, now) then
                    found[#found + 1] = drop
                end
            end
        end
        return found
    end)

    if not ok or type(matches) ~= "table" then return nil end
    -- Exactly one candidate, or nothing. See the header: ambiguity renders blank.
    if #matches ~= 1 then return nil end
    return matches[1]
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
    for _, info in ipairs(drop.rollInfos or {}) do
        local bucket = T.BucketForState(info.state)
        if bucket then
            counts[bucket] = (counts[bucket] or 0) + 1
            local list = players[bucket]
            list[#list + 1] = {
                name   = R.SafeString(info.playerName),
                class  = R.SafeString(info.playerClass),
                roll   = tonumber(info.roll),
                isSelf = info.isSelf and true or false,
            }
            total = total + 1
            if bucket ~= "waiting" then rolled = rolled + 1 end
            if info.isSelf then youRolled = bucket end
        end
    end

    for _, list in pairs(players) do T.SortPlayers(list) end

    local leader = drop.currentLeader
    local winner = drop.winner

    return {
        counts     = counts,
        players    = players,
        total      = total,
        rolled     = rolled,
        youRolled  = youRolled,
        isTied     = drop.isTied and true or false,
        allPassed  = drop.allPassed and true or false,
        leaderName = leader and R.SafeString(leader.playerName) or nil,
        leaderRoll = leader and tonumber(leader.roll) or nil,
        leaderClass = leader and R.SafeString(leader.playerClass) or nil,
        winnerName = winner and R.SafeString(winner.playerName) or nil,
        winnerRoll = winner and tonumber(winner.roll) or nil,
        winnerClass = winner and R.SafeString(winner.playerClass) or nil,
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

    local parts = {}
    for _, bucket in ipairs(BUCKET_ORDER) do
        local n = summary.counts and summary.counts[bucket] or 0
        if n > 0 then
            local label = (L and L[BUCKET_LABEL[bucket]]) or bucket
            parts[#parts + 1] = ("%s%d %s|r"):format(BUCKET_COLOR[bucket] or "|cFFFFFFFF", n, label)
        end
    end

    -- Nobody has chosen yet: say that rather than rendering an empty strip.
    if #parts == 0 then
        local waiting = summary.counts and summary.counts.waiting or 0
        if waiting > 0 then
            local template = (L and L["LOOT_ROLL_TALLY_WAITING"]) or "waiting on %d"
            return template:format(waiting)
        end
        return ""
    end

    local line = table.concat(parts, "  ")

    if summary.leaderName and summary.leaderRoll then
        local template = summary.isTied
            and ((L and L["LOOT_ROLL_TALLY_TIED"]) or "tied at %d")
            or  ((L and L["LOOT_ROLL_TALLY_LEADER"]) or "%s leads with %d")
        if summary.isTied then
            line = line .. "   " .. template:format(summary.leaderRoll)
        else
            line = line .. "   " .. template:format(summary.leaderName, summary.leaderRoll)
        end
    end

    return line
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

local function PlayerLine(p)
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
            tooltip:AddDoubleLine(PlayerLine(p), tostring(p.roll), 1, 1, 1, 0.8, 0.8, 0.8)
        else
            tooltip:AddLine(PlayerLine(p), 1, 1, 1)
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
