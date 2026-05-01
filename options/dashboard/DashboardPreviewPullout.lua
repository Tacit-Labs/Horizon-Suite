--[[
    Horizon Suite - Dashboard preview pullout (options/dashboard/).
    Shared shell + tab for module-specific live previews in the options dashboard.
    Modules register via DashboardPreview.Register(moduleKey, def).
]]

local addon = _G.HorizonSuite

addon.DashboardPreview = addon.DashboardPreview or {}
local DP = addon.DashboardPreview

local PULLOUT_ANIM_DUR = 0.20
local TAB_W = 26
local TAB_H = 80

local registrations = {}

local dashRef         = nil
local activeModuleKey = nil
local previewTabFrame = nil
local pulloutFrame    = nil
local contentHost     = nil
local titleLabel      = nil
local subtitleLabel   = nil
local pulloutHeaderBg = nil
local pulloutCloseBtn = nil

local function SetPulloutHeaderAlpha(a)
    if type(a) ~= "number" then return end
    if a < 0 then a = 0 elseif a > 1 then a = 1 end
    if titleLabel then titleLabel:SetAlpha(a) end
    if subtitleLabel then subtitleLabel:SetAlpha(a) end
    if pulloutHeaderBg then pulloutHeaderBg:SetAlpha(a) end
    if pulloutCloseBtn then pulloutCloseBtn:SetAlpha(a) end
end

-- Tab accent refs (for live class-colour updates and open-state feedback).
local tabBg        = nil
local tabAccentBar = nil
local tabIcon      = nil

local pulloutState    = "closed" -- "closed" | "opening" | "open" | "closing"
local pulloutProgress = 0
local animFullWidth   = 260
local mounted         = {} -- [moduleKey] = true after MountContent

local pulloutAnimFrame = CreateFrame("Frame")
pulloutAnimFrame:Hide()

local function easeOutPullout(t)
    return 1 - (1 - t) * (1 - t)
end

local function GetTabAccentColor()
    if addon.GetOptionsClassColor then
        local cc = addon.GetOptionsClassColor()
        if cc then return cc[1], cc[2], cc[3] end
    end
    return 0.2, 0.8, 0.9
end

local function UpdateTabOpenState()
    if not (tabIcon and tabAccentBar) then return end
    local isOpen = pulloutState == "open" or pulloutState == "opening"
    if isOpen then
        tabAccentBar:SetColorTexture(0.55, 0.55, 0.60, 1.0)
        tabIcon:SetVertexColor(0.80, 0.80, 0.85)
    else
        tabAccentBar:SetColorTexture(0.25, 0.25, 0.28, 0.60)
        tabIcon:SetVertexColor(0.45, 0.45, 0.50)
    end
end

--- Called when dashboard class colour is applied — tab uses neutral colours only; no-op.
--- @param r number
--- @param g number
--- @param b number
--- @return nil
function DP.ApplyAccentColor(r, g, b) end

local function GetPulloutFontPath()
    if addon.Dashboard_ResolveSavedDashboardFontPath and addon.GetDB then
        local raw = addon.GetDB("dashboardFontPath", addon.Dashboard_GetDefaultDashboardFontPath and addon.Dashboard_GetDefaultDashboardFontPath() or "Fonts\\FRIZQT__.TTF")
        return addon.Dashboard_ResolveSavedDashboardFontPath(raw)
    end
    if addon.GetDefaultFontPath then
        return addon.GetDefaultFontPath()
    end
    return "Fonts\\FRIZQT__.TTF"
end

local function ClosePulloutImmediate()
    pulloutAnimFrame:Hide()
    pulloutState = "closed"
    pulloutProgress = 0
    SetPulloutHeaderAlpha(1)
    UpdateTabOpenState()
    if pulloutFrame then
        pulloutFrame:Hide()
    end
end

--- @param moduleKey string e.g. "insight" — must match OptionCategories moduleKey
--- @param def table width, title, subtitle, MountContent(hostFrame), Refresh(), optional tabTooltipTitle, tabTooltipBody
function DP.Register(moduleKey, def)
    if type(moduleKey) ~= "string" or type(def) ~= "table" then return end
    registrations[moduleKey] = def
end

local function UpdateTabVisibility()
    if not previewTabFrame or not dashRef then return end
    local show = dashRef:IsShown() and activeModuleKey and registrations[activeModuleKey]
    previewTabFrame:SetShown(show and true or false)
end

--- @param moduleKey string|nil Module whose settings are shown, or nil on home/welcome/patch notes
function DP.SetActiveModuleKey(moduleKey)
    local prev = activeModuleKey
    activeModuleKey = moduleKey
    if moduleKey ~= prev or not moduleKey then
        ClosePulloutImmediate()
    end
    UpdateTabVisibility()
end

function DP.NotifyRefresh()
    if not (pulloutFrame and pulloutFrame:IsShown() and pulloutState == "open" and activeModuleKey) then
        return
    end
    local def = registrations[activeModuleKey]
    if def and def.refresh then
        pcall(def.refresh)
    end
end

local function ApplyHeader(def)
    if titleLabel and def.title then
        titleLabel:SetText(def.title)
    end
    if subtitleLabel and def.subtitle then
        subtitleLabel:SetText(def.subtitle)
    end
end

local function EnsurePulloutBuilt()
    if pulloutFrame then return end

    local dash    = dashRef or _G.HorizonSuiteDashboard
    local dashH   = (dash and dash:GetHeight() > 0 and dash:GetHeight()) or 720
    local dashLvl = (dash and dash:GetFrameLevel()) or 100
    local fontPath = GetPulloutFontPath()
    local reg = dash and dash._dashboardTypographyRefs

    pulloutFrame = CreateFrame("Frame", "HorizonSuiteDashboardPreviewPullout", UIParent, "BackdropTemplate")
    pulloutFrame:SetSize(260, dashH)
    pulloutFrame:SetFrameStrata("HIGH")
    pulloutFrame:SetFrameLevel(dashLvl + 1)
    pulloutFrame:SetClampedToScreen(false)

    pulloutFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    pulloutFrame:SetBackdropColor(0.08, 0.08, 0.11, 0.97)
    pulloutFrame:SetBackdropBorderColor(0.22, 0.22, 0.26, 1.0)

    pulloutHeaderBg = pulloutFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    pulloutHeaderBg:SetColorTexture(0, 0, 0, 0.35)
    pulloutHeaderBg:SetPoint("TOPLEFT", pulloutFrame, "TOPLEFT", 1, -1)
    pulloutHeaderBg:SetPoint("TOPRIGHT", pulloutFrame, "TOPRIGHT", -1, 0)
    pulloutHeaderBg:SetHeight(38)

    titleLabel = pulloutFrame:CreateFontString(nil, "OVERLAY")
    do
        local te = (addon.Dashboard_EffectiveDashboardFontSize and addon.Dashboard_EffectiveDashboardFontSize(13)) or 13
        local wf = (addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags()) or "OUTLINE"
        pcall(function()
            titleLabel:SetFont(fontPath, te, wf)
        end)
        if addon.Dashboard_ApplyTextShadow then
            addon.Dashboard_ApplyTextShadow(titleLabel)
        end
    end
    if reg and addon.Dashboard_RegisterTypographyFontString then
        addon.Dashboard_RegisterTypographyFontString(reg, titleLabel, 13, nil, true)
    end
    titleLabel:SetTextColor(0.65, 0.65, 0.70, 1.0)
    titleLabel:SetPoint("TOPLEFT", pulloutFrame, "TOPLEFT", 12, -12)

    subtitleLabel = pulloutFrame:CreateFontString(nil, "OVERLAY")
    do
        local se = (addon.Dashboard_EffectiveDashboardFontSize and addon.Dashboard_EffectiveDashboardFontSize(11)) or 11
        local wf = (addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags()) or "OUTLINE"
        pcall(function()
            subtitleLabel:SetFont(fontPath, se, wf)
        end)
        if addon.Dashboard_ApplyTextShadow then
            addon.Dashboard_ApplyTextShadow(subtitleLabel)
        end
    end
    if reg and addon.Dashboard_RegisterTypographyFontString then
        addon.Dashboard_RegisterTypographyFontString(reg, subtitleLabel, 11, nil, true)
    end
    subtitleLabel:SetTextColor(0.38, 0.38, 0.42, 1.0)
    subtitleLabel:SetPoint("TOPLEFT", pulloutFrame, "TOPLEFT", 12, -26)

    pulloutCloseBtn = CreateFrame("Button", nil, pulloutFrame)
    pulloutCloseBtn:SetSize(24, 24)
    pulloutCloseBtn:SetPoint("TOPRIGHT", pulloutFrame, "TOPRIGHT", -8, -7)
    pulloutCloseBtn:SetFrameLevel(pulloutFrame:GetFrameLevel() + 2)
    local closeTex = pulloutCloseBtn:CreateFontString(nil, "OVERLAY")
    do
        local ce = (addon.Dashboard_EffectiveDashboardFontSize and addon.Dashboard_EffectiveDashboardFontSize(16)) or 16
        local wf = (addon.Dashboard_GetWidgetOutlineFlags and addon.Dashboard_GetWidgetOutlineFlags()) or "OUTLINE"
        pcall(function()
            closeTex:SetFont(fontPath, ce, wf)
        end)
        if addon.Dashboard_ApplyTextShadow then
            addon.Dashboard_ApplyTextShadow(closeTex)
        end
    end
    if reg and addon.Dashboard_RegisterTypographyFontString then
        addon.Dashboard_RegisterTypographyFontString(reg, closeTex, 16, nil, true)
    end
    closeTex:SetTextColor(0.50, 0.50, 0.55, 1)
    closeTex:SetText("×")
    closeTex:SetAllPoints(pulloutCloseBtn)
    closeTex:SetJustifyH("CENTER")
    closeTex:SetJustifyV("MIDDLE")
    pulloutCloseBtn:SetScript("OnClick", function()
        DP.TogglePullout()
    end)
    pulloutCloseBtn:SetScript("OnEnter", function() closeTex:SetTextColor(1, 1, 1, 1) end)
    pulloutCloseBtn:SetScript("OnLeave", function() closeTex:SetTextColor(0.50, 0.50, 0.55, 1) end)

    contentHost = CreateFrame("Frame", nil, pulloutFrame)
    contentHost:SetClipsChildren(true)
    contentHost:SetPoint("TOPLEFT", pulloutFrame, "TOPLEFT", 0, -38)
    contentHost:SetPoint("BOTTOMRIGHT", pulloutFrame, "BOTTOMRIGHT", 0, 0)

    pulloutFrame:SetScript("OnHide", function()
        pulloutState = "closed"
        pulloutProgress = 0
        pulloutAnimFrame:Hide()
        SetPulloutHeaderAlpha(1)
        local dash = dashRef or _G.HorizonSuiteDashboard
        if previewTabFrame and dash then
            previewTabFrame:ClearAllPoints()
            previewTabFrame:SetPoint("LEFT", dash, "RIGHT", 0, 0)
        end
    end)
end

local function RepositionPulloutToDashboard()
    local dash = dashRef or _G.HorizonSuiteDashboard
    if not (pulloutFrame and dash) then return end
    local dashH = (dash:GetHeight() > 0 and dash:GetHeight()) or 720
    pulloutFrame:ClearAllPoints()
    pulloutFrame:SetPoint("TOPLEFT", dash, "TOPRIGHT", 0, 0)
    pulloutFrame:SetHeight(dashH)
end

local function EnsureMounted(moduleKey, def)
    if mounted[moduleKey] or not def.MountContent then return end
    if not contentHost then return end
    pcall(def.MountContent, contentHost)
    mounted[moduleKey] = true
end

local function OpenPullout()
    if not activeModuleKey or not registrations[activeModuleKey] then return end
    local def = registrations[activeModuleKey]

    EnsurePulloutBuilt()
    RepositionPulloutToDashboard()
    ApplyHeader(def)
    EnsureMounted(activeModuleKey, def)

    local w = tonumber(def.width) or 260
    animFullWidth = w
    pulloutFrame:SetWidth(1)
    SetPulloutHeaderAlpha(0)
    pulloutFrame:Show()
    if previewTabFrame then
        previewTabFrame:ClearAllPoints()
        previewTabFrame:SetPoint("LEFT", pulloutFrame, "RIGHT", 0, 0)
    end
    pulloutState = "opening"
    pulloutProgress = 0
    UpdateTabOpenState()
    pulloutAnimFrame:Show()
end

local function ClosePulloutAnimated()
    if not (pulloutFrame and pulloutFrame:IsShown()) then return end
    if pulloutState == "closing" then return end
    pulloutState = "closing"
    pulloutProgress = 0
    animFullWidth = math.max(pulloutFrame:GetWidth() or 1, 1)
    UpdateTabOpenState()
    pulloutAnimFrame:Show()
end

function DP.TogglePullout()
    if not activeModuleKey or not registrations[activeModuleKey] then return end
    if pulloutState == "opening" then return end
    if pulloutFrame and pulloutFrame:IsShown() and (pulloutState == "open" or pulloutState == "closing") then
        if pulloutState == "open" then
            ClosePulloutAnimated()
        end
        return
    end
    OpenPullout()
end

pulloutAnimFrame:SetScript("OnUpdate", function(self, elapsed)
    if not pulloutFrame then
        self:Hide()
        return
    end
    if pulloutState == "opening" then
        pulloutProgress = math.min(pulloutProgress + elapsed / PULLOUT_ANIM_DUR, 1)
        local t = easeOutPullout(pulloutProgress)
        local w = 1 + (animFullWidth - 1) * t
        pulloutFrame:SetWidth(math.max(1, math.floor(w)))
        SetPulloutHeaderAlpha(t)
        if pulloutProgress >= 1 then
            pulloutFrame:SetWidth(animFullWidth)
            pulloutState = "open"
            SetPulloutHeaderAlpha(1)
            self:Hide()
            local def = activeModuleKey and registrations[activeModuleKey]
            if def and def.refresh then
                pcall(def.refresh)
            end
        end
    elseif pulloutState == "closing" then
        pulloutProgress = math.min(pulloutProgress + elapsed / PULLOUT_ANIM_DUR, 1)
        local t = easeOutPullout(pulloutProgress)
        local w = animFullWidth - (animFullWidth - 1) * t
        pulloutFrame:SetWidth(math.max(1, math.floor(w)))
        SetPulloutHeaderAlpha(1 - t)
        if pulloutProgress >= 1 then
            pulloutState = "closed"
            SetPulloutHeaderAlpha(0)
            pulloutFrame:Hide()
            self:Hide()
        end
    else
        self:Hide()
    end
end)

local function EnsurePreviewTab(dashFrame)
    if previewTabFrame then return end
    if not dashFrame then return end

    previewTabFrame = CreateFrame("Button", "HorizonSuiteDashboardPreviewTab", UIParent)
    previewTabFrame:SetSize(TAB_W, TAB_H)
    -- CENTER anchor: tab is vertically centred on the dashboard right edge.
    previewTabFrame:SetPoint("LEFT", dashFrame, "RIGHT", 0, 0)
    previewTabFrame:SetFrameStrata("HIGH")
    previewTabFrame:SetFrameLevel((dashFrame:GetFrameLevel() or 100) + 2)
    previewTabFrame:SetClampedToScreen(false)

    -- Background matches the pullout panel so the two read as one surface when open.
    tabBg = previewTabFrame:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints(previewTabFrame)
    tabBg:SetColorTexture(0.08, 0.08, 0.11, 0.97)

    -- Right border (only edge that needs a visible line; left is the accent bar, top/bottom subtle).
    local borderR = previewTabFrame:CreateTexture(nil, "BORDER")
    borderR:SetColorTexture(0.22, 0.22, 0.26, 1.0)
    borderR:SetPoint("TOPLEFT", previewTabFrame, "TOPRIGHT", -1, 0)
    borderR:SetPoint("BOTTOMLEFT", previewTabFrame, "BOTTOMRIGHT", -1, 0)
    borderR:SetWidth(1)

    local borderT = previewTabFrame:CreateTexture(nil, "BORDER")
    borderT:SetColorTexture(0.18, 0.18, 0.22, 0.8)
    borderT:SetPoint("TOPLEFT", previewTabFrame, "TOPLEFT", 2, 0)
    borderT:SetPoint("TOPRIGHT", previewTabFrame, "TOPRIGHT", -1, 0)
    borderT:SetHeight(1)

    local borderB = previewTabFrame:CreateTexture(nil, "BORDER")
    borderB:SetColorTexture(0.18, 0.18, 0.22, 0.8)
    borderB:SetPoint("BOTTOMLEFT", previewTabFrame, "BOTTOMLEFT", 2, 0)
    borderB:SetPoint("BOTTOMRIGHT", previewTabFrame, "BOTTOMRIGHT", -1, 0)
    borderB:SetHeight(1)

    -- 2px accent bar — left edge of tab.
    tabAccentBar = previewTabFrame:CreateTexture(nil, "ARTWORK")
    tabAccentBar:SetSize(2, TAB_H)
    tabAccentBar:SetPoint("TOPLEFT", previewTabFrame, "TOPLEFT", 0, 0)
    tabAccentBar:SetColorTexture(0.25, 0.25, 0.28, 0.60)

    -- Spyglass icon — centered in the tab.
    tabIcon = previewTabFrame:CreateTexture(nil, "ARTWORK")
    tabIcon:SetSize(18, 18)
    tabIcon:SetPoint("CENTER", previewTabFrame, "CENTER", 1, 0)
    tabIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
    tabIcon:SetVertexColor(0.45, 0.45, 0.50)

    previewTabFrame:SetScript("OnEnter", function()
        tabAccentBar:SetColorTexture(0.65, 0.65, 0.70, 1.0)
        tabIcon:SetVertexColor(0.95, 0.95, 1.00)
        tabBg:SetColorTexture(0.12, 0.12, 0.16, 0.97)
        local def = activeModuleKey and registrations[activeModuleKey]
        local tTitle = (def and def.tabTooltipTitle) or "Preview"
        local tBody  = (def and def.tabTooltipBody)  or ""
        GameTooltip:SetOwner(previewTabFrame, "ANCHOR_LEFT")
        GameTooltip:SetText(tTitle, 1, 1, 1)
        if tBody ~= "" then
            GameTooltip:AddLine(tBody, 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    previewTabFrame:SetScript("OnLeave", function()
        tabBg:SetColorTexture(0.08, 0.08, 0.11, 0.97)
        UpdateTabOpenState()
        GameTooltip:Hide()
    end)
    previewTabFrame:SetScript("OnClick", function()
        DP.TogglePullout()
    end)

    UpdateTabOpenState()
end

--- Idempotent: bind tab + hooks to the dashboard frame created by Dashboard_BuildMainFrame / DashboardPanel slash handler.
function DP.InitDashboard(dashFrame)
    if not dashFrame then return end
    dashRef = dashFrame
    EnsurePreviewTab(dashFrame)

    if not dashFrame._horizonDashboardPreviewHooked then
        dashFrame._horizonDashboardPreviewHooked = true
        dashFrame:HookScript("OnShow", function()
            UpdateTabVisibility()
        end)
        dashFrame:HookScript("OnHide", function()
            ClosePulloutImmediate()
            if previewTabFrame then
                previewTabFrame:Hide()
            end
        end)
    end

    DP.SetActiveModuleKey(dashFrame.currentModuleKey)

    if addon.ApplyDashboardTypography then
        addon.ApplyDashboardTypography()
    end
end

-- Backwards compatibility for Insight.* callers
function DP.ClosePullout()
    if pulloutFrame and pulloutFrame:IsShown() and pulloutState == "open" then
        ClosePulloutAnimated()
    elseif pulloutFrame and pulloutFrame:IsShown() then
        ClosePulloutImmediate()
    end
end
