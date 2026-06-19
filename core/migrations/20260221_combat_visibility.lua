-- Horizon Suite — Migration 20260221
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v3.1.0 (2026-02-21) — "Add combat visibility options (Show/Fade/Hide)"
-- Converts the legacy boolean hideInCombat toggle to the new combatVisibility enum
-- ("show" | "fade" | "hide") across every stored profile.
-- The root-level hideInCombat is used as fallback for profiles that never had their own.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260221",

    run = function(db)
        local rootLegacy = db.hideInCombat
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" and prof.combatVisibility == nil then
                local legacyHide = prof.hideInCombat
                if legacyHide == nil then legacyHide = rootLegacy end
                if legacyHide ~= nil then
                    prof.combatVisibility = legacyHide and "hide" or "show"
                end
            end
        end
    end,
})
