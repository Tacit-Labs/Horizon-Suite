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

local function IsEnabled()
    return addon:IsModuleEnabled("insight")
end

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

local function HookTooltipOnShow(tooltip)
    tooltip:HookScript("OnShow", function(self)
        if not IsEnabled() then return end
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
        if not IsEnabled() then return end
        Insight.StyleFonts(self)
    end)
end

-- ============================================================================
-- ANIMATION
-- ============================================================================

local fadeState      = "idle"
local fadeElapsed    = 0
local fadeTarget     = nil
local suppressFadeIn = false
local lastTooltipItemLink = nil

-- Throttle stale unit-tooltip check (player moved away; mouseover not yet cleared).
local STALE_CHECK_INTERVAL = 0.1
local staleCheckElapsed    = 0

local fadeOutStartAlpha = 1
-- Midnight: GameTooltip:GetAlpha() is a secret value — track alpha we apply ourselves.
local fadeLastAppliedAlpha = 1

local animFrame = CreateFrame("Frame")
animFrame:Hide()

animFrame:SetScript("OnUpdate", function(self, elapsed)
    if fadeState == "fadein" and fadeTarget then
        fadeElapsed = fadeElapsed + elapsed
        local progress = math.min(fadeElapsed / Insight.FADE_IN_DUR, 1)
        local alpha = Insight.easeOut(progress)
        fadeTarget:SetAlpha(alpha)
        fadeLastAppliedAlpha = alpha
        if progress >= 1 then
            fadeState = "visible"
            self:Hide()
        end
    elseif fadeState == "fadeout" and fadeTarget then
        fadeElapsed = fadeElapsed + elapsed
        local progress = math.min(fadeElapsed / Insight.FADE_IN_DUR, 1)
        -- Mirror fade-in: same duration and easeOut curve, alpha → 0.
        local alpha = fadeOutStartAlpha * (1 - Insight.easeOut(progress))
        fadeTarget:SetAlpha(alpha)
        fadeLastAppliedAlpha = alpha
        if progress >= 1 then
            fadeState = "idle"
            local tt = fadeTarget
            fadeTarget = nil
            if tt and tt:IsShown() then
                tt:Hide()
            end
            self:Hide()
        end
    else
        self:Hide()
    end
end)

local function StartFadeIn(tooltip)
    fadeTarget  = tooltip
    fadeElapsed = 0
    fadeState   = "fadein"
    tooltip:SetAlpha(0)
    fadeLastAppliedAlpha = 0
    animFrame:Show()
end

local function StartFadeOutStale(tooltip)
    if not tooltip then return end
    fadeTarget = tooltip
    fadeElapsed = 0
    fadeState = "fadeout"
    fadeOutStartAlpha = fadeLastAppliedAlpha
    if not fadeOutStartAlpha or fadeOutStartAlpha <= 0 then
        fadeOutStartAlpha = 1
    end
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
            if not IsEnabled() then return end
            local tt = GameTooltip
            if not tt or not tt:IsShown() then return end
            if not tt._insightUnitTooltip and not (tt.GetUnit and tt:GetUnit()) then return end
            if UnitExists("mouseover") then return end
            if fadeState ~= "fadeout" or fadeTarget ~= tt then
                StartFadeOutStale(tt)
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
        if not IsEnabled() then return end
        -- New show cancels a stale fade-out (e.g. user hovered something else mid-fade).
        if fadeState == "fadeout" and fadeTarget == self then
            fadeState = "idle"
            fadeTarget = nil
            animFrame:Hide()
            self:SetAlpha(1)
            fadeLastAppliedAlpha = 1
        end
        if self.GetUnit and self:GetUnit() then
            local fn = Insight.StripHealthAndPowerText
            if fn then fn() end
        end
        if suppressFadeIn then
            suppressFadeIn = false
            fadeLastAppliedAlpha = 1
            return
        end
        local itemLink = GetTooltipItemLink(self)
        -- Auction tooltips can refresh the same item repeatedly while hovered.
        -- Do not restart the fade until the hovered item actually changes.
        if itemLink and lastTooltipItemLink == itemLink then
            return
        end
        -- Skip re-fade when tooltip is refreshed while already visible (e.g. AH price updates)
        if (fadeState == "fadein" or fadeState == "visible") and fadeTarget == self then
            lastTooltipItemLink = itemLink
            return
        end
        lastTooltipItemLink = itemLink
        StartFadeIn(self)
    end)
    GameTooltip:HookScript("OnHide", function(self)
        fadeState = "idle"
        animFrame:Hide()
        staleCheckElapsed = 0
        self:SetAlpha(1)
        fadeLastAppliedAlpha = 1
        self._insightItemQuality = nil
        self._insightUnitTooltip = nil
    end)
    GameTooltip:HookScript("OnUpdate", function(self, elapsed)
        if not IsEnabled() then return end
        staleCheckElapsed = staleCheckElapsed + elapsed
        if staleCheckElapsed < STALE_CHECK_INTERVAL then return end
        staleCheckElapsed = 0
        if (self._insightUnitTooltip or (self.GetUnit and self:GetUnit())) and not UnitExists("mouseover") then
            if fadeState ~= "fadeout" or fadeTarget ~= self then
                StartFadeOutStale(self)
            end
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
        if not IsEnabled() then return end
        local mode = GetAnchorMode()
        if mode == "fixed" then
            tooltip:ClearAllPoints()
            tooltip:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
        else
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

local function ProcessUnitTooltip(tooltip)
    if not IsEnabled() or not tooltip then return end
    if not UnitExists("mouseover") then return end

    tooltip._insightItemMetadata = nil
    tooltip._insightUnitTooltip  = true
    local unit     = "mouseover"
    local isPlayer = UnitIsPlayer(unit)

    StripHealthAndPowerText(tooltip)

    local processed = false
    if not isPlayer then
        processed = Insight.ProcessNpcTooltip(unit, tooltip)
    else
        processed = Insight.ProcessPlayerTooltip(unit, tooltip)
    end

    if processed then
        Insight.StyleFonts(tooltip)
        suppressFadeIn = true
        tooltip:Show()
        StripHealthAndPowerText(tooltip)
    end
end

-- ============================================================================
-- ITEM TOOLTIP
-- ============================================================================

local function ShowTransmog()
    return addon.GetDB("insightShowTransmog", true)
end

local function OnItemTooltip(tooltip, data)
    if not IsEnabled() then return end

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

    tooltip._insightItemMetadata = true
    tooltip._insightLastItemID   = itemID
    -- Structured item blocks (transmog, etc.)
    Insight.ProcessItemTooltip(tooltip, itemID, quality)
end

local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not IsEnabled() then return end
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
    if anchorFrame:IsShown() then
        Insight.ApplyStoredAnchor(anchorFrame)
        ApplyLiveBackdropColor(anchorFrame)
    end
    for _, tt in ipairs(tooltipsToStyle) do
        ApplyLiveBackdropColor(tt)
    end
end

function Insight.Init()
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
        end
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
eventFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "UPDATE_MOUSEOVER_UNIT" then
        if not IsEnabled() then return end
        if not UnitExists("mouseover") and GameTooltip:IsShown()
            and (GameTooltip._insightUnitTooltip or (GameTooltip.GetUnit and GameTooltip:GetUnit())) then
            GameTooltip:Hide()
        end
        return
    end
    if event == "INSPECT_READY" then
        if not IsEnabled() then return end
        if not guid then return end
        if not UnitExists("mouseover") then return end
        local mouseoverGuid = UnitGUID("mouseover")
        local okMatch, isMatch = pcall(function() return mouseoverGuid == guid end)
        if okMatch and isMatch then
            Insight.CacheInspect(guid, "mouseover")
            if GameTooltip:IsShown()
                and (GameTooltip._insightUnitTooltip or (GameTooltip.GetUnit and GameTooltip:GetUnit())) then
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
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
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
