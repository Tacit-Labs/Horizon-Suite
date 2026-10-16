--[[
    Horizon Suite - Meridian - Registry
    The block registry the bar draws from. Data only: no frames. Loads straight after the
    core files, before any module, so every module's files can register blocks.
    Gates (owning module on, platform capability present) are evaluated on every call,
    because modules enable in no fixed order (HorizonSuite.lua EnableModule).
]]

local addon = _G.HorizonSuite
if not addon then return end

addon.Meridian = addon.Meridian or {}
local Meridian = addon.Meridian

Meridian.SIDES = { "left", "centre", "right" }
local SIDE_SET = { left = true, centre = true, right = true }

-- Pale gold #E8D9B5.
Meridian.BRAND = { 232 / 255, 217 / 255, 181 / 255 }

-- Shown in place of a block whose text function errors.
Meridian.FAILED_TEXT = "\226\128\147"  -- en dash, as UTF-8 bytes

-- Set true by the bar while it is built and showing blocks.
Meridian._active = false

local blocks, order, warned = {}, {}, {}

local function DB(key, default)
    if addon.GetDB then return addon.GetDB(key, default) end
    return default
end

--- A Meridian setting, defaulting from MERIDIAN_DEFAULTS (read lazily: the defaults file
--- loads with the options, after this file).
-- @param key string
-- @return any
function Meridian.Setting(key)
    local D = addon.MERIDIAN_DEFAULTS
    return DB(key, D and D[key])
end

--- @param id string
--- @param field string "enabled" | "side" | "order"
--- @return string
function Meridian.Key(id, field)
    return "meridianBlock_" .. id .. "_" .. field
end

--- Add a block. The first registration of an id wins.
-- @param def table  see Docs/Engineering/2026-10-16-meridian-bar-plan.md, Task 1
-- @return boolean registered
function Meridian.RegisterBlock(def)
    if type(def) ~= "table" or type(def.id) ~= "string" or def.id == "" then return false end
    if type(def.text) ~= "function" then return false end
    if blocks[def.id] then return false end
    if not SIDE_SET[def.defaultSide] then def.defaultSide = "right" end
    def.defaultOrder = tonumber(def.defaultOrder) or 100
    if def.defaultOn == nil then def.defaultOn = true end
    blocks[def.id] = def
    order[#order + 1] = def.id
    if Meridian.OnBlocksChanged then Meridian.OnBlocksChanged() end
    return true
end

function Meridian.Get(id)
    return blocks[id]
end

--- Every registered block, in registration order.
function Meridian.All()
    local out = {}
    for i = 1, #order do out[i] = blocks[order[i]] end
    return out
end

function Meridian.IsBlockOn(id)
    local def = blocks[id]
    if not def then return false end
    return DB(Meridian.Key(id, "enabled"), def.defaultOn) and true or false
end

function Meridian.BlockSide(id)
    local def = blocks[id]
    if not def then return "right" end
    local v = DB(Meridian.Key(id, "side"), def.defaultSide)
    if SIDE_SET[v] then return v end
    return def.defaultSide
end

function Meridian.BlockOrder(id)
    local def = blocks[id]
    if not def then return 100 end
    return tonumber(DB(Meridian.Key(id, "order"), def.defaultOrder)) or def.defaultOrder
end

--- Whether a block's owning module is on and its platform capability is present.
function Meridian.IsAvailable(id)
    local def = blocks[id]
    if not def then return false end
    if def.module and not (addon.IsModuleEnabled and addon:IsModuleEnabled(def.module)) then return false end
    if def.requires and not (addon.Platform and addon.Platform.Has and addon.Platform.Has(def.requires)) then
        return false
    end
    return true
end

--- Whether Meridian is drawing this block, so another module should hide its own copy.
function Meridian.Owns(id)
    return Meridian._active == true and blocks[id] ~= nil
        and Meridian.IsBlockOn(id) and Meridian.IsAvailable(id)
end

--- The blocks to draw on one side: on, available, sorted by order then id.
-- @param side string
-- @return table def[]
function Meridian.Layout(side)
    local out = {}
    for i = 1, #order do
        local id = order[i]
        if Meridian.IsBlockOn(id) and Meridian.IsAvailable(id) and Meridian.BlockSide(id) == side then
            out[#out + 1] = blocks[id]
        end
    end
    table.sort(out, function(a, b)
        local oa, ob = Meridian.BlockOrder(a.id), Meridian.BlockOrder(b.id)
        if oa ~= ob then return oa < ob end
        return a.id < b.id
    end)
    return out
end

--- A block's text through pcall. nil means "nothing to show" (a contextual block).
-- @param def table
-- @return string|nil
function Meridian.SafeText(def)
    local ok, v = pcall(def.text)
    if not ok then
        if not warned[def.id] then
            warned[def.id] = true
            if addon.Log and addon.Log.warn then addon.Log.warn("meridian", def.id .. ": " .. tostring(v)) end
        end
        return Meridian.FAILED_TEXT
    end
    if v == nil then return nil end
    return tostring(v)
end

--- Accent colour: the class colour when Axis class tint is on for Meridian, else the brand.
function Meridian.Accent()
    local cc = addon.GetModuleClassColor and addon.GetModuleClassColor("meridian")
    if cc then return cc[1], cc[2], cc[3] end
    local b = Meridian.BRAND
    return b[1], b[2], b[3]
end

--- The font every block uses: the global override, else the base font, else the game's.
function Meridian.FontPath()
    local global = addon.GetActiveGlobalFont and addon.GetActiveGlobalFont()
    if global then return global end
    local base = DB("fontPath", nil)
    if type(base) == "string" and base ~= "" then
        return (addon.ResolveFontPath and addon.ResolveFontPath(base)) or base
    end
    return (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF"
end

--- Path of a block glyph rendered from tools/icons/meridian/<name>.svg.
function Meridian.Glyph(name)
    return "Interface\\AddOns\\" .. (addon.ADDON_NAME or "HorizonSuite") .. "\\media\\meridian\\" .. name .. ".tga"
end

function Meridian._ResetForTests()
    blocks, order, warned = {}, {}, {}
    Meridian._active = false
end
