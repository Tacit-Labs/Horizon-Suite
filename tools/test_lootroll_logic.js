#!/usr/bin/env node
/**
 * Executable checks for the pure-logic half of Augment's loot roll module:
 * roll-state bucketing, the loot-history join, tally formatting and item badges.
 *
 * Why this exists. None of that logic can be exercised without a live group
 * rolling on loot, which makes it exactly the code most likely to ship wrong.
 * It is also pure — no frames, no secure calls — so it runs fine in a plain Lua
 * VM with the WoW globals stubbed. The shipped locale file is loaded too, so
 * the format templates under test are the real ones.
 *
 * Covers in particular:
 *   - WoW: Forever has no specialisations, so an off-spec Need must collapse
 *     into Need rather than rendering an "off-spec" label for a client that
 *     has no off-spec.
 *   - ResolveDrop must fail closed. Loot history carries no rollID, so the join
 *     is by item link; two simultaneous rolls on the same link must yield NO
 *     tally rather than a confident wrong one. PairCopies may pair them (oldest
 *     roll, lowest drop key) but only when the counts agree, and FindMisPair
 *     catches a wrong pairing from which copy you pressed.
 *   - Loot history fields can be secret values; they are skipped, never compared.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_lootroll_logic.js
 *
 * Not wired into CI: the Luacheck workflow is a Lua parse gate with no node step.
 */

const fs = require('fs');
const path = require('path');

let fengari;
try {
  fengari = require('fengari');
} catch (e) {
  console.log('SKIP: fengari not installed.  npm install fengari');
  process.exit(0);
}
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = fengari;

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

function run(code, name) {
  if (lauxlib.luaL_loadbuffer(L, to_luastring(code), null, to_luastring(name)) !== lua.LUA_OK
      || lua.lua_pcall(L, 0, lua.LUA_MULTRET, 0) !== lua.LUA_OK) {
    console.error(name + ': ' + to_jsstring(lua.lua_tostring(L, -1)));
    process.exit(1);
  }
}

const REPO = path.resolve(__dirname, '..') + '/';
const read = f => fs.readFileSync(REPO + f, 'utf8').replace(/^﻿/, '');

// --- Stub the slice of the WoW/addon environment these files touch ---------
run(`
  _G.HorizonSuite = {
    Augment = { QUALITY_COLORS = { [1]={1,1,1},[4]={0.64,0.21,0.93} }, DB_KEYS = {},
                ToastMotion = { EDGE = 8, CHROME_HEIGHT_PAD = 10 } },
    AUGMENT_DEFAULTS = {}, AUGMENT_LIMITS = {},
    L = setmetatable({}, { __index = function(_, k) return k end }),
    db = {},
    GetDB = function(k, d)
      local v = _G.HorizonSuite.db[k]
      if v ~= nil then return v end
      return d
    end,
    Platform = { caps = { specs = true, transmog = true, lootHistory = true },
                 Has = function(k) return _G.HorizonSuite.Platform.caps[k] == true end },
  }
  Enum = { EncounterLootDropRollState = {
    NeedMainSpec = 0, NeedOffSpec = 1, Transmog = 2, Greed = 3, NoRoll = 4, Pass = 5 } }
  C_LootHistory = {}
  C_Item = {}
`, 'stubs');

// Load the real locale so format templates are the shipped ones, not stubs.
run(read('locales/horizon/enUS.lua'), 'enUS');

run(read('modules/Augment/LootRoll/AugmentRollState.lua'),  'RollState');
run(read('modules/Augment/LootRoll/AugmentRollTally.lua'),  'RollTally');
run(read('modules/Augment/LootRoll/AugmentRollBadges.lua'), 'RollBadges');
run(read('modules/Augment/LootRoll/AugmentRollWindow.lua'), 'RollWindow');
run(read('modules/Augment/LootRoll/AugmentRollFrames.lua'), 'RollFrames');
run(read('modules/Augment/LootRoll/AugmentRollDemo.lua'), 'RollDemo');

// --- Assertions -----------------------------------------------------------
run(`
  local R = HorizonSuite.Augment.Roll
  local T = R.Tally
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

  -- The module ships DISABLED, so the frame pool is never built until someone
  -- turns it on — yet the platform probe, /h roll status and /h roll clear all
  -- read the pool regardless. On the Retail client, with the module still off,
  -- /h platform probe died with "attempt to index field '?' (a nil value)".
  -- Forever never showed it only because the module had been switched on there
  -- first. These run BEFORE InitFrames, which is the default state for everyone.
  local function noThrow(fn, ...) return (pcall(fn, ...)) end
  check("HasActiveRows before InitFrames does not throw", noThrow(R.HasActiveRows), "threw")
  check("HasActiveRows before InitFrames is false", R.HasActiveRows() == false, R.HasActiveRows())
  check("FindRow before InitFrames does not throw", noThrow(R.FindRow, 1), "threw")
  check("FindRow before InitFrames is nil", R.FindRow(1) == nil, R.FindRow(1))
  check("ReleaseRoll before InitFrames does not throw (/h roll clear)", noThrow(R.ReleaseRoll, 900001), "threw")
  check("Restack before InitFrames does not throw", noThrow(R.Restack), "threw")
  check("ClearAllRolls before InitFrames does not throw", noThrow(R.ClearAllRolls), "threw")
  check("RefreshAllTallies before InitFrames does not throw", noThrow(R.RefreshAllTallies), "threw")

  -- Info-line layout. The first live demo put badges and tally on one line and
  -- the ellipsis ate the leader's name. Each gets a line now, and whichever is
  -- present moves up when the other is empty, so no row shows a blank line.
  local function fakeFS()
    return {
      text = nil, points = {},
      SetText = function(self, t) self.text = t end,
      ClearAllPoints = function(self) self.points = {} end,
      SetPoint = function(self, ...) self.points[#self.points + 1] = { ... } end,
      SetJustifyH = function(self, j) self.justify = j end,
    }
  end
  local function fakeRow()
    return {
      frame = {},
      title = fakeFS(), body = fakeFS(), tally = fakeFS(),
      -- Framed style: the icon itself is the anchor, inset 8 from the edge.
      icon = { GetPoint = function() return "LEFT", nil, "LEFT", 8, 0 end,
               GetWidth = function() return 40 end },
      iconBg = { IsShown = function() return false end },
      bar = { GetWidth = function() return 86 end },
    }
  end
  local function y(fs) return fs.points[1] and fs.points[1][5] end

  local row = fakeRow()
  R.SetInfoLines(row, "BADGES", "TALLY")
  check("both present: three lines", row.lineCount == 3, row.lineCount)
  check("both present: badges on the middle line", row.body.text == "BADGES", row.body.text)
  check("both present: tally on the bottom line", row.tally.text == "TALLY", row.tally.text)
  check("both present: name above badges above tally",
        y(row.title) > y(row.body) and y(row.body) > y(row.tally),
        tostring(y(row.title)) .. "/" .. tostring(y(row.body)) .. "/" .. tostring(y(row.tally)))
  check("both present: block centred on the icon", y(row.body) == 0, y(row.body))

  -- Both horizontal points hang off the same frame at the same height, which
  -- is the fix: no line is pinned between two anchors that disagree.
  local p1, p2 = row.title.points[1], row.title.points[2]
  check("each line anchored to the frame on both sides",
        p1[2] == row.frame and p2[2] == row.frame, "mixed anchors")
  check("left and right anchors agree vertically", p1[5] == p2[5], tostring(p1[5]) .. " vs " .. tostring(p2[5]))
  check("text clears the icon: 8 inset + 40 icon + 10 gap", p1[4] == 58, p1[4])
  check("text clears the buttons: 8 edge + 86 bar + 8 gap", p2[4] == -102, p2[4])

  row = fakeRow()
  R.SetInfoLines(row, "", "TALLY")
  check("no badges: tally moves up", row.body.text == "TALLY" and row.tally.text == "", row.body.text)
  check("no badges: two lines", row.lineCount == 2, row.lineCount)
  check("no badges: bottom line unanchored", #row.tally.points == 0, #row.tally.points)

  row = fakeRow()
  R.SetInfoLines(row, "BADGES", "")
  check("no tally: badges stay under the name", row.body.text == "BADGES" and row.tally.text == "", row.body.text)
  check("no tally: two lines", row.lineCount == 2, row.lineCount)

  row = fakeRow()
  R.SetInfoLines(row, "", "")
  check("nothing to say: name alone, centred", row.lineCount == 1 and y(row.title) == 0, row.lineCount)

  -- Remembered so an own-roll result can replace the tally and leave badges.
  row = fakeRow()
  R.SetInfoLines(row, "BADGES", "TALLY")
  R.SetInfoLines(row, row.badgeText, "You rolled 87")
  check("own roll replaces the tally, keeps the badges",
        row.body.text == "BADGES" and row.tally.text == "You rolled 87", row.tally.text)

  -- Mirrored: icon on the right, buttons packed against the left edge.
  local realGetDB = HorizonSuite.GetDB
  HorizonSuite.GetDB = function(k, d)
    if k == "lootRollIconSide" then return "right" end
    return realGetDB(k, d)
  end
  row = fakeRow()
  row.icon.GetPoint = function() return "RIGHT", nil, "RIGHT", -8, 0 end
  R.SetInfoLines(row, "BADGES", "TALLY")
  p1, p2 = row.title.points[1], row.title.points[2]
  check("mirrored: text clears the buttons on the left", p1[4] == 102, p1[4])
  check("mirrored: text clears the icon on the right", p2[4] == -58, p2[4])
  check("mirrored: text right-justified", row.title.justify == "RIGHT", row.title.justify)
  HorizonSuite.GetDB = realGetDB

  -- Bucketing, specs present
  check("NeedMainSpec -> need",  T.BucketForState(0) == "need",     T.BucketForState(0))
  check("NeedOffSpec -> needOff", T.BucketForState(1) == "needOff", T.BucketForState(1))
  check("Transmog",  T.BucketForState(2) == "transmog", T.BucketForState(2))
  check("Greed",     T.BucketForState(3) == "greed",    T.BucketForState(3))
  check("NoRoll -> waiting", T.BucketForState(4) == "waiting", T.BucketForState(4))
  check("Pass",      T.BucketForState(5) == "pass",     T.BucketForState(5))
  check("nil state", T.BucketForState(nil) == nil,      T.BucketForState(nil))

  -- THE FOREVER CASE: no specs, off-spec Need must collapse into Need
  HorizonSuite.Platform.caps.specs = false
  check("no specs: NeedOffSpec collapses to need", T.BucketForState(1) == "need", T.BucketForState(1))
  check("no specs: NeedMainSpec still need",       T.BucketForState(0) == "need", T.BucketForState(0))
  HorizonSuite.Platform.caps.specs = true

  -- Summarise
  local drop = {
    rollInfos = {
      { playerName = "Ana",  playerClass = "MAGE",   state = 0, isSelf = false },
      { playerName = "Bo",   playerClass = "ROGUE",  state = 0, isSelf = true  },
      { playerName = "Cy",   playerClass = "PRIEST", state = 3, isSelf = false },
      { playerName = "Di",   playerClass = "DRUID",  state = 5, isSelf = false },
      { playerName = "Ed",   playerClass = "WARLOCK",state = 4, isSelf = false },
    },
    currentLeader = { playerName = "Ana", roll = 87, playerClass = "MAGE" },
    isTied = false, allPassed = false,
  }
  local s = T.Summarise(drop)
  check("summary total",   s.total == 5,        s.total)
  check("summary rolled",  s.rolled == 4,       s.rolled)
  check("summary need=2",  s.counts.need == 2,  s.counts.need)
  check("summary greed=1", s.counts.greed == 1, s.counts.greed)
  check("summary pass=1",  s.counts.pass == 1,  s.counts.pass)
  check("summary waiting=1", s.counts.waiting == 1, s.counts.waiting)
  check("summary youRolled", s.youRolled == "need", s.youRolled)
  check("summary leader",  s.leaderName == "Ana" and s.leaderRoll == 87, s.leaderName)

  -- Who rolled what: names behind the counts (feedback: the counts alone
  -- cannot be matched to anyone in a raid).
  check("players.need has both needers", #s.players.need == 2, #s.players.need)
  check("players.greed names Cy", s.players.greed[1].name == "Cy", s.players.greed[1] and s.players.greed[1].name)
  check("players carry class", s.players.greed[1].class == "PRIEST", s.players.greed[1].class)
  check("players.waiting names Ed", s.players.waiting[1].name == "Ed", #s.players.waiting)

  local sorted = T.SortPlayers({ { name = "Zo" }, { name = "Al", roll = 12 }, { name = "Bea", roll = 80 }, { name = "Ab" } })
  check("sort: highest roll first", sorted[1].name == "Bea" and sorted[2].name == "Al", sorted[1].name)
  check("sort: unrolled by name after", sorted[3].name == "Ab" and sorted[4].name == "Zo", sorted[3].name)

  local function FakeTooltip()
    local t = { lines = {} }
    function t:AddLine(text) self.lines[#self.lines + 1] = text end
    function t:AddDoubleLine(l, r) self.lines[#self.lines + 1] = l .. " | " .. r end
    function t:Text() return table.concat(self.lines, "\\n") end
    return t
  end

  local tip = FakeTooltip()
  check("need button adds rollers", T.AddButtonRollers(tip, s, R.ROLL_NEED) == true)
  local txt = tip:Text()
  check("need tooltip names Ana", txt:find("Ana") ~= nil, txt)
  check("need tooltip marks self", txt:find("Bo %(you%)") ~= nil, txt)
  check("need tooltip omits greeders", txt:find("Cy") == nil, txt)

  -- Off-spec Need came from the Need button too.
  local offspec = T.Summarise({ rollInfos = {
    { playerName = "Fi", playerClass = "HUNTER", state = 1 } } })
  tip = FakeTooltip()
  T.AddButtonRollers(tip, offspec, R.ROLL_NEED)
  check("need tooltip includes off-spec", tip:Text():find("Fi") ~= nil, tip:Text())

  tip = FakeTooltip()
  T.AddButtonRollers(tip, offspec, R.ROLL_GREED)
  check("empty bucket says nobody yet", tip:Text():find("Nobody yet") ~= nil, tip:Text())

  tip = FakeTooltip()
  check("disenchant adds nothing", T.AddButtonRollers(tip, s, R.ROLL_DISENCHANT) == false and #tip.lines == 0)
  check("no summary adds nothing", T.AddButtonRollers(FakeTooltip(), nil, R.ROLL_NEED) == false)

  tip = FakeTooltip()
  T.AddAllRollers(tip, s)
  txt = tip:Text()
  check("all-rollers lists every name", txt:find("Ana") and txt:find("Cy") and txt:find("Di") and txt:find("Ed"), txt)
  check("all-rollers lists need before greed", txt:find("Need") < txt:find("Greed"), txt)
  check("all-rollers shows waiting", txt:find("Still choosing %(1%)") ~= nil, txt)

  local withRolls = T.Summarise({ rollInfos = {
    { playerName = "Gil", playerClass = "MAGE", state = 0, roll = 73 } } })
  tip = FakeTooltip()
  T.AddButtonRollers(tip, withRolls, R.ROLL_NEED)
  check("roll number shown beside name", tip:Text():find("Gil.*| 73") ~= nil, tip:Text())

  -- Counts drawn on the button icons
  check("button count: need", T.CountForButton(s, R.ROLL_NEED) == 2, T.CountForButton(s, R.ROLL_NEED))
  check("button count: greed", T.CountForButton(s, R.ROLL_GREED) == 1, T.CountForButton(s, R.ROLL_GREED))
  check("button count: pass", T.CountForButton(s, R.ROLL_PASS) == 1, T.CountForButton(s, R.ROLL_PASS))
  check("button count: need includes off-spec", T.CountForButton(offspec, R.ROLL_NEED) == 1)
  check("button count: disenchant always 0", T.CountForButton(s, R.ROLL_DISENCHANT) == 0)
  check("button count: no summary 0", T.CountForButton(nil, R.ROLL_NEED) == 0)

  -- Roll list window: one card per roll (feedback, 2026-11-25: a card per
  -- item reading like standings, not a long list of collapsible headers)
  local W = R.Window
  local function rows(card)
    local out = {}
    for _, r in ipairs(card.rows) do
      out[#out + 1] = r.kind == "fold" and ("F:" .. r.fold .. (r.collapsed and "+" or "-") .. r.count)
        or ((r.winner and "W:" or "P:") .. r.player.name .. (r.dim and "~" or ""))
    end
    return table.concat(out, ",")
  end
  local open = {}
  local function isCollapsed(k) if open[k] ~= nil then return not open[k] end return true end

  local card = W.BuildCard({ name = "Sword", quality = 4, summary = s }, isCollapsed)
  local got = rows(card)
  check("card: Need above Greed, pass and undecided folded",
        got == "P:Ana,P:Bo,P:Cy,F:pass+1,F:waiting+1", got)
  check("card: open roll says how many have chosen", card.line == "4 of 5 have chosen", card.line)
  check("card: open roll marked Rolling", card.status == "Rolling", card.status)
  check("card: need rows carry their bucket", card.rows[1].bucket == "need" and card.rows[3].bucket == "greed")

  open.pass = true
  got = rows(W.BuildCard({ name = "Sword", summary = s }, isCollapsed))
  check("card: opening Passed lists passers dimmed", got == "P:Ana,P:Bo,P:Cy,F:pass-1,P:Di~,F:waiting+1", got)
  open.pass = nil

  local offCard = W.BuildCard({ name = "Ring", summary = offspec }, isCollapsed)
  check("card: off-spec Need listed", rows(offCard) == "P:Fi", rows(offCard))
  check("card: everyone chosen says rolling", offCard.line == "Everyone has chosen, rolling...", offCard.line)

  card = W.BuildCard({ name = "Cloak", summary = nil }, isCollapsed)
  check("card: unmatched roll says no data, no rows", card.line == "No roll data yet" and #card.rows == 0, card.line)

  card = W.BuildCard({ name = "Bar", summary = T.Summarise({ rollInfos = {}, allPassed = true }) }, isCollapsed)
  check("card: all passed", card.line == "Everyone passed" and #card.rows == 0, card.line)

  card = W.BuildCard({ name = "Tie", summary = T.Summarise({ isTied = true, rollInfos = {
    { playerName = "A", playerClass = "MAGE", state = 0, roll = 50 },
    { playerName = "B", playerClass = "MAGE", state = 0, roll = 50 } } }) }, isCollapsed)
  check("card: tie says rolling again", card.line == "Tied, rolling again", card.line)

  check("cards: none open", #W.BuildCards({}, isCollapsed) == 0)
  check("cards: one per roll", #W.BuildCards({ { name = "A", summary = s }, { name = "B", summary = offspec } }, isCollapsed) == 2)

  -- Standings order: winner, then choice, then roll
  local ranked = W.Standings(T.Summarise({ rollInfos = {
    { playerName = "G1", playerClass = "MAGE", state = 3, roll = 99 },
    { playerName = "N1", playerClass = "MAGE", state = 0, roll = 20 },
    { playerName = "N2", playerClass = "MAGE", state = 0, roll = 60 },
    { playerName = "T1", playerClass = "MAGE", state = 2, roll = 90 },
    { playerName = "O1", playerClass = "MAGE", state = 1, roll = 95 },
  } }))
  local order = {}
  for _, r in ipairs(ranked) do order[#order + 1] = r.player.name end
  check("standings: Need > off-spec > Transmog > Greed, then roll",
        table.concat(order, ",") == "N2,N1,O1,T1,G1", table.concat(order, ","))

  -- Fold defaults when nothing is saved: both start closed.
  check("window default: pass collapsed", W.IsCollapsed("pass") == true)
  check("window default: waiting collapsed", W.IsCollapsed("waiting") == true)
  HorizonSuite.db.lootRollWindowCollapsed_pass = false
  check("window: saved choice beats default", W.IsCollapsed("pass") == false)
  HorizonSuite.db.lootRollWindowCollapsed_pass = nil

  -- Result view: a finished roll flips to who won (feedback, 2026-11-25)
  local live = { { rollID = 7, name = "Axe", quality = 4, icon = 123, itemLink = "AXE", summary = s,
                   dropKey = { encounterID = 1, lootListID = 3 } } }
  local entries = W.SyncEntries({}, live, nil)
  check("sync: open roll added", #entries == 1 and entries[1].finished == false, #entries)
  check("sync: icon and link carried", entries[1].icon == 123 and entries[1].itemLink == "AXE")

  local final = T.Summarise({
    rollInfos = {
      { playerName = "Ana", playerClass = "MAGE",   state = 0, roll = 87, isWinner = true },
      { playerName = "Bo",  playerClass = "ROGUE",  state = 0, roll = 40, isSelf = true },
      { playerName = "Cy",  playerClass = "PRIEST", state = 3, roll = 95 },
      { playerName = "Di",  playerClass = "DRUID",  state = 5 },
    },
    winner = { playerName = "Ana", playerClass = "MAGE", roll = 87 },
  })
  check("summary marks winner", final.players.need[1].isWinner == true)
  local asked
  W.SyncEntries(entries, {}, function(e) asked = e.dropKey; return final end)
  check("sync: closed roll finished", entries[1].finished == true)
  check("sync: resolves by drop key", asked and asked.lootListID == 3)
  local res = W.BuildCard(entries[1], isCollapsed)
  got = rows(res)
  check("result: winner first, then the rest, pass folded, no Still choosing",
        got == "W:Ana,P:Bo,P:Cy,F:pass+1", got)
  check("result: card marked Result", res.status == "Result", res.status)
  check("result: line names winner, choice and roll", res.line:find("Ana|r won with Need 87%.") ~= nil, res.line)
  check("result: line adds your own roll", res.line:find("You rolled 40%.") ~= nil, res.line)
  check("result: tone is result", res.tone == "result", res.tone)

  local mine = W.BuildCard({ finished = true, name = "Orb", summary = T.Summarise({
    rollInfos = { { playerName = "Me", playerClass = "MAGE", state = 3, roll = 70, isSelf = true, isWinner = true } },
    winner = { playerName = "Me", playerClass = "MAGE", roll = 70 } }) }, isCollapsed)
  check("result: you won", mine.line == "You won with Greed 70!", mine.line)

  local passedMe = W.BuildCard({ finished = true, name = "Orb", summary = T.Summarise({
    rollInfos = { { playerName = "Ana", playerClass = "MAGE", state = 0, roll = 12, isWinner = true },
                  { playerName = "Me", playerClass = "MAGE", state = 5, isSelf = true } },
    winner = { playerName = "Ana", playerClass = "MAGE", roll = 12 } }) }, isCollapsed)
  check("result: you passed", passedMe.line:find("You passed%.") ~= nil, passedMe.line)

  -- Resolve failing keeps the last summary; no winner yet means pending.
  local pend = W.SyncEntries({}, { { rollID = 8, name = "Orb", summary = s, dropKey = { encounterID = 1, lootListID = 4 } } }, nil)
  W.SyncEntries(pend, {}, function() return nil end)
  card = W.BuildCard(pend[1], isCollapsed)
  check("result: pending until history has the winner",
        card.line == "Waiting for the result..." and #card.rows == 0, card.line)

  local nokey = W.SyncEntries({}, { { rollID = 9, name = "Gem", summary = nil } }, nil)
  W.SyncEntries(nokey, {}, nil)
  card = W.BuildCard(nokey[1], isCollapsed)
  check("result: no key, unavailable", card.line == "Result unavailable", card.line)

  -- A new roll after results: DropFinished keeps open rolls only.
  local mixed = W.SyncEntries({}, { { rollID = 1, name = "A" }, { rollID = 2, name = "B" } }, nil)
  W.SyncEntries(mixed, { { rollID = 2, name = "B" } }, nil)
  W.DropFinished(mixed)
  check("drop finished keeps open rolls", #mixed == 1 and mixed[1].rollID == 2, #mixed)

  -- Tally line: result shows the winner
  check("tally line shows winner after roll", T.FormatLine(final):find("Ana won with 87") ~= nil, T.FormatLine(final))

  -- Formatting
  local line = T.FormatLine(s)
  -- Counts live on the button icons and the leader is not known until
  -- everyone has chosen, so mid-roll the line only says who is still to choose.
  check("line says who is still to choose", line == "waiting on 1", line)
  check("line has no counts", line:find("Need") == nil and line:find("Greed") == nil, line)
  check("line has no leader", line:find("Ana") == nil and line:find("87") == nil, line)
  local allChosen = T.Summarise({ rollInfos = { { playerName = "A", state = 0 } },
                                  currentLeader = { playerName = "A", roll = 50 } })
  check("everyone chosen, no result yet -> empty", T.FormatLine(allChosen) == "", T.FormatLine(allChosen))

  check("nil summary -> empty", T.FormatLine(nil) == "", T.FormatLine(nil))

  -- Roll chrome follows the loot toasts by default. A user with loot toasts in
  -- Accent expected the roll window to match without hunting for a setting
  -- (feedback, 2026-09-27), and both the toast stack and the skinned personal
  -- loot window read the same key, so following it matches either.
  HorizonSuite.AUGMENT_DEFAULTS.lootRollToastStyle = "__loot__"
  HorizonSuite.Augment.GetToastStyle = function() return "accent" end
  check("default follows the loot toast style", R.GetToastStyle() == "accent", R.GetToastStyle())

  HorizonSuite.Augment.GetToastStyle = function() return "compact" end
  check("it tracks a change to the loot toast style", R.GetToastStyle() == "compact", R.GetToastStyle())

  HorizonSuite.db.lootRollToastStyle = "framed"
  check("an explicit style still wins", R.GetToastStyle() == "framed", R.GetToastStyle())

  HorizonSuite.db.lootRollToastStyle = "__loot__"
  check("switching back resumes following", R.GetToastStyle() == "compact", R.GetToastStyle())

  -- Falls back rather than rendering an unstyled frame if loot toasts are gone.
  HorizonSuite.Augment.GetToastStyle = nil
  check("no loot toast module: falls back to framed", R.GetToastStyle() == "framed", R.GetToastStyle())
  HorizonSuite.db.lootRollToastStyle = nil

  local won = T.Summarise({ rollInfos = {}, winner = { playerName = "Zed", roll = 99 } })
  check("winner line names winner", T.FormatLine(won):find("Zed") ~= nil, T.FormatLine(won))
  check("winner line shows roll", T.FormatLine(won):find("99") ~= nil, T.FormatLine(won))

  local allPassed = T.Summarise({ rollInfos = {}, allPassed = true })
  check("all passed line", T.FormatLine(allPassed) == "Everyone passed",
        T.FormatLine(allPassed))

  -- Nobody has chosen yet
  local waiting = T.Summarise({ rollInfos = {
    { playerName="A", playerClass="MAGE", state=4, isSelf=false },
    { playerName="B", playerClass="MAGE", state=4, isSelf=false } } })
  check("waiting-only line non-empty", T.FormatLine(waiting) ~= "", T.FormatLine(waiting))

  -- ResolveDrop fails closed
  check("no link -> nil", T.ResolveDrop(nil) == nil, "nil")
  check("empty link -> nil", T.ResolveDrop("") == nil, "empty")
  HorizonSuite.Platform.caps.lootHistory = false
  check("no lootHistory capability -> nil", T.ResolveDrop("|Hitem:1|h[x]|h") == nil, "gated")
  HorizonSuite.Platform.caps.lootHistory = true

  -- Ambiguity: two unfinished drops with the same link must resolve to nothing
  C_LootHistory.GetLootHistoryTime = function() return 100 end
  C_LootHistory.GetAllEncounterInfos = function() return { { encounterID = 1 } } end
  C_LootHistory.GetSortedDropsForEncounter = function()
    return {
      { itemHyperlink = "SAME", startTime = 98, duration = 30, rollInfos = {} },
      { itemHyperlink = "SAME", startTime = 99, duration = 30, rollInfos = {} },
    }
  end
  check("ambiguous link -> nil (fails closed)", T.ResolveDrop("SAME") == nil, "ambiguous")

  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "ONE", startTime = 98, duration = 30, rollInfos = {} } }
  end
  check("single match resolves", T.ResolveDrop("ONE") ~= nil, "single")

  -- The key that finds the drop again once it is finished
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "KEYED", lootListID = 6, startTime = 98, duration = 30, rollInfos = {} } }
  end
  local d, enc = T.ResolveDrop("KEYED")
  check("resolve hands back encounterID", d ~= nil and enc ~= nil, tostring(enc))
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "KEYED", lootListID = 6, winner = { playerName = "Zed", roll = 5 }, rollInfos = {} } }
  end
  check("finished drop invisible to link join", T.ResolveDrop("KEYED") == nil)
  local fd = T.FindDrop(enc, 6)
  check("FindDrop finds the finished drop by key", fd ~= nil and fd.winner.playerName == "Zed")
  check("FindDrop wrong lootListID -> nil", T.FindDrop(enc, 7) == nil)

  -- A finished drop is not a candidate for a roll still on screen
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "DONE", startTime = 98, duration = 30, rollInfos = {},
               winner = { playerName = "X", roll = 1 } } }
  end
  check("finished drop ignored", T.ResolveDrop("DONE") == nil, "finished")

  -- Outside the time window
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "OLD", startTime = 10, duration = 30, rollInfos = {} } }
  end
  check("stale drop ignored", T.ResolveDrop("OLD") == nil, "stale")

  -- Drop key: retail's lootListID or Forever's lootListKey
  check("DropKey reads lootListID", T.DropKey({ lootListID = 4 }) == 4)
  check("DropKey reads lootListKey", T.DropKey({ lootListKey = 9 }) == 9)
  check("DropKey nil without either", T.DropKey({}) == nil)
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = "FV", lootListKey = 2, rollInfos = {} } }
  end
  check("FindDrop works with lootListKey", T.FindDrop(1, 2) ~= nil)

  -- Two copies of one item: candidates come back lowest key first
  C_LootHistory.GetSortedDropsForEncounter = function()
    return {
      { itemHyperlink = "TOKEN", lootListID = 12, startTime = 99, duration = 30, rollInfos = {} },
      { itemHyperlink = "TOKEN", lootListID = 11, startTime = 98, duration = 30, rollInfos = {} },
    }
  end
  local cands = T.Candidates("TOKEN")
  check("candidates: both copies", #cands == 2, #cands)
  check("candidates: lowest key first", cands[1].key == 11 and cands[2].key == 12,
        tostring(cands[1] and cands[1].key))
  check("ResolveDrop still fails closed on two copies", T.ResolveDrop("TOKEN") == nil)

  -- Oldest roll takes the lowest key
  local paired = T.PairCopies({ { rollID = 50, startedAt = 10.5 }, { rollID = 49, startedAt = 10.0 } }, cands)
  check("pair: oldest roll gets lowest key", paired[49] and paired[49].key == 11, paired[49] and paired[49].key)
  check("pair: newer roll gets next key", paired[50] and paired[50].key == 12, paired[50] and paired[50].key)
  local tie = T.PairCopies({ { rollID = 8, startedAt = 1 }, { rollID = 7, startedAt = 1 } }, cands)
  check("pair: same start time falls back to rollID", tie[7].key == 11 and tie[8].key == 12)

  -- Fails closed when counts disagree or a key is missing
  local none = T.PairCopies({ { rollID = 1, startedAt = 1 } }, cands)
  check("pair: one roll, two drops -> nothing", next(none) == nil)
  none = T.PairCopies({ { rollID = 1, startedAt = 1 }, { rollID = 2, startedAt = 2 } }, { cands[1] })
  check("pair: two rolls, one drop -> nothing", next(none) == nil)
  none = T.PairCopies({ { rollID = 1, startedAt = 1 } }, { { drop = {}, encounterID = 1, key = nil } })
  check("pair: drop without a key -> nothing", next(none) == nil)
  local single = T.PairCopies({ { rollID = 1, startedAt = 1 } }, { cands[1] })
  check("pair: one roll, one drop pairs", single[1] == cands[1])

  -- Your own choice on a drop
  check("SelfBucket need", T.SelfBucket({ rollInfos = { { isSelf = true, state = 0 } } }) == "need")
  check("SelfBucket waiting", T.SelfBucket({ rollInfos = { { isSelf = true, state = 4 } } }) == "waiting")
  check("SelfBucket nil when not on it", T.SelfBucket({ rollInfos = { { isSelf = false, state = 0 } } }) == nil)

  -- Mispair: you pressed roll 2, but history put your choice on roll 1's drop
  local i, j = T.FindMisPair({ { pressed = false, selfBucket = "need" }, { pressed = true, selfBucket = "waiting" } })
  check("mispair: swap found", i == 1 and j == 2, tostring(i) .. "," .. tostring(j))
  i = T.FindMisPair({ { pressed = true, selfBucket = "need" }, { pressed = false, selfBucket = "waiting" } })
  check("mispair: right way round -> nothing", i == nil)
  i = T.FindMisPair({ { pressed = true, selfBucket = "need" }, { pressed = true, selfBucket = "greed" } })
  check("mispair: pressed both -> nothing", i == nil)
  i = T.FindMisPair({ { pressed = false, selfBucket = "waiting" }, { pressed = true, selfBucket = "waiting" } })
  check("mispair: history not caught up -> nothing", i == nil)

  -- Secret values: unreadable fields are skipped, never compared
  local SECRET = setmetatable({}, { __eq = function() error("compared a secret") end })
  issecretvalue = function(v) return v == nil and false or rawequal(v, SECRET) end
  local sec = T.Summarise({ rollInfos = {
    { playerName = SECRET, playerClass = "MAGE", state = 0, roll = SECRET, isSelf = SECRET },
    { playerName = "Ok", playerClass = "MAGE", state = SECRET },
  }, isTied = SECRET, allPassed = SECRET, winner = SECRET })
  check("secret: summary built", sec ~= nil)
  check("secret: secret state skipped", sec.total == 1, sec.total)
  check("secret: secret name blank, roll dropped",
        sec.players.need[1].name == "" and sec.players.need[1].roll == nil)
  check("secret: secret flags read as false", sec.isTied == false and sec.allPassed == false and sec.winnerName == nil)
  C_LootHistory.GetSortedDropsForEncounter = function()
    return { { itemHyperlink = SECRET, lootListID = 1, rollInfos = {} },
             { itemHyperlink = "PLAIN", lootListID = SECRET, startTime = 99, duration = 30, rollInfos = {} } }
  end
  check("secret: secret link never matches", #T.Candidates("PLAIN") == 1)
  check("secret: secret key reads as no key", T.Candidates("PLAIN")[1].key == nil)
  issecretvalue = nil

  -- Badges
  local B = R.Badges
  check("bind badge off when not BoP", B.Bind(false) == nil, B.Bind(false))
  check("bind badge on when BoP", B.Bind(true) ~= nil, B.Bind(true))
  check("appearance nil without link", B.Appearance(nil) == nil, "nil link")
  check("ilvl nil without link", B.ItemLevel(nil) == nil, "nil link")

  -- Item level delta against the weaker of two rings
  C_Item.GetItemInfo = function(link)
    if link == "RING_NEW" then return "Ring", link, 3, 100, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "RING_A" then return "A", link, 3, 90, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "RING_B" then return "B", link, 3, 80, 60, "", "", 1, "INVTYPE_FINGER" end
    return nil
  end
  GetInventoryItemLink = function(_, slot)
    if slot == 11 then return "RING_A" end
    if slot == 12 then return "RING_B" end
    return nil
  end
  local badge = B.ItemLevel("RING_NEW")
  check("ilvl compares against weaker ring (+20)", badge and badge:find("%+20") ~= nil, badge)

  GetInventoryItemLink = function() return nil end
  check("ilvl nil with empty slots", B.ItemLevel("RING_NEW") == nil, B.ItemLevel("RING_NEW"))

  -- Appearance badge. PlayerHasTransmogByItemInfo answers FALSE, not nil, for
  -- things that were never collectable: a Gold Bar came back false on the
  -- Forever beta and earned itself a "New look" badge. "Not collected" and
  -- "nothing here to collect" must not share a branch.
  C_TransmogCollection = {
    PlayerHasTransmogByItemInfo = function() return false end,
    GetItemInfo = function(link)
      if link == "HOOD" then return 12345, 67890 end   -- has an appearance
      return nil                                        -- trade good: none
    end,
  }
  check("no badge on an item with no appearance (the Gold Bar bug)",
        B.Appearance("GOLD_BAR") == nil, B.Appearance("GOLD_BAR"))
  check("badge on an uncollected appearance",
        B.Appearance("HOOD") ~= nil, B.Appearance("HOOD"))

  -- Already collected: no badge.
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return true end
  check("no badge when already collected", B.Appearance("HOOD") == nil, B.Appearance("HOOD"))

  -- "Cannot tell" is not "you do not have it".
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return nil end
  check("no badge when the client cannot tell", B.Appearance("HOOD") == nil, B.Appearance("HOOD"))

  -- Fallback path: no GetItemInfo on this client, judge by equip slot.
  C_TransmogCollection.GetItemInfo = nil
  C_TransmogCollection.PlayerHasTransmogByItemInfo = function() return false end
  C_Item.GetItemInfo = function(link)
    if link == "HEAD_ITEM" then return "H", link, 3, 80, 60, "", "", 1, "INVTYPE_HEAD" end
    if link == "RING_ITEM" then return "R", link, 3, 80, 60, "", "", 1, "INVTYPE_FINGER" end
    if link == "TRADE_GOOD" then return "G", link, 1, 0, 1, "", "", 20, "" end
    return nil
  end
  check("fallback: badge on a head slot", B.Appearance("HEAD_ITEM") ~= nil, B.Appearance("HEAD_ITEM"))
  check("fallback: no badge on a ring (equippable, no appearance)",
        B.Appearance("RING_ITEM") == nil, B.Appearance("RING_ITEM"))
  check("fallback: no badge on a trade good",
        B.Appearance("TRADE_GOOD") == nil, B.Appearance("TRADE_GOOD"))

  -- Clicks. Buttons are parented to the row's FRAME, but the roll lives on the
  -- Lua TABLE wrapping it. The first version asked the frame for rollID, got
  -- nil, and returned before RollOnLoot on every click. Nothing caught it: the
  -- demo's buttons are meant to do nothing, and no test had ever created a
  -- button. Live rolls in a Forever dungeon did. This builds the real pool from
  -- recording stubs and fires the real handlers.
  local function stubObject(parent)
    local o = { scripts = {}, parent = parent, calls = {} }
    return setmetatable(o, { __index = function(_, k)
      if k == "SetScript" then return function(self, name, fn) self.scripts[name] = fn end end
      if k == "GetParent" then return function(self) return self.parent end end
      if k == "CreateTexture" or k == "CreateFontString" then
        return function(self) return stubObject(self) end
      end
      -- Widget methods are CamelCase from a capital; the addon's own data
      -- fields (reason, row, demo, rollID) are not. Only fake the methods: a
      -- stub that answers every missing key with a function makes nil fields
      -- truthy, and code under test then takes branches it never would in game.
      if type(k) == "string" and k:match("^%u") then
        return function(self, ...)
          if type(self) == "table" and self.calls then self.calls[k] = { ... } end
        end
      end
      return nil
    end })
  end
  CreateFrame = function(_, _, parent) return stubObject(parent) end
  CreateFont = function() return stubObject() end
  UIParent = stubObject()
  C_Timer = { After = function() end }
  R.ApplyStoredAnchor = function() end
  local rolledVia = nil
  R.Core = { OnRolled = function(id, t) rolledVia = { id, t } end }
  R.InitFrames()

  local rollCalls = {}
  RollOnLoot = function(id, t) rollCalls[#rollCalls + 1] = { id, t } end
  R.ShowRoll({ rollID = 42, rollTime = 10000, name = "Sword", quality = 3,
               canNeed = true, canGreed = true, itemLink = "SWORD_LINK" })
  local live = R.FindRow(42)
  check("live roll gets a row", live ~= nil, "no row")

  local need = live.buttons[R.ROLL_NEED]
  need.scripts.OnClick(need)
  check("clicking Need calls RollOnLoot(rollID, 1)",
        rollCalls[1] and rollCalls[1][1] == 42 and rollCalls[1][2] == 1,
        rollCalls[1] and (tostring(rollCalls[1][1]) .. "," .. tostring(rollCalls[1][2])) or "never called")
  check("a successful roll collapses the buttons", rolledVia and rolledVia[1] == 42, "OnRolled not called")

  local passButton = live.buttons[R.ROLL_PASS]
  passButton.scripts.OnClick(passButton)
  check("clicking Pass calls RollOnLoot(rollID, 0)",
        rollCalls[2] and rollCalls[2][1] == 42 and rollCalls[2][2] == 0, "wrong or missing call")

  -- A roll that throws must not grey out the buttons as if it had gone through.
  rolledVia = nil
  RollOnLoot = function() error("server said no") end
  need.scripts.OnClick(need)
  check("a failed roll does not look like a successful one", rolledVia == nil, "buttons collapsed anyway")

  -- Demo rows must never reach the real API.
  rollCalls = {}
  RollOnLoot = function(id, t) rollCalls[#rollCalls + 1] = { id, t } end
  R.ShowRoll({ rollID = 900001, rollTime = 10000, name = "Demo", quality = 4,
               canNeed = true, canGreed = true, demo = true })
  local demoRow = R.FindRow(900001)
  demoRow.buttons[R.ROLL_NEED].scripts.OnClick(demoRow.buttons[R.ROLL_NEED])
  check("demo buttons never call RollOnLoot", #rollCalls == 0, #rollCalls)

  -- The icon had the same mistake: no tooltip, no shift-click link.
  local tipRoll
  GameTooltip = stubObject()
  GameTooltip.SetLootRollItem = function(_, id) tipRoll = id end
  live.iconHit.scripts.OnEnter(live.iconHit)
  check("hovering the icon shows that roll's item", tipRoll == 42, tipRoll)

  local linked
  IsModifiedClick = function() return true end
  ChatEdit_InsertLink = function(link) linked = link end
  live.iconHit.scripts.OnClick(live.iconHit)
  check("shift-clicking the icon links the item", linked == "SWORD_LINK", linked)

  -- Hover. A disabled Button fires no OnEnter unless motion scripts are
  -- enabled while disabled, so a greyed Need button showed no tooltip — and
  -- its tooltip is the one that says WHY you cannot Need. Blizzard's template
  -- sets motionScriptsWhileDisabled; the first version here did not.
  local allFlagged = true
  for _, b in pairs(live.buttons) do
    local c = b.calls.SetMotionScriptsWhileDisabled
    if not (c and c[1] == true) then allFlagged = false end
  end
  check("every roll button keeps hover while disabled", allFlagged, "flag missing")

  local lines = {}
  GameTooltip.AddLine = function(_, text) lines[#lines + 1] = text end
  GameTooltip.SetText = function(_, text) lines[#lines + 1] = text end

  R.ShowRoll({ rollID = 43, rollTime = 10000, name = "Plate", quality = 3,
               canNeed = false, reasonNeed = "Your class cannot use this.", canGreed = true })
  local greyed = R.FindRow(43).buttons[R.ROLL_NEED]
  greyed.scripts.OnEnter(greyed)
  check("hovering a greyed Need explains why",
        lines[#lines] == "Your class cannot use this.", lines[#lines])

  lines = {}
  local demoNeed = demoRow.buttons[R.ROLL_NEED]
  demoNeed.scripts.OnEnter(demoNeed)
  check("hovering a demo button says it does nothing",
        lines[#lines] and lines[#lines]:find("does nothing") ~= nil, lines[#lines])

  -- Demo item loading. Item:CreateFromItemID is a COLON method. Called with a
  -- dot, the itemID lands in self and the real argument is nil, so every item
  -- comes back empty and nothing redraws — the Forever demo showed four
  -- "Demo Item" placeholders where the previous build had resolved three.
  -- Runs last: it replaces frame functions the earlier checks relied on.
  local received = {}
  Item = {
    CreateFromItemID = function(self, itemID)
      received[#received + 1] = { selfIsItem = (self == Item), itemID = itemID }
      return { IsItemEmpty = function() return itemID == nil end,
               ContinueOnItemLoad = function() end }
    end,
  }
  HorizonSuite.IsModuleEnabled = function() return true end
  R.InitFrames = function() end
  R.RestoreSavedPosition = function() end
  R.ShowRoll = function() return true end
  R.GetMaxVisible = function() return 4 end
  C_Item.GetItemInfo = function() return nil end
  C_Timer = { After = function() end }

  R.Demo.Run()
  check("demo asks for all four items", #received == 4, #received)
  local allGood = #received > 0
  for _, r in ipairs(received) do
    if not (r.selfIsItem and type(r.itemID) == "number") then allGood = false end
  end
  check("CreateFromItemID called as a method with a real itemID", allGood,
        received[1] and ("self=Item? " .. tostring(received[1].selfIsItem) ..
                         " itemID=" .. tostring(received[1].itemID)) or "no calls")

  print(("\\n%d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("assertions failed") end
`, 'assertions');
