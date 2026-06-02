-- Horizon Suite — Migration 20260406
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v4.9.0 (2026-04-06) — "Quest type icons default on"
-- showQuestTypeIcons was added as opt-in; flip all stored profiles to true
-- so existing users receive it automatically on upgrade.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260406",

    legacy = function(db) return db._migratedShowQuestTypeIconsDefaultOn end,

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                prof.showQuestTypeIcons = true
            end
        end
    end,
})
