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

local categories = {
    {
        key = "VistaMinimap",
        name = L["VISTA_DESC"],
        desc = L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"],
        moduleKey = "vista",
        options = {
            Section(L["SIZE_SHAPE"]),
            { type = "slider", name = L["VISTA_SIZE"],
              desc = L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"],
              dbKey = "vistaMapSize", min = 100, max = 400,
              get = function() return math.max(100, math.min(400, tonumber(getDB("vistaMapSize", 200)) or 200)) end,
              set = function(v) setDB("vistaMapSize", math.max(100, math.min(400, v))) end },
            Toggle(L["VISTA_CIRCULAR_SHAPE"], L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"], "vistaCircular", false),
            Section(L["AXIS_POSITION"]),
            Toggle(L["LOCK_MINIMAP"], L["VISTA_PREVENT_DRAGGING_MINIMAP"], "vistaLock", true),
            Button(L["VISTA_RESET_MINIMAP_POSITION"], L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"], function()
                if addon.Vista and addon.Vista.ResetMinimapPosition then
                    addon.Vista.ResetMinimapPosition()
                end
            end),
            Section(L["VISTA_AUTO_ZOOM"]),
            { type = "slider", name = L["VISTA_AUTO_ZOOM_DELAY"],
              desc = L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"],
              dbKey = "vistaAutoZoom", min = 0, max = 30,
              get = function() return math.max(0, math.min(30, tonumber(getDB("vistaAutoZoom", 5)) or 5)) end,
              set = function(v) setDB("vistaAutoZoom", math.max(0, math.min(30, v))) end },
            Section(L["VISTA_TEXT_ELEMENTS"]),
            Toggle(L["VISTA_ZONE_TEXT"], L["VISTA_ZONE_NAME_BELOW_MINIMAP"], "vistaShowZoneText", true),
            { type = "dropdown", name = L["VISTA_ZONE_TEXT_DISPLAY_MODE"],
              desc = L["VISTA_WHAT_ZONE_SUBZONE"],
              dbKey = "vistaZoneDisplayMode",
              options = function() return {
                  { L["VISTA_SHOW_ZONE"], "zone" },
                  { L["VISTA_SHOW_SUBZONE"], "subzone" },
                  { L["VISTA_SHOW_ZONE_AND_SUBZONE"], "both" },
              } end,
              get = function() return getDB("vistaZoneDisplayMode", "zone") end,
              set = function(v) setDB("vistaZoneDisplayMode", v) end,
              disabled = function() return not getDB("vistaShowZoneText", true) end },
            Toggle(L["VISTA_COORDINATES"], L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"], "vistaShowCoordText", true),
            Toggle(L["VISTA_TIME"], L["VISTA_CURRENT_GAME_BELOW_MINIMAP"], "vistaShowTimeText", true),
            Toggle(L["VISTA_FPS_LATENCY"], L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"], "vistaShowPerfText", false),
            Toggle(L["VISTA_LOCAL_TIME"], L["LOCAL_SYSTEM"], "vistaTimeUseLocal", true, { tooltip = L["VISTA_LOCAL_TIME_TIP"], disabled = function() return not getDB("vistaShowTimeText", true) end }),
            Toggle(L["VISTA_HOUR_CLOCK"], L["VISTA_DISPLAY_HOUR_FORMAT_24"], "vistaTime24Hour", false, { disabled = function() return not getDB("vistaShowTimeText", true) end }),
            Section(L["VISTA_MINIMAP_BUTTONS"]),
            Header(L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"]),
            Toggle(L["VISTA_TRACKING_BUTTON"], L["VISTA_MINIMAP_TRACKING_BUTTON"], "vistaShowTracking", true, { refreshIds = { "vistaMouseoverTracking" } }),
            Toggle(L["VISTA_TRACKING_BUTTON_MOUSEOVER"], L["HOVER"], "vistaMouseoverTracking", true, { tooltip = L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"], disabled = function() return not getDB("vistaShowTracking", true) end }),
            Toggle(L["VISTA_CALENDAR_BUTTON"], L["VISTA_MINIMAP_CALENDAR_BUTTON"], "vistaShowCalendar", true, { refreshIds = { "vistaMouseoverCalendar" } }),
            Toggle(L["VISTA_CALENDAR_BUTTON_MOUSEOVER"], L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"], "vistaMouseoverCalendar", true, { disabled = function() return not getDB("vistaShowCalendar", true) end }),
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

            return {
            Section(L["VISTA_BORDER"]),
            Toggle(L["FOCUS_BORDER"], L["VISTA_BORDER_TIP"], "vistaBorderShow", true),
            { type = "color", name = L["VISTA_BORDER_COLOUR"],
              desc = L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"],
              dbKey = "vistaBorderColor",
              get = function()
                  return getDB("vistaBorderColorR", 1), getDB("vistaBorderColorG", 1),
                         getDB("vistaBorderColorB", 1), getDB("vistaBorderColorA", 0.15)
              end,
              set = function(r, g, b, a)
                  setDB("vistaBorderColorR", r); setDB("vistaBorderColorG", g)
                  setDB("vistaBorderColorB", b)
                  if a ~= nil then setDB("vistaBorderColorA", a) end
              end,
              hasAlpha = true },
            { type = "slider", name = L["VISTA_BORDER_THICKNESS"],
              desc = L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"],
              dbKey = "vistaBorderWidth", min = 1, max = 8,
              get = function() return math.max(1, math.min(8, tonumber(getDB("vistaBorderWidth", 1)) or 1)) end,
              set = function(v)
                  addon.SetDB("vistaBorderWidth", math.max(1, math.min(8, v)))
                  if addon.Vista then
                      if addon._vistaBorderDebounce then addon._vistaBorderDebounce:Cancel() end
                      addon._vistaBorderDebounce = C_Timer.NewTimer(0.15, function()
                          addon._vistaBorderDebounce = nil
                          if addon.Vista.ApplyOptions then addon.Vista.ApplyOptions() end
                      end)
                  end
              end },
            Section(L["VISTA_TEXT_POSITIONS"]),
            Header(L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"]),
            { type = "dropdown", name = L["VISTA_LOCATION_POSITION"],
              desc = L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"],
              dbKey = "vistaZoneVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
              get = function() return getDB("vistaZoneVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaZoneVerticalPos", v)
                  setDB("vistaEX_zone", nil); setDB("vistaEY_zone", nil)
              end },
            Toggle(L["VISTA_LOCK_ZONE_TEXT_POSITION"], L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"], "vistaLocked_zone", true),
            { type = "dropdown", name = L["VISTA_COORDINATES_POSITION"],
              desc = L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"],
              dbKey = "vistaCoordVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
              get = function() return getDB("vistaCoordVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaCoordVerticalPos", v)
                  setDB("vistaEX_coord", nil); setDB("vistaEY_coord", nil)
              end },
            Toggle(L["VISTA_LOCK_COORDINATES_POSITION"], L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"], "vistaLocked_coord", true),
            { type = "dropdown", name = L["VISTA_CLOCK_POSITION"],
              desc = L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"],
              dbKey = "vistaTimeVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
              get = function() return getDB("vistaTimeVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaTimeVerticalPos", v)
                  setDB("vistaEX_time", nil); setDB("vistaEY_time", nil)
              end },
            Toggle(L["VISTA_LOCK_POSITION"], L["VISTA_TEXT_CANNOT_DRAGGED"], "vistaLocked_time", true),
            { type = "dropdown", name = L["VISTA_PERFORMANCE_TEXT_POSITION"],
              desc = L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"],
              dbKey = "vistaPerfVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
              get = function() return getDB("vistaPerfVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaPerfVerticalPos", v)
                  setDB("vistaEX_perf", nil); setDB("vistaEY_perf", nil)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            Toggle(L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"], L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"], "vistaLocked_perf", true, { disabled = function() return not getDB("vistaShowPerfText", false) end }),
            { type = "dropdown", name = L["VISTA_DIFFICULTY_TEXT_POSITION"],
              desc = L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"],
              dbKey = "vistaDiffVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"], "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"], "bottom" } } end,
              get = function() return getDB("vistaDiffVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaDiffVerticalPos", v)
                  setDB("vistaEX_diff", nil); setDB("vistaEY_diff", nil)
              end },
            Toggle(L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"], L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"], "vistaLocked_diff", false),
            Section(L["VISTA_BUTTON_POSITIONS"]),
            Header(L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"]),
            Button(L["VISTA_RESET_OVERLAY_POSITIONS"], L["VISTA_RESET_OVERLAY_POSITIONS_DESC"], function()
                if addon.Vista and addon.Vista.ResetOverlayPositionsToDefaults then
                    addon.Vista.ResetOverlayPositionsToDefaults()
                end
            end),
            Toggle(L["VISTA_LOCK_TRACKING_BUTTON"], L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"], "vistaLocked_proxy_tracking", true),
            Toggle(L["VISTA_LOCK_CALENDAR_BUTTON"], L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"], "vistaLocked_proxy_calendar", true),
            Toggle(L["VISTA_LOCK_QUEUE_BUTTON"], L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"], "vistaLocked_proxy_queue", true),
            Toggle(L["VISTA_LOCK_MAIL_INDICATOR"], L["VISTA_PREVENT_DRAGGING_MAIL_ICON"], "vistaLocked_proxy_mail", true),
            Toggle(L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"], L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"], "vistaLocked_proxy_craftingOrder", true),
            Toggle(L["VISTA_DISABLE_QUEUE_HANDLING"], L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"], "vistaQueueHandlingDisabled", false),
            Section(L["VISTA_BUTTON_SIZES"]),
            Header(L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"]),
            { type = "slider", name = L["VISTA_TRACKING_BUTTON_SIZE"],
              desc = L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"],
              dbKey = "vistaTrackingBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaTrackingBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaTrackingBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_CALENDAR_BUTTON_SIZE"],
              desc = L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"],
              dbKey = "vistaCalendarBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCalendarBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaCalendarBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_QUEUE_BUTTON_SIZE"],
              desc = L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"],
              dbKey = "vistaQueueBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaQueueBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaQueueBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_MAIL_INDICATOR_SIZE"],
              desc = L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"],
              dbKey = "vistaMailIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaMailIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaMailIconSize", math.max(14, math.min(40, v))) end },
            Toggle(L["MAIL_ICON_PULSE"], L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"], "vistaMailBlink", true),
            { type = "slider", name = L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"],
              desc = L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"],
              dbKey = "vistaCraftingOrderIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCraftingOrderIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaCraftingOrderIconSize", math.max(14, math.min(40, v))) end },
            Toggle(L["VISTA_CRAFTING_ORDER_ICON_PULSE"], L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"], "vistaCraftingOrderBlink", true),
            { type = "slider", name = L["VISTA_ADDON_BUTTON_SIZE"],
              desc = L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"],
              dbKey = "vistaAddonBtnSize", min = 16, max = 48,
              get = function() return math.max(16, math.min(48, tonumber(getDB("vistaAddonBtnSize", 26)) or 26)) end,
              set = function(v)
                  setDB("vistaAddonBtnSize", math.max(16, math.min(48, v)))
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
            Section(L["VISTA_ZONE_TEXT_HEADER"]),
            { type = "dropdown", name = L["VISTA_ZONE_FONT"],
              desc = L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"],
              dbKey = "vistaZoneFontPath", searchable = true,
              options = function() return fontOpts("vistaZoneFontPath") end,
              get = function() return getFont("vistaZoneFontPath") end,
              set = function(v) setDB("vistaZoneFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_ZONE_FONT_SIZE"],
              dbKey = "vistaZoneFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaZoneFontSize", 12)) or 12)) end,
              set = function(v) setDB("vistaZoneFontSize", math.max(7, math.min(24, v))) end },
            { type = "color", name = L["VISTA_ZONE_TEXT_COLOUR"],
              desc = L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"],
              dbKey = "vistaZoneColor",
              get = function()
                  return getDB("vistaZoneColorR", 1), getDB("vistaZoneColorG", 1), getDB("vistaZoneColorB", 1)
              end,
              set = function(r, g, b)
                  setDB("vistaZoneColorR", r); setDB("vistaZoneColorG", g); setDB("vistaZoneColorB", b)
              end },
            Section(L["VISTA_COORDINATES_TEXT"]),
            { type = "dropdown", name = L["VISTA_COORDINATES_FONT"],
              desc = L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"],
              dbKey = "vistaCoordFontPath", searchable = true,
              options = function() return fontOpts("vistaCoordFontPath") end,
              get = function() return getFont("vistaCoordFontPath") end,
              set = function(v) setDB("vistaCoordFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_COORDINATES_FONT_SIZE"],
              dbKey = "vistaCoordFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaCoordFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaCoordFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_COORDINATES_TEXT_COLOUR"],
              desc = L["VISTA_COLOUR_OF_COORDINATES_TEXT"],
              dbKey = "vistaCoordColor",
              get = function()
                  return getDB("vistaCoordColorR", 0.55), getDB("vistaCoordColorG", 0.65), getDB("vistaCoordColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaCoordColorR", r); setDB("vistaCoordColorG", g); setDB("vistaCoordColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_COORDINATE_PRECISION"],
              desc = L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"],
              dbKey = "vistaCoordPrecision",
              options = function() return {
                  { L["VISTA_COORDS_DECIMALS_OFF"],      0 },
                  { L["VISTA_DECIMAL_E_G"],    1 },
                  { L["VISTA_DECIMALS_E_G"], 2 },
              } end,
              get = function() return tonumber(getDB("vistaCoordPrecision", 1)) or 1 end,
              set = function(v) setDB("vistaCoordPrecision", tonumber(v) or 1) end },
            Section(L["VISTA_TEXT"]),
            { type = "dropdown", name = L["VISTA_FONT"],
              desc = L["VISTA_FONT_TEXT_BELOW_MINIMAP"],
              dbKey = "vistaTimeFontPath", searchable = true,
              options = function() return fontOpts("vistaTimeFontPath") end,
              get = function() return getFont("vistaTimeFontPath") end,
              set = function(v) setDB("vistaTimeFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_FONT_SIZE"],
              dbKey = "vistaTimeFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaTimeFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaTimeFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_TEXT_COLOUR"],
              desc = L["VISTA_COLOUR_OF_TEXT"],
              dbKey = "vistaTimeColor",
              get = function()
                  return getDB("vistaTimeColorR", 0.55), getDB("vistaTimeColorG", 0.65), getDB("vistaTimeColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaTimeColorR", r); setDB("vistaTimeColorG", g); setDB("vistaTimeColorB", b)
              end },
            Section(L["VISTA_PERFORMANCE_TEXT"]),
            { type = "dropdown", name = L["VISTA_PERFORMANCE_FONT"],
              desc = L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"],
              dbKey = "vistaPerfFontPath", searchable = true,
              options = function() return fontOpts("vistaPerfFontPath") end,
              get = function() return getFont("vistaPerfFontPath") end,
              set = function(v) setDB("vistaPerfFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "slider", name = L["VISTA_PERFORMANCE_FONT_SIZE"],
              dbKey = "vistaPerfFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaPerfFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaPerfFontSize", math.max(7, math.min(20, v))) end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "color", name = L["VISTA_PERFORMANCE_TEXT_COLOUR"],
              desc = L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"],
              dbKey = "vistaPerfColor",
              get = function()
                  return getDB("vistaPerfColorR", 0.55), getDB("vistaPerfColorG", 0.65), getDB("vistaPerfColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaPerfColorR", r); setDB("vistaPerfColorG", g); setDB("vistaPerfColorB", b)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            Section(L["VISTA_DIFFICULTY_TEXT"]),
            { type = "color", name = L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"],
              desc = L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"],
              dbKey = "vistaDiffColor",
              get = function()
                  return getDB("vistaDiffColorR", 0.55), getDB("vistaDiffColorG", 0.65), getDB("vistaDiffColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaDiffColorR", r); setDB("vistaDiffColorG", g); setDB("vistaDiffColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_DIFFICULTY_FONT"],
              desc = L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"],
              dbKey = "vistaDiffFontPath", searchable = true,
              options = function() return fontOpts("vistaDiffFontPath") end,
              get = function() return getFont("vistaDiffFontPath") end,
              set = function(v) setDB("vistaDiffFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_DIFFICULTY_FONT_SIZE"],
              dbKey = "vistaDiffFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaDiffFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaDiffFontSize", math.max(7, math.min(24, v))) end },
            Section(L["VISTA_PER_DIFFICULTY_COLOURS"], { defaultCollapsed = true }),
            { type = "color", name = L["VISTA_MYTHIC_COLOUR"],
              desc = L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"],
              dbKey = "vistaDiffColor_mythic",
              get = function() return getDB("vistaDiffColor_mythic_R", 0.64), getDB("vistaDiffColor_mythic_G", 0.21), getDB("vistaDiffColor_mythic_B", 0.93) end,
              set = function(r, g, b) setDB("vistaDiffColor_mythic_R", r); setDB("vistaDiffColor_mythic_G", g); setDB("vistaDiffColor_mythic_B", b) end },
            { type = "color", name = L["VISTA_HEROIC_COLOUR"],
              desc = L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"],
              dbKey = "vistaDiffColor_heroic",
              get = function() return getDB("vistaDiffColor_heroic_R", 1.00), getDB("vistaDiffColor_heroic_G", 0.12), getDB("vistaDiffColor_heroic_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_heroic_R", r); setDB("vistaDiffColor_heroic_G", g); setDB("vistaDiffColor_heroic_B", b) end },
            { type = "color", name = L["VISTA_NORMAL_COLOUR"],
              desc = L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"],
              dbKey = "vistaDiffColor_normal",
              get = function() return getDB("vistaDiffColor_normal_R", 0.12), getDB("vistaDiffColor_normal_G", 0.83), getDB("vistaDiffColor_normal_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_normal_R", r); setDB("vistaDiffColor_normal_G", g); setDB("vistaDiffColor_normal_B", b) end },
            { type = "color", name = L["VISTA_LFR_COLOUR"],
              desc = L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"],
              dbKey = "vistaDiffColor_lfr",
              get = function() return getDB("vistaDiffColor_looking_for_raid_R", 0.00), getDB("vistaDiffColor_looking_for_raid_G", 0.70), getDB("vistaDiffColor_looking_for_raid_B", 1.00) end,
              set = function(r, g, b) setDB("vistaDiffColor_looking_for_raid_R", r); setDB("vistaDiffColor_looking_for_raid_G", g); setDB("vistaDiffColor_looking_for_raid_B", b) end },
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
                Section(L["VISTA_BUTTON_MANAGEMENT"]),
                { type = "toggle", name = L["MANAGE_ADDON_BUTTONS"],
                  desc = L["COLLECT_GROUP_ADDON_MINIMAP_BUTTONS"], tooltip = L["GROUPS_SELECTED_LAYOUT_MODE_BELOW"],
                  dbKey = "vistaHandleAddonButtons",
                  get = function() return getDB("vistaHandleAddonButtons", true) end,
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
                  get = function() return getDB("vistaCollectHorizonMinimapButton", true) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      if C_Timer and C_Timer.After then
                          C_Timer.After(0, function() setDB("vistaCollectHorizonMinimapButton", v) end)
                      else
                          setDB("vistaCollectHorizonMinimapButton", v)
                      end
                  end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end },
                Toggle(L["VISTA_SORT_BUTTONS_ALPHA"], L["VISTA_SORT_BUTTONS_ALPHA_DESC"], "vistaButtonSortAlpha", false, { disabled = function() return not getDB("vistaHandleAddonButtons", true) end }),
                { type = "dropdown", name = L["VISTA_BUTTON_MODE"],
                  desc = L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"],
                  dbKey = "vistaButtonMode",
                  options = BUTTON_MODE_OPTIONS,
                  refreshIds = { "vistaDrawerIcon", "vistaDrawerButtonLocked", "vistaMouseoverLocked", "vistaMouseoverBarVisible", "vistaRightClickLocked" },
                  get = function() return getDB("vistaButtonMode", "rightclick") end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      setDB("vistaButtonMode", v)
                      if addon.OptionsPanel_Refresh and C_Timer and C_Timer.After then
                          C_Timer.After(0, addon.OptionsPanel_Refresh)
                      elseif addon.OptionsPanel_Refresh then
                          addon.OptionsPanel_Refresh()
                      end
                  end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end },
                { type = "button",
                  name = L["VISTA_CHOOSE_DRAWER_ICON"],
                  dbKey = "vistaDrawerIcon",
                  visibleWhen = function()
                      return getDB("vistaHandleAddonButtons", true) and getDB("vistaButtonMode", "mouseover") == "drawer"
                  end,
                  tooltip = L["VISTA_DRAWER_BUTTON_ICON_DESC"],
                  onClick = function()
                      if addon.OpenVistaDrawerIconPicker then
                          addon.OpenVistaDrawerIconPicker()
                      end
                  end },
                { type = "toggle", name = L["LOCK_DRAWER_BUTTON"],
                  desc = L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"],
                  dbKey = "vistaDrawerButtonLocked",
                  get = function() return getDB("vistaDrawerButtonLocked", false) end,
                  set = function(v)
                      if not getDB("vistaHandleAddonButtons", true) then return end
                      if getDB("vistaButtonMode", "mouseover") ~= "drawer" then return end
                      setDB("vistaDrawerButtonLocked", v)
                  end,
                  disabled = function()
                      return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "drawer"
                  end },
                Toggle(L["LOCK_MOUSEOVER_BAR"], L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"], "vistaMouseoverLocked", true, { disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover" end }),
                Toggle(L["VISTA_ALWAYS_BAR"], L["KEEP_BAR_VISIBLE_REPOSITIONING"], "vistaMouseoverBarVisible", false, { tooltip = L["VISTA_DISABLE_DONE"], disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover" end }),
                Toggle(L["LOCK_RIGHT_CLICK_PANEL"], L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"], "vistaRightClickLocked", true, { disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "rightclick" end }),

                Section(L["VISTA_CLOSE_FADE_TIMING"], { defaultCollapsed = true }),
                { type = "slider", name = L["MOUSEOVER_CLOSE_DELAY"],
                  desc = L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"],
                  dbKey = "vistaMouseoverCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaMouseoverCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaMouseoverCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["RIGHT_CLICK_CLOSE_DELAY"],
                  desc = L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"],
                  dbKey = "vistaRightClickCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaRightClickCloseDelay", 2.5)) or 2.5)) end,
                  set = function(v) setDB("vistaRightClickCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["VISTA_DRAWER_CLOSE_DELAY"],
                  desc = L["AUTO_CLOSE_DELAY_DISABLE"],
                  tooltip = L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"],
                  dbKey = "vistaDrawerCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaDrawerCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaDrawerCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },

                Section(L["DASH_LAYOUT"]),
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
                dbKey = "vistaBtnLayoutCols", min = 1, max = 20, step = 1,
                get = function() return math.max(1, math.min(20, tonumber(getDB("vistaBtnLayoutCols", 5)) or 5)) end,
                set = function(v)
                    setDB("vistaBtnLayoutCols", math.max(1, math.min(20, v)))
                    if addon._vistaBtnColsDebounce then addon._vistaBtnColsDebounce:Cancel() end
                    if C_Timer and C_Timer.NewTimer and addon.Vista and addon.Vista.ApplyOptions then
                        addon._vistaBtnColsDebounce = C_Timer.NewTimer(0.15, function()
                            addon._vistaBtnColsDebounce = nil
                            addon.Vista.ApplyOptions()
                        end)
                    end
                end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = {
                type = "dropdown", name = L["VISTA_EXPAND_DIRECTION"],
                desc = L["EXPAND_DIRECTION_ANCHOR"],
                tooltip = L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"],
                dbKey = "vistaBtnLayoutDir", options = DIR_OPTIONS,
                get = function() return getDB("vistaBtnLayoutDir", "right") end,
                set = function(v) setDB("vistaBtnLayoutDir", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }

            opts[#opts + 1] = Section(L["VISTA_PANEL_APPEARANCE"])
            opts[#opts + 1] = Header(L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"])
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BG_COLOUR_LABEL"],
                desc = L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"],
                dbKey = "vistaPanelBg",
                get = function()
                    return getDB("vistaPanelBgR", 0.08), getDB("vistaPanelBgG", 0.08),
                           getDB("vistaPanelBgB", 0.12), getDB("vistaPanelBgA", 0.95)
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
                    return getDB("vistaPanelBorderR", 0.3), getDB("vistaPanelBorderG", 0.4),
                           getDB("vistaPanelBorderB", 0.6), getDB("vistaPanelBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaPanelBorderR", r); setDB("vistaPanelBorderG", g)
                    setDB("vistaPanelBorderB", b)
                    if a ~= nil then setDB("vistaPanelBorderA", a) end
                end,
                hasAlpha = true,
            }

            opts[#opts + 1] = Section(L["VISTA_MOUSEOVER_BAR_APPEARANCE"])
            opts[#opts + 1] = Header(L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"])
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BACKGROUND_COLOUR"],
                desc = L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"],
                dbKey = "vistaBarBg",
                get = function()
                    return getDB("vistaBarBgR", 0.08), getDB("vistaBarBgG", 0.08),
                           getDB("vistaBarBgB", 0.12), getDB("vistaBarBgA", 0)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBgR", r); setDB("vistaBarBgG", g)
                    setDB("vistaBarBgB", b)
                    if a ~= nil then setDB("vistaBarBgA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }
            opts[#opts + 1] = Toggle(L["VISTA_BAR_BORDER"], L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"], "vistaBarBorderShow", false, { disabled = function() return not getDB("vistaHandleAddonButtons", true) end })
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BORDER_COLOUR"],
                desc = L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"],
                dbKey = "vistaBarBorder",
                get = function()
                    return getDB("vistaBarBorderR", 0.3), getDB("vistaBarBorderG", 0.4),
                           getDB("vistaBarBorderB", 0.6), getDB("vistaBarBorderA", 0.7)
                end,
                set = function(r, g, b, a)
                    setDB("vistaBarBorderR", r); setDB("vistaBarBorderG", g)
                    setDB("vistaBarBorderB", b)
                    if a ~= nil then setDB("vistaBarBorderA", a) end
                end,
                hasAlpha = true,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) or not getDB("vistaBarBorderShow", false) end,
            }

            opts[#opts + 1] = Section(L["VISTA_MANAGED_BUTTONS"])

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
                    disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
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

            opts[#opts + 1] = Section(L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"])

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
                    disabled = function()
                        if not getDB("vistaHandleAddonButtons", true) then return true end
                        return not getDB("vistaButtonManaged_" .. localName, true)
                    end,
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
