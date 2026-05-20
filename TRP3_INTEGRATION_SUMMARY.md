# Insight x Total RP 3 Integration

## Current Status

PR #272 (`feature/insight-trp3-integration`) adds Total RP 3 profile data to Insight player tooltips. The branch currently loads after the options refactor, with TRP3 options moved out of `OptionsData.lua` and into the modular options files.

The local branch is synced to the remote PR branch. The old local `OptionsData.lua` hotfix was stashed before pulling the latest refactor and should only be revisited if the refactored options fail again.

## Features

| Feature | DB key | Default |
|---|---|---|
| RP name | `insightTRP3RPName` | on |
| Character icon | `insightTRP3Icon` | on |
| Full title | `insightTRP3Title` | on |
| Custom colour | `insightTRP3CustomColor` | on |
| Pronouns | `insightTRP3Pronouns` | on |
| IC / OOC status | `insightTRP3ICStatus` | on |
| IC / OOC icon indicator | `insightTRP3ICStatusIcon` | off |
| Custom race & class | `insightTRP3RaceClass` | on |
| Custom guild | `insightTRP3Guild` | on |
| Currently text | `insightTRP3Currently` | on |

## Tooltip Behavior

When TRP3 is enabled, Insight reads profile data and renders it inside the normal Insight-styled `GameTooltip`.

Current intended behavior for race/class and guild:

- If the matching TRP3 toggle is off, no TRP3 line is shown and the normal Blizzard/Insight line stays in its usual spot.
- If the toggle is on, the native line is moved to the lower identity area above ratings.
- If valid TRP3 data exists, the lower line uses TRP3 data.
- If valid TRP3 data does not exist, the lower line falls back to native Blizzard/Insight data.

## TRP3 Data Sources

`Insight.GetTRP3PlayerData(unit)` reads:

- Local player profile data from `TRP3_API.profile.getPlayerCurrentProfile()`.
- Other player profile data from `TRP3_API.register.getUnitIDCurrentProfile(unitID)`.
- Profile fields from `characteristics` and `character`.
- Player object helpers from `AddOn_TotalRP3.Player.CreateFromCharacterID(unitID)` when available.

Important fields:

- `characteristics.RA`: custom race
- `characteristics.CL`: custom class
- `characteristics.FT`: full title
- `characteristics.IC`: character icon
- `character.RP`: IC/OOC status
- `character.CU`: Currently text

Player object helpers used where available:

- `GetCustomColorForDisplay()`
- `GetCustomPronouns()`
- `GetCustomRace()`
- `GetCustomClass()`
- `GetCustomGuildMembership()`
- `GetRoleplayStatus()`
- `GetCustomIcon()`

## Options Layout

After the options refactor, TRP3 options live in:

- `options/modules/OptionsInsight.lua`
- `options/modules/defaults/OptionsDefaultsInsight.lua`

The SetDB routing keys live in:

- `options/modules/defaults/OptionsDefaultsInsight.lua`

`OptionsData.lua` should mostly stay focused on shared DB routing and the base `OptionCategories` table. Avoid re-adding the TRP3 option section there unless the options architecture changes again.

## Debug Command

```text
/h debug insight trp3
```

Hover a player with TRP3 data, then run the command to print diagnostics for unit ID resolution, register lookup, profile fields, and Player object method results.

## Note: Native Row Scrub We Backed Out

During testing, yellow rows like these appeared in one tester's tooltip:

- `Cruxis Crystal - Officer`
- `Targeting <YOU>`
- `Item Level 137`

We initially thought those rows were TRP3 native `GameTooltip` additions and briefly added a delayed scrub/filter to remove them after Insight processed the tooltip. That was backed out after discovering they were from the EQoL addon, not TRP3.

Do not re-add that scrub as a TRP3 fix unless we reproduce the issue with only Horizon Suite + TRP3 enabled. If this comes back, first identify the source addon. A future version could add a generic compatibility filter, but it should be opt-in or narrowly scoped so it does not hide another addon's intentional tooltip lines.

## Files To Watch

- `modules/Insight/InsightCore.lua`: tooltip lifecycle, TRP3 suppressor, debug command
- `modules/Insight/InsightPlayerTooltip.lua`: TRP3 data reads and player tooltip rendering
- `options/modules/OptionsInsight.lua`: Insight and TRP3 dashboard options
- `options/modules/defaults/OptionsDefaultsInsight.lua`: Insight defaults and SetDB routing keys
- `locales/horizon/enUS.lua` and sibling locale files: TRP3 option labels/descriptions
