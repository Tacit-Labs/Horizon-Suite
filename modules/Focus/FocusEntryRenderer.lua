--[[
    Horizon Suite - Focus - Entry Renderer
    PopulateEntry, ApplyHighlightStyle, ApplyObjectives, ApplyScenarioOrWQTimerBar, ApplyShadowColors.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

--- Returns true when Auctionator's v1 CreateShoppingList API is available.
-- Result is cached after the first positive hit so we don't re-walk globals every render pass.
local _auctionatorAvailable = nil
local function IsAuctionatorAvailable()
    if _auctionatorAvailable then return true end
    local ok = Auctionator and Auctionator.API and Auctionator.API.v1
        and type(Auctionator.API.v1.CreateShoppingList) == "function"
    if ok then _auctionatorAvailable = true end
    return ok and true or false
end

--- Returns true when the Auction House frame is currently open.
local function IsAHOpen()
    return (AuctionHouseFrame and AuctionHouseFrame:IsShown())
        or (AuctionFrame and AuctionFrame:IsShown())
end

--- True if text contains the localized "abundance held" phrase (case-insensitive). Used for Abundance scenario.
local function isAbundanceHeld(text)
    if not text or type(text) ~= "string" then return false end
    local phrase = (addon.L and addon.L["UI_ABUNDANCE_HELD"]) or "abundance held"
    return text:lower():find(phrase:lower(), 1, true) ~= nil
end

--- True if text contains the localized "Abundance Bag" phrase (case-insensitive). Hide from inline; bar shows abundance held.
local function isAbundanceBag(text)
    if not text or type(text) ~= "string" then return false end
    local phrase = (addon.L and addon.L["UI_ABUNDANCE_BAG"]) or "Abundance Bag"
    return text:lower():find(phrase:lower(), 1, true) ~= nil
end

--- True if objective is intrinsically percent-based (text "X%", progressbar type, or weighted), not derived from X/Y.
local function IsIntrinsicallyPercentBased(o)
    if not o then return false end
    local textPct = o.text and tonumber(o.text:match("(%d+)%%"))
    local isProgressBarType = (o.type == "progressbar" or o.type == 8 or o.isWeighted)
    return (textPct ~= nil) or isProgressBarType
end

local function IsProgressBarEnabled(questData)
    local isScenario = questData.category == "SCENARIO"
        or questData.category == "DELVES"
        or questData.category == "DUNGEON"
        or questData.isScenarioMain
        or questData.isScenarioBonus
    if isScenario then
        return addon.GetDB("showProgressBarScenarios", true)
    else
        return addon.GetDB("showProgressBarQuests", true)
    end
end

local function hideAllHighlight(entry)
    entry.trackBar:Hide()
    entry.highlightBg:Hide()
    if entry.highlightTop then entry.highlightTop:Hide() end
    entry.highlightBorderT:Hide()
    entry.highlightBorderB:Hide()
    entry.highlightBorderL:Hide()
    entry.highlightBorderR:Hide()
end

local function ApplyHighlightStyle(entry, questData)
    local highlightStyle = addon.NormalizeHighlightStyle(addon.GetDB("activeQuestHighlight", "bar-left")) or "bar-left"
    local hc = addon.GetDB("highlightColor", nil)
    if not hc or #hc < 3 then hc = { 0.40, 0.70, 1.00 } end
    local fcc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if fcc then
        hc = { fcc[1], fcc[2], fcc[3] }
    end
    local ha = tonumber(addon.GetDB("highlightAlpha", 0.25)) or 0.25
    local barW = math.max(2, math.min(6, tonumber(addon.GetDB("highlightBarWidth", 2)) or 2))
    local topPadding = (questData.isSuperTracked and highlightStyle == "bar-top") and barW or 0
    local bottomPadding = (questData.isSuperTracked and highlightStyle == "bar-bottom") and barW or 0

    entry.titleText:ClearAllPoints()
    -- Keep the pool's default left padding (1-space) and just apply topPadding.
    local x, y = entry.titleText:GetPoint(1)
    local xOff = (type(x) == "number") and x or 4
    entry.titleText:SetPoint("TOPLEFT", entry, "TOPLEFT", xOff, -topPadding)
    entry.titleShadow:ClearAllPoints()
    entry.titleShadow:SetPoint("CENTER", entry.titleText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

    hideAllHighlight(entry)
    if questData.isSuperTracked then
        local borderAlpha = math.min(1, (ha + 0.35))
        if highlightStyle == "bar-left" or highlightStyle == "bar-right" or highlightStyle == "pill-left" then
            entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], 0.70)
            entry.trackBar:Show()
        elseif highlightStyle == "bar-top" then
            entry.highlightTop:SetColorTexture(hc[1], hc[2], hc[3], 0.70)
            entry.highlightTop:SetHeight(barW)
            entry.highlightTop:Show()
        elseif highlightStyle == "bar-bottom" then
            entry.highlightBorderB:SetColorTexture(hc[1], hc[2], hc[3], 0.70)
            entry.highlightBorderB:SetHeight(barW)
            entry.highlightBorderB:Show()
        elseif highlightStyle == "outline" then
            entry.highlightBorderB:SetHeight(1)
            entry.highlightBorderL:SetWidth(1)
            entry.highlightBorderR:SetWidth(1)
            for _, tex in ipairs({ entry.highlightBorderT, entry.highlightBorderB, entry.highlightBorderL, entry.highlightBorderR }) do
                tex:SetColorTexture(hc[1], hc[2], hc[3], borderAlpha)
                tex:Show()
            end
        elseif highlightStyle == "bar-both" then
            entry.highlightBorderL:SetColorTexture(hc[1], hc[2], hc[3], 0.70)
            entry.highlightBorderL:SetWidth(2)
            entry.highlightBorderL:Show()
            entry.highlightBorderR:SetColorTexture(hc[1], hc[2], hc[3], 0.70)
            entry.highlightBorderR:SetWidth(2)
            entry.highlightBorderR:Show()
        else
            entry.highlightBg:SetColorTexture(hc[1], hc[2], hc[3], ha)
            entry.highlightBg:Show()
            entry.highlightTop:SetHeight(2)
            entry.highlightTop:SetColorTexture(hc[1], hc[2], hc[3], math.min(1, ha + 0.2))
            entry.highlightTop:Show()
            for _, tex in ipairs({ entry.highlightBorderT, entry.highlightBorderB, entry.highlightBorderL, entry.highlightBorderR }) do
                tex:SetColorTexture(hc[1], hc[2], hc[3], borderAlpha)
                tex:Show()
            end
        end
    end
    return highlightStyle, hc, ha, barW, topPadding, bottomPadding
end

local function ApplyObjectives(entry, questData, textWidth, prevAnchor, totalH, c, effectiveCat, effectiveTitleRowH, titleToContentSpacing)
    local S = addon.Scaled or function(v) return v end
    local objIndent = addon.GetObjIndent()
    -- Indentation now comes from the entry's padded title anchor; keep objective indent consistent.

    -- Additional left padding for objectives only (not zone line), matching bar->icon gap when icons are enabled.
    local OBJ_EXTRA_LEFT_PAD = S(14)

    local objTextWidth = textWidth - objIndent
    if objTextWidth < 1 then objTextWidth = addon.GetPanelWidth() - S(addon.PADDING) * 2 - objIndent - S(addon.CONTENT_RIGHT_PADDING or 0) end

    local objSpacing = ((questData.category == "DELVES" or questData.category == "DUNGEON") and S(addon.DELVE_OBJ_SPACING)) or addon.GetObjSpacing()
    local titleGap = titleToContentSpacing or objSpacing

    local cat = (effectiveCat ~= nil and effectiveCat ~= "") and effectiveCat or questData.category
    local objColor = (addon.GetObjectiveColor and addon.GetObjectiveColor(cat)) or addon.OBJ_COLOR or c
    local doneColor = (addon.GetCompletedObjectiveColor and addon.GetCompletedObjectiveColor(cat))
        or (addon.GetObjectiveColor and addon.GetObjectiveColor(cat)) or addon.OBJ_DONE_COLOR
    local dimTextAlpha = 1
    if addon.ShouldApplySuperTrackQuestDim(questData) then
        objColor = addon.ApplyDimColor(objColor)
        doneColor = addon.ApplyDimColor(doneColor)
        dimTextAlpha = addon.GetDimAlpha()
    end
    local effectiveDoneColor = doneColor

    local maxObjs = addon.MAX_OBJECTIVES
    local showEllipsis = (questData.isAchievement or questData.isEndeavor) and questData.objectives and #questData.objectives > maxObjs

    -- Progress bar: determine which objectives are eligible for a per-objective bar.
    -- Eligible: (a) arithmetic (numFulfilled/numRequired, numRequired > 1) or (b) percent-only (percent set, numRequired nil/0/1 or type progressbar).
    -- progressBarTypeFilter: "both" | "xy_only" | "percent_only" controls which types get a bar.
    local showProgressBar = IsProgressBarEnabled(questData)
    local progressBarTypeFilter = addon.GetDB("progressBarTypeFilter", "percent_only")
    local progressBarObjIdx = nil
    local progressBarNf, progressBarNr = nil, nil
    local progressBarPercent = nil
    local progressBarSet = nil -- set of eligible objective indices for scenario/delve multi-objective entries
    if showProgressBar and questData.objectives and not questData.isAbundanceScenario then
        local barCount = 0
        local barIdx = nil
        local barNf, barNr = nil, nil
        local barPct = nil
        local isScenarioEntry = questData.isScenarioMain or questData.isScenarioBonus
        local eligibleSet = isScenarioEntry and {} or nil
        for idx, o in ipairs(questData.objectives) do
            local textPct = o.text and tonumber(o.text:match("(%d+)%%"))
            local isProgressBarType = (o.type == "progressbar" or o.type == 8 or o.isWeighted)
            local hasArithmetic = (o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numRequired) == "number" and o.numRequired > 1)

            if not o.finished then
                if (isProgressBarType or textPct or (o.percent ~= nil and not hasArithmetic)) then
                    -- Weighted/Percent progress (highest priority)
                    if (progressBarTypeFilter == "both" or progressBarTypeFilter == "percent_only") then
                        barCount = barCount + 1
                        if not barPct then
                            barIdx = idx
                            barNf, barNr = nil, nil
                            barPct = textPct or o.percent or 0
                        end
                        if eligibleSet then eligibleSet[idx] = true end
                    end
                elseif (o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numFulfilled) == "number" and type(o.numRequired) == "number" and o.numRequired > 1) then
                    -- Arithmetic (x/10 style) - lower priority than weighted
                    if (progressBarTypeFilter == "both" or progressBarTypeFilter == "xy_only") then
                        barCount = barCount + 1
                        if not barPct and not barNf then
                            barIdx = idx
                            barNf = o.numFulfilled
                            barNr = o.numRequired
                        end
                        if eligibleSet then eligibleSet[idx] = true end
                    end
                end
            end
        end
        if isScenarioEntry and barCount > 0 then
            -- Scenario/delve entries: allow per-objective bars for all eligible objectives.
            progressBarSet = eligibleSet
            progressBarObjIdx = barIdx
            progressBarNf = barNf
            progressBarNr = barNr
            progressBarPercent = barPct
        elseif barCount == 1 and questData.objectives and #questData.objectives == 1 then
            -- Non-scenario: only show bar when exactly one objective total and it is eligible.
            progressBarObjIdx = barIdx
            progressBarNf = barNf
            progressBarNr = barNr
            progressBarPercent = barPct
        end
    end

    -- When the progress bar is active, flag the questData so the title renderer
    -- can suppress its own (X/Y) to avoid duplication.
    questData._progressBarActive = (progressBarObjIdx ~= nil)

    local PROGRESS_BAR_SPACING = S(3)
    -- Bar height is dynamic: font size + padding so the label fits inside.
    local progBarFontSz = math.max(7, (tonumber(addon.GetDB("progressBarFontSize", 10)) or 10) + (tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0))
    local PROGRESS_BAR_HEIGHT = S(math.max(8, progBarFontSz + 4))

    -- Progress bar fill color: category color when option on, else custom from DB
    local progFillColor
    if addon.GetDB("progressBarUseCategoryColor", true) then
        progFillColor = c or (addon.GetTitleColor and addon.GetTitleColor(effectiveCat)) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.90, 0.90, 0.90 }
    else
        progFillColor = addon.GetDB("progressBarFillColor", nil)
        if not progFillColor or type(progFillColor) ~= "table" then progFillColor = { 0.40, 0.65, 0.90 } end
    end
    local progTextColor = addon.GetDB("progressBarTextColor", nil)
    if not progTextColor or type(progTextColor) ~= "table" then progTextColor = { 0.95, 0.95, 0.95 } end

    local shownObjs = 0
    local entryKey = questData.entryKey or entry.entryKey
    -- Default collapsed when key not in table (nil).
    local optCollapsed = not (addon.focus and addon.focus.recipeOptionalCollapsed and addon.focus.recipeOptionalCollapsed[entryKey] == false)
    local finCollapsed = not (addon.focus and addon.focus.recipeFinishingCollapsed and addon.focus.recipeFinishingCollapsed[entryKey] == false)

    for j = 1, addon.MAX_OBJECTIVES do
        local obj = entry.objectives[j]
        local oData = questData.objectives[j]
        if showEllipsis then
            if j == maxObjs then
                oData = { text = "...", finished = false }
            elseif j > maxObjs then
                oData = nil
            end
        end

        -- Skip optional/finishing reagents when their section is collapsed.
        if oData and oData.isOptionalReagent and optCollapsed then oData = nil end
        if oData and oData.isFinishingReagent and finCollapsed then oData = nil end

        -- Auto-complete quests: always show "Quest Complete / Click to complete" block, overwriting objectives.
        if oData and questData.isComplete and (questData.isAutoComplete and true or false) then oData = nil end

        obj.text:SetWidth(objTextWidth)
        obj.shadow:SetWidth(objTextWidth)

        if oData then
            -- Abundance: hide widget objectives inline; the wqProgress bar displays them instead.
            if questData.isAbundanceScenario and oData.isWeighted then
                oData = nil
            end
        end
        if oData then
            local objText = oData.text or ""
            local nf, nr = oData.numFulfilled, oData.numRequired
            local thisObjHasBar = (progressBarObjIdx == j) or (progressBarSet and progressBarSet[j])
            local isRecipeHeader = oData.isOptionalHeader or oData.isFinishingHeader

            if isRecipeHeader then
                local baseText = oData.text or ""
                local count = oData.sectionCount
                if count and type(count) == "number" then baseText = baseText .. " (" .. count .. ")" end
                local collapsed = (oData.isOptionalHeader and optCollapsed) or (oData.isFinishingHeader and finCollapsed)
                objText = baseText .. " " .. (collapsed and "+" or "-")
            else
                -- Recipe reagents: count before text (e.g. "0/1 Hochenblume"). Skip informational lines (Can craft, Quality, Requirements).
                local isRecipeReagent = questData.isRecipe and not oData.isCraftableCount and not oData.isQualityInfo and not oData.isRequirement
                if isRecipeReagent and not thisObjHasBar and nf ~= nil and nr ~= nil and type(nf) == "number" and type(nr) == "number" and nr > 0 then
                    objText = ("%d/%d %s"):format(nf, nr, objText)
                else
                    -- Quest objectives: append (X/Y) when nr > 1. Skip when title shows it or progress bar is active.
                    local titleShowsNumeric = questData.numericQuantity ~= nil and questData.numericRequired and type(questData.numericRequired) == "number" and questData.numericRequired > 1
                    local singleObjective = questData.objectives and #questData.objectives == 1
                    if not thisObjHasBar and nf ~= nil and nr ~= nil and type(nf) == "number" and type(nr) == "number" and nr > 1 and not (titleShowsNumeric and singleObjective) then
                        local pattern = tostring(nf) .. "/" .. tostring(nr)
                        if not objText:find(pattern, 1, true) then
                            objText = objText .. (" (%d/%d)"):format(nf, nr)
                        end
                    end
                end
                -- Strip trailing (X/Y) when text already starts with X/Y (scenario/delve often duplicate)
                if nf and nr and (questData.category == "SCENARIO" or questData.category == "DELVES" or questData.category == "DUNGEON") then
                    local pattern = ("%d/%d"):format(nf, nr)
                    local trailing = (" (%s)"):format(pattern)
                    if #objText >= #trailing and objText:sub(1, #pattern + 1) == pattern .. " " and objText:sub(-#trailing) == trailing then
                        objText = objText:sub(1, #objText - #trailing)
                    end
                end
                local prefixStyle = addon.GetDB("objectivePrefixStyle", "none")
                if prefixStyle == "numbers" then
                    objText = ("%d. %s"):format(j, objText)
                elseif prefixStyle == "hyphens" then
                    objText = "- " .. objText
                end
            end
            local useTick = oData.finished and addon.GetDB("useTickForCompletedObjectives", false) and not questData.isComplete
            obj.text:SetText(objText)
            obj.shadow:SetText(objText)

            local tickSize = math.max(10, (tonumber(addon.GetDB("objectiveFontSize", 11)) or 11) + (tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0))
            if useTick and obj.tick then
                obj.tick:SetSize(tickSize, tickSize)
                obj.tick:ClearAllPoints()
                obj.tick:SetPoint("RIGHT", obj.text, "LEFT", -4, 0)
                obj.tick:Show()
            elseif obj.tick then
                obj.tick:Hide()
            end

            local alpha = 1
            if oData.finished and (not questData.isAchievement and not questData.isEndeavor) and addon.GetDB("questCompletedObjectiveDisplay", "off") == "fade" then
                alpha = 0.4
            end
            obj._hsFinished = oData.finished and true or false
            obj._hsAlpha = alpha
            obj._hsItemQuality = oData.itemQuality
            local useObjColor = objColor
            if questData.isRecipe and addon.GetDB("recipeRarityColors", false) and oData.itemQuality then
                local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[oData.itemQuality]
                if qc then useObjColor = { qc.r, qc.g, qc.b } end
            end
            local outA = alpha * dimTextAlpha
            if oData.finished then
                if useTick then
                    obj.text:SetTextColor(useObjColor[1], useObjColor[2], useObjColor[3], outA)
                else
                    obj.text:SetTextColor(effectiveDoneColor[1], effectiveDoneColor[2], effectiveDoneColor[3], outA)
                end
            else
                obj.text:SetTextColor(useObjColor[1], useObjColor[2], useObjColor[3], outA)
            end

            obj.text:ClearAllPoints()
            -- First objective gets inset from title; subsequent objectives align with it.
            -- When prevAnchor is titleText, use effectiveTitleRowH so objectives sit below inline timer (world quests, etc.).
            -- Use titleGap (title-to-content) for first objective below title; objSpacing for subsequent.
            local leftPad = (shownObjs == 0) and OBJ_EXTRA_LEFT_PAD or 0
            local gapForThisObj = (shownObjs == 0 and prevAnchor == entry.titleText) and titleGap or objSpacing
            if shownObjs == 0 and prevAnchor == entry.titleText and effectiveTitleRowH then
                obj.text:SetPoint("TOPLEFT", prevAnchor, "TOPLEFT", leftPad, -effectiveTitleRowH - gapForThisObj)
            else
                obj.text:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", leftPad, -gapForThisObj)
            end
            obj.text:Show()
            obj.shadow:Show()

            -- Collapsible header: show button and set click handler.
            if obj.collapseBtn then
                if isRecipeHeader then
                    obj.collapseBtn:ClearAllPoints()
                    obj.collapseBtn:SetPoint("TOPLEFT", obj.text, "TOPLEFT", -leftPad, 2)
                    obj.collapseBtn:SetPoint("BOTTOMRIGHT", obj.text, "BOTTOMRIGHT", 0, -2)
                    obj.collapseBtn:Show()
                    local isOpt = oData.isOptionalHeader
                    obj.collapseBtn:SetScript("OnClick", function(_, button)
                        if button ~= "LeftButton" then return end
                        local key = entry.entryKey or questData.entryKey
                        if not key or not addon.focus then return end
                        local collapsed
                        if isOpt then collapsed = optCollapsed else collapsed = finCollapsed end
                        if isOpt then
                            addon.focus.recipeOptionalCollapsed = addon.focus.recipeOptionalCollapsed or {}
                            addon.focus.recipeOptionalCollapsed[key] = not collapsed
                        else
                            addon.focus.recipeFinishingCollapsed = addon.focus.recipeFinishingCollapsed or {}
                            addon.focus.recipeFinishingCollapsed[key] = not collapsed
                        end
                        if addon.ScheduleRefresh then addon.ScheduleRefresh() end
                    end)
                else
                    obj.collapseBtn:Hide()
                end
            end

            local objH = obj.text:GetStringHeight()
            if not objH or objH < 1 then objH = addon.OBJ_SIZE + 2 end
            totalH = totalH + gapForThisObj + objH

            prevAnchor = obj.text

            -- Progress bar for this objective
            local pctVal = progressBarPercent or oData.percent
            if thisObjHasBar and nf and nr and type(nf) == "number" and type(nr) == "number" and nr > 1 then
                -- Arithmetic (x/10): use nf/nr for fraction and "X/Y (Z%)" label
                local barW = objTextWidth - leftPad
                if barW < 20 then barW = objTextWidth end
                local fraction = math.min(nf / nr, 1)
                local fillW = math.max(1, barW * fraction)

                obj.progressBarBg:ClearAllPoints()
                obj.progressBarBg:SetPoint("TOPLEFT", obj.text, "BOTTOMLEFT", 0, -PROGRESS_BAR_SPACING)
                obj.progressBarBg:SetSize(barW, PROGRESS_BAR_HEIGHT)
                obj.progressBarBg:SetColorTexture(0.15, 0.15, 0.18, 0.7)
                obj.progressBarBg:Show()

                obj.progressBarFill:ClearAllPoints()
                obj.progressBarFill:SetPoint("TOPLEFT", obj.progressBarBg, "TOPLEFT", 0, 0)
                obj.progressBarFill:SetPoint("BOTTOMLEFT", obj.progressBarBg, "BOTTOMLEFT", 0, 0)
                obj.progressBarFill:SetWidth(fillW)
                addon.ApplyProgressBarFillTexture(obj.progressBarFill, progFillColor[1], progFillColor[2], progFillColor[3], progFillColor[4] or 0.85)
                obj.progressBarFill:Show()

                if obj.progressBarLabel then
                    local pct = math.floor(100 * fraction)
                    obj.progressBarLabel:SetText(("%d/%d (%d%%)"):format(nf, nr, pct))
                    obj.progressBarLabel:SetTextColor(progTextColor[1], progTextColor[2], progTextColor[3], dimTextAlpha)
                    obj.progressBarLabel:ClearAllPoints()
                    obj.progressBarLabel:SetPoint("CENTER", obj.progressBarBg, "CENTER", 0, 0)
                    obj.progressBarLabel:Show()
                end

                totalH = totalH + PROGRESS_BAR_SPACING + PROGRESS_BAR_HEIGHT
                prevAnchor = obj.progressBarBg
            elseif thisObjHasBar and pctVal ~= nil and type(pctVal) == "number" then
                -- Percent-only: use percent/100 for fraction and "Z%" label
                local barW = objTextWidth - leftPad
                if barW < 20 then barW = objTextWidth end
                local fraction = math.min(math.max(0, pctVal / 100), 1)
                local fillW = math.max(1, barW * fraction)

                obj.progressBarBg:ClearAllPoints()
                obj.progressBarBg:SetPoint("TOPLEFT", obj.text, "BOTTOMLEFT", 0, -PROGRESS_BAR_SPACING)
                obj.progressBarBg:SetSize(barW, PROGRESS_BAR_HEIGHT)
                obj.progressBarBg:SetColorTexture(0.15, 0.15, 0.18, 0.7)
                obj.progressBarBg:Show()

                obj.progressBarFill:ClearAllPoints()
                obj.progressBarFill:SetPoint("TOPLEFT", obj.progressBarBg, "TOPLEFT", 0, 0)
                obj.progressBarFill:SetPoint("BOTTOMLEFT", obj.progressBarBg, "BOTTOMLEFT", 0, 0)
                obj.progressBarFill:SetWidth(fillW)
                addon.ApplyProgressBarFillTexture(obj.progressBarFill, progFillColor[1], progFillColor[2], progFillColor[3], progFillColor[4] or 0.85)
                obj.progressBarFill:Show()

                if obj.progressBarLabel then
                    obj.progressBarLabel:SetText(("%d%%"):format(math.floor(pctVal)))
                    obj.progressBarLabel:SetTextColor(progTextColor[1], progTextColor[2], progTextColor[3], dimTextAlpha)
                    obj.progressBarLabel:ClearAllPoints()
                    obj.progressBarLabel:SetPoint("CENTER", obj.progressBarBg, "CENTER", 0, 0)
                    obj.progressBarLabel:Show()
                end

                totalH = totalH + PROGRESS_BAR_SPACING + PROGRESS_BAR_HEIGHT
                prevAnchor = obj.progressBarBg
            else
                if obj.progressBarBg then obj.progressBarBg:Hide() end
                if obj.progressBarFill then obj.progressBarFill:Hide() end
                if obj.progressBarLabel then obj.progressBarLabel:Hide() end
            end

            shownObjs = shownObjs + 1
        else
            obj._hsFinished = nil
            obj._hsAlpha = nil
            obj._hsItemQuality = nil
            obj.text:Hide()
            obj.shadow:Hide()
            if obj.tick then obj.tick:Hide() end
            if obj.collapseBtn then obj.collapseBtn:Hide() end
            if obj.progressBarBg then obj.progressBarBg:Hide() end
            if obj.progressBarFill then obj.progressBarFill:Hide() end
            if obj.progressBarLabel then obj.progressBarLabel:Hide() end
        end
    end

    if questData.isComplete and shownObjs == 0 then
        local obj = entry.objectives[1]
        local isAutoComplete = questData.isAutoComplete and true or false
        local L = addon.L or {}
        local readyToTurnIn = L["UI_READY_TO_TURN_IN"] or "Ready to turn in"
        local firstLineText = isAutoComplete
            and (_G.QUEST_WATCH_QUEST_COMPLETE or "Quest Complete")
            or (addon.GetDB("objectivePrefixStyle", "none") == "numbers" and ("1. " .. readyToTurnIn)
                or addon.GetDB("objectivePrefixStyle", "none") == "hyphens" and ("- " .. readyToTurnIn)
                or readyToTurnIn)
        obj.text:SetText(firstLineText)
        obj.shadow:SetText(firstLineText)
        obj._hsFinished = true
        obj._hsAlpha = 1
        obj.text:SetTextColor(doneColor[1], doneColor[2], doneColor[3], dimTextAlpha)
        obj.text:ClearAllPoints()
        local gapForComplete = (prevAnchor == entry.titleText) and titleGap or objSpacing
        obj.text:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", OBJ_EXTRA_LEFT_PAD, -gapForComplete)
        obj.text:Show()
        obj.shadow:Show()
        local objH = obj.text:GetStringHeight()
        if not objH or objH < 1 then objH = addon.OBJ_SIZE + 2 end
        totalH = totalH + gapForComplete + objH
        prevAnchor = obj.text

        if isAutoComplete then
            local obj2 = entry.objectives[2]
            local clickText = _G.QUEST_WATCH_CLICK_TO_COMPLETE or "(click to complete)"
            obj2.text:SetText(clickText)
            obj2.shadow:SetText(clickText)
            obj2._hsFinished = true
            obj2._hsAlpha = 1
            obj2.text:SetTextColor(doneColor[1], doneColor[2], doneColor[3], dimTextAlpha)
            obj2.text:ClearAllPoints()
            obj2.text:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -objSpacing)
            obj2.text:Show()
            obj2.shadow:Show()
            local obj2H = obj2.text:GetStringHeight()
            if not obj2H or obj2H < 1 then obj2H = addon.OBJ_SIZE + 2 end
            totalH = totalH + objSpacing + obj2H
            prevAnchor = obj2.text
        end
    end

    return totalH, prevAnchor
end

--- Get timer display info for an entry. Returns timerStr and optionally duration/startTime for ticker.
--- @return string|nil timerStr
--- @return number|nil duration
--- @return number|nil startTime
local function GetTimerDisplayInfo(questData, isWorld, isScenario, isGenericTimed)
    local hasStructuredTimer = (questData.timerDuration and questData.timerStartTime) and true or false
    if not hasStructuredTimer and questData.objectives then
        for _, o in ipairs(questData.objectives) do
            if o.timerDuration and o.timerStartTime then hasStructuredTimer = true; break end
        end
    end
    local timerStr, duration, startTime
    if questData.timerDuration and questData.timerStartTime then
        local now = GetTime()
        local remaining = questData.timerDuration - (now - questData.timerStartTime)
        if remaining > 0 then
            timerStr = addon.FormatTimeRemaining(remaining)
            duration, startTime = questData.timerDuration, questData.timerStartTime
        end
    end
    if not timerStr and questData.objectives then
        for _, o in ipairs(questData.objectives) do
            if o.timerDuration and o.timerStartTime then
                local now = GetTime()
                local remaining = o.timerDuration - (now - o.timerStartTime)
                if remaining > 0 then
                    timerStr = addon.FormatTimeRemaining(remaining)
                    duration, startTime = o.timerDuration, o.timerStartTime
                    break
                end
            end
        end
    end
    if not timerStr then
        if questData.timeLeftSeconds and questData.timeLeftSeconds > 0 then
            timerStr = addon.FormatTimeRemaining(questData.timeLeftSeconds)
            duration = questData.timeLeftSeconds
            startTime = GetTime()
        elseif questData.timeLeft and questData.timeLeft > 0 then
            timerStr = addon.FormatTimeRemainingFromMinutes(questData.timeLeft)
            duration = questData.timeLeft * 60
            startTime = GetTime()
        end
    end
    return timerStr, duration, startTime
end

local function ApplyScenarioOrWQTimerBar(entry, questData, textWidth, prevAnchor, totalH)
    -- Master toggle for timer / reverse-progress bars.
    local showTimerBars = addon.GetDB("showTimerBars", true)

    if not showTimerBars then
        entry.wqTimerText:Hide()
        entry.wqProgressBg:Hide()
        entry.wqProgressFill:Hide()
        entry.wqProgressText:Hide()
        if entry.inlineTimerText then entry.inlineTimerText:Hide() end
        entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do bar:Hide() end
        end
        -- Abundance progress bar is independent of the timer toggle; continue to show it.
        if not questData.isAbundanceScenario then
            return totalH
        end
    end
    local timerDisplayMode = addon.GetDB("timerDisplayMode", "inline")
    local isWorld = questData.category == "WORLD" or questData.category == "CALLING"
    local isScenarioOrDelve = questData.category == "SCENARIO" or questData.category == "DELVES" or questData.category == "DUNGEON"

    -- Determine whether this entry carries structured timer data (duration + startTime)
    -- on the entry itself or on one of its objectives.
    local hasStructuredTimer = (questData.timerDuration and questData.timerStartTime) and true or false
    if not hasStructuredTimer and questData.objectives then
        for _, o in ipairs(questData.objectives) do
            if o.timerDuration and o.timerStartTime then hasStructuredTimer = true; break end
        end
    end

    -- Legacy timer fields (minutes/seconds text only, no progress bar).
    local hasLegacyTimer = (questData.timeLeftSeconds and questData.timeLeftSeconds > 0)
        or (questData.timeLeft and questData.timeLeft > 0)

    local hasAnyTimer = hasStructuredTimer or hasLegacyTimer

    -- Any non-scenario entry with timer data gets the timed treatment (reverse progress bar + countdown).
    local isGenericTimed = (not isScenarioOrDelve) and hasAnyTimer and not questData.isRare

    if not isWorld and not isScenarioOrDelve and not isGenericTimed then
        entry.wqTimerText:Hide()
        entry.wqProgressBg:Hide()
        entry.wqProgressFill:Hide()
        entry.wqProgressText:Hide()
        if entry.inlineTimerText then entry.inlineTimerText:Hide() end
        entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do bar:Hide() end
        end
        return totalH
    end
    if (isWorld or isScenarioOrDelve) and questData.isRare then
        entry.wqTimerText:Hide()
        entry.wqProgressBg:Hide()
        entry.wqProgressFill:Hide()
        entry.wqProgressText:Hide()
        if entry.inlineTimerText then entry.inlineTimerText:Hide() end
        entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do bar:Hide() end
        end
        return totalH
    end

    -- Inline mode: timer beside title. For non-scenarios, return early (progress bar stays optional).
    -- For scenarios only: skip timer bar display below but still run progress bar logic (Abundance bar).
    local skipTimerBarDisplay = ((timerDisplayMode == "inline" or timerDisplayMode == "inline-below") and entry._inlineTimerStr)
    if skipTimerBarDisplay then
        entry.wqTimerText:Hide()
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do bar.duration = nil; bar.startTime = nil; bar:Hide() end
        end
        if not isScenarioOrDelve then
            entry.wqProgressBg:Hide()
            entry.wqProgressFill:Hide()
            entry.wqProgressText:Hide()
            return totalH
        end
    end

    -- Bar mode: hide any stray inline timer from a previous layout (only when not using inline).
    if not skipTimerBarDisplay then
        if entry.inlineTimerText then entry.inlineTimerText:Hide() end
        entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil
    end

    local S = addon.Scaled or function(v) return v end
    local objIndent = addon.GetObjIndent()

    -- Use the same bar width as objective progress bars for consistent alignment.
    local OBJ_EXTRA_LEFT_PAD = S(14)
    local objTextWidth = textWidth - objIndent
    if objTextWidth < 1 then objTextWidth = addon.GetPanelWidth() - S(addon.PADDING) * 2 - objIndent - S(addon.CONTENT_RIGHT_PADDING or 0) end
    local barW = objTextWidth - OBJ_EXTRA_LEFT_PAD
    if barW < 20 then barW = objTextWidth end

    local barH = S(addon.WQ_TIMER_BAR_HEIGHT or 6)
    local spacing = addon.GetObjSpacing()
    local timedBarTopMargin = (isScenarioOrDelve or isGenericTimed) and S(4) or 0
    local timedFirstElementPlaced = false

    -- Quest bar format for scenario/timed entries: same height, colors, and font as objective progress bars
    local progBarFontSz = math.max(7, (tonumber(addon.GetDB("progressBarFontSize", 10)) or 10) + (tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0))
    local PROGRESS_BAR_HEIGHT = S(math.max(8, progBarFontSz + 4))
    local progFillColor, progTextColor
    if isScenarioOrDelve or isGenericTimed then
        if addon.GetDB("progressBarUseCategoryColor", true) then
            local colorCat = questData.category or "DEFAULT"
            progFillColor = (addon.GetQuestColor and addon.GetQuestColor(colorCat)) or (addon.QUEST_COLORS and addon.QUEST_COLORS[colorCat]) or { 0.55, 0.35, 0.85 }
        else
            progFillColor = addon.GetDB("progressBarFillColor", nil)
            if not progFillColor or type(progFillColor) ~= "table" then progFillColor = { 0.40, 0.65, 0.90 } end
        end
        progTextColor = addon.GetDB("progressBarTextColor", nil)
        if not progTextColor or type(progTextColor) ~= "table" then progTextColor = { 0.95, 0.95, 0.95 } end
    end

    local showBar
    -- Use cinematic timer bars (reverse progress) for scenario entries and any entry with structured timer data.
    local wantTimerBars = showTimerBars and ((isScenarioOrDelve and addon.GetDB("cinematicScenarioBar", true)) or (isGenericTimed and hasStructuredTimer))
    if wantTimerBars and entry.scenarioTimerBars and not skipTimerBarDisplay then
        local timerSources = {}
        for _, o in ipairs(questData.objectives or {}) do
            if o.timerDuration and o.timerStartTime then
                timerSources[#timerSources + 1] = { duration = o.timerDuration, startTime = o.timerStartTime }
            end
        end
        if #timerSources == 0 and questData.timerDuration and questData.timerStartTime then
            timerSources[#timerSources + 1] = { duration = questData.timerDuration, startTime = questData.timerStartTime }
        end
        local barHeight = PROGRESS_BAR_HEIGHT
        for i, src in ipairs(timerSources) do
            local bar = entry.scenarioTimerBars[i]
            if bar then
                local barSpacing = (i == 1) and (spacing + timedBarTopMargin) or spacing
                bar.duration = src.duration
                bar.startTime = src.startTime
                bar:SetWidth(barW)
                bar:SetHeight(barHeight)
                bar:ClearAllPoints()
                bar:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -barSpacing)
                bar:Show()
                totalH = totalH + barSpacing + barHeight
                prevAnchor = bar
                timedFirstElementPlaced = true
            end
        end
        for i = #timerSources + 1, #(entry.scenarioTimerBars or {}) do
            local bar = entry.scenarioTimerBars[i]
            if bar then bar.duration = nil; bar.startTime = nil; bar:Hide() end
        end
        entry.wqTimerText:Hide()
        showBar = true
    else
        if entry.scenarioTimerBars then
            for _, bar in ipairs(entry.scenarioTimerBars) do
                bar.duration = nil
                bar.startTime = nil
                bar:Hide()
            end
        end

        local timerStr
        if questData.timeLeftSeconds and questData.timeLeftSeconds > 0 then
            timerStr = addon.FormatTimeRemaining(questData.timeLeftSeconds)
        elseif questData.timeLeft and questData.timeLeft > 0 then
            timerStr = addon.FormatTimeRemainingFromMinutes(questData.timeLeft)
        end

        local showTimer
        if isScenarioOrDelve then
            showTimer = (timerStr ~= nil)
            showBar = addon.GetDB("cinematicScenarioBar", true) or questData.isAbundanceScenario
        elseif isWorld and not hasStructuredTimer then
            -- Legacy WORLD quest timer (no structured timer data)
            showTimer = addon.GetDB("showWorldQuestTimer", true) and (timerStr ~= nil)
            showBar = addon.GetDB("showWorldQuestProgressBar", true)
        else
            showTimer = (timerStr ~= nil)
            showBar = true
        end

        if showTimerBars and showTimer and timerStr and not skipTimerBarDisplay then
            local timerSpacing = (isScenarioOrDelve or isGenericTimed) and (spacing + timedBarTopMargin) or spacing
            entry.wqTimerText:SetText(timerStr)
            entry.wqTimerText:SetWidth(barW)
            entry.wqTimerText:ClearAllPoints()
            entry.wqTimerText:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -timerSpacing)
            local remaining, duration
            if questData.timerDuration and questData.timerStartTime then
                remaining = math.max(0, questData.timerDuration - (GetTime() - questData.timerStartTime))
                duration = questData.timerDuration
            elseif questData.objectives then
                for _, o in ipairs(questData.objectives) do
                    if o.timerDuration and o.timerStartTime then
                        remaining = math.max(0, o.timerDuration - (GetTime() - o.timerStartTime))
                        duration = o.timerDuration
                        break
                    end
                end
            end
            if not remaining and (questData.timeLeftSeconds or questData.timeLeft) then
                remaining = questData.timeLeftSeconds or (questData.timeLeft and questData.timeLeft * 60) or 0
                duration = nil
            end
            remaining = remaining or 0
            local cat = questData.category or "DEFAULT"
            local useTimerColor = addon.GetDB("timerColorByRemaining", true)
            local r, g, b = addon.GetTimerTextColor(remaining, duration, cat, useTimerColor)
            local wr, wg, wb, wa = addon.GetDimmedTrackerTextColor(r, g, b, questData.isSuperTracked, questData)
            entry.wqTimerText:SetTextColor(wr, wg, wb, wa)
            entry.wqTimerText:Show()
            local th = entry.wqTimerText:GetStringHeight()
            if not th or th < 1 then th = addon.OBJ_SIZE + 2 end
            totalH = totalH + timerSpacing + th
            prevAnchor = entry.wqTimerText
            if isScenarioOrDelve or isGenericTimed then timedFirstElementPlaced = true end
        else
            entry.wqTimerText:Hide()
        end
    end

    -- Percent progress bar: find the first unfinished objective with percent that has numRequired > 1.
    -- Skip objectives where numRequired <= 1 (single kills/loots don't need a bar).
    -- Also skip if the objective progress bar system already handles this entry (avoid duplicates).
    -- Abundance: prefer the "abundance held" or "abundance bag" objective when present.
    local progressBarTypeFilter = addon.GetDB("progressBarTypeFilter", "percent_only")
    local firstPercent
    local selectedObj
    local hasObjProgressBar = questData._progressBarActive
    local showObjProgressBar = IsProgressBarEnabled(questData)
    if (showObjProgressBar or questData.isAbundanceScenario) and not hasObjProgressBar then
        for _, o in ipairs(questData.objectives or {}) do
            if o.percent ~= nil and not o.finished then
                local nr = o.numRequired
                if nr ~= nil and type(nr) == "number" and nr > 1 then
                    local isPercentOnly = (progressBarTypeFilter == "percent_only")
                    local intrinsic = IsIntrinsicallyPercentBased(o)
                    local hasArithmetic = (o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numRequired) == "number" and o.numRequired > 1)
                    if isPercentOnly and hasArithmetic and not intrinsic then
                        -- Skip: X/Y objective when percent_only
                    elseif questData.isAbundanceScenario and (isAbundanceHeld(o.text) or isAbundanceBag(o.text)) then
                        selectedObj = o
                        firstPercent = o.percent
                        break
                    elseif not selectedObj then
                        selectedObj = o
                        firstPercent = o.percent
                    end
                end
            end
        end
    end
    local isAbundanceBagSel = questData.isAbundanceScenario and selectedObj
    local isAbundanceBar = questData.isAbundanceScenario and selectedObj
    if showBar and firstPercent ~= nil and (isAbundanceBar or progressBarTypeFilter == "both" or progressBarTypeFilter == "percent_only") then
        local barHeight = (isScenarioOrDelve or isGenericTimed) and PROGRESS_BAR_HEIGHT or barH
        local percentBarSpacing = spacing + ((isScenarioOrDelve or isGenericTimed) and not timedFirstElementPlaced and timedBarTopMargin or 0)
        entry.wqProgressBg:SetHeight(barHeight)
        entry.wqProgressBg:SetWidth(barW)
        entry.wqProgressBg:ClearAllPoints()
        entry.wqProgressBg:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -percentBarSpacing)
        entry.wqProgressBg:SetColorTexture(0.15, 0.15, 0.18, 0.7)
        entry.wqProgressBg:Show()
        if entry.wqProgressLabel then entry.wqProgressLabel:Hide() end
        local pct = firstPercent and math.min(100, math.max(0, firstPercent)) or 0
        entry.wqProgressFill:SetHeight(barHeight)
        entry.wqProgressFill:SetWidth(math.max(2, barW * pct / 100))
        entry.wqProgressFill:ClearAllPoints()
        entry.wqProgressFill:SetPoint("TOPLEFT", entry.wqProgressBg, "TOPLEFT", 0, 0)
        -- Use consistent fill color for all bar types.
        local fillColor = progFillColor
        if not fillColor then
            if addon.GetDB("progressBarUseCategoryColor", true) then
                local colorCat = questData.category or "DEFAULT"
                fillColor = (addon.GetQuestColor and addon.GetQuestColor(colorCat)) or (addon.QUEST_COLORS and addon.QUEST_COLORS[colorCat]) or { 0.40, 0.65, 0.90 }
            else
                fillColor = addon.GetDB("progressBarFillColor", nil)
                if not fillColor or type(fillColor) ~= "table" then fillColor = { 0.40, 0.65, 0.90 } end
            end
        end
        -- Abundance: turn bar green when full.
        local isFull = (pct and pct >= 100) or (selectedObj and selectedObj.numFulfilled and selectedObj.numRequired
            and type(selectedObj.numFulfilled) == "number" and type(selectedObj.numRequired) == "number"
            and selectedObj.numFulfilled >= selectedObj.numRequired)
        if isAbundanceBar and isFull then
            fillColor = addon.OBJ_DONE_COLOR or { 0.30, 0.80, 0.30 }
        end
        addon.ApplyProgressBarFillTexture(entry.wqProgressFill, fillColor[1], fillColor[2], fillColor[3], fillColor[4] or 0.85)
        entry.wqProgressFill:Show()
        local barLabel
        local isAbundanceHeldSel = questData.isAbundanceScenario and selectedObj and isAbundanceHeld(selectedObj.text)
        local hasXy = selectedObj and selectedObj.numFulfilled ~= nil and selectedObj.numRequired ~= nil and type(selectedObj.numFulfilled) == "number" and type(selectedObj.numRequired) == "number"
        local useXyFormat = progressBarTypeFilter ~= "percent_only" and hasXy
        if isAbundanceBar and hasXy then
            -- Abundance: always show X/Y and % together.
            local nf = math.min(selectedObj.numFulfilled, selectedObj.numRequired)
            barLabel = ("%d/%d"):format(nf, selectedObj.numRequired)
            if firstPercent ~= nil then
                barLabel = barLabel .. " (" .. tostring(firstPercent) .. "%)"
            end
            if isAbundanceBagSel then barLabel = (addon.L and addon.L["UI_ABUNDANCE_BAG"] or "Abundance Bag") .. ": " .. barLabel end
            if isAbundanceHeldSel then barLabel = barLabel .. " " .. (addon.L and addon.L["UI_ABUNDANCE_HELD"] or "abundance held") end
        elseif useXyFormat then
            local nf = math.min(selectedObj.numFulfilled, selectedObj.numRequired)
            barLabel = ("%d/%d"):format(nf, selectedObj.numRequired)
            if isAbundanceBagSel then barLabel = (addon.L and addon.L["UI_ABUNDANCE_BAG"] or "Abundance Bag") .. ": " .. barLabel end
            if isAbundanceHeldSel then barLabel = barLabel .. " " .. (addon.L and addon.L["UI_ABUNDANCE_HELD"] or "abundance held") end
        else
            barLabel = firstPercent ~= nil and (tostring(firstPercent) .. "%") or ""
            if isAbundanceBagSel then barLabel = (addon.L and addon.L["UI_ABUNDANCE_BAG"] or "Abundance Bag") .. ": " .. barLabel end
            if isAbundanceHeldSel then barLabel = barLabel .. " " .. (addon.L and addon.L["UI_ABUNDANCE_HELD"] or "abundance held") end
        end
        entry.wqProgressText:SetText(barLabel)
        entry.wqProgressText:ClearAllPoints()
        entry.wqProgressText:SetPoint("CENTER", entry.wqProgressBg, "CENTER", 0, 0)
        local txtColor = progTextColor
        if not txtColor then
            txtColor = addon.GetDB("progressBarTextColor", nil)
            if not txtColor or type(txtColor) ~= "table" then txtColor = { 0.95, 0.95, 0.95 } end
        end
        entry.wqProgressText:SetFontObject(addon.ProgressBarFont or addon.ObjFont)
        local pr, pg, pb, pa = addon.GetDimmedTrackerTextColor(txtColor[1], txtColor[2], txtColor[3], questData.isSuperTracked, questData)
        entry.wqProgressText:SetTextColor(pr, pg, pb, pa)
        entry.wqProgressText:SetShown(firstPercent ~= nil)
        totalH = totalH + percentBarSpacing + barHeight
    else
        entry.wqProgressBg:Hide()
        entry.wqProgressFill:Hide()
        entry.wqProgressText:Hide()
        if entry.wqProgressLabel then entry.wqProgressLabel:Hide() end
    end

    return totalH
end

local function ApplyShadowColors(entry, questData, highlightStyle, hc, ha)
    local shadowA = addon.GetDB("showTextShadow", true) and (tonumber(addon.GetDB("shadowAlpha", 0.8)) or 0.8) or 0
    local glowAlpha = math.min(1, ha + 0.4)
    if questData.isSuperTracked and highlightStyle == "glow" then
        entry.titleShadow:SetTextColor(hc[1], hc[2], hc[3], glowAlpha)
        entry.zoneShadow:SetTextColor(hc[1], hc[2], hc[3], glowAlpha)
        if entry.affixShadow then entry.affixShadow:SetTextColor(hc[1], hc[2], hc[3], glowAlpha) end
        if entry.delveLivesShadow then entry.delveLivesShadow:SetTextColor(hc[1], hc[2], hc[3], glowAlpha) end
        for j = 1, addon.MAX_OBJECTIVES do
            entry.objectives[j].shadow:SetTextColor(hc[1], hc[2], hc[3], glowAlpha)
        end
    else
        entry.titleShadow:SetTextColor(0, 0, 0, shadowA)
        entry.zoneShadow:SetTextColor(0, 0, 0, shadowA)
        if entry.affixShadow then entry.affixShadow:SetTextColor(0, 0, 0, shadowA) end
        if entry.delveLivesShadow then entry.delveLivesShadow:SetTextColor(0, 0, 0, shadowA) end
        for j = 1, addon.MAX_OBJECTIVES do
            entry.objectives[j].shadow:SetTextColor(0, 0, 0, shadowA)
        end
    end
end

local function PopulateEntry(entry, questData, groupKey)
    -- Derive percent when missing so progress bar eligibility and rendering can use it.
    if questData.objectives then
        for _, o in ipairs(questData.objectives) do
            local textPct = o.text and tonumber(o.text:match("(%d+)%%"))
            if textPct then
                o.percent = textPct
            elseif o.percent == nil and o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numFulfilled) == "number" and type(o.numRequired) == "number" and o.numRequired > 1 then
                o.percent = math.floor(100 * math.min(o.numFulfilled, o.numRequired) / o.numRequired)
            end
        end
    end

    -- Pre-compute progress bar eligibility so the title renderer can suppress (X/Y).
    questData._progressBarActive = false
    if IsProgressBarEnabled(questData) and questData.objectives then
        local progressBarTypeFilter = addon.GetDB("progressBarTypeFilter", "percent_only")
        local barCount = 0
        for _, o in ipairs(questData.objectives) do
            local textPct = o.text and tonumber(o.text:match("(%d+)%%"))
            local isProgressBarType = (o.type == "progressbar" or o.type == 8 or o.isWeighted)
            local hasArithmetic = (o.numFulfilled ~= nil and o.numRequired ~= nil and type(o.numRequired) == "number" and o.numRequired > 1)
            if o.finished then
                -- skip
            elseif hasArithmetic then
                if progressBarTypeFilter == "both" or progressBarTypeFilter == "xy_only" then
                    barCount = barCount + 1
                end
            elseif IsIntrinsicallyPercentBased(o) or (o.percent ~= nil and not hasArithmetic) then
                if progressBarTypeFilter == "both" or progressBarTypeFilter == "percent_only" then
                    barCount = barCount + 1
                end
            end
        end
        local isScenarioEntry = questData.isScenarioMain or questData.isScenarioBonus
        if isScenarioEntry and barCount > 0 then
            questData._progressBarActive = true
        elseif barCount == 1 and questData.objectives and #questData.objectives == 1 then
            questData._progressBarActive = true
        end
    end

    local hasItem = (questData.itemTexture and questData.itemLink) and true or false
    local showItemBtn = hasItem and addon.GetDB("showQuestItemButtons", false)
    local showQuestIcons = addon.GetDB("showQuestTypeIcons", false)
    local showAchievementIcons = addon.GetDB("showAchievementIcons", true)
    local showDecorIcons = addon.GetDB("showDecorIcons", true)
    local showRecipeIcons = addon.GetDB("showRecipeIcons", true)
    local hasIcon = ((questData.questTypeAtlas ~= nil) and showQuestIcons) or (questData.isAchievement and questData.achievementIcon and showQuestIcons and showAchievementIcons) or (questData.isDecor and questData.decorIcon and showQuestIcons and showDecorIcons) or (questData.isRecipe and questData.recipeIcon and showQuestIcons and showRecipeIcons)
    local isOffMapWorld = (questData.category == "WORLD") and questData.isTracked and not questData.isNearby

    local S = addon.Scaled or function(v) return v end
    local leftOffset = addon.GetContentLeftOffset and addon.GetContentLeftOffset() or S(addon.PADDING + addon.ICON_COLUMN_WIDTH)
    local textWidth = addon.GetPanelWidth() - S(addon.PADDING) - leftOffset - S(addon.CONTENT_RIGHT_PADDING or 0)
    local titleLeftOffset = 0

    -- Collect item names for Auctionator AH search (recipe entries only).
    -- Includes the crafted item itself followed by each required reagent.
    if questData.isRecipe and entry.ahBtn then
        local terms, seen = {}, {}
        -- Crafted item first (recipe title == output item name in WoW).
        if type(questData.title) == "string" and questData.title ~= "" then
            seen[questData.title] = true
            terms[#terms + 1] = questData.title
        end
        if questData.objectives then
            for _, obj in ipairs(questData.objectives) do
                if not obj.isSectionHeader and not obj.isChoiceHeader
                   and not obj.isChoiceVariant and not obj.isCraftableCount
                   and not obj.isQualityInfo and not obj.isRequirement
                   and not obj.currencyID
                   and type(obj.text) == "string" and obj.text ~= ""
                   and (obj.numRequired or 0) > 0 then
                    if not seen[obj.text] then
                        seen[obj.text] = true
                        terms[#terms + 1] = obj.text
                    end
                end
            end
        end
        entry._ahSearchTerms = terms
        entry._ahRecipeName  = questData.title
    end

    -- Right-side gutter: auto-adjusting column that holds the LFG group button
    -- and/or the quest item button.  The gutter width adapts to whichever
    -- combination is needed so everything is right-aligned.
    local S = addon.Scaled or function(v) return v end
    local showLfgBtn  = questData.isGroupQuest and entry.lfgBtn and true or false
    local lfgBtnSize  = S(addon.LFG_BTN_SIZE or 26)
    local itemBtnSize = S(addon.ITEM_BTN_SIZE or 26)
    local gutterGap   = S(addon.LFG_BTN_GAP or 4)  -- gap between text and gutter, and between buttons
    local showAhBtn   = questData.isRecipe and entry.ahBtn
                        and addon.GetDB("showAHSearchButton", true)
                        and IsAuctionatorAvailable() and IsAHOpen() and true or false
    local ahBtnSize   = S(addon.AH_BTN_SIZE or 22)
    local gutterW     = 0
    if showItemBtn and showLfgBtn then
        gutterW = itemBtnSize + gutterGap + lfgBtnSize + gutterGap
    elseif showItemBtn then
        gutterW = itemBtnSize + gutterGap
    elseif showLfgBtn then
        gutterW = lfgBtnSize + gutterGap
    end
    if showAhBtn then
        gutterW = ahBtnSize + gutterGap
    end
    if gutterW > 0 then
        textWidth = textWidth - gutterW
    end

    local titleWidth = textWidth
    local showTimerBars = addon.GetDB("showTimerBars", true)
    local timerDisplayMode = addon.GetDB("timerDisplayMode", "inline")
    local isWorld = questData.category == "WORLD" or questData.category == "CALLING"
    local isScenarioOrDelve = questData.category == "SCENARIO" or questData.category == "DELVES" or questData.category == "DUNGEON"
    local hasStructuredTimer = (questData.timerDuration and questData.timerStartTime) and true or false
    if not hasStructuredTimer and questData.objectives then
        for _, o in ipairs(questData.objectives) do
            if o.timerDuration and o.timerStartTime then hasStructuredTimer = true; break end
        end
    end
    local hasLegacyTimer = (questData.timeLeftSeconds and questData.timeLeftSeconds > 0) or (questData.timeLeft and questData.timeLeft > 0)
    local isGenericTimed = (not isScenarioOrDelve) and (hasStructuredTimer or hasLegacyTimer) and not questData.isRare
    local showInlineTimer = showTimerBars and (timerDisplayMode == "inline" or timerDisplayMode == "inline-below") and (isWorld or isScenarioOrDelve or isGenericTimed) and not questData.isRare
    if showInlineTimer then
        local timerStr, duration, startTime = GetTimerDisplayInfo(questData, isWorld, isScenarioOrDelve, isGenericTimed)
        if timerStr then
            entry._inlineTimerStr = timerStr
            entry._inlineTimerDuration = duration
            entry._inlineTimerStartTime = startTime
        else
            entry._inlineTimerBaseTitle, entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil, nil
        end
    else
        entry._inlineTimerBaseTitle, entry._inlineTimerStr, entry._inlineTimerDuration, entry._inlineTimerStartTime = nil, nil, nil, nil
    end

    -- Extra spacing between icon column and title when icons are enabled.
    -- Keep icons-off layout exactly as-is.
    -- NOTE: ApplyHighlightStyle() resets title anchors, so we apply the final title X *after* highlight styling.
    local function ApplyIconModeTitleOffset()
        local basePad = entry.__baseTitlePadPx or 0
        local extraTitlePad = 0
        if showQuestIcons then
            local highlightStyle = addon.NormalizeHighlightStyle(addon.GetDB("activeQuestHighlight", "bar-left")) or "bar-left"
            local iconW = S(addon.QUEST_TYPE_ICON_SIZE or 14)
            local iconTitleGap = S(6)
            if highlightStyle == "bar-left" or highlightStyle == "pill-left" then
                local barLeft = S(addon.BAR_LEFT_OFFSET or 12)
                local barW = math.max(2, math.min(6, tonumber(addon.GetDB("highlightBarWidth", 2)) or 2))
                local padAfterBar = 6
                local iconLeft = -barLeft + barW + padAfterBar
                extraTitlePad = math.max(0, iconLeft + iconW + iconTitleGap)
            else
                extraTitlePad = iconW + iconTitleGap
            end
        end

        -- Preserve any vertical padding already applied (e.g. bar-top highlight style)
        local _, _, _, curX, curY = entry.titleText:GetPoint(1)
        curY = (type(curY) == "number") and curY or 0
        entry.titleText:ClearAllPoints()
        entry.titleText:SetPoint("TOPLEFT", entry, "TOPLEFT", basePad + extraTitlePad, curY)
        entry.titleShadow:ClearAllPoints()
        entry.titleShadow:SetPoint("CENTER", entry.titleText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
        return extraTitlePad
    end

    -- Apply an initial offset (will be re-applied after highlight style too).
    ApplyIconModeTitleOffset()

    -- Quest type icon visibility is fully controlled by the toggle;
    -- positioning is handled in FocusLayout.
    if not showQuestIcons then
        entry.questTypeIcon:Hide()
    elseif questData.category == "DELVES" then
        entry.questTypeIcon:SetAtlas(addon.DELVE_TIER_ATLAS)
        entry.questTypeIcon:Show()
    elseif questData.isAchievement and questData.achievementIcon and showAchievementIcons then
        entry.questTypeIcon:SetTexture(questData.achievementIcon)
        entry.questTypeIcon:Show()
    elseif questData.isDecor and questData.decorIcon and showDecorIcons then
        entry.questTypeIcon:SetTexture(questData.decorIcon)
        entry.questTypeIcon:Show()
    elseif questData.isRecipe and questData.recipeIcon and showRecipeIcons then
        entry.questTypeIcon:SetTexture(questData.recipeIcon)
        entry.questTypeIcon:Show()
    elseif questData.questTypeAtlas then
        entry.questTypeIcon:SetAtlas(questData.questTypeAtlas)
        entry.questTypeIcon:Show()
    else
        -- Toggle on but no icon data: hide.
        entry.questTypeIcon:Hide()
    end

    -- Quest icon button: show only for quest entries with visible icon in Classic mode.
    if entry.questIconBtn then
        if entry.questID and entry.questTypeIcon:IsShown() and addon.GetDB("useClassicClickBehaviour", false) then
            entry.questIconBtn:Show()
        else
            entry.questIconBtn:Hide()
        end
    end

    if entry.trackedFromOtherZoneIcon then
        entry.trackedFromOtherZoneIcon:Hide()
    end

    -- Delve main row: reserve right strip for lives (hearts) on the same line as name + tier.
    local delveLivesActive = false
    local delveLivesStr = ""
    local delveLivesReserve = 0
    local titleLineWidth = titleWidth
    if entry.delveLivesText and addon.FormatDelveLivesHeartsForTitle
        and questData.category == "DELVES" and questData.isScenarioMain
        and type(questData.delveLivesRemaining) == "number" and questData.delveLivesRemaining > 0 then
        delveLivesActive = true
        delveLivesStr = addon.FormatDelveLivesHeartsForTitle(questData.delveLivesRemaining, questData.delveLivesIconFileID)
        entry.delveLivesText:SetFontObject(addon.TitleFont)
        entry.delveLivesText:SetText(delveLivesStr)
        delveLivesReserve = (entry.delveLivesText:GetStringWidth() or 0) + S(6)
        titleLineWidth = math.max(1, titleWidth - delveLivesReserve)
    else
        if entry.delveLivesText then
            entry.delveLivesText:Hide()
            if entry.delveLivesShadow then entry.delveLivesShadow:Hide() end
        end
    end

    entry.titleText:SetWidth(titleLineWidth)
    entry.titleShadow:SetWidth(titleLineWidth)

    local displayTitle = questData.title
    if not questData._progressBarActive and (addon.GetDB("showCompletedCount", false) or questData.isAchievement or questData.isEndeavor) then
        local done, total
        if questData.numericQuantity ~= nil and questData.numericRequired and type(questData.numericRequired) == "number" and questData.numericRequired > 1 then
            done, total = questData.numericQuantity, questData.numericRequired
        elseif questData.criteriaDone and questData.criteriaTotal and type(questData.criteriaDone) == "number" and type(questData.criteriaTotal) == "number" and questData.criteriaTotal > 0 then
            done, total = questData.criteriaDone, questData.criteriaTotal
        elseif questData.objectivesDoneCount and questData.objectivesTotalCount then
            done, total = questData.objectivesDoneCount, questData.objectivesTotalCount
        elseif questData.objectives and #questData.objectives > 0 then
            done, total = 0, #questData.objectives
            for _, o in ipairs(questData.objectives) do if o.finished then done = done + 1 end end
        end
        if done and total then
            displayTitle = ("%s (%d/%d)"):format(displayTitle, done, total)
        end
    end

    -- Entry numbering (per category): apply when option is on.
    if addon.GetDB("showCategoryEntryNumbers", true) and questData.categoryIndex and type(questData.categoryIndex) == "number" then
        displayTitle = ("%d. %s"):format(questData.categoryIndex, displayTitle)
    end

    -- Tier in title
    if questData.category == "DELVES" and type(questData.delveTier) == "number" then
        displayTitle = displayTitle .. (" - Tier %d"):format(questData.delveTier)
    end
    local showInZoneSuffix = addon.GetDB("showInZoneSuffix", true)
    if showInZoneSuffix then
        local needSuffix = false
        if questData.category == "WORLD" then
            needSuffix = (questData.isAutoAdded == true) and (questData.isSuperTracked ~= true)
         elseif questData.category == "WEEKLY" or questData.category == "DAILY" then
             needSuffix = (questData.isAccepted == false)
         end
        if needSuffix then
            local iconKey = addon.GetDB("autoTrackIcon", "radar1")
            local iconPath = addon.GetRadarIconPath and addon.GetRadarIconPath(iconKey) or ("Interface\\AddOns\\HorizonSuite\\media\\" .. iconKey .. ".blp")
            displayTitle = displayTitle .. " |T" .. iconPath .. ":0|t"
        end
    end
    displayTitle = addon.ApplyTextCase(displayTitle, "questTitleCase", "proper")
    if addon.GetDB("showQuestLevel", false) and questData.level then
        displayTitle = ("%s [%d]"):format(displayTitle, questData.level)
    end
    entry.titleText:SetText(displayTitle)
    entry.titleShadow:SetText(displayTitle)

    if delveLivesActive and entry.delveLivesText then
        entry.delveLivesText:SetText(delveLivesStr)
        if entry.delveLivesShadow then entry.delveLivesShadow:SetText(delveLivesStr) end
        entry.delveLivesText:ClearAllPoints()
        entry.delveLivesText:SetPoint("TOPLEFT", entry.titleText, "TOPRIGHT", S(4), 0)
        entry.delveLivesText:Show()
        if entry.delveLivesShadow then
            entry.delveLivesShadow:ClearAllPoints()
            entry.delveLivesShadow:SetPoint("CENTER", entry.delveLivesText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)
            entry.delveLivesShadow:Show()
        end
    end

    if entry._inlineTimerStr then
        entry._inlineTimerBaseTitle = displayTitle
        if entry.inlineTimerText then
            entry.inlineTimerText:SetFontObject(addon.TitleFont)
            entry.inlineTimerText:ClearAllPoints()
            entry.inlineTimerText:SetText(" (" .. entry._inlineTimerStr .. ")")
            local timerStrWidth = entry.inlineTimerText:GetStringWidth() or 0
            local tw = titleWidth or textWidth
            -- When timer doesn't fit beside title (or user chose inline-below), put it on its own line with full width
            local titleToContentSpacing = ((questData.category == "DELVES" or questData.category == "DUNGEON") and S(addon.DELVE_OBJ_SPACING)) or addon.GetTitleToContentSpacing()
            local preferTimerBelow = (timerDisplayMode == "inline-below")
            if delveLivesActive and entry.delveLivesText then
                local hw = entry.delveLivesText:GetStringWidth() or 0
                local sameLineStartX = titleLineWidth + S(4) + hw + S(2)
                local remainingWidth = math.max(1, tw - sameLineStartX)
                if preferTimerBelow or remainingWidth < timerStrWidth then
                    entry.inlineTimerText:SetWidth(tw)
                    entry.inlineTimerText:SetPoint("TOPLEFT", entry.titleText, "BOTTOMLEFT", 0, -titleToContentSpacing)
                    entry._inlineTimerOnOwnLine = true
                else
                    entry.inlineTimerText:SetWidth(remainingWidth)
                    entry.inlineTimerText:SetPoint("LEFT", entry.titleText, "LEFT", sameLineStartX, 0)
                    entry._inlineTimerOnOwnLine = false
                end
            else
                local titlePixelWidth = entry.titleText:GetStringWidth() or 0
                local titleAnchorX = math.min(titlePixelWidth, titleLineWidth)
                local remainingWidth = math.max(1, tw - titleAnchorX - 2)
                if preferTimerBelow or remainingWidth < timerStrWidth then
                    entry.inlineTimerText:SetWidth(tw)
                    entry.inlineTimerText:SetPoint("TOPLEFT", entry.titleText, "BOTTOMLEFT", 0, -titleToContentSpacing)
                    entry._inlineTimerOnOwnLine = true
                else
                    entry.inlineTimerText:SetWidth(remainingWidth)
                    entry.inlineTimerText:SetPoint("LEFT", entry.titleText, "LEFT", titleAnchorX + 2, 0)
                    entry._inlineTimerOnOwnLine = false
                end
            end
            local remaining = entry._inlineTimerDuration and entry._inlineTimerStartTime and math.max(0, entry._inlineTimerDuration - (GetTime() - entry._inlineTimerStartTime)) or 0
            local cat = questData.category or groupKey or "DEFAULT"
            local useTimerColor = addon.GetDB("timerColorByRemaining", true)
            local r, g, b = addon.GetTimerTextColor(remaining, entry._inlineTimerDuration, cat, useTimerColor)
            local tr, tg, tb, ta = addon.GetDimmedTrackerTextColor(r, g, b, questData.isSuperTracked, questData)
            entry.inlineTimerText:SetTextColor(tr, tg, tb, ta)
            entry.inlineTimerText:Show()
        end
    elseif entry.inlineTimerText then
        entry.inlineTimerText:Hide()
        entry._inlineTimerOnOwnLine = nil
    end

    local effectiveCat = (addon.GetEffectiveColorCategory and addon.GetEffectiveColorCategory(questData.category, groupKey, questData.baseCategory, questData.isEventQuest)) or questData.category
    local c = (addon.GetTitleColor and addon.GetTitleColor(effectiveCat)) or questData.color
    if not c or type(c) ~= "table" or not c[1] or not c[2] or not c[3] then
        c = addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT or { 0.9, 0.9, 0.9 }
    end
    if questData.isDungeonQuest and not questData.isTracked then
        local df = addon.DUNGEON_UNTRACKED_DIM or 0.65
        c = { c[1] * df, c[2] * df, c[3] * df }
    elseif addon.ShouldApplySuperTrackQuestDim(questData) then
        c = addon.ApplyDimColor(c)
    end
    if questData.isRecipe and addon.GetDB("recipeRarityColors", false) and questData.outputQuality then
        local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[questData.outputQuality]
        if qc then c = { qc.r, qc.g, qc.b } end
    end
    local dimAlpha = addon.ShouldApplySuperTrackQuestDim(questData) and addon.GetDimAlpha() or 1
    local baseColor = { c[1], c[2], c[3], dimAlpha }
    entry._baseTitleColor = baseColor
    if not entry.hoverAnimState then
        entry.titleText:SetTextColor(c[1], c[2], c[3], dimAlpha)
        if delveLivesActive and entry.delveLivesText and entry.delveLivesText:IsShown() then
            entry.delveLivesText:SetTextColor(c[1], c[2], c[3], dimAlpha)
        end
        entry._savedColor = nil
        if entry:IsMouseOver() then
            entry._savedColor = { c[1], c[2], c[3] }
            entry.titleText:SetTextColor(
                math.min(c[1] * 1.25, 1),
                math.min(c[2] * 1.25, 1),
                math.min(c[3] * 1.25, 1), 1)
            if delveLivesActive and entry.delveLivesText and entry.delveLivesText:IsShown() then
                entry.delveLivesText:SetTextColor(
                    math.min(c[1] * 1.25, 1),
                    math.min(c[2] * 1.25, 1),
                    math.min(c[3] * 1.25, 1), 1)
            end
        end
    end

    local highlightStyle, hc, ha, barW, topPadding, bottomPadding = ApplyHighlightStyle(entry, questData)

    -- Re-apply icon-mode title offset because ApplyHighlightStyle resets the anchor.
    ApplyIconModeTitleOffset()

    -- Right-side gutter: position item button and/or LFG button.
    -- Both are anchored from the entry's TOPRIGHT, right-aligned.
    -- Layout (right to left): [entry TOPRIGHT] [LFG btn] [gap] [item btn] [gap] [text]
    -- When only one is present, it sits at the rightmost position.
    if showItemBtn then
        entry.itemLink = questData.itemLink
        entry.itemBtn.icon:SetTexture(questData.itemTexture)
        entry.itemBtn:SetSize(itemBtnSize, itemBtnSize)
        entry.itemBtn:ClearAllPoints()
        if showLfgBtn then
            entry.itemBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -(lfgBtnSize + gutterGap), 2)
        else
            entry.itemBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 2)
        end
        entry.itemBtn:Show()
        addon.ApplyItemCooldown(entry.itemBtn.cooldown, questData.itemLink)
    else
        entry.itemLink = nil
        entry.itemBtn:Hide()
    end
    entry:SetHitRectInsets(0, 0, 0, 0)

    if showLfgBtn then
        entry.lfgBtn:ClearAllPoints()
        entry.lfgBtn:SetSize(lfgBtnSize, lfgBtnSize)
        -- LFG button is always the rightmost element in the gutter.
        entry.lfgBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 3)
        entry.lfgBtn:Show()
    elseif entry.lfgBtn then
        entry.lfgBtn:Hide()
    end

    if showAhBtn then
        entry.ahBtn:ClearAllPoints()
        entry.ahBtn:SetSize(ahBtnSize, ahBtnSize)
        entry.ahBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 2)
        entry.ahBtn:Show()
    elseif entry.ahBtn then
        entry.ahBtn:Hide()
    end

    local titleToContentSpacing = ((questData.category == "DELVES" or questData.category == "DUNGEON") and S(addon.DELVE_OBJ_SPACING)) or addon.GetTitleToContentSpacing()
    local titleH = entry.titleText:GetStringHeight()
    if not titleH or titleH < 1 then titleH = addon.TITLE_SIZE + 4 end
    local effectiveTitleRowH = titleH
    if delveLivesActive and entry.delveLivesText and entry.delveLivesText:IsShown() then
        local dh = entry.delveLivesText:GetStringHeight() or 0
        if dh > 0 then effectiveTitleRowH = math.max(effectiveTitleRowH, dh) end
    end
    if entry._inlineTimerStr and entry.inlineTimerText and entry.inlineTimerText:IsShown() then
        local timerH = entry.inlineTimerText:GetStringHeight() or 0
        if timerH > 0 then
            if entry._inlineTimerOnOwnLine then
                effectiveTitleRowH = titleH + titleToContentSpacing + timerH
            else
                effectiveTitleRowH = math.max(effectiveTitleRowH, timerH)
            end
        end
    end
    local totalH = effectiveTitleRowH

    local prevAnchor = entry.titleText
    -- Cache the font-scaled "two spaces" width (measured from the title font) once per entry render.
    local twoSpacesPx = addon.focus and addon.focus.layout and addon.focus.layout.twoSpacesPx
    local titleIndentPx = addon.focus and addon.focus.layout and addon.focus.layout.titleIndentPx
    local showZoneLabels = addon.GetDB("showZoneLabels", true)
    local playerZone = addon.GetPlayerCurrentZoneName and addon.GetPlayerCurrentZoneName() or nil
    local inCurrentZone = questData.isNearby or (questData.zoneName and playerZone and questData.zoneName:lower() == playerZone:lower())
    -- Prey activities: "Activity" is a semantic label, not a zone—always show it even when in-zone
    local isActivityLabel = questData.zoneName and ((questData.zoneName == "Activity") or (addon.L and addon.L["OPTIONS_FOCUS_ACTIVITY"] and questData.zoneName == addon.L["OPTIONS_FOCUS_ACTIVITY"]))
    local shouldShowZone = showZoneLabels and questData.zoneName and (not inCurrentZone or isActivityLabel)
    local shouldShowScenarioStage = questData.stageName and (questData.category == "SCENARIO" or questData.isScenarioMain)
        and (questData.title ~= questData.stageName)
    if shouldShowZone then
        local zoneLabel = questData.zoneName
        if isOffMapWorld then
            zoneLabel = ("[Off-map] %s"):format(zoneLabel)
        end
        entry.zoneText:SetText(zoneLabel)
        entry.zoneShadow:SetText(zoneLabel)
        local zoneColor = (addon.GetZoneColor and addon.GetZoneColor(effectiveCat)) or addon.ZONE_COLOR
        if addon.ShouldApplySuperTrackQuestDim(questData) then
            zoneColor = addon.ApplyDimColor(zoneColor)
        end
        entry.zoneText:SetTextColor(zoneColor[1], zoneColor[2], zoneColor[3], dimAlpha)
        entry.zoneText:ClearAllPoints()
        entry.zoneText:SetPoint("TOPLEFT", entry.titleText, "TOPLEFT", 0, -effectiveTitleRowH - titleToContentSpacing)
        entry.zoneText:Show()
        entry.zoneShadow:Show()
        local zoneH = entry.zoneText:GetStringHeight()
        if not zoneH or zoneH < 1 then zoneH = addon.ZONE_SIZE + 2 end
        totalH = totalH + titleToContentSpacing + zoneH
        prevAnchor = entry.zoneText
    elseif shouldShowScenarioStage then
        local stageLabel = questData.stageName
        if questData.stageIndex and questData.stageIndex > 0 then
            local stageFmt = (addon.L and addon.L["UI_STAGE_X_X"]) or "Stage %d: %s"
            stageLabel = stageFmt:format(questData.stageIndex, questData.stageName)
        end
        entry.zoneText:SetText(stageLabel)
        entry.zoneShadow:SetText(stageLabel)
        local stageColor = (addon.GetScenarioStageColor and addon.GetScenarioStageColor()) or addon.ZONE_COLOR or { 0.55, 0.65, 0.75 }
        if addon.ShouldApplySuperTrackQuestDim(questData) then
            stageColor = addon.ApplyDimColor(stageColor)
        end
        entry.zoneText:SetTextColor(stageColor[1], stageColor[2], stageColor[3], dimAlpha)
        entry.zoneText:ClearAllPoints()
        entry.zoneText:SetPoint("TOPLEFT", entry.titleText, "TOPLEFT", 0, -effectiveTitleRowH - titleToContentSpacing)
        entry.zoneText:Show()
        entry.zoneShadow:Show()
        local stageH = entry.zoneText:GetStringHeight()
        if not stageH or stageH < 1 then stageH = addon.ZONE_SIZE + 2 end
        totalH = totalH + titleToContentSpacing + stageH
        prevAnchor = entry.zoneText
    else
        entry.zoneText:Hide()
        entry.zoneShadow:Hide()
    end

    -- Delve affixes: show on first Delve entry or scenario main.
    local showAffixesInEntry = questData.category == "DELVES"
        and (questData.categoryIndex == 1 or questData.isScenarioMain)
        and addon.GetDB("showDelveAffixes", true)
        and addon.GetDelvesAffixes
    local affixStr = ""
    if showAffixesInEntry and addon.GetDelvesAffixes then
        local affixes, tierSpellID = addon.GetDelvesAffixes()
        entry.tierSpellID = tierSpellID
        if affixes and #affixes > 0 then
            local parts = {}
            for _, a in ipairs(affixes) do
                if a.name and a.name ~= "" then parts[#parts + 1] = a.name end
            end
            if #parts > 0 then
                affixStr = table.concat(parts, "  ·  ")
                entry.affixData = affixes
            end
        end
    end
    if affixStr ~= "" and entry.affixText then
        local rawFont = addon.GetDB("fontPath", (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF")
        local fontPath = (addon.ResolveFontPath and addon.ResolveFontPath(rawFont)) or rawFont
        local fontOutline = addon.GetDB("fontOutline", "OUTLINE")
        local affixSize = S(math.max(10, math.min(16, tonumber(addon.GetDB("mplusAffixSize", 12)) or 12)))
        entry.affixText:SetWidth(textWidth)
        entry.affixText:SetFont(fontPath, affixSize, fontOutline)
        entry.affixText:SetText(affixStr)
        entry.affixText:SetTextColor(0.78, 0.85, 0.88, 1)
        entry.affixText:ClearAllPoints()
        if prevAnchor == entry.titleText then
            entry.affixText:SetPoint("TOPLEFT", entry.titleText, "TOPLEFT", 0, -effectiveTitleRowH - titleToContentSpacing)
        else
            entry.affixText:SetPoint("TOPLEFT", prevAnchor, "BOTTOMLEFT", 0, -titleToContentSpacing)
        end
        entry.affixText:Show()
        if entry.affixShadow then
            entry.affixShadow:SetWidth(textWidth)
            entry.affixShadow:Show()
        end
        local affixH = entry.affixText:GetStringHeight()
        if not affixH or affixH < 1 then affixH = addon.ZONE_SIZE + 2 end
        totalH = totalH + titleToContentSpacing + affixH
        prevAnchor = entry.affixText
    else
        entry.affixText:Hide()
        entry.affixShadow:Hide()
        entry.affixData = nil
    end

    totalH, prevAnchor = ApplyObjectives(entry, questData, textWidth, prevAnchor, totalH, c, effectiveCat, effectiveTitleRowH, titleToContentSpacing)
    totalH = ApplyScenarioOrWQTimerBar(entry, questData, textWidth, prevAnchor or entry.titleText, totalH)

    entry.entryHeight = totalH + topPadding + bottomPadding
    entry:SetHeight(totalH + topPadding + bottomPadding)

    ApplyShadowColors(entry, questData, highlightStyle, hc, ha)

    local trackBarW = (highlightStyle == "pill-left") and barW or S(2)
    if (highlightStyle == "bar-left" or highlightStyle == "bar-right" or highlightStyle == "pill-left") and entry.trackBar:IsShown() then
        entry.trackBar:ClearAllPoints()
        if highlightStyle == "bar-left" or highlightStyle == "pill-left" then
            local barLeft = S(addon.BAR_LEFT_OFFSET or 12)
            entry.trackBar:SetPoint("TOPLEFT", entry, "TOPLEFT", -barLeft, 0)
            entry.trackBar:SetPoint("BOTTOMRIGHT", entry, "BOTTOMLEFT", -barLeft + trackBarW, 0)
        else
            local barInsetRight = S(addon.ICON_COLUMN_WIDTH) - S(addon.PADDING) + S(4)
            entry.trackBar:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -barInsetRight, 0)
            entry.trackBar:SetPoint("BOTTOMLEFT", entry, "BOTTOMRIGHT", -barInsetRight - trackBarW, 0)
        end
    end

    entry.baseCategory = questData.baseCategory
    entry.isEventQuest = questData.isEventQuest and true or false
    entry.isComplete = questData.isComplete and true or false
    entry.isSuperTracked = questData.isSuperTracked and true or false
    entry.isDungeonQuest = questData.isDungeonQuest and true or false
    entry.isGroupQuest = questData.isGroupQuest and true or false
    entry.isAutoComplete = questData.isAutoComplete and true or false

    if questData.isRare then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.isRare     = true
        entry.creatureID = questData.creatureID
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = nil
        entry.itemLink   = nil
        entry.isTracked  = nil
        entry.title      = questData.title
        entry.vignetteGUID  = questData.vignetteGUID
        entry.vignetteMapID = questData.vignetteMapID
        entry.vignetteX     = questData.vignetteX
        entry.vignetteY     = questData.vignetteY
    elseif questData.isRareLoot or questData.category == "RARE_LOOT" then
        entry.questID       = nil
        entry.entryKey      = questData.entryKey
        entry.category      = questData.category
        entry.isRareLoot    = true
        entry.creatureID    = nil
        entry.achievementID = nil
        entry.endeavorID    = nil
        entry.decorID       = nil
        entry.itemLink      = nil
        entry.isTracked     = nil
        entry.title         = questData.title
        entry.zoneName      = questData.zoneName
        entry.questTypeAtlas = questData.questTypeAtlas
        entry.vignetteGUID  = questData.vignetteGUID
        entry.vignetteID    = questData.vignetteID
        entry.vignetteMapID = questData.vignetteMapID
        entry.vignetteX     = questData.vignetteX
        entry.vignetteY     = questData.vignetteY
    elseif questData.isAchievement or questData.category == "ACHIEVEMENT" then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = questData.achievementID
        entry.endeavorID = nil
        entry.isTracked  = true
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    elseif questData.isEndeavor or questData.category == "ENDEAVOR" then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = questData.endeavorID
        entry.decorID    = nil
        entry.isTracked  = true
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    elseif questData.isDecor or questData.category == "DECOR" then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = questData.decorID
        entry.adventureGuideID   = nil
        entry.adventureGuideType = nil
        entry.isTracked  = true
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    elseif questData.isRecipe or questData.category == "RECIPE" then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = nil
        entry.recipeID   = questData.recipeID
        entry.recipeIsRecraft = questData.recipeIsRecraft == true
        entry.isRecipe   = true
        entry.outputQuality = questData.outputQuality
        entry.isTracked  = true
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    elseif questData.isAdventureGuide or questData.category == "ADVENTURE" then
        entry.questID    = nil
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = nil
        entry.adventureGuideID   = questData.adventureGuideID
        entry.adventureGuideType = questData.adventureGuideType
        entry.isTracked  = true
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    elseif questData.isScenarioMain or questData.isScenarioBonus then
        entry.questID    = questData.questID
        entry.entryKey   = questData.entryKey
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = nil
        entry.isTracked  = questData.isTracked
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    else
        entry.questID    = questData.questID
        entry.entryKey   = nil
        entry.category   = questData.category
        entry.creatureID = nil
        entry.achievementID = nil
        entry.endeavorID = nil
        entry.decorID    = nil
        entry.isTracked  = questData.isTracked
        entry.vignetteGUID = nil; entry.vignetteMapID = nil; entry.vignetteX = nil; entry.vignetteY = nil; entry.title = nil
    end
    addon.ApplyDimToTrackerEntryIcons(entry, questData.isSuperTracked, questData)
    return totalH
end

addon.PopulateEntry = PopulateEntry
