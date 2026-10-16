--[[
    Horizon Suite - Meridian - Clock block
    Blizzard: date, GetGameTime, C_DateAndTime, SecondsToTime, TimeManagerFrame, C_AddOns.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local function ClockText()
    local use24 = Meridian.Setting("meridianClock24Hour") and true or false
    if Meridian.Setting("meridianClockLocal") ~= false then
        local t = date("*t")
        return F.Clock(t.hour, t.min, use24)
    end
    if not GetGameTime then return nil end
    local h, m = GetGameTime()
    if h == nil then return nil end
    return F.Clock(h, m, use24)
end

-- Same chain as Vista's clock (VistaCore.lua CreateDecor); loads the time manager on demand.
local function ToggleStopwatch()
    if not TimeManagerFrame and C_AddOns and C_AddOns.LoadAddOn then
        pcall(C_AddOns.LoadAddOn, "Blizzard_TimeManager")
    end
    if TimeManagerFrame then
        if TimeManagerFrame:IsShown() then TimeManagerFrame:Hide() else TimeManagerFrame:Show() end
    elseif type(ToggleTimeManager) == "function" then
        ToggleTimeManager()
    end
end

local function AddReset(tooltip, label, seconds)
    if type(seconds) ~= "number" or seconds <= 0 then return end
    local text = (SecondsToTime and SecondsToTime(seconds, true)) or (math.floor(seconds / 3600) .. "h")
    tooltip:AddDoubleLine(label, text, 0.7, 0.7, 0.7, 1, 1, 1)
end

Meridian.RegisterBlock({
    id = "clock",
    label = L["MERIDIAN_BLOCK_CLOCK"],
    icon = Meridian.Glyph("clock"),
    text = ClockText,
    tick = 1,
    OnClick = ToggleStopwatch,
    OnTooltipShow = function(tooltip)
        local D = C_DateAndTime
        if D and D.GetSecondsUntilDailyReset then AddReset(tooltip, L["MERIDIAN_DAILY_RESET"], D.GetSecondsUntilDailyReset()) end
        if D and D.GetSecondsUntilWeeklyReset then AddReset(tooltip, L["MERIDIAN_WEEKLY_RESET"], D.GetSecondsUntilWeeklyReset()) end
        tooltip:AddLine(L["MERIDIAN_CLICK_STOPWATCH"], 0.6, 0.6, 0.6)
    end,
    defaultSide = "centre", defaultOrder = 10, defaultOn = true,
})
