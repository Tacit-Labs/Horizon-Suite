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
        type = "toggle", name = name, desc = desc, dbKey = dbKey, default = default,
        get = function() return getDB(dbKey, default) end,
        set = function(v) setDB(dbKey, v) end,
    }, opts)
end

local function Slider(name, desc, dbKey, min, max, default, opts)
    return merge({
        type = "slider", name = name, desc = desc, dbKey = dbKey, default = default,
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

-- ---------------------------------------------------------------------------
-- Changed-from-default markers (Docs/Engineering/2026-10-05-dashboard-premium-polish-design.md,
-- item 4). A row is changed when the active profile stores a value for its key and that value
-- differs from the row's default. The helpers are pure: the stored-value reader is injected,
-- and the live one (OptionStoredValue) reads the profile with no default fallback.
-- ---------------------------------------------------------------------------

-- Module defaults tables, searched in this order; Axis (suite-wide keys) comes last, as the
-- key-ownership rule in OptionsData.lua reads them. TALKING_HEAD_DEFAULTS is an alias of
-- AUGMENT_DEFAULTS today and is listed in case that changes.
local DEFAULT_TABLES = {
    "FOCUS_DEFAULTS", "VISTA_DEFAULTS", "INSIGHT_DEFAULTS", "PRESENCE_DEFAULTS", "ECHO_DEFAULTS",
    "AUGMENT_DEFAULTS", "TALKING_HEAD_DEFAULTS", "ESSENCE_DEFAULTS", "AXIS_DEFAULTS",
}
local SPLIT_SUFFIXES = { "R", "G", "B", "A" }
local COLOR_FIELDS = { r = 1, g = 2, b = 3, a = 4 }
local NUMBER_TOLERANCE = 0.001   -- a colour channel step is about 0.004; slider steps are coarser

-- Row types that carry a changed marker. Buttons, notes, subheadings, previews, lists and the
-- colour matrices are left out.
local MARKABLE_TYPES = { toggle = true, binary = true, slider = true, dropdown = true, color = true, fontRow = true }

local function TableDefault(key)
    for _, name in ipairs(DEFAULT_TABLES) do
        local t = rawget(addon, name)
        if type(t) == "table" then
            local v = t[key]
            if v ~= nil then return v end
        end
    end
    return nil
end

--- The default for a saved key: the row's own default when it has one (a helper set it, or a
--- font-row part carries it), else the first module defaults table that holds the key, else a
--- colour assembled from split <key>R/G/B(/A) defaults. Nil when none is found.
--- @param key string
--- @param row table|nil  The row, or a font-row part, whose dbKey is key
--- @return any
local function OptionDefault(key, row)
    if type(key) ~= "string" then return nil end
    if type(row) == "table" and row.default ~= nil and (row.dbKey == nil or row.dbKey == key) then
        return row.default
    end
    local v = TableDefault(key)
    if v ~= nil then return v end
    local r, g, b = TableDefault(key .. "R"), TableDefault(key .. "G"), TableDefault(key .. "B")
    if r ~= nil and g ~= nil and b ~= nil then
        return { r, g, b, TableDefault(key .. "A") }
    end
    return nil
end

--- Whether a row can carry a changed marker: a settings row of a markable type with a saved key.
--- Keys starting with "_" are pseudo-keys (the Profiles page) and are never marked.
--- @param row table
--- @return boolean
local function OptionMarkable(row)
    if type(row) ~= "table" or not MARKABLE_TYPES[row.type] then return false end
    local key = row.dbKey
    return type(key) == "string" and key ~= "" and key:sub(1, 1) ~= "_"
end

-- A colour's channels in 1..4 order, whether it uses array or r/g/b/a fields.
local function ColorChannels(t)
    local out = {}
    for k, v in pairs(t) do
        local i = COLOR_FIELDS[k] or k
        out[i] = v
    end
    return out
end

local function ValuesEqual(a, b)
    if type(a) == "number" and type(b) == "number" then
        return math.abs(a - b) <= NUMBER_TOLERANCE
    end
    if type(a) == "table" and type(b) == "table" then
        local ca, cb = ColorChannels(a), ColorChannels(b)
        -- A colour saved without alpha is opaque.
        if type(ca[1]) == "number" and type(cb[1]) == "number" then
            if ca[4] == nil then ca[4] = 1 end
            if cb[4] == nil then cb[4] = 1 end
        end
        for k, v in pairs(ca) do
            if not ValuesEqual(v, cb[k]) then return false end
        end
        for k in pairs(cb) do
            if ca[k] == nil then return false end
        end
        return true
    end
    return a == b
end

-- What a row's getter shows when nothing is stored for key: its getter is called with
-- addon.GetDB answering `default` for that one key, so a default kept in code (a getter's
-- fallback, a helper such as GetCombatVisibility) is found in the row's own units. Returns a
-- packed table of the getter's results, or nil when the row has no getter or it errors. A
-- getter that captured GetDB at load ignores the mask; it then shows its stored value both
-- ways and reads as unchanged, which is the safe side.
local function ShownWithKeyCleared(row, key)
    if type(row) ~= "table" or type(row.get) ~= "function" then return nil end
    local real = addon.GetDB
    if type(real) ~= "function" then return nil end
    addon.GetDB = function(k, d)
        if k == key then return d end
        return real(k, d)
    end
    local res = { pcall(row.get) }
    addon.GetDB = real
    if not res[1] then return nil end
    table.remove(res, 1)
    return res
end

local function ShownNow(row)
    local res = { pcall(row.get) }
    if not res[1] then return nil end
    table.remove(res, 1)
    return res
end

--- For a row with no default in a table: whether its stored value shows the same as its
--- code default. Nil when that can't be worked out (no getter, or the getter errors).
--- @param row table  The row or font-row part whose dbKey is key
--- @param key string
--- @return boolean|nil
local function ShownMatchesCodeDefault(row, key)
    local def = ShownWithKeyCleared(row, key)
    if not def then return nil end
    local now = ShownNow(row)
    if not now then return nil end
    if #now ~= #def then return false end
    for i = 1, #def do
        if not ValuesEqual(now[i], def[i]) then return false end
    end
    return true
end

-- One saved key against its default. A colour row stored as split <key>R/G/B/A keys is changed
-- when any stored part differs from the matching part of the default. With no default in a
-- table, a row whose getter can be asked (ShownMatchesCodeDefault) is compared as it shows.
local function KeyChanged(key, row, getStored, isColor)
    local def = OptionDefault(key, row)
    if def == nil then
        if getStored(key) == nil then return false end
        local same = ShownMatchesCodeDefault(row, key)
        return same == false
    end
    local stored = getStored(key)
    if stored ~= nil then
        -- A row that reads several stored forms as one value (legacy numbers for an outline
        -- choice, say) gives `normalize`, and both sides are compared as the row shows them.
        if type(row) == "table" and type(row.normalize) == "function" then
            stored, def = row.normalize(stored), row.normalize(def)
        end
        return not ValuesEqual(stored, def)
    end
    if not isColor or type(def) ~= "table" then return false end
    local dc = ColorChannels(def)
    for i, suffix in ipairs(SPLIT_SUFFIXES) do
        local part = getStored(key .. suffix)
        if part ~= nil then
            local want = dc[i]
            if want == nil and i == 4 then want = 1 end
            if want == nil or not ValuesEqual(part, want) then return true end
        end
    end
    return false
end

--- Whether key stores a value that equals its default (through the row's normalize, as
--- OptionIsChanged compares). A reset's deferred second clear only clears such a key, so a
--- player's own change made in the meantime is kept. Nil stored or no default: false.
--- @param key string
--- @param row table|nil  The row or font-row part whose dbKey is key (nil for a split colour key)
--- @param getStored function  key -> stored value
--- @return boolean
local function OptionStoredIsDefault(key, row, getStored)
    local def = OptionDefault(key, row)
    local stored = getStored(key)
    if stored == nil then return false end
    if def == nil then
        return ShownMatchesCodeDefault(row, key) == true
    end
    if type(row) == "table" and type(row.normalize) == "function" then
        stored, def = row.normalize(stored), row.normalize(def)
    end
    return ValuesEqual(stored, def)
end

--- The value the active profile stores for key, with no default fallback (nil when unset).
--- @param key string
--- @return any
local function OptionStoredValue(key)
    if type(key) ~= "string" then return nil end
    if addon.DATABASE and not _G[addon.DATABASE] then return nil end
    local profile = addon.GetActiveProfile and addon.GetActiveProfile()
    if type(profile) ~= "table" then return nil end
    return profile[key]
end

--- Whether a row's setting is changed from its default in the active profile. A font row is
--- changed when any of its parts is. A row with no default found is never changed. A row or
--- part may carry normalize(value) -> shown value, used on both sides of the comparison.
--- @param row table
--- @param getStored function|nil  key -> stored value; default OptionStoredValue
--- @return boolean
local function OptionIsChanged(row, getStored)
    if not OptionMarkable(row) then return false end
    getStored = getStored or OptionStoredValue
    if row.type == "fontRow" then
        for _, slot in ipairs(FONT_ROW_PARTS) do
            local part = type(row.parts) == "table" and row.parts[slot]
            if type(part) == "table" and type(part.dbKey) == "string"
                and KeyChanged(part.dbKey, part, getStored, false) then
                return true
            end
        end
        return false
    end
    return KeyChanged(row.dbKey, row, getStored, row.type == "color")
end

--- The split <key>R/G/B/A keys a colour row saves through, when the defaults tables know them.
--- @param key string
--- @return table  Key names (empty when the colour is saved as one table)
local function OptionSplitColorKeys(key)
    local out = {}
    if type(key) ~= "string" or TableDefault(key .. "R") == nil then return out end
    for _, suffix in ipairs(SPLIT_SUFFIXES) do out[#out + 1] = key .. suffix end
    return out
end

addon.OptionDefault                    = OptionDefault
addon.OptionMarkable                   = OptionMarkable
addon.OptionIsChanged                  = OptionIsChanged
addon.OptionStoredValue                = OptionStoredValue
addon.OptionSplitColorKeys             = OptionSplitColorKeys
addon.OptionStoredIsDefault            = OptionStoredIsDefault

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
