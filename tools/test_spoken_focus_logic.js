#!/usr/bin/env node
/**
 * Executable checks for the Spoken integration in modules/Focus/integrations/SpokenFocus.lua.
 *
 * Why this exists. The integration calls Spoken internals (VoiceOver.QuestOverlayUI and
 * Spoken:DressBoxButton), not a public API. These checks run the real file against a stub
 * Spoken to pin down two things an in-game test can't easily show: which rows get Play, and
 * that a Spoken missing a function, raising, or an older "VoiceOver" addon in its place
 * hides the button instead of erroring inside Focus's layout.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_spoken_focus_logic.js
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

const REPO = path.resolve(__dirname, '..') + '/';
const SPOKEN_FOCUS = fs
  .readFileSync(REPO + 'modules/Focus/integrations/SpokenFocus.lua', 'utf8')
  .replace(/^﻿/, '');

// Just enough of the addon and the client for the file to load and draw one row.
const STUBS = `
  refreshes, invalidations = 0, 0
  HorizonSuite = {
    TITLE_SIZE = 13,
    Scaled = function(v) return v end,
    focus = { InvalidatePopulateCache = function() invalidations = invalidations + 1 end },
    ScheduleRefresh = function() refreshes = refreshes + 1 end,
  }

  local function Frame(parent)
    local f = { shown = true, level = 1, parent = parent, scripts = {}, events = {} }
    function f:SetSize(w, h) self.w, self.h = w, h end
    function f:SetHitRectInsets() end
    function f:Hide() self.shown = false end
    function f:Show() self.shown = true end
    function f:IsShown() return self.shown end
    function f:GetFrameLevel() return self.level end
    function f:SetFrameLevel(l) self.level = l end
    function f:ClearAllPoints() self.point = nil end
    function f:SetPoint(...) self.point = { ... } end
    function f:RegisterEvent(e) self.events[#self.events + 1] = e end
    function f:SetScript(k, fn) self.scripts[k] = fn end
    function f:CreateTexture()
      return { SetPoint = function() end, SetColorTexture = function() end }
    end
    return f
  end
  frames = {}
  CreateFrame = function(_, _, parent)
    local f = Frame(parent)
    frames[#frames + 1] = f
    return f
  end

  hooksecurefunc = function(t, key, post)
    local orig = t[key]
    t[key] = function(...) local r = orig(...); post(...); return r end
  end

  C_QuestLog = { GetTitleForQuestID = function(id) return "Quest " .. id end }

  -- A row: title at (10, -2) in a 13px font.
  function NewEntry()
    local e = Frame()
    e.level = 5
    e.titleText = {
      GetPoint = function() return "TOPLEFT", e, "TOPLEFT", 10, -2 end,
      GetFont = function() return "font", 13 end,
    }
    return e
  end

  -- Spoken as Spoken_Quests 3.9.0 lays it out: core global Spoken, quest addon env VoiceOver.
  voiced = { [748] = true, [749] = true }
  callbacks = {}
  function InstallSpoken()
    Spoken = {
      DressBoxButton = function(_, b)
        function b:SetBox(atlas, w, h) self.atlas, self.boxW, self.boxH = atlas, w, h end
      end,
      RegisterCallback = function(_, event, fn) callbacks[event] = fn end,
    }
    VoiceOver = {
      AddonFolder = "Spoken_Quests",
      QuestOverlayUI = {
        ShowsTrackerButton = function(_, id) return voiced[id] and true or false end,
        BindPlayButton = function(_, b, id, title, origin)
          b.questID, b.boundTitle, b.origin = id, title, origin
        end,
        SetPlayButtonState = function(_, b) b.stateSet = (b.stateSet or 0) + 1 end,
        FollowQueue = function() end,
        UpdateTrackerButtons = function() end,
      },
    }
  end
`;

const CHECKS = `
  local sp = HorizonSuite.focus.spoken
  local results = {}
  local function check(label, ok, got)
    results[#results + 1] = (ok and "ok   " or "FAIL ") .. label .. (ok and "" or ("  (got " .. tostring(got) .. ")"))
  end

  -- Without Spoken
  check("no Spoken: inactive", not sp.IsActive())
  check("no Spoken: no Play", sp.ShouldShow({ questID = 748 }) == false)
  local bare = NewEntry()
  sp.Render(bare, { questID = 748 }, true, 0)
  check("no Spoken: no button made", bare.spokenPlayBtn == nil)

  -- The older VoiceOver addon has the same global and a different folder.
  Spoken = { DressBoxButton = function() end }
  VoiceOver = { AddonFolder = "AI_VoiceOver", QuestOverlayUI = {} }
  check("old VoiceOver addon: inactive", not sp.IsActive())

  InstallSpoken()
  check("Spoken loaded: active", sp.IsActive())

  -- Which rows
  check("voiced quest: Play", sp.ShouldShow({ questID = 748 }) == true)
  check("unvoiced quest: no Play", sp.ShouldShow({ questID = 1 }) == false)
  check("rare row: no Play", sp.ShouldShow({ questID = 748, isRare = true }) == false)
  check("achievement row: no Play", sp.ShouldShow({ questID = 748, isAchievement = true }) == false)
  check("recipe row: no Play", sp.ShouldShow({ questID = 748, isRecipe = true }) == false)
  check("appearance row: no Play", sp.ShouldShow({ questID = 748, category = "APPEARANCE" }) == false)
  check("row with no quest ID: no Play", sp.ShouldShow({ entryKey = "x" }) == false)

  -- Drawing
  local e = NewEntry()
  sp.Render(e, { questID = 748, title = "Poison Water" }, true, 30)
  local b = e.spokenPlayBtn
  check("button made", b ~= nil)
  check("button shown", b and b:IsShown())
  check("button parented to the row", b and b.parent == e)
  check("button is Spoken's tracker box", b and b.atlas == "QuestLog-icon-ticksquare" and b.boxW == 14, b and b.atlas)
  check("button bound to the quest", b and b.questID == 748, b and b.questID)
  check("title from the quest log", b and b.boundTitle == "Quest 748", b and b.boundTitle)
  check("origin names Focus", b and b.origin and b.origin:find("Focus", 1, true) ~= nil, b and b.origin)
  check("state set", b and b.stateSet == 1, b and b.stateSet)
  check("above the row", b and b.level == 8, b and b.level)
  local p = b and b.point or {}
  check("right edge in from the gutter", p[1] == "TOPRIGHT" and p[2] == e and p[4] == -30, tostring(p[1]) .. " " .. tostring(p[4]))
  -- A 14px box on a 13px line sits at the title's top.
  check("level with the title", p[5] == -2, p[5])

  -- A pooled row drawn again for another quest drops the old quest's line.
  b.soundData = { questID = 748 }
  sp.Render(e, { questID = 749 }, true, 0)
  check("same button reused", e.spokenPlayBtn == b)
  check("rebound to the new quest", b.questID == 749, b.questID)
  check("old line dropped", b.soundData == nil)
  b.soundData = { questID = 749 }
  sp.Render(e, { questID = 749 }, true, 0)
  check("same quest keeps its line", b.soundData ~= nil)

  sp.Render(e, { questID = 1 }, false, 0)
  check("hidden when not shown", not b:IsShown())
  sp.Render(e, { questID = 748 }, true, 0)
  sp.Clear(e)
  check("hidden on clear", not b:IsShown())

  -- Spoken missing a function, or raising: no Play, no error.
  local bind = VoiceOver.QuestOverlayUI.BindPlayButton
  VoiceOver.QuestOverlayUI.BindPlayButton = nil
  check("missing BindPlayButton: inactive", not sp.IsActive())
  VoiceOver.QuestOverlayUI.BindPlayButton = function() error("changed") end
  local e2 = NewEntry()
  local ok = pcall(sp.Render, e2, { questID = 748 }, true, 0)
  check("BindPlayButton raising: no error", ok)
  check("BindPlayButton raising: hidden", e2.spokenPlayBtn and not e2.spokenPlayBtn:IsShown())
  VoiceOver.QuestOverlayUI.BindPlayButton = bind
  VoiceOver.QuestOverlayUI.ShowsTrackerButton = function() error("changed") end
  ok = pcall(sp.ShouldShow, { questID = 748 })
  check("ShowsTrackerButton raising: no error", ok)
  check("ShowsTrackerButton raising: no Play", sp.ShouldShow({ questID = 748 }) == false)

  -- Redraws: packs loading, Spoken Quests switched, Spoken's tracker checkbox.
  InstallSpoken()
  refreshes, invalidations = 0, 0
  sp.Listen()
  check("listens for packs", callbacks.VOICE_PACKS_LOADED ~= nil)
  check("listens for the part switch", callbacks.PART_SWITCHED ~= nil)
  refreshes, invalidations = 0, 0
  callbacks.VOICE_PACKS_LOADED()
  check("packs loaded: cache dropped and redraw", invalidations == 1 and refreshes == 1, refreshes)
  callbacks.PART_SWITCHED("zones")
  check("another part switched: no redraw", refreshes == 1, refreshes)
  callbacks.PART_SWITCHED("quests")
  check("quests switched: redraw", refreshes == 2, refreshes)

  -- Last: a Spoken whose box button fails is not retried on every row.
  Spoken.DressBoxButton = function() error("changed") end
  local e3 = NewEntry()
  ok = pcall(sp.Render, e3, { questID = 748 }, true, 0)
  check("box button failing: no error", ok)
  check("box button failing: no button", e3.spokenPlayBtn == nil)
  check("box button failing: off for the session", not sp.IsActive())

  return table.concat(results, "\\n")
`;

// Spoken's tracker checkbox is hooked on the env Listen() finds, so check it on its own state.
const HOOK = `
  InstallSpoken()
  refreshes = 0
  HorizonSuite.focus.spoken.Listen()
  refreshes = 0
  VoiceOver.QuestOverlayUI.UpdateTrackerButtons()
  return refreshes == 1 and "ok   tracker checkbox: redraw" or ("FAIL tracker checkbox: redraw  (got " .. refreshes .. ")")
`;

function run(body) {
  const L = lauxlib.luaL_newstate();
  lualib.luaL_openlibs(L);
  const chunk = STUBS + '\n' + SPOKEN_FOCUS + '\n' + body;
  if (lauxlib.luaL_loadstring(L, to_luastring(chunk)) !== 0 || lua.lua_pcall(L, 0, 1, 0) !== 0) {
    return 'FAIL load: ' + to_jsstring(lua.lua_tostring(L, -1));
  }
  return to_jsstring(lua.lua_tostring(L, -1));
}

const out = [run(CHECKS), run(HOOK)].join('\n');
console.log(out);
const failures = out.split('\n').filter((l) => l.startsWith('FAIL')).length;
console.log(failures ? failures + ' failed' : 'all passed');
process.exit(failures ? 1 : 0);
