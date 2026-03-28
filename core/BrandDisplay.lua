--[[
    Horizon Suite — BrandDisplay
    Fixed English product and module display names (not localised).
    UI descriptions and sentences stay in addon.L; see TRANSLATING.md.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.BrandDisplay = {
    optionsTitle = "HORIZON SUITE",
    productName = "Horizon Suite",
    horizonInsight = "Horizon Insight",
    module = {
        axis = "Axis",
        focus = "Focus",
        presence = "Presence",
        vista = "Vista",
        insight = "Insight",
        cache = "Cache",
        essence = "Essence",
        meridian = "Meridian",
    },
}
