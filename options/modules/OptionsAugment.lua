--[[
    Horizon Suite - Augment - Options categories
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
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end
local function getSlider(key)
    local lim = LIM[key]
    local v = tonumber(getDB(key, D[key])) or D[key]
    return math.max(lim.min, math.min(lim.max, v))
end

local categories = {
    {
        key = "AugmentGeneral",
        name = L["AXIS_GENERAL"],
        desc = L["POSITIONING_VISIBILITY_AUGMENT_LOOT_TOAST_SYS"],
        moduleKey = "augment",
        options = {
            Section(L["DASH_APPEARANCE"]),
            { type = "slider", name = L["AUGMENT_ICON_SIZE"], desc = L["AUGMENT_ICON_SIZE_DESC"], dbKey = "augmentIconSize",
                min = LIM.augmentIconSize.min, max = LIM.augmentIconSize.max, step = 1,
                get = function() return getSlider("augmentIconSize") end,
                set = function(v) setDB("augmentIconSize", clamp(v, "augmentIconSize")) end,
            },
            Section(L["AXIS_POSITION"]),
            Button(L["AXIS_ANCHOR_MOVE"], L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"], function()
                if addon.Augment and addon.Augment.ToggleAnchorFrame then addon.Augment.ToggleAnchorFrame() end
            end),
            Button(L["AXIS_RESET_POSITION"], L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"], function()
                if addon.Augment and addon.Augment.ResetPosition then addon.Augment.ResetPosition() end
            end),
            Section(L["AUGMENT_MAX_VISIBLE_SECTION"]),
            { type = "slider", name = L["AUGMENT_TOAST_OPACITY"], desc = L["AUGMENT_TOAST_OPACITY_DESC"], dbKey = "augmentToastOpacity",
                min = LIM.augmentToastOpacity.min, max = LIM.augmentToastOpacity.max, step = 5,
                get = function() return getSlider("augmentToastOpacity") end,
                set = function(v) setDB("augmentToastOpacity", clamp(v, "augmentToastOpacity")) end,
            },
            { type = "slider", name = L["AUGMENT_MAX_VISIBLE"], desc = L["AUGMENT_MAX_VISIBLE_DESC"], dbKey = "augmentMaxVisible",
                min = LIM.augmentMaxVisible.min, max = LIM.augmentMaxVisible.max, step = 1,
                get = function() return getSlider("augmentMaxVisible") end,
                set = function(v) setDB("augmentMaxVisible", clamp(v, "augmentMaxVisible")) end,
            },
            { type = "slider", name = L["AUGMENT_TOAST_SCALE"], desc = L["AUGMENT_TOAST_SCALE_DESC"], dbKey = "augmentUIScale",
                min = LIM.augmentUIScale.min, max = LIM.augmentUIScale.max, step = 0.05,
                get = function() return getSlider("augmentUIScale") end,
                set = function(v) setDB("augmentUIScale", clamp(v, "augmentUIScale")) end,
            },
        },
    },
    {
        key = "AugmentToastTypes",
        name = L["AUGMENT_TOAST_TYPES"],
        desc = L["AUGMENT_TOAST_TYPES_PAGE_DESC"],
        moduleKey = "augment",
        options = {
            Section(L["AUGMENT_TOAST_TYPES"]),
            Toggle(L["AUGMENT_SHOW_ITEMS"],        L["AUGMENT_SHOW_ITEMS_DESC"],        "augmentShowItems",        D.augmentShowItems,        { refreshIds = { "augmentMinQuality", "augmentShowPushedItems" } }),
            Toggle(L["AUGMENT_SHOW_PUSHED_ITEMS"], L["AUGMENT_SHOW_PUSHED_ITEMS_DESC"], "augmentShowPushedItems",  D.augmentShowPushedItems,  { disabled = function() return getDB("augmentShowItems", D.augmentShowItems) == false end }),
            Toggle(L["AUGMENT_SHOW_MONEY"],    L["AUGMENT_SHOW_MONEY_DESC"],    "augmentShowMoney",    D.augmentShowMoney),
            Toggle(L["AUGMENT_SHOW_CURRENCY"], L["AUGMENT_SHOW_CURRENCY_DESC"], "augmentShowCurrency", D.augmentShowCurrency),
            Toggle(L["AUGMENT_SHOW_REP"],      L["AUGMENT_SHOW_REP_DESC"],      "augmentShowRep",      D.augmentShowRep),
            Section(L["AUGMENT_STACKING_SECTION"]),
            Toggle(L["AUGMENT_STACK_DUPLICATES"],        L["AUGMENT_STACK_DUPLICATES_DESC"],        "augmentStackDuplicates",      D.augmentStackDuplicates),
            Toggle(L["AUGMENT_STACK_COUNT_BEFORE_NAME"], L["AUGMENT_STACK_COUNT_BEFORE_NAME_DESC"], "augmentStackCountBeforeName", D.augmentStackCountBeforeName),
            Toggle(L["AUGMENT_CONDENSE_JUNK"],           L["AUGMENT_CONDENSE_JUNK_DESC"],           "augmentCondenseJunk",         D.augmentCondenseJunk,    { disabled = function() return getDB("augmentShowItems", D.augmentShowItems) == false end }),
            { type = "dropdown", name = L["AUGMENT_MIN_QUALITY"], desc = L["AUGMENT_MIN_QUALITY_DESC"], dbKey = "augmentMinQuality",
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
                get = function() return tonumber(getDB("augmentMinQuality", D.augmentMinQuality)) or D.augmentMinQuality end,
                set = function(v) setDB("augmentMinQuality", v) end,
                disabled = function() return getDB("augmentShowItems", D.augmentShowItems) == false end,
            },
            Section(L["AUGMENT_BLIZZARD_SECTION"]),
            Toggle(L["AUGMENT_SUPPRESS_BLIZZARD"], L["AUGMENT_SUPPRESS_BLIZZARD_DESC"], "augmentSuppressBlizzard", D.augmentSuppressBlizzard),
        },
    },
    {
        key = "AugmentDurations",
        name = L["AUGMENT_HOLD_DURATIONS"],
        desc = L["AUGMENT_HOLD_DURATIONS_PAGE_DESC"],
        moduleKey = "augment",
        options = {
            Section(L["AUGMENT_HOLD_DURATIONS"]),
            { type = "slider", name = L["AUGMENT_HOLD_ITEM"],      desc = L["AUGMENT_HOLD_ITEM_DESC"],      dbKey = "augmentHoldItem",
                min = LIM.augmentHoldItem.min, max = LIM.augmentHoldItem.max, step = 0.5,
                get = function() return getSlider("augmentHoldItem") end,
                set = function(v) setDB("augmentHoldItem", clamp(v, "augmentHoldItem")) end,
                disabled = function()
                    local minQ = tonumber(getDB("augmentMinQuality", D.augmentMinQuality)) or 0
                    return getDB("augmentShowItems", D.augmentShowItems) == false or minQ > 3
                end,
            },
            { type = "slider", name = L["AUGMENT_HOLD_EPIC"],      desc = L["AUGMENT_HOLD_EPIC_DESC"],      dbKey = "augmentHoldEpic",
                min = LIM.augmentHoldEpic.min, max = LIM.augmentHoldEpic.max, step = 0.5,
                get = function() return getSlider("augmentHoldEpic") end,
                set = function(v) setDB("augmentHoldEpic", clamp(v, "augmentHoldEpic")) end,
                disabled = function()
                    local minQ = tonumber(getDB("augmentMinQuality", D.augmentMinQuality)) or 0
                    return getDB("augmentShowItems", D.augmentShowItems) == false or minQ > 4
                end,
            },
            { type = "slider", name = L["AUGMENT_HOLD_LEGENDARY"], desc = L["AUGMENT_HOLD_LEGENDARY_DESC"], dbKey = "augmentHoldLegendary",
                min = LIM.augmentHoldLegendary.min, max = LIM.augmentHoldLegendary.max, step = 0.5,
                get = function() return getSlider("augmentHoldLegendary") end,
                set = function(v) setDB("augmentHoldLegendary", clamp(v, "augmentHoldLegendary")) end,
                disabled = function() return getDB("augmentShowItems", D.augmentShowItems) == false end,
            },
            { type = "slider", name = L["AUGMENT_HOLD_MONEY"],    desc = L["AUGMENT_HOLD_MONEY_DESC"],    dbKey = "augmentHoldMoney",
                min = LIM.augmentHoldMoney.min, max = LIM.augmentHoldMoney.max, step = 0.5,
                get = function() return getSlider("augmentHoldMoney") end,
                set = function(v) setDB("augmentHoldMoney", clamp(v, "augmentHoldMoney")) end,
                disabled = function() return getDB("augmentShowMoney", D.augmentShowMoney) == false end,
            },
            { type = "slider", name = L["AUGMENT_HOLD_CURRENCY"], desc = L["AUGMENT_HOLD_CURRENCY_DESC"], dbKey = "augmentHoldCurrency",
                min = LIM.augmentHoldCurrency.min, max = LIM.augmentHoldCurrency.max, step = 0.5,
                get = function() return getSlider("augmentHoldCurrency") end,
                set = function(v) setDB("augmentHoldCurrency", clamp(v, "augmentHoldCurrency")) end,
                disabled = function() return getDB("augmentShowCurrency", D.augmentShowCurrency) == false end,
            },
            { type = "slider", name = L["AUGMENT_HOLD_REP"],      desc = L["AUGMENT_HOLD_REP_DESC"],      dbKey = "augmentHoldRep",
                min = LIM.augmentHoldRep.min, max = LIM.augmentHoldRep.max, step = 0.5,
                get = function() return getSlider("augmentHoldRep") end,
                set = function(v) setDB("augmentHoldRep", clamp(v, "augmentHoldRep")) end,
                disabled = function() return getDB("augmentShowRep", D.augmentShowRep) == false end,
            },
        },
    },
    {
        key = "AugmentSounds",
        name = L["AUGMENT_SOUNDS"],
        desc = L["AUGMENT_SOUNDS_PAGE_DESC"],
        moduleKey = "augment",
        options = {
            Section(L["AUGMENT_SOUNDS"]),
            Toggle(L["AUGMENT_SOUND_ENABLED"], L["AUGMENT_SOUND_ENABLED_DESC"], "augmentSoundEnabled", D.augmentSoundEnabled),
            { type = "dropdown", name = L["AUGMENT_SOUND_CHANNEL"], desc = L["AUGMENT_SOUND_CHANNEL_DESC"], dbKey = "augmentSoundChannel",
                options = {
                    { L["AUGMENT_SOUND_CH_SFX"],      "SFX"      },
                    { L["AUGMENT_SOUND_CH_MASTER"],   "Master"   },
                    { L["AUGMENT_SOUND_CH_DIALOG"],   "Dialog"   },
                    { L["AUGMENT_SOUND_CH_AMBIENCE"], "Ambience" },
                    { L["AUGMENT_SOUND_CH_MUSIC"],    "Music"    },
                },
                get = function() return getDB("augmentSoundChannel", D.augmentSoundChannel) end,
                set = function(v) setDB("augmentSoundChannel", v) end,
                visibleWhen = function() return getDB("augmentSoundEnabled", D.augmentSoundEnabled) ~= false end,
            },
            Toggle(L["AUGMENT_SOUND_ITEMS"],    L["AUGMENT_SOUND_ITEMS_DESC"],    "augmentSoundItems",    D.augmentSoundItems,    { visibleWhen = function() return getDB("augmentSoundEnabled", D.augmentSoundEnabled) ~= false end }),
            Toggle(L["AUGMENT_SOUND_MONEY"],    L["AUGMENT_SOUND_MONEY_DESC"],    "augmentSoundMoney",    D.augmentSoundMoney,    { visibleWhen = function() return getDB("augmentSoundEnabled", D.augmentSoundEnabled) ~= false end }),
            Toggle(L["AUGMENT_SOUND_CURRENCY"], L["AUGMENT_SOUND_CURRENCY_DESC"], "augmentSoundCurrency", D.augmentSoundCurrency, { visibleWhen = function() return getDB("augmentSoundEnabled", D.augmentSoundEnabled) ~= false end }),
            Toggle(L["AUGMENT_SOUND_REP"],      L["AUGMENT_SOUND_REP_DESC"],      "augmentSoundRep",      D.augmentSoundRep,      { visibleWhen = function() return getDB("augmentSoundEnabled", D.augmentSoundEnabled) ~= false end }),
        },
    },
    {
        key = "AugmentTypography",
        name = L["DASH_TYPOGRAPHY"],
        desc = L["AUGMENT_TYPOGRAPHY_PAGE_DESC"],
        moduleKey = "augment",
        options = {
            Section(L["DASH_TYPOGRAPHY"]),
            { type = "toggle", name = L["AUGMENT_TEXT_OUTLINE"], desc = L["AUGMENT_TEXT_OUTLINE_DESC"], dbKey = "augmentTextOutline",
                get = function() return getDB("augmentTextOutline", D.augmentTextOutline) ~= false end,
                set = function(v) setDB("augmentTextOutline", v) end,
            },
            { type = "slider", name = L["AUGMENT_FONT_SIZE"], desc = L["AUGMENT_FONT_SIZE_DESC"], dbKey = "augmentFontSize",
                min = LIM.augmentFontSize.min, max = LIM.augmentFontSize.max, step = 1,
                get = function() return getSlider("augmentFontSize") end,
                set = function(v) setDB("augmentFontSize", clamp(v, "augmentFontSize")) end,
            },
            { type = "dropdown",
                name = L["AUGMENT_FONT"],
                desc = L["AUGMENT_FONT_FAMILY"],
                dbKey = "augmentFontPath",
                searchable = true,
                options = function() return GetPerElementFontDropdownOptions("augmentFontPath") end,
                get = function() return getDB("augmentFontPath", FONT_USE_GLOBAL) end,
                set = function(v) setDB("augmentFontPath", v) end,
                displayFn = DisplayPerElementFont,
                fontPreviewInList = true,
            },
        },
    },
    {
        key = "AugmentPreview",
        name = L["AUGMENT_PREVIEW_SECTION"],
        desc = L["AUGMENT_PREVIEW_PAGE_DESC"],
        moduleKey = "augment",
        options = {
            Section(L["AUGMENT_PREVIEW_SECTION"]),
            Button(L["AUGMENT_PREVIEW"], L["AUGMENT_PREVIEW_DESC"], function()
                if addon.Augment and addon.Augment.PreviewToasts then addon.Augment.PreviewToasts() end
            end),
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
