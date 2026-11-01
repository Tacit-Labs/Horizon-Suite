#!/usr/bin/env node
/**
 * Executable checks for the achievement/instance probe in
 * modules/Focus/providers/FocusAchievementInstance.lua.
 *
 * Why this exists. The probe guesses which instance an achievement belongs to
 * from the Encounter Journal and achievement criteria, because the client's own
 * Achievement.Instance_ID is not exposed to Lua. These checks run the real matcher
 * against a small fake journal so each signal (encounter ID, instance name, boss
 * name, category) and each non-match (colliding kill-creature asset, too-short
 * boss name) is pinned down without logging into the game.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_focus_achievement_instance.js
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
const PROBE = fs
  .readFileSync(REPO + 'modules/Focus/providers/FocusAchievementInstance.lua', 'utf8')
  .replace(/^﻿/, '');

// A two-tier Encounter Journal, a category tree and a handful of achievements.
const STUBS = `
  HorizonSuite = {}
  C_Timer = { After = function(_, fn) fn() end }

  local TIERS = {
    {
      name     = "Burning Crusade",
      dungeons = { { id = 63, name = "The Deadmines" }, { id = 236, name = "Stratholme - Main Gate" },
                   { id = 237, name = "Stratholme - Service Entrance" }, { id = 249, name = "Magisters' Terrace" } },
      raids    = { { id = 741, name = "Molten Core" }, { id = 745, name = "Karazhan" }, { id = 749, name = "The Eye" } },
    },
    {
      name     = "Shadowlands",
      dungeons = { { id = 64, name = "Shadowfang Keep" }, { id = 716, name = "Eye of Azshara" },
                   { id = 1067, name = "The Deadmines" } },
      raids    = { { id = 322, name = "Pandaria" }, { id = 860, name = "Return to Karazhan" },
                   { id = 78, name = "Firelands" }, { id = 1190, name = "Castle Nathria" } },
    },
    {
      name     = "Wrath of the Lich King",
      dungeons = { { id = 276, name = "Halls of Reflection" } },
      raids    = { { id = 758, name = "Icecrown Citadel" } },
    },
  }
  -- [journalInstanceID] = dungeonAreaMapID; 424 is a continent (world-boss page).
  local AREA_MAP = { [322] = 424, [63] = 291 }
  local MAP_TYPE = { [424] = 2, [291] = 4 }
  -- [journalInstanceID] = { { name, dungeonEncounterID, mapID, creatures } }
  local ENCOUNTERS = {
    [63]  = { { "Glubtok", 1064, 36 }, { "Edwin VanCleef", 2001, 36 } },
    [741] = { { "Ragnaros", 672, 409 }, { "Ook", 673, 409 } },
    [64]  = { { "Lord Godfrey", 1072, 33, { "Lord Godfrey", "Baron Ashbury" } } },
    [236] = { { "Balnazzar", 484, 329 } },
    [322] = { { "Sha of Anger", 691, 870 } },
    [1067] = { { "Edwin VanCleef", 2001, 36 } },
    [237] = { { "Baron Rivendare", 456, 329 } },
    [78]  = { { "Ragnaros", 1203, 720 } },
    [249] = { { "Kael'thas Sunstrider", 1894, 585 } },
    [1190] = { { "Sun King's Salvation", 2402, 2296, { "Kael'thas Sunstrider" } } },
    [276] = { { "The Lich King", 1990, 668 } },
    [758] = { { "The Lich King", 856, 631 } },
  }
  selectedInstance = nil
  EJ_SelectInstance = function(id) selectedInstance = id end
  EJ_GetInstanceInfo = function(id) return "", "", 0, 0, 0, 0, AREA_MAP[id] or 0 end
  selectedTier = 2
  EJ_GetNumTiers = function() return #TIERS end
  EJ_GetTierInfo = function(t) return TIERS[t] and TIERS[t].name, "" end
  EJ_GetCurrentTier = function() return selectedTier end
  EJ_SelectTier = function(t) selectedTier = t end
  EJ_GetInstanceByIndex = function(i, isRaid)
    local list = TIERS[selectedTier][isRaid and "raids" or "dungeons"]
    local e = list[i]
    if e then return e.id, e.name end
  end
  -- Like the live client: the ID argument is ignored and the selected instance is read.
  EJ_GetEncounterInfoByIndex = function(i, _)
    local journalID = selectedInstance
    local e = journalID and ENCOUNTERS[journalID] and ENCOUNTERS[journalID][i]
    if not e then return nil end
    -- name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID
    return e[1], "", journalID * 100 + i, 0, "", journalID, e[2], e[3]
  end
  EJ_GetCreatureInfo = function(c, journalEncounterID)
    local journalID, i = math.floor(journalEncounterID / 100), journalEncounterID % 100
    local e = ENCOUNTERS[journalID] and ENCOUNTERS[journalID][i]
    local names = e and e[4]
    if names and names[c] then return c, names[c] end
  end
  EJ_GetInstanceForMap = function(uiMapID) return UIMAP_TO_JOURNAL[uiMapID] or 0 end
  UIMAP_TO_JOURNAL = { [291] = 63 }

  PLAYER = { name = "Orgrimmar", type = "none", map = 1, uiMap = 85 }
  GetInstanceInfo = function() return PLAYER.name, PLAYER.type, 2, "Heroic", 5, 0, false, PLAYER.map end
  C_Map = {
    GetBestMapForUnit = function() return PLAYER.uiMap end,
    GetMapInfo = function(id) if MAP_TYPE[id] then return { mapType = MAP_TYPE[id] } end end,
  }

  local CATEGORIES = {
    [168]   = { "Dungeons & Raids", -1 },
    [14808] = { "Classic", 168 },
    [9001]  = { "Shadowfang Keep", 168 },
    [92]    = { "General", -1 },
    [14805] = { "The Burning Crusade", 168 },
    [14823] = { "Lich King Raid", 168 },
  }
  local CATEGORY_ACHIEVEMENTS = {
    [14808] = { 100, 101, 102, 103, 104, 105, 107, 108, 109, 110, 111 },
    [9001]  = { 106 },
    [92]    = { 200 },
    [14805] = { 112, 113 },
    [14823] = { 114, 115 },
    [168]   = {},
  }
  -- [id] = { title, description, criteria = { { text, type, assetID } } }
  ACH = {
    [100] = { "Heroic: Deadmines", "Defeat Edwin VanCleef in the Deadmines on Heroic difficulty.", {} },
    [101] = { "Hot Pursuit", "Earn this somewhere hot.", { { "Ragnaros defeated", 165, 672 } } },
    [102] = { "Collision Course", "Kill Bob.", { { "Bob", 0, 672 } } },
    [103] = { "Worgen Hunter", "Hunt worgen.", { { "Lord Godfrey", 0, 46964 } } },
    [104] = { "Brute Force", "Defeat Ook the Brute.", {} },
    [105] = { "Glory of the Classic Hero", "Complete the Deadmines and Molten Core achievements listed below.",
              { { "Heroic: Deadmines", 8, 100 } } },
    [106] = { "Keep Explorer", "Explore every room.", {} },
    [107] = { "Stratholme", "Defeat Baron Rivendare in Stratholme.", {} },
    [108] = { "Mythic: Eye of Azshara", "Defeat Wrath of Azshara in the Eye of Azshara on Mythic.", {} },
    [109] = { "Took the Red Eye Down", "Defeat something with a red eye.", {} },
    [110] = { "Heroic: Return to Karazhan", "Defeat Viz'aduum in Return to Karazhan on Heroic.", {} },
    [111] = { "Minutes to Midnight", "Defeat Pandaria's champions before midnight.", {} },
    [112] = { "Molten Core", "Defeat Ragnaros.", {} },
    [113] = { "Prince of Fire", "Defeat Kael'thas Sunstrider.", {} },
    [114] = { "Neck-Deep in Vile", "Defeat The Lich King without anyone dying.", {} },
    [115] = { "Glory of the Icecrown Raider", "Complete the achievements listed below.",
              { { "Neck-Deep in Vile", 8, 114 } } },
    [200] = { "Level 10", "Reach level 10.", {} },
  }
  local ACH_CATEGORY = {}
  for cat, ids in pairs(CATEGORY_ACHIEVEMENTS) do
    for _, id in ipairs(ids) do ACH_CATEGORY[id] = cat end
  end

  GetCategoryList = function()
    local out = {}
    for id in pairs(CATEGORIES) do out[#out + 1] = id end
    table.sort(out)
    return out
  end
  GetCategoryInfo = function(id)
    local c = CATEGORIES[id]
    if c then return c[1], c[2], 0 end
  end
  GetCategoryNumAchievements = function(id) return #(CATEGORY_ACHIEVEMENTS[id] or {}) end
  GetAchievementCategory = function(id) return ACH_CATEGORY[id] end
  GetAchievementInfo = function(a, b)
    local id = a
    if b then id = CATEGORY_ACHIEVEMENTS[a] and CATEGORY_ACHIEVEMENTS[a][b] end
    local e = id and ACH[id]
    if not e then return nil end
    return id, e[1], 10, false, nil, nil, nil, e[2]
  end
  GetAchievementNumCriteria = function(id) return #((ACH[id] or {})[3] or {}) end
  GetAchievementCriteriaInfo = function(id, i)
    local c = ACH[id][3][i]
    if not c then return nil end
    return c[1], c[2], false, 0, 1, "", 0, c[3], "", i
  end
`;

const HELPERS = `
  local AI = HorizonSuite.AchievementInstance

  -- "Name[signals]" for each instance the achievement links to, sorted.
  function links(achID)
    local out = {}
    for _, m in ipairs(AI.FindInstances(AI.GetAchievementFacts(achID))) do
      local s = {}
      for _, k in ipairs({ "encounter", "name", "boss", "category", "meta" }) do
        if m.hit[k] then s[#s + 1] = k end
      end
      out[#out + 1] = m.label .. "[" .. table.concat(s, "+") .. "]"
    end
    table.sort(out)
    return #out > 0 and table.concat(out, ", ") or "none"
  end

  function indexInfo()
    AI.ResetIndex()
    local idx = AI.GetInstanceIndex()
    return #idx.list .. " instances, tier " .. selectedTier
  end

  function indexLine()
    return AI.IndexSummary(AI.GetInstanceIndex())
  end

  function tracked(where)
    if where == "deadmines" then
      PLAYER.name, PLAYER.type, PLAYER.map, PLAYER.uiMap = "The Deadmines", "party", 36, 291
    elseif where == "mc-by-map" then
      PLAYER.name, PLAYER.type, PLAYER.map, PLAYER.uiMap = "Molten Core", "raid", 409, 999
    else
      PLAYER.name, PLAYER.type, PLAYER.map, PLAYER.uiMap = "Orgrimmar", "none", 1, 85
    end
    return table.concat(AI.TrackedReport({ 100, 101, 102 }), "\\n")
  end

  function scan()
    local text
    AI.RunScan(function(lines) text = table.concat(lines, "\\n") end)
    return text or "not finished"
  end
`;

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
const chunk = STUBS + '\n' + PROBE + '\n' + HELPERS;
if (lauxlib.luaL_loadstring(L, to_luastring(chunk)) !== 0 || lua.lua_pcall(L, 0, 0, 0) !== 0) {
  console.log('FAIL load: ' + to_jsstring(lua.lua_tostring(L, -1)));
  process.exit(1);
}

function call(fn, ...args) {
  lua.lua_getglobal(L, to_luastring(fn));
  for (const a of args) {
    if (typeof a === 'number') lua.lua_pushnumber(L, a);
    else lua.lua_pushstring(L, to_luastring(String(a)));
  }
  if (lua.lua_pcall(L, args.length, 1, 0) !== 0) return 'ERROR ' + to_jsstring(lua.lua_tostring(L, -1));
  const s = to_jsstring(lua.lua_tostring(L, -1));
  lua.lua_pop(L, 1);
  return s;
}

let failures = 0;
function check(label, actual, expected) {
  if (actual === expected) {
    console.log('ok   ' + label);
  } else {
    failures++;
    console.log('FAIL ' + label + ': expected "' + expected + '", got "' + actual + '"');
  }
}
function checkHas(label, text, needle) {
  if (text.includes(needle)) {
    console.log('ok   ' + label);
  } else {
    failures++;
    console.log('FAIL ' + label + ': "' + needle + '" not in:\n' + text);
  }
}

check('index walks every tier, skips world-boss pages, restores the tier', call('indexInfo'), '15 instances, tier 2');
checkHas('index reads bosses of every instance', call('indexLine'), '15 instances, 13 encounters');
check('instance name in title/description ("the" ignored); same-name entries count once', call('links', 100), 'The Deadmines[name+boss]');
check('wings of one instance merge and match the bare name', call('links', 107), 'Stratholme[name+boss]');
check('instance name beats a boss shared with another instance', call('links', 112), 'Molten Core[name+boss]');
check('expansion category picks between instances sharing a boss', call('links', 113), "Magisters' Terrace[boss]");
check('raid category picks the raid when a dungeon shares the boss', call('links', 114), 'Icecrown Citadel[boss]');
check('meta links through its sub-achievements', call('links', 115), 'Icecrown Citadel[meta]');
check('"The Eye" does not match inside "Eye of Azshara"', call('links', 108), 'Eye of Azshara[name]');
check('one-word "The Eye" keeps its "the"', call('links', 109), 'none');
check('"Karazhan" is dropped when "Return to Karazhan" matches', call('links', 110), 'Return to Karazhan[name]');
check('world-boss pages are not instances', call('links', 111), 'none');
check('Defeat Encounter criterion matches by DungeonEncounter ID', call('links', 101), 'Molten Core[encounter]');
check('kill-creature asset that collides with an encounter ID is ignored', call('links', 102), 'none');
check('criterion text naming a boss matches', call('links', 103), 'Shadowfang Keep[boss]');
check('boss names under four letters are ignored', call('links', 104), 'none');
check('meta naming two instances links to both', call('links', 105), 'Molten Core[name], The Deadmines[name]');
check('category titled with the instance name matches', call('links', 106), 'Shadowfang Keep[category]');

const inside = call('tracked', 'deadmines');
checkHas('current instance found through EJ_GetInstanceForMap', inside, 'Current instance: The Deadmines (journal 63');
checkHas('achievement for this instance is kept', inside, '[100] Heroic: Deadmines  -> SHOW here');
checkHas('achievement for another instance is hidden', inside, '[101] Hot Pursuit  -> HIDE here');
checkHas('unlinked achievement is hidden and says why', inside, '[102] Collision Course  -> HIDE here\n    no instance link found');

checkHas('current instance falls back to the map ID', call('tracked', 'mc-by-map'), '[101] Hot Pursuit  -> SHOW here');

const outside = call('tracked', 'world');
checkHas('outside an instance there is no verdict', outside, 'Current instance: none (not in an instance)');
checkHas('outside an instance links are still listed', outside, '[101] Hot Pursuit\n    Molten Core [encounter]');

const summary = call('scan');
checkHas('scan covers only Dungeons & Raids categories', summary, 'Scanned 16 Dungeons & Raids achievements');
checkHas('scan counts single links', summary, 'one instance:  11 (69%)');
checkHas('scan counts multiple links', summary, 'several:       1 (6%)');
checkHas('scan counts misses', summary, 'no link:       4 (25%)');
checkHas('scan lists the misses', summary, '[104] Brute Force');
checkHas('scan reports the journal index', summary, '1 world-boss pages skipped');
checkHas('scan breaks down signals', summary, 'by signal: encounter 1, name 6, boss 6, category 1, meta 1; boss/category only 4');

console.log(failures ? failures + ' failed' : 'all passed');
process.exit(failures ? 1 : 0);
