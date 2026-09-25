--[[
    Horizon Suite - Echo - View
    Pure helpers the Echo frames draw from: colours, tile specs, names, message lines,
    the column layout and the combat toast queue. No frames, so the logic harness tests it.
    Blizzard (read only): RAID_CLASS_COLORS, C_ClassColor, ChatTypeInfo, LOCALIZED_CLASS_NAMES_MALE.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo
local L = addon.L

local View = {}
Echo.View = View

--- A saved setting, falling back to Echo's default (options/modules/defaults/OptionsDefaultsEcho.lua).
-- @param key string
-- @return any
function Echo.Setting(key)
    local defaults = addon.ECHO_DEFAULTS
    local fallback = defaults and defaults[key]
    if not addon.GetDB then return fallback end
    return addon.GetDB(key, fallback)
end

-- Echo's module colour, #8FA3E8 (Docs/Branding/ColourSchema.md).
View.ACCENT = { r = 0x8F / 255, g = 0xA3 / 255, b = 0xE8 / 255 }
View.PANEL_BG = { 0.06, 0.06, 0.09, 0.94 }
View.PANEL_BORDER = { 0.28, 0.30, 0.38, 0.65 }
View.GLYPH_BG = { 0.10, 0.10, 0.13, 0.95 }
-- A whisper whose class is unknown, and a Battle.net friend not on a character.
View.NEUTRAL = { r = 0.45, g = 0.47, b = 0.55 }
View.BNET = { r = 0.00, g = 0.68, b = 1.00 }

View.GLYPHS = { party = "P", raid = "R", instance = "I", guild = "G", officer = "O" }

-- ChatTypeInfo keys, so each kind uses Blizzard's own chat colour.
View.CHAT_TYPE = {
    whisper = "WHISPER", bnet = "BN_WHISPER", party = "PARTY", raid = "RAID",
    instance = "INSTANCE_CHAT", guild = "GUILD", officer = "OFFICER", channel = "CHANNEL",
}

local FIRST_CHAR = "^[\1-\127\194-\244][\128-\191]*"

--- First character of a readable string, UTF-8 aware, upper-cased when ASCII.
-- @param s string
-- @return string  "?" for secret, empty or non-string input
function View.Initial(s)
    if Echo.IsSecret(s) or type(s) ~= "string" then return "?" end
    local c = s:match(FIRST_CHAR)
    if not c or c == "" then return "?" end
    return c:upper()
end

--- Class colour for a class file.
-- @param class string|nil
-- @return number|nil r, number g, number b
function View.ClassColor(class)
    if Echo.IsSecret(class) or type(class) ~= "string" then return nil end
    if C_ClassColor and C_ClassColor.GetClassColor then
        local ok, c = pcall(C_ClassColor.GetClassColor, class)
        if ok and c then return c.r, c.g, c.b end
    end
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if rc then return rc.r, rc.g, rc.b end
    return nil
end

--- Blizzard's chat colour for a conversation kind, else Echo's accent.
-- @param kind string
-- @return number r, number g, number b
function View.ChatColor(kind)
    local chatType = View.CHAT_TYPE[kind]
    local info = chatType and ChatTypeInfo and ChatTypeInfo[chatType]
    if info and info.r then return info.r, info.g, info.b end
    return View.ACCENT.r, View.ACCENT.g, View.ACCENT.b
end

--- The newest incoming message, by position (history-seeded messages all have seq 0).
-- @param conv table
-- @return table|nil record
function View.LastIncoming(conv)
    local messages = conv and conv.messages
    if not messages then return nil end
    for i = #messages, 1, -1 do
        if not messages[i].outgoing then return messages[i] end
    end
    return nil
end

--- The newest class seen on an incoming message.
-- @param conv table
-- @return string|nil
function View.LastClass(conv)
    local messages = conv.messages
    for i = #messages, 1, -1 do
        local m = messages[i]
        if not m.outgoing and m.class then return m.class end
    end
    return nil
end

--- Title for a conversation's tile, toast and card. A Battle.net name is a protected
-- string and is returned whole.
-- @param conv table
-- @return string
function View.DisplayName(conv)
    local key, kind = conv.key, conv.kind
    if kind == "whisper" then
        local name = key:sub(3)
        return name:match("^([^-]+)") or name
    elseif kind == "bnet" then
        local last = View.LastIncoming(conv)
        if last and last.sender then return last.sender end
        local tag = Echo.History and Echo.History.BattleTagFor(key)
        if tag then return tag:match("^([^#]+)") or tag end
        return L["ECHO_BATTLENET"]
    elseif kind == "channel" then
        return key:sub(4)
    end
    return L["ECHO_KIND_" .. kind:upper()]
end

--- What a tile shows.
-- @param conv table
-- @return table { letter, r, g, b, glyph = boolean|nil, badge = "dot"|"count"|nil, count = number }
function View.TileSpec(conv)
    local kind = conv.kind
    local spec = { count = conv.unread or 0 }
    if kind == "whisper" or kind == "bnet" then
        local r, g, b = View.ClassColor(View.LastClass(conv))
        if not r then
            local c = (kind == "bnet") and View.BNET or View.NEUTRAL
            r, g, b = c.r, c.g, c.b
        end
        spec.r, spec.g, spec.b = r, g, b
        if kind == "whisper" then
            spec.letter = View.Initial(conv.key:sub(3))
        else
            local tag = Echo.History and Echo.History.BattleTagFor(conv.key)
            spec.letter = View.Initial(tag or "B")
        end
    else
        spec.glyph = true
        spec.letter = View.GLYPHS[kind] or View.Initial(conv.key:sub(4))
        spec.r, spec.g, spec.b = View.ChatColor(kind)
    end
    local tier = Echo.Store.TierOf(conv.key)
    if spec.count > 0 then
        if tier == "loud" then
            spec.badge = "dot"
        elseif tier == "count" then
            spec.badge = "count"
        end
    end
    return spec
end

--- Which conversations get a tile. Past maxTiles, the last slot becomes a +N tile.
-- @param list table  Store.List()
-- @param maxTiles number|nil
-- @return table visible, number overflow
function View.Column(list, maxTiles)
    maxTiles = math.max(1, maxTiles or 8)
    if #list <= maxTiles then return list, 0 end
    local visible = {}
    for i = 1, maxTiles - 1 do visible[i] = list[i] end
    return visible, #list - (maxTiles - 1)
end

--- The conversation with the most recent loud message, else the first one.
-- @param list table
-- @return table|nil conv
function View.NewestLoud(list)
    local best
    for _, conv in ipairs(list) do
        if (conv.lastLoud or 0) > 0 and (not best or conv.lastLoud > best.lastLoud) then best = conv end
    end
    return best or list[1]
end

--- The last n messages, oldest first.
-- @param conv table
-- @param n number
-- @return table records
function View.Recent(conv, n)
    local out, messages = {}, conv.messages
    for i = math.max(1, #messages - n + 1), #messages do out[#out + 1] = messages[i] end
    return out
end

--- Short age: "just now", "5m", "3h", "2d".
-- @param seconds number
-- @return string
function View.Age(seconds)
    seconds = math.max(0, seconds or 0)
    if seconds < 60 then return L["ECHO_JUST_NOW"] end
    if seconds < 3600 then return ("%dm"):format(math.floor(seconds / 60)) end
    if seconds < 86400 then return ("%dh"):format(math.floor(seconds / 3600)) end
    return ("%dd"):format(math.floor(seconds / 86400))
end

--- Card header detail: class (or Battle.net), unread count and age. Readable parts only.
-- @param conv table
-- @param now number
-- @return string
function View.MetaLine(conv, now)
    local parts = {}
    local class = View.LastClass(conv)
    if class and not Echo.IsSecret(class) then
        local names = LOCALIZED_CLASS_NAMES_MALE
        parts[#parts + 1] = (names and names[class]) or class
    elseif conv.kind == "bnet" then
        parts[#parts + 1] = L["ECHO_BATTLENET"]
    end
    if (conv.unread or 0) > 0 then parts[#parts + 1] = L["ECHO_NEW_COUNT"]:format(conv.unread) end
    local last = conv.messages[#conv.messages]
    if last and last.time then parts[#parts + 1] = View.Age(now - last.time) end
    return table.concat(parts, " · ")
end

--- Text for one message line. An incoming group line names the speaker when both parts
-- are readable. A secret text is returned untouched: SetText can show it, nothing may join it.
-- @param conv table
-- @param msg table
-- @return string|any
function View.LineText(conv, msg)
    local text = msg.text
    if msg.secret or Echo.IsSecret(text) then return text end
    if conv.kind ~= "whisper" and conv.kind ~= "bnet" and not msg.outgoing
        and not Echo.IsSecret(msg.sender) and type(msg.sender) == "string" then
        local short = msg.sender:match("^([^-]+)") or msg.sender
        return short .. ": " .. tostring(text)
    end
    return text
end

--- Toasts held during combat: one per conversation, played newest first afterwards.
-- @return table queue  :Hold(key, seq), :Release() -> keys, :Count()
function View.NewToastQueue()
    local queue = { held = {}, count = 0 }
    function queue:Hold(key, seq)
        if self.held[key] == nil then self.count = self.count + 1 end
        self.held[key] = seq or 0
    end
    function queue:Release()
        local entries = {}
        for key, seq in pairs(self.held) do entries[#entries + 1] = { key = key, seq = seq } end
        table.sort(entries, function(a, b) return a.seq > b.seq end)
        self.held, self.count = {}, 0
        local keys = {}
        for i, e in ipairs(entries) do keys[i] = e.key end
        return keys
    end
    function queue:Count()
        return self.count
    end
    return queue
end
