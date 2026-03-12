--[[
    Horizon Suite - Horizon Insight (Item Tooltip)
    Item-specific tooltip enrichment: transmog state.
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

--- Process item tooltip: add transmog collected/not collected line.
--- @param tooltip table GameTooltip or other tooltip frame
--- @param itemID number Item ID
--- @return boolean true if transmog line was added
function Insight.ProcessItemTooltip(tooltip, itemID)
    if not IsEnabled() then return false end
    if not ShowTransmog() then return false end
    if not C_TransmogCollection then return false end
    if not itemID then return false end

    local hasTransmog = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
    if hasTransmog == nil then return false end

    if hasTransmog then
        tooltip:AddLine("Appearance: Collected", Insight.TRANSMOG_HAVE[1], Insight.TRANSMOG_HAVE[2], Insight.TRANSMOG_HAVE[3])
    else
        tooltip:AddLine("Appearance: Not collected", Insight.TRANSMOG_MISS[1], Insight.TRANSMOG_MISS[2], Insight.TRANSMOG_MISS[3])
    end
    return true
end

addon.Insight = Insight
