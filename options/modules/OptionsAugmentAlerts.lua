--[[
    Horizon Suite - Augment / Alerts - options category
    Self-registers into addon.OptionCategories after OptionsData.lua runs.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L   = addon.L
local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS
local function clamp(v, key) local lim = LIM[key]; return math.max(lim.min, math.min(lim.max, v)) end

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section = addon.Section

local FONT_USE_GLOBAL                  = addon.FONT_USE_GLOBAL
local GetPerElementFontDropdownOptions = addon.GetPerElementFontDropdownOptions
local DisplayPerElementFont            = addon.DisplayPerElementFont

-- One colour picker per kind, all sharing the same get/set/default shape
-- (3 float DB keys per kind — see AugmentAlertsState.lua's A.GetKindColor).
local function ColorOption(nameKey, descKey, prefix)
    return {
        type = "color",
        name = L[nameKey], desc = L[descKey],
        dbKey = prefix,
        liveThrottle = 0.08,
        default = { D[prefix .. "R"], D[prefix .. "G"], D[prefix .. "B"] },
        get = function() return getDB(prefix .. "R", D[prefix .. "R"]), getDB(prefix .. "G", D[prefix .. "G"]), getDB(prefix .. "B", D[prefix .. "B"]) end,
        set = function(r, g, b)
            local batchingLive = addon._colorPickerLive and true or false
            if batchingLive then addon._suspendColorPickerLiveNotify = true end
            setDB(prefix .. "R", r)
            setDB(prefix .. "G", g)
            if batchingLive then addon._suspendColorPickerLiveNotify = nil end
            setDB(prefix .. "B", b)
        end,
    }
end

-- Re-apply live state after a toggle/slider changes. Cheap to call on every
-- option change since each step early-outs when nothing actually needs it.
local function applyAlerts()
    local A = addon.Augment and addon.Augment.Alerts
    if not A then return end
    if A.UpdateEventRegistrations then A.UpdateEventRegistrations() end
    if A.ApplyScale then A.ApplyScale() end
    if A.RestoreSavedPosition then A.RestoreSavedPosition() end
    if A.Bags and A.Bags.RefreshReminderState then A.Bags.RefreshReminderState() end
    if A.Durability and A.Durability.RefreshReminderState then A.Durability.RefreshReminderState() end
end

local function GetBagThresholdHint()
    local A = addon.Augment and addon.Augment.Alerts
    if A and A.GetThresholdHint then
        return A.GetThresholdHint()
    end
    local threshold = tonumber(getDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold
    local total = 0
    for bag = 0, NUM_BAG_SLOTS do
        local slots = C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag)
        if slots and slots > 0 then
            total = total + slots
        end
    end
    if total <= 0 then
        return L["AUGMENT_ALERTS_BAGS_THRESHOLD_DESC"]
    end

    local maxFree = math.floor(total * (100 - threshold) / 100)
    return string.format("%s\n\nWith your current bag capacity, this triggers at %d or fewer free slots total.\n\nIf you are already above the threshold when you enable Alerts, it waits until bags dip back below it and fill up again.", L["AUGMENT_ALERTS_BAGS_THRESHOLD_DESC"], maxFree)
end

local function GetReminderOptions()
    return {
        { L["AUGMENT_ALERTS_THRESHOLD"], "threshold" },
        { "1 Minute", "1min" },
        { "5 Minutes", "5min" },
        { "10 Minutes", "10min" },
        { "30 Minutes", "30min" },
    }
end

local category = {
    key         = "AugmentAlerts",
    name        = L["AUGMENT_ALERTS"],
    desc        = L["AUGMENT_ALERTS_PAGE_DESC"],
    icon        = "Interface\\Icons\\INV_Misc_Bell_01",
    accentColor = { 0.95, 0.65, 0.25 },
    moduleKey   = "augment",
    enabledKey  = "augmentAlertsEnabled",
    getEnabled  = function() return getDB("augmentAlertsEnabled", D.augmentAlertsEnabled) ~= false end,
    setEnabled  = function(v)
        v = v and true or false
        setDB("augmentAlertsEnabled", v)
        if addon.IsModuleEnabled and not addon:IsModuleEnabled("augment") then return end
        local A = addon.Augment and addon.Augment.Alerts
        if not A then return end
        if v then A.Enable() else A.Disable() end
    end,
    options = {
        Section(L["AUGMENT_ALERTS_KINDS"]),
        { type = "columns",
            left = {
                options = {
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_DURABILITY"], desc = L["AUGMENT_ALERTS_DURABILITY_DESC"],
                      dbKey = "alertsDurabilityEnabled",
                      get = function() return getDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) end,
                      set = function(v) setDB("alertsDurabilityEnabled", v); applyAlerts() end,
                      refreshIds = { "alertsDurabilityThreshold" },
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_DURABILITY_THRESHOLD"], desc = L["AUGMENT_ALERTS_DURABILITY_THRESHOLD_DESC"],
                      dbKey = "alertsDurabilityThreshold",
                      min = LIM.alertsDurabilityThreshold.min, max = LIM.alertsDurabilityThreshold.max,
                      get = function() return math.max(LIM.alertsDurabilityThreshold.min, math.min(LIM.alertsDurabilityThreshold.max, tonumber(getDB("alertsDurabilityThreshold", D.alertsDurabilityThreshold)) or D.alertsDurabilityThreshold)) end,
                      set = function(v) setDB("alertsDurabilityThreshold", clamp(v, "alertsDurabilityThreshold")) end,
                      disabled = function() return not getDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_DURABILITY_REMINDER"], desc = L["AUGMENT_ALERTS_DURABILITY_REMINDER_DESC"],
                      dbKey = "alertsDurabilityReminder",
                      options = GetReminderOptions(),
                      get = function() return getDB("alertsDurabilityReminder", D.alertsDurabilityReminder) end,
                      set = function(v) setDB("alertsDurabilityReminder", v); applyAlerts() end,
                      disabled = function() return not getDB("alertsDurabilityEnabled", D.alertsDurabilityEnabled) end,
                      preserveOrder = true,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_BAGS"], desc = L["AUGMENT_ALERTS_BAGS_DESC"],
                      dbKey = "alertsBagsEnabled",
                      get = function() return getDB("alertsBagsEnabled", D.alertsBagsEnabled) end,
                      set = function(v) setDB("alertsBagsEnabled", v); applyAlerts() end,
                      refreshIds = { "alertsBagsThreshold" },
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_BAGS_THRESHOLD"], desc = L["AUGMENT_ALERTS_BAGS_THRESHOLD_DESC"],
                      dbKey = "alertsBagsThreshold",
                      min = LIM.alertsBagsThreshold.min, max = LIM.alertsBagsThreshold.max,
                      get = function() return math.max(LIM.alertsBagsThreshold.min, math.min(LIM.alertsBagsThreshold.max, tonumber(getDB("alertsBagsThreshold", D.alertsBagsThreshold)) or D.alertsBagsThreshold)) end,
                      set = function(v) setDB("alertsBagsThreshold", clamp(v, "alertsBagsThreshold")) end,
                      disabled = function() return not getDB("alertsBagsEnabled", D.alertsBagsEnabled) end,
                      tooltip = GetBagThresholdHint,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_BAGS_REMINDER"], desc = L["AUGMENT_ALERTS_BAGS_REMINDER_DESC"],
                      dbKey = "alertsBagsReminder",
                      options = GetReminderOptions(),
                      get = function() return getDB("alertsBagsReminder", D.alertsBagsReminder) end,
                      set = function(v) setDB("alertsBagsReminder", v); applyAlerts() end,
                      disabled = function() return not getDB("alertsBagsEnabled", D.alertsBagsEnabled) end,
                      preserveOrder = true,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_MAIL"], desc = L["AUGMENT_ALERTS_MAIL_DESC"],
                      dbKey = "alertsMailEnabled",
                      get = function() return getDB("alertsMailEnabled", D.alertsMailEnabled) end,
                      set = function(v) setDB("alertsMailEnabled", v); applyAlerts() end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_VAULT"], desc = L["AUGMENT_ALERTS_VAULT_DESC"],
                      dbKey = "alertsVaultEnabled",
                      get = function() return getDB("alertsVaultEnabled", D.alertsVaultEnabled) end,
                      set = function(v) setDB("alertsVaultEnabled", v); applyAlerts() end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_FRIENDS"], desc = L["AUGMENT_ALERTS_FRIENDS_DESC"],
                      dbKey = "alertsFriendsEnabled",
                      get = function() return getDB("alertsFriendsEnabled", D.alertsFriendsEnabled) end,
                      set = function(v) setDB("alertsFriendsEnabled", v); applyAlerts() end,
                    },
                },
            },
            right = {
                options = {
                    { type = "section", name = L["AUGMENT_ALERTS_SOUND"] },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_ENABLED"], desc = L["AUGMENT_ALERTS_SOUND_ENABLED_DESC"],
                      dbKey = "alertsSoundEnabled",
                      get = function() return getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      set = function(v) setDB("alertsSoundEnabled", v) end,
                      disabled = function() return true end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_SOUND_CHANNEL"], desc = L["AUGMENT_ALERTS_SOUND_CHANNEL_DESC"],
                      dbKey = "alertsSoundChannel",
                      options = {
                          { L["AUGMENT_SOUND_CH_SFX"],      "SFX"      },
                          { L["AUGMENT_SOUND_CH_MASTER"],   "Master"   },
                          { L["AUGMENT_SOUND_CH_DIALOG"],   "Dialog"   },
                          { L["AUGMENT_SOUND_CH_AMBIENCE"], "Ambience" },
                          { L["AUGMENT_SOUND_CH_MUSIC"],    "Music"    },
                      },
                      get = function() return getDB("alertsSoundChannel", D.alertsSoundChannel) end,
                      set = function(v) setDB("alertsSoundChannel", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_SOUND_COOLDOWN"], desc = L["AUGMENT_ALERTS_SOUND_COOLDOWN_DESC"],
                      dbKey = "alertsSoundCooldown",
                      min = LIM.alertsSoundCooldown.min, max = LIM.alertsSoundCooldown.max,
                      get = function() return math.max(LIM.alertsSoundCooldown.min, math.min(LIM.alertsSoundCooldown.max, tonumber(getDB("alertsSoundCooldown", D.alertsSoundCooldown)) or D.alertsSoundCooldown)) end,
                      set = function(v) setDB("alertsSoundCooldown", clamp(v, "alertsSoundCooldown")) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_DURABILITY"], desc = L["AUGMENT_ALERTS_SOUND_DURABILITY_DESC"],
                      dbKey = "alertsSoundDurability",
                      get = function() return getDB("alertsSoundDurability", D.alertsSoundDurability) end,
                      set = function(v) setDB("alertsSoundDurability", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      shiftClick = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PlaySoundPreview then addon.Augment.Alerts.PlaySoundPreview("DURABILITY") end end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_BAGS"], desc = L["AUGMENT_ALERTS_SOUND_BAGS_DESC"],
                      dbKey = "alertsSoundBags",
                      get = function() return getDB("alertsSoundBags", D.alertsSoundBags) end,
                      set = function(v) setDB("alertsSoundBags", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      shiftClick = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PlaySoundPreview then addon.Augment.Alerts.PlaySoundPreview("BAGS") end end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_MAIL"], desc = L["AUGMENT_ALERTS_SOUND_MAIL_DESC"],
                      dbKey = "alertsSoundMail",
                      get = function() return getDB("alertsSoundMail", D.alertsSoundMail) end,
                      set = function(v) setDB("alertsSoundMail", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      shiftClick = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PlaySoundPreview then addon.Augment.Alerts.PlaySoundPreview("MAIL") end end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_VAULT"], desc = L["AUGMENT_ALERTS_SOUND_VAULT_DESC"],
                      dbKey = "alertsSoundVault",
                      get = function() return getDB("alertsSoundVault", D.alertsSoundVault) end,
                      set = function(v) setDB("alertsSoundVault", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      shiftClick = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PlaySoundPreview then addon.Augment.Alerts.PlaySoundPreview("VAULT") end end,
                    },
                    { type = "toggle",
                      name = L["AUGMENT_ALERTS_SOUND_FRIENDS"], desc = L["AUGMENT_ALERTS_SOUND_FRIENDS_DESC"],
                      dbKey = "alertsSoundFriends",
                      get = function() return getDB("alertsSoundFriends", D.alertsSoundFriends) end,
                      set = function(v) setDB("alertsSoundFriends", v) end,
                      disabled = function() return not getDB("alertsSoundEnabled", D.alertsSoundEnabled) end,
                      shiftClick = function() if addon.Augment and addon.Augment.Alerts and addon.Augment.Alerts.PlaySoundPreview then addon.Augment.Alerts.PlaySoundPreview("FRIEND_ON") end end,
                    },
                },
            },
        },

        Section(L["AUGMENT_ALERTS_DISPLAY"]),
        { type = "columns",
            left = {
                options = {
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_MAX_VISIBLE"], desc = L["AUGMENT_ALERTS_MAX_VISIBLE_DESC"],
                      dbKey = "alertsMaxVisible",
                      min = LIM.alertsMaxVisible.min, max = LIM.alertsMaxVisible.max,
                      get = function() return math.max(LIM.alertsMaxVisible.min, math.min(LIM.alertsMaxVisible.max, tonumber(getDB("alertsMaxVisible", D.alertsMaxVisible)) or D.alertsMaxVisible)) end,
                      set = function(v) setDB("alertsMaxVisible", clamp(v, "alertsMaxVisible")) end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_SCALE"], desc = L["AUGMENT_ALERTS_SCALE_DESC"],
                      dbKey = "alertsScale",
                      min = LIM.alertsScale.min, max = LIM.alertsScale.max, step = 0.1,
                      get = function() return math.max(LIM.alertsScale.min, math.min(LIM.alertsScale.max, tonumber(getDB("alertsScale", D.alertsScale)) or D.alertsScale)) end,
                      set = function(v) setDB("alertsScale", clamp(v, "alertsScale")); applyAlerts() end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_OPACITY"], desc = L["AUGMENT_ALERTS_OPACITY_DESC"],
                      dbKey = "alertsOpacity",
                      min = LIM.alertsOpacity.min, max = LIM.alertsOpacity.max,
                      get = function() return math.max(LIM.alertsOpacity.min, math.min(LIM.alertsOpacity.max, tonumber(getDB("alertsOpacity", D.alertsOpacity)) or D.alertsOpacity)) end,
                      set = function(v) setDB("alertsOpacity", clamp(v, "alertsOpacity")) end,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_HOLD_DURATION"], desc = L["AUGMENT_ALERTS_HOLD_DURATION_DESC"],
                      dbKey = "alertsHoldDuration",
                      min = LIM.alertsHoldDuration.min, max = LIM.alertsHoldDuration.max, step = 0.5,
                      get = function() return math.max(LIM.alertsHoldDuration.min, math.min(LIM.alertsHoldDuration.max, tonumber(getDB("alertsHoldDuration", D.alertsHoldDuration)) or D.alertsHoldDuration)) end,
                      set = function(v) setDB("alertsHoldDuration", clamp(v, "alertsHoldDuration")) end,
                    },
                },
            },
            right = {
                options = {
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_FONT"], desc = L["AUGMENT_ALERTS_FONT_DESC"],
                      dbKey = "alertsFontPath",
                      searchable = true,
                      options = function() return GetPerElementFontDropdownOptions("alertsFontPath") end,
                      get = function() return getDB("alertsFontPath", FONT_USE_GLOBAL) end,
                      set = function(v) setDB("alertsFontPath", v); applyAlerts() end,
                      displayFn = DisplayPerElementFont,
                      fontPreviewInList = true,
                    },
                    { type = "slider",
                      name = L["AUGMENT_ALERTS_FONT_SIZE"], desc = L["AUGMENT_ALERTS_FONT_SIZE_DESC"],
                      dbKey = "alertsFontSize",
                      min = LIM.alertsFontSize.min, max = LIM.alertsFontSize.max, step = 1,
                      get = function() return math.max(LIM.alertsFontSize.min, math.min(LIM.alertsFontSize.max, tonumber(getDB("alertsFontSize", D.alertsFontSize)) or D.alertsFontSize)) end,
                      set = function(v) setDB("alertsFontSize", clamp(v, "alertsFontSize")); applyAlerts() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_STYLE"], desc = L["AUGMENT_ALERTS_STYLE_DESC"],
                      dbKey = "alertsStyle",
                      options = {
                          { L["AUGMENT_ALERTS_STYLE_HORIZON"],    "horizon"    },
                          { L["AUGMENT_ALERTS_STYLE_MINIMALIST"], "minimalist" },
                      },
                      get = function() return getDB("alertsStyle", D.alertsStyle) end,
                      set = function(v) setDB("alertsStyle", v); applyAlerts() end,
                    },
                    { type = "dropdown",
                      name = L["AUGMENT_ALERTS_OUTLINE_TYPE"], desc = L["AUGMENT_ALERTS_OUTLINE_TYPE_DESC"],
                      dbKey = "alertsTextOutlineType",
                      options = addon.OUTLINE_OPTIONS,
                      get = function() return getDB("alertsTextOutlineType", D.alertsTextOutlineType) end,
                      set = function(v) setDB("alertsTextOutlineType", v); applyAlerts() end,
                    },
                },
            },
        },

        Section(L["AUGMENT_ALERTS_COLOURS"]),
        { type = "columns",
            left = {
                options = {
                    ColorOption("AUGMENT_ALERTS_DURABILITY_COLOUR", "AUGMENT_ALERTS_DURABILITY_COLOUR_DESC", "alertsDurabilityColor"),
                    ColorOption("AUGMENT_ALERTS_BAGS_COLOUR",       "AUGMENT_ALERTS_BAGS_COLOUR_DESC",       "alertsBagsColor"),
                    ColorOption("AUGMENT_ALERTS_MAIL_COLOUR",       "AUGMENT_ALERTS_MAIL_COLOUR_DESC",       "alertsMailColor"),
                },
            },
            right = {
                options = {
                    ColorOption("AUGMENT_ALERTS_VAULT_COLOUR",          "AUGMENT_ALERTS_VAULT_COLOUR_DESC",          "alertsVaultColor"),
                    ColorOption("AUGMENT_ALERTS_FRIEND_ON_COLOUR",      "AUGMENT_ALERTS_FRIEND_ON_COLOUR_DESC",      "alertsFriendOnColor"),
                    ColorOption("AUGMENT_ALERTS_FRIEND_OFF_COLOUR",     "AUGMENT_ALERTS_FRIEND_OFF_COLOUR_DESC",     "alertsFriendOffColor"),
                },
            },
        },
    },
}

-- Insert after the last Augment category to preserve sidebar order
local insertAt = #addon.OptionCategories + 1
for i, cat in ipairs(addon.OptionCategories) do
    if cat.moduleKey == "augment" then insertAt = i + 1 end
end
table.insert(addon.OptionCategories, insertAt, category)
