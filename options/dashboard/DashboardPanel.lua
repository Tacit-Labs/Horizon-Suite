--[[
    Horizon Suite - Dashboard Options Panel
    Entry: slash commands, ShowDashboard, lazy init via options/dashboard/DashboardFrame.lua.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local f = _G.HorizonSuiteDashboard

addon.ShowDashboard = function()
    if SlashCmdList["HSDASH"] then SlashCmdList["HSDASH"]("") end
end
_G.HorizonSuite_ShowDashboard = addon.ShowDashboard

SLASH_HSDASH1 = "/hsd"
SLASH_HSDASH2 = "/dash"
SlashCmdList["HSDASH"] = function(msg)
    f = f or _G.HorizonSuiteDashboard
    if f and f:IsShown() then
        f:Hide()
    else
        if not f then
            if addon.Dashboard_BuildMainFrame then
                f = addon.Dashboard_BuildMainFrame()
            end
        end
        if f and f.ShowDashboard and f.ShowWelcome then
            if addon.GetDB and not addon.GetDB("dashboardWelcomeSeen", false) then
                f.ShowWelcome()
            else
                f.ShowDashboard()
            end
        elseif f and f.ShowDashboard then
            f.ShowDashboard()
        end
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        if addon.DashboardPreview and addon.DashboardPreview.InitDashboard then
            addon.DashboardPreview.InitDashboard(f)
        end
        if f then f:Show() end
    end
end
