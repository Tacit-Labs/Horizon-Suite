--[[
    Horizon Suite - Horizon Insight (Core)
    Orchestration: init/disable, tooltip hooks, anchor, slash commands.
    Player/NPC/Item logic lives in InsightPlayerTooltip, InsightNpcTooltip, InsightItemTooltip.
]]

local addon = _G.HorizonSuite

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local insightPanel = addon.Log.createPanel("insight", "Insight Debug", { maxLines = 300,
    onClose = function()
        if addon.SetDB then addon.SetDB("insightDebugLive", false) end
        addon.Log.enableTag("insight", nil)
    end,
})
addon.Log.registerTag("insight", "insightDebugLive")

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
    addon.Log.debug("insight", "combat suppression — hiding styled tooltips")
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
        self._insightUnitTooltipInstance = nil
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
        self._insightUnitTooltipInstance = nil
        self._insightItemQuality = nil
        self._insightUnitTooltip = nil
        self._insightTooltipType = nil
        self._insightStyled = nil
        if self._insightLineTags then wipe(self._insightLineTags) end
        self._insightLastHideTime = GetTime()
    end)
    -- Reset instance token on every SetUnit so Blizzard periodic refreshes
    -- (nameplates, target frames) always re-process our custom lines even if
    -- they reuse the same dataInstanceID. _insightStyled is NOT cleared here —
    -- backdrop/font styling persists and doesn't need reapplying per refresh.
    hooksecurefunc(GameTooltip, "SetUnit", function(self)
        self._insightUnitTooltipInstance = nil
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
        if addon.GetDB("insightTRP3BorderColor", false) and addon.GetDB("insightTRP3Enabled", true) and Insight.GetTRP3PlayerData then
            local trp3d = Insight.GetTRP3PlayerData(unit)
            if trp3d and trp3d.customColorR then
                tooltip:SetBackdropBorderColor(trp3d.customColorR, trp3d.customColorG, trp3d.customColorB, 0.60)
                return
            end
        end
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
    addon.Log.debug("insight", "ProcessUnitTooltip unit=" .. tostring(unit))

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
    addon.Log.debug("insight", "OnItemTooltip id=" .. tostring(itemID))

    -- Base quality: prefer C_Item.GetItemInfo on the full hyperlink (it's
    -- link-aware, so bonus IDs that bump or drop quality — e.g. a Tarnished
    -- delve item lifted to rare by its bonus chain — are reflected). Fall
    -- back to tooltip:GetItem(), then TDP data.quality, then itemID-only
    -- lookup which is base-only.
    local baseQuality
    local hyperlink = data.hyperlink
    if not hyperlink and tooltip.GetItem then
        local _, link = tooltip:GetItem()
        hyperlink = link
    end
    if hyperlink and C_Item and C_Item.GetItemInfo then
        local _, _, q = C_Item.GetItemInfo(hyperlink)
        baseQuality = q
    end
    if not baseQuality then baseQuality = data.quality end
    if not baseQuality and C_Item and C_Item.GetItemInfo then
        local _, _, q = C_Item.GetItemInfo(itemID)
        baseQuality = q
    end
    -- Effective gradient quality: use the upgrade track tier when present,
    -- since PvP and some other items report an inflated base quality that
    -- does not match their actual tier. Track quality always wins; fall back
    -- to base quality only when no track line is detected.
    local trackQuality = Insight.DetectUpgradeTrackQuality(tooltip)
    local quality = trackQuality or baseQuality

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
    -- One sync apply seeds the title; InstallItemNameGradientHook keeps it
    -- alive across Blizzard's later SetText / SetTextColor passes.
    Insight.ApplyItemNameGradient(tooltip)

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
    -- Dedupe by Blizzard's dataInstanceID (non-secret, bumps per tooltip display),
    -- not a sticky boolean. A fade-out→re-hover transition can refresh the
    -- tooltip contents without firing SetUnit/OnShow — the old boolean flag
    -- stayed `true` and silently blocked re-processing for the new unit.
    local instanceID = data and data.dataInstanceID
    if instanceID and tooltip._insightUnitTooltipInstance == instanceID then return end
    tooltip._insightUnitTooltipInstance = instanceID or true
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

local MAX_PREVIEW_LINES  = 50
local PREVIEW_PAD_TOP    = 8
local PREVIEW_PAD_SIDE   = 10
local PREVIEW_PAD_BOTTOM = 10
local PREVIEW_LINE_GAP   = 2
local PREVIEW_BASE_WIDTH        = 260   -- single player preview
local PREVIEW_GLOBAL_BASE_WIDTH = 290   -- global stacked preview without TRP3 (extra room for badge tags line)
local PREVIEW_GLOBAL_WIDTH      = 320   -- global stacked preview with TRP3 (long RP name)
local PREVIEW_NPC_WIDTH    = 200   -- compact NPC sample; +20 so Layout(w-20) gives innerW=160
local PREVIEW_ITEM_WIDTH   = 215   -- compact item sample; +20 so Layout(w-20) gives innerW=175
local PREVIEW_MAX_WIDTH  = 460

local pulloutMock = nil
local globalPlayerMock, globalNpcMock, globalItemMock = nil, nil, nil
local globalMockHost = nil

-- ---- Mock tooltip (AddLine / ClearLines / NumLines / Layout) ----

local MOCK_NAME = "HorizonSuiteInsightPreviewTooltip"

-- nameSuffix allows multiple independent mock frames (e.g. "Player", "Npc", "Item" for global stacked preview).
local function CreateMockTooltipFrame(parent, nameSuffix)
    local mockName = MOCK_NAME .. (nameSuffix or "")
    local mock = CreateFrame("Frame", mockName, parent, "BackdropTemplate")
    mock._insightPreviewMock = true

    for i = 1, MAX_PREVIEW_LINES do
        local fs = mock:CreateFontString(nil, "OVERLAY")
        -- SetFont before any SetText (ClearLines runs before StyleFonts on first show).
        fs:SetFont(Insight.FONT_PATH, Insight.Scaled(Insight.BODY_SIZE), "OUTLINE")
        fs:SetWordWrap(true)
        fs:SetJustifyH("LEFT")
        fs:Hide()
        _G[mockName .. "TextLeft" .. i] = fs
    end

    mock._lineCount = 0

    function mock:NumLines()   return self._lineCount or 0 end

    function mock:ClearLines()
        for i = 1, MAX_PREVIEW_LINES do
            local fs = _G[mockName .. "TextLeft" .. i]
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
        local fs = _G[mockName .. "TextLeft" .. i]
        if fs then
            fs:SetText(text or "")
            fs:SetTextColor(r or 1, g or 1, b or 1, 1)
            fs:Show()
            fs._insightPlainLineShown = true
        end
    end

    function mock:Layout(explicitWidth)
        local w = explicitWidth or self:GetWidth()
        if w <= 0 then w = 220 end
        self:SetWidth(w)
        local innerW  = math.max(w - PREVIEW_PAD_SIDE * 2, 40)
        local yOffset = -PREVIEW_PAD_TOP
        for i = 1, self._lineCount do
            local fs = _G[mockName .. "TextLeft" .. i]
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

-- Returns the raw (unscaled) DB font size — used only for width ratio calculations.
local function GetPreviewFontSetting(keys, fallback)
    local size = tonumber(fallback) or Insight.BODY_SIZE
    if addon.GetDB then
        for _, key in ipairs(keys) do
            size = math.max(size, tonumber(addon.GetDB(key, size)) or size)
        end
    end
    return size
end

local function GetPreviewPulloutWidth()
    local mode = Insight.dashboardPreviewMode or "global"
    local baseWidth, fontSize
    if mode == "npc" then
        baseWidth = PREVIEW_NPC_WIDTH
        fontSize  = GetPreviewFontSetting({ "insightNpcHeaderSize", "insightNpcBodySize" }, Insight.HEADER_SIZE)
    elseif mode == "item" then
        baseWidth = PREVIEW_ITEM_WIDTH
        fontSize  = GetPreviewFontSetting({ "insightItemHeaderSize", "insightItemBodySize", "insightItemTransmogSize" }, Insight.HEADER_SIZE)
    elseif mode == "player" then
        baseWidth = PREVIEW_BASE_WIDTH
        fontSize  = GetPreviewFontSetting({ "insightPlayerHeaderSize", "insightPlayerBodySize", "insightPlayerBadgesSize", "insightPlayerStatsSize", "insightPlayerMountSize" }, Insight.HEADER_SIZE)
    else
        -- global mode: wider when TRP3 is enabled so the RP name has room; falls back to base width otherwise
        baseWidth = (TRP3_API and addon.GetDB("insightTRP3Enabled", true)) and PREVIEW_GLOBAL_WIDTH or PREVIEW_GLOBAL_BASE_WIDTH
        fontSize  = GetPreviewFontSetting({ "insightHeaderSize", "insightBodySize", "insightBadgesSize", "insightStatsSize", "insightMountSize", "insightTransmogSize" }, Insight.HEADER_SIZE)
    end
    -- Scale compact NPC/item samples more gently so preview-only font choices do not make
    -- short tooltips much wider than their live-game content.
    local scalePerPoint = (mode == "npc" or mode == "item") and 10 or 20
    local maxWidth = (mode == "npc" or mode == "item") and 300 or PREVIEW_MAX_WIDTH
    local extra = math.max(0, fontSize - Insight.HEADER_SIZE) * scalePerPoint
    -- Widen player preview when AFK/DND appears inline on the name line
    if mode == "player" and addon.GetDB("insightStatusBadgeAFK", true) and addon.GetDB("insightStatusBadgeAFKInHeader", false) then
        baseWidth = baseWidth + 55
    end
    return math.floor(math.min(maxWidth, baseWidth + extra) + 0.5)
end

local function RefreshPullout()
    if not pulloutMock then return end
    local mode = Insight.dashboardPreviewMode or "global"

    if mode == "global" then
        -- Hide the single mock; render three separate bordered tooltip frames.
        pulloutMock:ClearLines()
        pulloutMock:Hide()
        if not (globalPlayerMock and globalNpcMock and globalItemMock and globalMockHost) then return end

        local SUB_GAP = 8
        Insight.previewRendering = true

        -- Player sub-mock
        globalPlayerMock:ClearLines()
        Insight.ApplyBackdrop(globalPlayerMock)
        if Insight.RenderTestTooltipContent then Insight.RenderTestTooltipContent(globalPlayerMock) end
        globalPlayerMock._insightTooltipType = "player"
        Insight.StyleFonts(globalPlayerMock)
        local pbr, pbg, pbb = 0.77, 0.12, 0.23
        if TRP3_API and addon.GetDB("insightTRP3Enabled", true) and addon.GetDB("insightTRP3BorderColor", false) then
            pbr, pbg, pbb = 0.72, 0.53, 1.0
        end
        globalPlayerMock:SetBackdropBorderColor(pbr, pbg, pbb, 0.60)
        -- Mirror pulloutMock's TOPLEFT+RIGHT anchor setup so the frame width
        -- is constrained by anchors before Layout runs, giving identical
        -- word-wrap behaviour to the single-player preview.
        globalPlayerMock:ClearAllPoints()
        globalPlayerMock:SetPoint("TOPLEFT", globalMockHost, "TOPLEFT", 10, -10)
        globalPlayerMock:SetPoint("RIGHT", globalMockHost, "RIGHT", -10, 0)
        local playerMockW = GetPreviewPulloutWidth()
        -- Subtract host side-insets so the mock border stays inside the pullout.
        -- Both global widths (290 and 320) exceed PREVIEW_BASE_WIDTH, so this always fires in global mode.
        if playerMockW > PREVIEW_BASE_WIDTH then playerMockW = playerMockW - 20 end
        globalPlayerMock:Layout(playerMockW)
        globalPlayerMock:Show()

        -- NPC sub-mock
        globalNpcMock:ClearLines()
        Insight.ApplyBackdrop(globalNpcMock)
        if Insight.RenderNpcPreviewContent then Insight.RenderNpcPreviewContent(globalNpcMock) end
        globalNpcMock._insightTooltipType = "npc"
        Insight.StyleFonts(globalNpcMock)
        local nbr, nbg, nbb = 0.9, 0.35, 0.35
        if FACTION_BAR_COLORS and FACTION_BAR_COLORS[2] then
            local c = FACTION_BAR_COLORS[2]; nbr, nbg, nbb = c.r, c.g, c.b
        end
        globalNpcMock:SetBackdropBorderColor(nbr, nbg, nbb, 0.60)
        globalNpcMock:ClearAllPoints()
        globalNpcMock:SetPoint("TOPLEFT", globalPlayerMock, "BOTTOMLEFT", 0, -SUB_GAP)
        globalNpcMock:Layout(PREVIEW_NPC_WIDTH)
        globalNpcMock:Show()

        -- Item sub-mock
        globalItemMock:ClearLines()
        Insight.ApplyBackdrop(globalItemMock)
        if Insight.RenderItemPreviewContent then Insight.RenderItemPreviewContent(globalItemMock) end
        globalItemMock._insightTooltipType = "item"
        Insight.StyleFonts(globalItemMock)
        local ibr, ibg, ibb = Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3]
        if addon.GetDB("insightItemQualityBorder", true) then
            local itemID = Insight.DASHBOARD_PREVIEW_ITEM_ID or 168602
            if C_Item and C_Item.GetItemInfo then
                local info = C_Item.GetItemInfo(itemID)
                local q = info and info.quality
                if q and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] then
                    local qc = ITEM_QUALITY_COLORS[q]; ibr, ibg, ibb = qc.r, qc.g, qc.b
                end
            end
        end
        globalItemMock:SetBackdropBorderColor(ibr, ibg, ibb, 0.60)
        globalItemMock:ClearAllPoints()
        globalItemMock:SetPoint("TOPLEFT", globalNpcMock, "BOTTOMLEFT", 0, -SUB_GAP)
        globalItemMock:Layout(PREVIEW_ITEM_WIDTH)
        globalItemMock:Show()

        Insight.previewRendering = nil
        return
    end

    -- Non-global modes: hide sub-mocks, use the single pulloutMock.
    if globalPlayerMock then globalPlayerMock:Hide() end
    if globalNpcMock    then globalNpcMock:Hide()    end
    if globalItemMock   then globalItemMock:Hide()   end

    pulloutMock:ClearLines()
    pulloutMock:Show()
    Insight.ApplyBackdrop(pulloutMock)
    Insight.previewRendering = true
    if mode == "item" and Insight.RenderItemPreviewContent then
        Insight.RenderItemPreviewContent(pulloutMock)
    elseif mode == "npc" and Insight.RenderNpcPreviewContent then
        Insight.RenderNpcPreviewContent(pulloutMock)
    elseif mode == "player" and Insight.RenderTestTooltipContent then
        Insight.RenderTestTooltipContent(pulloutMock)
    end
    Insight.previewRendering = nil
    pulloutMock._insightTooltipType = mode
    Insight.StyleFonts(pulloutMock)
    local br = (mode == "item") and Insight.PANEL_BORDER[1] or 0.77
    local bg = (mode == "item") and Insight.PANEL_BORDER[2] or 0.12
    local bb = (mode == "item") and Insight.PANEL_BORDER[3] or 0.23
    local ba = (mode == "item") and Insight.PANEL_BORDER[4] or 0.60
    if mode == "player" and TRP3_API and addon.GetDB("insightTRP3Enabled", true) and addon.GetDB("insightTRP3BorderColor", false) then
        br, bg, bb = 0.72, 0.53, 1.0
    elseif mode == "npc" and FACTION_BAR_COLORS and FACTION_BAR_COLORS[2] then
        local c = FACTION_BAR_COLORS[2]
        br, bg, bb = c.r, c.g, c.b
    elseif mode == "item" and addon.GetDB("insightItemQualityBorder", true) then
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
    -- Subtract host side-insets so Layout's SetWidth call doesn't overflow the pullout host.
    pulloutMock:Layout(GetPreviewPulloutWidth() - 20)
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
-- TRP3 SUPPRESSOR
-- ============================================================================

--- Hook TRP3_CharacterTooltip:Show() so that when Insight is active, TRP3's
--- own frame is suppressed and Insight's enriched GameTooltip stays visible.
--- Called once when "totalRP3" finishes loading (or at Init if already loaded).
function Insight.InstallTRP3Suppressor()
    local trp3Tooltip = _G["TRP3_CharacterTooltip"]
    if not trp3Tooltip or Insight._trp3HookInstalled then return end
    Insight._trp3HookInstalled = true

    -- Override GameTooltip.Hide so TRP3's shouldHideGameTooltip path cannot
    -- clear Insight's tooltip content.  hooksecurefunc fires *after* the hide
    -- has already happened (too late); this override runs *instead of* it when
    -- the suppression flag is armed.
    local _origGTHide = GameTooltip.Hide
    GameTooltip.Hide = function(self, ...)
        if Insight._suppressTRP3Hide and Insight.IsInsightEnabled() then
            Insight._suppressTRP3Hide = false
            return  -- swallow TRP3's hide; GameTooltip content stays intact
        end
        return _origGTHide(self, ...)
    end

    hooksecurefunc(trp3Tooltip, "Show", function(self)
        if not Insight.IsInsightEnabled() then return end
        -- Suppress TRP3's frame; our GameTooltip already carries TRP3 RP data.
        self:Hide()
        -- Arm the GameTooltip.Hide override for TRP3's synchronous Hide() call
        -- that follows immediately inside show().
        Insight._suppressTRP3Hide = true
        -- Safety: clear next frame in case TRP3's config skips the Hide call.
        C_Timer.After(0, function()
            Insight._suppressTRP3Hide = false
        end)
    end)
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
        if Insight.ApplyNativeTooltipScale then
            Insight.ApplyNativeTooltipScale(tt)
        end
        ApplyLiveBackdropColor(tt)
    end
    if addon.DashboardPreview and addon.DashboardPreview.NotifyRefresh then
        addon.DashboardPreview.NotifyRefresh()
    end
    HideStyledTooltipsIfCombatSuppressionActive()
end

function Insight.Init()
    addon.Log.debug("insight", "Init")
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
            Insight.InstallItemNameGradientHook(tt)
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

    -- If totalRP3 loaded before Insight, ADDON_LOADED already fired; hook now.
    local trp3AlreadyLoaded = false
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        pcall(function()
            if C_AddOns.IsAddOnLoaded("totalRP3") then
                trp3AlreadyLoaded = true
            else
                trp3AlreadyLoaded = false
            end
        end)
    end
    if trp3AlreadyLoaded then
        Insight.InstallTRP3Suppressor()
    end

    if addon.DashboardPreview and addon.DashboardPreview.Register then
        addon.DashboardPreview.Register("insight", {
            width = GetPreviewPulloutWidth,
            title = "TOOLTIP PREVIEW",
            subtitle = "Updates as you change settings",
            tabTooltipTitle = "Tooltip Preview",
            tabTooltipBody = "Live preview — updates as you\nchange Insight settings.",
            MountContent = function(host)
                globalMockHost = host
                if not pulloutMock then
                    pulloutMock = CreateMockTooltipFrame(host)
                else
                    pulloutMock:SetParent(host)
                    pulloutMock:ClearAllPoints()
                end
                pulloutMock:SetPoint("TOPLEFT", host, "TOPLEFT", 10, -10)
                pulloutMock:SetPoint("RIGHT", host, "RIGHT", -10, 0)
                pulloutMock:SetHeight(300)
                if not globalPlayerMock then
                    globalPlayerMock = CreateMockTooltipFrame(host, "Player")
                    globalNpcMock    = CreateMockTooltipFrame(host, "Npc")
                    globalItemMock   = CreateMockTooltipFrame(host, "Item")
                else
                    globalPlayerMock:SetParent(host); globalPlayerMock:ClearAllPoints()
                    globalNpcMock:SetParent(host);    globalNpcMock:ClearAllPoints()
                    globalItemMock:SetParent(host);   globalItemMock:ClearAllPoints()
                end
            end,
            refresh = function()
                RefreshPullout()
            end,
        })
    end
end

function Insight.Disable()
    addon.Log.debug("insight", "Disable")
    HideAnchorFrame()
    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            if tt.SetScale then tt:SetScale(1) end
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
eventFrame:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "ADDON_LOADED" then
        -- guid here is the addon name arg from ADDON_LOADED
        if guid == "totalRP3" then
            Insight.InstallTRP3Suppressor()
        end
        return
    end
    if event == "MODIFIER_STATE_CHANGED" then
        local key = guid  -- first arg is key name e.g. "LSHIFT"
        if key ~= "LSHIFT" and key ~= "RSHIFT" then return end
        if not Insight.IsInsightEnabled() then return end
        if not TooltipPlainShown(GameTooltip) then return end
        if not GameTooltip._insightUnitTooltip then return end
        if SafeUnitExistsKnown("mouseover") ~= true then return end
        -- Reset dedup so the full rebuild runs clean, then let SetUnit
        -- repopulate Blizzard content and re-trigger our hooks.
        GameTooltip._insightUnitTooltipInstance = nil
        GameTooltip._insightStyled = nil
        GameTooltip:SetUnit("mouseover")
        return
    end
    if event == "PLAYER_REGEN_DISABLED" then
        addon.Log.debug("insight", "PLAYER_REGEN_DISABLED — combat started")
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
        return
    end
    if event == "INSPECT_ACHIEVEMENT_READY" then
        if not Insight.IsInsightEnabled() then return end
        if SafeUnitExistsKnown("mouseover") ~= true then return end
        if not UnitIsPlayer("mouseover") then return end
        if Insight.CacheAchievementPoints then Insight.CacheAchievementPoints("mouseover") end
        if TooltipPlainShown(GameTooltip) and GameTooltip._insightUnitTooltip then
            GameTooltip:SetUnit("mouseover")
        end
        if Insight.PruneAchievementCache then Insight.PruneAchievementCache() end
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

    else
        Insight.PrintBlock({
            "Horizon Insight",
            "  /insight, /h insight     This help",
            "  /insight anchor   Toggle cursor / fixed positioning",
            "  /insight move     Show draggable anchor to set fixed position",
            "  /insight resetpos Reset fixed position to default",
            "  /insight test     Show a sample styled tooltip",
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
            "  debuglive - Toggle live debug log panel",
            "  status    - Print config + cache count",
            "  lsm       - Test LibSharedMedia classicon registration",
            "  path      - Show class icon paths (Rondo + custom sample)",
            "  trp3      - Diagnose TRP3 data for current mouseover unit",
        })
        return
    end

    if cmd == "debuglive" then
        if not addon.Log.isDevMode() then
            Insight.Print("Debug requires DEV_MODE = true in core/Logger.lua")
            return
        end
        local v = not addon.Log.isEnabled("insight")
        if Insight.SetDebugLive then Insight.SetDebugLive(v) end
        Insight.Print("Insight debug log: " .. (v and "on" or "off"))
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
        local folder = addon.ADDON_NAME
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

    if cmd == "trp3" then
        local unit = "mouseover"
        Insight.Print("--- TRP3 Debug for unit: " .. unit .. " ---")

        if not TRP3_API then
            Insight.Print("  TRP3_API: NIL (addon not loaded?)")
            return
        end
        Insight.Print("  TRP3_API: OK")

        local getUnitID = TRP3_API.utils and TRP3_API.utils.str and TRP3_API.utils.str.getUnitID
        if not getUnitID then
            Insight.Print("  TRP3_API.utils.str.getUnitID: NIL")
            return
        end
        Insight.Print("  getUnitID func: OK")

        local ok, unitID = pcall(getUnitID, unit)
        if not ok then
            Insight.Print("  getUnitID() error: " .. tostring(unitID))
            return
        end
        Insight.Print("  unitID = " .. tostring(unitID))
        if not unitID or unitID == "" then
            Insight.Print("  -> unitID empty, returning nil")
            return
        end

        local isKnown = TRP3_API.register and TRP3_API.register.isUnitIDKnown
        if not isKnown then
            Insight.Print("  TRP3_API.register.isUnitIDKnown: NIL")
        else
            local ok2, known = pcall(isKnown, unitID)
            if not ok2 then
                Insight.Print("  isUnitIDKnown = pcall error: " .. tostring(known))
            elseif known then
                Insight.Print("  isUnitIDKnown = true")
            else
                Insight.Print("  isUnitIDKnown = false (unit not in TRP3 register)")
            end
            if not (ok2 and known) then
                if UnitIsUnit(unit, "player") then
                    Insight.Print("  -> local player; using TRP3_API.profile path")
                else
                    Insight.Print("  -> unit not known to TRP3, returning nil")
                    return
                end
            end
        end

        -- Resolve profile: local player via TRP3_API.profile, others via register
        local profile
        if UnitIsUnit(unit, "player") then
            local getPlayerProfile = TRP3_API.profile and TRP3_API.profile.getPlayerCurrentProfile
            if not getPlayerProfile then
                Insight.Print("  TRP3_API.profile.getPlayerCurrentProfile: NIL")
                return
            end
            local ok3, p = pcall(getPlayerProfile)
            if not ok3 then
                Insight.Print("  getPlayerCurrentProfile() error: " .. tostring(p))
                return
            end
            profile = p
            Insight.Print("  getPlayerCurrentProfile() = " .. (profile and "table" or "nil"))
        else
            local getProfile = TRP3_API.register and TRP3_API.register.getUnitIDCurrentProfile
            if not getProfile then
                Insight.Print("  TRP3_API.register.getUnitIDCurrentProfile: NIL")
                return
            end
            local ok3, p = pcall(getProfile, unitID)
            if not ok3 then
                Insight.Print("  getUnitIDCurrentProfile() error: " .. tostring(p))
                return
            end
            profile = p
            Insight.Print("  getUnitIDCurrentProfile() = " .. (profile and "table" or "nil"))
        end
        if not profile then return end

        -- Dump raw top-level keys
        local profileKeys = {}
        for k, v in pairs(profile) do
            table.insert(profileKeys, tostring(k) .. "=" .. type(v))
        end
        Insight.Print("  profile keys: " .. table.concat(profileKeys, ", "))

        -- Local player profile nests data under .player; register profiles are flat
        local profileData = UnitIsUnit(unit, "player") and (profile.player or {}) or profile
        local char   = profileData.characteristics or {}
        local status = profileData.character       or {}

        -- Dump all keys in characteristics
        local charKeys = {}
        for k, v in pairs(char) do
            local val = type(v) == "string" and v:sub(1, 20) or tostring(v)
            table.insert(charKeys, tostring(k) .. "=" .. val)
        end
        Insight.Print("  characteristics keys: " .. (next(charKeys) and table.concat(charKeys, ", ") or "(empty)"))

        -- Dump all keys in character/status
        local statKeys = {}
        for k, v in pairs(status) do
            local val = type(v) == "string" and v:sub(1, 20) or tostring(v)
            table.insert(statKeys, tostring(k) .. "=" .. val)
        end
        Insight.Print("  character keys: " .. (next(statKeys) and table.concat(statKeys, ", ") or "(empty)"))

        Insight.Print("  char.RA (race)  = " .. tostring(char.RA))
        Insight.Print("  char.CL (class) = " .. tostring(char.CL))
        Insight.Print("  char.IC (icon)  = " .. tostring(char.IC))
        Insight.Print("  status.RP (IC)  = " .. tostring(status.RP))
        Insight.Print("  status.CU (curr)= " .. tostring(status.CU and status.CU:sub(1,40) or nil))

        local getCompleteName = TRP3_API.register and TRP3_API.register.getCompleteName
        if getCompleteName then
            local ok4, name = pcall(getCompleteName, char, UnitName(unit) or "", false)
            Insight.Print("  getCompleteName = " .. tostring(ok4 and name or ("error: " .. tostring(name))))
        else
            Insight.Print("  TRP3_API.register.getCompleteName: NIL")
        end

        if AddOn_TotalRP3 and AddOn_TotalRP3.Player and AddOn_TotalRP3.Player.CreateFromCharacterID then
            Insight.Print("  AddOn_TotalRP3.Player.CreateFromCharacterID: OK")
            local ok5, player = pcall(AddOn_TotalRP3.Player.CreateFromCharacterID, unitID)
            if ok5 and player then
                Insight.Print("  player object: OK")
                if player.GetCustomColorForDisplay then
                    local ok6, color = pcall(player.GetCustomColorForDisplay, player)
                    Insight.Print("  customColor = " .. (ok6 and color and string.format("r=%.2f g=%.2f b=%.2f", color.r, color.g, color.b) or tostring(ok6 and color or ("error: " .. tostring(color)))))
                end
                if player.GetCustomPronouns then
                    local ok7, p = pcall(player.GetCustomPronouns, player)
                    Insight.Print("  pronouns = " .. tostring(ok7 and p or ("error: " .. tostring(p))))
                end
                if player.GetCustomGuildMembership then
                    local ok8, g = pcall(player.GetCustomGuildMembership, player)
                    if ok8 and g then
                        Insight.Print("  customGuild.name = " .. tostring(g.name) .. " rank = " .. tostring(g.rank))
                    else
                        Insight.Print("  customGuild = " .. tostring(ok8 and g or ("error: " .. tostring(g))))
                    end
                end
                if player.GetRoleplayStatus then
                    local ok9, s = pcall(player.GetRoleplayStatus, player)
                    Insight.Print("  GetRoleplayStatus = " .. tostring(ok9 and s or ("error: " .. tostring(s))))
                else
                    Insight.Print("  GetRoleplayStatus: NIL")
                end
                if player.GetCustomIcon then
                    local ok10, ic = pcall(player.GetCustomIcon, player)
                    Insight.Print("  GetCustomIcon = " .. tostring(ok10 and ic or ("error: " .. tostring(ic))))
                else
                    Insight.Print("  GetCustomIcon: NIL")
                end
            else
                Insight.Print("  CreateFromCharacterID error: " .. tostring(player))
            end
        else
            Insight.Print("  AddOn_TotalRP3.Player.CreateFromCharacterID: NIL")
        end

        Insight.Print("--- end TRP3 debug ---")
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

local function SetInsightDebugLive(v)
    if addon.SetDB then addon.SetDB("insightDebugLive", v) end
    addon.Log.enableTag("insight", v or nil)
    if v then insightPanel.Show(); addon.Log.debug("insight", "Live debug enabled")
    else insightPanel.Hide() end
end
Insight.SetDebugLive  = SetInsightDebugLive
Insight.ShowDebugPanel = insightPanel.Show
Insight.HideDebugPanel = insightPanel.Hide

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("insight", HandleInsightSlash)
end
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("insight", HandleInsightDebugSlash)
end

addon.Insight = Insight
