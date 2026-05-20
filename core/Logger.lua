--[[
    Horizon Suite - Logger
    Structured logger with a fixed-size ring buffer.

    Runtime per-tag enables and listener callbacks allow modules to gate
    logging at runtime (e.g. Presence live debug panel) without needing
    DEV_MODE = true.

    WARNING: DEV_MODE must remain false in committed code. Setting it to true
    activates live chat output and registers a slash command on every session,
    which will expose debug noise to end users.

    Usage:
        -- Modules register their tag and its saved-variable DB key once:
        addon.Log.registerTag("mymodule", "mymoduleDebugLive")
        -- Core calls addon.Log.syncFromDB() on PLAYER_LOGIN to restore all tags.

        -- Runtime-gated (zero-overhead when tag is off):
        addon.Log.debug("mymodule", "entered ShowToast")
        addon.Log.isEnabled("mymodule")  -- true while enabled

        -- DEV_MODE = true adds chat output and /h debug logger commands:
        addon.Log.info ("MyModule", "pool acquired entry #3")
        addon.Log.warn ("MyModule", "quality nil, defaulting to 1")
        addon.Log.error("MyModule", "frame is nil — InitFrames not called?")
        addon.Log.dump()   -- print all buffered entries to chat
        addon.Log.clear()  -- wipe the ring buffer

    Listener API (for in-game visual panels):
        local function onMyLog(level, tag, ts, msg, line) ... end
        addon.Log.addListener("mymodule", onMyLog)
        addon.Log.removeListener("mymodule", onMyLog)
        -- Listeners receive calls only while the tag is enabled.

    In-game slash commands (DEV_MODE = true only):
        /h debug logger        -- dump the buffer (same as dump)
        /h debug logger dump   -- print all buffered log entries to chat
        /h debug logger clear  -- wipe the ring buffer

    Registered tag → DB key mappings (add new module debug keys here):
        "presence"  →  "presenceDebugLive"
]]

local addon = _G.HorizonSuite

local DEV_MODE = false

local BUFFER_MAX = 100
local buffer, head, count = {}, 1, 0

local LEVEL_FMT = {
    DEBUG = "|cFF888888[DEBUG]|r",
    INFO  = "|cFF00CCFF[INFO]|r",
    WARN  = "|cFFFFCC00[WARN]|r",
    ERROR = "|cFFFF4444[ERROR]|r",
}

local PREFIX = "|cFF00CCFFHorizonSuite|r "

local enabledTags = {}  -- [tag] = true  (runtime-enabled tags)
local listeners   = {}  -- [tag] = { fn, fn, ... }
local tagDbKeys   = {}  -- [tag] = dbKey  (registered via Log.registerTag)

local function active(tag)
    if DEV_MODE then return true end
    return enabledTags[tag] == true
end

local function write(level, tag, msg)
    local ts   = ("%.2f"):format(GetTime())
    local line = ("[%s] %s [%s] %s"):format(ts, LEVEL_FMT[level], tostring(tag or "?"), tostring(msg or ""))

    if DEV_MODE then
        buffer[head] = line
        head  = (head % BUFFER_MAX) + 1
        if count < BUFFER_MAX then count = count + 1 end
        print(PREFIX .. line)
    end

    local tl = listeners[tag]
    if tl then
        for i = 1, #tl do
            tl[i](level, tag, ts, tostring(msg or ""), line)
        end
    end
end

local Log = {}

Log.debug = function(tag, msg) if active(tag) then write("DEBUG", tag, msg) end end
Log.info  = function(tag, msg) if active(tag) then write("INFO",  tag, msg) end end
Log.warn  = function(tag, msg) if active(tag) then write("WARN",  tag, msg) end end
Log.error = function(tag, msg) if active(tag) then write("ERROR", tag, msg) end end

Log.isDevMode = function() return DEV_MODE end

Log.enableTag = function(tag, enabled)
    enabledTags[tag] = enabled and true or nil
end

Log.isEnabled = function(tag)
    return active(tag)
end

Log.addListener = function(tag, fn)
    if not listeners[tag] then listeners[tag] = {} end
    listeners[tag][#listeners[tag] + 1] = fn
end

Log.removeListener = function(tag, fn)
    local list = listeners[tag]
    if not list then return end
    for i, f in ipairs(list) do
        if f == fn then
            table.remove(list, i)
            if #list == 0 then listeners[tag] = nil end
            return
        end
    end
end

-- Register a tag and its saved-variable DB key so syncFromDB can restore it.
-- Call once per module during initialization (before PLAYER_LOGIN).
Log.registerTag = function(tag, dbKey)
    tagDbKeys[tag] = dbKey
end

-- Restore all registered tag states from the saved DB.
-- Called by Core on PLAYER_LOGIN, after the character profile is resolved.
Log.syncFromDB = function()
    if not addon.GetDB then return end
    for tag, dbKey in pairs(tagDbKeys) do
        Log.enableTag(tag, addon.GetDB(dbKey, false) or nil)
    end
end

if DEV_MODE then
    Log.dump = function()
        if count == 0 then print(PREFIX .. "Log buffer is empty.") return end
        local start = (count < BUFFER_MAX) and 1 or head
        for i = 0, count - 1 do
            print(buffer[((start - 1 + i) % BUFFER_MAX) + 1])
        end
    end

    Log.clear = function()
        buffer, head, count = {}, 1, 0
        print(PREFIX .. "Log buffer cleared.")
    end

    addon.RegisterSlashHandlerDebug("logger", function(msg)
        local cmd = strtrim(msg or ""):lower()
        if cmd == "dump" or cmd == "" then
            Log.dump()
        elseif cmd == "clear" then
            Log.clear()
        else
            addon.HSPrint("Logger: /h debug logger [dump|clear]")
        end
    end)
else
    -- noop is a WoW FrameXML global (equivalent to `function() end`)
    Log.dump  = noop
    Log.clear = noop
end

addon.Log = Log
