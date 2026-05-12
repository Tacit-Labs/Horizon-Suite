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
Use `localisation` keys (`L["TERM"]`) within the code and add it to **`localisation/horizon/enUS.lua`**.
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