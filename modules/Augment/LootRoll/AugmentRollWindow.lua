--[[
    Horizon Suite - Augment / Loot Roll - Roll List Window
    A small movable window listing who chose Need, Greed and the rest on every
    open roll, with each choice's list collapsible from its header.

    The button and tally-line tooltips answer "who needed this?" for one roll
    at a time, and only while the mouse is on it. In a raid with several rolls
    open at once, a player asked for something they can glance at instead
    (feature request, "Check N&G rolls player"). This is that.

    Data comes from the roll rows (R.GetActiveRolls), which already hold each
    roll's loot-history summary. The window keeps no copy of its own, so it can
    never show a roll the frames have released, and it inherits the tally's
    fail-closed join: a roll whose history cannot be matched shows no names.

    Layout:

        Loot rolls                                   [x]
        Thunderfury, Blessed Blade of the Windseeker
          [-] Need (2)
                Sarah                                91
                Mikhail                              47
          [-] Greed (1)
                Ines
          [+] Pass (1)

    Collapse state is per choice, not per roll, and saved: collapsing Pass once
    collapses it on every roll from then on.

    BuildModel is pure (no frames) so the test harness can check it.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local Y = addon.Augment
local R = Y.Roll
R.Window = R.Window or {}
local W = R.Window
local L = addon.L

-- ============================================================================
-- STATE KEYS
-- ============================================================================

Y.DB_KEYS.lootRollShowWindow      = true
Y.DB_KEYS.lootRollWindowPoint     = true
Y.DB_KEYS.lootRollWindowRelPoint  = true
Y.DB_KEYS.lootRollWindowX         = true
Y.DB_KEYS.lootRollWindowY         = true

-- Sections in display order. `buckets` are Tally buckets merged into one list:
-- off-spec Need came from the Need button, so it belongs under Need.
-- Need and Greed always show, even empty — "nobody needed" is an answer. The
-- rest show only when someone is in them. Pass and the undecided start
-- collapsed: they are the long, least interesting lists in a raid.
W.SECTIONS = {
    { key = "need",     buckets = { "need", "needOff" }, label = "LOOT_ROLL_TALLY_NEED",
      color = { 0.25, 0.75, 0.25 } },
    { key = "greed",    buckets = { "greed" },           label = "LOOT_ROLL_TALLY_GREED",
      color = { 0.90, 0.80, 0.32 } },
    { key = "transmog", buckets = { "transmog" },        label = "LOOT_ROLL_TALLY_TRANSMOG",
      color = { 1.00, 0.50, 1.00 }, hideEmpty = true },
    { key = "pass",     buckets = { "pass" },            label = "LOOT_ROLL_TALLY_PASS",
      color = { 0.60, 0.60, 0.60 }, hideEmpty = true, collapsedByDefault = true },
    { key = "waiting",  buckets = { "waiting" },         label = "LOOT_ROLL_WINDOW_WAITING",
      color = { 0.60, 0.60, 0.60 }, hideEmpty = true, collapsedByDefault = true },
}

for _, sec in ipairs(W.SECTIONS) do
    Y.DB_KEYS["lootRollWindowCollapsed_" .. sec.key] = true
end

local function Text(key, fallback)
    return (L and L[key]) or fallback
end

--- @return boolean
function W.IsEnabled()
    local D = addon.AUGMENT_DEFAULTS
    if not (addon.Platform and addon.Platform.Has("lootHistory")) then return false end
    return R.GetDB("lootRollShowWindow", D and D.lootRollShowWindow) == true
end

--- @param key string  Section key
--- @return boolean
function W.IsCollapsed(key)
    local default = false
    for _, sec in ipairs(W.SECTIONS) do
        if sec.key == key then default = sec.collapsedByDefault and true or false end
    end
    local v = R.GetDB("lootRollWindowCollapsed_" .. key, nil)
    if v == nil then return default end
    return v and true or false
end

--- @param key string  Section key
--- @return nil
function W.ToggleCollapsed(key)
    if addon.SetDB then addon.SetDB("lootRollWindowCollapsed_" .. key, not W.IsCollapsed(key)) end
    W.Refresh()
end

-- ============================================================================
-- MODEL
-- ============================================================================

--- Flatten the open rolls into the lines the window draws.
--- @param rolls table  From R.GetActiveRolls
--- @param isCollapsed function(key) -> boolean
--- @return table lines  Array of { kind = "item"|"header"|"player"|"note", ... }
function W.BuildModel(rolls, isCollapsed)
    local lines = {}
    local T = R.Tally
    for _, roll in ipairs(rolls or {}) do
        lines[#lines + 1] = { kind = "item", text = roll.name or "", quality = roll.quality }
        local summary = roll.summary
        if summary and summary.allPassed then
            lines[#lines + 1] = { kind = "note", text = Text("LOOT_ROLL_TALLY_ALL_PASSED", "Everyone passed") }
        elseif not (summary and summary.players) then
            -- No history match (or the tally is off): say so rather than
            -- drawing empty Need/Greed headers that look like "nobody rolled".
            lines[#lines + 1] = { kind = "note", text = Text("LOOT_ROLL_WINDOW_NO_DATA", "No roll data yet") }
        else
            for _, sec in ipairs(W.SECTIONS) do
                local list = T.PlayersIn(summary, sec.buckets)
                if #list > 0 or not sec.hideEmpty then
                    local collapsed = isCollapsed and isCollapsed(sec.key) or false
                    lines[#lines + 1] = {
                        kind = "header", section = sec.key, count = #list,
                        text = Text(sec.label, sec.key), color = sec.color,
                        collapsed = collapsed,
                    }
                    if not collapsed then
                        if #list == 0 then
                            lines[#lines + 1] = { kind = "note", text = Text("LOOT_ROLL_WHO_NOBODY", "Nobody yet"), indent = true }
                        end
                        for _, p in ipairs(list) do
                            lines[#lines + 1] = { kind = "player", player = p }
                        end
                    end
                end
            end
        end
    end
    if #lines == 0 then
        lines[1] = { kind = "note", text = Text("LOOT_ROLL_WINDOW_EMPTY", "No rolls in progress") }
    end
    return lines
end

-- ============================================================================
-- FRAME
-- Everything below needs the WoW UI; the test harness never reaches it.
-- ============================================================================

local WIDTH        = 230
local MAX_HEIGHT   = 420
local TITLE_HEIGHT = 22
local PAD          = 8
local INDENT       = 14

local DEFAULT_POINT, DEFAULT_REL, DEFAULT_X, DEFAULT_Y = "TOPLEFT", "CENTER", 260, 220

local window, scroll, content, font, titleFont
local linePool = {}
local manuallyOpen = false   -- /h roll list, or the options button
local dismissed    = false   -- closed with [x] until the next new roll
local seenRolls    = {}      -- rollIDs already announced, so a refresh is not a "new roll"

local function LineHeight()
    return math.max(9, R.GetFontSize() - 1) + 5
end

local function UpdateFonts()
    if not font then return end
    local size = math.max(9, R.GetFontSize() - 1)
    font:SetFont(R.GetFontPath(), size, R.GetFontFlags())
    titleFont:SetFont(R.GetFontPath(), size + 1, R.GetFontFlags())
end

local function SavePosition()
    if not (window and addon.SetDB) then return end
    local point, _, relPoint, x, y = window:GetPoint(1)
    if not point then return end
    addon.SetDB("lootRollWindowPoint", point)
    addon.SetDB("lootRollWindowRelPoint", relPoint)
    addon.SetDB("lootRollWindowX", math.floor((x or 0) + 0.5))
    addon.SetDB("lootRollWindowY", math.floor((y or 0) + 0.5))
end

local function RestorePosition()
    if not window then return end
    local point    = R.GetDB("lootRollWindowPoint", nil) or DEFAULT_POINT
    local relPoint = R.GetDB("lootRollWindowRelPoint", nil) or DEFAULT_REL
    local x        = tonumber(R.GetDB("lootRollWindowX", nil)) or DEFAULT_X
    local y        = tonumber(R.GetDB("lootRollWindowY", nil)) or DEFAULT_Y
    window:ClearAllPoints()
    window:SetPoint(point, UIParent, relPoint, x, y)
end

--- @return nil
function W.ResetPosition()
    if addon.SetDB then
        addon.SetDB("lootRollWindowPoint", nil)
        addon.SetDB("lootRollWindowRelPoint", nil)
        addon.SetDB("lootRollWindowX", nil)
        addon.SetDB("lootRollWindowY", nil)
    end
    RestorePosition()
end

local function CreateLine()
    local b = CreateFrame("Button", nil, content)
    b:SetHeight(LineHeight())

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(11, 11)
    icon:SetPoint("LEFT", b, "LEFT", 0, 0)
    icon:Hide()
    b.icon = icon

    local left = b:CreateFontString(nil, "OVERLAY")
    left:SetFontObject(font)
    left:SetJustifyH("LEFT")
    left:SetWordWrap(false)
    b.left = left

    local right = b:CreateFontString(nil, "OVERLAY")
    right:SetFontObject(font)
    right:SetJustifyH("RIGHT")
    right:SetPoint("RIGHT", b, "RIGHT", 0, 0)
    right:SetTextColor(0.8, 0.8, 0.8, 1)
    b.right = right

    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(b)
    hl:SetColorTexture(1, 1, 1, 0.06)
    b.hl = hl

    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", function(self)
        if self.section then W.ToggleCollapsed(self.section) end
    end)
    return b
end

local function GetLine(i)
    if not linePool[i] then linePool[i] = CreateLine() end
    return linePool[i]
end

local function DrawLine(b, line)
    local indent = 0
    b.section = nil
    b.icon:Hide()
    b.hl:Hide()
    b:EnableMouse(false)
    b.right:SetText("")
    b.left:SetTextColor(1, 1, 1, 1)

    if line.kind == "item" then
        local c = R.QUALITY_COLORS and (R.QUALITY_COLORS[tonumber(line.quality) or 1] or R.QUALITY_COLORS[1])
        b.left:SetText(line.text)
        if c then b.left:SetTextColor(c[1], c[2], c[3], 1) end
    elseif line.kind == "header" then
        indent = 4
        b.section = line.section
        b:EnableMouse(true)
        b.hl:Show()
        b.icon:SetTexture(line.collapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
        b.icon:ClearAllPoints()
        b.icon:SetPoint("LEFT", b, "LEFT", indent, 0)
        b.icon:Show()
        indent = indent + 14
        local c = line.color or { 1, 1, 1 }
        b.left:SetText(("%s (%d)"):format(line.text, line.count or 0))
        b.left:SetTextColor(c[1], c[2], c[3], 1)
    elseif line.kind == "player" then
        indent = 4 + INDENT + 4
        local p = line.player
        b.left:SetText(R.Tally.FormatPlayerName(p))
        if p.roll then b.right:SetText(tostring(p.roll)) end
    else
        indent = line.indent and (4 + INDENT + 4) or 4
        b.left:SetText(line.text or "")
        b.left:SetTextColor(0.6, 0.6, 0.6, 1)
    end

    b.left:ClearAllPoints()
    b.left:SetPoint("LEFT", b, "LEFT", indent, 0)
    b.left:SetPoint("RIGHT", b.right, "LEFT", -4, 0)
end

local function Build()
    if window then return end

    font = CreateFont("HorizonSuiteRollWindowFont")
    titleFont = CreateFont("HorizonSuiteRollWindowTitleFont")
    UpdateFonts()

    window = CreateFrame("Frame", "HorizonSuiteRollWindow", UIParent, "BackdropTemplate")
    window:SetSize(WIDTH, 120)
    window:SetFrameStrata("MEDIUM")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:Hide()
    if window.SetBackdrop then
        window:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        window:SetBackdropColor(0.05, 0.05, 0.07, 0.9)
        window:SetBackdropBorderColor(1, 1, 1, 0.15)
    end

    -- Title bar doubles as the drag handle.
    local title = CreateFrame("Frame", nil, window)
    title:SetPoint("TOPLEFT", window, "TOPLEFT", 0, 0)
    title:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
    title:SetHeight(TITLE_HEIGHT)
    title:EnableMouse(true)
    title:RegisterForDrag("LeftButton")
    title:SetScript("OnDragStart", function() window:StartMoving() end)
    title:SetScript("OnDragStop", function()
        window:StopMovingOrSizing()
        SavePosition()
    end)

    local titleText = title:CreateFontString(nil, "OVERLAY")
    titleText:SetFontObject(titleFont)
    titleText:SetPoint("LEFT", title, "LEFT", PAD, 0)
    titleText:SetText(Text("LOOT_ROLL_WINDOW_TITLE", "Loot rolls"))
    titleText:SetTextColor(0.95, 0.65, 0.25, 1)

    local close = CreateFrame("Button", nil, title, "UIPanelCloseButton")
    close:SetSize(20, 20)
    close:SetPoint("RIGHT", title, "RIGHT", -1, 0)
    close:SetScript("OnClick", function()
        manuallyOpen = false
        dismissed = true
        window:Hide()
    end)

    local divider = title:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.1)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT", title, "BOTTOMLEFT", 1, 0)
    divider:SetPoint("BOTTOMRIGHT", title, "BOTTOMRIGHT", -1, 0)

    -- Grows to fit up to MAX_HEIGHT, then scrolls with the mouse wheel. A
    -- 25-player raid can put twenty names under one Need header.
    scroll = CreateFrame("ScrollFrame", nil, window)
    scroll:SetPoint("TOPLEFT", window, "TOPLEFT", PAD, -(TITLE_HEIGHT + 4))
    scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -PAD, PAD)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = self:GetVerticalScrollRange() or 0
        local v = (self:GetVerticalScroll() or 0) - delta * LineHeight() * 3
        self:SetVerticalScroll(math.max(0, math.min(max, v)))
    end)

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(WIDTH - 2 * PAD, 1)
    scroll:SetScrollChild(content)

    RestorePosition()
end

local function ShouldShow(hasRolls)
    if manuallyOpen then return true end
    if dismissed or not W.IsEnabled() then return false end
    return hasRolls
end

--- Redraw from the live rows. Cheap enough to call on every tally update.
--- @return nil
function W.Refresh()
    local rolls = R.GetActiveRolls and R.GetActiveRolls() or {}
    if #rolls == 0 then
        dismissed = false
        seenRolls = {}
    end

    if not ShouldShow(#rolls > 0) then
        if window then window:Hide() end
        return
    end
    Build()

    local lines = W.BuildModel(rolls, W.IsCollapsed)
    local h = LineHeight()
    local y = 0
    for i, line in ipairs(lines) do
        local b = GetLine(i)
        -- A little air above each item after the first, so rolls read as blocks.
        if line.kind == "item" and i > 1 then y = y + math.floor(h / 2) end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        b:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
        b:SetHeight(h)
        DrawLine(b, line)
        b:Show()
        y = y + h
    end
    for i = #lines + 1, #linePool do linePool[i]:Hide() end

    content:SetHeight(math.max(1, y))
    local height = math.min(MAX_HEIGHT, TITLE_HEIGHT + 4 + y + PAD)
    window:SetHeight(height)
    local max = scroll:GetVerticalScrollRange() or 0
    if (scroll:GetVerticalScroll() or 0) > max then scroll:SetVerticalScroll(max) end

    window:SetScale(R.GetScale())
    window:SetAlpha(R.GetOpacity())
    window:Show()
end

--- A roll got a row. A new roll brings a closed window back; the same roll
--- being redrawn does not.
--- @param rollID number
--- @return nil
function W.OnRollShown(rollID)
    if rollID and not seenRolls[rollID] then
        seenRolls[rollID] = true
        dismissed = false
    end
    W.Refresh()
end

--- Open or close the window by hand. Works with the option off and with no
--- rolls open, so a player can place it before the raid.
--- @return nil
function W.Toggle()
    if window and window:IsShown() then
        manuallyOpen = false
        dismissed = true
        window:Hide()
        return
    end
    manuallyOpen = true
    dismissed = false
    W.Refresh()
end

--- Re-apply fonts, scale and visibility after an options change.
--- @return nil
function W.ApplyOptions()
    UpdateFonts()
    if window then
        for _, b in ipairs(linePool) do
            b.left:SetFontObject(font)
            b.right:SetFontObject(font)
        end
    end
    W.Refresh()
end

--- @return nil
function W.Hide()
    manuallyOpen = false
    if window then window:Hide() end
end
