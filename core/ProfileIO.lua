--[[
    Horizon Suite — Profile IO
    Profile export / import: base64 codec, Lua table serializer, HSP2 string format.
    Extracted from Core.lua. Depends on addon._RawDB and addon._GetCurrentCharacterProfileKey
    (exposed by Core.lua) and EnsureProfilesAndMigrateLegacy (global, set by Core.lua).
]]

local addon = _G.HorizonSuite

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
    local db = addon._RawDB()
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
    local db = addon._RawDB()
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

    -- Activate the imported profile under whichever mode is active so the user sees
    -- the imported state without needing to manually re-select it from the dropdown.
    local charKey = addon._GetCurrentCharacterProfileKey()
    if db.useGlobalProfile == true then
        db.globalProfileKey = finalName
    elseif db.usePerSpecProfiles == true then
        local currentSpec = PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID() or nil
        if type(currentSpec) == "number" and currentSpec >= 1 and currentSpec <= 4 and addon.SetPerSpecProfileKey then
            addon.SetPerSpecProfileKey(currentSpec, finalName)
        elseif charKey and charKey ~= "" then
            db.charProfileKeys = db.charProfileKeys or {}
            db.charProfileKeys[charKey] = finalName
        end
    elseif charKey and charKey ~= "" then
        db.charProfileKeys = db.charProfileKeys or {}
        db.charProfileKeys[charKey] = finalName
    end

    return true, finalName
end
