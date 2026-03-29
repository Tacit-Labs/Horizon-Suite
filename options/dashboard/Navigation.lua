--[[
    Horizon Suite - Dashboard navigation (logical module).
    Search EditBox + dropdown chrome, patch notes view chrome, CrossfadeTo / ShowDashboard / back buttons,
    and f.ShowPatchNotes are built in options/dashboard/DashboardFrame.lua.
    Search debounce + results + FilterBySearch: options/dashboard/DetailView.lua (addon.DashboardDetailView_Init).
    Home tiles + Welcome: options/dashboard/HomeWelcome.lua.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end
