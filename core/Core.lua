--[[
    Horizon Suite - Focus - Core
    DB access, easing, and main frame (HS + scroll, resize, drag, position).
    Constants, colors, fonts, and labels live in Config.lua.
]]

if not _G.HorizonSuite and not _G.HorizonSuiteBeta then _G.HorizonSuite = {} end
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

-- ---------------------------------------------------------------------------
-- Forward declarations (Lua local scoping)
-- ---------------------------------------------------------------------------

local EnsureProfilesAndMigrateLegacy

-- ---------------------------------------------------------------------------
-- Dynamic DB accessor: returns _G[addon.DB_NAME] (HorizonDB or HorizonBetaDB)
-- ---------------------------------------------------------------------------
local function rawDB()
    local db = _G[addon.DB_NAME]
    if not db then
        db = {}; _G[addon.DB_NAME] = db
    end
    return db
end

-- ==========================================================================
-- DB AND DIMENSION HELPERS (depend on Config constants)
-- ==========================================================================

--- Returns the global UI scale factor from DB (default 1, range 0.5–2).
--- All visual sizes should be multiplied by this value at render time.
--- @return number
function addon.GetUIScale()
    local v = tonumber(addon.GetDB and addon.GetDB("globalUIScale", 1) or 1) or 1
    return math.max(0.5, math.min(2, v))
end

--- Returns true when per-module scaling is enabled (overrides global scale).
--- @return boolean
function addon.IsPerModuleScaling()
    return addon.GetDB and addon.GetDB("perModuleScaling", false) or false
end

--- Returns the scale factor for a specific module.
--- When per-module scaling is on, reads the module-specific key; otherwise returns global scale.
--- @param moduleName string  "focus"|"presence"|"vista"|"insight"|"yield"
--- @return number
function addon.GetModuleScale(moduleName)
    if addon.IsPerModuleScaling() then
        local key = moduleName .. "UIScale"
        local v = tonumber(addon.GetDB and addon.GetDB(key, 1) or 1) or 1
        return math.max(0.5, math.min(2, v))
    end
    return addon.GetUIScale()
end

--- Scale a value by the global UI scale factor.
--- @param value number The base value (user-configured or constant).
--- @return number
function addon.Scaled(value)
    if not value then return 0 end
    return value * addon.GetModuleScale("focus")
end

--- Scale a value by a specific module's scale factor.
--- @param value number
--- @param moduleName string  "focus"|"presence"|"vista"|"insight"|"yield"
--- @return number
function addon.ScaledForModule(value, moduleName)
    if not value then return 0 end
    return value * addon.GetModuleScale(moduleName)
end

--- Scale and floor a value (pixel-snapping for frame sizes).
--- @param value number
--- @return number
function addon.ScaledFloor(value)
    return math.floor(addon.Scaled(value))
end

--- Frequently-used scaled constants (convenience wrappers).
function addon.GetScaledPadding()       return addon.Scaled(addon.PADDING) end
function addon.GetScaledDividerHeight() return addon.Scaled(addon.DIVIDER_HEIGHT) end
function addon.GetScaledMinHeight()     return addon.Scaled(addon.MIN_HEIGHT) end
function addon.GetScaledMinimalHeaderHeight() return addon.Scaled(addon.MINIMAL_HEADER_HEIGHT) end
function addon.GetScaledContentRightPadding() return addon.Scaled(addon.CONTENT_RIGHT_PADDING or 0) end
function addon.GetScaledItemBtnSize()   return addon.Scaled(addon.ITEM_BTN_SIZE) end
function addon.GetScaledLfgBtnSize()    return addon.Scaled(addon.LFG_BTN_SIZE) end
function addon.GetScaledBarLeftOffset() return addon.Scaled(addon.BAR_LEFT_OFFSET) end
function addon.GetScaledScrollStep()    return addon.Scaled(addon.SCROLL_STEP) end


--- Returns the active spacing mode: "default"|"compact"|"spaced"|"custom". Handles legacy bool values.
--- @return string
function addon.GetSpacingMode()
    local mode = addon.GetDB("compactMode", "default")
    if mode == true then return "compact" end
    if mode == false then return "default" end
    return mode or "default"
end

function addon.GetTitleSpacing()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].titleSpacing)
    end
    local v = tonumber(addon.GetDB("customTitleSpacing", nil)) or tonumber(addon.GetDB("titleSpacing", 8)) or 8
    return addon.Scaled(math.max(2, math.min(20, v)))
end
function addon.GetObjSpacing()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].objSpacing)
    end
    local v = tonumber(addon.GetDB("customObjSpacing", nil)) or tonumber(addon.GetDB("objSpacing", 2)) or 2
    return addon.Scaled(math.max(0, math.min(8, v)))
end

--- Returns the vertical gap between quest title and the content below (zone, objectives, etc.).
--- @return number Scaled pixels
function addon.GetTitleToContentSpacing()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].titleToContentSpacing)
    end
    local v = tonumber(addon.GetDB("customTitleToContentSpacing", nil)) or tonumber(addon.GetDB("titleToContentSpacing", 2)) or 2
    return addon.Scaled(math.max(0, math.min(12, v)))
end

function addon.GetSectionSpacing()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].sectionSpacing)
    end
    local v = tonumber(addon.GetDB("customSectionSpacing", nil)) or tonumber(addon.GetDB("sectionSpacing", 10)) or 10
    return addon.Scaled(math.max(0, math.min(24, v)))
end

--- Returns the color multiplier for non-focused entries (0–1 range). Default 0.60 (40% dim).
function addon.GetDimFactor()
    local strength = tonumber(addon.GetDB("dimStrength", 40)) or 40
    return 1 - math.max(0, math.min(100, strength)) / 100
end

--- Returns the alpha for non-focused entries (0–1 range). Default 1.0 (no alpha change).
function addon.GetDimAlpha()
    local v = tonumber(addon.GetDB("dimAlpha", 100)) or 100
    return math.max(0, math.min(100, v)) / 100
end

--- Applies dimming (color multiply) and optional desaturation to a color table.
--- @param color table {r,g,b} input color
--- @return table {r,g,b} dimmed color
function addon.ApplyDimColor(color)
    if not color or not color[1] then return color end
    local factor = addon.GetDimFactor()
    local r, g, b = color[1] * factor, color[2] * factor, color[3] * factor
    if addon.GetDB("dimDesaturate", false) then
        local lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        -- Partial desaturation: blend 70% towards greyscale
        r = r + (lum - r) * 0.7
        g = g + (lum - g) * 0.7
        b = b + (lum - b) * 0.7
    end
    return { r, g, b }
end
function addon.GetSectionToEntryGap()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].sectionToEntryGap)
    end
    local v = tonumber(addon.GetDB("customSectionToEntryGap", nil)) or tonumber(addon.GetDB("sectionToEntryGap", 6)) or 6
    return addon.Scaled(math.max(0, math.min(16, v)))
end

--- Returns section header frame height from section font size so text is not clipped.
--- @return number
function addon.GetSectionHeaderHeight()
    local sz = math.max(8, (tonumber(addon.GetDB("sectionFontSize", 10)) or 10) + (tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0))
    return addon.Scaled(math.max(addon.SECTION_SIZE + 4, sz + 6))
end

function addon.GetObjIndent()
    local mode = addon.GetSpacingMode()
    -- compact uses COMPACT_OBJ_INDENT; default, spaced, custom use OBJ_INDENT
    local v = (mode == "compact") and addon.COMPACT_OBJ_INDENT or addon.OBJ_INDENT
    return addon.Scaled(v)
end

function addon.GetPanelWidth()
    local v = tonumber(addon.GetDB("panelWidth", addon.PANEL_WIDTH)) or addon.PANEL_WIDTH
    return addon.Scaled(v)
end
function addon.GetMaxContentHeight()
    local v = tonumber(addon.GetDB("maxContentHeight", addon.MAX_CONTENT_HEIGHT)) or addon.MAX_CONTENT_HEIGHT
    if v < 200 then v = addon.MAX_CONTENT_HEIGHT end
    return addon.Scaled(v)
end

--- Returns the header text color from DB or default.
--- When Focus class colour is enabled, RGB uses the player class colour.
--- @return table {r,g,b}
function addon.GetHeaderColor()
    local c = addon.GetDB("headerColor", nil)
    local r, g, b
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        r, g, b = c[1], c[2], c[3]
    else
        r, g, b = addon.HEADER_COLOR[1], addon.HEADER_COLOR[2], addon.HEADER_COLOR[3]
    end
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if cc then
        r, g, b = cc[1], cc[2], cc[3]
    end
    return { r, g, b }
end

--- Returns section divider colour between Focus groups; alpha follows DB/default.
--- When Focus class colour is enabled, RGB uses the player class colour.
--- @return table {r,g,b,a}
function addon.GetSectionDividerColor()
    local c = addon.GetDB("sectionDividerColor", nil)
    local r, g, b, a
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        r, g, b = c[1], c[2], c[3]
        a = (c[4] and type(c[4]) == "number") and c[4] or 0.4
    else
        r, g, b, a = 0.3, 0.3, 0.35, 0.4
    end
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if cc then
        r, g, b = cc[1], cc[2], cc[3]
    end
    return { r, g, b, a }
end

--- Returns the header divider color from DB or default.
--- When Focus class colour is enabled, RGB is tinted to the player class colour; alpha follows DB/default.
--- @return table {r,g,b,a}
function addon.GetHeaderDividerColor()
    local c = addon.GetDB("headerDividerColor", nil)
    local r, g, b, a
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        r, g, b = c[1], c[2], c[3]
        a = (c[4] and type(c[4]) == "number") and c[4] or 0.5
    else
        local d = addon.DIVIDER_COLOR
        r, g, b, a = d[1], d[2], d[3], (d[4] or 0.5)
    end
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if cc then
        r, g, b = cc[1], cc[2], cc[3]
    end
    return { r, g, b, a }
end

local HEADER_CHROME_DEFAULT = { 0.60, 0.65, 0.75 }
local HEADER_CHROME_HOVER_BUMP = 0.25

--- RGB for Focus header chrome: quest count, chevron, and options label. Uses class colour when Focus tint is on.
--- @return table {r,g,b}
function addon.GetHeaderChromeColor()
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("focus")
    if cc then
        return { cc[1], cc[2], cc[3] }
    end
    return { HEADER_CHROME_DEFAULT[1], HEADER_CHROME_DEFAULT[2], HEADER_CHROME_DEFAULT[3] }
end

--- Brighter chrome for the options button while hovered.
--- @return table {r,g,b}
function addon.GetHeaderChromeHoverColor()
    local c = addon.GetHeaderChromeColor()
    return {
        math.min(1, c[1] + HEADER_CHROME_HOVER_BUMP),
        math.min(1, c[2] + HEADER_CHROME_HOVER_BUMP),
        math.min(1, c[3] + HEADER_CHROME_HOVER_BUMP),
    }
end

--- Apply base (non-hover) colours to quest count, chevron, and options label.
--- @return nil
function addon.ApplyHeaderChromeColors()
    if not addon.GetHeaderChromeColor then return end
    local c = addon.GetHeaderChromeColor()
    if addon.countText and addon.countText.SetTextColor then
        addon.countText:SetTextColor(c[1], c[2], c[3], 1)
    end
    if addon.chevron and addon.chevron.SetTextColor then
        addon.chevron:SetTextColor(c[1], c[2], c[3], 1)
    end
    if addon.optionsLabel and addon.optionsLabel.SetTextColor then
        addon.optionsLabel:SetTextColor(c[1], c[2], c[3], 1)
    end
end

--- Refresh all UI that depends on per-module class colour toggles (batch Axis toggle).
--- @return nil
function addon.ApplyAllClassColorConsumers()
    if addon.ApplyOptionsClassColor then addon.ApplyOptionsClassColor() end
    if addon.ApplyDashboardClassColor then addon.ApplyDashboardClassColor() end
    if addon.ApplyPatchNotesAccent then addon.ApplyPatchNotesAccent() end
    if addon.Vista and addon.Vista.ApplyColors then addon.Vista.ApplyColors() end
    if addon.Insight and addon.Insight.ApplyInsightOptions then addon.Insight.ApplyInsightOptions() end
    if addon.Persona and addon.Persona.ApplyPersonaOptions then addon.Persona.ApplyPersonaOptions() end
    if addon.ApplyFocusColors then addon.ApplyFocusColors() end
    local fullLayout = addon.FullLayout or _G.HorizonSuite_FullLayout
    if fullLayout and not InCombatLockdown() then fullLayout() end
    if addon.Presence and addon.Presence.ApplyPresenceOptions then addon.Presence.ApplyPresenceOptions() end
    if addon.Yield and addon.Yield.ApplyYieldOptions then addon.Yield.ApplyYieldOptions() end
end

--- Returns the header bar height from DB or default, clamped to 18–48 px.
--- @return number
function addon.GetHeaderHeight()
    local v = tonumber(addon.GetDB("headerHeight", addon.HEADER_HEIGHT)) or addon.HEADER_HEIGHT
    local fontSz = math.max(8, (tonumber(addon.GetDB("headerFontSize", 16)) or 16) + (tonumber(addon.GetDB("globalFontSizeOffset", 0)) or 0))
    local minForFont = fontSz + 12
    return addon.Scaled(math.max(18, minForFont, math.min(48, v)))
end

--- Returns boss emote colour from DB or default (Presence module).
--- @return table {r,g,b}
function addon.GetPresenceBossEmoteColor()
    local c = addon.GetDB("presenceBossEmoteColor", nil)
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        return c
    end
    return addon.PRESENCE_BOSS_EMOTE_COLOR or { 1, 0.2, 0.2 }
end

--- Returns discovery line colour from DB or default (Presence module).
--- @return table {r,g,b}
function addon.GetPresenceDiscoveryColor()
    local c = addon.GetDB("presenceDiscoveryColor", nil)
    if c and type(c) == "table" and c[1] and c[2] and c[3] then
        return c
    end
    return addon.PRESENCE_DISCOVERY_COLOR or { 0.4, 1, 0.5 }
end

function addon.GetContentLeftOffset()
    -- Left gutter contains (optional) quest-type icon column.
    -- Quest item buttons live in the RIGHT gutter (shared with the LFG button).
    local showQuestIcons = addon.GetDB("showQuestTypeIcons", false)
    local base = addon.PADDING + (showQuestIcons and addon.ICON_COLUMN_WIDTH or 0)
    return addon.Scaled(math.max(addon.PADDING, base))
end

-- ==========================================================================
-- PROFILES
-- ==========================================================================

-- No "Default" profile: profiles are always character/explicitly named.
-- Each character's base profile selection is stored in HorizonDB.charProfileKeys[charName-realm].
local PROFILE_DEFAULT_KEY = nil

local function GetSpecIndexSafe()
    if _G.GetSpecialization then
        local s = _G.GetSpecialization()
        if type(s) == "number" and s >= 1 and s <= 4 then return s end
    end
    return nil
end

local _cachedCharKey = nil

local function GetCurrentCharacterProfileKey()
    if _cachedCharKey then return _cachedCharKey end
    local name = _G.UnitName and _G.UnitName("player")
    local realm = _G.GetNormalizedRealmName and _G.GetNormalizedRealmName() or (_G.GetRealmName and _G.GetRealmName())
    if type(name) ~= "string" or name == "" then return nil end
    realm = (type(realm) == "string" and realm ~= "") and realm or nil
    local key = realm and (name .. "-" .. realm) or name
    key = key:gsub("%s+", "")
    if realm then _cachedCharKey = key end
    return key
end

local function GetSpecName(specIndex)
    if type(specIndex) ~= "number" then return nil end
    if _G.GetSpecializationInfo then
        local id, name = _G.GetSpecializationInfo(specIndex)
        if type(name) == "string" and name ~= "" then return name end
    end
    return ("Spec %d"):format(specIndex)
end

function addon.ListSpecOptions()
    local out = {}
    local numSpecs = _G.GetNumSpecializations and _G.GetNumSpecializations() or 4
    for i = 1, numSpecs do
        local name = GetSpecName(i)
        if name and name ~= "" then
            out[#out + 1] = { tostring(i), name }
        end
    end
    return out
end

local function GetCharPerSpecKeys()
    local charKey = GetCurrentCharacterProfileKey()
    if not charKey then return nil end
    local db = rawDB()
    db.charPerSpecKeys = db.charPerSpecKeys or {}
    db.charPerSpecKeys[charKey] = db.charPerSpecKeys[charKey] or {}
    return db.charPerSpecKeys[charKey]
end

function addon.GetProfileModeState()
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local db = rawDB()
    local useGlobal = db.useGlobalProfile == true
    local usePerSpec = db.usePerSpecProfiles == true
    local globalKey = db.globalProfileKey
    local perSpec = GetCharPerSpecKeys()
    return useGlobal, usePerSpec, globalKey, perSpec
end

function addon.SetUseGlobalProfile(v)
    addon.EnsureDB()
    rawDB()._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    rawDB().useGlobalProfile = v and true or false
end

function addon.SetUsePerSpecProfiles(v)
    addon.EnsureDB()
    rawDB()._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    rawDB().usePerSpecProfiles = v and true or false
end

function addon.SetGlobalProfileKey(key)
    if type(key) ~= "string" or key == "" then return end
    addon.EnsureDB()
    rawDB()._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    rawDB().globalProfileKey = key
end

function addon.SetPerSpecProfileKey(specIndex, key)
    if type(specIndex) ~= "number" then return end
    if type(key) ~= "string" or key == "" then return end
    addon.EnsureDB()
    rawDB()._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    local perSpec = GetCharPerSpecKeys()
    if perSpec then
        perSpec[specIndex] = key
    end
end

function addon.GetEffectiveProfileKey()
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()

    local db = rawDB()
    local charKey = GetCurrentCharacterProfileKey()

    if db.useGlobalProfile == true then
        if type(db.globalProfileKey) == "string" and db.globalProfileKey ~= "" and db.globalProfileKey ~= "Default" then
            return db.globalProfileKey
        end
    end

    if db.usePerSpecProfiles == true then
        local spec = GetSpecIndexSafe()
        local perSpec = GetCharPerSpecKeys()
        if spec and perSpec and type(perSpec[spec]) == "string" and perSpec[spec] ~= "" and perSpec[spec] ~= "Default" then
            return perSpec[spec]
        end
    end

    if not charKey or charKey == "" then return nil end

    db.charProfileKeys = db.charProfileKeys or {}
    local selected = db.charProfileKeys[charKey] or charKey
    if selected == "Default" then selected = charKey end
    return selected
end

function addon.GetActiveProfileKey()
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    return addon.GetEffectiveProfileKey()
end

function addon.GetActiveProfile()
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local key = addon.GetEffectiveProfileKey()
    if not key or key == "" then
        addon._earlyLoadProfile = addon._earlyLoadProfile or {}
        return addon._earlyLoadProfile, nil
    end
    local db = rawDB()
    db.profiles = db.profiles or {}
    db.profiles[key] = db.profiles[key] or {}
    return db.profiles[key], key
end

function addon.SetActiveProfileKey(key)
    if type(key) ~= "string" or key == "" or key == "Default" then return end
    addon.EnsureDB()
    local db = rawDB()
    db._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    db.profiles = db.profiles or {}
    db.profiles[key] = db.profiles[key] or {}

    local charKey = GetCurrentCharacterProfileKey()
    if not charKey or charKey == "" then return end
    db.charProfileKeys = db.charProfileKeys or {}
    db.charProfileKeys[charKey] = key

    if db.useGlobalProfile == true then
        db.globalProfileKey = key
    end
end

EnsureProfilesAndMigrateLegacy = function()
    local db = rawDB()
    if db._profilesValidated then return end

    db.profiles = db.profiles or {}
    -- Axis class colour keys (migrate legacy dashboardClassColor / vistaClassColor once per profile)
    for _, prof in pairs(db.profiles) do
        if type(prof) == "table" then
            if prof.dashboardClassColor ~= nil then
                if prof.classColorDashboard == nil then prof.classColorDashboard = prof.dashboardClassColor end
                prof.dashboardClassColor = nil
            end
            if prof.vistaClassColor ~= nil then
                if prof.classColorVista == nil then prof.classColorVista = prof.vistaClassColor end
                prof.vistaClassColor = nil
            end
        end
    end
    db.charProfileKeys = db.charProfileKeys or {}
    db.charPerSpecKeys = db.charPerSpecKeys or {}

    local charKey = GetCurrentCharacterProfileKey()

    -- Ensure the Default profile always exists (empty = all default values).
    if not db.profiles["Default"] then
        db.profiles["Default"] = {}
    end

    -- If character info is not yet available (early load), skip charProfileKeys
    -- modifications to avoid creating stale entries under a partial key.
    if not charKey or charKey == "" then return end

    -- If we've already migrated, just ensure the selected key exists.
    if db._profilesMigrated then
        -- Clean up stale "Profile" entries from older early-load fallback bug.
        if db.charProfileKeys["Profile"] then
            db.charProfileKeys["Profile"] = nil
        end
        if db.profiles["Profile"] and not db.charProfileKeys[charKey] then
            db.profiles["Profile"] = nil
        end

        -- For characters that haven't picked a profile yet, default to their
        -- own character-named profile (NOT the stale shared profileKey).
        if not db.charProfileKeys[charKey] or db.charProfileKeys[charKey] == "Default" then
            db.charProfileKeys[charKey] = charKey
        end
        local activeKey = db.charProfileKeys[charKey] or charKey
        db.profiles[activeKey] = db.profiles[activeKey] or {}
        -- Validate referenced keys: reset dangling references instead of auto-creating profiles.
        if type(db.globalProfileKey) == "string" and db.globalProfileKey ~= "" then
            if not db.profiles[db.globalProfileKey] or db.globalProfileKey == "Default" then
                db.globalProfileKey = activeKey
            end
        end
        -- Per-character spec keys: initialize if missing, default all to the character's active profile.
        db.charPerSpecKeys[charKey] = db.charPerSpecKeys[charKey] or {}
        local charSpecs = db.charPerSpecKeys[charKey]
        for i = 1, 4 do
            charSpecs[i] = charSpecs[i] or activeKey
            -- Validate: if the referenced profile was deleted, reset to activeKey.
            if type(charSpecs[i]) == "string" and charSpecs[i] ~= "" then
                if not db.profiles[charSpecs[i]] or charSpecs[i] == "Default" then
                    charSpecs[i] = activeKey
                end
            end
        end
        -- Ensure fade in/out animations are explicitly set (default on for new/legacy profiles).
        for profKey, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                if prof.animations == nil then prof.animations = true end
                if prof.presenceAnimations == nil then prof.presenceAnimations = true end
            end
        end
        db._profilesValidated = true
        return
    end

    -- Migration: move legacy top-level settings into the character profile.
    db.profiles[charKey] = db.profiles[charKey] or {}

    -- Keep only options window geometry at root.
    local keepRoot = {
        optionsLeft = true,
        optionsTop = true,
        optionsPanelWidth = true,
        optionsPanelHeight = true,
        optionsGroupCollapsed = true,

        modules = true,

        profiles = true,
        profileKey = true,
        charProfileKeys = true,
        charPerSpecKeys = true,
        _profilesMigrated = true,

        -- profile mode state
        useGlobalProfile = true,
        usePerSpecProfiles = true,
        globalProfileKey = true,
        perSpecProfileKeys = true,
    }

    for k, v in pairs(db) do
        if not keepRoot[k] then
            db.profiles[charKey][k] = v
            db[k] = nil
        end
    end

    db.charProfileKeys[charKey] = charKey
    db.profileKey = charKey
    db._profilesMigrated = true

    -- Ensure fade in/out animations are explicitly set (default on).
    local prof = db.profiles[charKey]
    if type(prof) == "table" then
        if prof.animations == nil then prof.animations = true end
        if prof.presenceAnimations == nil then prof.presenceAnimations = true end
    end

    -- Initialize derived selectors.
    db.globalProfileKey = db.globalProfileKey or charKey
    db.charPerSpecKeys[charKey] = db.charPerSpecKeys[charKey] or {}
    for i = 1, 4 do
        db.charPerSpecKeys[charKey][i] = db.charPerSpecKeys[charKey][i] or charKey
    end
end


-- Ensure other files (and old saved snippets) calling the global name won't crash.
_G.EnsureProfilesAndMigrateLegacy = EnsureProfilesAndMigrateLegacy

-- ---------------------------------------------------------------------------
-- Profile helpers: list, create, delete, sanitize
-- ---------------------------------------------------------------------------

local function SanitizeProfileKey(raw)
    if type(raw) ~= "string" then return "" end
    local trimmed = raw:match("^%s*(.-)%s*$") or ""
    return trimmed
end

function addon.ListProfiles()
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local db = rawDB()
    db.profiles = db.profiles or {}
    local out = {}
    for k in pairs(db.profiles) do
        out[#out + 1] = k
    end
    table.sort(out)
    return out
end

function addon.CreateProfile(newKey, sourceKey)
    if type(newKey) ~= "string" or newKey == "" then return false end
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local db = rawDB()
    db.profiles = db.profiles or {}
    if db.profiles[newKey] then return false end
    db.profiles[newKey] = {}
    if type(sourceKey) == "string" and sourceKey ~= "" and db.profiles[sourceKey] then
        for k, v in pairs(db.profiles[sourceKey]) do
            if type(v) == "table" then
                local copy = {}
                for kk, vv in pairs(v) do copy[kk] = vv end
                db.profiles[newKey][k] = copy
            else
                db.profiles[newKey][k] = v
            end
        end
    end
    return true
end

function addon.DeleteProfile(key)
    if type(key) ~= "string" or key == "" then return false end
    if key == "Default" then return false end
    addon.EnsureDB()
    local db = rawDB()
    db._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    db.profiles = db.profiles or {}
    if not db.profiles[key] then return false end
    local activeKey = addon.GetActiveProfileKey()
    if key == activeKey then return false end
    db.profiles[key] = nil
    if db.globalProfileKey == key then
        db.globalProfileKey = activeKey
    end
    -- Clean up per-character spec keys for all characters.
    if db.charPerSpecKeys then
        for _, specMap in pairs(db.charPerSpecKeys) do
            if type(specMap) == "table" then
                for i = 1, 4 do
                    if specMap[i] == key then
                        specMap[i] = activeKey
                    end
                end
            end
        end
    end
    -- Also clean up legacy global perSpecProfileKeys if still present.
    if db.perSpecProfileKeys then
        for i = 1, 4 do
            if db.perSpecProfileKeys[i] == key then
                db.perSpecProfileKeys[i] = activeKey
            end
        end
    end
    if db.charProfileKeys then
        for ck, pk in pairs(db.charProfileKeys) do
            if pk == key then
                db.charProfileKeys[ck] = activeKey
            end
        end
    end
    return true
end

-- ---------------------------------------------------------------------------
-- Profile creation & deletion popups (UI)
-- ---------------------------------------------------------------------------

function addon.TryCreateProfile(newKey, sourceKey)
    newKey = SanitizeProfileKey(newKey)
    if newKey == "" then return false, "empty" end

    addon.EnsureDB()
    local db = rawDB()
    db.profiles = db.profiles or {}
    if db.profiles[newKey] then return false, "exists" end

    local ok = addon.CreateProfile(newKey, sourceKey)
    if not ok then return false, "failed" end

    addon.SetActiveProfileKey(newKey)
    return true
end

function addon.ShowCreateProfilePopup(sourceKey)
    addon._profilePopupSourceKey = sourceKey or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
    if StaticPopup_Show then
        StaticPopup_Show("HORIZONSUITE_CREATE_PROFILE")
    end
end

function addon.TryDeleteProfileConfirmed(key)
    if type(key) ~= "string" or key == "" then return false end
    if addon.GetActiveProfileKey and addon.GetActiveProfileKey() == key then
        return false
    end
    if addon.DeleteProfile and addon.DeleteProfile(key) then
        addon._profileDeleteKey = nil
        addon._profileCopyFrom = nil
        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
        return true
    end
    return false
end

function addon.ShowDeleteProfilePopup(key)
    addon._profilePopupDeleteKey = key
    if StaticPopup_Show then
        -- Pass profile key as arg1 so Blizzard can format dialogInfo.text safely.
        StaticPopup_Show("HORIZONSUITE_DELETE_PROFILE", key)
    end
end

if StaticPopupDialogs then
    StaticPopupDialogs["HORIZONSUITE_CREATE_PROFILE"] = StaticPopupDialogs["HORIZONSUITE_CREATE_PROFILE"] or {
        text = "Create profile",
        button1 = (_G.CREATE or "Create"),
        button2 = (_G.CANCEL or "Cancel"),
        hasEditBox = true,
        maxLetters = 32,
        editBoxWidth = 180,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if eb then
                eb:SetText("")
                eb:SetFocus()
                eb:HighlightText()
            end
        end,
        OnAccept = function(self)
            local eb = self.editBox or self.EditBox
            local name = eb and eb:GetText() or ""
            local src = addon._profilePopupSourceKey or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
            local ok, reason = addon.TryCreateProfile(name, src)
            if not ok then
                if addon.HSPrint then
                    if reason == "exists" then addon.HSPrint("Profile already exists.")
                    elseif reason == "reserved" then addon.HSPrint("That profile name is reserved.")
                    else addon.HSPrint("Invalid profile name.") end
                end
                return
            end
            -- TryCreateProfile switches active profile already.
            addon._profilePopupSourceKey = nil
            if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
            if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent then
                local btn = parent.button1 or (parent.Buttons and parent.Buttons[1])
                if btn then btn:Click() end
            end
        end,
        EditBoxOnEscapePressed = function(self)
            local parent = self:GetParent()
            if parent then
                local btn = parent.button2 or (parent.Buttons and parent.Buttons[2])
                if btn then btn:Click() end
            end
        end,
    }

    StaticPopupDialogs["HORIZONSUITE_DELETE_PROFILE"] = StaticPopupDialogs["HORIZONSUITE_DELETE_PROFILE"] or {
        text = "Delete profile '%s'?",
        button1 = (_G.DELETE or "Delete"),
        button2 = (_G.CANCEL or "Cancel"),
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnAccept = function()
            local key = addon._profilePopupDeleteKey
            addon._profilePopupDeleteKey = nil
            addon.TryDeleteProfileConfirmed(key)
        end,
        OnCancel = function()
            addon._profilePopupDeleteKey = nil
        end,
    }

    StaticPopupDialogs["HORIZONSUITE_IMPORT_PROFILE"] = StaticPopupDialogs["HORIZONSUITE_IMPORT_PROFILE"] or {
        text = "Name for imported profile:",
        button1 = (_G.OKAY or "Import"),
        button2 = (_G.CANCEL or "Cancel"),
        hasEditBox = true,
        maxLetters = 32,
        editBoxWidth = 180,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            local eb = self.editBox or self.EditBox
            if eb then
                eb:SetText("")
                eb:SetFocus()
            end
        end,
        OnAccept = function(self)
            local eb = self.editBox or self.EditBox
            local name = eb and eb:GetText() or ""
            name = name:trim()
            if name == "" then
                if addon.HSPrint then addon.HSPrint("Profile name cannot be empty.") end
                return
            end
            local str = addon._profileImportSourceString
            if not str or str == "" then
                if addon.HSPrint then addon.HSPrint("No import data.") end
                return
            end
            local ok, result = addon.ImportProfile(name, str)
            if not ok then
                if addon.HSPrint then addon.HSPrint("Import failed: " .. tostring(result)) end
                return
            end
            addon._profileImportSourceString = nil
            addon._profileImportString = nil
            addon._profileImportValid = false
            if addon.HSPrint then addon.HSPrint("Imported profile: " .. tostring(result)) end
            if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
            if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent then
                local btn = parent.button1 or (parent.Buttons and parent.Buttons[1])
                if btn then btn:Click() end
            end
        end,
        EditBoxOnEscapePressed = function(self)
            local parent = self:GetParent()
            if parent then
                local btn = parent.button2 or (parent.Buttons and parent.Buttons[2])
                if btn then btn:Click() end
            end
        end,
    }

end

-- ==========================================================================
-- URL COPY BOX (Horizon-themed)
-- Accent colour uses Axis option "Class colours - Dashboard" (GetOptionsClassColor) when enabled, else default cyan.
-- ==========================================================================

local urlCopyFrame
-- Match core/PatchNotes.lua chrome (What's New) for a consistent dialog.
local URL_COPY_W = 440
local URL_COPY_PAD = 16
local URL_COPY_ACCENT_H = 3
local URL_COPY_TITLE_H = 54
local URL_COPY_RULE_COL = { 0.13, 0.13, 0.17, 1 }
local URL_COPY_BG_COL = { 0.06, 0.06, 0.08, 0.97 }
local URL_COPY_EDGE_COL = { 0.2, 0.2, 0.26, 0.95 }
local URL_COPY_HINT_H = 14
local URL_COPY_EDIT_H = 28
local URL_COPY_BTN_H = 24
local URL_COPY_F_HEAD = "Fonts\\FRIZQT__.TTF"
local URL_COPY_F_BODY = "Fonts\\ARIALN.TTF"

local function GetURLCopyAccentRGB()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then return cc[1], cc[2], cc[3] end
    return 0.2, 0.8, 0.9
end

local function BuildURLCopyFrame()
    if urlCopyFrame then return urlCopyFrame end
    local Design = addon.Design
    local ebBg = Design and Design.QUEST_ITEM_BG or { 0.12, 0.12, 0.15, 0.95 }
    local ebBorder = Design and Design.QUEST_ITEM_BORDER or { 0.30, 0.32, 0.38, 0.6 }

    local bodyTop = URL_COPY_TITLE_H + URL_COPY_PAD
    local fH = bodyTop + URL_COPY_HINT_H + 4 + URL_COPY_EDIT_H + URL_COPY_PAD + URL_COPY_BTN_H + URL_COPY_PAD

    local f = CreateFrame("Frame", "HorizonSuiteURLCopyBox", UIParent, "BackdropTemplate")
    f:SetSize(URL_COPY_W, fH)
    f:SetPoint("CENTER", 0, 30)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:Hide()

    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(unpack(URL_COPY_BG_COL))
    f:SetBackdropBorderColor(unpack(URL_COPY_EDGE_COL))

    tinsert(UISpecialFrames, "HorizonSuiteURLCopyBox")

    local ar, ag, ab = GetURLCopyAccentRGB()
    local accentStrip = f:CreateTexture(nil, "OVERLAY")
    accentStrip:SetHeight(URL_COPY_ACCENT_H)
    accentStrip:SetPoint("TOPLEFT", 1, -1)
    accentStrip:SetPoint("TOPRIGHT", -1, -1)
    accentStrip:SetColorTexture(ar, ag, ab, 1)
    f.accentStrip = accentStrip

    local dragZone = CreateFrame("Frame", nil, f)
    dragZone:SetPoint("TOPLEFT")
    dragZone:SetPoint("TOPRIGHT")
    dragZone:SetHeight(URL_COPY_TITLE_H)
    dragZone:EnableMouse(true)
    dragZone:RegisterForDrag("LeftButton")
    dragZone:SetScript("OnDragStart", function()
        if not InCombatLockdown() then f:StartMoving() end
    end)
    dragZone:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    local suiteLbl = dragZone:CreateFontString(nil, "OVERLAY")
    suiteLbl:SetFont(URL_COPY_F_HEAD, 13, "OUTLINE")
    suiteLbl:SetPoint("TOPLEFT", dragZone, "TOPLEFT", URL_COPY_PAD, -(URL_COPY_ACCENT_H + 10))
    suiteLbl:SetText("HORIZON SUITE")
    suiteLbl:SetTextColor(0.88, 0.88, 0.92)

    local subtitleLbl = dragZone:CreateFontString(nil, "OVERLAY")
    subtitleLbl:SetFont(URL_COPY_F_BODY, 10, "")
    subtitleLbl:SetPoint("TOPLEFT", suiteLbl, "BOTTOMLEFT", 0, -3)
    subtitleLbl:SetText((addon.L and addon.L["Copy link"]) or "Copy link")
    subtitleLbl:SetTextColor(ar, ag, ab)
    f.subtitleLbl = subtitleLbl

    local closeBtn = CreateFrame("Button", nil, dragZone)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", dragZone, "TOPRIGHT", -4, -(URL_COPY_ACCENT_H + 8))
    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints()
    closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    closeX:SetFont(URL_COPY_F_HEAD, 13, "OUTLINE")
    closeX:SetPoint("CENTER")
    closeX:SetText("\195\151")
    closeX:SetTextColor(0.36, 0.36, 0.42)
    closeBtn:SetScript("OnEnter", function()
        closeX:SetTextColor(1, 1, 1)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0.2)
    end)
    closeBtn:SetScript("OnLeave", function()
        closeX:SetTextColor(0.36, 0.36, 0.42)
        closeBg:SetColorTexture(1, 0.3, 0.3, 0)
    end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local topRule = f:CreateTexture(nil, "ARTWORK")
    topRule:SetHeight(1)
    topRule:SetPoint("TOPLEFT", URL_COPY_PAD, -URL_COPY_TITLE_H)
    topRule:SetPoint("TOPRIGHT", -URL_COPY_PAD, -URL_COPY_TITLE_H)
    topRule:SetColorTexture(unpack(URL_COPY_RULE_COL))

    local hintLbl = f:CreateFontString(nil, "OVERLAY")
    hintLbl:SetFont(URL_COPY_F_BODY, 10, "")
    hintLbl:SetPoint("TOPLEFT", f, "TOPLEFT", URL_COPY_PAD, -bodyTop)
    hintLbl:SetPoint("RIGHT", f, "RIGHT", -URL_COPY_PAD, 0)
    hintLbl:SetWordWrap(true)
    hintLbl:SetNonSpaceWrap(false)
    hintLbl:SetText((addon.L and addon.L["Copy the URL below (Ctrl+C) and paste in your browser."]) or "Copy the URL below (Ctrl+C) and paste in your browser.")
    hintLbl:SetTextColor(0.42, 0.42, 0.50)

    local eb = CreateFrame("EditBox", nil, f)
    eb:SetSize(URL_COPY_W - URL_COPY_PAD * 2, URL_COPY_EDIT_H)
    eb:SetPoint("TOPLEFT", hintLbl, "BOTTOMLEFT", 0, -4)
    eb:SetPoint("RIGHT", f, "RIGHT", -URL_COPY_PAD, 0)
    eb:SetFontObject(ChatFontNormal)
    eb:SetFont("Fonts\\ARIALN.TTF", 11, "")
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(2048)
    eb:SetScript("OnEscapePressed", function() eb:ClearFocus() f:Hide() end)
    local ebBgTex = eb:CreateTexture(nil, "BACKGROUND")
    ebBgTex:SetAllPoints()
    ebBgTex:SetColorTexture(ebBg[1], ebBg[2], ebBg[3], ebBg[4] or 1)
    local ebLeft = eb:CreateTexture(nil, "BORDER")
    ebLeft:SetWidth(1)
    ebLeft:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebLeft:SetPoint("TOPLEFT", 0, 1)
    ebLeft:SetPoint("BOTTOMLEFT", 0, -1)
    local ebRight = eb:CreateTexture(nil, "BORDER")
    ebRight:SetWidth(1)
    ebRight:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebRight:SetPoint("TOPRIGHT", 0, 1)
    ebRight:SetPoint("BOTTOMRIGHT", 0, -1)
    local ebTop = eb:CreateTexture(nil, "BORDER")
    ebTop:SetHeight(1)
    ebTop:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebTop:SetPoint("TOPLEFT", 0, 0)
    ebTop:SetPoint("TOPRIGHT", 0, 0)
    local ebBottom = eb:CreateTexture(nil, "BORDER")
    ebBottom:SetHeight(1)
    ebBottom:SetColorTexture(ebBorder[1], ebBorder[2], ebBorder[3], ebBorder[4] or 1)
    ebBottom:SetPoint("BOTTOMLEFT", 0, 0)
    ebBottom:SetPoint("BOTTOMRIGHT", 0, 0)
    f.editBox = eb

    local btn = CreateFrame("Button", nil, f)
    btn:SetSize(72, URL_COPY_BTN_H)
    btn:SetPoint("BOTTOM", f, "BOTTOM", 0, URL_COPY_PAD)
    local btnBg = btn:CreateTexture(nil, "BACKGROUND")
    btnBg:SetAllPoints()
    btnBg:SetColorTexture(URL_COPY_EDGE_COL[1], URL_COPY_EDGE_COL[2], URL_COPY_EDGE_COL[3], 0.6)
    btn:SetNormalTexture(btnBg)
    local btnLabel = btn:CreateFontString(nil, "OVERLAY")
    btnLabel:SetFont(URL_COPY_F_HEAD, 10, "")
    btnLabel:SetPoint("CENTER")
    btnLabel:SetText(_G.OKAY or "Close")
    btnLabel:SetTextColor(0.9, 0.9, 0.92)
    btn:SetScript("OnClick", function() f:Hide() end)
    btn:SetScript("OnEnter", function()
        btnBg:SetColorTexture(ar * 0.5, ag * 0.5, ab * 0.5, 0.5)
    end)
    btn:SetScript("OnLeave", function()
        btnBg:SetColorTexture(URL_COPY_EDGE_COL[1], URL_COPY_EDGE_COL[2], URL_COPY_EDGE_COL[3], 0.6)
    end)

    urlCopyFrame = f
    return f
end

--- Show the URL copy box (same chrome as What's New / Patch Notes). User can Ctrl+C from the edit box and paste in a browser.
--- @param url string Full URL to display and copy
--- @param accentSubtitle string|nil Second header line (accent colour), e.g. "Copy link — Discord"; defaults to L["Copy link"]
function addon.ShowURLCopyBox(url, accentSubtitle)
    if not url or type(url) ~= "string" or url == "" then return end
    local f = BuildURLCopyFrame()
    if not f or not f.editBox then return end
    local ar, ag, ab = GetURLCopyAccentRGB()
    if f.accentStrip then
        f.accentStrip:SetColorTexture(ar, ag, ab, 1)
    end
    if f.subtitleLbl then
        f.subtitleLbl:SetText(accentSubtitle or ((addon.L and addon.L["Copy link"]) or "Copy link"))
        f.subtitleLbl:SetTextColor(ar, ag, ab)
    end
    f.editBox:SetText(url)
    f:Show()
    -- Defer focus and highlight so the edit box is ready and Ctrl+C works immediately (WoW quirk).
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if f:IsShown() and f.editBox then
                f.editBox:SetFocus()
                f.editBox:HighlightText()
            end
        end)
    else
        f.editBox:SetFocus()
        f.editBox:HighlightText()
    end
end

--- Refresh URL copy dialog accent if visible (e.g. when Dashboard class colour option changes).
--- @return nil
function addon.ApplyURLCopyBoxAccent()
    if not urlCopyFrame or not urlCopyFrame:IsShown() then return end
    local ar, ag, ab = GetURLCopyAccentRGB()
    if urlCopyFrame.accentStrip then
        urlCopyFrame.accentStrip:SetColorTexture(ar, ag, ab, 1)
    end
    if urlCopyFrame.subtitleLbl then
        urlCopyFrame.subtitleLbl:SetTextColor(ar, ag, ab)
    end
end

-- ==========================================================================
-- PROFILE EXPORT / IMPORT
-- ==========================================================================

local EXPORT_HEADER = "HSP2:"

-- Base64 encode/decode (pure Lua, no dependencies)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)
        b = b or 0; c = c or 0
        local n = a * 65536 + b * 256 + c
        local remain = #data - i + 1
        out[#out + 1] = B64:sub(math.floor(n / 262144) % 64 + 1, math.floor(n / 262144) % 64 + 1)
        out[#out + 1] = B64:sub(math.floor(n / 4096) % 64 + 1, math.floor(n / 4096) % 64 + 1)
        out[#out + 1] = remain > 1 and B64:sub(math.floor(n / 64) % 64 + 1, math.floor(n / 64) % 64 + 1) or "="
        out[#out + 1] = remain > 2 and B64:sub(n % 64 + 1, n % 64 + 1) or "="
    end
    return table.concat(out)
end

local B64INV = {}
for i = 1, #B64 do B64INV[B64:byte(i)] = i - 1 end

local function b64decode(data)
    data = data:gsub("[^A-Za-z0-9%+/=]", "")
    local out = {}
    for i = 1, #data, 4 do
        local a, b, c, d = data:byte(i, i + 3)
        a = B64INV[a] or 0; b = B64INV[b] or 0
        c = B64INV[c or 0] or 0; d = B64INV[d or 0] or 0
        local n = a * 262144 + b * 4096 + c * 64 + d
        out[#out + 1] = string.char(math.floor(n / 65536) % 256)
        if data:sub(i + 2, i + 2) ~= "=" then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
        if data:sub(i + 3, i + 3) ~= "=" then out[#out + 1] = string.char(n % 256) end
    end
    return table.concat(out)
end

-- Compact Lua table serializer (supports string/number/boolean/nested table).
-- Format per value: type tag + content. Pairs joined by \n, key\tvalue per pair.
-- Nested tables are length-prefixed: "T" .. len .. ":" .. serialized_content
local function SerializeValue(v)
    local tv = type(v)
    if tv == "string" then
        return "s" .. v:gsub("\\", "\\\\"):gsub("\t", "\\t"):gsub("\n", "\\n")
    elseif tv == "number" then return "n" .. tostring(v)
    elseif tv == "boolean" then return v and "B1" or "B0"
    elseif tv == "table" then
        local parts = {}
        for k, vv in pairs(v) do
            local sk = SerializeValue(k)
            local sv = SerializeValue(vv)
            if sk and sv then parts[#parts + 1] = sk .. "\t" .. sv end
        end
        local body = table.concat(parts, "\n")
        return "T" .. #body .. ":" .. body
    end
    return nil
end

local function DeserializeValue(str, pos)
    if not str or not pos or pos > #str then return nil, pos end
    local tag = str:sub(pos, pos)
    if tag == "s" then
        local nl = str:find("[\t\n]", pos + 1)
        local raw
        if not nl then raw = str:sub(pos + 1); nl = #str + 1
        else raw = str:sub(pos + 1, nl - 1) end
        return raw:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("\\\\", "\\"), nl
    elseif tag == "n" then
        local nl = str:find("[\t\n]", pos + 1)
        if not nl then return tonumber(str:sub(pos + 1)), #str + 1 end
        return tonumber(str:sub(pos + 1, nl - 1)), nl
    elseif tag == "B" then
        return str:sub(pos + 1, pos + 1) == "1", pos + 2
    elseif tag == "T" then
        local colon = str:find(":", pos + 1)
        if not colon then return nil, pos end
        local len = tonumber(str:sub(pos + 1, colon - 1))
        if not len then return nil, pos end
        local body = str:sub(colon + 1, colon + len)
        local tbl = {}
        local p = 1
        while p <= #body do
            local k, v
            local tabPos = body:find("\t", p)
            if not tabPos then break end
            k = DeserializeValue(body, p)
            p = tabPos + 1
            local nlPos = nil
            if body:sub(p, p) == "T" then
                local innerColon = body:find(":", p + 1)
                if innerColon then
                    local innerLen = tonumber(body:sub(p + 1, innerColon - 1))
                    if innerLen then nlPos = innerColon + innerLen + 1 end
                end
            end
            if not nlPos then nlPos = body:find("\n", p) end
            if nlPos then
                v = DeserializeValue(body, p)
                p = nlPos + 1
            else
                v = DeserializeValue(body, p)
                p = #body + 1
            end
            if k ~= nil and v ~= nil then tbl[k] = v end
        end
        return tbl, colon + len + 1
    end
    return nil, pos + 1
end

local EXPORT_STRIP_PREFIXES = { "vistaButtonManaged_" }
local EXPORT_STRIP_KEYS     = { vistaButtonWhitelist = true }

local function StripMachineSpecificKeys(src)
    local copy = {}
    for k, v in pairs(src) do
        local dominated = EXPORT_STRIP_KEYS[k]
        if not dominated then
            for _, prefix in ipairs(EXPORT_STRIP_PREFIXES) do
                if type(k) == "string" and k:sub(1, #prefix) == prefix then
                    dominated = true
                    break
                end
            end
        end
        if not dominated then
            copy[k] = v
        end
    end
    return copy
end

function addon.ExportProfile(key)
    if type(key) ~= "string" or key == "" then return nil end
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local db = rawDB()
    db.profiles = db.profiles or {}
    local profile
    local activeKey = addon.GetEffectiveProfileKey()
    if activeKey and activeKey == key then
        profile = addon.GetActiveProfile()
    else
        profile = db.profiles[key]
    end
    if not profile or type(profile) ~= "table" or next(profile) == nil then return nil end
    -- Strip machine-specific addon button selections before serialization.
    local cleaned = StripMachineSpecificKeys(profile)
    if not next(cleaned) then return nil end
    local serialized = SerializeValue(cleaned)
    if not serialized then return nil end
    return EXPORT_HEADER .. b64encode(serialized)
end

function addon.ValidateProfileString(str)
    if type(str) ~= "string" or str == "" then return false end
    if str:sub(1, 5) ~= "HSP2:" then return false end
    local payload = str:sub(6)
    if payload == "" then return false end
    local ok, decoded = pcall(b64decode, payload)
    if not ok or type(decoded) ~= "string" or decoded == "" then return false end
    if decoded:sub(1, 1) ~= "T" then return false end
    local tbl = DeserializeValue(decoded, 1)
    return type(tbl) == "table" and next(tbl) ~= nil
end

function addon.ImportProfile(name, dataString)
    if type(name) ~= "string" or name == "" then return false, "invalid" end
    if type(dataString) ~= "string" or dataString == "" then return false, "invalid" end
    if dataString:sub(1, 5) ~= "HSP2:" then return false, "invalid" end

    local payload = dataString:sub(6)
    local ok, decoded = pcall(b64decode, payload)
    if not ok or type(decoded) ~= "string" or decoded == "" then return false, "corrupt" end
    local tbl = DeserializeValue(decoded, 1)
    if type(tbl) ~= "table" or next(tbl) == nil then return false, "corrupt" end

    tbl = StripMachineSpecificKeys(tbl)
    if not next(tbl) then return false, "corrupt" end

    addon.EnsureDB()
    local db = rawDB()
    db._profilesValidated = nil
    EnsureProfilesAndMigrateLegacy()
    db.profiles = db.profiles or {}

    local finalName = name
    if db.profiles[finalName] then
        local base = finalName
        local i = 2
        while db.profiles[base .. " " .. i] do i = i + 1 end
        finalName = base .. " " .. i
    end

    db.profiles[finalName] = tbl

    local charKey = GetCurrentCharacterProfileKey()
    if charKey and charKey ~= "" then
        db.charProfileKeys = db.charProfileKeys or {}
        db.charProfileKeys[charKey] = finalName
    end

    return true, finalName
end

-- ==========================================================================
-- SPEC CHANGE: apply per-spec profile when the player swaps specialization
-- ==========================================================================

local specChangeFrame = CreateFrame("Frame")
specChangeFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specChangeFrame:SetScript("OnEvent", function(_, event, unit)
    if unit and unit ~= "player" then return end
    local db = rawDB()
    if not db then return end
    if db.useGlobalProfile == true then return end
    if db.usePerSpecProfiles ~= true then return end

    db._profilesValidated = nil

    local newKey = addon.GetEffectiveProfileKey and addon.GetEffectiveProfileKey()
    if addon.HSPrint then
        addon.HSPrint("Spec changed, switching to profile: " .. tostring(newKey))
    end

    C_Timer.After(0.1, function()
        if addon.RestoreSavedPosition then addon.RestoreSavedPosition() end
        if addon.UpdateResizeHandleVisibility then addon.UpdateResizeHandleVisibility() end
        if addon.OptionsData_NotifyMainAddon then addon.OptionsData_NotifyMainAddon() end
        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
    end)
end)

-- ==========================================================================
-- DB ACCESS
-- ==========================================================================

function addon.GetDB(key, default)
    if not _G[addon.DB_NAME] then return default end
    EnsureProfilesAndMigrateLegacy()
    local profile = addon.GetActiveProfile()
    local v = profile[key]
    if v == nil then return default end
    return v
end

function addon.SetDB(key, value)
    addon.EnsureDB()
    EnsureProfilesAndMigrateLegacy()
    local profile = addon.GetActiveProfile()
    profile[key] = value
end

--- Resolves combat visibility mode, migrating from legacy hideInCombat if needed.
--- @return string "show" | "fade" | "hide"
function addon.GetCombatVisibility()
    local v = addon.GetDB("combatVisibility", nil)
    if v == "show" or v == "fade" or v == "hide" then return v end
    -- Migrate from legacy hideInCombat
    if addon.GetDB("hideInCombat", false) then return "hide" end
    return "show"
end

function addon.ShouldHideInCombat()
    return (addon.GetCombatVisibility() == "hide") and UnitAffectingCombat("player")
end

--- Whether combat fade mode is currently active.
--- @return boolean
function addon.ShouldFadeInCombat()
    return (addon.GetCombatVisibility() == "fade") and UnitAffectingCombat("player")
end

--- Combat fade opacity (0..1) used for combat visibility Fade mode.
--- @return number
function addon.GetCombatFadeAlpha()
    local pct = tonumber(addon.GetDB("combatFadeOpacity", 30)) or 30
    return math.max(0, math.min(100, pct)) / 100
end

function addon.EnsureDB()
    rawDB() -- ensures _G[DB_NAME] exists
    if addon._ensureDBInProgress then return end
    addon._ensureDBInProgress = true
    if addon.EnsureModulesDB then addon:EnsureModulesDB() end
    EnsureProfilesAndMigrateLegacy()
    -- One-time migration from legacy hideInCombat toggle.
    -- Check both the active profile and the root DB for the legacy key,
    -- then write the migrated value into the active profile where GetDB reads it.
    local profile = addon.GetActiveProfile()
    if profile and profile.combatVisibility == nil then
        local legacyHide = profile.hideInCombat
        if legacyHide == nil then legacyHide = rawDB().hideInCombat end
        if legacyHide ~= nil then
            profile.combatVisibility = legacyHide and "hide" or "show"
        end
    end
    addon._ensureDBInProgress = nil
end

-- ==========================================================================
-- FOCUS CATEGORY COLLAPSE (per-profile)
-- ==========================================================================

function addon.IsCategoryCollapsed(groupKey)
    if type(groupKey) ~= "string" or groupKey == "" then return false end
    local t = addon.GetDB("collapsedCategories", nil)
    if type(t) ~= "table" then return false end
    return t[groupKey] == true
end

function addon.AreAllCategoriesCollapsed(grouped)
    if not grouped or #grouped == 0 then return false end
    for _, grp in ipairs(grouped) do
        if not addon.IsCategoryCollapsed(grp.key) then return false end
    end
    return true
end

function addon.SetCategoryCollapsed(groupKey, collapsed)
    if type(groupKey) ~= "string" or groupKey == "" then return end
    local t = addon.GetDB("collapsedCategories", nil)
    if type(t) ~= "table" then t = {} end
    t[groupKey] = collapsed and true or nil
    addon.SetDB("collapsedCategories", t)
end

-- ============================================================================
-- EASING FUNCTIONS
-- ============================================================================

function addon.easeOut(t)  return 1 - (1 - t) * (1 - t) end
function addon.easeIn(t)   return t * t end

-- ============================================================================
-- FRAME SETUP
-- ============================================================================

local HS = CreateFrame("Frame", "HSFrame", UIParent)
HS:SetSize(addon.GetPanelWidth(), addon.MIN_HEIGHT)
HS:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", addon.PANEL_X, addon.PANEL_Y)
HS:SetFrameStrata("MEDIUM")
HS:SetClampedToScreen(true)
HS:Hide()

local hsBg = HS:CreateTexture(nil, "BACKGROUND")
hsBg:SetAllPoints(HS)
local backdropColor = (addon.Design and addon.Design.BACKDROP_COLOR) or { 0.08, 0.08, 0.12, 0.90 }
hsBg:SetColorTexture(backdropColor[1], backdropColor[2], backdropColor[3], backdropColor[4] or 1)
addon.hsBg = hsBg

local borderColor = (addon.Design and addon.Design.BORDER_COLOR) or nil
local hsBorderT, hsBorderB, hsBorderL, hsBorderR = addon.CreateBorder(HS, borderColor)
addon.hsBorderT, addon.hsBorderB = hsBorderT, hsBorderB
addon.hsBorderL, addon.hsBorderR = hsBorderL, hsBorderR

function addon.ApplyBackdropOpacity()
    if not addon.hsBg then return end
    local a = tonumber(addon.GetDB("backdropOpacity", 0)) or 0
    local r = tonumber(addon.GetDB("backdropColorR", 0.08)) or 0.08
    local g = tonumber(addon.GetDB("backdropColorG", 0.08)) or 0.08
    local b = tonumber(addon.GetDB("backdropColorB", 0.12)) or 0.12
    addon.hsBg:SetColorTexture(r, g, b, math.max(0, math.min(1, a)))
end

function addon.ApplyBorderVisibility()
    local show = addon.GetDB("showBorder", false)
    if addon.hsBorderT then addon.hsBorderT:SetShown(show) end
    if addon.hsBorderB then addon.hsBorderB:SetShown(show) end
    if addon.hsBorderL then addon.hsBorderL:SetShown(show) end
    if addon.hsBorderR then addon.hsBorderR:SetShown(show) end
end

local headerShadow = HS:CreateFontString(nil, "BORDER")
headerShadow:SetFontObject(addon.HeaderFont)
headerShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
headerShadow:SetJustifyH("LEFT")
headerShadow:SetText(addon.L["OBJECTIVES"])

local headerText = HS:CreateFontString(nil, "OVERLAY")
headerText:SetFontObject(addon.HeaderFont)
do
    local c = addon.GetHeaderColor()
    headerText:SetTextColor(c[1], c[2], c[3], 1)
end
headerText:SetJustifyH("LEFT")
headerText:SetPoint("TOPLEFT", HS, "TOPLEFT", addon.PADDING, -addon.PADDING)
headerText:SetText(addon.L["OBJECTIVES"])
headerShadow:SetPoint("CENTER", headerText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

local countText = HS:CreateFontString(nil, "OVERLAY")
countText:SetFontObject(addon.ObjFont)
do
    local ch = addon.GetHeaderChromeColor()
    countText:SetTextColor(ch[1], ch[2], ch[3], 1)
end
countText:SetJustifyH("RIGHT")
countText:SetPoint("TOPRIGHT", HS, "TOPRIGHT", -addon.PADDING, -addon.PADDING - 3)

local countShadow = HS:CreateFontString(nil, "BORDER")
countShadow:SetFontObject(addon.ObjFont)
countShadow:SetTextColor(0, 0, 0, addon.SHADOW_A)
countShadow:SetJustifyH("RIGHT")
countShadow:SetPoint("CENTER", countText, "CENTER", addon.SHADOW_OX, addon.SHADOW_OY)

local chevron = HS:CreateFontString(nil, "OVERLAY")
chevron:SetFontObject(addon.ObjFont)
do
    local ch = addon.GetHeaderChromeColor()
    chevron:SetTextColor(ch[1], ch[2], ch[3], 1)
end
chevron:SetJustifyH("RIGHT")
chevron:SetPoint("RIGHT", countText, "LEFT", -6, 0)
chevron:SetText("-")

local optionsBtn = CreateFrame("Button", nil, HS)
local optionsLabel = optionsBtn:CreateFontString(nil, "OVERLAY")
optionsLabel:SetFontObject(addon.ObjFont)
do
    local ch = addon.GetHeaderChromeColor()
    optionsLabel:SetTextColor(ch[1], ch[2], ch[3], 1)
end
optionsLabel:SetJustifyH("RIGHT")
optionsLabel:SetText(addon.L["Options"])
optionsBtn:SetSize(math.max(optionsLabel:GetStringWidth() + 4, 44), 20)
optionsBtn:SetPoint("RIGHT", chevron, "LEFT", -6, 0)
optionsLabel:SetPoint("RIGHT", optionsBtn, "RIGHT", -2, 0)
-- Delayed tooltip hide: cancels if mouse re-enters within 0.15s (stops flicker when cursor briefly leaves)
local optionsTooltipHideRequested = false
optionsBtn:SetScript("OnClick", function()
    if addon.ShowDashboard then
        addon.ShowDashboard()
    elseif _G.HorizonSuite_ShowDashboard then
        _G.HorizonSuite_ShowDashboard()
    end
end)
optionsBtn:SetScript("OnEnter", function(self)
    optionsTooltipHideRequested = false
    local hi = addon.GetHeaderChromeHoverColor and addon.GetHeaderChromeHoverColor() or { 0.85, 0.85, 0.90 }
    optionsLabel:SetTextColor(hi[1], hi[2], hi[3], 1)
    -- Super-minimal: keep chevron and options visible when hovering options (header OnLeave fires when we move here)
    if addon.GetDB("hideObjectivesHeader", false) and not addon.GetDB("hideOptionsButton", false) then
        addon.chevron:SetAlpha(1)
        addon.optionsBtn:SetAlpha(1)
    end
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(addon.L["Options"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end)
optionsBtn:SetScript("OnLeave", function()
    if addon.ApplyHeaderChromeColors then
        addon.ApplyHeaderChromeColors()
    else
        optionsLabel:SetTextColor(0.60, 0.65, 0.75, 1)
    end
    optionsTooltipHideRequested = true
    C_Timer.After(0.15, function()
        if optionsTooltipHideRequested and GameTooltip then
            GameTooltip:Hide()
        end
        optionsTooltipHideRequested = false
    end)
end)

local divider = HS:CreateTexture(nil, "ARTWORK")
divider:SetSize(addon.GetPanelWidth() - addon.PADDING * 2, addon.DIVIDER_HEIGHT)
divider:SetPoint("TOP", HS, "TOPLEFT", addon.GetPanelWidth() / 2, -(addon.PADDING + addon.GetHeaderHeight()))
do
    local dc = addon.GetHeaderDividerColor()
    divider:SetColorTexture(dc[1], dc[2], dc[3], dc[4])
end

function addon.GetHeaderToContentGap()
    local mode = addon.GetSpacingMode()
    if mode ~= "custom" and addon.SPACING_PRESETS and addon.SPACING_PRESETS[mode] then
        return addon.Scaled(addon.SPACING_PRESETS[mode].headerToContentGap)
    end
    local v = tonumber(addon.GetDB("customHeaderToContentGap", nil)) or tonumber(addon.GetDB("headerToContentGap", 6)) or 6
    return addon.Scaled(math.max(0, math.min(24, v)))
end

function addon.GetContentTop()
    -- Super-minimal: move content to start just below the minimal header row with small padding
    if addon.GetDB("hideObjectivesHeader", false) then
        return -(addon.GetScaledMinimalHeaderHeight() + addon.Scaled(4))
    end
    return -(addon.Scaled(addon.PADDING) + addon.GetHeaderHeight() + addon.Scaled(addon.DIVIDER_HEIGHT) + addon.GetHeaderToContentGap())
end
function addon.GetCollapsedHeight()
    if addon.GetDB("hideObjectivesHeader", false) then
        return addon.GetScaledMinimalHeaderHeight() + addon.Scaled(6)
    end
    return addon.GetScaledPadding() + addon.GetHeaderHeight() + addon.Scaled(6)
end

local scrollFrame = CreateFrame("Frame", nil, HS)
scrollFrame:SetClipsChildren(true)
scrollFrame:SetPoint("TOPLEFT", HS, "TOPLEFT", 0, addon.GetContentTop())
scrollFrame:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", 0, addon.PADDING)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetWidth(addon.GetPanelWidth())
scrollChild:SetHeight(1)
scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)

addon.focus = addon.focus or {}
addon.focus.layout = addon.focus.layout or {
    scrollOffset = 0,
    targetHeight = addon.MIN_HEIGHT,
    currentHeight = addon.MIN_HEIGHT,
    sectionIdx = 0,
}
addon.focus.layout.scrollOffset = 0

local function ApplyScrollOffset(offset)
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, offset)
end
addon.ApplyScrollOffset = ApplyScrollOffset

local function HandleScroll(delta)
    local childH  = scrollChild:GetHeight() or 0
    local frameH  = scrollFrame:GetHeight() or 0
    local maxScr  = math.max(childH - frameH, 0)
    local lo = addon.focus.layout
    lo.scrollOffset = math.max(0, math.min(lo.scrollOffset - delta * addon.GetScaledScrollStep(), maxScr))
    ApplyScrollOffset(lo.scrollOffset)
    if addon.UpdateScrollIndicators then addon.UpdateScrollIndicators() end
end

scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(_, delta) HandleScroll(delta) end)

HS:EnableMouseWheel(true)
HS:SetScript("OnMouseWheel", function(_, delta) HandleScroll(delta) end)

-- =========================================================================
-- Scroll overflow indicators (entry fade + arrow)
-- =========================================================================
local SCROLL_FADE_ZONE   = 48   -- px from viewport edge where fade begins
local SCROLL_FADE_MIN    = 0.08 -- minimum alpha at the very edge
local SCROLL_ARROW_SIZE  = 20

-- Arrow indicators using built-in WoW arrow textures (Buttons for click support)
local arrowBottomFrame = CreateFrame("Button", nil, HS)
arrowBottomFrame:SetSize(SCROLL_ARROW_SIZE, SCROLL_ARROW_SIZE)
arrowBottomFrame:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", -4, addon.PADDING - 2)
arrowBottomFrame:SetFrameStrata("HIGH")
arrowBottomFrame:SetFrameLevel(HS:GetFrameLevel() + 20)
arrowBottomFrame:Hide()
local arrowBottomTex = arrowBottomFrame:CreateTexture(nil, "OVERLAY")
arrowBottomTex:SetAllPoints()
arrowBottomTex:SetTexture("Interface\\BUTTONS\\Arrow-Down-Up")
arrowBottomTex:SetAlpha(0.60)
arrowBottomTex:SetDesaturated(true)
arrowBottomFrame:SetScript("OnClick", function()
    local childH = scrollChild:GetHeight() or 0
    local frameH = scrollFrame:GetHeight() or 0
    local maxScr = math.max(childH - frameH, 0)
    local lo = addon.focus.layout
    lo.scrollOffset = maxScr
    ApplyScrollOffset(lo.scrollOffset)
    if addon.UpdateScrollIndicators then addon.UpdateScrollIndicators() end
end)
arrowBottomFrame:SetScript("OnEnter", function() arrowBottomTex:SetAlpha(1) end)
arrowBottomFrame:SetScript("OnLeave", function() arrowBottomTex:SetAlpha(0.60) end)

local arrowTopFrame = CreateFrame("Button", nil, HS)
arrowTopFrame:SetSize(SCROLL_ARROW_SIZE, SCROLL_ARROW_SIZE)
arrowTopFrame:SetPoint("TOPRIGHT", HS, "TOPRIGHT", -4, -(addon.PADDING + addon.GetHeaderHeight() + addon.DIVIDER_HEIGHT + addon.GetHeaderToContentGap() - 2))
arrowTopFrame:SetFrameStrata("HIGH")
arrowTopFrame:SetFrameLevel(HS:GetFrameLevel() + 20)
arrowTopFrame:Hide()
local arrowTopTex = arrowTopFrame:CreateTexture(nil, "OVERLAY")
arrowTopTex:SetAllPoints()
arrowTopTex:SetTexture("Interface\\BUTTONS\\Arrow-Up-Up")
arrowTopTex:SetAlpha(0.60)
arrowTopTex:SetDesaturated(true)
arrowTopFrame:SetScript("OnClick", function()
    local lo = addon.focus.layout
    lo.scrollOffset = 0
    ApplyScrollOffset(0)
    if addon.UpdateScrollIndicators then addon.UpdateScrollIndicators() end
end)
arrowTopFrame:SetScript("OnEnter", function() arrowTopTex:SetAlpha(1) end)
arrowTopFrame:SetScript("OnLeave", function() arrowTopTex:SetAlpha(0.60) end)

local function UpdateScrollArrowPositions()
    local layout = addon.focus and addon.focus.layout
    local useGrowUp
    if layout and layout.useGrowUpScrollLayout ~= nil then
        useGrowUp = layout.useGrowUpScrollLayout
    else
        useGrowUp = addon.GetDB("growUp", false)
    end
    arrowBottomFrame:ClearAllPoints()
    arrowTopFrame:ClearAllPoints()
    if useGrowUp then
        local headerArea = addon.GetDB("hideObjectivesHeader", false)
            and (addon.GetScaledMinimalHeaderHeight() + addon.Scaled(4))
            or (addon.GetScaledPadding() * 2 + addon.GetHeaderHeight() + addon.GetScaledDividerHeight() + addon.GetHeaderToContentGap())
        arrowBottomFrame:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", -4, headerArea + addon.Scaled(4))
        arrowTopFrame:SetPoint("TOPRIGHT", HS, "TOPRIGHT", -4, -(addon.Scaled(4)))
    else
        arrowBottomFrame:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", -4, addon.PADDING - 2)
        arrowTopFrame:SetPoint("TOPRIGHT", HS, "TOPRIGHT", -4, -(addon.PADDING + addon.GetHeaderHeight() + addon.DIVIDER_HEIGHT + addon.GetHeaderToContentGap() - 2))
    end
end

--- Compute fade alpha for an entry based on how close it is to being clipped
--- at a viewport edge. Only fades toward edges where there IS more content.
---
--- Coordinate system: Y=0 at scrollChild top, negative downward.
---   entryTop (finalY) is e.g. -50 for an entry 50px below the top.
---   viewTop = -scrollOffset (0 when not scrolled, more negative as you scroll down)
---   viewBottom = -(scrollOffset + frameHeight)
---
--- "About to scroll off the top" means entryTop is approaching viewTop from below.
--- "About to scroll off the bottom" means entryBottom is approaching viewBottom from above.
local function ComputeEdgeFadeAlpha(entryTop, entryH, trailingSpace, leadingSpace, viewTop, viewBottom, fadeZone, fadeAtTop, fadeAtBottom)
    local entryBottom = entryTop - entryH
    local alpha = 1

    -- Fade near the TOP viewport edge (entry scrolling upward out of view).
    -- As the entry scrolls up, entryTop approaches and then exceeds viewTop.
    -- We want to start fading when entryTop (plus its leading gap) enters the fade zone.
    -- distToTopClip = how far the entry's top is below the viewport top.
    --   Large positive = safely inside; small positive = near the edge; negative = already clipped.
    if fadeAtTop then
        local distToTopClip = viewTop - (entryTop + leadingSpace)
        -- distToTopClip: negative when entry top is below viewTop (safe),
        --                positive when entry top is above viewTop (clipped).
        -- We want to fade when the entry is *near* being clipped, i.e. when
        -- distToTopClip is close to 0 from the negative side, or positive.
        -- Remap: how many px of entry remain below the viewport top?
        local pxInsideFromTop = entryBottom - viewTop  -- negative means more inside
        -- When pxInsideFromTop is close to 0, almost none of the entry is visible.
        -- It's negative and large when the entry is fully visible.
        -- We want: fade when |pxInsideFromTop| < fadeZone and it's negative (entry mostly gone)
        local visibleFromTop = -(pxInsideFromTop)  -- positive = how much is visible below viewTop
        if visibleFromTop >= 0 and visibleFromTop < fadeZone then
            local t = visibleFromTop / fadeZone
            -- Quadratic curve: fades more aggressively at the start of the zone
            alpha = math.min(alpha, SCROLL_FADE_MIN + (1 - SCROLL_FADE_MIN) * (t * t))
        elseif visibleFromTop < 0 then
            -- Entry is fully above viewport top; shouldn't happen for shown entries, but clamp
            alpha = SCROLL_FADE_MIN
        end
    end

    -- Fade near the BOTTOM viewport edge (entry scrolling downward out of view).
    -- As the entry scrolls down toward the bottom, entryBottom approaches viewBottom.
    -- visibleFromBottom = how much of the entry (from its top) remains above the viewport bottom.
    if fadeAtBottom then
        local visibleFromBottom = (entryTop - trailingSpace) - viewBottom
        -- Large positive = plenty visible; approaching 0 = almost clipped off.
        if visibleFromBottom >= 0 and visibleFromBottom < fadeZone then
            local t = visibleFromBottom / fadeZone
            -- Quadratic curve: fades more aggressively at the start of the zone
            alpha = math.min(alpha, SCROLL_FADE_MIN + (1 - SCROLL_FADE_MIN) * (t * t))
        elseif visibleFromBottom < 0 then
            alpha = SCROLL_FADE_MIN
        end
    end

    return math.max(SCROLL_FADE_MIN, math.min(1, alpha))
end

local function ApplyScrollFade(entry, viewTop, viewBottom, fadeZone, fadeAtTop, fadeAtBottom)
    if not entry or not entry.IsShown or not entry:IsShown() then return end
    local entryTop = entry.finalY
    if not entryTop then return end
    local entryH = entry.entryHeight or entry:GetHeight() or 0
    local trailingSpace = entry._scrollFadeSpacing or 0
    local leadingSpace  = entry._scrollFadeLeadingGap or 0
    local alpha = ComputeEdgeFadeAlpha(entryTop, entryH, trailingSpace, leadingSpace, viewTop, viewBottom, fadeZone, fadeAtTop, fadeAtBottom)
    entry:SetAlpha(alpha)
    entry._scrollFadeAlpha = alpha
end

local function ClearEdgeFade(entry)
    if not entry then return end
    if entry._scrollFadeAlpha then
        entry:SetAlpha(1)
        entry._scrollFadeAlpha = nil
    end
end

local function ClearAllFades()
    if addon.pool then
        for i = 1, addon.POOL_SIZE do
            if addon.pool[i] then ClearEdgeFade(addon.pool[i]) end
        end
    end
    if addon.sectionPool then
        for i = 1, addon.SECTION_POOL_SIZE do
            if addon.sectionPool[i] then ClearEdgeFade(addon.sectionPool[i]) end
        end
    end
end

function addon.UpdateScrollIndicators()
    UpdateScrollArrowPositions()
    local enabled = addon.GetDB("showScrollIndicator", false)

    local childH = scrollChild:GetHeight() or 0
    local frameH = scrollFrame:GetHeight() or 0
    local maxScr = math.max(childH - frameH, 0)
    local curScr = addon.focus.layout.scrollOffset or 0

    local canScrollDown = maxScr > 0 and curScr < (maxScr - 1)
    local canScrollUp   = curScr > 1

    -- Nothing to scroll or feature disabled: clean up
    if not enabled or maxScr <= 0 then
        arrowBottomFrame:Hide()
        arrowTopFrame:Hide()
        ClearAllFades()
        return
    end

    local mode = addon.GetDB("scrollIndicatorStyle", "fade")

    if mode == "fade" then
        arrowBottomFrame:Hide()
        arrowTopFrame:Hide()

        -- Viewport in scrollChild coordinates (Y is negative downward, 0 at top)
        local viewTop    = -curScr
        local viewBottom = -(curScr + frameH)

        -- Only fade at edges where there's actually content to scroll to
        local fadeAtTop    = canScrollUp
        local fadeAtBottom = canScrollDown

        if addon.pool then
            for i = 1, addon.POOL_SIZE do
                local e = addon.pool[i]
                if e and e:IsShown() and (e.questID or e.entryKey) and e.finalY then
                    ApplyScrollFade(e, viewTop, viewBottom, SCROLL_FADE_ZONE, fadeAtTop, fadeAtBottom)
                else
                    if e then ClearEdgeFade(e) end
                end
            end
        end
        if addon.sectionPool then
            for i = 1, addon.SECTION_POOL_SIZE do
                local s = addon.sectionPool[i]
                if s and s:IsShown() and s.active and s.finalY then
                    ApplyScrollFade(s, viewTop, viewBottom, SCROLL_FADE_ZONE, fadeAtTop, fadeAtBottom)
                else
                    if s then ClearEdgeFade(s) end
                end
            end
        end
    else
        -- Arrow mode: clear any lingering fade, show arrows
        ClearAllFades()
        if canScrollDown then arrowBottomFrame:Show() else arrowBottomFrame:Hide() end
        if canScrollUp   then arrowTopFrame:Show()    else arrowTopFrame:Hide()    end
    end
end

HS:SetMovable(true)
HS:EnableMouse(true)
HS:RegisterForDrag("LeftButton")
HS:SetScript("OnDragStart", function(self)
    if InCombatLockdown() then return end
    if addon.GetDB("lockPosition", false) then return end
    self:StartMoving()
end)

local function SavePanelPosition()
    if InCombatLockdown() then return end
    local uiRight = UIParent:GetRight() or 0
    local right   = HS:GetRight()
    if not right then return end
    addon.EnsureDB()
    if addon.GetDB("growUp", false) then
        local bottom = HS:GetBottom()
        local uiBottom = UIParent:GetBottom() or 0
        if not bottom then return end
        local x, y = right - uiRight, bottom - uiBottom
        HS:ClearAllPoints()
        HS:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
        addon.SetDB("point", "BOTTOMRIGHT")
        addon.SetDB("relPoint", "BOTTOMRIGHT")
        addon.SetDB("x", x)
        addon.SetDB("y", y)
    else
        local top = HS:GetTop()
        local uiTop = UIParent:GetTop() or 0
        if not top then return end
        local x, y = right - uiRight, top - uiTop
        HS:ClearAllPoints()
        HS:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", x, y)
        addon.SetDB("point", "TOPRIGHT")
        addon.SetDB("relPoint", "TOPRIGHT")
        addon.SetDB("x", x)
        addon.SetDB("y", y)
    end
end

HS:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self:SetUserPlaced(false)
    if InCombatLockdown() then return end
    SavePanelPosition()
end)

-- Hover fade: track mouse over for show-on-mouseover mode
addon.focus = addon.focus or {}
addon.focus.hoverFade = addon.focus.hoverFade or { mouseOver = false, fadeState = nil, fadeTime = 0 }
HS:SetScript("OnEnter", function()
    addon.focus.hoverFade.mouseOver = true
    if addon.GetDB("showOnMouseoverOnly", false) and addon.EnsureFocusUpdateRunning then
        addon.EnsureFocusUpdateRunning()
    end
end)
HS:SetScript("OnLeave", function()
    addon.focus.hoverFade.mouseOver = false
    if addon.GetDB("showOnMouseoverOnly", false) and addon.EnsureFocusUpdateRunning then
        addon.EnsureFocusUpdateRunning()
    end
end)

-- Resize handle: drag bottom-right corner to change panel width and height
local RESIZE_MIN, RESIZE_MAX = 180, 800
local RESIZE_HEIGHT_MIN = addon.MIN_HEIGHT
local function GetResizeHeightMax()
    return addon.GetScaledPadding() + addon.GetHeaderHeight() + addon.GetScaledDividerHeight() + addon.Scaled(24) + 1600 + addon.GetScaledPadding()
end
local RESIZE_CONTENT_HEIGHT_MIN, RESIZE_CONTENT_HEIGHT_MAX = 200, 1500

local resizeHandle = CreateFrame("Frame", nil, HS)
resizeHandle:SetSize(20, 20)
resizeHandle:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", 0, 0)
resizeHandle:EnableMouse(true)
resizeHandle:SetScript("OnEnter", function(self)
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(addon.L["Drag to resize"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end)
resizeHandle:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
end)
local isResizing = false
local startWidth, startHeight, startMouseX, startMouseY
local lastResizeRefreshTime = 0
local lastResizeLayoutTime = 0
resizeHandle:RegisterForDrag("LeftButton")
local function ResizeOnUpdate(self, elapsed)
    if not isResizing then return end
    if InCombatLockdown() then
        isResizing = false
        self:SetScript("OnUpdate", nil)
        return
    end
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    local curX = select(1, GetCursorPosition()) / scale
    local curY = select(2, GetCursorPosition()) / scale
    local deltaX = curX - startMouseX
    local deltaY = curY - startMouseY
    local newWidth = math.max(RESIZE_MIN, math.min(RESIZE_MAX, startWidth + deltaX))
    local newHeight = math.max(RESIZE_HEIGHT_MIN, math.min(GetResizeHeightMax(), startHeight - deltaY))
    HS:SetWidth(newWidth)
    HS:SetHeight(newHeight)
    addon.focus.layout.targetHeight = newHeight
    addon.focus.layout.currentHeight = newHeight
    if addon.ApplyDimensions then addon.ApplyDimensions(newWidth) end

    -- Live-update DB values so sliders reflect the drag in real-time
    local widthUnscaled = newWidth / (addon.Scaled and addon.Scaled(1) or 1)
    addon.SetDB("panelWidth", widthUnscaled)

    local headerArea = addon.GetScaledPadding() + addon.GetHeaderHeight() + addon.GetScaledDividerHeight() + addon.GetHeaderToContentGap()
    local contentH = newHeight - headerArea - addon.GetScaledPadding()
    local mplus = addon.mplusBlock
    local hasMplus = mplus and mplus:IsShown()
    if hasMplus and addon.GetMplusBlockHeight then
        local gapPx = 4
        contentH = contentH - (addon.GetMplusBlockHeight() + gapPx * 2)
    end
    local contentUnscaled = contentH / (addon.Scaled and addon.Scaled(1) or 1)
    contentUnscaled = math.max(RESIZE_CONTENT_HEIGHT_MIN, math.min(RESIZE_CONTENT_HEIGHT_MAX, contentUnscaled))
    addon.SetDB("maxContentHeight", contentUnscaled)
    if not (addon.IsInMythicDungeon and addon.IsInMythicDungeon()) then
        addon.SetDB("maxContentHeightOverworld", contentUnscaled)
    end

    -- Refresh options sliders if the panel is open (throttled)
    local now = GetTime()
    if addon.OptionsPanel_Refresh and (now - lastResizeRefreshTime) > 0.15 then
        lastResizeRefreshTime = now
        addon.OptionsPanel_Refresh()
    end
    -- Reflow layout during resize so text (e.g. inline timer) wraps live (throttled)
    if addon.FullLayout and (now - lastResizeLayoutTime) > 0.15 then
        lastResizeLayoutTime = now
        addon.FullLayout()
    end
end
resizeHandle:SetScript("OnDragStart", function(self)
    if addon.GetDB("lockPosition", false) then return end
    if InCombatLockdown() then return end
    isResizing = true
    startWidth = HS:GetWidth()
    startHeight = HS:GetHeight()
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    startMouseX = select(1, GetCursorPosition()) / scale
    startMouseY = select(2, GetCursorPosition()) / scale
    self:SetScript("OnUpdate", ResizeOnUpdate)
end)
resizeHandle:SetScript("OnDragStop", function(self)
    if not isResizing then return end
    isResizing = false
    self:SetScript("OnUpdate", nil)
    addon.EnsureDB()
    -- DB values already saved during drag; just finalize layout
    if addon.ApplyDimensions then addon.ApplyDimensions() end
    if addon.FullLayout then addon.FullLayout() end
    if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
end)

-- Sleek L-shaped corner grip (two thin strips)
local gripR, gripG, gripB, gripA = 0.55, 0.56, 0.6, 0.65
local resizeLineH = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeLineH:SetSize(12, 2)
resizeLineH:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)
resizeLineH:SetColorTexture(gripR, gripG, gripB, gripA)
local resizeLineV = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeLineV:SetSize(2, 12)
resizeLineV:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)
resizeLineV:SetColorTexture(gripR, gripG, gripB, gripA)

function addon.UpdateResizeHandleVisibility()
    resizeHandle:SetShown(not addon.GetDB("lockPosition", false))
end
-- Call on ADDON_LOADED to ensure it reflects current state
local visUpdateFrame = CreateFrame("Frame")
visUpdateFrame:RegisterEvent("ADDON_LOADED")
visUpdateFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == addon.ADDON_NAME then
        if addon.RestoreSavedPosition then addon.RestoreSavedPosition() end
        addon.UpdateResizeHandleVisibility()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
addon.UpdateResizeHandleVisibility()

local function RestoreSavedPosition()
    local pt = addon.GetDB("point", nil)
    if not pt then return end
    local relPt = addon.GetDB("relPoint", nil) or pt
    local x = addon.GetDB("x", nil)
    local y = addon.GetDB("y", nil)
    if not x or not y then return end
    HS:ClearAllPoints()
    HS:SetPoint(pt, UIParent, relPt, x, y)
end

local function ApplyGrowUpAnchor()
    if not addon.GetDB("growUp", false) then return end
    local right = HS:GetRight()
    local bottom = HS:GetBottom()
    if not right or not bottom then return end
    local uiRight = UIParent:GetRight() or 0
    local uiBottom = UIParent:GetBottom() or 0
    local x, y = right - uiRight, bottom - uiBottom
    HS:ClearAllPoints()
    HS:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
    addon.EnsureDB()
    addon.SetDB("point", "BOTTOMRIGHT")
    addon.SetDB("relPoint", "BOTTOMRIGHT")
    addon.SetDB("x", x)
    addon.SetDB("y", y)
end

--- Sets header position at given Y offset from HS bottom (for grow-up header slide animation).
--- offsetFromBottom: 0 = at bottom, larger = higher. Used when headerSlidingToBottom/ToTop.
function addon.ApplyGrowUpHeaderPosition(offsetFromBottom)
    if InCombatLockdown() then return end
    local hb = addon.headerBtn
    if not hb then return end
    local S = addon.Scaled or function(v) return v end
    local pad = S(addon.PADDING)
    local minimal = addon.GetDB("hideObjectivesHeader", false)
    local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
    local headerBottomY = pad

    hb:ClearAllPoints()
    hb:SetPoint("BOTTOMLEFT", HS, "BOTTOMLEFT", 0, offsetFromBottom)
    hb:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", 0, offsetFromBottom)
    hb:SetHeight(headerH)

    headerText:ClearAllPoints()
    headerText:SetPoint("BOTTOMLEFT", HS, "BOTTOMLEFT", pad, offsetFromBottom + headerBottomY)
    countText:ClearAllPoints()
    countText:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", -pad, offsetFromBottom + headerBottomY + 3)
    chevron:ClearAllPoints()
    chevron:SetPoint("RIGHT", countText, "LEFT", -6, 0)
    optionsBtn:ClearAllPoints()
    optionsBtn:SetPoint("RIGHT", chevron, "LEFT", -6, 0)

    if not minimal then
        divider:ClearAllPoints()
        local divH = addon.GetScaledDividerHeight()
        local dividerY
        local c = addon.focus and addon.focus.collapse
        local rangeY = (c and c.headerSlidingToBottom and c.headerSlideStartY) or (c and c.headerSlidingToTop and c.headerSlideEndY)
        if rangeY and rangeY > 0 then
            -- Smooth interpolation during header slide: lerp from (pad+headerH) at bottom to (rangeY-divH) at top
            local t = offsetFromBottom / rangeY
            t = math.max(0, math.min(1, t))
            dividerY = (1 - t) * (headerBottomY + headerH) + t * (rangeY - divH)
        else
            -- Static layout: match ApplyGrowUpLayout
            dividerY = (offsetFromBottom <= 0) and (headerBottomY + headerH) or (offsetFromBottom - divH)
        end
        divider:SetPoint("BOTTOM", HS, "BOTTOMLEFT", addon.GetPanelWidth() / 2, dividerY)
    end
end

--- Repositions header elements when growUp: header at bottom (always) or at top until collapsed (collapse mode).
--- When growUp is false, restores default top-anchored layout.
--- Call from FullLayout after ApplyGrowUpAnchor.
function addon.ApplyGrowUpLayout()
    if InCombatLockdown() then return end
    local collapse = addon.focus and addon.focus.collapse
    if collapse and collapse.headerSlidingToTop then
        addon.ApplyGrowUpHeaderPosition(0)
        return
    end
    if collapse and collapse.headerSlidingToBottom then
        return
    end
    local growUp = addon.GetDB("growUp", false)
    local headerMode = addon.GetDB("growUpHeaderMode", "always")
    local collapsed = addon.focus and addon.focus.collapsed
    local collapseState = addon.focus and addon.focus.collapse
    local pceg = collapseState and collapseState.panelCollapsedExpandedGroups
    local hasPanelCollapsedExpanded = collapsed and pceg and next(pceg) ~= nil
    local effectiveCollapsed = collapsed and not hasPanelCollapsedExpanded
    local headerAtBottom = growUp and (headerMode == "always"
        or (headerMode == "collapse" and (effectiveCollapsed
            or (addon.focus.layout and addon.focus.layout.allCategoriesCollapsed))))
    local S = addon.Scaled or function(v) return v end
    local pad = S(addon.PADDING)
    local minimal = addon.GetDB("hideObjectivesHeader", false)

    if headerAtBottom then
        -- Header at bottom of panel. Content (scrollFrame) is positioned by FullLayout.
        local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())
        local headerBottomY = pad

        -- headerBtn (created in FocusLayout; may not exist yet on first load)
        local hb = addon.headerBtn
        if hb then
            hb:ClearAllPoints()
            hb:SetPoint("BOTTOMLEFT", HS, "BOTTOMLEFT", 0, 0)
            hb:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", 0, 0)
            hb:SetHeight(headerH)
        end

        -- headerText, countText, etc. anchored to bottom
        headerText:ClearAllPoints()
        headerText:SetPoint("BOTTOMLEFT", HS, "BOTTOMLEFT", pad, headerBottomY)
        countText:ClearAllPoints()
        countText:SetPoint("BOTTOMRIGHT", HS, "BOTTOMRIGHT", -pad, headerBottomY + 3)
        chevron:ClearAllPoints()
        chevron:SetPoint("RIGHT", countText, "LEFT", -6, 0)
        optionsBtn:ClearAllPoints()
        optionsBtn:SetPoint("RIGHT", chevron, "LEFT", -6, 0)

        -- Divider just above the header (between content and header)
        if not minimal then
            divider:ClearAllPoints()
            divider:SetPoint("BOTTOM", HS, "BOTTOMLEFT", addon.GetPanelWidth() / 2, headerBottomY + headerH)
        end
    else
        -- Default: header at top
        local headerH = minimal and addon.GetScaledMinimalHeaderHeight() or (pad + addon.GetHeaderHeight())

        local hb = addon.headerBtn
        if hb then
            hb:ClearAllPoints()
            hb:SetPoint("TOPLEFT", HS, "TOPLEFT", 0, 0)
            hb:SetPoint("TOPRIGHT", HS, "TOPRIGHT", 0, 0)
            hb:SetHeight(headerH)
        end

        headerText:ClearAllPoints()
        headerText:SetPoint("TOPLEFT", HS, "TOPLEFT", pad, -pad)
        countText:ClearAllPoints()
        countText:SetPoint("TOPRIGHT", HS, "TOPRIGHT", -pad, -pad - 3)
        chevron:ClearAllPoints()
        chevron:SetPoint("RIGHT", countText, "LEFT", -6, 0)
        optionsBtn:ClearAllPoints()
        optionsBtn:SetPoint("RIGHT", chevron, "LEFT", -6, 0)

        if not minimal then
            divider:ClearAllPoints()
            divider:SetPoint("TOP", HS, "TOPLEFT", addon.GetPanelWidth() / 2, -(pad + addon.GetHeaderHeight()))
        end
    end
end

function addon.UpdateHeaderQuestCount(questCount, trackedInLogCount)
    local mode = addon.GetDB("headerCountMode", "trackedLog")
    local maxSlots = (C_QuestLog.GetMaxNumQuestsCanAccept and C_QuestLog.GetMaxNumQuestsCanAccept()) or 35
    -- Count only quests the player has actually accepted: iterate log, require non-header + questID + not WQ + IsOnQuest(questID).
    local numInLog = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        local isWQ = addon.IsQuestWorldQuest or (C_QuestLog.IsWorldQuest and function(q) return C_QuestLog.IsWorldQuest(q) end) or function() return false end
        local isOnQuest = C_QuestLog.IsOnQuest and function(q) return C_QuestLog.IsOnQuest(q) end or function() return true end
        local numEntries = select(1, C_QuestLog.GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and not info.isHidden and info.questID and (not isWQ or not isWQ(info.questID)) and isOnQuest(info.questID) then
                numInLog = numInLog + 1
            end
        end
    end
    local countStr
    if mode == "trackedLog" then
        local numerator = (trackedInLogCount ~= nil) and trackedInLogCount or questCount
        countStr = (numerator and numerator > 0) and (numerator .. "/" .. numInLog) or ""
    else
        countStr = (numInLog and numInLog > 0) and (numInLog .. "/" .. maxSlots) or ""
    end
    addon.countText:SetText(countStr)
    addon.countShadow:SetText(countStr)
    if addon.GetDB("showQuestCount", true) and not addon.GetDB("hideObjectivesHeader", false) then
        addon.countText:Show()
        addon.countShadow:Show()
    else
        addon.countText:Hide()
        addon.countShadow:Hide()
    end
end

-- Debug: run /horizon headercountdebug to print quest-log count breakdown and compare APIs.
function addon.DebugHeaderCount()
    if not addon.HSPrint then return end
    local maxSlots = (C_QuestLog.GetMaxNumQuestsCanAccept and C_QuestLog.GetMaxNumQuestsCanAccept()) or 35
    if not C_QuestLog or not C_QuestLog.GetNumQuestLogEntries or not C_QuestLog.GetInfo then
        addon.HSPrint("[HeaderCount debug] C_QuestLog APIs not available.")
        return
    end
    local isWQ = addon.IsQuestWorldQuest or (C_QuestLog.IsWorldQuest and function(q) return C_QuestLog.IsWorldQuest(q) end) or function() return false end
    local isOnQuest = C_QuestLog.IsOnQuest and function(q) return C_QuestLog.IsOnQuest(q) end or function() return true end
    local a, b = C_QuestLog.GetNumQuestLogEntries()
    local numEntries = a or 0

    -- API comparison: try different ways to get "accepted quests in log" count (excluding WQ).
    do
        local countByLogIndex = 0  -- GetQuestIDForLogIndex(i) + IsOnQuest + not WQ
        local getQidForIdx = C_QuestLog.GetQuestIDForLogIndex
        if getQidForIdx then
            for i = 1, numEntries do
                local qid = getQidForIdx(i)
                if qid and (not isWQ or not isWQ(qid)) and isOnQuest(qid) then countByLogIndex = countByLogIndex + 1 end
            end
        end
        local countWithNotHidden = 0  -- GetInfo + not isHidden + IsOnQuest + not WQ
        for i = 1, numEntries do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and info.questID and not info.isHidden and (not isWQ or not isWQ(info.questID)) and isOnQuest(info.questID) then
                countWithNotHidden = countWithNotHidden + 1
            end
        end
        addon.HSPrint("[HeaderCount] API comparison (all exclude world quests):")
        addon.HSPrint(string.format("  numQuests (2nd return) = %s | GetQuestIDForLogIndex+IsOnQuest = %s | GetInfo+IsOnQuest = (below) | GetInfo+not isHidden+IsOnQuest = %s",
            tostring(b), tostring(countByLogIndex), tostring(countWithNotHidden)))
    end
    local numInLog, skippedHeader, skippedNoQid, skippedHidden, skippedWQ, skippedNotOnQuest = 0, 0, 0, 0, 0, 0
    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if not info then
        elseif info.isHeader then
            skippedHeader = skippedHeader + 1
        elseif not info.questID then
            skippedNoQid = skippedNoQid + 1
        elseif info.isHidden then
            skippedHidden = skippedHidden + 1
        elseif isWQ and isWQ(info.questID) then
            skippedWQ = skippedWQ + 1
        elseif not isOnQuest(info.questID) then
            skippedNotOnQuest = skippedNotOnQuest + 1
        else
            numInLog = numInLog + 1
        end
    end
    local afterCap = math.min(numInLog, maxSlots)
    addon.HSPrint(string.format("[HeaderCount] GetNumQuestLogEntries first=%s second=%s maxSlots=%s | loop=%s counted=%s afterCap=%s | skip: header=%s noQid=%s hidden=%s wq=%s notOnQuest=%s",
        tostring(a), tostring(b), tostring(maxSlots), tostring(numEntries), tostring(numInLog), tostring(afterCap),
        tostring(skippedHeader), tostring(skippedNoQid), tostring(skippedHidden), tostring(skippedWQ), tostring(skippedNotOnQuest)))
    -- Breakdown: list each entry we counted (index, questID, title) — matches production (GetInfo + not isHidden + IsOnQuest + not WQ).
    addon.HSPrint("[HeaderCount] Breakdown of counted entries (production logic; index | questID | title):")
    local getTitle = C_QuestLog.GetTitleForQuestID
    local n = 0
    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and not info.isHidden and info.questID and (not isWQ or not isWQ(info.questID)) and isOnQuest(info.questID) then
            n = n + 1
            local title = (getTitle and getTitle(info.questID)) or "(no title)"
            addon.HSPrint(string.format("  #%s idx=%s questID=%s | %s", tostring(n), tostring(i), tostring(info.questID), tostring(title)))
        end
    end
    addon.HSPrint(string.format("[HeaderCount] End breakdown: %s entries listed (production logic).", tostring(n)))
end

function addon.ApplyItemCooldown(cooldownFrame, itemLink)
    if not cooldownFrame or not itemLink then return end
    local ok, itemID = pcall(GetItemInfoInstant, itemLink)
    if not ok and addon.HSPrint then addon.HSPrint("GetItemInfoInstant failed: " .. tostring(itemLink)) end
    if not ok or not itemID or not GetItemCooldown then return end
    local start, duration = GetItemCooldown(itemID)
    if start and duration and duration > 0 then
        cooldownFrame:SetCooldown(start, duration)
    else
        cooldownFrame:Clear()
    end
end

addon.RARE_ADDED_SOUND = (SOUNDKIT and SOUNDKIT.UI_AUTO_QUEST_COMPLETE) or 61969

-- Export to addon table
addon.HS                  = HS
addon.scrollFrame         = scrollFrame
addon.scrollChild         = scrollChild
addon.headerText          = headerText
addon.headerShadow        = headerShadow
addon.countText           = countText
addon.countShadow         = countShadow
addon.chevron             = chevron
addon.optionsBtn          = optionsBtn
addon.optionsLabel        = optionsLabel
addon.divider             = divider
addon.HandleScroll        = HandleScroll
addon.SavePanelPosition   = SavePanelPosition
addon.RestoreSavedPosition = RestoreSavedPosition
addon.ApplyGrowUpAnchor   = ApplyGrowUpAnchor

-- Refresh LibSharedMedia fonts when media packs register late.
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()
        -- Flush any settings written during early load (before charKey was available)
        -- into the real character profile now that realm info is resolved.
        if addon._earlyLoadProfile and next(addon._earlyLoadProfile) then
            local realProfile, realKey = addon.GetActiveProfile()
            if realKey and realProfile then
                for k, v in pairs(addon._earlyLoadProfile) do
                    if realProfile[k] == nil then
                        realProfile[k] = v
                    end
                end
            end
            addon._earlyLoadProfile = nil
        end

        if addon.RefreshFontList then addon.RefreshFontList() end

        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM and LSM.RegisterCallback and not addon.__hsLSMFontCallbacksRegistered then
            addon.__hsLSMFontCallbacksRegistered = true
            -- CallbackHandler signature: RegisterCallback(eventName, method[, arg])
            -- LSM fires: "LibSharedMedia_Registered" (self, mediatype, key)
            if not addon.__OnLSMFontRegistered then
                function addon.__OnLSMFontRegistered(_, mediaType)
                    if mediaType == "font" then
                        if addon.RefreshFontList then addon.RefreshFontList() end
                        if addon.ApplyTypography then addon.ApplyTypography() end
                    elseif mediaType == "statusbar" then
                        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                        if addon.FullLayout and not InCombatLockdown() then addon.FullLayout() end
                    end
                end
            end
            -- CallbackHandler rule: don't do Library:RegisterCallback(); register from your own 'self'.
            -- This registers addon as the callback owner and listens to the LSM event.
            LSM.RegisterCallback(addon, "LibSharedMedia_Registered", "__OnLSMFontRegistered")
        end

        -- Deferred typography apply: catch fonts that register after HorizonSuite loads.
        C_Timer.After(0.5, function()
            if addon.ApplyTypography then addon.ApplyTypography() end
        end)
        C_Timer.After(1.5, function()
            if addon.ApplyTypography then addon.ApplyTypography() end
        end)

        if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end

        -- Clickable URL links: when a url: link is clicked in chat, show the URL copy box so the user can copy and paste in a browser.
        if not addon.__urlLinkHookInstalled and ChatFrame_OnHyperlinkShow and hooksecurefunc then
            addon.__urlLinkHookInstalled = true
            hooksecurefunc("ChatFrame_OnHyperlinkShow", function(_, link, _text, _button)
                local url = link and link:match("^url:(.+)$")
                if not url or url == "" then return end
                if addon.ShowURLCopyBox then addon.ShowURLCopyBox(url) end
            end)
        end

        f:UnregisterEvent("PLAYER_LOGIN")
    end)
end

