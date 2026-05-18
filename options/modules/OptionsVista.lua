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
        name = L["VISTA_DESC"] or "Minimap",
        desc = L["CONFIGURE_MINIMAP_S_SHAPE_SIZE_POSITION"] or "Configure the minimap's shape, size, position, and text overlays.",
        moduleKey = "vista",
        options = {
            Section(L["SIZE_SHAPE"] or "Size & shape"),
            { type = "slider", name = L["VISTA_SIZE"] or "Minimap size",
              desc = L["VISTA_WIDTH_HEIGHT_OF_MINIMAP_PIXELS"] or "Width and height of the minimap in pixels (100–400).",
              dbKey = "vistaMapSize", min = 100, max = 400,
              get = function() return math.max(100, math.min(400, tonumber(getDB("vistaMapSize", 200)) or 200)) end,
              set = function(v) setDB("vistaMapSize", math.max(100, math.min(400, v))) end },
            Toggle(L["VISTA_CIRCULAR_SHAPE"] or "Circular shape", L["VISTA_A_CIRCULAR_MINIMAP_INSTEAD_OF_SQUARE"] or "Use a circular minimap instead of square.", "vistaCircular", false),
            Section(L["AXIS_POSITION"] or "Position"),
            Toggle(L["LOCK_MINIMAP"] or "Lock minimap", L["VISTA_PREVENT_DRAGGING_MINIMAP"] or "Prevent dragging the minimap.", "vistaLock", true),
            Button(L["VISTA_RESET_MINIMAP_POSITION"] or "Reset minimap position", L["VISTA_RESET_MINIMAP_DEFAULT_POSITION_TOP_RIGHT"] or "Reset minimap to its default position (top-right).", function()
                if addon.Vista and addon.Vista.ResetMinimapPosition then
                    addon.Vista.ResetMinimapPosition()
                end
            end),
            Section(L["VISTA_AUTO_ZOOM"] or "Auto Zoom"),
            { type = "slider", name = L["VISTA_AUTO_ZOOM_DELAY"] or "Auto zoom-out delay",
              desc = L["VISTA_SECONDS_AFTER_ZOOMING_BEFORE_AUTO_ZOOM"] or "Seconds after zooming before auto zoom-out fires. Set to 0 to disable.",
              dbKey = "vistaAutoZoom", min = 0, max = 30,
              get = function() return math.max(0, math.min(30, tonumber(getDB("vistaAutoZoom", 5)) or 5)) end,
              set = function(v) setDB("vistaAutoZoom", math.max(0, math.min(30, v))) end },
            Section(L["VISTA_TEXT_ELEMENTS"] or "Text Elements"),
            Toggle(L["VISTA_ZONE_TEXT"] or "Show zone text", L["VISTA_ZONE_NAME_BELOW_MINIMAP"] or "Show the zone name below the minimap.", "vistaShowZoneText", true),
            { type = "dropdown", name = L["VISTA_ZONE_TEXT_DISPLAY_MODE"] or "Zone text display mode",
              desc = L["VISTA_WHAT_ZONE_SUBZONE"] or "What to show: zone only, subzone only, or both.",
              dbKey = "vistaZoneDisplayMode",
              options = function() return {
                  { L["VISTA_SHOW_ZONE"] or "Zone only", "zone" },
                  { L["VISTA_SHOW_SUBZONE"] or "Subzone only", "subzone" },
                  { L["VISTA_SHOW_ZONE_AND_SUBZONE"] or "Both", "both" },
              } end,
              get = function() return getDB("vistaZoneDisplayMode", "zone") end,
              set = function(v) setDB("vistaZoneDisplayMode", v) end,
              disabled = function() return not getDB("vistaShowZoneText", true) end },
            Toggle(L["VISTA_COORDINATES"] or "Show coordinates", L["VISTA_PLAYER_COORDINATES_BELOW_MINIMAP"] or "Show player coordinates below the minimap.", "vistaShowCoordText", true),
            Toggle(L["VISTA_TIME"] or "Show time", L["VISTA_CURRENT_GAME_BELOW_MINIMAP"] or "Show current game time below the minimap.", "vistaShowTimeText", true),
            Toggle(L["VISTA_FPS_LATENCY"] or "Show FPS and latency", L["VISTA_FPS_LATENCY_MS_BELOW_MINIMAP"] or "Show FPS and latency (ms) below the minimap.", "vistaShowPerfText", false),
            Toggle(L["VISTA_LOCAL_TIME"] or "Use local time", L["LOCAL_SYSTEM"] or "Show local system time.", "vistaTimeUseLocal", true, { tooltip = L["VISTA_LOCAL_TIME_TIP"] or "When on, shows your local system time. When off, shows server time.", disabled = function() return not getDB("vistaShowTimeText", true) end }),
            Toggle(L["VISTA_HOUR_CLOCK"] or "24-hour clock", L["VISTA_DISPLAY_HOUR_FORMAT_24"] or "Display time in 24-hour format (e.g. 14:30 instead of 2:30 PM).", "vistaTime24Hour", false, { disabled = function() return not getDB("vistaShowTimeText", true) end }),
            Section(L["VISTA_MINIMAP_BUTTONS"] or "Minimap Buttons"),
            Header(L["VISTA_QUEUE_STATUS_MAIL_INDICATOR_ALWAYS_SHOWN"] or "Queue status and mail indicator are always shown when relevant."),
            Toggle(L["VISTA_TRACKING_BUTTON"] or "Show tracking button", L["VISTA_MINIMAP_TRACKING_BUTTON"] or "Show the minimap tracking button.", "vistaShowTracking", true, { refreshIds = { "vistaMouseoverTracking" } }),
            Toggle(L["VISTA_TRACKING_BUTTON_MOUSEOVER"] or "Tracking button on mouseover only", L["HOVER"] or "Show only on hover.", "vistaMouseoverTracking", true, { tooltip = L["VISTA_HIDE_TRACKING_BUTTON_UNTIL_YOU_HOVER"] or "Hide tracking button until you hover over the minimap.", disabled = function() return not getDB("vistaShowTracking", true) end }),
            Toggle(L["VISTA_CALENDAR_BUTTON"] or "Show calendar button", L["VISTA_MINIMAP_CALENDAR_BUTTON"] or "Show the minimap calendar button.", "vistaShowCalendar", true, { refreshIds = { "vistaMouseoverCalendar" } }),
            Toggle(L["VISTA_CALENDAR_BUTTON_MOUSEOVER"] or "Calendar button on mouseover only", L["VISTA_HIDE_CALENDAR_BUTTON_UNTIL_YOU_HOVER"] or "Hide calendar button until you hover over the minimap.", "vistaMouseoverCalendar", true, { disabled = function() return not getDB("vistaShowCalendar", true) end }),
        },
    },
    {
        key = "VistaAppearance",
        name = L["DASH_APPEARANCE"] or "Appearance",
        desc = L["VISTA_CUSTOMISE_BORDERS_COLOURS_POSITIONING"] or "Customize borders, colors, and the positioning of specific minimap elements.",
        moduleKey = "vista",
        options = function()
            local GLOBAL_SENTINEL = "__global__"
            local GLOBAL_LABEL = L["FOCUS_GLOBAL_FONT"] or "Use global font"

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
            Section(L["VISTA_BORDER"] or "Border"),
            Toggle(L["FOCUS_BORDER"] or "Show border", L["VISTA_BORDER_TIP"] or "Show a border around the minimap.", "vistaBorderShow", true),
            { type = "color", name = L["VISTA_BORDER_COLOUR"] or "Border color",
              desc = L["VISTA_COLOUR_OPACITY_OF_MINIMAP_BORDER"] or "Color (and opacity) of the minimap border.",
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
            { type = "slider", name = L["VISTA_BORDER_THICKNESS"] or "Border thickness",
              desc = L["VISTA_THICKNESS_OF_MINIMAP_BORDER_PIXELS"] or "Thickness of the minimap border in pixels (1–8).",
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
            Section(L["VISTA_TEXT_POSITIONS"] or "Text Positions"),
            Header(L["VISTA_DRAG_TEXT_ELEMENTS_REPOSITION_LOCK_PREVEN"] or "Drag text elements to reposition them. Lock to prevent accidental movement."),
            { type = "dropdown", name = L["VISTA_LOCATION_POSITION"] or "Location position",
              desc = L["VISTA_PLACE_ZONE_NAME_ABOVE_BELOW_MINIMAP"] or "Place the zone name above or below the minimap.",
              dbKey = "vistaZoneVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaZoneVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaZoneVerticalPos", v)
                  setDB("vistaEX_zone", nil); setDB("vistaEY_zone", nil)
              end },
            Toggle(L["VISTA_LOCK_ZONE_TEXT_POSITION"] or "Lock zone text position", L["VISTA_ZONE_TEXT_CANNOT_DRAGGED"] or "When on, the zone text cannot be dragged.", "vistaLocked_zone", true),
            { type = "dropdown", name = L["VISTA_COORDINATES_POSITION"] or "Coordinates position",
              desc = L["VISTA_PLACE_COORDINATES_ABOVE_BELOW_MINIMAP"] or "Place the coordinates above or below the minimap.",
              dbKey = "vistaCoordVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaCoordVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaCoordVerticalPos", v)
                  setDB("vistaEX_coord", nil); setDB("vistaEY_coord", nil)
              end },
            Toggle(L["VISTA_LOCK_COORDINATES_POSITION"] or "Lock coordinates position", L["VISTA_COORDINATES_TEXT_CANNOT_DRAGGED"] or "When on, the coordinates text cannot be dragged.", "vistaLocked_coord", true),
            { type = "dropdown", name = L["VISTA_CLOCK_POSITION"] or "Clock position",
              desc = L["VISTA_PLACE_CLOCK_ABOVE_BELOW_MINIMAP"] or "Place the clock above or below the minimap.",
              dbKey = "vistaTimeVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaTimeVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaTimeVerticalPos", v)
                  setDB("vistaEX_time", nil); setDB("vistaEY_time", nil)
              end },
            Toggle(L["VISTA_LOCK_POSITION"] or "Lock time position", L["VISTA_TEXT_CANNOT_DRAGGED"] or "When on, the time text cannot be dragged.", "vistaLocked_time", true),
            { type = "dropdown", name = L["VISTA_PERFORMANCE_TEXT_POSITION"] or "Performance text position",
              desc = L["VISTA_PLACE_FPS_LATENCY_TEXT_ABOVE_BELOW"] or "Place the FPS/latency text above or below the minimap.",
              dbKey = "vistaPerfVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaPerfVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaPerfVerticalPos", v)
                  setDB("vistaEX_perf", nil); setDB("vistaEY_perf", nil)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            Toggle(L["VISTA_LOCK_PERFORMANCE_TEXT_POSITION"] or "Lock performance text position", L["VISTA_FPS_LATENCY_TEXT_CANNOT_DRAGGED"] or "When on, the FPS/latency text cannot be dragged.", "vistaLocked_perf", true, { disabled = function() return not getDB("vistaShowPerfText", false) end }),
            { type = "dropdown", name = L["VISTA_DIFFICULTY_TEXT_POSITION"] or "Difficulty text position",
              desc = L["VISTA_PLACE_DIFFICULTY_TEXT_ABOVE_BELOW"] or "Place the instance difficulty text above or below the minimap.",
              dbKey = "vistaDiffVerticalPos",
              options = function() return { { L["FOCUS_MYTHICPLUS_POSITION_TOP"] or "Top", "top" }, { L["FOCUS_MYTHICPLUS_POSITION_BOTTOM"] or "Bottom", "bottom" } } end,
              get = function() return getDB("vistaDiffVerticalPos", "bottom") or "bottom" end,
              set = function(v)
                  setDB("vistaDiffVerticalPos", v)
                  setDB("vistaEX_diff", nil); setDB("vistaEY_diff", nil)
              end },
            Toggle(L["VISTA_LOCK_DIFFICULTY_TEXT_POSITION"] or "Lock difficulty text position", L["VISTA_DIFFICULTY_TEXT_CANNOT_DRAGGED"] or "When on, the difficulty text cannot be dragged.", "vistaLocked_diff", false),
            Section(L["VISTA_BUTTON_POSITIONS"] or "Button Positions"),
            Header(L["VISTA_DRAG_BUTTONS_REPOSITION_LOCK_PREVENT_MOVE"] or "Drag buttons to reposition them. Lock to prevent movement."),
            Button(L["VISTA_RESET_OVERLAY_POSITIONS"] or "Reset overlay positions to defaults", L["VISTA_RESET_OVERLAY_POSITIONS_DESC"] or "Clear saved positions for zone text, coordinates, clock, performance and difficulty text, tracking, calendar, queue, mail, the addon button bar, drawer button, and right-click panel. The minimap frame position is not changed.", function()
                if addon.Vista and addon.Vista.ResetOverlayPositionsToDefaults then
                    addon.Vista.ResetOverlayPositionsToDefaults()
                end
            end),
            Toggle(L["VISTA_LOCK_TRACKING_BUTTON"] or "Lock Tracking button", L["VISTA_PREVENT_DRAGGING_TRACKING_BUTTON"] or "Prevent dragging the tracking button.", "vistaLocked_proxy_tracking", true),
            Toggle(L["VISTA_LOCK_CALENDAR_BUTTON"] or "Lock Calendar button", L["VISTA_PREVENT_DRAGGING_CALENDAR_BUTTON"] or "Prevent dragging the calendar button.", "vistaLocked_proxy_calendar", true),
            Toggle(L["VISTA_LOCK_QUEUE_BUTTON"] or "Lock Queue button", L["VISTA_PREVENT_DRAGGING_QUEUE_STATUS_BUTTON"] or "Prevent dragging the queue status button.", "vistaLocked_proxy_queue", true),
            Toggle(L["VISTA_LOCK_MAIL_INDICATOR"] or "Lock Mail indicator", L["VISTA_PREVENT_DRAGGING_MAIL_ICON"] or "Prevent dragging the mail icon.", "vistaLocked_proxy_mail", true),
            Toggle(L["VISTA_LOCK_CRAFTING_ORDER_INDICATOR"] or "Lock Crafting Order indicator", L["VISTA_PREVENT_DRAGGING_CRAFTING_ORDER_ICON"] or "Prevent dragging the crafting order icon.", "vistaLocked_proxy_craftingOrder", true),
            Toggle(L["VISTA_DISABLE_QUEUE_HANDLING"] or "Disable queue handling", L["VISTA_TURN_QUEUE_BUTTON_ANCHORING_OFF_ADDON_CONFLICT"] or "Turn off all queue button anchoring (use if another addon manages it).", "vistaQueueHandlingDisabled", false),
            Section(L["VISTA_BUTTON_SIZES"] or "Button Sizes"),
            Header(L["VISTA_ADJUST_SIZE_OF_MINIMAP_OVERLAY_BUTTONS"] or "Adjust the size of minimap overlay buttons."),
            { type = "slider", name = L["VISTA_TRACKING_BUTTON_SIZE"] or "Tracking button size",
              desc = L["VISTA_SIZE_OF_TRACKING_BUTTON_PIXELS"] or "Size of the tracking button (pixels).",
              dbKey = "vistaTrackingBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaTrackingBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaTrackingBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_CALENDAR_BUTTON_SIZE"] or "Calendar button size",
              desc = L["VISTA_SIZE_OF_CALENDAR_BUTTON_PIXELS"] or "Size of the calendar button (pixels).",
              dbKey = "vistaCalendarBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCalendarBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaCalendarBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_QUEUE_BUTTON_SIZE"] or "Queue button size",
              desc = L["VISTA_SIZE_OF_QUEUE_STATUS_BUTTON_PIXELS"] or "Size of the queue status button (pixels).",
              dbKey = "vistaQueueBtnSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaQueueBtnSize", 22)) or 22)) end,
              set = function(v) setDB("vistaQueueBtnSize", math.max(14, math.min(40, v))) end },
            { type = "slider", name = L["VISTA_MAIL_INDICATOR_SIZE"] or "Mail indicator size",
              desc = L["VISTA_SIZE_OF_MAIL_ICON_PIXELS"] or "Size of the new mail icon (pixels).",
              dbKey = "vistaMailIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaMailIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaMailIconSize", math.max(14, math.min(40, v))) end },
            Toggle(L["MAIL_ICON_PULSE"] or "Mail icon pulse", L["VISTA_MAIL_ICON_PULSES_DRAW_ATTENTION"] or "When on, the mail icon pulses to draw attention. When off, it stays at full opacity.", "vistaMailBlink", true),
            { type = "slider", name = L["VISTA_CRAFTING_ORDER_INDICATOR_SIZE"] or "Crafting Order indicator size",
              desc = L["VISTA_SIZE_OF_CRAFTING_ORDER_ICON_PIXELS"] or "Size of the crafting order icon (pixels).",
              dbKey = "vistaCraftingOrderIconSize", min = 14, max = 40,
              get = function() return math.max(14, math.min(40, tonumber(getDB("vistaCraftingOrderIconSize", 20)) or 20)) end,
              set = function(v) setDB("vistaCraftingOrderIconSize", math.max(14, math.min(40, v))) end },
            Toggle(L["VISTA_CRAFTING_ORDER_ICON_PULSE"] or "Crafting Order icon pulse", L["VISTA_CRAFTING_ORDER_ICON_PULSES_DRAW_ATTENTION"] or "When on, the crafting order icon pulses to draw attention. When off, it stays at full opacity.", "vistaCraftingOrderBlink", true),
            { type = "slider", name = L["VISTA_ADDON_BUTTON_SIZE"] or "Addon button size",
              desc = L["VISTA_SIZE_OF_COLLECTED_ADDON_MINIMAP_BUTTONS"] or "Size of collected addon minimap buttons (pixels).",
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
            Section(L["VISTA_ZONE_TEXT_HEADER"] or "Zone Text"),
            { type = "dropdown", name = L["VISTA_ZONE_FONT"] or "Zone font",
              desc = L["VISTA_FONT_ZONE_NAME_BELOW_MINIMAP"] or "Font for the zone name below the minimap.",
              dbKey = "vistaZoneFontPath", searchable = true,
              options = function() return fontOpts("vistaZoneFontPath") end,
              get = function() return getFont("vistaZoneFontPath") end,
              set = function(v) setDB("vistaZoneFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_ZONE_FONT_SIZE"] or "Zone font size",
              dbKey = "vistaZoneFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaZoneFontSize", 12)) or 12)) end,
              set = function(v) setDB("vistaZoneFontSize", math.max(7, math.min(24, v))) end },
            { type = "color", name = L["VISTA_ZONE_TEXT_COLOUR"] or "Zone text color",
              desc = L["VISTA_COLOUR_OF_ZONE_NAME_TEXT"] or "Color of the zone name text.",
              dbKey = "vistaZoneColor",
              get = function()
                  return getDB("vistaZoneColorR", 1), getDB("vistaZoneColorG", 1), getDB("vistaZoneColorB", 1)
              end,
              set = function(r, g, b)
                  setDB("vistaZoneColorR", r); setDB("vistaZoneColorG", g); setDB("vistaZoneColorB", b)
              end },
            Section(L["VISTA_COORDINATES_TEXT"] or "Coordinates Text"),
            { type = "dropdown", name = L["VISTA_COORDINATES_FONT"] or "Coordinates font",
              desc = L["VISTA_FONT_COORDINATES_TEXT_BELOW_MINIMAP"] or "Font for the coordinates text below the minimap.",
              dbKey = "vistaCoordFontPath", searchable = true,
              options = function() return fontOpts("vistaCoordFontPath") end,
              get = function() return getFont("vistaCoordFontPath") end,
              set = function(v) setDB("vistaCoordFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_COORDINATES_FONT_SIZE"] or "Coordinates font size",
              dbKey = "vistaCoordFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaCoordFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaCoordFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_COORDINATES_TEXT_COLOUR"] or "Coordinates text color",
              desc = L["VISTA_COLOUR_OF_COORDINATES_TEXT"] or "Color of the coordinates text.",
              dbKey = "vistaCoordColor",
              get = function()
                  return getDB("vistaCoordColorR", 0.55), getDB("vistaCoordColorG", 0.65), getDB("vistaCoordColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaCoordColorR", r); setDB("vistaCoordColorG", g); setDB("vistaCoordColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_COORDINATE_PRECISION"] or "Coordinate precision",
              desc = L["VISTA_NUMBER_OF_DECIMAL_PLACES_SHOWN_X"] or "Number of decimal places shown for X and Y coordinates.",
              dbKey = "vistaCoordPrecision",
              options = function() return {
                  { L["VISTA_COORDS_DECIMALS_OFF"]      or "No decimals (e.g. 52, 37)",      0 },
                  { L["VISTA_DECIMAL_E_G"]    or "1 decimal (e.g. 52.3, 37.1)",    1 },
                  { L["VISTA_DECIMALS_E_G"] or "2 decimals (e.g. 52.34, 37.12)", 2 },
              } end,
              get = function() return tonumber(getDB("vistaCoordPrecision", 1)) or 1 end,
              set = function(v) setDB("vistaCoordPrecision", tonumber(v) or 1) end },
            Section(L["VISTA_TEXT"] or "Time Text"),
            { type = "dropdown", name = L["VISTA_FONT"] or "Time font",
              desc = L["VISTA_FONT_TEXT_BELOW_MINIMAP"] or "Font for the time text below the minimap.",
              dbKey = "vistaTimeFontPath", searchable = true,
              options = function() return fontOpts("vistaTimeFontPath") end,
              get = function() return getFont("vistaTimeFontPath") end,
              set = function(v) setDB("vistaTimeFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_FONT_SIZE"] or "Time font size",
              dbKey = "vistaTimeFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaTimeFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaTimeFontSize", math.max(7, math.min(20, v))) end },
            { type = "color", name = L["VISTA_TEXT_COLOUR"] or "Time text color",
              desc = L["VISTA_COLOUR_OF_TEXT"] or "Color of the time text.",
              dbKey = "vistaTimeColor",
              get = function()
                  return getDB("vistaTimeColorR", 0.55), getDB("vistaTimeColorG", 0.65), getDB("vistaTimeColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaTimeColorR", r); setDB("vistaTimeColorG", g); setDB("vistaTimeColorB", b)
              end },
            Section(L["VISTA_PERFORMANCE_TEXT"] or "Performance Text"),
            { type = "dropdown", name = L["VISTA_PERFORMANCE_FONT"] or "Performance font",
              desc = L["VISTA_FONT_FPS_LATENCY_TEXT_BELOW_MINIMAP"] or "Font for the FPS and latency text below the minimap.",
              dbKey = "vistaPerfFontPath", searchable = true,
              options = function() return fontOpts("vistaPerfFontPath") end,
              get = function() return getFont("vistaPerfFontPath") end,
              set = function(v) setDB("vistaPerfFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "slider", name = L["VISTA_PERFORMANCE_FONT_SIZE"] or "Performance font size",
              dbKey = "vistaPerfFontSize", min = 7, max = 20,
              get = function() return math.max(7, math.min(20, tonumber(getDB("vistaPerfFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaPerfFontSize", math.max(7, math.min(20, v))) end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            { type = "color", name = L["VISTA_PERFORMANCE_TEXT_COLOUR"] or "Performance text color",
              desc = L["VISTA_COLOUR_OF_FPS_LATENCY_TEXT"] or "Color of the FPS and latency text.",
              dbKey = "vistaPerfColor",
              get = function()
                  return getDB("vistaPerfColorR", 0.55), getDB("vistaPerfColorG", 0.65), getDB("vistaPerfColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaPerfColorR", r); setDB("vistaPerfColorG", g); setDB("vistaPerfColorB", b)
              end,
              disabled = function() return not getDB("vistaShowPerfText", false) end },
            Section(L["VISTA_DIFFICULTY_TEXT"] or "Difficulty Text"),
            { type = "color", name = L["VISTA_DIFFICULTY_TEXT_COLOUR_FALLBACK"] or "Difficulty text color (fallback)",
              desc = L["VISTA_DEFAULT_COLOUR_PER_DIFFICULTY_COLOUR"] or "Default color when no per-difficulty color is set.",
              dbKey = "vistaDiffColor",
              get = function()
                  return getDB("vistaDiffColorR", 0.55), getDB("vistaDiffColorG", 0.65), getDB("vistaDiffColorB", 0.75)
              end,
              set = function(r, g, b)
                  setDB("vistaDiffColorR", r); setDB("vistaDiffColorG", g); setDB("vistaDiffColorB", b)
              end },
            { type = "dropdown", name = L["VISTA_DIFFICULTY_FONT"] or "Difficulty font",
              desc = L["VISTA_FONT_INSTANCE_DIFFICULTY_TEXT"] or "Font for the instance difficulty text.",
              dbKey = "vistaDiffFontPath", searchable = true,
              options = function() return fontOpts("vistaDiffFontPath") end,
              get = function() return getFont("vistaDiffFontPath") end,
              set = function(v) setDB("vistaDiffFontPath", v) end,
              displayFn = displayFont, fontPreviewInList = true },
            { type = "slider", name = L["VISTA_DIFFICULTY_FONT_SIZE"] or "Difficulty font size",
              dbKey = "vistaDiffFontSize", min = 7, max = 24,
              get = function() return math.max(7, math.min(24, tonumber(getDB("vistaDiffFontSize", 10)) or 10)) end,
              set = function(v) setDB("vistaDiffFontSize", math.max(7, math.min(24, v))) end },
            Section(L["VISTA_PER_DIFFICULTY_COLOURS"] or "Per-Difficulty Colors", { defaultCollapsed = true }),
            { type = "color", name = L["VISTA_MYTHIC_COLOUR"] or "Mythic color",
              desc = L["VISTA_COLOUR_MYTHIC_DIFFICULTY_TEXT"] or "Color for Mythic difficulty text.",
              dbKey = "vistaDiffColor_mythic",
              get = function() return getDB("vistaDiffColor_mythic_R", 0.64), getDB("vistaDiffColor_mythic_G", 0.21), getDB("vistaDiffColor_mythic_B", 0.93) end,
              set = function(r, g, b) setDB("vistaDiffColor_mythic_R", r); setDB("vistaDiffColor_mythic_G", g); setDB("vistaDiffColor_mythic_B", b) end },
            { type = "color", name = L["VISTA_HEROIC_COLOUR"] or "Heroic color",
              desc = L["VISTA_COLOUR_HEROIC_DIFFICULTY_TEXT"] or "Color for Heroic difficulty text.",
              dbKey = "vistaDiffColor_heroic",
              get = function() return getDB("vistaDiffColor_heroic_R", 1.00), getDB("vistaDiffColor_heroic_G", 0.12), getDB("vistaDiffColor_heroic_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_heroic_R", r); setDB("vistaDiffColor_heroic_G", g); setDB("vistaDiffColor_heroic_B", b) end },
            { type = "color", name = L["VISTA_NORMAL_COLOUR"] or "Normal color",
              desc = L["VISTA_COLOUR_NORMAL_DIFFICULTY_TEXT"] or "Color for Normal difficulty text.",
              dbKey = "vistaDiffColor_normal",
              get = function() return getDB("vistaDiffColor_normal_R", 0.12), getDB("vistaDiffColor_normal_G", 0.83), getDB("vistaDiffColor_normal_B", 0.12) end,
              set = function(r, g, b) setDB("vistaDiffColor_normal_R", r); setDB("vistaDiffColor_normal_G", g); setDB("vistaDiffColor_normal_B", b) end },
            { type = "color", name = L["VISTA_LFR_COLOUR"] or "LFR color",
              desc = L["VISTA_COLOUR_LOOKING_RAID_DIFFICULTY_TEXT"] or "Color for Looking For Raid difficulty text.",
              dbKey = "vistaDiffColor_lfr",
              get = function() return getDB("vistaDiffColor_looking_for_raid_R", 0.00), getDB("vistaDiffColor_looking_for_raid_G", 0.70), getDB("vistaDiffColor_looking_for_raid_B", 1.00) end,
              set = function(r, g, b) setDB("vistaDiffColor_looking_for_raid_R", r); setDB("vistaDiffColor_looking_for_raid_G", g); setDB("vistaDiffColor_looking_for_raid_B", b) end },
        } end,
    },
    {
        key = "VistaButtons",
        name = L["VISTA_ADDON_BUTTONS"] or "Addon Buttons",
        desc = L["VISTA_ICON_MANAGEMENT"] or "Manage and organize minimap icons from other addons into a tidy drawer or bar.",
        moduleKey = "vista",
        options = function()
            local BUTTON_MODE_OPTIONS = {
                { L["VISTA_MOUSEOVER_BAR"] or "Mouseover bar", "mouseover" },
                { L["VISTA_RIGHT_CLICK_PANEL"] or "Right-click panel", "rightclick" },
                { L["VISTA_FLOATING_DRAWER"] or "Floating drawer", "drawer" },
            }

            local opts = {
                Section(L["VISTA_BUTTON_MANAGEMENT"] or "Button Management"),
                { type = "toggle", name = L["MANAGE_ADDON_BUTTONS"] or "Manage addon buttons",
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
                { type = "toggle", name = L["VISTA_COLLECT_HORIZON_MINIMAP"] or "Include Horizon minimap icon",
                  desc = L["VISTA_COLLECT_HORIZON_MINIMAP_DESC"] or "Place Horizon's own minimap icon in the managed addon bar, panel, or drawer instead of leaving it on the minimap edge.",
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
                Toggle(L["VISTA_SORT_BUTTONS_ALPHA"] or "Sort buttons alphabetically", L["VISTA_SORT_BUTTONS_ALPHA_DESC"] or "Sort collected addon minimap buttons alphabetically by name.", "vistaButtonSortAlpha", false, { disabled = function() return not getDB("vistaHandleAddonButtons", true) end }),
                { type = "dropdown", name = L["VISTA_BUTTON_MODE"] or "Button mode",
                  desc = L["VISTA_ADDON_BUTTONS_PRESENTED_HOVER_BAR_BELOW"] or "How addon buttons are presented: hover bar below minimap, panel on right-click, or floating drawer button.",
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
                  name = L["VISTA_CHOOSE_DRAWER_ICON"] or "Choose Drawer Icon",
                  dbKey = "vistaDrawerIcon",
                  visibleWhen = function()
                      return getDB("vistaHandleAddonButtons", true) and getDB("vistaButtonMode", "mouseover") == "drawer"
                  end,
                  tooltip = L["VISTA_DRAWER_BUTTON_ICON_DESC"] or "Enter a Blizzard icon file ID or texture path. Leave blank to use the default drawer icon.",
                  onClick = function()
                      if addon.OpenVistaDrawerIconPicker then
                          addon.OpenVistaDrawerIconPicker()
                      end
                  end },
                { type = "toggle", name = L["LOCK_DRAWER_BUTTON"] or "Lock drawer button",
                  desc = L["VISTA_PREVENT_DRAGGING_FLOATING_DRAWER_BUTTON"] or "Prevent dragging the floating drawer button.",
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
                Toggle(L["LOCK_MOUSEOVER_BAR"] or "Lock mouseover bar", L["VISTA_PREVENT_DRAGGING_MOUSEOVER_BUTTON_BAR"] or "Prevent dragging the mouseover button bar.", "vistaMouseoverLocked", true, { disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover" end }),
                Toggle(L["VISTA_ALWAYS_BAR"] or "Always show bar", L["KEEP_BAR_VISIBLE_REPOSITIONING"], "vistaMouseoverBarVisible", false, { tooltip = L["VISTA_DISABLE_DONE"], disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "mouseover" end }),
                Toggle(L["LOCK_RIGHT_CLICK_PANEL"] or "Lock right-click panel", L["VISTA_PREVENT_DRAGGING_RIGHT_CLICK_PANEL"] or "Prevent dragging the right-click panel.", "vistaRightClickLocked", true, { disabled = function() return not getDB("vistaHandleAddonButtons", true) or getDB("vistaButtonMode", "mouseover") ~= "rightclick" end }),

                Section(L["VISTA_CLOSE_FADE_TIMING"] or "Close / Fade Timing", { defaultCollapsed = true }),
                { type = "slider", name = L["MOUSEOVER_CLOSE_DELAY"] or "Mouseover close delay",
                  desc = L["VISTA_LONG_SECONDS_BAR_STAYS_VISIBLE_AFTER"] or "How long (in seconds) the bar stays visible after the cursor leaves. 0 = instant fade.",
                  dbKey = "vistaMouseoverCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaMouseoverCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaMouseoverCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["RIGHT_CLICK_CLOSE_DELAY"] or "Right-click close delay",
                  desc = L["VISTA_LONG_SECONDS_PANEL_STAYS_OPEN_AFTER"] or "How long (in seconds) the panel stays open after the cursor leaves. 0 = never auto-close (close by right-clicking again).",
                  dbKey = "vistaRightClickCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaRightClickCloseDelay", 2.5)) or 2.5)) end,
                  set = function(v) setDB("vistaRightClickCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },
                { type = "slider", name = L["VISTA_DRAWER_CLOSE_DELAY"] or "Drawer close delay",
                  desc = L["AUTO_CLOSE_DELAY_DISABLE"] or "Auto-close delay (0 to disable).",
                  tooltip = L["VISTA_LONG_SECONDS_DRAWER_PANEL_STAYS_OPEN"] or "How long (in seconds) the drawer panel stays open after clicking away. 0 = never auto-close (close only by clicking the drawer button again).",
                  dbKey = "vistaDrawerCloseDelay", min = 0, max = 10, step = 0.5,
                  get = function() return math.max(0, math.min(10, tonumber(getDB("vistaDrawerCloseDelay", 0)) or 0)) end,
                  set = function(v) setDB("vistaDrawerCloseDelay", math.max(0, math.min(10, v))) end,
                  disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
                },

                Section(L["DASH_LAYOUT"] or "Layout"),
            }

            local DIR_OPTIONS = function() return {
                { L["VISTA_BUTTONS_FILL_RIGHT"] or "Right", "right" },
                { L["VISTA_BUTTONS_FILL_LEFT"] or "Left",   "left"  },
                { L["VISTA_BUTTONS_FILL_DOWN"] or "Down",   "down"  },
                { L["VISTA_BUTTONS_FILL_UP"] or "Up",       "up"    },
            } end

            opts[#opts + 1] = {
                type = "slider", name = L["VISTA_BUTTONS_PER_ROW_COLUMN"] or "Buttons per row/column",
                desc = L["VISTA_CONTROLS_MANY_BUTTONS_APPEAR_BEFORE_WRAPPING"] or "Controls how many buttons appear before wrapping. For left/right direction this is columns; for up/down it is rows.",
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
                type = "dropdown", name = L["VISTA_EXPAND_DIRECTION"] or "Expand direction",
                desc = L["EXPAND_DIRECTION_ANCHOR"] or "Expand direction from anchor.",
                tooltip = L["VISTA_DIRECTION_BUTTONS_FILL_ANCHOR_POINT_LEFT"] or "Direction buttons fill from the anchor point. Left/Right = horizontal rows. Up/Down = vertical columns.",
                dbKey = "vistaBtnLayoutDir", options = DIR_OPTIONS,
                get = function() return getDB("vistaBtnLayoutDir", "right") end,
                set = function(v) setDB("vistaBtnLayoutDir", v) end,
                disabled = function() return not getDB("vistaHandleAddonButtons", true) end,
            }

            opts[#opts + 1] = Section(L["VISTA_PANEL_APPEARANCE"] or "Panel Appearance")
            opts[#opts + 1] = Header(L["VISTA_COLOURS_DRAWER_RIGHT_CLICK_BUTTON_PANELS"] or "Colors for the drawer and right-click button panels.")
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_PANEL_BG_COLOUR_LABEL"] or "Panel background color",
                desc = L["VISTA_BACKGROUND_COLOUR_OF_ADDON_BUTTON_PANELS"] or "Background color of the addon button panels.",
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
                type = "color", name = L["VISTA_PANEL_BORDER_COLOUR"] or "Panel border color",
                desc = L["VISTA_BORDER_COLOUR_OF_ADDON_BUTTON_PANELS"] or "Border color of the addon button panels.",
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

            opts[#opts + 1] = Section(L["VISTA_MOUSEOVER_BAR_APPEARANCE"] or "Mouseover Bar Appearance")
            opts[#opts + 1] = Header(L["VISTA_BACKGROUND_BORDER_MOUSEOVER_BUTTON_BAR"] or "Background and border for the mouseover button bar.")
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BACKGROUND_COLOUR"] or "Bar background color",
                desc = L["VISTA_BACKGROUND_COLOUR_OF_MOUSEOVER_BUTTON_BAR"] or "Background color of the mouseover button bar (use alpha to control transparency).",
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
            opts[#opts + 1] = Toggle(L["VISTA_BAR_BORDER"] or "Show bar border", L["VISTA_A_BORDER_AROUND_MOUSEOVER_BUTTON_BAR"] or "Show a border around the mouseover button bar.", "vistaBarBorderShow", false, { disabled = function() return not getDB("vistaHandleAddonButtons", true) end })
            opts[#opts + 1] = {
                type = "color", name = L["VISTA_BAR_BORDER_COLOUR"] or "Bar border color",
                desc = L["VISTA_BORDER_COLOUR_OF_MOUSEOVER_BUTTON_BAR"] or "Border color of the mouseover button bar.",
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

            opts[#opts + 1] = Section(L["VISTA_MANAGED_BUTTONS"] or "Managed buttons")

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
                    desc = L["VISTA_BUTTON_COMPLETELY_IGNORED"] or "When off, this button is completely ignored by this addon.",
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
                    name = L["VISTA_ADDON_BUTTONS_DETECTED"] or "(No addon buttons detected yet)",
                    dbKey = "_vista_no_managed_placeholder",
                    get = function() return false end, set = function() end,
                    disabled = function() return true end,
                }
            end

            opts[#opts + 1] = Section(L["VISTA_VISIBLE_BUTTONS_CHECK_INCLUDE"] or "Visible buttons (check to include)")

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
                    name = L["VISTA_ADDON_BUTTONS_DETECTED_OPEN_YOUR_MINIMAP"] or "(No addon buttons detected yet — open your minimap first)",
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
