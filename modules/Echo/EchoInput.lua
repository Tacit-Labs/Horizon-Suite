--[[
    Horizon Suite - Echo - Input
    Blizzard's own input line, ChatFrame1EditBox, docked under Echo and restyled to match.
    Enter, /, R and Blizzard's Whisper keep working because the box is still the game's:
    Echo only moves it, lifts it to the column's strata, re-fonts it and its FontStrings,
    fades its border textures, and draws a rounded background behind it, and puts every one
    of those back when docking goes off. A SetPoint from anyone else while docked is undone.
    Under an open card it sits flush with the card's bottom edge at the card's width; with
    no card it sits beside the Echo icon at the column's foot, on the side panels open to.
    The card hides its own reply box while the shown line sends to the card's conversation.
    Blizzard's chat code is only observed: hooksecurefunc post-hooks on the activate,
    deactivate and header functions and on the box's SetPoint, and HookScript post-hooks on
    its OnShow and OnHide. Echo never calls them, never focuses the box and never
    sets its attributes (Task 1's probe in EchoSlash.lua is the one exception).
    Blizzard: ChatFrame1EditBox (GetPoint, GetNumPoints, GetScale, GetRegions, GetAttribute,
    GetFrameLevel, GetFrameStrata, GetFont, ClearAllPoints, SetPoint, SetScale,
    SetFrameStrata, SetFont, HookScript; Show, SetShown and SetAlpha from the activate and
    deactivate post-hooks and at enable; Hide at disable), hooksecurefunc,
    ChatFrameUtil.ActivateChat / DeactivateChat / UpdateHeader or the ChatEdit_ equivalents,
    ChatTypeInfo, GetChannelName (through Send.ChannelKeyForSlot).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Input = {}
Echo.Input = Input

Input.GAP = 4         -- between the card's bottom edge and the line
Input.FONT_SIZE = 12  -- for a FontString whose own size can't be read

local active = false  -- docked now
local saved           -- what enable changed on the box: points, scale, texture alphas, fonts
local background      -- Echo's rounded panel behind the box
local hooked = false  -- the post-hooks are installed once and stay
local anchoring = false  -- Echo's own SetPoint calls on the box are running; its hook lets them by
local alwaysShown = false  -- always-visible put the box on screen, not Blizzard's own activate

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

--- The conversation Blizzard's input line sends to now, or nil. Battle.net is Task 3's.
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
    if chatType == "CHANNEL" then
        local slot = Attribute(box, "channelTarget")
        if slot == nil then return nil end
        return Echo.Send.ChannelKeyForSlot(slot)
    end
    return nil
end

--- Whether the docked line, shown now, sends to this conversation: the card then hides
-- its own reply box.
-- @param convKey string|nil
-- @return boolean
function Input.Covers(convKey)
    if not active or convKey == nil then return false end
    local box = Box()
    if not box or not box:IsShown() then return false end
    return Input.TargetKey() == convKey
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

--- Colour the background's border with the line's chat colour.
function Input.PaintBorder()
    if not active or not background then return end
    local r, g, b = LineColor(Box())
    Echo.Round.SetBorderColor(background, r, g, b, 1)
end

-- Blizzard's border and focus textures go transparent; activate and the header can bring
-- them back, so both hooks fade them again.
local function FadeTextures()
    if not saved then return end
    for texture in pairs(saved.alphas) do texture:SetAlpha(0) end
end

local function SyncBackground(box)
    if background then background:SetShown(active and box:IsShown()) end
end

local function Background(box)
    if not background then
        local column = _G.HorizonSuiteEchoColumn
        local parent = (column and column:GetParent()) or UIParent
        background = CreateFrame("Frame", nil, parent)
        Echo.Round.Apply(background, { radius = Echo.Round.SMALL, border = true })
        local p = Echo.View.PANEL_BG
        Echo.Round.SetColor(background, p[1], p[2], p[3], p[4])
    end
    background:ClearAllPoints()
    background:SetPoint("TOPLEFT", box, "TOPLEFT", 0, 0)
    background:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0)
    local strata = box:GetFrameStrata()
    if type(strata) == "string" then background:SetFrameStrata(strata) end
    local level = box:GetFrameLevel()
    background:SetFrameLevel(math.max(0, (tonumber(level) or 1) - 1))
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

--- Put the line under the open card, or beside the Echo icon at the column's foot.
-- ChatFrame1EditBox isn't protected, so this is allowed in combat too.
function Input.Reanchor()
    if not active then return end
    local box, column = Box(), _G.HorizonSuiteEchoColumn
    if not box or not column then return end
    anchoring = true
    box:ClearAllPoints()
    box:SetScale(ColumnScale(box, column))
    local strata = column:GetFrameStrata()
    if type(strata) == "string" then box:SetFrameStrata(strata) end
    local card = _G.HorizonSuiteEchoCard
    if card and Echo.Card.IsShown() then
        box:SetPoint("TOPLEFT", card, "BOTTOMLEFT", 0, -Input.GAP)
        box:SetPoint("TOPRIGHT", card, "BOTTOMRIGHT", 0, -Input.GAP)
    else
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
    anchoring = false
    local bg = Background(box)
    if type(bg.SetScale) == "function" then bg:SetScale(column:GetScale() or 1) end
    SyncBackground(box)
end

local function OnActivate(editBox)
    if not active or editBox ~= Box() then return end
    -- Blizzard's own chat-frame layout can re-anchor the box; take it back as typing starts.
    Input.Reanchor()
    FadeTextures()
    alwaysShown = false  -- Blizzard's own flow has it now
    editBox:Show()
    SyncBackground(editBox)
    RefreshCard()
end

local function OnDeactivate(editBox)
    if not active or editBox ~= Box() then return end
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
    Input.PaintBorder()
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
    end
end

-- Note the box's points, scale, texture alphas and fonts, so disable can put them back.
local function Record(box)
    local s = { points = {}, alphas = {}, fonts = {} }
    for i = 1, box:GetNumPoints() or 0 do
        local point, rel, relPoint, x, y = box:GetPoint(i)
        s.points[i] = { point, rel, relPoint, x, y }
    end
    s.scale = box:GetScale()
    s.strata = box:GetFrameStrata()
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
    return s
end

-- Blizzard's border and focus textures go transparent; the FontStrings take Echo's font.
local function Restyle(box)
    FadeTextures()
    if saved.boxFont then
        Echo.TrackFont(box, tonumber(saved.boxFont[2]) or Input.FONT_SIZE, saved.boxFont[3] or "")
    end
    for fs, f in pairs(saved.fonts) do
        Echo.TrackFont(fs, tonumber(f[2]) or Input.FONT_SIZE, f[3] or "")
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
    Input.PaintBorder()
    RefreshCard()
end

--- Put the line back where Blizzard had it, as it was, and stop re-anchoring it.
function Input.Disable()
    if not active then return end
    active = false
    local box = Box()
    if box and saved then Restore(box) end
    saved = nil
    -- A box only always-visible kept on screen goes, so Blizzard's own flow shows it next time.
    if box and alwaysShown and box:IsShown() and not box:HasFocus() then box:Hide() end
    alwaysShown = false
    if background then background:Hide() end
    RefreshCard()
end

-- Test and debug handle.
function Input._background() return background end
