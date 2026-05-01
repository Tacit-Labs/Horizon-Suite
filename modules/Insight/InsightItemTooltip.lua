--[[
    Horizon Suite - Horizon Insight (Item Tooltip)
    Item-specific tooltip enrichment: transmog state.
    Structured as append-only block builders (AddAppearanceBlock, etc.).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G.HorizonSuite

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
-- FontString:SetGradient is blocked by the |cAARRGGBB escape codes Blizzard
-- bakes into item names, so we strip those escapes and re-emit the name as
-- per-character |cAARRGGBB spans interpolated between a darker and brighter
-- shade of the effective quality colour. Same technique as Eltruism.
-- Generic UTF-8 iteration + gradient building lives in InsightShared.
-- ============================================================================

-- TWW upgrade-track name → ItemQuality tier. Detection only ever *raises*
-- quality: the caller takes math.max(baseQuality, trackQuality), so an Epic
-- or Legendary base is never downgraded by a track that maps lower. Track
-- names are English-only here; non-enUS clients fall through to the item's
-- base quality, which is the same as the pre-detection behaviour.
local UPGRADE_TRACK_QUALITY = {
    ["Explorer"]   = 2, -- Uncommon
    ["Adventurer"] = 3, -- Rare
    ["Veteran"]    = 4, -- Epic
    ["Champion"]   = 4, -- Epic
    ["Hero"]       = 4, -- Epic
    ["Myth"]       = 4, -- Epic
}

-- Build a Lua pattern matching the localised "Upgrade Level: <Track> n/m"
-- line. Escapes Lua-pattern magic in the literal segments of the printf
-- format string, replaces `%s` with a non-whitespace capture, and `%d` with
-- a digit run. Falls back to enUS literal if the global is unavailable.
local UPGRADE_LINE_PATTERN
do
    local fmt = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
    if type(fmt) == "string" and fmt ~= "" then
        local parts, last = {}, 1
        for s, code, e in fmt:gmatch("()%%([a-zA-Z])()") do
            if s > last then
                local literal = fmt:sub(last, s - 1)
                parts[#parts + 1] = (literal:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
            end
            if code == "s" then
                parts[#parts + 1] = "(%S+)"
            elseif code == "d" then
                parts[#parts + 1] = "%d+"
            else
                parts[#parts + 1] = "%S+"
            end
            last = e
        end
        if last <= #fmt then
            local literal = fmt:sub(last)
            parts[#parts + 1] = (literal:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
        end
        UPGRADE_LINE_PATTERN = table.concat(parts)
    end
    if not UPGRADE_LINE_PATTERN then
        UPGRADE_LINE_PATTERN = "Upgrade Level:%s+(%S+)%s+%d+/%d+"
    end
end

--- Scan tooltip lines for an "Upgrade Level: <Track> n/m" label and return
--- the mapped ItemQuality tier, or nil if no track is present. Anchored on
--- the localised upgrade-line format so flavour text containing a track
--- word ("Explorer", "Champion", …) cannot trigger a false positive.
--- Wrapped in pcall: line text may be a secret string on some Midnight
--- tooltip sources.
--- @param tooltip table GameTooltip-like frame
--- @return number|nil ItemQuality index (1..6)
function Insight.DetectUpgradeTrackQuality(tooltip)
    local result
    pcall(function()
        Insight.ForTooltipLines(tooltip, function(_, left)
            if result or not left then return end
            -- SafeGetFontText coerces a possibly-secret return value to a
            -- plain Lua string; :match on a raw secret string would error
            -- and leave result = nil silently.
            local txt = Insight.SafeGetFontText(left)
            if txt == "" then return end
            local track = txt:match(UPGRADE_LINE_PATTERN)
            if track then
                result = UPGRADE_TRACK_QUALITY[track]
            end
        end)
    end)
    return result
end

local function BuildGradientString(plain, quality)
    local colors = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if not colors then return plain end
    return Insight.BuildNameGradient(plain, colors.r, colors.g, colors.b)
end

-- Reentrancy guard: our own SetText / SetTextColor calls trigger the same
-- hooks we install below; without the guard the wrap logic would recurse.
local gradientReentry = {}

-- Core writer shared by the sync entry point and the persistent hook.
-- Reads the current (or incoming) text, strips Blizzard escapes, rebuilds
-- as a gradient of tooltip._insightItemQuality, and forces vertex-white so
-- Blizzard's SetTextColor can't flatten the per-char escapes.
local function WriteGradient(tooltip, fs, incomingText)
    if gradientReentry[fs] then return end
    local quality = tooltip._insightItemQuality
    if not quality or quality < 0 then return end
    if not Insight.IsInsightEnabled() then return end
    if not addon.GetDB("insightItemNameGradient", false) then return end

    gradientReentry[fs] = true
    pcall(function()
        local raw = (type(incomingText) == "string" and incomingText ~= "")
            and incomingText or fs:GetText()
        if type(raw) ~= "string" or raw == "" then return end
        local plain = Insight.StripColourEscapes(raw)
        if plain == "" then return end
        local gradient = BuildGradientString(plain, quality)
        if gradient == raw then return end
        fs:SetText(gradient)
        fs:SetTextColor(1, 1, 1, 1)
    end)
    gradientReentry[fs] = nil
end

--- Apply the gradient to the tooltip's name line immediately. Callers must
--- have stashed the effective quality on tooltip._insightItemQuality first
--- (OnItemTooltip does this, RenderItemPreviewContent does it too). The
--- persistent hook keeps the gradient alive across later Blizzard writes.
--- @param tooltip table GameTooltip-like frame with <name>TextLeft1 FontString
function Insight.ApplyItemNameGradient(tooltip)
    local name = tooltip:GetName()
    if not name then return end
    local fs = _G[name .. "TextLeft1"]
    if not fs then return end
    WriteGradient(tooltip, fs, nil)
end

--- Install the SetText / SetFormattedText / SetTextColor hooks on the
--- tooltip's first-line FontString so any later Blizzard write (mid-display
--- refresh, layout pass, comparison reposition) gets re-wrapped with our
--- gradient in the same frame. Idempotent per-tooltip.
--- @param tooltip table GameTooltip-like frame
function Insight.InstallItemNameGradientHook(tooltip)
    if tooltip._insightGradientTextHooked then return end
    tooltip._insightGradientTextHooked = true
    local fs = _G[tooltip:GetName() .. "TextLeft1"]
    if not fs then return end

    hooksecurefunc(fs, "SetText", function(self, text)
        WriteGradient(tooltip, self, text)
    end)
    hooksecurefunc(fs, "SetFormattedText", function(self)
        WriteGradient(tooltip, self, nil)
    end)
    -- Blizzard sets the name-line quality tint via SetTextColor; that vertex
    -- colour multiplies with our per-character escapes and flattens the
    -- gradient. Snap it back to white whenever the tooltip is in item mode.
    hooksecurefunc(fs, "SetTextColor", function(self, r, g, b)
        if not tooltip._insightItemQuality then return end
        if r == 1 and g == 1 and b == 1 then return end
        if gradientReentry[self] then return end
        gradientReentry[self] = true
        pcall(self.SetTextColor, self, 1, 1, 1, 1)
        gradientReentry[self] = nil
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
    tooltip._insightItemQuality = quality
    Insight.ApplyItemNameGradient(tooltip)
    if itemLevel then
        tooltip:AddLine("Item Level " .. tostring(itemLevel), 1, 1, 1)
    end
    if ShowTransmog() and C_TransmogCollection and IsTransmoggableItem(itemID) then
        Insight.AddSectionSeparator(tooltip, qr, qg, qb)
        Insight.AddAppearanceBlock(tooltip, itemID)
    end
end

addon.Insight = Insight
