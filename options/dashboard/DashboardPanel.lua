--[[
    Horizon Suite - Dashboard Options Panel
    Entry: slash commands, ShowDashboard, lazy init via options/dashboard/DashboardFrame.lua.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local f = _G.HorizonSuiteDashboard

-- ---------------------------------------------------------------------------
-- ApplyDashboardSizeFromDB: reads dashboardSizeRatio / TopLeftX / TopLeftY
-- from the root DB, applies auto-shrink clamping, and positions the frame.
-- Returns the resolved ratio (nil if native 1.0 with no saved position).
-- Must be called AFTER the frame is built but BEFORE Show().
-- The caller is responsible for the single deferred Dashboard_CommitResize call.
-- ---------------------------------------------------------------------------
local function ApplyDashboardSizeFromDB(frame)
    if not frame then return end

    local DC = addon.DashboardConstants
    if not DC then return end

    local db    = _G[addon.DB_NAME]
    local ratio = db and tonumber(db.dashboardSizeRatio)
    local pinX  = db and tonumber(db.dashboardTopLeftX)
    local pinY  = db and tonumber(db.dashboardTopLeftY)

    -- Auto-shrink: clamp ratio so the frame fits within UIParent.
    -- Use UIParent:GetWidth/Height — NOT GetScreenWidth/GetScreenHeight,
    -- because raw screen pixels differ from virtual UI units when UIParent
    -- scale is not 1.0 (e.g. Steam Deck at ~0.64–0.71 UIParent scale).
    local parentW = UIParent:GetWidth()
    local parentH = UIParent:GetHeight()
    if parentW and parentW > 0 and DC.NATIVE_W and DC.NATIVE_W > 0 then
        local maxRatioW = parentW / DC.NATIVE_W
        if ratio then
            ratio = math.min(ratio, maxRatioW)
        else
            -- Default 1.0 but still clamp
            if maxRatioW < 1.0 then ratio = maxRatioW end
        end
    end
    if parentH and parentH > 0 and DC.NATIVE_H and DC.NATIVE_H > 0 then
        local maxRatioH = parentH / DC.NATIVE_H
        if ratio then
            ratio = math.min(ratio, maxRatioH)
        else
            if maxRatioH < 1.0 then ratio = maxRatioH end
        end
    end

    if ratio then
        ratio = math.max(0.5, math.min(2.0, ratio))
    end

    -- Position
    frame:ClearAllPoints()
    if pinX and pinY then
        -- Saved top-left; clamp all four edges so the frame is fully on-screen
        -- even after a screen resolution change or ratio adjustment.
        -- Use ratio if saved; fall back to 1.0 (native size) for bounds math when
        -- only position was saved (user moved but never resized).
        local effectiveRatio = ratio or 1.0
        local finalW = DC.NATIVE_W * effectiveRatio
        local finalH = DC.NATIVE_H * effectiveRatio
        local pw = parentW or DC.NATIVE_W
        local ph = parentH or DC.NATIVE_H
        -- Coordinates are relative to UIParent BOTTOMLEFT (X right, Y up).
        -- safeX: left edge between 0 (screen left) and pw-finalW (right edge at screen right).
        -- safeY: top edge between finalH (bottom edge at screen bottom) and ph (top edge at screen top).
        local safeX = math.max(0, math.min(pinX, pw - finalW))
        local safeY = math.max(finalH, math.min(pinY, ph))
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", safeX, safeY)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    -- Return the resolved ratio for the caller to use in a single deferred CommitResize.
    return ratio
end

addon.ShowDashboard = function()
    if SlashCmdList["HSDASH"] then SlashCmdList["HSDASH"]("") end
end
_G.HorizonSuite_ShowDashboard = addon.ShowDashboard

SLASH_HSDASH1 = "/hsd"
SLASH_HSDASH2 = "/dash"
SlashCmdList["HSDASH"] = function(msg)
    f = f or _G.HorizonSuiteDashboard
    if f and f:IsShown() then
        f:Hide()
    else
        if not f then
            if addon.Dashboard_BuildMainFrame then
                f = addon.Dashboard_BuildMainFrame()
            end
        end
        if f and f.ShowWelcome then
            f.ShowWelcome()
        elseif f and f.ShowDashboard then
            f.ShowDashboard()
        end
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        if addon.DashboardPreview and addon.DashboardPreview.InitDashboard then
            addon.DashboardPreview.InitDashboard(f)
        end
        if f then
            -- Apply saved size/position before showing; capture the resolved ratio
            -- (includes auto-shrink for small screens) for the single deferred reflow.
            local savedRatio = ApplyDashboardSizeFromDB(f)
            f:Show()
            -- Single deferred CommitResize: fires after the engine has completed the
            -- frame's first layout pass so all child frames report correct dimensions.
            if savedRatio then
                C_Timer.After(0, function()
                    if f and f:IsShown() and f.Dashboard_CommitResize then
                        f.Dashboard_CommitResize(math.max(0.5, math.min(2.0, savedRatio)))
                    end
                end)
            end
            if addon.PatchNotes_RefreshAttentionIndicators then
                addon.PatchNotes_RefreshAttentionIndicators()
            end
        end
    end
end
