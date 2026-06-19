# GameTooltip Sizing with Custom Fonts

How Insight keeps styled tooltip text inside the border, and why the obvious
approaches do not work. Applies to any module that restyles `GameTooltip`
fonts after Blizzard populates content.

## The problem

`GameTooltip` computes its frame size in C code from line metrics measured
with the fonts **in effect at layout time** — Blizzard's defaults. When a
module swaps lines to a custom font afterward (often larger, especially the
header line), the engine **never re-measures**:

- Not on a second `Show()`.
- Not when a `FontString`'s font changes.

The result: the frame is sized for smaller text than it contains. Long
names/titles overflow the right border, and taller lines eat the bottom
padding so the last line crowds the border.

Worse, Blizzard **periodically refreshes** unit tooltip content while the
cursor hovers (roughly every 0.2s). Each refresh re-runs the stale engine
layout, stomping any one-time correction the addon made.

## Approaches that do NOT work (tried, failed)

1. **Re-`Show()` after restyling fonts.** The engine reuses its stale
   measurements; width does not change.
2. **One-shot manual `SetWidth`, including deferred via `C_Timer.After(0)`.**
   Works for one frame (or a few), then the next periodic refresh stomps it.

## The working fix

`Insight.FixTooltipSize` (`modules/Insight/InsightShared.lua`) measures the
styled lines itself and grows the frame to fit — and a
`GameTooltip:HookScript("OnUpdate", ...)` (`modules/Insight/InsightCore.lua`)
re-asserts it **every frame** while a unit tooltip is shown. Don't try to
out-time the engine; continuously assert the invariant. The function bails
when the size already fits, so the steady-state cost is one measurement pass
over ~10 lines per frame.

Key details, each load-bearing:

- **Measure non-wrapping lines with `GetStringWidth`** (full text width).
  `GetWrappedWidth` on a non-wrapping line returns the laid-out rect width —
  which is the very stale width being corrected, so using it under-measures
  circularly. Wrapping lines need `GetWrappedWidth`, since their
  `GetStringWidth` is the unwrapped single-line width and would over-widen.
  Branch on `CanWordWrap()`.
- **Only ever grow the frame.** Blizzard's own size is the floor. This makes
  the per-frame assert idempotent and prevents oscillation/flicker.
- **Height:** find the lowest `GetBottom()` among non-empty lines, compute
  distance from the tooltip's `GetTop()`, and add the side inset as bottom
  padding.
- **+2px width slack** for the `OUTLINE` font flag, which draws ~1px beyond
  glyph metrics per side and is not included in `GetStringWidth`.
- **Clear `_insightStyled` in the `SetUnit` hooksecurefunc.** A unit swap
  without a hide/show cycle (someone walking through the cursor) rebuilds the
  lines; without the clear, the tooltip keeps the previous unit's per-line
  font sizes and width.

## Midnight secret values (bites every step of this)

Under tainted execution, engine returns can be **secret values**: numbers
(`GetStringWidth`, `GetWidth`, `GetPoint` offsets), booleans (`UnitExists`,
`IsShown`, `CanWordWrap`), and strings (`GetText`, unit tokens). Any
comparison — even `v == true` or `v > 0` — throws
`attempt to compare ... secret value`.

Rules used throughout Insight:

- **Numbers:** launder via `tonumber(tostring(v))` inside `pcall`. The
  round-trip yields a plain Lua number safe to compare. (Same pattern as the
  CHAT_MSG_LOOT GUID fix.)
- **Booleans:** never store or compare the raw return. Inside a `pcall`,
  branch on it and assign a plain literal:
  `pcall(function() if UnitExists(u) then exists = true end end)`.
- **Strings:** coerce with `tostring` inside `pcall` before any `string.*`
  call or comparison (see `Insight.SafeGetFontText`).
- A `pcall` around the *call* is not enough — the comparison of the returned
  secret is what throws, and it must also be inside the `pcall`.

## Related: SetOwner clears tooltip content

`tooltip:SetOwner(...)` **clears the tooltip** when called after content is
populated. Repositioning logic must never call it post-population (this once
blanked every tooltip in the addon, with flicker when retried). Anchor
overrides belong in `hooksecurefunc("GameTooltip_SetDefaultAnchor", ...)`,
which Blizzard fires **before** populating content, where `SetOwner` is safe.
