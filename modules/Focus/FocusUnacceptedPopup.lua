--[[
    Horizon Suite - Focus - Unaccepted Quests Popup
    Standalone test popup listing all best-effort unaccepted quests in current zone.
    Shows type (Daily, Weekly, Recurring, Repeatable, Other) for each.
    APIs: C_QuestLine, C_QuestLog, C_Map, C_QuestInfoSystem, C_TaskQuest.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local PADDING = 12
local ROW_HEIGHT = 22
local POPUP_WIDTH = 900
local POPUP_HEIGHT = 600
local QUEST_FREQ_DAILY = (Enum and Enum.QuestFrequency and Enum.QuestFrequency.Daily) or 1
local QUEST_FREQ_WEEKLY = (Enum and Enum.QuestFrequency and Enum.QuestFrequency.Weekly) or 2
local BG_COLOR = { 0.09, 0.09, 0.11, 0.96 }
local BORDER_COLOR = { 0.3, 0.3, 0.35 }
local MAP_OPEN_DELAY = 0.25
local LOAD_RESULT_DEBOUNCE = 0.3
local SCROLL_DELTA = 24

-- ---------------------------------------------------------------------------
-- Query: collect unaccepted daily/weekly candidates for current zone
-- ---------------------------------------------------------------------------

--- Build mapIDsToCheck for strict current-map mode.
local function GetMapIDsToCheck()
    if not C_Map or not C_Map.GetBestMapForUnit then return nil end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    return { mapID }
end

--- Returns true if the quest is not currently accepted (not in log).
local function IsQuestUnaccepted(questID)
    if not questID or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if logIndex then return false end
    end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        if C_QuestLog.IsOnQuest(questID) then return false end
    end
    return true
end

--- Build map context for a quest from map-focused APIs.
local function BuildQuestMapContext(questID, currentMapID, questLineInfo)
    local context = {
        lineInfo = questLineInfo,
        sourceMapID = currentMapID,
        poiMapID = nil,
        zoneMapID = nil,
        tagInfo = nil,
    }

    -- pcall: GetQuestLineInfo can throw on invalid questID or mapID.
    if (not context.lineInfo) and C_QuestLine and C_QuestLine.GetQuestLineInfo then
        local ok, info = pcall(C_QuestLine.GetQuestLineInfo, questID, currentMapID, true)
        if ok and info then
            context.lineInfo = info
        end
    end

    -- pcall: GetQuestZoneID can throw on invalid questID.
    if C_TaskQuest and C_TaskQuest.GetQuestZoneID then
        local ok, zoneMapID = pcall(C_TaskQuest.GetQuestZoneID, questID)
        if ok then
            context.zoneMapID = zoneMapID
        end
    end

    -- pcall: GetQuestTagInfo can throw on invalid questID.
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok then
            context.tagInfo = tagInfo
        end
    end

    return context
end

--- True only when we can explicitly resolve the quest to the current map.
local function IsQuestStrictlyOnCurrentMap(context, currentMapID)
    if not context or not currentMapID then return false end

    if context.poiMapID and context.poiMapID == currentMapID then
        return true, "poiMap"
    end
    if context.zoneMapID and context.zoneMapID == currentMapID then
        return true, "zoneMap"
    end
    if context.lineInfo and context.lineInfo.startMapID and context.lineInfo.startMapID == currentMapID then
        return true, "startMap"
    end

    -- Strict mode: if we cannot prove current-map match, discard.
    return false, "noExplicitCurrentMapMatch"
end

--- Classify as Daily, Weekly, Recurring, or nil (other).
--- Note: QuestPOIMapInfo and QuestLineInfo expose isDaily only, not isWeekly. Weekly detection
--- relies on RequestLoadQuestByID + GetQuestClassification(Recurring) after QUEST_DATA_LOAD_RESULT.
local function ClassifyAsDailyWeekly(questID, context)
    local questLineInfo = context and context.lineInfo or nil
    if questLineInfo and questLineInfo.isDaily then
        return "Daily", "high"
    end
    if context and context.poiIsDaily then
        return "Daily", "high"
    end

    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        local qc = C_QuestInfoSystem.GetQuestClassification(questID)
        if qc == Enum.QuestClassification.Recurring then
            return "Recurring", "high"
        end
    end

    if addon.GetQuestFrequency and addon.GetQuestFrequency(questID) ~= nil then
        local freq = addon.GetQuestFrequency(questID)
        if freq == QUEST_FREQ_WEEKLY or (LE_QUEST_FREQUENCY_WEEKLY and freq == LE_QUEST_FREQUENCY_WEEKLY) then
            return "Weekly", "high"
        end
        if freq == QUEST_FREQ_DAILY or (LE_QUEST_FREQUENCY_DAILY and freq == LE_QUEST_FREQUENCY_DAILY) then
            return "Daily", "high"
        end
    end

    if C_QuestLog and C_QuestLog.IsRepeatableQuest then
        if C_QuestLog.IsRepeatableQuest(questID) then
            return "Repeatable", "best-effort"
        end
    end

    return nil, nil
end

--- Resolve popup category using existing Focus category language.
local function ResolvePopupCategory(questID, typeStr, context)
    -- pcall: GetQuestBaseCategory can throw on invalid questID.
    if addon.GetQuestBaseCategory then
        local ok, base = pcall(addon.GetQuestBaseCategory, questID)
        if ok and base and base ~= "DEFAULT" and base ~= "COMPLETE" then
            return base
        end
    end

    if typeStr == "Daily" then return "DAILY" end
    if typeStr == "Weekly" or typeStr == "Recurring" or typeStr == "Repeatable" then return "WEEKLY" end

    if context and context.lineInfo then
        if context.lineInfo.isCampaign then return "CAMPAIGN" end
        if context.lineInfo.isImportant then return "IMPORTANT" end
        if context.lineInfo.isLegendary then return "LEGENDARY" end
    end

    return "DEFAULT"
end

--- Read unaccepted daily/weekly quests for current zone (best-effort).
--- @return table rows Array of { questID, title, typeStr, source, confidence }
--- @return number mapID Current player map
--- @return string zoneName Zone name for header
local function ReadUnacceptedZoneDailiesWeeklies()
    local rows = {}
    local mapID = nil
    local zoneName = "Unknown"

    if not C_Map or not C_Map.GetBestMapForUnit then
        return rows, 0, zoneName
    end
    mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return rows, 0, zoneName
    end

    local mapInfo = (C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)) or nil
    if mapInfo and mapInfo.name then
        zoneName = mapInfo.name
    end

    local mapIDsToCheck = GetMapIDsToCheck()
    if not mapIDsToCheck then
        return rows, mapID, zoneName
    end

    local candidateSet = {} -- questID -> { source, questLineInfo }
    local seen = {}

    -- 1. C_QuestLine.GetAvailableQuestLines (only unaccepted: not inProgress)
    -- pcall: RequestQuestLinesForMap can throw on invalid mapID.
    if C_QuestLine and C_QuestLine.RequestQuestLinesForMap then
        for _, checkMapID in ipairs(mapIDsToCheck) do
            pcall(C_QuestLine.RequestQuestLinesForMap, checkMapID)
        end
    end
    -- pcall: GetAvailableQuestLines can throw on invalid mapID.
    if C_QuestLine and C_QuestLine.GetAvailableQuestLines then
        for _, checkMapID in ipairs(mapIDsToCheck) do
            local ok, questLines = pcall(C_QuestLine.GetAvailableQuestLines, checkMapID)
            if ok and questLines and type(questLines) == "table" then
                for _, lineInfo in ipairs(questLines) do
                    if lineInfo and lineInfo.questID and not lineInfo.inProgress then
                        local qid = lineInfo.questID
                        if not seen[qid] then
                            seen[qid] = true
                            candidateSet[qid] = {
                                source = "QuestLine",
                                questLineInfo = lineInfo,
                                poiMapID = lineInfo.startMapID,
                                childDepth = lineInfo.childDepth,
                                isDaily = lineInfo.isDaily,
                                isMeta = lineInfo.isMeta,
                                questTagType = nil,
                            }
                        end
                    end
                end
            end
        end
    end

    -- 2. C_QuestLog.GetQuestsOnMap
    if C_QuestLog and C_QuestLog.GetQuestsOnMap then
        for _, checkMapID in ipairs(mapIDsToCheck) do
            local onMap = C_QuestLog.GetQuestsOnMap(checkMapID)
            if onMap then
                for _, info in ipairs(onMap) do
                    if info and info.questID then
                        local qid = info.questID
                        if not seen[qid] then
                            seen[qid] = true
                            candidateSet[qid] = {
                                source = "MapPOI",
                                questLineInfo = nil,
                                poiMapID = info.mapID or checkMapID,
                                childDepth = info.childDepth,
                                isDaily = info.isDaily,
                                isMeta = info.isMeta,
                                questTagType = info.questTagType,
                            }
                        end
                    end
                end
            end
        end
    end

    -- 3. C_TaskQuest.GetQuestsOnMap (task POIs)
    -- pcall: GetQuestsOnMap can throw on invalid mapID.
    if C_TaskQuest and C_TaskQuest.GetQuestsOnMap then
        for _, checkMapID in ipairs(mapIDsToCheck) do
            local ok, taskPOIs = pcall(C_TaskQuest.GetQuestsOnMap, checkMapID)
            if ok and taskPOIs and type(taskPOIs) == "table" then
                for _, info in ipairs(taskPOIs) do
                    if info and info.questID then
                        local qid = info.questID
                        if not seen[qid] then
                            seen[qid] = true
                            candidateSet[qid] = {
                                source = "TaskPOI",
                                questLineInfo = nil,
                                poiMapID = info.mapID or checkMapID,
                                childDepth = info.childDepth,
                                isDaily = info.isDaily,
                                isMeta = info.isMeta,
                                questTagType = info.questTagType,
                            }
                        end
                    end
                end
            end
        end
    end

    -- Filter: only unaccepted, exclude world quests and callings.
    local st = addon.focus and addon.focus.unacceptedPopup
    for questID, meta in pairs(candidateSet) do
        if not IsQuestUnaccepted(questID) then candidateSet[questID] = nil
        elseif addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then candidateSet[questID] = nil
        elseif C_QuestLog and C_QuestLog.IsQuestCalling and C_QuestLog.IsQuestCalling(questID) then candidateSet[questID] = nil
        end
    end

    -- Request quest data load so GetQuestClassification returns correct values for unaccepted quests.
    -- Only on first open (dataRequestedThisSession prevents re-request on event-triggered refreshes).
    if st and not st.dataRequestedThisSession and C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        for qid, _ in pairs(candidateSet) do
            C_QuestLog.RequestLoadQuestByID(qid)
        end
        st.dataRequestedThisSession = true
    end

    -- Classify and build rows (all unaccepted quests; show type for each).
    for questID, meta in pairs(candidateSet) do
        local context = BuildQuestMapContext(questID, mapID, meta.questLineInfo)
        context.poiMapID = meta.poiMapID
        context.poiIsDaily = meta.isDaily
        context.poiIsMeta = meta.isMeta
        context.poiQuestTagType = meta.questTagType
        local isOnCurrentMap, mapReason = IsQuestStrictlyOnCurrentMap(context, mapID)
        if isOnCurrentMap then
            local typeStr, confidence = ClassifyAsDailyWeekly(questID, context)
            local title = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)) or ("Quest " .. tostring(questID))
            if context.lineInfo and context.lineInfo.questName and #context.lineInfo.questName > 0 then
                title = context.lineInfo.questName
            end
            local tagStr = ""
            local parts = {}
            parts[#parts + 1] = ("poiDaily=%s poiMeta=%s poiTagType=%s"):format(
                tostring(context.poiIsDaily),
                tostring(context.poiIsMeta),
                tostring(context.poiQuestTagType)
            )
            if context.tagInfo then
                local tt = context.tagInfo.questTagType or context.tagInfo.tagType
                local tn = context.tagInfo.tagName
                parts[#parts + 1] = ("tagType=%s tagName=%s"):format(tostring(tt), tostring(tn or "nil"))
            end
            local questType = (C_QuestLog and C_QuestLog.GetQuestType) and C_QuestLog.GetQuestType(questID)
            parts[#parts + 1] = ("questType=%s"):format(tostring(questType))
            tagStr = table.concat(parts, " | ")
            rows[#rows + 1] = {
                questID = questID,
                title = title,
                typeStr = typeStr or "Other",
                category = ResolvePopupCategory(questID, typeStr, context),
                source = meta.source,
                confidence = confidence or "best-effort",
                mapHint = mapReason
                    .. ":poi=" .. tostring(context.poiMapID)
                    .. ",zone=" .. tostring(context.zoneMapID)
                    .. ",start=" .. tostring(context.lineInfo and context.lineInfo.startMapID or nil),
                tagHint = tagStr,
            }
        end
    end

    table.sort(rows, function(a, b) return (a.title or "") < (b.title or "") end)
    return rows, mapID, zoneName
end

-- ---------------------------------------------------------------------------
-- Event frame: auto-refresh when map/quest data changes (only while popup visible)
-- ---------------------------------------------------------------------------

local REFRESH_EVENTS = {
    "WORLD_MAP_OPEN",
    "QUEST_POI_UPDATE",
    "ZONE_CHANGED_NEW_AREA",
    "QUESTLINE_UPDATE",
    "QUEST_DATA_LOAD_RESULT",
}

local eventFrame

local function CreateEventFrame()
    if eventFrame then return end
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function(_, event)
        if not popupFrame or not popupFrame:IsShown() then return end
        if event == "WORLD_MAP_OPEN" and C_Timer and C_Timer.After then
            C_Timer.After(MAP_OPEN_DELAY, function()
                if popupFrame and popupFrame:IsShown() and addon.ShowUnacceptedPopup then
                    addon.ShowUnacceptedPopup()
                end
            end)
        elseif event == "QUEST_DATA_LOAD_RESULT" and C_Timer and C_Timer.After then
            local st = addon.focus and addon.focus.unacceptedPopup
            if st then
                st.loadResultDebounceGen = st.loadResultDebounceGen + 1
            end
            local myGen = st and st.loadResultDebounceGen or 0
            C_Timer.After(LOAD_RESULT_DEBOUNCE, function()
                if not st or myGen ~= st.loadResultDebounceGen then return end
                if not popupFrame or not popupFrame:IsShown() then return end
                if addon.ShowUnacceptedPopup then addon.ShowUnacceptedPopup() end
            end)
        else
            if addon.ShowUnacceptedPopup then addon.ShowUnacceptedPopup() end
        end
    end)
    eventFrame = f
end

local function RegisterRefreshEvents()
    CreateEventFrame()
    if not eventFrame then return end
    for _, ev in ipairs(REFRESH_EVENTS) do
        eventFrame:RegisterEvent(ev)
    end
end

local function UnregisterRefreshEvents()
    if not eventFrame then return end
    for _, ev in ipairs(REFRESH_EVENTS) do
        eventFrame:UnregisterEvent(ev)
    end
end

-- ---------------------------------------------------------------------------
-- Popup frame
-- ---------------------------------------------------------------------------

local popupFrame
local contentFrame
local scrollFrame

local function CreatePopupFrame()
    if popupFrame then return end

    local panel = CreateFrame("Frame", "HorizonSuiteUnacceptedPopup", UIParent)
    panel:SetSize(POPUP_WIDTH, POPUP_HEIGHT)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:Hide()

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(panel)
    bg:SetColorTexture(BG_COLOR[1], BG_COLOR[2], BG_COLOR[3], BG_COLOR[4])
    if addon.CreateBorder then addon.CreateBorder(panel, BORDER_COLOR) end

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(36)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        panel:StartMoving()
    end)
    titleBar:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        panel:StopMovingOrSizing()
    end)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    titleText:SetTextColor(0.9, 0.9, 0.9, 1)
    titleText:SetPoint("TOPLEFT", titleBar, "TOPLEFT", PADDING, -PADDING)
    panel.titleText = titleText

    local closeBtn = CreateFrame("Button", nil, panel)
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
    closeBtn:SetFrameLevel(titleBar:GetFrameLevel() + 2)
    local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY")
    closeLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    closeLabel:SetText("X")
    closeLabel:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeBtn:SetScript("OnClick", function()
        if addon.HideUnacceptedPopup then addon.HideUnacceptedPopup() else panel:Hide() end
    end)

    -- Refresh button (higher frame level so clicks reach it over title bar)
    local refreshBtn = CreateFrame("Button", nil, panel)
    refreshBtn:SetSize(72, 26)
    refreshBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -6, 0)
    refreshBtn:SetFrameLevel(titleBar:GetFrameLevel() + 2)
    refreshBtn:EnableMouse(true)
    local refreshLabel = refreshBtn:CreateFontString(nil, "OVERLAY")
    refreshLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    refreshLabel:SetText(addon.L["PRESENCE_REFRESH"])
    refreshLabel:SetPoint("CENTER", refreshBtn, "CENTER", 0, 0)
    refreshBtn:SetScript("OnClick", function()
        addon.ShowUnacceptedPopup()
    end)

    -- Scroll + content
    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING, -(36 + PADDING))
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PADDING - 16, PADDING + 24)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        local cur = scroll:GetVerticalScroll()
        local childH = scroll:GetScrollChild() and scroll:GetScrollChild():GetHeight() or 0
        local frameH = scroll:GetHeight() or 0
        scroll:SetVerticalScroll(math.max(0, math.min(cur - delta * SCROLL_DELTA, math.max(0, childH - frameH))))
    end)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
    content:SetHeight(1)
    scroll:SetScrollChild(content)

    -- Footer
    local footer = panel:CreateFontString(nil, "OVERLAY")
    footer:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    footer:SetTextColor(0.55, 0.55, 0.6, 1)
    footer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PADDING, PADDING)
    footer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PADDING, PADDING)
    footer:SetJustifyH("LEFT")
    footer:SetWordWrap(true)
    footer:SetText(addon.L["PRESENCE_BEST_EFFORT_UNACCEPTED_QUESTS_EXPO"])
    panel.footerText = footer

    popupFrame = panel
    scrollFrame = scroll
    contentFrame = content
end

local lineWidgets = {}

local function PopulatePopup(rows, mapID, zoneName)
    if not popupFrame or not contentFrame then return end

    local count = #rows
    popupFrame.titleText:SetText((addon.L["PRESENCE_UNACCEPTED_QUESTS_X_MAP_X"]):format(zoneName, tostring(mapID), count))

    local contentWidth = (scrollFrame and scrollFrame:GetWidth() and scrollFrame:GetWidth() > 0)
        and scrollFrame:GetWidth()
        or (POPUP_WIDTH - (PADDING * 2) - 20)
    contentFrame:SetWidth(contentWidth)

    -- Clear existing rows
    for _, line in ipairs(lineWidgets) do
        if line and line.SetParent then line:SetParent(nil) end
    end
    lineWidgets = {}

    -- Reuse tracker grouping so popup sections match Horizon tracker language.
    local grouped = nil
    if addon.SortAndGroupQuests then
        local entries = {}
        for _, row in ipairs(rows) do
            entries[#entries + 1] = {
                questID = row.questID,
                title = row.title,
                category = row.category or "DEFAULT",
                isNearby = true,
                isAccepted = false,
                isTracked = false,
                typeStr = row.typeStr,
                source = row.source,
                confidence = row.confidence,
                mapHint = row.mapHint,
                tagHint = row.tagHint,
            }
        end
        grouped = addon.SortAndGroupQuests(entries)
    end
    if not grouped then
        grouped = { { key = "AVAILABLE", quests = rows } }
    end

    local y = 0
    local function addLine(text, size, r, g, b, a, wrap)
        local line = contentFrame:CreateFontString(nil, "OVERLAY")
        line:SetFont("Fonts\\FRIZQT__.TTF", size or 11, "OUTLINE")
        line:SetTextColor(r or 0.85, g or 0.85, b or 0.9, a or 1)
        line:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -y)
        line:SetWidth(contentWidth)
        line:SetJustifyH("LEFT")
        line:SetWordWrap(wrap or false)
        line:SetText(text or "")
        line:Show()
        lineWidgets[#lineWidgets + 1] = line
        local h = (wrap and line.GetStringHeight and line:GetStringHeight()) or ROW_HEIGHT
        y = y + math.max(ROW_HEIGHT, h)
    end

    for _, grp in ipairs(grouped) do
        addLine(("-- %s --"):format(tostring(grp.key or "GROUP")), 11, 1, 0.82, 0.35, 1, false)
        for _, row in ipairs(grp.quests or {}) do
            local debugCol = row.mapHint or "map=?"
            if row.tagHint and row.tagHint ~= "" then
                debugCol = debugCol .. " | " .. (row.tagHint or "")
            end
            local text = ("[%s|%s] %s |cff888888(#%s %s %s)|r"):format(
                row.category or "?",
                row.typeStr or "?",
                row.title or "?",
                tostring(row.questID),
                (row.source or "?") .. " " .. (row.confidence or "?"),
                debugCol
            )
            addLine(text, 11, 0.85, 0.85, 0.9, 1, true)
        end
    end

    contentFrame:SetHeight(math.max(1, y))
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

--- Show the unaccepted daily/weekly popup (refresh data and display).
local function ShowUnacceptedPopup()
    CreatePopupFrame()
    local rows, mapID, zoneName = ReadUnacceptedZoneDailiesWeeklies()
    PopulatePopup(rows, mapID, zoneName)
    popupFrame:ClearAllPoints()
    popupFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    popupFrame:Show()
    RegisterRefreshEvents()
end

--- Hide the unaccepted popup.
--- @return nil
local function HideUnacceptedPopup()
    local st = addon.focus and addon.focus.unacceptedPopup
    if st then st.dataRequestedThisSession = false end
    UnregisterRefreshEvents()
    if popupFrame then popupFrame:Hide() end
end

addon.ShowUnacceptedPopup          = ShowUnacceptedPopup
addon.HideUnacceptedPopup          = HideUnacceptedPopup
addon.ReadUnacceptedZoneDailiesWeeklies = ReadUnacceptedZoneDailiesWeeklies
