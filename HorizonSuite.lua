--[[
    HORIZON SUITE
    Core addon with pluggable modules. Focus (objective tracker) is the first module.
    This file creates the addon namespace and module registry; behavior lives in Core and module files.

    Abbreviation glossary:
    - HS   = Horizon Suite (addon / frame prefix)
    - WQ   = World Quest
    - M+   = Mythic Plus (dungeon)
    - ATT  = All The Things (addon; rare vignette source)
    - WQT  = World Quest / Task Quest (C_TaskQuest API)
]]

-- ============================================================================
-- ADDON IDENTITY DETECTION
-- ============================================================================
-- Detect whether this code is running from the "HorizonSuite" or
-- "HorizonSuiteBeta" folder so both can be loaded simultaneously without
-- colliding on global namespace, SavedVariables, or frame names.

local ADDON_NAME
do
    -- Walk the call stack to find the originating file path.  When WoW (or
    -- the test harness) loads "Interface/AddOns/<FolderName>/HorizonSuite.lua"
    -- the folder name tells us which copy we are.
    local info = debugstack and debugstack(1, 1, 0) or ""
    if info:find("HorizonSuiteBeta") then
        ADDON_NAME = "HorizonSuiteBeta"
    else
        ADDON_NAME = "HorizonSuite"
    end
end

local isBeta    = (ADDON_NAME == "HorizonSuiteBeta")
local GLOBAL_NS = isBeta and "HorizonSuiteBeta" or "HorizonSuite"
local DB_NAME   = isBeta and "HorizonBetaDB"     or "HorizonDB"


if not _G[GLOBAL_NS] then _G[GLOBAL_NS] = {} end
local addon = _G[GLOBAL_NS]

-- Loading marker: WoW loads all TOC files for one addon sequentially before
-- moving to the next addon. Every subsequent file in this addon's TOC checks
-- _G._HorizonSuite_Loading to find the correct namespace, avoiding the bug
-- where the main addon's files accidentally bind to the beta namespace (or
-- vice-versa) when both are loaded simultaneously.
_G._HorizonSuite_Loading = addon

-- Store identity so every other file can query it.
addon.ADDON_NAME = ADDON_NAME
addon.IS_BETA    = isBeta
addon.DB_NAME    = DB_NAME

-- ============================================================================
-- MODULE REGISTRY AND LIFECYCLE
-- ============================================================================

addon.modules = {}

-- Localization: L[key] returns translated string or key as fallback. Localisation/LocaleCore.lua then enUS.lua; locale files (frFR, etc.) wrap with fallback to English.
addon.L = setmetatable({}, { __index = function(t, k) return k end })

--- Register a module. Called by module files at load time.
-- @param key string Module identifier (e.g. "focus")
-- @param def table { title, description, order, OnInit, OnEnable, OnDisable }
function addon:RegisterModule(key, def)
    if not key or type(key) ~= "string" or key == "" then return end
    if self.modules[key] then return end
    self.modules[key] = {
        key         = key,
        title       = def.title or key,
        description = def.description or "",
        order       = def.order or 100,
        OnInit      = def.OnInit,
        OnEnable    = def.OnEnable,
        OnDisable   = def.OnDisable,
        initialized = false,
        enabled     = false,
    }
end

--- Check if a module is enabled (runtime state).
function addon:IsModuleEnabled(key)
    local m = self.modules[key]
    return m and m.enabled
end

--- Get module definition by key.
function addon:GetModule(key)
    return self.modules[key]
end

--- Iterate over all registered modules (for options, etc.).
function addon:IterateModules()
    local keys = {}
    for k in pairs(self.modules) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
        local ma, mb = self.modules[a], self.modules[b]
        local oa = ma and ma.order or 100
        local ob = mb and mb.order or 100
        if oa ~= ob then return oa < ob end
        return (ma and ma.title or a) < (mb and mb.title or b)
    end)
    local i = 0
    return function()
        i = i + 1
        if keys[i] then return keys[i], self.modules[keys[i]] end
    end
end

--- Call callback for each enabled module.
function addon:ForEachEnabledModule(cb)
    for key, m in pairs(self.modules) do
        if m.enabled and cb then cb(key, m) end
    end
end

--- Persist a module's enabled state into the active profile so it follows the
--- profile across switches / exports. Always assigns a fresh inner table to
--- sever any shared refs from CreateProfile's shallow copy of the parent table.
local function writeModuleEnabledToActiveProfile(key, enabled)
    if type(key) ~= "string" or key == "" then return end
    if not addon.GetActiveProfile then return end
    local profile = addon.GetActiveProfile()
    if type(profile) ~= "table" then return end
    profile.modules = profile.modules or {}
    profile.modules[key] = { enabled = enabled and true or false }
end

--- Enable a module. Loads DB, calls OnInit once, then OnEnable.
function addon:EnableModule(key)
    local m = self.modules[key]
    if not m or m.enabled then return end
    local db = _G[self.DB_NAME]
    if not db then db = {}; _G[self.DB_NAME] = db end
    if not db.modules then db.modules = {} end
    if not db.modules[key] then db.modules[key] = {} end
    db.modules[key].enabled = true
    writeModuleEnabledToActiveProfile(key, true)
    if not m.initialized and m.OnInit then
        m.OnInit(self)
        m.initialized = true
    end
    if m.OnEnable then m.OnEnable(self) end
    m.enabled = true
end

--- Disable a module. Calls OnDisable, updates DB.
function addon:DisableModule(key)
    local m = self.modules[key]
    if not m or not m.enabled then return end
    if m.OnDisable then m.OnDisable(self) end
    m.enabled = false
    local db = _G[self.DB_NAME]
    if db and db.modules and db.modules[key] then
        db.modules[key].enabled = false
    end
    writeModuleEnabledToActiveProfile(key, false)
end

--- Set module enabled state (convenience for toggles).
--- @param key string Module key
--- @param enabled boolean
--- @param opts table|nil Optional; opts.deferReload skips ReloadUI until the user reloads (e.g. dashboard module toggles).
function addon:SetModuleEnabled(key, enabled, opts)
    if enabled then self:EnableModule(key) else self:DisableModule(key) end
    -- Set before Dashboard_Refresh: relayout reads _moduleReloadRecommended in visibleWhen for the reload prompt.
    if opts and opts.deferReload then
        self._moduleReloadRecommended = true
    else
        self._moduleReloadRecommended = false
    end
    if self.Dashboard_Refresh then self.Dashboard_Refresh() end
    if opts and opts.deferReload then
        return
    end
    ReloadUI()
end

--- Ensure modules table exists and migrate legacy installs (no modules table = all defaults).
function addon:EnsureModulesDB()
    local db = _G[self.DB_NAME]
    if not db then db = {}; _G[self.DB_NAME] = db end
    if not db.modules then
        db.modules = {}
        -- First-time install: all modules off until the user enables them in options.
        db.modules.focus = { enabled = false }
        db.modules.presence = { enabled = false }
        db.modules.insight = { enabled = false }
        db.modules.cache = { enabled = false }
        db.modules.vista = { enabled = false }
        db.modules.essence = { enabled = false }
    end
    -- Migrate old Vista (Presence) module key to Presence; repurpose vista for minimap
    if db.modules.vista and not db.modules.presence then
        db.modules.presence = { enabled = (db.modules.vista.enabled ~= false) }
        db.modules.vista = { enabled = false }
    end
    -- Ensure vista exists for existing installs (default enabled)
    if not db.modules.vista then
        db.modules.vista = { enabled = true }
    end
    -- Ensure insight exists for upgrades from builds before Insight (legacy default on)
    if not db.modules.insight then
        db.modules.insight = { enabled = true }
    end
    -- Ensure essence exists for existing installs; disabled by default (beta)
    if not db.modules.essence then
        db.modules.essence = { enabled = false }
    end

    -- Module on/off follows the active profile: sync db.modules from the active
    -- profile's modules map so ADDON_LOADED's initial enable-pass reflects the
    -- profile. Profiles without a modules map are seeded from db.modules (so an
    -- existing install doesn't lose its module state on first profile activation).
    if addon.GetActiveProfile then
        local profile = addon.GetActiveProfile()
        if type(profile) == "table" then
            if type(profile.modules) ~= "table" then
                local seeded = {}
                for mk, md in pairs(db.modules) do
                    if type(md) == "table" then
                        seeded[mk] = { enabled = md.enabled ~= false }
                    end
                end
                profile.modules = seeded
            else
                for mk, md in pairs(profile.modules) do
                    if type(md) == "table" then
                        db.modules[mk] = db.modules[mk] or {}
                        db.modules[mk].enabled = md.enabled and true or false
                    end
                end
            end
        end
    end
end

-- Binding display names for Key Bindings UI (must match Binding name in Bindings.xml exactly)
_G["BINDING_NAME_CLICK HSCollapseButton:LeftButton"] = "Collapse Tracker"
_G["BINDING_NAME_CLICK HSNearbyToggleButton:LeftButton"] = "Toggle Nearby Group"
_G["BINDING_NAME_CLICK HSSecureItemOverlay:LeftButton"] = "Use Floating Quest Item"
