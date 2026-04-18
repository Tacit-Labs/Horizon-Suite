--[[
    Horizon Suite - Presence - Blizzard Suppression
    Hide default zone text, level-up, boss emotes, achievements, event toasts.
    Restore per-type when that type is toggled off (user gets default WoW).
    Restore all when Presence is disabled.
    Frames: ZoneTextFrame, SubZoneTextFrame, RaidBossEmoteFrame, LevelUpDisplay,
    BossBanner, ObjectiveTrackerTopBannerFrame,
    EventToastManagerFrame, WorldQuestCompleteBannerFrame.

    ObjectiveTrackerBonusBannerFrame is intentionally NOT suppressed: it carries
    bonus objective banners and the Midnight Abundance / Prey information panel
    and pickup toasts (issue #47). Presence does not yet have a custom toast for
    Abundance, so we leave the native UI intact.

    EventToastManagerFrame uses "selective" suppression: the frame keeps its
    normal parent, and our DisplayToast / OnShow / Show hooks hide it only when
    the currently-displayed toast is NOT an Abundance toast. This lets Midnight
    Abundance completion / turn-in toasts render natively while everything else
    Presence already replaces (achievements, quest events, scenario stages)
    stays hidden. Abundance detection is string-based on localized "Abundance"
    across toastInfo text fields, with a best-effort Enum.EventToastType probe.
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

-- Selective EventToastManagerFrame state. When true, our hooks hide the manager
-- for every toast except Abundance. See "selective" note in file header.
local eventToastSelectiveSuppressed = false
local lastDisplayToastWasAbundance = false

-- Diagnostic: when true, the DisplayToast hook dumps each toastInfo payload
-- to chat. Toggle via /h debug presence debugtoasts. Used to identify the
-- exact field shape for Abundance toasts so IsAbundanceEventToast can be
-- tightened. Off by default.
local debugEventToastLogging = false

-- Fields on toastInfo / currentDisplayingToast.toastInfo that may carry user
-- facing text. We scan each for the localized "Abundance" needle.
local ABUNDANCE_TEXT_FIELDS = {
    "primaryText", "toastString", "toastString1", "toastString2",
    "title", "subtitle", "description", "text", "eventDescription",
}
-- Best-effort Enum.EventToastType names; we don't know the exact enum for
-- Midnight Abundance toasts, so probe a handful.
local ABUNDANCE_ENUM_NAMES = {
    "AbundanceToast", "AbundanceHeld", "AbundanceHeldFinal",
    "Abundance", "AbundanceCollected", "AbundanceTurnIn",
}

local function isTypeEnabled(key, fallbackKey, fallbackDefault)
    return addon.Presence and addon.Presence.IsTypeEnabled and addon.Presence.IsTypeEnabled(key, fallbackKey, fallbackDefault) or fallbackDefault
end

local function GetAbundanceNeedle()
    local L = addon.L or {}
    local n = L["UI_ABUNDANCE"]
    if type(n) ~= "string" or n == "" then n = "Abundance" end
    return n:lower()
end

--- True when the given toastInfo table looks like a Midnight Abundance toast.
--- Detection is string-based on localized "Abundance" across common text
--- fields, with a best-effort Enum.EventToastType name probe as a bonus.
--- @param toastInfo table|nil
--- @return boolean
local function IsAbundanceEventToast(toastInfo)
    if type(toastInfo) ~= "table" then return false end
    local needle = GetAbundanceNeedle()
    for i = 1, #ABUNDANCE_TEXT_FIELDS do
        local v = toastInfo[ABUNDANCE_TEXT_FIELDS[i]]
        if type(v) == "string" and v:lower():find(needle, 1, true) then
            return true
        end
    end
    if type(toastInfo.type) == "number" and Enum and Enum.EventToastType then
        for i = 1, #ABUNDANCE_ENUM_NAMES do
            local v = Enum.EventToastType[ABUNDANCE_ENUM_NAMES[i]]
            if v ~= nil and v == toastInfo.type then return true end
        end
    end
    return false
end

--- True when EventToastManagerFrame is currently displaying an Abundance toast.
--- Used from hooks that don't receive toastInfo (ShowNextToast, OnShow, etc.).
--- @param manager table|nil EventToastManagerFrame
--- @return boolean
local function IsCurrentEventToastAbundance(manager)
    if type(manager) ~= "table" then return false end
    local t = manager.currentDisplayingToast
    if t and type(t) == "table" and IsAbundanceEventToast(t.toastInfo) then
        return true
    end
    return false
end

--- Diagnostic helper: dump every scalar field of a toastInfo table to chat.
--- Guarded by debugEventToastLogging. Used to reverse-engineer the exact
--- toast payload shape for Midnight Abundance toasts.
--- @param label string
--- @param info table|nil
local function DumpToastInfo(label, info)
    if not debugEventToastLogging then return end
    local p = addon.HSPrint or print
    if type(info) ~= "table" then
        p(("|cFFFFD100[Presence:toasts]|r %s toastInfo=%s"):format(label, tostring(info)))
        return
    end
    p(("|cFFFFD100[Presence:toasts]|r %s:"):format(label))
    local count = 0
    for k, v in pairs(info) do
        local tv = type(v)
        if tv == "string" or tv == "number" or tv == "boolean" then
            p(("  %s (%s) = %s"):format(tostring(k), tv, tostring(v)))
        elseif tv == "table" then
            p(("  %s (table) = {...}"):format(tostring(k)))
        else
            p(("  %s (%s)"):format(tostring(k), tv))
        end
        count = count + 1
    end
    if count == 0 then p("  <empty table>") end
end

--- Exported: toggle toastInfo logging. Returns new state. Invoked via
--- /h debug presence debugtoasts.
--- @return boolean
local function ToggleDebugEventToasts()
    debugEventToastLogging = not debugEventToastLogging
    return debugEventToastLogging
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

-- Selective EventToastManagerFrame suppression: DO NOT reparent or mass-hide
-- the frame. Our permanent DisplayToast / ShowNextToast / ShowToast /
-- ReleaseToasts hooks (installed by HookEventToastManager) inspect each toast
-- and let Abundance render while hiding everything else when this flag is on.
local function SuppressEventToastManagerSelective(etm)
    eventToastSelectiveSuppressed = true
    if not etm then return end
    -- Clear any legacy reparent/kill from an older session so Abundance can render.
    if suppressedFrames[etm] then RestoreBlizzardFrame(etm) end
end

local function RestoreEventToastManagerSelective(etm)
    eventToastSelectiveSuppressed = false
    lastDisplayToastWasAbundance = false
    if etm then
        pcall(function() etm:SetAlpha(1) end)
    end
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

    -- Event toasts (achievements, quest accept/complete/progress, scenario) - shared frame.
    -- Selective suppression: Abundance toasts pass through natively (#47);
    -- everything else is hidden by the DisplayToast / OnShow hooks.
    local anyToast = (addon.Presence and addon.Presence.IsAnyToastEnabled and addon.Presence.IsAnyToastEnabled()) or false
    local eventToastFrame = EventToastManagerFrame or _G["EventToastManagerFrame"]
    if anyToast then
        SuppressEventToastManagerSelective(eventToastFrame)
    else
        RestoreEventToastManagerSelective(eventToastFrame)
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
    local topBannerFrame = ObjectiveTrackerTopBannerFrame or _G["ObjectiveTrackerTopBannerFrame"]
    if topBannerFrame then KillBlizzardFrame(topBannerFrame) end
    -- Abundance / bonus objective banner (ObjectiveTrackerBonusBannerFrame)
    -- is intentionally left alone; see file header.
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
    local etm = EventToastManagerFrame or _G["EventToastManagerFrame"]
    -- Belt-and-braces: also call RestoreBlizzardFrame in case a pre-#47 install
    -- had the manager in suppressedFrames from the old KillBlizzardFrame path.
    if etm and suppressedFrames[etm] then RestoreBlizzardFrame(etm) end
    RestoreEventToastManagerSelective(etm)
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

    local anyToast = (addon.Presence and addon.Presence.IsAnyToastEnabled and addon.Presence.IsAnyToastEnabled()) or false
    local eventToastFrame = EventToastManagerFrame or _G["EventToastManagerFrame"]
    local selectiveLabel = eventToastSelectiveSuppressed and "SELECTIVE (Abundance passthrough)" or "off"
    p("Event toasts:  any=" .. tostring(anyToast) .. " (ach/quest/scenario) | EventToastManagerFrame=" .. selectiveLabel
        .. " | legacy-kill=" .. frameState(eventToastFrame))

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
    local etm = EventToastManagerFrame or _G["EventToastManagerFrame"]
    for frame in pairs(suppressedFrames) do
        -- Carve-out: don't clobber EventToastManagerFrame if it's currently
        -- rendering an Abundance toast. (Normally the manager isn't in
        -- suppressedFrames under selective mode, but a pre-#47 install could
        -- still have it here and the sweep runs before SuppressEventToastManagerSelective
        -- clears that state.)
        local skip = (frame == etm) and (lastDisplayToastWasAbundance or IsCurrentEventToastAbundance(frame))
        if not skip then
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
end

-- Selective event-toast hide gate. Called from each hook:
-- - returns without hiding if this is an Abundance toast (passthrough, #47)
-- - returns without hiding if selective suppression is off (Presence toasts disabled)
-- - otherwise hides the manager so non-Abundance toasts Presence already
--   replaces (achievement/quest/scenario) don't double up.
local function MaybeHideEventToastManager(self, isAbundance)
    if isAbundance then
        pcall(function()
            self:SetAlpha(1)
            if not self:IsShown() then self:Show() end
        end)
        return
    end
    if not eventToastSelectiveSuppressed then return end
    pcall(function()
        self:Hide()
        self:SetAlpha(0)
    end)
end

HookEventToastManager = function()
    if eventToastHooked then return end
    local etm = EventToastManagerFrame or _G["EventToastManagerFrame"]
    if not etm then return end
    eventToastHooked = true

    if etm.DisplayToast then
        pcall(function()
            hooksecurefunc(etm, "DisplayToast", function(self, toastInfo)
                local isAbundance = IsAbundanceEventToast(toastInfo) or IsCurrentEventToastAbundance(self)
                lastDisplayToastWasAbundance = isAbundance
                if debugEventToastLogging then
                    DumpToastInfo("DisplayToast.arg", toastInfo)
                    local current = self and self.currentDisplayingToast
                    DumpToastInfo("DisplayToast.current.toastInfo", current and current.toastInfo)
                    local p = addon.HSPrint or print
                    p(("|cFFFFD100[Presence:toasts]|r isAbundance=%s  -> %s"):format(
                        tostring(isAbundance),
                        isAbundance and "PASSTHROUGH" or (eventToastSelectiveSuppressed and "HIDE" or "allow (selective=off)")))
                end
                MaybeHideEventToastManager(self, isAbundance)
            end)
        end)
    end

    for _, methodName in ipairs({ "ShowNextToast", "ReleaseToasts", "ShowToast" }) do
        if etm[methodName] then
            pcall(function()
                hooksecurefunc(etm, methodName, function(self)
                    local isAbundance = IsCurrentEventToastAbundance(self) or lastDisplayToastWasAbundance
                    MaybeHideEventToastManager(self, isAbundance)
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
addon.Presence.ToggleDebugEventToasts  = ToggleDebugEventToasts
