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

local MAX_ROWS    = 8
local ROW_GAP     = 5
local BAND_PAD    = 8
local BULLET      = "\226\128\162"  -- U+2022, escaped so the file stays ASCII
local FALLBACK_W  = 300

local band, rows, lore

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
--- @return number width
local function ContentWidth()
    local parent = _G.QuestInfoFrame
    if parent and parent.GetWidth then
        local w = parent:GetWidth()
        if w and w > 50 then return w end
    end
    return FALLBACK_W
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
    band:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })

    band.accent = band:CreateTexture(nil, "ARTWORK")
    band.accent:SetWidth(2)
    band.accent:SetPoint("TOPLEFT", band, "TOPLEFT", 0, 0)
    band.accent:SetPoint("BOTTOMLEFT", band, "BOTTOMLEFT", 0, 0)

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
    b:SetBackdropColor(0.11, 0.11, 0.14, 0.90)
    b.accent:SetColorTexture(accentColor[1], accentColor[2], accentColor[3], 1)

    local countWidth = structured and 46 or 0
    local shown = math.min(#objectives, MAX_ROWS)
    local y = -BAND_PAD
    local used = BAND_PAD

    for i = 1, MAX_ROWS do
        local row = rows[i]
        if i <= shown then
            local o = objectives[i]

            row.text:ClearAllPoints()
            row.text:SetPoint("TOPLEFT", b, "TOPLEFT", BAND_PAD + 6, y)
            row.text:SetWidth(math.max(40, width - (BAND_PAD * 2) - 6 - countWidth))
            if structured then
                row.text:SetText(BULLET .. "  " .. o.text)
            else
                row.text:SetText(o.text)
            end
            row.text:SetTextColor(0.89, 0.89, 0.93, 1)
            ApplyFont(row.text, size)
            row.text:Show()

            local hasCount = structured and o.need and o.need > 1
            if hasCount then
                row.count:ClearAllPoints()
                row.count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -BAND_PAD, y)
                row.count:SetText(tostring(o.done or 0) .. "/" .. tostring(o.need))
                row.count:SetTextColor(0.54, 0.54, 0.60, 1)
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
-- Lore
-- ---------------------------------------------------------------------------

local function EnsureLore()
    if lore then return lore end
    local parent = _G.QuestInfoFrame
    if not parent then return nil end

    lore = CreateFrame("Button", "HorizonFlowLoreToggle", parent)
    lore:SetHeight(18)

    lore.label = lore:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lore.label:SetPoint("LEFT", lore, "LEFT", 0, 0)
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

local function StyleToggle(toggle, labelKey)
    toggle:SetWidth(ContentWidth())
    toggle.label:SetText(L[labelKey])
    toggle.label:SetTextColor(0.54, 0.54, 0.60, 1)
    ApplyFont(toggle.label, FontSize())
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
        StyleToggle(toggle, "FLOW_READ_FULL_TEXT")
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

    if not toggle then return shown end

    StyleToggle(toggle, "FLOW_HIDE_FULL_TEXT")
    toggle:ClearAllPoints()
    toggle:SetPoint("TOPLEFT", shown, "BOTTOMLEFT", 0, -6)
    return shown, toggle
end

--- Hide both surfaces. Called from Flow.Disable.
--- @return nil
function F.HideBand()
    if band then band:Hide() end
    if lore then lore:Hide() end
    local desc = _G.QuestInfoDescriptionText
    if desc and desc.Show then desc:Show() end
end
