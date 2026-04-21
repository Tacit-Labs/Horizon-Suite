--[[
    Horizon Suite - Focus - Animation Engine
    HS OnUpdate: height lerp, entry fade/slide/collapse, objective flash, auto-hide.
    Uses C_Map.GetBestMapForUnit in RunMapCheck for zone change detection.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local HEIGHT_SNAP_THRESHOLD   = 0.5
local DRIFT_THRESHOLD        = 0.1
local FLASH_ALPHA_BY_INTENSITY = { subtle = 0.12, medium = 0.22, strong = 0.35 }
local GROUP_COLLAPSE_TIMEOUT = 2

local anim = addon.FOCUS_ANIM or { dur = 0.4, stagger = 0.05, slideInX = 20, slideOutX = 20, driftOutY = 10 }

-- ============================================================================
-- SHARED TRANSITION HELPERS (progress, easing, state init)
-- ============================================================================

--- Returns progress p in [0,1] from elapsed time, optional delay, and duration.
local function GetProgress(elapsed, delay, duration)
    local t = math.max(0, (elapsed or 0) - (delay or 0))
    return math.min(t / (duration or anim.dur), 1)
end

--- Sets entry to fadein state. staggerIndex is 0-based (0 = no delay).
function addon.SetEntryFadeIn(entry, staggerIndex)
    if not entry then return end
    entry.animState   = "fadein"
    entry.animTime    = 0
    entry.staggerDelay = (staggerIndex or 0) * anim.stagger
    entry:SetAlpha(0)
end

--- Sets entry to fadeout state.
function addon.SetEntryFadeOut(entry)
    if not entry then return end
    entry.animState   = "fadeout"
    entry.animTime    = 0
end

--- Sets entry to collapsing state. staggerIndex is 0-based.
function addon.SetEntryCollapsing(entry, staggerIndex)
    if not entry then return end
    entry.animState    = "collapsing"
    entry.animTime     = 0
    entry.collapseDelay = (staggerIndex or 0) * anim.stagger
end

--- Sets entry to slide-up state (Y moves from startY to finalY). Used when entries below
--- a collapsed category shift up to fill the gap.
function addon.SetEntrySlideUp(entry, startY)
    if not entry then return end
    entry.animState     = "slideup"
    entry.animTime      = 0
    entry.slideUpStartY = startY
end

-- ============================================================================
-- ANIMATION ENGINE
-- ============================================================================

local HS          = addon.HS
local pool         = addon.pool
local sectionPool  = addon.sectionPool
local scrollChild  = addon.scrollChild

local function SetPanelHeight(h)
    if addon.GetDB("growUp", false) then
        HS:SetHeight(h)
        return
    end
    local topBefore = HS:GetTop()
    if not topBefore then return end
    -- Clamp height so the panel bottom never goes below the screen edge.
    -- This keeps the scroll-frame visible without repositioning the frame upward.
    local uiBottom = UIParent:GetBottom() or 0
    local maxH = topBefore - uiBottom
    if maxH > 0 then h = math.min(h, maxH) end
    HS:SetHeight(h)
    local topAfter = HS:GetTop()
    if not topAfter then return end
    local drift = topAfter - topBefore
    if math.abs(drift) < DRIFT_THRESHOLD then return end
    local uiTop   = UIParent:GetTop()   or 0
    local uiRight = UIParent:GetRight() or 0
    local right   = HS:GetRight()      or 0
    HS:ClearAllPoints()
    HS:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", right - uiRight, topBefore - uiTop)
end

--- Detects player map changes and invalidates zone task quest cache.
--- Called on a timer; no params or return.
local function RunMapCheck()
    if not addon.focus.enabled or not C_Map or not C_Map.GetBestMapForUnit then return end

    local ctx = addon.ResolvePlayerMapContext and addon.ResolvePlayerMapContext("player") or nil
    local rawMapID = ctx and ctx.rawMapID or C_Map.GetBestMapForUnit("player")
    local zoneMapID = ctx and ctx.zoneMapID or rawMapID

    if zoneMapID and zoneMapID ~= addon.focus.lastZoneMapID then
        addon.focus.lastZoneMapID = zoneMapID
        addon.focus.lastPlayerMapID = rawMapID
        if addon.zoneTaskQuestCache then wipe(addon.zoneTaskQuestCache) end
        addon.focus.nearbyQuestCacheDirty = true
        addon.focus.nearbyQuestCache = nil
        addon.focus.nearbyTaskQuestCache = nil
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    elseif rawMapID and rawMapID ~= addon.focus.lastPlayerMapID then
        -- rawMapID changed (e.g. left event area within same zone); invalidate nearby cache.
        addon.focus.lastPlayerMapID = rawMapID
        addon.focus.nearbyQuestCacheDirty = true
        addon.focus.nearbyQuestCache = nil
        addon.focus.nearbyTaskQuestCache = nil
        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
    elseif not addon.focus.lastZoneMapID and zoneMapID then
        addon.focus.lastZoneMapID = zoneMapID
        addon.focus.lastPlayerMapID = rawMapID
    else
        -- Keep raw mapID updated for debug / proximity checks.
        addon.focus.lastPlayerMapID = rawMapID
    end
end

--- Expose for FocusModule's map ticker.
addon.RunMapCheck = RunMapCheck

-- Ensure HS OnUpdate is running.
--function addon.EnsureFocusUpdateRunning()
--    if not addon.HS or addon._focusUpdateRunning then return end
--    addon._focusUpdateRunning = true
--    addon.HS:SetScript("OnUpdate", function(_, dt)
--        if not addon.focus.enabled then
--            addon._focusUpdateRunning = false
--            addon.HS:SetScript("OnUpdate", nil)
--            return
--        end
--        dt = dt or 0
--        local useAnim = addon.GetDB("animations", true)
--        UpdatePanelHeight(dt)
--        UpdateCombatFade(dt, useAnim)
--        local anyEntryAnimating = UpdateEntryAnimations(dt, useAnim)
--        UpdateCollapseAnimations(dt)
--        UpdateGroupCollapseCompletion()
--        UpdateSectionHeaderSlideUp(dt, useAnim)
--
--        -- Stop the OnUpdate when nothing needs it.
--        local stillAnimating = anyEntryAnimating
--            or addon.focus.collapse.animating
--            or (addon.focus.combat and addon.focus.combat.fadeState ~= nil)
--            or (addon.focus.collapse.groups and next(addon.focus.collapse.groups) ~= nil)
--            or addon.focus.collapse.sectionHeadersFadingOut
--            or addon.focus.collapse.sectionHeadersFadingIn
--        if not stillAnimating then
--            addon._focusUpdateRunning = false
--            addon.HS:SetScript("OnUpdate", nil)
--        end
--    end)
--end

local function UpdatePanelHeight(dt)
    local targetHeight  = addon.focus.layout.targetHeight
    local currentHeight = addon.focus.layout.currentHeight
    if math.abs(currentHeight - targetHeight) > HEIGHT_SNAP_THRESHOLD then
        addon.focus.layout.currentHeight = currentHeight + (targetHeight - currentHeight) * math.min(addon.HEIGHT_SPEED * dt, 1)
        SetPanelHeight(addon.focus.layout.currentHeight)
    elseif currentHeight ~= targetHeight then
        addon.focus.layout.currentHeight = targetHeight
        SetPanelHeight(addon.focus.layout.currentHeight)
    end
end

local function GetFadeOnMouseoverAlpha()
    local pct = tonumber(addon.GetDB("fadeOnMouseoverOpacity", 10)) or 10
    return math.max(0, math.min(100, pct)) / 100
end

--- Returns true if the mouse is over the frame or any of its descendants.
--- Uses GetMouseFocus() for reliable detection when cursor is over child frames
--- (IsMouseOver can be unreliable for parent when mouse is on a child).
local function IsMouseOverFrameOrDescendants(frame)
    if not frame then return false end
    local focus = GetMouseFocus and GetMouseFocus()
    if focus then
        local f = focus
        while f do
            if f == frame then return true end
            f = f.GetParent and f:GetParent()
        end
    end
    return frame.IsMouseOver and frame:IsMouseOver()
end

function addon.IsFocusHoverActive()
    if IsMouseOverFrameOrDescendants(HS) then return true end
    local mplus = addon.mplusBlock
    if mplus and mplus:IsShown() and mplus:IsMouseOver() then return true end
    local floatingBtn = _G.HSFloatingQuestItem
    if floatingBtn and floatingBtn:IsShown() and floatingBtn:IsMouseOver() then return true end
    return false
end

addon.IsMouseOverTracker = addon.IsFocusHoverActive

local function UpdateHoverFade(dt, useAnim)
    -- Combat hide/fade owns alpha during combat transitions and deferred hide.
    if addon.focus.combat.fadeState
        or addon.focus.pendingHideAfterCombat
        or (addon.ShouldHideInCombat and addon.ShouldHideInCombat())
        or (addon.ShouldFadeInCombat and addon.ShouldFadeInCombat()) then
        return
    end
    local floatingBtn = _G.HSFloatingQuestItem
    if not addon.GetDB("showOnMouseoverOnly", false) then
        if addon.focus.hoverFade.fadeState then
            addon.focus.hoverFade.fadeState = nil
            addon.focus.hoverFade.fadeTime = 0
            if HS:IsShown() then
                HS:SetAlpha(1)
                if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(1) end
            end
        end
        return
    end
    if not HS:IsShown() then
        if addon.focus.hoverFade.fadeState then
            addon.focus.hoverFade.fadeState = nil
            addon.focus.hoverFade.fadeTime = 0
            addon.focus.hoverFade.startAlpha = nil
        end
        return
    end

    local mouseOver = addon.IsFocusHoverActive()
    local fadeAlpha = GetFadeOnMouseoverAlpha()
    local targetAlpha = mouseOver and 1 or fadeAlpha
    local currentAlpha = HS:GetAlpha()
    local dur = anim.dur
    local hf = addon.focus.hoverFade

    if hf.fadeState == nil then
        if math.abs(currentAlpha - targetAlpha) < 0.01 then
            HS:SetAlpha(targetAlpha)
            if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
            return
        end
        hf.fadeState = mouseOver and "in" or "out"
        hf.fadeTime = 0
        hf.startAlpha = currentAlpha
    else
        -- Re-check hover each tick; retarget immediately if it changed mid-transition
        local prevTarget = (hf.fadeState == "in") and 1 or fadeAlpha
        if math.abs(targetAlpha - prevTarget) >= 0.01 then
            hf.fadeState = mouseOver and "in" or "out"
            hf.fadeTime = 0
            hf.startAlpha = currentAlpha
        end
    end

    hf.fadeTime = hf.fadeTime + dt
    local p = GetProgress(hf.fadeTime, 0, dur)
    local ep = p  -- linear: same perceived speed for fade in and out
    local startAlpha = hf.startAlpha or currentAlpha
    local newAlpha = startAlpha + (targetAlpha - startAlpha) * ep

    if not useAnim then
        HS:SetAlpha(targetAlpha)
        if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
        hf.fadeState = nil
        hf.fadeTime = 0
        hf.startAlpha = nil
        return
    end

    HS:SetAlpha(newAlpha)
    if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(newAlpha) end

    if p >= 1 then
        HS:SetAlpha(targetAlpha)
        if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
        hf.fadeState = nil
        hf.fadeTime = 0
        hf.startAlpha = nil
    end
end

local function UpdateCombatFade(dt, useAnim)
    local combatState = addon.focus.combat.fadeState
    if not combatState then return end
    local mode = addon.GetCombatVisibility and addon.GetCombatVisibility() or "show"
    local isFadeMode = (mode == "fade")
    local dur = anim.dur
    addon.focus.combat.fadeTime = addon.focus.combat.fadeTime + dt
    local floatingBtn = _G.HSFloatingQuestItem

    if combatState == "out" then
        if addon.focus.combat.fadeFromAlpha == nil then
            addon.focus.combat.fadeFromAlpha = HS:GetAlpha() or 1
        end
        local startAlpha = addon.focus.combat.fadeFromAlpha or 1
        if isFadeMode then
            local targetAlpha = addon.GetCombatFadeAlpha and addon.GetCombatFadeAlpha() or 0.3
            if not useAnim then
                HS:SetAlpha(targetAlpha)
                if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
                addon.focus.combat.fadeState = nil
                addon.focus.combat.fadeTime = 0
                addon.focus.combat.fadeFromAlpha = nil
                addon.focus.combat.faded = true
            else
                local p = GetProgress(addon.focus.combat.fadeTime, 0, dur)
                local ep = addon.easeIn(p)
                local alpha = startAlpha + (targetAlpha - startAlpha) * ep
                HS:SetAlpha(alpha)
                if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(alpha) end
                if p >= 1 then
                    HS:SetAlpha(targetAlpha)
                    if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
                    addon.focus.combat.fadeState = nil
                    addon.focus.combat.fadeTime = 0
                    addon.focus.combat.fadeFromAlpha = nil
                    addon.focus.combat.faded = true
                end
            end
        elseif not useAnim then
            HS:Hide()
            if floatingBtn then floatingBtn:Hide() end
            if addon.UpdateFloatingQuestItem then addon.UpdateFloatingQuestItem(nil) end
            if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
            addon.focus.combat.fadeState = nil
            addon.focus.combat.fadeTime = 0
            addon.focus.combat.fadeFromAlpha = nil
        else
            local p = GetProgress(addon.focus.combat.fadeTime, 0, dur)
            local ep = addon.easeIn(p)
            local alpha = startAlpha * (1 - ep)
            HS:SetAlpha(alpha)
            if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(alpha) end
            if p >= 1 then
                HS:Hide()
                if floatingBtn then floatingBtn:Hide() end
                if addon.UpdateFloatingQuestItem then addon.UpdateFloatingQuestItem(nil) end
                if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
                addon.focus.combat.fadeState = nil
                addon.focus.combat.fadeTime = 0
                addon.focus.combat.fadeFromAlpha = nil
            end
        end
    elseif combatState == "in" then
        addon.focus.combat.fadeFromAlpha = nil
        if addon.focus.combat.fadeInFromAlpha == nil then
            addon.focus.combat.fadeInFromAlpha = HS:GetAlpha() or 0
        end
        local startAlpha = addon.focus.combat.fadeInFromAlpha or 0
        local targetAlpha = 1
        if addon.GetDB("showOnMouseoverOnly", false) then
            local fadeAlpha = GetFadeOnMouseoverAlpha()
            targetAlpha = addon.IsFocusHoverActive() and 1 or fadeAlpha
        end
        if not useAnim then
            HS:SetAlpha(targetAlpha)
            if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
            addon.focus.combat.fadeState = nil
            addon.focus.combat.fadeTime = 0
            addon.focus.combat.fadeInFromAlpha = nil
            addon.focus.combat.faded = nil
        else
            local p = GetProgress(addon.focus.combat.fadeTime, 0, dur)
            local ep = addon.easeOut(p)
            local alpha = startAlpha + (targetAlpha - startAlpha) * ep
            if HS:IsShown() then HS:SetAlpha(alpha) end
            if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(alpha) end
            if p >= 1 then
                HS:SetAlpha(targetAlpha)
                if floatingBtn and floatingBtn:IsShown() then floatingBtn:SetAlpha(targetAlpha) end
                addon.focus.combat.fadeState = nil
                addon.focus.combat.fadeTime = 0
                addon.focus.combat.fadeInFromAlpha = nil
                addon.focus.combat.faded = nil
            end
        end
    end
end

local function UpdateEntryAnimations(dt, useAnim)
    local anyAnimating = false
    local slideOutCount = 0
    local flashIntensity = addon.GetDB("objectiveProgressFlashIntensity", "subtle")
    local flashAlphaMax = FLASH_ALPHA_BY_INTENSITY[flashIntensity] or FLASH_ALPHA_BY_INTENSITY.subtle
    local flashColor = addon.GetDB("objectiveProgressFlashColor", nil)
    if not flashColor or #flashColor < 3 then flashColor = { 1, 1, 1 } end
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        local state = e.animState

        if (state == "idle" or state == "active") and e.flashTime <= 0 then
            -- nothing to do
        elseif state == "fadein" then
            e.animTime = e.animTime + dt
            if not useAnim then
                e:SetAlpha(1)
                e:ClearAllPoints()
                e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX, e.finalY)
                e.animState = "active"
            elseif e.animTime < (e.staggerDelay or 0) then
                e:SetAlpha(0)
            else
                local p = GetProgress(e.animTime, e.staggerDelay, anim.dur)
                local ep = addon.easeOut(p)
                e:SetAlpha(ep)
                local slideX = (1 - ep) * anim.slideInX
                e:ClearAllPoints()
                e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX + slideX, e.finalY)
                if p >= 1 then
                    e:SetAlpha(1)
                    e:ClearAllPoints()
                    e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX, e.finalY)
                    e.animState = "active"
                end
            end
            anyAnimating = true

        elseif state == "completing" then
            e.animTime = e.animTime + dt
            if e.animTime >= addon.COMPLETE_HOLD then
                e.animState = "fadeout"
                e.animTime  = 0
            end
            anyAnimating = true

        elseif state == "fadeout" then
            e.animTime = e.animTime + dt
            if not useAnim then
                local wasPromotion = e.promotionFadeOut
                if wasPromotion then
                    addon.promotionFadeOutCount = (addon.promotionFadeOutCount or 0) - 1
                    e.promotionFadeOut = nil
                end
                local wasCategoryChange = e.categoryChangeFadeOut
                if wasCategoryChange then
                    addon.categoryChangeFadeOutCount = (addon.categoryChangeFadeOutCount or 0) - 1
                    e.categoryChangeFadeOut = nil
                end
                addon.ClearEntry(e)
                if wasPromotion and addon.promotionFadeOutCount == 0 and addon.onPromotionFadeOutCompleteCallback then
                    addon.onPromotionFadeOutCompleteCallback()
                elseif wasCategoryChange and addon.categoryChangeFadeOutCount == 0 and addon.onCategoryChangeFadeOutCompleteCallback then
                    addon.onCategoryChangeFadeOutCompleteCallback()
                end
            else
                local p  = GetProgress(e.animTime, 0, anim.dur)
                local ep = addon.easeIn(p)
                e:SetAlpha(1 - ep)
                local slideX = ep * anim.slideOutX
                e:ClearAllPoints()
                e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX + slideX, e.finalY)
                if p >= 1 then
                    local wasPromotion = e.promotionFadeOut
                    if wasPromotion then
                        addon.promotionFadeOutCount = (addon.promotionFadeOutCount or 0) - 1
                        e.promotionFadeOut = nil
                    end
                    local wasCategoryChange = e.categoryChangeFadeOut
                    if wasCategoryChange then
                        addon.categoryChangeFadeOutCount = (addon.categoryChangeFadeOutCount or 0) - 1
                        e.categoryChangeFadeOut = nil
                    end
                    addon.ClearEntry(e)
                    if wasPromotion and addon.promotionFadeOutCount == 0 and addon.onPromotionFadeOutCompleteCallback then
                        addon.onPromotionFadeOutCompleteCallback()
                    elseif wasCategoryChange and addon.categoryChangeFadeOutCount == 0 and addon.onCategoryChangeFadeOutCompleteCallback then
                        addon.onCategoryChangeFadeOutCompleteCallback()
                    end
                end
            end
            anyAnimating = true

        elseif state == "slideout" then
            e.animTime = e.animTime + dt
            if not useAnim then
                addon.ClearEntry(e)
            else
                local p = GetProgress(e.animTime, 0, anim.dur)
                local ep = addon.easeIn(p)
                e:SetAlpha(1 - ep)
                local slideX = ep * anim.slideOutX
                e:ClearAllPoints()
                e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX + slideX, e.finalY)
                if p >= 1 then
                    addon.ClearEntry(e)
                else
                    slideOutCount = slideOutCount + 1
                end
            end
            anyAnimating = true

        elseif state == "collapsing" then
            e.animTime = e.animTime + dt
            local delay = e.collapseDelay or 0
            if not useAnim and e.animTime >= delay then
                addon.ClearEntry(e)
            elseif e.animTime >= delay then
                local p = GetProgress(e.animTime, delay, anim.dur)
                local ep = addon.easeIn(p)
                e:SetAlpha(1 - ep)
                local slideX = ep * anim.slideOutX
                e:ClearAllPoints()
                e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX + slideX, e.finalY)
                if p >= 1 then
                    addon.ClearEntry(e)
                end
            end
            anyAnimating = true

        elseif state == "slideup" then
            e.animTime = e.animTime + dt
            if not useAnim then
                if e.finalX and e.finalY then
                    e:ClearAllPoints()
                    e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX, e.finalY)
                end
                e.animState = "active"
                e.slideUpStartY = nil
                local cc = addon.focus.categoryChange
                if cc and cc.slideUpRemaining and cc.slideUpRemaining > 0 then
                    cc.slideUpRemaining = cc.slideUpRemaining - 1
                    if cc.slideUpRemaining == 0 and cc.onSlideUpComplete then
                        cc.onSlideUpComplete()
                    end
                end
            else
                local startY = e.slideUpStartY
                if startY and e.finalY ~= nil and e.finalX ~= nil then
                    local p = GetProgress(e.animTime, 0, anim.dur)
                    local ep = addon.easeOut(p)
                    local y = startY + (e.finalY - startY) * ep
                    e:ClearAllPoints()
                    e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX, y)
                    if p >= 1 then
                        e:ClearAllPoints()
                        e:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", e.finalX, e.finalY)
                        e.animState = "active"
                        e.slideUpStartY = nil
                        local cc = addon.focus.categoryChange
                        if cc and cc.slideUpRemaining and cc.slideUpRemaining > 0 then
                            cc.slideUpRemaining = cc.slideUpRemaining - 1
                            if cc.slideUpRemaining == 0 and cc.onSlideUpComplete then
                                cc.onSlideUpComplete()
                            end
                        end
                    end
                else
                    e.animState = "active"
                    e.slideUpStartY = nil
                end
            end
            anyAnimating = true
        end

        if e.flashTime > 0 then
            e.flashTime = e.flashTime - dt
            local fp = math.max(e.flashTime / addon.FLASH_DUR, 0)
            local alpha
            if fp > 0.85 then
                local phase1Progress = (1 - fp) / 0.15
                alpha = addon.easeIn(phase1Progress) * flashAlphaMax
            else
                local phase2Progress = (0.85 - fp) / 0.85
                alpha = (1 - addon.easeOut(phase2Progress)) * flashAlphaMax
            end
            e.flash:SetColorTexture(flashColor[1], flashColor[2], flashColor[3], alpha)
            anyAnimating = true
        end
    end
    if slideOutCount == 0 and addon.focus.callbacks.onSlideOutComplete then
        local fn = addon.focus.callbacks.onSlideOutComplete
        addon.focus.callbacks.onSlideOutComplete = nil
        fn()
    end
    return anyAnimating
end

local function UpdateSectionHeaderFadeOut(dt, useAnim)
    if not addon.focus.collapse.sectionHeadersFadingOut then return end
    local fadeOutKeys = addon.focus.collapse.sectionHeadersFadingOutKeys
    local function shouldFade(s)
        if not s.active then return false end
        if fadeOutKeys then
            return s.groupKey and fadeOutKeys[s.groupKey]
        end
        return true
    end
    if not useAnim then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if shouldFade(s) then
                s:SetAlpha(0)
                s:Hide()
                s.active = false
            end
        end
        addon.focus.collapse.sectionHeadersFadingOut = false
        addon.focus.collapse.sectionHeadersFadingOutKeys = nil
        addon.focus.collapse.sectionHeaderFadeTime = 0
        return
    end
    addon.focus.collapse.sectionHeaderFadeTime = addon.focus.collapse.sectionHeaderFadeTime + dt
    local p = math.min(addon.focus.collapse.sectionHeaderFadeTime / anim.dur, 1)
    local ep = addon.easeIn(p)
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if shouldFade(s) and s.finalX ~= nil then
            s:SetAlpha(1 - ep)
            local slideX = ep * anim.slideOutX
            s:ClearAllPoints()
            s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX + slideX, s.finalY)
        elseif shouldFade(s) then
            s:SetAlpha(1 - ep)
        end
    end
    if p >= 1 then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if shouldFade(s) then
                s:Hide()
                s.active = false
            end
        end
        addon.focus.collapse.sectionHeadersFadingOut = false
        addon.focus.collapse.sectionHeadersFadingOutKeys = nil
        addon.focus.collapse.sectionHeaderFadeTime = 0
    end
end

local function UpdateSectionHeaderSlideUp(dt, useAnim)
    if not useAnim then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.slideUpStartY ~= nil then
                s.slideUpStartY = nil
                s.slideUpAnimTime = nil
                if s.finalX ~= nil and s.finalY ~= nil then
                    s:ClearAllPoints()
                    s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX, s.finalY)
                end
                local cc = addon.focus.categoryChange
                if cc and cc.slideUpRemaining and cc.slideUpRemaining > 0 then
                    cc.slideUpRemaining = cc.slideUpRemaining - 1
                    if cc.slideUpRemaining == 0 and cc.onSlideUpComplete then
                        cc.onSlideUpComplete()
                    end
                end
            end
        end
        return
    end
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if s and s.active and s.slideUpStartY ~= nil and s.finalX ~= nil and s.finalY ~= nil then
            s.slideUpAnimTime = (s.slideUpAnimTime or 0) + dt
            local p = GetProgress(s.slideUpAnimTime, 0, anim.dur)
            local ep = addon.easeOut(p)
            local y = s.slideUpStartY + (s.finalY - s.slideUpStartY) * ep
            s:ClearAllPoints()
            s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX, y)
            if p >= 1 then
                s:ClearAllPoints()
                s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX, s.finalY)
                s.slideUpStartY = nil
                s.slideUpAnimTime = nil
                local cc = addon.focus.categoryChange
                if cc and cc.slideUpRemaining and cc.slideUpRemaining > 0 then
                    cc.slideUpRemaining = cc.slideUpRemaining - 1
                    if cc.slideUpRemaining == 0 and cc.onSlideUpComplete then
                        cc.onSlideUpComplete()
                    end
                end
            end
        end
    end
end

local function UpdateSectionHeaderFadeIn(dt, useAnim)
    if not addon.focus.collapse.sectionHeadersFadingIn then return end
    if not useAnim then
        for i = 1, addon.SECTION_POOL_SIZE do
            if sectionPool[i].active then
                sectionPool[i]:SetAlpha(1)
            end
        end
        addon.focus.collapse.sectionHeadersFadingIn = false
        addon.focus.collapse.sectionHeaderFadeTime = 0
        return
    end
    addon.focus.collapse.sectionHeaderFadeTime = addon.focus.collapse.sectionHeaderFadeTime + dt
    local allDone = true
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if s.active and s.staggerDelay ~= nil then
            if addon.focus.collapse.sectionHeaderFadeTime < s.staggerDelay then
                s:SetAlpha(0)
                if s.finalX ~= nil then
                    local slideX = anim.slideInX
                    s:ClearAllPoints()
                    s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX + slideX, s.finalY)
                end
                allDone = false
            else
                local p = GetProgress(addon.focus.collapse.sectionHeaderFadeTime, s.staggerDelay, anim.dur)
                local ep = addon.easeOut(p)
                s:SetAlpha(ep)
                if s.finalX ~= nil then
                    local slideX = (1 - ep) * anim.slideInX
                    s:ClearAllPoints()
                    s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX + slideX, s.finalY)
                end
                if p < 1 then allDone = false end
            end
        end
    end
    if allDone then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s.active then
                s:SetAlpha(1)
                if s.finalX ~= nil then
                    s:ClearAllPoints()
                    s:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", s.finalX, s.finalY)
                end
            end
        end
        addon.focus.collapse.sectionHeadersFadingIn = false
        addon.focus.collapse.sectionHeaderFadeTime = 0
    end
end

--- Drives header slide animation when growUp + collapse mode: header slides down to bottom on collapse,
--- or up from bottom to top on expand. Uses ApplyGrowUpHeaderPosition(offsetFromBottom).
local function UpdateHeaderSlide(dt, useAnim)
    local c = addon.focus and addon.focus.collapse
    if not c then return end
    if not useAnim then
        if c.headerSlidingToBottom then
            if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(0) end
            c.headerSlidingToBottom = false
            c.headerSlideStartY = nil
            c.headerSlideTime = nil
        end
        if c.headerSlidingToTop then
            local endY = c.headerSlideEndY or 0
            if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(endY) end
            c.headerSlidingToTop = false
            c.headerSlideEndY = nil
            c.headerSlideTime = nil
        end
        return
    end
    if c.headerSlidingToBottom then
        c.headerSlideTime = (c.headerSlideTime or 0) + dt
        local p = GetProgress(c.headerSlideTime, 0, anim.dur)
        local ep = addon.easeOut and addon.easeOut(p) or p
        local startY = c.headerSlideStartY or 0
        local currentY = startY + (0 - startY) * ep
        if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(currentY) end
        if p >= 1 then
            if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(0) end
            c.headerSlidingToBottom = false
            c.headerSlideStartY = nil
            c.headerSlideTime = nil
        end
    end
    if c.headerSlidingToTop then
        -- headerSlideEndY is set in FullLayout after targetHeight; fallback if missed
        local endY = c.headerSlideEndY
        if not endY or endY <= 0 then
            local layout = addon.focus.layout
            local panelH = layout and layout.targetHeight or (addon.HS and addon.HS:GetHeight()) or addon.MIN_HEIGHT
            local minimal = addon.GetDB("hideObjectivesHeader", false)
            local S = addon.Scaled or function(v) return v end
            local pad = S(addon.PADDING)
            local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
            endY = math.max(0, (panelH or 0) - headerH)
            c.headerSlideEndY = endY
        end
        c.headerSlideTime = (c.headerSlideTime or 0) + dt
        local p = GetProgress(c.headerSlideTime, 0, anim.dur)
        local ep = addon.easeOut and addon.easeOut(p) or p
        local currentY = 0 + (endY - 0) * ep
        if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(currentY) end
        if p >= 1 then
            if addon.ApplyGrowUpHeaderPosition then addon.ApplyGrowUpHeaderPosition(endY) end
            c.headerSlidingToTop = false
            c.headerSlideEndY = nil
            c.headerSlideTime = nil
        end
    end
end

local function UpdateCollapseAnimations(dt, useAnim)
    if not addon.focus.collapse.animating then return end
    local stillCollapsing = false
    for i = 1, addon.POOL_SIZE do
        if pool[i].animState == "collapsing" then
            stillCollapsing = true
            break
        end
    end
    local stillSectionHeadersFadingOut = addon.focus.collapse.sectionHeadersFadingOut
    if not stillCollapsing and not stillSectionHeadersFadingOut then
        addon.focus.collapse.animating = false
        for i = 1, addon.POOL_SIZE do
            if pool[i].animState == "idle" and (pool[i].questID or pool[i].entryKey) then
                addon.ClearEntry(pool[i], false)
            end
        end
        wipe(addon.activeMap)
        if useAnim then
            addon.focus.collapse.sectionHeadersFadingIn  = true
            addon.focus.collapse.sectionHeaderFadeTime    = 0
        end
        if addon.FullLayout then addon.FullLayout() end
    end
end

-- Group collapse completion: when no entries in a group are collapsing anymore,
-- mark that group as collapsed and trigger a layout refresh.
-- Early reflow: triggers FullLayout + slide-up after 50% of collapse duration so
-- the slide animation overlaps with the tail end of the fade-out, removing the
-- visible delay before remaining entries move to fill the gap.
local groupReflowed = {}
local function UpdateGroupCollapseCompletion()
    if not addon.focus.collapse.groups then return end
    for groupKey, startTime in pairs(addon.focus.collapse.groups) do
        local stillCollapsing = false
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if e.groupKey == groupKey and e.animState == "collapsing" then
                stillCollapsing = true
                break
            end
        end

        -- Safety timeout in case something goes wrong with anim state.
        local timedOut = (GetTime() - startTime) > GROUP_COLLAPSE_TIMEOUT

        -- Early reflow: once half the collapse duration has elapsed, trigger
        -- layout + slide even though some entries are still fading out.
        local elapsed = GetTime() - startTime
        local earlyReflow = stillCollapsing
            and not timedOut
            and elapsed >= (anim.dur * 0.5)
            and not groupReflowed[groupKey]

        if not stillCollapsing or timedOut or earlyReflow then
            -- Capture Y positions of entries and section headers in other groups before layout reflow.
            local slideUpStarts = {}
            local slideUpStartsSec = {}
            local useAnim = addon.GetDB("animations", true)
            local needsReflow = not groupReflowed[groupKey]

            if needsReflow and useAnim then
                for i = 1, addon.POOL_SIZE do
                    local e = pool[i]
                    if e and (e.questID or e.entryKey)
                        and e.groupKey ~= groupKey
                        and e.animState == "active"
                        and e.finalY ~= nil then
                        local key = e.questID or e.entryKey
                        slideUpStarts[key] = e.finalY
                    end
                end
                for i = 1, addon.SECTION_POOL_SIZE do
                    local s = sectionPool[i]
                    if s and s.active and s.groupKey and s.groupKey ~= groupKey and s.finalY ~= nil then
                        slideUpStartsSec[s.groupKey] = s.finalY
                    end
                end
            end

            if earlyReflow then
                -- Mark as reflowed so we don't re-trigger on subsequent ticks.
                -- Remove from collapse.groups now so FullLayout doesn't bail out
                -- (it skips layout when any group is still in collapse.groups).
                -- Track in groupReflowed for final entry cleanup.
                groupReflowed[groupKey] = startTime
                addon.focus.collapse.groups[groupKey] = nil
            else
                -- Final cleanup: remove from groups and clean up tracking.
                addon.focus.collapse.groups[groupKey] = nil
                groupReflowed[groupKey] = nil

                -- Clean up any lingering collapsing entries for this group.
                for i = 1, addon.POOL_SIZE do
                    local e = pool[i]
                    if e.groupKey == groupKey and e.animState == "collapsing" then
                        addon.ClearEntry(e)
                    end
                end
            end

            -- Re-run layout so remaining groups close up the gap (only once per group).
            if needsReflow and addon.FullLayout then
                addon.FullLayout()
            end

            -- Apply slide-up animation to entries that moved up.
            if needsReflow and useAnim and next(slideUpStarts) then
                for i = 1, addon.POOL_SIZE do
                    local e = pool[i]
                    if e and (e.questID or e.entryKey) and e.animState == "active" and e.finalY ~= nil then
                        local key = e.questID or e.entryKey
                        local prevY = slideUpStarts[key]
                        if prevY and prevY ~= e.finalY then
                            addon.SetEntrySlideUp(e, prevY)
                        end
                    end
                end
            end

            -- Apply slide-up animation to section headers that moved up.
            if needsReflow and useAnim and next(slideUpStartsSec) then
                for i = 1, addon.SECTION_POOL_SIZE do
                    local s = sectionPool[i]
                    if s and s.active and s.groupKey and s.finalY ~= nil then
                        local prevY = slideUpStartsSec[s.groupKey]
                        if prevY and prevY ~= s.finalY then
                            s.slideUpStartY = prevY
                            s.slideUpAnimTime = 0
                        end
                    end
                end
            end
        end
    end

    -- Second pass: clean up groups that were early-reflowed once their entries finish collapsing.
    for groupKey, startTime in pairs(groupReflowed) do
        local stillCollapsing = false
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if e.groupKey == groupKey and e.animState == "collapsing" then
                stillCollapsing = true
                break
            end
        end
        local timedOut = (GetTime() - startTime) > GROUP_COLLAPSE_TIMEOUT
        if not stillCollapsing or timedOut then
            groupReflowed[groupKey] = nil
            for i = 1, addon.POOL_SIZE do
                local e = pool[i]
                if e.groupKey == groupKey and e.animState == "collapsing" then
                    addon.ClearEntry(e)
                end
            end
        end
    end
end

--- Captures current Y positions before a category expand. Call before SetCategoryCollapsed(key,false) and FullLayout.
--- @param groupKey string Category being expanded (e.g. "WORLD", "NEARBY")
function addon.PrepareGroupExpandSlideDown(groupKey)
    if not addon.GetDB("animations", true) or not groupKey then return end
    local collapse = addon.focus and addon.focus.collapse
    if not collapse then return end
    collapse.expandSlideDownStarts = {}
    collapse.expandSlideDownStartsSec = {}
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        if e and (e.questID or e.entryKey) and (e.animState == "active" or e.animState == "fadein") and e.finalY ~= nil then
            local key = e.questID or e.entryKey
            collapse.expandSlideDownStarts[key] = e.finalY
        end
    end
    for i = 1, addon.SECTION_POOL_SIZE do
        local s = sectionPool[i]
        if s and s.active and s.groupKey and s.finalY ~= nil then
            collapse.expandSlideDownStartsSec[s.groupKey] = s.finalY
        end
    end
end

--- Applies slide-down animation to entries and section headers that moved after category expand.
--- Call after FullLayout when expandSlideDownStarts/expandSlideDownStartsSec were set.
function addon.ApplyGroupExpandSlideDown()
    local collapse = addon.focus and addon.focus.collapse
    if not collapse or not addon.GetDB("animations", true) then return end
    local starts = collapse.expandSlideDownStarts
    local startsSec = collapse.expandSlideDownStartsSec
    collapse.expandSlideDownStarts = nil
    collapse.expandSlideDownStartsSec = nil
    if not starts and not startsSec then return end
    if starts and next(starts) then
        for i = 1, addon.POOL_SIZE do
            local e = pool[i]
            if e and (e.questID or e.entryKey) and e.animState == "active" and e.finalY ~= nil then
                local key = e.questID or e.entryKey
                local prevY = starts[key]
                if prevY and prevY ~= e.finalY then
                    addon.SetEntrySlideUp(e, prevY)
                end
            end
        end
    end
    if startsSec and next(startsSec) then
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.groupKey and s.finalY ~= nil then
                local prevY = startsSec[s.groupKey]
                if prevY and prevY ~= s.finalY then
                    s.slideUpStartY = prevY
                    s.slideUpAnimTime = 0
                end
            end
        end
    end
    if addon.EnsureFocusUpdateRunning then addon.EnsureFocusUpdateRunning() end
end

--- Clears optionCollapseKeys when all WQ-toggle collapsing entries have finished.
local function UpdateOptionCollapseCompletion()
    local keys = addon.focus and addon.focus.collapse and addon.focus.collapse.optionCollapseKeys
    if not keys or not next(keys) then return end
    local stillCollapsing = false
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        local key = e and (e.questID or e.entryKey)
        if key and keys[key] and e.animState == "collapsing" then
            stillCollapsing = true
            break
        end
    end
    if not stillCollapsing then
        addon.focus.collapse.optionCollapseKeys = nil
    end
end

--- Lerps entry title color for hover brighten/restore. Driven by entry.hoverAnimState ("in" | "out").
local function UpdateEntryHoverAnimations(dt, useAnim)
    if not useAnim or not pool then return false end
    local dur = (anim.hoverTitleDur or 0.15)
    local anyAnimating = false
    for i = 1, addon.POOL_SIZE do
        local e = pool[i]
        local state = e and e.hoverAnimState
        if state then
            anyAnimating = true
            e.hoverAnimTime = (e.hoverAnimTime or 0) + dt
            local from = e._hoverFromColor
            local to = e._hoverToColor
            if not from or not to or not e.titleText then
                e.hoverAnimState = nil
                e.hoverAnimTime = nil
                e._hoverFromColor = nil
                e._hoverToColor = nil
            else
                local p = math.min((e.hoverAnimTime or 0) / dur, 1)
                local ep = (state == "in") and addon.easeOut and addon.easeOut(p) or addon.easeIn and addon.easeIn(p) or p
                local r = from[1] + (to[1] - from[1]) * ep
                local g = from[2] + (to[2] - from[2]) * ep
                local b = from[3] + (to[3] - from[3]) * ep
                local a = (from[4] ~= nil and to[4] ~= nil) and (from[4] + (to[4] - from[4]) * ep) or 1
                e.titleText:SetTextColor(r, g, b, a)
                if p >= 1 then
                    e.titleText:SetTextColor(to[1], to[2], to[3], to[4] or 1)
                    e.hoverAnimState = nil
                    e.hoverAnimTime = nil
                    e._hoverFromColor = nil
                    e._hoverToColor = nil
                    if state == "out" then e._savedColor = nil end
                end
            end
        end
    end
    return anyAnimating
end

-- ============================================================================
-- EXPORTS (defined last so local Update* functions are in scope)
-- ============================================================================

function addon.EnsureFocusUpdateRunning()
    if not addon.HS or addon._focusUpdateRunning then return end
    addon._focusUpdateRunning = true
    addon.HS:SetScript("OnUpdate", function(_, dt)
        if not addon.focus.enabled then
            addon._focusUpdateRunning = false
            addon.HS:SetScript("OnUpdate", nil)
            return
        end
        dt = dt or 0
        local useAnim = addon.GetDB("animations", true)
        local mouseoverOnly = addon.GetDB("showOnMouseoverOnly", false)
        UpdatePanelHeight(dt)
        UpdateCombatFade(dt, useAnim)
        UpdateHoverFade(dt, useAnim)
        local anyEntryAnimating = UpdateEntryAnimations(dt, useAnim)
        UpdateSectionHeaderFadeOut(dt, useAnim)
        UpdateCollapseAnimations(dt, useAnim)
        UpdateGroupCollapseCompletion()
        UpdateOptionCollapseCompletion()
        UpdateSectionHeaderSlideUp(dt, useAnim)
        UpdateSectionHeaderFadeIn(dt, useAnim)
        UpdateHeaderSlide(dt, useAnim)
        local anyHoverTitleAnimating = UpdateEntryHoverAnimations(dt, useAnim)

        local anySectionSliding = false
        for i = 1, addon.SECTION_POOL_SIZE do
            local s = sectionPool[i]
            if s and s.active and s.slideUpStartY ~= nil then
                anySectionSliding = true
                break
            end
        end
        local hoverFadeNeedsUpdate = false
        if addon.focus.hoverFade and mouseoverOnly and HS:IsShown() and not addon.focus.combat.fadeState then
            local mouseOver = addon.IsFocusHoverActive()
            local fadeAlpha = GetFadeOnMouseoverAlpha()
            local targetAlpha = mouseOver and 1 or fadeAlpha
            local currentAlpha = HS:GetAlpha()
            hoverFadeNeedsUpdate = (addon.focus.hoverFade.fadeState ~= nil) or (math.abs(currentAlpha - targetAlpha) >= 0.01)
        end

        local stillAnimating = anyEntryAnimating
            or anyHoverTitleAnimating
            or anySectionSliding
            or (math.abs(addon.focus.layout.currentHeight - addon.focus.layout.targetHeight) > HEIGHT_SNAP_THRESHOLD)
            or addon.focus.collapse.animating
            or addon.focus.collapse.headerSlidingToBottom
            or addon.focus.collapse.headerSlidingToTop
            or (addon.focus.combat and addon.focus.combat.fadeState ~= nil)
            or hoverFadeNeedsUpdate
            or (addon.focus.collapse.groups and next(addon.focus.collapse.groups) ~= nil)
            or next(groupReflowed) ~= nil
            or (addon.focus.collapse.optionCollapseKeys and next(addon.focus.collapse.optionCollapseKeys) ~= nil)
            or addon.focus.collapse.sectionHeadersFadingOut
            or addon.focus.collapse.sectionHeadersFadingIn
        if not stillAnimating then
            addon._focusUpdateRunning = false
            addon.HS:SetScript("OnUpdate", nil)
        end
    end)
end
