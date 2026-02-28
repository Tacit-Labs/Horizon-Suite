--[[
    Horizon Suite - Horizon Insight Module
    Cinematic tooltips with class colors, spec display, faction icons.
    Registers with addon:RegisterModule. Migrated from ModernTooltip.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("insight", {
    title       = "Horizon Insight",
    description = "Cinematic tooltips with class colors, spec display, and faction icons.",
    order       = 26,

    OnInit = function()
        -- Ensure module DB and defaults
        local db = _G[addon.DB_NAME]
        if not db then db = {}; _G[addon.DB_NAME] = db end
        if not db.modules then db.modules = {} end
        if not db.modules.insight then db.modules.insight = {} end

        local modDb = db.modules.insight
        if modDb.enabled == nil then modDb.enabled = true end

        -- Migrate from standalone ModernTooltipDB into active profile (once per character)
        if modDb.migratedFromModernTooltip then return end

        local src = _G.ModernTooltipDB
        if not src or type(src) ~= "table" then
            modDb.migratedFromModernTooltip = true
            return
        end

        addon.EnsureDB()
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
