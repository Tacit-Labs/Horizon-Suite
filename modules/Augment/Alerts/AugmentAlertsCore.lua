--[[
    Horizon Suite - Augment / Alerts - Core
    Frame pool, stacking, and fade animation for Alerts toasts. Visual style
    is deliberately much simpler than the Loot toast pool
    (modules/Augment/LootFrame/AugmentCore.lua): one icon + title/body line,
    no item-link stacking/merging, since these are status alerts rather than
    loot events.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local function S(v)
    local D = addon.AUGMENT_DEFAULTS
    local scale = tonumber(A.GetDB("alertsScale", D.alertsScale)) or D.alertsScale
    return v * scale
end

A.POOL_SIZE    = 6
A.WIDTH        = 280
A.HEIGHT       = 44
A.ICON_SIZE    = 32
A.LINE_SPACING = 6
A.LINE_HEIGHT  = A.HEIGHT + A.LINE_SPACING
A.ENTRANCE_DUR = 0.25
A.EXIT_DUR     = 0.4
A.SLIDE_DIST   = 16
A.DEFAULT_HOLD = 4.0
A.NUDGE_SPEED  = 10

local pool = {}
local activeCount = 0
local Frame
local framesCreated = false
local AlertsFontObj

local function GetFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local D = addon.AUGMENT_DEFAULTS
    local raw = A.GetDB("alertsFontPath", D.alertsFontPath)
    if raw == "__global__" or raw == nil or raw == "" then
        raw = (addon.GetDB and addon.GetDB("fontPath", nil)) or nil
    end
    if not raw or raw == "" or raw == "__global__" then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
    end
    if addon.ResolveFontPath then
        local resolved = addon.ResolveFontPath(raw)
        if resolved and resolved ~= "" then return resolved end
    end
    return raw
end
A.GetFontPath = GetFontPath

local function UpdateFontObject()
    if not AlertsFontObj then return end
    AlertsFontObj:SetFont(GetFontPath(), S(13), "OUTLINE")
end

local function Ease(t) return 1 - (1 - t) * (1 - t) end

function A.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, y = A.GetPosition()
    point    = point    or A.DEFAULT_ANCHOR
    relPoint = relPoint or A.DEFAULT_ANCHOR
    x = tonumber(x) or A.DEFAULT_X
    y = tonumber(y) or A.DEFAULT_Y
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, x, y)
end

local function CreateEntry(parent)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(S(A.WIDTH), S(A.HEIGHT))
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    f:SetBackdropColor(0, 0, 0, 0.75)

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(S(A.ICON_SIZE), S(A.ICON_SIZE))
    icon:SetPoint("LEFT", f, "LEFT", 8, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(AlertsFontObj)
    title:SetJustifyH("LEFT")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    title:SetPoint("RIGHT", f, "RIGHT", -8, 0)
    title:SetWordWrap(false)

    local body = f:CreateFontString(nil, "OVERLAY")
    body:SetFontObject(AlertsFontObj)
    body:SetTextColor(0.85, 0.85, 0.85, 1)
    body:SetJustifyH("LEFT")
    body:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 2)
    body:SetPoint("RIGHT", f, "RIGHT", -8, 0)
    body:SetWordWrap(false)

    f:SetAlpha(0)
    f:Hide()

    return {
        frame = f, icon = icon, title = title, body = body,
        active = false, elapsed = 0, holdDur = A.DEFAULT_HOLD,
        stackY = 0, smoothY = 0,
    }
end

-- Lazy init, called once from Enable() (DB is ready at that point).
function A.InitFrames()
    if framesCreated then return end
    framesCreated = true

    Frame = CreateFrame("Frame", "HorizonSuiteAlertsAnchor", UIParent)
    Frame:SetSize(S(A.WIDTH), S(A.LINE_HEIGHT))
    A.ApplyStoredAnchor(Frame)
    Frame:Hide()
    Frame:SetClampedToScreen(true)

    AlertsFontObj = _G["HorizonSuiteAlertsFont"] or CreateFont("HorizonSuiteAlertsFont")
    UpdateFontObject()

    for i = 1, A.POOL_SIZE do
        pool[i] = CreateEntry(Frame)
    end

    Frame:SetScript("OnUpdate", function(self, dt)
        if activeCount == 0 then
            self:Hide()
            return
        end
        for i = 1, A.POOL_SIZE do
            if pool[i].active then A.UpdateEntry(pool[i], dt) end
        end
    end)

    A.Frame = Frame
end

local function GetPoolCap()
    local D = addon.AUGMENT_DEFAULTS
    return math.max(1, math.min(A.POOL_SIZE, tonumber(A.GetDB("alertsMaxVisible", D.alertsMaxVisible)) or D.alertsMaxVisible))
end

local function AcquireEntry()
    local cap = GetPoolCap()
    for i = 1, cap do
        if not pool[i].active then return pool[i] end
    end
    -- Pool full within the visible cap: evict the entry with the least time remaining.
    local best, bestRemaining = 1, math.huge
    for i = 1, cap do
        local remaining = pool[i].holdDur - pool[i].elapsed
        if remaining < bestRemaining then
            best, bestRemaining = i, remaining
        end
    end
    local entry = pool[best]
    entry.frame:Hide()
    entry.frame:SetAlpha(0)
    entry.active = false
    activeCount = activeCount - 1
    return entry
end

function A.UpdateEntry(entry, dt)
    if not entry.active then return end
    entry.elapsed = entry.elapsed + dt
    local t = entry.elapsed
    local entEnd  = A.ENTRANCE_DUR
    local holdEnd = entEnd + entry.holdDur
    local fadeEnd = holdEnd + A.EXIT_DUR
    local alpha, slideX

    if t < entEnd then
        local p = Ease(t / A.ENTRANCE_DUR)
        alpha  = p
        slideX = A.SLIDE_DIST * (1 - p)
    elseif t < holdEnd then
        alpha, slideX = 1, 0
    elseif t < fadeEnd then
        alpha  = 1 - Ease((t - holdEnd) / A.EXIT_DUR)
        slideX = 0
    else
        entry.active = false
        entry.frame:Hide()
        entry.frame:SetAlpha(0)
        activeCount = activeCount - 1
        return
    end

    local gap = entry.stackY - entry.smoothY
    entry.smoothY = math.abs(gap) > 0.5 and (entry.smoothY + gap * math.min(A.NUDGE_SPEED * dt, 1)) or entry.stackY

    entry.frame:SetAlpha(alpha)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("TOP", Frame, "TOP", slideX, -entry.smoothY)
end

-- Show one toast. Only called from AugmentAlertsQueue.lua's internal emit()
-- so combat deferral and sound dispatch always happen first.
-- @param kind string
-- @param title string
-- @param body string
-- @param meta table|nil  meta.duration overrides the default hold time
function A.ShowToast(kind, title, body, meta)
    if not addon:IsModuleEnabled("augment") then return end
    if not framesCreated then return end

    local entry = AcquireEntry()

    for i = 1, A.POOL_SIZE do
        if pool[i].active then
            pool[i].stackY = pool[i].stackY + S(A.LINE_HEIGHT)
        end
    end

    local color = A.KIND_COLORS[kind] or { 1, 1, 1 }
    entry.icon:SetTexture(A.KIND_ICONS[kind])
    entry.title:SetText(title)
    entry.title:SetTextColor(color[1], color[2], color[3], 1)
    entry.body:SetText(body)
    entry.frame:SetBackdropBorderColor(color[1], color[2], color[3], 0.7)

    entry.active  = true
    entry.elapsed = 0
    entry.holdDur = tonumber(meta and meta.duration) or A.DEFAULT_HOLD
    entry.stackY  = 0
    entry.smoothY = 0

    entry.frame:SetAlpha(0)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("TOP", Frame, "TOP", A.SLIDE_DIST, 0)
    entry.frame:Show()
    Frame:Show()

    activeCount = activeCount + 1
end

function A.ClearActiveToasts()
    for i = 1, A.POOL_SIZE do
        local e = pool[i]
        if e and e.active then
            e.active = false
            e.frame:Hide()
            e.frame:SetAlpha(0)
        end
    end
    activeCount = 0
    if Frame then Frame:Hide() end
end

-- Re-apply scale and font to all pool entries. Called when the Alerts scale
-- or font option changes.
function A.ApplyScale()
    if not framesCreated then return end
    UpdateFontObject()
    Frame:SetSize(S(A.WIDTH), S(A.LINE_HEIGHT))
    for i = 1, A.POOL_SIZE do
        local e = pool[i]
        e.frame:SetSize(S(A.WIDTH), S(A.HEIGHT))
        e.icon:SetSize(S(A.ICON_SIZE), S(A.ICON_SIZE))
    end
end

function A.RestoreSavedPosition()
    if not framesCreated then return end
    A.ApplyStoredAnchor(Frame)
end
