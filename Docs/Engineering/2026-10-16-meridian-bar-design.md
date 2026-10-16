# Horizon Meridian: an info bar for the suite

**Date:** 2026-10-16
**Status:** Design approved; phase 1 plan in `2026-10-16-meridian-bar-plan.md`
**Module:** Meridian (new, eighth module)

## Goal

Meridian is a thin strip along the top or bottom edge of the screen that puts what Horizon already knows within one glance and one click: the time, your gold and durability, the quest you are following, your keystone, unread chat, and shortcuts into the rest of the suite.

In simple terms: a Titan Panel-style bar, but built only from Horizon's own pieces and styled to match them.

## Locked decisions

| Decision | Choice |
|----------|--------|
| Scope | Horizon-only hub. No LibDataBroker host; third-party feeds are out of scope |
| Packaging | New module `meridian` ("Horizon Meridian"), its own toggle under Axis → Modules, off by default |
| Brand colour | Pale gold `#E8D9B5`: the only low-saturation colour in the set, so it reads apart from every module and from Core's patch-note orange `#FF8C42` |
| Placeholder | Meridian already exists as a "Coming soon" dashboard entry whose copy described a compass module. The bar takes the name; that copy is rewritten in all seven locales |
| Form | Full-width edge strip, top by default, bottom as an option, with optional auto-hide |
| Bar style | Setting `meridianStyle`: `strip` (default) or `capsules`. Both draw the same blocks |
| Block look | Icon plus value. The label lives in the tooltip |
| Layout | Each block toggled on or off and given a side (left, centre, right) and an order, all from Axis. No dragging on the bar |
| Vista overlap | Meridian takes over. When Meridian owns a block, Vista hides its copy |
| Screen space | Overlays the world. Never moves Blizzard frames |
| Approach | Block registry that modules feed, delivered in three phases |
| Clients | Retail and Forever, gated through `addon.Platform` capability keys |

## Architecture

New module at `modules/Meridian/`, loaded in the TOC after the other modules.

| File | Job | Depends on |
|------|-----|-----------|
| `MeridianModule.lua` | `addon:RegisterModule("meridian", …)`; `OnEnable` builds the bar, `OnDisable` tears it down | core |
| `MeridianRegistry.lua` | `addon.Meridian.RegisterBlock(def)`, gating, ordering, `addon.Meridian.Owns(id)` | Platform |
| `MeridianBar.lua` | The strip frame, the two styles, left/centre/right sections, block layout | Registry |
| `MeridianAutoHide.lua` | Edge hover zone, slide in and out, combat visibility | Bar |
| `blocks/MeridianBlocksTime.lua` | Clock | Registry |
| `blocks/MeridianBlocksWorld.lua` | Coordinates, performance | Registry |
| `blocks/MeridianBlocksCharacter.lua` | Gold, durability, bags | Registry |
| `blocks/MeridianBlocksNotices.lua` | Mail, queue | Registry |
| `blocks/MeridianBlocksActions.lua` | Horizon menu, teleports | Registry, Vista (optional) |

Phase 2 blocks are registered by their owning modules, not by Meridian, so they live beside the code they read (for example `modules/Focus/FocusMeridian.lua`). `MeridianRegistry.lua` and `MeridianFormat.lua` load in the TOC straight after the core files, before any module, so those files always find the registry.

Settings follow the existing pattern: `options/modules/OptionsMeridian.lua` and `options/modules/defaults/OptionsDefaultsMeridian.lua`. Keys are `meridianEdge`, `meridianStyle`, `meridianAutoHide`, `meridianKeepShownOutOfCombat`, `meridianCombat`, and per block `meridianBlock_<id>_enabled`, `meridianBlock_<id>_side`, `meridianBlock_<id>_order`.

### Block definition

Field names follow LibDataBroker's (`text`, `icon`, `OnClick`, `OnTooltipShow`) so that hosting third-party feeds stays cheap if it is ever wanted. Nothing else about LibDataBroker is built.

```lua
addon.Meridian.RegisterBlock({
    id            = "clock",
    label         = L["MERIDIAN_BLOCK_CLOCK"],
    icon          = "Interface\\AddOns\\HorizonSuite\\media\\meridian\\clock",
    text          = function() return ... end,     -- string, or nil to hide (contextual)
    events        = { "PLAYER_ENTERING_WORLD" },   -- refresh on these
    tick          = 1,                             -- or refresh on the shared ticker, in seconds
    OnClick       = function(self, button) ... end,
    OnTooltipShow = function(tooltip) ... end,
    module        = nil,                           -- owning module key; block hidden when it is off
    requires      = nil,                           -- Platform capability key, e.g. "mythicPlus"
    defaultSide   = "centre",
    defaultOrder  = 10,
    defaultOn     = true,
})
```

- A block whose `module` is disabled, or whose `requires` capability is false, gets no slot.
- A block whose `text()` returns nil is contextual: it takes no space until it has something to show.
- Tick-driven blocks share one throttled ticker; the bar never runs one `OnUpdate` per block.

### Handover from Vista

`addon.Meridian.Owns(id)` returns true only when Meridian is enabled, its bar initialised, and that block is enabled. Vista calls it in `ApplyOptions_Texts` and in its mail and queue setup for the ids `clock`, `coords`, `performance`, `mail` and `queue`, and hides its own element when it gets true. Meridian calls `addon.Vista.ApplyOptions()` after it enables or disables a block that Vista also draws, so the handover happens without a reload.

With Meridian off, Vista behaves exactly as today. Vista's crafting-order indicator is not handed over.

Three details from the code survey (2026-10-16):

- **Queue.** Vista draws no queue indicator of its own: it reparents Blizzard's `QueueStatusButton`. When Meridian owns `queue`, Vista treats its queue handling as switched off, and Meridian hosts the same button in its block. When Meridian lets go, Vista re-attaches it, or, with Vista off, Meridian puts it back where it found it. Reparenting happens out of combat only.
- **Mail.** Vista suppresses Blizzard's mail icon for the session. With Meridian owning `mail`, Meridian's block is the only mail indicator.
- **Enable order.** Modules enable in no fixed order, and `addon:IsModuleEnabled` turns true only after a module's `OnEnable` returns. So `Owns` reads Meridian's own `_active` flag, and the `module` and `requires` gates are evaluated at every layout, never once at enable.

## Look and behaviour

- **Block:** icon plus value. Module blocks tint their icon with the module's brand colour (Focus `#ffd133`, Echo `#8fa3e8`). The Axis class-tint toggle applies to Meridian like every other module.
- **Strip style:** full-width dark band with a 1px pale-gold line on its inner edge.
- **Capsules style:** transparent band; the left, centre and right sections each sit in a soft rounded pill.
- **Size:** 26px tall, scaled by `addon.GetModuleScale("meridian")`: the global Horizon scale, or `meridianUIScale` when per-module scaling is on (a new slider beside the others in Axis).
- **Auto-hide:** off by default. When on, the bar collapses to a 2px pale-gold line. Hovering a 4px zone at that edge slides it in; it slides out 1.5s after the mouse leaves. "Keep shown out of combat" holds it open whenever you are not in combat.
- **Combat visibility:** show, fade or hide, with Meridian's own keys (`meridianCombat`, `meridianCombatFadeOpacity`) and the same wording as Focus. "Hide" hides the bar for the whole fight, hover included.
- **Fonts:** Horizon's font pipeline, including SharedMedia.
- **Mouse:** hover shows a Horizon-styled tooltip with the block's label and detail. Left-click runs the block's main action. Right-click offers "Hide this block" and "Meridian settings".
- **Combat-locked actions:** where Blizzard blocks an action in combat (Vista's secure teleport buttons, opening some panels), the tooltip says "Not available in combat" and the click does nothing.

Block icons are white monoline glyphs (`tools/icons/meridian/*.svg`, rendered by `tools/make_module_icons.py --src tools/icons/meridian --out media/meridian`) and tinted per block.

Mockups of both styles and the auto-hidden line were reviewed in the design session on 2026-10-16.

## Block catalogue

Contextual blocks are marked; they hide when there is nothing to show.

| Phase | Block | Default | Shows | Left-click | Gate |
|---|---|---|---|---|---|
| 1 | Horizon | left, on | Dawn mark | Opens the dashboard (`addon.ShowDashboard`); right-click lists module toggles | none |
| 1 | Clock | centre, on | Local or realm time, 12 or 24 hour, from Meridian's own keys (`meridianClockLocal`, `meridianClock24Hour`), seeded from Vista's choices on first enable | Stopwatch; tooltip shows daily and weekly reset | none |
| 1 | Coordinates | right, on | Player map coordinates | none | hidden where the map gives none |
| 1 | Performance | right, on | FPS and latency | none | none |
| 1 | Gold | right, on | Gold carried; tooltip shows this session's change | Opens bags | none |
| 1 | Durability | right, on | Lowest equipped slot % | Opens the character panel (Essence when it is on) | none |
| 1 | Bags | right, on | Free bag slots | Opens bags | none |
| 1 | Mail | right, contextual | Icon; tooltip lists senders | none | none |
| 1 | Queue | right, contextual | Blizzard's own queue button, hosted in the block | Blizzard's own (status, right-click menu) | none |
| 1 | Teleports | left, off | Icon | Opens Vista's teleport menu | `vista` on |
| 2 | Quest | left, on | Super-tracked quest and its progress | Opens it on the map | `focus` on |
| 2 | Keystone | left, contextual | Your key, or the live timer inside a key | Opens the Mythic+ tab | `mythicPlus`, `focus` on |
| 2 | Dungeon run | left, contextual | Gold per hour | none | `focus` on |
| 2 | Echo | left, contextual | Total unread messages | Opens the latest unread conversation | `echo` on |
| 2 | Great Vault | right, off | Unlocked slots, x/9 | Opens the Vault | `weeklyVault` |
| 3 | Addon buttons | right, on | Icon | Opens the button collector drawer under the block | none |

Phase 2 sources already exist and need only a public getter each: Focus `GetMplusData`, `GetMplusTimer` and `GetDungeonRunData` (`modules/Focus/scenarios/`), Echo's per-conversation `conv.unread`, and Augment's vault, bag and durability checks (`modules/Augment/Alerts/`).

## Phases

Each phase is its own pull request and can be released alone.

1. **Shell and basics.** Module, registry, bar, both styles, auto-hide, settings page, phase 1 blocks, and the Vista handover for clock, coordinates, performance, mail and queue.
2. **Module readouts.** A public getter in Focus, Echo and Augment, and each module registering its blocks.
3. **Button collector.** Extract the collector (about 1,300 lines, roughly `VistaCore.lua` 3160 to 4400) into a shared component that both the minimap and the bar can render, then add the Addon buttons block and hand the collector over.

Phase 3 carries the most risk, because the collector is tightly coupled to Vista's locals. It goes last so it holds nothing else back, and it gets its own plan.

## Error handling

- Every `text()` and `OnTooltipShow` call is wrapped in `pcall`. A failing block shows "–" and the rest of the bar keeps working. It logs once through `core/Logger.lua`, which is silent outside dev builds.
- Events are registered through `pcall`, because an event one client lacks would otherwise error at registration.
- `Owns(id)` is the only coupling to Vista. If Meridian fails to initialise, `Owns` returns false and Vista keeps its elements, so nothing disappears from both places.
- No frame changes that could taint happen in combat. Layout changes made in combat wait for `PLAYER_REGEN_ENABLED`.

## Testing

Logic tests in `tools/test_meridian_logic.js` on the existing fengari harness (`NODE_PATH="$HOME/.cache/hs-test/node_modules"`):

- Registry: gating by module and by capability, ordering within each side, contextual blocks dropping out, pcall isolation.
- `Owns()`: every combination of Meridian on or off and block on or off.
- Auto-hide state machine: hover in and out, the 1.5s delay, combat show, fade and hide, and "keep shown out of combat".
- Defaults: every `meridian*` key has a default, the same check `tools/test_options_logic.js` makes for the other modules.

In game, on the Windows PC: a Retail and a Forever pass for each phase, and an `/update-card` before and after once each phase merges.

## Out of scope

- Hosting LibDataBroker feeds from other addons.
- Dragging blocks on the bar itself.
- Gold totals across characters (needs saved per-character data).
- Moving Vista's crafting-order indicator.
