--[[
    Horizon Suite - Meridian - Coordinates and performance blocks
    Blizzard: C_Map, GetZoneText, GetSubZoneText, ToggleWorldMap, GetFramerate, GetNetStats.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local function CoordsText()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then return nil end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return nil end
    local x, y = pos:GetXY()
    return F.Coords(x, y, tonumber(Meridian.Setting("meridianCoordPrecision")) or 1)
end

Meridian.RegisterBlock({
    id = "coords",
    label = L["MERIDIAN_BLOCK_COORDS"],
    icon = Meridian.Glyph("pin"),
    text = CoordsText,
    tick = 0.25,
    OnClick = function() if ToggleWorldMap then ToggleWorldMap() end end,
    OnTooltipShow = function(tooltip)
        local zone = GetZoneText and GetZoneText() or ""
        local sub = GetSubZoneText and GetSubZoneText() or ""
        if zone ~= "" then tooltip:AddLine(zone, 1, 1, 1) end
        if sub ~= "" and sub ~= zone then tooltip:AddLine(sub, 0.8, 0.8, 0.8) end
        tooltip:AddLine(L["MERIDIAN_CLICK_MAP"], 0.6, 0.6, 0.6)
    end,
    defaultSide = "right", defaultOrder = 10, defaultOn = true,
})

local function NetStats()
    if not GetNetStats then return 0, 0 end
    local _, _, home, world = GetNetStats()
    return home or 0, world or home or 0
end

Meridian.RegisterBlock({
    id = "perf",
    label = L["MERIDIAN_BLOCK_PERF"],
    icon = Meridian.Glyph("pulse"),
    text = function()
        local _, world = NetStats()
        return F.Perf(GetFramerate and GetFramerate() or 0, world)
    end,
    tick = 1,
    OnTooltipShow = function(tooltip)
        local home, world = NetStats()
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_FPS"], tostring(math.floor(GetFramerate and GetFramerate() or 0)), 0.7, 0.7, 0.7, 1, 1, 1)
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_HOME"], home .. " ms", 0.7, 0.7, 0.7, 1, 1, 1)
        tooltip:AddDoubleLine(L["MERIDIAN_PERF_WORLD"], world .. " ms", 0.7, 0.7, 0.7, 1, 1, 1)
    end,
    defaultSide = "right", defaultOrder = 20, defaultOn = true,
})
