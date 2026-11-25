--[[
    Horizon Suite - Horizon Insight (Minimap Tooltip)
    Optional blank lines between the sections of the minimap mouseover tooltip.

    The game builds this tooltip every frame from whatever sits under the
    cursor (Minimap_OnUpdate -> GameTooltip:SetMinimapMouseover), and hands it
    over as one stack: a gathering node, then a quest title and its objectives,
    then a hint. Nothing marks where one object ends and the next begins, so
    the sections are found from the text itself: an objective line starts with
    a dash, and a quest title is the line just above its first objective.

    A blank line goes:
      - before a quest title, unless it is the first line;
      - before the first ordinary line after a quest's objectives.
    Stacked nodes with no objectives between them stay together.

    The logic half (colour-code handling, objective detection, gap planning) is
    pure and runs outside the game: tools/test_minimap_tooltip_logic.js.
]]

local addon = _G.HorizonSuite

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- ============================================================================
-- PURE LOGIC
-- ============================================================================

--- Colour codes as they open: |cAARRGGBB or the named form |cnNAME:.
local function MatchColourCodeAt(text, position)
    return text:match("^|c%x%x%x%x%x%x%x%x", position) or text:match("^|cn[^:|]+:", position)
end

--- Text without colour codes, trimmed: what a player reads on the line.
--- @param text string
--- @return string
function Insight.StripTooltipColourCodes(text)
    if type(text) ~= "string" then return "" end
    local plain = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:|]+:", ""):gsub("|r", "")
    return (plain:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Split a multi-line string into one string per line, carrying an unclosed
--- colour code onto the lines after it so each line keeps its colour once it
--- stands alone in its own FontString.
--- @param text string
--- @return table lines
function Insight.SplitColouredTooltipText(text)
    local lines = {}
    if type(text) ~= "string" then return lines end
    local carry = ""
    for raw in (text .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = carry .. raw
        local position = 1
        while true do
            local start = raw:find("|[cr]", position)
            if not start then break end
            if raw:sub(start + 1, start + 1) == "r" then
                carry = ""
                position = start + 2
            else
                local code = MatchColourCodeAt(raw, start)
                if code then
                    carry = code
                    position = start + #code
                else
                    position = start + 2
                end
            end
        end
    end
    return lines
end

--- A quest objective line: "- 2/10 Gray Bear Tongue", or a bullet.
--- @param text string raw or plain line text
--- @return boolean
function Insight.IsMinimapObjectiveLine(text)
    local plain = Insight.StripTooltipColourCodes(text)
    if plain:sub(1, 1) == "-" then return true end
    if plain:sub(1, 3) == "\226\128\162" then return true end -- U+2022 bullet
    return false
end

--- Which lines get a blank line before them.
--- @param texts table ordered line texts
--- @return table gaps set of indexes: gaps[i] == true means a blank line goes before line i
--- @return number count number of gaps
function Insight.FindMinimapSectionGaps(texts)
    local gaps, count = {}, 0
    local isObjective = {}
    for i = 1, #texts do
        isObjective[i] = Insight.IsMinimapObjectiveLine(texts[i])
    end
    for i = 2, #texts do
        if not isObjective[i] then
            local startsQuest  = isObjective[i + 1] == true
            local followsQuest = isObjective[i - 1] == true
            if startsQuest or followsQuest then
                gaps[i] = true
                count = count + 1
            end
        end
    end
    return gaps, count
end

-- ============================================================================
-- TOOLTIP
-- ============================================================================

local function IsMinimapSectionSpacingEnabled()
    return Insight.IsInsightEnabled and Insight.IsInsightEnabled()
        and addon.GetDB("insightMinimapSectionSpacing", false)
end

local function ReadTextColour(fontString)
    local r, g, b = 1, 1, 1
    pcall(function()
        local cr, cg, cb = fontString:GetTextColor()
        r = tonumber(tostring(cr)) or 1
        g = tonumber(tostring(cg)) or 1
        b = tonumber(tostring(cb)) or 1
    end)
    return r, g, b
end

local function CanFontStringWrap(fontString)
    local wraps = false
    pcall(function() if fontString:CanWordWrap() then wraps = true end end)
    return wraps
end

-- Read every visible line into plain entries, one per text line. Returns nil
-- when a line can't be read safely (secret text): the tooltip is then left as
-- the game built it rather than rebuilt with a hole in it.
local function ReadTooltipEntries(tooltip)
    local name = tooltip:GetName()
    if not name then return nil end
    local entries = {}
    for i = 1, tooltip:NumLines() do
        local left  = _G[name .. "TextLeft" .. i]
        local right = _G[name .. "TextRight" .. i]
        local text = Insight.SafeGetFontText(left)
        if text == "" then
            -- Empty after a safe read: either truly empty, or secret. Only the
            -- second aborts; the check itself must stay inside the pcall.
            local isUnreadable = true
            pcall(function()
                local raw = left:GetText()
                if raw == nil or raw == "" then isUnreadable = false end
            end)
            if isUnreadable then return nil end
        end
        local r, g, b = ReadTextColour(left)
        local rightText = right and Insight.SafeGetFontText(right) or ""
        local pieces = Insight.SplitColouredTooltipText(text)
        if #pieces > 1 then
            for _, piece in ipairs(pieces) do
                entries[#entries + 1] = { text = piece, r = r, g = g, b = b }
            end
            if rightText ~= "" then
                local last = entries[#entries]
                last.rightText = rightText
                last.rr, last.rg, last.rb = ReadTextColour(right)
            end
        else
            local entry = { text = text, r = r, g = g, b = b, wrap = CanFontStringWrap(left) }
            if rightText ~= "" then
                entry.rightText = rightText
                entry.rr, entry.rg, entry.rb = ReadTextColour(right)
            end
            entries[#entries + 1] = entry
        end
    end
    return entries
end

local isRebuilding = false

local function SpaceMinimapTooltipSections(tooltip)
    if isRebuilding or not tooltip or not tooltip.NumLines then return end
    if not IsMinimapSectionSpacingEnabled() then return end
    if tooltip:NumLines() < 1 then return end

    local entries = ReadTooltipEntries(tooltip)
    if not entries or #entries < 2 then return end

    local texts = {}
    for i, entry in ipairs(entries) do texts[i] = entry.text end
    local gaps, gapCount = Insight.FindMinimapSectionGaps(texts)
    if gapCount == 0 then return end

    isRebuilding = true
    pcall(function()
        tooltip:ClearLines()
        for i, entry in ipairs(entries) do
            if gaps[i] then tooltip:AddLine(" ", 1, 1, 1) end
            if entry.rightText then
                tooltip:AddDoubleLine(entry.text, entry.rightText, entry.r, entry.g, entry.b, entry.rr, entry.rg, entry.rb)
            else
                tooltip:AddLine(entry.text, entry.r, entry.g, entry.b, entry.wrap)
            end
        end
        tooltip:Show()
    end)
    isRebuilding = false
end

--- Hook the minimap mouseover tooltip. Called once from Insight.Init.
function Insight.HookMinimapTooltipSpacing()
    if Insight._minimapSpacingHooked then return end
    if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.MinimapMouseover then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.MinimapMouseover, SpaceMinimapTooltipSections)
        Insight._minimapSpacingHooked = true
    elseif GameTooltip and GameTooltip.SetMinimapMouseover then
        hooksecurefunc(GameTooltip, "SetMinimapMouseover", SpaceMinimapTooltipSections)
        Insight._minimapSpacingHooked = true
    end
end
