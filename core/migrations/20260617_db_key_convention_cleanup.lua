-- Horizon Suite — Migration 20260617
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: Unreleased (2026-06-17) — DB key naming convention foundation pass
-- A handful of keys violated the <module><Key> camelCase convention (no module
-- prefix, or snake_case). This is a targeted cleanup, not a full audit — see
-- core/Config.lua's core-owned key registry and options/OptionsData.lua's
-- convention comment for what is and isn't in scope.
--
-- Old keys       →  New keys (all stored per-profile)
--   showWorldQuests →  focusShowWorldQuests   (Focus-owned, was missing its prefix)
--   rs_color        →  rsColor                (RareScanner integration colour, snake_case)
--   sd_color        →  sdColor                (SilverDragon integration colour, snake_case)
--
-- fontPath is intentionally NOT renamed here — it is a separate legacy
-- root-level compatibility key (see options/OptionsData.lua) and a cross-module
-- "Global Font" fallback sentinel; renaming it is out of scope for this pass.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260617",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                if prof.showWorldQuests ~= nil then
                    if prof.focusShowWorldQuests == nil then
                        prof.focusShowWorldQuests = prof.showWorldQuests
                    end
                    prof.showWorldQuests = nil
                end
                if prof.rs_color ~= nil then
                    if prof.rsColor == nil then
                        prof.rsColor = prof.rs_color
                    end
                    prof.rs_color = nil
                end
                if prof.sd_color ~= nil then
                    if prof.sdColor == nil then
                        prof.sdColor = prof.sd_color
                    end
                    prof.sd_color = nil
                end
            end
        end
    end,
})
