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
        -- If the tooltip is bound to a unit, ProcessUnitTooltip will call StyleTooltipFull after
        -- adding Insight lines, which covers all lines including Blizzard's. Running StyleFonts here
        -- first would be a full redundant pass over every font string before Insight lines exist.
        -- Use pcall + UnitExists: GetUnit may return a secret token on Midnight that cannot be
        -- compared or type-checked directly outside a pcall.
        if self.GetUnit then
            local ok, unit = pcall(self.GetUnit, self)
            if ok and unit then
                local hasUnit = false
                pcall(function() if UnitExists(unit) then hasUnit = true end end)
                if hasUnit then return end
            end
        end
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
-- Expose for use in other Insight files (NPC tooltip, player tooltip).
Insight.SafeUnitExistsKnown = SafeUnitExistsKnown

-- True when a unit token has usable data, even if not physically present.
-- UnitExists returns false for party/raid members in a different zone, but
-- name/class/level APIs are still populated from client-side sync.
local function UnitHasData(u)
    if SafeUnitExistsKnown(u) == true then return true end
    local hasName = false
    pcall(function()
        local n = UnitName(u)
        if n then hasName = true end
    end)
    return hasName
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
    -- they reuse the same dataInstanceID. _insightStyled is also cleared:
    -- a unit swap without a hide/show cycle (someone walking through the
    -- cursor) rebuilds the lines, so per-line font sizes and the width
    -- re-measure in ProcessUnitTooltip must run again or the tooltip keeps
    -- the previous unit's width. SetFont fast-paths via cachedPath, so the
    -- repeat styling pass is cheap.
    hooksecurefunc(GameTooltip, "SetUnit", function(self)
        self._insightUnitTooltipInstance = nil
        self._insightStyled = nil
    end)

    -- Blizzard refreshes unit tooltip content periodically while hovered and
    -- each refresh re-runs the engine layout with metrics measured against the
    -- pre-Insight fonts, shrinking the frame so styled text overflows the
    -- right border and crowds the bottom one. Rather than chase every refresh
    -- path, re-assert the size every frame a unit tooltip is visible.
    -- FixTooltipSize only grows the frame and bails when the size already
    -- fits, so the steady-state cost is one measurement pass over ~10 lines.
    GameTooltip:HookScript("OnUpdate", function(self)
        if not self._insightUnitTooltip then return end
        if not Insight.IsInsightEnabled() then return end
        Insight.FixTooltipSize(self)
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
    if not tooltip or not tooltip.SetBackdropBorderColor or not unit or not UnitHasData(unit) then return end
    if isPlayer then
        local trp3d
        if addon.GetDB("insightTRP3BorderColor", false) and addon.GetDB("insightTRP3Enabled", true) and Insight.GetTRP3PlayerData then
            trp3d = Insight.GetTRP3PlayerData(unit)
            if trp3d and trp3d.customColorR then
                tooltip:SetBackdropBorderColor(trp3d.customColorR, trp3d.customColorG, trp3d.customColorB, 0.60)
                return
            end
        end
        local classFile = select(2, UnitClass(unit))
        local classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
        if Insight.GetPlayerTooltipBorderColor then
            tooltip:SetBackdropBorderColor(Insight.GetPlayerTooltipBorderColor(unit, classColor, trp3d))
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

local function GetPreviewPlayerBorderColor()
    if TRP3_API and addon.GetDB("insightTRP3Enabled", true) and addon.GetDB("insightTRP3BorderColor", false) then
        return 0.72, 0.53, 1.0, 0.60
    end

    -- Preview mimics the logged-in character (faction / class colour).
    local live = Insight.GetLivePlayerPreviewData and Insight.GetLivePlayerPreviewData()
    local mode = addon.GetDB("insightPlayerTooltipBorder", "class")
    if mode == "faction" then
        local faction = (live and live.faction) or "Alliance"
        local fc = Insight.FACTION_COLORS and Insight.FACTION_COLORS[faction]
        if fc then return fc[1], fc[2], fc[3], 0.60 end
    elseif mode == "class" then
        if live then return live.classR, live.classG, live.classB, 0.60 end
        return 0.77, 0.12, 0.23, 0.60
    end

    return Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4]
end

-- PlayerFrame / party frames: tooltip owns unit "player" or "party1" while mouseover is often empty.
-- GetUnit() may return a secret unit token on Midnight; never compare the string (e.g. to "").
-- Party/raid members in a different zone fail UnitExists but still have data via UnitHasData.
local function ResolveTooltipUnitToken(tooltip)
    if tooltip and tooltip.GetUnit then
        local ok, u = pcall(tooltip.GetUnit, tooltip)
        if ok and UnitHasData(u) then
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
            -- Fonts changed after the tooltip already sized itself with Blizzard's
            -- defaults; re-Show() so GameTooltip re-measures width for the new fonts
            -- (long names/titles at a larger header size otherwise overflow the border).
            tooltip._insightSuppressOnShowStyle = true
            tooltip:Show()
            tooltip._insightSuppressOnShowStyle = nil
            -- Show() can repopulate Blizzard health/power text; strip once more.
            StripHealthAndPowerText(tooltip)
            -- Re-Show() alone does not re-measure widths after a font change;
            -- widen the frame manually for the styled fonts. The GameTooltip
            -- OnUpdate hook re-asserts this every frame against engine stomps.
            Insight.FixTooltipSize(tooltip)
        end
        pcall(ReapplyUnitTooltipBorder, tooltip, unit, isPlayer)
    else
        -- Insight lines were not added (edge case), but we still own styling since
        -- HookTooltipShowMethod skips StyleFonts when a unit is bound. Apply it here.
        if not tooltip._insightStyled then
            Insight.StyleFonts(tooltip)
            tooltip._insightStyled = true
            tooltip._insightSuppressOnShowStyle = true
            tooltip:Show()
            tooltip._insightSuppressOnShowStyle = nil
            Insight.FixTooltipSize(tooltip)
        end
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
    local r, g, b, a = Insight.GetBackdropColor(tooltip._insightTooltipType)
    tooltip:SetBackdropColor(r, g, b, a)
end

-- ============================================================================
-- DASHBOARD PREVIEW (mock tooltip; shell lives in options/dashboard/DashboardPreviewPullout.lua)
-- ============================================================================

local PREVIEW_MODES = { global = true, player = true, npc = true, item = true }

-- Select which tooltip sample the dashboard preview shows when an Insight options page is active.
-- @param mode string "global" | "player" | "npc" | "item"
-- @return nil
function Insight.SetDashboardPreviewMode(mode)
    if type(mode) ~= "string" or not PREVIEW_MODES[mode] then return end
    Insight.dashboardPreviewMode = mode
    if Insight.RefreshEmbeddedPreview then
        Insight.RefreshEmbeddedPreview()
    end
end

local MAX_PREVIEW_LINES  = 50
local PREVIEW_PAD_TOP    = 8
local PREVIEW_PAD_SIDE   = 10
local PREVIEW_PAD_BOTTOM = 10
local PREVIEW_LINE_GAP   = 2

local pulloutMock = nil
local globalPlayerMock, globalNpcMock, globalItemMock = nil, nil, nil

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

    -- Widest line at its natural (unwrapped) width, plus side padding. Sizes
    -- the mock like a real GameTooltip instead of the old per-font-point
    -- width heuristics. Call after content + StyleFonts; un-constrains each
    -- line first so GetStringWidth reports the full text width.
    function mock:MeasureNaturalWidth()
        local maxW = 0
        for i = 1, self._lineCount do
            local fs = _G[mockName .. "TextLeft" .. i]
            if fs and fs._insightPlainLineShown then
                fs:SetWidth(0)
                local w = fs:GetStringWidth() or 0
                if w > maxW then maxW = w end
            end
        end
        return math.ceil(maxW + PREVIEW_PAD_SIDE * 2 + 2)
    end

    return mock
end

-- Border colour for a preview mock of the given sample type.
local function GetPreviewBorderColor(mode)
    if mode == "player" then
        return GetPreviewPlayerBorderColor()
    elseif mode == "npc" then
        local r, g, b = 0.9, 0.35, 0.35
        if FACTION_BAR_COLORS and FACTION_BAR_COLORS[2] then
            local c = FACTION_BAR_COLORS[2]
            r, g, b = c.r, c.g, c.b
        end
        return r, g, b, 0.60
    end
    -- item
    local r, g, b = Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3]
    if addon.GetDB("insightItemQualityBorder", true) then
        local itemID = Insight.DASHBOARD_PREVIEW_ITEM_ID or 168602
        if C_Item and C_Item.GetItemInfo then
            local _, _, q = C_Item.GetItemInfo(itemID)
            if q and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] then
                local qc = ITEM_QUALITY_COLORS[q]
                r, g, b = qc.r, qc.g, qc.b
            end
        end
    end
    return r, g, b, 0.60
end

-- Render one mock as the given sample type, then lay it out at its measured
-- natural width clamped to maxW. Returns the laid-out width.
local function RenderMockAs(mock, mode, maxW)
    mock:ClearLines()
    Insight.ApplyBackdrop(mock)
    Insight.previewRendering = true
    if mode == "player" and Insight.RenderTestTooltipContent then
        Insight.RenderTestTooltipContent(mock)
    elseif mode == "npc" and Insight.RenderNpcPreviewContent then
        Insight.RenderNpcPreviewContent(mock)
    elseif mode == "item" and Insight.RenderItemPreviewContent then
        Insight.RenderItemPreviewContent(mock)
    end
    Insight.previewRendering = nil
    mock._insightTooltipType = mode
    Insight.StyleFonts(mock)
    mock:SetBackdropBorderColor(GetPreviewBorderColor(mode))
    local w = mock:MeasureNaturalWidth()
    if maxW and w > maxW then w = maxW end
    if w < 140 then w = 140 end
    mock:Layout(w)
    mock:Show()
    return w
end

-- ---- Embedded preview strip (hosted at the top of Insight options pages by
-- DashboardDetailView; replaces the old right-side pullout) ----

local embeddedHost = nil

-- Mount (or re-mount) the preview mocks into the host frame. Idempotent.
-- @param host Frame owned by DashboardDetailView
function Insight.MountEmbeddedPreview(host)
    if not host then return end
    embeddedHost = host
    if not pulloutMock then
        pulloutMock      = CreateMockTooltipFrame(host)
        globalPlayerMock = CreateMockTooltipFrame(host, "Player")
        globalNpcMock    = CreateMockTooltipFrame(host, "Npc")
        globalItemMock   = CreateMockTooltipFrame(host, "Item")
    else
        for _, mock in ipairs({ pulloutMock, globalPlayerMock, globalNpcMock, globalItemMock }) do
            mock:SetParent(host)
            mock:ClearAllPoints()
        end
    end
end

-- Lay out the active preview(s) for the current dashboardPreviewMode and size
-- the host to fit. Global mode shows player/npc/item side by side; the per-type
-- pages show their single sample.
-- @return number host height (0 when not mounted)
function Insight.RefreshEmbeddedPreview()
    local host = embeddedHost
    if not (host and pulloutMock) then return 0 end
    local mode = Insight.dashboardPreviewMode or "global"

    local hostW = host:GetWidth() or 0
    if hostW < 200 then hostW = 640 end
    local PAD, GAP = 10, 10

    local stripH = 0
    if mode == "global" then
        pulloutMock:ClearLines()
        pulloutMock:Hide()
        -- Player sample is the tallest/widest; give it more room than the
        -- compact NPC/item samples (42% / 29% / 29% of the row).
        local rowW = hostW - PAD * 2 - GAP * 2
        local entries = {
            { globalPlayerMock, "player", math.max(200, math.floor(rowW * 0.42)) },
            { globalNpcMock,    "npc",    math.max(160, math.floor(rowW * 0.29)) },
            { globalItemMock,   "item",   math.max(160, math.floor(rowW * 0.29)) },
        }
        -- Render first so the real widths are known, then centre the row.
        local totalW = 0
        for _, entry in ipairs(entries) do
            if entry[1] then
                entry[4] = RenderMockAs(entry[1], entry[2], entry[3])
                totalW = totalW + entry[4] + GAP
            end
        end
        if totalW > 0 then totalW = totalW - GAP end
        local x = math.max(PAD, math.floor((hostW - totalW) / 2))
        for _, entry in ipairs(entries) do
            local mock, w = entry[1], entry[4]
            if mock and w then
                mock:ClearAllPoints()
                mock:SetPoint("TOPLEFT", host, "TOPLEFT", x, -PAD)
                x = x + w + GAP
                local h = (mock:GetHeight() or 0) + PAD * 2
                if h > stripH then stripH = h end
            end
        end
    else
        if globalPlayerMock then globalPlayerMock:Hide() end
        if globalNpcMock    then globalNpcMock:Hide()    end
        if globalItemMock   then globalItemMock:Hide()   end
        pulloutMock:ClearAllPoints()
        RenderMockAs(pulloutMock, mode, hostW - PAD * 2)
        pulloutMock:SetPoint("TOP", host, "TOP", 0, -PAD)
        stripH = (pulloutMock:GetHeight() or 0) + PAD * 2
    end

    local h = math.max(60, math.ceil(stripH))
    host:SetHeight(h)
    return h
end

-- Hide all embedded preview mocks (e.g. when another module's preview takes over the host).
function Insight.HideEmbeddedPreview()
    if pulloutMock      then pulloutMock:Hide()      end
    if globalPlayerMock then globalPlayerMock:Hide() end
    if globalNpcMock    then globalNpcMock:Hide()    end
    if globalItemMock   then globalItemMock:Hide()   end
end

-- @deprecated The right-side pullout is gone; previews are embedded at the top
-- of Insight options pages. Kept as no-ops for any external callers.
function Insight.TogglePreviewPullout() end
function Insight.ClosePullout() end

-- @deprecated Prefer addon.DashboardPreview.InitDashboard; kept for callers.
function Insight.EnsurePreviewTab(dashFrame)
    if addon.DashboardPreview and addon.DashboardPreview.InitDashboard then
        addon.DashboardPreview.InitDashboard(dashFrame)
    end
end

-- ============================================================================
-- TRP3 SUPPRESSOR
-- ============================================================================

-- Hook TRP3_CharacterTooltip:Show() so that when Insight is active, TRP3's
-- own frame is suppressed and Insight's enriched GameTooltip stays visible.
-- Called once when "totalRP3" finishes loading (or at Init if already loaded).
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

-- Toggle anchor visibility. Show if hidden, hide if shown. Used by settings button.
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
    if Insight.RefreshEmbeddedPreview then
        Insight.RefreshEmbeddedPreview()
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

    -- Previews are embedded at the top of Insight options pages
    -- (Insight.MountEmbeddedPreview / RefreshEmbeddedPreview, hosted by
    -- DashboardDetailView); the right-side pullout is no longer registered.
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
            self:UnregisterEvent("ADDON_LOADED")
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
        if SafeUnitExistsKnown("mouseover") ~= true
            and TooltipPlainShown(GameTooltip)
            and GameTooltip._insightUnitTooltip then
            C_Timer.After(0, function()
                if SafeUnitExistsKnown("mouseover") == true then return end
                if not TooltipPlainShown(GameTooltip) then return end
                if not GameTooltip._insightUnitTooltip then return end
                -- Don't hide if the tooltip is bound to a party/raid member in a
                -- different zone — no world mouseover but unit data is still valid.
                if GameTooltip.GetUnit then
                    local ok, u = pcall(GameTooltip.GetUnit, GameTooltip)
                    if ok and UnitHasData(u) then return end
                end
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
                    if SafeUnitExistsKnown("mouseover") == true then return end
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
-- STUCK-TOOLTIP FALLBACK POLL
-- Catches cases where UPDATE_MOUSEOVER_UNIT never fires (e.g. fixed anchor,
-- UI reload edge cases). Throttled to POLL_INTERVAL seconds; exits cheaply
-- each frame when the tooltip is not an insight unit tooltip.
-- ============================================================================

local POLL_INTERVAL = 0.25
local pollAccum     = 0
local pollFrame     = CreateFrame("Frame")
pollFrame:SetScript("OnUpdate", function(_, elapsed)
    pollAccum = pollAccum + elapsed
    if pollAccum < POLL_INTERVAL then return end
    pollAccum = 0
    if not Insight.IsInsightEnabled() then return end
    if not TooltipPlainShown(GameTooltip) then return end
    if not GameTooltip._insightUnitTooltip then return end
    if SafeUnitExistsKnown("mouseover") == true then return end
    -- Don't hide if the tooltip is bound to a party/raid member in a different
    -- zone — no world mouseover but unit data (name/class/level) is still valid.
    if GameTooltip.GetUnit then
        local ok, u = pcall(GameTooltip.GetUnit, GameTooltip)
        if ok and UnitHasData(u) then return end
    end
    GameTooltip:Hide()
end)

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================

local function HandleInsightSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "toggle" then
        if InCombatLockdown() then
            Insight.Print("Cannot toggle Insight during combat.")
            return
        end
        addon:SetModuleEnabled("insight", not addon:IsModuleEnabled("insight"))
        Insight.Print("Insight " .. (addon:IsModuleEnabled("insight") and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
        return
    end

    if not addon:IsModuleEnabled("insight") then
        Insight.Print("Horizon Insight is disabled. Use /h insight toggle to enable it.")
        return
    end

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

    elseif cmd == "reset" or cmd == "resetpos" then
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
                GameTooltip:SetBackdropBorderColor(GetPreviewPlayerBorderColor())
            end
        end)
        Insight.Print("Horizon Insight: Test tooltip shown at cursor.")

    else
        Insight.PrintBlock({
            "Horizon Insight",
            "  /h insight          This help",
            "  /h insight toggle   Enable / disable Insight module",
            "  /h insight anchor   Toggle cursor / fixed positioning",
            "  /h insight move     Show draggable anchor to set fixed position",
            "  /h insight reset    Reset fixed position to default",
            "  /h insight test     Show a sample styled tooltip",
        })
    end
end

local function HandleInsightDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        Insight.PrintBlock({
            "Insight debug commands (/h debug insight [cmd]):",
            "  debuglive - Toggle live debug log panel (DEV_MODE required)",
            "  status    - Print config + cache count",
            "  lsm       - Test LibSharedMedia classicon registration",
            "  path      - Show class icon paths (Rondo + custom sample)",
            "  trp3      - Diagnose TRP3 data for current mouseover unit",
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
if addon.RegisterDebugLive then
    addon.RegisterDebugLive("insight", function(v) if Insight.SetDebugLive then Insight.SetDebugLive(v) end end)
end

addon.Insight = Insight
