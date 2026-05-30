--[[
    Horizon Suite - Focus - SilverDragon Integration
    Widget lifecycle, portrait model, nav buttons, waypoint, and coord-click for SilverDragon alerts.
]]

local addon = _G.HorizonSuite
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
-- PlayerModel alpha sync
-- ---------------------------------------------------------------------------
do
    local HS = addon.HS
    if HS then
        HS:HookScript("OnHide", function()
            local pool = addon.pool
            if not pool then return end
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.sdModel then e.sdModel:Hide() end
            end
        end)
        HS:HookScript("OnShow", function()
            local pool = addon.pool
            if not pool then return end
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.sdModel and e.sdModelActive then e.sdModel:Show() end
            end
        end)
    end
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
        entry.sdModel:Show()
        entry.sdModelActive = true
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

local function SetupSecureBtn(btn, title, doTarget, dismissFn, creatureID, ctrlClickURLKey)
    btn._dismissFn       = dismissFn
    btn._creatureID      = creatureID
    btn._ctrlClickURLKey = ctrlClickURLKey
    if not InCombatLockdown() then
        if doTarget then
            -- type1 scopes to LeftButton only; `type` would fire the macro on any button.
            btn:SetAttribute("type1", "macro")
            btn:SetAttribute("macrotext1",
                "/targetexact [nomod:ctrl] " .. title .. "\n/tm [nomod:ctrl] !" .. SD_SKULL_MARKER)
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
    SetupSecureBtn(btn, questData.title, doTarget, sd.DismissCurrentAlert, questData.creatureID, "sd_ctrlClickURL")

    if not InCombatLockdown() then
        btn:ClearAllPoints()
        local _, _, _, tx, ty = entry.titleText:GetPoint(1)
        local titleH = entry.titleText:GetStringHeight()
        if not titleH or titleH < 1 then titleH = addon.TITLE_SIZE + 4 end
        local titleW = entry.titleText:GetWidth() or 100
        btn:SetFrameLevel(entry:GetFrameLevel() + 3)
        btn:SetPoint("TOPLEFT", entry, "TOPLEFT", tx or 0, ty or 0)
        btn:SetSize(titleW, titleH + 2)
        btn:Show()
    end

    if entry.sdModelBtn then
        SetupSecureBtn(entry.sdModelBtn, questData.title, doTarget, sd.DismissCurrentAlert, questData.creatureID, "sd_ctrlClickURL")
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
        if button == "RightButton" then
            sd.DismissCurrentAlert()
        elseif IsShiftKeyDown() then
            addon.ShareLocationInChat(entry.title or "Rare", entry.vignetteMapID, entry.vignetteX, entry.vignetteY)
        elseif IsControlKeyDown() and addon.GetDB("sd_ctrlClickURL", false) then
            if questData.creatureID and addon.ShowURLCopyBox then
                addon.ShowURLCopyBox("https://www.wowhead.com/npc=" .. tostring(questData.creatureID))
            else
                local dcf = DEFAULT_CHAT_FRAME
                if dcf then dcf:AddMessage("|cff8888ff[Horizon]|r " .. (addon.L and addon.L["FOCUS_INTEGRATION_RARE_NO_WOWHEAD_ID"] or "No Wowhead ID available.")) end
            end
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
