--[[
    Horizon Suite - Focus - RareScanner Integration
    Widget lifecycle, portrait model, loot icons, nav buttons, waypoint, and coord-click for RareScanner alerts.
]]

local addon = _G.HorizonSuite
local L = addon.L
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
-- Model clip envelope — used for "left" portrait mode.
-- Parented to HS (outside the ScrollFrame) so a left-positioned model can
-- extend past the tracker's left edge without being clipped.  The envelope
-- matches the scrollFrame's vertical bounds so models still disappear when
-- their entry scrolls off screen.
-- ---------------------------------------------------------------------------
local rsModelClipFrame
local function GetOrCreateRSModelClipFrame()
    if rsModelClipFrame then return rsModelClipFrame end
    local sf = addon.scrollFrame
    if not addon.HS or not sf then return addon.HS end
    rsModelClipFrame = CreateFrame("Frame", nil, addon.HS)
    rsModelClipFrame:SetClipsChildren(true)
    rsModelClipFrame:SetPoint("TOPLEFT",     sf, "TOPLEFT",     -200, 0)
    rsModelClipFrame:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT",    0, 0)
    return rsModelClipFrame
end

-- ---------------------------------------------------------------------------
-- IsActive — true when RS companion is loaded and rs_enabled is on.
-- ---------------------------------------------------------------------------

function rs.IsActive()
    return rawget(_G, "HorizonRareScanner") ~= nil and addon.GetDB("rs_enabled", false)
end

-- ---------------------------------------------------------------------------
-- Native popup suppression
-- ---------------------------------------------------------------------------

local hookedNativePopupFrames = setmetatable({}, { __mode = "k" })

local function HookNativePopupMouse(frame)
    if not frame or hookedNativePopupFrames[frame] or not hooksecurefunc or not frame.EnableMouse then return end
    hookedNativePopupFrames[frame] = true
    hooksecurefunc(frame, "EnableMouse", function(self, enabled)
        if not enabled or not addon.GetDB("rs_enabled", false) then return end
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
    pcall(function() frame:SetAlpha(0) end)
    if InCombatLockdown and InCombatLockdown() then return end
    pcall(function()
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMRIGHT", UIParent, "TOPLEFT", -2000, 2000)
        frame:SetSize(1, 1)
    end)
    if frame.EnableMouse then pcall(function() frame:EnableMouse(false) end) end
    if frame.EnableMouseWheel then pcall(function() frame:EnableMouseWheel(false) end) end
end

function rs.SuppressNativePopups()
    if not addon.GetDB("rs_enabled", false) then return end
    local rsp = rawget(_G, "HorizonRareScanner")
    if not rsp then return end
    if rsp.ApplyPopupSuppression then
        pcall(rsp.ApplyPopupSuppression, true)
    end

    -- Alpha-zero frames still receive mouse input.  Hide and mouse-disable any
    -- exposed native alert frames so the Focus tracker owns the click area.
    DisableNativePopupFrame(rsp.alertFrame)
    DisableNativePopupFrame(rsp.popupFrame)
    DisableNativePopupFrame(rsp.frame)
    DisableNativePopupFrame(rsp.modelFrame)
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
-- PlayerModel alpha sync — PlayerModel ignores inherited alpha AND SetAlpha has
-- no effect on the 3D renderer; the only reliable control is Hide()/Show().
-- Hide whenever the panel is not fully visible; show only at full opacity.
-- ---------------------------------------------------------------------------
do
    local HS = addon.HS
    if HS then
        local lastAlpha = 1
        local function SyncRSModels(alpha)
            local pool = addon.pool
            if not pool then return end
            -- Threshold: hide at any fade. Alternative considered: use alpha > 0.01
            -- so the portrait stays visible at the user's mouseover faded opacity
            -- (e.g. 61%). Rejected — PlayerModel ignores inherited alpha and always
            -- renders at full 3D opacity, so the portrait would appear brighter than
            -- the faded tracker text/background. Hard cutoff at 0.99 feels cleaner.
            local fullyVisible = alpha >= 0.99
            -- When fading, enforce Hide() every frame — a layout pass or async model
            -- load may have called Show() since the last sync.
            if not fullyVisible then
                lastAlpha = alpha
                for i = 1, (addon.POOL_SIZE or 0) do
                    local e = pool[i]
                    if e and e.rareModel and e.rareModel:IsShown() then
                        e.rareModel:Hide()
                    end
                end
                return
            end
            if math.abs(alpha - lastAlpha) < 0.001 then return end
            lastAlpha = alpha
            for i = 1, (addon.POOL_SIZE or 0) do
                local e = pool[i]
                if e and e.rareModel then
                    if e.rareModelActive then e.rareModel:Show() else e.rareModel:Hide() end
                end
            end
        end
        HS:HookScript("OnHide", function() SyncRSModels(0) end)
        HS:HookScript("OnShow", function() SyncRSModels(HS:GetAlpha()) end)
        -- Dedicated frame instead of HookScript("OnUpdate") — HookScript stops
        -- firing after EnsureFocusUpdateRunning calls SetScript("OnUpdate", nil).
        local rsSync = CreateFrame("Frame")
        rsSync:SetScript("OnUpdate", function() SyncRSModels(HS:GetAlpha()) end)
    end
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ADDON_LOADED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", function()
        if rs.SuppressNativePopups then rs.SuppressNativePopups() end
    end)
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

    entry.rarePrevBtn:SetScript("OnClick", function()
        local rsp = rawget(_G, "HorizonRareScanner")
        if rsp and rsp.NavigatePrev then rsp.NavigatePrev() end
    end)
    entry.rareNextBtn:SetScript("OnClick", function()
        local rsp = rawget(_G, "HorizonRareScanner")
        if rsp and rsp.NavigateNext then rsp.NavigateNext() end
    end)

    entry.rareModelActive = false
    -- rareModel (PlayerModel) is created lazily in TryRenderPortrait to avoid
    -- hitting WoW's hard limit on simultaneous PlayerModel frames at pool-init time.

    entry.rareTargetBtn = addon.CreateNavSecureBtn()
    entry.rareModelBtn  = addon.CreateNavSecureBtn()
    entry.rareTargetBtn:SetScript("OnEnter", ShowCreatureTooltipFrom)
    entry.rareTargetBtn:SetScript("OnLeave", HideCreatureTooltipFrom)
    entry.rareModelBtn:SetScript("OnEnter", ShowCreatureTooltipFrom)
    entry.rareModelBtn:SetScript("OnLeave", HideCreatureTooltipFrom)
end

function rs.ClearNavWidgets(entry)
    if entry.rarePrevBtn  then entry.rarePrevBtn:Hide()  end
    if entry.rareNextBtn  then entry.rareNextBtn:Hide()  end
    if entry.rareModel    then
        entry.rareModel:ClearModel()
        entry.rareModel:Hide()
        entry.rareModelActive = false
    end
    entry._rsLastCreatureID = nil  -- reset so next render always clears before loading a new creature
    if entry._rsPortraitClip then entry._rsPortraitClip:ClearAllPoints() end
    entry._rsModelParent = nil
    if not InCombatLockdown() then
        if entry.rareTargetBtn then entry.rareTargetBtn:Hide() end
        if entry.rareModelBtn  then entry.rareModelBtn:Hide()  end
    end
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
        btn:SetScript("OnClick", function(self)
            if IsAltKeyDown() and addon.ShowURLCopyBox then
                addon.ShowURLCopyBox("https://www.wowhead.com/item=" .. tostring(self._itemID))
            end
        end)
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
-- Nav gutter (called from FocusEntryRenderer). Returns showRsNav, btnSize, gap, showRsModel.
-- ---------------------------------------------------------------------------

function rs.CalcNavGutter(questData, entry, showQuestIcons)
    -- Sync RS_MODEL_SIZE from DB so FocusEntryRenderer reads the current value
    -- (it reads this field on the very next line after calling CalcNavGutter).
    rs.RS_MODEL_SIZE = math.max(32, math.min(128, tonumber(addon.GetDB("rs_modelSize", 64)) or 64))
    -- rsIsNPC guards against SD entries (or any non-RS entry) that share a pool
    -- slot and also carry creatureID — without this, rareModel would incorrectly
    -- show on those entries after pool reuse. sd.CalcNavGutter has a symmetric
    -- sdAlertIndex guard for the same reason.
    local showModel = (showQuestIcons ~= false)
        and questData.rsIsNPC
        and questData.creatureID ~= nil
        and addon.GetDB("rs_showPortrait", true)
        -- rareModel is lazily created; don't require it to exist yet
    return false, S(RS_NAV_BTN_W), S(RS_NAV_BTN_GAP), showModel and true or false
end

-- ---------------------------------------------------------------------------
-- Portrait rendering (called from FocusEntryRenderer). RenderNavButtons manages position/visibility.
-- ---------------------------------------------------------------------------

function rs.TryRenderPortrait(entry, questData, showQuestIcons)
    rs.SuppressNativePopups()
    if not (showQuestIcons and questData.rsIsNPC and addon.GetDB("rs_showPortrait", true)) then
        if entry.rareModel then
            entry.rareModel:ClearModel()
            entry.rareModel:Hide()
            entry.rareModelActive = false
        end
        return false
    end
    if questData.creatureID then
        -- Create the PlayerModel lazily — only one per active RS NPC entry,
        -- avoiding the pool-init crash from WoW's hard PlayerModel frame limit.
        local initPos  = addon.GetDB("rs_modelPosition", "right")
        local initOffX = math.max(-100, math.min(100, tonumber(addon.GetDB("rs_modelOffsetX", 0)) or 0))
        -- Left mode uses a two-level clip hierarchy:
        --   rsModelClipFrame (global, child of HS) → extends 200 px left of the tracker
        --   entry._rsPortraitClip (per-entry)      → anchored to entry bounds, clips portrait
        --                                             height so it cannot bleed into adjacent
        --                                             entries when two scanner alerts stack.
        -- Right mode: portrait is a direct child of entry; SetClipsChildren(true) on pool
        -- entries handles height clamping.
        local mParent
        if initPos == "left" then
            if not entry._rsPortraitClip then
                local clip = CreateFrame("Frame", nil, GetOrCreateRSModelClipFrame())
                clip:SetClipsChildren(true)
                entry._rsPortraitClip = clip
            end
            entry._rsPortraitClip:ClearAllPoints()
            entry._rsPortraitClip:SetPoint("TOPLEFT",     entry, "TOPLEFT",     -200, 0)
            entry._rsPortraitClip:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT",    0, 0)
            mParent = entry._rsPortraitClip
        else
            if entry._rsPortraitClip then entry._rsPortraitClip:ClearAllPoints() end
            mParent = entry
        end
        if entry.rareModel and entry._rsModelParent ~= mParent and not InCombatLockdown() then
            entry.rareModel:ClearModel()
            entry.rareModel:Hide()
            entry.rareModel:ClearAllPoints()
            entry.rareModel:SetParent(mParent)
            entry._rsModelParent = mParent
            entry._rsLastCreatureID = nil
        end
        if not entry.rareModel then
            local modelSz = S(rs.RS_MODEL_SIZE)
            local m = CreateFrame("PlayerModel", nil, mParent)
            if m then
                m:SetSize(modelSz, modelSz)
                m:SetPoint("TOPRIGHT", entry, initPos == "left" and "TOPLEFT" or "TOPRIGHT", initOffX, 0)
                -- Mouse disabled so rareModelBtn (higher frame level) receives all clicks.
                m:EnableMouse(false)
                -- Guard against creatures with no valid model (FileData ID 0 = fallback).
                -- SetCreature loads asynchronously, so we check after the load resolves.
                m:SetScript("OnModelLoaded", function(self)
                    local fid = self.GetModelFileID and self:GetModelFileID()
                    if not fid or fid == 0 then
                        self:Hide()
                        entry.rareModelActive = false
                        if entry.rareModelBtn and not InCombatLockdown() then
                            entry.rareModelBtn:Hide()
                        end
                        entry.questTypeIcon:Show()
                    elseif addon.HS and addon.HS:GetAlpha() < 0.99 then
                        self:Hide()
                    end
                end)
                entry.rareModel = m
                entry._rsModelParent = mParent
            end
        end
        if entry.rareModel then
            entry.questTypeIcon:Hide()
            if entry._rsLastCreatureID ~= questData.creatureID then
                -- SetCreature loads asynchronously; without ClearModel first, the
                -- previous creature's mesh lingers until the new one finishes loading.
                entry.rareModel:ClearModel()
                entry._rsLastCreatureID = questData.creatureID
            end
            -- Show before SetCreature so WoW's renderer can load the model
            -- data; calling SetCreature on a hidden frame may silently no-op.
            entry.rareModel:Show()
            entry.rareModel:SetCreature(questData.creatureID)
            -- Hide immediately if the panel is currently faded; RenderNavButtons
            -- will restore Show() on the next layout when the panel is fully visible.
            if addon.HS and addon.HS:GetAlpha() < 0.99 then
                entry.rareModel:Hide()
            end
            return true
        end
    end
    if entry.rareModel then
        entry.rareModel:ClearModel()
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
-- ---------------------------------------------------------------------------

function rs.RenderNavButtons(entry, showRsNav, gutterW, rsNavBtnSize, rsNavBtnGap, showRsModel, rsModelSize)
    local doNav   = showRsNav  and gutterW == 0
    local doModel = showRsModel and gutterW == 0
    rsModelSize   = rsModelSize or S(rs.RS_MODEL_SIZE)

    local modelPos  = addon.GetDB("rs_modelPosition", "right")
    local modelOffX = math.max(-100, math.min(100, tonumber(addon.GetDB("rs_modelOffsetX", 0)) or 0))
    local modelAnchor = modelPos == "left" and "TOPLEFT" or "TOPRIGHT"

    if doModel and entry.rareModel then
        entry.rareModel:ClearAllPoints()
        entry.rareModel:SetSize(rsModelSize, rsModelSize)
        entry.rareModel:SetPoint("TOPRIGHT", entry, modelAnchor, modelOffX, 0)
        entry.rareModelActive = true
        if addon.HS and addon.HS:GetAlpha() >= 0.99 then
            entry.rareModel:Show()
        else
            entry.rareModel:Hide()
        end
        if entry.rareModelBtn and not InCombatLockdown() then
            entry.rareModelBtn:ClearAllPoints()
            entry.rareModelBtn:SetSize(rsModelSize, rsModelSize)
            entry.rareModelBtn:SetFrameLevel(entry:GetFrameLevel() + 3)
            entry.rareModelBtn:SetPoint("TOPLEFT", entry.rareModel, "TOPLEFT", 0, 0)
            entry.rareModelBtn:Show()
        end
    elseif entry.rareModel then
        entry.rareModel:Hide()
        entry.rareModelActive = false
        if entry.rareModelBtn and not InCombatLockdown() then entry.rareModelBtn:Hide() end
    end

    if doNav then
        -- Always reserve the portrait column so the right arrow stays in a fixed
        -- position as the user cycles through alerts — some may have a portrait,
        -- others (containers, failed model load) may not.
        -- In right mode: next arrow sits left of the portrait's actual edge (including
        -- any X offset), so it always stays clear of the model button regardless of size.
        -- In left mode: portrait is outside the left edge; next arrow goes to far right.
        local nextXOffset = modelPos == "left" and 0 or (modelOffX - rsModelSize - rsNavBtnGap)

        local btnH = S(RS_NAV_BTN_H)
        -- Nav buttons must be well above the model button (+3) so clicks reach the
        -- arrows even when the model or its overlay partially overlaps their area.
        local navLevel = entry:GetFrameLevel() + 8

        entry.rareNextBtn:ClearAllPoints()
        entry.rareNextBtn:SetSize(rsNavBtnSize, btnH)
        entry.rareNextBtn:SetFrameLevel(navLevel)
        entry.rareNextBtn:SetPoint("TOPRIGHT", entry, "TOPRIGHT", nextXOffset, 0)
        entry.rareNextBtn:Show()

        entry.rarePrevBtn:ClearAllPoints()
        entry.rarePrevBtn:SetSize(rsNavBtnSize, btnH)
        entry.rarePrevBtn:SetFrameLevel(navLevel)
        entry.rarePrevBtn:SetPoint("TOPLEFT", entry, "TOPLEFT", 0, 0)
        entry.rarePrevBtn:Show()
    else
        if entry.rarePrevBtn then entry.rarePrevBtn:Hide() end
        if entry.rareNextBtn then entry.rareNextBtn:Hide() end
    end
end

-- ---------------------------------------------------------------------------
-- Secure name button for click-to-target (called from FocusEntryRenderer).
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
                "/targetexact " .. macroCond .. " " .. title .. "\n/tm " .. macroCond .. " !" .. RS_SKULL_MARKER)
        else
            btn:SetAttribute("type1", nil)
            btn:SetAttribute("macrotext1", nil)
        end
    end
end

function rs.RenderTargetButton(entry, questData)
    local btn = entry.rareTargetBtn
    if not btn then return end

    if not (questData.rsAlertIndex and questData.title and entry.titleText) then
        if not InCombatLockdown() then btn:Hide() end
        return
    end

    local doTarget = questData.rsIsNPC and addon.GetDB("rs_clickToTarget", false)
    SetupSecureBtn(btn, questData.title, doTarget, rs.DismissCurrentAlert, questData.creatureID)
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

    if entry.rareModelBtn then
        SetupSecureBtn(entry.rareModelBtn, questData.title, doTarget, rs.DismissCurrentAlert, questData.creatureID)
        entry.rareModelBtn._ownerEntry = entry
    end
end

-- ---------------------------------------------------------------------------
-- Waypoint helper
-- ---------------------------------------------------------------------------

function rs.SetWaypoint(entry)
    addon.SetRareWaypoint(entry, "rs_useTomTom")
end

-- ---------------------------------------------------------------------------
-- Coord waypoint button — reuses collapseBtn on the coord widget; no new frame needed.
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
            rs.DismissCurrentAlert()
        elseif IsShiftKeyDown() then
            addon.ShareLocationInChat(entry.title or "Rare", entry.vignetteMapID, entry.vignetteX, entry.vignetteY)
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
