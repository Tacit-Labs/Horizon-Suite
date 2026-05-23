--[[
    Horizon Suite - Focus - RareScanner Integration
    Centralises all RareScanner-specific widget creation, clearing, portrait
    rendering, nav-gutter calculation, and nav-button rendering so the generic
    pool/renderer/layout files stay clean of integration logic.
]]

local addon = _G.HorizonSuite
addon.focus    = addon.focus    or {}
addon.focus.rs = addon.focus.rs or {}

local rs = addon.focus.rs

-- ---------------------------------------------------------------------------
-- Helper / constants
-- ---------------------------------------------------------------------------

local function S(v)
    return (addon.Scaled and addon.Scaled(v)) or v
end

rs.RS_MODEL_SIZE    = 64
local RS_LOOT_ICON_MAX     = 24  -- 3 rows × 8 per row (max option value)
local RS_LOOT_ICON_SIZE    = 16
local RS_LOOT_ICON_GAP     = 2

local RS_NAV_BTN_W    = 16   -- nav arrow button width (also drives the text gutter)
local RS_NAV_BTN_H    = 60   -- nav arrow button height (spans portrait area)
local RS_NAV_BTN_GAP  = 3    -- gap between arrow button and text content
local RS_NAV_ARROW_SZ = 14   -- arrow texture size within button
local RS_SKULL_MARKER = 8   -- WoW raid-target marker index for skull

-- ---------------------------------------------------------------------------
-- IsActive
-- Returns true when the RareScanner companion addon is loaded AND the
-- rs_enabled DB flag is on.  Used by FocusLayout to suppress built-in rares.
-- ---------------------------------------------------------------------------

function rs.IsActive()
    return rawget(_G, "HorizonRareScanner") ~= nil and addon.GetDB("rs_enabled", false)
end


--- Removes the currently displayed RS alert and advances to the next one.
function rs.DismissCurrentAlert()
    local rsp = rawget(_G, "HorizonRareScanner")
    if not rsp or not rsp.alertOrder or #rsp.alertOrder == 0 or (rsp.alertIndex or 0) == 0 then return end
    local idx      = rsp.alertIndex
    local entityID = rsp.alertOrder[idx]
    table.remove(rsp.alertOrder, idx)
    if rsp.alertQueue then rsp.alertQueue[entityID] = nil end
    if #rsp.alertOrder == 0 then
        rsp.alertIndex = 0
    elseif idx > #rsp.alertOrder then
        rsp.alertIndex = #rsp.alertOrder
    end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end

-- ---------------------------------------------------------------------------
-- PlayerModel alpha sync
-- PlayerModel frames bypass the parent alpha chain in WoW's 3D rendering
-- pipeline, so HS:SetAlpha(0) does NOT hide them.  Hook the main frame's
-- SetAlpha to explicitly Hide/Show each model when the panel fades out/in.
-- addon.pool is not yet assigned when this file loads (pool file is next in
-- the TOC), so resolve it lazily inside the hook.
-- ---------------------------------------------------------------------------
do
    local HS = addon.HS
    if HS then
        hooksecurefunc(HS, "SetAlpha", function(_, alpha)
            local pool = addon.pool
            if not pool then return end
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.rareModel then
                    if alpha < 0.5 then
                        e.rareModel:Hide()
                    elseif e.rareModelActive then
                        e.rareModel:Show()
                    end
                end
            end
        end)
    end
end

-- ---------------------------------------------------------------------------
-- Widget lifecycle (called from FocusEntryPool)
-- ---------------------------------------------------------------------------

function rs.InitNavWidgets(entry)
    local btnW    = S(RS_NAV_BTN_W)
    local btnH    = S(RS_NAV_BTN_H)
    local arrowSz = S(RS_NAV_ARROW_SZ)

    entry.rarePrevBtn = addon.CreateNavArrowBtn(entry, "common-icon-backarrow",  btnW, btnH, arrowSz)
    entry.rarePrevBtn:SetPoint("TOPLEFT", entry, "TOPLEFT", 0, 0)

    entry.rareNextBtn = addon.CreateNavArrowBtn(entry, "common-icon-forwardarrow", btnW, btnH, arrowSz)
    entry.rareNextBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)

    entry.rareModelActive = false
    -- rareModel (PlayerModel) is created lazily in TryRenderPortrait to avoid
    -- hitting WoW's hard limit on simultaneous PlayerModel frames at pool-init time.

    -- Secure button over the NPC name for click-to-target (uses /targetexact
    -- macro so it works even without a visible nameplate).
    entry.rareTargetBtn = CreateFrame("Button", nil, entry, "SecureActionButtonTemplate")
    entry.rareTargetBtn:RegisterForClicks("AnyUp")
    entry.rareTargetBtn:Hide()
end

function rs.ClearNavWidgets(entry)
    if entry.rarePrevBtn  then entry.rarePrevBtn:Hide()  end
    if entry.rareNextBtn  then entry.rareNextBtn:Hide()  end
    if entry.rareModel    then
        entry.rareModel:Hide()
        entry.rareModelActive = false
    end
    if entry.rareTargetBtn then entry.rareTargetBtn:Hide() end
end

-- ---------------------------------------------------------------------------
-- Loot icon widgets (called from FocusEntryPool and FocusEntryRenderer)
-- ---------------------------------------------------------------------------

function rs.InitLootWidgets(entry)
    entry.rsLootIcons = {}
    for i = 1, RS_LOOT_ICON_MAX do
        local btn = CreateFrame("Button", nil, entry)
        btn:SetSize(S(RS_LOOT_ICON_SIZE), S(RS_LOOT_ICON_SIZE))
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints()
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn:SetScript("OnEnter", function(self)
            if not self._itemID then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local _, link = C_Item.GetItemInfo(self._itemID)
            GameTooltip:SetHyperlink(link or ("item:" .. self._itemID))
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        btn:Hide()
        entry.rsLootIcons[i] = btn
    end
end

function rs.ClearLootWidgets(entry)
    if not entry.rsLootIcons then return end
    for _, btn in ipairs(entry.rsLootIcons) do
        btn._itemID = nil
        btn:Hide()
    end
end

--- Position and show loot icons below `anchor` in rows of RS_LOOT_ICON_PER_ROW.
--- Returns updated totalH.
function rs.RenderLootIcons(entry, questData, anchor, totalH, spacing)
    local loot = questData.rsLoot
    if not entry.rsLootIcons or not loot or #loot == 0 then
        rs.ClearLootWidgets(entry)
        return totalH
    end

    local iconSz   = S(RS_LOOT_ICON_SIZE)
    local gap      = S(RS_LOOT_ICON_GAP)
    local perRow   = math.max(3, math.min(8, tonumber(addon.GetDB("rs_lootPerRow", 6)) or 6))
    local n        = math.min(#loot, RS_LOOT_ICON_MAX)
    local rowFirst = nil  -- first placed button of the current row (anchor for next row)
    local lastBtn  = nil  -- last placed button in the current row
    local col      = 0
    local rowCount = 0

    for i = 1, RS_LOOT_ICON_MAX do
        local btn = entry.rsLootIcons[i]
        if not btn then break end
        local itemID = (i <= n) and loot[i]
        if itemID then
            local _, _, _, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID)
            if texture then
                btn.icon:SetTexture(texture)
                btn._itemID = itemID
                btn:SetSize(iconSz, iconSz)
                btn:ClearAllPoints()
                if col == 0 then
                    if not rowFirst then
                        btn:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -spacing)
                    else
                        btn:SetPoint("TOPLEFT", rowFirst, "BOTTOMLEFT", 0, -gap)
                    end
                    rowFirst = btn
                    rowCount = rowCount + 1
                else
                    btn:SetPoint("TOPLEFT", lastBtn, "TOPRIGHT", gap, 0)
                end
                lastBtn = btn
                btn:Show()
                col = col + 1
                if col >= perRow then col = 0 end
            else
                btn._itemID = nil
                btn:Hide()
            end
        else
            btn._itemID = nil
            btn:Hide()
        end
    end

    if rowCount > 0 then
        totalH = totalH + spacing + rowCount * iconSz + (rowCount - 1) * gap
    end
    return totalH
end

-- ---------------------------------------------------------------------------
-- Nav gutter (called from FocusEntryRenderer before text-width narrowing).
-- Returns showRsNav, btnSize, gap, showRsModel.
-- ---------------------------------------------------------------------------

function rs.CalcNavGutter(questData, entry, showQuestIcons)
    local show = questData.rsAlertTotal
        and questData.rsAlertTotal > 1
        and entry.rarePrevBtn ~= nil
    local showModel = (showQuestIcons ~= false)
        and questData.rsIsNPC
        and questData.creatureID ~= nil
        and addon.GetDB("rs_showPortrait", true)
        -- rareModel is lazily created; don't require it to exist yet
    return show and true or false, S(RS_NAV_BTN_W), S(RS_NAV_BTN_GAP), showModel and true or false
end

-- ---------------------------------------------------------------------------
-- Portrait rendering (called from FocusEntryRenderer icon chain).
-- Sets the 3-D model's creature when available; RenderNavButtons handles
-- position/visibility so it is coordinated with the nav buttons.
-- ---------------------------------------------------------------------------

function rs.TryRenderPortrait(entry, questData, showQuestIcons)
    if not (showQuestIcons and questData.rsIsNPC and addon.GetDB("rs_showPortrait", true)) then
        if entry.rareModel then
            entry.rareModel:Hide()
            entry.rareModelActive = false
        end
        return false
    end
    if questData.creatureID then
        -- Create the PlayerModel lazily — only one per active RS NPC entry,
        -- avoiding the pool-init crash from WoW's hard PlayerModel frame limit.
        if not entry.rareModel then
            local modelSz = S(rs.RS_MODEL_SIZE)
            local m = CreateFrame("PlayerModel", nil, entry)
            if m then
                m:SetSize(modelSz, modelSz)
                m:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)
                entry.rareModel = m
            end
        end
        if entry.rareModel then
            entry.questTypeIcon:Hide()
            -- Show before SetCreature so WoW's renderer can load the model
            -- data; calling SetCreature on a hidden frame may silently no-op.
            -- RenderNavButtons manages final positioning and show/hide.
            entry.rareModel:Show()
            entry.rareModel:SetCreature(questData.creatureID)
            return true
        end
    end
    -- Fallback: atlas icon in the left icon slot.
    if entry.rareModel then
        entry.rareModel:Hide()
        entry.rareModelActive = false
    end
    if questData.rsAtlasName then
        entry.questTypeIcon:SetAtlas(questData.rsAtlasName)
        entry.questTypeIcon:Show()
        return true
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Nav button + model rendering (called from FocusEntryRenderer after AH-btn).
-- prevBtn → TOPLEFT, nextBtn → TOPRIGHT (left of model when model is shown),
-- model   → TOPRIGHT of entry.
-- ---------------------------------------------------------------------------

function rs.RenderNavButtons(entry, showRsNav, gutterW, rsNavBtnSize, rsNavBtnGap, showRsModel, rsModelSize)
    local doNav   = showRsNav  and gutterW == 0
    local doModel = showRsModel and gutterW == 0
    rsModelSize   = rsModelSize or S(rs.RS_MODEL_SIZE)

    -- 3-D model at the far right.
    if doModel and entry.rareModel then
        entry.rareModel:ClearAllPoints()
        entry.rareModel:SetSize(rsModelSize, rsModelSize)
        entry.rareModel:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 0, 0)
        entry.rareModel:Show()
        entry.rareModelActive = true
    elseif entry.rareModel then
        entry.rareModel:Hide()
        entry.rareModelActive = false
    end

    if doNav then
        -- nextBtn immediately left of model (or at TOPRIGHT when no model).
        local nextXOffset = doModel and -(rsModelSize + rsNavBtnGap) or 0

        local btnH = S(RS_NAV_BTN_H)

        entry.rareNextBtn:ClearAllPoints()
        entry.rareNextBtn:SetSize(rsNavBtnSize, btnH)
        entry.rareNextBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", nextXOffset, 0)
        entry.rareNextBtn:SetScript("OnClick", function()
            local rsp = rawget(_G, "HorizonRareScanner")
            if rsp and rsp.NavigateNext then rsp.NavigateNext() end
        end)
        entry.rareNextBtn:Show()

        -- prevBtn at the far left.
        entry.rarePrevBtn:ClearAllPoints()
        entry.rarePrevBtn:SetSize(rsNavBtnSize, btnH)
        entry.rarePrevBtn:SetPoint("TOPLEFT", entry, "TOPLEFT", 0, 0)
        entry.rarePrevBtn:SetScript("OnClick", function()
            local rsp = rawget(_G, "HorizonRareScanner")
            if rsp and rsp.NavigatePrev then rsp.NavigatePrev() end
        end)
        entry.rarePrevBtn:Show()
    else
        if entry.rarePrevBtn then entry.rarePrevBtn:Hide() end
        if entry.rareNextBtn then entry.rareNextBtn:Hide() end
    end
end

-- ---------------------------------------------------------------------------
-- Secure name button for click-to-target (called from FocusEntryRenderer).
-- Uses a SecureActionButtonTemplate with /targetexact so it works in combat
-- and without a visible nameplate.  Attributes are set outside combat only.
-- ---------------------------------------------------------------------------

function rs.RenderTargetButton(entry, questData)
    local btn = entry.rareTargetBtn
    if not btn then return end

    if not (questData.rsIsNPC and questData.title and entry.titleText) then
        btn:Hide()
        return
    end

    if not InCombatLockdown() then
        if addon.GetDB("rs_clickToTarget", false) then
            -- type1/macrotext1 scope the action to LeftButton only, leaving
            -- RightButton free for the PostClick dismiss handler below.
            btn:SetAttribute("type1", "macro")
            btn:SetAttribute("macrotext1",
                "/targetexact " .. questData.title .. "\n/tm !" .. RS_SKULL_MARKER)
        else
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("macrotext1", nil)
        end
    end

    btn:SetScript("PreClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and IsControlKeyDown()
                and addon.GetDB("rs_ctrlClickURL", false) and entry.creatureID then
            if addon.CopyToClipboard then
                addon.CopyToClipboard("https://www.wowhead.com/npc=" .. tostring(entry.creatureID))
            end
        end
    end)
    btn:SetScript("PostClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            rs.DismissCurrentAlert()
        end
    end)

    -- SecureActionButtonTemplate (protected frame) cannot anchor to a FontString
    -- (Region).  Read the title text's current position relative to entry (Frame)
    -- and replicate it so the button covers the same area.
    btn:ClearAllPoints()
    local _, _, _, tx, ty = entry.titleText:GetPoint(1)
    local titleH = entry.titleText:GetStringHeight() or 20
    local titleW = entry.titleText:GetWidth() or 100
    btn:SetPoint("TOPLEFT", entry, "TOPLEFT", tx or 0, ty or 0)
    btn:SetSize(titleW, titleH + 2)
    btn:Show()
end

-- ---------------------------------------------------------------------------
-- Waypoint helper — respects the rs_useTomTom option.
-- Default (rs_useTomTom = false): Blizzard native C_Map.SetUserWaypoint.
-- When the option is on and TomTom is loaded, delegates to TomTom.
-- ---------------------------------------------------------------------------

function rs.SetWaypoint(entry)
    addon.SetRareWaypoint(entry, "rs_useTomTom")
end

-- ---------------------------------------------------------------------------
-- Coord waypoint button (called from FocusEntryRenderer after ApplyObjectives).
-- Reuses the pre-allocated collapseBtn on the coord objective widget to make
-- the coordinate text clickable without allocating a new frame per entry.
-- Shift+click shares the location in chat instead of setting a waypoint.
-- ---------------------------------------------------------------------------

function rs.RenderCoordButton(entry, questData)
    if not addon.GetDB("rs_coordWaypoint", true) then return end
    if not (questData.vignetteMapID and questData.vignetteX and questData.vignetteY) then return end

    local coordObjIdx
    if questData.objectives then
        for i, o in ipairs(questData.objectives) do
            if o.rsCoord then coordObjIdx = i; break end
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
        elseif IsControlKeyDown() and addon.GetDB("rs_ctrlClickURL", false) and entry.creatureID then
            if addon.CopyToClipboard then
                addon.CopyToClipboard("https://www.wowhead.com/npc=" .. tostring(entry.creatureID))
            end
        else
            rs.SetWaypoint(entry)
        end
    end)
    obj.collapseBtn:Show()
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------

addon.RegisterRareProvider(rs.IsActive)
