-- Horizon Suite — Migration 20260403
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v4.8.0 (2026-04-03) — "Axis dashboard: Midnight default"
-- The old default dashboard background was "horizon" / "solid".  Bump any
-- stored choice that matches those legacy values to the new default "midnight".

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260403",

    legacy = function(db) return db._migratedDashboardBgDefaultToMidnight end,

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                local t = prof.dashboardBackgroundTheme
                if t == "horizon" or t == "solid" then
                    prof.dashboardBackgroundTheme = "midnight"
                end
            end
        end
    end,
})
