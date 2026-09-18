--[[
    Horizon Suite - Flow - Quest templates

    Rewrites QuestInfo template element arrays so that:
      - objectives render above the flavour text,
      - the objectives block is drawn by Flow's band element,
      - the flavour text is drawn by Flow's lore element.

    Substituting elements rather than repainting the finished frame is what
    keeps Blizzard's layout correct: QuestInfo_Display anchors each element
    below the frame the previous element returned, so a frame swapped in here
    is measured and positioned by Blizzard exactly like its own.

    Only the three quest-giver templates are touched. The world map's details
    pane renders from QUEST_TEMPLATE_MAP_DETAILS and QuestLogPopupDetailFrame
    from QUEST_TEMPLATE_LOG, so both keep stock Blizzard ordering and stock
    Blizzard appearance while Flow is enabled.

    Blizzard: QUEST_TEMPLATE_* tables and the QuestInfo_Show* element functions.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow

local TEMPLATE_NAMES = {
    "QUEST_TEMPLATE_DETAIL",
    "QUEST_TEMPLATE_PROGRESS",
    "QUEST_TEMPLATE_REWARD",
}

-- Content column Flow lays out in, and the frame width that hosts it. Blizzard's
-- own contentWidth is around 285, which is what makes the stock window a tall
-- letterbox; widening it is half of squaring the frame up.
F.CONTENT_PAD   = 20
F.CONTENT_WIDTH = 380
F.FRAME_WIDTH   = F.CONTENT_WIDTH + (F.CONTENT_PAD * 2)

-- [templateName] = { elements = <Blizzard's array>, contentWidth = <number|nil> }
-- The elements array is kept by reference so restore is exact rather than a
-- reconstruction.
local originals = {}

--- Blizzard's own element function for a slot Flow substitutes.
--- Flow only ever replaces entries inside a template's array, never the global
--- itself, so the original is always still reachable under its own name.
--- @param slot string "description" or "title"
--- @return function|nil
function F.GetOriginalElement(slot)
    if slot == "description" then return _G.QuestInfo_ShowDescriptionText end
    if slot == "title" then return _G.QuestInfo_ShowTitle end
    return nil
end

--- Width of the column Flow's elements should fill.
--- @return number
function F.GetContentWidth()
    return F.CONTENT_WIDTH
end

--- Distance in array slots between consecutive element entries.
--- Blizzard has shipped different tuple widths (func plus one or two offsets),
--- so the stride is read from the data rather than hardcoded. A change to the
--- shape then degrades to "no rewrite" instead of a corrupted array.
--- @param elements table Flat element array
--- @return number stride
local function DetectStride(elements)
    for i = 2, #elements do
        if type(elements[i]) == "function" then return i - 1 end
    end
    return 2
end

--- Split a flat element array into per-element groups.
--- @param elements table
--- @param stride number
--- @return table groups Array of arrays, each `stride` long
local function GroupsOf(elements, stride)
    local groups = {}
    for i = 1, #elements, stride do
        local group = {}
        for j = 0, stride - 1 do group[j + 1] = elements[i + j] end
        groups[#groups + 1] = group
    end
    return groups
end

--- Flatten groups back into an element array.
--- @param groups table
--- @param stride number
--- @return table elements
local function Flatten(groups, stride)
    local out = {}
    for i = 1, #groups do
        local group = groups[i]
        for j = 1, stride do out[#out + 1] = group[j] end
    end
    return out
end

--- Build Flow's replacement element array for one template.
--- @param elements table Blizzard's element array
--- @return table|nil rewritten Nil when nothing recognisable was found
local function Rewrite(elements)
    if type(elements) ~= "table" or #elements == 0 then return nil end

    local stride = DetectStride(elements)
    if stride < 1 or #elements % stride ~= 0 then return nil end

    local groups = GroupsOf(elements, stride)

    local descIndex, objTextIndex, objHeaderIndex, titleIndex
    for i = 1, #groups do
        local head = groups[i][1]
        if head ~= nil then
            if head == _G.QuestInfo_ShowDescriptionText then
                descIndex = descIndex or i
            elseif head == _G.QuestInfo_ShowObjectivesText then
                objTextIndex = objTextIndex or i
            elseif head == _G.QuestInfo_ShowObjectivesHeader then
                objHeaderIndex = objHeaderIndex or i
            elseif head == _G.QuestInfo_ShowTitle then
                titleIndex = titleIndex or i
            end
        end
    end

    -- Nothing Flow understands in this template: leave Blizzard's array alone.
    if not descIndex and not objTextIndex and not titleIndex then return nil end

    -- Flow's band draws its own heading, so Blizzard's is dropped rather than
    -- stubbed: QuestInfo_Display skips an element whose function returns nil,
    -- but dropping it avoids the call entirely.
    local drop = {}
    if objHeaderIndex then drop[objHeaderIndex] = true end

    if objTextIndex then groups[objTextIndex][1] = F.ShowObjectivesBand end
    if descIndex then groups[descIndex][1] = F.ShowLore end
    if titleIndex then groups[titleIndex][1] = F.ShowTitle end

    -- Move the objectives group above the description when it is not already.
    local moveGroup
    if objTextIndex and descIndex and objTextIndex > descIndex then
        moveGroup = groups[objTextIndex]
        drop[objTextIndex] = true
    end

    local out = {}
    for i = 1, #groups do
        if moveGroup and i == descIndex then
            out[#out + 1] = moveGroup
        end
        if not drop[i] then out[#out + 1] = groups[i] end
    end

    return Flatten(out, stride)
end

--- Swap in Flow's element arrays, remembering Blizzard's originals.
--- Idempotent: a template already rewritten is skipped.
--- @return nil
function F.InstallTemplates()
    for i = 1, #TEMPLATE_NAMES do
        local name = TEMPLATE_NAMES[i]
        local template = _G[name]
        if originals[name] == nil
            and type(template) == "table"
            and type(template.elements) == "table"
        then
            local ok, rewritten = pcall(Rewrite, template.elements)
            if ok and rewritten then
                originals[name] = {
                    elements     = template.elements,
                    contentWidth = template.contentWidth,
                }
                template.elements = rewritten
                if template.contentWidth then
                    template.contentWidth = F.CONTENT_WIDTH
                end
            end
        end
    end
end

--- Put Blizzard's original element arrays and content width back.
--- @return nil
function F.RestoreTemplates()
    for name, saved in pairs(originals) do
        local template = _G[name]
        if type(template) == "table" then
            template.elements = saved.elements
            if saved.contentWidth then
                template.contentWidth = saved.contentWidth
            end
        end
    end
    wipe(originals)
end

--- Whether Flow currently has any template swapped in. Used by /h flow.
--- @return boolean
function F.TemplatesInstalled()
    return next(originals) ~= nil
end
