--[[
    Horizon Suite - Augment / Alerts - Core
    Frame pool, stacking, and fade animation for Alerts toasts. Visual style
    is deliberately much simpler than the Loot toast pool
    (modules/Augment/LootFrame/AugmentCore.lua): one icon + title/body line,
    no item-link stacking/merging, since these are status alerts rather than
    loot events.
]]

local addon = _G.HorizonSuite
local L = addon.L
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
A.ICON_BG_PAD  = 1  -- colored square border per side in Minimalist style (matches LootFrame's BORDER_PAD)
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

-- Blizzard native Edit Mode integration (mirrors LootFrame's
-- Augment.HookNativeEditMode in AugmentCore.lua). editMode = manual toggle
-- (A.ToggleEditMode); nativeEditMode = Blizzard's Edit Mode is open.
local editMode = false
local nativeEditMode = false
local editOverlay, editTitle, editHint, editModePanel

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

local function GetFontSize()
    local D = addon.AUGMENT_DEFAULTS
    return tonumber(A.GetDB("alertsFontSize", D.alertsFontSize)) or D.alertsFontSize
end

local function GetFontFlags()
    if not addon.GetDB then return "OUTLINE" end
    local D = addon.AUGMENT_DEFAULTS
    return A.GetDB("alertsTextOutlineType", D.alertsTextOutlineType) or "OUTLINE"
end

local function UpdateFontObject()
    if not AlertsFontObj then return end
    AlertsFontObj:SetFont(GetFontPath(), S(GetFontSize()), GetFontFlags())
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

-- After StartMoving/StopMovingOrSizing, WoW internally re-anchors to
-- ("TOPLEFT", UIParent, "BOTTOMLEFT", screenX, screenTopY), making GetPoint()
-- return TOPLEFT regardless of how the frame was originally anchored. Recompute
-- explicitly for a TOP/TOP anchor (A.DEFAULT_ANCHOR) instead of trusting GetPoint().
local function SaveFramePosition()
    local left, right, top = Frame:GetLeft(), Frame:GetRight(), Frame:GetTop()
    if not left or not right or not top then return end
    local centerX = (left + right) / 2
    local x = math.floor(centerX - (UIParent:GetLeft() + UIParent:GetRight()) / 2 + 0.5)
    local y = math.floor(top - UIParent:GetTop() + 0.5)
    A.SavePosition("TOP", "TOP", x, y)
end

local function CreateEntry(parent)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(S(A.WIDTH), S(A.HEIGHT))
    -- Default to Horizon backdrop; ApplyEntryStyle will override for other styles.
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    f:SetBackdropColor(0, 0, 0, 0.75)

    -- Minimalist style: colored border square + dark inner fill (both hidden by default).
    local iconBg = f:CreateTexture(nil, "BORDER")
    local bgSzInit = S(A.ICON_SIZE + A.ICON_BG_PAD * 2)
    iconBg:SetSize(bgSzInit, bgSzInit)
    iconBg:SetPoint("LEFT", f, "LEFT", 0, 0)
    iconBg:Hide()

    -- Dark fill sits between iconBg and the icon so transparent icons (e.g. Friends,
    -- Vault) don't bleed the kind colour through — only the 1px border shows colour.
    local iconDark = f:CreateTexture(nil, "ARTWORK", nil, -1)
    iconDark:SetSize(S(A.ICON_SIZE), S(A.ICON_SIZE))
    iconDark:SetPoint("CENTER", iconBg, "CENTER", 0, 0)
    iconDark:SetColorTexture(0, 0, 0, 0.85)
    iconDark:Hide()

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
        frame = f, iconBg = iconBg, iconDark = iconDark, icon = icon, title = title, body = body,
        active = false, elapsed = 0, holdDur = A.DEFAULT_HOLD,
        stackY = 0, smoothY = 0, maxAlpha = 1,
    }
end

-- Apply layout and background for the given style. Called on every ShowToast
-- and on ApplyScale for active entries so live style changes take effect.
local function ApplyEntryStyle(entry, style, r, g, b)
    entry.title:SetTextColor(r, g, b, 1)
    entry.frame:SetBackdropBorderColor(r, g, b, 0.7)
    if style == "minimalist" then
        entry.frame:SetBackdrop(nil)
        local bgSz = S(A.ICON_SIZE + A.ICON_BG_PAD * 2)
        entry.iconBg:SetSize(bgSz, bgSz)
        entry.iconBg:ClearAllPoints()
        entry.iconBg:SetPoint("LEFT", entry.frame, "LEFT", 0, 0)
        entry.iconBg:SetColorTexture(r, g, b, 0.85)
        entry.iconBg:Show()
        local iconSz = S(A.ICON_SIZE)
        entry.iconDark:SetSize(iconSz, iconSz)
        entry.iconDark:Show()
        entry.icon:ClearAllPoints()
        entry.icon:SetPoint("CENTER", entry.iconBg, "CENTER", 1, 0)
        -- Anchor text to iconBg edges (not frame) so the title/body stay within
        -- the colored square regardless of the frame's extra vertical padding.
        entry.title:ClearAllPoints()
        entry.title:SetPoint("TOPLEFT",   entry.iconBg, "TOPRIGHT",    8, -2)
        entry.title:SetPoint("RIGHT",     entry.frame,  "RIGHT",      -8,  0)
        entry.body:ClearAllPoints()
        entry.body:SetPoint("BOTTOMLEFT", entry.iconBg, "BOTTOMRIGHT", 8,  2)
        entry.body:SetPoint("RIGHT",      entry.frame,  "RIGHT",      -8,  0)
    else -- "horizon"
        entry.frame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        entry.frame:SetBackdropColor(0, 0, 0, 0.75)
        entry.iconBg:Hide()
        entry.iconDark:Hide()
        entry.icon:ClearAllPoints()
        entry.icon:SetPoint("LEFT", entry.frame, "LEFT", 8, 0)
        entry.title:ClearAllPoints()
        entry.title:SetPoint("TOPLEFT",   entry.icon, "TOPRIGHT",    8, -2)
        entry.title:SetPoint("RIGHT",     entry.frame, "RIGHT",     -8,  0)
        entry.body:ClearAllPoints()
        entry.body:SetPoint("BOTTOMLEFT", entry.icon, "BOTTOMRIGHT", 8,  2)
        entry.body:SetPoint("RIGHT",      entry.frame, "RIGHT",     -8,  0)
    end
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
    Frame:EnableMouse(true)

    -- Edit overlay — shown while Blizzard's native Edit Mode is open (or via
    -- A.ToggleEditMode), drag-repositions Frame, mirrors LootFrame's editOverlay.
    editOverlay = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
    editOverlay:SetAllPoints(Frame)
    editOverlay:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editOverlay:SetBackdropColor(0, 0, 0, 0.5)
    editOverlay:SetBackdropBorderColor(0.95, 0.65, 0.25, 0.8)
    editOverlay:SetFrameLevel(Frame:GetFrameLevel() + 10)
    editOverlay:EnableMouse(false)
    editOverlay:RegisterForDrag("LeftButton")
    editOverlay:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        Frame:SetMovable(true)
        Frame:StartMoving()
    end)
    editOverlay:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        Frame:StopMovingOrSizing()
        Frame:SetMovable(false)
        SaveFramePosition()
    end)
    editOverlay:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            if A.PreviewAlerts then A.PreviewAlerts() end
        end
    end)
    editOverlay:Hide()

    editTitle = editOverlay:CreateFontString(nil, "OVERLAY")
    editTitle:SetFontObject(GameFontNormalLarge)
    editTitle:SetTextColor(0.95, 0.65, 0.25, 1)
    editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
    editTitle:SetText(L["ALERTS_EDIT_MODE_AREA"])

    editHint = editOverlay:CreateFontString(nil, "OVERLAY")
    editHint:SetFontObject(GameFontNormalSmall)
    editHint:SetTextColor(0.7, 0.7, 0.7, 1)
    editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
    editHint:SetText(L["ALERTS_EDIT_MODE_HINT"])

    AlertsFontObj = _G["HorizonSuiteAlertsFont"] or CreateFont("HorizonSuiteAlertsFont")
    UpdateFontObject()

    for i = 1, A.POOL_SIZE do
        pool[i] = CreateEntry(Frame)
    end

    Frame:SetScript("OnUpdate", function(self, dt)
        if activeCount == 0 then
            if not editMode and not nativeEditMode then self:Hide() end
            return
        end
        for i = 1, A.POOL_SIZE do
            if pool[i].active then A.UpdateEntry(pool[i], dt) end
        end
    end)

    A.Frame = Frame

    -- Defer font re-application to the next frame, matching LootFrame's pattern.
    -- The global font object may not have been applied yet when InitFrames runs
    -- synchronously at login, causing GetFontPath() to fall back to the game default.
    C_Timer.After(0, function() A.ApplyScale() end)

    -- Table-field call, so definition order below doesn't matter (A.HookNativeEditMode
    -- is assigned before this ever runs — InitFrames only executes from Enable(), well
    -- after file load).
    A.HookNativeEditMode()
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
    local maxA = entry.maxAlpha or 1

    if t < entEnd then
        local p = Ease(t / A.ENTRANCE_DUR)
        alpha  = p * maxA
        slideX = A.SLIDE_DIST * (1 - p)
    elseif t < holdEnd then
        alpha, slideX = maxA, 0
    elseif t < fadeEnd then
        alpha  = (1 - Ease((t - holdEnd) / A.EXIT_DUR)) * maxA
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

    local r, g, b = A.GetKindColor(kind)
    local kindIcon = A.KIND_ICONS[kind]
    if type(kindIcon) == "table" and kindIcon.atlas then
        entry.icon:SetAtlas(kindIcon.atlas, false)
    else
        entry.icon:SetTexture(kindIcon)
        entry.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    entry.icon:SetSize(S(A.ICON_SIZE), S(A.ICON_SIZE))

    local D = addon.AUGMENT_DEFAULTS
    entry._kind = kind
    ApplyEntryStyle(entry, A.GetDB("alertsStyle", D.alertsStyle), r, g, b)

    entry.title:SetText(title)
    entry.title:SetTextColor(r, g, b, 1)
    entry.body:SetText(body)
    entry.frame:SetBackdropBorderColor(r, g, b, 0.7)

    local D = addon.AUGMENT_DEFAULTS

    entry.active  = true
    entry.elapsed = 0
    entry.holdDur = tonumber(meta and meta.duration) or tonumber(A.GetDB("alertsHoldDuration", D.alertsHoldDuration)) or D.alertsHoldDuration
    entry.stackY  = 0
    entry.smoothY = 0
    -- Snapshot opacity at show-time so this toast's alpha is consistent
    -- throughout its lifecycle without a per-frame DB read (mirrors LootFrame's
    -- entry.maxAlpha pattern in AugmentCore.lua).
    entry.maxAlpha = math.max(0.1, math.min(1.0,
        (tonumber(A.GetDB("alertsOpacity", D.alertsOpacity)) or D.alertsOpacity) / 100))

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
    -- Don't force-hide Frame here: while editMode/nativeEditMode is active it
    -- must stay visible even with zero active toasts. The OnUpdate hide-check
    -- (which respects both flags) takes care of it on the very next tick.
end

-- Re-apply scale and font to all pool entries. Called when the Alerts scale
-- or font option changes.
function A.ApplyScale()
    if not framesCreated then return end
    UpdateFontObject()
    Frame:SetSize(S(A.WIDTH), S(A.LINE_HEIGHT))
    local D = addon.AUGMENT_DEFAULTS
    local style = A.GetDB("alertsStyle", D.alertsStyle)
    for i = 1, A.POOL_SIZE do
        local e = pool[i]
        e.frame:SetSize(S(A.WIDTH), S(A.HEIGHT))
        e.icon:SetSize(S(A.ICON_SIZE), S(A.ICON_SIZE))
        if e._kind then
            local r, g, b = A.GetKindColor(e._kind)
            ApplyEntryStyle(e, style, r, g, b)
        end
    end
end

function A.RestoreSavedPosition()
    if not framesCreated then return end
    A.ApplyStoredAnchor(Frame)
end

function A.ResetPosition()
    if not framesCreated then return end
    A.ClearPosition()
    A.ApplyStoredAnchor(Frame)
end

-- ============================================================================
-- BLIZZARD NATIVE EDIT MODE
-- Mirrors LootFrame's Augment.HookNativeEditMode/ToggleEditMode/
-- CreateEditModePanel (AugmentCore.lua) so the Alerts toast stack is
-- draggable the same way inside Blizzard's Edit Mode, with its own
-- DB-backed position (alertsPoint/alertsRelPoint/alertsX/alertsY) and its
-- own "show this overlay" checkbox (alertsEditModeShow) independent of
-- LootFrame's equivalents.
-- ============================================================================

-- Manual toggle (no Blizzard Edit Mode required) — same effect as opening
-- native Edit Mode with the panel checkbox on, for testing/positioning outside it.
function A.ToggleEditMode()
    if not framesCreated then return end
    editMode = not editMode
    if editMode then
        editOverlay:EnableMouse(true)
        editOverlay:Show()
        Frame:Show()
        A.Enqueue("DURABILITY", L["ALERTS_DURABILITY_TITLE"],
            string.format(L["ALERTS_DURABILITY_BODY"], 25))
    else
        if not nativeEditMode then editOverlay:EnableMouse(false) end
        editOverlay:Hide()
    end
end

local function CreateEditModePanel()
    if editModePanel then return end

    if addon.Augment and addon.Augment.editModePanel then
        -- Attach to LootFrame's panel: register a callback so the master checkbox
        -- toggles our overlay too. No second checkbox — one "Horizon Suite" toggle
        -- controls all Horizon Suite Edit Mode elements (mirrors Plumber's design).
        editModePanel = addon.Augment.editModePanel
        editModePanel.onCheckboxToggle = function(checked)
            if addon.SetDB then addon.SetDB("alertsEditModeShow", checked) end
            if nativeEditMode and framesCreated then
                if checked then
                    editOverlay:EnableMouse(true)
                    editOverlay:Show()
                    Frame:Show()
                else
                    editOverlay:EnableMouse(false)
                    editOverlay:Hide()
                    if activeCount == 0 then Frame:Hide() end
                end
            end
        end
        return
    end

    -- Standalone fallback: LootFrame panel not available.
    editModePanel = CreateFrame("Frame", nil, UIParent)
    editModePanel:SetSize(168, 44)
    editModePanel:SetFrameStrata("DIALOG")
    editModePanel:SetFrameLevel(200)
    editModePanel:EnableMouse(true)
    editModePanel:Hide()

    editModePanel.Border = CreateFrame("Frame", nil, editModePanel, "DialogBorderTranslucentTemplate")

    local checkbox = CreateFrame("CheckButton", nil, editModePanel, "UICheckButtonTemplate")
    checkbox:SetSize(26, 26)
    checkbox:SetPoint("LEFT", editModePanel, "LEFT", 14, 0)
    editModePanel.checkbox = checkbox

    local label = editModePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    label:SetText(L["NAME_ADDON"])
    label:SetTextColor(0.95, 0.65, 0.25, 1.0)
    label:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)

    local function ShowTip(anchor)
        GameTooltip:SetOwner(anchor, "ANCHOR_CURSOR")
        GameTooltip:SetText(L["ALERTS_EDIT_MODE_TOGGLE_HORIZON"], 1, 1, 1, 1, true)
        GameTooltip:AddLine(L["ALERTS_EDIT_MODE_SHOW_ELEMENTS"], 1, 1, 1, 1, true)
        GameTooltip:AddLine(L["ALERTS_EDIT_MODE_ALERTS_ITEM"], 0.8, 0.8, 0.8, 1)
        GameTooltip:AddLine(" ", 1, 1, 1, 1)
        GameTooltip:AddLine(L["ALERTS_EDIT_MODE_VISIBILITY_ONLY"], 0.7, 0.7, 0.7, 1, true)
        GameTooltip:Show()
    end
    local function HideTip() GameTooltip:Hide() end
    editModePanel:SetScript("OnEnter", function(self) ShowTip(self) end)
    editModePanel:SetScript("OnLeave", HideTip)
    checkbox:SetScript("OnEnter", function(self) ShowTip(self) end)
    checkbox:SetScript("OnLeave", HideTip)

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        if addon.SetDB then addon.SetDB("alertsEditModeShow", checked) end
        if nativeEditMode and framesCreated then
            if checked then
                editOverlay:EnableMouse(true)
                editOverlay:Show()
                Frame:Show()
            else
                editOverlay:EnableMouse(false)
                editOverlay:Hide()
                if activeCount == 0 then Frame:Hide() end
            end
        end
    end)

    editModePanel.t = 1
    editModePanel:SetScript("OnUpdate", function(self, elapsed)
        self.t = self.t + elapsed
        if self.t < 0.25 then return end
        self.t = 0
        if not EditModeManagerFrame or not EditModeManagerFrame:IsShown() then return end

        local x = EditModeManagerFrame:GetRight() - 16
        local y = EditModeManagerFrame:GetTop() - 104

        local function safeIsShown(f)
            local ok, v = pcall(f.IsShown, f); return ok and v
        end
        if not self.aboveFrame or not safeIsShown(self.aboveFrame) then
            self.aboveFrame = nil
            for _, child in ipairs({ UIParent:GetChildren() }) do
                if child ~= self and safeIsShown(child) then
                    local _, cl = pcall(child.GetLeft, child)
                    local _, ct = pcall(child.GetTop, child)
                    if type(cl) == "number" and type(ct) == "number"
                        and math.abs(cl - x) < 60 and math.abs(ct - y) < 30
                    then
                        self.aboveFrame = child
                        break
                    end
                end
            end
        end
        if self.aboveFrame and safeIsShown(self.aboveFrame) then
            local _, bottom = pcall(self.aboveFrame.GetBottom, self.aboveFrame)
            if type(bottom) == "number" then y = bottom - 20 end
        end

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    end)
end

function A.HookNativeEditMode()
    EventRegistry:RegisterCallback("EditMode.Enter", function()
        if not framesCreated then return end
        nativeEditMode = true

        local D = addon.AUGMENT_DEFAULTS
        local showOverlay = not addon.GetDB or addon.GetDB("alertsEditModeShow", D.alertsEditModeShow) ~= false

        if editModePanel and editModePanel ~= addon.Augment.editModePanel then
            -- Standalone: own the panel show/hide and checkbox state.
            if editModePanel.checkbox then editModePanel.checkbox:SetChecked(showOverlay) end
            editModePanel:Show()
        end
        -- Attached path: LootFrame owns panel show/hide; we just apply our overlay state.

        if showOverlay then
            editOverlay:EnableMouse(true)
            editOverlay:Show()
            Frame:Show()
            A.Enqueue("DURABILITY", L["ALERTS_DURABILITY_TITLE"],
                string.format(L["ALERTS_DURABILITY_BODY"], 25))
        end
    end, "HorizonSuiteAugmentAlerts")

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        if not framesCreated then return end
        -- Defer to next frame: Blizzard's synchronous EditMode exit chain can taint
        -- secure frame state if we react inline (same reasoning as LootFrame).
        C_Timer.After(0, function()
            nativeEditMode = false
            if not editMode then
                editOverlay:EnableMouse(false)
                editOverlay:Hide()
            end
            -- Only hide the panel if we own it (standalone); LootFrame hides it otherwise.
            if editModePanel and editModePanel ~= addon.Augment.editModePanel then
                editModePanel:Hide()
            end
            SaveFramePosition()
            if activeCount == 0 and not editMode then Frame:Hide() end
        end)
    end, "HorizonSuiteAugmentAlerts")

    CreateEditModePanel()
end
