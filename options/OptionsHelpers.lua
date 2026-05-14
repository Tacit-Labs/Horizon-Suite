--[[
    Horizon Suite - Shared option-descriptor helpers
    Exports font/outline helpers used by multiple module option files.
    Must load after OptionsData.lua and before any module options file.
]]
local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L
local function getDB(k, d) return addon.GetDB(k, d) end

local FONT_USE_GLOBAL = "__global__"

local function GetPerElementFontDropdownOptions(dbKey)
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB(dbKey, FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local function DisplayPerElementFont(value)
    if value == FONT_USE_GLOBAL then return L["FOCUS_GLOBAL_FONT"] end
    if addon.GetFontNameForPath then return addon.GetFontNameForPath(value) end
    return value
end

local OUTLINE_OPTIONS = {
    { L["FOCUS_OUTLINE_NONE"], "" },
    { L["FOCUS_OUTLINE"], "OUTLINE" },
    { L["FOCUS_THICK_OUTLINE"], "THICKOUTLINE" },
    { L["FOCUS_SLUG"] or "SLUG", "SLUG" },
    { L["FOCUS_SLUG_OUTLINE"] or "SLUG Outline", "OUTLINE, SLUG" },
    { L["FOCUS_SLUG_THICK_OUTLINE"] or "SLUG Thick Outline", "THICKOUTLINE, SLUG" },
}

addon.FONT_USE_GLOBAL                  = FONT_USE_GLOBAL
addon.GetPerElementFontDropdownOptions = GetPerElementFontDropdownOptions
addon.DisplayPerElementFont            = DisplayPerElementFont
addon.OUTLINE_OPTIONS                  = OUTLINE_OPTIONS
