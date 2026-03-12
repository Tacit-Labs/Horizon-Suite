--[[
    Horizon Suite - Horizon Insight (Player Tooltip)
    Player-specific tooltip enrichment: class/spec/role, PvP title, honor, badges, stats, mount block, inspect.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

addon.Insight = addon.Insight or {}
local Insight = addon.Insight

local INSPECT_THROTTLE = 1.5
local CACHE_TTL        = 300
local CACHE_MAX        = 100

local function IsEnabled()
    return addon:IsModuleEnabled("insight")
end

local function ShowMount()        return addon.GetDB("insightShowMount",        true)  end
local function ShowIlvl()         return addon.GetDB("insightShowIlvl",         true)  end
local function ShowPvPTitle()     return addon.GetDB("insightShowPvPTitle",     true)  end
local function ShowStatusBadges() return addon.GetDB("insightShowStatusBadges", true)  end
local function ShowMythicScore()  return addon.GetDB("insightShowMythicScore",  true)  end
local function ShowGuildRank()    return addon.GetDB("insightShowGuildRank",    true)  end
local function ShowHonorLevel()  return addon.GetDB("insightShowHonorLevel",   true)  end

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
-- SECTION BUILDERS (reused by ProcessPlayerTooltip and /insight test)
-- ============================================================================

--- Add PvP title and honor level block to tooltip.
function Insight.AddPvPBlock(tooltip, unit, sepR, sepG, sepB)
    if not ShowPvPTitle() and not ShowHonorLevel() then return end
    if ShowPvPTitle() then
        pcall(function()
            local pvpFullName = UnitPVPName(unit)
            local baseName    = UnitName(unit)
            if pvpFullName and baseName and pvpFullName ~= baseName then
                tooltip:AddLine(pvpFullName, Insight.TITLE_COLOR[1], Insight.TITLE_COLOR[2], Insight.TITLE_COLOR[3])
            end
        end)
    end
    if ShowHonorLevel() then
        pcall(function()
            local honorLevel = UnitHonorLevel(unit)
            if honorLevel and honorLevel > 0 then
                tooltip:AddLine("Honor Level " .. Insight.FormatNumberWithCommas(honorLevel), 0.85, 0.70, 1.00)
            end
        end)
    end
end

--- Add status badges block to tooltip.
function Insight.AddStatusBadgesBlock(tooltip, unit, guid)
    if not ShowStatusBadges() then return end
    local badges = {}
    pcall(function()
        if UnitAffectingCombat(unit) then badges[#badges + 1] = "|cffff4444[Combat]|r"      end
        if UnitIsAFK(unit)           then badges[#badges + 1] = "|cffffff55[AFK]|r"         end
        if UnitIsDND(unit)           then badges[#badges + 1] = "|cffaaaaaa[DND]|r"         end
        if UnitIsPVP(unit)           then badges[#badges + 1] = "|cffff8c00[PvP]|r"         end
        if UnitInRaid(unit)          then badges[#badges + 1] = "|cff88ddff[Raid]|r"
        elseif UnitInParty(unit)     then badges[#badges + 1] = "|cff88ddff[Party]|r"       end
        if C_FriendList and C_FriendList.IsFriend and guid and C_FriendList.IsFriend(guid) then
            badges[#badges + 1] = "|cff55ff55[Friend]|r"
        end
        local ok, isTargeting = pcall(UnitIsUnit, "mouseoverTarget", "player")
        if ok and isTargeting then
            badges[#badges + 1] = "|cffff4466[Targeting You]|r"
        end
    end)
    if #badges > 0 then
        tooltip:AddLine(table.concat(badges, "  "), 1, 1, 1)
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
            tooltip:AddLine(Insight.MYTHIC_ICON .. "M+ Score: " .. Insight.FormatNumberWithCommas(score), r, g, b)
        end
    end

    if cached then
        if ShowIlvl() and cached.ilvl then
            EnsureStatsSep()
            tooltip:AddLine("Item Level: " .. Insight.FormatNumberWithCommas(cached.ilvl), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
        end
    elseif not UnitIsUnit(unit, "player") then
        RequestInspect(unit)
    end
end

--- Add mount block to tooltip.
function Insight.AddMountBlock(tooltip, unit, sepR, sepG, sepB)
    if not ShowMount() then return end
    local mountOk, mount = pcall(GetPlayerMountInfo, unit)
    if not mountOk or not mount or not mount.name then return end

    local iconStr = mount.icon and ("|T" .. mount.icon .. ":14:14:0:0|t ") or ""
    Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)
    tooltip:AddLine(iconStr .. mount.name, Insight.MOUNT_COLOR[1], Insight.MOUNT_COLOR[2], Insight.MOUNT_COLOR[3])
    if mount.source and mount.source ~= "" then
        tooltip:AddLine(Insight.FormatNumbersInString(mount.source), Insight.MOUNT_SRC_COLOR[1], Insight.MOUNT_SRC_COLOR[2], Insight.MOUNT_SRC_COLOR[3])
    end
    if mount.isCollected == true then
        tooltip:AddLine("|cff55ff55You own this mount|r", 1, 1, 1)
    elseif mount.isCollected == false then
        tooltip:AddLine("|cffff5555You don't own this mount|r", 1, 1, 1)
    end
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
    if not IsEnabled() or not tooltip then return false end
    if not UnitIsPlayer(unit) then return false end

    local guid     = UnitGUID(unit)
    local className, classFile, classColor, guildName, guildRankName
    pcall(function()
        className, classFile = UnitClass(unit)
        classColor = classFile and C_ClassColor and C_ClassColor.GetClassColor(classFile)
        guildName, guildRankName = GetGuildInfo(unit)
    end)
    local sepR = (classColor and classColor.r) or Insight.SEP_COLOR[1]
    local sepG = (classColor and classColor.g) or Insight.SEP_COLOR[2]
    local sepB = (classColor and classColor.b) or Insight.SEP_COLOR[3]
    Insight.sepR, Insight.sepG, Insight.sepB = sepR, sepG, sepB
    local cached = guid and inspectCache[guid]

    -- Self-unit: populate inspect cache directly
    if not cached and UnitIsUnit(unit, "player") then
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
        local icon    = Insight.FACTION_ICONS[faction] or ""
        local name    = GetUnitName(unit, true) or Insight.SafeGetFontText(nameLeft) or ""
        nameLeft:SetText(icon .. name)
        local fc = Insight.FACTION_COLORS[faction]
        if fc then
            nameLeft:SetTextColor(fc[1], fc[2], fc[3])
        elseif classColor then
            nameLeft:SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end

    -- 2. Border tint + left accent bar
    if classColor then
        tooltip:SetBackdropBorderColor(classColor.r, classColor.g, classColor.b, 0.60)
        if Insight.accentBar then
            Insight.accentBar:SetColorTexture(classColor.r, classColor.g, classColor.b, 0.85)
            Insight.accentBar:Show()
        end
    end

    -- 3. Clean up Blizzard lines
    local numLines = tooltip:NumLines()
    local classLineStyled = false
    for j = 2, numLines do
        local lineLeft = _G["GameTooltipTextLeft" .. j]
        if lineLeft then
            local text = Insight.SafeGetFontText(lineLeft)

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
                local iconPrefix = (cached and cached.specIcon)
                    and ("|T" .. cached.specIcon .. ":14:14:0:0|t ") or ""
                local roleSuffix = ""
                if cached and cached.role then
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
        end
    end

    -- Separator: identity block → PvP/status block
    Insight.AddSectionSeparator(tooltip, sepR, sepG, sepB)

    -- 4. PvP title + honor level
    Insight.AddPvPBlock(tooltip, unit, sepR, sepG, sepB)

    -- 5. Status badges
    Insight.AddStatusBadgesBlock(tooltip, unit, guid)

    -- 6. Stats block (M+ score, item level)
    Insight.AddStatsBlock(tooltip, unit, cached, sepR, sepG, sepB)

    -- 7. Mount block
    Insight.AddMountBlock(tooltip, unit, sepR, sepG, sepB)

    return true
end

--- Render sample player tooltip content for /insight test. Reuses same constants and formatting as live path.
function Insight.RenderTestTooltipContent(tooltip)
    if not tooltip then return end
    local testSepR, testSepG, testSepB = 0.77, 0.12, 0.23  -- DK class colour
    Insight.sepR, Insight.sepG, Insight.sepB = testSepR, testSepG, testSepB

    tooltip:AddLine((Insight.FACTION_ICONS["Alliance"] or "") .. "Testplayer-Stormrage", 0.77, 0.12, 0.23)
    tooltip:AddLine("<Ascension>  |cffaaaaaaOfficer|r", 0.25, 0.78, 0.92)
    tooltip:AddLine("Level 80 Human", 1, 0.82, 0)
    tooltip:AddLine(
        "|TInterface\\Icons\\spell_deathknight_bloodpresence:14:14:0:0|t Blood Death Knight  |cff4d99ffTank|r",
        0.77, 0.12, 0.23)
    Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
    tooltip:AddLine("Duelist Testplayer", Insight.TITLE_COLOR[1], Insight.TITLE_COLOR[2], Insight.TITLE_COLOR[3])
    tooltip:AddLine("Honor Level " .. Insight.FormatNumberWithCommas(247), 0.85, 0.70, 1.00)
    tooltip:AddLine("|cffff4444[Combat]|r  |cffff8c00[PvP]|r  |cff88ddff[Party]|r  |cff55ff55[Friend]|r  |cffff4466[Targeting You]|r", 1, 1, 1)
    Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
    tooltip:AddLine(Insight.MYTHIC_ICON .. "M+ Score: " .. Insight.FormatNumberWithCommas(2847), Insight.MythicScoreColor(2847))
    tooltip:AddLine("Item Level: " .. Insight.FormatNumberWithCommas(639), Insight.ILVL_COLOR[1], Insight.ILVL_COLOR[2], Insight.ILVL_COLOR[3])
    Insight.AddSectionSeparator(tooltip, testSepR, testSepG, testSepB)
    tooltip:AddLine(
        "|TInterface\\Icons\\ability_mount_drake_proto:14:14:0:0|t Reins of the Thundering Cobalt Cloud Serpent",
        Insight.MOUNT_COLOR[1], Insight.MOUNT_COLOR[2], Insight.MOUNT_COLOR[3])
    tooltip:AddLine("Drop: Sha of Anger", Insight.MOUNT_SRC_COLOR[1], Insight.MOUNT_SRC_COLOR[2], Insight.MOUNT_SRC_COLOR[3])
    tooltip:AddLine("|cffff5555You don't own this mount|r", 1, 1, 1)
end

addon.Insight = Insight
