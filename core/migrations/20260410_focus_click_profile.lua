-- Horizon Suite — Migration 20260410
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v4.11.0 (2026-04-10) — "Focus click profiles: Horizon+ preset"
-- Maps the old boolean useClassicClickBehaviour to the new focusClickProfile enum.
-- Profiles that had classic behaviour → "blizzardDefault"; others → "horizonPlus".
-- NormalizeFocusClickProfileToBlizzard() in FocusClickConfig.lua handles any
-- runtime coercion needed when the Blizzard lock is active.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260410",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" and prof.focusClickProfile == nil then
                local wasClassic = prof.useClassicClickBehaviour == true
                prof.focusClickProfile = wasClassic and "blizzardDefault" or "horizonPlus"
            end
        end
    end,
})
