--[[
    Horizon Suite - Horizon Insight (Core)
    Orchestration: init/disable, tooltip hooks, anchor, slash commands.
    Player/NPC/Item logic lives in InsightPlayerTooltip, InsightNpcTooltip, InsightItemTooltip.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- ============================================================================
-- LOCAL REFS (from InsightShared)
-- ============================================================================

local FIXED_POINT = Insight.FIXED_POINT
local FIXED_X     = Insight.FIXED_X
local FIXED_Y     = Insight.FIXED_Y

-- ============================================================================
-- HELPERS
-- ============================================================================

local function GetAnchorMode()
    return addon.GetDB("insightAnchorMode", Insight.DEFAULT_ANCHOR)
end

local function GetFixedPoint()
    return addon.GetDB("insightFixedPoint", FIXED_POINT)
end

local function GetFixedX()
    return tonumber(addon.GetDB("insightFixedX", FIXED_X)) or FIXED_X
end

local function GetFixedY()
    return tonumber(addon.GetDB("insightFixedY", FIXED_Y)) or FIXED_Y
end

-- ============================================================================
-- ITEM IDENTITY (moved above tooltip hooks so OnShow closure can reference)
-- ============================================================================

local function GetItemQualityColor(quality)
    if not quality or quality < 0 then return nil end
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        return c.r, c.g, c.b
    end
    return nil
end

local function ApplyItemIdentity(tooltip, quality)
    if not addon.GetDB("insightItemQualityBorder", true) then return end
    local r, g, b = GetItemQualityColor(quality)
    if not r then return end
    if tooltip.SetBackdropBorderColor then
        tooltip:SetBackdropBorderColor(r, g, b, 0.60)
    end
end

-- ============================================================================
-- TOOLTIP STYLING (hooks into Shared)
-- ============================================================================

local tooltipsToStyle = {}
local hookedShow      = {}

-- Close styled tooltips when combat suppression is on (option + lockdown).
local function HideStyledTooltipsIfCombatSuppressionActive()
    if not Insight.IsInsightEnabled() then return end
    if not addon.GetDB("insightHideTooltipsInCombat", false) then return end
    if not InCombatLockdown() then return end
    for _, tt in ipairs(tooltipsToStyle) do
        if tt and tt.Hide then
            pcall(tt.Hide, tt)
        end
    end
end

local function HookTooltipOnShow(tooltip)
    tooltip:HookScript("OnShow", function(self)
        if not Insight.IsInsightEnabled() then return end
        -- Suppress when ProcessUnitTooltip is driving Show(); it will call StyleTooltipFull itself.
        if self._insightSuppressOnShowStyle then return end
        if addon.GetDB("insightHideTooltipsInCombat", false) and InCombatLockdown() then
            self:Hide()
            return
        end
        -- Rapid re-show (AH browsing): skip backdrop reset to avoid flash; TDP post-call applies correct styling.
        if self._insightLastHideTime and (GetTime() - self._insightLastHideTime) < 0.15 then
            Insight.StripNineSlice(self)
            return
        end
        Insight.StripNineSlice(self)
        Insight.ApplyBackdrop(self)
    end)
end

local function HookTooltipShowMethod(tooltip)
    if hookedShow[tooltip] then return end
    hookedShow[tooltip] = true
    hooksecurefunc(tooltip, "Show", function(self)
        if not Insight.IsInsightEnabled() then return end
        -- Suppress when ProcessUnitTooltip is driving Show(); StyleTooltipFull handles fonts after Show().
        if self._insightSuppressOnShowStyle then return end
        if not self._insightUnitTooltip and not self._insightItemMetadata then
            self._insightTooltipType = "other"
        end
        Insight.StyleFonts(self)
        -- Re-apply item name gradient after Show(): the TDP post-call can be
        -- undone by later Blizzard line updates (padding, size recalculation,
        -- comparison-tooltip repositioning), so this is the reliable site.
        if self._insightItemQuality and Insight.ApplyItemNameGradient then
            Insight.ApplyItemNameGradient(self, self._insightItemQuality)
        end
    end)
end

-- ============================================================================
-- LIFECYCLE (no animation; just tracking)
-- ============================================================================

-- Branch only on hook-maintained literals. IsShown/IsMouseOver returns can be secret booleans on Midnight:
-- do not truth-test or compare them — even `v == true` errors. Use OnShow/OnHide and OnEnter/OnLeave + EnableMouse.
local function TooltipPlainShown(tt)
    return tt and tt._insightPlainShown == true
end

-- UnitDocumentation: UnitExists uses SecretArguments AllowedWhenUntainted; from tainted addon code the
-- return can be a secret boolean — never use it in `if`, `and`, `not`, or store via `pcall` + `and`.
-- Do not compare or type-check `unit` before pcall: GetUnit may yield a secret token (Midnight).
-- Returns plain true/false when known, or nil when the probe fails or cannot be evaluated safely.
local function SafeUnitExistsKnown(unit)
    local exists
    local ok = pcall(function()
        if UnitExists(unit) then
            exists = true
        else
            exists = false
        end
    end)
    if not ok then
        return nil
    end
    return exists
end

local function HookGameTooltipLifecycle()
    GameTooltip:HookScript("OnShow", function(self)
        self._insightPlainShown = true
        -- Reset per-show so re-hover of same unit always reprocesses.
        self._insightUnitTooltipDedup = nil
        self._insightStyled = nil
        if not Insight.IsInsightEnabled() then return end
        if addon.GetDB("insightHideTooltipsInCombat", false) and InCombatLockdown() then
            self:Hide()
            return
        end
        local hasUnit = false
        if self.GetUnit then
            local ok, u = pcall(self.GetUnit, self)
            if ok then
                hasUnit = (SafeUnitExistsKnown(u) == true)
            end
        end
        if hasUnit then
            local fn = Insight.StripHealthAndPowerText
            if fn then fn() end
        end
    end)
    GameTooltip:HookScript("OnHide", function(self)
        self._insightPlainShown = false
        self._insightUnitTooltipDedup = nil
        self._insightItemQuality = nil
        self._insightUnitTooltip = nil
        self._insightTooltipType = nil
        self._insightStyled = nil
        if self._insightLineTags then wipe(self._insightLineTags) end
        self._insightLastHideTime = GetTime()
    end)
    -- Reset dedup guard on every SetUnit so Blizzard periodic refreshes (nameplates,
    -- target frames) always re-add our custom lines. _insightStyled is NOT cleared here
    -- because backdrop/font styling persists and doesn't need reapplying per refresh.
    hooksecurefunc(GameTooltip, "SetUnit", function(self)
        self._insightUnitTooltipDedup = nil
    end)
end

local function HookTooltipLifecycle(tt)
    if not tt then return end
    tt:HookScript("OnShow", function(self)
        self._insightPlainShown = true
    end)
    tt:HookScript("OnHide", function(self)
        self._insightPlainShown = false
    end)
end

-- ============================================================================
-- HEALTH/POWER STRIP
-- ============================================================================

local function ClearStatusBarText()
    for i = 1, 5 do
        local text = _G["GameTooltipStatusBar" .. i .. "Text"]
        if text then text:SetText("") end
        local bar = _G["GameTooltipStatusBar" .. i]
        if bar then bar:Hide() end
    end
end

local function StripHealthAndPowerText(tt)
    tt = tt or GameTooltip
    if not tt then return end
    ClearStatusBarText()
    Insight.ForTooltipLines(tt, function(i, left, right)
        for _, font in ipairs({ left, right }) do
            if font then
                pcall(function()
                    local ok2, rawVal = pcall(font.GetText, font)
                    local raw = tostring((ok2 and rawVal) or "")
                    local okCmp, notEmpty = pcall(function() return raw ~= "" end)
                    if okCmp and notEmpty then
                        local text = raw:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                        if text:match("^%s*%d[%d,]*%s*/%s*%d[%d,]*%s*$") then
                            font:SetText("")
                        end
                    end
                end)
            end
        end
    end)
end
Insight.StripHealthAndPowerText = StripHealthAndPowerText

-- ============================================================================
-- POSITIONING
-- ============================================================================

-- Positioning is now handled by InsightCursorAnchor.lua

local function HideHealthBar()
    local bar = GameTooltip.StatusBar
    if bar then
        bar:Hide()
        bar:HookScript("OnShow", function(self) self:Hide() end)
    end
end

-- ============================================================================
-- UNIT TOOLTIP DISPATCH
-- ============================================================================

-- Show() runs HookTooltipOnShow → ApplyBackdrop, which resets border to PANEL_BORDER.
-- Process*Tooltip sets reaction/class border before Show(); re-apply after Show returns.
local function ReapplyUnitTooltipBorder(tooltip, unit, isPlayer)
    if not tooltip or not tooltip.SetBackdropBorderColor or not unit or SafeUnitExistsKnown(unit) ~= true then return end
    if isPlayer then
        local classFile = select(2, UnitClass(unit))
        local classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
        if classColor and addon.GetModuleClassColor and addon.GetModuleClassColor("insight") then
            tooltip:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.60)
        else
            tooltip:SetBackdropBorderColor(
                Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2],
                Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
        end
    else
        local reaction = UnitReaction(unit, "player")
        local c = (reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]) and FACTION_BAR_COLORS[reaction] or nil
        if c then
            tooltip:SetBackdropBorderColor(c.r, c.g, c.b, 0.60)
        else
            tooltip:SetBackdropBorderColor(
                Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2],
                Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
        end
    end
end

-- PlayerFrame / party frames: tooltip owns unit "player" or "party1" while mouseover is often empty.
-- GetUnit() may return a secret unit token on Midnight; never compare the string (e.g. to "").
local function ResolveTooltipUnitToken(tooltip)
    if tooltip and tooltip.GetUnit then
        local ok, u = pcall(tooltip.GetUnit, tooltip)
        if ok and SafeUnitExistsKnown(u) == true then
            return u
        end
    end
    if SafeUnitExistsKnown("mouseover") == true then
        return "mouseover"
    end
    return nil
end

local function ProcessUnitTooltip(tooltip)
    if not Insight.IsInsightEnabled() or not tooltip then return end
    local unit = ResolveTooltipUnitToken(tooltip)
    if not unit then return end

    -- If Blizzard already showed the tooltip, a second Show() re-runs OnShow (backdrop) and flashes.
    local alreadyVisible = TooltipPlainShown(tooltip)

    tooltip._insightItemMetadata = nil
    tooltip._insightUnitTooltip  = true
    if tooltip._insightLineTags then wipe(tooltip._insightLineTags) end
    -- Never compare UnitIsPlayer return; assign plain literals inside pcall only.
    local isPlayer = false
    pcall(function()
        if UnitIsPlayer(unit) then
            isPlayer = true
        else
            isPlayer = false
        end
    end)
    tooltip._insightTooltipType = isPlayer and "player" or "npc"

    StripHealthAndPowerText(tooltip)

    local processed = false
    if not isPlayer then
        processed = Insight.ProcessNpcTooltip(unit, tooltip)
    else
        processed = Insight.ProcessPlayerTooltip(unit, tooltip)
    end

    if processed then
        if not alreadyVisible then
            -- Suppress OnShow/Show hooks so StyleTooltipFull below is the single authoritative styling pass.
            tooltip._insightSuppressOnShowStyle = true
            tooltip:Show()
            tooltip._insightSuppressOnShowStyle = nil
        end
        -- Strip after Show (Show() can repopulate Blizzard health/power text).
        StripHealthAndPowerText(tooltip)
        -- Apply cinematic chrome once per tooltip lifetime; cleared on OnHide for the next hover.
        if not tooltip._insightStyled then
            Insight.StyleTooltipFull(tooltip)
            tooltip._insightStyled = true
        end
        pcall(ReapplyUnitTooltipBorder, tooltip, unit, isPlayer)
    end
end

-- ============================================================================
-- ITEM TOOLTIP
-- ============================================================================

local function ShowTransmog()
    return addon.GetDB("insightShowTransmog", true)
end

local function OnItemTooltip(tooltip, data)
    if not Insight.IsInsightEnabled() then return end

    local itemID = data and data.id
    if not itemID then return end

    -- Item identity: quality-colored border and separator tint
    local quality = data and data.quality
    if not quality and C_Item and C_Item.GetItemInfo then
        local info = C_Item.GetItemInfo(itemID)
        quality = info and info.quality
    end
    if quality and quality >= 0 then
        local r, g, b = GetItemQualityColor(quality)
        if r then
            Insight.sepR, Insight.sepG, Insight.sepB = r, g, b
        end
        tooltip._insightItemQuality = quality
        ApplyItemIdentity(tooltip, quality)
    else
        Insight.sepR, Insight.sepG, Insight.sepB = nil, nil, nil
        tooltip._insightItemQuality = nil
    end

    -- Gradient is width-neutral (no AddLine), safe for ShoppingTooltip1/2.
    if Insight.ApplyItemNameGradient then
        Insight.ApplyItemNameGradient(tooltip, quality)
    end

    -- Comparison tooltips get quality borders + name gradient (above) but no line enrichment:
    -- adding lines triggers Blizzard to reposition them, re-firing Show() repeatedly.
    if tooltip == ShoppingTooltip1 or tooltip == ShoppingTooltip2 then return end

    tooltip._insightItemMetadata = true
    tooltip._insightTooltipType  = "item"
    tooltip._insightLastItemID   = itemID
    if tooltip._insightLineTags then wipe(tooltip._insightLineTags) end
    -- Structured item blocks (transmog, etc.)
    Insight.ProcessItemTooltip(tooltip, itemID, quality)
end

local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not Insight.IsInsightEnabled() then return end
    local unit = ResolveTooltipUnitToken(tooltip)
    if not unit then return end
    -- Midnight: never compare UnitGUID from tainted paths (secret string). Dedupe via hook-owned flag instead.
    if tooltip._insightUnitTooltipDedup == true then return end
    tooltip._insightUnitTooltipDedup = true
    ProcessUnitTooltip(tooltip)
end

-- ============================================================================
-- ANCHOR FRAME
-- ============================================================================

local anchorFrame = CreateFrame("Frame", "HorizonSuiteInsightAnchor", UIParent, "BackdropTemplate")
anchorFrame:SetSize(160, 40)
anchorFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", FIXED_X, FIXED_Y)
anchorFrame:SetBackdrop(Insight.CINEMATIC_BACKDROP)
anchorFrame:SetBackdropColor(0, 0, 0, 0.85)
anchorFrame:SetBackdropBorderColor(0.50, 0.70, 1.0, 0.60)
anchorFrame:SetMovable(true)
anchorFrame:EnableMouse(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetFrameStrata("DIALOG")
anchorFrame:Hide()
anchorFrame:HookScript("OnShow", function(self)
    self._insightPlainShown = true
end)
anchorFrame:HookScript("OnHide", function(self)
    self._insightPlainShown = false
end)

local anchorLabel = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorLabel:SetFont(Insight.FONT_PATH, Insight.Scaled(Insight.BODY_SIZE), "OUTLINE")
anchorLabel:SetPoint("CENTER")
anchorLabel:SetTextColor(0.50, 0.70, 1.0, 1)
anchorLabel:SetText("TOOLTIP ANCHOR")

local anchorHint = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorHint:SetFont(Insight.FONT_PATH, Insight.Scaled(Insight.SMALL_SIZE), "OUTLINE")
anchorHint:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -4)
anchorHint:SetTextColor(0.60, 0.60, 0.60, 1)
anchorHint:SetText("Drag to move · Right-click to confirm")

anchorFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then self:StartMoving() end
end)
anchorFrame:SetScript("OnDragStop", function(self)
    if InCombatLockdown() then return end
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    addon.SetDB("insightFixedPoint", point)
    addon.SetDB("insightFixedX", math.floor(x + 0.5))
    addon.SetDB("insightFixedY", math.floor(y + 0.5))
end)

anchorFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        self:Hide()
        addon.SetDB("insightAnchorMode", "fixed")
        Insight.Print("Horizon Insight: Position saved. Anchor set to FIXED.")
    end
end)

local function ShowAnchorFrame()
    if InCombatLockdown() then return end
    Insight.ApplyStoredAnchor(anchorFrame)
    anchorFrame:Show()
    addon.SetDB("insightAnchorMode", "fixed")
    Insight.Print("Horizon Insight: Drag the anchor, then right-click to confirm.")
end

local function HideAnchorFrame()
    anchorFrame:Hide()
end

local function ApplyLiveBackdropColor(tooltip)
    if not tooltip or not TooltipPlainShown(tooltip) or not tooltip.SetBackdropColor then return end
    local r, g, b, a = Insight.GetBackdropColor()
    tooltip:SetBackdropColor(r, g, b, a)
end

-- ============================================================================
-- DASHBOARD PREVIEW (mock tooltip; shell lives in options/dashboard/DashboardPreviewPullout.lua)
-- ============================================================================

local PREVIEW_MODES = { global = true, player = true, npc = true, item = true }

--- Select which tooltip sample the dashboard preview shows when an Insight options page is active.
--- @param mode string "global" | "player" | "npc" | "item"
--- @return nil
function Insight.SetDashboardPreviewMode(mode)
    if type(mode) ~= "string" or not PREVIEW_MODES[mode] then return end
    Insight.dashboardPreviewMode = mode
    if addon.DashboardPreview and addon.DashboardPreview.NotifyRefresh then
        addon.DashboardPreview.NotifyRefresh()
    end
end

local MAX_PREVIEW_LINES  = 30
local PREVIEW_PAD_TOP    = 8
local PREVIEW_PAD_SIDE   = 10
local PREVIEW_PAD_BOTTOM = 10
local PREVIEW_LINE_GAP   = 2

local pulloutMock = nil

-- ---- Mock tooltip (AddLine / ClearLines / NumLines / Layout) ----

local MOCK_NAME = "HorizonSuiteInsightPreviewTooltip"

local function CreateMockTooltipFrame(parent)
    local mock = CreateFrame("Frame", MOCK_NAME, parent, "BackdropTemplate")

    for i = 1, MAX_PREVIEW_LINES do
        local fs = mock:CreateFontString(nil, "OVERLAY")
        -- SetFont before any SetText (ClearLines runs before StyleFonts on first show).
        fs:SetFont(Insight.FONT_PATH, Insight.Scaled(Insight.BODY_SIZE), "OUTLINE")
        fs:SetWordWrap(true)
        fs:SetJustifyH("LEFT")
        fs:Hide()
        _G[MOCK_NAME .. "TextLeft" .. i] = fs
    end

    mock._lineCount = 0

    function mock:NumLines()   return self._lineCount or 0 end

    function mock:ClearLines()
        for i = 1, MAX_PREVIEW_LINES do
            local fs = _G[MOCK_NAME .. "TextLeft" .. i]
            if fs then
                fs:SetText("")
                fs:Hide()
                fs._insightPlainLineShown = false
            end
        end
        self._lineCount      = 0
        self._insightLineTags = {}
    end

    function mock:AddLine(text, r, g, b)
        local i = (self._lineCount or 0) + 1
        if i > MAX_PREVIEW_LINES then return end
        self._lineCount = i
        local fs = _G[MOCK_NAME .. "TextLeft" .. i]
        if fs then
            fs:SetText(text or "")
            fs:SetTextColor(r or 1, g or 1, b or 1, 1)
            fs:Show()
            fs._insightPlainLineShown = true
        end
    end

    function mock:Layout()
        local w = self:GetWidth()
        if w <= 0 then w = 220 end
        local innerW  = math.max(w - PREVIEW_PAD_SIDE * 2, 40)
        local yOffset = -PREVIEW_PAD_TOP
        for i = 1, self._lineCount do
            local fs = _G[MOCK_NAME .. "TextLeft" .. i]
            if fs and fs._insightPlainLineShown then
                fs:ClearAllPoints()
                fs:SetWidth(innerW)
                fs:SetPoint("TOPLEFT", self, "TOPLEFT", PREVIEW_PAD_SIDE, yOffset)
                local h = fs:GetStringHeight()
                if h <= 0 then local _, fh = fs:GetFont(); h = (fh or 12) * 1.2 end
                yOffset = yOffset - h - PREVIEW_LINE_GAP
            end
        end
        self:SetHeight(math.max(math.abs(yOffset) + PREVIEW_PAD_BOTTOM, 40))
    end

    return mock
end

local function RefreshPullout()
    if not pulloutMock then return end
    pulloutMock:ClearLines()
    Insight.ApplyBackdrop(pulloutMock)
    local mode = Insight.dashboardPreviewMode or "global"
    if mode == "item" and Insight.RenderItemPreviewContent then
        Insight.RenderItemPreviewContent(pulloutMock)
    elseif mode == "npc" and Insight.RenderNpcPreviewContent then
        Insight.RenderNpcPreviewContent(pulloutMock)
    elseif mode == "player" and Insight.RenderTestTooltipContent then
        Insight.RenderTestTooltipContent(pulloutMock)
    else
        if Insight.RenderTestTooltipContent then Insight.RenderTestTooltipContent(pulloutMock) end
    end
    pulloutMock._insightTooltipType = (mode == "player" or mode == "npc" or mode == "item") and mode or nil
    Insight.StyleFonts(pulloutMock)
    local br, bg, bb, ba = 0.77, 0.12, 0.23, 0.60
    if mode == "npc" and FACTION_BAR_COLORS and FACTION_BAR_COLORS[2] then
        local c = FACTION_BAR_COLORS[2]
        br, bg, bb = c.r, c.g, c.b
    elseif mode == "item" then
        local id = Insight.DASHBOARD_PREVIEW_ITEM_ID or 168602
        if C_Item and C_Item.GetItemInfo then
            local info = C_Item.GetItemInfo(id)
            local q = info and info.quality
            if q and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] then
                local qc = ITEM_QUALITY_COLORS[q]
                br, bg, bb = qc.r, qc.g, qc.b
            end
        end
    end
    pulloutMock:SetBackdropBorderColor(br, bg, bb, ba)
    pulloutMock:Layout()
end

--- Toggle dashboard preview pullout (delegates to shared options shell).
function Insight.TogglePreviewPullout()
    if addon.DashboardPreview and addon.DashboardPreview.TogglePullout then
        addon.DashboardPreview.TogglePullout()
    end
end

function Insight.ClosePullout()
    if addon.DashboardPreview and addon.DashboardPreview.ClosePullout then
        addon.DashboardPreview.ClosePullout()
    end
end

--- @deprecated Prefer addon.DashboardPreview.InitDashboard; kept for callers.
function Insight.EnsurePreviewTab(dashFrame)
    if addon.DashboardPreview and addon.DashboardPreview.InitDashboard then
        addon.DashboardPreview.InitDashboard(dashFrame)
    end
end

-- ============================================================================
-- INIT / DISABLE / APPLY
-- ============================================================================

function Insight.ShowAnchorFrame()
    ShowAnchorFrame()
end

--- Toggle anchor visibility. Show if hidden, hide if shown. Used by settings button.
function Insight.ToggleAnchorFrame()
    if TooltipPlainShown(anchorFrame) then
        HideAnchorFrame()
        Insight.Print("Horizon Insight: Anchor hidden. Position saved.")
    else
        ShowAnchorFrame()
    end
end

function Insight.ApplyInsightOptions()
    if TooltipPlainShown(anchorFrame) then
        Insight.ApplyStoredAnchor(anchorFrame)
        ApplyLiveBackdropColor(anchorFrame)
    end
    for _, tt in ipairs(tooltipsToStyle) do
        tt._insightStyled = nil
        ApplyLiveBackdropColor(tt)
    end
    if addon.DashboardPreview and addon.DashboardPreview.NotifyRefresh then
        addon.DashboardPreview.NotifyRefresh()
    end
    HideStyledTooltipsIfCombatSuppressionActive()
end

function Insight.Init()
    if Insight.dashboardPreviewMode == nil then
        Insight.dashboardPreviewMode = "global"
    end

    tooltipsToStyle = {
        GameTooltip,
        ItemRefTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        EmbeddedItemTooltip,
    }

    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            Insight.StyleTooltipFull(tt)
            HookTooltipOnShow(tt)
            HookTooltipShowMethod(tt)
            if tt ~= GameTooltip then
                HookTooltipLifecycle(tt)
            end
        end
    end

    HookGameTooltipLifecycle()
    HideHealthBar()
    Insight.HookCursorAnchor()

    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        if Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnitTooltip)
        end
        if Enum.TooltipDataType.Item then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
        end
    end

    -- Defer LSM registration so IsAddOnLoaded is available (runs when API is ready)
    if C_Timer and C_Timer.After and addon.RegisterRondoClassIconsWithLSM then
        C_Timer.After(0, function()
            pcall(addon.RegisterRondoClassIconsWithLSM)
        end)
    end

    if addon.DashboardPreview and addon.DashboardPreview.Register then
        addon.DashboardPreview.Register("insight", {
            width = 260,
            title = "TOOLTIP PREVIEW",
            subtitle = "Updates as you change settings",
            tabTooltipTitle = "Tooltip Preview",
            tabTooltipBody = "Live preview — updates as you\nchange Insight settings.",
            MountContent = function(host)
                if not pulloutMock then
                    pulloutMock = CreateMockTooltipFrame(host)
                else
                    pulloutMock:SetParent(host)
                    pulloutMock:ClearAllPoints()
                end
                pulloutMock:SetPoint("TOPLEFT", host, "TOPLEFT", 10, -10)
                pulloutMock:SetPoint("RIGHT", host, "RIGHT", -10, 0)
                pulloutMock:SetHeight(300)
            end,
            refresh = function()
                RefreshPullout()
            end,
        })
    end
end

function Insight.Disable()
    HideAnchorFrame()
    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            Insight.RestoreNineSlice(tt)
            if tt.SetBackdrop then tt:SetBackdrop(nil) end
        end
    end
end

-- ============================================================================
-- INSPECT_READY
-- ============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "PLAYER_REGEN_DISABLED" then
        HideStyledTooltipsIfCombatSuppressionActive()
        return
    end
    if event == "UPDATE_MOUSEOVER_UNIT" then
        if not Insight.IsInsightEnabled() then return end
        if SafeUnitExistsKnown("mouseover") == false
            and TooltipPlainShown(GameTooltip)
            and GameTooltip._insightUnitTooltip then
            C_Timer.After(0, function()
                if SafeUnitExistsKnown("mouseover") ~= false then return end
                if not TooltipPlainShown(GameTooltip) then return end
                if not GameTooltip._insightUnitTooltip then return end
                GameTooltip:Hide()
            end)
        end
        return
    end
    if event == "INSPECT_READY" then
        if not Insight.IsInsightEnabled() then return end
        if not guid then return end
        if SafeUnitExistsKnown("mouseover") ~= true then return end
        local mouseoverGuid = UnitGUID("mouseover")
        local guidMatches = false
        pcall(function()
            if mouseoverGuid == guid then
                guidMatches = true
            else
                guidMatches = false
            end
        end)
        if guidMatches then
            Insight.CacheInspect(guid, "mouseover")
            if TooltipPlainShown(GameTooltip) and GameTooltip._insightUnitTooltip then
                GameTooltip:SetUnit("mouseover")
                C_Timer.After(0.25, function()
                    if not Insight.IsInsightEnabled() then return end
                    if not TooltipPlainShown(GameTooltip) then return end
                    if not GameTooltip._insightUnitTooltip then return end
                    if SafeUnitExistsKnown("mouseover") ~= false then return end
                    GameTooltip:Hide()
                end)
            end
        end
        if Insight.PruneInspectCache then Insight.PruneInspectCache() end
    end
end)

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================

local function HandleInsightSlash(msg)
    if not addon:IsModuleEnabled("insight") then
        Insight.Print("Horizon Insight is disabled. Enable it in Horizon Suite options.")
        return
    end

    local cmd = strtrim(msg or ""):lower()

    if cmd == "anchor" then
        local mode = GetAnchorMode()
        if mode == "cursor" then
            addon.SetDB("insightAnchorMode", "fixed")
            Insight.Print("Horizon Insight: Anchor → FIXED (" .. GetFixedPoint() .. ")")
        else
            addon.SetDB("insightAnchorMode", "cursor")
            Insight.Print("Horizon Insight: Anchor → CURSOR")
        end

    elseif cmd == "move" then
        if TooltipPlainShown(anchorFrame) then
            HideAnchorFrame()
            Insight.Print("Horizon Insight: Anchor hidden. Position saved.")
        else
            ShowAnchorFrame()
        end

    elseif cmd == "resetpos" then
        addon.SetDB("insightFixedPoint", FIXED_POINT)
        addon.SetDB("insightFixedX", FIXED_X)
        addon.SetDB("insightFixedY", FIXED_Y)
        HideAnchorFrame()
        Insight.Print("Horizon Insight: Fixed position reset to default.")

    elseif cmd == "test" then
        local ox = tonumber(addon.GetDB("insightCursorOffsetX", 0)) or 0
        local oy = tonumber(addon.GetDB("insightCursorOffsetY", 0)) or 0
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR", ox, oy)
        GameTooltip:ClearLines()
        Insight.RenderTestTooltipContent(GameTooltip)
        GameTooltip:Show()
        -- Defer so we run after OnShow/ApplyBackdrop; otherwise backdrop overwrites border color.
        C_Timer.After(0, function()
            if TooltipPlainShown(GameTooltip) then
                GameTooltip:SetBackdropBorderColor(0.77, 0.12, 0.23, 0.60)
            end
        end)
        Insight.Print("Horizon Insight: Test tooltip shown at cursor.")

    elseif cmd == "gradient" then
        -- Diagnostic: open an Epic sample tooltip, force-apply the gradient, and
        -- print what happened. Use this to confirm the option is on, the helper
        -- is wired, and whether the FontString text change is actually taking.
        local sampleID = 168602 -- same itemID the dashboard preview uses
        local enabled = addon.GetDB("insightItemNameGradient", true)
        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
        ItemRefTooltip:SetHyperlink("item:" .. sampleID)
        if not ItemRefTooltip:IsShown() then ItemRefTooltip:Show() end
        local fs = _G["ItemRefTooltipTextLeft1"]
        local before = (fs and fs.GetText and fs:GetText()) or "<no fs>"
        if Insight.ApplyItemNameGradient then
            Insight.ApplyItemNameGradient(ItemRefTooltip, 4)
        end
        local after = (fs and fs.GetText and fs:GetText()) or "<no fs>"
        local changed = (before ~= after)
        Insight.PrintBlock({
            "Horizon Insight — gradient diagnostic",
            "   Toggle         : " .. tostring(enabled),
            "   Has helper     : " .. tostring(Insight.ApplyItemNameGradient ~= nil),
            "   Before text    : " .. tostring(before):sub(1, 60),
            "   After  text    : " .. tostring(after):sub(1, 80),
            "   Text changed   : " .. tostring(changed),
        })

    else
        Insight.PrintBlock({
            "Horizon Insight",
            "  /insight, /h insight     This help",
            "  /insight anchor   Toggle cursor / fixed positioning",
            "  /insight move     Show draggable anchor to set fixed position",
            "  /insight resetpos Reset fixed position to default",
            "  /insight test     Show a sample styled tooltip",
            "  /insight gradient Diagnostic: force a quality gradient on ItemRefTooltip",
        })
    end
end

SLASH_HORIZONSUITEINSIGHT1 = "/insight"
SLASH_HORIZONSUITEINSIGHT2 = "/hsi"
SLASH_HORIZONSUITEINSIGHT3 = "/mtt"
SlashCmdList["HORIZONSUITEINSIGHT"] = HandleInsightSlash

local function HandleInsightDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        Insight.PrintBlock({
            "Insight debug commands (/h debug insight [cmd]):",
            "  status  - Print config + cache count",
            "  lsm     - Test LibSharedMedia classicon registration",
            "  path    - Show class icon paths (Rondo + custom sample)",
        })
        return
    end

    if cmd == "path" then
        local source = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
        local isRondo = false
        if C_AddOns and C_AddOns.IsAddOnLoaded then
            pcall(function()
                if C_AddOns.IsAddOnLoaded("RondoMedia") then
                    isRondo = true
                else
                    isRondo = false
                end
            end)
        end
        local rondo = addon.CLASS_ICON_RONDO_NAMES
        local displayName = rondo and rondo["WARRIOR"] or "Warrior"
        local folder = addon.ADDON_NAME or "HorizonSuite"
        local rondoPath = isRondo
            and ("Interface\\AddOns\\RondoMedia\\media\\Class_icons\\class_colored border\\32x32\\%s_32.tga"):format(displayName)
            or ("Interface\\AddOns\\%s\\media\\RondoClassIcons\\class_colored border\\32x32\\%s_32.tga"):format(folder, displayName)
        local customPath = ("Interface\\AddOns\\%s\\media\\CustomClassIcons\\WARRIOR\\warrior.tga"):format(folder)
        Insight.PrintBlock({
            "Class icon path debug",
            "   Class icon source : " .. source,
            "   RondoMedia loaded : " .. tostring(isRondo),
            "   Sample Rondo path : " .. rondoPath,
            "   Sample custom path: " .. customPath,
        })
        return
    end

    if cmd == "lsm" then
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if not LSM then
            Insight.Print("LibSharedMedia-3.0 not loaded.")
            return
        end
        local list = LSM.List and LSM:List("classicon") or {}
        local count = #list
        Insight.Print("LSM classicon: " .. count .. " entries")
        if count > 0 then
            for i = 1, math.min(5, count) do
                local key = list[i]
                local path = LSM.Fetch and LSM:Fetch("classicon", key, true)
                Insight.Print("  " .. key .. " -> " .. (path or "nil"))
            end
            if count > 5 then
                Insight.Print("  ... and " .. (count - 5) .. " more")
            end
        else
            Insight.Print("  (none registered; RondoMedia or Horizon Suite will register on init)")
        end
        return
    end

    if cmd == "status" then
        local cacheCount = 0
        if Insight.inspectCache then
            for _ in pairs(Insight.inspectCache) do cacheCount = cacheCount + 1 end
        end
        local classIconSource = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
        Insight.PrintBlock({
            "Horizon Insight Status",
            "   Enabled      : Yes",
            "   Anchor       : " .. GetAnchorMode(),
            "   Class icons  : " .. classIconSource,
            "   Cache        : " .. cacheCount .. " inspect entries",
        })
    else
        Insight.Print("Unknown debug command. Use /h debug insight for help.")
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("insight", HandleInsightSlash)
end
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("insight", HandleInsightDebugSlash)
end

addon.Insight = Insight

