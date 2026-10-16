--[[
    Horizon Suite - Meridian - Bar
    The strip: one frame on the top or bottom screen edge, three sections (left, centre,
    right), a button per block, the Strip and Capsules styles, the shared ticker and event
    refresh, tooltips, clicks and the right-click menu. Data comes only from the registry.
    Blizzard: CreateFrame, UIParent, GameTooltip, GetCursorPosition, InCombatLockdown,
    MenuUtil.CreateContextMenu, C_Timer.After.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian then return end

local L = addon.L

local Bar = {}
Meridian.Bar = Bar

Bar.HEIGHT = 26
Bar.PAD = 10        -- inset of the left and right sections from the screen edge
Bar.GAP = 12        -- space between blocks
Bar.ICON = 14
Bar.ICON_GAP = 4
Bar.TICK = 0.25     -- shared ticker resolution, seconds
Bar.PILL_PAD = 8
Bar.PILL_H = 20
Bar.STRIP_BG = { 0.04, 0.05, 0.06, 0.78 }
Bar.TEXT = { 0.85, 0.86, 0.89 }
Bar.ICON_TINT = { 0.54, 0.56, 0.63 }

local frame, bg, accentLine, edgeLine, driver
local buttons = {}
local pills = {}
local state
local cfg = {}
local inp = {}
local tickAcc = 0
local sinceTick = {}
local layoutAfterCombat = false
local disablePending = false

Bar._buttons = buttons

local LAYOUT_EVENTS = { PLAYER_ENTERING_WORLD = true, DISPLAY_SIZE_CHANGED = true, UI_SCALE_CHANGED = true }

local function InCombat()
    return (InCombatLockdown and InCombatLockdown()) and true or false
end

local function ReadConfig()
    cfg.edge = Meridian.Setting("meridianEdge") == "bottom" and "bottom" or "top"
    cfg.capsules = Meridian.Setting("meridianStyle") == "capsules"
    cfg.autoHide = Meridian.Setting("meridianAutoHide") and true or false
    cfg.keepOutOfCombat = Meridian.Setting("meridianKeepShownOutOfCombat") and true or false
    cfg.combatMode = Meridian.Setting("meridianCombat") or "show"
    cfg.fadeAlpha = (tonumber(Meridian.Setting("meridianCombatFadeOpacity")) or 30) / 100
    cfg.fontSize = tonumber(Meridian.Setting("meridianFontSize")) or 12
end

--- Left edge x of each block, per side. Order reads left to right on every side.
-- @param widths table { left = {w...}, centre = {w...}, right = {w...} }
-- @return table { left = {x...}, centre = {x...}, right = {x...} }
function Bar.ComputeX(widths, barWidth, pad, gap)
    local out = { left = {}, centre = {}, right = {} }
    local function total(ws)
        local t = 0
        for i = 1, #ws do t = t + ws[i] end
        if #ws > 1 then t = t + gap * (#ws - 1) end
        return t
    end
    local function place(ws, startX, dest)
        local x = startX
        for i = 1, #ws do dest[i] = x; x = x + ws[i] + gap end
    end
    place(widths.left or {}, pad, out.left)
    local c = widths.centre or {}
    place(c, (barWidth - total(c)) / 2, out.centre)
    local r = widths.right or {}
    place(r, barWidth - pad - total(r), out.right)
    return out
end

local function IconColor(def)
    if def.iconAccent then return Meridian.Accent() end
    local c = def.iconColor
    if type(c) == "function" then
        local ok, v = pcall(c)
        c = ok and v or nil
    end
    c = c or Bar.ICON_TINT
    return c[1], c[2], c[3]
end

local function TooltipBelongsToBar()
    if not (GameTooltip and GameTooltip.IsShown and GameTooltip:IsShown()) then return false end
    local owner = GameTooltip.GetOwner and GameTooltip:GetOwner()
    for _ = 1, 3 do
        if not owner then return false end
        if owner == frame then return true end
        owner = owner.GetParent and owner:GetParent()
    end
    return false
end

-- ---------------------------------------------------------------------------
-- Tooltips, clicks, menu
-- ---------------------------------------------------------------------------

function Bar.OnBlockEnter(b)
    local def = Meridian.Get(b.id)
    if not def or not GameTooltip then return end
    GameTooltip:SetOwner(b, cfg.edge == "bottom" and "ANCHOR_TOP" or "ANCHOR_BOTTOM")
    GameTooltip:ClearLines()
    GameTooltip:SetText(def.label or def.id, 1, 1, 1, 1, false)
    if def.OnTooltipShow then pcall(def.OnTooltipShow, GameTooltip) end
    if def.combatLocked and InCombat() then
        GameTooltip:AddLine(L["MERIDIAN_NOT_IN_COMBAT"], 1, 0.35, 0.35)
    end
    GameTooltip:Show()
end

function Bar.OnBlockLeave()
    if GameTooltip then GameTooltip:Hide() end
end

function Bar.OpenMenu(b, def)
    if not (MenuUtil and type(MenuUtil.CreateContextMenu) == "function") then return end
    pcall(MenuUtil.CreateContextMenu, b, function(_, root)
        if def.OnMenu then
            pcall(def.OnMenu, root)
            root:CreateDivider()
        end
        root:CreateButton(L["MERIDIAN_MENU_HIDE_BLOCK"], function()
            local set = addon.OptionsData_SetDB or addon.SetDB
            if set then set(Meridian.Key(def.id, "enabled"), false) end
            Meridian.ApplyOptions()
        end)
        root:CreateButton(L["MERIDIAN_MENU_SETTINGS"], Meridian.OpenSettings)
    end)
end

function Bar.OnBlockClick(b, mouseButton)
    local def = Meridian.Get(b.id)
    if not def then return end
    if mouseButton == "RightButton" then Bar.OpenMenu(b, def) return end
    if def.combatLocked and InCombat() then return end
    if def.OnClick then pcall(def.OnClick, b) end
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function CreateBlockButton(id)
    local b = CreateFrame("Button", nil, frame)
    b:SetHeight(Bar.HEIGHT)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(Bar.ICON, Bar.ICON)
    b.text = b:CreateFontString(nil, "OVERLAY")
    b.text:SetFont(Meridian.FontPath(), cfg.fontSize or 12, "")
    b.text:SetShadowOffset(1, -1)
    b.text:SetShadowColor(0, 0, 0, 0.8)
    b.text:SetTextColor(Bar.TEXT[1], Bar.TEXT[2], Bar.TEXT[3])
    b.id = id
    b:SetScript("OnEnter", Bar.OnBlockEnter)
    b:SetScript("OnLeave", Bar.OnBlockLeave)
    b:SetScript("OnClick", Bar.OnBlockClick)
    b:Hide()
    buttons[id] = b
    return b
end

--- Re-read one block's text and icon.
-- @return boolean true when the block's width, or whether it shows, changed
function Bar.RefreshBlock(def)
    if not frame then return false end
    local b = buttons[def.id] or CreateBlockButton(def.id)
    local value = Meridian.SafeText(def)
    local icon = def.icon
    if type(icon) == "function" then
        local ok, v = pcall(icon)
        icon = ok and v or nil
    end

    b.icon:ClearAllPoints()
    b.text:ClearAllPoints()
    local w = 0
    if icon then
        b.icon:SetTexture(icon)
        b.icon:SetVertexColor(IconColor(def))
        b.icon:SetPoint("LEFT", b, "LEFT", 0, 0)
        b.icon:Show()
        w = Bar.ICON
    else
        b.icon:Hide()
    end
    if value and value ~= "" then
        b.text:SetText(value)
        if icon then
            b.text:SetPoint("LEFT", b.icon, "RIGHT", Bar.ICON_GAP, 0)
            w = w + Bar.ICON_GAP
        else
            b.text:SetPoint("LEFT", b, "LEFT", 0, 0)
        end
        b.text:Show()
        w = w + (tonumber(b.text:GetStringWidth()) or 0)
    else
        b.text:SetText("")
        b.text:Hide()
    end
    if def.width then w = math.max(w, def.width) end
    w = math.floor(w + 0.5)

    local changed = ((b.value == nil) ~= (value == nil)) or b._width ~= w
    b.value, b._width = value, w
    return changed
end

function Bar.LayoutPills(lists, xs, widths)
    local Round = addon.Echo and addon.Echo.Round
    for _, side in ipairs(Meridian.SIDES) do
        local pill = pills[side]
        local list = lists[side]
        if cfg.capsules and #list > 0 then
            if not pill then
                pill = CreateFrame("Frame", nil, frame)
                pill:SetFrameLevel(frame:GetFrameLevel())
                if Round then
                    Round.Apply(pill, { radius = Bar.PILL_H / 2, border = true })
                    Round.SetColor(pill, 1, 1, 1, 0.07)
                    Round.SetBorderColor(pill, 1, 1, 1, 0.12)
                else
                    local t = pill:CreateTexture(nil, "BACKGROUND")
                    t:SetAllPoints(pill)
                    t:SetColorTexture(1, 1, 1, 0.07)
                end
                pills[side] = pill
            end
            local first = xs[side][1]
            local last = xs[side][#list] + widths[side][#list]
            pill:ClearAllPoints()
            pill:SetPoint("LEFT", frame, "LEFT", first - Bar.PILL_PAD, 0)
            pill:SetSize(last - first + Bar.PILL_PAD * 2, Bar.PILL_H)
            if Round and Round.Layout then Round.Layout(pill) end
            pill:Show()
        elseif pill then
            pill:Hide()
        end
    end
end

function Bar.Layout()
    if not frame or not Meridian._active then return end
    local lists, widths, available = {}, {}, {}
    for _, side in ipairs(Meridian.SIDES) do
        local list, ws = {}, {}
        for _, def in ipairs(Meridian.Layout(side)) do
            available[def.id] = def
            Bar.RefreshBlock(def)
            local b = buttons[def.id]
            if b.value ~= nil then
                list[#list + 1] = b
                ws[#ws + 1] = b._width
            else
                b:Hide()
            end
        end
        lists[side], widths[side] = list, ws
    end

    local xs = Bar.ComputeX(widths, frame:GetWidth() or 0, Bar.PAD, Bar.GAP)
    for _, side in ipairs(Meridian.SIDES) do
        for i, b in ipairs(lists[side]) do
            -- Re-anchor only on a real move: Layout runs up to four times a second, and a frame
            -- touched in combat can trip a protected-action block if anything secure hangs off it.
            local x, w = xs[side][i], math.max(1, b._width)
            if b._x ~= x or b._laidWidth ~= w then
                b:ClearAllPoints()
                b:SetPoint("LEFT", frame, "LEFT", x, 0)
                b:SetWidth(w)
                b._x, b._laidWidth = x, w
            end
            b:Show()
        end
    end

    for id, b in pairs(buttons) do
        local def = Meridian.Get(id)
        if available[id] then
            if def.Attach then pcall(def.Attach, b) end
        else
            b:Hide()
            if def and def.Detach then pcall(def.Detach, b) end
        end
    end

    Bar.LayoutPills(lists, xs, widths)
end

--- Refresh one block now (hooks call this), relaying out when its size changed.
function Bar.RequestRefresh(id)
    local def = Meridian.Get(id)
    if not def or not frame or not Meridian._active then return end
    if Bar.RefreshBlock(def) then Bar.Layout() end
end

--- Run Layout again when combat ends (a block's Attach could not finish in combat).
function Bar.LayoutAfterCombat()
    layoutAfterCombat = true
    if driver then pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED") end
end

-- ---------------------------------------------------------------------------
-- Frame, edge, slide
-- ---------------------------------------------------------------------------

function Bar.Create()
    if frame then return frame end
    frame = CreateFrame("Frame", "HorizonSuiteMeridianBar", UIParent)
    frame:SetFrameStrata("HIGH")
    frame:SetHeight(Bar.HEIGHT)

    bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(Bar.STRIP_BG[1], Bar.STRIP_BG[2], Bar.STRIP_BG[3], Bar.STRIP_BG[4])

    accentLine = frame:CreateTexture(nil, "BORDER")
    accentLine:SetHeight(1)

    edgeLine = CreateFrame("Frame", "HorizonSuiteMeridianEdge", UIParent)
    edgeLine:SetFrameStrata("HIGH")
    edgeLine:SetHeight(2)
    edgeLine.tex = edgeLine:CreateTexture(nil, "ARTWORK")
    edgeLine.tex:SetAllPoints(edgeLine)
    edgeLine:Hide()

    -- Layout reads the bar's width, which settles only after scale and display changes land.
    frame:SetScript("OnSizeChanged", function() if Meridian._active then Bar.Layout() end end)

    driver = CreateFrame("Frame")
    Bar._driver = driver
    driver:SetScript("OnEvent", function(_, event, ...) Bar.OnEvent(event, ...) end)
    return frame
end

function Bar.ApplyEdge()
    if not frame then return end
    local hidden = 1 - ((state and state.progress) or 1)
    local offset = hidden * (Bar.HEIGHT + 2)
    frame:ClearAllPoints()
    accentLine:ClearAllPoints()
    edgeLine:ClearAllPoints()
    if cfg.edge == "bottom" then
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, -offset)
        frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, -offset)
        accentLine:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        accentLine:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        edgeLine:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        edgeLine:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    else
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, offset)
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, offset)
        accentLine:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        accentLine:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        edgeLine:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
        edgeLine:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    end
end

local function FillInputs()
    local hovering = false
    if GetCursorPosition and UIParent then
        local _, y = GetCursorPosition()
        local s = (UIParent.GetEffectiveScale and UIParent:GetEffectiveScale()) or 1
        if y and s and s > 0 then
            hovering = Meridian.AutoHide.CursorInZone(cfg.edge, y / s, UIParent:GetHeight() or 0,
                Meridian.AutoHide.EDGE_ZONE)
        end
    end
    if not hovering and frame:IsShown() and frame:IsMouseOver() then hovering = true end
    if not hovering and TooltipBelongsToBar() then hovering = true end
    local inCombat = InCombat() or ((UnitAffectingCombat and UnitAffectingCombat("player")) and true or false)
    inp.autoHide = cfg.autoHide
    inp.keepOutOfCombat = cfg.keepOutOfCombat
    inp.combatMode = cfg.combatMode
    inp.fadeAlpha = cfg.fadeAlpha
    inp.inCombat = inCombat
    inp.hovering = hovering
end

local function OnUpdate(_, elapsed)
    FillInputs()
    local before = state.progress
    local progress, alpha = Meridian.AutoHide.Step(state, elapsed, inp)
    if progress ~= before then Bar.ApplyEdge() end
    frame:SetAlpha(alpha)
    local out = progress > 0
    if out ~= frame:IsShown() then frame:SetShown(out) end
    local showLine = inp.autoHide and progress < 1 and not (inp.inCombat and inp.combatMode == "hide")
    edgeLine:SetShown(showLine)
    if showLine then edgeLine:SetAlpha(1 - progress) end

    tickAcc = tickAcc + elapsed
    if tickAcc < Bar.TICK then return end
    local dt = tickAcc
    tickAcc = 0
    if not out then return end

    local changed = false
    for _, def in ipairs(Meridian.All()) do
        if def.tick and Meridian.IsBlockOn(def.id) and Meridian.IsAvailable(def.id) then
            local t = (sinceTick[def.id] or def.tick) + dt  -- a block's first tick refreshes at once
            if t >= def.tick then
                t = 0
                if Bar.RefreshBlock(def) then changed = true end
            end
            sinceTick[def.id] = t
        end
    end
    if changed then Bar.Layout() end
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

function Bar.RegisterEvents()
    if not driver then return end
    driver:UnregisterAllEvents()
    local seen = {}
    local function reg(ev)
        if seen[ev] then return end
        seen[ev] = true
        pcall(driver.RegisterEvent, driver, ev)  -- an event one client lacks errors at registration
    end
    for ev in pairs(LAYOUT_EVENTS) do reg(ev) end
    reg("PLAYER_REGEN_ENABLED")
    for _, def in ipairs(Meridian.All()) do
        if def.events then
            for _, ev in ipairs(def.events) do reg(ev) end
        end
    end
end

local function DetachAll()
    for id, b in pairs(buttons) do
        local def = Meridian.Get(id)
        if def and def.Detach then pcall(def.Detach, b) end
        b:Hide()
    end
end

function Bar.OnEvent(event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        if disablePending then
            disablePending = false
            DetachAll()
            driver:UnregisterAllEvents()
            -- Disable's own notification was deferred by combat and nothing else will fire it now.
            Meridian._ownershipPending = false
            Meridian.NotifyOwnershipChanged()
            return
        end
        if Meridian._ownershipPending then
            Meridian._ownershipPending = false
            Meridian.NotifyOwnershipChanged()
        end
        if layoutAfterCombat then
            layoutAfterCombat = false
            Bar.Layout()
        end
        return
    end
    if LAYOUT_EVENTS[event] then Bar.Layout() return end

    local changed = false
    for _, def in ipairs(Meridian.All()) do
        if def.events and Meridian.IsBlockOn(def.id) and Meridian.IsAvailable(def.id) then
            for _, ev in ipairs(def.events) do
                if ev == event then
                    if def.OnEvent then pcall(def.OnEvent, event, ...) end
                    if Bar.RefreshBlock(def) then changed = true end
                    break
                end
            end
        end
    end
    if changed then Bar.Layout() end
end

-- ---------------------------------------------------------------------------
-- Options, enable, disable
-- ---------------------------------------------------------------------------

function Bar.ApplyOptions()
    if not frame then return end
    ReadConfig()
    local scale = (addon.GetModuleScale and addon.GetModuleScale("meridian")) or 1
    frame:SetScale(scale)
    edgeLine:SetScale(scale)
    local r, g, b = Meridian.Accent()
    accentLine:SetColorTexture(r, g, b, 1)
    edgeLine.tex:SetColorTexture(r, g, b, 0.55)
    bg:SetShown(not cfg.capsules)
    accentLine:SetShown(not cfg.capsules)
    local font = Meridian.FontPath()
    for _, btn in pairs(buttons) do btn.text:SetFont(font, cfg.fontSize, "") end
    if state and not cfg.autoHide then state.progress = 1 end
    Bar.ApplyEdge()
    Bar.Layout()
end

function Bar.Enable()
    Bar.Create()
    ReadConfig()
    disablePending = false
    state = Meridian.AutoHide.New(not cfg.autoHide)
    Meridian._active = true
    Bar.RegisterEvents()
    Bar.ApplyOptions()
    frame:Show()
    driver:SetScript("OnUpdate", OnUpdate)
    -- Other modules may still be enabling; lay out again on the next frame.
    C_Timer.After(0, function() if Meridian._active then Bar.Layout() end end)
    Meridian.NotifyOwnershipChanged()
end

function Bar.Disable()
    Meridian._active = false
    if driver then driver:SetScript("OnUpdate", nil) end
    if InCombat() then
        -- Detaching hands Blizzard's queue button back, which waits for combat to end.
        disablePending = true
        if driver then
            driver:UnregisterAllEvents()
            pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED")
        end
    else
        DetachAll()
        if driver then driver:UnregisterAllEvents() end
    end
    for _, btn in pairs(buttons) do btn:Hide() end
    if frame then frame:Hide() end
    if edgeLine then edgeLine:Hide() end
    Meridian.NotifyOwnershipChanged()
end

-- A block registered after the bar is up (a module's own file) gets its events and a slot.
Meridian.OnBlocksChanged = function()
    if Meridian._active then
        Bar.RegisterEvents()
        Bar.Layout()
    end
end

--- Re-apply after any Meridian setting changes (OptionsData routes here).
function Meridian.ApplyOptions()
    if not Meridian._active then return end
    Bar.ApplyOptions()
    Meridian.NotifyOwnershipChanged()
end

--- Tell Vista which readouts Meridian now draws, so it hides or restores its own.
function Meridian.NotifyOwnershipChanged()
    local V = addon.Vista
    if not V then return end
    if InCombat() then
        Meridian._ownershipPending = true
        if driver then pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED") end
        return
    end
    C_Timer.After(0, function()
        if V.ApplyOptions then V.ApplyOptions("vistaShowTimeText") end
        if V.UpdateMailIndicator then V.UpdateMailIndicator() end
        if V.RefreshMailAnchor then V.RefreshMailAnchor() end
        if V.RefreshQueueProxies then V.RefreshQueueProxies() end
    end)
end

--- Open the dashboard on Meridian's page.
function Meridian.OpenSettings()
    local dash = _G.HorizonSuiteDashboard
    local shown = dash and type(dash.IsShown) == "function" and dash:IsShown()
    if not shown then
        local show = addon.ShowOptions or _G.HorizonSuite_ShowOptions
        if type(show) ~= "function" then return end
        pcall(show)
        dash = _G.HorizonSuiteDashboard
    end
    if dash and type(dash.OpenModule) == "function" then
        pcall(dash.OpenModule, L["NAME_ADDON_INFOBAR"], "meridian")
    end
end
