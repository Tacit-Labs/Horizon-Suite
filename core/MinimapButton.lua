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
-- Blizzard / LibDBIcon canonical addon-minimap-button size: 31px button, 54px ring. Used only when
-- `minimapButtonCircular` is on and the button is standalone, so the stock-button look matches
-- calendar/clock dimensions. Vista-collected proxy continues to use the slider (`vistaAddonBtnSize`).
local STANDARD_CIRCULAR_BTN_PX = 31

local ICON_PATH = "Interface\\AddOns\\HorizonSuite\\HorizonLogo"
local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local FADE_IN_DUR  = addon.FOCUS_ANIM and addon.FOCUS_ANIM.minimapFadeIn  or 0.2
local FADE_OUT_DUR = addon.FOCUS_ANIM and addon.FOCUS_ANIM.minimapFadeOut or 0.3

local btn
local hoverZone     -- invisible frame over minimap to detect mouse enter/leave
local iconMask      -- circular MaskTexture; created lazily the first time circular mode is on
local ringBorder    -- gold ring overlay (Blizzard's standard minimap button frame) shown in circular mode
local dragHelper    -- separate Frame with OnUpdate that snaps btn to minimap edge while dragging
local DEFAULT_ANGLE_RAD = math.rad(225)  -- bottom-left, mirroring the legacy DEFAULT_ANCHOR corner
-- LibDBIcon proportions for WOW_PROJECT_MAINLINE (retail / Midnight): icon 18x18 CENTER-anchored,
-- border 50x50 TOPLEFT(0, 0), inside a 31x31 button. The MiniMap-TrackingBorder texture's visible
-- artwork is calibrated for exactly these dimensions — see Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua
-- in BugSack (`ResetButtonIcon` / `ResetButtonBorder`, lines 526–617). Different numbers leave the
-- icon off-centre or the ring loose around it.
local ICON_SIZE_FRAC = 18 / 31
local RING_SIZE_FRAC = 50 / 31
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

-- Standalone minimap child: tooltip anchor flips to the opposite quadrant of the button so it
-- never clips off-screen — same idea LibDBIcon uses (`getAnchors`, BugSack/Libs/LibDBIcon-1.0/
-- LibDBIcon-1.0.lua:60). Vista proxies still pass ANCHOR_BOTTOMLEFT explicitly.
--   * y in upper half → tooltip below (ANCHOR_BOTTOM*); lower half → above (ANCHOR_TOP*).
--   * x in left third → tooltip extends right (*RIGHT); right third → extends left (*LEFT);
--     middle third → no L/R suffix.
local function PickStandaloneTooltipAnchor(ownerFrame)
    if not ownerFrame or not UIParent then return "ANCHOR_LEFT" end
    local x, y = ownerFrame:GetCenter()
    if not x or not y then return "ANCHOR_LEFT" end
    local uw = UIParent:GetWidth()  or 0
    local uh = UIParent:GetHeight() or 0
    if uw == 0 or uh == 0 then return "ANCHOR_LEFT" end
    local v = (y > uh / 2) and "BOTTOM" or "TOP"
    local h
    if x < uw / 3 then       h = "RIGHT"
    elseif x > uw * 2 / 3 then h = "LEFT"
    else                     h = ""
    end
    return "ANCHOR_" .. v .. h
end

--- Show Horizon minimap tooltip anchored to the given frame (standalone button or Vista proxy).
--- @param ownerFrame Frame
--- @param anchor string|nil GameTooltip anchor token; defaults to a quadrant-aware anchor for the standalone btn.
--- @return nil
local function ShowGameTooltip(ownerFrame, anchor)
    if not GameTooltip or not ownerFrame then return end
    anchor = anchor or PickStandaloneTooltipAnchor(ownerFrame)
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

-- Size used for the standalone btn frame. When circular mode is on, override to Blizzard's
-- canonical 31px (with the same patch-notes-unread enlarge multiplier on top). Vista's
-- collected proxy keeps using `GetMinimapButtonDisplayPixelSize` so the bar stays uniform.
local function GetStandalonePixelSize()
    if addon.GetDB and addon.GetDB("minimapButtonCircular", false) then
        local base = STANDARD_CIRCULAR_BTN_PX
        if addon.PatchNotes_HasUnread and addon.PatchNotes_HasUnread() then
            local enlarged = math.floor(base * UNREAD_MINIMAP_SIZE_MULT + 0.5)
            return math.max(enlarged, base + 2)
        end
        return base
    end
    return GetMinimapButtonDisplayPixelSize()
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

-- When `minimapButtonCircular` is on, shrink btn.icon to LibDBIcon proportions, mask it to a circle,
-- and overlay Blizzard's MiniMap-TrackingBorder so it matches calendar/clock-style minimap buttons.
local function ApplyShape()
    if not btn or not btn.icon then return end
    local circular = addon.GetDB and addon.GetDB("minimapButtonCircular", false)
    local w = btn:GetWidth() or 22
    local h = btn:GetHeight() or 22
    if circular then
        -- Resize and re-anchor btn.icon to LibDBIcon's mainline proportions so the visible logo lands
        -- inside the gold ring's inner opening. Keep the 8% TexCoord crop the square mode uses:
        -- LibDBIcon assumes edge-to-edge icon content (Blizzard ability/quest icons), but HorizonLogo
        -- has transparent padding inside the texture canvas — without the crop, the visible glass is
        -- smaller than the 18×18 box and a gap appears between the logo and the ring's inner edge.
        btn.icon:ClearAllPoints()
        btn.icon:SetSize(w * ICON_SIZE_FRAC, h * ICON_SIZE_FRAC)
        btn.icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)

        if not iconMask then
            iconMask = btn:CreateMaskTexture(nil, "BACKGROUND")
            iconMask:SetTexture(addon.MASK_CIRCULAR_FILEDATAID,
                "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        end
        iconMask:ClearAllPoints()
        iconMask:SetAllPoints(btn.icon)
        btn.icon:AddMaskTexture(iconMask)

        if not ringBorder then
            ringBorder = btn:CreateTexture(nil, "OVERLAY")
            ringBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        end
        ringBorder:ClearAllPoints()
        ringBorder:SetSize(w * RING_SIZE_FRAC, h * RING_SIZE_FRAC)
        ringBorder:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        ringBorder:Show()

        -- Mouseover glow: same FileDataID LibDBIcon installs via SetHighlightTexture, which puts
        -- the texture on the auto-managed HIGHLIGHT layer (only visible while cursor is over btn).
        btn:SetHighlightTexture(136477)  -- "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    else
        -- Restore the square presentation: full-button icon with the original 8% TexCoord crop.
        btn.icon:ClearAllPoints()
        btn.icon:SetAllPoints(btn)
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        if iconMask then btn.icon:RemoveMaskTexture(iconMask) end
        if ringBorder then ringBorder:Hide() end
        local highlight = btn:GetHighlightTexture()
        if highlight then
            highlight:SetTexture(nil)
            highlight:Hide()
        end
    end
end

-- True when the minimap silhouette is a circle. Default WoW minimaps are round; when Vista is
-- enabled we follow its `vistaCircular` setting instead.
local function MinimapIsRoundShape()
    if addon.IsModuleEnabled and addon:IsModuleEnabled("vista") then
        return addon.GetDB and addon.GetDB("vistaCircular", false) and true or false
    end
    return true
end

-- Offset from Minimap CENTER to place the button on the minimap's perimeter at `angle` radians.
-- Round case: button center sits on the circular edge (half the icon overlaps the minimap, half
-- overhangs — matches Blizzard's calendar/clock placement). Square case: angle ray clamped to box.
local function GetEdgePosition(angle)
    local mw = (Minimap and Minimap:GetWidth()) or 140
    local mh = (Minimap and Minimap:GetHeight()) or 140
    local cosA, sinA = math.cos(angle), math.sin(angle)
    local hw, hh = mw / 2, mh / 2
    if MinimapIsRoundShape() then
        return cosA * hw, sinA * hh
    end
    local tx = (cosA == 0) and math.huge or (hw / math.abs(cosA))
    local ty = (sinA == 0) and math.huge or (hh / math.abs(sinA))
    local t = math.min(tx, ty)
    return cosA * t, sinA * t
end

-- Resolve the saved angle, migrating from the legacy `minimapButtonX/Y` keys on first read so
-- existing users land at the closest edge position rather than jumping to the default corner.
local function ResolveButtonAngle()
    if not addon.GetDB then return DEFAULT_ANGLE_RAD end
    local saved = tonumber(addon.GetDB("minimapButtonAngle", nil))
    if saved then return saved end
    local x = tonumber(addon.GetDB("minimapButtonX", nil))
    local y = tonumber(addon.GetDB("minimapButtonY", nil))
    if x and y and (x ~= 0 or y ~= 0) then
        local migrated = math.atan2(y, x)
        if addon.SetDB then addon.SetDB("minimapButtonAngle", migrated) end
        return migrated
    end
    return DEFAULT_ANGLE_RAD
end

local function ApplyPosition()
    if not btn or not Minimap then return end
    if vistaCollectedStandaloneHidden then return end
    local size = GetStandalonePixelSize()
    btn:SetSize(size, size)
    local circular = addon.GetDB and addon.GetDB("minimapButtonCircular", false)
    btn:ClearAllPoints()
    if circular then
        local x, y = GetEdgePosition(ResolveButtonAngle())
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    else
        local savedX = addon.GetDB and tonumber(addon.GetDB("minimapButtonX", nil))
        local savedY = addon.GetDB and tonumber(addon.GetDB("minimapButtonY", nil))
        if savedX and savedY then
            btn:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
        else
            btn:SetPoint(DEFAULT_ANCHOR, Minimap, DEFAULT_ANCHOR, DEFAULT_X, DEFAULT_Y)
        end
    end
    ApplyShape()
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
    local initSize = GetStandalonePixelSize()
    btn:SetSize(initSize, initSize)
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
    ApplyShape()

    btn:SetScript("OnClick", function(self, mouseButton)
        ShowOptions()
    end)
    btn:SetScript("OnDragStart", function(self)
        if IsMinimapButtonLocked() or InCombatLockdown() then return end
        local circular = addon.GetDB and addon.GetDB("minimapButtonCircular", false)
        if circular then
            -- Magnetic drag: dragHelper's OnUpdate keeps the button glued to the minimap edge
            -- under the cursor angle. Initialised lazily to keep load-time work minimal.
            if not dragHelper then
                dragHelper = CreateFrame("Frame")
                dragHelper:Hide()
                dragHelper:SetScript("OnUpdate", function(self)
                    local target = self.target
                    if not target or not Minimap then self:Hide(); return end
                    local mx, my = Minimap:GetCenter()
                    if not mx then return end
                    local cx, cy = GetCursorPosition()
                    local scale = (Minimap.GetEffectiveScale and Minimap:GetEffectiveScale()) or 1
                    if scale == 0 then scale = 1 end
                    cx, cy = cx / scale, cy / scale
                    local angle = math.atan2(cy - my, cx - mx)
                    local x, y = GetEdgePosition(angle)
                    target:ClearAllPoints()
                    target:SetPoint("CENTER", Minimap, "CENTER", x, y)
                end)
            end
            dragHelper.target = self
            dragHelper:Show()
        else
            self:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        local circular = addon.GetDB and addon.GetDB("minimapButtonCircular", false)
        if circular then
            if dragHelper then dragHelper.target = nil; dragHelper:Hide() end
            local mx, my = Minimap:GetCenter()
            local px, py = self:GetCenter()
            if mx and px then
                local angle = math.atan2(py - my, px - mx)
                if addon.SetDB then addon.SetDB("minimapButtonAngle", angle) end
                local nx, ny = GetEdgePosition(angle)
                self:ClearAllPoints()
                self:SetPoint("CENTER", Minimap, "CENTER", nx, ny)
            end
        else
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
        end
    end)
    btn:SetScript("OnEnter", function(self)
        if MinimapHoverFadeEnabled() then
            FadeButton(1)
        else
            self:SetAlpha(1)
        end
        self._hsTooltipStick = true
        ShowGameTooltip(self)
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
            GameTooltip:SetOwner(btn, PickStandaloneTooltipAnchor(btn))
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
--- Re-mask the standalone Horizon icon to match Vista's minimap shape (circular vs. square).
--- Called from Vista's ApplyOptions_Minimap so live shape toggles take effect without /reload.
--- @return nil
addon.MinimapButton_ApplyShape = ApplyShape
addon.MinimapButton_ShowGameTooltip = ShowGameTooltip
--- Effective minimap button edge size (slightly enlarged when patch notes are unread); Vista proxy matches this.
--- @return number
addon.MinimapButton_GetDisplayPixelSize = GetMinimapButtonDisplayPixelSize
