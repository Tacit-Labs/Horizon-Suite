--[[
    Horizon Suite — Config
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

addon.POOL_SIZE       = 50
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
addon.SPACED_TITLE_SPACING  = 12
addon.SPACED_OBJ_SPACING    = 3

-- Single source of truth for spacing presets. All spacing getters resolve from here when not in Custom mode.
addon.SPACING_PRESETS = {
    default = {
        titleSpacing = 8,
        objSpacing = 2,
        titleToContentSpacing = 2,
        sectionSpacing = 10,
        sectionToEntryGap = 6,
        headerToContentGap = 6,
    },
    compact = {
        titleSpacing = 4,
        objSpacing = 1,
        titleToContentSpacing = 1,
        sectionSpacing = 8,
        sectionToEntryGap = 4,
        headerToContentGap = 6,
    },
    spaced = {
        titleSpacing = 12,
        objSpacing = 3,
        titleToContentSpacing = 3,
        sectionSpacing = 12,
        sectionToEntryGap = 8,
        headerToContentGap = 8,
    },
}
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
addon.AH_BTN_SIZE         = 18   -- Auctionator search button (right-side gutter, recipe entries)
addon.DELVE_TIER_ATLAS = "delves-scenario-flag"  -- Blizzard atlas for Delve tier/flag (TierFrame.Flag)
addon.DELVE_LIFE_EMBED_SIZE = 13                 -- |T icon :H:W|t size for delve lives strip in tracker title row

-- Runtime values overwritten in Focus ApplyTypography from saved shadow settings.
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
    minimapFadeIn  = 0.2,
    minimapFadeOut = 0.3,
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
-- Timer urgency (absolute): green (>=12h left), yellow (<12h), red (<3h)
addon.TIMER_URGENCY_RED_SECONDS    = 3 * 3600   -- 3 hours
addon.TIMER_URGENCY_YELLOW_SECONDS = 12 * 3600 -- 12 hours
addon.TIMER_URGENCY_COLORS = {
    plenty = { 0.35, 0.90, 0.45 },  -- green
    low    = { 1.00, 0.85, 0.25 },  -- yellow
    critical = { 1.00, 0.35, 0.35 }, -- red
}
addon.ZONE_SIZE       = 10
addon.ZONE_COLOR      = { 0.55, 0.65, 0.75 }

-- WoW color systems (for distinctness): Item quality (Poor grey, Common white, Uncommon green, Rare blue 0070dd,
-- Epic purple a335ee, Legendary orange ff8000, Artifact gold e6cc80); quest icons (Campaign gold, Recurring cyan,
-- Important pink); quest difficulty (green/yellow/orange/red). We align where meaningful and avoid collisions.
addon.QUEST_COLORS = {
    DEFAULT   = { 0.90, 0.90, 0.90 },
    CURRENT   = { 0.95, 0.55, 0.45 },  -- coral, matches SECTION_COLORS.CURRENT (Current Quest)
    AVAILABLE     = { 0.28, 0.48, 0.88 },  -- deep blue (Events in Zone; distinct from WEEKLY/DAILY cyan)
    CURRENT_EVENT = { 0.28, 0.48, 0.88 },  -- deep blue (continuity with Events in Zone)
    NEARBY    = { 0.35, 0.75, 0.98 },  -- sky blue, matches SECTION_COLORS.NEARBY (Current Zone)
    CAMPAIGN  = { 1.00, 0.82, 0.20 },
    IMPORTANT = { 1.00, 0.45, 0.80 },  -- pink to match importantavailablequesticon
    LEGENDARY = { 1.00, 0.50, 0.00 },
    DUNGEON   = { 0.64, 0.21, 0.93 },  -- WoW Epic purple (a335ee); instanced content
    RAID      = { 0.85, 0.25, 0.25 },  -- red: raid quests
    DELVES    = { 0.32, 0.72, 0.68 },  -- teal/seafoam: Delve steps (distinct from all other categories)
    SCENARIO  = { 0.38, 0.52, 0.88 },  -- deep blue: event/scenario steps (Twilight's Call etc.)
    SCENARIO_STAGE = { 0.55, 0.65, 0.75 },  -- matches ZONE_COLOR: scenario stage line (customizable in options)
    WORLD     = { 0.78, 0.42, 0.95 },  -- purple-violet (slightly more purple; distinct from DUNGEON)
    WEEKLY    = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    PREY      = { 0.72, 0.22, 0.22 },  -- dark crimson (Midnight Prey; distinct from RAID red)
    DAILY     = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    CALLING   = { 0.20, 0.60, 1.00 },
    COMPLETE  = { 0.20, 1.00, 0.40 },
    RARE      = { 0.96, 0.56, 0.08 },  -- warm orange (distinct from CURRENT coral, LEGENDARY)
    RARE_LOOT = { 0.96, 0.56, 0.08 },  -- warm orange (same as Rare Bosses)
    ACHIEVEMENT = { 0.78, 0.48, 0.22 },  -- bronze, trophy feel
    ENDEAVOR   = { 0.45, 0.95, 0.75 },  -- mint green (housing/endeavor)
    ENDEAVORS  = { 0.45, 0.95, 0.75 },  -- mint green (color matrix group default)
    DECOR      = { 0.65, 0.55, 0.45 },  -- warm brown (housing decor)
    APPEARANCE = { 135/255, 96/255, 1 },  -- #8760FF (transmog / tracked appearances)
    APPEARANCES = { 135/255, 96/255, 1 },  -- group default (color matrix)
    RECIPE     = { 0.55, 0.75, 0.45 },  -- sage green (profession recipes)
    RECIPES    = { 0.55, 0.75, 0.45 },  -- sage green (group default)
    ADVENTURE  = { 0.90, 0.80, 0.50 },  -- artifact gold (WoW e6cc80; distinct from CAMPAIGN)
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

-- Values are locale keys (L["UI_*"]) so tracker/options pick up translations; see Localisation/enUS.lua (Tracker section labels).
addon.SECTION_LABELS = {
    CURRENT       = "UI_CURRENT_QUEST",
    CURRENT_EVENT = "UI_CURRENT_EVENT",
    DUNGEON       = "UI_DUNGEON",
    RAID          = "UI_RAID",
    DELVES        = "UI_DELVES",
    SCENARIO      = "UI_SCENARIO_EVENTS",
    AVAILABLE     = "UI_EVENTS_IN_ZONE",
    NEARBY        = "UI_CURRENT_ZONE",
    CAMPAIGN      = "UI_CAMPAIGN",
    IMPORTANT     = "UI_IMPORTANT",
    LEGENDARY     = "UI_LEGENDARY",
    WORLD         = "UI_WORLD_QUESTS",
    WEEKLY        = "UI_WEEKLY_QUESTS",
    PREY          = "UI_PREY",
    DAILY         = "UI_DAILY_QUESTS",
    RARES         = "UI_RARE_BOSSES",
    RARE_LOOT     = "UI_RARE_LOOT",
    ACHIEVEMENTS  = "UI_ACHIEVEMENTS",
    ENDEAVORS     = "UI_ENDEAVORS",
    DECOR         = "UI_DECOR",
    APPEARANCES   = "UI_APPEARANCES",
    RECIPES       = "UI_RECIPES",
    ADVENTURE     = "UI_ADVENTURE_GUIDE",
    DEFAULT       = "UI_QUESTS",
    COMPLETE      = "UI_READY_TO_TURN_IN",
}

addon.SECTION_COLORS = {
    CURRENT   = { 0.95, 0.55, 0.45 },  -- coral (recent progress; distinct from NEARBY)
    DUNGEON   = { 0.64, 0.21, 0.93 },  -- WoW Epic purple (a335ee)
    RAID      = { 0.85, 0.25, 0.25 },  -- red: raid quests
    DELVES    = { 0.32, 0.72, 0.68 },  -- teal: Delve section
    SCENARIO  = { 0.38, 0.52, 0.88 },  -- deep blue: event/scenario steps
    SCENARIO_STAGE = { 0.55, 0.65, 0.75 },  -- matches ZONE_COLOR: scenario stage line
    AVAILABLE    = { 0.28, 0.48, 0.88 },  -- deep blue (Events in Zone; distinct from WEEKLY/DAILY cyan)
    CURRENT_EVENT = { 0.28, 0.48, 0.88 },  -- deep blue (continuity with Events in Zone)
    NEARBY    = { 0.35, 0.75, 0.98 },  -- sky blue (accepted, in zone)
    CAMPAIGN  = { 1.00, 0.82, 0.20 },
    IMPORTANT = { 1.00, 0.45, 0.80 },  -- pink to match importantavailablequesticon
    LEGENDARY = { 1.00, 0.50, 0.00 },
    WORLD     = { 0.78, 0.42, 0.95 },  -- purple-violet (slightly more purple)
    WEEKLY    = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    PREY      = { 0.72, 0.22, 0.22 },  -- dark crimson (Midnight Prey; distinct from RAID red)
    DAILY     = { 0.25, 0.88, 0.92 },  -- match quest-recurring-available icon (cyan)
    RARES     = { 0.96, 0.56, 0.08 },  -- warm orange (distinct from CURRENT coral, LEGENDARY)
    RARE_LOOT = { 0.96, 0.56, 0.08 },  -- warm orange (same as Rare Bosses)
    ACHIEVEMENTS = { 0.78, 0.48, 0.22 },  -- bronze
    ENDEAVORS  = { 0.45, 0.95, 0.75 },  -- mint green (housing/endeavor)
    DECOR      = { 0.65, 0.55, 0.45 },  -- warm brown (housing decor)
    APPEARANCES = { 135/255, 96/255, 1 },  -- #8760FF (transmog appearances)
    RECIPES    = { 0.55, 0.75, 0.45 },  -- sage green (profession recipes)
    ADVENTURE  = { 0.90, 0.80, 0.50 },  -- artifact gold (WoW e6cc80; distinct from CAMPAIGN)
    DEFAULT   = { 0.90, 0.90, 0.90 },  -- matches QUEST_COLORS.DEFAULT so section/title/objective share same default
    COMPLETE  = { 0.20, 1.00, 0.40 },
}

addon.GROUP_ORDER = { "CURRENT_EVENT", "CURRENT", "DELVES", "SCENARIO", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "APPEARANCES", "RECIPES", "ADVENTURE", "DUNGEON", "RAID", "NEARBY", "COMPLETE", "WORLD", "WEEKLY", "PREY", "DAILY", "RARES", "RARE_LOOT", "AVAILABLE", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "DEFAULT" }

addon.GROUP_ORDER_PRESETS = {
    ["Collection Focused"] = { "CURRENT_EVENT", "CURRENT", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "APPEARANCES", "RECIPES", "ADVENTURE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "NEARBY", "COMPLETE", "WORLD", "WEEKLY", "PREY", "DAILY", "RARES", "RARE_LOOT", "AVAILABLE", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "DEFAULT" },
    ["Quest Focused"]      = { "CURRENT_EVENT", "CURRENT", "COMPLETE", "NEARBY", "AVAILABLE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "WORLD", "WEEKLY", "PREY", "DAILY", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "RARES", "RARE_LOOT", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "APPEARANCES", "RECIPES", "ADVENTURE", "DEFAULT" },
    ["Campaign Focused"]   = { "CURRENT_EVENT", "CURRENT", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "COMPLETE", "NEARBY", "DELVES", "SCENARIO", "DUNGEON", "RAID", "AVAILABLE", "WORLD", "WEEKLY", "PREY", "DAILY", "RARES", "RARE_LOOT", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "APPEARANCES", "RECIPES", "ADVENTURE", "DEFAULT" },
    ["World / Rare Focused"] = { "CURRENT_EVENT", "CURRENT", "WORLD", "WEEKLY", "PREY", "DAILY", "RARES", "RARE_LOOT", "NEARBY", "COMPLETE", "AVAILABLE", "DELVES", "SCENARIO", "DUNGEON", "RAID", "CAMPAIGN", "IMPORTANT", "LEGENDARY", "ACHIEVEMENTS", "ENDEAVORS", "DECOR", "APPEARANCES", "RECIPES", "ADVENTURE", "DEFAULT" },
}

-- Section groupKeys whose headers skip super-track dimming (achievements, rares, etc. — not quest log rows).
addon.NON_QUEST_SUPERTRACK_DIM_SECTION_KEYS = {
    ACHIEVEMENTS = true,
    ENDEAVORS = true,
    DECOR = true,
    APPEARANCES = true,
    RECIPES = true,
    ADVENTURE = true,
    RARES = true,
    RARE_LOOT = true,
}

-- Category keys (enum-style) for consistent string usage across modules.
addon.CATEGORY_KEYS = {
    CURRENT = "CURRENT", CURRENT_EVENT = "CURRENT_EVENT", DUNGEON = "DUNGEON", RAID = "RAID", DELVES = "DELVES", SCENARIO = "SCENARIO", AVAILABLE = "AVAILABLE", NEARBY = "NEARBY", CAMPAIGN = "CAMPAIGN",
    IMPORTANT = "IMPORTANT", LEGENDARY = "LEGENDARY", WORLD = "WORLD", WEEKLY = "WEEKLY", PREY = "PREY",
    DAILY = "DAILY", RARES = "RARES", RARE = "RARE", RARE_LOOT = "RARE_LOOT", ACHIEVEMENT = "ACHIEVEMENT", ACHIEVEMENTS = "ACHIEVEMENTS",
    ENDEAVOR = "ENDEAVOR", ENDEAVORS = "ENDEAVORS",
    DECOR = "DECOR",
    APPEARANCE = "APPEARANCE", APPEARANCES = "APPEARANCES",
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
    PREY      = "PREY",
    DAILY     = "DAILY",
    CALLING   = "WORLD",
    RARE_LOOT = "RARE_LOOT",
    ACHIEVEMENT = "ACHIEVEMENTS",
    ENDEAVOR   = "ENDEAVORS",
    DECOR      = "DECOR",
    APPEARANCE = "APPEARANCES",
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

-- ============================================================================
-- STATUSBAR LIST (for progress bar texture via LibSharedMedia)
-- ============================================================================

--- Resolve a LibSharedMedia statusbar key to a texture file path.
--- @param value string|nil LSM statusbar key (e.g. "Solid", "Blizzard")
--- @return string Texture path; fallback to WHITE8X8 if invalid
function addon.ResolveStatusbarPath(value)
    if type(value) ~= "string" or value == "" then
        return "Interface\\Buttons\\WHITE8X8"
    end
    local LSM = (LibStub and LibStub("LibSharedMedia-3.0", true)) or nil
    if LSM and LSM.Fetch then
        local ok, path = pcall(LSM.Fetch, LSM, "statusbar", value, true)
        if ok and type(path) == "string" and path ~= "" then
            return path
        end
    end
    return "Interface\\Buttons\\WHITE8X8"
end

--- Build dropdown options for statusbar textures from LibSharedMedia.
--- @return table Array of { displayName, value } pairs; "Solid" first
function addon.GetStatusbarDropdownOptions()
    local list = {}
    local LSM = (LibStub and LibStub("LibSharedMedia-3.0", true)) or nil
    if not (LSM and LSM.HashTable) then
        list[1] = { "Solid", "Solid" }
        return list
    end
    local hash = LSM:HashTable("statusbar")
    if type(hash) ~= "table" then
        list[1] = { "Solid", "Solid" }
        return list
    end
    local names = {}
    for name in pairs(hash) do
        if type(name) == "string" and name ~= "" then
            names[#names + 1] = name
        end
    end
    table.sort(names)
    -- Prefer "Solid" first to match default behavior
    if names[1] ~= "Solid" then
        local idx = nil
        for i, n in ipairs(names) do
            if n == "Solid" then idx = i break end
        end
        if idx then
            table.remove(names, idx)
            table.insert(names, 1, "Solid")
        end
    end
    for _, name in ipairs(names) do
        list[#list + 1] = { name, name }
    end
    if #list == 0 then list[1] = { "Solid", "Solid" } end
    return list
end

--- Apply progress bar fill texture and vertex color. Uses LSM statusbar texture from DB.
--- @param tex table Texture object (e.g. progressBarFill)
--- @param r number Red (0-1)
--- @param g number Green (0-1)
--- @param b number Blue (0-1)
--- @param a number|nil Alpha (0-1); default 0.85
function addon.ApplyProgressBarFillTexture(tex, r, g, b, a)
    if not tex then return end
    local path = addon.ResolveStatusbarPath(addon.GetDB("progressBarTexture", "Solid"))
    tex:SetTexture(path)
    tex:SetVertexColor(r or 0.4, g or 0.65, b or 0.9, a or 0.85)
end

--- Unread patch-notes marker: bundled media/update.tga; fallback masked green dot if missing.
--- Loaded from Config so MinimapButton (and beta TOC without PatchNotes.lua) can use it.
--- @param tex Texture
--- @return nil
function addon.PatchNotes_StyleAttentionBadge(tex)
    if not tex then return end
    pcall(function() tex:SetMask(nil) end)
    local folder = addon.ADDON_NAME or "HorizonSuite"
    local base = "Interface\\AddOns\\" .. folder .. "\\media\\update"
    local ok = pcall(function() tex:SetTexture(base) end)
    if not ok then
        ok = pcall(function() tex:SetTexture(base .. ".tga") end)
    end
    if ok then
        pcall(function() tex:SetVertexColor(1, 1, 1, 1) end)
        return
    end
    pcall(function()
        tex:SetTexture(nil)
        tex:SetColorTexture(0.20, 0.82, 0.28, 1)
        tex:SetMask("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    end)
end

-- ============================================================================
-- BRAND DISPLAY
-- Fixed English product and module display names — NOT localised.
-- UI sentences/descriptions belong in addon.L; see TRANSLATING.md.
-- ============================================================================

addon.BrandDisplay = {
    optionsTitle = "HORIZON SUITE",
    -- Short name for minimap icon tooltip title (not localised).
    minimapTooltipTitle = "Horizon",
    productName = "Horizon Suite",
    horizonInsight = "Horizon Insight",
    module = {
        axis = "Axis",
        focus = "Focus",
        presence = "Presence",
        vista = "Vista",
        insight = "Insight",
        cache = "Cache",
        essence = "Essence",
        meridian = "Meridian",
    },
}

