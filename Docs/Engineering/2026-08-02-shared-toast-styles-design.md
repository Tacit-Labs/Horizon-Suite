# Shared Augment toast styles (loot + alerts)

**Date:** 2026-08-02  
**Status:** Approved for planning  
**Module:** Augment (Loot Frame + Alerts)

## Goal

Loot and Alerts pick from the same toast **chrome** and **base motion** so choosing the same style makes them feel like one family. Content stays native: loot remains one text line; alerts keep title + body.

In simple terms: both toast systems share the same three “skins” and the same slide/fade basics, but each still shows its own kind of message.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Parity bar | Matching chrome + base motion when the same style is selected; not identical line count |
| Style catalog | Three skins with product names: **Compact**, **Framed**, **Accent** |
| Controls | Separate Axis pickers per system (no global lock, no “match other” toggle) |
| Defaults | Loot → Compact; Alerts → Framed (preserve today’s looks) |
| Architecture | Shared chrome + motion module; separate pools and content paths |
| Motion | Shared base entrance/exit/slide/nudge; loot epic/legend pop + shine stay loot-only |
| Content | Style owns chrome only; loot one line; alerts title + body |

## Style catalog

| Product name | Style ID | Maps from today’s look |
|--------------|----------|------------------------|
| Compact | `compact` | Current loot chip — coloured icon border, no full toast box |
| Framed | `framed` | Current alerts Horizon — dark tooltip box + tinted border |
| Accent | `accent` | Current alerts Minimalist — coloured icon square, no box |

## Architecture

### Shared module

Add `modules/Augment/ToastStyles/AugmentToastStyles.lua` (name may vary slightly), loaded **before** loot and alerts toast cores via TOC.

Responsibilities:

1. **Style IDs and labels** — `compact` | `framed` | `accent`; shared locale keys for Compact / Framed / Accent.
2. **`ApplyChrome(entry, style, colors, layout)`** — Applies backdrop on/off, icon border/square, border/accent tint, and icon–text anchoring consistent with layout inputs (icon side, gap, scale). Does **not** set toast text strings.
3. **`ToastMotion` constants** — Shared `ENTRANCE_DUR`, `EXIT_DUR`, `SLIDE_DIST`, `NUDGE_SPEED`, and a shared ease helper if both cores currently duplicate one. Loot keeps quality-specific entrance durations, pop scale, and shine locally.

### Call sites

- **Alerts** — Replace local `ApplyEntryStyle` / motion constants with shared chrome + motion. Keep title/body population and kind colours.
- **Loot** — Call `ApplyChrome` on show / scale apply. Keep quality entrance, shine, stack fan, single-line text, and loot-owned hold durations.

### Data / DB

| Key | Default | Notes |
|-----|---------|--------|
| `augmentToastStyle` | `compact` | Loot picker |
| `alertsToastStyle` | `framed` | Alerts picker |

**Migration (one-shot):**

- `alertsStyle == "horizon"` → `alertsToastStyle = "framed"`
- `alertsStyle == "minimalist"` → `alertsToastStyle = "accent"`
- Missing loot key → `compact`
- Gate with an explicit one-shot migration flag; do not re-run and clobber later edits.
- Stop writing `alertsStyle` after migration.

Register new keys in Augment `DB_KEYS` / defaults / limits as needed.

### Options (Axis)

- Both Loot Toast Settings and Alerts Display get a **Style** dropdown: Compact / Framed / Accent (shared locale labels; alert-specific desc only if wording must differ).
- Place with the Appearance block (same relative order on both pages: after Grow layout trio, near Font controls).
- Live apply via existing `ApplyAugmentOptions` / `applyAlerts()` paths.
- Remove alerts-only Horizon / Minimalist option labels.

### README

Short Augment capability line: shared toast styles (Compact / Framed / Accent) available for loot and alerts.

## Out of scope

- Merging loot and alerts into one options page or one frame pool
- Forcing two-line loot or one-line alerts
- Sharing epic/legend pop/shine to alerts
- Migrating user-saved font/icon/layout values (style ID migration only)
- Presence / other non-Augment toasts

## Verification

- Same style on both → matching chrome and base slide/fade; loot still one line; alerts still title + body
- Defaults: loot Compact, alerts Framed (after migration of existing alerts styles)
- Epic/legend pop + shine still work on loot under any chrome style
- Per-system icon side / slide / grow / size / gap still work
- `/reload` keeps chosen styles
- Live style changes update active or next toasts without requiring a full UI rebuild beyond existing apply paths

## Dependencies / prerequisites

Builds on recent toast visual consistency (shared default sizes/gaps/font/motion numbers) and toast layout options (#382 / v5.3.5). Does not require those defaults to be identical forever, but shared motion constants should live in the new module going forward.
