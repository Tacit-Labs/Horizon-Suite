# Adding a Module

`addon:RegisterModule` ([HorizonSuite.lua:24](../../HorizonSuite.lua)) puts a module
in the runtime registry. Nothing in the Axis dashboard reads that registry to
build its UI.

Instead, around twenty separate hardcoded lists of module keys do: the Module
Toggles row, the sidebar group order, the search filter, the Home tiles, the
module guide, and a colour map in each of three different files. A module missing
from one of them is simply absent from that surface. There is no error, no
warning, and no Lua failure, because every one of those lists is read by key and
falls back silently to nil, to a neutral grey, or to the question-mark icon.

That is the trap this page exists to close. Work the checklist down.

The concrete examples below use **Essence**, because it is the most recently
added module on `main` and every one of its edits can be read in place. The
checklist itself was compiled while adding **Flow**, the quest box module, which
was registered and loading and invisible to the player in every surface at once.

---

## 1. The module itself

Pick a lowercase, single-word module key (`essence`, `vista`, `insight`). The key
is the identifier everywhere below. The Proper Case form (`Essence`) is the brand
name and the directory name.

|Step|Where|Notes|
|-|-|-|
|Create the module directory|`modules/<Module>/`|Split by concern, one file per area, in the house style of `modules/Essence/` or `modules/Insight/`.|
|Register the module|`modules/<Module>/<Module>Module.lua`|`addon:RegisterModule("<key>", { title, description, order, OnInit, OnEnable, OnDisable })`. Guard the file with `if not addon or not addon.RegisterModule then return end`.|
|Add a slash handler|`modules/<Module>/<Module>Slash.lua`|Optional. `addon.RegisterSlashHandler("<key>", handler)` is a real registry, so no central list needs editing. `addon.RegisterSlashHandlerDebug` and `addon.RegisterDebugLive` work the same way.|
|List every new file|`HorizonSuite.toc`|Load order is the file order. Module files go in the `modules/` block. See section 6 for the options-side ordering rule.|

`order` in the `RegisterModule` table only affects `addon:IterateModules()`. It
does **not** order the dashboard sidebar; that is `groupOrder` in section 4.

---

## 2. Settings and the options category

|Step|Where|Symbol|
|-|-|-|
|Declare defaults, limits and routing keys|`options/modules/defaults/OptionsDefaults<Module>.lua`|`addon.<MODULE>_KEYS`, `addon.<MODULE>_DEFAULTS`, `addon.<MODULE>_LIMITS`|
|Build the options category|`options/modules/Options<Module>.lua`|Appends to `addon.OptionCategories` with `key = "<Module>"`, `moduleKey = "<key>"`|
|Dispatch setting changes back to the module|`options/OptionsData.lua`|Add the `<MODULE>_KEYS` arm to `OptionsData_SetDB`|

The dispatch arm follows the existing shape exactly:

```lua
if addon.ESSENCE_KEYS and addon.ESSENCE_KEYS[key] and addon.Essence and addon.Essence.ApplyEssenceOptions then
    addon.Essence.ApplyEssenceOptions()
end
```

**If you skip the dispatch arm**, every control in your options category appears
and saves correctly, and none of them changes anything on screen until a reload.

---

## 3. Names and strings

|Step|Where|Symbol|
|-|-|-|
|Brand name|`core/Config.lua`|`addon.BrandDisplay.module.<key> = L["NAME_ADDON_<THING>"]`|
|Plain-English name|`core/Config.lua`|`addon.BrandDisplay.simple.<key> = L["AXIS_MODULE_NAME_SIMPLE_<THING>"]`|
|Locale strings|`locales/horizon/enUS.lua`|Both keys above, plus every string your options category and guide entry use|

Both `BrandDisplay` maps are needed. `addon.GetModuleDisplayName`
([options/dashboard/DashboardUtil.lua](../../options/dashboard/DashboardUtil.lua))
reads `module` in the default naming mode and `simple` in the Subtitle and Simple
modes, so a module present in only one of them renders its raw lowercase key in
the other. `addon.BrandModule` and `addon.Dashboard_BrandModule` both delegate
here, so nothing else needs a per-module edit.

Only `enUS.lua` is required. The other locale files fall back to English. See
[Translate.md](Translate.md) and [locales/KeyNomenclature.md](../../locales/KeyNomenclature.md).

---

## 4. The dashboard, where the trap lives

Every row below is a separate hardcoded list. None of them derives from the
registry.

### The one that matters most

|Where|Symbol|Skipping it means|
|-|-|-|
|`options/modules/OptionsAxis.lua`|the `Modules` category toggle row, `dbKey = "_module_<key>"`|**The module cannot be turned on at all.** This row is the only user-facing switch. Do this one first.|

### Sidebar, search and labels

`options/dashboard/DashboardFrame.lua`:

|Symbol|Skipping it means|
|-|-|
|`moduleLabels`|The module's own label cache is empty, so the name falls back to the raw key in tiles and headers.|
|`PREVIEW_MODULE_KEYS`|No `(Preview)` tag. Set this for a new module; clear it when the module leaves preview.|
|`TILE_MODULE_LABEL_COLORS`|The Home tile label renders in neutral grey rather than the module's colour.|
|`categoryIcons`|Read as `categoryIcons[cat.key]`, so the key here is the **Proper Case category key** (`["Essence"]`), not the module key. Missing means the sidebar entry shows `INV_Misc_Question_01`, the question mark.|
|`SEARCH_MODULE_FILTER_GROUP_ORDER`|The module is absent from the search filter menu, so its settings cannot be filtered to.|
|`MODULE_LABELS`|The sidebar group has no label.|
|`groupOrder`|**The sidebar group is not built at all.** The module's whole options category is unreachable from the sidebar.|
|`MODULE_NAME_KEYS`|Switching the module name display mode does not relabel this module live; it needs a reload to pick the new mode up.|

### Home welcome cards

`options/dashboard/DashboardHomeWelcome.lua`:

|Symbol|Skipping it means|
|-|-|
|`MODULE_ORDER`|No Home tile for the module.|
|`MODULE_COLORS`|The card accent falls back. Match the hex to `PN_MODULE_COLORS` (below) so the palettes agree.|
|`MODULE_ICONS`|The card shows `INV_Misc_Question_01`, the question mark.|
|`MODULE_DESCS`|The card's description line is blank.|

### Module guide

`options/dashboard/DashboardModuleGuide.lua`:

|Symbol|Skipping it means|
|-|-|
|the `ApplyGuideBulletStatusTags` row list|No `(Preview)` or `(Coming Soon)` tag beside the module's name in guide bullets.|
|`GUIDE_MODULE_COLORS`|Keyed by **Proper Case name** (`["Essence"]`), not the module key. The module's name is not colourised in guide bullets, and the `ApplyGuideBulletStatusTags` row above becomes a no-op, because it looks the colour up here and does nothing when it is nil.|
|the accordion card, its body FontString, and its `layoutAccordionCard` call|No guide entry. All three go together; adding the card without the layout call leaves it unpositioned.|

### Patch notes

|Where|Symbol|Notes|
|-|-|-|
|`options/dashboard/DashboardPatchNotesContent.lua`|`PN_MODULE_COLORS`|Keyed by Proper Case name. Missing means the module's name is not colourised in patch notes. This is the palette the other two colour maps are meant to match.|

---

## 5. Class tint, saved variables and the rest

|Step|Where|Symbol|Notes|
|-|-|-|-|
|Class-tint toggle|`options/modules/OptionsGlobal.lua`|`classColorKeys` **and** the per-module toggle row|Two edits in one file. The list drives the master "all on / all off" row; the toggle row is the control itself.|
|Class-tint plumbing|none|`addon.GetModuleClassColor`|Derives the DB key as `"classColor" .. Capitalised`, so no edit is needed. Add `classColor<Module>` to your `<MODULE>_KEYS` table so changing it re-applies.|
|Saved-variable seed|`HorizonSuite.lua`|`EnsureModulesDB`|Two places: the first-install block, and a guard of the `if not db.modules.<key> then` shape for existing installs. `EnableModule` creates the entry on demand, so a toggle still works without this, but the key is then absent from `db.modules` until first toggled and so missing from any profile seeded in that window. Follow the pattern.|
|Blizzard globals|`.luacheckrc`|`read_globals`|Only if the module touches Blizzard globals the config does not already list. Run `luacheck .` to find out.|
|Feature summary|`README.md`|the module section|User-facing prose, sentence case headings.|
|Core help text|`core/CoreSlash.lua`|`ShowCoreHelp`, and the `Modules:` line in the debug help|Optional and already incomplete on `main`; Essence is missing from both. Add your module if it has slash commands worth advertising.|

---

## 6. Load order in the TOC

`HorizonSuite.toc` is read top to bottom, so these have to be in this relative
order:

1. `modules/<Module>/*.lua`, with `<Module>Module.lua` last in its own block, since it registers against the files above it.
2. `options/OptionsData.lua`.
3. `options/modules/defaults/OptionsDefaults<Module>.lua`, which exports `<MODULE>_DEFAULTS` and `<MODULE>_LIMITS`.
4. `options/modules/Options<Module>.lua`, which reads both of those at file scope and appends to `addon.OptionCategories`.

Getting 3 and 4 the wrong way round gives a nil index on `addon.<MODULE>_DEFAULTS`
at load, which is at least loud. The rest of the checklist is silent.

---

## 7. Verifying

Grep is the honest check. Pick an established module key and see where it
appears but yours does not:

```bash
grep -rn '"essence"\|essence *=' --include=*.lua core options HorizonSuite.lua \
  | grep -vi 'modules/Essence'
```

Every hit on that list is a site your module key probably also belongs in. Then
walk the UI in-game and confirm each of these:

- [ ] The toggle appears under Axis, Modules, and turns the module on.
- [ ] The sidebar has a group for the module, with a real icon rather than a question mark.
- [ ] The module's settings are reachable from the sidebar and from search, and the search filter lists the module.
- [ ] The Home screen shows a tile with the right icon, name, colour and description.
- [ ] The module guide has an entry, positioned correctly, with the module name colourised.
- [ ] Changing a setting applies it live, without a reload.
- [ ] The class-tint toggle appears under Global toggles and both the master row and the individual row respond.
- [ ] Switching the module name display mode relabels the module without a reload.
- [ ] `luacheck .` is clean.

---

## Worth fixing properly

Most of section 4 exists because the dashboard hand-maintains what
`addon:IterateModules()` ([HorizonSuite.lua:52](../../HorizonSuite.lua)) already
knows. The iterator returns every registered module key sorted by the `order`
field the module itself declares, which is exactly what `groupOrder`,
`MODULE_ORDER`, `SEARCH_MODULE_FILTER_GROUP_ORDER` and `MODULE_NAME_KEYS` are
each spelling out by hand.

The presentation data those lists carry, a colour, an icon, a preview flag, has
no home on the registry today, but it could: `RegisterModule` already takes a
definition table, and `title`, `description` and `order` live there. Moving
`color`, `icon` and `preview` alongside them would let the dashboard build its
lists from `IterateModules()` and reduce this checklist to registering the module
and writing its options.

Nobody has done that yet. It is a real refactor across `DashboardFrame.lua`,
`DashboardHomeWelcome.lua` and `DashboardModuleGuide.lua`, and it is not a
prerequisite for adding a module. Until it happens, this checklist is the
contract.
