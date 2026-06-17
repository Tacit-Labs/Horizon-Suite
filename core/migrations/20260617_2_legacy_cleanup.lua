-- Horizon Suite — Migration 20260617_2
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: Unreleased (2026-06-17) — §5.2 dead/legacy code cleanup
-- Two unrelated one-shot fixes bundled together (same pattern as 20260527_2):
--
-- 1. insightBgOpacity: very old saves stored this as a literal 0-100 value;
--    current code always writes/reads 0-1. A runtime guard in
--    modules/Insight/InsightShared.lua divided by 100 when the stored value
--    was > 1. This migration does that normalisation once so the runtime
--    guard can be deleted.
--
-- 2. vistaShowDefaultMinimapButtons: dead key, no longer read or written by
--    any current code (was a routing-table entry with no backing default or
--    consumer). Removed from existing profiles to stop it polluting saves.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260617_2",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                local a = tonumber(prof.insightBgOpacity)
                if a and a > 1 then
                    prof.insightBgOpacity = a / 100
                end
                prof.vistaShowDefaultMinimapButtons = nil
            end
        end
    end,
})
