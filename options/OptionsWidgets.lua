--[[
    Horizon Suite - Focus - Options Widgets
    Reusable widget library: toggle, slider, dropdown, color swatch, search input, reorder list, section card/header.
    Modern Cinematic styling. All widgets expose :Refresh() and .searchText for search indexing.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L

-- Design tokens (Cinematic, Modern, Minimalistic). Panel can override FontPath/HeaderSize via SetDef.
local Def = {
    Padding = 18,
    OptionGap = 18,
    SectionGap = 30,
    CardPadding = 18,
    CardBottomPadding = 26,
    BorderEdge = 1,
    CornerRadius = 8,
    LabelSize = 13,
    SectionSize = 11,
    FontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF",
    HeaderSize = addon.HEADER_SIZE or 16,
    TextColorNormal = { 1, 1, 1 },
    TextColorHighlight = { 0.72, 0.8, 0.95, 1 },
    TextColorLabel = { 0.84, 0.84, 0.88 },
    TextColorSection = { 0.58, 0.64, 0.74 },
    TextColorTitleBar = { 0.9, 0.92, 0.96, 1 },
    SectionCardBg = { 0.09, 0.09, 0.11, 0.96 },
    SectionCardBorder = { 0.18, 0.2, 0.24, 0.35 },
    SectionCardHeaderHighlight = { 0.96, 0.97, 0.99, 0.015 },
    AccentColor = { 0.48, 0.58, 0.82, 0.9 },
    DividerColor = { 0.35, 0.4, 0.5, 0.25 },
    InputBg = { 0.07, 0.07, 0.1, 0.96 },
    InputBorder = { 0.2, 0.22, 0.28, 0.3 },
    TrackOff = { 0.14, 0.14, 0.18, 0.95 },
    TrackOn = { 0.48, 0.58, 0.82, 0.85 },
    ThumbColor = { 1, 1, 1, 0.98 },
    WidgetFontFlags = "OUTLINE",
    WidgetTextShadow = false,
}
Def.BorderColor = Def.SectionCardBorder
if addon.StandardFont then
    Def.FontPath = addon.StandardFont
end

local _activeColorPickerCallbacks = nil  -- { setKeyVal, notify, tex } when our picker is open
local _hexBoxHooked = false

function _G.OptionsWidgets_SetDef(overrides)
    if not overrides then return end
    for k, v in pairs(overrides) do Def[k] = v end
end
addon.OptionsWidgetsDef = Def

-- Class color lookup: returns {r, g, b} for player class, nil if unavailable.
local function GetClassColorRaw()
    local _, classFile = UnitClass("player")
    if not classFile then return nil end
    local cc = C_ClassColor and C_ClassColor.GetClassColor(classFile)
    if cc then return { cc.r, cc.g, cc.b } end
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if rc then return { rc.r, rc.g, rc.b } end
    return nil
end

--- Returns player class RGB when the module's class-colour DB toggle is enabled, else nil.
--- @param moduleKey string Lowercase module id: dashboard, vista, insight, essence, focus, presence, cache
--- @return table|nil { r, g, b } with components in 0–1
function addon.GetModuleClassColor(moduleKey)
    if type(moduleKey) ~= "string" or moduleKey == "" then return nil end
    local cap = moduleKey:sub(1, 1):upper() .. moduleKey:sub(2)
    local dbKey = "classColor" .. cap
    if not (addon.GetDB and addon.GetDB(dbKey, false)) then
        return nil
    end
    return GetClassColorRaw()
end

-- Returns {r, g, b} when dashboard/options panel should use class colour, nil otherwise.
function addon.GetOptionsClassColor()
    return addon.GetModuleClassColor("dashboard")
end

-- Returns {r, g, b} when Vista should use class colour, nil otherwise.
function addon.GetVistaClassColor()
    return addon.GetModuleClassColor("vista")
end

local SetTextColor = addon.SetTextColor or function(obj, color)
    if not color or not obj then return end
    obj:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local DEFAULT_FALLBACK_FONT = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"

-- Registry of widget FontStrings that were set with nil flags (i.e. defer to Def.WidgetFontFlags).
-- Populated by SetSafeFont; consumed by OptionsWidgets_RefreshFonts.
local widgetFontRegistry = {}

--- Re-apply current Def font path and WidgetFontFlags to all registered widget FontStrings.
--- Call after OptionsWidgets_SetDef changes WidgetFontFlags or FontPath.
function _G.OptionsWidgets_RefreshFonts()
    local path = Def.FontPath or DEFAULT_FALLBACK_FONT
    local flags = Def.WidgetFontFlags or "OUTLINE"
    for _, e in ipairs(widgetFontRegistry) do
        local fs = e.fs
        if fs and fs.SetFont then
            pcall(function() fs:SetFont(path, e.size, flags) end)
            if addon.Dashboard_ApplyTextShadow then addon.Dashboard_ApplyTextShadow(fs) end
        end
    end
end

local function SetSafeFont(fs, path, size, flags)
    if not fs then return false end
    path = path or Def.FontPath or DEFAULT_FALLBACK_FONT
    local effFlags = flags
    if effFlags == nil then
        effFlags = Def.WidgetFontFlags or "OUTLINE"
        -- Register so OptionsWidgets_RefreshFonts can re-apply when WidgetFontFlags changes.
        widgetFontRegistry[#widgetFontRegistry + 1] = { fs = fs, size = size }
    end
    local ok = fs:SetFont(path, size, effFlags)
    if not ok then
        if path ~= DEFAULT_FALLBACK_FONT then
            ok = fs:SetFont(DEFAULT_FALLBACK_FONT, size, effFlags)
        end
        if not ok then
            ok = fs:SetFont("Fonts\\FRIZQT__.TTF", size, effFlags)
        end
    end
    if ok and addon.Dashboard_ApplyTextShadow then
        addon.Dashboard_ApplyTextShadow(fs)
    end
    return ok
end

local easeOut = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end
local TOGGLE_ANIM_DUR = 0.15

-- Apply optional hover tooltip to option rows (desc = inline; tooltip = hover detail).
local function ApplyOptionTooltip(frame, tooltip)
    if not tooltip or tooltip == "" then return end
    local tt = type(tooltip) == "function" and tooltip() or tooltip
    if not tt or tt == "" then return end
    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(tt, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function ApplyRowHoverHighlight(row)
    if not row then return end
    local hiBg = row:CreateTexture(nil, "BACKGROUND", nil, -7) -- Behind track/thumb backgrounds
    hiBg:SetPoint("TOPLEFT", row, "TOPLEFT", -18, 5)
    hiBg:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 18, -5)
    hiBg:SetColorTexture(1, 1, 1, 0.025)
    hiBg:Hide()
    
    row:EnableMouse(true)
    row:HookScript("OnEnter", function()
        -- Fade in
        UIFrameFadeIn(row.hoverHighlightFrame or hiBg, 0.15, 0, 1)
        hiBg:Show()
    end)
    row:HookScript("OnLeave", function()
        hiBg:Hide()
    end)
end

-- Rounded pill toggle: 48x22 track with inset for softer look, 18px thumb. On = accent fill, Off = dark.
local TOGGLE_TRACK_W, TOGGLE_TRACK_H = 48, 22
local TOGGLE_INSET = 2
local TOGGLE_THUMB_SIZE = 18

function _G.OptionsWidgets_CreateToggleSwitch(parent, labelText, description, get, set, disabledFn, tooltip)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(32)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local trackW, trackH = TOGGLE_TRACK_W, TOGGLE_TRACK_H
    local thumbSize = TOGGLE_THUMB_SIZE
    local track = CreateFrame("Frame", nil, row)
    track:SetSize(trackW, trackH)
    track:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    local trackBg = track:CreateTexture(nil, "BACKGROUND")
    trackBg:SetPoint("TOPLEFT", track, "TOPLEFT", TOGGLE_INSET, -TOGGLE_INSET)
    trackBg:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", -TOGGLE_INSET, TOGGLE_INSET)
    trackBg:SetColorTexture(Def.TrackOff[1], Def.TrackOff[2], Def.TrackOff[3], Def.TrackOff[4])
    local trackFill = track:CreateTexture(nil, "ARTWORK")
    trackFill:SetPoint("TOPLEFT", track, "TOPLEFT", TOGGLE_INSET, -TOGGLE_INSET)
    trackFill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", TOGGLE_INSET, TOGGLE_INSET)
    trackFill:SetWidth(0)
    trackFill:SetColorTexture(Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4])
    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(thumbSize, thumbSize)
    thumb:SetColorTexture(Def.ThumbColor[1], Def.ThumbColor[2], Def.ThumbColor[3], Def.ThumbColor[4])
    thumb:SetPoint("CENTER", track, "LEFT", TOGGLE_INSET + thumbSize/2, 0)

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    label:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -(trackW + 12), 0)
    label:SetWordWrap(true)

    local desc = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", track, "LEFT", -12, 0)
    desc:SetWordWrap(true)

    -- Measure actual description height and adjust row to prevent overlap (desc hidden; in tooltip)
    row._desc = desc
    row._baseHeight = 32
    local function updateRowHeight()
        local descH = desc:GetStringHeight() or 0
        local labelH = label:GetStringHeight() or 0
        local neededH = labelH + 2 + descH + 4
        local h = math.max(row._baseHeight, neededH)
        row:SetHeight(h)
        row._measuredHeight = h
    end
    -- Defer measurement to after layout
    C_Timer.After(0, updateRowHeight)

    local btn = CreateFrame("Button", nil, row)
    btn:SetAllPoints(track)

    row.thumbPos = get() and 1 or 0
    row.animStart = nil
    row.animFrom = nil
    row.animTo = nil

    local fillW = trackW - 2 * TOGGLE_INSET
    local thumbTravel = fillW - thumbSize
    local function updateVisuals(t)
        -- Keep fill colour in sync with Def.TrackOn every paint. ApplyOptionsClassColor() may run
        -- inside set() (e.g. batch class colours) before the slide animation; skipping Refresh() on
        -- the clicked row avoids snapping the thumb but must still pick up the new "on" tint here.
        trackFill:SetColorTexture(Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4] or 0.85)
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", track, "LEFT", TOGGLE_INSET + thumbSize/2 + t * thumbTravel, 0)
        trackFill:SetWidth(t * fillW)
    end

    local function applyDisabledVisuals()
        local dis = disabledFn and disabledFn() == true
        if dis then
            label:SetAlpha(0.45)
            desc:SetAlpha(0.45)
            track:SetAlpha(0.45)
        else
            label:SetAlpha(1)
            desc:SetAlpha(1)
            track:SetAlpha(1)
        end
    end

    local function toggleOnUpdate()
        if not row.animStart then
            track:SetScript("OnUpdate", nil)
            return
        end
        local elapsed = GetTime() - row.animStart
        if elapsed >= TOGGLE_ANIM_DUR then
            row.thumbPos = row.animTo
            row.animStart = nil
            updateVisuals(row.thumbPos)
            track:SetScript("OnUpdate", nil)
            return
        end
        row.thumbPos = row.animFrom + (row.animTo - row.animFrom) * easeOut(elapsed / TOGGLE_ANIM_DUR)
        updateVisuals(row.thumbPos)
    end

    btn:SetScript("OnClick", function()
        if disabledFn and disabledFn() == true then return end
        if row.animStart then return end  -- Debounce: ignore clicks during animation (prevents double-click reverting)
        local next = not get()
        set(next)
        row.animStart = GetTime()
        row.animFrom = row.thumbPos
        row.animTo = next and 1 or 0
        track:SetScript("OnUpdate", toggleOnUpdate)
    end)

    function row:Refresh()
        local on = get()
        row.thumbPos = on and 1 or 0
        row.animStart = nil
        track:SetScript("OnUpdate", nil)
        trackFill:SetColorTexture(Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4])
        updateVisuals(row.thumbPos)
        applyDisabledVisuals()
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = (description or "") .. (description and tooltip and "\n\n" or "") .. (tooltip or "")
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

--- Create a flat-styled action button with background, border, and hover state.
--- @param parent table Parent frame
--- @param labelText string Button label
--- @param onClick function Callback on click
--- @param opts table|nil Optional; opts.width, opts.height (default 100x22)
--- @return table Button frame (caller sets position)
function _G.OptionsWidgets_CreateButton(parent, labelText, onClick, opts)
    opts = opts or {}
    local width = opts.width or 100
    local height = opts.height or 22

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width, height)

    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
    btnBg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
    btnBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])

    addon.CreateBorder(btn, Def.InputBorder)

    local hi = btn:CreateTexture(nil, "HIGHLIGHT")
    hi:SetAllPoints(btn)
    hi:SetColorTexture(1, 1, 1, 0.06)

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lbl, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(lbl, Def.TextColorLabel)
    lbl:SetText(labelText or "")
    lbl:SetPoint("CENTER", btn, "CENTER", 0, 0)

    btn:SetScript("OnClick", function()
        if onClick then onClick() end
    end)
    btn:SetScript("OnEnter", function()
        SetTextColor(lbl, Def.TextColorHighlight)
    end)
    btn:SetScript("OnLeave", function()
        SetTextColor(lbl, Def.TextColorLabel)
    end)

    ApplyOptionTooltip(btn, opts.tooltip)
    return btn
end

-- Slider: slim rounded track + draggable thumb + numeric readout
local SLIDER_TRACK_HEIGHT = 6
local SLIDER_THUMB_SIZE = 14
local SLIDER_TRACK_INSET = 2
function _G.OptionsWidgets_CreateSlider(parent, labelText, description, get, set, minVal, maxVal, disabledFn, step, tooltip)
    -- step: snapping increment (default 1 = integer). Use e.g. 0.1 for one decimal place.
    step = step or 1
    local decimals = 0
    if step < 1 then
        -- Determine display decimal places from step (e.g. 0.1 → 1, 0.05 → 2)
        local s = tostring(step)
        local dot = s:find("%.")
        decimals = dot and (#s - dot) or 0
    end
    local function snapToStep(v)
        if step <= 0 then return v end
        return math.floor(v / step + 0.5) * step
    end
    local function formatValue(v)
        if decimals > 0 then
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring((v >= 0) and math.floor(v + 0.5) or -math.floor(-v + 0.5))
    end
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(34)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    label:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -60, 0)
    local desc = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", row, "RIGHT", -60, 0)
    desc:SetWordWrap(true)

    local trackWidth = 180
    local track = CreateFrame("Frame", nil, row)
    track:SetSize(trackWidth, SLIDER_TRACK_HEIGHT)
    track:SetPoint("RIGHT", row, "RIGHT", -52, 0)
    local trackBg = track:CreateTexture(nil, "BACKGROUND")
    trackBg:SetPoint("TOPLEFT", track, "TOPLEFT", SLIDER_TRACK_INSET, -SLIDER_TRACK_INSET)
    trackBg:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", -SLIDER_TRACK_INSET, SLIDER_TRACK_INSET)
    trackBg:SetColorTexture(Def.TrackOff[1], Def.TrackOff[2], Def.TrackOff[3], Def.TrackOff[4])
    local trackFill = track:CreateTexture(nil, "ARTWORK")
    trackFill:SetPoint("TOPLEFT", track, "TOPLEFT", SLIDER_TRACK_INSET, -SLIDER_TRACK_INSET)
    trackFill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", SLIDER_TRACK_INSET, SLIDER_TRACK_INSET)
    trackFill:SetColorTexture(Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4])

    local thumb = CreateFrame("Button", nil, track)
    thumb:SetSize(SLIDER_THUMB_SIZE, SLIDER_THUMB_SIZE)
    thumb:SetPoint("CENTER", track, "LEFT", 0, 0)
    local thumbTex = thumb:CreateTexture(nil, "BACKGROUND")
    thumbTex:SetAllPoints(thumb)
    thumbTex:SetColorTexture(Def.ThumbColor[1], Def.ThumbColor[2], Def.ThumbColor[3], Def.ThumbColor[4])

    local editWrap = CreateFrame("Frame", nil, row)
    editWrap:SetSize(44, 20)
    editWrap:SetPoint("LEFT", track, "RIGHT", 8, 0)
    local editBg = editWrap:CreateTexture(nil, "BACKGROUND")
    editBg:SetAllPoints(editWrap)
    editBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
    local bt, bb, bl, br = addon.CreateBorder(editWrap, Def.InputBorder)
    local function setEditBorderColor(c)
        for _, tex in ipairs({ bt, bb, bl, br }) do
            if tex then tex:SetColorTexture(c[1], c[2], c[3], c[4] or 1) end
        end
    end

    -- Pre-declare so edit scripts and drag handler can reference it before the body is assigned.
    local updateFromValue

    local edit = CreateFrame("EditBox", nil, editWrap)
    edit:SetPoint("TOPLEFT", editWrap, "TOPLEFT", 4, 0)
    edit:SetPoint("BOTTOMRIGHT", editWrap, "BOTTOMRIGHT", -4, 0)
    edit:SetMaxLetters(7)   -- allow e.g. "-200" (4 chars) plus some headroom
    -- Do NOT use SetNumeric(true) — it blocks negative numbers.
    -- We validate manually in OnEnterPressed / OnEditFocusLost.
    edit:SetAutoFocus(false)
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    edit:SetScript("OnEscapePressed", function()
        updateFromValue(get())
        edit:ClearFocus()
    end)
    edit:SetScript("OnEditFocusGained", function()
        if disabledFn and disabledFn() == true then edit:ClearFocus(); return end
        setEditBorderColor(Def.AccentColor)
    end)
    edit:SetScript("OnEditFocusLost", function()
        setEditBorderColor(Def.InputBorder)
        if disabledFn and disabledFn() == true then return end
        local v = tonumber(edit:GetText())
        if v ~= nil then
            v = snapToStep(math.max(minVal, math.min(maxVal, v)))
            set(v)
            updateFromValue(v)
        else
            updateFromValue(get())
        end
    end)
    edit:SetScript("OnEnterPressed", function()
        if disabledFn and disabledFn() == true then edit:ClearFocus(); return end
        local v = tonumber(edit:GetText())
        if v ~= nil then
            v = snapToStep(math.max(minVal, math.min(maxVal, v)))
            set(v)
            updateFromValue(v)
        else
            updateFromValue(get())
        end
        edit:ClearFocus()
    end)
    -- OnTextChanged intentionally omitted: would call set() on every keystroke,
    -- triggering heavy callbacks (refreshAllScaling → FullLayout) per character.

    local function valueToNorm(v)
        if maxVal <= minVal then return 0 end
        return (v - minVal) / (maxVal - minVal)
    end
    local function normToValue(n)
        return minVal + n * (maxVal - minVal)
    end

    local fillWidth = trackWidth - 2 * SLIDER_TRACK_INSET
    local thumbTravel = fillWidth - SLIDER_THUMB_SIZE

    -- Now assign the body — all closures above that captured the upvalue slot will see this.
    updateFromValue = function(v)
        v = math.max(minVal, math.min(maxVal, v))
        local n = valueToNorm(v)
        thumb:ClearAllPoints()
        thumb:SetPoint("CENTER", track, "LEFT", SLIDER_TRACK_INSET + SLIDER_THUMB_SIZE/2 + n * thumbTravel, 0)
        trackFill:SetWidth(n * fillWidth)
        edit:SetText(formatValue(v))
    end

    local dragging = false
    local startNorm, startX
    thumb:SetScript("OnMouseDown", function(_, btn)
        if btn ~= "LeftButton" then return end
        if disabledFn and disabledFn() == true then return end
        dragging = true
        startNorm = valueToNorm(get())
        local scale = track:GetEffectiveScale()
        startX = GetCursorPosition() / scale
        local lastCommittedSnapped = snapToStep(normToValue(startNorm))
        thumb:GetParent():SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then
                thumb:GetParent():SetScript("OnUpdate", nil)
                dragging = false
                -- Commit final value on release so the DB is up-to-date.
                local finalV = snapToStep(math.max(minVal, math.min(maxVal, normToValue(startNorm))))
                if finalV ~= lastCommittedSnapped then
                    set(finalV)
                end
                return
            end
            local x = GetCursorPosition() / scale
            local delta = (x - startX) / fillWidth
            local n = math.max(0, math.min(1, startNorm + delta))
            local v = normToValue(n)
            -- Update visual every frame for smooth thumb movement.
            updateFromValue(v)
            -- Only call set() when the snapped value changes.
            local snappedV = snapToStep(v)
            if snappedV ~= lastCommittedSnapped then
                lastCommittedSnapped = snappedV
                set(snappedV)
            end
            startNorm = n
            startX = x
        end)
    end)

    local function applyDisabledVisual()
        local dis = disabledFn and disabledFn() == true
        local alpha = dis and 0.35 or 1
        label:SetAlpha(alpha)
        desc:SetAlpha(alpha)
        track:SetAlpha(alpha)
        editWrap:SetAlpha(alpha)
        if dis then
            edit:EnableMouse(false)
        else
            edit:EnableMouse(true)
        end
    end

    function row:Refresh()
        trackFill:SetColorTexture(Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4])
        updateFromValue(get())
        applyDisabledVisual()
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = (description or "") .. (description and tooltip and "\n\n" or "") .. (tooltip or "")
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Rounded backdrop for section cards and dropdown popups (uses Blizzard edge file for modern look).
local SECTION_CARD_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
}

-- Sentinel stored in DB for "use global font" per-element pickers (must match OptionsData FONT_USE_GLOBAL / Vista GLOBAL_SENTINEL).
local DROPDOWN_FONT_GLOBAL_SENTINEL = "__global__"

-- Custom dropdown: button + popup list (no UIDropDownMenuTemplate)
-- When searchable is true, adds an EditBox above the list to filter options by name (e.g. font dropdown).
-- resetButton: optional table { onClick, tooltip } — adds a small reset-arrow icon button to the left of the dropdown.
-- fontPreviewInList: when true, each list row (and closed button when a font path is selected) uses ResolveFontPath(value) for SetFont.
function _G.OptionsWidgets_CreateCustomDropdown(parent, labelText, description, options, get, set, displayFn, searchable, disabledFn, tooltip, resetButton, fontPreviewInList)
    local labelFn = type(labelText) == "function" and labelText or nil
    local resolvedLabel = labelFn and labelFn() or labelText
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(34)
    local searchText = (resolvedLabel or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local DROPDOWN_BTN_WIDTH = 180
    local RESET_BTN_SIZE = 24
    local RESET_GAP = 6
    local rightInset = DROPDOWN_BTN_WIDTH + 12
    if resetButton and resetButton.onClick then
        rightInset = rightInset + RESET_BTN_SIZE + RESET_GAP
    end

    local btn = CreateFrame("Button", nil, row)
    btn:SetHeight(26)
    btn:SetWidth(DROPDOWN_BTN_WIDTH)
    btn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    btn:SetPoint("TOP", row, "CENTER", 0, 13)
    btn:SetPoint("BOTTOM", row, "CENTER", 0, -13)

    if resetButton and resetButton.onClick then
        local resetBtn = CreateFrame("Button", nil, row)
        resetBtn:SetSize(RESET_BTN_SIZE, RESET_BTN_SIZE)
        resetBtn:SetPoint("RIGHT", btn, "LEFT", -RESET_GAP, 0)
        resetBtn:SetFrameLevel(row:GetFrameLevel() + 10)
        resetBtn:EnableMouse(true)
        resetBtn:SetScript("OnClick", function()
            resetButton.onClick()
        end)
        local resetIcon = resetBtn:CreateTexture(nil, "OVERLAY")
        resetIcon:SetAllPoints(resetBtn)
        resetIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        resetIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
        resetBg:SetAllPoints(resetBtn)
        resetBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
        if addon.CreateBorder then addon.CreateBorder(resetBtn, Def.InputBorder) end
        local resetHi = resetBtn:CreateTexture(nil, "HIGHLIGHT")
        resetHi:SetAllPoints(resetBtn)
        resetHi:SetColorTexture(1, 1, 1, 0.15)
        local resetTt = (resetButton.tooltip or (L and L["OPTIONS_FOCUS_RESET_SPACING"])) or "Reset spacing"
        resetBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(resetBtn, "ANCHOR_RIGHT")
            GameTooltip:SetText(resetTt, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(resolvedLabel or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    label:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -rightInset, 0)
    label:SetWordWrap(true)

    local desc = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    desc:SetWordWrap(true)

    row._desc = desc

    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
    btnBg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
    btnBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])

    addon.CreateBorder(btn, Def.InputBorder)

    local btnHi = btn:CreateTexture(nil, "HIGHLIGHT")
    btnHi:SetAllPoints(btn)
    btnHi:SetColorTexture(1, 1, 1, 0.06)

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(btnText, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(btnText, Def.TextColorLabel)
    btnText:SetPoint("LEFT", btn, "LEFT", 8, 0)
    btnText:SetPoint("RIGHT", btn, "RIGHT", -24, 0)
    btnText:SetJustifyH("LEFT")

    local chevron = btn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(chevron, Def.FontPath, Def.LabelSize, nil)
    SetTextColor(chevron, Def.TextColorSection)
    chevron:SetText("v")
    chevron:SetPoint("RIGHT", btn, "RIGHT", -6, 0)

    local list = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    list:SetFrameStrata("TOOLTIP")
    list:Hide()
    list:SetSize(200, 1)
    list:SetBackdrop(SECTION_CARD_BACKDROP)
    list:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    list:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    local searchEdit
    if searchable then
        searchEdit = CreateFrame("EditBox", nil, list)
        searchEdit:SetHeight(26)
        searchEdit:SetPoint("TOPLEFT", list, "TOPLEFT", 6, -6)
        searchEdit:SetPoint("TOPRIGHT", list, "TOPRIGHT", -6, 0)
        searchEdit:SetAutoFocus(false)
        SetSafeFont(searchEdit, Def.FontPath, Def.LabelSize, nil)
        searchEdit:SetTextInsets(8, 8, 0, 0)
        local tc = Def.TextColorLabel
        searchEdit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
        local searchBg = searchEdit:CreateTexture(nil, "BACKGROUND")
        searchBg:SetAllPoints(searchEdit)
        searchBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
        local ph = searchEdit:CreateFontString(nil, "OVERLAY")
        SetSafeFont(ph, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(ph, Def.TextColorSection)
        ph:SetText(L["OPTIONS_FOCUS_SEARCH_FONTS"] or "Search fonts...")
        ph:SetPoint("LEFT", searchEdit, "LEFT", 8, 0)
        ph:SetJustifyH("LEFT")
        searchEdit.placeholder = ph
        searchEdit:SetScript("OnEditFocusGained", function() if ph then ph:Hide() end end)
        searchEdit:SetScript("OnEditFocusLost", function() if ph and searchEdit:GetText() == "" then ph:Show() end end)
    end

    local scrollFrame = CreateFrame("ScrollFrame", nil, list)
    if searchable then
        scrollFrame:SetPoint("TOPLEFT", searchEdit, "BOTTOMLEFT", 0, -4)
        scrollFrame:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -4, 4)
    else
        scrollFrame:SetAllPoints(list)
    end

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(1)
    scrollChild:SetHeight(1)

    -- Ensure the dropdown list scrolls internally and doesn't forward wheel events to the parent panel.
    scrollFrame:EnableMouseWheel(true)
    list:EnableMouseWheel(true)
    if not InCombatLockdown() then
        scrollFrame:SetPropagateMouseMotion(false)
        list:SetPropagateMouseMotion(false)
    end

    -- Row height for open list; updated in populate when fontPreviewInList (taller rows for glyph clearance).
    local listRowHeight = 22

    local function consumeWheel() end
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        if not list:IsShown() then return end
        if self.StopMovingOrSizing then self:StopMovingOrSizing() end -- no-op consume
        local step = listRowHeight * 3
        local cur = self:GetVerticalScroll() or 0
        local childH = (scrollChild and scrollChild:GetHeight()) or 0
        local frameH = self:GetHeight() or 0
        local maxScroll = math.max(0, childH - frameH)
        local new = math.max(0, math.min(cur - delta * step, maxScroll))
        self:SetVerticalScroll(new)
    end)
    -- Capture mouse wheel on the outer list too, so the options panel underneath doesn't scroll.
    list:SetScript("OnMouseWheel", function() consumeWheel() end)

    -- Keep our own list of option buttons; GetNumChildren()/GetChildren() is unreliable.
    local optionButtons = {}

    local catch = CreateFrame("Button", "HorizonSuite_DropdownCatch" .. tostring(row):gsub("table: ", ""), UIParent)
    catch:SetFrameStrata("TOOLTIP")
    catch:SetAllPoints(UIParent)
    catch:Hide()

    -- Allow ESC to close an open dropdown.
    -- WoW's CloseSpecialWindows() hides frames listed in UISpecialFrames.
    catch.__horizonDropdownCatch = true
    if _G.UISpecialFrames then
        local n = catch:GetName()
        local exists = false
        for i = 1, #_G.UISpecialFrames do
            if _G.UISpecialFrames[i] == n then exists = true break end
        end
        if not exists then tinsert(_G.UISpecialFrames, n) end
    end

    local function closeList()
        if addon._OnDropdownClosed then addon._OnDropdownClosed(closeList) end
        if searchable and searchEdit and searchEdit:HasFocus() then
            searchEdit:ClearFocus()
        end
        list:Hide()
        catch:Hide()
    end
    catch:SetScript("OnClick", closeList)
    catch:SetScript("OnHide", function()
        -- Keep list in sync if the catch is hidden via ESC.
        if list:IsShown() then
            if addon._OnDropdownClosed then addon._OnDropdownClosed(closeList) end
            list:Hide()
        end
    end)

    -- Must be declared before setValue (Lua 5.1: later `local function` is not visible to earlier closures).
    local function isDisabled()
        return disabledFn and disabledFn() == true
    end

    local function applyDisabledVisuals()
        local dis = isDisabled()
        if dis then
            btn:Disable()
            SetTextColor(btnText, Def.TextColorSection)
            chevron:SetAlpha(0.5)
            btnBg:SetAlpha(0.6)
        else
            btn:Enable()
            SetTextColor(btnText, Def.TextColorLabel)
            chevron:SetAlpha(1)
            btnBg:SetAlpha(1)
        end
    end

    local function applyBtnTextFontForValue(value)
        if not fontPreviewInList then return end
        if value == nil or value == "" or value == DROPDOWN_FONT_GLOBAL_SENTINEL then
            SetSafeFont(btnText, Def.FontPath, Def.LabelSize, nil)
        else
            local path = (addon.ResolveFontPath and addon.ResolveFontPath(value)) or value
            SetSafeFont(btnText, path, Def.LabelSize, nil)
        end
    end

    local function setValue(value, display)
        set(value)
        btnText:SetText(display or tostring(value))
        applyBtnTextFontForValue(value)
        applyDisabledVisuals()
        closeList()
    end

    local function normalizeOptions(opts)
        if type(opts) ~= "table" then return {} end
        -- Rebuild into a dense array.
        local out = {}
        for k, v in pairs(opts) do
            if type(k) == "number" and type(v) == "table" then
                -- Expected shape: { name, value [, disabled] } — [3] truthy = not selectable (grey label, click closes list only).
                out[#out + 1] = v
            elseif type(k) == "string" then
                -- Map shape: name -> value
                out[#out + 1] = { k, v }
            end
        end
        table.sort(out, function(a, b)
            local aVal = a and a[2]
            local bVal = b and b[2]
            if aVal == "__global__" then return true end
            if bVal == "__global__" then return false end
            return tostring(a and a[1] or "") < tostring(b and b[1] or "")
        end)
        return out
    end

    local SEARCH_BOX_HEIGHT = searchable and 36 or 0

    local function populate()
        list:SetParent(UIParent)
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)

        local fullOpts = normalizeOptions((type(options) == "function" and options()) or options or {})
        local opts = fullOpts
        if searchable and searchEdit then
            local filterText = searchEdit:GetText()
            if type(filterText) == "string" and filterText ~= "" then
                local lower = filterText:lower()
                opts = {}
                for _, opt in ipairs(fullOpts) do
                    local name = opt and opt[1] or ""
                    if name:lower():find(lower, 1, true) then
                        opts[#opts + 1] = opt
                    end
                end
            end
        end

        local num = #opts

        local rowH = fontPreviewInList and 24 or 22
        listRowHeight = rowH
        local maxHeight = 330
        local totalHeight = num * rowH

        list:SetWidth(btn:GetWidth())
        list:SetHeight(SEARCH_BOX_HEIGHT + math.min(totalHeight, maxHeight))
        scrollChild:SetWidth(btn:GetWidth())
        scrollChild:SetHeight(math.max(totalHeight, 1))
        scrollFrame:SetVerticalScroll(0)

        if searchable and searchEdit then
            searchEdit:Show()
        end

        local lblColor = Def.TextColorLabel
        for i = 1, num do
            local b = optionButtons[i]
            if not b then
                b = CreateFrame("Button", nil, scrollChild)
                b:SetHeight(rowH)

                local tb = b:CreateFontString(nil, "OVERLAY")
                SetSafeFont(tb, Def.FontPath, Def.LabelSize, nil)
                tb:SetPoint("LEFT", b, "LEFT", 8, 0)
                tb:SetJustifyV("MIDDLE")
                tb:SetJustifyH("LEFT")
                b.text = tb

                local hi = b:CreateTexture(nil, "BACKGROUND")
                hi:SetAllPoints(b)
                hi:SetColorTexture(1, 1, 1, 0.06)
                hi:Hide()
                b._dropdownHi = hi

                optionButtons[i] = b
            end
            b:SetHeight(rowH)
        end

        for i = 1, num do
            local opt = opts[i]
            local name = opt and opt[1]
            local value = opt and opt[2]
            local rowDisabled = opt and opt[3] == true
            local b = optionButtons[i]
            local hi = b._dropdownHi

            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * rowH)
            b:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -(i - 1) * rowH)

            if fontPreviewInList then
                if value == nil or value == "" or value == DROPDOWN_FONT_GLOBAL_SENTINEL then
                    SetSafeFont(b.text, Def.FontPath, Def.LabelSize, nil)
                else
                    local path = (addon.ResolveFontPath and addon.ResolveFontPath(value)) or value
                    SetSafeFont(b.text, path, Def.LabelSize, nil)
                end
                SetTextColor(b.text, rowDisabled and Def.TextColorSection or lblColor)
            elseif rowDisabled then
                SetTextColor(b.text, Def.TextColorSection)
            else
                SetTextColor(b.text, lblColor)
            end
            b.text:SetText(name)
            if rowDisabled then
                b:SetScript("OnEnter", function() end)
                b:SetScript("OnLeave", function() end)
                b:SetScript("OnClick", function()
                    closeList()
                end)
            else
                b:SetScript("OnEnter", function()
                    if hi then hi:Show() end
                end)
                b:SetScript("OnLeave", function()
                    if hi then hi:Hide() end
                end)
                b:SetScript("OnClick", function()
                    setValue(value, name)
                end)
            end
            b:Show()
        end

        for i = num + 1, #optionButtons do
            optionButtons[i]:Hide()
        end

        if addon._OnDropdownOpened then addon._OnDropdownOpened(closeList) end
        list:Show()
        catch:Show()
    end

    if searchable and searchEdit then
        searchEdit:SetScript("OnTextChanged", function() populate() end)
    end

    btn:SetScript("OnClick", function()
        if isDisabled() then return end
        if list:IsShown() then
            closeList()
            return
        end
        if searchable and searchEdit then
            searchEdit:SetText("")
            if searchEdit.placeholder then searchEdit.placeholder:Show() end
        end
        populate()
        if searchable and searchEdit then
            searchEdit:SetFocus()
        end
    end)

    function row:Refresh()
        if labelFn then
            local newLabel = labelFn()
            if newLabel then label:SetText(newLabel) end
        end
        local val = get()
        local opts = normalizeOptions((type(options) == "function" and options()) or options or {})

        for _, opt in ipairs(opts) do
            local optVal = opt[2]
            if optVal == val then
                btnText:SetText(opt[1])
                applyBtnTextFontForValue(val)
                applyDisabledVisuals()
                return
            end
        end

        if searchable and addon.ResolveFontPath then
            local valResolved = addon.ResolveFontPath(val) or val
            for _, opt in ipairs(opts) do
                local optVal = opt[2]
                local optResolved = addon.ResolveFontPath(optVal) or optVal
                if optResolved == valResolved then
                    if displayFn then
                        btnText:SetText(displayFn(optVal))
                    else
                        btnText:SetText(opt[1])
                    end
                    applyBtnTextFontForValue(val)
                    applyDisabledVisuals()
                    return
                end
            end
        end

        if displayFn then
            btnText:SetText(displayFn(val))
        elseif val == nil or val == "" then
            btnText:SetText("")
        else
            btnText:SetText(tostring(val))
        end
        applyBtnTextFontForValue(val)
        applyDisabledVisuals()
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = (description or "") .. (description and tooltip and "\n\n" or "") .. (tooltip or "")
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Helper: get effective color from ColorPickerFrame, preferring HexBox if user typed hex (10.2.5+).
-- Returns r, g, b in 0-1 range. HexBox may contain "ff0000", "#ff0000", or "f00" (3-char shorthand).
local function GetColorPickerEffectiveRGB()
    if not ColorPickerFrame then return 0.5, 0.5, 0.5 end
    local content = ColorPickerFrame.Content
    local hexBox = content and content.HexBox
    if hexBox and hexBox.GetText then
        local raw = hexBox:GetText()
        if type(raw) == "string" and #raw > 0 then
            local hex = raw:gsub("^#", ""):gsub("%s+", "")
            if #hex >= 3 then
                if #hex == 3 then
                    hex = hex:gsub("(%x)(%x)(%x)", "%1%1%2%2%3%3")
                end
                hex = hex:sub(1, 6)
                while #hex < 6 do hex = hex .. "0" end
                local r = tonumber(hex:sub(1, 2), 16)
                local g = tonumber(hex:sub(3, 4), 16)
                local b = tonumber(hex:sub(5, 6), 16)
                if r and g and b then
                    return r / 255, g / 255, b / 255
                end
            end
        end
    end
    return ColorPickerFrame:GetColorRGB()
end

-- Sync hex box to picker visual and apply color (live update when user types). Only runs when our picker is open.
local function SyncHexBoxToPicker()
    if not ColorPickerFrame:IsVisible() or not _activeColorPickerCallbacks then return end
    local content = ColorPickerFrame.Content
    local hexBox = content and content.HexBox
    if not hexBox or not hexBox.GetText then return end
    local raw = hexBox:GetText()
    if type(raw) ~= "string" or #raw < 3 then return end
    local hex = raw:gsub("^#", ""):gsub("%s+", "")
    if #hex < 3 then return end
    if #hex == 3 then hex = hex:gsub("(%x)(%x)(%x)", "%1%1%2%2%3%3") end
    hex = hex:sub(1, 6)
    while #hex < 6 do hex = hex .. "0" end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not r or not g or not b then return end
    r, g, b = r / 255, g / 255, b / 255
    local cp = content.ColorPicker
    local swatchCurrent = content.ColorSwatchCurrent
    if cp and cp.SetColorRGB then cp:SetColorRGB(r, g, b) end
    if swatchCurrent and swatchCurrent.SetColorTexture then swatchCurrent:SetColorTexture(r, g, b) end
    local cb = _activeColorPickerCallbacks
    if cb then
        cb.setKeyVal({ r, g, b })
        local texA = (cb.getAlpha and cb.getAlpha()) or 1
        if cb.tex then cb.tex:SetColorTexture(r, g, b, texA) end
        -- No notify during live hex typing; finishedFunc/cancelFunc will notify.
    end
end

local function EnsureHexBoxHooked()
    if _hexBoxHooked then return end
    local content = ColorPickerFrame and ColorPickerFrame.Content
    local hexBox = content and content.HexBox
    if not hexBox or not hexBox.SetScript then return end
    hexBox:SetScript("OnTextChanged", function()
        SyncHexBoxToPicker()
    end)
    -- Hide the "hex" label inside the box (it obstructs the UI)
    local function hideHexLabel()
        for i = 1, select("#", hexBox:GetRegions()) do
            local r = select(i, hexBox:GetRegions())
            if r and r.GetText and r.Hide then
                local t = r:GetText()
                if t and t:lower():find("hex") then
                    r:Hide()
                    return
                end
            end
        end
        local hash = hexBox.Hash
        if hash and hash.GetText and hash.Hide then
            local ok, t = pcall(function() return hash:GetText() end)
            if ok and t and t:lower():find("hex") then hash:Hide() end
        end
    end
    hideHexLabel()
    _hexBoxHooked = true
end

-- Color swatch row: label + clickable swatch (for colorMatrix/colorGroup in options panel).
-- defaultTbl: {r,g,b} or nil (nil => {0.5,0.5,0.5}). getTbl() returns current color or nil. setKeyVal({r,g,b}), notify() on change.
-- disabledFn: optional function() return boolean end; when true, greys out and disables the swatch.
function _G.OptionsWidgets_CreateColorSwatchRow(parent, anchor, labelText, defaultTbl, getTbl, setKeyVal, notify, disabledFn, hasAlpha, tooltip)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(280, 24)
    row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    local lab = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lab, Def.FontPath, Def.LabelSize, nil)
    lab:SetJustifyH("LEFT")
    SetTextColor(lab, Def.TextColorLabel)
    lab:SetText(labelText or "")
    lab:SetPoint("LEFT", row, "LEFT", 0, 0)
    local swatch = CreateFrame("Button", nil, row)
    swatch:SetSize(22, 18)
    swatch:SetPoint("LEFT", lab, "RIGHT", 10, 0)
    local tex = swatch:CreateTexture(nil, "BACKGROUND")
    local swInset = 1
    tex:SetPoint("TOPLEFT", swatch, "TOPLEFT", swInset, -swInset)
    tex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -swInset, swInset)
    addon.CreateBorder(swatch, Def.SectionCardBorder)
    swatch.tex = tex
    local def = defaultTbl and #defaultTbl >= 3 and defaultTbl or { 0.5, 0.5, 0.5 }
    function swatch:Refresh()
        local r, g, b, a = def[1], def[2], def[3], def[4] or 1
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and result[1] then
                r, g, b = result[1], result[2], result[3]
                if hasAlpha and type(result[4]) == "number" then a = result[4] end
            elseif type(result) == "number" then
                local rVal, gVal, bVal, aVal = getTbl()
                if type(rVal) == "number" and type(gVal) == "number" and type(bVal) == "number" then
                    r, g, b = rVal, gVal, bVal
                    if hasAlpha and type(aVal) == "number" then a = aVal end
                end
            end
        end
        if hasAlpha then
            tex:SetColorTexture(r, g, b, a)
        else
            tex:SetColorTexture(r, g, b, 1)
        end
    end
    swatch:SetScript("OnClick", function()
        if disabledFn and disabledFn() then return end
        if not ColorPickerFrame or not ColorPickerFrame.SetupColorPickerAndShow then return end
        local r, g, b, a = def[1], def[2], def[3], def[4] or 1
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and result[1] then
                r, g, b = result[1], result[2], result[3]
                if hasAlpha and type(result[4]) == "number" then a = result[4] end
            elseif type(result) == "number" then
                local rVal, gVal, bVal, aVal = getTbl()
                if type(rVal) == "number" and type(gVal) == "number" and type(bVal) == "number" then
                    r, g, b = rVal, gVal, bVal
                    if hasAlpha and type(aVal) == "number" then a = aVal end
                end
            end
        end
        addon._colorPickerLive = true
        _activeColorPickerCallbacks = { setKeyVal = setKeyVal, notify = notify, tex = tex }
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            a = hasAlpha and a or nil,
            opacity = hasAlpha and a or nil,
            hasOpacity = hasAlpha == true,
            swatchFunc = function()
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                if hasAlpha then
                    local na = (type(ColorPickerFrame.GetColorAlpha) == "function" and ColorPickerFrame:GetColorAlpha())
                               or (type(ColorPickerFrame.GetOpacity) == "function" and (1 - ColorPickerFrame:GetOpacity()))
                               or 1
                    setKeyVal({ nr, ng, nb, na })
                    tex:SetColorTexture(nr, ng, nb, na)
                else
                    setKeyVal({ nr, ng, nb })
                    tex:SetColorTexture(nr, ng, nb, 1)
                end
            end,
            cancelFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local p = ColorPickerFrame.previousValues
                if p and type(p.r) == "number" and type(p.g) == "number" and type(p.b) == "number" then
                    if hasAlpha then
                        -- modern WoW stores alpha as pv.a; legacy stored inverted pv.opacity
                        local oa = (type(p.a) == "number" and p.a)
                                   or (type(p.opacity) == "number" and (1 - p.opacity))
                                   or 1
                        setKeyVal({ p.r, p.g, p.b, oa })
                    else
                        setKeyVal({ p.r, p.g, p.b })
                    end
                elseif getTbl then
                    local res = getTbl()
                    if type(res) == "table" and res[1] then
                        setKeyVal(res)
                    end
                end
                swatch:Refresh()
                if notify then notify() end
            end,
            finishedFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                if hasAlpha then
                    local na = (type(ColorPickerFrame.GetColorAlpha) == "function" and ColorPickerFrame:GetColorAlpha())
                               or (type(ColorPickerFrame.GetOpacity) == "function" and (1 - ColorPickerFrame:GetOpacity()))
                               or 1
                    setKeyVal({ nr, ng, nb, na })
                    tex:SetColorTexture(nr, ng, nb, na)
                else
                    setKeyVal({ nr, ng, nb })
                    tex:SetColorTexture(nr, ng, nb, 1)
                end
                if notify then notify() end
            end,
        })
        EnsureHexBoxHooked()
    end)
    row.Refresh = function()
        swatch:Refresh()
        if disabledFn then
            local disabled = disabledFn()
            if disabled then
                swatch:Disable()
                lab:SetAlpha(0.5)
                swatch:SetAlpha(0.5)
            else
                swatch:Enable()
                lab:SetAlpha(1)
                swatch:SetAlpha(1)
            end
        end
    end
    row:Refresh()
    ApplyOptionTooltip(row, tooltip)
    return row
end

-- Compact inline swatch for color matrix cards: swatch on left, label on right (cleaner layout).
-- getTbl() returns {r,g,b} or nil; setKeyVal({r,g,b}) writes to DB.
function _G.OptionsWidgets_CreateMiniSwatch(parent, labelText, defaultTbl, getTbl, setKeyVal, notify, tooltip)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(90, 24)

    local swatch = CreateFrame("Button", nil, frame)
    swatch:SetSize(20, 20)
    swatch:SetPoint("LEFT", frame, "LEFT", 0, 0)
    local lab = frame:CreateFontString(nil, "OVERLAY")
    SetSafeFont(lab, Def.FontPath, 10, "")
    lab:SetJustifyH("LEFT")
    lab:SetTextColor(0.88, 0.88, 0.92, 1)
    lab:SetText(labelText or "")
    lab:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    lab:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    local tex = swatch:CreateTexture(nil, "BACKGROUND")
    tex:SetPoint("TOPLEFT", swatch, "TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -1, 1)
    local addon = _G.HorizonSuite
    if addon and addon.CreateBorder then
        addon.CreateBorder(swatch, Def.SectionCardBorder)
    end
    swatch.tex = tex

    local def = defaultTbl and #defaultTbl >= 3 and defaultTbl or { 0.5, 0.5, 0.5 }

    function swatch:Refresh()
        local r, g, b = def[1], def[2], def[3]
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and result[1] then
                r, g, b = result[1], result[2], result[3]
            end
        end
        tex:SetColorTexture(r, g, b, 1)
    end

    swatch:SetScript("OnClick", function()
        if not ColorPickerFrame or not ColorPickerFrame.SetupColorPickerAndShow then return end
        local r, g, b = def[1], def[2], def[3]
        if getTbl then
            local result = getTbl()
            if type(result) == "table" and result[1] then
                r, g, b = result[1], result[2], result[3]
            end
        end
        addon._colorPickerLive = true
        _activeColorPickerCallbacks = { setKeyVal = setKeyVal, notify = notify, tex = tex }
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b,
            swatchFunc = function()
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                setKeyVal({ nr, ng, nb })
                tex:SetColorTexture(nr, ng, nb, 1)
            end,
            cancelFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local p = ColorPickerFrame.previousValues
                if p and type(p.r) == "number" then
                    setKeyVal({ p.r, p.g, p.b })
                end
                swatch:Refresh()
                if notify then notify() end
            end,
            finishedFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                setKeyVal({ nr, ng, nb })
                tex:SetColorTexture(nr, ng, nb, 1)
                if notify then notify() end
            end,
        })
        EnsureHexBoxHooked()
    end)

    frame.Refresh = function() swatch:Refresh() end
    frame:Refresh()
    if tooltip then ApplyOptionTooltip(swatch, tooltip) end
    return frame
end

-- Simplified Color Swatch for Dashboard (no anchor required, uses get/set functions)
function _G.OptionsWidgets_CreateColorSwatch(parent, labelText, description, get, set, hasAlpha, tooltip)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(32)
    local searchText = (labelText or "") .. " " .. (description or "")
    row.searchText = searchText:lower()

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    label:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -45, 0)

    local desc = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", row, "RIGHT", -45, 0)
    desc:SetWordWrap(true)

    local swatch = CreateFrame("Button", nil, row)
    swatch:SetSize(24, 24)
    swatch:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    local bg = swatch:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(swatch)
    bg:SetColorTexture(Def.InputBorder[1], Def.InputBorder[2], Def.InputBorder[3], 0.6)
    local tex = swatch:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("TOPLEFT", swatch, "TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -1, 1)

    function swatch:Refresh()
        if type(get) ~= "function" then 
            tex:SetColorTexture(1, 1, 1, 1)
            return 
        end
        local r, g, b, a = get()
        tex:SetColorTexture(r or 1, g or 1, b or 1, a or 1)
    end

    swatch:SetScript("OnClick", function()
        if type(get) ~= "function" or type(set) ~= "function" then return end
        local r, g, b, a = get()
        addon._colorPickerLive = true
        -- Guard: swatchFunc may fire during SetupColorPickerAndShow before the
        -- opacity slider is initialised.  Defer readiness by one frame so init
        -- callbacks cannot overwrite the saved alpha with a stale value.
        local pickerReady = false
        _activeColorPickerCallbacks = {
            setKeyVal = function(tbl)
                -- SyncHexBoxToPicker always passes {r,g,b} with no alpha.
                -- Preserve current alpha from get() so hex-box sync never clobbers it.
                if type(tbl) == "table" then
                    local _, _, _, currentA = get()
                    set(tbl[1] or 1, tbl[2] or 1, tbl[3] or 1, currentA)
                end
            end,
            getAlpha = hasAlpha and function()
                local _, _, _, ca = get()
                return ca or 1
            end or nil,
            notify = nil,
            tex = tex,
        }
        local info = {
            r = r or 1, g = g or 1, b = b or 1,
            a = hasAlpha and (a or 1) or nil,
            opacity = hasAlpha and (a or 1) or nil,
            hasOpacity = hasAlpha == true,
            swatchFunc = function()
                if not pickerReady then return end
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                if hasAlpha then
                    local na = (type(ColorPickerFrame.GetColorAlpha) == "function" and ColorPickerFrame:GetColorAlpha())
                               or (type(ColorPickerFrame.GetOpacity) == "function" and (1 - ColorPickerFrame:GetOpacity()))
                               or 1
                    set(nr, ng, nb, na)
                    tex:SetColorTexture(nr, ng, nb, na)
                else
                    set(nr, ng, nb, 1)
                    tex:SetColorTexture(nr, ng, nb, 1)
                end
            end,
            cancelFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local pv = ColorPickerFrame.previousValues
                if pv and type(pv.r) == "number" and type(pv.g) == "number" and type(pv.b) == "number" then
                    if hasAlpha then
                        -- modern WoW stores alpha as pv.a; legacy stored inverted pv.opacity
                        local oa = (type(pv.a) == "number" and pv.a)
                                   or (type(pv.opacity) == "number" and (1 - pv.opacity))
                                   or 1
                        set(pv.r, pv.g, pv.b, oa)
                    else
                        set(pv.r, pv.g, pv.b, 1)
                    end
                end
                swatch:Refresh()
            end,
            finishedFunc = function()
                addon._colorPickerLive = nil
                _activeColorPickerCallbacks = nil
                local nr, ng, nb = GetColorPickerEffectiveRGB()
                if hasAlpha then
                    local na = (type(ColorPickerFrame.GetColorAlpha) == "function" and ColorPickerFrame:GetColorAlpha())
                               or (type(ColorPickerFrame.GetOpacity) == "function" and (1 - ColorPickerFrame:GetOpacity()))
                               or 1
                    set(nr, ng, nb, na)
                else
                    set(nr, ng, nb, 1)
                end
                swatch:Refresh()
            end,
        }
        if ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            -- Legacy WoW support
            ColorPickerFrame.func = info.swatchFunc
            ColorPickerFrame.cancelFunc = info.cancelFunc
            ColorPickerFrame.opacityFunc = info.swatchFunc
            ColorPickerFrame.hasOpacity = info.hasOpacity
            ColorPickerFrame.opacity = info.opacity
            ColorPickerFrame:SetColorRGB(info.r, info.g, info.b)
            ColorPickerFrame:Show()
        end
        EnsureHexBoxHooked()
        C_Timer.After(0, function() pickerReady = true end)
    end)

    function row:Refresh()
        swatch:Refresh()
    end

    row:Refresh()
    ApplyRowHoverHighlight(row)
    local effectiveTooltip = (description or "") .. (description and tooltip and "\n\n" or "") .. (tooltip or "")
    ApplyOptionTooltip(row, effectiveTooltip)
    return row
end

-- Search input: card-themed styling (SectionCardBg, SectionCardBorder), search icon, integrated clear, focus state.
-- onTextChanged(text) called on input.
local SEARCH_ICON_LEFT = 28
local SEARCH_CLEAR_SIZE = 20
local SEARCH_CARD_INSET = 4
local SEARCH_BAR_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
}
function OptionsWidgets_CreateSearchInput(parent, onTextChanged, placeholder)
    local row = CreateFrame("Frame", nil, parent)
    row:SetAllPoints(parent)
    local editWrapper = CreateFrame("Frame", nil, row, "BackdropTemplate")
    editWrapper:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    editWrapper:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
    editWrapper:SetHeight(32)
    editWrapper:SetBackdrop(SEARCH_BAR_BACKDROP)
    editWrapper:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    editWrapper:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    local function setBorderColor(c)
        editWrapper:SetBackdropBorderColor(c[1], c[2], c[3], c[4] or 1)
    end

    local edit = CreateFrame("EditBox", nil, editWrapper)
    edit:SetAllPoints(editWrapper)
    edit:SetAutoFocus(false)
    edit:EnableMouse(true)
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    edit:SetTextInsets(SEARCH_ICON_LEFT, SEARCH_CLEAR_SIZE + 14, 0, 0)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)

    local searchIcon = edit:CreateTexture(nil, "OVERLAY")
    searchIcon:SetSize(14, 14)
    searchIcon:SetPoint("LEFT", edit, "LEFT", 10, 0)
    searchIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    searchIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    if placeholder then
        local ph = edit:CreateFontString(nil, "OVERLAY")
        SetSafeFont(ph, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(ph, Def.TextColorSection)
        ph:SetText(placeholder)
        ph:SetPoint("LEFT", edit, "LEFT", SEARCH_ICON_LEFT, 0)
        ph:SetJustifyH("LEFT")
        edit.placeholder = ph
        edit:SetScript("OnEditFocusGained", function()
            if ph then ph:Hide() end
            setBorderColor(Def.AccentColor)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
        edit:SetScript("OnEditFocusLost", function()
            if ph and edit:GetText() == "" then ph:Show() end
            setBorderColor(Def.SectionCardBorder)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
    else
        edit:SetScript("OnEditFocusGained", function()
            setBorderColor(Def.AccentColor)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
        edit:SetScript("OnEditFocusLost", function()
            setBorderColor(Def.SectionCardBorder)
            if row.clearBtn then row.clearBtn:SetShown(edit:GetText() ~= "") end
        end)
    end
    edit:SetScript("OnEscapePressed", function()
        edit:SetText("")
        if edit.placeholder then edit.placeholder:Show() end
        edit:ClearFocus()
        if onTextChanged then onTextChanged("") end
        if row.clearBtn then row.clearBtn:Hide() end
    end)
    if not placeholder then
        edit:SetScript("OnTextChanged", function(self, userInput)
            if userInput and onTextChanged then onTextChanged(self:GetText()) end
            if row.clearBtn then row.clearBtn:SetShown(self:GetText() ~= "") end
        end)
    else
        edit:SetScript("OnTextChanged", function(self, userInput)
            if edit.placeholder then edit.placeholder:SetShown(self:GetText() == "") end
            if userInput and onTextChanged then onTextChanged(self:GetText()) end
            if row.clearBtn then row.clearBtn:SetShown(self:GetText() ~= "") end
        end)
    end

    local clearBtn = CreateFrame("Button", nil, row)
    clearBtn:SetSize(SEARCH_CLEAR_SIZE, SEARCH_CLEAR_SIZE)
    clearBtn:SetPoint("RIGHT", editWrapper, "RIGHT", -8, 0)
    clearBtn:SetFrameLevel(editWrapper:GetFrameLevel() + 5)
    clearBtn:EnableMouse(true)
    clearBtn:Hide()
    local clearText = clearBtn:CreateFontString(nil, "OVERLAY")
    SetSafeFont(clearText, Def.FontPath, Def.LabelSize - 1, nil)
    SetTextColor(clearText, Def.TextColorSection)
    clearText:SetText("X")
    clearText:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
    clearBtn:SetScript("OnClick", function()
        edit:SetText("")
        if edit.placeholder then edit.placeholder:Show() end
        if onTextChanged then onTextChanged("") end
        clearBtn:Hide()
    end)
    clearBtn:SetScript("OnEnter", function() SetTextColor(clearText, Def.TextColorHighlight) end)
    clearBtn:SetScript("OnLeave", function() SetTextColor(clearText, Def.TextColorSection) end)

    row.edit = edit
    row.clearBtn = clearBtn
    row.searchText = ""
    return row
end

local CARD_HEADER_H = 24
local CARD_EXPAND_ANIM_DUR = 0.22

-- Section card: rounded corners via SetBackdrop, soft cinematic background.
-- When sectionKey and getCollapsedFn/setCollapsedFn are provided, the card is collapsible.
function _G.OptionsWidgets_CreateSectionCard(parent, anchor, sectionKey, getCollapsedFn, setCollapsedFn)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -Def.SectionGap)
    card:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    card:SetBackdrop(SECTION_CARD_BACKDROP)
    card:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], Def.SectionCardBg[4])
    card:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])

    if sectionKey and getCollapsedFn and setCollapsedFn then
        card:SetClipsChildren(true)
        local contentContainer = CreateFrame("Frame", nil, card)
        contentContainer:SetPoint("TOPLEFT", card, "TOPLEFT", Def.CardPadding, -Def.CardPadding - CARD_HEADER_H)
        contentContainer:SetPoint("RIGHT", card, "RIGHT", -Def.CardPadding, 0)
        contentContainer:SetHeight(1)
        contentContainer:SetFrameLevel(card:GetFrameLevel() + 1)
        card.contentContainer = contentContainer
        card.contentAnchor = contentContainer
        card.sectionKey = sectionKey
        card.getCardCollapsed = getCollapsedFn
        card.setCardCollapsed = setCollapsedFn
        card.headerHeight = CARD_HEADER_H + Def.CardPadding
    end

    return card
end

local function SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, collapsed, cw, lw, parent)
    hdr:ClearAllPoints()
    chevron:ClearAllPoints()
    hdrLabel:ClearAllPoints()
    if collapsed then
        -- Fill full card for centered text
        hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        hdr:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        local pad = Def.CardPadding
        chevron:SetPoint("CENTER", hdr, "LEFT", pad + 6 + cw / 2, 0)
        hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
        hdrLabel:SetPoint("CENTER", hdr, "LEFT", pad + 6 + cw + 6 + lw / 2, 0)
    else
        -- Inset header at top of card
        hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", Def.CardPadding, -Def.CardPadding)
        hdr:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Def.CardPadding, 0)
        hdr:SetHeight(CARD_HEADER_H)
        chevron:SetPoint("CENTER", hdr, "LEFT", 6 + cw / 2, 0)
        hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
        hdrLabel:SetPoint("CENTER", hdr, "LEFT", 6 + cw + 6 + lw / 2, 0)
    end
end

-- Section header: uppercase label, left-aligned. When sectionKey and getCollapsedFn/setCollapsedFn are
-- provided, returns a clickable Button with chevron for collapse; otherwise returns a FontString.
function _G.OptionsWidgets_CreateSectionHeader(parent, text, sectionKey, getCollapsedFn, setCollapsedFn)
    local sk = sectionKey or parent.sectionKey
    local getFn = getCollapsedFn or parent.getCardCollapsed
    local setFn = setCollapsedFn or parent.setCardCollapsed

    if sk and getFn and setFn then
        local hdr = CreateFrame("Button", nil, parent)
        hdr:EnableMouse(true)
        hdr:SetFrameLevel(parent:GetFrameLevel() + 2)

        local hdrBg = hdr:CreateTexture(nil, "BACKGROUND")
        hdrBg:SetAllPoints(hdr)
        hdrBg:SetColorTexture(0.10, 0.10, 0.12, 0.0)

        local chevron = hdr:CreateFontString(nil, "OVERLAY")
        SetSafeFont(chevron, Def.FontPath, Def.LabelSize or 13, nil)
        SetTextColor(chevron, Def.TextColorSection)
        chevron:SetText(getFn(sk) and "+" or "-")
        local cw = chevron:GetStringWidth()
        hdr.chevron = chevron
        parent.header = hdr

        local hdrLabel = hdr:CreateFontString(nil, "OVERLAY")
        SetSafeFont(hdrLabel, Def.FontPath, Def.SectionSize + 1, nil)
        SetTextColor(hdrLabel, Def.TextColorSection)
        hdrLabel:SetText(text and text:upper() or "")
        hdrLabel:SetJustifyH("LEFT")
        local lw = hdrLabel:GetStringWidth()
        SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, getFn(sk), cw, lw, parent)

        -- Text glow on hover instead of full-card highlight
        local glowColor = Def.AccentColor
        hdr:SetScript("OnEnter", function()
            SetTextColor(chevron, Def.TextColorHighlight)
            SetTextColor(hdrLabel, Def.TextColorHighlight)
            chevron:SetShadowColor(glowColor[1], glowColor[2], glowColor[3], 0.75)
            chevron:SetShadowOffset(2, -2)
            hdrLabel:SetShadowColor(glowColor[1], glowColor[2], glowColor[3], 0.75)
            hdrLabel:SetShadowOffset(2, -2)
        end)
        hdr:SetScript("OnLeave", function()
            SetTextColor(chevron, Def.TextColorSection)
            SetTextColor(hdrLabel, Def.TextColorSection)
            if addon.Dashboard_ApplyTextShadow then
                addon.Dashboard_ApplyTextShadow(chevron)
                addon.Dashboard_ApplyTextShadow(hdrLabel)
            else
                chevron:SetShadowColor(0, 0, 0, 0)
                chevron:SetShadowOffset(0, 0)
                hdrLabel:SetShadowColor(0, 0, 0, 0)
                hdrLabel:SetShadowOffset(0, 0)
            end
        end)

        hdr.UpdateCollapsedAnchors = function()
            SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, getFn(sk), cw, lw, parent)
        end

        hdr:SetScript("OnClick", function()
            local collapsed = not getFn(sk)
            setFn(sk, collapsed)
            chevron:SetText(collapsed and "+" or "-")
            SetHeaderCollapsedAnchors(hdr, chevron, hdrLabel, collapsed, cw, lw, parent)
            local cc = parent.contentContainer
            local headerH = parent.headerHeight or CARD_HEADER_H + Def.CardPadding
            local fullH = parent.contentHeight and (parent.contentHeight + (Def.CardBottomPadding or Def.CardPadding)) or headerH
            local fromH = parent:GetHeight()
            local toH = collapsed and headerH or fullH
            if cc then
                cc:SetShown(not collapsed)
            end
            if fromH == toH then return end
            parent.animStart = GetTime()
            parent.animFrom = fromH
            parent.animTo = toH
            parent:SetScript("OnUpdate", function(self)
                local elapsed = GetTime() - self.animStart
                local t = math.min(elapsed / CARD_EXPAND_ANIM_DUR, 1)
                local h = self.animFrom + (self.animTo - self.animFrom) * easeOut(t)
                self:SetHeight(math.max(headerH, h))
                if t >= 1 then
                    self:SetScript("OnUpdate", nil)
                    -- Resize parent tab frame so scroll stops at content end
                    local tab = self:GetParent()
                    if tab and _G.ResizeTabFrame then _G.ResizeTabFrame(tab) end
                end
            end)
        end)

        return hdr
    end

    local label = parent:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.SectionSize + 1, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorSection)
    label:SetText(text and text:upper() or "")
    return label
end

-- Reorder list: drag rows with ghost and insertion line. scrollFrameRef and panelRef for auto-scroll.
local REORDER_ROW_GAP = 4
local REORDER_ROW_HEIGHT = 24
local REORDER_AUTOSCROLL_MARGIN = 40
local REORDER_AUTOSCROLL_STEP = 10

--- Create a drag-to-reorder list widget (e.g. for Focus category order). Rows show labelMap[key]; opt.get/set provide order array.
-- @param parent table Parent frame
-- @param anchor table Anchor for TOPLEFT
-- @param opt table Option descriptor: get(), set(order), labelMap, name, tooltip
-- @param scrollFrameRef table Scroll frame for auto-scroll during drag
-- @param panelRef table Options panel for scroll region
-- @param notifyMainAddonFn function Called when order changes (e.g. to refresh tracker)
-- @return table Container frame
function OptionsWidgets_CreateReorderList(parent, anchor, opt, scrollFrameRef, panelRef, notifyMainAddonFn)
    local keys = opt.get and opt.get() or {}
    if type(keys) == "function" then keys = keys() end
    if type(keys) ~= "table" then keys = {} end
    local defaultOrder = addon.GROUP_ORDER
    if #keys < #defaultOrder then
        local seen = {}
        for _, k in ipairs(keys) do seen[k] = true end
        for _, k in ipairs(defaultOrder) do
            if not seen[k] then keys[#keys + 1] = k end
        end
    end
    local labelMap = opt.labelMap or {}
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -Def.SectionGap)
    container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    local sectionLabel = OptionsWidgets_CreateSectionHeader(container, opt.name or L["OPTIONS_FOCUS_ORDER"])
    sectionLabel:SetPoint("TOPLEFT", container, "TOPLEFT", Def.CardPadding, -Def.CardPadding)

    local rows = {}
    local keyToRow = {}
    local state = {
        active = false,
        sourceIndex = nil,
        targetIndex = nil,
        ghostFrame = nil,
        insertionLine = nil,
        sourceRow = nil,
        rows = rows,
        keyToRow = keyToRow,
        get = opt.get,
        set = opt.set,
    }

    local function ensureGhost()
        if state.ghostFrame then return state.ghostFrame end
        local ghost = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        ghost:SetFrameStrata("TOOLTIP")
        ghost:SetSize(240, REORDER_ROW_HEIGHT)
        ghost:SetAlpha(0.85)
        ghost:SetBackdrop(SECTION_CARD_BACKDROP)
        ghost:SetBackdropColor(Def.SectionCardBg[1], Def.SectionCardBg[2], Def.SectionCardBg[3], 0.95)
        ghost:SetBackdropBorderColor(Def.SectionCardBorder[1], Def.SectionCardBorder[2], Def.SectionCardBorder[3], Def.SectionCardBorder[4])
        state.ghostFrame = ghost
        state.ghostLabel = ghost:CreateFontString(nil, "OVERLAY")
        SetSafeFont(state.ghostLabel, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(state.ghostLabel, Def.TextColorLabel)
        state.ghostLabel:SetPoint("LEFT", ghost, "LEFT", 28, 0)
        return ghost
    end

    local function ensureInsertionLine()
        if state.insertionLine then return state.insertionLine end
        local line = container:CreateTexture(nil, "OVERLAY")
        line:SetHeight(3)
        line:SetColorTexture(Def.AccentColor[1], Def.AccentColor[2], Def.AccentColor[3], 1)
        state.insertionLine = line
        return line
    end

    --- Compute insertion index from cursor Y using row screen bounds (avoids IsMouseOver quirks in scroll frames).
    local function getInsertionIndexFromCursor()
        local activeRows = state.rows
        if not activeRows or #activeRows == 0 then return 1 end
        local _, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        cursorY = cursorY / scale
        for i = 1, #activeRows do
            local row = activeRows[i]
            local top = row:GetTop()
            local bottom = row:GetBottom()

            if top and bottom then
                local mid = (top + bottom) / 2
                if cursorY > mid then
                    return i
                end
            end
        end
        return #activeRows + 1
    end


    local presetOrder = { "Collection Focused", "Quest Focused", "Campaign Focused", "World / Rare Focused" }
    local presets = (opt.presets and addon.GROUP_ORDER_PRESETS) and opt.presets or nil
    local presetRow = nil
    if presets then
        presetRow = CreateFrame("Frame", nil, container)
        presetRow:SetHeight(56)  -- 2 rows of buttons + gap
        presetRow:SetPoint("TOPLEFT", sectionLabel, "BOTTOMLEFT", 0, -8)
        presetRow:SetPoint("TOPRIGHT", container, "TOPRIGHT", -Def.CardPadding, 0)
        local btnW, btnH, gapH, gapV = 130, 22, 8, 6
        local prevBtn = nil
        for idx, name in ipairs(presetOrder) do
            local presetOrderArr = presets[name]
            if presetOrderArr then
                local btn = OptionsWidgets_CreateButton(presetRow, name:gsub(" / Rare", "/Rare"), function()
                    if opt.set then opt.set(presetOrderArr) end
                    if container.Refresh then container:Refresh() end
                    if notifyMainAddonFn then notifyMainAddonFn() end
                end, { width = btnW, height = btnH })
                if idx == 1 then
                    btn:SetPoint("TOPLEFT", presetRow, "TOPLEFT", 0, 0)
                elseif idx == 2 then
                    btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", gapH, 0)
                elseif idx == 3 then
                    btn:SetPoint("TOPLEFT", presetRow, "TOPLEFT", 0, -(btnH + gapV))
                else
                    btn:SetPoint("TOPLEFT", prevBtn, "TOPRIGHT", gapH, 0)
                end
                prevBtn = btn
            end
        end
    end

    local rowListAnchor = presetRow or sectionLabel
    local function repositionRows(orderedKeys)
        local prev = rowListAnchor
        for i, key in ipairs(orderedKeys) do
            local row = keyToRow[key]
            if row then
                row.index = i
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -REORDER_ROW_GAP)
                prev = row
            end
        end
        local newRows = {}
        for i, key in ipairs(orderedKeys) do
            if keyToRow[key] then newRows[i] = keyToRow[key] end
        end
        state.rows = newRows
        local resetBtn = state.resetBtn
        if resetBtn and orderedKeys[#orderedKeys] then
            local lastRow = keyToRow[orderedKeys[#orderedKeys]]
            if lastRow then
                resetBtn:ClearAllPoints()
                resetBtn:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -6)
            end
        end
    end

    local function applyReorderAndCleanup()
        if not state.active or not state.rows or #state.rows == 0 then return end

        panelRef:SetScript("OnUpdate", nil)
        state.active = false

        local fromIdx = state.sourceIndex
        local toIdx = state.targetIndex or fromIdx

        if state.ghostFrame then state.ghostFrame:Hide() end
        if state.insertionLine then state.insertionLine:Hide() end
        if state.sourceRow then state.sourceRow:SetAlpha(1) end
        if toIdx == fromIdx then return end

        local orderedKeys = {}
        for i, row in ipairs(state.rows) do
            orderedKeys[i] = row.key
        end

        local key = orderedKeys[fromIdx]
        table.remove(orderedKeys, fromIdx)
        local insertAt = (fromIdx < toIdx) and (toIdx - 1) or toIdx
        table.insert(orderedKeys, insertAt, key)
        state.set(orderedKeys)
        repositionRows(orderedKeys)
        if notifyMainAddonFn then
                notifyMainAddonFn()
        end
    end


    local function onReorderUpdate()
    if not state.active or not IsMouseButtonDown("LeftButton") then
        applyReorderAndCleanup() return end

        local ghost = ensureGhost()
        local line = ensureInsertionLine()

        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        x, y = x / scale, y / scale

        ghost:ClearAllPoints()
        ghost:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        ghost:Show()

        local insertIdx = getInsertionIndexFromCursor()
        state.targetIndex = insertIdx

        local activeRows = state.rows
        if not activeRows or #activeRows == 0 then return end

            if insertIdx <= #activeRows then
                local ref = activeRows[insertIdx]
                line:ClearAllPoints()
                line:SetPoint("LEFT", ref, "LEFT", 0, 0)
                line:SetPoint("RIGHT", ref, "RIGHT", 0, 0)
                line:SetPoint("BOTTOM", ref, "TOP", 0, REORDER_ROW_GAP / 2)
                line:Show()
            else
                local last = activeRows[#activeRows]
                line:ClearAllPoints()
                line:SetPoint("LEFT", last, "LEFT", 0, 0)
                line:SetPoint("RIGHT", last, "RIGHT", 0, 0)
                line:SetPoint("TOP", last, "BOTTOM", 0, -REORDER_ROW_GAP / 2)
                line:Show()
            end

            -- Auto scroll
            if scrollFrameRef then
                local sy = y
                local sfTop = scrollFrameRef:GetTop()
                local sfBottom = scrollFrameRef:GetBottom()
                local cur = scrollFrameRef:GetVerticalScroll()
                local vh = scrollFrameRef:GetHeight()
                local scrollChild = scrollFrameRef:GetScrollChild()
                local maxScroll = math.max(((scrollChild and scrollChild:GetHeight() or 0) - vh), 0)

                if sfTop and sy > sfTop - REORDER_AUTOSCROLL_MARGIN and cur > 0 then
                    scrollFrameRef:SetVerticalScroll(math.max(cur - REORDER_AUTOSCROLL_STEP, 0))
                elseif sfBottom and sy < sfBottom + REORDER_AUTOSCROLL_MARGIN and maxScroll > 0 then
                    scrollFrameRef:SetVerticalScroll(math.min(cur + REORDER_AUTOSCROLL_STEP, maxScroll))
                end
            end
    end

    local prevAnchor = rowListAnchor
    for i, key in ipairs(keys) do
        local row = CreateFrame("Button", nil, container)
        row:SetSize(240, REORDER_ROW_HEIGHT)
        row:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -REORDER_ROW_GAP)
        prevAnchor = row
        row.key = key
        row.index = i
        keyToRow[key] = row
        local lab = row:CreateFontString(nil, "OVERLAY")
        SetSafeFont(lab, Def.FontPath, Def.LabelSize, nil)
        lab:SetJustifyH("LEFT")
        SetTextColor(lab, Def.TextColorLabel)
        lab:SetText(addon.L[(labelMap[key]) or key:gsub("^%l", string.upper)])
        lab:SetPoint("LEFT", row, "LEFT", 24, 0)
        row.label = lab
        local grip = row:CreateFontString(nil, "OVERLAY")
        SetSafeFont(grip, Def.FontPath, Def.LabelSize, nil)
        SetTextColor(grip, Def.TextColorSection)
        grip:SetText("::")
        grip:SetPoint("LEFT", row, "LEFT", 4, 0)
        row:SetScript("OnMouseDown", function(_, btn)
            if btn ~= "LeftButton" then return end
            state.active = true
            state.sourceIndex = row.index
            state.targetIndex = row.index
            state.sourceRow = row
            row:SetAlpha(0.5)
            ensureGhost():Show()
            state.ghostLabel:SetText(lab:GetText())
            panelRef:SetScript("OnUpdate", onReorderUpdate)
        end)
        rows[i] = row
    end
    state.rows = rows

    local resetBtn = OptionsWidgets_CreateButton(container, L["OPTIONS_FOCUS_RESET_DEFAULT"], function()
        if opt.set then opt.set(nil) end
        if addon.SetDB then addon.SetDB("groupOrder", nil) end
        local newKeys = opt.get and opt.get() or {}
        if type(newKeys) == "function" then newKeys = newKeys() end
        if type(newKeys) == "table" then repositionRows(newKeys) end
        if notifyMainAddonFn then notifyMainAddonFn() end
    end, { width = 100, height = 22 })
    state.resetBtn = resetBtn
    resetBtn:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -6)

    local presetH = presetRow and (8 + 56) or 0
    local totalH = Def.CardPadding + 14 + presetH + (#keys * (REORDER_ROW_HEIGHT + REORDER_ROW_GAP)) + 6 + 22 + Def.CardPadding
    container:SetHeight(totalH)
    container.searchText = ((opt.name or "order") .. " " .. (opt.desc or "") .. " " .. (opt.tooltip or "")):lower()
    function container:Refresh()
        local newKeys = opt.get and opt.get() or {}
        if type(newKeys) == "function" then newKeys = newKeys() end
        if type(newKeys) == "table" then repositionRows(newKeys) end
    end
    return container
end

-- Edit box: multi-line text input with optional read-only mode (used for profile import/export).
function _G.OptionsWidgets_CreateEditBox(parent, labelText, get, set, opts)
    opts = opts or {}
    local boxH = opts.height or 60
    local readonly = opts.readonly
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(20 + 4 + boxH)
    row.searchText = ((labelText or "") .. " editbox"):lower()

    local label = row:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)

    local wrap = CreateFrame("Frame", nil, row)
    wrap:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
    wrap:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    wrap:SetHeight(boxH)
    local wBg = wrap:CreateTexture(nil, "BACKGROUND")
    wBg:SetAllPoints(wrap)
    wBg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
    addon.CreateBorder(wrap, Def.InputBorder)

    local scroll = CreateFrame("ScrollFrame", nil, wrap)
    scroll:SetPoint("TOPLEFT", wrap, "TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", wrap, "BOTTOMRIGHT", -4, 4)

    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetWidth(scroll:GetWidth() or 300)
    SetSafeFont(edit, Def.FontPath, Def.LabelSize, nil)
    local tc = Def.TextColorLabel
    edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
    edit:SetMaxLetters(2000)
    scroll:SetScrollChild(edit)

    -- Update width after layout
    C_Timer.After(0, function()
        local w = scroll:GetWidth()
        if w and w > 0 then edit:SetWidth(w) end
    end)

    if readonly then
        edit:SetScript("OnChar", function(self) self:SetText(get and get() or "") end)
        edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        edit:SetScript("OnEditFocusLost", function(self) self:HighlightText(0, 0) end)
    else
        edit:SetScript("OnEditFocusLost", function(self)
            if set then set(self:GetText()) end
        end)
        edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    end

    if opts.storeRef and type(opts.storeRef) == "string" then
        addon[opts.storeRef] = edit
    end

    function row:Refresh()
        if get then edit:SetText(get() or "") end
    end
    row:Refresh()
    ApplyRowHoverHighlight(row)
    ApplyOptionTooltip(row, opts.tooltip)
    return row
end

-- Blacklist grid: shows quests the player has hidden; each row has a name and an Unblock button.
function _G.OptionsWidgets_CreateBlacklistGrid(parent, labelText, opts)
    opts = opts or {}
    local container = CreateFrame("Frame", nil, parent)
    local BLACKLIST_HEADER_H = 34  -- label + gap (desc in tooltip)
    container:SetHeight(BLACKLIST_HEADER_H + 20)
    container.searchText = ((labelText or "") .. " " .. (opts.desc or "") .. " blacklist hidden quests"):lower()

    local label = container:CreateFontString(nil, "OVERLAY")
    SetSafeFont(label, Def.FontPath, Def.LabelSize, nil)
    label:SetJustifyH("LEFT")
    SetTextColor(label, Def.TextColorLabel)
    label:SetText(labelText or "")
    label:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    local desc = container:CreateFontString(nil, "OVERLAY")
    SetSafeFont(desc, Def.FontPath, Def.SectionSize, nil)
    desc:SetJustifyH("LEFT")
    SetTextColor(desc, Def.TextColorSection)
    desc:SetText("")
    desc:Hide()
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
    desc:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    desc:SetWordWrap(true)

    local listFrame = CreateFrame("Frame", nil, container)
    listFrame:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -10)
    listFrame:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    listFrame:SetHeight(1)

    local rowWidgets = {}

    local function Rebuild()
        for _, rw in ipairs(rowWidgets) do rw:Hide() end
        wipe(rowWidgets)

        local blacklist = addon.GetDB and addon.GetDB("questBlacklist", nil) or nil
        if not blacklist or type(blacklist) ~= "table" then
            local emptyLabel = listFrame:CreateFontString(nil, "OVERLAY")
            SetSafeFont(emptyLabel, Def.FontPath, Def.SectionSize, nil)
            SetTextColor(emptyLabel, Def.TextColorSection)
            emptyLabel:SetText(addon.L and addon.L["OPTIONS_CORE_HIDDEN_QUESTS"] or "No hidden quests.")
            emptyLabel:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, 0)
            local emptyRow = CreateFrame("Frame", nil, listFrame)
            emptyRow:SetHeight(20)
            emptyRow:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, 0)
            emptyRow:SetPoint("RIGHT", listFrame, "RIGHT", 0, 0)
            rowWidgets[1] = emptyRow
            listFrame:SetHeight(20)
            container:SetHeight(BLACKLIST_HEADER_H + 20)
            return
        end

        local yOff = 0
        local count = 0
        for questID, questName in pairs(blacklist) do
            count = count + 1
            local row = CreateFrame("Frame", nil, listFrame)
            row:SetHeight(24)
            row:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", listFrame, "RIGHT", 0, 0)

            local nameLbl = row:CreateFontString(nil, "OVERLAY")
            SetSafeFont(nameLbl, Def.FontPath, Def.LabelSize, nil)
            SetTextColor(nameLbl, Def.TextColorLabel)
            local displayName = (type(questName) == "string" and questName ~= "" and questName ~= "true") and questName or ("Quest #" .. tostring(questID))
            nameLbl:SetText(displayName)
            nameLbl:SetPoint("LEFT", row, "LEFT", 0, 0)
            nameLbl:SetJustifyH("LEFT")

            local unblockBtn = _G.OptionsWidgets_CreateButton(row, addon.L and addon.L["OPTIONS_CORE_UNBLOCK"] or "Unblock", function()
                if addon.GetDB then
                    local bl = addon.GetDB("questBlacklist", nil)
                    if bl and type(bl) == "table" then
                        bl[questID] = nil
                        local hasAny = false
                        for _ in pairs(bl) do hasAny = true; break end
                        if not hasAny then bl = nil end
                        if addon.SetDB then addon.SetDB("questBlacklist", bl) end
                    end
                end
                Rebuild()
                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
            end, { width = 70, height = 20 })
            unblockBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)

            rowWidgets[#rowWidgets + 1] = row
            yOff = yOff - 28
        end

        if count == 0 then
            listFrame:SetHeight(20)
            container:SetHeight(BLACKLIST_HEADER_H + 20)
        else
            listFrame:SetHeight(-yOff)
            container:SetHeight(BLACKLIST_HEADER_H + (-yOff))
        end
    end

    function container:Refresh()
        Rebuild()
    end
    Rebuild()
    local effectiveTooltip = (opts.desc or "") .. (opts.desc and opts.tooltip and "\n\n" or "") .. (opts.tooltip or "")
    ApplyOptionTooltip(container, effectiveTooltip)
    return container
end

-- Export Def and shared backdrop for panel (font updates, search dropdown)
addon.OptionsWidgetsDef = Def
addon.OptionsWidgetsSectionCardBackdrop = SECTION_CARD_BACKDROP
