--[[
    Horizon Suite - Shared option-descriptor helpers
    Exports font/outline helpers, BrandModule, and option-descriptor builders used by
    multiple module option files. Must load after OptionsData.lua and before any module
    options file.
]]
local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L
local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

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
    { L["FOCUS_SLUG"], "SLUG" },
    { L["FOCUS_SLUG_OUTLINE"], "OUTLINE, SLUG" },
    { L["FOCUS_SLUG_THICK_OUTLINE"], "THICKOUTLINE, SLUG" },
}

local function BrandModule(moduleKey)
    if addon.GetModuleDisplayName then return addon.GetModuleDisplayName(moduleKey) end
    local t = addon.BrandDisplay and addon.BrandDisplay.module
    if not moduleKey or not t then return nil end
    return t[moduleKey]
end

local function merge(t, opts)
    if opts then for k, v in pairs(opts) do t[k] = v end end
    return t
end

local function Section(name, opts)
    return merge({ type = "section", name = name }, opts)
end

local function Header(name)
    return { type = "header", name = name }
end

local function ModuleReloadPrompt(opts)
    return merge({ type = "moduleReloadPrompt" }, opts)
end

local function Button(name, desc, onClick, opts)
    return merge({ type = "button", name = name, desc = desc, onClick = onClick }, opts)
end

local function Toggle(name, desc, dbKey, default, opts)
    return merge({
        type = "toggle", name = name, desc = desc, dbKey = dbKey,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }, opts)
end

local function Slider(name, desc, dbKey, min, max, default, opts)
    return merge({
        type = "slider", name = name, desc = desc, dbKey = dbKey,
        min = min, max = max,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }, opts)
end

local function Color(name, desc, dbKey, default, opts)
    return merge({ type = "color", name = name, desc = desc, dbKey = dbKey, default = default }, opts)
end

addon.FONT_USE_GLOBAL                  = FONT_USE_GLOBAL
addon.GetPerElementFontDropdownOptions = GetPerElementFontDropdownOptions
addon.DisplayPerElementFont            = DisplayPerElementFont
addon.OUTLINE_OPTIONS                  = OUTLINE_OPTIONS
addon.BrandModule                      = BrandModule
addon.Section                          = Section
addon.Header                           = Header
addon.ModuleReloadPrompt               = ModuleReloadPrompt
addon.Button                           = Button
addon.Toggle                           = Toggle
addon.Slider                           = Slider
addon.Color                            = Color
