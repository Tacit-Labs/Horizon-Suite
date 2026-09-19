# Horizon Modules

|Module|Hex Code|
|---------|------------|
|Augment|<span style="color:#33CC66;">#33CC66</span>|
|Axis|<span style="color:#E0E0E0;">#E0E0E0</span>|
|Essence|<span style="color:#DC143C;">#DC143C</span>|
|Flow|<span style="color:#3399FF;">#3399FF</span>|
|Focus|<span style="color:#FFD133;">#FFD133</span>|
|Insight|<span style="color:#FF66B3;">#FF66B3</span>|
|Presence|<span style="color:#33FFDF;">#33FFDF</span>|
|Vista|<span style="color:#B366FF;">#B366FF</span>|

Core is not a module, but patch-note bullets use it for addon-wide changes and it
needs a colour of its own — without one those bullets rendered in body copy colour
and read as ordinary prose rather than as a labelled entry.

|Name|Hex Code|
|---------|------------|
|Core|<span style="color:#FF8C42;">#FF8C42</span>|

# Client flavours

A patch-note bullet that only one client can observe carries the flavour in its
prefix, as `Core (Forever):`. These sit deliberately outside the module palette:
the flavour says who can see the change, so it must not read as another module
name. Warm for the vanilla-era client, cool for the modern one.

|Flavour|Hex Code|
|---------|------------|
|Retail|<span style="color:#5B9BD5;">#5B9BD5</span>|
|Forever|<span style="color:#C8A055;">#C8A055</span>|

Neither badge carries art yet. `PN_FLAVOUR_ICONS` in
`options/dashboard/DashboardPatchNotesContent.lua` holds one string per flavour for
an inline atlas or a bundled texture, and is empty until the art has been confirmed
to render on both clients.
