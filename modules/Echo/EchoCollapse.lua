--[[
    Horizon Suite - Echo - Collapse
    Collapse mode (echoCollapse): the column of tiles folds into the Echo icon and slides up
    on hover. "all" folds every tile; "keepnew" keeps tiles with a badge out,
    packed down from the bottom slot. While tiles are folded the icon wears their badge.
    One clock on the column (its OnUpdate, installed by Layout only while collapse is on)
    runs the open and close delays and the slide, so the harness can drive it with elapsed
    values. Echo's frames are non-secure, so this behaves the same in combat.
    Blizzard: none. Echo: Tiles (layout, badges), Card and Stack (which hold a fold off).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Collapse = {}
Echo.Collapse = Collapse

Collapse.OPEN_DELAY = 0.15   -- hover on the icon this long before the column opens
Collapse.CLOSE_DELAY = 0.6   -- away from the column this long before it folds
Collapse.STAGGER = 0.03      -- each tile starts this long after the one below it
Collapse.SLIDE = 0.18        -- one tile's slide from the icon to its slot

Collapse.expanded = false    -- open, or opening
Collapse.progress = 0        -- 0 folded .. 1 fully out

local VALID = { all = true, keepnew = true }

local mode           -- the mode last laid out; nil before the first layout
local t = 0          -- the slide's clock, 0 .. Total()
local dir = 0        -- +1 opening, -1 folding, 0 at rest
local openWait       -- seconds on the icon so far, or nil when no open is pending
local away = 0       -- seconds the mouse has been away from an open column
local items = {}     -- the last layout's frames, bottom-up (EchoTiles Refresh)
local fullHeight, foldedHeight
local folded = {}    -- frame -> true for the tiles that fold away

--- The collapse setting: "off", "all" or "keepnew".
-- @return string
function Collapse.Mode()
    local m = Echo.Setting("echoCollapse")
    if VALID[m] then return m end
    return "off"
end

local function Active()
    return mode ~= nil and mode ~= "off"
end

local function Clamp(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

-- Ease-out cubic: quick off the icon, settling into the slot.
local function EaseOut(p)
    local q = 1 - p
    return 1 - q * q * q
end

-- The whole slide: the last tile's start plus one slide.
local function Total()
    local n = math.max(1, #items)
    return (n - 1) * Collapse.STAGGER + Collapse.SLIDE
end

-- How far out the i-th frame from the bottom is at the clock's time, eased, 0..1.
local function Out(i)
    return EaseOut(Clamp((t - (i - 1) * Collapse.STAGGER) / Collapse.SLIDE))
end

-- Nothing folds while the card or the stack is up (the mouse over either is covered by
-- that too) or while the column is being dragged.
local function Blocked()
    local column = Echo.Tiles.Column()
    if column and column.moving then return true end
    if Echo.Card and Echo.Card.IsShown() then return true end
    local stack = _G.HorizonSuiteEchoStack
    if stack and stack:IsShown() then return true end
    return false
end

-- The column frame's own rect: the icon and the tiles. Layout shrinks it to the
-- icon and any kept tiles while folded.
local function MouseOver()
    local column = Echo.Tiles.Column()
    return column ~= nil and column:IsMouseOver() == true
end

-- The folded tiles' badge on the icon: a dot when any has one, else their counts summed.
-- A folded +N tile brings the badge of the conversations hidden behind it (item.hidden).
local function PaintIconBadge(show)
    local icon = Echo.Tiles.StackButton()
    if not icon or not icon.dot then return end
    local badge, sum = nil, 0
    if show then
        for _, item in ipairs(items) do
            local spec = item.spec or item.hidden
            if folded[item.frame] and spec then
                if spec.badge == "dot" then
                    badge = "dot"
                elseif spec.badge == "count" then
                    sum = sum + (tonumber(spec.count) or 0)
                end
            end
        end
        if badge ~= "dot" and sum > 0 then badge = "count" end
    end
    Echo.Tiles.PaintBadge(icon, badge, sum)
end

-- Put every frame where the clock says: a folded tile slides from the icon (offset 0) to
-- its slot and fades in; a kept tile moves from its packed slot to its place in the full
-- column. At 0 the folded frames hide.
local function Place()
    local column = Echo.Tiles.Column()
    if not column then return end
    for i, item in ipairs(items) do
        local e = Out(i)
        local f = item.frame
        f:ClearAllPoints()
        f:SetPoint("BOTTOM", column, "BOTTOM", 0, item.from + (item.y - item.from) * e)
        if folded[f] then
            f:SetAlpha(e)
            -- Hidden until it leaves the icon, so an invisible tile never takes the icon's mouse.
            f:SetShown(e > 0)
        else
            f:SetAlpha(1)
        end
    end
    local total = Total()
    Collapse.progress = Clamp(t / total)
    local out = t > 0 or Collapse.expanded
    column:SetHeight(out and fullHeight or foldedHeight)
    PaintIconBadge(not out)
end

--- Open the column now (the hover delay has passed, or a fold is turned back).
function Collapse.Expand()
    if not Active() then return end
    Collapse.expanded = true
    dir = 1
    openWait = nil
    away = 0
    Place()
end

--- Start folding the column into the icon, top tile first.
function Collapse.Fold()
    if not Active() then return end
    Collapse.expanded = false
    dir = -1
    away = 0
    Place()
end

--- The mouse entered the icon or a tile. It cancels a pending fold; on the icon of a
-- folded column it starts the open delay, and on any of them it turns a fold under way back.
-- @param frame Frame
function Collapse.Enter(frame)
    if not Active() then return end
    away = 0
    if Collapse.expanded then return end
    if dir == -1 then
        Collapse.Expand()
    elseif frame ~= nil and frame == Echo.Tiles.StackButton() then
        openWait = openWait or 0
    end
end

--- The mouse left the icon or a tile. Leaving the icon cancels a pending open; the
-- fold itself waits on the column's clock, which sees the mouse leave the whole column.
-- @param frame Frame
function Collapse.Leave(frame)
    if not Active() then return end
    if frame ~= nil and frame == Echo.Tiles.StackButton() then openWait = nil end
end

--- Drop a pending open: a drag has started on the icon, and a drag never unfolds the column.
function Collapse.CancelOpen()
    openWait = nil
end

--- The column's OnUpdate: the open delay, the close delay and the slide.
-- @param _ Frame
-- @param elapsed number
function Collapse.OnUpdate(_, elapsed)
    if not Active() then return end
    elapsed = tonumber(elapsed) or 0
    -- A slide starts from where it is on the tick that starts it; the next tick moves it.
    local started = false
    local column = Echo.Tiles.Column()
    if column and column.moving then openWait = nil end
    if openWait then
        openWait = openWait + elapsed
        if openWait >= Collapse.OPEN_DELAY then
            Collapse.Expand()
            started = true
        end
    end
    if Collapse.expanded and not started then
        -- Held at zero while the card or stack is up, so the close delay starts from zero
        -- when it hides with the mouse outside.
        if Blocked() or MouseOver() then
            away = 0
        else
            away = away + elapsed
            if away >= Collapse.CLOSE_DELAY then
                Collapse.Fold()
                started = true
            end
        end
    end
    if dir ~= 0 and not started then
        local total = Total()
        t = t + dir * elapsed
        if t >= total then
            t, dir = total, 0
        elseif t <= 0 then
            t, dir = 0, 0
        end
        Place()
    end
end

--- Lay the column out (EchoTiles Refresh). Off, it puts back anything collapse changed and
-- returns false so the column lays itself out as usual. A new mode (the first layout, or
-- the setting changed live) takes effect at once, without animating.
-- @param list table  { { frame, y, spec? } } bottom-up
-- @param full number  the open column's height
-- @return boolean handled
function Collapse.Layout(list, full)
    local m = Collapse.Mode()
    if m ~= mode then
        mode = m
        t, dir, openWait, away = 0, 0, nil, 0
        Collapse.expanded = false
    end
    items = list
    folded = {}
    -- The clock runs only while collapsing: off, the column has no OnUpdate at all.
    local column = Echo.Tiles.Column()
    if column then column:SetScript("OnUpdate", m ~= "off" and Collapse.OnUpdate or nil) end
    if m == "off" then
        for _, item in ipairs(list) do item.frame:SetAlpha(1) end
        PaintIconBadge(false)
        Collapse.progress = 1
        return false
    end
    local SlotY = Echo.Tiles.SlotY
    local kept = 0
    for _, item in ipairs(list) do
        local spec = item.spec
        if m == "keepnew" and spec and spec.badge ~= nil then
            kept = kept + 1
            item.from = SlotY(kept)
        else
            folded[item.frame] = true
            item.from = 0
        end
    end
    fullHeight = full
    foldedHeight = kept > 0 and (SlotY(kept + 1) - Echo.Tiles.GAP) or Echo.Tiles.TILE_SIZE
    -- A refresh at rest keeps the clock at its end, however many tiles there are now.
    if dir == 0 then t = Collapse.expanded and Total() or 0 end
    if t > Total() then t = Total() end
    Place()
    return true
end

--- Whether a tile is folded into the icon now (not out, or not yet visible on its way out).
-- @param frame Frame
-- @return boolean
function Collapse.IsFolded(frame)
    if not Active() or not folded[frame] then return false end
    return not Collapse.expanded or not frame:IsShown()
end
