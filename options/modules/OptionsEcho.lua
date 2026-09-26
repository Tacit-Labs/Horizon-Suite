--[[
    Horizon Suite - Echo - Options page
    One dashboard category for Echo. Every setting is in ECHO_KEYS, so a change re-applies
    through Echo.ApplyOptions (options/OptionsData.lua) without a reload.
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end
local L = addon.L
local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) addon.OptionsData_SetDB(k, v) end
local Section, Button, Toggle = addon.Section, addon.Button, addon.Toggle
local D   = addon.ECHO_DEFAULTS
local LIM = addon.ECHO_LIMITS
if not D or not LIM then return end

local function clamp(v, key)
    local lim = LIM[key]
    return math.max(lim.min, math.min(lim.max, v))
end

local function Echo() return addon.Echo end

local WHISPER_SOUND_OPTIONS = {
    { L["ECHO_SOUND_BLIZZARD"], "blizzard" },
    { L["ECHO_SOUND_TOAST"],    "toast"    },
    { L["ECHO_SOUND_PING"],     "ping"     },
    { L["ECHO_SOUND_OFF"],      "off"      },
}

local TIER_OPTIONS = {
    { L["ECHO_TIER_LOUD"],  "loud"  },
    { L["ECHO_TIER_COUNT"], "count" },
    { L["ECHO_TIER_QUIET"], "quiet" },
    { L["ECHO_TIER_MUTED"], "muted" },
}

local HISTORY_DAYS_OPTIONS = {
    { L["ECHO_HISTORY_DAYS_7"],  7  },
    { L["ECHO_HISTORY_DAYS_30"], 30 },
    { L["ECHO_HISTORY_DAYS_90"], 90 },
    { L["ECHO_HISTORY_FOREVER"], 0  },
}

local function TierDropdown(kind, label)
    local key = addon.Echo.TierKey(kind)
    return { type = "dropdown", name = label, desc = L["ECHO_TIER_DESC"], dbKey = key,
        options = TIER_OPTIONS, preserveOrder = true,
        get = function() return getDB(key, D[key]) end,
        set = function(v) setDB(key, v) end }
end

local function IntSlider(key, name, desc, step)
    return { type = "slider", name = name, desc = desc, dbKey = key,
        min = LIM[key].min, max = LIM[key].max, step = step,
        get = function() return tonumber(getDB(key, D[key])) or D[key] end,
        set = function(v) setDB(key, clamp(math.floor(v + 0.5), key)) end }
end

local options = {
    Section(L["ECHO_SECTION_GENERAL"]),
    { type = "dropdown", name = L["ECHO_COLUMN_EDGE"], desc = L["ECHO_COLUMN_EDGE_DESC"], dbKey = "echoColumnEdge",
      options = { { L["ECHO_EDGE_AUTO"], "auto" }, { L["ECHO_EDGE_RIGHT"], "right" }, { L["ECHO_EDGE_LEFT"], "left" } },
      preserveOrder = true,
      get = function() return getDB("echoColumnEdge", D.echoColumnEdge) end,
      set = function(v)
          if v == "left" or v == "right" then
              setDB("echoX", nil)
              setDB("echoY", nil)
              setDB("echoColumnEdge", v)
          else
              setDB("echoColumnEdge", "auto")
          end
      end },
    Toggle(L["ECHO_LOCK"], L["ECHO_LOCK_DESC"], "echoLockPosition", D.echoLockPosition),
    Button(L["AXIS_RESET_POSITION"], L["ECHO_RESET_POSITION_DESC"], function()
        setDB("echoX", nil)
        setDB("echoY", nil)
    end),
    { type = "slider", name = L["ECHO_SCALE"], desc = L["ECHO_SCALE_DESC"], dbKey = "echoScale",
      min = LIM.echoScale.min * 100, max = LIM.echoScale.max * 100, step = 5,
      get = function() return math.floor((tonumber(getDB("echoScale", D.echoScale)) or 1) * 100 + 0.5) end,
      set = function(v) setDB("echoScale", clamp(v / 100, "echoScale")) end },
    { type = "dropdown", name = L["ECHO_STRATA"], desc = L["ECHO_STRATA_DESC"], dbKey = "echoFrameStrata",
      options = {
          { L["FOCUS_STRATA_BACKGROUND"], "BACKGROUND" }, { L["FOCUS_STRATA_LOW"], "LOW" },
          { L["FOCUS_STRATA_MEDIUM"], "MEDIUM" }, { L["FOCUS_STRATA_HIGH"], "HIGH" },
          { L["ECHO_STRATA_DIALOG"], "DIALOG" },
      }, preserveOrder = true,
      get = function() return getDB("echoFrameStrata", D.echoFrameStrata) end,
      set = function(v) setDB("echoFrameStrata", v) end },
    IntSlider("echoMaxTiles", L["ECHO_MAX_TILES"], L["ECHO_MAX_TILES_DESC"], 1),

    Section(L["ECHO_SECTION_NOTIFICATIONS"]),
    { type = "dropdown", name = L["ECHO_TOAST_STYLE"], desc = L["ECHO_TOAST_STYLE_DESC"], dbKey = "echoToastStyle",
      options = {
          { L["AUGMENT_TOAST_STYLE_COMPACT"], "compact" },
          { L["AUGMENT_TOAST_STYLE_FRAMED"],  "framed"  },
          { L["AUGMENT_TOAST_STYLE_ACCENT"],  "accent"  },
      }, preserveOrder = true,
      get = function() return getDB("echoToastStyle", D.echoToastStyle) end,
      set = function(v) setDB("echoToastStyle", v) end },
    IntSlider("echoToastSeconds", L["ECHO_TOAST_SECONDS"], L["ECHO_TOAST_SECONDS_DESC"], 1),
    Toggle(L["ECHO_HOLD_IN_COMBAT"], L["ECHO_HOLD_IN_COMBAT_DESC"], "echoHoldToastsInCombat", D.echoHoldToastsInCombat),
    { type = "dropdown", name = L["ECHO_WHISPER_SOUND"], desc = L["ECHO_WHISPER_SOUND_DESC"], dbKey = "echoWhisperSound",
      options = WHISPER_SOUND_OPTIONS, preserveOrder = true,
      get = function() return getDB("echoWhisperSound", D.echoWhisperSound) end,
      set = function(v) setDB("echoWhisperSound", v) end },
    Button(L["ECHO_SOUND_PREVIEW"], L["ECHO_SOUND_PREVIEW_DESC"], function()
        local E = Echo()
        if E and E.Sound then E.Sound.Whisper(false, true) end
    end),
    Toggle(L["ECHO_SOUND_IN_COMBAT"], L["ECHO_SOUND_IN_COMBAT_DESC"], "echoSoundInCombat", D.echoSoundInCombat),
    Toggle(L["ECHO_SOUND_BNET"], L["ECHO_SOUND_BNET_DESC"], "echoSoundBnet", D.echoSoundBnet),
    { type = "editbox", name = L["ECHO_KEYWORDS"], labelText = L["ECHO_KEYWORDS"], tooltip = L["ECHO_KEYWORDS_DESC"],
      dbKey = "echoKeywords", height = 24,
      get = function() return getDB("echoKeywords", D.echoKeywords) or "" end,
      set = function(v) setDB("echoKeywords", type(v) == "string" and v:gsub("[\r\n]+", ",") or "") end },

    Section(L["ECHO_SECTION_TIERS"]),
    TierDropdown("whisper",  L["ECHO_KIND_WHISPER"]),
    TierDropdown("bnet",     L["ECHO_KIND_BNET"]),
    TierDropdown("party",    L["ECHO_KIND_PARTY"]),
    TierDropdown("raid",     L["ECHO_KIND_RAID"]),
    TierDropdown("instance", L["ECHO_KIND_INSTANCE"]),
    TierDropdown("guild",    L["ECHO_KIND_GUILD"]),
    TierDropdown("officer",  L["ECHO_KIND_OFFICER"]),
    TierDropdown("channel",  L["ECHO_KIND_CHANNEL"]),

    Section(L["ECHO_SECTION_FEEDS"]),
}

for _, kind in ipairs({ "loot", "progress", "system" }) do
    local name = L["ECHO_KIND_" .. kind:upper()]
    local feedKey = addon.Echo.FeedKey(kind)
    options[#options + 1] = Toggle(L["ECHO_FEED_SHOW"]:format(name), L["ECHO_FEED_SHOW_DESC"], feedKey, D[feedKey])
    local tier = TierDropdown(kind, L["ECHO_FEED_TIER"]:format(name))
    tier.visibleWhen = function() return getDB(feedKey, D[feedKey]) ~= false end
    options[#options + 1] = tier
end

-- Groups: up to four named groups of chats (modules/Echo/EchoGroups.lua). The member ids and
-- their order mirror the Global Constraints table in Docs/Engineering/2026-09-26-echo-groups-plan.md.
local GROUP_MEMBERS = {
    { id = "ch:General",             label = L["ECHO_GROUP_MEMBER_GENERAL"] },
    { id = "ch:Trade",                label = L["ECHO_GROUP_MEMBER_TRADE"] },
    { id = "ch:Trade (Services)",     label = L["ECHO_GROUP_MEMBER_SERVICES"] },
    { id = "ch:LocalDefense",         label = L["ECHO_GROUP_MEMBER_LOCAL_DEFENSE"] },
    { id = "ch:LookingForGroup",      label = L["ECHO_GROUP_MEMBER_LFG"] },
    { id = "ch:WorldDefense",         label = L["ECHO_GROUP_MEMBER_WORLD_DEFENSE"] },
    { id = "ch:NewcomerChat",         label = L["ECHO_GROUP_MEMBER_NEWCOMER"] },
    { id = "ch:*",                    label = L["ECHO_GROUP_MEMBER_OTHER_CHANNELS"] },
    { id = "guild",                   label = L["ECHO_KIND_GUILD"] },
    { id = "officer",                 label = L["ECHO_KIND_OFFICER"] },
    { id = "party",                   label = L["ECHO_KIND_PARTY"] },
    { id = "raid",                    label = L["ECHO_KIND_RAID"] },
    { id = "instance",                label = L["ECHO_KIND_INSTANCE"] },
    { id = "loot",                    label = L["ECHO_KIND_LOOT"] },
    { id = "progress",                label = L["ECHO_KIND_PROGRESS"] },
    { id = "system",                  label = L["ECHO_KIND_SYSTEM"] },
}

-- A member id starting "ch:" but not the "ch:*" wildcard: an exact channel entry. For these,
-- "None" must write `false` (not remove the entry), so a per-channel None beats a grouped
-- "Other channels" (ch:*) fallback. Every other member id just clears its entry.
local function IsExactChannel(id)
    return type(id) == "string" and id:sub(1, 3) == "ch:" and id ~= "ch:*"
end

-- A fresh copy of a 4-entry group-names table, defaulting missing/invalid entries to "".
local function GroupNamesCopy()
    local names = getDB("echoGroupNames", D.echoGroupNames)
    local copy = { "", "", "", "" }
    if type(names) == "table" then
        for i = 1, 4 do
            if type(names[i]) == "string" then copy[i] = names[i] end
        end
    end
    return copy
end

-- A fresh copy of the member-id -> group-index table.
local function GroupOfCopy()
    local of = getDB("echoGroupOf", D.echoGroupOf)
    local copy = {}
    if type(of) == "table" then
        for k, v in pairs(of) do copy[k] = v end
    end
    return copy
end

-- A fresh copy of the group-index -> chosen-icon table.
local function GroupIconsCopy()
    local icons = getDB("echoGroupIcons", D.echoGroupIcons)
    local copy = {}
    if type(icons) == "table" then
        for k, v in pairs(icons) do copy[k] = v end
    end
    return copy
end

options[#options + 1] = Section(L["ECHO_SECTION_GROUPS"])
options[#options + 1] = Toggle(L["ECHO_GROUPS_ENABLE"], L["ECHO_GROUPS_ENABLE_DESC"], "echoGroupsEnabled", D.echoGroupsEnabled)

for i = 1, 4 do
    options[#options + 1] = {
        type = "editbox", name = L["ECHO_GROUP_NAME"]:format(i), labelText = L["ECHO_GROUP_NAME"]:format(i),
        tooltip = L["ECHO_GROUP_NAME_DESC"], height = 24,
        dbKey = (i == 1) and "echoGroupNames" or nil,
        get = function()
            local names = getDB("echoGroupNames", D.echoGroupNames)
            if type(names) ~= "table" or type(names[i]) ~= "string" then return "" end
            return names[i]
        end,
        set = function(v)
            local copy = GroupNamesCopy()
            copy[i] = (type(v) == "string") and v or ""
            setDB("echoGroupNames", copy)
        end,
    }
    options[#options + 1] = Button(L["ECHO_GROUP_ICON"], L["ECHO_GROUP_ICON_DESC"], function()
        local names = getDB("echoGroupNames", D.echoGroupNames)
        local name = (type(names) == "table" and type(names[i]) == "string" and names[i]:find("%S"))
            and names[i] or string.format(L["ECHO_GROUP_DEFAULT_TITLE"], i)
        if not addon.OpenIconPicker then return end
        addon.OpenIconPicker({
            title = name,
            get = function()
                local icons = getDB("echoGroupIcons", D.echoGroupIcons)
                return (type(icons) == "table") and icons[i] or nil
            end,
            set = function(icon)
                local copy = GroupIconsCopy()
                copy[i] = icon
                setDB("echoGroupIcons", copy)
            end,
            allowDefault = true,
        })
    end, (i == 1) and { dbKey = "echoGroupIcons" } or nil)
end

for i, member in ipairs(GROUP_MEMBERS) do
    local id = member.id
    options[#options + 1] = {
        type = "dropdown", name = member.label, desc = L["ECHO_GROUP_MEMBER_DESC"],
        dbKey = (i == 1) and "echoGroupOf" or nil,
        preserveOrder = true,
        options = function()
            local names = getDB("echoGroupNames", D.echoGroupNames)
            -- Only named groups are offered; a blank-named group groups nothing, so it isn't
            -- worth choosing even when something is still (stale) assigned to it.
            local opts = { { L["ECHO_GROUP_NONE"], "none" } }
            for gi = 1, 4 do
                local name = (type(names) == "table") and names[gi] or nil
                if type(name) == "string" and name:find("%S") then
                    opts[#opts + 1] = { name, gi }
                end
            end
            return opts
        end,
        -- nil and false both read as "None": false is the explicit "not grouped, no
        -- ch:* fallback" marker an exact channel writes below.
        get = function()
            local of = getDB("echoGroupOf", D.echoGroupOf)
            local v = (type(of) == "table") and of[id] or nil
            if v == nil or v == false then return "none" end
            return v
        end,
        set = function(v)
            local copy = GroupOfCopy()
            if v == "none" then
                -- Lua's `and/or` idiom can't choose `false` here (it would fall through to
                -- the `or` branch), so this stays an explicit if.
                if IsExactChannel(id) then copy[id] = false else copy[id] = nil end
            else
                copy[id] = v
            end
            setDB("echoGroupOf", copy)
        end,
    }
end

local tail = {
    Section(L["ECHO_SECTION_HISTORY"]),
    Toggle(L["ECHO_SAVE_HISTORY"], L["ECHO_SAVE_HISTORY_DESC"], "echoSaveHistory", D.echoSaveHistory),
    { type = "dropdown", name = L["ECHO_HISTORY_DAYS"], desc = L["ECHO_HISTORY_DAYS_DESC"], dbKey = "echoHistoryDays",
      options = HISTORY_DAYS_OPTIONS, preserveOrder = true,
      get = function() return getDB("echoHistoryDays", D.echoHistoryDays) end,
      set = function(v) setDB("echoHistoryDays", v) end },
    Button(L["ECHO_CLEAR_HISTORY"], L["ECHO_CLEAR_HISTORY_DESC"], function()
        local E = Echo()
        if E and E.ConfirmClearHistory then E.ConfirmClearHistory() end
    end),

    Section(L["ECHO_SECTION_BLIZZARD_CHAT"]),
    Toggle(L["ECHO_HIDE_STORED"], L["ECHO_HIDE_STORED_DESC"], "echoHideStoredWhispers", D.echoHideStoredWhispers),

    Section(L["ECHO_SECTION_CARD"]),
    IntSlider("echoCardWidth",  L["ECHO_CARD_WIDTH"],  L["ECHO_CARD_SIZE_DESC"], 10),
    IntSlider("echoCardHeight", L["ECHO_CARD_HEIGHT"], L["ECHO_CARD_SIZE_DESC"], 10),
    IntSlider("echoCardTextSize", L["ECHO_CARD_TEXT_SIZE"], L["ECHO_CARD_TEXT_SIZE_DESC"], 1),
    Toggle(L["ECHO_ANIMATE_CARD"], L["ECHO_ANIMATE_CARD_DESC"], "echoAnimateCard", D.echoAnimateCard),
    { type = "dropdown", name = L["ECHO_FONT"], desc = L["ECHO_FONT_DESC"], dbKey = "echoFontPath", searchable = true,
      options = function() return addon.GetPerElementFontDropdownOptions("echoFontPath") end,
      get = function() return getDB("echoFontPath", D.echoFontPath) end,
      set = function(v) setDB("echoFontPath", v) end,
      displayFn = addon.DisplayPerElementFont, fontPreviewInList = true },
}
for _, opt in ipairs(tail) do options[#options + 1] = opt end

addon.OptionCategories[#addon.OptionCategories + 1] = {
    key = "Echo", name = L["NAME_ADDON_CHAT"], desc = L["ECHO_DESC"], moduleKey = "echo",
    options = options,
}
