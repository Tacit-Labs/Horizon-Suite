--[[
    Horizon Suite – Dashboard Accordion Detail Builder
    Assigns f.BuildAccordionDetail — the widget-building loop that populates accordion
    cards from an OptionCategory options array.
    Exposed as addon.DashboardAccordionBuild_Init(f, p).
    Called from DashboardDetailView.lua after all closure dependencies are defined.
    p fields: L, MakeText, SBg, SBd, SBgA, UpdateDetailLayout, accordionCardParams,
              currentDetailCards, detailContent, detailScroll, detailView
]]

local addon = _G.HorizonSuite
if not addon then return end

--- @param f frame  The main dashboard frame (_G.HorizonSuiteDashboard)
--- @param p table  Closure dependencies from DashboardDetailView_Init
function addon.DashboardAccordionBuild_Init(f, p)
    local L                  = p.L
    local MakeText           = p.MakeText
    local SBg                = p.SBg
    local SBd                = p.SBd
    local SBgA               = p.SBgA
    local UpdateDetailLayout = p.UpdateDetailLayout
    local accordionCardParams = p.accordionCardParams
    local currentDetailCards = p.currentDetailCards
    local detailContent      = p.detailContent
    local detailScroll       = p.detailScroll
    local detailView         = p.detailView

    local function CreateAccordionCard(parent, title, headerToggleCfg, desc)
        return addon.Dashboard_CreateAccordionCard(parent, title, headerToggleCfg, accordionCardParams, desc)
    end

    -- A subheading inside a card: a small muted label with a faint 1px rule running from the
    -- label to the row's right edge. It sits Def.SubheadingTopGap below the row above and takes
    -- the same left inset as the rows (DoInstantRelayout anchors it).
    local SUBHEADING_HEIGHT = 14
    local SUBHEADING_RULE_GAP = 8
    local SUBHEADING_RULE_MIN = 16
    local function CreateSubheading(parent, name)
        local WDef = addon.OptionsWidgetsDef
        local tc = WDef.TextColorSection
        local rc = WDef.DividerColor
        if type(name) == "function" then name = name() end
        local row = CreateFrame("Frame", nil, parent)
        row:SetHeight(SUBHEADING_HEIGHT)
        local label = MakeText(row, tostring(name or ""), WDef.SectionSize, tc[1], tc[2], tc[3], "LEFT")
        label:SetPoint("LEFT", row, "LEFT", 0, 0)
        if label.SetWordWrap then label:SetWordWrap(false) end
        if label.SetNonSpaceWrap then label:SetNonSpaceWrap(false) end
        if label.SetMaxLines then label:SetMaxLines(1) end
        local rule
        if row.CreateTexture then
            rule = row:CreateTexture(nil, "ARTWORK")
            rule:SetHeight(1)
            rule:SetPoint("LEFT", label, "RIGHT", SUBHEADING_RULE_GAP, 0)
            rule:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            rule:SetColorTexture(rc[1], rc[2], rc[3], rc[4])
            row._rule = rule
        end
        -- Keep the label inside the row (truncated when it is too long), and show the rule only
        -- while it has room to the label's right. Re-run whenever the row's size or the
        -- dashboard font changes its width.
        local function Fit()
            local rowW = row:GetWidth() or 0
            if rowW <= 0 then return end
            local textW = (label.GetUnboundedStringWidth and label:GetUnboundedStringWidth()) or label:GetStringWidth() or 0
            local maxW = math.max(1, rowW - SUBHEADING_RULE_GAP - SUBHEADING_RULE_MIN)
            local w = math.min(math.ceil(textW), maxW)
            -- Width 0 lets a label that fits size itself, so a later font change still shows it whole.
            label:SetWidth(textW > maxW and maxW or 0)
            if rule then rule:SetShown(rowW - w - SUBHEADING_RULE_GAP >= SUBHEADING_RULE_MIN) end
        end
        row:SetScript("OnSizeChanged", Fit)
        row:SetScript("OnShow", Fit)
        row.label = label
        return row
    end

    -- A header row a module writes itself is a note, often a full sentence: muted text that
    -- wraps across the row, at least NOTE_MIN_HEIGHT tall. Only the assembler's subheadings
    -- (opt._subheading) use CreateSubheading.
    local NOTE_MIN_HEIGHT = 20
    local function CreateNote(parent, text)
        local WDef = addon.OptionsWidgetsDef
        local tc = WDef.TextColorSection
        if type(text) == "function" then text = text() end
        local note = MakeText(parent, tostring(text or ""), WDef.SectionSize, tc[1], tc[2], tc[3], "LEFT")
        if note.SetWordWrap then note:SetWordWrap(true) end
        return note
    end

    f.BuildAccordionDetail = function(moduleSubName, options)
        local currentCard = nil
        local detailOptionFrames = {}

        -- skipDbKey: do not Refresh the control that initiated the change — Refresh() snaps the
        -- pill thumb and cancels CreateToggleSwitch's slide animation (feels broken vs other toggles).
        local function RefreshLinkedTargets(refreshIds, skipDbKey)
            if not refreshIds then return end
            for _, k in ipairs(refreshIds) do
                if k ~= skipDbKey then
                    local w = detailOptionFrames[k]
                    if w and w.Refresh then w:Refresh() end
                end
            end
            if addon.Presence and addon.Presence.RefreshPreviewTargets then
                addon.Presence.RefreshPreviewTargets()
            end
        end

        local DEPENDENT_FADE_DUR = 0.12
        local DEPENDENT_HEIGHT_DUR = 0.15
        local CARD_VISIBILITY_FADE_DUR = 0.3
        local easeOutDep = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end

        -- Animate a card's alpha + height together. direction = "in" or "out".
        -- For "in", targetHeight is required.
        local function AnimateCardVisibility(card, direction, targetHeight)
            if not card then return end
            local fadingIn = direction == "in"
            -- Cancel any opposing fade in-flight; this animation takes ownership.
            card._visibilityFadingIn = nil
            card._visibilityFadingOut = nil
            if fadingIn then
                if not card:IsShown() then card:SetShown(true) end
                card:SetAlpha(0)
                card:SetHeight(0.01)
                card._visibilityFadingIn = true
            else
                if not card:IsShown() then
                    card:SetHeight(0)
                    return
                end
                card._visibilityFadingOut = true
            end

            local startAlpha = card:GetAlpha() or (fadingIn and 0 or 1)
            local startHeight = card:GetHeight() or 0
            local endAlpha = fadingIn and 1 or 0
            -- Read each tick: a row that changes height mid-fade moves the target (OnRowHeightChanged).
            card._fadeTargetHeight = fadingIn and targetHeight or 0

            local animFrame = card.relayoutAnimFrame
            if not animFrame then
                animFrame = CreateFrame("Frame", nil, card)
                animFrame:SetAllPoints(card)
                card.relayoutAnimFrame = animFrame
            end
            local elapsed = 0
            animFrame:SetScript("OnUpdate", function(self, dt)
                local ownerFlag = fadingIn and card._visibilityFadingIn or (not fadingIn and card._visibilityFadingOut)
                if not ownerFlag then
                    self:SetScript("OnUpdate", nil)
                    return
                end
                elapsed = elapsed + dt
                local t = math.min(1, elapsed / CARD_VISIBILITY_FADE_DUR)
                local ep = easeOutDep(t)
                card:SetAlpha(startAlpha + (endAlpha - startAlpha) * ep)
                local endHeight = card._fadeTargetHeight or 0
                card:SetHeight(math.max(0.01, startHeight + (endHeight - startHeight) * ep))
                UpdateDetailLayout()
                if t >= 1 then
                    self:SetScript("OnUpdate", nil)
                    card._visibilityFadingIn = nil
                    card._visibilityFadingOut = nil
                    -- Re-check final condition: visibility may have flipped during the fade.
                    local wantVisible = not card.visibleWhen or card.visibleWhen()
                    if wantVisible then
                        card:SetAlpha(1)
                        card:SetHeight(card.expanded and (card.fullHeight or targetHeight or 0) or (card.collapsedHeight or 0))
                    else
                        card:SetShown(false)
                        card:SetHeight(0)
                        card:SetAlpha(1)
                    end
                    UpdateDetailLayout()
                end
            end)
        end

        local function FadeOutConditionalCard(card)
            if not card or card._visibilityFadingOut then return end
            AnimateCardVisibility(card, "out")
        end

        -- A hairline above a row (Def.RowDivider), spanning the card's content width whatever
        -- the row's indent. A child of the row, so it fades and hides with it.
        local function SetRowDivider(frame, show, indentX, gapAbove)
            local div = frame._rowDivider
            if not show then
                if div then div:Hide() end
                return
            end
            if not div then
                if not frame.CreateTexture then return end
                local c = addon.OptionsWidgetsDef.RowDivider
                div = frame:CreateTexture(nil, "ARTWORK")
                div:SetColorTexture(c[1], c[2], c[3], c[4])
                div:SetHeight(1)
                frame._rowDivider = div
            end
            div:ClearAllPoints()
            div:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -indentX, gapAbove)
            div:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, gapAbove)
            div:Show()
        end

        -- Rows staggering in as the player opens a card (spec item 3): each visible row fades
        -- from 0 and rises Def.RowRise px into place, Def.RowStagger after the row above, the
        -- whole sequence capped at Def.RowStaggerCap. card._rowStagger holds the state. The rise
        -- is an offset added to the y DoInstantRelayout computes, so a relayout mid-sequence
        -- reapplies it rather than fighting it; every relayout pass remembers each row's base
        -- anchor in frame._hsRowX/_hsRowY.
        local RowStaggerAt = addon.OptionsWidgets_RowStaggerAt
        local RowStaggerSchedule = addon.OptionsWidgets_RowStaggerSchedule

        -- A row's alpha and y offset now: 1 and 0 unless a running stagger owns it.
        local function RowStaggerLook(card, frame)
            local st = card._rowStagger
            local idx = st and st.index[frame]
            if not idx then return 1, 0 end
            local alpha, dy = RowStaggerAt(idx, st.t, st.step, st.dur, st.rise)
            return alpha, dy
        end

        local function PlaceStaggerRow(card, frame, alpha, dy)
            frame:SetAlpha(alpha)
            if frame._hsRowX then
                -- Replaces only the TOPLEFT point; the RIGHT point relayout set stays.
                frame:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", frame._hsRowX, frame._hsRowY + dy)
            end
        end

        -- End the stagger now: every row it owned sits exactly in place at alpha 1. Hidden rows
        -- stay hidden (alpha alone never shows a frame).
        local function FinishRowStagger(card)
            local st = card and card._rowStagger
            if not st then return end
            card._rowStagger = nil
            if st.driver then st.driver:SetScript("OnUpdate", nil) end
            for frame in pairs(st.index) do
                PlaceStaggerRow(card, frame, 1, 0)
            end
        end

        -- Start the stagger on the player's open. Returns true when it runs. Skipped while the
        -- card is hidden or fading, or a dependent-row fade owns row alpha (card.relayoutAnim).
        local function StartRowStagger(card)
            FinishRowStagger(card)
            if not card or not card.widgetList or not RowStaggerAt or not RowStaggerSchedule then return false end
            if card.relayoutAnim or card._visibilityFadingIn or card._visibilityFadingOut then return false end
            if not card:IsVisible() then return false end
            local index, n = {}, 0
            for _, entry in ipairs(card.widgetList) do
                local frame = entry.frame
                -- A note may measure under 1px before its text lays out; the layout gives it
                -- NOTE_MIN_HEIGHT, so it staggers like any row. Only true spacers are skipped.
                local h = frame:GetHeight() or 0
                if entry.isNote and h < NOTE_MIN_HEIGHT then h = NOTE_MIN_HEIGHT end
                if frame:IsShown() and h >= 1 and frame._hsRowX then
                    n = n + 1
                    index[frame] = n
                end
            end
            if n == 0 then return false end
            local WDef = addon.OptionsWidgetsDef
            local step, dur, total = RowStaggerSchedule(n, WDef.RowStagger, WDef.MotionFast, WDef.RowStaggerCap)
            if total <= 0 then return false end
            local driver = card._rowStaggerDriver
            if not driver then
                -- A child of the card, so it hides with the card or the dashboard and ends the
                -- stagger exactly.
                driver = CreateFrame("Frame", nil, card)
                driver:SetScript("OnHide", function() FinishRowStagger(card) end)
                card._rowStaggerDriver = driver
            end
            local st = { t = 0, step = step, dur = dur, total = total, rise = WDef.RowRise or 0,
                index = index, driver = driver }
            card._rowStagger = st
            -- Paint the first frame now, so no row flashes in place before the first tick.
            for frame in pairs(index) do
                local alpha, dy = RowStaggerLook(card, frame)
                PlaceStaggerRow(card, frame, alpha, dy)
            end
            driver:SetScript("OnUpdate", function(self, elapsed)
                if card._rowStagger ~= st then
                    self:SetScript("OnUpdate", nil)
                    return
                end
                st.t = st.t + math.max(0, tonumber(elapsed) or 0)
                if st.t >= st.total then
                    FinishRowStagger(card)
                    return
                end
                for frame in pairs(st.index) do
                    if frame:IsShown() then
                        local alpha, dy = RowStaggerLook(card, frame)
                        PlaceStaggerRow(card, frame, alpha, dy)
                    end
                end
            end)
            return true
        end

        -- The card calls these: StartRowStagger on a player's open, StopRowStagger on a close
        -- or an instant open.
        local function AttachRowStagger(card)
            card.StartRowStagger = function() return StartRowStagger(card) end
            card.StopRowStagger = function() FinishRowStagger(card) end
        end

        -- "N changed" in the card header: the rows shown in the card whose marker is lit
        -- (frame._hsChanged, set by the row's marker update below). Runs after every marker
        -- update and every relayout, so a row a condition hides drops out of the count.
        local function UpdateCardChangedCount(card)
            if not (card and card.SetChangedCount and card.widgetList) then return end
            local n = 0
            for _, entry in ipairs(card.widgetList) do
                local fr = entry.frame
                if fr and fr._hsChanged and fr:IsShown() then n = n + 1 end
            end
            card.SetChangedCount(n)
        end

        -- Restack the card's visible entries. Spacing and hairlines come from
        -- addon.CardRowSpacing, decided from the visible order each time, so a row that hides
        -- or shows moves the hairlines with it. restackOnly positions the entries and works out
        -- card.fullHeight but leaves the card's height and visibility to a running animation.
        local function DoInstantRelayoutBody(card, skipHeightApply, animateVisibility, restackOnly)
            animateVisibility = animateVisibility == true
            card._inRelayout = true
            local WDef = addon.OptionsWidgetsDef
            local cardPadX = WDef.CardPadding
            local rowIndent = WDef.RowIndent
            local sc = card.settingsContainer

            local shown, kinds = {}, {}
            for _, entry in ipairs(card.widgetList) do
                local visible = true
                if entry.visibleWhen then
                    visible = entry.visibleWhen()
                end
                entry.frame:SetShown(visible)
                if visible then
                    -- Alpha 1, or where a running open stagger has the row (RowStaggerLook).
                    entry.frame:SetAlpha((RowStaggerLook(card, entry.frame)))
                    local h = entry.frame:GetHeight() or 0
                    if entry.isNote and h < NOTE_MIN_HEIGHT then h = NOTE_MIN_HEIGHT end
                    local kind = (entry.isHeader and "subheading") or (entry.isNote and "note")
                        or (h < 1 and "spacer") or (entry.frame._rowPadded and "row") or "block"
                    shown[#shown + 1] = { entry = entry, h = h }
                    kinds[#kinds + 1] = kind
                end
            end

            local spacing = addon.CardRowSpacing(kinds, {
                subheadingTop = WDef.SubheadingTopGap,
                subheadingBottom = WDef.SubheadingBottomGap,
                noteTop = WDef.NoteTopGap,
                blockPad = WDef.BlockPadY,
            })

            local yOff = 0
            for i, item in ipairs(shown) do
                local entry, sp = item.entry, spacing[i]
                local frame = entry.frame
                local indentX = entry.indent and rowIndent or 0
                local rowX = cardPadX + indentX
                yOff = yOff + sp.top
                frame:ClearAllPoints()
                frame._hsRowX, frame._hsRowY = rowX, -yOff
                local _, staggerDy = RowStaggerLook(card, frame)
                frame:SetPoint("TOPLEFT", sc, "TOPLEFT", rowX, -yOff + staggerDy)
                frame:SetPoint("RIGHT", sc, "RIGHT", -cardPadX, 0)
                SetRowDivider(frame, sp.divider, indentX, sp.top)
                -- The row hover runs across the whole card, past the row's own inset.
                local hover = frame._rowHover
                if hover then
                    hover:ClearAllPoints()
                    hover:SetPoint("TOPLEFT", frame, "TOPLEFT", -rowX, 0)
                    hover:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", cardPadX, 0)
                end
                yOff = yOff + item.h + sp.bottom
            end
            card.contentHeight = yOff
            card.fullHeight = yOff + card.chromeHeight
            UpdateCardChangedCount(card)
            card._inRelayout = nil
            -- A row that changed height while this pass read the heights: stack once more.
            if card._relayoutPending then
                card._relayoutPending = nil
                DoInstantRelayoutBody(card, skipHeightApply, animateVisibility, restackOnly)
                return
            end
            if restackOnly then
                UpdateDetailLayout()
                return
            end
            if card.headerToggleInit then
                card.headerToggleInit()
                card.headerToggleInit = nil  -- run once
            elseif not skipHeightApply and card.expanded then
                card:SetHeight(card.fullHeight)
            end
            if card.visibleWhen then
                local cardVisible = card.visibleWhen()
                local wasShown = card:IsShown()
                if not cardVisible then
                    if animateVisibility then
                        FadeOutConditionalCard(card)
                    else
                        card._visibilityFadingOut = nil
                        card:SetShown(false)
                        card:SetHeight(0)
                        card:SetAlpha(1)
                    end
                elseif (card:GetHeight() or 0) < 1 then
                    card._visibilityFadingOut = nil
                    card:SetShown(true)
                    card:SetHeight(card.expanded and card.fullHeight or card.collapsedHeight)
                    if animateVisibility and not wasShown then
                        card:SetAlpha(0)
                        if UIFrameFadeIn then
                            UIFrameFadeIn(card, CARD_VISIBILITY_FADE_DUR, 0, 1)
                        else
                            card:SetAlpha(1)
                        end
                    else
                        card:SetAlpha(1)
                    end
                end
            end
            UpdateDetailLayout()
        end

        -- Runs the body under pcall so an error cannot leave card._inRelayout set (which would
        -- swallow every later restack), then raises the error again.
        local function DoInstantRelayout(card, skipHeightApply, animateVisibility, restackOnly)
            if not card or not card.widgetList then return end
            local ok, err = pcall(DoInstantRelayoutBody, card, skipHeightApply, animateVisibility, restackOnly)
            if not ok then
                card._inRelayout = nil
                card._relayoutPending = nil
                error(err, 0)
            end
        end

        local function RelayoutCard(card, animateVisibility)
            if not card or not card.widgetList then return end
            animateVisibility = animateVisibility == true

            -- If a visibility fade owns the card, let it run unless the target state flipped.
            local wantVisible = (not card.visibleWhen) or card.visibleWhen()
            if card._visibilityFadingIn then
                if wantVisible then return end
                card._visibilityFadingIn = nil
                if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
            end
            if card._visibilityFadingOut then
                if not wantVisible then return end
                card._visibilityFadingOut = nil
                if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
            end

            -- Hide path: dissolve alpha + height together.
            if animateVisibility and card.visibleWhen and not wantVisible and card:IsShown() then
                if card.relayoutAnim then
                    card.relayoutAnim = nil
                    if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
                end
                FadeOutConditionalCard(card)
                return
            end

            -- Show path: grow alpha + height together. Use DoInstantRelayout to compute
            -- card.fullHeight so the animation has a real target.
            if animateVisibility and card.visibleWhen and wantVisible
                and (not card:IsShown() or (card:GetHeight() or 0) < 1) then
                card:SetShown(true)
                if card.relayoutAnim then
                    card.relayoutAnim = nil
                    if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
                end
                DoInstantRelayout(card, true, false)
                local target = card.expanded and card.fullHeight or (card.collapsedHeight or card.fullHeight)
                AnimateCardVisibility(card, "in", target)
                return
            end

            if card.relayoutAnim then
                if card.relayoutAnim.toShow then
                    for _, entry in ipairs(card.relayoutAnim.toShow) do
                        entry.frame:Hide()
                        entry.frame:SetAlpha(1)
                    end
                end
                if card.relayoutAnim.oldHeight then
                    card:SetHeight(card.relayoutAnim.oldHeight)
                end
                card.relayoutAnim = nil
                if card.relayoutAnimFrame then
                    card.relayoutAnimFrame:SetScript("OnUpdate", nil)
                end
            end

            local toHide, toShow = {}, {}
            for _, entry in ipairs(card.widgetList) do
                if entry.visibleWhen then
                    local wasVisible = entry.frame:IsShown()
                    local targetVisible = entry.visibleWhen()
                    if wasVisible and not targetVisible then
                        toHide[#toHide + 1] = entry
                    elseif not wasVisible and targetVisible then
                        toShow[#toShow + 1] = entry
                    end
                end
            end

            local skipAnim = (#toHide == 0 and #toShow == 0) or not card.expanded

            if skipAnim then
                DoInstantRelayout(card, false, animateVisibility)
                return
            end

            -- A dependent-row fade takes over row alpha from here: land an open stagger first,
            -- so the two never animate the same row.
            FinishRowStagger(card)

            local oldHeight = card:GetHeight()
            local animFrame = card.relayoutAnimFrame or CreateFrame("Frame", nil, card)
            animFrame:ClearAllPoints()
            animFrame:SetAllPoints(card)
            card.relayoutAnimFrame = animFrame

            local capturedAnimateVisibility = animateVisibility
            if #toHide > 0 then
                card.relayoutAnim = { phase = "fadeOut", elapsed = 0, toHide = toHide, oldHeight = oldHeight }
                animFrame:SetScript("OnUpdate", function(self, dt)
                    local a = card.relayoutAnim
                    if not a then self:SetScript("OnUpdate", nil) return end
                    a.elapsed = a.elapsed + dt
                    if a.phase == "fadeOut" then
                        local t = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                        local ep = easeOutDep(t)
                        for _, entry in ipairs(a.toHide) do
                            entry.frame:SetAlpha(1 - ep)
                        end
                        if t >= 1 then
                            for _, entry in ipairs(a.toHide) do
                                entry.frame:Hide()
                                entry.frame:SetAlpha(1)
                            end
                            DoInstantRelayout(card, true, capturedAnimateVisibility)
                            a.phase = "heightShrink"
                            a.elapsed = 0
                            a.targetFullH = card.fullHeight
                        end
                    else
                        local t = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                        local ep = easeOutDep(t)
                        local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * ep
                        card:SetHeight(curH)
                        UpdateDetailLayout()
                        if t >= 1 then
                            DoInstantRelayout(card, false, capturedAnimateVisibility)
                            card.relayoutAnim = nil
                            self:SetScript("OnUpdate", nil)
                        end
                    end
                end)
            elseif #toShow > 0 then
                DoInstantRelayout(card, true, capturedAnimateVisibility)
                for _, entry in ipairs(toShow) do
                    entry.frame:SetAlpha(0)
                end
                card:SetHeight(oldHeight)

                card.relayoutAnim = {
                    phase = "fadeIn",
                    elapsed = 0,
                    toShow = toShow,
                    oldHeight = oldHeight,
                    targetFullH = card.fullHeight,
                }
                animFrame:SetScript("OnUpdate", function(self, dt)
                    local a = card.relayoutAnim
                    if not a then self:SetScript("OnUpdate", nil) return end
                    a.elapsed = a.elapsed + dt
                    local fadeT = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                    local heightT = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                    local fadeEp = easeOutDep(fadeT)
                    local heightEp = easeOutDep(heightT)
                    for _, entry in ipairs(a.toShow) do
                        entry.frame:SetAlpha(fadeEp)
                    end
                    local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * heightEp
                    card:SetHeight(curH)
                    UpdateDetailLayout()
                    if fadeT >= 1 and heightT >= 1 then
                        for _, entry in ipairs(a.toShow) do
                            entry.frame:SetAlpha(1)
                        end
                        card:SetHeight(a.targetFullH)
                        card.relayoutAnim = nil
                        self:SetScript("OnUpdate", nil)
                        UpdateDetailLayout()
                    end
                end)
            end
        end

        -- An entry reports a new height (a wrapped label, a font row wrapping, the colour
        -- matrix restacking): restack its card. Mid-restack, that pass runs once more. While an
        -- animation owns the card's height (a visibility fade or a dependent-row fade), only the
        -- entries move and the animation's target height follows card.fullHeight, so the
        -- animation is neither dropped nor restarted.
        local function OnRowHeightChanged(card)
            if not card then return end
            if card._inRelayout then
                card._relayoutPending = true
                return
            end
            if card._visibilityFadingOut then return end
            local anim = card.relayoutAnim
            if card._visibilityFadingIn or anim then
                DoInstantRelayout(card, true, false, true)
                if card._visibilityFadingIn then
                    card._fadeTargetHeight = card.expanded and card.fullHeight or card.collapsedHeight
                end
                -- The fade-out phase reads card.fullHeight itself when it ends.
                if anim and anim.phase ~= "fadeOut" then anim.targetFullH = card.fullHeight end
                return
            end
            RelayoutCard(card, false)
        end

        -- Reset a changed row to its default (the reset arrow). The stored value is cleared
        -- first, so the row's own getter reads the default in the units its setter takes (some
        -- rows show 0-100 for a 0-1 value); the row's setter then runs with it, so the module's
        -- apply code sees exactly what a player choosing the default would cause; then the
        -- stored value is cleared again, so the setting follows the default from now on. A
        -- colour takes its default straight from the row or the defaults tables, and split
        -- R/G/B/A keys are cleared with it. A font row resets every part.
        local function ResetRowToDefault(opt, g, s, fontParts, widget)
            local SetDB = addon.SetDB
            if not SetDB then return end
            local keys, keyRows = {}, {}   -- keyRows[i]: the row or part that owns keys[i]
            local function clear() for _, k in ipairs(keys) do SetDB(k, nil) end end
            if opt.type == "fontRow" then
                for _, slot in ipairs(addon.FONT_ROW_PARTS) do
                    local part = fontParts and fontParts[slot]
                    if part and part.dbKey and part.get and part.set then
                        keys[#keys + 1] = part.dbKey
                        keyRows[#keys] = part
                        SetDB(part.dbKey, nil)
                        part.set(part.get())
                        SetDB(part.dbKey, nil)
                    end
                end
            else
                keys[1] = opt.dbKey
                keyRows[1] = opt
                if opt.type == "color" and addon.OptionSplitColorKeys then
                    for _, k in ipairs(addon.OptionSplitColorKeys(opt.dbKey)) do keys[#keys + 1] = k end
                end
                clear()
                if s then
                    if opt.type == "color" then
                        local def = addon.OptionDefault and addon.OptionDefault(opt.dbKey, opt)
                        if type(def) == "table" then
                            s(def[1] or def.r or 1, def[2] or def.g or 1, def[3] or def.b or 1, def[4] or def.a or 1)
                        elseif g then
                            s(g())
                        end
                    else
                        -- A row with no getter of its own reads nil once cleared: use the default.
                        local v = g and g()
                        if v == nil and addon.OptionDefault then v = addon.OptionDefault(opt.dbKey, opt) end
                        if v ~= nil then s(v) end
                    end
                end
                clear()
            end
            local function after()
                if widget and widget.Refresh then widget:Refresh() end
                RefreshLinkedTargets(opt.refreshIds)
                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
            end
            after()
            -- A setter that writes on the next frame (C_Timer.After(0)) lands after the clear
            -- above: clear once more then, so the profile ends with nothing stored. Only on the
            -- same profile, and only a key still holding its default, so a profile switch or
            -- the player's own change in that frame is never undone.
            if C_Timer and C_Timer.After then
                local profileAtClick = addon.GetActiveProfile and addon.GetActiveProfile()
                C_Timer.After(0, function()
                    local now = addon.GetActiveProfile and addon.GetActiveProfile()
                    if now ~= profileAtClick then return end
                    local atDefault = addon.OptionStoredIsDefault
                    local read = addon.OptionStoredValue
                    if not (atDefault and read) then return end
                    for i, k in ipairs(keys) do
                        if atDefault(k, keyRows[i], read) then SetDB(k, nil) end
                    end
                    after()
                end)
            end
        end

        for _, opt in ipairs(options) do
            -- Changed-from-default marker (addon.OptionMarkable rows). markUpdate is set once the
            -- row's marker exists; the setters below call it, so a player's change updates the dot
            -- and the card count even when the row does not Refresh itself.
            local markable = addon.OptionMarkable and addon.OptionMarkable(opt) or false
            local markUpdate
            local fontParts
            -- A few setters write on the next frame (C_Timer.After(0)), so a set also looks again
            -- one frame later; repeated sets in one frame (a colour drag) queue one look.
            local recheckPending = false
            local function markRecheck()
                if recheckPending or not (C_Timer and C_Timer.After) then return end
                recheckPending = true
                C_Timer.After(0, function()
                    recheckPending = false
                    if markUpdate then markUpdate() end
                end)
            end
            -- Resolve get/set fallbacks if missing
            local g = opt.get
            local s = opt.set
            if not g and opt.dbKey then
                if opt.type == "color" then
                    g = function()
                        local t = _G.OptionsData_GetDB(opt.dbKey, nil)
                        if type(t) == "table" and t[1] then
                            return t[1], t[2], t[3], t[4] or 1
                        end
                        if type(opt.default) == "table" then return unpack(opt.default) end
                        return 1, 1, 1, 1
                    end
                else
                    g = function() return _G.OptionsData_GetDB(opt.dbKey, opt.default) end
                end
            end
            if not s and opt.dbKey then
                if opt.type == "color" then
                    s = function(nr, ng, nb, na)
                        local t = { nr, ng, nb }
                        if opt.hasAlpha then t[4] = na end
                        _G.OptionsData_SetDB(opt.dbKey, t)
                    end
                else
                    s = function(v) _G.OptionsData_SetDB(opt.dbKey, v) end
                end
            end
            if opt.refreshIds and s then
                local origSet = s
                local skipKey = opt.dbKey
                if opt.type == "color" then
                    s = function(nr, ng, nb, na)
                        origSet(nr, ng, nb, na)
                        RefreshLinkedTargets(opt.refreshIds, skipKey)
                    end
                else
                    s = function(v)
                        origSet(v)
                        RefreshLinkedTargets(opt.refreshIds, skipKey)
                    end
                end
            end

            if markable and s then
                local innerSet = s
                s = function(...)
                    innerSet(...)
                    if markUpdate then markUpdate() end
                    if markRecheck then markRecheck() end
                end
            end

            if opt.type == "section" then
                -- Finalize previous card if any (relayout to apply visibility)
                if currentCard then
                    RelayoutCard(currentCard, false)
                end

                currentCard = CreateAccordionCard(detailContent, opt.name, opt.headerToggle, opt.desc)
                AttachRowStagger(currentCard)
                currentCard.contentHeight = 0
                currentCard.optionIds = {}
                currentCard.widgetList = {}
                currentCard.visibleWhen = opt.visibleWhen
                currentCard.cardId = opt.cardId
                if opt.dbKey then
                    currentCard.Refresh = function()
                        RelayoutCard(currentCard, true)
                    end
                    detailOptionFrames[opt.dbKey] = currentCard
                end
                tinsert(currentDetailCards, currentCard)
            else
                if not currentCard then
                    currentCard = CreateAccordionCard(detailContent, moduleSubName)
                    AttachRowStagger(currentCard)
                    currentCard.contentHeight = 0
                    currentCard.optionIds = {}
                    currentCard.widgetList = {}
                    tinsert(currentDetailCards, currentCard)
                end

                -- Store the option identifier to track its parent card (for search-jump).
                -- moduleReloadPrompt is excluded from search results, so skip it here.
                local optId = opt.type ~= "moduleReloadPrompt" and (
                    opt.dbKey
                    or (opt.type == "presencePreview" and "presencePreview")
                    or (opt.type == "talkingHeadPreview" and "talkingHeadPreview")
                    or (moduleSubName .. "_" .. (type(opt.name)=="function" and opt.name() or opt.name or ""):gsub("%s+", "_"))
                )
                if optId then currentCard.optionIds[optId] = true end

                -- Per-setting "(New!)" suffix: declared via `isNew = "<version>"`.
                -- Display-only for now; ack-on-interaction is intentionally not wired.
                local displayName = (addon.NewSettings_ResolveDisplayName and addon.NewSettings_ResolveDisplayName(opt, optId)) or opt.name

                local widget
                if opt.type == "binary" or opt.type == "toggle" then
                    widget = _G.OptionsWidgets_CreateToggleSwitch(currentCard.settingsContainer, displayName, opt.desc or "", g, s, opt.disabled, opt.tooltip)
                    if widget then
                        if opt.hidden and type(opt.hidden) == "function" then
                            local origRefresh = widget.Refresh
                            widget.Refresh = function(self)
                                if origRefresh then origRefresh(self) end
                                if opt.hidden() then self:Hide() else self:Show() end
                            end
                            if opt.hidden() then widget:Hide() end
                        end
                        if widget.Refresh then detailOptionFrames[optId] = widget end
                    end
                elseif opt.type == "slider" then
                    widget = _G.OptionsWidgets_CreateSlider(currentCard.settingsContainer, displayName, opt.desc or "", g, s, opt.min or 0, opt.max or 100, opt.disabled, opt.step or 1, opt.tooltip)
                    if widget then
                        if opt.hidden and type(opt.hidden) == "function" then
                            local origRefresh = widget.Refresh
                            widget.Refresh = function(self)
                                if origRefresh then origRefresh(self) end
                                if opt.hidden() then self:Hide() else self:Show() end
                            end
                            if opt.hidden() then widget:Hide() end
                        end
                        if widget.Refresh then detailOptionFrames[optId] = widget end
                    end
                elseif opt.type == "dropdown" then
                    local resetBtn = opt.resetButton
                    if resetBtn and resetBtn.onClick and opt.refreshIds then
                        local origOnClick = resetBtn.onClick
                        resetBtn = {
                            onClick = function()
                                origOnClick()
                                RefreshLinkedTargets(opt.refreshIds)
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end,
                            tooltip = resetBtn.tooltip,
                        }
                    end
                    -- A short static choice shows as segmented buttons when they fit the row, else
                    -- as this dropdown (the row switches itself as its width changes).
                    if addon.SegmentedEligible and addon.SegmentedEligible(opt) and _G.OptionsWidgets_CreateSegmented then
                        widget = _G.OptionsWidgets_CreateSegmented(currentCard.settingsContainer, displayName, opt.desc or "", opt.options, g, s, opt.displayFn, opt.disabled, opt.tooltip, resetBtn, opt.preserveOrder)
                    else
                        widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, displayName, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip, resetBtn, opt.fontPreviewInList, opt.preserveOrder)
                    end
                    if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                elseif opt.type == "fontRow" and _G.OptionsWidgets_CreateFontRow then
                    -- One row for a text element's font, size and outline (addon.FontRow). Each part
                    -- keeps its own key, getter and setter; a part's setter refreshes the part's
                    -- refreshIds and the row's (the children wired to any of its keys).
                    local rowKey = opt.dbKey
                    local parts, partKeys = {}, {}
                    for _, slot in ipairs(addon.FONT_ROW_PARTS) do
                        local part = opt.parts and opt.parts[slot]
                        if type(part) == "table" then
                            local key, default = part.dbKey, part.default
                            local pg, ps = part.get, part.set
                            if not pg and key then pg = function() return _G.OptionsData_GetDB(key, default) end end
                            if not ps and key then ps = function(v) _G.OptionsData_SetDB(key, v) end end
                            if pg and ps then
                                local ids, have = {}, {}
                                for _, list in ipairs({ part.refreshIds or {}, opt.refreshIds or {} }) do
                                    for _, id in ipairs(list) do
                                        if not have[id] then have[id] = true; ids[#ids + 1] = id end
                                    end
                                end
                                if #ids > 0 then
                                    local origSet = ps
                                    ps = function(v)
                                        origSet(v)
                                        RefreshLinkedTargets(ids, rowKey)
                                    end
                                end
                                if markable then
                                    local innerSet = ps
                                    ps = function(v)
                                        innerSet(v)
                                        if markUpdate then markUpdate() end
                                        if markRecheck then markRecheck() end
                                    end
                                end
                                -- A copy: the module's part table may be shared, so it is never written.
                                local p = {}
                                for k, v in pairs(part) do p[k] = v end
                                p.get, p.set = pg, ps
                                parts[slot] = p
                                if key then partKeys[#partKeys + 1] = key end
                            end
                        end
                    end
                    fontParts = parts
                    local rowDisabled = opt.disabled
                    if type(rowDisabled) ~= "function" then
                        local always = rowDisabled == true
                        rowDisabled = always and function() return true end or nil
                    end
                    widget = _G.OptionsWidgets_CreateFontRow(currentCard.settingsContainer, displayName, opt.desc or "", parts, rowDisabled, opt.tooltip)
                    if widget then
                        -- Wrapping below 640px changes the row's height; the card must restack.
                        local cardRef = currentCard
                        widget.onHeightChanged = function() OnRowHeightChanged(cardRef) end
                        if widget.Refresh then
                            if optId then detailOptionFrames[optId] = widget end
                            -- A real row that owns a part key keeps its own registration.
                            for _, key in ipairs(partKeys) do
                                if not detailOptionFrames[key] then detailOptionFrames[key] = widget end
                            end
                        end
                    end
                elseif opt.type == "color" then
                    widget = _G.OptionsWidgets_CreateColorSwatch(currentCard.settingsContainer, displayName, opt.desc or "", g, s, opt.hasAlpha, opt.tooltip, opt.liveThrottle)
                    if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                elseif opt.type == "presencePreview" then
                    local previewWidget = addon.Presence and addon.Presence.CreatePreviewWidget and addon.Presence.CreatePreviewWidget(currentCard.settingsContainer, {
                        getTypeName = function()
                            return _G.OptionsData_GetDB("presencePreviewType", "LEVEL_UP")
                        end,
                        setTypeName = function(v)
                            _G.OptionsData_SetDB("presencePreviewType", v)
                        end,
                        notify = function()
                            if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                        end,
                        scale = 0.55,
                    })
                    widget = previewWidget and previewWidget.frame or nil
                    if widget and previewWidget.Refresh then
                        widget.Refresh = previewWidget.Refresh
                    end
                    detailOptionFrames[optId] = widget
                elseif opt.type == "talkingHeadPreview" then
                    -- Preview is in the pinned strip above the scroll area; register a
                    -- zero-height proxy so refreshIds = { "talkingHeadPreview" } still
                    -- triggers RefreshEmbeddedTHPreview when option values change.
                    widget = CreateFrame("Frame", nil, currentCard.settingsContainer)
                    widget:SetHeight(0)
                    widget.Refresh = function()
                        if addon.Augment and addon.Augment.RefreshEmbeddedTHPreview then
                            addon.Augment.RefreshEmbeddedTHPreview()
                        end
                    end
                    detailOptionFrames[optId] = widget
                elseif opt.type == "header" then
                    if opt._subheading then
                        widget = CreateSubheading(currentCard.settingsContainer, opt.name)
                    else
                        widget = CreateNote(currentCard.settingsContainer, opt.name)
                    end
                elseif opt.type == "button" then
                    local onClick = opt.onClick
                    if opt.refreshIds and #opt.refreshIds > 0 then
                        onClick = function()
                            if opt.onClick then opt.onClick() end
                            RefreshLinkedTargets(opt.refreshIds)
                        end
                    end
                    widget = _G.OptionsWidgets_CreateButton(currentCard.settingsContainer, displayName, onClick, { tooltip = opt.tooltip })
                    if widget then
                        widget.Refresh = widget.Refresh or function() end
                        detailOptionFrames[optId] = widget
                    end
                elseif opt.type == "moduleReloadPrompt" then
                    local container = CreateFrame("Frame", nil, currentCard.settingsContainer)
                    local hintText = opt.hintText or L["MODULE_RELOAD_HINT"]
                    local hint = MakeText(container, hintText, 12, 0.65, 0.68, 0.75, "LEFT")
                    hint:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
                    hint:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
                    hint:SetWordWrap(true)
                    local reloadBtn = _G.OptionsWidgets_CreateButton(container, L["RELOAD_UI"], function()
                        ReloadUI()
                    end, { width = 130, height = 24 })
                    reloadBtn:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -10)
                    local function syncModuleReloadPromptHeight()
                        local hh = hint:GetStringHeight() or 14
                        container:SetHeight(math.max(56, hh + 10 + 24 + 8))
                    end
                    syncModuleReloadPromptHeight()
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0, syncModuleReloadPromptHeight)
                    end
                    widget = container
                elseif opt.type == "editbox" then
                    if _G.OptionsWidgets_CreateEditBox then
                        widget = _G.OptionsWidgets_CreateEditBox(currentCard.settingsContainer, opt.labelText or opt.name, g, s, {
                            height = opt.height,
                            readonly = opt.readonly,
                            storeRef = opt.storeRef,
                            tooltip = opt.tooltip,
                        })
                    end
                elseif opt.type == "reorderList" then
                    if OptionsWidgets_CreateReorderList then
                        widget = OptionsWidgets_CreateReorderList(currentCard.settingsContainer, currentCard.settingsContainer, opt, detailScroll, detailContent, function()
                            if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                        end)
                    end
                elseif opt.type == "blacklistGrid" then
                    if _G.OptionsWidgets_CreateBlacklistGrid then
                        widget = _G.OptionsWidgets_CreateBlacklistGrid(currentCard.settingsContainer, opt.name, {
                            desc = opt.desc or "",
                            tooltip = opt.tooltip,
                        })
                    end
                elseif opt.type == "colorMatrix" then
                    -- Emulate a mini-card inside the settings container
                    local cmContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                    local yOff = 0

                    local lbl = _G.OptionsWidgets_CreateSectionHeader(cmContainer, opt.name or "Colors")
                    lbl:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                    lbl:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                    yOff = yOff - 24

                    local keys = opt.keys or addon.COLOR_KEYS_ORDER or {}
                    local defaultMap = opt.defaultMap or addon.QUEST_COLORS or {}
                    local swatches = {}

                    local sub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["QUEST_TYPES"])
                    sub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                    yOff = yOff - 20

                    for _, key in ipairs(keys) do
                        local getTbl = function() local db = _G.OptionsData_GetDB(opt.dbKey, nil) return db and db[key] end
                        local setKeyVal = function(v)
                            addon.EnsureDB()
                            local _rdb = _G[addon.DATABASE]
                            if not _rdb[opt.dbKey] then _rdb[opt.dbKey] = {} end
                            _rdb[opt.dbKey][key] = v
                            if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                        end
                        local labelText = L[(opt.labelMap and opt.labelMap[key]) or key:gsub("^%l", string.upper)]
                        local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, labelText, defaultMap[key], getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                        row:ClearAllPoints()
                        row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                        row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                        yOff = yOff - 28
                        swatches[#swatches+1] = row
                    end

                    local resetBtn = _G.OptionsWidgets_CreateButton(cmContainer, L["FOCUS_RESET_QUEST_TYPES"], function()
                        _G.OptionsData_SetDB(opt.dbKey, nil)
                        _G.OptionsData_SetDB("sectionColors", nil)
                        for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                    end, { width = 120, height = 22 })
                    resetBtn:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                    yOff = yOff - 30

                    local overridesSub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["ELEMENT_OVERRIDES"])
                    overridesSub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff - 10)
                    yOff = yOff - 30

                    local overrideRows = {}
                    for _, ov in ipairs(opt.overrides or {}) do
                        local getTbl = function() return _G.OptionsData_GetDB(ov.dbKey, nil) end
                        local setKeyVal = function(v) _G.OptionsData_SetDB(ov.dbKey, v); if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end
                        local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, ov.name, ov.default, getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                        row:ClearAllPoints()
                        row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                        row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                        yOff = yOff - 28
                        overrideRows[#overrideRows+1] = row
                    end

                    local resetOv = _G.OptionsWidgets_CreateButton(cmContainer, L["FOCUS_RESET_OVERRIDES"], function()
                        for _, ov in ipairs(opt.overrides or {}) do _G.OptionsData_SetDB(ov.dbKey, nil) end
                        for _, r in ipairs(overrideRows) do if r.Refresh then r:Refresh() end end
                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                    end, { width = 120, height = 22 })
                    resetOv:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                    yOff = yOff - 28

                elseif opt.type == "colorMatrixFull" then
                    -- Compact color cards in 3-column grid
                    local cmfContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                    -- currentCard moves on as later sections build; LayoutAll runs later.
                    local cmfCard = currentCard
                    local notifyFn = function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end

                    local function getMatrix()
                        addon.EnsureDB()
                        local m = _G.OptionsData_GetDB(opt.dbKey, nil)
                        if type(m) ~= "table" then
                            m = { categories = {}, overrides = {} }
                            _G.OptionsData_SetDB(opt.dbKey, m)
                        else
                            m.categories = m.categories or {}
                            m.overrides = m.overrides or {}
                        end
                        return m
                    end

                    local function getOverride(key)
                        local m = getMatrix()
                        local v = m.overrides and m.overrides[key]
                        if key == "useCompletedOverride" and v == nil then return true end
                        if key == "useCurrentQuestOverride" and v == nil then return true end
                        return v
                    end
                    local function setOverride(key, v)
                        local m = getMatrix()
                        m.overrides[key] = v
                        _G.OptionsData_SetDB(opt.dbKey, m)
                        if not addon._colorPickerLive then notifyFn() end
                    end

                    -- Grid constants
                    local COLS = 3
                    local CARD_GAP = 12
                    local CARD_H = 108
                    local CARD_PAD = 14
                    local widgetLabelColor = { 0.88, 0.88, 0.92 }

                    local allCards = {}
                    local overrideGroupMap = {}
                    local otherColorRows = {}
                    local completedObjRow

                    -- Build a compact color card for a category
                    local function BuildCompactCard(parentFrame, key)
                        local labelBase = L[(addon.SECTION_LABELS and addon.SECTION_LABELS[key]) or key]
                        local card = CreateFrame("Frame", nil, parentFrame)
                        card:SetHeight(CARD_H)
                        card.groupKey = key

                        -- Card background (match options section-card transparency)
                        local bg = card:CreateTexture(nil, "BACKGROUND")
                        bg:SetAllPoints(card)
                        bg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                        -- Subtle border
                        if addon.CreateBorder then
                            addon.CreateBorder(card, SBd)
                        end

                        -- 2px accent bar at top using category base color
                        local accentBar = card:CreateTexture(nil, "OVERLAY")
                        accentBar:SetHeight(2)
                        accentBar:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
                        accentBar:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
                        card.accentBar = accentBar

                        local nameLabel = card:CreateFontString(nil, "OVERLAY")
                        do
                            local wp = addon.Dashboard_ResolveSavedDashboardFontPath(
                                (addon.GetDB and addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath())) or addon.Dashboard_GetDefaultDashboardFontPath()
                            )
                            local we = addon.Dashboard_EffectiveDashboardFontSize(13)
                            local wf = addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags() or "OUTLINE"
                            pcall(function()
                                nameLabel:SetFont(wp, we, wf)
                            end)
                            if addon.Dashboard_ApplyTextShadow then
                                addon.Dashboard_ApplyTextShadow(nameLabel)
                            end
                        end
                        local typoReg = f._dashboardTypographyRefs
                        if typoReg and addon.Dashboard_RegisterTypographyFontString then
                            addon.Dashboard_RegisterTypographyFontString(typoReg, nameLabel, 13, nil, true)
                        end
                        nameLabel:SetTextColor(widgetLabelColor[1], widgetLabelColor[2], widgetLabelColor[3])
                        nameLabel:SetText((labelBase and labelBase ~= "") and (string.gsub(labelBase, "(%a)([%w_']*)", function(a, b) return string.upper(a) .. string.lower(b) end)) or labelBase)
                        nameLabel:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)
                        nameLabel:SetJustifyH("LEFT")

                        local resetBtn = _G.OptionsWidgets_CreateButton(card, L["FOCUS_RESET"], function()
                            local m = getMatrix()
                            if m.categories and m.categories[key] then
                                m.categories[key] = nil
                                _G.OptionsData_SetDB(opt.dbKey, m)
                                notifyFn()
                                card:Refresh()
                            end
                        end, { width = 52, height = 20 })
                        resetBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -7)

                        local questColorKey = (key == "ACHIEVEMENTS" and "ACHIEVEMENT") or (key == "RARES" and "RARE") or key
                        local baseColor = (addon.QUEST_COLORS and addon.QUEST_COLORS[questColorKey]) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                        local sectionColor = (addon.SECTION_COLORS and addon.SECTION_COLORS[key]) or (addon.SECTION_COLORS and addon.SECTION_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                        local unifiedDef = (key == "NEARBY" or key == "CURRENT" or key == "CURRENT_EVENT") and sectionColor or baseColor

                        local zoneLabel = (key == "SCENARIO") and (L["UI_STAGE"]) or (L["FOCUS_ZONE"])
                        local catDefs = {
                            { subKey = "section",   abbr = L["FOCUS_SECTION"],   full = "Section",   def = unifiedDef },
                            { subKey = "title",     abbr = L["FOCUS_TITLE"],     full = "Title",     def = unifiedDef },
                            { subKey = "zone",      abbr = (key == "SCENARIO") and (L["UI_STAGE"]) or (L["FOCUS_ZONE"]), full = zoneLabel, def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                            { subKey = "objective", abbr = L["FOCUS_OBJECTIVE"], full = "Objective", def = unifiedDef },
                        }

                        card.swatches = {}
                        -- 2×2 grid: swatch-left layout, more breathing room
                        local SWATCH_ROW_H = 32
                        local SWATCH_GAP_X = 14
                        local SWATCH_W = 90
                        for i, cd in ipairs(catDefs) do
                            local getTbl = function()
                                local m = getMatrix()
                                local cats = m.categories or {}
                                return cats[key] and cats[key][cd.subKey] or nil
                            end
                            local setKeyVal = function(v)
                                local m = getMatrix()
                                m.categories[key] = m.categories[key] or {}
                                m.categories[key][cd.subKey] = (type(v) == "table" and v[1] and v[2] and v[3]) and { v[1], v[2], v[3] } or v
                                _G.OptionsData_SetDB(opt.dbKey, m)
                                if not addon._colorPickerLive then notifyFn() end
                            end
                            local sw = _G.OptionsWidgets_CreateMiniSwatch(card, cd.abbr, cd.def, getTbl, setKeyVal, notifyFn, cd.full)
                            local col = (i - 1) % 2
                            local row = math.floor((i - 1) / 2)
                            local xOfs = 10 + col * (SWATCH_W + SWATCH_GAP_X)
                            local yOfs = -(8 + nameLabel:GetStringHeight() + 6 + row * SWATCH_ROW_H)
                            sw:ClearAllPoints()
                            sw:SetPoint("TOPLEFT", card, "TOPLEFT", xOfs, yOfs)
                            card.swatches[#card.swatches + 1] = sw
                        end

                        function card:Refresh()
                            for _, sw in ipairs(self.swatches) do if sw.Refresh then sw:Refresh() end end
                            -- Update accent bar from live section color
                            local m = getMatrix()
                            local cats = m.categories or {}
                            local catData = cats[self.groupKey]
                            local secColor = (catData and catData.section) or unifiedDef
                            local r, g, b = secColor[1], secColor[2], secColor[3]
                            self.accentBar:SetColorTexture(r, g, b, 1)
                        end

                        allCards[#allCards + 1] = card
                        card:Refresh()
                        return card
                    end

                    -- Position cards in a grid within a container
                    local function PositionGrid(gridFrame, cards, cols, cardH, gap)
                        local gridW = gridFrame:GetWidth()
                        if gridW < 10 then gridW = 600 end
                        local cardW = math.floor((gridW - (cols - 1) * gap) / cols)
                        for idx, c in ipairs(cards) do
                            local col = (idx - 1) % cols
                            local row = math.floor((idx - 1) / cols)
                            c:ClearAllPoints()
                            c:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * (cardW + gap), -row * (cardH + gap))
                            c:SetSize(cardW, cardH)
                        end
                    end

                    -- LayoutAll repositions everything and resizes the container
                    local perCatCards = {}
                    local overrideCards = {}
                    local perCatGrid, overrideGrid
                    local perCatHdr, resetAllBtn, goHdr, otherHdr
                    local ovCompleted, ovCurrentZone, ovCurrentQuest, ovCompletedObj

                    -- A toggle's hover runs to the card's edges, as on the card's own rows: past
                    -- CARD_PAD inside the grid and the card padding outside it.
                    local function StretchHover(row)
                        local hover = row and row._rowHover
                        if not hover then return end
                        local edge = addon.OptionsWidgetsDef.CardPadding + CARD_PAD
                        hover:ClearAllPoints()
                        hover:SetPoint("TOPLEFT", row, "TOPLEFT", -edge, 0)
                        hover:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", edge, 0)
                    end

                    local function LayoutAll()
                        -- A row can report a height change before the whole grid exists.
                        if not (perCatHdr and goHdr and otherHdr and overrideGrid and ovCompletedObj) then return end
                        local yOff = 0

                        perCatHdr:ClearAllPoints()
                        perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                        resetAllBtn:ClearAllPoints()
                        resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                        yOff = yOff - 28

                        -- Per-category grid
                        local numRows = math.ceil(#perCatCards / COLS)
                        local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                        perCatGrid:ClearAllPoints()
                        perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        perCatGrid:SetHeight(gridH)
                        PositionGrid(perCatGrid, perCatCards, COLS, CARD_H, CARD_GAP)
                        yOff = yOff - gridH

                        yOff = yOff - 16
                        goHdr:ClearAllPoints()
                        goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                        yOff = yOff - 28

                        ovCompleted:ClearAllPoints()
                        ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        StretchHover(ovCompleted)
                        yOff = yOff - ovCompleted:GetHeight()

                        ovCurrentZone:ClearAllPoints()
                        ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        StretchHover(ovCurrentZone)
                        yOff = yOff - ovCurrentZone:GetHeight()

                        ovCurrentQuest:ClearAllPoints()
                        ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        StretchHover(ovCurrentQuest)
                        yOff = yOff - ovCurrentQuest:GetHeight()

                        -- Override grid: show only visible cards in a single row
                        local visibleOv = {}
                        for _, c in ipairs(overrideCards) do
                            if c:IsShown() then visibleOv[#visibleOv + 1] = c end
                        end
                        if #visibleOv > 0 then
                            overrideGrid:ClearAllPoints()
                            overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            overrideGrid:SetHeight(CARD_H)
                            overrideGrid:Show()
                            PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                            yOff = yOff - CARD_H
                        else
                            overrideGrid:Hide()
                        end

                        yOff = yOff - 16
                        otherHdr:ClearAllPoints()
                        otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                        yOff = yOff - 28

                        ovCompletedObj:ClearAllPoints()
                        ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        StretchHover(ovCompletedObj)
                        yOff = yOff - ovCompletedObj:GetHeight()

                        for _, row in ipairs(otherColorRows) do
                            if row:IsShown() then
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                yOff = yOff - 30
                            end
                        end

                        local newHeight = math.max(1, -yOff)
                        cmfContainer:SetHeight(newHeight)
                        -- Restack the card around the new height (its padding included).
                        OnRowHeightChanged(cmfCard)
                    end

                    -- Build the layout
                    local groupOrder = addon.GetGroupOrder and addon.GetGroupOrder() or {}
                    if type(groupOrder) ~= "table" or #groupOrder == 0 then groupOrder = addon.GROUP_ORDER or {} end
                    local GROUPING_OVERRIDE_KEYS = { CURRENT = true, NEARBY = true, COMPLETE = true }
                    local yOff = 0

                    perCatHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["PER_CATEGORY"])
                    perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    resetAllBtn = _G.OptionsWidgets_CreateButton(cmfContainer, L["FOCUS_RESET_DEFAULTS"], function()
                        _G.OptionsData_SetDB(opt.dbKey, nil)
                        _G.OptionsData_SetDB("questColors", nil)
                        _G.OptionsData_SetDB("sectionColors", nil)
                        for _, c in ipairs(allCards) do if c.Refresh then c:Refresh() end end
                        for _, r in ipairs(otherColorRows) do if r.Refresh then r:Refresh() end end
                        notifyFn()
                    end, { width = 140, height = 22 })
                    resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                    yOff = yOff - 28

                    -- Per-category grid
                    perCatGrid = CreateFrame("Frame", nil, cmfContainer)
                    local perCatKeys = {}
                    for _, key in ipairs(groupOrder) do
                        if not GROUPING_OVERRIDE_KEYS[key] then
                            tinsert(perCatKeys, key)
                        end
                    end
                    for _, key in ipairs(perCatKeys) do
                        local card = BuildCompactCard(perCatGrid, key)
                        tinsert(perCatCards, card)
                    end
                    local numRows = math.ceil(#perCatCards / COLS)
                    local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                    perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    perCatGrid:SetHeight(gridH)
                    yOff = yOff - gridH

                    yOff = yOff - 16
                    goHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["SECTION_OVERRIDES"])
                    goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    yOff = yOff - 28

                    ovCompleted = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"], L["FOCUS_READY_TURN_COLOURS_QUESTS"], function() return getOverride("useCompletedOverride") end, function(v)
                        setOverride("useCompletedOverride", v)
                        local gf = overrideGroupMap["COMPLETE"]
                        if gf then gf:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    -- Rows size themselves (taller with a description); restack when one changes.
                    ovCompleted.onHeightChanged = function() LayoutAll() end
                    yOff = yOff - ovCompleted:GetHeight()

                    ovCurrentZone = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"], L["FOCUS_CURRENT_ZONE_SECTION_COLOURS"], function() return getOverride("useCurrentZoneOverride") end, function(v)
                        setOverride("useCurrentZoneOverride", v)
                        local gf = overrideGroupMap["NEARBY"]
                        if gf then gf:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    -- Rows size themselves (taller with a description); restack when one changes.
                    ovCurrentZone.onHeightChanged = function() LayoutAll() end
                    yOff = yOff - ovCurrentZone:GetHeight()

                    ovCurrentQuest = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"], L["FOCUS_CURRENT_QUEST_SECTION_COLOURS"], function() return getOverride("useCurrentQuestOverride") end, function(v)
                        setOverride("useCurrentQuestOverride", v)
                        local gf = overrideGroupMap["CURRENT"]
                        if gf then gf:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    -- Rows size themselves (taller with a description); restack when one changes.
                    ovCurrentQuest.onHeightChanged = function() LayoutAll() end
                    yOff = yOff - ovCurrentQuest:GetHeight()

                    -- Override color cards in a single-row grid
                    overrideGrid = CreateFrame("Frame", nil, cmfContainer)
                    for _, key in ipairs(groupOrder) do
                        if GROUPING_OVERRIDE_KEYS[key] then
                            local card = BuildCompactCard(overrideGrid, key)
                            tinsert(overrideCards, card)
                            overrideGroupMap[key] = card
                        end
                    end
                    -- Hide override cards whose toggle is OFF
                    if not getOverride("useCompletedOverride") and overrideGroupMap["COMPLETE"] then overrideGroupMap["COMPLETE"]:Hide() end
                    if not getOverride("useCurrentZoneOverride") and overrideGroupMap["NEARBY"] then overrideGroupMap["NEARBY"]:Hide() end
                    if not getOverride("useCurrentQuestOverride") and overrideGroupMap["CURRENT"] then overrideGroupMap["CURRENT"]:Hide() end

                    local visibleOv = {}
                    for _, c in ipairs(overrideCards) do if c:IsShown() then visibleOv[#visibleOv + 1] = c end end
                    if #visibleOv > 0 then
                        overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                        overrideGrid:SetHeight(CARD_H)
                        PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                        yOff = yOff - CARD_H
                    else
                        overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        overrideGrid:SetHeight(1)
                    end

                    yOff = yOff - 16
                    otherHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OTHER_COLOURS"])
                    otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                    yOff = yOff - 28

                    ovCompletedObj = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["FOCUS_DISTINCT_COLOUR_COMPLETED_OBJECTIVES"], L["COMPLETED_OBJECTIVES_COLOUR_BELOW"], function() return _G.OptionsData_GetDB("useCompletedObjectiveColor", true) end, function(v)
                        _G.OptionsData_SetDB("useCompletedObjectiveColor", v)
                        notifyFn()
                        if completedObjRow then completedObjRow:SetShown(v and true or false); LayoutAll() end
                    end)
                    ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                    ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                    -- Rows size themselves (taller with a description); restack when one changes.
                    ovCompletedObj.onHeightChanged = function() LayoutAll() end
                    yOff = yOff - ovCompletedObj:GetHeight()

                    local otherDefs = {
                        { dbKey = "highlightColor", label = L["FOCUS_HIGHLIGHT"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                        { dbKey = "completedObjectiveColor", label = L["FOCUS_COMPLETED_OBJECTIVE"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }), isCompletedObj = true },
                        { dbKey = "progressBarFillColor", label = L["FOCUS_PROGRESS_BAR_FILL"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return _G.OptionsData_GetDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                        { dbKey = "progressBarTextColor", label = L["FOCUS_PROGRESS_BAR_TEXT"], def = { 0.95, 0.95, 0.95 } },
                    }

                    for _, od in ipairs(otherDefs) do
                        local getTbl = function() return _G.OptionsData_GetDB(od.dbKey, nil) end
                        local setKeyVal = function(v) _G.OptionsData_SetDB(od.dbKey, v); if not addon._colorPickerLive then notifyFn() end end
                        local row = _G.OptionsWidgets_CreateColorSwatchRow(cmfContainer, nil, od.label, od.def, getTbl, setKeyVal, notifyFn, od.disabled, od.hasAlpha)
                        row:ClearAllPoints()
                        row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                        row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                        tinsert(otherColorRows, row)
                        if od.isCompletedObj then completedObjRow = row end
                        yOff = yOff - 30
                    end

                    -- Hide completed objective swatch if toggle is OFF
                    if completedObjRow and not _G.OptionsData_GetDB("useCompletedObjectiveColor", true) then
                        completedObjRow:Hide()
                    end

                    cmfContainer:SetHeight(-yOff)
                    -- OnSizeChanged: reposition grid cards when width changes (guard against height-only changes)
                    local lastCmfWidth = 0
                    cmfContainer:SetScript("OnSizeChanged", function(self, w)
                        if math.abs(w - lastCmfWidth) > 0.5 then
                            lastCmfWidth = w
                            LayoutAll()
                        end
                    end)
                    widget = cmfContainer
                end

                if widget then
                    widget:SetParent(currentCard.settingsContainer)
                    widget:Show()
                    widget._parentCard = currentCard

                    local isHeader = opt.type == "header" and opt._subheading
                    local isNote = opt.type == "header" and not opt._subheading

                    -- An entry that changes height (a wrapped label, the Presence preview) restacks its card.
                    if widget.SetHeight and not widget.onHeightChanged then
                        local cardRef = currentCard
                        widget.onHeightChanged = function() OnRowHeightChanged(cardRef) end
                    end

                    -- Dependent rows sit indented under their parent with a thin accent line at
                    -- low alpha, just inside the parent row's left edge, beside the row's text.
                    if opt.indent and widget.CreateTexture and not widget._indentBar then
                        local WDef = addon.OptionsWidgetsDef
                        local barX = -(WDef.RowIndent - WDef.RowIndentBarX)
                        local barInsetY = widget._rowPadded and (WDef.RowPadY - WDef.RowDescGap) or 0
                        local bar = widget:CreateTexture(nil, "ARTWORK")
                        bar:SetWidth(WDef.RowIndentBarW)
                        bar:SetPoint("TOPLEFT", widget, "TOPLEFT", barX, -barInsetY)
                        bar:SetPoint("BOTTOMLEFT", widget, "BOTTOMLEFT", barX, barInsetY)
                        -- The accent follows the class theme (Def.AccentColor); ApplyDashboardClassColor
                        -- recolours the lines already built through dashAccentRefs.indentBars.
                        local ac = WDef.AccentColor
                        bar:SetColorTexture(ac[1], ac[2], ac[3], WDef.RowIndentBarAlpha)
                        local refs = accordionCardParams.dashAccentRefs
                        if refs and refs.indentBars then tinsert(refs.indentBars, bar) end
                        widget._indentBar = bar
                    end

                    tinsert(currentCard.widgetList, {
                        frame = widget,
                        isHeader = isHeader,
                        isNote = isNote,
                        indent = opt.indent,
                        visibleWhen = (opt.type == "moduleReloadPrompt" and function() return addon._moduleReloadRecommended end) or opt.visibleWhen,
                    })

                    -- The changed marker: a dot in the gutter and a reset arrow on hover
                    -- (OptionsWidgets AttachChangedMarker). It updates after every Refresh of the
                    -- row and every set, and keeps the card's "N changed" in step.
                    if markable and widget._rowLabel and _G.OptionsWidgets_AttachChangedMarker
                        and addon.OptionIsChanged then
                        local cardRef, rowWidget, rowG, rowS, rowParts = currentCard, widget, g, s, fontParts
                        local function disabledNow()
                            local d = opt.disabled
                            if type(d) == "function" then return d() == true end
                            return d == true
                        end
                        local marker = _G.OptionsWidgets_AttachChangedMarker(widget, function()
                            ResetRowToDefault(opt, rowG, rowS, rowParts, rowWidget)
                        end, disabledNow)
                        if marker then
                            markUpdate = function()
                                local changed = addon.OptionIsChanged(opt) and true or false
                                marker.SetChanged(changed)
                                rowWidget._hsChanged = changed
                                UpdateCardChangedCount(cardRef)
                            end
                            rowWidget._hsMarkUpdate = markUpdate
                            local origRefresh = widget.Refresh
                            widget.Refresh = function(self, ...)
                                if origRefresh then origRefresh(self, ...) end
                                markUpdate()
                            end
                            markUpdate()
                        end
                    end

                    if opt.visibleWhen and type(opt.visibleWhen) == "function" and widget.Refresh then
                        local origRefresh = widget.Refresh
                        local cardRef = currentCard
                        widget.Refresh = function(self)
                            if origRefresh then origRefresh(self) end
                            RelayoutCard(cardRef, true)
                        end
                    end
                end
            end
        end

        if currentCard then
            RelayoutCard(currentCard)
        end

        -- Open state on assembled pages: the first card opens by default and a remembered
        -- state wins. Cards with a header switch follow their switch instead.
        local Assemble = addon.OptionsAssemble
        if Assemble then
            local firstDone = false
            for _, card in ipairs(currentDetailCards) do
                if card.cardId and card.headerToggleEnabled then
                    -- A visible header-switch card still counts as the page's first card; it
                    -- expands by its switch, not by this rule.
                    if not (card.visibleWhen and not card.visibleWhen()) then firstDone = true end
                elseif card.cardId then
                    if card.visibleWhen and not card.visibleWhen() then
                        -- Hidden by its own condition: sync content alpha and chevron through
                        -- SetExpandedInstant, then put back the hidden state it overwrote. A hidden
                        -- card never counts as the first card, so it defaults to closed.
                        card.SetExpandedInstant(Assemble.IsCardExpanded(card.cardId, false))
                        card:SetHeight(0)
                        card:SetShown(false)
                    else
                        local isFirst = not firstDone
                        firstDone = true
                        card.SetExpandedInstant(Assemble.IsCardExpanded(card.cardId, isFirst))
                    end
                    local id = card.cardId
                    card.onExpandedChanged = function(expanded) Assemble.SetCardExpanded(id, expanded) end
                end
            end
        end

        UpdateDetailLayout()

        f._dashboardRelayoutDetailCards = function()
            -- detailScroll is inset 40px on each side from detailView, so its effective
            -- width = detailView:GetWidth() - 80.  Update detailContent to match so all
            -- cards (and their widgets) cascade to the correct width via RIGHT anchors.
            local newW = detailView:GetWidth() - 80
            if newW > 0 then
                detailContent:SetWidth(newW)
            end
            for _, card in ipairs(currentDetailCards) do
                -- A profile switch (OnActiveProfileChangedDeferred -> Dashboard_Refresh) lands
                -- here: re-read every marker before the relayout recounts the card.
                for _, entry in ipairs(card.widgetList or {}) do
                    if entry.frame and entry.frame._hsMarkUpdate then entry.frame._hsMarkUpdate() end
                end
                RelayoutCard(card)
            end
            UpdateDetailLayout()
        end

        f._refreshDashboardDetailOptionFonts = function()
            for _, w in pairs(detailOptionFrames) do
                if w and w.Refresh then w:Refresh() end
            end
            -- Card titles and descriptions change width with the dashboard font; refit them.
            for _, card in ipairs(currentDetailCards) do
                if card.FitHeader then card.FitHeader() end
            end
        end
    end
end
