--[[
    Horizon Suite - Focus - Highlight Effects
    Effects built into the focused quest highlight styles: the bars show progress in quarter steps (unless
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

local TRACK_ALPHA = 0.25  -- alpha of a progress step not yet reached
local BAR_ALPHA = 0.70
local PROGRESS_STEPS = 4  -- the bar lights a step at each 25% of progress
local STEP_GAP = 2        -- gap between steps, px
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

    fx.steps = {}
    for i = 1, PROGRESS_STEPS do
        fx.steps[i] = entry:CreateTexture(nil, "OVERLAY", nil, 1)
        fx.steps[i]:Hide()
    end

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
    addEnter(entry.trackBar, true)
    for _, tex in ipairs(fx.steps) do
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

local function HideSteps(fx)
    for _, tex in ipairs(fx.steps) do tex:Hide() end
end

local function HideSheen(fx)
    fx.sheenL:Hide(); fx.sheenR:Hide()
    StopGroups(fx.sheenAnims)
end

-- The pointer sits in the tracker's left padding, outside the entry, so it is parented to the
-- entry's parent (the entry clips its children) and follows the entry's visibility by hooks.
--
-- Its motion is worked out each frame from its anchor (base spot + nudge + focus-change slide)
-- rather than with Translation animations. A looping Translation on a frame that is re-anchored
-- while it plays can keep its offset and drift, which walked the arrow across the quest title.
-- This way the arrow can never be more than the nudge away from its spot.
local POINTER_ENTER_SLIDE = 8  -- how far the arrow slides in from on a focus change, px

local function PlacePointer(p)
    local x = p._x or 0
    if p._nudgeOn then
        -- Smooth out and back: 0 -> nudge -> 0 over two nudge durations.
        local phase = (p._nudgeT or 0) / POINTER_NUDGE_DURATION * math.pi
        x = x + (p._nudge or 0) * (1 - math.cos(phase)) / 2
    end
    if p._enterT then
        local t = math.min(1, p._enterT / ENTER_DURATION)
        local remain = 1 - t
        x = x - S(POINTER_ENTER_SLIDE) * remain * remain  -- eased out
    end
    p:ClearAllPoints()
    p:SetPoint("RIGHT", p._entry, "TOPLEFT", x, p._y or 0)
end

local function PointerOnUpdate(p, elapsed)
    if p._nudgeOn then
        p._nudgeT = ((p._nudgeT or 0) + elapsed) % (POINTER_NUDGE_DURATION * 2)
    end
    if p._enterT then
        p._enterT = p._enterT + elapsed
        if p._enterT >= ENTER_DURATION then
            p._enterT = nil
            p.tex:SetAlpha(1)
        else
            p.tex:SetAlpha(p._enterT / ENTER_DURATION)
        end
    end
    PlacePointer(p)
    if not p._nudgeOn and not p._enterT then p:SetScript("OnUpdate", nil) end
end

local function RunPointer(p)
    if p._nudgeOn or p._enterT then
        p:SetScript("OnUpdate", PointerOnUpdate)
    else
        p:SetScript("OnUpdate", nil)
    end
    PlacePointer(p)
end

local function EnsurePointer(entry, fx)
    if fx.pointer then return fx.pointer end
    local p = CreateFrame("Frame", nil, entry:GetParent())
    p:SetFrameLevel(entry:GetFrameLevel() + 2)
    p:Hide()
    p._entry = entry
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints(p)
    p.tex:SetTexture(POINTER_TEXTURE)

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
    p:SetScript("OnUpdate", nil)
    p._nudgeOn, p._nudgeT, p._enterT = false, 0, nil
    p.tex:SetAlpha(1)
end

-- Focus change: fade in while sliding toward the entry.
local function PlayPointerEnter(p)
    p._enterT = 0
    p.tex:SetAlpha(0)
    RunPointer(p)
end

-- Arrow just left of the entry, level with the middle of the title's first line.
local function ApplyPointer(entry, fx, hc)
    local p = EnsurePointer(entry, fx)
    local size = S(POINTER_SIZE)
    local _, fontSize = entry.titleText:GetFont()
    local _, _, _, _, titleY = entry.titleText:GetPoint(1)
    local midY = (type(titleY) == "number" and titleY or 0) - (tonumber(fontSize) or size) / 2
    p:SetSize(size, size)
    p._x = -S(POINTER_GAP) - S(POINTER_NUDGE)
    p._y = midY
    p._nudge = S(POINTER_NUDGE)
    p.tex:SetVertexColor(hc[1], hc[2], hc[3], 1)
    fx.pointerOn = true
    if entry:IsShown() then p:Show() end
    -- Keep the nudge's phase across re-renders so tracker updates do not restart it.
    p._nudgeOn = AnimationsOn()
    if not p._nudgeOn then
        p._nudgeT, p._enterT = 0, nil
        p.tex:SetAlpha(1)
    end
    RunPointer(p)
end

--- Hide every effect and stop its animations (entry no longer focused, or released to the pool).
-- @param entry Frame Focus entry
function addon.FocusHighlight_Clear(entry)
    local fx = entry and entry._highlightFx
    if not fx then return end
    HideSteps(fx)
    HideSheen(fx)
    HidePointer(fx)
    StopGroups(fx.enter)
end

-- The bar splits into steps stacked from the bottom; each lights at the next 25% of progress,
-- and the rest show as a faint track. The bar itself stays as an invisible anchor.
-- Quests with no objectives to measure keep the plain bar.
-- @return boolean true when the steps are drawn
local function ApplyProgress(fx, entry, questData, hc, entryH)
    local progress = addon.GetFocusQuestProgress(questData)
    if not progress then return false end
    entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], 0)
    local lit = math.floor(progress * PROGRESS_STEPS + 1e-6)
    local gap = S(STEP_GAP)
    local stepH = math.max(1, (entryH - gap * (PROGRESS_STEPS - 1)) / PROGRESS_STEPS)
    for i, tex in ipairs(fx.steps) do
        local bottom = (i - 1) * (stepH + gap)
        tex:ClearAllPoints()
        tex:SetPoint("BOTTOMLEFT", entry.trackBar, "BOTTOMLEFT", 0, bottom)
        tex:SetPoint("BOTTOMRIGHT", entry.trackBar, "BOTTOMRIGHT", 0, bottom)
        tex:SetHeight(stepH)
        tex._alpha = i <= lit and BAR_ALPHA or TRACK_ALPHA
        tex:SetColorTexture(hc[1], hc[2], hc[3], tex._alpha)
        tex:Show()
    end
    return true
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
    HideSteps(fx)

    local hc = addon.GetFocusHighlightColor(questData)
    local entryW, entryH = entry:GetWidth() or 0, entry:GetHeight() or 0
    local shown = {}  -- highlight textures drawn this pass, for the focus-change animation

    if entry.trackBar:IsShown() then
        if styleFx.progress and addon.GetDB("focusHighlightProgress", true)
            and ApplyProgress(fx, entry, questData, hc, entryH) then
            for _, tex in ipairs(fx.steps) do shown[#shown + 1] = tex end
        else
            shown[#shown + 1] = entry.trackBar
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
            PlayPointerEnter(fx.pointer)
        end
    end
end

--- Recolour the effects live (colour picker drag, class colour toggle) without a full layout.
-- @param entry Frame Focus entry
-- @param hc table {r, g, b}
function addon.FocusHighlight_Recolour(entry, hc)
    local fx = entry and entry._highlightFx
    if not fx then return end
    -- The layout recolour sets the bar's alpha from its vertex colour (always 1), so put it back:
    -- invisible under the progress steps, else the usual bar alpha.
    if fx.steps[1]:IsShown() then
        entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], 0)
        for _, tex in ipairs(fx.steps) do
            tex:SetColorTexture(hc[1], hc[2], hc[3], tex._alpha or BAR_ALPHA)
        end
    elseif entry.trackBar:IsShown() then
        entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], BAR_ALPHA)
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
