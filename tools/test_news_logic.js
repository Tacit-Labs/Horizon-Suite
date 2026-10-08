#!/usr/bin/env node
/**
 * Executable checks for the pure-logic half of the Dashboard news module:
 * filtering stories by date and version, sorting by priority, tracking unread,
 * and building the release story from patch notes.
 *
 * Why this exists. News filtering, sorting and tracking must work correctly
 * before a player sees them, and that logic is pure — no frames, no secure
 * calls — so it runs fine in a plain Lua VM with the WoW globals stubbed.
 * The shipped locale file is loaded too, so localisation keys are the real ones.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_news_logic.js
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
  _G.HorizonSuite = { L = setmetatable({}, { __index = function(_, k) return k end }) }
`, 'stubs');
run(read('locales/horizon/enUS.lua'), 'enUS');
run(read('options/dashboard/DashboardNewsLogic.lua'), 'NewsLogic');

run(`
  local N = HorizonSuite.NewsLogic
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end
  local function ids(list) local t = {} for i, s in ipairs(list) do t[i] = s.id end return table.concat(t, ",") end

  -- Versions compare numerically, so 6.10.0 is newer than 6.9.0.
  check("6.10.0 > 6.9.0", N.CompareVersions("6.10.0", "6.9.0") == 1)
  check("6.6 == 6.6.0", N.CompareVersions("6.6", "6.6.0") == 0)
  check("6.5.1 < 6.6.0", N.CompareVersions("6.5.1", "6.6.0") == -1)

  local s = { id = "a", fromDate = "2026-10-01", untilDate = "2026-10-31" }
  check("before from is hidden", not N.IsVisible(s, "2026-09-30", "6.6.0"))
  check("on from is shown", N.IsVisible(s, "2026-10-01", "6.6.0"))
  check("on until is shown", N.IsVisible(s, "2026-10-31", "6.6.0"))
  check("after until is hidden", not N.IsVisible(s, "2026-11-01", "6.6.0"))
  local v = { id = "v", untilVersion = "6.6.0" }
  check("same version shown", N.IsVisible(v, "2026-10-06", "6.6.0"))
  check("newer version hides", not N.IsVisible(v, "2026-10-06", "6.6.1"))
  check("unknown version keeps it", N.IsVisible(v, "2026-10-06", ""))

  local feed = N.Visible({
    { id = "low",  priority = 100, fromDate = "2026-10-05" },
    { id = "high", priority = 500 },
    { id = "newer", priority = 100, fromDate = "2026-10-06" },
    { id = "b", priority = 100 }, { id = "a", priority = 100 },
    { id = "gone", priority = 900, untilDate = "2026-01-01" },
  }, "2026-10-06", "6.6.0")
  check("sort: priority, then newest from, then id", ids(feed) == "high,newer,low,a,b", ids(feed))

  local notes = { ["6.6.0"] = { date = "2026-10-05",
    { section = "New Features", bullets = { "One." } },
    { section = "Fixes", bullets = { "Two.", "Three." } } } }
  local r = N.ReleaseStory(notes, "6.6.0")
  check("release id", r and r.id == "release-6.6.0", r and r.id)
  check("release title", r and r.title == "What's new in 6.6.0", r and r.title)
  check("release takes first two bullets", r and #r.paragraphs == 2 and r.paragraphs[2] == "Two.")
  check("release action", r and r.action.type == "patch_notes")
  check("release flagged", r and r.isRelease == true and r.layout == "release" and r.date == "2026-10-05")
  check("no notes, no release", N.ReleaseStory(notes, "9.9.9") == nil)
  check("nil notes, no release", N.ReleaseStory(nil, "6.6.0") == nil)
  check("empty notes, no release", N.ReleaseStory({ ["1.0"] = { { section = "x", bullets = {} } } }, "1.0") == nil)

  local full = N.Feed({ { id = "x", priority = 999 } }, notes, "2026-10-06", "6.6.0")
  check("release story is first", ids(full) == "release-6.6.0,x", ids(full))
  check("feed with nothing is empty", #N.Feed(nil, nil, "2026-10-06", "6.6.0") == 0)

  -- Unread: the release story never counts (the What's new row badges it already).
  local root = {}
  local seen, first = N.EnsureSeen(root, full)
  check("first run creates the table", first == true and root.newsSeen == seen)
  check("first run marks existing stories seen", N.UnseenCount(full, seen) == 0)
  local more = N.Feed({ { id = "x" }, { id = "y" } }, notes, "2026-10-06", "6.6.0")
  local seen2, first2 = N.EnsureSeen(root, more)
  check("second run is not first", first2 == false and seen2 == seen)
  check("a new story is unseen", N.UnseenCount(more, seen2) == 1, N.UnseenCount(more, seen2))
  N.MarkSeen(more, seen2)
  check("mark seen clears it", N.UnseenCount(more, seen2) == 0)
  check("release id never stored", seen2["release-6.6.0"] == nil)
  check("Today is ISO", type(N.Today()) == "string")

  -- Release story extras: summary, blocks, modules, posted date.
  local rn = { ["6.7.0"] = { date = "2026-10-05",
    { section = "New Features", bullets = { "Focus (Forever): a thing.", "Vista: other thing." } },
    { section = "Fixes", bullets = { "Focus: third." } } } }
  local r2 = N.ReleaseStory(rn, "6.7.0")
  check("release summary is the first bullet", r2.summary == "Focus (Forever): a thing.", r2.summary)
  check("release blocks are one list of two", #r2.blocks == 1 and r2.blocks[1].kind == "list"
    and #r2.blocks[1].items == 2 and r2.blocks[1].items[2] == "Vista: other thing.")
  check("release modules distinct and lowercased", #r2.modules == 2 and r2.modules[1] == "focus" and r2.modules[2] == "vista")
  check("release fromDate", r2.fromDate == "2026-10-05")
  check("release keeps paragraphs", #r2.paragraphs == 2)
  check("no module prefix gives no modules", #r.modules == 0)
  local r3 = N.ReleaseStory({ ["1.0"] = { { section = "x", bullets = { "Focus on speed: yes.", "Nonsense: x" } } } }, "1.0")
  check("only a leading Module: prefix counts", #r3.modules == 0, #r3.modules)
  local r4 = N.ReleaseStory({ ["1.0"] = { { section = "x", bullets = { "Echo: a", "Axis: b" } },
    { section = "y", bullets = { "Essence: c", "Insight: d" } } } }, "1.0")
  check("modules capped by the two bullets taken", #r4.modules == 2)

  -- PostedLabel buckets.
  local P = N.PostedLabel
  check("same day is Today", P("2026-10-08", "2026-10-08") == "Today", P("2026-10-08", "2026-10-08"))
  check("future is Today", P("2026-10-20", "2026-10-08") == "Today")
  check("one day is Yesterday", P("2026-10-07", "2026-10-08") == "Yesterday")
  check("2 days", P("2026-10-06", "2026-10-08") == "2 days ago", P("2026-10-06", "2026-10-08"))
  check("6 days", P("2026-10-02", "2026-10-08") == "6 days ago", P("2026-10-02", "2026-10-08"))
  check("7 days is a date", P("2026-10-01", "2026-10-08") == "1 Oct", P("2026-10-01", "2026-10-08"))
  check("older is day and month", P("2026-03-12", "2026-10-08") == "12 Mar", P("2026-03-12", "2026-10-08"))
  check("month boundary yesterday", P("2026-09-30", "2026-10-01") == "Yesterday")
  check("month boundary 5 days", P("2026-09-26", "2026-10-01") == "5 days ago", P("2026-09-26", "2026-10-01"))
  check("year boundary yesterday", P("2025-12-31", "2026-01-01") == "Yesterday")
  check("year boundary 3 days", P("2025-12-29", "2026-01-01") == "3 days ago", P("2025-12-29", "2026-01-01"))
  check("leap day counted", P("2024-02-28", "2024-03-01") == "2 days ago", P("2024-02-28", "2024-03-01"))
  check("non-leap Feb", P("2026-02-28", "2026-03-01") == "Yesterday")
  check("other year shows year", P("2025-10-12", "2026-10-08") == "12 Oct 2025", P("2025-10-12", "2026-10-08"))
  check("nil date", P(nil, "2026-10-08") == nil)
  check("garbage date", P("soon", "2026-10-08") == nil)
  check("bad month", P("2026-13-01", "2026-10-08") == nil)
  check("bad today still labels the date", P("2026-10-01", "") == "1 Oct 2026", P("2026-10-01", ""))

  print(string.format("news_logic: %d passed, %d failed", pass, fail))
  if fail > 0 then error("failures") end
`, 'assertions');
