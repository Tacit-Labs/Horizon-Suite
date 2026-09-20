--[[
    Horizon Suite - Focus - Dungeon Run Tracker (data)

    Accumulates what a party-dungeon run earned: elapsed time, experience, money
    and bosses defeated, plus the per-hour rates derived from them. Pure data with
    an isolated API boundary; FocusRunBlock renders it.

    Deliberately event-driven only. Nothing here reads the combat log, so mob kill
    counts are out of scope: COMBAT_LOG_EVENT_UNFILTERED fires constantly and would
    be this addon's first consumer of it. Everything below costs one event per gain.

    Run identity is the instanceID from GetInstanceInfo(). Re-entering the same
    instance within RESUME_WINDOW resumes the run rather than starting a fresh one,
    because a corpse run on a Classic-era client drops you outside the instance and
    back in, which would otherwise reset the numbers mid-dungeon. Elapsed stays on
    wall clock across that gap; the window bounds how wrong that can be.

    The run in progress survives a reload. It is stored at HorizonDB.dungeonRun,
    keyed by character, as exactly one record: deliberately NOT inside a profile,
    because ProfileIO serialises a whole profile on export and copying settings to
    an alt would otherwise copy dungeon state with them. This is the in-progress
    run only. There is no run history.

    Every stored timestamp is wall-clock epoch seconds rather than GetTime(),
    which is session-relative and restarts at zero on a reload.
]]

local addon = _G.HorizonSuite

-- Re-entering the same instance within this many seconds continues the run.
local RESUME_WINDOW = 600
-- Per-hour figures stay blank below this elapsed time. A run that is twelve
-- seconds old divides by almost nothing and prints a rate nobody can use.
local RATE_MIN_ELAPSED = 60
-- Top-level HorizonDB key. A sibling of `profiles`, never a member of one.
local DB_KEY = "dungeonRun"

local run = nil         -- the live run, or nil
local lastRun = nil     -- the most recent run, kept for the resume window
local pendingLive = nil -- a run restored from disk that was live when it was saved
local hydrated = false

local function Now()
    return time()
end

-- ---------------------------------------------------------------------------
-- Experience
-- ---------------------------------------------------------------------------

-- True when the player cannot earn experience, so the XP row is hidden rather
-- than showing a permanent zero.
local function IsXPCapped()
    local okDisabled, disabled = pcall(function() return IsXPUserDisabled and IsXPUserDisabled() end)
    if okDisabled and disabled then return true end
    local okMax, maxXP = pcall(UnitXPMax, "player")
    if okMax and (tonumber(maxXP) or 0) <= 0 then return true end
    local okCap, levelCap = pcall(function() return GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() end)
    local okLevel, level = pcall(UnitLevel, "player")
    if okCap and okLevel and levelCap and level and level >= levelCap then return true end
    return false
end

local function CurrentXP()
    local ok, xp = pcall(UnitXP, "player")
    return ok and (tonumber(xp) or 0) or 0
end

local function CurrentXPMax()
    local ok, xp = pcall(UnitXPMax, "player")
    return ok and (tonumber(xp) or 0) or 0
end

local function CurrentMoney()
    local ok, money = pcall(GetMoney)
    return ok and (tonumber(money) or 0) or 0
end

-- ---------------------------------------------------------------------------
-- Persistence
--
-- One record per character at HorizonDB.dungeonRun, written whenever the run's
-- figures change. The elapsed clock needs no write of its own: the record stores
-- the epoch second the run began, so however stale the save is, elapsed on
-- restore is still Now() minus that anchor.
-- ---------------------------------------------------------------------------

local function CharacterKey()
    local key = addon._GetCurrentCharacterProfileKey and addon._GetCurrentCharacterProfileKey()
    return (type(key) == "string" and key ~= "") and key or nil
end

-- @return table|nil store, string|nil charKey
local function RunStore()
    -- The key is nil until the realm resolves, which on Forever is later than
    -- ADDON_LOADED. No key means no persistence this call; the next one retries.
    local charKey = CharacterKey()
    if not charKey then return nil, nil end
    local db = _G[addon.DATABASE]
    if type(db) ~= "table" then return nil, nil end
    if type(db[DB_KEY]) ~= "table" then db[DB_KEY] = {} end
    return db[DB_KEY], charKey
end

local function CopyList(list)
    local out = {}
    for i = 1, #(list or {}) do out[i] = list[i] end
    return out
end

local function Persist()
    local store, charKey = RunStore()
    if not store then return end
    local record = run or lastRun
    if not record then
        store[charKey] = nil
        return
    end
    store[charKey] = {
        instanceName    = record.instanceName,
        instanceID      = record.instanceID,
        difficultyName  = record.difficultyName,
        startEpoch      = record.startEpoch,
        stoppedAt       = record.stoppedAt,
        leftDead        = record.leftDead,
        live            = run ~= nil,
        xpGained        = record.xpGained,
        levelsGained    = record.levelsGained,
        moneyStart      = record.moneyStart,
        moneyPending    = record.moneyPending,
        moneyAwayAdjust = record.moneyAwayAdjust,
        bosses          = CopyList(record.bosses),
    }
end

local function Forget()
    local store, charKey = RunStore()
    if store then store[charKey] = nil end
end

-- Read the stored record back into memory. A record that was live when it was
-- saved is held aside rather than made live immediately: only re-entering the
-- same instance proves the reload happened inside it.
-- @return boolean  True once the store was actually reachable.
local function Hydrate()
    if hydrated then return true end
    local store, charKey = RunStore()
    if not store then return false end
    hydrated = true

    local saved = store[charKey]
    if type(saved) ~= "table" or not saved.instanceID or not saved.startEpoch then return true end

    local restored = {
        instanceName    = saved.instanceName or "",
        instanceID      = saved.instanceID,
        difficultyName  = saved.difficultyName or "",
        startEpoch      = saved.startEpoch,
        stoppedAt       = saved.stoppedAt,
        leftDead        = saved.leftDead,
        xpGained        = tonumber(saved.xpGained) or 0,
        levelsGained    = tonumber(saved.levelsGained) or 0,
        moneyStart      = tonumber(saved.moneyStart) or CurrentMoney(),
        moneyPending    = saved.moneyPending == true,
        moneyAwayAdjust = tonumber(saved.moneyAwayAdjust),
        bosses          = CopyList(saved.bosses),
        -- Experience did not move while the client was down, so the bookkeeping
        -- baselines re-anchor to what the player has right now.
        lastXP          = CurrentXP(),
        lastXPMax       = CurrentXPMax(),
    }

    if saved.live then
        pendingLive = restored
    else
        lastRun = restored
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Run lifecycle
-- ---------------------------------------------------------------------------

-- @return name, instanceID, difficultyName, isPartyDungeon
local function ReadInstance()
    local ok, name, instanceType, _, difficultyName, _, _, _, instanceID = pcall(GetInstanceInfo)
    if not ok then return nil, nil, nil, false end
    return name, instanceID, difficultyName, instanceType == "party"
end

local function NewRun(name, instanceID, difficultyName)
    return {
        instanceName   = name or "",
        instanceID     = instanceID,
        difficultyName = difficultyName or "",
        startEpoch     = Now(),
        stoppedAt      = nil,   -- set when the player leaves; nil while inside
        xpGained       = 0,
        levelsGained   = 0,
        moneyStart     = CurrentMoney(),
        -- Logging in or reloading inside a dungeon can snapshot the baseline
        -- before the client has handed over the player's money, which would
        -- credit the whole purse to the run. A zero baseline is therefore held
        -- provisional until the first PLAYER_MONEY re-anchors it. The cost is
        -- that a player sitting on exactly 0 copper loses credit for their
        -- first gain of the run.
        moneyPending   = CurrentMoney() == 0,
        bosses         = {},
        -- XP bookkeeping: lastXPMax is the max *before* the most recent update,
        -- which is what makes the level-up wrap below correct.
        lastXP         = CurrentXP(),
        lastXPMax      = CurrentXPMax(),
    }
end

local function StartOrResume()
    local name, instanceID, difficultyName, isParty = ReadInstance()
    if not isParty then return false end

    if run and run.instanceID == instanceID then
        -- Already running in this instance (a reload of the zone, not a new run).
        run.stoppedAt = nil
        return true
    end

    -- A run that was live when it was saved, and we are back in its instance:
    -- the player reloaded or relogged mid-dungeon. Pick it straight back up.
    if pendingLive and pendingLive.instanceID == instanceID then
        run = pendingLive
        pendingLive = nil
        run.stoppedAt = nil
        lastRun = run
        Persist()
        return true
    end

    -- Resume only a run the player left as a corpse. instanceID names the dungeon,
    -- not the lockout, so "same instance, recently" is also true of a fresh reset
    -- of the same dungeon — and farming one dungeon back to back is exactly the
    -- case this tracker is for. Leaving dead is the signal that separates a corpse
    -- run from a finished one; walking out alive always ends the run.
    if lastRun and lastRun.instanceID == instanceID and lastRun.stoppedAt and lastRun.leftDead
        and (Now() - lastRun.stoppedAt) <= RESUME_WINDOW then
        run = lastRun
        run.stoppedAt = nil
        -- Money and XP baselines are re-anchored to the gap, so anything earned
        -- outside the instance is not credited to the run.
        run.moneyStart   = CurrentMoney() - (run.moneyAwayAdjust or 0)
        run.moneyPending = false
        run.lastXP       = CurrentXP()
        run.lastXPMax    = CurrentXPMax()
        Persist()
        return true
    end

    run = NewRun(name, instanceID, difficultyName)
    lastRun = run
    Persist()
    return true
end

local function StopRun()
    if not run then return end
    run.stoppedAt = Now()
    local okDead, isDead = pcall(UnitIsDeadOrGhost, "player")
    run.leftDead = okDead and isDead or false
    -- Bank what the run earned so far. On resume the baseline is re-anchored to
    -- this figure, so money made or spent outside never lands in the run.
    run.moneyAwayAdjust = CurrentMoney() - run.moneyStart
    lastRun = run
    run = nil
    Persist()
end

-- Discard the live run and start a fresh one if still inside a dungeon.
function addon.ResetDungeonRun()
    run = nil
    lastRun = nil
    pendingLive = nil
    Forget()
    StartOrResume()
end

-- ---------------------------------------------------------------------------
-- Accumulation
-- ---------------------------------------------------------------------------

local function OnXPUpdate()
    if not run then return end
    local current = CurrentXP()
    local gained
    if current >= run.lastXP then
        gained = current - run.lastXP
    else
        -- Levelled: the remainder of the old bar plus whatever landed on the new one.
        gained = math.max(0, run.lastXPMax - run.lastXP) + current
    end
    run.xpGained = run.xpGained + gained
    run.lastXP    = current
    run.lastXPMax = CurrentXPMax()
    Persist()
end

local function OnLevelUp()
    if not run then return end
    run.levelsGained = run.levelsGained + 1
    Persist()
end

local function OnEncounterEnd(_, encounterName, _, _, success)
    if not run then return end
    if success ~= 1 and success ~= true then return end
    run.bosses[#run.bosses + 1] = encounterName or ""
    Persist()
end

-- ---------------------------------------------------------------------------
-- Read side
-- ---------------------------------------------------------------------------

-- True when a run is live (the player is inside the tracked dungeon).
function addon.IsDungeonRunActive()
    return run ~= nil
end

-- Snapshot of the live run, or nil when there is none.
-- @return table|nil { instanceName, difficultyName, elapsed, xpGained, xpPerHour,
--                     moneyGained, moneyPerHour, bosses, levelsGained, hasRates, xpCapped }
function addon.GetDungeonRunData()
    if not run then return nil end

    local elapsed = math.max(0, Now() - run.startEpoch)
    -- A provisional baseline would read the player's whole purse as run income
    -- until the first PLAYER_MONEY settles it; report nothing rather than that.
    local moneyGained = run.moneyPending and 0 or (CurrentMoney() - run.moneyStart)
    local hasRates = elapsed >= RATE_MIN_ELAPSED

    return {
        instanceName   = run.instanceName,
        difficultyName = run.difficultyName,
        elapsed        = elapsed,
        xpCapped       = IsXPCapped(),
        xpGained       = run.xpGained,
        xpPerHour      = hasRates and (run.xpGained / elapsed * 3600) or nil,
        xpToNextLevel  = math.max(0, CurrentXPMax() - CurrentXP()),
        levelsGained   = run.levelsGained,
        moneyGained    = moneyGained,
        moneyPerHour   = hasRates and (moneyGained / elapsed * 3600) or nil,
        bosses         = run.bosses,
        hasRates       = hasRates,
    }
end

-- "Scarlet Monastery has been reset." in whatever locale the client runs, turned
-- into a match pattern. A wipe-release-reset-re-enter cycle otherwise satisfies
-- every condition the corpse-run resume tests for, and the fresh run would
-- inherit the wiped one's figures.
local instanceResetPattern
do
    local ok, pattern = pcall(function()
        local raw = _G.INSTANCE_RESET_SUCCESS
        if type(raw) ~= "string" then return nil end
        local escaped = raw:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        return (escaped:gsub("%%%%s", ".+"))
    end)
    instanceResetPattern = ok and pattern or nil
end

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------

-- Everything the tracker is holding, including what is on disk, so a run can be
-- checked without guessing from the banner. Drives `/h debug focus runstate`.
--
-- The three in-memory slots are what the resume rules act on, and telling them
-- apart is the whole point: `run` is live, `lastRun` is a finished run still
-- inside the resume window, and `pendingLive` is a run restored from disk that
-- has not yet proved it is back in its own instance.
-- @return table
function addon.GetDungeonRunDebugSnapshot()
    local name, instanceID, difficultyName, isParty = ReadInstance()
    local store, charKey = RunStore()
    local saved = (store and charKey) and store[charKey] or nil

    local function describe(record, label)
        if not record then return label .. ": none" end
        return ("%s: %s (id=%s) started=%s xp=%s levels=%s moneyStart=%s bosses=%d%s%s"):format(
            label,
            tostring(record.instanceName),
            tostring(record.instanceID),
            tostring(record.startEpoch),
            tostring(record.xpGained),
            tostring(record.levelsGained),
            tostring(record.moneyStart),
            #(record.bosses or {}),
            record.stoppedAt and (" stopped=" .. tostring(record.stoppedAt)) or "",
            record.leftDead ~= nil and (" leftDead=" .. tostring(record.leftDead)) or "")
    end

    local lines = {
        ("client: instance=%s (id=%s, %s) partyDungeon=%s"):format(
            tostring(name), tostring(instanceID), tostring(difficultyName), tostring(isParty)),
        ("persistence: charKey=%s hydrated=%s storeReachable=%s"):format(
            tostring(charKey), tostring(hydrated), tostring(store ~= nil)),
        ("rules: resumeWindow=%ds rateMinElapsed=%ds resetPattern=%s"):format(
            RESUME_WINDOW, RATE_MIN_ELAPSED, instanceResetPattern and "built" or "unavailable"),
        describe(run, "run (live)"),
        describe(lastRun, "lastRun (resumable)"),
        describe(pendingLive, "pendingLive (from disk)"),
    }

    if saved then
        lines[#lines + 1] = ("saved: id=%s live=%s started=%s xp=%s moneyStart=%s bosses=%d age=%ds"):format(
            tostring(saved.instanceID), tostring(saved.live), tostring(saved.startEpoch),
            tostring(saved.xpGained), tostring(saved.moneyStart), #(saved.bosses or {}),
            math.max(0, Now() - (tonumber(saved.startEpoch) or Now())))
    else
        lines[#lines + 1] = "saved: no record for this character"
    end

    local data = addon.GetDungeonRunData()
    if data then
        lines[#lines + 1] = ("derived: elapsed=%ds xp=%s money=%s rates=%s xpCapped=%s"):format(
            math.floor(data.elapsed), tostring(data.xpGained), tostring(data.moneyGained),
            data.hasRates and "live" or ("held until " .. RATE_MIN_ELAPSED .. "s"),
            tostring(data.xpCapped))
    else
        lines[#lines + 1] = "derived: no live run"
    end

    return { lines = lines }
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_MONEY")
pcall(function() eventFrame:RegisterEvent("PLAYER_XP_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("PLAYER_LEVEL_UP") end)
pcall(function() eventFrame:RegisterEvent("ENCOUNTER_END") end)
if instanceResetPattern then eventFrame:RegisterEvent("CHAT_MSG_SYSTEM") end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        Hydrate()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        Hydrate()
        local _, instanceID, _, isParty = ReadInstance()
        if isParty then
            StartOrResume()
        else
            StopRun()
        end
        -- A restored live run we did not land back inside is over: the player
        -- reloaded and came up somewhere else. Demote it so the corpse-run path
        -- cannot resume it either, since they plainly did not leave as a corpse.
        if pendingLive and pendingLive.instanceID ~= instanceID then
            pendingLive.stoppedAt = pendingLive.stoppedAt or Now()
            pendingLive.leftDead = false
            lastRun = pendingLive
            pendingLive = nil
            Persist()
        end
        if addon.UpdateDungeonRunBlock then addon.UpdateDungeonRunBlock() end
    elseif event == "PLAYER_XP_UPDATE" then
        OnXPUpdate()
    elseif event == "PLAYER_LEVEL_UP" then
        OnLevelUp()
    elseif event == "ENCOUNTER_END" then
        local before = run and #run.bosses or 0
        OnEncounterEnd(...)
        -- The first boss of a run adds a row, which makes the block taller. Only
        -- a full layout re-measures the panel around it; every later kill just
        -- changes a number, so it takes the cheap repaint.
        if run and #run.bosses == 1 and before == 0 and addon.FullLayout then
            addon.FullLayout()
        elseif addon.UpdateDungeonRunBlock then
            addon.UpdateDungeonRunBlock()
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local msg = ...
        if type(msg) == "string" and instanceResetPattern and msg:match(instanceResetPattern) then
            -- The dungeon behind us no longer exists; nothing left to resume into.
            lastRun = nil
            pendingLive = nil
            Forget()
        end
    elseif event == "PLAYER_MONEY" then
        -- Money is otherwise read live from GetMoney() against the run baseline;
        -- this only settles a baseline that was taken before the client had it.
        if run and run.moneyPending then
            run.moneyStart   = CurrentMoney()
            run.moneyPending = false
            Persist()
        end
    end
end)
