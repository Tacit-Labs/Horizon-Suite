--[[
    Horizon Suite - Dashboard shared build context (mutable table populated during lazy frame init).
    Fields assigned from Dashboard_BuildMainFrame: frame, layout (contentWidth, dashScrollTopOffset, dashScrollTopOffsetModule, viewWidth, …).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.DashboardCtx = addon.DashboardCtx or {}
