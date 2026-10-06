--[[
    Horizon Suite - Options Search
    Builds and scores the flat search index over addon.OptionCategories.
    Exports OptionsData_BuildSearchIndex, OptionsData_SearchEntryScore,
    OptionsData_SearchResultDetailText and OptionsData_SearchHighlight used by the dashboard
    search bar.
    Must load after all module options files so OptionCategories is complete.
]]
local addon = _G.HorizonSuite
if not addon then return end

-- A word is a run of letters and digits, or of UTF-8 bytes, so accented and CJK labels in the
-- other locales split into words too (string.lower leaves those bytes as they are).
local WORD = "[%w\128-\255]+"

-- US spellings fold to the UK spellings the strings use, so either finds the same setting.
local SPELLING = {
    color = "colour", colors = "colours", colored = "coloured", coloring = "colouring",
    gray = "grey", grayscale = "greyscale", center = "centre", centered = "centred",
    behavior = "behaviour", armor = "armour", favorite = "favourite", favorites = "favourites",
    customize = "customise", organize = "organise", dialog = "dialogue",
}

-- Words a player may type for the same idea. A term also matches its alternatives, at a
-- lower score than the word itself.
local SYNONYMS = {
    opacity = { "alpha", "transparency", "transparent" },
    alpha = { "opacity", "transparency" },
    transparency = { "opacity", "alpha" },
    transparent = { "opacity", "alpha" },
    scale = { "size" },
    size = { "scale" },
    bigger = { "size", "scale" },
    smaller = { "size", "scale" },
    font = { "text", "typeface" },
    typeface = { "font" },
    colour = { "tint" },
    tint = { "colour" },
    position = { "anchor", "move" },
    move = { "position", "lock", "anchor" },
    drag = { "lock", "position", "move" },
    anchor = { "position" },
    sound = { "audio", "volume" },
    audio = { "sound" },
    volume = { "sound" },
    notification = { "toast", "alert" },
    notifications = { "toasts", "alerts" },
    toast = { "notification", "alert" },
    toasts = { "notifications", "alerts" },
    alert = { "notification", "toast" },
    alerts = { "notifications", "toasts" },
    delay = { "duration", "time" },
    duration = { "time", "delay" },
}
local SYNONYM_SHARE = 0.75

-- Words that only frame a request ("show the minimap icon"). Labels mostly leave them out, so
-- a filler that matches nothing is skipped instead of failing the search.
local FILLER = {
    show = true, hide = true, display = true, enable = true, disable = true, toggle = true,
    turn = true, on = true, off = true, the = true, a = true, an = true, of = true, to = true,
    ["for"] = true, ["in"] = true, my = true, set = true, change = true, use = true, how = true,
    i = true, can = true, setting = true, settings = true, option = true, options = true,
}

-- Extra words for each module, so a search can name what the module is about ("tooltip scale"
-- finds Insight's scale).
local MODULE_ALIASES = {
    axis = "dashboard settings window",
    focus = "tracker quests objectives",
    presence = "notifications toasts zone text",
    vista = "minimap map",
    insight = "tooltip tooltips",
    augment = "loot toasts vendor",
    essence = "character sheet",
    echo = "chat whispers",
}

local function Fold(word)
    return SPELLING[word] or word
end

local function TokenizeSearchCorpus(str)
    local t = {}
    if not str or str == "" then return t end
    local lower = str:lower()
    for word in string.gmatch(lower, WORD) do
        t[#t + 1] = Fold(word)
    end
    return t
end

local function ParseSearchQueryTerms(query)
    local terms = {}
    if not query or query == "" then return terms end
    local q = query:lower()
    q = q:gsub("^%s+", ""):gsub("%s+$", "")
    for word in string.gmatch(q, WORD) do
        terms[#terms + 1] = Fold(word)
    end
    return terms
end

-- True when a and b differ by one edit: a letter changed, added, dropped, or two neighbours
-- swapped ("colur", "colourr", "clour", "coluor" all reach "colour").
local function WithinOneEdit(a, b)
    local la, lb = #a, #b
    if a == b then return true end
    if math.abs(la - lb) > 1 then return false end
    if la == lb then
        local first
        for i = 1, la do
            if a:sub(i, i) ~= b:sub(i, i) then
                if first then
                    -- A swap of neighbours is one edit; any other second difference is not.
                    return i == first + 1 and a:sub(first, first) == b:sub(i, i)
                        and a:sub(i, i) == b:sub(first, first) and a:sub(i + 1) == b:sub(i + 1)
                end
                first = i
            end
        end
        return true
    end
    if la > lb then a, b, la, lb = b, a, lb, la end
    -- b is one longer: skipping one letter of b must leave a.
    local i = 1
    while i <= la and a:sub(i, i) == b:sub(i, i) do i = i + 1 end
    return a:sub(i) == b:sub(i + 1)
end

-- Best score for one query term against a token list. In falling order: the whole word, the
-- start of a word (term of 2+ letters), the word with one typo (both 5+ letters), and, when
-- inside is set (names and keywords only), the term inside a longer word ("map" in "minimap").
local function TermScoreAgainstTokens(term, tokens, exactScore, prefixScore, inside)
    local best = 0
    if not tokens then return 0 end
    local n = #term
    for i = 1, #tokens do
        local w = tokens[i]
        local s = 0
        if w == term then
            s = exactScore
        elseif n >= 2 and #w >= n and string.sub(w, 1, n) == term then
            s = prefixScore
        elseif n >= 5 and #w >= 5 and WithinOneEdit(term, w) then
            s = prefixScore * 0.5
        elseif inside and n >= 3 and #w > n and string.find(w, term, 2, true) then
            s = exactScore * 0.4
        end
        if s > best then best = s end
    end
    return best
end

-- One term's best score across an entry's fields, its synonyms counting at a share.
local FIELDS = {
    { "searchTokensName", 1000, 700, true },
    { "searchTokensKeywords", 450, 320, true },
    { "searchTokensSection", 400, 280 },
    { "searchTokensCategory", 350, 240 },
    { "searchTokensModule", 300, 200 },
    { "searchTokensOptionId", 180, 120 },
    { "searchTokensDesc", 150, 100 },
}
local function TermScore(entry, term)
    local best = 0
    for _, f in ipairs(FIELDS) do
        local s = TermScoreAgainstTokens(term, entry[f[1]], f[2], f[3], f[4])
        if s > best then best = s end
    end
    local alts = SYNONYMS[term]
    if alts then
        for _, alt in ipairs(alts) do
            for _, f in ipairs(FIELDS) do
                local s = TermScoreAgainstTokens(alt, entry[f[1]], f[2], f[3], f[4]) * SYNONYM_SHARE
                if s > best then best = s end
            end
        end
    end
    return best
end

-- Score an index entry for a lowercased search string; nil if no match.
-- Every term must match somewhere (AND), except filler words that match nothing, which are
-- skipped. Higher = better (name > keywords > section > category > module > option id > desc);
-- a name that holds the whole query as a phrase ranks higher still.
-- @param entry table Row from OptionsData_BuildSearchIndex()
-- @param queryLower string Trimmed, lowercased query
-- @return number|nil
function OptionsData_SearchEntryScore(entry, queryLower)
    if not entry or not queryLower or queryLower == "" then return nil end
    local terms = ParseSearchQueryTerms(queryLower)
    if #terms == 0 then return nil end
    local total, matched = 0, 0
    for ti = 1, #terms do
        local term = terms[ti]
        local best = TermScore(entry, term)
        if best == 0 then
            if not FILLER[term] then return nil end
        else
            total = total + best
            matched = matched + 1
        end
    end
    if matched == 0 then return nil end
    if #terms > 1 and entry.searchTokensName then
        local name = " " .. table.concat(entry.searchTokensName, " ") .. " "
        -- The phrase may end mid-word, so "class colour" also lifts "Class colours".
        if name:find(" " .. table.concat(terms, " "), 1, true) then total = total + 500 end
    end
    return total
end

-- The text with each word the query matches wrapped in a colour, for result rows. Text that
-- carries its own escape codes comes back unchanged, so those codes are never split.
-- @param text string
-- @param queryLower string
-- @param hex string Six hex digits, e.g. "a8c0ff"
-- @return string
function OptionsData_SearchHighlight(text, queryLower, hex)
    text = tostring(text or "")
    if text == "" or not queryLower or queryLower == "" or text:find("|", 1, true) then return text end
    local terms = ParseSearchQueryTerms(queryLower)
    if #terms == 0 then return text end
    return (text:gsub(WORD, function(word)
        local one = { Fold(word:lower()) }
        for _, term in ipairs(terms) do
            local hit = TermScoreAgainstTokens(term, one, 1, 1, true) > 0
            if not hit and SYNONYMS[term] then
                for _, alt in ipairs(SYNONYMS[term]) do
                    if TermScoreAgainstTokens(alt, one, 1, 1, true) > 0 then hit = true break end
                end
            end
            if hit and not (FILLER[term] and one[1] ~= term) then
                return "|cff" .. hex .. word .. "|r"
            end
        end
    end))
end

local function StripSearchDisplayFormatting(s)
    if s == nil then return "" end
    s = tostring(s)
    s = s:gsub("|c%x%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("|n", " ")
    s = s:gsub("|T[^|]-|t", "")
    return s
end

local function NormalizeSearchDisplayWhitespace(s)
    s = s:gsub("%s+", " ")
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Plain-text option description and tooltip for search dropdown rows (why this matched).
-- @param opt table Option definition from OptionCategories
-- @param maxLen number|nil Max characters before "..." (default 140)
-- @return string
function OptionsData_SearchResultDetailText(opt, maxLen)
    if not opt then return "" end
    maxLen = maxLen or 140
    local rawD = type(opt.desc) == "function" and opt.desc() or opt.desc
    local rawT = type(opt.tooltip) == "function" and opt.tooltip() or opt.tooltip
    local d = NormalizeSearchDisplayWhitespace(StripSearchDisplayFormatting(rawD))
    local t = NormalizeSearchDisplayWhitespace(StripSearchDisplayFormatting(rawT))
    local combined
    if d ~= "" and t ~= "" and t ~= d then
        combined = d .. " · " .. t
    elseif d ~= "" then
        combined = d
    else
        combined = t
    end
    if #combined <= maxLen then return combined end
    return string.sub(combined, 1, maxLen - 3) .. "..."
end

-- Row types that are layout, not settings, and never appear as results.
-- talkingHeadPreview is a zero-height refresh proxy; the preview itself is pinned above the page.
local NOT_SEARCHABLE = {
    section = true, header = true, moduleReloadPrompt = true, talkingHeadPreview = true,
}

local function ResolveText(v)
    if type(v) == "function" then return v() end
    return v
end

local function BuildSearchIndexUncached()
    local index = {}
    local L = addon.L
    local cats = addon.OptionCategories or {}
    for catIdx, cat in ipairs(cats) do
        local currentSection, currentCardId, currentCardHidden = "", nil, false
        local moduleKey = cat.moduleKey
        local moduleLabel
        if addon.Dashboard_IsAxisCategoryKey and addon.Dashboard_IsAxisCategoryKey(cat.key) then
            moduleLabel = addon.BrandModule and addon.BrandModule("axis") or "Axis"
        else
            moduleLabel = addon.BrandModule and addon.BrandModule(moduleKey) or (L and L["MODULES"])
        end
        local catNameStr = tostring(ResolveText(cat.name) or "")
        local catNameLower = catNameStr:lower()
        local catOpts = ResolveText(cat.options) or {}
        for _, opt in ipairs(catOpts) do
            if opt.type == "section" then
                currentSection = ResolveText(opt.name) or ""
                currentCardId = opt.cardId
                -- A card hidden by its own condition (another addon missing, a feature not shipped)
                -- cannot be opened, so its rows are not results.
                currentCardHidden = type(opt.cardWhen) == "function" and not opt.cardWhen()
            elseif not NOT_SEARCHABLE[opt.type] and not currentCardHidden then
                local rawName = ResolveText(opt.name) or ResolveText(opt.searchName) or ResolveText(opt.labelText)
                local name = (rawName or ""):lower()
                local rawDesc, rawTooltip = ResolveText(opt.desc), ResolveText(opt.tooltip)
                local desc = ((rawDesc or "") .. " " .. (rawTooltip or "")):lower()
                local keywords = {}
                for _, k in ipairs(opt.keywords or {}) do keywords[#keywords + 1] = tostring(ResolveText(k) or "") end
                local keywordText = table.concat(keywords, " "):lower()
                local sectionLower = (currentSection or ""):lower()
                local aliasKey = (addon.Dashboard_IsAxisCategoryKey and addon.Dashboard_IsAxisCategoryKey(cat.key)) and "axis" or moduleKey
                local moduleLower = ((moduleLabel or "") .. " " .. (MODULE_ALIASES[aliasKey] or "")):lower()
                local searchText = name .. " " .. keywordText .. " " .. desc .. " " .. sectionLower .. " " .. moduleLower
                local optionId = opt.dbKey or (cat.key .. "_" .. (rawName or ""):gsub("%s+", "_"))
                local idForTokens = tostring(optionId or ""):lower():gsub("_+", " ")
                index[#index + 1] = {
                    categoryKey = cat.key,
                    categoryName = cat.name,
                    categoryIndex = catIdx,
                    moduleKey = moduleKey,
                    moduleLabel = moduleLabel,
                    sectionName = currentSection,
                    cardId = currentCardId,
                    option = opt,
                    optionId = optionId,
                    searchText = searchText,
                    searchTokensName = TokenizeSearchCorpus(name),
                    searchTokensKeywords = TokenizeSearchCorpus(keywordText),
                    searchTokensDesc = TokenizeSearchCorpus(desc),
                    searchTokensSection = TokenizeSearchCorpus(sectionLower),
                    searchTokensModule = TokenizeSearchCorpus(moduleLower),
                    searchTokensCategory = TokenizeSearchCorpus(catNameLower),
                    searchTokensOptionId = TokenizeSearchCorpus(idForTokens),
                }
            end
        end
    end
    return index
end

--- Put a query at the front of a recent-searches list: trimmed, case-insensitively unique,
--- at most max long. Queries under two characters are ignored. Pure; returns the list.
--- @param list table
--- @param query string
--- @param max number|nil  Default 6
--- @return table
function addon.OptionsSearch_PushRecent(list, query, max)
    list = list or {}
    max = max or 6
    local q = tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if #q < 2 then return list end
    local low = q:lower()
    for i = #list, 1, -1 do
        if tostring(list[i]):lower() == low then table.remove(list, i) end
    end
    table.insert(list, 1, q)
    while #list > max do table.remove(list) end
    return list
end

local cachedIndex

--- The search index over every assembled page. Built once and reused until
--- addon.OptionsSearch_Invalidate() (dashboard opened, module toggled).
--- @return table
function OptionsData_BuildSearchIndex()
    if not cachedIndex then cachedIndex = BuildSearchIndexUncached() end
    return cachedIndex
end

--- Drop the cached index so the next search rebuilds it.
function addon.OptionsSearch_Invalidate()
    cachedIndex = nil
end

addon.OptionsData_BuildSearchIndex        = OptionsData_BuildSearchIndex
addon.OptionsData_SearchEntryScore        = OptionsData_SearchEntryScore
addon.OptionsData_SearchResultDetailText  = OptionsData_SearchResultDetailText
addon.OptionsData_SearchHighlight         = OptionsData_SearchHighlight
