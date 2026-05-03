--[[
    Horizon Suite - Minimap Button
    Clickable minimap icon that opens the options panel.
    Excluded from Vista's collector unless vistaCollectHorizonMinimapButton is enabled.
    Pixel size matches Vista's collected addon minimap buttons (vistaAddonBtnSize).
]]

local addon = _G.HorizonSuite
if not addon then return end

local Minimap = _G.Minimap
if not Minimap then return end

-- Same defaults/clamp as options Vista addon button slider and modules/Vista/VistaCore.lua BTN_DEFAULTS.addon
local VISTA_ADDON_BTN_MIN = 16
local VISTA_ADDON_BTN_MAX = 48
local VISTA_ADDON_BTN_DEFAULT = 26

local ICON_PATH = "Interface\\AddOns\\HorizonSuite\\HorizonLogo"
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local FADE_IN_DUR  = addon.FOCUS_ANIM and addon.FOCUS_ANIM.minimapFadeIn  or 0.2
local FADE_OUT_DUR = addon.FOCUS_ANIM and addon.FOCUS_ANIM.minimapFadeOut or 0.3

local btn
local hoverZone  -- invisible frame over minimap to detect mouse enter/leave
local vistaCollectedStandaloneHidden = false
-- Vista proxy for HorizonSuiteMinimapButton when the icon is in the collector UI.
local horizonPatchNotesProxy

local function ShowOptions()
    if addon.ShowDashboard then
        addon.ShowDashboard()
    elseif _G.HorizonSuite_ShowDashboard then
        _G.HorizonSuite_ShowDashboard()
    end
end

local DEFAULT_ANCHOR = "BOTTOMLEFT"
local DEFAULT_X, DEFAULT_Y = 2, 2

-- Standalone minimap child: tooltip anchor; Vista proxies pass ANCHOR_BOTTOMLEFT via ShowGameTooltip.
local STANDALONE_TOOLTIP_ANCHOR = "ANCHOR_LEFT"

--- Show Horizon minimap tooltip anchored to the given frame (standalone button or Vista proxy).
--- @param ownerFrame Frame
--- @param anchor string|nil GameTooltip anchor token; default STANDALONE_TOOLTIP_ANCHOR
--- @return nil
local function ShowGameTooltip(ownerFrame, anchor)
    if not GameTooltip or not ownerFrame then return end
    anchor = anchor or STANDALONE_TOOLTIP_ANCHOR
    GameTooltip:SetOwner(ownerFrame, anchor)
    GameTooltip:ClearLines()
    local title = (addon.BrandDisplay and addon.BrandDisplay.minimapTooltipTitle) or "Horizon"
    -- wrap=false: avoids first-show width glitch; ClearLines resets shared tooltip from prior UI.
    GameTooltip:SetText(title, nil, nil, nil, nil, false)
    if addon.PatchNotes_HasUnread and addon.PatchNotes_HasUnread() then
        local L = addon.L
        local hint = (L and L["UI_MINIMAP_PATCH_NOTES_UNREAD_HINT"]) or "New patch notes — open Axis and choose Patch Notes."
        GameTooltip:AddLine(hint, 0.75, 0.92, 0.78, true)
    end
    GameTooltip:Show()
end

local function IsMinimapButtonHidden()
    return addon.GetDB and addon.GetDB("hideMinimapButton", false) or false
end

local function IsMinimapButtonLocked()
    return addon.GetDB and addon.GetDB("minimapButtonLocked", false) or false
end

local function MinimapHoverFadeEnabled()
    if not addon.GetDB then return true end
    return addon.GetDB("minimapButtonShowOnlyOnMinimapHover", false)
end

local function GetMinimapButtonPixelSize()
    if not addon.GetDB then return VISTA_ADDON_BTN_DEFAULT end
    local v = tonumber(addon.GetDB("vistaAddonBtnSize", VISTA_ADDON_BTN_DEFAULT)) or VISTA_ADDON_BTN_DEFAULT
    if v < VISTA_ADDON_BTN_MIN then return VISTA_ADDON_BTN_MIN end
    if v > VISTA_ADDON_BTN_MAX then return VISTA_ADDON_BTN_MAX end
    return v
end

-- Slightly larger than DB size when patch notes are unread (clamped to addon button max).
local UNREAD_MINIMAP_SIZE_MULT = 1.12

local function GetMinimapButtonDisplayPixelSize()
    local base = GetMinimapButtonPixelSize()
    if addon.PatchNotes_HasUnread and addon.PatchNotes_HasUnread() then
        local enlarged = math.floor(base * UNREAD_MINIMAP_SIZE_MULT + 0.5)
        enlarged = math.max(enlarged, base + 2)
        if enlarged > VISTA_ADDON_BTN_MAX then enlarged = VISTA_ADDON_BTN_MAX end
        return enlarged
    end
    return base
end

-- ~25% of minimap / Vista proxy button — top-right corner exclamation-style marker.
local function GetPatchNotesBadgePixelSize()
    local icon = GetMinimapButtonDisplayPixelSize()
    return math.max(5, math.floor(icon * 0.25 + 0.5))
end

local function EnsurePatchNotesBadgeOnParent(parent)
    if not parent then return nil end
    if parent.patchNotesAttentionBadge then
        return parent.patchNotesAttentionBadge
    end
    local t = parent:CreateTexture(nil, "OVERLAY", nil, 1)
    if addon.PatchNotes_StyleAttentionBadge then
        addon.PatchNotes_StyleAttentionBadge(t)
    else
        t:SetColorTexture(0.20, 0.82, 0.28, 1)
    end
    parent.patchNotesAttentionBadge = t
    return t
end

local function LayoutPatchNotesBadgeOnParent(parent, badge)
    if not parent or not badge then return end
    local icon = GetMinimapButtonDisplayPixelSize()
    local sz = GetPatchNotesBadgePixelSize()
    badge:SetSize(sz, sz)
    badge:ClearAllPoints()
    -- Pull in from the button edge: scales with badge + a slice of icon so it is not cramped.
    local inset = math.max(4, math.floor(sz * 0.40 + 0.5) + math.floor(icon * 0.08 + 0.5))
    badge:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -inset, -inset)
end

local function UpdatePatchNotesBadgeInternal()
    local hasUnread = addon.PatchNotes_HasUnread and addon.PatchNotes_HasUnread()
    local minimapHidden = IsMinimapButtonHidden()
    if btn then
        local b = EnsurePatchNotesBadgeOnParent(btn)
        LayoutPatchNotesBadgeOnParent(btn, b)
        local showMain = hasUnread and not minimapHidden and not vistaCollectedStandaloneHidden
        b:SetShown(showMain)
    end
    if horizonPatchNotesProxy then
        local disp = GetMinimapButtonDisplayPixelSize()
        pcall(function() horizonPatchNotesProxy:SetSize(disp, disp) end)
        local pb = EnsurePatchNotesBadgeOnParent(horizonPatchNotesProxy)
        LayoutPatchNotesBadgeOnParent(horizonPatchNotesProxy, pb)
        local showProxy = hasUnread and not minimapHidden and vistaCollectedStandaloneHidden
        pb:SetShown(showProxy)
    end
end

local function ApplyPosition()
    if not btn or not Minimap then return end
    if vistaCollectedStandaloneHidden then return end
    btn:SetSize(GetMinimapButtonDisplayPixelSize(), GetMinimapButtonDisplayPixelSize())
    local savedX = addon.GetDB and tonumber(addon.GetDB("minimapButtonX", nil))
    local savedY = addon.GetDB and tonumber(addon.GetDB("minimapButtonY", nil))
    btn:ClearAllPoints()
    if savedX and savedY then
        btn:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
    else
        btn:SetPoint(DEFAULT_ANCHOR, Minimap, DEFAULT_ANCHOR, DEFAULT_X, DEFAULT_Y)
    end
    UpdatePatchNotesBadgeInternal()
end

local function FadeButton(targetAlpha)
    if not btn then return end
    if btn.fadeTo == targetAlpha then return end
    btn.fadeTo = targetAlpha
    btn.fadeFrom = btn:GetAlpha()
    btn.fadeElapsed = 0
    btn.fadeDur = targetAlpha > 0 and FADE_IN_DUR or FADE_OUT_DUR
    btn:SetScript("OnUpdate", function(self, elapsed)
        self.fadeElapsed = self.fadeElapsed + elapsed
        local pct = math.min(self.fadeElapsed / self.fadeDur, 1)
        local alpha = self.fadeFrom + (self.fadeTo - self.fadeFrom) * pct
        self:SetAlpha(alpha)
        if pct >= 1 then
            self:SetScript("OnUpdate", nil)
            if alpha <= 0 then
                self:EnableMouse(false)
            end
        end
    end)
    if targetAlpha > 0 then
        btn:EnableMouse(true)
        btn:Show()
    end
end

local function UpdateVisibility()
    if not btn then return end
    if IsMinimapButtonHidden() then
        btn:Hide()
        if hoverZone then hoverZone:Hide() end
        return
    end
    if vistaCollectedStandaloneHidden then
        if hoverZone then hoverZone:Hide() end
        return
    end
    if MinimapHoverFadeEnabled() then
        btn:SetAlpha(0)
        btn:EnableMouse(false)
    else
        btn:SetAlpha(1)
        btn:EnableMouse(true)
    end
    btn:Show()
    if hoverZone then hoverZone:Show() end
    UpdatePatchNotesBadgeInternal()
end

-- Vista calls when Horizon's minimap button is in the collector (bar / panel / drawer).
local function SetVistaCollected(collected)
    vistaCollectedStandaloneHidden = collected and true or false
    if not btn then return end
    btn:SetScript("OnUpdate", nil)
    btn.fadeTo = nil
    if collected then
        if btn then btn._hsTooltipStick = nil end
        if hoverZone then hoverZone:Hide() end
        return
    end
    if hoverZone and not IsMinimapButtonHidden() then hoverZone:Show() end
    UpdateVisibility()
    ApplyPosition()
    UpdatePatchNotesBadgeInternal()
end

local function CreateButton()
    if btn then return btn end

    btn = CreateFrame("Button", "HorizonSuiteMinimapButton", Minimap)
    btn:SetSize(GetMinimapButtonDisplayPixelSize(), GetMinimapButtonDisplayPixelSize())
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    btn:SetClampedToScreen(true)
    btn:SetMovable(true)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetAlpha(0)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local ok = pcall(icon.SetTexture, icon, ICON_PATH)
    if not ok then
        icon:SetTexture(FALLBACK_ICON)
    end
    btn.icon = icon

    btn:SetScript("OnClick", function(self, mouseButton)
        ShowOptions()
    end)
    btn:SetScript("OnDragStart", function(self)
        if IsMinimapButtonLocked() or InCombatLockdown() then return end
        self:StartMoving()
    end)
    btn:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local mx, my = Minimap:GetCenter()
        local px, py = self:GetCenter()
        local ox, oy = px - mx, py - my
        if addon.SetDB then
            addon.SetDB("minimapButtonX", ox)
            addon.SetDB("minimapButtonY", oy)
        end
        self:ClearAllPoints()
        self:SetPoint("CENTER", Minimap, "CENTER", ox, oy)
    end)
    btn:SetScript("OnEnter", function(self)
        if MinimapHoverFadeEnabled() then
            FadeButton(1)
        else
            self:SetAlpha(1)
        end
        self._hsTooltipStick = true
        ShowGameTooltip(self, STANDALONE_TOOLTIP_ANCHOR)
    end)
    btn:SetScript("OnLeave", function()
        btn._hsTooltipStick = nil
        if GameTooltip then GameTooltip:Hide() end
        if not MinimapHoverFadeEnabled() then return end
        if hoverZone and hoverZone:IsMouseOver() then return end
        FadeButton(0)
    end)

    ApplyPosition()

    -- Re-apply position when minimap is resized (e.g. by Vista)
    if Minimap.SetSize then
        hooksecurefunc(Minimap, "SetSize", function()
            if addon.MinimapButton_ApplyPosition then addon.MinimapButton_ApplyPosition() end
        end)
    end

    -- Hover zone: invisible frame covering the minimap to detect mouse enter/leave
    hoverZone = CreateFrame("Frame", nil, Minimap)
    hoverZone:SetAllPoints(Minimap)
    hoverZone:SetFrameStrata("BACKGROUND")
    hoverZone:EnableMouse(false)  -- don't eat clicks
    hoverZone:SetScript("OnUpdate", function(self)
        if MinimapHoverFadeEnabled() and not IsMinimapButtonHidden() and not vistaCollectedStandaloneHidden then
            if self:IsMouseOver() or (btn and btn:IsMouseOver()) then
                if btn:GetAlpha() < 1 and btn.fadeTo ~= 1 then
                    FadeButton(1)
                end
            else
                if btn:GetAlpha() > 0 and btn.fadeTo ~= 0 then
                    FadeButton(0)
                end
            end
        end
        -- Re-anchor tooltip every frame while hovering (minimap resize / drag moves the button).
        if btn and btn._hsTooltipStick and GameTooltip and GameTooltip:GetOwner() == btn then
            GameTooltip:SetOwner(btn, STANDALONE_TOOLTIP_ANCHOR)
            GameTooltip:Show()
        end
    end)

    UpdateVisibility()
    return btn
end

--- Show or hide unread patch-notes dot on the minimap button and Vista proxy (if any).
--- @return nil
function addon.MinimapButton_UpdatePatchNotesBadge()
    UpdatePatchNotesBadgeInternal()
end

--- Vista: the visible proxy frame for Horizon's minimap icon when collected into the bar/panel/drawer.
--- @param frame Frame|nil
--- @return nil
function addon.MinimapButton_SetHorizonPatchNotesProxy(frame)
    horizonPatchNotesProxy = frame
    UpdatePatchNotesBadgeInternal()
end

-- Create on load; defer slightly so Minimap is fully ready
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(0.5, function()
            CreateButton()
            if addon.IsModuleEnabled and addon:IsModuleEnabled("vista") and addon.Vista and addon.Vista.CollectButtons then
                addon.Vista.CollectButtons()
            end
            if addon.PatchNotes_RefreshAttentionIndicators then
                addon.PatchNotes_RefreshAttentionIndicators()
            end
        end)
    end
end)

--- @param collected boolean True when Vista is showing the icon in its managed UI.
--- @return nil
addon.MinimapButton_SetVistaCollected = SetVistaCollected
addon.MinimapButton_UpdateVisibility = UpdateVisibility
addon.MinimapButton_ApplyPosition = ApplyPosition
addon.MinimapButton_ShowGameTooltip = ShowGameTooltip
--- Effective minimap button edge size (slightly enlarged when patch notes are unread); Vista proxy matches this.
--- @return number
addon.MinimapButton_GetDisplayPixelSize = GetMinimapButtonDisplayPixelSize
