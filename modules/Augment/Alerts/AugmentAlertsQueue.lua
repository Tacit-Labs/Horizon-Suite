--[[
    Horizon Suite - Augment / Alerts - Queue
    Single Enqueue(kind, title, body, meta) entry point used by every Alerts
    kind module. Improves on HKDToasts' design (Roadmap §8.2) in two ways:
    sound cooldown is centralised here, per kind, instead of each kind module
    reimplementing its own debounce (HKDToasts' ConsumableAlert module had a
    local one-off cooldown table that none of its other modules shared); and
    there is exactly one combat-deferral queue instead of two parallel ones
    (HKDToasts ran a separate "challenge run" queue on top of the combat
    queue, which only mattered for chat-driven kinds like whispers — none of
    Alerts' kinds need that distinction).
]]

local addon = _G.HorizonSuite
local A = addon and addon.Augment and addon.Augment.Alerts
if not A then return end

local lastSoundAt = {}
local deferred = {}
local flushTicker

-- WoW disallows several frame operations (anchoring, protected frame
-- movement) while in combat, so any alert raised during combat is queued and
-- flushed once PLAYER_REGEN_ENABLED fires.
local function isInCombat()
    return InCombatLockdown and InCombatLockdown()
end
A.IsInCombat = isInCombat

-- Play the kind's sound, gated by a shared per-kind cooldown so a burst of
-- the same alert (e.g. several friends logging on at once) doesn't spam audio.
function A.PlaySoundForKind(kind)
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsSoundEnabled", D.alertsSoundEnabled) then return end
    if not A.IsSoundEnabledForKind(kind) then return end
    local sound = A.KIND_SOUNDS[kind]
    if not sound then return end

    local cooldown = tonumber(A.GetDB("alertsSoundCooldown", D.alertsSoundCooldown)) or D.alertsSoundCooldown
    local now = GetTime and GetTime() or 0
    local last = lastSoundAt[kind] or 0
    if (now - last) < cooldown then return end
    lastSoundAt[kind] = now

    local channel = A.GetDB("alertsSoundChannel", D.alertsSoundChannel)
    pcall(PlaySound, sound, channel)
end

local function emit(kind, title, body, meta)
    if A.ShowToast then
        A.ShowToast(kind, title, body, meta)
    end
    A.PlaySoundForKind(kind)
end

local function flushDeferred()
    if isInCombat() then return end
    if #deferred == 0 then
        if flushTicker then flushTicker:Cancel(); flushTicker = nil end
        return
    end
    local queue = deferred
    deferred = {}
    for i = 1, #queue do
        local item = queue[i]
        emit(item.kind, item.title, item.body, item.meta)
    end
    if flushTicker then flushTicker:Cancel(); flushTicker = nil end
end
A.FlushDeferred = flushDeferred

-- Called from AugmentAlertsEvents.lua's PLAYER_REGEN_ENABLED handler.
function A.OnCombatEnd()
    if #deferred == 0 then return end
    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, flushDeferred)
    else
        flushDeferred()
    end
end

-- Public entry point. Every kind module calls this instead of touching the
-- render layer or sound dispatch directly.
-- @param kind string  one of A.KNOWN_KINDS
-- @param title string  short headline (e.g. a friend's name)
-- @param body string  detail line
-- @param meta table|nil  optional per-toast overrides; meta.duration overrides the hold time
function A.Enqueue(kind, title, body, meta)
    if not A.KNOWN_KINDS[kind] then return end
    title = A.SafeString(title)
    body  = A.SafeString(body)

    if isInCombat() then
        deferred[#deferred + 1] = { kind = kind, title = title, body = body, meta = meta }
        return
    end

    emit(kind, title, body, meta)
end
