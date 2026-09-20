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
--- @return table|nil summary { counts, total, rolled, leaderName, leaderRoll, isTied, winnerName, winnerRoll, allPassed, youRolled }
function T.Summarise(drop)
    if type(drop) ~= "table" then return nil end

    local counts = {}
    for k, v in pairs(EMPTY_COUNTS) do counts[k] = v end

    local total, rolled, youRolled = 0, 0, nil
    for _, info in ipairs(drop.rollInfos or {}) do
        local bucket = T.BucketForState(info.state)
        if bucket then
            counts[bucket] = (counts[bucket] or 0) + 1
            total = total + 1
            if bucket ~= "waiting" then rolled = rolled + 1 end
            if info.isSelf then youRolled = bucket end
        end
    end

    local leader = drop.currentLeader
    local winner = drop.winner

    return {
        counts     = counts,
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
