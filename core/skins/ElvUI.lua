local addon = _G.HorizonSuite
if not addon then return end

addon.GameMenuButtonSkins = addon.GameMenuButtonSkins or {}
table.insert(addon.GameMenuButtonSkins, function(button)
    if not _G.ElvUI then return end
    local E = _G.ElvUI[1]
    if not E then return end
    if not (E.private and E.private.skins and E.private.skins.blizzard
            and E.private.skins.blizzard.enable and E.private.skins.blizzard.misc) then return end
    if E.OtherAddons and E.OtherAddons.ConsolePort then return end
    local S = E:GetModule('Skins')
    if not S then return end
    S:HandleButton(button, nil, nil, nil, true)
    if button.backdrop then button.backdrop:SetInside(nil, 1, 1) end
end)
