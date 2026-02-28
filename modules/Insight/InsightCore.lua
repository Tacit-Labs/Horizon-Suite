--[[
    Horizon Suite - Horizon Insight (Insight)
    Cinematic tooltips with class colors, spec/role, faction icons.
    Blizzard APIs: GameTooltip, TooltipDataProcessor, C_ClassColor, Inspect.
    Settings via addon.GetDB/SetDB (profile-backed).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local FONT_PATH       = "Fonts\\FRIZQT__.TTF"
local HEADER_SIZE     = 14
local BODY_SIZE       = 12
local SMALL_SIZE      = 10

local PANEL_BG        = { 0, 0, 0, 0.75 }
local PANEL_BORDER    = { 0.25, 0.25, 0.25, 0.30 }

local FADE_IN_DUR     = 0.15

local DEFAULT_ANCHOR  = "cursor"
local FIXED_POINT     = "BOTTOMRIGHT"
local FIXED_X         = -40
local FIXED_Y         = 120

local INSPECT_THROTTLE = 1.5
local CACHE_TTL        = 300
local CACHE_MAX        = 100

local FACTION_ICONS = {
    Horde    = "|TInterface\\FriendsFrame\\PlusManz-Horde:14:14:0:0|t ",
    Alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:14:14:0:0|t ",
}

local FACTION_COLORS = {
    Alliance = { 0.00, 0.44, 0.87 },   -- alliance blue
    Horde    = { 0.87, 0.17, 0.17 },   -- horde red
}

local SPEC_COLOR      = { 0.65, 0.75, 0.85 }
local MOUNT_COLOR     = { 0.80, 0.65, 1.00 }   -- soft purple for mount name
local MOUNT_SRC_COLOR = { 0.55, 0.55, 0.55 }   -- grey for source text
local ILVL_COLOR      = { 0.60, 0.85, 1.00 }   -- ice blue for item level
local TITLE_COLOR     = { 1.00, 0.82, 0.00 }   -- gold for PvP title
local TRANSMOG_HAVE   = { 0.40, 1.00, 0.55 }   -- green: appearance collected
local TRANSMOG_MISS   = { 0.65, 0.65, 0.65 }   -- grey: not collected

local ROLE_COLORS = {
    TANK    = { 0.30, 0.60, 1.00 },   -- blue
    HEALER  = { 0.30, 1.00, 0.40 },   -- green
    DAMAGER = { 1.00, 0.55, 0.20 },   -- orange
}

local MYTHIC_ICON = "|TInterface\\Icons\\achievement_challengemode_gold:14:14:0:0|t "
local SEPARATOR   = string.rep("-", 22)
local SEP_COLOR   = { 0.18, 0.18, 0.18 }
local SEP_INSET   = 10

-- Returns r, g, b for a Mythic+ score using WoW's tier thresholds.
local function MythicScoreColor(score)
    if score >= 3000 then return 1.00, 0.50, 0.00  -- orange: Mythic Hero+
    elseif score >= 2500 then return 0.85, 0.40, 1.00  -- purple: Mythic
    elseif score >= 2000 then return 0.20, 0.75, 1.00  -- blue: Heroic
    elseif score >= 1500 then return 0.40, 1.00, 0.40  -- green: Normal
    else                       return 0.65, 0.65, 0.65  -- grey: unranked
    end
end

local CINEMATIC_BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- ============================================================================
-- HELPERS
-- ============================================================================

local floor = math.floor

local function FormatNumberWithCommas(n)
    if type(n) ~= "number" then return tostring(n) end
    if BreakUpLargeNumbers then
        return BreakUpLargeNumbers(floor(n))
    end
    local s = tostring(floor(n))
    local i = #s % 3
    if i == 0 then i = 3 end
    return s:sub(1, i) .. s:sub(i + 1):gsub("(%d%d%d)", ",%1")
end

-- Format numbers (4+ digits) in a string with comma separators; used for mount source (e.g. "Vendor: 5000g").
local function FormatNumbersInString(str)
    if not str or str == "" then return str end
    return (str:gsub("%d+", function(numStr)
        local n = tonumber(numStr)
        if n and #numStr >= 4 then
            return FormatNumberWithCommas(n)
        end
        return numStr
    end))
end

local function easeOut(t) return 1 - (1 - t) * (1 - t) end

local function IsEnabled()
    return addon:IsModuleEnabled("insight")
end

local function GetAnchorMode()    return addon.GetDB("insightAnchorMode",    DEFAULT_ANCHOR) end
local function GetFixedPoint()    return addon.GetDB("insightFixedPoint",   FIXED_POINT)    end
local function GetFixedX()        return tonumber(addon.GetDB("insightFixedX", FIXED_X)) or FIXED_X end
local function GetFixedY()        return tonumber(addon.GetDB("insightFixedY", FIXED_Y)) or FIXED_Y end

local function ShowMount()        return addon.GetDB("insightShowMount",        true)  end
local function ShowIlvl()         return addon.GetDB("insightShowIlvl",         true)  end
local function ShowPvPTitle()     return addon.GetDB("insightShowPvPTitle",     true)  end
local function ShowStatusBadges() return addon.GetDB("insightShowStatusBadges", true)  end
local function ShowMythicScore()  return addon.GetDB("insightShowMythicScore",  true)  end
local function ShowTransmog()     return addon.GetDB("insightShowTransmog",     true)  end
local function ShowGuildRank()    return addon.GetDB("insightShowGuildRank",    true)  end
local function ShowHonorLevel()   return addon.GetDB("insightShowHonorLevel",   true)  end

-- Repositions tooltip so its bottom does not clip below the screen edge (cursor mode only).
local function ClampTooltipToScreen()
    if GetAnchorMode() ~= "cursor" then return end
    local bottom = GameTooltip:GetBottom()
    if not bottom or bottom >= 2 then return end
    local left    = GameTooltip:GetLeft() or 0
    local uiScale = UIParent:GetEffectiveScale()
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left / uiScale, 2 / uiScale)
end

-- ============================================================================
-- BACKBONE TOOLTIP STYLING
-- ============================================================================

local tooltipsToStyle = {}
local hookedShow      = {}

local function StripNineSlice(tooltip)
    if tooltip and tooltip.NineSlice then
        tooltip.NineSlice:SetAlpha(0)
    end
end

local function RestoreNineSlice(tooltip)
    if tooltip and tooltip.NineSlice then
        tooltip.NineSlice:SetAlpha(1)
    end
end

local function ApplyBackdrop(tooltip)
    if not tooltip then return end
    if not tooltip.SetBackdrop then
        Mixin(tooltip, BackdropTemplateMixin)
    end
    tooltip:SetBackdrop(CINEMATIC_BACKDROP)
    tooltip:SetBackdropColor(PANEL_BG[1], PANEL_BG[2], PANEL_BG[3], PANEL_BG[4])
    tooltip:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])
end

local function StyleFonts(tooltip)
    if not tooltip then return end
    local name = tooltip:GetName()
    if not name then return end
    local S = function(v) return (addon.ScaledForModule or addon.Scaled or function(x) return x end)(v, "insight") end
    local numLines = tooltip:NumLines()
    for i = 1, numLines do
        local left  = _G[name .. "TextLeft" .. i]
        local right = _G[name .. "TextRight" .. i]
        if left then
            local sz = (i == 1) and S(HEADER_SIZE) or S(BODY_SIZE)
            left:SetFont(FONT_PATH, sz, "OUTLINE")
        end
        if right then
            right:SetFont(FONT_PATH, S(BODY_SIZE), "OUTLINE")
        end
    end
end

local function StyleTooltipFull(tooltip)
    StripNineSlice(tooltip)
    ApplyBackdrop(tooltip)
end

local function HookTooltipOnShow(tooltip)
    tooltip:HookScript("OnShow", function(self)
        if not IsEnabled() then return end
        StripNineSlice(self)
        ApplyBackdrop(self)
    end)
end

local function HookTooltipShowMethod(tooltip)
    if hookedShow[tooltip] then return end
    hookedShow[tooltip] = true
    hooksecurefunc(tooltip, "Show", function(self)
        if not IsEnabled() then return end
        StyleFonts(self)
    end)
end

-- ============================================================================
-- SEPARATOR TEXTURES (defined before animation hooks that reference them)
-- ============================================================================

local SEP_TEXTURE_POOL_SIZE = 4

local function HideSeparatorTextures()
    local textures = Insight.sepTextures
    if textures then
        for i = 1, #textures do
            textures[i]:Hide()
        end
    end
end

local function UpdateSeparatorTextures()
    if not GameTooltip or not GameTooltip:IsShown() then return end
    local textures = Insight.sepTextures
    if not textures then return end

    for i = 1, #textures do
        textures[i]:Hide()
    end

    local sepR = Insight.sepR or SEP_COLOR[1]
    local sepG = Insight.sepG or SEP_COLOR[2]
    local sepB = Insight.sepB or SEP_COLOR[3]

    local name = GameTooltip:GetName()
    if not name then return end

    local numLines = GameTooltip:NumLines()
    local texIdx = 0

    for i = 1, numLines do
        local left = _G[name .. "TextLeft" .. i]
        if left and left:GetText() == SEPARATOR then
            left:SetAlpha(0)
            texIdx = texIdx + 1
            local tex = textures[texIdx]
            if tex then
                tex:SetColorTexture(sepR, sepG, sepB, 1)
                tex:ClearAllPoints()
                tex:SetPoint("LEFT", GameTooltip, "LEFT", SEP_INSET, 0)
                tex:SetPoint("RIGHT", GameTooltip, "RIGHT", -SEP_INSET, 0)
                tex:SetPoint("TOP", left, "TOP", 0, 0)
                tex:SetPoint("BOTTOM", left, "BOTTOM", 0, 0)
                tex:Show()
            end
        end
    end
end

local function ShowAndScheduleSeparators()
    GameTooltip:Show()
    C_Timer.After(0, function()
        if GameTooltip and GameTooltip:IsShown() then
            UpdateSeparatorTextures()
        end
    end)
    -- Some tooltip widths finalize one frame later (inspect/data refresh path).
    C_Timer.After(0.03, function()
        if GameTooltip and GameTooltip:IsShown() then
            UpdateSeparatorTextures()
        end
    end)
end

-- ============================================================================
-- ANIMATION ENGINE
-- ============================================================================

local fadeState      = "idle"
local fadeElapsed    = 0
local fadeTarget     = nil
local suppressFadeIn = false

local animFrame = CreateFrame("Frame")
animFrame:Hide()

animFrame:SetScript("OnUpdate", function(self, elapsed)
    if fadeState == "fadein" and fadeTarget then
        fadeElapsed = fadeElapsed + elapsed
        local progress = math.min(fadeElapsed / FADE_IN_DUR, 1)
        fadeTarget:SetAlpha(easeOut(progress))
        if progress >= 1 then
            fadeState = "visible"
            self:Hide()
        end
    else
        self:Hide()
    end
end)

local function StartFadeIn(tooltip)
    fadeTarget  = tooltip
    fadeElapsed = 0
    fadeState   = "fadein"
    tooltip:SetAlpha(0)
    animFrame:Show()
end

local function HookGameTooltipAnimation()
    GameTooltip:HookScript("OnShow", function(self)
        if not IsEnabled() then return end
        if self.GetUnit and self:GetUnit() then
            C_Timer.After(0, function()
                local fn = addon and addon.Insight and addon.Insight.StripHealthAndPowerText
                if fn then fn() end
            end)
        end
        if suppressFadeIn then
            suppressFadeIn = false
            return
        end
        StartFadeIn(self)
        if Insight.accentBar then Insight.accentBar:Hide() end
    end)
    GameTooltip:HookScript("OnHide", function(self)
        fadeState = "idle"
        animFrame:Hide()
        self:SetAlpha(1)
        if Insight.accentBar then Insight.accentBar:Hide() end
        HideSeparatorTextures()
    end)
end

-- ============================================================================
-- MOUNT SCANNER
-- ============================================================================

local function GetPlayerMountInfo(unit)
    if not C_MountJournal or not C_UnitAuras then return nil end
    local i = 1
    while true do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not auraData then break end
        local spellID = auraData.spellId
        if spellID and type(spellID) == "number" and spellID > 0 then
            local ok, mountID = pcall(C_MountJournal.GetMountFromSpell, spellID)
            if ok and mountID and type(mountID) == "number" and mountID > 0 then
                local mOk, mName, _, mIcon, _, _, sourceType, _, _, _, _, isCollected =
                    pcall(C_MountJournal.GetMountInfoByID, mountID)
                if mOk and mName then
                    local eOk, _, description, source = pcall(C_MountJournal.GetMountInfoExtraByID, mountID)
                    return {
                        name        = mName,
                        icon        = mIcon,
                        source      = eOk and source or nil,
                        sourceType  = sourceType,
                        isCollected = isCollected,
                        description = eOk and description or nil,
                    }
                end
            end
        end
        i = i + 1
    end
    return nil
end

-- ============================================================================
-- UNIT TOOLTIP ENHANCEMENTS
-- ============================================================================

local inspectCache = {}
local lastInspect  = 0

local function PruneCache()
    local now   = GetTime()
    local count = 0
    local oldest, oldestKey
    for guid, entry in pairs(inspectCache) do
        if now - entry.time > CACHE_TTL then
            inspectCache[guid] = nil
        else
            count = count + 1
            if not oldest or entry.time < oldest then
                oldest    = entry.time
                oldestKey = guid
            end
        end
    end
    if count > CACHE_MAX and oldestKey then
        inspectCache[oldestKey] = nil
    end
end

local function CacheInspect(guid, unit)
    local specID = GetInspectSpecialization(unit)
    if not specID or specID <= 0 then return end
    local _, specName, _, specIcon, role = GetSpecializationInfoByID(specID)
    if not specName then return end

    local ilvl
    if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
        local equipped = C_PaperDollInfo.GetInspectItemLevel(unit)
        if equipped and equipped > 0 then
            ilvl = equipped
        end
    end

    inspectCache[guid] = {
        specName = specName,
        specIcon = specIcon,
        role     = role,
        ilvl     = ilvl,
        time     = GetTime(),
    }
end

local function RequestInspect(unit)
    if not UnitIsPlayer(unit) then return end
    if not CanInspect(unit) then return end
    local now = GetTime()
    if now - lastInspect < INSPECT_THROTTLE then return end
    lastInspect = now
    NotifyInspect(unit)
end

local function HideHealthBar()
    local bar = GameTooltip.StatusBar
    if bar then
        bar:Hide()
        bar:HookScript("OnShow", function(self) self:Hide() end)
    end
end

local function ClearStatusBarText()
    for i = 1, 5 do
        local text = _G["GameTooltipStatusBar" .. i .. "Text"]
        if text then text:SetText("") end
        local bar = _G["GameTooltipStatusBar" .. i]
        if bar then bar:Hide() end
    end
end

-- Blizzard adds health/power as "current / max (pct%)" on TextLeft or TextRight.
-- May be wrapped in color codes or have locale-specific formatting.
local function StripHealthAndPowerText()
    ClearStatusBarText()
    local name = GameTooltip:GetName()
    if not name then return end
    local numLines = GameTooltip:NumLines()
    for i = 1, numLines do
        for _, suffix in ipairs({ "Left", "Right" }) do
            local font = _G[name .. "Text" .. suffix .. i]
            if font then
                local ok, rawVal = pcall(font.GetText, font)
                local raw = tostring((ok and rawVal) or "")
                if raw == "" then
                    -- nothing
                else
                    local text = raw:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                    if text:match("%d[%d,]*%s*/%s*%d[%d,]*") then
                        font:SetText("")
                    end
                end
            end
        end
    end
end
Insight.StripHealthAndPowerText = StripHealthAndPowerText

local function ProcessUnitTooltip()
    if not IsEnabled() then return end
    if not GameTooltip or not GameTooltip:IsShown() then return end
    if not UnitExists("mouseover") then return end

    local unit     = "mouseover"
    local isPlayer = UnitIsPlayer(unit)
    local guid     = UnitGUID(unit)

    StripHealthAndPowerText()

    -- Non-player: reaction-coloured name, plain border, no accent bar
    if not isPlayer then
        GameTooltip:SetBackdropBorderColor(PANEL_BORDER[1], PANEL_BORDER[2], PANEL_BORDER[3], PANEL_BORDER[4])
        if Insight.accentBar then Insight.accentBar:Hide() end
        local nameLeft = _G["GameTooltipTextLeft1"]
        if nameLeft then
            local reaction = UnitReaction(unit, "player")
            if reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction] then
                local c = FACTION_BAR_COLORS[reaction]
                nameLeft:SetTextColor(c.r, c.g, c.b)
            end
        end
        StyleFonts(GameTooltip)
        return
    end

    local className, classFile, classColor, guildName, guildRankName
    pcall(function()
        className, classFile = UnitClass(unit)
        classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
        guildName, guildRankName = GetGuildInfo(unit)
    end)
    local sepR = (classColor and classColor.r) or SEP_COLOR[1]
    local sepG = (classColor and classColor.g) or SEP_COLOR[2]
    local sepB = (classColor and classColor.b) or SEP_COLOR[3]
    Insight.sepR, Insight.sepG, Insight.sepB = sepR, sepG, sepB
    local cached = guid and inspectCache[guid]

    -- Self-unit: populate inspect cache directly (no NotifyInspect round-trip)
    -- to avoid the INSPECT_READY → SetUnit tooltip rebuild flicker.
    if not cached and isPlayer and UnitIsUnit(unit, "player") then
        local specIdx = GetSpecialization()
        if specIdx then
            local _, specName, _, specIcon, role = GetSpecializationInfo(specIdx)
            local _, equipped = GetAverageItemLevel()
            if specName then
                inspectCache[guid] = {
                    specName = specName,
                    specIcon = specIcon,
                    role     = role,
                    ilvl     = (equipped and equipped > 0) and equipped or nil,
                    time     = GetTime(),
                }
                cached = inspectCache[guid]
            end
        end
    end

    -- 1. Name line: faction icon + faction colour
    local nameLeft = _G["GameTooltipTextLeft1"]
    if nameLeft then
        local faction = UnitFactionGroup(unit)
        local icon    = FACTION_ICONS[faction] or ""
        local name    = GetUnitName(unit, true) or nameLeft:GetText() or ""
        nameLeft:SetText(icon .. name)
        local fc = FACTION_COLORS[faction]
        if fc then
            nameLeft:SetTextColor(fc[1], fc[2], fc[3])
        elseif classColor then
            nameLeft:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end

    -- 2. Border tint + left accent bar
    if classColor then
        GameTooltip:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.60)
        if Insight.accentBar then
            Insight.accentBar:SetColorTexture(classColor.r, classColor.g, classColor.b, 0.85)
            Insight.accentBar:Show()
        end
    end

    -- 3. Clean up Blizzard lines: strip "(Player)", remove faction text, style class line
    local numLines = GameTooltip:NumLines()
    local classLineStyled = false
    for j = 2, numLines do
        local lineLeft = _G["GameTooltipTextLeft" .. j]
        if lineLeft then
            local text = lineLeft:GetText() or ""

            -- Strip "(Player)" suffix
            if text:find(" %(Player%)") then
                text = text:gsub(" %(Player%)", "")
                lineLeft:SetText(text)
            end

            -- Blank the redundant faction line (already shown as icon on name)
            if text == "Horde" or text == "Alliance" then
                lineLeft:SetText("")

            -- Blank redundant Hero Talent / second spec line (e.g. "Paladin Unique Mode DPS")
            -- Blizzard adds this in TWW; we already show spec + role on the primary class line.
            elseif className and text ~= "" and text:find(className, 1, true) and classLineStyled then
                lineLeft:SetText("")

            -- Guild line: append rank name
            elseif guildName and text == "<" .. guildName .. ">" then
                if ShowGuildRank() and guildRankName and guildRankName ~= "" then
                    lineLeft:SetText(text .. "  |cffaaaaaa" .. guildRankName .. "|r")
                end

            -- Style the primary class line: class colour + spec icon + role badge
            elseif className and text ~= "" and text:find(className, 1, true) then
                classLineStyled = true
                if classColor then
                    lineLeft:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
                local iconPrefix = (cached and cached.specIcon)
                    and ("|T" .. cached.specIcon .. ":14:14:0:0|t ") or ""
                local roleSuffix = ""
                if cached and cached.role then
                    local rc = ROLE_COLORS[cached.role]
                    if rc then
                        local hex = string.format("%02x%02x%02x",
                            math.floor(rc[1] * 255),
                            math.floor(rc[2] * 255),
                            math.floor(rc[3] * 255))
                        local label = cached.role == "TANK" and "Tank"
                            or cached.role == "HEALER" and "Healer" or "DPS"
                        roleSuffix = "  |cff" .. hex .. label .. "|r"
                    end
                end
                lineLeft:SetText(iconPrefix .. text .. roleSuffix)
            end
        end
    end

    -- Separator: identity block → PvP/status block
    GameTooltip:AddLine(SEPARATOR, sepR, sepG, sepB)

    -- 4. PvP title + honor level
    -- All string comparisons on unit-API results are wrapped in pcall because
    -- INSPECT_READY taints the "mouseover" token; comparing tainted strings
    -- causes "attempt to compare a secret string value" errors.
    if ShowPvPTitle() then
        pcall(function()
            local pvpFullName = UnitPVPName(unit)
            local baseName    = UnitName(unit)
            if pvpFullName and baseName and pvpFullName ~= baseName then
                GameTooltip:AddLine(pvpFullName, TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
            end
        end)
    end
    if ShowHonorLevel() then
        pcall(function()
            local honorLevel = UnitHonorLevel(unit)
            if honorLevel and honorLevel > 0 then
                GameTooltip:AddLine("Honor Level " .. FormatNumberWithCommas(honorLevel), 0.85, 0.70, 1.00)
            end
        end)
    end

    -- 5. Status badges (combat/AFK/DND + friend/pvp/group/targeting)
    if ShowStatusBadges() then
        local badges = {}
        pcall(function()
            if UnitAffectingCombat(unit) then badges[#badges + 1] = "|cffff4444[Combat]|r"      end
            if UnitIsAFK(unit)           then badges[#badges + 1] = "|cffffff55[AFK]|r"         end
            if UnitIsDND(unit)           then badges[#badges + 1] = "|cffaaaaaa[DND]|r"         end
            if UnitIsPVP(unit)           then badges[#badges + 1] = "|cffff8c00[PvP]|r"         end
            if UnitInRaid(unit)          then badges[#badges + 1] = "|cff88ddff[Raid]|r"
            elseif UnitInParty(unit)     then badges[#badges + 1] = "|cff88ddff[Party]|r"       end
            if C_FriendList and C_FriendList.IsFriend and guid and C_FriendList.IsFriend(guid) then
                                              badges[#badges + 1] = "|cff55ff55[Friend]|r"      end
            -- "mouseoverTarget" comparison is the primary taint source — guard it separately
            local ok, isTargeting = pcall(UnitIsUnit, "mouseoverTarget", "player")
            if ok and isTargeting then
                                              badges[#badges + 1] = "|cffff4466[Targeting You]|r" end
        end)
        if #badges > 0 then
            GameTooltip:AddLine(table.concat(badges, "  "), 1, 1, 1)
        end
    end

    -- Stats block (M+ score, item level) — prefixed with a separator if non-empty
    local hasStats = false
    local function EnsureStatsSep()
        if not hasStats then
            GameTooltip:AddLine(SEPARATOR, sepR, sepG, sepB)
            hasStats = true
        end
    end

    -- 6. Mythic+ score (no inspect needed)
    if ShowMythicScore() and C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
        local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
        if summary and summary.currentSeasonScore and summary.currentSeasonScore > 0 then
            local score = summary.currentSeasonScore
            local r, g, b = MythicScoreColor(score)
            EnsureStatsSep()
            GameTooltip:AddLine(MYTHIC_ICON .. "M+ Score: " .. FormatNumberWithCommas(score), r, g, b)
        end
    end

    -- 7. Item level (only once inspect cache is available)
    if cached then
        if ShowIlvl() and cached.ilvl then
            EnsureStatsSep()
            GameTooltip:AddLine("Item Level: " .. FormatNumberWithCommas(cached.ilvl), ILVL_COLOR[1], ILVL_COLOR[2], ILVL_COLOR[3])
        end
    elseif not UnitIsUnit(unit, "player") then
        RequestInspect(unit)
    end

    -- 8. Mount block
    if ShowMount() then
        local mountOk, mount = pcall(GetPlayerMountInfo, unit)
        if mountOk and mount and mount.name then
            local iconStr = mount.icon and ("|T" .. mount.icon .. ":14:14:0:0|t ") or ""
            GameTooltip:AddLine(SEPARATOR, sepR, sepG, sepB)
            GameTooltip:AddLine(iconStr .. mount.name, MOUNT_COLOR[1], MOUNT_COLOR[2], MOUNT_COLOR[3])
            if mount.source and mount.source ~= "" then
                GameTooltip:AddLine(FormatNumbersInString(mount.source), MOUNT_SRC_COLOR[1], MOUNT_SRC_COLOR[2], MOUNT_SRC_COLOR[3])
            end
            if mount.isCollected == true then
                GameTooltip:AddLine("|cff55ff55You own this mount|r", 1, 1, 1)
            elseif mount.isCollected == false then
                GameTooltip:AddLine("|cffff5555You don't own this mount|r", 1, 1, 1)
            end
        end
    end

    StyleFonts(GameTooltip)
    suppressFadeIn = true
    GameTooltip:Show()
    StripHealthAndPowerText()
    ClampTooltipToScreen()
end

-- ============================================================================
-- ITEM TOOLTIP ENHANCEMENTS
-- ============================================================================

local function OnItemTooltip(tooltip, data)
    if not IsEnabled() then return end
    if not ShowTransmog() then return end
    if not C_TransmogCollection then return end

    local itemID = data and data.id
    if not itemID then return end

    local hasTransmog = C_TransmogCollection.PlayerHasTransmogByItemInfo(itemID)
    if hasTransmog == nil then return end  -- not a transmoggable item

    if hasTransmog then
        tooltip:AddLine("Appearance: Collected", TRANSMOG_HAVE[1], TRANSMOG_HAVE[2], TRANSMOG_HAVE[3])
    else
        tooltip:AddLine("Appearance: Not collected", TRANSMOG_MISS[1], TRANSMOG_MISS[2], TRANSMOG_MISS[3])
    end
end

local pendingUnit = false

local function OnUnitTooltip(tooltip, data)
    if tooltip ~= GameTooltip or not IsEnabled() then return end
    if not pendingUnit then
        pendingUnit = true
        C_Timer.After(0, function()
            pendingUnit = false
            ProcessUnitTooltip()
        end)
    end
end

-- ============================================================================
-- POSITIONING SYSTEM
-- ============================================================================

local function HookPositioning()
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if not IsEnabled() then return end
        local mode = GetAnchorMode()
        if mode == "fixed" then
            tooltip:ClearAllPoints()
            tooltip:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
        else
            tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        end
    end)
end

-- Draggable anchor frame
local anchorFrame = CreateFrame("Frame", "HorizonSuiteInsightAnchor", UIParent, "BackdropTemplate")
anchorFrame:SetSize(160, 40)
anchorFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", FIXED_X, FIXED_Y)
anchorFrame:SetBackdrop(CINEMATIC_BACKDROP)
anchorFrame:SetBackdropColor(0, 0, 0, 0.85)
anchorFrame:SetBackdropBorderColor(0.50, 0.70, 1.0, 0.60)
anchorFrame:SetMovable(true)
anchorFrame:EnableMouse(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetFrameStrata("DIALOG")
anchorFrame:Hide()

local anchorLabel = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorLabel:SetFont(FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(BODY_SIZE, "insight"), "OUTLINE")
anchorLabel:SetPoint("CENTER")
anchorLabel:SetTextColor(0.50, 0.70, 1.0, 1)
anchorLabel:SetText("TOOLTIP ANCHOR")

local anchorHint = anchorFrame:CreateFontString(nil, "OVERLAY")
anchorHint:SetFont(FONT_PATH, (addon.ScaledForModule or addon.Scaled or function(v) return v end)(SMALL_SIZE, "insight"), "OUTLINE")
anchorHint:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -4)
anchorHint:SetTextColor(0.60, 0.60, 0.60, 1)
anchorHint:SetText("Drag to move · Right-click to confirm")

anchorFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then self:StartMoving() end
end)
anchorFrame:SetScript("OnDragStop", function(self)
    if InCombatLockdown() then return end
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    addon.SetDB("insightFixedPoint", point)
    addon.SetDB("insightFixedX", math.floor(x + 0.5))
    addon.SetDB("insightFixedY", math.floor(y + 0.5))
end)

anchorFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
        self:Hide()
        addon.SetDB("insightAnchorMode", "fixed")
        if addon.HSPrint then addon.HSPrint("Horizon Insight: Position saved. Anchor set to FIXED.") end
    end
end)

local function ShowAnchorFrame()
    if InCombatLockdown() then return end
    anchorFrame:ClearAllPoints()
    anchorFrame:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
    anchorFrame:Show()
    addon.SetDB("insightAnchorMode", "fixed")
    if addon.HSPrint then addon.HSPrint("Horizon Insight: Drag the anchor, then right-click to confirm.") end
end

local function HideAnchorFrame()
    anchorFrame:Hide()
end

-- ============================================================================
-- INIT / DISABLE / APPLY
-- ============================================================================

--- Show the draggable anchor frame to set fixed tooltip position.
function Insight.ShowAnchorFrame()
    ShowAnchorFrame()
end

--- Apply tooltip options (anchor position). Called when profile/options change.
function Insight.ApplyInsightOptions()
    if anchorFrame:IsShown() then
        anchorFrame:ClearAllPoints()
        anchorFrame:SetPoint(GetFixedPoint(), UIParent, GetFixedPoint(), GetFixedX(), GetFixedY())
    end
end

--- Initialize Horizon Insight. Called from InsightModule OnEnable.
function Insight.Init()
    tooltipsToStyle = {
        GameTooltip,
        ItemRefTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        EmbeddedItemTooltip,
    }

    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            StyleTooltipFull(tt)
            HookTooltipOnShow(tt)
            HookTooltipShowMethod(tt)
        end
    end

    -- Class-coloured left accent bar (created once, reused across tooltips)
    if not Insight.accentBar then
        local bar = GameTooltip:CreateTexture(nil, "BORDER")
        bar:SetWidth(3)
        bar:SetPoint("TOPLEFT",    GameTooltip, "TOPLEFT",    0, 0)
        bar:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT", 0, 0)
        bar:SetColorTexture(0.5, 0.5, 0.5, 0.8)
        bar:Hide()
        Insight.accentBar = bar
    end

    -- Separator texture pool for full-width class-coloured lines
    if not Insight.sepTextures or #Insight.sepTextures == 0 then
        Insight.sepTextures = {}
        for i = 1, SEP_TEXTURE_POOL_SIZE do
            local tex = GameTooltip:CreateTexture(nil, "ARTWORK")
            tex:SetColorTexture(0.18, 0.18, 0.18, 1)
            tex:Hide()
            Insight.sepTextures[i] = tex
        end
    end

    HookGameTooltipAnimation()
    HideHealthBar()
    HookPositioning()

    if TooltipDataProcessor and Enum and Enum.TooltipDataType then
        if Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnUnitTooltip)
        end
        if Enum.TooltipDataType.Item then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
        end
    end

    if addon.HSPrint then addon.HSPrint("Horizon Insight loaded. Type /insight or /mtt for options.") end
end

--- Disable Horizon Insight. Restore default tooltip appearance.
function Insight.Disable()
    HideAnchorFrame()
    if Insight.accentBar then Insight.accentBar:Hide() end
    HideSeparatorTextures()
    for _, tt in ipairs(tooltipsToStyle) do
        if tt then
            RestoreNineSlice(tt)
            if tt.SetBackdrop then tt:SetBackdrop(nil) end
        end
    end
end

-- ============================================================================
-- EVENT HANDLER (INSPECT_READY)
-- ============================================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("INSPECT_READY")
eventFrame:SetScript("OnEvent", function(self, event, guid)
    if event == "INSPECT_READY" then
        if not IsEnabled() then return end
        if not guid then return end
        if UnitExists("mouseover") and UnitGUID("mouseover") == guid then
            CacheInspect(guid, "mouseover")
            -- Refresh the tooltip from scratch so Blizzard's lines are rebuilt
            -- before we append ours — prevents every AddLine running twice.
            if GameTooltip:IsShown() then
                suppressFadeIn = true
                GameTooltip:SetUnit("mouseover")
            end
        end
        PruneCache()
    end
end)

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================

local function HandleInsightSlash(msg)
    if not addon:IsModuleEnabled("insight") then
        if addon.HSPrint then addon.HSPrint("Horizon Insight is disabled. Enable it in Horizon Suite options.") end
        return
    end

    local cmd = strtrim(msg or ""):lower()

    if cmd == "anchor" then
        local mode = GetAnchorMode()
        if mode == "cursor" then
            addon.SetDB("insightAnchorMode", "fixed")
            if addon.HSPrint then addon.HSPrint("Horizon Insight: Anchor → FIXED (" .. GetFixedPoint() .. ")") end
        else
            addon.SetDB("insightAnchorMode", "cursor")
            if addon.HSPrint then addon.HSPrint("Horizon Insight: Anchor → CURSOR") end
        end

    elseif cmd == "move" then
        if anchorFrame:IsShown() then
            HideAnchorFrame()
            if addon.HSPrint then addon.HSPrint("Horizon Insight: Anchor hidden. Position saved.") end
        else
            ShowAnchorFrame()
        end

    elseif cmd == "resetpos" then
        addon.SetDB("insightFixedPoint", FIXED_POINT)
        addon.SetDB("insightFixedX", FIXED_X)
        addon.SetDB("insightFixedY", FIXED_Y)
        HideAnchorFrame()
        if addon.HSPrint then addon.HSPrint("Horizon Insight: Fixed position reset to default.") end

    elseif cmd == "test" then
        local testSepR, testSepG, testSepB = 0.77, 0.12, 0.23  -- DK class colour
        Insight.sepR, Insight.sepG, Insight.sepB = testSepR, testSepG, testSepB
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        -- Name: faction icon + class colour (DK = dark red)
        GameTooltip:AddLine((FACTION_ICONS["Alliance"] or "") .. "Testplayer-Stormrage", 0.77, 0.12, 0.23)
        -- Guild + rank
        GameTooltip:AddLine("<Ascension>  |cffaaaaaaOfficer|r", 0.25, 0.78, 0.92)
        -- Level + Race
        GameTooltip:AddLine("Level 80 Human", 1, 0.82, 0)
        -- Class line: spec icon + role badge (Tank = blue)
        GameTooltip:AddLine(
            "|TInterface\\Icons\\spell_deathknight_bloodpresence:14:14:0:0|t Blood Death Knight  |cff4d99ffTank|r",
            0.77, 0.12, 0.23)
        -- Identity / status separator
        GameTooltip:AddLine(SEPARATOR, testSepR, testSepG, testSepB)
        -- PvP title
        GameTooltip:AddLine("Duelist Testplayer", TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])
        -- Honor level
        GameTooltip:AddLine("Honor Level " .. FormatNumberWithCommas(247), 0.85, 0.70, 1.00)
        -- Status badges
        GameTooltip:AddLine("|cffff4444[Combat]|r  |cffff8c00[PvP]|r  |cff88ddff[Party]|r  |cff55ff55[Friend]|r  |cffff4466[Targeting You]|r", 1, 1, 1)
        -- Stats separator
        GameTooltip:AddLine(SEPARATOR, testSepR, testSepG, testSepB)
        -- M+ score
        GameTooltip:AddLine(MYTHIC_ICON .. "M+ Score: " .. FormatNumberWithCommas(2847), MythicScoreColor(2847))
        -- Item level
        GameTooltip:AddLine("Item Level: " .. FormatNumberWithCommas(639), ILVL_COLOR[1], ILVL_COLOR[2], ILVL_COLOR[3])
        -- Mount separator
        GameTooltip:AddLine(SEPARATOR, testSepR, testSepG, testSepB)
        -- Mount
        GameTooltip:AddLine(
            "|TInterface\\Icons\\ability_mount_drake_proto:14:14:0:0|t Reins of the Thundering Cobalt Cloud Serpent",
            MOUNT_COLOR[1], MOUNT_COLOR[2], MOUNT_COLOR[3])
        GameTooltip:AddLine("Drop: Sha of Anger", MOUNT_SRC_COLOR[1], MOUNT_SRC_COLOR[2], MOUNT_SRC_COLOR[3])
        GameTooltip:AddLine("|cffff5555You don't own this mount|r", 1, 1, 1)
        -- Show accent bar + border in DK colour
        GameTooltip:SetBackdropBorderColor(0.77, 0.12, 0.23, 0.60)
        if Insight.accentBar then
            Insight.accentBar:SetColorTexture(0.77, 0.12, 0.23, 0.85)
            Insight.accentBar:Show()
        end
        ShowAndScheduleSeparators()
        if addon.HSPrint then addon.HSPrint("Horizon Insight: Test tooltip shown at cursor.") end

    else
        if addon.HSPrint then
            addon.HSPrint("Horizon Insight")
            addon.HSPrint("  /insight, /h insight     This help")
            addon.HSPrint("  /insight anchor   Toggle cursor / fixed positioning")
            addon.HSPrint("  /insight move     Show draggable anchor to set fixed position")
            addon.HSPrint("  /insight resetpos Reset fixed position to default")
            addon.HSPrint("  /insight test     Show a sample styled tooltip")
        end
    end
end

SLASH_HORIZONSUITEINSIGHT1 = "/insight"
SLASH_HORIZONSUITEINSIGHT2 = "/hsi"
SLASH_HORIZONSUITEINSIGHT3 = "/mtt"
SlashCmdList["HORIZONSUITEINSIGHT"] = HandleInsightSlash

local function HandleInsightDebugSlash(msg)
    local cmd = strtrim(msg or ""):lower()

    if cmd == "" or cmd == "help" then
        if addon.HSPrint then
            addon.HSPrint("Insight debug commands (/h debug insight [cmd]):")
            addon.HSPrint("  status - Print config + cache count")
        end
        return
    end

    if cmd == "status" then
        local cacheCount = 0
        for _ in pairs(inspectCache) do cacheCount = cacheCount + 1 end
        if addon.HSPrint then
            addon.HSPrint("Horizon Insight Status")
            addon.HSPrint("   Enabled : Yes")
            addon.HSPrint("   Anchor  : " .. GetAnchorMode())
            addon.HSPrint("   Cache   : " .. cacheCount .. " inspect entries")
        end
    else
        if addon.HSPrint then
            addon.HSPrint("Unknown debug command. Use /h debug insight for help.")
        end
    end
end

if addon.RegisterSlashHandler then
    addon.RegisterSlashHandler("insight", HandleInsightSlash)
end
if addon.RegisterSlashHandlerDebug then
    addon.RegisterSlashHandlerDebug("insight", HandleInsightDebugSlash)
end

addon.Insight = Insight
