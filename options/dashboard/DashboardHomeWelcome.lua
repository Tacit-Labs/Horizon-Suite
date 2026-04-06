--[[
    Horizon Suite - Dashboard home grid and module tiles; Welcome tab lives in DashboardWelcomeView.lua.
    Wired from DashboardFrame.lua via addon.DashboardHomeWelcome_Init(env).
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local tinsert = table.insert

--- @param env table
--- @return table { RefreshDashboardTiles = function }
function addon.DashboardHomeWelcome_Init(env)
    local f = env.f
    local addon = env.addon
    local L = env.L
    local dashboardView = env.dashboardView
    local dashScrollTopOffset = env.dashScrollTopOffset
    local dashAccentRefs = env.dashAccentRefs
    local GetAccentColor = env.GetAccentColor
    local MakeText = env.MakeText
    local MakeDashboardWelcomeMixedScriptText = env.MakeDashboardWelcomeMixedScriptText
    local moduleLabels = env.moduleLabels
    local categoryIcons = env.categoryIcons
    local PREVIEW_MODULE_KEYS = env.PREVIEW_MODULE_KEYS
    local COMING_SOON_MODULE_KEYS = env.COMING_SOON_MODULE_KEYS
    local TILE_MODULE_LABEL_COLORS = env.TILE_MODULE_LABEL_COLORS
    local ShouldShowModuleOnDashboard = env.ShouldShowModuleOnDashboard
    local DASH_HOME_TILE_W = env.DASH_HOME_TILE_W
    local DASH_HOME_TILE_H = env.DASH_HOME_TILE_H
    local DASH_HOME_TILE_GAP = env.DASH_HOME_TILE_GAP
    local DASH_HOME_TILE_COLS = env.DASH_HOME_TILE_COLS
    local DASH_HOME_TILE_BG_ALPHA_MULT = env.DASH_HOME_TILE_BG_ALPHA_MULT
    local DASH_HOME_SKELETON_BG_ALPHA_MULT = env.DASH_HOME_SKELETON_BG_ALPHA_MULT
    local DASHBOARD_CONTENT_CARD_ALPHA_MULT = env.DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local detailNav = env.detailNav

    local WDef = addon.OptionsWidgetsDef
    local SBg = (WDef and WDef.SectionCardBg) or { 0.09, 0.09, 0.11, 0.96 }
    local SBgA = SBg[4] * DASHBOARD_CONTENT_CARD_ALPHA_MULT
    local SBgHoverR, SBgHoverG, SBgHoverB = 0.11, 0.11, 0.13

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
        tile:SetSize(tw, th)

        local tileH = th
        local fillANormal = SBgA * DASH_HOME_TILE_BG_ALPHA_MULT

        -- Card chrome: full bleed fill + bottom rule (no left accent bar on Home — subcategory/detail keep theirs)
        local tBg = tile:CreateTexture(nil, "BACKGROUND")
        tBg:SetAllPoints()
        tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal)

        local homeCardDivider = tile:CreateTexture(nil, "ARTWORK")
        homeCardDivider:SetHeight(1)
        homeCardDivider:SetPoint("BOTTOMLEFT", 20, 0)
        homeCardDivider:SetPoint("BOTTOMRIGHT", -20, 0)
        local ddr, ddg, ddb = GetAccentColor()
        homeCardDivider:SetColorTexture(ddr, ddg, ddb, 0.2)
        tinsert(dashAccentRefs.homeTileDividers, homeCardDivider)

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

        tile._isSkeleton = false

        --- Apply disabled-module (skeleton) or normal idle chrome for this Home tile.
        --- @param skeleton boolean
        --- @return nil
        tile.SetDashboardSkeletonMode = function(_, skeleton)
            tile._isSkeleton = skeleton and true or false
            if tile._isSkeleton then
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal * DASH_HOME_SKELETON_BG_ALPHA_MULT)
                homeCardDivider:SetColorTexture(0.14, 0.15, 0.17, 0.22)
                if ic.SetDesaturated then ic:SetDesaturated(true) end
                ic:SetVertexColor(0.5, 0.52, 0.56, 0.68)
                lbl:SetTextColor(0.44, 0.46, 0.49)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(0.32, 0.58, 0.34, 0.8)
                end
                tileDivider:SetColorTexture(0.14, 0.15, 0.17, 0.22)
            else
                tBg:SetColorTexture(SBg[1], SBg[2], SBg[3], fillANormal)
                local rr, rg, rb = GetAccentColor()
                homeCardDivider:SetColorTexture(rr, rg, rb, 0.2)
                if ic.SetDesaturated then ic:SetDesaturated(false) end
                ic:SetVertexColor(0.80, 0.80, 0.85, 0.82)
                lbl:SetTextColor(tile._moduleLabelR, tile._moduleLabelG, tile._moduleLabelB)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(34/255, 139/255, 34/255, 1)
                end
                tileDivider:SetColorTexture(0.20, 0.21, 0.26, 0.28)
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
        end
        tile.ApplyDashboardTileLayout(tile, tileH)

        tile:SetScript("OnEnter", function()
            if tile._isSkeleton then
                tBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, fillANormal * DASH_HOME_SKELETON_BG_ALPHA_MULT)
                ic:SetVertexColor(0.58, 0.60, 0.64, 0.82)
                lbl:SetTextColor(0.55, 0.57, 0.60)
                if tile.previewBadge then
                    tile.previewBadge:SetTextColor(0.38, 0.65, 0.40, 0.9)
                end
            else
                tBg:SetColorTexture(SBgHoverR, SBgHoverG, SBgHoverB, fillANormal)
            end
        end)
        tile:SetScript("OnLeave", function()
            if tile.SetDashboardSkeletonMode then
                tile:SetDashboardSkeletonMode(tile._isSkeleton)
            end
        end)
        tile:SetScript("OnClick", function()
            if tile._isComingSoon then
                ShowCopyURL(L["DASH_DISCORD"] or "Discord", "https://discord.gg/nFabdZmvSB")
            elseif tile._isSkeleton then
                detailNav.NavigateToModuleToggles()
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

    if addon.DashboardWelcomeView_Init then
        addon.DashboardWelcomeView_Init(env)
    end

    return {
        RefreshDashboardTiles = RefreshDashboardTiles,
    }
end
