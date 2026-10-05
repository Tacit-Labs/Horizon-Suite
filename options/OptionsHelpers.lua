--[[
    Horizon Suite - Shared option-descriptor helpers
    Exports font/outline helpers, BrandModule, and option-descriptor builders used by
    multiple module option files. Must load after OptionsData.lua and before any module
    options file.
]]
local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L
local function getDB(k, d) return addon.GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end

local FONT_USE_GLOBAL = "__global__"

local function GetPerElementFontDropdownOptions(dbKey)
    if addon.RefreshFontList then addon.RefreshFontList() end
    local list = (addon.GetFontList and addon.GetFontList()) or {}
    local out = { { L["FOCUS_GLOBAL_FONT"], FONT_USE_GLOBAL } }
    for i = 1, #list do out[#out + 1] = list[i] end
    local saved = getDB(dbKey, FONT_USE_GLOBAL)
    if saved == FONT_USE_GLOBAL then return out end
    for _, o in ipairs(out) do
        if o[2] == saved then return out end
    end
    out[#out + 1] = { L["FOCUS_CUSTOM"], saved }
    return out
end

local function DisplayPerElementFont(value)
    if value == FONT_USE_GLOBAL then return L["FOCUS_GLOBAL_FONT"] end
    if addon.GetFontNameForPath then return addon.GetFontNameForPath(value) end
    return value
end

local OUTLINE_OPTIONS = {
    { L["FOCUS_OUTLINE_NONE"], "" },
    { L["FOCUS_OUTLINE"], "OUTLINE" },
    { L["FOCUS_THICK_OUTLINE"], "THICKOUTLINE" },
    { L["FOCUS_SLUG"], "SLUG" },
    { L["FOCUS_SLUG_OUTLINE"], "OUTLINE, SLUG" },
    { L["FOCUS_SLUG_THICK_OUTLINE"], "THICKOUTLINE, SLUG" },
}
local VALID_OUTLINE_VALUES = {}
for _, pair in ipairs(OUTLINE_OPTIONS) do VALID_OUTLINE_VALUES[pair[2]] = true end

local function BrandModule(moduleKey)
    if addon.GetModuleDisplayName then return addon.GetModuleDisplayName(moduleKey) end
    local t = addon.BrandDisplay and addon.BrandDisplay.module
    if not moduleKey or not t then return nil end
    return t[moduleKey]
end

local function merge(t, opts)
    if opts then for k, v in pairs(opts) do t[k] = v end end
    return t
end

local function Section(name, opts)
    return merge({ type = "section", name = name }, opts)
end

local function Header(name)
    return { type = "header", name = name }
end

local function ModuleReloadPrompt(opts)
    return merge({ type = "moduleReloadPrompt" }, opts)
end

local function Button(name, desc, onClick, opts)
    return merge({ type = "button", name = name, desc = desc, onClick = onClick }, opts)
end

local function Toggle(name, desc, dbKey, default, opts)
    return merge({
        type = "toggle", name = name, desc = desc, dbKey = dbKey,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }, opts)
end

local function Slider(name, desc, dbKey, min, max, default, opts)
    return merge({
        type = "slider", name = name, desc = desc, dbKey = dbKey,
        min = min, max = max,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }, opts)
end

local function Color(name, desc, dbKey, default, opts)
    return merge({ type = "color", name = name, desc = desc, dbKey = dbKey, default = default }, opts)
end

local FONT_ROW_PARTS = { "family", "size", "outline" }

-- One row that sets a text element's font, size and outline. Each part keeps its own saved
-- key, getter and setter; a part without a getter or setter reads and writes its key. The
-- row's dbKey is its primary key (family, else size), which the assembler and search
-- key on. The assembler also resolves a `parent` that names any part key.
-- @param name string|function
-- @param desc string|function|nil
-- @param parts table  { family?, size?, outline? }; each { dbKey, default?, get?, set?, refreshIds?, ... }.
--   family: options, displayFn. size: min, max, step. outline: kind ("dropdown" or "toggle"), options.
-- @param opts table|nil  Merged into the row (parent, parentIs, keywords, visibleWhen, ...)
-- @return table
local function FontRow(name, desc, parts, opts)
    local own = {}
    for _, slot in ipairs(FONT_ROW_PARTS) do
        local src = parts and parts[slot]
        if src then
            local p = {}
            for k, v in pairs(src) do p[k] = v end
            local key, default = p.dbKey, p.default
            if not p.get and key then p.get = function() return getDB(key, default) end end
            if not p.set and key then p.set = function(v) setDB(key, v) end end
            if slot == "outline" and p.kind == nil then p.kind = "dropdown" end
            own[slot] = p
        end
    end
    local primary = (own.family and own.family.dbKey) or (own.size and own.size.dbKey)
        or (own.outline and own.outline.dbKey)
    return merge({ type = "fontRow", name = name, desc = desc, dbKey = primary, parts = own }, opts)
end

-- Font row geometry, shared by FontRowLayout and the widget that draws the row.
local FONT_ROW_METRICS = {
    wrapBelow   = 640,  -- a row narrower than this wraps to two lines
    lineH       = 34,   -- first line: label and font (and, unwrapped, every control)
    line2H      = 30,   -- second line when wrapped: size and outline
    controlH    = 26,
    gap         = 8,    -- between controls
    labelGap    = 12,   -- between the label and the first control
    familyMin   = 140,
    familyMax   = 220,
    stepperW    = 84,
    outlineW    = 130,
    outlineSegMax = 200, -- the widest the outline part may grow as segmented buttons
}

--- Lay out a font row at a given width. A width of 0 or less (not yet anchored) lays out as one line.
--- @param width number
--- @param has table  { family = bool, size = bool, outline = bool }
--- @return table  { wrapped = bool, familyW = number, lines = 1 or 2 }  The widget sets the
---   lines' heights (SettingsRowHeight), so the layout reports only how many there are.
local function FontRowLayout(width, has)
    local M = FONT_ROW_METRICS
    has = has or {}
    local known = type(width) == "number" and width > 0
    local wrapped = known and width < M.wrapBelow
    local share = wrapped and 0.4 or 0.24
    local familyW = known and math.floor(width * share) or M.familyMax
    familyW = math.max(M.familyMin, math.min(M.familyMax, familyW))
    local lines = (wrapped and (has.size or has.outline)) and 2 or 1
    return { wrapped = wrapped and true or false, familyW = familyW, lines = lines }
end

--- Step or clamp a font size the way the old slider did: snap to the step, then clamp.
--- @param value number|string  Current or typed value
--- @param delta number  -1, 0 or 1 (0 for a typed value)
--- @param min number
--- @param max number
--- @param step number|nil  Default 1
--- @param fallback number|nil  Used when value is not a number (default min)
--- @return number
local function FontRowStepSize(value, delta, min, max, step, fallback)
    step = tonumber(step) or 1
    if step <= 0 then step = 1 end
    local v = tonumber(value)
    if v == nil then return tonumber(fallback) or min end
    v = v + (delta or 0) * step
    v = math.floor(v / step + 0.5) * step
    v = math.max(min, math.min(max, v))
    if step < 1 then
        local s = tostring(step)
        local dot = s:find("%.")
        local decimals = dot and (#s - dot) or 0
        v = tonumber(string.format("%." .. decimals .. "f", v))
    end
    return v
end

--- Show a font size the way the stepper does: as many decimals as the step has.
--- @param value number
--- @param step number|nil  Default 1
--- @return string
local function FontRowFormatSize(value, step)
    step = tonumber(step) or 1
    local v = tonumber(value) or 0
    if step > 0 and step < 1 then
        local s = tostring(step)
        local dot = s:find("%.")
        local decimals = dot and (#s - dot) or 0
        return string.format("%." .. decimals .. "f", v)
    end
    return tostring(math.floor(v + 0.5))
end

--- The size to save for text typed into the stepper, or nil to save nothing: when the text is
--- not a number, still shows the saved value (focus in and out, Escape), or lands on the saved value.
--- @param text string
--- @param current number|nil  The saved size
--- @param min number
--- @param max number
--- @param step number|nil
--- @return number|nil
local function FontRowTypedSize(text, current, min, max, step)
    if tonumber(text) == nil then return nil end
    if current ~= nil and text == FontRowFormatSize(current, step) then return nil end
    local v = FontRowStepSize(text, 0, min, max, step, current)
    if v == tonumber(current) then return nil end
    return v
end

--- The vertical rhythm of a card's visible entries, and where its hairlines go. Settings rows
--- pad themselves; other entries get gaps. A row or custom widget gets a hairline above it
--- unless it is the first entry in the card or follows a subheading or a note (the start of a
--- group). Subheadings and notes never get one, and a spacer (a zero-height entry) is skipped.
--- @param kinds table  Each visible entry in order: "row", "block", "subheading", "note" or "spacer"
--- @param m table  { subheadingTop, subheadingBottom, noteTop, blockPad }
--- @return table  One { top = number, bottom = number, divider = boolean } per entry
local function CardRowSpacing(kinds, m)
    local out = {}
    local prev
    for i, kind in ipairs(kinds or {}) do
        local e = { top = 0, bottom = 0, divider = false }
        if kind == "subheading" then
            e.top, e.bottom = m.subheadingTop or 0, m.subheadingBottom or 0
        elseif kind == "note" then
            e.top = m.noteTop or 0
        elseif kind == "block" then
            e.top, e.bottom = m.blockPad or 0, m.blockPad or 0
        end
        if (kind == "row" or kind == "block") and (prev == "row" or prev == "block") then
            e.divider = true
        end
        if kind ~= "spacer" then prev = kind end
        out[i] = e
    end
    return out
end

--- The height of a settings row from its measured text. The label and description stack
--- with descGap between them, centred with padY above and below; the row is never shorter than
--- minH. Heights over labelMaxH or descMaxH (the line caps: two lines each) are clamped, in
--- case a client reports the unclamped height of truncated text.
--- @param labelH number  Measured label height
--- @param descH number|nil  Measured description height; 0 or nil for no description
--- @param m table  { minH, padY, descGap, labelMaxH?, descMaxH? }
--- @return number height, number blockH  The row height and the text block's height
local function SettingsRowHeight(labelH, descH, m)
    labelH = math.max(0, tonumber(labelH) or 0)
    descH = math.max(0, tonumber(descH) or 0)
    if m.labelMaxH then labelH = math.min(labelH, m.labelMaxH) end
    if m.descMaxH then descH = math.min(descH, m.descMaxH) end
    local blockH = labelH
    if descH > 0 then blockH = blockH + (m.descGap or 0) + descH end
    return math.max(m.minH or 0, math.ceil(blockH + 2 * (m.padY or 0))), blockH
end

local SEGMENTED_MIN, SEGMENTED_MAX = 2, 4  -- segments a dropdown may become

--- Whether a dropdown row (or a font row's outline part) may show as segmented buttons: a
--- static option table of two to four entries, not searchable, with no font preview, no greyed
--- out entry, and no `segmented = false`. Whether the segments fit is decided at layout time
--- (SegmentedFits), so an eligible row can still render as a dropdown.
--- @param opt table  The row definition or the font-row part
--- @return boolean
local function SegmentedEligible(opt)
    if type(opt) ~= "table" then return false end
    if opt.type ~= nil and opt.type ~= "dropdown" then return false end
    if opt.kind == "toggle" or opt.segmented == false then return false end
    if opt.searchable or opt.fontPreviewInList then return false end
    if type(opt.options) ~= "table" then return false end
    -- Count entries the way the dropdown normalises them: array rows and name -> value pairs.
    local n = 0
    for k, v in pairs(opt.options) do
        if type(k) == "number" and type(v) == "table" then
            if v[3] == true then return false end
            n = n + 1
        elseif type(k) == "string" then
            n = n + 1
        end
    end
    return n >= SEGMENTED_MIN and n <= SEGMENTED_MAX
end

--- Whether segments fit a space. Each segment is its label (rounded up) plus segPadX on each
--- side; segments are gap apart inside a track padded by trackPad.
--- @param labelWidths table  Measured label widths, in order
--- @param available number|nil  The space for the control
--- @param padding table|number|nil  { segPadX, trackPad, gap }, or a number for segPadX alone
--- @return boolean fits, number width  The control's natural width
local function SegmentedFits(labelWidths, available, padding)
    local segPadX, trackPad, gap = 0, 0, 0
    if type(padding) == "number" then
        segPadX = padding
    elseif type(padding) == "table" then
        segPadX = tonumber(padding.segPadX) or 0
        trackPad = tonumber(padding.trackPad) or 0
        gap = tonumber(padding.gap) or 0
    end
    local n = type(labelWidths) == "table" and #labelWidths or 0
    local width = 2 * trackPad + math.max(0, n - 1) * gap
    for i = 1, n do
        width = width + math.ceil(tonumber(labelWidths[i]) or 0) + 2 * segPadX
    end
    local space = tonumber(available)
    return (n > 0 and space ~= nil and space > 0 and width <= space) and true or false, width
end

addon.CardRowSpacing                   = CardRowSpacing
addon.SettingsRowHeight                = SettingsRowHeight
addon.SegmentedEligible                = SegmentedEligible
addon.SegmentedFits                    = SegmentedFits
addon.FONT_ROW_METRICS                 = FONT_ROW_METRICS
addon.FontRowLayout                    = FontRowLayout
addon.FontRowStepSize                  = FontRowStepSize
addon.FontRowFormatSize                = FontRowFormatSize
addon.FontRowTypedSize                 = FontRowTypedSize
addon.FONT_ROW_PARTS                   = FONT_ROW_PARTS
addon.FontRow                          = FontRow
addon.FONT_USE_GLOBAL                  = FONT_USE_GLOBAL
addon.GetPerElementFontDropdownOptions = GetPerElementFontDropdownOptions
addon.DisplayPerElementFont            = DisplayPerElementFont
addon.OUTLINE_OPTIONS                  = OUTLINE_OPTIONS
addon.VALID_OUTLINE_VALUES             = VALID_OUTLINE_VALUES
addon.BrandModule                      = BrandModule
addon.Section                          = Section

-- ---------------------------------------------------------------------------
-- Platform gating. A row or Section carrying `requires = "<capability>"` is
-- dropped from the options tree when addon.Platform.Has(capability) is false
-- (e.g. Mythic+ rows on WoW: Forever). options/OptionsPlatform.lua runs the
-- prune once over addon.OptionCategories after every module has registered.
-- ---------------------------------------------------------------------------

-- Attach a capability requirement to an option built by a helper that takes no opts table.
-- @param capability string  Key in addon.Platform.has
-- @param option table
-- @return table  The same option, tagged
function addon.RequireCapability(capability, option)
    if type(option) == "table" then option.requires = capability end
    return option
end

-- Return a copy of an option list without rows whose capability is absent.
-- @param list table|nil
-- @return table|nil
function addon.PruneOptionsForPlatform(list)
    if type(list) ~= "table" then return list end
    local P = addon.Platform
    local out = {}
    for _, row in ipairs(list) do
        local keep = true
        if type(row) == "table" and row.requires and P and not P.Has(row.requires) then
            keep = false
        end
        if keep then
            out[#out + 1] = row
        end
    end
    return out
end
addon.Header                           = Header
addon.ModuleReloadPrompt               = ModuleReloadPrompt
addon.Button                           = Button
addon.Toggle                           = Toggle
addon.Slider                           = Slider
addon.Color                            = Color
