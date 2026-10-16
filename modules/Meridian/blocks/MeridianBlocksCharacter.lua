--[[
    Horizon Suite - Meridian - Gold, durability and bag blocks
    Blizzard: GetMoney, GetMoneyString, GetInventoryItemDurability, GetInventoryItemLink,
    C_Container.GetContainerNumFreeSlots, ToggleAllBags, ToggleCharacter.
]]

local addon = _G.HorizonSuite
if not addon then return end
local Meridian = addon.Meridian
if not Meridian or not Meridian.RegisterBlock then return end

local F = Meridian.Format
local L = addon.L

local WARN = { 0.95, 0.70, 0.30 }
local BAD = { 0.90, 0.30, 0.30 }

-- Gold ---------------------------------------------------------------------------

local sessionStart

Meridian.RegisterBlock({
    id = "gold",
    label = L["MERIDIAN_BLOCK_GOLD"],
    icon = Meridian.Glyph("coins"),
    iconColor = { 0.90, 0.76, 0.35 },
    text = function()
        if not GetMoney then return nil end
        local money = GetMoney()
        if sessionStart == nil then sessionStart = money end
        return F.Gold(money)
    end,
    events = { "PLAYER_MONEY", "PLAYER_ENTERING_WORLD" },
    OnClick = function() if ToggleAllBags then ToggleAllBags() end end,
    OnTooltipShow = function(tooltip)
        if not GetMoney then return end
        local money = GetMoney()
        if GetMoneyString then tooltip:AddLine(GetMoneyString(money, true), 1, 1, 1) end
        tooltip:AddDoubleLine(L["MERIDIAN_GOLD_SESSION"], F.GoldDelta(money - (sessionStart or money)), 0.7, 0.7, 0.7, 1, 1, 1)
    end,
    defaultSide = "right", defaultOrder = 30, defaultOn = true,
})

-- Durability ---------------------------------------------------------------------

-- Head, shoulder, chest, waist, legs, feet, wrist, hands, main hand, off hand, ranged.
local SLOTS = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }

local function ReadSlots()
    local out = {}
    for i = 1, #SLOTS do
        local cur, max
        if GetInventoryItemDurability then cur, max = GetInventoryItemDurability(SLOTS[i]) end
        out[#out + 1] = { cur, max, SLOTS[i] }
    end
    return out
end

local function Lowest() return F.LowestDurability(ReadSlots()) end

Meridian.RegisterBlock({
    id = "durability",
    label = L["MERIDIAN_BLOCK_DURABILITY"],
    icon = Meridian.Glyph("shield"),
    iconColor = function()
        local low = Lowest()
        if low and low <= 25 then return BAD end
        if low and low <= 50 then return WARN end
        return nil
    end,
    text = function()
        local low = Lowest()
        return low and F.Percent(low) or nil
    end,
    events = { "UPDATE_INVENTORY_DURABILITY", "PLAYER_ENTERING_WORLD" },
    OnClick = function()
        if addon:IsModuleEnabled("essence") and addon.Essence and addon.Essence.Toggle then
            addon.Essence.Toggle()
        elseif ToggleCharacter then
            ToggleCharacter("PaperDollFrame")
        end
    end,
    OnTooltipShow = function(tooltip)
        local any = false
        for _, s in ipairs(ReadSlots()) do
            local cur, max, slot = s[1], s[2], s[3]
            if type(cur) == "number" and type(max) == "number" and max > 0 and cur < max then
                any = true
                local link = GetInventoryItemLink and GetInventoryItemLink("player", slot)
                tooltip:AddDoubleLine(link or tostring(slot), F.Percent(cur / max * 100), 1, 1, 1, 1, 1, 1)
            end
        end
        if not any then tooltip:AddLine(L["MERIDIAN_DURABILITY_ALL_GOOD"], 0.7, 0.7, 0.7) end
    end,
    defaultSide = "right", defaultOrder = 40, defaultOn = true,
})

-- Bags -------------------------------------------------------------------------

local function FreeSlots()
    local total = 0
    local C = C_Container
    for bag = 0, (NUM_BAG_SLOTS or 4) do
        local free, bagType
        if C and C.GetContainerNumFreeSlots then
            free, bagType = C.GetContainerNumFreeSlots(bag)
        elseif GetContainerNumFreeSlots then
            free, bagType = GetContainerNumFreeSlots(bag)
        end
        -- Only general bags: a profession bag's space doesn't hold just anything.
        if free and (bagType == nil or bagType == 0) then total = total + free end
    end
    return total
end

Meridian.RegisterBlock({
    id = "bags",
    label = L["MERIDIAN_BLOCK_BAGS"],
    icon = Meridian.Glyph("bag"),
    iconColor = function()
        local n = FreeSlots()
        if n == 0 then return BAD end
        if n <= 5 then return WARN end
        return nil
    end,
    text = function() return tostring(FreeSlots()) end,
    events = { "BAG_UPDATE_DELAYED", "PLAYER_ENTERING_WORLD" },
    OnClick = function() if ToggleAllBags then ToggleAllBags() end end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(string.format(L["MERIDIAN_BAGS_FREE_FMT"], FreeSlots()), 0.7, 0.7, 0.7)
    end,
    defaultSide = "right", defaultOrder = 50, defaultOn = true,
})
