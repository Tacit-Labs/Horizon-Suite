--[[
    Horizon Suite - Focus - CraftProfit crafting panel
    A Horizon-styled panel docked to the open profession window that lists the player's
    tracked recipes and the most profitable learned recipes of the open profession, priced
    by the CraftProfit addon (which reads its own scans, Auctionator or TSM).

    CraftProfit draws its numbers into Blizzard's ProfessionsFrame. UI replacements that draw
    their own crafting window (Daylight UI's DaylightUICraft) hide those numbers; this panel
    docks to whichever window is actually on screen, so the numbers follow the player.

    Inactive unless CraftProfit is loaded and the "cp_craftPanel" option is on.
]]

local addon = _G.HorizonSuite
if not addon then return end
local L = addon.L

-- Crafting windows the panel can dock to, most specific first. The first one shown wins.
local HOST_FRAME_NAMES = { "DaylightUICraft", "ProfessionsFrame" }

local PANEL_W        = addon.Scaled(270)
local PANEL_PAD      = addon.Scaled(10)
local PANEL_GAP      = addon.Scaled(4)   -- space between the host window and the panel
local ACCENT_H       = addon.Scaled(3)
local TITLE_H        = addon.Scaled(26)
local HEADER_H       = addon.Scaled(20)
local ROW_H          = addon.Scaled(20)
local ICON_SIZE      = addon.Scaled(16)
local EMPTY_H        = addon.Scaled(18)
local SECTION_GAP    = addon.Scaled(8)
local TOP_N          = 5                 -- rows in "Most profitable"
local REFRESH_DELAY  = 0.15              -- seconds; coalesces bursts of list/price events
local F_HEAD         = "Fonts\\FRIZQT__.TTF"
local F_BODY         = "Fonts\\ARIALN.TTF"
local BG_COL         = { 0.06, 0.06, 0.08, 0.95 }
local EDGE_COL       = { 0.2, 0.2, 0.26, 0.95 }
local RULE_COL       = { 0.13, 0.13, 0.17, 1 }
local HEAD_COL       = { 0.62, 0.64, 0.70 }
local PROFIT_COL     = { 0.30, 0.85, 0.40 }
local LOSS_COL       = { 0.95, 0.35, 0.30 }
local MISSING_COL    = { 0.55, 0.55, 0.60 }

local panel, rowPool, headerPool, emptyPool = nil, {}, {}, {}
local host, refreshPending, hooked = nil, false, {}

-- ============================================================================
-- CRAFTPROFIT ACCESS
-- ============================================================================

--- The CraftProfit addon table when its calculator is available, else nil.
local function GetCraftProfit()
    local cp = rawget(_G, "CraftProfit")
    if type(cp) == "table" and type(cp.Calc) == "table" and type(cp.Calc.Get) == "function" then
        return cp
    end
    return nil
end

--- True when the panel should exist: CraftProfit present and the option on.
local function IsPanelEnabled()
    if addon.IsModuleEnabled and not addon:IsModuleEnabled("focus") then return false end
    return GetCraftProfit() ~= nil and addon.GetDB("cp_craftPanel", true) and true or false
end

--- CraftProfit economics for a recipe (see CraftProfit Calculator.lua Calc:Get), or nil.
local function GetEconomics(recipeID)
    local cp = GetCraftProfit()
    if not cp then return nil end
    local ok, eco = pcall(cp.Calc.Get, cp.Calc, recipeID)
    if ok and type(eco) == "table" then return eco end
    return nil
end

--- Net profit, margin and basis ("ah" | "vendor") for an economics table, honouring
--- CraftProfit's own netBasis setting. Returns nil when a price is missing.
local function PickNet(eco)
    local cp = GetCraftProfit()
    if not cp or not eco then return nil end
    if type(cp.Calc.PickNet) == "function" then
        local ok, net, margin, kind = pcall(cp.Calc.PickNet, cp.Calc, eco)
        if ok then return net, margin, kind end
        return nil
    end
    return eco.net, eco.margin, "ah"
end

local function FormatShort(copper)
    local cp = GetCraftProfit()
    if cp and cp.FormatMoneyShort then return cp:FormatMoneyShort(copper, { sign = true }) end
    return GetMoneyString and GetMoneyString(math.abs(copper)) or tostring(copper)
end

local function FormatLong(copper)
    local cp = GetCraftProfit()
    if cp and cp.FormatMoney then return cp:FormatMoney(copper) end
    return GetMoneyString and GetMoneyString(math.abs(copper)) or tostring(copper)
end

-- ============================================================================
-- RECIPE DATA
-- ============================================================================

local function GetRecipeInfo(recipeID)
    if not (C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo) then return nil end
    local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, recipeID)
    if ok and type(info) == "table" then return info end
    return nil
end

--- Tracked recipes with their economics, in tracking order.
--- @return table Array of { recipeID, isRecraft, info, eco }
local function CollectTracked()
    local out = {}
    local ids = addon.GetTrackedRecipeIDs and addon.GetTrackedRecipeIDs() or {}
    for _, entry in ipairs(ids) do
        local info = GetRecipeInfo(entry.recipeID)
        if info then
            out[#out + 1] = {
                recipeID  = entry.recipeID,
                isRecraft = entry.isRecraft,
                info      = info,
                eco       = GetEconomics(entry.recipeID),
            }
        end
    end
    return out
end

--- True when the open profession is the player's own (not a link, guild or NPC view).
local function IsOwnProfessionOpen()
    if not C_TradeSkillUI then return false end
    if C_TradeSkillUI.IsTradeSkillLinked and C_TradeSkillUI.IsTradeSkillLinked() then return false end
    if C_TradeSkillUI.IsTradeSkillGuild and C_TradeSkillUI.IsTradeSkillGuild() then return false end
    if C_TradeSkillUI.IsNPCCrafting and C_TradeSkillUI.IsNPCCrafting() then return false end
    return true
end

--- The open profession's learned recipes with a positive net, best first, at most TOP_N.
--- @return table Array of { recipeID, info, eco, net }
local function CollectTopProfitable()
    local out = {}
    if not (C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs) or not IsOwnProfessionOpen() then return out end
    local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
    if not ok or type(ids) ~= "table" then return out end
    for _, recipeID in ipairs(ids) do
        local info = GetRecipeInfo(recipeID)
        if info and info.learned and not info.isRecraft then
            local eco = GetEconomics(recipeID)
            local net = PickNet(eco)
            if net and net > 0 then
                out[#out + 1] = { recipeID = recipeID, info = info, eco = eco, net = net }
            end
        end
    end
    table.sort(out, function(a, b) return a.net > b.net end)
    for i = #out, TOP_N + 1, -1 do out[i] = nil end
    return out
end

local function IsTracked(recipeID)
    if not (C_TradeSkillUI and C_TradeSkillUI.IsRecipeTracked) then return false end
    local ok, tracked = pcall(C_TradeSkillUI.IsRecipeTracked, recipeID, false)
    return ok and tracked and true or false
end

local function SetTracked(recipeID, isRecraft, tracked)
    if not (C_TradeSkillUI and C_TradeSkillUI.SetRecipeTracked) then return end
    pcall(C_TradeSkillUI.SetRecipeTracked, recipeID, tracked, isRecraft or false)
end

-- ============================================================================
-- TOOLTIP
-- ============================================================================

local function AddMoneyLine(label, copper)
    if copper then
        GameTooltip:AddDoubleLine(label, FormatLong(copper), 0.8, 0.8, 0.8, 1, 1, 1)
    else
        GameTooltip:AddDoubleLine(label, L["FOCUS_CRAFTPROFIT_NO_PRICE"], 0.8, 0.8, 0.8,
            MISSING_COL[1], MISSING_COL[2], MISSING_COL[3])
    end
end

local function ShowRowTooltip(row)
    local data = row.data
    if not data then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:AddLine(data.info.name or "", 1, 1, 1)
    local eco = data.eco
    if eco then
        AddMoneyLine(L["FOCUS_CRAFTPROFIT_COST"], eco.costComplete and eco.cost or nil)
        AddMoneyLine(L["FOCUS_CRAFTPROFIT_SALE"], eco.sale)
        if eco.cut and eco.cut > 0 then AddMoneyLine(L["FOCUS_CRAFTPROFIT_AH_CUT"], -eco.cut) end
        if eco.vendorSale then AddMoneyLine(L["FOCUS_CRAFTPROFIT_VENDOR"], eco.vendorSale) end
        local net, margin, kind = PickNet(eco)
        if net then
            local col = net >= 0 and PROFIT_COL or LOSS_COL
            local label = kind == "vendor" and L["FOCUS_CRAFTPROFIT_NET_VENDOR"] or L["FOCUS_CRAFTPROFIT_NET"]
            local value = FormatLong(net)
            if margin then value = value .. string.format(" (%d%%)", math.floor(margin * 100 + 0.5)) end
            GameTooltip:AddDoubleLine(label, value, 1, 1, 1, col[1], col[2], col[3])
        end
        if eco.missing and eco.missing > 0 then
            GameTooltip:AddLine(string.format(L["FOCUS_CRAFTPROFIT_MISSING_PRICES"], eco.missing),
                MISSING_COL[1], MISSING_COL[2], MISSING_COL[3], true)
        end
    else
        GameTooltip:AddLine(L["FOCUS_CRAFTPROFIT_NO_PRICE"], MISSING_COL[1], MISSING_COL[2], MISSING_COL[3])
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(row.tracked and L["FOCUS_CRAFTPROFIT_HINT_UNTRACK"] or L["FOCUS_CRAFTPROFIT_HINT_TRACK"],
        0.5, 0.8, 1, true)
    GameTooltip:Show()
end

-- ============================================================================
-- FRAME CONSTRUCTION
-- ============================================================================

local function GetAccentRGB()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then return cc[1], cc[2], cc[3] end
    return 0.2, 0.8, 0.9
end

local function BuildPanel()
    if panel then return panel end
    panel = CreateFrame("Frame", "HorizonSuiteCraftProfitPanel", UIParent, "BackdropTemplate")
    panel:SetWidth(PANEL_W)
    panel:SetFrameStrata("HIGH")
    panel:SetClampedToScreen(true)
    panel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    panel:SetBackdropColor(BG_COL[1], BG_COL[2], BG_COL[3], BG_COL[4])
    panel:SetBackdropBorderColor(EDGE_COL[1], EDGE_COL[2], EDGE_COL[3], EDGE_COL[4])
    panel:Hide()

    local accent = panel:CreateTexture(nil, "ARTWORK")
    accent:SetPoint("TOPLEFT", 1, -1)
    accent:SetPoint("TOPRIGHT", -1, -1)
    accent:SetHeight(ACCENT_H)
    panel.accent = accent

    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont(F_HEAD, addon.Scaled(12), "")
    title:SetPoint("TOPLEFT", PANEL_PAD, -(ACCENT_H + addon.Scaled(7)))
    title:SetText(L["FOCUS_CRAFTPROFIT_PANEL_TITLE"])
    title:SetTextColor(1, 1, 1)
    panel.title = title

    local rule = panel:CreateTexture(nil, "ARTWORK")
    rule:SetColorTexture(RULE_COL[1], RULE_COL[2], RULE_COL[3], RULE_COL[4])
    rule:SetPoint("TOPLEFT", PANEL_PAD, -(ACCENT_H + TITLE_H))
    rule:SetPoint("TOPRIGHT", -PANEL_PAD, -(ACCENT_H + TITLE_H))
    rule:SetHeight(1)

    return panel
end

local function AcquireHeader(i)
    local h = headerPool[i]
    if not h then
        h = panel:CreateFontString(nil, "OVERLAY")
        h:SetFont(F_HEAD, addon.Scaled(10), "")
        h:SetTextColor(HEAD_COL[1], HEAD_COL[2], HEAD_COL[3])
        h:SetJustifyH("LEFT")
        headerPool[i] = h
    end
    return h
end

local function AcquireEmpty(i)
    local e = emptyPool[i]
    if not e then
        e = panel:CreateFontString(nil, "OVERLAY")
        e:SetFont(F_BODY, addon.Scaled(11), "")
        e:SetTextColor(MISSING_COL[1], MISSING_COL[2], MISSING_COL[3])
        e:SetJustifyH("LEFT")
        e:SetWordWrap(true)
        emptyPool[i] = e
    end
    return e
end

local function OnRowClick(row)
    local data = row.data
    if not data then return end
    SetTracked(data.recipeID, data.isRecraft, not row.tracked)
    -- TRACKED_RECIPE_UPDATE refreshes the panel; hide the now stale tooltip meanwhile.
    GameTooltip:Hide()
end

local function AcquireRow(i)
    local row = rowPool[i]
    if not row then
        row = CreateFrame("Button", nil, panel)
        row:SetHeight(ROW_H)
        row:RegisterForClicks("LeftButtonUp")

        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.06)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(ICON_SIZE, ICON_SIZE)
        row.icon:SetPoint("LEFT", 0, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        row.value = row:CreateFontString(nil, "OVERLAY")
        row.value:SetFont(F_BODY, addon.Scaled(12), "")
        row.value:SetPoint("RIGHT", 0, 0)
        row.value:SetJustifyH("RIGHT")

        row.name = row:CreateFontString(nil, "OVERLAY")
        row.name:SetFont(F_BODY, addon.Scaled(12), "")
        row.name:SetPoint("LEFT", row.icon, "RIGHT", addon.Scaled(5), 0)
        row.name:SetPoint("RIGHT", row.value, "LEFT", -addon.Scaled(6), 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)

        row:SetScript("OnEnter", ShowRowTooltip)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:SetScript("OnClick", OnRowClick)
        rowPool[i] = row
    end
    return row
end

local function FillRow(row, data, tracked)
    row.data, row.tracked = data, tracked
    row.icon:SetTexture(data.info.icon or 134400)
    row.name:SetText(data.info.name or "")
    row.name:SetTextColor(tracked and 1 or 0.85, tracked and 0.82 or 0.85, tracked and 0 or 0.85)
    local net = PickNet(data.eco)
    if net then
        local col = net >= 0 and PROFIT_COL or LOSS_COL
        row.value:SetText(FormatShort(net))
        row.value:SetTextColor(col[1], col[2], col[3])
    else
        row.value:SetText("-")  -- ARIALN lacks the em dash
        row.value:SetTextColor(MISSING_COL[1], MISSING_COL[2], MISSING_COL[3])
    end
end

-- ============================================================================
-- LAYOUT
-- ============================================================================

local function Layout()
    if not panel then return end
    local r, g, b = GetAccentRGB()
    panel.accent:SetColorTexture(r, g, b, 1)

    for _, row in ipairs(rowPool) do row:Hide(); row.data = nil end
    for _, h in ipairs(headerPool) do h:Hide() end
    for _, e in ipairs(emptyPool) do e:Hide() end

    local y = ACCENT_H + TITLE_H + SECTION_GAP
    local rowN, headN, emptyN = 0, 0, 0
    local innerW = PANEL_W - PANEL_PAD * 2

    local function Header(text)
        headN = headN + 1
        local h = AcquireHeader(headN)
        h:ClearAllPoints()
        h:SetPoint("TOPLEFT", PANEL_PAD, -y)
        h:SetWidth(innerW)
        h:SetText(text)
        h:Show()
        y = y + HEADER_H
    end

    local function Empty(text)
        emptyN = emptyN + 1
        local e = AcquireEmpty(emptyN)
        e:ClearAllPoints()
        e:SetPoint("TOPLEFT", PANEL_PAD, -y)
        e:SetWidth(innerW)
        e:SetText(text)
        e:Show()
        y = y + math.max(EMPTY_H, e:GetStringHeight() + addon.Scaled(4))
    end

    local function Row(data, tracked)
        rowN = rowN + 1
        local row = AcquireRow(rowN)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", PANEL_PAD, -y)
        row:SetWidth(innerW)
        FillRow(row, data, tracked)
        row:Show()
        y = y + ROW_H
    end

    Header(L["FOCUS_CRAFTPROFIT_TRACKED"])
    local tracked = CollectTracked()
    if #tracked == 0 then
        Empty(L["FOCUS_CRAFTPROFIT_TRACKED_EMPTY"])
    else
        for _, data in ipairs(tracked) do Row(data, true) end
    end

    y = y + SECTION_GAP
    Header(L["FOCUS_CRAFTPROFIT_TOP"])
    local top = CollectTopProfitable()
    if #top == 0 then
        Empty(L["FOCUS_CRAFTPROFIT_TOP_EMPTY"])
    else
        for _, data in ipairs(top) do Row(data, IsTracked(data.recipeID)) end
    end

    panel:SetHeight(y + PANEL_PAD)
end

-- ============================================================================
-- HOST WINDOW
-- ============================================================================

--- The crafting window currently on screen, or nil.
local function FindShownHost()
    for _, name in ipairs(HOST_FRAME_NAMES) do
        local f = rawget(_G, name)
        if f and f.IsShown and f:IsShown() and f:GetEffectiveAlpha() > 0 then return f end
    end
    return nil
end

local UpdateVisibility

local function HookHosts()
    for _, name in ipairs(HOST_FRAME_NAMES) do
        local f = rawget(_G, name)
        if f and not hooked[f] and f.HookScript then
            hooked[f] = true
            f:HookScript("OnShow", function() UpdateVisibility() end)
            f:HookScript("OnHide", function() UpdateVisibility() end)
        end
    end
end

UpdateVisibility = function()
    HookHosts()
    local target = IsPanelEnabled() and FindShownHost() or nil
    if not target then
        if panel then panel:Hide() end
        host = nil
        return
    end
    BuildPanel()
    if host ~= target then
        host = target
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", host, "TOPRIGHT", PANEL_GAP, 0)
    end
    Layout()
    panel:Show()
end

--- Coalesce refresh requests (list updates and price events arrive in bursts).
local function ScheduleRefresh()
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(REFRESH_DELAY, function()
        refreshPending = false
        UpdateVisibility()
    end)
end

-- Exposed for the options toggle.
addon.RefreshCraftProfitPanel = ScheduleRefresh

-- ============================================================================
-- EVENTS
-- ============================================================================

local events = CreateFrame("Frame")
for _, ev in ipairs({
    "PLAYER_LOGIN", "TRADE_SKILL_SHOW", "TRADE_SKILL_CLOSE", "TRADE_SKILL_LIST_UPDATE",
    "TRADE_SKILL_DATA_SOURCE_CHANGED", "TRACKED_RECIPE_UPDATE", "ADDON_LOADED",
}) do
    -- Not every event exists on every client; an unknown event must not break the file.
    pcall(events.RegisterEvent, events, ev)
end

local craftProfitHooked = false
local function HookCraftProfit()
    if craftProfitHooked then return end
    local cp = GetCraftProfit()
    if not cp or type(cp.On) ~= "function" then return end
    craftProfitHooked = true
    for _, ev in ipairs({ "PRICES_UPDATED", "VENDOR_UPDATED", "SETTINGS_CHANGED", "CRAFTS_UPDATED" }) do
        cp:On(ev, function() if panel and panel:IsShown() then ScheduleRefresh() end end)
    end
end

events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" or event == "ADDON_LOADED" then
        HookCraftProfit()
        HookHosts()
        return
    end
    if event == "TRADE_SKILL_CLOSE" then
        -- The host's OnHide normally covers this; hide anyway in case it never hooked.
        if panel then panel:Hide() end
        host = nil
        return
    end
    HookCraftProfit()
    ScheduleRefresh()
end)
