--[[
    Horizon Suite - Meridian - Mail and queue blocks
    Blizzard: HasNewMail, GetLatestThreeSenders, hooksecurefunc (the queue block hooks Blizzard's own
    queue button so it can host it).
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

-- Queue ------------------------------------------------------------------------
-- Hosts Blizzard's own queue button, as Vista does on the minimap, so its status
-- tooltip and right-click menu keep working. Never reparented in combat.

local QUEUE_SIZE = 20
local Q = { owned = false, host = nil, internal = false, saved = nil, hooked = false }

local function QueueButton()
    return _G["QueueStatusButton"] or _G["QueueStatusMinimapButton"] or _G["MiniMapBattlefieldFrame"]
end

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) and true or false
end

local function SavePlacement(btn)
    local okP, parent = pcall(btn.GetParent, btn)
    local saved = { parent = (okP and parent) or UIParent, points = {} }
    local okN, n = pcall(btn.GetNumPoints, btn)
    for i = 1, ((okN and n) or 0) do
        local ok, p, rel, rp, x, y = pcall(btn.GetPoint, btn, i)
        if ok and p then saved.points[#saved.points + 1] = { p, rel, rp, x, y } end
    end
    local okS, w, h = pcall(btn.GetSize, btn)
    if okS then saved.w, saved.h = w, h end
    return saved
end

local function Hosted(btn)
    if not Q.host then return false end
    local okP, parent = pcall(btn.GetParent, btn)
    if not okP or parent ~= Q.host then return false end
    local okPt, _, rel = pcall(btn.GetPoint, btn, 1)
    return okPt and rel == Q.host
end

local AttachQueue

local function HookOnce(btn)
    if Q.hooked or not hooksecurefunc then return end
    Q.hooked = true
    local function Recheck()
        if Q.internal or not Q.owned then return end
        if not Hosted(btn) then
            C_Timer.After(0, function() if Q.owned and Q.host then AttachQueue(Q.host) end end)
        end
    end
    hooksecurefunc(btn, "SetParent", Recheck)
    hooksecurefunc(btn, "SetPoint", Recheck)
    local function Changed()
        if Meridian.Bar and Meridian.Bar.RequestRefresh then Meridian.Bar.RequestRefresh("queue") end
    end
    hooksecurefunc(btn, "Show", Changed)
    hooksecurefunc(btn, "Hide", Changed)
end

AttachQueue = function(host)
    local btn = QueueButton()
    if not btn or not host then return end
    if Q.owned and Q.host == host and Hosted(btn) then return end
    if InCombat() then
        if Meridian.Bar and Meridian.Bar.LayoutAfterCombat then Meridian.Bar.LayoutAfterCombat() end
        return
    end
    if not Q.saved then Q.saved = SavePlacement(btn) end
    Q.owned, Q.host, Q.internal = true, host, true
    pcall(btn.SetParent, btn, host)
    pcall(btn.ClearAllPoints, btn)
    pcall(btn.SetPoint, btn, "CENTER", host, "CENTER", 0, 0)
    pcall(btn.SetSize, btn, QUEUE_SIZE, QUEUE_SIZE)
    pcall(btn.SetFrameLevel, btn, host:GetFrameLevel() + 2)
    pcall(btn.SetIgnoreParentAlpha, btn, false)  -- Vista sets it true; on the bar it fades with the bar
    Q.internal = false
    HookOnce(btn)
end

local function DetachQueue()
    if not Q.owned then return end
    if InCombat() then
        if Meridian.Bar and Meridian.Bar.LayoutAfterCombat then Meridian.Bar.LayoutAfterCombat() end
        return
    end
    local btn = QueueButton()
    Q.owned, Q.host = false, nil
    if btn then
        local V = addon.Vista
        if V and V.ReattachQueueButton and addon:IsModuleEnabled("vista") then
            V.ReattachQueueButton()
        elseif Q.saved then
            Q.internal = true
            pcall(btn.SetParent, btn, Q.saved.parent)
            pcall(btn.ClearAllPoints, btn)
            for i = 1, #Q.saved.points do
                local p = Q.saved.points[i]
                pcall(btn.SetPoint, btn, p[1], p[2], p[3], p[4], p[5])
            end
            if Q.saved.w and Q.saved.h then pcall(btn.SetSize, btn, Q.saved.w, Q.saved.h) end
            Q.internal = false
        end
    end
    Q.saved = nil
end

Meridian.RegisterBlock({
    id = "queue",
    label = L["MERIDIAN_BLOCK_QUEUE"],
    text = function()
        local btn = QueueButton()
        if btn and btn:IsShown() then return "" end
        return nil
    end,
    tick = 1,
    width = QUEUE_SIZE,
    Attach = AttachQueue,
    Detach = DetachQueue,
    defaultSide = "right", defaultOrder = 70, defaultOn = true,
})
