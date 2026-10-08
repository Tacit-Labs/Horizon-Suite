--[[
    Horizon Suite - Vista - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section = addon.Section
local Header  = addon.Header
local Button  = addon.Button
local Toggle  = addon.Toggle
local FontRow = addon.FontRow
local D   = addon.VISTA_DEFAULTS
local LIM = addon.VISTA_LIMITS

local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end
local function getSlider(key)
    local lim = LIM[key]
    local v = tonumber(getDB(key, D[key])) or D[key]
    return math.max(lim.min, math.min(lim.max, v))
end

-- Pages: General, Layout and Look & feel hold the minimap's own settings. Text and Buttons hold
-- one card per element around it, each with its switch first and the rest nested under it, so
-- everything about (say) the FPS text is in one place.
addon.RegisterModulePages("vista", {
    { key = "text", name = L["VISTA_PAGE_TEXT"], desc = L["VISTA_PAGE_TEXT_DESC"] },
    { key = "buttons", name = L["VISTA_PAGE_BUTTONS"], desc = L["VISTA_PAGE_BUTTONS_DESC"], cardNames = {
        drawerTiming = L["VISTA_CARD_TIMING_LAYOUT"],
        panelColours = L["VISTA_CARD_PANEL_BAR_COLOURS"],
    } },
})

local categories = {
    {
        key = "VistaMinimap",
        name = L["VISTA_DESC"],
        desc = L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"],
        moduleKey = "vista",
        options = {
            Section(L["SIZE_SHAPE"], { page = "layout", card = "size" }),
            { type = "slider", name = L["VISTA_SIZE"],
              desc = L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"],
              dbKey = "vistaMapSize", min = LIM.vistaMapSize.min, max = LIM.vistaMapSize.max,
              get = function() return getSlider("vistaMapSize") end,
              set = function(v) setDB("vistaMapSize", clamp(v, "vistaMapSize")) end },
            Toggle(L["VISTA_CIRCULAR_SHAPE"], L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"], "vistaCircular", D.vistaCircular),
            Section(L["AXIS_POSITION"], { page = "layout", card = "position" }),
            Toggle(L["LOCK_MINIMAP"], L["VISTA_PREVENT_DRAGGING_MINIMAP"], "vistaLock", D.vistaLock),
            Button(L["VISTA_RESET_MINIMAP_POSITION"], L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"], function()
                if addon.Vista and addon.Vista.ResetMinimapPosition then
                    addon.Vista.ResetMinimapPosition()
                end
            end),
            Button(L["VISTA_RESET_ELEMENTS"], L["VISTA_RESET_OVERLAY_POSITIONS_DESC"], function()
                if addon.Vista and addon.Vista.ResetOverlayPositionsToDefaults then
                    addon.Vista.ResetOverlayPositionsToDefaults()
                end
            end),
            Section(L["VISTA_AUTO_ZOOM"], { page = "general", card = "behaviour" }),
            { type = "slider", name = L["VISTA_AUTO_ZOOM_DELAY"],
              desc = L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"],
              dbKey = "vistaAutoZoom", min = LIM.vistaAutoZoom.min, max = LIM.vistaAutoZoom.max,
              get = function() return getSlider("vistaAutoZoom") end,
              set = function(v) setDB("vistaAutoZoom", clamp(v, "vistaAutoZoom")) end },
        },
    },
    {
        key = "VistaAppearance",
        name = L["DASH_APPEARANCE"],
        desc = L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"],
        moduleKey = "vista",
        options = function()
            local GLOBAL_SENTINEL = "__global__"
            local GLOBAL_LABEL = L["FOCUS_GLOBAL_FONT"]

            local function fontOpts(dbKey)
                local list = { { GLOBAL_LABEL, GLOBAL_SENTINEL } }
                local fontList = (addon.GetFontList and addon.GetFontList()) or {}
                for _, f in ipairs(fontList) do list[#list + 1] = f end
                local saved = getDB(dbKey, GLOBAL_SENTINEL)
                if saved and saved ~= GLOBAL_SENTINEL and saved ~= "" then
                    local found = false
                    for _, o in ipairs(list) do if o[2] == saved then found = true; break end end
                    if not found then list[#list + 1] = { "Custom", saved } end
                end
                return list
            end

            local function displayFont(v)
                if v == GLOBAL_SENTINEL or v == nil or v == "" then return GLOBAL_LABEL end
                if addon.GetFontNameForPath then return addon.GetFontNameForPath(v) end
                return v
            end

            local function getFont(dbKey)
                local v = getDB(dbKey, GLOBAL_SENTINEL)
                if v == nil or v == "" then return GLOBAL_SENTINEL end
                return v
            end

            -- A colour row stored as three channel keys (prefix .. "R", "G", "B").
            local function Rgb(name, desc, dbKey, prefix, extra)
                local row = { type = "color", name = name, desc = desc, dbKey = dbKey,
                    get = function()
                        return getDB(prefix .. "R", D[prefix .. "R"]), getDB(prefix .. "G", D[prefix .. "G"]),
                               getDB(prefix .. "B", D[prefix .. "B"])
                    end,
                    set = function(r, g, b)
                        setDB(prefix .. "R", r); setDB(prefix .. "G", g); setDB(prefix .. "B", b)
                    end }
                for k, v in pairs(extra or {}) do row[k] = v end
                return row
            end

            -- Above or below the minimap for one text element; choosing clears a dragged offset.
            local function PositionRow(elem, dbKey, desc, parent)
                return { type = "dropdown", name = L["AXIS_POSITION"], desc = desc, dbKey = dbKey,
                    options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
                    get = function() return getDB(dbKey, D[dbKey]) or D[dbKey] end,
                    set = function(v)
                        setDB(dbKey, v)
                        setDB("vistaEX_" .. elem, nil); setDB("vistaEY_" .. elem, nil)
                    end,
                    parent = parent }
            end

            -- A button or indicator size slider; oldLabel keeps it findable by its former name.
            local function SizeRow(dbKey, desc, parent, oldLabel, parentIs)
                return { type = "slider", name = L["DASH_ROW_SIZE"], desc = desc, dbKey = dbKey,
                    min = LIM[dbKey].min, max = LIM[dbKey].max,
                    get = function() return getSlider(dbKey) end,
                    set = function(v) setDB(dbKey, clamp(v, dbKey)) end,
                    parent = parent, parentIs = parentIs, keywords = { oldLabel } }
            end

            return {
            Section(L["VISTA_BORDER"], { page = "look", card = "background" }),
            Toggle(L["FOCUS_BORDER"], L["VISTA_BORDER_TIP"], "vistaBorderShow", D.vistaBorderShow),
            { type = "color", name = L["VISTA_BORDER_COLOUR"],
              desc = L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"],
              dbKey = "vistaBorderColor",
              get = function()
                  return getDB("vistaBorderColorR", D.vistaBorderColorR), getDB("vistaBorderColorG", D.vistaBorderColorG),
                         getDB("vistaBorderColorB", D.vistaBorderColorB), getDB("vistaBorderColorA", D.vistaBorderColorA)
              end,
              set = function(r, g, b, a)
                  setDB("vistaBorderColorR", r); setDB("vistaBorderColorG", g)
                  setDB("vistaBorderColorB", b)
                  if a ~= nil then setDB("vistaBorderColorA", a) end
              end,
              hasAlpha = true },
            { type = "slider", name = L["VISTA_BORDER_THICKNESS"],
              desc = L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"],
              dbKey = "vistaBorderWidth", min = LIM.vistaBorderWidth.min, max = LIM.vistaBorderWidth.max,
              get = function() return getSlider("vistaBorderWidth") end,
              set = function(v)
                  addon.SetDB("vistaBorderWidth", clamp(v, "vistaBorderWidth"))
                  if addon.Vista then
                      if addon._vistaBorderDebounce then addon._vistaBorderDebounce:Cancel() end
                      addon._vistaBorderDebounce = C_Timer.NewTimer(0.15, function()
                          addon._vistaBorderDebounce = nil
                          if addon.Vista.ApplyOptions then addon.Vista.ApplyOptions() end
                      end)
                  end
              end },
            { type = "slider", name = L["VISTA_OPACITY"],
              desc = L["VISTA_OPACITY_DESC"],
              dbKey = "vistaOpacity", min = LIM.vistaOpacity.min, max = LIM.vistaOpacity.max, step = 1,
              get = function() return getSlider("vistaOpacity") end,
              set = function(v) setDB("vistaOpacity", clamp(v, "vistaOpacity")) end },
            { type = "slider", name = L["VISTA_COMBAT_OPACITY"],
              desc = L["VISTA_COMBAT_OPACITY_DESC"],
              dbKey = "vistaCombatOpacity", min = LIM.vistaCombatOpacity.min, max = LIM.vistaCombatOpacity.max, step = 1,
              get = function() return getSlider("vistaCombatOpacity") end,
              set = function(v) setDB("vistaCombatOpacity", clamp(v, "vistaCombatOpacity")) end },
            -- ===== Text page: one card per text element =====
            -- Each card leads with the element's switch; position, lock, font and colour nest under
            -- it, so turning the element off folds its card to one row.
            Section(L["VISTA_ZONE_TEXT"], { page = "text", card = "zone" }),
            Toggle(L["VISTA_ZONE_TEXT"], L["VISTA_ZONE_NAME_BELOW_MINIMAP"], "vistaShowZoneText", D.vistaShowZoneText),
            { type = "dropdown", name = L["VISTA_ZONE_TEXT_DISPLAY_MODE"],
              desc = L["VISTA_WHAT_ZONE_SUBZONE"],
              dbKey = "vistaZoneDisplayMode",
              options = function() return {
                  { L["VISTA_SHOW_ZONE"], "zone" },
                  { L["VISTA_SHOW_SUBZONE"], "subzone" },
                  { L["VISTA_SHOW_ZONE_AND_SUBZONE"], "both" },
              } end,
              get = function() return getDB("vistaZoneDisplayMode", D.vistaZoneDisplayMode) end,
              set = function(v) setDB("vistaZoneDisplayMode", v) end,
              parent = "vistaShowZoneText" },
            PositionRow("zone", "vistaZoneVerticalPos", L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"], "vistaShowZoneText"),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"], "vistaLocked_zone", D.vistaLocked_zone, { parent = "vistaShowZoneText" }),
            FontRow(L["FOCUS_FONT"], L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"], {
                family = {
                    dbKey = "vistaZoneFontPath", searchable = true,
                    options = function() return fontOpts("vistaZoneFontPath") end,
                    get = function() return getFont("vistaZoneFontPath") end,
                    set = function(v) setDB("vistaZoneFontPath", v) end,
                    displayFn = displayFont, fontPreviewInList = true,
                },
                size = {
                    dbKey = "vistaZoneFontSize", min = LIM.vistaZoneFontSize.min, max = LIM.vistaZoneFontSize.max,
                    get = function() return getSlider("vistaZoneFontSize") end,
                    set = function(v) setDB("vistaZoneFontSize", clamp(v, "vistaZoneFontSize")) end,
                },
            }, { parent = "vistaShowZoneText", keywords = { L["VISTA_ZONE_FONT"], L["VISTA_ZONE_FONT_SIZE"] } }),
            Rgb(L["DASH_ROW_COLOUR"], L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"], "vistaZoneColor", "vistaZoneColor",
                { parent = "vistaShowZoneText", keywords = { L["VISTA_ZONE_TEXT_COLOUR"] } }),

            Section(L["VISTA_COORDINATES"], { page = "text", card = "coordinates" }),
            Toggle(L["VISTA_COORDINATES"], L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"], "vistaShowCoordText", D.vistaShowCoordText),
            { type = "dropdown", name = L["VISTA_COORDINATE_PRECISION"],
              desc = L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"],
              dbKey = "vistaCoordPrecision",
              options = function() return {
                  { L["VISTA_COORDS_DECIMALS_OFF"],      0 },
                  { L["VISTA_DECIMAL_E_G"],    1 },
                  { L["VISTA_DECIMALS_E_G"], 2 },
              } end,
              get = function() return tonumber(getDB("vistaCoordPrecision", D.vistaCoordPrecision)) or D.vistaCoordPrecision end,
              set = function(v) setDB("vistaCoordPrecision", tonumber(v) or D.vistaCoordPrecision) end,
              parent = "vistaShowCoordText" },
            PositionRow("coord", "vistaCoordVerticalPos", L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"], "vistaShowCoordText"),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"], "vistaLocked_coord", D.vistaLocked_coord, { parent = "vistaShowCoordText" }),
            FontRow(L["FOCUS_FONT"], L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"], {
                family = {
                    dbKey = "vistaCoordFontPath", searchable = true,
                    options = function() return fontOpts("vistaCoordFontPath") end,
                    get = function() return getFont("vistaCoordFontPath") end,
                    set = function(v) setDB("vistaCoordFontPath", v) end,
                    displayFn = displayFont, fontPreviewInList = true,
                },
                size = {
                    dbKey = "vistaCoordFontSize", min = LIM.vistaCoordFontSize.min, max = LIM.vistaCoordFontSize.max,
                    get = function() return getSlider("vistaCoordFontSize") end,
                    set = function(v) setDB("vistaCoordFontSize", clamp(v, "vistaCoordFontSize")) end,
                },
            }, { parent = "vistaShowCoordText", keywords = { L["VISTA_COORDINATES_FONT"], L["VISTA_COORDINATES_FONT_SIZE"] } }),
            Rgb(L["DASH_ROW_COLOUR"], L["VISTA_COLOUR_OF_COORDINATES_TEXT"], "vistaCoordColor", "vistaCoordColor",
                { parent = "vistaShowCoordText", keywords = { L["VISTA_COORDINATES_TEXT_COLOUR"] } }),

            Section(L["VISTA_CARD_CLOCK"], { page = "text", card = "clock" }),
            Toggle(L["VISTA_TIME"], L["VISTA_CURRENT_GAME_BELOW_MINIMAP"], "vistaShowTimeText", D.vistaShowTimeText),
            Toggle(L["VISTA_LOCAL_TIME"], L["LOCAL_SYSTEM"], "vistaTimeUseLocal", D.vistaTimeUseLocal, { tooltip = L["VISTA_LOCAL_TIME_TIP"], parent = "vistaShowTimeText" }),
            Toggle(L["VISTA_HOUR_CLOCK"], L["VISTA_DISPLAY_HOUR_FORMAT_24"], "vistaTime24Hour", D.vistaTime24Hour, { parent = "vistaShowTimeText" }),
            PositionRow("time", "vistaTimeVerticalPos", L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"], "vistaShowTimeText"),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_TEXT_CANNOT_DRAGGED"], "vistaLocked_time", D.vistaLocked_time, { parent = "vistaShowTimeText" }),
            FontRow(L["FOCUS_FONT"], L["VISTA_FONT_TEXT_BELOW_MINIMAP"], {
                family = {
                    dbKey = "vistaTimeFontPath", searchable = true,
                    options = function() return fontOpts("vistaTimeFontPath") end,
                    get = function() return getFont("vistaTimeFontPath") end,
                    set = function(v) setDB("vistaTimeFontPath", v) end,
                    displayFn = displayFont, fontPreviewInList = true,
                },
                size = {
                    dbKey = "vistaTimeFontSize", min = LIM.vistaTimeFontSize.min, max = LIM.vistaTimeFontSize.max,
                    get = function() return getSlider("vistaTimeFontSize") end,
                    set = function(v) setDB("vistaTimeFontSize", clamp(v, "vistaTimeFontSize")) end,
                },
            }, { parent = "vistaShowTimeText", keywords = { L["VISTA_FONT"], L["VISTA_FONT_SIZE"] } }),
            Rgb(L["DASH_ROW_COLOUR"], L["VISTA_COLOUR_OF_TEXT"], "vistaTimeColor", "vistaTimeColor",
                { parent = "vistaShowTimeText", keywords = { L["VISTA_TEXT_COLOUR"] } }),

            Section(L["VISTA_CARD_PERFORMANCE"], { page = "text", card = "performance" }),
            Toggle(L["VISTA_FPS_LATENCY"], L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"], "vistaShowPerfText", D.vistaShowPerfText),
            PositionRow("perf", "vistaPerfVerticalPos", L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"], "vistaShowPerfText"),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"], "vistaLocked_perf", D.vistaLocked_perf, { parent = "vistaShowPerfText" }),
            FontRow(L["FOCUS_FONT"], L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"], {
                family = {
                    dbKey = "vistaPerfFontPath", searchable = true,
                    options = function() return fontOpts("vistaPerfFontPath") end,
                    get = function() return getFont("vistaPerfFontPath") end,
                    set = function(v) setDB("vistaPerfFontPath", v) end,
                    displayFn = displayFont, fontPreviewInList = true,
                },
                size = {
                    dbKey = "vistaPerfFontSize", min = LIM.vistaPerfFontSize.min, max = LIM.vistaPerfFontSize.max,
                    get = function() return getSlider("vistaPerfFontSize") end,
                    set = function(v) setDB("vistaPerfFontSize", clamp(v, "vistaPerfFontSize")) end,
                },
            }, { parent = "vistaShowPerfText", keywords = { L["VISTA_PERFORMANCE_FONT"], L["VISTA_PERFORMANCE_FONT_SIZE"] } }),
            Rgb(L["DASH_ROW_COLOUR"], L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"], "vistaPerfColor", "vistaPerfColor",
                { parent = "vistaShowPerfText", keywords = { L["VISTA_PERFORMANCE_TEXT_COLOUR"] } }),

            -- Difficulty text has no switch: it always shows inside an instance.
            Section(L["VISTA_CARD_DIFFICULTY"], { page = "text", card = "difficulty" }),
            PositionRow("diff", "vistaDiffVerticalPos", L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"]),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"], "vistaLocked_diff", D.vistaLocked_diff),
            FontRow(L["FOCUS_FONT"], L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"], {
                family = {
                    dbKey = "vistaDiffFontPath", searchable = true,
                    options = function() return fontOpts("vistaDiffFontPath") end,
                    get = function() return getFont("vistaDiffFontPath") end,
                    set = function(v) setDB("vistaDiffFontPath", v) end,
                    displayFn = displayFont, fontPreviewInList = true,
                },
                size = {
                    dbKey = "vistaDiffFontSize", min = LIM.vistaDiffFontSize.min, max = LIM.vistaDiffFontSize.max,
                    get = function() return getSlider("vistaDiffFontSize") end,
                    set = function(v) setDB("vistaDiffFontSize", clamp(v, "vistaDiffFontSize")) end,
                },
            }, { keywords = { L["VISTA_DIFFICULTY_FONT"], L["VISTA_DIFFICULTY_FONT_SIZE"] } }),
            Rgb(L["VISTA_MYTHIC_COLOUR"], L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"], "vistaDiffColor_mythic", "vistaDiffColor_mythic_"),
            Rgb(L["VISTA_HEROIC_COLOUR"], L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"], "vistaDiffColor_heroic", "vistaDiffColor_heroic_"),
            Rgb(L["VISTA_NORMAL_COLOUR"], L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"], "vistaDiffColor_normal", "vistaDiffColor_normal_"),
            Rgb(L["VISTA_LFR_COLOUR"], L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"], "vistaDiffColor_lfr", "vistaDiffColor_looking_for_raid_"),
            Rgb(L["VISTA_DIFF_OTHER"], L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"], "vistaDiffColor", "vistaDiffColor",
                { keywords = { L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"] } }),

            -- ===== Buttons page: one card per Blizzard button or indicator =====
            Section(L["VISTA_CARD_TRACKING"], { page = "buttons", card = "tracking" }),
            Toggle(L["VISTA_TRACKING_BUTTON"], L["VISTA_MINIMAP_TRACKING_BUTTON"], "vistaShowTracking", D.vistaShowTracking),
            Toggle(L["VISTA_TRACKING_BUTTON_MOUSEOVER"], L["HOVER"], "vistaMouseoverTracking", D.vistaMouseoverTracking, { tooltip = L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"], parent = "vistaShowTracking" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"], "vistaLocked_proxy_tracking", D.vistaLocked_proxy_tracking, { parent = "vistaShowTracking" }),
            SizeRow("vistaTrackingBtnSize", L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"], "vistaShowTracking", L["VISTA_TRACKING_BUTTON_SIZE"]),

            Section(L["VISTA_CARD_CALENDAR"], { page = "buttons", card = "calendar" }),
            Toggle(L["VISTA_CALENDAR_BUTTON"], L["VISTA_MINIMAP_CALENDAR_BUTTON"], "vistaShowCalendar", D.vistaShowCalendar),
            Toggle(L["VISTA_CALENDAR_BUTTON_MOUSEOVER"], L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"], "vistaMouseoverCalendar", D.vistaMouseoverCalendar, { parent = "vistaShowCalendar" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"], "vistaLocked_proxy_calendar", D.vistaLocked_proxy_calendar, { parent = "vistaShowCalendar" }),
            SizeRow("vistaCalendarBtnSize", L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"], "vistaShowCalendar", L["VISTA_CALENDAR_BUTTON_SIZE"]),

            Section(L["VISTA_CARD_TELEPORT"], { page = "buttons", card = "teleport" }),
            Toggle(L["VISTA_TELEPORT_BUTTON"], L["VISTA_TELEPORT_BUTTON_DESC"], "vistaShowTeleport", D.vistaShowTeleport),
            Toggle(L["VISTA_TELEPORT_BUTTON_MOUSEOVER"], L["VISTA_TELEPORT_BUTTON_MOUSEOVER_DESC"], "vistaMouseoverTeleport", D.vistaMouseoverTeleport, { parent = "vistaShowTeleport" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_LOCK_TELEPORT_BUTTON_DESC"], "vistaLocked_proxy_teleport", D.vistaLocked_proxy_teleport, { parent = "vistaShowTeleport" }),
            SizeRow("vistaTeleportBtnSize", L["VISTA_TELEPORT_BUTTON_SIZE_DESC"], "vistaShowTeleport", L["VISTA_TELEPORT_BUTTON_SIZE"]),

            -- The teleport button's menu, next to the button that opens it.
            Section(L["VISTA_TELEPORT_MENU"], { page = "buttons", card = "teleportMenu" }),
            Toggle(L["VISTA_TELEPORT_GROUP_HEARTHSTONE"], L["VISTA_TELEPORT_GROUP_HEARTHSTONE_DESC"], "vistaTeleportGroup_hearthstone", D.vistaTeleportGroup_hearthstone),
            Toggle(L["VISTA_TELEPORT_GROUP_PROFESSION"], L["VISTA_TELEPORT_GROUP_PROFESSION_DESC"], "vistaTeleportGroup_profession", D.vistaTeleportGroup_profession),
            Toggle(L["VISTA_TELEPORT_GROUP_CLASS"], L["VISTA_TELEPORT_GROUP_CLASS_DESC"], "vistaTeleportGroup_class", D.vistaTeleportGroup_class),
            Toggle(L["VISTA_TELEPORT_GROUP_DUNGEON"], L["VISTA_TELEPORT_GROUP_DUNGEON_DESC"], "vistaTeleportGroup_dungeon", D.vistaTeleportGroup_dungeon),
            Toggle(L["VISTA_TELEPORT_GROUP_EVENT"], L["VISTA_TELEPORT_GROUP_EVENT_DESC"], "vistaTeleportGroup_event", D.vistaTeleportGroup_event),
            Section(L["VISTA_TELEPORT_MENU_BEHAVIOUR"], { page = "buttons", card = "teleportMenuBehaviour" }),
            Toggle(L["VISTA_TELEPORT_SHOW_COOLDOWNS"], L["VISTA_TELEPORT_SHOW_COOLDOWNS_DESC"], "vistaTeleportShowCooldowns", D.vistaTeleportShowCooldowns),
            Toggle(L["VISTA_TELEPORT_SHOW_RECENTS"], L["VISTA_TELEPORT_SHOW_RECENTS_DESC"], "vistaTeleportShowRecents", D.vistaTeleportShowRecents),
            Toggle(L["VISTA_TELEPORT_ENABLE_FAVOURITES"], L["VISTA_TELEPORT_ENABLE_FAVOURITES_DESC"], "vistaTeleportEnableFavorites", D.vistaTeleportEnableFavorites, { tooltip = L["VISTA_TELEPORT_ENABLE_FAVOURITES_TIP"] }),
            Button(L["VISTA_TELEPORT_CLEAR_RECENT"], L["VISTA_TELEPORT_CLEAR_RECENT_DESC"], function() setDB("vistaTeleportRecent", {}) end),
            Button(L["VISTA_TELEPORT_CLEAR_FAVOURITES"], L["VISTA_TELEPORT_CLEAR_FAVOURITES_DESC"], function() setDB("vistaTeleportFavorites", {}) end),

            Section(L["VISTA_CARD_LANDING"], { page = "buttons", card = "landing" }),
            Toggle(L["VISTA_LANDING_BUTTON"], L["VISTA_LANDING_BUTTON_DESC"], "vistaShowLanding", D.vistaShowLanding),
            Toggle(L["VISTA_LANDING_BUTTON_MOUSEOVER"], L["VISTA_LANDING_BUTTON_MOUSEOVER_DESC"], "vistaMouseoverLanding", D.vistaMouseoverLanding, { parent = "vistaShowLanding" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_LANDING_BUTTON"], "vistaLocked_proxy_landing", D.vistaLocked_proxy_landing, { parent = "vistaShowLanding" }),
            SizeRow("vistaLandingBtnSize", L["VISTA_SIZE_OF_LANDING_BUTTON_PIXELS"], "vistaShowLanding", L["VISTA_LANDING_BUTTON_SIZE"]),

            -- Queue status always shows; Vista only places it, unless handling is off.
            Section(L["VISTA_CARD_QUEUE"], { page = "buttons", card = "queue" }),
            Toggle(L["VISTA_DISABLE_QUEUE_HANDLING"], L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"], "vistaQueueHandlingDisabled", D.vistaQueueHandlingDisabled),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"], "vistaLocked_proxy_queue", D.vistaLocked_proxy_queue,
                { parent = "vistaQueueHandlingDisabled", parentIs = false }),
            SizeRow("vistaQueueBtnSize", L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"], "vistaQueueHandlingDisabled", L["VISTA_QUEUE_BUTTON_SIZE"], false),

            Section(L["VISTA_CARD_MAIL"], { page = "buttons", card = "mail" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_MAIL_ICON"], "vistaLocked_proxy_mail", D.vistaLocked_proxy_mail),
            SizeRow("vistaMailIconSize", L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"], nil, L["VISTA_MAIL_INDICATOR_SIZE"]),
            Toggle(L["DASH_ROW_PULSE"], L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"], "vistaMailBlink", D.vistaMailBlink, { keywords = { L["MAIL_ICON_PULSE"] } }),

            Section(L["VISTA_CARD_CRAFTING"], { page = "buttons", card = "craftingOrders" }),
            Toggle(L["FOCUS_LOCK_POSITION"], L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"], "vistaLocked_proxy_craftingOrder", D.vistaLocked_proxy_craftingOrder),
            SizeRow("vistaCraftingOrderIconSize", L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"], nil, L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"]),
            Toggle(L["DASH_ROW_PULSE"], L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"], "vistaCraftingOrderBlink", D.vistaCraftingOrderBlink, { keywords = { L["VISTA_CRAFTING_ORDER_ICON_PULSE"] } }),
        } end,
    },
    {
        key = "VistaButtons",
        name = L["VISTA_ADDON_BUTTONS"],
        desc = L["VISTA_ICON_MANAGEMENT"],
        moduleKey = "vista",
        options = function()
            local BUTTON_MODE_OPTIONS = {
                { L["VISTA_MOUSEOVER_BAR"], "mouseover" },
                { L["VISTA_RIGHT_CLICK_PANEL"], "rightclick" },
                { L["VISTA_FLOATING_DRAWER"], "drawer" },
            }

            local opts = {
                Section(L["VISTA_CARD_ADDON_BUTTONS"], { page = "buttons", card = "addonButtons" }),
                { type = "toggle", name = L["MANAGE_ADDON_BUTTONS"],
                  desc = L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"], tooltip = L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"],
                  dbKey = "vistaHandleAddonButtons",
                  get = function() return getDB("vistaHandleAddonButtons", D.vistaHandleAddonButtons) end,
                  set = function(v)
                      setDB("vistaHandleAddonButtons", v)
                      if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                          C_Timer.After(0, addon.OptionsPanel_Refresh)
                      elseif addon.OptionsPanel_Refresh then
                          addon.OptionsPanel_Refresh()
                      end
                  end },
                { type = "toggle", name = L["VISTA_COLLECT_HORIZON_MINIMAP"],
                  desc = L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"],
                  dbKey = "vistaCollectHorizonMinimapButton",
                  get = function() return getDB("vistaCollectHorizonMinimapButton", D.vistaCollectHorizonMinimapButton) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", D.vistaHandleAddonButtons) then return end
                      if C_Timer and C_Timer.After then
                          C_Timer.After(0, function() setDB("vistaCollectHorizonMinimapButton", v) end)
                      else
                          setDB("vistaCollectHorizonMinimapButton", v)
                      end
                  end,
                  parent = "vistaHandleAddonButtons" },
                Toggle(L["VISTA_SORT_BUTTONS_ALPHA"], L["VISTA_SORT_BUTTONS_ALPHA_DESC"], "vistaButtonSortAlpha", D.vistaButtonSortAlpha, { parent = "vistaHandleAddonButtons" }),
                { type = "dropdown", name = L["VISTA_BUTTON_MODE"],
                  desc = L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"],
                  dbKey = "vistaButtonMode",
                  options = BUTTON_MODE_OPTIONS,
                  refreshIds = { "vistaDrawerIcon" },
                  get = function() return getDB("vistaButtonMode", D.vistaButtonMode) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", D.vistaHandleAddonButtons) then return end
                      setDB("vistaButtonMode", v)
                      if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                          C_Timer.After(0, addon.OptionsPanel_Refresh)
                      elseif addon.OptionsPanel_Refresh then
                          addon.OptionsPanel_Refresh()
                      end
                  end,
                  parent = "vistaHandleAddonButtons" },
                { type = "toggle", name = L["LOCK_DRAWER_BUTTON"],
                  desc = L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"],
                  dbKey = "vistaDrawerButtonLocked",
                  get = function() return getDB("vistaDrawerButtonLocked", D.vistaDrawerButtonLocked) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", D.vistaHandleAddonButtons) then return end
                      if getDB("vistaButtonMode", D.vistaButtonMode) ~= "drawer" then return end
                      setDB("vistaDrawerButtonLocked", v)
                  end,
                  parent = "vistaButtonMode", parentIs = "drawer" },
                Toggle(L["LOCK_MOUSEOVER_BAR"], L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"], "vistaMouseoverLocked", D.vistaMouseoverLocked, { parent = "vistaButtonMode", parentIs = "mouseover"  }),
                Toggle(L["VISTA_ALWAYS_BAR"], L["KEEP_BAR_VISIBLE_REPOSITIONING"], "vistaMouseoverBarVisible", D.vistaMouseoverBarVisible, { tooltip = L["VISTA_DISABLE_DONE"], parent = "vistaButtonMode", parentIs = "mouseover"  }),
                Toggle(L["LOCK_RIGHT_CLICK_PANEL"], L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"], "vistaRightClickLocked", D.vistaRightClickLocked, { parent = "vistaButtonMode", parentIs = "rightclick"  }),
                -- Not nested: it also sizes Horizon's own minimap icon when that stands alone.
                { type = "slider", name = L["DASH_ROW_SIZE"],
                  desc = L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"],
                  dbKey = "vistaAddonBtnSize", min = LIM.vistaAddonBtnSize.min, max = LIM.vistaAddonBtnSize.max,
                  keywords = { L["VISTA_ADDON_BUTTON_SIZE"] },
                  get = function() return getSlider("vistaAddonBtnSize") end,
                  set = function(v)
                      setDB("vistaAddonBtnSize", clamp(v, "vistaAddonBtnSize"))
                      if addon._vistaAddonBtnDebounce then addon._vistaAddonBtnDebounce:Cancel() end
                      if C_Timer and C_Timer.NewTimer then
                          addon._vistaAddonBtnDebounce = C_Timer.NewTimer(0.15, function()
                              addon._vistaAddonBtnDebounce = nil
                              if addon.Vista and addon.Vista.ApplyOptions then
                                  addon.Vista.ApplyOptions()
                              elseif addon.MinimapButton_ApplyPosition then
                                  addon.MinimapButton_ApplyPosition()
                              end
                          end)
                      end
                  end },
                { type = "button",
                  name = L["VISTA_CHOOSE_DRAWER_ICON"],
                  dbKey = "vistaDrawerIcon",
                  visibleWhen = function()
                      return getDB("vistaHandleAddonButtons", D.vistaHandleAddonButtons) and getDB("vistaButtonMode", D.vistaButtonMode) == "drawer"
                  end,
                  tooltip = L["VISTA_DRAWER_BUTTON_ICON_DESC"],
                  onClick = function()
                      if addon.OpenVistaDrawerIconPicker then
                          addon.OpenVistaDrawerIconPicker()
                      end
                  end },

                Section(L["VISTA_CLOSE_FADE_TIMING"], { page = "buttons", card = "drawerTiming" }),
                { type = "slider", name = L["MOUSEOVER_CLOSE_DELAY"],
                  desc = L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"],
                  dbKey = "vistaMouseoverCloseDelay", min = LIM.vistaMouseoverCloseDelay.min, max = LIM.vistaMouseoverCloseDelay.max, step = 0.5,
                  get = function() return getSlider("vistaMouseoverCloseDelay") end,
                  set = function(v) setDB("vistaMouseoverCloseDelay", clamp(v, "vistaMouseoverCloseDelay")) end,
                  parent = "vistaHandleAddonButtons",
                },
                { type = "slider", name = L["RIGHT_CLICK_CLOSE_DELAY"],
                  desc = L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"],
                  dbKey = "vistaRightClickCloseDelay", min = LIM.vistaRightClickCloseDelay.min, max = LIM.vistaRightClickCloseDelay.max, step = 0.5,
                  get = function() return getSlider("vistaRightClickCloseDelay") end,
                  set = function(v) setDB("vistaRightClickCloseDelay", clamp(v, "vistaRightClickCloseDelay")) end,
                  parent = "vistaHandleAddonButtons",
                },
                { type = "slider", name = L["VISTA_DRAWER_CLOSE_DELAY"],
                  desc = L["AUTO_CLOSE_DELAY_DISABLE"],
                  tooltip = L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"],
                  dbKey = "vistaDrawerCloseDelay", min = LIM.vistaDrawerCloseDelay.min, max = LIM.vistaDrawerCloseDelay.max, step = 0.5,
                  get = function() return getSlider("vistaDrawerCloseDelay") end,
                  set = function(v) setDB("vistaDrawerCloseDelay", clamp(v, "vistaDrawerCloseDelay")) end,
                  parent = "vistaHandleAddonButtons",
                },

                Section(L["DASH_LAYOUT"], { page = "buttons", card = "drawerTiming" }),
            }

            local DIR_OPTIONS = function() return {
                { L["VISTA_BUTTONS_FILL_RIGHT"], "right" },
                { L["VISTA_BUTTONS_FILL_LEFT"],   "left"  },
                { L["VISTA_BUTTONS_FILL_DOWN"],   "down"  },
                { L["VISTA_BUTTONS_FILL_UP"],       "up"    },
            } end

            opts[#opts + 1] = {
                type = "slider", name = L["VISTA_BUTTONS_PER_ROW_COLUMN"],
                desc = L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"],
                dbKey = "vistaBtnLayoutCols", min = LIM.vistaBtnLayoutCols.min, max = LIM.vistaBtnLayoutCols.max, step = 1,
                get = function() return getSlider("vistaBtnLayoutCols") end,
                set = function(v)
                    setDB("vistaBtnLayoutCols", clamp(v, "vistaBtnLayoutCols"))
                    if addon._vistaBtnColsDebounce then addon._vistaBtnColsDebounce:Cancel() end
                    if C_Timer and C_Timer.NewTimer and addon.Vista and addon.Vista.ApplyOptions then
                        addon._vistaBtnColsDebounce = C_Timer.NewTimer(0.15, function()
                            addon._vistaBtnColsDebounce = nil
                            addon.Vista.ApplyOptions()
                        end)
                    end
                end,
                parent = "vistaHandleAddonButtons",
            }
            opts[#opts + 1] = {
                type = "dropdown", name = L["VISTA_EXPAND_DIRECTION"],
                desc = L["EXPAND_DIRECTION_ANCHOR"],
                tooltip = L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"],
                dbKey = "vistaBtnLayoutDir", options = DIR_OPTIONS,
                get = function() return getDB("vistaBtnLayoutDir", D.vistaBtnLayoutDir) end,
                set = function(v) setDB("vistaBtnLayoutDir", v) end,
                parent = "vistaHandleAddonButtons",
            }

            opts[#opts + 1] = Section(L["VISTA_PANEL_APPEARANCE"], { page = "buttons", card = "panelColours" })
            opts[#opts + 1] = Header(L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"])
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BG_COLOUR_LABEL"],
                desc = L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"],
                dbKey = "vistaPanelBg",
                get = function()
                    return getDB("vistaPanelBgR", D.vistaPanelBgR), getDB("vistaPanelBgG", D.vistaPanelBgG),
                           getDB("vistaPanelBgB", D.vistaPanelBgB), getDB("vistaPanelBgA", D.vistaPanelBgA)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBgR", r); setDB("vistaPanelBgG", g)
                    setDB("vistaPanelBgB", b)
                    if a ~= nil then setDB("vistaPanelBgA", a) end
                end,
                hasAlpha = true,
            }
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BORDER_COLOUR"],
                desc = L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"],
                dbKey = "vistaPanelBorder",
                get = function()
                    return getDB("vistaPanelBorderR", D.vistaPanelBorderR), getDB("vistaPanelBorderG", D.vistaPanelBorderG),
                           getDB("vistaPanelBorderB", D.vistaPanelBorderB), getDB("vistaPanelBorderA", D.vistaPanelBorderA)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBorderR", r); setDB("vistaPanelBorderG", g)
                    setDB("vistaPanelBorderB", b)
                    if a ~= nil then setDB("vistaPanelBorderA", a) end
                end,
                hasAlpha = true,
            }

            opts[#opts + 1] = Section(L["VISTA_MOUSEOVER_BAR_APPEARANCE"], { page = "buttons", card = "panelColours" })
            opts[#opts + 1] = Header(L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"])
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BACKGROUND_COLOUR"],
                desc = L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"],
                dbKey = "vistaBarBg",
                get = function()
                    return getDB("vistaBarBgR", D.vistaBarBgR), getDB("vistaBarBgG", D.vistaBarBgG),
                           getDB("vistaBarBgB", D.vistaBarBgB), getDB("vistaBarBgA", D.vistaBarBgA)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBgR", r); setDB("vistaBarBgG", g)
                    setDB("vistaBarBgB", b)
                    if a ~= nil then setDB("vistaBarBgA", a) end
                end,
                hasAlpha = true,
                parent = "vistaHandleAddonButtons",
            }
            opts[#opts + 1] = Toggle(L["VISTA_BAR_BORDER"], L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"], "vistaBarBorderShow", D.vistaBarBorderShow, { parent = "vistaHandleAddonButtons" })
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BORDER_COLOUR"],
                desc = L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"],
                dbKey = "vistaBarBorder",
                get = function()
                    return getDB("vistaBarBorderR", D.vistaBarBorderR), getDB("vistaBarBorderG", D.vistaBarBorderG),
                           getDB("vistaBarBorderB", D.vistaBarBorderB), getDB("vistaBarBorderA", D.vistaBarBorderA)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBorderR", r); setDB("vistaBarBorderG", g)
                    setDB("vistaBarBorderB", b)
                    if a ~= nil then setDB("vistaBarBorderA", a) end
                end,
                hasAlpha = true,
                parent = "vistaBarBorderShow",
            }

            opts[#opts + 1] = Section(L["VISTA_MANAGED_BUTTONS"], { page = "buttons" })

            local function getButtonNames()
                if addon.Vista and addon.Vista.GetDiscoveredButtonNames then
                    return addon.Vista.GetDiscoveredButtonNames()
                end
                return {}
            end

            local managedNames = getButtonNames()
            for _, btnName in ipairs(managedNames) do
                local localName = btnName
                local displayName = localName
                if addon.Vista and addon.Vista.GetButtonDisplayName then
                    displayName = addon.Vista.GetButtonDisplayName(localName) or localName
                end
                opts[#opts + 1] = {
                    type = "toggle",
                    name = (displayName ~= "" and displayName ~= localName) and displayName or localName,
                    desc = L["VISTA_BUTTON_COMPLETELY_IGNORED"],
                    dbKey = "vistaButtonManaged_" .. localName,
                    parent = "vistaHandleAddonButtons",
                    get = function() return getDB("vistaButtonManaged_" .. localName, true) end,
                    set = function(v)
                        setDB("vistaButtonManaged_" .. localName, v)
                    end,
                }
            end
            if #managedNames == 0 then
                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["VISTA_ADDON_BUTTONS_DETECTED"],
                    dbKey = "_vista_no_managed_placeholder",
                    get = function() return false end, set = function() end,
                    disabled = function() return true end,
                }
            end

            opts[#opts + 1] = Section(L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"], { page = "buttons" })

            local names = getButtonNames()
            for _, btnName in ipairs(names) do
                local localName = btnName
                local displayName = localName
                if addon.Vista and addon.Vista.GetButtonDisplayName then
                    displayName = addon.Vista.GetButtonDisplayName(localName) or localName
                end
                local label = (displayName ~= localName and displayName ~= "") and displayName or localName
                opts[#opts + 1] = {
                    type = "toggle",
                    name = label,
                    dbKey = "vistaBtn_" .. localName,
                    parent = "vistaButtonManaged_" .. localName,
                    get = function()
                        local wl = getDB("vistaButtonWhitelist", nil)
                        if not wl or type(wl) ~= "table" then return true end
                        return wl[localName] == true
                    end,
                    set = function(v)
                        local wl = getDB("vistaButtonWhitelist", nil)
                        if not wl or type(wl) ~= "table" then
                            local allNames = getButtonNames()
                            wl = {}
                            for _, n in ipairs(allNames) do wl[n] = true end
                        end
                        wl[localName] = v or nil
                        local hasAny = false
                        for _, val in pairs(wl) do
                            if val then hasAny = true; break end
                        end
                        if not hasAny then wl = nil end
                        setDB("vistaButtonWhitelist", wl)
                    end,
                }
            end

            if #names == 0 then
                opts[#opts + 1] = {
                    type = "toggle",
                    name = L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"],
                    dbKey = "_vista_no_buttons_placeholder",
                    get = function() return false end,
                    set = function() end,
                    disabled = function() return true end,
                }
            end

            return opts
        end,
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
