--[[
    Horizon Suite - Augment / Loot Roll - Frames
    Frame pool, chrome, roll buttons and timer bar for group loot rolls.

    Nothing here is secure or protected. RollOnLoot is an unprotected call and
    these frames use no secure templates, so unlike Alerts there is NO combat
    deferral anywhere in this module — rolls land mid-pull constantly and a
    deferred roll frame is a missed roll.

    Layout per row (icon side left; mirrored when the icon sits right):

        [icon] Item Name                      [Need][Greed][Pass]
               new look  +13 ilvl   2 Need 1 Greed
        [================= timer bar =====================]
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local Y = addon.Augment
local R = Y.Roll
local M = Y.ToastMotion
local L = addon.L

local pool = {}
local framesCreated = false
local Frame
local RollFont

-- Scale helper, matching AugmentCore's S().
local function S(v)
    return v * (R.GetScale and R.GetScale() or 1)
end

local function RowHeight()
    return math.max(R.GetIconSize() + M.CHROME_HEIGHT_PAD, R.GetIconSize()) + R.ROW_PAD
end

local function LineHeight()
    return RowHeight() + R.LINE_SPACING
end

-- ============================================================================
-- FONT
-- ============================================================================

local function UpdateFontObject()
    if not RollFont then return end
    RollFont:SetFont(R.GetFontPath(), S(R.GetFontSize()), R.GetFontFlags())
end

-- ============================================================================
-- BUTTONS
-- ============================================================================

local BUTTON_ORDER = { R.ROLL_NEED, R.ROLL_GREED, R.ROLL_TRANSMOG, R.ROLL_DISENCHANT, R.ROLL_PASS }

local BUTTON_LABEL = {
    [R.ROLL_NEED]       = function() return _G.NEED or "Need" end,
    [R.ROLL_GREED]      = function() return _G.GREED or "Greed" end,
    [R.ROLL_TRANSMOG]   = function() return _G.TRANSMOGRIFY or "Transmogrify" end,
    [R.ROLL_DISENCHANT] = function() return _G.ROLL_DISENCHANT or "Disenchant" end,
    [R.ROLL_PASS]       = function() return _G.PASS or "Pass" end,
}

local function SetButtonEnabled(button, enabled, reason)
    button.reason = reason
    if enabled then
        button:Enable()
        button:SetAlpha(1.0)
        if button.icon then button.icon:SetDesaturated(false) end
    else
        button:Disable()
        button:SetAlpha(0.35)
        if button.icon then button.icon:SetDesaturated(true) end
    end
end

local function CreateRollButton(parent, rollType)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(S(R.BUTTON_SIZE), S(R.BUTTON_SIZE))
    b.rollType = rollType

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(b)
    R.ApplyButtonArt(icon, rollType, R.BUTTON_ATLASES)
    b.icon = icon

    local highlight = b:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(b)
    if not R.ApplyButtonArt(highlight, rollType, R.BUTTON_HIGHLIGHT_ATLASES) then
        highlight:SetColorTexture(1, 1, 1, 0.18)
    else
        highlight:SetBlendMode("ADD")
    end

    b:SetScript("OnEnter", function(self)
        local row = self:GetParent()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local label = BUTTON_LABEL[self.rollType] and BUTTON_LABEL[self.rollType]() or ""
        GameTooltip:SetText(label, 1, 1, 1)
        if self.reason then
            GameTooltip:AddLine(self.reason, 1, 0.3, 0.3, true)
        elseif row and row.demo then
            GameTooltip:AddLine((L and L["LOOT_ROLL_DEMO_BUTTON_INERT"]) or
                "Demo roll — this button does nothing.", 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    b:SetScript("OnClick", function(self)
        local row = self:GetParent()
        if not row or not row.rollID then return end
        -- A demo row must never touch the real roll API: its rollID is
        -- fabricated and would address somebody else's live roll.
        if row.demo then return end
        if RollOnLoot then pcall(RollOnLoot, row.rollID, self.rollType) end
        if R.Core and R.Core.OnRolled then R.Core.OnRolled(row.rollID, self.rollType) end
    end)

    return b
end

-- ============================================================================
-- ROW CREATION
-- ============================================================================

local function CreateRow(parent)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(S(R.GetWidth()), S(RowHeight()))
    f:Hide()

    -- Icon plate. iconBg/iconDark are the regions TS.ApplyChrome expects for
    -- the Compact and Accent styles; Framed hides them itself.
    local iconBg = f:CreateTexture(nil, "BORDER")
    iconBg:Hide()
    local iconDark = f:CreateTexture(nil, "ARTWORK", nil, -1)
    iconDark:SetColorTexture(0, 0, 0, 0.85)
    iconDark:Hide()
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Stack count, bottom-right of the icon, as Blizzard draws it.
    local count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
    count:Hide()

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFontObject(RollFont)
    title:SetWordWrap(false)

    local body = f:CreateFontString(nil, "OVERLAY")
    body:SetFontObject(RollFont)
    body:SetTextColor(0.85, 0.85, 0.85, 1)
    body:SetWordWrap(false)

    -- Button bar, packed from the edge opposite the icon.
    local bar = CreateFrame("Frame", nil, f)
    bar:SetSize(1, S(R.BUTTON_SIZE))
    local buttons = {}
    for _, rollType in ipairs(BUTTON_ORDER) do
        buttons[rollType] = CreateRollButton(f, rollType)
        buttons[rollType]:Hide()
    end

    local timer = CreateFrame("StatusBar", nil, f)
    timer:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    timer:SetMinMaxValues(0, 1)
    timer:SetValue(1)
    timer:SetHeight(S(R.TIMER_HEIGHT))

    local timerBg = timer:CreateTexture(nil, "BACKGROUND")
    timerBg:SetAllPoints(timer)
    timerBg:SetColorTexture(0, 0, 0, 0.5)

    -- Hovering the icon shows the item, exactly as Blizzard's roll frame does.
    local iconHit = CreateFrame("Button", nil, f)
    iconHit:SetScript("OnEnter", function(self)
        local row = self:GetParent()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local shown = false
        if row.demo then
            if row.itemLink then
                shown = pcall(GameTooltip.SetHyperlink, GameTooltip, row.itemLink)
            end
        elseif row.rollID and GameTooltip.SetLootRollItem then
            shown = pcall(GameTooltip.SetLootRollItem, GameTooltip, row.rollID)
        end
        if not shown and row.itemLink then
            pcall(GameTooltip.SetHyperlink, GameTooltip, row.itemLink)
        end
        GameTooltip:Show()
    end)
    iconHit:SetScript("OnLeave", function() GameTooltip:Hide() end)
    iconHit:RegisterForClicks("LeftButtonUp")
    iconHit:SetScript("OnClick", function(self)
        local row = self:GetParent()
        if IsModifiedClick and IsModifiedClick("CHATLINK") and row.itemLink then
            if ChatEdit_InsertLink then ChatEdit_InsertLink(row.itemLink) end
        end
    end)

    return {
        frame = f, icon = icon, iconBg = iconBg, iconDark = iconDark,
        count = count, title = title, body = body,
        bar = bar, buttons = buttons, timer = timer, iconHit = iconHit,
        active = false,
    }
end

-- ============================================================================
-- LAYOUT
-- ============================================================================

-- TS.ApplyChrome anchors dual text from the icon to the frame's far edge, which
-- would run the item name underneath the roll buttons. Re-anchor both lines to
-- stop at the button bar instead. Called after ApplyChrome, never before.
local function ReanchorText(row, iconSide)
    local anchor = row.iconBg and row.iconBg:IsShown() and row.iconBg or row.icon
    local gap = S(R.GetIconGap())
    local edge = M.EDGE

    row.title:ClearAllPoints()
    row.body:ClearAllPoints()

    if iconSide == "right" then
        row.title:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -gap, -2)
        row.title:SetPoint("LEFT", row.bar, "RIGHT", edge, 0)
        row.body:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -gap, 2)
        row.body:SetPoint("LEFT", row.bar, "RIGHT", edge, 0)
    else
        row.title:SetPoint("TOPLEFT", anchor, "TOPRIGHT", gap, -2)
        row.title:SetPoint("RIGHT", row.bar, "LEFT", -edge, 0)
        row.body:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", gap, 2)
        row.body:SetPoint("RIGHT", row.bar, "LEFT", -edge, 0)
    end
end

-- Pack the visible buttons into the bar and anchor the bar to the far edge.
local function LayoutButtons(row, iconSide)
    local size = S(R.BUTTON_SIZE)
    local gap = S(R.BUTTON_GAP)
    local visible = {}
    for _, rollType in ipairs(BUTTON_ORDER) do
        local b = row.buttons[rollType]
        if b:IsShown() then visible[#visible + 1] = b end
    end

    local width = #visible > 0 and (#visible * size + (#visible - 1) * gap) or 1
    row.bar:SetSize(width, size)
    row.bar:ClearAllPoints()
    if iconSide == "right" then
        row.bar:SetPoint("LEFT", row.frame, "LEFT", M.EDGE, S(R.TIMER_HEIGHT) / 2)
    else
        row.bar:SetPoint("RIGHT", row.frame, "RIGHT", -M.EDGE, S(R.TIMER_HEIGHT) / 2)
    end

    for i, b in ipairs(visible) do
        b:SetSize(size, size)
        b:ClearAllPoints()
        b:SetPoint("LEFT", row.bar, "LEFT", (i - 1) * (size + gap), 0)
    end
end

local function LayoutRow(row, quality)
    local iconSide = R.GetIconSide()
    local colors = R.QUALITY_COLORS[quality or 1] or R.QUALITY_COLORS[1]
    local r, g, b = colors[1], colors[2], colors[3]

    local TS = Y.ToastStyles
    if TS and TS.ApplyChrome then
        TS.ApplyChrome(row, R.GetToastStyle(), { r = r, g = g, b = b }, {
            textMode  = "dual",
            iconSide  = iconSide,
            iconSize  = R.GetIconSize(),
            iconGap   = R.GetIconGap(),
            iconBgPad = R.ICON_BG_PAD,
            scale     = S,
        })
    end

    LayoutButtons(row, iconSide)
    ReanchorText(row, iconSide)

    -- The icon hit area tracks whatever the chrome anchored the icon to.
    row.iconHit:ClearAllPoints()
    row.iconHit:SetAllPoints(row.icon)

    row.timer:ClearAllPoints()
    row.timer:SetPoint("BOTTOMLEFT", row.frame, "BOTTOMLEFT", M.EDGE, M.EDGE / 2)
    row.timer:SetPoint("BOTTOMRIGHT", row.frame, "BOTTOMRIGHT", -M.EDGE, M.EDGE / 2)
    row.timer:SetHeight(S(R.TIMER_HEIGHT))
    row.timer:SetStatusBarColor(r, g, b, 0.9)
end

-- ============================================================================
-- POOL
-- ============================================================================

function R.InitFrames()
    if framesCreated then return end
    framesCreated = true

    RollFont = _G["HorizonSuiteLootRollFont"] or CreateFont("HorizonSuiteLootRollFont")
    UpdateFontObject()

    Frame = CreateFrame("Frame", "HorizonSuiteLootRollAnchor", UIParent)
    Frame:SetSize(S(R.GetWidth()), S(LineHeight()))
    Frame:SetFrameStrata("HIGH")
    Frame:Hide()
    Frame:SetClampedToScreen(true)
    R.ApplyStoredAnchor(Frame)

    for i = 1, R.POOL_SIZE do
        pool[i] = CreateRow(Frame)
        pool[i].title:SetFontObject(RollFont)
        pool[i].body:SetFontObject(RollFont)
    end

    Frame:SetScript("OnUpdate", function(self)
        local any = false
        for i = 1, R.POOL_SIZE do
            local row = pool[i]
            if row.active then
                any = true
                R.UpdateRowTimer(row)
            end
        end
        if not any and not R.IsEditing() then self:Hide() end
    end)

    R.Frame = Frame
    -- Font objects may not be resolved yet at login; re-apply next frame, the
    -- same deferral LootFrame and Alerts both use.
    C_Timer.After(0, function() R.ApplyScale() end)
end

--- @return boolean
function R.IsReady() return framesCreated end

--- @return table|nil
function R.GetAnchorFrame() return Frame end

local function Restack()
    if not framesCreated then return end   -- exported as R.Restack; see R.FindRow
    local visible = 0
    local attach = R.GetEntryAttachPoint()
    local growUp = (attach == "BOTTOM")
    for i = 1, R.POOL_SIZE do
        local row = pool[i]
        if row.active then
            local offset = visible * S(LineHeight())
            row.frame:ClearAllPoints()
            row.frame:SetPoint(attach, Frame, attach, 0, growUp and offset or -offset)
            visible = visible + 1
        end
    end
end
R.Restack = Restack

--- Find the pooled row showing a roll.
--- @param rollID number
--- @return table|nil
function R.FindRow(rollID)
    -- The pool is only built by InitFrames, which only runs once the module is
    -- enabled — and it ships disabled. Every public reader of the pool has to
    -- survive being called first: the platform probe, /h roll status and
    -- /h roll clear all reach here with the module off.
    if not framesCreated then return nil end
    for i = 1, R.POOL_SIZE do
        if pool[i].active and pool[i].rollID == rollID then return pool[i] end
    end
    return nil
end

local function AcquireRow()
    local cap = R.GetMaxVisible()
    for i = 1, cap do
        if not pool[i].active then return pool[i] end
    end
    return nil
end

-- ============================================================================
-- SHOW / UPDATE / RELEASE
-- ============================================================================

--- Render a roll. The descriptor is built by AugmentRollEvents.BuildRoll for
--- live rolls and by AugmentRollDemo for fabricated ones — identical shape, so
--- both take exactly this path.
--- @param roll table { rollID, rollTime, itemLink, texture, name, count, quality,
---                     bindOnPickUp, canNeed, canGreed, canDisenchant, canTransmog,
---                     reasonNeed, reasonGreed, reasonDisenchant, demo }
--- @return boolean shown  false when the visible cap is full
function R.ShowRoll(roll)
    if not framesCreated then return false end
    if type(roll) ~= "table" or not roll.rollID then return false end

    local row = R.FindRow(roll.rollID) or AcquireRow()
    if not row then return false end

    local quality = tonumber(roll.quality) or 1

    -- Keep the whole descriptor: the badge strip and every later relayout read
    -- fields (bindOnPickUp, itemLink, quality) that the row itself does not carry.
    row.roll         = roll
    row.rollID       = roll.rollID
    row.rollTime     = tonumber(roll.rollTime) or 0
    row.itemLink     = roll.itemLink
    row.quality      = quality
    row.demo         = roll.demo and true or false
    row.demoTally    = roll.demoTally
    row.startedAt    = GetTime and GetTime() or 0
    row.rolledAs     = nil

    row.icon:SetTexture(roll.texture)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    local colors = R.QUALITY_COLORS[quality] or R.QUALITY_COLORS[1]
    row.title:SetText(roll.name or "")
    row.title:SetTextColor(colors[1], colors[2], colors[3], 1)

    if (tonumber(roll.count) or 1) > 1 then
        row.count:SetText(roll.count)
        row.count:Show()
    else
        row.count:Hide()
    end

    -- Buttons: exactly what this item allows, as Blizzard's GroupLootFrame_OnShow
    -- decides it. Transmog REPLACES Greed rather than sitting beside it.
    local showTransmog = roll.canTransmog and true or false
    row.buttons[R.ROLL_NEED]:Show()
    SetButtonEnabled(row.buttons[R.ROLL_NEED], roll.canNeed, roll.reasonNeed)

    if showTransmog then
        row.buttons[R.ROLL_GREED]:Hide()
        row.buttons[R.ROLL_TRANSMOG]:Show()
        SetButtonEnabled(row.buttons[R.ROLL_TRANSMOG], true, nil)
    else
        row.buttons[R.ROLL_TRANSMOG]:Hide()
        row.buttons[R.ROLL_GREED]:Show()
        SetButtonEnabled(row.buttons[R.ROLL_GREED], roll.canGreed, roll.reasonGreed)
    end

    -- Disenchant needs no client branch: retail dropped DE rolls and a vanilla
    -- world never had them, so canDisenchant is false on both and the button
    -- simply never draws. If some content does offer it, it works.
    if roll.canDisenchant then
        row.buttons[R.ROLL_DISENCHANT]:Show()
        SetButtonEnabled(row.buttons[R.ROLL_DISENCHANT], true, nil)
    else
        row.buttons[R.ROLL_DISENCHANT]:Hide()
    end

    row.buttons[R.ROLL_PASS]:Show()
    SetButtonEnabled(row.buttons[R.ROLL_PASS], true, nil)

    LayoutRow(row, quality)
    R.RefreshRowInfoLine(row, roll)

    row.timer:SetMinMaxValues(0, math.max(1, row.rollTime))
    row.timer:SetValue(row.rollTime)

    row.frame:SetAlpha(R.GetOpacity())
    row.active = true
    row.frame:Show()
    Frame:Show()
    Restack()
    return true
end

--- Rebuild the badges + tally line for a row.
--- @param row table
--- @param roll table|nil  Descriptor; falls back to what the row already holds
--- @return nil
function R.RefreshRowInfoLine(row, roll)
    if not row then return end
    roll = roll or row.roll
    if not roll then return end
    local parts = {}

    local badges = R.Badges and R.Badges.Build and R.Badges.Build(roll) or ""
    if badges ~= "" then parts[#parts + 1] = badges end

    if R.IsTallyEnabled() and not row.demo then
        local line = R.Tally and R.Tally.FormatLine(R.Tally.ForItemLink(row.itemLink)) or ""
        if line ~= "" then parts[#parts + 1] = line end
    elseif row.demo and row.demoTally then
        local line = R.Tally and R.Tally.FormatLine(row.demoTally) or ""
        if line ~= "" then parts[#parts + 1] = line end
    end

    row.body:SetText(table.concat(parts, "   "))
end

--- Refresh every open row's tally. Called from LOOT_HISTORY_UPDATE_DROP.
--- @return nil
function R.RefreshAllTallies()
    if not framesCreated then return end
    for i = 1, R.POOL_SIZE do
        if pool[i].active then R.RefreshRowInfoLine(pool[i]) end
    end
end

--- Drive one row's countdown from the live roll timer.
--- @param row table
--- @return nil
function R.UpdateRowTimer(row)
    if row.demo then
        -- Demo rows have no server timer; run the bar off the local clock so
        -- the countdown looks exactly like a live one.
        local elapsed = (GetTime and GetTime() or 0) - (row.startedAt or 0)
        local left = math.max(0, row.rollTime - elapsed * 1000)
        row.timer:SetValue(left)
        if left <= 0 then R.ReleaseRoll(row.rollID) end
        return
    end

    -- Liveness. Removal is normally driven by CANCEL_LOOT_ROLL, but we have
    -- hidden Blizzard's frame for this roll — so a missed cancel would leave a
    -- dead row sitting over the screen with no way to dismiss it. Blizzard's own
    -- GroupLootFrame_OnShow treats "no item info" as "this roll is gone"; the
    -- same check here is the backstop.
    if GetLootRollItemInfo then
        local infoOk, name = pcall(function()
            return (select(2, GetLootRollItemInfo(row.rollID)))
        end)
        if not infoOk or name == nil then
            R.ReleaseRoll(row.rollID)
            if R.ForgetRoll then R.ForgetRoll(row.rollID) end
            return
        end
    end

    if not GetLootRollTimeLeft then return end
    local ok, left = pcall(GetLootRollTimeLeft, row.rollID)
    if not ok or type(left) ~= "number" then return end
    local minV, maxV = row.timer:GetMinMaxValues()
    if left < minV or left > maxV then left = minV end
    row.timer:SetValue(left)
end

--- Mark a row as rolled: the buttons collapse to the choice made, matching the
--- way Blizzard's frame stops offering alternatives once you have committed.
--- @param rollID number
--- @param rollType number
--- @return nil
function R.MarkRolled(rollID, rollType)
    local row = R.FindRow(rollID)
    if not row then return end
    row.rolledAs = rollType
    for _, t in ipairs(BUTTON_ORDER) do
        local b = row.buttons[t]
        if b:IsShown() and t ~= rollType then SetButtonEnabled(b, false, nil) end
    end
end

--- Release a roll's row and restack the rest.
--- @param rollID number
--- @return nil
function R.ReleaseRoll(rollID)
    local row = R.FindRow(rollID)
    if not row then return end
    row.active = false
    row.rollID = nil
    row.frame:Hide()
    -- Blizzard hides its own confirm popup when the roll frame goes away
    -- (GroupLootFrame_Remove). We suppress its frame, so that cleanup is ours.
    if StaticPopup_Hide then pcall(StaticPopup_Hide, "CONFIRM_LOOT_ROLL", rollID) end
    Restack()
    if R.HasActiveRows and not R.HasActiveRows() and not R.IsEditing() then
        Frame:Hide()
    end
end

--- @return boolean
function R.HasActiveRows()
    if not framesCreated then return false end   -- see R.FindRow
    for i = 1, R.POOL_SIZE do
        if pool[i].active then return true end
    end
    return false
end

--- Release every row.
--- @return nil
function R.ClearAllRolls()
    if not framesCreated then return end
    for i = 1, R.POOL_SIZE do
        local row = pool[i]
        if row.active then
            row.active = false
            row.rollID = nil
            row.frame:Hide()
        end
    end
    if not R.IsEditing() then Frame:Hide() end
end

-- ============================================================================
-- OPTION APPLICATION
-- ============================================================================

--- Re-apply scale, font and layout to every pooled row.
--- @return nil
function R.ApplyScale()
    if not framesCreated then return end
    UpdateFontObject()
    Frame:SetSize(S(R.GetWidth()), S(LineHeight()))
    for i = 1, R.POOL_SIZE do
        local row = pool[i]
        row.frame:SetSize(S(R.GetWidth()), S(RowHeight()))
        row.frame:SetAlpha(R.GetOpacity())
        if row.active then
            LayoutRow(row, row.quality)
            R.RefreshRowInfoLine(row)
        end
    end
    Restack()
end

function R.RestoreSavedPosition()
    if not framesCreated then return end
    R.ApplyStoredAnchor(Frame)
end
