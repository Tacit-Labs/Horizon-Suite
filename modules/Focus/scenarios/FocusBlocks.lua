--[[
    Horizon Suite - Focus - Block arbitration

    Focus has two banner blocks that can sit above or below the quest list: the
    Mythic+ banner (FocusMplusBlock) and the dungeon run tracker (FocusRunBlock).
    They are mutually exclusive by design — a keystone run gets the keystone
    banner, every other party dungeon gets the run tracker — and the layout only
    ever needs to know about whichever one is currently up.

    That rule lives here, in one place, so FocusLayout and Core can ask for "the
    active block" instead of naming a specific one. Adding a third block means
    editing this file and nothing downstream.

    Every accessor resolves late (addon.* looked up at call time), so this file
    carries no load-order requirement against the blocks it arbitrates.
]]

local addon = _G.HorizonSuite

-- Refresh both blocks. The M+ block runs first: the run block consults its shown
-- state to decide whether to stand down, so a stale answer there would let both
-- draw for a frame.
function addon.UpdateFocusBlocks()
    if addon.UpdateMplusBlock then addon.UpdateMplusBlock() end
    if addon.UpdateDungeonRunBlock then addon.UpdateDungeonRunBlock() end
end

-- The block currently shown, or nil when neither is.
-- @return Frame|nil
function addon.GetActiveFocusBlock()
    local mplus = addon.mplusBlock
    if mplus and mplus:IsShown() then return mplus end
    local runBlock = addon.runBlock
    if runBlock and runBlock:IsShown() then return runBlock end
    return nil
end

-- Height of the active block, or 0 when neither is shown. Callers add their own
-- gap; this is the frame height alone.
-- @return number
function addon.GetActiveFocusBlockHeight()
    local mplus = addon.mplusBlock
    if mplus and mplus:IsShown() then
        return (addon.GetMplusBlockHeight and addon.GetMplusBlockHeight()) or mplus:GetHeight() or 0
    end
    local runBlock = addon.runBlock
    if runBlock and runBlock:IsShown() then
        return (addon.GetDungeonRunBlockHeight and addon.GetDungeonRunBlockHeight()) or runBlock:GetHeight() or 0
    end
    return 0
end

-- Which end of the panel the active block is anchored to. Each block keeps its
-- own position setting, so this reports the one that is actually up.
-- @return string  "top" or "bottom"
function addon.GetActiveFocusBlockPosition()
    local mplus = addon.mplusBlock
    if mplus and mplus:IsShown() then
        return addon.GetDB("mplusBlockPosition", "top") or "top"
    end
    local runBlock = addon.runBlock
    if runBlock and runBlock:IsShown() then
        return addon.GetDB("runBlockPosition", "top") or "top"
    end
    return "top"
end
