# 🌌 Horizon Suite

CurseForge Game Versions CurseForge Version

CurseForge Downloads Discord

[Patreon](https://www.patreon.com/c/HorizonSuite) [Ko-fi](https://ko-fi.com/horizonsuite) 

**Horizon Suite** is a core addon with pluggable modules: **Focus** (objective tracker), **Presence** (zone text & notifications), **Insight** (cinematic tooltips), **Vista** (minimap), and **Cache** (loot toasts). Designed for the Midnight era—clean, cinematic, player-in-control. It replaces static, cluttered lists with a fluid interface that grants you total agency over your goals. Additional suites will appear as modules in the same options panel.

---

## 🎯 Focus (Objective Tracker)

Focus - Objective Tracker

- **Smart zone tracking** – Nearby quests float to the top; list updates as you move. Delves, scenarios, raids, and world events get their own sections with progress bars and timers. Zone event quests appear in Events in Zone before you enter; once you step in, they move to the Current Event section. World quests you're actively doing also appear in Current Event.
- **Events in Zone section** – Turn it off under Focus → Sorting & Filtering → Grouping to hide nearby unaccepted and zone-event quests from the tracker (like turning off world quests for content you have not accepted).
- **Track what matters** – Achievements, Endeavors (housing), Decor, tracked transmog appearances, Recipes (professions), and Traveler's Log objectives appear in the tracker. Full achievement progress tracking with criteria parsing and quantity strings. One-click to open achievement panel, housing dashboard, decor catalog, the Appearances wardrobe for a tracked look (Shift+click opens the map to the source), or Adventure Guide. Under Appearances, you can use the in-game transmog list icon for every row instead of each item's icon.
- **Recipe reagents** – By default, tracked recipes show a compact shopping list (Basic reagent slots only, first item per slot—similar to typical AH shopping flows). Enable **Full reagent detail** under Focus → Recipes to list optional and finishing sections, every choice variant, and non-Basic reagents. With **Auctionator** and the Auction House open, the magnifying glass runs a shopping search; **right-click** it to enter how many crafts you want and multiply every line’s quantity.
- **Rare boss alerts** – Super-track nearby rares with one click and optional audio alerts.
- **Live quest sync** – World quests, dailies, and weeklies update dynamically. Quests auto-track when you accept them. Choose a radar icon for auto-tracked in-zone entries.
- **Objective progress colours** – Optional gold and green tint on the whole X/Y token, including the slash (not started stays the normal objective colour).
- **Prey section** – Midnight hunting activities (Prey hunts) appear in a dedicated Prey section with distinct colours, separate from weeklies.
- **All The Things integration** – Collection data appears directly in your objectives.
- **Profiles** – Create, switch, copy, and delete named profiles. Per-character, per-specialization, or global (account-wide) modes. Import and export profiles as shareable text strings.
- **Combat-ready** – Show, fade, or hide in combat; show or hide in dungeons/raids/BGs; compact or super-minimal layouts.
- **Show only on mouseover** – Fade the tracker when not hovering; move the mouse over it to reveal.
- **Mythic+ and Delves** – Banner for keystone info, timer, and affixes. Delve objectives in the standard layout.
- **Countdown timers by section** – With **Show timer** on, toggle countdowns separately for **Scenarios**, **World Quests**, and **Dailies / Weeklies** (other timed quest log entries use the same switch as dailies and weeklies).
- **Classic click behaviour** – Optional toggle: left-click opens the quest map, right-click shows share/abandon menu. When off, Shift+Left opens or closes quest details; Ctrl+Right shares the quest with your party.

## 🎬 Presence (Zone Text & Notifications)

Presence - Zone Text & Notifications

- **Cinematic notifications** – Replaces Blizzard's default zone text, level-up banner, boss emote frame, and achievement alerts with styled toasts: smooth entrance and exit animations, a dividing line between title and subtitle, and an optional "Discovered!" third line on first visits.
- **Full notification coverage** – Zone entry, subzone changes, level-up, boss emotes, achievements, quest accepted/complete/progress, world quest accepted/complete, scenario start, scenario or delve complete, and scenario or delve objective updates — 13 types in total.
- **Per-type toggles** – Enable or disable each notification type individually. Mythic+ suppression silences zone, quest, and scenario notifications while inside a keystone dungeon.
- **Delve suppression** – Toggle to hide objective update popups while in a Delve. Zone entry and completion toasts still show.
- **Prioritised queue** – Up to five notifications queue when one is already playing; higher-priority events (level-up, boss emotes, achievements) play ahead of routine quest updates.
- **Visual customisation** – Vertical screen position, frame scale, and independent font types and sizes for title and subtitle. Entrance speed, exit speed, and hold-duration multiplier are all adjustable.

## 🗺️ Vista (Minimap)

Vista - Minimap

- **Square or circular minimap** – Choose a square or circular mask. Adjust size (100–400px), lock position, or drag to relocate. Optional auto zoom-out after zooming.
- **Zone text, coordinates, time, and FPS/latency** – Zone name, player coordinates, game time, and optional FPS/latency (ms) below the minimap. Each element has its own font, size, and colour; show or hide individually. Click the time to open the stopwatch.
- **Instance difficulty** – Difficulty name and Mythic+ keystone level shown when in an instance.
- **Mail and queue indicators** – New mail icon and queue status button appear automatically when relevant. Unlock the mail icon in options to drag and reposition it.
- **Built-in buttons** – Tracking and calendar buttons. Show always or on mouseover. Each is draggable and resizable; lock to prevent accidental movement.
- **Addon button collector** – Minimap buttons from other addons are grouped and presented in one of three modes: mouseover bar below the minimap, right-click panel, or floating drawer button. Per-addon filter to show only selected buttons.
- **Customizable appearance** – Border (thickness, colour, opacity), panel background and border colours for button panels, and per-element typography. SharedMedia support for fonts.
- **Mouse wheel zoom** – Scroll over the minimap to zoom in and out.

## 💎 Cache (Loot Toasts) - BETA

Cache - Loot Toasts

- **Cinematic loot notifications** – Items, money, currency, and reputation gains appear as styled toasts with quality-based colours and smooth slide-in animations.
- **Epic and legendary flair** – Extra entrance time, shine effects, and optional sounds for high-value loot.

## 🔍 Insight (Tooltips) - BETA

Insight - Tooltips

- **Cinematic tooltips** – Dark backdrop, class-colored player names and borders, faction icons, spec/role display, and fade-in animation.
- **Profile-backed settings** – Anchor mode (cursor or fixed) and position stored per profile.
- **Hide tooltips in combat** – Optional toggle under Insight → Global Tooltips to close styled tooltip frames during combat.

## 🎨 Visuals & UI Design

- **High-fidelity icons** – Distinct icons for Campaign, Legendary, and World Quests.
- **Customizable colours** – Per-category colour control (title, objective, zone, section). Panel backdrop colour and opacity.
- **Global Toggles (Axis)** – Under **Axis → Global Toggles**, enable class tint per module or all at once (dashboard, Focus, Presence, Vista, Insight, Cache, Essence), pick a **dashboard background** preset (flat Default, Midnight artwork, or **Specialisation (auto)** using Blizzard’s talent UI art for your current spec—with a short crossfade when you change preset or spec), choose **dashboard font** and **dashboard text size** for the settings window (independent of Focus typography), and set global UI scale (50–200%) or per-module scale sliders for Focus, Presence, Vista, Insight, and Cache.
- **Typography and spacing** – Fonts, sizes, outlines, and spacing sliders. Optional SharedMedia support for fonts from addon packs. Turn-in highlights and progress counts (e.g. 15/18) at a glance.
- **Progress bar** – Optional bar under objectives with numeric progress (e.g. 3/250). Configurable font, size, colours, and texture (SharedMedia support: Blizzard status bar, Solid, or addon packs). Filter to show for X/Y objectives (e.g. 3/10), percent-only objectives (e.g. 45%), or both.
- **Timer layout** – Bar below objectives, inline beside the title, or inline on its own line below the title.
- **Fluid motion** – Smooth entry/exit animations and a subtle pulse on objective completion.
- **Scroll indicators** – Optional fade or arrow buttons when the list has more content than visible.

---

## 📦 Modules & Roadmap

**Focus** is the objective tracker. **Presence** adds cinematic zone text and notifications. **Insight** adds cinematic tooltips with class colors, spec display, and faction icons. **Vista** adds a cinematic minimap (square or circular) with zone text, coordinates, time, optional FPS/latency, addon button collector, and full customisation. **Cache** adds cinematic loot toasts (items, money, currency, reputation). Enable them in options. More modules are planned: Quest Log, Combat Alerts, Unit Frames, Chat.

---

## 📥 Installation & Support

**Requirements:** World of Warcraft Retail (The War Within or later).

**Optional:** [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) (e.g. SharedMedia Additional Fonts) for expanded font choices in Typography and statusbar textures for progress bars. If not installed, the font dropdown shows only Game Font and any custom path you enter; progress bars use Solid texture. [RondoMedia](https://www.curseforge.com/wow/addons/rondomedia) by RondoFerrari for class icons in Insight tooltips and, when Dashboard class colours are on, for the Dashboard header class icon (Axis → Class Colours → Dashboard class icon style—separate from Insight).

1. Install via [CurseForge](https://www.curseforge.com/projects/1457844), [Wago](https://addons.wago.io/addons/jK8gY56y), or download the [latest release](https://gitlab.com/Crystilac/horizon-suite/-/releases) and extract the `HorizonSuite` folder. ([Beta](https://gitlab.com/Crystilac/horizon-suite/-/releases/beta))
2. Place it in `World of Warcraft\_retail_\Interface\AddOns\`.
3. Enable **Horizon Suite** in your AddOn list.
4. Open the **dashboard** (`/hsd`, the minimap button, or **Options** on the tracker).
5. **Welcome** is the first sidebar item with a short overview of each module (Preview items are labelled); **Quick Start** (under Welcome) explains Focus sections, Presence notifications, and each module in more detail. **Home** shows module tiles. Under **Axis** use **Global Toggles** (class colours and UI scale) or **Modules** (module on/off and minimap button). After your first visit, the dashboard opens on **Home** by default; **Welcome** and **Quick Start** stay in the sidebar.

[ko-fi](https://ko-fi.com/T6T71TX1Y1) **[Patreon](https://patreon.com/HorizonSuite?utm_medium=unknown&utm_source=join_link&utm_campaign=creatorshare_creator&utm_content=copyLink)** | **[Discord](https://discord.gg/nFabdZmvSB)** — Bug reports, feature requests, and community.

---

## 🤝 Contributing

**Issues** — [GitHub Issues](https://gitlab.com/Crystilac/horizon-suite/-/issues). Use the Bug report or Feature request template. Reports from Discord, Reddit, or CurseForge are welcome.

---

## 💖 Contributors

Thanks to everyone who has contributed to Horizon Suite:

- **feanor21#2847 — Panoramuxa (Tarren Mill -EU)** — Development
- Marthix — Development
- Swift — Coordinator
- Boofuls — Moderator
- **RondoFerrari** — [RondoMedia](https://www.curseforge.com/wow/addons/rondomedia) — Class icons in Insight tooltips and optional Dashboard header icon when class colours are on (optional)
- **Aishuu** — French localization (frFR)
- **아즈샤라-두녘** — Korean localization (koKR)
- **Linho-Gallywix** — Brazilian Portuguese localization (ptBR)
- **allmoon** — Chinese localization (zhCN)

---

## 🌐 Localizations

The addon UI is localized for:

- **Chinese (zhCN)** — `Localisation/zhCN.lua`
- **French (frFR)** — `Localisation/frFR.lua`
- **German (deDE)** — `Localisation/deDE.lua`
- **Korean (koKR)** — `Localisation/koKR.lua`
- **Brazilian Portuguese (ptBR)** — `Localisation/ptBR.lua`
- **Russian (ruRU)** — `Localisation/ruRU.lua`
- **Spanish (esES)** — `Localisation/esES.lua`

Contributions for additional locales are welcome — see **[TRANSLATING.md](TRANSLATING.md)** and Discord.

---

## License

Distributed under the MIT License. See `LICENSE` for more information.