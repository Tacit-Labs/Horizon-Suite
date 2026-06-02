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

local function SetHighlight(modeKey)
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

local function Evaluate()
    if not (addon.GetDB and addon.GetDB("augmentSelfHighlightEnabled", false)) then
        ClearHighlight()
        return
    end
    local inCombat = UnitAffectingCombat("player")
    local hostile  = UnitExists("target") and UnitCanAttack("player", "target")
    local trigger  = (addon.GetDB("selfHighlightCombat",  true) and inCombat)
                  or (addon.GetDB("selfHighlightHostile", true) and hostile)
    if trigger then
        local D = addon.AUGMENT_DEFAULTS
        SetHighlight(addon.GetDB("selfHighlightMode", D and D.selfHighlightMode or "outlinecircle"))
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
