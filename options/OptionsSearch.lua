--[[
    Horizon Suite - Options Search
    Builds and scores the flat search index over addon.OptionCategories.
    Exports OptionsData_BuildSearchIndex, OptionsData_SearchEntryScore, and
    OptionsData_SearchResultDetailText used by the dashboard search bar.
    Must load after all module options files so OptionCategories is complete.
]]
local addon = _G.HorizonSuite
if not addon then return end

local function TokenizeSearchCorpus(str)
    local t = {}
    if not str or str == "" then return t end
    local lower = str:lower()
    for word in string.gmatch(lower, "%w+") do
        t[#t + 1] = word
    end
    return t
end

local function ParseSearchQueryTerms(query)
    local terms = {}
    if not query or query == "" then return terms end
    local q = query:lower()
    q = q:gsub("^%s+", ""):gsub("%s+$", "")
    for word in string.gmatch(q, "%w+") do
        terms[#terms + 1] = word
    end
    return terms
end

-- Best score for one query term against a token list (exact word or whole-token prefix if term length >= 2).
local function TermScoreAgainstTokens(term, tokens, exactScore, prefixScore)
    local best = 0
    if not tokens then return 0 end
    for i = 1, #tokens do
        local w = tokens[i]
        if w == term then
            if exactScore > best then best = exactScore end
        elseif #term >= 2 and #w >= #term and string.sub(w, 1, #term) == term then
            if prefixScore > best then best = prefixScore end
        end
    end
    return best
end

--- Score an index entry for a lowercased search string; nil if no match.
--- Multi-word queries require every term to match some token (AND). Higher = better (name > section > category > module > option id > desc).
--- @param entry table Row from OptionsData_BuildSearchIndex()
--- @param queryLower string Trimmed, lowercased query
--- @return number|nil
function OptionsData_SearchEntryScore(entry, queryLower)
    if not entry or not queryLower or queryLower == "" then return nil end
    local terms = ParseSearchQueryTerms(queryLower)
    if #terms == 0 then return nil end
    local total = 0
    for ti = 1, #terms do
        local term = terms[ti]
        local best = 0
        local function bump(tokens, exactPts, prefixPts)
            local s = TermScoreAgainstTokens(term, tokens, exactPts, prefixPts)
            if s > best then best = s end
        end
        bump(entry.searchTokensName, 1000, 700)
        bump(entry.searchTokensSection, 400, 280)
        bump(entry.searchTokensCategory, 350, 240)
        bump(entry.searchTokensModule, 300, 200)
        bump(entry.searchTokensOptionId, 180, 120)
        bump(entry.searchTokensDesc, 150, 100)
        if best == 0 then return nil end
        total = total + best
    end
    return total
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

--- Plain-text option description and tooltip for search dropdown rows (why this matched).
--- @param opt table Option definition from OptionCategories
--- @param maxLen number|nil Max characters before "..." (default 140)
--- @return string
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

function OptionsData_BuildSearchIndex()
    local index = {}
    local L = addon.L
    local cats = addon.OptionCategories
    for catIdx, cat in ipairs(cats) do
        local currentSection = ""
        local moduleKey = cat.moduleKey
        local moduleLabel
        if cat.key == "Profiles" or cat.key == "Modules" or cat.key == "GlobalToggles" then
            moduleLabel = addon.BrandModule and addon.BrandModule("axis") or "Axis"
        else
            moduleLabel = addon.BrandModule and addon.BrandModule(moduleKey) or (L and L["MODULES"])
        end
        local catNameRaw = type(cat.name) == "function" and cat.name() or cat.name
        local catNameStr = tostring(catNameRaw or "")
        local catNameLower = catNameStr:lower()
        local catOpts = type(cat.options) == "function" and cat.options() or cat.options
        for _, opt in ipairs(catOpts) do
            if opt.type == "section" then
                currentSection = type(opt.name) == "function" and opt.name() or opt.name or ""
            elseif opt.type ~= "section" and opt.type ~= "header" and opt.type ~= "moduleReloadPrompt" then
                local rawName = type(opt.name) == "function" and opt.name() or opt.name
                local name = (rawName or ""):lower()
                local desc = ((opt.desc or "") .. " " .. (opt.tooltip or "")):lower()
                local sectionLower = (currentSection or ""):lower()
                local moduleLower = (moduleLabel or ""):lower()
                local searchText = name .. " " .. desc .. " " .. sectionLower .. " " .. moduleLower
                local optionId = opt.dbKey or (cat.key .. "_" .. (rawName or ""):gsub("%s+", "_"))
                local idForTokens = tostring(optionId or ""):lower():gsub("_+", " ")
                index[#index + 1] = {
                    categoryKey = cat.key,
                    categoryName = cat.name,
                    categoryIndex = catIdx,
                    moduleKey = moduleKey,
                    moduleLabel = moduleLabel,
                    sectionName = currentSection,
                    option = opt,
                    optionId = optionId,
                    searchText = searchText,
                    searchTokensName = TokenizeSearchCorpus(name),
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

addon.OptionsData_BuildSearchIndex        = OptionsData_BuildSearchIndex
addon.OptionsData_SearchEntryScore        = OptionsData_SearchEntryScore
addon.OptionsData_SearchResultDetailText  = OptionsData_SearchResultDetailText
