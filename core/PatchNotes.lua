--[[
    Horizon Suite - Patch Notes
    Shows a popup once per account on the first login after each update.
    Reopen: /h notes  or the Dashboard "What's New" button.

    Notes data lives in core/PatchNotesData.lua — edit that file each release.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- LAYOUT
-- ============================================================================

local W          = 440
local H          = 460
local PAD        = 16
local TITLE_H    = 54
local FOOTER_H   = 36
local ACCENT_H   = 3
local SECTION_GAP = 16
local BULLET_X   = 16
local LINE_GAP   = 5
local FADE_DUR   = 0.25

local CHANGELOG_URL = "https://gitlab.com/Crystilac/horizon-suite/-/blob/main/CHANGELOG.md"

local BG_COL    = { 0.06, 0.06, 0.08, 0.97 }
local EDGE_COL  = { 0.2,  0.2,  0.26, 0.95 }
local RULE_COL  = { 0.13, 0.13, 0.17, 1    }
local MUTED_COL = { 0.42, 0.42, 0.50, 1    }
local BODY_COL  = { 0.72, 0.72, 0.76, 1    }

local F_HEAD = "Fonts\\FRIZQT__.TTF"
local F_BODY = "Fonts\\ARIALN.TTF"

-- ============================================================================
-- ACCENT COLOUR  (follows user's class-colour setting, else default cyan)
-- ============================================================================

local function GetAccentRGB()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then return cc[1], cc[2], cc[3] end
    return 0.2, 0.8, 0.9
end

local function AccentHex()
    local r, g, b = GetAccentRGB()
    return string.format("%02X%02X%02X",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5))
end

-- ============================================================================
-- VERSION / DB
-- ============================================================================

local function GetCurrentVersion()
    local gm = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return (gm and gm(addon.ADDON_NAME, "Version")) or ""
end

local function GetLastSeenVersion()
    local db = _G[addon.DB_NAME]
    return db and db.lastSeenPatchVersion or ""
end

local function SetLastSeenVersion(v)
    local db = _G[addon.DB_NAME]
    if not db then db = {}; _G[addon.DB_NAME] = db end
    db.lastSeenPatchVersion = v
end

-- ============================================================================
-- FRAME
-- ============================================================================

local panel

local function BuildPanel()
    panel = CreateFrame("Frame", "HorizonSuitePatchNotes", UIParent, "BackdropTemplate")
    panel:SetSize(W, H)
    panel:SetPoint("CENTER", 0, 30)
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:Hide()

    panel:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(BG_COL))
    panel:SetBackdropBorderColor(unpack(EDGE_COL))

    tinsert(UISpecialFrames, "HorizonSuitePatchNotes")

    -- ── Top accent strip ─────────────────────────────────────────────────────
    local accentStrip = panel:CreateTexture(nil, "OVERLAY")
    accentStrip:SetHeight(ACCENT_H)
    accentStrip:SetPoint("TOPLEFT",  1, -1)
    accentStrip:SetPoint("TOPRIGHT", -1, -1)
    panel.accentStrip = accentStrip

    -- ── Title zone (draggable) ───────────────────────────────────────────────
    local dragZone = CreateFrame("Frame", nil, panel)
    dragZone:SetPoint("TOPLEFT")
    dragZone:SetPoint("TOPRIGHT")
    dragZone:SetHeight(TITLE_H)
    dragZone:EnableMouse(true)
    dragZone:RegisterForDrag("LeftButton")
    dragZone:SetScript("OnDragStart", function()
        if not InCombatLockdown() then panel:StartMoving() end
    end)
    dragZone:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)

    -- "HORIZON SUITE" — addon identity (top line, larger)
    local suiteLbl = dragZone:CreateFontString(nil, "OVERLAY")
    suiteLbl:SetFont(F_HEAD, 13, "OUTLINE")
    suiteLbl:SetPoint("TOPLEFT", dragZone, "TOPLEFT", PAD, -(ACCENT_H + 10))
    suiteLbl:SetText("HORIZON SUITE")
    suiteLbl:SetTextColor(0.88, 0.88, 0.92)   -- near-white, distinct from accent

    -- "WHAT'S NEW" — subtitle (second line, accent)
    local titleLbl = dragZone:CreateFontString(nil, "OVERLAY")
    titleLbl:SetFont(F_BODY, 10, "")
    titleLbl:SetPoint("TOPLEFT", suiteLbl, "BOTTOMLEFT", 0, -3)
    panel.titleLbl = titleLbl   -- coloured at show-time

    -- Version badge (top-right, aligned with the HORIZON SUITE text line)
    local verLbl = dragZone:CreateFontString(nil, "OVERLAY")
    verLbl:SetFont(F_BODY, 10, "")
    verLbl:SetPoint("TOPRIGHT", dragZone, "TOPRIGHT", -38, -(ACCENT_H + 12))
    verLbl:SetTextColor(unpack(MUTED_COL))
    panel.vBadge = verLbl

    -- Close  ×
    local closeBtn = CreateFrame("Button", nil, dragZone)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", dragZone, "TOPRIGHT", -4, -(ACCENT_H + 8))

    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(1, 0.3, 0.3, 0)

    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    closeX:SetFont(F_HEAD, 13, "OUTLINE")
    closeX:SetPoint("CENTER")
    closeX:SetText("\195\151")   -- ×
    closeX:SetTextColor(0.36, 0.36, 0.42)

    closeBtn:SetScript("OnEnter", function()
        closeX:SetTextColor(1, 1, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0.2)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeX:SetTextColor(0.36, 0.36, 0.42)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    end)
    closeBtn:SetScript("OnClick", function() panel:Hide() end)

    -- Rule below title zone
    local topRule = panel:CreateTexture(nil, "ARTWORK")
    topRule:SetHeight(1)
    topRule:SetPoint("TOPLEFT",  PAD,  -TITLE_H)
    topRule:SetPoint("TOPRIGHT", -PAD, -TITLE_H)
    topRule:SetColorTexture(unpack(RULE_COL))

    -- ── Scroll frame ─────────────────────────────────────────────────────────
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
    scrollFrame:SetPoint("TOPLEFT",     PAD, -(TITLE_H + PAD))
    scrollFrame:SetPoint("BOTTOMRIGHT", -PAD, FOOTER_H)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur  = self:GetVerticalScroll() or 0
        local sc   = self:GetScrollChild()
        local maxS = sc and math.max(0, sc:GetHeight() - self:GetHeight()) or 0
        self:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * 22)))
    end)
    panel.scrollFrame = scrollFrame

    -- ── Footer ───────────────────────────────────────────────────────────────
    local footRule = panel:CreateTexture(nil, "ARTWORK")
    footRule:SetHeight(1)
    footRule:SetPoint("BOTTOMLEFT",  PAD,  FOOTER_H - 1)
    footRule:SetPoint("BOTTOMRIGHT", -PAD, FOOTER_H - 1)
    footRule:SetColorTexture(unpack(RULE_COL))

    -- Full changelog (text link, bottom-left)
    local changelogBtn = CreateFrame("Button", nil, panel)
    changelogBtn:SetSize(100, FOOTER_H)
    changelogBtn:SetPoint("BOTTOMLEFT", PAD, 0)

    local changelogTxt = changelogBtn:CreateFontString(nil, "OVERLAY")
    changelogTxt:SetFont(F_BODY, 12, "")
    changelogTxt:SetPoint("LEFT", 0, 0)
    changelogTxt:SetText("Full changelog")
    changelogTxt:SetTextColor(unpack(MUTED_COL))

    local changelogLine = changelogBtn:CreateTexture(nil, "ARTWORK")
    changelogLine:SetHeight(1)
    changelogLine:SetPoint("BOTTOMLEFT",  changelogTxt, "BOTTOMLEFT",  0, -2)
    changelogLine:SetPoint("BOTTOMRIGHT", changelogTxt, "BOTTOMRIGHT", 0, -2)
    changelogLine:SetColorTexture(1, 1, 1, 0)

    changelogBtn:SetScript("OnEnter", function()
        local ar, ag, ab = GetAccentRGB()
        changelogTxt:SetTextColor(ar, ag, ab)
        changelogLine:SetColorTexture(ar, ag, ab, 0.45)
        if GameTooltip then
            GameTooltip:SetOwner(changelogBtn, "ANCHOR_TOP")
            GameTooltip:SetText(CHANGELOG_URL, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    changelogBtn:SetScript("OnLeave", function()
        changelogTxt:SetTextColor(unpack(MUTED_COL))
        changelogLine:SetColorTexture(1, 1, 1, 0)
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    changelogBtn:SetScript("OnClick", function()
        if GameTooltip then GameTooltip:Hide() end
        if addon.ShowURLCopyBox then addon.ShowURLCopyBox(CHANGELOG_URL) end
    end)

    -- Dismiss (text link, bottom-right)
    local dismissBtn = CreateFrame("Button", nil, panel)
    dismissBtn:SetSize(90, FOOTER_H)
    dismissBtn:SetPoint("BOTTOMRIGHT", -PAD, 0)

    local dismissTxt = dismissBtn:CreateFontString(nil, "OVERLAY")
    dismissTxt:SetFont(F_BODY, 12, "")
    dismissTxt:SetPoint("RIGHT", 0, 0)
    dismissTxt:SetText("Dismiss")
    dismissTxt:SetTextColor(unpack(MUTED_COL))

    local dismissLine = dismissBtn:CreateTexture(nil, "ARTWORK")
    dismissLine:SetHeight(1)
    dismissLine:SetPoint("BOTTOMLEFT",  dismissTxt, "BOTTOMLEFT",  0, -2)
    dismissLine:SetPoint("BOTTOMRIGHT", dismissTxt, "BOTTOMRIGHT", 0, -2)
    dismissLine:SetColorTexture(1, 1, 1, 0)

    dismissBtn:SetScript("OnEnter", function()
        local ar, ag, ab = GetAccentRGB()
        dismissTxt:SetTextColor(ar, ag, ab)
        dismissLine:SetColorTexture(ar, ag, ab, 0.45)
    end)
    dismissBtn:SetScript("OnLeave", function()
        dismissTxt:SetTextColor(unpack(MUTED_COL))
        dismissLine:SetColorTexture(1, 1, 1, 0)
    end)
    dismissBtn:SetScript("OnClick", function() panel:Hide() end)
end

-- ============================================================================
-- CONTENT BUILDER
-- ============================================================================

local function BuildContent(version)
    -- Orphan old scroll child so its regions don't render
    if panel.scrollContent then
        panel.scrollContent:SetParent(nil)
    end

    panel.accentLabels = {}
    panel.accentBullets = {}

    local c = CreateFrame("Frame", nil, panel.scrollFrame)
    local cW = W - PAD * 2 - 2
    c:SetWidth(cW)
    c:SetHeight(1)
    panel.scrollFrame:SetScrollChild(c)
    panel.scrollContent = c

    local notes   = addon.PATCH_NOTES and addon.PATCH_NOTES[version]
    local items   = {}
    local hex     = AccentHex()

    if not notes then
        local lbl = c:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(F_BODY, 12, "")
        lbl:SetWidth(cW)
        lbl:SetJustifyH("CENTER")
        lbl:SetText("No notes available for this version.")
        lbl:SetTextColor(unpack(MUTED_COL))
        tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 0 })
    else
        for i, sec in ipairs(notes) do
            if i > 1 then
                tinsert(items, { type = "gap", h = SECTION_GAP })
            end

            -- Section label — uppercase, accent colour (stored for refresh on show)
            local lbl = c:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(F_HEAD, 10, "OUTLINE")
            lbl:SetWidth(cW)
            lbl:SetJustifyH("LEFT")
            lbl:SetText(sec.section)
            lbl:SetTextColor(GetAccentRGB())
            tinsert(panel.accentLabels, lbl)
            tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 5 })

            -- Thin rule below label
            local rule = c:CreateTexture(nil, "ARTWORK")
            rule:SetSize(cW, 1)
            rule:SetColorTexture(unpack(RULE_COL))
            tinsert(items, { type = "tex", tex = rule, gap = 8 })

            -- Bullets — accent dash prefix inline (stored for refresh on show)
            for _, bullet in ipairs(sec.bullets) do
                local txt = c:CreateFontString(nil, "OVERLAY")
                txt:SetFont(F_BODY, 12, "")
                txt:SetWidth(cW - BULLET_X)
                txt:SetJustifyH("LEFT")
                txt:SetWordWrap(true)
                txt:SetText("|cFF" .. hex .. "\226\128\148|r  " .. bullet)  -- — dash
                txt:SetTextColor(unpack(BODY_COL))
                tinsert(panel.accentBullets, { fs = txt, bullet = bullet })
                tinsert(items, { type = "fs", fs = txt, x = BULLET_X, gap = LINE_GAP })
            end
        end
    end

    -- Layout pass deferred one frame so string heights are computed
    C_Timer.After(0, function()
        if not (panel and panel:IsShown()) then return end
        local y = 0
        for _, item in ipairs(items) do
            if item.type == "fs" then
                item.fs:ClearAllPoints()
                item.fs:SetPoint("TOPLEFT", c, "TOPLEFT", item.x, y)
                y = y - math.max(item.fs:GetStringHeight(), 13) - item.gap
            elseif item.type == "tex" then
                item.tex:ClearAllPoints()
                item.tex:SetPoint("TOPLEFT", c, "TOPLEFT", 0, y)
                y = y - 1 - item.gap
            elseif item.type == "gap" then
                y = y - item.h
            end
        end
        c:SetHeight(math.max(1, -y))
        panel.scrollFrame:SetVerticalScroll(0)
    end)
end

-- ============================================================================
-- SHOW / HIDE
-- ============================================================================

local function FadeIn()
    panel:SetAlpha(0)
    panel:Show()
    local elapsed = 0
    panel:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        local t = math.min(elapsed / FADE_DUR, 1)
        self:SetAlpha(t)
        if t >= 1 then
            self:SetAlpha(1)
            self:SetScript("OnUpdate", nil)
        end
    end)
end

addon.ShowPatchNotes = function()
    if not panel then BuildPanel() end

    local ar, ag, ab = GetAccentRGB()
    local ver = GetCurrentVersion()

    panel.accentStrip:SetColorTexture(ar, ag, ab, 1)
    panel.titleLbl:SetText("WHAT'S NEW")
    panel.titleLbl:SetTextColor(ar, ag, ab)
    panel.vBadge:SetText(ver ~= "" and ("v" .. ver) or "")

    if ver ~= panel.builtVersion then
        local notes = addon.PATCH_NOTES
        BuildContent(ver ~= "" and ver or (notes and next(notes) or ""))
        panel.builtVersion = ver
    else
        -- Refresh accent-coloured content so it matches current class colour setting
        for _, lbl in ipairs(panel.accentLabels or {}) do
            if lbl and lbl.SetTextColor then lbl:SetTextColor(ar, ag, ab) end
        end
        local hex = AccentHex()
        for _, entry in ipairs(panel.accentBullets or {}) do
            if entry and entry.fs and entry.bullet then
                entry.fs:SetText("|cFF" .. hex .. "\226\128\148|r  " .. entry.bullet)
            end
        end
    end

    FadeIn()
end

addon.HidePatchNotes = function()
    if panel then panel:Hide() end
end

--- Refresh accent colours on the Patch Notes panel if it is visible (e.g. when "Class colours - Dashboard" is toggled).
--- Call from options when dashboardClassColor changes so the panel updates live.
function addon.ApplyPatchNotesAccent()
    if not panel or not panel:IsShown() then return end
    local ar, ag, ab = GetAccentRGB()
    panel.accentStrip:SetColorTexture(ar, ag, ab, 1)
    panel.titleLbl:SetTextColor(ar, ag, ab)
    for _, lbl in ipairs(panel.accentLabels or {}) do
        if lbl and lbl.SetTextColor then lbl:SetTextColor(ar, ag, ab) end
    end
    local hex = AccentHex()
    for _, entry in ipairs(panel.accentBullets or {}) do
        if entry and entry.fs and entry.bullet then
            entry.fs:SetText("|cFF" .. hex .. "\226\128\148|r  " .. entry.bullet)
        end
    end
end

-- ============================================================================
-- AUTO-SHOW ON LOGIN
-- ============================================================================

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    local cur = GetCurrentVersion()
    if cur == "" then return end
    if GetLastSeenVersion() ~= cur then
        SetLastSeenVersion(cur)
        if C_Timer and C_Timer.After then
            C_Timer.After(2.0, function()
                if addon.ShowPatchNotes then addon.ShowPatchNotes() end
            end)
        else
            addon.ShowPatchNotes()
        end
    end
end)
