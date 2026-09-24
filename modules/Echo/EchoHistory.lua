--[[
    Horizon Suite - Echo - History
    Whisper history in HorizonDB.echoHistory: per character for whispers, account-wide
    for Battle.net (names resolve fresh each session; only the account ID is keyed).
    Never writes secret, pending, failed or demo messages. Channels are never persisted.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local History = {}
Echo.History = History

History.CAP = 100

local root
local characterKey = function() return nil end
local enabledCheck = function() return true end

--- Attach to the SavedVariables root.
-- @param db table  HorizonDB
-- @param keyFn function  Returns "Name-Realm", or nil while the realm is unknown
function History.Bind(db, keyFn)
    if type(db) ~= "table" then return end
    db.echoHistory = db.echoHistory or {}
    root = db.echoHistory
    root.chars = root.chars or {}
    root.bnet = root.bnet or {}
    if type(keyFn) == "function" then characterKey = keyFn end
end

function History.Unbind()
    root = nil
end

--- Options (plan 3) supplies the "Save whisper history" setting through this.
-- @param fn function  Returns true when history may be written
function History.SetEnabledCheck(fn)
    if type(fn) == "function" then enabledCheck = fn end
end

local function Bucket(convKey, create)
    if not root then return nil end
    local kind = Echo.Store.KindOf(convKey)
    local parent
    if kind == "bnet" then
        parent = root.bnet
    elseif kind == "whisper" then
        local charKey = characterKey()
        if not charKey then return nil end
        parent = root.chars[charKey]
        if not parent and create then
            parent = {}
            root.chars[charKey] = parent
        end
    end
    if not parent then return nil end
    local list = parent[convKey]
    if not list and create then
        list = {}
        parent[convKey] = list
    end
    return list
end

--- Persist one whisper. Rejections are silent: the message still shows this session.
-- @param convKey string
-- @param record table
-- @return boolean written
function History.Append(convKey, record)
    if not root or not enabledCheck() then return false end
    if record.secret or record.demo then return false end
    if record.status == "pending" or record.status == "failed" then return false end
    if Echo.IsSecret(record.text) or type(record.text) ~= "string" then return false end
    local list = Bucket(convKey, true)
    if not list then return false end
    list[#list + 1] = { t = record.time, out = record.outgoing and true or nil, text = record.text }
    while #list > History.CAP do table.remove(list, 1) end
    return true
end

--- Saved messages for a conversation, oldest first, as Store records.
-- @param convKey string
-- @return table records  empty when there is no history
function History.Load(convKey)
    local out = {}
    local list = Bucket(convKey, false)
    if not list then return out end
    for i, entry in ipairs(list) do
        out[i] = {
            convKey     = convKey,
            text        = entry.text,
            time        = entry.t,
            outgoing    = entry.out == true,
            status      = entry.out and "sent" or nil,
            fromHistory = true,
            seq         = 0,
        }
    end
    return out
end

--- Wipe all saved whispers, for every character and Battle.net.
function History.Clear()
    if not root then return end
    root.chars = {}
    root.bnet = {}
end
