--[[
    Horizon Suite - Horizon Insight (NPC Tooltip)
    NPC-specific tooltip enrichment: reaction color, level/classification/creature type.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local function ShowReactionBorder() return addon.GetDB("insightNpcReactionBorder", true) end
local function ShowReactionName()   return addon.GetDB("insightNpcReactionName",   true) end
local function ShowLevelLine()      return addon.GetDB("insightNpcShowLevelLine",  true) end
local function ShowNpcIcons()       return addon.GetDB("insightNpcShowIcons",      true) end

--- Process NPC (non-player) unit tooltip. Reaction-coloured name, border, level/classification/creature type.
--- @param unit string Unit token (e.g. "mouseover")
--- @param tooltip table GameTooltip
--- @return boolean true if processed (caller should finalize)
function Insight.ProcessNpcTooltip(unit, tooltip)
    if not Insight.IsInsightEnabled() or not tooltip then return false end
    local isUnitPlayer = false
    pcall(function()
        if UnitIsPlayer(unit) then
            isUnitPlayer = true
        else
            isUnitPlayer = false
        end
    end)
    if isUnitPlayer then return false end

    local reaction = UnitReaction(unit, "player")
    local c = (reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]) and FACTION_BAR_COLORS[reaction] or nil
    if c and ShowReactionBorder() then
        tooltip:SetBackdropBorderColor(c.r, c.g, c.b, 0.60)
    else
        tooltip:SetBackdropBorderColor(Insight.PANEL_BORDER[1], Insight.PANEL_BORDER[2], Insight.PANEL_BORDER[3], Insight.PANEL_BORDER[4])
    end

    local ttName = tooltip:GetName()
    local nameLeft = ttName and _G[ttName .. "TextLeft1"]
    if nameLeft and c and ShowReactionName() then
        nameLeft:SetTextColor(c.r, c.g, c.b)
    end

    if ShowLevelLine() then
        local level = UnitLevel(unit)
        local levelStr = (level and level >= 0) and tostring(level) or (ShowNpcIcons() and "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t" or "??")
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
            local lineLeft = ttName and _G[ttName .. "TextLeft2"]
            local gray = 0.75
            if lineLeft then
                lineLeft:SetText(lineText)
                lineLeft:SetTextColor(gray, gray, gray)
            else
                tooltip:AddLine(lineText, gray, gray, gray)
            end
        end
    end

    return true
end

--- Render sample NPC tooltip lines for the options dashboard preview.
--- @param tooltip table Mock tooltip with AddLine (Insight dashboard pullout)
--- @return nil
function Insight.RenderNpcPreviewContent(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    local hostile = FACTION_BAR_COLORS and FACTION_BAR_COLORS[2]
    local r, g, b = 0.9, 0.35, 0.35
    if hostile then
        r, g, b = hostile.r, hostile.g, hostile.b
    end
    tooltip:AddLine("Darkheart Villager", r, g, b)
    tooltip:AddLine("Level 45 Elite Humanoid", 0.75, 0.75, 0.75)
end

addon.Insight = Insight
