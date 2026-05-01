--[[
    Horizon Suite - Focus - Colors
    Color matrix: defaults + per-category overrides for title/objective/zone/section.
]]

local addon = _G.HorizonSuite

local function EnsureColorMatrix()
    if not addon.GetDB then return end
    local existing = addon.GetDB("colorMatrix", nil)
    if existing and type(existing) == "table" then return end

    local cm = { categories = {}, overrides = {} }

    local qc = addon.GetDB("questColors", nil)
    if qc and type(qc) == "table" then
        for k, v in pairs(qc) do
            if type(v) == "table" and v[1] and v[2] and v[3] then
                if not cm.categories[k] then cm.categories[k] = {} end
                cm.categories[k].title = { v[1], v[2], v[3] }
            end
        end
    end

    local sc = addon.GetDB("sectionColors", nil)
    if sc and type(sc) == "table" then
        for k, v in pairs(sc) do
            if type(v) == "table" and v[1] and v[2] and v[3] then
                if not cm.categories[k] then cm.categories[k] = {} end
                cm.categories[k].section = { v[1], v[2], v[3] }
            end
        end
    end

    -- Seed CURRENT, CURRENT_EVENT, and NEARBY title to match section when not already set
    for _, key in ipairs({ "CURRENT", "CURRENT_EVENT", "NEARBY" }) do
        local sec = addon.SECTION_COLORS and addon.SECTION_COLORS[key]
        if sec and type(sec) == "table" and sec[1] and sec[2] and sec[3] then
            if not cm.categories[key] then cm.categories[key] = {} end
            if not cm.categories[key].title then
                cm.categories[key].title = { sec[1], sec[2], sec[3] }
            end
        end
    end

    addon.SetDB("colorMatrix", cm)
end

local function GetColorMatrix()
    if not addon.GetDB then return nil end
    EnsureColorMatrix()
    return addon.GetDB("colorMatrix", nil)
end

-- When override toggles are on, Completed and Current Zone sections use their row colours for all elements.
-- When off, COMPLETE/NEARBY use baseCategory (the underlying quest type) for colours.
-- isEventQuest: when true and groupKey is NEARBY, use AVAILABLE colour so event quests keep it when accepted.
local function GetEffectiveColorCategory(category, groupKey, baseCategory, isEventQuest)
    if not category then return groupKey or "DEFAULT" end
    local cm = GetColorMatrix()
    local ov = cm and cm.overrides and type(cm.overrides) == "table" and cm.overrides or {}
    if groupKey == "COMPLETE" and (ov.useCompletedOverride == nil or ov.useCompletedOverride) then
        return "COMPLETE"  -- Default true when not explicitly set to false
    end
    if groupKey == "COMPLETE" and baseCategory then
        return baseCategory  -- Use underlying category when override is off
    end
    -- NEARBY: event quests (moved from Events in Zone when accepted) keep the same colour.
    if groupKey == "NEARBY" and isEventQuest then
        return "AVAILABLE"
    end
    if groupKey == "NEARBY" and ov.useCurrentZoneOverride then
        return "NEARBY"
    end
    if groupKey == "CURRENT" and (ov.useCurrentQuestOverride == nil or ov.useCurrentQuestOverride) then
        return "CURRENT"
    end
    if groupKey == "CURRENT" and baseCategory then
        return baseCategory  -- Use underlying category when override is off
    end
    -- AVAILABLE (Events in Zone): all entries use the same colour.
    if groupKey == "AVAILABLE" then
        return "AVAILABLE"
    end
    -- CURRENT_EVENT: accepted event quests use the same colour as Events in Zone.
    if groupKey == "CURRENT_EVENT" then
        return "CURRENT_EVENT"
    end
    return category
end

-- Matrix rows use group keys (e.g. RARES); quest category can be RARE. Use same row for RARE.
local function MatrixKey(category)
    if category == "RARE" then return "RARES" end
    if category == "RARE_LOOT" then return "RARE_LOOT" end
    if category == "ACHIEVEMENT" then return "ACHIEVEMENTS" end
    if category == "ENDEAVOR" then return "ENDEAVORS" end
    if category == "DECOR" then return "DECOR" end
    if category == "APPEARANCE" then return "APPEARANCES" end
    if category == "RECIPE" then return "RECIPES" end
    return category
end

local function SanitizeColor(c, default)
    if c and type(c) == "table" and type(c[1]) == "number" and type(c[2]) == "number" and type(c[3]) == "number" then
        return c
    end
    return default or addon.QUEST_COLORS.DEFAULT
end

local function GetTitleColor(category)
    if not category then
        return addon.QUEST_COLORS.DEFAULT
    end

    local cm = GetColorMatrix()
    local key = MatrixKey(category)
    if cm and cm.categories and cm.categories[key] and cm.categories[key].title then
        return SanitizeColor(cm.categories[key].title, addon.QUEST_COLORS[category] or addon.QUEST_COLORS.DEFAULT)
    end

    -- Legacy per-category questColors support (for safety if migration didn't run yet).
    local db = addon.GetDB and addon.GetDB("questColors", nil)
    if db then
        if db[category] then return SanitizeColor(db[category], addon.QUEST_COLORS[category] or addon.QUEST_COLORS.DEFAULT) end
        if category == "CALLING" and db.WORLD then return SanitizeColor(db.WORLD, addon.QUEST_COLORS.WORLD or addon.QUEST_COLORS.DEFAULT) end
    end

    return addon.QUEST_COLORS[category] or addon.QUEST_COLORS.DEFAULT
end

local function GetObjectiveColor(category)
    local cm = GetColorMatrix()
    local key = category and MatrixKey(category) or nil
    if cm and cm.categories and key and cm.categories[key] and cm.categories[key].objective then
        return SanitizeColor(cm.categories[key].objective, addon.QUEST_COLORS[category] or addon.QUEST_COLORS.DEFAULT)
    end
    return addon.QUEST_COLORS[category] or addon.QUEST_COLORS.DEFAULT
end

local function GetZoneColor(category)
    local cm = GetColorMatrix()
    local key = category and MatrixKey(category) or nil
    if cm and cm.categories and key and cm.categories[key] and cm.categories[key].zone then
        return SanitizeColor(cm.categories[key].zone, addon.ZONE_COLOR)
    end
    return addon.ZONE_COLOR
end

--- Color for scenario stage line (e.g. "Stage 1: Where is the Echoless Flame?").
--- Reads from color matrix SCENARIO.zone (labeled "Stage" in options); defaults to ZONE_COLOR.
--- @return table {r,g,b}
local function GetScenarioStageColor()
    local cm = GetColorMatrix()
    if cm and cm.categories and cm.categories.SCENARIO and cm.categories.SCENARIO.zone then
        return SanitizeColor(cm.categories.SCENARIO.zone, addon.ZONE_COLOR)
    end
    return (addon.QUEST_COLORS and addon.QUEST_COLORS.SCENARIO_STAGE) or (addon.SECTION_COLORS and addon.SECTION_COLORS.SCENARIO_STAGE) or addon.ZONE_COLOR
end

local function GetQuestColor(category)
    -- Backwards-compatible wrapper for title color.
    return GetTitleColor(category)
end

local function GetSectionColor(groupKey)
    local cm = GetColorMatrix()
    if cm and cm.categories and groupKey and cm.categories[groupKey] and cm.categories[groupKey].section then
        return SanitizeColor(cm.categories[groupKey].section, addon.SECTION_COLORS[groupKey] or addon.SECTION_COLORS.DEFAULT)
    end
    return addon.SECTION_COLORS[groupKey] or addon.SECTION_COLORS.DEFAULT
end

--- Colour for section/category row headers (CURRENT, NEARBY, …): per-group section colour, or player class when Focus class colour is on.
--- Applies dim via ShouldDimSectionHeaderForSuperTrack (quest sections only; achievements/rares/etc. headers stay full strength).
--- @param groupKey string
--- @param focusedGroupKey string|nil Group key that contains the super-tracked quest, if any; nil means dim quest-section headers
--- @return table {r,g,b}
local function GetSectionHeaderDisplayColor(groupKey, focusedGroupKey)
    local color = GetSectionColor(groupKey)
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if cc then
        color = { cc[1], cc[2], cc[3] }
    end
    if not color or type(color) ~= "table" or not color[1] or not color[2] or not color[3] then
        color = addon.SECTION_COLORS.DEFAULT
    end
    if addon.ShouldDimSectionHeaderForSuperTrack(groupKey, focusedGroupKey) then
        color = addon.ApplyDimColor(color)
    end
    return color
end

--- Returns the color for completed objectives when the override is on; nil when off (caller uses same as incomplete).
--- @param category string Optional category (unused when override is on)
--- @return table|nil {r,g,b} or nil
local function GetCompletedObjectiveColor(category)
    if not (addon.GetDB and addon.GetDB("useCompletedObjectiveColor", true)) then
        return nil
    end
    local c = addon.GetDB and addon.GetDB("completedObjectiveColor", nil)
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        return c
    end
    return addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }
end

addon.GetEffectiveColorCategory   = GetEffectiveColorCategory
addon.GetCompletedObjectiveColor = GetCompletedObjectiveColor
addon.GetTitleColor        = GetTitleColor
addon.GetObjectiveColor    = GetObjectiveColor
addon.GetZoneColor         = GetZoneColor
addon.GetScenarioStageColor = GetScenarioStageColor
addon.GetQuestColor        = GetQuestColor
addon.GetSectionColor              = GetSectionColor
addon.GetSectionHeaderDisplayColor = GetSectionHeaderDisplayColor
