--[[
    Horizon Suite - Augment - Self Highlight
    Manages WoW's native self-highlight effect (findYourself CVars) based on
    combat state and target hostility. Activates the configured mode on trigger,
    restores all CVars to 0 when neither trigger is active.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

-- Register this mini-module's DB keys into the shared routing table.
Y.DB_KEYS.augmentSelfHighlightEnabled = true
Y.DB_KEYS.selfHighlightEnabled        = true
Y.DB_KEYS.selfHighlightMode           = true
Y.DB_KEYS.selfHighlightCombat         = true
Y.DB_KEYS.selfHighlightHostile        = true

-- ============================================================================
-- CVar map per highlight mode
-- ============================================================================

-- findYourselfMode integer values come from WoW's own enum:
--   1 = outline, 2 = circle, 3 = icon, 4 = outline+circle, 5 = outline+icon
local MODE_CONFIG = {
    outline       = { mode = 1, outline = 1, circle = 0, icon = 0 },
    circle        = { mode = 2, outline = 0, circle = 1, icon = 0 },
    icon          = { mode = 3, outline = 0, circle = 0, icon = 1 },
    outlinecircle = { mode = 4, outline = 1, circle = 1, icon = 0 },
    outlineicon   = { mode = 5, outline = 1, circle = 0, icon = 1 },
}

-- ============================================================================
-- CVar helpers
-- ============================================================================

-- Cache the last applied state so SetCVar is only called on actual changes.
-- Calling SetCVar fires CVAR_UPDATE in the same tick; if that tick also
-- contains action-bar event handlers, WoW taints the cooldown context and
-- produces "Secret values are only allowed during untainted execution" errors
-- on every action button (34000+ times in a normal session with a 0.5 s ticker).
local activeMode = nil  -- current mode key string, false = cleared, nil = unknown

local function SetHighlight(modeKey)
    if activeMode == modeKey then return end
    activeMode = modeKey
    local cfg = MODE_CONFIG[modeKey] or MODE_CONFIG.outlinecircle
    SetCVar("selfHighlight",                    1)
    SetCVar("findYourselfMode",                 cfg.mode)
    SetCVar("findYourselfModeOutline",          cfg.outline)
    SetCVar("findYourselfModeCircle",           cfg.circle)
    SetCVar("findYourselfModeIcon",             cfg.icon)
    SetCVar("findYourselfAnywhere",             1)
    -- Never restrict to combat-only at the CVar level; the Lua layer owns that logic.
    SetCVar("findYourselfAnywhereOnlyInCombat", 0)
end

local function ClearHighlight()
    if activeMode == false then return end
    activeMode = false
    SetCVar("selfHighlight",                    0)
    SetCVar("findYourselfMode",                 0)
    SetCVar("findYourselfModeOutline",          0)
    SetCVar("findYourselfModeCircle",           0)
    SetCVar("findYourselfModeIcon",             0)
    SetCVar("findYourselfAnywhere",             0)
    SetCVar("findYourselfAnywhereOnlyInCombat", 0)
end

-- ============================================================================
-- Core evaluation
-- ============================================================================

-- getDB helper: explicit nil-check so a stored `false` is not replaced by the default.
local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end

local function Evaluate()
    if not (addon.GetDB and addon.GetDB("augmentSelfHighlightEnabled", false)) then
        ClearHighlight()
        return
    end
    local inCombat = UnitAffectingCombat("player")
    local hostile  = UnitExists("target") and UnitCanAttack("player", "target")
    local trigger  = (getDB("selfHighlightCombat",  true) and inCombat)
                  or (getDB("selfHighlightHostile", true) and hostile)
    if trigger then
        local D = addon.AUGMENT_DEFAULTS
        SetHighlight(getDB("selfHighlightMode", D and D.selfHighlightMode or "outlinecircle"))
    else
        ClearHighlight()
    end
end

-- ============================================================================
-- Event frame + safety ticker
-- ============================================================================

local eventFrame = CreateFrame("Frame")
local ticker

local function StopTicker()
    if ticker then ticker:Cancel() end
    ticker = nil
end

local function StartTicker()
    if ticker then return end
    ticker = C_Timer.NewTicker(0.5, Evaluate)
end

eventFrame:SetScript("OnEvent", function(_, event)
    -- Delay after zone/world transitions so WoW's own defaults settle first.
    if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, Evaluate)
    else
        Evaluate()
    end
end)

-- ============================================================================
-- Public API (addon.Augment.SelfHighlight)
-- ============================================================================

local SH = {}
Y.SelfHighlight = SH

function SH.Enable()
    activeMode = nil  -- invalidate cache so first Evaluate() always writes CVars
    eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    StartTicker()
    Evaluate()
end

function SH.Disable()
    eventFrame:UnregisterAllEvents()
    StopTicker()
    ClearHighlight()
end

function SH.Evaluate()
    Evaluate()
end
