--[[
    Horizon Suite - Dashboard news logic (pure; no frames).
    Filters the generated feed (DashboardNewsFeed.lua) by date and version, sorts it,
    puts a story built from this version's patch notes first, and tracks which
    stories the player has seen. Tested by tools/test_news_logic.js.
]]

local addon = _G.HorizonSuite
if not addon then return end

local NewsLogic = {}
addon.NewsLogic = NewsLogic

local DEFAULT_PRIORITY = 100

local function VersionParts(v)
    local t = {}
    for n in tostring(v or ""):gmatch("%d+") do t[#t + 1] = tonumber(n) end
    return t
end

--- @return number -1 when a < b, 0 when equal, 1 when a > b (numeric per part; missing parts are 0)
function NewsLogic.CompareVersions(a, b)
    local pa, pb = VersionParts(a), VersionParts(b)
    for i = 1, math.max(#pa, #pb) do
        local x, y = pa[i] or 0, pb[i] or 0
        if x ~= y then return x < y and -1 or 1 end
    end
    return 0
end

--- Dates are ISO strings, so string comparison orders them correctly.
function NewsLogic.IsVisible(story, today, version)
    if story.fromDate and today < story.fromDate then return false end
    if story.untilDate and today > story.untilDate then return false end
    if story.untilVersion and version and version ~= ""
        and NewsLogic.CompareVersions(version, story.untilVersion) > 0 then
        return false
    end
    return true
end

function NewsLogic.Visible(stories, today, version)
    local out = {}
    for i = 1, #(stories or {}) do
        local s = stories[i]
        if NewsLogic.IsVisible(s, today, version) then out[#out + 1] = s end
    end
    table.sort(out, function(a, b)
        local pa, pb = a.priority or DEFAULT_PRIORITY, b.priority or DEFAULT_PRIORITY
        if pa ~= pb then return pa > pb end
        local fa, fb = a.fromDate or "", b.fromDate or ""
        if fa ~= fb then return fa > fb end
        return a.id < b.id
    end)
    return out
end

local KNOWN_MODULES = {
    focus = true, presence = true, vista = true, insight = true,
    augment = true, essence = true, echo = true, axis = true,
}
local MAX_MODULES = 3
local MONTHS = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

--- Days since a fixed epoch for a proleptic Gregorian date (pure; no os.time).
local function DayNumber(y, m, d)
    if m <= 2 then y = y - 1; m = m + 12 end
    local era = math.floor(y / 400)
    local yoe = y - era * 400
    local doy = math.floor((153 * (m - 3) + 2) / 5) + d - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    return era * 146097 + doe
end

local function ParseISO(s)
    if type(s) ~= "string" then return nil end
    local y, m, d = s:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not y then return nil end
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    if m < 1 or m > 12 or d < 1 or d > 31 then return nil end
    return y, m, d
end

--- "Today", "Yesterday", "N days ago" (2-6), else "12 Oct" (with the year when it differs).
--- A future date reads "Today". @return string|nil nil when fromDate is missing or invalid.
function NewsLogic.PostedLabel(fromDate, today)
    local y, m, d = ParseISO(fromDate)
    if not y then return nil end
    local L = addon.L or {}
    local ty, tm, td = ParseISO(today)
    if ty then
        local days = DayNumber(ty, tm, td) - DayNumber(y, m, d)
        if days <= 0 then return L["DASH_NEWS_POSTED_TODAY"] or "Today" end
        if days == 1 then return L["DASH_NEWS_POSTED_YESTERDAY"] or "Yesterday" end
        if days <= 6 then return (L["DASH_NEWS_POSTED_DAYS_X"] or "%d days ago"):format(days) end
    end
    local label = d .. " " .. MONTHS[m]
    if not ty or ty ~= y then label = label .. " " .. y end
    return label
end

--- Distinct known module keys named by "Module:" / "Module (Flavour):" bullet prefixes.
local function ModulesFromBullets(bullets)
    local out, seen = {}, {}
    for _, b in ipairs(bullets) do
        local text = tostring(b)
        local key = text:match("^%s*(%a+)%s*:") or text:match("^%s*(%a+)%s*%b()%s*:")
        key = key and key:lower()
        if key and KNOWN_MODULES[key] and not seen[key] and #out < MAX_MODULES then
            seen[key] = true
            out[#out + 1] = key
        end
    end
    return out
end

--- A story from the installed version's patch notes: its first two bullets, linking to Patch notes.
function NewsLogic.ReleaseStory(patchNotes, version)
    local notes = type(patchNotes) == "table" and version and patchNotes[version]
    if type(notes) ~= "table" then return nil end
    local paragraphs = {}
    for _, section in ipairs(notes) do
        for _, bullet in ipairs(section.bullets or {}) do
            if #paragraphs < 2 then paragraphs[#paragraphs + 1] = bullet end
        end
    end
    if #paragraphs == 0 then return nil end
    local L = addon.L or {}
    return {
        id = "release-" .. version,
        layout = "release",
        isRelease = true,
        version = version,
        date = notes.date,
        fromDate = notes.date,
        title = (L["DASH_NEWS_RELEASE_TITLE_X"] or "What's new in %s"):format(version),
        button = L["DASH_NEWS_RELEASE_BUTTON"] or "Patch notes",
        action = { type = "patch_notes" },
        summary = paragraphs[1],
        blocks = { { kind = "list", items = paragraphs } },
        modules = ModulesFromBullets(paragraphs),
        paragraphs = paragraphs,
    }
end

function NewsLogic.Feed(stories, patchNotes, today, version)
    local out = {}
    local release = NewsLogic.ReleaseStory(patchNotes, version)
    if release then out[1] = release end
    local visible = NewsLogic.Visible(stories, today, version)
    for i = 1, #visible do out[#out + 1] = visible[i] end
    return out
end

function NewsLogic.UnseenCount(feed, seen)
    local n = 0
    for i = 1, #(feed or {}) do
        local s = feed[i]
        if not s.isRelease and not (seen and seen[s.id]) then n = n + 1 end
    end
    return n
end

function NewsLogic.MarkSeen(feed, seen)
    for i = 1, #(feed or {}) do
        local s = feed[i]
        if not s.isRelease then seen[s.id] = true end
    end
end

--- Returns rootDB.newsSeen, creating it on first run with every current story marked
--- seen, so existing players aren't badged for news that was already there.
--- @return table seen, boolean firstRun
function NewsLogic.EnsureSeen(rootDB, feed)
    if type(rootDB.newsSeen) == "table" then return rootDB.newsSeen, false end
    rootDB.newsSeen = {}
    NewsLogic.MarkSeen(feed, rootDB.newsSeen)
    return rootDB.newsSeen, true
end

function NewsLogic.Today()
    local d = _G.date or (os and os.date)
    return d and d("%Y-%m-%d") or ""
end

function NewsLogic.CurrentVersion()
    local gm = (C_AddOns and C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
    return (gm and gm(addon.ADDON_NAME or "HorizonSuite", "Version")) or ""
end

--- The feed as the dashboard shows it right now.
function NewsLogic.CurrentFeed()
    return NewsLogic.Feed(addon.DashboardNewsFeed, addon.PATCH_NOTES, NewsLogic.Today(), NewsLogic.CurrentVersion())
end
