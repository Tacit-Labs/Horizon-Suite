--[[
    Horizon Suite - Horizon Insight (Item Tooltip)
    Item-specific tooltip enrichment: transmog state.
    Structured as append-only block builders (AddAppearanceBlock, etc.).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local function IsEnabled()
    return addon:IsModuleEnabled("insight")
end

local function ShowTransmog()
    return addon.GetDB("insightShowTransmog", true)
end

local TRANSMOG_COLLECTED_TEXT = "Appearance: Collected"
local TRANSMOG_MISSING_TEXT   = "Appearance: Not collected"

local function IsTransmoggableItem(itemID)
    if not GetItemInfo then return false end
    local _, _, _, _, _, itemType = GetItemInfo(itemID)
    return itemType == "Armor" or itemType == "Weapon"
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
-- ITEM BLOCK BUILDERS
-- ============================================================================

--- Add appearance (transmog) block to tooltip.
--- @param tooltip table GameTooltip or other tooltip frame
--- @param itemID number Item ID
--- @return boolean true if block was added
function Insight.AddAppearanceBlock(tooltip, itemID)
    if not IsEnabled() or not ShowTransmog() then return false end
    if not C_TransmogCollection or not itemID then return false end
    if not IsTransmoggableItem(itemID) then return false end
    if HasTransmogLine(tooltip) then return false end

    local hasTransmog = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
    if hasTransmog == nil then return false end

    if hasTransmog then
        tooltip:AddLine(TRANSMOG_COLLECTED_TEXT, Insight.TRANSMOG_HAVE[1], Insight.TRANSMOG_HAVE[2], Insight.TRANSMOG_HAVE[3])
    else
        tooltip:AddLine(TRANSMOG_MISSING_TEXT, Insight.TRANSMOG_MISS[1], Insight.TRANSMOG_MISS[2], Insight.TRANSMOG_MISS[3])
    end
    return true
end

--- Process item tooltip: add structured Insight blocks (appearance, etc.).
--- Adds a section separator only when at least one block will be shown.
--- @param tooltip table GameTooltip or other tooltip frame
--- @param itemID number Item ID
--- @param quality number|nil Item quality for separator tint
--- @return boolean true if any block was added
function Insight.ProcessItemTooltip(tooltip, itemID, quality)
    if not IsEnabled() or not itemID then return false end

    local hasAppearance = ShowTransmog() and C_TransmogCollection
        and IsTransmoggableItem(itemID)
        and C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID) ~= nil
        and not HasTransmogLine(tooltip)

    if not hasAppearance then return false end

    local sepR, sepG, sepB
    if quality and quality >= 0 and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        sepR, sepG, sepB = c.r, c.g, c.b
    end
    Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
    return Insight.AddAppearanceBlock(tooltip, itemID)
end

addon.Insight = Insight
