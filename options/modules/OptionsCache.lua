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
local LIMITS                           = addon.CACHE_LIMITS

local function clamp(v, key) local lim = LIMITS[key]; return math.max(lim.min, math.min(lim.max, v)) end
local function getSlider(key)
    local lim = LIMITS[key]
    local v = tonumber(getDB(key, addon.CACHE_DEFAULTS[key])) or addon.CACHE_DEFAULTS[key]
    return math.max(lim.min, math.min(lim.max, v))
end

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
                min = LIMITS.cacheToastOpacity.min, max = LIMITS.cacheToastOpacity.max, step = 5,
                get = function() return getSlider("cacheToastOpacity") end,
                set = function(v) setDB("cacheToastOpacity", clamp(v, "cacheToastOpacity")) end,
            },
            { type = "slider", name = L["CACHE_MAX_VISIBLE"], desc = L["CACHE_MAX_VISIBLE_DESC"], dbKey = "cacheMaxVisible",
                min = LIMITS.cacheMaxVisible.min, max = LIMITS.cacheMaxVisible.max, step = 1,
                get = function() return getSlider("cacheMaxVisible") end,
                set = function(v) setDB("cacheMaxVisible", clamp(v, "cacheMaxVisible")) end,
            },
            { type = "slider", name = L["CACHE_TOAST_SCALE"], desc = L["CACHE_TOAST_SCALE_DESC"], dbKey = "cacheUIScale",
                min = LIMITS.cacheUIScale.min, max = LIMITS.cacheUIScale.max, step = 0.05,
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
            { type = "section", name = L["CACHE_TOAST_TYPES"] },
            { type = "toggle", name = L["CACHE_SHOW_ITEMS"],        desc = L["CACHE_SHOW_ITEMS_DESC"],        dbKey = "cacheShowItems",        get = function() return getDB("cacheShowItems",        addon.CACHE_DEFAULTS.cacheShowItems)        end, set = function(v) setDB("cacheShowItems",        v) end, refreshIds = { "cacheMinQuality", "cacheShowPushedItems" } },
            { type = "toggle", name = L["CACHE_SHOW_PUSHED_ITEMS"], desc = L["CACHE_SHOW_PUSHED_ITEMS_DESC"], dbKey = "cacheShowPushedItems", get = function() return getDB("cacheShowPushedItems", addon.CACHE_DEFAULTS.cacheShowPushedItems) end, set = function(v) setDB("cacheShowPushedItems", v) end, disabled = function() return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false end },
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
            { type = "section", name = L["CACHE_BLIZZARD_SECTION"] },
            { type = "toggle", name = L["CACHE_SUPPRESS_BLIZZARD"], desc = L["CACHE_SUPPRESS_BLIZZARD_DESC"], dbKey = "cacheSuppressBlizzard", get = function() return getDB("cacheSuppressBlizzard", addon.CACHE_DEFAULTS.cacheSuppressBlizzard) end, set = function(v) setDB("cacheSuppressBlizzard", v) end },
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
                min = LIMITS.cacheHoldItem.min, max = LIMITS.cacheHoldItem.max, step = 0.5,
                get = function() return getSlider("cacheHoldItem") end,
                set = function(v) setDB("cacheHoldItem", clamp(v, "cacheHoldItem")) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", addon.CACHE_DEFAULTS.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false or minQ > 3
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_EPIC"],      desc = L["CACHE_HOLD_EPIC_DESC"],      dbKey = "cacheHoldEpic",
                min = LIMITS.cacheHoldEpic.min, max = LIMITS.cacheHoldEpic.max, step = 0.5,
                get = function() return getSlider("cacheHoldEpic") end,
                set = function(v) setDB("cacheHoldEpic", clamp(v, "cacheHoldEpic")) end,
                disabled = function()
                    local minQ = tonumber(getDB("cacheMinQuality", addon.CACHE_DEFAULTS.cacheMinQuality)) or 0
                    return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false or minQ > 4
                end,
            },
            { type = "slider", name = L["CACHE_HOLD_LEGENDARY"], desc = L["CACHE_HOLD_LEGENDARY_DESC"], dbKey = "cacheHoldLegendary",
                min = LIMITS.cacheHoldLegendary.min, max = LIMITS.cacheHoldLegendary.max, step = 0.5,
                get = function() return getSlider("cacheHoldLegendary") end,
                set = function(v) setDB("cacheHoldLegendary", clamp(v, "cacheHoldLegendary")) end,
                disabled = function() return getDB("cacheShowItems", addon.CACHE_DEFAULTS.cacheShowItems) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_MONEY"],    desc = L["CACHE_HOLD_MONEY_DESC"],    dbKey = "cacheHoldMoney",
                min = LIMITS.cacheHoldMoney.min, max = LIMITS.cacheHoldMoney.max, step = 0.5,
                get = function() return getSlider("cacheHoldMoney") end,
                set = function(v) setDB("cacheHoldMoney", clamp(v, "cacheHoldMoney")) end,
                disabled = function() return getDB("cacheShowMoney", addon.CACHE_DEFAULTS.cacheShowMoney) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_CURRENCY"], desc = L["CACHE_HOLD_CURRENCY_DESC"], dbKey = "cacheHoldCurrency",
                min = LIMITS.cacheHoldCurrency.min, max = LIMITS.cacheHoldCurrency.max, step = 0.5,
                get = function() return getSlider("cacheHoldCurrency") end,
                set = function(v) setDB("cacheHoldCurrency", clamp(v, "cacheHoldCurrency")) end,
                disabled = function() return getDB("cacheShowCurrency", addon.CACHE_DEFAULTS.cacheShowCurrency) == false end,
            },
            { type = "slider", name = L["CACHE_HOLD_REP"],      desc = L["CACHE_HOLD_REP_DESC"],      dbKey = "cacheHoldRep",
                min = LIMITS.cacheHoldRep.min, max = LIMITS.cacheHoldRep.max, step = 0.5,
                get = function() return getSlider("cacheHoldRep") end,
                set = function(v) setDB("cacheHoldRep", clamp(v, "cacheHoldRep")) end,
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
                min = LIMITS.cacheFontSize.min, max = LIMITS.cacheFontSize.max, step = 1,
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
