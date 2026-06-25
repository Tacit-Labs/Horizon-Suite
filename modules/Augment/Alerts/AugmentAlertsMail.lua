--[[
    Horizon Suite - Augment / Alerts - Mail
    Fires once per "new mail" transition via HasNewMail(), so it doesn't
    repeat on every MAIL_INBOX_UPDATE while the mailbox is open.
]]

local addon = _G.HorizonSuite
local L = addon.L
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Mail = M

local hadMail = false

function M.SetBaseline()
    hadMail = HasNewMail() and true or false
end

function M.CheckAndNotify()
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsMailEnabled", D.alertsMailEnabled) then return end

    local has = HasNewMail() and true or false
    if has and not hadMail then
        A.Enqueue("MAIL", L["ALERTS_MAIL_TITLE"], L["ALERTS_MAIL_BODY"])
    end
    hadMail = has
end
