--[[
    Horizon Suite - Cache - Core
    Frame, pool, animation engine, ShowToast. Blizzard: CreateFrame, C_Timer.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Cache then return end

local Y = addon.Cache
local y = addon.cache

local function easeOut(t)  return 1 - (1 - t) * (1 - t) end
local function easeIn(t)   return t * t end
local function easeInOut(t)
    if t < 0.5 then return 2 * t * t end
    return 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2
end

-- ============================================================================
-- FRAME & POOL
-- ============================================================================

local CACHE_ANCHOR_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

--- Apply stored anchor position to frame.
--- @param frame table Frame to position
function Y.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, yPos = Y.GetPosition()
    point = point or Y.DEFAULT_ANCHOR
    relPoint = relPoint or Y.DEFAULT_ANCHOR
    x = tonumber(x) or Y.DEFAULT_X
    yPos = tonumber(yPos) or Y.DEFAULT_Y
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, x, yPos)
end

local Frame = CreateFrame("Frame", nil, UIParent)
do
    local S = function(v) return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "cache") end
    Frame:SetSize(S(Y.TOTAL_WIDTH), S(Y.LINE_HEIGHT) * Y.POOL_SIZE)
end
Y.ApplyStoredAnchor(Frame)
Frame:Hide()

Frame:SetMovable(true)
Frame:EnableMouse(true)
Frame:RegisterForDrag("LeftButton")
Frame:SetClampedToScreen(true)

local function SaveFramePosition()
    local point, _, relPoint, x, yPos = Frame:GetPoint()
    if not point or not relPoint then return end
    Y.SavePosition(point, relPoint, math.floor(x + 0.5), math.floor(yPos + 0.5))
end

Frame:SetScript("OnDragStart", function(self)
    if InCombatLockdown() then return end
    self:StartMoving()
end)

Frame:SetScript("OnDragStop", function(self)
    if InCombatLockdown() then return end
    self:StopMovingOrSizing()
    SaveFramePosition()
end)

-- Edit overlay
local editOverlay = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
editOverlay:SetAllPoints(Frame)
editOverlay:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
})
editOverlay:SetBackdropColor(0, 0, 0, 0.5)
editOverlay:SetBackdropBorderColor(0.4, 0.8, 1.0, 0.8)
editOverlay:SetFrameLevel(Frame:GetFrameLevel() + 10)
editOverlay:EnableMouse(false)

local editTitle = editOverlay:CreateFontString(nil, "OVERLAY")
editTitle:SetFont(Y.FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(14, "cache"), "OUTLINE")
editTitle:SetTextColor(0.4, 0.8, 1.0, 1)
editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
editTitle:SetText("LOOT TOAST AREA")

local editHint = editOverlay:CreateFontString(nil, "OVERLAY")
editHint:SetFont(Y.FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(10, "cache"), "OUTLINE")
editHint:SetTextColor(0.7, 0.7, 0.7, 1)
editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
editHint:SetText("Drag to reposition  |  /h cache edit to hide")

editOverlay:Hide()

-- ============================================================================
-- ANCHOR FRAME
-- ============================================================================

local anchorFrame = CreateFrame("Frame", "HorizonSuiteCacheAnchor", UIParent, "BackdropTemplate")
anchorFrame:SetSize(160, 40)
anchorFrame:SetPoint(Y.DEFAULT_ANCHOR, UIParent, Y.DEFAULT_ANCHOR, Y.DEFAULT_X, Y.DEFAULT_Y)
anchorFrame:SetBackdrop(CACHE_ANCHOR_BACKDROP)
anchorFrame:SetBackdropColor(0, 0, 0, 0.85)
anchorFrame:SetBackdropBorderColor(0.50, 0.70, 1.0, 0.60)
anchorFrame:SetMovable(true)
anchorFrame:EnableMouse(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetFrameStrata("DIALOG")
anchorFrame:Hide()

local anchorLabel = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorLabel:SetFont(Y.FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(12, "cache"), "OUTLINE")
anchorLabel:SetPoint("CENTER")
anchorLabel:SetTextColor(0.50, 0.70, 1.0, 1)
anchorLabel:SetText("LOOT TOAST ANCHOR")

local anchorHint = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorHint:SetFont(Y.FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(10, "cache"), "OUTLINE")
anchorHint:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -4)
anchorHint:SetTextColor(0.60, 0.60, 0.60, 1)
anchorHint:SetText("Drag to move · Right-click to confirm")

local function ApplyCacheClassChrome()
    local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("cache")
    local br, bg, bb, ba = 0.50, 0.70, 1.0, 0.60
    local er, eg, eb, ea = 0.4, 0.8, 1.0, 0.8
    if ycc then
        br, bg, bb = ycc[1], ycc[2], ycc[3]
        er, eg, eb = ycc[1], ycc[2], ycc[3]
    end
    anchorFrame:SetBackdropBorderColor(br, bg, bb, ba)
    anchorLabel:SetTextColor(br, bg, bb, 1)
    editOverlay:SetBackdropBorderColor(er, eg, eb, ea)
    editTitle:SetTextColor(er, eg, eb, 1)
end

Y.ApplyCacheClassChrome = ApplyCacheClassChrome

anchorFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then self:StartMoving() end
end)
anchorFrame:SetScript("OnDragStop", function(self)
    if InCombatLockdown() then return end
    self:StopMovingOrSizing()
    local point, _, relPoint, x, yPos = self:GetPoint()
    Y.SavePosition(point, relPoint, math.floor(x + 0.5), math.floor(yPos + 0.5))
    Y.ApplyStoredAnchor(Frame)
end)
anchorFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        self:Hide()
        local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end
        HSPrint("Cache: Position saved.")
    end
end)

local function ShowAnchorFrame()
    if InCombatLockdown() then return end
    Y.ApplyStoredAnchor(anchorFrame)
    anchorFrame:Show()
    local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end
    HSPrint("Cache: Drag the anchor, then right-click to confirm.")
end

local function HideAnchorFrame()
    anchorFrame:Hide()
end

function Y.ToggleAnchorFrame()
    if anchorFrame:IsShown() then
        HideAnchorFrame()
        local HSPrint = addon.HSPrint or function(msg) print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or "")) end
        HSPrint("Cache: Anchor hidden. Position saved.")
    else
        ShowAnchorFrame()
    end
end

function Y.HideAnchorFrame()
    HideAnchorFrame()
end

function Y.ApplyCacheOptions()
    ApplyCacheClassChrome()
    if anchorFrame:IsShown() then
        Y.ApplyStoredAnchor(anchorFrame)
    end
    Y.ApplyStoredAnchor(Frame)
end

local function CreateToastEntry(parent)
    local S = function(v) return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "cache") end
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(S(Y.TOTAL_WIDTH), S(Y.ENTRY_HEIGHT))

    local iconBg = f:CreateTexture(nil, "BORDER")
    iconBg:SetSize(S(Y.ICON_SIZE + Y.BORDER_PAD * 2), S(Y.ICON_SIZE + Y.BORDER_PAD * 2))
    iconBg:SetPoint("LEFT", f, "LEFT", 0, 0)
    iconBg:SetColorTexture(1, 1, 1, 0.8)

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(S(Y.ICON_SIZE), S(Y.ICON_SIZE))
    icon:SetPoint("CENTER", iconBg, "CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local shine = f:CreateTexture(nil, "OVERLAY")
    shine:SetSize(S(Y.ICON_SIZE + 8), S(Y.ICON_SIZE + 8))
    shine:SetPoint("CENTER", iconBg, "CENTER", 0, 0)
    shine:SetTexture("Interface\\Cooldown\\star4")
    shine:SetBlendMode("ADD")
    shine:SetAlpha(0)
    shine:Hide()

    local shadow = f:CreateFontString(nil, "BORDER")
    shadow:SetFont(Y.FONT_PATH, S(Y.FONT_SIZE), "OUTLINE")
    shadow:SetTextColor(0, 0, 0, 0.7)
    shadow:SetJustifyH("LEFT")
    shadow:SetPoint("LEFT", iconBg, "RIGHT", S(Y.ICON_GAP) + 1, -1)
    shadow:SetPoint("RIGHT", f, "RIGHT", 1, -1)
    shadow:SetWordWrap(false)

    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetFont(Y.FONT_PATH, S(Y.FONT_SIZE), "OUTLINE")
    text:SetTextColor(1, 1, 1, 1)
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", iconBg, "RIGHT", S(Y.ICON_GAP), 0)
    text:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    text:SetWordWrap(false)

    f:SetAlpha(0)
    f:Hide()

    return {
        frame    = f,
        iconBg   = iconBg,
        icon     = icon,
        shine    = shine,
        shadow   = shadow,
        text     = text,
        active   = false,
        elapsed  = 0,
        holdDur  = Y.HOLD_ITEM,
        quality  = nil,
        stackY   = 0,
        smoothY  = 0,
        driftY   = 0,
    }
end

for i = 1, Y.POOL_SIZE do
    y.pool[i] = CreateToastEntry(Frame)
end

-- ============================================================================
-- POOL & ANIMATION
-- ============================================================================

local function AcquireEntry()
    for i = 1, Y.POOL_SIZE do
        if not y.pool[i].active then return y.pool[i] end
    end
    local best, bestT = 1, 0
    for i = 1, Y.POOL_SIZE do
        if y.pool[i].elapsed > bestT then
            best  = i
            bestT = y.pool[i].elapsed
        end
    end
    local entry = y.pool[best]
    entry.frame:Hide()
    entry.frame:SetAlpha(0)
    entry.active = false
    y.activeCount = y.activeCount - 1
    return entry
end

local function UpdateEntry(entry, dt)
    if not entry.active then return end

    entry.elapsed = entry.elapsed + dt
    local t = entry.elapsed

    local isEpicOrLegendary = (entry.quality == 4 or entry.quality == 5)
    local entranceDur = Y.ENTRANCE_DUR
    local popPeak = 1
    if entry.quality == 5 then
        entranceDur = Y.ENTRANCE_DUR_LEGENDARY
        popPeak = Y.POP_SCALE_PEAK_LEGEND
    elseif entry.quality == 4 then
        entranceDur = Y.ENTRANCE_DUR_EPIC
        popPeak = Y.POP_SCALE_PEAK_EPIC
    end

    local entEnd  = entranceDur
    local holdEnd = entEnd + entry.holdDur
    local fadeEnd = holdEnd + Y.EXIT_DUR

    local alpha, slideX, scale

    if t < entEnd then
        local p = easeOut(t / entranceDur)
        alpha  = p
        slideX = Y.SLIDE_DIST * (1 - p)
        if isEpicOrLegendary then
            local settleStart = 1 - Y.POP_SETTLE_FRAC
            if p <= settleStart then
                local q = p / settleStart
                scale = Y.POP_SCALE_START + (popPeak - Y.POP_SCALE_START) * easeOut(q)
            else
                local q = (p - settleStart) / Y.POP_SETTLE_FRAC
                scale = popPeak + (1 - popPeak) * easeInOut(q)
            end
        else
            scale = 1
        end

    elseif t < holdEnd then
        alpha  = 1
        slideX = 0
        scale  = 1

    elseif t < fadeEnd then
        local p = easeIn((t - holdEnd) / Y.EXIT_DUR)
        alpha  = 1 - p
        slideX = 0
        scale  = 1
        entry.driftY = entry.driftY + (Y.EXIT_DRIFT / Y.EXIT_DUR) * dt

    else
        entry.active = false
        entry.frame:Hide()
        entry.frame:SetAlpha(0)
        entry.frame:SetScale(1)
        if entry.shine then entry.shine:Hide() end
        if entry.iconBg then entry.iconBg:SetAlpha(0.8) end
        y.activeCount = y.activeCount - 1
        return
    end

    local cacheCC = addon.GetModuleClassColor and addon.GetModuleClassColor("cache")
    if entry.shine and (entry.quality == 5 or (entry.quality == 4 and cacheCC)) then
        if t < Y.FLASH_DUR then
            entry.shine:Show()
            entry.shine:SetAlpha(1 - easeOut(t / Y.FLASH_DUR))
        else
            entry.shine:Hide()
        end
    end

    if isEpicOrLegendary and t >= entEnd and t < holdEnd and entry.iconBg then
        local pulse = 0.5 + 0.5 * math.sin(t * Y.BORDER_PULSE_SPEED * 6.283185307)
        local glowAlpha = 1 - Y.BORDER_PULSE_ALPHA + Y.BORDER_PULSE_ALPHA * pulse
        entry.iconBg:SetAlpha(glowAlpha)
    elseif entry.iconBg then
        entry.iconBg:SetAlpha(0.8)
    end

    local gap = entry.stackY - entry.smoothY
    if math.abs(gap) > 0.5 then
        entry.smoothY = entry.smoothY + gap * math.min(Y.NUDGE_SPEED * dt, 1)
    else
        entry.smoothY = entry.stackY
    end

    entry.frame:SetAlpha(alpha)
    entry.frame:SetScale(scale or 1)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT",
                         slideX, entry.smoothY + entry.driftY)
end

Frame:SetScript("OnUpdate", function(self, dt)
    if y.activeCount == 0 then
        if not y.editMode then self:Hide() end
        return
    end
    for i = 1, Y.POOL_SIZE do
        if y.pool[i].active then
            UpdateEntry(y.pool[i], dt)
        end
    end
    if y.activeCount == 0 and not y.editMode then self:Hide() end
end)

-- ============================================================================
-- SHOW TOAST & HELPERS
-- ============================================================================

function Y.ShowToast(data)
    if not addon:IsModuleEnabled("cache") or not data then return end

    local entry = AcquireEntry()

    local S = function(v) return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "cache") end
    for i = 1, Y.POOL_SIZE do
        if y.pool[i].active then
            y.pool[i].stackY = y.pool[i].stackY + S(Y.LINE_HEIGHT)
        end
    end

    entry.icon:SetTexture(data.icon)
    entry.iconBg:SetColorTexture(data.br, data.bg, data.bb, 0.8)

    entry.text:SetText(data.text)
    entry.text:SetTextColor(data.r, data.g, data.b, 1)
    entry.shadow:SetText(data.text)

    entry.active   = true
    entry.elapsed  = 0
    entry.holdDur  = data.holdDur
    entry.quality  = data.quality
    entry.stackY   = 0
    entry.smoothY  = 0
    entry.driftY   = 0

    entry.frame:SetAlpha(0)
    entry.frame:SetScale(1)
    entry.shine:SetAlpha(0)
    entry.shine:Hide()
    local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("cache")
    if ycc then
        entry.shine:SetVertexColor(ycc[1], ycc[2], ycc[3])
    else
        entry.shine:SetVertexColor(1, 1, 1)
    end
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", Y.SLIDE_DIST, 0)
    entry.frame:Show()
    Frame:Show()

    if data.quality == 5 and Y.SOUND_LEGENDARY and PlaySound then
        pcall(PlaySound, Y.SOUND_LEGENDARY)
    elseif data.quality == 4 and Y.SOUND_EPIC and PlaySound then
        pcall(PlaySound, Y.SOUND_EPIC)
    end

    if data.quality == 4 or data.quality == 5 then
        if Y.KillDynamicItemRevealPopup then
            C_Timer.After(0.1, function() Y.KillDynamicItemRevealPopup() end)
            C_Timer.After(0.4, function() Y.KillDynamicItemRevealPopup() end)
        end
    end

    y.activeCount = y.activeCount + 1
end

function Y.ToggleEditMode()
    y.editMode = not y.editMode
    if y.editMode then
        editOverlay:Show()
        print("|cFF00CCFFHorizon Suite - Cache:|r Edit mode |cFF00FF00ON|r - drag the box to reposition.")
        Y.ShowToast({
            icon = 135349, text = "Ashkandur, Fall of the Brotherhood",
            r = 0.64, g = 0.21, b = 0.93, br = 0.77, bg = 0.25, bb = 1.0,
            holdDur = Y.HOLD_EPIC, quality = 4,
        })
    else
        editOverlay:Hide()
        print("|cFF00CCFFHorizon Suite - Cache:|r Edit mode |cFFFF0000OFF|r")
    end
end

function Y.RestoreSavedPosition()
    Y.ApplyStoredAnchor(Frame)
end

function Y.ResetPosition()
    Frame:ClearAllPoints()
    Frame:SetPoint(Y.DEFAULT_ANCHOR, UIParent, Y.DEFAULT_ANCHOR, Y.DEFAULT_X, Y.DEFAULT_Y)
    Y.ClearPosition()
end

function Y.ClearActiveToasts()
    for i = 1, Y.POOL_SIZE do
        if y.pool[i].active then
            y.pool[i].active = false
            y.pool[i].frame:Hide()
            y.pool[i].frame:SetAlpha(0)
        end
    end
    y.activeCount = 0
end

function Y.SetFrameVisible(visible)
    if visible then
        Frame:Show()
    else
        Frame:Hide()
    end
end

--- Re-apply scale to frame and pool entries (call when global UI scale changes).
function Y.ApplyScale()
    local S = function(v) return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "cache") end
    Frame:SetSize(S(Y.TOTAL_WIDTH), S(Y.LINE_HEIGHT) * Y.POOL_SIZE)
    for i = 1, Y.POOL_SIZE do
        local entry = y.pool[i]
        if entry then
            if entry.frame then entry.frame:SetSize(S(Y.TOTAL_WIDTH), S(Y.ENTRY_HEIGHT)) end
            if entry.iconBg then entry.iconBg:SetSize(S(Y.ICON_SIZE + Y.BORDER_PAD * 2), S(Y.ICON_SIZE + Y.BORDER_PAD * 2)) end
            if entry.icon then entry.icon:SetSize(S(Y.ICON_SIZE), S(Y.ICON_SIZE)) end
            if entry.shine then entry.shine:SetSize(S(Y.ICON_SIZE + 8), S(Y.ICON_SIZE + 8)) end
            if entry.text then entry.text:SetFont(Y.FONT_PATH, S(Y.FONT_SIZE), "OUTLINE") end
            if entry.shadow then entry.shadow:SetFont(Y.FONT_PATH, S(Y.FONT_SIZE), "OUTLINE") end
        end
    end
end

Y.Frame = Frame
