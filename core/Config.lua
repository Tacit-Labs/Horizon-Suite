--[[
    Horizon Suite - Focus - Config
    Constants, colors, fonts, labels, and group order. Loaded after Utilities, before Core.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

-- ============================================================================
-- CONFIGURATION (constants, colors, fonts, labels, group order)
-- ============================================================================

addon.HEADER_SIZE     = 16
addon.TITLE_SIZE      = 13
addon.OBJ_SIZE        = 11

addon.POOL_SIZE       = 25
addon.MAX_OBJECTIVES  = 7

addon.PANEL_WIDTH     = 260
addon.PANEL_X         = -40
addon.PANEL_Y         = -100
addon.PADDING              = 14
addon.CONTENT_RIGHT_PADDING = 1
addon.HEADER_HEIGHT         = 28
addon.MINIMAL_HEADER_HEIGHT = 24  -- Super-minimal mode bar height (chevron + O)
addon.DIVIDER_HEIGHT  = 2
addon.TITLE_SPACING   = 10
addon.OBJ_SPACING     = 2
-- Objective indent is relative to the title's left padding.
-- With a 4px title pad, OBJ_INDENT=8 yields objectives at +12px from entry left.
addon.OBJ_INDENT      = 8
addon.COMPACT_TITLE_SPACING = 4
addon.COMPACT_OBJ_SPACING   = 1
addon.COMPACT_OBJ_INDENT    = 8
-- Delve-specific spacing (slightly more room between entries and objectives).
addon.DELVE_ENTRY_SPACING   = 12
addon.DELVE_OBJ_SPACING     = 4
addon.MIN_HEIGHT      = 50

addon.MAX_CONTENT_HEIGHT = 480
addon.SCROLL_STEP        = 30

addon.ITEM_BTN_SIZE   = 26
addon.ITEM_BTN_OFFSET = 4

addon.QUEST_TYPE_ICON_SIZE = 16
addon.QUEST_TYPE_ICON_GAP  = 4
addon.ICON_COLUMN_WIDTH    = addon.QUEST_TYPE_ICON_SIZE + addon.QUEST_TYPE_ICON_GAP
addon.BAR_LEFT_OFFSET      = 9
addon.TRACKED_OTHER_ZONE_ICON_SIZE = 12
addon.WQ_TIMER_BAR_HEIGHT = 6
addon.SCENARIO_TIMER_BAR_SLOTS = 5
addon.LFG_BTN_SIZE        = 26   -- Join Group button size (right-side column for group quests)
addon.LFG_BTN_GAP         = 4    -- gap between text content and LFG button column
addon.DELVE_TIER_ATLAS = "delves-scenario-flag"  -- Blizzard atlas for Delve tier/flag (TierFrame.Flag)

addon.SHADOW_OX       = 2
addon.SHADOW_OY       = -2
addon.SHADOW_A        = 0.8
addon.DUNGEON_UNTRACKED_DIM = 0.65   -- dim factor for untracked dungeon quests (single source)

-- Single source of truth for Focus fade/transition. All animation code reads from here.
addon.FOCUS_ANIM = {
    dur          = 0.4,
    stagger      = 0.05,
    slideInX     = 20,
    slideOutX    = 20,
    driftOutY    = 10,
    hoverTitleDur = 0.15,
}
addon.COMPLETE_HOLD   = 0.50
addon.HEIGHT_SPEED    = 8
addon.FLASH_DUR       = 0.55

-- Backward-compatible aliases (derived from FOCUS_ANIM).
addon.FOCUS_ANIM_DUR  = addon.FOCUS_ANIM.dur
addon.FADE_IN_DUR     = addon.FOCUS_ANIM.dur
addon.FADE_OUT_DUR    = addon.FOCUS_ANIM.dur
addon.COLLAPSE_DUR    = addon.FOCUS_ANIM.dur
addon.COMBAT_FADE_DUR = addon.FOCUS_ANIM.dur
addon.ENTRY_STAGGER   = addon.FOCUS_ANIM.stagger
addon.SLIDE_IN_X      = addon.FOCUS_ANIM.slideInX
addon.SLIDE_OUT_X     = addon.FOCUS_ANIM.slideOutX
addon.DRIFT_OUT_Y     = addon.FOCUS_ANIM.driftOutY

addon.HEADER_COLOR    = { 1, 1, 1 }
addon.DIVIDER_COLOR   = { 1, 1, 1, 0.5 }
addon.OBJ_COLOR       = { 0.78, 0.78, 0.78 }
addon.OBJ_DONE_COLOR  = { 0.30, 0.80, 0.30 }
-- Timer urgency: green (>25% left), yellow (10–25%), red (<10%)
addon.TIMER_URGENCY_COLORS = {
    plenty = { 0.35, 0.90, 0.45 },  -- green
    low    = { 1.00, 0.85, 0.25 },  -- yellow
    critical = { 1.00, 0.35, 0.35 }, -- red
}
addon.ZONE_SIZE       = 10
addon.ZONE_COLOR      = { 0.55, 0.65, 0.75 }

addon.QUEST_COLORS = {
    DEFAULT   = { 0.90, 0.90, 0.90 },
    CURRENT   = { 0.95, 0.55, 0.45 },  -- coral, matches SECTION_COLORS.CURRENT (Current Quest)
    AVAILABLE     = { 0.25, 0.88, 0.92 },  -- cyan/teal, matches SECTION_COLORS.AVAILABLE (Events in Zone)
    CURRENT_EVENT = { 0.25, 0.88, 0.92 },  -- cyan (continuity with Events in Zone)
    NEARBY    = { 0.35, 0.75, 0.98 },  -- sky blue, matches SECTION_COLORS.NEARBY (Current Zone)
    CAMPAIGN  = { 1.00, 0.82, 0.20 },
    IMPORTANT = { 1.00, 0.45, 0.80 },  -- pink to match importantavailablequesticon
    LEGENDARY = { 1.00, 0.50, 0.00 },
    DUNGEON   = { 0.60, 0.40, 1.00 },  -- purple: party dungeon quests (Normal/Heroic/Mythic/M+)
    RAID      = { 0.85, 0.25, 0.25 },  -- red: raid quests
    DELVES    = { 0.32, 0.72, 0.68 },  -- teal/seafoam: Delve steps (distinct from all other categories)
    SCENARIO  = { 0.38, 0.52, 0.88 },  -- deep blue: event/scenario steps (Twilight's Call etc.)
    WORLD     = { 0.60, 0.20, 1.00 },
    WEEKLY    = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    DAILY     = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    CALLING   = { 0.20, 0.60, 1.00 },
    COMPLETE  = { 0.20, 1.00, 0.40 },
    RARE      = { 1.00, 0.55, 0.25 },
    ACHIEVEMENT = { 0.78, 0.48, 0.22 },  -- bronze, trophy feel
    ENDEAVOR   = { 0.45, 0.95, 0.75 },  -- mint green (housing/endeavor)
    ENDEAVORS  = { 0.45, 0.95, 0.75 },  -- mint green (color matrix group default)
    DECOR      = { 0.65, 0.55, 0.45 },  -- warm brown (housing decor)
    RECIPE     = { 0.55, 0.75, 0.45 },  -- sage green (profession recipes)
    RECIPES    = { 0.55, 0.75, 0.45 },  -- sage green (group default)
    ADVENTURE  = { 0.85, 0.70, 0.30 },  -- warm gold (Adventure Guide / Traveler's Log)
}

-- Presence-only (no Focus category): boss emote alert, discovery line
addon.PRESENCE_BOSS_EMOTE_COLOR = { 1, 0.2, 0.2 }
addon.PRESENCE_DISCOVERY_COLOR  = { 0.4, 1, 0.5 }

addon.SECTION_SIZE      = 10
addon.SECTION_SPACING   = 10
addon.SECTION_COLOR_A   = 1
addon.SECTION_POOL_SIZE = 10

function addon.GetDefaultFontPath()
    local path = GameFontNormal and GameFontNormal:GetFont()
    if path and path ~= "" then return path end
    return "Fonts\\FRIZQT__.TTF"
end

addon.FONT_PATH = addon.GetDefaultFontPath()
addon.HeaderFont  = CreateFont("HorizonSuiteHeaderFont")
addon.HeaderFont:SetFont(addon.FONT_PATH, addon.HEADER_SIZE, "OUTLINE")
addon.TitleFont   = CreateFont("HorizonSuiteTitleFont")
addon.TitleFont:SetFont(addon.FONT_PATH, addon.TITLE_SIZE, "OUTLINE")
addon.ObjFont     = CreateFont("HorizonSuiteObjFont")
addon.ObjFont:SetFont(addon.FONT_PATH, addon.OBJ_SIZE, "OUTLINE")
addon.ZoneFont    = CreateFont("HorizonSuiteZoneFont")
addon.ZoneFont:SetFont(addon.FONT_PATH, addon.ZONE_SIZE, "OUTLINE")
addon.SectionFont = CreateFont("HorizonSuiteSectionFont")
addon.SectionFont:SetFont(addon.FONT_PATH, addon.SECTION_SIZE, "OUTLINE")
addon.ProgressBarFont = CreateFont("HorizonSuiteProgressBarFont")
addon.ProgressBarFont:SetFont(addon.FONT_PATH, addon.OBJ_SIZE, "OUTLINE")

addon.SECTION_LABELS = {
    CURRENT      = "CURRENT QUEST",
    CURRENT_EVENT = "CURRENT EVENT",
    DUNGEON   = "DUNGEON",
    RAID      = "RAID",
    DELVES    = "DELVES",
    SCENARIO  = "SCENARIO EVENTS",
    AVAILABLE = "EVENTS IN ZONE",
    NEARBY    = "CURRENT ZONE",
    CAMPAIGN  = "CAMPAIGN",
    IMPORTANT = "IMPORTANT",
    LEGENDARY = "LEGENDARY",
    WORLD     = "WORLD QUESTS",
    WEEKLY    = "WEEKLY QUESTS",
    DAILY     = "DAILY QUESTS",
    RARES     = "RARE BOSSES",
    ACHIEVEMENTS = "ACHIEVEMENTS",
    ENDEAVORS  = "ENDEAVORS",
    DECOR      = "DECOR",
    RECIPES    = "RECIPES",
    ADVENTURE  = "ADVENTURE GUIDE",
    DEFAULT   = "QUESTS",
    COMPLETE  = "READY TO TURN IN",
}

addon.SECTION_COLORS = {
    CURRENT   = { 0.95, 0.55, 0.45 },  -- coral (recent progress; distinct from NEARBY)
    DUNGEON   = { 0.60, 0.40, 1.00 },
    RAID      = { 0.85, 0.25, 0.25 },  -- red: raid quests
    DELVES    = { 0.32, 0.72, 0.68 },  -- teal: Delve section
    SCENARIO  = { 0.38, 0.52, 0.88 },  -- deep blue: event/scenario steps
    AVAILABLE    = { 0.25, 0.88, 0.92 },  -- cyan/teal (available to pick up)
    CURRENT_EVENT = { 0.25, 0.88, 0.92 },  -- cyan (continuity with Events in Zone)
    NEARBY    = { 0.35, 0.75, 0.98 },  -- sky blue (accepted, in zone)
    CAMPAIGN  = { 1.00, 0.82, 0.20 },
    IMPORTANT = { 1.00, 0.45, 0.80 },  -- pink to match importantavailablequesticon
    LEGENDARY = { 1.00, 0.50, 0.00 },
    WORLD     = { 0.60, 0.20, 1.00 },
    WEEKLY    = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    DAILY     = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    RARES     = { 1.00, 0.55, 0.25 },
    ACHIEVEMENTS = { 0.78, 0.48, 0.22 },  -- bronze
    ENDEAVORS  = { 0.45, 0.95, 0.75 },  -- mint green (housing/endeavor)
    DECOR      = { 0.65, 0.55, 0.45 },  -- warm brown (housing decor)
    RECIPES    = { 0.55, 0.75, 0.45 },  -- sage green (profession recipes)
    ADVENTURE  = { 0.85, 0.70, 0.30 },  -- warm gold (Adventure Guide)
    DEFAULT   = { 0.70, 0.70, 0.70 },
    COMPLETE  = { 0.20, 1.00, 0.40 },
}

addon.GROUP_ORDER = { "CURRENT_EVENT", "CURRENT", "DELVES", "SCENARIO", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "RECIPES", "ADVENTURE", "DUNGEON", "RAID", "NEARBY", "COMPLETE", "WORLD", "WEEKLY", "DAILY", "RARES", "AVAILABLE", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "DEFAULT" }

addon.GROUP_ORDER_PRESETS = {
    ["Collection Focused"] = { "CURRENT_EVENT", "CURRENT", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "RECIPES", "ADVENTURE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "NEARBY", "COMPLETE", "WORLD", "WEEKLY", "DAILY", "RARES", "AVAILABLE", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "DEFAULT" },
    ["Quest Focused"]      = { "CURRENT_EVENT", "CURRENT", "COMPLETE", "NEARBY", "AVAILABLE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "WORLD", "WEEKLY", "DAILY", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "RARES", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "RECIPES", "ADVENTURE", "DEFAULT" },
    ["Campaign Focused"]   = { "CURRENT_EVENT", "CURRENT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "COMPLETE", "NEARBY", "DELVES", "SCENARIO", "DUNGEON", "RAID", "AVAILABLE", "WORLD", "WEEKLY", "DAILY", "RARES", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "RECIPES", "ADVENTURE", "DEFAULT" },
    ["World / Rare Focused"] = { "CURRENT_EVENT", "CURRENT", "WORLD", "WEEKLY", "DAILY", "RARES", "NEARBY", "COMPLETE", "AVAILABLE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "RECIPES", "ADVENTURE", "DEFAULT" },
}

-- Category keys (enum-style) for consistent string usage across modules.
addon.CATEGORY_KEYS = {
    CURRENT = "CURRENT", CURRENT_EVENT = "CURRENT_EVENT", DUNGEON = "DUNGEON", RAID = "RAID", DELVES = "DELVES", SCENARIO = "SCENARIO", AVAILABLE = "AVAILABLE", NEARBY = "NEARBY", CAMPAIGN = "CAMPAIGN",
    IMPORTANT = "IMPORTANT", LEGENDARY = "LEGENDARY", WORLD = "WORLD", WEEKLY = "WEEKLY",
    DAILY = "DAILY", RARES = "RARES", RARE = "RARE",     ACHIEVEMENT = "ACHIEVEMENT", ACHIEVEMENTS = "ACHIEVEMENTS",
    ENDEAVOR = "ENDEAVOR", ENDEAVORS = "ENDEAVORS",
    DECOR = "DECOR",
    RECIPE = "RECIPE", RECIPES = "RECIPES",
    ADVENTURE = "ADVENTURE",
    DEFAULT = "DEFAULT", COMPLETE = "COMPLETE", CALLING = "CALLING",
}

-- Quest type atlas names (Blizzard texture atlases for quest icons).
addon.ATLAS_QUEST_TURNIN = "QuestTurnin"
addon.ATLAS_QUEST_CAMPAIGN = "Quest-Campaign-Available"
addon.ATLAS_QUEST_RECURRING = "quest-recurring-available"
addon.ATLAS_QUEST_IMPORTANT = "importantavailablequesticon"
addon.ATLAS_QUEST_LEGENDARY = "UI-QuestPoiLegendary-QuestBang"
addon.ATLAS_QUEST_PVP = "questlog-questtypeicon-pvp"

addon.CATEGORY_TO_GROUP = {
    COMPLETE  = "COMPLETE",
    DUNGEON   = "DUNGEON",
    RAID      = "RAID",
    DELVES    = "DELVES",
    SCENARIO  = "SCENARIO",
    LEGENDARY = "LEGENDARY",
    IMPORTANT = "IMPORTANT",
    CAMPAIGN  = "CAMPAIGN",
    WORLD     = "WORLD",
    WEEKLY    = "WEEKLY",
    DAILY     = "DAILY",
    CALLING   = "WORLD",
    ACHIEVEMENT = "ACHIEVEMENTS",
    ENDEAVOR   = "ENDEAVORS",
    DECOR      = "DECOR",
    RECIPE     = "RECIPES",
    ADVENTURE  = "ADVENTURE",
    DEFAULT   = "DEFAULT",
}

-- Returns a validated group order array.
function addon.GetGroupOrder()
    -- Stored in DB as an array of group keys.
    local saved = (addon.GetDB and addon.GetDB("groupOrder", nil)) or nil
    if type(saved) ~= "table" or #saved == 0 then
        return addon.GROUP_ORDER
    end

    -- Validate: keep only known keys, preserve saved ordering, then append any missing.
    local known = {}
    for i = 1, #addon.GROUP_ORDER do
        known[addon.GROUP_ORDER[i]] = true
    end

    local out, seen = {}, {}
    for i = 1, #saved do
        local k = saved[i]
        if type(k) == "string" and known[k] and not seen[k] then
            out[#out + 1] = k
            seen[k] = true
        end
    end
    -- Migration: prepend CURRENT_EVENT and CURRENT when missing so existing users get them at top.
    if not seen["CURRENT"] and known["CURRENT"] then
        table.insert(out, 1, "CURRENT")
        seen["CURRENT"] = true
    end
    if not seen["CURRENT_EVENT"] and known["CURRENT_EVENT"] then
        table.insert(out, 1, "CURRENT_EVENT")
        seen["CURRENT_EVENT"] = true
    end
    for i = 1, #addon.GROUP_ORDER do
        local k = addon.GROUP_ORDER[i]
        if not seen[k] then
            out[#out + 1] = k
        end
    end
    return out
end

-- Persists a new group order.
function addon.SetGroupOrder(order)
    if type(order) ~= "table" then return end
    if not addon.SetDB then return end

    -- Store exactly what we were given; GetGroupOrder() will validate/repair.
    addon.SetDB("groupOrder", order)

    if addon.ScheduleRefresh then
        addon.ScheduleRefresh()
    elseif addon.FullLayout and not InCombatLockdown() then
        addon.FullLayout()
    end
end

-- Font list for options: "Game Font" first, then LibSharedMedia fonts if available
local fontListNames, fontListPaths = {}, {}

-- Saved value can be a file path (legacy/Game Font/Custom) or an LSM font key.
-- Returns a usable font file path.
function addon.ResolveFontPath(value)
    if type(value) ~= "string" or value == "" then
        return addon.GetDefaultFontPath()
    end
    -- Heuristic: real paths contain slashes/backslashes.
    if value:find("\\") or value:find("/") then
        return value
    end
    local LSM = (LibStub and LibStub("LibSharedMedia-3.0", true)) or nil
    if LSM and LSM.Fetch then
        local ok, path = pcall(LSM.Fetch, LSM, "font", value, true)
        if ok and type(path) == "string" and path ~= "" then
            return path
        end
    end
    return addon.GetDefaultFontPath()
end

function addon.RefreshFontList()
    wipe(fontListNames)
    wipe(fontListPaths)
    local gamePath = addon.GetDefaultFontPath()
    fontListNames[1] = "Game Font"
    -- value for index 1 stays a concrete path for backwards compat
    fontListPaths[1] = gamePath
    local LSM = (LibStub and LibStub("LibSharedMedia-3.0", true)) or nil
    if not (LSM and LSM.HashTable and LSM.Fetch) then
        return
    end

    -- HashTable is the authoritative list of *registered* media. LSM:List() can be incomplete
    -- depending on load order or internal filtering.
    local hash = LSM:HashTable("font")
    if type(hash) ~= "table" then
        return
    end

    local t = {}
    for name in pairs(hash) do
        if type(name) == "string" and name ~= "" then
            local ok, path = pcall(LSM.Fetch, LSM, "font", name, true)
            if ok and type(path) == "string" and path ~= "" then
                t[#t + 1] = name
            end
        end
    end
    table.sort(t)
    for _, name in ipairs(t) do
        fontListNames[#fontListNames + 1] = name
        -- store the LSM key as the value so the dropdown can persist it
        fontListPaths[#fontListPaths + 1] = name
    end
end

function addon.GetFontList()
    if #fontListNames == 0 then addon.RefreshFontList() end
    local list = {}
    for i = 1, #fontListNames do
        list[i] = { fontListNames[i], fontListPaths[i] }
    end
    return list
end

function addon.GetFontPathForIndex(index)
    if #fontListPaths == 0 then addon.RefreshFontList() end
    if not index or index < 1 or index > #fontListPaths then return addon.GetDefaultFontPath() end
    return fontListPaths[index]
end

function addon.GetFontNameForPath(path)
    if #fontListNames == 0 then addon.RefreshFontList() end
    if type(path) ~= "string" or path == "" then
        return "Custom"
    end

    -- If it's an LSM key (we store keys in fontListPaths), return the friendly name.
    for i = 1, #fontListPaths do
        if fontListPaths[i] == path then
            return fontListNames[i]
        end
    end

    -- If it's a concrete file path, try to find a matching LSM entry by resolving keys.
    if path:find("\\") or path:find("/") then
        for i = 1, #fontListPaths do
            local v = fontListPaths[i]
            if type(v) == "string" and v ~= "" and not (v:find("\\") or v:find("/")) then
                local resolved = addon.ResolveFontPath(v)
                if resolved == path then
                    return fontListNames[i]
                end
            end
        end
        return "Custom"
    end

    -- Otherwise, it's probably an unknown key; show it as-is.
    return path
end

-- ============================================================================
-- SOUND LIST (for rare boss sound picker via LibSharedMedia)
-- ============================================================================

function addon.GetSoundDropdownOptions()
    local list = { { "Default (Quest Complete)", "default" } }
    local LSM = (LibStub and LibStub("LibSharedMedia-3.0", true)) or nil
    if not (LSM and LSM.HashTable) then return list end
    local hash = LSM:HashTable("sound")
    if type(hash) ~= "table" then return list end
    local names = {}
    for name in pairs(hash) do
        if type(name) == "string" and name ~= "" then
            names[#names + 1] = name
        end
    end
    table.sort(names)
    for _, name in ipairs(names) do
        list[#list + 1] = { name, name }
    end
    return list
end

