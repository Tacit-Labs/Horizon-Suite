--[[
    Horizon Suite - Echo - Redraw
    Collects "this view needs repainting" marks and repaints each view once on the next
    frame, so a burst of lines (a group-loot roll, a busy channel) costs one repaint.
    Views register a repaint function under a name; Store listeners call Mark.
    Blizzard: CreateFrame (a hidden frame whose OnUpdate runs once, then hides).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Echo = addon.Echo or {}
local Echo = addon.Echo

local Redraw = {}
Echo.Redraw = Redraw

-- Test harness only: repaint inside Mark, as the views did before this file.
Redraw.sync = false

local ORDER = { "tiles", "stack", "card", "cardRow" }
local handlers, dirty = {}, {}
local ticker

--- Set the repaint function for a view name.
-- @param name string
-- @param fn function
function Redraw.Register(name, fn)
    if type(fn) == "function" then handlers[name] = fn end
end

--- Repaint every marked view, once each, in ORDER. A handler that errors is reported and
-- skipped, so one broken view does not stop the others repainting this flush.
function Redraw.Flush()
    local now = dirty
    dirty = {}
    if ticker then ticker:Hide() end
    if now.card then now.cardRow = nil end
    for _, name in ipairs(ORDER) do
        if now[name] and handlers[name] then
            local ok, err = pcall(handlers[name])
            if not ok then
                local handler = geterrorhandler and geterrorhandler()
                if handler then handler(err) end
            end
        end
    end
end

--- Mark a view for repainting on the next frame.
-- @param name string
function Redraw.Mark(name)
    if Redraw.sync then
        local fn = handlers[name]
        if fn then fn() end
        return
    end
    dirty[name] = true
    if not ticker then
        ticker = CreateFrame("Frame")
        ticker:Hide()
        ticker:SetScript("OnUpdate", function() Redraw.Flush() end)
    end
    ticker:Show()
end

--- @param name string
-- @return boolean
function Redraw.Pending(name)
    return dirty[name] == true
end

--- Drop every pending mark (module disabled).
function Redraw.Clear()
    dirty = {}
    if ticker then ticker:Hide() end
end
