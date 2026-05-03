--[[
    Horizon Suite - Horizon Insight Module
    Cinematic tooltips with class colors, spec display, faction icons.
    Registers with addon:RegisterModule. Migrated from ModernTooltip.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("insight", {
    title       = "Horizon Insight",
    description = "Cinematic tooltips with class colors, spec display, and faction icons.",
    order       = 26,

    OnInit = function()
        -- Module on/off and db.modules.insight shape: addon:EnsureModulesDB() in HorizonSuite.lua.
        -- Here: one-time migration from standalone ModernTooltip into the active profile.
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
