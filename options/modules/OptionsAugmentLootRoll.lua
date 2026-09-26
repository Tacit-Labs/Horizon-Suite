--[[
    Horizon Suite - Augment / Loot Roll - options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.

    On a client with no group loot the category is never registered at all (see
    the guard at the foot of this file), so nothing offers settings for a system
    that is not there. Individual rows still carry row-level `requires`, which
    options/OptionsPlatform.lua prunes in the normal way.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L   = addon.L
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local function clamp(v, key)
    local lim = LIM[key]
    if not lim then return v end
    return math.max(lim.min, math.min(lim.max, v))
end

local Section = addon.Section
local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont

-- Re-apply live state after any option change. Cheap to call on every change:
-- each step early-outs when there is nothing to do.
local function applyRoll()
    local R = addon.Augment and addon.Augment.Roll
    if not R or not R.ApplyOptions then return end
    R.ApplyOptions()
end

local QUALITY_OPTIONS = {
    { L["LOOT_ROLL_QUALITY_ALL"],       0 },
    { L["LOOT_ROLL_QUALITY_UNCOMMON"],  2 },
    { L["LOOT_ROLL_QUALITY_RARE"],      3 },
    { L["LOOT_ROLL_QUALITY_EPIC"],      4 },
}

local STYLE_OPTIONS = {
    { L["AUGMENT_TOAST_STYLE_COMPACT"], "compact" },
    { L["AUGMENT_TOAST_STYLE_FRAMED"],  "framed"  },
    { L["AUGMENT_TOAST_STYLE_ACCENT"],  "accent"  },
}

local SIDE_OPTIONS = {
    { L["AUGMENT_LAYOUT_LEFT"],  "left"  },
    { L["AUGMENT_LAYOUT_RIGHT"], "right" },
}

local GROW_OPTIONS = {
    { L["AUGMENT_LAYOUT_DOWN"], "down" },
    { L["AUGMENT_LAYOUT_UP"],   "up"   },
}

local category = {
    key         = "AugmentLootRoll",
    name        = L["AUGMENT_LOOT_ROLL"],
    desc        = L["AUGMENT_LOOT_ROLL_PAGE_DESC"],
    icon        = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
    accentColor = { 0.95, 0.65, 0.25 },
    moduleKey   = "augment",
    enabledKey  = "augmentLootRollEnabled",
    getEnabled  = function() return getDB("augmentLootRollEnabled", D.augmentLootRollEnabled) ~= false end,
    setEnabled  = function(v)
        v = v and true or false
        setDB("augmentLootRollEnabled", v)
        if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
        local R = addon.Augment and addon.Augment.Roll
        if not R then return end
        if v then R.Enable() else R.Disable() end
    end,
    options = {
        Section(L["LOOT_ROLL_PREVIEW"]),
        { type = "button",
          name = L["LOOT_ROLL_DEMO"], desc = L["LOOT_ROLL_DEMO_DESC"],
          onClick = function()
              local R = addon.Augment and addon.Augment.Roll
              if R and R.Demo then R.Demo.Run() end
          end,
        },
        { type = "button",
          name = L["LOOT_ROLL_MOVE"], desc = L["LOOT_ROLL_MOVE_DESC"],
          onClick = function()
              local R = addon.Augment and addon.Augment.Roll
              if R and R.ToggleEditMode then R.ToggleEditMode() end
          end,
        },

        Section(L["LOOT_ROLL_INFORMATION"]),
        { type = "columns",
            left = {
                options = {
                    { type = "toggle",
                      name = L["LOOT_ROLL_SHOW_TALLY"], desc = L["LOOT_ROLL_SHOW_TALLY_DESC"],
                      dbKey = "lootRollShowTally",
                      requires = "lootHistory",
                      get = function() return getDB("lootRollShowTally", D.lootRollShowTally) end,
                      set = function(v) setDB("lootRollShowTally", v); applyRoll() end,
                    },
                    { type = "toggle",
                      name = L["LOOT_ROLL_BADGE_APPEARANCE"], desc = L["LOOT_ROLL_BADGE_APPEARANCE_DESC"],
                      dbKey = "lootRollShowBadgeAppearance",
                      requires = "transmog",
                      get = function() return getDB("lootRollShowBadgeAppearance", D.lootRollShowBadgeAppearance) end,
                      set = function(v) setDB("lootRollShowBadgeAppearance", v); applyRoll() end,
                    },
                },
            },
            right = {
                options = {
                    { type = "toggle",
                      name = L["LOOT_ROLL_BADGE_ITEM_LEVEL"], desc = L["LOOT_ROLL_BADGE_ITEM_LEVEL_DESC"],
                      dbKey = "lootRollShowBadgeItemLevel",
                      get = function() return getDB("lootRollShowBadgeItemLevel", D.lootRollShowBadgeItemLevel) end,
                      set = function(v) setDB("lootRollShowBadgeItemLevel", v); applyRoll() end,
                    },
                    { type = "toggle",
                      name = L["LOOT_ROLL_BADGE_BIND"], desc = L["LOOT_ROLL_BADGE_BIND_DESC"],
                      dbKey = "lootRollShowBadgeBind",
                      get = function() return getDB("lootRollShowBadgeBind", D.lootRollShowBadgeBind) end,
                      set = function(v) setDB("lootRollShowBadgeBind", v); applyRoll() end,
                    },
                },
            },
        },
        { type = "dropdown",
          name = L["LOOT_ROLL_MIN_QUALITY"], desc = L["LOOT_ROLL_MIN_QUALITY_DESC"],
          dbKey = "lootRollMinQuality",
          options = QUALITY_OPTIONS,
          preserveOrder = true,
          get = function() return getDB("lootRollMinQuality", D.lootRollMinQuality) end,
          set = function(v) setDB("lootRollMinQuality", tonumber(v) or 0); applyRoll() end,
        },

        Section(L["LOOT_ROLL_APPEARANCE"]),
        { type = "columns",
            left = {
                options = {
                    { type = "dropdown",
                      name = L["AUGMENT_TOAST_STYLE"], desc = L["LOOT_ROLL_STYLE_DESC"],
                      dbKey = "lootRollToastStyle",
                      options = STYLE_OPTIONS, preserveOrder = true,
                      get = function() return getDB("lootRollToastStyle", D.lootRollToastStyle) end,
                      set = function(v) setDB("lootRollToastStyle", v); applyRoll() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ICON_SIDE"], desc = L["LOOT_ROLL_ICON_SIDE_DESC"],
                      dbKey = "lootRollIconSide",
                      options = SIDE_OPTIONS, preserveOrder = true,
                      get = function() return getDB("lootRollIconSide", D.lootRollIconSide) end,
                      set = function(v) setDB("lootRollIconSide", v); applyRoll() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_GROW_DIRECTION"], desc = L["LOOT_ROLL_GROW_DESC"],
                      dbKey = "lootRollGrowDirection",
                      options = GROW_OPTIONS, preserveOrder = true,
                      get = function() return getDB("lootRollGrowDirection", D.lootRollGrowDirection) end,
                      set = function(v) setDB("lootRollGrowDirection", v); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ICON_SIZE"], desc = L["LOOT_ROLL_ICON_SIZE_DESC"],
                      dbKey = "lootRollIconSize",
                      min = LIM.lootRollIconSize.min, max = LIM.lootRollIconSize.max,
                      get = function() return clamp(tonumber(getDB("lootRollIconSize", D.lootRollIconSize)) or D.lootRollIconSize, "lootRollIconSize") end,
                      set = function(v) setDB("lootRollIconSize", clamp(v, "lootRollIconSize")); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ICON_GAP"], desc = L["LOOT_ROLL_ICON_GAP_DESC"],
                      dbKey = "lootRollIconGap",
                      min = LIM.lootRollIconGap.min, max = LIM.lootRollIconGap.max,
                      get = function() return clamp(tonumber(getDB("lootRollIconGap", D.lootRollIconGap)) or D.lootRollIconGap, "lootRollIconGap") end,
                      set = function(v) setDB("lootRollIconGap", clamp(v, "lootRollIconGap")); applyRoll() end,
                    },
                },
            },
            right = {
                options = {
                    { type = "slider",
                      name = L["LOOT_ROLL_SCALE"], desc = L["LOOT_ROLL_SCALE_DESC"],
                      dbKey = "lootRollScale",
                      min = LIM.lootRollScale.min, max = LIM.lootRollScale.max, step = 0.05,
                      get = function() return clamp(tonumber(getDB("lootRollScale", D.lootRollScale)) or D.lootRollScale, "lootRollScale") end,
                      set = function(v) setDB("lootRollScale", clamp(v, "lootRollScale")); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_TOAST_OPACITY"], desc = L["LOOT_ROLL_OPACITY_DESC"],
                      dbKey = "lootRollOpacity",
                      min = LIM.lootRollOpacity.min, max = LIM.lootRollOpacity.max, step = 5,
                      get = function() return clamp(tonumber(getDB("lootRollOpacity", D.lootRollOpacity)) or D.lootRollOpacity, "lootRollOpacity") end,
                      set = function(v) setDB("lootRollOpacity", clamp(v, "lootRollOpacity")); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["LOOT_ROLL_WIDTH"], desc = L["LOOT_ROLL_WIDTH_DESC"],
                      dbKey = "lootRollWidth",
                      min = LIM.lootRollWidth.min, max = LIM.lootRollWidth.max, step = 10,
                      get = function() return clamp(tonumber(getDB("lootRollWidth", D.lootRollWidth)) or D.lootRollWidth, "lootRollWidth") end,
                      set = function(v) setDB("lootRollWidth", clamp(v, "lootRollWidth")); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["LOOT_ROLL_MAX_VISIBLE"], desc = L["LOOT_ROLL_MAX_VISIBLE_DESC"],
                      dbKey = "lootRollMaxVisible",
                      min = LIM.lootRollMaxVisible.min, max = LIM.lootRollMaxVisible.max,
                      get = function() return clamp(tonumber(getDB("lootRollMaxVisible", D.lootRollMaxVisible)) or D.lootRollMaxVisible, "lootRollMaxVisible") end,
                      set = function(v) setDB("lootRollMaxVisible", clamp(v, "lootRollMaxVisible")); applyRoll() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_FONT"], desc = L["LOOT_ROLL_FONT_DESC"],
                      dbKey = "lootRollFontPath",
                      options = function() return GetPerElementFontDropdownOptions("lootRollFontPath") end,
                      displayFn = DisplayPerElementFont,
                      searchable = true,
                      fontPreviewInList = true,
                      get = function() return getDB("lootRollFontPath", FONT_USE_GLOBAL) end,
                      set = function(v) setDB("lootRollFontPath", v); applyRoll() end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_FONT_SIZE"], desc = L["LOOT_ROLL_FONT_SIZE_DESC"],
                      dbKey = "lootRollFontSize",
                      min = LIM.lootRollFontSize.min, max = LIM.lootRollFontSize.max,
                      get = function() return clamp(tonumber(getDB("lootRollFontSize", D.lootRollFontSize)) or D.lootRollFontSize, "lootRollFontSize") end,
                      set = function(v) setDB("lootRollFontSize", clamp(v, "lootRollFontSize")); applyRoll() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_TEXT_OUTLINE"], desc = L["LOOT_ROLL_OUTLINE_DESC"],
                      dbKey = "lootRollTextOutlineType",
                      options = addon.OUTLINE_OPTIONS, preserveOrder = true,
                      get = function() return getDB("lootRollTextOutlineType", D.lootRollTextOutlineType) end,
                      set = function(v) setDB("lootRollTextOutlineType", v); applyRoll() end,
                    },
                },
            },
        },
    },
}

-- options/OptionsPlatform.lua prunes rows *within* a category; it has no notion
-- of a category-level capability. Rather than teach shared options infrastructure
-- a new concept for one page, a client with no group loot simply never sees this
-- category registered. Individual rows still carry their own `requires` (the
-- tally needs lootHistory, the appearance badge needs transmog), which the
-- existing prune handles.
if addon.Platform and not addon.Platform.Has("groupLootRolls") then return end

-- Insert after the last Augment category to preserve sidebar order.
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "augment" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
