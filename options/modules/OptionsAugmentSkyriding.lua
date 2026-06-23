--[[
    Horizon Suite - Augment / Skyriding - options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L   = addon.L
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section = addon.Section
local Toggle  = addon.Toggle
local Slider  = addon.Slider

local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

local function S() return addon.Augment and addon.Augment.Skyriding end

local function applyLayout()
    local s = S()
    if not s then return end
    if s.BarStyle and s.BarStyle.ApplyLayout then s.BarStyle.ApplyLayout() end
    if s.CircularStyle and s.CircularStyle.ApplyLayout then s.CircularStyle.ApplyLayout() end
end

local function isBarStyle() return getDB("skyridingStyle", D.skyridingStyle) == "bar" end
local function isCircularStyle() return getDB("skyridingStyle", D.skyridingStyle) == "circular" end

local BAR_DBKEYS = {
    "skyridingBarWidth", "skyridingBarChargeHeight", "skyridingBarSpeedHeight",
    "skyridingBarPadding", "skyridingBarSwapPosition",
    "skyridingBarChargeColor", "skyridingBarSpeedLowColor",
    "skyridingBarSpeedThrillColor", "skyridingBarSpeedGroundSkimColor",
}
local CIRCULAR_DBKEYS = { "skyridingCircularSize", "skyridingCircularColor" }

local function ColorOption(name, desc, prefix, defaultR, defaultG, defaultB, opts)
    local t = {
        type = "color", name = name, desc = desc, dbKey = prefix,
        default = { defaultR, defaultG, defaultB },
        get = function()
            return getDB(prefix .. "R", defaultR), getDB(prefix .. "G", defaultG), getDB(prefix .. "B", defaultB)
        end,
        set = function(r, g, b)
            setDB(prefix .. "R", r); setDB(prefix .. "G", g); setDB(prefix .. "B", b)
            applyLayout()
        end,
    }
    if opts then for k, v in pairs(opts) do t[k] = v end end
    return t
end

local category = {
    key         = "AugmentSkyriding",
    name        = L["AUGMENT_SKYRIDING"],
    desc        = L["AUGMENT_SKYRIDING_PAGE_DESC"],
    moduleKey   = "augment",
    icon        = "Interface\\Icons\\Ability_Hunter_AspectOfTheHawk",
    accentColor = { 0.25, 0.78, 1.0 },
    enabledKey  = "skyridingEnabled",
    getEnabled  = function() return getDB("skyridingEnabled", D.skyridingEnabled) ~= false end,
    setEnabled  = function(v)
        v = v and true or false
        setDB("skyridingEnabled", v)
        local s = S()
        if not s then return end
        if v then s.Enable() else s.Disable() end
    end,
    options = {
        Section(L["AUGMENT_SKYRIDING_STYLE"]),
        { type = "dropdown",
          name = L["AUGMENT_SKYRIDING_STYLE"], desc = L["AUGMENT_SKYRIDING_STYLE_DESC"],
          dbKey = "skyridingStyle",
          options = {
              { L["AUGMENT_SKYRIDING_STYLE_BAR"], "bar" },
              { L["AUGMENT_SKYRIDING_STYLE_CIRCULAR"], "circular" },
          },
          get = function() return getDB("skyridingStyle", D.skyridingStyle) end,
          set = function(v)
              setDB("skyridingStyle", v)
              local s = S()
              if s and s.ApplyActiveStyle then s.ApplyActiveStyle() end
          end,
          refreshIds = (function()
              local ids = {}
              for _, k in ipairs(BAR_DBKEYS) do ids[#ids + 1] = k end
              for _, k in ipairs(CIRCULAR_DBKEYS) do ids[#ids + 1] = k end
              return ids
          end)(),
        },
        Slider(L["AUGMENT_SKYRIDING_SCALE"], L["AUGMENT_SKYRIDING_SCALE_DESC"], "skyridingScale",
            LIM.skyridingScale.min, LIM.skyridingScale.max, D.skyridingScale,
            { step = 0.05, set = function(v) setDB("skyridingScale", clamp(v, "skyridingScale")); applyLayout() end }),
        Toggle(L["AUGMENT_SKYRIDING_SHOW_SPEED_TEXT"], L["AUGMENT_SKYRIDING_SHOW_SPEED_TEXT_DESC"],
            "skyridingShowSpeedText", D.skyridingShowSpeedText),
        Toggle(L["AUGMENT_SKYRIDING_HIDE_GROUNDED_FULL"], L["AUGMENT_SKYRIDING_HIDE_GROUNDED_FULL_DESC"],
            "skyridingHideWhenGroundedFull", D.skyridingHideWhenGroundedFull),

        Section(L["AUGMENT_SKYRIDING_BAR_SETTINGS"], { visibleWhen = isBarStyle }),
        { type = "columns", visibleWhen = isBarStyle,
            left = { options = {
                Slider(L["AUGMENT_SKYRIDING_WIDTH"], L["AUGMENT_SKYRIDING_WIDTH_DESC"], "skyridingBarWidth",
                    LIM.skyridingBarWidth.min, LIM.skyridingBarWidth.max, D.skyridingBarWidth,
                    { set = function(v) setDB("skyridingBarWidth", clamp(v, "skyridingBarWidth")); applyLayout() end }),
                Slider(L["AUGMENT_SKYRIDING_CHARGE_HEIGHT"], L["AUGMENT_SKYRIDING_CHARGE_HEIGHT_DESC"], "skyridingBarChargeHeight",
                    LIM.skyridingBarChargeHeight.min, LIM.skyridingBarChargeHeight.max, D.skyridingBarChargeHeight,
                    { set = function(v) setDB("skyridingBarChargeHeight", clamp(v, "skyridingBarChargeHeight")); applyLayout() end }),
                Slider(L["AUGMENT_SKYRIDING_SPEED_HEIGHT"], L["AUGMENT_SKYRIDING_SPEED_HEIGHT_DESC"], "skyridingBarSpeedHeight",
                    LIM.skyridingBarSpeedHeight.min, LIM.skyridingBarSpeedHeight.max, D.skyridingBarSpeedHeight,
                    { set = function(v) setDB("skyridingBarSpeedHeight", clamp(v, "skyridingBarSpeedHeight")); applyLayout() end }),
                Slider(L["AUGMENT_SKYRIDING_PADDING"], L["AUGMENT_SKYRIDING_PADDING_DESC"], "skyridingBarPadding",
                    LIM.skyridingBarPadding.min, LIM.skyridingBarPadding.max, D.skyridingBarPadding,
                    { set = function(v) setDB("skyridingBarPadding", clamp(v, "skyridingBarPadding")); applyLayout() end }),
                Toggle(L["AUGMENT_SKYRIDING_SWAP_POSITION"], L["AUGMENT_SKYRIDING_SWAP_POSITION_DESC"], "skyridingBarSwapPosition", D.skyridingBarSwapPosition,
                    { set = function(v) setDB("skyridingBarSwapPosition", v); applyLayout() end }),
            } },
            right = { options = {
                ColorOption(L["AUGMENT_SKYRIDING_CHARGE_COLOR"], L["AUGMENT_SKYRIDING_CHARGE_COLOR_DESC"], "skyridingBarChargeColor",
                    D.skyridingBarChargeColorR, D.skyridingBarChargeColorG, D.skyridingBarChargeColorB),
                ColorOption(L["AUGMENT_SKYRIDING_SPEED_LOW_COLOR"], L["AUGMENT_SKYRIDING_SPEED_LOW_COLOR_DESC"], "skyridingBarSpeedLowColor",
                    D.skyridingBarSpeedLowColorR, D.skyridingBarSpeedLowColorG, D.skyridingBarSpeedLowColorB),
                ColorOption(L["AUGMENT_SKYRIDING_SPEED_THRILL_COLOR"], L["AUGMENT_SKYRIDING_SPEED_THRILL_COLOR_DESC"], "skyridingBarSpeedThrillColor",
                    D.skyridingBarSpeedThrillColorR, D.skyridingBarSpeedThrillColorG, D.skyridingBarSpeedThrillColorB),
                ColorOption(L["AUGMENT_SKYRIDING_SPEED_GROUNDSKIM_COLOR"], L["AUGMENT_SKYRIDING_SPEED_GROUNDSKIM_COLOR_DESC"], "skyridingBarSpeedGroundSkimColor",
                    D.skyridingBarSpeedGroundSkimColorR, D.skyridingBarSpeedGroundSkimColorG, D.skyridingBarSpeedGroundSkimColorB),
            } },
        },

        Section(L["AUGMENT_SKYRIDING_CIRCULAR_SETTINGS"], { visibleWhen = isCircularStyle }),
        { type = "columns", visibleWhen = isCircularStyle,
            left = { options = {
                Slider(L["AUGMENT_SKYRIDING_GAUGE_SIZE"], L["AUGMENT_SKYRIDING_GAUGE_SIZE_DESC"], "skyridingCircularSize",
                    LIM.skyridingCircularSize.min, LIM.skyridingCircularSize.max, D.skyridingCircularSize,
                    { set = function(v) setDB("skyridingCircularSize", clamp(v, "skyridingCircularSize")); applyLayout() end }),
            } },
            right = { options = {
                ColorOption(L["AUGMENT_SKYRIDING_CIRCULAR_COLOR"], L["AUGMENT_SKYRIDING_CIRCULAR_COLOR_DESC"], "skyridingCircularColor",
                    D.skyridingCircularColorR, D.skyridingCircularColorG, D.skyridingCircularColorB),
            } },
        },

        Section(L["AUGMENT_SKYRIDING_SECOND_WIND"]),
        Toggle(L["AUGMENT_SKYRIDING_SECOND_WIND_ENABLE"], L["AUGMENT_SKYRIDING_SECOND_WIND_ENABLE_DESC"],
            "skyridingSecondWindEnabled", D.skyridingSecondWindEnabled),
        ColorOption(L["AUGMENT_SKYRIDING_SECOND_WIND_COLOR"], L["AUGMENT_SKYRIDING_SECOND_WIND_COLOR_DESC"], "skyridingSecondWindColor",
            D.skyridingSecondWindColorR, D.skyridingSecondWindColorG, D.skyridingSecondWindColorB),

        Section(L["AUGMENT_SKYRIDING_WHIRLING_SURGE"]),
        Toggle(L["AUGMENT_SKYRIDING_WHIRLING_SURGE_ENABLE"], L["AUGMENT_SKYRIDING_WHIRLING_SURGE_ENABLE_DESC"],
            "skyridingWhirlingSurgeEnabled", D.skyridingWhirlingSurgeEnabled),
        { type = "dropdown",
          name = L["AUGMENT_SKYRIDING_SURGE_VISIBILITY"], desc = L["AUGMENT_SKYRIDING_SURGE_VISIBILITY_DESC"],
          dbKey = "skyridingWhirlingSurgeVisibility",
          options = {
              { L["AUGMENT_SKYRIDING_SURGE_ALWAYS"], 3 },
              { L["AUGMENT_SKYRIDING_SURGE_READY"], 2 },
              { L["AUGMENT_SKYRIDING_SURGE_CHARGING"], 1 },
          },
          get = function() return tonumber(getDB("skyridingWhirlingSurgeVisibility", D.skyridingWhirlingSurgeVisibility)) end,
          set = function(v) setDB("skyridingWhirlingSurgeVisibility", v) end,
          disabled = function() return not getDB("skyridingWhirlingSurgeEnabled", D.skyridingWhirlingSurgeEnabled) end,
        },

        Section(L["AUGMENT_SKYRIDING_OTHER"]),
        Toggle(L["AUGMENT_SKYRIDING_DERBY_ENABLE"], L["AUGMENT_SKYRIDING_DERBY_ENABLE_DESC"], "skyridingDerbyEnabled", D.skyridingDerbyEnabled,
            { set = function(v)
                setDB("skyridingDerbyEnabled", v)
                local s = S()
                if s and s.UpdateEventRegistrations then s.UpdateEventRegistrations() end
            end }),
        Toggle(L["AUGMENT_SKYRIDING_SOUND_ENABLE"], L["AUGMENT_SKYRIDING_SOUND_ENABLE_DESC"], "skyridingSoundEnabled", D.skyridingSoundEnabled),
    },
}

-- Insert after the last Augment category to preserve sidebar order.
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "augment" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
