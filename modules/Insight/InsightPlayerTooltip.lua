--[[
    Horizon Suite - Horizon Insight (Player Tooltip)
    Player-specific tooltip enrichment: class/spec/role, PvP title, honor, badges, stats, mount block, inspect.
]]

local addon = _G.HorizonSuite

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local INSPECT_THROTTLE      = 1.5
local ACHIEVEMENT_THROTTLE  = 2.0
local CACHE_TTL             = 300
local CACHE_MAX             = 100

local MOUNT_READY_TEX  = "Interface\\RaidFrame\\ReadyCheck-Ready"
local MOUNT_NOTREADY_TEX = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local MOUNT_OWN_ICON_BASE = 14

local RACE_ICON_PATH_PREFIX = "Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\RaceIcons\\Charactercreate-races_"

local RACE_ICON_FILE_BASE = {
    BloodElf            = "bloodelf",
    DarkIronDwarf       = "darkirondwarf",
    Draenei             = "draenei",
    Dracthyr            = "dracthyr",
    Dwarf               = "dwarf",
    EarthenDwarf        = "earthen",
    Gnome               = "gnome",
    Goblin              = "goblin",
    HighmountainTauren  = "highmountain",
    Human               = "human",
    KulTiran            = "kultiranhuman",
    LightforgedDraenei  = "lightforged",
    MagharOrc           = "maghar",
    Mechagnome          = "mechagnome",
    Nightborne          = "nightborne",
    NightElf            = "nightelf",
    Orc                 = "orc",
    Pandaren            = "panda",
    Scourge             = "undead",
    Tauren              = "tauren",
    Troll               = "troll",
    VoidElf             = "voidelf",
    Vulpera             = "vulpera",
    Worgen              = "worgen",
    ZandalariTroll      = "ZandalariTroll",
    Haranir             = "haranir",
    Harronir            = "haranir",
    Harranir            = "haranir",
}

local RACE_ICON_GENDER_SUFFIX = {
    Worgen = {
        male = "male2",
        female = "female2",
    },
}

local DRACTHYR_VISAGE_AURA_SPELL_IDS = {
    372014, -- Visage: visible health regeneration aura while in visage form.
    382916, -- Visage Form: quest/form helper aura on some clients.
}

-- Wrap a plain name in either a per-character gradient (class-colour mode with
-- the gradient toggle on) or a single flat |cff colour span. Shared by the
-- live tooltip and the dashboard preview.
local function FormatNameSpan(plain, r, g, b, useGradient)
    if useGradient then
        return Insight.BuildNameGradient(plain, r, g, b)
    end
    local hex = string.format("%02x%02x%02x",
        math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
    return "|cff" .. hex .. plain .. "|r"
end

local function ShiftModifierActive()
    return IsShiftKeyDown and IsShiftKeyDown()
end

local function GetInsightDisplayMode(modeKey, legacyKey)
    local mode = addon.GetDB(modeKey, nil)
    if mode == "force" or mode == "modifier" or mode == "hide" then return mode end
    return addon.GetDB(legacyKey, false) and "force" or "hide"
end

local function ShowMount()            return addon.GetDB("insightShowMount",            true)  end
local function ShowSpecRole()         return addon.GetDB("insightShowSpecRole",          true)  end
local function ShowCharacterTitle()   return addon.GetDB("insightShowCharacterTitle",   true)  end
local function ShowStatusBadges()     return addon.GetDB("insightShowStatusBadges",     true)  end
local function ShowStatusBadgeCombat()    return addon.GetDB("insightStatusBadgeCombat",    true) end
local function ShowStatusBadgeAFK()       return addon.GetDB("insightStatusBadgeAFK",        true) end
local function ShowStatusBadgeDND()       return addon.GetDB("insightStatusBadgeDND",        true) end
local function ShowStatusBadgePVP()       return addon.GetDB("insightStatusBadgePVP",        true) end
local function ShowStatusBadgeGroup()     return addon.GetDB("insightStatusBadgeGroup",      true) end
local function ShowStatusBadgeFriend()    return addon.GetDB("insightStatusBadgeFriend",     true) end
local function ShowStatusBadgeTargeting() return addon.GetDB("insightStatusBadgeTargeting",  true) end
local function ShowMythicScore()
    local mode = GetInsightDisplayMode("insightMythicScoreMode", "insightShowMythicScore")
    if mode == "hide" then return false end
    return mode == "force" or (mode == "modifier" and (Insight.previewRendering or ShiftModifierActive()))
end
local function ShowGuildRank()    return addon.GetDB("insightShowGuildRank",    true)  end
local function ShowIcons()        return addon.GetDB("insightShowIcons",        true)  end
local function ShowRaceIcons()    return ShowIcons() and addon.GetDB("insightRaceIcons", true) end
local function ShowRatingsIcons() return addon.GetDB("insightRatingsIcons",     true)  end

local function ShowTRP3RPName()      return addon.GetDB("insightTRP3RPName",      true) end
local function ShowTRP3CustomColor() return addon.GetDB("insightTRP3CustomColor", true) end
local function ShowTRP3Pronouns()    return addon.GetDB("insightTRP3Pronouns",    true) end
local function ShowTRP3ICStatus()    return addon.GetDB("insightTRP3ICStatus",    true) end
local function ShowTRP3ICStatusIcon() return addon.GetDB("insightTRP3ICStatusIcon", false) end
local function ShowTRP3RaceClass()   return addon.GetDB("insightTRP3RaceClass",   true) end
local function ShowTRP3Guild()       return addon.GetDB("insightTRP3Guild",       true) end
local function ShowTRP3Currently()   return addon.GetDB("insightTRP3Currently",   true) end
local function ShowTRP3Icon()        return addon.GetDB("insightTRP3Icon",        true) end
local function ShowTRP3()           return addon.GetDB("insightTRP3Enabled",     true) end

local function SpecIconMarkup(specIcon, size)
    if not specIcon then return "" end
    size = tonumber(size) or 14
    -- Crop Blizzard spec icons slightly so their baked pale edge blends into the tooltip.
    return "|T" .. specIcon .. ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t "
end

local function GetSpellNameByID(spellID)
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, spellID)
        if ok and name then return name end
    end
    if GetSpellInfo then
        local ok, name = pcall(GetSpellInfo, spellID)
        if ok and name then return name end
    end
    return nil
end

local function UnitHasAuraBySpellID(unit, spellID)
    if not unit or not spellID then return false end
    if UnitIsUnit and UnitIsUnit(unit, "player") and C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellID)
        if ok and aura then return true end
    end
    if C_UnitAuras and C_UnitAuras.GetUnitAuraBySpellID then
        local ok, aura = pcall(C_UnitAuras.GetUnitAuraBySpellID, unit, spellID)
        if ok and aura then return true end
    end
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for i = 1, 40 do
            local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
            if not ok or not aura then break end
            if aura.spellId == spellID then return true end
        end
    end
    if UnitAura then
        for i = 1, 40 do
            local ok, name, _, _, _, _, _, _, _, spellId = pcall(UnitAura, unit, i, "HELPFUL")
            if not ok or not name then break end
            if spellId == spellID then return true end
        end
    end
    if AuraUtil and AuraUtil.FindAuraByName then
        local spellName = GetSpellNameByID(spellID)
        if spellName then
            local ok, auraName = pcall(AuraUtil.FindAuraByName, spellName, unit, "HELPFUL")
            if ok and auraName then return true end
        end
    end
    return false
end

local function IsDracthyrInVisageForm(unit)
    for _, spellID in ipairs(DRACTHYR_VISAGE_AURA_SPELL_IDS) do
        if UnitHasAuraBySpellID(unit, spellID) then
            return true
        end
    end
    return false
end

local function RaceIconMarkup(unit, size)
    if not ShowRaceIcons() then return "" end
    local raceName, raceFile, sex
    pcall(function()
        local localizedName, fileName = UnitRace(unit)
        raceName = localizedName
        raceFile = fileName
        sex = UnitSex(unit)
    end)
    local fileBase = raceFile and RACE_ICON_FILE_BASE[raceFile]
    if not fileBase then
        local raceKey = tostring(raceFile or raceName or ""):lower()
        if raceKey:find("haranir", 1, true) or raceKey:find("harronir", 1, true) or raceKey:find("harranir", 1, true) then
            fileBase = "haranir"
        end
    end
    if not fileBase then return "" end
    if raceFile == "Dracthyr" and IsDracthyrInVisageForm(unit) then
        fileBase = "dracthyr-visage"
    end
    size = tonumber(size) or 14
    local gender = (sex == 3) and "female" or "male"
    local suffixes = RACE_ICON_GENDER_SUFFIX[raceFile]
    local genderSuffix = (suffixes and suffixes[gender]) or gender
    return "|T" .. RACE_ICON_PATH_PREFIX .. fileBase .. "-" .. genderSuffix .. ".tga:" .. size .. ":" .. size .. ":0:0|t "
end

local function ShowIlvl()
    local mode = GetInsightDisplayMode("insightItemLevelMode", "insightShowIlvl")
    if mode == "hide" then return false end
    return mode == "force" or (mode == "modifier" and (Insight.previewRendering or ShiftModifierActive()))
end

local function ShowHonorLevel()
    local mode = GetInsightDisplayMode("insightHonorLevelMode", "insightShowHonorLevel")
    if mode == "hide" then return false end
    return mode == "force" or (mode == "modifier" and (Insight.previewRendering or ShiftModifierActive()))
end

local function ShowAchievementPoints()
    local mode = GetInsightDisplayMode("insightAchievementPointsMode", "insightShowAchievementPoints")
    if mode == "hide" then return false end
    return mode == "force" or (mode == "modifier" and (Insight.previewRendering or ShiftModifierActive()))
end

-- ============================================================================
-- INSPECT CACHE
-- ============================================================================

local inspectCache = {}
Insight.inspectCache = inspectCache

local lastInspect = 0

-- ============================================================================
-- ACHIEVEMENT CACHE
-- ============================================================================

local achievementCache = {}
Insight.achievementCache = achievementCache

local lastAchievementRequest = 0

function Insight.PruneInspectCache()
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

function Insight.PruneAchievementCache()
    local now   = GetTime()
    local count = 0
    local oldest, oldestKey
    for guid, entry in pairs(achievementCache) do
        if now - entry.time > CACHE_TTL then
            achievementCache[guid] = nil
        else
            count = count + 1
            if not oldest or entry.time < oldest then
                oldest    = entry.time
                oldestKey = guid
            end
        end
    end
    if count > CACHE_MAX and oldestKey then
        achievementCache[oldestKey] = nil
    end
end

-- Midnight: UnitGUID and cache keys must not be truth-tested or compared outside pcall (secret string).
local function GetInspectCachedForUnit(unit)
    local cached = nil
    pcall(function()
        local g = UnitGUID(unit)
        cached = inspectCache[g]
    end)
    return cached
end

-- Populate inspect cache for the player unit; all GUID/cache access stays inside pcall.
local function TrySeedSelfInspectCache(unit)
    pcall(function()
        local g = UnitGUID(unit)
        local specID = PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID()
        if not specID or specID <= 0 then return end
        local _, specName, _, specIcon, role = GetSpecializationInfoByID(specID)
        local _, equipped = GetAverageItemLevel()
        if not specName then return end
        inspectCache[g] = {
            specName = specName,
            specIcon = specIcon,
            role     = role,
            ilvl     = (equipped and equipped > 0) and equipped or nil,
            time     = GetTime(),
        }
    end)
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
    local allowInspect = false
    pcall(function()
        if not UnitIsPlayer(unit) then return end
        if not CanInspect(unit) then return end
        allowInspect = true
    end)
    if not allowInspect then return end
    local now = GetTime()
    if now - lastInspect < INSPECT_THROTTLE then return end
    lastInspect = now
    NotifyInspect(unit)
end

local function RequestAchievementComparison(unit)
    local allowRequest = false
    pcall(function()
        if not UnitIsPlayer(unit) then return end
        if UnitIsUnit(unit, "player") then return end
        allowRequest = true
    end)
    if not allowRequest then return end
    local now = GetTime()
    if now - lastAchievementRequest < ACHIEVEMENT_THROTTLE then return end
    lastAchievementRequest = now
    if SetAchievementComparisonUnit then
        if ClearAchievementComparisonUnit then
            pcall(ClearAchievementComparisonUnit)
        end
        pcall(SetAchievementComparisonUnit, unit)
    end
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

-- Mount collection: icons append to the name line; full text stays on its own line.
local function MountOwnershipIconSize()
    local S = addon.ScaledForModule or addon.Scaled or function(x) return x end
    return math.max(8, math.floor(S(MOUNT_OWN_ICON_BASE, "insight")))
end

--- @return string|nil nameSuffix Rich text to append after mount name (icons mode only)
--- @return string|nil textLine Full line for tooltip (text mode only)
local function GetMountOwnershipDisplay(isCollected)
    if isCollected ~= true and isCollected ~= false then return nil, nil end
    local mode = addon.GetDB("insightMountOwnershipDisplay", "text")
    local L = addon.L
    if mode == "icons" then
        local sz = MountOwnershipIconSize()
        local path = isCollected and MOUNT_READY_TEX or MOUNT_NOTREADY_TEX
        local hex = isCollected and "55ff55" or "ff5555"
        local suffix = " |cff" .. hex .. "|T" .. path .. ":" .. sz .. ":" .. sz .. ":0:0|t|r"
        return suffix, nil
    end
    if isCollected then
        return nil, "|cff55ff55" .. ((L and L["INSIGHT_MOUNT_OWNED"])) .. "|r"
    end
    return nil, "|cffff5555" .. ((L and L["INSIGHT_MOUNT_NOT_OWNED"])) .. "|r"
end

-- ============================================================================
-- SECTION BUILDERS (reused by ProcessPlayerTooltip and /insight test)
-- ============================================================================

-- Honor level for separator + line; single pcall path shared with AddPvPBlock.
local function GetHonorLevelIfShown(unit)
    if not ShowHonorLevel() then return nil end
    local ok, honorLevel = pcall(UnitHonorLevel, unit)
    if ok and honorLevel and honorLevel > 0 then return honorLevel end
    return nil
end

local function PvPHasContent(unit)
    return GetHonorLevelIfShown(unit) ~= nil
end

local function SafePlainString(value)
    local ok, text = pcall(function()
        if value == nil then return nil end
        local s = tostring(value)
        if type(s) == "string" and s ~= "" then
            return s
        end
        return nil
    end)
    return ok and text or nil
end

local function GetSafeGuildInfo(unit)
    local guildName, guildRankName, guildRealm
    pcall(function()
        local rawGuildName, second, third, fourth = GetGuildInfo(unit)
        guildName = rawGuildName
        if type(third) == "string" and type(second) == "string" then
            guildRealm = second
            guildRankName = third
        else
            guildRankName = second
            guildRealm = fourth
        end
    end)
    return SafePlainString(guildName), SafePlainString(guildRankName), SafePlainString(guildRealm)
end

local function IsGuildLine(text, guildName, guildRealm)
    if not text or not guildName or guildName == "" then return false end
    local plain = Insight.StripColourEscapes and Insight.StripColourEscapes(text) or text
    if plain == guildName then return true end
    if guildRealm and guildRealm ~= "" and plain == guildName .. "-" .. guildRealm then return true end
    if plain:find("<" .. guildName .. ">", 1, true) then return true end
    if guildRealm and guildRealm ~= "" and plain:find("<" .. guildName .. "-" .. guildRealm .. ">", 1, true) then return true end
    return false
end

local function GetGuildRankDisplay(guildRankName, guildRealm)
    local rank = SafePlainString(guildRankName)
    if not rank or rank == "" then return nil end
    if guildRealm and rank == guildRealm then return nil end
    return rank
end

local function GetGuildDisplayLine(guildName, guildRankDisplay)
    if not guildName or guildName == "" then return nil end
    local line = "|cff00ff00<" .. guildName .. ">|r"
    if guildRankDisplay and guildRankDisplay ~= "" then
        line = line .. " |cffffffff" .. guildRankDisplay .. "|r"
    end
    return line
end

local function GetInsightTitleColorHex()
    local tc = addon.GetDB("insightTitleColor", nil)
    if not (tc and type(tc) == "table" and tc[1] and tc[2] and tc[3]) then
        local r = addon.GetDB("insightTitleColorR", nil)
        local g = addon.GetDB("insightTitleColorG", nil)
        local b = addon.GetDB("insightTitleColorB", nil)
        tc = (r and g and b) and { r, g, b } or Insight.TITLE_COLOR
    end
    return string.format("%02x%02x%02x",
        math.floor(tc[1] * 255), math.floor(tc[2] * 255), math.floor(tc[3] * 255))
end

local function RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        math.floor((r or 1) * 255), math.floor((g or 1) * 255), math.floor((b or 1) * 255))
end

local function IsNameGradientEnabled()
    return addon.GetDB("insightPlayerNameColor", "faction") == "class"
        and addon.GetDB("insightPlayerNameGradient", false)
end

local function GetTitleColorMode()
    local mode = addon.GetDB("insightTitleColorMode", nil)
    if mode == "match" or mode == "gradient" or mode == "custom" then
        if mode == "gradient" and not IsNameGradientEnabled() then return "match" end
        return mode
    end
    if addon.GetDB("insightTitleMatchNameColor", false) then return "match" end
    return "custom"
end

local function GetRealmNameMode()
    local mode = addon.GetDB("insightRealmNameMode", "full")
    if mode == "full" or mode == "hide" or mode == "modifier" or mode == "simplified" then return mode end
    return "full"
end

local function SplitRealmName(name)
    if type(name) ~= "string" or name == "" then return name end
    local base, realm = name:match("^(.-)%-(.+)$")
    if not base or base == "" or not realm or realm == "" then return name end
    return base, realm
end

local function GetRealmDisplayParts(name)
    local base, realm = SplitRealmName(name)
    if not realm then return name, "" end
    local mode = GetRealmNameMode()
    if mode == "full" then
        return base, "-" .. realm
    elseif mode == "hide" then
        return base, ""
    elseif ShiftModifierActive() then
        return base, "-" .. realm
    elseif mode == "modifier" then
        return base, ""
    end
    return base, " (*)"
end

local function FormatTitleSpan(titlePart, nameR, nameG, nameB)
    local mode = GetTitleColorMode()
    if mode == "gradient" then
        return Insight.BuildNameGradient(titlePart, nameR, nameG, nameB)
    elseif mode == "match" then
        return "|cff" .. RGBToHex(nameR, nameG, nameB) .. titlePart .. "|r"
    end
    return "|cff" .. GetInsightTitleColorHex() .. titlePart .. "|r"
end

local function FormatTitleNameSpan(titlePart, namePart, titlePosition, nameR, nameG, nameB, useGradient, realmSuffix)
    realmSuffix = realmSuffix or ""
    local titleFirst = titlePosition ~= "suffix"
    -- Suffix titles carry their own native separator (" the X" or ", the X"); don't double-space.
    local plain = titleFirst and (titlePart .. " " .. namePart .. realmSuffix) or (namePart .. titlePart .. realmSuffix)
    if GetTitleColorMode() == "gradient" then
        return Insight.BuildNameGradient(plain, nameR, nameG, nameB)
    end

    local nameSpan = FormatNameSpan(namePart, nameR, nameG, nameB, useGradient)
    local titleSpan = FormatTitleSpan(titlePart, nameR, nameG, nameB)
    local realmSpan = realmSuffix ~= "" and FormatNameSpan(realmSuffix, nameR, nameG, nameB, useGradient) or ""
    if titleFirst then
        return titleSpan .. " " .. nameSpan .. realmSpan
    end
    return nameSpan .. titleSpan .. realmSpan
end

local function GetPlayerDisplayName(unit, nameLeft)
    local namePart
    pcall(function()
        local n = GetUnitName(unit, true)
        namePart = SafePlainString(n)
    end)
    if not namePart or namePart == "" then
        namePart = Insight.SafeGetFontText(nameLeft) or ""
    end
    local baseName, realmSuffix = GetRealmDisplayParts(namePart)
    return baseName .. realmSuffix
end

local function GetInlineStatusTag(unit)
    if not ShowStatusBadges() then return "" end
    local tag = nil
    pcall(function()
        if ShowStatusBadgeAFK() and UnitIsAFK(unit) then
            tag = "|cffffff55[AFK]|r"
        elseif ShowStatusBadgeDND() and UnitIsDND(unit) then
            tag = "|cffaaaaaa[DND]|r"
        end
    end)
    return tag and (" " .. tag) or ""
end

local function GetPreviewInlineStatusTag()
    if not ShowStatusBadges() then return "" end
    if ShowStatusBadgeAFK() then return " |cffffff55[AFK]|r" end
    if ShowStatusBadgeDND() then return " |cffaaaaaa[DND]|r" end
    return ""
end

local function GetCharacterTitleParts(unit, nameLeft)
    local pvpName, baseName, fullName
    pcall(function()
        pvpName = SafePlainString(UnitPVPName(unit))
        baseName = SafePlainString(UnitName(unit))
        fullName = SafePlainString(GetUnitName(unit, true))
    end)
    if not pvpName or pvpName == "" then return nil, nil end

    local candidates = { fullName, baseName, Insight.SafeGetFontText(nameLeft) }
    for _, candidate in ipairs(candidates) do
        if candidate and candidate ~= "" then
            local plainCandidate = Insight.StripColourEscapes and Insight.StripColourEscapes(candidate) or candidate
            local idx = pvpName:find(plainCandidate, 1, true)
            if idx then
                local titlePart = pvpName:sub(1, idx - 1):gsub("%s+$", "")
                -- Preserve the native suffix separator (" the X" or ", the X") rather than
                -- stripping it; FormatTitleNameSpan relies on it for correct spacing.
                local suffixTitle = pvpName:sub(idx + #plainCandidate)
                if titlePart ~= "" then
                    return titlePart, fullName or candidate, "prefix"
                elseif suffixTitle:find("%S") then
                    return suffixTitle, fullName or candidate, "suffix"
                end
            end
        end
    end

    return nil, nil
end

--- Add PvP block (honor level only). Character title is shown in identity section.
--- @param tooltip table GameTooltip
--- @param unit string Unit token
--- @param _sepR number|nil Unused; kept for API stability with other block builders
--- @param _sepG number|nil Unused
--- @param _sepB number|nil Unused
--- @return nil
function Insight.AddPvPBlock(tooltip, unit, _sepR, _sepG, _sepB)
    local honorLevel = GetHonorLevelIfShown(unit)
    if honorLevel then
        Insight.TagLines(tooltip, "stats", function()
            local icon = (ShowIcons() and ShowRatingsIcons()) and Insight.HONOR_ICON or ""
            local faction = UnitFactionGroup(unit)
            local fc = Insight.FACTION_COLORS[faction]
            tooltip:AddLine(icon .. "Honor Level: " .. Insight.FormatNumberWithCommas(honorLevel), (fc and fc[1]) or 0.85, (fc and fc[2]) or 0.70, (fc and fc[3]) or 1.00)
        end)
    end
end

--- Add status badges block to tooltip.
--- @param tooltip table GameTooltip
--- @param unit string Unit token (e.g. "mouseover")
function Insight.AddStatusBadgesBlock(tooltip, unit)
    if not ShowStatusBadges() then return end
    local badges = {}
    pcall(function()
        if ShowStatusBadgeCombat() and UnitAffectingCombat(unit) then badges[#badges + 1] = "|cffff4444[Combat]|r"    end
        if ShowStatusBadgePVP()    and UnitIsPVP(unit)           then badges[#badges + 1] = "|cffff8c00[PvP]|r"       end
        if ShowStatusBadgeGroup() then
            if UnitInRaid(unit)        then badges[#badges + 1] = "|cff88ddff[Raid]|r"
            elseif UnitInParty(unit)   then badges[#badges + 1] = "|cff88ddff[Party]|r" end
        end
        if ShowStatusBadgeFriend() and C_FriendList and C_FriendList.IsFriend then
            local isFriend = false
            pcall(function()
                local g = UnitGUID(unit)
                if C_FriendList.IsFriend(g) then isFriend = true else isFriend = false end
            end)
            if isFriend then badges[#badges + 1] = "|cff55ff55[Friend]|r" end
        end
        if ShowStatusBadgeTargeting() then
            local targetingYou = false
            pcall(function()
                if UnitIsUnit("mouseoverTarget", "player") then targetingYou = true else targetingYou = false end
            end)
            if targetingYou then badges[#badges + 1] = "|cffff4466[Targeting You]|r" end
        end
    end)
    if #badges > 0 then
        Insight.TagLines(tooltip, "badges", function()
            tooltip:AddLine(table.concat(badges, "  "), 1, 1, 1)
        end)
    end
end

--- Add ratings block (M+ score, honor level) to tooltip.
function Insight.AddStatsBlock(tooltip, unit, cached, sepR, sepG, sepB)
    local hasStats = false
    local function EnsureStatsSep()
        if not hasStats then
            Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
            hasStats = true
        end
    end

    if ShowMythicScore() and C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
        local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
        if summary and summary.currentSeasonScore and summary.currentSeasonScore > 0 then
            local score = summary.currentSeasonScore
            local r, g, b = Insight.MythicScoreColor(score)
            EnsureStatsSep()
            Insight.TagLines(tooltip, "stats", function()
                local icon = (ShowIcons() and ShowRatingsIcons()) and Insight.MYTHIC_ICON or ""
                tooltip:AddLine(icon .. "M+ Score: " .. Insight.FormatNumberWithCommas(score), r, g, b)
            end)
        end
    end

    local honorLevel = GetHonorLevelIfShown(unit)
    if honorLevel then
        EnsureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (ShowIcons() and ShowRatingsIcons()) and Insight.HONOR_ICON or ""
            local faction = UnitFactionGroup(unit)
            local fc = Insight.FACTION_COLORS[faction]
            tooltip:AddLine(icon .. "Honor Level: " .. Insight.FormatNumberWithCommas(honorLevel), (fc and fc[1]) or 0.85, (fc and fc[2]) or 0.70, (fc and fc[3]) or 1.00)
        end)
    end

    if ShowAchievementPoints() then
        local achievedPoints = nil
        pcall(function()
            if UnitIsUnit(unit, "player") then
                local ok, pts = pcall(GetTotalAchievementPoints)
                if ok and pts and pts > 0 then achievedPoints = pts end
            else
                local g = UnitGUID(unit)
                local cachedAch = g and achievementCache[g]
                if cachedAch then
                    achievedPoints = cachedAch.points
                else
                    RequestAchievementComparison(unit)
                end
            end
        end)
        if achievedPoints then
            EnsureStatsSep()
            Insight.TagLines(tooltip, "stats", function()
                local icon = (ShowIcons() and ShowRatingsIcons()) and Insight.ACHIEVEMENT_ICON or ""
                tooltip:AddLine(icon .. "Achievement Points: " .. Insight.FormatNumberWithCommas(achievedPoints), Insight.ACHIEVEMENT_POINTS_COLOR[1], Insight.ACHIEVEMENT_POINTS_COLOR[2], Insight.ACHIEVEMENT_POINTS_COLOR[3])
            end)
        end
    end

    if cached then
        if ShowIlvl() and cached.ilvl then
            Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
            Insight.TagLines(tooltip, "stats", function()
                local icon = (ShowIcons() and ShowRatingsIcons()) and Insight.ILVL_ICON or ""
                tooltip:AddLine(icon .. "Item Level: " .. Insight.FormatNumberWithCommas(cached.ilvl), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
            end)
        end
    else
        local isSelf = false
        pcall(function()
            if UnitIsUnit(unit, "player") then
                isSelf = true
            else
                isSelf = false
            end
        end)
        local needsInspect = ShowIlvl() or ShowSpecRole()
        if not needsInspect then
            local src = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
            needsInspect = (src == "specoverride")
        end
        if not isSelf and needsInspect then
            RequestInspect(unit)
        end
    end
end

--- Add mount block to tooltip.
function Insight.AddMountBlock(tooltip, unit, sepR, sepG, sepB)
    if not ShowMount() then return end
    local mountOk, mount = pcall(GetPlayerMountInfo, unit)
    if not mountOk or not mount or not mount.name then return end

    local iconStr = ShowIcons() and mount.icon and ("|T" .. mount.icon .. ":14:14:0:0|t ") or ""
    Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
    Insight.TagLines(tooltip, "mount", function()
        local ownSuffix, ownTextLine = GetMountOwnershipDisplay(mount.isCollected)
        tooltip:AddLine(iconStr .. mount.name .. (ownSuffix or ""), Insight.MOUNT_COLOR[1], Insight.MOUNT_COLOR[2], Insight.MOUNT_COLOR[3])
        if mount.isCollected ~= true and mount.source and mount.source ~= "" then
            tooltip:AddLine(Insight.FormatNumbersInString(mount.source), Insight.MOUNT_SRC_COLOR[1], Insight.MOUNT_SRC_COLOR[2], Insight.MOUNT_SRC_COLOR[3])
        end
        if ownTextLine then
            tooltip:AddLine(ownTextLine, 1, 1, 1)
        end
    end)
end

--- Cache inspect for unit; used by INSPECT_READY handler.
function Insight.CacheInspect(guid, unit)
    CacheInspect(guid, unit)
end

--- Cache achievement points for unit; used by INSPECT_ACHIEVEMENT_READY handler.
function Insight.CacheAchievementPoints(unit)
    pcall(function()
        local g = UnitGUID(unit)
        if not g then return end
        if not GetComparisonAchievementPoints then return end
        local points = GetComparisonAchievementPoints()
        if not points or points <= 0 then return end
        achievementCache[g] = { points = points, time = GetTime() }
    end)
end

-- ============================================================================
-- TRP3 DATA FETCH
-- ============================================================================

--- Fetch Total RP 3 profile fields for a unit token. Returns a table of RP data
--- or nil when TRP3 is not loaded / the unit has no TRP3 profile.
--- All access is pcall-wrapped for Midnight safety.
function Insight.GetTRP3PlayerData(unit)
    if not TRP3_API then return nil end
    local ok, result = pcall(function()
        local getUnitID = TRP3_API.utils and TRP3_API.utils.str and TRP3_API.utils.str.getUnitID
        if not getUnitID then return nil end
        local unitID = getUnitID(unit)
        if not unitID or unitID == "" then return nil end

        -- Local player profiles live in TRP3_API.profile, not the register.
        -- Other players are looked up via the register.
        local profile
        if UnitIsUnit(unit, "player") then
            local getPlayerProfile = TRP3_API.profile and TRP3_API.profile.getPlayerCurrentProfile
            if not getPlayerProfile then return nil end
            profile = getPlayerProfile()
        else
            local isKnown = TRP3_API.register and TRP3_API.register.isUnitIDKnown
            if not (isKnown and isKnown(unitID)) then return nil end
            local getProfile = TRP3_API.register.getUnitIDCurrentProfile
            profile = getProfile and getProfile(unitID)
        end
        if not profile then return nil end
        -- Local player profiles nest data under profile.player; register profiles are flat.
        local profileData = UnitIsUnit(unit, "player") and (profile.player or {}) or profile
        local char   = profileData.characteristics or {}
        local status = profileData.character       or {}
        local data   = {}
        -- RP name (complete name including first name, last name, title prefix)
        local getCompleteName = TRP3_API.register and TRP3_API.register.getCompleteName
        if getCompleteName then
            local defaultName = UnitName(unit) or ""
            local name = getCompleteName(char, defaultName, false)
            if name and name ~= "" and name ~= defaultName then
                data.rpName = name
            end
        end
        -- Custom race and class
        if char.RA and char.RA ~= "" then data.customRace  = char.RA end
        if char.CL and char.CL ~= "" then data.customClass = char.CL end
        -- Character icon
        if char.IC and char.IC ~= "" then data.icon = char.IC end
        -- Currently text
        if status.CU and status.CU ~= "" then
            local cu = strtrim(status.CU)
            if cu ~= "" then data.currently = cu end
        end
        -- Player object APIs (color, pronouns, guild, IC status, icon fallback)
        if AddOn_TotalRP3 and AddOn_TotalRP3.Player and AddOn_TotalRP3.Player.CreateFromCharacterID then
            local player = AddOn_TotalRP3.Player.CreateFromCharacterID(unitID)
            if player then
                if player.GetCustomColorForDisplay then
                    local color = player:GetCustomColorForDisplay()
                    if color then
                        data.customColorR = color.r
                        data.customColorG = color.g
                        data.customColorB = color.b
                    end
                end
                if player.GetCustomPronouns then
                    local pronouns = player:GetCustomPronouns()
                    if pronouns and pronouns ~= "" then
                        data.pronouns = pronouns
                    end
                end
                if player.GetCustomGuildMembership then
                    local guild = player:GetCustomGuildMembership()
                    if guild and guild.name and guild.name ~= "" then
                        data.customGuild = strtrim(guild.name)
                        if guild.rank and guild.rank ~= "" then
                            data.customGuildRank = strtrim(guild.rank)
                        end
                    end
                end
                -- IC/OOC status via Player object (more reliable than raw profile key)
                if player.GetRoleplayStatus then
                    local rpStatus = player:GetRoleplayStatus()
                    -- AddOn_TotalRP3.Enums.ROLEPLAY_STATUS: IN_CHARACTER=1, OUT_OF_CHARACTER=2
                    if rpStatus then
                        data.isIC = (rpStatus == 1)
                    end
                elseif status.RP ~= nil then
                    data.isIC = (status.RP == 1)
                end
                -- Icon via Player object if not already found in characteristics
                if not data.icon and player.GetCustomIcon then
                    local icon = player:GetCustomIcon()
                    if icon and icon ~= "" then data.icon = icon end
                end
            end
        elseif status.RP ~= nil then
            data.isIC = (status.RP == 1)
        end
        if not next(data) then return nil end
        return data
    end)
    if not ok or type(result) ~= "table" then return nil end
    return result
end

-- ============================================================================
-- PROCESS PLAYER TOOLTIP
-- ============================================================================

--- Process player unit tooltip. Full enrichment: name, class/spec/role, PvP, badges, stats, mount.
--- @param unit string Unit token (e.g. "mouseover")
--- @param tooltip table GameTooltip
--- @return boolean true if processed
function Insight.ProcessPlayerTooltip(unit, tooltip)
    if not Insight.IsInsightEnabled() or not tooltip then return false end
    local isUnitPlayer = false
    pcall(function()
        if UnitIsPlayer(unit) then
            isUnitPlayer = true
        else
            isUnitPlayer = false
        end
    end)
    if not isUnitPlayer then return false end

    local className, classFile, classColor
    pcall(function()
        className, classFile = UnitClass(unit)
        classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
    end)
    -- className from UnitClass is a tainted (secret) string in TWW Midnight — it cannot be
    -- passed to Lua string functions (find, gsub, etc.) without erroring.  Get an equivalent
    -- plain Lua string from the global lookup table instead, keyed by classFile which is the
    -- non-tainted uppercase token (e.g. "DEATHKNIGHT").  Falls back to className if the lookup
    -- fails so this is a no-op on older clients where taint is not an issue.
    local classNameSafe = className  -- pre-TWW fallback
    pcall(function()
        if classFile and LOCALIZED_CLASS_NAMES_MALE then
            local safe = LOCALIZED_CLASS_NAMES_MALE[classFile]
            if type(safe) == "string" and safe ~= "" then
                classNameSafe = safe
            end
        end
    end)
    local guildName, guildRankName, guildRealm = GetSafeGuildInfo(unit)
    local trp3Data = ShowTRP3() and Insight.GetTRP3PlayerData(unit) or nil
    if classColor then
        local modcc = addon.GetModuleClassColor and addon.GetModuleClassColor("insight")
        if not modcc then classColor = nil end
    end
    local sepR = (classColor and classColor.r) or Insight.SEP_COLOR[1]
    local sepG = (classColor and classColor.g) or Insight.SEP_COLOR[2]
    local sepB = (classColor and classColor.b) or Insight.SEP_COLOR[3]
    Insight.sepR, Insight.sepG, Insight.sepB = sepR, sepG, sepB
    local cached = GetInspectCachedForUnit(unit)

    -- Self-unit: populate inspect cache directly
    local isSelfUnit = false
    pcall(function()
        if UnitIsUnit(unit, "player") then
            isSelfUnit = true
        else
            isSelfUnit = false
        end
    end)
    if not cached and isSelfUnit then
        TrySeedSelfInspectCache(unit)
        cached = GetInspectCachedForUnit(unit)
    end
    if not cached then
        local needsEarlyInspect = ShowIlvl() or ShowSpecRole()
        if not needsEarlyInspect and ShowIcons() then
            local src = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
            needsEarlyInspect = src == "specoverride"
        end
        if needsEarlyInspect then
            RequestInspect(unit)
        end
    end

    -- 1. Name line: faction icon + name (with character title when ShowCharacterTitle; title in gold, name in faction/class color)
    local ttName = tooltip:GetName()
    local nameLeft = ttName and _G[ttName .. "TextLeft1"]
    if nameLeft then
        local faction = UnitFactionGroup(unit)
        local icon    = ShowIcons() and (Insight.FACTION_ICONS[faction] or "") or ""
        local displayText
        local nameR, nameG, nameB
        local nameModeRaw = addon.GetDB("insightPlayerNameColor", "faction")
        local nameMode = (nameModeRaw == "class") and "class" or "faction"
        if nameMode == "class" and classFile and C_ClassColor and C_ClassColor.GetClassColor then
            local ccName = C_ClassColor.GetClassColor(classFile)
            if ccName then
                nameR, nameG, nameB = ccName.r, ccName.g, ccName.b
            end
        end
        if not nameR then
            local fc = Insight.FACTION_COLORS[faction]
            nameR = (fc and fc[1]) or (classColor and classColor.r) or 1
            nameG = (fc and fc[2]) or (classColor and classColor.g) or 1
            nameB = (fc and fc[3]) or (classColor and classColor.b) or 1
        end
        -- TRP3 custom name colour overrides faction/class colour when enabled
        if trp3Data and trp3Data.customColorR and ShowTRP3CustomColor() then
            nameR = trp3Data.customColorR
            nameG = trp3Data.customColorG
            nameB = trp3Data.customColorB
        end
        local useGradient = (nameMode == "class")
            and addon.GetDB("insightPlayerNameGradient", false)
        if ShowCharacterTitle() then
            pcall(function()
                local titlePart, namePart, titlePosition = GetCharacterTitleParts(unit, nameLeft)
                if not titlePart or not namePart then return end
                local baseName, realmSuffix = GetRealmDisplayParts(namePart)
                displayText = FormatTitleNameSpan(titlePart, baseName, titlePosition, nameR, nameG, nameB, useGradient, realmSuffix)
            end)
        end
        if not displayText then
            local namePart = GetPlayerDisplayName(unit, nameLeft)
            if useGradient then
                -- Force vertex colour to white so our |cff escapes aren't
                -- dampened by Blizzard's SetTextColor.
                displayText = Insight.BuildNameGradient(Insight.StripColourEscapes(namePart), nameR, nameG, nameB)
                nameLeft:SetTextColor(1, 1, 1, 1)
            else
                displayText = namePart
                nameLeft:SetTextColor(nameR, nameG, nameB)
            end
        end
        -- TRP3 RP name: replace WoW character name with RP name when available
        if trp3Data and trp3Data.rpName and ShowTRP3RPName() then
            if useGradient then
                displayText = Insight.BuildNameGradient(trp3Data.rpName, nameR, nameG, nameB)
                nameLeft:SetTextColor(1, 1, 1, 1)
            else
                displayText = FormatNameSpan(trp3Data.rpName, nameR, nameG, nameB, false)
                nameLeft:SetTextColor(nameR, nameG, nameB)
            end
        end
        -- Build TRP3 suffix: pronouns and IC/OOC badge
        local trp3Suffix = ""
        if trp3Data then
            if trp3Data.pronouns and ShowTRP3Pronouns() then
                trp3Suffix = trp3Suffix .. " |cffaaaaaa(" .. trp3Data.pronouns .. ")|r"
            end
            if trp3Data.isIC ~= nil and ShowTRP3ICStatus() then
                if ShowTRP3ICStatusIcon() then
                    trp3Suffix = trp3Suffix .. (trp3Data.isIC and " |cff55ff55●|r" or " |cffff5555●|r")
                else
                    trp3Suffix = trp3Suffix .. (trp3Data.isIC and " |cff55ff55[IC]|r" or " |cffff5555[OOC]|r")
                end
            end
        end
        local trp3IconMarkup = ""
        if trp3Data and trp3Data.icon and ShowTRP3Icon() then
            trp3IconMarkup = "|TInterface\\Icons\\" .. trp3Data.icon .. ":14:14:0:0|t "
        end
        -- TRP3 icon replaces the faction symbol; fall back to faction when no TRP3 icon
        local namePrefix = (trp3IconMarkup ~= "" and trp3IconMarkup) or icon
        nameLeft:SetText(namePrefix .. displayText .. GetInlineStatusTag(unit) .. trp3Suffix)
    end

    -- 2. Border tint
    if classColor then
        tooltip:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.60)
    end

    -- 3. Clean up Blizzard lines (skip line 1; name already styled)
    local classLineStyled = false
    local guildLineStyled = false
    local guildRankDisplay = ShowGuildRank() and GetGuildRankDisplay(guildRankName, guildRealm)
    local raceNameSafe = nil
    pcall(function()
        raceNameSafe = UnitRace(unit)
    end)
    local raceIconStyled = false
    local raceIconPrefix = ""
    if raceNameSafe and raceNameSafe ~= "" then
        local raceIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
        raceIconPrefix = RaceIconMarkup(unit, raceIconPx)
    end
    Insight.ForTooltipLines(tooltip, function(j, lineLeft, _lineRight)
        if j < 2 or not lineLeft then return end
        pcall(function()
            local text = Insight.SafeGetFontText(lineLeft)
            if not text or text == "" then return end

            if text:find(" %(Player%)") then
                text = text:gsub(" %(Player%)", "")
                lineLeft:SetText(text)
            end

            if text == "Horde" or text == "Alliance" or text == "PvP" then
                lineLeft:SetText("")
            elseif classNameSafe and text ~= "" and text:find(classNameSafe, 1, true) and classLineStyled then
                lineLeft:SetText("")
            elseif IsGuildLine(text, guildName, guildRealm) then
                guildLineStyled = true
                local guildDisplayLine = GetGuildDisplayLine(guildName, guildRankDisplay)
                if guildDisplayLine then
                    lineLeft:SetText(guildDisplayLine)
                    lineLeft:SetTextColor(1, 1, 1)
                end
            elseif not raceIconStyled and raceIconPrefix ~= "" and raceNameSafe and text ~= "" and text:find(raceNameSafe, 1, true) and not text:find("|T", 1, true) and not text:find("|A", 1, true) then
                raceIconStyled = true
                lineLeft:SetText(raceIconPrefix .. text)
            elseif classNameSafe and text ~= "" and text:find(classNameSafe, 1, true) then
                classLineStyled = true
                if classColor then
                    lineLeft:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
                local iconPrefix = ""
                if ShowIcons() then
                    local lineIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
                    local source = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
                    if source == "specoverride" then
                        -- Spec override intentionally waits for inspect data instead of flashing a class icon first.
                        if cached and cached.specIcon then
                            iconPrefix = SpecIconMarkup(cached.specIcon, lineIconPx)
                        end
                    else
                        local classIcon = Insight.GetClassIconTexture and Insight.GetClassIconTexture(classFile)
                        if classIcon then
                            iconPrefix = classIcon
                        elseif ShowSpecRole() and cached and cached.specIcon then
                            iconPrefix = SpecIconMarkup(cached.specIcon, lineIconPx)
                        end
                    end
                end
                local roleSuffix = ""
                if ShowSpecRole() and cached and cached.role then
                    local rc = Insight.ROLE_COLORS[cached.role]
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
        end)
        -- On taint/secret string, pcall catches; skip styling for this line
    end)

    if guildName and guildRankDisplay and not guildLineStyled then
        Insight.TagLines(tooltip, "identity", function()
            tooltip:AddLine(GetGuildDisplayLine(guildName, guildRankDisplay), 1, 1, 1)
        end)
    end

    -- TRP3 custom RP guild (separate from WoW guild)
    if trp3Data and trp3Data.customGuild and ShowTRP3Guild() then
        Insight.TagLines(tooltip, "identity", function()
            local guildLine = "|cff00ccff<" .. trp3Data.customGuild .. ">|r"
            if trp3Data.customGuildRank and trp3Data.customGuildRank ~= "" then
                guildLine = guildLine .. " |cffaaaaaa" .. trp3Data.customGuildRank .. "|r"
            end
            tooltip:AddLine(guildLine, 1, 1, 1)
        end)
    end

    -- TRP3 custom race and/or class
    if trp3Data and ShowTRP3RaceClass() and (trp3Data.customRace or trp3Data.customClass) then
        Insight.TagLines(tooltip, "identity", function()
            local racePart  = trp3Data.customRace  or ""
            local classPart = trp3Data.customClass  or ""
            if classColor and classPart ~= "" then
                local hex = string.format("%02x%02x%02x",
                    math.floor(classColor.r * 255),
                    math.floor(classColor.g * 255),
                    math.floor(classColor.b * 255))
                classPart = "|cff" .. hex .. classPart .. "|r"
            end
            local line = strtrim(racePart .. (classPart ~= "" and (" " .. classPart) or ""))
            if line ~= "" then
                tooltip:AddLine(line, 1, 0.82, 0)
            end
        end)
    end

    -- 4. Status badges (part of identity section)
    Insight.AddStatusBadgesBlock(tooltip, unit)

    -- 5. Stats block (M+ score, item level)
    Insight.AddStatsBlock(tooltip, unit, cached, sepR, sepG, sepB)

    -- 6. Mount block
    Insight.AddMountBlock(tooltip, unit, sepR, sepG, sepB)

    -- 7. TRP3 Currently block
    if trp3Data and trp3Data.currently and ShowTRP3Currently() then
        Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
        Insight.TagLines(tooltip, "trp3currently", function()
            tooltip:AddLine("Currently:", 0.7, 0.7, 0.7)
            local text = trp3Data.currently
            if #text > 300 then text = text:sub(1, 300) .. "..." end
            tooltip:AddLine(text, 0.9, 0.85, 0.7)
        end)
    end

    return true
end

--- Render sample player tooltip content for /insight test and dashboard preview.
--- Mirrors ProcessPlayerTooltip + block builders; each section gated by the same Show*() DB flags.
function Insight.RenderTestTooltipContent(tooltip)
    if not tooltip then return end
    local testSepR, testSepG, testSepB = 0.77, 0.12, 0.23  -- DK class colour
    Insight.sepR, Insight.sepG, Insight.sepB = testSepR, testSepG, testSepB

    local showIcons = ShowIcons()
    local fc = Insight.FACTION_COLORS["Alliance"]
    local nameModeRaw = addon.GetDB("insightPlayerNameColor", "faction")
    local nameMode = (nameModeRaw == "class") and "class" or "faction"
    local nameR, nameG, nameB = fc[1], fc[2], fc[3]
    if nameMode == "class" then
        nameR, nameG, nameB = testSepR, testSepG, testSepB
    end
    local facIcon = showIcons and (Insight.FACTION_ICONS["Alliance"] or "") or ""

    local useGradient = (nameMode == "class")
        and addon.GetDB("insightPlayerNameGradient", false)

    -- TRP3 mock data (mirrors what GetTRP3PlayerData would return for a player with a full profile)
    local previewTRP3 = (TRP3_API ~= nil and ShowTRP3()) and {
        rpName      = "Aelindra Dawnwhisper",
        pronouns    = "she/her",
        isIC        = true,
        customColorR = 0.72, customColorG = 0.53, customColorB = 1.0,
        customRace  = "Sin'dorei",
        customClass = "Arcane Weaver",
        customGuild = "Dawnguard Covenant",
        customGuildRank = "Keeper",
        currently   = "Studying ancient texts in the library, searching for answers...",
        icon        = "spell_arcane_arcane01",
    } or nil

    -- 1. Name line (character title optional — same as live)
    -- When TRP3 is active the preview character is Aelindra (Blood Elf) so the RP name
    -- toggle clearly shows "Aelindra" → "Aelindra Dawnwhisper".
    local previewName, previewRealmSuffix
    if previewTRP3 then
        previewName, previewRealmSuffix = "Aelindra", ""
    else
        previewName, previewRealmSuffix = GetRealmDisplayParts("Horizonaut-Stormrage")
    end
    local inlineStatusTag = GetPreviewInlineStatusTag()

    -- TRP3 custom colour override
    if previewTRP3 and previewTRP3.customColorR and ShowTRP3CustomColor() then
        nameR = previewTRP3.customColorR
        nameG = previewTRP3.customColorG
        nameB = previewTRP3.customColorB
    end

    -- TRP3 RP name replaces the WoW character name
    local displayName = previewName .. previewRealmSuffix
    if previewTRP3 and previewTRP3.rpName and ShowTRP3RPName() then
        displayName = previewTRP3.rpName
    end

    local nameSpan
    if useGradient then
        nameSpan = Insight.BuildNameGradient(displayName, nameR, nameG, nameB)
    else
        nameSpan = FormatNameSpan(displayName, nameR, nameG, nameB, false)
    end

    -- TRP3 pronouns + IC/OOC suffix
    local trp3Suffix = ""
    if previewTRP3 then
        if previewTRP3.pronouns and ShowTRP3Pronouns() then
            trp3Suffix = trp3Suffix .. " |cffaaaaaa(" .. previewTRP3.pronouns .. ")|r"
        end
        if previewTRP3.isIC ~= nil and ShowTRP3ICStatus() then
            if ShowTRP3ICStatusIcon() then
                trp3Suffix = trp3Suffix .. (previewTRP3.isIC and " |cff55ff55●|r" or " |cffff5555●|r")
            else
                trp3Suffix = trp3Suffix .. (previewTRP3.isIC and " |cff55ff55[IC]|r" or " |cffff5555[OOC]|r")
            end
        end
    end

    -- TRP3 character icon
    local trp3IconMarkup = ""
    if previewTRP3 and previewTRP3.icon and ShowTRP3Icon() then
        trp3IconMarkup = "|TInterface\\Icons\\" .. previewTRP3.icon .. ":14:14:0:0|t "
    end

    -- TRP3 icon replaces the faction symbol in preview too
    local namePrefix = (trp3IconMarkup ~= "" and trp3IconMarkup) or facIcon
    if ShowCharacterTitle() then
        local titleSpan = FormatTitleNameSpan("Duelist", displayName, "prefix", nameR, nameG, nameB, useGradient, "")
        tooltip:AddLine(namePrefix .. titleSpan .. inlineStatusTag .. trp3Suffix, nameR, nameG, nameB)
    else
        if useGradient then
            tooltip:AddLine(namePrefix .. nameSpan .. inlineStatusTag .. trp3Suffix, 1, 1, 1)
        else
            tooltip:AddLine(namePrefix .. nameSpan .. inlineStatusTag .. trp3Suffix, nameR, nameG, nameB)
        end
    end

    -- 2. Guild (rank line only when guild rank toggle on — live augments guild line)
    if ShowGuildRank() then
        tooltip:AddLine("<Ascension>  |cffaaaaaaOfficer|r", testSepR, testSepG, testSepB)
    else
        tooltip:AddLine("<Ascension>", testSepR, testSepG, testSepB)
    end
    -- TRP3 custom guild
    if previewTRP3 and previewTRP3.customGuild and ShowTRP3Guild() then
        Insight.TagLines(tooltip, "identity", function()
            local guildLine = "|cff00ccff<" .. previewTRP3.customGuild .. ">|r"
            if previewTRP3.customGuildRank and previewTRP3.customGuildRank ~= "" then
                guildLine = guildLine .. " |cffaaaaaa" .. previewTRP3.customGuildRank .. "|r"
            end
            tooltip:AddLine(guildLine, 1, 1, 1)
        end)
    end

    local testIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
    local previewRaceFile = previewTRP3 and "bloodelf-female" or "human-male"
    local previewRaceName = previewTRP3 and "Blood Elf" or "Human"
    local raceIconStr = ShowRaceIcons() and ("|T" .. RACE_ICON_PATH_PREFIX .. previewRaceFile .. ".tga:" .. testIconPx .. ":" .. testIconPx .. ":0:0|t ") or ""
    tooltip:AddLine(raceIconStr .. "Level 80 " .. previewRaceName, 1, 0.82, 0)
    -- TRP3 custom race & class
    if previewTRP3 and ShowTRP3RaceClass() and (previewTRP3.customRace or previewTRP3.customClass) then
        Insight.TagLines(tooltip, "identity", function()
            local racePart  = previewTRP3.customRace  or ""
            local classPart = previewTRP3.customClass or ""
            if classPart ~= "" then
                local hex = string.format("%02x%02x%02x",
                    math.floor(testSepR * 255), math.floor(testSepG * 255), math.floor(testSepB * 255))
                classPart = "|cff" .. hex .. classPart .. "|r"
            end
            local line = strtrim(racePart .. (classPart ~= "" and (" " .. classPart) or ""))
            if line ~= "" then tooltip:AddLine(line, 1, 0.82, 0) end
        end)
    end

    local classIconStr = ""
    if showIcons then
        local src = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
        if src == "specoverride" then
            -- Spec Override: show Blizzard's native Blood DK spec icon
            classIconStr = SpecIconMarkup("Interface\\Icons\\spell_deathknight_bloodpresence", testIconPx)
        else
            classIconStr = (Insight.GetClassIconTexture and Insight.GetClassIconTexture("DEATHKNIGHT")) or ""
            if classIconStr == "" then
                classIconStr = "|TInterface\\Icons\\spell_deathknight_bloodpresence:" .. testIconPx .. ":" .. testIconPx .. ":0:0|t "
            end
        end
    end
    local previewRoleSuffix = ""
    if ShowSpecRole() then
        local previewRc = Insight.ROLE_COLORS["TANK"]
        local previewRoleHex = string.format("%02x%02x%02x", math.floor(previewRc[1] * 255), math.floor(previewRc[2] * 255), math.floor(previewRc[3] * 255))
        previewRoleSuffix = "  |cff" .. previewRoleHex .. "Tank|r"
    end
    tooltip:AddLine(classIconStr .. "Blood Death Knight" .. previewRoleSuffix, 0.77, 0.12, 0.23)

    -- 4. Status badges (AddStatusBadgesBlock)
    if ShowStatusBadges() then
        local previewBadges = {}
        if ShowStatusBadgeCombat()    then previewBadges[#previewBadges + 1] = "|cffff4444[Combat]|r"       end
        if ShowStatusBadgePVP()       then previewBadges[#previewBadges + 1] = "|cffff8c00[PvP]|r"         end
        if ShowStatusBadgeGroup()     then previewBadges[#previewBadges + 1] = "|cff88ddff[Party]|r"       end
        if ShowStatusBadgeFriend()    then previewBadges[#previewBadges + 1] = "|cff55ff55[Friend]|r"      end
        if ShowStatusBadgeTargeting() then previewBadges[#previewBadges + 1] = "|cffff4466[Targeting You]|r" end
        if #previewBadges > 0 then
            Insight.TagLines(tooltip, "badges", function()
                tooltip:AddLine(table.concat(previewBadges, "  "), 1, 1, 1)
            end)
        end
    end

    -- 5. Stats (M+ / ilvl — EnsureStatsSep pattern from AddStatsBlock)
    local hasStats = false
    local function ensureStatsSep()
        if not hasStats then
            Insight.AddSectionSeparator(tooltip)
            hasStats = true
        end
    end
    if ShowMythicScore() then
        ensureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.MYTHIC_ICON or ""
            tooltip:AddLine(icon .. "M+ Score: " .. Insight.FormatNumberWithCommas(2847), Insight.MythicScoreColor(2847))
        end)
    end
    if ShowHonorLevel() then
        ensureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.HONOR_ICON or ""
            tooltip:AddLine(icon .. "Honor Level: " .. Insight.FormatNumberWithCommas(247), fc[1], fc[2], fc[3])
        end)
    end

    if ShowAchievementPoints() then
        ensureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.ACHIEVEMENT_ICON or ""
            tooltip:AddLine(icon .. "Achievement Points: " .. Insight.FormatNumberWithCommas(28650), Insight.ACHIEVEMENT_POINTS_COLOR[1], Insight.ACHIEVEMENT_POINTS_COLOR[2], Insight.ACHIEVEMENT_POINTS_COLOR[3])
        end)
    end

    if ShowIlvl() then
        Insight.AddSectionSeparator(tooltip)
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.ILVL_ICON or ""
            tooltip:AddLine(icon .. "Item Level: " .. Insight.FormatNumberWithCommas(639), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
        end)
    end

    -- 7. Mount block (mirrors AddMountBlock: source only when not collected; ownership from setting)
    if ShowMount() then
        Insight.AddSectionSeparator(tooltip)
        local mountIconStr = showIcons and "|TInterface\\Icons\\ability_mount_drake_proto:14:14:0:0|t " or ""
        local ownSuffix, ownTextLine = GetMountOwnershipDisplay(false)
        Insight.TagLines(tooltip, "mount", function()
            tooltip:AddLine(
                mountIconStr .. "Reins of the Thundering Cobalt Cloud Serpent" .. (ownSuffix or ""),
                Insight.MOUNT_COLOR[1], Insight.MOUNT_COLOR[2], Insight.MOUNT_COLOR[3])
            -- Uncollected sample mount: source line shown; collected mounts omit source in live tooltips.
            tooltip:AddLine("Drop: Sha of Anger", Insight.MOUNT_SRC_COLOR[1], Insight.MOUNT_SRC_COLOR[2], Insight.MOUNT_SRC_COLOR[3])
            if ownTextLine then
                tooltip:AddLine(ownTextLine, 1, 1, 1)
            end
        end)
    end

    -- TRP3 Currently block
    if previewTRP3 and previewTRP3.currently and ShowTRP3Currently() then
        Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
        Insight.TagLines(tooltip, "trp3currently", function()
            tooltip:AddLine("Currently:", 0.7, 0.7, 0.7)
            tooltip:AddLine(previewTRP3.currently, 0.9, 0.85, 0.7)
        end)
    end
end

addon.Insight = Insight
