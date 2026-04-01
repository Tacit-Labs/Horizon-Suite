--[[
    Horizon Suite - Horizon Insight (Core)
    Orchestration: init/disable, tooltip hooks, anchor, slash commands.
    Player/NPC/Item logic lives in InsightPlayerTooltip, InsightNpcTooltip, InsightItemTooltip.
]]

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

local function GetCursorOffsetX()
    return tonumber(addon.GetDB("insightCursorOffsetX", 0)) or 0
end

local function GetCursorOffsetY()
    return tonumber(addon.GetDB("insightCursorOffsetY", 0)) or 0
end

-- Cursor offsets on SetOwner(..., "ANCHOR_CURSOR", x, y) are ignored in current retail builds;
-- use ANCHOR_NONE + screen cursor position. Do not call SetOwner every OnUpdate — it clears tooltip lines (blank box on unit hover).
local function MoveGameTooltipToCursor(tooltip)
    if not tooltip or not UIParent then return end
    tooltip:ClearAllPoints()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    if scale and scale > 0 then
        x = x / scale
        y = y / scale
    end
    local ox, oy = GetCursorOffsetX(), GetCursorOffsetY()
    pcall(function()
        tooltip:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x + ox, y + oy)
    end)
end

local function ApplyGameTooltipCursorAnchor(tooltip, parent)
    if not tooltip or not UIParent then return end
    parent = parent or UIParent
    pcall(function()
        tooltip:SetOwner(parent, "ANCHOR_NONE")
    end)
    MoveGameTooltipToCursor(tooltip)
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
        if addon.GetDB("insightHideTooltipsInCombat", false) and InCombatLockdown() then
            self:Hide()
            return
        end
        Insight.StripNineSlice(self)
        Insight.ApplyBackdrop(self)
        if self._insightItemQuality then
            ApplyItemIdentity(self, self._insightItemQuality)
        end
    end)
end

local function HookTooltipShowMethod(tooltip)
    if hookedShow[tooltip] then return end
    hookedShow[tooltip] = true
    hooksecurefunc(tooltip, "Show", function(self)
        if not Insight.IsInsightEnabled() then return end
        if not self._insightUnitTooltip and not self._insightItemMetadata then
            self._insightTooltipType = "other"
        end
        Insight.StyleFonts(self)
    end)
end

-- ============================================================================
-- ANIMATION (per-tooltip; supports GameTooltip + ItemRef/shopping/embedded concurrently)
-- ============================================================================

local FADE_STATE_FADEIN  = "fadein"
local FADE_STATE_FADEOUT = "fadeout"

local suppressFadeIn = false
-- Weak keys: tooltip frames; avoids retaining dead frames.
local lastTooltipItemLinkByTT = setmetatable({}, { __mode = "k" })
-- [tooltip] = { state, elapsed, fadeInStartAlpha, fadeOutStartAlpha, lastAppliedAlpha }
local tooltipFadeData         = setmetatable({}, { __mode = "k" })

-- Stale unit-tooltip dismiss: debounce from insightTooltipDismissGrace; fade length from insightTooltipFadeOutSec.
-- Race with Blizzard: if the client calls GameTooltip:Hide() before our dismiss runs, the tooltip "pops" with no custom fade.
local staleCheckElapsed     = 0
local staleMouseoverMissTicks = 0
local umuDismissGen         = 0

local function GetTooltipDismissGrace()
    local raw = addon.GetDB("insightTooltipDismissGrace", "default")
    if raw == "instant" then return "instant" end
    if raw == "relaxed" then return "relaxed" end
    return "default"
end

local function GetStaleCheckInterval()
    if GetTooltipDismissGrace() == "instant" then
        return 0.05
    end
    return 0.1
end

local function GetStaleMissThreshold()
    local g = GetTooltipDismissGrace()
    if g == "instant" then return 1 end
    if g == "relaxed" then return 5 end
    return 2
end

local function GetUmuDismissDelaySeconds()
    if GetTooltipDismissGrace() == "relaxed" then
        return 0.15
    end
    return 0
end

local function SyncFadeOutDurationFromDB()
    local s = tonumber(addon.GetDB("insightTooltipFadeOutSec", 0.4)) or 0.4
    s = math.max(0, math.min(0.8, s))
    s = math.floor(s / 0.05 + 0.5) * 0.05
    Insight.FADE_OUT_DUR = s
end
-- Expand GameTooltip hit box slightly so cursor gaps between anchor and tooltip do not count as "stale".
local STALE_MOUSEOVER_PADDING        = 4

local animFrame = CreateFrame("Frame")
animFrame:Hide()

local function HasActiveTooltipFadeDriver()
    for _, d in pairs(tooltipFadeData) do
        if d.state == FADE_STATE_FADEIN or d.state == FADE_STATE_FADEOUT then
            return true
        end
    end
    return false
end

local function GetFadeData(tooltip)
    local d = tooltipFadeData[tooltip]
    if not d then
        d = {
            state = "idle",
            elapsed = 0,
            fadeInStartAlpha = 0,
            fadeOutStartAlpha = 1,
            lastAppliedAlpha = 1,
        }
        tooltipFadeData[tooltip] = d
    end
    return d
end

local function IsTooltipInFadeOut(tooltip)
    local d = tooltipFadeData[tooltip]
    return d and d.state == FADE_STATE_FADEOUT
end

-- True when the cursor is over the tooltip (with padding); do not treat as stale "no mouseover".
-- Cursor anchor mode positions GameTooltip at the mouse, so IsMouseOver is almost always true and would block stale fade forever — defer only in fixed mode.
-- pcall: IsMouseOver can be restricted around secret anchoring per API docs.
local function ShouldDeferStaleFadeOut(tt)
    if GetAnchorMode() == "cursor" then
        return false
    end
    if not tt or not tt.IsMouseOver then return false end
    local p = STALE_MOUSEOVER_PADDING
    local ok, over = pcall(tt.IsMouseOver, tt, p, p, p, p)
    return ok and over
end

animFrame:SetScript("OnUpdate", function(self, elapsed)
    local durIn = Insight.FADE_IN_DUR
    local durOut = Insight.FADE_OUT_DUR or durIn
    local toRemove = {}
    for tt, d in pairs(tooltipFadeData) do
        if d.state == FADE_STATE_FADEIN then
            d.elapsed = d.elapsed + elapsed
            local progress = math.min(d.elapsed / durIn, 1)
            local alpha = d.fadeInStartAlpha + (1 - d.fadeInStartAlpha) * Insight.easeOut(progress)
            if tt.SetAlpha then tt:SetAlpha(alpha) end
            d.lastAppliedAlpha = alpha
            if progress >= 1 then
                if tt.SetAlpha then tt:SetAlpha(1) end
                d.lastAppliedAlpha = 1
                toRemove[#toRemove + 1] = tt
            end
        elseif d.state == FADE_STATE_FADEOUT then
            d.elapsed = d.elapsed + elapsed
            if durOut <= 0 then
                if tt and tt:IsShown() then
                    tt:Hide()
                end
                toRemove[#toRemove + 1] = tt
            else
                local progress = math.min(d.elapsed / durOut, 1)
                local alpha = d.fadeOutStartAlpha * (1 - Insight.easeOut(progress))
                if tt.SetAlpha then tt:SetAlpha(alpha) end
                d.lastAppliedAlpha = alpha
                if progress >= 1 then
                    if tt and tt:IsShown() then
                        tt:Hide()
                    end
                    toRemove[#toRemove + 1] = tt
                end
            end
        end
    end
    for i = 1, #toRemove do
        tooltipFadeData[toRemove[i]] = nil
    end
    if not HasActiveTooltipFadeDriver() then
        self:Hide()
    end
end)

local function StartFadeIn(tooltip)
    if not tooltip then return end
    local d = GetFadeData(tooltip)
    d.state = FADE_STATE_FADEIN
    d.elapsed = 0
    d.fadeInStartAlpha = 0
    d.lastAppliedAlpha = 0
    tooltip:SetAlpha(0)
    animFrame:Show()
end

local function StartFadeOutStale(tooltip)
    if not tooltip then return end
    local d = GetFadeData(tooltip)
    d.state = FADE_STATE_FADEOUT
    d.elapsed = 0
    local startA = d.lastAppliedAlpha
    if not startA or startA <= 0 then
        startA = 1
    end
    d.fadeOutStartAlpha = startA
    animFrame:Show()
end

-- GameTooltip unit tip only: instant Hide when fade-out duration is 0, else fade (Insight.FADE_OUT_DUR from DB).
local function DismissStaleUnitGameTooltip(tooltip)
    if not tooltip then return end
    if ShouldDeferStaleFadeOut(tooltip) then return end
    if IsTooltipInFadeOut(tooltip) then return end
    SyncFadeOutDurationFromDB()
    local dur = Insight.FADE_OUT_DUR or 0
    if dur <= 0 then
        tooltipFadeData[tooltip] = nil
        if tooltip == GameTooltip then
            staleMouseoverMissTicks = 0
        end
        if tooltip:IsShown() then
            tooltip:Hide()
        end
    else
        StartFadeOutStale(tooltip)
    end
end

-- TooltipDataProcessor can refresh unit tooltips without OnShow; cancel fade-out so anim does not Hide() mid-hover.
local function CancelTooltipFadeOutIfNeeded(tooltip)
    if not tooltip then return end
    local d = tooltipFadeData[tooltip]
    if not d or d.state ~= FADE_STATE_FADEOUT then return end
    if tooltip == GameTooltip then
        staleMouseoverMissTicks = 0
    end
    local startA = d.lastAppliedAlpha
    if not startA or startA < 0 then
        startA = 0
    elseif startA > 1 then
        startA = 1
    end
    d.fadeInStartAlpha = startA
    d.elapsed = 0
    d.state = FADE_STATE_FADEIN
    tooltip:SetAlpha(startA)
    d.lastAppliedAlpha = startA
    animFrame:Show()
end

-- Staggered checks after inspect refresh; catches delayed mouseover clearing when user moves off quickly.
local postInspectSafetyGen = 0
local POST_INSPECT_SAFETY_DELAYS = { 0, 0.1, 0.25, 0.5 }

local function SchedulePostInspectTooltipSafetyNet()
    if not (C_Timer and C_Timer.After) then return end
    postInspectSafetyGen = postInspectSafetyGen + 1
    local waveGen = postInspectSafetyGen
    for _, delay in ipairs(POST_INSPECT_SAFETY_DELAYS) do
        C_Timer.After(delay, function()
            if waveGen ~= postInspectSafetyGen then return end
            if not Insight.IsInsightEnabled() then return end
            local tt = GameTooltip
            if not tt or not tt:IsShown() then return end
            if not tt._insightUnitTooltip and not (tt.GetUnit and tt:GetUnit()) then return end
            if UnitExists("mouseover") then return end
            if ShouldDeferStaleFadeOut(tt) then return end
            if not IsTooltipInFadeOut(tt) then
                DismissStaleUnitGameTooltip(tt)
            end
        end)
    end
end

local function GetTooltipItemLink(tooltip)
    if not tooltip then return nil end
    if tooltip.GetItem then
        local ok, _, itemLink = pcall(tooltip.GetItem, tooltip)
        if ok and itemLink then return itemLink end
    end
    -- Fallback: itemID set by OnItemTooltip for tooltips where GetItem() returns nil
    return tooltip._insightLastItemID
end

local function HookGameTooltipAnimation()
    GameTooltip:HookScript("OnShow", function(self)
        if not Insight.IsInsightEnabled() then return end
        -- New show cancels a stale fade-out (e.g. user hovered something else mid-fade).
        CancelTooltipFadeOutIfNeeded(self)
        -- pcall: GetUnit can throw or return secret values on Midnight; must not abort OnShow before StartFadeIn.
        local hasUnit = false
        if self.GetUnit then
            local ok, u = pcall(self.GetUnit, self)
            hasUnit = ok and u
        end
        if hasUnit then
            local fn = Insight.StripHealthAndPowerText
            if fn then fn() end
        end
        if suppressFadeIn then
            suppressFadeIn = false
            tooltipFadeData[self] = nil
            self:SetAlpha(1)
            if not HasActiveTooltipFadeDriver() then
                animFrame:Hide()
            end
            return
        end
        local itemLink = GetTooltipItemLink(self)
        local last = lastTooltipItemLinkByTT[self]
        -- Auction tooltips can refresh the same item repeatedly while hovered.
        -- Do not restart the fade until the hovered item actually changes.
        if itemLink and last == itemLink then
            return
        end
        -- Skip re-fade when tooltip is refreshed while already visible (e.g. AH price updates)
        local d = tooltipFadeData[self]
        if d and d.state == FADE_STATE_FADEIN then
            lastTooltipItemLinkByTT[self] = itemLink
            return
        end
        lastTooltipItemLinkByTT[self] = itemLink
        StartFadeIn(self)
    end)
    GameTooltip:HookScript("OnHide", function(self)
        tooltipFadeData[self] = nil
        lastTooltipItemLinkByTT[self] = nil
        if not HasActiveTooltipFadeDriver() then
            animFrame:Hide()
        end
        staleCheckElapsed = 0
        staleMouseoverMissTicks = 0
        self:SetAlpha(1)
        self._insightItemQuality = nil
        self._insightUnitTooltip = nil
        self._insightTooltipType = nil
        self._insightLastAnchorParent = nil
    end)
    GameTooltip:HookScript("OnUpdate", function(self, elapsed)
        if not Insight.IsInsightEnabled() then return end
        if GetAnchorMode() == "cursor" and self:IsShown() then
            MoveGameTooltipToCursor(self)
        end
        staleCheckElapsed = staleCheckElapsed + elapsed
        local checkInt = GetStaleCheckInterval()
        if staleCheckElapsed < checkInt then return end
        staleCheckElapsed = 0
        local okU, u = self.GetUnit and pcall(self.GetUnit, self)
        local unitTip = self._insightUnitTooltip or (okU and u)
        if unitTip and UnitExists("mouseover") then
            staleMouseoverMissTicks = 0
        elseif unitTip and not UnitExists("mouseover") then
            if ShouldDeferStaleFadeOut(self) then
                staleMouseoverMissTicks = 0
            else
                staleMouseoverMissTicks = staleMouseoverMissTicks + 1
                if staleMouseoverMissTicks >= GetStaleMissThreshold() then
                    if not IsTooltipInFadeOut(self) then
                        DismissStaleUnitGameTooltip(self)
                    end
                end
            end
        else
            staleMouseoverMissTicks = 0
        end
    end)
end

-- Fade-in for ItemRef, shopping, and embedded tooltips (GameTooltip uses HookGameTooltipAnimation).
local function HookStyledTooltipFade(tt)
    if not tt then return end
    tt:HookScript("OnShow", function(self)
        if not Insight.IsInsightEnabled() then return end
        CancelTooltipFadeOutIfNeeded(self)
        -- Comparison tooltips are repositioned by Blizzard on every Show(); fade-in
        -- resets alpha to 0 each time, causing visible flicker on minimap/world quest
        -- tooltips. Let them appear at full alpha; borders and styling are unaffected.
        if self == ShoppingTooltip1 or self == ShoppingTooltip2 then
            self:SetAlpha(1)
            return
        end
        local itemLink = GetTooltipItemLink(self)
        local last = lastTooltipItemLinkByTT[self]
        if itemLink and last == itemLink then
            return
        end
        local d = tooltipFadeData[self]
        if d and d.state == FADE_STATE_FADEIN then
            lastTooltipItemLinkByTT[self] = itemLink
            return
        end
        lastTooltipItemLinkByTT[self] = itemLink
        StartFadeIn(self)
    end)
    tt:HookScript("OnHide", function(self)
        lastTooltipItemLinkByTT[self] = nil
        tooltipFadeData[self] = nil
        self:SetAlpha(1)
        if not HasActiveTooltipFadeDriver() then
            animFrame:Hide()
        end
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

local function HookPositioning()
    -- Delegate screen-edge clamping to the engine; avoids branching on secret positional values.
    GameTooltip:SetClampedToScreen(true)
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if not Insight.IsInsightEnabled() then return end
        local mode = GetAnchorMode()
        if mode == "fixed" then
            tooltip:ClearAllPoints()
            tooltip:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
        elseif tooltip == GameTooltip then
            tooltip._insightLastAnchorParent = parent
            ApplyGameTooltipCursorAnchor(tooltip, parent)
        else
            -- Comparison / embedded tooltips: keep Blizzard cursor anchor (offsets not applied).
            tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        end
    end)
end

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
    if not tooltip or not tooltip.SetBackdropBorderColor or not unit or not UnitExists(unit) then return end
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
local function ResolveTooltipUnitToken(tooltip)
    if tooltip and tooltip.GetUnit then
        local ok, u = pcall(tooltip.GetUnit, tooltip)
        if ok and u and u ~= "" and UnitExists(u) then
            return u
        end
    end
    if UnitExists("mouseover") then
        return "mouseover"
    end
    return nil
end

local function ProcessUnitTooltip(tooltip)
    if not Insight.IsInsightEnabled() or not tooltip then return end
    local unit = ResolveTooltipUnitToken(tooltip)
    if not unit then return end

    CancelTooltipFadeOutIfNeeded(tooltip)

    -- If Blizzard already showed the tooltip, a second Show() re-runs OnShow (backdrop, fade) and flashes.
    local alreadyVisible = tooltip:IsShown()

    tooltip._insightItemMetadata = nil
    tooltip._insightUnitTooltip  = true
    if tooltip._insightLineTags then wipe(tooltip._insightLineTags) end
    local isPlayer = UnitIsPlayer(unit)
    tooltip._insightTooltipType = isPlayer and "player" or "npc"

    StripHealthAndPowerText(tooltip)

    local processed = false
    if not isPlayer then
        processed = Insight.ProcessNpcTooltip(unit, tooltip)
    else
        processed = Insight.ProcessPlayerTooltip(unit, tooltip)
    end

    if processed then
        Insight.StyleFonts(tooltip)
        if not alreadyVisible then
            -- First show this pass: Show() can repopulate Blizzard health/power text after our edits.
            tooltip:Show()
        end
        -- Second strip after Show when we showed; same strip when already visible (no redundant Show).
        StripHealthAndPowerText(tooltip)
        -- TooltipDataProcessor can refresh without OnShow; re-apply cinematic chrome (OnShow-only hooks would skip).
        Insight.StyleTooltipFull(tooltip)
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
    if tooltip and tooltip:IsShown() then
        CancelTooltipFadeOutIfNeeded(tooltip)
    end

    local itemID = data and data.id
    if not itemID then return end

    -- Item identity: quality-colored border and separator tint
    local quality = (data and data.quality) or (GetItemInfo and select(3, GetItemInfo(itemID)))
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

    -- Comparison tooltips get quality borders (above) but no line enrichment:
    -- adding lines triggers Blizzard to reposition them, re-firing Show() and
    -- feeding the StartFadeIn flicker loop on World Quest / minimap tooltips.
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
    if not tooltip or not tooltip:IsShown() or not tooltip.SetBackdropColor then return end
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
            if fs then fs:SetText(""); fs:Hide() end
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
        end
    end

    function mock:Layout()
        local w = self:GetWidth()
        if w <= 0 then w = 220 end
        local innerW  = math.max(w - PREVIEW_PAD_SIDE * 2, 40)
        local yOffset = -PREVIEW_PAD_TOP
        for i = 1, self._lineCount do
            local fs = _G[MOCK_NAME .. "TextLeft" .. i]
            if fs and fs:IsShown() then
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
            local _, _, q = C_Item.GetItemInfo(id)
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
    if anchorFrame:IsShown() then
        HideAnchorFrame()
        Insight.Print("Horizon Insight: Anchor hidden. Position saved.")
    else
        ShowAnchorFrame()
    end
end

function Insight.ApplyInsightOptions()
    SyncFadeOutDurationFromDB()
    if anchorFrame:IsShown() then
        Insight.ApplyStoredAnchor(anchorFrame)
        ApplyLiveBackdropColor(anchorFrame)
    end
    for _, tt in ipairs(tooltipsToStyle) do
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
                HookStyledTooltipFade(tt)
            end
        end
    end

    -- Comparison tooltips inherit GameTooltip's alpha through the frame hierarchy.
    -- When Insight fades GameTooltip in from alpha=0, the shopping panels visually
    -- dim too. SetIgnoreParentAlpha(true) breaks that inheritance so they stay at 1.
    if ShoppingTooltip1 and ShoppingTooltip1.SetIgnoreParentAlpha then
        ShoppingTooltip1:SetIgnoreParentAlpha(true)
    end
    if ShoppingTooltip2 and ShoppingTooltip2.SetIgnoreParentAlpha then
        ShoppingTooltip2:SetIgnoreParentAlpha(true)
    end

    HookGameTooltipAnimation()
    HideHealthBar()
    HookPositioning()

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
    SyncFadeOutDurationFromDB()
end

function Insight.Disable()
    HideAnchorFrame()
    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            Insight.RestoreNineSlice(tt)
            if tt.SetBackdrop then tt:SetBackdrop(nil) end
        end
    end
    if ShoppingTooltip1 and ShoppingTooltip1.SetIgnoreParentAlpha then
        ShoppingTooltip1:SetIgnoreParentAlpha(false)
    end
    if ShoppingTooltip2 and ShoppingTooltip2.SetIgnoreParentAlpha then
        ShoppingTooltip2:SetIgnoreParentAlpha(false)
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
        local okGt, gtUnit = GameTooltip.GetUnit and pcall(GameTooltip.GetUnit, GameTooltip)
        if not UnitExists("mouseover") and GameTooltip:IsShown()
            and (GameTooltip._insightUnitTooltip or (okGt and gtUnit)) then
            if ShouldDeferStaleFadeOut(GameTooltip) then return end
            umuDismissGen = umuDismissGen + 1
            local gen = umuDismissGen
            local delay = GetUmuDismissDelaySeconds()
            local function runUmuDismiss()
                if gen ~= umuDismissGen then return end
                if UnitExists("mouseover") then return end
                if not GameTooltip:IsShown() then return end
                local okGt2, gtUnit2 = GameTooltip.GetUnit and pcall(GameTooltip.GetUnit, GameTooltip)
                if not (GameTooltip._insightUnitTooltip or (okGt2 and gtUnit2)) then return end
                DismissStaleUnitGameTooltip(GameTooltip)
            end
            -- Defer with C_Timer so we run after Blizzard's UMU handlers; may start fade before engine Hide().
            if C_Timer and C_Timer.After then
                if delay > 0 then
                    C_Timer.After(delay, runUmuDismiss)
                else
                    C_Timer.After(0, runUmuDismiss)
                end
            else
                runUmuDismiss()
            end
        end
        return
    end
    if event == "INSPECT_READY" then
        if not Insight.IsInsightEnabled() then return end
        if not guid then return end
        if not UnitExists("mouseover") then return end
        local mouseoverGuid = UnitGUID("mouseover")
        local okMatch, isMatch = pcall(function() return mouseoverGuid == guid end)
        if okMatch and isMatch then
            Insight.CacheInspect(guid, "mouseover")
            if GameTooltip:IsShown()
                and (GameTooltip._insightUnitTooltip or (GameTooltip.GetUnit and GameTooltip:GetUnit())) then
                -- Rebuild while visible; avoid restarting fade from a second OnShow.
                suppressFadeIn = true
                GameTooltip:SetUnit("mouseover")
                SchedulePostInspectTooltipSafetyNet()
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
        if anchorFrame:IsShown() then
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
        GameTooltip._insightLastAnchorParent = UIParent
        ApplyGameTooltipCursorAnchor(GameTooltip, UIParent)
        GameTooltip:ClearLines()
        Insight.RenderTestTooltipContent(GameTooltip)
        GameTooltip:Show()
        -- Defer so we run after OnShow/ApplyBackdrop; otherwise backdrop overwrites border color.
        C_Timer.After(0, function()
            if GameTooltip:IsShown() then
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
            "  status  - Print config + cache count",
            "  lsm     - Test LibSharedMedia classicon registration",
            "  path    - Show RondoMedia path and detection",
        })
        return
    end

    if cmd == "path" then
        local source = addon.GetDB and addon.GetDB("insightClassIconSource", "default") or "default"
        local isRondo = false
        if C_AddOns and C_AddOns.IsAddOnLoaded then
            local ok, r = pcall(C_AddOns.IsAddOnLoaded, "RondoMedia")
            isRondo = ok and r
        elseif type(IsAddOnLoaded) == "function" then
            local ok, r = pcall(IsAddOnLoaded, "RondoMedia")
            isRondo = ok and r
        end
        local rondo = addon.CLASS_ICON_RONDO_NAMES
        local displayName = rondo and rondo["WARRIOR"] or "Warrior"
        local folder = addon.ADDON_NAME or "HorizonSuite"
        local path = isRondo
            and ("Interface\\AddOns\\RondoMedia\\media\\Class_icons\\class_colored border\\32x32\\%s_32.tga"):format(displayName)
            or ("Interface\\AddOns\\%s\\media\\RondoClassIcons\\class_colored border\\32x32\\%s_32.tga"):format(folder, displayName)
        Insight.PrintBlock({
            "RondoMedia path debug",
            "   Class icon source : " .. source,
            "   RondoMedia loaded : " .. tostring(isRondo),
            "   Sample path      : " .. path,
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
        local classIconSource = addon.GetDB and addon.GetDB("insightClassIconSource", "default") or "default"
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

