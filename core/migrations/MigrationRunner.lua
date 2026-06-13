--[[
    Horizon Suite — Migration Runner
    ─────────────────────────────────────────────────────────────────────────────
    IT IS ABSOLUTELY CRITICAL THAT A MIGRATION FILE IS NEVER
    RENAMED OR MODIFIED IN ANY FUNCTIONAL WAY ONCE MERGED
    ─────────────────────────────────────────────────────────────────────────────
    Lightweight, timestamp-ordered, one-shot migration framework for HorizonDB.

    HOW TO ADD A MIGRATION
    ──────────────────────
    1. Create a new file in core/migrations/ named:
           YYYYMMDD_short_description.lua
       where YYYYMMDD is the date the migration is written. If two migrations
       share the same date, append _2, _3, etc. to disambiguate — you will
       rarely need more than one or two per day.

    2. Call addon.RegisterMigration({ … }) inside that file:

           addon.RegisterMigration({
               id     = "YYYYMMDD",          -- must be unique and sortable
               legacy = function(db) … end,  -- optional: return true if an older
                                             -- guard flag means this already ran
               run    = function(db) … end,  -- the actual data transform
           })

    3. Add the new file to HorizonSuite.toc AFTER MigrationRunner.lua and
       BEFORE core/Core.lua.

    GUARANTEES
    ──────────
    • Each migration runs exactly once: its id is written to HorizonDB._migrations
      the first time it executes and checked on every subsequent load.
    • `legacy(db)` lets existing flag-guarded migrations be grandfathered in
      without re-running their logic.
    • Migrations are sorted by id before execution, so insertion order in the
      TOC does not matter.
    • RunMigrations is idempotent within a session (in-memory guard).

    WHAT DOES NOT BELONG HERE
    ─────────────────────────
    Some transforms intentionally live outside this framework:

    • EnsureModulesDB inline transforms (HorizonSuite.lua)

    Transforms that must run before the profile sync inside EnsureModulesDB cannot
    wait for RunMigrations (which fires after EnsureProfilesAndMigrateLegacy).
    They write db._migrations[id] = true directly so the runner skips them via the
    outer ID check. Their migration files register for bookkeeping only — run() is
    never reached. Current example: 20260223_vista_presence_rename.lua.

    • Vista OnInit  (modules/Vista/VistaModule.lua)
    • Insight OnInit (modules/Insight/InsightModule.lua)

    These must write to the ACTIVE profile via addon.SetDB at module-enable time,
    because the source data (ModernMinimapDB / ModernTooltipDB) is a per-character
    SavedVariable from a standalone addon — it cannot be safely fanned out to all
    profiles from the runner.  Both are guarded by a flag on db.modules.<key>.

    • EnsureProfilesAndMigrateLegacy (core/Core.lua)
    • _profilesMigrated / _profilesValidated flags

    These are active infrastructure state for the profile system, not one-shot
    data transforms.  They run before RunMigrations and must stay where they are.
]]

local addon = _G.HorizonSuite
if not addon then return end

local registered = {}

 -- Register a migration to be executed by RunMigrations.
 -- @param m table  { id, run [, legacy] }
function addon.RegisterMigration(m)
    assert(type(m) == "table",          "RegisterMigration: expected table")
    assert(type(m.id)  == "string" and m.id  ~= "", "RegisterMigration: id required")
    assert(type(m.run) == "function",   "RegisterMigration: run function required")
    registered[#registered + 1] = m
end

 -- Run all pending migrations against the root SavedVariables table.
 -- Called once per session from addon.EnsureDB() after EnsureProfilesAndMigrateLegacy.
 -- @param db table  The raw HorizonDB SavedVariables table.
function addon.RunMigrations(db)
    if not db or addon._migrationsRan then return end
    addon._migrationsRan = true

    db._migrations = db._migrations or {}

    table.sort(registered, function(a, b) return a.id < b.id end)

    for _, m in ipairs(registered) do
        if not db._migrations[m.id] then
            -- If a legacy flag signals the migration already ran under the old
            -- system, mark it done without executing run().
            local alreadyDone = m.legacy and m.legacy(db)
            if alreadyDone then
                db._migrations[m.id] = true
            else
                -- Guard each run(): a single throwing migration must not abort the
                -- whole chain (that would silently skip every later migration on
                -- every subsequent load). Mark done only on success, so a migration
                -- fixed in a later build re-runs on the next load rather than being
                -- permanently lost.
                local ok, err = pcall(m.run, db)
                if ok then
                    db._migrations[m.id] = true
                elseif addon.Log and addon.Log.error then
                    addon.Log.error("migrations", "Migration '" .. m.id .. "' failed: " .. tostring(err))
                end
            end
        end
    end
end
