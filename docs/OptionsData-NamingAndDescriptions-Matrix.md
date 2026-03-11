# Options — Naming & Description Matrix

Reference for updating `OptionsData.lua`. **dbKey values never change.**

Only options that change are listed. Unlisted options keep their current name/desc.

---

## 1. Names

Drop "Enable", "Show", "Use" where the control type (toggle/dropdown) already implies it. Keep labels short — context comes from the section and category they sit in.


| Category  | Current name                                | Proposed name              |
| --------- | ------------------------------------------- | -------------------------- |
| Profiles  | Use global profile (account-wide)           | Global profile             |
| Profiles  | Enable per specialization profiles          | Per-spec profiles          |
| Profiles  | Create new profile from Default template    | New from Default           |
| Profiles  | Delete selected                             | Delete selected profile    |
| Modules   | Enable Focus module                         | Focus                      |
| Modules   | Enable Presence module                      | Presence                   |
| Modules   | Enable Vista module                         | Vista                      |
| Modules   | Enable Horizon Insight module               | Insight                    |
| Modules   | Enable Yield module                         | Yield                      |
| Panel     | Show scroll indicator                       | Scroll indicator           |
| Panel     | Show in dungeon                             | In dungeon                 |
| Panel     | Show in raid                                | In raid                    |
| Panel     | Show in battleground                        | In battleground            |
| Panel     | Show in arena                               | In arena                   |
| Panel     | Show only on mouseover                      | Mouseover only             |
| Panel     | Only show quests in current zone            | Current zone only          |
| Display   | Show quest count                            | Quest count                |
| Display   | Show header divider                         | Header divider             |
| Display   | Super-minimal mode                          | Minimal mode               |
| Display   | Show options button                         | Options button             |
| Display   | Show section headers                        | Section headers            |
| Display   | Show category headers when collapsed        | Sections when collapsed    |
| Display   | Show Nearby (Current Zone) group            | Current Zone group         |
| Display   | Show zone labels                            | Zone labels                |
| Display   | Show quest item buttons                     | Quest item buttons         |
| Display   | Show entry numbers                          | Entry numbers              |
| Display   | Show completed count                        | Completed count            |
| Display   | Show objective progress bar                 | Progress bar               |
| Display   | Use category color for progress bar         | Category color for bar     |
| Display   | Show timer                                  | Show timer                 |
| Display   | Timer display                               | Timer display              |
| Display   | Color timer by remaining time               | Color timer by remaining time |
| Display   | Use tick for completed objectives           | Checkmark for completed    |
| Display   | Show quest type icons                       | Quest type icons           |
| Display   | Show icon for in-zone auto-tracking         | Auto-track icon            |
| Display   | Show quest level                            | Quest level                |
| Display   | Dim non-focused quests                      | Dim unfocused entries      |
| Display   | Spacing between quest entries (px)          | Entry spacing              |
| Display   | Spacing before category header (px)         | Before section header      |
| Display   | Spacing after category header (px)          | After section header       |
| Display   | Spacing between objectives (px)             | Objective spacing          |
| Display   | Spacing below header (px)                   | Below header               |
| Behaviour | Focus category order                        | Category order             |
| Behaviour | Focus sort mode                             | Sort mode                  |
| Behaviour | Require Ctrl for focus & remove             | Ctrl for focus / untrack   |
| Behaviour | Use classic click behaviour                 | Classic clicks             |
| Behaviour | Require Ctrl for click to complete          | Ctrl to click-complete     |
| Behaviour | Keep campaign quests in category            | Keep campaign in category  |
| Behaviour | Keep important quests in category           | Keep important in category |
| Behaviour | Permanently suppress untracked quests       | Blacklist untracked        |
| Delves & Dungeons | Show scenario events                        | Scenario events            |
| Delves & Dungeons | Hide other categories in Delve or Dungeon   | Delve/Dungeon only         |
| Delves & Dungeons | Show affix names in Delves                  | Delve affix names          |
| Delves & Dungeons | Cinematic scenario bar                      | Scenario bar               |
| Content   | Show in-zone world quests                   | In-zone world quests       |
| Content   | Show rare bosses                            | Rare bosses                |
| Content   | Rare added sound                            | Rare sound alert           |
| Content   | Show achievements                           | Achievements               |
| Content   | Show completed achievements                 | Include completed          |
| Content   | Show achievement icons                      | Achievement icons          |
| Content   | Only show missing requirements              | Missing criteria only      |
| Content   | Show endeavors                              | Endeavors                  |
| Content   | Show completed endeavors                    | Include completed          |
| Content   | Show decor                                  | Decor                      |
| Content   | Show decor icons                            | Decor icons                |
| Content   | Show Traveler's Log                         | Traveler's Log             |
| Content   | Auto-remove completed activities            | Untrack when complete      |
| Content   | Show floating quest item                    | Floating quest item        |
| Content   | Lock floating quest item position           | Lock item position         |
| Content   | Floating quest item source                  | Item source                |
| Presence  | Show quest type icons on toasts             | Toast icons                |
| Presence  | Show discovery line                         | Discovery line             |
| Presence  | Show zone entry                             | Zone entry                 |
| Presence  | Show subzone changes                        | Subzone changes            |
| Presence  | Hide zone name for subzone changes          | Subzone only               |
| Presence  | Suppress zone changes in Mythic+            | Suppress in M+             |
| Presence  | Show level up                               | Level up                   |
| Presence  | Show boss emotes                            | Boss emotes                |
| Presence  | Show achievements                           | Achievements               |
| Presence  | Show quest accept                           | Quest accept               |
| Presence  | Show world quest accept                     | World quest accept         |
| Presence  | Show quest complete                         | Quest complete             |
| Presence  | Show world quest complete                   | World quest complete       |
| Presence  | Show quest progress                         | Quest progress             |
| Presence  | Show scenario start                         | Scenario start             |
| Presence  | Show scenario progress                      | Scenario progress          |
| Presence  | Enable animations                           | Animations                 |
| Vista     | Lock minimap position                       | Lock minimap               |
| Vista     | Circular minimap                            | Circular shape             |
| Vista     | Disable queue button handling               | Disable queue handling     |
| Vista     | Mail icon blink                             | Mail icon pulse            |
| Vista     | Manage addon minimap buttons                | Manage addon buttons       |
| Vista     | Lock drawer button position                 | Lock drawer button         |
| Vista     | Lock mouseover bar position                 | Lock mouseover bar         |
| Vista     | Always show mouseover bar (for positioning) | Always show bar            |
| Vista     | Lock right-click panel position             | Lock right-click panel     |
| Vista     | Mouseover bar — close delay (seconds)       | Mouseover close delay      |
| Vista     | Right-click panel — close delay (seconds)   | Right-click close delay    |
| Vista     | Floating drawer — close delay (seconds)     | Drawer close delay         |
| Insight   | Tooltip anchor mode                         | Tooltip anchor             |
| Insight   | Show status badges                          | Status badges              |
| Insight   | Show Mythic+ score                          | Mythic+ score              |
| Insight   | Show item level                             | Item level                |
| Insight   | Show mount info                             | Mount info                 |
| Insight   | Show transmog status                        | Transmog status            |
| Insight   | Show guild rank                             | Guild rank                 |
| Insight   | Show PvP title                              | PvP title                  |
| Insight   | Show honor level                            | Honor level                |


---

## 2. Descriptions

Short `desc` shown inline. Optional `tooltip` shown on hover for detail. "—" means no tooltip needed.


| Category   | Option                           | Short desc                                                                  | Tooltip                                                                             |
| ---------- | -------------------------------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Modules    | Focus                            | Objective tracker for quests, world quests, rares, achievements, scenarios. | —                                                                                   |
| Modules    | Presence                         | Zone text and notifications.                                                | —                                                                                   |
| Modules    | Vista                            | Minimap with zone text, coords, time, and button collector.                 | —                                                                                   |
| Modules    | Insight                          | Tooltips with class colors, spec, and faction icons.                        | —                                                                                   |
| Modules    | Yield                            | Loot toasts for items, money, currency, reputation.                         | —                                                                                   |
| Modules    | Global UI scale                  | Scale all UI elements (50–200%).                                            | Doesn't change your configured values, only the effective display scale.            |
| Modules    | Per-module scaling               | Separate scale slider per module.                                           | Overrides the global scale with individual sliders for Focus, Presence, Vista, etc. |
| Panel      | Scroll indicator                 | Hint when the list is scrollable.                                           | —                                                                                   |
| Panel      | Scroll indicator style           | Fade gradient or arrow.                                                     | —                                                                                   |
| Panel      | Combat visibility                | Show, fade, or hide in combat.                                              | —                                                                                   |
| Panel      | Combat fade opacity              | Tracker opacity while faded in combat.                                      | Only applies when Combat visibility is set to Fade.                                 |
| Panel      | Mouseover only                   | Fade out when not hovering.                                                 | —                                                                                   |
| Panel      | Current zone only                | Hide quests outside your current zone.                                      | —                                                                                   |
| Display    | Header count format              | Tracked vs in-log count.                                                    | Tracked/in-log or in-log/max. Tracked excludes world and in-zone quests.            |
| Display    | Sections when collapsed          | Keep section headers visible when collapsed.                                | Click a section header to expand that category.                                     |
| Display    | Current Zone group               | Dedicated section for in-zone quests.                                       | When off, in-zone quests appear in their normal category.                           |
| Display    | Progress bar                     | Bar under numeric objectives (e.g. 3/250).                                  | Only for entries with a single numeric objective where required > 1.                |
| Display    | Category color for bar           | Match bar to quest category color.                                          | When off, uses the custom fill color below.                                         |
| Display    | Show timer                       | Show countdown timer on timed quests, events, and scenarios.                  | When off, timers are hidden for all entry types.                                     |
| Display    | Timer display                    | Where to show the countdown: bar below objectives or text beside quest name. | Bar below or inline beside title. Disabled when timer bars are off.                  |
| Display    | Color timer by remaining time    | Green when plenty of time left, yellow when running low, red when critical.  | Disabled when timer bars are off.                                                    |
| Display    | Checkmark for completed          | ✓ instead of green for done objectives.                                     | —                                                                                   |
| Display    | Auto-track icon                  | Icon next to auto-tracked in-zone entries.                                  | For world quests and weeklies not in your quest log.                                |
| Typography | Progress bar text size           | Font size for bar label and bar height.                                     | Also affects scenario progress and timer bars.                                      |
| Behaviour  | Category order                   | Drag to reorder. Delves and Scenarios stay first.                           | —                                                                                   |
| Behaviour  | Ctrl for focus / untrack         | Prevent accidental clicks.                                                  | Ctrl+Left = focus/add, Ctrl+Right = unfocus/untrack.                                |
| Behaviour  | Classic clicks                   | L-click opens map, R-click opens menu.                                      | Off: L-click focuses, R-click untracks. Ctrl+Right shares.                          |
| Behaviour  | Ctrl to click-complete           | Require Ctrl to complete click-completable quests.                          | Only for quests that don't need NPC turn-in. Off = Blizzard default.                |
| Behaviour  | Keep campaign in category        | Campaign quests stay in Campaign when ready to turn in.                     | When off, they move to the Complete section.                                        |
| Behaviour  | Keep important in category       | Important quests stay in Important when ready to turn in.                   | When off, they move to the Complete section.                                        |
| Behaviour  | Auto-track accepted quests       | Track new quests from quest log automatically.                              | Does not apply to world quests.                                                     |
| Behaviour  | Suppress untracked until reload  | Hide untracked WQs/weeklies until reload.                                   | When off, they reappear when you return to the zone.                                |
| Behaviour  | Blacklist untracked              | Permanently hide untracked WQs/weeklies.                                    | Takes priority over suppress-until-reload. Accepting removes from blacklist.        |
| Delves & Dungeons | Scenario events                  | Track Delve, Dungeon, and scenario activities.                              | Delves appear in Delves section; dungeons in Dungeon; other scenarios in Scenario Events. |
| Delves & Dungeons | Delve/Dungeon only               | Show only the active instance section.                                      | Hides other categories while in a Delve or party dungeon.                           |
| Delves & Dungeons | Delve affix names                | Show affix names on first Delve entry.                                      | May not appear with full tracker replacements.                                      |
| Content    | In-zone world quests             | Auto-add WQs in your current zone.                                          | Off: only tracked or nearby WQs appear (Blizzard default).                          |
| Content    | Include completed (achievements) | Show completed achievements in the list.                                    | Off: only in-progress tracked achievements shown.                                   |
| Content    | Achievement icons                | Icon next to achievement title.                                             | Requires quest type icons to be enabled in Display.                                 |
| Content    | Traveler's Log                   | Tracked objectives from Adventure Guide.                                    | —                                                                                   |
| Content    | Untrack when complete            | Auto-untrack finished activities.                                           | —                                                                                   |
| Content    | Item source                      | Super-tracked first, or current zone first.                                 | —                                                                                   |
| Blacklist  | Blacklisted quests               | Quests hidden via right-click untrack.                                      | Enable "Blacklist untracked" in Behaviour to add quests here.                       |
| Presence   | Subzone only                     | Only show subzone name within same zone.                                    | Zone name still appears when entering a new zone.                                   |
| Presence   | Suppress in M+                   | Only boss emotes, achievements, and level-up.                                | Hides zone, quest, and scenario notifications in Mythic+.                           |
| Vista      | Manage addon buttons             | Collect and group addon minimap buttons.                                    | Groups them by the selected layout mode below.                                      |
| Vista      | Button mode                      | Hover bar, right-click panel, or drawer.                                    | —                                                                                   |
| Vista      | Always show bar                  | Keep bar visible for repositioning.                                         | Disable when done.                                                                  |
| Vista      | Right-click close delay          | Seconds before panel auto-closes. 0 = manual.                               | —                                                                                   |
| Vista      | Drawer close delay               | Seconds before drawer auto-closes. 0 = manual.                              | —                                                                                   |
| Vista      | Buttons per row/column           | Buttons before wrapping to next line.                                       | Left/right = columns; up/down = rows.                                               |
| Vista      | Expand direction                 | Direction buttons fill from anchor.                                         | Left/right = horizontal; up/down = vertical.                                        |
| Insight    | Show anchor to move              | Drag to set position, right-click to confirm.                               | —                                                                                   |
| Insight    | Status badges                    | Combat, AFK, DND, PvP, party, friends, targeting.                           | —                                                                                   |
| Insight    | Mount info                       | Mount name, source, and collection status.                                  | Shown when hovering a mounted player.                                               |


---

## 3. Sidebar category names


| Current               | Proposed      |
| --------------------- | ------------- |
| Minimap Addon Buttons | Addon Buttons |
| Blacklisted quests    | Blacklist     |
| Content Types         | Content       |


Section headings within categories stay as-is unless noted below:


| Category  | Current section | Proposed          |
| --------- | --------------- | ----------------- |
| Behaviour | Focus order     | Category order    |
| Panel     | Panel behaviour | Position & layout |


---

## 4. Implementation notes

- All changes are `name`/`desc` strings only. `dbKey` values are untouched.
- Add `tooltip` field to option descriptors where the description table above has a non-"—" tooltip value.
- Add `OnEnter`/`OnLeave` tooltip support to toggle, slider, dropdown, color, and button widgets in `OptionsWidgets.lua`.
- Update `OptionsData_BuildSearchIndex` to concatenate `desc` and `tooltip` for search text.
- New or changed L[] keys need entries in frFR, koKR, ptBR, ruRU locale files (leave untranslated until translators update).
