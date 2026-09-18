--[[
    Horizon Suite - Flow - Background

    Artwork behind the quest box, drawn from the same theme library the Axis
    dashboard uses. The art files and the theme list live in
    options/dashboard/DashboardBackground.lua and are reached through
    addon.ResolveHorizonBackgroundTarget, so adding a background there reaches
    Flow with no further work and there is no second copy of the file map to
    drift.

    Layering, bottom to top:
      solid   - the backdrop colour, so the window is readable whatever the art
      art     - the theme texture, tinted dark and held at low alpha
      cards   - the objectives, lore and reward blocks
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow

-- Sentinel: take whatever the dashboard is currently set to, so the two match
-- without the player configuring it twice.
F.THEME_FOLLOW_DASHBOARD = "__dashboard__"

local DEFAULT_ART_ALPHA = 35

local art, artHolder

--- The theme id Flow should draw.
--- @return string themeId
function F.GetBackgroundTheme()
    local raw = addon.GetDB and addon.GetDB("flowBackgroundTheme", F.THEME_FOLLOW_DASHBOARD)
    if not raw or raw == "" or raw == F.THEME_FOLLOW_DASHBOARD then
        return (addon.GetDB and addon.GetDB("dashboardBackgroundTheme", "midnight")) or "midnight"
    end
    return raw
end

--- Art opacity as a 0-1 fraction.
--- @return number alpha
local function ArtAlpha()
    local pct = tonumber(addon.GetDB and addon.GetDB("flowBackgroundOpacity", DEFAULT_ART_ALPHA))
        or DEFAULT_ART_ALPHA
    return math.max(0, math.min(1, pct / 100))
end

--- Draw (or clear) the themed art behind the quest box.
---
--- The holder is a frame rather than a bare texture on the chrome so the art
--- can be clipped to the window and kept below every card without competing
--- for draw layers with the chrome's own backdrop.
--- @param parent Frame The chrome frame the art sits inside
--- @return nil
function F.ApplyBackground(parent)
    if not parent then return end

    if not artHolder then
        artHolder = CreateFrame("Frame", "HorizonFlowBackgroundArt", parent)
        artHolder:SetAllPoints(parent)
        artHolder:SetFrameLevel(math.max(0, (parent:GetFrameLevel() or 1)))
        art = artHolder:CreateTexture(nil, "BACKGROUND", nil, 1)
        art:SetAllPoints(artHolder)
    end

    if not (addon.GetDB and addon.GetDB("flowShowBackgroundArt", true)) then
        artHolder:Hide()
        return
    end

    local resolve = addon.ResolveHorizonBackgroundTarget
    if type(resolve) ~= "function" then
        -- DashboardBackground.lua loads after the module block; on the very
        -- first paint of a session the resolver may not exist yet. Nothing to
        -- recover from, the next display picks it up.
        artHolder:Hide()
        return
    end

    local ok, target = pcall(resolve, F.GetBackgroundTheme())
    if not ok or type(target) ~= "table" or target.kind == "clear" then
        artHolder:Hide()
        return
    end

    if target.kind == "texture" and target.path then
        art:SetTexture(target.path)
    elseif target.kind == "atlas" and target.atlas then
        art:SetAtlas(target.atlas, false)
    else
        artHolder:Hide()
        return
    end

    -- Tinted down as well as faded: the dashboard art is full-brightness
    -- scenery, and at readable alpha alone it still pulls the eye off the
    -- objectives, which are the whole point of the window.
    art:SetVertexColor(0.45, 0.45, 0.52, 1)
    art:SetAlpha(ArtAlpha())
    artHolder:Show()
end

--- @return nil
function F.HideBackground()
    if artHolder then artHolder:Hide() end
end
