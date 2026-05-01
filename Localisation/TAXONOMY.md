# Localisation — key taxonomy

This directory is the source of truth for every user-facing string in Horizon Suite. `enUS.lua` is the canonical file; every other locale overrides it via a metatable chain (`LocaleCore.lua`).

This document defines **how keys are named**. Follow it for every new key; do not invent ad-hoc prefixes.

---

## Canonical key shape

```
<DOMAIN>[_<SUBGROUP>]_<PURPOSE>[_<MODIFIER>]
```

- **DOMAIN** — which module or surface the string belongs to. Fixed list below.
- **SUBGROUP** — optional functional grouping inside a large module (e.g. `HIGHLIGHT`, `TOMTOM`).
- **PURPOSE** — what the string says (`RESET`, `COLOUR`, `SIZE`, `ENABLE`, …).
- **MODIFIER** — optional suffix. Exactly one meaning each. See the suffix table.

Keys are `UPPER_SNAKE_CASE`. No camelCase, no leading digits, no punctuation other than `_`.

---

## Fixed domain list

| Domain     | Surface                                                       | Examples                                          |
|------------|---------------------------------------------------------------|---------------------------------------------------|
| `NAME_`    | Product / third-party brand names only (never user copy). `NAME_ADDON_*` sub-namespace holds Horizon Suite's own module brand names. | `NAME_ADDON`, `NAME_ADDON_OBJECTIVES` ("Focus"), `NAME_TOMTOM`, `NAME_PATREON` |
| `AXIS_`    | Options-window chrome (sidebar, tabs, profile panel)          | `AXIS_PROFILES`, `AXIS_MODULES`                   |
| `DASH_`    | Dashboard-wide look & feel (theme, background, class colours) | `DASH_THEME`, `DASH_BACKGROUND`, `DASH_CLASS_COLOURS_DASHBOARD` |
| `HOME_`    | Home tab inside the Dashboard (welcome, news, module cards)   | `HOME_WELCOME_TITLE`, `HOME_MOD_HEAD_SUB`         |
| `FOCUS_`   | Focus module (objective tracker)                              | `FOCUS_HIGHLIGHT_SOFT_GLOW`                       |
| `PRESENCE_`| Presence module (toasts)                                      | `PRESENCE_BOSS_EMOTE_COLOUR`, `PRESENCE_H_ZONE`   |
| `VISTA_`   | Vista module (minimap)                                        | `VISTA_BORDER_COLOUR`, `VISTA_BUTTONS_FILL_DOWN`  |
| `INSIGHT_` | Insight module (tooltips)                                     | `INSIGHT_CLASS_COLOURS`                           |
| `ESSENCE_` | Essence module (character sheet)                              | `ESSENCE_CLASS_COLOURS`                           |
| `CACHE_`   | Cache module (loot toasts)                                    | `CACHE_CLASS_COLOURS`                             |
| `UI_`      | Cross-module UI vocabulary used by 2+ domains                 | `UI_CURRENT_QUEST`, `UI_DUNGEON`, `UI_MINIMAP_PATCH_NOTES_UNREAD_HINT` |
| `TRACKER_` | Difficulty / content labels used by multiple modules          | `TRACKER_HEROIC_DUNGEONS`, `TRACKER_MYTHIC_RAIDS` |
| *(bare)*   | Unambiguous vocabulary with no module-specific meaning        | `RELOAD_UI`, `MODULES`, `PROFILES`, `HEROIC_DUNGEON`, `MYTHIC_RAID`, `COMING_SOON`, `QUEST_COMPLETE` |

### Bare-key policy

A key may be bare (no domain prefix) when the word or short phrase is **unambiguous** — its meaning is self-evident without a module context (`HEROIC_DUNGEON`, `COMING_SOON`, `RELOAD_UI`, `PROFILES`). If the word would read ambiguously in a different module's UI (e.g. `COLOUR`, `ENABLE`, `RESET`, `SETTINGS`), give it that module's prefix instead.

Rule of thumb:
- **Bare:** the string names a concrete thing in the game world or in addon-agnostic UI vocabulary (`HEROIC_DUNGEON`, `MODULES`, `DRAG_TO_RESIZE`).
- **Prefixed:** the string is a generic verb/noun that only makes sense scoped to a module (`FOCUS_RESET`, `VISTA_COLOUR`).

If in doubt, prefix it — bare keys are easy to promote later, hard to demote.

---

## Subgroup registry

Each module has a small registered list of subgroups to prevent flat "everything at root level" sprawl. New keys inside that module must use a registered subgroup or extend the list here.

| Module     | Subgroups (initial)                                                   |
|------------|-----------------------------------------------------------------------|
| FOCUS      | `HIGHLIGHT`, `TOMTOM`, `MYTHICPLUS`, `CAMPAIGN`, `FLASH`, `COLOUR`, `RESET`, `TEXT`, `SECTION` |
| PRESENCE   | `H` (help), `DEMO`, `ANIM`, `COLOUR`, `ICON`, `SHOW` (toggle labels)  |
| VISTA      | `BORDER`, `BUTTONS`, `ZOOM`, `COORDS`, `COLOUR`                       |
| INSIGHT    | `PLAYER`, `ITEM`, `NPC`, `ICON`, `COLOUR`                             |
| DASH       | `THEME`, `BACKGROUND`, `CLASS_COLOURS`, `TYPOGRAPHY`                  |
| HOME       | `WELCOME`, `NEWS`, `MOD`, `GUIDE`                                     |

Adding a new subgroup is fine — extend the table and keep examples in alphabetical order.

---

## Suffix conventions (one meaning each)

| Suffix         | Meaning                                           | Example                           |
|----------------|---------------------------------------------------|-----------------------------------|
| *(none)*       | Primary label (button, checkbox, dropdown)        | `FOCUS_RESET`                     |
| `_DESC`        | Simple body copy under the label             | `VISTA_CLASS_COLOURS_DESC`        |
| `_TIP`         | Tooltip on hover                                  | `FOCUS_SHOW_ZONE_EVENTS_TIP`      |
| `_HELP`        | Slash-command help text                           | `PRESENCE_H_ZONE_TEST` *(legacy; prefer `_HELP`)* |
| `_HINT`        | Inline placeholder / small print                  | `MODULE_RELOAD_HINT`              |
| `_LABEL`       | Short label when the key also needs a longer body | `AXIS_CUSTOM_CLASS_ICONS_LABEL`   |
| `_PLACEHOLDER` | Edit-box empty-state text                         | `DASH_SEARCH_PLACEHOLDER`         |

Do not stack modifiers: `_DESC_TIP` is wrong; pick one.

The legacy `H_<MODULE>_` prefix for help text is **retired**. All slash-command help moves to the module's `_H_` subgroup (e.g. `PRESENCE_H_ZONE`) or, for new keys, to a `_HELP` suffix.

---

## Spelling

**UK English in both keys and string values.** Standard pairs:

| American      | British       |
|---------------|---------------|
| `COLOR`       | `COLOUR`      |
| `COLORS`      | `COLOURS`     |
| `ORGANIZATION`| `ORGANISATION`|
| `ORGANIZE`    | `ORGANISE`    |
| `CUSTOMIZE`   | `CUSTOMISE`   |
| `RECOGNIZE`   | `RECOGNISE`   |
| `CENTER`      | `CENTRE` *(only when a UI axis/position label; keep Blizzard's own string keys literal)* |

---

## What keys must not contain

- Truncated auto-generated suffixes (`_Z`, `_ZO`, `_POSITIO`, `_B`, `_T`, `_D` at end of key unless the key really ends there). If the shortened key would be ambiguous, pick a longer human-readable name.
- The English sentence baked into the key (`FOCUS_YOU_MUST_A_PARTY_SHARE_QUEST`). Keys describe intent, values describe content.
- Placeholder tokens (`%s`, `%d`) — those stay only in the *value*.
- Double prefixes (`H_PRESENCE_PRESENCE_*`, `FOCUS_FOCUS_*`).
- American spellings.

---

## Workflow

### Adding a new key

1. Pick the domain + (optional) subgroup + purpose + (optional) modifier.
2. Add the key to `Localisation/enUS.lua` in the right domain section. Values in UK English.
3. Do **not** manually edit `deDE.lua` / `frFR.lua` / etc. — the restructure script generates them.
4. Run `node tools/restructure_locales.js` — regenerates locale files from enUS, leaving untranslated entries as commented-out fall-throughs.
5. Run `node tools/locale_audit.js --strict` — must pass.
6. Run `node tools/find_orphan_l_keys.js` — must report zero orphans.

### Renaming or removing keys

1. Put `oldKey → newKey` pairs into `tools/locale-key-rename.json`.
2. Run `node tools/apply_locale_key_rename.js` — replaces `L["old"]` / `addon.L["old"]` everywhere.
3. Reset `tools/locale-key-rename.json` back to `{}` when done.
4. Run `restructure_locales.js` → `locale_audit.js --strict` → `find_orphan_l_keys.js`.

### Never-manual edits

- `deDE.lua`, `frFR.lua`, `esES.lua`, `koKR.lua`, `ptBR.lua`, `ruRU.lua`, `zhCN.lua`, `locale_template.lua` — all generated from `enUS.lua` by `restructure_locales.js`. Translators add translations by editing them, but key presence / order / comment headers come from enUS.

---

## File-level binding

Every locale file starts with:

```lua
if GetLocale() ~= "XXYY" then return end

local addon = _G.HorizonSuite

local L = setmetatable({}, { __index = addon.L })
addon.L = L
addon.StandardFont = <font-constant>
```

`enUS.lua` is the base of the chain (no `setmetatable` wrapping — it *is* the fallback table). Missing keys surface as the key string itself (see `LocaleCore.lua` — enable `addon.debugLocale = true` in-game to log them).

---

## Why this file exists

Horizon Suite carried legacy prefix families (`OPTIONS_FOCUS_*`, `OPTIONS_CORE_*`, `H_PRESENCE_*`, `DASH_HOME_*`) that described the **source file** a string came from rather than the **domain** the user sees. When the options UI was refactored the implementation moved but the keys didn't, so key names stopped matching reality. This taxonomy puts the user-facing domain in the name so the two can't drift again.

If you're reviewing a PR that adds an `OPTIONS_*` key, reject it — the prefix is retired.
