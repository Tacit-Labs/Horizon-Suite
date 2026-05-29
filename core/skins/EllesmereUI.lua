local addon = _G.HorizonSuite
if not addon then return end

addon.GameMenuButtonSkins = addon.GameMenuButtonSkins or {}
table.insert(addon.GameMenuButtonSkins, function(button)
    local EUI = _G.EllesmereUI
    if not EUI then return end
    local RS = EUI.RESKIN
    local PP = EUI.PP
    if not RS or not PP then return end

    local blizzSkinLoaded = C_AddOns and C_AddOns.IsAddOnLoaded and
        C_AddOns.IsAddOnLoaded("EllesmereUIBlizzardSkin")
    if not blizzSkinLoaded then return end

    local db = _G.EllesmereUIDB
    local reskin = db and db.reskinGameMenu
    if reskin == nil then
        reskin = not db or (db.customTooltips ~= false and db.reskinQueuePopup ~= false)
    end
    if not reskin then return end

    for i = 1, select("#", button:GetRegions()) do
        local r = select(i, button:GetRegions())
        if r and r:IsObjectType("Texture") and r ~= button:GetFontString() then
            r:SetAlpha(0)
        end
    end
    for _, key in ipairs({ "Left", "Middle", "Right" }) do
        local tex = button[key]
        if tex then
            tex:SetAlpha(0)
            hooksecurefunc(tex, "SetAlpha", function(self, a)
                if a > 0 then self:SetAlpha(0) end
            end)
        end
    end

    local inset = CreateFrame("Frame", nil, button)
    inset:SetPoint("TOPLEFT", 2, -2)
    inset:SetPoint("BOTTOMRIGHT", -2, 2)
    inset:SetFrameLevel(button:GetFrameLevel())
    local bg = inset:CreateTexture(nil, "BACKGROUND", nil, -6)
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    if PP.CreateBorder then
        PP.CreateBorder(inset, 1, 1, 1, RS.BRD_ALPHA, 1, "OVERLAY", 7)
    end
    local hl = button:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints(inset)
    hl:SetColorTexture(1, 1, 1, 0.1)
    local fs = button:GetFontString()
    if fs then
        local euiFont = EUI.GetFontPath and EUI.GetFontPath("blizzardSkin") or nil
        local _, size, flags = fs:GetFont()
        fs:SetFont(euiFont or "Fonts\\FRIZQT__.TTF", (size or 14) - 2, flags or "")
    end
end)
