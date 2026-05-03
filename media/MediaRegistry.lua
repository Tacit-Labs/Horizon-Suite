local addon = _G.HorizonSuite
if not addon then return end

local MEDIA_DIR = "Interface\\AddOns\\HorizonSuite\\media\\"

addon.RadarIcons = {
    { key = "radar1", label = "Radar 1", file = MEDIA_DIR .. "radar1" },
    { key = "radar2", label = "Radar 2", file = MEDIA_DIR .. "radar2" },
}

function addon.GetRadarIconPath(key)
    for _, entry in ipairs(addon.RadarIcons) do
        if entry.key == key then
            return entry.file .. ".blp"
        end
    end
    return addon.RadarIcons[1].file .. ".blp"
end

function addon.GetRadarIconOptions()
    local opts = {}
    for _, entry in ipairs(addon.RadarIcons) do
        opts[#opts + 1] = {
            "|T" .. entry.file .. ".blp:0|t " .. entry.label,
            entry.key,
        }
    end
    return opts
end

