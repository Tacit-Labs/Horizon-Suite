--[[
    Horizon Suite - Augment / Loot Roll - Demo
    Fabricated rolls for solo testing.

    A real Need/Greed roll needs a group, group loot set, and a qualifying drop.
    That is no basis for iterating on layout, and it is no basis for checking
    whether this works on a client nobody has tested it on yet. The demo builds
    the same descriptor table AugmentRollEvents.BuildRoll builds and hands it to
    the same renderer, so a demo row and a live row differ in exactly two ways:
    the buttons are inert, and the timer runs off the local clock.

    Item IDs below are deliberately ordinary, low-level and long-standing, so
    they resolve on a vanilla-world client as readily as on retail. Anything
    expansion-specific would render as a question mark on Forever and make the
    demo useless exactly where it is most needed.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment or not addon.Augment.Roll then return end

local R = addon.Augment.Roll
R.Demo = R.Demo or {}
local Demo = R.Demo

-- Fabricated roll IDs sit far above anything the server issues, so a demo row
-- can never collide with a live roll or be addressed by RollOnLoot. The button
-- handler refuses demo rows outright as well; this is the second lock.
local DEMO_ROLL_BASE = 900000

local FALLBACK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- itemID, quality, and which buttons the fabricated roll offers.
local SAMPLES = {
    {   itemID = 19019, quality = 5, count = 1,            -- Thunderfury
        canNeed = true, canGreed = true, bindOnPickUp = true,
        tally = { need = 2, greed = 1, pass = 1, leader = "Sarah", leaderRoll = 91 } },
    {   itemID = 18832, quality = 4, count = 1,            -- Brutality Blade
        canNeed = true, canGreed = true, bindOnPickUp = true,
        tally = { need = 1, greed = 2, pass = 0, leader = "Mikhail", leaderRoll = 64 } },
    {   itemID = 12064, quality = 3, count = 1,            -- Serpentine Sash
        canNeed = false, canGreed = true, canTransmog = true,
        reasonNeed = 1 },
    {   itemID = 3577,  quality = 2, count = 4,            -- Gold Bar
        canNeed = false, canGreed = true, reasonNeed = 5,
        tally = { allPassed = true } },
}

-- Build the summary shape AugmentRollTally.Summarise produces, so the demo
-- exercises the real formatter rather than a parallel one that could drift.
local function BuildDemoTally(spec)
    if not spec then return nil end
    if spec.allPassed then
        return { counts = {}, total = 0, rolled = 0, allPassed = true }
    end
    return {
        counts = {
            need = spec.need or 0, needOff = 0, transmog = 0,
            greed = spec.greed or 0, pass = spec.pass or 0, waiting = 0,
        },
        total      = (spec.need or 0) + (spec.greed or 0) + (spec.pass or 0),
        rolled     = (spec.need or 0) + (spec.greed or 0) + (spec.pass or 0),
        isTied     = false,
        allPassed  = false,
        leaderName = spec.leader,
        leaderRoll = spec.leaderRoll,
    }
end

--- Build one fabricated roll descriptor.
--- @param index number  Index into SAMPLES
--- @return table
local function BuildDemoRoll(index)
    local sample = SAMPLES[index]
    local name, link, texture

    if C_Item and C_Item.GetItemInfo then
        local ok, itemName, itemLink, _, _, _, _, _, _, _, itemTexture =
            pcall(C_Item.GetItemInfo, sample.itemID)
        if ok then
            name, link, texture = itemName, itemLink, itemTexture
        end
    end

    -- An uncached item returns nils on first ask. Fall back to something
    -- legible rather than a blank row, and let the retry below fill it in.
    if not name then
        name = (addon.L and addon.L["LOOT_ROLL_DEMO_ITEM"]) or "Demo Item"
    end

    return {
        rollID        = DEMO_ROLL_BASE + index,
        -- A real roll's length: Blizzard's own timer bar is sized for 60s
        -- (GroupLootFrame.xml, Timer maxValue). At 12s the demo vanished
        -- before there was time to hover everything on it.
        rollTime      = 60000,
        texture       = texture or FALLBACK_ICON,
        name          = name,
        itemLink      = link,
        count         = sample.count or 1,
        quality       = sample.quality,
        bindOnPickUp  = sample.bindOnPickUp and true or false,
        canNeed       = sample.canNeed and true or false,
        canGreed      = sample.canGreed and true or false,
        canDisenchant = sample.canDisenchant and true or false,
        canTransmog   = sample.canTransmog and true or false,
        reasonNeed    = (not sample.canNeed) and sample.reasonNeed
                        and _G["LOOT_ROLL_INELIGIBLE_REASON" .. sample.reasonNeed] or nil,
        demo          = true,
        demoTally     = BuildDemoTally(sample.tally),
    }
end

--- Show the demo reel: one fabricated roll per style of row.
--- Respects the visible cap, so what you see is what a real burst would look
--- like with your current settings.
--- @param count number|nil  How many rows (default: fill the visible cap)
--- @return nil
function Demo.Run(count)
    if not addon.IsModuleEnabled or not addon:IsModuleEnabled("augment") then
        if addon.HSPrint then
            addon.HSPrint((addon.L and addon.L["LOOT_ROLL_DEMO_AUGMENT_OFF"])
                or "Augment is disabled — enable it first.")
        end
        return
    end

    R.InitFrames()
    R.RestoreSavedPosition()

    local wanted = math.min(tonumber(count) or R.GetMaxVisible(), #SAMPLES)

    local function show()
        for i = 1, wanted do
            R.ShowRoll(BuildDemoRoll(i))
        end
    end

    -- Draw immediately so the frames appear the instant the command is run,
    -- then redraw as each item finishes loading.
    show()

    -- C_Item.GetItemInfo returns nils until the client has the item cached, and
    -- on a fresh login that is the normal case — the first run of this demo
    -- rendered a placeholder question mark reading "Demo Item". A fixed delay
    -- is a guess at how long the server takes; ContinueOnItemLoad fires when
    -- the item is actually there, so the row fills in whenever that happens.
    local Item = _G.Item
    if Item and Item.CreateFromItemID then
        for i = 1, wanted do
            -- CreateFromItemID is a colon method: Item has to be passed as self.
            -- Called with a dot, the itemID lands in self, the real argument is
            -- nil, every item comes back empty and nothing ever redraws.
            local ok, item = pcall(Item.CreateFromItemID, Item, SAMPLES[i].itemID)
            if ok and item and not item:IsItemEmpty() then
                pcall(function() item:ContinueOnItemLoad(show) end)
            end
        end
        return
    end

    -- No ItemMixin on this client: fall back to asking, then redrawing twice.
    for i = 1, wanted do
        if C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, SAMPLES[i].itemID)
        end
    end
    C_Timer.After(0.5, show)
    C_Timer.After(2.0, show)
end

--- Clear every demo row.
--- @return nil
function Demo.Clear()
    for i = 1, #SAMPLES do
        R.ReleaseRoll(DEMO_ROLL_BASE + i)
    end
end
