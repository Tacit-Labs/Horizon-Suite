--[[
    Horizon Suite - Horizon Insight (NPC Tooltip)
    NPC-specific tooltip enrichment: reaction color, level/classification/creature type.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local function IsEnabled()
    return addon:IsModuleEnabled("insight")
end

--- Process NPC (non-player) unit tooltip. Reaction-coloured name, border, level/classification/creature type.
--- @param unit string Unit token (e.g. "mouseover")
--- @param tooltip table GameTooltip
--- @return boolean true if processed (caller should finalize)
function Insight.ProcessNpcTooltip(unit, tooltip)
    if not IsEnabled() or not tooltip or not tooltip:IsShown() then return false end
    if UnitIsPlayer(unit) then return false end

    local reaction = UnitReaction(unit, "player")
    local c = (reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]) and FACTION_BAR_COLORS[reaction] or nil
    if c then
        tooltip:SetBackdropBorderColor(c.r, c.g, c.b, 0.60)
    else
        tooltip:SetBackdropBorderColor(Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
    end
    if Insight.accentBar then Insight.accentBar:Hide() end

    local nameLeft = _G["GameTooltipTextLeft1"]
    if nameLeft and c then
        nameLeft:SetTextColor(c.r, c.g, c.b)
    end

    local level = UnitLevel(unit)
    local levelStr = (level and level >= 0) and tostring(level) or "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t"
    local classification = UnitClassification(unit)
    local classStr = (classification == "elite" and "Elite") or (classification == "rare" and "Rare") or (classification == "rareelite" and "Rare Elite") or (classification == "worldboss" and "World Boss") or (classification == "trivial" and "Trivial") or nil
    local creatureType = UnitCreatureType(unit)
    local parts = {}
    parts[#parts + 1] = "Level " .. levelStr
    if classStr then parts[#parts + 1] = classStr end
    pcall(function()
        if creatureType and creatureType ~= "" then
            parts[#parts + 1] = creatureType
        end
    end)
    local lineText = #parts > 0 and table.concat(parts, " ") or nil
    if lineText then
        local lineLeft = _G["GameTooltipTextLeft2"]
        local gray = 0.75
        if lineLeft then
            lineLeft:SetText(lineText)
            lineLeft:SetTextColor(gray, gray, gray)
        else
            tooltip:AddLine(lineText, gray, gray, gray)
        end
    end

    return true
end

addon.Insight = Insight
