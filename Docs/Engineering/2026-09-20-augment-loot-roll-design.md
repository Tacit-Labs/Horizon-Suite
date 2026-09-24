# Augment group loot rolls (Need / Greed)

**Date:** 2026-09-20
**Status:** Implemented, awaiting first live test pass
**Module:** Augment (Loot Roll)
**Branch:** `feature/augment-loot-roll`

## Goal

Replace Blizzard's `GroupLootFrame` with a Horizon-drawn roll frame that carries
the Augment chrome, shows who has rolled while the timer is still running, and
tells you what the item is worth to you before you choose. Runs on Retail and on
WoW: Forever from one code path.

In simple terms: when the group rolls on an item, Horizon draws that window
instead of Blizzard, and it shows you more than Blizzard's does.

The 2026-08-07 skinned-loot-window design deferred this deliberately — "Group
rolls (Need/Greed): out of v1; shared skin helper designed so they can plug in
later". This is that plug-in.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Approach | **Native frames.** Horizon owns the buttons and calls `RollOnLoot` itself |
| Blizzard frames | `GroupLootContainer` suppressed the way loot toasts are — never `KillBlizzardFrame` |
| Button set | Driven per-roll by `GetLootRollItemInfo`, never by a client branch |
| Live tally | Yes — from `C_LootHistory`, joined to the roll by item link |
| Item badges | Yes — appearance-known, item level delta, BoP/BoE. Each capability-gated |
| Automation | **Out.** No auto-pass, no auto-greed. Rolling stays the player's act |
| Keybindings | Out of v1 |
| Placement | Own movable anchor, own edit-mode handle, independent of the toast stack |
| Style source | Existing `augmentToastStyle` chrome, applied through `TS.ApplyChrome` |
| Default state | **Off**, pending a live test pass on both clients (Alerts precedent) |
| Confirm popups | Left to Blizzard. We only hide the popup when our frame goes away |

## The API, and why one code path covers both clients

Every call this feature needs is tagged for **both** Midnight 12.1.5 and Forever
1.60.1 on the API wiki:

| Call | Purpose |
|---|---|
| `START_LOOT_ROLL(rollID, rollTime, lootHandle)` | A roll opened |
| `CANCEL_LOOT_ROLL(rollID)` / `CANCEL_ALL_LOOT_ROLLS` | A roll closed |
| `GetLootRollItemInfo(rollID)` | 13 returns; see below |
| `GetLootRollItemLink(rollID)` | Item link — also the tally join key |
| `GetLootRollTimeLeft(rollID)` | Milliseconds remaining |
| `RollOnLoot(rollID, rollType)` | Pass 0 · Need 1 · Greed 2 · Disenchant 3 · Transmog 4 |
| `MAIN_SPEC_NEED_ROLL(rollID, roll, isWinning)` | Your own need roll, resolved early |
| `C_LootHistory.GetSortedDropsForEncounter(encounterID)` | Live tally source |
| `C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID)` | One drop's roll info |
| `LOOT_HISTORY_UPDATE_DROP(encounterID, lootListID)` | Tally refresh trigger |

`RollOnLoot` is unprotected, so our own buttons can roll. Nothing in this feature
touches a secure or protected path, which matters because rolls land mid-combat
constantly — there is no combat deferral anywhere in this module, unlike Alerts.

### The button set gates itself

`GetLootRollItemInfo(rollID)` returns, in order:

```
texture, name, count, quality, bindOnPickUp,
canNeed, canGreed, canDisenchant,
reasonNeed, reasonGreed, reasonDisenchant,
deSkillRequired, canTransmog
```

The `can*` flags decide which buttons exist for *that item*, exactly as Blizzard's
own `GroupLootFrame_OnShow` does it. Two consequences worth stating:

- **Disenchant needs no client branch.** Retail dropped DE rolls; Blizzard's
  current XML has no DE button at all. Forever runs a vanilla world where the
  system never existed. `canDisenchant` is false in both cases, so the button
  simply never draws — and if some content somewhere does offer it, it works.
- **Transmog replaces Greed**, it does not sit beside it. Blizzard shows one or
  the other. We match that.

When a button is unavailable, the reason comes from
`_G["LOOT_ROLL_INELIGIBLE_REASON"..reason]`, shown on hover rather than hidden.

### Where the two clients genuinely diverge

`Enum.EncounterLootDropRollState` distinguishes `NeedMainSpec` from
`NeedOffSpec`. **Forever has no specialisations** (`Platform.has.specs == false`),
so that distinction is meaningless there. `AugmentRollTally.lua` collapses both
states into one "Need" bucket when `specs` is absent, rather than rendering an
off-spec label for a client with no off-spec.

This is the only real fork, and it is expressed as a capability read, not an
`isForever` branch — per the platform doc's rule: *"Add a capability key rather
than an isForever branch. A future client that gains the system should light up
without a code change."*

### What the Forever probe actually says

`core/Platform.lua` earns its existence from a specific trap: on Forever,
`C_PartyInfo.IsDelveInProgress` returns **true** inside an ordinary dungeon, for
a system the client does not have. The lesson recorded there is that *a call
answering is not evidence the system exists*.

Probe of the Forever beta, 2026-09-24, level 1 Undead in Tirisfal Glades, solo:

```
groupLootRolls  RollOnLoot=function GetLootRollItemInfo=function,
                method=Group (3), threshold=2, grouped=no
                LootMethod enum: Freeforall, Group, Masterlooter,
                                 Needbeforegreed, Personal, Roundrobin
lootHistory     0 encounters, 0 drops (0 still rolling), RollState enum=present
specs           GetSpecialization=nil
transmog        head appearances 1/237, PlayerHasTransmogByItemInfo=function
```

Three coherent, *specific* values rather than one boolean:

- **`method=Group (3)`** — the client's active loot method is Group. Not nil,
  not Freeforall, not Personal.
- **`threshold=2`** — Uncommon, the quality at which group rolls trigger.
- **The full `LootMethod` enum**, including `Group` and `Needbeforegreed`.

This is a different quality of evidence from the delve trap. There, a single
boolean returned a stale `true`. Here three independent values cohere, and a
client with no group loot has no obvious reason to name Group as its active
method.

**The Retail comparison has not been measured.** An earlier revision of this
section stated that the same call reads Personal or Freeforall solo on Retail,
and leaned on that disagreement as the strongest part of the argument. It was
reasoning, never a reading: the first Retail probe (2026-09-24, level 90, solo)
crashed on exactly the `groupLootRolls` line, because the frame pool it read had
never been built with the module switched off. The crash is fixed; the value is
still owed. If Retail also reports `Group`, the method line stops distinguishing
the clients and the case for Forever rests on the threshold and enum alone —
weaker, and worth knowing.

Also confirmed by the same probe: `specs` is genuinely absent, so the off-spec
collapse in `AugmentRollTally.lua` is the path that runs on Forever; and transmog
answers, so the appearance badge works there.

### What still is not proven

Nobody has watched a roll open. Zero encounters and zero drops is a solo
character, not a verdict. Configuration being right is not the same as the system
firing, and only a live roll in a party settles:

- that `START_LOOT_ROLL` fires at all on a vanilla-world client,
- that `C_LootHistory` populates, which the tally depends on,
- that the suppression hook and the frames behave against a real roll.

Until then `groupLootRolls` and `lootHistory` stay on `Platform.unverified`, and
the module ships **off by default**.

## Architecture

New mini-module at `modules/Augment/LootRoll/`, structured like `Alerts/`:

| File | Responsibility |
|---|---|
| `AugmentRollState.lua` | Constants, `DB_KEYS` registration, DB accessors, anchor position |
| `AugmentRollTally.lua` | `C_LootHistory` → normalised tally. Owns the roll↔drop join |
| `AugmentRollBadges.lua` | Item context badges, each independently capability-gated |
| `AugmentRollFrames.lua` | Frame pool, chrome, buttons, timer bar, stacking |
| `AugmentRollEvents.lua` | Event registration and roll lifecycle |
| `AugmentRollCore.lua` | Orchestration, anchor, edit mode, `Enable`/`Disable` |
| `AugmentRollDemo.lua` | Fabricated rolls for solo testing (see Testing) |
| `AugmentRollSlash.lua` | `/h roll …` |

Supporting changes:

- `core/Platform.lua` — `groupLootRolls` capability key plus a probe entry.
- `modules/Augment/LootFrame/AugmentBlizzard.lua` — suppress `GroupLootContainer`.
- `modules/Augment/AugmentModule.lua` — lifecycle wiring.
- `options/modules/OptionsAugmentLootRoll.lua` + defaults.

### Data flow

```
START_LOOT_ROLL(rollID, rollTime)
   → GetLootRollItemInfo / GetLootRollItemLink
   → acquire pooled frame, apply TS.ApplyChrome by item quality
   → build buttons from can* flags, badges from capabilities
   → OnUpdate drives the timer bar from GetLootRollTimeLeft

LOOT_HISTORY_UPDATE_DROP(encounterID, lootListID)
   → Tally.Refresh() → re-resolve each open roll's drop → update tally row

click → RollOnLoot(rollID, rollType)   [Blizzard owns any confirm popup]
MAIN_SPEC_NEED_ROLL(rollID, roll, isWinning) → show your own roll early
CANCEL_LOOT_ROLL / CANCEL_ALL_LOOT_ROLLS / LOOT_ROLLS_COMPLETE → release
```

### The roll ↔ drop join, and why it fails closed

This is the sharpest edge in the feature, so it is stated plainly.

**Loot history carries no `rollID`.** `EncounterLootDropInfo` has `lootListID`,
`itemHyperlink`, `rollInfos`, `currentLeader`, `isTied`, `winner`, `allPassed`,
`startTime` and `duration` — and no roll identifier. Blizzard never needs the
join because its roll frame and its history window are separate surfaces that
never talk. We need it because we are putting history data *on* the roll frame.

The only available key is the **item link**: `GetLootRollItemLink(rollID)` against
`drop.itemHyperlink`, searching unfinished drops (`not (drop.winner or
drop.allPassed)` — the same filter Blizzard uses in `LootHistory.lua`).

That is ambiguous when two simultaneous rolls carry an identical link. The rule
in `AugmentRollTally.lua` is therefore:

- Narrow candidates by link, then by whether the drop's `startTime`/`duration`
  window plausibly contains this roll.
- **If more than one candidate survives, show no tally for that roll.** A blank
  tally row is a small loss. A tally showing you another item's rolls, or naming
  the wrong winner, is worse than Blizzard's frame — and it would be believed.

The buttons, timer and badges never depend on the join, so an unresolved tally
degrades one row and nothing else.

## Badges

Each badge is independent and draws only when its capability is present and it
has something to say.

| Badge | Source | Retail | Forever |
|---|---|---|---|
| Appearance not collected | `C_TransmogCollection.PlayerHasTransmogByItemInfo` | yes | yes (237 head appearances confirmed on the beta) |
| Item level vs equipped | `C_Item.GetItemInfo` + equipped slot | yes | yes |
| Binds on pickup | `bindOnPickUp` from the roll info | yes | yes |

`GetItemInfo` and `GetSpellInfo` do not exist on Forever — `C_Item.GetItemInfo`
and `C_Spell.GetSpellInfo` are used throughout, per the platform doc.

A spec-aware "upgrade for your spec" badge is deliberately **not** in v1: it needs
`specs`, which Forever lacks, and an item-level delta already answers most of the
question on both clients without a capability fork.

## Testing

A real Need/Greed roll needs a group, group loot set, and a qualifying drop —
not something to rely on for iterating on layout. Three surfaces make this
testable, in rising order of fidelity:

1. **`/h roll demo`** — fabricates roll frames from real item IDs with no game
   state at all. Exercises chrome, layout, buttons, badges, timer, stacking and
   the tally renderer against synthetic roll info. Works solo, on either client,
   from a standing start. This is how layout gets iterated.
2. **`/h platform probe`** — the `groupLootRolls` probe reports what each client
   says about group loot and loot history from one paste, settling the "does the
   namespace answer, and is it populated" question the capability table cannot.
3. **`/h roll debug`** — logs real roll payloads through the existing
   `addon.Log` tag surface, so one live dungeon run on each client produces the
   evidence a PR needs.

Demo frames are visually identical to live ones by construction: the demo builds
the same descriptor table the event path builds, and calls the same renderer.
The only difference is that its buttons are inert.

### Known constraint on the Forever beta

The Forever beta (build 69913) writes `HorizonDB` but hands nothing back at next
load, so settings do not survive a reload there. Every default in this module is
therefore chosen to be correct with an empty DB, and the demo works from defaults
without any option being set first.

## Defaults, and why the module ships off

`augmentLootRollEnabled` defaults to **false**, following the Alerts precedent
recorded in `OptionsDefaultsAugmentAlerts.lua`: *"the engine and all five kinds
are fully wired up, but none has been verified in-game yet… Flip a kind on here
once it's been confirmed working, rather than shipping it live to every profile
by default."*

This feature suppresses a Blizzard frame the player needs in order to receive
loot. Shipping it on before anyone has seen it roll in a real group would put
"you cannot loot" one bad assumption away. It goes on in a follow-up, once the
live pass on both clients says it works.

## Out of scope

- Automation of any kind (auto-pass, auto-greed, auto-DE).
- Keybindings for rolling.
- A session roll-history panel. `C_LootHistory` already backs Blizzard's own
  history window; a Horizon one is its own feature, not a rider on this.
- Master loot / `DoMasterLootRoll`.
- Bonus rolls (`BonusRollFrame`) — a different system that shares a file, not a
  shared mechanism.
