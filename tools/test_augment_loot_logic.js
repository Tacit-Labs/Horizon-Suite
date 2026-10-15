#!/usr/bin/env node
/**
 * Executable checks for Augment's auto-loot handling in AugmentEvents.lua:
 * the Faster auto-loot option (augmentFastLoot) and the held-back loot window
 * it shares LOOT_READY with.
 *
 * Why this exists. Fast loot calls LootSlot from addon code on every corpse,
 * so a mistake loots the wrong thing or nothing at all, and the only other
 * check is killing something in-game. The handlers are plain event code, so
 * they run in a Lua VM with the loot API stubbed and the events fired by hand.
 *
 * Covers in particular:
 *   - Off by default, and nothing is taken on a manual (non auto-loot) loot.
 *   - Every slot is taken, last to first, except empty and locked ones.
 *   - LOOT_READY repeating before or after LOOT_OPENED takes the loot once.
 *   - Items the game refuses still reveal the held-back window.
 *   - Items that cannot fit the bags are left and shown at once, counting
 *     stacks, profession bags and the reagent bag.
 *   - A client without LootSlot (Forever, should it differ) does not error.
 *
 * Usage:
 *   npm install fengari     # one dependency, not vendored
 *   node tools/test_augment_loot_logic.js
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

// --- Stub the slice of the WoW/addon environment AugmentEvents touches ------
run(`
  _G.HorizonSuite = {
    Augment = { state = {} },
    AUGMENT_DEFAULTS = {}, AUGMENT_LIMITS = {},
    db = {},
    GetDB = function(k, d)
      local v = _G.HorizonSuite.db[k]
      if v ~= nil then return v end
      return d
    end,
    SetDB = function(k, v) _G.HorizonSuite.db[k] = v end,
    IsModuleEnabled = function() return true end,
    Log = {
      createPanel = function() return { Show = function() end, Hide = function() end } end,
      registerTag = function() end, enableTag = function() end, debug = function() end,
    },
    gamepad = false,
  }
  HorizonSuite.Platform = { IsGamepadUI = function() return HorizonSuite.gamepad end }

  -- Timers run only when the test says so.
  now = 100
  timers = {}
  function GetTime() return now end
  C_Timer = {
    After = function(delay, fn) timers[#timers + 1] = { at = now + delay, fn = fn } end,
    NewTicker = function() return { Cancel = function() end } end,
  }
  function advance(dt)
    now = now + dt
    local due, keep = {}, {}
    for _, t in ipairs(timers) do
      if t.at <= now then due[#due + 1] = t else keep[#keep + 1] = t end
    end
    timers = keep
    for _, t in ipairs(due) do t.fn() end
  end

  function UnitGUID() return "Player-1" end
  function CreateFrame()
    local f = { events = {} }
    function f:SetScript(_, fn) self.onEvent = fn end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterAllEvents() self.events = {} end
    eventFrame = f
    return f
  end

  -- Blizzard's loot window: records whether it will open, and each open.
  windowOpens = {}
  LootFrame = { registered = { LOOT_OPENED = true } }
  function LootFrame:IsEventRegistered(e) return self.registered[e] == true end
  function LootFrame:RegisterEvent(e) self.registered[e] = true end
  function LootFrame:UnregisterEvent(e) self.registered[e] = nil end
  function LootFrame:GetScript()
    return function(_, event, autoLoot) windowOpens[#windowOpens + 1] = { event = event, autoLoot = autoLoot } end
  end

  -- The corpse. slots[i] = false once taken, else a table:
  --   locked, refuse (the game says no), money, qty, stack (max stack size),
  --   have (count already carried), family (profession bag bits), reagent,
  --   uncached (item info not loaded yet).
  slots = {}
  looted = {}
  closed = 0
  function GetNumLootItems() return #slots end
  function LootSlotHasItem(i) return slots[i] and true or false end
  function GetLootSlotInfo(i)
    local s = slots[i]
    if not s then return nil end
    return 134400, "Item " .. i, s.qty or 1, nil, 1, s.locked or false
  end
  Enum = { LootSlotType = { None = 0, Item = 1, Money = 2, Currency = 3 } }
  function GetLootSlotType(i)
    local s = slots[i]
    if not s then return 0 end
    return s.money and 2 or 1
  end
  function GetLootSlotLink(i) return slots[i] and ("item:" .. i) or nil end
  local function slotOf(link) return slots[tonumber(link:match("item:(%d+)"))] end
  C_Item = {
    GetItemInfo = function(link)
      local s = slotOf(link)
      if not s or s.uncached then return nil end
      local r = {}
      r[1], r[8], r[17] = "Item", s.stack or 1, s.reagent or false
      return table.unpack(r, 1, 17)
    end,
    GetItemCount = function(link) local s = slotOf(link); return s and s.have or 0 end,
    GetItemFamily = function(link) local s = slotOf(link); return s and s.family or 0 end,
  }
  bit = { band = function(a, b) return a & b end }
  function LootSlot(i)
    looted[#looted + 1] = i
    if slots[i] and not slots[i].refuse then slots[i] = false end
  end
  function CloseLoot() closed = closed + 1 end
  NUM_BAG_SLOTS = 4
  NUM_REAGENTBAG_SLOTS = 1
  -- bag 0: general; bag 1: a profession bag; bag 5: the reagent bag.
  freeSlots, profFree, profFamily, reagentFree = 20, 0, 0, 0
  C_Container = { GetContainerNumFreeSlots = function(bag)
    if bag == 0 then return freeSlots, 0 end
    if bag == 1 then return profFree, profFamily end
    if bag == 5 then return reagentFree, 0 end
    return 0, 0
  end }
  function bags(general, prof, family, reagent)
    freeSlots, profFree, profFamily, reagentFree = general, prof or 0, family or 0, reagent or 0
  end

  function fire(event, ...) eventFrame.onEvent(eventFrame, event, ...) end
  function reset(newSlots)
    fire("LOOT_CLOSED")
    slots, looted, windowOpens, timers = newSlots, {}, {}, {}
  end
  function list(t)
    local out = {}
    for i, v in ipairs(t) do out[i] = tostring(v) end
    return table.concat(out, ",")
  end
`, 'stubs');

run(read('options/modules/defaults/augment/OptionsDefaultsAugmentLootFrame.lua'), 'Defaults');
run(read('modules/Augment/LootFrame/AugmentEvents.lua'), 'AugmentEvents');

// --- Assertions -----------------------------------------------------------
run(`
  local addon = HorizonSuite
  local pass, fail = 0, 0
  local function check(name, ok, got)
    if ok then pass = pass + 1
    else fail = fail + 1; print("  FAIL: " .. name .. "  got: " .. tostring(got)) end
  end

  addon.Augment.EnableEvents()
  check("events registered", eventFrame and eventFrame.events.LOOT_READY, eventFrame)

  -- Off by default: Blizzard's auto-loot does the taking.
  check("fast loot defaults off", addon.AUGMENT_DEFAULTS.augmentFastLoot == false, addon.AUGMENT_DEFAULTS.augmentFastLoot)
  reset({ {}, {}, {} })
  fire("LOOT_READY", true)
  check("off: nothing taken", #looted == 0, list(looted))
  check("off: window still held back for auto-loot", not LootFrame:IsEventRegistered("LOOT_OPENED"), "registered")

  addon.db.augmentFastLoot = true

  -- Every slot, last to first, skipping the empty and the locked.
  reset({ {}, false, { locked = true }, {}, {} })
  fire("LOOT_READY", true)
  check("on: takes unlocked slots last to first", list(looted) == "5,4,1", list(looted))

  -- LOOT_READY repeats: before LOOT_OPENED (guard) and after it (lootOpen).
  fire("LOOT_READY", true)
  check("repeat before LOOT_OPENED takes nothing more", list(looted) == "5,4,1", list(looted))
  fire("LOOT_OPENED", true)
  fire("LOOT_READY", true)
  check("repeat after LOOT_OPENED takes nothing more", list(looted) == "5,4,1", list(looted))

  -- A manual loot (auto-loot off, or the modifier held) is left alone.
  reset({ {}, {} })
  fire("LOOT_READY", false)
  check("manual loot: nothing taken", #looted == 0, list(looted))
  check("manual loot: window opens", LootFrame:IsEventRegistered("LOOT_OPENED"), "unregistered")

  -- LOOT_CLOSED ends the loot, so the next corpse is taken at once.
  reset({ {}, {} })
  fire("LOOT_READY", true)
  check("next loot after LOOT_CLOSED is taken", list(looted) == "2,1", list(looted))

  -- If LOOT_CLOSED never comes, the guard expires rather than sticking.
  slots, looted = { {} }, {}
  advance(0.2)
  fire("LOOT_READY", true)
  check("within the guard: not taken again", #looted == 0, list(looted))
  advance(1.0)
  fire("LOOT_READY", true)
  check("guard expires without LOOT_CLOSED", list(looted) == "1", list(looted))

  -- Full bags: the game refuses a slot and raises a UI error. The held window
  -- must still reveal what is left, as a manual loot.
  reset({ {}, { refuse = true } })
  fire("LOOT_READY", true)
  fire("LOOT_OPENED", true)
  fire("UI_ERROR_MESSAGE", 3, "Inventory is full.")
  advance(0)
  check("refused item reveals the window", #windowOpens == 1 and windowOpens[1].autoLoot == false, #windowOpens)

  -- No error raised: the 0.5s fallback reveals it instead.
  reset({ { refuse = true } })
  fire("LOOT_READY", true)
  fire("LOOT_OPENED", true)
  advance(0.6)
  check("fallback reveals a refused item", #windowOpens == 1, #windowOpens)

  -- Everything taken: the window never opens.
  reset({ {}, {} })
  fire("LOOT_READY", true)
  fire("LOOT_OPENED", true)
  advance(0.6)
  check("all taken: window stays shut", #windowOpens == 0, #windowOpens)

  -- Gamepad UI (#468): the bag check counts the loot before fast loot takes it,
  -- so loot that does not fit still lets Blizzard open its own window.
  addon.gamepad = true
  reset({ {}, {}, {} })
  fire("LOOT_READY", true)
  check("gamepad: loot that fits is held back", not LootFrame:IsEventRegistered("LOOT_OPENED"), "registered")
  freeSlots = 1
  reset({ {}, {}, {} })
  fire("LOOT_READY", true)
  check("gamepad: loot that does not fit opens Blizzard's window", LootFrame:IsEventRegistered("LOOT_OPENED"), "held")
  check("gamepad: fast loot takes what fits", list(looted) == "3", list(looted))
  addon.gamepad = false
  freeSlots = 20

  -- Bag-space check: items that cannot fit are left, and the held window
  -- shows them as soon as it opens rather than after the 0.5s fallback.
  bags(0)
  reset({ {}, { money = true }, {} })
  fire("LOOT_READY", true)
  check("full bags: money taken, items left", list(looted) == "2", list(looted))
  fire("LOOT_OPENED", true)
  check("full bags: window shows at once", #windowOpens == 1 and windowOpens[1].autoLoot == false, #windowOpens)
  advance(0.6)
  check("full bags: the fallback does not show it again", #windowOpens == 1, #windowOpens)

  bags(1)
  reset({ {}, {}, {} })
  fire("LOOT_READY", true)
  check("one free slot: one item taken", list(looted) == "3", list(looted))

  bags(0)
  reset({ { stack = 20, have = 15, qty = 3 } })
  fire("LOOT_READY", true)
  check("room on a carried stack: taken", list(looted) == "1", list(looted))
  reset({ { stack = 20, have = 15, qty = 6 } })
  fire("LOOT_READY", true)
  check("stack without room for the whole loot: left", #looted == 0, list(looted))
  reset({ { stack = 20, have = 40, qty = 1 } })
  fire("LOOT_READY", true)
  check("only full stacks carried: left", #looted == 0, list(looted))

  bags(0, 1, 0x20)
  reset({ { family = 0x20 }, { family = 0x20 }, {} })
  fire("LOOT_READY", true)
  check("profession bag takes one of its own kind, nothing else", list(looted) == "2", list(looted))

  bags(0, 0, 0, 1)
  reset({ { reagent = true }, {} })
  fire("LOOT_READY", true)
  check("reagent bag takes a reagent only", list(looted) == "1", list(looted))

  bags(0)
  reset({ { uncached = true } })
  fire("LOOT_READY", true)
  check("uncached item info: taken, the game decides", list(looted) == "1", list(looted))

  -- A locked slot also shows at once.
  bags(20)
  reset({ { locked = true }, {} })
  fire("LOOT_READY", true)
  fire("LOOT_OPENED", true)
  check("locked slot: window shows at once", #windowOpens == 1, #windowOpens)

  -- Without the item API the check takes everything rather than erroring.
  bags(0)
  local savedItem = C_Item
  C_Item = nil
  reset({ {}, {} })
  local okItem, errItem = pcall(fire, "LOOT_READY", true)
  check("missing item API does not error", okItem, errItem)
  check("missing item API takes everything", list(looted) == "2,1", list(looted))
  C_Item = savedItem
  bags(20)

  -- A client without the loot API (Forever, should it differ) must not error.
  local savedLootSlot = LootSlot
  LootSlot = nil
  reset({ {} })
  local ok, err = pcall(fire, "LOOT_READY", true)
  check("missing LootSlot does not error", ok, err)
  LootSlot = savedLootSlot

  print(("augment loot: %d passed, %d failed"):format(pass, fail))
  if fail > 0 then error("augment loot logic failed") end
`, 'assertions');
