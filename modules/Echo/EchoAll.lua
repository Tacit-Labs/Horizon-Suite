--[[
    Horizon Suite - Echo - All
    The All view (plan 12): one read-only, quiet feed ("all") holding every line Echo files,
    plus everything else printed to the main chat window (addon prints, Blizzard system
    text that isn't a chat event, /dump). Never persisted, never grouped, capped at
    Store.ALL_CAP. Switched by echoAllView (Echo.FeedKey("all")).
      - Echo's records arrive through a Store listener: each becomes an All line with its
        chat's short name and sender in a separate prefix field. A secret text is kept as
        it is and never joined with the prefix; the view draws the prefix on its own.
      - Other text arrives through a post-hook on DEFAULT_CHAT_FRAME.AddMessage. A call
        from Blizzard's chat event handlers is skipped (Echo files those lines itself), as
        is one from Echo's own code, and one whose stack is secret.
    Blizzard: hooksecurefunc, DEFAULT_CHAT_FRAME.AddMessage (post-hook only), debugstack,
    UnitName.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local Store = Echo.Store
local IsSecret = Echo.IsSecret
local L = addon.L

local All = {}
Echo.All = All

All.KEY = "all"
All.ICON = "Interface\\Icons\\INV_Misc_Note_01"

-- A stack holding any of these came from a chat event Echo already files, or from Echo.
local ADDON_ROOT = "Interface/AddOns/" .. (addon.ADDON_NAME or "HorizonSuite")
All.SKIP_STACKS = {
    "ChatFrame_OnEvent",
    "MessageEventHandler",
    "Blizzard_Channels",
    ADDON_ROOT .. "/modules/Echo",
    ((ADDON_ROOT .. "/modules/Echo"):gsub("/", "\\")),
}
-- This file's own frame, which sits at the top of the hook's stack.
local OWN_FILE = "modules/Echo/EchoAll.lua"
local OWN_FILE_BACKSLASH = (OWN_FILE:gsub("/", "\\"))

local active = false
local subscribed = false
local hookedFrame

-- Nearby styles whose text already names the speaker.
local NAMED_STYLES = { textemote = true, npcemote = true }

local function Readable(s)
    if IsSecret(s) or type(s) ~= "string" or s == "" then return nil end
    return s
end

--- The prefix an All line shows before a record's text: the chat's short name in
-- brackets, then who spoke. nil when nothing readable is left to show.
-- @param conv table  the record's conversation
-- @param record table
-- @return string|nil
function All.PrefixFor(conv, record)
    local View = Echo.View
    if not View or type(conv) ~= "table" or type(record) ~= "table" then return nil end
    local name = Readable(View.DisplayName(conv))
    local kind = conv.kind
    if kind == "whisper" or kind == "bnet" then
        if not name then return nil end
        if record.outgoing then return "[" .. L["ECHO_ALL_TO"]:format(name) .. "]" end
        return "[" .. name .. "]"
    end
    local head = name and ("[" .. name .. "]") or nil
    if Store.FEED_KINDS[kind] or NAMED_STYLES[record.style] then return head end
    local who
    if record.outgoing then
        who = Readable(UnitName and UnitName("player"))
    else
        who = Readable(View.SenderName(record))
    end
    if not who then return head end
    -- A custom emote reads "[Nearby] Brisa dances", with no colon.
    local tail = (record.style == "emote") and who or (who .. ":")
    return head and (head .. " " .. tail) or tail
end

--- The All line for a record Echo filed.
-- @param conv table
-- @param record table
-- @return table line
function All.LineFor(conv, record)
    local r, g, b
    if Echo.View then r, g, b = Echo.View.LineColor(conv, record) end
    return {
        convKey = All.KEY,
        text    = record.text,
        secret  = (record.secret or IsSecret(record.text)) and true or false,
        prefix  = All.PrefixFor(conv, record),
        feed    = true,
        r = r, g = g, b = b,
        time    = record.time,
        source  = record.convKey,
    }
end

local function Collecting()
    return active and (not Echo.FeedEnabled or Echo.FeedEnabled(All.KEY))
end

--- Store listener: mirror each record Echo files into All. All's own lines, and changes
-- that carry no new record, are ignored.
-- @param convKey string|nil
-- @param change string|nil
-- @param record table|nil
function All.OnChange(convKey, change, record)
    if not Collecting() or convKey == nil or convKey == All.KEY or type(record) ~= "table" then return end
    local conv = Store.Get(convKey)
    if not conv then return end
    Store.Add(All.LineFor(conv, record))
end

-- True when a stack line comes from this file (the hook itself).
local function OwnLine(line)
    return line:find(OWN_FILE, 1, true) ~= nil or line:find(OWN_FILE_BACKSLASH, 1, true) ~= nil
end

--- True when an AddMessage call should be left out: its stack is secret, or it came from a
-- chat event handler or from Echo.
-- @param stack any  debugstack()'s result
-- @return boolean
function All.SkipStack(stack)
    if IsSecret(stack) then return true end
    if type(stack) ~= "string" then return false end
    for line in stack:gmatch("[^\n]+") do
        if not OwnLine(line) then
            for _, marker in ipairs(All.SKIP_STACKS) do
                if line:find(marker, 1, true) then return true end
            end
        end
    end
    return false
end

local function Colour(v)
    if IsSecret(v) or type(v) ~= "number" then return nil end
    return v
end

--- Post-hook on DEFAULT_CHAT_FRAME.AddMessage: file a printed line into All. A secret
-- text is filed as it is and never inspected.
function All.OnAddMessage(_, text, r, g, b)
    if not Collecting() then return end
    local stack
    if type(debugstack) == "function" then
        local ok, s = pcall(debugstack, 2)
        if ok then stack = s end
    end
    if All.SkipStack(stack) then return end
    local secret = IsSecret(text)
    if not secret then
        if type(text) == "number" then text = tostring(text) end
        if type(text) ~= "string" or text == "" then return end
    end
    r, g, b = Colour(r), Colour(g), Colour(b)
    if not (r and g and b) then r, g, b = 1, 1, 1 end
    Store.Add({
        convKey = All.KEY,
        text    = text,
        secret  = secret,
        feed    = true,
        r = r, g = g, b = b,
        time    = Store.Now(),
    })
end

--- Start collecting. The Store listener and the hook are installed once; Disable only
-- stops them acting, since a post-hook can't be removed.
function All.Enable()
    active = true
    if not subscribed then
        Store.Subscribe(All.OnChange)
        subscribed = true
    end
    local frame = _G.DEFAULT_CHAT_FRAME
    if not hookedFrame and type(frame) == "table" and type(hooksecurefunc) == "function" then
        hookedFrame = frame
        hooksecurefunc(frame, "AddMessage", All.OnAddMessage)
    end
end

function All.Disable()
    active = false
end

--- File a printed-style line into All: a chat type Echo doesn't route, while Blizzard's
-- chat windows are hidden (plan 12, Task 5, EchoHideChat.lua). A secret text is filed as
-- it is, never inspected; the prefix stays a field of its own and is never joined to it.
-- @param text string  may be secret
-- @param r number|nil  colour; white when any part is missing
-- @param g number|nil
-- @param b number|nil
-- @param prefix string|nil  drawn before the text, e.g. the sender's short name
-- @return boolean filed
function All.AddLine(text, r, g, b, prefix)
    if not Collecting() then return false end
    local secret = IsSecret(text)
    if not secret then
        if type(text) == "number" then text = tostring(text) end
        if type(text) ~= "string" or text == "" then return false end
    end
    r, g, b = Colour(r), Colour(g), Colour(b)
    if not (r and g and b) then r, g, b = 1, 1, 1 end
    Store.Add({
        convKey = All.KEY,
        text    = text,
        secret  = secret,
        prefix  = Readable(prefix),
        feed    = true,
        r = r, g = g, b = b,
        time    = Store.Now(),
    })
    return true
end
