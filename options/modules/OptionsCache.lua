--[[
    Horizon Suite - Cache - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont
local Section                          = addon.Section
local Button                           = addon.Button
local Toggle                           = addon.Toggle
local D   = addon.CACHE_DEFAULTS
local LIM = addon.CACHE_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end
local function getSlider(key)
    local lim = LIM[key]
    local v = tonumber(getDB(key, D[key])) or D[key]
    return math.max(lim.min, math.min(lim.max, v))
end

local categories = {
    {
        key = "CacheGeneral",
        name = L["AXIS_GENERAL"],
        desc = L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"],
        moduleKey = "cache",
        options = {
            Section(L["AXIS_POSITION"]),
            Button(L["AXIS_ANCHOR_MOVE"], L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"], function()
                if addon.Cache and addon.Cache.ToggleAnchorFrame then addon.Cache.ToggleAnchorFrame() end
            end),
            Button(L["AXIS_RESET_POSITION"], L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"], function()
                if addon.Cache and addon.Cache.ResetPosition then addon.Cache.ResetPosition() end
            end),
            Section(L["CACHE_MAX_VISIBLE_SECTION"]),
            { type = "slider", name = L["CACHE_TOAST_OPACITY"], desc = L["CACHE_TOAST_OPACITY_DESC"], dbKey = "cacheToastOpacity",
                min = LIM.cacheToastOpacity.min, max = LIM.cacheToastOpacity.max, step = 5,
                get = function() return getSlider("cacheToastOpacity") end,
                set = function(v) setDB("cacheToastOpacity", clamp(v, "cacheToastOpacity")) end,
            },
            { type = "slider", name = L["CACHE_MAX_VISIBLE"], desc = L["CACHE_MAX_VISIBLE_DESC"], dbKey = "cacheMaxVisible",
                min = LIM.cacheMaxVisible.min, max = LIM.cacheMaxVisible.max, step = 1,
                get = function() return getSlider("cacheMaxVisible") end,
                set = function(v) setDB("cacheMaxVisible", clamp(v, "cacheMaxVisible")) end,
            },
            { type = "slider", name = L["CACHE_TOAST_SCALE"], desc = L["CACHE_TOAST_SCALE_DESC"], dbKey = "cacheUIScale",
                min = LIM.cacheUIScale.min, max = LIM.cacheUIScale.max, step = 0.05,
                get = function() return getSlider("cacheUIScale") end,
                set = function(v) setDB("cacheUIScale", clamp(v, "cacheUIScale")) end,
            },
        },
    },
    {
        key = "CacheToastTypes",
        name = L["CACHE_TOAST_TYPES"],
        desc = L["CACHE_TOAST_TYPES_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            Section(L["CACHE_TOAST_TYPES"]),
            Toggle(L["CACHE_SHOW_ITEMS"],        L["CACHE_SHOW_ITEMS_DESC"],        "cacheShowItems",        D.cacheShowItems,        { refreshIds = { "cacheMinQuality", "cacheShowPushedItems" } }),
            Toggle(L["CACHE_SHOW_PUSHED_ITEMS"], L["CACHE_SHOW_PUSHED_ITEMS_DESC"], "cacheShowPushedItems",  D.cacheShowPushedItems,  { disabled = function() return getDB("cacheShowItems", D.cacheShowItems) == false end }),
            Toggle(L["CACHE_SHOW_MONEY"],    L["CACHE_SHOW_MONEY_DESC"],    "cacheShowMoney",    D.cacheShowMoney),
            Toggle(L["CACHE_SHOW_CURRENCY"], L["CACHE_SHOW_CURRENCY_DESC"], "cacheShowCurrency", D.cacheShowCurrency),
            Toggle(L["CACHE_SHOW_REP"],      L["CACHE_SHOW_REP_DESC"],      "cacheShowRep",      D.cacheShowRep),
            Section(L["CACHE_STACKING_SECTION"]),
            Toggle(L["CACHE_STACK_DUPLICATES"], L["CACHE_STACK_DUPLICATES_DESC"], "cacheStackDuplicates", D.cacheStackDuplicates),
            Toggle(L["CACHE_CONDENSE_JUNK"],    L["CACHE_CONDENSE_JUNK_DESC"],    "cacheCondenseJunk",    D.cacheCondenseJunk,    { disabled = function() return getDB("cacheShowItems", D.cacheShowItems) == false end }),
            { type = "dropdown", name = L["CACHE_MIN_QUALITY"], desc = L["CACHE_MIN_QUALITY_DESC"], dbKey = "cacheMinQuality",
                options = function()
                    return {
                        { ITEM_QUALITY0_DESC or "Poor",      0 },
                        { ITEM_QUALITY1_DESC or "Common",    1 },
                        { ITEM_QUALITY2_DESC or "Uncommon",  2 },
                        { ITEM_QUALITY3_DESC or "Rare",      3 },
                        { ITEM_QUALITY4_DESC or "Epic",      4 },
                        { ITEM_QUALITY5_DESC or "Legendary", 5 },
                    }
                end,
                get = function() return tonumber(getDB("cacheMinQuality", D.cacheMinQuality)) or D.cacheMinQuality end,
                set = function(v) setDB("cacheMinQuality", v) end,
                disabled = function() return getDB("cacheShowItems", D.cacheShowItems) == false end,
            },
            Section(L["CACHE_BLIZZARD_SECTION"]),
            Toggle(L["CACHE_SUPPRESS_BLIZZARD"], L["CACHE_SUPPRESS_BLIZZARD_DESC"], "cacheSuppressBlizzard", D.cacheSuppressBlizzard),
        },
    },
    {
        key = "CacheDurations",
        name = L["CACHE_HOLD_DURATIONS"],
        desc = L["CACHE_HOLD_DURATIONS_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            Section(L["CACHE_HOLD_DURATIONS"]),
            { type = "slider", name = L["CACHE_HOLD_ITEM"],      desc = L["CACHE_HOLD_ITEM_DESC"],      dbKey = "cacheHoldItem",
                min = LIM.cacheHoldItem.min, max = LIM.cacheHoldItem.max, step = 0.5,
                get = function() return getSlider("cacheHoldItem") end,
                set = function(v) setDB("cacheHoldItem", clamp(v, "cacheHoldItem")) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", D.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", D.cacheShowItems) == false or minQ > 3
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_EPIC"],      desc = L["CACHE_HOLD_EPIC_DESC"],      dbKey = "cacheHoldEpic",
                min = LIM.cacheHoldEpic.min, max = LIM.cacheHoldEpic.max, step = 0.5,
                get = function() return getSlider("cacheHoldEpic") end,
                set = function(v) setDB("cacheHoldEpic", clamp(v, "cacheHoldEpic")) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", D.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", D.cacheShowItems) == false or minQ > 4
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_LEGENDARY"], desc = L["CACHE_HOLD_LEGENDARY_DESC"], dbKey = "cacheHoldLegendary",
                min = LIM.cacheHoldLegendary.min, max = LIM.cacheHoldLegendary.max, step = 0.5,
                get = function() return getSlider("cacheHoldLegendary") end,
                set = function(v) setDB("cacheHoldLegendary", clamp(v, "cacheHoldLegendary")) end,
                disabled = function() return getDB("cacheShowItems", D.cacheShowItems) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_MONEY"],    desc = L["CACHE_HOLD_MONEY_DESC"],    dbKey = "cacheHoldMoney",
                min = LIM.cacheHoldMoney.min, max = LIM.cacheHoldMoney.max, step = 0.5,
                get = function() return getSlider("cacheHoldMoney") end,
                set = function(v) setDB("cacheHoldMoney", clamp(v, "cacheHoldMoney")) end,
                disabled = function() return getDB("cacheShowMoney", D.cacheShowMoney) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_CURRENCY"], desc = L["CACHE_HOLD_CURRENCY_DESC"], dbKey = "cacheHoldCurrency",
                min = LIM.cacheHoldCurrency.min, max = LIM.cacheHoldCurrency.max, step = 0.5,
                get = function() return getSlider("cacheHoldCurrency") end,
                set = function(v) setDB("cacheHoldCurrency", clamp(v, "cacheHoldCurrency")) end,
                disabled = function() return getDB("cacheShowCurrency", D.cacheShowCurrency) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_REP"],      desc = L["CACHE_HOLD_REP_DESC"],      dbKey = "cacheHoldRep",
                min = LIM.cacheHoldRep.min, max = LIM.cacheHoldRep.max, step = 0.5,
                get = function() return getSlider("cacheHoldRep") end,
                set = function(v) setDB("cacheHoldRep", clamp(v, "cacheHoldRep")) end,
                disabled = function() return getDB("cacheShowRep", D.cacheShowRep) == false end,
            },
        },
    },
    {
        key = "CacheSounds",
        name = L["CACHE_SOUNDS"],
        desc = L["CACHE_SOUNDS_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            Section(L["CACHE_SOUNDS"]),
            Toggle(L["CACHE_SOUND_ENABLED"], L["CACHE_SOUND_ENABLED_DESC"], "cacheSoundEnabled", D.cacheSoundEnabled),
            { type = "dropdown", name = L["CACHE_SOUND_CHANNEL"], desc = L["CACHE_SOUND_CHANNEL_DESC"], dbKey = "cacheSoundChannel",
                options = {
                    { L["CACHE_SOUND_CH_SFX"],      "SFX"      },
                    { L["CACHE_SOUND_CH_MASTER"],   "Master"   },
                    { L["CACHE_SOUND_CH_DIALOG"],   "Dialog"   },
                    { L["CACHE_SOUND_CH_AMBIENCE"], "Ambience" },
                    { L["CACHE_SOUND_CH_MUSIC"],    "Music"    },
                },
                get = function() return getDB("cacheSoundChannel", D.cacheSoundChannel) end,
                set = function(v) setDB("cacheSoundChannel", v) end,
                visibleWhen = function() return getDB("cacheSoundEnabled", D.cacheSoundEnabled) ~= false end,
            },
            Toggle(L["CACHE_SOUND_ITEMS"],    L["CACHE_SOUND_ITEMS_DESC"],    "cacheSoundItems",    D.cacheSoundItems,    { visibleWhen = function() return getDB("cacheSoundEnabled", D.cacheSoundEnabled) ~= false end }),
            Toggle(L["CACHE_SOUND_MONEY"],    L["CACHE_SOUND_MONEY_DESC"],    "cacheSoundMoney",    D.cacheSoundMoney,    { visibleWhen = function() return getDB("cacheSoundEnabled", D.cacheSoundEnabled) ~= false end }),
            Toggle(L["CACHE_SOUND_CURRENCY"], L["CACHE_SOUND_CURRENCY_DESC"], "cacheSoundCurrency", D.cacheSoundCurrency, { visibleWhen = function() return getDB("cacheSoundEnabled", D.cacheSoundEnabled) ~= false end }),
            Toggle(L["CACHE_SOUND_REP"],      L["CACHE_SOUND_REP_DESC"],      "cacheSoundRep",      D.cacheSoundRep,      { visibleWhen = function() return getDB("cacheSoundEnabled", D.cacheSoundEnabled) ~= false end }),
        },
    },
    {
        key = "CacheTypography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["CACHE_TYPOGRAPHY_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            Section(L["DASH_TYPOGRAPHY"]),
            { type = "toggle", name = L["CACHE_TEXT_OUTLINE"], desc = L["CACHE_TEXT_OUTLINE_DESC"], dbKey = "cacheTextOutline",
                get = function() return getDB("cacheTextOutline", D.cacheTextOutline) ~= false end,
                set = function(v) setDB("cacheTextOutline", v) end,
            },
            { type = "slider", name = L["CACHE_FONT_SIZE"], desc = L["CACHE_FONT_SIZE_DESC"], dbKey = "cacheFontSize",
                min = LIM.cacheFontSize.min, max = LIM.cacheFontSize.max, step = 1,
                get = function() return getSlider("cacheFontSize") end,
                set = function(v) setDB("cacheFontSize", clamp(v, "cacheFontSize")) end,
            },
            { type = "dropdown",
                name = L["CACHE_FONT"],
                desc = L["CACHE_FONT_FAMILY"],
                dbKey = "cacheFontPath",
                searchable = true,
                options = function() return GetPerElementFontDropdownOptions("cacheFontPath") end,
                get = function() return getDB("cacheFontPath", FONT_USE_GLOBAL) end,
                set = function(v) setDB("cacheFontPath", v) end,
                displayFn = DisplayPerElementFont,
                fontPreviewInList = true,
            },
        },
    },
    {
        key = "CachePreview",
        name = L["CACHE_PREVIEW_SECTION"],
        desc = L["CACHE_PREVIEW_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            Section(L["CACHE_PREVIEW_SECTION"]),
            Button(L["CACHE_PREVIEW"], L["CACHE_PREVIEW_DESC"], function()
                if addon.Cache and addon.Cache.PreviewToasts then addon.Cache.PreviewToasts() end
            end),
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
