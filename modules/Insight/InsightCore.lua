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
-- TOOLTIP STYLING (hooks into Shared)
-- ============================================================================

local tooltipsToStyle = {}
local hookedShow      = {}

local function HookTooltipOnShow(tooltip)
    tooltip:HookScript("OnShow", function(self)
        if not IsEnabled() then return end
        Insight.StripNineSlice(self)
        Insight.ApplyBackdrop(self)
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

local animFrame = CreateFrame("Frame")
animFrame:Hide()

animFrame:SetScript("OnUpdate", function(self, elapsed)
    if fadeState == "fadein" and fadeTarget then
        fadeElapsed = fadeElapsed + elapsed
        local progress = math.min(fadeElapsed / Insight.FADE_IN_DUR, 1)
        fadeTarget:SetAlpha(Insight.easeOut(progress))
        if progress >= 1 then
            fadeState = "visible"
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
    animFrame:Show()
end

local function GetTooltipItemLink(tooltip)
    if not tooltip or not tooltip.GetItem then return nil end
    local ok, _, itemLink = pcall(tooltip.GetItem, tooltip)
    if not ok then return nil end
    return itemLink
end

local function HookGameTooltipAnimation()
    GameTooltip:HookScript("OnShow", function(self)
        if not IsEnabled() then return end
        if self.GetUnit and self:GetUnit() then
            local fn = Insight.StripHealthAndPowerText
            if fn then fn() end
        end
        if suppressFadeIn then
            suppressFadeIn = false
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
        self:SetAlpha(1)
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
                        if text:match("%d[%d,]*%s*/%s*%d[%d,]*") then
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

local function ClampTooltipToScreen()
    if GetAnchorMode() ~= "cursor" then return end
    local bottom = GameTooltip:GetBottom()
    if not bottom or bottom >= 2 then return end
    local left    = GameTooltip:GetLeft() or 0
    local uiScale = UIParent:GetEffectiveScale()
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left / uiScale, 2 / uiScale)
end

local function HookPositioning()
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
        ClampTooltipToScreen()
    end
end

-- ============================================================================
-- ITEM TOOLTIP
-- ============================================================================

local function ShowTransmog()
    return addon.GetDB("insightShowTransmog", true)
end

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
        ApplyItemIdentity(tooltip, quality)
        -- Defer so we run after OnShow/ApplyBackdrop
        C_Timer.After(0, function()
            if tooltip and tooltip:IsShown() then
                ApplyItemIdentity(tooltip, quality)
            end
        end)
    else
        Insight.sepR, Insight.sepG, Insight.sepB = nil, nil, nil
    end

    tooltip._insightItemMetadata = true
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

    Insight.Print("Horizon Insight loaded. Type /insight or /mtt for options.")
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
eventFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "INSPECT_READY" then
        if not IsEnabled() then return end
        if not guid then return end
        if not UnitExists("mouseover") then return end
        local mouseoverGuid = UnitGUID("mouseover")
        local okMatch, isMatch = pcall(function() return mouseoverGuid == guid end)
        if okMatch and isMatch then
            Insight.CacheInspect(guid, "mouseover")
            if GameTooltip:IsShown() then
                suppressFadeIn = true
                GameTooltip:SetUnit("mouseover")
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
        })
        return
    end

    if cmd == "status" then
        local cacheCount = 0
        if Insight.inspectCache then
            for _ in pairs(Insight.inspectCache) do cacheCount = cacheCount + 1 end
        end
        Insight.PrintBlock({
            "Horizon Insight Status",
            "   Enabled : Yes",
            "   Anchor  : " .. GetAnchorMode(),
            "   Cache   : " .. cacheCount .. " inspect entries",
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
