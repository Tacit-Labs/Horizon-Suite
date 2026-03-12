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
Insight.HEADER_SIZE     = 14
Insight.BODY_SIZE       = 12
Insight.SMALL_SIZE      = 10

Insight.PANEL_BG        = { 0, 0, 0, 0.75 }
Insight.PANEL_BORDER    = { 0.25, 0.25, 0.25, 0.30 }

Insight.FADE_IN_DUR     = 0.15

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
Insight.SEP_INSET   = 10

Insight.CINEMATIC_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- ============================================================================
-- SHARED HELPERS
-- ============================================================================

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

--- Add a section separator line to tooltip.
function Insight.AddSectionSeparator(tooltip, r, g, b)
    if not tooltip then return end
    local sepR = r or Insight.SEP_COLOR[1]
    local sepG = g or Insight.SEP_COLOR[2]
    local sepB = b or Insight.SEP_COLOR[3]
    tooltip:AddLine(Insight.SEPARATOR, sepR, sepG, sepB)
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

function Insight.ApplyBackdrop(tooltip)
    if not tooltip then return end
    if not tooltip.SetBackdrop then
        Mixin(tooltip, BackdropTemplateMixin)
    end
    tooltip:SetBackdrop(Insight.CINEMATIC_BACKDROP)
    tooltip:SetBackdropColor(Insight.PANEL_BG[1], Insight.PANEL_BG[2], Insight.PANEL_BG[3], Insight.PANEL_BG[4])
    tooltip:SetBackdropBorderColor(Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
end

local function StyleFonts(tooltip)
    if not tooltip then return end
    local S = Insight.Scaled
    local metadataStartLine = nil
    if tooltip._insightItemMetadata then
        local name = tooltip:GetName()
        if name then
            for i = 1, tooltip:NumLines() do
                local left = _G[name .. "TextLeft" .. i]
                if left and Insight.SafeGetFontText(left) == Insight.SEPARATOR then
                    metadataStartLine = i
                    break
                end
            end
        end
    end

    Insight.ForTooltipLines(tooltip, function(i, left, right)
        if left then
            local sz
            if metadataStartLine and i >= metadataStartLine then
                sz = S(Insight.SMALL_SIZE)
            else
                sz = (i == 1) and S(Insight.HEADER_SIZE) or S(Insight.BODY_SIZE)
            end
            left:SetFont(Insight.FONT_PATH, sz, "OUTLINE")
        end
        if right then
            local sz = (metadataStartLine and i >= metadataStartLine) and S(Insight.SMALL_SIZE) or S(Insight.BODY_SIZE)
            right:SetFont(Insight.FONT_PATH, sz, "OUTLINE")
        end
    end)
end

function Insight.StyleFonts(tooltip)
    StyleFonts(tooltip)
end

function Insight.StyleTooltipFull(tooltip)
    Insight.StripNineSlice(tooltip)
    Insight.ApplyBackdrop(tooltip)
end

addon.Insight = Insight
