--[[
    Horizon Suite - Focus - Dungeon Run Block

    Cinematic banner for an ordinary party dungeon: elapsed time, experience and
    money earned, the per-hour rates, and bosses defeated. Hover shows the boss
    list and the projection to the next level.

    This is the counterpart to FocusMplusBlock, and the two are mutually
    exclusive: a keystone run shows the M+ banner, everything else shows this one.
    FocusBlocks owns that rule so the layout only ever deals with "the active
    block". Structure, typography and positioning deliberately mirror the M+ block
    so the two read as one component in different clothes.

    Data comes from FocusRunTracker; nothing here reads a game API for run figures.
]]

local addon = _G.HorizonSuite
local L = addon.L

local RUN_MIN_HEIGHT = 72
local ROW_GAP = 6
local TICK_TEXT_GAP = " "

local runBlock = CreateFrame("Frame", nil, UIParent)
do
    local S = addon.Scaled or function(v) return v end
    runBlock:SetSize(addon.GetPanelWidth() - S(addon.PADDING) * 2, S(RUN_MIN_HEIGHT))
end
-- Parented to UIParent (not the panel) for the same reason as the M+ block: it
-- stays visible when "Show in dungeon" hides the tracker itself. Core's
-- ApplyFocusFrameStrata re-points it when the panel strata changes.
runBlock:SetFrameStrata(addon.HS:GetFrameStrata())
runBlock:SetFrameLevel(addon.HS:GetFrameLevel() + 5)
runBlock:EnableMouse(true)
runBlock:Hide()

local runBg = runBlock:CreateTexture(nil, "BACKGROUND")
runBg:SetAllPoints()
if runBg.SetGradient and CreateColor then
    runBg:SetGradient("VERTICAL", CreateColor(0.02, 0.02, 0.06, 0.88), CreateColor(0.05, 0.05, 0.12, 0.72))
else
    runBg:SetColorTexture(0.02, 0.02, 0.06, 0.78)
end

-- Line 1: dungeon name + difficulty
local runHeroShadow = runBlock:CreateFontString(nil, "BORDER")
local runHeroText = runBlock:CreateFontString(nil, "OVERLAY")
runHeroText:SetWordWrap(true)
runHeroText:SetJustifyH("LEFT")

-- Line 2: elapsed
local runTimerText = runBlock:CreateFontString(nil, "OVERLAY")
runTimerText:SetJustifyH("LEFT")

-- Lines 3+: stat ledger. Each row is a muted label on the left and the figure on
-- the right, so the numbers line up in a column however long the labels get.
local ROW_KEYS = { "xp", "money", "bosses" }
local rows = {}
for _, key in ipairs(ROW_KEYS) do
    local label = runBlock:CreateFontString(nil, "OVERLAY")
    label:SetJustifyH("LEFT")
    -- Labels give way to the figure when the panel is narrow. Without this they
    -- wrap to a second line and the ledger stops lining up.
    label:SetWordWrap(false)
    local value = runBlock:CreateFontString(nil, "OVERLAY")
    value:SetJustifyH("RIGHT")
    rows[key] = { label = label, value = value }
end

addon.runBlock = runBlock

-- Current height of the run block (content-driven).
function addon.GetDungeonRunBlockHeight()
    if runBlock and runBlock:IsShown() then
        return runBlock:GetHeight() or RUN_MIN_HEIGHT
    end
    return RUN_MIN_HEIGHT
end

-- ---------------------------------------------------------------------------
-- Formatting
-- ---------------------------------------------------------------------------

local function FormatElapsed(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    end
    return string.format("%d:%02d", m, s)
end

local function Grouped(n)
    local rounded = math.floor((tonumber(n) or 0) + 0.5)
    if addon.FormatNumberWithGrouping then
        return addon.FormatNumberWithGrouping(rounded)
    end
    return tostring(rounded)
end

-- Coin string with an explicit sign, because a run can end down on money after
-- a repair and GetCoinTextureString has nothing to say about negatives.
local function FormatMoney(copper)
    copper = math.floor(tonumber(copper) or 0)
    local sign = copper < 0 and "-" or ""
    local magnitude = math.abs(copper)
    local ok, text = pcall(function()
        return GetCoinTextureString and GetCoinTextureString(magnitude)
    end)
    if ok and text then return sign .. text end
    return sign .. Grouped(magnitude / 10000) .. "g"
end

-- Rates are shown in whole gold: the silver and copper on a per-hour projection
-- are noise, and the coin icons make the row twice as wide for nothing.
local function FormatGoldRate(copperPerHour)
    local gold = (tonumber(copperPerHour) or 0) / 10000
    local sign = gold < 0 and "-" or ""
    return sign .. Grouped(math.abs(gold)) .. "g"
end

local function ColorHex(r, g, b)
    return string.format("|cff%02x%02x%02x", math.floor((r or 1) * 255), math.floor((g or 1) * 255), math.floor((b or 1) * 255))
end

-- ---------------------------------------------------------------------------
-- Typography
-- ---------------------------------------------------------------------------

local function ClampedSize(key, default)
    local S = addon.Scaled or function(v) return v end
    return S(math.max(8, math.min(32, tonumber(addon.GetDB(key, default)) or default)))
end

local function ApplyRunTypography()
    local rawFont = addon.GetDB("fontPath", (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF")
    local fontPath = (addon.ResolveFontPath and addon.ResolveFontPath(rawFont)) or rawFont
    local fontOutline = addon.GetDB("fontOutline", "OUTLINE")

    local nameSize = ClampedSize("runNameSize", 14)
    local timerSize = ClampedSize("runTimerSize", 13)
    local statSize = ClampedSize("runStatSize", 12)

    local nameR = addon.GetDB("runNameColorR", 0.96)
    local nameG = addon.GetDB("runNameColorG", 0.96)
    local nameB = addon.GetDB("runNameColorB", 1.0)
    local timerR = addon.GetDB("runTimerColorR", 0.6)
    local timerG = addon.GetDB("runTimerColorG", 0.88)
    local timerB = addon.GetDB("runTimerColorB", 1.0)
    local labelR = addon.GetDB("runLabelColorR", 0.66)
    local labelG = addon.GetDB("runLabelColorG", 0.70)
    local labelB = addon.GetDB("runLabelColorB", 0.80)
    local valueR = addon.GetDB("runValueColorR", 0.96)
    local valueG = addon.GetDB("runValueColorG", 0.96)
    local valueB = addon.GetDB("runValueColorB", 1.0)

    local shadowOx = tonumber(addon.GetDB("shadowOffsetX", 2)) or 2
    local shadowOy = tonumber(addon.GetDB("shadowOffsetY", -2)) or -2
    local shadowA = addon.GetDB("showTextShadow", true) and (tonumber(addon.GetDB("shadowAlpha", 0.8)) or 0.8) or 0

    runHeroShadow:SetFont(fontPath, nameSize, fontOutline)
    runHeroShadow:SetTextColor(0, 0, 0, shadowA)
    runHeroShadow:SetJustifyH("LEFT")
    runHeroShadow:SetPoint("CENTER", runHeroText, "CENTER", shadowOx, shadowOy)
    runHeroText:SetFont(fontPath, nameSize, fontOutline)
    runHeroText:SetTextColor(nameR, nameG, nameB, 1)

    runTimerText:SetFont(fontPath, timerSize, fontOutline)
    runTimerText:SetTextColor(timerR, timerG, timerB, 1)

    for _, key in ipairs(ROW_KEYS) do
        rows[key].label:SetFont(fontPath, statSize, fontOutline)
        rows[key].label:SetTextColor(labelR, labelG, labelB, 1)
        rows[key].value:SetFont(fontPath, statSize, fontOutline)
        rows[key].value:SetTextColor(valueR, valueG, valueB, 1)
    end
end

-- ---------------------------------------------------------------------------
-- Display
-- ---------------------------------------------------------------------------

local function GetBlockContentWidth()
    local S = addon.Scaled or function(v) return v end
    local w = (addon.HS and addon.HS.GetWidth and addon.HS:GetWidth()) or addon.GetPanelWidth()
    return (w or S(addon.PANEL_WIDTH)) - S(addon.PADDING) * 2
end

local function PositionRunBlock(pos)
    local S = addon.Scaled or function(v) return v end
    runBlock:SetWidth(GetBlockContentWidth())
    runBlock:ClearAllPoints()
    if pos == "bottom" then
        runBlock:SetPoint("BOTTOMLEFT", addon.HS, "BOTTOMLEFT", S(addon.PADDING), S(addon.PADDING))
    else
        runBlock:SetPoint("TOPLEFT", addon.HS, "TOPLEFT", S(addon.PADDING), addon.GetContentTop())
    end
end

-- Builds "12,345  (18,400/hr)" with the rate in the accent colour. Before the
-- tracker will quote a rate the bracket is dropped rather than shown as zero.
local function WithRate(valueText, rateText)
    if not rateText then return valueText end
    local accent = ColorHex(
        addon.GetDB("runRateColorR", 0.55),
        addon.GetDB("runRateColorG", 0.85),
        addon.GetDB("runRateColorB", 0.65))
    return valueText .. "  " .. accent .. "(" .. rateText .. "/hr)|r"
end

local function UpdateRunBlockDisplay(data)
    if not data then return end
    local statSize = ClampedSize("runStatSize", 12)
    local nameSize = ClampedSize("runNameSize", 14)
    local timerSize = ClampedSize("runTimerSize", 13)

    -- Line 1: dungeon name + difficulty
    local heroStr = data.instanceName ~= "" and data.instanceName or L["FOCUS_RUN_DUNGEON_RUN"]
    if data.difficultyName and data.difficultyName ~= "" then
        heroStr = heroStr .. " (" .. data.difficultyName .. ")"
    end
    addon.SetTextWithShadow(runHeroText, runHeroShadow, heroStr)

    -- Line 2: elapsed
    runTimerText:SetText(FormatElapsed(data.elapsed))

    -- Stat rows. A row with nothing to say is hidden rather than zeroed: a fresh
    -- run at max level has no experience line at all.
    local shown = {}

    local showXP = addon.GetDB("runShowXP", true) and not data.xpCapped
    if showXP then
        local value = Grouped(data.xpGained)
        if data.levelsGained and data.levelsGained > 0 then
            local suffix = data.levelsGained == 1 and L["FOCUS_RUN_LEVEL_ONE"] or L["FOCUS_RUN_LEVEL_MANY"]
            value = value .. "  +" .. data.levelsGained .. " " .. suffix
        end
        rows.xp.label:SetText(L["FOCUS_RUN_EXPERIENCE"])
        rows.xp.value:SetText(WithRate(value, data.xpPerHour and Grouped(data.xpPerHour) or nil))
        shown[#shown + 1] = "xp"
    end

    local showMoney = addon.GetDB("runShowGold", true)
    if showMoney then
        rows.money.label:SetText(L["FOCUS_RUN_MONEY"])
        rows.money.value:SetText(WithRate(
            FormatMoney(data.moneyGained),
            data.moneyPerHour and FormatGoldRate(data.moneyPerHour) or nil))
        shown[#shown + 1] = "money"
    end

    local bossCount = data.bosses and #data.bosses or 0
    local showBosses = addon.GetDB("runShowBosses", true) and bossCount > 0
    if showBosses then
        rows.bosses.label:SetText(L["FOCUS_RUN_BOSSES"])
        -- Floored: UI scaling can make the size fractional, and a texture escape
        -- wants integers on both axes.
        local tick = math.floor(statSize)
        rows.bosses.value:SetText(
            "|TInterface\\Buttons\\UI-CheckBox-Check:" .. tick .. ":" .. tick .. ":0:0|t"
            .. TICK_TEXT_GAP .. Grouped(bossCount))
        shown[#shown + 1] = "bosses"
    end

    local isShown = {}
    for _, key in ipairs(shown) do isShown[key] = true end
    for _, key in ipairs(ROW_KEYS) do
        rows[key].label:SetShown(isShown[key] == true)
        rows[key].value:SetShown(isShown[key] == true)
    end

    -- ----------------------------------------------------------------
    -- Layout. Everything is positioned explicitly from the top so no anchor
    -- chain runs through a hidden row. All plain frames, safe during combat.
    -- ----------------------------------------------------------------
    local heroLeft = 4
    local sidePadding = heroLeft + 4
    local panelWidth = GetBlockContentWidth()
    runBlock:SetWidth(panelWidth)
    local contentWidth = math.max(1, panelWidth - sidePadding)
    local y = -4

    runHeroText:ClearAllPoints()
    runHeroText:SetPoint("TOPLEFT", runBlock, "TOPLEFT", heroLeft, y)
    runHeroText:SetWidth(contentWidth)
    runHeroShadow:SetWidth(contentWidth)
    runHeroShadow:SetWordWrap(true)
    y = y - (runHeroText:GetStringHeight() or nameSize) - ROW_GAP

    runTimerText:ClearAllPoints()
    runTimerText:SetPoint("TOPLEFT", runBlock, "TOPLEFT", heroLeft, y)
    y = y - (runTimerText:GetStringHeight() or timerSize) - ROW_GAP

    for _, key in ipairs(shown) do
        local row = rows[key]
        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT", runBlock, "TOPLEFT", heroLeft, y)
        row.value:ClearAllPoints()
        row.value:SetPoint("TOPRIGHT", runBlock, "TOPRIGHT", -heroLeft, y)
        -- The value is the longer half, so the label yields the width it needs.
        local valueWidth = math.min(contentWidth, row.value:GetStringWidth() or 0)
        row.label:SetWidth(math.max(1, contentWidth - valueWidth - 8))
        local rowH = math.max(row.label:GetStringHeight() or statSize, row.value:GetStringHeight() or statSize)
        y = y - rowH - 4
    end

    runBlock:SetHeight(math.max(RUN_MIN_HEIGHT, -y + 4))
end

-- ---------------------------------------------------------------------------
-- Tooltip
-- ---------------------------------------------------------------------------

local TOOLTIP_FONT_SIZE = 13

local function ShowRunTooltip()
    if not addon.GetDB("focusShowTooltipOnHover", false) then return end
    local data = addon.runDebugPreview and addon.GetDungeonRunDemoData() or addon.GetDungeonRunData()
    if not data then return end

    local tt = GameTooltip
    addon.focus.AnchorTooltip(tt, runBlock)
    tt:ClearLines()
    tt:AddLine(data.instanceName ~= "" and data.instanceName or L["FOCUS_RUN_DUNGEON_RUN"], 1, 1, 1)
    tt:AddLine(L["FOCUS_RUN_ELAPSED"] .. ": " .. FormatElapsed(data.elapsed), 0.8, 0.8, 0.8)

    if not data.xpCapped then
        tt:AddLine(L["FOCUS_RUN_EXPERIENCE"] .. ": " .. Grouped(data.xpGained), 0.8, 0.8, 0.8)
        -- Projection to the next level, which is the figure an XP rate is
        -- actually a proxy for. Only offered once the rate itself is trusted.
        if data.xpPerHour and data.xpPerHour > 0 and data.xpToNextLevel and data.xpToNextLevel > 0 then
            local secondsToLevel = data.xpToNextLevel / (data.xpPerHour / 3600)
            tt:AddLine(L["FOCUS_RUN_NEXT_LEVEL_IN"] .. ": " .. FormatElapsed(secondsToLevel), 0.8, 0.8, 0.8)
        end
    end

    tt:AddLine(L["FOCUS_RUN_MONEY"] .. ": " .. FormatMoney(data.moneyGained), 0.8, 0.8, 0.8)

    if data.bosses and #data.bosses > 0 then
        tt:AddLine(" ")
        tt:AddLine(L["FOCUS_RUN_BOSSES"], 1, 1, 1)
        for _, name in ipairs(data.bosses) do
            tt:AddLine(name, 0.6, 0.85, 0.6)
        end
    end

    tt:Show()
    local fontPath = (GameFontNormal and GameFontNormal:GetFont()) or "Fonts\\FRIZQT__.TTF"
    for i = 1, tt:NumLines() do
        local left = _G["GameTooltipTextLeft" .. i]
        if left then
            left:SetFont(fontPath, TOOLTIP_FONT_SIZE, "OUTLINE")
        end
    end
end

local function HideRunTooltip()
    if GameTooltip:IsOwned(runBlock) then
        GameTooltip:Hide()
    end
end

runBlock:SetScript("OnEnter", function()
    ShowRunTooltip()
    if addon.IsFocusHoverTrackingEnabled and addon.IsFocusHoverTrackingEnabled() and addon.EnsureFocusUpdateRunning then
        addon.EnsureFocusUpdateRunning()
    end
end)
runBlock:SetScript("OnLeave", function()
    HideRunTooltip()
    if addon.IsFocusHoverTrackingEnabled and addon.IsFocusHoverTrackingEnabled() and addon.EnsureFocusUpdateRunning then
        addon.EnsureFocusUpdateRunning()
    end
end)

-- ---------------------------------------------------------------------------
-- Update
-- ---------------------------------------------------------------------------

-- Drives `/h debug focus rundebug` and the "Always" preview toggle outside a
-- dungeon. Debug subcommands route through the module debug handler, so the
-- shorter `/h rundebug` reaches nothing.
local RUN_DEMO_DATA = {
    instanceName   = "Scarlet Monastery",
    difficultyName = "Heroic",
    elapsed        = 1327,
    xpCapped       = false,
    xpGained       = 41250,
    xpPerHour      = 111900,
    xpToNextLevel  = 18400,
    levelsGained   = 1,
    moneyGained    = 274300,
    moneyPerHour   = 744000,
    bosses         = { "Interrogator Vishas", "Houndmaster Loksey", "Bloodmage Thalnos" },
    hasRates       = true,
}

function addon.GetDungeonRunDemoData()
    return RUN_DEMO_DATA
end

local timeSinceLastUpdate = 0
runBlock:SetScript("OnUpdate", function(self, elapsed)
    if not self:IsShown() then return end
    if addon.runDebugPreview then return end
    if not addon.IsDungeonRunActive() then return end

    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= 1.0 then
        timeSinceLastUpdate = 0
        UpdateRunBlockDisplay(addon.GetDungeonRunData())
    end
end)

local function UpdateDungeonRunBlock()
    local pos = addon.GetDB("runBlockPosition", "top") or "top"

    if addon.runDebugPreview then
        PositionRunBlock(pos)
        ApplyRunTypography()
        UpdateRunBlockDisplay(RUN_DEMO_DATA)
        runBlock:Show()
        return
    end

    if not addon.GetDB("showRunBlock", true) then
        runBlock:Hide()
        return
    end

    -- The block is parented to UIParent, so disabling Focus does not take it down
    -- with the panel. Nothing should outlive the module that owns it.
    if addon.focus and addon.focus.enabled == false then
        runBlock:Hide()
        return
    end

    -- The M+ banner owns the screen in a keystone run; never stack the two.
    if addon.mplusBlock and addon.mplusBlock:IsShown() then
        runBlock:Hide()
        return
    end

    local data = addon.GetDungeonRunData()
    local alwaysShow = addon.GetDB("runAlwaysShow", false)
    if not data then
        if not alwaysShow then
            runBlock:Hide()
            return
        end
        data = RUN_DEMO_DATA
    end

    PositionRunBlock(pos)
    if not runBlock:IsShown() then
        ApplyRunTypography()
    end
    UpdateRunBlockDisplay(data)
    runBlock:Show()
end

addon.UpdateDungeonRunBlock = UpdateDungeonRunBlock
addon.ApplyRunTypography = ApplyRunTypography
