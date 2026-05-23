--[[
    Horizon Suite - Focus - SilverDragon Integration
    Centralises all SilverDragon-specific widget creation, portrait rendering,
    nav-gutter calculation, and nav-button rendering so the generic
    pool/renderer/layout files stay clean of integration logic.
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
    local idx   = sdp.alertIndex
    local npcID = sdp.alertOrder[idx]
    table.remove(sdp.alertOrder, idx)
    if sdp.alertQueue then sdp.alertQueue[npcID] = nil end
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
        hooksecurefunc(HS, "SetAlpha", function(_, alpha)
            local pool = addon.pool
            if not pool then return end
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.sdModel then
                    if alpha < 0.5 then
                        e.sdModel:Hide()
                    elseif e.sdModelActive then
                        e.sdModel:Show()
                    end
                end
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

    entry.sdModelActive = false

    entry.sdTargetBtn = CreateFrame("Button", nil, entry, "SecureActionButtonTemplate")
    entry.sdTargetBtn:RegisterForClicks("AnyUp")
    entry.sdTargetBtn:Hide()
end

function sd.ClearNavWidgets(entry)
    if entry.sdPrevBtn   then entry.sdPrevBtn:Hide()   end
    if entry.sdNextBtn   then entry.sdNextBtn:Hide()   end
    if entry.sdTargetBtn then entry.sdTargetBtn:Hide() end
    if entry.sdModel     then
        entry.sdModel:Hide()
        entry.sdModelActive = false
    end
end

-- ---------------------------------------------------------------------------
-- Nav gutter
-- ---------------------------------------------------------------------------

function sd.CalcNavGutter(questData, entry, showQuestIcons)
    local show = questData.sdAlertTotal
        and questData.sdAlertTotal > 1
        and entry.sdPrevBtn ~= nil
    local showModel = (showQuestIcons ~= false)
        and questData.creatureID ~= nil
        and addon.GetDB("sd_showPortrait", true)
    return show and true or false, S(SD_NAV_BTN_W), S(SD_NAV_BTN_GAP), showModel and true or false
end

-- ---------------------------------------------------------------------------
-- Portrait rendering
-- ---------------------------------------------------------------------------

function sd.TryRenderPortrait(entry, questData, showQuestIcons)
    if not (showQuestIcons and questData.creatureID and addon.GetDB("sd_showPortrait", true)) then
        if entry.sdModel then
            entry.sdModel:Hide()
            entry.sdModelActive = false
        end
        return false
    end
    if not entry.sdModel then
        local modelSz = S(sd.SD_MODEL_SIZE)
        local m = CreateFrame("PlayerModel", nil, entry)
        if m then
            m:SetSize(modelSz, modelSz)
            m:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)
            entry.sdModel = m
        end
    end
    if entry.sdModel then
        entry.questTypeIcon:Hide()
        entry.sdModel:Show()
        entry.sdModel:SetCreature(questData.creatureID)
        return true
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Nav button + model rendering
-- ---------------------------------------------------------------------------

function sd.RenderNavButtons(entry, showSdNav, gutterW, sdNavBtnSize, sdNavBtnGap, showSdModel, sdModelSize)
    local doNav   = showSdNav   and gutterW == 0
    local doModel = showSdModel and gutterW == 0
    sdModelSize   = sdModelSize or S(sd.SD_MODEL_SIZE)

    if doModel and entry.sdModel then
        entry.sdModel:ClearAllPoints()
        entry.sdModel:SetSize(sdModelSize, sdModelSize)
        entry.sdModel:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)
        entry.sdModel:Show()
        entry.sdModelActive = true
    elseif entry.sdModel then
        entry.sdModel:Hide()
        entry.sdModelActive = false
    end

    if doNav then
        local nextXOffset = doModel and -(sdModelSize + sdNavBtnGap) or 0
        local btnH = S(SD_NAV_BTN_H)

        entry.sdNextBtn:ClearAllPoints()
        entry.sdNextBtn:SetSize(sdNavBtnSize, btnH)
        entry.sdNextBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", nextXOffset, 0)
        entry.sdNextBtn:SetScript("OnClick", function()
            local sdp = rawget(_G, "HorizonSilverDragon")
            if sdp and sdp.NavigateNext then sdp.NavigateNext() end
        end)
        entry.sdNextBtn:Show()

        entry.sdPrevBtn:ClearAllPoints()
        entry.sdPrevBtn:SetSize(sdNavBtnSize, btnH)
        entry.sdPrevBtn:SetPoint("TOPLEFT", entry, "TOPLEFT", 0, 0)
        entry.sdPrevBtn:SetScript("OnClick", function()
            local sdp = rawget(_G, "HorizonSilverDragon")
            if sdp and sdp.NavigatePrev then sdp.NavigatePrev() end
        end)
        entry.sdPrevBtn:Show()
    else
        if entry.sdPrevBtn then entry.sdPrevBtn:Hide() end
        if entry.sdNextBtn then entry.sdNextBtn:Hide() end
    end
end

-- ---------------------------------------------------------------------------
-- Click-to-target button
-- ---------------------------------------------------------------------------

function sd.RenderTargetButton(entry, questData)
    local btn = entry.sdTargetBtn
    if not btn then return end

    if not (questData.sdAlertIndex and questData.title and entry.titleText) then
        btn:Hide()
        return
    end

    if not InCombatLockdown() then
        if addon.GetDB("sd_clickToTarget", false) then
            btn:SetAttribute("type1", "macro")
            btn:SetAttribute("macrotext1",
                "/targetexact " .. questData.title .. "\n/tm !" .. SD_SKULL_MARKER)
        else
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("macrotext1", nil)
        end
    end

    btn:SetScript("PreClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and IsControlKeyDown()
                and addon.GetDB("sd_ctrlClickURL", false) and entry.creatureID then
            if addon.CopyToClipboard then
                addon.CopyToClipboard("https://www.wowhead.com/npc=" .. tostring(entry.creatureID))
            end
        end
    end)
    btn:SetScript("PostClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            sd.DismissCurrentAlert()
        end
    end)

    btn:ClearAllPoints()
    local _, _, _, tx, ty = entry.titleText:GetPoint(1)
    local titleH = entry.titleText:GetStringHeight() or 20
    local titleW = entry.titleText:GetWidth() or 100
    btn:SetPoint("TOPLEFT", entry, "TOPLEFT", tx or 0, ty or 0)
    btn:SetSize(titleW, titleH + 2)
    btn:Show()
end

-- ---------------------------------------------------------------------------
-- Waypoint helper
-- ---------------------------------------------------------------------------

function sd.SetWaypoint(entry)
    addon.SetRareWaypoint(entry, "sd_useTomTom")
end

-- ---------------------------------------------------------------------------
-- Coord waypoint button
-- Shift+click shares the location in chat instead of setting a waypoint.
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
    obj.collapseBtn:SetScript("OnClick", function()
        if IsShiftKeyDown() then
            addon.ShareLocationInChat(entry.title or "Rare", entry.vignetteMapID, entry.vignetteX, entry.vignetteY)
        elseif IsControlKeyDown() and addon.GetDB("sd_ctrlClickURL", false) and entry.creatureID then
            if addon.CopyToClipboard then
                addon.CopyToClipboard("https://www.wowhead.com/npc=" .. tostring(entry.creatureID))
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
