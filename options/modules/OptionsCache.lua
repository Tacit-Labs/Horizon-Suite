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

local categories = {
    {
        key = "CacheGeneral",
        name = L["AXIS_GENERAL"],
        desc = L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"],
        moduleKey = "cache",
        options = {
            { type = "section", name = L["AXIS_POSITION"] },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"], desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"], onClick = function()
                if addon.Cache and addon.Cache.ToggleAnchorFrame then addon.Cache.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_POSITION"], desc = L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"], onClick = function()
                if addon.Cache and addon.Cache.ResetPosition then addon.Cache.ResetPosition() end
            end },
            { type = "section", name = L["CACHE_MAX_VISIBLE_SECTION"] },
            { type = "slider", name = L["CACHE_TOAST_OPACITY"], desc = L["CACHE_TOAST_OPACITY_DESC"], dbKey = "cacheToastOpacity",
                min = 10, max = 100, step = 5,
                get = function() return math.max(10, math.min(100, tonumber(getDB("cacheToastOpacity", addon.CACHE_DEFAULTS.cacheToastOpacity)) or addon.CACHE_DEFAULTS.cacheToastOpacity)) end,
                set = function(v) setDB("cacheToastOpacity", math.max(10, math.min(100, v))) end,
            },
            { type = "slider", name = L["CACHE_MAX_VISIBLE"], desc = L["CACHE_MAX_VISIBLE_DESC"], dbKey = "cacheMaxVisible",
                min = 1, max = 15, step = 1,
                get = function() return math.max(1, math.min(15, tonumber(getDB("cacheMaxVisible", addon.CACHE_DEFAULTS.cacheMaxVisible)) or addon.CACHE_DEFAULTS.cacheMaxVisible)) end,
                set = function(v) setDB("cacheMaxVisible", math.max(1, math.min(15, v))) end,
            },
            { type = "slider", name = L["CACHE_TOAST_SCALE"], desc = L["CACHE_TOAST_SCALE_DESC"], dbKey = "cacheUIScale",
                min = 0.5, max = 2.0, step = 0.05,
                get = function() return math.max(0.5, math.min(2.0, tonumber(getDB("cacheUIScale", addon.CACHE_DEFAULTS.cacheUIScale)) or addon.CACHE_DEFAULTS.cacheUIScale)) end,
                set = function(v) setDB("cacheUIScale", math.max(0.5, math.min(2.0, v))) end,
            },
        },
    },
    {
        key = "CacheToastTypes",
        name = L["CACHE_TOAST_TYPES"],
        desc = L["CACHE_TOAST_TYPES_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            { type = "section", name = L["CACHE_TOAST_TYPES"] },
            { type = "toggle", name = L["CACHE_SHOW_ITEMS"],    desc = L["CACHE_SHOW_ITEMS_DESC"],    dbKey = "cacheShowItems",    get = function() return getDB("cacheShowItems",    addon.CACHE_DEFAULTS.cacheShowItems)    end, set = function(v) setDB("cacheShowItems",    v) end, refreshIds = { "cacheMinQuality" } },
            { type = "toggle", name = L["CACHE_SHOW_MONEY"],    desc = L["CACHE_SHOW_MONEY_DESC"],    dbKey = "cacheShowMoney",    get = function() return getDB("cacheShowMoney",    addon.CACHE_DEFAULTS.cacheShowMoney)    end, set = function(v) setDB("cacheShowMoney",    v) end },
            { type = "toggle", name = L["CACHE_SHOW_CURRENCY"], desc = L["CACHE_SHOW_CURRENCY_DESC"], dbKey = "cacheShowCurrency", get = function() return getDB("cacheShowCurrency", addon.CACHE_DEFAULTS.cacheShowCurrency) end, set = function(v) setDB("cacheShowCurrency", v) end },
            { type = "toggle", name = L["CACHE_SHOW_REP"],      desc = L["CACHE_SHOW_REP_DESC"],      dbKey = "cacheShowRep",      get = function() return getDB("cacheShowRep",      addon.CACHE_DEFAULTS.cacheShowRep)      end, set = function(v) setDB("cacheShowRep",      v) end },
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
                get = function() return tonumber(getDB("cacheMinQuality", addon.CACHE_DEFAULTS.cacheMinQuality)) or addon.CACHE_DEFAULTS.cacheMinQuality end,
                set = function(v) setDB("cacheMinQuality", v) end,
                disabled = function() return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false end,
            },
        },
    },
    {
        key = "CacheDurations",
        name = L["CACHE_HOLD_DURATIONS"],
        desc = L["CACHE_HOLD_DURATIONS_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            { type = "section", name = L["CACHE_HOLD_DURATIONS"] },
            { type = "slider", name = L["CACHE_HOLD_ITEM"],      desc = L["CACHE_HOLD_ITEM_DESC"],      dbKey = "cacheHoldItem",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldItem",      addon.CACHE_DEFAULTS.cacheHoldItem))      or addon.CACHE_DEFAULTS.cacheHoldItem))      end,
                set = function(v) setDB("cacheHoldItem",      math.max(1, math.min(12, v))) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", addon.CACHE_DEFAULTS.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false or minQ > 3
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_EPIC"],      desc = L["CACHE_HOLD_EPIC_DESC"],      dbKey = "cacheHoldEpic",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldEpic",      addon.CACHE_DEFAULTS.cacheHoldEpic))      or addon.CACHE_DEFAULTS.cacheHoldEpic))      end,
                set = function(v) setDB("cacheHoldEpic",      math.max(1, math.min(12, v))) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", addon.CACHE_DEFAULTS.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false or minQ > 4
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_LEGENDARY"], desc = L["CACHE_HOLD_LEGENDARY_DESC"], dbKey = "cacheHoldLegendary",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldLegendary", addon.CACHE_DEFAULTS.cacheHoldLegendary)) or addon.CACHE_DEFAULTS.cacheHoldLegendary)) end,
                set = function(v) setDB("cacheHoldLegendary", math.max(1, math.min(12, v))) end,
                disabled = function() return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_MONEY"],    desc = L["CACHE_HOLD_MONEY_DESC"],    dbKey = "cacheHoldMoney",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldMoney",    addon.CACHE_DEFAULTS.cacheHoldMoney))    or addon.CACHE_DEFAULTS.cacheHoldMoney))    end,
                set = function(v) setDB("cacheHoldMoney",    math.max(1, math.min(12, v))) end,
                disabled = function() return getDB("cacheShowMoney", addon.CACHE_DEFAULTS.cacheShowMoney) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_CURRENCY"], desc = L["CACHE_HOLD_CURRENCY_DESC"], dbKey = "cacheHoldCurrency",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldCurrency", addon.CACHE_DEFAULTS.cacheHoldCurrency)) or addon.CACHE_DEFAULTS.cacheHoldCurrency)) end,
                set = function(v) setDB("cacheHoldCurrency", math.max(1, math.min(12, v))) end,
                disabled = function() return getDB("cacheShowCurrency", addon.CACHE_DEFAULTS.cacheShowCurrency) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_REP"],      desc = L["CACHE_HOLD_REP_DESC"],      dbKey = "cacheHoldRep",
                min = 1, max = 12, step = 0.5,
                get = function() return math.max(1, math.min(12, tonumber(getDB("cacheHoldRep",      addon.CACHE_DEFAULTS.cacheHoldRep))      or addon.CACHE_DEFAULTS.cacheHoldRep))      end,
                set = function(v) setDB("cacheHoldRep",      math.max(1, math.min(12, v))) end,
                disabled = function() return getDB("cacheShowRep", addon.CACHE_DEFAULTS.cacheShowRep) == false end,
            },
        },
    },
    {
        key = "CacheSounds",
        name = L["CACHE_SOUNDS"],
        desc = L["CACHE_SOUNDS_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            { type = "section", name = L["CACHE_SOUNDS"] },
            { type = "toggle", name = L["CACHE_SOUND_ENABLED"],  desc = L["CACHE_SOUND_ENABLED_DESC"],  dbKey = "cacheSoundEnabled",  get = function() return getDB("cacheSoundEnabled",  addon.CACHE_DEFAULTS.cacheSoundEnabled)  end, set = function(v) setDB("cacheSoundEnabled",  v) end },
            { type = "dropdown", name = L["CACHE_SOUND_CHANNEL"], desc = L["CACHE_SOUND_CHANNEL_DESC"], dbKey = "cacheSoundChannel",
                options = {
                    { L["CACHE_SOUND_CH_SFX"],      "SFX"      },
                    { L["CACHE_SOUND_CH_MASTER"],   "Master"   },
                    { L["CACHE_SOUND_CH_DIALOG"],   "Dialog"   },
                    { L["CACHE_SOUND_CH_AMBIENCE"], "Ambience" },
                    { L["CACHE_SOUND_CH_MUSIC"],    "Music"    },
                },
                get = function() return getDB("cacheSoundChannel", addon.CACHE_DEFAULTS.cacheSoundChannel) end,
                set = function(v) setDB("cacheSoundChannel", v) end,
                visibleWhen = function() return getDB("cacheSoundEnabled", addon.CACHE_DEFAULTS.cacheSoundEnabled) ~= false end,
            },
            { type = "toggle", name = L["CACHE_SOUND_ITEMS"],    desc = L["CACHE_SOUND_ITEMS_DESC"],    dbKey = "cacheSoundItems",    get = function() return getDB("cacheSoundItems",    addon.CACHE_DEFAULTS.cacheSoundItems)    end, set = function(v) setDB("cacheSoundItems",    v) end, visibleWhen = function() return getDB("cacheSoundEnabled", addon.CACHE_DEFAULTS.cacheSoundEnabled) ~= false end },
            { type = "toggle", name = L["CACHE_SOUND_MONEY"],    desc = L["CACHE_SOUND_MONEY_DESC"],    dbKey = "cacheSoundMoney",    get = function() return getDB("cacheSoundMoney",    addon.CACHE_DEFAULTS.cacheSoundMoney)    end, set = function(v) setDB("cacheSoundMoney",    v) end, visibleWhen = function() return getDB("cacheSoundEnabled", addon.CACHE_DEFAULTS.cacheSoundEnabled) ~= false end },
            { type = "toggle", name = L["CACHE_SOUND_CURRENCY"], desc = L["CACHE_SOUND_CURRENCY_DESC"], dbKey = "cacheSoundCurrency", get = function() return getDB("cacheSoundCurrency", addon.CACHE_DEFAULTS.cacheSoundCurrency) end, set = function(v) setDB("cacheSoundCurrency", v) end, visibleWhen = function() return getDB("cacheSoundEnabled", addon.CACHE_DEFAULTS.cacheSoundEnabled) ~= false end },
            { type = "toggle", name = L["CACHE_SOUND_REP"],      desc = L["CACHE_SOUND_REP_DESC"],      dbKey = "cacheSoundRep",      get = function() return getDB("cacheSoundRep",      addon.CACHE_DEFAULTS.cacheSoundRep)      end, set = function(v) setDB("cacheSoundRep",      v) end, visibleWhen = function() return getDB("cacheSoundEnabled", addon.CACHE_DEFAULTS.cacheSoundEnabled) ~= false end },
        },
    },
    {
        key = "CacheTypography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["CACHE_TYPOGRAPHY_PAGE_DESC"],
        moduleKey = "cache",
        options = {
            { type = "section", name = L["DASH_TYPOGRAPHY"] },
            { type = "toggle", name = L["CACHE_TEXT_OUTLINE"], desc = L["CACHE_TEXT_OUTLINE_DESC"], dbKey = "cacheTextOutline",
                get = function() return getDB("cacheTextOutline", addon.CACHE_DEFAULTS.cacheTextOutline) ~= false end,
                set = function(v) setDB("cacheTextOutline", v) end,
            },
            { type = "slider", name = L["CACHE_FONT_SIZE"], desc = L["CACHE_FONT_SIZE_DESC"], dbKey = "cacheFontSize",
                min = 8, max = 28, step = 1,
                get = function() return math.max(8, math.min(28, tonumber(getDB("cacheFontSize", addon.CACHE_DEFAULTS.cacheFontSize)) or addon.CACHE_DEFAULTS.cacheFontSize)) end,
                set = function(v) setDB("cacheFontSize", math.max(8, math.min(28, v))) end,
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
            { type = "section", name = L["CACHE_PREVIEW_SECTION"] },
            { type = "button", name = L["CACHE_PREVIEW"], desc = L["CACHE_PREVIEW_DESC"], onClick = function()
                if addon.Cache and addon.Cache.PreviewToasts then addon.Cache.PreviewToasts() end
            end },
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
