--[[
    Horizon Suite - Cache - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local FONT_USE_GLOBAL              = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont        = addon.DisplayPerElementFont

local categories = {
    {
        key = "CacheGeneral",
        name = L["AXIS_GENERAL"],
        desc = L["POSITIONING_VISIBILITY_CACHE_LOOT_TOAST_SYS"] or "Positioning and visibility for the Cache loot toast system.",
        moduleKey = "cache",
        options = {
            { type = "section", name = L["AXIS_POSITION"] },
            { type = "button", name = L["AXIS_ANCHOR_MOVE"] or "Show anchor to move", desc = L["AXIS_CLICK_HIDE_ANCHOR_DRAG_POSITION"] or "Click to show or hide the anchor. Drag to set position, right-click to confirm.", onClick = function()
                if addon.Cache and addon.Cache.ToggleAnchorFrame then addon.Cache.ToggleAnchorFrame() end
            end },
            { type = "button", name = L["AXIS_RESET_POSITION"], desc = L["AXIS_RESET_LOOT_TOAST_POSITION_DEFAULT"], onClick = function()
                if addon.Cache and addon.Cache.ResetPosition then addon.Cache.ResetPosition() end
            end },
            { type = "section", name = L["DASH_TYPOGRAPHY"] or "Typography" },
            { type = "dropdown",
                name = L["CACHE_FONT"] or "Loot toast font",
                desc = L["CACHE_FONT_FAMILY"] or "Font family used for loot toast text. Use 'Use global font' to follow the addon-wide font.",
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
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
