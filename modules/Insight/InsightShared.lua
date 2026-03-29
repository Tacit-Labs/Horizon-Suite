--[[
    Horizon Suite - Horizon Insight (Shared)
    Shared helpers for tooltip line iteration, styling, separators, print, and render utilities.
    Used by InsightPlayerTooltip, InsightNpcTooltip, InsightItemTooltip, and InsightCore.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- ============================================================================
-- CONSTANTS (shared across all Insight tooltip types)
-- ============================================================================

Insight.FONT_PATH       = "Fonts\\FRIZQT__.TTF"

local INSIGHT_FONT_USE_GLOBAL = "__global__"

local function GetInsightFontPath()
    local raw = addon.GetDB and addon.GetDB("insightFontPath", INSIGHT_FONT_USE_GLOBAL) or INSIGHT_FONT_USE_GLOBAL
    if raw == INSIGHT_FONT_USE_GLOBAL or not raw or raw == "" then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
    end
    return (addon.ResolveFontPath and addon.ResolveFontPath(raw)) or raw
end

local function GetInsightHeaderSize()
    return math.max(8, tonumber(addon.GetDB and addon.GetDB("insightHeaderSize", Insight.HEADER_SIZE)) or Insight.HEADER_SIZE)
end
local function GetInsightBodySize()
    return math.max(8, tonumber(addon.GetDB and addon.GetDB("insightBodySize", Insight.BODY_SIZE)) or Insight.BODY_SIZE)
end
local function GetInsightBadgesSize()
    return math.max(6, tonumber(addon.GetDB and addon.GetDB("insightBadgesSize", 12)) or 12)
end
local function GetInsightStatsSize()
    return math.max(6, tonumber(addon.GetDB and addon.GetDB("insightStatsSize", 11)) or 11)
end
local function GetInsightMountSize()
    return math.max(6, tonumber(addon.GetDB and addon.GetDB("insightMountSize", 11)) or 11)
end
local function GetInsightTransmogSize()
    return math.max(6, tonumber(addon.GetDB and addon.GetDB("insightTransmogSize", 11)) or 11)
end

function Insight.TagLines(tooltip, tag, fn)
    local before = tooltip:NumLines()
    fn()
    local after = tooltip:NumLines()
    if after > before then
        tooltip._insightLineTags = tooltip._insightLineTags or {}
        for i = before + 1, after do
            tooltip._insightLineTags[i] = tag
        end
    end
end

Insight.HEADER_SIZE     = 14
Insight.BODY_SIZE       = 12
Insight.SMALL_SIZE      = 10

Insight.PANEL_BG        = { 0, 0, 0, 0.75 }
Insight.PANEL_BORDER    = { 0.25, 0.25, 0.25, 0.30 }

Insight.FADE_IN_DUR     = 0.4

Insight.DEFAULT_ANCHOR  = "cursor"
Insight.FIXED_POINT     = "BOTTOMRIGHT"
Insight.FIXED_X         = -60
Insight.FIXED_Y         = 120

Insight.FACTION_ICONS = {
    Horde    = "|TInterface\\FriendsFrame\\PlusManz-Horde:14:14:0:0|t ",
    Alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:14:14:0:0|t ",
}

Insight.FACTION_COLORS = {
    Alliance = { 0.00, 0.44, 0.87 },
    Horde    = { 0.87, 0.17, 0.17 },
}

Insight.SPEC_COLOR      = { 0.65, 0.75, 0.85 }
Insight.MOUNT_COLOR     = { 0.80, 0.65, 1.00 }
Insight.MOUNT_SRC_COLOR = { 0.55, 0.55, 0.55 }
Insight.ILVL_COLOR      = { 0.60, 0.85, 1.00 }
Insight.TITLE_COLOR     = { 1.00, 0.82, 0.00 }
Insight.TRANSMOG_HAVE   = { 0.40, 1.00, 0.55 }
Insight.TRANSMOG_MISS   = { 0.65, 0.65, 0.65 }

Insight.ROLE_COLORS = {
    TANK    = { 0.30, 0.60, 1.00 },
    HEALER  = { 0.30, 1.00, 0.40 },
    DAMAGER = { 1.00, 0.55, 0.20 },
}

Insight.MYTHIC_ICON = "|TInterface\\Icons\\achievement_challengemode_gold:14:14:0:0|t "
Insight.SEPARATOR   = string.rep("-", 22)
Insight.SEP_COLOR   = { 0.18, 0.18, 0.18 }

-- Alias for debug / callers; canonical table is addon.CLASS_ICON_RONDO_NAMES (core/ClassIconMedia.lua).
Insight.RONDO_CLASS_NAMES = addon.CLASS_ICON_RONDO_NAMES

Insight.CINEMATIC_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- ============================================================================
-- SHARED HELPERS
-- ============================================================================

--- True when Horizon Suite has the Insight module enabled in options.
--- @return boolean
function Insight.IsInsightEnabled()
    return addon:IsModuleEnabled("insight")
end

local floor = math.floor

function Insight.FormatNumberWithCommas(n)
    if type(n) ~= "number" then return tostring(n) end
    if BreakUpLargeNumbers then
        return BreakUpLargeNumbers(floor(n))
    end
    local s = tostring(floor(n))
    local i = #s % 3
    if i == 0 then i = 3 end
    return s:sub(1, i) .. s:sub(i + 1):gsub("(%d%d%d)", ",%1")
end

function Insight.FormatNumbersInString(str)
    if not str or str == "" then return str end
    return (str:gsub("%d+", function(numStr)
        local n = tonumber(numStr)
        if n and #numStr >= 4 then
            return Insight.FormatNumberWithCommas(n)
        end
        return numStr
    end))
end

function Insight.MythicScoreColor(score)
    if score >= 3000 then return 1.00, 0.50, 0.00
    elseif score >= 2500 then return 0.85, 0.40, 1.00
    elseif score >= 2000 then return 0.20, 0.75, 1.00
    elseif score >= 1500 then return 0.40, 1.00, 0.40
    else return 0.65, 0.65, 0.65
    end
end

function Insight.easeOut(t) return 1 - (1 - t) * (1 - t) end

--- Iterate over tooltip lines; fn(i, left, right) receives line index and font strings.
function Insight.ForTooltipLines(tooltip, fn)
    if not tooltip then return end
    local name = tooltip:GetName()
    if not name then return end
    local numLines = tooltip:NumLines()
    for i = 1, numLines do
        local left  = _G[name .. "TextLeft" .. i]
        local right = _G[name .. "TextRight" .. i]
        fn(i, left, right)
    end
end

--- Safe get text from font string; returns "" on error (secret/taint).
function Insight.SafeGetFontText(font)
    if not font then return "" end
    local ok, val = pcall(font.GetText, font)
    return (ok and val) or ""
end

--- Safely check if font string text equals any of the given values. Returns false on taint/secret string.
--- Use instead of SafeGetFontText + == to avoid "attempt to compare secret string" errors in secure contexts.
--- @param font table FontString
--- @param ... string Values to compare against
--- @return boolean
function Insight.SafeFontTextEquals(font, ...)
    if not font then return false end
    local expected = {...}
    if #expected == 0 then return false end
    local ok, result = pcall(function()
        local text = font:GetText()
        if not text then return false end
        for i = 1, #expected do
            if text == expected[i] then return true end
        end
        return false
    end)
    return (ok and result) or false
end

--- Add a section separator line to tooltip.
function Insight.AddSectionSeparator(tooltip, r, g, b)
    if not tooltip then return end
    if addon.GetDB("insightBlankSeparator", false) then
        tooltip:AddLine(" ", 1, 1, 1)
    else
        local sepR = r or Insight.SEP_COLOR[1]
        local sepG = g or Insight.SEP_COLOR[2]
        local sepB = b or Insight.SEP_COLOR[3]
        tooltip:AddLine(Insight.SEPARATOR, sepR, sepG, sepB)
    end
end

--- Apply stored anchor position to frame.
function Insight.ApplyStoredAnchor(frame)
    if not frame then return end
    frame:ClearAllPoints()
    frame:SetPoint(
        addon.GetDB("insightFixedPoint", Insight.FIXED_POINT),
        UIParent,
        addon.GetDB("insightFixedPoint", Insight.FIXED_POINT),
        tonumber(addon.GetDB("insightFixedX", Insight.FIXED_X)) or Insight.FIXED_X,
        tonumber(addon.GetDB("insightFixedY", Insight.FIXED_Y)) or Insight.FIXED_Y
    )
end

--- Print to addon chat; no-op if HSPrint unavailable.
function Insight.Print(...)
    if addon.HSPrint then addon.HSPrint(...) end
end

--- Print multiple lines.
function Insight.PrintBlock(lines)
    if not addon.HSPrint then return end
    for _, line in ipairs(lines) do
        addon.HSPrint(line)
    end
end

--- Scale value for Insight module.
function Insight.Scaled(v)
    return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "insight")
end

--- Strip NineSlice from tooltip; ApplyBackdrop applies cinematic styling.
function Insight.StripNineSlice(tooltip)
    if tooltip and tooltip.NineSlice then
        tooltip.NineSlice:SetAlpha(0)
    end
end

function Insight.RestoreNineSlice(tooltip)
    if tooltip and tooltip.NineSlice then
        tooltip.NineSlice:SetAlpha(1)
    end
end

function Insight.GetBackdropColor()
    local r, g, b = Insight.PANEL_BG[1], Insight.PANEL_BG[2], Insight.PANEL_BG[3]
    local a = tonumber(addon.GetDB("insightBgOpacity", Insight.PANEL_BG[4])) or Insight.PANEL_BG[4]
    if a > 1 then a = a / 100 end -- legacy: stored as 0-100
    return r, g, b, a
end

function Insight.ApplyBackdrop(tooltip)
    if not tooltip then return end
    if not tooltip.SetBackdrop then
        Mixin(tooltip, BackdropTemplateMixin)
    end
    tooltip:SetBackdrop(Insight.CINEMATIC_BACKDROP)
    local r, g, b, a = Insight.GetBackdropColor()
    tooltip:SetBackdropColor(r, g, b, a)
    tooltip:SetBackdropBorderColor(Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
end

local function StyleFonts(tooltip)
    if not tooltip then return end
    local S        = Insight.Scaled
    local tags     = tooltip._insightLineTags
    local headerSz = GetInsightHeaderSize()
    local bodySz   = GetInsightBodySize()
    local sizeForTag = {
        badges   = GetInsightBadgesSize(),
        stats    = GetInsightStatsSize(),
        mount    = GetInsightMountSize(),
        transmog = GetInsightTransmogSize(),
    }

    local tooltipType = tooltip._insightTooltipType
    if tooltipType == "player" then
        headerSz             = addon.GetDB("insightPlayerHeaderSize", headerSz)
        bodySz               = addon.GetDB("insightPlayerBodySize",   bodySz)
        sizeForTag.badges    = addon.GetDB("insightPlayerBadgesSize", sizeForTag.badges)
        sizeForTag.stats     = addon.GetDB("insightPlayerStatsSize",  sizeForTag.stats)
        sizeForTag.mount     = addon.GetDB("insightPlayerMountSize",  sizeForTag.mount)
    elseif tooltipType == "npc" then
        headerSz = addon.GetDB("insightNpcHeaderSize", headerSz)
        bodySz   = addon.GetDB("insightNpcBodySize",   bodySz)
    elseif tooltipType == "item" then
        headerSz = addon.GetDB("insightItemHeaderSize", headerSz)
        bodySz   = addon.GetDB("insightItemBodySize",   bodySz)
        sizeForTag.transmog = addon.GetDB("insightItemTransmogSize", sizeForTag.transmog)
    end

    Insight.ForTooltipLines(tooltip, function(i, left, right)
        local tag    = tags and tags[i]
        local sz     = tag and sizeForTag[tag] or ((i == 1) and headerSz or bodySz)
        local rightSz = tag and sizeForTag[tag] or bodySz
        if left  then left:SetFont(GetInsightFontPath(),  S(sz),      "OUTLINE") end
        if right then right:SetFont(GetInsightFontPath(), S(rightSz), "OUTLINE") end
    end)
end

function Insight.StyleFonts(tooltip)
    StyleFonts(tooltip)
end

function Insight.StyleTooltipFull(tooltip)
    Insight.StripNineSlice(tooltip)
    Insight.ApplyBackdrop(tooltip)
end

-- ============================================================================
-- CLASS ICON (Default / RondoMedia via core/ClassIconMedia.lua)
-- ============================================================================

--- Returns texture string for class icon, or nil if icons disabled.
--- Respects insightClassIconSource: "default" | "rondomedia".
--- @param classFile string UnitClass classFile (DEATHKNIGHT, etc.)
--- @param size number Display size (default 14)
--- @return string|nil Texture markup or nil
function Insight.GetClassIconTexture(classFile, size)
    if not addon.GetDB("insightShowIcons", true) or not classFile then return nil end
    size = size or 14
    local source = addon.GetDB("insightClassIconSource", "default")
    local disp = addon.ResolveClassIconDisplay and addon.ResolveClassIconDisplay(classFile, source)
    if not disp then return nil end
    if disp.kind == "file" then
        return "|T" .. disp.path .. ":" .. size .. ":" .. size .. ":0:0|t "
    end
    if disp.kind == "atlas" and CreateAtlasMarkup then
        return CreateAtlasMarkup(disp.atlas, size, size) .. " "
    end
    return nil
end

--- Register RondoMedia class icons with LibSharedMedia (delegates to addon.RegisterRondoClassIconsWithLSM).
--- @return nil
function Insight.RegisterRondoClassIconsWithLSM()
    if addon.RegisterRondoClassIconsWithLSM then
        addon.RegisterRondoClassIconsWithLSM()
    end
end

addon.Insight = Insight
