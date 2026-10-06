-- Horizon Suite — Migration 20261006
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: Unreleased (2026-10-06) — dashboard settings review, items A6 and A7.
--
-- 1. Talking Head: talkingHeadEnabled and talkingHeadCustomise lost their rows in v5.1.0
--    but are still read, so a profile saved with either off kept the Talking Head hidden
--    (or Blizzard's frame) with no setting to undo it. Clearing them lets the sidebar
--    switch (augmentTalkingHeadEnabled) decide alone, as the page has since 5.1.0.
--
-- 2. Insight: old keys still win over the visible settings whenever the newer key is
--    unset, so a slider could show one size while tooltips used another. Each old value is
--    copied into its replacement when the replacement is unset, then the old key is cleared.
--    insightHeaderSize and insightBodySize stay: tooltips with no per-type key (spells and
--    other plain tooltips) still size from them. Copies use the runtime's floors (8 for
--    header and body, 6 for the tagged lines). The runtime fallbacks stay for imported old
--    profiles.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

-- Old Insight size key -> the per-tooltip keys that replaced it, the runtime's floor for the
-- value, and whether the old key is cleared afterwards.
local SIZE_KEYS = {
    insightHeaderSize   = { news = { "insightPlayerHeaderSize", "insightNpcHeaderSize", "insightItemHeaderSize" }, floor = 8, keep = true },
    insightBodySize     = { news = { "insightPlayerBodySize", "insightNpcBodySize", "insightItemBodySize" }, floor = 8, keep = true },
    insightBadgesSize   = { news = { "insightPlayerBadgesSize" }, floor = 6 },
    insightStatsSize    = { news = { "insightPlayerStatsSize" }, floor = 6 },
    insightMountSize    = { news = { "insightPlayerMountSize" }, floor = 6 },
    insightTransmogSize = { news = { "insightItemTransmogSize" }, floor = 6 },
}

-- Old show/hide toggle -> the Hide / Show / Modifier dropdown that replaced it.
local MODE_KEYS = {
    insightShowMythicScore = "insightMythicScoreMode",
    insightShowIlvl        = "insightItemLevelMode",
    insightShowHonorLevel  = "insightHonorLevelMode",
}

addon.RegisterMigration({
    id = "20261006",

    run = function(db)
        db.profiles = db.profiles or {}
        for _, prof in pairs(db.profiles) do
            if type(prof) == "table" then
                prof.talkingHeadEnabled = nil
                prof.talkingHeadCustomise = nil

                for old, spec in pairs(SIZE_KEYS) do
                    local v = tonumber(prof[old])
                    if v then
                        v = math.max(spec.floor, v)
                        for _, new in ipairs(spec.news) do
                            if prof[new] == nil then prof[new] = v end
                        end
                    end
                    if not spec.keep then prof[old] = nil end
                end

                for old, new in pairs(MODE_KEYS) do
                    if prof[old] ~= nil and prof[new] == nil then
                        prof[new] = prof[old] and "force" or "hide"
                    end
                    prof[old] = nil
                end

                if prof.insightBlankSeparator ~= nil and prof.insightSeparatorMode == nil then
                    prof.insightSeparatorMode = prof.insightBlankSeparator and "blank" or "divider"
                end
                prof.insightBlankSeparator = nil

                if prof.insightTitleMatchNameColor and prof.insightTitleColorMode == nil then
                    prof.insightTitleColorMode = "match"
                end
                prof.insightTitleMatchNameColor = nil
            end
        end
    end,
})
