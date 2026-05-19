--[[
    Horizon Suite - Logger
    Development-only structured logger with a fixed-size ring buffer.

    WARNING: DEV_MODE must remain false in committed code. Setting it to true
    activates live chat output and registers a slash command on every session,
    which will expose debug noise to end users.

    Usage (DEV_MODE = true only):
        addon.Log.debug("MyModule", "entered ShowToast")
        addon.Log.info ("MyModule", "pool acquired entry #3")
        addon.Log.warn ("MyModule", "quality nil, defaulting to 1")
        addon.Log.error("MyModule", "frame is nil — InitFrames not called?")
        addon.Log.dump()   -- print all buffered entries to chat
        addon.Log.clear()  -- wipe the ring buffer

    In-game slash commands (DEV_MODE = true only):
        /h debug logger        -- dump the buffer (same as dump)
        /h debug logger dump   -- print all buffered log entries to chat
        /h debug logger clear  -- wipe the ring buffer

    When DEV_MODE = false all methods are noop — zero runtime cost.
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

local function write(level, tag, msg)
    local ts    = ("%.2f"):format(GetTime())
    local entry = ("[%s] %s [%s] %s"):format(ts, LEVEL_FMT[level], tostring(tag or "?"), tostring(msg or ""))
    buffer[head] = entry
    head  = (head % BUFFER_MAX) + 1
    if count < BUFFER_MAX then count = count + 1 end
    print(PREFIX .. entry)
end

local Log = {}

if DEV_MODE then
    Log.debug = function(tag, msg) write("DEBUG", tag, msg) end
    Log.info  = function(tag, msg) write("INFO",  tag, msg) end
    Log.warn  = function(tag, msg) write("WARN",  tag, msg) end
    Log.error = function(tag, msg) write("ERROR", tag, msg) end

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
    Log.debug = noop
    Log.info  = noop
    Log.warn  = noop
    Log.error = noop
    Log.dump  = noop
    Log.clear = noop
end

addon.Log = Log
