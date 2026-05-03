--[[
    Horizon Suite - Dashboard Options Panel
    Entry: slash commands, ShowDashboard, lazy init via options/dashboard/DashboardFrame.lua.
]]


local addon = _G.HorizonSuite

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

    local db    = _G[addon.DATABASE]
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

-- dashboardLastView (root SavedVar) records the user's last "real" location
-- so the dashboard can resume there. Schema:
--   { kind = "news" }
--   { kind = "dashboard" }
--   { kind = "whatsnew" }                                      -- Patch Notes
--   { kind = "module",   name = ..., moduleKey = ... }         -- module landing
--   { kind = "category", modName = ..., catName = ...,
--                        moduleKey = ... }                     -- category drill-down
-- Welcome and Search are intentionally NOT resume targets:
--   - Welcome is one-shot onboarding gated by welcomeSeen.
--   - Search is transient (no meaningful state to restore).
-- Stale string values from earlier builds are coerced to { kind = <string> }.

local SIMPLE_KIND_BY_FN = {
    ShowNews       = "news",
    ShowDashboard  = "dashboard",
    ShowPatchNotes = "whatsnew",
}

local function ReadLastView(db)
    local v = db and db.dashboardLastView or nil
    if type(v) == "string" then return { kind = v } end
    if type(v) == "table" then return v end
    return nil
end

-- Find a category by name in the global category list and return its
-- options (resolving function-typed options).
local function FindCategoryOptions(catName)
    if not catName or not addon.OptionCategories then return nil end
    for _, cat in ipairs(addon.OptionCategories) do
        if cat.name == catName then
            local opts = type(cat.options) == "function" and cat.options() or cat.options
            return opts
        end
    end
    return nil
end

-- Returns a zero-arg function that opens the resolved entry view.
-- Rules:
--   1. First-ever open (no welcomeSeen) → Welcome.
--   2. Otherwise replay dashboardLastView if it's known and resumable.
--   3. Fallback: News (post-onboarding home).
local function ResolveEntryAction(frame)
    local db = _G[addon.DATABASE]
    if not db then
        if frame.ShowWelcome then return frame.ShowWelcome end
        return frame.ShowDashboard or function() end
    end

    if not db.welcomeSeen then
        return frame.ShowWelcome or frame.ShowNews or frame.ShowDashboard
    end

    local last = ReadLastView(db)
    if last then
        local kind = last.kind
        if kind == "news" and frame.ShowNews then
            return frame.ShowNews
        elseif kind == "dashboard" and frame.ShowDashboard then
            return frame.ShowDashboard
        elseif kind == "whatsnew" and frame.ShowPatchNotes then
            return frame.ShowPatchNotes
        elseif kind == "module" and frame.OpenModule and last.moduleKey then
            local name, mk = last.name or last.moduleKey, last.moduleKey
            return function() frame.OpenModule(name, mk) end
        elseif kind == "category" and frame.OpenCategoryDetail and last.catName then
            local options = FindCategoryOptions(last.catName)
            if options then
                local modName, catName = last.modName or "", last.catName
                local mk = last.moduleKey
                return function()
                    -- Prime f.currentModuleKey + sidebar context, then jump into the category.
                    if mk and frame.OpenModule then
                        frame.OpenModule(modName ~= "" and modName or mk, mk, true)
                    end
                    frame.OpenCategoryDetail(modName, catName, options)
                end
            end
        end
    end

    return frame.ShowNews or frame.ShowDashboard
end

-- Wrap navigation entry points once per frame so each call snapshots
-- dashboardLastView. ShowWelcome only flips welcomeSeen (one-shot marker).
local function InstallFlowGatingHooks(frame)
    if not frame or frame._flowGatingHooked then return end

    if type(frame.ShowWelcome) == "function" then
        local origWelcome = frame.ShowWelcome
        frame.ShowWelcome = function(...)
            origWelcome(...)
            local db = _G[addon.DATABASE]
            if db then db.welcomeSeen = true end
        end
    end

    for fnName, kind in pairs(SIMPLE_KIND_BY_FN) do
        local orig = frame[fnName]
        if type(orig) == "function" then
            frame[fnName] = function(...)
                orig(...)
                local db = _G[addon.DATABASE]
                if db then db.dashboardLastView = { kind = kind } end
            end
        end
    end

    -- Module landing pages (sidebar header / standalone module click).
    -- For sidebar subcategory clicks the call site fires OpenModule(...,true)
    -- immediately followed by OpenCategoryDetail — the latter overwrites this
    -- write with kind = "category", which is what we want.
    if type(frame.OpenModule) == "function" then
        local origOpen = frame.OpenModule
        frame.OpenModule = function(name, moduleKey, skipDetailBuild)
            origOpen(name, moduleKey, skipDetailBuild)
            local db = _G[addon.DATABASE]
            if db and moduleKey then
                db.dashboardLastView = {
                    kind = "module",
                    name = name,
                    moduleKey = moduleKey,
                }
            end
        end
    end

    -- Category drill-down (subcategory tile or sidebar sub-row click).
    if type(frame.OpenCategoryDetail) == "function" then
        local origCat = frame.OpenCategoryDetail
        frame.OpenCategoryDetail = function(modName, catName, options, skipEntranceCascade)
            origCat(modName, catName, options, skipEntranceCascade)
            local db = _G[addon.DATABASE]
            if db and catName then
                db.dashboardLastView = {
                    kind = "category",
                    modName = modName,
                    catName = catName,
                    moduleKey = frame.currentModuleKey,
                }
            end
        end
    end

    frame._flowGatingHooked = true
end

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
        if f then
            InstallFlowGatingHooks(f)
            local action = ResolveEntryAction(f)
            if type(action) == "function" then
                action()
            elseif f.ShowDashboard then
                f.ShowDashboard()
            end
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
