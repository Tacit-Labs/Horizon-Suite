--[[
    Horizon Suite - Dashboard full-bleed background (solid + themed art, crossfade).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

-- Dashboard background: Minimalistic (horizon) = solid only. Default theme = Midnight (addon PNG). Talents = Blizzard class-talent atlas for current spec.
local DASHBOARD_BG_MEDIA_PATH = "Interface\\AddOns\\HorizonSuite\\media\\dashboard\\"
-- Full-bleed background: solid + art stack. Solid alpha adjusts dynamically so Minimalistic/horizon (solid-only)
-- stays dark and readable, while Midnight/Specialisation (solid + art) lets the world peek through.
-- Art alpha is user-configurable via dashboardBackgroundOpacity (50–100%, stored as integer, default 90).
local DASHBOARD_BG_SOLID_ALPHA_BARE = 0.88      -- used when NO art layer is showing (Minimalistic/horizon)
local DASHBOARD_BG_SOLID_ALPHA_WITH_ART = 0.25  -- under themed art; kept low so art+solid don't compound to fully opaque
local DASHBOARD_BG_ART_ALPHA_DEFAULT = 0.90     -- fallback before DB is available

local function GetDashboardBgArtAlpha()
    if addon.GetDB then
        local pct = tonumber(addon.GetDB("dashboardBackgroundOpacity", 90)) or 90
        return math.max(0.50, math.min(1.0, pct / 100))
    end
    return DASHBOARD_BG_ART_ALPHA_DEFAULT
end

local DASHBOARD_BG_CROSSFADE_SEC = 0.4
-- Theme id -> path under media/dashboard/ (SetTexture; PNG/JPEG per client support).
local DASHBOARD_BG_FILES = {
    midnight = "backgrounds\\Wow-Midnight.jpg",
    teldrassilburns = "backgrounds\\TeldrassilBurns.jpg",
    nightfae = "backgrounds\\Nightfae.jpg",
    ardenweald = "backgrounds\\Ardenweald.jpg",
    zinazshari = "backgrounds\\Zin-Azshari.jpg",
    suramargarden = "backgrounds\\SuramarGarden.jpg",
    quelthalas = "backgrounds\\QuelThalas.jpg",
    twilightvineyards = "backgrounds\\TwilightVineyards.jpg",
    zulaman = "backgrounds\\ZulAman.jpg",
    illidan = "backgrounds\\Illidan.jpg",
    tbcanniversary = "backgrounds\\TBCAnniversary.jpg",
    lichking = "backgrounds\\LichKing.jpg",
    beledarslight = "backgrounds\\BeledarsLight.jpg",
}
local DASHBOARD_BG_ORDER = {
    "horizon",
    "midnight",
    "teldrassilburns",
    "quelthalas",
    "nightfae",
    "ardenweald",
    "zinazshari",
    "suramargarden",
    "twilightvineyards",
    "zulaman",
    "illidan",
    "tbcanniversary",
    "lichking",
    "beledarslight",
    "talents",
}
addon.DashboardBackgroundThemeOrder = DASHBOARD_BG_ORDER

local function NormalizeDashboardThemeId(themeId)
    if themeId == "horizon" then
        return "horizon"
    end
    if themeId == "talents" then
        return "talents"
    end
    -- Legacy id when Teldrassil.jpg was a separate preset; same art folder as TeldrassilBurns.jpg.
    if themeId == "teldrassil" then
        return "teldrassilburns"
    end
    if type(themeId) == "string" and DASHBOARD_BG_FILES[themeId] then
        return themeId
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
    local rel = type(themeId) == "string" and DASHBOARD_BG_FILES[themeId]
    if type(rel) == "string" and rel ~= "" then
        local path = DASHBOARD_BG_MEDIA_PATH .. rel
        return { kind = "texture", path = path, signature = themeId .. ":" .. path }
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

--- Solid layer alpha when creating the dashboard frame (no art yet) or when matching bare/art modes.
--- @param hasArt boolean
--- @return number
function addon.Dashboard_GetBgSolidAlpha(hasArt)
    return GetDashboardBgSolidAlpha(hasArt)
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

--- Apply saved dashboard background theme to the dashboard frame (if it exists).
--- Crossfades between image themes when the dashboard is visible; snaps when hidden or on first apply.
--- @return nil
function addon.ApplyDashboardBackground()
    local dash = _G.HorizonSuiteDashboard
    local L1, L2 = dash and dash._dashboardBgArt1, dash and dash._dashboardBgArt2
    if not dash or not L1 or not L2 then
        return
    end
    local raw = (addon.GetDB and addon.GetDB("dashboardBackgroundTheme", "midnight")) or "midnight"
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
