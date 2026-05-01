--[[
    Horizon Suite - Horizon Essence (Core)
    Custom character sheet: 3D model, identity, item level, stat bars, gear grid.
    Replaces the default character frame (C key) when the module is enabled.
]]

local addon = _G.HorizonSuite

addon.Essence = addon.Essence or {}
local Essence = addon.Essence

-- ============================================================================
-- LAYOUT CONSTANTS (unscaled pixels)
-- ============================================================================

local PANEL_W   = 460
local HEADER_H  = 32
local PAD       = 12
local MODEL_W   = 180
local MODEL_H   = 240
local SLOT_SIZE = 50
local SLOT_GAP  = 4
local GEAR_COLS = 8
local GEAR_ROWS = 2
local STAT_BAR_H = 6

-- Right column: starts right of model
local RCOL_X = PAD + MODEL_W + PAD    -- 204
local RCOL_W = PANEL_W - RCOL_X - PAD -- 244

-- Gear section starts below model
local GEAR_AREA_H = GEAR_ROWS * SLOT_SIZE + (GEAR_ROWS - 1) * SLOT_GAP   -- 104
local GEAR_TOP_Y  = HEADER_H + PAD + MODEL_H + PAD   -- distance from frame top to gear divider

local PANEL_H = GEAR_TOP_Y + 1 + 6 + 14 + 6 + GEAR_AREA_H + PAD  -- ~439

-- Gear slot IDs: row 1 = armour, row 2 = accessories + weapons
local GEAR_SLOT_IDS = { 1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17 }

local GEAR_SLOT_NAMES = {
    [1]  = "Head",     [2]  = "Neck",       [3]  = "Shoulder",
    [5]  = "Chest",    [6]  = "Waist",      [7]  = "Legs",
    [8]  = "Feet",     [9]  = "Wrist",      [10] = "Hands",
    [11] = "Ring 1",   [12] = "Ring 2",     [13] = "Trinket 1",
    [14] = "Trinket 2",[15] = "Back",       [16] = "Main Hand",
    [17] = "Off Hand",
}

-- Secondary stat definitions
local SECONDARY_STATS = {
    { label = "Crit",    color = { 1.00, 0.70, 0.20 },
      fn = function()
          local ok, v = pcall(GetCritChance); return ok and (v or 0) or 0
      end },
    { label = "Haste",   color = { 0.30, 0.95, 0.50 },
      fn = function()
          local ok, v = pcall(GetHaste); return ok and (v or 0) or 0
      end },
    { label = "Mastery", color = { 0.75, 0.40, 1.00 },
      fn = function()
          local ok, v = pcall(GetMasteryEffect); return ok and (v or 0) or 0
      end },
    { label = "Vers",    color = { 0.30, 0.80, 1.00 },
      fn = function()
          if not GetCombatRatingBonus then return 0 end
          local ok, v = pcall(GetCombatRatingBonus, CR_VERSATILITY_DAMAGE_DONE or 40)
          return ok and (v or 0) or 0
      end },
}

-- ============================================================================
-- HELPERS
-- ============================================================================

local function IsEnabled()
    return addon:IsModuleEnabled("essence")
end

local function S(n)
    return addon.Scaled and addon.Scaled(n) or n
end

local function GetDB(k, d)
    return addon.GetDB and addon.GetDB(k, d) or d
end

local function SetDB(k, v)
    if addon.SetDB then addon.SetDB(k, v) end
end

local function GetFontPath()
    if addon.GetDB then
        return addon.GetDB("fontPath", addon.FONT_PATH or "Fonts\\FRIZQT__.TTF")
    end
    return addon.FONT_PATH or "Fonts\\FRIZQT__.TTF"
end

local function GetItemQualityColor(quality)
    if not quality or quality < 0 then return 0.22, 0.22, 0.28 end
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        return c.r or 0.22, c.g or 0.22, c.b or 0.28
    end
    return 0.22, 0.22, 0.28
end

-- ============================================================================
-- WIDGET REFERENCES
-- ============================================================================

local frame
local model
local nameText, nameShadow
local titleText
local identityText
local specText
local ilvlBg, ilvlFill, ilvlLabel, ilvlValue
local statBars = {}     -- [i] = { label, pct, bg, fill, color, barW }
local gearSlots = {}    -- [i] = { btn, icon, badge, borderTop, borderBot, borderLeft, borderRight }

-- ============================================================================
-- FRAME CONSTRUCTION
-- ============================================================================

local function CreateGearSlot(parent, index)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(S(SLOT_SIZE), S(SLOT_SIZE))

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0.07, 0.07, 0.10, 0.85)
    bg:SetAllPoints()

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT",    btn, "TOPLEFT",    1, -1)
    icon:SetPoint("BOTTOMRIGHT",btn, "BOTTOMRIGHT",-1,  1)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local badge = btn:CreateFontString(nil, "OVERLAY")
    badge:SetFont(GetFontPath(), S(8), "OUTLINE")
    badge:SetTextColor(1, 1, 1, 1)
    badge:SetJustifyH("RIGHT")
    badge:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
    badge:Hide()

    local bTop, bBot, bLeft, bRight = addon.CreateBorder(btn, { 0.22, 0.22, 0.28, 0.55 }, 1)

    btn:SetScript("OnEnter", function(self)
        local slotID = GEAR_SLOT_IDS[index]
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetInventoryItem("player", slotID)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return {
        btn        = btn,
        icon       = icon,
        badge      = badge,
        borderTop  = bTop,
        borderBot  = bBot,
        borderLeft = bLeft,
        borderRight= bRight,
    }
end

local function CreateStatRow(parent, statDef, anchorFrame, yOff)
    local barW = S(RCOL_W)

    local lbl = parent:CreateFontString(nil, "OVERLAY")
    lbl:SetFont(GetFontPath(), S(10), "OUTLINE")
    lbl:SetTextColor(0.72, 0.72, 0.80, 1)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(statDef.label)
    lbl:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, yOff)
    lbl:SetWidth(barW * 0.55)

    local pct = parent:CreateFontString(nil, "OVERLAY")
    pct:SetFont(GetFontPath(), S(10), "OUTLINE")
    pct:SetJustifyH("RIGHT")
    pct:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT", 0, yOff)
    pct:SetWidth(barW * 0.45)

    local bg = parent:CreateTexture(nil, "BACKGROUND", nil, 2)
    bg:SetColorTexture(0.14, 0.14, 0.18, 0.70)
    bg:SetSize(barW, S(STAT_BAR_H))
    bg:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -S(2))

    local fill = parent:CreateTexture(nil, "BACKGROUND", nil, 3)
    fill:SetColorTexture(statDef.color[1], statDef.color[2], statDef.color[3], 0.82)
    fill:SetHeight(S(STAT_BAR_H))
    fill:SetWidth(S(2))  -- placeholder until refresh
    fill:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)

    return { label = lbl, pct = pct, bg = bg, fill = fill,
             color = statDef.color, barW = barW }
end

local function BuildFrame()
    -- ── Main panel ────────────────────────────────────────────────────────────
    frame = CreateFrame("Frame", "HorizonSuiteEssenceFrame", UIParent, "BackdropTemplate")
    frame:SetSize(S(PANEL_W), S(PANEL_H))
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1,
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:SetBackdropColor(0.06, 0.06, 0.09, 0.94)
    frame:SetBackdropBorderColor(0.28, 0.30, 0.38, 0.65)
    frame:Hide()

    -- ── Header bar ────────────────────────────────────────────────────────────
    local headerBg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    headerBg:SetColorTexture(0.10, 0.10, 0.16, 0.85)
    headerBg:SetPoint("TOPLEFT",  frame, "TOPLEFT",  0, 0)
    headerBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    headerBg:SetHeight(S(HEADER_H))

    local headerDiv = frame:CreateTexture(nil, "ARTWORK")
    headerDiv:SetColorTexture(0.28, 0.30, 0.38, 0.50)
    headerDiv:SetHeight(1)
    headerDiv:SetPoint("BOTTOMLEFT",  headerBg, "BOTTOMLEFT",  0, 0)
    headerDiv:SetPoint("BOTTOMRIGHT", headerBg, "BOTTOMRIGHT", 0, 0)

    local headerLabel = frame:CreateFontString(nil, "OVERLAY")
    headerLabel:SetFont(GetFontPath(), S(10), "OUTLINE")
    headerLabel:SetTextColor(0.50, 0.55, 0.72, 1)
    headerLabel:SetText("HORIZON ESSENCE")
    headerLabel:SetPoint("LEFT", frame, "TOPLEFT", S(PAD), -S(HEADER_H / 2))

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(S(22), S(22))
    closeBtn:SetPoint("RIGHT", frame, "TOPRIGHT", -S(8), -S(HEADER_H / 2))
    local closeTex = closeBtn:CreateFontString(nil, "OVERLAY")
    closeTex:SetFont(GetFontPath(), S(16), "OUTLINE")
    closeTex:SetTextColor(0.50, 0.50, 0.62, 1)
    closeTex:SetText("×")
    closeTex:SetAllPoints()
    closeTex:SetJustifyH("CENTER")
    closeBtn:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        Essence._suppressCharHook = true
        Essence.Hide()
        CharacterFrame:Show()
        C_Timer.After(0, function() Essence._suppressCharHook = nil end)
    end)
    closeBtn:SetScript("OnEnter", function() closeTex:SetTextColor(1.0, 0.35, 0.35, 1) end)
    closeBtn:SetScript("OnLeave", function() closeTex:SetTextColor(0.50, 0.50, 0.62, 1) end)

    -- Header drag
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        if GetDB("essenceLockPosition", false) then return end
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        if InCombatLockdown() then return end
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        SetDB("essencePoint", point)
        SetDB("essenceX", math.floor(x + 0.5))
        SetDB("essenceY", math.floor(y + 0.5))
    end)

    -- ── PlayerModel ───────────────────────────────────────────────────────────
    model = CreateFrame("PlayerModel", "HSEssenceModel", frame)
    model:SetSize(S(MODEL_W), S(MODEL_H))
    model:SetPoint("TOPLEFT", frame, "TOPLEFT", S(PAD), -S(HEADER_H + PAD))
    model:SetFrameLevel(frame:GetFrameLevel() + 1)
    addon.CreateBorder(model, { 0.22, 0.24, 0.32, 0.50 }, 1)

    -- ── Identity block ────────────────────────────────────────────────────────
    local rTop = -S(HEADER_H + PAD)

    nameText, nameShadow = addon.CreateShadowedText(frame, nil, "OVERLAY", "BORDER")
    local nameFont = GetFontPath()
    nameText:SetFont(nameFont, S(15), "OUTLINE")
    nameShadow:SetFont(nameFont, S(15), "OUTLINE")
    nameText:SetTextColor(1, 1, 1, 1)
    nameText:SetJustifyH("LEFT")
    nameText:SetWidth(S(RCOL_W))
    nameText:SetPoint("TOPLEFT", frame, "TOPLEFT", S(RCOL_X), rTop)

    titleText = frame:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(GetFontPath(), S(10), "OUTLINE")
    titleText:SetTextColor(1.00, 0.82, 0.20, 1)
    titleText:SetJustifyH("LEFT")
    titleText:SetWidth(S(RCOL_W))
    titleText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -S(3))
    titleText:Hide()

    identityText = frame:CreateFontString(nil, "OVERLAY")
    identityText:SetFont(GetFontPath(), S(10), "OUTLINE")
    identityText:SetTextColor(0.68, 0.68, 0.76, 1)
    identityText:SetJustifyH("LEFT")
    identityText:SetWidth(S(RCOL_W))
    identityText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -S(2))

    specText = frame:CreateFontString(nil, "OVERLAY")
    specText:SetFont(GetFontPath(), S(10), "OUTLINE")
    specText:SetTextColor(0.72, 0.72, 0.80, 1)
    specText:SetJustifyH("LEFT")
    specText:SetWidth(S(RCOL_W))
    specText:SetPoint("TOPLEFT", identityText, "BOTTOMLEFT", 0, -S(2))

    -- Divider 1 (below identity)
    local div1 = frame:CreateTexture(nil, "ARTWORK")
    div1:SetColorTexture(0.28, 0.30, 0.38, 0.45)
    div1:SetHeight(1)
    div1:SetWidth(S(RCOL_W))
    div1:SetPoint("TOPLEFT", specText, "BOTTOMLEFT", 0, -S(8))

    -- ── Item Level bar ────────────────────────────────────────────────────────
    ilvlLabel = frame:CreateFontString(nil, "OVERLAY")
    ilvlLabel:SetFont(GetFontPath(), S(10), "OUTLINE")
    ilvlLabel:SetTextColor(0.52, 0.58, 0.72, 1)
    ilvlLabel:SetText("Item Level")
    ilvlLabel:SetJustifyH("LEFT")
    ilvlLabel:SetPoint("TOPLEFT", div1, "BOTTOMLEFT", 0, -S(7))

    ilvlValue = frame:CreateFontString(nil, "OVERLAY")
    ilvlValue:SetFont(GetFontPath(), S(10), "OUTLINE")
    ilvlValue:SetTextColor(0.90, 0.92, 1.00, 1)
    ilvlValue:SetJustifyH("RIGHT")
    ilvlValue:SetWidth(S(RCOL_W))
    ilvlValue:SetPoint("TOPRIGHT", div1, "BOTTOMRIGHT", 0, -S(7))

    ilvlBg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    ilvlBg:SetColorTexture(0.12, 0.12, 0.16, 0.70)
    ilvlBg:SetSize(S(RCOL_W), S(8))
    ilvlBg:SetPoint("TOPLEFT", ilvlLabel, "BOTTOMLEFT", 0, -S(4))

    ilvlFill = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
    ilvlFill:SetColorTexture(0.40, 0.65, 1.00, 0.78)
    ilvlFill:SetHeight(S(8))
    ilvlFill:SetWidth(S(2))
    ilvlFill:SetPoint("TOPLEFT", ilvlBg, "TOPLEFT", 0, 0)

    -- Divider 2 (below ilvl)
    local div2 = frame:CreateTexture(nil, "ARTWORK")
    div2:SetColorTexture(0.28, 0.30, 0.38, 0.45)
    div2:SetHeight(1)
    div2:SetWidth(S(RCOL_W))
    div2:SetPoint("TOPLEFT", ilvlBg, "BOTTOMLEFT", 0, -S(8))

    -- ── Secondary stat bars ───────────────────────────────────────────────────
    local statAnchor = div2
    for i, statDef in ipairs(SECONDARY_STATS) do
        local yOff = (i == 1) and -S(8) or -S(4)
        local bar = CreateStatRow(frame, statDef, statAnchor, yOff)
        statBars[i] = bar
        statAnchor = bar.bg
    end

    -- ── Gear section ──────────────────────────────────────────────────────────
    local gearDiv = frame:CreateTexture(nil, "ARTWORK")
    gearDiv:SetColorTexture(0.28, 0.30, 0.38, 0.45)
    gearDiv:SetHeight(1)
    gearDiv:SetPoint("TOPLEFT",  frame, "TOPLEFT",  S(PAD), -S(GEAR_TOP_Y))
    gearDiv:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -S(PAD), -S(GEAR_TOP_Y))

    local gearLabel = frame:CreateFontString(nil, "OVERLAY")
    gearLabel:SetFont(GetFontPath(), S(9), "OUTLINE")
    gearLabel:SetTextColor(0.45, 0.48, 0.60, 1)
    gearLabel:SetText("GEAR")
    gearLabel:SetPoint("TOPLEFT", gearDiv, "BOTTOMLEFT", 0, -S(4))

    -- Center the gear grid horizontally in the panel
    local totalGearW = GEAR_COLS * SLOT_SIZE + (GEAR_COLS - 1) * SLOT_GAP
    local gearOffX   = S(PAD) + (S(PANEL_W - PAD * 2) - S(totalGearW)) / 2
    local gearOffY   = -S(GEAR_TOP_Y + 1 + 4 + 14 + 6)   -- below divider + label + spacing

    for i = 1, 16 do
        local col = (i - 1) % GEAR_COLS
        local row = math.floor((i - 1) / GEAR_COLS)
        local slot = CreateGearSlot(frame, i)
        slot.btn:SetPoint("TOPLEFT", frame, "TOPLEFT",
            gearOffX + col * (S(SLOT_SIZE) + S(SLOT_GAP)),
            gearOffY - row * (S(SLOT_SIZE) + S(SLOT_GAP)))
        gearSlots[i] = slot
    end
end

-- ============================================================================
-- DATA REFRESH
-- ============================================================================

local function GetSlotIlvl(slotID)
    local link = GetInventoryItemLink("player", slotID)
    if not link then return nil end
    local ok, _, _, ilvl = pcall(GetDetailedItemLevelInfo, link)
    return ok and ilvl and ilvl > 0 and ilvl or nil
end

function Essence.Refresh()
    if not frame or not frame:IsShown() then return end

    local fp = GetFontPath()

    -- ── Name ──────────────────────────────────────────────────────────────────
    local name = UnitName("player") or "Unknown"
    local _, classFile = UnitClass("player")
    local classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
    if classColor and addon.GetModuleClassColor and addon.GetModuleClassColor("essence") then
        nameText:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
    else
        nameText:SetTextColor(1, 1, 1, 1)
    end
    nameText:SetText(name)
    nameShadow:SetText(name)

    -- ── PvP Title ─────────────────────────────────────────────────────────────
    if GetDB("essenceShowTitle", true) then
        local pvpName = UnitPVPName and UnitPVPName("player")
        if pvpName and pvpName ~= name then
            -- pvpName is "Title CharacterName" — strip the trailing character name
            local titlePrefix = pvpName:sub(1, #pvpName - #name):match("^%s*(.-)%s*$")
            if titlePrefix and titlePrefix ~= "" then
                titleText:SetText(titlePrefix)
                titleText:Show()
            else
                titleText:Hide()
            end
        else
            titleText:Hide()
        end
    else
        titleText:Hide()
    end

    identityText:ClearAllPoints()
    if titleText:IsShown() then
        identityText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -S(2))
    else
        identityText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -S(4))
    end

    -- ── Identity line ─────────────────────────────────────────────────────────
    local level     = UnitLevel("player") or "?"
    local raceName  = UnitRace and UnitRace("player") or "?"
    local className = select(1, UnitClass("player")) or "?"
    identityText:SetText(level .. "  ·  " .. (raceName or "?") .. "  ·  " .. (className or "?"))

    -- ── Spec + Role ───────────────────────────────────────────────────────────
    local specIdx = GetSpecialization and GetSpecialization()
    if specIdx then
        local _, specName, _, _, role = GetSpecializationInfo(specIdx)
        -- Role icons from the LFG portrait roles atlas (64×64 sheet)
        local roleIcon = ""
        if role == "TANK" then
            roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:13:13:0:0:64:64:0:19:22:41|t "
        elseif role == "HEALER" then
            roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:13:13:0:0:64:64:20:39:1:20|t "
        else
            roleIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:13:13:0:0:64:64:20:39:22:41|t "
        end
        specText:SetText(roleIcon .. (specName or ""))
    else
        specText:SetText("")
    end

    -- ── Item Level ────────────────────────────────────────────────────────────
    local overall, equipped = GetAverageItemLevel()
    overall  = math.floor(overall or 0)
    equipped = math.floor(equipped or 0)
    ilvlValue:SetText(equipped .. " / " .. overall)

    local maxIlvl  = math.max(1, overall + 15)
    local ilvlFrac = math.min(1, equipped / maxIlvl)
    local ilvlBarW = S(RCOL_W)
    ilvlFill:SetWidth(math.max(S(2), ilvlBarW * ilvlFrac))

    if equipped >= overall then
        ilvlFill:SetColorTexture(0.30, 0.90, 0.40, 0.80)
    elseif equipped >= overall - 5 then
        ilvlFill:SetColorTexture(0.92, 0.78, 0.20, 0.80)
    else
        ilvlFill:SetColorTexture(0.40, 0.65, 1.00, 0.78)
    end

    -- ── Secondary Stats ───────────────────────────────────────────────────────
    local showStats = GetDB("essenceShowStatBars", true)
    local statCap   = tonumber(GetDB("essenceStatCap", 50)) or 50

    for i, bar in ipairs(statBars) do
        if showStats then
            local pct  = SECONDARY_STATS[i].fn()
            local frac = math.min(1, pct / statCap)
            local c    = bar.color
            bar.label:Show(); bar.pct:Show(); bar.bg:Show(); bar.fill:Show()
            bar.pct:SetText(("%.1f%%"):format(pct))
            bar.pct:SetTextColor(c[1], c[2], c[3], 1)
            bar.fill:SetColorTexture(c[1], c[2], c[3], 0.82)
            bar.fill:SetWidth(math.max(S(2), bar.barW * frac))
        else
            bar.label:Hide(); bar.pct:Hide(); bar.bg:Hide(); bar.fill:Hide()
        end
    end

    -- ── Gear Slots ────────────────────────────────────────────────────────────
    local showBadge = GetDB("essenceShowIlvlBadge", true)

    for i, slot in ipairs(gearSlots) do
        local slotID  = GEAR_SLOT_IDS[i]
        local iconTex = GetInventoryItemTexture("player", slotID)
        local quality = GetInventoryItemQuality and GetInventoryItemQuality("player", slotID)
        local r, g, b = GetItemQualityColor(quality)

        if iconTex then
            slot.icon:SetTexture(iconTex)
            slot.icon:Show()
            -- Quality-coloured border
            for _, tex in ipairs({ slot.borderTop, slot.borderBot, slot.borderLeft, slot.borderRight }) do
                if tex then tex:SetColorTexture(r, g, b, 0.78) end
            end
        else
            slot.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
            slot.icon:Show()
            for _, tex in ipairs({ slot.borderTop, slot.borderBot, slot.borderLeft, slot.borderRight }) do
                if tex then tex:SetColorTexture(0.20, 0.20, 0.26, 0.40) end
            end
        end

        if showBadge and iconTex then
            local ilvl = GetSlotIlvl(slotID)
            if ilvl then
                slot.badge:SetText(ilvl)
                slot.badge:Show()
            else
                slot.badge:Hide()
            end
        else
            slot.badge:Hide()
        end
    end
end

-- ============================================================================
-- SHOW / HIDE / TOGGLE
-- ============================================================================

function Essence.Show()
    if not frame then return end
    frame:Show()
    if model and UnitExists("player") then
        pcall(model.SetUnit, model, "player")
    end
    Essence.Refresh()
end

function Essence.Hide()
    if frame then frame:Hide() end
end

function Essence.Toggle()
    if not frame then return end
    if frame:IsShown() then Essence.Hide() else Essence.Show() end
end

-- ============================================================================
-- POSITION
-- ============================================================================

function Essence.ApplyPosition(reset)
    if not frame then return end
    frame:ClearAllPoints()
    if reset then
        SetDB("essencePoint", "CENTER")
        SetDB("essenceX", 0)
        SetDB("essenceY", 0)
    end
    local point = GetDB("essencePoint", "CENTER")
    local x = tonumber(GetDB("essenceX", 0)) or 0
    local y = tonumber(GetDB("essenceY", 0)) or 0
    frame:SetPoint(point, UIParent, point, x, y)
end

-- ============================================================================
-- APPLY OPTIONS
-- ============================================================================

function Essence.ApplyEssenceOptions()
    if not frame then return end
    local sc = tonumber(GetDB("essenceScale", 1.0)) or 1.0
    frame:SetScale(sc)
    if frame:IsShown() then Essence.Refresh() end
end

-- ============================================================================
-- C KEY INTERCEPT (taint-safe via HookScript)
-- ============================================================================

local function InstallCharFrameHook()
    if Essence._charFrameHooked then return end
    Essence._charFrameHooked = true
    CharacterFrame:HookScript("OnShow", function()
        if not IsEnabled() then return end
        if InCombatLockdown() then return end
        if Essence._suppressCharHook then return end
        CharacterFrame:Hide()
        Essence.Show()
    end)
end

-- ============================================================================
-- EVENTS
-- ============================================================================

local eventFrame = CreateFrame("Frame")

local function RegisterEssenceEvents()
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if not IsEnabled() then return end
    if event == "UNIT_INVENTORY_CHANGED" then
        if select(1, ...) ~= "player" then return end
    end
    if event == "PLAYER_ENTERING_WORLD" then
        Essence.ApplyPosition()
        if frame and frame:IsShown() and model and UnitExists("player") then
            pcall(model.SetUnit, model, "player")
        end
    end
    if frame and frame:IsShown() then
        Essence.Refresh()
    end
end)

-- ============================================================================
-- INIT / DISABLE
-- ============================================================================

function Essence.Init()
    if Essence._initialized then
        -- Re-enable after disable: re-register events and re-apply position
        RegisterEssenceEvents()
        InstallCharFrameHook()
        Essence.ApplyPosition()
        return
    end
    Essence._initialized = true

    BuildFrame()
    RegisterEssenceEvents()
    InstallCharFrameHook()
    Essence.ApplyPosition()
end

function Essence.Disable()
    if frame then frame:Hide() end
    eventFrame:UnregisterAllEvents()
end

addon.Essence = Essence
