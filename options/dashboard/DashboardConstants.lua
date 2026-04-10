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
    SEARCH_BOX_H = 38,
    -- Vertical chrome: shell is SEARCH_BOX_H + SEARCH_SHELL_EXTRA_H; shell top = SEARCH_Y - SEARCH_BAR_TOP_NUDGE.
    SEARCH_SHELL_EXTRA_H = 6,
    SEARCH_BAR_TOP_NUDGE = 3,
    -- Space from bottom of search shell to top of scroll content (detail tiles, first accordion, Home, etc.).
    SCROLL_GAP_BELOW_SEARCH = 16,
    -- Extra inset before the first accordion in module detail scroll (below search/title band).
    DETAIL_FIRST_BLOCK_TOP_PAD = 10,
    -- Cap width for the dashboard search field (content area may be narrower).
    SEARCH_BAR_MAX_W = 640,
    -- Welcome + Module Guide: visible space between scroll content and Community & Support block.
    COMMUNITY_FOOTER_SCROLL_GAP = 24,
    -- Home module toggle cards (replaces tile grid); one height for every row (preview disclaimer fits in fixed text bands).
    HOME_TOGGLE_CARD_H = 88,
    HOME_TOGGLE_CARD_GAP = 8,
    HOME_TOGGLE_PILL_W = 44,
    HOME_TOGGLE_PILL_H = 24,
    HOME_TOGGLE_PILL_THUMB = 18,
    HOME_TOGGLE_ICON_SIZE = 36,
    HOME_RELOAD_BANNER_H = 52,
}

local C = addon.DashboardConstants
C.VIEW_H = C.FRAME_H - 20
