--[[
    Horizon Suite - Horizon Insight Module
    Cinematic tooltips with class colors, spec display, faction icons.
    Registers with addon:RegisterModule. Migrated from ModernTooltip.
]]

local addon = _G.HorizonSuite

addon:RegisterModule("insight", {
    title       = "Horizon Insight",
    description = "Cinematic tooltips with class colors, spec display, and faction icons.",
    order       = 26,

    OnInit = function()
        -- Module on/off and db.modules.insight shape: addon:EnsureModulesDB() in HorizonSuite.lua.
        --
        -- One-time migration: copy anchor/position settings from the legacy standalone
        -- ModernTooltipDB SavedVariable into the active Horizon profile via addon.SetDB.
        --
        -- Why this lives here instead of core/migrations/:
        --   ModernTooltipDB is a single global written by the old standalone addon; it
        --   belongs to a specific character, not all profiles.  Iterating all profiles from
        --   the migration runner would incorrectly stamp every profile with the same values.
        --   Running here (at module enable time) ensures we write to the correct active
        --   profile for the character that actually used the old addon.
        --   Guard: modDb.migratedFromModernTooltip (on db.modules.insight) — set on first run.
        addon.EnsureDB()
        local db = _G[addon.DATABASE]
        local modDb = db and db.modules and db.modules.insight
        if not modDb then return end

        if modDb.migratedFromModernTooltip then return end

        local src = _G.ModernTooltipDB
        if not src or type(src) ~= "table" then
            modDb.migratedFromModernTooltip = true
            return
        end

        local profile = addon.GetActiveProfile()
        if not profile then
            modDb.migratedFromModernTooltip = true
            return
        end

        if src.anchorMode ~= nil then
            addon.SetDB("insightAnchorMode", src.anchorMode)
        end
        if src.fixedPoint ~= nil then
            addon.SetDB("insightFixedPoint", src.fixedPoint)
        end
        if src.fixedX ~= nil then
            addon.SetDB("insightFixedX", src.fixedX)
        end
        if src.fixedY ~= nil then
            addon.SetDB("insightFixedY", src.fixedY)
        end

        modDb.migratedFromModernTooltip = true
    end,

    OnEnable = function()
        if addon.Insight and addon.Insight.Init then
            addon.Insight.Init()
        end
    end,

    OnDisable = function()
        if addon.Insight and addon.Insight.Disable then
            addon.Insight.Disable()
        end
    end,
})
