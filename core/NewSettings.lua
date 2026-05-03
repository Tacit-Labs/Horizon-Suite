--[[
    Horizon Suite - New Settings suffix
    Per-setting "(New!)" name suffix, keyed by option dbKey (or synthetic optId)
    and the version the setting was introduced in.

    Declare in options/OptionsData.lua via `isNew = "<version>"` on an option entry.
    Storage (root DB): db.newSettingsAcked = { [optId] = "<acknowledged version>" }.
    Ack-on-interaction: first `set()` or `onClick()` clears the suffix for that optId.
]]

local addon = _G.HorizonSuite

local function EnsureRootDB()
    local db = _G[addon.DATABASE]
    if not db then
        db = {}
        _G[addon.DATABASE] = db
    end
    if type(db.newSettingsAcked) ~= "table" then
        db.newSettingsAcked = {}
    end
    return db
end

local function ReadAckedVersion(optId)
    local db = _G[addon.DATABASE]
    local t = db and db.newSettingsAcked
    if type(t) ~= "table" then return "" end
    return t[optId] or ""
end

--- True if this option was introduced in `introducedInVersion` and the user has not yet acked that version for this optId.
--- @param optId string
--- @param introducedInVersion string
--- @return boolean
function addon.NewSettings_IsUnread(optId, introducedInVersion)
    if type(optId) ~= "string" or optId == "" then return false end
    if type(introducedInVersion) ~= "string" or introducedInVersion == "" then return false end
    return ReadAckedVersion(optId) ~= introducedInVersion
end

--- Mark an option as acked for the given introduced version. Silent no-op on bad input.
--- @param optId string
--- @param introducedInVersion string
--- @return nil
function addon.NewSettings_MarkAcknowledged(optId, introducedInVersion)
    if type(optId) ~= "string" or optId == "" then return end
    if type(introducedInVersion) ~= "string" or introducedInVersion == "" then return end
    local db = EnsureRootDB()
    db.newSettingsAcked[optId] = introducedInVersion
end

--- Resolve a display-ready label for `opt`, appending " (New!)" (localised) when the
--- option is tagged `isNew = "<version>"` and still unread for this optId.
--- Safely resolves function-typed `opt.name` to a string.
--- @param opt table option entry from OptionsData.lua
--- @param optId string stable identifier (normally the option dbKey)
--- @return string|nil display name
function addon.NewSettings_ResolveDisplayName(opt, optId)
    if not opt then return nil end
    local raw = opt.name
    local base
    if type(raw) == "function" then
        local ok, v = pcall(raw)
        base = (ok and type(v) == "string") and v or ""
    elseif type(raw) == "string" then
        base = raw
    else
        return raw
    end
    if opt.isNew and addon.NewSettings_IsUnread(optId, opt.isNew) then
        local suffix = (addon.L and addon.L["DASH_WHATS_NEW_UNREAD_SUFFIX"]) or " (New!)"
        -- Matches the Patch Notes sidebar green (WHATSNEW_GREEN in core/PatchNotes.lua:105).
        return base .. "|cff52e680" .. suffix .. "|r"
    end
    return base
end
