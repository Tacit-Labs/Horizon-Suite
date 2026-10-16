--[[
    Horizon Suite - Meridian - Horizon menu block (teleports are added in Task 7)
    Blizzard: StaticPopupDialogs, StaticPopup_Show, ReloadUI.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local L = addon.L

local RELOAD_POPUP = "HORIZONSUITE_MERIDIAN_RELOAD"

local function AskReload()
    if not (StaticPopupDialogs and StaticPopup_Show) then return end
    if not StaticPopupDialogs[RELOAD_POPUP] then
        StaticPopupDialogs[RELOAD_POPUP] = {
            text = L["MERIDIAN_RELOAD_PROMPT"],
            button1 = L["RELOAD_UI"],
            button2 = L["MERIDIAN_RELOAD_LATER"],
            OnAccept = function() ReloadUI() end,
            timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
        }
    end
    StaticPopup_Show(RELOAD_POPUP)
end

local function ModuleName(key, m)
    if addon.GetModuleDisplayName then
        local name = addon.GetModuleDisplayName(key)
        if name and name ~= "" then return name end
    end
    return m.title or key
end

Meridian.RegisterBlock({
    id = "horizon",
    label = L["MERIDIAN_BLOCK_HORIZON"],
    icon = Meridian.Glyph("horizon"),
    iconAccent = true,
    text = function() return "" end,
    OnClick = function() if addon.ShowDashboard then addon.ShowDashboard() end end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["MERIDIAN_HORIZON_TOOLTIP"], 0.7, 0.7, 0.7)
    end,
    OnMenu = function(root)
        root:CreateTitle(L["MERIDIAN_MENU_MODULES"])
        if not addon.IterateModules then return end
        for key, m in addon:IterateModules() do
            root:CreateCheckbox(ModuleName(key, m),
                function() return addon:IsModuleEnabled(key) and true or false end,
                function()
                    addon:SetModuleEnabled(key, not addon:IsModuleEnabled(key), { deferReload = true })
                    AskReload()
                end)
        end
    end,
    defaultSide = "left", defaultOrder = 10, defaultOn = true,
})

Meridian.RegisterBlock({
    id = "teleports",
    label = L["MERIDIAN_BLOCK_TELEPORTS"],
    icon = Meridian.Glyph("portal"),
    text = function() return "" end,
    module = "vista",
    combatLocked = true,
    OnClick = function(b)
        local V = addon.Vista
        if not (V and V.ToggleTeleportMenu) then return end
        if Meridian.Setting("meridianEdge") == "bottom" then
            V.ToggleTeleportMenu(b, "BOTTOMLEFT", "TOPLEFT", 2)
        else
            V.ToggleTeleportMenu(b, "TOPLEFT", "BOTTOMLEFT", -2)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(L["MERIDIAN_TELEPORTS_TOOLTIP"], 0.7, 0.7, 0.7)
    end,
    defaultSide = "left", defaultOrder = 20, defaultOn = false,
})
