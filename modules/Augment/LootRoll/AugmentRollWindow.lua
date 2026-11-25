--[[
    Horizon Suite - Augment / Loot Roll - Roll List Window
    A small movable window with one card per open roll: who chose what, and
    once the roll ends, who won it.

    The button and tally-line tooltips answer "who needed this?" for one roll
    at a time, and only while the mouse is on it. In a raid with several rolls
    open at once, a player asked for something they can glance at instead
    (feature request, "Check N&G rolls player"). This is that.

    Data comes from the roll rows (R.GetActiveRolls), which already hold each
    roll's loot-history summary. A roll whose history cannot be matched shows
    no names (the tally's fail-closed join).

    Each card reads like a standings table, not a set of lists:

        [icon] Thunderfury, Blessed Blade              Result
               Sarah won with Need 91. You rolled 47.
          [N]  Sarah                       ======== 91
          [N]  Mikhail (you)               ====     47
          [G]  Ines                        ======   63
          [+]  Passed (14)

    Winner first, then Need above Transmog above Greed, then the highest roll.
    Pass and the undecided fold into one line each (click to open): in a raid
    they are the long, least interesting part. Fold state is saved per kind,
    not per roll.

    WHEN A ROLL ENDS its card flips to the result. The roll frame itself closes
    the moment the roll ends, so this is the only place the outcome stays on
    screen — but only briefly. Once every roll has ended and every result is
    in, the window lingers for a few seconds (lootRollWindowLinger), then fades
    and clears itself. It is a pop-up for the moment, not a panel that stays
    (feedback, 2026-11-25). Hovering it holds it open; a new roll cancels the
    countdown.

    The roll rows forget a roll when it ends, so the window keeps its own list
    of entries. While a roll is open its entry mirrors the row; once the row is
    gone the entry looks its drop up again by the key the row recorded
    (encounterID + drop key), which names one drop exactly.

    BuildCards is pure (no frames) so the test harness can check it.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local Y = addon.Augment
local R = Y.Roll
R.Window = R.Window or {}
local W = R.Window
local L = addon.L

-- ============================================================================
-- STATE KEYS
-- ============================================================================

Y.DB_KEYS.lootRollShowWindow      = true
Y.DB_KEYS.lootRollWindowPoint     = true
Y.DB_KEYS.lootRollWindowRelPoint  = true
Y.DB_KEYS.lootRollWindowX         = true
Y.DB_KEYS.lootRollWindowY         = true

-- What each choice looks like on a card. `rank` orders the standings (higher
-- first); `rollType` picks the roll button's icon for the row.
W.PICKS = {
    need     = { rank = 5, rollType = R.ROLL_NEED,     label = "LOOT_ROLL_TALLY_NEED",     color = { 0.25, 0.75, 0.25 } },
    needOff  = { rank = 4, rollType = R.ROLL_NEED,     label = "LOOT_ROLL_TALLY_NEED_OFF", color = { 0.56, 0.82, 0.56 } },
    transmog = { rank = 3, rollType = R.ROLL_TRANSMOG, label = "LOOT_ROLL_TALLY_TRANSMOG", color = { 1.00, 0.50, 1.00 } },
    greed    = { rank = 2, rollType = R.ROLL_GREED,    label = "LOOT_ROLL_TALLY_GREED",    color = { 0.90, 0.80, 0.32 } },
    pass     = { rank = 0, rollType = R.ROLL_PASS,     label = "LOOT_ROLL_TALLY_PASS",     color = { 0.60, 0.60, 0.60 } },
}
-- Choices that make up the standings, in rank order.
W.STANDING_BUCKETS = { "need", "needOff", "transmog", "greed" }

-- Folded lines under the standings. Both start collapsed.
W.FOLDS = {
    { key = "pass",    label = "LOOT_ROLL_WINDOW_PASSED",         fallback = "Passed (%d)" },
    { key = "waiting", label = "LOOT_ROLL_WINDOW_STILL_CHOOSING", fallback = "Still choosing (%d)", openOnly = true },
}

for _, fold in ipairs(W.FOLDS) do
    Y.DB_KEYS["lootRollWindowCollapsed_" .. fold.key] = true
end
Y.DB_KEYS.lootRollWindowLinger = true
Y.DB_KEYS.lootRollWindowWidth  = true
Y.DB_KEYS.lootRollWindowHeight = true
Y.DB_KEYS.lootRollWindowScale  = true

local function Clamped(key, fallback)
    local D = addon.AUGMENT_DEFAULTS
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS[key]
    local v = tonumber(R.GetDB(key, D and D[key])) or fallback
    if lim then v = math.max(lim.min, math.min(lim.max, v)) end
    return v
end

--- Window width, set by dragging the corner grip.
--- @return number
function W.GetWidth() return Clamped("lootRollWindowWidth", 260) end

--- Tallest the window grows before it scrolls, set by the corner grip.
--- @return number
function W.GetMaxHeight() return Clamped("lootRollWindowHeight", 480) end

--- The window's own scale, independent of the roll frames' scale.
--- @return number
function W.GetScale() return Clamped("lootRollWindowScale", 1.0) end

-- A finished roll whose winner never reaches loot history should not hold the
-- window open forever: after this long it counts as settled anyway.
W.RESULT_WAIT = 15
-- Length of the closing fade, inside the linger time.
W.FADE = 0.5

--- Seconds the window stays up after the last result arrives.
--- @return number
function W.GetLinger()
    local D = addon.AUGMENT_DEFAULTS
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS.lootRollWindowLinger
    local v = tonumber(R.GetDB("lootRollWindowLinger", D and D.lootRollWindowLinger)) or 8
    if lim then v = math.max(lim.min, math.min(lim.max, v)) end
    return v
end

--- Is every roll over, and does every finished roll have its outcome?
--- @param list table  Window entries
--- @return boolean allFinished, boolean allSettled
function W.ExpiryState(list)
    if #list == 0 then return false, false end
    local settled = true
    for _, e in ipairs(list) do
        if not e.finished then return false, false end
        local s = e.summary
        local known = s and (s.allPassed or s.winnerName)
        -- No key and no demo result: nothing more will ever arrive.
        local hopeless = not (e.dropKey or e.demoResult)
        if not (known or hopeless) then settled = false end
    end
    return true, settled
end

local function Text(key, fallback)
    return (L and L[key]) or fallback
end

--- @return boolean
function W.IsEnabled()
    local D = addon.AUGMENT_DEFAULTS
    if not (addon.Platform and addon.Platform.Has("lootHistory")) then return false end
    return R.GetDB("lootRollShowWindow", D and D.lootRollShowWindow) == true
end

--- @param key string  Fold key ("pass" or "waiting")
--- @return boolean
function W.IsCollapsed(key)
    local v = R.GetDB("lootRollWindowCollapsed_" .. key, nil)
    if v == nil then return true end
    return v and true or false
end

--- @param key string  Fold key
--- @return nil
function W.ToggleCollapsed(key)
    if addon.SetDB then addon.SetDB("lootRollWindowCollapsed_" .. key, not W.IsCollapsed(key)) end
    W.Refresh()
end

-- ============================================================================
-- ENTRIES
-- ============================================================================

--- Merge the open rolls into the window's entries.
--- Open rolls update (or add) their entry; an entry whose roll is no longer
--- open is marked finished and asks `resolve` for its final summary.
--- @param list table  Entries, updated in place, in the order rolls appeared
--- @param rolls table  From R.GetActiveRolls
--- @param resolve function(entry) -> summary|nil  For finished entries
--- @return table list
function W.SyncEntries(list, rolls, resolve)
    local open = {}
    for _, r in ipairs(rolls or {}) do
        if r.rollID ~= nil then open[r.rollID] = r end
    end
    for _, e in ipairs(list) do
        local r = open[e.rollID]
        if r then
            e.name, e.quality, e.summary = r.name, r.quality, r.summary
            e.icon, e.itemLink = r.icon or e.icon, r.itemLink or e.itemLink
            e.dropKey = r.dropKey or e.dropKey
            e.demoResult = r.demoResult
            e.finished = false
            open[e.rollID] = nil
        else
            e.finished = true
            local final = resolve and resolve(e)
            if final then e.summary = final end
        end
    end
    for _, r in ipairs(rolls or {}) do
        if r.rollID ~= nil and open[r.rollID] then
            list[#list + 1] = {
                rollID = r.rollID, name = r.name, quality = r.quality,
                icon = r.icon, itemLink = r.itemLink,
                summary = r.summary, dropKey = r.dropKey, demoResult = r.demoResult,
                finished = false,
            }
        end
    end
    return list
end

--- Drop finished entries, keeping open ones.
--- @param list table
--- @return table list
function W.DropFinished(list)
    for i = #list, 1, -1 do
        if list[i].finished then table.remove(list, i) end
    end
    return list
end

-- ============================================================================
-- MODEL
-- ============================================================================

--- Everyone who chose Need, Transmog or Greed, best first: the winner, then
--- by choice (Need beats off-spec Need beats Transmog beats Greed), then the
--- highest roll, then the name.
--- @param summary table|nil  From R.Tally.Summarise
--- @return table list  Array of { player, bucket }
function W.Standings(summary)
    local out = {}
    if not (summary and summary.players) then return out end
    local winnerName = summary.winnerName
    for _, bucket in ipairs(W.STANDING_BUCKETS) do
        for _, p in ipairs(summary.players[bucket] or {}) do
            local won = p.isWinner or (winnerName ~= nil and winnerName ~= "" and p.name == winnerName)
            out[#out + 1] = { player = p, bucket = bucket, winner = won and true or false }
        end
    end
    table.sort(out, function(a, b)
        if a.winner ~= b.winner then return a.winner end
        local ra, rb = W.PICKS[a.bucket].rank, W.PICKS[b.bucket].rank
        if ra ~= rb then return ra > rb end
        local na, nb = a.player.roll or -1, b.player.roll or -1
        if na ~= nb then return na > nb end
        return (a.player.name or "") < (b.player.name or "")
    end)
    return out
end

local function ColoredName(p)
    local r, g, b = R.Tally.ClassColor(p.class)
    local name = (p.name and p.name ~= "") and p.name or "?"
    return ("|cFF%02X%02X%02X%s|r"):format(
        math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), name)
end

local function FindSelf(summary)
    for bucket, list in pairs(summary.players or {}) do
        for _, p in ipairs(list) do
            if p.isSelf then return p, bucket end
        end
    end
    return nil
end

--- The one line under the item name: where the roll stands, or how it ended.
--- @param e table  A window entry
--- @return string text, string tone  tone is "result", "info" or "muted"
function W.SummaryLine(e)
    local summary, finished = e.summary, e.finished and true or false
    if summary and summary.allPassed then
        return Text("LOOT_ROLL_TALLY_ALL_PASSED", "Everyone passed"), "info"
    end

    if finished then
        if not (summary and summary.winnerName) then
            if e.dropKey or e.demoResult then
                -- History records the winner a moment after the roll closes.
                return Text("LOOT_ROLL_WINDOW_PENDING", "Waiting for the result..."), "muted"
            end
            return Text("LOOT_ROLL_WINDOW_NO_RESULT", "Result unavailable"), "muted"
        end
        local winner, winnerBucket
        for _, s in ipairs(W.Standings(summary)) do
            if s.winner then winner, winnerBucket = s.player, s.bucket break end
        end
        winner = winner or { name = summary.winnerName, class = summary.winnerClass, roll = summary.winnerRoll }
        local roll = winner.roll or summary.winnerRoll
        local choice = winnerBucket and Text(W.PICKS[winnerBucket].label, winnerBucket)

        if winner.isSelf then
            if roll and choice then
                return Text("LOOT_ROLL_WINDOW_YOU_WON", "You won with %s %d!"):format(choice, roll), "result"
            end
            return Text("LOOT_ROLL_WINDOW_YOU_WON_NO_ROLL", "You won!"), "result"
        end

        local text
        if roll and choice then
            text = Text("LOOT_ROLL_WINDOW_WON", "%s won with %s %d."):format(ColoredName(winner), choice, roll)
        else
            text = Text("LOOT_ROLL_WINDOW_WON_NO_ROLL", "%s won."):format(ColoredName(winner))
        end
        local me, myBucket = FindSelf(summary)
        if me and myBucket == "pass" then
            text = text .. " " .. Text("LOOT_ROLL_WINDOW_YOU_PASSED", "You passed.")
        elseif me and me.roll then
            text = text .. " " .. Text("LOOT_ROLL_WINDOW_YOU_ROLLED", "You rolled %d."):format(me.roll)
        end
        return text, "result"
    end

    if not (summary and summary.players) then
        -- No history match (or the tally is off): say so rather than an empty
        -- card that looks like "nobody rolled".
        return Text("LOOT_ROLL_WINDOW_NO_DATA", "No roll data yet"), "muted"
    end
    if summary.isTied then
        return Text("LOOT_ROLL_WINDOW_TIED", "Tied, rolling again"), "info"
    end
    local total, waiting = summary.total or 0, (summary.counts and summary.counts.waiting) or 0
    if waiting > 0 then
        return Text("LOOT_ROLL_WINDOW_CHOSEN", "%d of %d have chosen"):format(total - waiting, total), "info"
    end
    return Text("LOOT_ROLL_WINDOW_ALL_CHOSEN", "Everyone has chosen, rolling..."), "info"
end

--- One card for one entry.
--- @param e table  A window entry
--- @param isCollapsed function(key) -> boolean
--- @return table card  { rollID, name, quality, icon, itemLink, finished, status, line, tone, rows }
---         rows: { kind = "player", player, bucket, winner, dim } | { kind = "fold", fold, count, collapsed, text }
function W.BuildCard(e, isCollapsed)
    local finished = e.finished and true or false
    local card = {
        rollID = e.rollID, name = e.name or "", quality = e.quality,
        icon = e.icon, itemLink = e.itemLink, finished = finished,
        status = finished and Text("LOOT_ROLL_WINDOW_RESULT", "Result")
                          or  Text("LOOT_ROLL_WINDOW_ROLLING", "Rolling"),
        rows = {},
    }
    card.line, card.tone = W.SummaryLine(e)

    local summary = e.summary
    -- Names only once there is something to show: an open roll with data, or
    -- a finished one whose winner is known. Everyone passing needs no list.
    local hasNames = summary and summary.players and not summary.allPassed
        and (not finished or summary.winnerName)
    if not hasNames then return card end

    for _, s in ipairs(W.Standings(summary)) do
        card.rows[#card.rows + 1] = { kind = "player", player = s.player, bucket = s.bucket, winner = s.winner }
    end
    for _, fold in ipairs(W.FOLDS) do
        if not (fold.openOnly and finished) then
            local list = R.Tally.PlayersIn(summary, { fold.key })
            if #list > 0 then
                local collapsed = isCollapsed and isCollapsed(fold.key) or false
                card.rows[#card.rows + 1] = {
                    kind = "fold", fold = fold.key, count = #list, collapsed = collapsed,
                    text = Text(fold.label, fold.fallback):format(#list),
                }
                if not collapsed then
                    for _, p in ipairs(list) do
                        card.rows[#card.rows + 1] = { kind = "player", player = p, bucket = fold.key, dim = true }
                    end
                end
            end
        end
    end
    return card
end

--- Every entry as a card, oldest roll first.
--- @param list table  From W.SyncEntries
--- @param isCollapsed function(key) -> boolean
--- @return table cards
function W.BuildCards(list, isCollapsed)
    local cards = {}
    for _, e in ipairs(list or {}) do cards[#cards + 1] = W.BuildCard(e, isCollapsed) end
    return cards
end

-- ============================================================================
-- FRAME
-- Everything below needs the WoW UI; the test harness never reaches it.
-- ============================================================================

-- Width and max height are the player's (W.GetWidth / W.GetMaxHeight); these
-- are the floor the corner grip can shrink to.
local MIN_WIDTH    = 220
local MIN_HEIGHT   = 120
local TITLE_HEIGHT = 22
local PAD          = 6    -- window edge to cards
local CARD_PAD     = 6    -- card edge to its contents
local CARD_GAP     = 6
local ICON         = 30
local PICK_ICON    = 13
local BAR_WIDTH    = 46
local NUM_WIDTH    = 24

local DEFAULT_POINT, DEFAULT_REL, DEFAULT_X, DEFAULT_Y = "TOPLEFT", "CENTER", 260, 220

local window, scroll, content, font, smallFont, titleFont, emptyText
local cardPool = {}
local sizing = false   -- corner grip held: Refresh leaves the size alone
local manuallyOpen = false   -- /h roll list, or the options button
local dismissed    = false   -- closed with [x] until the next new roll
local entries      = {}      -- open and finished rolls, see W.SyncEntries
local finishedAt   = nil     -- GetTime() when every roll had ended
local settledAt    = nil     -- GetTime() when every result was in: the linger starts here

local function FontSize() return math.max(9, R.GetFontSize() - 1) end
local function RowHeight() return FontSize() + 7 end

local function UpdateFonts()
    if not font then return end
    local size = FontSize()
    font:SetFont(R.GetFontPath(), size, R.GetFontFlags())
    smallFont:SetFont(R.GetFontPath(), math.max(8, size - 2), R.GetFontFlags())
    titleFont:SetFont(R.GetFontPath(), size + 1, R.GetFontFlags())
end

local function SavePosition()
    if not (window and addon.SetDB) then return end
    local point, _, relPoint, x, y = window:GetPoint(1)
    if not point then return end
    addon.SetDB("lootRollWindowPoint", point)
    addon.SetDB("lootRollWindowRelPoint", relPoint)
    addon.SetDB("lootRollWindowX", math.floor((x or 0) + 0.5))
    addon.SetDB("lootRollWindowY", math.floor((y or 0) + 0.5))
end

local function RestorePosition()
    if not window then return end
    local point    = R.GetDB("lootRollWindowPoint", nil) or DEFAULT_POINT
    local relPoint = R.GetDB("lootRollWindowRelPoint", nil) or DEFAULT_REL
    local x        = tonumber(R.GetDB("lootRollWindowX", nil)) or DEFAULT_X
    local y        = tonumber(R.GetDB("lootRollWindowY", nil)) or DEFAULT_Y
    window:ClearAllPoints()
    window:SetPoint(point, UIParent, relPoint, x, y)
end

--- @return nil
function W.ResetPosition()
    if addon.SetDB then
        addon.SetDB("lootRollWindowPoint", nil)
        addon.SetDB("lootRollWindowRelPoint", nil)
        addon.SetDB("lootRollWindowX", nil)
        addon.SetDB("lootRollWindowY", nil)
        addon.SetDB("lootRollWindowWidth", nil)
        addon.SetDB("lootRollWindowHeight", nil)
    end
    RestorePosition()
    W.Refresh()
end

local function Backdrop(f, bg, border)
    if not f.SetBackdrop then return end
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    f:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function QualityColor(quality)
    local colors = R.QUALITY_COLORS
    return colors and (colors[tonumber(quality) or 1] or colors[1]) or { 1, 1, 1 }
end

-- One row inside a card: a player, or a fold line.
local function CreateRow(card)
    local b = CreateFrame("Button", nil, card)

    local wash = b:CreateTexture(nil, "BACKGROUND")
    wash:SetAllPoints(b)
    wash:SetColorTexture(1, 0.82, 0, 0.12)
    wash:Hide()
    b.wash = wash

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(b)
    hl:SetColorTexture(1, 1, 1, 0.06)
    b.hl = hl

    local pick = b:CreateTexture(nil, "ARTWORK")
    pick:SetSize(PICK_ICON, PICK_ICON)
    pick:SetPoint("LEFT", b, "LEFT", CARD_PAD, 0)
    b.pick = pick

    local num = b:CreateFontString(nil, "OVERLAY")
    num:SetFontObject(font)
    num:SetJustifyH("RIGHT")
    num:SetWidth(NUM_WIDTH)
    num:SetPoint("RIGHT", b, "RIGHT", -CARD_PAD, 0)
    b.num = num

    local bar = CreateFrame("StatusBar", nil, b)
    bar:SetSize(BAR_WIDTH, 4)
    bar:SetPoint("RIGHT", num, "LEFT", -5, 0)
    bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar:SetMinMaxValues(0, 100)
    local barBg = bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetAllPoints(bar)
    barBg:SetColorTexture(1, 1, 1, 0.08)
    b.bar = bar

    local name = b:CreateFontString(nil, "OVERLAY")
    name:SetFontObject(font)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    name:SetPoint("LEFT", pick, "RIGHT", 5, 0)
    name:SetPoint("RIGHT", bar, "LEFT", -5, 0)
    b.name = name

    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        if self.fold then W.ToggleCollapsed(self.fold) end
    end)
    return b
end

local function CreateCard()
    local c = CreateFrame("Frame", nil, content, "BackdropTemplate")
    Backdrop(c, { 1, 1, 1, 0.03 }, { 1, 1, 1, 0.10 })

    -- Quality colour along the top edge, as on the roll frame.
    local edge = c:CreateTexture(nil, "ARTWORK")
    edge:SetPoint("TOPLEFT", c, "TOPLEFT", 1, -1)
    edge:SetPoint("TOPRIGHT", c, "TOPRIGHT", -1, -1)
    edge:SetHeight(2)
    edge:SetColorTexture(1, 1, 1, 1)
    c.edge = edge

    -- The item: its tooltip on hover, shift-click links it like any item.
    local icon = CreateFrame("Button", nil, c)
    icon:SetSize(ICON, ICON)
    icon:SetPoint("TOPLEFT", c, "TOPLEFT", CARD_PAD, -CARD_PAD - 1)
    icon.tex = icon:CreateTexture(nil, "ARTWORK")
    icon.tex:SetAllPoints(icon)
    icon.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    icon:SetScript("OnEnter", function(self)
        if not (c.itemLink and GameTooltip) then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        pcall(GameTooltip.SetHyperlink, GameTooltip, c.itemLink)
        GameTooltip:Show()
    end)
    icon:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    icon:RegisterForClicks("LeftButtonUp")
    icon:SetScript("OnClick", function()
        if c.itemLink and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink then
            ChatEdit_InsertLink(c.itemLink)
        end
    end)
    c.icon = icon

    local status = c:CreateFontString(nil, "OVERLAY")
    status:SetFontObject(smallFont)
    status:SetJustifyH("RIGHT")
    status:SetPoint("TOPRIGHT", c, "TOPRIGHT", -CARD_PAD, -CARD_PAD - 2)
    c.status = status

    local name = c:CreateFontString(nil, "OVERLAY")
    name:SetFontObject(font)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 6, -1)
    name:SetPoint("RIGHT", status, "LEFT", -6, 0)
    c.name = name

    local line = c:CreateFontString(nil, "OVERLAY")
    line:SetFontObject(smallFont)
    line:SetJustifyH("LEFT")
    line:SetJustifyV("TOP")
    line:SetWordWrap(true)
    line:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    -- A fixed width, so GetStringHeight is right on the first draw, before
    -- the card has been laid out.
    line:SetWidth(W.GetWidth() - 2 * PAD - 2 * CARD_PAD - ICON - 6)
    c.line = line

    c.rows = {}
    return c
end

local function DrawRow(b, row)
    b.fold = nil
    b.wash:Hide()
    b.bar:Hide()
    b.num:SetText("")
    b.pick:Show()
    b:SetAlpha(1)

    if row.kind == "fold" then
        b.fold = row.fold
        b:EnableMouse(true)
        b.hl:Show()
        b.pick:SetTexture(row.collapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
        b.pick:SetTexCoord(0, 1, 0, 1)
        b.name:SetText(row.text)
        b.name:SetTextColor(0.6, 0.6, 0.6, 1)
        return
    end

    b:EnableMouse(false)
    b.hl:Hide()
    local p, pick = row.player, W.PICKS[row.bucket]
    b.pick:SetTexCoord(0, 1, 0, 1)
    if not (pick and pick.rollType and R.ApplyButtonArt(b.pick, pick.rollType, R.BUTTON_ATLASES)) then
        b.pick:Hide()
    end
    b.name:SetText(R.Tally.FormatPlayerName(p))
    b.name:SetTextColor(1, 1, 1, 1)

    if p.roll then
        b.num:SetText(tostring(p.roll))
        local color = pick and pick.color or { 0.8, 0.8, 0.8 }
        if row.winner then
            b.num:SetTextColor(1, 0.82, 0, 1)
            b.bar:SetStatusBarColor(1, 0.82, 0, 1)
        else
            b.num:SetTextColor(0.85, 0.85, 0.85, 1)
            b.bar:SetStatusBarColor(color[1], color[2], color[3], 0.9)
        end
        b.bar:SetValue(math.max(0, math.min(100, p.roll)))
        b.bar:Show()
    end
    if row.winner then b.wash:Show() end
    if row.dim then b:SetAlpha(0.6) end
end

local TONE_COLORS = {
    result = { 1, 0.82, 0 },
    info   = { 0.85, 0.85, 0.85 },
    muted  = { 0.6, 0.6, 0.6 },
}

-- Fill one card and return its height.
local function DrawCard(c, card)
    local qc = QualityColor(card.quality)
    c.itemLink = card.itemLink
    c.edge:SetVertexColor(qc[1], qc[2], qc[3], 0.9)
    c.icon.tex:SetTexture(card.icon or 134400)
    c.name:SetText(card.name)
    c.name:SetTextColor(qc[1], qc[2], qc[3], 1)
    c.status:SetText(card.status or "")
    if card.finished then
        c.status:SetTextColor(0.95, 0.65, 0.25, 1)
    else
        c.status:SetTextColor(0.6, 0.6, 0.6, 1)
    end
    -- Re-set every draw: the width follows the corner grip.
    c.line:SetWidth(W.GetWidth() - 2 * PAD - 2 * CARD_PAD - ICON - 6)
    c.line:SetText(card.line or "")
    local tc = TONE_COLORS[card.tone] or TONE_COLORS.info
    c.line:SetTextColor(tc[1], tc[2], tc[3], 1)

    -- The header is as tall as the icon, or the name and a wrapped line.
    local textH = (c.name:GetStringHeight() or 0) + 3 + (c.line:GetStringHeight() or 0)
    local headH = CARD_PAD + 1 + math.max(ICON, textH) + 4

    local h, y = RowHeight(), headH
    for i, row in ipairs(card.rows) do
        local b = c.rows[i]
        if not b then b = CreateRow(c); c.rows[i] = b end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", c, "TOPLEFT", 1, -y)
        b:SetPoint("TOPRIGHT", c, "TOPRIGHT", -1, -y)
        b:SetHeight(h)
        DrawRow(b, row)
        b:Show()
        y = y + h
    end
    for i = #card.rows + 1, #c.rows do c.rows[i]:Hide() end
    return y + CARD_PAD
end

local function Build()
    if window then return end

    font = CreateFont("HorizonSuiteRollWindowFont")
    smallFont = CreateFont("HorizonSuiteRollWindowSmallFont")
    titleFont = CreateFont("HorizonSuiteRollWindowTitleFont")
    UpdateFonts()

    window = CreateFrame("Frame", "HorizonSuiteRollWindow", UIParent, "BackdropTemplate")
    window:SetSize(W.GetWidth(), 120)
    window:SetFrameStrata("MEDIUM")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:Hide()
    Backdrop(window, { 0.05, 0.05, 0.07, 0.9 }, { 1, 1, 1, 0.15 })

    -- Title bar doubles as the drag handle.
    local title = CreateFrame("Frame", nil, window)
    title:SetPoint("TOPLEFT", window, "TOPLEFT", 0, 0)
    title:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
    title:SetHeight(TITLE_HEIGHT)
    title:EnableMouse(true)
    title:RegisterForDrag("LeftButton")
    title:SetScript("OnDragStart", function() window:StartMoving() end)
    title:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        SavePosition()
    end)

    local titleText = title:CreateFontString(nil, "OVERLAY")
    titleText:SetFontObject(titleFont)
    titleText:SetPoint("LEFT", title, "LEFT", PAD + 2, 0)
    titleText:SetText(Text("LOOT_ROLL_WINDOW_TITLE", "Loot rolls"))
    titleText:SetTextColor(0.95, 0.65, 0.25, 1)

    local close = CreateFrame("Button", nil, title, "UIPanelCloseButton")
    close:SetSize(20, 20)
    close:SetPoint("RIGHT", title, "RIGHT", -1, 0)
    close:SetScript("OnClick", function()
        manuallyOpen = false
        dismissed = true
        W.DropFinished(entries)
        window:Hide()
    end)

    -- Linger, then fade and clear. Hover holds it: the countdown restarts
    -- from the moment the mouse leaves, so a result is never pulled away
    -- from under someone reading it.
    local elapsed = 0
    window:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + (dt or 0)
        if elapsed < 0.1 then return end
        elapsed = 0
        W.Tick()
    end)

    -- Corner grip: drag to set the width and the tallest the window may grow.
    -- Height otherwise follows the content, so what is saved is the cap.
    window:SetResizable(true)
    if window.SetResizeBounds then
        window:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, 480, 900)
    elseif window.SetMinResize then
        window:SetMinResize(MIN_WIDTH, MIN_HEIGHT)
        if window.SetMaxResize then window:SetMaxResize(480, 900) end
    end
    local grip = CreateFrame("Button", nil, window)
    grip:SetSize(14, 14)
    grip:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -1, 1)
    grip:SetFrameLevel(window:GetFrameLevel() + 10)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        sizing = true
        window:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function()
        if not sizing then return end
        window:StopMovingOrSizing()
        sizing = false
        if addon.SetDB then
            addon.SetDB("lootRollWindowWidth", math.floor(window:GetWidth() + 0.5))
            addon.SetDB("lootRollWindowHeight", math.floor(window:GetHeight() + 0.5))
        end
        SavePosition()
        W.Refresh()
    end)
    window:SetScript("OnSizeChanged", function(self, w)
        if content then content:SetWidth(math.max(1, (w or self:GetWidth()) - 2 * PAD)) end
    end)

    -- Grows to fit up to the saved height, then scrolls with the mouse wheel.
    scroll = CreateFrame("ScrollFrame", nil, window)
    scroll:SetPoint("TOPLEFT", window, "TOPLEFT", PAD, -(TITLE_HEIGHT + 2))
    scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -PAD, PAD)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = self:GetVerticalScrollRange() or 0
        local v = (self:GetVerticalScroll() or 0) - delta * RowHeight() * 3
        self:SetVerticalScroll(math.max(0, math.min(max, v)))
    end)

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(W.GetWidth() - 2 * PAD, 1)
    scroll:SetScrollChild(content)

    emptyText = content:CreateFontString(nil, "OVERLAY")
    emptyText:SetFontObject(font)
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -4)
    emptyText:SetTextColor(0.6, 0.6, 0.6, 1)
    emptyText:SetText(Text("LOOT_ROLL_WINDOW_EMPTY", "No rolls in progress"))

    RestorePosition()
end

local function Now() return GetTime and GetTime() or 0 end

-- Track when every roll ended and when every result was in.
local function UpdateExpiry()
    local allFinished, allSettled = W.ExpiryState(entries)
    if not allFinished then
        finishedAt, settledAt = nil, nil
        return
    end
    local now = Now()
    finishedAt = finishedAt or now
    if not settledAt and (allSettled or now - finishedAt >= W.RESULT_WAIT) then
        settledAt = now
    end
end

local function Expire()
    finishedAt, settledAt = nil, nil
    manuallyOpen = false
    W.DropFinished(entries)
    if window then window:Hide() end
end

--- Countdown step, run from the window's OnUpdate.
--- @return nil
function W.Tick()
    if not (window and window:IsShown()) then return end
    UpdateExpiry()
    if not settledAt then return end
    local now = Now()
    if window:IsMouseOver() then
        settledAt = now
        window:SetAlpha(R.GetOpacity())
        return
    end
    local left = W.GetLinger() - (now - settledAt)
    if left <= 0 then
        Expire()
    elseif left < W.FADE then
        window:SetAlpha(R.GetOpacity() * left / W.FADE)
    end
end

local function ShouldShow(hasEntries)
    if manuallyOpen then return true end
    if dismissed or not W.IsEnabled() then return false end
    return hasEntries
end

-- Final summary for a roll whose row has gone.
local function ResolveFinished(e)
    if e.demoResult then return e.demoResult end
    if e.dropKey and R.Tally then
        local drop = R.Tally.FindDrop(e.dropKey.encounterID, e.dropKey.lootListID)
        if drop then return R.Tally.Summarise(drop) end
    end
    return nil
end

--- Redraw from the live rows and kept results. Cheap enough to call on every
--- tally update.
--- @return nil
function W.Refresh()
    local rolls = R.GetActiveRolls and R.GetActiveRolls() or {}
    W.SyncEntries(entries, rolls, ResolveFinished)
    if #entries == 0 then dismissed = false end
    UpdateExpiry()

    if not ShouldShow(#entries > 0) then
        if window then window:Hide() end
        return
    end
    Build()

    local cards = W.BuildCards(entries, W.IsCollapsed)
    local y = 0
    for i, card in ipairs(cards) do
        local c = cardPool[i]
        if not c then c = CreateCard(); cardPool[i] = c end
        c:ClearAllPoints()
        c:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        c:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
        local h = DrawCard(c, card)
        c:SetHeight(h)
        c:Show()
        y = y + h + CARD_GAP
    end
    for i = #cards + 1, #cardPool do cardPool[i]:Hide() end
    emptyText:SetShown(#cards == 0)
    if #cards == 0 then y = RowHeight() + 8 else y = y - CARD_GAP end

    content:SetHeight(math.max(1, y))
    if not sizing then
        window:SetWidth(W.GetWidth())
        content:SetWidth(W.GetWidth() - 2 * PAD)
        window:SetHeight(math.max(MIN_HEIGHT, math.min(W.GetMaxHeight(), TITLE_HEIGHT + 2 + y + PAD)))
    end
    local max = scroll:GetVerticalScrollRange() or 0
    if (scroll:GetVerticalScroll() or 0) > max then scroll:SetVerticalScroll(max) end

    window:SetScale(W.GetScale())
    window:SetAlpha(R.GetOpacity())
    window:Show()
end

--- A roll got a row. A NEW roll clears the previous rolls' results (they
--- belong to the last boss) and brings a closed window back; the same roll
--- being redrawn does neither.
--- @param rollID number
--- @return nil
function W.OnRollShown(rollID)
    local known = false
    for _, e in ipairs(entries) do
        if e.rollID == rollID then known = true end
    end
    if rollID and not known then
        W.DropFinished(entries)
        dismissed = false
    end
    W.Refresh()
end

--- Open or close the window by hand. Works with the option off and with no
--- rolls open, so a player can place it before the raid.
--- @return nil
function W.Toggle()
    if window and window:IsShown() then
        manuallyOpen = false
        dismissed = true
        W.DropFinished(entries)
        window:Hide()
        return
    end
    manuallyOpen = true
    dismissed = false
    W.Refresh()
end

--- Open the window regardless of the option, as /h roll list does. Used by
--- the played demo so the result view is always on screen for it.
--- @return nil
function W.Open()
    manuallyOpen = true
    dismissed = false
    W.Refresh()
end

--- Forget every roll and result.
--- @return nil
function W.Clear()
    entries = {}
    finishedAt, settledAt = nil, nil
    W.Refresh()
end

--- Re-apply fonts, scale and visibility after an options change.
--- @return nil
function W.ApplyOptions()
    UpdateFonts()
    W.Refresh()
end

--- @return nil
function W.Hide()
    manuallyOpen = false
    entries = {}
    finishedAt, settledAt = nil, nil
    if window then window:Hide() end
end
