--[[
    Horizon Suite - Flow - Layout

    Flow owns the quest window's layout outright: a wide horizontal panel in the
    centre of the screen, with the story, the objectives and the rewards as
    three columns under a title strip.

    This is a deliberate step past the original "host, do not reparent" design.
    Blizzard's QuestInfo only ever flows vertically in a single column, so a
    horizontal layout cannot be expressed through its template element system.
    What Blizzard keeps is everything that matters for correctness: the reward
    buttons and their click handlers, the accept, decline and complete handlers,
    and ownership of when the window shows. Flow never calls AcceptQuest or
    GetQuestReward, and never calls Show, Hide or SetParent on QuestFrame.

    QuestInfoFrame IS reparented, out of Blizzard's scroll frame and onto
    QuestFrame, so the columns are not clipped by a scroll area sized for a
    narrow vertical list. That is safe because QuestInfo_Display reassigns the
    parent on every single display, so the map's details pane and the quest log
    popup reclaim it automatically the moment either of them draws.

    Blizzard: QuestFrame, UIPanelWindows, QuestInfoFrame, QuestInfoRewardsFrame.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow
local L = addon.L

local FRAME_WIDTH   = 880
local HEADER_HEIGHT = 42
local FOOTER_HEIGHT = 46
local COL_PAD       = 18
local MIN_HEIGHT    = 190
local MAX_HEIGHT    = 460

-- Column weights: the story gets the most room because it is the only column
-- whose length Flow cannot predict.
local COL_WEIGHTS = { 1.5, 1.05, 1.05 }

local BUTTON_HEIGHT = 24
local BUTTON_WIDTH  = 108
local BUTTON_GAP    = 9

local ACTION_BUTTONS = {
    "QuestFrameAcceptButton",
    "QuestFrameDeclineButton",
    "QuestFrameCompleteButton",
    "QuestFrameCompleteQuestButton",
    "QuestFrameGoodbyeButton",
    "QuestFrameCancelButton",
    "QuestFrameGreetingGoodbyeButton",
}

local PRIMARY_BUTTONS = {
    QuestFrameAcceptButton        = true,
    QuestFrameCompleteButton      = true,
    QuestFrameCompleteQuestButton = true,
}

local PANEL_NAMES = {
    "QuestFrameDetailPanel",
    "QuestFrameProgressPanel",
    "QuestFrameRewardPanel",
    "QuestFrameGreetingPanel",
}

local BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local columns, dividers, footerHint
local styledButtons = {}
local savedPanelEntry, panelEntrySaved = nil, false

-- ---------------------------------------------------------------------------
-- Geometry
-- ---------------------------------------------------------------------------

--- Left edge and width of each column, in frame-local coordinates.
--- @return table cols Array of { x = number, w = number }
local function ColumnGeometry()
    local inner = FRAME_WIDTH
    local total = 0
    for i = 1, #COL_WEIGHTS do total = total + COL_WEIGHTS[i] end

    local cols, x = {}, 0
    for i = 1, #COL_WEIGHTS do
        local w = (inner * COL_WEIGHTS[i]) / total
        cols[i] = { x = x, w = w }
        x = x + w
    end
    return cols
end

--- Lazily build the column headers and the hairline dividers between columns.
--- @param frame Frame QuestFrame
--- @return nil
local function EnsureColumns(frame)
    if columns then return end

    columns, dividers = {}, {}
    local labels = { "FLOW_COL_STORY", "FLOW_COL_OBJECTIVES", "FLOW_COL_REWARDS" }

    for i = 1, 3 do
        local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetJustifyH("LEFT")
        header:SetText(L[labels[i]])
        columns[i] = { header = header }

        if i > 1 then
            local line = frame:CreateTexture(nil, "ARTWORK")
            line:SetWidth(1)
            dividers[i] = line
        end
    end

    footerHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footerHint:SetJustifyH("LEFT")
    footerHint:SetText(L["FLOW_ESCAPE_HINT"])
end

-- ---------------------------------------------------------------------------
-- Buttons
-- ---------------------------------------------------------------------------

local function StyleButton(button, primary)
    if not button or not button.CreateTexture then return end

    if not styledButtons[button] then
        for _, method in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture", "GetDisabledTexture" }) do
            if button[method] then
                local tex = button[method](button)
                if tex and tex.SetTexture then pcall(tex.SetTexture, tex, nil) end
            end
        end
        if button.GetRegions then
            local regions = { button:GetRegions() }
            for i = 1, #regions do
                local r = regions[i]
                if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Hide then
                    pcall(r.Hide, r)
                end
            end
        end

        local fill = CreateFrame("Frame", nil, button, "BackdropTemplate")
        fill:SetAllPoints(button)
        fill:SetFrameLevel(math.max(0, (button:GetFrameLevel() or 1) - 1))
        fill:SetBackdrop(BACKDROP)
        button._hsFlowFill = fill

        if button.GetPoint and button:GetNumPoints() > 0 then
            button._hsFlowPoint = { button:GetPoint(1) }
        end
        button._hsFlowSize = { button:GetWidth(), button:GetHeight() }
        styledButtons[button] = true
    end

    local ar, ag, ab = 0.20, 0.60, 1.00
    if F.GetAccentColor then ar, ag, ab = F.GetAccentColor() end

    local fill = button._hsFlowFill
    if fill then
        if primary then
            fill:SetBackdropColor(ar, ag, ab, 1)
            fill:SetBackdropBorderColor(ar, ag, ab, 1)
        else
            fill:SetBackdropColor(0.11, 0.11, 0.14, 1)
            fill:SetBackdropBorderColor(0.24, 0.24, 0.28, 1)
        end
        fill:Show()
    end

    local label = button.Text or (button.GetFontString and button:GetFontString())
    if label and label.SetTextColor then
        if primary then
            label:SetTextColor(0.04, 0.10, 0.17, 1)
        else
            label:SetTextColor(0.78, 0.78, 0.84, 1)
        end
        if F.GetFontPath then
            local path = F.GetFontPath()
            if path then pcall(label.SetFont, label, path, 12, "") end
        end
    end
end

local function RestoreButtons()
    for button in pairs(styledButtons) do
        if button._hsFlowFill then button._hsFlowFill:Hide() end
        if button.GetRegions then
            local regions = { button:GetRegions() }
            for i = 1, #regions do
                local r = regions[i]
                if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Show then
                    pcall(r.Show, r)
                end
            end
        end
        if button._hsFlowPoint then
            button:ClearAllPoints()
            pcall(button.SetPoint, button, unpack(button._hsFlowPoint))
        end
        if button._hsFlowSize then
            pcall(button.SetSize, button, button._hsFlowSize[1], button._hsFlowSize[2])
        end
    end
end

--- Action buttons, right-aligned in the footer with the affirmative one last.
--- @param frame Frame QuestFrame
--- @return nil
local function LayoutFooter(frame)
    local visible = {}
    for i = 1, #ACTION_BUTTONS do
        local button = _G[ACTION_BUTTONS[i]]
        if button and button.IsShown and button:IsShown() then
            visible[#visible + 1] = button
        end
    end
    if #visible == 0 then return end

    -- Affirmative action sits rightmost, where the eye finishes.
    table.sort(visible, function(a, b)
        local pa = PRIMARY_BUTTONS[a:GetName() or ""] and 1 or 0
        local pb = PRIMARY_BUTTONS[b:GetName() or ""] and 1 or 0
        return pa < pb
    end)

    local y = (FOOTER_HEIGHT - BUTTON_HEIGHT) / 2

    -- Anchored right to left, each button hanging off the one after it, so the
    -- footer needs no cumulative offset arithmetic.
    for i = #visible, 1, -1 do
        local button = visible[i]
        StyleButton(button, PRIMARY_BUTTONS[button:GetName() or ""] and true or false)
        button:ClearAllPoints()
        button:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT)
        if i == #visible then
            button:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -COL_PAD, y)
        else
            button:SetPoint("RIGHT", visible[i + 1], "LEFT", -BUTTON_GAP, 0)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Rewards
-- ---------------------------------------------------------------------------

--- Stack Blizzard's reward buttons vertically so they fit a narrow column.
--- Blizzard lays them out two per row at its own width, which overflows a third
--- of an 880 frame. Only position and size are touched; the icons, names,
--- tooltips and click handlers stay Blizzard's.
--- @param rewards Frame QuestInfoRewardsFrame
--- @param width number Column width
--- @return number height Space the stack occupies
local function StackRewardButtons(rewards, width)
    local buttons = rewards.RewardButtons
    if type(buttons) ~= "table" then return rewards:GetHeight() or 0 end

    local y, count = 0, 0
    for i = 1, #buttons do
        local b = buttons[i]
        if b and b.IsShown and b:IsShown() then
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", rewards, "TOPLEFT", 0, -y)
            if b.SetWidth then pcall(b.SetWidth, b, width) end
            y = y + (b:GetHeight() or 32) + 4
            count = count + 1
        end
    end
    if count == 0 then return rewards:GetHeight() or 0 end
    return y
end

-- ---------------------------------------------------------------------------
-- Centring
-- ---------------------------------------------------------------------------

--- Ask the UIPanel system to centre the window instead of parking it on the
--- left. Going through UIPanelWindows rather than fighting it with SetPoint
--- keeps ESC handling and the panel system's show and hide intact.
--- @return nil
local function ApplyCentring()
    local windows = _G.UIPanelWindows
    if type(windows) ~= "table" then return end

    if not panelEntrySaved then
        savedPanelEntry = windows["QuestFrame"]
        panelEntrySaved = true
    end

    windows["QuestFrame"] = { area = "center", pushable = 0, whileDead = 1 }

    local frame = _G.QuestFrame
    if frame and frame.IsShown and frame:IsShown() then
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 60)
    end
end

local function RestoreCentring()
    if not panelEntrySaved then return end
    local windows = _G.UIPanelWindows
    if type(windows) == "table" then
        windows["QuestFrame"] = savedPanelEntry
    end
    panelEntrySaved = false
    savedPanelEntry = nil
end

-- ---------------------------------------------------------------------------
-- The layout pass
-- ---------------------------------------------------------------------------

--- Lay the quest window out as three columns in a wide centred panel.
--- @return nil
function F.ApplyShape()
    local frame = _G.QuestFrame
    if not frame or not frame.SetSize then return end
    if not (addon.GetDB and addon.GetDB("flowAutoSize", true)) then return end

    local info = _G.QuestInfoFrame
    if not info then return end

    EnsureColumns(frame)
    ApplyCentring()

    pcall(frame.SetWidth, frame, FRAME_WIDTH)

    -- Panels fill the frame; their scroll frames are taken out of the picture
    -- entirely, since Flow positions the content itself.
    for i = 1, #PANEL_NAMES do
        local panel = _G[PANEL_NAMES[i]]
        if panel and panel.IsShown and panel:IsShown() then
            pcall(panel.SetWidth, panel, FRAME_WIDTH)
            if panel.GetChildren then
                local children = { panel:GetChildren() }
                for j = 1, #children do
                    local child = children[j]
                    if child and child.GetObjectType and child:GetObjectType() == "ScrollFrame" then
                        pcall(child.SetWidth, child, FRAME_WIDTH)
                    end
                end
            end
        end
    end

    -- Out of the scroll frame so nothing clips the columns. QuestInfo_Display
    -- reassigns this on every display, so the map pane reclaims it by itself.
    pcall(info.SetParent, info, frame)
    info:ClearAllPoints()
    info:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -HEADER_HEIGHT)
    info:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, FOOTER_HEIGHT)

    local cols = ColumnGeometry()
    local top  = -(HEADER_HEIGHT + 14)
    local heights = { 0, 0, 0 }

    for i = 1, 3 do
        local header = columns[i].header
        header:ClearAllPoints()
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", cols[i].x + COL_PAD, top)
        header:SetTextColor(0.43, 0.43, 0.48, 1)
        if F.GetFontPath then
            local path = F.GetFontPath()
            if path then pcall(header.SetFont, header, path, 10, "") end
        end
        header:Show()
    end

    local bodyTop = top - 18

    -- Column 1: the story.
    local desc = _G.QuestInfoDescriptionText
    if desc and desc.IsShown and desc:IsShown() then
        local w = cols[1].w - (COL_PAD * 2)
        desc:ClearAllPoints()
        desc:SetWidth(w)
        desc:SetPoint("TOPLEFT", frame, "TOPLEFT", cols[1].x + COL_PAD, bodyTop)
        heights[1] = desc:GetStringHeight() or 0
    end

    -- Column 2: the objectives band.
    local drawn = F.GetDrawnFrames and F.GetDrawnFrames() or {}
    local band = drawn[1]
    if band and band.IsShown and band:IsShown() then
        local w = cols[2].w - (COL_PAD * 2)
        band:ClearAllPoints()
        band:SetWidth(w)
        band:SetPoint("TOPLEFT", frame, "TOPLEFT", cols[2].x + COL_PAD, bodyTop)
        heights[2] = band:GetHeight() or 0
    end

    -- Column 3: Blizzard's reward block, stacked to fit.
    local rewards = _G.QuestInfoRewardsFrame
    if rewards and rewards.IsShown and rewards:IsShown() then
        local w = cols[3].w - (COL_PAD * 2)
        rewards:ClearAllPoints()
        rewards:SetWidth(w)
        rewards:SetPoint("TOPLEFT", frame, "TOPLEFT", cols[3].x + COL_PAD, bodyTop)
        heights[3] = StackRewardButtons(rewards, w)
    end

    local tallest = math.max(heights[1], heights[2], heights[3])
    local height = HEADER_HEIGHT + 32 + tallest + 16 + FOOTER_HEIGHT
    height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, height))
    pcall(frame.SetHeight, frame, height)

    for i = 2, 3 do
        local line = dividers[i]
        if line then
            line:ClearAllPoints()
            line:SetPoint("TOP", frame, "TOPLEFT", cols[i].x, -HEADER_HEIGHT)
            line:SetHeight(height - HEADER_HEIGHT - FOOTER_HEIGHT)
            line:SetColorTexture(0.14, 0.14, 0.17, 1)
            line:Show()
        end
    end

    footerHint:ClearAllPoints()
    footerHint:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", COL_PAD, (FOOTER_HEIGHT - 12) / 2)
    footerHint:SetTextColor(0.33, 0.33, 0.37, 1)
    footerHint:Show()

    LayoutFooter(frame)
end

--- Re-run the layout on the next frame. Blizzard sizes the reward block lazily,
--- so a measurement taken inside the display hook can be one frame stale.
--- @return nil
function F.ApplyShapeDeferred()
    if not C_Timer or not C_Timer.After then return end
    C_Timer.After(0, function()
        local frame = _G.QuestFrame
        if frame and frame.IsShown and frame:IsShown() then
            pcall(F.ApplyShape)
        end
    end)
end

--- Hide Blizzard's corner close button. ESC still closes the window, and the
--- footer carries Decline, Cancel or Goodbye on every panel that has one.
--- @return nil
function F.ApplyCloseButton()
    local close = _G.QuestFrameCloseButton
    if not close then return end
    if addon.GetDB and addon.GetDB("flowHideCloseButton", true) then
        pcall(close.Hide, close)
    else
        pcall(close.Show, close)
    end
end

--- Undo everything in this file, as far as is reachable. A reload is still the
--- exact restore; this is the mid-session escape hatch behind /h flow restore.
--- @return nil
function F.ResetShape()
    if columns then
        for i = 1, #columns do
            if columns[i].header then columns[i].header:Hide() end
        end
    end
    if dividers then
        for _, line in pairs(dividers) do if line then line:Hide() end end
    end
    if footerHint then footerHint:Hide() end
    RestoreButtons()
    RestoreCentring()
    local close = _G.QuestFrameCloseButton
    if close then pcall(close.Show, close) end
end
