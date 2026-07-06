--[[
    Horizon Suite - Augment / Skyriding - Circular Style
    Radial Vigor gauge renderer (the "Glider-style" option). Built entirely
    from Blizzard-native primitives: CooldownFrameTemplate's default pie
    swipe (untouched — no custom swipe/edge texture) layered over flat-color
    masked-circle backgrounds (Interface\Masks\CircleMaskScalable, the same
    scalable round mask Blizzard's own modern UI uses for icon crops). The
    "donut ring" look for the speed indicator and Second Wind comes from
    concentric same-centre circles drawn at different radii and stacked in
    sublayer order — no hole-punch texture needed, the smaller circle on top
    just covers the larger one's centre.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

S.CircularStyle = S.CircularStyle or {}
local Circ = S.CircularStyle

local CIRCLE_MASK = "Interface\\Masks\\CircleMaskScalable"

local root
local speedBG, speedSwipe
local vigorBG, vigorSwipe
local swBG, swSwipe
local pulseTex, pulseAnim
local surgeIcon
local textDisplay
local active = false
local lastSnapshot
local lastCharges = 0

local function GetSize()
    local D = addon.AUGMENT_DEFAULTS
    return tonumber(S.GetDB("skyridingCircularSize", D.skyridingCircularSize)) or D.skyridingCircularSize
end

local function CreateMaskedCircle(parent, layer, subLevel)
    local tex = parent:CreateTexture(nil, layer, nil, subLevel)
    tex:SetColorTexture(1, 1, 1, 1)
    local mask = parent:CreateMaskTexture()
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(tex)
    tex:AddMaskTexture(mask)
    return tex
end

-- A flat-color background + an unmodified default Cooldown swipe (dark,
-- reversed so it covers the *unfilled* portion) reproduces the same
-- "colored disc that fills in" look Glider gets from its painted atlas,
-- without needing any custom swipe/edge art.
local function CreateRing(parent, subLevel)
    local bg = CreateMaskedCircle(parent, "ARTWORK", subLevel)
    local swipe = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate") ---@diagnostic disable-line
    swipe:SetAllPoints(bg)
    swipe:SetReverse(true)
    swipe:SetDrawEdge(false)
    swipe:SetDrawBling(false)
    swipe:SetHideCountdownNumbers(true)
    swipe:SetSwipeColor(0, 0, 0, 0.8)
    swipe.noCooldownCount = true
    return bg, swipe
end

local function ApplySizes()
    if not root then return end
    local size = S.Scale(GetSize())
    root:SetSize(size * 1.5, size * 1.5)

    speedBG:SetSize(size * 1.25, size * 1.25)
    speedBG:ClearAllPoints()
    speedBG:SetPoint("CENTER", root, "CENTER")
    speedSwipe:SetAllPoints(speedBG)

    vigorBG:SetSize(size, size)
    vigorBG:ClearAllPoints()
    vigorBG:SetPoint("CENTER", root, "CENTER")
    vigorSwipe:SetAllPoints(vigorBG)

    swBG:SetSize(size * 0.55, size * 0.55)
    swBG:ClearAllPoints()
    swBG:SetPoint("CENTER", root, "CENTER")
    swSwipe:SetAllPoints(swBG)

    pulseTex:SetSize(size * 1.3, size * 1.3)
    pulseTex:ClearAllPoints()
    pulseTex:SetPoint("CENTER", root, "CENTER")

    surgeIcon:SetSize(S.Scale(28), S.Scale(28))
    surgeIcon:ClearAllPoints()
    surgeIcon:SetPoint("TOP", speedBG, "BOTTOM", 0, -S.Scale(6))

    textDisplay:ClearAllPoints()
    textDisplay:SetPoint("CENTER", vigorBG, "CENTER")
end

function Circ.ApplyColors()
    if not root then return end
    local r, g, b = S.GetColor("skyridingCircularColor")
    vigorBG:SetColorTexture(r, g, b, 1)
    pulseTex:SetColorTexture(r, g, b, 0.6)
end

local function RefreshVigor(info)
    local progress = info.charges / math.max(1, info.maxCharges)
    if info.isCharging and info.chargeDuration and info.chargeDuration > 0 then
        local now = GetTime()
        local within = math.min((now - info.chargeStart) / info.chargeDuration, 1)
        progress = (info.charges + within) / math.max(1, info.maxCharges)
    end
    CooldownFrame_SetDisplayAsPercentage(vigorSwipe, 1 - math.min(progress, 1))

    if info.charges > lastCharges then
        pulseAnim:Restart()
    end
    lastCharges = info.charges
end

local function RefreshSecondWind(info)
    local total = (info.swMaxCharges or 0)
    if total <= 0 then
        swBG:Hide()
        swSwipe:Hide()
        return
    end
    swBG:Show()
    swSwipe:Show()
    local r, g, b = S.GetColor("skyridingSecondWindColor")
    swBG:SetColorTexture(r, g, b, 1)
    local filled = (info.swCharges or 0) / total
    CooldownFrame_SetDisplayAsPercentage(swSwipe, 1 - math.min(filled, 1))
end

local function RefreshSpeed(info)
    local forwardSpeed = info.forwardSpeed or 0
    local target = math.min(forwardSpeed * (info.speedScale or 0.011764), 1.2) / 1.2
    CooldownFrame_SetDisplayAsPercentage(speedSwipe, 1 - target)

    local r, g, b
    if info.isThrill then
        r, g, b = S.GetColor("skyridingBarSpeedThrillColor")
    elseif info.isGroundSkimming then
        r, g, b = S.GetColor("skyridingBarSpeedGroundSkimColor")
    else
        r, g, b = S.GetColor("skyridingBarSpeedLowColor")
    end
    speedBG:SetColorTexture(r, g, b, 1)

    local D = addon.AUGMENT_DEFAULTS
    if S.GetDB("skyridingShowSpeedText", D.skyridingShowSpeedText) then
        local displaySpeed = forwardSpeed * 14.285
        textDisplay:SetText(displaySpeed > 0 and string.format("%d", displaySpeed) or "")
    else
        textDisplay:SetText("")
    end
end

local function RefreshSurge(info)
    if S.ShouldShowWhirlingSurge(info.surgeDuration or 0) then
        surgeIcon.Icon:SetTexture(S.API:GetWhirlingSurgeIcon())
        surgeIcon:Show()
        if info.surgeStart and info.surgeStart > 0 and info.surgeDuration and info.surgeDuration > 0 then
            surgeIcon.Cooldown:SetCooldown(info.surgeStart, info.surgeDuration)
        end
    else
        surgeIcon:Hide()
    end
end

function Circ.SetActive(isActive)
    active = isActive
    if root then root:SetShown(isActive) end
end

function Circ.Init(parent)
    if root then return end

    root = CreateFrame("Frame", nil, parent)
    root:SetPoint("CENTER", parent, "CENTER")

    speedBG, speedSwipe = CreateRing(root, -2)
    vigorBG, vigorSwipe = CreateRing(root, 0)
    swBG, swSwipe = CreateRing(root, 2)

    pulseTex = CreateMaskedCircle(root, "OVERLAY", 0)
    pulseTex:SetBlendMode("ADD")
    pulseTex:SetAlpha(0)

    pulseAnim = pulseTex:CreateAnimationGroup()
    pulseAnim:SetToFinalAlpha(true)
    local pAlpha = pulseAnim:CreateAnimation("Alpha")
    pAlpha:SetFromAlpha(0.8)
    pAlpha:SetToAlpha(0)
    pAlpha:SetDuration(0.5)
    pAlpha:SetSmoothing("OUT")
    local pScale = pulseAnim:CreateAnimation("Scale")
    pScale:SetScaleFrom(0.85, 0.85)
    pScale:SetScaleTo(1.15, 1.15)
    pScale:SetDuration(0.5)
    pScale:SetSmoothing("OUT")

    surgeIcon = CreateFrame("Frame", nil, root)
    surgeIcon.Icon = surgeIcon:CreateTexture(nil, "ARTWORK")
    surgeIcon.Icon:SetAllPoints()
    surgeIcon.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    surgeIcon.Cooldown = CreateFrame("Cooldown", nil, surgeIcon, "CooldownFrameTemplate") ---@diagnostic disable-line
    surgeIcon.Cooldown:SetAllPoints()
    surgeIcon.Cooldown:SetHideCountdownNumbers(false)
    surgeIcon:Hide()

    textDisplay = root:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textDisplay:SetJustifyH("CENTER")
    textDisplay:SetJustifyV("MIDDLE")

    ApplySizes()
    Circ.ApplyColors()
    root:Hide()
end

function Circ.ApplyLayout()
    ApplySizes()
    Circ.ApplyColors()
end

function Circ.Update(snapshot)
    if not root then return end
    lastSnapshot = snapshot
    RefreshVigor(snapshot)
    RefreshSecondWind(snapshot)
    RefreshSpeed(snapshot)
    RefreshSurge(snapshot)
end
