--[[
    Horizon Suite - Dashboard layout constants (shared by dashboard UI files).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.DashboardConstants = {
    -- Interior fills: lower so tiles/sidebar do not read as opaque slabs over the softened backdrop.
    CHILD_PANEL_ALPHA = 0.72,
    CONTENT_CARD_ALPHA_MULT = 0.78,
    -- Home module tiles: bento Axis (same width as others; height = stacked rows + gap). Fill matches subcategory/accordion cards (SectionCard × CONTENT_CARD_ALPHA_MULT); HOME_TILE_BG_ALPHA_MULT for optional tuning.
    HOME_TILE_W = 190,
    HOME_TILE_H = 160,
    HOME_TILE_GAP = 15,
    HOME_TILE_COLS = 4,
    HOME_TILE_BG_ALPHA_MULT = 1.0,
    HOME_SKELETON_BG_ALPHA_MULT = 0.58,
    -- Dashboard window (16:9). Author full-bleed PNG backgrounds at this size (or 2×, e.g. 2560×1440).
    FRAME_W = 1280,
    FRAME_H = 720,
    -- Main content header band (anchors to dashboard frame TOP).
    HEAD_TITLE_Y = -30,
    HEAD_SUBTITLE_Y = -58,
    SEARCH_Y = -88,
    SEARCH_BOX_H = 36,
    -- Welcome + Module Guide: visible space between scroll content and Community & Support block.
    COMMUNITY_FOOTER_SCROLL_GAP = 24,
}

local C = addon.DashboardConstants
C.VIEW_H = C.FRAME_H - 20
