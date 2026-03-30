--[[
    Horizon Suite - Dashboard shared build context (mutable table populated during lazy frame init).
    Fields assigned from Dashboard_BuildMainFrame: frame, layout (contentWidth, dashScrollTopOffset, viewWidth, …).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.DashboardCtx = addon.DashboardCtx or {}
