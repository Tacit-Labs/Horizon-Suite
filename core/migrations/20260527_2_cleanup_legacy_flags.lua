-- Horizon Suite — Migration 20260527_2
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v5.0.0 (2026-05-27) — migration framework cleanup
-- Now that the migration runner tracks applied migrations in db._migrations,
-- the old one-shot guard flags scattered across HorizonDB are dead weight.
-- This migration removes them so they no longer pollute users' SavedVariables.
--
-- Flags removed:
--   _augmentRenamed                      (superseded by migration 20260527)
--   _migratedDashboardBgDefaultToMidnight (superseded by migration 20260403)
--   _migratedDashboardBgTeldrassilToBurns (superseded by migration 20260403_2)
--   _migratedShowQuestTypeIconsDefaultOn  (superseded by migration 20260406)
--   _migratedMplusAlwaysShowReset         (superseded by migration 20260507)
--
-- Safety: this migration sorts last (20260527_2) so all legacy-checked
-- migrations have already had a chance to read their flags before we erase them.
-- Setting a nil key to nil is a no-op, so running this on a fresh install is safe.
--
-- NOT removed: _profilesMigrated / _profilesValidated — these are active
-- infrastructure state read by EnsureProfilesAndMigrateLegacy, not migration flags.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260527_2",

    run = function(db)
        db._augmentRenamed                       = nil
        db._migratedDashboardBgDefaultToMidnight = nil
        db._migratedDashboardBgTeldrassilToBurns = nil
        db._migratedShowQuestTypeIconsDefaultOn  = nil
        db._migratedMplusAlwaysShowReset         = nil
    end,
})
