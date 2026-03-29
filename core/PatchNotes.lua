--[[
    Horizon Suite - Patch Notes
    Version tracking and auto-show on login.
    The "What's New" view is built inside options/dashboard/DashboardFrame.lua.

    Reopen: /h notes  or the Dashboard "What's New" button.
    Notes data lives in core/PatchNotesData.lua — edit that file each release.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then return end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ============================================================================
-- VERSION / DB
-- ============================================================================

local function GetCurrentVersion()
    local gm = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return (gm and gm(addon.ADDON_NAME, "Version")) or ""
end

local function GetLastSeenVersion()
    local db = _G[addon.DB_NAME]
    return db and db.lastSeenPatchVersion or ""
end

local function SetLastSeenVersion(v)
    local db = _G[addon.DB_NAME]
    if not db then db = {}; _G[addon.DB_NAME] = db end
    db.lastSeenPatchVersion = v
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
    local cur = GetCurrentVersion()
    if cur == "" then return end
    if GetLastSeenVersion() ~= cur then
        SetLastSeenVersion(cur)
        if C_Timer and C_Timer.After then
            C_Timer.After(2.0, function()
                if addon.ShowPatchNotes then addon.ShowPatchNotes() end
            end)
        else
            addon.ShowPatchNotes()
        end
    end
end)
