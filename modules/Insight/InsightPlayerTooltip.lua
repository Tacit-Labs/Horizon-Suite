--[[
    Horizon Suite - Horizon Insight (Player Tooltip)
    Player-specific tooltip enrichment: class/spec/role, PvP title, honor, badges, stats, mount block, inspect.
]]


local addon = _G.HorizonSuite

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local INSPECT_THROTTLE = 1.5
local CACHE_TTL        = 300
local CACHE_MAX        = 100

local MOUNT_READY_TEX  = "Interface\\RaidFrame\\ReadyCheck-Ready"
local MOUNT_NOTREADY_TEX = "Interface\\RaidFrame\\ReadyCheck-NotReady"
local MOUNT_OWN_ICON_BASE = 14

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

local function ShowMount()            return addon.GetDB("insightShowMount",            true)  end
local function ShowIlvl()             return addon.GetDB("insightShowIlvl",             true)  end
local function ShowSpecRole()          return addon.GetDB("insightShowSpecRole",          true)  end
local function ShowCharacterTitle()   return addon.GetDB("insightShowCharacterTitle",   true)  end
local function ShowStatusBadges()     return addon.GetDB("insightShowStatusBadges",     true)  end
local function ShowMythicScore()  return addon.GetDB("insightShowMythicScore",  true)  end
local function ShowGuildRank()    return addon.GetDB("insightShowGuildRank",    true)  end
local function ShowHonorLevel()  return addon.GetDB("insightShowHonorLevel",   true)  end
local function ShowIcons()       return addon.GetDB("insightShowIcons",       true)  end

-- ============================================================================
-- INSPECT CACHE
-- ============================================================================

local inspectCache = {}
Insight.inspectCache = inspectCache

local lastInspect = 0

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
        return nil, "|cff55ff55" .. ((L and L["INSIGHT_MOUNT_OWNED"]) or "You own this mount") .. "|r"
    end
    return nil, "|cffff5555" .. ((L and L["INSIGHT_MOUNT_NOT_OWNED"]) or "You don't own this mount") .. "|r"
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
            tooltip:AddLine("Honor Level " .. Insight.FormatNumberWithCommas(honorLevel), 0.85, 0.70, 1.00)
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
        if UnitAffectingCombat(unit) then badges[#badges + 1] = "|cffff4444[Combat]|r"      end
        if UnitIsAFK(unit)           then badges[#badges + 1] = "|cffffff55[AFK]|r"         end
        if UnitIsDND(unit)           then badges[#badges + 1] = "|cffaaaaaa[DND]|r"         end
        if UnitIsPVP(unit)           then badges[#badges + 1] = "|cffff8c00[PvP]|r"         end
        if UnitInRaid(unit)          then badges[#badges + 1] = "|cff88ddff[Raid]|r"
        elseif UnitInParty(unit)     then badges[#badges + 1] = "|cff88ddff[Party]|r"       end
        if C_FriendList and C_FriendList.IsFriend then
            local isFriend = false
            pcall(function()
                local g = UnitGUID(unit)
                if C_FriendList.IsFriend(g) then
                    isFriend = true
                else
                    isFriend = false
                end
            end)
            if isFriend then
                badges[#badges + 1] = "|cff55ff55[Friend]|r"
            end
        end
        local targetingYou = false
        pcall(function()
            if UnitIsUnit("mouseoverTarget", "player") then
                targetingYou = true
            else
                targetingYou = false
            end
        end)
        if targetingYou then
            badges[#badges + 1] = "|cffff4466[Targeting You]|r"
        end
    end)
    if #badges > 0 then
        Insight.TagLines(tooltip, "badges", function()
            tooltip:AddLine(table.concat(badges, "  "), 1, 1, 1)
        end)
    end
end

--- Add stats block (M+ score, item level) to tooltip. Returns ensureStatsSep function for optional stats.
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
                tooltip:AddLine((ShowIcons() and Insight.MYTHIC_ICON or "") .. "M+ Score: " .. Insight.FormatNumberWithCommas(score), r, g, b)
            end)
        end
    end

    if cached then
        if ShowIlvl() and cached.ilvl then
            EnsureStatsSep()
            Insight.TagLines(tooltip, "stats", function()
                tooltip:AddLine("Item Level: " .. Insight.FormatNumberWithCommas(cached.ilvl), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
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
        if not isSelf and (ShowIlvl() or ShowSpecRole()) then
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

    local className, classFile, classColor, guildName, guildRankName
    pcall(function()
        className, classFile = UnitClass(unit)
        classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
        guildName, guildRankName = GetGuildInfo(unit)
    end)
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
        local useGradient = (nameMode == "class")
            and addon.GetDB("insightPlayerNameGradient", false)
        if ShowCharacterTitle() then
            -- Midnight: never compare or string-op Unit* name returns outside pcall (secret strings).
            pcall(function()
                local pvpName, baseName = UnitPVPName(unit), UnitName(unit)
                local namesDiffer = false
                pcall(function()
                    namesDiffer = (pvpName ~= baseName)
                end)
                if not namesDiffer then return end
                local idx = pvpName:find(baseName, 1, true)
                if not idx or idx <= 1 then return end
                local titlePart = pvpName:sub(1, idx - 1):gsub("%s+$", "")
                local namePart = ""
                pcall(function()
                    local okB, sb = pcall(tostring, baseName)
                    if okB and type(sb) == "string" then
                        namePart = sb
                    end
                end)
                pcall(function()
                    local n = GetUnitName(unit, true)
                    local okT, s = pcall(tostring, n)
                    if okT and type(s) == "string" and s ~= "" then
                        namePart = s
                    end
                end)
                local tc = addon.GetDB("insightTitleColor", nil)
                if not (tc and type(tc) == "table" and tc[1] and tc[2] and tc[3]) then
                    local r = addon.GetDB("insightTitleColorR", nil)
                    local g = addon.GetDB("insightTitleColorG", nil)
                    local b = addon.GetDB("insightTitleColorB", nil)
                    tc = (r and g and b) and { r, g, b } or Insight.TITLE_COLOR
                end
                local titleHex = string.format("%02x%02x%02x",
                    math.floor(tc[1] * 255), math.floor(tc[2] * 255), math.floor(tc[3] * 255))
                displayText = "|cff" .. titleHex .. titlePart .. "|r " .. FormatNameSpan(namePart, nameR, nameG, nameB, useGradient)
            end)
        end
        if not displayText then
            local namePart
            pcall(function()
                local n = GetUnitName(unit, true)
                local okT, s = pcall(tostring, n)
                if okT and type(s) == "string" and s ~= "" then
                    namePart = s
                end
            end)
            if not namePart or namePart == "" then
                namePart = Insight.SafeGetFontText(nameLeft) or ""
            end
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
        nameLeft:SetText(icon .. displayText)
    end

    -- 2. Border tint
    if classColor then
        tooltip:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.60)
    end

    -- 3. Clean up Blizzard lines (skip line 1; name already styled)
    local classLineStyled = false
    Insight.ForTooltipLines(tooltip, function(j, lineLeft, _lineRight)
        if j < 2 or not lineLeft then return end
        pcall(function()
            local text = lineLeft:GetText()
            if not text then return end

            if text:find(" %(Player%)") then
                text = text:gsub(" %(Player%)", "")
                lineLeft:SetText(text)
            end

            if text == "Horde" or text == "Alliance" then
                lineLeft:SetText("")
            elseif className and text ~= "" and text:find(className, 1, true) and classLineStyled then
                lineLeft:SetText("")
            elseif guildName and text == "<" .. guildName .. ">" then
                if ShowGuildRank() and guildRankName and guildRankName ~= "" then
                    lineLeft:SetText(text .. "  |cffaaaaaa" .. guildRankName .. "|r")
                end
            elseif className and text ~= "" and text:find(className, 1, true) then
                classLineStyled = true
                if classColor then
                    lineLeft:SetTextColor(classColor.r, classColor.g, classColor.b)
                end
                local iconPrefix = ""
                if ShowIcons() then
                    local lineIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
                    local classIcon = Insight.GetClassIconTexture and Insight.GetClassIconTexture(classFile)
                    if classIcon then
                        iconPrefix = classIcon
                    elseif ShowSpecRole() and cached and cached.specIcon then
                        iconPrefix = "|T" .. cached.specIcon .. ":" .. lineIconPx .. ":" .. lineIconPx .. ":0:0|t "
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

    -- 4. Status badges (part of identity section)
    Insight.AddStatusBadgesBlock(tooltip, unit)

    -- Separator: identity block → PvP block (only when PvP will add content)
    if PvPHasContent(unit) then
        Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
    end

    -- 5. PvP title + honor level
    Insight.AddPvPBlock(tooltip, unit, sepR, sepG, sepB)

    -- 6. Stats block (M+ score, item level)
    Insight.AddStatsBlock(tooltip, unit, cached, sepR, sepG, sepB)

    -- 7. Mount block
    Insight.AddMountBlock(tooltip, unit, sepR, sepG, sepB)

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

    -- 1. Name line (character title optional — same as live)
    local nameSpan = FormatNameSpan("Horizonaut-Stormrage", nameR, nameG, nameB, useGradient)
    if ShowCharacterTitle() then
        local tc = addon.GetDB("insightTitleColor", nil)
        if not (tc and type(tc) == "table" and tc[1] and tc[2] and tc[3]) then
            local r = addon.GetDB("insightTitleColorR", nil)
            local g = addon.GetDB("insightTitleColorG", nil)
            local b = addon.GetDB("insightTitleColorB", nil)
            tc = (r and g and b) and { r, g, b } or Insight.TITLE_COLOR
        end
        local titleHex = string.format("%02x%02x%02x",
            math.floor(tc[1] * 255), math.floor(tc[2] * 255), math.floor(tc[3] * 255))
        tooltip:AddLine(facIcon .. "|cff" .. titleHex .. "Duelist|r " .. nameSpan, nameR, nameG, nameB)
    else
        tooltip:AddLine(facIcon .. nameSpan, nameR, nameG, nameB)
    end

    -- 2. Guild (rank line only when guild rank toggle on — live augments guild line)
    if ShowGuildRank() then
        tooltip:AddLine("<Ascension>  |cffaaaaaaOfficer|r", testSepR, testSepG, testSepB)
    else
        tooltip:AddLine("<Ascension>", testSepR, testSepG, testSepB)
    end

    tooltip:AddLine("Level 80 Human", 1, 0.82, 0)

    local rc = Insight.ROLE_COLORS["TANK"]
    local roleHex = string.format("%02x%02x%02x", math.floor(rc[1] * 255), math.floor(rc[2] * 255), math.floor(rc[3] * 255))
    local testIconPx = (addon.GetInsightClassIconDisplaySize and addon.GetInsightClassIconDisplaySize()) or 14
    local classIconStr = (showIcons and Insight.GetClassIconTexture and Insight.GetClassIconTexture("DEATHKNIGHT")) or ""
    if classIconStr == "" and showIcons then
        classIconStr = "|TInterface\\Icons\\spell_deathknight_bloodpresence:" .. testIconPx .. ":" .. testIconPx .. ":0:0|t "
    end
    tooltip:AddLine(
        classIconStr .. "Blood Death Knight  |cff" .. roleHex .. "Tank|r",
        0.77, 0.12, 0.23)

    -- 4. Status badges (AddStatusBadgesBlock)
    if ShowStatusBadges() then
        tooltip:AddLine("|cffff4444[Combat]|r  |cffff8c00[PvP]|r  |cff88ddff[Party]|r  |cff55ff55[Friend]|r  |cffff4466[Targeting You]|r", 1, 1, 1)
    end

    -- 5. Honor (PvP block — separator only when honor will show, like PvPHasContent)
    if ShowHonorLevel() then
        Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
        tooltip:AddLine("Honor Level " .. Insight.FormatNumberWithCommas(247), 0.85, 0.70, 1.00)
    end

    -- 6. Stats (M+ / ilvl — EnsureStatsSep pattern from AddStatsBlock)
    local hasStats = false
    local function ensureStatsSep()
        if not hasStats then
            Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
            hasStats = true
        end
    end
    if ShowMythicScore() then
        ensureStatsSep()
        tooltip:AddLine((showIcons and Insight.MYTHIC_ICON or "") .. "M+ Score: " .. Insight.FormatNumberWithCommas(2847), Insight.MythicScoreColor(2847))
    end
    if ShowIlvl() then
        ensureStatsSep()
        tooltip:AddLine("Item Level: " .. Insight.FormatNumberWithCommas(639), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
    end

    -- 7. Mount block (mirrors AddMountBlock: source only when not collected; ownership from setting)
    if ShowMount() then
        Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
        local mountIconStr = showIcons and "|TInterface\\Icons\\ability_mount_drake_proto:14:14:0:0|t " or ""
        local ownSuffix, ownTextLine = GetMountOwnershipDisplay(false)
        tooltip:AddLine(
            mountIconStr .. "Reins of the Thundering Cobalt Cloud Serpent" .. (ownSuffix or ""),
            Insight.MOUNT_COLOR[1], Insight.MOUNT_COLOR[2], Insight.MOUNT_COLOR[3])
        -- Uncollected sample mount: source line shown; collected mounts omit source in live tooltips.
        tooltip:AddLine("Drop: Sha of Anger", Insight.MOUNT_SRC_COLOR[1], Insight.MOUNT_SRC_COLOR[2], Insight.MOUNT_SRC_COLOR[3])
        if ownTextLine then
            tooltip:AddLine(ownTextLine, 1, 1, 1)
        end
    end
end

addon.Insight = Insight
