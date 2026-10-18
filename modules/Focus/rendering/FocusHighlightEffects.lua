--[[
    Horizon Suite - Focus - Highlight Effects
    Effects built into the focused quest highlight styles: the bars get a progress fill (unless
    Show progress is off) and grow in when focus changes; the gradient slides in when focus
    changes and carries a sheen sweep; the pointer is an arrow left of the entry that nudges
    toward it. The animated parts follow the global Animations option.
]]

local addon = _G.HorizonSuite

-- Which effects each highlight style carries.
local STYLE_FX = {
    ["bar-gutter"] = { progress = true, enter = true },
    ["bar-right"]  = { progress = true, enter = true },
    ["gradient"]   = { enter = true, sheen = true },
    ["pointer"]    = { pointer = true },
}

local TRACK_ALPHA = 0.25  -- bar alpha behind the progress fill
local BAR_ALPHA = 0.70
local SHEEN_W = 18        -- width of each half of the sheen band, px
local SHEEN_ALPHA = 0.30
local SHEEN_DURATION = 1.1
local SHEEN_DELAY = 5
local ENTER_DURATION = 0.3
local SLIDE_OFFSET = 24   -- how far the gradient slides in from, px
local POINTER_TEXTURE = "Interface\\AddOns\\HorizonSuite\\media\\pointer"
local POINTER_SIZE = 10   -- px
local POINTER_GAP = 3     -- gap between the arrow tip and the entry, px
local POINTER_NUDGE = 3   -- how far the arrow nudges toward the entry, px
local POINTER_NUDGE_DURATION = 0.8

-- Key of the quest that last played the focus-change animation, so it plays once per change.
local lastFocusKey

local function S(v)
    return addon.Scaled and addon.Scaled(v) or v
end

local function AnimationsOn()
    return addon.GetDB("animations", true)
end

local function SheenTint(hc)
    -- Tint toward white so the band reads as light, not as more highlight colour.
    return { (hc[1] + 1) / 2, (hc[2] + 1) / 2, (hc[3] + 1) / 2 }
end

-- Lazily create the extra textures and their animation groups on an entry.
local function Ensure(entry)
    local fx = entry._highlightFx
    if fx then return fx end
    fx = {}

    fx.fill = entry:CreateTexture(nil, "OVERLAY", nil, 1)
    fx.fill:Hide()

    fx.sheenL = entry:CreateTexture(nil, "ARTWORK")
    fx.sheenR = entry:CreateTexture(nil, "ARTWORK")
    fx.sheenAnims = {}
    for i, tex in ipairs({ fx.sheenL, fx.sheenR }) do
        tex:SetBlendMode("ADD")
        tex:Hide()
        local ag = tex:CreateAnimationGroup()
        ag:SetLooping("REPEAT")
        local move = ag:CreateAnimation("Translation")
        move:SetDuration(SHEEN_DURATION)
        move:SetStartDelay(SHEEN_DELAY)
        move:SetSmoothing("IN_OUT")
        ag.move = move
        fx.sheenAnims[i] = ag
    end

    -- One focus-change group per highlight texture: bars grow out from their middle,
    -- the gradient slides in from the left; both fade in.
    fx.enter = {}
    local function addEnter(tex, vertical)
        local ag = tex:CreateAnimationGroup()
        local hideA = ag:CreateAnimation("Alpha")
        hideA:SetFromAlpha(0); hideA:SetToAlpha(0); hideA:SetDuration(0); hideA:SetOrder(1)
        local showA = ag:CreateAnimation("Alpha")
        showA:SetFromAlpha(0); showA:SetToAlpha(1); showA:SetDuration(ENTER_DURATION); showA:SetOrder(2)
        if vertical then
            local squash = ag:CreateAnimation("Scale")
            squash:SetScale(1, 0.05); squash:SetDuration(0); squash:SetOrder(1)
            local grow = ag:CreateAnimation("Scale")
            grow:SetScale(1, 20); grow:SetDuration(ENTER_DURATION); grow:SetSmoothing("OUT"); grow:SetOrder(2)
        else
            local back = ag:CreateAnimation("Translation")
            back:SetOffset(-S(SLIDE_OFFSET), 0); back:SetDuration(0); back:SetOrder(1)
            local forward = ag:CreateAnimation("Translation")
            forward:SetOffset(S(SLIDE_OFFSET), 0); forward:SetDuration(ENTER_DURATION); forward:SetSmoothing("OUT"); forward:SetOrder(2)
        end
        fx.enter[tex] = ag
    end
    for _, tex in ipairs({ entry.trackBar, fx.fill }) do
        addEnter(tex, true)
    end
    addEnter(entry.highlightGradient, false)

    entry._highlightFx = fx
    return fx
end

local function StopGroups(groups)
    for _, ag in pairs(groups) do
        if ag:IsPlaying() then ag:Stop() end
    end
end

local function HideSheen(fx)
    fx.sheenL:Hide(); fx.sheenR:Hide()
    StopGroups(fx.sheenAnims)
end

-- The pointer sits in the tracker's left padding, outside the entry, so it is parented to the
-- entry's parent (the entry clips its children) and follows the entry's visibility by hooks.
local function EnsurePointer(entry, fx)
    if fx.pointer then return fx.pointer end
    local p = CreateFrame("Frame", nil, entry:GetParent())
    p:SetFrameLevel(entry:GetFrameLevel() + 2)
    p:Hide()
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints(p)
    p.tex:SetTexture(POINTER_TEXTURE)

    -- Out and back as two eased moves in one repeating group: the loop ends exactly where it
    -- starts, so it runs seamlessly (BOUNCE hitches at each turn).
    p.nudge = p:CreateAnimationGroup()
    p.nudge:SetLooping("REPEAT")
    p.nudge.out = p.nudge:CreateAnimation("Translation")
    p.nudge.out:SetDuration(POINTER_NUDGE_DURATION)
    p.nudge.out:SetSmoothing("IN_OUT")
    p.nudge.out:SetOrder(1)
    p.nudge.back = p.nudge:CreateAnimation("Translation")
    p.nudge.back:SetDuration(POINTER_NUDGE_DURATION)
    p.nudge.back:SetSmoothing("IN_OUT")
    p.nudge.back:SetOrder(2)

    -- Focus change: fade in while sliding toward the entry.
    p.enter = p.tex:CreateAnimationGroup()
    local hideA = p.enter:CreateAnimation("Alpha")
    hideA:SetFromAlpha(0); hideA:SetToAlpha(0); hideA:SetDuration(0); hideA:SetOrder(1)
    local back = p.enter:CreateAnimation("Translation")
    back:SetOffset(-S(8), 0); back:SetDuration(0); back:SetOrder(1)
    local showA = p.enter:CreateAnimation("Alpha")
    showA:SetFromAlpha(0); showA:SetToAlpha(1); showA:SetDuration(ENTER_DURATION); showA:SetOrder(2)
    local forward = p.enter:CreateAnimation("Translation")
    forward:SetOffset(S(8), 0); forward:SetDuration(ENTER_DURATION); forward:SetSmoothing("OUT"); forward:SetOrder(2)

    entry:HookScript("OnHide", function() p:Hide() end)
    entry:HookScript("OnShow", function() if fx.pointerOn then p:Show() end end)
    fx.pointer = p
    return p
end

local function HidePointer(fx)
    fx.pointerOn = false
    local p = fx.pointer
    if not p then return end
    p:Hide()
    if p.nudge:IsPlaying() then p.nudge:Stop() end
    if p.enter:IsPlaying() then p.enter:Stop() end
end

-- Arrow just left of the entry, level with the middle of the title's first line.
local function ApplyPointer(entry, fx, hc)
    local p = EnsurePointer(entry, fx)
    local size = S(POINTER_SIZE)
    local _, fontSize = entry.titleText:GetFont()
    local _, _, _, _, titleY = entry.titleText:GetPoint(1)
    local midY = (type(titleY) == "number" and titleY or 0) - (tonumber(fontSize) or size) / 2
    local x = -S(POINTER_GAP) - S(POINTER_NUDGE)
    -- Re-anchor only when the spot moves, so tracker updates do not disturb the nudge.
    if p._size ~= size or p._x ~= x or p._y ~= midY then
        p:SetSize(size, size)
        p:ClearAllPoints()
        p:SetPoint("RIGHT", entry, "TOPLEFT", x, midY)
        p._size, p._x, p._y = size, x, midY
    end
    p.tex:SetVertexColor(hc[1], hc[2], hc[3], 1)
    fx.pointerOn = true
    if entry:IsShown() then p:Show() end
    if AnimationsOn() then
        local nudge = S(POINTER_NUDGE)
        if p.nudge._offset ~= nudge then
            p.nudge.out:SetOffset(nudge, 0)
            p.nudge.back:SetOffset(-nudge, 0)
            p.nudge._offset = nudge
        end
        -- Leave a running nudge alone so re-renders do not restart it.
        if not p.nudge:IsPlaying() then p.nudge:Play() end
    elseif p.nudge:IsPlaying() then
        p.nudge:Stop()
    end
end

--- Hide every effect and stop its animations (entry no longer focused, or released to the pool).
-- @param entry Frame Focus entry
function addon.FocusHighlight_Clear(entry)
    local fx = entry and entry._highlightFx
    if not fx then return end
    fx.fill:Hide()
    HideSheen(fx)
    HidePointer(fx)
    StopGroups(fx.enter)
end

-- Bar becomes a faint track; the fill grows from the bottom with quest progress.
-- Quests with no objectives to measure keep the plain bar.
local function ApplyProgress(fx, entry, questData, hc, entryH)
    local progress = addon.GetFocusQuestProgress(questData)
    if not progress then return end
    entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], TRACK_ALPHA)
    fx.fill:SetColorTexture(hc[1], hc[2], hc[3], BAR_ALPHA)
    fx.fill:ClearAllPoints()
    fx.fill:SetPoint("BOTTOMLEFT", entry.trackBar, "BOTTOMLEFT", 0, 0)
    fx.fill:SetPoint("BOTTOMRIGHT", entry.trackBar, "BOTTOMRIGHT", 0, 0)
    if progress > 0 then
        fx.fill:SetHeight(math.max(1, entryH * progress))
        fx.fill:Show()
    end
end

local function ApplySheen(fx, entry, hc, entryW)
    local tint = SheenTint(hc)
    local w = S(SHEEN_W)
    fx.sheenL:ClearAllPoints()
    fx.sheenL:SetPoint("TOPRIGHT", entry, "TOPLEFT", -w, 0)
    fx.sheenL:SetPoint("BOTTOMRIGHT", entry, "BOTTOMLEFT", -w, 0)
    fx.sheenL:SetWidth(w)
    addon.SetTextureFade(fx.sheenL, tint, 0, SHEEN_ALPHA)
    fx.sheenR:ClearAllPoints()
    fx.sheenR:SetPoint("TOPLEFT", fx.sheenL, "TOPRIGHT", 0, 0)
    fx.sheenR:SetPoint("BOTTOMLEFT", fx.sheenL, "BOTTOMRIGHT", 0, 0)
    fx.sheenR:SetWidth(w)
    addon.SetTextureFade(fx.sheenR, tint, SHEEN_ALPHA, 0)
    local travel = entryW + w * 2
    for _, ag in ipairs(fx.sheenAnims) do
        if ag._travel ~= travel then
            ag.move:SetOffset(travel, 0)
            ag._travel = travel
        end
    end
    fx.sheenL:Show(); fx.sheenR:Show()
    -- Leave a running sweep alone so re-renders do not restart it.
    for _, ag in ipairs(fx.sheenAnims) do
        if not ag:IsPlaying() then ag:Play() end
    end
end

--- Apply the style's effects after the entry has its final size and the track bar is placed.
-- @param entry Frame Focus entry
-- @param questData table
-- @param highlightStyle string normalised style
function addon.FocusHighlight_Apply(entry, questData, highlightStyle)
    local styleFx = STYLE_FX[highlightStyle]
    if not questData.isSuperTracked or not styleFx then
        addon.FocusHighlight_Clear(entry)
        return
    end
    local fx = Ensure(entry)
    fx.fill:Hide()

    local hc = addon.GetFocusHighlightColor(questData)
    local entryW, entryH = entry:GetWidth() or 0, entry:GetHeight() or 0
    local shown = {}  -- highlight textures drawn this pass, for the focus-change animation

    if entry.trackBar:IsShown() then
        shown[#shown + 1] = entry.trackBar
        if styleFx.progress and addon.GetDB("focusHighlightProgress", true) then
            ApplyProgress(fx, entry, questData, hc, entryH)
            if fx.fill:IsShown() then shown[#shown + 1] = fx.fill end
        end
    elseif entry.highlightGradient:IsShown() then
        shown[#shown + 1] = entry.highlightGradient
    end

    if styleFx.pointer then
        ApplyPointer(entry, fx, hc)
    else
        HidePointer(fx)
    end

    if styleFx.sheen and AnimationsOn() and entryW > 0 then
        ApplySheen(fx, entry, hc, entryW)
    else
        HideSheen(fx)
    end

    local key = questData.questID or questData.title
    if key ~= nil and key ~= lastFocusKey then
        lastFocusKey = key
        if styleFx.enter and AnimationsOn() then
            for _, tex in ipairs(shown) do fx.enter[tex]:Play() end
        end
        if styleFx.pointer and AnimationsOn() then
            fx.pointer.enter:Play()
        end
    end
end

--- Recolour the effects live (colour picker drag, class colour toggle) without a full layout.
-- @param entry Frame Focus entry
-- @param hc table {r, g, b}
function addon.FocusHighlight_Recolour(entry, hc)
    local fx = entry and entry._highlightFx
    if not fx then return end
    if fx.fill:IsShown() then
        fx.fill:SetColorTexture(hc[1], hc[2], hc[3], BAR_ALPHA)
    end
    if fx.pointer and fx.pointerOn then
        fx.pointer.tex:SetVertexColor(hc[1], hc[2], hc[3], 1)
    end
    if fx.sheenL:IsShown() then
        local tint = SheenTint(hc)
        addon.SetTextureFade(fx.sheenL, tint, 0, SHEEN_ALPHA)
        addon.SetTextureFade(fx.sheenR, tint, SHEEN_ALPHA, 0)
    end
end
