--[[
    Horizon Suite - Echo - Input
    Blizzard's own input line, ChatFrame1EditBox, docked under Echo and restyled to match.
    Enter, /, R and Blizzard's Whisper keep working because the box is still the game's:
    Echo only moves it, lifts it to the column's strata (and above the card), re-fonts it and
    its FontStrings, recolours its header, fades its border textures, and draws the card's
    reply-box look behind it: a rounded fill, a chat-coloured chip behind the header ("Say:")
    and a "Reply…" hint while the box is empty. Every one of those goes back when docking
    goes off. A SetPoint from anyone else while docked is undone.
    Over an open card it takes the card's reply slot (Card.ReplySlot); with no card it sits
    beside the Echo icon at the column's foot, on the side panels open to. The card hides
    its own reply box, mode chip and send button while the line is shown over it.
    While the line is being typed in, the card follows it: Blizzard's Whisper, R, /w, /g
    and /1 open the conversation the line is aimed at, once per target, without focus
    or the genie.
    Blizzard's chat code is only observed: hooksecurefunc post-hooks on the activate,
    deactivate and header functions and on the box's SetPoint, and HookScript post-hooks on
    its OnShow, OnHide and OnTextChanged. Echo never calls them, never focuses the box, never
    sets its text or text insets and never sets its attributes (Task 1's probe in
    EchoSlash.lua is the one exception).
    Blizzard: ChatFrame1EditBox (GetPoint, GetNumPoints, GetScale, GetRegions, GetAttribute,
    GetFrameLevel, GetFrameStrata, GetFont, GetText, HasFocus, IsVisible, IsInIMECompositionMode,
    ClearAllPoints, SetPoint, SetScale, SetFrameStrata, SetFrameLevel, SetFont, HookScript;
    Show, SetShown and SetAlpha from the activate and deactivate post-hooks and at enable;
    Hide at disable), its header and headerSuffix FontStrings (GetText, GetStringWidth,
    GetTextColor, SetTextColor, SetFont, GetParentKey), hooksecurefunc,
    ChatFrameUtil.ActivateChat / DeactivateChat / UpdateHeader or the ChatEdit_ equivalents,
    ChatTypeInfo, GetChannelName (through Send.ChannelKeyForSlot),
    BNGetNumFriends, C_BattleNet.GetFriendAccountInfo.
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Input = {}
Echo.Input = Input

Input.FONT_SIZE = 12  -- for a FontString whose own size can't be read
Input.HEADER_SIZE = 10  -- the header's font size, as the card's mode chip label
Input.CHIP_PAD = 8      -- the chip reaches this far before the header
Input.CHIP_PAD_RIGHT = 2  -- and only this far after it: Blizzard starts the typed text right after the header
Input.CHIP_HEIGHT = 22
Input.CHIP_WIDTH = 48   -- for a header whose width is secret or unreadable
Input.CHIP_ALPHA = 0.22
Input.CARD_LIFT = 3     -- over the card, the box draws at least this many levels above it
local CHIP_LABEL = { 0.92, 0.93, 0.98, 1 }  -- the card's mode chip label colour
local HINT_COLOR = { 0.5, 0.52, 0.6, 1 }    -- the card's placeholder colour

local active = false  -- docked now
local saved           -- what enable changed on the box: points, scale, texture alphas, fonts
local background      -- Echo's rounded panel behind the box
local chip            -- Echo's rounded chip behind Blizzard's header
local hint            -- Echo's "Reply…" hint while the box is empty
local lifted = false  -- the box's frame level was raised above the card
local hooked = false  -- the post-hooks are installed once and stay
local anchoring = false  -- Echo's own SetPoint calls on the box are running; its hook lets them by
local alwaysShown = false  -- always-visible put the box on screen, not Blizzard's own activate
local followed        -- the conversation the card last opened because the line aimed at it

-- The conversation each chat type sends to, for the types keyed by kind alone.
local KIND_OF = {
    GUILD = "guild", OFFICER = "officer", PARTY = "party", RAID = "raid",
    INSTANCE_CHAT = "instance", SAY = "nearby", YELL = "nearby", EMOTE = "nearby",
}

local function Box()
    return _G.ChatFrame1EditBox
end

local function Attribute(box, name)
    if not box or type(box.GetAttribute) ~= "function" then return nil end
    local v = box:GetAttribute(name)
    if Echo.IsSecret(v) then return nil end
    return v
end

-- The "bn:<accountID>" conversation of the Battle.net friend whose account name is this
-- one, else nil. Account names are |K protected strings: they are only ever compared as
-- whole strings, never searched, cut or parsed.
local function BattleNetKey(accountName)
    if type(accountName) ~= "string" or accountName == "" then return nil end
    local api = C_BattleNet and C_BattleNet.GetFriendAccountInfo
    if type(BNGetNumFriends) ~= "function" or type(api) ~= "function" then return nil end
    local okCount, count = pcall(BNGetNumFriends)
    if not okCount or Echo.IsSecret(count) or type(count) ~= "number" then return nil end
    for i = 1, count do
        local ok, info = pcall(api, i)
        if ok and not Echo.IsSecret(info) and type(info) == "table" then
            local name = info.accountName
            if not Echo.IsSecret(name) and name == accountName then
                local id = info.bnetAccountID
                if Echo.IsSecret(id) or type(id) ~= "number" then return nil end
                return Echo.Store.KeyFor("bnet", id)
            end
        end
    end
    return nil
end

--- The conversation Blizzard's input line sends to now, or nil.
-- @return string|nil convKey
function Input.TargetKey()
    local box = Box()
    local chatType = Attribute(box, "chatType")
    if type(chatType) ~= "string" then return nil end
    if KIND_OF[chatType] then return KIND_OF[chatType] end
    if chatType == "WHISPER" then
        local key = Echo.Send.WhisperKeyFor(Attribute(box, "tellTarget"))
        return key and (Echo.Store.WhisperKeyLike(key) or key)
    end
    if chatType == "BN_WHISPER" then
        return BattleNetKey(Attribute(box, "tellTarget"))
    end
    if chatType == "CHANNEL" then
        local slot = Attribute(box, "channelTarget")
        if slot == nil then return nil end
        return Echo.Send.ChannelKeyForSlot(slot)
    end
    return nil
end

--- Whether the docked line is on screen over the shown card, in its reply slot: the card
-- then hides its own reply box, whatever conversation the line sends to.
-- @param convKey string|nil  the card's conversation
-- @return boolean
function Input.Covers(convKey)
    if not active or convKey == nil then return false end
    local box = Box()
    -- IsVisible, not IsShown: a box shown under a hidden parent isn't on screen.
    if not box or not box:IsVisible() then return false end
    return Echo.Card ~= nil and Echo.Card.IsShown()
end

--- @return boolean
function Input.IsDocked()
    return active
end

-- The card's reply box depends on the line's target and whether it is shown.
local function RefreshCard()
    if Echo.Redraw and Echo.Card and Echo.Card.IsShown() then Echo.Redraw.Mark("card") end
end

-- Blizzard's chat colour for the line's chat type; a channel uses its own slot's colour.
local function LineColor(box)
    local chatType = Attribute(box, "chatType")
    local info
    local types = _G.ChatTypeInfo
    if types and type(chatType) == "string" then
        if chatType == "CHANNEL" then
            local slot = Attribute(box, "channelTarget")
            if slot ~= nil and type(GetChannelName) == "function" then
                local ok, id = pcall(GetChannelName, slot)
                if ok and not Echo.IsSecret(id) and type(id) == "number" and id > 0 then
                    info = types["CHANNEL" .. id]
                end
            end
            info = info or types.CHANNEL
        else
            info = types[chatType]
        end
    end
    if info and type(info.r) == "number" then return info.r, info.g, info.b end
    local a = Echo.View.ACCENT
    return a.r, a.g, a.b
end

-- A FontString Blizzard keys on the box (header, headerSuffix): the field, read raw so no
-- Lua is written or triggered on the box, else the region whose parentKey it is.
local function Keyed(box, key)
    local fs = rawget(box, key)
    if type(fs) == "table" then return fs end
    if type(box.GetRegions) ~= "function" then return nil end
    for _, region in ipairs({ box:GetRegions() }) do
        if type(region.GetParentKey) == "function" and region:GetParentKey() == key then return region end
    end
    return nil
end

-- The header's rendered width, or nil when its text or width is secret or unreadable.
local function HeaderWidth(header)
    if type(header.GetText) == "function" and Echo.IsSecret(header:GetText()) then return nil end
    if type(header.GetStringWidth) ~= "function" then return nil end
    local ok, w = pcall(header.GetStringWidth, header)
    if not ok or Echo.IsSecret(w) or type(w) ~= "number" or w <= 0 then return nil end
    return w
end

--- The chip behind Blizzard's header: sized to the header, in the line's chat colour, the
-- header (and its suffix) in the chip label colour. Runs after Blizzard's UpdateHeader.
function Input.PaintChip()
    if not active or not chip then return end
    local box = Box()
    local header = box and Keyed(box, "header")
    if not header then
        chip:Hide()
        return
    end
    local w = HeaderWidth(header)
    local width = w and (w + Input.CHIP_PAD + Input.CHIP_PAD_RIGHT) or Input.CHIP_WIDTH
    chip:ClearAllPoints()
    chip:SetPoint("LEFT", header, "LEFT", -Input.CHIP_PAD, 0)
    chip:SetSize(width, Input.CHIP_HEIGHT)
    local r, g, b = LineColor(box)
    Echo.Round.SetColor(chip, r, g, b, Input.CHIP_ALPHA)
    chip:Show()
    header:SetTextColor(CHIP_LABEL[1], CHIP_LABEL[2], CHIP_LABEL[3], CHIP_LABEL[4])
    local suffix = Keyed(box, "headerSuffix")
    if suffix and type(suffix.SetTextColor) == "function" then
        suffix:SetTextColor(CHIP_LABEL[1], CHIP_LABEL[2], CHIP_LABEL[3], CHIP_LABEL[4])
    end
end

-- The hint shows while the box is empty (readably, not a secret) and no IME text is being
-- composed in it.
local function PaintHint(box)
    if not hint then return end
    local show = false
    if active and box and type(box.GetText) == "function" then
        local text = box:GetText()
        show = not Echo.IsSecret(text) and text == ""
    end
    if show and type(box.IsInIMECompositionMode) == "function" then
        local ime = box:IsInIMECompositionMode()
        if Echo.IsSecret(ime) or ime then show = false end
    end
    hint:SetShown(show)
end

-- Blizzard's border and focus textures go transparent; activate and the header can bring
-- them back, so both hooks fade them again.
local function FadeTextures()
    if not saved then return end
    for texture in pairs(saved.alphas) do texture:SetAlpha(0) end
end

local function SyncBackground(box)
    if background then background:SetShown(active and box:IsShown()) end
    if chip then chip:SetShown(active and box:IsShown() and Keyed(box, "header") ~= nil) end
    PaintHint(box)
end

-- The card's reply-box look: its fill and radius, no border. The chip and the hint are
-- the background's own children, so they show, hide and scale with it.
local function Background(box)
    if not background then
        local column = _G.HorizonSuiteEchoColumn
        local parent = (column and column:GetParent()) or UIParent
        background = CreateFrame("Frame", nil, parent)
        Echo.Round.Apply(background, { radius = Echo.Round.SMALL, layer = "BACKGROUND" })
        local fill = Echo.Card.EDIT_BG
        Echo.Round.SetColor(background, fill[1], fill[2], fill[3], fill[4])
        -- BORDER, above the background's own BACKGROUND fill.
        chip = CreateFrame("Frame", nil, background)
        Echo.Round.Apply(chip, { radius = Echo.Round.SMALL, layer = "BORDER" })
        chip:Hide()
        hint = Echo.NewText(background, 12, "")
        hint:SetPoint("LEFT", chip, "RIGHT", 6, 0)
        hint:SetTextColor(HINT_COLOR[1], HINT_COLOR[2], HINT_COLOR[3], HINT_COLOR[4])
        hint:SetText(addon.L["ECHO_REPLY"])
        hint:Hide()
    end
    background:ClearAllPoints()
    background:SetPoint("TOPLEFT", box, "TOPLEFT", 0, 0)
    background:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0)
    local strata = box:GetFrameStrata()
    if type(strata) == "string" then background:SetFrameStrata(strata) end
    local level = box:GetFrameLevel()
    -- At level 0 the background shares the box's level and stays under it by drawing in BACKGROUND.
    local under = math.max(0, (tonumber(level) or 1) - 1)
    background:SetFrameLevel(under)
    chip:SetFrameLevel(under)  -- under the box, so the header draws over it
    return background
end

-- The box's scale that matches the column's, whatever the box's own parent is scaled to.
local function ColumnScale(box, column)
    local parent = type(box.GetParent) == "function" and box:GetParent()
    local ps = parent and type(parent.GetEffectiveScale) == "function" and parent:GetEffectiveScale()
    local cs = type(column.GetEffectiveScale) == "function" and column:GetEffectiveScale()
    if type(ps) == "number" and ps > 0 and type(cs) == "number" and cs > 0 then return cs / ps end
    return column:GetScale() or 1
end

--- Put the line in the open card's reply slot, or beside the Echo icon at the column's foot.
-- ChatFrame1EditBox isn't protected, so this is allowed in combat too.
local function Anchor(box, column)
    box:ClearAllPoints()
    box:SetScale(ColumnScale(box, column))
    local strata = column:GetFrameStrata()
    if type(strata) == "string" then box:SetFrameStrata(strata) end
    local card = _G.HorizonSuiteEchoCard
    local slot = card and Echo.Card.IsShown() and Echo.Card.ReplySlot and Echo.Card.ReplySlot()
    if slot then
        box:SetPoint("TOPLEFT", slot, "TOPLEFT", 0, 0)
        box:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 0, 0)
        -- Over the card now, so it must draw above the card's panel.
        local want = (tonumber(card:GetFrameLevel()) or 0) + Input.CARD_LIFT
        local level = box:GetFrameLevel()
        if Echo.IsSecret(level) or type(level) ~= "number" or level < want then
            box:SetFrameLevel(want)
            lifted = true
        end
    else
        if lifted and saved and type(saved.level) == "number" then box:SetFrameLevel(saved.level) end
        lifted = false
        local icon = (Echo.Tiles.StackButton and Echo.Tiles.StackButton()) or column
        local width = Echo.Card.WIDTH
        local side = Echo.View.PanelSides(Echo.View.PanelEdge(width))
        if side.dx > 0 then
            box:SetPoint("LEFT", icon, "RIGHT", side.dx, 0)
            box:SetPoint("RIGHT", icon, "RIGHT", side.dx + width, 0)
        else
            box:SetPoint("RIGHT", icon, "LEFT", side.dx, 0)
            box:SetPoint("LEFT", icon, "LEFT", side.dx - width, 0)
        end
    end
end

function Input.Reanchor()
    if not active then return end
    local box, column = Box(), _G.HorizonSuiteEchoColumn
    if not box or not column then return end
    -- Always clear the flag, even on an error, or every later foreign SetPoint would pass.
    anchoring = true
    local ok, err = pcall(Anchor, box, column)
    anchoring = false
    if not ok then
        local handler = geterrorhandler and geterrorhandler()
        if handler then handler(err) end
        return
    end
    local bg = Background(box)
    if type(bg.SetScale) == "function" then bg:SetScale(column:GetScale() or 1) end
    SyncBackground(box)
end

-- Whether the box has the keyboard now, read without trusting a secret answer.
local function Focused(box)
    if type(box.HasFocus) ~= "function" then return false end
    local focus = box:HasFocus()
    return not Echo.IsSecret(focus) and focus == true
end

-- The line is being typed in and aims at a conversation: open it on the card, without
-- focusing the card's reply box and without the genie, once per target. The header and
-- activate hooks both call this, since the header can update before the box has focus.
-- Say, Yell and Emote set Nearby's mode each time, since switching among them keeps the
-- same conversation.
local function Follow(box)
    if not box:IsVisible() or not Focused(box) then return end
    local Card = Echo.Card
    if Card.IsClosing and Card.IsClosing() then return end
    local key = Input.TargetKey()
    if key == nil then return end
    if key == "nearby" then
        local mode = Attribute(box, "chatType")
        if type(mode) == "string" then Echo.Store.SetSendMode("nearby", mode) end
    end
    if key == followed then return end
    followed = key
    Echo.Store.Start(key)
    Card.Show(key, nil)  -- no tile, so no genie: the line is being typed in
end

local function OnActivate(editBox)
    if not active or editBox ~= Box() then return end
    -- Blizzard's own chat-frame layout can re-anchor the box; take it back as typing starts.
    Input.Reanchor()
    FadeTextures()
    alwaysShown = false  -- Blizzard's own flow has it now
    editBox:Show()
    SyncBackground(editBox)
    -- A header update that ran before the box took focus followed nothing; catch it here.
    Follow(editBox)
    RefreshCard()
end

local function OnDeactivate(editBox)
    if not active or editBox ~= Box() then return end
    followed = nil  -- the next time the line opens, its target opens the card again
    local always = Echo.Setting("echoInputAlwaysVisible") == true
    editBox:SetShown(always)
    if always then editBox:SetAlpha(1) end
    alwaysShown = always
    SyncBackground(editBox)
    RefreshCard()
end

local function OnHeader(editBox)
    if not active or editBox ~= Box() then return end
    FadeTextures()
    Input.PaintChip()
    PaintHint(editBox)
    Follow(editBox)
    RefreshCard()
end

-- Blizzard's layout moved the box while it is docked: put it back. Echo's own calls pass.
local function OnSetPoint(editBox)
    if not active or anchoring or editBox ~= Box() then return end
    Input.Reanchor()
end

local function OnBoxShown(editBox)
    if not active or editBox ~= Box() then return end
    SyncBackground(editBox)
    RefreshCard()  -- a box hidden by any path must give the card its reply box back
end

local function OnTextChanged(editBox)
    if not active or editBox ~= Box() then return end
    PaintHint(editBox)
end

-- Post-hook table[name] when it is a function; true when hooked.
local function HookMethod(target, name, fn)
    if type(target) ~= "table" or type(target[name]) ~= "function" then return false end
    hooksecurefunc(target, name, fn)
    return true
end

local function HookGlobal(name, fn)
    if type(_G[name]) ~= "function" then return false end
    hooksecurefunc(name, fn)
    return true
end

-- Installed once; each handler does nothing while docking is off.
local function Hook(box)
    if hooked or type(hooksecurefunc) ~= "function" then return end
    hooked = true
    local util = _G.ChatFrameUtil
    if not HookMethod(util, "ActivateChat", OnActivate) then HookGlobal("ChatEdit_ActivateChat", OnActivate) end
    if not HookMethod(util, "DeactivateChat", OnDeactivate) then HookGlobal("ChatEdit_DeactivateChat", OnDeactivate) end
    if not HookMethod(box, "UpdateHeader", OnHeader) and not HookMethod(util, "UpdateHeader", OnHeader) then
        HookGlobal("ChatEdit_UpdateHeader", OnHeader)
    end
    HookMethod(box, "SetPoint", OnSetPoint)
    if type(box.HookScript) == "function" then
        box:HookScript("OnShow", OnBoxShown)
        box:HookScript("OnHide", OnBoxShown)
        box:HookScript("OnTextChanged", OnTextChanged)
    end
end

-- Note the box's points, scale, level, texture alphas, fonts and header colours, so
-- disable can put them back.
local function Record(box)
    local s = { points = {}, alphas = {}, fonts = {}, colors = {}, headers = {} }
    for i = 1, box:GetNumPoints() or 0 do
        local point, rel, relPoint, x, y = box:GetPoint(i)
        s.points[i] = { point, rel, relPoint, x, y }
    end
    s.scale = box:GetScale()
    s.strata = box:GetFrameStrata()
    s.level = box:GetFrameLevel()
    if type(box.GetFont) == "function" then
        local path, size, flags = box:GetFont()
        s.boxFont = { path, size, flags }
    end
    for _, region in ipairs({ box:GetRegions() }) do
        if region:IsObjectType("Texture") then
            s.alphas[region] = region:GetAlpha()
        elseif region:IsObjectType("FontString") then
            local path, size, flags = region:GetFont()
            s.fonts[region] = { path, size, flags }
        end
    end
    for _, key in ipairs({ "header", "headerSuffix" }) do
        local fs = Keyed(box, key)
        if fs then
            s.headers[fs] = true
            if type(fs.GetTextColor) == "function" then
                local r, g, b, a = fs:GetTextColor()
                s.colors[fs] = { r, g, b, a }
            end
        end
    end
    return s
end

-- Blizzard's border and focus textures go transparent; the FontStrings take Echo's font.
local function Restyle(box)
    FadeTextures()
    if saved.boxFont then
        Echo.TrackFont(box, tonumber(saved.boxFont[2]) or Input.FONT_SIZE, saved.boxFont[3] or "")
    end
    for fs, f in pairs(saved.fonts) do
        -- The header and its suffix read as the card's mode chip label: Echo's font at 10.
        local size = saved.headers[fs] and Input.HEADER_SIZE or tonumber(f[2]) or Input.FONT_SIZE
        Echo.TrackFont(fs, size, f[3] or "")
    end
end

local function Restore(box)
    box:ClearAllPoints()
    for _, p in ipairs(saved.points) do box:SetPoint(p[1], p[2], p[3], p[4], p[5]) end
    if saved.scale then box:SetScale(saved.scale) end
    if type(saved.strata) == "string" then box:SetFrameStrata(saved.strata) end
    if saved.boxFont then
        Echo.UntrackFont(box)
        if saved.boxFont[1] then box:SetFont(saved.boxFont[1], saved.boxFont[2], saved.boxFont[3]) end
    end
    for texture, alpha in pairs(saved.alphas) do texture:SetAlpha(alpha) end
    for fs, f in pairs(saved.fonts) do
        Echo.UntrackFont(fs)
        if f[1] then fs:SetFont(f[1], f[2], f[3]) end
    end
    for fs, c in pairs(saved.colors) do
        if type(c[1]) == "number" then fs:SetTextColor(c[1], c[2], c[3], c[4]) end
    end
    if lifted and type(saved.level) == "number" then box:SetFrameLevel(saved.level) end
    lifted = false
end

--- Dock the line, when echoDockInput is on; undock it when it is off. Safe to call again:
-- Echo.ApplyOptions calls it on every settings change.
function Input.Enable()
    if Echo.Setting("echoDockInput") == false then
        Input.Disable()
        return
    end
    local box = Box()
    if not box then return end
    Hook(box)
    if not active then
        saved = Record(box)
        Restyle(box)
        active = true
    end
    if Echo.Setting("echoInputAlwaysVisible") == true and not box:IsShown() then
        box:Show()
        box:SetAlpha(1)
        alwaysShown = true
    end
    Input.Reanchor()
    Input.PaintChip()
    PaintHint(box)
    RefreshCard()
end

--- Put the line back where Blizzard had it, as it was, and stop re-anchoring it.
function Input.Disable()
    -- Blizzard's chat hiding may have moved the box onto UIParent; that goes back too.
    if Echo.HideChat and Echo.HideChat.RestoreBoxParent then Echo.HideChat.RestoreBoxParent() end
    if not active then return end
    active = false
    local box = Box()
    if box and saved then Restore(box) end
    saved = nil
    -- A box only always-visible kept on screen goes, so Blizzard's own flow shows it next time.
    if box and alwaysShown and box:IsShown() and not box:HasFocus() then box:Hide() end
    alwaysShown = false
    followed = nil
    if background then background:Hide() end
    if chip then chip:Hide() end
    if hint then hint:Hide() end
    RefreshCard()
end

-- Test and debug handles.
function Input._background() return background end
function Input._chip() return chip end
function Input._hint() return hint end
