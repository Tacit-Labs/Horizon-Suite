# PR #173 — SwiftMint Review: Action Plan

Working triage doc for addressing SwiftMint's review of
**PR #173 — "Vista button for quick teleport overview"**
(branch `feature/172-vista-teleport-button`, closes #172).

Swift left **three deliberately siloed comments**. Each opens with the same
disclaimer: a point raised in one comment will **not** be repeated in another,
even if relevant. So treat them as three independent workstreams and read all
three before assuming something is "missing".

- §1 [Strictly PR Body Feedback](https://github.com/Tacit-Labs/Horizon-Suite/pull/173#issuecomment-4709817660) — PR description text only, **no code**.
- §2 [Strictly In-Game Feedback](https://github.com/Tacit-Labs/Horizon-Suite/pull/173#issuecomment-4710453248) — behavioural / UX bugs found while testing.
- §3 [Strictly Code-Base Feedback](https://github.com/Tacit-Labs/Horizon-Suite/pull/173#issuecomment-4712618095) — code review.

Legend: **[BUG]** functional defect · **[CONV]** convention/doc violation ·
**[WORD]** wording/docs only · **[REFACTOR]** cleanup · **[Q]** needs a decision
or a reply to Swift before acting.

Files in scope (current PR):
- `modules/Vista/VistaTeleports.lua` (new, 471 lines)
- `modules/Vista/VistaCore.lua` (+373)
- `options/modules/OptionsVista.lua` (+22)
- `options/modules/defaults/OptionsDefaultsVista.lua` (+22)
- `locales/horizon/enUS.lua` (+43)
- `HorizonSuite.toc`, `modules/Focus/FocusInteractions.lua` (minor)

Cited repo references to read first: `Docs/Contributions/Repository/GitHubPRs.md`,
`Docs/Contributions/Code.md` (`## Files, Functions, Variables, etc.`),
`locales/KeyNomenclature.md`, and PRs/issues **#325, #262, #188, #172**.

---

## §1 — PR Body Feedback (description rewrite, no code)

> All of these are edits to the PR description on GitHub. Quick, uncontroversial.

- [ ] **[CONV]** Reformat **Intent** to the `# Intent` template in `GitHubPRs.md`.
- [ ] **[WORD]** Break up run-on sentences flagged across Reviewer Notes &
  Developer Notes (~12 specific sentences quoted by Swift).
- [ ] **[WORD]** Delete the "reconciles the original #172 work (≈6 weeks / 117
  commits stale…)" narrative — it was only a draft, never an open PR, and
  "building it out" is the point of the PR. Pure fluff.
- [ ] **[WORD]** Fix the "(Safe because these teleports can't be cast in combat
  anyway.)" parenthetical — it has its own terminal punctuation outside the
  prior sentence. (Also factually wrong — see §2/§3.)
- [ ] **[WORD]** Remove the self-review boast ("adversarial multi-lens
  review… ship-ready, zero findings"). `GitHubPRs.md` says self-review +
  in-game testing is *expected*, not noteworthy.
- [ ] **[CONV]** Reformat the **Reviewer Checklist** to the documented
  `## Reviewer Checklist` format.
- [ ] **[WORD]** Replace the confusing "toggle **Other** off" checklist example
  with a concrete group, e.g. "toggle Hearthstones off → only Hearthstone rows
  vanish (all others preserved)".
- [ ] **[WORD]** `relog` vs `/reload` inconsistency — standardise on `/reload`
  (or be explicit if a real logout is intended).
- [ ] **[WORD]** Resources: #172 is already linked in Intent (drop the dup);
  lead with the wiki source rather than burying it; list or drop "info APIs".

---

## §2 — In-Game Feedback (behaviour / UX)

### Confirmed functional bugs (code)

- [ ] **[BUG] Mouseover-only default broken.** Both `Show Teleport Button` and
  `Teleport Button on Mouseover Only` are on by default, yet the button shows
  **permanently** on login; toggling `Show` does nothing, only toggling
  `Mouseover-Only` off→on fixes it.
  - Smoking gun: `VISTA_DEFAULTS` sets `vistaMouseoverTeleport = true`
    (`OptionsDefaultsVista.lua:145`) but the live getter defaults to `false`
    (`VistaCore.lua:255` `G.MouseoverTeleport`). Confirm the proxy's
    mouseover-reveal handlers are wired for the `teleport` key on first
    `CreateDefaultButtonProxies`, and that initial state honours the DB.
  - Compare against how `tracking`/`calendar` reveal on minimap hover.

- [ ] **[BUG] Faction/zone-wrong teleports listed.** Frostwolf Insignia (Horde)
  appears for an Alliance character; both AV insignias show despite being
  unusable outside Alterac Valley (`VistaTeleports.lua:240-241`).
  `PlayerHasToy` isn't faction/zone aware — either drop these entries or add a
  faction/usability filter to `ResolveEntry`.

- [ ] **[BUG] "Cooldown sweeps" don't sweep.** Only the countdown number shows;
  no radial sweep motion. Check `row._cd` config (`VistaCore.lua:1783-1787`):
  `SetDrawSwipe`/`SetDrawEdge`/`SetSwipeColor` and that the Cooldown frame isn't
  hidden behind the icon.

- [ ] **[BUG] Menu won't close in combat.** If the menu is open when combat
  starts, it stays open after the mouse leaves until combat ends. Caused by the
  combat-guarded `menu:Hide()` (`VistaCore.lua:1858-1872`, `2207`). Decide on
  acceptable UX (e.g. hide-on-OnLeave is already deferred to
  `PLAYER_REGEN_ENABLED`; can we fade/visually disable instead?).

- [ ] **[BUG] Paging math is off.** Page breaks at 17 items regardless of how
  many category headers are shown; disabling a category whose rows aren't
  visible still changes the page count. `TP_MaxVisible` (`VistaCore.lua:1732`)
  reserves a fixed `6 * TP_HDR_H` for headers instead of counting the actual
  sections on the page. Rework to page by rendered height / real section count.

- [ ] **[BUG/Q] "No teleports unlocked" placeholder is misleading** when the
  real cause is "all categories disabled". Add a distinct message for the
  all-groups-off case (`VistaCore.lua:1896`, `VistaTeleports.lua` empty path).

### Wording / strings (in-game)

- [ ] **[CONV] "Favourites" vs "Favorites".** In-game strings use American
  "Favorites" (menu header, "Enable Favorites", "Clear Teleport Favorites");
  `KeyNomenclature.md` requires King's English for new strings → standardise on
  **"Favourites"**. ⚠️ Judgment call: the favourite icon is Blizzard's
  `FavoritesIcon` and WoW's own UI uses "Favorites" — confirm which wins before
  mass-renaming locale strings. **[Q]**
- [ ] **[WORD]** "Recently-used" appears only once; elsewhere "Show Recently
  Used" / "Recent" / "Clear Recent Teleports" — make consistent.
- [ ] **[WORD]** PR/checklist say "Clear Recent / Clear Favorites"; actual
  labels are "Clear Recent Teleports" / "Clear Teleport Favorites".

### Questions / judgment calls (decide, then reply to Swift)

- [ ] **[Q] Button placement.** Swift finds bottom-right crowded and overlapping
  the other buttons. Move it, or keep consistency with tracking/calendar? Affects
  `DEFAULT_BTN_DEFS` teleport anchor (`VistaCore.lua:2191-2192`).
- [ ] **[Q] Right-click also casts** — intentional? Rows
  `RegisterForClicks("AnyDown","AnyUp")` (`VistaCore.lua:1772`). If only
  left-click should cast, restrict it.
- [ ] **[Q] Mage portals listed separately from class teleports** in the PR copy
  — clarify wording / grouping intent.
- [ ] **No action:** "raid teleports don't exist" — Swift self-corrected (they
  exist since Shadowlands). Just acknowledge.
- [ ] **[WORD/§1]** "Settings hard to find" — Swift wants exact setting locations
  bolded in test instructions. Really a PR-body/testing-doc fix (§1).

---

## §3 — Code-Base Feedback (the meat)

### Correctness / factual

- [ ] **[BUG] Deprecated APIs.** `IsPlayerSpell` and `IsSpellKnown` were removed
  in 11.2.0 (`VistaTeleports.lua:289-290`). Replace with
  `C_SpellBook.IsSpellKnown(spellID)` (added 11.0). Verify the
  known-vs-in-spellbook semantics match what we want for teleport spells.
- [ ] **[BUG] Wrong item ID.** `153716` labelled "Wormhole Generator: Argus"
  (`VistaTeleports.lua:59`) is actually **Jewelhammer's Focus**. Find the real
  Argus wormhole ID (or remove if Argus has no wormhole toy).
- [ ] **[BUG] Duplicate "Wormhole Generator: Khaz Algar".** Appears at `:63`
  (`219030`) and `:110` (`221966`); one ID is wrong/non-existent and the comment
  references a prototype ID (`221965`) that isn't wired up. Resolve to the single
  correct toy ID.
- [ ] **[BUG] Catalogue incomplete & needs a full ID-by-ID audit.** Missing many
  hearthstones (Swift linked the Wowhead "Returns you to Hearthstone Location"
  filter), Ancient Dalaran portal, guild cloaks, rings, "The Last Relic of
  Argus", etc. Go through every entry, verify ID↔name against a source, and
  document where each came from.
- [ ] **[BUG]** `GameTooltip:SetText` called with missing args in `VistaCore.lua`
  — use the full `SetText(text, r, g, b, wrapText)` form (e.g. the favourite-star
  tip `:1807`; audit the others at `:927`, `:1336`, `:1341`, `:1573`).

### Conventions (per cited docs)

- [ ] **[CONV] `TP_*` file-scope names violate `Docs/Contributions/Code.md`**
  (Proper Case alphabetical only — no underscores, no numerals). Rename all
  `TP_ROW_H`, `TP_CreateRow`, `TP_EnsureMenu`, `TP_MaxVisible`, `TP_SkinStar`,
  etc. to Proper Case (e.g. `TeleportRowHeight`, `CreateTeleportRow`). ~30
  references in `VistaCore.lua` (1718-2037).
- [ ] **[CONV] Locale keys** — audit the 43 new `enUS.lua` keys against the
  *temporary* scheme in `locales/KeyNomenclature.md`; confirm the scheme hasn't
  changed; reference official keys where they name concrete WoW things; King's
  English for strings. Do **not** edit other locale files (regenerated from enUS).
- [ ] **[CONV/WORD]** Comment cleanups:
  - "Consumed by the Vista teleport proxy button" (`VistaTeleports.lua:4`) —
    odd word choice ("Consumed").
  - "Curated catalogue" flourish (`VistaTeleports.lua:3`) — either use the full
    "…of teleport toys, items, and class spells" or drop the flourish; keep it
    consistent with the Developer-Notes phrasing.
  - "Both AnyDown and AnyUp required since 10.0…" (`VistaCore.lua:1770`) — we're
    on 12.0.x; drop the historical note.
  - "Sort order: group (hearthstone → … → other)" (`VistaTeleports.lua:328-329`)
    — don't hard-code the order in prose; say "follows `GROUP_ORDER`".
  - `(Alliance)`/`(Horde)` comments on entries with no faction alternative are
    inconsistent — remove or apply uniformly (`VistaTeleports.lua` class block).
  - Dungeon/raid entries: some have a location comment, many don't — make
    uniform (add or remove).
- [ ] **[CONV] OOC ambiguity.** "Out of combat" abbreviated as `OOC` near a
  codebase with TRP3 integration (where OOC = out-of-character). Spell it out
  ("out of combat") in comments (`VistaCore.lua:1954` etc.).
- [ ] **[CONV]** Inconsistent comment casing: `non-secure` vs
  `NON-secure (no secure template)` (`VistaCore.lua:1783`, `1788`) — pick one.
- [ ] **[Q] `RECENT_CAP = 8`** (`VistaTeleports.lua:353`) — Swift argues 5.
  Decide (5 vs 8) and set.
- [ ] **[CONV/WORD]** Remove the "Midnight / secret values" framing if it's not
  adding clarity; ensure cooldown comments describe behaviour, not lore.

### Refactors

- [ ] **[REFACTOR] Duplicated `showFuncs`/`mouseoverFuncs` tables** in
  `RefreshDefaultButtonProxiesFromDB` (`VistaCore.lua:2240-2249`) and
  `CreateDefaultButtonProxies` (`:2304-2313`). Hoist to one shared upvalue table.
- [ ] **[REFACTOR/Q] `local LayoutTeleportMenu` forward-decl + the
  `and LayoutTeleportMenu then LayoutTeleportMenu(menu)` guard**
  (`VistaCore.lua:1764`, `1802`).
  - The forward declaration **is** correct/necessary: `TP_CreateRow` (defined at
    `:1767`, before `LayoutTeleportMenu` at `:1878`) closes over it. Reply to
    Swift explaining this.
  - The `and LayoutTeleportMenu` nil-guard is redundant by runtime — simplify the
    star-handler call site.
- [ ] **[REFACTOR] Use the existing `Slider()` helper** in `OptionsVista.lua`
  for the teleport-size slider instead of the hand-rolled `{ type = "slider", …}`
  block — match the surrounding sliders.
- [ ] **[REFACTOR/Q]** Font size: header/rows use `GameFontNormalSmall`
  (`VistaCore.lua:1777`, `1924`) — Swift asks why not Normal, and whether we can
  resolve to `addon.GetDefaultFontPath`. Decide on a font strategy consistent
  with the rest of Vista.
- [ ] **[CONV]** `vista*_proxy_teleport`, `vistaTeleportGroup_*`,
  `vistaTeleportShowRecents` are absent from `VistaCore` where the sibling proxy
  keys are declared — align declaration locations with the other proxy keys.

### Questions to answer in a reply (no code change unless decided)

- [ ] **[Q]** "Why a Horizon-only proxy for this?" (`VistaCore.lua:2190`
  `names = {}`). Also "see #325" — read it and align.
- [ ] **[Q]** "Names resolve **live**?" — clarify it means resolved at
  menu-build time via `C_ToyBox`/`C_Spell`, not a recurring ticker.
- [ ] **[Q]** "`C_Item.GetItemCooldown` as 3 scalars — what are they?"
  Answer: `startTime, duration, enable` (`VistaCore.lua:1976`).
- [ ] **[Q]** "Are any of those in bags anymore?" (PR's "without opening the map,
  bags, spellbook…") — verify the claim, adjust copy.
- [ ] **[Q]** "Example of a non-recognisable group?" The `other` catch-all in
  `GroupEnabled` (`VistaTeleports.lua:322-326`) — Swift notes nothing falls
  through since unknowns aren't shown. Either justify the catch-all or simplify.
- [ ] **[Q]** PR claim "`VISTA_KEYS` ported to `OptionsVista.lua`" is inaccurate
  — `VISTA_KEYS` lives in `OptionsDefaultsVista.lua`/`OptionsData`, not
  `OptionsVista`. Correct the PR copy (§1) and confirm key placement.
- [ ] **[CONV]** Review against referenced precedents: **#262** (VistaCore),
  **#188** (VistaTeleports), **#325** (proxy) — align patterns.
- [ ] **[Q] `locales/horizon/enUS.lua` entirety** — Swift points to
  `KeyNomenclature.md` "TEMPORARY Naming Scheme"; compare to a recently merged PR
  for the current accepted format.

---

## Suggested order of attack

1. **§1 PR body** — fast, no code, clears the simplest objections.
2. **§3 correctness** — deprecated APIs + catalogue ID audit (highest risk).
3. **§2 functional bugs** — mouseover default, faction filter, cooldown sweep,
   paging.
4. **§3 conventions + refactors** — renames, dedup, Slider(), comments.
5. **Reply to Swift** on all the **[Q]** items (placement, right-click,
   RECENT_CAP, font, proxy rationale, scalars, etc.) — ideally batch into one
   reply per comment thread.

## Open decisions to confirm before coding
- "Favourites" vs "Favorites" (King's English vs Blizzard/WoW convention).
- Button placement (move vs keep bottom-right).
- Right-click cast (keep vs left-only).
- `RECENT_CAP` 5 vs 8.
- Font: `GameFontNormalSmall` vs Normal vs `addon.GetDefaultFontPath`.
- In-combat menu behaviour (current deferred-hide vs visual disable).
