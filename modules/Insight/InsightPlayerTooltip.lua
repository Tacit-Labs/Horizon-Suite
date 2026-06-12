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

local function GetPlayerGradientBias()
    return tonumber(addon.GetDB("insightPlayerGradientBias", 0)) or 0
end

-- Wrap a plain name in either a per-character gradient (class-colour mode with
-- the gradient toggle on) or a single flat |cff colour span. Shared by the
-- live tooltip and the dashboard preview.
local function FormatNameSpan(plain, r, g, b, useGradient)
    if useGradient then
        return Insight.BuildNameGradient(plain, r, g, b, GetPlayerGradientBias())
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
local function ShowStatusBadgeDND()       return ShowStatusBadgeAFK() end
local function ShowStatusBadgePVP()       return addon.GetDB("insightStatusBadgePVP",        true) end
local function ShowStatusBadgeGroup()     return addon.GetDB("insightStatusBadgeGroup",      true) end
local function ShowStatusBadgeFriend()    return addon.GetDB("insightStatusBadgeFriend",     true) end
local function ShowStatusBadgeTargeting() return addon.GetDB("insightStatusBadgeTargeting",  true) end
local function ShowTargeting()            return addon.GetDB("insightShowTargeting",          true) end
local function ShowStatusBadgeAFKInHeader() return addon.GetDB("insightStatusBadgeAFKInHeader", false) end
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
local function ShowTRP3BorderColor()  return addon.GetDB("insightTRP3BorderColor",  false) end

local function ProperCasePronouns(s)
    if not s or s == "" then return s end
    return (s:gsub("([^/]+)", function(seg) return seg:sub(1, 1):upper() .. seg:sub(2) end))
end
local function ShowTRP3Title()        return addon.GetDB("insightTRP3Title",        true) end
-- WoW character title alongside the TRP3 RP name ("Star Savior Queen Angelstar").
-- force = always, modifier = only while Shift held, hide = RP name only.
local function ShowWowTitleWithTRP3()
    local mode = addon.GetDB("insightTRP3WowTitle", "force")
    if mode == "hide" then return false end
    return mode == "force" or (mode == "modifier" and (Insight.previewRendering or ShiftModifierActive()))
end
local function ShowTRP3RaceClass()   return addon.GetDB("insightTRP3RaceClass",   true) end
local function ShowTRP3Guild()       return addon.GetDB("insightTRP3Guild",       true) end
-- Build the combined race / class / level line.
-- When trp3d has custom race/class, those are used with TRP3 colour logic.
-- When trp3d has no custom fields (or is nil), wowFallback provides the WoW race/class strings.
-- Race and level render in white; class gets TRP3 custom colour (if enabled) or WoW class colour.
-- @param trp3d      table|nil   TRP3 player data from GetTRP3PlayerData (nil = WoW-only line)
-- @param classCol   table|nil   classColor {r,g,b} for class colour fallback
-- @param unitToken  string|nil  Unit token for live UnitLevel
-- @param wowFallback table|nil  { race=string, class=string } used when trp3d has no custom data
-- @return string
local function BuildCombinedRaceClassLine(trp3d, classCol, unitToken, wowFallback)
    local racePart, rawClass, useCustomColor
    if trp3d and (trp3d.customRace or trp3d.customClass) then
        racePart       = (trp3d.customRace  ~= nil and trp3d.customRace  ~= "") and trp3d.customRace  or ""
        rawClass       = (trp3d.customClass ~= nil and trp3d.customClass ~= "") and trp3d.customClass or ""
        useCustomColor = trp3d.customColorR and ShowTRP3CustomColor()
    elseif wowFallback then
        racePart = wowFallback.race  or ""
        rawClass  = wowFallback.class or ""
    else
        return ""
    end
    local classPart = ""
    if rawClass ~= "" then
        local cr, cg, cb
        if useCustomColor then
            cr, cg, cb = trp3d.customColorR, trp3d.customColorG, trp3d.customColorB
        elseif classCol then
            cr, cg, cb = classCol.r, classCol.g, classCol.b
        end
        if cr and cg and cb then
            local hex = string.format("%02x%02x%02x",
                math.floor(cr * 255),
                math.floor(cg * 255),
                math.floor(cb * 255))
            classPart = "|cff" .. hex .. rawClass .. "|r"
        else
            classPart = rawClass
        end
    end
    local level = nil
    if unitToken then pcall(function() level = UnitLevel(unitToken) end) end
    local line = racePart
    if classPart ~= "" then line = line .. (racePart ~= "" and " " or "") .. classPart end
    if level and level > 0 then line = line .. "  Level " .. tostring(level) end
    return line
end
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
            local cmpOk, matched = pcall(function() return aura.spellId == spellID end)
            if cmpOk and matched then return true end
            if not cmpOk then break end  -- spellId is secret; all iterations will be, bail out
        end
    end
    if UnitAura then
        for i = 1, 40 do
            local ok, name, _, _, _, _, _, _, _, spellId = pcall(UnitAura, unit, i, "HELPFUL")
            if not ok or not name then break end
            local cmpOk, matched = pcall(function() return spellId == spellID end)
            if cmpOk and matched then return true end
            if not cmpOk then break end  -- spellId is secret; bail out
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

-- @return string|nil nameSuffix Rich text to append after mount name (icons mode only)
-- @return string|nil textLine Full line for tooltip (text mode only)
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

-- Expose for sibling Insight tooltip files (e.g. NPC targeting) that need to
-- launder a possibly-secret string before display.
Insight.SafePlainString = Insight.SafePlainString or SafePlainString

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
        return Insight.BuildNameGradient(titlePart, nameR, nameG, nameB, GetPlayerGradientBias())
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
        return Insight.BuildNameGradient(plain, nameR, nameG, nameB, GetPlayerGradientBias())
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
        if ShowStatusBadgeAFK() and ShowStatusBadgeAFKInHeader() then
            if UnitIsAFK(unit) then
                tag = "|cffffff55[AFK]|r"
            elseif UnitIsDND(unit) then
                tag = "|cffaaaaaa[DND]|r"
            end
        end
    end)
    return tag and (" " .. tag) or ""
end

local function GetPreviewInlineStatusTag()
    if not ShowStatusBadges() then return "" end
    if ShowStatusBadgeAFK() and ShowStatusBadgeAFKInHeader() then return " |cffffff55[AFK]|r" end
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

-- Add PvP block (honor level only). Character title is shown in identity section.
-- @param tooltip table GameTooltip
-- @param unit string Unit token
-- @param _sepR number|nil Unused; kept for API stability with other block builders
-- @param _sepG number|nil Unused
-- @param _sepB number|nil Unused
-- @return nil
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

-- Add status badges block to tooltip.
-- @param tooltip table GameTooltip
-- @param unit string Unit token (e.g. "mouseover")
function Insight.AddStatusBadgesBlock(tooltip, unit)
    if not ShowStatusBadges() then return end
    local badges = {}
    pcall(function()
        if ShowStatusBadgeAFK() and not ShowStatusBadgeAFKInHeader() and UnitIsAFK(unit) then badges[#badges + 1] = "|cffffff55[AFK]|r" end
        if ShowStatusBadgeAFK() and not ShowStatusBadgeAFKInHeader() and UnitIsDND(unit) then badges[#badges + 1] = "|cffaaaaaa[DND]|r" end
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

-- Add ratings block (M+ score, honor level) to tooltip.
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

-- Add targeting line to tooltip.
function Insight.AddTargetingBlock(tooltip, unit, sepR, sepG, sepB)
    if not ShowTargeting() then return end
    local targetName = nil

    -- Resolve target unit token.
    -- When the hovered unit is a party/raid member, tooltip:GetUnit() returns the
    -- party token (e.g. "party1") rather than "mouseover". WoW doesn't always sync
    -- party member target data to the client, so "party1target" may not exist even
    -- when they have a target. If this unit is also the current mouseover, prefer
    -- "mouseovertarget" which is always populated while hovering.
    -- `unit` may itself be a secret token (tooltip:GetUnit() on Midnight), so even
    -- the `unit .. "target"` concatenation can throw — isolate it in its own pcall.
    local targetUnit
    pcall(function() targetUnit = unit .. "target" end)
    if not targetUnit then return end
    if targetUnit ~= "mouseovertarget" then
        local isMO = false
        pcall(function()
            if UnitIsUnit(unit, "mouseover") then isMO = true end
        end)
        if isMO then targetUnit = "mouseovertarget" end
    end

    -- UnitExists can return a secret boolean in tainted execution (securecallfunction).
    -- `if secretBool then` throws, so isolate the probe in its own pcall (SafeUnitExistsKnown
    -- pattern) to get a plain true/false out before touching UnitName.
    local targetExists = false
    pcall(function()
        if UnitExists(targetUnit) then targetExists = true end
    end)
    if targetExists then
        pcall(function()
            -- UnitName returns a secret string; launder via SafePlainString so the
            -- "Targeting: " .. targetName concat below cannot throw on a secret value.
            local n = SafePlainString(UnitName(targetUnit))
            if n then targetName = n end
        end)
    end

    if not targetName then return end
    Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
    Insight.TagLines(tooltip, "stats", function()
        tooltip:AddLine("Targeting: " .. targetName, 1, 1, 1)
    end)
end

-- Add mount block to tooltip.
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

-- Cache inspect for unit; used by INSPECT_READY handler.
function Insight.CacheInspect(guid, unit)
    CacheInspect(guid, unit)
end

-- Cache achievement points for unit; used by INSPECT_ACHIEVEMENT_READY handler.
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

-- Fetch Total RP 3 profile fields for a unit token. Returns a table of RP data
-- or nil when TRP3 is not loaded / the unit has no TRP3 profile.
-- All access is pcall-wrapped for Midnight safety.
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
        -- Some TRP3 APIs return profile data flat, while others nest it under profile.player.
        local profileData = profile.player or profile
        local char   = profileData.characteristics or {}
        local status = profileData.character       or {}
        local data   = {}
        local function cleanProfileValue(value)
            if not value or value == "" then return nil end
            local cleaned = strtrim(value)
            return cleaned ~= "" and cleaned or nil
        end
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
        data.customRace = cleanProfileValue(char.RA)
        data.customClass = cleanProfileValue(char.CL)
        -- Full title (shown beneath the name line)
        if char.FT and char.FT ~= "" then
            local ft = strtrim(char.FT)
            if ft ~= "" then data.fullTitle = "< " .. ft .. " >" end
        end
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
                if not data.customRace and player.GetCustomRace then
                    data.customRace = cleanProfileValue(player:GetCustomRace())
                end
                if not data.customClass and player.GetCustomClass then
                    data.customClass = cleanProfileValue(player:GetCustomClass())
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

-- Process player unit tooltip. Full enrichment: name, class/spec/role, PvP, badges, stats, mount.
-- @param unit string Unit token (e.g. "mouseover")
-- @param tooltip table GameTooltip
-- @return boolean true if processed
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
        local wowTitlePart, wowTitlePosition
        if ShowCharacterTitle() then
            pcall(function()
                local titlePart, namePart, titlePosition = GetCharacterTitleParts(unit, nameLeft)
                if not titlePart or not namePart then return end
                wowTitlePart, wowTitlePosition = titlePart, titlePosition
                local baseName, realmSuffix = GetRealmDisplayParts(namePart)
                displayText = FormatTitleNameSpan(titlePart, baseName, titlePosition, nameR, nameG, nameB, useGradient, realmSuffix)
            end)
        end
        if not displayText then
            local namePart = GetPlayerDisplayName(unit, nameLeft)
            if useGradient then
                -- Force vertex colour to white so our |cff escapes aren't
                -- dampened by Blizzard's SetTextColor.
                displayText = Insight.BuildNameGradient(Insight.StripColourEscapes(namePart), nameR, nameG, nameB, GetPlayerGradientBias())
                nameLeft:SetTextColor(1, 1, 1, 1)
            else
                displayText = namePart
                nameLeft:SetTextColor(nameR, nameG, nameB)
            end
        end
        -- TRP3 RP name: replace WoW character name with RP name when available
        if trp3Data and trp3Data.rpName and ShowTRP3RPName() then
            if wowTitlePart and ShowWowTitleWithTRP3() then
                -- Keep the WoW character title around the RP name (option-gated)
                displayText = FormatTitleNameSpan(wowTitlePart, trp3Data.rpName, wowTitlePosition, nameR, nameG, nameB, useGradient, "")
                if useGradient then
                    nameLeft:SetTextColor(1, 1, 1, 1)
                else
                    nameLeft:SetTextColor(nameR, nameG, nameB)
                end
            elseif useGradient then
                displayText = Insight.BuildNameGradient(trp3Data.rpName, nameR, nameG, nameB, GetPlayerGradientBias())
                nameLeft:SetTextColor(1, 1, 1, 1)
            else
                displayText = FormatNameSpan(trp3Data.rpName, nameR, nameG, nameB, false)
                nameLeft:SetTextColor(nameR, nameG, nameB)
            end
        end
        -- Build TRP3 suffix: IC/OOC badge only (pronouns moved to title line)
        local trp3Suffix = ""
        if trp3Data then
            if trp3Data.isIC ~= nil and ShowTRP3ICStatus() then
                if ShowTRP3ICStatusIcon() then
                    trp3Suffix = trp3Suffix .. (trp3Data.isIC
                        and " |TInterface\\Common\\Indicator-Green:12:12:0:0|t"
                        or  " |TInterface\\Common\\Indicator-Red:12:12:0:0|t")
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
    if Insight.GetPlayerTooltipBorderColor then
        tooltip:SetBackdropBorderColor(Insight.GetPlayerTooltipBorderColor(unit, classColor, trp3Data))
    end

    -- Move native identity lines down when the matching TRP3 toggle is active.
    -- Race/class: active whenever trp3Data exists (even without custom fields — WoW data shown in TRP3 format).
    -- Bottom rendering uses TRP3 data when present, then native data as fallback.
    local moveRaceClassToBottom = ShowTRP3() and ShowTRP3RaceClass()
    local moveGuildToBottom = ShowTRP3() and ShowTRP3Guild()

    -- 3. Clean up Blizzard lines (skip line 1; name already styled)
    -- When TRP3 title/pronouns need a line, we reuse the first cleared native line
    -- (guild or race/class) so no empty FontString gap appears between name and title.
    local trp3IdentityLine = nil
    local needsTrp3IdentityLine = trp3Data and (
        (trp3Data.fullTitle and ShowTRP3Title()) or
        (trp3Data.pronouns  and ShowTRP3Pronouns())
    )
    local classLineStyled = false
    local guildLineStyled = false
    local guildRankDisplay = ShowGuildRank() and GetGuildRankDisplay(guildRankName, guildRealm)
    local raceNameSafe = nil
    pcall(function()
        -- UnitRace returns a secret string in TWW Midnight; pass through SafePlainString
        -- (same treatment as classNameSafe) so text:find() works without erroring.
        raceNameSafe = SafePlainString(UnitRace(unit))
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
                if moveGuildToBottom then
                    if needsTrp3IdentityLine and not trp3IdentityLine then trp3IdentityLine = lineLeft end
                    lineLeft:SetText("")
                else
                    local guildDisplayLine = GetGuildDisplayLine(guildName, guildRankDisplay)
                    if guildDisplayLine then
                        lineLeft:SetText(guildDisplayLine)
                        lineLeft:SetTextColor(1, 1, 1)
                    end
                end
            elseif not raceIconStyled and raceNameSafe and text ~= "" and text:find(raceNameSafe, 1, true) and not text:find("|T", 1, true) and not text:find("|A", 1, true) then
                raceIconStyled = true
                if moveRaceClassToBottom then
                    if needsTrp3IdentityLine and not trp3IdentityLine then trp3IdentityLine = lineLeft end
                    lineLeft:SetText("")
                elseif raceIconPrefix ~= "" then
                    lineLeft:SetText(raceIconPrefix .. text)
                end
            elseif classNameSafe and text ~= "" and text:find(classNameSafe, 1, true) then
                if moveRaceClassToBottom then
                    if needsTrp3IdentityLine and not trp3IdentityLine then trp3IdentityLine = lineLeft end
                    lineLeft:SetText("")
                    classLineStyled = true
                    do return end
                end
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

    if guildName and guildName ~= "" and not guildLineStyled and not moveGuildToBottom then
        Insight.TagLines(tooltip, "identity", function()
            tooltip:AddLine(GetGuildDisplayLine(guildName, guildRankDisplay), 1, 1, 1)
        end)
    end

    if trp3Data and trp3Data.fullTitle and ShowTRP3Title() then
        local titleLine = trp3Data.fullTitle
        if trp3Data.pronouns and ShowTRP3Pronouns() then
            titleLine = titleLine .. "  |cffaaaaaa(" .. ProperCasePronouns(trp3Data.pronouns) .. ")|r"
        end
        if trp3IdentityLine then
            trp3IdentityLine:SetText(titleLine)
            trp3IdentityLine:SetTextColor(0.75, 0.85, 1.0, 1)
        else
            Insight.TagLines(tooltip, "identity", function()
                tooltip:AddLine(titleLine, 0.75, 0.85, 1.0)
            end)
        end
    elseif trp3Data and trp3Data.pronouns and ShowTRP3Pronouns() then
        local pronounsText = "|cffaaaaaa(" .. ProperCasePronouns(trp3Data.pronouns) .. ")|r"
        if trp3IdentityLine then
            trp3IdentityLine:SetText(pronounsText)
            trp3IdentityLine:SetTextColor(1, 1, 1, 1)
        else
            Insight.TagLines(tooltip, "identity", function()
                tooltip:AddLine(pronounsText, 1, 1, 1)
            end)
        end
    end

    if moveRaceClassToBottom then
        Insight.TagLines(tooltip, "identity", function()
            local raceClassLine = BuildCombinedRaceClassLine(trp3Data, classColor, unit, { race = raceNameSafe, class = classNameSafe })
            if raceClassLine and raceClassLine ~= "" then
                tooltip:AddLine(raceClassLine, 1, 1, 1)
            end
        end)
    end

    if moveGuildToBottom then
        Insight.TagLines(tooltip, "identity", function()
            local guildLine
            if trp3Data and trp3Data.customGuild and trp3Data.customGuild ~= "" and trp3Data.customGuildRank and trp3Data.customGuildRank ~= "" then
                guildLine = trp3Data.customGuildRank .. " of |cff00ccff" .. trp3Data.customGuild .. "|r"
            elseif trp3Data and trp3Data.customGuild and trp3Data.customGuild ~= "" then
                guildLine = "|cff00ccff" .. trp3Data.customGuild .. "|r"
            else
                guildLine = GetGuildDisplayLine(guildName, guildRankDisplay)
            end
            if guildLine and guildLine ~= "" then
                tooltip:AddLine(guildLine, 1, 1, 1)
            end
        end)
    end

    -- 4. Status badges — below identity block
    Insight.AddStatusBadgesBlock(tooltip, unit)

    -- 5. Ratings block (M+ score, honour level, achievement points, item level)
    Insight.AddStatsBlock(tooltip, unit, cached, sepR, sepG, sepB)

    -- 5b. Targeting line
    Insight.AddTargetingBlock(tooltip, unit, sepR, sepG, sepB)

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

-- Gather the logged-in character's identity for the preview, with static
-- fallbacks for anything unavailable (early load, missing APIs). All reads
-- are pcall-wrapped: previews can refresh from tainted execution paths.
local function GetLivePlayerPreviewData()
    local d = {
        name = "Horizonaut", realm = "Stormrage",
        classFile = "DEATHKNIGHT", className = "Death Knight",
        classR = 0.77, classG = 0.12, classB = 0.23,
        raceName = "Human", raceFile = "human-male",
        level = 80, faction = "Alliance",
        guildName = "Ascension", guildRank = "Officer",
        title = nil, specName = nil, specIcon = nil, role = nil,
        mythicScore = 2847, honorLevel = 247, achievementPoints = 28650, ilvl = 639,
    }
    pcall(function()
        local n = UnitName("player")
        if n and n ~= "" then d.name = n end
        local realm = GetRealmName and GetRealmName()
        if realm and realm ~= "" then d.realm = realm end
        local className, classFile = UnitClass("player")
        if classFile then
            d.classFile = classFile
            if className then d.className = className end
            local cc = C_ClassColor and C_ClassColor.GetClassColor and C_ClassColor.GetClassColor(classFile)
            if cc then d.classR, d.classG, d.classB = cc.r, cc.g, cc.b end
        end
        local raceName, raceFile = UnitRace("player")
        if raceName then d.raceName = raceName end
        if raceFile then
            d.raceFile = raceFile:lower() .. ((UnitSex("player") == 3) and "-female" or "-male")
        end
        local lvl = UnitLevel("player")
        if lvl and lvl > 0 then d.level = lvl end
        local fac = UnitFactionGroup("player")
        if fac == "Horde" or fac == "Alliance" then d.faction = fac end
        local gName, gRank = GetGuildInfo("player")
        if gName and gName ~= "" then
            d.guildName = gName
            d.guildRank = gRank or d.guildRank
        end
        if GetCurrentTitle and GetTitleName then
            local t = GetTitleName(GetCurrentTitle())
            if t and t ~= "" then d.title = t:gsub("^%s+", ""):gsub("[%s,]+$", "") end
        end
        if GetSpecialization and GetSpecializationInfo then
            local spec = GetSpecialization()
            if spec then
                local _, specName, _, specIcon, role = GetSpecializationInfo(spec)
                d.specName, d.specIcon, d.role = specName, specIcon, role
            end
        end
    end)
    pcall(function()
        local summary = C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary
            and C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
        if summary and summary.currentSeasonScore and summary.currentSeasonScore > 0 then
            d.mythicScore = summary.currentSeasonScore
        end
    end)
    pcall(function()
        local h = UnitHonorLevel and UnitHonorLevel("player")
        if h and h > 0 then d.honorLevel = h end
    end)
    pcall(function()
        local a = GetTotalAchievementPoints and GetTotalAchievementPoints()
        if a and a > 0 then d.achievementPoints = a end
    end)
    pcall(function()
        local _, equipped = GetAverageItemLevel()
        if equipped and equipped > 0 then d.ilvl = math.floor(equipped + 0.5) end
    end)
    return d
end
Insight.GetLivePlayerPreviewData = GetLivePlayerPreviewData

-- Render sample player tooltip content for /insight test and dashboard preview.
-- Mirrors ProcessPlayerTooltip + block builders; each section gated by the same Show*() DB flags.
-- Identity mimics the logged-in character; the Aelindra TRP3 persona is used only
-- when TRP3 is enabled but no live own-profile data is available.
function Insight.RenderTestTooltipContent(tooltip)
    if not tooltip then return end
    local live = GetLivePlayerPreviewData()
    local testSepR, testSepG, testSepB = live.classR, live.classG, live.classB
    Insight.sepR, Insight.sepG, Insight.sepB = testSepR, testSepG, testSepB

    local showIcons = ShowIcons()

    -- TRP3: prefer the player's own live profile; fall back to the demo persona
    -- (which exists so every TRP3 option visibly reacts in the preview).
    local previewTRP3, trp3IsLive
    if TRP3_API ~= nil and ShowTRP3() then
        if Insight.GetTRP3PlayerData then
            local ok, ownProfile = pcall(Insight.GetTRP3PlayerData, "player")
            if ok and type(ownProfile) == "table" and ownProfile.rpName then
                previewTRP3, trp3IsLive = ownProfile, true
            end
        end
        if not previewTRP3 then
            previewTRP3 = {
                rpName      = "Aelindra Dawnwhisper",
                pronouns    = "she/her",
                isIC        = true,
                customColorR = 0.72, customColorG = 0.53, customColorB = 1.0,
                customRace  = "Sin'dorei",
                customClass = "Arcane Weaver",
                fullTitle   = "< Keeper of the Dawnguard >",
                customGuild = "Dawnguard Covenant",
                customGuildRank = "Keeper",
                currently   = "Studying ancient texts in the library, searching for answers...",
                icon        = "spell_arcane_arcane01",
            }
        end
    end
    -- The demo persona is a Blood Elf Horde character; with live data (or no
    -- TRP3) everything mimics the logged-in character.
    local useLiveIdentity = (previewTRP3 == nil) or (trp3IsLive == true)

    local previewFaction = useLiveIdentity and live.faction or "Horde"
    local fc = Insight.FACTION_COLORS[previewFaction]
    local nameModeRaw = addon.GetDB("insightPlayerNameColor", "faction")
    local nameMode = (nameModeRaw == "class") and "class" or "faction"
    local nameR, nameG, nameB = fc[1], fc[2], fc[3]
    if nameMode == "class" then
        nameR, nameG, nameB = testSepR, testSepG, testSepB
    end
    local facIcon = showIcons and (Insight.FACTION_ICONS[previewFaction] or "") or ""

    local useGradient = (nameMode == "class")
        and addon.GetDB("insightPlayerNameGradient", false)

    -- 1. Name line (character title optional — same as live)
    -- Demo persona: Aelindra (so the RP name toggle clearly shows
    -- "Aelindra" → "Aelindra Dawnwhisper"); otherwise the live character.
    local previewName, previewRealmSuffix
    if previewTRP3 and not trp3IsLive then
        previewName, previewRealmSuffix = "Aelindra", ""
    else
        previewName, previewRealmSuffix = GetRealmDisplayParts(live.name .. "-" .. live.realm)
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
        nameSpan = Insight.BuildNameGradient(displayName, nameR, nameG, nameB, GetPlayerGradientBias())
    else
        nameSpan = FormatNameSpan(displayName, nameR, nameG, nameB, false)
    end

    -- TRP3 IC/OOC suffix
    local trp3Suffix = ""
    if previewTRP3 then
        if previewTRP3.isIC ~= nil and ShowTRP3ICStatus() then
            if ShowTRP3ICStatusIcon() then
                trp3Suffix = trp3Suffix .. (previewTRP3.isIC
                    and " |TInterface\\Common\\Indicator-Green:12:12:0:0|t"
                    or  " |TInterface\\Common\\Indicator-Red:12:12:0:0|t")
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
    -- When the RP name replaces the WoW name, the WoW title obeys the same
    -- show/hide/modifier option as the live tooltip (modifier counts as shown
    -- in previews via Insight.previewRendering).
    local trp3NameActive = previewTRP3 and previewTRP3.rpName and ShowTRP3RPName()
    if ShowCharacterTitle() and (not trp3NameActive or ShowWowTitleWithTRP3()) then
        -- Live character title when one is set; sample titles keep the option visible otherwise.
        local previewTitle = (useLiveIdentity and live.title)
            or (previewTRP3 and not trp3IsLive and "Arcanist")
            or "Duelist"
        local titleSpan = FormatTitleNameSpan(previewTitle, displayName, "prefix", nameR, nameG, nameB, useGradient, "")
        tooltip:AddLine(namePrefix .. titleSpan .. inlineStatusTag .. trp3Suffix, nameR, nameG, nameB)
    else
        if useGradient then
            tooltip:AddLine(namePrefix .. nameSpan .. inlineStatusTag .. trp3Suffix, 1, 1, 1)
        else
            tooltip:AddLine(namePrefix .. nameSpan .. inlineStatusTag .. trp3Suffix, nameR, nameG, nameB)
        end
    end

    -- 2. Guild / Full Title / Race+Class block
    local previewMoveGuildToBottom = previewTRP3 and ShowTRP3Guild()
    local previewMoveRaceClassToBottom = previewTRP3 and ShowTRP3RaceClass()
    local previewClassCol = { r = testSepR, g = testSepG, b = testSepB }

    local previewHasTitle = previewTRP3 and previewTRP3.fullTitle and ShowTRP3Title()
    local previewHasPronouns = previewTRP3 and previewTRP3.pronouns and ShowTRP3Pronouns()
    if previewHasTitle then
        local titleLine = previewTRP3.fullTitle
        if previewHasPronouns then
            titleLine = titleLine .. "  |cffaaaaaa(" .. ProperCasePronouns(previewTRP3.pronouns) .. ")|r"
        end
        tooltip:AddLine(titleLine, 0.75, 0.85, 1.0)
    elseif previewHasPronouns then
        tooltip:AddLine("|cffaaaaaa(" .. ProperCasePronouns(previewTRP3.pronouns) .. ")|r", 1, 1, 1)
    else
        -- WoW guild shown in TRP3 "Rank of Guild" format (TRP3 active) or legacy format (not active)
        if previewMoveGuildToBottom then
            -- Moved to the bottom identity block.
        elseif previewTRP3 then
            local previewGuildLine = ShowGuildRank()
                and (live.guildRank .. " of |cff00ccff" .. live.guildName .. "|r")
                or ("|cff00ccff" .. live.guildName .. "|r")
            tooltip:AddLine(previewGuildLine, 1, 1, 1)
        elseif ShowGuildRank() then
            tooltip:AddLine("<" .. live.guildName .. ">  |cffaaaaaa" .. live.guildRank .. "|r", testSepR, testSepG, testSepB)
        else
            tooltip:AddLine("<" .. live.guildName .. ">", testSepR, testSepG, testSepB)
        end
    end

    local testIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
    local previewRaceFile = useLiveIdentity and live.raceFile or "bloodelf-female"
    local previewRaceName = useLiveIdentity and live.raceName or "Blood Elf"
    local raceIconStr = ShowRaceIcons() and ("|T" .. RACE_ICON_PATH_PREFIX .. previewRaceFile .. ".tga:" .. testIconPx .. ":" .. testIconPx .. ":0:0|t ") or ""
    if not previewMoveRaceClassToBottom then
        tooltip:AddLine(raceIconStr .. "Level " .. live.level .. " " .. previewRaceName, 1, 0.82, 0)
    end
    -- TRP3 RP guild — "Rank of Guild" format

    local classIconStr = ""
    if showIcons then
        local src = Insight.GetClassIconSource and Insight.GetClassIconSource() or "custom"
        if src == "specoverride" then
            -- Spec Override: the live spec icon when known, Blood DK sample otherwise.
            if live.specIcon then
                classIconStr = SpecIconMarkup(live.specIcon, testIconPx)
            else
                classIconStr = SpecIconMarkup("Interface\\Icons\\spell_deathknight_bloodpresence", testIconPx)
            end
        else
            classIconStr = (Insight.GetClassIconTexture and Insight.GetClassIconTexture(live.classFile)) or ""
            if classIconStr == "" then
                classIconStr = "|TInterface\\Icons\\spell_deathknight_bloodpresence:" .. testIconPx .. ":" .. testIconPx .. ":0:0|t "
            end
        end
    end
    local PREVIEW_ROLE_LABELS = { TANK = "Tank", HEALER = "Healer", DAMAGER = "DPS" }
    local previewRoleSuffix = ""
    if ShowSpecRole() then
        local roleKey = (live.role and PREVIEW_ROLE_LABELS[live.role]) and live.role or "TANK"
        local previewRc = Insight.ROLE_COLORS[roleKey] or Insight.ROLE_COLORS["TANK"]
        local previewRoleHex = string.format("%02x%02x%02x", math.floor(previewRc[1] * 255), math.floor(previewRc[2] * 255), math.floor(previewRc[3] * 255))
        previewRoleSuffix = "  |cff" .. previewRoleHex .. PREVIEW_ROLE_LABELS[roleKey] .. "|r"
    end
    local previewSpecClass = (live.specName and (live.specName .. " ") or "") .. live.className
    if not previewMoveRaceClassToBottom then
        tooltip:AddLine(classIconStr .. previewSpecClass .. previewRoleSuffix, testSepR, testSepG, testSepB)
    end

    -- Live tooltips leave a blank gap here (the cleared native guild/race/class
    -- lines); mirror it so the preview spacing matches in-game.
    if previewTRP3 and (previewMoveRaceClassToBottom or previewMoveGuildToBottom) then
        tooltip:AddLine(" ")
    end

    -- 3a. TRP3 identity fallback (race/class and guild displaced to bottom)
    if previewMoveRaceClassToBottom then
        local raceClassLine = BuildCombinedRaceClassLine(previewTRP3, previewClassCol, nil,
            { race = previewRaceName, class = live.className })
        if raceClassLine and raceClassLine ~= "" then
            tooltip:AddLine(raceClassLine, 1, 1, 1)
        end
    end
    if previewMoveGuildToBottom then
        local guildLine
        if previewTRP3.customGuild and previewTRP3.customGuild ~= "" and previewTRP3.customGuildRank and previewTRP3.customGuildRank ~= "" then
            guildLine = previewTRP3.customGuildRank .. " of |cff00ccff" .. previewTRP3.customGuild .. "|r"
        elseif previewTRP3.customGuild and previewTRP3.customGuild ~= "" then
            guildLine = "|cff00ccff" .. previewTRP3.customGuild .. "|r"
        else
            guildLine = ShowGuildRank()
                and ("<" .. live.guildName .. ">  |cffaaaaaa" .. live.guildRank .. "|r")
                or ("<" .. live.guildName .. ">")
        end
        tooltip:AddLine(guildLine, 1, 1, 1)
    end

    -- 4. Status badges — below identity block
    if ShowStatusBadges() then
        local previewBadges = {}
        if ShowStatusBadgeAFK() and not ShowStatusBadgeAFKInHeader() then previewBadges[#previewBadges + 1] = "|cffffff55[AFK]|r"         end
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

    -- 5. Ratings (M+ score, honour level, achievement points, item level)
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
            tooltip:AddLine(icon .. "M+ Score: " .. Insight.FormatNumberWithCommas(live.mythicScore), Insight.MythicScoreColor(live.mythicScore))
        end)
    end
    if ShowHonorLevel() then
        ensureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.HONOR_ICON or ""
            tooltip:AddLine(icon .. "Honor Level: " .. Insight.FormatNumberWithCommas(live.honorLevel), fc[1], fc[2], fc[3])
        end)
    end

    if ShowAchievementPoints() then
        ensureStatsSep()
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.ACHIEVEMENT_ICON or ""
            tooltip:AddLine(icon .. "Achievement Points: " .. Insight.FormatNumberWithCommas(live.achievementPoints), Insight.ACHIEVEMENT_POINTS_COLOR[1], Insight.ACHIEVEMENT_POINTS_COLOR[2], Insight.ACHIEVEMENT_POINTS_COLOR[3])
        end)
    end

    if ShowIlvl() then
        Insight.AddSectionSeparator(tooltip)
        Insight.TagLines(tooltip, "stats", function()
            local icon = (showIcons and ShowRatingsIcons()) and Insight.ILVL_ICON or ""
            tooltip:AddLine(icon .. "Item Level: " .. Insight.FormatNumberWithCommas(live.ilvl), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
        end)
    end

    -- 5b. Targeting line
    if ShowTargeting() then
        Insight.AddSectionSeparator(tooltip)
        Insight.TagLines(tooltip, "stats", function()
            tooltip:AddLine("Targeting: Arthas", 1, 1, 1)
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
