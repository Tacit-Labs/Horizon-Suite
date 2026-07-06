--[[
    Horizon Suite - Augment / Skyriding - API
    Read-only data layer for the Skyriding Vigor/Speed display: Vigor charges,
    Second Wind, Whirling Surge, gliding/forward-speed, and racing detection.
    Reimplemented from first principles against Blizzard's spell/widget APIs
    (not ported from any third-party addon). Every function here is a plain
    read — nothing touches a protected/secure API, so this file never needs
    InCombatLockdown guards.
]]

local addon = _G.HorizonSuite
local Y = addon and addon.Augment
if not Y then return end

Y.Skyriding = Y.Skyriding or {}
local S = Y.Skyriding
S.API = S.API or {}
local API = S.API

-- Spell IDs (retail, Dragonriding/Skyriding).
local SPELL_VIGOR               = 372608  -- Vigor charges (shared by all Skyriding mounts)
local SPELL_SECOND_WIND         = 425782  -- Second Wind bonus charges
local SPELL_WHIRLING_SURGE      = 361584  -- Whirling Surge burst cooldown
local SPELL_WHIRLING_SURGE_ICON = 1227921

-- Zones where Vigor regen uses the "Dragonriding Race" speed-scale reciprocal
-- even without an active race quest in the log.
local RACE_ZONE_INSTANCE_IDS = {
    [2444] = true, -- Dragon Isles
    [2454] = true, -- Zaralek Cavern
    [2516] = true, -- Nokhud Offensive
    [2522] = true, -- Vault of the Incarnates
    [2548] = true, -- Emerald Dream
    [2569] = true, -- Aberrus, the Shadowed Crucible
}

local BRONZE_TIMETOKEN_ITEM_ID  = 191140
local DERBY_RACING_POWER_BAR_ID = 650

local glideState = { enabled = false, isGliding = false, forwardSpeed = 0.0 }
local isRacingQuest = false

local function RefreshGlideState()
    if not C_PlayerInfo or not C_PlayerInfo.GetGlidingInfo then return end
    local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    glideState.enabled = canGlide
    glideState.isGliding = isGliding
    glideState.forwardSpeed = forwardSpeed or 0.0
end

-- @return isCharging boolean, charges number, maxCharges number, chargeStart number,
--         chargeDuration number, chargeModRate number, isThrill boolean, isGroundSkimming boolean
function API:GetVigorInfo()
    local data = C_Spell.GetSpellCharges(SPELL_VIGOR)
    if not data then return false, 0, 0, 0, 0, 0, false, false end
    return data.currentCharges < data.maxCharges,
        data.currentCharges, data.maxCharges,
        data.cooldownStartTime, data.cooldownDuration, data.chargeModRate,
        data.cooldownDuration <= 6.003, -- base 10.35s, -42% while Thrill of the Skies is active
        data.cooldownDuration == 8.28   -- Ground Skimming recharge rate
end

-- @return isCharging boolean, charges number, maxCharges number, chargeStart number, chargeDuration number, chargeModRate number
function API:GetSecondWindInfo()
    local data = C_Spell.GetSpellCharges(SPELL_SECOND_WIND)
    if not data then return false, 0, 0, 0, 0, 0 end
    return data.currentCharges < data.maxCharges,
        data.currentCharges, data.maxCharges,
        data.cooldownStartTime, data.cooldownDuration, data.chargeModRate
end

-- @return startTime number, duration number, isEnabled boolean, modRate number, activeCategory number|nil
function API:GetWhirlingSurgeInfo()
    local data = C_Spell.GetSpellCooldown(SPELL_WHIRLING_SURGE)
    if not data then return 0, 0, false, 0, nil end
    return data.startTime, data.duration, data.isEnabled, data.modRate, data.activeCategory
end

function API:GetWhirlingSurgeIcon()
    return C_Spell.GetSpellTexture(SPELL_WHIRLING_SURGE_ICON)
end

function API:IsGlidingEnabled()
    RefreshGlideState()
    return glideState.enabled
end

function API:IsGliding()
    RefreshGlideState()
    return glideState.isGliding
end

function API:GetForwardSpeed()
    RefreshGlideState()
    return glideState.forwardSpeed
end

-- True while the Skyriding bonus action bar is active, or while gliding with a
-- non-default power bar (covers Derby Racing and similar special integrations
-- that don't use the bonus bar at all).
function API:IsSkyriding()
    local hasSkyridingBar = C_ActionBar.GetBonusBarIndex() == 11 and C_ActionBar.GetBonusBarOffset() == 5
    if hasSkyridingBar then return true end
    local powerBarID = UnitPowerBarID("player")
    return self:IsGlidingEnabled() and powerBarID ~= 0
end

function API:IsDerbyRacing()
    return UnitPowerBarID("player") == DERBY_RACING_POWER_BAR_ID
end

-- Cached by AugmentSkyridingEvents.lua's PLAYER_LOGIN/CLIENT_SCENE_OPENED/
-- CLIENT_SCENE_CLOSED handlers via RefreshRacingQuestState below.
function API:IsRacing()
    return isRacingQuest
end

-- Vigor regen during Dragonriding Races (and a few race-themed zones) scales
-- forward speed into the 0-1 bar value using a tighter reciprocal than normal flight.
function API:GetSpeedScaleReciprocal()
    if isRacingQuest then return 0.01 end
    local instanceID = select(8, GetInstanceInfo())
    if instanceID and RACE_ZONE_INSTANCE_IDS[instanceID] then return 0.01 end
    return 0.011764
end

-- The Bronze Timetoken can persist in bags after a race quest is turned in
-- (a known client quirk), so confirm via the quest log too rather than trusting
-- the item alone.
local function HasActiveRaceQuest()
    if C_Item.GetItemCount(BRONZE_TIMETOKEN_ITEM_ID) == 0 then return false end
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader then
            local link = GetQuestLogSpecialItemInfo(i)
            if link and C_Item.GetItemIDForItemInfo(link) == BRONZE_TIMETOKEN_ITEM_ID then
                return true
            end
        end
    end
    return false
end

-- Called from AugmentSkyridingEvents.lua on PLAYER_LOGIN/CLIENT_SCENE_OPENED/
-- CLIENT_SCENE_CLOSED — kept here rather than registering its own event frame
-- so all Skyriding event registration lives in one place.
function API:RefreshRacingQuestState()
    isRacingQuest = HasActiveRaceQuest()
end
