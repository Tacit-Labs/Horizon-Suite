--[[
    Horizon Suite - Cache - Core
    Frame, pool, animation engine, ShowToast. Blizzard: CreateFrame, C_Timer.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Cache then return end

local Cache = addon.Cache
local state = addon.cache

-- ============================================================================
-- MODULE-LEVEL HELPERS
-- ============================================================================

local function S(v)
    return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "cache")
end

local function HSPrint(msg)
    if addon.HSPrint then
        addon.HSPrint(msg)
    else
        print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or ""))
    end
end

local function easeOut(t)  return 1 - (1 - t) * (1 - t) end
local function easeIn(t)   return t * t end
local function easeInOut(t)
    if t < 0.5 then return 2 * t * t end
    return 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2
end

-- ============================================================================
-- FRAME REFERENCES (nil until InitFrames)
-- ============================================================================

local Frame, anchorFrame, editOverlay, editTitle, editHint, anchorLabel, anchorHint
local framesCreated = false

-- Forward-declare so the OnUpdate closure inside InitFrames can reference it
-- before the function body is defined below.
local UpdateEntry

local CACHE_ANCHOR_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- ============================================================================
-- READY GUARD
-- ============================================================================

local function IsReady() return framesCreated end

--- Returns true once InitFrames has run. External callers (events, slash) can
--- check this instead of knowing the internal framesCreated flag.
Cache.IsReady = IsReady

-- ============================================================================
-- POSITION
-- ============================================================================

--- Apply stored anchor position to a frame. Safe to call before InitFrames
--- (used by external callers); no-ops on nil.
--- @param frame table Frame to position
function Cache.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, yPos = Cache.GetPosition()
    point   = point   or Cache.DEFAULT_ANCHOR
    relPoint = relPoint or Cache.DEFAULT_ANCHOR
    x    = tonumber(x)    or Cache.DEFAULT_X
    yPos = tonumber(yPos) or Cache.DEFAULT_Y
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, x, yPos)
end

local function SaveFramePosition()
    local point, _, relPoint, x, yPos = Frame:GetPoint()
    if not point or not relPoint then return end
    Cache.SavePosition(point, relPoint, math.floor(x + 0.5), math.floor(yPos + 0.5))
end

-- ============================================================================
-- POOL ENTRY FACTORY
-- ============================================================================

local function CreateToastEntry(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(S(Cache.TOTAL_WIDTH), S(Cache.ENTRY_HEIGHT))

    local iconBg = f:CreateTexture(nil, "BORDER")
    iconBg:SetSize(S(Cache.ICON_SIZE + Cache.BORDER_PAD * 2), S(Cache.ICON_SIZE + Cache.BORDER_PAD * 2))
    iconBg:SetPoint("LEFT", f, "LEFT", 0, 0)
    iconBg:SetColorTexture(1, 1, 1, 0.8)

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(S(Cache.ICON_SIZE), S(Cache.ICON_SIZE))
    icon:SetPoint("CENTER", iconBg, "CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local shine = f:CreateTexture(nil, "OVERLAY")
    shine:SetSize(S(Cache.ICON_SIZE + 8), S(Cache.ICON_SIZE + 8))
    shine:SetPoint("CENTER", iconBg, "CENTER", 0, 0)
    shine:SetTexture("Interface\\Cooldown\\star4")
    shine:SetBlendMode("ADD")
    shine:SetAlpha(0)
    shine:Hide()

    local shadow = f:CreateFontString(nil, "BORDER")
    shadow:SetFont(Cache.GetFontPath(), S(Cache.FONT_SIZE), "OUTLINE")
    shadow:SetTextColor(0, 0, 0, 0.7)
    shadow:SetJustifyH("LEFT")
    shadow:SetPoint("LEFT", iconBg, "RIGHT", S(Cache.ICON_GAP) + 1, -1)
    shadow:SetPoint("RIGHT", f, "RIGHT", 1, -1)
    shadow:SetWordWrap(false)

    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetFont(Cache.GetFontPath(), S(Cache.FONT_SIZE), "OUTLINE")
    text:SetTextColor(1, 1, 1, 1)
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", iconBg, "RIGHT", S(Cache.ICON_GAP), 0)
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
        holdDur  = Cache.HOLD_ITEM,
        quality  = nil,
        maxAlpha = 1,
        stackY   = 0,
        smoothY  = 0,
        driftY   = 0,
    }
end

-- ============================================================================
-- LAZY INIT — called once from OnEnable (DB is ready at that point)
-- ============================================================================

function Cache.InitFrames()
    if framesCreated then return end
    framesCreated = true

    Frame = CreateFrame("Frame", nil, UIParent)
    Frame:SetSize(S(Cache.TOTAL_WIDTH), S(Cache.LINE_HEIGHT) * Cache.POOL_SIZE)
    Cache.ApplyStoredAnchor(Frame)
    Frame:Hide()

    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    Frame:RegisterForDrag("LeftButton")
    Frame:SetClampedToScreen(true)

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
    editOverlay = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
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

    editTitle = editOverlay:CreateFontString(nil, "OVERLAY")
    editTitle:SetFont(Cache.GetFontPath(), S(14), "OUTLINE")
    editTitle:SetTextColor(0.4, 0.8, 1.0, 1)
    editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
    editTitle:SetText("LOOT TOAST AREA")

    editHint = editOverlay:CreateFontString(nil, "OVERLAY")
    editHint:SetFont(Cache.GetFontPath(), S(10), "OUTLINE")
    editHint:SetTextColor(0.7, 0.7, 0.7, 1)
    editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
    editHint:SetText("Drag to reposition  |  /h cache edit to hide")

    editOverlay:Hide()

    -- Anchor frame
    anchorFrame = CreateFrame("Frame", "HorizonSuiteCacheAnchor", UIParent, "BackdropTemplate")
    anchorFrame:SetSize(160, 40)
    anchorFrame:SetBackdrop(CACHE_ANCHOR_BACKDROP)
    anchorFrame:SetBackdropColor(0, 0, 0, 0.85)
    anchorFrame:SetBackdropBorderColor(0.50, 0.70, 1.0, 0.60)
    anchorFrame:SetMovable(true)
    anchorFrame:EnableMouse(true)
    anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame:SetClampedToScreen(true)
    anchorFrame:SetFrameStrata("DIALOG")
    anchorFrame:Hide()

    anchorLabel = anchorFrame:CreateFontString(nil, "OVERLAY")
    anchorLabel:SetFont(Cache.GetFontPath(), S(12), "OUTLINE")
    anchorLabel:SetPoint("CENTER")
    anchorLabel:SetTextColor(0.50, 0.70, 1.0, 1)
    anchorLabel:SetText("LOOT TOAST ANCHOR")

    anchorHint = anchorFrame:CreateFontString(nil, "OVERLAY")
    anchorHint:SetFont(Cache.GetFontPath(), S(10), "OUTLINE")
    anchorHint:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -4)
    anchorHint:SetTextColor(0.60, 0.60, 0.60, 1)
    anchorHint:SetText("Drag to move · Right-click to confirm")

    anchorFrame:SetScript("OnDragStart", function(self)
        if not InCombatLockdown() then self:StartMoving() end
    end)
    anchorFrame:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
        self:StopMovingOrSizing()
        local point, _, relPoint, x, yPos = self:GetPoint()
        Cache.SavePosition(point, relPoint, math.floor(x + 0.5), math.floor(yPos + 0.5))
        Cache.ApplyStoredAnchor(Frame)
    end)
    anchorFrame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            self:Hide()
            HSPrint("Cache: Position saved.")
        end
    end)

    -- Pool
    for i = 1, Cache.POOL_SIZE do
        state.pool[i] = CreateToastEntry(Frame)
    end

    -- OnUpdate — UpdateEntry is forward-declared above InitFrames
    Frame:SetScript("OnUpdate", function(self, dt)
        if state.activeCount == 0 then
            if not state.editMode then self:Hide() end
            return
        end
        for i = 1, Cache.POOL_SIZE do
            if state.pool[i].active then
                UpdateEntry(state.pool[i], dt)
            end
        end
        if state.activeCount == 0 and not state.editMode then self:Hide() end
    end)

    Cache.Frame = Frame

    Cache.ApplyCacheClassChrome()
end

-- ============================================================================
-- CLASS CHROME
-- ============================================================================

local function ApplyCacheClassChrome()
    if not IsReady() then return end
    local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("cache")
    local br, bg, bb, ba = 0.50, 0.70, 1.0, 0.60
    local er, eg, eb, ea = 0.4,  0.8,  1.0, 0.8
    if ycc then
        br, bg, bb = ycc[1], ycc[2], ycc[3]
        er, eg, eb = ycc[1], ycc[2], ycc[3]
    end
    anchorFrame:SetBackdropBorderColor(br, bg, bb, ba)
    anchorLabel:SetTextColor(br, bg, bb, 1)
    editOverlay:SetBackdropBorderColor(er, eg, eb, ea)
    editTitle:SetTextColor(er, eg, eb, 1)
end

Cache.ApplyCacheClassChrome = ApplyCacheClassChrome

-- ============================================================================
-- POOL & ANIMATION
-- ============================================================================

local function AcquireEntry()
    local cap = math.max(1, math.min(
        Cache.POOL_SIZE,
        (addon.GetDB and tonumber(addon.GetDB("cacheMaxVisible", Cache.DEFAULTS.cacheMaxVisible))) or Cache.DEFAULTS.cacheMaxVisible
    ))
    for i = 1, cap do
        if not state.pool[i].active then return state.pool[i] end
    end
    -- Pool full (within cap): evict the entry with the least remaining display time.
    local best, bestRemaining = 1, math.huge
    for i = 1, cap do
        local e = state.pool[i]
        local remaining = e.holdDur - e.elapsed
        if remaining < bestRemaining then
            best          = i
            bestRemaining = remaining
        end
    end
    local entry = state.pool[best]
    entry.frame:Hide()
    entry.frame:SetAlpha(0)
    entry.active = false
    state.activeCount = state.activeCount - 1
    return entry
end

-- Assigned here so the forward declaration above is satisfied.
UpdateEntry = function(entry, dt)
    if not entry.active then return end

    entry.elapsed = entry.elapsed + dt
    local t = entry.elapsed

    local isEpicOrLegendary = (entry.quality == 4 or entry.quality == 5)
    local entranceDur = Cache.ENTRANCE_DUR
    local popPeak = 1
    if entry.quality == 5 then
        entranceDur = Cache.ENTRANCE_DUR_LEGENDARY
        popPeak     = Cache.POP_SCALE_PEAK_LEGEND
    elseif entry.quality == 4 then
        entranceDur = Cache.ENTRANCE_DUR_EPIC
        popPeak     = Cache.POP_SCALE_PEAK_EPIC
    end

    local entEnd  = entranceDur
    local holdEnd = entEnd  + entry.holdDur
    local fadeEnd = holdEnd + Cache.EXIT_DUR

    local maxA  = entry.maxAlpha or 1
    local alpha, slideX, scale

    if t < entEnd then
        local p = easeOut(t / entranceDur)
        alpha  = p * maxA
        slideX = Cache.SLIDE_DIST * (1 - p)
        if isEpicOrLegendary then
            local settleStart = 1 - Cache.POP_SETTLE_FRAC
            if p <= settleStart then
                local q = p / settleStart
                scale = Cache.POP_SCALE_START + (popPeak - Cache.POP_SCALE_START) * easeOut(q)
            else
                local q = (p - settleStart) / Cache.POP_SETTLE_FRAC
                scale = popPeak + (1 - popPeak) * easeInOut(q)
            end
        else
            scale = 1
        end

    elseif t < holdEnd then
        alpha  = maxA
        slideX = 0
        scale  = 1

    elseif t < fadeEnd then
        local p = easeIn((t - holdEnd) / Cache.EXIT_DUR)
        alpha        = (1 - p) * maxA
        slideX       = 0
        scale        = 1
        entry.driftY = entry.driftY + (Cache.EXIT_DRIFT / Cache.EXIT_DUR) * dt

    else
        entry.active = false
        entry.frame:Hide()
        entry.frame:SetAlpha(0)
        entry.frame:SetScale(1)
        if entry.shine  then entry.shine:Hide()         end
        if entry.iconBg then entry.iconBg:SetAlpha(0.8) end
        state.activeCount = state.activeCount - 1
        return
    end

    local cacheCC = addon.GetModuleClassColor and addon.GetModuleClassColor("cache")
    if entry.shine and (entry.quality == 5 or (entry.quality == 4 and cacheCC)) then
        if t < Cache.FLASH_DUR then
            entry.shine:Show()
            entry.shine:SetAlpha(1 - easeOut(t / Cache.FLASH_DUR))
        else
            entry.shine:Hide()
        end
    end

    if isEpicOrLegendary and t >= entEnd and t < holdEnd and entry.iconBg then
        local pulse     = 0.5 + 0.5 * math.sin(t * Cache.BORDER_PULSE_SPEED * 6.283185307)
        local glowAlpha = 1 - Cache.BORDER_PULSE_ALPHA + Cache.BORDER_PULSE_ALPHA * pulse
        entry.iconBg:SetAlpha(glowAlpha)
    elseif entry.iconBg then
        entry.iconBg:SetAlpha(0.8)
    end

    local gap = entry.stackY - entry.smoothY
    if math.abs(gap) > 0.5 then
        entry.smoothY = entry.smoothY + gap * math.min(Cache.NUDGE_SPEED * dt, 1)
    else
        entry.smoothY = entry.stackY
    end

    entry.frame:SetAlpha(alpha)
    entry.frame:SetScale(scale or 1)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT",
                         slideX, entry.smoothY + entry.driftY)
end

-- ============================================================================
-- SOUND DISPATCH
-- ============================================================================

local function PlayToastSound(data)
    if not addon.GetDB then return end
    if addon.GetDB("cacheSoundEnabled", Cache.DEFAULTS.cacheSoundEnabled) == false then return end
    local kind  = data.kind
    local sound
    if kind == "item" then
        if addon.GetDB("cacheSoundItems", Cache.DEFAULTS.cacheSoundItems) ~= false then
            if data.quality == 5 then
                sound = Cache.SOUND_LEGENDARY
            elseif data.quality == 4 then
                sound = Cache.SOUND_EPIC
            end
        end
    elseif kind == "money" then
        if addon.GetDB("cacheSoundMoney", Cache.DEFAULTS.cacheSoundMoney) ~= false then sound = Cache.SOUND_MONEY end
    elseif kind == "currency" then
        if addon.GetDB("cacheSoundCurrency", Cache.DEFAULTS.cacheSoundCurrency) ~= false then sound = Cache.SOUND_CURRENCY end
    elseif kind == "rep" then
        if addon.GetDB("cacheSoundRep", Cache.DEFAULTS.cacheSoundRep) ~= false then sound = Cache.SOUND_REP end
    end
    if sound and PlaySound then
        local ch = (addon.GetDB and addon.GetDB("cacheSoundChannel", Cache.DEFAULTS.cacheSoundChannel)) or Cache.DEFAULTS.cacheSoundChannel
        pcall(PlaySound, sound, ch)
    end
end

-- ============================================================================
-- SHOW TOAST
-- ============================================================================

function Cache.ShowToast(data)
    if not addon:IsModuleEnabled("cache") or not data then return end
    if not IsReady() then return end

    local entry = AcquireEntry()

    for i = 1, Cache.POOL_SIZE do
        if state.pool[i].active then
            state.pool[i].stackY = state.pool[i].stackY + S(Cache.LINE_HEIGHT)
        end
    end

    entry.icon:SetTexture(data.icon)
    entry.iconBg:SetColorTexture(data.br, data.bg, data.bb, 0.8)
    entry.text:SetText(data.text)
    entry.text:SetTextColor(data.r, data.g, data.b, 1)
    entry.shadow:SetText(data.text)

    entry.active   = true
    entry.elapsed  = 0
    entry.holdDur  = Cache.GetHoldDur(data.kind, data.quality)
    entry.quality  = data.quality
    -- Snapshot opacity at show-time so each toast has consistent alpha throughout its lifecycle
    -- without a per-frame DB read.
    entry.maxAlpha = math.max(0.1, math.min(1.0,
        (addon.GetDB and tonumber(addon.GetDB("cacheToastOpacity", Cache.DEFAULTS.cacheToastOpacity)) or Cache.DEFAULTS.cacheToastOpacity) / 100))
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
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", Cache.SLIDE_DIST, 0)
    entry.frame:Show()
    Frame:Show()

    PlayToastSound(data)

    state.activeCount = state.activeCount + 1
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function Cache.ToggleEditMode()
    if not IsReady() then return end
    state.editMode = not state.editMode
    if state.editMode then
        editOverlay:Show()
        Frame:Show()
        print("|cFF00CCFFHorizon Suite - Cache:|r Edit mode |cFF00FF00ON|r - drag the box to reposition.")
        Cache.ShowToast({
            kind = "item", icon = 135349, text = "Ashkandur, Fall of the Brotherhood",
            r = 0.64, g = 0.21, b = 0.93, br = 0.77, bg = 0.25, bb = 1.0, quality = 4,
        })
    else
        editOverlay:Hide()
        print("|cFF00CCFFHorizon Suite - Cache:|r Edit mode |cFFFF0000OFF|r")
    end
end

function Cache.RestoreSavedPosition()
    if not IsReady() then return end
    Cache.ApplyStoredAnchor(Frame)
end

function Cache.ResetPosition()
    if not IsReady() then return end
    Frame:ClearAllPoints()
    Frame:SetPoint(Cache.DEFAULT_ANCHOR, UIParent, Cache.DEFAULT_ANCHOR, Cache.DEFAULT_X, Cache.DEFAULT_Y)
    Cache.ClearPosition()
end

function Cache.ClearActiveToasts()
    if not IsReady() then return end
    for i = 1, Cache.POOL_SIZE do
        local e = state.pool[i]
        if e.active then
            e.active = false
            e.frame:Hide()
            e.frame:SetAlpha(0)
        end
    end
    state.activeCount = 0
end

function Cache.SetFrameVisible(visible)
    if not IsReady() then return end
    if visible then Frame:Show() else Frame:Hide() end
end

function Cache.ToggleAnchorFrame()
    if not IsReady() then return end
    if anchorFrame:IsShown() then
        anchorFrame:Hide()
        HSPrint("Cache: Anchor hidden. Position saved.")
    else
        if InCombatLockdown() then return end
        Cache.ApplyStoredAnchor(anchorFrame)
        anchorFrame:Show()
        HSPrint("Cache: Drag the anchor, then right-click to confirm.")
    end
end

function Cache.HideAnchorFrame()
    if not IsReady() then return end
    anchorFrame:Hide()
end

function Cache.ApplyCacheOptions()
    if not IsReady() then return end
    ApplyCacheClassChrome()
    if anchorFrame:IsShown() then Cache.ApplyStoredAnchor(anchorFrame) end
    Cache.ApplyStoredAnchor(Frame)
    if Cache.ApplyScale then Cache.ApplyScale() end
end

--- Re-apply scale and font to all pool entries and overlay labels.
--- Called when UI scale or cacheFontPath changes.
function Cache.ApplyScale()
    if Cache.InvalidateCoinTextures then Cache.InvalidateCoinTextures() end
    if not IsReady() then return end
    local fontPath = Cache.GetFontPath()
    Frame:SetSize(S(Cache.TOTAL_WIDTH), S(Cache.LINE_HEIGHT) * Cache.POOL_SIZE)
    for i = 1, Cache.POOL_SIZE do
        local e = state.pool[i]
        if e then
            if e.frame  then e.frame:SetSize(S(Cache.TOTAL_WIDTH), S(Cache.ENTRY_HEIGHT)) end
            if e.iconBg then e.iconBg:SetSize(S(Cache.ICON_SIZE + Cache.BORDER_PAD * 2), S(Cache.ICON_SIZE + Cache.BORDER_PAD * 2)) end
            if e.icon   then e.icon:SetSize(S(Cache.ICON_SIZE), S(Cache.ICON_SIZE)) end
            if e.shine  then e.shine:SetSize(S(Cache.ICON_SIZE + 8), S(Cache.ICON_SIZE + 8)) end
            if e.text   then e.text:SetFont(fontPath, S(Cache.FONT_SIZE), "OUTLINE") end
            if e.shadow then e.shadow:SetFont(fontPath, S(Cache.FONT_SIZE), "OUTLINE") end
        end
    end
    if editTitle   then editTitle:SetFont(fontPath, S(14), "OUTLINE") end
    if editHint    then editHint:SetFont(fontPath,  S(10), "OUTLINE") end
    if anchorLabel then anchorLabel:SetFont(fontPath, S(12), "OUTLINE") end
    if anchorHint  then anchorHint:SetFont(fontPath,  S(10), "OUTLINE") end
end
