--[[
    Horizon Suite - Options Data
    Core DB helpers and per-key routing (SetDB side-effects).
    Initialises the empty OptionCategories table that self-registering module
    files populate. Search index lives in OptionsSearch.lua.
]]

local addon = _G.HorizonSuite
if not addon then return end
if not _G[addon.DATABASE] then _G[addon.DATABASE] = {} end

-- ---------------------------------------------------------------------------
-- Migration: early global-font implementation used fontPath as the override key.
-- If useGlobalFont is true but globalOverrideFontPath was never written, the saved
-- fontPath is the old override value.  Copy it to the dedicated key.
-- fontPath is intentionally kept: it serves as the per-module "Global Font" sentinel
-- fallback (Cache, Vista, Presence, Insight all fall through to fontPath when their
-- own per-module key is "__global__" and the override is off).
-- ---------------------------------------------------------------------------
do
    local db = _G[addon.DATABASE]
    if db and db.useGlobalFont and db.globalOverrideFontPath == nil and db.fontPath ~= nil then
        db.globalOverrideFontPath = db.fontPath
    end
end

-- ---------------------------------------------------------------------------
-- SetDB routing
-- ---------------------------------------------------------------------------

-- Populated by OptionsDefaults.lua (loads before this file)
local TYPOGRAPHY_KEYS      = addon.TYPOGRAPHY_KEYS
local COLOR_LIVE_KEYS      = addon.COLOR_LIVE_KEYS
local SCALE_DEBOUNCE_KEYS  = addon.SCALE_DEBOUNCE_KEYS
local CLASS_COLOR_KEYS     = addon.CLASS_COLOR_KEYS

function OptionsData_GetDB(key, default)
    return addon.GetDB(key, default)
end

local updateOptionsPanelFontsRef
function OptionsData_SetUpdateFontsRef(fn)
    updateOptionsPanelFontsRef = fn
end

function OptionsData_SetDB(key, value)
    addon.SetDB(key, value)
    if key == "showWorldQuests" and addon.focus and addon.focus.collapse then
        if value == false then
            addon.focus.collapse.pendingWQCollapse = true
        elseif value == true then
            addon.focus.collapse.pendingWQExpand = true
        end
    end
    -- When the "Show in-zone world quests" toggle is flipped on, invalidate the nearby
    -- WQ scan cache so the next FullLayout immediately re-scans for the current zone.
    if key == "showWorldQuests" and value == true and addon.focus then
        addon.focus.nearbyQuestCacheDirty = true
        addon.focus.nearbyQuestCache = nil
        addon.focus.nearbyTaskQuestCache = nil
    end
    if (key == "fontPath" or key == "titleFontPath" or key == "zoneFontPath" or key == "objectiveFontPath" or key == "sectionFontPath" or key == "progressBarFontPath" or key == "timerFontPath" or key == "optionsFontPath" or key == "presenceTitleFontPath" or key == "presenceSubtitleFontPath" or key == "insightFontPath" or key == "useGlobalFont" or key == "globalOverrideFontPath") and updateOptionsPanelFontsRef then
        updateOptionsPanelFontsRef()
    end
    if TYPOGRAPHY_KEYS[key] and addon.UpdateFontObjectsFromDB then
        addon.UpdateFontObjectsFromDB()
    end
    -- When the global-font override toggle changes, or when fontPath changes while
    -- the override is active, push the new font through every module immediately.
    -- (useGlobalFont is in TYPOGRAPHY_KEYS so UpdateFontObjectsFromDB already ran;
    --  this block handles the per-module apply functions that sit outside that path.)
    if key == "useGlobalFont" or (key == "globalOverrideFontPath" and addon.GetDB and addon.GetDB("useGlobalFont", false)) then
        if addon.Cache and addon.Cache.ApplyScale then addon.Cache.ApplyScale() end
        if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
        if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
        if addon.Essence and addon.Essence.ApplyEssenceOptions then addon.Essence.ApplyEssenceOptions() end
        if addon.Vista and addon.Vista.ApplyOptions then
            local k = key
            C_Timer.After(0, function() if addon.Vista and addon.Vista.ApplyOptions then addon.Vista.ApplyOptions(k) end end)
        end
    end
    if addon.MPLUS_TYPOGRAPHY_KEYS and addon.MPLUS_TYPOGRAPHY_KEYS[key] and addon.ApplyMplusTypography then
        addon.ApplyMplusTypography()
    end
    if addon.MPLUS_EMBEDDED_MARKUP_KEYS and addon.MPLUS_EMBEDDED_MARKUP_KEYS[key] and addon.UpdateMplusBlock then
        addon.UpdateMplusBlock()
    end
    if addon.PRESENCE_KEYS and addon.PRESENCE_KEYS[key] and addon.Presence then
        if addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
        if addon.Presence.ApplyBlizzardSuppression then addon.Presence.ApplyBlizzardSuppression() end
    end
    if addon.INSIGHT_KEYS and addon.INSIGHT_KEYS[key] and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
    end
    if addon.ESSENCE_KEYS and addon.ESSENCE_KEYS[key] and addon.Essence and addon.Essence.ApplyEssenceOptions then
        addon.Essence.ApplyEssenceOptions()
    end
    if addon.CACHE_KEYS and addon.CACHE_KEYS[key] and addon.Cache and addon.Cache.ApplyCacheOptions then
        addon.Cache.ApplyCacheOptions()
    end
    if addon.DASHBOARD_CLASS_ICON_KEYS and addon.DASHBOARD_CLASS_ICON_KEYS[key] then
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
    end
    if addon.DASHBOARD_BACKGROUND_KEYS and addon.DASHBOARD_BACKGROUND_KEYS[key] then
        if addon.ApplyDashboardBackground then addon.ApplyDashboardBackground() end
    end
    if addon.DASHBOARD_TYPOGRAPHY_KEYS and addon.DASHBOARD_TYPOGRAPHY_KEYS[key] then
        if addon.ApplyDashboardTypography then addon.ApplyDashboardTypography() end
    end
    if CLASS_COLOR_KEYS[key] then
        if key == "classColorDashboard" then
            if addon.ApplyOptionsClassColor then addon.ApplyOptionsClassColor() end
            if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            if addon.ApplyPatchNotesAccent then addon.ApplyPatchNotesAccent() end
            if addon.ApplyURLCopyBoxAccent then addon.ApplyURLCopyBoxAccent() end
            if addon.focus.ApplyAuctionCraftDialogAccent then addon.focus.ApplyAuctionCraftDialogAccent() end
        end
        if key == "classColorVista" and addon.Vista and addon.Vista.ApplyColors then
            addon.Vista.ApplyColors()
        end
        if key == "classColorInsight" and addon.Insight and addon.Insight.ApplyInsightOptions then
            addon.Insight.ApplyInsightOptions()
        end
        if key == "classColorEssence" and addon.Essence and addon.Essence.ApplyEssenceOptions then
            addon.Essence.ApplyEssenceOptions()
        end
        if key == "classColorFocus" and addon.ApplyFocusColors then
            addon.ApplyFocusColors()
        end
        if key == "classColorPresence" and addon.Presence and addon.Presence.ApplyPresenceOptions then
            addon.Presence.ApplyPresenceOptions()
        end
        if key == "classColorCache" and addon.Cache and addon.Cache.ApplyCacheOptions then
            addon.Cache.ApplyCacheOptions()
        end
    end
    if addon.VISTA_KEYS and addon.VISTA_KEYS[key] and addon.Vista then
        if addon._colorPickerLive and addon.VISTA_COLOR_LIVE_KEYS and addon.VISTA_COLOR_LIVE_KEYS[key] then
            if addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
        elseif addon.Vista.ApplyOptions or addon.Vista.ApplyLockOnlyOptions then
            local fn
            if addon.VISTA_SKIP_FULL_LAYOUT_KEYS and addon.VISTA_SKIP_FULL_LAYOUT_KEYS[key] and addon.Vista.ApplyLockOnlyOptions then
                fn = addon.Vista.ApplyLockOnlyOptions
            else
                local vistaKey = key
                fn = function()
                    if addon.Vista and addon.Vista.ApplyOptions then
                        addon.Vista.ApplyOptions(vistaKey)
                    end
                end
            end
            -- vistaLock: apply immediately when not in combat for responsive toggle feedback
            if key == "vistaLock" and not InCombatLockdown() then
                fn()
            elseif C_Timer and C_Timer.After then
                C_Timer.After(0, fn)
            else
                fn()
            end
        end
    end
    -- vistaButtonManaged_* keys trigger a full button re-collect
    if key:sub(1, 19) == "vistaButtonManaged_" and addon.Vista and addon.Vista.ApplyOptions then
        local managedKey = key
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if addon.Vista and addon.Vista.ApplyOptions then
                    addon.Vista.ApplyOptions(managedKey)
                end
            end)
        else
            addon.Vista.ApplyOptions(managedKey)
        end
    end
    if key == "lockPosition" and addon.UpdateResizeHandleVisibility then
        addon.UpdateResizeHandleVisibility()
    end
    if (key == "backdropOpacity" or key == "backdropColorR" or key == "backdropColorG" or key == "backdropColorB") and addon.ApplyBackdropOpacity then
        addon.ApplyBackdropOpacity()
    end
    if key == "insightBgOpacity" and addon.Insight and addon.Insight.ApplyInsightOptions then
        addon.Insight.ApplyInsightOptions()
    end
    if addon._colorPickerLive and COLOR_LIVE_KEYS[key] then
        OptionsData_NotifyMainAddon_Live()
        return
    end
    -- Scale keys are handled by debounced callbacks in the slider set lambdas.
    -- Do NOT call NotifyMainAddon here or FullLayout runs on every integer drag step.
    if SCALE_DEBOUNCE_KEYS[key] then return end
    -- Current Quest expiry ticker: restart when toggle or window changes.
    if (key == "showCurrentQuestCategory" or key == "currentQuestWindowSec") and addon.StopCurrentQuestExpiryTicker and addon.StartCurrentQuestExpiryTicker then
        addon.StopCurrentQuestExpiryTicker()
        if key == "showCurrentQuestCategory" then
            if value == true and addon.focus and addon.focus.enabled then
                addon.StartCurrentQuestExpiryTicker()
            end
        elseif addon.GetDB("showCurrentQuestCategory", true) and addon.focus and addon.focus.enabled then
            addon.StartCurrentQuestExpiryTicker()
        end
    end
    if key == "minimapButtonShowOnlyOnMinimapHover" and addon.MinimapButton_UpdateVisibility then
        addon.MinimapButton_UpdateVisibility()
    end
    if addon.VISTA_KEYS and addon.VISTA_KEYS[key] and not (addon.VISTA_KEYS_REQUIRE_NOTIFY and addon.VISTA_KEYS_REQUIRE_NOTIFY[key]) then return end
    if key:sub(1, 19) == "vistaButtonManaged_" then return end
    OptionsData_NotifyMainAddon()
end

--- Lightweight notify for live color picker: updates visuals without FullLayout.
function OptionsData_NotifyMainAddon_Live()
    local applyTy = addon.ApplyTypography or _G.HorizonSuite_ApplyTypography
    if applyTy then applyTy() end
    if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
    if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
    if addon.ApplyFocusColors then addon.ApplyFocusColors() end
    if addon.Vista and addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
    if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
end

function OptionsData_NotifyMainAddon()
    -- Bust the per-entry populate-signature cache so option changes (objectivePrefixStyle,
    -- showZoneLabels, useTickForCompletedObjectives, etc.) take effect on the next FullLayout
    -- instead of waiting for /reload or a fingerprinted qData field to perturb.
    if addon.focus and addon.focus.InvalidatePopulateCache then addon.focus.InvalidatePopulateCache() end
    local applyTy = addon.ApplyTypography or _G.HorizonSuite_ApplyTypography
    if applyTy then applyTy() end
    if addon.ApplyDimensions then addon.ApplyDimensions()
    elseif _G.HorizonSuite_ApplyDimensions then _G.HorizonSuite_ApplyDimensions() end
    if addon.ApplyBackdropOpacity then addon.ApplyBackdropOpacity() end
    if addon.ApplyBorderVisibility then addon.ApplyBorderVisibility() end
    -- Re-apply colours and bar textures on visible entries; FullLayout repositions
    -- but does not re-run the per-entry renderer that calls SetTexture, so without
    -- this call texture/colour changes wait for an aggregator pass or /reload.
    if addon.ApplyFocusColors then addon.ApplyFocusColors() end
    if addon.RequestRefresh then addon.RequestRefresh()
    elseif _G.HorizonSuite_RequestRefresh then _G.HorizonSuite_RequestRefresh() end
    local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
    if fullLayout and not InCombatLockdown() then fullLayout() end
end


-- ---------------------------------------------------------------------------
-- OptionCategories: populated at load time by self-registering module files
-- in TOC order. Read-only after initial load.
-- ---------------------------------------------------------------------------

local OptionCategories = {
}

local function getVisibleCategories()
    local out = {}
    for _, cat in ipairs(OptionCategories) do
        out[#out + 1] = cat
    end
    return out
end

-- Export for panel and module option files
addon.OptionsData_GetDB = OptionsData_GetDB
addon.OptionsData_SetDB = OptionsData_SetDB
addon.OptionsData_GetFontList = function()
    if addon.RefreshFontList then addon.RefreshFontList() end
    return (addon.GetFontList and addon.GetFontList()) or {}
end
addon.OptionsData_NotifyMainAddon   = OptionsData_NotifyMainAddon
addon.OptionsData_SetUpdateFontsRef = OptionsData_SetUpdateFontsRef
addon.OptionCategories              = getVisibleCategories()
