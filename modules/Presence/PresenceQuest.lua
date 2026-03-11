--[[
    Horizon Suite - Presence - Quest Events
    Quest accept, turn-in, removal, objective updates, and UI_INFO_MESSAGE handling.
    APIs: C_QuestLog, C_SuperTrack, C_Timer.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local DbgWQ = function() end

-- ============================================================================
-- Constants
-- ============================================================================

local UPDATE_BUFFER_TIME = 0.35      -- Time to wait for data to settle (fix for 55/100 vs 71/100)
local ZERO_PROGRESS_RETRY_TIME = 0.45 -- Re-sample when we get 0/X (meta quests like "0/8 WQs" may lag)
local CACHE_MATCH_RETRY_TIME = 0.4   -- Re-sample when cache matches from QUEST_WATCH_UPDATE
local UI_MSG_THROTTLE = 1.0

-- ============================================================================
-- Quest text detection
-- ============================================================================

--- Returns true if the quest title is a Blizzard DNT (Do Not Translate) internal quest.
--- @param questName string|nil Quest title from C_QuestLog.GetTitleForQuestID
--- @return boolean
local function IsDNTQuest(questName)
    return questName and questName:find("%[DNT%]")
end

--- Build locale-safe keywords for quest text detection at load time.
local questTextKeywords = { "slain", "destroyed", "Quest Accepted", "Complete" }
local questAcceptedKeywords = { "Quest Accepted", "Accepted" }
do
    local globalSources = {
        "QUEST_COMPLETE",
        "ERR_QUEST_OBJECTIVE_COMPLETE_S",
        "QUEST_WATCH_QUEST_READY",
        "OBJECTIVE_COMPLETE",
        "ERR_QUEST_UNKNOWN_COMPLETE",
        "QUEST_WATCH_QUEST_COMPLETE",
    }
    for _, gName in ipairs(globalSources) do
        local gs = _G[gName]
        if gs and type(gs) == "string" then
            local clean = gs:gsub("%%[%d$]*[sd]", ""):gsub("%s+", " ")
            clean = strtrim(clean)
            if clean ~= "" and #clean > 2 then
                questTextKeywords[#questTextKeywords + 1] = clean
            end
        end
    end

    local acceptSources = {
        "ERR_QUEST_ACCEPTED_S",
        "ERR_QUEST_ADD_FOUND_SII",
    }
    for _, gName in ipairs(acceptSources) do
        local gs = _G[gName]
        if gs and type(gs) == "string" then
            local clean = gs:gsub("%%[%d$]*[sd]", ""):gsub("[:]", ""):gsub("%s+", " ")
            clean = strtrim(clean)
            if clean ~= "" and #clean > 2 then
                questAcceptedKeywords[#questAcceptedKeywords + 1] = clean
            end
        end
    end

    local L = addon.L or {}
    if L["QUEST COMPLETE"] and type(L["QUEST COMPLETE"]) == "string" then
        local clean = strtrim(L["QUEST COMPLETE"])
        if clean ~= "" and #clean > 2 then
            questTextKeywords[#questTextKeywords + 1] = clean
        end
    end
    if L["QUEST ACCEPTED"] and type(L["QUEST ACCEPTED"]) == "string" then
        local clean = strtrim(L["QUEST ACCEPTED"])
        if clean ~= "" and #clean > 2 then
            questTextKeywords[#questTextKeywords + 1] = clean
            questAcceptedKeywords[#questAcceptedKeywords + 1] = clean
        end
    end
end

--- Returns true if the message looks like quest objective progress.
--- @param msg string|nil Message text to check
--- @return boolean
local function IsQuestText(msg)
    if not msg then return false end
    if msg:find("%d+/%d+") or msg:find("%%") then return true end
    for _, kw in ipairs(questTextKeywords) do
        if msg:find(kw, 1, true) then return true end
    end
    return false
end

--- Normalize quest update text to "X/Y Objective" format.
--- Strips leading "x/1 " for single-step objectives only.
--- @param s string Raw text (e.g. "Burn Deepsflayer Nests: 3/6", "Objective (3/5)")
--- @return string
local function NormalizeQuestUpdateText(s)
    if not s or s == "" then return s or "" end
    s = strtrim(s)
    local result
    if s:match("^%d+/%d+%s") then
        result = s
    else
        local text, x, y = s:match("^(.+):%s*(%d+)/(%d+)$")
        if text and x and y then
            result = ("%s/%s %s"):format(x, y, strtrim(text))
        else
            local text2, x2, y2 = s:match("^(.+)%s*%((%d+)/(%d+)%)$")
            if text2 and x2 and y2 then
                result = ("%s/%s %s"):format(x2, y2, strtrim(text2))
            else
                result = s
            end
        end
    end
    if result and result:match("^%d+/1[%s:]+") then
        result = result:gsub("^%d+/1[%s:]+%s*", "")
    end
    return result
end

-- ============================================================================
-- Quest state
-- ============================================================================

local lastQuestObjectivesCache = {}
local lastQuestObjectivesState = {}
local pendingQuestUpdateIDs = {}
local cacheMatchRetryPending = {}
local recentlyDisposed = {}
local pendingNonBlind = {}

local lastUIInfoMsg, lastUIInfoTime = nil, 0
local pendingStandaloneTimer = nil

--- Remove cached quest state for a quest that is no longer relevant.
--- @param questID number
local function DisposeQuestState(questID)
    if not questID then return end
    lastQuestObjectivesCache[questID] = nil
    lastQuestObjectivesState[questID] = nil
    recentlyDisposed[questID] = GetTime()
    pendingNonBlind[questID] = nil
    pendingQuestUpdateIDs[questID] = nil
    cacheMatchRetryPending[questID] = nil
    if addon.Presence and addon.Presence.CancelDebounced then
        addon.Presence.CancelDebounced("quest:" .. questID)
    end
end

-- ============================================================================
-- Quest update logic
-- ============================================================================

local function FormatObjective(o)
    return (addon.Presence and addon.Presence.FormatObjectiveForDisplay and addon.Presence.FormatObjectiveForDisplay(o)) or (o and o.text) or ""
end

local function Strip(s)
    return (addon.Presence and addon.Presence.StripMarkup) and addon.Presence.StripMarkup(s) or (s or "")
end

--- Process debounced quest objective update; shows QUEST_UPDATE or skips if unchanged/blind.
--- @param questID number
--- @param isBlindUpdate boolean
--- @param source string|nil Event name for debug
--- @param isRetry boolean|nil True when this is a deferred re-sample after 0/X
--- @param isCacheMatchRetry boolean|nil True when this is a re-sample after cache match
local function ExecuteQuestUpdate(questID, isBlindUpdate, source, isRetry, isCacheMatchRetry)
    pendingQuestUpdateIDs[questID] = nil
    if not questID or questID <= 0 then return end

    local disposedAt = recentlyDisposed[questID]
    if disposedAt and (GetTime() - disposedAt) < 2.0 then return end

    if C_QuestLog and C_QuestLog.IsOnQuest and not C_QuestLog.IsOnQuest(questID) then return end

    local objectives = (C_QuestLog and C_QuestLog.GetQuestObjectives) and (C_QuestLog.GetQuestObjectives(questID) or {}) or {}
    if #objectives == 0 then return end

    local parts = {}
    local state = {}
    for i = 1, #objectives do
        local o = objectives[i]
        local text = (o and o.text) or ""
        local finished = (o and o.finished) and true or false
        local nf = (o and type(o.numFulfilled) == "number") and o.numFulfilled or nil
        local nr = (o and type(o.numRequired) == "number") and o.numRequired or nil
        parts[i] = text .. "|" .. (finished and "1" or "0") .. "|" .. (nf or "") .. "|" .. (nr or "")
        state[i] = { text = text, finished = finished, numFulfilled = nf, numRequired = nr }
    end
    local objKey = table.concat(parts, ";")
    local oldState = lastQuestObjectivesState[questID]

    if lastQuestObjectivesCache[questID] == objKey then
        DbgWQ("ExecuteQuestUpdate SKIP cache match: questID=", questID, "source=", tostring(source))
        if not isCacheMatchRetry and source == "QUEST_WATCH_UPDATE" and not cacheMatchRetryPending[questID] then
            cacheMatchRetryPending[questID] = true
            local function retryFn()
                cacheMatchRetryPending[questID] = nil
                ExecuteQuestUpdate(questID, isBlindUpdate, source, nil, true)
            end
            if addon.Presence and addon.Presence.RequestDebounced then
                addon.Presence.RequestDebounced("quest:" .. questID, CACHE_MATCH_RETRY_TIME, retryFn)
            end
        end
        return
    end

    local isNew = (lastQuestObjectivesCache[questID] == nil)
    lastQuestObjectivesCache[questID] = objKey
    lastQuestObjectivesState[questID] = state

    if isBlindUpdate and isNew then
        return
    end

    local msg = nil

    if oldState and type(oldState) == "table" then
        local maxCount = math.max(#oldState, #state)
        for i = 1, maxCount do
            local oldO = oldState[i]
            local newO = state[i]
            if newO then
                local changed = (not oldO) or oldO.text ~= newO.text or oldO.finished ~= newO.finished or oldO.numFulfilled ~= newO.numFulfilled
                if changed and newO.text ~= "" then
                    msg = FormatObjective(newO)
                    break
                end
            end
        end
    end

    if not msg and isNew then
        for i = 1, #state do
            local o = state[i]
            if o and o.text ~= "" and o.finished then
                msg = FormatObjective(o)
                break
            end
        end
    end

    if not msg then
        for i = 1, #state do
            local o = state[i]
            if o and o.text ~= "" and not o.finished then
                msg = FormatObjective(o)
                break
            end
        end
    end

    if not msg and #state > 0 then
        local o = state[1]
        if o and o.text ~= "" then
            msg = FormatObjective(o)
        end
    end

    if not msg or msg == "" then msg = "Objective updated" end

    local stripped = Strip(msg)
    local normalized = NormalizeQuestUpdateText(stripped)

    if not isRetry and not isNew and source == "QUEST_WATCH_UPDATE" and normalized and normalized:match("^0/%d+") then
        lastQuestObjectivesCache[questID] = nil
        lastQuestObjectivesState[questID] = nil
        local function retryFn()
            ExecuteQuestUpdate(questID, isBlindUpdate, source, true, nil)
        end
        if addon.Presence and addon.Presence.RequestDebounced then
            addon.Presence.RequestDebounced("quest:" .. questID, ZERO_PROGRESS_RETRY_TIME, retryFn)
        end
        return
    end

    if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceQuestUpdate", "presenceQuestEvents", true)) then return end
    if addon.Presence and addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType() then return end
    local L = addon.L or {}
    local questName = (C_QuestLog and C_QuestLog.GetTitleForQuestID) and Strip(C_QuestLog.GetTitleForQuestID(questID) or "") or ""
    if IsDNTQuest(questName) then return end
    local title = (questName ~= "" and questName) or L["QUEST UPDATE"]
    DbgWQ("ExecuteQuestUpdate: QueueOrPlay", questID, "title=", title, "sub=", normalized, "source=", source, "isNew=", isNew, "isBlind=", isBlindUpdate)

    lastUIInfoMsg = msg
    lastUIInfoTime = GetTime()

    addon.Presence.QueueOrPlay("QUEST_UPDATE", title, normalized, { questID = questID, source = source })
end

--- Entry point for requesting an update. Resets the timer to ensure we only process the *final* state.
--- @param questID number
--- @param isBlindUpdate boolean
--- @param source string|nil Event name for debug
local function RequestQuestUpdate(questID, isBlindUpdate, source)
    if not questID then return end

    if not isBlindUpdate then
        pendingNonBlind[questID] = true
    end
    local effectiveBlind = isBlindUpdate and not pendingNonBlind[questID]

    local function fireQuestUpdate()
        pendingQuestUpdateIDs[questID] = nil
        pendingNonBlind[questID] = nil
        ExecuteQuestUpdate(questID, effectiveBlind, source, nil, nil)
    end
    pendingQuestUpdateIDs[questID] = true
    if addon.Presence and addon.Presence.RequestDebounced then
        addon.Presence.RequestDebounced("quest:" .. questID, UPDATE_BUFFER_TIME, fireQuestUpdate)
    end
end

-- ============================================================================
-- Quest ID resolution
-- ============================================================================

--- Guess active quest ID for blind QUEST_LOG_UPDATE/UI_INFO_MESSAGE.
local function GetWorldQuestIDForObjectiveUpdate()
    local super = (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) and C_SuperTrack.GetSuperTrackedQuestID() or 0
    if super and super > 0 then
        if not (C_QuestLog and C_QuestLog.IsComplete and C_QuestLog.IsComplete(super)) then
            return super
        end
    end
    if addon.ReadTrackedQuests then
        local candidates = {}
        for _, q in ipairs(addon.ReadTrackedQuests()) do
            if q.questID and (q.category == "WORLD" or q.category == "CALLING") and not q.isComplete and q.isNearby then
                candidates[#candidates + 1] = q.questID
            end
        end
        if #candidates > 0 then return candidates[1] end
    end
    if C_QuestLog and C_QuestLog.GetNumQuestWatches and C_QuestLog.GetQuestIDForQuestWatchIndex then
        local numWatches = C_QuestLog.GetNumQuestWatches()
        for i = 1, numWatches do
            local qid = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if qid and qid > 0 and not (C_QuestLog.IsComplete and C_QuestLog.IsComplete(qid)) then
                return qid
            end
        end
    end
    return nil
end

--- Resolve quest ID by matching normalized objective text against quest log.
--- @param normalizedObjectiveText string Normalized "X/Y Objective" format
--- @return number|nil questID if a matching quest is found
local function GetQuestIDFromObjectiveText(normalizedObjectiveText)
    if not normalizedObjectiveText or normalizedObjectiveText == "" then return nil end
    if not C_QuestLog or not C_QuestLog.GetQuestObjectives then return nil end

    local function objectivesMatch(questID)
        local objectives = C_QuestLog.GetQuestObjectives(questID) or {}
        for _, o in ipairs(objectives) do
            local text = (o and o.text) and Strip(o.text) or ""
            if text ~= "" then
                local norm = NormalizeQuestUpdateText(text)
                if norm == normalizedObjectiveText then return true end
            end
        end
        return false
    end

    local super = (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) and C_SuperTrack.GetSuperTrackedQuestID() or 0
    if super and super > 0 and not (C_QuestLog.IsComplete and C_QuestLog.IsComplete(super)) and objectivesMatch(super) then
        return super
    end

    if C_QuestLog.GetNumQuestWatches and C_QuestLog.GetQuestIDForQuestWatchIndex then
        local numWatches = C_QuestLog.GetNumQuestWatches()
        for i = 1, numWatches do
            local qid = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if qid and qid > 0 and objectivesMatch(qid) then return qid end
        end
    end

    if C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo and C_QuestLog.IsOnQuest then
        local numEntries = select(1, C_QuestLog.GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and info and not info.isHeader and info.questID and C_QuestLog.IsOnQuest(info.questID) and objectivesMatch(info.questID) then
                return info.questID
            end
        end
    end
    return nil
end

-- ============================================================================
-- Event handlers (public entry points)
-- ============================================================================

--- Handle QUEST_ACCEPTED. Shows quest accept notification.
--- @param questID number
local function Quest_OnQuestAccepted(questID)
    if addon.Presence and addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType() then return end
    if questID and C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo then
        local logIdx = C_QuestLog.GetLogIndexForQuestID(questID)
        if logIdx then
            local ok, info = pcall(C_QuestLog.GetInfo, logIdx)
            if ok and info and info.isHidden then return end
        end
    end
    local opts = (questID and { questID = questID }) or {}
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local questName = Strip(C_QuestLog.GetTitleForQuestID(questID) or "New Quest")
        if IsDNTQuest(questName) then return end
        if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
            if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceWorldQuestAccept", "presenceQuestEvents", true)) then return end
            local L = addon.L or {}
            addon.Presence.QueueOrPlay("WORLD_QUEST_ACCEPT", L["WORLD QUEST ACCEPTED"], questName, opts)
        else
            if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceQuestAccept", "presenceQuestEvents", true)) then return end
            local L = addon.L or {}
            addon.Presence.QueueOrPlay("QUEST_ACCEPT", L["QUEST ACCEPTED"], questName, opts)
        end
    else
        if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceQuestAccept", "presenceQuestEvents", true)) then return end
        local L = addon.L or {}
        addon.Presence.QueueOrPlay("QUEST_ACCEPT", L["QUEST ACCEPTED"], L["New Quest"], opts)
    end
end

--- Handle QUEST_TURNED_IN. Shows quest complete notification.
--- @param questID number
local function Quest_OnQuestTurnedIn(questID)
    if addon.Presence and addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType() then return end
    local L = addon.L or {}
    local opts = (questID and { questID = questID }) or {}
    local questName = "Objective"
    if C_QuestLog then
        if C_QuestLog.GetTitleForQuestID then
            questName = Strip(C_QuestLog.GetTitleForQuestID(questID) or questName)
        end
        if IsDNTQuest(questName) then return end
        if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
            if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true)) then return end
            addon.Presence.QueueOrPlay("WORLD_QUEST", L["WORLD QUEST"], questName, opts)
            DisposeQuestState(questID)
            return
        end
    end
    if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceQuestComplete", "presenceQuestEvents", true)) then return end
    addon.Presence.QueueOrPlay("QUEST_COMPLETE", L["QUEST COMPLETE"] or "QUEST COMPLETE", questName, opts)
    DisposeQuestState(questID)
end

--- Handle QUEST_REMOVED. Disposes cached quest state.
--- @param questID number
local function Quest_OnQuestRemoved(questID)
    DisposeQuestState(questID)
end

--- Handle QUEST_WATCH_UPDATE. Requests debounced quest objective update.
--- @param questID number
local function Quest_OnQuestWatchUpdate(questID)
    DbgWQ("EVENT: QUEST_WATCH_UPDATE", questID)
    RequestQuestUpdate(questID, false, "QUEST_WATCH_UPDATE")
end

--- Handle QUEST_LOG_UPDATE. Blind scan for active quest; requests debounced update.
local function Quest_OnQuestLogUpdate()
    if addon.Presence._suppressQuestUpdateOnReload then return end

    local questID = GetWorldQuestIDForObjectiveUpdate()
    DbgWQ("EVENT: QUEST_LOG_UPDATE", "questID=", questID or "nil")
    if questID then
        RequestQuestUpdate(questID, true, "QUEST_LOG_UPDATE")
    end
end

--- Handle UI_INFO_MESSAGE. Maps quest progress messages to quests; shows standalone popup when unmapped.
--- @param msgType number
--- @param msg string
local function Quest_OnUIInfoMessage(msgType, msg)
    if not msg then return end

    local function IsAcceptMsg(s)
        for _, kw in ipairs(questAcceptedKeywords) do
            if s:find(kw, 1, true) then return true end
        end
        return false
    end

    if not IsQuestText(msg) or IsAcceptMsg(msg) then return end

    local plain = strtrim(msg):gsub("[%.%!%?]$", "")
    local objComplete  = _G["OBJECTIVE_COMPLETE"] and _G["OBJECTIVE_COMPLETE"]:gsub("[%.%!%?]$", "")
    local questComplete = _G["QUEST_COMPLETE"]    and _G["QUEST_COMPLETE"]:gsub("[%.%!%?]$", "")
    local readyTurnIn  = _G["QUEST_WATCH_QUEST_READY"] and _G["QUEST_WATCH_QUEST_READY"]:gsub("[%.%!%?]$", "")
    local unknownComplete = _G["ERR_QUEST_UNKNOWN_COMPLETE"] and _G["ERR_QUEST_UNKNOWN_COMPLETE"]:gsub("[%.%!%?]$", "")
    local watchComplete   = _G["QUEST_WATCH_QUEST_COMPLETE"] and _G["QUEST_WATCH_QUEST_COMPLETE"]:gsub("[%.%!%?]$", "")
    local popupComplete   = _G["QUEST_WATCH_POPUP_QUEST_COMPLETE"] and _G["QUEST_WATCH_POPUP_QUEST_COMPLETE"]:gsub("[%.%!%?]$", "")

    if (objComplete and plain == objComplete)
        or (questComplete and plain == questComplete)
        or (readyTurnIn and plain == readyTurnIn)
        or (unknownComplete and plain == unknownComplete)
        or (watchComplete and plain == watchComplete)
        or (popupComplete and plain == popupComplete) then
        return
    end

    local stripped = Strip(msg or "")
    local normalized = NormalizeQuestUpdateText(stripped)

    local questID = GetWorldQuestIDForObjectiveUpdate()
    if not questID and normalized ~= "" then
        questID = GetQuestIDFromObjectiveText(normalized)
    end

    if questID then
        RequestQuestUpdate(questID, true, "UI_INFO_MESSAGE")
    else
        if not (addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled("presenceQuestUpdate", "presenceQuestEvents", true)) then return end
        if addon.Presence and addon.Presence.ShouldSuppressType and addon.Presence.ShouldSuppressType() then return end

        local now = GetTime()
        if lastUIInfoMsg == msg and (now - lastUIInfoTime) < UI_MSG_THROTTLE then return end
        lastUIInfoMsg, lastUIInfoTime = msg, now

        if pendingStandaloneTimer then
            pendingStandaloneTimer:Cancel()
            pendingStandaloneTimer = nil
        end

        pendingStandaloneTimer = C_Timer.After(UPDATE_BUFFER_TIME, function()
            pendingStandaloneTimer = nil
            local hasPendingUpdate = false
            for _ in pairs(pendingQuestUpdateIDs) do
                hasPendingUpdate = true break
            end
            if hasPendingUpdate then
                DbgWQ("UI_INFO_MESSAGE standalone: skipped (pending debounced update)")
                return
            end
            DbgWQ("UI_INFO_MESSAGE standalone popup:", "sub=", normalized)
            local L = addon.L or {}
            addon.Presence.QueueOrPlay("QUEST_UPDATE", L["QUEST UPDATE"], normalized, { source = "UI_INFO_MESSAGE" })
        end)
    end
end

--- Return the set of quest IDs with pending debounced updates (for standalone path check).
--- @return table questID -> true
local function Quest_GetPendingQuestUpdateIDs()
    return pendingQuestUpdateIDs
end

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.Quest_OnQuestAccepted    = Quest_OnQuestAccepted
addon.Presence.Quest_OnQuestTurnedIn    = Quest_OnQuestTurnedIn
addon.Presence.Quest_OnQuestRemoved     = Quest_OnQuestRemoved
addon.Presence.Quest_OnQuestWatchUpdate = Quest_OnQuestWatchUpdate
addon.Presence.Quest_OnQuestLogUpdate   = Quest_OnQuestLogUpdate
addon.Presence.Quest_OnUIInfoMessage    = Quest_OnUIInfoMessage
addon.Presence.Quest_GetPendingQuestUpdateIDs = Quest_GetPendingQuestUpdateIDs
addon.Presence.IsQuestText              = IsQuestText
addon.Presence.NormalizeQuestUpdateText = NormalizeQuestUpdateText
