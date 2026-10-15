--[[
    Horizon Suite - Augment / Alerts - Recipe learned
    Replaces Blizzard's "New Recipe Learned" toast. Blizzard's AlertFrame
    registers NEW_RECIPE_LEARNED and calls NewRecipeLearnedAlertSystem:AddAlert
    from its OnEvent, so while this kind is on the event is unregistered from
    AlertFrame (the same approach AugmentBlizzard.lua takes for loot toasts)
    and re-registered when the kind, or Alerts, is turned off.

    A trainer's "Train all" fires one event per recipe within a few frames.
    Events are collected for a short quiet window and shown as one toast:
    the recipe itself when only one arrived, "N Recipes Learned" otherwise.
]]

local addon = _G.HorizonSuite
local L = addon.L
local Y = addon and addon.Augment
local A = Y and Y.Alerts
if not A then return end

local M = {}
A.Recipe = M

local EVENT = "NEW_RECIPE_LEARNED"

-- Seconds of quiet after the last event before the batch is shown. Each new
-- event restarts the wait, so a long "Train all" still lands as one toast.
M.COALESCE_WINDOW = 0.75

-- True only while this file removed the event from AlertFrame, so restore never
-- registers an event Blizzard had not registered itself.
local removedFromAlertFrame = false

local pending = {}
local flushTimer

-- ============================================================================
-- BLIZZARD TOAST
-- ============================================================================

function M.SuppressBlizzardToast()
    if removedFromAlertFrame then return end
    local af = _G.AlertFrame
    if not (af and af.IsEventRegistered and af.UnregisterEvent) then return end
    local ok, isReg = pcall(af.IsEventRegistered, af, EVENT)
    if ok and isReg then
        pcall(af.UnregisterEvent, af, EVENT)
        removedFromAlertFrame = true
    end
end

function M.RestoreBlizzardToast()
    if not removedFromAlertFrame then return end
    removedFromAlertFrame = false
    local af = _G.AlertFrame
    if af and af.RegisterEvent then
        pcall(af.RegisterEvent, af, EVENT)
    end
end

-- ============================================================================
-- RECIPE LOOKUP
-- ============================================================================

-- @param recipeID number
-- @return number|nil  texture of the recipe's profession (parent line first, as Blizzard's toast does)
local function ProfessionTexture(recipeID)
    local TS = C_TradeSkillUI
    if not (TS and TS.GetTradeSkillLineForRecipe and TS.GetTradeSkillTexture) then return nil end
    local ok, tradeSkillID, _, parentTradeSkillID = pcall(TS.GetTradeSkillLineForRecipe, recipeID)
    if not ok or not tradeSkillID then return nil end
    local ok2, tex = pcall(TS.GetTradeSkillTexture, parentTradeSkillID or tradeSkillID)
    if ok2 then return tex end
    return nil
end

-- @param recipeID number
-- @param recipeLevel number|nil  set only for recipes that level up (ranks)
-- @return table|nil  { name, icon, professionIcon }, or nil when the recipe has no name
function M.Describe(recipeID, recipeLevel)
    if type(recipeID) ~= "number" then return nil end
    local name, icon

    if C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
        local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, recipeID, recipeLevel)
        if ok and type(info) == "table" then
            name, icon = info.name, info.icon
        end
    end
    if (not name or name == "") and C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, recipeID)
        if ok and type(info) == "table" then
            name = info.name
            icon = icon or info.iconID
        end
    end

    name = A.SafeString(name)
    if name == "" then return nil end

    local professionIcon = ProfessionTexture(recipeID)
    if tonumber(recipeLevel) and recipeLevel > 0 then
        name = string.format(L["ALERTS_RECIPE_RANK_FORMAT"], name, recipeLevel)
    end

    return {
        name = name,
        icon = icon or professionIcon,
        professionIcon = professionIcon or icon,
    }
end

-- ============================================================================
-- BATCHING
-- ============================================================================

-- Pure: turns a batch of described recipes into one toast.
-- @param batch table  array of M.Describe results
-- @return string|nil, string, table  title, body, meta (nil title for an empty batch)
function M.BuildToast(batch)
    local n = #batch
    if n == 0 then return nil end
    local first = batch[1]
    if n == 1 then
        return L["ALERTS_RECIPE_TITLE"], first.name, { icon = first.icon }
    end
    return string.format(L["ALERTS_RECIPE_MANY_TITLE"], n),
        string.format(L["ALERTS_RECIPE_MANY_BODY"], first.name, n - 1),
        { icon = first.professionIcon }
end

function M.Flush()
    if flushTimer then flushTimer:Cancel(); flushTimer = nil end
    local batch = pending
    pending = {}
    local title, body, meta = M.BuildToast(batch)
    if title then A.Enqueue("RECIPE", title, body, meta) end
end

-- Drops anything still waiting, e.g. when the kind is turned off mid-batch.
function M.Reset()
    if flushTimer then flushTimer:Cancel(); flushTimer = nil end
    pending = {}
end

-- @param recipeID number
-- @param recipeLevel number|nil
function M.HandleRecipeLearned(recipeID, recipeLevel)
    local D = addon.AUGMENT_DEFAULTS
    if not A.GetDB("alertsRecipeEnabled", D.alertsRecipeEnabled) then return end

    local entry = M.Describe(recipeID, recipeLevel)
    if not entry then return end
    pending[#pending + 1] = entry

    if flushTimer then flushTimer:Cancel() end
    if C_Timer and C_Timer.NewTimer then
        flushTimer = C_Timer.NewTimer(M.COALESCE_WINDOW, M.Flush)
    else
        M.Flush()
    end
end
