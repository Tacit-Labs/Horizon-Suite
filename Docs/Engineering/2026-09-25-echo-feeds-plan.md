# Horizon Echo: Feed Tiles and Live Links Implementation Plan (4 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three read-only feed conversations, Loot, Progress and System, with icon tiles and timestamped lines. Make links clickable in bubbles, feed lines and the stack.

**Architecture:** Feeds are ordinary Store conversations whose key is the kind (`loot`, `progress`, `system`), routed by event type in `EchoEvents`. They are quiet by default, never persisted, and flagged by `Store.FEED_KINDS`.
- `EchoView` gains the feed helpers: `IsFeed`, icon specs, line colour and timestamp.
- Views draw feeds read-only: no reply box, and full-width timestamped lines in the card.
- `Echo.PaintTileFace` in `EchoTiles` draws a tile's icon or letter wherever a tile appears.
- `Echo.Links.Attach` makes a frame's hyperlinks live through the game's own `SetItemRef` and `GameTooltip`.

**Tech Stack:** WoW Lua 5.1 addon (Retail 120100 and Forever 16001), and the fengari harness `tools/test_echo_logic.js`.

**Spec:** `Docs/Engineering/2026-09-24-echo-chat-design.md`, section "Feeds (plan 4, decided 2026-09-25)".

**Plan series:** 1 Foundation, 2 Tiles and stack, 3 Expanded card (all done). **4 Feeds and live links (this plan).** 5 Options page, dashboard, whisper filter, keywords, polish and better icons. All of it is on branch `feature/echo`.

## Global Constraints

- **Lua:** Lua 5.1 only, and runnable on fengari's 5.3. Don't use `goto`, `//`, bitwise operators, `unpack`, `tinsert` or `%z`.
- **File header:** every file starts with `local addon = _G.HorizonSuite` and `if not addon then return end`, and hangs off `addon.Echo`.
- **Secret values:** ask `Echo.IsSecret(v)` before `type()`, comparing, concatenating, formatting, matching or indexing by a chat value. A secret text is passed to `SetText` **alone**. Never read a size from a FontString holding secret text.
- **Battle.net `|K` names:** display them whole. One documented exception is the System feed's friend alerts. There a readable `|K` name is formatted into Blizzard's own `BN_INLINE_TOAST_*` string, exactly as Blizzard's chat does. Feeds are never persisted, so that text never reaches disk.
- **Feed routing:** feeds are routed by event type only. A feed line is never outgoing, never urgent and has no class.
- **Frame names:** no new frame names. Frames are non-secure.
- **Strings:** shown to the player through `addon.L` (`locales/horizon/enUS.lua`).
- **Feed icons:**
  - Loot `Interface\Icons\INV_Misc_Bag_10`
  - Progress `Interface\Icons\Achievement_General`
  - System `Interface\Icons\INV_Misc_Gear_01`
  - All are cropped with texcoords 0.08–0.92.
- **Commits:** Conventional Commits with scope `echo`, on branch `feature/echo`, each with exactly one `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` trailer. Run `git add` and `git commit` as separate commands.
- **Test command:** `NODE_PATH="$HOME/.cache/hs-test/node_modules" node tools/test_echo_logic.js` (530 passing at the start of this plan).
- **Parse check:**
  `NODE_PATH="$HOME/.cache/hs-test/node_modules" node -e "const {lauxlib,lua,to_luastring,to_jsstring}=require('fengari');const L=lauxlib.luaL_newstate();for(const f of process.argv.slice(1)){const s=require('fs').readFileSync(f,'utf8');console.log(f,lauxlib.luaL_loadbuffer(L,to_luastring(s),null,to_luastring(f))===lua.LUA_OK?'parses':to_jsstring(lua.lua_tostring(L,-1)))}" <files>`
- **Stand-in frames:** `STUB_FRAME` / `STUB_CREATE_FRAME`. Frame sections set `CreateFrame = STUB_CREATE_FRAME` first. Use `rawget` to test that a field is absent. Per-object overrides are undone with `nil`. Stubs don't fire OnShow or OnHide.

## File map

| File | Status | Responsibility |
|------|--------|----------------|
| `modules/Echo/EchoStore.lua` | Modify | Feed kinds, their events and default tier |
| `modules/Echo/EchoEvents.lua` | Modify | Feed records, achievement and Battle.net alert text, system feed plus failed-whisper check, registration |
| `modules/Echo/EchoView.lua` | Modify | `IsFeed`, feed icons, `LineColor`, `FeedTime` |
| `modules/Echo/EchoLinks.lua` | Modify | `Links.Attach`: hover tooltip, click through `SetItemRef` |
| `modules/Echo/EchoTiles.lua` | Modify | `Echo.PaintTileFace`; icon tiles; toast icon |
| `modules/Echo/EchoStack.lua` | Modify | Feed cards read-only; line colours; live links |
| `modules/Echo/EchoCard.lua` | Modify | Feed lines with timestamps; read-only; live links in bubbles; icon row tiles |
| `locales/horizon/enUS.lua` | Modify | Feed names |
| `.luacheckrc` | Modify | New read globals |
| `tools/test_echo_logic.js` | Modify | Tests |

---

### Task 1: Feed conversations in the Store and Events

**Files:**
- Modify: `modules/Echo/EchoStore.lua` (`DEFAULT_TIERS`, `EVENT_KIND`, new `FEED_KINDS`)
- Modify: `modules/Echo/EchoEvents.lua` (`BuildRecord`, `Dispatch`, `Enable`)
- Test: `tools/test_echo_logic.js` (new section before `// --- Summary`)

**Interfaces:**
- Produces:
  - `Store.FEED_KINDS` (`{ loot = true, progress = true, system = true }`).
  - Feed keys `loot`, `progress` and `system`, each with the `quiet` tier.
  - Feed records: `{ convKey, text, secret, outgoing = false, time, feed = true, chatType, sender? }`. `chatType` is the event name without `CHAT_MSG_`, or `BN_INLINE_TOAST_ALERT`.
- Keeps: `CHAT_MSG_SYSTEM` still runs `Events.OnSystemMessage`, so a whisper to an offline player still fails, and is then also filed in the System feed.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Feeds: loot, progress and system lines --------------------------------------------
run(`
  local S, E = HorizonSuite.Echo.Store, HorizonSuite.Echo.Events
  S.Reset()
  local function p(text, sender) return text, sender, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil end

  check("feeds are known kinds", S.KindOf("loot") == "loot" and S.KindOf("progress") == "progress" and S.KindOf("system") == "system", "?")
  check("feeds are quiet by default", S.TierOf("loot") == "quiet" and S.TierOf("progress") == "quiet" and S.TierOf("system") == "quiet", "?")
  check("feeds are flagged", S.FEED_KINDS.loot and S.FEED_KINDS.progress and S.FEED_KINDS.system and not S.FEED_KINDS.party, "?")

  local r = E.BuildRecord("CHAT_MSG_LOOT", p("You receive loot: [Cloak].", "Kaelis-Horizon"))
  check("loot goes to the loot feed", r and r.convKey == "loot" and r.feed == true, r and r.convKey)
  check("your own loot is not an outgoing message", r.outgoing == false, r.outgoing)
  check("a feed line remembers its line type", r.chatType == "LOOT", r.chatType)
  check("a feed line has no class and is never urgent", r.class == nil and r.urgent == false, "?")
  check("money and currency go to loot", E.BuildRecord("CHAT_MSG_MONEY", p("You loot 3 Gold")).convKey == "loot"
        and E.BuildRecord("CHAT_MSG_CURRENCY", p("You receive currency")).convKey == "loot", "?")
  for _, ev in ipairs({ "CHAT_MSG_COMBAT_FACTION_CHANGE", "CHAT_MSG_COMBAT_XP_GAIN", "CHAT_MSG_SKILL" }) do
    check(ev .. " goes to progress", E.BuildRecord(ev, p("progress")).convKey == "progress", ev)
  end
  r = E.BuildRecord("CHAT_MSG_SYSTEM", p("You feel rested."))
  check("system lines go to the system feed", r.convKey == "system" and r.chatType == "SYSTEM", r.convKey)

  r = E.BuildRecord("CHAT_MSG_ACHIEVEMENT", p("%s has earned the achievement [Cloak Collector]!", "Brisa-Horizon"))
  check("an achievement names the player as a link", r.convKey == "progress"
        and r.text == "|Hplayer:Brisa-Horizon|h[Brisa]|h has earned the achievement [Cloak Collector]!", r.text)
  r = E.BuildRecord("CHAT_MSG_GUILD_ACHIEVEMENT", p("%s has earned the achievement [Raider]!", SECRET("Brisa-Horizon")))
  check("a secret achiever leaves the text as it came", r.text == "%s has earned the achievement [Raider]!", r.text)

  local savedOnline = BN_INLINE_TOAST_FRIEND_ONLINE
  BN_INLINE_TOAST_FRIEND_ONLINE = "%s has come online."
  r = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_ONLINE", "|Kq1|k"))
  check("a battle.net alert uses Blizzard's own text", r and r.convKey == "system" and r.text == "|Kq1|k has come online." and r.chatType == "BN_INLINE_TOAST_ALERT", r and r.text)
  local none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("NOT_A_REAL_TOAST", "|Kq1|k"))
  check("an alert with no Blizzard text is ignored", none == nil and reason == "ignored", reason)
  none, reason = E.BuildRecord("BN_INLINE_TOAST_ALERT", p("FRIEND_ONLINE", SECRET("|Kq1|k")))
  check("an alert with a secret name is ignored", none == nil and reason == "ignored", reason)
  BN_INLINE_TOAST_FRIEND_ONLINE = savedOnline

  r = E.BuildRecord("CHAT_MSG_LOOT", p(SECRET("You receive loot: [Hidden]."), "Kaelis-Horizon"))
  check("a secret loot line still lands in its feed", r and r.convKey == "loot" and r.secret == true, r and r.convKey)

  S.Reset()
  local q = S.AddPending("w:Ghost-Horizon", "hello?")
  E.Dispatch("CHAT_MSG_SYSTEM", "No player named 'Ghost' is currently playing.")
  check("a system line still fails the pending whisper", q.status == "failed", q.status)
  check("and it is filed in the system feed", S.Get("system") and #S.Get("system").messages == 1, "not filed")
  E.Dispatch("CHAT_MSG_LOOT", p("You receive loot: [Cloak].", "Kaelis-Horizon"))
  check("a feed line counts as unread but stays quiet", S.Get("loot").unread == 1 and S.TierOf("loot") == "quiet", S.Get("loot").unread)

  local registered = {}
  E.Enable()  -- makes sure the event frame exists (an earlier section may have made it)
  local fr = E._frame()
  local savedRegister, savedUnregister = fr.RegisterEvent, fr.UnregisterAllEvents
  fr.RegisterEvent = function(_, e) registered[e] = true end
  fr.UnregisterAllEvents = function() registered = {} end
  E.Disable()
  E.Enable()
  check("feed events are registered", registered.CHAT_MSG_LOOT and registered.CHAT_MSG_ACHIEVEMENT and registered.CHAT_MSG_SYSTEM, "missing")
  check("battle.net alerts register with the capability", registered.BN_INLINE_TOAST_ALERT == true, "missing")
  E.Disable()
  HorizonSuite.Platform.caps.bnetWhispers = false
  E.Enable()
  check("no battle.net alerts without the capability", registered.BN_INLINE_TOAST_ALERT == nil and registered.CHAT_MSG_LOOT == true, "registered")
  E.Disable()
  HorizonSuite.Platform.caps.bnetWhispers = true
  fr.RegisterEvent, fr.UnregisterAllEvents = savedRegister, savedUnregister
  S.Reset()
`, 'feeds-events');
```

`Events` builds its frame once and reuses it, so this test swaps the recording methods onto that frame through a test handle, `Events._frame()` (Step 4), and puts the originals back afterwards.

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: failures starting at `feeds are known kinds`.

- [ ] **Step 3: Store**

In `modules/Echo/EchoStore.lua`:
- Add `loot = "quiet", progress = "quiet", system = "quiet",` to `Store.DEFAULT_TIERS`.
- Add these entries to `Store.EVENT_KIND`:

```lua
    CHAT_MSG_LOOT                  = "loot",
    CHAT_MSG_MONEY                 = "loot",
    CHAT_MSG_CURRENCY              = "loot",
    CHAT_MSG_COMBAT_FACTION_CHANGE = "progress",
    CHAT_MSG_COMBAT_XP_GAIN        = "progress",
    CHAT_MSG_SKILL                 = "progress",
    CHAT_MSG_ACHIEVEMENT           = "progress",
    CHAT_MSG_GUILD_ACHIEVEMENT     = "progress",
    CHAT_MSG_SYSTEM                = "system",
    BN_INLINE_TOAST_ALERT          = "system",
```

- Directly after `Store.PERSISTED_KINDS = …`, add:

```lua
-- Read-only feeds of non-conversation lines (plan 4). Routed by event type, quiet by
-- default, never persisted or restored.
Store.FEED_KINDS = { loot = true, progress = true, system = true }
```

- [ ] **Step 4: Events**

In `modules/Echo/EchoEvents.lua`, directly above `--- Build a message record from a CHAT_MSG_* payload.`, add:

```lua
-- Achievement lines arrive as "%s has earned…" and are filled with the achiever's link.
local ACHIEVEMENT_EVENTS = { CHAT_MSG_ACHIEVEMENT = true, CHAT_MSG_GUILD_ACHIEVEMENT = true }

-- Only the Battle.net friend alert needs the capability to be registered.
local BNET_EVENTS = {
    CHAT_MSG_BN_WHISPER = true, CHAT_MSG_BN_WHISPER_INFORM = true, BN_INLINE_TOAST_ALERT = true,
}

-- A feed line: routed by event type, never outgoing, never urgent, no class.
local function BuildFeedRecord(event, kind, text, sender)
    local textSecret = IsSecret(text)
    if event == "BN_INLINE_TOAST_ALERT" then
        -- arg1 names the alert ("FRIEND_ONLINE"), arg2 is the friend's |K name. Build the
        -- line from Blizzard's own string, as Blizzard's chat does; feeds are never saved.
        if textSecret or type(text) ~= "string" or IsSecret(sender) then return nil, "ignored" end
        local template = _G["BN_INLINE_TOAST_" .. text]
        if type(template) ~= "string" then return nil, "ignored" end
        if template:find("%s", 1, true) then
            if type(sender) ~= "string" then return nil, "ignored" end
            local ok, formatted = pcall(string.format, template, sender)
            if not ok then return nil, "ignored" end
            template = formatted
        end
        text, textSecret = template, false
    elseif ACHIEVEMENT_EVENTS[event] and not textSecret and type(text) == "string"
        and text:find("%s", 1, true) and not IsSecret(sender) and type(sender) == "string" and sender ~= "" then
        local short = sender:match("^([^-]+)") or sender
        local ok, formatted = pcall(string.format, text, "|Hplayer:" .. sender .. "|h[" .. short .. "]|h")
        if ok then text = formatted end
    end
    return {
        convKey  = kind,
        text     = text,
        secret   = textSecret,
        outgoing = false,
        urgent   = false,
        feed     = true,
        chatType = (event:gsub("^CHAT_MSG_", "")),
        time     = Store.Now(),
    }
end
```

At the top of `Events.BuildRecord`, directly after `if not kind then return nil, "ignored" end`, add:

```lua
    if Store.FEED_KINDS[kind] then return BuildFeedRecord(event, kind, text, sender) end
```

In `Events.Dispatch`, replace:

```lua
    if event == "CHAT_MSG_SYSTEM" then
        Events.OnSystemMessage((...))
        return
    end
```

with:

```lua
    -- A system line may fail a pending whisper; it is then filed in the System feed too.
    if event == "CHAT_MSG_SYSTEM" then Events.OnSystemMessage((...)) end
```

In `Events.Enable`, replace the registration loop and the separate `CHAT_MSG_SYSTEM` line with:

```lua
    local hasBnet = addon.Platform and addon.Platform.Has("bnetWhispers")
    for event in pairs(Store.EVENT_KIND) do
        if not BNET_EVENTS[event] or hasBnet then frame:RegisterEvent(event) end
    end
```

`CHAT_MSG_SYSTEM` is now in `EVENT_KIND`, so the loop registers it.

Directly after `Events.Disable`, add a test handle:

```lua
-- Test and debug handle.
function Events._frame()
    return frame
end
```

- [ ] **Step 5: Run the tests and parse-check**

Expected: `554 passed, 0 failed`. Earlier sections that assert `CHAT_MSG_SYSTEM` behaviour, such as "other system messages are ignored", still pass. A test that asserted a system line creates **no** conversation needs updating to the new behaviour: explain the change in the report. Both files parse.

- [ ] **Step 6: Commit**

```bash
git add modules/Echo/EchoStore.lua modules/Echo/EchoEvents.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): file loot, progress and system lines into feeds" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: View helpers for feeds

**Files:**
- Modify: `modules/Echo/EchoView.lua` (append at the end; extend `View.CHAT_TYPE`)
- Modify: `locales/horizon/enUS.lua` (append)
- Test: `tools/test_echo_logic.js` (new section)

**Interfaces:**
- Produces:
  - `View.FEED_ICONS`.
  - `View.IsFeed(kind) -> boolean`.
  - `View.TileSpec(conv)`, which for feeds returns `{ glyph = true, icon = <path>, letter = "", r, g, b, badge, count }`.
  - `View.LineColor(conv, msg) -> r, g, b`.
  - `View.FeedTime(t) -> "HH:MM" | ""`.
  - Feed display names through `ECHO_KIND_LOOT`, `ECHO_KIND_PROGRESS` and `ECHO_KIND_SYSTEM`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- View: feed helpers ------------------------------------------------------------------
run(`
  local S, V = HorizonSuite.Echo.Store, HorizonSuite.Echo.View
  S.Reset()
  check("feeds are feeds", V.IsFeed("loot") and V.IsFeed("progress") and V.IsFeed("system"), "?")
  check("conversations are not feeds", not V.IsFeed("party") and not V.IsFeed("whisper") and not V.IsFeed(nil), "?")

  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  local spec = V.TileSpec(S.Get("loot"))
  check("a feed tile shows an icon, not a letter", spec.glyph == true and spec.icon == V.FEED_ICONS.loot and spec.letter == "", tostring(spec.icon))
  check("a quiet feed shows no badge", spec.badge == nil, spec.badge)
  check("a feed is named by its kind", V.DisplayName(S.Get("loot")) == "ECHO_KIND_LOOT", V.DisplayName(S.Get("loot")))
  check("each feed has its own icon", V.FEED_ICONS.loot ~= V.FEED_ICONS.progress and V.FEED_ICONS.progress ~= V.FEED_ICONS.system, "?")

  local savedInfo = ChatTypeInfo
  ChatTypeInfo = { LOOT = { r = 0, g = 0.67, b = 0 }, SYSTEM = { r = 1, g = 1, b = 0 }, PARTY = { r = 0.67, g = 0.67, b = 1 } }
  local r, g, b = V.LineColor(S.Get("loot"), { chatType = "LOOT" })
  check("a feed line takes its own line type's colour", r == 0 and g == 0.67, r)
  r = V.LineColor(S.Get("loot"), { chatType = "NOT_A_TYPE" })
  check("an unknown line type falls back to the feed's colour", r ~= nil, "nil")
  r, g, b = V.LineColor({ kind = "party" }, {})
  check("a conversation line uses its conversation's colour", r == 0.67 and b == 1, r)
  ChatTypeInfo = savedInfo

  local savedDate = date
  date = function(fmt, t) return fmt == "%H:%M" and ("12:" .. string.format("%02d", t % 60)) or "?" end
  check("feed time is hours and minutes", V.FeedTime(125) == "12:05", V.FeedTime(125))
  check("no time, no stamp", V.FeedTime(nil) == "", V.FeedTime(nil))
  date = nil
  check("no date function, no stamp", V.FeedTime(125) == "", V.FeedTime(125))
  date = savedDate
  S.Reset()
`, 'view-feeds');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: `view-feeds: … attempt to call a nil value (field 'IsFeed')`.

- [ ] **Step 3: Implement**

In `modules/Echo/EchoView.lua`, add to `View.CHAT_TYPE`: `loot = "LOOT", progress = "ACHIEVEMENT", system = "SYSTEM",`.

In `View.TileSpec`, directly after `local spec = { count = conv.unread or 0 }`, add:

```lua
    if View.FEED_ICONS[kind] then
        spec.glyph = true
        spec.icon = View.FEED_ICONS[kind]
        spec.letter = ""
        spec.r, spec.g, spec.b = View.ChatColor(kind)
        if spec.count > 0 then
            local tier = Echo.Store.TierOf(conv.key)
            if tier == "loud" then spec.badge = "dot" elseif tier == "count" then spec.badge = "count" end
        end
        return spec
    end
```

`View.FEED_ICONS` is defined at the end of the file but read at call time, so the order doesn't matter.

Append at the end of the file:

```lua
-- ---------------------------------------------------------------------------
-- Feeds (plan 4)
-- ---------------------------------------------------------------------------

View.FEED_ICONS = {
    loot     = "Interface\\Icons\\INV_Misc_Bag_10",
    progress = "Interface\\Icons\\Achievement_General",
    system   = "Interface\\Icons\\INV_Misc_Gear_01",
}

--- True for the read-only feeds (Loot, Progress, System).
-- @param kind string|nil
-- @return boolean
function View.IsFeed(kind)
    return kind ~= nil and Echo.Store.FEED_KINDS[kind] == true
end

--- Colour for one line: a feed line in its own line type's colour, else the conversation's.
-- @param conv table
-- @param msg table
-- @return number r, number g, number b
function View.LineColor(conv, msg)
    local info = msg and msg.chatType and ChatTypeInfo and ChatTypeInfo[msg.chatType]
    if info and info.r then return info.r, info.g, info.b end
    return View.ChatColor(conv.kind)
end

--- A feed line's timestamp, "HH:MM", or "" when there is no time.
-- @param t number|nil
-- @return string
function View.FeedTime(t)
    if type(t) ~= "number" or type(date) ~= "function" then return "" end
    local ok, stamp = pcall(date, "%H:%M", t)
    return (ok and type(stamp) == "string") and stamp or ""
end
```

Append to `locales/horizon/enUS.lua`:

```lua
-- Echo — feeds
L["ECHO_KIND_LOOT"]                                           = "Loot"
L["ECHO_KIND_PROGRESS"]                                       = "Progress"
L["ECHO_KIND_SYSTEM"]                                         = "System"
```

- [ ] **Step 4: Run the tests and parse-check**

Expected: `566 passed, 0 failed`. `EchoView.lua` and `enUS.lua` parse.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoView.lua locales/horizon/enUS.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): add feed icons, line colours and timestamps to the view" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: Live links

**Files:**
- Modify: `modules/Echo/EchoLinks.lua` (new `Links.Attach`)
- Test: `tools/test_echo_logic.js` (new section)

**Interfaces:**
- Produces: `Links.Attach(frame)`. It enables hyperlinks on `frame` and sets `OnHyperlinkEnter` (the tooltip), `OnHyperlinkLeave` (hides it) and `OnHyperlinkClick` (`SetItemRef`, so shift-click inserts through the game's own path, which Echo's hook already catches). A secret or non-string link is ignored.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Links: hover and click links in Echo's text -----------------------------------------
run(`
  local Links = HorizonSuite.Echo.Links
  local savedTooltip, savedItemRef = GameTooltip, SetItemRef
  local shown, hidden, ref = nil, false, nil
  GameTooltip = {
    SetOwner = function() end,
    SetHyperlink = function(_, link) if link == "bad:1" then error("no tooltip") end shown = link end,
    Show = function() end,
    Hide = function() hidden = true end,
  }
  SetItemRef = function(link, text, button) ref = { link, text, button } end
  CreateFrame = STUB_CREATE_FRAME
  local f = CreateFrame("Frame")
  f.SetHyperlinksEnabled = function(self, on) self.hyperlinks = on end
  Links.Attach(f)
  check("links are enabled on the frame", f.hyperlinks == true, tostring(f.hyperlinks))
  f.scripts.OnHyperlinkEnter(f, "item:1")
  check("hovering a link shows its tooltip", shown == "item:1", shown)
  f.scripts.OnHyperlinkLeave(f)
  check("leaving hides it", hidden == true, "?")
  check("a link with no tooltip is survived", pcall(f.scripts.OnHyperlinkEnter, f, "bad:1"), "threw")
  f.scripts.OnHyperlinkClick(f, "item:1", "[Cloak]", "LeftButton")
  check("clicking goes through the game's own link handler", ref and ref[1] == "item:1" and ref[2] == "[Cloak]" and ref[3] == "LeftButton", "?")
  ref, shown = nil, nil
  f.scripts.OnHyperlinkEnter(f, SECRET("item:2"))
  f.scripts.OnHyperlinkClick(f, SECRET("item:2"), "[x]", "LeftButton")
  check("a secret link is ignored", shown == nil and ref == nil, "used")
  SetItemRef = nil
  check("no link handler, no error", pcall(f.scripts.OnHyperlinkClick, f, "item:1", "[Cloak]", "LeftButton"), "threw")
  f.SetHyperlinksEnabled = nil
  GameTooltip, SetItemRef = savedTooltip, savedItemRef
`, 'links-live');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: `links-live: … attempt to call a nil value (field 'Attach')`.

- [ ] **Step 3: Implement**

Append to `modules/Echo/EchoLinks.lua`:

```lua
local function ShowTooltip(frame, link)
    if Echo.IsSecret(link) or type(link) ~= "string" or not GameTooltip then return end
    GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
    if pcall(GameTooltip.SetHyperlink, GameTooltip, link) then GameTooltip:Show() end
end

--- Make the links in a frame's text live: hover for the tooltip, click through the game's
-- own handler (so shift-click links and ctrl-click previews work as in Blizzard's chat).
-- @param frame Frame
function Links.Attach(frame)
    if frame.SetHyperlinksEnabled then frame:SetHyperlinksEnabled(true) end
    frame:SetScript("OnHyperlinkEnter", function(self, link) ShowTooltip(self, link) end)
    frame:SetScript("OnHyperlinkLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    frame:SetScript("OnHyperlinkClick", function(self, link, text, button)
        if Echo.IsSecret(link) or type(link) ~= "string" or type(SetItemRef) ~= "function" then return end
        pcall(SetItemRef, link, text, button, self)
    end)
end
```

- [ ] **Step 4: Run the tests and parse-check**

Expected: `573 passed, 0 failed`. `EchoLinks.lua` parses.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoLinks.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): make links in Echo's text hover and click like Blizzard's chat" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Icon tiles everywhere; feeds in the stack

**Files:**
- Modify: `modules/Echo/EchoTiles.lua` (`Echo.PaintTileFace`; tile icon; toast icon)
- Modify: `modules/Echo/EchoStack.lua` (card icon; feeds read-only; line colours; live links)
- Modify: `modules/Echo/EchoCard.lua` (row tile icon only; feed rendering is Task 5)
- Test: `tools/test_echo_logic.js` (new section)

**Interfaces:**
- Produces: `Echo.PaintTileFace(icon, letter, spec)`, which shows `spec.icon` cropped on `icon` (a Texture) and clears `letter`, or else hides `icon` and sets the letter. Tiles in the column and the card's row gain `b.icon`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Icon tiles and read-only feeds in the stack -------------------------------------------
run(`
  local S, T, K, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Tiles, HorizonSuite.Echo.Stack, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  T.Enable()
  K.Enable()
  C.Enable()
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT" })
  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon", class = "DRUID" })

  local lootTile = T.TileFor("loot")
  check("a feed tile shows its icon", lootTile and lootTile.icon.shown and lootTile.letter.text == "", lootTile and lootTile.letter.text)
  local brisaTile = T.TileFor("w:Brisa-Horizon")
  check("a whisper tile shows its letter, no icon", brisaTile.icon.shown == false and brisaTile.letter.text == "B", brisaTile.letter.text)

  K.Open("loot")
  local f = K._frames()
  check("the stack shows a feed card", f.card.name.text == "ECHO_KIND_LOOT", f.card.name.text)
  check("a feed card has no reply box", f.edit.shown == false, tostring(f.edit.shown))
  check("the feed card's line is shown", f.card.lines[1].text == "You receive loot: [Cloak].", f.card.lines[1].text)
  K.Open("w:Brisa-Horizon")
  check("a conversation card keeps its reply box", f.edit.shown == true, tostring(f.edit.shown))
  check("the stack card's links are live", f.card.scripts.OnHyperlinkClick ~= nil, "not attached")
  K.Hide()

  C.Open("w:Brisa-Horizon")
  local cf = C._frames()
  local lootRow
  for _, b in ipairs(cf.rowTiles) do if b.convKey == "loot" then lootRow = b end end
  check("the card's row shows the feed's icon", lootRow and lootRow.icon.shown and lootRow.letter.text == "", "?")
  C.Hide()
  C.Disable()
  K.Disable()
  T.Disable()
  S.Reset()
`, 'icons-stack-feeds');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: failures, starting with `a feed tile shows its icon` (the tile has no `.icon` yet).

- [ ] **Step 3: `EchoTiles.lua`**

Directly after `Echo.NewText`, add:

```lua
--- Draw a tile spec's face: its icon, cropped, when it has one; otherwise its letter.
-- @param icon Texture  shown for an icon, hidden otherwise
-- @param letter FontString
-- @param spec table  View.TileSpec
function Echo.PaintTileFace(icon, letter, spec)
    if spec.icon then
        icon:SetTexture(spec.icon)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:Show()
        letter:SetText("")
    else
        icon:Hide()
        letter:SetText(spec.letter)
    end
end
```

In `CreateTile`, directly after the `b.letter` lines, add:

```lua
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 3, -3)
    b.icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -3, 3)
    b.icon:Hide()
```

In `PaintTile`, replace `b.letter:SetText(spec.letter)` with `Echo.PaintTileFace(b.icon, b.letter, spec)`. In `Tiles.Refresh`'s overflow block, add `overflowTile.icon:Hide()` next to `overflowTile.dot:Hide()`.

In `Tiles.ShowToast`, replace the block that starts `if spec.glyph then` and ends `entry.letter:SetText(spec.letter)` with:

```lua
    if spec.icon then
        entry.icon:SetTexture(spec.icon)
        entry.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        entry.letter:SetText("")
    elseif spec.glyph then
        local bg = View.GLYPH_BG
        entry.icon:SetColorTexture(bg[1], bg[2], bg[3], 1)
        entry.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
        entry.letter:SetText(spec.letter)
    else
        entry.icon:SetColorTexture(spec.r, spec.g, spec.b, 1)
        entry.letter:SetTextColor(0.05, 0.05, 0.07, 1)
        entry.letter:SetText(spec.letter)
    end
```

- [ ] **Step 4: `EchoStack.lua`**

1. In `Create`, after the card is made mouse-enabled (`card:EnableMouse(true)`), add `if Echo.Links then Echo.Links.Attach(card) end`.
2. In `Stack.Render`, replace the block that starts `if spec.glyph then` and ends `card.letter:SetText(spec.letter)` with:

```lua
    if spec.icon then
        card.tile:SetTexture(spec.icon)
        card.tile:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        card.letter:SetText("")
    elseif spec.glyph then
        local bg = View.GLYPH_BG
        card.tile:SetColorTexture(bg[1], bg[2], bg[3], 1)
        card.letter:SetTextColor(spec.r, spec.g, spec.b, 1)
        card.letter:SetText(spec.letter)
    else
        card.tile:SetColorTexture(spec.r, spec.g, spec.b, 1)
        card.letter:SetTextColor(0.05, 0.05, 0.07, 1)
        card.letter:SetText(spec.letter)
    end
```

3. In the message-line loop, change the incoming-line colour from `fs:SetTextColor(r, g, b, 1)` to use the line's own colour: `local lr, lg, lb = View.LineColor(conv, msg)` then `fs:SetTextColor(lr, lg, lb, 1)`. The local `r, g, b` above the loop can go if nothing else uses it.
4. After `edit.placeholder:SetShown(...)`, add:

```lua
    -- Feeds are read-only: no reply box.
    edit:SetShown(not View.IsFeed(conv.kind))
```

- [ ] **Step 5: `EchoCard.lua` (row tiles only)**

In `Create`'s row-tile loop, directly after the `b.letter` lines, add the same four `b.icon` lines as in the Tiles step. In the card's local `PaintTile(b, spec)`, replace `b.letter:SetText(spec.letter)` with `Echo.PaintTileFace(b.icon, b.letter, spec)`.

- [ ] **Step 6: Run the tests and parse-check**

Expected: `581 passed, 0 failed`. `EchoTiles.lua`, `EchoStack.lua` and `EchoCard.lua` all parse.

- [ ] **Step 7: Commit**

```bash
git add modules/Echo/EchoTiles.lua modules/Echo/EchoStack.lua modules/Echo/EchoCard.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): show feed icons on tiles and feeds read-only in the stack" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Feed lines on the card, and live links in bubbles

**Files:**
- Modify: `modules/Echo/EchoCard.lua` (`Bubble`, a new `SizeFeedLine`, `RenderMessages`, `Card.Render`)
- Test: `tools/test_echo_logic.js` (new section)

**Interfaces:**
- Card constants: `Card.FEED_TIME_WIDTH` 40 and `Card.FEED_GAP` 2.
- Feed cards render every message as a full-width line: a timestamp at the left, then the text, in `View.LineColor`, with a transparent backdrop, no labels and no status line. The reply box and send button are hidden for feeds.
- Bubbles get live links through `Echo.Links.Attach`.

- [ ] **Step 1: Write the failing tests**

Insert before `// --- Summary`:

```js
// --- Card: feed lines and live links ---------------------------------------------------------
run(`
  local S, C = HorizonSuite.Echo.Store, HorizonSuite.Echo.Card
  S.Reset()
  CreateFrame = STUB_CREATE_FRAME
  C.Enable()
  local f = C._frames()
  local savedDate = date
  date = function() return "12:04" end
  S.Add({ convKey = "loot", text = "You receive loot: [Cloak].", feed = true, chatType = "LOOT", time = 100 })
  S.Add({ convKey = "loot", text = SECRET("You receive loot: [Hidden]."), secret = true, feed = true, chatType = "LOOT", time = 101 })
  C.Open("loot")
  check("a feed card is read-only", f.edit.shown == false and f.send.shown == false, tostring(f.edit.shown))
  local newest, older = f.bubbles[1], f.bubbles[2]
  check("the newest feed line is at the bottom", rawequal(newest.text.text, S.Get("loot").messages[2].text), "?")
  check("a feed line carries its time", older.time and older.time.shown and older.time.text == "12:04", older.time and older.time.text)
  check("a feed line spans the card", older.points[1][1] == "BOTTOMLEFT", older.points[1][1])
  check("no status line on a feed", f.status.shown == false, tostring(f.status.shown))
  check("a feed line's links are live", older.scripts.OnHyperlinkClick ~= nil, "not attached")

  S.Add({ convKey = "w:Brisa-Horizon", text = "hi", sender = "Brisa-Horizon" })
  C.Show("w:Brisa-Horizon")
  check("a conversation card has its reply box", f.edit.shown == true and f.send.shown == true, tostring(f.edit.shown))
  check("a bubble after a feed line hides its time", f.bubbles[1].time == nil or f.bubbles[1].time.shown == false, "shown")
  date = savedDate
  C.Disable()
  S.Reset()
`, 'card-feeds');
```

- [ ] **Step 2: Run the tests and confirm they fail**

Expected: failures, starting with `a feed card is read-only`.

- [ ] **Step 3: Implement in `modules/Echo/EchoCard.lua`**

1. Add constants after `Card.LINE_HEIGHT = 14`:

```lua
Card.FEED_TIME_WIDTH = 40
Card.FEED_GAP = 2
```

2. In `Bubble(i)`, after `b.text:SetNonSpaceWrap(true)`, add:

```lua
    b.time = Echo.NewText(b, 10, "")
    b.time:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -3)
    b.time:SetTextColor(0.55, 0.60, 0.75, 1)
    b.time:Hide()
    b:EnableMouse(true)
    if Echo.Links then Echo.Links.Attach(b) end
```

3. At the start of `SizeBubble`, before `local inner = …`, reset the bubble layout (a feed line may have used this frame last):

```lua
    b.time:Hide()
    b.text:ClearAllPoints()
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.BUBBLE_PAD, -Card.BUBBLE_PAD)
```

4. Directly after `SizeBubble`, add:

```lua
-- Lay out one feed line across the card: time, then text. Readable text is measured; a
-- secret gets a fixed number of lines. Returns its height.
local function SizeFeedLine(b, msg, secret)
    local width = Card.WIDTH - Card.PAD * 2
    b.time:SetText(Echo.View.FeedTime(msg.time))
    b.time:Show()
    b.text:ClearAllPoints()
    b.text:SetPoint("TOPLEFT", b, "TOPLEFT", Card.FEED_TIME_WIDTH, -3)
    b.text:SetWidth(width - Card.FEED_TIME_WIDTH - 4)
    b.text:SetMaxLines(secret and Card.SECRET_LINES or 0)
    b.text:SetText(msg.text)
    local height
    if secret then
        height = Card.SECRET_LINES * Card.LINE_HEIGHT
    else
        local h = b.text:GetStringHeight()
        if Echo.IsSecret(h) or type(h) ~= "number" or h <= 0 then h = Card.LINE_HEIGHT end
        height = h
    end
    b:SetSize(width, height + 6)
    return height + 6
end
```

5. In `RenderMessages`, directly after `statusLine:Hide()`, add a feed branch that lays out lines and returns:

```lua
    if View.IsFeed(conv.kind) then
        for i = #messages - offset, 1, -1 do
            if y > Card.AREA_HEIGHT then break end
            local msg = messages[i]
            used = used + 1
            local line = Bubble(used)
            local height = SizeFeedLine(line, msg, msg.secret or Echo.IsSecret(msg.text))
            line:ClearAllPoints()
            line:SetPoint("BOTTOMLEFT", area, "BOTTOMLEFT", 0, y)
            line:SetBackdropColor(0, 0, 0, 0)
            line:SetBackdropBorderColor(0, 0, 0, 0)
            local lr, lg, lb = View.LineColor(conv, msg)
            line.text:SetTextColor(lr, lg, lb, 1)
            line:Show()
            y = y + height + Card.FEED_GAP
        end
        for j = used + 1, #bubbles do bubbles[j]:Hide() end
        for j = 1, #labels do labels[j]:Hide() end
        return
    end
```

6. In `Card.Render`, after `edit.placeholder:SetShown(…)`, add:

```lua
    -- Feeds are read-only: no reply box or send button.
    local feed = View.IsFeed(conv.kind)
    edit:SetShown(not feed)
    send:SetShown(not feed)
```

- [ ] **Step 4: Run the tests and parse-check**

Expected: `589 passed, 0 failed`. `EchoCard.lua` parses.

- [ ] **Step 5: Commit**

```bash
git add modules/Echo/EchoCard.lua tools/test_echo_logic.js
```

```bash
git commit -m "feat(echo): show feeds as timestamped lines and make bubble links live" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Lint globals and the checklist

**Files:**
- Modify: `.luacheckrc` (`read_globals`)
- Modify: this plan (the Task 7 checklist is final as written)

- [ ] **Step 1:** Add each of these that isn't already listed: `SetItemRef`, `BN_INLINE_TOAST_FRIEND_ONLINE` (or a `BN_INLINE_TOAST_` pattern entry, if the file uses patterns). `GameTooltip`, `ChatTypeInfo` and `date` are already there. Parse-check `.luacheckrc`.

- [ ] **Step 2: Commit**

```bash
git add .luacheckrc
```

```bash
git commit -m "chore(echo): declare the feed and link globals for luacheck" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: In-game check (on the Windows PC, a human step)

- [ ] **Step 1:** Push `feature/echo`. A `/reload` is enough, because no TOC lines change.

- [ ] **Step 2: Checklist (director, in game)**

1. Loot something, pick up gold and earn currency: a **Loot** tile with a bag icon appears, with no badge (it's quiet). Hover or click it: timestamped lines in Blizzard's loot colours, and no reply box.
2. Gain reputation or experience, or watch a guildmate earn an achievement: a **Progress** tile with a star appears. The achievement line names the player, and clicking the name opens their menu.
3. "You feel rested", a system message or a Battle.net friend logging in: a **System** tile with a cog appears. Whisper an offline name: the whisper shows "Not delivered", and the System feed also has the "No player named…" line.
4. Hover an item link in a loot line, in a whisper bubble and in the stack: the item tooltip shows. Click it: it behaves like Blizzard's chat. Shift-click it with a reply box focused: the link goes into Echo's box.
5. `⋯` → Notifications → Count on Loot: its tile shows a number. Muted: nothing.
6. `/reload`: the feed tiles are gone until new lines arrive. Your whisper tiles come back as before.
7. In a dungeon, loot during a boss fight (if the game hides the line): the Loot feed still gets a line, and nothing errors.
8. Repeat on Forever. Battle.net friend alerts only appear where the client has Battle.net.
