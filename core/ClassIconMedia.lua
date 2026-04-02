--[[
    Horizon Suite - Class icon media (Blizzard atlas / RondoMedia / bundled / custom addon media).
    Shared by Insight tooltips and the Dashboard; not Insight-specific.
    RondoMedia class icons by RondoFerrari — https://www.curseforge.com/wow/addons/rondomedia
    Custom icons: media/CustomClassIcons/<CLASSFILE>/<classfile lower>.tga (e.g. WARRIOR/warrior.tga).
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon then return end

local LSM_CLASSICON = "classicon"
local RONDO_BORDER_FOLDER = "class_colored border"

-- classFile (DEATHKNIGHT, etc.) → RondoMedia filename part ("Death Knight", etc.)
addon.CLASS_ICON_RONDO_NAMES = {
    DEATHKNIGHT = "Death Knight", DEMONHUNTER = "Demon Hunter",
    DRUID = "Druid", EVOKER = "Evoker", HUNTER = "Hunter", MAGE = "Mage",
    MONK = "Monk", PALADIN = "Paladin", PRIEST = "Priest", ROGUE = "Rogue",
    SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior",
}

local function IsRondoMediaLoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local ok, r = pcall(C_AddOns.IsAddOnLoaded, "RondoMedia")
        return ok and r
    end
    if type(IsAddOnLoaded) == "function" then
        local ok, r = pcall(IsAddOnLoaded, "RondoMedia")
        return ok and r
    end
    return false
end

local function BundledRondoBasePath()
    local folder = addon.ADDON_NAME or "HorizonSuite"
    return ("Interface\\AddOns\\%s\\media\\RondoClassIcons\\%s\\32x32\\"):format(folder, RONDO_BORDER_FOLDER)
end

-- classFile must be a known playable class (same set as Rondo map).
local function BundledCustomClassIconPath(classFile)
    if not classFile or not addon.CLASS_ICON_RONDO_NAMES[classFile] then return nil end
    local folder = addon.ADDON_NAME or "HorizonSuite"
    local lower = strlower(classFile)
    return ("Interface\\AddOns\\%s\\media\\CustomClassIcons\\%s\\%s.tga"):format(folder, classFile, lower)
end

--- Resolve class icon for Texture:SetTexture / SetAtlas or tooltip |T markup.
--- @param classFile string UnitClass classFile (DEATHKNIGHT, etc.)
--- @param source string "default" | "rondomedia" | "custom"
--- @return table|nil { kind = "file", path = string } | { kind = "atlas", atlas = string }
function addon.ResolveClassIconDisplay(classFile, source)
    if not classFile then return nil end
    if source == "custom" then
        local path = BundledCustomClassIconPath(classFile)
        if path then
            return { kind = "file", path = path }
        end
        return nil
    end
    if source == "rondomedia" then
        local displayName = addon.CLASS_ICON_RONDO_NAMES[classFile]
        if displayName then
            if IsRondoMediaLoaded() then
                local path = ("Interface\\AddOns\\RondoMedia\\media\\Class_icons\\%s\\32x32\\%s_32.tga"):format(RONDO_BORDER_FOLDER, displayName)
                return { kind = "file", path = path }
            end
            local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
            if LSM and LSM.Fetch then
                local ok, path = pcall(LSM.Fetch, LSM, LSM_CLASSICON, classFile, true)
                if ok and path and path ~= "" then
                    return { kind = "file", path = path }
                end
            end
            local path = BundledRondoBasePath() .. displayName .. "_32.tga"
            return { kind = "file", path = path }
        end
    end
    if GetClassAtlas then
        local atlas = GetClassAtlas(classFile)
        if atlas then
            return { kind = "atlas", atlas = atlas }
        end
    end
    return nil
end

--- Register RondoMedia class icons with LibSharedMedia if not already registered.
--- Prefers RondoMedia addon path; else Horizon Suite bundled path.
--- @return nil
function addon.RegisterRondoClassIconsWithLSM()
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if not LSM or not LSM.Register then return end

    local useRondo = IsRondoMediaLoaded()
    local base = useRondo
        and ("Interface\\AddOns\\RondoMedia\\media\\Class_icons\\" .. RONDO_BORDER_FOLDER .. "\\32x32\\")
        or BundledRondoBasePath()

    for classFile, displayName in pairs(addon.CLASS_ICON_RONDO_NAMES) do
        local path = base .. displayName .. "_32.tga"
        LSM:Register(LSM_CLASSICON, classFile, path)
    end
end
