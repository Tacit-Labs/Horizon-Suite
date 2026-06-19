-- Horizon Suite — Migration 20260223
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v3.0.0 (2026-02-23) — "Vista module, Presence per-type toggles"
-- The old "vista" module key was repurposed: it originally held zone-text /
-- Presence data. This migration moves that state to db.modules.presence and
-- resets db.modules.vista to off so the new Vista minimap module is opt-in.
--
-- NOTE: The actual transform runs inline inside EnsureModulesDB (HorizonSuite.lua),
-- not here. It must execute before the profile sync that immediately follows in
-- EnsureModulesDB, making it timing-sensitive for the runner (which fires later,
-- after EnsureProfilesAndMigrateLegacy). EnsureModulesDB writes
-- db._migrations["20260223"] = true when it runs, so by the time RunMigrations
-- iterates registered migrations the outer `if not db._migrations[m.id]` check is
-- already false — run() is never reached. This file exists purely for bookkeeping
-- so the migration appears in the ordered registry.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260223",

    run = function(db)
        -- Unreachable: EnsureModulesDB always marks this id done before
        -- RunMigrations is called. See the file-level comment above.
        if not db.modules or not db.modules.vista then return end
        if db.modules.presence then return end
        if db.modules.vista.migratedToProfile then
            db.modules.presence = { enabled = false }
        else
            db.modules.presence = { enabled = (db.modules.vista.enabled ~= false) }
            db.modules.vista    = { enabled = false }
        end
    end,
})
