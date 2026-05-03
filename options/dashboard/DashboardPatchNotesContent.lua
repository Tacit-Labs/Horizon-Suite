--[[
    Horizon Suite - Patch Notes Content Builder

    Lifted out of Dashboard_BuildMainFrame so the same renderer can populate:
      - the dashboard's inline Patch Notes view (DashboardFrame.lua)
      - the standalone Patch Notes modal shown on version bumps
        (DashboardPatchNotesModal.lua)

    The builder is pure: it creates the inner content frame, returns layout
    items, and never touches dashboard state directly. Callers own the
    accent/typography refresh ref tables and pass them in.
]]


local addon = _G.HorizonSuite


local L = (addon.L) or setmetatable({}, { __index = function(_, k) return k end })

local tinsert = table.insert

-- Layout constants (kept identical to the dashboard's previous in-closure values).
local PN_BODY_COL    = { 0.72, 0.72, 0.76, 1 }
local PN_MUTED_COL   = { 0.52, 0.56, 0.62, 1 }
local PN_SECTION_GAP = 16
local PN_BULLET_X    = 16
local PN_LINE_GAP    = 5

-- Module-name highlight palette (matches Dashboard accent palette by code).
local PN_MODULE_COLORS = {
    ["Essence"]  = "DC143C",
    ["Focus"]    = "FFD133",
    ["Cache"]    = "33CC66",
    ["Presence"] = "33FFDF",
    ["Flow"]     = "3399FF",
    ["Vista"]    = "B366FF",
    ["Insight"]  = "FF66B3",
    ["Axis"]     = "E0E0E0",
}

-- Capitalize first letter after "…: " (module prefix) so bullets read consistently.
local function CapitalizeAfterModulePrefix(text)
    if type(text) ~= "string" or text == "" then return text end
    local pre, first, rest = text:match("^(.-:%s*)(%a)(.*)$")
    if not pre or not first then return text end
    if first ~= string.lower(first) then return text end
    return pre .. string.upper(first) .. rest
end

local function ColorModuleNames(text)
    for name, hex in pairs(PN_MODULE_COLORS) do
        text = text:gsub("%f[%a](" .. name .. ")%f[%A]", "|cFF" .. hex .. "%1|r")
    end
    return text
end

addon.PatchNotes_ColorModuleNames           = ColorModuleNames
addon.PatchNotes_CapitalizeAfterModulePrefix = CapitalizeAfterModulePrefix

-- Build patch notes content under `opts.parent`. Pure builder; layout/sizing is
-- the caller's responsibility.
--
-- opts = {
--   parent         = Frame                -- where the inner container is parented
--   width          = number               -- content width in px
--   version        = string               -- target version, e.g. "4.15.0"
--   maxVersions    = number?              -- if set, render only the N most recent
--                                            versions (modal uses 1)
--   GetAccentColor = function() -> r,g,b  -- 0..1 RGB
--   accentRefs     = {                    -- caller-owned arrays for accent refresh
--                       sectionLabels = {}, bullets = {}, rules = {} }
--   typoRefs       = { ... }              -- caller-owned typography refresh table
-- }
--
-- Returns: {
--   inner        = Frame,        -- the inner container (caller may orphan to rebuild)
--   items        = { ... },      -- layout items consumed by ApplyLayout
--   builtVersion = string,
-- }
function addon.PatchNotes_BuildContent(opts)
    local parent         = opts.parent
    local cW             = opts.width or 600
    local currentVersion = opts.version or ""
    local maxVersions    = opts.maxVersions
    local GetAccentColor = opts.GetAccentColor or function() return 1, 1, 1 end
    local accentRefs     = opts.accentRefs or {}
    accentRefs.sectionLabels = accentRefs.sectionLabels or {}
    accentRefs.bullets       = accentRefs.bullets       or {}
    accentRefs.rules         = accentRefs.rules         or {}
    local typoRefs       = opts.typoRefs or {}

    local function ApplyPatchNoteFontString(fs, base, flagsOrNil, widgetChrome)
        local path = addon.Dashboard_ResolveSavedDashboardFontPath(
            (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath()))
                or addon.Dashboard_GetDefaultDashboardFontPath()
        )
        local eff = addon.Dashboard_EffectiveDashboardFontSize(base)
        local fl
        if widgetChrome and addon.Dashboard_GetWidgetOutlineFlags then
            fl = addon.Dashboard_GetWidgetOutlineFlags()
        else
            fl = flagsOrNil or ""
        end
        pcall(function()
            fs:SetFont(path, eff, fl)
        end)
        if addon.Dashboard_ApplyTextShadow then
            addon.Dashboard_ApplyTextShadow(fs)
        end
        tinsert(typoRefs, {
            fs = fs,
            base = base,
            flags = widgetChrome and nil or flagsOrNil,
            widgetChrome = widgetChrome and true or nil,
        })
    end

    local inner = CreateFrame("Frame", nil, parent)
    inner:SetWidth(cW)
    inner:SetHeight(1)
    inner:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)

    local items = {}
    local ar, ag, ab = GetAccentColor()
    local hex = string.format("%02X%02X%02X",
        math.floor(ar * 255 + 0.5), math.floor(ag * 255 + 0.5), math.floor(ab * 255 + 0.5))

    -- Collect all versions in the current major (e.g. 4.x.x), descending.
    local curMajor = tonumber((currentVersion or ""):match("^(%d+)")) or 0
    local versions = {}
    if addon.PATCH_NOTES then
        for v in pairs(addon.PATCH_NOTES) do
            if (tonumber(v:match("^(%d+)")) or 0) == curMajor then
                tinsert(versions, v)
            end
        end
    end
    table.sort(versions, function(a, b)
        local a1, a2, a3 = a:match("^(%d+)%.(%d+)%.(%d+)$")
        local b1, b2, b3 = b:match("^(%d+)%.(%d+)%.(%d+)$")
        a1, a2, a3 = tonumber(a1) or 0, tonumber(a2) or 0, tonumber(a3) or 0
        b1, b2, b3 = tonumber(b1) or 0, tonumber(b2) or 0, tonumber(b3) or 0
        if a1 ~= b1 then return a1 > b1 end
        if a2 ~= b2 then return a2 > b2 end
        return a3 > b3
    end)

    if type(maxVersions) == "number" and maxVersions > 0 and #versions > maxVersions then
        for i = #versions, maxVersions + 1, -1 do versions[i] = nil end
    end

    if #versions == 0 then
        local lbl = inner:CreateFontString(nil, "OVERLAY")
        ApplyPatchNoteFontString(lbl, 12, "")
        lbl:SetWidth(cW)
        lbl:SetJustifyH("CENTER")
        lbl:SetText(L["DASH_PATCH_NOTES_EMPTY"] or "No notes available.")
        lbl:SetTextColor(unpack(PN_MUTED_COL))
        tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 0,
                         onResize = function(w) lbl:SetWidth(w) end })
    else
        for vi, ver in ipairs(versions) do
            local notes = addon.PATCH_NOTES[ver]
            if notes then
                if vi > 1 then
                    tinsert(items, { type = "gap", h = 24 })
                    local sep = inner:CreateTexture(nil, "ARTWORK")
                    sep:SetSize(cW, 1)
                    sep:SetColorTexture(ar, ag, ab, 0.15)
                    tinsert(accentRefs.rules, sep)
                    tinsert(items, { type = "tex", tex = sep, gap = 18,
                                     onResize = function(w) sep:SetWidth(w) end })
                end

                local vHdr = inner:CreateFontString(nil, "OVERLAY")
                ApplyPatchNoteFontString(vHdr, 14, nil, true)
                vHdr:SetJustifyH("LEFT")
                local noteDate = notes.date
                if type(noteDate) == "string" and noteDate ~= "" then
                    local disp = (addon.PatchNotes_FormatIsoDateLongUK
                                  and addon.PatchNotes_FormatIsoDateLongUK(noteDate))
                                 or noteDate
                    vHdr:SetText("v" .. ver .. " (" .. disp .. ")")
                else
                    vHdr:SetText("v" .. ver)
                end
                vHdr:SetTextColor(ar, ag, ab)
                tinsert(accentRefs.sectionLabels, vHdr)
                tinsert(items, { type = "fs", fs = vHdr, x = 0, gap = 14 })

                for si, sec in ipairs(notes) do
                    if si > 1 then tinsert(items, { type = "gap", h = PN_SECTION_GAP }) end

                    local lbl = inner:CreateFontString(nil, "OVERLAY")
                    ApplyPatchNoteFontString(lbl, 10, nil, true)
                    lbl:SetWidth(cW)
                    lbl:SetJustifyH("LEFT")
                    lbl:SetText(sec.section:upper())
                    lbl:SetTextColor(ar, ag, ab)
                    tinsert(accentRefs.sectionLabels, lbl)
                    tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 9,
                                     onResize = function(w) lbl:SetWidth(w) end })

                    for _, bullet in ipairs(sec.bullets) do
                        local txt = inner:CreateFontString(nil, "OVERLAY")
                        ApplyPatchNoteFontString(txt, 12, "")
                        txt:SetWidth(cW - PN_BULLET_X)
                        txt:SetJustifyH("LEFT")
                        txt:SetWordWrap(true)
                        local coloredBullet = ColorModuleNames(CapitalizeAfterModulePrefix(bullet))
                        txt:SetText("|cFF" .. hex .. "\226\128\148|r  " .. coloredBullet)
                        txt:SetTextColor(unpack(PN_BODY_COL))
                        tinsert(accentRefs.bullets,
                                { fs = txt, bullet = bullet, coloredBullet = coloredBullet })
                        tinsert(items, { type = "fs", fs = txt, x = PN_BULLET_X, gap = PN_LINE_GAP,
                                         onResize = function(w) txt:SetWidth(w - PN_BULLET_X) end })
                    end
                end
            end
        end
    end

    return {
        inner        = inner,
        items        = items,
        builtVersion = currentVersion,
    }
end

-- Reflow content vertically. Returns the total height consumed.
function addon.PatchNotes_ApplyLayout(items, inner)
    if not inner or not items then return 0 end
    local y = 0
    for _, item in ipairs(items) do
        if item.type == "fs" then
            item.fs:ClearAllPoints()
            item.fs:SetPoint("TOPLEFT", inner, "TOPLEFT", item.x, y)
            y = y - math.max(item.fs:GetStringHeight(), 13) - item.gap
        elseif item.type == "tex" then
            item.tex:ClearAllPoints()
            item.tex:SetPoint("TOPLEFT", inner, "TOPLEFT", 0, y)
            y = y - 1 - item.gap
        elseif item.type == "gap" then
            y = y - item.h
        end
    end
    local totalH = math.max(1, -y)
    inner:SetHeight(totalH)
    return totalH
end

-- Update widths for word-wrap on resize (call before ApplyLayout).
function addon.PatchNotes_RelayoutWidths(items, newW)
    if not items then return end
    for _, item in ipairs(items) do
        if item.onResize then item.onResize(newW) end
    end
end
