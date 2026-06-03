-- Horizon Suite — Migration 20260603
-- CRITICAL: NEVER RENAME OR MODIFY THIS FILE IN ANY FUNCTIONAL WAY
-- Introduced: v5.0.3 — "fix(augment): promote vendor pill for existing auto-sell/repair users"
-- The mini-module architecture (v5.0.2) added augmentVendorEnabled as an outer
-- pill gate for the Auto Vendor mini-module, defaulting to false. No migration
-- was written for existing users who had autoSellerEnabled or autoRepairEnabled
-- set to true, so their vendor stopped working silently after the update.
-- We promote augmentVendorEnabled to true only when it has never been saved (nil),
-- so users who have already seen the new UI and toggled the pill explicitly are
-- not overwritten.

local addon = _G.HorizonSuite
if not addon or not addon.RegisterMigration then return end

local function migrate(profile)
    if type(profile) ~= "table" then return end
    if profile.augmentVendorEnabled ~= nil then return end
    if profile.autoSellerEnabled == true or profile.autoRepairEnabled == true then
        profile.augmentVendorEnabled = true
    end
end

addon.RegisterMigration({
    id  = "20260603",
    run = function(db)
        migrate(db)
        if type(db.profiles) == "table" then
            for _, profile in pairs(db.profiles) do
                migrate(profile)
            end
        end
    end,
})
