--[[
    Horizon Suite - Flow - SetDB routing keys
    Exports FLOW_KEYS used by OptionsData_SetDB to trigger
    Flow.ApplyFlowOptions when any Flow setting changes.

    Flow carries its own appearance keys rather than reading Focus's. Coupling
    them would mean reconfiguring or disabling Focus silently changed the quest
    box; the defaults below simply sit close to Focus's so the two look like one
    product out of the box.
]]
local addon = _G.HorizonSuite
if not addon then return end

addon.FLOW_KEYS = {
    flowBackdropColor   = true,
    flowBackdropOpacity = true,
    flowShowBorder      = true,
    flowFontPath        = true,
    flowFontSize        = true,
    flowEntrance        = true,
    flowCollapseLore    = true,
    flowShowTypePill    = true,
    flowAutoSize        = true,
    flowHideCloseButton = true,
    classColorFlow      = true,
}

addon.FLOW_DEFAULTS = {
    flowBackdropColor   = { 0.09, 0.09, 0.11 },
    flowBackdropOpacity = 92,
    flowShowBorder      = true,
    flowFontSize        = 13,
    flowEntrance        = true,
    flowCollapseLore    = true,
    flowShowTypePill    = true,
    flowAutoSize        = true,
    flowHideCloseButton = true,
}

addon.FLOW_LIMITS = {
    flowBackdropOpacity = { min = 0, max = 100 },
    flowFontSize        = { min = 9, max = 22  },
}
