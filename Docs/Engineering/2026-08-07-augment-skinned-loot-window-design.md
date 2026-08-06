# Augment skinned personal loot window

**Date:** 2026-08-07  
**Status:** Approved for planning  
**Module:** Augment (Loot Frame)

## Goal

Keep Blizzard’s interactive personal loot window working (including when Auto Loot is off), stop suppressing it as a “toast,” and restyle it in place so it matches Augment’s Compact / Framed / Accent chrome. Design fidelity targets **Accent** first; the existing loot toast style setting drives both toasts and the window.

In simple terms: Blizzard still owns clicking loot off the corpse; Horizon paints that window to look like Augment and no longer hides it by mistake.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Approach | **In-place restyle** of Blizzard `LootFrame` (not overlay, not custom `LootSlot` replacement) |
| Skin depth | Heavy — chrome, fonts, slot quality colouring, money line, close/title treatment |
| Style source | One setting: existing `augmentToastStyle` / `Y.GetToastStyle()` |
| Design reference | Accent (Compact and Framed still apply when selected) |
| Group rolls (Need/Greed) | Out of v1; shared skin helper designed so they can plug in later |
| Position | Keep Blizzard defaults (including under-mouse CVar behaviour) |
| Options | No new master skin toggle; skin follows Augment loot module enabled |
| Suppress Blizzard | Toasts/alerts only — **never** kill interactive `LootFrame` |

## Problem this fixes

`AugmentBlizzard.lua` currently calls `KillBlizzardFrame(LootFrame)` while suppressing loot toasts. That hides the interactive window players need when Auto Loot is off, so nothing can be looted and Augment toasts never fire either. Option copy already describes toast-only suppression; killing `LootFrame` is incorrect.

## Architecture

### 1. Suppression fix (required)

In `modules/Augment/LootFrame/AugmentBlizzard.lua`:

- Remove `KillBlizzardFrame(LootFrame)` from `SuppressBlizzard`.
- Keep suppressing loot **toast**/alert systems (`LootAlertFrame`, AlertFrame loot events, money/upgrade toast frames, etc.).
- On `ADDON_LOADED` for `Blizzard_LootFrame`, re-apply toast suppression only — do not re-kill `LootFrame`.

### 2. New skin module

Add `modules/Augment/LootFrame/AugmentLootWindowSkin.lua` (name may vary slightly), loaded with the Augment loot TOC block after ToastStyles / state.

Responsibilities:

1. Hook personal loot window show / update (and page changes if present).
2. Strip or hide default Blizzard art (NineSlice / border textures) best-effort.
3. Apply Augment chrome consistent with Compact / Framed / Accent (reuse `ToastStyles` where practical; loot-window-specific layout as needed).
4. Restyle slot names by item quality, icon treatment per style, money line, title/close fonts.
5. Clear / restore on module disable.

Does **not** replace slot click handlers or call `LootSlot` itself in v1.

### 3. Shared skin helper (group-roll hook)

Export a small API on `addon.Augment` (exact names in implementation plan), e.g.:

- Apply window chrome for a given style
- Strip default regions on a frame
- Apply quality colouring to a slot-like row

Personal loot is the first consumer. Group roll frames are not skinned in v1 but should be able to call the same helpers later without rewriting personal loot.

### 4. Lifecycle

| Event | Behaviour |
|-------|-----------|
| Augment loot enable | Install hooks; skin if `LootFrame` already loaded |
| `LootFrame` show / update | Re-apply skin (slots can change) |
| Toast style DB change | Next open (or immediate re-apply if shown) uses new style |
| Augment loot disable | Unhook / restore Blizzard art best-effort |
| `augmentSuppressBlizzard` | Affects toasts only; loot window skin independent |

## Visuals & behaviour

**Restyle:** frame chrome, title, close control, each loot slot (quality-coloured name + style-appropriate icon treatment), money line.

**Preserve:** Blizzard slot clicks and tooltips; Auto Loot CVar behaviour; under-mouse / default positioning; group Need/Greed UI.

**Hover:** Keep Blizzard tooltips on slots — no custom tooltip rewrite in v1.

## Options & README

- No new Axis toggle for v1 skin on/off.
- Document in README only if the skinned window is a user-facing capability worth listing (styled personal loot window matching toast style) — follow README rule at plan/implement time.
- Locale: no new style labels required if reusing existing Compact / Framed / Accent strings; add keys only if new option/help text is needed.

## Out of scope (v1)

- Custom loot frame that owns `LootSlot` / replaces Blizzard hierarchy
- Group loot / Need / Greed / Pass skinning (helper hooks only)
- Edit Mode anchor for the personal loot window
- Separate style dropdown for the loot window
- Changing Auto Loot behaviour or adding “loot all” automation beyond Blizzard

## Edge cases

- Auto Loot on: do not break auto-loot if the window flashes briefly
- Auto Loot off: window must appear and accept clicks (primary regression)
- Many slots / paging: re-skin on Blizzard update
- Combat: appearance-only; guard protected Show/Hide/SetParent if used
- Lazy load of `Blizzard_LootFrame`: hook after load
- Module disable / `/reload`: best-effort restore of default art

## Success criteria / test checklist

- [ ] Auto Loot off → personal loot window appears; items clickable; Augment toast after loot
- [ ] Auto Loot on → looting still works; toasts still work
- [ ] Compact / Framed / Accent → window chrome follows toast style on next open
- [ ] Disable Augment loot → Blizzard window look restored approximately
- [ ] “Hide Default Blizzard Toasts” on → Blizzard loot **toasts** stay suppressed; interactive window still works
- [ ] Group roll UI unchanged

## Open for implementation plan (not design blockers)

- Exact Blizzard hook points on Midnight `LootFrame` (verify against live FrameXML / in-game)
- How much `ToastStyles.ApplyChrome` can be reused vs loot-window-specific chrome helpers
- Best-effort restore fidelity when unskinning
