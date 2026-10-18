--[[
    Horizon Suite - Focus - Highlight Effects
    Effects built into the focused quest highlight styles: the bars get a soft glow, a progress
    fill and grow in when focus changes; the gradient slides in when focus changes and carries
    a sheen sweep. The animated parts follow the global Animations option.
]]

local addon = _G.HorizonSuite

-- Which effects each highlight style carries.
local STYLE_FX = {
    ["bar-gutter"] = { glow = true, progress = true, enter = true },
    ["bar-right"]  = { glow = true, progress = true, enter = true },
    ["gradient"]   = { enter = true, sheen = true },
}

local GLOW_W = 5          -- soft glow width either side of the bar, px
local GLOW_ALPHA = 0.45
local TRACK_ALPHA = 0.25  -- bar alpha behind the progress fill
local BAR_ALPHA = 0.70
local SHEEN_W = 18        -- width of each half of the sheen band, px
local SHEEN_ALPHA = 0.30
local SHEEN_DURATION = 1.1
local SHEEN_DELAY = 5
local ENTER_DURATION = 0.3
local SLIDE_OFFSET = 24   -- how far the gradient slides in from, px

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

    fx.glowL = entry:CreateTexture(nil, "BACKGROUND")
    fx.glowR = entry:CreateTexture(nil, "BACKGROUND")
    for _, tex in ipairs({ fx.glowL, fx.glowR }) do
        tex:SetBlendMode("ADD")
        tex:Hide()
    end

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
    for _, tex in ipairs({ entry.trackBar, fx.fill, fx.glowL, fx.glowR }) do
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

--- Hide every effect and stop its animations (entry no longer focused, or released to the pool).
-- @param entry Frame Focus entry
function addon.FocusHighlight_Clear(entry)
    local fx = entry and entry._highlightFx
    if not fx then return end
    fx.glowL:Hide(); fx.glowR:Hide(); fx.fill:Hide()
    HideSheen(fx)
    StopGroups(fx.enter)
end

local function ApplyGlow(fx, entry, hc)
    local w = S(GLOW_W)
    fx.glowL:ClearAllPoints()
    fx.glowL:SetPoint("TOPRIGHT", entry.trackBar, "TOPLEFT", 0, 0)
    fx.glowL:SetPoint("BOTTOMRIGHT", entry.trackBar, "BOTTOMLEFT", 0, 0)
    fx.glowL:SetWidth(w)
    addon.SetTextureFade(fx.glowL, "HORIZONTAL", hc, 0, GLOW_ALPHA)
    fx.glowR:ClearAllPoints()
    fx.glowR:SetPoint("TOPLEFT", entry.trackBar, "TOPRIGHT", 0, 0)
    fx.glowR:SetPoint("BOTTOMLEFT", entry.trackBar, "BOTTOMRIGHT", 0, 0)
    fx.glowR:SetWidth(w)
    addon.SetTextureFade(fx.glowR, "HORIZONTAL", hc, GLOW_ALPHA, 0)
    fx.glowL:Show(); fx.glowR:Show()
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
    addon.SetTextureFade(fx.sheenL, "HORIZONTAL", tint, 0, SHEEN_ALPHA)
    fx.sheenR:ClearAllPoints()
    fx.sheenR:SetPoint("TOPLEFT", fx.sheenL, "TOPRIGHT", 0, 0)
    fx.sheenR:SetPoint("BOTTOMLEFT", fx.sheenL, "BOTTOMRIGHT", 0, 0)
    fx.sheenR:SetWidth(w)
    addon.SetTextureFade(fx.sheenR, "HORIZONTAL", tint, SHEEN_ALPHA, 0)
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
    fx.glowL:Hide(); fx.glowR:Hide(); fx.fill:Hide()

    local hc = addon.GetFocusHighlightColor(questData)
    local entryW, entryH = entry:GetWidth() or 0, entry:GetHeight() or 0
    local shown = {}  -- highlight textures drawn this pass, for the focus-change animation

    if entry.trackBar:IsShown() then
        shown[#shown + 1] = entry.trackBar
        if styleFx.glow then
            ApplyGlow(fx, entry, hc)
            shown[#shown + 1] = fx.glowL
            shown[#shown + 1] = fx.glowR
        end
        if styleFx.progress then
            ApplyProgress(fx, entry, questData, hc, entryH)
            if fx.fill:IsShown() then shown[#shown + 1] = fx.fill end
        end
    elseif entry.highlightGradient:IsShown() then
        shown[#shown + 1] = entry.highlightGradient
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
    end
end

--- Recolour the effects live (colour picker drag, class colour toggle) without a full layout.
-- @param entry Frame Focus entry
-- @param hc table {r, g, b}
function addon.FocusHighlight_Recolour(entry, hc)
    local fx = entry and entry._highlightFx
    if not fx then return end
    if fx.glowL:IsShown() then
        addon.SetTextureFade(fx.glowL, "HORIZONTAL", hc, 0, GLOW_ALPHA)
        addon.SetTextureFade(fx.glowR, "HORIZONTAL", hc, GLOW_ALPHA, 0)
    end
    if fx.fill:IsShown() then
        fx.fill:SetColorTexture(hc[1], hc[2], hc[3], BAR_ALPHA)
    end
    if fx.sheenL:IsShown() then
        local tint = SheenTint(hc)
        addon.SetTextureFade(fx.sheenL, "HORIZONTAL", tint, 0, SHEEN_ALPHA)
        addon.SetTextureFade(fx.sheenR, "HORIZONTAL", tint, SHEEN_ALPHA, 0)
    end
end
