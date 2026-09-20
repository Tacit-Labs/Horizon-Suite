--[[
    Horizon Suite - Augment / Loot Roll - Core
    Lifecycle, anchor, edit mode, and Blizzard frame suppression.

    SUPPRESSION IS PER ROLL, NOT WHOLESALE. The 2026-08-07 loot-window design
    was written to fix exactly this mistake: AugmentBlizzard.lua used to call
    KillBlizzardFrame(LootFrame) and took away the window players need in order
    to loot at all. A loot roll has the same property — take the frame away
    without putting one back and the roll is simply lost.

    So the hook below asks, for each roll, whether Horizon actually drew it. A
    roll we skipped (below the quality floor, past the visible cap, or no item
    info) keeps its Blizzard frame. GroupLootContainer itself is never killed.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local Y = addon.Augment
local R = Y.Roll
R.Core = R.Core or {}
local L = addon.L

local editMode = false
local nativeEditMode = false
local editOverlay, editTitle, editHint
local hookInstalled = false
local originalAddRoll

-- ============================================================================
-- ENABLED STATE
-- ============================================================================

--- The mini-module runs only when Augment runs, the pill is on, and the client
--- actually has group loot rolls.
--- @return boolean
function R.IsEnabled()
    if not addon.IsModuleEnabled or not addon:IsModuleEnabled("augment") then return false end
    local D = addon.AUGMENT_DEFAULTS
    if R.GetDB("augmentLootRollEnabled", D.augmentLootRollEnabled) == false then return false end
    if addon.Platform and not addon.Platform.Has("groupLootRolls") then return false end
    return true
end

--- @return boolean
function R.IsEditing()
    return editMode or nativeEditMode
end

-- ============================================================================
-- ANCHOR
-- ============================================================================

function R.ApplyStoredAnchor(frame)
    if not frame then return end
    local point, relPoint, x, y = R.GetPosition()
    point    = point    or R.DEFAULT_ANCHOR
    relPoint = relPoint or R.DEFAULT_ANCHOR
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, relPoint, tonumber(x) or R.DEFAULT_X, tonumber(y) or R.DEFAULT_Y)
end

-- After StartMoving/StopMovingOrSizing WoW re-anchors internally to TOPLEFT
-- regardless of the original point, so recompute against the grow direction
-- rather than trusting GetPoint(). Same reasoning as Alerts' SaveFramePosition.
local function SaveFramePosition()
    local frame = R.GetAnchorFrame()
    if not frame then return end
    local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
    if not left or not right or not top or not bottom then return end
    local centerX = (left + right) / 2
    local x = math.floor(centerX - (UIParent:GetLeft() + UIParent:GetRight()) / 2 + 0.5)
    local point = (R.GetGrowDirection() == "up") and "BOTTOM" or "TOP"
    local y
    if point == "BOTTOM" then
        y = math.floor(bottom - UIParent:GetBottom() + 0.5)
    else
        y = math.floor(top - UIParent:GetTop() + 0.5)
    end
    R.SavePosition(point, point, x, y)
end
R.SaveFramePosition = SaveFramePosition

function R.ResetPosition()
    R.ClearPosition()
    R.RestoreSavedPosition()
end

-- ============================================================================
-- BLIZZARD SUPPRESSION
-- ============================================================================

--- Wrap GroupLootContainer_AddRoll so Blizzard skips only the rolls we drew.
---
--- The wrapper asks R.EnsureRollHandled first rather than reading a set our own
--- event handler filled in. Both handlers listen to START_LOOT_ROLL and the
--- order between them is not guaranteed; making the decision itself memoized
--- and callable from either side removes the race instead of betting on it.
--- @return nil
local function InstallSuppressionHook()
    if hookInstalled then return end
    if type(_G.GroupLootContainer_AddRoll) ~= "function" then return end

    hookInstalled = true
    originalAddRoll = _G.GroupLootContainer_AddRoll

    _G.GroupLootContainer_AddRoll = function(rollID, rollTime, ...)
        if R.IsEnabled() then
            local ok, drew = pcall(R.EnsureRollHandled, rollID, rollTime)
            if ok and drew then
                -- Horizon is showing this roll; Blizzard's frame stays closed.
                return
            end
        end
        return originalAddRoll(rollID, rollTime, ...)
    end
end

--- Put Blizzard's own function back. Only restores the wrapper we installed,
--- so an addon that hooked us afterwards is left alone.
--- @return nil
local function RemoveSuppressionHook()
    if not hookInstalled then return end
    hookInstalled = false
    if originalAddRoll and _G.GroupLootContainer_AddRoll then
        _G.GroupLootContainer_AddRoll = originalAddRoll
    end
    originalAddRoll = nil
end

--- Close any Blizzard roll frame already open for a roll we have taken over.
--- Covers the case where Blizzard drew first — on a reload mid-roll, say.
--- @param rollID number
--- @return nil
function R.HideBlizzardRollFrame(rollID)
    for i = 1, 4 do
        local frame = _G["GroupLootFrame" .. i]
        if frame and frame.rollID == rollID and frame:IsShown() then
            if _G.GroupLootContainer_RemoveFrame then
                pcall(_G.GroupLootContainer_RemoveFrame, _G.GroupLootContainer, frame)
            else
                frame:Hide()
            end
        end
    end
end

-- ============================================================================
-- ROLL FEEDBACK
-- ============================================================================

--- Called after the player clicks one of our buttons.
--- @param rollID number
--- @param rollType number
--- @return nil
function R.Core.OnRolled(rollID, rollType)
    R.MarkRolled(rollID, rollType)
end

--- Show the player's own need roll the moment the server resolves it
--- (MAIN_SPEC_NEED_ROLL). Blizzard plays an animation; the number is the part
--- that carries information, so it goes on the row's info line.
--- @param rollID number
--- @param roll number
--- @param isWinning boolean
--- @return nil
function R.ShowOwnRoll(rollID, roll, isWinning)
    local row = R.FindRow and R.FindRow(rollID)
    if not row then return end
    local template = isWinning
        and ((L and L["LOOT_ROLL_YOUR_ROLL_WINNING"]) or "You rolled %d — winning")
        or  ((L and L["LOOT_ROLL_YOUR_ROLL"]) or "You rolled %d")
    local color = isWinning and "|cFF40C040" or "|cFFAAAAAA"
    row.body:SetText(color .. template:format(tonumber(roll) or 0) .. "|r")
end

-- ============================================================================
-- EDIT MODE
-- Mirrors Alerts: attach to LootFrame's Edit Mode panel when it exists so one
-- "Horizon Suite" checkbox governs every Horizon element, rather than adding a
-- third checkbox of our own.
-- ============================================================================

local function BuildEditOverlay()
    local frame = R.GetAnchorFrame()
    if not frame or editOverlay then return end

    editOverlay = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    editOverlay:SetAllPoints(frame)
    editOverlay:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editOverlay:SetBackdropColor(0, 0, 0, 0.5)
    editOverlay:SetBackdropBorderColor(0.95, 0.65, 0.25, 0.8)
    editOverlay:SetFrameLevel(frame:GetFrameLevel() + 10)
    editOverlay:EnableMouse(false)
    editOverlay:RegisterForDrag("LeftButton")
    editOverlay:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        frame:SetMovable(true)
        frame:StartMoving()
    end)
    editOverlay:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        frame:StopMovingOrSizing()
        frame:SetMovable(false)
        SaveFramePosition()
    end)
    editOverlay:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() then
            if R.Demo and R.Demo.Run then R.Demo.Run() end
        end
    end)
    editOverlay:Hide()

    editTitle = editOverlay:CreateFontString(nil, "OVERLAY")
    editTitle:SetFontObject(GameFontNormalLarge)
    editTitle:SetTextColor(0.95, 0.65, 0.25, 1)
    editTitle:SetPoint("CENTER", editOverlay, "CENTER", 0, 10)
    editTitle:SetText((L and L["LOOT_ROLL_EDIT_MODE_AREA"]) or "Loot Rolls")

    editHint = editOverlay:CreateFontString(nil, "OVERLAY")
    editHint:SetFontObject(GameFontNormalSmall)
    editHint:SetTextColor(0.7, 0.7, 0.7, 1)
    editHint:SetPoint("CENTER", editOverlay, "CENTER", 0, -8)
    editHint:SetText((L and L["LOOT_ROLL_EDIT_MODE_HINT"]) or "Drag to move · Shift-click for a demo roll")
end

--- Manual toggle, no Blizzard Edit Mode needed.
--- @return nil
function R.ToggleEditMode()
    if not R.IsReady() then return end
    BuildEditOverlay()
    if not editOverlay then return end

    editMode = not editMode
    local frame = R.GetAnchorFrame()
    if editMode then
        editOverlay:EnableMouse(true)
        editOverlay:Show()
        frame:Show()
        if R.Demo and R.Demo.Run then R.Demo.Run() end
    else
        if not nativeEditMode then editOverlay:EnableMouse(false) end
        editOverlay:Hide()
        if not R.HasActiveRows() then frame:Hide() end
    end
end

function R.HideAnchorFrame()
    if not R.IsReady() then return end
    if editMode then
        editMode = false
        if editOverlay and not nativeEditMode then
            editOverlay:EnableMouse(false)
            editOverlay:Hide()
        end
    end
    SaveFramePosition()
    local frame = R.GetAnchorFrame()
    if frame and not R.HasActiveRows() and not R.IsEditing() then frame:Hide() end
end

local function HookNativeEditMode()
    if not EventRegistry then return end

    EventRegistry:RegisterCallback("EditMode.Enter", function()
        if not R.IsReady() then return end
        BuildEditOverlay()
        if not editOverlay then return end
        nativeEditMode = true

        local D = addon.AUGMENT_DEFAULTS
        local show = R.GetDB("lootRollEditModeShow", D.lootRollEditModeShow) ~= false
        if show then
            editOverlay:EnableMouse(true)
            editOverlay:Show()
            R.GetAnchorFrame():Show()
            if R.Demo and R.Demo.Run then R.Demo.Run() end
        end
    end, "HorizonSuiteAugmentLootRoll")

    EventRegistry:RegisterCallback("EditMode.Exit", function()
        if not R.IsReady() then return end
        -- Deferred by a frame: reacting inline to Blizzard's synchronous Edit
        -- Mode exit chain can taint secure frame state (same as LootFrame).
        C_Timer.After(0, function()
            nativeEditMode = false
            if editOverlay and not editMode then
                editOverlay:EnableMouse(false)
                editOverlay:Hide()
            end
            SaveFramePosition()
            local frame = R.GetAnchorFrame()
            if frame and not R.HasActiveRows() and not editMode then frame:Hide() end
        end)
    end, "HorizonSuiteAugmentLootRoll")

    -- Attach to LootFrame's Edit Mode panel when it owns one, so the single
    -- "Horizon Suite" checkbox governs this overlay too.
    local panel = Y.editModePanel
    if panel then
        local previous = panel.onCheckboxToggle
        panel.onCheckboxToggle = function(checked)
            if previous then pcall(previous, checked) end
            if addon.SetDB then addon.SetDB("lootRollEditModeShow", checked) end
            if nativeEditMode and R.IsReady() and editOverlay then
                if checked then
                    editOverlay:EnableMouse(true)
                    editOverlay:Show()
                    R.GetAnchorFrame():Show()
                else
                    editOverlay:EnableMouse(false)
                    editOverlay:Hide()
                    if not R.HasActiveRows() then R.GetAnchorFrame():Hide() end
                end
            end
        end
    end
end

-- ============================================================================
-- LIFECYCLE
-- ============================================================================

function R.Enable()
    if addon.Platform and not addon.Platform.Has("groupLootRolls") then
        -- Nothing to hook: this client has no group loot rolls at all.
        return
    end
    R.InitFrames()
    R.RestoreSavedPosition()
    R.EnableEvents()
    InstallSuppressionHook()
    HookNativeEditMode()
    R.AdoptOpenRolls()
end

--- Take over any roll already on screen when the module starts.
--- Covers switching the module on mid-dungeon and reloading mid-roll: the
--- START_LOOT_ROLL for those has already been and gone, so without this they
--- would stay on Blizzard's frames until the next roll.
--- @return nil
function R.AdoptOpenRolls()
    if not R.IsEnabled() then return end
    for i = 1, 4 do
        local frame = _G["GroupLootFrame" .. i]
        if frame and frame.rollID and frame:IsShown() then
            local rollTime = frame.rollTime
            -- Not yet decided: EnsureRollHandled is memoized, so a roll we have
            -- already ruled on is left exactly as it is.
            pcall(R.EnsureRollHandled, frame.rollID, rollTime)
        end
    end
end

function R.Disable()
    R.DisableEvents()
    RemoveSuppressionHook()
    R.ForgetRoll(nil)
    R.ClearAllRolls()
end

--- Re-apply everything an options change can affect.
--- @return nil
function R.ApplyOptions()
    if not R.IsReady() then return end
    R.ApplyScale()
    R.RestoreSavedPosition()
    if R.IsEnabled() then
        R.EnableEvents()
        InstallSuppressionHook()
    else
        R.DisableEvents()
        RemoveSuppressionHook()
        R.ClearAllRolls()
    end
end
