--[[
    Horizon Suite - Focus - SilverDragon Integration
    Widget lifecycle, portrait model, nav buttons, waypoint, and coord-click for SilverDragon alerts.
]]

local addon = _G.HorizonSuite
local L = addon.L
addon.focus    = addon.focus    or {}
addon.focus.sd = addon.focus.sd or {}

local sd = addon.focus.sd

-- ---------------------------------------------------------------------------
-- Helper / constants
-- ---------------------------------------------------------------------------

local function S(v)
    return (addon.Scaled and addon.Scaled(v)) or v
end

sd.SD_MODEL_SIZE  = 64

local SD_NAV_BTN_W    = 16
local SD_NAV_BTN_H    = 60
local SD_NAV_BTN_GAP  = 3
local SD_NAV_ARROW_SZ = 14
local SD_SKULL_MARKER = 8

-- ---------------------------------------------------------------------------
-- Model clip envelope — used for "left" portrait mode.
-- ---------------------------------------------------------------------------
local sdModelClipFrame
local function GetOrCreateSDModelClipFrame()
    if sdModelClipFrame then return sdModelClipFrame end
    local sf = addon.scrollFrame
    if not addon.HS or not sf then return addon.HS end
    sdModelClipFrame = CreateFrame("Frame", nil, addon.HS)
    sdModelClipFrame:SetClipsChildren(true)
    sdModelClipFrame:SetPoint("TOPLEFT",     sf, "TOPLEFT",     -200, 0)
    sdModelClipFrame:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT",    0, 0)
    return sdModelClipFrame
end

-- ---------------------------------------------------------------------------
-- IsActive
-- ---------------------------------------------------------------------------

function sd.IsActive()
    return rawget(_G, "HorizonSilverDragon") ~= nil and addon.GetDB("sd_enabled", false)
end

-- ---------------------------------------------------------------------------
-- Native popup suppression
-- ---------------------------------------------------------------------------

local hookedNativePopupFrames = setmetatable({}, { __mode = "k" })

local function HookNativePopupMouse(frame)
    if not frame or hookedNativePopupFrames[frame] or not hooksecurefunc or not frame.EnableMouse then return end
    hookedNativePopupFrames[frame] = true
    hooksecurefunc(frame, "EnableMouse", function(self, enabled)
        if not enabled or not addon.GetDB("sd_enabled", false) then return end
        if InCombatLockdown and InCombatLockdown() then return end
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if self and self.EnableMouse then
                    pcall(function() self:EnableMouse(false) end)
                    if self.EnableMouseWheel then pcall(function() self:EnableMouseWheel(false) end) end
                end
            end)
        else
            pcall(function() self:EnableMouse(false) end)
            if self.EnableMouseWheel then pcall(function() self:EnableMouseWheel(false) end) end
        end
    end)
end

local function DisableNativePopupFrame(frame)
    if not frame or not frame.Hide then return end
    HookNativePopupMouse(frame)
    if InCombatLockdown and InCombatLockdown() then
        pcall(function() frame:SetAlpha(0) end)
        return
    end
    pcall(function()
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -2000, 2000)
        frame:SetSize(1, 1)
    end)
    pcall(function() frame:Hide() end)
    if frame.EnableMouse then pcall(function() frame:EnableMouse(false) end) end
    if frame.EnableMouseWheel then pcall(function() frame:EnableMouseWheel(false) end) end
end

function sd.SuppressNativePopups()
    if not addon.GetDB("sd_enabled", false) then return end
    local sdp = rawget(_G, "HorizonSilverDragon")
    if not sdp then return end
    if sdp.ApplyPopupSuppression then
        pcall(sdp.ApplyPopupSuppression, true)
    end

    -- Alpha-zero frames still receive mouse input.  If the companion exposes its
    -- native alert frame, hide it and disable mouse so Focus widgets remain clickable.
    DisableNativePopupFrame(sdp.alertFrame)
    DisableNativePopupFrame(sdp.popupFrame)
    DisableNativePopupFrame(sdp.frame)
    DisableNativePopupFrame(sdp.modelFrame)
end

local function ShowCreatureTooltipFrom(btn)
    local entry = btn and btn._ownerEntry
    if entry and entry.GetScript then
        local onEnter = entry:GetScript("OnEnter")
        if onEnter then pcall(onEnter, entry) end
    end

    local creatureID = btn and btn._creatureID
    if not creatureID or not GameTooltip then return end

    local link = ("unit:Creature-0-0-0-0-%d-0000000000"):format(creatureID)
    if addon.focus and addon.focus.AnchorTooltip then
        addon.focus.AnchorTooltip(GameTooltip, btn)
    else
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    end
    pcall(GameTooltip.SetHyperlink, GameTooltip, link)

    local att = _G.AllTheThings
    if att and att.Modules and att.Modules.Tooltip then
        local attach = att.Modules.Tooltip.AttachTooltipSearchResults
        local searchFn = att.SearchForObject or att.SearchForField
        if attach and searchFn then
            pcall(attach, GameTooltip, searchFn, "npcID", creatureID)
        end
    end

    if addon.GetDB("focusShowWoWheadLink", true) then
        local hint = addon.focus and addon.focus.GetWoWheadClickBindingHint and addon.focus.GetWoWheadClickBindingHint() or ""
        if hint == "" then
            hint = L["FOCUS_WOWHEAD_TOOLTIP_HINT_FALLBACK"] or ""
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(("|cff66b3ff[%s]|r |cff888888(%s)|r"):format(L["FOCUS_VIEW_WOWHEAD"] or "View on WoWhead", hint))
    end

    GameTooltip:Show()
end

local function HideCreatureTooltipFrom(btn)
    if GameTooltip then GameTooltip:Hide() end
    local entry = btn and btn._ownerEntry
    if entry and entry.GetScript then
        local onLeave = entry:GetScript("OnLeave")
        if onLeave then pcall(onLeave, entry) end
    end
end

-- ---------------------------------------------------------------------------
-- DismissCurrentAlert
-- ---------------------------------------------------------------------------

function sd.DismissCurrentAlert()
    local sdp = rawget(_G, "HorizonSilverDragon")
    if not sdp or not sdp.alertOrder or #sdp.alertOrder == 0 or (sdp.alertIndex or 0) == 0 then return end
    local idx      = sdp.alertIndex
    local alertKey = sdp.alertOrder[idx]
    table.remove(sdp.alertOrder, idx)
    if sdp.alertQueue then sdp.alertQueue[alertKey] = nil end
    if #sdp.alertOrder == 0 then
        sdp.alertIndex = 0
    elseif idx > #sdp.alertOrder then
        sdp.alertIndex = #sdp.alertOrder
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

-- ---------------------------------------------------------------------------
-- PlayerModel alpha sync — PlayerModel ignores inherited alpha AND SetAlpha has
-- no effect on the 3D renderer; the only reliable control is Hide()/Show().
-- Hide whenever the panel is not fully visible; show only at full opacity.
-- ---------------------------------------------------------------------------
do
    local HS = addon.HS
    if HS then
        local lastAlpha = 1
        local function SyncSDModels(alpha)
            if math.abs(alpha - lastAlpha) < 0.001 then return end
            lastAlpha = alpha
            local pool = addon.pool
            if not pool then return end
            local fullyVisible = alpha >= 0.99
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.sdModel then
                    if fullyVisible and e.sdModelActive then
                        e.sdModel:Show()
                    else
                        e.sdModel:Hide()
                    end
                end
            end
        end
        HS:HookScript("OnHide",   function() SyncSDModels(0) end)
        HS:HookScript("OnShow",   function() SyncSDModels(HS:GetAlpha()) end)
        HS:HookScript("OnUpdate", function() SyncSDModels(HS:GetAlpha()) end)
    end
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", function()
        if sd.SuppressNativePopups then sd.SuppressNativePopups() end
    end)
end

-- ---------------------------------------------------------------------------
-- Widget lifecycle
-- ---------------------------------------------------------------------------

function sd.InitNavWidgets(entry)
    local btnW    = S(SD_NAV_BTN_W)
    local btnH    = S(SD_NAV_BTN_H)
    local arrowSz = S(SD_NAV_ARROW_SZ)

    entry.sdPrevBtn = addon.CreateNavArrowBtn(entry, "common-icon-backarrow",  btnW, btnH, arrowSz)
    entry.sdPrevBtn:SetPoint("TOPLEFT", entry, "TOPLEFT", 0, 0)

    entry.sdNextBtn = addon.CreateNavArrowBtn(entry, "common-icon-forwardarrow", btnW, btnH, arrowSz)
    entry.sdNextBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)

    entry.sdPrevBtn:SetScript("OnClick", function()
        local sdp = rawget(_G, "HorizonSilverDragon")
        if sdp and sdp.NavigatePrev then sdp.NavigatePrev() end
    end)
    entry.sdNextBtn:SetScript("OnClick", function()
        local sdp = rawget(_G, "HorizonSilverDragon")
        if sdp and sdp.NavigateNext then sdp.NavigateNext() end
    end)

    entry.sdModelActive = false

    entry.sdTargetBtn = addon.CreateNavSecureBtn()
    entry.sdModelBtn  = addon.CreateNavSecureBtn()
    entry.sdTargetBtn:SetScript("OnEnter", ShowCreatureTooltipFrom)
    entry.sdTargetBtn:SetScript("OnLeave", HideCreatureTooltipFrom)
    entry.sdModelBtn:SetScript("OnEnter", ShowCreatureTooltipFrom)
    entry.sdModelBtn:SetScript("OnLeave", HideCreatureTooltipFrom)
end

function sd.ClearNavWidgets(entry)
    if entry.sdPrevBtn   then entry.sdPrevBtn:Hide()   end
    if entry.sdNextBtn   then entry.sdNextBtn:Hide()   end
    if entry.sdModel     then
        entry.sdModel:ClearModel()
        entry.sdModel:Hide()
        entry.sdModelActive = false
    end
    entry._sdLastCreatureID = nil  -- reset so next render always clears before loading a new creature
    if entry._sdPortraitClip then entry._sdPortraitClip:ClearAllPoints() end
    entry._sdModelParent = nil
    if not InCombatLockdown() then
        if entry.sdTargetBtn then entry.sdTargetBtn:Hide() end
        if entry.sdModelBtn  then entry.sdModelBtn:Hide()  end
    end
end

-- ---------------------------------------------------------------------------
-- Nav gutter
-- ---------------------------------------------------------------------------

function sd.CalcNavGutter(questData, entry, showQuestIcons)
    -- Sync SD_MODEL_SIZE from DB so FocusEntryRenderer reads the current value.
    sd.SD_MODEL_SIZE = math.max(32, math.min(128, tonumber(addon.GetDB("sd_modelSize", 64)) or 64))
    -- sdAlertIndex is present on every SD alert (mob and vignette alike) and
    -- absent on all RS/quest entries. Without this guard, an RS NPC entry that
    -- shares a pool slot previously used by SD would also carry creatureID,
    -- causing sdModel to be shown incorrectly. rs.CalcNavGutter has a symmetric
    -- rsIsNPC guard for the same reason.
    local showModel = (showQuestIcons ~= false)
        and questData.sdAlertIndex ~= nil
        and questData.creatureID ~= nil
        and addon.GetDB("sd_showPortrait", true)
    return false, S(SD_NAV_BTN_W), S(SD_NAV_BTN_GAP), showModel and true or false
end

-- ---------------------------------------------------------------------------
-- Portrait rendering
-- ---------------------------------------------------------------------------

function sd.TryRenderPortrait(entry, questData, showQuestIcons)
    sd.SuppressNativePopups()
    if not (showQuestIcons and questData.sdAlertIndex and questData.creatureID and addon.GetDB("sd_showPortrait", true)) then
        if entry.sdModel then
            entry.sdModel:ClearModel()
            entry.sdModel:Hide()
            entry.sdModelActive = false
        end
        return false
    end
    local initPos  = addon.GetDB("sd_modelPosition", "right")
    local initOffX = math.max(-100, math.min(100, tonumber(addon.GetDB("sd_modelOffsetX", 0)) or 0))
    -- Left mode uses a two-level clip hierarchy:
    --   sdModelClipFrame (global, child of HS) → extends 200 px left of the tracker
    --   entry._sdPortraitClip (per-entry)      → anchored to entry bounds, clips portrait
    --                                             height so it cannot bleed into adjacent
    --                                             entries when two scanner alerts stack.
    -- Right mode: portrait is a direct child of entry; SetClipsChildren(true) on pool
    -- entries handles height clamping.
    local mParent
    if initPos == "left" then
        if not entry._sdPortraitClip then
            local clip = CreateFrame("Frame", nil, GetOrCreateSDModelClipFrame())
            clip:SetClipsChildren(true)
            entry._sdPortraitClip = clip
        end
        entry._sdPortraitClip:ClearAllPoints()
        entry._sdPortraitClip:SetPoint("TOPLEFT",     entry, "TOPLEFT",     -200, 0)
        entry._sdPortraitClip:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT",    0, 0)
        mParent = entry._sdPortraitClip
    else
        if entry._sdPortraitClip then entry._sdPortraitClip:ClearAllPoints() end
        mParent = entry
    end
    if entry.sdModel and entry._sdModelParent ~= mParent and not InCombatLockdown() then
        entry.sdModel:ClearModel()
        entry.sdModel:Hide()
        entry.sdModel:ClearAllPoints()
        entry.sdModel:SetParent(mParent)
        entry._sdModelParent = mParent
        entry._sdLastCreatureID = nil
    end
    if not entry.sdModel then
        local modelSz = S(sd.SD_MODEL_SIZE)
        local m = CreateFrame("PlayerModel", nil, mParent)
        if m then
            m:SetSize(modelSz, modelSz)
            m:SetPoint("TOPRIGHT", entry, initPos == "left" and "TOPLEFT" or "TOPRIGHT", initOffX, 0)
            -- Mouse disabled so sdModelBtn (higher frame level) receives all clicks.
            m:EnableMouse(false)
            -- Guard against creatures with no valid model (FileData ID 0 = fallback).
            -- SetCreature loads asynchronously, so we check after the load resolves.
            m:SetScript("OnModelLoaded", function(self)
                local fid = self.GetModelFileID and self:GetModelFileID()
                if not fid or fid == 0 then
                    self:Hide()
                    entry.sdModelActive = false
                    if entry.sdModelBtn and not InCombatLockdown() then
                        entry.sdModelBtn:Hide()
                    end
                    entry.questTypeIcon:Show()
                end
            end)
            entry.sdModel = m
            entry._sdModelParent = mParent
        end
    end
    if entry.sdModel then
        entry.questTypeIcon:Hide()
        if entry._sdLastCreatureID ~= questData.creatureID then
            -- SetCreature loads asynchronously; without ClearModel first, the
            -- previous creature's mesh lingers until the new one finishes loading.
            entry.sdModel:ClearModel()
            entry._sdLastCreatureID = questData.creatureID
        end
        entry.sdModel:Show()
        entry.sdModel:SetCreature(questData.creatureID)
        if addon.HS and addon.HS:GetAlpha() < 0.99 then
            entry.sdModel:Hide()
        end
        return true
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Nav button + model rendering
-- ---------------------------------------------------------------------------

-- showSdNav / sdNavBtnSize / sdNavBtnGap: kept for signature parity with
-- rs.RenderNavButtons. SD nav arrows were moved to section headers and are
-- no longer rendered here.
function sd.RenderNavButtons(entry, showSdNav, gutterW, sdNavBtnSize, sdNavBtnGap, showSdModel, sdModelSize)
    local doModel = showSdModel and gutterW == 0
    sdModelSize   = sdModelSize or S(sd.SD_MODEL_SIZE)

    local modelPos  = addon.GetDB("sd_modelPosition", "right")
    local modelOffX = math.max(-100, math.min(100, tonumber(addon.GetDB("sd_modelOffsetX", 0)) or 0))
    local modelAnchor = modelPos == "left" and "TOPLEFT" or "TOPRIGHT"

    if doModel and entry.sdModel then
        entry.sdModel:ClearAllPoints()
        entry.sdModel:SetSize(sdModelSize, sdModelSize)
        entry.sdModel:SetPoint("TOPRIGHT", entry, modelAnchor, modelOffX, 0)
        entry.sdModelActive = true
        if addon.HS and addon.HS:GetAlpha() >= 0.99 then
            entry.sdModel:Show()
        else
            entry.sdModel:Hide()
        end
        if entry.sdModelBtn and not InCombatLockdown() then
            entry.sdModelBtn:ClearAllPoints()
            entry.sdModelBtn:SetSize(sdModelSize, sdModelSize)
            entry.sdModelBtn:SetFrameLevel(entry:GetFrameLevel() + 3)
            entry.sdModelBtn:SetPoint("TOPLEFT", entry.sdModel, "TOPLEFT", 0, 0)
            entry.sdModelBtn:Show()
        end
    elseif entry.sdModel then
        entry.sdModel:Hide()
        entry.sdModelActive = false
        if entry.sdModelBtn and not InCombatLockdown() then entry.sdModelBtn:Hide() end
    end

    if entry.sdPrevBtn then entry.sdPrevBtn:Hide() end
    if entry.sdNextBtn then entry.sdNextBtn:Hide() end
end

-- ---------------------------------------------------------------------------
-- Click-to-target button
-- ---------------------------------------------------------------------------

local function SetupSecureBtn(btn, title, doTarget, dismissFn, creatureID)
    btn._dismissFn       = dismissFn
    btn._creatureID      = creatureID
    if not InCombatLockdown() then
        local macroCond = addon.focus and addon.focus.GetTargetMacroConditionExcludingWoWhead and addon.focus.GetTargetMacroConditionExcludingWoWhead() or "[nomod:ctrl]"
        if doTarget and macroCond ~= nil then
            -- type1 scopes to LeftButton only; `type` would fire the macro on any button.
            btn:SetAttribute("type1", "macro")
            btn:SetAttribute("macrotext1",
                "/targetexact " .. macroCond .. " " .. title .. "\n/tm " .. macroCond .. " !" .. SD_SKULL_MARKER)
        else
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("macrotext1", nil)
        end
    end
end

function sd.RenderTargetButton(entry, questData)
    local btn = entry.sdTargetBtn
    if not btn then return end

    if not (questData.sdAlertIndex and questData.title and entry.titleText) then
        if not InCombatLockdown() then btn:Hide() end
        return
    end

    local doTarget = not questData.sdIsLoot and addon.GetDB("sd_clickToTarget", false)
    SetupSecureBtn(btn, questData.title, doTarget, sd.DismissCurrentAlert, questData.creatureID)
    btn._ownerEntry = entry

    if not InCombatLockdown() then
        btn:ClearAllPoints()
        local _, _, _, tx, ty = entry.titleText:GetPoint(1)
        local titleH = entry.titleText:GetStringHeight()
        if not titleH or titleH < 1 then titleH = addon.TITLE_SIZE + 4 end
        local titleW = (entry.titleText.GetStringWidth and entry.titleText:GetStringWidth()) or entry.titleText:GetWidth() or 100
        titleW = math.min(titleW + 4, entry.titleText:GetWidth() or titleW)
        btn:SetFrameLevel(entry:GetFrameLevel() + 3)
        btn:SetPoint("TOPLEFT", entry, "TOPLEFT", tx or 0, ty or 0)
        btn:SetSize(titleW, titleH + 2)
        btn:Show()
    end

    if entry.sdModelBtn then
        SetupSecureBtn(entry.sdModelBtn, questData.title, doTarget, sd.DismissCurrentAlert, questData.creatureID)
        entry.sdModelBtn._ownerEntry = entry
    end
end

-- ---------------------------------------------------------------------------
-- Waypoint helper
-- ---------------------------------------------------------------------------

function sd.SetWaypoint(entry)
    addon.SetRareWaypoint(entry, "sd_useTomTom")
end

-- ---------------------------------------------------------------------------
-- Coord waypoint button
-- ---------------------------------------------------------------------------

function sd.RenderCoordButton(entry, questData)
    if not addon.GetDB("sd_coordWaypoint", true) then return end
    if not (questData.vignetteMapID and questData.vignetteX and questData.vignetteY) then return end

    local coordObjIdx
    if questData.objectives then
        for i, o in ipairs(questData.objectives) do
            if o.sdCoord then coordObjIdx = i; break end
        end
    end
    if not coordObjIdx then return end

    local obj = entry.objectives and entry.objectives[coordObjIdx]
    if not obj or not obj.collapseBtn or not obj.text:IsShown() then return end

    obj.collapseBtn:ClearAllPoints()
    obj.collapseBtn:SetPoint("TOPLEFT",     obj.text, "TOPLEFT",     0,  2)
    obj.collapseBtn:SetPoint("BOTTOMRIGHT", obj.text, "BOTTOMRIGHT", 0, -2)
    obj.collapseBtn:RegisterForClicks("AnyUp")
    obj.collapseBtn:SetScript("OnClick", function(_, button)
        local isWoWheadClick = addon.focus and addon.focus.IsWoWheadClick and addon.focus.IsWoWheadClick(button, {
            shift = IsShiftKeyDown and IsShiftKeyDown() or false,
            ctrl = IsControlKeyDown and IsControlKeyDown() or false,
            alt = IsAltKeyDown and IsAltKeyDown() or false,
        })
        if isWoWheadClick then
            if questData.creatureID and addon.ShowURLCopyBox then
                addon.ShowURLCopyBox("https://www.wowhead.com/npc=" .. tostring(questData.creatureID))
            else
                local dcf = DEFAULT_CHAT_FRAME
                if dcf then dcf:AddMessage("|cff8888ff[Horizon]|r " .. (L["FOCUS_INTEGRATION_RARE_NO_WOWHEAD_ID"] or "No Wowhead ID available.")) end
            end
        elseif button == "RightButton" then
            sd.DismissCurrentAlert()
        elseif IsShiftKeyDown() then
            addon.ShareLocationInChat(entry.title or "Rare", entry.vignetteMapID, entry.vignetteX, entry.vignetteY)
        else
            sd.SetWaypoint(entry)
        end
    end)
    obj.collapseBtn:Show()
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------

addon.RegisterRareProvider(sd.IsActive)
