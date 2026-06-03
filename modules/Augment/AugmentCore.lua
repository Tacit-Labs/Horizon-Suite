--[[
    Horizon Suite - Augment - Core
    Frame, pool, animation engine, ShowToast. Blizzard: CreateFrame, C_Timer.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end
local L = addon.L
local Augment = addon.Augment
local state = addon.augment

-- ============================================================================
-- MODULE-LEVEL HELPERS
-- ============================================================================

local function S(v)
    local lim = addon.AUGMENT_LIMITS.augmentUIScale
    local scale = math.max(lim.min, math.min(lim.max,
        tonumber(addon.GetDB and addon.GetDB("augmentUIScale", addon.AUGMENT_DEFAULTS.augmentUIScale)) or 1))
    return v * scale
end

local function GetFontSize()
    return tonumber(addon.GetDB and addon.GetDB("augmentFontSize", addon.AUGMENT_DEFAULTS.augmentFontSize)) or addon.AUGMENT_DEFAULTS.augmentFontSize
end

local function HSPrint(msg)
    if addon.HSPrint then
        addon.HSPrint(msg)
    else
        print("|cFF00CCFFHorizon Suite:|r " .. tostring(msg or ""))
    end
end

local function GetFontFlags()
    if not addon.GetDB then return "OUTLINE" end
    return addon.GetDB("augmentTextOutline", addon.AUGMENT_DEFAULTS.augmentTextOutline) ~= false and "OUTLINE" or ""
end

local function GetToastFont()
    return Augment.GetFontPath(), S(GetFontSize()), GetFontFlags()
end

-- Per-FontString hook that re-asserts our desired font whenever a font-replacement
-- addon (e.g. Platynator) overrides SetFont or SetFontObject on that string.
-- Mirrors the LockDirectFont pattern used in PresenceTalkingHead.lua.
local function LockDirectFont(fontString, getFont)
    local busy = false

    hooksecurefunc(fontString, "SetFontObject", function(self, obj)
        if busy or not obj then return end
        local path, size, flags = getFont()
        if not path then return end
        busy = true
        self:SetFontObject(nil)
        self:SetFont(path, size, flags or "OUTLINE")
        busy = false
    end)

    hooksecurefunc(fontString, "SetFont", function(self, path, size, flags)
        if busy then return end
        local targetPath, targetSize, targetFlags = getFont()
        if not targetPath or path == targetPath then return end
        busy = true
        self:SetFont(targetPath, targetSize or size, targetFlags or flags or "OUTLINE")
        busy = false
    end)
end

-- Shared FontObject for all pool text/shadow FontStrings.
-- Updating it propagates to every FontString using SetFontObject(AugmentFontObj) automatically,
-- without touching individual FontStrings — and survives same-tick overrides from other addons
-- that hook SetFont on specific FontStrings.
local AugmentFontObj

local function UpdateAugmentFontObject()
    if not AugmentFontObj then return end
    AugmentFontObj:SetFont(Augment.GetFontPath(), S(GetFontSize()), GetFontFlags())
end

-- mode: "in" = ease-in, "inOut" = ease-in-out, default = ease-out (quadratic)
local function Ease(t, mode)
    if mode == "in"    then return t * t end
    if mode == "inOut" then
        if t < 0.5 then return 2 * t * t end
        return 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2
    end
    return 1 - (1 - t) * (1 - t)
end

-- ============================================================================
-- FRAME REFERENCES (nil until InitFrames)
-- ============================================================================

local Frame, anchorFrame, editOverlay, editTitle, editHint, anchorLabel, anchorHint
local framesCreated = false

local function UpdateFrameSize()
    if not Frame then return end
    Frame:SetSize(S(Augment.TOTAL_WIDTH), S(Augment.LINE_HEIGHT) * math.max(1, state.activeCount))
end

-- Forward-declare so the OnUpdate closure inside InitFrames can reference it
-- before the function body is defined below.
local UpdateEntry

local AUGMENT_ANCHOR_BACKDROP = {
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
Augment.IsReady = IsReady

-- ============================================================================
-- POSITION
-- ============================================================================

--- Apply stored anchor position to a frame. Safe to call before InitFrames
--- (used by external callers); no-ops on nil.
--- @param frame table Frame to position
function Augment.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, yPos = Augment.GetPosition()
    point   = point   or Augment.DEFAULT_ANCHOR
    relPoint = relPoint or Augment.DEFAULT_ANCHOR
    x    = tonumber(x)    or Augment.DEFAULT_X
    yPos = tonumber(yPos) or Augment.DEFAULT_Y
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, x, yPos)
end

-- After StartMoving/StopMovingOrSizing, WoW internally re-anchors to
-- ("TOPLEFT", UIParent, "BOTTOMLEFT", screenX, screenTopY), making GetPoint()
-- return TOPLEFT. Saving that causes Frame to grow downward and toasts to
-- appear below the anchor. Normalize to BOTTOMRIGHT/BOTTOMRIGHT instead.
local function SaveFramePosition()
    local right  = Frame:GetRight()
    local bottom = Frame:GetBottom()
    if not right or not bottom then return end
    local x = math.floor(right  - UIParent:GetRight()  + 0.5)
    local y = math.floor(bottom - UIParent:GetBottom() + 0.5)
    Augment.SavePosition("BOTTOMRIGHT", "BOTTOMRIGHT", x, y)
end

-- ============================================================================
-- POOL ENTRY FACTORY
-- ============================================================================

-- Fraction of icon size used as the overlap/step between stacked layers.
-- Mirrors Plumber's overlapRatio so the whole stack fits within the original icon bounding box.
local STACK_OVERLAP = 0.15

local function CreateToastEntry(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(S(Augment.TOTAL_WIDTH), S(Augment.ENTRY_HEIGHT))

    -- Fixed invisible texture used purely as a stable anchor for text/shadow.
    -- iconBg (and its stack siblings) reposition during the fan layout, but
    -- text must never move, so it anchors here instead.
    local iconBgAnchor = f:CreateTexture(nil, "BACKGROUND")
    iconBgAnchor:SetSize(S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2), S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2))
    iconBgAnchor:SetPoint("LEFT", f, "LEFT", 0, 0)
    iconBgAnchor:SetAlpha(0)

    -- Stack backgrounds — created back-to-front so BORDER z-order matches icon depth.
    local iconBg3 = f:CreateTexture(nil, "BORDER")
    iconBg3:SetSize(S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2), S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2))
    iconBg3:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    iconBg3:Hide()

    local iconBg2 = f:CreateTexture(nil, "BORDER")
    iconBg2:SetSize(S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2), S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2))
    iconBg2:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    iconBg2:Hide()

    -- Main (front) background — starts centered on the anchor; repositioned by UpdateStackIcons.
    local iconBg = f:CreateTexture(nil, "BORDER")
    iconBg:SetSize(S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2), S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2))
    iconBg:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    iconBg:SetColorTexture(1, 1, 1, 0.8)

    -- Stack icons — back-to-front so ARTWORK z-order mirrors depth.
    local icon3 = f:CreateTexture(nil, "ARTWORK")
    icon3:SetSize(S(Augment.ICON_SIZE), S(Augment.ICON_SIZE))
    icon3:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    icon3:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon3:Hide()

    local icon2 = f:CreateTexture(nil, "ARTWORK")
    icon2:SetSize(S(Augment.ICON_SIZE), S(Augment.ICON_SIZE))
    icon2:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    icon2:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon2:Hide()

    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(S(Augment.ICON_SIZE), S(Augment.ICON_SIZE))
    icon:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local shine = f:CreateTexture(nil, "OVERLAY")
    shine:SetSize(S(Augment.ICON_SIZE + 8), S(Augment.ICON_SIZE + 8))
    shine:SetPoint("CENTER", iconBgAnchor, "CENTER", 0, 0)
    shine:SetTexture("Interface\\Cooldown\\star4")
    shine:SetBlendMode("ADD")
    shine:SetAlpha(0)
    shine:Hide()

    local shadow = f:CreateFontString(nil, "BORDER")
    shadow:SetFontObject(AugmentFontObj)
    shadow:SetTextColor(0, 0, 0, 0.7)
    shadow:SetJustifyH("LEFT")
    shadow:SetPoint("LEFT", iconBgAnchor, "RIGHT", S(Augment.ICON_GAP) + 1, -1)
    shadow:SetPoint("RIGHT", f, "RIGHT", 1, -1)
    shadow:SetWordWrap(false)

    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetFontObject(AugmentFontObj)
    text:SetTextColor(1, 1, 1, 1)
    text:SetJustifyH("LEFT")
    text:SetPoint("LEFT", iconBgAnchor, "RIGHT", S(Augment.ICON_GAP), 0)
    text:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    text:SetWordWrap(false)

    LockDirectFont(shadow, GetToastFont)
    LockDirectFont(text,   GetToastFont)

    -- Transparent button child: handles hover tooltip and Ctrl+Left item preview while
    -- propagating all other clicks through to the game engine (camera rotation, etc.).
    local clickBtn = CreateFrame("Button", nil, f)
    clickBtn:SetAllPoints(f)
    clickBtn:SetPropagateMouseClicks(true)
    clickBtn:RegisterForClicks("AnyUp")
    clickBtn:SetScript("OnEnter", function(self)
        if not f._itemLink then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetHyperlink(f._itemLink)
        GameTooltip:Show()
    end)
    clickBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    clickBtn:SetScript("OnClick", function(_, button)
        if button == "LeftButton" and IsControlKeyDown() and f._itemLink then
            DressUpItemLink(f._itemLink)
        end
    end)

    f:SetAlpha(0)
    f:Hide()

    return {
        frame       = f,
        iconBgAnchor = iconBgAnchor,
        iconBg      = iconBg,
        iconBg2     = iconBg2,
        iconBg3     = iconBg3,
        icon        = icon,
        icon2       = icon2,
        icon3       = icon3,
        shine       = shine,
        shadow      = shadow,
        text        = text,
        active      = false,
        elapsed     = 0,
        holdDur     = Augment.HOLD_ITEM,
        quality     = nil,
        maxAlpha    = 1,
        stackY   = 0,
        smoothY  = 0,
        driftY   = 0,
    }
end

-- ============================================================================
-- LAZY INIT — called once from OnEnable (DB is ready at that point)
-- ============================================================================

function Augment.InitFrames()
    if framesCreated then return end
    framesCreated = true

    Frame = CreateFrame("Frame", nil, UIParent)
    Frame:SetSize(S(Augment.TOTAL_WIDTH), S(Augment.LINE_HEIGHT))
    Augment.ApplyStoredAnchor(Frame)
    Frame:Hide()

    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    Frame:RegisterForDrag("LeftButton")
    Frame:SetClampedToScreen(true)
    Frame:SetPropagateMouseClicks(true)

    Frame:SetScript("OnDragStart", function(self)
        if InCombatLockdown() or not state.editMode then return end
        self:StartMoving()
    end)
    Frame:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
        self:StopMovingOrSizing()
        SaveFramePosition()
    end)
    Frame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" and not state.editMode then
            Augment.ClearActiveToasts()
            self:Hide()
        end
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
    editTitle:SetFont(Augment.GetFontPath(), S(14), "OUTLINE")
    editTitle:SetTextColor(0.4, 0.8, 1.0, 1)
    editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
    editTitle:SetText("LOOT TOAST AREA")

    editHint = editOverlay:CreateFontString(nil, "OVERLAY")
    editHint:SetFont(Augment.GetFontPath(), S(10), "OUTLINE")
    editHint:SetTextColor(0.7, 0.7, 0.7, 1)
    editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
    editHint:SetText("Drag to reposition  |  /h augment edit to hide")

    editOverlay:Hide()

    -- Anchor frame
    anchorFrame = CreateFrame("Frame", "HorizonSuiteAugmentAnchor", UIParent, "BackdropTemplate")
    anchorFrame:SetSize(160, 40)
    anchorFrame:SetBackdrop(AUGMENT_ANCHOR_BACKDROP)
    anchorFrame:SetBackdropColor(0, 0, 0, 0.85)
    anchorFrame:SetBackdropBorderColor(0.50, 0.70, 1.0, 0.60)
    anchorFrame:SetMovable(true)
    anchorFrame:EnableMouse(true)
    anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame:SetClampedToScreen(true)
    anchorFrame:SetFrameStrata("DIALOG")
    anchorFrame:Hide()

    anchorLabel = anchorFrame:CreateFontString(nil, "OVERLAY")
    anchorLabel:SetFont(Augment.GetFontPath(), S(12), "OUTLINE")
    anchorLabel:SetPoint("CENTER")
    anchorLabel:SetTextColor(0.50, 0.70, 1.0, 1)
    anchorLabel:SetText("LOOT TOAST ANCHOR")

    anchorHint = anchorFrame:CreateFontString(nil, "OVERLAY")
    anchorHint:SetFont(Augment.GetFontPath(), S(10), "OUTLINE")
    anchorHint:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -4)
    anchorHint:SetTextColor(0.60, 0.60, 0.60, 1)
    anchorHint:SetText("Drag to move · Right-click to confirm")

    anchorFrame:SetScript("OnDragStart", function(self)
        if not InCombatLockdown() then self:StartMoving() end
    end)
    anchorFrame:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
        self:StopMovingOrSizing()
        local right  = self:GetRight()  or 0
        local bottom = self:GetBottom() or 0
        local x = math.floor(right  - UIParent:GetRight()  + 0.5)
        local y = math.floor(bottom - UIParent:GetBottom() + 0.5)
        Augment.SavePosition("BOTTOMRIGHT", "BOTTOMRIGHT", x, y)
        Augment.ApplyStoredAnchor(Frame)
    end)
    anchorFrame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            self:Hide()
            HSPrint("Augment: Position saved.")
        end
    end)

    -- Shared FontObject — must exist before pool entries are created.
    AugmentFontObj = _G["HorizonSuiteAugmentFont"] or CreateFont("HorizonSuiteAugmentFont")
    UpdateAugmentFontObject()

    -- Pool
    for i = 1, Augment.POOL_SIZE do
        state.pool[i] = CreateToastEntry(Frame)
    end

    -- OnUpdate — UpdateEntry is forward-declared above InitFrames
    Frame:SetScript("OnUpdate", function(self, dt)
        if state.activeCount == 0 then
            if not state.editMode then self:Hide() end
            return
        end
        for i = 1, Augment.POOL_SIZE do
            if state.pool[i].active then
                UpdateEntry(state.pool[i], dt)
            end
        end
        if state.activeCount == 0 and not state.editMode then self:Hide() end
    end)

    Augment.Frame = Frame

    Augment.ApplyAugmentClassChrome()

    -- Re-apply fonts after the current event handler returns so our settings
    -- land after any typography addon that hooks synchronously at login.
    C_Timer.After(0, function() if Augment.ApplyScale then Augment.ApplyScale() end end)
end

-- ============================================================================
-- CLASS CHROME
-- ============================================================================

local function ApplyAugmentClassChrome()
    if not IsReady() then return end
    local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("augment")
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

Augment.ApplyAugmentClassChrome = ApplyAugmentClassChrome

-- ============================================================================
-- POOL & ANIMATION
-- ============================================================================

local function GetPoolCap()
    return math.max(1, math.min(
        Augment.POOL_SIZE,
        (addon.GetDB and tonumber(addon.GetDB("augmentMaxVisible", addon.AUGMENT_DEFAULTS.augmentMaxVisible))) or addon.AUGMENT_DEFAULTS.augmentMaxVisible
    ))
end

local function AcquireEntry()
    local cap = GetPoolCap()
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

local function GetQualityEntrance(quality)
    if quality == 5 then return Augment.ENTRANCE_DUR_LEGENDARY, Augment.POP_SCALE_PEAK_LEGEND, true end
    if quality == 4 then return Augment.ENTRANCE_DUR_EPIC,      Augment.POP_SCALE_PEAK_EPIC,   true end
    return Augment.ENTRANCE_DUR, 1, false
end

local function CalcEntranceScale(p, isEpicOrLegendary, popPeak)
    if not isEpicOrLegendary then return 1 end
    local settleStart = 1 - Augment.POP_SETTLE_FRAC
    if p <= settleStart then
        return Augment.POP_SCALE_START + (popPeak - Augment.POP_SCALE_START) * Ease(p / settleStart)
    end
    return popPeak + (1 - popPeak) * Ease((p - settleStart) / Augment.POP_SETTLE_FRAC, "inOut")
end

local function UpdateShine(entry, t)
    if not entry.shine then return end
    local augmentCC = addon.GetModuleClassColor and addon.GetModuleClassColor("augment")
    if (entry.quality == 5 or (entry.quality == 4 and augmentCC)) and t < Augment.FLASH_DUR then
        entry.shine:Show()
        entry.shine:SetAlpha(1 - Ease(t / Augment.FLASH_DUR))
    else
        entry.shine:Hide()
    end
end

local function UpdateIconGlow(entry, t, isEpicOrLegendary, entEnd, holdEnd)
    if not entry.iconBg then return end
    if isEpicOrLegendary and t >= entEnd and t < holdEnd then
        local pulse = 0.5 + 0.5 * math.sin(t * Augment.BORDER_PULSE_SPEED * 6.283185307)
        entry.iconBg:SetAlpha(1 - Augment.BORDER_PULSE_ALPHA + Augment.BORDER_PULSE_ALPHA * pulse)
    else
        entry.iconBg:SetAlpha(0.8)
    end
end

local function SmoothStack(entry, dt)
    local gap = entry.stackY - entry.smoothY
    if math.abs(gap) > 0.5 then
        entry.smoothY = entry.smoothY + gap * math.min(Augment.NUDGE_SPEED * dt, 1)
    else
        entry.smoothY = entry.stackY
    end
end

-- Assigned here so the forward declaration above is satisfied.
UpdateEntry = function(entry, dt)
    if not entry.active then return end

    entry.elapsed = entry.elapsed + dt
    local t = entry.elapsed

    local entranceDur, popPeak, isEpicOrLegendary = GetQualityEntrance(entry.quality)
    local entEnd  = entranceDur
    local holdEnd = entEnd  + entry.holdDur
    local fadeEnd = holdEnd + Augment.EXIT_DUR
    local maxA    = entry.maxAlpha or 1
    local alpha, slideX, scale

    if t < entEnd then
        local p = Ease(t / entranceDur)
        alpha  = p * maxA
        slideX = Augment.SLIDE_DIST * (1 - p)
        scale  = CalcEntranceScale(p, isEpicOrLegendary, popPeak)

    elseif t < holdEnd then
        alpha  = maxA
        slideX = 0
        scale  = 1

    elseif t < fadeEnd then
        local p = Ease((t - holdEnd) / Augment.EXIT_DUR, "in")
        alpha        = (1 - p) * maxA
        slideX       = 0
        scale        = 1
        entry.driftY = entry.driftY + (Augment.EXIT_DRIFT / Augment.EXIT_DUR) * dt

    else
        entry.active = false
        entry.frame:Hide()
        entry.frame:SetAlpha(0)
        entry.frame:SetScale(1)
        if entry.shine  then entry.shine:Hide()         end
        if entry.iconBg then entry.iconBg:SetAlpha(0.8) end
        if entry.icon2   then entry.icon2:Hide()   end
        if entry.icon3   then entry.icon3:Hide()   end
        if entry.iconBg2 then entry.iconBg2:Hide() end
        if entry.iconBg3 then entry.iconBg3:Hide() end
        state.activeCount = state.activeCount - 1
        UpdateFrameSize()
        return
    end

    UpdateShine(entry, t)
    UpdateIconGlow(entry, t, isEpicOrLegendary, entEnd, holdEnd)
    SmoothStack(entry, dt)

    entry.frame:SetAlpha(alpha)
    entry.frame:SetScale(scale or 1)
    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", slideX, entry.smoothY + entry.driftY)
end

-- ============================================================================
-- SOUND DISPATCH
-- ============================================================================

local function PlayToastSound(data)
    if not addon.GetDB then return end
    if addon.GetDB("augmentSoundEnabled", addon.AUGMENT_DEFAULTS.augmentSoundEnabled) == false then return end
    local kind  = data.kind
    local sound
    if kind == "item" then
        if addon.GetDB("augmentSoundItems", addon.AUGMENT_DEFAULTS.augmentSoundItems) ~= false then
            if data.quality == 5 then
                sound = Augment.SOUND_LEGENDARY
            elseif data.quality == 4 then
                sound = Augment.SOUND_EPIC
            end
        end
    elseif kind == "money" then
        if addon.GetDB("augmentSoundMoney", addon.AUGMENT_DEFAULTS.augmentSoundMoney) ~= false then sound = Augment.SOUND_MONEY end
    elseif kind == "currency" then
        if addon.GetDB("augmentSoundCurrency", addon.AUGMENT_DEFAULTS.augmentSoundCurrency) ~= false then sound = Augment.SOUND_CURRENCY end
    elseif kind == "rep" then
        if addon.GetDB("augmentSoundRep", addon.AUGMENT_DEFAULTS.augmentSoundRep) ~= false then sound = Augment.SOUND_REP end
    end
    if sound and PlaySound then
        local ch = (addon.GetDB and addon.GetDB("augmentSoundChannel", addon.AUGMENT_DEFAULTS.augmentSoundChannel)) or addon.AUGMENT_DEFAULTS.augmentSoundChannel
        pcall(PlaySound, sound, ch)
    end
end

-- ============================================================================
-- STACKING / MERGE
-- ============================================================================

local JUNK_KEY = "__junk__"

local function GetEffectiveItemKey(data)
    if not data.itemKey then return nil end
    if data.kind == "item" and data.quality == 0 then
        if addon.GetDB and addon.GetDB("augmentCondenseJunk", addon.AUGMENT_DEFAULTS.augmentCondenseJunk) ~= false then
            return JUNK_KEY
        end
    end
    if addon.GetDB and addon.GetDB("augmentStackDuplicates", addon.AUGMENT_DEFAULTS.augmentStackDuplicates) ~= false then
        return data.itemKey
    end
    return nil
end

local function BuildMergedText(data, effectiveKey, totalCount)
    local showStackCountBeforeName = addon.GetDB and addon.GetDB("augmentStackCountBeforeName", addon.AUGMENT_DEFAULTS.augmentStackCountBeforeName) ~= false
    
    if effectiveKey == JUNK_KEY then
        -- Show the real item name until a second junk item merges in.
        if totalCount == 1 then
            return data.baseName or data.text
        end
        if showStackCountBeforeName then
            return totalCount .. " x " .. L["AUGMENT_JUNK_LABEL"]
        else
            return L["AUGMENT_JUNK_LABEL"] .. " x" .. totalCount
        end
    end
    if data.kind == "item" then
        if showStackCountBeforeName then
           return totalCount > 1 and (totalCount .. " x " .. data.baseName) or data.baseName
        else
           return totalCount > 1 and (data.baseName .. " x" .. totalCount) or data.baseName
        end
    end
    if data.kind == "currency" then
        return "+" .. totalCount .. " " .. (data.baseName or "")
    end
    return data.text
end

-- Layout all stack layers (icon + background per layer) using Plumber's diagonal-fan approach.
-- Each layer gets its own border/background so they look like individual item slots.
-- count < 2 restores everything to single-icon state.
local function UpdateStackIcons(entry, count)
    local numIcons = math.min(count, 3)
    local iconLayers = { entry.icon,   entry.icon2,   entry.icon3   }  -- front → back
    local bgLayers   = { entry.iconBg, entry.iconBg2, entry.iconBg3 }
    local bgBase     = S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2)
    local szBase     = S(Augment.ICON_SIZE)
    local anchor     = entry.iconBgAnchor or entry.iconBg  -- fallback for safety

    if numIcons < 2 then
        -- Single icon: restore front icon/bg to full size, hide the rest.
        entry.iconBg:SetSize(bgBase, bgBase)
        entry.iconBg:ClearAllPoints()
        entry.iconBg:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        entry.iconBg:SetAlpha(0.8)
        entry.icon:SetSize(szBase, szBase)
        entry.icon:SetAlpha(1)
        entry.icon:ClearAllPoints()
        entry.icon:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        if entry.icon2   then entry.icon2:Hide()   end
        if entry.icon3   then entry.icon3:Hide()   end
        if entry.iconBg2 then entry.iconBg2:Hide() end
        if entry.iconBg3 then entry.iconBg3:Hide() end
        return
    end

    local iconSize   = szBase / (1 + (numIcons - 1) * STACK_OVERLAP)
    local iconOffset = iconSize * STACK_OVERLAP
    local stackSpan  = (numIcons - 1) * iconOffset
    local bgSize     = iconSize + S(Augment.BORDER_PAD * 2)
    local br = entry._bgR or 1
    local bg = entry._bgG or 1
    local bb = entry._bgB or 1

    for pos = 0, numIcons - 1 do
        local ico = iconLayers[pos + 1]
        local ibg = bgLayers[pos + 1]
        local cx  = -stackSpan / 2 + pos * iconOffset
        local cy  =  stackSpan / 2 - pos * iconOffset
        local a   = 1 - pos * 0.2   -- front=1.0, mid=0.8, back=0.6

        if ico then
            ico:SetSize(iconSize, iconSize)
            ico:ClearAllPoints()
            ico:SetPoint("CENTER", anchor, "CENTER", cx, cy)
            ico:SetAlpha(a)
            ico:Show()
        end
        if ibg then
            ibg:SetSize(bgSize, bgSize)
            ibg:ClearAllPoints()
            ibg:SetPoint("CENTER", anchor, "CENTER", cx, cy)
            ibg:SetColorTexture(br, bg, bb, 0.8 * a)
            ibg:Show()
        end
    end

    -- Hide layers not needed at this count.
    for i = numIcons + 1, 3 do
        if iconLayers[i] then iconLayers[i]:Hide() end
        if bgLayers[i]   then bgLayers[i]:Hide()   end
    end
end

local function TryMergeToast(data, effectiveKey)
    local cap = GetPoolCap()
    for i = 1, cap do
        local e = state.pool[i]
        if e.active and e._itemKey == effectiveKey then
            local newCount = (e._count or 1) + (data.count or 1)
            e._count = newCount
            local newText
            if effectiveKey == JUNK_KEY and e._origItemKey then
                if e._origItemKey == data.itemKey then
                    -- Same junk item looted again — keep its real name.
                    newText = newCount > 1
                        and ((data.baseName or data.text) .. " x" .. newCount)
                        or  (data.baseName or data.text)
                else
                    -- A different junk item arrived — switch to the generic label
                    -- and clear _origItemKey so further merges also use it.
                    e._origItemKey = nil
                    newText = BuildMergedText(data, effectiveKey, newCount)
                end
            else
                newText = BuildMergedText(data, effectiveKey, newCount)
            end
            e.text:SetText(newText)
            e.shadow:SetText(newText)
            if effectiveKey == JUNK_KEY then
                -- Shift icon layers so each junk item keeps its own icon.
                -- icon3 ← icon2's texture, icon2 ← main icon's texture, main ← new item.
                if e.icon3 and e.icon2 then e.icon3:SetTexture(e.icon2:GetTexture()) end
                if e.icon2 then e.icon2:SetTexture(e.icon:GetTexture()) end
                e.icon:SetTexture(data.icon)
                e.frame._itemLink = data.link
            end
            UpdateStackIcons(e, effectiveKey == JUNK_KEY and newCount or 0)
            -- Jump to hold phase and reset hold timer so entry stays visible
            local entranceDur = GetQualityEntrance(e.quality)
            e.elapsed = entranceDur
            e.driftY  = 0
            e.holdDur = Augment.GetHoldDur(data.kind, data.quality)
            return true
        end
    end
    return false
end

-- ============================================================================
-- SHOW TOAST
-- ============================================================================

function Augment.ShowToast(data)
    if not addon:IsModuleEnabled("augment") or not data then return end
    if not IsReady() then return end

    local effectiveKey = GetEffectiveItemKey(data)
    if effectiveKey and TryMergeToast(data, effectiveKey) then return end

    local entry = AcquireEntry()

    for i = 1, Augment.POOL_SIZE do
        if state.pool[i].active then
            state.pool[i].stackY = state.pool[i].stackY + S(Augment.LINE_HEIGHT)
        end
    end

    local initialCount = data.count or 1
    local displayText = effectiveKey
        and BuildMergedText(data, effectiveKey, initialCount)
        or  data.text

    entry.icon:SetTexture(data.icon)
    entry.iconBg:SetColorTexture(data.br, data.bg, data.bb, 0.8)
    entry._bgR, entry._bgG, entry._bgB = data.br, data.bg, data.bb
    entry.text:SetText(displayText)
    entry.text:SetTextColor(data.r, data.g, data.b, 1)
    entry.shadow:SetText(displayText)
    entry.frame._itemLink = data.link
    entry._itemKey     = effectiveKey
    entry._count       = initialCount
    -- For junk entries remember the originating item so TryMergeToast can tell
    -- whether a subsequent loot is the same item (keep name) or a different one (switch to "Junk").
    entry._origItemKey = (effectiveKey == JUNK_KEY) and data.itemKey or nil
    UpdateStackIcons(entry, effectiveKey == JUNK_KEY and initialCount or 0)

    entry.active   = true
    entry.elapsed  = 0
    entry.holdDur  = Augment.GetHoldDur(data.kind, data.quality)
    entry.quality  = data.quality
    -- Snapshot opacity at show-time so each toast has consistent alpha throughout its lifecycle
    -- without a per-frame DB read.
    entry.maxAlpha = math.max(0.1, math.min(1.0,
        (addon.GetDB and tonumber(addon.GetDB("augmentToastOpacity", addon.AUGMENT_DEFAULTS.augmentToastOpacity)) or addon.AUGMENT_DEFAULTS.augmentToastOpacity) / 100))
    entry.stackY   = 0
    entry.smoothY  = 0
    entry.driftY   = 0

    entry.frame:SetAlpha(0)
    entry.frame:SetScale(1)
    entry.shine:SetAlpha(0)
    entry.shine:Hide()

    local ycc = addon.GetModuleClassColor and addon.GetModuleClassColor("augment")
    if ycc then
        entry.shine:SetVertexColor(ycc[1], ycc[2], ycc[3])
    else
        entry.shine:SetVertexColor(1, 1, 1)
    end

    entry.frame:ClearAllPoints()
    entry.frame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", Augment.SLIDE_DIST, 0)
    entry.frame:Show()
    Frame:Show()

    PlayToastSound(data)

    state.activeCount = state.activeCount + 1
    UpdateFrameSize()
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function Augment.ToggleEditMode()
    if not IsReady() then return end
    state.editMode = not state.editMode
    if state.editMode then
        editOverlay:Show()
        Frame:Show()
        print("|cFF00CCFFHorizon Suite - Augment:|r Edit mode |cFF00FF00ON|r - drag the box to reposition.")
        Augment.ShowToast({
            kind = "item", icon = 135349, text = "Ashkandur, Fall of the Brotherhood",
            r = 0.64, g = 0.21, b = 0.93, br = 0.77, bg = 0.25, bb = 1.0, quality = 4,
        })
    else
        editOverlay:Hide()
        print("|cFF00CCFFHorizon Suite - Augment:|r Edit mode |cFFFF0000OFF|r")
    end
end

function Augment.RestoreSavedPosition()
    if not IsReady() then return end
    Augment.ApplyStoredAnchor(Frame)
end

function Augment.ResetPosition()
    if not IsReady() then return end
    Augment.ClearPosition()
    Augment.ApplyStoredAnchor(Frame)
    if anchorFrame and anchorFrame:IsShown() then
        Augment.ApplyStoredAnchor(anchorFrame)
    end
end

function Augment.ClearActiveToasts()
    if not IsReady() then return end
    for i = 1, Augment.POOL_SIZE do
        local e = state.pool[i]
        if e.active then
            e.active   = false
            e._itemKey = nil
            e._count   = nil
            e.frame:Hide()
            e.frame:SetAlpha(0)
            if e.icon2   then e.icon2:Hide()   end
            if e.icon3   then e.icon3:Hide()   end
            if e.iconBg2 then e.iconBg2:Hide() end
            if e.iconBg3 then e.iconBg3:Hide() end
        end
    end
    state.activeCount = 0
end

function Augment.SetFrameVisible(visible)
    if not IsReady() then return end
    if visible then Frame:Show() else Frame:Hide() end
end

function Augment.ToggleAnchorFrame()
    if not IsReady() then return end
    if anchorFrame:IsShown() then
        anchorFrame:Hide()
        HSPrint("Augment: Anchor hidden. Position saved.")
    else
        if InCombatLockdown() then return end
        Augment.ApplyStoredAnchor(anchorFrame)
        anchorFrame:Show()
        HSPrint("Augment: Drag the anchor, then right-click to confirm.")
    end
end

function Augment.HideAnchorFrame()
    if not IsReady() then return end
    anchorFrame:Hide()
end

function Augment.ApplyAugmentOptions()
    if not IsReady() then return end
    ApplyAugmentClassChrome()
    if anchorFrame:IsShown() then Augment.ApplyStoredAnchor(anchorFrame) end
    Augment.ApplyStoredAnchor(Frame)
    if Augment.ApplyScale then Augment.ApplyScale() end
    if Augment.ApplyBlizzardSuppression then Augment.ApplyBlizzardSuppression() end
end

--- Re-apply scale and font to all pool entries and overlay labels.
--- Called when UI scale or augmentFontPath changes.
function Augment.ApplyScale()
    if Augment.InvalidateCoinTextures then Augment.InvalidateCoinTextures() end
    if not IsReady() then return end
    UpdateAugmentFontObject()
    local fontPath  = Augment.GetFontPath()
    local fontSize  = S(GetFontSize())
    local fontFlags = GetFontFlags()
    UpdateFrameSize()
    for i = 1, Augment.POOL_SIZE do
        local e = state.pool[i]
        if e then
            if e.frame       then e.frame:SetSize(S(Augment.TOTAL_WIDTH), S(Augment.ENTRY_HEIGHT)) end
            local bgSz = S(Augment.ICON_SIZE + Augment.BORDER_PAD * 2)
            if e.iconBgAnchor then e.iconBgAnchor:SetSize(bgSz, bgSz) end
            if e.iconBg       then e.iconBg:SetSize(bgSz, bgSz) end
            -- For active junk stacks re-run the layout so sizes/positions rescale correctly.
            if e.active and e._itemKey == JUNK_KEY and e._count and e._count >= 2 then
                UpdateStackIcons(e, e._count)
            else
                if e.icon3 then e.icon3:Hide() end
                if e.icon2 then e.icon2:Hide() end
                if e.icon  then e.icon:SetSize(S(Augment.ICON_SIZE), S(Augment.ICON_SIZE)) end
            end
            if e.shine  then e.shine:SetSize(S(Augment.ICON_SIZE + 8), S(Augment.ICON_SIZE + 8)) end
            -- Explicit per-FontString SetFont overrides any direct-set override a
            -- third-party addon may have applied on top of our FontObject.
            if e.shadow then e.shadow:SetFont(fontPath, fontSize, fontFlags) end
            if e.text   then e.text:SetFont(fontPath, fontSize, fontFlags) end
        end
    end
    if editTitle   then editTitle:SetFont(fontPath, S(14), "OUTLINE") end
    if editHint    then editHint:SetFont(fontPath,  S(10), "OUTLINE") end
    if anchorLabel then anchorLabel:SetFont(fontPath, S(12), "OUTLINE") end
    if anchorHint  then anchorHint:SetFont(fontPath,  S(10), "OUTLINE") end
end
