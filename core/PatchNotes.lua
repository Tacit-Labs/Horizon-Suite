--[[
    Horizon Suite - Patch Notes
    Version tracking, optional auto-show on login; minimap unread vs sidebar (New!) until sidebar click.
    The Patch Notes view is built inside options/dashboard/DashboardFrame.lua.

    Reopen: /h notes  or the Dashboard Patch Notes button.
    Notes data lives in core/PatchNotesData.lua — edit that file each release.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- VERSION / DB (root saved variables, not per-profile)
-- ============================================================================

local function GetCurrentVersion()
    local gm = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return (gm and gm(addon.ADDON_NAME, "Version")) or ""
end

local function EnsureRootDB()
    local db = _G[addon.DATABASE]
    if not db then
        db = {}
        _G[addon.DATABASE] = db
    end
    return db
end

-- One-time: copy legacy lastSeenPatchVersion so users who already saw the auto popup are not badged.
local function MigratePatchNotesVersionIfNeeded()
    local db = EnsureRootDB()
    if db.patchNotesLastViewedVersion == nil and db.lastSeenPatchVersion ~= nil then
        db.patchNotesLastViewedVersion = db.lastSeenPatchVersion
    end
end

local function GetPatchNotesLastViewedVersion()
    MigratePatchNotesVersionIfNeeded()
    local db = _G[addon.DATABASE]
    return (db and db.patchNotesLastViewedVersion) or ""
end

local function SetPatchNotesLastViewedVersion(v)
    local db = EnsureRootDB()
    db.patchNotesLastViewedVersion = v
end

-- Sidebar "(New!)" + green: cleared only when the user clicks the Patch Notes sidebar row (not /h notes or auto-open).
local function MigrateWhatsNewSidebarAckIfNeeded()
    local db = EnsureRootDB()
    if db.patchNotesWhatsNewSidebarAckedVersion ~= nil then return end
    local cur = GetCurrentVersion()
    MigratePatchNotesVersionIfNeeded()
    if cur ~= "" and GetPatchNotesLastViewedVersion() == cur then
        db.patchNotesWhatsNewSidebarAckedVersion = cur
    else
        db.patchNotesWhatsNewSidebarAckedVersion = ""
    end
end

local function GetWhatsNewSidebarAckedVersion()
    MigrateWhatsNewSidebarAckIfNeeded()
    local db = _G[addon.DATABASE]
    return (db and db.patchNotesWhatsNewSidebarAckedVersion) or ""
end

--- True when the installed version has not been acknowledged via Patch Notes.
--- @return boolean
function addon.PatchNotes_HasUnread()
    local cur = GetCurrentVersion()
    if cur == "" then return false end
    return GetPatchNotesLastViewedVersion() ~= cur
end

--- Mark the current addon version as viewed; refreshes minimap and dashboard indicators.
--- @return nil
function addon.PatchNotes_MarkCurrentVersionViewed()
    local cur = GetCurrentVersion()
    if cur == "" then return end
    SetPatchNotesLastViewedVersion(cur)
    addon.PatchNotes_RefreshAttentionIndicators()
end

--- Call when the user clicks the Axis sidebar Patch Notes row (clears sidebar New!/green only).
--- @return nil
function addon.PatchNotes_MarkWhatsNewSidebarClicked()
    local cur = GetCurrentVersion()
    if cur == "" then return end
    local db = EnsureRootDB()
    db.patchNotesWhatsNewSidebarAckedVersion = cur
    addon.PatchNotes_RefreshAttentionIndicators()
end

--- True while this version should show sidebar (New!) and green until the sidebar row is clicked.
--- @return boolean
function addon.PatchNotes_HasUnreadSidebarAttention()
    local cur = GetCurrentVersion()
    if cur == "" then return false end
    return GetWhatsNewSidebarAckedVersion() ~= cur
end

-- Sidebar: green when unread; brighter green when that row is selected; idle/white otherwise.
local WHATSNEW_GREEN_R, WHATSNEW_GREEN_G, WHATSNEW_GREEN_B = 0.32, 0.90, 0.50
local WHATSNEW_GREEN_ACTIVE_R, WHATSNEW_GREEN_ACTIVE_G, WHATSNEW_GREEN_ACTIVE_B = 0.55, 1, 0.72
local WHATSNEW_IDLE_R, WHATSNEW_IDLE_G, WHATSNEW_IDLE_B = 0.65, 0.65, 0.70

--- Set Patch Notes sidebar label to unread green when applicable; icon uses normal sidebar tints (not green).
--- @param btn table Sidebar button with _sidebarViewGetter
--- @param lbl FontString
--- @param icon Texture|nil
--- @param isHover boolean
--- @return nil
function addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, lbl, icon, isHover)
    if not btn or not lbl then return end
    local sidebarAttention = addon.PatchNotes_HasUnreadSidebarAttention and addon.PatchNotes_HasUnreadSidebarAttention()
    local isWhatsNewRowActive = false
    if btn._sidebarViewGetter then
        isWhatsNewRowActive = (btn._sidebarViewGetter() == "whatsnew")
    end
    -- Match CreateSidebarButton icon behaviour (green is label-only).
    local function applySidebarIconVertex()
        if not icon then return end
        if isWhatsNewRowActive then
            icon:SetVertexColor(1, 1, 1, 1)
        elseif isHover then
            icon:SetVertexColor(0.9, 0.9, 0.95, 1)
        else
            icon:SetVertexColor(0.6, 0.6, 0.65, 1)
        end
    end
    if sidebarAttention then
        applySidebarIconVertex()
        if isWhatsNewRowActive then
            if isHover then
                lbl:SetTextColor(0.68, 1, 0.80, 1)
            else
                lbl:SetTextColor(WHATSNEW_GREEN_ACTIVE_R, WHATSNEW_GREEN_ACTIVE_G, WHATSNEW_GREEN_ACTIVE_B, 1)
            end
        else
            if isHover then
                lbl:SetTextColor(0.40, 0.96, 0.58, 1)
            else
                lbl:SetTextColor(WHATSNEW_GREEN_R, WHATSNEW_GREEN_G, WHATSNEW_GREEN_B, 1)
            end
        end
    else
        if isWhatsNewRowActive then
            lbl:SetTextColor(1, 1, 1, 1)
            if icon then
                icon:SetVertexColor(1, 1, 1, 1)
            end
        else
            if isHover then
                lbl:SetTextColor(0.9, 0.9, 0.95, 1)
                if icon then
                    icon:SetVertexColor(0.9, 0.9, 0.95, 1)
                end
            else
                lbl:SetTextColor(WHATSNEW_IDLE_R, WHATSNEW_IDLE_G, WHATSNEW_IDLE_B, 1)
                if icon then
                    icon:SetVertexColor(0.6, 0.6, 0.65, 1)
                end
            end
        end
    end
end

--- Update minimap marker and dashboard Patch Notes label when unread state changes.
--- @return nil
function addon.PatchNotes_RefreshAttentionIndicators()
    if addon.MinimapButton_UpdatePatchNotesBadge then
        addon.MinimapButton_UpdatePatchNotesBadge()
    end
    local dash = _G.HorizonSuiteDashboard
    local btn = dash and dash.whatsnewSidebarBtn
    if btn and btn.label then
        local L = addon.L
        local base = btn._whatsNewBaseText or (L and L["DASH_WHATS_NEW"]) or "Patch Notes"
        local suffix = (L and L["DASH_WHATS_NEW_UNREAD_SUFFIX"]) or " (New!)"
        local sidebarAttention = addon.PatchNotes_HasUnreadSidebarAttention and addon.PatchNotes_HasUnreadSidebarAttention()
        if sidebarAttention then
            btn.label:SetText(base .. suffix)
        else
            btn.label:SetText(base)
        end
        if addon.PatchNotes_ApplyWhatsNewSidebarRowStyle then
            addon.PatchNotes_ApplyWhatsNewSidebarRowStyle(btn, btn.label, btn.icon, false)
        end
    end
end

-- Long UK order (day month year), English month names — same on every client next to English patch bullets.
local PATCH_NOTE_MONTHS_ENGLISH = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
}

--- Format an ISO date for the Patch Notes dashboard header (e.g. "31 March 2026").
--- Uses fixed English months; validates the calendar date via time/date.
--- @param iso string|nil "YYYY-MM-DD"
--- @return string|nil Display string, or nil if iso is missing or not a valid date.
function addon.PatchNotes_FormatIsoDateLongUK(iso)
    if type(iso) ~= "string" or iso == "" then return nil end
    local ys, ms, ds = iso:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    local y = tonumber(ys)
    local m = tonumber(ms)
    local d = tonumber(ds)
    if not y or not m or not d then return nil end
    if m < 1 or m > 12 or d < 1 or d > 31 then return nil end
    if not time or not date then return nil end
    local ts = time({ year = y, month = m, day = d, hour = 12 })
    if not ts or ts <= 0 then return nil end
    local tt = date("*t", ts)
    if not tt or tt.year ~= y or tt.month ~= m or tt.day ~= d then return nil end
    local monthName = PATCH_NOTE_MONTHS_ENGLISH[m]
    if not monthName then return nil end
    return string.format("%d %s %d", d, monthName, y)
end

-- ============================================================================
-- PUBLIC API (delegates to the inline Dashboard view)
-- ============================================================================

addon.ShowPatchNotes = function()
    -- Open the dashboard (creates if needed), then navigate to the patch notes view.
    if addon.ShowDashboard then addon.ShowDashboard() end
    C_Timer.After(0, function()
        local frame = _G.HorizonSuiteDashboard
        if frame and frame.ShowPatchNotes then
            frame.ShowPatchNotes()
        end
    end)
end

addon.HidePatchNotes = function() end

--- Refresh accent colours on the patch notes view if it is visible.
--- Called from options when classColorDashboard (Axis → Class Colours) changes.
function addon.ApplyPatchNotesAccent()
    local frame = _G.HorizonSuiteDashboard
    if frame and frame.patchNotesView and frame.patchNotesView:IsShown() then
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
    end
end

-- ============================================================================
-- AUTO-SHOW ON LOGIN
-- ============================================================================

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    MigratePatchNotesVersionIfNeeded()
    local cur = GetCurrentVersion()
    if cur == "" then return end

    if not addon.PatchNotes_HasUnread() then
        addon.PatchNotes_RefreshAttentionIndicators()
        return
    end

    -- Skip the auto-show modal on first install — the user should see the
    -- Welcome onboarding (driven by the dashboard flow gating in
    -- DashboardPanel.lua) before being interrupted by patch notes.
    local rootDB = _G[addon.DATABASE]
    if rootDB and not rootDB.welcomeSeen then
        addon.PatchNotes_RefreshAttentionIndicators()
        return
    end

    local autoShow = true
    if addon.GetDB then
        autoShow = addon.GetDB("autoShowPatchNotesOnLogin", true) and true or false
    end
    if autoShow then
        if C_Timer and C_Timer.After then
            C_Timer.After(2.0, function()
                if addon.PatchNotes_ShowModal then
                    addon.PatchNotes_ShowModal(cur)
                elseif addon.ShowPatchNotes then
                    addon.ShowPatchNotes()
                end
            end)
        elseif addon.PatchNotes_ShowModal then
            addon.PatchNotes_ShowModal(cur)
        elseif addon.ShowPatchNotes then
            addon.ShowPatchNotes()
        end
    end

    -- Minimap button is created later (PLAYER_ENTERING_WORLD + delay); refresh a few times.
    if C_Timer and C_Timer.After then
        C_Timer.After(1.0, function()
            addon.PatchNotes_RefreshAttentionIndicators()
        end)
        C_Timer.After(3.0, function()
            addon.PatchNotes_RefreshAttentionIndicators()
        end)
    end
end)
