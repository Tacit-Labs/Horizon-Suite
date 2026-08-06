# Augment Skinned Personal Loot Window Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop hiding Blizzard’s personal loot window, then restyle it in place to match Augment Compact / Framed / Accent (Accent as fidelity target), driven by `augmentToastStyle`.

**Architecture:** Remove `KillBlizzardFrame(LootFrame)` from toast suppression. Add `AugmentLootWindowSkin.lua` that hooksecures `LootFrame` show/update, strips default art, and applies Augment chrome via shared helpers reusable later for group rolls. Slot clicks stay Blizzard’s.

**Tech Stack:** WoW retail Lua 5.1 (Interface 120007), Horizon Suite Augment, `BackdropTemplate`, `hooksecurefunc`, existing `Augment.ToastStyles`.

**Spec:** `Docs/Engineering/2026-08-07-augment-skinned-loot-window-design.md`

## Global Constraints

- Lua 5.1 only (no `goto`, `//`, native bitwise, `require`)
- Namespace: `local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite` (match neighboring Augment loot files if they still use `_G.HorizonSuite` — prefer the loading alias in **new** files)
- Do **not** call `LootSlot`, replace slot OnClick, or build a custom loot hierarchy in v1
- Style source: `Y.GetToastStyle()` / `augmentToastStyle` only — no new style DB key
- `augmentSuppressBlizzard` suppresses **toasts only** — never the interactive `LootFrame`
- Group Need/Greed frames: do not skin in v1; export helpers only
- Combat: appearance-only; guard `Show`/`Hide`/`SetParent` on secure frames with `InCombatLockdown()` if those calls are used
- Work on a **feature branch** off `main` (do not push design/plan commits alone as the feature PR without the code)

---

## File map

| File | Responsibility |
|------|----------------|
| Modify: `modules/Augment/LootFrame/AugmentBlizzard.lua` | Stop killing `LootFrame`; keep toast suppression |
| Create: `modules/Augment/LootFrame/AugmentLootWindowSkin.lua` | Shared skin helpers + personal `LootFrame` hooks / apply / clear |
| Modify: `HorizonSuite.toc` | Load skin module after ToastStyles + State, before or after Blizzard (after `AugmentBlizzard.lua` is fine) |
| Modify: `modules/Augment/AugmentModule.lua` | Enable/Disable skin with loot mini-module |
| Modify: `modules/Augment/LootFrame/AugmentCore.lua` | Call skin refresh from `ApplyAugmentOptions` |
| Modify: `modules/Augment/LootFrame/AugmentEvents.lua` | After `Blizzard_LootFrame` loads, enable skin hooks (not re-kill) |
| Modify: `README.md`, `README-wago.md`, `README-curseforge.md` | One Augment capability line for skinned personal loot window |

---

### Task 1: Stop killing interactive `LootFrame`

**Files:**
- Modify: `modules/Augment/LootFrame/AugmentBlizzard.lua` (around the `KillBlizzardFrame(LootFrame)` call in `Y.SuppressBlizzard`)

**Interfaces:**
- Consumes: existing `KillBlizzardFrame`, toast alert suppression
- Produces: `SuppressBlizzard` no longer hides personal loot window; toasts still suppressed

- [ ] **Step 1: Remove personal loot window kill**

In `Y.SuppressBlizzard`, delete this line only:

```lua
KillBlizzardFrame(LootFrame)
```

Leave these intact:

```lua
KillBlizzardFrame(LootAlertFrame)
KillBlizzardFrame(MoneyWonAlertFrame)
KillBlizzardFrame(LootUpgradeAlertFrame)
KillBlizzardFrame(LootWonAlertFrame)
```

Add a one-line comment above the remaining kills:

```lua
-- Do not KillBlizzardFrame(LootFrame): that is the interactive manual-loot UI
-- (required when Auto Loot is off). Toast/alert frames only below.
```

- [ ] **Step 2: Verify `ADDON_LOADED` path does not re-introduce a LootFrame kill**

Confirm `AugmentEvents.lua` `handlers.ADDON_LOADED` only calls `Y.ApplyBlizzardSuppression()` (which now skips `LootFrame`). No extra `KillBlizzardFrame(LootFrame)` elsewhere — search:

```text
KillBlizzardFrame\(LootFrame\)
```

Expected: zero matches after Step 1.

- [ ] **Step 3: In-game smoke test (suppression fix alone)**

1. Enable Augment loot + “Hide Default Blizzard Toasts”
2. Turn **Auto Loot off** in WoW settings
3. Loot a corpse → Blizzard loot window must appear and items must be clickable
4. After looting, Augment toast should still appear
5. Blizzard loot **toast** alerts should stay hidden

- [ ] **Step 4: Commit**

```bash
git add modules/Augment/LootFrame/AugmentBlizzard.lua
git commit -m "fix(augment): keep interactive LootFrame when suppressing toasts"
```

---

### Task 2: Skin module scaffold + shared helpers

**Files:**
- Create: `modules/Augment/LootFrame/AugmentLootWindowSkin.lua`
- Modify: `HorizonSuite.toc` — insert after `AugmentBlizzard.lua`:

```toc
modules/Augment/LootFrame/AugmentLootWindowSkin.lua
```

**Interfaces:**
- Consumes: `addon.Augment`, `Y.GetToastStyle`, `Y.GetFontPath`, `ITEM_QUALITY_COLORS` / `Y.QUALITY_COLORS`
- Produces (assign on `addon.Augment`):
  - `Y.SkinStripDefaultArt(frame)` — hide common Blizzard chrome regions best-effort
  - `Y.SkinApplyWindowChrome(frame, style, accentR, accentG, accentB)` — Compact / Framed / Accent on a BackdropTemplate-capable frame
  - `Y.SkinApplySlotQuality(fontString, quality)` — set text colour from quality
  - `Y.EnableLootWindowSkin()` / `Y.DisableLootWindowSkin()` — install/remove personal loot hooks; idempotent
  - `Y.RefreshLootWindowSkin()` — re-apply if `LootFrame` shown

- [ ] **Step 1: Create file header + local refs**

```lua
--[[
    Horizon Suite - Augment - Personal Loot Window Skin
    In-place restyle of Blizzard LootFrame to match Augment toast chrome.
    Does not replace loot clicks. Group-roll consumers can reuse Skin* helpers later.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

local TOOLTIP_BACKDROP = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
}

local hooksInstalled = false
local skinActive = false
local savedRegions = {}  -- [region] = { shown = bool, ... } for best-effort restore
```

- [ ] **Step 2: Implement shared helpers**

```lua
--- Hide common Blizzard decorative regions on a frame (NineSlice, Border, Portrait, etc.).
--- @param frame Frame
--- @return nil
function Y.SkinStripDefaultArt(frame)
    if not frame then return end
    local names = { "NineSlice", "Border", "Bg", "TitleBg", "PortraitContainer", "Inset", "TopTileStreaks" }
    for i = 1, #names do
        local region = frame[names[i]]
        if region and region.Hide then
            if savedRegions[region] == nil then
                savedRegions[region] = true
            end
            pcall(region.Hide, region)
        end
    end
    -- Also hide unnamed texture children that look like full-frame borders (best-effort).
    if frame.GetRegions then
        local regions = { frame:GetRegions() }
        for _, r in ipairs(regions) do
            if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Hide then
                local draw = r.GetDrawLayer and r:GetDrawLayer()
                if draw == "BORDER" or draw == "BACKGROUND" then
                    if savedRegions[r] == nil then savedRegions[r] = true end
                    pcall(r.Hide, r)
                end
            end
        end
    end
end

--- Apply Compact / Framed / Accent chrome to a window frame.
--- Framed uses tooltip backdrop; Accent draws a left colour strip; Compact is minimal dark fill.
--- @param frame Frame Must support BackdropTemplate methods when style is framed (ensure template or CreateTexture fallback)
--- @param style string|nil
--- @param accentR number
--- @param accentG number
--- @param accentB number
--- @return nil
function Y.SkinApplyWindowChrome(frame, style, accentR, accentG, accentB)
    if not frame then return end
    local TS = Y.ToastStyles
    style = (TS and TS.Normalize and TS.Normalize(style)) or "framed"
    accentR, accentG, accentB = accentR or 0.6, accentG or 0.6, accentB or 0.6

    if not frame._hsAugmentChromeStrip then
        local strip = frame:CreateTexture(nil, "ARTWORK")
        strip:SetWidth(3)
        strip:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        strip:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        frame._hsAugmentChromeStrip = strip
    end
    local strip = frame._hsAugmentChromeStrip

    if style == "framed" then
        if frame.SetBackdrop then
            frame:SetBackdrop(TOOLTIP_BACKDROP)
            frame:SetBackdropColor(0, 0, 0, 0.75)
            frame:SetBackdropBorderColor(accentR, accentG, accentB, 0.7)
        end
        strip:Hide()
    elseif style == "accent" then
        if frame.SetBackdrop then frame:SetBackdrop(nil) end
        if not frame._hsAugmentChromeBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(frame)
            bg:SetColorTexture(0, 0, 0, 0.85)
            frame._hsAugmentChromeBg = bg
        end
        frame._hsAugmentChromeBg:Show()
        strip:SetColorTexture(accentR, accentG, accentB, 1)
        strip:Show()
    else -- compact
        if frame.SetBackdrop then frame:SetBackdrop(nil) end
        if not frame._hsAugmentChromeBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(frame)
            bg:SetColorTexture(0, 0, 0, 0.85)
            frame._hsAugmentChromeBg = bg
        end
        frame._hsAugmentChromeBg:Show()
        strip:Hide()
    end
end

--- Colour a FontString by item quality.
--- @param fontString FontString
--- @param quality number|nil
--- @return nil
function Y.SkinApplySlotQuality(fontString, quality)
    if not fontString or not fontString.SetTextColor then return end
    local r, g, b = 1, 1, 1
    if ITEM_QUALITY_COLORS and quality ~= nil and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        r, g, b = c.r, c.g, c.b
    elseif Y.QUALITY_COLORS and Y.QUALITY_COLORS[quality or 1] then
        local c = Y.QUALITY_COLORS[quality or 1]
        r, g, b = c[1] or c.r, c[2] or c.g, c[3] or c.b
    end
    fontString:SetTextColor(r, g, b, 1)
end
```

Ensure `LootFrame` can use backdrop: if `LootFrame` lacks `SetBackdrop`, wrap with a child `BackdropTemplate` frame named `_hsAugmentChromeFrame` parented behind content (implement inside `SkinApplyWindowChrome` when `not frame.SetBackdrop`).

- [ ] **Step 3: Stub Enable/Disable/Refresh (hooks empty until Task 3–4)**

```lua
function Y.RefreshLootWindowSkin()
    if not skinActive then return end
    local frame = _G.LootFrame
    if not frame or not frame.IsShown or not frame:IsShown() then return end
    -- Full apply filled in Task 3–4
end

function Y.EnableLootWindowSkin()
    skinActive = true
    -- hooks in Task 3
end

function Y.DisableLootWindowSkin()
    skinActive = false
    -- restore in Task 5
end
```

- [ ] **Step 4: Commit**

```bash
git add modules/Augment/LootFrame/AugmentLootWindowSkin.lua HorizonSuite.toc
git commit -m "feat(augment): add loot window skin helpers scaffold"
```

---

### Task 3: Hook Blizzard personal loot window + apply chrome

**Files:**
- Modify: `modules/Augment/LootFrame/AugmentLootWindowSkin.lua`

**Interfaces:**
- Consumes: `Y.SkinStripDefaultArt`, `Y.SkinApplyWindowChrome`, `Y.GetToastStyle`
- Produces: hooks that call apply on show/update; accent colour = highest visible slot quality or white

- [ ] **Step 1: Resolve accent colour from visible loot**

```lua
local function GetLootAccentColor()
    local bestQ = -1
    local r, g, b = 0.7, 0.7, 0.7
    local num = GetNumLootItems and GetNumLootItems() or 0
    for slot = 1, num do
        -- GetLootSlotInfo returns texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive
        local ok, _, _, _, _, quality = pcall(GetLootSlotInfo, slot)
        if ok and quality and quality > bestQ then
            bestQ = quality
            if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
                local c = ITEM_QUALITY_COLORS[quality]
                r, g, b = c.r, c.g, c.b
            end
        end
    end
    return r, g, b, bestQ
end
```

- [ ] **Step 2: Implement `ApplyPersonalLootSkin`**

```lua
local function ApplyPersonalLootSkin()
    if not skinActive then return end
    local frame = _G.LootFrame
    if not frame then return end

    Y.SkinStripDefaultArt(frame)
    local ar, ag, ab = GetLootAccentColor()
    local style = Y.GetToastStyle and Y.GetToastStyle() or "framed"
    Y.SkinApplyWindowChrome(frame, style, ar, ag, ab)

    -- Title / close fonts
    local fontPath = Y.GetFontPath and Y.GetFontPath() or "Fonts\\FRIZQT__.TTF"
    local title = frame.TitleText or _G.LootFrameTitleText or frame.TitleContainer and frame.TitleContainer.TitleText
    if title and title.SetFont then
        pcall(title.SetFont, title, fontPath, 14, "OUTLINE")
        title:SetTextColor(ar, ag, ab, 1)
    end

    -- Slot pass filled in Task 4
    ApplyLootSlotsSkin()
end

function Y.RefreshLootWindowSkin()
    ApplyPersonalLootSkin()
end
```

- [ ] **Step 3: Install hooks (idempotent)**

```lua
local function InstallHooks()
    if hooksInstalled then return end
    local frame = _G.LootFrame
    if not frame then return end

    frame:HookScript("OnShow", function()
        if skinActive then ApplyPersonalLootSkin() end
    end)

    if _G.LootFrame_Update then
        hooksecurefunc("LootFrame_Update", function()
            if skinActive then ApplyPersonalLootSkin() end
        end)
    elseif frame.Update then
        hooksecurefunc(frame, "Update", function()
            if skinActive then ApplyPersonalLootSkin() end
        end)
    end

    hooksInstalled = true
end

function Y.EnableLootWindowSkin()
    skinActive = true
    if _G.LootFrame then
        InstallHooks()
        if _G.LootFrame:IsShown() then ApplyPersonalLootSkin() end
    end
end
```

If `LootFrame` is nil at enable time, Task 5’s `ADDON_LOADED` path calls `EnableLootWindowSkin` again after load.

- [ ] **Step 4: In-game check**

Auto Loot off → open loot → window shows Augment chrome (Accent/Framed/Compact per style setting). Clicks still work.

- [ ] **Step 5: Commit**

```bash
git add modules/Augment/LootFrame/AugmentLootWindowSkin.lua
git commit -m "feat(augment): hook and chrome-skin personal LootFrame"
```

---

### Task 4: Slot rows, money line, icon treatment

**Files:**
- Modify: `modules/Augment/LootFrame/AugmentLootWindowSkin.lua`

**Interfaces:**
- Consumes: `Y.SkinApplySlotQuality`, style from `GetToastStyle`
- Produces: `ApplyLootSlotsSkin()` complete

- [ ] **Step 1: Skin `LootButton1`…`N` (legacy globals) and/or ScrollBox children**

```lua
local function SkinOneLootButton(button, quality)
    if not button or not button.IsShown or not button:IsShown() then return end
    local fontPath = Y.GetFontPath and Y.GetFontPath() or "Fonts\\FRIZQT__.TTF"
    local text = button.Text or button.Name or _G[button:GetName() and (button:GetName() .. "Text") or ""]
    if text and text.SetFont then
        pcall(text.SetFont, text, fontPath, 13, "OUTLINE")
        Y.SkinApplySlotQuality(text, quality)
    end

    local style = Y.GetToastStyle and Y.GetToastStyle() or "framed"
    local icon = button.Icon or button.icon or _G[button:GetName() and (button:GetName() .. "IconTexture") or ""]
    local r, g, b = 1, 1, 1
    if ITEM_QUALITY_COLORS and quality and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        r, g, b = c.r, c.g, c.b
    end

    -- Accent/Compact: quality-tinted icon pad behind icon (create once per button)
    if style == "accent" or style == "compact" then
        if icon and not button._hsIconPad then
            local pad = button:CreateTexture(nil, "BACKGROUND")
            local padExtra = (style == "accent") and 4 or 1
            pad:SetPoint("TOPLEFT", icon, "TOPLEFT", -padExtra, padExtra)
            pad:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", padExtra, -padExtra)
            button._hsIconPad = pad
        end
        if button._hsIconPad then
            button._hsIconPad:SetColorTexture(r, g, b, style == "accent" and 0.85 or 0.8)
            button._hsIconPad:Show()
        end
    elseif button._hsIconPad then
        button._hsIconPad:Hide()
    end

    -- Hide default slot border textures when present
    local border = button.IconBorder or button.NormalTexture
    if border and border.Hide and style ~= "framed" then
        pcall(border.Hide, border)
    end
end

function ApplyLootSlotsSkin()
    local numButtons = (_G.LOOTFRAME_NUMBUTTONS) or 4
    for index = 1, numButtons do
        local button = _G["LootButton" .. index]
        if button and button:IsShown() then
            local slot = button.slot or button:GetID() or index
            local ok, _, _, _, _, quality = pcall(GetLootSlotInfo, slot)
            SkinOneLootButton(button, ok and quality or 1)
        end
    end

    -- Money: LootFrame gold/silver/copper or MoneyFrame children — tint labels, keep values
    local moneyLabel = _G.LootFrameGoldButton or (_G.LootFrame and _G.LootFrame.MoneyFrame)
    -- Best-effort: walk LootFrame children named *Money* / *Gold* and apply font only
end
```

If Midnight uses a ScrollBox of loot elements instead of `LootButtonN`, detect `LootFrame.ScrollBox` and iterate visible frames via `ScrollBox:GetFrames()` (guard with existence checks). Prefer one code path that tries globals first, then ScrollBox.

- [ ] **Step 2: In-game check**

- Epic item name purple; icon pad visible on Accent  
- Switch toast style in options → reopen loot → chrome + pads update  
- Tooltips on hover still Blizzard  

- [ ] **Step 3: Commit**

```bash
git add modules/Augment/LootFrame/AugmentLootWindowSkin.lua
git commit -m "feat(augment): quality-colour loot slots to match toast styles"
```

---

### Task 5: Lifecycle — enable, disable, options, lazy load

**Files:**
- Modify: `modules/Augment/AugmentModule.lua`
- Modify: `modules/Augment/LootFrame/AugmentCore.lua` (`ApplyAugmentOptions`)
- Modify: `modules/Augment/LootFrame/AugmentEvents.lua`
- Modify: `modules/Augment/LootFrame/AugmentLootWindowSkin.lua` (`DisableLootWindowSkin` restore)

**Interfaces:**
- Consumes: `Y.EnableLootWindowSkin`, `Y.DisableLootWindowSkin`, `Y.RefreshLootWindowSkin`
- Produces: skin follows loot mini-module; style changes refresh live window

- [ ] **Step 1: Wire `OnEnable` / `OnDisable`**

In `AugmentModule.lua` loot-on block (alongside `EnableEvents`):

```lua
if addon.Augment.EnableLootWindowSkin then addon.Augment.EnableLootWindowSkin() end
```

In `OnDisable` (alongside `RestoreBlizzard`):

```lua
if addon.Augment.DisableLootWindowSkin then addon.Augment.DisableLootWindowSkin() end
```

When `lootOn` is false but module enable still runs other subsystems, do **not** enable skin. If loot is toggled off via options without full module disable, ensure options path calls `DisableLootWindowSkin` (mirror how loot events are gated — check `OptionsAugment` apply path; if loot disable only stops events, add skin disable there too).

- [ ] **Step 2: Refresh from options**

In `Augment.ApplyAugmentOptions` after suppression apply:

```lua
if Augment.RefreshLootWindowSkin then Augment.RefreshLootWindowSkin() end
```

- [ ] **Step 3: Lazy load**

In `handlers.ADDON_LOADED` when `msg == "Blizzard_LootFrame"`:

```lua
if addon:IsModuleEnabled("augment")
    and addon.GetDB and addon.GetDB("augmentLootFrameEnabled", true) ~= false
    and Y.EnableLootWindowSkin
then
    Y.EnableLootWindowSkin()
end
```

Keep existing `ApplyBlizzardSuppression` call (toasts only).

- [ ] **Step 4: Implement restore in `DisableLootWindowSkin`**

```lua
function Y.DisableLootWindowSkin()
    skinActive = false
    for region in pairs(savedRegions) do
        if region and region.Show then pcall(region.Show, region) end
    end
    wipe(savedRegions)
    local frame = _G.LootFrame
    if frame then
        if frame._hsAugmentChromeStrip then frame._hsAugmentChromeStrip:Hide() end
        if frame._hsAugmentChromeBg then frame._hsAugmentChromeBg:Hide() end
        if frame.SetBackdrop then frame:SetBackdrop(nil) end
    end
    -- Note: hooksInstalled stays true (hooksecurefunc cannot unhook); skinActive gates work
end
```

- [ ] **Step 5: Full checklist from spec**

- [ ] Auto Loot off → window + clicks + Augment toast  
- [ ] Auto Loot on → still works  
- [ ] Style switch updates chrome  
- [ ] Disable Augment loot → art approximately restored  
- [ ] Suppress toasts on → no Blizzard loot toasts; window still works  
- [ ] Group roll UI unchanged  

- [ ] **Step 6: Commit**

```bash
git add modules/Augment/AugmentModule.lua modules/Augment/LootFrame/AugmentCore.lua modules/Augment/LootFrame/AugmentEvents.lua modules/Augment/LootFrame/AugmentLootWindowSkin.lua
git commit -m "feat(augment): wire loot window skin enable/disable lifecycle"
```

---

### Task 6: README capability line

**Files:**
- Modify: `README.md`, `README-wago.md`, `README-curseforge.md` (Augment section)

- [ ] **Step 1: Add one bullet under Augment**

```markdown
- **Styled personal loot window** — When Auto Loot is off, Blizzard’s loot window stays usable and picks up the same Compact / Framed / Accent look as your loot toasts.
```

Keep existing toast bullets; do not remove core Augment content.

- [ ] **Step 2: Commit**

```bash
git add README.md README-wago.md README-curseforge.md
git commit -m "docs: note Augment skinned personal loot window"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| Remove `KillBlizzardFrame(LootFrame)` | Task 1 |
| Toast suppression unchanged | Task 1 |
| In-place restyle heavy chrome | Tasks 2–4 |
| One style setting (`augmentToastStyle`) | Tasks 3–5 |
| Accent fidelity target | Tasks 3–4 (chrome + icon pads) |
| Shared helpers for later group rolls | Task 2 (`Skin*` API) |
| Keep Blizzard position / clicks / tooltips | Tasks 3–4 (no click replace) |
| No new master toggle | Task 5 (loot module gate) |
| Lifecycle enable/disable/options/lazy load | Task 5 |
| README if user-facing | Task 6 |
| Manual test checklist | Tasks 1, 3, 4, 5 |

**Placeholder scan:** none intentional. Midnight ScrollBox vs `LootButtonN` is handled with existence-guarded dual path in Task 4 (verify in-game; adjust hooks if FrameXML renamed `LootFrame_Update`).

**Type consistency:** `EnableLootWindowSkin` / `DisableLootWindowSkin` / `RefreshLootWindowSkin` / `SkinStripDefaultArt` / `SkinApplyWindowChrome` / `SkinApplySlotQuality` used consistently across tasks.
