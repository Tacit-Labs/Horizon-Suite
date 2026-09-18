# Flow Quest Box Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship Flow v1 — a new Horizon Suite module that dresses the NPC quest dialogue window in Horizon chrome, puts objectives above the flavour text, and leaves every reward and acceptance call to Blizzard.

**Architecture:** `QuestFrame` stays the frame and stays inside `UIPanelWindows`. Flow strips its art, parents a `BackdropTemplate` chrome layer behind it, swaps the `elements` arrays on three `QUEST_TEMPLATE_*` tables so objectives render first, and draws its own objectives band from read-only quest API. One hook point, `hooksecurefunc("QuestInfo_Display", …)`, drives every repaint.

**Tech Stack:** WoW Lua 5.1, Interface 120100 (Retail) and 16001 (Forever), `BackdropTemplate`, `hooksecurefunc`, `UIFrameFadeIn`, `C_QuestLog`, existing Horizon `RegisterModule` / `OptionCategories` / `ResolveFontPath`.

**Spec:** `Docs/Engineering/2026-09-18-flow-quest-box-design.md`

## Global constraints

- Lua 5.1 only: no `goto`, no `//`, no native bitwise, no `require`
- Namespace in every new file: `local addon = _G.HorizonSuite` (86 of 89 module files use this; the `_HorizonSuite_Loading` alias is only for files loading before the global settles)
- Never call `AcceptQuest`, `DeclineQuest`, `CompleteQuest` or `GetQuestReward`
- Never call `Show`, `Hide` or `SetParent` on `QuestFrame`
- Never touch `QUEST_TEMPLATE_MAP_DETAILS` or `QUEST_TEMPLATE_MAP_REWARDS`
- Never set fonts on global font objects; set them on individual FontStrings
- Every styling pass runs under `pcall`; a Lua error must degrade to an ugly quest box, never an unusable one
- Module default state: `enabled = false`
- No `Platform.Has()` gating anywhere in Flow
- New locale keys go in `locales/horizon/enUS.lua` only
- `luacheck` must pass; new Blizzard globals go in `.luacheckrc` `read_globals`
- Branch from `main` as `feature/flow-quest-box`; squash-merge; PR body via `/pr`

---

## File map

| File | Responsibility |
|------|----------------|
| Create: `modules/Flow/FlowModule.lua` | `RegisterModule("flow", …)`, enable/disable lifecycle |
| Create: `modules/Flow/FlowCore.lua` | art stripping, chrome layer, fonts, entrance, hook install |
| Create: `modules/Flow/FlowTemplates.lua` | template copy, element reorder, restore |
| Create: `modules/Flow/FlowQuestBand.lua` | the objectives band and the lore expander |
| Create: `modules/Flow/FlowSlash.lua` | `/h flow`, `/h flow restore` |
| Create: `options/modules/defaults/OptionsDefaultsFlow.lua` | `FLOW_KEYS`, `FLOW_DEFAULTS`, `FLOW_LIMITS` |
| Create: `options/modules/OptionsFlow.lua` | `OptionCategories` entry |
| Modify: `HorizonSuite.toc` | new Flow load block after the Presence block |
| Modify: `HorizonSuite.lua` | seed `db.modules.flow`, existing-install guard |
| Modify: `core/Config.lua` | module display-name maps |
| Modify: `options/OptionsData.lua` | route `FLOW_KEYS` to `Flow.ApplyFlowOptions` |
| Modify: `.luacheckrc` | new Blizzard globals |
| Modify: `locales/horizon/enUS.lua` | new keys |
| Modify: `README.md` | Flow module section |

Load order inside the TOC block matters: `FlowTemplates` and `FlowQuestBand` must load before `FlowCore`, which calls into both.

---

### Task 1: In-game verification spike

Throwaway. No code is kept. Its output is a findings block appended to the design doc, which Tasks 4 and 5 read.

**Files:**
- Modify: `Docs/Engineering/2026-09-18-flow-quest-box-design.md` (append a "Spike findings" section)

**Interfaces:**
- Consumes: nothing
- Produces: confirmed values for element stride, material colour table name, Greeting panel routing, resize tolerance, and `GetQuestObjectives` behaviour on an offered quest

- [ ] **Step 1: Confirm the globals exist**

In-game, with no Horizon module changes loaded, run:

```
/run for _,n in ipairs({"QuestInfo_Display","QuestFrame_GetMaterial","MATERIAL_TEXT_COLOR_TABLE","MATERIAL_TITLETEXT_COLOR_TABLE","QUEST_TEMPLATE_DETAIL","QUEST_TEMPLATE_PROGRESS","QUEST_TEMPLATE_REWARD","QUEST_TEMPLATE_MAP_DETAILS"}) do print(n, tostring(_G[n])) end
```

Record which are `nil`. If `MATERIAL_TEXT_COLOR_TABLE` is nil, Task 3 uses the per-FontString fallback rather than the material path.

- [ ] **Step 2: Determine the element tuple stride**

```
/run local names={} for k,v in pairs(_G) do if type(v)=="function" and type(k)=="string" and k:find("^QuestInfo_") then names[v]=k end end local t=QUEST_TEMPLATE_DETAIL.elements for i=1,#t do local v=t[i] print(i, type(v)=="function" and (names[v] or "func?") or tostring(v)) end
```

Record the printed list verbatim. The stride is the index of the second function entry minus one. Repeat for `QUEST_TEMPLATE_PROGRESS` and `QUEST_TEMPLATE_REWARD`.

- [ ] **Step 3: Check whether the Greeting panel routes through `QuestInfo_Display`**

```
/run hooksecurefunc("QuestInfo_Display", function(t) print("display:", t==QUEST_TEMPLATE_DETAIL and "DETAIL" or t==QUEST_TEMPLATE_PROGRESS and "PROGRESS" or t==QUEST_TEMPLATE_REWARD and "REWARD" or "OTHER") end)
```

Then talk to an NPC offering several quests at once. If nothing prints while the greeting list is up, the Greeting panel is styled by Task 3's chrome pass only and never by the band.

- [ ] **Step 4: Check structured objectives for an offered quest**

Open a quest you have **not** accepted, then:

```
/run local id=GetQuestID() print("questID",id) local o=C_QuestLog.GetQuestObjectives(id) print("objectives",o and #o or "nil") if o then for i=1,#o do print(i,o[i].text,o[i].numFulfilled,o[i].numRequired) end end print("blob:",GetObjectiveText())
```

If the objectives table is non-empty, Task 5 renders bullets. If empty or nil, Task 5 uses the prose path only and the band still ships.

- [ ] **Step 5: Check resize tolerance inside UIPanel layout**

With a quest open:

```
/run QuestFrame:SetSize(420, 560)
```

Confirm the frame redraws, the panels still fill it, and opening the character sheet still tiles beside it rather than overlapping. Then `/reload`. Record the largest size that behaved.

- [ ] **Step 6: Repeat Steps 1, 2 and 4 on the Forever client**

Forever runs the Retail UI API on a vanilla world, so the template shapes should match. Any difference here becomes a branch in Task 4.

- [ ] **Step 7: Record findings in the design doc**

Append to `Docs/Engineering/2026-09-18-flow-quest-box-design.md`:

```markdown
## Spike findings (2026-09-18)

| Item | Retail | Forever |
|---|---|---|
| Element tuple stride | | |
| Material colour table global | | |
| Greeting routes through `QuestInfo_Display` | | |
| `GetQuestObjectives` on offered quest | | |
| Largest tolerated `QuestFrame` size | | |
```

Fill every cell. An empty cell blocks Task 4.

- [ ] **Step 8: Commit**

```bash
git add Docs/Engineering/2026-09-18-flow-quest-box-design.md
git commit -m "docs(flow): record quest box spike findings"
```

---

### Task 2: Module skeleton

Deliverable: Flow appears in the dashboard, toggles on and off, and does nothing.

**Files:**
- Create: `modules/Flow/FlowModule.lua`
- Modify: `HorizonSuite.toc`, `HorizonSuite.lua`, `core/Config.lua`, `.luacheckrc`, `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: `addon.RegisterModule`
- Produces: `addon.Flow` namespace table; `addon.Flow.Enable()` and `addon.Flow.Disable()` as no-op stubs that Tasks 3–5 fill

- [ ] **Step 1: Create `modules/Flow/FlowModule.lua`**

```lua
--[[
    Horizon Suite - Flow Module
    Horizon chrome and objectives-first layout for the NPC quest dialogue window.
    Hosts Blizzard's QuestFrame rather than replacing it: Blizzard keeps body
    text layout and every control that grants a reward.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("flow", {
    title       = "Flow",
    description = "Horizon styling for the quest dialogue window, with objectives above the flavour text.",
    order       = 28,

    OnEnable = function()
        if addon.Flow and addon.Flow.Enable then addon.Flow.Enable() end
    end,

    OnDisable = function()
        if addon.Flow and addon.Flow.Disable then addon.Flow.Disable() end
    end,
})
```

- [ ] **Step 2: Add the TOC block**

In `HorizonSuite.toc`, immediately after the Presence block and before the Augment block, insert a blank line then:

```toc
modules/Flow/FlowTemplates.lua
modules/Flow/FlowQuestBand.lua
modules/Flow/FlowCore.lua
modules/Flow/FlowSlash.lua
modules/Flow/FlowModule.lua
```

- [ ] **Step 3: Seed the database entry**

In `HorizonSuite.lua`, inside `EnsureModulesDB`, add to the first-install block beside the other five:

```lua
        db.modules.flow = { enabled = false }
```

Then, after the existing Essence guard, add:

```lua
    -- Ensure flow exists for existing installs; disabled by default (new module)
    if not db.modules.flow then
        db.modules.flow = { enabled = false }
    end
```

- [ ] **Step 4: Add display names**

In `core/Config.lua`, add `flow` to both module name maps near lines 710 and 721, matching the surrounding style:

```lua
        flow = L["NAME_ADDON_FLOW"],
```

```lua
        flow     = L["AXIS_MODULE_NAME_SIMPLE_FLOW"],
```

- [ ] **Step 5: Add locale keys**

In `locales/horizon/enUS.lua`, beside the other module names:

```lua
L["NAME_ADDON_FLOW"] = "Horizon Flow"
L["AXIS_MODULE_NAME_SIMPLE_FLOW"] = "Quest Box"
L["FLOW_DESC"] = "Horizon styling for the quest dialogue window, with objectives above the flavour text."
```

- [ ] **Step 6: Add Blizzard globals to `.luacheckrc`**

In the `read_globals` list, beside the existing quest entries:

```lua
    "QuestFrame",
    "QuestFrameDetailPanel",
    "QuestFrameProgressPanel",
    "QuestFrameRewardPanel",
    "QuestFrameGreetingPanel",
    "QuestInfoFrame",
    "QuestInfo_Display",
    "QuestInfo_ShowObjectivesHeader",
    "QuestInfo_ShowObjectivesText",
    "QuestInfo_ShowDescriptionText",
    "QUEST_TEMPLATE_DETAIL",
    "QUEST_TEMPLATE_PROGRESS",
    "QUEST_TEMPLATE_REWARD",
    "QuestFrame_GetMaterial",
    "GetObjectiveText",
    "GetQuestID",
    "UIFrameFadeIn",
    "BackdropTemplateMixin",
```

- [ ] **Step 7: Verify**

Run `luacheck .` — expect clean. In game, `/reload`, open the dashboard, confirm a Flow entry exists, toggle it on and off, and confirm no Lua error.

- [ ] **Step 8: Commit**

```bash
git add modules/Flow/FlowModule.lua HorizonSuite.toc HorizonSuite.lua core/Config.lua .luacheckrc locales/horizon/enUS.lua
git commit -m "feat(flow): register Flow module skeleton"
```

---

### Task 3: Chrome — strip art, paint Horizon, restore

Deliverable: the quest box is dark Horizon chrome with Horizon fonts, and disabling Flow returns it to parchment without a reload.

**Files:**
- Create: `modules/Flow/FlowCore.lua`

**Interfaces:**
- Consumes: `addon.ResolveFontPath`, `addon.GetDB`
- Produces on `addon.Flow`:
  - `F.Enable()` / `F.Disable()` — idempotent
  - `F.Restyle()` — full repaint of whatever panel is showing
  - `F.StripFrameArt(frame)` / `F.RestoreFrameArt()`
  - `F.GetAccentColor()` → `r, g, b`

- [ ] **Step 1: Create the file with state and art stripping**

```lua
--[[
    Horizon Suite - Flow - Core
    Chrome, typography and hook installation for the quest dialogue window.
    QuestFrame stays inside UIPanelWindows; Flow only dresses it.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow

local BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local ART_NAMES = {
    "NineSlice", "Bg", "Border", "TopTileStreaks", "Inset",
    "PortraitContainer", "TitleBg", "TitleContainer",
}

local active        = false
local hooksInstalled = false
local hiddenRegions = {}
local chrome, header

--- Hide a frame's decorative regions, remembering them for restore.
--- @param frame Frame|nil
--- @return nil
function F.StripFrameArt(frame)
    if not frame then return end
    for i = 1, #ART_NAMES do
        local region = frame[ART_NAMES[i]]
        if region and region.Hide and region.IsShown then
            if region:IsShown() then hiddenRegions[region] = true end
            pcall(region.Hide, region)
        end
    end
    if not frame.GetRegions then return end
    local regions = { frame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Hide then
            local layer = r.GetDrawLayer and r:GetDrawLayer()
            if layer == "BACKGROUND" or layer == "BORDER" then
                if r.IsShown and r:IsShown() then hiddenRegions[r] = true end
                pcall(r.Hide, r)
            end
        end
    end
end

--- Re-show every region Flow hid.
--- @return nil
function F.RestoreFrameArt()
    for region in pairs(hiddenRegions) do
        if region and region.Show then pcall(region.Show, region) end
    end
    wipe(hiddenRegions)
end
```

- [ ] **Step 2: Add the chrome layer and accent colour**

`QuestFrame` has no `SetBackdrop` in modern Retail, so Flow parents its own `BackdropTemplate` frame behind the content rather than calling backdrop methods on `QuestFrame` itself.

```lua
--- Flow's accent colour: class tint when Axis asks for it, else Flow blue.
--- @return number r, number g, number b
function F.GetAccentColor()
    local GetDB = addon.GetDB
    if GetDB and GetDB("flowClassTint", false) and addon.GetClassColor then
        local r, g, b = addon.GetClassColor()
        if r then return r, g, b end
    end
    return 0.2, 0.6, 1.0
end

local function EnsureChrome()
    if chrome then return chrome end
    if not _G.QuestFrame then return nil end

    chrome = CreateFrame("Frame", "HorizonFlowChrome", _G.QuestFrame, "BackdropTemplate")
    chrome:SetAllPoints(_G.QuestFrame)
    chrome:SetFrameLevel(math.max(0, _G.QuestFrame:GetFrameLevel() - 1))
    chrome:SetBackdrop(BACKDROP)

    header = chrome:CreateTexture(nil, "ARTWORK")
    header:SetPoint("TOPLEFT", chrome, "TOPLEFT", 1, -1)
    header:SetPoint("BOTTOMRIGHT", chrome, "TOPRIGHT", -1, -32)

    chrome.accent = chrome:CreateTexture(nil, "OVERLAY")
    chrome.accent:SetWidth(3)
    chrome.accent:SetPoint("TOPLEFT", chrome, "TOPLEFT", 1, -1)
    chrome.accent:SetPoint("BOTTOMLEFT", chrome, "TOPLEFT", 1, -33)

    return chrome
end
```

`addon.GetClassColor` may not exist under that name. If `luacheck` or a runtime nil says so, find the real helper with `grep -rn "GetClassColor\|ClassColor" core/Config.lua` and use that; the Axis class-tint plumbing already resolves one for every other module.

- [ ] **Step 3: Implement `Restyle`**

```lua
local function ApplyFontTo(fontString, size, flags)
    if not fontString or not fontString.SetFont then return end
    local path = addon.ResolveFontPath and addon.ResolveFontPath(addon.GetDB and addon.GetDB("flowFont", nil))
    if not path then return end
    pcall(fontString.SetFont, fontString, path, size, flags)
end

--- Repaint whichever quest panel is currently showing.
--- @return nil
function F.Restyle()
    if not active then return end
    local frame = _G.QuestFrame
    if not frame or not frame.IsShown or not frame:IsShown() then return end

    F.StripFrameArt(frame)
    F.StripFrameArt(_G.QuestFrameDetailPanel)
    F.StripFrameArt(_G.QuestFrameProgressPanel)
    F.StripFrameArt(_G.QuestFrameRewardPanel)
    F.StripFrameArt(_G.QuestFrameGreetingPanel)

    local c = EnsureChrome()
    if not c then return end

    local GetDB  = addon.GetDB
    local alpha  = (GetDB and GetDB("flowBackdropOpacity", 92) or 92) / 100
    local br     = GetDB and GetDB("flowBackdropColorR", 0.09) or 0.09
    local bg     = GetDB and GetDB("flowBackdropColorG", 0.09) or 0.09
    local bb     = GetDB and GetDB("flowBackdropColorB", 0.11) or 0.11
    local ar, ag, ab = F.GetAccentColor()

    c:SetBackdropColor(br, bg, bb, alpha)
    if GetDB and GetDB("flowShowBorder", true) then
        c:SetBackdropBorderColor(0.18, 0.18, 0.22, 1)
    else
        c:SetBackdropBorderColor(0, 0, 0, 0)
    end
    header:SetColorTexture(br + 0.04, bg + 0.04, bb + 0.05, alpha)
    c.accent:SetColorTexture(ar, ag, ab, 1)
    c:Show()

    local size = tonumber(GetDB and GetDB("flowFontSize", 13)) or 13
    ApplyFontTo(_G.QuestInfoTitleHeader, size + 2, "")
    ApplyFontTo(_G.QuestInfoDescriptionText, size, "")
    ApplyFontTo(_G.QuestInfoObjectivesText, size, "")
    if _G.QuestInfoTitleHeader and _G.QuestInfoTitleHeader.SetTextColor then
        _G.QuestInfoTitleHeader:SetTextColor(0.94, 0.94, 0.96, 1)
    end
    if _G.QuestInfoDescriptionText and _G.QuestInfoDescriptionText.SetTextColor then
        _G.QuestInfoDescriptionText:SetTextColor(0.60, 0.60, 0.66, 1)
    end

    if addon.Flow.UpdateBand then addon.Flow.UpdateBand() end
end
```

The `QuestInfo*` FontString globals above are the ones Task 1 Step 2 printed as element functions. If any is nil at runtime, drop that line rather than guessing an alternative name.

- [ ] **Step 4: Install hooks and implement enable/disable**

```lua
local function InstallHooks()
    if hooksInstalled then return end
    if type(_G.QuestInfo_Display) ~= "function" then return end

    hooksecurefunc("QuestInfo_Display", function()
        if not active then return end
        pcall(F.Restyle)
    end)

    if _G.QuestFrame then
        _G.QuestFrame:HookScript("OnShow", function()
            if not active then return end
            pcall(F.Restyle)
            if addon.GetDB and addon.GetDB("flowEntrance", true) and _G.UIFrameFadeIn then
                pcall(_G.UIFrameFadeIn, _G.QuestFrame, 0.18, 0, 1)
            end
        end)
    end

    hooksInstalled = true
end

--- @return nil
function F.Enable()
    if active then return end
    active = true
    if addon.Flow.InstallTemplates then addon.Flow.InstallTemplates() end
    InstallHooks()
    if _G.QuestFrame and _G.QuestFrame:IsShown() then pcall(F.Restyle) end
end

--- @return nil
function F.Disable()
    active = false
    if addon.Flow.RestoreTemplates then addon.Flow.RestoreTemplates() end
    if addon.Flow.HideBand then addon.Flow.HideBand() end
    if chrome then chrome:Hide() end
    F.RestoreFrameArt()
end

--- Re-apply after an options change.
--- @return nil
function F.ApplyFlowOptions()
    if not active then return end
    pcall(F.Restyle)
end
```

`hooksecurefunc` cannot be undone, which is why `active` gates every hook body rather than the hooks being removed.

- [ ] **Step 5: Verify in-game**

`/reload`, enable Flow, talk to a quest giver. Expect dark chrome with a blue accent bar and Horizon fonts. Disable Flow from the dashboard with the frame still open, then reopen the quest: parchment is back.

- [ ] **Step 6: Commit**

```bash
git add modules/Flow/FlowCore.lua
git commit -m "feat(flow): paint Horizon chrome on the quest dialogue window"
```

---

### Task 4: Template element reordering

Deliverable: objectives render above flavour text on Detail, Progress and Reward, and the map details pane is untouched.

**Files:**
- Create: `modules/Flow/FlowTemplates.lua`

**Interfaces:**
- Consumes: the stride recorded in Task 1's spike findings
- Produces on `addon.Flow`: `F.InstallTemplates()`, `F.RestoreTemplates()`

- [ ] **Step 1: Create the file with stride detection and grouping**

Stride is detected at runtime rather than hardcoded, so a Blizzard change to the tuple shape degrades to "no reorder" instead of a corrupted element array.

```lua
--[[
    Horizon Suite - Flow - Quest templates
    Reorders QuestInfo template element arrays so objectives render above the
    flavour text. Only the three giver templates are touched; the map details
    pane renders from QUEST_TEMPLATE_MAP_DETAILS and is deliberately left alone.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow

local TEMPLATE_NAMES = {
    "QUEST_TEMPLATE_DETAIL",
    "QUEST_TEMPLATE_PROGRESS",
    "QUEST_TEMPLATE_REWARD",
}

local originals = {}

--- Distance in array slots between consecutive element entries.
--- @param elements table
--- @return number stride
local function DetectStride(elements)
    for i = 2, #elements do
        if type(elements[i]) == "function" then return i - 1 end
    end
    return 2
end

--- Split a flat element array into per-element groups.
--- @param elements table
--- @param stride number
--- @return table groups
local function GroupsOf(elements, stride)
    local groups = {}
    for i = 1, #elements, stride do
        local group = {}
        for j = 0, stride - 1 do group[j + 1] = elements[i + j] end
        groups[#groups + 1] = group
    end
    return groups
end

--- Flatten groups back into an element array.
--- @param groups table
--- @param stride number
--- @return table elements
local function Flatten(groups, stride)
    local out = {}
    for i = 1, #groups do
        for j = 1, stride do out[#out + 1] = groups[i][j] end
    end
    return out
end
```

- [ ] **Step 2: Implement the reorder**

```lua
--- Move the objectives group(s) directly above the description group.
--- @param elements table
--- @return table|nil reordered Nil when the expected groups are not present
local function Reorder(elements)
    local stride = DetectStride(elements)
    local groups = GroupsOf(elements, stride)

    local descIndex, objIndices = nil, {}
    for i = 1, #groups do
        local head = groups[i][1]
        if head == _G.QuestInfo_ShowDescriptionText then
            descIndex = i
        elseif head == _G.QuestInfo_ShowObjectivesHeader
            or head == _G.QuestInfo_ShowObjectivesText then
            objIndices[#objIndices + 1] = i
        end
    end

    if not descIndex or #objIndices == 0 then return nil end
    for i = 1, #objIndices do
        if objIndices[i] < descIndex then return nil end
    end

    local moving, skip = {}, {}
    for i = 1, #objIndices do
        moving[#moving + 1] = groups[objIndices[i]]
        skip[objIndices[i]] = true
    end

    local out = {}
    for i = 1, #groups do
        if i == descIndex then
            for j = 1, #moving do out[#out + 1] = moving[j] end
        end
        if not skip[i] then out[#out + 1] = groups[i] end
    end

    return Flatten(out, stride)
end
```

The two guard clauses matter. `not descIndex or #objIndices == 0` means Blizzard renamed something, and the bail leaves stock ordering. The `objIndices[i] < descIndex` check makes the function idempotent: once objectives already sit above the description, a second call changes nothing rather than shuffling them back down.

- [ ] **Step 3: Implement install and restore**

```lua
--- Swap in reordered element arrays, remembering the originals.
--- @return nil
function F.InstallTemplates()
    for i = 1, #TEMPLATE_NAMES do
        local name = TEMPLATE_NAMES[i]
        local template = _G[name]
        if type(template) == "table" and type(template.elements) == "table"
            and originals[name] == nil then
            local reordered = Reorder(template.elements)
            if reordered then
                originals[name] = template.elements
                template.elements = reordered
            end
        end
    end
end

--- Put Blizzard's original element arrays back.
--- @return nil
function F.RestoreTemplates()
    for name, elements in pairs(originals) do
        local template = _G[name]
        if type(template) == "table" then template.elements = elements end
    end
    wipe(originals)
end
```

Flow keeps a reference to Blizzard's original array rather than a copy, so restore is exact.

- [ ] **Step 4: Verify in-game**

Enable Flow, open a quest with a long description. Objectives appear above the flavour text. Open the world map, click a tracked quest: the map details pane still shows description-then-objectives in Blizzard order. Disable Flow, reopen the quest: Blizzard order returns.

- [ ] **Step 5: Commit**

```bash
git add modules/Flow/FlowTemplates.lua
git commit -m "feat(flow): reorder quest template elements to lead with objectives"
```

---

### Task 5: The objectives band and lore expander

Deliverable: a Horizon-drawn band above the body showing bullets with counts where the API has them, and the flavour text collapsed behind an expander that remembers its state.

**Files:**
- Create: `modules/Flow/FlowQuestBand.lua`

**Interfaces:**
- Consumes: `F.GetAccentColor` from Task 3, `addon.ResolveFontPath`, spike finding for `GetQuestObjectives`
- Produces on `addon.Flow`: `F.UpdateBand()`, `F.HideBand()`

- [ ] **Step 1: Create the file and the band frame**

```lua
--[[
    Horizon Suite - Flow - Objectives band
    Draws the objectives summary above Blizzard's quest body, and collapses the
    flavour text behind an expander. Read-only quest API only.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow
local L = addon.L

local MAX_ROWS = 6
local band, rows, expander

local function EnsureBand()
    if band then return band end
    local parent = _G.QuestFrameDetailPanel or _G.QuestFrame
    if not parent then return nil end

    band = CreateFrame("Frame", "HorizonFlowBand", parent, "BackdropTemplate")
    band:SetHeight(28)
    band:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
    band:SetBackdropColor(0.11, 0.11, 0.14, 0.9)

    band.accent = band:CreateTexture(nil, "OVERLAY")
    band.accent:SetWidth(2)
    band.accent:SetPoint("TOPLEFT")
    band.accent:SetPoint("BOTTOMLEFT")

    rows = {}
    for i = 1, MAX_ROWS do
        local row = band:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local count = band:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row:SetJustifyH("LEFT")
        count:SetJustifyH("RIGHT")
        rows[i] = { text = row, count = count }
    end

    expander = CreateFrame("Button", nil, band:GetParent())
    expander:SetHeight(16)
    expander.label = expander:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expander.label:SetPoint("LEFT")
    expander:SetScript("OnClick", function()
        local collapsed = addon.GetDB and addon.GetDB("flowCollapseLore", true)
        if addon.OptionsData_SetDB then addon.OptionsData_SetDB("flowCollapseLore", not collapsed) end
        if F.UpdateBand then F.UpdateBand() end
    end)

    return band
end
```

- [ ] **Step 2: Read the objectives**

```lua
--- Structured objectives for the quest currently on offer or in progress.
--- Falls back to Blizzard's prose blob when no structured data exists.
--- @return table rows Array of { text = string, done = number|nil, need = number|nil }
--- @return boolean structured
local function ReadObjectives()
    local out = {}
    local questID = _G.GetQuestID and _G.GetQuestID()
    if questID and questID > 0 and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, objectives = pcall(C_QuestLog.GetQuestObjectives, questID)
        if ok and type(objectives) == "table" then
            for i = 1, #objectives do
                local o = objectives[i]
                if o and o.text and o.text ~= "" then
                    out[#out + 1] = { text = o.text, done = o.numFulfilled, need = o.numRequired }
                end
            end
        end
    end
    if #out > 0 then return out, true end

    local blob = _G.GetObjectiveText and _G.GetObjectiveText()
    if blob and blob ~= "" then return { { text = blob } }, false end
    return {}, false
end
```

- [ ] **Step 3: Implement `UpdateBand`**

```lua
--- @return nil
function F.UpdateBand()
    local b = EnsureBand()
    if not b then return end

    local objectives, structured = ReadObjectives()
    if #objectives == 0 then b:Hide(); if expander then expander:Hide() end return end

    local anchor = _G.QuestInfoTitleHeader
    if not anchor then b:Hide() return end
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -8)
    b:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -8)

    local ar, ag, ab = F.GetAccentColor()
    b.accent:SetColorTexture(ar, ag, ab, 1)

    local path = addon.ResolveFontPath and addon.ResolveFontPath(addon.GetDB and addon.GetDB("flowFont", nil))
    local size = tonumber(addon.GetDB and addon.GetDB("flowFontSize", 13)) or 13

    local shown = math.min(#objectives, MAX_ROWS)
    local y = -8
    for i = 1, MAX_ROWS do
        local row = rows[i]
        if i <= shown then
            local o = objectives[i]
            row.text:ClearAllPoints()
            row.text:SetPoint("TOPLEFT", b, "TOPLEFT", 12, y)
            row.text:SetPoint("RIGHT", b, "RIGHT", -52, 0)
            row.text:SetText((structured and "|cff5599ff\226\128\162|r  " or "") .. o.text)
            row.text:SetTextColor(0.89, 0.89, 0.93, 1)
            if path then pcall(row.text.SetFont, row.text, path, size, "") end
            row.text:Show()

            if structured and o.need and o.need > 1 then
                row.count:ClearAllPoints()
                row.count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -12, y)
                row.count:SetText((o.done or 0) .. "/" .. o.need)
                row.count:SetTextColor(0.54, 0.54, 0.60, 1)
                if path then pcall(row.count.SetFont, row.count, path, size, "") end
                row.count:Show()
            else
                row.count:Hide()
            end
            y = y - (size + 7)
        else
            row.text:Hide()
            row.count:Hide()
        end
    end

    b:SetHeight(math.max(28, 16 + shown * (size + 7)))
    b:Show()

    F.UpdateLoreExpander(b)
end
```

The bullet is an explicit UTF-8 escape rather than a literal character, because the repo's Lua files are read by tooling that does not guarantee encoding round-trips.

- [ ] **Step 4: Implement the lore expander**

```lua
--- Collapse or reveal Blizzard's description FontString beneath the band.
--- @param b Frame The band, used as the anchor
--- @return nil
function F.UpdateLoreExpander(b)
    local desc = _G.QuestInfoDescriptionText
    if not desc or not expander then return end

    local collapsed = addon.GetDB and addon.GetDB("flowCollapseLore", true)
    expander:ClearAllPoints()
    expander:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 12, -6)
    expander:SetPoint("RIGHT", b, "RIGHT", -12, 0)
    expander.label:SetText(collapsed and L["FLOW_READ_FULL_TEXT"] or L["FLOW_HIDE_FULL_TEXT"])
    expander.label:SetTextColor(0.54, 0.54, 0.60, 1)
    expander:Show()

    if collapsed then
        desc:SetAlpha(0)
        desc:SetHeight(1)
    else
        desc:SetAlpha(1)
        desc:SetHeight(0)
    end
end

--- @return nil
function F.HideBand()
    if band then band:Hide() end
    if expander then expander:Hide() end
    local desc = _G.QuestInfoDescriptionText
    if desc then desc:SetAlpha(1); desc:SetHeight(0) end
end
```

`SetHeight(0)` on a FontString restores auto-sizing; it does not collapse it. Alpha plus a one-pixel height is used rather than `Hide` because Blizzard's layout pass re-shows hidden element FontStrings on the next display, which would make the expander appear to do nothing every second quest.

- [ ] **Step 5: Add locale keys**

In `locales/horizon/enUS.lua`:

```lua
L["FLOW_READ_FULL_TEXT"] = "Read the full text"
L["FLOW_HIDE_FULL_TEXT"] = "Hide the full text"
```

- [ ] **Step 6: Verify in-game**

Open an unaccepted quest with several objectives: the band shows bullets with `0/N` counts. Open a quest with one narrative objective: one styled line, no count. Click the expander both ways and reopen the quest; the choice persists. Compare against Task 1 Step 4's recorded output for the same quest.

- [ ] **Step 7: Commit**

```bash
git add modules/Flow/FlowQuestBand.lua locales/horizon/enUS.lua
git commit -m "feat(flow): add objectives band and lore expander"
```

---

### Task 6: Options

Deliverable: an Axis → Flow page with appearance settings that apply live.

**Files:**
- Create: `options/modules/defaults/OptionsDefaultsFlow.lua`, `options/modules/OptionsFlow.lua`
- Modify: `HorizonSuite.toc`, `options/OptionsData.lua`, `locales/horizon/enUS.lua`

**Interfaces:**
- Consumes: `addon.Section`, `addon.Toggle`, `addon.Slider`, `addon.Color`, `F.ApplyFlowOptions`
- Produces: `addon.FLOW_KEYS`, `addon.FLOW_DEFAULTS`, `addon.FLOW_LIMITS`

- [ ] **Step 1: Create the defaults file**

```lua
--[[
    Horizon Suite - Flow - SetDB routing keys
    Exports FLOW_KEYS used by OptionsData_SetDB to trigger Flow.ApplyFlowOptions
    when any Flow setting changes.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.FLOW_KEYS = {
    flowBackdropColorR  = true,
    flowBackdropColorG  = true,
    flowBackdropColorB  = true,
    flowBackdropOpacity = true,
    flowShowBorder      = true,
    flowFont            = true,
    flowFontSize        = true,
    flowEntrance        = true,
    flowCollapseLore    = true,
    flowShowTypePill    = true,
    flowClassTint       = true,
}

addon.FLOW_DEFAULTS = {
    flowBackdropColorR  = 0.09,
    flowBackdropColorG  = 0.09,
    flowBackdropColorB  = 0.11,
    flowBackdropOpacity = 92,
    flowShowBorder      = true,
    flowFontSize        = 13,
    flowEntrance        = true,
    flowCollapseLore    = true,
    flowShowTypePill    = true,
    flowClassTint       = false,
}

addon.FLOW_LIMITS = {
    flowBackdropOpacity = { min = 0,  max = 100 },
    flowFontSize        = { min = 9,  max = 22  },
}
```

Defaults mirror Focus's `backdropColorR/G/B` at `0.08 / 0.08 / 0.12` closely enough to look like one product, without reading Focus's keys.

- [ ] **Step 2: Create the options category**

```lua
--[[
    Horizon Suite - Flow - Options categories
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local Section = addon.Section
local Toggle  = addon.Toggle
local Slider  = addon.Slider
local Color   = addon.Color
local D   = addon.FLOW_DEFAULTS
local LIM = addon.FLOW_LIMITS

local categories = {
    {
        key       = "Flow",
        name      = L["AXIS_MODULE_NAME_SIMPLE_FLOW"],
        desc      = L["FLOW_DESC"],
        moduleKey = "flow",
        options   = {
            Section(L["DASH_APPEARANCE"]),
            Color(L["FLOW_BACKDROP_COLOUR"], L["FLOW_BACKDROP_COLOUR_DESC"], "flowBackdropColor",
                { D.flowBackdropColorR, D.flowBackdropColorG, D.flowBackdropColorB }),
            Slider(L["FLOW_BACKDROP_OPACITY"], L["FLOW_BACKDROP_OPACITY_DESC"], "flowBackdropOpacity",
                LIM.flowBackdropOpacity.min, LIM.flowBackdropOpacity.max, D.flowBackdropOpacity),
            Toggle(L["FLOW_SHOW_BORDER"], L["FLOW_SHOW_BORDER_DESC"], "flowShowBorder", D.flowShowBorder),
            Slider(L["FLOW_FONT_SIZE"], L["FLOW_FONT_SIZE_DESC"], "flowFontSize",
                LIM.flowFontSize.min, LIM.flowFontSize.max, D.flowFontSize),
            Section(L["FLOW_BEHAVIOUR"]),
            Toggle(L["FLOW_ENTRANCE"], L["FLOW_ENTRANCE_DESC"], "flowEntrance", D.flowEntrance),
            Toggle(L["FLOW_COLLAPSE_LORE"], L["FLOW_COLLAPSE_LORE_DESC"], "flowCollapseLore", D.flowCollapseLore),
            Toggle(L["FLOW_TYPE_PILL"], L["FLOW_TYPE_PILL_DESC"], "flowShowTypePill", D.flowShowTypePill),
        },
    },
}

for i = 1, #categories do
    addon.OptionCategories[#addon.OptionCategories + 1] = categories[i]
end
```

The `Color` helper writes a single key. `FlowCore.Restyle` reads three separate `flowBackdropColorR/G/B` keys. Reconcile by checking how `headerColor` is stored and read in `OptionsFocus.lua` line 352 and its consumer, then match that convention in both files — do not invent a third.

- [ ] **Step 3: Route settings changes**

In `options/OptionsData.lua`, find the block that dispatches on `ESSENCE_KEYS` and add the matching Flow branch beside it:

```lua
    if addon.FLOW_KEYS and addon.FLOW_KEYS[key] and addon.Flow and addon.Flow.ApplyFlowOptions then
        addon.Flow.ApplyFlowOptions()
    end
```

- [ ] **Step 4: Add the TOC entries and locale keys**

In `HorizonSuite.toc`, beside the other options defaults and module files:

```toc
options/modules/defaults/OptionsDefaultsFlow.lua
```

```toc
options/modules/OptionsFlow.lua
```

Add every `L["FLOW_*"]` key used above to `locales/horizon/enUS.lua` with plain sentence-case English.

- [ ] **Step 5: Verify**

`luacheck .` clean. In game, open Axis → Flow, change backdrop opacity with a quest window open, and confirm it updates live.

- [ ] **Step 6: Commit**

```bash
git add options/modules/defaults/OptionsDefaultsFlow.lua options/modules/OptionsFlow.lua options/OptionsData.lua HorizonSuite.toc locales/horizon/enUS.lua
git commit -m "feat(flow): add Flow appearance and behaviour options"
```

---

### Task 7: Slash commands and the restore panic path

Deliverable: `/h flow restore` returns a broken quest box to Blizzard without a reload.

**Files:**
- Create: `modules/Flow/FlowSlash.lua`

**Interfaces:**
- Consumes: `F.Enable`, `F.Disable`, `F.Restyle`
- Produces: `/h flow`, `/h flow restore`, `/h flow restyle`

- [ ] **Step 1: Find the registration pattern**

Read `modules/Essence/EssenceSlash.lua` end to end and copy its registration shape exactly. Do not invent a new one.

- [ ] **Step 2: Implement**

```lua
--[[
    Horizon Suite - Flow - Slash commands
    /h flow          status
    /h flow restore  unhook and restore Blizzard without touching the enabled flag
    /h flow restyle  force a repaint
]]

local addon = _G.HorizonSuite
if not addon then return end

local F = addon.Flow

local function Handle(rest)
    local sub = (rest or ""):lower():match("^(%a*)")
    if sub == "restore" then
        if F and F.Disable then F.Disable() end
        print("|cff3399ffHorizon Flow|r: restored Blizzard quest frame. Re-enable from Axis or /reload.")
    elseif sub == "restyle" then
        if F and F.Restyle then F.Restyle() end
        print("|cff3399ffHorizon Flow|r: repainted.")
    else
        local on = addon.IsModuleEnabled and addon:IsModuleEnabled("flow")
        print("|cff3399ffHorizon Flow|r: " .. (on and "enabled" or "disabled")
            .. ". Subcommands: restore, restyle.")
    end
end
```

Register `Handle` under the `flow` keyword using the pattern from Step 1.

- [ ] **Step 3: Verify**

With a quest open and Flow enabled, run `/h flow restore`. The parchment frame returns without a reload, and the quest is still acceptable. `/h flow` reports state.

- [ ] **Step 4: Commit**

```bash
git add modules/Flow/FlowSlash.lua HorizonSuite.toc
git commit -m "feat(flow): add slash commands and restore path"
```

---

### Task 8: README and the full QA pass

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add the Flow section**

Insert after the Presence section, matching the shape of its neighbours:

```markdown
## 📜 <span style="color:#3399FF;">Flow</span> [Quest Box]

The quest box should tell you what to do before it tells you why.

- **Horizon chrome** — The parchment window picks up your backdrop colour, opacity, border and font, so the quest box and the tracker look like one addon.
- **Objectives first** — What the quest actually asks moves above the flavour text, with counts where the game provides them.
- **Lore on demand** — Collapse the full quest text behind a single line and expand it when you want it. Your choice is remembered.
- **Blizzard keeps the rewards** — Accepting, declining and choosing a reward are still Blizzard's own controls, untouched.
- **Works everywhere** — Retail and World of Warcraft: Forever, with no feature gating.
```

Also add `Flow` to the module list in `Docs/Branding/ColourSchema.md` only if it is missing. It is already present; confirm rather than duplicate.

- [ ] **Step 2: Run the spec checklist**

Every box from the design doc's success criteria, in one sitting, on Retail:

- [ ] Accept and decline both work
- [ ] Completing a quest with a choice of rewards delivers the chosen item
- [ ] Objectives render above flavour text on Detail, Progress and Reward
- [ ] Band shows bullets with counts where `GetQuestObjectives` returns them, a prose line where it does not
- [ ] Lore expander collapses, expands, and remembers the preference
- [ ] Greeting panel with several quests still selects correctly
- [ ] Required-item Progress panel renders and completes
- [ ] Map details pane and `QuestLogPopupDetailFrame` render as stock Blizzard while Flow is on
- [ ] Disabling Flow restores the parchment frame without a reload
- [ ] `/h flow restore` recovers a broken state mid-chain
- [ ] Runs with ElvUI's quest skin active without visual garbage
- [ ] Auto-accepted quest does not error when the Detail panel never shows
- [ ] Quest with a spell or currency reward renders
- [ ] `luacheck .` clean

- [ ] **Step 3: Repeat the checklist on Forever**

Same list on the Forever install. Skip the map-pane row if that client's map has no quest details pane.

- [ ] **Step 4: Commit and open the PR**

```bash
git add README.md
git commit -m "docs: add Flow module to README"
```

Then generate the PR body with the `/pr` skill. Do not hand-write it. Open ready, not draft.

---

## Spec coverage (self-review)

| Spec requirement | Task |
|---|---|
| New module `flow`, order 28, colour `#3399FF` | Task 2 |
| Host, do not reparent | Task 3 (no `SetParent` on `QuestFrame` anywhere) |
| Strip art, Horizon chrome, class-tinted header | Task 3 |
| Template element reordering, three giver templates only | Task 4 |
| Map templates untouched | Task 4 (explicit list), Task 8 (verified) |
| Objectives band, bullets or prose | Task 5 |
| Lore collapsed behind an expander, remembered | Task 5 |
| Fonts on FontStrings, never global font objects | Task 3 (`ApplyFontTo`), Task 5 |
| Flow's own appearance settings, Focus-matching defaults | Task 6 |
| Entrance animation, toggleable | Task 3, Task 6 |
| Teardown restores templates and art | Tasks 3 and 4 (`Disable`, `RestoreTemplates`) |
| `/h flow restore` panic path | Task 7 |
| `pcall` around styling passes | Task 3 (hook bodies), Task 5 (`ReadObjectives`) |
| Default off | Task 2 |
| No Platform gating | Global constraints; nothing added |
| `.luacheckrc` globals | Task 2 |
| README | Task 8 |
| Success criteria checklist | Task 8 |
| Four spike open items | Task 1 |

**Placeholder scan:** no `TBD` or `implement later`. Three places defer to the codebase rather than guessing, each with an explicit lookup instruction: `addon.GetClassColor`'s real name (Task 3 Step 2), the `Color` helper's single-key versus three-key storage (Task 6 Step 2), and the slash registration shape (Task 7 Step 1). These are reads of existing code, not undefined work.

**Type consistency:** `F.Enable` / `F.Disable` / `F.Restyle` / `F.ApplyFlowOptions` / `F.StripFrameArt` / `F.RestoreFrameArt` / `F.GetAccentColor` (Task 3), `F.InstallTemplates` / `F.RestoreTemplates` (Task 4), `F.UpdateBand` / `F.UpdateLoreExpander` / `F.HideBand` (Task 5) are used with the same names and arities everywhere they appear. `FlowCore.Disable` calls `RestoreTemplates` and `HideBand`, both defined; `FlowCore.Restyle` calls `UpdateBand`, defined; `FlowQuestBand` calls `F.GetAccentColor`, defined.

**Known ordering dependency:** `FlowTemplates.lua` and `FlowQuestBand.lua` must precede `FlowCore.lua` in the TOC, and `FlowModule.lua` must come last. Task 2 Step 2 sets this; do not reorder it in later tasks.
