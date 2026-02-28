--[[
    Horizon Suite - Vista - Core
    Cinematic square minimap with zone text, coordinates, time, instance difficulty, mail, tracking, button collector.
    Supports full options: map size, border, typography, visibility, button drawer modes, per-addon filtering.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Vista = addon.Vista or {}
local Vista = addon.Vista

-- ============================================================================
-- DEFAULTS / CONSTANTS
-- ============================================================================

local FONT_PATH_DEFAULT = "Fonts\\FRIZQT__.TTF"
local ZONE_SIZE_DEFAULT   = 12
local COORD_SIZE_DEFAULT  = 10
local TIME_SIZE_DEFAULT   = 10

local BORDER_COLOR_DEFAULT  = { 1, 1, 1, 0.15 }
local ZONE_COLOR_DEFAULT    = { 1, 1, 1 }
local COORD_COLOR_DEFAULT   = { 0.55, 0.65, 0.75 }
local DIFF_COLOR            = { 0.55, 0.65, 0.75 }
local DIFF_SIZE             = 10

local SHADOW_A  = 0.8

local MAP_SIZE_DEFAULT = 200
local MINIMAP_BASE_SIZE = 256  -- Blizzard's minimap texture size; we scale this to vistaMapSize

local BTN_GAP  = 4

local FADE_DUR       = 0.20
local COORD_THROTTLE = 0.25
local TIME_THROTTLE  = 1.0

local PULSE_MIN   = 0.40
local PULSE_MAX   = 1.00
local PULSE_SPEED = 2.0

local DEFAULT_POINT    = "TOPRIGHT"
local DEFAULT_RELPOINT = "TOPRIGHT"
local DEFAULT_X        = -20
local DEFAULT_Y        = -20

-- Sentinel value meaning "use the global font" for per-element font pickers
local FONT_USE_GLOBAL = "__global__"

-- Button modes
local BTN_MODE_MOUSEOVER  = "mouseover"
local BTN_MODE_RIGHTCLICK = "rightclick"
local BTN_MODE_DRAWER     = "drawer"

local function easeOut(t) return 1 - (1 - t) * (1 - t) end

-- Proxy frame for taint-free Minimap manipulation
local proxy = CreateFrame("Frame")

-- ============================================================================
-- DB HELPERS
-- ============================================================================

local function DB(key, default)
    if addon.GetDB then return addon.GetDB(key, default) end
    return default
end

local function SetDB(key, value)
    if addon.SetDB then addon.SetDB(key, value) end
end

local function GetMapSize() return tonumber(DB("vistaMapSize", MAP_SIZE_DEFAULT)) or MAP_SIZE_DEFAULT end
local function GetBorderShow()  return DB("vistaBorderShow", true) end
local function GetBorderW()     return tonumber(DB("vistaBorderWidth", 1)) or 1 end
local function GetBorderColor()
    return  tonumber(DB("vistaBorderColorR", BORDER_COLOR_DEFAULT[1])) or BORDER_COLOR_DEFAULT[1],
            tonumber(DB("vistaBorderColorG", BORDER_COLOR_DEFAULT[2])) or BORDER_COLOR_DEFAULT[2],
            tonumber(DB("vistaBorderColorB", BORDER_COLOR_DEFAULT[3])) or BORDER_COLOR_DEFAULT[3],
            tonumber(DB("vistaBorderColorA", BORDER_COLOR_DEFAULT[4])) or BORDER_COLOR_DEFAULT[4]
end

-- Resolve a per-element font path, falling back to global or the hard default.
-- Always pipes through addon.ResolveFontPath() so LSM keys (e.g. "Game Font",
-- "Friz Quadrata TT") are converted to actual file paths before being passed
-- to FontString:SetFont().
local function ResolveFont(dbKey)
    local v = DB(dbKey, FONT_USE_GLOBAL)
    if v == FONT_USE_GLOBAL or v == nil or v == "" then
        -- Fall back to the addon global font setting (also may be an LSM key)
        v = (addon.GetDB and addon.GetDB("fontPath", nil)) or nil
    end
    -- If we still have nothing, use the in-game default font path directly
    if not v or v == "" or v == FONT_USE_GLOBAL then
        return addon.GetDefaultFontPath and addon.GetDefaultFontPath() or FONT_PATH_DEFAULT
    end
    -- ResolveFontPath converts LSM keys → real file paths; passes real paths through unchanged
    if addon.ResolveFontPath then
        local resolved = addon.ResolveFontPath(v)
        if resolved and resolved ~= "" then return resolved end
    end
    -- Last resort: if it's already a path (contains slashes), use as-is
    if v:find("\\") or v:find("/") then return v end
    return addon.GetDefaultFontPath and addon.GetDefaultFontPath() or FONT_PATH_DEFAULT
end

-- All getter functions in one table (saves ~45 top-level locals)
local G = {}
do
    local DIFF_COLOR_KEYS = {
        mythic           = { 0.64, 0.21, 0.93 },
        heroic           = { 1.00, 0.12, 0.12 },
        normal           = { 0.12, 0.83, 0.12 },
        looking_for_raid = { 0.00, 0.70, 1.00 },
    }
    local PANEL_BG_DEFAULT     = { 0.08, 0.08, 0.12, 0.95 }
    local PANEL_BORDER_DEFAULT = { 0.3, 0.4, 0.6, 0.7 }
    local MASK_SQUARE_V   = "Interface\\ChatFrame\\ChatFrameBackground"
    local MASK_CIRCULAR_V = 186178
    local BTN_DEFAULTS = { tracking=22, calendar=22, queue=22, zoom=16, mail=20, addon=26 }

    -- Font / size
    G.ZoneFont   = function() return ResolveFont("vistaZoneFontPath") end
    G.ZoneSize   = function() return tonumber(DB("vistaZoneFontSize",  ZONE_SIZE_DEFAULT))  or ZONE_SIZE_DEFAULT end
    G.CoordFont  = function() return ResolveFont("vistaCoordFontPath") end
    G.CoordSize  = function() return tonumber(DB("vistaCoordFontSize", COORD_SIZE_DEFAULT)) or COORD_SIZE_DEFAULT end
    G.TimeFont   = function() return ResolveFont("vistaTimeFontPath") end
    G.TimeSize   = function() return tonumber(DB("vistaTimeFontSize",  TIME_SIZE_DEFAULT))  or TIME_SIZE_DEFAULT end
    G.DiffFont   = function() return ResolveFont("vistaDiffFontPath") end
    G.DiffSize   = function() return tonumber(DB("vistaDiffFontSize",  DIFF_SIZE)) or DIFF_SIZE end

    -- Visibility toggles
    G.ShowZone      = function() return DB("vistaShowZoneText",   true)  end
    G.ShowCoord     = function() return DB("vistaShowCoordText",  true)  end
    G.ShowTime      = function() return DB("vistaShowTimeText",   true) end
    G.TimeUseLocal  = function() return DB("vistaTimeUseLocal",   true) end
    G.ZoneDisplayMode = function() return DB("vistaZoneDisplayMode", "zone") end

    -- Vertical positions
    local function vpos(key) return (DB(key,"bottom") or "bottom")=="top" and "top" or "bottom" end
    G.ZoneVerticalPos  = function() return vpos("vistaZoneVerticalPos")  end
    G.CoordVerticalPos = function() return vpos("vistaCoordVerticalPos") end
    G.TimeVerticalPos  = function() return vpos("vistaTimeVerticalPos")  end

    -- Anchors
    G.ZoneAnchors  = function() if G.ZoneVerticalPos()=="top"  then return "BOTTOM","TOP"         end return "TOP","BOTTOM"         end
    G.CoordAnchors = function() if G.CoordVerticalPos()=="top" then return "BOTTOMRIGHT","TOPRIGHT" end return "TOPRIGHT","BOTTOMRIGHT" end
    G.TimeAnchors  = function() if G.TimeVerticalPos()=="top"  then return "BOTTOMLEFT","TOPLEFT"  end return "TOPLEFT","BOTTOMLEFT"  end

    -- Saved drag offsets
    local DEFAULT_Y_BOTTOM, DEFAULT_Y_TOP = -6, 6
    G.ElemX      = function(k,d) return tonumber(DB("vistaEX_"..k, d)) or d end
    G.ElemY      = function(k,d) return tonumber(DB("vistaEY_"..k, d)) or d end
    G.ElemLocked = function(k)   return DB("vistaLocked_"..k, false) end
    G.ZoneOffsetX  = function() return G.ElemX("zone",  0) end
    G.ZoneOffsetY  = function() local c=G.ElemY("zone",nil);  if c~=nil then return c end return G.ZoneVerticalPos()=="top"  and DEFAULT_Y_TOP or DEFAULT_Y_BOTTOM end
    G.CoordOffsetX = function() return G.ElemX("coord", 0) end
    G.CoordOffsetY = function() local c=G.ElemY("coord",nil); if c~=nil then return c end return G.CoordVerticalPos()=="top" and DEFAULT_Y_TOP or DEFAULT_Y_BOTTOM end
    G.TimeOffsetX  = function() return G.ElemX("time",  0) end
    G.TimeOffsetY  = function() local c=G.ElemY("time", nil);  if c~=nil then return c end return G.TimeVerticalPos()=="top"  and DEFAULT_Y_TOP or DEFAULT_Y_BOTTOM end

    -- Button modes
    G.ButtonMode          = function() return DB("vistaButtonMode",         BTN_MODE_RIGHTCLICK) end
    G.ButtonHandleButtons = function() return DB("vistaHandleAddonButtons", true) end
    G.ButtonDrawerLocked  = function() return DB("vistaDrawerButtonLocked", false) end
    G.ButtonWhitelist     = function() return DB("vistaButtonWhitelist",    nil) end
    G.IsButtonManaged     = function(n) return DB("vistaButtonManaged_" .. n, true) end
    G.CoordPrecision        = function() return tonumber(DB("vistaCoordPrecision", 1)) or 1 end
    G.BtnLayoutCols         = function() return tonumber(DB("vistaBtnLayoutCols",  5)) or 5 end
    G.BtnLayoutDir          = function() return DB("vistaBtnLayoutDir", "right") end
    G.MouseoverLocked       = function() return DB("vistaMouseoverLocked", true)  end
    G.MouseoverBarX         = function() return tonumber(DB("vistaMouseoverBarX", nil)) end
    G.MouseoverBarY         = function() return tonumber(DB("vistaMouseoverBarY", nil)) end
    G.MouseoverBarVisible   = function() return DB("vistaMouseoverBarVisible", false) end
    G.MouseoverCloseDelay   = function() return tonumber(DB("vistaMouseoverCloseDelay", 0)) or 0 end
    G.RightClickCloseDelay  = function() return tonumber(DB("vistaRightClickCloseDelay", 0.3)) or 0.3 end
    G.DrawerCloseDelay      = function() return tonumber(DB("vistaDrawerCloseDelay", 0)) or 0 end
    G.MailBlink             = function() return DB("vistaMailBlink", true) end
    G.BarBgColor            = function()
        local BAR_BG_DEFAULT = { 0.08, 0.08, 0.12, 0 }
        return tonumber(DB("vistaBarBgR", BAR_BG_DEFAULT[1])) or BAR_BG_DEFAULT[1],
               tonumber(DB("vistaBarBgG", BAR_BG_DEFAULT[2])) or BAR_BG_DEFAULT[2],
               tonumber(DB("vistaBarBgB", BAR_BG_DEFAULT[3])) or BAR_BG_DEFAULT[3],
               tonumber(DB("vistaBarBgA", BAR_BG_DEFAULT[4])) or BAR_BG_DEFAULT[4]
    end
    G.BarBorderShow         = function() return DB("vistaBarBorderShow", false) end
    G.BarBorderColor        = function()
        local BAR_BORDER_DEFAULT = { 0.3, 0.4, 0.6, 0.7 }
        return tonumber(DB("vistaBarBorderR", BAR_BORDER_DEFAULT[1])) or BAR_BORDER_DEFAULT[1],
               tonumber(DB("vistaBarBorderG", BAR_BORDER_DEFAULT[2])) or BAR_BORDER_DEFAULT[2],
               tonumber(DB("vistaBarBorderB", BAR_BORDER_DEFAULT[3])) or BAR_BORDER_DEFAULT[3],
               tonumber(DB("vistaBarBorderA", BAR_BORDER_DEFAULT[4])) or BAR_BORDER_DEFAULT[4]
    end
    G.RightClickLocked      = function() return DB("vistaRightClickLocked", true) end
    G.RightClickPanelX      = function() return tonumber(DB("vistaRightClickPanelX", nil)) end
    G.RightClickPanelY      = function() return tonumber(DB("vistaRightClickPanelY", nil)) end

    -- Shape / mask
    G.Circular    = function() return DB("vistaCircular", false) end
    G.MaskSquare   = MASK_SQUARE_V
    G.MaskCircular = MASK_CIRCULAR_V

    -- Per-button visibility / mouseover
    G.ShowTracking      = function() return DB("vistaShowTracking",      true)  end
    G.ShowCalendar      = function() return DB("vistaShowCalendar",      true)  end
    G.ShowZoomBtns      = function() return DB("vistaShowZoomBtns",      true)  end
    G.MouseoverTracking = function() return DB("vistaMouseoverTracking", false) end
    G.MouseoverCalendar = function() return DB("vistaMouseoverCalendar", false) end
    G.MouseoverZoomBtns = function() return DB("vistaMouseoverZoomBtns", false) end

    -- Button sizes
    G.TrackingBtnSize = function() return tonumber(DB("vistaTrackingBtnSize", BTN_DEFAULTS.tracking)) or BTN_DEFAULTS.tracking end
    G.CalendarBtnSize = function() return tonumber(DB("vistaCalendarBtnSize", BTN_DEFAULTS.calendar)) or BTN_DEFAULTS.calendar end
    G.QueueBtnSize    = function() return tonumber(DB("vistaQueueBtnSize",    BTN_DEFAULTS.queue))    or BTN_DEFAULTS.queue    end
    G.ZoomBtnSize     = function() return tonumber(DB("vistaZoomBtnSize",     BTN_DEFAULTS.zoom))     or BTN_DEFAULTS.zoom     end
    G.MailIconSize    = function() return tonumber(DB("vistaMailIconSize",     BTN_DEFAULTS.mail))     or BTN_DEFAULTS.mail     end
    G.AddonBtnSize    = function() return tonumber(DB("vistaAddonBtnSize",     BTN_DEFAULTS.addon))    or BTN_DEFAULTS.addon    end
    G.ProxyBtnSizeForKey = function(k)
        if k=="tracking" then return G.TrackingBtnSize()
        elseif k=="calendar" then return G.CalendarBtnSize()
        elseif k=="queue"    then return G.QueueBtnSize()
        else return BTN_DEFAULTS.tracking end
    end

    -- Colors
    G.ZoneColor  = function() return tonumber(DB("vistaZoneColorR",  ZONE_COLOR_DEFAULT[1]))  or ZONE_COLOR_DEFAULT[1],  tonumber(DB("vistaZoneColorG",  ZONE_COLOR_DEFAULT[2]))  or ZONE_COLOR_DEFAULT[2],  tonumber(DB("vistaZoneColorB",  ZONE_COLOR_DEFAULT[3]))  or ZONE_COLOR_DEFAULT[3]  end
    G.CoordColor = function() return tonumber(DB("vistaCoordColorR", COORD_COLOR_DEFAULT[1])) or COORD_COLOR_DEFAULT[1], tonumber(DB("vistaCoordColorG", COORD_COLOR_DEFAULT[2])) or COORD_COLOR_DEFAULT[2], tonumber(DB("vistaCoordColorB", COORD_COLOR_DEFAULT[3])) or COORD_COLOR_DEFAULT[3] end
    G.TimeColor  = function() return tonumber(DB("vistaTimeColorR",  COORD_COLOR_DEFAULT[1])) or COORD_COLOR_DEFAULT[1], tonumber(DB("vistaTimeColorG",  COORD_COLOR_DEFAULT[2])) or COORD_COLOR_DEFAULT[2], tonumber(DB("vistaTimeColorB",  COORD_COLOR_DEFAULT[3])) or COORD_COLOR_DEFAULT[3] end
    G.DiffColor  = function() return tonumber(DB("vistaDiffColorR",  DIFF_COLOR[1])) or DIFF_COLOR[1], tonumber(DB("vistaDiffColorG", DIFF_COLOR[2])) or DIFF_COLOR[2], tonumber(DB("vistaDiffColorB", DIFF_COLOR[3])) or DIFF_COLOR[3] end
    G.DiffLocked = function() return DB("vistaLocked_diff", false) end

    G.PanelBgColor = function()
        return tonumber(DB("vistaPanelBgR",PANEL_BG_DEFAULT[1])) or PANEL_BG_DEFAULT[1],
               tonumber(DB("vistaPanelBgG",PANEL_BG_DEFAULT[2])) or PANEL_BG_DEFAULT[2],
               tonumber(DB("vistaPanelBgB",PANEL_BG_DEFAULT[3])) or PANEL_BG_DEFAULT[3],
               tonumber(DB("vistaPanelBgA",PANEL_BG_DEFAULT[4])) or PANEL_BG_DEFAULT[4]
    end
    G.PanelBorderColor = function()
        return tonumber(DB("vistaPanelBorderR",PANEL_BORDER_DEFAULT[1])) or PANEL_BORDER_DEFAULT[1],
               tonumber(DB("vistaPanelBorderG",PANEL_BORDER_DEFAULT[2])) or PANEL_BORDER_DEFAULT[2],
               tonumber(DB("vistaPanelBorderB",PANEL_BORDER_DEFAULT[3])) or PANEL_BORDER_DEFAULT[3],
               tonumber(DB("vistaPanelBorderA",PANEL_BORDER_DEFAULT[4])) or PANEL_BORDER_DEFAULT[4]
    end

    -- Per-difficulty color lookup
    local function NormalizeDiffKey(name)
        if not name then return nil end
        return name:lower():gsub("%s+","_"):gsub("[^%w_]","")
    end
    G.DiffColorForName = function(diffName)
        if not diffName then return G.DiffColor() end
        local key = NormalizeDiffKey(diffName)
        local fb = { G.DiffColor() }
        local defs = DIFF_COLOR_KEYS[key] or fb
        return tonumber(DB("vistaDiffColor_"..key.."_R", defs[1])) or defs[1],
               tonumber(DB("vistaDiffColor_"..key.."_G", defs[2])) or defs[2],
               tonumber(DB("vistaDiffColor_"..key.."_B", defs[3])) or defs[3]
    end
end

-- Two constants used by name in SetMaskTexture calls
local MASK_SQUARE, MASK_CIRCULAR = G.MaskSquare, G.MaskCircular

-- Aliases for frequently-called getters (avoids table lookup overhead in hot paths)
local GetZoneFont, GetZoneSize           = G.ZoneFont,  G.ZoneSize
local GetCoordFont, GetCoordSize         = G.CoordFont, G.CoordSize
local GetTimeFont, GetTimeSize           = G.TimeFont,  G.TimeSize
local GetDiffFont, GetDiffSize           = G.DiffFont,  G.DiffSize
local GetShowZone, GetShowCoord, GetShowTime = G.ShowZone, G.ShowCoord, G.ShowTime
local GetTimeUseLocal, GetZoneDisplayMode    = G.TimeUseLocal, G.ZoneDisplayMode
local GetZoneAnchors, GetCoordAnchors, GetTimeAnchors = G.ZoneAnchors, G.CoordAnchors, G.TimeAnchors
local GetElemLocked                          = G.ElemLocked
local GetZoneOffsetX, GetZoneOffsetY         = G.ZoneOffsetX, G.ZoneOffsetY
local GetCoordOffsetX, GetCoordOffsetY       = G.CoordOffsetX, G.CoordOffsetY
local GetTimeOffsetX, GetTimeOffsetY         = G.TimeOffsetX, G.TimeOffsetY
local GetButtonMode                          = G.ButtonMode
local GetCircular                            = G.Circular
local GetShowTracking, GetShowCalendar, GetShowZoomBtns       = G.ShowTracking, G.ShowCalendar, G.ShowZoomBtns
local GetMouseoverTracking, GetMouseoverCalendar, GetMouseoverZoomBtns = G.MouseoverTracking, G.MouseoverCalendar, G.MouseoverZoomBtns
local GetZoomBtnSize, GetMailIconSize, GetAddonBtnSize        = G.ZoomBtnSize, G.MailIconSize, G.AddonBtnSize
local GetProxyBtnSizeForKey                  = G.ProxyBtnSizeForKey
local GetZoneColor, GetCoordColor, GetTimeColor, GetDiffColor = G.ZoneColor, G.CoordColor, G.TimeColor, G.DiffColor
local GetPanelBgColor, GetPanelBorderColor   = G.PanelBgColor, G.PanelBorderColor
local GetDiffColorForName                    = G.DiffColorForName
-- Inlined on use: G.ButtonHandleButtons, G.ButtonDrawerLocked, G.ButtonWhitelist,
--                G.DiffLocked, G.TrackingBtnSize, G.CalendarBtnSize, G.QueueBtnSize,
--                G.ZoneVerticalPos/CoordVerticalPos/TimeVerticalPos, G.ElemX, G.ElemY

-- ============================================================================
-- BLIZZARD CHROME STRIP
-- ============================================================================

local KillFrame, KillFrameObj, StripBlizzardChrome, SuppressZoomButtons, HookMinimapClusterChildrenShow
do
    local CHROME_KILL_LIST = {
        "MinimapBorderTop", "MiniMapWorldMapButton",
        "MinimapCompassTexture", "MinimapBackdrop", "MinimapNorthTag",
        "MinimapZoneTextButton", "MiniMapInstanceDifficulty",
        "MinimapBorder",
        "MinimapZoomIn", "MinimapZoomOut",
        "GameTimeFrame",
        "AddonCompartmentFrame",
    }

    KillFrame = function(name)
        local frame = _G[name]
        if not frame then return end
        pcall(function()
            frame:Hide()
            frame:SetAlpha(0)
            frame.Show = function() end
        end)
    end

    KillFrameObj = function(f)
        if not f then return end
        pcall(function()
            f:Hide()
            f:SetAlpha(0)
            f.Show = function() end
        end)
    end

    -- Permanently suppress Blizzard zoom buttons — we draw our own on decor.
    SuppressZoomButtons = function()
        pcall(function()
            local function suppressBtn(btn)
                if not btn then return end
                btn:Hide(); btn:SetAlpha(0)
                btn.Show = function() end
                if hooksecurefunc and not btn._vistaZoomHooked then
                    btn._vistaZoomHooked = true
                    hooksecurefunc(btn, "SetPoint", function(self) self:SetAlpha(0) end)
                    hooksecurefunc(btn, "Show",     function(self) self:SetAlpha(0) end)
                end
            end
            suppressBtn(MinimapZoomIn);  suppressBtn(MinimapZoomOut)
            suppressBtn(Minimap and Minimap.ZoomIn)
            suppressBtn(Minimap and Minimap.ZoomOut)
        end)
    end

    HookMinimapClusterChildrenShow = function()
        if chromeSuppressHooked then return end
        chromeSuppressHooked = true
        pcall(function()
            if not MinimapCluster then return end
            for _, child in ipairs({ MinimapCluster:GetChildren() }) do
                if child ~= Minimap then
                    local cName = child:GetName()
                    if not cName or not cName:find("^HorizonSuite") then
                        if hooksecurefunc and not child._vistaShowHooked then
                            child._vistaShowHooked = true
                            pcall(function()
                                hooksecurefunc(child, "Show", function(self) self:SetAlpha(0) end)
                            end)
                        end
                    end
                end
            end
            if MinimapCluster.BorderTop and hooksecurefunc and not MinimapCluster.BorderTop._vistaShowHooked then
                MinimapCluster.BorderTop._vistaShowHooked = true
                pcall(function() hooksecurefunc(MinimapCluster.BorderTop, "Show", function(self) self:SetAlpha(0) end) end)
            end
            if MinimapCluster.Tracking and hooksecurefunc and not MinimapCluster.Tracking._vistaShowHooked then
                MinimapCluster.Tracking._vistaShowHooked = true
                pcall(function() hooksecurefunc(MinimapCluster.Tracking, "Show", function(self) self:SetAlpha(0) end) end)
                if MinimapCluster.Tracking.Background then
                    pcall(function() hooksecurefunc(MinimapCluster.Tracking.Background, "Show", function(self) self:SetAlpha(0) end) end)
                end
            end
        end)
    end

    StripBlizzardChrome = function()
        for _, name in ipairs(CHROME_KILL_LIST) do KillFrame(name) end
        SuppressZoomButtons()
        pcall(function()
            if not MinimapCluster then return end
            local subFrameNames = {
                "BorderTop", "Tracking", "ZoneTextButton",
                "InstanceDifficulty", "MailFrame", "CraftingOrderIcon",
                "GuildInstanceDifficulty", "DungeonDifficulty",
                "ZoomIn", "ZoomOut",
            }
            for _, key in ipairs(subFrameNames) do
                KillFrameObj(MinimapCluster[key])
                if MinimapCluster[key] then
                    for _, subVal in pairs(MinimapCluster[key]) do
                        if type(subVal) == "table" and subVal.Hide then KillFrameObj(subVal) end
                    end
                end
            end
            for _, child in ipairs({ MinimapCluster:GetChildren() }) do
                if child ~= Minimap then
                    local cName = child:GetName()
                    if not cName or not cName:find("^HorizonSuite") then
                        KillFrameObj(child)
                        for _, region in ipairs({ child:GetRegions() }) do
                            pcall(function() region:Hide(); region:SetAlpha(0) end)
                        end
                        for _, grandchild in ipairs({ child:GetChildren() }) do KillFrameObj(grandchild) end
                    end
                end
            end
            for _, region in ipairs({ MinimapCluster:GetRegions() }) do
                pcall(function() region:Hide(); region:SetAlpha(0) end)
            end
        end)
        pcall(function()
            for _, region in ipairs({ Minimap:GetRegions() }) do
                if region then pcall(function() region:SetAlpha(0); region:Hide() end) end
            end
        end)
        pcall(function()
            Minimap:SetArchBlobRingScalar(0); Minimap:SetArchBlobRingAlpha(0)
            Minimap:SetQuestBlobRingScalar(0); Minimap:SetQuestBlobRingAlpha(0)
        end)
        pcall(function()
            if MinimapZoneText then MinimapZoneText:Hide(); MinimapZoneText:SetAlpha(0) end
        end)
    end
end -- end chrome do-block

-- ============================================================================
-- STATE
-- ============================================================================

local decor, circularBorderFrame
local borderTextures = {}
local zoneText, zoneShadow, diffText, diffShadow
local coordText, coordShadow, timeText, timeShadow
local mailFrame, mailPulsing
local collectorBar, barAnchor
local collectedButtons, drawerPanelButtons = {}, {}
local barAlpha, hoverTarget, hoverElapsed = 0, 0, 0
local barCloseDelayElapsed = 0  -- tracks how long we've been "waiting to close"
local barAnchorDragging = false -- true while the anchor is being dragged
local barFlashTimer = nil  -- C_Timer handle for the "flash visible for positioning" effect
local coordElapsed, timeElapsed = 0, 0
local hookedButtons = {}
local setParentHook, eventFrame
local drawerButton, drawerPanel
local drawerOpen = false
local rightClickPanel, rightClickVisible = nil, false
local zoomInBtn, zoomOutBtn
local defaultProxies = {}
local queueAnchor  -- dedicated draggable anchor for QueueStatusButton
local vistaLastKnownZone, autoZoomTimer

-- ============================================================================
-- DRAGGABLE ELEMENT HELPER
-- ============================================================================

-- Makes `frame` draggable. On drag-stop saves the position as an offset
-- relative to `relFrame` using anchors from `getAnchors()`.
-- `getAnchors` is a function returning (anchorPoint, relPoint) for the current vertical position.
-- `lockKey` is the DB key for the lock toggle. `xKey`/`yKey` are where we persist offsets.
local function MakeDraggable(frame, lockKey, xKey, yKey, getAnchors, relFrame)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if DB("vistaLocked_" .. lockKey, false) then return end
        if InCombatLockdown() then return end
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local anchorPoint, relPoint = getAnchors()
        -- Compute offset relative to relFrame so the element keeps following it.
        -- After StopMovingOrSizing, WoW re-anchors to BOTTOMLEFT/UIParent.
        local sx, sy = self:GetCenter()
        local rx, ry = relFrame:GetCenter()
        local relW, relH = relFrame:GetSize()
        local selfW, selfH = self:GetSize()
        local ox, oy
        -- Bottom position (element below minimap)
        if anchorPoint == "TOP" and relPoint == "BOTTOM" then
            ox = sx - rx
            oy = (sy + selfH / 2) - (ry - relH / 2)
        elseif anchorPoint == "TOPRIGHT" and relPoint == "BOTTOMRIGHT" then
            ox = (sx + selfW / 2) - (rx + relW / 2)
            oy = (sy + selfH / 2) - (ry - relH / 2)
        elseif anchorPoint == "TOPLEFT" and relPoint == "BOTTOMLEFT" then
            ox = (sx - selfW / 2) - (rx - relW / 2)
            oy = (sy + selfH / 2) - (ry - relH / 2)
        -- Top position (element above minimap)
        elseif anchorPoint == "BOTTOM" and relPoint == "TOP" then
            ox = sx - rx
            oy = (sy - selfH / 2) - (ry + relH / 2)
        elseif anchorPoint == "BOTTOMRIGHT" and relPoint == "TOPRIGHT" then
            ox = (sx + selfW / 2) - (rx + relW / 2)
            oy = (sy - selfH / 2) - (ry + relH / 2)
        elseif anchorPoint == "BOTTOMLEFT" and relPoint == "TOPLEFT" then
            ox = (sx - selfW / 2) - (rx - relW / 2)
            oy = (sy - selfH / 2) - (ry + relH / 2)
        else
            ox = sx - rx
            oy = sy - ry
        end
        SetDB("vistaEX_" .. xKey, ox)
        SetDB("vistaEY_" .. yKey, oy)
        self:ClearAllPoints()
        self:SetPoint(anchorPoint, relFrame, relPoint, ox, oy)
    end)
end

-- ============================================================================
-- AUTO ZOOM
-- ============================================================================


local function ScheduleAutoZoom()
    -- Cancel any in-flight timer first so re-enable after 0 works correctly.
    if autoZoomTimer then
        autoZoomTimer:Cancel()
        autoZoomTimer = nil
    end
    local autoZoom = tonumber(DB("vistaAutoZoom", 5)) or 0
    if autoZoom <= 0 then return end
    autoZoomTimer = C_Timer.NewTimer(autoZoom, function()
        autoZoomTimer = nil
        for _ = 1, Minimap:GetZoom() or 0 do
            if Minimap_ZoomOutClick then Minimap_ZoomOutClick()
            elseif Minimap.ZoomOut then Minimap.ZoomOut:Click() end
        end
    end)
end
Vista.ScheduleAutoZoom = ScheduleAutoZoom

-- ============================================================================
-- MINIMAP SETUP
-- ============================================================================

local function SetupMinimap()
    local pt    = DB("vistaPoint",    nil)
    local rp    = DB("vistaRelPoint", nil)
    local vx    = DB("vistaX",        nil)
    local vy    = DB("vistaY",        nil)
    local scale = DB("vistaScale",    1.0)

    local sz = GetMapSize()
    local mapScale = sz / MINIMAP_BASE_SIZE
    Minimap:SetSize(MINIMAP_BASE_SIZE, MINIMAP_BASE_SIZE)
    Minimap:SetMaskTexture(GetCircular() and MASK_CIRCULAR or MASK_SQUARE)

    if pt then
        proxy.ClearAllPoints(Minimap)
        proxy.SetPoint(Minimap, pt, UIParent, rp or pt, vx or 0, vy or 0)
    else
        proxy.ClearAllPoints(Minimap)
        proxy.SetPoint(Minimap, DEFAULT_POINT, UIParent, DEFAULT_RELPOINT, DEFAULT_X, DEFAULT_Y)
    end

    if hooksecurefunc and not Vista._setPointHooked then
        Vista._setPointHooked = true
        hooksecurefunc(Minimap, "SetPoint", function()
            if not addon:IsModuleEnabled("vista") then return end
            local dpt = DB("vistaPoint", nil)
            if dpt then
                proxy.ClearAllPoints(Minimap)
                proxy.SetPoint(Minimap, dpt, UIParent, DB("vistaRelPoint", dpt) or dpt, DB("vistaX", 0) or 0, DB("vistaY", 0) or 0)
            end
        end)
    end

    local moduleScale = (addon.GetModuleScale and addon.GetModuleScale("vista")) or 1
    proxy.SetScale(Minimap, (scale or 1.0) * moduleScale * mapScale)
    Minimap:Show()
    Minimap:SetAlpha(1)
end

-- ============================================================================
-- BORDER HELPERS
-- ============================================================================

local function ApplyBorderTextures()
    if not decor then return end
    local show       = GetBorderShow()
    local bw         = GetBorderW()
    local r, g, b, a = GetBorderColor()
    local isCircular = GetCircular()

    if isCircular and circularBorderFrame then
        -- Hide the four rectangular border lines
        for _, tex in pairs(borderTextures) do
            if tex then tex:Hide() end
        end
        -- Show/update the circular ring border
        if show then
            local sz = GetMapSize()
            circularBorderFrame:SetSize(sz + bw * 2, sz + bw * 2)
            circularBorderFrame:ClearAllPoints()
            circularBorderFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
            circularBorderFrame._tex:SetColorTexture(r, g, b, a)
            circularBorderFrame:Show()
        else
            circularBorderFrame:Hide()
        end
        return
    end

    -- Square mode: hide circular ring, show rect borders
    if circularBorderFrame then circularBorderFrame:Hide() end

    for _, tex in pairs(borderTextures) do
        if tex then
            tex:SetColorTexture(r, g, b, a)
            if show then tex:Show() else tex:Hide() end
        end
    end

    if borderTextures.top then
        borderTextures.top:ClearAllPoints()
        borderTextures.top:SetHeight(bw)
        borderTextures.top:SetPoint("TOPLEFT",  Minimap, "TOPLEFT",  0,  bw)
        borderTextures.top:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0,  bw)
    end
    if borderTextures.bottom then
        borderTextures.bottom:ClearAllPoints()
        borderTextures.bottom:SetHeight(bw)
        borderTextures.bottom:SetPoint("BOTTOMLEFT",  Minimap, "BOTTOMLEFT",  0, -bw)
        borderTextures.bottom:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, -bw)
    end
    if borderTextures.left then
        borderTextures.left:ClearAllPoints()
        borderTextures.left:SetWidth(bw)
        borderTextures.left:SetPoint("TOPLEFT",    Minimap, "TOPLEFT",    -bw,  bw)
        borderTextures.left:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -bw, -bw)
    end
    if borderTextures.right then
        borderTextures.right:ClearAllPoints()
        borderTextures.right:SetWidth(bw)
        borderTextures.right:SetPoint("TOPRIGHT",    Minimap, "TOPRIGHT",    bw,  bw)
        borderTextures.right:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", bw, -bw)
    end
end

-- ============================================================================
-- DECOR CREATION
-- ============================================================================

local function CreateDecor()
    decor = CreateFrame("Frame", "HorizonSuiteVistaDecor", Minimap)
    decor:SetAllPoints(Minimap)
    decor:SetFrameLevel(Minimap:GetFrameLevel() + 5)

    local function MakeBorderTex(name)
        local t = decor:CreateTexture(nil, "OVERLAY")
        borderTextures[name] = t
        return t
    end
    MakeBorderTex("top"); MakeBorderTex("bottom"); MakeBorderTex("left"); MakeBorderTex("right")

    -- Circular border ring is rendered as a masked color circle behind Minimap.
    -- The inside is covered by Minimap itself, leaving a clean visible rim outside.
    -- Parent to Minimap's parent so we're not clipped by Minimap's circular mask.
    local minimapParent = Minimap:GetParent()
    if minimapParent then
        circularBorderFrame = CreateFrame("Frame", "HorizonSuiteVistaCircularBorder", minimapParent)
        circularBorderFrame:SetFrameStrata(Minimap:GetFrameStrata())
        circularBorderFrame:SetFrameLevel(math.max((Minimap:GetFrameLevel() or 1) - 1, 0))
        circularBorderFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
        circularBorderFrame:SetSize(GetMapSize(), GetMapSize())
        local cbt = circularBorderFrame:CreateTexture(nil, "OVERLAY")
        cbt:SetColorTexture(1, 1, 1, 1)
        cbt:SetAllPoints()
        local mask = circularBorderFrame:CreateMaskTexture(nil, "OVERLAY")
        mask:SetTexture(MASK_CIRCULAR, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        mask:SetAllPoints(cbt)
        cbt:AddMaskTexture(mask)
        circularBorderFrame._tex = cbt
        circularBorderFrame._mask = mask
        circularBorderFrame:Hide()
    end

    ApplyBorderTextures()

    -- Draggable minimap
    Minimap:SetMovable(true)
    Minimap:SetClampedToScreen(true)
    Minimap:RegisterForDrag("LeftButton")
    Minimap:SetScript("OnDragStart", function(self)
        local lock = DB("vistaLock", true)
        if not lock and self:IsMovable() then
            if not InCombatLockdown() then self:StartMoving() end
        end
    end)
    Minimap:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
        self:StopMovingOrSizing()
        if not addon.SetDB then return end
        local p, _, rp, x, y = self:GetPoint()
        SetDB("vistaPoint", p); SetDB("vistaRelPoint", rp)
        SetDB("vistaX", x);     SetDB("vistaY", y)
    end)

    -- Mouse wheel zoom
    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(_, d)
        if d > 0 then
            if MinimapZoomIn  then MinimapZoomIn:Click()  elseif Minimap.ZoomIn  then Minimap.ZoomIn:Click()  end
        else
            if MinimapZoomOut then MinimapZoomOut:Click() elseif Minimap.ZoomOut then Minimap.ZoomOut:Click() end
        end
    end)

    pcall(function()
        if MinimapZoomIn then
            MinimapZoomIn:HookScript("OnClick",  ScheduleAutoZoom)
            MinimapZoomOut:HookScript("OnClick", ScheduleAutoZoom)
        elseif Minimap.ZoomIn then
            Minimap.ZoomIn:HookScript("OnClick",  ScheduleAutoZoom)
            Minimap.ZoomOut:HookScript("OnClick", ScheduleAutoZoom)
        end
    end)
    Minimap:HookScript("OnMouseWheel", ScheduleAutoZoom)

    -- ---- Zone text (in a draggable container) ----
    local zoneContainer = CreateFrame("Frame", nil, decor)
    zoneContainer:SetSize(GetMapSize(), 20)
    local zAp, zRp = GetZoneAnchors()
    zoneContainer:SetPoint(zAp, Minimap, zRp, GetZoneOffsetX(), GetZoneOffsetY())
    zoneContainer:SetFrameLevel(decor:GetFrameLevel() + 1)
    MakeDraggable(zoneContainer, "zone", "zone", "zone", GetZoneAnchors, Minimap)

    -- Primary line (zone name, or subzone in subzone-only mode)
    zoneShadow = zoneContainer:CreateFontString(nil, "BORDER")
    zoneShadow:SetFont(GetZoneFont(), GetZoneSize(), "OUTLINE")
    zoneShadow:SetTextColor(0, 0, 0, SHADOW_A)
    zoneShadow:SetJustifyH("CENTER")
    zoneShadow:SetPoint("TOPLEFT", zoneContainer, "TOPLEFT")
    zoneShadow:SetPoint("TOPRIGHT", zoneContainer, "TOPRIGHT")

    zoneText = zoneContainer:CreateFontString(nil, "OVERLAY")
    zoneText:SetFont(GetZoneFont(), GetZoneSize(), "OUTLINE")
    zoneText:SetTextColor(unpack(ZONE_COLOR_DEFAULT))
    zoneText:SetJustifyH("CENTER")
    zoneText:SetPoint("TOPLEFT", zoneContainer, "TOPLEFT")
    zoneText:SetPoint("TOPRIGHT", zoneContainer, "TOPRIGHT")

    -- Secondary line (subzone, only shown in "both" mode)
    local subZoneShadow = zoneContainer:CreateFontString(nil, "BORDER")
    subZoneShadow:SetFont(GetZoneFont(), GetZoneSize(), "OUTLINE")
    subZoneShadow:SetTextColor(0, 0, 0, SHADOW_A)
    subZoneShadow:SetJustifyH("CENTER")
    subZoneShadow:SetPoint("TOPLEFT", zoneText, "BOTTOMLEFT", 0, -2)
    subZoneShadow:SetPoint("TOPRIGHT", zoneText, "BOTTOMRIGHT", 0, -2)

    local subZoneText = zoneContainer:CreateFontString(nil, "OVERLAY")
    subZoneText:SetFont(GetZoneFont(), GetZoneSize(), "OUTLINE")
    subZoneText:SetTextColor(GetZoneColor())
    subZoneText:SetJustifyH("CENTER")
    subZoneText:SetPoint("TOPLEFT", zoneText, "BOTTOMLEFT", 0, -2)
    subZoneText:SetPoint("TOPRIGHT", zoneText, "BOTTOMRIGHT", 0, -2)

    zoneContainer._subZoneText   = subZoneText
    zoneContainer._subZoneShadow = subZoneShadow

    -- ---- Difficulty text (in a draggable container) ----
    local diffContainer = CreateFrame("Frame", nil, decor)
    diffContainer:SetSize(GetMapSize(), 20)
    diffContainer:SetPoint("TOP", zoneText, "BOTTOM", 0, -2)
    diffContainer:SetFrameLevel(decor:GetFrameLevel() + 1)
    MakeDraggable(diffContainer, "diff", "diff", "diff", function() return "TOP", "BOTTOM" end, zoneText)

    diffShadow = diffContainer:CreateFontString(nil, "BORDER")
    diffShadow:SetFont(GetDiffFont(), GetDiffSize(), "OUTLINE")
    diffShadow:SetTextColor(0, 0, 0, SHADOW_A)
    diffShadow:SetJustifyH("CENTER")
    diffShadow:SetAllPoints()

    diffText = diffContainer:CreateFontString(nil, "OVERLAY")
    diffText:SetFont(GetDiffFont(), GetDiffSize(), "OUTLINE")
    diffText:SetTextColor(GetDiffColor())
    diffText:SetJustifyH("CENTER")
    diffText:SetAllPoints()
    diffText:SetWidth(GetMapSize())
    diffShadow:SetAllPoints(diffText)

    decor._diffContainer = diffContainer

    -- ---- Coord text (in a draggable container) ----
    local coordContainer = CreateFrame("Frame", nil, decor)
    coordContainer:SetSize(120, 16)
    local cAp, cRp = GetCoordAnchors()
    coordContainer:SetPoint(cAp, Minimap, cRp, GetCoordOffsetX(), GetCoordOffsetY())
    coordContainer:SetFrameLevel(decor:GetFrameLevel() + 1)
    MakeDraggable(coordContainer, "coord", "coord", "coord", GetCoordAnchors, Minimap)

    coordShadow = coordContainer:CreateFontString(nil, "BORDER")
    coordShadow:SetFont(GetCoordFont(), GetCoordSize(), "OUTLINE")
    coordShadow:SetTextColor(0, 0, 0, SHADOW_A)
    coordShadow:SetJustifyH("RIGHT")
    coordShadow:SetAllPoints()

    coordText = coordContainer:CreateFontString(nil, "OVERLAY")
    coordText:SetFont(GetCoordFont(), GetCoordSize(), "OUTLINE")
    coordText:SetTextColor(unpack(COORD_COLOR_DEFAULT))
    coordText:SetJustifyH("RIGHT")
    coordText:SetAllPoints()

    -- ---- Time text (in a draggable container) ----
    -- Use Button (not Frame) so it handles both click (open time manager) and drag (reposition), same as zone/coord
    local TIME_PAD = 4
    local timeContainer = CreateFrame("Button", nil, decor)
    timeContainer:SetSize(60, 16)
    local tAp, tRp = GetTimeAnchors()
    timeContainer:SetPoint(tAp, Minimap, tRp, GetTimeOffsetX(), GetTimeOffsetY())
    timeContainer:SetFrameLevel(decor:GetFrameLevel() + 1)
    MakeDraggable(timeContainer, "time", "time", "time", GetTimeAnchors, Minimap)

    timeShadow = timeContainer:CreateFontString(nil, "BORDER")
    timeShadow:SetFont(GetTimeFont(), GetTimeSize(), "OUTLINE")
    timeShadow:SetTextColor(0, 0, 0, SHADOW_A)
    timeShadow:SetJustifyH("LEFT")
    timeShadow:SetPoint("TOPLEFT", timeContainer, "TOPLEFT", TIME_PAD, 0)
    timeShadow:SetPoint("BOTTOMRIGHT", timeContainer, "BOTTOMRIGHT", -TIME_PAD, 0)

    timeText = timeContainer:CreateFontString(nil, "OVERLAY")
    timeText:SetFont(GetTimeFont(), GetTimeSize(), "OUTLINE")
    timeText:SetTextColor(unpack(COORD_COLOR_DEFAULT))
    timeText:SetJustifyH("LEFT")
    timeText:SetPoint("TOPLEFT", timeContainer, "TOPLEFT", TIME_PAD, 0)
    timeText:SetPoint("BOTTOMRIGHT", timeContainer, "BOTTOMRIGHT", -TIME_PAD, 0)

    -- Resize container to fit text width each time text changes
    local function ResizeTimeContainer()
        local w = timeText:GetStringWidth()
        if w and w > 0 then
            timeContainer:SetWidth(w + TIME_PAD * 2)
        end
    end
    -- Hook into UpdateTimeText via a timer-based resize
    local timeResizeElapsed = 0
    timeContainer:SetScript("OnUpdate", function(_, elapsed)
        timeResizeElapsed = timeResizeElapsed + elapsed
        if timeResizeElapsed < 0.5 then return end
        timeResizeElapsed = 0
        ResizeTimeContainer()
    end)

    -- Click opens time manager (same frame handles drag via MakeDraggable)
    timeContainer:RegisterForClicks("LeftButtonUp")
    timeContainer:SetScript("OnClick", function()
        pcall(function()
            if TimeManagerFrame then
                if TimeManagerFrame:IsShown() then TimeManagerFrame:Hide() else TimeManagerFrame:Show() end
            elseif _G["ToggleTimeManager"] then
                ToggleTimeManager()
            else
                local btn = TimeManagerClockButton
                if btn then
                    btn.Show = nil; btn:Show()
                    local s = btn:GetScript("OnClick")
                    if s then s(btn, "LeftButton") else btn:Click("LeftButton") end
                    btn:Hide(); btn.Show = function() end
                end
            end
        end)
    end)
    timeContainer:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText("Open Stopwatch")
        GameTooltip:Show()
    end)
    timeContainer:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- store containers for ApplyOptions
    decor._zoneContainer  = zoneContainer
    decor._coordContainer = coordContainer
    decor._timeContainer  = timeContainer

    -- Apply initial visibility
    local showZone  = GetShowZone()
    local showCoord = GetShowCoord()
    local showTime  = GetShowTime()
    zoneText:SetShown(showZone);   zoneShadow:SetShown(showZone);   zoneContainer:SetShown(showZone)
    coordText:SetShown(showCoord); coordShadow:SetShown(showCoord); coordContainer:SetShown(showCoord)
    timeText:SetShown(showTime);   timeShadow:SetShown(showTime);   timeContainer:SetShown(showTime)
end

-- ============================================================================
-- TEXT UPDATES
-- ============================================================================


local function UpdateZoneText()
    if not zoneText then return end
    local mode = GetZoneDisplayMode()
    local zone = GetZoneText() or ""
    local sub  = GetSubZoneText and GetSubZoneText() or ""
    if zone ~= "" then vistaLastKnownZone = zone end

    -- Interior zones: WoW sets zone=building, sub=parent — detect and swap
    local isInterior = vistaLastKnownZone and sub ~= "" and sub == vistaLastKnownZone
    local displayZone = isInterior and sub or zone
    local displaySub  = (isInterior and zone ~= "" and zone ~= displayZone) and zone or sub
    local hasSub = displaySub ~= "" and displaySub ~= displayZone

    local container = decor and decor._zoneContainer
    local subText   = container and container._subZoneText
    local subShadow = container and container._subZoneShadow

    if mode == "subzone" then
        local text = hasSub and displaySub or displayZone
        zoneText:SetText(text); zoneShadow:SetText(text)
        if subText then subText:SetText(""); subShadow:SetText("") end
        if container then container:SetHeight(zoneText:GetStringHeight() + 2) end
    elseif mode == "both" then
        zoneText:SetText(displayZone); zoneShadow:SetText(displayZone)
        if subText then
            if hasSub then
                subText:SetText(displaySub);  subShadow:SetText(displaySub)
                subText:Show();  subShadow:Show()
            else
                subText:SetText(""); subShadow:SetText("")
                subText:Hide();  subShadow:Hide()
            end
        end
        if container then
            local h = zoneText:GetStringHeight() + 2
            if hasSub and subText then h = h + subText:GetStringHeight() + 4 end
            container:SetHeight(h)
        end
    else  -- "zone"
        zoneText:SetText(displayZone); zoneShadow:SetText(displayZone)
        if subText then subText:SetText(""); subShadow:SetText("") end
        if container then container:SetHeight(zoneText:GetStringHeight() + 2) end
    end
end

local function UpdateDifficultyText()
    if not diffText then return end
    local _, instanceType, difficultyID = GetInstanceInfo()
    if instanceType == "none" or difficultyID == 0 then
        diffText:SetText(""); diffShadow:SetText(""); return
    end
    local diffName = GetDifficultyInfo(difficultyID)
    if not diffName or diffName == "" then
        diffText:SetText(""); diffShadow:SetText(""); return
    end
    if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        local keystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
        if keystoneLevel and keystoneLevel > 0 then diffName = diffName .. " +" .. keystoneLevel end
    end
    local r, g, b = GetDiffColorForName(diffName)
    diffText:SetTextColor(r, g, b)
    diffShadow:SetTextColor(0, 0, 0, SHADOW_A)
    diffText:SetText(diffName); diffShadow:SetText(diffName)
end

local function UpdateCoords(_, elapsed)
    if not coordText or not GetShowCoord() then return end
    coordElapsed = coordElapsed + elapsed
    if coordElapsed < COORD_THROTTLE then return end
    coordElapsed = 0
    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID and C_Map.GetPlayerMapPosition then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                local x, y = pos:GetXY()
                local prec = G.CoordPrecision()
                local fmt = prec == 0 and "%.0f, %.0f" or (prec == 2 and "%.2f, %.2f" or "%.1f, %.1f")
                local str = format(fmt, x * 100, y * 100)
                coordText:SetText(str); coordShadow:SetText(str)
                return
            end
        end
    end
    coordText:SetText("--"); coordShadow:SetText("--")
end

local function UpdateTimeText(_, elapsed)
    if not timeText or not GetShowTime() then return end
    timeElapsed = timeElapsed + elapsed
    if timeElapsed < TIME_THROTTLE then return end
    timeElapsed = 0
    local str
    if GetTimeUseLocal() then
        local t = date("*t")
        if not t then return end
        local hours, minutes = t.hour, t.min
        local use24 = GetCVar and GetCVar("timeMgrUseMilitaryTime") == "1"
        if use24 then
            str = format("%02d:%02d", hours, minutes)
        else
            local period = hours >= 12 and "PM" or "AM"
            hours = hours % 12
            if hours == 0 then hours = 12 end
            str = format("%d:%02d %s", hours, minutes, period)
        end
    else
        local hours, minutes = GetGameTime()
        if hours == nil then return end
        local use24 = GetCVar and GetCVar("timeMgrUseMilitaryTime") == "1"
        if use24 then
            str = format("%02d:%02d", hours, minutes)
        else
            local period = hours >= 12 and "PM" or "AM"
            hours = hours % 12
            if hours == 0 then hours = 12 end
            str = format("%d:%02d %s", hours, minutes, period)
        end
    end
    timeText:SetText(str); timeShadow:SetText(str)
end

-- ============================================================================
-- MAIL INDICATOR
-- ============================================================================

local function CreateMailIndicator()
    mailFrame = CreateFrame("Frame", nil, decor)
    mailFrame:SetSize(GetMailIconSize(), GetMailIconSize())
    mailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 4, -4)
    mailFrame:SetFrameLevel(decor:GetFrameLevel() + 2)
    mailFrame:Hide()

    local icon = mailFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\MINIMAP\\TRACKING\\Mailbox")
    icon:SetAllPoints(); icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    mailFrame.icon = icon

    mailFrame:EnableMouse(true)
    mailFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText("You have mail"); GameTooltip:Show()
    end)
    mailFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local pulseTime = 0
    mailFrame:SetScript("OnUpdate", function(self, elapsed)
        if not mailPulsing or not G.MailBlink() then self.icon:SetAlpha(1); return end
        pulseTime = pulseTime + elapsed
        local t = (math.sin(pulseTime * PULSE_SPEED * math.pi * 2) + 1) / 2
        self.icon:SetAlpha(PULSE_MIN + (PULSE_MAX - PULSE_MIN) * t)
    end)
end

local function UpdateMailIndicator()
    if not mailFrame then return end
    local hasMail = HasNewMail()
    if hasMail then mailFrame:Show(); mailPulsing = true
    else mailFrame:Hide(); mailPulsing = false end
end

local function SuppressBlizzardMail()
    pcall(function()
        if MiniMapMailFrame then
            MiniMapMailFrame:Hide(); MiniMapMailFrame:SetAlpha(0)
            MiniMapMailFrame.Show = function() end
        end
    end)
    pcall(function()
        if MinimapCluster and MinimapCluster.IndicatorFrame then
            local ind = MinimapCluster.IndicatorFrame
            if ind.MailFrame then
                ind.MailFrame:Hide(); ind.MailFrame:SetAlpha(0)
                ind.MailFrame.Show = function() end
            end
            ind:Hide(); ind:SetAlpha(0); ind.Show = function() end
        end
    end)
    pcall(function()
        if MiniMapMailIcon then
            MiniMapMailIcon:Hide(); MiniMapMailIcon:SetAlpha(0)
            MiniMapMailIcon.Show = function() end
        end
    end)
end

-- ============================================================================
-- OUR OWN ZOOM BUTTONS
-- ============================================================================

local function CreateZoomButtons()
    -- Parent to UIParent so zoom buttons work when minimap is locked (Minimap:SetMovable(false)
    -- can block child input; UIParent children are unaffected)
    local zoomParent = UIParent
    local function makeZoomBtn(lockKey, defaultXOff, zoomDelta)
        local label = zoomDelta > 0 and "+" or "-"
        local btn = CreateFrame("Button", nil, zoomParent)
        btn:SetSize(GetZoomBtnSize(), GetZoomBtnSize())
        btn:SetFrameLevel(decor:GetFrameLevel() + 10)

        -- Restore saved position or use default BOTTOMRIGHT offset
        -- Positions are stored as CENTER offset relative to Minimap CENTER
        local savedX = tonumber(DB("vistaEX_" .. lockKey, nil))
        local savedY = tonumber(DB("vistaEY_" .. lockKey, nil))
        if savedX and savedY then
            btn:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
        else
            btn:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", defaultXOff, 2)
        end

        -- No background — outline text over the map
        local zoomFontSize = math.max(10, math.floor(GetZoomBtnSize() * 0.875))
        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(FONT_PATH_DEFAULT, zoomFontSize, "OUTLINE")
        lbl:SetText(label)
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER"); lbl:SetJustifyV("MIDDLE")
        btn._label = lbl

        -- Draggable
        btn:SetMovable(true)
        btn:SetClampedToScreen(true)
        btn:RegisterForDrag("LeftButton")
        btn:SetScript("OnDragStart", function(self)
            if DB("vistaLocked_" .. lockKey, true) then return end
            if InCombatLockdown() then return end
            self:StartMoving()
        end)
        btn:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            -- Save position as offset from Minimap center so button follows minimap
            local mx, my = Minimap:GetCenter()
            local bx, by = self:GetCenter()
            local ox, oy = bx - mx, by - my
            SetDB("vistaEX_" .. lockKey, ox)
            SetDB("vistaEY_" .. lockKey, oy)
            self:ClearAllPoints()
            self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
        end)

        btn:SetScript("OnClick", function()
            local cur = Minimap:GetZoom() or 0
            local new = math.max(0, math.min(Minimap:GetZoomLevels() or 5, cur + zoomDelta))
            Minimap:SetZoom(new)
            ScheduleAutoZoom()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:SetText(zoomDelta > 0 and "Zoom In" or "Zoom Out")
            if not DB("vistaLocked_" .. lockKey, true) then
                GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end

    -- ZoomIn on the far right, ZoomOut just to its left
    zoomInBtn  = makeZoomBtn("zoomIn",  -2,  1)
    zoomOutBtn = makeZoomBtn("zoomOut", -20, -1)

    -- Apply initial zoom button visibility
    local function ApplyZoomButtonVisibility()
        if not zoomInBtn or not zoomOutBtn then return end
        local show      = GetShowZoomBtns()
        local mouseover = GetMouseoverZoomBtns()
        if not show then
            zoomInBtn:Hide(); zoomOutBtn:Hide()
        elseif mouseover then
            -- Shown but invisible; becomes visible on hover of the button itself
            zoomInBtn:SetAlpha(0); zoomOutBtn:SetAlpha(0)
            zoomInBtn:Show(); zoomOutBtn:Show()
        else
            zoomInBtn:SetAlpha(1); zoomOutBtn:SetAlpha(1)
            zoomInBtn:Show(); zoomOutBtn:Show()
        end
    end
    ApplyZoomButtonVisibility()

    -- Per-button mouseover: show only when hovering the individual zoom button
    local function hookZoomMouseover(btn)
        btn:HookScript("OnEnter", function(self)
            if GetShowZoomBtns() and GetMouseoverZoomBtns() then
                self:SetAlpha(1)
            end
        end)
        btn:HookScript("OnLeave", function(self)
            if GetShowZoomBtns() and GetMouseoverZoomBtns() then
                self:SetAlpha(0)
            end
        end)
    end
    hookZoomMouseover(zoomInBtn)
    hookZoomMouseover(zoomOutBtn)
end

-- ============================================================================
-- DEFAULT BUTTON PROXIES  (tracking, calendar/landing page)
-- ============================================================================

local SuppressDefaultBlizzardButtons, CreateDefaultButtonProxies
do
local DEFAULT_BTN_DEFS = {
    {
        key     = "tracking",
        names   = { "MiniMapTracking", "MinimapTrackingFrame", "MiniMapTrackingButton" },
        anchor  = "TOPRIGHT",
        xOff    = -4, yOff = -4,
        tooltip = "Tracking",
        getIcon = function()
            -- Walk MiniMapTracking regions for the current tracking icon texture
            if MiniMapTracking then
                for _, r in ipairs({ MiniMapTracking:GetRegions() }) do
                    if r and r:IsObjectType("Texture") then
                        local t = r:GetTexture()
                        if t and type(t) == "string" and t ~= ""
                            and not t:lower():find("highlight")
                            and not t:lower():find("pushed")
                            and not t:lower():find("border") then
                            return t
                        end
                    end
                end
            end
            return "Interface\\MINIMAP\\TRACKING\\None"
        end,
        onClick = function(self, btn)
            -- Build a tracking menu using C_Minimap API directly.
            -- This is independent of any Blizzard frame that StripBlizzardChrome may kill.
            pcall(function()
                if not C_Minimap or not C_Minimap.GetNumTrackingTypes then return end
                -- Create/reuse a simple dropdown menu frame
                if not Vista._trackingMenu then
                    local menu = CreateFrame("Frame", "HorizonSuiteTrackingMenu", UIParent, "BackdropTemplate")
                    menu:SetFrameStrata("TOOLTIP")
                    menu:SetClampedToScreen(true)
                    menu:SetBackdrop({
                        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
                        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                        edgeSize = 12,
                        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
                    })
                    menu:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
                    menu:SetBackdropBorderColor(0.3, 0.4, 0.6, 0.8)
                    menu:EnableMouse(true)
                    menu:Hide()
                    menu._rows = {}
                    menu:SetScript("OnLeave", function(s)
                        C_Timer.After(0.2, function()
                            if s and not s:IsMouseOver() then s:Hide() end
                        end)
                    end)
                    Vista._trackingMenu = menu
                end
                local menu = Vista._trackingMenu
                if menu:IsShown() then menu:Hide(); return end

                -- Clear old rows
                for _, row in ipairs(menu._rows) do row:Hide() end

                local numTypes = C_Minimap.GetNumTrackingTypes()
                local rowIdx = 0
                local ROW_H = 20
                local PAD = 6
                local maxW = 120

                for i = 1, numTypes do
                    local info = C_Minimap.GetTrackingInfo(i)
                    if info then
                        rowIdx = rowIdx + 1
                        local row = menu._rows[rowIdx]
                        if not row then
                            row = CreateFrame("Button", nil, menu)
                            row:SetHeight(ROW_H)
                            row._icon = row:CreateTexture(nil, "ARTWORK")
                            row._icon:SetSize(16, 16)
                            row._icon:SetPoint("LEFT", row, "LEFT", 4, 0)
                            row._check = row:CreateTexture(nil, "OVERLAY")
                            row._check:SetSize(12, 12)
                            row._check:SetPoint("LEFT", row._icon, "RIGHT", 2, 0)
                            row._check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                            row._label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                            row._label:SetPoint("LEFT", row._check, "RIGHT", 2, 0)
                            row._label:SetJustifyH("LEFT")
                            row._hl = row:CreateTexture(nil, "HIGHLIGHT")
                            row._hl:SetAllPoints()
                            row._hl:SetColorTexture(1, 1, 1, 0.1)
                            menu._rows[rowIdx] = row
                        end
                        row:SetPoint("TOPLEFT", menu, "TOPLEFT", PAD, -(PAD + (rowIdx - 1) * ROW_H))
                        row:SetPoint("RIGHT", menu, "RIGHT", -PAD, 0)
                        row._icon:SetTexture(info.texture)
                        row._label:SetText(info.name or "")
                        row._check:SetShown(info.active)
                        local w = (row._label:GetStringWidth() or 0) + 48
                        if w > maxW then maxW = w end
                        local trackIdx = i
                        row:SetScript("OnClick", function()
                            C_Minimap.SetTracking(trackIdx, not info.active)
                            menu:Hide()
                        end)
                        row:Show()
                    end
                end

                if rowIdx == 0 then return end
                menu:SetSize(maxW + PAD * 2, PAD * 2 + rowIdx * ROW_H)
                menu:ClearAllPoints()
                menu:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -2)
                menu:Show()
            end)
        end,
    },
    {
        key     = "calendar",
        names   = { "GameTimeFrame" },
        anchor  = "TOPLEFT",
        xOff    = 4, yOff = -4,
        tooltip = "Calendar",
        getIcon = function()
            return nil  -- we use SetAtlas below; nil means skip SetTexture
        end,
        setIcon = function(iconTex)
            -- Use a clean calendar icon without the circular minimap frame.
            -- Try the Calendarbutton atlas first (just the page, no circle).
            local ok = pcall(function() iconTex:SetAtlas("CalendarButton") end)
            if ok and iconTex:GetAtlas() and iconTex:GetAtlas() ~= "" then
                iconTex:SetTexCoord(0, 1, 0, 1)
                return
            end
            -- Fallback: inventory calendar/note icon (clean, no circle)
            iconTex:SetTexture("Interface\\Icons\\INV_Misc_Note_06")
            iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end,
        onClick = function(_, btn)
            pcall(function()
                local target = _G["GameTimeFrame"]
                if target then
                    target.Show = nil; target:Show()
                    target:Click(btn or "LeftButton")
                    target:Hide(); target.Show = function() end
                end
            end)
        end,
    },
}

SuppressDefaultBlizzardButtons = function()
    local allNames = {
        "MiniMapTracking", "MinimapTrackingFrame", "MiniMapTrackingButton",
        "ExpansionLandingPageMinimapButton", "GarrisonLandingPageMinimapButton",
        "TimeManagerClockButton", "GameTimeFrame", "MiniMapInstanceDifficulty",
    }
    for _, name in ipairs(allNames) do
        pcall(function()
            local f = _G[name]
            if not f then return end
            f:Hide(); f:SetAlpha(0); f.Show = function() end
        end)
    end
end

CreateDefaultButtonProxies = function()
    -- Clean up old proxies
    for _, f in ipairs(defaultProxies) do
        -- Do NOT clear _vistaProxyHooked — hooks are permanent (hooksecurefunc)
        -- and the flag must remain set so SuppressDefaultBlizzardButtons won't
        -- override Show/Hide on the real button.
        pcall(function() f:Hide() end)
    end
    wipe(defaultProxies)

    if not decor then return end

    -- Per-button show/mouseover DB lookups
    local showFuncs = {
        tracking = GetShowTracking,
        calendar = GetShowCalendar,
    }
    local mouseoverFuncs = {
        tracking = GetMouseoverTracking,
        calendar = GetMouseoverCalendar,
    }

    for _, def in ipairs(DEFAULT_BTN_DEFS) do
        local key = def.key
        local lockKey = "proxy_" .. key
        local getShow      = showFuncs[key]      or function() return true end
        local getMouseover = mouseoverFuncs[key]  or function() return false end

        -- Parent to decor so the proxy always moves with Minimap
        local proxy = CreateFrame("Button", nil, decor)
        local proxySize = GetProxyBtnSizeForKey(key)
        proxy:SetSize(proxySize, proxySize)
        proxy._vistaKey = key
        proxy:SetFrameStrata("HIGH")
        proxy:SetFrameLevel(decor:GetFrameLevel() + 20)
        proxy:SetClampedToScreen(true)
        proxy:SetAlpha(1)  -- always full alpha; visibility controlled by Show/Hide

        -- Position: saved center-offset from Minimap, else default corner
        local savedX = tonumber(DB("vistaEX_" .. lockKey, nil))
        local savedY = tonumber(DB("vistaEY_" .. lockKey, nil))
        if savedX and savedY then
            proxy:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
        else
            proxy:SetPoint(def.anchor, Minimap, def.anchor, def.xOff, def.yOff)
        end

        -- Draggable
        proxy:SetMovable(true)
        proxy:RegisterForDrag("LeftButton")
        proxy:SetScript("OnDragStart", function(self)
            if DB("vistaLocked_" .. lockKey, true) then return end
            if InCombatLockdown() then return end
            self:StartMoving()
        end)
        proxy:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local mx, my = Minimap:GetCenter()
            local px, py = self:GetCenter()
            SetDB("vistaEX_" .. lockKey, px - mx)
            SetDB("vistaEY_" .. lockKey, py - my)
            self:ClearAllPoints()
            self:SetPoint("CENTER", Minimap, "CENTER",
                tonumber(DB("vistaEX_" .. lockKey, 0)) or 0,
                tonumber(DB("vistaEY_" .. lockKey, 0)) or 0)
        end)

        -- Icon — use NormalTexture slot so it's always full-brightness
        local icon = proxy:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetAlpha(1)
        if def.setIcon then
            def.setIcon(icon)
        else
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            local tex = def.getIcon()
            if tex then icon:SetTexture(tex) end
        end
        proxy._icon = icon

        -- Highlight
        if key ~= "tracking" then
            local hl = proxy:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.25)
        end

        -- Click
        proxy:RegisterForClicks("AnyUp")
        proxy:SetScript("OnClick", function(self, btn)
            pcall(function() def.onClick(self, btn) end)
        end)

        proxy:SetScript("OnEnter", function(self)
            if getShow() and getMouseover() then self:SetAlpha(1) end
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:SetText(def.tooltip)
            GameTooltip:Show()
        end)
        proxy:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            if getShow() and getMouseover() then self:SetAlpha(0) end
        end)

        -- Tracking icon sync
        if key == "tracking" then
            proxy:SetScript("OnUpdate", function(self, elapsed)
                self._syncTimer = (self._syncTimer or 0) + elapsed
                if self._syncTimer < 0.5 then return end
                self._syncTimer = 0
                local t = def.getIcon()
                if t and t ~= "" then
                    local ok = pcall(function() self._icon:SetAtlas(t) end)
                    if not ok then self._icon:SetTexture(t) end
                end
            end)
        end

        -- Apply initial show/mouseover state
        if not getShow() then
            proxy:Hide()
        elseif getMouseover() then
            proxy:Show(); proxy:SetAlpha(0)
        else
            proxy:Show(); proxy:SetAlpha(1)
        end

        defaultProxies[#defaultProxies + 1] = proxy
    end
end -- end CreateDefaultButtonProxies
end -- end DEFAULT_BTN_DEFS do-block

-- ============================================================================
-- QUEUE BUTTON ANCHOR
-- ============================================================================

local QUEUE_ANCHOR_PAD = 6  -- padding around the 45px button

local function RefreshQueueAnchor()
    if not queueAnchor then return end
    if DB("vistaQueueHandlingDisabled", false) then
        queueAnchor:SetAlpha(0)
        queueAnchor._border:Hide()
        queueAnchor:Hide()
        return
    end
    local realBtn = _G["QueueStatusButton"] or _G["QueueStatusMinimapButton"] or _G["MiniMapBattlefieldFrame"]
    local locked  = DB("vistaLocked_proxy_queue", true)
    local queued  = realBtn and realBtn:IsShown()

    if queued then
        queueAnchor:SetAlpha(1)
        queueAnchor._border:Hide()
        queueAnchor:Show()
    elseif not locked then
        queueAnchor:SetAlpha(1)
        queueAnchor._border:Show()
        queueAnchor:Show()
    else
        queueAnchor:SetAlpha(0)
        queueAnchor._border:Hide()
        queueAnchor:Hide()
    end
end

local function CreateQueueAnchor()
    if DB("vistaQueueHandlingDisabled", false) then
        if queueAnchor then RefreshQueueAnchor() end
        return
    end
    local realBtn = _G["QueueStatusButton"] or _G["QueueStatusMinimapButton"] or _G["MiniMapBattlefieldFrame"]
    if not realBtn then return end

    -- Only create once
    if queueAnchor then
        RefreshQueueAnchor()
        return
    end

    local btnSz = G.QueueBtnSize()
    local anchorSz = btnSz + QUEUE_ANCHOR_PAD * 2

    queueAnchor = CreateFrame("Frame", "HorizonSuiteVistaQueueAnchor", UIParent)
    queueAnchor:SetSize(anchorSz, anchorSz)
    queueAnchor:SetFrameStrata("HIGH")
    queueAnchor:SetClampedToScreen(true)
    queueAnchor:SetMovable(true)
    queueAnchor:EnableMouse(true)

    -- Position: restore saved or default to BOTTOMLEFT of minimap
    local savedX = tonumber(DB("vistaEX_proxy_queue", nil))
    local savedY = tonumber(DB("vistaEY_proxy_queue", nil))
    if savedX and savedY then
        queueAnchor:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
    else
        queueAnchor:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 4, 4)
    end

    -- Visible border shown when unlocked and not queued (drag handle)
    local border = queueAnchor:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints()
    border:SetColorTexture(0.4, 0.6, 1, 0.5)
    border:Hide()
    queueAnchor._border = border

    -- Drag support — identical pattern to the drawer button
    queueAnchor:RegisterForDrag("LeftButton")
    queueAnchor:SetScript("OnDragStart", function(self)
        if DB("vistaLocked_proxy_queue", true) then return end
        if InCombatLockdown() then return end
        self:StartMoving()
    end)
    queueAnchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local mx, my = Minimap:GetCenter()
        local bx, by = self:GetCenter()
        if not (mx and my and bx and by) then return end
        local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
        local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
        local bScale  = (self:GetEffectiveScale()) or uiScale
        local ox = (bx * bScale - mx * mmScale) / uiScale
        local oy = (by * bScale - my * mmScale) / uiScale
        SetDB("vistaEX_proxy_queue", ox)
        SetDB("vistaEY_proxy_queue", oy)
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
    end)
end

local INTERNAL_BLACKLIST, BLIZZARD_DEFAULT_BUTTONS, ClusterAndOtherAddonNamePatterns, buttonOriginalState, proxyButtonCache
do
    INTERNAL_BLACKLIST = {
        ["HorizonSuiteVistaDecor"]       = true,
        ["HorizonSuiteVistaButtonBar"]   = true,
        ["HorizonSuiteVistaDrawerBtn"]   = true,
        ["HorizonSuiteVistaQueueAnchor"] = true,
        ["MinimapBackdrop"]              = true,
        ["MinimapCompassTexture"]        = true,
        ["MinimapBorder"]                = true,
        ["MinimapBorderTop"]             = true,
        ["MinimapNorthTag"]              = true,
        ["MinimapZoneTextButton"]        = true,
        ["MiniMapWorldMapButton"]        = true,
        ["MinimapZoomIn"]                = true,
        ["MinimapZoomOut"]               = true,
        ["MinimapCluster"]               = true,
        ["MinimapToggleButton"]          = true,
        ["AddonCompartmentFrame"]        = true,
        ["AddonCompartmentFrameButton"]  = true,
    }
    BLIZZARD_DEFAULT_BUTTONS = {
        ["TimeManagerClockButton"]            = true,
        ["GameTimeFrame"]                     = true,
        ["MiniMapTracking"]                   = true,
        ["MinimapTrackingFrame"]              = true,
        ["MiniMapTrackingButton"]             = true,
        ["MiniMapTrackingIcon"]               = true,
        ["MiniMapTrackingIconOverlay"]        = true,
        ["GarrisonLandingPageMinimapButton"]  = true,
        ["ExpansionLandingPageMinimapButton"] = true,
        ["MiniMapInstanceDifficulty"]         = true,
        ["QueueStatusMinimapButton"]          = true,
        ["QueueStatusButton"]                 = true,
        ["QueueStatusFrame"]                  = true,
        ["MiniMapBattlefieldFrame"]           = true,
        ["MiniMapMailFrame"]                  = true,
        ["MiniMapMailIcon"]                   = true,
        ["MiniMapMailBorder"]                 = true,
        ["MinimapMailFrameNormal"]            = true,
        ["MiniMapStableFrame"]               = true,
        ["MiniMapCraftingOrderIcon"]          = true,
        ["MiniMapVoiceChatFrame"]             = true,
        ["MinimapPlayerArrow"]               = true,
        ["MinimapArrow"]                     = true,
        ["HelpOpenWebTicketButton"]          = true,
        ["HelpOpenTicketButton"]             = true,
        ["MinimapHelpButton"]                = true,
        ["MiniMapLFGFrame"]                  = true,
        ["MiniMapRecordingButton"]           = true,
        ["EmoticonMiniMapDropDown"]           = true,
        ["EmoticonMiniMapButton"]            = true,
    }

    ClusterAndOtherAddonNamePatterns = {
        "^MinimapCluster%.",
        "^Minimap%a*Pin%d*$",
        "^Plumber",
        "^Emoticon",
        "^GatherMate%a*%d+$",
        "^TomTom",
        "^TTMinimap%a*%d+$",
    }
    buttonOriginalState = {}
    proxyButtonCache    = {}
end

local function SaveButtonState(btn)
    if buttonOriginalState[btn] then return end
    local parent = btn:GetParent()
    local point, relFrame, relPoint, x, y = btn:GetPoint()
    local ok, strata = pcall(function() return btn:GetFrameStrata() end)
    buttonOriginalState[btn] = {
        parent   = parent,
        point    = point    or "CENTER",
        relFrame = relFrame or parent,
        relPoint = relPoint or "CENTER",
        x        = x or 0,
        y        = y or 0,
        strata   = (ok and strata) or "MEDIUM",
        originalShow = btn.Show,
    }
end

-- Reset button brightness without hiding decorative textures.
-- Used when buttons stay on the minimap (mouseover bar, unmanaged).
local function ResetButtonBrightness(btn)
    pcall(function() btn:SetAlpha(1) end)
    -- Restore the LibDBIcon decorative ring/background textures
    pcall(function() if btn.background then btn.background:Show() end end)
    pcall(function() if btn.border then btn.border:Show() end end)
    -- Ensure the icon texture itself is full brightness
    pcall(function()
        if btn.icon then
            btn.icon:SetAlpha(1)
            btn.icon:SetDesaturated(false)
            btn.icon:SetVertexColor(1, 1, 1, 1)
        end
    end)
    -- Walk all regions and reset alpha/desaturation
    pcall(function()
        for _, region in ipairs({ btn:GetRegions() }) do
            if region then
                pcall(function() region:SetDesaturated(false) end)
                pcall(function() region:SetAlpha(1) end)
                pcall(function() region:SetVertexColor(1, 1, 1, 1) end)
            end
        end
    end)
end

local function SuppressButtonShow(btn)
    local s = buttonOriginalState[btn]
    if not s then return end
    if not s.originalShow then s.originalShow = btn.Show end
    btn.Show = function() end
end

local function RestoreButtonShow(btn)
    local s = buttonOriginalState[btn]
    if s and s.originalShow then
        btn.Show = s.originalShow
    end
end

-- Reset button for use inside a panel (drawer / right-click).
-- Instead of placing the original LibDBIcon button (which has dark rendering issues),
-- we create a clean proxy button that copies the icon texture and forwards events.

local function GetOrCreateProxyButton(originalBtn, parent)
    if proxyButtonCache[originalBtn] then
        local proxy = proxyButtonCache[originalBtn]
        proxy:SetParent(parent)
        return proxy
    end

    local proxy = CreateFrame("Button", nil, parent)
    proxy:SetSize(GetAddonBtnSize(), GetAddonBtnSize())
    proxy._vistaOriginalBtn = originalBtn

    -- Create our own icon texture
    local proxyIcon = proxy:CreateTexture(nil, "ARTWORK")
    proxyIcon:SetAllPoints()
    proxy._vistaIcon = proxyIcon

    -- Extract icon texture from the original button
    local function UpdateProxyIcon()
        local tex = nil
        -- Try .icon first (LibDBIcon standard)
        if originalBtn.icon then
            tex = originalBtn.icon:GetTexture()
        end
        -- Fallback: scan regions for a texture with content
        if not tex then
            pcall(function()
                for _, region in ipairs({ originalBtn:GetRegions() }) do
                    if region and region:IsObjectType("Texture") then
                        local t = region:GetTexture()
                        if t and region ~= originalBtn.background and region ~= originalBtn.border then
                            tex = t
                            break
                        end
                    end
                end
            end)
        end
        if tex then
            proxyIcon:SetTexture(tex)
            -- Copy texcoords if available
            if originalBtn.icon then
                pcall(function()
                    proxyIcon:SetTexCoord(originalBtn.icon:GetTexCoord())
                end)
            end
        else
            proxyIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        proxyIcon:SetDesaturated(false)
        proxyIcon:SetAlpha(1)
        proxyIcon:SetVertexColor(1, 1, 1, 1)
    end

    UpdateProxyIcon()
    proxy._vistaUpdateIcon = UpdateProxyIcon

    -- Forward clicks to the original button
    proxy:SetScript("OnClick", function(self, button)
        -- The original btn may have dataObject (LibDBIcon)
        if originalBtn.dataObject then
            local dObj = originalBtn.dataObject
            if button == "LeftButton" then
                if dObj.OnClick then dObj.OnClick(originalBtn, button) end
            elseif button == "RightButton" then
                if dObj.OnClick then dObj.OnClick(originalBtn, button) end
            end
        else
            -- Fallback: simulate a click on the original
            pcall(function() originalBtn:Click(button) end)
        end
    end)
    proxy:RegisterForClicks("AnyUp")

    -- Forward tooltip
    proxy:SetScript("OnEnter", function(self)
        if originalBtn.dataObject then
            local dObj = originalBtn.dataObject
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            if dObj.OnTooltipShow then
                dObj.OnTooltipShow(GameTooltip)
            elseif dObj.text then
                GameTooltip:SetText(dObj.text)
            end
            GameTooltip:Show()
        else
            -- Try to fire original OnEnter
            pcall(function()
                local script = originalBtn:GetScript("OnEnter")
                if script then script(originalBtn) end
            end)
        end
    end)
    proxy:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        pcall(function()
            local script = originalBtn:GetScript("OnLeave")
            if script then script(originalBtn) end
        end)
    end)

    -- Highlight on hover
    local highlight = proxy:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.15)

    proxyButtonCache[originalBtn] = proxy
    return proxy
end

-- Hide all proxy buttons (used when switching modes)
local function HideAllProxyButtons()
    for _, proxy in pairs(proxyButtonCache) do
        proxy:Hide()
    end
end

local function RestoreButton(btn)
    RestoreButtonShow(btn)
    local s = buttonOriginalState[btn]
    if not s then
        pcall(function() btn:SetParent(Minimap); btn:Show() end)
        ResetButtonBrightness(btn)
        return
    end
    pcall(function()
        btn:SetFrameStrata(s.strata or "MEDIUM")
        btn:SetParent(s.parent or Minimap)
        btn:ClearAllPoints()
        btn:SetPoint(s.point, s.relFrame or (s.parent or Minimap), s.relPoint, s.x, s.y)
        btn:Show()
    end)
    ResetButtonBrightness(btn)
end

local function IsButtonManagedByVista(btn)
    local cName = btn:GetName()
    if cName and INTERNAL_BLACKLIST[cName] then return false end
    if cName and BLIZZARD_DEFAULT_BUTTONS[cName] then return false end
    if cName then
        for _, pat in ipairs(ClusterAndOtherAddonNamePatterns) do
            if cName:match(pat) then return false end
        end
    end
    local isProtected = false
    pcall(function() isProtected = btn:IsProtected() end)
    if isProtected then return false end
    if cName and not DB("vistaButtonManaged_" .. cName, true) then return false end
    return true
end

local function IsButtonVisible(btn)
    local cName = btn:GetName()
    local whitelist = G.ButtonWhitelist()
    if whitelist and type(whitelist) == "table" then
        local hasAny = false
        for _ in pairs(whitelist) do hasAny = true; break end
        if hasAny and not whitelist[cName or ""] then return false end
    end
    return true
end



--- Scan button-like children of Minimap AND MinimapCluster for ADDON buttons only.
--- Only includes buttons that are currently shown (active addons).
local function ScanMinimapButtons()
    local result = {}
    local seen = {}


    local function isMapPin(child)
        if child.dataObject then return false end
        if child.db and child.db.minimapPos then return false end
        if not child:GetName() then
            local ok, point, relFrame, relPoint = pcall(child.GetPoint, child, 1)
            if ok and point == "CENTER" and relPoint == "CENTER" and relFrame == Minimap then
                return true
            end
            local hasClick = false
            pcall(function()
                if child:HasScript("OnClick") and child:GetScript("OnClick") then hasClick = true end
            end)
            pcall(function()
                if child:HasScript("OnMouseUp") and child:GetScript("OnMouseUp") then hasClick = true end
            end)
            if not hasClick then return true end
        end
        return false
    end

    local function matchesBlizzardPattern(cName)
        if not cName then return false end
        for _, pat in ipairs(ClusterAndOtherAddonNamePatterns) do
            if cName:match(pat) then return true end
        end
        return false
    end

    local OPTION_PANEL_PATTERNS = {
        "option", "config", "setting", "panel", "control", "dialog", "pref",
    }
    local function isOptionsPanelChild(child)
        local parent = child:GetParent()
        if not parent then return false end
        local pName = parent:GetName()
        if not pName then return false end
        local lp = pName:lower()
        for _, pat in ipairs(OPTION_PANEL_PATTERNS) do
            if lp:find(pat, 1, true) then return true end
        end
        return false
    end

    local function hasClickHandler(child)
        local found = false
        pcall(function()
            if child:HasScript("OnClick") and child:GetScript("OnClick") then found = true end
        end)
        if found then return true end
        pcall(function()
            if child:HasScript("OnMouseUp") and child:GetScript("OnMouseUp") then found = true end
        end)
        if found then return true end
        pcall(function()
            if child:HasScript("OnMouseDown") and child:GetScript("OnMouseDown") then found = true end
        end)
        if found then return true end
        pcall(function()
            for _, sub in ipairs({ child:GetChildren() }) do
                pcall(function()
                    if sub:HasScript("OnClick") and sub:GetScript("OnClick") then found = true end
                end)
                if not found then pcall(function()
                    if sub:HasScript("OnMouseUp") and sub:GetScript("OnMouseUp") then found = true end
                end) end
                if found then return end
            end
        end)
        return found
    end

    local function tryAdd(child, requireName)
        if not child or seen[child] then return end
        local ok, isBtn = pcall(function() return child:IsObjectType("Button") end)
        if not ok or not isBtn then return end
        local cName = child:GetName()
        if requireName and not cName then return end
        if cName and INTERNAL_BLACKLIST[cName] then return end
        if cName and BLIZZARD_DEFAULT_BUTTONS[cName] then return end
        if cName and matchesBlizzardPattern(cName) then return end
        local isProtected = false
        pcall(function() isProtected = child:IsProtected() end)
        if isProtected then return end
        if isOptionsPanelChild(child) then return end
        if isMapPin(child) then return end
        local w, h = child:GetSize()
        if w < 14 or w > 100 or h < 14 or h > 100 then return end
        local ratio = (w > h) and (w / h) or (h / w)
        if ratio > 1.5 then return end
        if not child.dataObject and not (child.db and child.db.minimapPos) then
            if not hasClickHandler(child) then return end
        end
        seen[child] = true
        result[#result + 1] = child
    end

    -- Direct children of Minimap
    for _, child in ipairs({ Minimap:GetChildren() }) do
        tryAdd(child)
    end

    -- Children of MinimapCluster (many addons parent here)
    if MinimapCluster then
        for _, child in ipairs({ MinimapCluster:GetChildren() }) do
            if child ~= Minimap then
                tryAdd(child)
                local ok, isBtn = pcall(function() return child:IsObjectType("Button") end)
                if not (ok and isBtn) then
                    local ok2, isFrame = pcall(function() return child:IsObjectType("Frame") end)
                    if ok2 and isFrame then
                        for _, sub in ipairs({ child:GetChildren() }) do
                            tryAdd(sub)
                        end
                    end
                end
            end
        end
    end

    if MinimapBackdrop then
        for _, child in ipairs({ MinimapBackdrop:GetChildren() }) do
            tryAdd(child)
            local ok, isBtn = pcall(function() return child:IsObjectType("Button") end)
            if not (ok and isBtn) then
                local ok2, isFrame = pcall(function() return child:IsObjectType("Frame") end)
                if ok2 and isFrame then
                    for _, sub in ipairs({ child:GetChildren() }) do
                        tryAdd(sub)
                    end
                end
            end
        end
    end

    for gName, gObj in pairs(_G) do
        if type(gName) == "string" then
            local lname = gName:lower()
            local isLibDBIcon = lname:match("^libdbicon[%d]*_")
            if isLibDBIcon then
                if type(gObj) == "table" and type(gObj.IsObjectType) == "function" then
                    pcall(function() tryAdd(gObj, true) end)
                end
            end
        end
    end

    -- Blizzard's AddonCompartmentFrame children (addon drawer buttons)
    if _G["AddonCompartmentFrame"] then
        for _, child in ipairs({ _G["AddonCompartmentFrame"]:GetChildren() }) do
            tryAdd(child)
            local ok, isBtn = pcall(function() return child:IsObjectType("Button") end)
            if not (ok and isBtn) then
                local ok2, isFrame = pcall(function() return child:IsObjectType("Frame") end)
                if ok2 and isFrame then
                    for _, sub in ipairs({ child:GetChildren() }) do tryAdd(sub) end
                end
            end
        end
    end

    return result
end

-- Forward declaration — defined in the HOVER / ON-UPDATE section below.
-- Needed here because CreateCollectorBar's OnDragStop closure captures it.
local PositionBarAnchor

local function CreateCollectorBar()
    collectorBar = CreateFrame("Frame", "HorizonSuiteVistaButtonBar", UIParent)
    collectorBar:SetFrameStrata("HIGH")
    collectorBar:SetClampedToScreen(true)
    collectorBar:SetMovable(true)
    collectorBar:SetSize(1, GetAddonBtnSize())
    collectorBar:SetAlpha(0)

    local savedX = G.MouseoverBarX()
    local savedY = G.MouseoverBarY()
    if savedX and savedY then
        collectorBar:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
    else
        collectorBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -8)
    end
    collectorBar:Show()

    -- Backdrop (background + border textures)
    local barBgFrame = CreateFrame("Frame", nil, collectorBar)
    barBgFrame:SetAllPoints()
    barBgFrame:SetFrameLevel(collectorBar:GetFrameLevel())
    local brR, brG, brB, brA = G.BarBgColor()
    local bgTex = barBgFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    bgTex:SetAllPoints(); bgTex:SetColorTexture(brR, brG, brB, brA)
    collectorBar._bgTex = bgTex
    collectorBar._bgFrame = barBgFrame

    local bdrR, bdrG, bdrB, bdrA = G.BarBorderColor()
    local bbT = barBgFrame:CreateTexture(nil, "BORDER"); bbT:SetColorTexture(bdrR, bdrG, bdrB, bdrA)
    local bbB = barBgFrame:CreateTexture(nil, "BORDER"); bbB:SetColorTexture(bdrR, bdrG, bdrB, bdrA)
    local bbL = barBgFrame:CreateTexture(nil, "BORDER"); bbL:SetColorTexture(bdrR, bdrG, bdrB, bdrA)
    local bbR = barBgFrame:CreateTexture(nil, "BORDER"); bbR:SetColorTexture(bdrR, bdrG, bdrB, bdrA)
    collectorBar._borderTextures = { bbT, bbB, bbL, bbR }
    -- border visibility controlled by G.BarBorderShow()
    local function applyBarBorderVis()
        local show = G.BarBorderShow()
        bbT:SetShown(show); bbB:SetShown(show); bbL:SetShown(show); bbR:SetShown(show)
    end
    applyBarBorderVis()
    bbT:SetPoint("TOPLEFT",0,0); bbT:SetPoint("TOPRIGHT",0,0); bbT:SetHeight(1)
    bbB:SetPoint("BOTTOMLEFT",0,0); bbB:SetPoint("BOTTOMRIGHT",0,0); bbB:SetHeight(1)
    bbL:SetPoint("TOPLEFT",0,0); bbL:SetPoint("BOTTOMLEFT",0,0); bbL:SetWidth(1)
    bbR:SetPoint("TOPRIGHT",0,0); bbR:SetPoint("BOTTOMRIGHT",0,0); bbR:SetWidth(1)
    collectorBar._applyBarBorderVis = applyBarBorderVis

    -- Tooltip when bar is unlocked (to help user understand it is draggable)
    collectorBar:EnableMouse(true)
    collectorBar:SetScript("OnEnter", function(self)
        hoverTarget = 1; hoverElapsed = 0
        if not G.MouseoverLocked() then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:SetText("Minimap Buttons")
            GameTooltip:AddLine("Drag to reposition the bar", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("Lock position in options to hide this tip", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end
    end)
    collectorBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if Minimap:IsMouseOver() or collectorBar:IsMouseOver() then return end
        for _, p in pairs(proxyButtonCache) do if p:IsMouseOver() then return end end
        hoverTarget = 0; hoverElapsed = 0
    end)

    collectorBar:RegisterForDrag("LeftButton")
    collectorBar:SetScript("OnDragStart", function(self)
        if not G.MouseoverLocked() and not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    collectorBar:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local mx, my = Minimap:GetCenter()
        local bx, by = self:GetCenter()
        if not (mx and my and bx and by) then return end
        local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
        local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
        local bScale  = (self:GetEffectiveScale()) or uiScale
        local ox = (bx * bScale - mx * mmScale) / uiScale
        local oy = (by * bScale - my * mmScale) / uiScale
        SetDB("vistaMouseoverBarX", ox)
        SetDB("vistaMouseoverBarY", oy)
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
        PositionBarAnchor()
    end)

    -- ── Drag Anchor ─────────────────────────────────────────────────────────
    -- Icon-sized handle shown only when the bar is unlocked and visible.
    -- Dragging it repositions collectorBar. Styled like the floating drawer button.
    local anchorSz = GetAddonBtnSize() + 4
    barAnchor = CreateFrame("Button", "HorizonSuiteVistaBarAnchor", UIParent)
    barAnchor:SetSize(anchorSz, anchorSz)
    barAnchor:SetFrameStrata("HIGH")
    barAnchor:SetFrameLevel(collectorBar:GetFrameLevel() + 10)
    barAnchor:SetClampedToScreen(true)
    barAnchor:SetMovable(true)
    barAnchor:RegisterForDrag("LeftButton")
    barAnchor:Hide()

    -- Visuals: same panel colour as the floating drawer
    local abgR, abgG, abgB, abgA = GetPanelBgColor()
    local ancBg = barAnchor:CreateTexture(nil, "BACKGROUND")
    ancBg:SetAllPoints(); ancBg:SetColorTexture(abgR, abgG, abgB, abgA)
    barAnchor._bg = ancBg

    local abrR, abrG, abrB, abrA = GetPanelBorderColor()
    local ancBorder = barAnchor:CreateTexture(nil, "OVERLAY")
    ancBorder:SetPoint("TOPLEFT", -1, 1); ancBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    ancBorder:SetColorTexture(abrR, abrG, abrB, abrA)
    barAnchor._border = ancBorder

    -- Move icon
    local ancIcon = barAnchor:CreateTexture(nil, "ARTWORK")
    ancIcon:SetPoint("CENTER"); ancIcon:SetSize(14, 14)
    ancIcon:SetTexture("Interface\\CURSOR\\UI-Cursor-Move")
    ancIcon:SetTexCoord(0, 1, 0, 1)
    barAnchor._icon = ancIcon

    -- Tooltip
    barAnchor:SetScript("OnEnter", function(self)
        hoverTarget = 1; hoverElapsed = 0; barCloseDelayElapsed = 0
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText("Mouseover Bar Anchor")
        GameTooltip:AddLine("Drag to reposition the button bar", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    barAnchor:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Drag: user drags the anchor; on drop, offset collectorBar so its leading
    -- edge lands where the anchor was, then re-snap anchor to that edge.
    barAnchor:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        barAnchorDragging = true
        collectorBar:SetAlpha(1)  -- keep bar visible while dragging
        self:StartMoving()
        -- Live-follow: read anchor screen pos every frame, derive bar CENTER, move bar
        self:SetScript("OnUpdate", function(s)
            if not collectorBar then return end
            local ax, ay = s:GetCenter()
            if not ax then return end
            local dir     = G.BtnLayoutDir()
            local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
            local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
            local aScale  = (s:GetEffectiveScale()) or uiScale
            local mx, my  = Minimap:GetCenter()
            if not mx then return end
            -- anchor centre in Minimap-relative units
            local ancOffX = (ax * aScale - mx * mmScale) / uiScale
            local ancOffY = (ay * aScale - my * mmScale) / uiScale
            local cbW  = collectorBar:GetWidth()
            local cbH  = collectorBar:GetHeight()
            local ancW = s:GetWidth()
            local ancH = s:GetHeight()
            local gap  = BTN_GAP
            local ox, oy
            if     dir == "right" then ox = ancOffX + ancW/2 + gap + cbW/2; oy = ancOffY
            elseif dir == "left"  then ox = ancOffX - ancW/2 - gap - cbW/2; oy = ancOffY
            elseif dir == "down"  then ox = ancOffX; oy = ancOffY - ancH/2 - gap - cbH/2
            elseif dir == "up"    then ox = ancOffX; oy = ancOffY + ancH/2 + gap + cbH/2
            else                       ox = ancOffX + ancW/2 + gap + cbW/2; oy = ancOffY end
            -- Move collectorBar without creating a circular anchor dependency
            collectorBar:ClearAllPoints()
            collectorBar:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
        end)
    end)
    barAnchor:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)  -- stop live-follow
        self:StopMovingOrSizing()
        barAnchorDragging = false
        if not collectorBar then return end

        -- Step 1: compute anchor's own offset from Minimap CENTER
        -- (same formula used by collectorBar's own OnDragStop)
        local mx, my = Minimap:GetCenter()
        local ax, ay = self:GetCenter()
        if not (mx and my and ax and ay) then return end
        local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
        local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
        local aScale  = (self:GetEffectiveScale()) or uiScale
        -- anchor offset from Minimap CENTER, in Minimap-relative units
        local ancOffX = (ax * aScale - mx * mmScale) / uiScale
        local ancOffY = (ay * aScale - my * mmScale) / uiScale

        -- Step 2: shift from anchor position to collectorBar CENTER
        -- based on expand direction (anchor sits on the leading edge)
        local dir  = G.BtnLayoutDir()
        local cbW  = collectorBar:GetWidth()
        local cbH  = collectorBar:GetHeight()
        local ancW = self:GetWidth()
        local ancH = self:GetHeight()
        local gap  = BTN_GAP
        local ox, oy
        if dir == "right" then
            ox = ancOffX + ancW/2 + gap + cbW/2
            oy = ancOffY
        elseif dir == "left" then
            ox = ancOffX - ancW/2 - gap - cbW/2
            oy = ancOffY
        elseif dir == "down" then
            ox = ancOffX
            oy = ancOffY - ancH/2 - gap - cbH/2
        elseif dir == "up" then
            ox = ancOffX
            oy = ancOffY + ancH/2 + gap + cbH/2
        else
            ox = ancOffX + ancW/2 + gap + cbW/2
            oy = ancOffY
        end

        SetDB("vistaMouseoverBarX", ox)
        SetDB("vistaMouseoverBarY", oy)
        collectorBar:ClearAllPoints()
        collectorBar:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
        PositionBarAnchor()
    end)
end


local function LayoutCollectedButtons()
    if not collectorBar then return end
    local n = #collectedButtons
    local btnSz = GetAddonBtnSize()
    local BAR_PAD = 4
    if n == 0 then collectorBar:SetWidth(1); collectorBar:SetHeight(btnSz + BAR_PAD * 2); return end

    local cols   = math.min(n, math.max(1, G.BtnLayoutCols()))
    local dir    = G.BtnLayoutDir()
    local vertical = (dir == "up" or dir == "down")
    local primaryCount   = cols
    local secondaryCount = math.ceil(n / primaryCount)
    local gridCols = vertical and secondaryCount or primaryCount
    local gridRows = vertical and primaryCount    or secondaryCount

    local totalWidth  = gridCols * btnSz + (gridCols - 1) * BTN_GAP + BAR_PAD * 2
    local totalHeight = gridRows * btnSz + (gridRows - 1) * BTN_GAP + BAR_PAD * 2
    collectorBar:SetSize(totalWidth, totalHeight)

    for i, originalBtn in ipairs(collectedButtons) do
        local idx = i - 1
        local pri = idx % primaryCount
        local sec = math.floor(idx / primaryCount)
        local col, row
        if     dir == "right" then col = pri;                       row = sec
        elseif dir == "left"  then col = (primaryCount - 1 - pri); row = sec
        elseif dir == "down"  then col = sec;                       row = pri
        elseif dir == "up"    then col = sec;                       row = (primaryCount - 1 - pri)
        else                       col = pri;                       row = sec end

        -- Use proxy buttons (properly sized with correct click area)
        originalBtn:Hide()
        local proxy = GetOrCreateProxyButton(originalBtn, collectorBar)
        proxy:ClearAllPoints()
        proxy:SetSize(btnSz, btnSz)
        proxy:SetFrameLevel(collectorBar:GetFrameLevel() + 2)
        proxy:SetPoint("TOPLEFT", collectorBar, "TOPLEFT",
            BAR_PAD + col * (btnSz + BTN_GAP),
            -(BAR_PAD + row * (btnSz + BTN_GAP)))
        proxy._vistaUpdateIcon()
        proxy:Show()
    end

    -- Re-snap anchor to leading edge now that bar dimensions are final
    if barAnchor then PositionBarAnchor() end

    collectorBar:EnableMouse(true)
    -- Re-apply hover scripts each layout (they may have been cleared)
    collectorBar:SetScript("OnEnter", function(self)
        hoverTarget = 1; hoverElapsed = 0
        if not G.MouseoverLocked() then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:SetText("Minimap Buttons")
            GameTooltip:AddLine("Drag to reposition the bar", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("Lock position in options to hide this tip", 0.5, 0.5, 0.5)
            GameTooltip:Show()
        end
    end)
    collectorBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if Minimap:IsMouseOver() or collectorBar:IsMouseOver() then return end
        for _, p in pairs(proxyButtonCache) do if p:IsMouseOver() then return end end
        hoverTarget = 0; hoverElapsed = 0
    end)

    for _, originalBtn in ipairs(collectedButtons) do
        local proxy = proxyButtonCache[originalBtn]
        if proxy and not hookedButtons[proxy] then
            hookedButtons[proxy] = true
            proxy:HookScript("OnEnter", function() hoverTarget = 1; hoverElapsed = 0 end)
            proxy:HookScript("OnLeave", function()
                if Minimap:IsMouseOver() or collectorBar:IsMouseOver() then return end
                for _, p in pairs(proxyButtonCache) do if p:IsMouseOver() then return end end
                hoverTarget = 0; hoverElapsed = 0
            end)
        end
    end
end

-- ============================================================================
-- DRAWER BUTTON
-- ============================================================================

local function UpdateDrawerPanelLayout()
    if not drawerPanel then return end
    local n = #drawerPanelButtons
    if n == 0 then drawerPanel:SetSize(1, 1); return end

    local PAD = 6; local GAP = 4
    local btnSz = GetAddonBtnSize()
    local dir   = G.BtnLayoutDir()
    local vertical = (dir == "up" or dir == "down")
    local primaryCount = math.min(n, math.max(1, G.BtnLayoutCols()))
    local secondaryCount = math.ceil(n / primaryCount)
    local gridCols = vertical and secondaryCount or primaryCount
    local gridRows = vertical and primaryCount    or secondaryCount

    drawerPanel:SetSize(
        gridCols * btnSz + (gridCols - 1) * GAP + PAD * 2,
        gridRows * btnSz + (gridRows - 1) * GAP + PAD * 2)

    for idx, originalBtn in ipairs(drawerPanelButtons) do
        local i = idx - 1
        local pri = i % primaryCount
        local sec = math.floor(i / primaryCount)
        local col, row
        if dir == "right" then col = pri; row = sec
        elseif dir == "left" then col = (primaryCount - 1 - pri); row = sec
        elseif dir == "down" then col = sec; row = pri
        elseif dir == "up"   then col = sec; row = (primaryCount - 1 - pri)
        else col = pri; row = sec end

        originalBtn:Hide()
        local proxy = GetOrCreateProxyButton(originalBtn, drawerPanel)
        proxy:ClearAllPoints()
        proxy:SetSize(btnSz, btnSz)
        proxy:SetFrameLevel(drawerPanel:GetFrameLevel() + 10 + idx)
        proxy:SetPoint("TOPLEFT", drawerPanel, "TOPLEFT",
            PAD + col * (btnSz + GAP),
            -(PAD + row * (btnSz + GAP)))
        proxy._vistaUpdateIcon()
        proxy:Show()
    end
end

local function CreateDrawerButton()
    if drawerButton then drawerButton:Show(); return end

    drawerButton = CreateFrame("Button", "HorizonSuiteVistaDrawerBtn", UIParent)
    drawerButton:SetSize(GetAddonBtnSize() + 4, GetAddonBtnSize() + 4)
    drawerButton:SetFrameStrata("HIGH")
    drawerButton:SetClampedToScreen(true)
    drawerButton:SetMovable(true)
    drawerButton:RegisterForDrag("LeftButton")  -- use WoW drag API, not manual tracking

    local dbx = DB("vistaDrawerBtnX", nil)
    local dby = DB("vistaDrawerBtnY", nil)
    if dbx and dby then
        -- Saved as CENTER offset relative to Minimap CENTER
        drawerButton:SetPoint("CENTER", Minimap, "CENTER", dbx, dby)
    else
        drawerButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)
    end

    -- Visuals
    local bg = drawerButton:CreateTexture(nil, "BACKGROUND")
    local dbR, dbG, dbB, dbA = GetPanelBgColor()
    bg:SetAllPoints(); bg:SetColorTexture(dbR, dbG, dbB, dbA)
    drawerButton._bg = bg

    local icon = drawerButton:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("CENTER"); icon:SetSize(18, 18)
    icon:SetTexture("Interface\\MINIMAP\\TRACKING\\Recycle")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    drawerButton.icon = icon

    local brR, brG, brB, brA = GetPanelBorderColor()
    local border = drawerButton:CreateTexture(nil, "OVERLAY")
    border:SetPoint("TOPLEFT", -1, 1); border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(brR, brG, brB, brA)
    drawerButton._border = border

    drawerButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:SetText("Minimap Buttons")
        GameTooltip:AddLine("Click to toggle drawer", 0.7, 0.7, 0.7)
        if not G.ButtonDrawerLocked() then
            GameTooltip:AddLine("Drag to move", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    drawerButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Drag via OnDragStart / OnDragStop (clean, no sticky-mouse bug)
    drawerButton:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self:StartMoving()
    end)
    drawerButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local mx, my = Minimap:GetCenter()
        local bx, by = self:GetCenter()
        if not (mx and my and bx and by) then return end
        local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
        local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
        local bScale  = (self:GetEffectiveScale()) or uiScale
        local ox = (bx * bScale - mx * mmScale) / uiScale
        local oy = (by * bScale - my * mmScale) / uiScale
        SetDB("vistaDrawerBtnX", ox)
        SetDB("vistaDrawerBtnY", oy)
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
    end)

    -- Click to toggle the drawer (only fires when not dragging)
    drawerButton:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        drawerOpen = not drawerOpen
        if drawerPanel then
            if drawerOpen then
                drawerPanel:Show()
                if drawerPanel._scheduleAutoClose then drawerPanel._scheduleAutoClose() end
            else
                drawerPanel:Hide()
                drawerPanel:SetScript("OnUpdate", nil)
            end
        end
    end)

    -- Drawer panel: separate background child frame to avoid overlapping button icons
    drawerPanel = CreateFrame("Frame", nil, UIParent)
    drawerPanel:SetFrameStrata("FULLSCREEN_DIALOG")
    drawerPanel:SetFrameLevel(1)
    drawerPanel:SetClampedToScreen(true)

    -- Background is a child frame at very low level
    local dpBgFrame = CreateFrame("Frame", nil, drawerPanel)
    dpBgFrame:SetAllPoints()
    dpBgFrame:SetFrameLevel(0)
    local dpBgR, dpBgG, dpBgB, dpBgA = GetPanelBgColor()
    local dpBg = dpBgFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    dpBg:SetAllPoints(); dpBg:SetColorTexture(dpBgR, dpBgG, dpBgB, dpBgA)
    local dpBrR, dpBrG, dpBrB, dpBrA = GetPanelBorderColor()
    local dpBorderT = dpBgFrame:CreateTexture(nil, "BORDER"); dpBorderT:SetColorTexture(dpBrR, dpBrG, dpBrB, dpBrA)
    local dpBorderB = dpBgFrame:CreateTexture(nil, "BORDER"); dpBorderB:SetColorTexture(dpBrR, dpBrG, dpBrB, dpBrA)
    local dpBorderL = dpBgFrame:CreateTexture(nil, "BORDER"); dpBorderL:SetColorTexture(dpBrR, dpBrG, dpBrB, dpBrA)
    local dpBorderR = dpBgFrame:CreateTexture(nil, "BORDER"); dpBorderR:SetColorTexture(dpBrR, dpBrG, dpBrB, dpBrA)
    drawerPanel._bgTex = dpBg
    drawerPanel._borderTextures = { dpBorderT, dpBorderB, dpBorderL, dpBorderR }
    dpBorderT:SetPoint("TOPLEFT",0,0); dpBorderT:SetPoint("TOPRIGHT",0,0); dpBorderT:SetHeight(1)
    dpBorderB:SetPoint("BOTTOMLEFT",0,0); dpBorderB:SetPoint("BOTTOMRIGHT",0,0); dpBorderB:SetHeight(1)
    dpBorderL:SetPoint("TOPLEFT",0,0); dpBorderL:SetPoint("BOTTOMLEFT",0,0); dpBorderL:SetWidth(1)
    dpBorderR:SetPoint("TOPRIGHT",0,0); dpBorderR:SetPoint("BOTTOMRIGHT",0,0); dpBorderR:SetWidth(1)

    drawerPanel:SetPoint("BOTTOMLEFT", drawerButton, "TOPLEFT", 0, 4)
    drawerPanel:Hide()
    drawerOpen = false

    -- Auto-close polling when delay > 0
    local function ScheduleDrawerAutoClose()
        local delay = G.DrawerCloseDelay()
        if delay <= 0 then return end  -- 0 = never auto-close
        local elapsed = 0
        local function poll(_, dt)
            elapsed = elapsed + dt
            if not drawerPanel or not drawerOpen then return end
            if drawerButton and drawerButton:IsMouseOver() then elapsed = 0; return end
            if drawerPanel:IsMouseOver() then elapsed = 0; return end
            for _, p in pairs(proxyButtonCache) do
                if p:GetParent() == drawerPanel and p:IsMouseOver() then elapsed = 0; return end
            end
            if elapsed >= delay then
                drawerPanel:Hide()
                drawerOpen = false
                drawerPanel:SetScript("OnUpdate", nil)
            end
        end
        drawerPanel:SetScript("OnUpdate", poll)
    end
    drawerPanel._scheduleAutoClose = ScheduleDrawerAutoClose
end

local function DestroyDrawerButton()
    if drawerButton then
        drawerButton:Hide()
        if drawerPanel then drawerPanel:Hide() end
    end
end

-- ============================================================================
-- RIGHT-CLICK PANEL
-- ============================================================================

local function CreateRightClickPanel()
    if rightClickPanel then return end

    rightClickPanel = CreateFrame("Frame", nil, UIParent)
    rightClickPanel:SetFrameStrata("FULLSCREEN_DIALOG")
    rightClickPanel:SetFrameLevel(1)
    rightClickPanel:SetClampedToScreen(true)
    rightClickPanel:SetMovable(true)
    rightClickPanel:Hide()
    rightClickVisible = false

    local savedX = G.RightClickPanelX()
    local savedY = G.RightClickPanelY()
    if savedX and savedY then
        rightClickPanel:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
    else
        rightClickPanel:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -4)
    end

    local rcBgFrame = CreateFrame("Frame", nil, rightClickPanel)
    rcBgFrame:SetAllPoints()
    rcBgFrame:SetFrameLevel(0)
    local rcBgR, rcBgG, rcBgB, rcBgA = GetPanelBgColor()
    local rcBg = rcBgFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
    rcBg:SetAllPoints(); rcBg:SetColorTexture(rcBgR, rcBgG, rcBgB, rcBgA)
    local rcBrR, rcBrG, rcBrB, rcBrA = GetPanelBorderColor()
    local rcBT = rcBgFrame:CreateTexture(nil, "BORDER"); rcBT:SetColorTexture(rcBrR, rcBrG, rcBrB, rcBrA)
    local rcBB = rcBgFrame:CreateTexture(nil, "BORDER"); rcBB:SetColorTexture(rcBrR, rcBrG, rcBrB, rcBrA)
    local rcBL = rcBgFrame:CreateTexture(nil, "BORDER"); rcBL:SetColorTexture(rcBrR, rcBrG, rcBrB, rcBrA)
    local rcBR = rcBgFrame:CreateTexture(nil, "BORDER"); rcBR:SetColorTexture(rcBrR, rcBrG, rcBrB, rcBrA)
    rightClickPanel._bgTex = rcBg
    rightClickPanel._borderTextures = { rcBT, rcBB, rcBL, rcBR }
    rcBT:SetPoint("TOPLEFT",0,0); rcBT:SetPoint("TOPRIGHT",0,0); rcBT:SetHeight(1)
    rcBB:SetPoint("BOTTOMLEFT",0,0); rcBB:SetPoint("BOTTOMRIGHT",0,0); rcBB:SetHeight(1)
    rcBL:SetPoint("TOPLEFT",0,0); rcBL:SetPoint("BOTTOMLEFT",0,0); rcBL:SetWidth(1)
    rcBR:SetPoint("TOPRIGHT",0,0); rcBR:SetPoint("BOTTOMRIGHT",0,0); rcBR:SetWidth(1)

    rightClickPanel:RegisterForDrag("LeftButton")
    rightClickPanel:SetScript("OnDragStart", function(self)
        if not G.RightClickLocked() and not InCombatLockdown() then
            self:StartMoving()
        end
    end)
    rightClickPanel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local mx, my = Minimap:GetCenter()
        local bx, by = self:GetCenter()
        if not (mx and my and bx and by) then return end
        local uiScale = (UIParent and UIParent:GetEffectiveScale()) or 1
        local mmScale = (Minimap and Minimap:GetEffectiveScale()) or uiScale
        local bScale  = (self:GetEffectiveScale()) or uiScale
        local ox = (bx * bScale - mx * mmScale) / uiScale
        local oy = (by * bScale - my * mmScale) / uiScale
        SetDB("vistaRightClickPanelX", ox)
        SetDB("vistaRightClickPanelY", oy)
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
    end)

    -- Auto-close polling: instead of OnLeave (which fires on child entry), poll every 0.1s
    -- to check if the mouse has left both the panel and all its proxy buttons.
    local function ScheduleRightClickAutoClose()
        local delay = G.RightClickCloseDelay()
        if delay <= 0 then return end  -- 0 = never auto-close
        local elapsed = 0
        local function poll(_, dt)
            elapsed = elapsed + dt
            if not rightClickPanel or not rightClickVisible then return end
            -- Check if mouse is over the panel or any child proxy button
            if rightClickPanel:IsMouseOver() then elapsed = 0; return end
            for _, p in pairs(proxyButtonCache) do
                if p:GetParent() == rightClickPanel and p:IsMouseOver() then elapsed = 0; return end
            end
            if elapsed >= delay then
                rightClickPanel:Hide()
                rightClickVisible = false
            end
        end
        -- Attach poll to the panel's own OnUpdate only while it's visible
        rightClickPanel:SetScript("OnUpdate", poll)
    end
    rightClickPanel._scheduleAutoClose = ScheduleRightClickAutoClose
end

local function LayoutRightClickPanel(buttons)
    if not rightClickPanel then return end
    local n = #buttons
    if n == 0 then rightClickPanel:Hide(); rightClickVisible = false; return end

    local PAD = 6; local GAP = 4
    local btnSz = GetAddonBtnSize()
    local dir      = G.BtnLayoutDir()
    local vertical = (dir == "up" or dir == "down")
    local primaryCount   = math.min(n, math.max(1, G.BtnLayoutCols()))
    local secondaryCount = math.ceil(n / primaryCount)
    local gridCols = vertical and secondaryCount or primaryCount
    local gridRows = vertical and primaryCount    or secondaryCount

    rightClickPanel:SetSize(
        gridCols * btnSz + (gridCols - 1) * GAP + PAD * 2,
        gridRows * btnSz + (gridRows - 1) * GAP + PAD * 2)

    for idx, originalBtn in ipairs(buttons) do
        local i = idx - 1
        local pri = i % primaryCount
        local sec = math.floor(i / primaryCount)
        local col, row
        if     dir == "right" then col = pri;                       row = sec
        elseif dir == "left"  then col = (primaryCount - 1 - pri); row = sec
        elseif dir == "down"  then col = sec;                       row = pri
        elseif dir == "up"    then col = sec;                       row = (primaryCount - 1 - pri)
        else                       col = pri;                       row = sec end

        originalBtn:Hide()
        local proxy = GetOrCreateProxyButton(originalBtn, rightClickPanel)
        proxy:ClearAllPoints()
        proxy:SetSize(btnSz, btnSz)
        proxy:SetFrameLevel(rightClickPanel:GetFrameLevel() + 10 + idx)
        proxy:SetPoint("TOPLEFT", rightClickPanel, "TOPLEFT",
            PAD + col * (btnSz + GAP),
            -(PAD + row * (btnSz + GAP)))
        proxy._vistaUpdateIcon()
        proxy:Show()
    end
end

local function RestoreButtonToMinimap(btn)
    RestoreButton(btn)
end

-- ============================================================================
-- MAIN BUTTON COLLECTION DISPATCH
-- ============================================================================

-- Master registry of all buttons Vista has ever taken ownership of.
-- This persists across CollectMinimapButtons calls so we can always restore them.
local allManagedButtons = {}  -- [btn] = true

-- The authoritative list lives on Vista._discoveredNames (persists across calls).
-- Initialized here; populated by CollectMinimapButtons each time it runs.
Vista._discoveredNames = Vista._discoveredNames or {}

local function CollectMinimapButtons()
    if not G.ButtonHandleButtons() then
        HideAllProxyButtons()
        for btn in pairs(allManagedButtons) do
            RestoreButton(btn)
        end
        wipe(allManagedButtons)
        wipe(collectedButtons)
        wipe(drawerPanelButtons)
        DestroyDrawerButton()
        if rightClickPanel then rightClickPanel:Hide(); rightClickVisible = false end
        if collectorBar then collectorBar:SetWidth(1) end
        return
    end

    -- Hide any proxy buttons from previous layout
    HideAllProxyButtons()

    -- Step 1: restore buttons currently in our panels to their natural state
    -- so ScanMinimapButtons can find them again (they may be parented to our panel)
    for btn in pairs(allManagedButtons) do
        RestoreButtonShow(btn)
        pcall(function()
            local s = buttonOriginalState[btn]
            if s then
                btn:SetParent(s.parent or Minimap)
                btn:SetPoint(s.point, s.relFrame or s.parent or Minimap, s.relPoint, s.x, s.y)
                btn:Show()
            end
        end)
    end

    -- Scan for addon buttons
    local allCandidates = ScanMinimapButtons()

    wipe(allManagedButtons)
    for _, btn in ipairs(allCandidates) do
        SaveButtonState(btn)
        allManagedButtons[btn] = true
    end

    -- Cache candidate names for the options filter list (only update when scan found buttons)
    if #allCandidates > 0 then
        local newNames = {}
        local seen = {}
        for _, btn in ipairs(allCandidates) do
            local cName = btn.GetName and btn:GetName()
            if cName and not seen[cName] then
                seen[cName] = true
                newNames[#newNames + 1] = cName
            end
        end
        table.sort(newNames)
        local oldCount = Vista._discoveredNames and #Vista._discoveredNames or 0
        Vista._discoveredNames = newNames

        if oldCount == 0 and #newNames > 0 and addon.OptionsPanel_RebuildCategory then
            C_Timer.After(0, function()
                addon.OptionsPanel_RebuildCategory("VistaButtons")
            end)
        end
    end

    wipe(collectedButtons)
    wipe(drawerPanelButtons)


    local mode = GetButtonMode()

    -- Three-way split: managed+visible → panel, managed+hidden → hide, unmanaged → untouched
    local visible = {}
    for _, btn in ipairs(allCandidates) do
        if IsButtonManagedByVista(btn) then
            if IsButtonVisible(btn) then
                visible[#visible + 1] = btn
            else
                pcall(function() btn:Hide() end)
                SuppressButtonShow(btn)
            end
        end
    end

    if mode == BTN_MODE_MOUSEOVER then
        HideAllProxyButtons()
        DestroyDrawerButton()
        if rightClickPanel then rightClickPanel:Hide(); rightClickVisible = false end
        for _, btn in ipairs(visible) do
            collectedButtons[#collectedButtons + 1] = btn
            btn:Hide()
            SuppressButtonShow(btn)
        end
        LayoutCollectedButtons()

    elseif mode == BTN_MODE_RIGHTCLICK then
        DestroyDrawerButton()
        if not rightClickPanel then CreateRightClickPanel() end
        for _, btn in ipairs(visible) do
            collectedButtons[#collectedButtons + 1] = btn
            btn:Hide()
            SuppressButtonShow(btn)
        end
        LayoutRightClickPanel(collectedButtons)
        if collectorBar then collectorBar:SetWidth(1) end

    elseif mode == BTN_MODE_DRAWER then
        if rightClickPanel then rightClickPanel:Hide(); rightClickVisible = false end
        CreateDrawerButton()
        for _, btn in ipairs(visible) do
            drawerPanelButtons[#drawerPanelButtons + 1] = btn
            btn:Hide()
            SuppressButtonShow(btn)
        end
        UpdateDrawerPanelLayout()
        if collectorBar then collectorBar:SetWidth(1) end
    end
end

-- ============================================================================
-- HOVER / ON-UPDATE
-- ============================================================================

local barCloseDelayElapsed = 0  -- tracks how long we've been "waiting to close"

-- Show the drag anchor only when: mode=mouseover, unlocked, AND bar is visible (hovered or always-on)
PositionBarAnchor = function()
    if not barAnchor or not collectorBar then return end
    if barAnchorDragging then return end  -- don't fight StartMoving
    -- Attach anchor to the leading edge of the bar based on expand direction.
    -- "First" means the side the first button grows away from.
    local dir   = G.BtnLayoutDir()
    local ancSz = GetAddonBtnSize() + 4
    local gap   = BTN_GAP
    barAnchor:ClearAllPoints()
    if dir == "right" then
        -- bar grows right → anchor is to the LEFT of the bar
        barAnchor:SetPoint("RIGHT", collectorBar, "LEFT", -gap, 0)
    elseif dir == "left" then
        -- bar grows left → anchor is to the RIGHT of the bar
        barAnchor:SetPoint("LEFT", collectorBar, "RIGHT", gap, 0)
    elseif dir == "down" then
        -- bar grows down → anchor is ABOVE the bar
        barAnchor:SetPoint("BOTTOM", collectorBar, "TOP", 0, gap)
    elseif dir == "up" then
        -- bar grows up → anchor is BELOW the bar
        barAnchor:SetPoint("TOP", collectorBar, "BOTTOM", 0, -gap)
    else
        barAnchor:SetPoint("RIGHT", collectorBar, "LEFT", -gap, 0)
    end
end

local function UpdateBarAnchorVisibility()
    if not barAnchor then return end
    local shouldShow = (GetButtonMode() == BTN_MODE_MOUSEOVER)
                    and not G.MouseoverLocked()
                    and (G.MouseoverBarVisible() or barAlpha > 0.05)
    if shouldShow then
        PositionBarAnchor()
        barAnchor:Show()
    else
        barAnchor:Hide()
    end
end

local function OnHoverUpdate(_, elapsed)
    UpdateCoords(nil, elapsed)
    UpdateTimeText(nil, elapsed)

    -- Only animate the collector bar in mouseover mode
    if GetButtonMode() ~= BTN_MODE_MOUSEOVER then
        if barAnchor then barAnchor:Hide() end
        return
    end
    if not collectorBar or #collectedButtons == 0 then
        if barAnchor then barAnchor:Hide() end
        return
    end

    -- "Always visible" override (for positioning)
    if G.MouseoverBarVisible() then
        barAlpha  = 1
        hoverTarget = 1
        hoverElapsed = 0
        barCloseDelayElapsed = 0
        collectorBar:SetAlpha(1)
        UpdateBarAnchorVisibility()
        return
    end

    -- If hover target just switched to 0 (cursor left), apply close delay
    if hoverTarget == 0 and barAlpha > 0 then
        local delay = G.MouseoverCloseDelay()
        if delay > 0 then
            barCloseDelayElapsed = barCloseDelayElapsed + elapsed
            if barCloseDelayElapsed < delay then
                -- hold at current alpha until delay expires
                return
            end
        end
    elseif hoverTarget == 1 then
        barCloseDelayElapsed = 0
    end

    if barAlpha == hoverTarget then
        UpdateBarAnchorVisibility()
        return
    end

    hoverElapsed = hoverElapsed + elapsed
    local t = math.min(hoverElapsed / FADE_DUR, 1)
    if hoverTarget > barAlpha then
        barAlpha = easeOut(t) * hoverTarget
    else
        barAlpha = 1 - easeOut(t)
        if barAlpha < 0 then barAlpha = 0 end
    end
    if t >= 1 then barAlpha = hoverTarget; barCloseDelayElapsed = 0 end
    collectorBar:SetAlpha(barAlpha)
    UpdateBarAnchorVisibility()
end

-- ============================================================================
-- APPLY COLORS  (lightweight; called during live color-picker drags)
-- ============================================================================

function Vista.ApplyColors()
    if not decor then return end
    ApplyBorderTextures()
    if zoneText  then zoneText:SetTextColor(GetZoneColor())   end
    if coordText then coordText:SetTextColor(GetCoordColor()) end
    if timeText  then timeText:SetTextColor(GetTimeColor())   end
    if diffText  then UpdateDifficultyText() end  -- per-difficulty colors applied inside
    if drawerButton then
        if drawerButton._bg     then drawerButton._bg:SetColorTexture(GetPanelBgColor())     end
        if drawerButton._border then drawerButton._border:SetColorTexture(GetPanelBorderColor()) end
    end
    local bgR, bgG, bgB, bgA = GetPanelBgColor()
    local brR, brG, brB, brA = GetPanelBorderColor()
    if drawerPanel and drawerPanel._bgTex then
        drawerPanel._bgTex:SetColorTexture(bgR, bgG, bgB, bgA)
    end
    if drawerPanel and drawerPanel._borderTextures then
        for _, tex in ipairs(drawerPanel._borderTextures) do tex:SetColorTexture(brR, brG, brB, brA) end
    end
    if rightClickPanel and rightClickPanel._bgTex then
        rightClickPanel._bgTex:SetColorTexture(bgR, bgG, bgB, bgA)
    end
    if rightClickPanel and rightClickPanel._borderTextures then
        for _, tex in ipairs(rightClickPanel._borderTextures) do tex:SetColorTexture(brR, brG, brB, brA) end
    end
    -- Mouseover bar backdrop
    if collectorBar then
        if collectorBar._bgTex then collectorBar._bgTex:SetColorTexture(G.BarBgColor()) end
        if collectorBar._borderTextures then
            local bbR, bbG, bbB, bbA = G.BarBorderColor()
            for _, tex in ipairs(collectorBar._borderTextures) do tex:SetColorTexture(bbR, bbG, bbB, bbA) end
        end
        if collectorBar._applyBarBorderVis then collectorBar._applyBarBorderVis() end
    end
    -- Anchor (same colours as the drawer/panel)
    if barAnchor then
        if barAnchor._bg     then barAnchor._bg:SetColorTexture(GetPanelBgColor())     end
        if barAnchor._border then barAnchor._border:SetColorTexture(GetPanelBorderColor()) end
    end
end

-- ============================================================================
-- APPLY OPTIONS  (split into helpers to stay under LuaJIT 60-upvalue limit)
-- ============================================================================

local function ApplyOptions_Minimap()
    Minimap:SetMovable(not DB("vistaLock", true))
    local sz       = GetMapSize()
    local mapScale = sz / MINIMAP_BASE_SIZE
    Minimap:SetSize(MINIMAP_BASE_SIZE, MINIMAP_BASE_SIZE)
    Minimap:SetMaskTexture(GetCircular() and MASK_CIRCULAR or MASK_SQUARE)
    pcall(function() local z = Minimap:GetZoom(); if z then Minimap:SetZoom(z) end end)
    local vistaScale  = DB("vistaScale", 1.0) or 1.0
    local moduleScale = (addon.GetModuleScale and addon.GetModuleScale("vista")) or 1
    proxy.SetScale(Minimap, vistaScale * moduleScale * mapScale)
    ApplyBorderTextures()
end

local function ApplyOptions_Texts(sz)
    if zoneText and decor._zoneContainer then
        local show = GetShowZone()
        local fp, fs = GetZoneFont(), GetZoneSize()
        zoneText:SetFont(fp, fs, "OUTLINE");  zoneShadow:SetFont(fp, fs, "OUTLINE")
        zoneText:SetTextColor(GetZoneColor())
        zoneText:SetShown(show);  zoneShadow:SetShown(show)
        local subText   = decor._zoneContainer._subZoneText
        local subShadow = decor._zoneContainer._subZoneShadow
        if subText then
            subText:SetFont(fp, fs, "OUTLINE");   subShadow:SetFont(fp, fs, "OUTLINE")
            subText:SetTextColor(GetZoneColor())
        end
        decor._zoneContainer:SetShown(show);  decor._zoneContainer:SetWidth(sz)
        local ap, rp = GetZoneAnchors()
        decor._zoneContainer:ClearAllPoints()
        decor._zoneContainer:SetPoint(ap, Minimap, rp, GetZoneOffsetX(), GetZoneOffsetY())
        decor._zoneContainer:SetMovable(not GetElemLocked("zone"))
        UpdateZoneText()
    end
    if coordText and decor._coordContainer then
        local show = GetShowCoord()
        local fp, fs = GetCoordFont(), GetCoordSize()
        coordText:SetFont(fp, fs, "OUTLINE"); coordShadow:SetFont(fp, fs, "OUTLINE")
        coordText:SetTextColor(GetCoordColor())
        coordText:SetShown(show); coordShadow:SetShown(show)
        decor._coordContainer:SetShown(show)
        local ap, rp = GetCoordAnchors()
        decor._coordContainer:ClearAllPoints()
        decor._coordContainer:SetPoint(ap, Minimap, rp, GetCoordOffsetX(), GetCoordOffsetY())
        decor._coordContainer:SetMovable(not GetElemLocked("coord"))
    end
    if timeText and decor._timeContainer then
        local show = GetShowTime()
        local fp, fs = GetTimeFont(), GetTimeSize()
        timeText:SetFont(fp, fs, "OUTLINE"); timeShadow:SetFont(fp, fs, "OUTLINE")
        timeText:SetTextColor(GetTimeColor())
        timeText:SetShown(show); timeShadow:SetShown(show)
        decor._timeContainer:SetShown(show)
        local ap, rp = GetTimeAnchors()
        decor._timeContainer:ClearAllPoints()
        decor._timeContainer:SetPoint(ap, Minimap, rp, GetTimeOffsetX(), GetTimeOffsetY())
        decor._timeContainer:SetMovable(not GetElemLocked("time"))
    end
    if diffText and decor._diffContainer then
        local fp, fs = GetDiffFont(), GetDiffSize()
        diffText:SetFont(fp, fs, "OUTLINE"); diffShadow:SetFont(fp, fs, "OUTLINE")
        diffText:SetWidth(sz); diffShadow:SetWidth(sz)
        decor._diffContainer:SetWidth(sz)
        decor._diffContainer:SetMovable(not G.DiffLocked())
        if not DB("vistaEX_diff", nil) then
            decor._diffContainer:ClearAllPoints()
            decor._diffContainer:SetPoint("TOP", decor._zoneContainer, "BOTTOM", 0, -2)
        end
        UpdateDifficultyText()
    end
    if collectorBar then
        local savedX = G.MouseoverBarX()
        local savedY = G.MouseoverBarY()
        collectorBar:ClearAllPoints()
        if savedX and savedY then
            collectorBar:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
        else
            collectorBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -8)
        end
    end
end

local function ApplyOptions_Buttons()
    CreateDefaultButtonProxies()
    if zoomInBtn and zoomOutBtn then
        local zoomSz     = GetZoomBtnSize()
        local zoomFontSz = math.max(10, math.floor(zoomSz * 0.875))
        zoomInBtn:SetSize(zoomSz, zoomSz);  zoomOutBtn:SetSize(zoomSz, zoomSz)
        if zoomInBtn._label  then zoomInBtn._label:SetFont(FONT_PATH_DEFAULT, zoomFontSz, "OUTLINE")  end
        if zoomOutBtn._label then zoomOutBtn._label:SetFont(FONT_PATH_DEFAULT, zoomFontSz, "OUTLINE") end
        local showZoom = GetShowZoomBtns()
        local moZoom   = GetMouseoverZoomBtns()
        if not showZoom then
            zoomInBtn:Hide(); zoomOutBtn:Hide()
        elseif moZoom then
            zoomInBtn:Show(); zoomOutBtn:Show()
            zoomInBtn:SetAlpha(0); zoomOutBtn:SetAlpha(0)
        else
            zoomInBtn:Show(); zoomOutBtn:Show()
            zoomInBtn:SetAlpha(1); zoomOutBtn:SetAlpha(1)
        end
    end
    if mailFrame then mailFrame:SetSize(GetMailIconSize(), GetMailIconSize()) end
    if drawerButton then
        local addonSz = GetAddonBtnSize()
        drawerButton:SetSize(addonSz + 4, addonSz + 4)
        if drawerButton._bg     then drawerButton._bg:SetColorTexture(GetPanelBgColor())     end
        if drawerButton._border then drawerButton._border:SetColorTexture(GetPanelBorderColor()) end
    end
    local bgR, bgG, bgB, bgA = GetPanelBgColor()
    local brR, brG, brB, brA = GetPanelBorderColor()
    if drawerPanel and drawerPanel._bgTex then
        drawerPanel._bgTex:SetColorTexture(bgR, bgG, bgB, bgA)
    end
    if drawerPanel and drawerPanel._borderTextures then
        for _, tex in ipairs(drawerPanel._borderTextures) do tex:SetColorTexture(brR, brG, brB, brA) end
    end
    if rightClickPanel and rightClickPanel._bgTex then
        rightClickPanel._bgTex:SetColorTexture(bgR, bgG, bgB, bgA)
    end
    if rightClickPanel and rightClickPanel._borderTextures then
        for _, tex in ipairs(rightClickPanel._borderTextures) do tex:SetColorTexture(brR, brG, brB, brA) end
    end
    -- Mouseover bar backdrop
    if collectorBar then
        if collectorBar._bgTex then collectorBar._bgTex:SetColorTexture(G.BarBgColor()) end
        if collectorBar._borderTextures then
            local bbR, bbG, bbB, bbA = G.BarBorderColor()
            for _, tex in ipairs(collectorBar._borderTextures) do tex:SetColorTexture(bbR, bbG, bbB, bbA) end
        end
        if collectorBar._applyBarBorderVis then collectorBar._applyBarBorderVis() end
    end
    -- Anchor colours + visibility sync
    if barAnchor then
        if barAnchor._bg     then barAnchor._bg:SetColorTexture(GetPanelBgColor())     end
        if barAnchor._border then barAnchor._border:SetColorTexture(GetPanelBorderColor()) end
        local ancSz = GetAddonBtnSize() + 4
        barAnchor:SetSize(ancSz, ancSz)
        UpdateBarAnchorVisibility()
    end
    for _, p in ipairs(defaultProxies) do
        if p and p._vistaKey then
            local pSz = GetProxyBtnSizeForKey(p._vistaKey)
            p:SetSize(pSz, pSz)
        end
    end
    CollectMinimapButtons()
    C_Timer.After(0.05, CollectMinimapButtons)
    CreateQueueAnchor()
end

function Vista.ApplyOptions()
    if not decor then return end
    ApplyOptions_Minimap()
    ApplyOptions_Texts(GetMapSize())
    ApplyOptions_Buttons()
end

--- Flash the mouseover bar visible for a few seconds so the user can see where it is
--- after toggling the position lock off.
function Vista.FlashMouseoverBar()
    if not collectorBar then return end
    if GetButtonMode() ~= BTN_MODE_MOUSEOVER then return end
    -- Cancel any in-flight flash timer
    if barFlashTimer then barFlashTimer:Cancel(); barFlashTimer = nil end
    -- Show immediately
    barAlpha   = 1
    hoverTarget = 1
    hoverElapsed = 0
    collectorBar:SetAlpha(1)
    UpdateBarAnchorVisibility()
    -- After 3 seconds, fade back out (unless user is hovering or always-visible is on)
    barFlashTimer = C_Timer.NewTimer(3, function()
        barFlashTimer = nil
        if G.MouseoverBarVisible() then return end
        if collectorBar and collectorBar:IsMouseOver() then return end
        if barAnchor and barAnchor:IsMouseOver() then return end
        if Minimap and Minimap:IsMouseOver() then return end
        hoverTarget  = 0
        hoverElapsed = 0
        UpdateBarAnchorVisibility()
    end)
end

-- ============================================================================
-- INIT / DISABLE
-- ============================================================================

function Vista.Init()
    if not Minimap or not MinimapCluster then return end

    proxy.SetFrameStrata(Minimap, "LOW")
    proxy.SetFrameLevel(Minimap, 2)
    pcall(function()
        proxy.SetFixedFrameStrata(Minimap, true)
        proxy.SetFixedFrameLevel(Minimap, true)
    end)

    proxy.SetParent(Minimap, UIParent)

    if hooksecurefunc then
        setParentHook = function()
            if addon:IsModuleEnabled("vista") then
                proxy.SetParent(Minimap, UIParent)
            end
        end
        hooksecurefunc(Minimap, "SetParent", setParentHook)
    end

    MinimapCluster:EnableMouse(false)

    if MinimapBackdrop then
        MinimapBackdrop:ClearAllPoints()
        MinimapBackdrop:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
    end


    StripBlizzardChrome()
    -- Explicitly hide AddonCompartmentFrame — it's UIParent-parented and loads late
    pcall(function()
        if AddonCompartmentFrame then
            AddonCompartmentFrame:Hide()
            AddonCompartmentFrame:SetAlpha(0)
            AddonCompartmentFrame.Show = function() end
        end
    end)
    SuppressDefaultBlizzardButtons()
    CreateDecor()
    SetupMinimap()
    CreateZoomButtons()
    CreateMailIndicator()
    CreateCollectorBar()
    SuppressBlizzardMail()
    CreateDefaultButtonProxies()
    CreateQueueAnchor()

    UpdateZoneText()
    UpdateDifficultyText()
    UpdateMailIndicator()
    ScheduleAutoZoom()

    decor:SetScript("OnUpdate", OnHoverUpdate)

    -- Re-apply options one frame after init so profile/scale are fully ready
    if C_Timer and C_Timer.After and Vista.ApplyOptions then
        C_Timer.After(0, Vista.ApplyOptions)
    end

    Minimap:HookScript("OnEnter", function()
        if GetButtonMode() == BTN_MODE_MOUSEOVER then
            hoverTarget = 1; hoverElapsed = 0; barCloseDelayElapsed = 0
        end
    end)
    Minimap:HookScript("OnLeave", function()
        if collectorBar and collectorBar:IsMouseOver() then return end
        for _, btn in ipairs(collectedButtons) do
            if btn:IsMouseOver() then return end
        end
        hoverTarget = 0; hoverElapsed = 0; barCloseDelayElapsed = 0
    end)

    Minimap:HookScript("OnMouseUp", function(_, button)
        if button == "RightButton" and GetButtonMode() == BTN_MODE_RIGHTCLICK then
            if not rightClickPanel then CreateRightClickPanel() end
            rightClickVisible = not rightClickVisible
            if rightClickVisible then
                LayoutRightClickPanel(collectedButtons)
                rightClickPanel:Show()
                if rightClickPanel._scheduleAutoClose then rightClickPanel._scheduleAutoClose() end
            else
                rightClickPanel:Hide()
                if rightClickPanel then rightClickPanel:SetScript("OnUpdate", nil) end
            end
        end
    end)

    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("ZONE_CHANGED")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    eventFrame:RegisterEvent("UPDATE_PENDING_MAIL")
    eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
    eventFrame:RegisterEvent("PET_BATTLE_OPENING_START")
    eventFrame:RegisterEvent("PET_BATTLE_CLOSE")
    eventFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
    eventFrame:RegisterEvent("ADDON_LOADED")

    eventFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" then
            C_Timer.After(0.5, function()
                StripBlizzardChrome()
                SuppressDefaultBlizzardButtons()
                HookMinimapClusterChildrenShow()
            end)
            return
        end
        if event == "PLAYER_ENTERING_WORLD" then
            local function reStrip()
                StripBlizzardChrome()
                SuppressDefaultBlizzardButtons()
                HookMinimapClusterChildrenShow()
            end
            reStrip()
            C_Timer.After(2.0, function()
                reStrip()
                CollectMinimapButtons()
            end)
            UpdateZoneText(); UpdateDifficultyText(); UpdateMailIndicator()
        elseif event == "MINIMAP_UPDATE_ZOOM" then
            -- WoW sometimes re-shows zoom buttons after zoom level changes — keep them gone
            SuppressZoomButtons()
            pcall(function()
                if Minimap.ZoomIn then Minimap.ZoomIn:SetAlpha(0) end
                if Minimap.ZoomOut then Minimap.ZoomOut:SetAlpha(0) end
            end)
        elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
            UpdateZoneText(); UpdateDifficultyText()
        elseif event == "UPDATE_INSTANCE_INFO" then
            UpdateDifficultyText()
        elseif event == "UPDATE_PENDING_MAIL" then
            UpdateMailIndicator()
        elseif event == "PET_BATTLE_OPENING_START" then
            Minimap:Hide()
        elseif event == "PET_BATTLE_CLOSE" then
            if addon:IsModuleEnabled("vista") then Minimap:Show() end
        end
    end)

    local showMinimap = DB("vistaShowMinimap", true)
    if showMinimap ~= false then Minimap:Show() else Minimap:Hide() end
end

function Vista.Disable()
    if not Minimap or not MinimapCluster then return end
    if eventFrame then eventFrame:UnregisterAllEvents(); eventFrame:SetScript("OnEvent", nil) end
    if decor then decor:SetScript("OnUpdate", nil) end
    HideAllProxyButtons()
    DestroyDrawerButton()
    if not InCombatLockdown() then proxy.SetParent(Minimap, MinimapCluster) end
    ReloadUI()
end

function Vista.CollectButtons()
    CollectMinimapButtons()
    return #collectedButtons + #drawerPanelButtons
end

function Vista.ApplyScale()
    if not Minimap then return end
    local scale = DB("vistaScale", 1.0) or 1.0
    local moduleScale = (addon.GetModuleScale and addon.GetModuleScale("vista")) or 1
    local mapScale = GetMapSize() / MINIMAP_BASE_SIZE
    proxy.SetScale(Minimap, scale * moduleScale * mapScale)
end

-- Convert PascalCase / camelCase to a human-readable string.
-- "MyAddonButton" -> "My Addon", "DBMMinimapButton" -> "DBM"
local function HumanizePascalCase(str)
    if not str or str == "" then return str end
    -- Insert spaces before uppercase letters that follow a lowercase letter or digit
    local spaced = str:gsub("(%l)(%u)", "%1 %2"):gsub("(%d)(%u)", "%1 %2"):gsub("(%u+)(%u%l)", "%1 %2")
    -- Trim and collapse multiple spaces
    spaced = spaced:gsub("  +", " "):match("^%s*(.-)%s*$")
    return spaced
end

-- Try to get a human-readable addon name from a frame name or its addon owner.
local function GetAddonDisplayName(btn)
    local cName = btn:GetName() or ""

    -- Handle LibDBIcon pattern: "LibDBIcon10_AddonName" → extract "AddonName"
    local libDBSuffix = cName:match("^LibDBIcon[%d]*_(.+)$")
    if libDBSuffix then
        -- Try to find the addon title from C_AddOns using the suffix as the addon name
        if C_AddOns and C_AddOns.GetAddOnInfo then
            local numAddons = C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns() or 0
            for i = 1, numAddons do
                local name, title = C_AddOns.GetAddOnInfo(i)
                if name and name:lower() == libDBSuffix:lower() then
                    return title or name, cName
                end
            end
        end
        -- No exact match found — humanize the suffix directly
        return HumanizePascalCase(libDBSuffix), cName
    end

    -- Try C_AddOns.GetAddOnInfo for the addon that owns this frame
    if C_AddOns and C_AddOns.GetAddOnInfo then
        -- Walk loaded addons and check if cName contains the addon name
        local numAddons = C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns() or 0
        for i = 1, numAddons do
            local name, title = C_AddOns.GetAddOnInfo(i)
            if name and cName:lower():find(name:lower(), 1, true) then
                return title or name, cName
            end
        end
    end
    -- Fallback: strip common suffixes from frame name, then humanize
    local stripped = cName:gsub("MinimapButton$",""):gsub("Button$",""):gsub("Frame$",""):gsub("Minimap$","")
    if stripped ~= "" and stripped ~= cName then
        return HumanizePascalCase(stripped), cName
    end
    return HumanizePascalCase(cName), cName
end

function Vista.GetDiscoveredButtonNames()
    local list = Vista._discoveredNames
    if list and #list > 0 then return list end

    -- Fallback: build from allManagedButtons if scan hasn't run yet
    local names = {}
    local seen = {}
    for btn in pairs(allManagedButtons) do
        local cName = btn.GetName and btn:GetName()
        if cName and not seen[cName] then
            seen[cName] = true
            names[#names + 1] = cName
        end
    end
    table.sort(names)
    return names
end

-- Returns a display name for a given frame name (for options panel labels)
function Vista.GetButtonDisplayName(frameName)
    local btn = _G[frameName]
    if not btn then return frameName end
    local display = GetAddonDisplayName(btn)
    return display
end

-- ============================================================================
-- MINIMAP POSITION
-- ============================================================================

--- Reset minimap to default position (top-right) and clear saved position from DB.
--- Called from options Reset button and slash command.
function Vista.ResetMinimapPosition()
    if not InCombatLockdown() then
        proxy.ClearAllPoints(Minimap)
        proxy.SetPoint(Minimap, DEFAULT_POINT, UIParent, DEFAULT_RELPOINT, DEFAULT_X, DEFAULT_Y)
    end
    SetDB("vistaPoint", nil)
    SetDB("vistaRelPoint", nil)
    SetDB("vistaX", nil)
    SetDB("vistaY", nil)
end

function Vista.RefreshQueueProxies()
    RefreshQueueAnchor()
end

addon.Vista = Vista
