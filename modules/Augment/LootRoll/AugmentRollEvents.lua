--[[
    Horizon Suite - Augment / Loot Roll - Events
    Roll lifecycle: open a frame on START_LOOT_ROLL, keep its tally fresh from
    LOOT_HISTORY_UPDATE_DROP, release it when the roll ends.

    No combat deferral anywhere in this file, deliberately. Alerts queues its
    toasts until PLAYER_REGEN_ENABLED because a status alert can wait; a loot
    roll cannot — the timer runs out in seconds and most rolls open mid-fight.
    Nothing here touches a secure or protected path, so there is no reason to
    wait.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local R = addon.Augment.Roll

addon.Log.registerTag("augmentLootRoll", "lootRollDebugLive")

local ev = CreateFrame("Frame")
local registered = false

local EVENTS = {
    "START_LOOT_ROLL",
    "CANCEL_LOOT_ROLL",
    "CANCEL_ALL_LOOT_ROLLS",
    "LOOT_ROLLS_COMPLETE",
    "LOOT_HISTORY_UPDATE_DROP",
    "MAIN_SPEC_NEED_ROLL",
}

local function Log(msg)
    if addon.Log and addon.Log.debug then
        addon.Log.debug("augmentLootRoll", msg)
    end
end

-- ============================================================================
-- ROLL DESCRIPTOR
-- ============================================================================

--- Read a live roll into the descriptor the frame layer renders.
--- GetLootRollItemInfo's 13 returns, in Blizzard's own order (GroupLootFrame.lua):
---   texture, name, count, quality, bindOnPickUp,
---   canNeed, canGreed, canDisenchant,
---   reasonNeed, reasonGreed, reasonDisenchant,
---   deSkillRequired, canTransmog
--- Read through pcall and select() so a client returning fewer values degrades
--- to "that capability is absent" rather than throwing.
--- @param rollID number
--- @return table|nil
function R.BuildRoll(rollID, rollTime)
    if not GetLootRollItemInfo then return nil end
    local ok, texture, name, count, quality, bindOnPickUp,
          canNeed, canGreed, canDisenchant,
          reasonNeed, reasonGreed, reasonDisenchant,
          _, canTransmog = pcall(GetLootRollItemInfo, rollID)

    if not ok or not name then return nil end

    local itemLink
    if GetLootRollItemLink then
        local linkOk, link = pcall(GetLootRollItemLink, rollID)
        if linkOk then itemLink = link end
    end

    local function Reason(index)
        if not index then return nil end
        return _G["LOOT_ROLL_INELIGIBLE_REASON" .. tostring(index)]
    end

    return {
        rollID        = rollID,
        rollTime      = tonumber(rollTime) or 0,
        texture       = texture,
        name          = name,
        count         = tonumber(count) or 1,
        quality       = tonumber(quality) or 1,
        itemLink      = itemLink,
        bindOnPickUp  = bindOnPickUp and true or false,
        canNeed       = canNeed and true or false,
        canGreed      = canGreed and true or false,
        canDisenchant = canDisenchant and true or false,
        canTransmog   = canTransmog and true or false,
        reasonNeed        = (not canNeed) and Reason(reasonNeed) or nil,
        reasonGreed       = (not canGreed) and Reason(reasonGreed) or nil,
        reasonDisenchant  = (not canDisenchant) and Reason(reasonDisenchant) or nil,
    }
end

-- ============================================================================
-- HANDLERS
-- ============================================================================

-- Rolls this session has already ruled on, keyed by rollID → drew-it boolean.
-- Cleared as each roll ends.
local decided = {}

--- Decide once, per roll, whether Horizon draws it — and draw it if so.
---
--- This is memoized and safe to call from either side, because the ordering
--- between our START_LOOT_ROLL handler and Blizzard's own is not guaranteed.
--- AugmentRollCore's GroupLootContainer_AddRoll hook calls this before asking
--- whether to suppress, so whichever path the client runs first makes the
--- decision and the other reads it.
--- @param rollID number
--- @param rollTime number|nil
--- @return boolean drewIt
function R.EnsureRollHandled(rollID, rollTime)
    if rollID == nil then return false end
    if decided[rollID] ~= nil then return decided[rollID] end

    if not R.IsEnabled() then
        decided[rollID] = false
        return false
    end

    local roll = R.BuildRoll(rollID, rollTime)
    if not roll then
        Log("roll " .. tostring(rollID) .. ": no item info, leaving it to Blizzard")
        decided[rollID] = false
        return false
    end

    -- Below the quality floor we draw nothing AND suppress nothing, so the
    -- player still gets Blizzard's frame rather than losing the roll entirely.
    if roll.quality < R.GetMinQuality() then
        Log(("skipping roll %d (%s, quality %d < floor %d)")
            :format(rollID, tostring(roll.name), roll.quality, R.GetMinQuality()))
        decided[rollID] = false
        return false
    end

    Log(("roll %d: %s q%d need=%s greed=%s mog=%s de=%s bop=%s")
        :format(rollID, tostring(roll.name), roll.quality,
            tostring(roll.canNeed), tostring(roll.canGreed), tostring(roll.canTransmog),
            tostring(roll.canDisenchant), tostring(roll.bindOnPickUp)))

    -- Only claim a roll we actually drew. One past the visible cap keeps its
    -- Blizzard frame rather than disappearing.
    local shown = R.ShowRoll(roll)
    decided[rollID] = shown

    -- Close any Blizzard frame already open for this roll. The AddRoll hook
    -- normally stops one being created at all, but it cannot help when Blizzard
    -- drew first — reloading mid-roll, or a roll that opened before the module
    -- was switched on.
    if shown then R.HideBlizzardRollFrame(rollID) end

    return shown
end

--- Forget a roll's decision. Called as the roll ends.
--- @param rollID number|nil  nil clears every decision
--- @return nil
function R.ForgetRoll(rollID)
    if rollID == nil then
        decided = {}
    else
        decided[rollID] = nil
    end
end

local function OnStartLootRoll(rollID, rollTime)
    R.EnsureRollHandled(rollID, rollTime)
end

local function OnCancelLootRoll(rollID)
    Log("CANCEL_LOOT_ROLL " .. tostring(rollID))
    R.ReleaseRoll(rollID)
    R.ForgetRoll(rollID)
end

local function OnCancelAll()
    Log("CANCEL_ALL_LOOT_ROLLS")
    R.ClearAllRolls()
    R.ForgetRoll(nil)
end

local function OnRollsComplete()
    Log("LOOT_ROLLS_COMPLETE")
    -- Give the last history update a frame to land so a winner line is visible
    -- briefly before the rows go, rather than blinking out mid-update.
    R.RefreshAllTallies()
end

local function OnHistoryUpdateDrop(encounterID, lootListID)
    Log(("LOOT_HISTORY_UPDATE_DROP enc=%s list=%s"):format(tostring(encounterID), tostring(lootListID)))
    R.RefreshAllTallies()
end

-- Your own need roll, resolved by the server before the timer ends. Blizzard
-- plays an animation here; we show the number on the row, which is the part
-- that carries information.
local function OnMainSpecNeedRoll(rollID, roll, isWinning)
    Log(("MAIN_SPEC_NEED_ROLL %s roll=%s winning=%s")
        :format(tostring(rollID), tostring(roll), tostring(isWinning)))
    R.ShowOwnRoll(rollID, roll, isWinning)
end

ev:SetScript("OnEvent", function(_, event, ...)
    if event == "START_LOOT_ROLL" then
        local rollID, rollTime = ...
        OnStartLootRoll(rollID, rollTime)
    elseif event == "CANCEL_LOOT_ROLL" then
        OnCancelLootRoll((...))
    elseif event == "CANCEL_ALL_LOOT_ROLLS" then
        OnCancelAll()
    elseif event == "LOOT_ROLLS_COMPLETE" then
        OnRollsComplete()
    elseif event == "LOOT_HISTORY_UPDATE_DROP" then
        OnHistoryUpdateDrop(...)
    elseif event == "MAIN_SPEC_NEED_ROLL" then
        OnMainSpecNeedRoll(...)
    end
end)

-- ============================================================================
-- REGISTRATION
-- ============================================================================

function R.EnableEvents()
    if registered then return end
    registered = true
    for _, event in ipairs(EVENTS) do
        -- Registered individually and through pcall: a client without loot
        -- history throws on its event name rather than silently skipping it,
        -- and losing the tally must not cost us the roll frames.
        local ok = pcall(ev.RegisterEvent, ev, event)
        if not ok then Log("could not register " .. event .. " on this client") end
    end
end

function R.DisableEvents()
    if not registered then return end
    registered = false
    ev:UnregisterAllEvents()
end

function R.SetDebugLive(v)
    if addon.SetDB then addon.SetDB("lootRollDebugLive", v and true or false) end
end
