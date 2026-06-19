-- Horizon Suite — Migration 20260301
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v3.1.0 (2026-03-01) — class-colour key standardisation
-- All per-module class-colour toggles were consolidated under a single naming
-- convention: <module><Key> → classColor<Module>.
--
-- Old keys  →  New keys (all stored per-profile)
--   dashboardClassColor  →  classColorDashboard
--   vistaClassColor      →  classColorVista
--
-- No legacy flag existed for this transform; it previously ran inside
-- EnsureProfilesAndMigrateLegacy on every session where _profilesValidated
-- was nil.  Running it again on already-migrated data is a no-op because the
-- source keys are nilled out after copying.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260301",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                if prof.dashboardClassColor ~= nil then
                    if prof.classColorDashboard == nil then
                        prof.classColorDashboard = prof.dashboardClassColor
                    end
                    prof.dashboardClassColor = nil
                end
                if prof.vistaClassColor ~= nil then
                    if prof.classColorVista == nil then
                        prof.classColorVista = prof.vistaClassColor
                    end
                    prof.vistaClassColor = nil
                end
            end
        end
    end,
})
