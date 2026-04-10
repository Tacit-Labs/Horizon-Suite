--[[
    Horizon Suite - Horizon Insight (NPC Tooltip)
    NPC-specific tooltip enrichment: reaction color, level/classification/creature type;
    preserves Blizzard line 2 (subtitle) when it is not the level row.
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

-- Strip |c…|r for heuristics only (same pattern as StripHealthAndPowerText).
-- pcall: s may be a secret string (Midnight); (s or "") still uses s when truthy, so :gsub can error without this guard.
local function StripTooltipColorCodes(s)
    local ok, out = pcall(function()
        return (s or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    end)
    return (ok and out) or ""
end

-- True if `level` appears as a whole number in `stripped` (not a substring of a larger digit run).
local function strippedContainsIsolatedLevel(stripped, level)
    if not (level and level >= 0) then return false end
    local levelNum = tostring(level)
    local pos = 1
    while pos <= #stripped do
        local i, j = stripped:find(levelNum, pos, true)
        if not i then return false end
        local leftChar = i > 1 and stripped:sub(i - 1, i - 1) or ""
        local rightChar = j < #stripped and stripped:sub(j + 1, j + 1) or ""
        local leftOk = leftChar == "" or not leftChar:match("%d")
        local rightOk = rightChar == "" or not rightChar:match("%d")
        if leftOk and rightOk then return true end
        pos = i + 1
    end
    return false
end

--- True if stripped line-2 text looks like Blizzard's level row (not an NPC subtitle).
--- @param stripped string TextLeft2 without color codes, trimmed
--- @param level number|nil UnitLevel (may be negative for unknown)
--- @param creatureType string|nil
--- @param classStr string|nil Elite / Rare / etc.
--- @param unknownLevel boolean level not known as a number
local function LooksLikeBlizzardNpcLevelLine(stripped, level, creatureType, classStr, unknownLevel)
    stripped = stripped:gsub("^%s+", ""):gsub("%s+$", "")
    if stripped == "" then
        return true
    end
    local hasCreature = creatureType and creatureType ~= "" and stripped:find(creatureType, 1, true)
    local hasClass = classStr and stripped:find(classStr, 1, true)
    local typeHint = hasCreature or hasClass
    if unknownLevel then
        if stripped:find("%?%?", 1, true) and typeHint then
            return true
        end
        if stripped:find("%?%?", 1, true) and (stripped:find("Level", 1, true) or stripped:find("Stufe", 1, true)) then
            return true
        end
        return false
    end
    if not strippedContainsIsolatedLevel(stripped, level) then
        return false
    end
    if typeHint then
        return true
    end
    if stripped:find("Level", 1, true) or stripped:find("Stufe", 1, true) then
        return true
    end
    return false
end

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

    -- Midnight: UnitReaction / UnitLevel / UnitClassification returns must not drive control flow outside pcall.
    local c = nil
    pcall(function()
        local reaction = UnitReaction(unit, "player")
        if reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction] then
            c = FACTION_BAR_COLORS[reaction]
        end
    end)
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

    local levelStr = (ShowNpcIcons() and "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t") or "??"
    local unknownLevel = true
    local levelForHeuristic = nil
    local classStr = nil
    local creatureType = nil
    pcall(function()
        local lev = UnitLevel(unit)
        local classification = UnitClassification(unit)
        classStr = (classification == "elite" and "Elite") or (classification == "rare" and "Rare") or (classification == "rareelite" and "Rare Elite") or (classification == "worldboss" and "World Boss") or (classification == "trivial" and "Trivial") or nil
        creatureType = UnitCreatureType(unit)
        local nonNeg = false
        pcall(function()
            if type(lev) == "number" and lev >= 0 then
                nonNeg = true
            end
        end)
        if nonNeg then
            levelForHeuristic = lev
            unknownLevel = false
            levelStr = tostring(lev)
        else
            levelForHeuristic = nil
            pcall(function()
                if type(lev) == "number" then
                    levelForHeuristic = lev
                end
            end)
            unknownLevel = true
            levelStr = (ShowNpcIcons() and "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14:0:0|t") or "??"
        end
    end)

    if ShowLevelLine() then
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
            local lineLeft2 = ttName and _G[ttName .. "TextLeft2"]
            local captured = Insight.SafeGetFontText(lineLeft2)
            local stripped = StripTooltipColorCodes(captured):gsub("^%s+", ""):gsub("%s+$", "")
            local isBlizzardLevel = false
            pcall(function()
                isBlizzardLevel = LooksLikeBlizzardNpcLevelLine(stripped, levelForHeuristic, creatureType, classStr, unknownLevel)
            end)
            local gray = 0.75
            if stripped == "" or isBlizzardLevel then
                if lineLeft2 then
                    pcall(function()
                        lineLeft2:SetText(lineText)
                        lineLeft2:SetTextColor(gray, gray, gray)
                    end)
                else
                    tooltip:AddLine(lineText, gray, gray, gray)
                end
            else
                -- Line 2 is NPC subtitle; keep Blizzard colouring. Level row on line 3 (replaces Blizzard duplicate if any).
                if lineLeft2 then
                    pcall(function()
                        lineLeft2:SetText(captured)
                    end)
                end
                local lineLeft3 = ttName and _G[ttName .. "TextLeft3"]
                if lineLeft3 then
                    pcall(function()
                        lineLeft3:SetText(lineText)
                        lineLeft3:SetTextColor(gray, gray, gray)
                    end)
                else
                    tooltip:AddLine(lineText, gray, gray, gray)
                end
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
    tooltip:AddLine("General Goods Vendor", 1.0, 0.82, 0.0)
    tooltip:AddLine("Level 45 Elite Humanoid", 0.75, 0.75, 0.75)
end

addon.Insight = Insight
