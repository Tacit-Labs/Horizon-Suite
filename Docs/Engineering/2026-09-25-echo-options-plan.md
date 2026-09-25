# Horizon Echo: Settings, Dashboard and Smooth Redraws Implementation Plan (5 of 6)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give Echo a full options page on the Horizon dashboard, apply every setting live, add the Blizzard whisper filter and mention keywords, and repaint the views once per frame instead of once per line.

**Architecture:**
- A new `EchoRedraw` collects "this view is dirty" marks and repaints each view once on the next frame.
- A new `EchoOptions` holds `Echo.ApplyOptions()`, the one function every setting change calls. It pushes the settings into the Store (tiers per kind), Events (keywords, feeds), History (the save switch), the filter and the frames (edge, scale, strata, card size, font).
- A new `EchoFilter` hides filed whispers from Blizzard's chat windows when the player asks for it.
- The options page is `options/modules/OptionsEcho.lua`, built like Essence's. `OptionsData_SetDB` routes Echo keys to `Echo.ApplyOptions`.
- Dashboard wiring adds `echo` to every hardcoded module list, as a preview module.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), and the fengari harness `tools/test_echo_logic.js`.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, sections "Options", "Storage" and "Carried into plan 5".

**Plan series:**
1. Foundation (done)
2. Tiles and stack (done)
3. Expanded card (done)
4. Feeds and live links (done)
5. **Settings, dashboard and smooth redraws (this plan)**
6. Looks and tidy-ups: tile icons, distinct channel glyphs, one tile painter and badge helper, scroll anchoring, drafts of closed conversations, the `upper()` fix.

All of it is on branch `feature/echo`.

## Global Constraints

- **Lua:** Lua 5.1 only, and runnable on fengari's 5.3. Don't use `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`.
- **File header:** every Echo file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, formatting, matching or indexing by a chat value. A secret text is passed to `SetText` **alone**. Never read a size from a FontString holding secret text. The chat filter receives raw event arguments; it may only hand them to `Events.BuildRecord`, which already obeys this rule.
- **Frame names:** no new named frames except the options page, which has none. Frames are non-secure.
- **Strings:** everything shown to the player goes through `addon.L` (`locales/horizon/enUS.lua`). Slash output included (Task 7). Add new keys in the Echo block at the end of the file (after `L["ECHO_SOMEONE"]`), aligned like the existing ones.
- **Settings keys (exact names and defaults, `addon.ECHO_DEFAULTS`):**

  | Key | Default | Range / values |
  |---|---|---|
  | `echoColumnEdge` | `"right"` | `"right"`, `"left"` |
  | `echoLockPosition` | `true` | |
  | `echoScale` | `1` | 0.6–1.6, slider in percent 60–160, step 5 |
  | `echoFrameStrata` | `"MEDIUM"` | `BACKGROUND`, `LOW`, `MEDIUM`, `HIGH`, `DIALOG` |
  | `echoMaxTiles` | `8` | 2–12 |
  | `echoToastStyle` | `"framed"` | `compact`, `framed`, `accent` |
  | `echoToastSeconds` | `4` | 2–10 |
  | `echoHoverDelay` | `0.35` | not on the page |
  | `echoHoldToastsInCombat` | `true` | |
  | `echoTierWhisper` … `echoTierSystem` | the `Store.DEFAULT_TIERS` value for that kind | `loud`, `count`, `quiet`, `muted` |
  | `echoKeywords` | `""` | comma-separated words |
  | `echoFeedLoot`, `echoFeedProgress`, `echoFeedSystem` | `true` | |
  | `echoSaveHistory` | `true` | |
  | `echoHideStoredWhispers` | `false` | |
  | `echoCardWidth` | `360` | 320–520, step 10 |
  | `echoCardHeight` | `440` | 320–640, step 10 |
  | `echoFontPath` | `"__global__"` | the shared per-element font list |

  The tier key for a kind is `"echoTier"` followed by the kind with its first letter upper-cased (`whisper` → `echoTierWhisper`, `bnet` → `echoTierBnet`). The feed key is `"echoFeed"` plus the capitalised kind.
- **Module colour:** Echo `#8FA3E8`, as `{ 0x8F/255, 0xA3/255, 0xE8/255 }` (0.561, 0.639, 0.910).
- **Preview module:** Echo is labelled **Preview** on the dashboard, like Essence, and is off on first install.
- **Commits:** Conventional Commits with scope `echo` (or `options` for dashboard-only files), on branch `feature/echo`, each with exactly one `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. Run `git add` and `git commit` as separate commands.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (636 passing at the start of this plan). It must stay green after every task.
- **Parse check:**
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8').replace(/^﻿/,'');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`
  Run it on every Lua file a task changes, including the options and dashboard files the harness doesn't load.
- **Stand-in frames:** `STUB_FRAME` / `STUB_CREATE_FRAME`. Frame sections set `CreateFrame = STUB_CREATE_FRAME` first. Use `rawget` to test that a field is absent. Per-object overrides are undone with `nil`. Stubs don't fire OnShow, OnHide or OnUpdate. Tests that swap `HorizonSuite.GetDB` restore it to `nil` at the end of their section.

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Echo/EchoRedraw.lua` | Create | One-frame dirty flags for the tiles, stack and card |
| `modules/Echo/EchoOptions.lua` | Create | `Echo.ApplyOptions`, `Echo.FontPath`, font tracking, key helpers |
| `modules/Echo/EchoFilter.lua` | Create | Hides filed whispers from Blizzard's chat windows |
| `modules/Echo/EchoStore.lua` | Modify | Kind tiers settable (`SetKindTier`, `KindTier`) |
| `modules/Echo/EchoEvents.lua` | Modify | `SetKeywords`; switched-off feeds are dropped |
| `modules/Echo/EchoView.lua` | Modify | `PanelSides(edge)`; the menu's default tier follows settings |
| `modules/Echo/EchoTiles.lua` | Modify | Redraw marks; edge; scale-safe position; clamp max tiles; toast side |
| `modules/Echo/EchoStack.lua` | Modify | Redraw marks; opens on the edge's side; tracked font |
| `modules/Echo/EchoCard.lua` | Modify | Redraw marks; size from settings; opens on the edge's side; tracked font |
| `modules/Echo/EchoModule.lua` | Modify | Calls `ApplyOptions`; history switch; clear-history dialog |
| `modules/Echo/EchoSlash.lua` | Modify | Strings through `addon.L` |
| `options/modules/defaults/OptionsDefaultsEcho.lua` | Modify | All defaults, `ECHO_KEYS`, `ECHO_LIMITS` |
| `options/modules/OptionsEcho.lua` | Create | The Echo options page |
| `options/OptionsData.lua` | Modify | Route `ECHO_KEYS` to `Echo.ApplyOptions` |
| `core/Config.lua`, `HorizonSuite.lua`, `options/modules/OptionsAxis.lua`, `options/dashboard/DashboardFrame.lua`, `options/dashboard/DashboardHomeWelcome.lua`, `options/dashboard/DashboardModuleGuide.lua` | Modify | Echo in every module list |
| `HorizonSuite.toc` | Modify | New files |
| `locales/horizon/enUS.lua` | Modify | New strings |
| `.luacheckrc` | Modify | New globals |
| `tools/test_echo_logic.js` | Modify | Tests |

---

### Task 1: Repaint once per frame

**Files:**
- Create: `modules/Echo/EchoRedraw.lua`
- Modify: `modules/Echo/EchoTiles.lua` (`Tiles.OnStoreChange`, `Tiles.Enable`, `Tiles.Disable`)
- Modify: `modules/Echo/EchoStack.lua` (`Stack.OnStoreChange`, `Stack.Enable`, `Stack.Disable`)
- Modify: `modules/Echo/EchoCard.lua` (`Card.OnStoreChange`, `Card.Enable`, `Card.Disable`)
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoView.lua`)
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Produces:
  - `Echo.Redraw.Register(name, fn)`
  - `Echo.Redraw.Mark(name)`
  - `Echo.Redraw.Flush()`
  - `Echo.Redraw.Pending(name) -> boolean`
  - `Echo.Redraw.Clear()`
  - `Echo.Redraw.sync`, a boolean. It is true only in the test harness and makes `Mark` repaint at once.
- View names: `"tiles"`, `"stack"`, `"card"`, `"cardRow"`. Flush order is tiles, stack, card, cardRow. A pending `card` drops a pending `cardRow`, because a full render repaints the row.

- [ ] **Step 1: Write the failing tests.** Add `'modules/Echo/EchoRedraw.lua'` to `FILES` straight after `'modules/Echo/EchoView.lua'`. After the `for (const f of FILES)` line, add:

```js
// Views repaint synchronously in every section except the coalescing tests below.
run(`HorizonSuite.Echo.Redraw.sync = true`, 'redraw-sync');
```

Add this section at the end of the file, before the summary lines:

```js
// --- Redraw: one repaint per frame -------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local R = Echo.Redraw
  R.sync = false
  local calls = {}
  R.Register("tiles", function() calls[#calls + 1] = "tiles" end)
  R.Register("card", function() calls[#calls + 1] = "card" end)
  R.Register("cardRow", function() calls[#calls + 1] = "cardRow" end)
  R.Mark("tiles"); R.Mark("tiles"); R.Mark("tiles")
  check("a mark waits for the next frame", #calls == 0, #calls)
  check("the mark is pending", R.Pending("tiles") == true, R.Pending("tiles"))
  R.Flush()
  check("three marks repaint once", #calls == 1 and calls[1] == "tiles", table.concat(calls, ","))
  check("nothing pending after a flush", R.Pending("tiles") == false, R.Pending("tiles"))

  calls = {}
  R.Mark("cardRow"); R.Mark("card")
  R.Flush()
  check("a full card render drops the row repaint", #calls == 1 and calls[1] == "card", table.concat(calls, ","))

  calls = {}
  R.Mark("card"); R.Mark("tiles")
  R.Flush()
  check("tiles repaint before the card", calls[1] == "tiles" and calls[2] == "card", table.concat(calls, ","))

  calls = {}
  R.Mark("tiles"); R.Clear(); R.Flush()
  check("Clear drops pending marks", #calls == 0, #calls)

  -- A burst of lines through the real views: one Tiles.Refresh.
  local Store = Echo.Store
  Store.Reset()
  Echo.Tiles.Enable()
  local refreshes, real = 0, Echo.Tiles.Refresh
  Echo.Tiles.Refresh = function() refreshes = refreshes + 1; return real() end
  R.Register("tiles", function() Echo.Tiles.Refresh() end)
  for i = 1, 20 do Store.Add({ convKey = "loot", text = "item " .. i }) end
  check("twenty feed lines, no repaint yet", refreshes == 0, refreshes)
  R.Flush()
  check("twenty feed lines, one repaint", refreshes == 1, refreshes)
  Echo.Tiles.Refresh = real
  Echo.Tiles.Disable()
  Store.Reset()
  R.Clear()
  R.sync = true
`, 'redraw');
```

- [ ] **Step 2: Run the tests.** Expected: the run fails at load with `attempt to index a nil value (field 'Redraw')`.

- [ ] **Step 3: Create `modules/Echo/EchoRedraw.lua`:**

```lua
--[[
    Horizon Suite - Echo - Redraw
    Collects "this view needs repainting" marks and repaints each view once on the next
    frame, so a burst of lines (a group-loot roll, a busy channel) costs one repaint.
    Views register a repaint function under a name; Store listeners call Mark.
    Blizzard: CreateFrame (a hidden frame whose OnUpdate runs once, then hides).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Redraw = {}
Echo.Redraw = Redraw

-- Test harness only: repaint inside Mark, as the views did before this file.
Redraw.sync = false

local ORDER = { "tiles", "stack", "card", "cardRow" }
local handlers, dirty = {}, {}
local ticker

--- Set the repaint function for a view name.
-- @param name string
-- @param fn function
function Redraw.Register(name, fn)
    if type(fn) == "function" then handlers[name] = fn end
end

--- Repaint every marked view, once each, in ORDER.
function Redraw.Flush()
    local now = dirty
    dirty = {}
    if ticker then ticker:Hide() end
    if now.card then now.cardRow = nil end
    for _, name in ipairs(ORDER) do
        if now[name] and handlers[name] then handlers[name]() end
    end
end

--- Mark a view for repainting on the next frame.
-- @param name string
function Redraw.Mark(name)
    if Redraw.sync then
        local fn = handlers[name]
        if fn then fn() end
        return
    end
    dirty[name] = true
    if not ticker then
        ticker = CreateFrame("Frame")
        ticker:Hide()
        ticker:SetScript("OnUpdate", function() Redraw.Flush() end)
    end
    ticker:Show()
end

--- @param name string
-- @return boolean
function Redraw.Pending(name)
    return dirty[name] == true
end

--- Drop every pending mark (module disabled).
function Redraw.Clear()
    dirty = {}
    if ticker then ticker:Hide() end
end
```

- [ ] **Step 4: Route the views through it.**

`EchoTiles.lua`: replace `Tiles.OnStoreChange` with:

```lua
--- Store listener: mark the column for repainting, then toast or hold a loud message.
-- A loud message repaints at once: its toast points at the tile it has just moved to.
function Tiles.OnStoreChange(convKey, change)
    if change == "toast" then
        Tiles.Refresh()
    else
        Echo.Redraw.Mark("tiles")
        return
    end
    if not convKey then return end
    -- The open stack or card already shows the conversation (it re-renders, its tile
    -- badges); a toast over it would only cover it, and a held one would replay stale later.
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() then return end
    local card = _G.HorizonSuiteEchoCard
    if card and card:IsShown() then return end
    if Tiles.holding then
        HoldKey(convKey)
    else
        Tiles.ShowToast(convKey)
    end
end
```

In `Tiles.Enable`, before `Tiles.ApplyPosition()`, add `Echo.Redraw.Register("tiles", Tiles.Refresh)`.

`EchoStack.lua`: replace `Stack.OnStoreChange` with:

```lua
function Stack.OnStoreChange()
    if root and root:IsShown() then Echo.Redraw.Mark("stack") end
end
```

In `Stack.Enable`, after the subscribe block, add:

```lua
    Echo.Redraw.Register("stack", function()
        if root and root:IsShown() then Stack.Render() end
    end)
```

`EchoCard.lua`: replace the body of `Card.OnStoreChange` with:

```lua
function Card.OnStoreChange(convKey, change)
    if not root or not root:IsShown() then return end
    if convKey and renderedKey and convKey ~= renderedKey and change ~= "closed" then
        Echo.Redraw.Mark("cardRow")
    else
        Echo.Redraw.Mark("card")
    end
end
```

In `Card.Enable`, after the subscribe block, add:

```lua
    Echo.Redraw.Register("card", function()
        if root and root:IsShown() then Card.Render() end
    end)
    Echo.Redraw.Register("cardRow", function()
        if root and root:IsShown() and renderedKey then PaintRow(Echo.Store.List(), renderedKey) end
    end)
```

In `EchoModule.lua`'s `Echo.Disable`, add `Echo.Redraw.Clear()` as the first line after `if lifecycle ...`.

In `HorizonSuite.toc`, add `modules/Echo/EchoRedraw.lua` on the line after `modules/Echo/EchoView.lua`.

- [ ] **Step 5: Run the tests and parse-check.** Expected: all pass (636 + 10). Parse-check the four changed Lua files and the new one.

- [ ] **Step 6: Commit.**

```bash
git add modules/Echo/EchoRedraw.lua modules/Echo/EchoTiles.lua modules/Echo/EchoStack.lua modules/Echo/EchoCard.lua modules/Echo/EchoModule.lua HorizonSuite.toc tools/test_echo_logic.js
git commit -m "feat(echo): repaint each view once per frame"
```

---

### Task 2: Settings reach the Store, Events and History

**Files:**
- Modify: `options/modules/defaults/OptionsDefaultsEcho.lua` (full rewrite)
- Create: `modules/Echo/EchoOptions.lua`
- Modify: `modules/Echo/EchoStore.lua` (`TierOf`, `Reset`, new `KindTier`, `SetKindTier`)
- Modify: `modules/Echo/EchoEvents.lua` (`Events.keywords` comment, new `SetKeywords`, feed gate in `Dispatch`)
- Modify: `modules/Echo/EchoView.lua` (`View.MenuSpec` default tier)
- Modify: `modules/Echo/EchoTiles.lua` (`Tiles.Refresh` clamp)
- Modify: `modules/Echo/EchoModule.lua` (`Echo.Init`)
- Modify: `HorizonSuite.toc` (`EchoOptions.lua` after `EchoCard.lua`, before `EchoSlash.lua`)
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Produces:
  - `Store.KindTier(kind) -> string`. Returns the kind's tier from the settings, else `DEFAULT_TIERS`, else `"quiet"`.
  - `Store.SetKindTier(kind, tier|nil) -> boolean`. It notifies with `(nil, nil)`, so every view repaints.
  - `Events.SetKeywords(text)`: a comma-separated string, trimmed. Empty entries are dropped.
  - `Echo.TierKey(kind) -> string`
  - `Echo.FeedKey(kind) -> string`
  - `Echo.FeedEnabled(kind) -> boolean`
  - `Echo.ApplyOptions()`. Task 3 adds the frame half and Task 4 the filter.
  - `addon.ECHO_KEYS`, `addon.ECHO_LIMITS`.
- Consumes: `Echo.Setting`, `History.SetEnabledCheck`, `Store.FEED_KINDS`, `Store.Close`.

- [ ] **Step 1: Rewrite `options/modules/defaults/OptionsDefaultsEcho.lua`:**

```lua
--[[
    Horizon Suite - Echo - Defaults
    ECHO_DEFAULTS for the settings Echo reads through Echo.Setting; ECHO_KEYS routes a change
    of any of them (options/OptionsData.lua) to Echo.ApplyOptions; ECHO_LIMITS bounds the
    sliders on the options page. echoX / echoY have no default: unset means the default corner.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.ECHO_DEFAULTS = {
    echoColumnEdge         = "right",
    echoLockPosition       = true,
    echoScale              = 1,
    echoFrameStrata        = "MEDIUM",
    echoMaxTiles           = 8,
    echoToastStyle         = "framed",
    echoToastSeconds       = 4,
    echoHoverDelay         = 0.35,
    echoHoldToastsInCombat = true,
    -- Tier per conversation type; mirrors Store.DEFAULT_TIERS.
    echoTierWhisper        = "loud",
    echoTierBnet           = "loud",
    echoTierParty          = "count",
    echoTierRaid           = "count",
    echoTierInstance       = "count",
    echoTierGuild          = "quiet",
    echoTierOfficer        = "quiet",
    echoTierChannel        = "quiet",
    echoTierLoot           = "quiet",
    echoTierProgress       = "quiet",
    echoTierSystem         = "quiet",
    echoKeywords           = "",
    echoFeedLoot           = true,
    echoFeedProgress       = true,
    echoFeedSystem         = true,
    echoSaveHistory        = true,
    echoHideStoredWhispers = false,
    echoCardWidth          = 360,
    echoCardHeight         = 440,
    echoFontPath           = "__global__",
}

addon.ECHO_LIMITS = {
    echoScale        = { min = 0.6, max = 1.6 },
    echoMaxTiles     = { min = 2,   max = 12 },
    echoToastSeconds = { min = 2,   max = 10 },
    echoCardWidth    = { min = 320, max = 520 },
    echoCardHeight   = { min = 320, max = 640 },
}

-- Every setting, plus the dragged position, re-applies Echo when it changes.
addon.ECHO_KEYS = { echoX = true, echoY = true }
for key in pairs(addon.ECHO_DEFAULTS) do addon.ECHO_KEYS[key] = true end
```

- [ ] **Step 2: Write the failing tests.** Add `'modules/Echo/EchoOptions.lua'` to `FILES` after `'modules/Echo/EchoCard.lua'` and before `'modules/Echo/EchoSlash.lua'`. Add these sections before the Redraw section:

```js
// --- Defaults, keys and limits -------------------------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults');
run(`
  local A = HorizonSuite
  local S = A.Echo.Store
  for kind, tier in pairs(S.DEFAULT_TIERS) do
    local key = A.Echo.TierKey(kind)
    check("tier default for " .. kind, A.ECHO_DEFAULTS[key] == tier, tostring(A.ECHO_DEFAULTS[key]))
  end
  for key in pairs(A.ECHO_DEFAULTS) do
    check("routed key " .. key, A.ECHO_KEYS[key] == true, key)
  end
  check("position keys routed", A.ECHO_KEYS.echoX and A.ECHO_KEYS.echoY, "echoX/echoY")
  check("at least two tiles", A.ECHO_LIMITS.echoMaxTiles.min == 2, A.ECHO_LIMITS.echoMaxTiles.min)
  check("tier key", A.Echo.TierKey("bnet") == "echoTierBnet", A.Echo.TierKey("bnet"))
  check("feed key", A.Echo.FeedKey("loot") == "echoFeedLoot", A.Echo.FeedKey("loot"))
  -- Later sections run without defaults, as before this plan.
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
`, 'echo-defaults-check');

// --- Settings applied to the Store, Events and History ----------------------------
run(`
  local Echo = HorizonSuite.Echo
  local S, E = Echo.Store, Echo.Events
  S.Reset()
  local db = {}
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end

  check("kind tier defaults", S.KindTier("guild") == "quiet", S.KindTier("guild"))
  db.echoTierGuild = "loud"
  Echo.ApplyOptions()
  check("guild follows its setting", S.KindTier("guild") == "loud", S.KindTier("guild"))
  check("a guild conversation rings loud", S.TierOf("guild") == "loud", S.TierOf("guild"))
  S.SetTier("guild", "muted")
  check("a conversation's own tier still wins", S.TierOf("guild") == "muted", S.TierOf("guild"))
  S.SetTier("guild", nil)
  db.echoTierGuild = "bogus"
  Echo.ApplyOptions()
  check("an unknown tier falls back to the default", S.KindTier("guild") == "quiet", S.KindTier("guild"))
  check("SetKindTier refuses junk", S.SetKindTier("guild", "loudest") == false, "accepted")
  -- The harness L returns keys; give the two strings the label is built from real text.
  local Lt = HorizonSuite.L
  rawset(Lt, "ECHO_TIER_DEFAULT", "Default (%s)"); rawset(Lt, "ECHO_TIER_COUNT", "Count")
  db.echoTierGuild = "count"
  Echo.ApplyOptions()
  local label
  for _, e in ipairs(Echo.View.MenuSpec({ key = "guild", kind = "guild", pinned = false })) do
    if e.value == "default" then label = e.label end
  end
  check("the menu's default label follows the setting", label == "Default (Count)", label)
  rawset(Lt, "ECHO_TIER_DEFAULT", nil); rawset(Lt, "ECHO_TIER_COUNT", nil)

  db.echoKeywords = " heal , ,Tank,  "
  Echo.ApplyOptions()
  check("keywords parsed", #E.keywords == 2 and E.keywords[1] == "heal" and E.keywords[2] == "Tank", #E.keywords)
  check("keyword mention", E.IsMention("need a TANK for keys") == true, "no mention")
  check("your name still counts", E.IsMention("kaelis you there") == true, "no mention")
  db.echoKeywords = ""
  Echo.ApplyOptions()
  check("no keywords", #E.keywords == 0, #E.keywords)

  -- A switched-off feed files nothing and closes its tile.
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Linen Cloth].")
  check("loot feed on", S.Get("loot") ~= nil and S.Get("loot").open, "no loot feed")
  db.echoFeedLoot = false
  Echo.ApplyOptions()
  check("switching the feed off closes it", not S.Get("loot").open, "still open")
  local before = #S.Get("loot").messages
  E.Dispatch("CHAT_MSG_LOOT", "You receive loot: [Wool Cloth].")
  check("a switched-off feed files nothing", #S.Get("loot").messages == before, #S.Get("loot").messages)
  check("FeedEnabled", Echo.FeedEnabled("loot") == false and Echo.FeedEnabled("system") == true, "wrong")
  check("a conversation kind is never a switched-off feed", Echo.FeedEnabled("whisper") == true, "off")
  db.echoFeedLoot = nil

  -- A system line still fails a pending whisper with the System feed off.
  db.echoFeedSystem = false
  Echo.ApplyOptions()
  S.AddPending("w:Ghost-Horizon", "hi")
  E.Dispatch("CHAT_MSG_SYSTEM", "No player named 'Ghost' is currently playing.")
  local ghost = S.Get("w:Ghost-Horizon")
  check("failed whisper with the feed off", ghost.messages[#ghost.messages].status == "failed", ghost.messages[#ghost.messages].status)
  check("no system feed", S.Get("system") == nil or not S.Get("system").open, "system feed open")
  db.echoFeedSystem = nil

  -- The history switch.
  local H = Echo.History
  local saved = {}
  H.Bind(saved, function() return "Kaelis-Horizon" end)
  db.echoSaveHistory = false
  Echo.ApplyOptions()
  check("history off writes nothing", H.Append("w:Brisa-Horizon", { time = 1, text = "hi" }) == false, "wrote")
  db.echoSaveHistory = nil
  Echo.ApplyOptions()
  check("history on writes", H.Append("w:Brisa-Horizon", { time = 1, text = "hi" }) == true, "did not write")
  H.Unbind()

  HorizonSuite.GetDB = nil
  Echo.ApplyOptions()
  S.Reset()
`, 'echo-apply-options');
```

`History.Append(convKey, record)` returns `false` without writing when the enabled check fails, and `true` after writing a readable `record.text`.

- [ ] **Step 3: Run the tests.** Expected: they fail on `attempt to call a nil value (field 'TierKey')`.

- [ ] **Step 4: Store.** In `EchoStore.lua`, add `local kindTiers = {}` next to `overrides`. Change the fallback line of `Store.TierOf` to `return kind and Store.KindTier(kind) or "quiet"`. Add after `Store.TierOf`:

```lua
--- The tier a kind rings at unless a conversation overrides it: the player's setting for
-- that kind (Echo.ApplyOptions), else the default.
-- @param kind string
-- @return string
function Store.KindTier(kind)
    return kindTiers[kind] or Store.DEFAULT_TIERS[kind] or "quiet"
end

--- Set a kind's tier from the options; nil restores the default. Views repaint.
-- @param kind string  A Store.DEFAULT_TIERS key
-- @param tier string|nil
-- @return boolean
function Store.SetKindTier(kind, tier)
    if not Store.DEFAULT_TIERS[kind] then return false end
    if tier ~= nil and not Store.VALID_TIERS[tier] then return false end
    if kindTiers[kind] == tier then return true end
    kindTiers[kind] = tier
    Notify(nil, nil)
    return true
end
```

`Notify` is a local defined above `Store.TierOf` (line ~113). If it is not, move the two functions below it. `Store.Reset` does **not** clear `kindTiers`, because they are settings, not session state.

- [ ] **Step 5: Events.** In `EchoEvents.lua`, change the comment above `Events.keywords` to `-- Extra mention words (case-insensitive), from the echoKeywords setting.`. Add after `Events.IsMention`:

```lua
--- Replace the mention keywords from a comma-separated setting.
-- @param text string|nil
function Events.SetKeywords(text)
    local out = {}
    if type(text) == "string" then
        for word in text:gmatch("[^,]+") do
            word = word:match("^%s*(.-)%s*$")
            if word ~= "" then out[#out + 1] = word end
        end
    end
    Events.keywords = out
end
```

In `Events.Dispatch`, straight after the `if event == "CHAT_MSG_SYSTEM" then ... end` line, add:

```lua
    -- A switched-off feed files nothing (the system line above still checked for a failed whisper).
    local feedKind = Store.EVENT_KIND[event]
    if Store.FEED_KINDS[feedKind] and Echo.FeedEnabled and not Echo.FeedEnabled(feedKind) then return end
```

- [ ] **Step 6: The menu's default tier.** In `View.MenuSpec` (`EchoView.lua:426`), replace `Echo.Store.DEFAULT_TIERS[conv.kind] or "quiet"` with `Echo.Store.KindTier(conv.kind)`.

- [ ] **Step 7: Clamp the column.** In `Tiles.Refresh`, replace `tonumber(Echo.Setting("echoMaxTiles")) or 8` with `math.max(2, tonumber(Echo.Setting("echoMaxTiles")) or 8)`.

- [ ] **Step 8: Create `modules/Echo/EchoOptions.lua`:**

```lua
--[[
    Horizon Suite - Echo - Options
    Echo.ApplyOptions pushes every setting into the running module. options/OptionsData.lua
    calls it when any ECHO_KEYS setting changes, and Echo.Init calls it on enable.
    Settings are read through Echo.Setting, so a missing profile value is its default.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local function Capitalise(s)
    return s:sub(1, 1):upper() .. s:sub(2)
end

--- The setting holding a conversation kind's tier.
-- @param kind string
-- @return string
function Echo.TierKey(kind)
    return "echoTier" .. Capitalise(kind)
end

--- The setting switching a feed on or off.
-- @param kind string
-- @return string
function Echo.FeedKey(kind)
    return "echoFeed" .. Capitalise(kind)
end

--- False only for a feed the player has switched off.
-- @param kind string
-- @return boolean
function Echo.FeedEnabled(kind)
    if not Echo.Store.FEED_KINDS[kind] then return true end
    return Echo.Setting(Echo.FeedKey(kind)) ~= false
end

--- Push every setting into the running module.
function Echo.ApplyOptions()
    Echo.History.SetEnabledCheck(function() return Echo.Setting("echoSaveHistory") ~= false end)
    local Store = Echo.Store
    for kind in pairs(Store.DEFAULT_TIERS) do
        local tier = Echo.Setting(Echo.TierKey(kind))
        if not Store.VALID_TIERS[tier] then tier = nil end
        Store.SetKindTier(kind, tier)
    end
    Echo.Events.SetKeywords(Echo.Setting("echoKeywords"))
    for kind in pairs(Store.FEED_KINDS) do
        local conv = Store.Get(kind)
        if not Echo.FeedEnabled(kind) and conv and conv.open then Store.Close(kind) end
    end
end
```

`Store.SetKindTier(kind, nil)` when the setting equals the default is fine: `KindTier` falls back to the same value.

- [ ] **Step 9: The history switch and the first apply.** In `EchoModule.lua`'s `Echo.Init`, add straight after the `Echo.History.Bind(...)` line:

```lua
    Echo.History.SetEnabledCheck(function() return Echo.Setting("echoSaveHistory") ~= false end)
```

and add `Echo.ApplyOptions()` straight after `Echo.Links.Hook()`.

Correction to the line above: the history test calls `ApplyOptions` without `Init`, so the `SetEnabledCheck` call goes in `Echo.ApplyOptions` (Step 8), as its first line, **not** in `Init`. `Init` gets only the `Echo.ApplyOptions()` call.

- [ ] **Step 10: TOC.** Add `modules/Echo/EchoOptions.lua` on the line after `modules/Echo/EchoCard.lua`.

- [ ] **Step 11: Run the tests and parse-check.** Expected: all pass.

- [ ] **Step 12: Commit.**

```bash
git add options/modules/defaults/OptionsDefaultsEcho.lua modules/Echo/EchoOptions.lua modules/Echo/EchoStore.lua modules/Echo/EchoEvents.lua modules/Echo/EchoView.lua modules/Echo/EchoTiles.lua modules/Echo/EchoModule.lua HorizonSuite.toc tools/test_echo_logic.js
git commit -m "feat(echo): apply tiers, keywords, feeds and history settings"
```

---

### Task 3: Edge, scale, strata, card size and font follow the settings

**Files:**
- Modify: `modules/Echo/EchoView.lua` (new `View.PanelSides`)
- Modify: `modules/Echo/EchoOptions.lua` (`Echo.FontPath`, `Echo.TrackFont`, `Echo.ApplyFont`, frame half of `ApplyOptions`)
- Modify: `modules/Echo/EchoTiles.lua` (`FontPath`, `Echo.NewText`, `SavePosition`, `Tiles.ApplyPosition`, toast points)
- Modify: `modules/Echo/EchoStack.lua` (`FontPath`, edit font, `Anchor`)
- Modify: `modules/Echo/EchoCard.lua` (`FontPath`, edit font, size, `Anchor`, new `Card.ApplySize`)
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Produces:
  - `View.PanelSides(edge) -> table`, with the fields `{ panel, rel, dx, toast, toastRel, toastDir }`:
    - Right edge: `{ panel = "BOTTOMRIGHT", rel = "BOTTOMLEFT", dx = -8, toast = "RIGHT", toastRel = "LEFT", toastDir = -1 }`
    - Left edge: `{ panel = "BOTTOMLEFT", rel = "BOTTOMRIGHT", dx = 8, toast = "LEFT", toastRel = "RIGHT", toastDir = 1 }`
    - Any other value is treated as right.
  - `Echo.FontPath() -> string`
  - `Echo.TrackFont(obj, size, flags)`
  - `Echo.ApplyFont()`
  - `Card.ApplySize()`
- Saved position: `echoX` / `echoY` become **screen units**, the column's centre and bottom multiplied by its scale. `ApplyPosition` divides by the current scale, so a scale change keeps the column's bottom centre in place. A position saved before this plan at a scale other than 1 shifts once. Only testers have such saves; Task 8 records it in the spec.

- [ ] **Step 1: Write the failing tests.** Add before the Redraw section:

```js
// --- Edge, scale, card size and font ---------------------------------------------
run(`
  CreateFrame = STUB_CREATE_FRAME
  local Echo = HorizonSuite.Echo
  local V = Echo.View
  local r, l = V.PanelSides("right"), V.PanelSides("left")
  check("right edge opens left", r.panel == "BOTTOMRIGHT" and r.rel == "BOTTOMLEFT" and r.dx == -8 and r.toast == "RIGHT" and r.toastDir == -1, r.panel)
  check("left edge opens right", l.panel == "BOTTOMLEFT" and l.rel == "BOTTOMRIGHT" and l.dx == 8 and l.toast == "LEFT" and l.toastDir == 1, l.panel)
  check("junk edge is right", V.PanelSides("top").panel == "BOTTOMRIGHT", V.PanelSides("top").panel)

  local db = {}
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  HorizonSuite.SetDB = function(k, v) db[k] = v end
  Echo.Store.Reset()
  Echo.Tiles.Enable()
  local column = _G.HorizonSuiteEchoColumn
  local scale = 1
  column.SetScale = function(self, s) scale = s end
  column.GetScale = function() return scale end

  -- Default corner follows the edge.
  db.echoColumnEdge = "left"
  Echo.ApplyOptions()
  local p = column.points[#column.points]
  check("left edge default corner", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMLEFT" and p[4] > 0, p[1] .. " " .. tostring(p[4]))

  -- A dragged position is kept in screen units across a scale change.
  db.echoX, db.echoY = 800, 300
  db.echoScale = 2
  Echo.ApplyOptions()
  p = column.points[#column.points]
  check("scale 2 halves the offsets", p[1] == "BOTTOM" and p[4] == 400 and p[5] == 150, tostring(p[4]) .. "," .. tostring(p[5]))
  column.GetCenter = function() return 400 end
  column.GetBottom = function() return 150 end
  Echo.Tiles._savePosition()
  check("saving multiplies by the scale", db.echoX == 800 and db.echoY == 300, tostring(db.echoX) .. "," .. tostring(db.echoY))
  column.GetCenter, column.GetBottom = nil, nil

  -- The stack and card open on the edge's side.
  Echo.Stack.Enable(); Echo.Card.Enable()
  Echo.Store.Add({ convKey = "w:Brisa-Horizon", sender = "Brisa-Horizon", text = "hi" })
  Echo.Card.Open("w:Brisa-Horizon")
  local card = Echo.Card._frames().root
  p = card.points[#card.points]
  check("card opens right of a left column", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMRIGHT" and p[4] == 8, p[1])
  Echo.Card.Hide()
  Echo.Stack.Open("w:Brisa-Horizon")
  local stack = Echo.Stack._frames().root
  p = stack.points[#stack.points]
  check("stack opens right of a left column", p[1] == "BOTTOMLEFT" and p[3] == "BOTTOMRIGHT", p[1])
  Echo.Stack.Hide()

  -- Card size. ECHO_LIMITS was cleared after the defaults section; the clamp needs it.
  HorizonSuite.ECHO_LIMITS = { echoCardWidth = { min = 320, max = 520 }, echoCardHeight = { min = 320, max = 640 } }
  db.echoCardWidth, db.echoCardHeight = 480, 600
  Echo.ApplyOptions()
  check("card width from settings", card.width == 480 and card.height == 600, tostring(card.width) .. "x" .. tostring(card.height))
  check("bubble width follows the card", Echo.Card.BUBBLE_MAX == 370, Echo.Card.BUBBLE_MAX)
  check("message area follows the card", Echo.Card.AREA_HEIGHT == 600 - Echo.Card.AREA_TOP - Echo.Card.AREA_BOTTOM, Echo.Card.AREA_HEIGHT)
  db.echoCardWidth = 9999
  Echo.ApplyOptions()
  check("card width clamped", card.width == 520, card.width)

  -- Font: tracked strings are re-fonted.
  local set = {}
  local fs = { SetFont = function(self, path, size, flags) set[#set + 1] = { path, size, flags } end }
  Echo.TrackFont(fs, 12, "")
  db.echoFontPath = "Fonts\\\\ARIALN.TTF"
  Echo.ApplyOptions()
  local last = set[#set]
  check("font re-applied", last and last[1] == "Fonts\\\\ARIALN.TTF" and last[2] == 12 and last[3] == "", last and last[1])
  db.echoFontPath = "__global__"
  check("global font", Echo.FontPath() ~= "__global__", Echo.FontPath())

  HorizonSuite.GetDB, HorizonSuite.SetDB, HorizonSuite.ECHO_LIMITS = nil, nil, nil
  Echo.ApplyOptions()
  Echo.Card.Disable(); Echo.Stack.Disable(); Echo.Tiles.Disable()
  column.SetScale, column.GetScale = nil, nil
  Echo.Store.Reset()
`, 'echo-layout-options');
```

Two notes on the tests:
- The existing Card and Stack smoke sections open both with stand-in frames the same way. If either needs extra setup there (a stubbed `GetTime`, `MenuUtil`), copy it from those sections.
- The stub `SetPoint` stores `{ point, relFrame, relPoint, x, y }`, so `p[4]` is x and `p[5]` is y.

- [ ] **Step 2: Run the tests.** Expected: they fail on `attempt to call a nil value (field 'PanelSides')`.

- [ ] **Step 3: View.** Add to `EchoView.lua` after `Echo.Setting`:

```lua
--- Which way the stack, card and toast open from the column: away from its screen edge.
-- @param edge string  "right" | "left"
-- @return table { panel, rel, dx, toast, toastRel, toastDir }
function View.PanelSides(edge)
    if edge == "left" then
        return { panel = "BOTTOMLEFT", rel = "BOTTOMRIGHT", dx = 8, toast = "LEFT", toastRel = "RIGHT", toastDir = 1 }
    end
    return { panel = "BOTTOMRIGHT", rel = "BOTTOMLEFT", dx = -8, toast = "RIGHT", toastRel = "LEFT", toastDir = -1 }
end
```

- [ ] **Step 4: Font.** Add to `EchoOptions.lua`:

```lua
local FONT_USE_GLOBAL = "__global__"
local tracked = setmetatable({}, { __mode = "k" })  -- FontString / EditBox -> { size, flags }

--- Echo's font: its own setting, else the suite's font, else the game's.
-- @return string
function Echo.FontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local raw = Echo.Setting("echoFontPath")
    if type(raw) == "string" and raw ~= FONT_USE_GLOBAL and raw ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(raw)) or raw
    end
    local base = addon.GetDB and addon.GetDB("fontPath", nil)
    if type(base) == "string" and base ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(base)) or base
    end
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- Set an object's font now and again whenever the font setting changes.
-- @param obj FontString|EditBox
-- @param size number
-- @param flags string
function Echo.TrackFont(obj, size, flags)
    tracked[obj] = { size = size, flags = flags }
    obj:SetFont(Echo.FontPath(), size, flags)
end

--- Re-font every tracked object.
function Echo.ApplyFont()
    local path = Echo.FontPath()
    for obj, f in pairs(tracked) do obj:SetFont(path, f.size, f.flags) end
end
```

Change `Echo.NewText` in `EchoTiles.lua` to:

```lua
function Echo.NewText(parent, size, flags)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    Echo.TrackFont(fs, size, flags or "OUTLINE")
    return fs
end
```

Delete the local `FontPath` function in `EchoTiles.lua`, `EchoStack.lua` and `EchoCard.lua`. Replace the two `edit:SetFont(FontPath(), 12, "")` lines (Stack line ~76, Card line ~231) with `Echo.TrackFont(edit, 12, "")`. `EchoTiles.lua` loads before `EchoOptions.lua`, but `NewText` only runs when frames are created, after all files have loaded.

- [ ] **Step 5: Column position and edge.** In `EchoTiles.lua`, replace `SavePosition` and `Tiles.ApplyPosition`:

```lua
-- Saved in screen units (the column's own coordinates times its scale), so a scale change
-- leaves the column where it was.
local function SavePosition()
    local x = column:GetCenter()
    local y = column:GetBottom()
    if not x or not y then return end
    local scale = column:GetScale() or 1
    addon.SetDB("echoX", math.floor(x * scale + 0.5))
    addon.SetDB("echoY", math.floor(y * scale + 0.5))
end

--- Anchor, scale and strata from settings. Unmoved, the column sits in the bottom corner
-- of its edge and grows upward; once dragged it is anchored by its bottom centre.
function Tiles.ApplyPosition()
    if not column then return end
    local scale = tonumber(Echo.Setting("echoScale")) or 1
    column:SetScale(scale)
    column:SetFrameStrata(Echo.Setting("echoFrameStrata") or "MEDIUM")
    column:ClearAllPoints()
    local x, y = tonumber(Echo.Setting("echoX")), tonumber(Echo.Setting("echoY"))
    if x and y then
        column:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    elseif Echo.Setting("echoColumnEdge") == "left" then
        column:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 24 / scale, 240 / scale)
    else
        column:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -24 / scale, 240 / scale)
    end
end
```

Add the test handle `function Tiles._savePosition() SavePosition() end` next to the other handles at the end of the file. `ResetPosition` stays as it is.

- [ ] **Step 6: Toast side.** In `ToastUpdate` replace the last line with:

```lua
    local side = Echo.View.PanelSides(Echo.Setting("echoColumnEdge"))
    self:SetPoint(side.toast, self.anchor, side.toastRel, side.toastDir * (8 + offset), 0)
```

In `Tiles.ShowToast`, replace `toast:SetPoint("RIGHT", toast.anchor, "LEFT", -8, 0)` with:

```lua
    local side = View.PanelSides(Echo.Setting("echoColumnEdge"))
    toast:SetPoint(side.toast, toast.anchor, side.toastRel, side.toastDir * 8, 0)
```

- [ ] **Step 7: Stack and card anchors.** In both `EchoStack.lua`'s and `EchoCard.lua`'s `Anchor`, replace `root:SetPoint("BOTTOMRIGHT", column, "BOTTOMLEFT", -8, 0)` with:

```lua
        local side = Echo.View.PanelSides(Echo.Setting("echoColumnEdge"))
        root:SetPoint(side.panel, column, side.rel, side.dx, 0)
```

- [ ] **Step 8: Card size.** In `EchoCard.lua`, add after the constants block:

```lua
--- Take the card's width and height from the settings and re-derive the sizes built on
-- them. The bubble width keeps the 110px the original 360px card left beside a bubble.
function Card.ApplySize()
    local lim = addon.ECHO_LIMITS
    local function clamp(v, key, fallback)
        v = tonumber(v) or fallback
        local l = lim and lim[key]
        if l then v = math.max(l.min, math.min(l.max, v)) end
        return v
    end
    Card.WIDTH = clamp(Echo.Setting("echoCardWidth"), "echoCardWidth", 360)
    Card.HEIGHT = clamp(Echo.Setting("echoCardHeight"), "echoCardHeight", 440)
    Card.AREA_HEIGHT = Card.HEIGHT - Card.AREA_TOP - Card.AREA_BOTTOM
    Card.BUBBLE_MAX = Card.WIDTH - 110
    if root then
        root:SetSize(Card.WIDTH, Card.HEIGHT)
        if root:IsShown() then Card.Render() end
    end
end
```

Card rendering reads `Card.HEIGHT` at render time: `Card.Render` calls `AnchorArea`, which recomputes the `areaHeight` local from it. The `SizeBubble` / `SizeFeedLine` helpers read `Card.BUBBLE_MAX` and `Card.WIDTH` at call time too.

- [ ] **Step 9: The frame half of `ApplyOptions`.** Append to the end of `Echo.ApplyOptions`:

```lua
    Echo.ApplyFont()
    if Echo.Tiles and Echo.Tiles.ApplyPosition then Echo.Tiles.ApplyPosition() end
    if Echo.Card and Echo.Card.ApplySize then Echo.Card.ApplySize() end
    -- Re-anchor an open stack or card to the column's new scale, strata or edge.
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() and Echo.Stack.Reanchor then Echo.Stack.Reanchor() end
    local card = _G.HorizonSuiteEchoCard
    if card and card:IsShown() and Echo.Card.Reanchor then Echo.Card.Reanchor() end
    if Echo.Redraw then Echo.Redraw.Mark("tiles") end
```

Expose `function Stack.Reanchor() Anchor() end` and `function Card.Reanchor() Anchor() end`. Put each directly after its file's local `Anchor`.

- [ ] **Step 10: Run the tests and parse-check.** Expected: all pass. Earlier sections that check the column's default `BOTTOMRIGHT` point at scale 1 still pass, since `-24 / 1 == -24`.

- [ ] **Step 11: Commit.**

```bash
git add modules/Echo/EchoView.lua modules/Echo/EchoOptions.lua modules/Echo/EchoTiles.lua modules/Echo/EchoStack.lua modules/Echo/EchoCard.lua tools/test_echo_logic.js
git commit -m "feat(echo): follow the edge, scale, card size and font settings"
```

---

### Task 4: Hide whispers Echo has filed from Blizzard's chat

**Files:**
- Create: `modules/Echo/EchoFilter.lua`
- Modify: `modules/Echo/EchoOptions.lua` (end of `ApplyOptions`)
- Modify: `modules/Echo/EchoModule.lua` (`Echo.Disable`)
- Modify: `HorizonSuite.toc` (after `modules/Echo/EchoEvents.lua`)
- Test: `tools/test_echo_logic.js`

**Behaviour:**
- On: a whisper event is hidden from every Blizzard chat window when `Events.BuildRecord` files it (returns a record) and the record isn't secret. Secret whispers, and whispers from a secret sender (no record), still show in Blizzard's chat, so nothing is lost.
- The events are `CHAT_MSG_WHISPER`, `CHAT_MSG_WHISPER_INFORM`, and on Battle.net builds `CHAT_MSG_BN_WHISPER` and `CHAT_MSG_BN_WHISPER_INFORM`.
- Blizzard sets the reply target (the R key) after the filters run, so a hidden incoming whisper would leave R pointing at the last visible one. For a hidden incoming whisper, the filter sets the reply target itself:
  - `ChatFrameUtil.SetLastTellTarget(sender, chatType)` if it exists, else `ChatEdit_SetLastTellTarget(sender, chatType)`
  - `chatType` is `"WHISPER"` or `"BN_WHISPER"`
  - Guarded by `IsSecret(sender)`, so it only runs on a readable sender.
- Off: the filter is removed. It is also removed when Echo is disabled.
- The add and remove functions come from `ChatFrameUtil.AddMessageEventFilter` / `RemoveMessageEventFilter`, else the globals `ChatFrame_AddMessageEventFilter` / `ChatFrame_RemoveMessageEventFilter`. They are resolved at call time.

**Interfaces:**
- Produces:
  - `Echo.Filter.Apply(on)`
  - `Echo.Filter.ShouldHide(event, ...) -> boolean`
  - `Echo.Filter.Handler(chatFrame, event, ...) -> boolean, ...`, with Blizzard's filter signature. Returning `true` hides the line; otherwise it returns `false, ...` with the arguments unchanged.
  - `Echo.Filter.active`, a boolean.

- [ ] **Step 1: Write the failing tests.** Add `'modules/Echo/EchoFilter.lua'` to `FILES` after `'modules/Echo/EchoEvents.lua'`. Add before the Redraw section:

```js
// --- Blizzard whisper filter ----------------------------------------------------
run(`
  local Echo = HorizonSuite.Echo
  local F = Echo.Filter
  local added, removed = {}, {}
  ChatFrame_AddMessageEventFilter = function(event, fn) added[event] = fn end
  ChatFrame_RemoveMessageEventFilter = function(event, fn) if added[event] == fn then added[event] = nil end removed[event] = true end
  local lastTell
  ChatEdit_SetLastTellTarget = function(name, chatType) lastTell = { name, chatType } end

  F.Apply(true)
  check("filter on registers whispers", added.CHAT_MSG_WHISPER == F.Handler and added.CHAT_MSG_WHISPER_INFORM == F.Handler, "missing")
  check("filter on registers Battle.net whispers", added.CHAT_MSG_BN_WHISPER == F.Handler, "missing")
  check("filter active", F.active == true, F.active)
  F.Apply(true)
  check("applying twice is harmless", added.CHAT_MSG_WHISPER == F.Handler, "lost")

  local hide = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a filed whisper is hidden", hide == true, hide)
  check("the reply target follows a hidden whisper", lastTell and lastTell[1] == "Brisa-Horizon" and lastTell[2] == "WHISPER", lastTell and lastTell[1])

  lastTell = nil
  local keep, text = F.Handler(nil, "CHAT_MSG_WHISPER", SECRET("hi"), "Brisa-Horizon", "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a secret whisper stays in Blizzard chat", keep == false, keep)
  check("its arguments pass through", issecretvalue(text), text)
  check("no reply target from a kept whisper", lastTell == nil, lastTell and lastTell[1])

  keep = F.Handler(nil, "CHAT_MSG_WHISPER", "hi", SECRET("Brisa-Horizon"), "", "", "", "", 0, 0, "", 0, 1, "Player-1-DRUID")
  check("a secret sender stays in Blizzard chat", keep == false, keep)

  HorizonSuite.Platform.caps.bnetWhispers = false
  F.Apply(false); F.Apply(true)
  check("no Battle.net filter without Battle.net whispers", added.CHAT_MSG_BN_WHISPER == nil, "registered")
  HorizonSuite.Platform.caps.bnetWhispers = true

  F.Apply(false)
  check("filter off removes whispers", added.CHAT_MSG_WHISPER == nil and added.CHAT_MSG_WHISPER_INFORM == nil, "still there")
  check("filter inactive", F.active == false, F.active)

  -- ApplyOptions drives it.
  local db = { echoHideStoredWhispers = true }
  HorizonSuite.GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  CreateFrame = STUB_CREATE_FRAME
  Echo.ApplyOptions()
  check("setting on applies the filter", F.active == true, F.active)
  db.echoHideStoredWhispers = false
  Echo.ApplyOptions()
  check("setting off removes the filter", F.active == false, F.active)
  HorizonSuite.GetDB = nil
  ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter, ChatEdit_SetLastTellTarget = nil, nil, nil
`, 'echo-filter');
```

The argument list follows `CHAT_MSG_WHISPER`: text, sender, then the rest up to arg 12, the GUID. Read `Events.BuildRecord` and match the positions it reads (GUID at 12, `bnSenderID` at 13). If the harness's `BuildRecord` needs other arguments to file a whisper, copy them from the existing "whisper record" tests.

- [ ] **Step 2: Run the tests.** Expected: they fail on `attempt to index a nil value (field 'Filter')`.

- [ ] **Step 3: Create `modules/Echo/EchoFilter.lua`:**

```lua
--[[
    Horizon Suite - Echo - Filter
    "Hide whispers Echo has stored": while on, a whisper Echo files in a conversation is
    hidden from Blizzard's chat windows. A whisper Echo could not read (secret text or a
    secret sender) is never hidden, so nothing is lost. Blizzard sets the reply target
    after the filters run, so a hidden incoming whisper sets it here instead.
    Blizzard: ChatFrameUtil.AddMessageEventFilter / RemoveMessageEventFilter (legacy
    ChatFrame_* globals), ChatFrameUtil.SetLastTellTarget / ChatEdit_SetLastTellTarget.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Filter = { active = false }
Echo.Filter = Filter

local EVENTS = { "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM" }
local BN_EVENTS = { "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM" }
local INCOMING = { CHAT_MSG_WHISPER = "WHISPER", CHAT_MSG_BN_WHISPER = "BN_WHISPER" }

local registered = {}  -- events this filter is currently registered on

local function AddFn()
    local util = _G.ChatFrameUtil
    return (util and util.AddMessageEventFilter) or _G.ChatFrame_AddMessageEventFilter
end

local function RemoveFn()
    local util = _G.ChatFrameUtil
    return (util and util.RemoveMessageEventFilter) or _G.ChatFrame_RemoveMessageEventFilter
end

local function SetLastTell(sender, chatType)
    if Echo.IsSecret(sender) then return end
    local util = _G.ChatFrameUtil
    local fn = (util and util.SetLastTellTarget) or _G.ChatEdit_SetLastTellTarget
    if fn then pcall(fn, sender, chatType) end
end

--- True when Echo files this whisper as a readable message.
-- @return boolean
function Filter.ShouldHide(event, ...)
    local record = Echo.Events.BuildRecord(event, ...)
    return record ~= nil and not record.secret
end

--- Blizzard's message-filter signature: true hides the line.
function Filter.Handler(_, event, ...)
    if Filter.ShouldHide(event, ...) then
        local chatType = INCOMING[event]
        if chatType then SetLastTell((select(2, ...)), chatType) end
        return true
    end
    return false, ...
end

--- Register or remove the filter.
-- @param on boolean
function Filter.Apply(on)
    local remove = RemoveFn()
    for event in pairs(registered) do
        if remove then remove(event, Filter.Handler) end
    end
    registered = {}
    Filter.active = false
    if not on then return end
    local add = AddFn()
    if not add then return end
    local events = {}
    for _, e in ipairs(EVENTS) do events[#events + 1] = e end
    if addon.Platform and addon.Platform.Has("bnetWhispers") then
        for _, e in ipairs(BN_EVENTS) do events[#events + 1] = e end
    end
    for _, event in ipairs(events) do
        add(event, Filter.Handler)
        registered[event] = true
    end
    Filter.active = true
end
```

`Events.BuildRecord` sets `record.secret` for secret text, and returns nil with `"unrouted"` for a whisper whose sender is secret.

- [ ] **Step 4: Wire it.** Append to `Echo.ApplyOptions`: `Echo.Filter.Apply(Echo.Setting("echoHideStoredWhispers") == true)`. In `Echo.Disable` (`EchoModule.lua`), add `Echo.Filter.Apply(false)` before `Echo.Events.Disable()`. In `HorizonSuite.toc`, add `modules/Echo/EchoFilter.lua` after `modules/Echo/EchoEvents.lua`.

- [ ] **Step 5: Run the tests and parse-check.** Expected: all pass.

- [ ] **Step 6: Commit.**

```bash
git add modules/Echo/EchoFilter.lua modules/Echo/EchoOptions.lua modules/Echo/EchoModule.lua HorizonSuite.toc tools/test_echo_logic.js
git commit -m "feat(echo): optionally hide filed whispers from Blizzard chat"
```

---

### Task 5: The Echo options page

**Files:**
- Create: `options/modules/OptionsEcho.lua`
- Modify: `options/OptionsData.lua` (the per-module apply block, after `ESSENCE_KEYS`)
- Modify: `modules/Echo/EchoModule.lua` (the clear-history dialog)
- Modify: `HorizonSuite.toc` (after `options/modules/OptionsEssence.lua`)
- Modify: `locales/horizon/enUS.lua`
- Test: `tools/test_echo_logic.js`

**Interfaces:**
- Consumes:
  - `addon.OptionCategories`, `addon.Section`, `addon.Toggle`, `addon.Button`
  - `addon.OptionsData_GetDB`, `addon.OptionsData_SetDB`
  - `addon.GetPerElementFontDropdownOptions`, `addon.DisplayPerElementFont`
  - `addon.ECHO_DEFAULTS`, `addon.ECHO_LIMITS`
  - `Echo.TierKey`, `Echo.FeedKey`
- Produces: `Echo.ConfirmClearHistory()`, and a category with `moduleKey = "echo"`.

- [ ] **Step 1: Strings.** Add to `locales/horizon/enUS.lua`, after `L["ECHO_SOMEONE"]`:

```lua
L["ECHO_DESC"]                                                = "Conversation-first chat: whispers and group chat as tiles you can read and reply from."
L["ECHO_SECTION_GENERAL"]                                     = "General"
L["ECHO_SECTION_NOTIFICATIONS"]                               = "Notifications"
L["ECHO_SECTION_TIERS"]                                       = "How each type of chat notifies you"
L["ECHO_SECTION_FEEDS"]                                       = "Feeds"
L["ECHO_SECTION_HISTORY"]                                     = "History"
L["ECHO_SECTION_BLIZZARD_CHAT"]                               = "Blizzard chat"
L["ECHO_SECTION_CARD"]                                        = "Card"
L["ECHO_COLUMN_EDGE"]                                         = "Screen edge"
L["ECHO_COLUMN_EDGE_DESC"]                                    = "Which side of the screen the tiles sit on. The stack, card and pop-ups open towards the middle."
L["ECHO_EDGE_RIGHT"]                                          = "Right"
L["ECHO_EDGE_LEFT"]                                           = "Left"
L["ECHO_LOCK"]                                                = "Lock position"
L["ECHO_LOCK_DESC"]                                           = "When unlocked, drag the chat button at the foot of the tiles to move them."
L["ECHO_RESET_POSITION_DESC"]                                 = "Move the tiles back to the bottom corner of their screen edge."
L["ECHO_SCALE"]                                               = "Scale"
L["ECHO_SCALE_DESC"]                                          = "Size of the tiles, stack, card and pop-ups, in percent."
L["ECHO_STRATA"]                                              = "Frame strata"
L["ECHO_STRATA_DESC"]                                         = "Which layer of the interface Echo draws on. Raise it if other windows cover the tiles."
L["ECHO_MAX_TILES"]                                           = "Most tiles shown"
L["ECHO_MAX_TILES_DESC"]                                      = "Past this many, a +N tile opens the stack with the rest."
L["ECHO_TOAST_STYLE"]                                         = "Pop-up style"
L["ECHO_TOAST_STYLE_DESC"]                                    = "The look of the pop-up that slides out beside a tile for a new message."
L["ECHO_TOAST_SECONDS"]                                       = "Pop-up time"
L["ECHO_TOAST_SECONDS_DESC"]                                  = "How many seconds a pop-up stays before fading. Hovering it keeps it up."
L["ECHO_HOLD_IN_COMBAT"]                                      = "Hold pop-ups in combat"
L["ECHO_HOLD_IN_COMBAT_DESC"]                                 = "Save pop-ups until combat ends, then show them newest first, one per conversation."
L["ECHO_KEYWORDS"]                                            = "Mention keywords"
L["ECHO_KEYWORDS_DESC"]                                       = "Extra words that count as a mention in party, raid and instance chat, separated by commas. Your character's name always counts."
L["ECHO_TIER_DESC"]                                           = "Loud: a dot and a pop-up. Count: a number. Quiet: nothing until you open it. Muted: never counted."
L["ECHO_KIND_WHISPER"]                                        = "Whispers"
L["ECHO_KIND_BNET"]                                           = "Battle.net whispers"
L["ECHO_KIND_CHANNEL"]                                        = "Channels (General, Trade…)"
L["ECHO_FEED_SHOW"]                                           = "Show the %s feed"
L["ECHO_FEED_SHOW_DESC"]                                      = "Collect these lines in their own tile. Off, they stay only in Blizzard's chat."
L["ECHO_FEED_TIER"]                                           = "%s feed notifications"
L["ECHO_SAVE_HISTORY"]                                        = "Save whisper history"
L["ECHO_SAVE_HISTORY_DESC"]                                   = "Keep the last 100 whispers with each person between sessions, and reopen recent tiles after a reload. Messages the game hides are never saved."
L["ECHO_CLEAR_HISTORY"]                                       = "Clear history"
L["ECHO_CLEAR_HISTORY_DESC"]                                  = "Delete saved whispers for every character and Battle.net friend."
L["ECHO_CLEAR_HISTORY_CONFIRM"]                               = "Delete Echo's saved whisper history for every character? This can't be undone."
L["ECHO_HIDE_STORED"]                                         = "Hide whispers Echo has stored"
L["ECHO_HIDE_STORED_DESC"]                                    = "Remove whispers from Blizzard's chat windows once Echo has them. Whispers Echo can't read still show there."
L["ECHO_CARD_WIDTH"]                                          = "Card width"
L["ECHO_CARD_HEIGHT"]                                         = "Card height"
L["ECHO_CARD_SIZE_DESC"]                                      = "Size of the expanded conversation card."
L["ECHO_FONT"]                                                = "Font"
L["ECHO_FONT_DESC"]                                           = "Font for Echo's tiles, stack and card."
```

Reuse the existing keys:
- Kind names: `ECHO_KIND_PARTY`, `_RAID`, `_INSTANCE`, `_GUILD`, `_OFFICER`, `_LOOT`, `_PROGRESS`, `_SYSTEM`.
- Tier names: `ECHO_TIER_LOUD`, `_COUNT`, `_QUIET`, `_MUTED`.
- Toast styles: `AUGMENT_TOAST_STYLE_COMPACT`, `_FRAMED`, `_ACCENT`.
- Strata labels: `FOCUS_STRATA_BACKGROUND`, `_LOW`, `_MEDIUM`, `_HIGH`. For DIALOG, check that `FOCUS_STRATA_DIALOG` exists (`grep FOCUS_STRATA locales/horizon/enUS.lua`). If it doesn't, add `L["ECHO_STRATA_DIALOG"] = "Dialog"` and use that.
- Reset button: `AXIS_RESET_POSITION`.

- [ ] **Step 2: The clear-history dialog.** Add to `EchoModule.lua`, above `Echo.Init`:

```lua
--- Ask before wiping saved whisper history (options page button).
function Echo.ConfirmClearHistory()
    if not StaticPopupDialogs or not StaticPopup_Show then return end
    if not StaticPopupDialogs.HORIZONSUITE_ECHO_CLEAR_HISTORY then
        StaticPopupDialogs.HORIZONSUITE_ECHO_CLEAR_HISTORY = {
            text = addon.L["ECHO_CLEAR_HISTORY_CONFIRM"],
            button1 = YES, button2 = NO,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
            OnAccept = function() Echo.History.Clear() end,
        }
    end
    StaticPopup_Show("HORIZONSUITE_ECHO_CLEAR_HISTORY")
end
```

`History.Clear` returns early while History is unbound (Echo disabled), so a clear from the options page with Echo off would do nothing. Change its first line in `EchoHistory.lua` to:

```lua
    local target = root
    if not target then
        local db = _G[addon.DATABASE]
        target = type(db) == "table" and type(db.echoHistory) == "table" and db.echoHistory or nil
    end
    if not target then return end
```

and use `target` in place of `root` in the three lines after it. Pins and tiers (`prefs`) are kept, as before. Add a test to the "Settings applied" section: with History unbound, set `_G[HorizonSuite.DATABASE] = { echoHistory = { chars = { x = {} }, prefs = { p = 1 } } }` (setting `HorizonSuite.DATABASE = "HorizonDB_Test"` first). Call `Echo.History.Clear()`, then check that `chars` is empty and `prefs.p == 1`. Restore both globals to nil.

- [ ] **Step 3: Create `options/modules/OptionsEcho.lua`:**

```lua
--[[
    Horizon Suite - Echo - Options page
    One dashboard category for Echo. Every setting is in ECHO_KEYS, so a change re-applies
    through Echo.ApplyOptions (options/OptionsData.lua) without a reload.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end
local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section, Button, Toggle = addon.Section, addon.Button, addon.Toggle
local D   = addon.ECHO_DEFAULTS
local LIM = addon.ECHO_LIMITS
if not D or not LIM then return end

local function clamp(v, key)
    local lim = LIM[key]
    return math.max(lim.min, math.min(lim.max, v))
end

local function Echo() return addon.Echo end

local TIER_OPTIONS = {
    { L["ECHO_TIER_LOUD"],  "loud"  },
    { L["ECHO_TIER_COUNT"], "count" },
    { L["ECHO_TIER_QUIET"], "quiet" },
    { L["ECHO_TIER_MUTED"], "muted" },
}

local function TierKey(kind) return "echoTier" .. kind:sub(1, 1):upper() .. kind:sub(2) end
local function FeedKey(kind) return "echoFeed" .. kind:sub(1, 1):upper() .. kind:sub(2) end

local function TierDropdown(kind, label)
    local key = TierKey(kind)
    return { type = "dropdown", name = label, desc = L["ECHO_TIER_DESC"], dbKey = key,
        options = TIER_OPTIONS, preserveOrder = true,
        get = function() return getDB(key, D[key]) end,
        set = function(v) setDB(key, v) end }
end

local function IntSlider(key, name, desc, step)
    return { type = "slider", name = name, desc = desc, dbKey = key,
        min = LIM[key].min, max = LIM[key].max, step = step,
        get = function() return tonumber(getDB(key, D[key])) or D[key] end,
        set = function(v) setDB(key, clamp(math.floor(v + 0.5), key)) end }
end

local options = {
    Section(L["ECHO_SECTION_GENERAL"]),
    { type = "dropdown", name = L["ECHO_COLUMN_EDGE"], desc = L["ECHO_COLUMN_EDGE_DESC"], dbKey = "echoColumnEdge",
      options = { { L["ECHO_EDGE_RIGHT"], "right" }, { L["ECHO_EDGE_LEFT"], "left" } }, preserveOrder = true,
      get = function() return getDB("echoColumnEdge", D.echoColumnEdge) end,
      set = function(v) setDB("echoColumnEdge", v == "left" and "left" or "right") end },
    Toggle(L["ECHO_LOCK"], L["ECHO_LOCK_DESC"], "echoLockPosition", D.echoLockPosition),
    Button(L["AXIS_RESET_POSITION"], L["ECHO_RESET_POSITION_DESC"], function()
        setDB("echoX", nil)
        setDB("echoY", nil)
    end),
    { type = "slider", name = L["ECHO_SCALE"], desc = L["ECHO_SCALE_DESC"], dbKey = "echoScale",
      min = LIM.echoScale.min * 100, max = LIM.echoScale.max * 100, step = 5,
      get = function() return math.floor((tonumber(getDB("echoScale", D.echoScale)) or 1) * 100 + 0.5) end,
      set = function(v) setDB("echoScale", clamp(v / 100, "echoScale")) end },
    { type = "dropdown", name = L["ECHO_STRATA"], desc = L["ECHO_STRATA_DESC"], dbKey = "echoFrameStrata",
      options = {
          { L["FOCUS_STRATA_BACKGROUND"], "BACKGROUND" }, { L["FOCUS_STRATA_LOW"], "LOW" },
          { L["FOCUS_STRATA_MEDIUM"], "MEDIUM" }, { L["FOCUS_STRATA_HIGH"], "HIGH" },
          { L["ECHO_STRATA_DIALOG"], "DIALOG" },
      }, preserveOrder = true,
      get = function() return getDB("echoFrameStrata", D.echoFrameStrata) end,
      set = function(v) setDB("echoFrameStrata", v) end },
    IntSlider("echoMaxTiles", L["ECHO_MAX_TILES"], L["ECHO_MAX_TILES_DESC"], 1),

    Section(L["ECHO_SECTION_NOTIFICATIONS"]),
    { type = "dropdown", name = L["ECHO_TOAST_STYLE"], desc = L["ECHO_TOAST_STYLE_DESC"], dbKey = "echoToastStyle",
      options = {
          { L["AUGMENT_TOAST_STYLE_COMPACT"], "compact" },
          { L["AUGMENT_TOAST_STYLE_FRAMED"],  "framed"  },
          { L["AUGMENT_TOAST_STYLE_ACCENT"],  "accent"  },
      }, preserveOrder = true,
      get = function() return getDB("echoToastStyle", D.echoToastStyle) end,
      set = function(v) setDB("echoToastStyle", v) end },
    IntSlider("echoToastSeconds", L["ECHO_TOAST_SECONDS"], L["ECHO_TOAST_SECONDS_DESC"], 1),
    Toggle(L["ECHO_HOLD_IN_COMBAT"], L["ECHO_HOLD_IN_COMBAT_DESC"], "echoHoldToastsInCombat", D.echoHoldToastsInCombat),
    { type = "editbox", name = L["ECHO_KEYWORDS"], labelText = L["ECHO_KEYWORDS"], desc = L["ECHO_KEYWORDS_DESC"],
      dbKey = "echoKeywords", height = 24,
      get = function() return getDB("echoKeywords", D.echoKeywords) or "" end,
      set = function(v) setDB("echoKeywords", type(v) == "string" and v or "") end },

    Section(L["ECHO_SECTION_TIERS"]),
    TierDropdown("whisper",  L["ECHO_KIND_WHISPER"]),
    TierDropdown("bnet",     L["ECHO_KIND_BNET"]),
    TierDropdown("party",    L["ECHO_KIND_PARTY"]),
    TierDropdown("raid",     L["ECHO_KIND_RAID"]),
    TierDropdown("instance", L["ECHO_KIND_INSTANCE"]),
    TierDropdown("guild",    L["ECHO_KIND_GUILD"]),
    TierDropdown("officer",  L["ECHO_KIND_OFFICER"]),
    TierDropdown("channel",  L["ECHO_KIND_CHANNEL"]),

    Section(L["ECHO_SECTION_FEEDS"]),
}

for _, kind in ipairs({ "loot", "progress", "system" }) do
    local name = L["ECHO_KIND_" .. kind:upper()]
    local feedKey = FeedKey(kind)
    options[#options + 1] = Toggle(L["ECHO_FEED_SHOW"]:format(name), L["ECHO_FEED_SHOW_DESC"], feedKey, D[feedKey])
    local tier = TierDropdown(kind, L["ECHO_FEED_TIER"]:format(name))
    tier.visibleWhen = function() return getDB(feedKey, D[feedKey]) ~= false end
    options[#options + 1] = tier
end

local tail = {
    Section(L["ECHO_SECTION_HISTORY"]),
    Toggle(L["ECHO_SAVE_HISTORY"], L["ECHO_SAVE_HISTORY_DESC"], "echoSaveHistory", D.echoSaveHistory),
    Button(L["ECHO_CLEAR_HISTORY"], L["ECHO_CLEAR_HISTORY_DESC"], function()
        local E = Echo()
        if E and E.ConfirmClearHistory then E.ConfirmClearHistory() end
    end),

    Section(L["ECHO_SECTION_BLIZZARD_CHAT"]),
    Toggle(L["ECHO_HIDE_STORED"], L["ECHO_HIDE_STORED_DESC"], "echoHideStoredWhispers", D.echoHideStoredWhispers),

    Section(L["ECHO_SECTION_CARD"]),
    IntSlider("echoCardWidth",  L["ECHO_CARD_WIDTH"],  L["ECHO_CARD_SIZE_DESC"], 10),
    IntSlider("echoCardHeight", L["ECHO_CARD_HEIGHT"], L["ECHO_CARD_SIZE_DESC"], 10),
    { type = "dropdown", name = L["ECHO_FONT"], desc = L["ECHO_FONT_DESC"], dbKey = "echoFontPath", searchable = true,
      options = function() return addon.GetPerElementFontDropdownOptions("echoFontPath") end,
      get = function() return getDB("echoFontPath", D.echoFontPath) end,
      set = function(v) setDB("echoFontPath", v) end,
      displayFn = addon.DisplayPerElementFont, fontPreviewInList = true },
}
for _, opt in ipairs(tail) do options[#options + 1] = opt end

addon.OptionCategories[#addon.OptionCategories + 1] = {
    key = "Echo", name = L["NAME_ADDON_CHAT"], desc = L["ECHO_DESC"], moduleKey = "echo",
    options = options,
}
```

Check the editbox row: read `options/dashboard/DashboardAccordionBuild.lua:543-551` and `options/modules/OptionsAxis.lua:360-400`, and pass the field names the builder actually reads (`labelText`, `height`, `readonly`, `get`/`set`). The keyword box is one line. If the builder only takes a multi-line box, use its smallest height and strip newlines in `set` (`v:gsub("[\r\n]+", ",")`).

The reset button writes `echoX`/`echoY` to nil through `setDB`, which runs the Echo apply block in `OptionsData_SetDB` (it doesn't return early on nil), and `ApplyOptions` re-anchors the column. `NAME_ADDON_CHAT` is added in Task 6. Until then the page title shows as its key, which is fine between tasks.

- [ ] **Step 4: Route the keys.** In `options/OptionsData.lua`, add after the `ESSENCE_KEYS` block:

```lua
    if addon.ECHO_KEYS and addon.ECHO_KEYS[key] and addon.Echo and addon.Echo.ApplyOptions
        and addon.IsModuleEnabled and addon:IsModuleEnabled("echo") then
        addon.Echo.ApplyOptions()
    end
```

- [ ] **Step 5: TOC.** Add `options/modules/OptionsEcho.lua` on the line after `options/modules/OptionsEssence.lua`.

- [ ] **Step 6: Load-test the page.** Add before the Redraw section:

```js
// --- Options page builds -----------------------------------------------------
run(read('options/modules/defaults/OptionsDefaultsEcho.lua'), 'echo-defaults-2');
run(`
  local A = HorizonSuite
  A.OptionCategories = {}
  local db = {}
  A.OptionsData_GetDB = function(k, d) if db[k] ~= nil then return db[k] end return d end
  A.OptionsData_SetDB = function(k, v) db[k] = v end
  local function merge(t, o) if o then for k, v in pairs(o) do t[k] = v end end return t end
  A.Section = function(n) return { type = "section", name = n } end
  A.Button = function(n, d, f) return { type = "button", name = n, desc = d, onClick = f } end
  A.Toggle = function(n, d, key, def, o) return merge({ type = "toggle", name = n, desc = d, dbKey = key,
    get = function() return A.OptionsData_GetDB(key, def) end, set = function(v) A.OptionsData_SetDB(key, v) end }, o) end
  A.GetPerElementFontDropdownOptions = function() return { { "Global", "__global__" } } end
`, 'echo-options-stubs');
run(read('options/modules/OptionsEcho.lua'), 'options/modules/OptionsEcho.lua');
run(`
  local A = HorizonSuite
  local cat = A.OptionCategories[1]
  check("one Echo category", #A.OptionCategories == 1 and cat.moduleKey == "echo", #A.OptionCategories)
  local keys = {}
  for _, opt in ipairs(cat.options) do if opt.dbKey then keys[opt.dbKey] = opt end end
  for key in pairs(A.ECHO_DEFAULTS) do
    if key ~= "echoHoverDelay" then check("on the page: " .. key, keys[key] ~= nil, key) end
  end
  keys.echoScale.set(250)
  check("scale slider clamps", A.OptionsData_GetDB("echoScale") == 1.6, A.OptionsData_GetDB("echoScale"))
  keys.echoScale.set(85)
  check("scale slider stores a fraction", A.OptionsData_GetDB("echoScale") == 0.85, A.OptionsData_GetDB("echoScale"))
  check("scale slider reads percent", keys.echoScale.get() == 85, keys.echoScale.get())
  keys.echoMaxTiles.set(1)
  check("max tiles at least two", A.OptionsData_GetDB("echoMaxTiles") == 2, A.OptionsData_GetDB("echoMaxTiles"))
  check("guild tier default", keys.echoTierGuild.get() == "quiet", keys.echoTierGuild.get())
  A.OptionsData_SetDB("echoFeedLoot", false)
  check("loot tier hidden with its feed off", keys.echoTierLoot.visibleWhen() == false, "shown")
  A.OptionCategories, A.OptionsData_GetDB, A.OptionsData_SetDB = nil, nil, nil
  A.Section, A.Button, A.Toggle, A.GetPerElementFontDropdownOptions = nil, nil, nil, nil
  A.ECHO_DEFAULTS, A.ECHO_KEYS, A.ECHO_LIMITS = nil, nil, nil
`, 'echo-options-page');
```

- [ ] **Step 7: Run the tests and parse-check** (including `options/OptionsData.lua`). Expected: all pass.

- [ ] **Step 8: Commit.**

```bash
git add options/modules/OptionsEcho.lua options/OptionsData.lua modules/Echo/EchoModule.lua modules/Echo/EchoHistory.lua HorizonSuite.toc locales/horizon/enUS.lua tools/test_echo_logic.js
git commit -m "feat(echo): add the Echo options page"
```

(Leave `EchoHistory.lua` out of `git add` if Step 2 didn't change it.)

---

### Task 6: Echo on the dashboard

**Files:**
- Modify: `core/Config.lua` (`BrandDisplay.module`, `BrandDisplay.simple`)
- Modify: `HorizonSuite.lua` (first-install module list; the "ensure exists" block)
- Modify: `options/modules/OptionsAxis.lua` (Modules toggles)
- Modify: `options/dashboard/DashboardFrame.lua` (`moduleLabels`, `PREVIEW_MODULE_KEYS`, `TILE_MODULE_LABEL_COLORS`, `SEARCH_MODULE_FILTER_GROUP_ORDER`, `MODULE_LABELS`, `groupOrder`, `MODULE_NAME_KEYS`)
- Modify: `options/dashboard/DashboardHomeWelcome.lua` (`MODULE_ORDER`, `MODULE_COLORS`, `MODULE_ICONS`, `MODULE_DESCS`)
- Modify: `options/dashboard/DashboardModuleGuide.lua` (`GUIDE_MODULE_COLORS`, the preview tag rows, a guide card)
- Modify: `locales/horizon/enUS.lua`

This task is wiring only; nothing in it runs in the harness. Each edit mirrors the `essence` entry beside it. Search each file for `essence` and add an `echo` entry next to every hit listed here.

- [ ] **Step 1: Strings.** Add to `enUS.lua`:
  - next to `L["NAME_ADDON_CHARACTER"]`: `L["NAME_ADDON_CHAT"] = "Echo"`
  - next to `L["AXIS_MODULE_NAME_SIMPLE_CHARACTER"]`: `L["AXIS_MODULE_NAME_SIMPLE_CHAT"] = "Chat"`
  - next to the Essence guide body: `L["DASH_GUIDE_MOD_ECHO_BODY"] = "Echo gives each whisper and group chat its own tile at the edge of the screen. Hover a tile to read and reply, click it for the full conversation. Loot, progress and system lines collect in feeds. Open Echo in the sidebar for notifications, history and layout."`
  - next to `L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"]`: `L["DASH_ECHO_MODULE_SHORT_DESCRIPTION"] = "Whispers and group chat as tiles you can read and reply from."`
  - next to `L["HOME_MOD_ESSENCE_SHORT"]`: `L["HOME_MOD_ECHO_SHORT"] = "Whispers and group chat as tiles you reply from."`

  Match the column alignment of the neighbouring lines.

- [ ] **Step 2: `core/Config.lua`.** Add `echo = L["NAME_ADDON_CHAT"],` after `essence` in `module`, and `echo = L["AXIS_MODULE_NAME_SIMPLE_CHAT"],` after `essence` in `simple`.

- [ ] **Step 3: `HorizonSuite.lua`.**
  - In the first-install block, add `db.modules.echo = { enabled = false }` after the essence line.
  - After the "Ensure essence exists" block, add:

```lua
    -- Ensure echo exists for existing installs; disabled by default (preview)
    if not db.modules.echo then
        db.modules.echo = { enabled = false }
    end
```

- [ ] **Step 4: `OptionsAxis.lua`.** After the essence toggle row, add:

```lua
                { type = "toggle", name = (BM and BM("echo") or L["NAME_ADDON_CHAT"]) .. previewSuffix, desc = L["DASH_ECHO_MODULE_SHORT_DESCRIPTION"] .. previewDescSuffix, dbKey = "_module_echo", get = function() return addon:IsModuleEnabled("echo") end, set = function(v) setModuleFromOptions("echo", v) end },
```

- [ ] **Step 5: `DashboardFrame.lua`.**
  - `moduleLabels`: add `echo = addon.Dashboard_BrandModule("echo"),` after essence.
  - `PREVIEW_MODULE_KEYS`: `{ essence = true, echo = true }`.
  - `TILE_MODULE_LABEL_COLORS`: add `echo = { 143/255, 163/255, 232/255 },  -- 8FA3E8`.
  - `SEARCH_MODULE_FILTER_GROUP_ORDER` and `groupOrder`: insert `"echo"` after `"essence"`.
  - `MODULE_LABELS`: add `["echo"] = addon.Dashboard_BrandModule("echo")`.
  - `MODULE_NAME_KEYS`: insert `"echo"` after `"essence"`.
  - Search the file for any other table keyed by module names (for example a `PN_MODULE_COLORS` table that the comments mention). Add echo with `8FA3E8` wherever essence appears with a colour.

- [ ] **Step 6: `DashboardHomeWelcome.lua`.**
  - `MODULE_ORDER`: append `"echo"`.
  - `MODULE_COLORS`: `echo = { 0.56, 0.64, 0.91 }`.
  - `MODULE_ICONS`: `echo = "ui_chat"`. If that texture doesn't exist, use `"inv_letter_15"`. Icons here are `Interface\Icons\` basenames; check how the table is consumed, and pick an icon that resolves on both clients. `inv_letter_15` is safe.
  - `MODULE_DESCS`: `echo = L["HOME_MOD_ECHO_SHORT"]`.

  If this file also has a preview-key list, add echo to it.

- [ ] **Step 7: `DashboardModuleGuide.lua`.**
  - `GUIDE_MODULE_COLORS`: `["Echo"] = "8FA3E8"`.
  - Preview tag rows: add `{ key = "echo", label = "Echo", tag = prevTag, when = PREVIEW_MODULE_KEYS },` after essence. Make sure the local `PREVIEW_MODULE_KEYS` in this file includes echo.
  - After the essence card, add:

```lua
    local echoCard = CreateGuideAccordionCard(content, ModuleGuideSectionTitle("echo"), false, RunAccordionLayout)
    local echoBody = MakeDashboardWelcomeMixedScriptText(echoCard.settingsContainer, L["DASH_GUIDE_MOD_ECHO_BODY"], 12, 0.62, 0.65, 0.70, "LEFT")
    echoBody:SetWordWrap(true)
    echoBody:SetSpacing(4)
```

  - Add `layoutAccordionCard(echoCard, { echoBody }, 10)` after the essence layout line.

- [ ] **Step 8: Sweep for missed lists.** Run `grep -rn '"essence"\|essence *=' options core HorizonSuite.lua | grep -v "^options/modules/OptionsEssence\|defaults/OptionsDefaultsEssence"`. For every hit that lists modules, check that echo is there too. Report any you deliberately skipped, with the reason.

- [ ] **Step 9: Parse-check every changed file and run the tests.** Expected: all parse; the suite is unchanged and passing.

- [ ] **Step 10: Commit.**

```bash
git add core/Config.lua HorizonSuite.lua options/modules/OptionsAxis.lua options/dashboard/DashboardFrame.lua options/dashboard/DashboardHomeWelcome.lua options/dashboard/DashboardModuleGuide.lua locales/horizon/enUS.lua
git commit -m "feat(options): add Echo to the dashboard as a preview module"
```

---

### Task 7: Slash strings through the locale file

**Files:**
- Modify: `modules/Echo/EchoSlash.lua`
- Modify: `locales/horizon/enUS.lua`
- Test: `tools/test_echo_logic.js`

- [ ] **Step 1: Strings.** Add to `enUS.lua` (Echo block):

```lua
L["ECHO_SLASH_STATUS"]                                        = "Echo: %d conversations, %d messages left in Blizzard chat (unrouted)"
L["ECHO_SLASH_STATUS_ROW"]                                    = "  %s  tier=%s unread=%d messages=%d%s"
L["ECHO_SLASH_PINNED"]                                        = " pinned"
L["ECHO_SLASH_PROBE"]                                         = "Echo probe: sendChat=%s sendBN=%s secretChat=%s bnetWhispers=%s"
L["ECHO_SLASH_PROBE_START"]                                   = "Echo probe: describing the next %d chat messages (types only, never text)."
L["ECHO_SLASH_YES"]                                           = "yes"
L["ECHO_SLASH_NO"]                                            = "no"
L["ECHO_SLASH_NO_COMBAT"]                                     = "Cannot toggle Echo during combat."
L["ECHO_SLASH_DISABLED"]                                      = "Horizon Echo is disabled. Use /h echo toggle to enable it."
L["ECHO_SLASH_TEST"]                                          = "Echo: added sample conversations. /h echo status lists them."
L["ECHO_SLASH_CLEARED"]                                       = "Echo: whisper history cleared for every character."
L["ECHO_SLASH_LOCKED"]                                        = "Echo: column locked."
L["ECHO_SLASH_UNLOCKED"]                                      = "Echo: column unlocked. Drag the chat button at its foot to move it, then /h echo lock."
L["ECHO_SLASH_RESET"]                                         = "Echo: column moved back to its corner."
L["ECHO_SLASH_HELP"]                                          = "Echo commands:"
L["ECHO_SLASH_HELP_TOGGLE"]                                   = "  /h echo toggle       - Enable / disable Echo (reloads the UI)"
L["ECHO_SLASH_HELP_STATUS"]                                   = "  /h echo status       - List conversations, tiers and unread counts"
L["ECHO_SLASH_HELP_PROBE"]                                    = "  /h echo probe [n]    - Describe the next n chat messages (default 10)"
L["ECHO_SLASH_HELP_UNLOCK"]                                   = "  /h echo unlock       - Let the column be dragged by its chat button"
L["ECHO_SLASH_HELP_LOCK"]                                     = "  /h echo lock         - Lock the column in place"
L["ECHO_SLASH_HELP_RESET"]                                    = "  /h echo reset        - Move the column back to its corner"
L["ECHO_SLASH_HELP_TEST"]                                     = "  /h echo test         - Add sample conversations"
L["ECHO_SLASH_HELP_CLEAR"]                                    = "  /h echo clearhistory - Delete saved whisper history"
L["ECHO_SLASH_HELP_OPTIONS"]                                  = "  More settings: Horizon dashboard, Echo."
L["ECHO_SLASH_UNKNOWN"]                                       = "Unknown command. Use /h echo for help."
```

- [ ] **Step 2: Replace every literal in `EchoSlash.lua`.** Each `HSPrint("…")` and `HSPrint(("…"):format(…))` becomes `HSPrint(L["KEY"])` or `HSPrint(L["KEY"]:format(…))`, with the arguments unchanged. Add `local L = addon.L` under the `Echo` local. `sendChat and "yes" or "no"` becomes `sendChat and L["ECHO_SLASH_YES"] or L["ECHO_SLASH_NO"]`. The pinned suffix becomes `conv.pinned and L["ECHO_SLASH_PINNED"] or ""`. Add `HSPrint(L["ECHO_SLASH_HELP_OPTIONS"])` as the help's last line. `lock`/`unlock` keep using `addon.SetDB`; the drag handler reads the lock live, so no re-apply is needed. `reset` keeps calling `Echo.Tiles.ResetPosition()`.

- [ ] **Step 3: Test.** Add before the Redraw section:

```js
// --- Slash output goes through the locale table -------------------------------
run(`
  local src = ${JSON.stringify(read('modules/Echo/EchoSlash.lua'))}
  local literal = 0
  for line in src:gmatch("[^\\n]+") do
    if line:find("HSPrint%(") and line:find('HSPrint%(%(?"') then literal = literal + 1 end
  end
  check("no literal strings printed by /h echo", literal == 0, literal)
`, 'echo-slash-locale');
```

The pattern skips the `HSPrint` fallback definition at the top of the file, because that line has `print(` rather than `HSPrint(`. If it still matches, exclude lines that start with `local HSPrint`.

- [ ] **Step 4: Run the tests and parse-check.** Expected: all pass. The locale audit is unaffected (`node tools/locale_audit.js` only reports translation coverage).

- [ ] **Step 5: Commit.**

```bash
git add modules/Echo/EchoSlash.lua locales/horizon/enUS.lua tools/test_echo_logic.js
git commit -m "refactor(echo): route slash output through the locale table"
```

---

### Task 8: Lint globals, the spec and the checklist

**Files:**
- Modify: `.luacheckrc`
- Modify: `Docs/Engineering/2026-09-24-echo-chat-design.md`

- [ ] **Step 1: `.luacheckrc`.**
  - Add to `read_globals`, in the Blizzard section, if missing:
    - `ChatFrameUtil`
    - `ChatFrame_AddMessageEventFilter`, `ChatFrame_RemoveMessageEventFilter`
    - `ChatEdit_SetLastTellTarget`
    - `StaticPopupDialogs`, `StaticPopup_Show`
    - `YES`, `NO`
  - `StaticPopupDialogs` is written to, so it belongs in `globals` if the file already treats it that way. Check how `core/Core.lua`'s use of it is declared.

- [ ] **Step 2: The spec.**
  - In "Carried into plan 5", tick off what this plan did: mark each item done or name its plan 6 home. Rename the heading's remaining items to **"Carried into plan 6"** and list: better tile icons, distinct channel glyphs, `PaintTileFace` for the toast and stack, one badge-tier helper, the card's further re-render coalescing, scroll anchoring, drafts of closed conversations, and the `upper()` fix.
  - Under "Options", add a line saying the page is built (plan 5). Note three things there:
    - Positions are saved in screen units, so a position saved at a scale other than 1 before plan 5 shifts once.
    - The whisper filter sets the reply target for hidden whispers.
    - A switched-off feed files nothing but still fails a pending whisper.
  - In "Build order", note that step 6 (Options, persistence, keybinds and polish) is split across plans 5 and 6.

- [ ] **Step 3: Run the tests and commit.**

```bash
git add .luacheckrc Docs/Engineering/2026-09-24-echo-chat-design.md
git commit -m "docs(echo): record plan 5 and carry the rest to plan 6"
```

---

### Task 9: In-game check (on the Windows PC, a human step)

Full restart, because the TOC gained files. Then enable Echo from the dashboard's Modules list, or with `/h echo toggle`.

- [ ] Dashboard: Echo shows in the sidebar, the Modules toggles, the home cards and the module guide, in periwinkle with a Preview tag. Searching "whisper" finds Echo settings.
- [ ] Screen edge Left: the tiles jump to the bottom left, and the stack, card and toasts open to their right. Right puts them back.
- [ ] Unlock, drag, lock; change the scale from 100 to 140. The column's foot stays put, and the stack and card grow with it.
- [ ] Strata High: the tiles draw over the bags. Most tiles shown at 2 gives two tiles and a +N tile.
- [ ] Pop-up style and time change the next toast. Hold pop-ups off: a whisper in combat toasts at once.
- [ ] Guild tier set to Loud: a guild line shows a dot and a toast. Muted: nothing.
- [ ] Mention keyword "tank": a party line containing "Tank" toasts.
- [ ] Loot feed off: the Loot tile closes and new loot doesn't bring it back; Blizzard chat still shows the loot. Turn it back on.
- [ ] Save whisper history off, `/reload`: the tiles don't come back and no whisper is saved. Back on. Clear history asks first, and after Yes a relog shows no old whispers.
- [ ] Hide whispers Echo has stored, on: a whisper shows in Echo and not in Blizzard's chat window. Pressing R replies to that person.
- [ ] Card width 480 and height 600: the card grows and bubbles use the width. Font: pick another font, and the tiles, stack and card change without a reload.
- [ ] A group-loot roll or a busy Trade channel with the card open: no stutter.
- [ ] `/h echo` prints the help from the locale table, ending with the dashboard hint.
- [ ] Forever beta: the page opens. The Battle.net rows are harmless where Battle.net whispers are missing.
