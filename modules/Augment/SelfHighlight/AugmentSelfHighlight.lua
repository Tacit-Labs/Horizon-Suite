--[[
    Horizon Suite - Augment - Self Highlight
    Applies WoW's native findYourself CVars with combat-only gating via
    findYourselfAnywhereOnlyInCombat. When the hostile-target option is on,
    targeting an attackable unit temporarily clears that gate so the highlight
    shows outside of combat too.

    CVars persist to disk across sessions, so the event frame always listens
    for PLAYER_ENTERING_WORLD and clears stale CVars when the module is off.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

-- Register this mini-module's DB keys into the shared routing table.
Y.DB_KEYS.augmentSelfHighlightEnabled = true
Y.DB_KEYS.selfHighlightEnabled        = true
Y.DB_KEYS.selfHighlightMode           = true
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
-- Apply / clear / evaluate
-- ============================================================================

local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    if v == nil then return d end
    return v
end

local function ApplyHighlight()
    local D = addon.AUGMENT_DEFAULTS
    local modeKey = getDB("selfHighlightMode", D and D.selfHighlightMode or "outlinecircle")
    local cfg = MODE_CONFIG[modeKey] or MODE_CONFIG.outlinecircle
    SetCVar("selfHighlight",           1)
    SetCVar("findYourselfMode",        cfg.mode)
    SetCVar("findYourselfModeOutline", cfg.outline)
    SetCVar("findYourselfModeCircle",  cfg.circle)
    SetCVar("findYourselfModeIcon",    cfg.icon)
    SetCVar("findYourselfAnywhere",    1)
    -- Default to combat-only; Evaluate() may loosen this for hostile targets.
    SetCVar("findYourselfAnywhereOnlyInCombat", 1)
end

-- Zeros out the CVars we own. Called on disable and on load when the module
-- is off, to clear any values that were persisted from a previous session.
local function ClearHighlight()
    SetCVar("selfHighlight",                    0)
    SetCVar("findYourselfAnywhere",             0)
    SetCVar("findYourselfAnywhereOnlyInCombat", 0)
end

-- Toggles findYourselfAnywhereOnlyInCombat based on hostile target state.
-- When targeting a hostile: clear the combat gate so the highlight shows outside
-- combat too. Otherwise keep it combat-only and let WoW handle the gating natively.
local function Evaluate()
    if not (addon.GetDB and addon.GetDB("augmentSelfHighlightEnabled", false)) then return end
    local hostile = getDB("selfHighlightHostile", true)
                    and UnitExists("target")
                    and UnitCanAttack("player", "target")
    SetCVar("findYourselfAnywhereOnlyInCombat", hostile and 0 or 1)
end

-- ============================================================================
-- Event frame — always registered, handles both enabled and disabled state
-- ============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        -- Delay so WoW's own CVar restoration from SavedVariables settles first.
        C_Timer.After(1, function()
            if addon.GetDB and addon.GetDB("augmentSelfHighlightEnabled", false) then
                ApplyHighlight()
                Evaluate()
            else
                -- Module is off but CVars may be dirty from a previous session.
                ClearHighlight()
            end
        end)
    elseif event == "PLAYER_TARGET_CHANGED" then
        Evaluate()
    end
end)

-- ============================================================================
-- Public API (addon.Augment.SelfHighlight)
-- ============================================================================

local SH = {}
Y.SelfHighlight = SH

function SH.Enable()
    ApplyHighlight()
    Evaluate()
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function SH.Disable()
    eventFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    ClearHighlight()
end

-- Called from AugmentCore and the options page after a setting changes. Re-applies
-- the mode CVars (so the Highlight Mode dropdown takes effect live) and re-checks
-- the hostile-target combat gate. Mirrors the SH.Enable() apply sequence. The
-- frequent PLAYER_TARGET_CHANGED path still uses the lightweight local Evaluate(),
-- so this heavier re-apply only runs on infrequent option changes.
function SH.Evaluate()
    if addon.GetDB and addon.GetDB("augmentSelfHighlightEnabled", false) then
        ApplyHighlight()
        Evaluate()
    end
end
