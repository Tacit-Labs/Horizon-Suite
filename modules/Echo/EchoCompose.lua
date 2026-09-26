--[[
    Horizon Suite - Echo - Compose
    The + button's menu: every place you can start a chat right now. Whisper... (a name
    prompt), online friends, Nearby, guild and officer chat, your group, and your joined
    channels. Choosing one starts its conversation (Store.Start) and opens the card on it.
    Blizzard: MenuUtil.CreateContextMenu, StaticPopup_Show, C_FriendList, BNGetNumFriends,
    C_BattleNet.GetFriendAccountInfo, GetChannelList, IsInGroup, GetAutoCompleteResults.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Compose = {}
Echo.Compose = Compose

Compose.MAX_FRIENDS = 20
Compose.POPUP = "HORIZON_ECHO_NEW_WHISPER"  -- a StaticPopupDialogs key, not a frame name

local function IsSecret(v) return Echo.IsSecret(v) end

-- Call a Blizzard function safely: nil when it is missing or throws.
local function Call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local results = { pcall(fn, ...) }
    if not results[1] then return nil end
    table.remove(results, 1)
    return results
end

-- A readable true from a Blizzard check; a missing, throwing or secret answer is false.
local function IsTrue(fn, ...)
    local r = Call(fn, ...)
    if not r or IsSecret(r[1]) then return false end
    return r[1] and true or false
end

-- A readable number, else nil.
local function Number(v)
    if IsSecret(v) or type(v) ~= "number" then return nil end
    return v
end

-- A readable, non-empty string, else nil.
local function Text(v)
    if IsSecret(v) or type(v) ~= "string" or v == "" then return nil end
    return v
end

--- Start a conversation and open the card on it, focused, growing from its tile (or its
-- group's tile).
-- @param convKey string
-- @return boolean started
function Compose.Choose(convKey)
    if not Echo.Store.Start(convKey) then return false end
    local Tiles = Echo.Tiles
    -- Store.Start's repaint waits for the next frame; the card grows from the tile now.
    if Tiles and Tiles.Refresh then Tiles.Refresh() end
    local tile = Tiles and Tiles.TileFor and Tiles.TileFor(convKey) or nil
    if Echo.Card then
        Echo.Card.Open(convKey, true, tile)
    elseif Echo.Stack then
        Echo.Stack.Open(convKey)
    end
    return true
end

-- Party chat needs a home group; an instance group alone talks in Instance.
local function InHomeGroup()
    if LE_PARTY_CATEGORY_HOME ~= nil then return IsTrue(IsInGroup, LE_PARTY_CATEGORY_HOME) end
    return IsTrue(IsInGroup)
end

--- The online friends to offer: character friends, then Battle.net friends where the client
-- has Battle.net whispers, at most MAX_FRIENDS. A Battle.net label is the account's |K
-- name, shown whole and never cut or matched.
-- @return table entries  { { label = string, key = string } }
function Compose.OnlineFriends()
    local out = {}
    local api = C_FriendList
    local count = type(api) == "table" and Call(api.GetNumFriends)
    count = count and Number(count[1]) or 0
    for i = 1, count do
        if #out >= Compose.MAX_FRIENDS then return out end
        local r = Call(api.GetFriendInfoByIndex, i)
        local info = r and r[1]
        if not IsSecret(info) and type(info) == "table" and not IsSecret(info.connected) and info.connected == true then
            local name = Text(info.name)
            local key = name and Echo.Send.WhisperKeyFor(name)
            if key then out[#out + 1] = { label = name, key = key } end
        end
    end
    if not (addon.Platform and addon.Platform.Has("bnetWhispers")) then return out end
    local accountInfo = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    local bnCount = Call(BNGetNumFriends)
    bnCount = bnCount and Number(bnCount[1]) or 0
    for i = 1, bnCount do
        if #out >= Compose.MAX_FRIENDS then return out end
        local r = Call(accountInfo, i)
        local info = r and r[1]
        if not IsSecret(info) and type(info) == "table" then
            local game = info.gameAccountInfo
            local online = not IsSecret(game) and type(game) == "table" and not IsSecret(game.isOnline)
                and game.isOnline == true
            local id = Number(info.bnetAccountID)
            local label = Text(info.accountName)
            if online and id and label then
                out[#out + 1] = { label = label, key = Echo.Store.KeyFor("bnet", id) }
            end
        end
    end
    return out
end

--- Every joined channel, in slot order: GetChannelList returns (id, name, disabled)
-- triples. A zone channel's joined name may carry the zone, which its key leaves out.
-- @return table entries  { { label = string, key = string } }
function Compose.JoinedChannels()
    local out = {}
    local r = Call(GetChannelList)
    if not r then return out end
    local View = Echo.View
    for i = 1, #r, 3 do
        local id, name, disabled = Number(r[i]), Text(r[i + 1]), r[i + 2]
        if id and name and not IsSecret(disabled) and not disabled then
            local zone = name:find(" - ", 1, true) and 1 or nil
            local keyName = Echo.Events.ChannelKeyName(name, zone)
            local key = keyName and Echo.Store.KeyFor("channel", keyName)
            if key then
                local label = id .. ". " .. keyName
                local icon = View.CHANNEL_ICONS[(keyName:gsub(" ", ""))]
                if icon then label = "|T" .. icon .. ":14:14:0:0|t " .. label end
                out[#out + 1] = { label = label, key = key }
            end
        end
    end
    return out
end

-- The popup's edit box and its text, whichever field name the client uses.
local function EditBoxOf(popup)
    if type(popup) ~= "table" then return nil end
    return rawget(popup, "editBox") or rawget(popup, "EditBox")
end

--- Accept a name typed in the Whisper... prompt: start that whisper and open it.
-- @param text string
-- @return boolean started
function Compose.AcceptWhisper(text)
    if IsSecret(text) or type(text) ~= "string" then return false end
    local name = text:gsub("^%s+", ""):gsub("%s+$", "")
    local key = Echo.Send.WhisperKeyFor(name)
    if not key then return false end
    return Compose.Choose(key)
end

local function PopupText(popup)
    local box = EditBoxOf(popup)
    if not box or type(box.GetText) ~= "function" then return nil end
    local r = Call(box.GetText, box)
    return r and r[1]
end

-- Register the Whisper... prompt on first use.
local function RegisterPopup()
    if type(StaticPopupDialogs) ~= "table" then return false end
    if StaticPopupDialogs[Compose.POPUP] then return true end
    local L = addon.L
    local dialog = {
        text = L["ECHO_COMPOSE_WHISPER_PROMPT"],
        button1 = _G.ACCEPT or _G.OKAY,
        button2 = _G.CANCEL,
        hasEditBox = true,
        maxLetters = 64,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            local box = EditBoxOf(self)
            if box then
                box:SetText("")
                box:SetFocus()
            end
        end,
        OnAccept = function(self)
            Compose.AcceptWhisper(PopupText(self))
        end,
        EditBoxOnEnterPressed = function(box)
            local text = type(box.GetText) == "function" and box:GetText() or nil
            local parent = type(box.GetParent) == "function" and box:GetParent() or nil
            if parent and type(parent.Hide) == "function" then parent:Hide() end
            Compose.AcceptWhisper(text)
        end,
        EditBoxOnEscapePressed = function(box)
            local parent = type(box.GetParent) == "function" and box:GetParent() or nil
            if parent and type(parent.Hide) == "function" then parent:Hide() end
        end,
    }
    -- Name suggestions as you type. StaticPopup_Show unpacks autoCompleteArgs into
    -- GetAutoCompleteResults(text, include, exclude), so it is the list's two masks.
    local list = type(AUTOCOMPLETE_LIST) == "table" and AUTOCOMPLETE_LIST.WHISPER
    if type(GetAutoCompleteResults) == "function" and type(list) == "table" then
        dialog.autoCompleteSource = GetAutoCompleteResults
        dialog.autoCompleteArgs = { list.include, list.exclude }
    end
    StaticPopupDialogs[Compose.POPUP] = dialog
    return true
end

--- Show the Whisper... prompt.
-- @return boolean shown
function Compose.PromptWhisper()
    if not RegisterPopup() or type(StaticPopup_Show) ~= "function" then return false end
    return pcall(StaticPopup_Show, Compose.POPUP)
end

-- A button that starts one conversation.
local function Entry(parent, label, key)
    parent:CreateButton(label, function() Compose.Choose(key) end)
end

-- A submenu of entries, left out when it would be empty.
local function Submenu(root, label, entries)
    if #entries == 0 then return end
    local sub = root:CreateButton(label)
    for _, e in ipairs(entries) do Entry(sub, e.label, e.key) end
end

--- Fill a MenuUtil root description with the places you can start a chat now.
-- @param rootDescription table
function Compose.Build(rootDescription)
    local L = addon.L
    local Send = Echo.Send
    rootDescription:CreateButton(L["ECHO_COMPOSE_WHISPER"], function() Compose.PromptWhisper() end)
    Submenu(rootDescription, L["ECHO_COMPOSE_FRIENDS"], Compose.OnlineFriends())
    Entry(rootDescription, L["ECHO_NEARBY"], "nearby")
    -- Send.CanReach is the same check a /g, /o, /ra or /i shortcut makes (officer rights
    -- included). Party asks for a home group here, which CanReach("party") doesn't.
    if Send.CanReach("guild") then Entry(rootDescription, L["ECHO_KIND_GUILD"], "guild") end
    if Send.CanReach("officer") then Entry(rootDescription, L["ECHO_KIND_OFFICER"], "officer") end
    if InHomeGroup() then Entry(rootDescription, L["ECHO_KIND_PARTY"], "party") end
    if Send.CanReach("raid") then Entry(rootDescription, L["ECHO_KIND_RAID"], "raid") end
    if Send.CanReach("instance") then Entry(rootDescription, L["ECHO_KIND_INSTANCE"], "instance") end
    Submenu(rootDescription, L["ECHO_COMPOSE_CHANNELS"], Compose.JoinedChannels())
end

--- Open the menu from the + button.
-- @param owner Frame
-- @return boolean opened
function Compose.Open(owner)
    if not (Echo.Menu and Echo.Menu.Available()) then return false end
    MenuUtil.CreateContextMenu(owner, function(_, rootDescription) Compose.Build(rootDescription) end)
    return true
end
