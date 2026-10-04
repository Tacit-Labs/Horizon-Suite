--[[
    Horizon Suite - Options - Page assembler
    Turns the tagged sections every module registered into dashboard pages.
    A Section tagged `page = "<key>"` (and `card = "<key>"`) is filed under that page of
    its module; sections that share a card merge into one card. Pages come out shared
    first (OptionsPages.SHARED), then the module's own pages in RegisterModulePages order.
    The result is written back into addon.OptionCategories, so the sidebar, detail view,
    search and platform prune read assembled pages without knowing about tags.
    A category with no tagged section passes through unchanged and, with `strict` on, warns.
    Builders must return the same sections whatever the saved settings hold, because the page
    list is fixed at load.
    Must load after every module options file and before OptionsPlatform.lua.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionsPages then return end

local Pages = addon.OptionsPages

local Assemble = {
    warnings = {},
    -- A category with no tagged section is a load-time error.
    strict = true,
    -- dbKey of a row search is jumping to; that row shows even when its parent hides it.
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
-- Saved card state: open/closed, keyed by card id.
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
-- section's page (and its card, on a shared page). A column's title becomes a header row
-- placed before that column's first row, in whichever chunk that row lands.
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
                local title = row[side] and row[side].title
                for _, inner in ipairs(opts) do
                    if inner.type ~= "section" and title then
                        sideCur.rows[#sideCur.rows + 1] = { type = "header", name = title }
                        title = nil
                    end
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
-- Dependent rows: `parent = "<dbKey>"`, optional `parentIs`. ExpandParents indents each child,
-- shows it only while the parent matches, disables it otherwise, and adds a hint to its tooltip.
-- ---------------------------------------------------------------------------

local function ParentMatches(parentRow, row)
    -- A hidden parent counts as unmatched, so a chain collapses from the top down. The
    -- parent's visibleWhen is read now, so it is the final wrapped function when the
    -- parent has a parent of its own.
    if parentRow.visibleWhen and not parentRow.visibleWhen() then return false end
    -- A revealed parent passes its visibleWhen while its own parent is unmatched, so the
    -- chain is checked too; otherwise a grandchild shows enabled under a greyed parent.
    if parentRow._parentMatch and not parentRow._parentMatch() then return false end
    local v
    if parentRow.get then
        v = parentRow.get()
    elseif parentRow.dbKey then
        -- Same fallback the card builder uses for rows without a getter.
        if _G.OptionsData_GetDB then
            v = _G.OptionsData_GetDB(parentRow.dbKey, parentRow.default)
        elseif addon.GetDB then
            v = addon.GetDB(parentRow.dbKey, parentRow.default)
        end
    end
    local want = row.parentIs
    if type(want) == "function" then return want(v) and true or false end
    if want == nil then return v and true or false end
    if type(want) == "boolean" then return (v and true or false) == want end
    return v == want
end

local function IsTrue(fnOrBool)
    if type(fnOrBool) == "function" then return fnOrBool() and true or false end
    return fnOrBool == true
end

-- A row's condition for counting as content of its card or subheading: its own condition
-- and its parent chain, which ExpandParents folds into visibleWhen. nil means always.
local function ContentCondition(r)
    return r.visibleWhen
end

-- A font row's part slots, in display order.
local FONT_ROW_PARTS = { "family", "size", "outline" }

-- The parts of a font row whose key is not the row's own dbKey. Empty for any other row.
local function ExtraParts(r)
    local out = {}
    if r.type ~= "fontRow" or type(r.parts) ~= "table" then return out end
    for _, slot in ipairs(FONT_ROW_PARTS) do
        local part = r.parts[slot]
        if type(part) == "table" and part.dbKey and part.dbKey ~= r.dbKey then out[#out + 1] = part end
    end
    return out
end

-- The part of a font row that holds the row's own dbKey (its family, else its size), or nil.
local function PrimaryPart(r)
    if r.type ~= "fontRow" or type(r.parts) ~= "table" then return nil end
    for _, slot in ipairs(FONT_ROW_PARTS) do
        local part = r.parts[slot]
        if type(part) == "table" and part.dbKey == r.dbKey then return part end
    end
    return nil
end

-- Stands in for one part of a font row when another row names the part's key as its parent.
-- It reads the part's value; everything else (name, visibleWhen, _parentMatch, refreshIds) reads
-- and writes through to the row, so a child's refresh id lands on the row, whose every part
-- setter refreshes it. The part table itself may be shared with the module, so it is never written.
local function PartProxy(row, part)
    local key, default = part.dbKey, part.default
    local get = part.get or function()
        if _G.OptionsData_GetDB then return _G.OptionsData_GetDB(key, default) end
        if addon.GetDB then return addon.GetDB(key, default) end
        return nil
    end
    return setmetatable({ dbKey = key, get = get, _row = row }, { __index = row, __newindex = row })
end

-- Rows are copies made by BuildPage, so wiring them here never touches a module's tables.
-- cardOf maps each row to its card id; a child is indented only under a parent in its card.
local function ExpandParents(rows, moduleKey, pageKey, cardOf)
    local byKey = {}
    for _, r in ipairs(rows) do
        if r.dbKey and r.type ~= "section" then byKey[r.dbKey] = r end
    end
    -- A font row's keys resolve to their part: its own key reads the primary part's getter and
    -- default (a font row has neither), and each other part key reads that part, unless a real
    -- row already holds the key.
    for _, r in ipairs(rows) do
        local primary = PrimaryPart(r)
        if primary and byKey[r.dbKey] == r then byKey[r.dbKey] = PartProxy(r, primary) end
        for _, part in ipairs(ExtraParts(r)) do
            if not byKey[part.dbKey] then byKey[part.dbKey] = PartProxy(r, part) end
        end
    end
    -- A chain that revisits a key is a cycle: warn once per cycle and leave its rows unwired.
    local cyclic, warnedCycle = {}, {}
    for _, r in ipairs(rows) do
        if r.parent and r.dbKey and r.type ~= "section" then
            local path, order, cur = {}, {}, r
            while cur and cur.parent do
                if path[cur.dbKey] then
                    local members, minKey = {}, cur.dbKey
                    local on = false
                    for _, k in ipairs(order) do
                        if k == cur.dbKey then on = true end
                        if on then
                            members[#members + 1] = k
                            if k < minKey then minKey = k end
                        end
                    end
                    for _, k in ipairs(members) do cyclic[k] = true end
                    if not warnedCycle[minKey] then
                        warnedCycle[minKey] = true
                        Warn(("%s › %s: parent cycle between %s"):format(moduleKey, pageKey, table.concat(members, ", ")))
                    end
                    break
                end
                path[cur.dbKey] = true
                order[#order + 1] = cur.dbKey
                cur = byKey[cur.parent]
            end
        end
    end
    for _, r in ipairs(rows) do
        if r.parent and not (r.dbKey and cyclic[r.dbKey]) then
            local p = byKey[r.parent]
            if not p then
                Warn(("%s › %s: '%s' depends on '%s', which is not on this page"):format(moduleKey, pageKey, Label(r), tostring(r.parent)))
            elseif not r.dbKey then
                Warn(("%s › %s: '%s' has a parent but no dbKey"):format(moduleKey, pageKey, Label(r)))
            else
                local child, ownVisible, ownDisabled = r, r.visibleWhen, r.disabled
                local function match() return ParentMatches(p, child) end
                r._parentMatch = match
                if cardOf and cardOf[r] == cardOf[rawget(p, "_row") or p] then r.indent = true end
                r.visibleWhen = function()
                    if ownVisible and not ownVisible() then return false end
                    return match() or Assemble.IsRevealed(child)
                end
                r.disabled = function()
                    if IsTrue(ownDisabled) then return true end
                    return not match()
                end
                local hint = addon.L["DASH_NEEDS_PARENT"]:format(Label(p))
                local tip = r.tooltip
                r.tooltip = function()
                    local base
                    if type(tip) == "function" then base = tip() else base = tip end
                    if match() then return base end
                    if base and base ~= "" then return base .. "\n\n" .. hint end
                    return hint
                end
                local ids = {}
                for _, id in ipairs(p.refreshIds or {}) do ids[#ids + 1] = id end
                ids[#ids + 1] = r.dbKey
                p.refreshIds = ids
            end
        end
    end
    -- A parent refreshes every descendant, not just its direct children, so a change
    -- re-evaluates the whole chain beneath it.
    local kids = {}
    for _, r in ipairs(rows) do
        if r.parent and r.dbKey and not cyclic[r.dbKey] and byKey[r.parent] then
            local list = kids[r.parent] or {}
            list[#list + 1] = r.dbKey
            kids[r.parent] = list
        end
    end
    -- A font row's children hang off its part keys as well as its own key.
    local function ownKeys(r)
        local keys = { r.dbKey }
        for _, part in ipairs(ExtraParts(r)) do keys[#keys + 1] = part.dbKey end
        return keys
    end
    for _, r in ipairs(rows) do
        local hasKids = false
        if r.dbKey then
            for _, k in ipairs(ownKeys(r)) do
                if kids[k] then hasKids = true end
            end
        end
        if hasKids then
            local ids, have = {}, {}
            for _, id in ipairs(r.refreshIds or {}) do
                if not have[id] then have[id] = true; ids[#ids + 1] = id end
            end
            local stack, seen, i = {}, {}, 1
            for _, k in ipairs(ownKeys(r)) do
                if not seen[k] then seen[k] = true; stack[#stack + 1] = k end
            end
            while i <= #stack do
                for _, k in ipairs(kids[stack[i]] or {}) do
                    if not seen[k] then
                        seen[k] = true
                        stack[#stack + 1] = k
                        if not have[k] then
                            have[k] = true
                            ids[#ids + 1] = k
                        end
                        -- Walk on through a font row child's part keys too.
                        local kr = byKey[k]
                        if kr then kr = rawget(kr, "_row") or kr end
                        if kr then
                            for _, pk in ipairs(ownKeys(kr)) do
                                if not seen[pk] then seen[pk] = true; stack[#stack + 1] = pk end
                            end
                        end
                    end
                end
                i = i + 1
            end
            r.refreshIds = ids
        end
    end
end

-- Rows that never count as content of a card or a subheading.
local NOT_CONTENT = { section = true, header = true, talkingHeadPreview = true }

-- The condition under which any of `rows` would show, read from their content conditions when
-- called, since ExpandParents has rewritten them by then. Returns nil when one of them always
-- shows, and `false` when none counts as content.
local function AnyContent(rows)
    local conds = {}
    for _, r in ipairs(rows) do
        if not NOT_CONTENT[r.type] then
            local c = ContentCondition(r)
            if c == nil or c == true then return nil end
            if type(c) == "function" then conds[#conds + 1] = c end
        end
    end
    if #conds == 0 then return false end
    return function()
        for _, c in ipairs(conds) do
            if c() then return true end
        end
        return false
    end
end

-- A card whose rows would all be hidden hides itself, ANDed with its section's own
-- condition. A header-switch card keeps its title, since the switch is its content.
-- A card whose rows are all unconditional is left alone. The dashboard re-reads this when any
-- conditional row in the card is refreshed, which a parent's refreshIds already trigger.
local function HideWhenEmpty(header, rows)
    -- The card's own condition, before the content rule joins it. Search skips cards it hides.
    header.cardWhen = header.visibleWhen
    if header.headerToggle then return end
    local has = AnyContent(rows)
    if type(has) == "function" then header.visibleWhen = Both(header.visibleWhen, has) end
end

-- A subheading shows while any row in its scope would show. A section subheading's scope runs
-- to the next section subheading or the card's end; a column title's runs to the next header
-- of either kind. A subheading over rows that always show keeps no condition.
local function HideEmptySubheadings(rows)
    for i, r in ipairs(rows) do
        if r.type == "header" then
            local scope = {}
            for j = i + 1, #rows do
                local n = rows[j]
                if n.type == "header" and (n._subheading or not r._subheading) then break end
                scope[#scope + 1] = n
            end
            local has = AnyContent(scope)
            if has == false then
                r.visibleWhen = function() return false end
            elseif has then
                r.visibleWhen = has
            end
        end
    end
end

-- The subheading a merged card shows before one of its sections, or nil for none. A section
-- may set `subheading` to a label of its own, or to false for none. Otherwise the section's
-- name is used, unless it matches the name the card itself shows.
local function SubheadingFor(section, cardName)
    local sub = section.subheading
    if sub == false then return nil end
    if sub ~= nil then return sub end
    if Resolve(section.name) == Resolve(cardName) then return nil end
    return section.name
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

    local out, cardOf, cardList = {}, {}, {}
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
        local members = {}
        cardList[#cardList + 1] = { header = header, rows = members }

        for _, chunk in ipairs(card.chunks) do
            local kept = {}
            for _, row in ipairs(chunk.rows) do
                -- Rows the client cannot use are dropped here, so subheadings, card auto-hide
                -- and parent wiring never see them.
                if HasCapability(row.requires) then
                    local r = Copy(row)
                    -- A merged card has one header, so each section's own condition moves onto its rows.
                    if merged and chunk.section.visibleWhen then
                        r.visibleWhen = Both(chunk.section.visibleWhen, r.visibleWhen)
                    end
                    kept[#kept + 1] = r
                end
            end
            local sub = merged and #kept > 0 and SubheadingFor(chunk.section, header.name)
            if sub then
                local h = { type = "header", name = sub, _subheading = true }
                out[#out + 1] = h
                members[#members + 1] = h
            end
            for _, r in ipairs(kept) do
                out[#out + 1] = r
                members[#members + 1] = r
                cardOf[r] = cardId
            end
        end
    end

    ExpandParents(out, moduleKey, pageKey, cardOf)
    for _, c in ipairs(cardList) do
        HideEmptySubheadings(c.rows)
        HideWhenEmpty(c.header, c.rows)
    end
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
