-- Horizon Suite — Migration 20260602
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v5.0.2 (2026-06-02) — "feat(augment): mini-module architecture"
-- The Self Highlight enable gate moved from selfHighlightEnabled (inner toggle,
-- default false) to augmentSelfHighlightEnabled (sidebar pill, default false).
-- Without this migration, users who had Self Highlight on will silently find
-- it no longer activates because the new code reads the pill key, not the old one.
-- We only write the pill if it has never been saved (nil), so a user who has
-- already seen the new UI and toggled the pill explicitly is not overwritten.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

local function migrate(profile)
    if type(profile) ~= "table" then return end
    if profile.augmentSelfHighlightEnabled == nil and profile.selfHighlightEnabled == true then
        profile.augmentSelfHighlightEnabled = true
    end
end

addon.RegisterMigration({
    id  = "20260602",
    run = function(db)
        migrate(db)
        if type(db.profiles) == "table" then
            for _, profile in pairs(db.profiles) do
                migrate(profile)
            end
        end
    end,
})
