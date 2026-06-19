--[[
    Horizon Suite - Augment - Defaults shell
    Sub-module defaults are populated by the three files in augment/*.lua,
    which the .toc loads before this file. This shell finalises AUGMENT_KEYS
    so every key written via OptionsData_SetDB is routed correctly.
]]
local addon = _G.HorizonSuite
if not addon then return end

-- Ensure tables exist even if a sub-file failed to load.
addon.AUGMENT_DEFAULTS = addon.AUGMENT_DEFAULTS or {}
addon.AUGMENT_LIMITS   = addon.AUGMENT_LIMITS   or {}

-- Position keys have no meaningful defaults (nil = use anchor frame position).
addon.AUGMENT_KEYS = { augmentPoint = true, augmentRelPoint = true, augmentX = true, augmentY = true }
for k in pairs(addon.AUGMENT_DEFAULTS) do addon.AUGMENT_KEYS[k] = true end
