# `Nomenclature` (Branches, Files, and Folders)
Use any alphanumeric character besides `spaces` (` `) or `underscores` (`_`).
Try to minimise the amount of symbols within file names.

**`Files`** must use **lowercase** with individual words and **ProperCase** with multiple words.
**`Branches`** must use **`lower-kebab-case`** (lowercase-words-connected-with-hyphens).

## Branch `Types` (Prefixes)
### Front-End
**`fix`** `/` *addresses* an unexpected problem/behaviour
**`feature`** `/` *introduces* a new functionality
**`enhancement`** `/` *improves* existing functionality
### Back-End
**`docs`** `/` *records* information in an `*.md` file
**`refactor`** `/` *revises* code without a behavioural change
**`chore`** `/` *preserves* base functionality for posterity
### EMERGENCIES ONLY
**`hotfix`** `/` *revives* a broken function
This is ***exclusively*** for game/AddOn-breaking bugs, not small fixes
<br>

---

# `Displayed Strings` (any visible to the end-user)
Use `localisation` keys (`L["TERM"]`) within the code and add it to **`locales/horizon/enUS.lua`**.
Every key shares the same format. It is **crucial** that the coding syntax remains the same.
```
L["DEFINED_TERM"]                                                = "Translated into the respective language, English by default."
```
A template key is provided for you at the top of the `enUS.lua` file, as seen below.
```
L["TERM"]                                                = " "
```

### Please mention in the commit and PR message if  `node tools/restructure_locales.js` was run.

See [**Key Nomenclature**](KeyNomenclature.md) for more information.
<br>

---

# `Pull Requests`
The `main` branch is **strictly** for releases.
The `dev` branch is where all code changes will go before entering the next release from main.

All PRs should be directed to `dev` and will require a review from a staff-member.
Nobody can approve their own PR on the dev branch except for extenuating circumstances.
These circumstances include, but are not limited to, urgency that does not warrant a `hotfix/` branch and excess lack of activity from other developers.

---

## `Debug / DEV_MODE`

The addon ships with a structured logger in `core/Logger.lua`. A compile-time flag controls whether debug features are active:

```lua
local DEV_MODE = false   -- must stay false in committed code
```

### What DEV_MODE enables

- All `addon.Log.debug / info / warn / error` calls fire and print to chat.
- Per-module live debug panels (scrolling log window) can be toggled via slash commands.
- The `/h debug logger` dump/clear commands become available.

### How to use it locally

1. Set `DEV_MODE = true` in `core/Logger.lua`.
2. Reload the UI (`/reload`).
3. Toggle a module's panel: `/h debug <module> debuglive`
   - Modules: `focus`, `presence`, `vista`, `cache`, `insight`, `essence`
   - `/h debug help` lists all commands and shows current DEV_MODE state.
4. The panel is a draggable scrolling window. Use **Copy** to export its contents and **Clear** to reset it.

### Pre-push hook (required setup)

A git hook prevents accidentally pushing `DEV_MODE = true` to remote. Set it up once after cloning:

```sh
cp scripts/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

If you try to push with `DEV_MODE = true` still set, git will abort with:

```text
ERROR: DEV_MODE = true in core/Logger.lua — set it back to false before pushing.
```

Simply set it back to `false`, reload to confirm everything still works, then push.

> Local commits with `DEV_MODE = true` are fine — the hook only blocks the push step.
