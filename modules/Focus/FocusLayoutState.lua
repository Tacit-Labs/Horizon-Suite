--[[
    Horizon Suite - Focus - Layout State
    Owns the initial shape of addon.focus.layout and addon.focus.hoverFade. Loaded
    before core/Core.lua and modules/Focus/FocusState.lua so neither file needs to
    independently create or preserve these sub-tables.
]]

local addon = _G.HorizonSuite

addon.focus = addon.focus or {}

addon.focus.layout = addon.focus.layout or {
    scrollOffset = 0,
    targetHeight = addon.MIN_HEIGHT,
    currentHeight = addon.MIN_HEIGHT,
    sectionIdx = 0,
    -- Distance from the bottom of the scroll content (maxScr - scrollOffset). Used in
    -- grow-up mode to keep the viewport pinned to the bottom (Objectives header) so
    -- the highest-priority section stays visible across layouts. 0 = pinned to bottom.
    scrollBottomOffset = 0,
}

addon.focus.hoverFade = addon.focus.hoverFade or {
    mouseOver = false,
    fadeState = nil,  -- "in" | "out" | nil
    fadeTime  = 0,
    bgFadeState = nil,  -- "in" | "out" | nil
    bgFadeTime  = 0,
}
