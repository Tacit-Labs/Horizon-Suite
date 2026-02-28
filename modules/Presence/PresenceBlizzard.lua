--[[
    Horizon Suite - Presence - Blizzard Suppression
    Hide default zone text, level-up, boss emotes, achievements, event toasts.
    Restore per-type when that type is toggled off (user gets default WoW).
    Restore all when Presence is disabled.
    Frames: ZoneTextFrame, SubZoneTextFrame, RaidBossEmoteFrame, LevelUpDisplay,
    BossBanner, ObjectiveTrackerBonusBannerFrame, ObjectiveTrackerTopBannerFrame,
    EventToastManagerFrame, WorldQuestCompleteBannerFrame.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Presence then return end

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local suppressedFrames = {}
local originalParents = {}
local originalPoints = {}
local originalAlphas = {}
local hookedShowFrames = {}  -- frames with persistent hooksecurefunc("Show") applied
local ZONE_TEXT_EVENTS = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" }

-- Option check with fallback; must match OptionsData/PresenceEvents logic.
local function isTypeEnabled(key, fallbackKey, fallbackDefault)
    if not addon.GetDB then return fallbackDefault end
    local v = addon.GetDB(key, nil)
    if v ~= nil then return v end
    return (fallbackKey and addon.GetDB(fallbackKey, fallbackDefault)) or fallbackDefault
end

-- ============================================================================
-- Private helpers
-- ============================================================================

-- pcall: frame methods can throw on protected or invalid frames.
local function KillBlizzardFrame(frame)
    if not frame then return end
    local ok1, err1 = pcall(function()
        frame:UnregisterAllEvents()
        if not suppressedFrames[frame] then
            originalParents[frame] = frame:GetParent()
            local p, r, rp, x, y = frame:GetPoint(1)
            originalPoints[frame] = p and { p, r, rp, x, y } or nil
            originalAlphas[frame] = frame:GetAlpha()
        end
        suppressedFrames[frame] = true
        frame:SetParent(hiddenParent)
        frame:Hide()
        frame:SetAlpha(0)
    end)
    if not ok1 and addon.HSPrint then addon.HSPrint("Presence KillBlizzardFrame hide failed: " .. tostring(err1)) end
    local ok2, err2 = pcall(function()
        frame:SetScript("OnShow", function(self) self:Hide() end)
    end)
    if not ok2 and addon.HSPrint then addon.HSPrint("Presence KillBlizzardFrame OnShow hook failed: " .. tostring(err2)) end
    if not hookedShowFrames[frame] then
        hookedShowFrames[frame] = true
        pcall(function()
            hooksecurefunc(frame, "Show", function(self)
                if suppressedFrames[self] then
                    self:Hide()
                end
            end)
        end)
    end
end

-- pcall: frame methods can throw on protected or invalid frames.
local function RestoreBlizzardFrame(frame)
    if not frame or not suppressedFrames[frame] then return end
    local ok, err = pcall(function()
        frame:SetScript("OnShow", nil)
        frame:SetParent(originalParents[frame] or UIParent)
        frame:SetAlpha(originalAlphas[frame] or 1)
        local pt = originalPoints[frame]
        frame:ClearAllPoints()
        if pt and pt[1] then
            frame:SetPoint(pt[1], pt[2] or UIParent, pt[3] or "CENTER", pt[4] or 0, pt[5] or 0)
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        local isZoneTextFrame = (frame == ZoneTextFrame) or (frame == SubZoneTextFrame)
        if isZoneTextFrame then
            for _, ev in ipairs(ZONE_TEXT_EVENTS) do frame:RegisterEvent(ev) end
        end
        frame:Hide()
    end)
    if not ok and addon.HSPrint then addon.HSPrint("Presence RestoreBlizzardFrame failed: " .. tostring(err)) end
    suppressedFrames[frame] = nil
    originalParents[frame] = nil
    originalPoints[frame] = nil
    originalAlphas[frame] = nil
end

-- ============================================================================
-- Public functions
-- ============================================================================

-- Forward declarations for reload-safe suppression (defined later)
local HookEventToastManager

--- Apply per-type Blizzard suppression. Suppress only frames for types that are ON;
--- restore frames for types that are OFF so default WoW notifications show.
--- Idempotent; safe to call multiple times.
--- @return nil
local function ApplyBlizzardSuppression()
    if not addon:IsModuleEnabled("presence") then return end

    -- Zone entry
    local zoneFrame = ZoneTextFrame or _G["ZoneTextFrame"]
    if isTypeEnabled("presenceZoneChange", nil, true) then
        KillBlizzardFrame(zoneFrame)
    else
        RestoreBlizzardFrame(zoneFrame)
    end

    -- Subzone: suppress when subzone notifications are on, or when user wants zone hidden for subzone-only changes
    local subzoneFrame = SubZoneTextFrame or _G["SubZoneTextFrame"]
    local subzoneOn = isTypeEnabled("presenceSubzoneChange", "presenceZoneChange", true)
    local hideZoneForSubzone = addon.GetDB and addon.GetDB("presenceHideZoneForSubzone", false)
    if subzoneOn or hideZoneForSubzone then
        KillBlizzardFrame(subzoneFrame)
    else
        RestoreBlizzardFrame(subzoneFrame)
    end

    -- Level up
    local levelUpFrame = LevelUpDisplay or _G["LevelUpDisplay"]
    if addon.GetDB and addon.GetDB("presenceLevelUp", true) then
        KillBlizzardFrame(levelUpFrame)
    else
        RestoreBlizzardFrame(levelUpFrame)
    end

    -- Boss emotes
    local bossEmoteFrame = RaidBossEmoteFrame or _G["RaidBossEmoteFrame"]
    if addon.GetDB and addon.GetDB("presenceBossEmote", true) then
        KillBlizzardFrame(bossEmoteFrame)
    else
        RestoreBlizzardFrame(bossEmoteFrame)
    end

    -- Event toasts (achievements, quest accept/complete/progress, scenario) - shared frame
    local anyToast = isTypeEnabled("presenceAchievement", nil, true)
        or isTypeEnabled("presenceAchievementProgress", nil, false)
        or isTypeEnabled("presenceQuestAccept", "presenceQuestEvents", true)
        or isTypeEnabled("presenceWorldQuestAccept", "presenceQuestEvents", true)
        or isTypeEnabled("presenceQuestComplete", "presenceQuestEvents", true)
        or isTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true)
        or isTypeEnabled("presenceQuestUpdate", "presenceQuestEvents", true)
        or isTypeEnabled("presenceScenarioStart", "showScenarioEvents", true)
        or isTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true)
    local eventToastFrame = EventToastManagerFrame or _G["EventToastManagerFrame"]
    if anyToast then
        KillBlizzardFrame(eventToastFrame)
    else
        RestoreBlizzardFrame(eventToastFrame)
    end

    -- World quest complete banner (separate from EventToastManagerFrame)
    if isTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true) then
        local wqFrame = WorldQuestCompleteBannerFrame or _G["WorldQuestCompleteBannerFrame"]
        if wqFrame then KillBlizzardFrame(wqFrame) end
    else
        local wqFrame = WorldQuestCompleteBannerFrame or _G["WorldQuestCompleteBannerFrame"]
        if wqFrame then RestoreBlizzardFrame(wqFrame) end
    end

    -- Always suppress when Presence is on (no per-type mapping)
    KillBlizzardFrame(BossBanner)
    KillBlizzardFrame(ObjectiveTrackerBonusBannerFrame)
    local topBannerFrame = ObjectiveTrackerTopBannerFrame or _G["ObjectiveTrackerTopBannerFrame"]
    if topBannerFrame then KillBlizzardFrame(topBannerFrame) end
end

--- Re-apply zone frame suppression. Call when zone events fire to ensure frames stay hidden after Blizzard may have shown them.
--- @return nil
local function ReapplyZoneSuppression()
    if not addon:IsModuleEnabled("presence") then return end
    if isTypeEnabled("presenceZoneChange", nil, true) then
        KillBlizzardFrame(ZoneTextFrame or _G["ZoneTextFrame"])
    end
    local subzoneOn = isTypeEnabled("presenceSubzoneChange", "presenceZoneChange", true)
    local hideZoneForSubzone = addon.GetDB and addon.GetDB("presenceHideZoneForSubzone", false)
    if subzoneOn or hideZoneForSubzone then
        KillBlizzardFrame(SubZoneTextFrame or _G["SubZoneTextFrame"])
    end
end

--- Suppress Blizzard frames when Presence is enabled. Calls ApplyBlizzardSuppression for per-type logic.
--- @return nil
local function SuppressBlizzard()
    ApplyBlizzardSuppression()
    HookEventToastManager()
end

--- Restore all suppressed Blizzard frames when Presence is disabled.
--- @return nil
local function RestoreBlizzard()
    RestoreBlizzardFrame(ZoneTextFrame)
    RestoreBlizzardFrame(SubZoneTextFrame)
    RestoreBlizzardFrame(RaidBossEmoteFrame or _G["RaidBossEmoteFrame"])
    RestoreBlizzardFrame(LevelUpDisplay or _G["LevelUpDisplay"])
    RestoreBlizzardFrame(EventToastManagerFrame or _G["EventToastManagerFrame"])
    RestoreBlizzardFrame(BossBanner)
    RestoreBlizzardFrame(ObjectiveTrackerBonusBannerFrame)
    local topBannerFrame = ObjectiveTrackerTopBannerFrame or _G["ObjectiveTrackerTopBannerFrame"]
    if topBannerFrame then RestoreBlizzardFrame(topBannerFrame) end
    local wqFrame = WorldQuestCompleteBannerFrame or _G["WorldQuestCompleteBannerFrame"]
    if wqFrame then RestoreBlizzardFrame(wqFrame) end
end

--- Dump notification type options and Blizzard frame suppression state for debugging.
--- Call with addon.HSPrint or similar. Use /horizon presence debugtypes for quick check.
--- @param p function Print function (msg) -> nil
--- @return nil
local function DumpBlizzardSuppression(p)
    if not p then return end
    p("|cFF00CCFF--- Notification types & Blizzard suppression ---|r")
    if not addon:IsModuleEnabled("presence") then
        p("Module disabled - Blizzard frames not managed by Presence")
        return
    end

    local function frameState(frame)
        if not frame then return "nil" end
        return suppressedFrames[frame] and "SUPPRESSED" or "restored"
    end

    -- Per-type mappings: label, option enabled?, Blizzard frame
    local zoneOn = isTypeEnabled("presenceZoneChange", nil, true)
    p("Zone entry:    option=" .. tostring(zoneOn) .. " | ZoneTextFrame=" .. frameState(ZoneTextFrame))

    local subzoneOn = isTypeEnabled("presenceSubzoneChange", "presenceZoneChange", true)
    p("Subzone:       option=" .. tostring(subzoneOn) .. " | SubZoneTextFrame=" .. frameState(SubZoneTextFrame))

    local levelUpFrame = LevelUpDisplay or _G["LevelUpDisplay"]
    local levelOn = addon.GetDB and addon.GetDB("presenceLevelUp", true)
    p("Level up:      option=" .. tostring(levelOn) .. " | LevelUpDisplay=" .. frameState(levelUpFrame))

    local bossEmoteFrame = RaidBossEmoteFrame or _G["RaidBossEmoteFrame"]
    local bossOn = addon.GetDB and addon.GetDB("presenceBossEmote", true)
    p("Boss emote:    option=" .. tostring(bossOn) .. " | RaidBossEmoteFrame=" .. frameState(bossEmoteFrame))

    local anyToast = isTypeEnabled("presenceAchievement", nil, true)
        or isTypeEnabled("presenceAchievementProgress", nil, false)
        or isTypeEnabled("presenceQuestAccept", "presenceQuestEvents", true)
        or isTypeEnabled("presenceWorldQuestAccept", "presenceQuestEvents", true)
        or isTypeEnabled("presenceQuestComplete", "presenceQuestEvents", true)
        or isTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true)
        or isTypeEnabled("presenceQuestUpdate", "presenceQuestEvents", true)
        or isTypeEnabled("presenceScenarioStart", "showScenarioEvents", true)
        or isTypeEnabled("presenceScenarioUpdate", "showScenarioEvents", true)
    local eventToastFrame = EventToastManagerFrame or _G["EventToastManagerFrame"]
    p("Event toasts:  any=" .. tostring(anyToast) .. " (ach/quest/scenario) | EventToastManagerFrame=" .. frameState(eventToastFrame))

    local wqOn = isTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true)
    local wqFrame = WorldQuestCompleteBannerFrame or _G["WorldQuestCompleteBannerFrame"]
    p("World quest:   option=" .. tostring(wqOn) .. " | WorldQuestCompleteBannerFrame=" .. frameState(wqFrame))

    p("Expect: option=ON -> SUPPRESSED (Presence shows). option=OFF -> restored (WoW default shows)")
    p("|cFF00CCFF--- End suppression debug ---|r")
end

--- Suppress WorldQuestCompleteBannerFrame (called on ADDON_LOADED for Blizzard_WorldQuestComplete).
--- Only suppresses if presenceWorldQuest type is enabled.
--- @return nil
local function KillWorldQuestBanner()
    if not isTypeEnabled("presenceWorldQuest", "presenceQuestEvents", true) then return end
    local frame = WorldQuestCompleteBannerFrame or _G["WorldQuestCompleteBannerFrame"]
    if frame then
        KillBlizzardFrame(frame)
    end
end

-- ============================================================================
-- RELOAD-SAFE SUPPRESSION
-- ============================================================================
-- On reload/login, Blizzard re-initializes frames and may queue pending toasts,
-- achievements, or scenario updates before our ADDON_LOADED handler runs.

local reloadSweepTicker = nil
local eventToastHooked = false

local function SweepSuppressedFrames()
    for frame in pairs(suppressedFrames) do
        pcall(function()
            if frame:IsShown() then
                frame:Hide()
            end
            frame:SetAlpha(0)
            if frame.GetChildren then
                for _, child in ipairs({ frame:GetChildren() }) do
                    if child and child.IsShown and child:IsShown() then
                        pcall(function() child:Hide() end)
                    end
                end
            end
        end)
    end
end

HookEventToastManager = function()
    if eventToastHooked then return end
    local etm = EventToastManagerFrame or _G["EventToastManagerFrame"]
    if not etm then return end
    eventToastHooked = true

    if etm.DisplayToast then
        pcall(function()
            hooksecurefunc(etm, "DisplayToast", function(self)
                if suppressedFrames[self] then
                    pcall(function()
                        self:Hide()
                        self:SetAlpha(0)
                    end)
                end
            end)
        end)
    end

    for _, methodName in ipairs({ "ShowNextToast", "ReleaseToasts", "ShowToast" }) do
        if etm[methodName] then
            pcall(function()
                hooksecurefunc(etm, methodName, function(self)
                    if suppressedFrames[self] then
                        pcall(function()
                            self:Hide()
                            self:SetAlpha(0)
                        end)
                    end
                end)
            end)
        end
    end
end

local function DrainAlertFrameQueue()
    pcall(function()
        if not AlertFrame then return end
        if AlertFrame.alertQueue and type(AlertFrame.alertQueue) == "table" then
            wipe(AlertFrame.alertQueue)
        end
        if AlertFrame.GetChildren then
            for _, child in ipairs({ AlertFrame:GetChildren() }) do
                if child and child.IsShown and child:IsShown() then
                    pcall(function() child:Hide() end)
                end
            end
        end
    end)
end

local function StartReloadSweep()
    if reloadSweepTicker then
        reloadSweepTicker:Cancel()
        reloadSweepTicker = nil
    end
    local sweepCount = 0
    local MAX_SWEEPS = 20  -- 20 ticks × 0.25s = 5 seconds of sweeping
    reloadSweepTicker = C_Timer.NewTicker(0.25, function()
        sweepCount = sweepCount + 1
        if not addon:IsModuleEnabled("presence") or sweepCount >= MAX_SWEEPS then
            if reloadSweepTicker then
                reloadSweepTicker:Cancel()
                reloadSweepTicker = nil
            end
            return
        end
        SweepSuppressedFrames()
        DrainAlertFrameQueue()
    end)
end

local reloadGuardFrame = CreateFrame("Frame")
reloadGuardFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reloadGuardFrame:SetScript("OnEvent", function(self, event)
    if not addon:IsModuleEnabled("presence") then return end
    ApplyBlizzardSuppression()
    HookEventToastManager()
    SweepSuppressedFrames()
    DrainAlertFrameQueue()
    StartReloadSweep()
end)

-- ============================================================================
-- Exports
-- ============================================================================

addon.Presence.SuppressBlizzard        = SuppressBlizzard
addon.Presence.RestoreBlizzard         = RestoreBlizzard
addon.Presence.ApplyBlizzardSuppression = ApplyBlizzardSuppression
addon.Presence.ReapplyZoneSuppression   = ReapplyZoneSuppression
addon.Presence.DumpBlizzardSuppression = DumpBlizzardSuppression
addon.Presence.KillWorldQuestBanner     = KillWorldQuestBanner
addon.Presence.HookEventToastManager   = HookEventToastManager
