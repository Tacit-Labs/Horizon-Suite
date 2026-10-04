# Dashboard settings consolidation

**Date:** 2026-10-04
**Status:** Approved for planning (phase 1); phases 2 and 3 need their own specs
**Module:** Axis (dashboard), touching every module's options file

## Goal

The Axis dashboard holds about 776 settings across 35 pages in 8 modules. Players cannot find
what they want: a typical setting is three or four clicks deep, every card opens collapsed,
search misses whole areas, and the same kind of setting (font, scale, opacity, position) lives in
a different place in each module.

This work makes the settings compact, dynamic and easy to find. Every module shares one page
vocabulary, so a player who learns where sizing lives in Focus knows where it lives in Vista.
Settings that only matter once another setting is on stay hidden until then, and niche settings
sit behind a per-card **More** fold.

## Locked decisions

| Decision | Choice |
|---|---|
| Scope | Reorganise the UI and also prune or merge settings |
| Niche settings | Per-card **More** fold, marked per row with `advanced = true` |
| Dependent settings | Hidden until their parent applies; declared with `parent` / `parentIs` |
| Navigation | Module → page → card, with 2 to 5 pages per module |
| Page names | One shared vocabulary in every module: General, Layout, Look & Feel, then the module's own pages |
| Card density | Row style A (today's 32px rows, dependent rows indented) for the shell; merged controls (style C) during module prunes |
| Augment | One page per feature (Loot, Alerts, Loot Roll, Talking Head, Vendor, Self highlight, Achievement tracker); no shared pages (see Augment below) |
| Third-party addon settings | RareScanner, SilverDragon and TRP3 move into the Integrations view (phase 3) |
| Build approach | Tag and assemble: sections declare `page` and `card`; one assembler builds the pages |
| Saved settings | Phase 1 changes no DB keys and needs no migration |

## Inventory at the start

Counts from `origin/main` at `6ad33d9`, accurate to roughly ±3 per module.

| Module | Pages | Settings |
|---|---|---|
| Axis | 3 | 57 |
| Focus (with integrations) | 12 | 277 |
| Vista | 3 | 107 |
| Insight | 4 | 80 |
| Presence | 4 | 55 |
| Echo | 1 | 72 |
| Augment | 7 | 122 |
| Essence | 1 | 6 |
| **Total** | **35** | **776** |

Problems found, all confirmed against the code:

- About 25 font-family dropdowns, each with its own size, outline and shadow controls.
- Scale is set in four ways: a global slider, per-module sliders in Axis, and separate Presence,
  Echo and Talking Head scales. `augmentUIScale` appears twice, as Axis "Augment scale"
  (`OptionsGlobal.lua:445`) and Augment "Toast scale" (`OptionsAugment.lua:87`).
- Ten opacity sliders and five copies of a Position, Lock and Reset block.
- Search never descends into `type = "columns"` blocks, so most Augment settings cannot be found.
- `defaultCollapsed` is set on six sections but nothing reads it; every card starts collapsed.
- About 190 rows already hide or grey out based on another setting, each wired by hand with
  `visibleWhen` plus a matching `refreshIds` entry on the parent.
- Section names overlap or mislead: Focus has "Visibility", "Visibility & Fading" and an
  Instances "Visibility"; Presence "Instance suppression" also holds level-up and achievement toggles.

## Phases

1. **Dashboard shell** (this spec): the page vocabulary, the assembler, card behaviour, search,
   and retagging every module onto the shared pages.
2. **Shared look and scale** (own spec): one Axis value each for typography, scale, opacity and
   position, with per-module overrides and a profile migration. Closes issue #11.
3. **Module prunes** (one spec per module, Focus first): mark advanced rows, adopt `parent`,
   merge controls, reword labels, move third-party addon settings into Integrations.

Phase 2 and phase 3 depend on phase 1's vocabulary and More fold. They are described here only
enough to fix the order; their own specs carry the detail.

## Page vocabulary

Every module shows the shared pages first, in this order, then its own pages. A page with no
cards does not appear.

| Page | Key | Holds | Shared cards, in order |
|---|---|---|---|
| General | `general` | On/off, behaviour, when it shows | Visibility, Behaviour |
| Layout | `layout` | Where it sits and **all sizing** | Position, Size |
| Look & Feel | `look` | How it looks and moves | Text, Colours, Background & border, Animation |

Shared card keys: `visibility`, `behaviour`, `position`, `size`, `text`, `colours`,
`background`, `animation`. A shared page may also hold module cards, which follow the shared
cards in registration order.

Rule for anyone adding a setting: size or position goes on Layout; font, colour, opacity or
animation goes on Look & Feel; everything else goes on General or one of the module's own pages.

### Target page map

| Module | Pages | Built from today's pages |
|---|---|---|
| Axis | General · Layout · Look & Feel · Profiles | Minimap icon and game menu → General; global scale → Layout; global font, class colour, dashboard look → Look & Feel. The old Modules page is removed: module switches live on the Axis home page |
| Focus | General · Layout · Look & Feel · What's tracked · Instances | Click options and Interactions → General; Layout and Animations → Layout and Look & Feel; Appearance, Typography and Colors → Look & Feel; Content types, Sorting & filtering and Hidden quests → What's tracked |
| Vista | General · Layout · Look & Feel · Buttons | Minimap and Appearance split across the shared pages; the three text sections become one Text card |
| Insight | General · Layout · Look & Feel · Players · NPCs & items | NPC and Item merge into one page with an NPC card and an Item card |
| Presence | General · Layout · Look & Feel · Notifications | Preview becomes the first card on Notifications; moving it into the preview pull-out waits for the Presence prune |
| Echo | General · Layout · Look & Feel · Feeds & groups | History, Blizzard chat and sounds → General; tiers, feeds and groups → Feeds & groups |
| Augment | Loot · Alerts · Loot Roll · Talking Head · Vendor · Self highlight · Achievement tracker | Same pages as today in a new order; columns layouts become ordinary cards |
| Essence | General · Layout | |

Until phase 3, RareScanner and SilverDragon stay on a Focus "Integrations" module page and TRP3
on a card of its own on the Insight Players page.

**Augment keeps its feature pages.** Vendor, Self highlight and Achievement tracker are separate
features, each with an on/off switch whose setter runs code (`setEnabled` starts or stops the
feature). A card header switch only saves a value, so folding them into a General page would
break those switches. Every Augment feature therefore keeps its own page, icon and switch; the
Achievement tracker page has no settings besides its switch and is kept with `allowEmpty`.
Giving each feature page its own Layout and Look & Feel cards is part of the Augment prune.

## Architecture

### What exists today

Each module options file appends category tables to `addon.OptionCategories`
(`OptionsData.lua:321`). A category is one page; each top-level `Section` in its `options`
becomes one accordion card. About 15 places read the list: the sidebar (`DashboardFrame.lua`),
the detail view (`DashboardDetailView.lua`), search (`OptionsSearch.lua`), platform pruning
(`OptionsPlatform.lua`), `DashboardPanel.lua` and the preview pull-out.

### What changes

Module files contribute tagged sections. One assembler turns them into pages and writes the
result back into `addon.OptionCategories`, so every reader keeps working unchanged.

**`options/OptionsPages.lua` (new).** The vocabulary: the ordered shared pages, the ordered
shared cards for each, and their locale keys. Loaded before any module options file.

**Section tags.** A `Section` gains:

- `page`: a shared page key, or a module page key the module declared.
- `card`: a shared card key, or a module card key. Sections that share a `card` on the same page
  merge into one card, rows in registration order.

A module declares its own pages and their order with
`addon.RegisterModulePages(moduleKey, { { key = "tracked", name = ... }, ... })`. A def may also
name a shared page to attach fields to it. Page fields copied onto the emitted page: `desc`,
`icon`, `accentColor`, `enabledKey`/`getEnabled`/`setEnabled`, `hidden`, `dashboardPreviewMode`
and `headerButtons`. Assembler-only fields: `legacyKey` (keep an old category key),
`cardNames` (display names for module cards) and `allowEmpty` (emit the page with no cards).

**`options/OptionsAssemble.lua` (new).** Runs once after every module options file and before
`OptionsPlatform.lua` and `OptionsSearch.lua`: it goes in `HorizonSuite.toc` directly after
`options/modules/OptionsFocusIntegrations.lua`. For each module it:

1. groups sections by page, then by card;
2. orders pages (shared first, then module pages) and cards (shared first, then module cards);
3. merges sections that share a card;
4. drops pages with no cards;
5. emits one category per page into `addon.OptionCategories`, keeping `moduleKey`.

Categories whose `options` is a function stay lazy: the emitted page's `options` is a function
that evaluates its sources when called.

**Load-time checks.** Each prints one red chat line naming the module, section and problem, and
the assembler skips the offending section instead of erroring:

- a `page` key that is neither shared nor declared by the module;
- a section on a shared page with no `card`;
- two sections merged into one card that each carry a `headerToggle`.

**Kept category keys.** `Profiles` and `GlobalToggles` keep their keys (via `legacyKey`) so
the Welcome links and `Dashboard_IsAxisCategoryKey` keep working; that check also accepts any
`axis:<page>` key. Other emitted pages use `<moduleKey>:<pageKey>`. The Axis `Modules` category
was removed during implementation, because the Axis home page already shows every module switch.

**Header buttons move onto the page.** The detail view currently shows preview, reset and anchor
buttons by checking for the keys `AugmentImprovements` and `AugmentAlerts`
(`DashboardDetailView.lua:1046`). Pages carry `headerButtons = { preview = fn, reset = fn, anchor = fn }`
instead, and the detail view shows a button when its function is present.

**Transition fallback.** During phase 1, a category registered without tags passes through the
assembler untouched. The fallback is removed in the final retag PR, after which an untagged
section is a load-time error.

## Card behaviour

**Open and closed.** The first card on a page opens by default; the rest start closed. Each
card's state is remembered account-wide in the root saved table, next to the sidebar's group
collapse state (`optionsCardExpanded` and `optionsCardMoreOpen`), keyed by
`<moduleKey>:<page key>:<card key>`. It is UI state, so it does not follow profile switches. A remembered state wins over the default. `defaultCollapsed` and its
six uses are deleted.

**Dependent rows.** A row may declare:

- `parent = "<dbKey>"`: the setting it depends on;
- `parentIs = <value>` or `parentIs = function(v) ... end`: when it shows. Defaults to truthy.

The card builder indents the row under its parent with an accent line, hides it unless the
parent matches, and refreshes it when the parent changes. This replaces hand-written
`visibleWhen` plus `refreshIds` pairs for the simple case. `visibleWhen` stays for compound
conditions.

The three states stay distinct:

| State | Meaning | Example |
|---|---|---|
| Hidden | Does not apply to the player's current setup | Max width while Dynamic width is off |
| Greyed, reason in tooltip | Blocked by something outside the card | "Requires Focus to be enabled" |
| Removed at load | Does not exist on this platform | `requires = "<capability>"` on Forever |

**More fold.** A row with `advanced = true` renders below the card's everyday rows, behind a
**More (n)** row showing the count. The fold opens inline, and its state is remembered per card
like open and closed. A card with no advanced rows shows no More row. Phase 1 builds the fold
only; marking rows advanced happens in phase 3.

**Columns removed.** The assembler unwraps `type = "columns"` blocks: rows before a column's
first nested section stay in the enclosing card, and each nested section becomes its own card on
the same page. Once every module is tagged, nothing reaches the card builder as columns, and the
last phase 1 PR deletes the second row-building path in `DashboardAccordionBuild.lua` (about lines
1043 to 1160). Search then sees those rows too.

## Search

- **Coverage.** `OptionsData_BuildSearchIndex` reads the assembled pages, so it sees every row,
  including former columns rows and rows behind More. Special widgets without a name (colour
  matrix, hidden-quests grid, Presence preview) get a `searchName`.
- **Result location.** Each result shows module, page and card, for example
  "Focus › Layout › Size".
- **Navigation.** Opening a result opens the page, then the card, then the More fold if needed.
  If the row is hidden because its parent does not match, it shows in place with a hint naming
  the parent ("Turn on Dynamic width to use this"). `NavigateToOption` resolves the card from
  the assembled data instead of the current 0.1s timer and frame search.
- **Keywords.** An optional `keywords` list of locale strings adds terms that are not in the
  label. Keyword matches rank below name matches and above description matches. Used sparingly,
  mainly so renamed or merged settings in phase 3 still answer to their old names.
- **Index lifetime.** Built once when the dashboard opens and rebuilt only when a module is
  turned on or off, instead of on every keystroke.

## Locales

Page and card names are new locale keys in `locales/horizon/enUS.lua`
(`PAGE_GENERAL`, `PAGE_LAYOUT`, `PAGE_LOOK`, `CARD_POSITION`, and so on). Other locales fall
back to English until translated. Existing section names stay as they are where a section
becomes a module card.

## Delivery

Phase 1 ships as a series of PRs, each releasable on its own:

1. Vocabulary, assembler, load-time checks and transition fallback. No visible change.
2. Card behaviour: open state, `parent`/`parentIs`, More fold, `defaultCollapsed` removal.
3. Search: assembled index, location in results, `keywords`, `searchName`, index lifetime.
4. Retag per module, one PR each: Axis, Focus, Vista, Insight, Presence, Echo, Essence, and
   Augment (which also moves the header buttons onto its pages).
5. Turn the transition fallback into a load-time error and delete the columns code path.

Every player-visible PR gets a before and after image through `/update-card` and a CHANGELOG
entry at release.

## Testing

**Logic script.** `tools/test_options_logic.js`, following the existing
`tools/test_echo_logic.js` harness (fengari, stubbed WoW globals). It covers:

- page order, card order and card merging;
- empty-page removal and the transition fallback;
- each load-time check firing on a bad tag;
- `parent`/`parentIs` visibility, including function predicates;
- search finding a former columns row and a More row, the result location string, and keyword
  ranking.

**In game.** Run on the Windows PC on Retail and on Forever for each PR:

- every module's sidebar shows the expected pages in the shared order;
- the first card opens, and open state and More state survive `/reload`;
- dependent rows indent, hide and reappear as their parent changes;
- a search hit inside More and a hit on a hidden row both land correctly;
- Augment's preview, reset and anchor buttons still work on Loot and Alerts;
- Forever-pruned rows stay absent.

## Out of scope

- The Home and Welcome screens and the Module Guide.
- The preview pull-out's design.
- Any change to what a setting does or to its saved value (phase 2 and phase 3 own those).
