--[[
Migration: v3.1.0 (2026-02-21) 
 ─────────────────────────────────────────────────────────────────────────────
 CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
 ─────────────────────────────────────────────────────────────────────────────
 Add Combat Visibility options (Show/Fade/Hide)
    - Convert legacy boolean `hideInCombat` toggle to combatVisibility enum
    - Root-level: `hideInCombat` used as a fallback if no option was previously set.
]]--

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

addon.RegisterMigration({
    id = "20260221",

    run = function(db)
        local rootLegacy = db.hideInCombat
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" and prof.combatVisibility == nil then
                local legacyHide = prof.hideInCombat
                if legacyHide == nil then legacyHide = rootLegacy end
                if legacyHide ~= nil then
                    prof.combatVisibility = legacyHide and "hide" or "show"
                end
            end
        end
    end,
})


--[[
Migration: v3.1.0 (2026-02-21) 
 ─────────────────────────────────────────────────────────────────────────────
 CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
 ─────────────────────────────────────────────────────────────────────────────
 Add Combat Visibility options (Show/Fade/Hide)
    - Convert legacy boolean `hideInCombat` toggle to combatVisibility enum
    - Root-level: `hideInCombat` used as a fallback if no option was previously set.
]]--