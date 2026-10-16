--[[
    Horizon Suite - Meridian - Mail and queue blocks
    Blizzard: HasNewMail, GetLatestThreeSenders. (The queue block is added in Task 7.)
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local L = addon.L

Meridian.RegisterBlock({
    id = "mail",
    label = L["MERIDIAN_BLOCK_MAIL"],
    icon = Meridian.Glyph("mail"),
    iconAccent = true,
    text = function()
        if HasNewMail and HasNewMail() then return "" end
        return nil
    end,
    events = { "UPDATE_PENDING_MAIL", "PLAYER_ENTERING_WORLD", "MAIL_CLOSED", "MAIL_INBOX_UPDATE" },
    OnTooltipShow = function(tooltip)
        local a, b, c
        if GetLatestThreeSenders then a, b, c = GetLatestThreeSenders() end
        if a then
            tooltip:AddLine(L["MERIDIAN_MAIL_FROM"], 0.7, 0.7, 0.7)
            tooltip:AddLine(a, 1, 1, 1)
            if b then tooltip:AddLine(b, 1, 1, 1) end
            if c then tooltip:AddLine(c, 1, 1, 1) end
        else
            tooltip:AddLine(L["MERIDIAN_MAIL_UNREAD"], 0.7, 0.7, 0.7)
        end
    end,
    defaultSide = "right", defaultOrder = 60, defaultOn = true,
})
