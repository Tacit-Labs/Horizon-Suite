--[[
    Horizon Suite - Flow - Layout

    Everything that changes the SHAPE of the quest window rather than its
    colours: squaring the frame up, hugging the content instead of keeping
    Blizzard's fixed 384x512, carding the reward block, and pulling the panel
    buttons into a real footer.

    None of this touches a protected path. QuestFrame is resized and its own
    buttons are re-anchored, but Show, Hide and SetParent are never called on
    it, so the UIPanel system keeps ownership of when the window appears.

    Blizzard: QuestFrame, its four panels, QuestInfoRewardsFrame and the panel
    action buttons.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow

local FOOTER_HEIGHT = 46
local FOOTER_PAD    = 20
local FOOTER_GAP    = 10
local BUTTON_HEIGHT = 24
local CONTENT_TOP   = 18
local MIN_HEIGHT    = 200
local MAX_HEIGHT    = 620

-- Buttons Blizzard shows on each panel. Flow lays out whichever are visible
-- rather than assuming which panel is up, so an unexpected combination still
-- produces a sane footer instead of an empty one.
local ACTION_BUTTONS = {
    "QuestFrameAcceptButton",
    "QuestFrameDeclineButton",
    "QuestFrameCompleteButton",
    "QuestFrameCompleteQuestButton",
    "QuestFrameGoodbyeButton",
    "QuestFrameCancelButton",
    "QuestFrameGreetingGoodbyeButton",
}

-- Buttons that read as the affirmative action and get the accent fill.
local PRIMARY_BUTTONS = {
    QuestFrameAcceptButton        = true,
    QuestFrameCompleteButton      = true,
    QuestFrameCompleteQuestButton = true,
}

local rewardCard, footer
local styledButtons = {}

-- ---------------------------------------------------------------------------
-- Buttons
-- ---------------------------------------------------------------------------

--- Strip a Blizzard button's art and give it a flat Horizon fill.
--- Idempotent: the texture strip only runs the first time a button is seen.
--- @param button Button
--- @param primary boolean Accent fill rather than outline
--- @return nil
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
        fill:SetBackdrop({
            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        button._hsFlowFill = fill

        -- Remembered so Disable can put the button back where Blizzard had it,
        -- rather than leaving it in Flow's footer until the next reload.
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
            fill:SetBackdropColor(0.13, 0.13, 0.16, 1)
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
            local size = tonumber(addon.GetDB and addon.GetDB("flowFontSize", 13)) or 13
            if path then pcall(label.SetFont, label, path, size, "") end
        end
    end
end

--- Restore a button's Blizzard look as far as we can. hooksecurefunc-free, so
--- this is a best-effort re-show of the textures the strip hid.
--- @return nil
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

-- ---------------------------------------------------------------------------
-- Footer
-- ---------------------------------------------------------------------------

--- Re-anchor whichever panel buttons are visible into an evenly split footer
--- along the bottom of the window.
--- @param width number Frame width
--- @return nil
local function LayoutFooter(width)
    local frame = _G.QuestFrame
    if not frame then return end

    if not footer then
        footer = CreateFrame("Frame", "HorizonFlowFooter", frame)
        footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        footer:SetHeight(FOOTER_HEIGHT)
    end
    footer:SetFrameLevel(math.max(1, (frame:GetFrameLevel() or 1) + 1))
    footer:Show()

    local visible = {}
    for i = 1, #ACTION_BUTTONS do
        local button = _G[ACTION_BUTTONS[i]]
        if button and button.IsShown and button:IsShown() then
            visible[#visible + 1] = button
        end
    end
    if #visible == 0 then return end

    local usable = width - (FOOTER_PAD * 2) - (FOOTER_GAP * (#visible - 1))
    local each   = math.max(60, usable / #visible)

    for i = 1, #visible do
        local button = visible[i]
        StyleButton(button, PRIMARY_BUTTONS[button:GetName() or ""] and true or false)
        button:ClearAllPoints()
        button:SetSize(each, BUTTON_HEIGHT)
        button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT",
            FOOTER_PAD + ((each + FOOTER_GAP) * (i - 1)),
            (FOOTER_HEIGHT - BUTTON_HEIGHT) / 2)
    end
end

-- ---------------------------------------------------------------------------
-- Reward card
-- ---------------------------------------------------------------------------

--- Draw the shared card surface behind Blizzard's reward block.
--- The card is anchored to the rewards frame with padding, so it tracks
--- whatever size Blizzard gave it without Flow having to measure the contents.
--- @return nil
local function LayoutRewardCard()
    local rewards = _G.QuestInfoRewardsFrame
    local parent  = _G.QuestInfoFrame
    if not rewards or not parent then
        if rewardCard then rewardCard:Hide() end
        return
    end

    if not rewards.IsShown or not rewards:IsShown() then
        if rewardCard then rewardCard:Hide() end
        return
    end

    if not rewardCard then
        rewardCard = CreateFrame("Frame", "HorizonFlowRewardCard", parent, "BackdropTemplate")
    end

    rewardCard:SetParent(rewards:GetParent() or parent)
    rewardCard:SetFrameLevel(math.max(0, (rewards:GetFrameLevel() or 1) - 1))
    rewardCard:ClearAllPoints()
    rewardCard:SetPoint("TOPLEFT", rewards, "TOPLEFT", -12, 10)
    rewardCard:SetPoint("BOTTOMRIGHT", rewards, "BOTTOMRIGHT", 12, -10)
    if F.StyleCard then F.StyleCard(rewardCard) end
    rewardCard:Show()
end

-- ---------------------------------------------------------------------------
-- Frame sizing
-- ---------------------------------------------------------------------------

--- Lowest point reached by anything Flow knows is on screen, in the frame's own
--- coordinate space.
---
--- Measured from GetBottom rather than from QuestInfoFrame's height, because
--- the latter depends on Blizzard internals this code has never seen. Screen
--- coordinates are scale-relative, so both ends of the subtraction are taken
--- from frames in the same scale chain.
--- @param frame Frame QuestFrame
--- @return number|nil contentHeight
local function MeasureContent(frame)
    local top = frame:GetTop()
    if not top then return nil end

    local lowest
    local candidates = {}

    if F.GetDrawnFrames then
        local drawn = F.GetDrawnFrames()
        for i = 1, #drawn do candidates[#candidates + 1] = drawn[i] end
    end
    candidates[#candidates + 1] = _G.QuestInfoRewardsFrame
    candidates[#candidates + 1] = _G.QuestInfoDescriptionText
    candidates[#candidates + 1] = _G.QuestInfoTitleHeader

    for i = 1, #candidates do
        local c = candidates[i]
        if c and c.IsShown and c:IsShown() and c.GetBottom then
            local b = c:GetBottom()
            if b and (not lowest or b < lowest) then lowest = b end
        end
    end

    if not lowest then return nil end
    return top - lowest
end

local PANEL_NAMES = {
    "QuestFrameDetailPanel",
    "QuestFrameProgressPanel",
    "QuestFrameRewardPanel",
    "QuestFrameGreetingPanel",
}

--- Widening QuestFrame alone changes nothing a player can see: the panels and
--- their scroll frames carry their own sizes, so the content stays in a narrow
--- column on the left. Push the new width down through both.
--- @param frame Frame QuestFrame
--- @param width number
--- @return nil
local function ResizePanels(frame, width)
    for i = 1, #PANEL_NAMES do
        local panel = _G[PANEL_NAMES[i]]
        if panel and panel.IsShown and panel:IsShown() then
            pcall(panel.SetWidth, panel, width)

            if panel.GetChildren then
                local children = { panel:GetChildren() }
                for j = 1, #children do
                    local child = children[j]
                    if child and child.GetObjectType and child:GetObjectType() == "ScrollFrame" then
                        pcall(child.SetWidth, child, width - (FOOTER_PAD * 2))
                        local scrollChild = child.GetScrollChild and child:GetScrollChild()
                        if scrollChild and scrollChild.SetWidth then
                            pcall(scrollChild.SetWidth, scrollChild, width - (FOOTER_PAD * 2))
                        end
                    end
                end
            end
        end
    end
end

--- Square the window up: fixed content width, height hugging the content.
--- @return nil
function F.ApplyShape()
    local frame = _G.QuestFrame
    if not frame or not frame.SetSize then return end
    if not (addon.GetDB and addon.GetDB("flowAutoSize", true)) then return end

    local width = (F.FRAME_WIDTH or 420)

    pcall(frame.SetWidth, frame, width)
    ResizePanels(frame, width)

    -- Measured after the width change, because a narrower column wraps text
    -- differently and would give a height for a layout that no longer exists.
    local content = MeasureContent(frame)
    if content then
        local height = content + CONTENT_TOP + FOOTER_HEIGHT + 10
        height = math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, height))
        pcall(frame.SetHeight, frame, height)
    end

    LayoutRewardCard()
    LayoutFooter(width)
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

--- Undo everything in this file, as far as is reachable.
--- @return nil
function F.ResetShape()
    if footer then footer:Hide() end
    if rewardCard then rewardCard:Hide() end
    RestoreButtons()
    local close = _G.QuestFrameCloseButton
    if close then pcall(close.Show, close) end
end
