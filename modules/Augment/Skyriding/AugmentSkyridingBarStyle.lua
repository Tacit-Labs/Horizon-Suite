--[[
    Horizon Suite - Augment / Skyriding - Bar Style
    Rectangular Vigor charge bar + speed bar renderer (the "Falcon-style"
    option). Built entirely from plain statusbars (Interface\Buttons\WHITE8X8)
    and BackdropTemplate borders — no custom texture atlas, per the
    Blizzard-native-primitives-only constraint on this mini-module.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
local S = Y and Y.Skyriding
if not S then return end

S.BarStyle = S.BarStyle or {}
local Bar = S.BarStyle

local NUM_CHARGES = 6
local root, speedBarBG, speedBar, chargesParent, textDisplay
local chargeBGs, chargeBars, secondWindBars = {}, {}, {}
local surgeIcon
local active = false
local prevSpeed = 0
local lastSnapshot

local function GetLayout()
    local D = addon.AUGMENT_DEFAULTS
    local width        = tonumber(S.GetDB("skyridingBarWidth", D.skyridingBarWidth)) or D.skyridingBarWidth
    local chargeHeight = tonumber(S.GetDB("skyridingBarChargeHeight", D.skyridingBarChargeHeight)) or D.skyridingBarChargeHeight
    local speedHeight  = tonumber(S.GetDB("skyridingBarSpeedHeight", D.skyridingBarSpeedHeight)) or D.skyridingBarSpeedHeight
    local padding      = tonumber(S.GetDB("skyridingBarPadding", D.skyridingBarPadding)) or D.skyridingBarPadding
    local swap         = S.GetDB("skyridingBarSwapPosition", D.skyridingBarSwapPosition)
    return width, chargeHeight, speedHeight, padding, swap
end

local function RefreshChargeSegments()
    if not lastSnapshot then return end
    local info = lastSnapshot
    local progress = info.charges
    if info.isCharging and info.chargeDuration and info.chargeDuration > 0 then
        progress = info.charges + math.min((GetTime() - info.chargeStart) / info.chargeDuration, 1)
    end
    local totalFilled = info.charges + (info.swCharges or 0)
    for i = 1, NUM_CHARGES do
        local value = 0
        if i <= math.floor(progress) then
            value = 1
        elseif i == math.ceil(progress) then
            value = progress - math.floor(progress)
        end
        chargeBars[i]:SetValue(value)
        secondWindBars[i]:SetValue((i <= totalFilled) and 1 or 0)
    end
end

local function RefreshSpeedBar()
    if not lastSnapshot then return end
    local info = lastSnapshot
    local forwardSpeed = info.forwardSpeed or 0
    local target = forwardSpeed * (info.speedScale or 0.011764)
    prevSpeed = (FrameDeltaLerp and FrameDeltaLerp(prevSpeed, target, 0.2)) or target
    speedBar:SetValue(math.min(prevSpeed, 1.2))
    speedBar.tick:SetShown(info.isThrill and true or false)

    local r, g, b
    if info.isThrill then
        r, g, b = S.GetColor("skyridingBarSpeedThrillColor")
    elseif info.isGroundSkimming then
        r, g, b = S.GetColor("skyridingBarSpeedGroundSkimColor")
    else
        r, g, b = S.GetColor("skyridingBarSpeedLowColor")
    end
    speedBar:SetStatusBarColor(r, g, b, 1)

    local D = addon.AUGMENT_DEFAULTS
    if S.GetDB("skyridingShowSpeedText", D.skyridingShowSpeedText) then
        local displaySpeed = forwardSpeed * 14.285
        textDisplay:SetText(displaySpeed > 0 and string.format("%d", displaySpeed) or "")
    else
        textDisplay:SetText("")
    end
end

local function RefreshSurge()
    if not lastSnapshot then return end
    local info = lastSnapshot
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

local function OnUpdateTick()
    if not active then return end
    RefreshChargeSegments()
    RefreshSpeedBar()
end

function Bar.ApplyColors()
    if not root then return end
    local r, g, b = S.GetColor("skyridingBarChargeColor")
    local swr, swg, swb = S.GetColor("skyridingSecondWindColor")
    for i = 1, NUM_CHARGES do
        chargeBars[i]:SetStatusBarColor(r, g, b, 1)
        secondWindBars[i]:SetStatusBarColor(swr, swg, swb, 0.6)
    end
end

function Bar.ApplyLayout()
    if not root then return end
    local width, chargeHeight, speedHeight, padding, swap = GetLayout()
    local sWidth, sCH, sSH, sPad = S.Scale(width), S.Scale(chargeHeight), S.Scale(speedHeight), S.Scale(padding)
    local totalWidth = (sWidth * NUM_CHARGES) + (sPad * (NUM_CHARGES - 1))

    speedBarBG:SetSize(totalWidth, sSH)
    chargesParent:SetSize(totalWidth, sCH)
    speedBarBG:ClearAllPoints()
    chargesParent:ClearAllPoints()
    if swap then
        speedBarBG:SetPoint("BOTTOM", root, "BOTTOM")
        chargesParent:SetPoint("BOTTOM", speedBarBG, "TOP", 0, sPad)
    else
        speedBarBG:SetPoint("TOP", root, "TOP")
        chargesParent:SetPoint("TOP", speedBarBG, "BOTTOM", 0, -sPad)
    end

    speedBar:ClearAllPoints()
    speedBar:SetAllPoints(speedBarBG)
    speedBar.tick:ClearAllPoints()
    speedBar.tick:SetWidth(2)
    speedBar.tick:SetPoint("TOP", speedBar, "TOP")
    speedBar.tick:SetPoint("BOTTOM", speedBar, "BOTTOM")
    speedBar.tick:SetPoint("LEFT", speedBar, "LEFT", totalWidth / 2 - 1, 0)

    for i = 1, NUM_CHARGES do
        local bg = chargeBGs[i]
        bg:SetSize(sWidth, sCH)
        bg:ClearAllPoints()
        if i == 1 then
            bg:SetPoint("LEFT", chargesParent, "LEFT")
        else
            bg:SetPoint("LEFT", chargeBGs[i - 1], "RIGHT", sPad, 0)
        end
        chargeBars[i]:SetAllPoints(bg)
        secondWindBars[i]:SetAllPoints(bg)
    end

    surgeIcon:ClearAllPoints()
    surgeIcon:SetSize(S.Scale(28), S.Scale(28))
    surgeIcon:SetPoint("BOTTOM", chargesParent, "TOP", 0, S.Scale(8))

    Bar.ApplyColors()
end

function Bar.SetActive(isActive)
    active = isActive
    if root then root:SetShown(isActive) end
end

function Bar.Init(parent)
    if root then return end

    root = CreateFrame("Frame", nil, parent)
    root:SetAllPoints(parent)

    speedBarBG = CreateFrame("Frame", nil, root, "BackdropTemplate")
    speedBarBG:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    speedBarBG:SetBackdropBorderColor(0, 0, 0, 0.6)

    speedBar = CreateFrame("StatusBar", nil, speedBarBG)
    speedBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    speedBar:SetMinMaxValues(0, 1.2)
    speedBar:SetValue(0)
    speedBar.tick = speedBar:CreateTexture(nil, "OVERLAY")
    speedBar.tick:SetColorTexture(0, 0, 0, 1)
    speedBar.tick:Hide()

    textDisplay = speedBarBG:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textDisplay:SetJustifyH("RIGHT")
    textDisplay:SetJustifyV("MIDDLE")
    textDisplay:SetPoint("RIGHT", speedBarBG, "RIGHT", -4, 0)

    chargesParent = CreateFrame("Frame", nil, root)

    for i = 1, NUM_CHARGES do
        local bg = CreateFrame("Frame", nil, chargesParent, "BackdropTemplate")
        bg:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        bg:SetBackdropBorderColor(0, 0, 0, 0.6)

        local secondWind = CreateFrame("StatusBar", nil, bg)
        secondWind:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        secondWind:SetMinMaxValues(0, 1)
        secondWind:SetValue(0)

        local chargeBar = CreateFrame("StatusBar", nil, bg)
        chargeBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        chargeBar:SetMinMaxValues(0, 1)
        chargeBar:SetValue(0)
        chargeBar:SetFrameLevel(secondWind:GetFrameLevel() + 1)

        chargeBGs[i] = bg
        chargeBars[i] = chargeBar
        secondWindBars[i] = secondWind
    end

    surgeIcon = CreateFrame("Frame", nil, root)
    surgeIcon.Icon = surgeIcon:CreateTexture(nil, "ARTWORK")
    surgeIcon.Icon:SetAllPoints()
    surgeIcon.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    surgeIcon.Cooldown = CreateFrame("Cooldown", nil, surgeIcon, "CooldownFrameTemplate")
    surgeIcon.Cooldown:SetAllPoints()
    surgeIcon.Cooldown:SetHideCountdownNumbers(false)
    surgeIcon:Hide()

    root:SetScript("OnUpdate", OnUpdateTick)
    Bar.ApplyLayout()
    root:Hide()
end

function Bar.Update(snapshot)
    if not root then return end
    lastSnapshot = snapshot
    RefreshChargeSegments()
    RefreshSpeedBar()
    RefreshSurge()
end
