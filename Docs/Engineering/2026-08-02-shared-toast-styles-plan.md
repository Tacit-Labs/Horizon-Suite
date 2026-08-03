# Shared Augment Toast Styles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give loot and alerts the same three chrome skins (Compact / Framed / Accent) and shared base slide/fade motion, with separate pickers and native content layouts.

**Architecture:** New `AugmentToastStyles` module owns style IDs, `ToastMotion` constants/`Ease`, and `ApplyChrome`. Loot and Alerts keep separate pools/text; both call into the shared module. One-shot migration remaps `alertsStyle` → `alertsToastStyle`.

**Tech Stack:** WoW retail Lua 5.1 addon (Interface 120007), Horizon Suite Augment module, Axis options, `RegisterMigration` runner.

**Spec:** `Docs/Engineering/2026-08-02-shared-toast-styles-design.md`

## Global Constraints

- Lua 5.1 only (no `goto`, `//`, native bitwise, `require`)
- Namespace: `local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite` (match file’s existing header pattern)
- Style IDs: `compact` | `framed` | `accent` only (product names Compact / Framed / Accent)
- Defaults: loot `augmentToastStyle = "framed"`; alerts `alertsToastStyle = "framed"`
- Content stays native: loot one line (`text`/`shadow`); alerts title + body
- Shared base motion only; loot epic/legend pop/shine stay local
- One-shot migration via `addon.RegisterMigration` + `db._migrations[id]` (never gate on data conditions alone)
- Do not merge pools or options pages; do not touch Presence toasts

---

## File map

| File | Responsibility |
|------|----------------|
| Create: `modules/Augment/ToastStyles/AugmentToastStyles.lua` | Style normalize, `ToastMotion`, `ApplyChrome` |
| Create: `core/migrations/20260802_augment_toast_styles.lua` | Migrate `alertsStyle` → `alertsToastStyle` |
| Modify: `HorizonSuite.toc` (+ Beta toc if present) | Load ToastStyles before loot/alerts cores; register migration |
| Modify: `options/modules/defaults/augment/OptionsDefaultsAugmentLootFrame.lua` | `augmentToastStyle` default |
| Modify: `options/modules/defaults/augment/OptionsDefaultsAugmentAlerts.lua` | `alertsToastStyle` default; drop/stop using `alertsStyle` as live default |
| Modify: `modules/Augment/LootFrame/AugmentState.lua` | DB key, getter, alias motion from shared |
| Modify: `modules/Augment/Alerts/AugmentAlertsState.lua` | DB keys, getter; remove live `alertsStyle` writes |
| Modify: `modules/Augment/Alerts/AugmentAlertsCore.lua` | Call `ApplyChrome` + shared motion |
| Modify: `modules/Augment/LootFrame/AugmentCore.lua` | BackdropTemplate where needed; call `ApplyChrome`; shared Ease/motion |
| Modify: `options/modules/OptionsAugment.lua` | Style dropdown |
| Modify: `options/modules/OptionsAugmentAlerts.lua` | Replace Horizon/Minimalist with shared trio |
| Modify: `locales/horizon/enUS.lua` + restructure | Shared style labels/descs |
| Modify: `README.md` | One capability line |

---

### Task 1: Shared ToastStyles module (motion + ApplyChrome)

**Files:**
- Create: `modules/Augment/ToastStyles/AugmentToastStyles.lua`
- Modify: `HorizonSuite.toc` — insert `modules/Augment/ToastStyles/AugmentToastStyles.lua` **before** `modules/Augment/LootFrame/AugmentState.lua`
- Modify: `HorizonSuiteBeta.toc` if it lists Augment files the same way

**Interfaces:**
- Consumes: `addon.Augment` table (must exist; create `addon.Augment = addon.Augment or {}` if loot State usually creates it — check `AugmentState.lua` load order; ToastStyles loads first so initialize `addon.Augment`)
- Produces:
  - `addon.Augment.ToastStyles.Normalize(style) → "compact"|"framed"|"accent"`
  - `addon.Augment.ToastMotion` table: `ENTRANCE_DUR=0.28`, `EXIT_DUR=0.45`, `SLIDE_DIST=18`, `EXIT_DRIFT=10`, `NUDGE_SPEED=10`, `EDGE=8`, `Ease(t, mode)`
  - `addon.Augment.ToastStyles.ApplyChrome(entry, style, colors, layout)` — see signature below

**ApplyChrome contract:**

```lua
--- Apply shared toast chrome. Does not set text strings.
--- @param entry table Must provide: frame; icon; iconBg (optional for framed);
---   For textMode "dual": title, body; optional iconDark
---   For textMode "single": text; optional shadow, iconBgAnchor (preferred icon parent)
--- @param style string|nil Raw DB value; normalized internally
--- @param colors table { r, g, b [, br, bg, bb] } — text/border tint; compact/accent icon fill prefers br,bg,bb when set
--- @param layout table {
---   textMode = "single"|"dual",
---   iconSide = "left"|"right",
---   iconSize = number,   -- unscaled px
---   iconGap = number,    -- unscaled px
---   iconBgPad = number,  -- unscaled px (compact/accent square pad)
---   scale = function(v) return number end,  -- UI scale helper
--- }
--- @return nil
function ApplyChrome(entry, style, colors, layout) end
```

Chrome behaviour (match today’s visuals):

| Style | Frame backdrop | Icon treatment | Text anchors |
|-------|----------------|----------------|--------------|
| `framed` | Tooltip bg + border; border color `(r,g,b,0.7)`; bg `(0,0,0,0.75)` | Icon on frame edge (`EDGE`); hide accent `iconBg`/`iconDark` if present | Dual: title/body vs icon + opposite frame edge. Single: text/shadow vs icon/`iconBgAnchor` |
| `accent` | `SetBackdrop(nil)` | Coloured square `iconBg` (`r,g,b` or border RGB @ 0.85); optional `iconDark`; icon centered on square | Dual: title/body vs `iconBg`. Single: text vs `iconBg`/`iconBgAnchor` |
| `compact` | `SetBackdrop(nil)` | Chip: `iconBg` size `iconSize+pad*2`, color border RGB @ ~0.8; icon centered (loot stack layers left alone — caller may still fan `iconBg2/3`) | Dual: title/body vs chip. Single: existing loot text layout vs `iconBgAnchor` |

- [ ] **Step 1: Create `AugmentToastStyles.lua` with Normalize + ToastMotion + Ease**

```lua
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Augment = addon.Augment or {}
local Y = addon.Augment
Y.ToastStyles = Y.ToastStyles or {}
local TS = Y.ToastStyles

Y.ToastMotion = Y.ToastMotion or {}
local M = Y.ToastMotion
M.ENTRANCE_DUR = 0.28
M.EXIT_DUR     = 0.45
M.SLIDE_DIST   = 18
M.NUDGE_SPEED  = 10
M.EDGE         = 8

--- Quadratic ease. mode: "in" | "inOut" | nil (ease-out).
function M.Ease(t, mode)
    if mode == "in" then return t * t end
    if mode == "inOut" then
        if t < 0.5 then return 2 * t * t end
        return 1 - ((-2 * t + 2) * (-2 * t + 2)) / 2
    end
    return 1 - (1 - t) * (1 - t)
end

local LEGACY = { horizon = "framed", minimalist = "accent" }

function TS.Normalize(style)
    if style == "compact" or style == "framed" or style == "accent" then return style end
    if LEGACY[style] then return LEGACY[style] end
    return "framed"
end
```

- [ ] **Step 2: Implement `TS.ApplyChrome` covering framed / accent / compact for both `textMode` values**

Implement by porting logic from `AugmentAlertsCore.lua` `ApplyEntryStyle` (framed←horizon, accent←minimalist) and loot chip layout from `ApplyToastIconLayout` + iconBg colouring. Guard missing optional regions with `if entry.iconDark then`. For `SetBackdrop`, only call if `entry.frame.SetBackdrop` exists (BackdropTemplate).

- [ ] **Step 3: Wire TOC load order**

In `HorizonSuite.toc`, add before LootFrame State:

```toc
modules/Augment/ToastStyles/AugmentToastStyles.lua
modules/Augment/LootFrame/AugmentState.lua
```

Mirror in Beta toc if applicable.

- [ ] **Step 4: Smoke-check load**

Run: open game or `/reload` with Augment enabled — no load errors mentioning `AugmentToastStyles`.  
Expected: addon loads; `HorizonSuite.Augment.ToastMotion.ENTRANCE_DUR == 0.28` in a debug scratch if available.

- [ ] **Step 5: Commit**

```bash
git add modules/Augment/ToastStyles/AugmentToastStyles.lua HorizonSuite.toc HorizonSuiteBeta.toc
git commit -m "feat(augment): add shared ToastStyles chrome and motion module"
```

---

### Task 2: Defaults, DB keys, migration

**Files:**
- Modify: `options/modules/defaults/augment/OptionsDefaultsAugmentLootFrame.lua`
- Modify: `options/modules/defaults/augment/OptionsDefaultsAugmentAlerts.lua`
- Modify: `modules/Augment/LootFrame/AugmentState.lua`
- Modify: `modules/Augment/Alerts/AugmentAlertsState.lua`
- Create: `core/migrations/20260802_augment_toast_styles.lua`
- Modify: `HorizonSuite.toc` — add migration after existing migration entries

**Interfaces:**
- Consumes: `TS.Normalize`, migration runner
- Produces: `Y.GetToastStyle()`, `A.GetToastStyle()`, defaults, one-shot migration `id = "20260802"`

- [ ] **Step 1: Defaults**

Loot defaults file:

```lua
D.augmentToastStyle = "framed"
```

Alerts defaults file:

```lua
D.alertsToastStyle = "framed"
-- Keep D.alertsStyle only if needed for migration read of unset profiles; do not use as live default going forward.
```

- [ ] **Step 2: DB_KEYS + getters**

In `AugmentState.lua` (loot):

```lua
Y.DB_KEYS.augmentToastStyle = true

function Y.GetToastStyle()
    local D = addon.AUGMENT_DEFAULTS
    local raw = addon.GetDB and addon.GetDB("augmentToastStyle", D.augmentToastStyle) or D.augmentToastStyle
    local TS = Y.ToastStyles
    return (TS and TS.Normalize and TS.Normalize(raw)) or "compact"
end
```

Point `Y.ENTRANCE_DUR` / `EXIT_DUR` / `SLIDE_DIST` / `NUDGE_SPEED` at `Y.ToastMotion.*` after ToastMotion exists (assign from `Y.ToastMotion` so existing loot code keeps working).

In `AugmentAlertsState.lua`:

```lua
Y.DB_KEYS.alertsToastStyle = true
-- Keep alertsStyle key registered read-only for one release OR unregister after migration — prefer unregister from live options; migration still reads raw profile fields.

function A.GetToastStyle()
    local D = addon.AUGMENT_DEFAULTS
    local raw = A.GetDB("alertsToastStyle", D.alertsToastStyle)
    local TS = Y.ToastStyles
    return (TS and TS.Normalize and TS.Normalize(raw)) or "framed"
end
```

Alias `A.ENTRANCE_DUR` etc. from `Y.ToastMotion` in AlertsCore or State.

- [ ] **Step 3: Migration**

```lua
-- core/migrations/20260802_augment_toast_styles.lua
local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

local MAP = { horizon = "framed", minimalist = "accent" }

addon.RegisterMigration({
    id = "20260802",
    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                if prof.alertsToastStyle == nil and type(prof.alertsStyle) == "string" then
                    prof.alertsToastStyle = MAP[prof.alertsStyle] or "framed"
                end
                if prof.augmentToastStyle == nil then
                    prof.augmentToastStyle = "framed"
                end
            end
        end
    end,
})
```

Add to TOC after other migrations.

- [ ] **Step 4: Verify migration logic offline**

Mentally / via scratch: profile with `alertsStyle="minimalist"` and no `alertsToastStyle` → after migration `alertsToastStyle="accent"`; second load no-ops because `_migrations["20260802"]` set.

- [ ] **Step 5: Commit**

```bash
git add options/modules/defaults/augment/OptionsDefaultsAugmentLootFrame.lua \
  options/modules/defaults/augment/OptionsDefaultsAugmentAlerts.lua \
  modules/Augment/LootFrame/AugmentState.lua \
  modules/Augment/Alerts/AugmentAlertsState.lua \
  core/migrations/20260802_augment_toast_styles.lua HorizonSuite.toc
git commit -m "feat(augment): toast style defaults, getters, and alertsStyle migration"
```

---

### Task 3: Wire Alerts core to shared chrome + motion

**Files:**
- Modify: `modules/Augment/Alerts/AugmentAlertsCore.lua`

**Interfaces:**
- Consumes: `A.GetToastStyle()`, `Y.ToastStyles.ApplyChrome`, `Y.ToastMotion` / `M.Ease`
- Produces: Alerts toasts render Compact/Framed/Accent; no local `ApplyEntryStyle` or local Ease/motion constants

- [ ] **Step 1: Replace local motion constants**

Remove local `A.ENTRANCE_DUR` assignments (or set from ToastMotion once). Replace local `Ease` with:

```lua
local M = Y.ToastMotion
local function Ease(t, mode)
    return M.Ease(t, mode)
end
```

Use `M.ENTRANCE_DUR`, `M.EXIT_DUR`, `M.SLIDE_DIST`, `M.NUDGE_SPEED` in OnUpdate / ShowToast (keep reading via `A.*` aliases if cleaner).

- [ ] **Step 2: Replace `ApplyEntryStyle` with shared chrome**

```lua
local function ApplyEntryChrome(entry, r, g, b)
    local TS = Y.ToastStyles
    if not TS or not TS.ApplyChrome then return end
    entry.title:SetTextColor(r, g, b, 1)
    TS.ApplyChrome(entry, A.GetToastStyle(), { r = r, g = g, b = b }, {
        textMode  = "dual",
        iconSide  = (A.GetIconSide and A.GetIconSide()) or "left",
        iconSize  = A.ICON_SIZE,
        iconGap   = A.ICON_GAP,
        iconBgPad = A.ICON_BG_PAD,
        scale     = S,
    })
end
```

Replace all `ApplyEntryStyle(...)` and `alertsStyle` reads with `ApplyEntryChrome` / `A.GetToastStyle()`.

- [ ] **Step 3: In-game verify alerts**

Enable an alert kind; preview if available (`A.PreviewAlerts` / Axis). Cycle styles via temporary SetDB if options not wired yet:
- Framed = boxed (default)
- Accent = icon square
- Compact = chip, no box; title+body still two lines

Expected: no Lua errors; base slide ~0.28s.

- [ ] **Step 4: Commit**

```bash
git add modules/Augment/Alerts/AugmentAlertsCore.lua
git commit -m "feat(augment): alerts use shared toast chrome and motion"
```

---

### Task 4: Wire Loot core to shared chrome + motion

**Files:**
- Modify: `modules/Augment/LootFrame/AugmentCore.lua`

**Interfaces:**
- Consumes: `Y.GetToastStyle()`, `TS.ApplyChrome`, `Y.ToastMotion.Ease`
- Produces: Loot toasts honour Compact/Framed/Accent; epic/legend pop/shine unchanged; stack fan still loot-owned for Compact

- [ ] **Step 1: BackdropTemplate on loot toast frames**

Change create line to:

```lua
local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
```

(Edit overlay already uses BackdropTemplate; toast entries need it for Framed.)

- [ ] **Step 2: Replace local Ease with ToastMotion.Ease**

```lua
local M = Augment.ToastMotion
local function Ease(t, mode)
    return M.Ease(t, mode)
end
```

Ensure `Augment.ENTRANCE_DUR` etc. still resolve (from State aliases).

- [ ] **Step 3: Apply chrome on show / scale / icon layout**

After colours and icon textures are set in show path, call:

```lua
local style = Augment.GetToastStyle and Augment.GetToastStyle() or "compact"
local TS = Augment.ToastStyles
if TS and TS.ApplyChrome then
    TS.ApplyChrome(entry, style, {
        r = data.r, g = data.g, b = data.b,
        br = data.br, bg = data.bg, bb = data.bb,
    }, {
        textMode  = "single",
        iconSide  = Augment.GetIconSide and Augment.GetIconSide() or "left",
        iconSize  = Augment.ICON_SIZE,
        iconGap   = Augment.ICON_GAP,
        iconBgPad = Augment.BORDER_PAD,
        scale     = S,
    })
end
```

Refactor `ApplyToastIconLayout` to either call `ApplyChrome` or become a thin wrapper used only when style is compact and stack fan needs re-anchor — avoid double-layout fights. For Framed/Accent, hide stack sibling bgs (`iconBg2`/`iconBg3`) or leave fan only on Compact.

Also call chrome refresh from `ApplyScale` / `ApplyAugmentOptions` path for active entries.

- [ ] **Step 4: In-game verify loot**

`/horizon augment` preview (or existing slash):
- Compact = today’s loot chip + stack fan
- Framed = boxed toast, one text line, quality colours on border
- Accent = coloured icon square, one text line
- Epic/legend still pop/shine under all three

- [ ] **Step 5: Commit**

```bash
git add modules/Augment/LootFrame/AugmentCore.lua
git commit -m "feat(augment): loot toasts use shared Compact/Framed/Accent chrome"
```

---

### Task 5: Axis options, locales, README

**Files:**
- Modify: `options/modules/OptionsAugment.lua`
- Modify: `options/modules/OptionsAugmentAlerts.lua`
- Modify: `locales/horizon/enUS.lua`
- Run: `node tools/restructure_locales.js`
- Modify: `README.md`

**Interfaces:**
- Consumes: DB keys `augmentToastStyle` / `alertsToastStyle`, shared locale keys
- Produces: Matching Style dropdowns on both Appearance blocks

- [ ] **Step 1: enUS keys**

```lua
L["AUGMENT_TOAST_STYLE"]        = "Style"
L["AUGMENT_TOAST_STYLE_DESC"]   = "Chrome style for this toast stack. Compact, Framed, and Accent match across loot and alerts."
L["AUGMENT_TOAST_STYLE_COMPACT"] = "Compact"
L["AUGMENT_TOAST_STYLE_FRAMED"]  = "Framed"
L["AUGMENT_TOAST_STYLE_ACCENT"]  = "Accent"
```

Deprecate/stop using `AUGMENT_ALERTS_STYLE_*` Horizon/Minimalist labels in options (keys may remain unused).

- [ ] **Step 2: Loot dropdown** (after Grow, before Font)

```lua
{ type = "dropdown",
  name = L["AUGMENT_TOAST_STYLE"], desc = L["AUGMENT_TOAST_STYLE_DESC"],
  dbKey = "augmentToastStyle",
  options = {
      { L["AUGMENT_TOAST_STYLE_COMPACT"], "compact" },
      { L["AUGMENT_TOAST_STYLE_FRAMED"],  "framed"  },
      { L["AUGMENT_TOAST_STYLE_ACCENT"],  "accent"  },
  },
  get = function() return getDB("augmentToastStyle", D.augmentToastStyle) end,
  set = function(v) setDB("augmentToastStyle", v) end,
  preserveOrder = true,
},
```

- [ ] **Step 3: Alerts dropdown** — replace `alertsStyle` block with `alertsToastStyle` + same three options; `set` calls `applyAlerts()`.

- [ ] **Step 4: Restructure locales + README**

```bash
node tools/restructure_locales.js
```

README Augment bullet (extend toast layout line or add):

```markdown
- **Shared toast styles** — Compact, Framed, or Accent chrome for loot toasts and status alerts (chosen separately so both can match or differ).
```

- [ ] **Step 5: In-game options verify**

Axis → Augment Loot / Alerts: Style dropdowns match; live change updates chrome; `/reload` persists.

- [ ] **Step 6: Commit**

```bash
git add options/modules/OptionsAugment.lua options/modules/OptionsAugmentAlerts.lua \
  locales/horizon/enUS.lua locales/horizon/*.lua README.md
git commit -m "feat(augment): Axis Compact/Framed/Accent style pickers for loot and alerts"
```

---

### Task 6: End-to-end verification checklist

No code unless fixes are needed.

- [ ] **Step 1: Defaults / migration**
  - Fresh profile: loot Framed, alerts Framed
  - Old profile with `alertsStyle=minimalist`: becomes Accent after one load

- [ ] **Step 2: Parity**
  - Set both to Framed → matching box chrome + base slide timing
  - Set both to Accent → matching icon-square chrome
  - Set both to Compact → matching chip chrome
  - Loot still one line; alerts still title + body

- [ ] **Step 3: Regression**
  - Icon side / slide / grow / size / gap still work per system
  - Epic/legend loot pop + shine still work
  - Alerts kinds/colours/sounds unchanged

- [ ] **Step 4: Final commit only if fixes landed**; otherwise done.

---

## Spec coverage (self-review)

| Spec item | Task |
|-----------|------|
| Compact / Framed / Accent catalog | 1, 5 |
| Separate pickers + defaults | 2, 5 |
| Shared ApplyChrome | 1, 3, 4 |
| Shared base motion; loot flourishes local | 1, 3, 4 |
| Content native (single vs dual) | 1 (`textMode`), 3, 4 |
| Migration alertsStyle → alertsToastStyle | 2 |
| Options + locales + README | 5 |
| Verification | 3, 4, 6 |
| Out of scope (pools, Presence, two-line loot) | Not tasked |

## Placeholder / consistency check

- Style IDs and DB keys consistent across tasks: `compact|framed|accent`, `augmentToastStyle`, `alertsToastStyle`
- `ApplyChrome` / `Normalize` / `ToastMotion.Ease` names match Task 1 producers
- Migration id `20260802` consistent
