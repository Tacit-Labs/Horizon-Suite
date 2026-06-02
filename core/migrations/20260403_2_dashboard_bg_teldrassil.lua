-- Horizon Suite — Migration 20260403_2
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v4.8.0 (2026-04-03) — "Axis dashboard: Midnight default"
-- The "teldrassil" background preset was removed; remap it to "teldrassilburns".

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260403_2",

    legacy = function(db) return db._migratedDashboardBgTeldrassilToBurns end,

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" and prof.dashboardBackgroundTheme == "teldrassil" then
                prof.dashboardBackgroundTheme = "teldrassilburns"
            end
        end
    end,
})
