--[[
    Horizon Suite - Axis - Options categories
    Self-registers Modules and Profiles into addon.OptionCategories after OptionsData.lua runs.
    GlobalToggles is owned by OptionsGlobal.lua (inserts at position 2).
]]
local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L

local categories = {
    {
        key = "Modules",
        name = L["MODULES"],
        moduleKey = nil,
        options = function()
            local BM = addon.BrandModule
            local previewSuffix = " |cff228b22(" .. L["PRESENCE_PREVIEW"] .. ")|r"
            local previewDescSuffix = "\n\n" .. L["MODULE_PREVIEW_DISCLAIMER"]
            local function setModuleFromOptions(moduleKey, v)
                local dash = _G.HorizonSuiteDashboard
                local defer = dash and dash:IsShown()
                addon:SetModuleEnabled(moduleKey, v, defer and { deferReload = true } or nil)
            end
            return {
                { type = "section", name = L["MODULE_TOGGLES"] },
                { type = "toggle", name = BM and BM("focus"),                                    desc = L["DASH_OBJECTIVE_TRACKER_QUESTS_WORLD_QUESTS"], dbKey = "_module_focus",   get = function() return addon:IsModuleEnabled("focus")    end, set = function(v) setModuleFromOptions("focus",    v) end },
                { type = "toggle", name = BM and BM("presence"),                                 desc = L["DASH_ZONE_TEXT_AND_NOTIFICATIONS"],           dbKey = "_module_presence", get = function() return addon:IsModuleEnabled("presence") end, set = function(v) setModuleFromOptions("presence", v) end },
                { type = "toggle", name = BM and BM("vista"),                                    desc = L["DASH_MINIMAP_ZONE_TEXT_COORDS_BUTTON"],       dbKey = "_module_vista",    get = function() return addon:IsModuleEnabled("vista")    end, set = function(v) setModuleFromOptions("vista",    v) end },
                { type = "toggle", name = BM and BM("insight"),                                  desc = L["DASH_TOOLTIPS_CLASS_COLOURS_SPEC_FACTION"],   dbKey = "_module_insight",  get = function() return addon:IsModuleEnabled("insight")  end, set = function(v) setModuleFromOptions("insight",  v) end },
                { type = "toggle", name = (BM and BM("augment") or L["NAME_SUITE_LOOT"])    .. previewSuffix, desc = L["DASH_LOOT_TOASTS_ITEMS_MONEY_CURRENCY"]    .. previewDescSuffix, dbKey = "_module_augment", get = function() return addon:IsModuleEnabled("augment") end, set = function(v) setModuleFromOptions("augment", v) end },
                { type = "toggle", name = (BM and BM("essence") or L["NAME_SUITE_CHARACTER"]) .. previewSuffix, desc = L["DASH_ESSENCE_MODULE_SHORT_DESCRIPTION"] .. previewDescSuffix, dbKey = "_module_essence", get = function() return addon:IsModuleEnabled("essence") end, set = function(v) setModuleFromOptions("essence", v) end },
                { type = "moduleReloadPrompt" },
            }
        end,
    },
    {
        key = "Profiles",
        name = L["PROFILES"],
        desc = L["MANAGE_SWITCH_BETWEEN_YOUR_ADDON_CONFIGURATIONS"],
        moduleKey = nil,
        options = function()
            local opts = {}

            local function profileDropdownOptions()
                local list = addon.ListProfiles and addon.ListProfiles() or {}
                local out = {}
                for _, k in ipairs(list) do
                    if k ~= "Default" then
                        out[#out + 1] = { k, k }
                    end
                end
                return out
            end

            -- Section A: Global switch + current profile
            opts[#opts + 1] = { type = "section", name = L["PROFILES"] }

            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_GLOBAL_PROFILE"],
                desc = L["AXIS_CHARACTERS_SAME_PROFILE"],
                dbKey = "_profiles_useGlobal",
                get = function()
                    local useGlobal = addon.GetProfileModeState and select(1, addon.GetProfileModeState())
                    return useGlobal == true
                end,
                set = function(v)
                    local currentKey = addon.GetActiveProfileKey and addon.GetActiveProfileKey()
                    if addon.SetUseGlobalProfile then addon.SetUseGlobalProfile(v) end
                    if v and currentKey and addon.SetGlobalProfileKey then
                        addon.SetGlobalProfileKey(currentKey)
                    end
                    if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                end,
                refreshIds = {
                    "_profiles_current",
                    "_profiles_usePerSpec",
                    "_profiles_spec_1",
                    "_profiles_spec_2",
                    "_profiles_spec_3",
                    "_profiles_spec_4",
                },
            }

            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_CURRENT_PROFILE"],
                desc = L["AXIS_SELECT_PROFILE_CURRENTLY"],
                dbKey = "_profiles_current",
                options = profileDropdownOptions,
                disabled = function()
                    if not addon.GetProfileModeState then return false end
                    local useGlobal, usePerSpec = addon.GetProfileModeState()
                    return (useGlobal ~= true) and (usePerSpec == true)
                end,
                get = function() return (addon.GetActiveProfileKey and addon.GetActiveProfileKey()) end,
                set = function(v)
                    if addon.SetActiveProfileKey then addon.SetActiveProfileKey(v) end
                    addon._profileCopyFrom = nil
                    if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                end,
            }

            opts[#opts + 1] = {
                type = "button",
                name = L["DEFAULT"],
                desc = L["AXIS_CREATES_A_PROFILE_DEFAULT_SETTINGS"],
                dbKey = "_profiles_create_new",
                onClick = function()
                    if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup("Default") end
                end,
            }

            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_COPY_PROFILE"],
                desc = L["AXIS_SOURCE_PROFILE_COPYING"],
                dbKey = "_profiles_copyFrom",
                options = profileDropdownOptions,
                get = function()
                    local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    if addon._profileCopyFrom and addon._profileCopyFrom ~= "" then
                        for _, k in ipairs(list) do
                            if k == addon._profileCopyFrom then return addon._profileCopyFrom end
                        end
                    end
                    addon._profileCopyFrom = current
                    return current
                end,
                set = function(v) addon._profileCopyFrom = v end,
            }

            opts[#opts + 1] = {
                type = "button",
                name = L["AXIS_COPY_SELECTED"],
                desc = L["AXIS_CREATES_A_PROFILE_COPIED_SELECTED_SOURC"],
                dbKey = "_profiles_copy_selected",
                onClick = function()
                    local src = addon._profileCopyFrom or (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                    if addon.ShowCreateProfilePopup then addon.ShowCreateProfilePopup(src) end
                end,
            }

            opts[#opts + 1] = {
                type = "dropdown",
                name = "|cffff4040!|r " .. L["AXIS_DELETE_PROFILE"],
                desc = L["AXIS_SELECT_A_PROFILE_DELETE_CURRENT_DEFAULT"],
                dbKey = "_profiles_delete",
                options = function()
                    local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    local out = {}
                    for _, k in ipairs(list) do
                        if k ~= current and k ~= "Default" then out[#out + 1] = { k, k } end
                    end
                    return out
                end,
                get = function()
                    local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    local function exists(k)
                        if not k or k == "" then return false end
                        for _, kk in ipairs(list) do if kk == k then return true end end
                        return false
                    end
                    if exists(addon._profileDeleteKey) and addon._profileDeleteKey ~= current and addon._profileDeleteKey ~= "Default" then
                        return addon._profileDeleteKey
                    end
                    for _, k in ipairs(list) do
                        if k ~= current and k ~= "Default" then
                            addon._profileDeleteKey = k
                            return k
                        end
                    end
                    addon._profileDeleteKey = nil
                    return ""
                end,
                set = function(v) addon._profileDeleteKey = v end,
            }

            opts[#opts + 1] = {
                type = "button",
                name = L["AXIS_DELETE_SELECTED_PROFILE"],
                desc = L["AXIS_DELETE_SELECTED_PROFILE_DESC"],
                dbKey = "_profiles_delete_btn",
                onClick = function()
                    local k = addon._profileDeleteKey
                    if not k or k == "" then
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        local list = addon.ListProfiles and addon.ListProfiles() or {}
                        for _, kk in ipairs(list) do
                            if kk ~= current then k = kk; addon._profileDeleteKey = kk; break end
                        end
                    end
                    if not k or k == "" then return end
                    if addon.ShowDeleteProfilePopup then
                        addon.ShowDeleteProfilePopup(k)
                        return
                    end
                    if addon.DeleteProfile and addon.DeleteProfile(k) then
                        addon._profileDeleteKey = nil
                        if addon.OnActiveProfileChanged then addon.OnActiveProfileChanged() end
                    end
                end,
            }

            opts[#opts + 1] = {
                type = "moduleReloadPrompt",
                hintText = L["PROFILE_RELOAD_HINT"],
            }

            -- Section B: Per-spec switch + spec dropdowns
            opts[#opts + 1] = { type = "section", name = L["AXIS_SPEC_PROFILES"] }

            opts[#opts + 1] = {
                type = "toggle",
                name = L["AXIS_ENABLE"],
                desc = L["AXIS_PICK_DIFFERENT_PROFILES_PER_SPEC"],
                dbKey = "_profiles_usePerSpec",
                refreshIds = {
                    "_profiles_current",
                    "_profiles_spec_1",
                    "_profiles_spec_2",
                    "_profiles_spec_3",
                    "_profiles_spec_4",
                },
                disabled = function()
                    local useGlobal = addon.GetProfileModeState and select(1, addon.GetProfileModeState())
                    return useGlobal == true
                end,
                get = function()
                    if not addon.GetProfileModeState then return false end
                    local useGlobal, usePerSpec = addon.GetProfileModeState()
                    return (useGlobal ~= true) and (usePerSpec == true)
                end,
                set = function(v)
                    if v and addon.GetActiveProfileKey and addon.SetPerSpecProfileKey then
                        local baseKey = addon.GetActiveProfileKey()
                        if baseKey then
                            local currentSpec = PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID() or nil
                            for si = 1, 4 do
                                if si == currentSpec then
                                    addon.SetPerSpecProfileKey(si, baseKey)
                                else
                                    local _, _, _, perSpec = addon.GetProfileModeState()
                                    if not (type(perSpec) == "table" and type(perSpec[si]) == "string" and perSpec[si] ~= "") then
                                        addon.SetPerSpecProfileKey(si, baseKey)
                                    end
                                end
                            end
                        end
                    end
                    if addon.SetUsePerSpecProfiles then addon.SetUsePerSpecProfiles(v) end
                    if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                end,
            }

            local function specProfileOptions()
                local list = addon.ListProfiles and addon.ListProfiles() or {}
                local out = {}
                for _, k in ipairs(list) do
                    if k ~= "Default" then
                        out[#out + 1] = { k, k }
                    end
                end
                return out
            end

            for specIndex = 1, 4 do
                local function specNameFn()
                    if addon.ListSpecOptions then
                        local specOpts = addon.ListSpecOptions()
                        for _, pair in ipairs(specOpts) do
                            if tonumber(pair[1]) == specIndex then
                                return pair[2]
                            end
                        end
                    end
                    return L["AXIS_SPEC_FALLBACK_FMT"]:format(specIndex)
                end
                local function specHiddenFn()
                    local numSpecs = _G.GetNumSpecializations and _G.GetNumSpecializations() or 0
                    if numSpecs < 1 then return false end
                    return specIndex > numSpecs
                end
                opts[#opts + 1] = {
                    type = "dropdown",
                    name = specNameFn,
                    dbKey = "_profiles_spec_" .. tostring(specIndex),
                    options = specProfileOptions,
                    hidden = specHiddenFn,
                    disabled = function()
                        if not addon.GetProfileModeState then return true end
                        local useGlobal, usePerSpec = addon.GetProfileModeState()
                        return (useGlobal == true) or (usePerSpec ~= true)
                    end,
                    get = function()
                        if not addon.GetProfileModeState then
                            return (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                        end
                        local useGlobal, usePerSpec, _, perSpec = addon.GetProfileModeState()
                        if useGlobal ~= true and usePerSpec == true then
                            if type(perSpec) == "table" and type(perSpec[specIndex]) == "string" and perSpec[specIndex] ~= "" then
                                return perSpec[specIndex]
                            end
                        end
                        return (addon.GetActiveProfileKey and addon.GetActiveProfileKey())
                    end,
                    set = function(v)
                        if addon.SetPerSpecProfileKey then addon.SetPerSpecProfileKey(specIndex, v) end
                        if addon.OnActiveProfileChangedDeferred then addon.OnActiveProfileChangedDeferred() end
                    end,
                }
            end

            opts[#opts + 1] = {
                type = "moduleReloadPrompt",
                hintText = L["PROFILE_RELOAD_HINT"],
            }

            -- Section C: Sharing (export / import)
            opts[#opts + 1] = { type = "section", name = L["AXIS_SHARING"] }

            opts[#opts + 1] = {
                type = "dropdown",
                name = L["AXIS_EXPORT_PROFILE"],
                desc = L["AXIS_SELECT_A_PROFILE_EXPORT"],
                dbKey = "_profiles_export_select",
                options = function()
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    local out = {}
                    for _, k in ipairs(list) do
                        if k ~= "Default" then out[#out + 1] = { k, k } end
                    end
                    return out
                end,
                get = function()
                    local list = addon.ListProfiles and addon.ListProfiles() or {}
                    if addon._profileExportKey then
                        for _, k in ipairs(list) do
                            if k == addon._profileExportKey and k ~= "Default" then return k end
                        end
                    end
                    local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                    if current and current ~= "Default" then
                        addon._profileExportKey = current
                        return current
                    end
                    for _, k in ipairs(list) do
                        if k ~= "Default" then addon._profileExportKey = k; return k end
                    end
                    return ""
                end,
                set = function(v)
                    addon._profileExportKey = v
                    if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                end,
            }

            opts[#opts + 1] = {
                type = "editbox",
                labelText = L["AXIS_EXPORT_STRING"],
                dbKey = "_profiles_export_box",
                height = 60,
                readonly = true,
                storeRef = "_profileExportEditBox",
                get = function()
                    local key = addon._profileExportKey
                    if not key or key == "" then
                        local current = addon.GetActiveProfileKey and addon.GetActiveProfileKey() or nil
                        if current and current ~= "Default" then
                            key = current
                            addon._profileExportKey = key
                        else
                            local list = addon.ListProfiles and addon.ListProfiles() or {}
                            for _, k in ipairs(list) do
                                if k ~= "Default" then key = k; addon._profileExportKey = k; break end
                            end
                        end
                    end
                    if not key or key == "" then return "" end
                    return (addon.ExportProfile and addon.ExportProfile(key)) or ""
                end,
            }

            opts[#opts + 1] = {
                type = "editbox",
                labelText = L["AXIS_IMPORT_STRING"],
                dbKey = "_profiles_import_box",
                height = 60,
                readonly = false,
                get = function() return addon._profileImportString or "" end,
                set = function(v)
                    addon._profileImportString = v
                    local valid = addon.ValidateProfileString and addon.ValidateProfileString(v) or false
                    addon._profileImportValid = valid
                end,
            }

            opts[#opts + 1] = {
                type = "button",
                name = L["AXIS_IMPORT_PROFILE"],
                dbKey = "_profiles_import_btn",
                onClick = function()
                    local str = addon._profileImportString
                    if not str or str == "" then
                        if addon.HSPrint then addon.HSPrint(L["AXIS_PROFILE_NO_IMPORT_STRING"]) end
                        return
                    end
                    if not (addon.ValidateProfileString and addon.ValidateProfileString(str)) then
                        if addon.HSPrint then addon.HSPrint(L["AXIS_PROFILE_INVALID_STRING"]) end
                        return
                    end
                    addon._profileImportSourceString = str
                    if StaticPopup_Show then
                        StaticPopup_Show("HORIZONSUITE_IMPORT_PROFILE")
                    end
                end,
            }

            return opts
        end,
    },
}

table.insert(addon.OptionCategories, categories[1])
table.insert(addon.OptionCategories, categories[2])
