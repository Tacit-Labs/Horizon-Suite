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

    State lives in memory for the session only. A /reload inside a dungeon starts
    the run over — there is no run history yet, and none of this is written to
    SavedVariables.
]]

local addon = _G.HorizonSuite

-- Re-entering the same instance within this many seconds continues the run.
local RESUME_WINDOW = 600
-- Per-hour figures stay blank below this elapsed time. A run that is twelve
-- seconds old divides by almost nothing and prints a rate nobody can use.
local RATE_MIN_ELAPSED = 60

local run = nil      -- the live run, or nil
local lastRun = nil  -- the most recent run, kept for the resume window

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
        startTime      = GetTime(),
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

    -- Resume only a run the player left as a corpse. instanceID names the dungeon,
    -- not the lockout, so "same instance, recently" is also true of a fresh reset
    -- of the same dungeon — and farming one dungeon back to back is exactly the
    -- case this tracker is for. Leaving dead is the signal that separates a corpse
    -- run from a finished one; walking out alive always ends the run.
    if lastRun and lastRun.instanceID == instanceID and lastRun.stoppedAt and lastRun.leftDead
        and (GetTime() - lastRun.stoppedAt) <= RESUME_WINDOW then
        run = lastRun
        run.stoppedAt = nil
        -- Money and XP baselines are re-anchored to the gap, so anything earned
        -- outside the instance is not credited to the run.
        run.moneyStart   = CurrentMoney() - (run.moneyAwayAdjust or 0)
        run.moneyPending = false
        run.lastXP       = CurrentXP()
        run.lastXPMax    = CurrentXPMax()
        return true
    end

    run = NewRun(name, instanceID, difficultyName)
    lastRun = run
    return true
end

local function StopRun()
    if not run then return end
    run.stoppedAt = GetTime()
    local okDead, isDead = pcall(UnitIsDeadOrGhost, "player")
    run.leftDead = okDead and isDead or false
    -- Bank what the run earned so far. On resume the baseline is re-anchored to
    -- this figure, so money made or spent outside never lands in the run.
    run.moneyAwayAdjust = CurrentMoney() - run.moneyStart
    lastRun = run
    run = nil
end

-- Discard the live run and start a fresh one if still inside a dungeon.
function addon.ResetDungeonRun()
    run = nil
    lastRun = nil
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
end

local function OnLevelUp()
    if not run then return end
    run.levelsGained = run.levelsGained + 1
end

local function OnEncounterEnd(_, encounterName, _, _, success)
    if not run then return end
    if success ~= 1 and success ~= true then return end
    run.bosses[#run.bosses + 1] = encounterName or ""
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

    local elapsed = math.max(0, GetTime() - run.startTime)
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

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

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

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_MONEY")
pcall(function() eventFrame:RegisterEvent("PLAYER_XP_UPDATE") end)
pcall(function() eventFrame:RegisterEvent("PLAYER_LEVEL_UP") end)
pcall(function() eventFrame:RegisterEvent("ENCOUNTER_END") end)
if instanceResetPattern then eventFrame:RegisterEvent("CHAT_MSG_SYSTEM") end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        local _, _, _, isParty = ReadInstance()
        if isParty then
            StartOrResume()
        else
            StopRun()
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
        end
    elseif event == "PLAYER_MONEY" then
        -- Money is otherwise read live from GetMoney() against the run baseline;
        -- this only settles a baseline that was taken before the client had it.
        if run and run.moneyPending then
            run.moneyStart   = CurrentMoney()
            run.moneyPending = false
        end
    end
end)
