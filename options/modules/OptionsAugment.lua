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
    -- ── Loot Frame ──────────────────────────────────────────────────────────
    {
        key = "AugmentImprovements",
        name = L["AUGMENT_IMPROVEMENTS"],
        desc = L["AUGMENT_IMPROVEMENTS_PAGE_DESC"],
        moduleKey = "augment",
        icon = "inv_misc_coin_01",
        accentColor = { 0.95, 0.75, 0.20 },
        -- Mini-module master toggle (sidebar visibility + live activation).
        enabledKey = "augmentLootFrameEnabled",
        getEnabled = function() return getDB("augmentLootFrameEnabled", true) ~= false end,
        setEnabled = function(v)
            v = v and true or false
            setDB("augmentLootFrameEnabled", v)
            if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
            local Y = addon.Augment
            if not Y then return end
            if v then
                if Y.EnableEvents then Y.EnableEvents() end
                if Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
            else
                if Y.DisableEvents then Y.DisableEvents() end
                if Y.RestoreBlizzard then Y.RestoreBlizzard() end
                if Y.ClearActiveToasts then Y.ClearActiveToasts() end
            end
        end,
        options = {
            -- Toast Settings (two-column: Visibility | Toast Types)
            Section(L["AUGMENT_TOAST_SETTINGS"]),
            { type = "columns",
                left = {
                    title = L["AUGMENT_MAX_VISIBLE_SECTION"],
                    options = {
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
                        { type = "slider", name = L["AUGMENT_ICON_SIZE"], desc = L["AUGMENT_ICON_SIZE_DESC"], dbKey = "augmentIconSize",
                            min = LIM.augmentIconSize.min, max = LIM.augmentIconSize.max, step = 1,
                            get = function() return getSlider("augmentIconSize") end,
                            set = function(v) setDB("augmentIconSize", clamp(v, "augmentIconSize")) end,
                        },
                        { type = "slider", name = L["AUGMENT_ICON_GAP"], desc = L["AUGMENT_ICON_GAP_DESC"], dbKey = "augmentIconGap",
                            min = LIM.augmentIconGap.min, max = LIM.augmentIconGap.max, step = 1,
                            get = function() return getSlider("augmentIconGap") end,
                            set = function(v) setDB("augmentIconGap", clamp(v, "augmentIconGap")) end,
                        },
                        { type = "dropdown",
                            name = L["AUGMENT_ICON_SIDE"], desc = L["AUGMENT_ICON_SIDE_DESC"],
                            dbKey = "augmentIconSide",
                            options = {
                                { L["AUGMENT_LAYOUT_LEFT"],  "left"  },
                                { L["AUGMENT_LAYOUT_RIGHT"], "right" },
                            },
                            get = function() return getDB("augmentIconSide", D.augmentIconSide) end,
                            set = function(v) setDB("augmentIconSide", v) end,
                            preserveOrder = true,
                        },
                        { type = "dropdown",
                            name = L["AUGMENT_SLIDE_SIDE"], desc = L["AUGMENT_SLIDE_SIDE_DESC"],
                            dbKey = "augmentSlideSide",
                            options = {
                                { L["AUGMENT_LAYOUT_LEFT"],  "left"  },
                                { L["AUGMENT_LAYOUT_RIGHT"], "right" },
                            },
                            get = function() return getDB("augmentSlideSide", D.augmentSlideSide) end,
                            set = function(v) setDB("augmentSlideSide", v) end,
                            preserveOrder = true,
                        },
                        { type = "dropdown",
                            name = L["AUGMENT_GROW_DIRECTION"], desc = L["AUGMENT_GROW_DIRECTION_DESC"],
                            dbKey = "augmentGrowDirection",
                            options = {
                                { L["AUGMENT_LAYOUT_UP"],   "up"   },
                                { L["AUGMENT_LAYOUT_DOWN"], "down" },
                            },
                            get = function() return getDB("augmentGrowDirection", D.augmentGrowDirection) end,
                            set = function(v) setDB("augmentGrowDirection", v) end,
                            preserveOrder = true,
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
                        { type = "slider", name = L["AUGMENT_FONT_SIZE"], desc = L["AUGMENT_FONT_SIZE_DESC"], dbKey = "augmentFontSize",
                            min = LIM.augmentFontSize.min, max = LIM.augmentFontSize.max, step = 1,
                            get = function() return getSlider("augmentFontSize") end,
                            set = function(v) setDB("augmentFontSize", clamp(v, "augmentFontSize")) end,
                        },
                        { type = "dropdown",
                            name = L["AUGMENT_TEXT_OUTLINE_TYPE"], desc = L["AUGMENT_TEXT_OUTLINE_TYPE_DESC"],
                            dbKey = "augmentTextOutlineType",
                            options = addon.OUTLINE_OPTIONS,
                            get = function() return getDB("augmentTextOutlineType", D.augmentTextOutlineType) end,
                            set = function(v) setDB("augmentTextOutlineType", v) end,
                        },
                        Toggle(L["AUGMENT_SUPPRESS_BLIZZARD"], L["AUGMENT_SUPPRESS_BLIZZARD_DESC"], "augmentSuppressBlizzard", D.augmentSuppressBlizzard),
                    },
                },
                right = {
                    title = L["AUGMENT_TOAST_TYPES"],
                    options = {
                        Toggle(L["AUGMENT_SHOW_ITEMS"],        L["AUGMENT_SHOW_ITEMS_DESC"],        "augmentShowItems",       D.augmentShowItems,       { refreshIds = { "augmentMinQuality", "augmentShowPushedItems" } }),
                        Toggle(L["AUGMENT_SHOW_PUSHED_ITEMS"], L["AUGMENT_SHOW_PUSHED_ITEMS_DESC"], "augmentShowPushedItems", D.augmentShowPushedItems, { disabled = function() return getDB("augmentShowItems", D.augmentShowItems) == false end }),
                        Toggle(L["AUGMENT_SHOW_MONEY"],    L["AUGMENT_SHOW_MONEY_DESC"],    "augmentShowMoney",    D.augmentShowMoney),
                        Toggle(L["AUGMENT_SHOW_CURRENCY"], L["AUGMENT_SHOW_CURRENCY_DESC"], "augmentShowCurrency", D.augmentShowCurrency),
                        Toggle(L["AUGMENT_SHOW_REP"],      L["AUGMENT_SHOW_REP_DESC"],      "augmentShowRep",      D.augmentShowRep),
                    },
                },
            },

            -- Style (two-column: Stacking | Hold Durations)
            Section(L["AUGMENT_STYLE_SECTION"]),
            { type = "columns",
                left = {
                    options = {
                        { type = "section", name = L["AUGMENT_STACKING_SECTION"] },
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
                    },
                },
                right = {
                    title = L["AUGMENT_HOLD_DURATIONS"],
                    options = {
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
            },

            -- Sounds
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

    -- ── Achievement Tracker ──────────────────────────────────────────────────
    {
        key = "AugmentAchievementTracker",
        name = L["AUGMENT_ACHIEVEMENT_TRACKER"],
        desc = L["AUGMENT_ACHIEVEMENT_TRACKER_DESC"],
        icon = 236668,  -- Achievement_General (gold star)
        accentColor = { 1.0, 0.82, 0.0 },
        moduleKey = "augment",
        hidden = function() return addon.IsModuleEnabled and addon:IsModuleEnabled("focus") end,
        enabledKey = "augmentAchievementTrackerEnabled",
        getEnabled = function() return getDB("augmentAchievementTrackerEnabled", D.augmentAchievementTrackerEnabled) ~= false end,
        setEnabled = function(v)
            v = v and true or false
            setDB("augmentAchievementTrackerEnabled", v)
            if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
            local AT = addon.Augment and addon.Augment.AchievementTracker
            if not AT then return end
            if v then AT.Enable() else AT.Disable() end
        end,
        options = function() return {} end,
    },

    -- ── Auto Vendor ─────────────────────────────────────────────────────────
    {
        key = "AugmentVendor",
        name = L["AUGMENT_VENDOR"],
        desc = L["AUGMENT_VENDOR_DESC"],
        icon = "inv_misc_bag_17",
        accentColor = { 0.25, 0.78, 1.0 },
        moduleKey = "augment",
        enabledKey = "augmentVendorEnabled",
        getEnabled = function() return getDB("augmentVendorEnabled", D.augmentVendorEnabled) ~= false end,
        setEnabled = function(v)
            v = v and true or false
            setDB("augmentVendorEnabled", v)
            if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
            local V = addon.Augment and addon.Augment.Vendor
            if not V then return end
            if v then V.Enable() else V.Disable() end
        end,
        options = function()
            local function sellerDisabled() return not getDB("autoSellerEnabled", D.autoSellerEnabled) end
            local function repairDisabled() return not getDB("autoRepairEnabled", D.autoRepairEnabled) end
            local verbosityOptions = {
                { L["AUGMENT_VENDOR_VERBOSITY_SILENT"],  "none"    },
                { L["AUGMENT_VENDOR_VERBOSITY_SUMMARY"], "summary" },
            }
            return {
                Section(L["AUGMENT_VENDOR_SELLER_SECTION"]),
                Toggle(L["AUGMENT_VENDOR_SELLER_ENABLE"],        L["AUGMENT_VENDOR_SELLER_ENABLE_DESC"],        "autoSellerEnabled",  D.autoSellerEnabled),
                Toggle(L["AUGMENT_VENDOR_SELLER_GREY"],          L["AUGMENT_VENDOR_SELLER_GREY_DESC"],          "autoSellerGrey",     D.autoSellerGrey,     { disabled = sellerDisabled }),
                Toggle(L["AUGMENT_VENDOR_SELLER_UNUSABLE"],      L["AUGMENT_VENDOR_SELLER_UNUSABLE_DESC"],      "autoSellerUnusable",  D.autoSellerUnusable,  { disabled = sellerDisabled }),
                Toggle(L["AUGMENT_VENDOR_SELLER_NONOPTIMAL"],    L["AUGMENT_VENDOR_SELLER_NONOPTIMAL_DESC"],    "autoSellerNonOptimal", D.autoSellerNonOptimal, { disabled = sellerDisabled }),
                Toggle(L["AUGMENT_VENDOR_SELLER_LOW_LEVEL"],     L["AUGMENT_VENDOR_SELLER_LOW_LEVEL_DESC"],     "autoSellerLowLevel",  D.autoSellerLowLevel,  { disabled = sellerDisabled, refreshIds = { "autoSellerLowLevelThreshold" } }),
                { type = "slider",
                    name     = L["AUGMENT_VENDOR_SELLER_LOW_LEVEL_THRESHOLD"],
                    desc     = L["AUGMENT_VENDOR_SELLER_LOW_LEVEL_THRESHOLD_DESC"],
                    dbKey    = "autoSellerLowLevelThreshold",
                    min = LIM.autoSellerLowLevelThreshold.min, max = LIM.autoSellerLowLevelThreshold.max, step = 1,
                    get = function() return getSlider("autoSellerLowLevelThreshold") end,
                    set = function(v) setDB("autoSellerLowLevelThreshold", clamp(v, "autoSellerLowLevelThreshold")) end,
                    disabled = function() return sellerDisabled() or not getDB("autoSellerLowLevel", D.autoSellerLowLevel) end,
                },
                Toggle(L["AUGMENT_VENDOR_SELLER_FORTUNE_CARDS"], L["AUGMENT_VENDOR_SELLER_FORTUNE_CARDS_DESC"], "autoSellerFortuneCards", D.autoSellerFortuneCards, { disabled = sellerDisabled }),
                Toggle(L["AUGMENT_VENDOR_SELLER_LEGION_RELICS"], L["AUGMENT_VENDOR_SELLER_LEGION_RELICS_DESC"], "autoSellerLegionRelics",  D.autoSellerLegionRelics,  { disabled = sellerDisabled }),
                { type = "dropdown",
                    name     = L["AUGMENT_VENDOR_VERBOSITY"],
                    desc     = L["AUGMENT_VENDOR_VERBOSITY_DESC"],
                    dbKey    = "autoSellerVerbosity",
                    disabled = sellerDisabled,
                    options  = verbosityOptions,
                    get = function() return getDB("autoSellerVerbosity", D.autoSellerVerbosity) end,
                    set = function(v) setDB("autoSellerVerbosity", v) end,
                },

                Section(L["AUGMENT_VENDOR_REPAIR_SECTION"]),
                Toggle(L["AUGMENT_VENDOR_REPAIR_ENABLE"],     L["AUGMENT_VENDOR_REPAIR_ENABLE_DESC"],     "autoRepairEnabled",  D.autoRepairEnabled),
                Toggle(L["AUGMENT_VENDOR_REPAIR_GUILDBANK"],  L["AUGMENT_VENDOR_REPAIR_GUILDBANK_DESC"],  "autoRepairGuildBank", D.autoRepairGuildBank, { disabled = repairDisabled }),
                { type = "dropdown",
                    name     = L["AUGMENT_VENDOR_VERBOSITY"],
                    desc     = L["AUGMENT_VENDOR_VERBOSITY_DESC"],
                    dbKey    = "autoRepairVerbosity",
                    disabled = repairDisabled,
                    options  = verbosityOptions,
                    get = function() return getDB("autoRepairVerbosity", D.autoRepairVerbosity) end,
                    set = function(v) setDB("autoRepairVerbosity", v) end,
                },
            }
        end,
    },

    -- ── Self Highlight ───────────────────────────────────────────────────────
    {
        key = "AugmentSelfHighlight",
        name = L["AUGMENT_SELF_HIGHLIGHT"],
        desc = L["AUGMENT_SELF_HIGHLIGHT_DESC"],
        icon = 237570,
        accentColor = { 0.70, 0.40, 1.0 },
        moduleKey = "augment",
        enabledKey = "augmentSelfHighlightEnabled",
        getEnabled = function() return getDB("augmentSelfHighlightEnabled", D.augmentSelfHighlightEnabled) ~= false end,
        setEnabled = function(v)
            v = v and true or false
            setDB("augmentSelfHighlightEnabled", v)
            if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
            local SH = addon.Augment and addon.Augment.SelfHighlight
            if not SH then return end
            if v then SH.Enable() else SH.Disable() end
        end,
        options = function()
            return {
                Section(L["AUGMENT_SELF_HIGHLIGHT_BEHAVIOUR"]),
                { type = "dropdown",
                    name     = L["AUGMENT_SELF_HIGHLIGHT_MODE"],
                    desc     = L["AUGMENT_SELF_HIGHLIGHT_MODE_DESC"],
                    dbKey    = "selfHighlightMode",
                    options  = function()
                        return {
                            { L["AUGMENT_SELF_HIGHLIGHT_MODE_OUTLINECIRCLE"], "outlinecircle" },
                            { L["AUGMENT_SELF_HIGHLIGHT_MODE_OUTLINEICON"],   "outlineicon"   },
                            { L["AUGMENT_SELF_HIGHLIGHT_MODE_OUTLINE"],       "outline"       },
                            { L["AUGMENT_SELF_HIGHLIGHT_MODE_CIRCLE"],        "circle"        },
                            { L["AUGMENT_SELF_HIGHLIGHT_MODE_ICON"],          "icon"          },
                        }
                    end,
                    get = function() return getDB("selfHighlightMode", D.selfHighlightMode) end,
                    set = function(v) setDB("selfHighlightMode", v) end,
                },
                { type = "toggle",
                    name  = L["AUGMENT_SELF_HIGHLIGHT_HOSTILE"],
                    desc  = L["AUGMENT_SELF_HIGHLIGHT_HOSTILE_DESC"],
                    dbKey = "selfHighlightHostile",
                    get = function() return getDB("selfHighlightHostile", D.selfHighlightHostile) end,
                    set = function(v)
                        setDB("selfHighlightHostile", v)
                        local SH = addon.Augment and addon.Augment.SelfHighlight
                        if SH then SH.Evaluate() end
                    end,
                },
            }
        end,
    },

}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end