--[[
    Horizon Suite - Options - Page vocabulary
    The shared page and card names every module files its settings under, and the
    registry of each module's own pages. OptionsAssemble.lua reads both to build the
    dashboard pages. Must load after OptionsHelpers.lua and before any module options file.
]]
local addon = _G.HorizonSuite
if not addon then return end

local Pages = {
    -- Shared pages, in display order. Every module shows these first.
    SHARED = { "general", "layout", "look" },
    -- Shared cards for each shared page, in display order.
    SHARED_CARDS = {
        general = { "visibility", "behaviour" },
        layout  = { "position", "size" },
        look    = { "text", "colours", "background", "animation" },
    },
    -- Locale keys for shared page and card display names.
    NAMES = {
        general    = "PAGE_GENERAL",
        layout     = "PAGE_LAYOUT",
        look       = "PAGE_LOOK",
        visibility = "CARD_VISIBILITY",
        behaviour  = "CARD_BEHAVIOUR",
        position   = "CARD_POSITION",
        size       = "CARD_SIZE",
        text       = "CARD_TEXT",
        colours    = "CARD_COLOURS",
        background = "CARD_BACKGROUND",
        animation  = "CARD_ANIMATION",
    },
    -- [moduleKey] = { order = { pageKey, ... }, defs = { [pageKey] = def } }
    modules = {},
}
addon.OptionsPages = Pages

local sharedSet = {}
for _, k in ipairs(Pages.SHARED) do sharedSet[k] = true end

--- @param pageKey string
--- @return boolean
function Pages.IsShared(pageKey)
    return sharedSet[pageKey] == true
end

--- @param pageKey string
--- @param cardKey string
--- @return boolean
function Pages.IsSharedCard(pageKey, cardKey)
    for _, k in ipairs(Pages.SHARED_CARDS[pageKey] or {}) do
        if k == cardKey then return true end
    end
    return false
end

--- Localised display name for a shared page or card key.
--- @param key string
--- @return string
function Pages.Name(key)
    local localeKey = Pages.NAMES[key]
    return localeKey and addon.L[localeKey] or key
end

--- Declare a module's own pages (shown after the shared ones) and fields for any page.
--- A def whose key is a shared page adds fields to that page without reordering anything.
--- Registering a key again replaces its def and keeps its place in the order.
--- @param moduleKey string  "axis" for the Axis categories, which carry no moduleKey
--- @param defs table  Array of page defs: { key = string, name = string|nil, ... }
function addon.RegisterModulePages(moduleKey, defs)
    local m = Pages.modules[moduleKey]
    if not m then
        m = { order = {}, defs = {} }
        Pages.modules[moduleKey] = m
    end
    for _, def in ipairs(defs) do
        if not sharedSet[def.key] and not m.defs[def.key] then
            m.order[#m.order + 1] = def.key
        end
        m.defs[def.key] = def
    end
end
