-- Horizon Suite — Migration 20260802
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Migrates the legacy Alerts style IDs and initializes shared toast styles.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

local MAP = {
    horizon = "framed",
    minimalist = "accent",
}

addon.RegisterMigration({
    id = "20260802",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                if prof.alertsToastStyle == nil and type(prof.alertsStyle) == "string" then
                    prof.alertsToastStyle = MAP[prof.alertsStyle] or "framed"
                end
                if prof.augmentToastStyle == nil then
                    -- Match alerts: first-run / unset loot style is Framed so both
                    -- stacks share chrome out of the box. Compact remains available
                    -- as an explicit picker choice.
                    prof.augmentToastStyle = "framed"
                end
            end
        end
    end,
})
