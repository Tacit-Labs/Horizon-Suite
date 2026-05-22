--[[
    Horizon Suite - Dashboard Integrations view.
    Lists third-party addons Horizon Suite integrates with, plus an at-a-glance
    install/enable status indicator per row.

    Wired from DashboardFrame.lua via addon.DashboardIntegrationsView_Init(env).
    Data lives in options/dashboard/DashboardIntegrationsFeedData.lua.

    Features:
      - Per-row status pill (Installed / Disabled / Not installed / Bundled).
        The pill doubles as the call-to-action when the integration is
        actionable: missing → Install, disabled → Enable, pendingReload →
        Reload UI. Click is bound to the pill itself; colour conveys state.
      - Top summary line ("X of Y integrations active").
      - Addon's own IconTexture (from its TOC) when installed; curated fallback otherwise.
      - Version display next to title (from C_AddOns.GetAddOnMetadata "Version").
      - "Settings" link when installed and the integration has a registered slash key.
      - "NEW" badge for integrations the user hasn't seen yet (tracked in HorizonDB.integrationsSeen).
      - Subtle pulse on green ticks the first time the view is shown per session.
      - Refreshes on ADDON_LOADED while shown.
]]

local addon = _G.HorizonSuite
if not addon then return end

-- ---------------------------------------------------------------------------
-- State helpers
-- ---------------------------------------------------------------------------

--- @return string  "enabled" | "disabled" | "missing"
local function GetIntegrationState(name)
    if type(name) ~= "string" or name == "" then return "missing" end
    if not C_AddOns then return "missing" end

    if C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(name) then
        return "enabled"
    end

    if not C_AddOns.GetAddOnInfo then return "missing" end
    local _, _, _, loadable, reason = C_AddOns.GetAddOnInfo(name)
    if loadable == false and reason == "DISABLED" then
        return "disabled"
    end
    return "missing"
end

--- @return string|number|nil
local function ResolveAddonIconTexture(addonName)
    if type(addonName) ~= "string" or addonName == "" then return nil end
    if not C_AddOns or not C_AddOns.GetAddOnMetadata then return nil end
    local ok, tex = pcall(C_AddOns.GetAddOnMetadata, addonName, "IconTexture")
    if not ok then return nil end
    if tex == nil or tex == "" then return nil end
    return tex
end

--- @return string|nil
local function ResolveAddonVersion(addonName)
    if type(addonName) ~= "string" or addonName == "" then return nil end
    if not C_AddOns or not C_AddOns.GetAddOnMetadata then return nil end
    local ok, ver = pcall(C_AddOns.GetAddOnMetadata, addonName, "Version")
    if not ok or type(ver) ~= "string" or ver == "" then return nil end
    return ver
end

--- @param feed table|nil
--- @return table
local function GetSortedFeed(feed)
    local src = feed or addon.DashboardIntegrationsFeed
    if not src or #src == 0 then return {} end
    local t = {}
    for i = 1, #src do t[i] = src[i] end
    table.sort(t, function(a, b)
        return (a.sort or 0) > (b.sort or 0)
    end)
    return t
end

local function ApplyIntegrationIcon(tex, iconSpec)
    if type(iconSpec) == "table" and iconSpec.atlas and tex.SetAtlas then
        local atlas = iconSpec.atlas
        local gi = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
        if C_Texture and C_Texture.GetAtlasInfo and not gi and type(iconSpec.fallback) == "string" then
            tex:SetAtlas(nil)
            tex:SetTexture("Interface\\Icons\\" .. iconSpec.fallback)
        else
            tex:SetTexture(nil)
            pcall(function() tex:SetAtlas(atlas, true) end)
        end
    elseif type(iconSpec) == "number" then
        if tex.SetAtlas then tex:SetAtlas(nil) end
        tex:SetTexture(iconSpec)
    elseif type(iconSpec) == "string" then
        if tex.SetAtlas then tex:SetAtlas(nil) end
        if iconSpec:find("[\\/]") then
            tex:SetTexture(iconSpec)
        else
            tex:SetTexture("Interface\\Icons\\" .. iconSpec)
        end
    end
end

-- Persistent "seen" tracking: db.integrationsSeen = { [id] = true }.
local function GetSeenMap()
    local db = _G[addon.DATABASE]
    if not db then return {} end
    if type(db.integrationsSeen) ~= "table" then
        db.integrationsSeen = {}
    end
    return db.integrationsSeen
end

local function MarkSeen(id)
    if type(id) ~= "string" or id == "" then return end
    local seen = GetSeenMap()
    seen[id] = true
end

-- ---------------------------------------------------------------------------
-- Main init
-- ---------------------------------------------------------------------------

function addon.DashboardIntegrationsView_Init(env)
    local L                = env.L
    local integrationsView = env.targetView or env.integrationsView
    if not integrationsView then return end

    local MakeText            = env.MakeText
    local GetAccentColor      = env.GetAccentColor
    local dashAccentRefs      = env.dashAccentRefs
    local contentWidth        = env.contentWidth or 800
    local dashScrollTopOffset = env.dashScrollTopOffset or 0
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT or 1

    local WDef = addon.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT

    -- CARD_H sized so all six rows fit inside the scroll viewport at the
    -- default dashboard ratio (~552px tall): 6 rows + 5 gaps + summary + pad
    -- ≈ 540px. Internal Y offsets tighten in step so title/body/pill remain
    -- visually balanced inside the shorter card.
    local CARD_H              = 76
    local CARD_GAP            = 8
    local CARD_X_INSET        = 18
    local CARD_ACCENT_W       = 3
    local CARD_ICON_SIZE      = 36
    local CARD_ICON_X         = CARD_ACCENT_W + 12
    local CARD_ICON_PAD       = 1
    local CARD_TITLE_X        = CARD_ICON_X + CARD_ICON_SIZE + 12
    local CARD_TITLE_Y        = -10
    local CARD_BODY_Y         = -30
    local CARD_PILL_W         = 100
    local CARD_PILL_H         = 22
    local CARD_PILL_X         = -14
    local CARD_PILL_Y         = -8
    local CARD_VPILL_H        = 18
    local CARD_VPILL_GAP      = 4
    local CARD_LINK_X         = -14
    local CARD_LINK_Y         = 10                 -- from BOTTOM
    local NEW_BADGE_W         = 38
    local NEW_BADGE_H         = 16
    local SUMMARY_HEIGHT      = 24
    local SCROLL_BODY_X_INSET = 28
    local SCROLL_TOP_PAD      = 4
    local SCROLL_BOTTOM_PAD   = 20
    local SCROLL_DELTA_MULT   = 30

    -- { r, g, b, a, statusLocaleKey, pulseable }
    local STATUS_COLORS = {
        enabled       = { 0.20, 0.75, 0.30, 0.85, "DASH_INT_STATUS_ENABLED",  true },
        disabled      = { 0.95, 0.65, 0.20, 0.85, "DASH_INT_STATUS_DISABLED", false },
        missing       = { 0.90, 0.25, 0.25, 0.80, "DASH_INT_STATUS_MISSING",  false },
        bundled       = { 0.20, 0.75, 0.30, 0.85, "DASH_INT_STATUS_BUNDLED",  true },
        pendingReload = { 0.55, 0.55, 0.95, 0.85, "DASH_INT_STATUS_PENDING",  false },
    }

    local function GetEffectiveState(row)
        if row._pendingReload then return "pendingReload" end
        if row._bundled then return "bundled" end
        return GetIntegrationState(row._addonName)
    end

    -- One-shot pulse on green ticks each time the view is shown.
    local pulsedThisShow = false

    -- -----------------------------------------------------------------------
    -- Scroll plumbing
    -- -----------------------------------------------------------------------
    local scrollFrame = CreateFrame("ScrollFrame", nil, integrationsView)
    scrollFrame:SetPoint("TOPLEFT", SCROLL_BODY_X_INSET, dashScrollTopOffset)
    scrollFrame:SetPoint("BOTTOMRIGHT", -SCROLL_BODY_X_INSET, 24)
    scrollFrame:EnableMouseWheel(true)

    local scrollContent = CreateFrame("Frame", nil, scrollFrame)
    scrollContent:SetSize(contentWidth, 1)
    scrollFrame:SetScrollChild(scrollContent)

    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll() or 0
        local maxS = math.max(0, scrollContent:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * SCROLL_DELTA_MULT)))
    end)

    -- Track the dashboard frame's resize so the inner scroll content stays
    -- pinned to the live scroll viewport width. Rows anchor TOPLEFT/TOPRIGHT
    -- against the summary (which is anchored to scrollContent), so resizing
    -- scrollContent reflows body wrapping and pill/link positioning for free.
    integrationsView:HookScript("OnSizeChanged", function()
        local w = scrollFrame:GetWidth()
        if w and w > 0 then
            scrollContent:SetWidth(w)
        end
    end)

    -- -----------------------------------------------------------------------
    -- Summary header line ("X of Y integrations active")
    -- -----------------------------------------------------------------------
    local summary = MakeText(scrollContent, "", 12, 0.85, 0.85, 0.9, "LEFT")
    summary:SetPoint("TOPLEFT", CARD_X_INSET, -SCROLL_TOP_PAD)
    summary:SetPoint("TOPRIGHT", -CARD_X_INSET, -SCROLL_TOP_PAD)
    summary:SetHeight(SUMMARY_HEIGHT)
    summary:SetWordWrap(false)

    -- -----------------------------------------------------------------------
    -- Row factory + state apply
    -- -----------------------------------------------------------------------
    local rows = {}

    local function MaybePulseTick(row, state)
        if pulsedThisShow then return end
        local def = STATUS_COLORS[state]
        if not (def and def[6]) then return end
        if not row.pillText then return end
        local ag = row.pillPulse
        if not ag then
            ag = row.pill:CreateAnimationGroup()
            local a1 = ag:CreateAnimation("Alpha")
            a1:SetFromAlpha(1.0)
            a1:SetToAlpha(0.35)
            a1:SetDuration(0.22)
            a1:SetOrder(1)
            local a2 = ag:CreateAnimation("Alpha")
            a2:SetFromAlpha(0.35)
            a2:SetToAlpha(1.0)
            a2:SetDuration(0.35)
            a2:SetOrder(2)
            row.pillPulse = ag
        end
        ag:Stop()
        ag:Play()
    end

    -- State → action mapping. Each entry returns the CTA label and an action
    -- callback, OR nil to keep the pill informational (no click handler bound).
    local function ResolvePillAction(row, stateKey, defaultLabel)
        if stateKey == "missing" and row._doInstall then
            return L["DASH_INT_CTA_GET"] or "Install", row._doInstall
        end
        if stateKey == "disabled" and row._doEnable then
            return L["DASH_INT_CTA_ENABLE"] or "Enable", row._doEnable
        end
        if stateKey == "pendingReload" and row._doReload then
            return L["DASH_INT_CTA_RELOAD"] or "Reload UI", row._doReload
        end
        return defaultLabel, nil
    end

    local function ApplyRowState(row)
        local stateKey = GetEffectiveState(row)
        local s = STATUS_COLORS[stateKey] or STATUS_COLORS.missing
        row.pillBg:SetColorTexture(s[1], s[2], s[3], s[4])
        row._state = stateKey
        row._pillColor = s

        -- Pill label + click action. When the integration is actionable
        -- (missing / disabled / pendingReload) the pill itself becomes the CTA;
        -- otherwise the pill stays informational (Installed / Bundled).
        local defaultLabel = L[s[5]] or ""
        local ctaLabel, action = ResolvePillAction(row, stateKey, defaultLabel)
        row.pillText:SetText(ctaLabel)
        row._pillAction = action
        if row.pill.SetEnabled then
            row.pill:SetEnabled(action ~= nil)
        end

        -- Icon: addon's own IconTexture takes priority; fallback otherwise.
        if row._icon then
            local addonIcon = ResolveAddonIconTexture(row._addonName)
            ApplyIntegrationIcon(row._icon, addonIcon or row._fallbackIcon)
        end

        -- Version pill (sits underneath the status pill). Shows whenever the
        -- addon is present on disk — enabled or disabled — since GetAddOnMetadata
        -- reads from the TOC regardless of load state. Background tinted with
        -- the state colour at low alpha to pair visually with the status pill.
        if row.versionPill then
            local ver = ResolveAddonVersion(row._addonName)
            if ver then
                row.versionPillText:SetText("v" .. ver)
                if row.versionPillBg then
                    row.versionPillBg:SetColorTexture(s[1], s[2], s[3], 0.30)
                end
                row.versionPill:Show()
            else
                row.versionPill:Hide()
            end
        end

        -- Bottom-right Settings link (enabled state only — Install / Enable /
        -- Reload UI all live on the pill now).
        if row.linkSettings then
            if stateKey == "enabled" then
                local slashKey = row._slashKey
                local registered = type(slashKey) == "string" and _G.SlashCmdList and _G.SlashCmdList[slashKey]
                row.linkSettings:SetShown(registered and true or false)
            else
                row.linkSettings:Hide()
            end
        end

        MaybePulseTick(row, stateKey)
    end

    local function MakeLink(row, text, onClick, color)
        local r, g, b = color[1] or 0.75, color[2] or 0.85, color[3] or 1
        local link = CreateFrame("Button", nil, row)
        link:SetSize(96, 18)
        link:SetPoint("BOTTOMRIGHT", CARD_LINK_X, CARD_LINK_Y)
        local label = MakeText(link, text, 11, r, g, b, "RIGHT")
        label:SetAllPoints()
        link:SetScript("OnEnter", function() label:SetTextColor(1, 1, 1, 1) end)
        link:SetScript("OnLeave", function() label:SetTextColor(r, g, b, 1) end)
        link:SetScript("OnClick", onClick)
        link:Hide()
        return link
    end

    local function CreateRow(entry, index)
        local row = CreateFrame("Frame", nil, scrollContent)
        row:SetHeight(CARD_H)
        if index == 1 then
            row:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, -CARD_GAP)
            row:SetPoint("TOPRIGHT", summary, "BOTTOMRIGHT", 0, -CARD_GAP)
        else
            row:SetPoint("TOPLEFT", rows[index - 1], "BOTTOMLEFT", 0, -CARD_GAP)
            row:SetPoint("TOPRIGHT", rows[index - 1], "BOTTOMRIGHT", 0, -CARD_GAP)
        end

        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

        local accent = row:CreateTexture(nil, "ARTWORK")
        accent:SetWidth(CARD_ACCENT_W)
        accent:SetPoint("TOPLEFT", 0, 0)
        accent:SetPoint("BOTTOMLEFT", 0, 0)
        local ar, ag, ab = GetAccentColor()
        accent:SetColorTexture(ar, ag, ab, 0.85)
        if dashAccentRefs and dashAccentRefs.sidebarBars then
            table.insert(dashAccentRefs.sidebarBars, accent)
        end

        local iconFrame = row:CreateTexture(nil, "BORDER")
        iconFrame:SetSize(CARD_ICON_SIZE + CARD_ICON_PAD * 2, CARD_ICON_SIZE + CARD_ICON_PAD * 2)
        iconFrame:SetPoint("LEFT", CARD_ICON_X - CARD_ICON_PAD, 0)
        iconFrame:SetColorTexture(0.02, 0.02, 0.03, 0.9)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(CARD_ICON_SIZE, CARD_ICON_SIZE)
        icon:SetPoint("LEFT", CARD_ICON_X, 0)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- Optional NEW badge before the title (matches the dashboard news-badge style:
        -- cyan-tinted bg, light text). Fixed width — GetStringWidth at construction
        -- time can return 0 before the engine lays out the fontstring.
        local newBadge
        local seen = GetSeenMap()
        if entry.id and not seen[entry.id] then
            newBadge = CreateFrame("Frame", nil, row)
            newBadge:SetSize(NEW_BADGE_W, NEW_BADGE_H)
            newBadge:SetPoint("TOPLEFT", row, "TOPLEFT", CARD_TITLE_X, CARD_TITLE_Y - 2)
            local nbBg = newBadge:CreateTexture(nil, "ARTWORK")
            nbBg:SetAllPoints()
            nbBg:SetColorTexture(0.20, 0.80, 0.90, 0.18)
            local nbText = MakeText(newBadge, L["DASH_INT_NEW_BADGE"] or "New", 10, 0.78, 0.91, 1, "CENTER")
            nbText:SetAllPoints()
        end

        local titleX = CARD_TITLE_X + (newBadge and (NEW_BADGE_W + 8) or 0)

        local title = MakeText(row, entry.displayName or entry.addonName or "?", 14, 1, 1, 1, "LEFT")
        title:SetPoint("TOPLEFT", titleX, CARD_TITLE_Y)
        title:SetHeight(20)
        title:SetWordWrap(false)

        -- Description. Right edge stops before the pill column so the version pill
        -- (placed under the status pill) has room without overlapping the body text.
        local what = entry.whatKey and L[entry.whatKey] or ""
        local body = MakeText(row, what, 11, 0.72, 0.72, 0.78, "LEFT")
        body:SetPoint("TOPLEFT", CARD_TITLE_X, CARD_BODY_Y)
        body:SetPoint("RIGHT", row, "RIGHT", CARD_PILL_X - CARD_PILL_W - 8, 0)
        body:SetWordWrap(true)

        -- Action closures stored on the row — driven by the status pill button
        -- (see ResolvePillAction).
        if entry.url and addon.ShowURLCopyBox then
            row._doInstall = function()
                addon.ShowURLCopyBox(entry.url, entry.displayName or entry.addonName)
            end
        end

        if C_AddOns and C_AddOns.EnableAddOn then
            row._doEnable = function()
                local ok = pcall(C_AddOns.EnableAddOn, entry.addonName)
                if ok then
                    row._pendingReload = true
                    ApplyRowState(row)
                end
            end
        end

        row._doReload = function()
            if _G.ReloadUI then _G.ReloadUI() end
        end

        -- Bottom-right Settings link — separate concern from install/enable, so
        -- it stays in its existing position rather than moving onto the pill.
        local linkSettings
        if entry.slashKey then
            linkSettings = MakeLink(row,
                (L["DASH_INT_CTA_SETTINGS"] or "Settings"),
                function()
                    local fn = _G.SlashCmdList and _G.SlashCmdList[entry.slashKey]
                    if type(fn) == "function" then
                        pcall(fn, "")
                    end
                end,
                { 0.72, 0.72, 0.78 }
            )
        end
        row.linkSettings = linkSettings

        -- Status pill — Button so it can act as the Install / Enable / Reload UI
        -- CTA when the integration is in an actionable state. ApplyRowState
        -- swaps the label and enabled flag based on the row's resolved state.
        local pill = CreateFrame("Button", nil, row)
        pill:SetSize(CARD_PILL_W, CARD_PILL_H)
        pill:SetPoint("TOPRIGHT", CARD_PILL_X, CARD_PILL_Y)
        local pillBg = pill:CreateTexture(nil, "BACKGROUND")
        pillBg:SetAllPoints()
        local pillText = MakeText(pill, "", 11, 1, 1, 1, "CENTER")
        pillText:SetAllPoints()
        pillText:SetJustifyV("MIDDLE")
        pill:SetScript("OnEnter", function()
            local c = row._pillColor
            if row._pillAction and c then
                pillBg:SetColorTexture(
                    math.min(1, c[1] * 1.25),
                    math.min(1, c[2] * 1.25),
                    math.min(1, c[3] * 1.25),
                    math.min(1, (c[4] or 0.85) + 0.1)
                )
            end
        end)
        pill:SetScript("OnLeave", function()
            local c = row._pillColor
            if c then
                pillBg:SetColorTexture(c[1], c[2], c[3], c[4])
            end
        end)
        pill:SetScript("OnClick", function()
            if type(row._pillAction) == "function" then
                row._pillAction()
            end
        end)
        row.pill, row.pillBg, row.pillText = pill, pillBg, pillText

        -- Version pill — sits directly beneath the status pill. Background is
        -- tinted with the state colour (low alpha) by ApplyRowState so the two
        -- pills read as a paired status block.
        local versionPill = CreateFrame("Frame", nil, row)
        versionPill:SetSize(CARD_PILL_W, CARD_VPILL_H)
        versionPill:SetPoint("TOP", pill, "BOTTOM", 0, -CARD_VPILL_GAP)
        local vpBg = versionPill:CreateTexture(nil, "BACKGROUND")
        vpBg:SetAllPoints()
        vpBg:SetColorTexture(0.10, 0.10, 0.13, 0.85)
        local vpText = MakeText(versionPill, "", 10, 0.92, 0.92, 0.95, "CENTER")
        vpText:SetAllPoints()
        vpText:SetJustifyV("MIDDLE")
        versionPill:Hide()
        row.versionPill, row.versionPillBg, row.versionPillText = versionPill, vpBg, vpText

        row._addonName     = entry.addonName
        row._slashKey      = entry.slashKey
        row._bundled       = entry.bundled and true or false
        row._icon          = icon
        row._fallbackIcon  = entry.icon
        row._newBadge      = newBadge

        row:SetScript("OnEnter", function()
            if entry.descKey and L[entry.descKey] then
                GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
                GameTooltip:SetText(entry.displayName or entry.addonName, 1, 1, 1)
                GameTooltip:AddLine(L[entry.descKey], 0.85, 0.85, 0.9, true)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        ApplyRowState(row)
        return row
    end

    -- -----------------------------------------------------------------------
    -- Summary refresh
    -- -----------------------------------------------------------------------
    local function RefreshSummary()
        local total, active, disabled = 0, 0, 0
        for _, row in ipairs(rows) do
            total = total + 1
            local s = row._state
            if s == "enabled" or s == "bundled" then
                active = active + 1
            elseif s == "disabled" then
                disabled = disabled + 1
            end
        end

        if total == 0 then
            summary:SetText("")
            return
        end

        if active == 0 and disabled == 0 then
            -- Empty state: none installed at all.
            summary:SetText(L["DASH_INT_SUMMARY_EMPTY"] or "These addons aren't installed yet — try them to unlock extra features.")
            summary:SetTextColor(0.78, 0.78, 0.85)
            return
        end

        local base = (L["DASH_INT_SUMMARY"] or "%d of %d integrations active"):format(active, total)
        if disabled > 0 then
            base = base .. "  ·  " .. (L["DASH_INT_SUMMARY_DISABLED"] or "%d disabled"):format(disabled)
        end
        summary:SetText(base)
        summary:SetTextColor(0.85, 0.85, 0.9)
    end

    -- -----------------------------------------------------------------------
    -- Sidebar (New!) suffix — mirrors the pattern used by the Patch Notes
    -- sidebar entry (DASH_WHATS_NEW_UNREAD_SUFFIX). Shows when any integration
    -- in the feed has an id that is not yet in db.integrationsSeen.
    -- -----------------------------------------------------------------------
    local function RefreshSidebarBadge()
        local btn = env.f and env.f.integrationsSidebarBtn
        if not btn or not btn.label then return end
        local base = btn._integrationsBaseText
        if not base or base == "" then
            base = btn.label:GetText() or ""
            btn._integrationsBaseText = base
        end
        local seen = GetSeenMap()
        local hasUnseen = false
        if addon.DashboardIntegrationsFeed then
            for _, entry in ipairs(addon.DashboardIntegrationsFeed) do
                if entry.id and not seen[entry.id] then
                    hasUnseen = true
                    break
                end
            end
        end
        if hasUnseen then
            btn.label:SetText(base .. (L["DASH_WHATS_NEW_UNREAD_SUFFIX"] or " (New!)"))
        else
            btn.label:SetText(base)
        end
    end

    -- -----------------------------------------------------------------------
    -- Initial population
    -- -----------------------------------------------------------------------
    local sorted = GetSortedFeed()
    for i, entry in ipairs(sorted) do
        rows[i] = CreateRow(entry, i)
    end
    local totalH = SCROLL_TOP_PAD + SUMMARY_HEIGHT + CARD_GAP + (#rows * (CARD_H + CARD_GAP)) + SCROLL_BOTTOM_PAD
    scrollContent:SetHeight(totalH)
    RefreshSummary()
    -- The Integrations sidebar button is created LATER in the dashboard build
    -- flow than this view init (line ~1757 vs line ~1463 in DashboardFrame.lua),
    -- so we can't query it directly here. Hook the dashboard frame's OnShow
    -- instead — it fires after the build completes and on every subsequent open.
    if env.f and env.f.HookScript then
        env.f:HookScript("OnShow", RefreshSidebarBadge)
    end

    -- -----------------------------------------------------------------------
    -- ADDON_LOADED refresh while view is shown
    -- -----------------------------------------------------------------------
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:SetScript("OnEvent", function(_, _, loadedName)
        if not integrationsView:IsShown() then return end
        local matched = false
        for _, row in ipairs(rows) do
            if row._addonName == loadedName then
                ApplyRowState(row)
                matched = true
            end
        end
        if matched then RefreshSummary() end
    end)

    integrationsView:HookScript("OnShow", function()
        pulsedThisShow = false
        for _, row in ipairs(rows) do
            ApplyRowState(row)
        end
        RefreshSummary()
        pulsedThisShow = true
    end)

    -- After the user opens the view, mark every shown integration as "seen"
    -- (so the New badge stops showing for them in future sessions) and
    -- refresh the sidebar suffix so it clears immediately.
    integrationsView:HookScript("OnHide", function()
        for i, entry in ipairs(sorted) do
            if entry.id then MarkSeen(entry.id) end
            local nb = rows[i] and rows[i]._newBadge
            if nb then nb:Hide() end
        end
        RefreshSidebarBadge()
    end)
end
