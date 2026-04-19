--[[
    Horizon Suite - Horizon Insight (Item Tooltip)
    Item-specific tooltip enrichment: transmog state.
    Structured as append-only block builders (AddAppearanceBlock, etc.).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- Equippable item used only for dashboard tooltip preview (name, quality border, transmog line).
Insight.DASHBOARD_PREVIEW_ITEM_ID = 168602

local function ShowTransmog()
    return addon.GetDB("insightShowTransmog", true)
end

local function AddItemSectionSeparator(tooltip, r, g, b)
    if addon.GetDB("insightItemSectionSpacing", false) then
        tooltip:AddLine(" ", 1, 1, 1)
    else
        Insight.AddSectionSeparator(tooltip, r, g, b)
    end
end

local TRANSMOG_COLLECTED_TEXT = "Appearance: Collected"
local TRANSMOG_MISSING_TEXT   = "Appearance: Not collected"

local NON_TRANSMOG_EQUIP = {
    INVTYPE_TRINKET = true,
    INVTYPE_FINGER  = true,
    INVTYPE_NECK    = true,
}

local function IsTransmoggableItem(itemID)
    if not C_Item or not C_Item.GetItemInfo then return false end
    local _, _, _, _, _, itemType, _, _, itemEquipLoc = C_Item.GetItemInfo(itemID)
    if not itemType then return false end
    if itemType ~= "Armor" and itemType ~= "Weapon" then return false end
    if itemEquipLoc and NON_TRANSMOG_EQUIP[itemEquipLoc] then return false end
    return true
end

-- Midnight: PlayerHasTransmogByItemInfo may return a secret boolean; only plain literals escape.
local function GetTransmogKnownAndCollected(itemID)
    local known = false
    local collected = false
    pcall(function()
        local v = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
        local state = "unknown"
        pcall(function()
            if v == nil then
                state = "nil"
            elseif v == true then
                state = "true"
            elseif v == false then
                state = "false"
            else
                state = "unknown"
            end
        end)
        if state == "nil" then
            known = false
        elseif state == "true" then
            known = true
            collected = true
        elseif state == "false" then
            known = true
            collected = false
        else
            known = false
        end
    end)
    return known, collected
end

local function HasTransmogLine(tooltip)
    local hasLine = false
    Insight.ForTooltipLines(tooltip, function(_, left)
        if left and Insight.SafeFontTextEquals(left, TRANSMOG_COLLECTED_TEXT, TRANSMOG_MISSING_TEXT) then
            hasLine = true
        end
    end)
    return hasLine
end

-- ============================================================================
-- QUALITY GRADIENT (item name first line)
--
-- Implementation note: FontString:SetGradient is blocked by the |cAARRGGBB
-- escape codes that Blizzard bakes into the item name line, so the gradient
-- is invisible in practice. Instead we strip the existing escapes and inject
-- a per-character |cAARRGGBB colour span interpolated between two shades of
-- the quality colour. Same technique used by Eltruism / Windtools.
-- ============================================================================

-- Iterate a UTF-8 byte string one character at a time (so multi-byte
-- non-ASCII item names don't get shredded when we wrap each char in |c..|r).
local function Utf8Chars(s)
    local out = {}
    local i, n = 1, #s
    while i <= n do
        local b = s:byte(i) or 0
        local len
        if b < 0x80 then len = 1
        elseif b < 0xC0 then len = 1 -- stray continuation byte; emit as-is
        elseif b < 0xE0 then len = 2
        elseif b < 0xF0 then len = 3
        else                   len = 4
        end
        out[#out + 1] = s:sub(i, i + len - 1)
        i = i + len
    end
    return out
end

local function BuildGradientString(plain, r1, g1, b1, r2, g2, b2)
    local chars = Utf8Chars(plain)
    local n = #chars
    if n == 0 then return plain end
    local parts = {}
    for i = 1, n do
        local ch = chars[i]
        if ch == " " or ch == "\t" or ch == "\n" then
            parts[#parts + 1] = ch
        else
            local t = (n > 1) and ((i - 1) / (n - 1)) or 0
            local r = math.floor((r1 + (r2 - r1) * t) * 255 + 0.5)
            local g = math.floor((g1 + (g2 - g1) * t) * 255 + 0.5)
            local b = math.floor((b1 + (b2 - b1) * t) * 255 + 0.5)
            parts[#parts + 1] = string.format("|cff%02x%02x%02x%s|r", r, g, b, ch)
        end
    end
    return table.concat(parts)
end

--- Rewrite the tooltip's first text line with a per-character gradient of the
--- item quality colour (darker → brighter, left to right). No-op on tooltips
--- without a GetName, when the option is off, or when quality is unknown.
--- Synchronous — apply right now. Callers driven by TDP / Show should usually
--- use Insight.ScheduleItemNameGradient instead: Blizzard does a final layout
--- text pass after both of those hooks, and running on the next frame is the
--- only way to guarantee our text wins.
--- @param tooltip table GameTooltip-like frame (must expose GetName and have <name>TextLeft1 FontString)
--- @param quality number|nil Item quality index (0..7)
function Insight.ApplyItemNameGradient(tooltip, quality)
    if not tooltip or not tooltip.GetName then return end
    local name = tooltip:GetName()
    if not name then return end
    local fs = _G[name .. "TextLeft1"]
    if not fs or not fs.SetText or not fs.GetText then return end

    if not Insight.IsInsightEnabled() then return end
    if not addon.GetDB("insightItemNameGradient", true) then return end
    if not quality or quality < 0 then return end

    local colors = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if not colors then return end
    local r, g, b = colors.r, colors.g, colors.b
    local r1, g1, b1 = r * 0.65, g * 0.65, b * 0.65
    local r2 = math.min(1, r * 1.20 + 0.15)
    local g2 = math.min(1, g * 1.20 + 0.15)
    local b2 = math.min(1, b * 1.20 + 0.15)

    pcall(function()
        local raw = fs:GetText()
        if type(raw) ~= "string" or raw == "" then return end
        -- Strip any existing Blizzard colour escapes, then re-wrap per character.
        local plain = raw:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        if plain == "" then return end
        local gradient = BuildGradientString(plain, r1, g1, b1, r2, g2, b2)
        if gradient == plain then return end
        fs:SetText(gradient)
    end)
end

--- Deferred variant: apply the gradient on the next frame so we run after
--- Blizzard's final layout/text pass. The token on tooltip._insightGradientPending
--- collapses multiple schedule calls (TDP post-call + Show hook + SetBagItem
--- internal show) into a single apply per display.
--- @param tooltip table GameTooltip-like frame
--- @param quality number|nil Item quality index
function Insight.ScheduleItemNameGradient(tooltip, quality)
    if not tooltip or not quality or quality < 0 then return end
    if not C_Timer or not C_Timer.After then
        Insight.ApplyItemNameGradient(tooltip, quality)
        return
    end
    local token = (tooltip._insightGradientPending or 0) + 1
    tooltip._insightGradientPending = token
    C_Timer.After(0, function()
        if tooltip._insightGradientPending ~= token then return end
        tooltip._insightGradientPending = nil
        Insight.ApplyItemNameGradient(tooltip, quality)
    end)
end

-- ============================================================================
-- SetText-level hook: stops the one-frame flash when Blizzard re-renders
-- mid-display. hooksecurefunc on the FontString's SetText runs after every
-- text write; if the tooltip is in item mode (quality cached) and the new
-- text isn't already our gradient, re-wrap it in the same frame. Reentrancy
-- guard prevents us recursing on our own SetText call.
-- ============================================================================

local gradientReentry = {}

local function WrapFirstLineText(tooltip, fs, incomingText)
    if not tooltip or not fs then return end
    if gradientReentry[fs] then return end
    local quality = tooltip._insightItemQuality
    if not quality or quality < 0 then return end
    if not Insight.IsInsightEnabled() then return end
    if not addon.GetDB("insightItemNameGradient", true) then return end
    local colors = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if not colors then return end

    -- Reentrancy guard must always clear, even if the inner SetText errors
    -- (e.g., a Midnight secret-string taint surfaces mid-processing). Keeping
    -- the guard outside the pcall guarantees this.
    gradientReentry[fs] = true
    pcall(function()
        local raw = incomingText
        if type(raw) ~= "string" or raw == "" then
            raw = fs:GetText()
        end
        if type(raw) ~= "string" or raw == "" then return end
        local plain = raw:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        if plain == "" then return end
        local r, g, b = colors.r, colors.g, colors.b
        local r1, g1, b1 = r * 0.65, g * 0.65, b * 0.65
        local r2 = math.min(1, r * 1.20 + 0.15)
        local g2 = math.min(1, g * 1.20 + 0.15)
        local b2 = math.min(1, b * 1.20 + 0.15)
        local gradient = BuildGradientString(plain, r1, g1, b1, r2, g2, b2)
        if gradient == raw then return end
        fs:SetText(gradient)
        if Insight._gradientDebug then
            local plainShort = plain:sub(1, 30)
            Insight.Print(string.format(
                "gradient: q=%d  plain=%q  start=%02x%02x%02x  end=%02x%02x%02x",
                quality, plainShort,
                math.floor(r1*255), math.floor(g1*255), math.floor(b1*255),
                math.floor(r2*255), math.floor(g2*255), math.floor(b2*255)))
        end
    end)
    gradientReentry[fs] = nil
end

--- Install a persistent hook on the tooltip's first-line FontString so any
--- subsequent Blizzard-driven SetText is re-wrapped with our gradient in the
--- same frame. Call once per tooltip in Init; idempotent via _insightGradientTextHooked.
--- @param tooltip table GameTooltip-like frame
function Insight.InstallItemNameGradientHook(tooltip)
    if not tooltip or tooltip._insightGradientTextHooked then return end
    if not tooltip.GetName then return end
    local name = tooltip:GetName()
    if not name then return end
    local fs = _G[name .. "TextLeft1"]
    if not fs or not fs.SetText then return end
    tooltip._insightGradientTextHooked = true
    hooksecurefunc(fs, "SetText", function(self, text)
        WrapFirstLineText(tooltip, self, text)
    end)
end

-- ============================================================================
-- ITEM BLOCK BUILDERS
-- ============================================================================

--- Add appearance (transmog) block to tooltip.
--- @param tooltip table GameTooltip or other tooltip frame
--- @param itemID number Item ID
--- @return boolean true if block was added
function Insight.AddAppearanceBlock(tooltip, itemID)
    if not Insight.IsInsightEnabled() or not ShowTransmog() then return false end
    if not C_TransmogCollection or not itemID then return false end
    if not IsTransmoggableItem(itemID) then return false end
    if HasTransmogLine(tooltip) then return false end

    local known, collected = GetTransmogKnownAndCollected(itemID)
    if not known then return false end

    Insight.TagLines(tooltip, "transmog", function()
        if collected then
            tooltip:AddLine(TRANSMOG_COLLECTED_TEXT, Insight.TRANSMOG_HAVE[1], Insight.TRANSMOG_HAVE[2], Insight.TRANSMOG_HAVE[3])
        else
            tooltip:AddLine(TRANSMOG_MISSING_TEXT, Insight.TRANSMOG_MISS[1], Insight.TRANSMOG_MISS[2], Insight.TRANSMOG_MISS[3])
        end
    end)
    return true
end

--- Process item tooltip: add structured Insight blocks (appearance, etc.).
--- Adds a section separator only when at least one block will be shown.
--- @param tooltip table GameTooltip or other tooltip frame
--- @param itemID number Item ID
--- @param quality number|nil Item quality for separator tint
--- @return boolean true if any block was added
function Insight.ProcessItemTooltip(tooltip, itemID, quality)
    if not Insight.IsInsightEnabled() or not itemID then return false end

    local transmogKnown = select(1, GetTransmogKnownAndCollected(itemID))
    local hasAppearance = ShowTransmog() and C_TransmogCollection
        and IsTransmoggableItem(itemID)
        and transmogKnown
        and not HasTransmogLine(tooltip)

    if not hasAppearance then return false end

    local sepR, sepG, sepB
    if quality and quality >= 0 and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        sepR, sepG, sepB = c.r, c.g, c.b
    end
    AddItemSectionSeparator(tooltip, sepR, sepG, sepB)
    return Insight.AddAppearanceBlock(tooltip, itemID)
end

--- Render sample item tooltip content for the options dashboard preview.
--- @param tooltip table Mock tooltip with AddLine and optional ClearLines
--- @return nil
function Insight.RenderItemPreviewContent(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    local itemID = Insight.DASHBOARD_PREVIEW_ITEM_ID
    local itemName = "Sample Item"
    local quality = 2
    local itemLevel = nil
    if C_Item and C_Item.GetItemInfo then
        local name, _, q, ilvl = C_Item.GetItemInfo(itemID)
        if name and name ~= "" then
            itemName = name
        end
        if type(q) == "number" then
            quality = q
        end
        if type(ilvl) == "number" and ilvl > 0 then
            itemLevel = ilvl
        end
    end
    local qr, qg, qb = 1, 1, 1
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        qr, qg, qb = c.r, c.g, c.b
    end
    tooltip:AddLine(itemName, qr, qg, qb)
    Insight.ApplyItemNameGradient(tooltip, quality)
    if itemLevel then
        tooltip:AddLine("Item Level " .. tostring(itemLevel), 1, 1, 1)
    end
    if ShowTransmog() and C_TransmogCollection and IsTransmoggableItem(itemID) then
        Insight.AddSectionSeparator(tooltip, qr, qg, qb)
        Insight.AddAppearanceBlock(tooltip, itemID)
    end
end

addon.Insight = Insight
