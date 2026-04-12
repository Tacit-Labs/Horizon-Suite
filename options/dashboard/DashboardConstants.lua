--[[
    Horizon Suite - Dashboard layout constants (shared by dashboard UI files).

    NATIVE_W / NATIVE_H are the canonical 16:9 design dimensions.
    All pixel values produced by GetLayoutConstants() are relative to those
    dimensions and scaled by the caller-supplied ratio.
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
    -- Dashboard window canonical design size (16:9).
    -- Author full-bleed PNG backgrounds at this size (or 2×: 2560×1440).
    NATIVE_W = 1280,
    NATIVE_H = 720,
    FRAME_W   = 1280,   -- kept for back-compat; always equals NATIVE_W
    FRAME_H   = 720,    -- kept for back-compat; always equals NATIVE_H
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
    -- Sidebar native dimensions (always fixed; sidebar does not scale with dashboard ratio)
    SIDEBAR_NATIVE_W        = 160,
    SIDEBAR_CONTENT_X_INSET = 15,
    -- Subcategory scroll frame inset (40px left + 40px right from subCategoryView)
    -- Keep in sync with the TOPLEFT/BOTTOMRIGHT anchor offsets on subCategoryScroll.
    SUBCATEGORY_SCROLL_INSET = 80,
}

local DC = addon.DashboardConstants
DC.VIEW_H = DC.FRAME_H - 20

-- ---------------------------------------------------------------------------
-- DC.Scaled(value, ratio) — scale a native-pixel value by a resize ratio.
-- ratio defaults to 1.0 when omitted.
-- ---------------------------------------------------------------------------
function DC.Scaled(value, ratio)
    ratio = ratio or 1.0
    return value * ratio
end

-- ---------------------------------------------------------------------------
-- DC.GetLayoutConstants(ratio) — returns a table of all frame-level pixel
-- values scaled by ratio.  Consumers should call this once per resize event
-- and read fields rather than calling individual helpers per-pixel.
-- ---------------------------------------------------------------------------
function DC.GetLayoutConstants(ratio)
    ratio = ratio or 1.0
    local nw = DC.NATIVE_W * ratio
    local nh = DC.NATIVE_H * ratio
    local sw = DC.SIDEBAR_NATIVE_W  -- sidebar is fixed-size; does not scale with ratio
    local contentOffset = sw + 10
    local viewWidth     = nw - sw - 10
    local viewH         = nh - 20
    local viewCenterX   = contentOffset / 2
    local contentWidth  = viewWidth - 80
    local dashTitleX    = contentOffset + 40
    local viewTopInset  = (nh - viewH) / 2
    local scrollTopOff  = -(math.abs(DC.SEARCH_Y) + DC.SEARCH_BOX_H + 8 - viewTopInset)
    return {
        ratio          = ratio,
        frameW         = nw,
        frameH         = nh,
        viewH          = viewH,
        sidebarW       = sw,
        contentOffset  = contentOffset,
        viewWidth      = viewWidth,
        viewCenterX    = viewCenterX,
        contentWidth   = contentWidth,
        dashTitleX     = dashTitleX,
        dashScrollTopOffset = scrollTopOff,
    }
end
