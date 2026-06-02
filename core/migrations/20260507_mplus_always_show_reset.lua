-- Horizon Suite — Migration 20260507
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v4.17.5 (2026-05-07) — "fix(focus): default mplusAlwaysShow off"
-- The M+ "Always Show" block changed behaviour: it now shows a preview when out
-- of a keystone run.  Reset stored true values so existing users are not
-- surprised by the preview appearing unexpectedly on upgrade.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260507",

    legacy = function(db) return db._migratedMplusAlwaysShowReset end,

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                prof.mplusAlwaysShow = false
            end
        end
    end,
})
