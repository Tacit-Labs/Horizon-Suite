--[[
    Horizon Suite - Augment / AutoVendor - Option defaults and limits
    Populates addon.AUGMENT_DEFAULTS and addon.AUGMENT_LIMITS for the Auto
    Vendor mini-module. Loaded before OptionsDefaultsAugment.lua.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

local D   = addon.AUGMENT_DEFAULTS
local LIM = addon.AUGMENT_LIMITS

-- Auto Vendor mini-module master switch (pill)
-- Defaults to true so the event frame is always registered.
-- Auto Seller defaults on (greys) to match the feature description; Auto Repair
-- stays opt-in because it spends gold.
D.augmentVendorEnabled        = true

-- AutoSeller
-- Defaults on so the Auto Vendor pill matches its description (sell greys on
-- merchant open). Auto Repair stays opt-in because it spends gold.
D.autoSellerEnabled           = true
D.autoSellerGrey              = true
D.autoSellerUnusable          = false
D.autoSellerNonOptimal        = false
D.autoSellerLowLevel          = false
D.autoSellerLowLevelThreshold = 50
D.autoSellerFortuneCards      = false
D.autoSellerLegionRelics      = false
D.autoSellerVerbosity         = "summary"

-- AutoRepair
D.autoRepairEnabled           = false
D.autoRepairGuildBank         = false
D.autoRepairVerbosity         = "summary"

-- Limits
LIM.autoSellerLowLevelThreshold = { min = 1, max = 999 }
