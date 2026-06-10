--[[
    Horizon Suite - Horizon Insight (Shared)
    Shared helpers for tooltip line iteration, styling, separators, print, and render utilities.
    Used by InsightPlayerTooltip, InsightNpcTooltip, InsightItemTooltip, and InsightCore.
]]

local addon = _G.HorizonSuite

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- ============================================================================
-- CONSTANTS (shared across all Insight tooltip types)
-- ============================================================================

Insight.FONT_PATH       = "Fonts\\FRIZQT__.TTF"

local INSIGHT_FONT_USE_GLOBAL = "__global__"

local function GetInsightFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local raw = addon.GetDB and addon.GetDB("insightFontPath", INSIGHT_FONT_USE_GLOBAL) or INSIGHT_FONT_USE_GLOBAL
    if raw ~= INSIGHT_FONT_USE_GLOBAL and raw ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(raw)) or raw
    end
    local base = addon.GetDB and addon.GetDB("fontPath", nil)
    if base and base ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(base)) or base
    end
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
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
-- Fade-out duration (stale unit dismiss and future unified outs); match fade-in for symmetry.
Insight.FADE_OUT_DUR    = Insight.FADE_IN_DUR

Insight.DEFAULT_ANCHOR  = "cursor"
Insight.FIXED_POINT     = "BOTTOMRIGHT"
Insight.FIXED_X         = -60
Insight.FIXED_Y         = 120

-- Class/spec line icons: Horizon bundled media (OptionsData value "custom"); default for new profiles.
Insight.DEFAULT_CLASS_ICON_SOURCE = "custom"

Insight.FACTION_ICONS = {
    Horde    = "|TInterface\\FriendsFrame\\PlusManz-Horde:14:14:0:0|t ",
    Alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:14:14:0:0|t ",
}

Insight.FACTION_COLORS = {
    Alliance = { 0.00, 0.44, 0.87 },
    Horde    = { 0.87, 0.17, 0.17 },
}

function Insight.GetPlayerTooltipBorderColor(unit, classColor, trp3Data)
    if trp3Data and trp3Data.customColorR and addon.GetDB("insightTRP3BorderColor", false) then
        return trp3Data.customColorR, trp3Data.customColorG, trp3Data.customColorB, 0.60
    end

    local mode = addon.GetDB("insightPlayerTooltipBorder", "class")
    if mode == "class" and classColor then
        return classColor.r, classColor.g, classColor.b, 0.60
    elseif mode == "faction" and unit then
        local faction
        pcall(function() faction = UnitFactionGroup(unit) end)
        local fc = faction and Insight.FACTION_COLORS[faction]
        if fc then return fc[1], fc[2], fc[3], 0.60 end
    end

    return Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4]
end

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

Insight.MYTHIC_ICON       = "|TInterface\\Icons\\achievement_challengemode_gold:14:14:0:0:64:64:5:59:5:59|t "
Insight.HONOR_ICON        = "|T132147:14:14:0:0:64:64:5:59:5:59|t "
Insight.ILVL_ICON         = "|T1030901:14:14:0:0:64:64:5:59:5:59|t "
Insight.ACHIEVEMENT_ICON  = "|TInterface\\Icons\\achievement_dungeon_heroic_gloryoftheraider:14:14:0:0:64:64:5:59:5:59|t "
Insight.ACHIEVEMENT_POINTS_COLOR = { 1.00, 0.82, 0.00 }
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

-- True when Horizon Suite has the Insight module enabled in options.
-- @return boolean
function Insight.IsInsightEnabled()
    return addon:IsModuleEnabled("insight")
end

function Insight.FormatNumberWithCommas(n)
    if addon.FormatNumberWithGrouping then
        return addon.FormatNumberWithGrouping(n)
    end
    if type(n) ~= "number" then return tostring(n) end
    if BreakUpLargeNumbers then
        return BreakUpLargeNumbers(math.floor(n))
    end
    local s = tostring(math.floor(n))
    local i = #s % 3
    if i == 0 then i = 3 end
    return s:sub(1, i) .. s:sub(i + 1):gsub("(%d%d%d)", ",%1")
end

function Insight.FormatNumbersInString(str)
    if addon.FormatLargeNumbersInString then
        return addon.FormatLargeNumbersInString(str)
    end
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
    return 0.85, 0.40, 1.00
end

function Insight.easeOut(t) return 1 - (1 - t) * (1 - t) end

-- Iterate a UTF-8 byte string one character at a time so multi-byte (CJK,
-- accented) item and player names stay intact when we wrap each char in
-- |cff…|r for gradients.
-- @param s string
-- @return table
function Insight.Utf8Chars(s)
    local out = {}
    local i, n = 1, #s
    while i <= n do
        local b = s:byte(i) or 0
        local len
        if     b < 0x80 then len = 1
        elseif b < 0xC0 then len = 1 -- stray continuation byte; emit as-is
        elseif b < 0xE0 then len = 2
        elseif b < 0xF0 then len = 3
        else                 len = 4
        end
        out[#out + 1] = s:sub(i, i + len - 1)
        i = i + len
    end
    return out
end

-- Strip Blizzard colour-escape sequences (`|cAARRGGBB…|r`) from a string.
-- Used before re-wrapping text as a per-character gradient.
-- @param text string
-- @return string
function Insight.StripColourEscapes(text)
    if type(text) ~= "string" or text == "" then return "" end
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

-- Build a two-stop horizontal gradient (darker → brighter) of the given
-- base RGB colour over `plain` text, as a single |cff…|r-escaped string.
-- Shared by the item-name gradient (InsightItemTooltip) and the
-- player-name gradient (InsightPlayerTooltip).
-- @param plain string Plain text to colour
-- @param r number Base red (0..1)
-- @param g number Base green (0..1)
-- @param b number Base blue (0..1)
-- @return string Escape-coded gradient text (or `plain` if there's nothing to colour)
function Insight.BuildNameGradient(plain, r, g, b, bias)
    local shift = (type(bias) == "number") and (bias / 100) or 0
    local clamp = math.max
    local r1 = clamp(0, math.min(1, r * 0.65 + shift))
    local g1 = clamp(0, math.min(1, g * 0.65 + shift))
    local b1 = clamp(0, math.min(1, b * 0.65 + shift))
    local r2 = clamp(0, math.min(1, r * 1.20 + 0.15 + shift))
    local g2 = clamp(0, math.min(1, g * 1.20 + 0.15 + shift))
    local b2 = clamp(0, math.min(1, b * 1.20 + 0.15 + shift))

    local chars = Insight.Utf8Chars(plain)
    local n = #chars
    if n == 0 then return plain end
    local parts = {}
    for i = 1, n do
        local ch = chars[i]
        if ch == " " or ch == "\t" or ch == "\n" then
            parts[#parts + 1] = ch
        else
            local t = (n > 1) and ((i - 1) / (n - 1)) or 0
            local cr = math.floor((r1 + (r2 - r1) * t) * 255 + 0.5)
            local cg = math.floor((g1 + (g2 - g1) * t) * 255 + 0.5)
            local cb = math.floor((b1 + (b2 - b1) * t) * 255 + 0.5)
            parts[#parts + 1] = string.format("|cff%02x%02x%02x%s|r", cr, cg, cb, ch)
        end
    end
    return table.concat(parts)
end

-- Iterate over tooltip lines; fn(i, left, right) receives line index and font strings.
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

-- Safe get text from a font string as a plain Lua string (safe for string.* / :gsub).
-- GetText can return a secret string on Midnight; that value must not be passed to string APIs from addon code.
-- Returns "" on error, nil text, or if coercion fails.
-- @param font table FontString|nil
-- @return string
function Insight.SafeGetFontText(font)
    if not font then return "" end
    local ok, out = pcall(function()
        local ok2, val = pcall(font.GetText, font)
        if not ok2 or val == nil then
            return ""
        end
        local ok3, plain = pcall(tostring, val)
        return (ok3 and plain) or ""
    end)
    return (ok and out) or ""
end

-- Safely check if font string text equals any of the given values. Returns false on taint/secret string.
-- Use instead of SafeGetFontText + == to avoid "attempt to compare secret string" errors in secure contexts.
-- @param font table FontString
-- @param ... string Values to compare against
-- @return boolean
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

-- Add a section separator line to tooltip.
function Insight.AddSectionSeparator(tooltip, r, g, b)
    if not tooltip then return end
    local mode = addon.GetDB("insightSeparatorMode", nil)
    if mode ~= "divider" and mode ~= "blank" and mode ~= "none" then
        mode = addon.GetDB("insightBlankSeparator", false) and "blank" or "divider"
    end
    if mode == "none" then
        return
    elseif mode == "blank" then
        tooltip:AddLine(" ", 1, 1, 1)
    else
        local sepR = r or Insight.SEP_COLOR[1]
        local sepG = g or Insight.SEP_COLOR[2]
        local sepB = b or Insight.SEP_COLOR[3]
        tooltip:AddLine(Insight.SEPARATOR, sepR, sepG, sepB)
    end
end

-- Apply stored anchor position to frame.
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

-- Print to addon chat; no-op if HSPrint unavailable.
function Insight.Print(...)
    if addon.HSPrint then addon.HSPrint(...) end
end

-- Print multiple lines.
function Insight.PrintBlock(lines)
    if not addon.HSPrint then return end
    for _, line in ipairs(lines) do
        addon.HSPrint(line)
    end
end

-- Scale value for Insight module.
function Insight.Scaled(v)
    return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "insight")
end

function Insight.ApplyNativeTooltipScale(tooltip)
    if not tooltip or tooltip._insightPreviewMock or not tooltip.SetScale then return end
    local scale = 1
    if addon.GetModuleScale then
        scale = tonumber(addon.GetModuleScale("insight")) or 1
    end
    tooltip:SetScale(scale)
end

-- Strip NineSlice from tooltip; ApplyBackdrop applies cinematic styling.
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

local BG_COLOR_KEY = {
    player = "insightPlayerBgColor",
    npc    = "insightNpcBgColor",
    item   = "insightItemBgColor",
}

function Insight.GetBackdropColor(tooltipType)
    local r, g, b = Insight.PANEL_BG[1], Insight.PANEL_BG[2], Insight.PANEL_BG[3]
    local key = tooltipType and BG_COLOR_KEY[tooltipType]
    if key then
        local c = addon.GetDB(key, nil)
        if c and type(c) == "table" and c[1] and c[2] and c[3] then
            r, g, b = c[1], c[2], c[3]
        end
    end
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
    local r, g, b, a = Insight.GetBackdropColor(tooltip._insightTooltipType)
    tooltip:SetBackdropColor(r, g, b, a)
    tooltip:SetBackdropBorderColor(Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
end

-- Per-FontString hook that re-asserts our font path whenever a font-replacement
-- addon (e.g. Platynator) overrides SetFont or SetFontObject on that string.
-- Size is nil so per-line size choices (header/body/badges) go through unchanged.
-- Mirrors LockDirectFont in PresenceTalkingHead.lua.
local function LockDirectFont(fontString, getFont)
    local busyObj  = false
    local busyFont = false
    -- Cached last-known target path. Avoids calling getFont() (DB lookup) when the
    -- incoming path already matches — which happens on every StyleFonts call.
    local cachedPath = nil

    hooksecurefunc(fontString, "SetFontObject", function(self, obj)
        if busyObj or not obj then return end
        local path, size, flags = getFont()
        if not path then return end
        local _, curSize, curFlags = self:GetFont()
        cachedPath = path  -- set before SetFont fires our hook so it fast-paths
        busyObj = true
        self:SetFontObject(nil)
        self:SetFont(path, size or curSize or 12, flags or curFlags or "OUTLINE")
        busyObj = false
    end)

    hooksecurefunc(fontString, "SetFont", function(self, path, size, flags)
        if busyFont then return end
        -- Fast path: path already matches our target — nothing to override.
        -- Skips the getFont() DB lookup on every StyleFonts → SetFont call.
        if path == cachedPath then return end
        local targetPath, targetSize, targetFlags = getFont()
        if not targetPath then return end
        cachedPath = targetPath
        if path == targetPath then return end
        busyFont = true
        self:SetFont(targetPath, targetSize or size, targetFlags or flags or "OUTLINE")
        busyFont = false
    end)
end

-- Weak-keyed table so GC'd FontStrings are released automatically.
local lockedInsightFontStrings = setmetatable({}, { __mode = "k" })

local function GetInsightFont()
    if not Insight.IsInsightEnabled() then return nil end
    return GetInsightFontPath(), nil, "OUTLINE"
end

local function LockInsightFontString(fs)
    if not fs or lockedInsightFontStrings[fs] then return end
    lockedInsightFontStrings[fs] = true
    LockDirectFont(fs, GetInsightFont)
end

local function StyleFonts(tooltip)
    if not tooltip then return end
    Insight.ApplyNativeTooltipScale(tooltip)
    local S        = tooltip._insightPreviewMock and Insight.Scaled or function(v) return v end
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

    local fontPath = GetInsightFontPath()
    Insight.ForTooltipLines(tooltip, function(i, left, right)
        local tag    = tags and tags[i]
        local sz     = tag and sizeForTag[tag] or ((i == 1) and headerSz or bodySz)
        local rightSz = tag and sizeForTag[tag] or bodySz
        if left  then left:SetFont(fontPath,  S(sz),      "OUTLINE"); LockInsightFontString(left)  end
        if right then right:SetFont(fontPath, S(rightSz), "OUTLINE"); LockInsightFontString(right) end
    end)
end

function Insight.StyleFonts(tooltip)
    StyleFonts(tooltip)
end

function Insight.StyleTooltipFull(tooltip)
    Insight.ApplyNativeTooltipScale(tooltip)
    Insight.StripNineSlice(tooltip)
    Insight.ApplyBackdrop(tooltip)
    StyleFonts(tooltip)
end

-- GameTooltip computes its width from line widths measured with the fonts
-- in effect at layout time. StyleFonts swaps lines to the Insight font (often
-- larger, esp. the header), and GameTooltip does NOT re-measure after a font
-- change — not even on a second Show(). Long names/titles then overflow the
-- right border. Measure the styled lines ourselves and widen the frame to fit.
-- GetStringWidth returns a plain number (0 for empty/hidden lines), so no
-- secret-value handling is needed beyond pcall.
function Insight.FixTooltipWidth(tooltip)
    if not tooltip or tooltip._insightPreviewMock or not tooltip.GetWidth then return end

    -- GetWrappedWidth respects word-wrap on body lines (GetStringWidth would
    -- report the full unwrapped width and over-widen); for non-wrapping lines
    -- like the header it equals the full string width.
    -- Widths can be secret numbers under tainted execution (Midnight); they
    -- cannot be compared directly. tostring→tonumber inside pcall launders
    -- them to plain Lua numbers (same pattern as the CHAT_MSG_LOOT GUID fix).
    local function LineWidth(fs)
        local w = 0
        pcall(function()
            local raw = (fs.GetWrappedWidth and fs:GetWrappedWidth()) or fs:GetStringWidth()
            w = tonumber(tostring(raw)) or 0
        end)
        return w
    end

    local maxW = 0
    Insight.ForTooltipLines(tooltip, function(i, left, right)
        local w = left and LineWidth(left) or 0
        if right then
            local rw = LineWidth(right)
            -- Right-anchored text shares the line; keep a readable gap between columns.
            if rw > 0 then w = w + rw + 14 end
        end
        if w > maxW then maxW = w end
    end)
    if maxW <= 0 then return end

    -- Side inset: distance from the tooltip edge to line 1's left edge (~10px default).
    local inset = 10
    pcall(function()
        local name = tooltip:GetName()
        local l1 = name and _G[name .. "TextLeft1"]
        if l1 then
            local x = tonumber(tostring(select(4, l1:GetPoint(1))))
            if x and x > 0 and x < 30 then inset = x end
        end
    end)

    pcall(function()
        local needed = math.ceil(maxW + inset * 2)
        local current = tonumber(tostring(tooltip:GetWidth())) or 0
        if needed > current then
            tooltip:SetWidth(needed)
        end
    end)
end

-- ============================================================================
-- CLASS ICON (Default / RondoMedia / custom media via core/ClassIconMedia.lua)
-- ============================================================================

local VALID_INSIGHT_CLASS_ICON_SOURCE = { custom = true, default = true, rondomedia = true, specoverride = true }

-- Tooltip class icon pack: Horizon (custom), Blizzard default atlas, or RondoMedia.
-- @return string "custom" | "default" | "rondomedia"
function Insight.GetClassIconSource()
    local def = Insight.DEFAULT_CLASS_ICON_SOURCE
    local s = (addon.GetDB and addon.GetDB("insightClassIconSource", def)) or def
    if type(s) ~= "string" or not VALID_INSIGHT_CLASS_ICON_SOURCE[s] then
        return def
    end
    return s
end

-- Returns texture string for class icon, or nil if icons disabled.
-- Respects insightClassIconSource: "custom" (Horizon bundled) | "default" | "rondomedia".
-- @param classFile string UnitClass classFile (DEATHKNIGHT, etc.)
-- @param size number|nil Display size; omit to use GetInsightClassIconDisplaySize() (larger for custom source).
-- @return string|nil Texture markup or nil
function Insight.GetClassIconTexture(classFile, size)
    if not addon.GetDB("insightShowIcons", true) or not classFile then return nil end
    if size == nil then
        size = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
    end
    local source = Insight.GetClassIconSource()
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

-- Register RondoMedia class icons with LibSharedMedia (delegates to addon.RegisterRondoClassIconsWithLSM).
-- @return nil
function Insight.RegisterRondoClassIconsWithLSM()
    if addon.RegisterRondoClassIconsWithLSM then
        addon.RegisterRondoClassIconsWithLSM()
    end
end

addon.Insight = Insight
