--[[
    Horizon Suite - Augment - Events
    Event registration and dispatch for loot, money, currency, reputation.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment
local y = addon.Augment.state

local eventFrame
local eventsRegistered = false

-- ============================================================================
-- COALESCING QUEUE
-- Loot events arriving in the same tick are staggered so the pool stack
-- animation doesn't receive them all at position 0 simultaneously.
-- ============================================================================

local augmentPanel = addon.Log.createPanel("augment", "Augment Debug", { maxLines = 300,
    onClose = function()
        if addon.SetDB then addon.SetDB("augmentDebugLive", false) end
        addon.Log.enableTag("augment", nil)
    end,
})
addon.Log.registerTag("augment", "augmentDebugLive")

local COALESCE_STAGGER = 0.08
local lootQueue        = {}
local lootFlushPending = false

local function FlushLootQueue()
    lootFlushPending = false
    local queue = lootQueue
    lootQueue = {}
    addon.Log.debug("augment", "FlushLootQueue — " .. #queue .. " item(s)")
    for i, data in ipairs(queue) do
        if i == 1 then
            Y.ShowToast(data)
        else
            C_Timer.After((i - 1) * COALESCE_STAGGER, function()
                Y.ShowToast(data)
            end)
        end
    end
end

local function EnqueueLootToast(data)
    lootQueue[#lootQueue + 1] = data
    addon.Log.debug("augment", "Enqueue — type=" .. tostring(data and data.type) .. " q=" .. #lootQueue)
    if not lootFlushPending then
        lootFlushPending = true
        C_Timer.After(0, FlushLootQueue)
    end
end

local function ClearQueues()
    lootQueue        = {}
    lootFlushPending = false
end

-- ============================================================================
-- EVENT HANDLERS
-- ============================================================================

local handlers = {}

handlers.ADDON_LOADED = function(msg)
    -- Re-suppress after lazy Blizzard frames load in.
    if (msg == "Blizzard_AlertFrames" or msg == "Blizzard_LootFrame" or msg == "Blizzard_ContainerOpeningUI")
        and addon:IsModuleEnabled("augment") and Y.ApplyBlizzardSuppression
    then
        Y.ApplyBlizzardSuppression()
    end
    -- The loot window skin watches for Blizzard_LootFrame itself
    -- (AugmentLootWindowSkin.lua), since it can run with these events off.
end

local function OnPlayerReady()
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then Y.InitPatterns() end
    if addon:IsModuleEnabled("augment") and Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
end
handlers.PLAYER_LOGIN          = OnPlayerReady
handlers.PLAYER_ENTERING_WORLD = OnPlayerReady


handlers.CHAT_MSG_LOOT = function(msg, ...)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowItems", true) == false then return end
    local rawGuid = select(11, ...)
    -- CHAT_MSG_LOOT's 11th arg is a secret string in tainted execution.
    -- tostring() does NOT strip the secret flag, so == / ~= still throw.
    -- Wrap every comparison in pcall to extract plain booleans:
    --   guidKnownMatch    = comparison succeeded and GUIDs are equal
    --   guidKnownMismatch = comparison succeeded and GUIDs differ → skip
    --   both false        = comparison threw (secret string) → fall back to IsSelfLoot
    local guid = nil
    if rawGuid then
        pcall(function()
            if rawGuid ~= "" then guid = rawGuid end
        end)
    end
    local guidKnownMatch    = false
    local guidKnownMismatch = false
    if guid and y.playerGUID then
        pcall(function()
            if guid == y.playerGUID then
                guidKnownMatch = true
            else
                guidKnownMismatch = true
            end
        end)
    end
    if guidKnownMismatch then return end
    if not guidKnownMatch then
        if not Y.IsSelfLoot(msg) then return end
    end
    if Y.IsPushedLoot(msg) and addon.GetDB("augmentShowPushedItems", addon.AUGMENT_DEFAULTS.augmentShowPushedItems) == false then return end
    addon.Log.debug("augment", "LOOT guid=" .. tostring(rawGuid) .. " match=" .. tostring(guidKnownMatch) .. " " .. tostring(msg):sub(1, 80))
    local data = Y.ParseItemLoot(msg)
    if data then
        local minQ = (addon.GetDB and tonumber(addon.GetDB("augmentMinQuality", 0))) or 0
        if (data.quality or 1) >= minQ then
            EnqueueLootToast(data)
        else
            addon.Log.debug("augment", "LOOT filtered — quality=" .. tostring(data.quality) .. " < minQ=" .. minQ)
        end
    end
end

handlers.CHAT_MSG_MONEY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowMoney", true) == false then return end
    local data = Y.ParseMoney(msg)
    if data then
        addon.Log.debug("augment", "MONEY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_CURRENCY = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowCurrency", true) == false then return end
    local data = Y.ParseCurrency(msg)
    if data then
        addon.Log.debug("augment", "CURRENCY — " .. tostring(msg):sub(1, 60))
        EnqueueLootToast(data)
    end
end

handlers.CHAT_MSG_COMBAT_FACTION_CHANGE = function(msg)
    if not y.patternsOK then return end
    if addon.GetDB("augmentShowRep", true) == false then return end
    local data = Y.ParseReputation(msg)
    if data then
        addon.Log.debug("augment", "REP — " .. tostring(msg):sub(1, 60))
        Y.ShowToast(data)
    end
end

-- Rolling kill ticker: fires KillDynamicItemRevealPopup every 0.2s for 5s.
-- Covers animated chests (slow reveal), instant event rewards, and anything
-- in between. Any new loot/reward event resets and extends the window.
local killTicker = nil
local KILL_INTERVAL = 0.2
local KILL_DURATION = 5.0

local function StartKillTicker()
    if not Y.KillDynamicItemRevealPopup then return end
    if killTicker then killTicker:Cancel(); killTicker = nil end
    Y.KillDynamicItemRevealPopup()  -- immediate pass before first tick
    -- Deferred pass: catches frames Blizzard creates in the same event cycle as us,
    -- after all same-tick handlers have finished.
    C_Timer.After(0, function() if Y.KillDynamicItemRevealPopup then Y.KillDynamicItemRevealPopup() end end)
    local elapsed = 0
    killTicker = C_Timer.NewTicker(KILL_INTERVAL, function()
        elapsed = elapsed + KILL_INTERVAL
        Y.KillDynamicItemRevealPopup()
        if elapsed >= KILL_DURATION then
            if killTicker then killTicker:Cancel() end
            killTicker = nil
        end
    end)
end

local function OnBlizzardLootToast() StartKillTicker() end
handlers.SHOW_LOOT_TOAST                  = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_UPGRADE          = OnBlizzardLootToast
handlers.SHOW_LOOT_TOAST_LEGENDARY_LOOTED = OnBlizzardLootToast
handlers.LOOT_ITEM_ROLL_WON               = OnBlizzardLootToast
handlers.BONUS_LOOT_ITEM_RECEIVED         = OnBlizzardLootToast
-- Scenario/quest completions can reward items via popups that bypass SHOW_LOOT_TOAST.
handlers.SCENARIO_COMPLETED               = OnBlizzardLootToast
handlers.QUEST_TURNED_IN                  = OnBlizzardLootToast

-- Auto-loot opens Blizzard's loot window, empties it and closes it within a
-- fraction of a second, which reads as a second toast beside Augment's own.
-- The window animates in, out and per row, so hiding it by alpha still let it
-- flash. Instead, stop it opening: LOOT_READY says whether the coming loot is
-- auto-loot before LOOT_OPENED reaches the window, so take LOOT_OPENED off the
-- window for auto-loot and leave Blizzard to open it normally otherwise.
--
-- Auto-loot can leave items behind (full bags, a unique item already owned).
-- Only those items warrant the window, and they must show at once: a hidden
-- window made players loot the corpse again and again, and each retry
-- restarted the wait. The game reports each item it could not take as a UI
-- error, so open the window on that error if anything is still unlooted. As a
-- fallback for a refusal that raises no error, open it after
-- AUTOLOOT_REVEAL_DELAY if items remain.
local AUTOLOOT_REVEAL_DELAY = 0.5
local lootOpen        = false
local lootHeld        = false
local autoLootToken   = 0
local heldFromItem    = nil

local function SetLootWindowOpens(opens)
    local frame = _G.LootFrame
    if not frame then return end
    if opens then
        if not frame:IsEventRegistered("LOOT_OPENED") then frame:RegisterEvent("LOOT_OPENED") end
    else
        frame:UnregisterEvent("LOOT_OPENED")
    end
end

local function LootLeftOver()
    for slot = 1, (GetNumLootItems() or 0) do
        if LootSlotHasItem(slot) then return true end
    end
    return false
end

-- Under Blizzard's gamepad UI, opening the window from addon code taints its
-- gamepad navigation (#468), so RevealHeldLoot must never run there. Holding
-- the window back is still safe: it only takes an event off the window. So in
-- gamepad mode, hold it back only when the loot should fit in the bags, and
-- otherwise let Blizzard open it and run its own full-bags refocus.
local function GamepadUI()
    return addon.Platform and addon.Platform.IsGamepadUI() or false
end

-- Set when held loot left items behind in gamepad mode, so the next loot
-- opens Blizzard's window rather than holding it back again.
local showNextLoot = false

local function LootFitsInBags()
    local need = 0
    for slot = 1, (GetNumLootItems() or 0) do
        if LootSlotHasItem(slot) and GetLootSlotType(slot) == Enum.LootSlotType.Item then
            need = need + 1
        end
    end
    if need == 0 then return true end
    local free = 0
    for bag = 0, NUM_BAG_SLOTS do
        local n, family = C_Container.GetContainerNumFreeSlots(bag)
        -- Only general bags: a profession bag takes only its own kind of item.
        if family == 0 then free = free + (n or 0) end
    end
    return free >= need
end

-- Open the held-back window if auto-loot left anything behind.
local function RevealHeldLoot()
    if not (lootOpen and lootHeld) or not LootLeftOver() then return end
    if GamepadUI() then
        -- Refused despite the bag check (a unique item already owned, say).
        -- Close the loot so the next try opens Blizzard's window.
        lootHeld = false
        showNextLoot = true
        CloseLoot()
        return
    end
    local frame = _G.LootFrame
    local onEvent = frame and frame:GetScript("OnEvent")
    if not onEvent then return end
    lootHeld = false
    autoLootToken = autoLootToken + 1
    SetLootWindowOpens(true)
    -- Opened as a manual loot, so the rows stay put rather than sliding out.
    onEvent(frame, "LOOT_OPENED", false, heldFromItem)
end

-- Faster auto-loot (augmentFastLoot). Blizzard's auto-loot works through the
-- slots one at a time; taking every slot here, on LOOT_READY, empties the
-- corpse at once. Locked slots (a group roll under way,
-- or another player looting) stay with Blizzard, and so does the bind-on-pickup
-- prompt a slot may raise (LOOT_BIND_CONFIRM). Whatever cannot be taken is left
-- for the reveal above.
--
-- Should LOOT_READY fire again before LOOT_OPENED, the loot is still taken
-- once: nothing more until LOOT_CLOSED, or for FAST_LOOT_GUARD seconds should
-- LOOT_CLOSED never arrive.
--
-- Items that will not fit in the bags are left rather than tried: a refusal's
-- UI error can arrive before LOOT_OPENED, when nothing is held yet to reveal,
-- which left the window waiting on AUTOLOOT_REVEAL_DELAY. Anything left here
-- reveals the window as soon as it opens. The check only skips an item it is
-- sure cannot fit; when it cannot tell (item info not cached, an API missing
-- on this client) it takes the item and the refusal path above still applies.
local FAST_LOOT_GUARD = 1.0
local fastLootAt = nil
local fastLootLeft = false

local function ItemAPI(name)
    return (C_Item and C_Item[name]) or _G[name]
end

-- Free slots by kind: general bags, profession bags (by family) and the
-- reagent bag, which sits after the NUM_BAG_SLOTS bags.
local function ReadBagSpace()
    if not (C_Container and C_Container.GetContainerNumFreeSlots) then return nil end
    local space = { general = 0, families = {}, reagent = 0 }
    for bag = 0, NUM_BAG_SLOTS + (NUM_REAGENTBAG_SLOTS or 0) do
        local n, family = C_Container.GetContainerNumFreeSlots(bag)
        n = n or 0
        if bag > NUM_BAG_SLOTS then
            space.reagent = space.reagent + n
        elseif not family or family == 0 then
            space.general = space.general + n
        elseif n > 0 then
            space.families[#space.families + 1] = { family = family, free = n }
        end
    end
    return space
end

-- True if the item fits, spending the bag slot it would take so the next
-- item counts what is left.
local function TakeBagSpace(space, link, quantity)
    local getInfo = ItemAPI("GetItemInfo")
    if not space or not link or not getInfo then return true end
    local info = { getInfo(link) }
    local stackSize = info[8]
    if not stackSize then return true end  -- not cached yet
    local getCount = ItemAPI("GetItemCount")
    if stackSize > 1 and getCount then
        local part = (getCount(link) or 0) % stackSize
        if part > 0 and stackSize - part >= (quantity or 1) then return true end
    end
    -- A profession item goes to its own bag first.
    local getFamily = ItemAPI("GetItemFamily")
    local itemFamily = getFamily and getFamily(link)
    if itemFamily and itemFamily > 0 and bit and bit.band then
        for _, b in ipairs(space.families) do
            if b.free > 0 and bit.band(itemFamily, b.family) > 0 then
                b.free = b.free - 1
                return true
            end
        end
    end
    if space.general > 0 then
        space.general = space.general - 1
        return true
    end
    if space.reagent > 0 and info[17] then  -- isCraftingReagent
        space.reagent = space.reagent - 1
        return true
    end
    return false
end

local function FastLoot()
    if addon.GetDB("augmentFastLoot", addon.AUGMENT_DEFAULTS.augmentFastLoot) ~= true then return end
    if type(LootSlot) ~= "function" or type(GetLootSlotInfo) ~= "function" then return end
    local now = GetTime()
    if fastLootAt and now - fastLootAt < FAST_LOOT_GUARD then return end
    fastLootAt = now
    fastLootLeft = false
    local space = ReadBagSpace()
    for slot = (GetNumLootItems() or 0), 1, -1 do
        if LootSlotHasItem(slot) then
            local _, _, quantity, _, _, locked = GetLootSlotInfo(slot)
            -- Money and currency need no bag space.
            local isItem = type(GetLootSlotType) == "function" and Enum and Enum.LootSlotType
                and GetLootSlotType(slot) == Enum.LootSlotType.Item
            local link = isItem and type(GetLootSlotLink) == "function" and GetLootSlotLink(slot)
            if not locked and (not isItem or TakeBagSpace(space, link, quantity)) then
                LootSlot(slot)
            else
                fastLootLeft = true
            end
        end
    end
end

handlers.LOOT_READY = function(autoLoot)
    -- The second LOOT_READY of a loot arrives after LOOT_OPENED; ignore it.
    if lootOpen then return end
    local hold = autoLoot
    if hold and GamepadUI() then
        hold = not showNextLoot and LootFitsInBags()
        showNextLoot = false
    end
    SetLootWindowOpens(not hold)
    -- After the bag check above, which counts the slots still to take.
    if autoLoot then FastLoot() end
end

handlers.LOOT_OPENED = function(autoLoot, acquiredFromItem)
    lootOpen = true
    local frame = _G.LootFrame
    lootHeld = autoLoot and frame and not frame:IsEventRegistered("LOOT_OPENED") or false
    if not lootHeld then return end
    heldFromItem = acquiredFromItem
    autoLootToken = autoLootToken + 1
    local token = autoLootToken
    C_Timer.After(AUTOLOOT_REVEAL_DELAY, function()
        if token == autoLootToken then RevealHeldLoot() end
    end)
    -- Fast loot already knows what it left behind, so show it now.
    if fastLootLeft then RevealHeldLoot() end
end

-- "Inventory is full", "You can't carry any more of those" and the like.
-- Wait a frame so slots the game did take have cleared before checking.
handlers.UI_ERROR_MESSAGE = function()
    if lootHeld then C_Timer.After(0, RevealHeldLoot) end
end

handlers.LOOT_CLOSED = function()
    lootOpen = false
    lootHeld = false
    heldFromItem = nil
    fastLootAt = nil
    fastLootLeft = false
    SetLootWindowOpens(true)
end

local function OnEvent(_, event, msg, ...)
    local handler = handlers[event]
    if handler then handler(msg, ...) end
end

-- ============================================================================
-- ENABLE / DISABLE
-- ============================================================================

function Y.EnableEvents()
    if eventsRegistered then return end
    if not eventFrame then
        eventFrame = CreateFrame("Frame")
        eventFrame:SetScript("OnEvent", OnEvent)
    end
    y.playerGUID = UnitGUID("player")
    if not y.patternsOK and Y.InitPatterns then
        Y.InitPatterns()
    end
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")
    eventFrame:RegisterEvent("CHAT_MSG_MONEY")
    eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
    eventFrame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_UPGRADE")
    pcall(eventFrame.RegisterEvent, eventFrame, "SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
    pcall(eventFrame.RegisterEvent, eventFrame, "LOOT_ITEM_ROLL_WON")
    pcall(eventFrame.RegisterEvent, eventFrame, "BONUS_LOOT_ITEM_RECEIVED")
    pcall(eventFrame.RegisterEvent, eventFrame, "SCENARIO_COMPLETED")
    pcall(eventFrame.RegisterEvent, eventFrame, "QUEST_TURNED_IN")
    eventFrame:RegisterEvent("LOOT_READY")
    eventFrame:RegisterEvent("LOOT_OPENED")
    eventFrame:RegisterEvent("LOOT_CLOSED")
    eventFrame:RegisterEvent("UI_ERROR_MESSAGE")
    eventsRegistered = true
end

function Y.DisableEvents()
    if not eventsRegistered then return end
    if eventFrame then
        eventFrame:UnregisterAllEvents()
    end
    ClearQueues()
    -- Toasts are off: let Blizzard open the loot window again.
    lootOpen = false
    lootHeld = false
    fastLootAt = nil
    fastLootLeft = false
    SetLootWindowOpens(true)
    eventsRegistered = false
end

--- Bring loot toasts and the loot window skin in line with the Loot Frame
--- master switch and its two parts. Either part can run without the other.
--- Callers check the augment module is on: during OnEnable it is not yet
--- marked enabled, so this cannot ask IsModuleEnabled itself.
--- @return nil
function Y.ApplyLootFrameState()
    local GetDB = addon.GetDB
    local function on(key) return not GetDB or GetDB(key, true) ~= false end
    local masterOn = on("augmentLootFrameEnabled")
    if masterOn and on("augmentLootToastsEnabled") then
        Y.EnableEvents()
        if Y.ApplyBlizzardSuppression then Y.ApplyBlizzardSuppression() end
    else
        Y.DisableEvents()
        if Y.RestoreBlizzard then Y.RestoreBlizzard() end
        if Y.ClearActiveToasts then Y.ClearActiveToasts() end
    end
    if masterOn and on("augmentLootWindowSkinEnabled") then
        if Y.EnableLootWindowSkin then Y.EnableLootWindowSkin() end
    else
        if Y.DisableLootWindowSkin then Y.DisableLootWindowSkin() end
    end
end

function Y.SetDebugLive(v)
    if addon.SetDB then addon.SetDB("augmentDebugLive", v) end
    addon.Log.enableTag("augment", v or nil)
    if v then
        augmentPanel.Show()
        addon.Log.debug("augment", "Live debug enabled")
    else
        augmentPanel.Hide()
    end
end
