# WoW: Forever support — platform capabilities

**Date:** 2026-09-18 · **Status:** in progress on `feature/forever-platform`

## Why

World of Warcraft: Forever (beta 2026-09-17, launch 2026-11-04) runs the Retail
12.1.5 UI API on a vanilla 1–60 world. It reports interface `16001`, build line
1.60.x, and `WOW_PROJECT_ID == WOW_PROJECT_MAINLINE`. Every Retail `C_*`
namespace is present in the client, but several game systems behind them do not
exist. That makes "does the namespace exist" useless as a feature test, so the
addon needs one place that knows which client it is on and what that client has.

## What

`core/Platform.lua` loads first and exposes:

| Field | Meaning |
|---|---|
| `addon.Platform.isForever` / `isRetail` | Mainline project ID with interface below 20000 is Forever |
| `addon.Platform.has[key]` / `Has(key)` | Namespace present **and** not on the known-absent list for this client |
| `addon.Platform.unverified` | Keys whose content has not yet been seen on the beta |

Capability keys and their state on the Forever beta (probe of 2026-09-18):

| Key | Forever | Evidence |
|---|---|---|
| `specs`, `heroTalents` | no | `GetSpecialization` is nil |
| `mythicPlus` | no | 0 keystone maps |
| `delves`, `housing` | no | namespaces present, `C_Endeavors` empty, no content |
| `weeklyVault` | no | API answers but nothing to claim |
| `adventureGuide` | no | Traveler's Log returns 0 activities |
| `achievements` | yes | 111 achievements in 29 categories |
| `transmog` | yes | 237 head appearances |
| `professions` | yes | 20 tradeskill lines, recipe schematics available |
| `contentTracking` | yes | enums and tracked-ID calls work |
| `worldQuests`, `scenarios` | unverified | none seen yet at low level |

In game: `/h platform` prints the table, `/h platform probe` queries each system
live and prints what it returns.

## APIs that answer for systems Forever does not have

The capability table exists because a namespace being present proves nothing.
The first play session on the beta (2026-09-19) found the same trap one level
down, in the functions themselves: they answer, and the answer is wrong.

- **`C_PartyInfo.IsDelveInProgress` returns true inside an ordinary dungeon.**
  Forever has no Delves, so nothing downstream expected to have to doubt it.
  Every dungeon came out classified, coloured and titled as a Delve — the
  scenario provider, the category, the section header and the Presence toasts
  all agree, because all four read `addon.IsDelveActive`. That helper now asks
  `Platform.Has("delves")` before it asks the client. `/h delvedebug` prints the
  raw API answer and the gated one side by side.
- **`UnitName` returns the given name only.** Forever characters have a surname;
  `UnitPVPName` and `GetUnitName` carry it, `UnitName` does not. Any code that
  treats `UnitName` as the whole name, or subtracts its length from
  `UnitPVPName` to isolate a title, is wrong on Forever and was wrong for Retail
  suffix titles already.

**The rule both cases point at:** gate on the capability table, not on whether
the call returns something. A call that answers for a system the client does not
have is the normal case here, not the surprise.

## How modules use it

- **Options.** A row or `Section(...)` may carry `requires = "<key>"`.
  `options/OptionsPlatform.lua` runs once after every module has registered and
  strips anything whose capability is absent, so dashboard, search and the
  detail view never see it. Helpers that take no opts table go through
  `addon.RequireCapability(key, option)`.
- **Runtime.** Code paths call `addon.Platform.Has(key)` before touching a
  system. Most sites were already nil-guarded on the namespace; the guard adds
  the client check on top (Insight spec lines, Essence spec header, inspect cache).
- **Removed globals.** `GetItemInfo` and `GetSpellInfo` do not exist on Forever.
  Use `C_Item.GetItemInfo` and `C_Spell.GetSpellInfo`.

## Rules

- Never test `GetBuildInfo()` or the interface number outside `core/Platform.lua`.
  The beta number may move at launch; it lives in one place.
- Add a capability key rather than an `isForever` branch. A future client that
  gains the system should light up without a code change.
- One TOC. `## Interface: 120100, 16001` and one package. No `_Forever.toc`:
  neither the BigWigs packager nor any addon site has a Forever flavour yet.

## Beta client: SavedVariables are written but not read back

On the Forever beta (build 69913) the client writes `HorizonDB` to
`WTF\Account\<id>\SavedVariables\HorizonSuite.lua` at reload, but hands nothing
back at the next load: `/h platform` reports **NOT restored**, and every module
starts from defaults. Verified against the file on disk (both the root module
list and the character profile said `enabled = true` while the running addon
started empty) and reproduced on the branch's first commit, so it is the client,
not the addon. Until Blizzard fixes it, settings and module toggles on the beta
do not survive a reload. Retail is unaffected.

Two hardening changes came out of chasing this and stay on their own merits:
a module that throws while starting now prints the error instead of silently
staying off, and no bare-name profile is minted before the realm is known.

## Open items

- Confirm task quests and scenarios once a higher-level character can look.
- Sweep for other calls that answer wrongly rather than failing. Two are fixed
  above; nothing proves they are the only two, and each one is only found by
  playing.
- Re-test persistence on each new beta build; drop this section when it holds.
- Per-spec profiles: the toggle is hidden on Forever and resolution falls back
  to the character key; existing Retail spec profiles are untouched.
- Product folder on the Windows test box is `_classic_beta_` (confirmed).
