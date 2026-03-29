--[[
    Horizon Suite - Dashboard Options Panel
    New standalone dashboard-style options UI.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local L = addon.L

local function BrandModule(moduleKey)
    local t = addon.BrandDisplay and addon.BrandDisplay.module
    if not moduleKey or not t then return nil end
    return t[moduleKey]
end

-- Dashboard background: Default = solid only. Midnight = addon PNG. Talents = Blizzard class-talent atlas for current spec.
local DASHBOARD_BG_MEDIA_PATH = "Interface\\AddOns\\HorizonSuite\\media\\dashboard\\"
-- Full-bleed background: solid + art stack. Solid alpha adjusts dynamically so default/horizon (solid-only)
-- stays dark and readable, while Midnight/Specialisation (solid + art) lets the world peek through.
-- Art alpha is user-configurable via dashboardBackgroundOpacity (50–100%, stored as integer, default 90).
local DASHBOARD_BG_SOLID_ALPHA_BARE = 0.88      -- used when NO art layer is showing (default/horizon)
local DASHBOARD_BG_SOLID_ALPHA_WITH_ART = 0.25  -- under themed art; kept low so art+solid don't compound to fully opaque
local DASHBOARD_BG_ART_ALPHA_DEFAULT = 0.90     -- fallback before DB is available

local function GetDashboardBgArtAlpha()
    if addon.GetDB then
        local pct = tonumber(addon.GetDB("dashboardBackgroundOpacity", 90)) or 90
        return math.max(0.50, math.min(1.0, pct / 100))
    end
    return DASHBOARD_BG_ART_ALPHA_DEFAULT
end
-- Interior fills: lower so tiles/sidebar do not read as opaque slabs over the softened backdrop.
local DASHBOARD_CHILD_PANEL_ALPHA = 0.72
local DASHBOARD_CONTENT_CARD_ALPHA_MULT = 0.78
-- Home module tiles: polish + bento Axis (same width as others; height = two stacked tiles + gap).
local DASH_HOME_TILE_W = 190
local DASH_HOME_TILE_H = 160
local DASH_HOME_TILE_GAP = 15
local DASH_HOME_TILE_COLS = 4
local DASH_HOME_TILE_BG_ALPHA_MULT = 0.82
local DASH_HOME_TILE_BORDER_ALPHA_MULT = 0.88
-- Disabled modules on Home (any moduleKey): dimmer fill/border than live tiles.
local DASH_HOME_SKELETON_BG_ALPHA_MULT = 0.58
local DASH_HOME_SKELETON_BORDER_ALPHA_MULT = 0.62
local DASHBOARD_BG_CROSSFADE_SEC = 0.4
local DASHBOARD_BG_FILES = {
    midnight = "backgrounds\\Wow-Midnight.png",
}
local DASHBOARD_BG_ORDER = { "horizon", "midnight", "talents" }
addon.DashboardBackgroundThemeOrder = DASHBOARD_BG_ORDER

local function NormalizeDashboardThemeId(themeId)
    if themeId == "midnight" then
        return "midnight"
    end
    if themeId == "talents" then
        return "talents"
    end
    return "horizon"
end

-- Spec ID -> talent UI background atlas (mirrors Blizzard_PlayerSpells ClassTalents/Blizzard_ClassTalentUtil.lua SpecializationVisuals.background).
-- Update when Blizzard adds a new specialization.
local DASHBOARD_SPEC_TALENT_BACKGROUND_ATLAS = {
    [250] = "talents-background-deathknight-blood",
    [251] = "talents-background-deathknight-frost",
    [252] = "talents-background-deathknight-unholy",
    [577] = "talents-background-demonhunter-havoc",
    [581] = "talents-background-demonhunter-vengeance",
    [1480] = "talents-background-demonhunter-devourer",
    [102] = "talents-background-druid-balance",
    [103] = "talents-background-druid-feral",
    [104] = "talents-background-druid-guardian",
    [105] = "talents-background-druid-restoration",
    [1467] = "talents-background-evoker-devastation",
    [1468] = "talents-background-evoker-preservation",
    [1473] = "talents-background-evoker-augmentation",
    [253] = "talents-background-hunter-beastmastery",
    [254] = "talents-background-hunter-marksmanship",
    [255] = "talents-background-hunter-survival",
    [62] = "talents-background-mage-arcane",
    [63] = "talents-background-mage-fire",
    [64] = "talents-background-mage-frost",
    [268] = "talents-background-monk-brewmaster",
    [269] = "talents-background-monk-windwalker",
    [270] = "talents-background-monk-mistweaver",
    [65] = "talents-background-paladin-holy",
    [66] = "talents-background-paladin-protection",
    [70] = "talents-background-paladin-retribution",
    [256] = "talents-background-priest-discipline",
    [257] = "talents-background-priest-holy",
    [258] = "talents-background-priest-shadow",
    [259] = "talents-background-rogue-assassination",
    [260] = "talents-background-rogue-outlaw",
    [261] = "talents-background-rogue-subtlety",
    [262] = "talents-background-shaman-elemental",
    [263] = "talents-background-shaman-enhancement",
    [264] = "talents-background-shaman-restoration",
    [265] = "talents-background-warlock-affliction",
    [266] = "talents-background-warlock-demonology",
    [267] = "talents-background-warlock-destruction",
    [71] = "talents-background-warrior-arms",
    [72] = "talents-background-warrior-fury",
    [73] = "talents-background-warrior-protection",
}

-- Atlas name for Player Spells / talent UI spec background (local copy of Blizzard SpecializationVisuals; no ClassTalentUtil load required).
local function GetDashboardTalentBackgroundAtlas()
    if not GetSpecialization or not GetSpecializationInfo then
        return nil
    end
    local specIndex = GetSpecialization()
    if type(specIndex) ~= "number" or specIndex < 1 then
        return nil
    end
    local specID = select(1, GetSpecializationInfo(specIndex))
    if type(specID) ~= "number" or specID < 1 then
        return nil
    end
    local atlas = DASHBOARD_SPEC_TALENT_BACKGROUND_ATLAS[specID]
    if type(atlas) ~= "string" or atlas == "" then
        return nil
    end
    if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(atlas) then
        return nil
    end
    return atlas
end

local function ClearDashboardBgLayer(tex)
    tex:Hide()
    if tex.SetTexture then
        tex:SetTexture(nil)
    end
    if tex.SetAtlas then
        tex:SetAtlas(nil)
    end
    tex:SetVertexColor(1, 1, 1, 1)
    tex:SetAlpha(1)
end

-- Normalized theme id -> target descriptor for background layers.
local function ResolveDashboardBackgroundTarget(themeId)
    if themeId == "horizon" then
        return { kind = "clear", signature = "horizon" }
    end
    if themeId == "midnight" then
        local rel = DASHBOARD_BG_FILES.midnight
        if not rel then
            return { kind = "clear", signature = "horizon" }
        end
        local path = DASHBOARD_BG_MEDIA_PATH .. rel
        return { kind = "texture", path = path, signature = "midnight:" .. path }
    end
    if themeId == "talents" then
        local atlas = GetDashboardTalentBackgroundAtlas()
        if not atlas then
            return { kind = "clear", signature = "horizon" }
        end
        return { kind = "atlas", atlas = atlas, signature = "talents:" .. atlas }
    end
    return { kind = "clear", signature = "horizon" }
end

local function ApplyDashboardBgToTexture(tex, target)
    if target.kind == "clear" then
        return true
    end
    if target.kind == "texture" then
        if tex.SetAtlas then
            tex:SetAtlas(nil)
        end
        tex:SetTexture(target.path)
        return true
    end
    if target.kind == "atlas" then
        if tex.SetTexture then
            tex:SetTexture(nil)
        end
        local ok = pcall(function()
            tex:SetAtlas(target.atlas, true)
        end)
        return ok
    end
    return false
end

local function GetDashboardBgSolidAlpha(hasArt)
    local userAlpha = GetDashboardBgArtAlpha()
    if hasArt then
        return DASHBOARD_BG_SOLID_ALPHA_WITH_ART
    end
    return userAlpha
end

local function SetSolidAlphaForTarget(dash, target)
    local solid = dash._dashboardBgSolid
    if not solid then return end
    local a = GetDashboardBgSolidAlpha(target.kind ~= "clear")
    solid:SetColorTexture(0.05, 0.05, 0.07, a)
end

local function SettleDashboardBackgroundSnap(dash, target)
    local L1, L2 = dash._dashboardBgArt1, dash._dashboardBgArt2
    local driver = dash._dashboardBgFadeDriver
    if driver then
        driver:SetScript("OnUpdate", nil)
    end
    dash._dashboardBgFading = false
    ClearDashboardBgLayer(L1)
    ClearDashboardBgLayer(L2)
    SetSolidAlphaForTarget(dash, target)
    if target.kind == "clear" then
        dash._dashboardBgLastSig = "horizon"
        dash._dashboardBgActiveLayer = 1
        return
    end
    if not ApplyDashboardBgToTexture(L1, target) then
        dash._dashboardBgLastSig = "horizon"
        dash._dashboardBgActiveLayer = 1
        SetSolidAlphaForTarget(dash, { kind = "clear" })
        return
    end
    L1:SetVertexColor(1, 1, 1, 1)
    L1:SetAlpha(GetDashboardBgArtAlpha())
    L1:Show()
    dash._dashboardBgLastSig = target.signature
    dash._dashboardBgActiveLayer = 1
end

local function StartDashboardBgFade(dash, mode, fromTex, toTex, target, newActiveLayer)
    local driver = dash._dashboardBgFadeDriver
    local elapsedAcc = 0
    dash._dashboardBgFading = true
    local solid = dash._dashboardBgSolid
    local solidBare = GetDashboardBgSolidAlpha(false)
    local solidArt  = GetDashboardBgSolidAlpha(true)
    local solidFrom = (mode == "out") and solidArt or
                      (mode == "in")  and solidBare or
                      solidArt
    local solidTo   = (mode == "out") and solidBare or
                      (mode == "in")  and solidArt or
                      solidArt
    local artA = GetDashboardBgArtAlpha()
    driver:SetScript("OnUpdate", function(_, dt)
        elapsedAcc = elapsedAcc + dt
        local t = math.min(1, elapsedAcc / DASHBOARD_BG_CROSSFADE_SEC)
        local s = t * t * (3 - 2 * t)
        if solid then
            solid:SetColorTexture(0.05, 0.05, 0.07, solidFrom + (solidTo - solidFrom) * s)
        end
        if mode == "in" then
            toTex:SetAlpha(s * artA)
        elseif mode == "out" then
            fromTex:SetAlpha((1 - s) * artA)
        else
            fromTex:SetAlpha((1 - s) * artA)
            toTex:SetAlpha(s * artA)
        end
        if t >= 1 then
            driver:SetScript("OnUpdate", nil)
            dash._dashboardBgFading = false
            if solid then
                solid:SetColorTexture(0.05, 0.05, 0.07, solidTo)
            end
            if mode == "in" then
                toTex:SetAlpha(artA)
                dash._dashboardBgLastSig = target.signature
                dash._dashboardBgActiveLayer = newActiveLayer
            elseif mode == "out" then
                ClearDashboardBgLayer(fromTex)
                dash._dashboardBgLastSig = "horizon"
                dash._dashboardBgActiveLayer = 1
            else
                ClearDashboardBgLayer(fromTex)
                toTex:SetAlpha(artA)
                dash._dashboardBgLastSig = target.signature
                dash._dashboardBgActiveLayer = newActiveLayer
            end
        end
    end)
end

-- Dashboard window (16:9). Author full-bleed PNG backgrounds at this size (or 2×, e.g. 2560×1440).
local DASHBOARD_FRAME_W = 1280
local DASHBOARD_FRAME_H = 720
local DASHBOARD_VIEW_H = DASHBOARD_FRAME_H - 20 -- main views sit inside frame below header band

-- Main content header band (anchors to dashboard frame TOP). Subcategory/detail reuse these Y values with head/headSub so titles do not shift between Home, Welcome, and deeper views.
local DASH_HEAD_TITLE_Y = -30
local DASH_HEAD_SUBTITLE_Y = -58
local DASH_SEARCH_Y = -88
local DASH_SEARCH_BOX_H = 36

--- Apply saved dashboard background theme to the dashboard frame (if it exists).
--- Crossfades between image themes when the dashboard is visible; snaps when hidden or on first apply.
--- @return nil
function addon.ApplyDashboardBackground()
    local dash = _G.HorizonSuiteDashboard
    local L1, L2 = dash and dash._dashboardBgArt1, dash and dash._dashboardBgArt2
    if not dash or not L1 or not L2 then
        return
    end
    local raw = (addon.GetDB and addon.GetDB("dashboardBackgroundTheme", "horizon")) or "horizon"
    local themeId = NormalizeDashboardThemeId(raw)
    local solid = dash._dashboardBgSolid
    if solid then
        solid:Show()
    end

    local target = ResolveDashboardBackgroundTarget(themeId)

    if dash._dashboardBgFading and dash._dashboardBgFadeDriver then
        dash._dashboardBgFadeDriver:SetScript("OnUpdate", nil)
        dash._dashboardBgFading = false
        SettleDashboardBackgroundSnap(dash, target)
        return
    end

    if target.signature == dash._dashboardBgLastSig then
        -- Theme unchanged but opacity may have changed; refresh alpha on visible layers + solid.
        SetSolidAlphaForTarget(dash, target)
        local activeIdx = dash._dashboardBgActiveLayer or 1
        local activeTex = (activeIdx == 1) and L1 or L2
        if target.kind ~= "clear" and activeTex:IsShown() then
            activeTex:SetAlpha(GetDashboardBgArtAlpha())
        end
        return
    end

    if dash._dashboardBgLastSig == nil or not dash:IsShown() then
        SettleDashboardBackgroundSnap(dash, target)
        return
    end

    local lastSig = dash._dashboardBgLastSig
    local hasFrom = lastSig ~= nil and lastSig ~= "horizon"
    local hasTo = target.kind ~= "clear"

    if not hasFrom and not hasTo then
        return
    end

    local activeIdx = dash._dashboardBgActiveLayer or 1
    local fromTex = (activeIdx == 1) and L1 or L2
    local toTex = (activeIdx == 1) and L2 or L1
    local newLayerIdx = (activeIdx == 1) and 2 or 1

    if not hasFrom and hasTo then
        if not ApplyDashboardBgToTexture(toTex, target) then
            SettleDashboardBackgroundSnap(dash, { kind = "clear", signature = "horizon" })
            return
        end
        toTex:SetVertexColor(1, 1, 1, 1)
        toTex:SetAlpha(0)
        toTex:Show()
        StartDashboardBgFade(dash, "in", nil, toTex, target, newLayerIdx)
        return
    end

    if hasFrom and not hasTo then
        StartDashboardBgFade(dash, "out", fromTex, nil, { kind = "clear", signature = "horizon" }, 1)
        return
    end

    if not ApplyDashboardBgToTexture(toTex, target) then
        SettleDashboardBackgroundSnap(dash, { kind = "clear", signature = "horizon" })
        return
    end
    toTex:SetVertexColor(1, 1, 1, 1)
    toTex:SetAlpha(0)
    toTex:Show()
    fromTex:SetAlpha(GetDashboardBgArtAlpha())
    StartDashboardBgFade(dash, "cross", fromTex, toTex, target, newLayerIdx)
end

-- Categories shown under the Axis hub (dashboard + search); keep in sync with OptionCategories keys.
local function OptionCategoryKeyIsAxis(catKey)
    return catKey == "Profiles" or catKey == "Modules" or catKey == "GlobalToggles"
end

-- Helper: Create Text
local function MakeText(parent, text, size, r, g, b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local font = size >= 14 and "Fonts\\FRIZQT__.TTF" or "Fonts\\ARIALN.TTF"
    local flags = size >= 14 and "OUTLINE" or ""
    fs:SetFont(font, size, flags)
    fs:SetText(text)
    fs:SetTextColor(r, g, b)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

-- Welcome contributor / localization bodies may include Hangul or CJK; ARIALN and FRIZQT omit those glyphs on many enUS installs (tofu squares). 2002 is Blizzard's broad-coverage UI font.
local function MakeDashboardWelcomeMixedScriptText(parent, text, size, r, g, b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    local ok = pcall(function()
        fs:SetFont("Fonts\\2002.TTF", size, "")
    end)
    if not ok then
        fs:SetFont("Fonts\\ARIALN.TTF", size, "")
    end
    fs:SetText(text)
    fs:SetTextColor(r, g, b)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

local f = _G.HorizonSuiteDashboard
addon.ShowDashboard = function()
    if SlashCmdList["HSDASH"] then SlashCmdList["HSDASH"]("") end
end
_G.HorizonSuite_ShowDashboard = addon.ShowDashboard

SLASH_HSDASH1 = "/hsd"
SLASH_HSDASH2 = "/dash"
SlashCmdList["HSDASH"] = function(msg)
    f = f or _G.HorizonSuiteDashboard
    if f and f:IsShown() then
        f:Hide()
    else
        if not f then
            f = CreateFrame("Frame", "HorizonSuiteDashboard", UIParent, "BackdropTemplate")
            f:SetSize(DASHBOARD_FRAME_W, DASHBOARD_FRAME_H)
            f:SetPoint("CENTER")
            f:SetFrameStrata("HIGH")
            f:SetToplevel(true)
            f:SetMovable(true)
            f:SetClampedToScreen(true)
            f:EnableMouse(true)
            f:Hide()

            -- Drag region: top bar to move the window (header area only; search box remains clickable)
            local dragBar = CreateFrame("Frame", nil, f)
            dragBar:SetPoint("TOPLEFT", 0, 0)
            dragBar:SetPoint("TOPRIGHT", 0, 0)
            dragBar:SetHeight(65)
            dragBar:SetFrameLevel(f:GetFrameLevel() + 1)
            dragBar:EnableMouse(true)
            dragBar:RegisterForDrag("LeftButton")
            local dashClickCount = 0
            local dashClickResetAt = 0
            local dashClickWasDrag = false
            local DASH_CLICK_RESET_SEC = 2
            dragBar:SetScript("OnDragStart", function()
                dashClickWasDrag = true
                if not InCombatLockdown() then f:StartMoving() end
            end)
            dragBar:SetScript("OnDragStop", function()
                f:StopMovingOrSizing()
            end)
            dragBar:SetScript("OnMouseUp", function(self, button)
                if button ~= "LeftButton" then return end
                if dashClickWasDrag then dashClickWasDrag = false return end
                dashClickWasDrag = false
                local now = GetTime()
                if now > dashClickResetAt then dashClickCount = 0 end
                dashClickCount = dashClickCount + 1
                dashClickResetAt = now + DASH_CLICK_RESET_SEC
                if dashClickCount >= 5 then
                    dashClickCount = 0
                    local v = not (addon.GetDB and addon.GetDB("focusDevMode", false))
                    if addon.SetDB then addon.SetDB("focusDevMode", v) end
                    if addon.HSPrint then addon.HSPrint("Dev mode (Blizzard tracker): " .. (v and "on" or "off")) end
                    ReloadUI()
                end
            end)

            if _G.OptionsWidgets_SetDef then
                _G.OptionsWidgets_SetDef({
                    FontPath = "Fonts\\FRIZQT__.TTF",
                    LabelSize = 13,
                    SectionSize = 11,
                })
            end

            local moduleLabels = {
                axis = BrandModule("axis") or "Axis",
                focus = BrandModule("focus"),
                presence = BrandModule("presence"),
                vista = BrandModule("vista"),
                insight = BrandModule("insight"),
                cache = BrandModule("cache"),
                essence = BrandModule("essence"),
                meridian = BrandModule("meridian"),
            }

            -- Preview-labelled modules (tiles, sidebar, welcome); keep in sync with OptionsData Modules toggles.
            local PREVIEW_MODULE_KEYS = { cache = true, essence = true }
            -- Coming-soon modules: planned but with no in-game content yet.
            local COMING_SOON_MODULE_KEYS = { meridian = true }

            -- Per-module label colours for Home tiles, matching PN_MODULE_COLORS hex values.
            -- Meridian omitted: no colour assigned yet, falls back to neutral gray.
            local TILE_MODULE_LABEL_COLORS = {
                axis     = { 224/255, 224/255, 224/255 },  -- E0E0E0
                focus    = { 255/255, 209/255,  51/255 },  -- FFD133
                presence = {  51/255, 255/255, 223/255 },  -- 33FFDF
                vista    = { 179/255, 102/255, 255/255 },  -- B366FF
                insight  = { 255/255, 102/255, 179/255 },  -- FF66B3
                cache    = {  51/255, 204/255, 102/255 },  -- 33CC66
                essence  = { 220/255,  20/255,  60/255 },  -- DC143C
            }

            local function ShouldShowModuleOnDashboard(mk)
                if mk == "axis" then return true end
                return addon.IsModuleEnabled and addon:IsModuleEnabled(mk)
            end

            local categoryIcons = {
                ["Axis"] = "INV_Misc_Wrench_01",
                ["Profiles"] = "INV_Misc_GroupNeedMore",
                ["Modules"] = "inv_10_engineering_purchasedparts_color2",
                ["GlobalToggles"] = "Trade_Engineering",
                ["Focus"] = "achievement_quests_completed_05",
                ["Presence"] = "vas_guildnamechange",
                ["Vista"] = "ability_hunter_pathfinding",
                ["Insight"] = "ui_profession_inscription",
                ["Cache"] = "INV_Misc_Coin_01",
                ["Essence"] = "achievement_character_human_male",
                ["Meridian"] = "ability_tracking",
                ["Typography"] = "INV_Misc_Book_09",
                ["Colors"] = "INV_Misc_Gem_Diamond_01",
                ["General"] = "INV_Misc_Question_01",
                ["Core"] = "INV_Misc_Wrench_01",
            }
            
            local function GetAccentColor()
                if addon.GetOptionsClassColor then
                    local cc = addon.GetOptionsClassColor()
                    if cc then return cc[1], cc[2], cc[3] end
                end
                return 0.2, 0.8, 0.9 -- Default sleek cyan
            end

            -- Track static accent elements for live class-colour refresh
            local dashAccentRefs = {
                sidebarBars = {},
                subcatAccents = {},
                cardAccents = {},
                cardDividers = {},
                dashboardAxisRails = {},
                patchNotesSectionLabels = {},
                patchNotesBullets = {},
                patchNotesRules = {},
                underline = nil,
                sidebarDivider = nil,
                logoSep = nil,
                logoText = nil,
                searchDropBorder = nil,
                welcomeAccentStrip = nil,
                pnFooterRule = nil,
                dashboardClassIcon = nil,
            }

            -- Set after sidebar header built; repositions logo separator + scroll under version/dev/class icon.
            local LayoutDashboardSidebarUnderHeader

            local function RefreshDashboardClassIcon()
                local tex = dashAccentRefs.dashboardClassIcon
                if not tex then return end
                if not (addon.GetOptionsClassColor and addon.GetOptionsClassColor()) then
                    tex:Hide()
                    return
                end
                local _, classFile = UnitClass("player")
                local src = (addon.GetDB and addon.GetDB("dashboardClassIconSource", "default")) or "default"
                local disp = addon.ResolveClassIconDisplay and addon.ResolveClassIconDisplay(classFile, src)
                if not disp then
                    tex:Hide()
                    return
                end
                tex:SetVertexColor(1, 1, 1, 1)
                if disp.kind == "atlas" then
                    tex:SetTexture(nil)
                    tex:SetAtlas(disp.atlas)
                elseif disp.kind == "file" then
                    tex:SetAtlas(nil)
                    tex:SetTexture(disp.path)
                else
                    tex:Hide()
                    return
                end
                tex:Show()
            end

            addon.ApplyDashboardClassColor = function()
                local ar, ag, ab = GetAccentColor()
                for _, bar in ipairs(dashAccentRefs.sidebarBars) do
                    if bar.SetColorTexture then bar:SetColorTexture(ar, ag, ab, 1) end
                end
                if dashAccentRefs.underline then
                    dashAccentRefs.underline:SetColorTexture(ar, ag, ab, 0.35)
                end
                for _, acc in ipairs(dashAccentRefs.subcatAccents) do
                    if acc.SetColorTexture then acc:SetColorTexture(ar, ag, ab, 1) end
                end
                for _, acc in ipairs(dashAccentRefs.cardAccents) do
                    if acc.SetColorTexture then acc:SetColorTexture(ar, ag, ab, 1) end
                end
                for _, div in ipairs(dashAccentRefs.cardDividers) do
                    if div.SetColorTexture then div:SetColorTexture(ar, ag, ab, 0.2) end
                end
                if activeSidebarBtn then
                    activeSidebarBtn.btnBg:SetColorTexture(ar * 0.15, ag * 0.15, ab * 0.15, DASHBOARD_CHILD_PANEL_ALPHA)
                    activeSidebarBtn.accentBar:SetColorTexture(ar, ag, ab, 1)
                end
                if dashAccentRefs.sidebarDivider then
                    dashAccentRefs.sidebarDivider:SetColorTexture(ar, ag, ab, 0.4)
                end
                if dashAccentRefs.logoSep then
                    dashAccentRefs.logoSep:SetColorTexture(ar, ag, ab, 0.3)
                end
                if dashAccentRefs.logoText then
                    dashAccentRefs.logoText:SetTextColor(ar, ag, ab)
                end
                if dashAccentRefs.searchDropBorder and dashAccentRefs.searchDropBorder.SetBackdropBorderColor then
                    dashAccentRefs.searchDropBorder:SetBackdropBorderColor(ar, ag, ab, 0.5)
                end
                if dashAccentRefs.welcomeAccentStrip and dashAccentRefs.welcomeAccentStrip.SetColorTexture then
                    dashAccentRefs.welcomeAccentStrip:SetColorTexture(ar, ag, ab, 0.5)
                end
                for _, lbl in ipairs(dashAccentRefs.patchNotesSectionLabels) do
                    if lbl and lbl.SetTextColor then lbl:SetTextColor(ar, ag, ab) end
                end
                for _, rule in ipairs(dashAccentRefs.patchNotesRules) do
                    if rule and rule.SetColorTexture then rule:SetColorTexture(ar, ag, ab, 0.35) end
                end
                if dashAccentRefs.pnFooterRule and dashAccentRefs.pnFooterRule.SetColorTexture then
                    dashAccentRefs.pnFooterRule:SetColorTexture(ar, ag, ab, 0.3)
                end
                local pnHex = string.format("%02X%02X%02X",
                    math.floor(ar*255+0.5), math.floor(ag*255+0.5), math.floor(ab*255+0.5))
                for _, entry in ipairs(dashAccentRefs.patchNotesBullets) do
                    if entry and entry.fs and entry.bullet then
                        entry.fs:SetText("|cFF"..pnHex.."\226\128\148|r  "..(entry.coloredBullet or entry.bullet))
                    end
                end
                for _, rail in ipairs(dashAccentRefs.dashboardAxisRails) do
                    if rail and rail.SetColorTexture then
                        local parent = rail:GetParent()
                        local hover = parent and parent.IsMouseOver and parent:IsMouseOver()
                        rail:SetColorTexture(ar, ag, ab, hover and 0.55 or 0.35)
                    end
                end
                if addon.DashboardPreview and addon.DashboardPreview.ApplyAccentColor then
                    addon.DashboardPreview.ApplyAccentColor(ar, ag, ab)
                end
                RefreshDashboardClassIcon()
                if LayoutDashboardSidebarUnderHeader then
                    LayoutDashboardSidebarUnderHeader()
                end
            end

            tinsert(UISpecialFrames, "HorizonSuiteDashboard")

            -- Background: solid base (always) + optional art layer(s) with crossfade between themes
            local bgSolid = f:CreateTexture(nil, "BACKGROUND", nil, -1)
            bgSolid:SetAllPoints()
            bgSolid:SetColorTexture(0.05, 0.05, 0.07, GetDashboardBgSolidAlpha(false))
            local bgArt1 = f:CreateTexture(nil, "BACKGROUND", nil, 0)
            local bgArt2 = f:CreateTexture(nil, "BACKGROUND", nil, 0)
            bgArt1:SetAllPoints()
            bgArt2:SetAllPoints()
            bgArt1:Hide()
            bgArt2:Hide()
            local bgFadeDriver = CreateFrame("Frame", nil, f)
            bgFadeDriver:SetSize(1, 1)
            bgFadeDriver:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
            f._dashboardBgSolid = bgSolid
            f._dashboardBgArt1 = bgArt1
            f._dashboardBgArt2 = bgArt2
            f._dashboardBgFadeDriver = bgFadeDriver
            f._dashboardBgActiveLayer = 1
            f._dashboardBgLastSig = nil
            f._dashboardBgFading = false
            if addon.ApplyDashboardBackground then
                addon.ApplyDashboardBackground()
            end

            f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
            f:SetScript("OnEvent", function(self, event)
                if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
                    if self:IsShown() and addon.ApplyDashboardBackground then
                        addon.ApplyDashboardBackground()
                    end
                end
            end)

            -- ===== SIDEBAR =====
            local SIDEBAR_WIDTH = 160
            local CONTENT_OFFSET = SIDEBAR_WIDTH + 10

            local sidebar = CreateFrame("Frame", nil, f)
            sidebar:SetPoint("TOPLEFT", 0, 0)
            sidebar:SetPoint("BOTTOMLEFT", 0, 0)
            sidebar:SetWidth(SIDEBAR_WIDTH)
            sidebar:SetFrameLevel(f:GetFrameLevel() + 2)

            local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
            sidebarBg:SetAllPoints()
            sidebarBg:SetColorTexture(0.02, 0.02, 0.02, DASHBOARD_CHILD_PANEL_ALPHA)

            -- Sidebar divider line
            local sidebarDivider = sidebar:CreateTexture(nil, "BORDER")
            sidebarDivider:SetWidth(1)
            sidebarDivider:SetPoint("TOPRIGHT", 0, 0)
            sidebarDivider:SetPoint("BOTTOMRIGHT", 0, 0)
            local ar, ag, ab = GetAccentColor()
            sidebarDivider:SetColorTexture(ar, ag, ab, 0.4)
            dashAccentRefs.sidebarDivider = sidebarDivider

            -- Sidebar Logo
            local sidebarLogoSub = MakeText(sidebar, "HORIZON SUITE", 16, ar, ag, ab, "CENTER")
            sidebarLogoSub:SetPoint("TOP", 0, -18)
            dashAccentRefs.logoText = sidebarLogoSub

            -- Version from TOC (addon version)
            local addonName = addon.ADDON_NAME or "HorizonSuite"
            local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
            local versionStr = addon.VERSION or (getMetadata and getMetadata(addonName, "Version")) or ""
            local sidebarVersion = MakeText(sidebar, versionStr ~= "" and ("v" .. versionStr) or "", 12, 0.55, 0.55, 0.65, "CENTER")
            sidebarVersion:SetPoint("TOP", sidebarLogoSub, "BOTTOM", 0, -4)

            -- Dev Mode indicator badge
            local devBadge = nil
            local isDevMode = addon.GetDB and addon.GetDB("focusDevMode", false)
            if isDevMode then
                devBadge = MakeText(sidebar, "[ DEV MODE ]", 10, 1, 0.65, 0.1, "CENTER")
                devBadge:SetPoint("TOP", sidebarVersion, "BOTTOM", 0, -2)
            end
            local lastSidebarHeader = devBadge or sidebarVersion

            local dashboardClassIcon = sidebar:CreateTexture(nil, "ARTWORK")
            dashboardClassIcon:SetSize(28, 28)
            dashboardClassIcon:SetPoint("TOP", lastSidebarHeader, "BOTTOM", 0, -6)
            dashboardClassIcon:Hide()
            dashAccentRefs.dashboardClassIcon = dashboardClassIcon

            -- Sidebar separator under logo / class icon (position from LayoutDashboardSidebarUnderHeader)
            local logoSep = sidebar:CreateTexture(nil, "ARTWORK")
            logoSep:SetHeight(1)
            logoSep:SetColorTexture(ar, ag, ab, 0.3)
            dashAccentRefs.logoSep = logoSep

            -- Sidebar scroll area for buttons
            local sidebarScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
            local sidebarScrollContent = CreateFrame("Frame", nil, sidebarScrollFrame)
            sidebarScrollContent:SetWidth(SIDEBAR_WIDTH - 1)
            sidebarScrollContent:SetHeight(1)
            sidebarScrollFrame:SetScrollChild(sidebarScrollContent)
            sidebarScrollFrame:EnableMouseWheel(true)
            sidebarScrollFrame:SetScript("OnMouseWheel", function(self, delta)
                local cur = self:GetVerticalScroll() or 0
                local maxS = math.max(0, sidebarScrollContent:GetHeight() - self:GetHeight())
                self:SetVerticalScroll(math.max(0, math.min(maxS, cur - delta * 30)))
            end)

            local TAB_ROW_HEIGHT = 38
            local SIDEBAR_WHATSNEW_RESERVE = TAB_ROW_HEIGHT + 8

            LayoutDashboardSidebarUnderHeader = function()
                logoSep:ClearAllPoints()
                local icon = dashAccentRefs.dashboardClassIcon
                local anchorBelow = (icon and icon:IsShown()) and icon or lastSidebarHeader
                logoSep:SetPoint("TOP", anchorBelow, "BOTTOM", 0, -8)
                logoSep:SetPoint("LEFT", sidebar, "LEFT", 15, 0)
                logoSep:SetPoint("RIGHT", sidebar, "RIGHT", -15, 0)
                sidebarScrollFrame:ClearAllPoints()
                sidebarScrollFrame:SetPoint("TOPLEFT", logoSep, "BOTTOMLEFT", 0, -10)
                sidebarScrollFrame:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -1, 10 + SIDEBAR_WHATSNEW_RESERVE)
            end

            RefreshDashboardClassIcon()
            LayoutDashboardSidebarUnderHeader()

            local sidebarButtons = {}
            local activeSidebarBtn = nil

            -- Sidebar group collapse (reuse OptionsPanel state for consistency)
            local groupCollapsed = (_G[addon.DB_NAME] and _G[addon.DB_NAME].optionsSidebarGroupCollapsed) or {}
            local function GetGroupCollapsed(mk) return groupCollapsed[mk] ~= false end
            local function SetGroupCollapsed(mk, v)
                groupCollapsed[mk] = v
                local db = _G[addon.DB_NAME]
                if db then db.optionsSidebarGroupCollapsed = groupCollapsed end
            end

            local function SetGroupChildrenShown(g, shown)
                if not g or not g.tabsContainer then return end
                for _, child in pairs({g.tabsContainer:GetChildren()}) do
                    child:SetShown(shown)
                end
            end

            -- Sidebar state controller: single source of truth for view, active selection, expanded groups.
            -- view: "dashboard" | "welcome" | "module" | "category"
            -- activeModuleKey: module key when in module/category view
            -- activeCategoryIndex: OptionCategories index when in category view
            local sidebarState = {
                view = "dashboard",
                activeModuleKey = nil,
                activeCategoryIndex = nil,
            }
            local CLEAR = {}  -- Sentinel for explicitly clearing a state field (nil cannot be passed)

            local SetSidebarState
            local RequestGroupToggle

            local HEADER_ROW_HEIGHT = 28
            local SIDEBAR_TOP_PAD = 4
            local COLLAPSE_ANIM_DUR = 0.18
            local easeOut = addon.easeOut or function(t) return 1 - (1-t)*(1-t) end

            local function CreateSidebarButton(parent, label, iconName, onClick, indentPx, noHover)
                indentPx = indentPx or 0
                parent = parent or sidebarScrollContent
                local btn = CreateFrame("Button", nil, parent)
                btn:SetSize(SIDEBAR_WIDTH - 1, TAB_ROW_HEIGHT)

                local btnBg = btn:CreateTexture(nil, "BACKGROUND")
                btnBg:SetAllPoints()
                btnBg:SetColorTexture(0, 0, 0, 0)
                btn.btnBg = btnBg

                local accentBar = btn:CreateTexture(nil, "ARTWORK")
                accentBar:SetSize(3, 22)
                accentBar:SetPoint("LEFT", 4 + indentPx, 0)
                local ar, ag, ab = GetAccentColor()
                accentBar:SetColorTexture(ar, ag, ab, 1)
                accentBar:Hide()
                btn.accentBar = accentBar
                tinsert(dashAccentRefs.sidebarBars, accentBar)

                if iconName then
                    local ic = btn:CreateTexture(nil, "ARTWORK")
                    ic:SetSize(16, 16)
                    ic:SetPoint("LEFT", indentPx + 14, 0)
                    ic:SetTexture("Interface\\Icons\\" .. iconName)
                    ic:SetVertexColor(0.6, 0.6, 0.65, 1)
                    btn.icon = ic
                end

                local lbl = MakeText(btn, label, 11, 0.65, 0.65, 0.7, "LEFT")
                lbl:SetPoint("LEFT", indentPx + (iconName and 36 or 14), 0)
                lbl:SetPoint("RIGHT", -8, 0)
                lbl:SetWordWrap(false)
                btn.label = lbl

                if not noHover then
                    btn:SetScript("OnEnter", function()
                        if btn ~= activeSidebarBtn then
                            btnBg:SetColorTexture(0.1, 0.1, 0.12, DASHBOARD_CHILD_PANEL_ALPHA)
                            lbl:SetTextColor(0.9, 0.9, 0.95)
                            if btn.icon then btn.icon:SetVertexColor(0.9, 0.9, 0.95, 1) end
                        end
                    end)
                    btn:SetScript("OnLeave", function()
                        if btn ~= activeSidebarBtn then
                            btnBg:SetColorTexture(0, 0, 0, 0)
                            lbl:SetTextColor(0.65, 0.65, 0.7)
                            if btn.icon then btn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                        end
                    end)
                end
                btn:SetScript("OnClick", function()
                    if onClick then onClick() end
                end)

                return btn
            end

            local function SetActiveSidebarButton(btn)
                -- Deactivate previous
                if activeSidebarBtn then
                    activeSidebarBtn.btnBg:SetColorTexture(0, 0, 0, 0)
                    activeSidebarBtn.label:SetTextColor(0.65, 0.65, 0.7)
                    if activeSidebarBtn.icon then activeSidebarBtn.icon:SetVertexColor(0.6, 0.6, 0.65, 1) end
                    activeSidebarBtn.accentBar:Hide()
                end
                -- Activate new
                activeSidebarBtn = btn
                if btn then
                    local ar, ag, ab = GetAccentColor()
                    btn.btnBg:SetColorTexture(ar * 0.15, ag * 0.15, ab * 0.15, DASHBOARD_CHILD_PANEL_ALPHA)
                    btn.label:SetTextColor(1, 1, 1)
                    if btn.icon then btn.icon:SetVertexColor(1, 1, 1, 1) end
                    btn.accentBar:Show()
                end
            end

            -- ===== END SIDEBAR =====
            
            -- Header
            local head = MakeText(f, "Horizon Suite", 24, 1, 1, 1, "CENTER")
            head:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_TITLE_Y)
            local headSub = MakeText(f, "Select a module to configure", 13, 0.5, 0.5, 0.5, "CENTER")
            headSub:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_HEAD_SUBTITLE_Y)

            -- Search Bar
            local searchBox = CreateFrame("EditBox", nil, f)
            searchBox:SetSize(500, DASH_SEARCH_BOX_H)
            searchBox:SetPoint("TOP", CONTENT_OFFSET / 2, DASH_SEARCH_Y)
            searchBox:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
            searchBox:SetTextInsets(48, 15, 0, 0)
            searchBox:SetAutoFocus(false)
            searchBox:SetFrameLevel(f:GetFrameLevel() + 5)
            
            local sbBorder = searchBox:CreateTexture(nil, "BACKGROUND")
            sbBorder:SetPoint("TOPLEFT", -1, 1)
            sbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
            sbBorder:SetColorTexture(0.18, 0.18, 0.22, 0.6)

            local sbBg = searchBox:CreateTexture(nil, "BORDER")
            sbBg:SetAllPoints()
            sbBg:SetColorTexture(0.10, 0.10, 0.13, DASHBOARD_CHILD_PANEL_ALPHA)
            
            local sbPlaceholder = MakeText(searchBox, "Search settings...", 14, 0.45, 0.45, 0.5, "LEFT")
            sbPlaceholder:SetPoint("LEFT", 48, 0)
            
            local sbIcon = searchBox:CreateTexture(nil, "ARTWORK")
            sbIcon:SetSize(20, 20)
            sbIcon:SetPoint("LEFT", 16, 0)
            sbIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
            sbIcon:SetVertexColor(0.45, 0.45, 0.5, 1)

            searchBox:SetScript("OnEditFocusGained", function(self)
                local ar, ag, ab = GetAccentColor()
                sbBorder:SetColorTexture(ar, ag, ab, 1)
                sbPlaceholder:Hide()
                sbIcon:SetVertexColor(0.8, 0.8, 0.8, 1)
            end)
            searchBox:SetScript("OnEditFocusLost", function(self)
                sbBorder:SetColorTexture(0.2, 0.2, 0.25, 1)
                if self:GetText() == "" then
                    sbPlaceholder:Show()
                    sbIcon:SetVertexColor(0.5, 0.5, 0.5, 1)
                end
            end)
            searchBox:SetScript("OnTextChanged", function(self)
                if self:GetText() == "" and not self:HasFocus() then
                     sbPlaceholder:Show()
                else
                     sbPlaceholder:Hide()
                end
                if f.OnSearchTextChanged then f.OnSearchTextChanged(self:GetText()) end
            end)
            searchBox:SetScript("OnEscapePressed", function(self) 
                self:ClearFocus() 
                self:SetText("")
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)

            -- Smooth Scroll Helper
            local function ApplySmoothScroll(scrollFrame, scrollContent, speed, addScrollbar)
                scrollFrame.targetScroll = nil
                scrollFrame.scrollSpeed = speed or 60
                
                local updateThumb
                if addScrollbar then
                    local track = CreateFrame("Frame", nil, scrollFrame)
                    track:SetWidth(4)
                    track:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 10, 0)
                    track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 10, 0)
                    
                    local thumb = track:CreateTexture(nil, "OVERLAY")
                    thumb:SetWidth(4)
                    thumb:SetColorTexture(1, 1, 1, 0.2)
                    
                    updateThumb = function()
                        local frameH = scrollFrame:GetHeight() or 1
                        if frameH == 0 then frameH = 1 end
                        local contentH = scrollContent:GetHeight() or 1
                        if contentH <= frameH then
                            thumb:Hide()
                            return
                        end
                        thumb:Show()
                        local scroll = scrollFrame:GetVerticalScroll() or 0
                        local maxScroll = math.max(1, contentH - frameH)
                        local thumbPct = frameH / contentH
                        local thumbH = math.max(20, frameH * thumbPct)
                        thumb:SetHeight(thumbH)
                        local trackH = (track:GetHeight() or frameH) - thumbH
                        local offset = (scroll / maxScroll) * trackH
                        thumb:ClearAllPoints()
                        thumb:SetPoint("TOP", track, "TOP", 0, -offset)
                    end
                    
                    if scrollFrame:GetScript("OnScrollRangeChanged") then
                        scrollFrame:HookScript("OnScrollRangeChanged", updateThumb)
                    else
                        scrollFrame:SetScript("OnScrollRangeChanged", updateThumb)
                    end
                    
                    if scrollFrame:GetScript("OnVerticalScroll") then
                        scrollFrame:HookScript("OnVerticalScroll", updateThumb)
                    else
                        scrollFrame:SetScript("OnVerticalScroll", updateThumb)
                    end
                end

                scrollFrame:EnableMouseWheel(true)
                scrollFrame:SetScript("OnMouseWheel", function(self, delta)
                    local cur = self.targetScroll or self:GetVerticalScroll() or 0
                    local childH = scrollContent:GetHeight() or 0
                    local frameH = self:GetHeight() or 0
                    local maxScroll = math.max(0, childH - frameH)
                    
                    local new = math.max(0, math.min(maxScroll, cur - delta * self.scrollSpeed))
                    self.targetScroll = new
                    
                    self:SetScript("OnUpdate", function(self, elapsed)
                        if not self.targetScroll then
                            self:SetScript("OnUpdate", nil)
                            return
                        end
                        local current = self:GetVerticalScroll() or 0
                        local diff = self.targetScroll - current
                        if math.abs(diff) < 0.5 then
                            self:SetVerticalScroll(self.targetScroll)
                            self.targetScroll = nil
                            self:SetScript("OnUpdate", nil)
                        else
                            -- Lerp towards target
                            self:SetVerticalScroll(current + diff * 25 * elapsed)
                        end
                        if updateThumb then updateThumb() end
                    end)
                end)
            end

            -- Search Dropdown UI
            local searchDropdown = CreateFrame("Frame", nil, f, "BackdropTemplate")
            searchDropdown:SetSize(600, 300)
            searchDropdown:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -5)
            searchDropdown:SetFrameLevel(f:GetFrameLevel() + 10)
            searchDropdown:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            searchDropdown:SetBackdropColor(0.08, 0.08, 0.09, DASHBOARD_CHILD_PANEL_ALPHA)
            local sdar, sdag, sdab = GetAccentColor()
            searchDropdown:SetBackdropBorderColor(sdar, sdag, sdab, 0.5)
            dashAccentRefs.searchDropBorder = searchDropdown
            searchDropdown:Hide()

            local searchDropdownScroll = CreateFrame("ScrollFrame", nil, searchDropdown)
            searchDropdownScroll:SetPoint("TOPLEFT", 6, -6)
            searchDropdownScroll:SetPoint("BOTTOMRIGHT", -6, 6)
            local searchDropdownContent = CreateFrame("Frame", nil, searchDropdownScroll)
            searchDropdownContent:SetSize(570, 1)
            searchDropdownScroll:SetScrollChild(searchDropdownContent)

            ApplySmoothScroll(searchDropdownScroll, searchDropdownContent, 30, true)
            local searchDropdownCatch = CreateFrame("Button", nil, f)
            searchDropdownCatch:SetAllPoints(f)
            searchDropdownCatch:SetFrameLevel(searchDropdown:GetFrameLevel() - 1)
            searchDropdownCatch:Hide()
            searchDropdownCatch:SetScript("OnClick", function()
                if f.HideSearchDropdown then f.HideSearchDropdown() end
            end)

            f.HideSearchDropdown = function()
                searchDropdown:Hide()
                searchDropdownCatch:Hide()
            end

            -- Views (offset right to accommodate sidebar)
            local viewWidth = DASHBOARD_FRAME_W - SIDEBAR_WIDTH - 10
            local viewCenterX = CONTENT_OFFSET / 2
            local contentWidth = viewWidth - 80  -- scroll frame uses 40px inset on each side
            local viewTopInset = (DASHBOARD_FRAME_H - DASHBOARD_VIEW_H) / 2
            -- Scroll tops sit just below the search box (same visual band as Home), in each view's local coords.
            local dashScrollTopOffset = -(math.abs(DASH_SEARCH_Y) + DASH_SEARCH_BOX_H + 8 - viewTopInset)
            local dashTitleX = CONTENT_OFFSET + 40

            local detailTitle = MakeText(f, "MODULE SETTINGS", 18, 1, 1, 1, "LEFT")
            detailTitle:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_TITLE_Y)
            detailTitle:Hide()
            f.detailTitle = detailTitle

            local detailTitleUnderline = f:CreateTexture(nil, "ARTWORK")
            detailTitleUnderline:SetHeight(1)
            detailTitleUnderline:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6)
            detailTitleUnderline:SetWidth(math.max(1, viewWidth - 80))
            local arU, agU, abU = GetAccentColor()
            detailTitleUnderline:SetColorTexture(arU, agU, abU, 0.35)
            detailTitleUnderline:Hide()
            dashAccentRefs.underline = detailTitleUnderline

            local dashboardView = CreateFrame("Frame", nil, f)
            dashboardView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            dashboardView:SetPoint("CENTER", viewCenterX, 0)
            f.dashboardView = dashboardView

            local detailView = CreateFrame("Frame", nil, f)
            detailView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            detailView:SetPoint("CENTER", viewCenterX, 0)
            detailView:Hide()
            f.detailView = detailView

            local subCategoryView = CreateFrame("Frame", nil, f)
            subCategoryView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            subCategoryView:SetPoint("CENTER", viewCenterX, 0)
            subCategoryView:Hide()
            f.subCategoryView = subCategoryView

            local welcomeView = CreateFrame("Frame", nil, f)
            welcomeView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            welcomeView:SetPoint("CENTER", viewCenterX, 0)
            welcomeView:Hide()
            f.welcomeView = welcomeView

            local patchNotesView = CreateFrame("Frame", nil, f)
            patchNotesView:SetSize(viewWidth, DASHBOARD_VIEW_H)
            patchNotesView:SetPoint("CENTER", viewCenterX, 0)
            patchNotesView:Hide()
            f.patchNotesView = patchNotesView

            local PN_FOOTER_H    = 44
            local PN_BODY_COL  = { 0.72, 0.72, 0.76, 1 }
            local PN_MUTED_COL = { 0.52, 0.56, 0.62, 1 }
            local PN_SECTION_GAP = 16
            local PN_BULLET_X    = 16
            local PN_LINE_GAP    = 5
            local PN_CHANGELOG_URL = "https://gitlab.com/Crystilac/horizon-suite/-/blob/main/CHANGELOG.md"

            local PN_MODULE_COLORS = {
                ["Essence"]  = "DC143C",
                ["Focus"]    = "FFD133",
                ["Cache"]    = "33CC66",
                ["Presence"] = "33FFDF",
                ["Flow"]     = "3399FF",
                ["Vista"]    = "B366FF",
                ["Insight"]  = "FF66B3",
                ["Axis"]     = "E0E0E0",
            }

            local function ColorModuleNames(text)
                for name, hex in pairs(PN_MODULE_COLORS) do
                    text = text:gsub("%f[%a](" .. name .. ")%f[%A]", "|cFF" .. hex .. "%1|r")
                end
                return text
            end

            -- Footer (fixed, outside scroll — mirrors welcome screen footer style)
            local pnFooter = CreateFrame("Frame", nil, patchNotesView)
            pnFooter:SetPoint("BOTTOMLEFT",  patchNotesView, "BOTTOMLEFT",   40, 0)
            pnFooter:SetPoint("BOTTOMRIGHT", patchNotesView, "BOTTOMRIGHT", -40, 0)
            pnFooter:SetHeight(PN_FOOTER_H)
            pnFooter:SetFrameLevel(patchNotesView:GetFrameLevel() + 10)

            local pnFooterTopRule = pnFooter:CreateTexture(nil, "ARTWORK")
            pnFooterTopRule:SetHeight(1)
            pnFooterTopRule:SetPoint("TOPLEFT",  pnFooter, "TOPLEFT",  0, 0)
            pnFooterTopRule:SetPoint("TOPRIGHT", pnFooter, "TOPRIGHT", 0, 0)
            local pnFar, pnFag, pnFab = GetAccentColor()
            pnFooterTopRule:SetColorTexture(pnFar, pnFag, pnFab, 0.3)
            dashAccentRefs.pnFooterRule = pnFooterTopRule

            local pnClBtn = CreateFrame("Button", nil, pnFooter)
            pnClBtn:SetPoint("BOTTOM", pnFooter, "BOTTOM", 0, 10)
            pnClBtn:SetSize(120, 20)

            local pnClTxt = pnClBtn:CreateFontString(nil, "OVERLAY")
            pnClTxt:SetFont("Fonts\\ARIALN.TTF", 12, "")
            pnClTxt:SetPoint("CENTER", pnClBtn, "CENTER", 0, 0)
            pnClTxt:SetText("Full changelog")
            pnClTxt:SetTextColor(unpack(PN_MUTED_COL))

            local pnClUnderline = pnClBtn:CreateTexture(nil, "OVERLAY")
            pnClUnderline:SetHeight(1)
            pnClUnderline:SetPoint("BOTTOM", pnClBtn, "BOTTOM", 0,  0)
            pnClUnderline:SetPoint("LEFT",   pnClBtn, "LEFT",   0,  0)
            pnClUnderline:SetPoint("RIGHT",  pnClBtn, "RIGHT",  0,  0)
            pnClUnderline:Hide()

            pnClBtn:SetScript("OnEnter", function()
                pnClTxt:SetTextColor(0.88, 0.90, 0.94)
                local r, g, b = GetAccentColor()
                pnClUnderline:SetColorTexture(r, g, b, 0.6)
                pnClUnderline:Show()
                if GameTooltip then
                    GameTooltip:SetOwner(pnClBtn, "ANCHOR_TOP")
                    GameTooltip:SetText(PN_CHANGELOG_URL, 1, 1, 1, 1, true)
                    GameTooltip:Show()
                end
            end)
            pnClBtn:SetScript("OnLeave", function()
                pnClTxt:SetTextColor(unpack(PN_MUTED_COL))
                pnClUnderline:Hide()
                if GameTooltip then GameTooltip:Hide() end
            end)
            pnClBtn:SetScript("OnClick", function()
                if GameTooltip then GameTooltip:Hide() end
                if addon.ShowURLCopyBox then addon.ShowURLCopyBox(PN_CHANGELOG_URL) end
            end)

            local pnScroll = CreateFrame("ScrollFrame", nil, patchNotesView, "UIPanelScrollFrameTemplate")
            pnScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
            pnScroll:SetPoint("BOTTOMRIGHT", -40, PN_FOOTER_H)
            pnScroll.ScrollBar:Hide()
            pnScroll.ScrollBar:ClearAllPoints()

            local pnContent = CreateFrame("Frame", nil, pnScroll)
            pnContent:SetSize(contentWidth, 1)
            pnScroll:SetScrollChild(pnContent)
            ApplySmoothScroll(pnScroll, pnContent, 60, true)

            local pnBuiltVersion = nil

            local function BuildPatchNotesContent(currentVersion)
                -- Orphan previous inner container so its regions don't render
                if pnContent._inner then pnContent._inner:SetParent(nil) end
                wipe(dashAccentRefs.patchNotesSectionLabels)
                wipe(dashAccentRefs.patchNotesBullets)
                wipe(dashAccentRefs.patchNotesRules)

                -- Inner container parented to pnContent (scroll child stays fixed)
                local cW = contentWidth
                local inner = CreateFrame("Frame", nil, pnContent)
                inner:SetWidth(cW)
                inner:SetHeight(1)
                inner:SetPoint("TOPLEFT", pnContent, "TOPLEFT", 0, 0)
                pnContent._inner = inner

                local items = {}
                local ar, ag, ab = GetAccentColor()
                local hex = string.format("%02X%02X%02X",
                    math.floor(ar*255+0.5), math.floor(ag*255+0.5), math.floor(ab*255+0.5))

                -- Collect all versions in the current major (e.g. 4.x.x) and sort descending
                local curMajor = tonumber(currentVersion:match("^(%d+)")) or 0
                local versions = {}
                if addon.PATCH_NOTES then
                    for v in pairs(addon.PATCH_NOTES) do
                        if (tonumber(v:match("^(%d+)")) or 0) == curMajor then
                            tinsert(versions, v)
                        end
                    end
                end
                table.sort(versions, function(a, b)
                    local a1,a2,a3 = a:match("^(%d+)%.(%d+)%.(%d+)$")
                    local b1,b2,b3 = b:match("^(%d+)%.(%d+)%.(%d+)$")
                    a1,a2,a3 = tonumber(a1) or 0, tonumber(a2) or 0, tonumber(a3) or 0
                    b1,b2,b3 = tonumber(b1) or 0, tonumber(b2) or 0, tonumber(b3) or 0
                    if a1 ~= b1 then return a1 > b1 end
                    if a2 ~= b2 then return a2 > b2 end
                    return a3 > b3
                end)

                if #versions == 0 then
                    local lbl = inner:CreateFontString(nil, "OVERLAY")
                    lbl:SetFont("Fonts\\ARIALN.TTF", 12, "")
                    lbl:SetWidth(cW)
                    lbl:SetJustifyH("CENTER")
                    lbl:SetText("No notes available.")
                    lbl:SetTextColor(unpack(PN_MUTED_COL))
                    tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 0 })
                else
                    for vi, ver in ipairs(versions) do
                        local notes = addon.PATCH_NOTES[ver]
                        if notes then
                            -- Subtle rule between versions
                            if vi > 1 then
                                tinsert(items, { type = "gap", h = 24 })
                                local sep = inner:CreateTexture(nil, "ARTWORK")
                                sep:SetSize(cW, 1)
                                sep:SetColorTexture(ar, ag, ab, 0.15)
                                tinsert(dashAccentRefs.patchNotesRules, sep)
                                tinsert(items, { type = "tex", tex = sep, gap = 18 })
                            end

                            -- Version header
                            local vHdr = inner:CreateFontString(nil, "OVERLAY")
                            vHdr:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
                            vHdr:SetJustifyH("LEFT")
                            vHdr:SetText("v" .. ver)
                            vHdr:SetTextColor(ar, ag, ab)
                            tinsert(dashAccentRefs.patchNotesSectionLabels, vHdr)
                            tinsert(items, { type = "fs", fs = vHdr, x = 0, gap = 14 })

                            -- Sections (no ruled divider — label + spacing carry the hierarchy)
                            for si, sec in ipairs(notes) do
                                if si > 1 then tinsert(items, { type = "gap", h = PN_SECTION_GAP }) end

                                local lbl = inner:CreateFontString(nil, "OVERLAY")
                                lbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
                                lbl:SetWidth(cW)
                                lbl:SetJustifyH("LEFT")
                                lbl:SetText(sec.section:upper())
                                lbl:SetTextColor(ar, ag, ab)
                                tinsert(dashAccentRefs.patchNotesSectionLabels, lbl)
                                tinsert(items, { type = "fs", fs = lbl, x = 0, gap = 9 })

                                for _, bullet in ipairs(sec.bullets) do
                                    local txt = inner:CreateFontString(nil, "OVERLAY")
                                    txt:SetFont("Fonts\\ARIALN.TTF", 12, "")
                                    txt:SetWidth(cW - PN_BULLET_X)
                                    txt:SetJustifyH("LEFT")
                                    txt:SetWordWrap(true)
                                    local coloredBullet = ColorModuleNames(bullet)
                                    txt:SetText("|cFF"..hex.."\226\128\148|r  "..coloredBullet)
                                    txt:SetTextColor(unpack(PN_BODY_COL))
                                    tinsert(dashAccentRefs.patchNotesBullets, { fs = txt, bullet = bullet, coloredBullet = coloredBullet })
                                    tinsert(items, { type = "fs", fs = txt, x = PN_BULLET_X, gap = PN_LINE_GAP })
                                end
                            end
                        end
                    end
                end

                C_Timer.After(0, function()
                    if not (patchNotesView and patchNotesView:IsShown()) then return end
                    local y = 0
                    for _, item in ipairs(items) do
                        if item.type == "fs" then
                            item.fs:ClearAllPoints()
                            item.fs:SetPoint("TOPLEFT", inner, "TOPLEFT", item.x, y)
                            y = y - math.max(item.fs:GetStringHeight(), 13) - item.gap
                        elseif item.type == "tex" then
                            item.tex:ClearAllPoints()
                            item.tex:SetPoint("TOPLEFT", inner, "TOPLEFT", 0, y)
                            y = y - 1 - item.gap
                        elseif item.type == "gap" then
                            y = y - item.h
                        end
                    end
                    local totalH = math.max(1, -y)
                    inner:SetHeight(totalH)
                    pnContent:SetHeight(totalH)
                    pnScroll:SetVerticalScroll(0)
                end)

                pnBuiltVersion = currentVersion
            end

            local subCategoryScroll = CreateFrame("ScrollFrame", nil, subCategoryView, "UIPanelScrollFrameTemplate")
            subCategoryScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
            subCategoryScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            subCategoryScroll.ScrollBar:Hide()
            subCategoryScroll.ScrollBar:ClearAllPoints()

            local subCategoryContent = CreateFrame("Frame", nil, subCategoryScroll)
            subCategoryContent:SetSize(contentWidth, 1)
            subCategoryScroll:SetScrollChild(subCategoryContent)

            ApplySmoothScroll(subCategoryScroll, subCategoryContent, 60, true)

            -- Back Button (Persistent in Detail View) — parent is main frame so Y matches headSub row across views
            local backBtn = CreateFrame("Button", nil, f)
            backBtn:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_SUBTITLE_Y)
            backBtn:SetFrameLevel(f:GetFrameLevel() + 6)
            backBtn:Hide()

            -- Back Button (Subcategory View)
            local subBackBtn = CreateFrame("Button", nil, f)
            subBackBtn:SetPoint("TOPLEFT", f, "TOPLEFT", dashTitleX, DASH_HEAD_SUBTITLE_Y)
            subBackBtn:SetFrameLevel(f:GetFrameLevel() + 6)
            subBackBtn:Hide()
            
            local function StyleBackButton(btn, textStr)
                btn:SetSize(160, 32)
                
                local icon = btn:CreateTexture(nil, "ARTWORK")
                icon:SetSize(14, 14)
                icon:SetPoint("LEFT", 0, 0)
                icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
                icon:SetDesaturated(true)
                icon:SetVertexColor(0.5, 0.5, 0.55)

                local txt = MakeText(btn, textStr, 12, 0.5, 0.5, 0.55, "LEFT")
                txt:SetPoint("LEFT", icon, "RIGHT", 6, 0)

                -- Underline (hidden by default)
                local underline = btn:CreateTexture(nil, "ARTWORK")
                underline:SetHeight(1)
                underline:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -2)
                underline:SetPoint("RIGHT", txt, "RIGHT", 0, 0)
                underline:SetColorTexture(1, 1, 1, 0)
                
                btn:SetScript("OnEnter", function() 
                    local ar, ag, ab = GetAccentColor()
                    txt:SetTextColor(1, 1, 1)
                    icon:SetDesaturated(false)
                    icon:SetVertexColor(ar, ag, ab)
                    underline:SetColorTexture(ar, ag, ab, 0.5)
                end)
                btn:SetScript("OnLeave", function() 
                    txt:SetTextColor(0.5, 0.5, 0.55)
                    icon:SetDesaturated(true)
                    icon:SetVertexColor(0.5, 0.5, 0.55)
                    underline:SetColorTexture(1, 1, 1, 0)
                end)
            end

            StyleBackButton(backBtn, "BACK")
            StyleBackButton(subBackBtn, "BACK")

            local function HideContextHeader()
                backBtn:Hide()
                subBackBtn:Hide()
                detailTitle:Hide()
                detailTitleUnderline:Hide()
            end

            local function ShowDetailHeader()
                backBtn:Show()
                subBackBtn:Hide()
                detailTitle:Show()
                detailTitleUnderline:Show()
            end

            local function ShowSubcategoryHeader()
                subBackBtn:Show()
                backBtn:Hide()
                detailTitle:Show()
                detailTitleUnderline:Show()
            end

            -- Transitions (faster animations per UX feedback)
            local function CrossfadeTo(targetView)
                dashboardView:Hide()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                patchNotesView:Hide()
                if head then head:Hide() end
                if headSub then headSub:Hide() end
                HideContextHeader()

                targetView:SetAlpha(0)
                targetView:Show()
                UIFrameFadeIn(targetView, 0.2, 0, 1)
            end

            f.ShowDashboard = function()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                welcomeView:Hide()
                patchNotesView:Hide()
                dashboardView:SetAlpha(0)
                dashboardView:Show()
                UIFrameFadeIn(dashboardView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText("Select a module to configure")
                end
                searchBox:Show()
                f.currentModuleKey = nil
                SetSidebarState({ view = "dashboard", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardBackground then addon.ApplyDashboardBackground() end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end

            -- Back button in detail view: reopen module groups, but keep core tiles behaving like dashboard entries.
            backBtn:SetScript("OnClick", function()
                if f.currentModuleKey then
                    local mk = f.currentModuleKey
                    local cats = {}
                    for _, cat in ipairs(addon.OptionCategories) do
                        local catMk
                        if OptionCategoryKeyIsAxis(cat.key) then
                            catMk = "axis"
                        else
                            catMk = cat.moduleKey or "modules"
                        end
                        if catMk == mk and cat.options then
                            tinsert(cats, cat)
                        end
                    end
                    if mk ~= "modules" and #cats > 1 then
                        local modName = moduleLabels[mk] or mk
                        f.OpenModule(modName, mk)
                    else
                        f.ShowDashboard()
                    end
                else
                    f.ShowDashboard()
                end
            end)

            subBackBtn:SetScript("OnClick", function() f.ShowDashboard() end)

            local closeBtn = CreateFrame("Button", nil, f)
            closeBtn:SetSize(28, 28)
            closeBtn:SetPoint("TOPRIGHT", -15, -15)
            closeBtn:SetFrameLevel(f:GetFrameLevel() + 10)

            local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
            closeBg:SetAllPoints()
            closeBg:SetColorTexture(1, 0.3, 0.3, 0)
            
            local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
            closeTxt:SetFont(addon.GetDefaultFontPath and addon.GetDefaultFontPath() or "Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
            closeTxt:SetPoint("CENTER", 0, 0)
            closeTxt:SetText("\195\151")
            closeTxt:SetTextColor(0.5, 0.5, 0.55)
            
            closeBtn:SetScript("OnEnter", function()
                closeTxt:SetTextColor(1, 1, 1)
                closeBg:SetColorTexture(1, 0.3, 0.3, 0.25)
            end)
            closeBtn:SetScript("OnLeave", function()
                closeTxt:SetTextColor(0.5, 0.5, 0.55)
                closeBg:SetColorTexture(1, 0.3, 0.3, 0)
            end)
            closeBtn:SetScript("OnClick", function() f:Hide() end)

            -- Key Handling (Escape to Close)
            f:SetPropagateKeyboardInput(true)
            f:SetScript("OnKeyDown", function(self, key)
                if key == "ESCAPE" then
                    self:SetPropagateKeyboardInput(false)
                    self:Hide()
                else
                    self:SetPropagateKeyboardInput(true)
                end
            end)

            -- Detail Card Container (Scrollable)
            local detailScroll = CreateFrame("ScrollFrame", nil, detailView, "UIPanelScrollFrameTemplate")
            detailScroll:SetPoint("TOPLEFT", 40, dashScrollTopOffset)
            detailScroll:SetPoint("BOTTOMRIGHT", -40, 40)
            detailScroll.ScrollBar:Hide()
            detailScroll.ScrollBar:ClearAllPoints()

            local detailContent = CreateFrame("Frame", nil, detailScroll)
            detailContent:SetSize(contentWidth, 1)
            detailScroll:SetScrollChild(detailContent)

            ApplySmoothScroll(detailScroll, detailContent, 60, true)
            local currentDetailCards = {}

            local function ClearDetailCards()
                for _, card in ipairs(currentDetailCards) do
                    if card.anim and card.anim:IsPlaying() then card.anim:Stop() end
                    if card.relayoutAnimFrame then card.relayoutAnimFrame:SetScript("OnUpdate", nil) end
                    card.relayoutAnim = nil
                    card:Hide()
                end
                wipe(currentDetailCards)
                wipe(dashAccentRefs.cardAccents)
                wipe(dashAccentRefs.cardDividers)
            end

            -- Helper: Update Detail Layout
            local function UpdateDetailLayout()
                local yOffset = 0
                for _, card in ipairs(currentDetailCards) do
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", 0, -yOffset)
                    card:SetPoint("RIGHT", detailContent, "RIGHT", 0, 0)
                    yOffset = yOffset + card:GetHeight() + 15
                end
                
                local newHeight = math.max(1, yOffset)
                detailContent:SetHeight(newHeight)
                
                if detailScroll then
                    local frameH = detailScroll:GetHeight() or 1
                    local maxScroll = math.max(0, newHeight - frameH)
                    local curScroll = detailScroll.targetScroll or detailScroll:GetVerticalScroll() or 0
                    if curScroll > maxScroll then
                        -- Instantly adjust the content so it stays attached to bottom edge instead of popping
                        detailScroll.targetScroll = maxScroll
                        if not detailScroll:GetScript("OnUpdate") then
                            detailScroll:SetVerticalScroll(maxScroll)
                            detailScroll.targetScroll = nil
                        end
                    end
                end
            end

            local function NavigateToOption(entry)
                if not entry then return end
                -- Find the target category
                local targetCat = false
                for _, cat in ipairs(addon.OptionCategories) do
                    if cat.key == entry.categoryKey then
                        targetCat = cat
                        break
                    end
                end

                if targetCat then
                    -- Get the effective moduleKey (Profiles/Modules map to "axis")
                    local effectiveMk = targetCat.moduleKey
                    if OptionCategoryKeyIsAxis(targetCat.key) then
                        effectiveMk = "axis"
                    end
                    local modName = effectiveMk and moduleLabels[effectiveMk] or targetCat.name

                    -- Build subcategory tiles (for back button) but skip detail card creation since OpenCategoryDetail handles it
                    f.OpenModule(modName, effectiveMk, true)

                    local options = type(targetCat.options) == "function" and targetCat.options() or targetCat.options
                    f.OpenCategoryDetail(modName, entry.categoryName, options)

                    -- Find and expand the relevant accordion card
                    C_Timer.After(0.1, function()
                        for _, card in ipairs(currentDetailCards) do
                            if card.optionIds and card.optionIds[entry.optionId] then
                                if not card.expanded then
                                    card.expanded = true
                                    card.anim:Play()
                                end
                                
                                -- Scroll to the card
                                local _, _, _, _, yOffset = card:GetPoint()
                                local frameH = detailScroll:GetHeight() or 0
                                local maxScroll = math.max(0, detailContent:GetHeight() - frameH)
                                local targetScroll = math.max(0, math.min(maxScroll, math.abs(yOffset or 0) - 20))
                                detailScroll:SetVerticalScroll(targetScroll)
                                break
                            end
                        end
                    end)
                end
            end

            --- Open Axis → Modules detail with the Module Toggles accordion expanded (same as Welcome “Open module toggles” link).
            --- @return nil
            local function NavigateToModuleToggles()
                local togglesSection = L["OPTIONS_AXIS_MODULE_TOGGLES"] or "Module Toggles"
                local modulesName = L["OPTIONS_AXIS_MODULES"] or "Modules"
                local entryFound
                local idx = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
                for _, e in ipairs(idx) do
                    if e.categoryKey == "Modules" and e.sectionName == togglesSection then
                        entryFound = e
                        break
                    end
                end
                if not entryFound then
                    entryFound = {
                        categoryKey = "Modules",
                        categoryName = modulesName,
                        optionId = "_module_focus",
                    }
                end
                NavigateToOption(entryFound)
            end

            local searchDropdownButtons = {}
            local SEARCH_DROPDOWN_ROW_HEIGHT = 38

            local function ShowSearchResults(matches)
                if not matches or #matches == 0 then
                    f.HideSearchDropdown()
                    return
                end
                
                local num = math.min(#matches, 12)
                for i = 1, num do
                    if not searchDropdownButtons[i] then
                        local b = CreateFrame("Button", nil, searchDropdownContent)
                        b:SetHeight(SEARCH_DROPDOWN_ROW_HEIGHT)
                        b:SetPoint("LEFT", searchDropdownContent, "LEFT", 0, 0)
                        b:SetPoint("RIGHT", searchDropdownContent, "RIGHT", 0, 0)
                        
                        b.subLabel = MakeText(b, "", 10, 0.58, 0.64, 0.74, "LEFT")
                        b.subLabel:SetPoint("TOPLEFT", b, "TOPLEFT", 8, -4)
                        
                        b.label = MakeText(b, "", 12, 0.9, 0.9, 0.9, "LEFT")
                        b.label:SetPoint("TOPLEFT", b.subLabel, "BOTTOMLEFT", 0, -1)
                        
                        local hi = b:CreateTexture(nil, "BACKGROUND")
                        hi:SetAllPoints(b)
                        hi:SetColorTexture(1, 1, 1, 0.08)
                        hi:Hide()

                        b:SetScript("OnEnter", function()
                            local har, hag, hab = GetAccentColor()
                            hi:SetColorTexture(har, hag, hab, 0.08)
                            hi:Show()
                            b.label:SetTextColor(1, 1, 1)
                        end)
                        b:SetScript("OnLeave", function()
                            hi:Hide()
                            b.label:SetTextColor(0.9, 0.9, 0.9)
                        end)
                        searchDropdownButtons[i] = { btn = b, hi = hi }
                    end
                    
                    local row = searchDropdownButtons[i]
                    local m = matches[i]
                    local breadcrumb
                    if m.moduleLabel and m.moduleLabel ~= "" and m.moduleLabel ~= (m.categoryName or "") then
                        breadcrumb = (m.moduleLabel or "") .. " > " .. (m.categoryName or "") .. " > " .. (m.sectionName or "")
                    else
                        breadcrumb = (m.categoryName or "") .. " > " .. (m.sectionName or "")
                    end
                    
                    local rawName = m.option and (type(m.option.name) == "function" and m.option.name() or m.option.name) or nil
                    local optionName = tostring(rawName or "")
                    
                    row.btn.subLabel:SetText(breadcrumb or "")
                    row.btn.label:SetText(optionName)
                    row.btn.entry = m
                    row.btn:SetPoint("TOP", searchDropdownContent, "TOP", 0, -(i - 1) * SEARCH_DROPDOWN_ROW_HEIGHT)
                    row.btn:SetScript("OnClick", function()
                        NavigateToOption(row.btn.entry)
                        f.HideSearchDropdown()
                        if searchBox then searchBox:ClearFocus() end
                    end)
                    row.btn:Show()
                end
                
                for i = num + 1, #searchDropdownButtons do
                    if searchDropdownButtons[i] then searchDropdownButtons[i].btn:Hide() end
                end
                
                searchDropdownContent:SetHeight(num * SEARCH_DROPDOWN_ROW_HEIGHT)
                searchDropdownScroll:SetVerticalScroll(0)
                searchDropdown:Show()
                searchDropdownCatch:Show()
            end

            local searchDebounceTimer
            f.OnSearchTextChanged = function(text)
                if searchDebounceTimer and searchDebounceTimer.Cancel then
                    searchDebounceTimer:Cancel()
                end
                searchDebounceTimer = nil
                
                local delay = 0.2
                if C_Timer and C_Timer.NewTimer then
                    searchDebounceTimer = C_Timer.NewTimer(delay, function()
                        searchDebounceTimer = nil
                        f.FilterBySearch(text)
                    end)
                elseif C_Timer and C_Timer.After then
                    C_Timer.After(delay, function() f.FilterBySearch(text) end)
                else
                    f.FilterBySearch(text)
                end
            end

            f.FilterBySearch = function(query)
                local searchQuery = query and query:trim():lower() or ""
                if searchQuery == "" or #searchQuery < 2 then
                    f.HideSearchDropdown()
                    return
                end
                
                local index = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
                local matches = {}
                for _, entry in ipairs(index) do
                    if entry.searchText and entry.searchText:find(searchQuery, 1, true) then
                        matches[#matches + 1] = entry
                    end
                end
                ShowSearchResults(matches)
            end

            local currentSubTiles = {}

            local function ClearSubTiles()
                for _, tile in ipairs(currentSubTiles) do
                    tile:Hide()
                end
                wipe(currentSubTiles)
                wipe(dashAccentRefs.subcatAccents)
            end

            -- Match options section-card transparency (OptionsWidgets SectionCardBg / SectionCardBorder)
            local WDef = addon.OptionsWidgetsDef
            local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
            local SBd = (WDef and WDef.SectionCardBorder) or { 0.18, 0.2, 0.24, 0.35 }
            local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
            -- Hover / expanded fills: shared by module tiles, subcategory tiles, and detail accordions
            local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13
            local SBgExpandedR, SBgExpandedG, SBgExpandedB = 0.10, 0.10, 0.12

            -- Helper: Create Subcategory Tile
            local TILE_PAD = 10
            local TILE_GAP = 10
            local TILE_W = math.floor((contentWidth - TILE_PAD * 2 - TILE_GAP) / 2)
            local TILE_STRIDE = TILE_W + TILE_GAP

            local function CreateSubCategoryTile(parent, name, index, options, modName, desc)
                local tile = CreateFrame("Button", nil, parent)
                tile:SetSize(TILE_W, 110)
                
                local row = math.floor((index-1) / 2)
                local col = (index-1) % 2
                tile:SetPoint("TOPLEFT", parent, "TOPLEFT", TILE_PAD + (col * TILE_STRIDE), 0 + (row * -130))

                -- Background
                local tBg = tile:CreateTexture(nil, "BACKGROUND")
                tBg:SetPoint("TOPLEFT", 1, -1)
                tBg:SetPoint("BOTTOMRIGHT", -1, 1)
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                -- Border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(SBd[1], SBd[2], SBd[3], SBd[4])

                -- Top accent highlight (hidden by default)
                local topAccent = tile:CreateTexture(nil, "ARTWORK")
                topAccent:SetHeight(2)
                topAccent:SetPoint("TOPLEFT", 1, -1)
                topAccent:SetPoint("TOPRIGHT", -1, -1)
                topAccent:SetColorTexture(1, 1, 1, 0)

                -- Accent
                local accent = tile:CreateTexture(nil, "ARTWORK")
                accent:SetSize(4, 60)
                accent:SetPoint("LEFT", 0, 0)
                local ar, ag, ab = GetAccentColor()
                accent:SetColorTexture(ar, ag, ab, 1)
                accent:Hide()
                tinsert(dashAccentRefs.subcatAccents, accent)

                -- Label
                local lbl = MakeText(tile, name, 18, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 28, -22)
                
                -- Collect subset of option names for description
                local descStr = desc or ("Configure and customize settings related to " .. name:lower() .. ".")

                -- Description Text
                local descLbl = MakeText(tile, descStr, 12, 0.55, 0.6, 0.65, "LEFT")
                descLbl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -6)
                descLbl:SetPoint("RIGHT", tile, "RIGHT", -22, 0)
                descLbl:SetWordWrap(true)
                descLbl:SetHeight(40)
                descLbl:SetJustifyV("TOP")

                tile:SetScript("OnEnter", function()
                    -- Keep fill = collapsed accordion idle (no header-hover tint)
                    local ar, ag, ab = GetAccentColor()
                    border:SetColorTexture(ar, ag, ab, 0.6)
                    lbl:SetTextColor(1, 1, 1)
                    descLbl:SetTextColor(0.75, 0.8, 0.85)
                    accent:SetColorTexture(ar, ag, ab, 1)
                    accent:Show()
                    topAccent:SetColorTexture(ar, ag, ab, 0.3)
                end)
                tile:SetScript("OnLeave", function()
                    border:SetColorTexture(SBd[1], SBd[2], SBd[3], SBd[4])
                    lbl:SetTextColor(0.9, 0.9, 0.95)
                    descLbl:SetTextColor(0.55, 0.6, 0.65)
                    accent:Hide()
                    topAccent:SetColorTexture(1, 1, 1, 0)
                end)
                tile:SetScript("OnClick", function()
                    f.OpenCategoryDetail(modName, name, options)
                end)

                return tile
            end

            f.OpenCategoryDetail = function(modName, catName, options)
                if searchBox then searchBox:ClearFocus() end

                local matchedModuleKey = f.currentModuleKey or "modules"
                local matchedCatIdx = nil
                for i, cat in ipairs(addon.OptionCategories) do
                    local catMk
                    if OptionCategoryKeyIsAxis(cat.key) then
                        catMk = "axis"
                    else
                        catMk = cat.moduleKey or "modules"
                    end
                    if cat.name == catName and (not f.currentModuleKey or catMk == f.currentModuleKey) then
                        matchedModuleKey = catMk
                        matchedCatIdx = i
                        break
                    end
                end
                f.currentModuleKey = matchedModuleKey
                SetSidebarState({ view = "category", activeModuleKey = matchedModuleKey, activeCategoryIndex = matchedCatIdx })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(matchedModuleKey)
                end

                ClearDetailCards()
                CrossfadeTo(detailView)
                ShowDetailHeader()
                detailContent:Show()
                detailScroll:SetVerticalScroll(0)

                if f.detailTitle then 
                    f.detailTitle:SetText(modName:upper() .. "  >  " .. catName:upper())
                end

                f.BuildAccordionDetail(catName, options)

                -- Cascade effect (faster per UX feedback)
                for i, card in ipairs(currentDetailCards) do
                    card:SetAlpha(0)
                    local _, _, _, xVal, yVal = card:GetPoint()
                    if yVal then
                        card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                        if C_Timer and C_Timer.After then
                            C_Timer.After(i * 0.05, function()
                                if card:IsShown() then
                                    card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                    UIFrameFadeIn(card, 0.2, 0, 1)
                                end
                            end)
                        else
                            card:SetAlpha(1)
                        end
                    end
                end
            end

            f.OpenModule = function(name, moduleKey, skipDetailBuild)
                if searchBox then searchBox:ClearFocus() end

                local mk = moduleKey or "modules"
                f.currentModuleKey = mk
                SetSidebarState({ view = "module", activeModuleKey = mk, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(mk)
                end

                -- Find all matching sub-categories
                local cats = {}
                for _, cat in ipairs(addon.OptionCategories) do
                    local match = false
                    if moduleKey == "axis" then
                        match = OptionCategoryKeyIsAxis(cat.key)
                    elseif moduleKey and cat.moduleKey == moduleKey then
                        match = true
                    elseif not moduleKey and cat.name == name then
                        match = true
                    end
                    if match and cat.options then
                        tinsert(cats, cat)
                    end
                end

                    if #cats > 1 then
                    -- Show SubCategory View
                    ClearSubTiles()
                    CrossfadeTo(subCategoryView)
                    ShowSubcategoryHeader()
                    subCategoryScroll:SetVerticalScroll(0)

                    local modName = moduleKey and moduleLabels[moduleKey] or name

                    if f.detailTitle then
                        f.detailTitle:SetText(modName:upper() .. " CATEGORIES")
                    end

                local tileYOffset = 0
                    for i, cat in ipairs(cats) do
                        local options = type(cat.options) == "function" and cat.options() or cat.options
                        local tile = CreateSubCategoryTile(subCategoryContent, cat.name, i, options, modName, cat.desc)
                        tinsert(currentSubTiles, tile)
                        
                        local row = math.floor((i-1) / 2)
                        tileYOffset = math.max(tileYOffset, (row + 1) * 130)

                        -- Staggered Cascade Entrance (faster per UX feedback)
                        tile:SetAlpha(0)
                        local _, _, _, xVal, yVal = tile:GetPoint()
                        if xVal and yVal then
                            tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal - 20)
                            if C_Timer and C_Timer.After then
                                C_Timer.After(i * 0.05, function()
                                    if tile:IsShown() then
                                        tile:SetPoint("TOPLEFT", subCategoryContent, "TOPLEFT", xVal, yVal)
                                        UIFrameFadeIn(tile, 0.2, 0, 1)
                                    end
                                end)
                            else
                                tile:SetAlpha(1)
                            end
                        end
                    end
                    subCategoryContent:SetHeight(math.max(1, tileYOffset))
                elseif not skipDetailBuild then
                    -- Only 1 category (or none), go straight to details
                    ClearDetailCards()
                    CrossfadeTo(detailView)
                    ShowDetailHeader()
                    detailContent:Show()
                    detailScroll:SetVerticalScroll(0)

                    if f.detailTitle then 
                        local titleText = name:upper()
                        if moduleKey and moduleLabels[moduleKey] then
                            local modName = moduleLabels[moduleKey]
                            if modName:upper() ~= name:upper() then
                                titleText = modName:upper() .. "  >  " .. name:upper()
                            end
                        end
                        f.detailTitle:SetText(titleText) 
                    end

                    if cats[1] then
                        local options = type(cats[1].options) == "function" and cats[1].options() or cats[1].options
                        f.BuildAccordionDetail(cats[1].name, options)

                        -- Cascade effect (faster per UX feedback)
                        for i, card in ipairs(currentDetailCards) do
                            card:SetAlpha(0)
                            local _, _, _, xVal, yVal = card:GetPoint()
                            if yVal then
                                card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal - 20)
                                if C_Timer and C_Timer.After then
                                    C_Timer.After(i * 0.05, function()
                                        if card:IsShown() then
                                            card:SetPoint("TOPLEFT", detailContent, "TOPLEFT", xVal or 0, yVal)
                                            UIFrameFadeIn(card, 0.2, 0, 1)
                                        end
                                    end)
                                else
                                    card:SetAlpha(1)
                                end
                            end
                        end
                    end
                end
            end

            local function CreateAccordionCard(parent, title)
                local card = CreateFrame("Frame", nil, parent)
                card:SetHeight(60)
                card:SetPoint("LEFT", parent, "LEFT", 0, 0)
                card:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
                card.expanded = false
                card.collapsedHeight = 60
                card:SetClipsChildren(true)

                -- Background (same alpha as options section cards)
                local cBg = card:CreateTexture(nil, "BACKGROUND")
                cBg:SetAllPoints()
                cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                -- Bottom divider
                local divider = card:CreateTexture(nil, "ARTWORK")
                divider:SetHeight(1)
                divider:SetPoint("BOTTOMLEFT", 20, 0)
                divider:SetPoint("BOTTOMRIGHT", -20, 0)
                local cdr, cdg, cdb = GetAccentColor()
                divider:SetColorTexture(cdr, cdg, cdb, 0.2)
                tinsert(dashAccentRefs.cardDividers, divider)

                -- Accent
                local accent = card:CreateTexture(nil, "ARTWORK")
                accent:SetSize(3, 24)
                accent:SetPoint("TOPLEFT", 20, -18)
                local cr, cg, cb = GetAccentColor()
                accent:SetColorTexture(cr, cg, cb, 1)
                tinsert(dashAccentRefs.cardAccents, accent)

                -- Chevron indicator
                local chevron = MakeText(card, "+", 14, 0.5, 0.5, 0.55, "RIGHT")
                chevron:SetPoint("TOPRIGHT", -25, -23)

                -- Title
                local lbl = MakeText(card, title:upper(), 15, 0.9, 0.9, 0.95, "LEFT")
                lbl:SetPoint("TOPLEFT", 35, -22)

                local headerBtn = CreateFrame("Button", nil, card)
                headerBtn:SetPoint("TOPLEFT", 0, 0)
                headerBtn:SetPoint("TOPRIGHT", 0, 0)
                headerBtn:SetHeight(60)
                headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)
                headerBtn:SetScript("OnEnter", function()
                    if not card.expanded then
                        cBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
                    end
                end)
                headerBtn:SetScript("OnLeave", function()
                    if not card.expanded then
                        cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
                    end
                end)

                -- Settings Container
                local sc = CreateFrame("Frame", nil, card)
                sc:SetPoint("TOPLEFT", 0, -60)
                sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
                sc:SetHeight(1)
                sc:SetAlpha(0)
                card.settingsContainer = sc

                local function updateExpandedVisuals()
                    if card.expanded then
                        cBg:SetColorTexture(SBgExpandedR, SBgExpandedG, SBgExpandedB, SBgA)
                        chevron:SetText("-")
                    else
                        cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
                        chevron:SetText("+")
                    end
                end

                -- Animation logic
                card.anim = card:CreateAnimationGroup()
                local sizeAnim = card.anim:CreateAnimation("Animation")
                sizeAnim:SetDuration(0.15)
                sizeAnim:SetSmoothing("IN_OUT")
                
                card.anim:SetScript("OnUpdate", function()
                    local progress = sizeAnim:GetSmoothProgress()
                    local startH = card.expanded and card.collapsedHeight or (card.fullHeight or 200)
                    local endH = card.expanded and (card.fullHeight or 200) or card.collapsedHeight
                    
                    local curH = startH + (endH - startH) * progress
                    card:SetHeight(curH)
                    
                    if card.expanded then
                        sc:SetAlpha(progress)
                    else
                        sc:SetAlpha(1 - progress)
                    end
                    UpdateDetailLayout()
                end)
                
                card.anim:SetScript("OnFinished", function()
                    local finalH = card.expanded and (card.fullHeight or 200) or card.collapsedHeight
                    card:SetHeight(finalH)
                    sc:SetAlpha(card.expanded and 1 or 0)
                    updateExpandedVisuals()
                    UpdateDetailLayout()
                end)

                headerBtn:SetScript("OnClick", function()
                    if card.anim:IsPlaying() then return end
                    card.expanded = not card.expanded
                    updateExpandedVisuals()
                    card.anim:Play()
                end)

                return card
            end

            f.BuildAccordionDetail = function(moduleSubName, options)
                local currentCard = nil
                local detailOptionFrames = {}

                -- skipDbKey: do not Refresh the control that initiated the change — Refresh() snaps the
                -- pill thumb and cancels CreateToggleSwitch's slide animation (feels broken vs other toggles).
                local function RefreshLinkedTargets(refreshIds, skipDbKey)
                    if not refreshIds then return end
                    for _, k in ipairs(refreshIds) do
                        if k ~= skipDbKey then
                            local w = detailOptionFrames[k]
                            if w and w.Refresh then w:Refresh() end
                        end
                    end
                    if addon.Presence and addon.Presence.RefreshPreviewTargets then
                        addon.Presence.RefreshPreviewTargets()
                    end
                end

                local DEPENDENT_FADE_DUR = 0.12
                local DEPENDENT_HEIGHT_DUR = 0.15
                local easeOutDep = addon.easeOut or function(t) return 1 - (1 - t) * (1 - t) end

                local function DoInstantRelayout(card, skipHeightApply)
                    if not card or not card.widgetList then return end
                    local yOff = 0
                    for _, entry in ipairs(card.widgetList) do
                        local visible = true
                        if entry.visibleWhen then
                            visible = entry.visibleWhen()
                        end
                        entry.frame:SetShown(visible)
                        if visible then
                            entry.frame:SetAlpha(1)
                            local topGap = entry.isHeader and 18 or 6
                            entry.frame:ClearAllPoints()
                            entry.frame:SetPoint("TOPLEFT", card.settingsContainer, "TOPLEFT", 30, -(yOff + topGap))
                            entry.frame:SetPoint("RIGHT", card.settingsContainer, "RIGHT", -30, 0)
                            local h = entry.frame:GetHeight() or 40
                            if entry.isHeader and h < 20 then h = 20 end
                            yOff = yOff + h + topGap
                        end
                    end
                    card.contentHeight = yOff
                    card.fullHeight = yOff + 80
                    if not skipHeightApply and card.expanded then
                        card:SetHeight(card.fullHeight)
                    end
                    UpdateDetailLayout()
                end

                local function RelayoutCard(card)
                    if not card or not card.widgetList then return end

                    if card.relayoutAnim then
                        if card.relayoutAnim.toShow then
                            for _, entry in ipairs(card.relayoutAnim.toShow) do
                                entry.frame:Hide()
                                entry.frame:SetAlpha(1)
                            end
                        end
                        if card.relayoutAnim.oldHeight then
                            card:SetHeight(card.relayoutAnim.oldHeight)
                        end
                        card.relayoutAnim = nil
                        if card.relayoutAnimFrame then
                            card.relayoutAnimFrame:SetScript("OnUpdate", nil)
                        end
                    end

                    local toHide, toShow = {}, {}
                    for _, entry in ipairs(card.widgetList) do
                        if entry.visibleWhen then
                            local wasVisible = entry.frame:IsShown()
                            local targetVisible = entry.visibleWhen()
                            if wasVisible and not targetVisible then
                                toHide[#toHide + 1] = entry
                            elseif not wasVisible and targetVisible then
                                toShow[#toShow + 1] = entry
                            end
                        end
                    end

                    local skipAnim = (#toHide == 0 and #toShow == 0) or not card.expanded

                    if skipAnim then
                        DoInstantRelayout(card, false)
                        return
                    end

                    local oldHeight = card:GetHeight()
                    local animFrame = card.relayoutAnimFrame or CreateFrame("Frame", nil, card)
                    animFrame:ClearAllPoints()
                    animFrame:SetAllPoints(card)
                    card.relayoutAnimFrame = animFrame

                    if #toHide > 0 then
                        card.relayoutAnim = { phase = "fadeOut", elapsed = 0, toHide = toHide, oldHeight = oldHeight }
                        animFrame:SetScript("OnUpdate", function(self, dt)
                            local a = card.relayoutAnim
                            if not a then self:SetScript("OnUpdate", nil) return end
                            a.elapsed = a.elapsed + dt
                            if a.phase == "fadeOut" then
                                local t = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                                local ep = easeOutDep(t)
                                for _, entry in ipairs(a.toHide) do
                                    entry.frame:SetAlpha(1 - ep)
                                end
                                if t >= 1 then
                                    for _, entry in ipairs(a.toHide) do
                                        entry.frame:Hide()
                                        entry.frame:SetAlpha(1)
                                    end
                                    DoInstantRelayout(card, true)
                                    a.phase = "heightShrink"
                                    a.elapsed = 0
                                    a.targetFullH = card.fullHeight
                                end
                            else
                                local t = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                                local ep = easeOutDep(t)
                                local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * ep
                                card:SetHeight(curH)
                                UpdateDetailLayout()
                                if t >= 1 then
                                    DoInstantRelayout(card, false)
                                    card.relayoutAnim = nil
                                    self:SetScript("OnUpdate", nil)
                                end
                            end
                        end)
                    elseif #toShow > 0 then
                        DoInstantRelayout(card, true)
                        for _, entry in ipairs(toShow) do
                            entry.frame:SetAlpha(0)
                        end
                        card:SetHeight(oldHeight)

                        card.relayoutAnim = {
                            phase = "fadeIn",
                            elapsed = 0,
                            toShow = toShow,
                            oldHeight = oldHeight,
                            targetFullH = card.fullHeight,
                        }
                        animFrame:SetScript("OnUpdate", function(self, dt)
                            local a = card.relayoutAnim
                            if not a then self:SetScript("OnUpdate", nil) return end
                            a.elapsed = a.elapsed + dt
                            local fadeT = math.min(1, a.elapsed / DEPENDENT_FADE_DUR)
                            local heightT = math.min(1, a.elapsed / DEPENDENT_HEIGHT_DUR)
                            local fadeEp = easeOutDep(fadeT)
                            local heightEp = easeOutDep(heightT)
                            for _, entry in ipairs(a.toShow) do
                                entry.frame:SetAlpha(fadeEp)
                            end
                            local curH = a.oldHeight + (a.targetFullH - a.oldHeight) * heightEp
                            card:SetHeight(curH)
                            UpdateDetailLayout()
                            if fadeT >= 1 and heightT >= 1 then
                                for _, entry in ipairs(a.toShow) do
                                    entry.frame:SetAlpha(1)
                                end
                                card:SetHeight(a.targetFullH)
                                card.relayoutAnim = nil
                                self:SetScript("OnUpdate", nil)
                                UpdateDetailLayout()
                            end
                        end)
                    end
                end

                for _, opt in ipairs(options) do
                    -- Resolve get/set fallbacks if missing
                    local g = opt.get
                    local s = opt.set
                    if not g and opt.dbKey then
                        if opt.type == "color" then
                            g = function()
                                local t = _G.OptionsData_GetDB(opt.dbKey, nil)
                                if type(t) == "table" and t[1] then
                                    return t[1], t[2], t[3], t[4] or 1
                                end
                                if type(opt.default) == "table" then return unpack(opt.default) end
                                return 1, 1, 1, 1
                            end
                        else
                            g = function() return _G.OptionsData_GetDB(opt.dbKey, opt.default) end
                        end
                    end
                    if not s and opt.dbKey then
                        if opt.type == "color" then
                            s = function(nr, ng, nb, na)
                                local t = { nr, ng, nb }
                                if opt.hasAlpha then t[4] = na end
                                _G.OptionsData_SetDB(opt.dbKey, t)
                            end
                        else
                            s = function(v) _G.OptionsData_SetDB(opt.dbKey, v) end
                        end
                    end
                    if opt.refreshIds and s then
                        local origSet = s
                        local skipKey = opt.dbKey
                        if opt.type == "color" then
                            s = function(nr, ng, nb, na)
                                origSet(nr, ng, nb, na)
                                RefreshLinkedTargets(opt.refreshIds, skipKey)
                            end
                        else
                            s = function(v)
                                origSet(v)
                                RefreshLinkedTargets(opt.refreshIds, skipKey)
                            end
                        end
                    end

                    if opt.type == "section" then
                        -- Finalize previous card if any (relayout to apply visibility)
                        if currentCard then
                            RelayoutCard(currentCard)
                        end

                        currentCard = CreateAccordionCard(detailContent, opt.name)
                        currentCard.contentHeight = 0
                        currentCard.optionIds = {}
                        currentCard.widgetList = {}
                        tinsert(currentDetailCards, currentCard)
                    else
                        if not currentCard then
                            currentCard = CreateAccordionCard(detailContent, moduleSubName)
                            currentCard.contentHeight = 0
                            currentCard.optionIds = {}
                            currentCard.widgetList = {}
                            tinsert(currentDetailCards, currentCard)
                        end
                        
                        -- Store the option identifier to track its parent card
                        local optId = opt.dbKey or (opt.type == "presencePreview" and "presencePreview") or (moduleSubName .. "_" .. (type(opt.name)=="function" and opt.name() or opt.name or ""):gsub("%s+", "_"))
                        currentCard.optionIds[optId] = true

                        local widget
                        if opt.type == "binary" or opt.type == "toggle" then
                            widget = _G.OptionsWidgets_CreateToggleSwitch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.disabled, opt.tooltip)
                            if widget then
                                if opt.hidden and type(opt.hidden) == "function" then
                                    local origRefresh = widget.Refresh
                                    widget.Refresh = function(self)
                                        if origRefresh then origRefresh(self) end
                                        if opt.hidden() then self:Hide() else self:Show() end
                                    end
                                    if opt.hidden() then widget:Hide() end
                                end
                                if widget.Refresh then detailOptionFrames[optId] = widget end
                            end
                        elseif opt.type == "slider" then
                            widget = _G.OptionsWidgets_CreateSlider(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.min or 0, opt.max or 100, opt.disabled, opt.step or 1, opt.tooltip)
                            if widget then
                                if opt.hidden and type(opt.hidden) == "function" then
                                    local origRefresh = widget.Refresh
                                    widget.Refresh = function(self)
                                        if origRefresh then origRefresh(self) end
                                        if opt.hidden() then self:Hide() else self:Show() end
                                    end
                                    if opt.hidden() then widget:Hide() end
                                end
                                if widget.Refresh then detailOptionFrames[optId] = widget end
                            end
                        elseif opt.type == "dropdown" then
                            local resetBtn = opt.resetButton
                            if resetBtn and resetBtn.onClick and opt.refreshIds then
                                local origOnClick = resetBtn.onClick
                                resetBtn = {
                                    onClick = function()
                                        origOnClick()
                                        RefreshLinkedTargets(opt.refreshIds)
                                        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                    end,
                                    tooltip = resetBtn.tooltip,
                                }
                            end
                            widget = _G.OptionsWidgets_CreateCustomDropdown(currentCard.settingsContainer, opt.name, opt.desc or "", opt.options, g, s, opt.displayFn, opt.searchable, opt.disabled, opt.tooltip, resetBtn)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "color" then
                            widget = _G.OptionsWidgets_CreateColorSwatch(currentCard.settingsContainer, opt.name, opt.desc or "", g, s, opt.hasAlpha, opt.tooltip)
                            if widget and widget.Refresh then detailOptionFrames[optId] = widget end
                        elseif opt.type == "presencePreview" then
                            local previewWidget = addon.Presence and addon.Presence.CreatePreviewWidget and addon.Presence.CreatePreviewWidget(currentCard.settingsContainer, {
                                getTypeName = function()
                                    return _G.OptionsData_GetDB("presencePreviewType", "LEVEL_UP")
                                end,
                                setTypeName = function(v)
                                    _G.OptionsData_SetDB("presencePreviewType", v)
                                end,
                                notify = function()
                                    if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end,
                                scale = 0.55,
                            })
                            widget = previewWidget and previewWidget.frame or nil
                            if widget and previewWidget.Refresh then
                                widget.Refresh = previewWidget.Refresh
                            end
                            detailOptionFrames[optId] = widget
                        elseif opt.type == "header" then
                            widget = _G.OptionsWidgets_CreateSectionHeader(currentCard.settingsContainer, opt.name)
                        elseif opt.type == "button" then
                            local onClick = opt.onClick
                            if opt.refreshIds and #opt.refreshIds > 0 then
                                onClick = function()
                                    if opt.onClick then opt.onClick() end
                                    RefreshLinkedTargets(opt.refreshIds)
                                end
                            end
                            widget = _G.OptionsWidgets_CreateButton(currentCard.settingsContainer, opt.name, onClick, { tooltip = opt.tooltip })
                        elseif opt.type == "editbox" then
                            if _G.OptionsWidgets_CreateEditBox then
                                widget = _G.OptionsWidgets_CreateEditBox(currentCard.settingsContainer, opt.labelText or opt.name, g, s, {
                                    height = opt.height,
                                    readonly = opt.readonly,
                                    storeRef = opt.storeRef,
                                    tooltip = opt.tooltip,
                                })
                            end
                        elseif opt.type == "reorderList" then
                            if OptionsWidgets_CreateReorderList then
                                widget = OptionsWidgets_CreateReorderList(currentCard.settingsContainer, currentCard.settingsContainer, opt, detailScroll, detailContent, function()
                                    if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end)
                            end
                        elseif opt.type == "blacklistGrid" then
                            if _G.OptionsWidgets_CreateBlacklistGrid then
                                widget = _G.OptionsWidgets_CreateBlacklistGrid(currentCard.settingsContainer, opt.name, {
                                    desc = opt.desc or "",
                                    tooltip = opt.tooltip,
                                })
                            end
                        elseif opt.type == "colorMatrix" then
                            -- Emulate a mini-card inside the settings container
                            local cmContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                            local yOff = 0
                            
                            local lbl = _G.OptionsWidgets_CreateSectionHeader(cmContainer, opt.name or "Colors")
                            lbl:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                            lbl:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                            yOff = yOff - 24
                            
                            local keys = opt.keys or addon.COLOR_KEYS_ORDER or {}
                            local defaultMap = opt.defaultMap or addon.QUEST_COLORS or {}
                            local swatches = {}
                            
                            local sub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["OPTIONS_FOCUS_QUEST_TYPES"])
                            sub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 20
                            
                            for _, key in ipairs(keys) do
                                local getTbl = function() local db = _G.OptionsData_GetDB(opt.dbKey, nil) return db and db[key] end
                                local setKeyVal = function(v) 
                                    addon.EnsureDB()
                                    local _rdb = _G[addon.DB_NAME]
                                    if not _rdb[opt.dbKey] then _rdb[opt.dbKey] = {} end
                                    _rdb[opt.dbKey][key] = v
                                    if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                                end
                                local labelText = addon.L[(opt.labelMap and opt.labelMap[key]) or key:gsub("^%l", string.upper)]
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, labelText, defaultMap[key], getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                                row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                                yOff = yOff - 28
                                swatches[#swatches+1] = row
                            end
                            
                            local resetBtn = _G.OptionsWidgets_CreateButton(cmContainer, L["OPTIONS_FOCUS_RESET_QUEST_TYPES"], function()
                                _G.OptionsData_SetDB(opt.dbKey, nil)
                                _G.OptionsData_SetDB("sectionColors", nil)
                                for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end, { width = 120, height = 22 })
                            resetBtn:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                            yOff = yOff - 30

                            local overridesSub = _G.OptionsWidgets_CreateSectionHeader(cmContainer, L["OPTIONS_FOCUS_ELEMENT_OVERRIDES"])
                            overridesSub:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 0, yOff - 10)
                            yOff = yOff - 30
                            
                            local overrideRows = {}
                            for _, ov in ipairs(opt.overrides or {}) do
                                local getTbl = function() return _G.OptionsData_GetDB(ov.dbKey, nil) end
                                local setKeyVal = function(v) _G.OptionsData_SetDB(ov.dbKey, v); if not addon._colorPickerLive and addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmContainer, nil, ov.name, ov.default, getTbl, setKeyVal, function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                                row:SetPoint("RIGHT", cmContainer, "RIGHT", 0, 0)
                                yOff = yOff - 28
                                overrideRows[#overrideRows+1] = row
                            end
                            
                            local resetOv = _G.OptionsWidgets_CreateButton(cmContainer, L["OPTIONS_FOCUS_RESET_OVERRIDES"], function()
                                for _, ov in ipairs(opt.overrides or {}) do _G.OptionsData_SetDB(ov.dbKey, nil) end
                                for _, r in ipairs(overrideRows) do if r.Refresh then r:Refresh() end end
                                if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
                            end, { width = 120, height = 22 })
                            resetOv:SetPoint("TOPLEFT", cmContainer, "TOPLEFT", 10, yOff)
                            yOff = yOff - 28

                        elseif opt.type == "colorMatrixFull" then
                            -- Compact color cards in 3-column grid
                            local cmfContainer = CreateFrame("Frame", nil, currentCard.settingsContainer)
                            local notifyFn = function() if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end end

                            local function getMatrix()
                                addon.EnsureDB()
                                local m = _G.OptionsData_GetDB(opt.dbKey, nil)
                                if type(m) ~= "table" then
                                    m = { categories = {}, overrides = {} }
                                    _G.OptionsData_SetDB(opt.dbKey, m)
                                else
                                    m.categories = m.categories or {}
                                    m.overrides = m.overrides or {}
                                end
                                return m
                            end

                            local function getOverride(key)
                                local m = getMatrix()
                                local v = m.overrides and m.overrides[key]
                                if key == "useCompletedOverride" and v == nil then return true end
                                if key == "useCurrentQuestOverride" and v == nil then return true end
                                return v
                            end
                            local function setOverride(key, v)
                                local m = getMatrix()
                                m.overrides[key] = v
                                _G.OptionsData_SetDB(opt.dbKey, m)
                                if not addon._colorPickerLive then notifyFn() end
                            end

                            -- Grid constants
                            local COLS = 3
                            local CARD_GAP = 12
                            local CARD_H = 108
                            local CARD_PAD = 14
                            local widgetFontPath = (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
                            local widgetLabelColor = { 0.88, 0.88, 0.92 }

                            local allCards = {}
                            local overrideGroupMap = {}
                            local otherColorRows = {}
                            local completedObjRow

                            -- Build a compact color card for a category
                            local function BuildCompactCard(parentFrame, key)
                                local labelBase = addon.L[(addon.SECTION_LABELS and addon.SECTION_LABELS[key]) or key]
                                local card = CreateFrame("Frame", nil, parentFrame)
                                card:SetHeight(CARD_H)
                                card.groupKey = key

                                -- Card background (match options section-card transparency)
                                local bg = card:CreateTexture(nil, "BACKGROUND")
                                bg:SetAllPoints(card)
                                bg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                                -- Subtle border
                                if addon.CreateBorder then
                                    addon.CreateBorder(card, SBd)
                                end

                                -- 2px accent bar at top using category base color
                                local accentBar = card:CreateTexture(nil, "OVERLAY")
                                accentBar:SetHeight(2)
                                accentBar:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
                                accentBar:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
                                card.accentBar = accentBar

                                local nameLabel = card:CreateFontString(nil, "OVERLAY")
                                nameLabel:SetFont(widgetFontPath, 13, "OUTLINE")
                                nameLabel:SetTextColor(widgetLabelColor[1], widgetLabelColor[2], widgetLabelColor[3])
                                nameLabel:SetText((labelBase and labelBase ~= "") and (string.gsub(labelBase, "(%a)([%w_']*)", function(a, b) return string.upper(a) .. string.lower(b) end)) or labelBase)
                                nameLabel:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)
                                nameLabel:SetJustifyH("LEFT")

                                local resetBtn = _G.OptionsWidgets_CreateButton(card, L["OPTIONS_FOCUS_RESET"], function()
                                    local m = getMatrix()
                                    if m.categories and m.categories[key] then
                                        m.categories[key] = nil
                                        _G.OptionsData_SetDB(opt.dbKey, m)
                                        notifyFn()
                                        card:Refresh()
                                    end
                                end, { width = 52, height = 20 })
                                resetBtn:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -7)

                                local questColorKey = (key == "ACHIEVEMENTS" and "ACHIEVEMENT") or (key == "RARES" and "RARE") or key
                                local baseColor = (addon.QUEST_COLORS and addon.QUEST_COLORS[questColorKey]) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local sectionColor = (addon.SECTION_COLORS and addon.SECTION_COLORS[key]) or (addon.SECTION_COLORS and addon.SECTION_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                                local unifiedDef = (key == "NEARBY" or key == "CURRENT" or key == "CURRENT_EVENT") and sectionColor or baseColor

                                local zoneLabel = (key == "SCENARIO") and ((addon.L and addon.L["UI_STAGE"]) or "Stage") or ((addon.L and addon.L["OPTIONS_FOCUS_ZONE"]) or "Zone")
                                local catDefs = {
                                    { subKey = "section",   abbr = L["OPTIONS_FOCUS_SECTION"] or "Section",   full = "Section",   def = unifiedDef },
                                    { subKey = "title",     abbr = L["OPTIONS_FOCUS_TITLE"] or "Title",     full = "Title",     def = unifiedDef },
                                    { subKey = "zone",      abbr = (key == "SCENARIO") and (L["UI_STAGE"] or "Stage") or (L["OPTIONS_FOCUS_ZONE"] or "Zone"), full = zoneLabel, def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                                    { subKey = "objective", abbr = L["OPTIONS_FOCUS_OBJECTIVE"] or "Objective", full = "Objective", def = unifiedDef },
                                }

                                card.swatches = {}
                                -- 2×2 grid: swatch-left layout, more breathing room
                                local SWATCH_ROW_H = 32
                                local SWATCH_GAP_X = 14
                                local SWATCH_W = 90
                                for i, cd in ipairs(catDefs) do
                                    local getTbl = function()
                                        local m = getMatrix()
                                        local cats = m.categories or {}
                                        return cats[key] and cats[key][cd.subKey] or nil
                                    end
                                    local setKeyVal = function(v)
                                        local m = getMatrix()
                                        m.categories[key] = m.categories[key] or {}
                                        m.categories[key][cd.subKey] = (type(v) == "table" and v[1] and v[2] and v[3]) and { v[1], v[2], v[3] } or v
                                        _G.OptionsData_SetDB(opt.dbKey, m)
                                        if not addon._colorPickerLive then notifyFn() end
                                    end
                                    local sw = _G.OptionsWidgets_CreateMiniSwatch(card, cd.abbr, cd.def, getTbl, setKeyVal, notifyFn, cd.full)
                                    local col = (i - 1) % 2
                                    local row = math.floor((i - 1) / 2)
                                    local xOfs = 10 + col * (SWATCH_W + SWATCH_GAP_X)
                                    local yOfs = -(8 + nameLabel:GetStringHeight() + 6 + row * SWATCH_ROW_H)
                                    sw:ClearAllPoints()
                                    sw:SetPoint("TOPLEFT", card, "TOPLEFT", xOfs, yOfs)
                                    card.swatches[#card.swatches + 1] = sw
                                end

                                function card:Refresh()
                                    for _, sw in ipairs(self.swatches) do if sw.Refresh then sw:Refresh() end end
                                    -- Update accent bar from live section color
                                    local m = getMatrix()
                                    local cats = m.categories or {}
                                    local catData = cats[self.groupKey]
                                    local secColor = (catData and catData.section) or unifiedDef
                                    local r, g, b = secColor[1], secColor[2], secColor[3]
                                    self.accentBar:SetColorTexture(r, g, b, 1)
                                end

                                allCards[#allCards + 1] = card
                                card:Refresh()
                                return card
                            end

                            -- Position cards in a grid within a container
                            local function PositionGrid(gridFrame, cards, cols, cardH, gap)
                                local gridW = gridFrame:GetWidth()
                                if gridW < 10 then gridW = 600 end
                                local cardW = math.floor((gridW - (cols - 1) * gap) / cols)
                                for idx, c in ipairs(cards) do
                                    local col = (idx - 1) % cols
                                    local row = math.floor((idx - 1) / cols)
                                    c:ClearAllPoints()
                                    c:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", col * (cardW + gap), -row * (cardH + gap))
                                    c:SetSize(cardW, cardH)
                                end
                            end

                            -- LayoutAll repositions everything and resizes the container
                            local perCatCards = {}
                            local overrideCards = {}
                            local perCatGrid, overrideGrid
                            local perCatHdr, resetAllBtn, goHdr, otherHdr
                            local ovCompleted, ovCurrentZone, ovCurrentQuest, ovCompletedObj

                            local function LayoutAll()
                                local yOff = 0

                                perCatHdr:ClearAllPoints()
                                perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                resetAllBtn:ClearAllPoints()
                                resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                                yOff = yOff - 28

                                -- Per-category grid
                                local numRows = math.ceil(#perCatCards / COLS)
                                local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                                perCatGrid:ClearAllPoints()
                                perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                perCatGrid:SetHeight(gridH)
                                PositionGrid(perCatGrid, perCatCards, COLS, CARD_H, CARD_GAP)
                                yOff = yOff - gridH

                                yOff = yOff - 16
                                goHdr:ClearAllPoints()
                                goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                yOff = yOff - 28

                                ovCompleted:ClearAllPoints()
                                ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                ovCurrentZone:ClearAllPoints()
                                ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                ovCurrentQuest:ClearAllPoints()
                                ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                -- Override grid: show only visible cards in a single row
                                local visibleOv = {}
                                for _, c in ipairs(overrideCards) do
                                    if c:IsShown() then visibleOv[#visibleOv + 1] = c end
                                end
                                if #visibleOv > 0 then
                                    overrideGrid:ClearAllPoints()
                                    overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                    overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                    overrideGrid:SetHeight(CARD_H)
                                    overrideGrid:Show()
                                    PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                                    yOff = yOff - CARD_H
                                else
                                    overrideGrid:Hide()
                                end

                                yOff = yOff - 16
                                otherHdr:ClearAllPoints()
                                otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                                yOff = yOff - 28

                                ovCompletedObj:ClearAllPoints()
                                ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                yOff = yOff - 40

                                for _, row in ipairs(otherColorRows) do
                                    if row:IsShown() then
                                        row:ClearAllPoints()
                                        row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                        row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                        yOff = yOff - 30
                                    end
                                end

                                local newHeight = math.max(1, -yOff)
                                cmfContainer:SetHeight(newHeight)
                                currentCard.contentHeight = newHeight
                                currentCard.fullHeight = newHeight + 80
                                UpdateDetailLayout()
                            end

                            -- Build the layout
                            local groupOrder = addon.GetGroupOrder and addon.GetGroupOrder() or {}
                            if type(groupOrder) ~= "table" or #groupOrder == 0 then groupOrder = addon.GROUP_ORDER or {} end
                            local GROUPING_OVERRIDE_KEYS = { CURRENT = true, NEARBY = true, COMPLETE = true }
                            local yOff = 0

                            perCatHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_PER_CATEGORY"])
                            perCatHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            resetAllBtn = _G.OptionsWidgets_CreateButton(cmfContainer, L["OPTIONS_FOCUS_RESET_DEFAULTS"], function()
                                _G.OptionsData_SetDB(opt.dbKey, nil)
                                _G.OptionsData_SetDB("questColors", nil)
                                _G.OptionsData_SetDB("sectionColors", nil)
                                for _, c in ipairs(allCards) do if c.Refresh then c:Refresh() end end
                                for _, r in ipairs(otherColorRows) do if r.Refresh then r:Refresh() end end
                                notifyFn()
                            end, { width = 140, height = 22 })
                            resetAllBtn:SetPoint("TOPRIGHT", cmfContainer, "TOPRIGHT", 0, yOff)
                            yOff = yOff - 28

                            -- Per-category grid
                            perCatGrid = CreateFrame("Frame", nil, cmfContainer)
                            local perCatKeys = {}
                            for _, key in ipairs(groupOrder) do
                                if not GROUPING_OVERRIDE_KEYS[key] then
                                    tinsert(perCatKeys, key)
                                end
                            end
                            for _, key in ipairs(perCatKeys) do
                                local card = BuildCompactCard(perCatGrid, key)
                                tinsert(perCatCards, card)
                            end
                            local numRows = math.ceil(#perCatCards / COLS)
                            local gridH = numRows * CARD_H + math.max(0, numRows - 1) * CARD_GAP
                            perCatGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            perCatGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            perCatGrid:SetHeight(gridH)
                            yOff = yOff - gridH

                            yOff = yOff - 16
                            goHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_SECTION_OVERRIDES"])
                            goHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 28

                            ovCompleted = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_READY_TURN_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_READY_TURN_COLOURS_QUESTS"], function() return getOverride("useCompletedOverride") end, function(v)
                                setOverride("useCompletedOverride", v)
                                local gf = overrideGroupMap["COMPLETE"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCompleted:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCompleted:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            ovCurrentZone = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_CURRENT_ZONE_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_CURRENT_ZONE_COLOURS_QUESTS_SEC"], function() return getOverride("useCurrentZoneOverride") end, function(v)
                                setOverride("useCurrentZoneOverride", v)
                                local gf = overrideGroupMap["NEARBY"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCurrentZone:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCurrentZone:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            ovCurrentQuest = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_CURRENT_QUEST_OVERRIDES_BASE_COLOURS"], L["OPTIONS_FOCUS_CURRENT_QUEST_COLOURS_QUESTS_SE"], function() return getOverride("useCurrentQuestOverride") end, function(v)
                                setOverride("useCurrentQuestOverride", v)
                                local gf = overrideGroupMap["CURRENT"]
                                if gf then gf:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCurrentQuest:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCurrentQuest:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            -- Override color cards in a single-row grid
                            overrideGrid = CreateFrame("Frame", nil, cmfContainer)
                            for _, key in ipairs(groupOrder) do
                                if GROUPING_OVERRIDE_KEYS[key] then
                                    local card = BuildCompactCard(overrideGrid, key)
                                    tinsert(overrideCards, card)
                                    overrideGroupMap[key] = card
                                end
                            end
                            -- Hide override cards whose toggle is OFF
                            if not getOverride("useCompletedOverride") and overrideGroupMap["COMPLETE"] then overrideGroupMap["COMPLETE"]:Hide() end
                            if not getOverride("useCurrentZoneOverride") and overrideGroupMap["NEARBY"] then overrideGroupMap["NEARBY"]:Hide() end
                            if not getOverride("useCurrentQuestOverride") and overrideGroupMap["CURRENT"] then overrideGroupMap["CURRENT"]:Hide() end

                            local visibleOv = {}
                            for _, c in ipairs(overrideCards) do if c:IsShown() then visibleOv[#visibleOv + 1] = c end end
                            if #visibleOv > 0 then
                                overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                overrideGrid:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                                overrideGrid:SetHeight(CARD_H)
                                PositionGrid(overrideGrid, visibleOv, #visibleOv, CARD_H, CARD_GAP)
                                yOff = yOff - CARD_H
                            else
                                overrideGrid:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                overrideGrid:SetHeight(1)
                            end

                            yOff = yOff - 16
                            otherHdr = _G.OptionsWidgets_CreateSectionHeader(cmfContainer, L["OPTIONS_FOCUS_COLORS"])
                            otherHdr:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", 0, yOff)
                            yOff = yOff - 28

                            ovCompletedObj = _G.OptionsWidgets_CreateToggleSwitch(cmfContainer, L["OPTIONS_FOCUS_DISTINCT_COLOR_COMPLETED_OBJECTIVES"], L["OPTIONS_CORE_COMPLETED_OBJECTIVES_COLOR_BELOW"], function() return _G.OptionsData_GetDB("useCompletedObjectiveColor", true) end, function(v)
                                _G.OptionsData_SetDB("useCompletedObjectiveColor", v)
                                notifyFn()
                                if completedObjRow then completedObjRow:SetShown(v and true or false); LayoutAll() end
                            end)
                            ovCompletedObj:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                            ovCompletedObj:SetPoint("RIGHT", cmfContainer, "RIGHT", -CARD_PAD, 0)
                            yOff = yOff - 40

                            local otherDefs = {
                                { dbKey = "highlightColor", label = L["OPTIONS_FOCUS_HIGHLIGHT"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                                { dbKey = "completedObjectiveColor", label = L["OPTIONS_FOCUS_COMPLETED_OBJECTIVE"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }), isCompletedObj = true },
                                { dbKey = "progressBarFillColor", label = L["OPTIONS_FOCUS_PROGRESS_BAR_FILL"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return _G.OptionsData_GetDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                                { dbKey = "progressBarTextColor", label = L["OPTIONS_FOCUS_PROGRESS_BAR_TEXT"], def = { 0.95, 0.95, 0.95 } },
                            }

                            for _, od in ipairs(otherDefs) do
                                local getTbl = function() return _G.OptionsData_GetDB(od.dbKey, nil) end
                                local setKeyVal = function(v) _G.OptionsData_SetDB(od.dbKey, v); if not addon._colorPickerLive then notifyFn() end end
                                local row = _G.OptionsWidgets_CreateColorSwatchRow(cmfContainer, nil, od.label, od.def, getTbl, setKeyVal, notifyFn, od.disabled, od.hasAlpha)
                                row:ClearAllPoints()
                                row:SetPoint("TOPLEFT", cmfContainer, "TOPLEFT", CARD_PAD, yOff)
                                row:SetPoint("RIGHT", cmfContainer, "RIGHT", 0, 0)
                                tinsert(otherColorRows, row)
                                if od.isCompletedObj then completedObjRow = row end
                                yOff = yOff - 30
                            end

                            -- Hide completed objective swatch if toggle is OFF
                            if completedObjRow and not _G.OptionsData_GetDB("useCompletedObjectiveColor", true) then
                                completedObjRow:Hide()
                            end

                            cmfContainer:SetHeight(-yOff)
                            -- OnSizeChanged: reposition grid cards when width changes (guard against height-only changes)
                            local lastCmfWidth = 0
                            cmfContainer:SetScript("OnSizeChanged", function(self, w)
                                if math.abs(w - lastCmfWidth) > 0.5 then
                                    lastCmfWidth = w
                                    LayoutAll()
                                end
                            end)
                            widget = cmfContainer
                        end

                        if widget then
                            widget:SetParent(currentCard.settingsContainer)
                            widget:Show()
                            widget._parentCard = currentCard

                            local isHeader = opt.type == "header"
                            if isHeader then
                                if widget.SetJustifyH then widget:SetJustifyH("LEFT") end
                                if widget.SetTextColor then
                                    widget:SetTextColor(0.58, 0.64, 0.74, 1)
                                end
                            end

                            tinsert(currentCard.widgetList, {
                                frame = widget,
                                isHeader = isHeader,
                                visibleWhen = opt.visibleWhen,
                            })

                            if opt.visibleWhen and type(opt.visibleWhen) == "function" and widget.Refresh then
                                local origRefresh = widget.Refresh
                                local cardRef = currentCard
                                widget.Refresh = function(self)
                                    if origRefresh then origRefresh(self) end
                                    RelayoutCard(cardRef)
                                end
                            end
                        end
                    end
                end

                if currentCard then
                    RelayoutCard(currentCard)
                end

                UpdateDetailLayout()
            end


            -- Icons by moduleKey so localized tile titles still resolve art.
            local dashboardTileIconByKey = {
                axis = "INV_Misc_Wrench_01",
                focus = "achievement_quests_completed_05",
                presence = "vas_guildnamechange",
                vista = "ability_hunter_pathfinding",
                insight = "ui_profession_inscription",
                cache = "INV_Misc_Coin_01",
                essence = "achievement_character_human_male",
                meridian = "ability_tracking",
            }

            local function DashboardAxisBentoHeight()
                return DASH_HOME_TILE_H * 3 + DASH_HOME_TILE_GAP * 2
            end

            local function DashboardTileSizeForKey(mk)
                if mk == "axis" then
                    return DASH_HOME_TILE_W, DashboardAxisBentoHeight()
                end
                return DASH_HOME_TILE_W, DASH_HOME_TILE_H
            end

            -- Copy-to-clipboard: same custom dialog as Patch Notes "Full changelog" (addon.ShowURLCopyBox in core/Core.lua)
            local function ShowCopyURL(label, url)
                if addon.ShowURLCopyBox then
                    addon.ShowURLCopyBox(url, (L["DASH_COPY_LINK_X"] or "Copy link — %s"):format(label))
                end
            end

            local function MakeTile(parent, name, icon, moduleKey)
                local tile = CreateFrame("Button", nil, parent)
                tile.moduleKey = moduleKey
                local tw, th = DashboardTileSizeForKey(moduleKey)
                local isAxis = moduleKey == "axis"
                tile:SetSize(tw, th)

                local tileH = th
                local fillA = SBgA * DASH_HOME_TILE_BG_ALPHA_MULT
                local borderA = SBd[4] * DASH_HOME_TILE_BORDER_ALPHA_MULT

                -- Background (softer than section cards)
                local tBg = tile:CreateTexture(nil, "BACKGROUND", nil, -8)
                tBg:SetPoint("TOPLEFT", 2, -2)
                tBg:SetPoint("BOTTOMRIGHT", -2, 2)
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillA)

                -- Top sheen (gradient when supported)
                local sheen = tile:CreateTexture(nil, "BACKGROUND", nil, -7)
                sheen:SetPoint("TOPLEFT", tBg, "TOPLEFT", 0, 0)
                sheen:SetPoint("TOPRIGHT", tBg, "TOPRIGHT", 0, 0)
                sheen:SetHeight(math.min(56, math.floor(tileH * 0.38)))
                if sheen.SetGradient and CreateColor then
                    sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.09), CreateColor(0.04, 0.05, 0.08, 0))
                else
                    sheen:SetColorTexture(1, 1, 1, 0.04)
                end

                -- Outer border
                local border = tile:CreateTexture(nil, "BORDER")
                border:SetAllPoints()
                border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderA)

                -- Inner hairline (top edge — lifts card off flat fill)
                local innerTop = tile:CreateTexture(nil, "ARTWORK", nil, -8)
                innerTop:SetHeight(1)
                innerTop:SetPoint("TOPLEFT", tBg, "TOPLEFT", 1, -1)
                innerTop:SetPoint("TOPRIGHT", tBg, "TOPRIGHT", -1, -1)
                innerTop:SetColorTexture(1, 1, 1, 0.11)

                -- Axis: subtle class-accent rail (idle)
                local axisRail = nil
                if isAxis then
                    axisRail = tile:CreateTexture(nil, "ARTWORK", nil, -7)
                    axisRail:SetWidth(3)
                    axisRail:SetPoint("TOPLEFT", tBg, "TOPLEFT", 0, 0)
                    axisRail:SetPoint("BOTTOMLEFT", tBg, "BOTTOMLEFT", 0, 0)
                    local rr, rg, rb = GetAccentColor()
                    axisRail:SetColorTexture(rr, rg, rb, 0.35)
                    tile.axisRail = axisRail
                    tinsert(dashAccentRefs.dashboardAxisRails, axisRail)
                end

                local iconPath = dashboardTileIconByKey[moduleKey] or categoryIcons[name] or "INV_Misc_Question_01"
                local ic = tile:CreateTexture(nil, "ARTWORK")
                ic:SetTexture("Interface\\Icons\\" .. iconPath)
                ic:SetVertexColor(0.80, 0.80, 0.85, 0.82)

                local tileDivider = tile:CreateTexture(nil, "ARTWORK")
                tileDivider:SetHeight(1)
                tileDivider:SetColorTexture(0.20, 0.21, 0.26, 0.28)

                local lbl = MakeText(tile, name, 13, 0.80, 0.80, 0.85, "CENTER")
                tile.label = lbl
                local mc = TILE_MODULE_LABEL_COLORS[moduleKey]
                tile._moduleLabelR = mc and mc[1] or 0.80
                tile._moduleLabelG = mc and mc[2] or 0.80
                tile._moduleLabelB = mc and mc[3] or 0.85
                lbl:SetTextColor(tile._moduleLabelR, tile._moduleLabelG, tile._moduleLabelB)

                if moduleKey and PREVIEW_MODULE_KEYS[moduleKey] then
                    local prevLabel = "(" .. (L["OPTIONS_PRESENCE_PREVIEW"] or "Preview") .. ")"
                    local prevBadge = MakeText(tile, prevLabel, 9, 34/255, 139/255, 34/255, "CENTER")
                    prevBadge:SetPoint("TOP", lbl, "BOTTOM", 0, -1)
                    tile.previewBadge = prevBadge
                elseif moduleKey and COMING_SOON_MODULE_KEYS[moduleKey] then
                    local csLabel = "(" .. (L["OPTIONS_CORE_COMING_SOON"] or "Coming Soon") .. ")"
                    local csBadge = MakeText(tile, csLabel, 9, 0.55, 0.70, 0.90, "CENTER")
                    csBadge:SetPoint("TOP", lbl, "BOTTOM", 0, -1)
                    tile.previewBadge = csBadge
                end

                local bottomGlow = tile:CreateTexture(nil, "ARTWORK")
                bottomGlow:SetHeight(2)
                bottomGlow:SetPoint("BOTTOMLEFT", 1, 1)
                bottomGlow:SetPoint("BOTTOMRIGHT", -1, 1)
                bottomGlow:SetColorTexture(1, 1, 1, 0)

                local fillANormal = SBgA * DASH_HOME_TILE_BG_ALPHA_MULT
                local borderANormal = SBd[4] * DASH_HOME_TILE_BORDER_ALPHA_MULT
                tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
                tile._dashBorderIdleA = borderANormal
                tile._isSkeleton = false

                --- Apply disabled-module (skeleton) or normal idle chrome for this Home tile.
                --- @param skeleton boolean
                --- @return nil
                tile.SetDashboardSkeletonMode = function(_, skeleton)
                    tile._isSkeleton = skeleton and true or false
                    if tile._isSkeleton then
                        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal * DASH_HOME_SKELETON_BG_ALPHA_MULT)
                        border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderANormal * DASH_HOME_SKELETON_BORDER_ALPHA_MULT)
                        tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
                        tile._dashBorderIdleA = borderANormal * DASH_HOME_SKELETON_BORDER_ALPHA_MULT
                        if ic.SetDesaturated then ic:SetDesaturated(true) end
                        ic:SetVertexColor(0.5, 0.52, 0.56, 0.68)
                        lbl:SetTextColor(0.44, 0.46, 0.49)
                        if tile.previewBadge then
                            tile.previewBadge:SetTextColor(0.32, 0.58, 0.34, 0.8)
                        end
                        tileDivider:SetColorTexture(0.14, 0.15, 0.17, 0.22)
                        innerTop:SetColorTexture(1, 1, 1, 0.04)
                        if sheen.SetGradient and CreateColor then
                            sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.03), CreateColor(0.04, 0.05, 0.08, 0))
                        else
                            sheen:SetColorTexture(1, 1, 1, 0.015)
                        end
                        bottomGlow:SetColorTexture(1, 1, 1, 0)
                        if tile.axisRail then
                            local rr, rg, rb = GetAccentColor()
                            tile.axisRail:SetColorTexture(rr, rg, rb, 0.22)
                        end
                    else
                        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal)
                        border:SetColorTexture(SBd[1], SBd[2], SBd[3], borderANormal)
                        tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB = SBd[1], SBd[2], SBd[3]
                        tile._dashBorderIdleA = borderANormal
                        if ic.SetDesaturated then ic:SetDesaturated(false) end
                        ic:SetVertexColor(0.80, 0.80, 0.85, 0.82)
                        lbl:SetTextColor(tile._moduleLabelR, tile._moduleLabelG, tile._moduleLabelB)
                        if tile.previewBadge then
                            tile.previewBadge:SetTextColor(34/255, 139/255, 34/255, 1)
                        end
                        tileDivider:SetColorTexture(0.20, 0.21, 0.26, 0.28)
                        innerTop:SetColorTexture(1, 1, 1, 0.11)
                        if sheen.SetGradient and CreateColor then
                            sheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.09), CreateColor(0.04, 0.05, 0.08, 0))
                        else
                            sheen:SetColorTexture(1, 1, 1, 0.04)
                        end
                        bottomGlow:SetColorTexture(1, 1, 1, 0)
                        if tile.axisRail then
                            local rr, rg, rb = GetAccentColor()
                            tile.axisRail:SetColorTexture(rr, rg, rb, 0.35)
                        end
                    end
                end

                tile.ApplyDashboardTileLayout = function(_, h)
                    h = h or tile:GetHeight() or DASH_HOME_TILE_H
                    local axis = tile.moduleKey == "axis"
                    local icSize = axis and 72 or 54
                    ic:SetSize(icSize, icSize)
                    if axis then
                        -- Bento block: icon upper-middle, label band at bottom (same stack height as two small tiles).
                        ic:SetPoint("CENTER", tile, "CENTER", -4, 28)
                        tileDivider:ClearAllPoints()
                        tileDivider:SetPoint("LEFT", tile, "LEFT", 28, 0)
                        tileDivider:SetPoint("RIGHT", tile, "RIGHT", -28, 0)
                        tileDivider:SetPoint("BOTTOM", tile, "BOTTOM", 0, 46)
                        lbl:ClearAllPoints()
                        lbl:SetPoint("BOTTOM", tile, "BOTTOM", -6, 22)
                    else
                        ic:SetPoint("CENTER", tile, "CENTER", 0, 12)
                        tileDivider:ClearAllPoints()
                        tileDivider:SetPoint("LEFT", tile, "LEFT", 20, 0)
                        tileDivider:SetPoint("RIGHT", tile, "RIGHT", -22, 0)
                        tileDivider:SetPoint("BOTTOM", tile, "BOTTOM", 0, 42)
                        lbl:ClearAllPoints()
                        lbl:SetPoint("BOTTOM", tile, "BOTTOM", 0, 19)
                    end
                    sheen:SetHeight(math.min(axis and 100 or 56, math.floor(h * (axis and 0.32 or 0.38))))
                end
                tile.ApplyDashboardTileLayout(tile, tileH)

                tile:SetScript("OnEnter", function()
                    if tile._isSkeleton then
                        border:SetColorTexture(tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB, math.min(1, tile._dashBorderIdleA * 1.2))
                        ic:SetVertexColor(0.58, 0.60, 0.64, 0.82)
                        lbl:SetTextColor(0.55, 0.57, 0.60)
                        bottomGlow:SetColorTexture(tile._dashBorderIdleR, tile._dashBorderIdleG, tile._dashBorderIdleB, 0.22)
                        innerTop:SetColorTexture(1, 1, 1, 0.07)
                        if tile.previewBadge then
                            tile.previewBadge:SetTextColor(0.38, 0.65, 0.40, 0.9)
                        end
                        if tile.axisRail then
                            local ar, ag, ab = GetAccentColor()
                            tile.axisRail:SetColorTexture(ar, ag, ab, 0.35)
                        end
                    else
                        local ar, ag, ab = GetAccentColor()
                        border:SetColorTexture(ar, ag, ab, 0.55)
                        ic:SetVertexColor(1, 1, 1, 1)
                        lbl:SetTextColor(1, 1, 1)
                        bottomGlow:SetColorTexture(ar, ag, ab, 0.48)
                        innerTop:SetColorTexture(1, 1, 1, 0.16)
                        if tile.axisRail then
                            tile.axisRail:SetColorTexture(ar, ag, ab, 0.55)
                        end
                    end
                end)
                tile:SetScript("OnLeave", function()
                    if tile.SetDashboardSkeletonMode then
                        tile:SetDashboardSkeletonMode(tile._isSkeleton)
                    end
                end)
                tile:SetScript("OnClick", function()
                    if tile._isComingSoon then
                        ShowCopyURL(L["DASH_DISCORD"] or "Discord", "https://discord.com/invite/e7nW2f4VQj")
                    elseif tile._isSkeleton then
                        NavigateToModuleToggles()
                    else
                        f.OpenModule(name, moduleKey)
                    end
                end)

                return tile
            end

            -- Group logic (tiles and sidebar; refreshable for live module toggle updates)
            local dashboardTilePool = {}
            local function BuildMainTilesList()
                local out = {}
                local seen = {}
                tinsert(out, { name = moduleLabels.axis or "Axis", moduleKey = "axis", isSkeleton = false })
                tinsert(out, { name = moduleLabels.meridian or "Meridian", moduleKey = "meridian", isSkeleton = true, isComingSoon = true })
                for _, cat in ipairs(addon.OptionCategories) do
                    local mk = cat.moduleKey
                    if mk and not seen[mk] then
                        seen[mk] = true
                        local enabled = ShouldShowModuleOnDashboard(mk)
                        tinsert(out, {
                            name = moduleLabels[mk] or mk,
                            moduleKey = mk,
                            -- Disabled modules: same desaturated skeleton chrome + Module Toggles on click as preview modules.
                            isSkeleton = not enabled,
                        })
                    end
                end
                table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
                return out
            end

            -- Bento: Axis occupies column 0 rows 0–1 (same width as other tiles, two rows tall); others fill remaining cells in row-major order.
            local function RefreshDashboardTiles()
                local mainTiles = BuildMainTilesList()
                local TILE_W, TILE_H, TILE_GAP = DASH_HOME_TILE_W, DASH_HOME_TILE_H, DASH_HOME_TILE_GAP
                local STRIDE = TILE_W + TILE_GAP
                local COLS = DASH_HOME_TILE_COLS
                local TOP_Y = -152

                local gridOuterW = COLS * TILE_W + (COLS - 1) * TILE_GAP
                local gridHalfW = gridOuterW / 2

                local function CellCenterX(col)
                    return -gridHalfW + TILE_W / 2 + col * STRIDE
                end

                local function CellReservedForAxis(row, col)
                    return col == 0 and row <= 2
                end

                local axisInfo = nil
                local others = {}
                for _, info in ipairs(mainTiles) do
                    if info.moduleKey == "axis" then
                        axisInfo = info
                    else
                        others[#others + 1] = info
                    end
                end

                local slots = {}
                local maxScanRows = math.max(12, math.ceil((#others + 2) / 3) + 6)
                for row = 0, maxScanRows do
                    for col = 0, COLS - 1 do
                        if not CellReservedForAxis(row, col) then
                            slots[#slots + 1] = { r = row, c = col }
                            if #slots >= #others then
                                break
                            end
                        end
                    end
                    if #slots >= #others then
                        break
                    end
                end

                local function PlaceTile(tileInfo, centerX, topY)
                    local tile = dashboardTilePool[tileInfo.moduleKey]
                    if not tile then
                        tile = MakeTile(dashboardView, tileInfo.name, nil, tileInfo.moduleKey)
                        dashboardTilePool[tileInfo.moduleKey] = tile
                    end
                    if tile.label then tile.label:SetText(tileInfo.name) end
                    local tw, th = DashboardTileSizeForKey(tileInfo.moduleKey)
                    tile:SetSize(tw, th)
                    if tile.ApplyDashboardTileLayout then
                        tile.ApplyDashboardTileLayout(tile, th)
                    end
                    tile:ClearAllPoints()
                    tile:SetPoint("TOP", dashboardView, "TOP", centerX, topY)
                    tile._isComingSoon = tileInfo.isComingSoon and true or false
                    if tile.SetDashboardSkeletonMode then
                        tile:SetDashboardSkeletonMode(tileInfo.isSkeleton and true or false)
                    end
                    tile:Show()
                end

                if axisInfo then
                    PlaceTile(axisInfo, CellCenterX(0), TOP_Y)
                end

                for i = 1, #others do
                    local slot = slots[i]
                    if slot then
                        local topY = TOP_Y - slot.r * (TILE_H + TILE_GAP)
                        PlaceTile(others[i], CellCenterX(slot.c), topY)
                    end
                end

                local inKeys = {}
                if axisInfo then inKeys.axis = true end
                for _, info in ipairs(others) do
                    inKeys[info.moduleKey] = true
                end
                for mk, tile in pairs(dashboardTilePool) do
                    if not inKeys[mk] then tile:Hide() end
                end
            end

            RefreshDashboardTiles()

            -- Welcome tab (always in sidebar, above Home; dedicated view)
            do
                -- Search is hidden on Welcome; nudge card up to reclaim vertical space below the header band.
                local WELCOME_BG_TOP_NUDGE = 50
                local WELCOME_CONTENT_TOP_PAD = 6
                local WELCOME_ACC_HEAD_H = 48

                local welcomeBg = welcomeView:CreateTexture(nil, "BACKGROUND")
                welcomeBg:SetPoint("TOPLEFT", 28, dashScrollTopOffset + WELCOME_BG_TOP_NUDGE)
                -- Room for footer links only (bottom buttons removed)
                welcomeBg:SetPoint("BOTTOMRIGHT", welcomeView, "BOTTOMRIGHT", -28, 20)

                -- Scrollable body (title → modules); footer stays fixed so expanded accordions do not cover Community & Support.
                local footerPanel = CreateFrame("Frame", nil, welcomeView)
                footerPanel:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 10)

                local welcomeScroll = CreateFrame("ScrollFrame", nil, welcomeView, "UIPanelScrollFrameTemplate")
                welcomeScroll:SetFrameLevel((welcomeView:GetFrameLevel() or 0) + 2)
                welcomeScroll.ScrollBar:Hide()
                welcomeScroll.ScrollBar:ClearAllPoints()

                local content = CreateFrame("Frame", nil, welcomeScroll)
                content:SetSize(400, 1)
                welcomeScroll:SetScrollChild(content)
                ApplySmoothScroll(welcomeScroll, content, 60, true)

                -- Accordion aligned with detail-view section cards; calls onLayout during resize animation.
                local function CreateWelcomeAccordionCard(parent, titleText, onLayout)
                    local card = CreateFrame("Frame", nil, parent)
                    card:SetHeight(WELCOME_ACC_HEAD_H)
                    card.expanded = false
                    card.collapsedHeight = WELCOME_ACC_HEAD_H
                    card.fullHeight = WELCOME_ACC_HEAD_H
                    card:SetClipsChildren(true)

                    local cBg = card:CreateTexture(nil, "BACKGROUND")
                    cBg:SetAllPoints()
                    cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)

                    local divider = card:CreateTexture(nil, "ARTWORK")
                    divider:SetHeight(1)
                    divider:SetPoint("BOTTOMLEFT", 14, 0)
                    divider:SetPoint("BOTTOMRIGHT", -14, 0)
                    local cdr, cdg, cdb = GetAccentColor()
                    divider:SetColorTexture(cdr, cdg, cdb, 0.2)

                    local accent = card:CreateTexture(nil, "ARTWORK")
                    accent:SetSize(3, 20)
                    accent:SetPoint("TOPLEFT", 14, -14)
                    local cr, cg, cb = GetAccentColor()
                    accent:SetColorTexture(cr, cg, cb, 1)

                    local chevron = MakeText(card, "+", 14, 0.5, 0.5, 0.55, "RIGHT")
                    chevron:SetPoint("TOPRIGHT", -18, -17)

                    local lbl = MakeText(card, (titleText or ""):upper(), 13, 0.9, 0.9, 0.95, "LEFT")
                    lbl:SetPoint("TOPLEFT", 28, -16)

                    local headerBtn = CreateFrame("Button", nil, card)
                    headerBtn:SetPoint("TOPLEFT", 0, 0)
                    headerBtn:SetPoint("TOPRIGHT", 0, 0)
                    headerBtn:SetHeight(WELCOME_ACC_HEAD_H)
                    headerBtn:SetFrameLevel(card:GetFrameLevel() + 5)

                    local sc = CreateFrame("Frame", nil, card)
                    sc:SetPoint("TOPLEFT", 0, -WELCOME_ACC_HEAD_H)
                    sc:SetPoint("RIGHT", card, "RIGHT", 0, 0)
                    sc:SetHeight(1)
                    sc:SetAlpha(0)
                    card.settingsContainer = sc

                    local function updateExpandedVisuals()
                        if card.expanded then
                            cBg:SetColorTexture(SBgExpandedR, SBgExpandedG, SBgExpandedB, SBgA)
                            chevron:SetText("-")
                        else
                            cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
                            chevron:SetText("+")
                        end
                    end

                    headerBtn:SetScript("OnEnter", function()
                        if not card.expanded then
                            cBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, SBgA)
                        end
                    end)
                    headerBtn:SetScript("OnLeave", function()
                        if not card.expanded then
                            cBg:SetColorTexture(SBg[1], SBg[2], SBg[3], SBgA)
                        end
                    end)

                    card.anim = card:CreateAnimationGroup()
                    local sizeAnim = card.anim:CreateAnimation("Animation")
                    sizeAnim:SetDuration(0.15)
                    sizeAnim:SetSmoothing("IN_OUT")

                    card.anim:SetScript("OnUpdate", function()
                        local progress = sizeAnim:GetSmoothProgress()
                        local startH = card.expanded and card.collapsedHeight or (card.fullHeight or WELCOME_ACC_HEAD_H)
                        local endH = card.expanded and (card.fullHeight or WELCOME_ACC_HEAD_H) or card.collapsedHeight
                        local curH = startH + (endH - startH) * progress
                        card:SetHeight(curH)
                        if card.expanded then
                            sc:SetAlpha(progress)
                        else
                            sc:SetAlpha(1 - progress)
                        end
                        if onLayout then onLayout() end
                    end)

                    card.anim:SetScript("OnFinished", function()
                        local finalH = card.expanded and (card.fullHeight or WELCOME_ACC_HEAD_H) or card.collapsedHeight
                        card:SetHeight(finalH)
                        sc:SetAlpha(card.expanded and 1 or 0)
                        updateExpandedVisuals()
                        if onLayout then onLayout() end
                    end)

                    headerBtn:SetScript("OnClick", function()
                        if card.anim:IsPlaying() then return end
                        card.expanded = not card.expanded
                        updateExpandedVisuals()
                        card.anim:Play()
                    end)

                    return card
                end

                local function CreateWelcomeTextLink(parent, label, onClick, justify)
                    justify = justify or "CENTER"
                    local btn = CreateFrame("Button", nil, parent)
                    btn:SetSize(100, 20)
                    local lbl = MakeText(btn, label, 12, 0.52, 0.56, 0.62, justify)
                    lbl:ClearAllPoints()
                    if justify == "LEFT" then
                        lbl:SetPoint("LEFT", btn, "LEFT", 0, 0)
                        lbl:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
                    else
                        lbl:SetAllPoints()
                    end
                    btn.label = lbl
                    local underline = btn:CreateTexture(nil, "OVERLAY")
                    underline:SetHeight(1)
                    underline:SetPoint("BOTTOM", btn, "BOTTOM", 0, 0)
                    underline:SetPoint("LEFT", btn, "LEFT", 0, 0)
                    underline:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
                    underline:Hide()
                    btn.underline = underline
                    btn:SetScript("OnEnter", function()
                        lbl:SetTextColor(0.88, 0.90, 0.94)
                        local ar, ag, ab = GetAccentColor()
                        underline:SetColorTexture(ar, ag, ab, 0.6)
                        underline:Show()
                    end)
                    btn:SetScript("OnLeave", function()
                        lbl:SetTextColor(0.52, 0.56, 0.62)
                        underline:Hide()
                    end)
                    btn:SetScript("OnClick", onClick)
                    return btn
                end

                local LayoutWelcomeContent
                local contributorsCard = CreateWelcomeAccordionCard(content, L["DASH_WELCOME_CONTRIBUTORS_HEADING"] or "Contributors", function()
                    LayoutWelcomeContent()
                end)
                local contributorsBodyFs = MakeDashboardWelcomeMixedScriptText(contributorsCard.settingsContainer, L["DASH_WELCOME_CONTRIBUTORS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
                contributorsBodyFs:SetWordWrap(true)
                contributorsBodyFs:SetSpacing(4)

                local localisationsCard = CreateWelcomeAccordionCard(content, L["DASH_WELCOME_LOCALISATIONS_HEADING"] or "Localisations", function()
                    LayoutWelcomeContent()
                end)
                local localisationsBodyFs = MakeDashboardWelcomeMixedScriptText(localisationsCard.settingsContainer, L["DASH_WELCOME_LOCALISATIONS_BODY"] or "", 12, 0.62, 0.65, 0.70, "LEFT")
                localisationsBodyFs:SetWordWrap(true)
                localisationsBodyFs:SetSpacing(4)

                local titleFs = MakeText(content, L["DASH_WELCOME_TITLE"] or "Welcome to Horizon Suite", 22, 1, 1, 1, "LEFT")

                local introFs = MakeText(content, L["DASH_WELCOME_INTRO"] or "", 13, 0.72, 0.74, 0.78, "LEFT")
                introFs:SetWordWrap(true)
                introFs:SetSpacing(4)

                local modulesHdr = MakeText(content, (L["DASH_WELCOME_MODULES_HEADING"] or "Modules"), 16, 0.88, 0.90, 0.94, "LEFT")

                local listRule = content:CreateTexture(nil, "ARTWORK")
                listRule:SetHeight(1)
                listRule:SetColorTexture(0.22, 0.24, 0.30, 0.85)

                local function DismissWelcomeAndOpenModuleToggles()
                    if addon.SetDB then addon.SetDB("dashboardWelcomeSeen", true) end
                    NavigateToModuleToggles()
                end

                local btnOpenModuleToggles = CreateWelcomeTextLink(content, L["DASH_WELCOME_OPEN_MODULE_TOGGLES_LINK"] or "Open module toggles", DismissWelcomeAndOpenModuleToggles, "LEFT")

                local modRows = {
                    { key = "axis", name = BrandModule("axis") or "Axis", desc = L["DASH_AXIS_MODULE_SHORT_DESCRIPTION"] or "Core settings hub: profiles, modules, and global toggles." },
                    { key = "focus", name = BrandModule("focus"), desc = L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"] or "" },
                    { key = "presence", name = BrandModule("presence"), desc = L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"] or "" },
                    { key = "vista", name = BrandModule("vista"), desc = L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"] or "Minimap with zone text, coords, time, and button collector." },
                    { key = "insight", name = BrandModule("insight"), desc = L["DASH_TOOLTIPS_CLASS_COLORS_SPEC_FACTION"] or "" },
                    { key = "cache", name = BrandModule("cache"), desc = L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"] or "" },
                    { key = "essence", name = BrandModule("essence"), desc = L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"] or "Custom character sheet with 3D model, item level, stats, and gear grid." },
                    { key = "meridian", name = BrandModule("meridian"), desc = L["DASH_MERIDIAN_MODULE_SHORT_DESCRIPTION"] or "Join the Discord and have a guess!" },
                }
                local moduleLineWidgets = {}
                for _, row in ipairs(modRows) do
                    local nm = row.name
                    if PREVIEW_MODULE_KEYS[row.key] then
                        nm = nm .. " |cff228b22(" .. (L["OPTIONS_PRESENCE_PREVIEW"] or "Preview") .. ")|r"
                    elseif COMING_SOON_MODULE_KEYS[row.key] then
                        nm = nm .. " |cff8cb2e6(" .. (L["OPTIONS_CORE_COMING_SOON"] or "Coming Soon") .. ")|r"
                    end
                    local nameFs = MakeText(content, nm, 14, 0.96, 0.97, 1, "LEFT")
                    nameFs:SetWordWrap(true)
                    local descFs = MakeText(content, row.desc, 12, 0.52, 0.56, 0.62, "LEFT")
                    descFs:SetWordWrap(true)
                    descFs:SetSpacing(3)
                    tinsert(moduleLineWidgets, { nameFs = nameFs, descFs = descFs })
                end

                -- Footer: Community & Support + external links (copy URL)
                local footerTopRule = footerPanel:CreateTexture(nil, "ARTWORK")
                footerTopRule:SetHeight(1)
                footerTopRule:SetColorTexture(0.22, 0.24, 0.30, 0.85)

                local communityHdr = MakeText(footerPanel, L["DASH_WELCOME_COMMUNITY_HEADING"] or "Community & Support", 14, 0.52, 0.56, 0.62, "LEFT")

                local linkData = {
                    { label = L["DASH_DISCORD"] or "Discord", url = "https://discord.com/invite/e7nW2f4VQj" },
                    { label = L["DASH_KO_FI"] or "Ko-fi", url = "https://ko-fi.com/horizonsuite" },
                    { label = L["DASH_PATREON"] or "Patreon", url = "https://patreon.com/HorizonSuite" },
                    { label = L["DASH_GITLAB"] or "GitLab", url = "https://gitlab.com/Crystilac/horizon-suite" },
                    { label = L["DASH_CURSEFORGE"] or "CurseForge", url = "https://www.curseforge.com/projects/1457844" },
                    { label = L["DASH_WAGO"] or "Wago", url = "https://addons.wago.io/addons/jK8gY56y" },
                }

                local linkButtons = {}
                for _, link in ipairs(linkData) do
                    local btn = CreateWelcomeTextLink(footerPanel, link.label, function()
                        ShowCopyURL(link.label, link.url)
                    end)
                    tinsert(linkButtons, btn)
                end

                LayoutWelcomeContent = function()
                    local rawW = welcomeBg:GetWidth() or 0
                    local w = math.max(280, rawW - 40)
                    local innerPad = 28

                    -- --- Footer (bottom of card) ---
                    local fy = 0
                    footerTopRule:ClearAllPoints()
                    footerTopRule:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", 0, -fy)
                    footerTopRule:SetPoint("TOPRIGHT", footerPanel, "TOPRIGHT", 0, -fy)
                    fy = fy + 1 + 12

                    communityHdr:SetWidth(w)
                    communityHdr:ClearAllPoints()
                    communityHdr:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", 0, -fy)
                    fy = fy + communityHdr:GetHeight() + 8

                    local linkBtnW = 82
                    local linkGap = 10
                    local totalLinkWidth = (#linkButtons * linkBtnW) + ((#linkButtons - 1) * linkGap)
                    local linkRowX = math.max(0, (w - totalLinkWidth) / 2)

                    for i, btn in ipairs(linkButtons) do
                        btn:SetWidth(linkBtnW)
                        btn:ClearAllPoints()
                        btn:SetPoint("TOPLEFT", footerPanel, "TOPLEFT", linkRowX + (i - 1) * (linkBtnW + linkGap), -fy)
                    end
                    fy = fy + 20

                    footerPanel:SetWidth(w)
                    footerPanel:SetHeight(math.max(fy + 4, 1))
                    footerPanel:ClearAllPoints()
                    footerPanel:SetPoint("BOTTOMLEFT", welcomeBg, "BOTTOMLEFT", 20, 14)
                    footerPanel:SetPoint("BOTTOMRIGHT", welcomeBg, "BOTTOMRIGHT", -20, 14)

                    local WELCOME_SCROLL_ABOVE_FOOTER_GAP = 10
                    welcomeScroll:ClearAllPoints()
                    welcomeScroll:SetPoint("TOPLEFT", welcomeBg, "TOPLEFT", 20, -WELCOME_CONTENT_TOP_PAD)
                    welcomeScroll:SetPoint("BOTTOMLEFT", footerPanel, "TOPLEFT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)
                    welcomeScroll:SetPoint("TOPRIGHT", welcomeBg, "TOPRIGHT", -20, -WELCOME_CONTENT_TOP_PAD)
                    welcomeScroll:SetPoint("BOTTOMRIGHT", footerPanel, "TOPRIGHT", 0, WELCOME_SCROLL_ABOVE_FOOTER_GAP)

                    -- --- Body (scroll child; height may exceed viewport) ---
                    content:SetWidth(w)
                    local y = 0
                    titleFs:SetWidth(w)
                    titleFs:ClearAllPoints()
                    titleFs:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + titleFs:GetHeight() + 12
                    introFs:SetWidth(w)
                    introFs:ClearAllPoints()
                    introFs:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + introFs:GetHeight() + 12

                    contributorsBodyFs:ClearAllPoints()
                    contributorsBodyFs:SetPoint("TOPLEFT", contributorsCard.settingsContainer, "TOPLEFT", innerPad, -10)
                    contributorsBodyFs:SetPoint("TOPRIGHT", contributorsCard.settingsContainer, "TOPRIGHT", -innerPad, -10)
                    local contribBodyH = contributorsBodyFs:GetHeight()
                    contributorsCard.fullHeight = WELCOME_ACC_HEAD_H + 10 + contribBodyH + 14
                    if not contributorsCard.anim:IsPlaying() then
                        if contributorsCard.expanded then
                            contributorsCard:SetHeight(contributorsCard.fullHeight)
                        else
                            contributorsCard:SetHeight(contributorsCard.collapsedHeight)
                        end
                    end
                    contributorsCard:SetWidth(w)
                    contributorsCard:ClearAllPoints()
                    contributorsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + contributorsCard:GetHeight() + 8

                    localisationsBodyFs:ClearAllPoints()
                    localisationsBodyFs:SetPoint("TOPLEFT", localisationsCard.settingsContainer, "TOPLEFT", innerPad, -10)
                    localisationsBodyFs:SetPoint("TOPRIGHT", localisationsCard.settingsContainer, "TOPRIGHT", -innerPad, -10)
                    local locBodyH = localisationsBodyFs:GetHeight()
                    localisationsCard.fullHeight = WELCOME_ACC_HEAD_H + 10 + locBodyH + 14
                    if not localisationsCard.anim:IsPlaying() then
                        if localisationsCard.expanded then
                            localisationsCard:SetHeight(localisationsCard.fullHeight)
                        else
                            localisationsCard:SetHeight(localisationsCard.collapsedHeight)
                        end
                    end
                    localisationsCard:SetWidth(w)
                    localisationsCard:ClearAllPoints()
                    localisationsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + localisationsCard:GetHeight() + 16

                    modulesHdr:SetWidth(w)
                    modulesHdr:ClearAllPoints()
                    modulesHdr:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + modulesHdr:GetHeight() + 8
                    listRule:ClearAllPoints()
                    listRule:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    listRule:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
                    y = y + 10

                    local togglesLabel = L["DASH_WELCOME_OPEN_MODULE_TOGGLES_LINK"] or "Open module toggles"
                    btnOpenModuleToggles.label:SetText(togglesLabel)
                    local tw = btnOpenModuleToggles.label:GetStringWidth() or 120
                    btnOpenModuleToggles:SetSize(math.min(w, math.floor(tw) + 12), 20)
                    btnOpenModuleToggles:ClearAllPoints()
                    btnOpenModuleToggles:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
                    y = y + btnOpenModuleToggles:GetHeight() + 12

                    local colGap = 32
                    local colW = math.floor((w - colGap) / 2)
                    local leftX, rightX = 4, colW + colGap + 4
                    local leftY, rightY = y, y

                    for i, pair in ipairs(moduleLineWidgets) do
                        local nameFs, descFs = pair.nameFs, pair.descFs
                        local isRight = i > 4
                        local colX = isRight and rightX or leftX
                        local colRef = isRight and rightY or leftY

                        nameFs:SetWidth(colW - 4)
                        nameFs:ClearAllPoints()
                        nameFs:SetPoint("TOPLEFT", content, "TOPLEFT", colX, -colRef)
                        local nameH = nameFs:GetHeight()

                        descFs:SetWidth(colW - 16)
                        descFs:ClearAllPoints()
                        descFs:SetPoint("TOPLEFT", content, "TOPLEFT", colX + 8, -(colRef + nameH + 4))
                        local descH = descFs:GetHeight()

                        if isRight then
                            rightY = rightY + nameH + 4 + descH + 14
                        else
                            leftY = leftY + nameH + 4 + descH + 14
                        end
                    end

                    y = math.max(leftY, rightY)
                    content:SetHeight(math.max(y + 8, 1))

                    if welcomeScroll.UpdateScrollChildRect then
                        welcomeScroll:UpdateScrollChildRect()
                    end
                    local viewH = welcomeScroll:GetHeight() or 0
                    local contentH = content:GetHeight() or 0
                    local maxScroll = math.max(0, contentH - viewH)
                    local curScroll = welcomeScroll:GetVerticalScroll() or 0
                    if curScroll > maxScroll then
                        welcomeScroll:SetVerticalScroll(maxScroll)
                        welcomeScroll.targetScroll = nil
                    end
                end

                welcomeView:SetScript("OnShow", function()
                    LayoutWelcomeContent()
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0, LayoutWelcomeContent)
                    end
                end)
                welcomeView:SetScript("OnSizeChanged", function()
                    if welcomeView:IsShown() then LayoutWelcomeContent() end
                end)

                f.ShowWelcome = function()
                    HideContextHeader()
                    detailView:Hide()
                    subCategoryView:Hide()
                    dashboardView:Hide()
                    patchNotesView:Hide()
                    welcomeView:SetAlpha(0)
                    welcomeView:Show()
                    UIFrameFadeIn(welcomeView, 0.2, 0, 1)
                    if head then head:Show() end
                    if headSub then
                        headSub:Show()
                        headSub:SetText(L["DASH_WELCOME_HEAD_SUB"] or "What each module does and where to turn them on")
                    end
                    if searchBox then searchBox:Hide() end
                    f.currentModuleKey = nil
                    SetSidebarState({ view = "welcome", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                    if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                        addon.DashboardPreview.SetActiveModuleKey(nil)
                    end
                    if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
                end
            end

            f.ShowPatchNotes = function()
                HideContextHeader()
                detailView:Hide()
                subCategoryView:Hide()
                dashboardView:Hide()
                welcomeView:Hide()
                patchNotesView:SetAlpha(0)
                patchNotesView:Show()
                UIFrameFadeIn(patchNotesView, 0.2, 0, 1)
                if head then head:Show() end
                if headSub then
                    headSub:Show()
                    headSub:SetText("Release history and recent changes")
                end
                if searchBox then searchBox:Hide() end

                local gm = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
                local ver = (gm and gm(addon.ADDON_NAME or "HorizonSuite", "Version")) or ""
                local notes = addon.PATCH_NOTES
                local targetVer = ver ~= "" and ver or (notes and next(notes) or "")
                if pnBuiltVersion ~= targetVer then
                    BuildPatchNotesContent(targetVer)
                end

                detailTitle:SetText("WHAT'S NEW" .. (ver ~= "" and ("  |cFF888899v"..ver.."|r") or ""))
                detailTitle:Show()
                detailTitleUnderline:Show()

                f.currentModuleKey = nil
                SetSidebarState({ view = "whatsnew", activeModuleKey = CLEAR, activeCategoryIndex = CLEAR })
                if addon.DashboardPreview and addon.DashboardPreview.SetActiveModuleKey then
                    addon.DashboardPreview.SetActiveModuleKey(nil)
                end
                if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
            end

            -- ===== POPULATE SIDEBAR =====
            -- Group categories by moduleKey; build all groups so we can show/hide on refresh.
            local MODULE_LABELS = { ["axis"] = BrandModule("axis") or "Axis", ["modules"] = L["OPTIONS_AXIS_MODULES"] or "Modules", ["focus"] = BrandModule("focus"), ["presence"] = BrandModule("presence"), ["insight"] = BrandModule("insight"), ["cache"] = BrandModule("cache"), ["vista"] = BrandModule("vista"), ["essence"] = BrandModule("essence"), ["meridian"] = BrandModule("meridian") }
            local groups = {}
            for i, cat in ipairs(addon.OptionCategories) do
                local mk
                if OptionCategoryKeyIsAxis(cat.key) then
                    mk = "axis"
                else
                    mk = cat.moduleKey or "modules"
                end
                if not groups[mk] then groups[mk] = { label = MODULE_LABELS[mk] or L["OPTIONS_FOCUS_OTHER"], categories = {} } end
                tinsert(groups[mk].categories, i)
            end
            local groupOrder = { "axis", "focus", "insight", "essence", "presence", "vista", "cache" }
            local sidebarRows = {}

            local lastSidebarRow = nil
            local yOff = 0

            -- Welcome (first row — overview for new and returning users)
            local welcomeBtn = CreateSidebarButton(sidebarScrollContent, L["DASH_WELCOME_TAB"] or "Welcome", "INV_Misc_Book_09", function()
                if f.ShowWelcome then f.ShowWelcome() end
            end)
            welcomeBtn:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -SIDEBAR_TOP_PAD)
            f.welcomeSidebarBtn = welcomeBtn
            tinsert(sidebarButtons, welcomeBtn)
            tinsert(sidebarRows, { type = "welcome", frame = welcomeBtn, bottom = welcomeBtn, offsetFromPrev = -SIDEBAR_TOP_PAD })
            lastSidebarRow = welcomeBtn
            yOff = SIDEBAR_TOP_PAD + TAB_ROW_HEIGHT

            -- Home
            local homeBtn = CreateSidebarButton(sidebarScrollContent, "Home", "INV_Misc_Map_01", function()
                f.ShowDashboard()
            end)
            homeBtn:SetPoint("TOPLEFT", welcomeBtn, "BOTTOMLEFT", 0, 0)
            f.homeSidebarBtn = homeBtn
            tinsert(sidebarButtons, homeBtn)
            tinsert(sidebarRows, { type = "home", frame = homeBtn, bottom = homeBtn, offsetFromPrev = 0 })
            lastSidebarRow = homeBtn
            yOff = yOff + TAB_ROW_HEIGHT

            -- Separator (anchored to sep row; reflows with RefreshSidebar)
            yOff = yOff + 9
            lastSidebarRow = CreateFrame("Frame", nil, sidebarScrollContent)
            lastSidebarRow:SetPoint("TOPLEFT", sidebarScrollContent, "TOPLEFT", 0, -yOff)
            lastSidebarRow:SetSize(1, 1)
            local sbSep = sidebarScrollContent:CreateTexture(nil, "ARTWORK")
            sbSep:SetHeight(1)
            sbSep:SetPoint("BOTTOMLEFT", lastSidebarRow, "TOPLEFT", 15, 8)
            sbSep:SetPoint("BOTTOMRIGHT", lastSidebarRow, "TOPRIGHT", -15, 8)
            sbSep:SetColorTexture(0.15, 0.15, 0.2, 1)
            tinsert(sidebarRows, { type = "sep", frame = lastSidebarRow, bottom = lastSidebarRow, offsetFromPrev = -9 })

            -- Per-group: standalone (single category) or header + collapsible sub-buttons
            for _, mk in ipairs(groupOrder) do
                local g = groups[mk]
                if not g or #g.categories == 0 then
                    -- skip empty groups
                else
                    local isStandalone = (mk == "modules" and #g.categories == 1)
                    local modName = MODULE_LABELS[mk] or mk

                    if isStandalone then
                        local catIdx = g.categories[1]
                        local cat = addon.OptionCategories[catIdx]
                        local iconKey = categoryIcons[cat.key] or "INV_Misc_Question_01"
                        local btn = CreateSidebarButton(sidebarScrollContent, cat.name, iconKey, function()
                            f.OpenModule(cat.name, cat.moduleKey)
                        end)
                        btn:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0)
                        lastSidebarRow = btn
                        yOff = yOff + TAB_ROW_HEIGHT
                        btn.sidebarModuleKey = cat.moduleKey
                        btn.sidebarName = cat.name
                        btn.sidebarCategoryIndex = catIdx
                        btn:SetShown(ShouldShowModuleOnDashboard(mk))
                        g.row = { type = "group", mk = mk, frame = btn, bottom = btn, offsetFromPrev = 0 }
                        tinsert(sidebarRows, g.row)
                        tinsert(sidebarButtons, btn)
                    else
                        -- Header row (clickable, collapsible)
                        local prevLastRow = lastSidebarRow
                        local header = CreateFrame("Button", nil, sidebarScrollContent)
                        header:SetSize(SIDEBAR_WIDTH - 1, HEADER_ROW_HEIGHT)
                        header:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0)
                        lastSidebarRow = header
                        yOff = yOff + HEADER_ROW_HEIGHT
                        header.groupKey = mk
                        g.header = header
                        header.hoverBg = header:CreateTexture(nil, "BACKGROUND")
                        header.hoverBg:SetAllPoints(header)
                        header.hoverBg:SetColorTexture(1, 1, 1, 0.03)
                        header.hoverBg:Hide()
                        local chevron = header:CreateFontString(nil, "OVERLAY")
                        chevron:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
                        chevron:SetPoint("LEFT", header, "LEFT", 8, 0)
                        chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                        header.chevron = chevron
                        local headerLabel = header:CreateFontString(nil, "OVERLAY")
                        headerLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                        headerLabel:SetPoint("LEFT", chevron, "RIGHT", 4, 0)
                        headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                        local headerLabelText = (g.label or ""):upper()
                        if PREVIEW_MODULE_KEYS[mk] then
                            headerLabelText = headerLabelText .. " |cff228b22(Preview)|r"
                        end
                        headerLabel:SetText(headerLabelText)
                        header.headerLabel = headerLabel

                        local tabsContainer = CreateFrame("Frame", nil, sidebarScrollContent)
                        tabsContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
                        tabsContainer:SetWidth(SIDEBAR_WIDTH - 1)
                        tabsContainer:SetClipsChildren(true)
                        local fullHeight = TAB_ROW_HEIGHT * #g.categories
                        local startCollapsed = GetGroupCollapsed(mk)
                        tabsContainer:SetHeight(startCollapsed and 0 or fullHeight)
                        g.tabsContainer = tabsContainer
                        g.fullHeight = fullHeight

                        local spacer = CreateFrame("Frame", nil, sidebarScrollContent)
                        spacer:SetSize(2, 2)
                        spacer:SetAlpha(0)
                        local function UpdateSpacerPosition()
                            spacer:ClearAllPoints()
                            spacer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -tabsContainer:GetHeight())
                        end
                        header.updateSpacer = UpdateSpacerPosition
                        UpdateSpacerPosition()
                        lastSidebarRow = spacer
                        yOff = yOff + tabsContainer:GetHeight()

                        local show = ShouldShowModuleOnDashboard(mk)
                        header:SetShown(show)
                        tabsContainer:SetShown(show)
                        spacer:SetShown(show)
                        if not show then lastSidebarRow = prevLastRow end
                        g.row = { type = "group", mk = mk, header = header, tabsContainer = tabsContainer, spacer = spacer, bottom = spacer, offsetFromPrev = 0 }
                        tinsert(sidebarRows, g.row)

                        header:SetScript("OnClick", function()
                            RequestGroupToggle(mk)
                        end)
                        header:SetScript("OnEnter", function()
                            header.hoverBg:Show()
                            headerLabel:SetTextColor(0.8, 0.8, 0.85, 1)
                            chevron:SetTextColor(0.8, 0.8, 0.85, 1)
                        end)
                        header:SetScript("OnLeave", function()
                            header.hoverBg:Hide()
                            headerLabel:SetTextColor(0.55, 0.55, 0.65, 1)
                            chevron:SetTextColor(0.55, 0.55, 0.65, 1)
                        end)
                        chevron:SetText(GetGroupCollapsed(mk) and "+" or "-")

                        local containerAnchor = tabsContainer
                        for _, catIdx in ipairs(g.categories) do
                            local cat = addon.OptionCategories[catIdx]
                            local modLabel = moduleLabels[mk] or (cat.moduleKey and (moduleLabels[cat.moduleKey] or cat.moduleKey)) or modName
                            local catMk = (mk == "axis") and "axis" or cat.moduleKey
                            local btn = CreateSidebarButton(tabsContainer, cat.name, nil, function()
                                f.OpenModule(modLabel, catMk, true)
                                local options = type(cat.options) == "function" and cat.options() or cat.options
                                f.OpenCategoryDetail(modLabel, cat.name, options)
                            end, 12)
                            btn:SetPoint("TOPLEFT", containerAnchor, (containerAnchor == tabsContainer) and "TOPLEFT" or "BOTTOMLEFT", 0, 0)
                            containerAnchor = btn
                            btn.sidebarModuleKey = catMk
                            btn.sidebarName = cat.name
                            btn.sidebarCategoryIndex = catIdx
                            tinsert(sidebarButtons, btn)
                        end

                        if startCollapsed then
                            SetGroupChildrenShown(g, false)
                        end
                    end
                end
            end

            -- What's New: pinned to sidebar bottom (outside scroll; see SIDEBAR_WHATSNEW_RESERVE)
            do
                local wnBtn = CreateSidebarButton(sidebar, "What's New", "INV_Scroll_05", function()
                    if f.ShowPatchNotes then f.ShowPatchNotes() end
                end)
                wnBtn:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 0, 10)
                wnBtn:SetFrameLevel(sidebarScrollFrame:GetFrameLevel() + 1)
                tinsert(sidebarButtons, wnBtn)
                f.whatsnewSidebarBtn = wnBtn
            end

            --- Reflow sidebar scroll content height from top to last row.
            local function LayoutSidebar()
                if not sidebarScrollContent or not lastSidebarRow then return end
                local top = sidebarScrollContent:GetTop()
                local bottom = lastSidebarRow:GetBottom()
                if top and bottom then
                    local h = math.max(1, top - bottom + SIDEBAR_TOP_PAD)
                    sidebarScrollContent:SetHeight(h)
                end
            end

            --- Apply sidebarState to UI: active button, expanded groups, spacers.
            local function ApplySidebarState()
                local targetMk = sidebarState.view ~= "dashboard" and sidebarState.activeModuleKey or nil
                for _, mk in ipairs(groupOrder) do
                    local g = groups[mk]
                    if g and g.tabsContainer and g.fullHeight then
                        if targetMk and mk == targetMk then
                            SetGroupCollapsed(mk, false)
                            g.tabsContainer:SetScript("OnUpdate", nil)
                            g.tabsContainer:SetHeight(g.fullHeight)
                            SetGroupChildrenShown(g, true)
                            if g.header and g.header.chevron then g.header.chevron:SetText("-") end
                        elseif not GetGroupCollapsed(mk) then
                            SetGroupCollapsed(mk, true)
                            g.tabsContainer:SetScript("OnUpdate", nil)
                            g.tabsContainer:SetHeight(0)
                            SetGroupChildrenShown(g, false)
                            if g.header and g.header.chevron then g.header.chevron:SetText("+") end
                        end
                        if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                    end
                end
                local activeBtn = f.homeSidebarBtn or sidebarButtons[1]
                if sidebarState.view == "welcome" and f.welcomeSidebarBtn then
                    activeBtn = f.welcomeSidebarBtn
                elseif sidebarState.view == "whatsnew" and f.whatsnewSidebarBtn then
                    activeBtn = f.whatsnewSidebarBtn
                elseif sidebarState.view == "module" or sidebarState.view == "category" then
                    local mk = sidebarState.activeModuleKey or "modules"
                    local wantCatIdx = sidebarState.activeCategoryIndex
                    for _, sb in ipairs(sidebarButtons) do
                        if sb.sidebarCategoryIndex then
                            local sbMk = sb.sidebarModuleKey or "modules"
                            if sbMk == mk then
                                if wantCatIdx and sb.sidebarCategoryIndex == wantCatIdx then
                                    activeBtn = sb
                                    break
                                elseif not wantCatIdx then
                                    activeBtn = sb
                                    break
                                end
                            end
                        end
                    end
                end
                SetActiveSidebarButton(activeBtn)
                LayoutSidebar()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() LayoutSidebar() end)
                end
            end

            --- Update sidebar state and apply to UI. Single entry point for navigation.
            --- @param state table { view?, activeModuleKey?, activeCategoryIndex? }
            --- Use CLEAR to explicitly clear a field; omit keys to leave unchanged.
            SetSidebarState = function(state)
                if state.view then sidebarState.view = state.view end
                if state.activeModuleKey == CLEAR then sidebarState.activeModuleKey = nil
                elseif state.activeModuleKey ~= nil then sidebarState.activeModuleKey = state.activeModuleKey end
                if state.activeCategoryIndex == CLEAR then sidebarState.activeCategoryIndex = nil
                elseif state.activeCategoryIndex ~= nil then sidebarState.activeCategoryIndex = state.activeCategoryIndex end
                ApplySidebarState()
            end

            --- Refresh sidebar visibility and reflow when modules are toggled.
            local function RefreshSidebar()
                for _, row in ipairs(sidebarRows) do
                    if row.type == "group" and row.mk then
                        local show = ShouldShowModuleOnDashboard(row.mk)
                        if row.frame then
                            row.frame:SetShown(show)
                        elseif row.header then
                            row.header:SetShown(show)
                            row.tabsContainer:SetShown(show)
                            row.spacer:SetShown(show)
                        end
                        row._visible = show
                    else
                        row._visible = true
                    end
                end
                local prev = sidebarScrollContent
                for _, row in ipairs(sidebarRows) do
                    if not row._visible then
                        -- skip hidden rows
                    else
                        local topFrame = row.frame or row.header
                        local bottomFrame = row.bottom
                        local off = row.offsetFromPrev or 0
                        if topFrame and bottomFrame then
                            topFrame:ClearAllPoints()
                            if prev == sidebarScrollContent then
                                topFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, off)
                            else
                                topFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, off)
                            end
                            prev = bottomFrame
                        end
                    end
                end
                lastSidebarRow = prev
                LayoutSidebar()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0, function() LayoutSidebar() end)
                end
            end

            --- Live refresh when modules are toggled (called from SetModuleEnabled).
            addon.Dashboard_Refresh = function()
                if not f or not f:IsShown() then return end
                RefreshDashboardTiles()
                RefreshSidebar()
                if sidebarState.view == "dashboard" and sidebarState.activeModuleKey and not ShouldShowModuleOnDashboard(sidebarState.activeModuleKey) then
                    f.ShowDashboard()
                end
            end

            --- Toggle a group's collapse state (user header click). Persists and animates.
            RequestGroupToggle = function(mk)
                local g = groups[mk]
                if not g or not g.tabsContainer or not g.fullHeight then return end
                local collapsed = not GetGroupCollapsed(mk)
                SetGroupCollapsed(mk, collapsed)
                if g.header and g.header.chevron then g.header.chevron:SetText(collapsed and "+" or "-") end
                local fromH = g.tabsContainer:GetHeight()
                local toH = collapsed and 0 or g.fullHeight
                if fromH ~= toH then
                    g.tabsContainer.animStart = GetTime()
                    g.tabsContainer.animFrom = fromH
                    g.tabsContainer.animTo = toH
                    g.tabsContainer:SetScript("OnUpdate", function(self)
                        local elapsed = GetTime() - self.animStart
                        local t = math.min(elapsed / COLLAPSE_ANIM_DUR, 1)
                        local h = self.animFrom + (self.animTo - self.animFrom) * easeOut(t)
                        self:SetHeight(math.max(0, h))
                        if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                        LayoutSidebar()
                        if t >= 1 then
                            self:SetScript("OnUpdate", nil)
                            if collapsed then
                                SetGroupChildrenShown(g, false)
                            else
                                SetGroupChildrenShown(g, true)
                            end
                        end
                    end)
                else
                    if collapsed then
                        SetGroupChildrenShown(g, false)
                    else
                        SetGroupChildrenShown(g, true)
                    end
                    if g.header and g.header.updateSpacer then g.header.updateSpacer() end
                    LayoutSidebar()
                end
            end

            LayoutSidebar()
            RefreshSidebar()
        end
        if f and f.ShowDashboard and f.ShowWelcome then
            if addon.GetDB and not addon.GetDB("dashboardWelcomeSeen", false) then
                f.ShowWelcome()
            else
                f.ShowDashboard()
            end
        elseif f and f.ShowDashboard then
            f.ShowDashboard()
        end
        if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
        if addon.DashboardPreview and addon.DashboardPreview.InitDashboard then
            addon.DashboardPreview.InitDashboard(f)
        end
        f:Show()
    end
end

