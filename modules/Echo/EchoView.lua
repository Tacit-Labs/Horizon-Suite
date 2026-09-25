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
    loot = "LOOT", progress = "ACHIEVEMENT", system = "SYSTEM",
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
    if View.FEED_ICONS[kind] then
        spec.glyph = true
        spec.icon = View.FEED_ICONS[kind]
        spec.letter = ""
        spec.r, spec.g, spec.b = View.ChatColor(kind)
        if spec.count > 0 then
            local tier = Echo.Store.TierOf(conv.key)
            if tier == "loud" then spec.badge = "dot" elseif tier == "count" then spec.badge = "count" end
        end
        return spec
    end
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

--- The conversation to reply to: the newest incoming message among loud conversations
-- (a reply of your own moves a conversation up but does not make it the one waiting).
-- Falls back to NewestLoud when no loud conversation has an incoming message.
-- @param list table  Store.List()
-- @return table|nil conversation
function View.NewestIncomingLoud(list)
    local best, bestSeq
    for _, conv in ipairs(list) do
        if (conv.lastLoud or 0) > 0 then
            local msg = View.LastIncoming(conv)
            if msg and msg.seq and (not bestSeq or msg.seq > bestSeq) then
                best, bestSeq = conv, msg.seq
            end
        end
    end
    return best or View.NewestLoud(list)
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
    -- Only a whisper is one person; a group or channel card's last speaker isn't who the
    -- card is about, so it names no class (a Battle.net card keeps its relationship).
    local class = conv.kind == "whisper" and View.LastClass(conv) or nil
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

-- ---------------------------------------------------------------------------
-- The expanded card (plan 3)
-- ---------------------------------------------------------------------------

View.GROUP_GAP_SECONDS = 120

--- True when message i starts a new group: the other side, another speaker, or a pause.
-- A secret speaker can't be compared, so it always starts a group.
-- @param messages table
-- @param i number
-- @return boolean
function View.StartsGroup(messages, i)
    local cur, prev = messages[i], messages[i - 1]
    if not prev then return true end
    if (cur.outgoing and true or false) ~= (prev.outgoing and true or false) then return true end
    if not cur.outgoing then
        if Echo.IsSecret(cur.sender) or Echo.IsSecret(prev.sender) or cur.sender ~= prev.sender then
            return true
        end
    end
    if type(cur.time) == "number" and type(prev.time) == "number"
        and cur.time - prev.time > View.GROUP_GAP_SECONDS then
        return true
    end
    return false
end

--- Index of the newest outgoing message, or nil.
-- @param conv table
-- @return number|nil
function View.NewestOutgoing(conv)
    for i = #conv.messages, 1, -1 do
        if conv.messages[i].outgoing then return i end
    end
    return nil
end

--- Bubble width: fitted to readable text, the widest bubble when it couldn't be measured.
-- @param measured number|nil  the text's unwrapped width; nil for secret text
-- @param maxWidth number
-- @param pad number  inner padding on each side
-- @return number
function View.BubbleWidth(measured, maxWidth, pad)
    if type(measured) ~= "number" then return maxWidth end
    return math.min(maxWidth, math.ceil(measured) + pad * 2)
end

--- Who a conversation is with and whether they're online, where the game says.
-- @param conv table
-- @return string|nil label, boolean|nil online
function View.Relationship(conv)
    if conv.kind == "bnet" then
        local online
        local id = tonumber(conv.key:sub(4))
        local api = C_BattleNet and C_BattleNet.GetAccountInfoByID
        if id and type(api) == "function" then
            local ok, info = pcall(api, id)
            local game = ok and type(info) == "table" and info.gameAccountInfo
            if type(game) == "table" and not Echo.IsSecret(game.isOnline) then
                online = game.isOnline == true
            end
        end
        return L["ECHO_BATTLENET"], online
    elseif conv.kind == "whisper" then
        local name = conv.key:sub(3)
        local friends = C_FriendList and C_FriendList.GetFriendInfo
        if type(friends) == "function" then
            local ok, info = pcall(friends, name)
            if not ok or type(info) ~= "table" then
                ok, info = pcall(friends, name:match("^([^-]+)") or name)
            end
            if ok and type(info) == "table" then
                local online
                if not Echo.IsSecret(info.connected) then online = info.connected == true end
                return L["ECHO_FRIEND"], online
            end
        end
        local guild = C_GuildInfo and C_GuildInfo.MemberExistsByName
        if type(guild) == "function" then
            local ok, member = pcall(guild, name)
            if ok and not Echo.IsSecret(member) and member == true then return L["ECHO_GUILDMATE"], nil end
        end
    end
    return nil, nil
end

--- The card header's detail line: class (whispers only), relationship and online status,
-- readable parts only.
-- @param conv table
-- @return string
function View.CardMeta(conv)
    local parts = {}
    -- Only a whisper is one person; a group or channel card's last speaker isn't who the
    -- card is about, so it names no class (a Battle.net card keeps its relationship).
    local class = conv.kind == "whisper" and View.LastClass(conv) or nil
    if class and not Echo.IsSecret(class) then
        local names = LOCALIZED_CLASS_NAMES_MALE
        parts[#parts + 1] = (names and names[class]) or class
    end
    local relationship, online = View.Relationship(conv)
    if relationship then parts[#parts + 1] = relationship end
    if online ~= nil then parts[#parts + 1] = online and L["ECHO_ONLINE"] or L["ECHO_OFFLINE"] end
    return table.concat(parts, " · ")
end

--- The words under your newest message.
-- @param status string|nil  "pending" | "sent" | "failed"
-- @return string
function View.StatusText(status)
    if status == "pending" then return L["ECHO_STATUS_PENDING"] end
    if status == "sent" then return L["ECHO_STATUS_SENT"] end
    if status == "failed" then return L["ECHO_STATUS_FAILED"] end
    return ""
end

View.TIER_CHOICES = { "default", "loud", "count", "quiet", "muted" }

--- The ⋯ menu for a conversation, as data (EchoMenu builds the real menu from it).
-- @param conv table
-- @return table entries
function View.MenuSpec(conv)
    local override = Echo.Store.OverrideOf(conv.key) or "default"
    local defaultTier = Echo.Store.DEFAULT_TIERS[conv.kind] or "quiet"
    local entries = {
        { kind = "button", label = conv.pinned and L["ECHO_UNPIN"] or L["ECHO_PIN"], action = "pin" },
        { kind = "divider" },
        { kind = "title", label = L["ECHO_NOTIFICATIONS"] },
    }
    for _, value in ipairs(View.TIER_CHOICES) do
        local label
        if value == "default" then
            label = L["ECHO_TIER_DEFAULT"]:format(L["ECHO_TIER_" .. defaultTier:upper()])
        else
            label = L["ECHO_TIER_" .. value:upper()]
        end
        entries[#entries + 1] = { kind = "radio", label = label, action = "tier", value = value,
                                  selected = (value == override) }
    end
    entries[#entries + 1] = { kind = "divider" }
    entries[#entries + 1] = { kind = "button", label = L["ECHO_CLOSE_CONVERSATION"], action = "close" }
    return entries
end

-- Unsent replies per conversation, shared by the stack and the card.
Echo.Drafts = Echo.Drafts or {}

--- Keep a conversation's unsent reply while its box shows something else.
-- @param convKey string|nil
-- @param text string|nil
function Echo.ParkDraft(convKey, text)
    if not convKey then return end
    Echo.Drafts[convKey] = (type(text) == "string" and text ~= "") and text or nil
end

--- Take a conversation's parked reply back.
-- @param convKey string|nil
-- @return string  "" when there is none
function Echo.TakeDraft(convKey)
    if not convKey then return "" end
    local text = Echo.Drafts[convKey]
    Echo.Drafts[convKey] = nil
    return text or ""
end

function Echo.ClearDrafts()
    Echo.Drafts = {}
end

-- ---------------------------------------------------------------------------
-- Feeds (plan 4)
-- ---------------------------------------------------------------------------

View.FEED_ICONS = {
    loot     = "Interface\\Icons\\INV_Misc_Bag_10",
    progress = "Interface\\Icons\\Achievement_General",
    system   = "Interface\\Icons\\INV_Misc_Gear_01",
}

--- True for the read-only feeds (Loot, Progress, System).
-- @param kind string|nil
-- @return boolean
function View.IsFeed(kind)
    return kind ~= nil and Echo.Store.FEED_KINDS[kind] == true
end

--- Colour for one line: a feed line in its own line type's colour, else the conversation's.
-- @param conv table
-- @param msg table
-- @return number r, number g, number b
function View.LineColor(conv, msg)
    local info = msg and msg.chatType and ChatTypeInfo and ChatTypeInfo[msg.chatType]
    if info and info.r then return info.r, info.g, info.b end
    return View.ChatColor(conv.kind)
end

--- A feed line's timestamp, "HH:MM", or "" when there is no time.
-- @param t number|nil
-- @return string
function View.FeedTime(t)
    if type(t) ~= "number" or type(date) ~= "function" then return "" end
    local ok, stamp = pcall(date, "%H:%M", t)
    return (ok and type(stamp) == "string") and stamp or ""
end
