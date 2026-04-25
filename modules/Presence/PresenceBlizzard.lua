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

local function suppressionRegistry()
    return addon.Presence and addon.Presence.Suppression
end

local function isSuppressed(category)
    local s = suppressionRegistry()
    return s and s.IsSuppressed(category) or false
end

local function framesFor(category)
    local s = suppressionRegistry()
    return s and s.GetFrames(category) or {}
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

--- Apply per-frame Blizzard suppression. Iterates the suppression registry and
--- kills frames for categories the user has chosen to suppress; restores the
--- rest. Also re-evaluates the AlertFrame mute via PresenceErrors.MuteAlerts.
--- Idempotent; safe to call multiple times.
--- @return nil
local function ApplyBlizzardSuppression()
    if not addon:IsModuleEnabled("presence") then return end
    local s = suppressionRegistry()
    if not s then return end
    for category, entry in pairs(s.GetCategories()) do
        if entry.frames then
            local kill = s.IsSuppressed(category)
            for _, frame in ipairs(s.GetFrames(category)) do
                if kill then KillBlizzardFrame(frame) else RestoreBlizzardFrame(frame) end
            end
        end
    end
    if addon.Presence and addon.Presence.MuteAlerts then addon.Presence.MuteAlerts() end
end

--- Re-apply zone-frame suppression after a zone event in case Blizzard re-showed them.
--- @return nil
local function ReapplyZoneSuppression()
    if not addon:IsModuleEnabled("presence") then return end
    if isSuppressed("ZONE_TEXT") then
        for _, f in ipairs(framesFor("ZONE_TEXT")) do KillBlizzardFrame(f) end
    end
    if isSuppressed("SUBZONE_TEXT") then
        for _, f in ipairs(framesFor("SUBZONE_TEXT")) do KillBlizzardFrame(f) end
    end
end

--- Suppress Blizzard frames when Presence is enabled. Calls ApplyBlizzardSuppression for per-type logic.
--- @return nil
local function SuppressBlizzard()
    ApplyBlizzardSuppression()
    HookEventToastManager()
end

--- Restore every Blizzard frame Presence may have suppressed (called when Presence is disabled).
--- @return nil
local function RestoreBlizzard()
    local s = suppressionRegistry()
    if not s then return end
    for category, entry in pairs(s.GetCategories()) do
        if entry.frames then
            for _, frame in ipairs(s.GetFrames(category)) do
                RestoreBlizzardFrame(frame)
            end
        end
    end
end

--- Dump suppression registry state for debugging. Use /horizon presence debugtypes.
--- @param p function Print function (msg) -> nil
--- @return nil
local function DumpBlizzardSuppression(p)
    if not p then return end
    p("|cFF00CCFF--- Blizzard suppression ---|r")
    if not addon:IsModuleEnabled("presence") then
        p("Module disabled - Blizzard frames not managed by Presence")
        return
    end
    local s = suppressionRegistry()
    if not s then
        p("Suppression registry not loaded")
        return
    end
    p("Master presenceSuppressAll = " .. tostring(s.IsSuppressAllOn()))
    local function frameState(frame)
        if not frame then return "nil" end
        return suppressedFrames[frame] and "SUPPRESSED" or "restored"
    end
    for category, entry in pairs(s.GetCategories()) do
        local decision = s.IsSuppressed(category)
        if entry.frames then
            local parts = {}
            for _, frame in ipairs(s.GetFrames(category)) do
                parts[#parts + 1] = frameState(frame)
            end
            p(category .. ": suppress=" .. tostring(decision) .. " | frames=" .. table.concat(parts, ", "))
        else
            p(category .. ": suppress=" .. tostring(decision) .. " | (no frames)")
        end
    end
    p("|cFF00CCFF--- End suppression debug ---|r")
end

--- Suppress WorldQuestCompleteBannerFrame (called on ADDON_LOADED for Blizzard_WorldQuestComplete).
--- Only suppresses if the WORLD_QUEST_BANNER suppression category is on.
--- @return nil
local function KillWorldQuestBanner()
    if not isSuppressed("WORLD_QUEST_BANNER") then return end
    for _, frame in ipairs(framesFor("WORLD_QUEST_BANNER")) do KillBlizzardFrame(frame) end
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

-- Hide every currently-active frame in the toast pool that matches `template`,
-- and release it back to the pool. Defensive across pool-shape variants
-- (FramePoolCollection with sub-pools per template, or a single FramePool).
local function hideAndReleaseActiveToasts(etm, template)
    if not etm or not template then return end
    local fpc = etm.toastFramePool
    if not fpc then return end
    pcall(function()
        local sub = fpc.GetPool and fpc:GetPool(template)
        if sub and sub.EnumerateActive then
            for f in sub:EnumerateActive() do
                if f then
                    pcall(function() f:Hide() end)
                    pcall(function() f:SetAlpha(0) end)
                    if sub.Release then pcall(function() sub:Release(f) end) end
                end
            end
            return
        end
        if fpc.EnumerateActive then
            for f in fpc:EnumerateActive() do
                if f then
                    pcall(function() f:Hide() end)
                    pcall(function() f:SetAlpha(0) end)
                    if fpc.Release then pcall(function() fpc:Release(f) end) end
                end
            end
        end
    end)
end

HookEventToastManager = function()
    if eventToastHooked then return end
    local etm = EventToastManagerFrame or _G["EventToastManagerFrame"]
    if not etm then return end
    eventToastHooked = true

    -- Per-toast suppression: GetToastFrame is called once per incoming toast
    -- with the toast's metadata table (containing `.template`). We dispatch
    -- by template through the registry; if the resulting category is
    -- suppressed, we defer one frame so Blizzard's Setup/Show have run, then
    -- hide and release the matching pool frame(s).
    if etm.GetToastFrame then
        pcall(function()
            hooksecurefunc(etm, "GetToastFrame", function(self, toastInfo)
                if not addon:IsModuleEnabled("presence") then return end
                if type(toastInfo) ~= "table" then return end
                local template = toastInfo.template
                if not template then return end
                local s = suppressionRegistry()
                if not (s and s.GetCategoryForTemplate) then return end
                local category = s.GetCategoryForTemplate(template)
                if not category or not s.IsSuppressed(category) then return end
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() hideAndReleaseActiveToasts(self, template) end)
                else
                    hideAndReleaseActiveToasts(self, template)
                end
            end)
        end)
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
