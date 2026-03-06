--[[
    Horizon Suite - Focus - Utilities
    Shared helpers for design tokens, borders, text, logging, and quest/map helpers.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then
    addon = {}
    -- Fallback: shouldn't happen since HorizonSuite.lua loads first
    _G.HorizonSuite = addon
end

-- ============================================================================
-- DESIGN TOKENS
-- ============================================================================

addon.Design = addon.Design or {}
local Design = addon.Design

Design.BORDER_COLOR   = Design.BORDER_COLOR   or { 0.35, 0.38, 0.45, 0.45 }
Design.BACKDROP_COLOR = Design.BACKDROP_COLOR or { 0.08, 0.08, 0.12, 0.90 }
Design.SHADOW_COLOR   = Design.SHADOW_COLOR   or { 0, 0, 0 }
Design.QUEST_ITEM_BG     = Design.QUEST_ITEM_BG     or { 0.12, 0.12, 0.15, 0.9 }
Design.QUEST_ITEM_BORDER = Design.QUEST_ITEM_BORDER or { 0.30, 0.32, 0.38, 0.6 }

-- ============================================================================
-- QUEST ITEM BUTTON STYLING
-- ============================================================================

--- Apply unified slot-style visuals to a quest item button (per-entry or floating).
--- Adds dark backdrop, thin border; caller should add hover alpha in OnEnter/OnLeave.
--- @param btn Frame Button frame (SecureActionButtonTemplate) to style.
function addon.StyleQuestItemButton(btn)
    if not btn then return end
    local bg = Design.QUEST_ITEM_BG
    local bgTex = btn:CreateTexture(nil, "BACKGROUND")
    bgTex:SetAllPoints()
    bgTex:SetColorTexture(bg[1], bg[2], bg[3], bg[4] or 1)
    addon.CreateBorder(btn, Design.QUEST_ITEM_BORDER, 1)
end

--- Blizzard-inspired clean frame for the floating quest item button.
--- Dark background, crisp 1px border drawn on OVERLAY so it sits on top of the icon.
--- Highlight on hover via a subtle white overlay. Idempotent.
--- @param btn Frame Button frame (SecureActionButtonTemplate) to style.
function addon.ApplyBlizzardFloatingQuestItemStyle(btn)
    if not btn or btn._blizzardStyleApplied then return end
    btn._blizzardStyleApplied = true

    local BORDER_T = 1
    local BORDER_C = { 0.40, 0.42, 0.48, 0.80 }
    local BG_C     = { 0.06, 0.06, 0.08, 0.95 }

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(BG_C[1], BG_C[2], BG_C[3], BG_C[4])

    local function mkBorder(point1, point2, isHoriz)
        local t = btn:CreateTexture(nil, "OVERLAY")
        t:SetColorTexture(BORDER_C[1], BORDER_C[2], BORDER_C[3], BORDER_C[4])
        if isHoriz then
            t:SetHeight(BORDER_T)
            t:SetPoint("LEFT", btn, "LEFT", 0, 0)
            t:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
            t:SetPoint(point1, btn, point2, 0, 0)
        else
            t:SetWidth(BORDER_T)
            t:SetPoint("TOP", btn, "TOP", 0, 0)
            t:SetPoint("BOTTOM", btn, "BOTTOM", 0, 0)
            t:SetPoint(point1, btn, point2, 0, 0)
        end
    end
    mkBorder("TOPLEFT", "TOPLEFT", true)
    mkBorder("BOTTOMLEFT", "BOTTOMLEFT", true)
    mkBorder("TOPLEFT", "TOPLEFT", false)
    mkBorder("TOPRIGHT", "TOPRIGHT", false)

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.15)
    btn:SetHighlightTexture(highlight)
end

-- ============================================================================
-- QUEST HELPERS
-- ============================================================================

--- True if the player has accepted this quest (in the quest log).
--- C_QuestLog.IsOnQuest is the authoritative check for campaign/available entries
--- that may appear in the log before being accepted.
--- @param questID number
--- @return boolean
function addon.IsQuestAccepted(questID)
    if not questID or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID)
    end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(questID) ~= nil
    end
    return false
end

-- ============================================================================
-- TIME FORMATTING
-- ============================================================================

--- Format remaining time in seconds as "Xd Xh Xm Xs" (days, hours, minutes, seconds).
--- Shows only the most significant non-zero units to keep the string compact.
--- @param seconds number Remaining time in seconds (>= 0)
--- @return string|nil Formatted string, or nil if invalid
function addon.FormatTimeRemaining(seconds)
    if not seconds or type(seconds) ~= "number" or seconds < 0 then return nil end
    local s = math.floor(seconds % 60)
    local m = math.floor(seconds / 60) % 60
    local h = math.floor(seconds / 3600) % 24
    local d = math.floor(seconds / 86400)
    if d > 0 then
        return ("%dd %dh %dm"):format(d, h, m)
    elseif h > 0 then
        return ("%dh %dm %ds"):format(h, m, s)
    elseif m > 0 then
        return ("%dm %ds"):format(m, s)
    else
        return ("%ds"):format(s)
    end
end

--- Convert minutes (e.g. from C_TaskQuest.GetQuestTimeLeftMinutes) to seconds and format.
--- @param minutes number Time left in minutes
--- @return string|nil Formatted string, or nil if invalid
function addon.FormatTimeRemainingFromMinutes(minutes)
    if not minutes or type(minutes) ~= "number" or minutes < 0 then return nil end
    return addon.FormatTimeRemaining(minutes * 60)
end

--- Timer color based on absolute time remaining. Used when timerColorByRemaining is on.
--- Green when >=12h left, yellow when <12h, red when <3h.
--- @param remaining number Seconds remaining
--- @param duration number Total duration in seconds (unused; kept for API compatibility)
--- @return number r, number g, number b
function addon.GetTimerColorByRemaining(remaining, duration)
    if not remaining or type(remaining) ~= "number" or remaining < 0 then
        local c = addon.TIMER_URGENCY_COLORS and addon.TIMER_URGENCY_COLORS.critical or { 1, 0.35, 0.35 }
        return c[1], c[2], c[3]
    end
    local redSec = addon.TIMER_URGENCY_RED_SECONDS or (3 * 3600)
    local yellowSec = addon.TIMER_URGENCY_YELLOW_SECONDS or (12 * 3600)
    local t = addon.TIMER_URGENCY_COLORS or {}
    if remaining < redSec then
        local c = t.critical or { 1.00, 0.35, 0.35 }
        return c[1], c[2], c[3]
    elseif remaining < yellowSec then
        local c = t.low or { 1.00, 0.85, 0.25 }
        return c[1], c[2], c[3]
    else
        local c = t.plenty or { 0.35, 0.90, 0.45 }
        return c[1], c[2], c[3]
    end
end

-- ============================================================================
-- BORDERS & TEXT
-- ============================================================================

--- Create a simple 1px border around a frame.
-- @param frame Frame to receive border textures.
-- @param color Optional {r,g,b,a}; falls back to Design.BORDER_COLOR.
-- @param thickness Optional border thickness in pixels (default 1).
function addon.CreateBorder(frame, color, thickness)
    if not frame then return nil end
    local c = color or Design.BORDER_COLOR
    local t = thickness or 1

    local top = frame:CreateTexture(nil, "BORDER")
    top:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    top:SetHeight(t)
    top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    bottom:SetHeight(t)
    bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    local left = frame:CreateTexture(nil, "BORDER")
    left:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    left:SetWidth(t)
    left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

    local right = frame:CreateTexture(nil, "BORDER")
    right:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
    right:SetWidth(t)
    right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

    return top, bottom, left, right
end

--- Safe helper for setting text color from a {r,g,b[,a]} table.
function addon.SetTextColor(fontString, color)
    if not fontString or not color then return end
    fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

--- Apply text case from DB option. Returns text in upper, lower, or proper (title) case based on dbKey.
-- @param text string or nil
-- @param dbKey string DB key (e.g. "headerTextCase"); values "upper", "lower", or "proper"
-- @param default string optional default when key is not set (e.g. "upper" for header, "proper" for title)
-- @return string
function addon.ApplyTextCase(text, dbKey, default)
    if not text or type(text) ~= "string" or text == "" then return text end
    
    local v = addon.GetDB(dbKey, default or "proper")
    if v == "default" then return text end
    local hasNonAscii = text:find("[\128-\255]") ~= nil
    local hasEscapes = text:find("|c") or text:find("|[TtAa]")
    local hasExtendedCap = (not hasNonAscii) and (text == strupper(text))
    local _, spaceCount = text:gsub("%s", "")
    local isSystemText = spaceCount > 3 or text:find("%.%s*$") or #text > 35
    local isInternal = hasEscapes or hasExtendedCap or isSystemText
    local escapes = {}
    
    local function transform(s)
        -- Lua case transforms are byte-based; avoid corrupting UTF-8 multibyte text.
        if s and s:find("[\128-\255]") then return s end
        if v == "upper" then return strupper(s) end
        if v == "lower" then return strlower(s) end
        
        if v == "proper" then
            -- Skip proper case for internal/localized strings to prevent Umlaut corruption
            if isInternal then return s end

            -- Format short addon labels
            local lower = strlower(s)
            return (lower:gsub("(%S)(%S*)", function(first, rest)
                return strupper(first) .. rest
            end))
        end
        return s
    end

    local clean = text:gsub("(|[TtAa][^|]*|[TtAa])", function(m)
        table.insert(escapes, m)
        return "\001"
    end):gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", function(p, i, s)
        table.insert(escapes, {p = p, i = i, s = s})
        return "\001"
    end)

    clean = transform(clean)

    local idx = 0
    return (clean:gsub("\001", function()
        idx = idx + 1
        local e = escapes[idx]
        if type(e) == "table" then
            return e.p .. (isInternal and e.i or transform(e.i)) .. e.s
        end
        return e
    end))
end

--- Create a text + shadow pair using the addon font objects and shadow offsets.
-- Returns text, shadow.
function addon.CreateShadowedText(parent, fontObject, layer, shadowLayer)
    if not parent then return nil end
    local textLayer   = layer or "OVERLAY"
    local shadowLayer = shadowLayer or "BORDER"

    local text = parent:CreateFontString(nil, textLayer)
    if fontObject then
        text:SetFontObject(fontObject)
    end

    local shadow = parent:CreateFontString(nil, shadowLayer)
    if fontObject then
        shadow:SetFontObject(fontObject)
    end
    local ox = addon.SHADOW_OX or 2
    local oy = addon.SHADOW_OY or -2
    local a  = addon.SHADOW_A or 0.8
    shadow:SetTextColor(0, 0, 0, a)
    shadow:SetPoint("CENTER", text, "CENTER", ox, oy)

    return text, shadow
end

-- ============================================================================
-- LOGGING
-- ============================================================================

addon.PRINT_PREFIX = "|cFF00CCFFHorizon Suite:|r "

--- Standardized print helper with colored Horizon Suite prefix.
function addon.HSPrint(msg)
    local prefix = addon.PRINT_PREFIX
    if msg == nil then
        print(prefix)
    else
        print(prefix .. tostring(msg))
    end
end

-- ============================================================================
-- OPTION HELPERS
-- ============================================================================

--- Normalize legacy "bar" to "bar-left". Returns valid highlight style for layout/options.
function addon.NormalizeHighlightStyle(style)
    if style == "bar" then return "bar-left" end
    return style
end

-- ============================================================================
-- QUEST / MAP HELPERS
-- ============================================================================

--- Append default quest rewards (gold, XP, items, currencies, spells) to a tooltip.
--- All API calls are wrapped in pcall; missing or unavailable data is skipped.
--- @param tooltip GameTooltip
--- @param questID number
function addon.AddQuestRewardsToTooltip(tooltip, questID)
    if not tooltip or not questID then return end
    local hasAny = false

    -- Some reward APIs need the quest selected; backup and restore
    local prevQuestID = (C_QuestLog and C_QuestLog.GetSelectedQuest) and C_QuestLog.GetSelectedQuest() or nil
    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        pcall(C_QuestLog.SetSelectedQuest, questID)
    end

    local function restoreQuest()
        if prevQuestID and C_QuestLog and C_QuestLog.SetSelectedQuest then
            pcall(C_QuestLog.SetSelectedQuest, prevQuestID)
        end
    end

    -- Gold
    local ok, money = pcall(GetQuestLogRewardMoney, questID)
    if ok and money and money > 0 then
        local ok2, str = pcall(GetCoinTextureString, money)
        if ok2 and str and str ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine(str or tostring(money))
            hasAny = true
        end
    end

    -- Experience (skip at max level)
    local atMaxLevel = (IsPlayerAtEffectiveMaxLevel and IsPlayerAtEffectiveMaxLevel()) or (UnitLevel("player") and UnitLevel("player") >= (GetMaxPlayerLevel and GetMaxPlayerLevel() or 70))
    if not atMaxLevel then
        local ok, xp = pcall(GetQuestLogRewardXP, questID)
        if ok and xp and xp > 0 then
            if not hasAny then tooltip:AddLine(" ") end
            local label = COMBAT_XP_GAIN or "Experience"
            tooltip:AddDoubleLine(label, tostring(xp))
            hasAny = true
        end
    end

    -- Honor
    if GetQuestLogRewardHonor then
        local ok, honor = pcall(GetQuestLogRewardHonor, questID)
        if ok and honor and honor > 0 then
            if not hasAny then tooltip:AddLine(" ") end
            tooltip:AddDoubleLine(HONOR or "Honor", tostring(honor))
            hasAny = true
        end
    end

    -- Currencies (Retail: C_QuestLog.GetQuestRewardCurrencies; fallback: legacy APIs)
    local currencyRewards = nil
    if C_QuestLog and C_QuestLog.GetQuestRewardCurrencies then
        local ok, cur = pcall(C_QuestLog.GetQuestRewardCurrencies, questID)
        if ok and cur and #cur > 0 then currencyRewards = cur end
    end
    if currencyRewards then
        local FormatLargeNumber = FormatLargeNumber or tostring
        for _, cr in ipairs(currencyRewards) do
            local name = cr.name
            local currencyID = cr.currencyID
            local texture = cr.texture or cr.icon
            local amount = cr.totalRewardAmount or cr.quantity or cr.amount
                or ((cr.baseRewardAmount or 0) + (cr.bonusRewardAmount or 0))
                or 0
            if (name or currencyID) and amount > 0 then
                if not hasAny then tooltip:AddLine(" ") end
                local amountStr = (type(FormatLargeNumber) == "function" and FormatLargeNumber(amount)) or tostring(amount)
                local link
                if currencyID and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
                    local ok3, l = pcall(C_CurrencyInfo.GetCurrencyLink, currencyID, amount)
                    if ok3 and l then link = l end
                end
                local iconStr = (texture and ("|T" .. texture .. ":0|t ")) or ""
                local line = iconStr .. amountStr .. " " .. (link or (name or ("Currency " .. tostring(currencyID))))
                tooltip:AddLine(line)
                hasAny = true
            end
        end
    elseif GetNumQuestLogRewardCurrencies and GetQuestLogRewardCurrencyInfo then
        local ok, n = pcall(GetNumQuestLogRewardCurrencies, questID)
        if ok and n and n > 0 then
            local FormatLargeNumber = FormatLargeNumber or tostring
            for i = 1, n do
                local ok2, name, texture, numItems, currencyID, quality = pcall(GetQuestLogRewardCurrencyInfo, i, questID)
                if ok2 and (name or currencyID) and (numItems == nil or numItems > 0) then
                    if not hasAny then tooltip:AddLine(" ") end
                    local amount = numItems or 0
                    local amountStr = (type(FormatLargeNumber) == "function" and FormatLargeNumber(amount)) or tostring(amount)
                    local link
                    if currencyID and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyLink then
                        local ok3, l = pcall(C_CurrencyInfo.GetCurrencyLink, currencyID, amount)
                        if ok3 and l then link = l end
                    end
                    local iconStr = (texture and ("|T" .. texture .. ":0|t ")) or ""
                    local line = iconStr .. amountStr .. " " .. (link or (name or ""))
                    tooltip:AddLine(line)
                    hasAny = true
                end
            end
        end
    end

    -- Item rewards
    if GetNumQuestLogRewards and GetQuestLogRewardInfo then
        local ok, numItems = pcall(GetNumQuestLogRewards, questID)
        if ok and numItems and numItems > 0 then
            for i = 1, numItems do
                local ok2, itemName, texture, quantity, quality, isUsable, itemID, itemLevel = pcall(GetQuestLogRewardInfo, i, questID)
                if ok2 and (itemName or itemID) then
                    if not hasAny then tooltip:AddLine(" ") end
                    local link
                    if itemID then
                        local ok3, l = pcall(GetItemInfo, itemID)
                        if ok3 and l then link = l end
                    end
                    local iconStr = (texture and ("|T" .. texture .. ":0|t ")) or ""
                    local qty = (quantity and quantity > 1) and (" x" .. quantity) or ""
                    tooltip:AddLine(iconStr .. (link or (itemName or ("Item " .. tostring(itemID)))) .. qty)
                    hasAny = true
                end
            end
        end
    end

    -- Spell rewards
    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestRewardSpells and C_QuestInfoSystem.GetQuestRewardSpellInfo then
        local ok, spellIDs = pcall(C_QuestInfoSystem.GetQuestRewardSpells, questID)
        if ok and spellIDs and #spellIDs > 0 then
            for _, spellID in ipairs(spellIDs) do
                local ok2, info = pcall(C_QuestInfoSystem.GetQuestRewardSpellInfo, questID, spellID)
                if ok2 and info and info.name then
                    if not hasAny then tooltip:AddLine(" ") end
                    local spellLink
                    if spellID and GetSpellLink then
                        local ok3, l = pcall(GetSpellLink, spellID)
                        if ok3 and l then spellLink = l end
                    end
                    local iconStr = (info.texture and ("|T" .. info.texture .. ":0|t ")) or ""
                    tooltip:AddLine(iconStr .. (spellLink or (info.name or ("Spell " .. tostring(spellID)))))
                    hasAny = true
                end
            end
        end
    end

    restoreQuest()
end

--- Append party member quest progress to a tooltip when in a group.
--- Uses C_TooltipInfo.GetQuestPartyProgress; no-op when solo or API unavailable.
--- @param tooltip GameTooltip
--- @param questID number
function addon.AddQuestPartyProgressToTooltip(tooltip, questID)
    if not tooltip or not questID then return end
    if not (C_TooltipInfo and C_TooltipInfo.GetQuestPartyProgress) then return end
    if not (IsInGroup and IsInGroup()) then return end
    local tooltipData = C_TooltipInfo.GetQuestPartyProgress(questID, true)
    if not tooltipData then return end
    if tooltipData.lines and #tooltipData.lines > 0 then
        tooltip:AddLine(" ")
        for _, line in ipairs(tooltipData.lines) do
            local text = line.leftText or ""
            if text ~= "" then
                local r, g, b = line.leftColor and line.leftColor.r or 1, line.leftColor and line.leftColor.g or 1, line.leftColor and line.leftColor.b or 1
                tooltip:AddLine(text, r, g, b, true)
            end
        end
    end
end

--- Parse a Task POI table into a simple set of quest IDs.
-- Handles both array-style lists and keyed tables used by various C_TaskQuest APIs.
-- @param taskPOIs Table returned from C_TaskQuest.* APIs (may be nil).
-- @param outSet   Table used as a set; ids will be added as keys with value true.
-- @return number  Count of IDs added.
function addon.ParseTaskPOIs(taskPOIs, outSet)
    if not taskPOIs or not outSet then return 0 end
    local count = 0

    if #taskPOIs > 0 then
        for _, poi in ipairs(taskPOIs) do
            local id = (type(poi) == "table" and (poi.questID or poi.questId)) or (type(poi) == "number" and poi)
            if id and not outSet[id] then
                outSet[id] = true
                count = count + 1
            end
        end
    end

    for k, v in pairs(taskPOIs) do
        if type(k) == "number" and k > 0 then
            if not outSet[k] then
                outSet[k] = true
                count = count + 1
            end
        elseif type(v) == "table" then
            local id = v.questID or v.questId
            if id and not outSet[id] then
                outSet[id] = true
                count = count + 1
            end
        end
    end

    return count
end

-- Resolve C_TaskQuest world-quest-list API once at load time.
-- Newer builds expose GetQuestsForPlayerByMapID; older builds have GetQuestsOnMap.
addon.GetTaskQuestsForMap = C_TaskQuest and (C_TaskQuest.GetQuestsForPlayerByMapID or C_TaskQuest.GetQuestsOnMap) or nil

--- Open the quest details view for a quest ID, mirroring Blizzard's behavior.
-- Used by click handlers so the logic lives in one place.
function addon.OpenQuestDetails(questID)
    if not questID or not C_QuestLog then return end

    if QuestMapFrame_OpenToQuestDetails then
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if QuestMapFrame_OpenToQuestDetails then
                    QuestMapFrame_OpenToQuestDetails(questID)
                end
            end)
        else
            QuestMapFrame_OpenToQuestDetails(questID)
        end
        return
    end

    if C_QuestLog.SetSelectedQuest then
        C_QuestLog.SetSelectedQuest(questID)
    end

    if OpenQuestLog then
        OpenQuestLog()
        return
    end

    -- Fallback: select quest and toggle world map if available.
    if not WorldMapFrame or not WorldMapFrame.IsShown then
        return
    end
    if not WorldMapFrame:IsShown() and ToggleWorldMap then
        ToggleWorldMap()
    end
end

--- Open the achievement frame to a specific achievement.
-- Used by click handlers for tracked achievements.
function addon.OpenAchievementToAchievement(achievementID)
    if not achievementID or type(achievementID) ~= "number" or achievementID <= 0 then return end
    if AchievementFrame_LoadUI then AchievementFrame_LoadUI() end
    if OpenAchievementFrameToAchievement then
        OpenAchievementFrameToAchievement(achievementID)
    end
end

-- ============================================================================
-- MAP CONTEXT RESOLUTION (World Quests / map-scoped events)
-- ============================================================================

--- Returns map info safely.
local function SafeGetMapInfo(mapID)
    if not mapID or not C_Map or not C_Map.GetMapInfo then return nil end
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    if ok then return info end
    return nil
end

--- Walks up the parent chain until predicate returns true or we hit root.
local function ClimbParents(mapID, predicate, maxDepth)
    local id = mapID
    for _ = 1, (maxDepth or 20) do
        if not id or id == 0 then return nil end
        local info = SafeGetMapInfo(id)
        if not info then return nil end
        if predicate(info, id) then return id, info end
        local parent = info.parentMapID
        if not parent or parent == 0 or parent == id then return nil end
        id = parent
    end
    return nil
end

--- Resolve the player's current map context for filtering WQs and map-scoped events.
-- Goal: avoid subzone-only mapIDs (too aggressive filtering) while still preventing cross-zone leakage.
--
-- Contract:
--  * rawMapID: direct C_Map.GetBestMapForUnit(unit)
--  * zoneMapID: "stable" zone-level map, derived by climbing parents
--  * mapIDsToQuery: list of mapIDs to pass into C_TaskQuest/C_QuestLog map APIs
--
-- Heuristics:
--  * Prefer stopping at mapType == Zone (3).
--  * If GetBestMapForUnit returns a Micro/Dungeon (>=4), include that raw map + its parent zone (if any).
--  * If already on a Zone, do NOT try to include parent/continent (prevents pulling other zones).
--  * In Delves, keep it strict: only query rawMapID.
function addon.ResolvePlayerMapContext(unit)
    unit = unit or "player"

    local rawMapID = (C_Map and C_Map.GetBestMapForUnit) and C_Map.GetBestMapForUnit(unit) or nil
    if not rawMapID then
        return { rawMapID = nil, zoneMapID = nil, mapIDsToQuery = {} }
    end

    local rawInfo = SafeGetMapInfo(rawMapID)
    local rawType = rawInfo and rawInfo.mapType

    -- Party dungeons: keep it strict to the instance map.
    -- In instances, zoneMapID climbing causes us to pull open-world zone WQs, which should not appear.
    if addon.IsInPartyDungeon and addon.IsInPartyDungeon() then
        return { rawMapID = rawMapID, zoneMapID = rawMapID, rawMapType = rawType, mapIDsToQuery = { rawMapID } }
    end

    -- Delves: don't climb; querying parent will leak zone WQs into delve UI.
    if addon.IsDelveActive and addon.IsDelveActive() then
        return { rawMapID = rawMapID, zoneMapID = rawMapID, rawMapType = rawType, mapIDsToQuery = { rawMapID } }
    end

    -- Find a stable zone parent (mapType == Zone).
    local zoneMapID = nil
    if rawType == 3 then
        zoneMapID = rawMapID
    else
        zoneMapID = select(1, ClimbParents(rawMapID, function(info)
            return info and info.mapType == 3
        end))
    end

    -- If we couldn't find a zone (rare), fall back to raw.
    if not zoneMapID then zoneMapID = rawMapID end

    -- Build query list.
    local mapIDsToQuery = {}
    local seen = {}
    local function add(id)
        if id and id ~= 0 and not seen[id] then
            seen[id] = true
            mapIDsToQuery[#mapIDsToQuery + 1] = id
        end
    end

    add(zoneMapID)

    -- Include immediate children of the zone map.
    -- Many WQs/area POIs are authored on child "area" maps, not on the parent zone map.
    -- We keep this bounded to avoid pulling in neighboring zones or overloading APIs.
    if C_Map and C_Map.GetMapChildrenInfo and zoneMapID then
        local ok, children = pcall(C_Map.GetMapChildrenInfo, zoneMapID, nil, true)
        if ok and children and type(children) == "table" then
            local added = 0
            for _, child in ipairs(children) do
                local childID = child and (child.mapID or child.uiMapID or child.mapId)
                local childType = child and child.mapType
                -- Allow only sub-zone/area/zone-ish children.
                if childID and childID ~= 0 and (childType == nil or childType == 4 or childType == 5 or childType == 6) then
                    -- Safety: only include children that truly belong to this zone map.
                    -- Some map hierarchies include other zones as children (e.g. special hubs).
                    local belongs = false
                    local check = childID
                    for _ = 1, 10 do
                        if check == zoneMapID then
                            belongs = true
                            break
                        end
                        local info = SafeGetMapInfo(check)
                        if not info or not info.parentMapID or info.parentMapID == 0 then break end
                        check = info.parentMapID
                    end
                    if belongs then
                        add(childID)
                        added = added + 1
                        if added >= 25 then break end
                    end
                end
            end
        end
    end

    -- If we're on a micro/dungeon map, also query that map so we don't miss "instance-only" or micro POIs.
    if rawType ~= nil and rawType >= 4 then
        add(rawMapID)
    end

    -- Final safety pass: ensure every queried map actually belongs to this zoneMapID.
    -- Some hierarchies can leak unrelated area maps even after child filtering.
    if zoneMapID and #mapIDsToQuery > 0 then
        local filtered = {}
        for _, mid in ipairs(mapIDsToQuery) do
            local okBelongs = (mid == zoneMapID)
            if not okBelongs then
                local check = mid
                for _ = 1, 12 do
                    local info = SafeGetMapInfo(check)
                    if not info or not info.parentMapID or info.parentMapID == 0 then break end
                    check = info.parentMapID
                    if check == zoneMapID then okBelongs = true; break end
                end
            end
            if okBelongs then
                filtered[#filtered + 1] = mid
            end
        end
        mapIDsToQuery = filtered
    end

    return {
        rawMapID = rawMapID,
        zoneMapID = zoneMapID,
        rawMapType = rawType,
        mapIDsToQuery = mapIDsToQuery,
    }
end

-- ============================================================================
-- SECURE ITEM OVERLAY
-- ============================================================================

local secureItemOverlay
local overlayTarget

local function CreateSecureItemOverlay()
    if secureItemOverlay then return end
    local btn = CreateFrame("Button", "HSSecureItemOverlay", UIParent, "SecureActionButtonTemplate")
    btn:SetSize(1, 1)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(200)
    btn:RegisterForClicks("AnyDown", "AnyUp")
    btn:SetAttribute("type", "item")
    btn:EnableMouse(true)
    btn:SetAlpha(0)
    btn:Hide()
    btn:SetScript("OnEnter", function(self)
        if overlayTarget then
            overlayTarget:SetAlpha(1)
            local itemLink = overlayTarget._itemLink or (overlayTarget._ownerEntry and overlayTarget._ownerEntry.itemLink)
            if itemLink and GameTooltip then
                GameTooltip:SetOwner(overlayTarget, "ANCHOR_RIGHT")
                pcall(GameTooltip.SetHyperlink, GameTooltip, itemLink)
                GameTooltip:Show()
            end
        end
    end)
    btn:SetScript("OnLeave", function(self)
        local target = overlayTarget
        if not InCombatLockdown() then
            self:Hide()
        end
        overlayTarget = nil
        if target then
            target:SetAlpha(0.9)
            if GameTooltip:GetOwner() == target then
                GameTooltip:Hide()
            end
        end
    end)
    secureItemOverlay = btn
end

function addon.AttachSecureItemOverlay(itemBtn, itemLink)
    if not itemBtn or not itemLink then return end
    if InCombatLockdown() then return end
    if not secureItemOverlay then CreateSecureItemOverlay() end
    if overlayTarget == itemBtn and secureItemOverlay:IsShown() then return end
    overlayTarget = itemBtn
    secureItemOverlay:SetAttribute("item", itemLink)
    secureItemOverlay:ClearAllPoints()
    secureItemOverlay:SetAllPoints(itemBtn)
    secureItemOverlay:SetParent(itemBtn)
    secureItemOverlay:SetFrameLevel(itemBtn:GetFrameLevel() + 5)
    secureItemOverlay:Show()
end

function addon.DetachSecureItemOverlay(itemBtn)
    if not secureItemOverlay then return end
    if overlayTarget ~= itemBtn then return end
    if secureItemOverlay:IsMouseOver() then return end
    if InCombatLockdown() then return end
    secureItemOverlay:Hide()
    overlayTarget = nil
end

function addon.SetSecureItemOverlayItem(itemLink)
    if not secureItemOverlay then CreateSecureItemOverlay() end
    if InCombatLockdown() then return end
    secureItemOverlay:SetAttribute("item", itemLink)
end

CreateSecureItemOverlay()