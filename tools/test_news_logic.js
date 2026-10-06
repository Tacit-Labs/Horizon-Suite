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

  print(string.format("news_logic: %d passed, %d failed", pass, fail))
  if fail > 0 then error("failures") end
`, 'assertions');
