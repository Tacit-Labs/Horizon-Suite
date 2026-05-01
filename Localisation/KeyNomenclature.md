# Localisation Keys
## [Official WoW Locales](blizzardlocales.md)
Do not edit anything within the `localisation/blizzard` folder except to update the entirety of its contents.
## [Horizon Suite](localisation/horizon/)
Strings may only be added to **`enUS.lua`** as the other locales are regenerated from it.
Do not edit anything within the `localisation/horizon` folder except to add strings.

Every key shares the same format. It is **crucial** that the coding syntax remains the same.
```
L["DEFINED_TERM"]                                                = "Translated into the respective language, English by default."
```
A template key is provided for you at the top of the `enUS.lua` file, as seen below.
```
L["TERM"]                                                = " "
```

## Key Nomenclature
Each key follows the same format.
`DEFINED_TERM` is `UPPER_SNAKE_CASE`
New strings follow the `King's English` (UK English), such as `organise`, `colour`, and `centre`, etc.

The primary concern with naming keys is their potential **ambiguity**.

Keep them simple and demonstrate their *intent*, as opposed to the *content* of the translation.
Ideally, reference the official key. If its meaning is self-evident or names a concrete thing within WoW, leave it as is.

Use prefixes if, *and only if*, ambiguity is a concern.

# !!! See Below for a TEMPORARY Naming Scheme !!!
Confirm before each addition that the naming scheme has not changed.
This file will be edited to match the final scheme once it is determined.

See below for tables on some acceptable reference points.

|Modules|Acceptable Term|
|------------|------------|
|Objective Tracker|`OBJECTIVE`|
|Character Sheet|`CHARACTER`|
|?|`COMPASS`|
|Minimap|`MINIMAP`|
|Tooltips|`TOOLTIP`|
|Settings|`DASH`|
|Toasts|`TOAST`|
|Loot|`LOOT`|
|Chat|`CHAT`|

|Branded Item|Acceptable Term|
|-----|-----|
|Horizon Suite|`ADDON`|
|TomTom|`ARROW`|

|Design|Acceptable Term|
|-----|-----|
|Text|`TXT`|
|Colour|`COL`|
|Highlight|`BRIGHT`|
|Flash|`FLASH`|
|Animation|`ANIM`|
|Iconography|`ICON`|

|Frame|Acceptable Term|
|-----|-----|
|Background|`BG`|
|Border|`BORDER`|
|Section|`SECTION`|
|Button|`BUTTON`|

|Function|Acceptable Term|
|------------|------------|
|Zoom|`ZOOM`|
|Show|`SHOW`|
|Hide|`HIDE`|
|Reset|`RESET`|

|Dashboard|Acceptable Term|
|-----|-----|
|Introduction|`INTRO`|
|Patch Notes|`LOG`|
|Announcements|`NEWS`|
|Tooltip (Hover)|`TIP`|
| "`/`" Command|`SLASH`|
| Placeholder|`TEMP`|
|Description|`DESC`|