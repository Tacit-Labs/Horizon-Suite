-- Horizon Suite — Migration 20260527
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v5.0.0 (2026-05-27) — "refactor(augment): rename Cache module to Augment"
-- Renames all cache-prefixed DB keys to augment-prefixed equivalents across the
-- root DB and every stored profile, and migrates the module registry entry.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

local function renameKeys(tbl)
    if type(tbl) ~= "table" then return end
    local moves
    for k in pairs(tbl) do
        if type(k) == "string" and k:sub(1, 5) == "cache" then
            moves = moves or {}
            moves[k] = "augment" .. k:sub(6)
        end
    end
    if not moves then return end
    for oldKey, newKey in pairs(moves) do
        if tbl[newKey] == nil then tbl[newKey] = tbl[oldKey] end
        tbl[oldKey] = nil
    end
end

local function renameFixedKeys(tbl)
    if type(tbl) ~= "table" then return end
    if tbl.classColorCache ~= nil then
        if tbl.classColorAugment == nil then tbl.classColorAugment = tbl.classColorCache end
        tbl.classColorCache = nil
    end
end

local function renameModuleEntry(modules)
    if type(modules) == "table" and modules.cache ~= nil then
        if modules.augment == nil then modules.augment = modules.cache end
        modules.cache = nil
    end
end

addon.RegisterMigration({
    id = "20260527",

    legacy = function(db) return db._augmentRenamed end,

    run = function(db)
        renameKeys(db)
        renameFixedKeys(db)
        renameModuleEntry(db.modules)

        if type(db.profiles) == "table" then
            for _, prof in pairs(db.profiles) do
                if type(prof) == "table" then
                    renameKeys(prof)
                    renameFixedKeys(prof)
                    renameModuleEntry(prof.modules)
                end
            end
        end
    end,
})
