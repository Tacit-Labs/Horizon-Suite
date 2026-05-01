--[[
    Horizon Suite - Patch Notes Modal

    Standalone "what's new" popup shown on /reload after a version bump.
    Lives outside the dashboard — does not touch dashboardLastView, does not
    open the dashboard. Renders via the shared addon.PatchNotes_BuildContent
    helper so the layout matches the inline dashboard view exactly.

    Public API:
        addon.PatchNotes_ShowModal(versionString)
        addon.PatchNotes_HideModal()

    Dismiss behaviour: closes the modal, calls PatchNotes_MarkCurrentVersionViewed()
    so the unread indicator clears just like opening the inline view does.
]]


local addon = _G.HorizonSuite

local L = (addon.L) or setmetatable({}, { __index = function(_, k) return k end })

local MODAL_W            = 544
local MODAL_H            = 459
local MODAL_PAD          = 18
local MODAL_TITLE_H      = 50
local MODAL_FOOTER_H     = 56
local MODAL_LOGO_SIZE    = 32
local MODAL_LOGO_PATH    = "Interface\\AddOns\\HorizonSuite\\HorizonLogo"
local MODAL_BTN_W        = 168
local MODAL_BTN_H        = 24
local MODAL_BTN_GAP      = 12
local MODAL_FRAME_NAME   = "HorizonSuitePatchNotesModal"

-- Match core/UrlCopyDialog.lua chrome — same button look used by every Horizon
-- popup (footer link copy boxes, etc.) so dialog buttons feel uniform.
local MODAL_BTN_FONT     = "Fonts\\FRIZQT__.TTF"
local MODAL_BTN_FONT_SZ  = 10
local MODAL_BTN_BG_COL   = { 0.20, 0.20, 0.26, 0.60 }
local MODAL_BTN_TXT_COL  = { 0.90, 0.90, 0.92 }

-- Inherit the dashboard's accent color helper if present; otherwise fall back
-- to the white-default and a hardcoded dim accent so the modal still renders
-- before the dashboard frame has ever been built.
local function ResolveAccentColor()
    if addon.Dashboard_GetClassAccentColorRGB then
        local r, g, b = addon.Dashboard_GetClassAccentColorRGB()
        if r and g and b then return r, g, b end
    end
    if addon.GetClassAccentColor then
        local r, g, b = addon.GetClassAccentColor()
        if r and g and b then return r, g, b end
    end
    return 0.45, 0.7, 1.0
end

-- Build one popup-style footer button. Background defaults to the muted
-- bevel; hover shifts to a 50%-tinted version of the live accent. The accent
-- is read at hover-time so class-colour changes apply immediately.
local function CreateModalFooterButton(parent, text, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(MODAL_BTN_W, MODAL_BTN_H)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(MODAL_BTN_BG_COL))
    btn._bg = bg

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont(MODAL_BTN_FONT, MODAL_BTN_FONT_SZ, "")
    lbl:SetPoint("CENTER")
    lbl:SetText(text)
    lbl:SetTextColor(unpack(MODAL_BTN_TXT_COL))
    btn._label = lbl

    btn:SetScript("OnEnter", function()
        local ar, ag, ab = ResolveAccentColor()
        bg:SetColorTexture(ar * 0.5, ag * 0.5, ab * 0.5, 0.5)
    end)
    btn:SetScript("OnLeave", function()
        bg:SetColorTexture(unpack(MODAL_BTN_BG_COL))
    end)
    btn:SetScript("OnClick", onClick)
    return btn
end

local modal -- lazy-built singleton

local function BuildModal()
    if modal then return modal end

    -- Click-blocker behind the modal, sized to UIParent. Eats mouse input so
    -- the user can't click through to the dashboard / world UI underneath.
    local blocker = CreateFrame("Frame", nil, UIParent)
    blocker:SetAllPoints(UIParent)
    blocker:SetFrameStrata("FULLSCREEN_DIALOG")
    blocker:EnableMouse(true)
    blocker:Hide()
    local dim = blocker:CreateTexture(nil, "BACKGROUND")
    dim:SetAllPoints()
    dim:SetColorTexture(0, 0, 0, 0.55)

    -- Modal frame proper. Sits one strata above the blocker.
    local f = CreateFrame("Frame", MODAL_FRAME_NAME, blocker, "BackdropTemplate")
    f:SetSize(MODAL_W, MODAL_H)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(blocker:GetFrameLevel() + 10)
    f:EnableMouse(true)
    f:SetToplevel(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true,
        tileSize = 16,
        edgeSize = 14,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.06, 0.06, 0.08, 0.97)
    f:SetBackdropBorderColor(0.18, 0.20, 0.24, 0.85)

    -- Header bar: Horizon Suite logo + brand line on top, accent subtitle
    -- ("Patch Notes — v4.15.5") below — mirrors the URL-copy popup chrome so
    -- branding is consistent across Horizon dialogs.
    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetSize(MODAL_LOGO_SIZE, MODAL_LOGO_SIZE)
    logo:SetPoint("TOPLEFT", f, "TOPLEFT", MODAL_PAD, -MODAL_PAD)
    logo:SetTexture(MODAL_LOGO_PATH)
    f._logo = logo

    local brand = f:CreateFontString(nil, "OVERLAY")
    brand:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    brand:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, -2)
    brand:SetText((L["NAME_ADDON"] or "Horizon Suite"):upper())
    brand:SetTextColor(0.88, 0.88, 0.92)
    f._brand = brand

    -- Modal-specific subtitle: "What's New" + version, accent coloured.
    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\ARIALN.TTF", 11, "")
    title:SetPoint("TOPLEFT", brand, "BOTTOMLEFT", 0, -3)
    title:SetText(L["DASH_WHATS_NEW"] or "What's New")
    f._title = title

    local versionLabel = f:CreateFontString(nil, "OVERLAY")
    versionLabel:SetFont("Fonts\\ARIALN.TTF", 11, "")
    versionLabel:SetPoint("LEFT", title, "RIGHT", 6, 0)
    versionLabel:SetTextColor(0.55, 0.55, 0.62, 1)
    f._versionLabel = versionLabel

    local rule = f:CreateTexture(nil, "ARTWORK")
    rule:SetHeight(1)
    rule:SetPoint("TOPLEFT", f, "TOPLEFT", MODAL_PAD, -(MODAL_PAD + MODAL_TITLE_H))
    rule:SetPoint("TOPRIGHT", f, "TOPRIGHT", -MODAL_PAD, -(MODAL_PAD + MODAL_TITLE_H))
    f._rule = rule

    -- Close (×) button — top-right, mirrors the dashboard's close style.
    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeTxt:SetPoint("CENTER", 0, 0)
    closeTxt:SetText("\195\151") -- ×
    closeTxt:SetTextColor(0.55, 0.55, 0.6)
    closeBtn:SetScript("OnEnter", function()
        closeTxt:SetTextColor(1, 1, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0.25)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeTxt:SetTextColor(0.55, 0.55, 0.6)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    end)
    closeBtn:SetScript("OnClick", function() addon.PatchNotes_HideModal() end)

    -- Body scroll area (sized at show-time so version-label / footer can grow).
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",  f, "TOPLEFT",  MODAL_PAD,
                    -(MODAL_PAD + MODAL_TITLE_H + 8))
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",
                    -(MODAL_PAD + 22), MODAL_FOOTER_H)
    f._scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    local contentW = MODAL_W - (MODAL_PAD * 2) - 22
    content:SetSize(contentW, 1)
    scroll:SetScrollChild(content)
    f._content   = content
    f._contentW  = contentW

    if addon.Dashboard_ApplySmoothScroll then
        addon.Dashboard_ApplySmoothScroll(scroll, content, 60, true)
    end

    -- Footer rule + popup-style action buttons.
    local footRule = f:CreateTexture(nil, "ARTWORK")
    footRule:SetHeight(1)
    footRule:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", MODAL_PAD, MODAL_FOOTER_H - 8)
    footRule:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -MODAL_PAD, MODAL_FOOTER_H - 8)
    f._footRule = footRule

    -- Footer holds two popup-style buttons centred as a pair:
    -- [View all patch notes] [Dismiss]. Same chrome as the URL-copy dialog so
    -- every Horizon popup's footer feels uniform.
    local viewAll = CreateModalFooterButton(
        f,
        L["DASH_PATCH_NOTES_VIEW_ALL"] or "View all patch notes",
        function()
            if modal and modal.frame   then modal.frame:Hide()   end
            if modal and modal.blocker then modal.blocker:Hide() end
            if addon.ShowPatchNotes then addon.ShowPatchNotes() end
        end
    )
    viewAll:SetPoint("BOTTOM", f, "BOTTOM",
                     -((MODAL_BTN_W + MODAL_BTN_GAP) / 2), MODAL_PAD)
    f._viewAll = viewAll

    local dismiss = CreateModalFooterButton(
        f,
        L["DASH_PATCH_NOTES_DISMISS"] or "Dismiss",
        function() addon.PatchNotes_HideModal() end
    )
    dismiss:SetPoint("BOTTOM", f, "BOTTOM",
                     ((MODAL_BTN_W + MODAL_BTN_GAP) / 2), MODAL_PAD)
    f._dismiss = dismiss

    -- Esc closes the modal. EnableKeyboard / SetPropagateKeyboardInput are
    -- protected, so guard with combat-lockdown + pcall (mirrors the dashboard's
    -- DashboardApplyKeyboardPropagation pattern).
    f:SetScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" then addon.PatchNotes_HideModal() end
    end)
    f._applyKeyboardPropagation = function()
        if not f or f:IsForbidden() then return end
        if InCombatLockdown() then return end
        pcall(function()
            if f.EnableKeyboard then f:EnableKeyboard(true) end
            f:SetPropagateKeyboardInput(false)
        end)
    end

    f:Hide()
    blocker:Hide()

    modal = {
        blocker      = blocker,
        frame        = f,
        scroll       = scroll,
        content      = content,
        contentW     = contentW,
        title        = title,
        versionLabel = versionLabel,
        rule         = rule,
        footRule     = footRule,
        accentRefs   = { sectionLabels = {}, bullets = {}, rules = {} },
        typoRefs     = {},
        builtVersion = nil,
        innerFrame   = nil,
        layoutItems  = nil,
    }
    return modal
end

local function ApplyAccentToModal(m)
    local r, g, b = ResolveAccentColor()
    if m.title and m.title.SetTextColor then m.title:SetTextColor(r, g, b) end
    if m.rule and m.rule.SetColorTexture then m.rule:SetColorTexture(r, g, b, 0.4) end
    if m.footRule and m.footRule.SetColorTexture then m.footRule:SetColorTexture(r, g, b, 0.25) end
end

local function RebuildContent(m, version)
    -- Orphan previous inner so its child regions stop rendering.
    if m.innerFrame then m.innerFrame:SetParent(nil) end
    wipe(m.accentRefs.sectionLabels)
    wipe(m.accentRefs.bullets)
    wipe(m.accentRefs.rules)
    wipe(m.typoRefs)

    local result = addon.PatchNotes_BuildContent({
        parent         = m.content,
        width          = m.contentW,
        version        = version or "",
        maxVersions    = 1,
        GetAccentColor = ResolveAccentColor,
        accentRefs     = m.accentRefs,
        typoRefs       = m.typoRefs,
    })
    m.innerFrame   = result.inner
    m.layoutItems  = result.items
    m.builtVersion = result.builtVersion

    -- Defer one frame so font strings have measured before we read string heights.
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if not (m and m.frame and m.frame:IsShown()) then return end
            local h = addon.PatchNotes_ApplyLayout(m.layoutItems, m.innerFrame) or 1
            m.content:SetHeight(h)
            m.scroll:SetVerticalScroll(0)
        end)
    else
        local h = addon.PatchNotes_ApplyLayout(m.layoutItems, m.innerFrame) or 1
        m.content:SetHeight(h)
    end
end

function addon.PatchNotes_ShowModal(version)
    local m = BuildModal()

    local resolvedVersion = version
    if not resolvedVersion or resolvedVersion == "" then
        local gm = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
        resolvedVersion = (gm and gm(addon.ADDON_NAME or "HorizonSuite", "Version")) or ""
    end

    if m.versionLabel then
        if resolvedVersion ~= "" then
            m.versionLabel:SetText("v" .. resolvedVersion)
            m.versionLabel:Show()
        else
            m.versionLabel:Hide()
        end
    end

    ApplyAccentToModal(m)

    if m.builtVersion ~= resolvedVersion then
        RebuildContent(m, resolvedVersion)
    else
        -- Same content already built; just reset scroll.
        if m.scroll and m.scroll.SetVerticalScroll then m.scroll:SetVerticalScroll(0) end
    end

    m.blocker:Show()
    m.frame:Show()
    m.frame:Raise()
    if m.frame._applyKeyboardPropagation then m.frame._applyKeyboardPropagation() end

    -- Register for ESC handling. UISpecialFrames is checked by Blizzard's
    -- CloseAllWindows / Esc handler; idempotent re-add is safe.
    if _G.UISpecialFrames then
        local already = false
        for _, name in ipairs(_G.UISpecialFrames) do
            if name == MODAL_FRAME_NAME then already = true; break end
        end
        if not already then table.insert(_G.UISpecialFrames, MODAL_FRAME_NAME) end
    end
end

function addon.PatchNotes_HideModal()
    if not modal then return end
    local wasShown = modal.frame and modal.frame:IsShown()
    if modal.frame   then modal.frame:Hide()   end
    if modal.blocker then modal.blocker:Hide() end
    -- Mirror the inline view: dismissing the modal counts as "viewed", so the
    -- minimap pip / sidebar New! indicator clears.
    if wasShown and addon.PatchNotes_MarkCurrentVersionViewed then
        addon.PatchNotes_MarkCurrentVersionViewed()
    end
end
