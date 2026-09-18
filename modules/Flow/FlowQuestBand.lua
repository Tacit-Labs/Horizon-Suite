--[[
    Horizon Suite - Flow - Objectives band and lore expander

    Both surfaces are supplied to Blizzard as QuestInfo *template elements*
    rather than painted over the finished frame. An element function returns the
    frame it laid out, and Blizzard anchors the next element below whatever came
    back, so supplying our own frames lets Blizzard's own layout pass size around
    them. Painting afterwards would change heights that had already been used to
    position everything below.

    Read-only quest API only: C_QuestLog.GetQuestObjectives, GetQuestID,
    GetObjectiveText. Nothing here accepts a quest or grants a reward.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow
local L = addon.L

local MAX_ROWS   = 8
local ROW_GAP    = 6
local BAND_PAD   = 13
local FALLBACK_W = 380

-- Card surface shared by the objectives block, the lore line and the rewards
-- block, so the three read as one system rather than three treatments.
local CARD_BG     = { 0.11, 0.11, 0.14, 0.95 }
local CARD_BORDER = { 0.15, 0.15, 0.18, 1 }

local CARD_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local band, rows, lore, title, titleRule

--- Apply the shared card surface to a BackdropTemplate frame.
--- @param frame Frame
--- @return nil
function F.StyleCard(frame)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop(CARD_BACKDROP)
    frame:SetBackdropColor(CARD_BG[1], CARD_BG[2], CARD_BG[3], CARD_BG[4])
    frame:SetBackdropBorderColor(CARD_BORDER[1], CARD_BORDER[2], CARD_BORDER[3], CARD_BORDER[4])
end

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

local function FontSize()
    return tonumber(addon.GetDB and addon.GetDB("flowFontSize", 13)) or 13
end

--- Uses FlowCore's resolver so the band, the title and the lore line all follow
--- the same per-module-then-global font chain.
local function ApplyFont(fontString, size)
    local path = F.GetFontPath and F.GetFontPath()
    if not path or not fontString or not fontString.SetFont then return end
    pcall(fontString.SetFont, fontString, path, size, "")
end

--- Width Blizzard expects a quest info element to occupy.
---
--- This is the template's content column, NOT QuestInfoFrame's width.
--- QuestInfoFrame is SetAllPoints to the whole panel, so measuring it makes
--- every element overhang the scroll area and clips whatever sits at the right
--- edge.
--- @return number width
local function ContentWidth()
    if F.GetContentWidth then
        local w = F.GetContentWidth()
        if w and w > 50 then return w end
    end
    return FALLBACK_W
end

--- Split a leading "3/8 " progress prefix off an objective.
---
--- GetQuestObjectives returns text that already carries the count, so rendering
--- a separate right-aligned column without stripping it shows the number twice.
--- @param text string
--- @return string body, string|nil count
local function SplitCount(text)
    local done, need, rest = text:match("^(%d+)%s*/%s*(%d+)%s+(.+)$")
    if done and rest then return rest, done .. "/" .. need end
    return text, nil
end

-- ---------------------------------------------------------------------------
-- Objectives
-- ---------------------------------------------------------------------------

--- Objectives for the quest currently on offer or in progress.
---
--- Blizzard's own giver templates only ever show the prose blob from
--- GetObjectiveText, because the bulleted path reads the selected quest log
--- entry and an unaccepted quest is not in the log. The structured data is
--- still reachable by questID, which is why this prefers GetQuestObjectives and
--- keeps the blob as a fallback.
---
--- @return table entries Array of { text = string, done = number|nil, need = number|nil }
--- @return boolean structured True when entries came from GetQuestObjectives
local function ReadObjectives()
    local out = {}

    local questID = _G.GetQuestID and _G.GetQuestID()
    if questID and questID > 0 and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, objectives = pcall(C_QuestLog.GetQuestObjectives, questID)
        if ok and type(objectives) == "table" then
            for i = 1, #objectives do
                local o = objectives[i]
                if type(o) == "table" and type(o.text) == "string" and o.text ~= "" then
                    out[#out + 1] = { text = o.text, done = o.numFulfilled, need = o.numRequired }
                end
            end
        end
    end
    if #out > 0 then return out, true end

    local blob = _G.GetObjectiveText and _G.GetObjectiveText()
    if type(blob) == "string" and blob ~= "" then
        return { { text = blob } }, false
    end
    return out, false
end

local function EnsureBand()
    if band then return band end
    local parent = _G.QuestInfoFrame
    if not parent then return nil end

    band = CreateFrame("Frame", "HorizonFlowObjectivesBand", parent, "BackdropTemplate")
    F.StyleCard(band)

    rows = {}
    for i = 1, MAX_ROWS do
        local text  = band:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        local count = band:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetJustifyH("LEFT")
        text:SetJustifyV("TOP")
        count:SetJustifyH("RIGHT")
        rows[i] = { text = text, count = count }
    end

    return band
end

--- QuestInfo template element: the objectives band.
--- Signature and return value follow Blizzard's element contract.
--- @return Frame|nil shownFrame Nil tells Blizzard to skip this element
function F.ShowObjectivesBand()
    local b = EnsureBand()
    if not b then return nil end

    local objectives, structured = ReadObjectives()
    if #objectives == 0 then
        b:Hide()
        return nil
    end

    local width = ContentWidth()
    local size  = FontSize()
    local accentColor = F.GetAccentColor and { F.GetAccentColor() } or { 0.2, 0.6, 1.0 }

    b:SetWidth(width)
    F.StyleCard(b)

    local countWidth = 50
    local shown = math.min(#objectives, MAX_ROWS)
    local y = -BAND_PAD
    local used = BAND_PAD

    for i = 1, MAX_ROWS do
        local row = rows[i]
        if i <= shown then
            local o = objectives[i]
            local body, count = o.text, nil
            if structured then
                body, count = SplitCount(o.text)
                if not count and o.need and o.need > 1 then
                    count = tostring(o.done or 0) .. "/" .. tostring(o.need)
                end
            end

            row.text:ClearAllPoints()
            row.text:SetPoint("TOPLEFT", b, "TOPLEFT", BAND_PAD, y)
            row.text:SetWidth(math.max(40, width - (BAND_PAD * 2) - (count and countWidth or 0)))
            row.text:SetText(body)
            row.text:SetTextColor(0.89, 0.89, 0.93, 1)
            ApplyFont(row.text, size)
            row.text:Show()

            if count then
                row.count:ClearAllPoints()
                row.count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -BAND_PAD, y)
                row.count:SetText(count)
                row.count:SetTextColor(accentColor[1], accentColor[2], accentColor[3], 1)
                ApplyFont(row.count, size)
                row.count:Show()
            else
                row.count:Hide()
            end

            -- Read the height back rather than assuming one line: a long
            -- objective wraps inside the width set above.
            local rowHeight = math.max(size + 2, row.text:GetStringHeight() or (size + 2))
            y    = y - rowHeight - ROW_GAP
            used = used + rowHeight + ROW_GAP
        else
            row.text:Hide()
            row.count:Hide()
        end
    end

    b:SetHeight(math.max(size + (BAND_PAD * 2), used - ROW_GAP + BAND_PAD))
    b:Show()
    return b
end

-- ---------------------------------------------------------------------------
-- Title
-- ---------------------------------------------------------------------------

--- QuestInfo template element: the quest title, centred, with an accent rule
--- beneath it. Blizzard positions the title; the rule is anchored under it by
--- hand and handed back as `bottomShownFrame` so the next element clears both.
--- @return Frame|nil shownFrame
--- @return Frame|nil bottomShownFrame
function F.ShowTitle()
    local original = F.GetOriginalElement and F.GetOriginalElement("title")
    if type(original) ~= "function" then return nil end

    local ok, shown = pcall(original)
    if not ok or not shown then return nil end

    title = _G.QuestInfoTitleHeader or shown
    if title and title.SetWidth then
        title:SetWidth(ContentWidth())
        title:SetJustifyH("CENTER")
        if title.SetTextColor then title:SetTextColor(0.94, 0.94, 0.96, 1) end
        ApplyFont(title, FontSize() + 3)
    end

    local parent = _G.QuestInfoFrame
    if not parent then return shown end

    if not titleRule then
        titleRule = CreateFrame("Frame", "HorizonFlowTitleRule", parent)
        titleRule:SetHeight(8)
        titleRule.line = titleRule:CreateTexture(nil, "OVERLAY")
        titleRule.line:SetSize(28, 2)
        titleRule.line:SetPoint("TOP", titleRule, "TOP", 0, 0)
    end

    local ar, ag, ab = 0.20, 0.60, 1.00
    if F.GetAccentColor then ar, ag, ab = F.GetAccentColor() end
    titleRule.line:SetColorTexture(ar, ag, ab, 1)
    titleRule:SetWidth(ContentWidth())
    titleRule:ClearAllPoints()
    titleRule:SetPoint("TOPLEFT", shown, "BOTTOMLEFT", 0, -7)
    titleRule:Show()

    return shown, titleRule
end

-- ---------------------------------------------------------------------------
-- Lore
-- ---------------------------------------------------------------------------

local function EnsureLore()
    if lore then return lore end
    local parent = _G.QuestInfoFrame
    if not parent then return nil end

    lore = CreateFrame("Button", "HorizonFlowLoreToggle", parent, "BackdropTemplate")
    lore:SetHeight(28)

    lore.label = lore:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lore.label:SetPoint("LEFT", lore, "LEFT", BAND_PAD, 0)
    lore.label:SetJustifyH("LEFT")

    lore:SetScript("OnClick", function()
        local collapsed = addon.GetDB and addon.GetDB("flowCollapseLore", true)
        if addon.SetDB then addon.SetDB("flowCollapseLore", not collapsed) end
        if F.RedisplayQuestInfo then F.RedisplayQuestInfo() end
    end)

    lore:SetScript("OnEnter", function(self)
        self.label:SetTextColor(0.89, 0.89, 0.93, 1)
    end)
    lore:SetScript("OnLeave", function(self)
        self.label:SetTextColor(0.54, 0.54, 0.60, 1)
    end)

    return lore
end

local CHEVRON = "\226\128\186"  -- U+203A, escaped so the file stays ASCII

local function StyleToggle(toggle, labelKey, asCard)
    toggle:SetWidth(ContentWidth())
    toggle.label:SetText(CHEVRON .. "  " .. L[labelKey])
    toggle.label:SetTextColor(0.43, 0.43, 0.48, 1)
    ApplyFont(toggle.label, FontSize())
    if asCard then
        F.StyleCard(toggle)
        toggle:SetHeight(28)
    else
        toggle:SetBackdrop(nil)
        toggle:SetHeight(20)
    end
    toggle:Show()
end

--- QuestInfo template element: the flavour text, or the line that reveals it.
---
--- Blizzard's loop anchors the next element below `bottomShownFrame` when one
--- is returned, and only ever sets points on `shownFrame`. So in the expanded
--- case the description is handed back as the positioned frame and the toggle
--- is anchored under it by hand, which keeps a way to collapse again without
--- going to the options panel.
---
--- @return Frame|nil shownFrame
--- @return Frame|nil bottomShownFrame
function F.ShowLore()
    local collapsed = addon.GetDB and addon.GetDB("flowCollapseLore", true)
    local toggle = EnsureLore()
    local desc = _G.QuestInfoDescriptionText

    if collapsed then
        if desc and desc.Hide then desc:Hide() end
        if not toggle then return nil end
        StyleToggle(toggle, "FLOW_READ_FULL_TEXT", true)
        return toggle
    end

    local original = F.GetOriginalElement and F.GetOriginalElement("description")
    if type(original) ~= "function" then
        if toggle then toggle:Hide() end
        return nil
    end

    local ok, shown = pcall(original)
    if not ok or not shown then
        if toggle then toggle:Hide() end
        return nil
    end

    -- Blizzard fades the quest description in from alpha 0, driven by an
    -- OnUpdate that only runs on the normal QUEST_DETAIL flow. The expander
    -- re-runs QuestInfo_Display directly, so that driver never ticks and the
    -- text stays invisible: laid out, sized, alpha 0. Force it visible rather
    -- than relying on a fade that is not going to happen.
    if shown.Show then shown:Show() end
    if shown.SetAlpha then shown:SetAlpha(1) end
    if _G.QuestInfoFrame then
        _G.QuestInfoFrame.fadingFrame = nil
        _G.QuestInfoFrame.fading = nil
    end

    if shown.SetWidth then shown:SetWidth(ContentWidth()) end
    if shown.SetTextColor then shown:SetTextColor(0.60, 0.60, 0.66, 1) end
    ApplyFont(shown, FontSize())

    if not toggle then return shown end

    StyleToggle(toggle, "FLOW_HIDE_FULL_TEXT", false)
    toggle:ClearAllPoints()
    toggle:SetPoint("TOPLEFT", shown, "BOTTOMLEFT", 0, -6)
    return shown, toggle
end

--- Hide every surface Flow draws. Called from Flow.Disable.
--- @return nil
function F.HideBand()
    if band then band:Hide() end
    if lore then lore:Hide() end
    if titleRule then titleRule:Hide() end
    local desc = _G.QuestInfoDescriptionText
    if desc and desc.Show then desc:Show() end
    if title and title.SetJustifyH then title:SetJustifyH("LEFT") end
end

--- The frames Flow draws, for the layout pass to measure.
--- @return table frames
function F.GetDrawnFrames()
    return { band, lore, titleRule }
end
