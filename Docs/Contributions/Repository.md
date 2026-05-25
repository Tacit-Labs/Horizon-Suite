# Repository

The `main` branch is **strictly** for releases.
The `dev` branch is where all code changes will go before entering the next release from main.

All PRs should be directed to `dev` and will require a review from a staff-member.
Nobody can approve their own PR on the dev branch except for extenuating circumstances.
These circumstances include, but are not limited to, urgency that does not warrant a `hotfix/` branch and excess lack of activity from other developers.

## Issues

Try to make the title brief but informative.
Do not use complete sentences and make sure to apply the correct type and appropriate labels.

|Type|Purpose|
|------|----------|
|**<span style="color:#941d1b;">Bug</span>**|An unexpected problem or behaviour|
|**<span style="color:#4d5356;">Chore</span>**|Maintenance, upkeep, tooling, admin|
|**<span style="color:#d68f04;">Docs</span>**|Documentation additions or changes|
|**<span style="color:#2ba843;">Feature</span>**|New, big-ticket functionality|
|**<span style="color:#0f4caa;">Improvement</span>**|Quality of life, betterment to existing functionality|
|**<span style="color:#ae4f1a;">Localisation</span>**|Translations and locale work|
|**<span style="color:#40158e;">Refactor</span>**|Code restructuring, no behaviour change|

<br>

|Priority Label|Purpose|
|-----------------|----------|
|<span style="color:#E11D48;">Critical</span>| **`BLOCKED`** from use of the game or AddOn. `Handle as soon as possible.`|
|<span style="color:#F97316;">High</span>| **`DISRUPTIVE`** to the game or AddOn. `Handle at next earliest convenience.`|
|<span style="color:#EAB308;">Medium</span>| **`NOTICEABLE`** within the game or AddOn. `Handle when available.`|
|<span style="color:#3B82F6;">Low</span>| **`PRESENT`** in the game or AddOn. `Handle if time permits.`|

<br>

|Module Label|Purpose|
|-----------------|----------|
|<span style="color:#E0E0E0;">Axis</span>| Core and Dependencies/Data |
|<span style="color:#33CC66;">Cache</span>| Loot Toasts and Bags |
|<span style="color:#DC143C;">Essence</span>| Character Sheet |
|<span style="color:#3399FF;">Flow</span>| Chat and Social |
|<span style="color:#FFD133;">Focus</span>| Objective Tracker |
|<span style="color:#FF66B3;">Insight</span>| Tooltips |
|<span style="color:#B5F3C9;">Meridian</span>| `[?]` Navigation/Compass |
|<span style="color:#33FFDF;">Presence</span>| Notifications |
|<span style="color:#B366FF;">Vista</span>| Minimap |

<br>

**To be used with `Chore`**:
|Upkeep Label|Purpose|
|-----------------|----------|
|<span style="color:#00C98E;">Administration</span>|Repository Tidiness & Optimization|
|<span style="color:#8FEEE7;">Maintenance</span>|Data Management & Processing|

<br>

## Branches

In `lower-kebab-case`, prefix your branch with its associated issue type.
Be concise in branch naming.

<br>

|Issue Type|Branch|Purpose|
|-------------|---------------|----------|
|**<span style="color:#941d1b;">Bug</span>**|**`fix`** `/`|*addresses* an unexpected problem/behaviour|
|**<span style="color:#4d5356;">Chore</span>**|**`chore`** `/`|*preserves* base functionality for posterity|
|**<span style="color:#d68f04;">Docs</span>**|**`docs`** `/`|*records* information in an `*.md` file|
|**<span style="color:#2ba843;">Feature</span>**|**`feature`** `/`|*introduces* a new functionality|
|**<span style="color:#0f4caa;">Improvement</span>**|**`improvement`** `/`|*enhances* existing functionality|
|**<span style="color:#ae4f1a;">Localisation</span>**|**`localisation`** `/`|*translates* locale strings|
|**<span style="color:#40158e;">Refactor</span>**|**`refactor`** `/`|*revises* code without a behavioural change||
||||
|<span style="color:#FF0000;">EMERGENCIES</span>|**`hotfix`** `/` |*restores* a broken function **[GAME-BREAKING]**|


<br>
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
