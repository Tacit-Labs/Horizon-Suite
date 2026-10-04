--[[
    Horizon Suite - Options - Page assembler
    Turns the tagged sections every module registered into dashboard pages.
    A Section tagged `page = "<key>"` (and `card = "<key>"`) is filed under that page of
    its module; sections that share a card merge into one card. Pages come out shared
    first (OptionsPages.SHARED), then the module's own pages in RegisterModulePages order.
    The result is written back into addon.OptionCategories, so the sidebar, detail view,
    search and platform prune read assembled pages without knowing about tags.
    Categories with no tagged section pass through unchanged until `strict` is on.
    Builders must return the same sections whatever the saved settings hold, because the page
    list is fixed at load.
    Must load after every module options file and before OptionsPlatform.lua.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionsPages then return end

local Pages = addon.OptionsPages

local Assemble = {
    warnings = {},
    -- When true, a category with no tagged section is reported as a load-time error.
    strict = false,
    -- dbKey of a row search is jumping to; that row shows even when its parent or More hides it.
    revealId = nil,
    revealPending = false,
}
addon.OptionsAssemble = Assemble

-- Fields copied from a page def onto the emitted category.
local PAGE_FIELDS = {
    "desc", "icon", "accentColor", "enabledKey", "getEnabled", "setEnabled",
    "hidden", "dashboardPreviewMode", "headerButtons",
}

local seenWarnings = {}

local function Warn(msg)
    if seenWarnings[msg] then return end
    seenWarnings[msg] = true
    Assemble.warnings[#Assemble.warnings + 1] = msg
    print("|cffff5555Horizon Suite options:|r " .. msg)
end

--- Clear recorded warnings (tests only).
function Assemble.ResetWarnings()
    Assemble.warnings = {}
    seenWarnings = {}
end

local function Resolve(v)
    if type(v) == "function" then return v() end
    return v
end

-- Resolve a category's options without letting a failing builder escape. Returns the list,
-- or nil after warning that the builder failed.
local function SafeResolve(cat, moduleKey)
    local ok, list = pcall(Resolve, cat.options)
    if ok then return list end
    Warn(("%s › %s: options builder failed (%s); left as is"):format(moduleKey, tostring(cat.key), tostring(list)))
    return nil
end

local function Label(t)
    if type(t) ~= "table" then return "?" end
    return tostring(Resolve(t.name) or Resolve(t.searchName) or t.dbKey or "?")
end

local function Copy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

local function ModuleOf(cat)
    return cat.moduleKey or "axis"
end

local function HasCapability(req)
    if not req then return true end
    local P = addon.Platform
    return not (P and P.Has) or P.Has(req)
end

local function Both(a, b)
    if not a then return b end
    if not b then return a end
    return function() return a() and b() end
end

-- ---------------------------------------------------------------------------
-- Saved card state: open/closed and More open/closed, keyed by card id.
-- ---------------------------------------------------------------------------

local function Store(field)
    local db = addon.DATABASE and _G[addon.DATABASE]
    if type(db) ~= "table" then return nil end
    if type(db[field]) ~= "table" then db[field] = {} end
    return db[field]
end

--- @param cardId string
--- @param isFirst boolean  The card is the first on its page
--- @return boolean
function Assemble.IsCardExpanded(cardId, isFirst)
    local s = Store("optionsCardExpanded")
    local v = s and s[cardId]
    if v == nil then return isFirst == true end
    return v == true
end

--- @param cardId string
--- @param expanded boolean
function Assemble.SetCardExpanded(cardId, expanded)
    local s = Store("optionsCardExpanded")
    if s then s[cardId] = expanded and true or false end
end

--- @param cardId string
--- @return boolean
function Assemble.IsMoreOpen(cardId)
    local s = Store("optionsCardMoreOpen")
    return s ~= nil and s[cardId] == true
end

--- @param cardId string
--- @param open boolean
function Assemble.SetMoreOpen(cardId, open)
    local s = Store("optionsCardMoreOpen")
    if s then s[cardId] = open and true or false end
end

--- @param row table
--- @return boolean
function Assemble.IsRevealed(row)
    return Assemble.revealId ~= nil and row.dbKey == Assemble.revealId
end

-- ---------------------------------------------------------------------------
-- Chunks: an option list split into { section = <table>, rows = { ... } }.
-- ---------------------------------------------------------------------------

-- A category is tagged when any top-level section in it carries a page tag.
local function IsTagged(list)
    if type(list) ~= "table" then return false end
    for _, row in ipairs(list) do
        if type(row) == "table" and row.type == "section" and row.page then return true end
    end
    return false
end

-- A columns block is unwrapped: rows before a column's first nested section stay in the
-- enclosing chunk; each nested section opens its own chunk and inherits the enclosing
-- section's page (and its card, on a shared page).
local function Chunks(list, moduleKey, catKey)
    local out, cur = {}, nil
    for _, row in ipairs(list) do
        if row.type == "section" then
            cur = { section = row, rows = {} }
            out[#out + 1] = cur
        elseif not cur then
            Warn(("%s › %s: '%s' sits before the first section and was skipped"):format(moduleKey, tostring(catKey), Label(row)))
        elseif row.type == "columns" then
            local outer = cur
            for _, side in ipairs({ "left", "right" }) do
                local sideCur = outer
                local opts = (row[side] and row[side].options) or {}
                for _, inner in ipairs(opts) do
                    if inner.type == "section" then
                        local s = Copy(inner)
                        if not s.page then s.page = outer.section.page end
                        if not s.card and Pages.IsShared(s.page) then s.card = outer.section.card end
                        sideCur = { section = s, rows = {} }
                        out[#out + 1] = sideCur
                    else
                        sideCur.rows[#sideCur.rows + 1] = inner
                    end
                end
            end
            cur = outer
        else
            cur.rows[#cur.rows + 1] = row
        end
    end
    return out
end

local function Valid(moduleKey, chunk)
    local s = chunk.section
    local where = moduleKey .. " › " .. Label(s)
    local mod = Pages.modules[moduleKey]
    if not s.page then
        Warn(where .. ": section has no page tag; section skipped")
        return false
    end
    if not Pages.IsShared(s.page) and not (mod and mod.defs[s.page]) then
        Warn(where .. ": unknown page '" .. tostring(s.page) .. "'; section skipped")
        return false
    end
    if Pages.IsShared(s.page) and not s.card then
        Warn(where .. ": section on shared page '" .. s.page .. "' has no card tag; section skipped")
        return false
    end
    return HasCapability(s.requires)
end

local function ModuleChunks(moduleKey, sources)
    local all = {}
    for _, cat in ipairs(sources) do
        local list = SafeResolve(cat, moduleKey)
        if type(list) == "table" then
            for _, chunk in ipairs(Chunks(list, moduleKey, cat.key)) do
                if Valid(moduleKey, chunk) then all[#all + 1] = chunk end
            end
        end
    end
    return all
end

-- ---------------------------------------------------------------------------
-- Dependent rows: `parent = "<dbKey>"`, optional `parentIs`. Filled in by Task 3.
-- ---------------------------------------------------------------------------

local function ExpandParents(rows, moduleKey, pageKey)
end

-- ---------------------------------------------------------------------------
-- Page building
-- ---------------------------------------------------------------------------

--- Build one page's option list from a module's chunks.
--- @param moduleKey string
--- @param pageKey string
--- @param chunks table  From ModuleChunks
--- @return table  Option list: a section row per card, then its rows
function Assemble.BuildPage(moduleKey, pageKey, chunks)
    local mod = Pages.modules[moduleKey]
    local def = (mod and mod.defs[pageKey]) or {}
    local cards, order, auto = {}, {}, 0
    for _, chunk in ipairs(chunks) do
        local s = chunk.section
        if s.page == pageKey then
            local key = s.card
            if not key then
                auto = auto + 1
                key = "_" .. auto
            end
            local card = cards[key]
            if not card then
                card = { key = key, chunks = {} }
                cards[key] = card
                order[#order + 1] = key
            end
            if #card.chunks > 0 and s.headerToggle then
                Warn(("%s › %s: '%s' has a header switch, so it must be the first section in card '%s'; section skipped")
                    :format(moduleKey, pageKey, Label(s), key))
            else
                card.chunks[#card.chunks + 1] = chunk
            end
        end
    end

    local rank, seen = {}, {}
    for i, k in ipairs(Pages.SHARED_CARDS[pageKey] or {}) do rank[k] = i end
    for i, k in ipairs(order) do seen[k] = i end
    table.sort(order, function(a, b)
        local ra, rb = rank[a], rank[b]
        if ra and rb then return ra < rb end
        if ra or rb then return ra ~= nil end
        return seen[a] < seen[b]
    end)

    local out = {}
    for _, key in ipairs(order) do
        local card = cards[key]
        local cardId = moduleKey .. ":" .. pageKey .. ":" .. key
        local merged = #card.chunks > 1
        local first = card.chunks[1].section
        local header
        if merged then
            header = { type = "section", name = first.name, headerToggle = first.headerToggle, dbKey = first.dbKey }
        else
            header = Copy(first)
        end
        header.cardId, header.page, header.card = cardId, pageKey, key
        if rank[key] then
            header.name = Pages.Name(key)
        elseif def.cardNames and def.cardNames[key] then
            header.name = def.cardNames[key]
        end
        out[#out + 1] = header

        local normal, advanced = {}, {}
        for _, chunk in ipairs(card.chunks) do
            for _, row in ipairs(chunk.rows) do
                local r = Copy(row)
                -- A merged card has one header, so each section's own condition moves onto its rows.
                if merged and chunk.section.visibleWhen then
                    r.visibleWhen = Both(chunk.section.visibleWhen, r.visibleWhen)
                end
                if r.advanced then advanced[#advanced + 1] = r else normal[#normal + 1] = r end
            end
        end
        for _, r in ipairs(normal) do out[#out + 1] = r end
        -- Task 5 inserts the More row here; until then advanced rows follow the others.
        for _, r in ipairs(advanced) do out[#out + 1] = r end
    end

    ExpandParents(out, moduleKey, pageKey)
    return out
end

local function EmitModule(moduleKey, sources)
    local chunks = ModuleChunks(moduleKey, sources)
    local used = {}
    for _, c in ipairs(chunks) do used[c.section.page] = true end
    local mod = Pages.modules[moduleKey] or { order = {}, defs = {} }

    local pageOrder = {}
    for _, k in ipairs(Pages.SHARED) do pageOrder[#pageOrder + 1] = k end
    for _, k in ipairs(mod.order) do pageOrder[#pageOrder + 1] = k end

    local pages = {}
    for _, pageKey in ipairs(pageOrder) do
        local def = mod.defs[pageKey] or {}
        if used[pageKey] or def.allowEmpty then
            local page = {
                key = def.legacyKey or (moduleKey .. ":" .. pageKey),
                name = def.name or Pages.Name(pageKey),
                moduleKey = sources[1].moduleKey,
                pageKey = pageKey,
                options = function()
                    return Assemble.BuildPage(moduleKey, pageKey, ModuleChunks(moduleKey, sources))
                end,
            }
            for _, field in ipairs(PAGE_FIELDS) do
                if def[field] ~= nil then page[field] = def[field] end
            end
            pages[#pages + 1] = page
        end
    end
    return pages
end

--- Assemble a category list. A module's pages replace its tagged categories at the
--- position of the first one; untagged categories keep their place.
--- @param categories table
--- @return table
function Assemble.Run(categories)
    local tagged, sources, firstAt = {}, {}, {}
    for i, cat in ipairs(categories) do
        tagged[i] = IsTagged(SafeResolve(cat, ModuleOf(cat)))
        if tagged[i] then
            local mk = ModuleOf(cat)
            if not sources[mk] then
                sources[mk] = {}
                firstAt[i] = mk
            end
            sources[mk][#sources[mk] + 1] = cat
        end
    end

    local out = {}
    for i, cat in ipairs(categories) do
        if firstAt[i] then
            for _, page in ipairs(EmitModule(firstAt[i], sources[firstAt[i]])) do
                out[#out + 1] = page
            end
        elseif not tagged[i] then
            if Assemble.strict then
                Warn(("%s › %s: page has no page tags"):format(ModuleOf(cat), tostring(cat.key)))
            end
            out[#out + 1] = cat
        end
    end
    return out
end

-- Assemble in place, so anything already holding the table sees the result.
if type(addon.OptionCategories) == "table" then
    local assembled = Assemble.Run(addon.OptionCategories)
    for i = #addon.OptionCategories, 1, -1 do addon.OptionCategories[i] = nil end
    for i, cat in ipairs(assembled) do addon.OptionCategories[i] = cat end
end
