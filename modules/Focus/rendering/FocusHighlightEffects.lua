--[[
    Horizon Suite - Focus - Highlight Effects
    Extras layered on the focused quest highlight: soft glow and progress fill on the bars,
    the slide-in when focus changes, the sheen sweep, and breathing.
    Each is off unless its option is on; the animated ones also follow the global Animations option.
]]

local addon = _G.HorizonSuite

local GLOW_W = 5          -- soft glow width either side of the bar, px
local GLOW_ALPHA = 0.45
local TRACK_ALPHA = 0.25  -- bar alpha behind the progress fill
local BAR_ALPHA = 0.70
local SHEEN_W = 18        -- width of each half of the sheen band, px
local SHEEN_ALPHA = 0.30
local SHEEN_DURATION = 1.1
local SHEEN_DELAY = 5
local BREATHE_LOW = 0.45
local BREATHE_DURATION = 1.6
local SLIDE_DURATION = 0.3
local SLIDE_OFFSET = 24   -- how far the gradient slides in from, px

-- Key of the quest that last played the focus-change animation, so it plays once per change.
local lastFocusKey

local function S(v)
    return addon.Scaled and addon.Scaled(v) or v
end

local function AnimOn(dbKey)
    return addon.GetDB(dbKey, false) and addon.GetDB("animations", true)
end

local function IsBarStyle(style)
    return style == "bar-gutter" or style == "bar-right"
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

    -- One breathing group and one slide-in group per highlight texture.
    fx.breathe, fx.slide = {}, {}
    local function addBreathe(tex)
        local ag = tex:CreateAnimationGroup()
        ag:SetLooping("BOUNCE")
        local a = ag:CreateAnimation("Alpha")
        a:SetFromAlpha(1)
        a:SetToAlpha(BREATHE_LOW)
        a:SetDuration(BREATHE_DURATION)
        a:SetSmoothing("IN_OUT")
        fx.breathe[tex] = ag
    end
    local function addSlide(tex, vertical)
        local ag = tex:CreateAnimationGroup()
        local hideA = ag:CreateAnimation("Alpha")
        hideA:SetFromAlpha(0); hideA:SetToAlpha(0); hideA:SetDuration(0); hideA:SetOrder(1)
        local showA = ag:CreateAnimation("Alpha")
        showA:SetFromAlpha(0); showA:SetToAlpha(1); showA:SetDuration(SLIDE_DURATION); showA:SetOrder(2)
        if vertical then
            -- Bars grow out from their middle.
            local squash = ag:CreateAnimation("Scale")
            squash:SetScale(1, 0.05); squash:SetDuration(0); squash:SetOrder(1)
            local grow = ag:CreateAnimation("Scale")
            grow:SetScale(1, 20); grow:SetDuration(SLIDE_DURATION); grow:SetSmoothing("OUT"); grow:SetOrder(2)
        else
            -- The gradient slides in from the left.
            local back = ag:CreateAnimation("Translation")
            back:SetOffset(-S(SLIDE_OFFSET), 0); back:SetDuration(0); back:SetOrder(1)
            local forward = ag:CreateAnimation("Translation")
            forward:SetOffset(S(SLIDE_OFFSET), 0); forward:SetDuration(SLIDE_DURATION); forward:SetSmoothing("OUT"); forward:SetOrder(2)
        end
        fx.slide[tex] = ag
    end
    for _, tex in ipairs({ entry.trackBar, fx.fill, fx.glowL, fx.glowR }) do
        addBreathe(tex)
        addSlide(tex, true)
    end
    addBreathe(entry.highlightGradient)
    addSlide(entry.highlightGradient, false)

    entry._highlightFx = fx
    return fx
end

local function StopGroups(groups)
    for _, ag in pairs(groups) do
        if ag:IsPlaying() then ag:Stop() end
    end
end

--- Hide every extra and stop its animations (entry no longer focused, or released to the pool).
-- @param entry Frame Focus entry
function addon.FocusHighlight_Clear(entry)
    local fx = entry and entry._highlightFx
    if not fx then return end
    fx.glowL:Hide(); fx.glowR:Hide(); fx.fill:Hide(); fx.sheenL:Hide(); fx.sheenR:Hide()
    StopGroups(fx.sheenAnims)
    StopGroups(fx.breathe)
    StopGroups(fx.slide)
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
-- @return boolean true when the fill is drawn
local function ApplyProgress(fx, entry, questData, hc, entryH)
    local progress = addon.GetFocusQuestProgress(questData)
    if not progress then return false end
    entry.trackBar:SetColorTexture(hc[1], hc[2], hc[3], TRACK_ALPHA)
    fx.fill:SetColorTexture(hc[1], hc[2], hc[3], BAR_ALPHA)
    fx.fill:ClearAllPoints()
    fx.fill:SetPoint("BOTTOMLEFT", entry.trackBar, "BOTTOMLEFT", 0, 0)
    fx.fill:SetPoint("BOTTOMRIGHT", entry.trackBar, "BOTTOMRIGHT", 0, 0)
    if progress > 0 then
        fx.fill:SetHeight(math.max(1, entryH * progress))
        fx.fill:Show()
    end
    return true
end

local function ApplySheen(fx, entry, hc, entryW)
    -- Tint toward white so the band reads as light, not as more highlight colour.
    local tint = { (hc[1] + 1) / 2, (hc[2] + 1) / 2, (hc[3] + 1) / 2 }
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
    for _, ag in ipairs(fx.sheenAnims) do
        if not ag:IsPlaying() then ag:Play() end
    end
end

--- Apply the highlight extras after the entry has its final size and the track bar is placed.
-- @param entry Frame Focus entry
-- @param questData table
-- @param highlightStyle string normalised style
function addon.FocusHighlight_Apply(entry, questData, highlightStyle)
    if not questData.isSuperTracked or highlightStyle == "none" then
        addon.FocusHighlight_Clear(entry)
        return
    end
    local fx = Ensure(entry)
    -- Hide the extras but leave running loops alone, so a re-render does not restart them.
    fx.glowL:Hide(); fx.glowR:Hide(); fx.fill:Hide()

    local hc = addon.GetFocusHighlightColor(questData)
    local entryW, entryH = entry:GetWidth() or 0, entry:GetHeight() or 0
    local bar = IsBarStyle(highlightStyle) and entry.trackBar:IsShown()
    local shown = {}  -- highlight textures drawn this pass, for breathing and the slide-in

    if bar then
        shown[#shown + 1] = entry.trackBar
        if addon.GetDB("focusHighlightSoftGlow", false) then
            ApplyGlow(fx, entry, hc)
            shown[#shown + 1] = fx.glowL
            shown[#shown + 1] = fx.glowR
        end
        if addon.GetDB("focusHighlightProgress", false) and ApplyProgress(fx, entry, questData, hc, entryH) then
            if fx.fill:IsShown() then shown[#shown + 1] = fx.fill end
        end
    elseif highlightStyle == "gradient" and entry.highlightGradient:IsShown() then
        shown[#shown + 1] = entry.highlightGradient
    end

    if AnimOn("focusHighlightSheen") and entryW > 0 then
        ApplySheen(fx, entry, hc, entryW)
    else
        fx.sheenL:Hide(); fx.sheenR:Hide()
        StopGroups(fx.sheenAnims)
    end

    local breathing = {}
    if AnimOn("focusHighlightBreathe") then
        for _, tex in ipairs(shown) do breathing[tex] = true end
    end
    for tex, ag in pairs(fx.breathe) do
        if breathing[tex] then
            if not ag:IsPlaying() then ag:Play() end
        elseif ag:IsPlaying() then
            ag:Stop()
        end
    end

    local key = questData.questID or questData.title
    if key ~= nil and key ~= lastFocusKey then
        lastFocusKey = key
        if AnimOn("focusHighlightAnimateChange") then
            for _, tex in ipairs(shown) do fx.slide[tex]:Play() end
        end
    end
end

--- Recolour the extras live (colour picker drag, class colour toggle) without a full layout.
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
        local tint = { (hc[1] + 1) / 2, (hc[2] + 1) / 2, (hc[3] + 1) / 2 }
        addon.SetTextureFade(fx.sheenL, "HORIZONTAL", tint, 0, SHEEN_ALPHA)
        addon.SetTextureFade(fx.sheenR, "HORIZONTAL", tint, SHEEN_ALPHA, 0)
    end
end
