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
-- ============================================================================

local function QualityGradientColors(quality)
    if not quality or quality < 0 then return nil, nil end
    if not ITEM_QUALITY_COLORS or not ITEM_QUALITY_COLORS[quality] then return nil, nil end
    if not CreateColor then return nil, nil end
    local c = ITEM_QUALITY_COLORS[quality]
    local r, g, b = c.r, c.g, c.b
    local sR, sG, sB = r * 0.70, g * 0.70, b * 0.70
    local eR = math.min(1, r * 1.15 + 0.10)
    local eG = math.min(1, g * 1.15 + 0.10)
    local eB = math.min(1, b * 1.15 + 0.10)
    return CreateColor(sR, sG, sB, 1), CreateColor(eR, eG, eB, 1)
end

local function ResetNameGradient(fs, quality)
    if not fs or not fs._insightGradientApplied then return end
    if fs.SetTextColor and quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        pcall(fs.SetTextColor, fs, c.r, c.g, c.b)
    end
    fs._insightGradientApplied = nil
end

--- Apply a two-stop horizontal gradient to the tooltip's first text line,
--- derived from the item quality colour. No-ops on tooltips without a GetName,
--- on clients without FontString:SetGradient, or when the option is off.
--- @param tooltip table GameTooltip-like frame (must expose GetName and have <name>TextLeft1 FontString)
--- @param quality number|nil Item quality index (0..7)
function Insight.ApplyItemNameGradient(tooltip, quality)
    if not tooltip or not tooltip.GetName then return end
    local name = tooltip:GetName()
    if not name then return end
    local fs = _G[name .. "TextLeft1"]
    if not fs or not fs.SetGradient then return end

    local enabled = Insight.IsInsightEnabled()
        and addon.GetDB("insightItemNameGradient", true)
    if not enabled or not quality or quality < 0 then
        ResetNameGradient(fs, quality)
        return
    end

    local startC, endC = QualityGradientColors(quality)
    if not startC then
        ResetNameGradient(fs, quality)
        return
    end
    fs:SetGradient("HORIZONTAL", startC, endC)
    fs._insightGradientApplied = true
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
