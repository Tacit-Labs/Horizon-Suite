# Branch, File, and Folder Nomenclature
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
See [**Key Nomenclature**](KeyNomenclature.md) for more information.

---