--[[
    Horizon Suite - Flow Module
    Horizon chrome and objectives-first layout for the NPC quest dialogue window.
    Hosts Blizzard's QuestFrame rather than replacing it: QuestFrame stays inside
    UIPanelWindows and Blizzard keeps body text layout plus every control that
    grants a reward. Registers with addon:RegisterModule.
]]

local addon = _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("flow", {
    title       = "Flow",
    description = "Horizon styling for the quest dialogue window, with objectives above the flavour text.",
    order       = 28,

    OnEnable = function()
        if addon.Flow and addon.Flow.Enable then addon.Flow.Enable() end
    end,

    OnDisable = function()
        if addon.Flow and addon.Flow.Disable then addon.Flow.Disable() end
    end,
})
