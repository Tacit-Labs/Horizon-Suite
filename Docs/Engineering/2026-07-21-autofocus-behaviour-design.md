# Auto-Focus Behaviour Modes — Design

**Date:** 2026-07-21  
**Module:** Focus  
**Status:** Approved for planning

## Goal

In simple terms: keep Auto-Focus Closest Quest as an on/off feature, and let players choose how aggressively it manages the focused quest so a nearby quest does not steal focus from one they chose on purpose.

## Problem

Auto-Focus currently always owns focus while enabled. A player focusing a quest in another zone has that choice overridden by a nearer local quest. The tooltip documents this, and `/h focus autofocus` / the keybind pause it, but users reasonably expect a softer mode without turning the feature off.

## Approach

**A — Behaviour dropdown under Auto-Focus** (chosen).

Master toggle stays `proximityAutoSuperTrack`. When on, a new dropdown `proximityAutoBehaviour` selects the rule. Keybind and slash continue to toggle only the master switch.

Rejected:

- **B** — Extra boolean “Don’t override manual focus” (incomplete; two booleans are unclear).
- **C** — Soft pause on click with no option (undiscoverable; not what the user asked for).

## Options UI

| Control | DB key | Notes |
|---|---|---|
| Auto-Focus Closest Quest (toggle) | `proximityAutoSuperTrack` | Unchanged; default `false` |
| Auto-Focus Behaviour (dropdown) | `proximityAutoBehaviour` | Visible when Auto-Focus is on; default `"always"` |
| Include Untracked Quests (toggle) | `proximityAutoIncludeUntracked` | Unchanged; still widens candidate pool for all modes |

### Behaviour values

| Label | Value | Rule |
|---|---|---|
| Always Closest | `always` | Current behaviour; continuously sets focus to closest |
| Respect Manual Focus | `respectManual` | Auto-tracks closest until the player picks a different quest; then yields |
| Only When Unfocused | `onlyWhenUnfocused` | Only fills an empty focus; never replaces an existing one |

Default remains **`always`** so existing users keep today’s behaviour.

### Mode matrix

| Mode | Empty focus | Closest changes | Player focuses another quest |
|---|---|---|---|
| `always` | → closest | → new closest | overridden next update |
| `respectManual` | → closest | → new closest | pause until focus cleared or Auto-Focus re-enabled |
| `onlyWhenUnfocused` | → closest | leave alone | leave alone |

## Detection & session state

Session-only under `addon.focus` (not SavedVariables):

| Field | Purpose |
|---|---|
| `proximityAutoOwnedQID` | Last quest ID Auto-Focus itself set |
| `proximityManualOverride` | `true` after the player chooses a different focus while Auto-Focus is on |

### Set override when

- Tracker click / menu / icon quest `superTrack` chooses a quest that is not the current closest (and not the auto-owned ID), or
- On next Apply: current super-track ≠ closest and ≠ `proximityAutoOwnedQID` (covers Blizzard map clicks and other external focus changes).

### Clear override when

- Super-track becomes empty (`0` / none)
- Auto-Focus master toggle flips off→on (clears pause so automation resumes)
- Behaviour is set to `always` (clears lingering override)
- Manually focused quest is gone (completed / abandoned / no longer valid)

### Mode-specific notes

- **`onlyWhenUnfocused`**: no override flag required; Apply only sets when current focus is empty.
- **`always`**: ignore override; clear it when entering this mode so it does not linger.

## Apply flow

`ApplyProximityAutoSuperTrack` (after closest / optional untracked winner is known):

1. Bail if Auto-Focus off or no valid closest.
2. Read `proximityAutoBehaviour` (default `always`).
3. Read current super-tracked quest ID.
4. Branch:
   - **`always`**: clear override; set closest if different; mark owned.
   - **`onlyWhenUnfocused`**: set closest only if current is empty; mark owned when we set.
   - **`respectManual`**:
     - If override and current empty → clear override, fall through.
     - If override and current still valid (and ≠ owned) → return (leave player focus).
     - If current set, ≠ closest, ≠ owned → set override, return.
     - Else set closest if needed; mark owned.

Manual path: quest `superTrack` in `FocusInteractions` calls a small helper (`MarkProximityManualOverride` / clear) so tracker clicks do not wait for the next layout inference.

## Files to change

| Area | Change |
|---|---|
| `modules/Focus/rendering/FocusAggregator.lua` | Behaviour branch in Apply; export override helpers |
| `modules/Focus/interactions/FocusInteractions.lua` | Mark override on player super-track |
| `modules/Focus/FocusState.lua` | Init `proximityAutoOwnedQID`, `proximityManualOverride` |
| `options/modules/defaults/OptionsDefaultsFocus.lua` | Default `proximityAutoBehaviour = "always"` |
| `options/modules/OptionsFocus.lua` | Dropdown under Auto-Focus; `visibleWhen` + refresh wiring |
| `locales/horizon/enUS.lua` | Labels, tip, mode names (project locale flow for other locales) |
| README.md / README-wago.md / README-curseforge.md | One-line behaviour note under Auto-Focus |

## Out of scope

- Changing proximity *sort* mode
- Per-mode keybinds
- Persisting override across reloads / logout
- Renaming the master toggle (optional polish later; not required for this ship)

## Verification

- Auto-Focus on + each behaviour: empty focus fills with closest.
- Closest changes while walking: `always` / `respectManual` update; `onlyWhenUnfocused` does not once focused.
- Manual pick of a non-closest quest: `always` overrides; `respectManual` holds; `onlyWhenUnfocused` holds.
- Clearing focus or toggling Auto-Focus resumes `respectManual`.
- Include Untracked still affects the candidate pool in all three modes.
- Options dashboard stays in sync when using slash/keybind for the master toggle.
