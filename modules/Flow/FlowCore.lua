--[[
    Horizon Suite - Flow - Core

    Chrome, typography and hook installation for the quest dialogue window.

    QuestFrame stays the frame and stays registered in UIPanelWindows, which
    owns its show/hide, ESC handling, panel stacking and auto-close on range.
    Flow only dresses it: no Show, Hide or SetParent is ever called on
    QuestFrame, so nothing here needs combat guarding and nothing taints the
    UIPanel system.

    Blizzard: QuestFrame and its four panels, QuestInfo_Display, UIFrameFadeIn.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Flow = addon.Flow or {}
local F = addon.Flow
local L = addon.L

local BACKDROP = {
    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
    insets   = { left = 1, right = 1, top = 1, bottom = 1 },
}

local FOOTER_HEIGHT   = 46
local DEFAULT_ACCENT  = { 0.20, 0.60, 1.00 }  -- Flow #3399FF
local DEFAULT_BG      = { 0.09, 0.09, 0.11 }
local DEFAULT_FONT    = "Fonts\\FRIZQT__.TTF"
local FONT_USE_GLOBAL = "__global__"

local PILL_LABELS = {
    CAMPAIGN  = "FLOW_PILL_CAMPAIGN",
    IMPORTANT = "FLOW_PILL_IMPORTANT",
    LEGENDARY = "FLOW_PILL_LEGENDARY",
    WORLD     = "FLOW_PILL_WORLD",
    DAILY     = "FLOW_PILL_DAILY",
    WEEKLY    = "FLOW_PILL_WEEKLY",
    PREY      = "FLOW_PILL_PREY",
    DUNGEON   = "FLOW_PILL_DUNGEON",
    RAID      = "FLOW_PILL_RAID",
}

local PANEL_NAMES = {
    "QuestFrameDetailPanel",
    "QuestFrameProgressPanel",
    "QuestFrameRewardPanel",
    "QuestFrameGreetingPanel",
}

local ART_NAMES = {
    "NineSlice", "Bg", "Border", "TopTileStreaks", "Inset",
    "PortraitContainer", "TitleBg", "TitleContainer", "Background",
}

local active         = false
local hooksInstalled = false
local hiddenRegions  = {}
local lastDisplayArgs
local chrome, footerFill, pill, pillText

-- ---------------------------------------------------------------------------
-- Settings
-- ---------------------------------------------------------------------------

local function GetDB(key, default)
    if not addon.GetDB then return default end
    return addon.GetDB(key, default)
end

--- Flow's accent colour: player class tint when Axis asks for it, else Flow blue.
--- @return number r, number g, number b
function F.GetAccentColor()
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("flow")
    if cc and cc[1] then return cc[1], cc[2], cc[3] end
    return DEFAULT_ACCENT[1], DEFAULT_ACCENT[2], DEFAULT_ACCENT[3]
end

--- Backdrop colour, stored as one key holding {r, g, b} like every other
--- Horizon colour option.
--- @return number r, number g, number b
local function GetBackdropColor()
    local c = GetDB("flowBackdropColor", nil)
    if type(c) == "table" and c[1] and c[2] and c[3] then
        return c[1], c[2], c[3]
    end
    return DEFAULT_BG[1], DEFAULT_BG[2], DEFAULT_BG[3]
end

--- Resolve the active font path for Flow. Mirrors Augment's Y.GetFontPath and
--- VistaCore.ResolveFont: per-module DB key, then the global fontPath DB, then
--- the client default.
--- @return string fontPath
function F.GetFontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end

    local raw = GetDB("flowFontPath", FONT_USE_GLOBAL) or FONT_USE_GLOBAL
    if raw == FONT_USE_GLOBAL or raw == "" then
        raw = GetDB("fontPath", nil)
    end
    if not raw or raw == "" or raw == FONT_USE_GLOBAL then
        return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or DEFAULT_FONT
    end
    if addon.ResolveFontPath then
        local resolved = addon.ResolveFontPath(raw)
        if resolved and resolved ~= "" then return resolved end
    end
    return raw
end

local function ApplyFont(fontString, size)
    local path = F.GetFontPath()
    if not path or not fontString or not fontString.SetFont then return end
    pcall(fontString.SetFont, fontString, path, size, "")
end

-- ---------------------------------------------------------------------------
-- Blizzard art
-- ---------------------------------------------------------------------------

--- Hide a frame's decorative regions, remembering them for restore.
--- @param frame Frame|nil
--- @return nil
function F.StripFrameArt(frame)
    if not frame then return end

    for i = 1, #ART_NAMES do
        local region = frame[ART_NAMES[i]]
        if region and region.Hide and region.IsShown then
            if region:IsShown() then hiddenRegions[region] = true end
            pcall(region.Hide, region)
        end
    end

    if not frame.GetRegions then return end
    local regions = { frame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Hide then
            local layer = r.GetDrawLayer and r:GetDrawLayer()
            if layer == "BACKGROUND" or layer == "BORDER" then
                if r.IsShown and r:IsShown() then hiddenRegions[r] = true end
                pcall(r.Hide, r)
            end
        end
    end
end

--- Re-show every region Flow hid. Best effort, as Blizzard may have hidden some
--- of them itself in the meantime.
--- @return nil
function F.RestoreFrameArt()
    for region in pairs(hiddenRegions) do
        if region and region.Show then pcall(region.Show, region) end
    end
    wipe(hiddenRegions)
end

-- ---------------------------------------------------------------------------
-- Chrome
-- ---------------------------------------------------------------------------

--- QuestFrame has no SetBackdrop in modern clients, so Flow parents its own
--- BackdropTemplate frame behind the content rather than calling backdrop
--- methods on QuestFrame itself.
--- @return Frame|nil
local function EnsureChrome()
    if chrome then return chrome end

    local parent = _G.QuestFrame
    if not parent then return nil end

    chrome = CreateFrame("Frame", "HorizonFlowChrome", parent, "BackdropTemplate")
    chrome:SetAllPoints(parent)
    chrome:SetFrameLevel(math.max(0, (parent:GetFrameLevel() or 1) - 1))
    chrome:SetBackdrop(BACKDROP)

    -- Footer well: a slightly lighter strip so the action buttons read as a
    -- footer rather than as controls floating on the page.
    footerFill = chrome:CreateTexture(nil, "ARTWORK")
    footerFill:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 1, 1)
    footerFill:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -1, 1)
    footerFill:SetHeight(FOOTER_HEIGHT)

    pill = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    pill:SetBackdrop(BACKDROP)
    pill:SetHeight(16)
    pillText = pill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pillText:SetPoint("CENTER", pill, "CENTER", 0, 0)
    pill:Hide()

    return chrome
end

--- Quest-type pill beside the title. Uses the shared category helpers so the
--- colours match whatever Focus would show for the same quest.
--- @param r number Accent red, used when the quest has no distinct category
--- @param g number
--- @param b number
--- @return nil
local function UpdatePill(r, g, b)
    if not pill then return end

    if not GetDB("flowShowTypePill", true) then
        pill:Hide()
        return
    end

    local questID = _G.GetQuestID and _G.GetQuestID()
    local category = questID and questID > 0 and addon.GetQuestCategory
        and addon.GetQuestCategory(questID) or nil
    local labelKey = category and PILL_LABELS[category] or nil
    if not labelKey then
        pill:Hide()
        return
    end

    local pr, pg, pb = r, g, b
    local qc = addon.GetQuestColor and addon.GetQuestColor(category)
    if qc and qc[1] then pr, pg, pb = qc[1], qc[2], qc[3] end

    local title = _G.QuestInfoTitleHeader
    if not title then
        pill:Hide()
        return
    end

    pillText:SetText(L[labelKey])
    pillText:SetTextColor(pr, pg, pb, 1)
    ApplyFont(pillText, 11)

    pill:SetWidth((pillText:GetStringWidth() or 40) + 14)
    pill:SetBackdropColor(pr, pg, pb, 0.12)
    pill:SetBackdropBorderColor(pr, pg, pb, 0.55)
    pill:ClearAllPoints()
    pill:SetPoint("BOTTOM", title, "TOP", 0, 6)
    pill:Show()
end

--- Blizzard colours the reward block through its "material" system, which hands
--- every label a parchment tan. Those labels sit on Flow's dark card and are
--- close to unreadable, and they carry the ornate quest font besides.
---
--- Only the reward frame's own regions are touched, not its children: the item
--- buttons below carry quality colours on their names, which Blizzard sets per
--- item and Flow has no business overriding.
--- @param size number Base font size
--- @return nil
local function RestyleRewardText(size)
    local rewards = _G.QuestInfoRewardsFrame
    if not rewards or not rewards.GetRegions then return end

    local regions = { rewards:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.GetObjectType and r:GetObjectType() == "FontString" then
            ApplyFont(r, size)
            if r.SetTextColor then r:SetTextColor(0.54, 0.54, 0.60, 1) end
        end
    end

    -- The "Rewards" heading is a named child rather than a plain region on
    -- every client that has it, so it is handled separately and guarded.
    local header = rewards.Header or _G.QuestInfoRewardsFrameHeader
    if header and header.SetTextColor then
        ApplyFont(header, size)
        header:SetTextColor(0.78, 0.78, 0.84, 1)
    end
end

--- Repaint whichever quest panel is currently showing.
--- Cosmetic only. Safe to call at any time; does nothing when Flow is off or
--- the frame is hidden.
--- @return nil
function F.Restyle()
    if not active then return end

    local frame = _G.QuestFrame
    if not frame or not frame.IsShown or not frame:IsShown() then return end

    F.StripFrameArt(frame)
    for i = 1, #PANEL_NAMES do
        F.StripFrameArt(_G[PANEL_NAMES[i]])
    end

    local c = EnsureChrome()
    if not c then return end

    local alpha = (tonumber(GetDB("flowBackdropOpacity", 92)) or 92) / 100
    local br, bg, bb = GetBackdropColor()
    local ar, ag, ab = F.GetAccentColor()

    c:SetBackdropColor(br, bg, bb, alpha)
    if GetDB("flowShowBorder", true) then
        c:SetBackdropBorderColor(0.18, 0.18, 0.22, 1)
    else
        c:SetBackdropBorderColor(0, 0, 0, 0)
    end
    footerFill:SetColorTexture(
        math.min(1, br + 0.03), math.min(1, bg + 0.03), math.min(1, bb + 0.04), alpha)
    c:Show()

    local size = tonumber(GetDB("flowFontSize", 13)) or 13
    RestyleRewardText(size)
    UpdatePill(ar, ag, ab)

    if F.ApplyCloseButton then F.ApplyCloseButton() end
    if F.ApplyShape then F.ApplyShape() end
end

-- ---------------------------------------------------------------------------
-- Hooks
-- ---------------------------------------------------------------------------

--- Re-run Blizzard's last QuestInfo layout. Used when a Flow element changes
--- height, such as the lore expander being toggled.
--- @return nil
function F.RedisplayQuestInfo()
    if not active or not lastDisplayArgs then return end
    if type(_G.QuestInfo_Display) ~= "function" then return end
    local a = lastDisplayArgs
    pcall(_G.QuestInfo_Display, a[1], a[2], a[3], a[4], a[5])
end

local function InstallHooks()
    if hooksInstalled then return end
    if type(_G.QuestInfo_Display) ~= "function" then return end

    hooksecurefunc("QuestInfo_Display", function(template, parentFrame, acceptButton, material, mapView)
        -- Captured even while inactive so a mid-session enable has something to
        -- redisplay from.
        lastDisplayArgs = { template, parentFrame, acceptButton, material, mapView }
        if not active then return end
        pcall(F.Restyle)
    end)

    local frame = _G.QuestFrame
    if frame and frame.HookScript then
        frame:HookScript("OnShow", function()
            if not active then return end
            pcall(F.Restyle)
            if GetDB("flowEntrance", true) and _G.UIFrameFadeIn then
                pcall(_G.UIFrameFadeIn, frame, 0.18, 0, 1)
            end
        end)
        frame:HookScript("OnHide", function()
            if chrome then chrome:Hide() end
        end)
    end

    hooksInstalled = true
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------

--- @return nil
function F.Enable()
    if active then return end
    active = true
    if F.InstallTemplates then F.InstallTemplates() end
    InstallHooks()
    if _G.QuestFrame and _G.QuestFrame.IsShown and _G.QuestFrame:IsShown() then
        pcall(F.Restyle)
    end
end

--- Full teardown. Blizzard's element arrays and art go back, Flow's frames
--- hide. hooksecurefunc cannot be undone, which is why `active` gates every
--- hook body rather than the hooks being removed.
--- @return nil
function F.Disable()
    active = false
    if F.RestoreTemplates then F.RestoreTemplates() end
    if F.HideBand then F.HideBand() end
    if F.ResetShape then F.ResetShape() end
    if chrome then chrome:Hide() end
    if pill then pill:Hide() end
    F.RestoreFrameArt()
end

--- Re-apply after an options change.
--- @return nil
function F.ApplyFlowOptions()
    if not active then return end
    pcall(F.Restyle)
end

--- Whether Flow is currently dressing the quest frame. Used by /h flow.
--- @return boolean
function F.IsActive()
    return active
end
