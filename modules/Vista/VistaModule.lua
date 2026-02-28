--[[
    Horizon Suite - Vista Module
    Cinematic square minimap with zone text, coordinates, instance difficulty, mail, and button collector.
    Registers with addon:RegisterModule. Migrated from ModernMinimap.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.RegisterModule then return end

addon:RegisterModule("vista", {
    title       = "Vista",
    description = "Cinematic square minimap with zone text, coordinates, instance difficulty, mail indicator, and button collector.",
    order       = 25,

    OnInit = function()
        addon.EnsureDB()
        if not addon.GetActiveProfile or not addon.SetDB then return end

        -- One-time migration: DB.modules.vista and ModernMinimapDB -> profile
        local db = _G[addon.DB_NAME]
        if not db then db = {}; _G[addon.DB_NAME] = db end
        if not db.modules then db.modules = {} end
        if not db.modules.vista then db.modules.vista = {} end
        local modDb = db.modules.vista
        if not modDb.migratedToProfile then
            modDb.migratedToProfile = true
            local hasProfileData = addon.GetDB("vistaPoint", nil) or addon.GetDB("vistaX", nil) or addon.GetDB("vistaY", nil)
            if not hasProfileData then
                local src = modDb
                if _G.ModernMinimapDB and type(_G.ModernMinimapDB) == "table" and (not src.point and not src.x and not src.y) then
                    src = _G.ModernMinimapDB
                end
                if src.point then addon.SetDB("vistaPoint", src.point) end
                if src.relpoint then addon.SetDB("vistaRelPoint", src.relpoint) end
                if src.x ~= nil then addon.SetDB("vistaX", src.x) end
                if src.y ~= nil then addon.SetDB("vistaY", src.y) end
                if src.scale ~= nil then addon.SetDB("vistaScale", src.scale) end
                if src.lock ~= nil then addon.SetDB("vistaLock", src.lock) end
                if src.autoZoom ~= nil then addon.SetDB("vistaAutoZoom", src.autoZoom) end
                if src.enabled ~= nil then addon.SetDB("vistaShowMinimap", src.enabled) end
            end
        end
    end,

    OnEnable = function()
        if addon.Vista and addon.Vista.Init then
            addon.Vista.Init()
        end
    end,

    OnDisable = function()
        if addon.Vista and addon.Vista.Disable then
            addon.Vista.Disable()
        end
    end,
})
