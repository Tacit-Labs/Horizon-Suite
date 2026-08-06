--[[
    Horizon Suite - Augment - Personal Loot Window Skin
    In-place restyle of Blizzard LootFrame to match Augment toast chrome.
    Does not replace loot clicks. Group-roll consumers can reuse Skin* helpers later.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

local TOOLTIP_BACKDROP = {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 },
}

-- Match AugmentCore: clamp augmentUIScale and scale raw layout values.
local function S(v)
    local lim = addon.AUGMENT_LIMITS and addon.AUGMENT_LIMITS.augmentUIScale
    local def = addon.AUGMENT_DEFAULTS and addon.AUGMENT_DEFAULTS.augmentUIScale or 1
    local scale = 1
    if lim then
        scale = math.max(lim.min, math.min(lim.max,
            tonumber(addon.GetDB and addon.GetDB("augmentUIScale", def)) or 1))
    else
        scale = tonumber(addon.GetDB and addon.GetDB("augmentUIScale", def)) or 1
    end
    return v * scale
end

local hooksInstalled = false
local skinActive = false
local savedRegions = {}  -- [region] = wasShown (bool) for best-effort restore

-- Record prior visibility once; used by DisableLootWindowSkin to re-Show only if shown.
local function RememberRegion(region)
    if region and savedRegions[region] == nil then
        savedRegions[region] = (region.IsShown and region:IsShown()) and true or false
    end
end

-- LootFrame may lack BackdropTemplate; child frame holds tooltip-style chrome behind content.
local function GetBackdropHost(frame)
    if frame.SetBackdrop then
        return frame
    end
    if not frame._hsAugmentChromeFrame then
        local chrome = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        chrome:SetAllPoints(frame)
        local level = frame.GetFrameLevel and frame:GetFrameLevel() or 0
        if chrome.SetFrameLevel then
            chrome:SetFrameLevel(math.max(0, level - 1))
        end
        frame._hsAugmentChromeFrame = chrome
    end
    return frame._hsAugmentChromeFrame
end

local function ClearWindowBackdrop(frame)
    if frame.SetBackdrop then
        frame:SetBackdrop(nil)
    end
    local chrome = frame._hsAugmentChromeFrame
    if chrome and chrome.SetBackdrop then
        chrome:SetBackdrop(nil)
    end
end

--- Hide common Blizzard decorative regions on a frame (NineSlice, Border, Portrait, etc.).
--- @param frame Frame
--- @return nil
function Y.SkinStripDefaultArt(frame)
    if not frame then return end
    local names = { "NineSlice", "Border", "Bg", "TitleBg", "PortraitContainer", "Inset", "TopTileStreaks" }
    for i = 1, #names do
        local region = frame[names[i]]
        if region and region.Hide then
            RememberRegion(region)
            pcall(region.Hide, region)
        end
    end
    -- Also hide unnamed texture children that look like full-frame borders (best-effort).
    if frame.GetRegions then
        local regions = { frame:GetRegions() }
        for _, r in ipairs(regions) do
            if r and r.GetObjectType and r:GetObjectType() == "Texture" and r.Hide then
                local draw = r.GetDrawLayer and r:GetDrawLayer()
                if draw == "BORDER" or draw == "BACKGROUND" then
                    RememberRegion(r)
                    pcall(r.Hide, r)
                end
            end
        end
    end
end

--- Apply Compact / Framed / Accent chrome to a window frame.
--- Framed uses tooltip backdrop; Accent draws a left colour strip; Compact is minimal dark fill.
--- @param frame Frame Must support BackdropTemplate methods when style is framed (ensure template or CreateTexture fallback)
--- @param style string|nil
--- @param accentR number
--- @param accentG number
--- @param accentB number
--- @return nil
function Y.SkinApplyWindowChrome(frame, style, accentR, accentG, accentB)
    if not frame then return end
    local TS = Y.ToastStyles
    style = (TS and TS.Normalize and TS.Normalize(style)) or "framed"
    accentR, accentG, accentB = accentR or 0.6, accentG or 0.6, accentB or 0.6

    if not frame._hsAugmentChromeStrip then
        local strip = frame:CreateTexture(nil, "ARTWORK")
        strip:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        strip:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        frame._hsAugmentChromeStrip = strip
    end
    local strip = frame._hsAugmentChromeStrip
    strip:SetWidth(S(3))

    if style == "framed" then
        ClearWindowBackdrop(frame) -- reset then re-apply framed backdrop below
        if frame._hsAugmentChromeBg then
            frame._hsAugmentChromeBg:Hide()
        end
        local backdropHost = GetBackdropHost(frame)
        if backdropHost.SetBackdrop then
            TOOLTIP_BACKDROP.edgeSize = S(10)
            backdropHost:SetBackdrop(TOOLTIP_BACKDROP)
            backdropHost:SetBackdropColor(0, 0, 0, 0.75)
            backdropHost:SetBackdropBorderColor(accentR, accentG, accentB, 0.7)
        end
        strip:Hide()
    elseif style == "accent" then
        ClearWindowBackdrop(frame)
        if not frame._hsAugmentChromeBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(frame)
            bg:SetColorTexture(0, 0, 0, 0.85)
            frame._hsAugmentChromeBg = bg
        end
        frame._hsAugmentChromeBg:Show()
        strip:SetColorTexture(accentR, accentG, accentB, 1)
        strip:Show()
    else -- compact
        ClearWindowBackdrop(frame)
        if not frame._hsAugmentChromeBg then
            local bg = frame:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(frame)
            bg:SetColorTexture(0, 0, 0, 0.85)
            frame._hsAugmentChromeBg = bg
        end
        frame._hsAugmentChromeBg:Show()
        strip:Hide()
    end
end

--- Colour a FontString by item quality.
--- @param fontString FontString
--- @param quality number|nil
--- @return nil
function Y.SkinApplySlotQuality(fontString, quality)
    if not fontString or not fontString.SetTextColor then return end
    local r, g, b = 1, 1, 1
    if ITEM_QUALITY_COLORS and quality ~= nil and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        r, g, b = c.r, c.g, c.b
    elseif Y.QUALITY_COLORS and Y.QUALITY_COLORS[quality or 1] then
        local c = Y.QUALITY_COLORS[quality or 1]
        r, g, b = c[1] or c.r, c[2] or c.g, c[3] or c.b
    end
    fontString:SetTextColor(r, g, b, 1)
end

-- Highest visible loot slot quality colour, or muted white/grey when empty.
local function GetLootAccentColor()
    local bestQ = -1
    local r, g, b = 0.7, 0.7, 0.7
    local num = GetNumLootItems and GetNumLootItems() or 0
    for slot = 1, num do
        -- GetLootSlotInfo: texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive
        local ok, _, _, _, _, quality = pcall(GetLootSlotInfo, slot)
        if ok and quality and quality > bestQ then
            bestQ = quality
            if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
                local c = ITEM_QUALITY_COLORS[quality]
                r, g, b = c.r, c.g, c.b
            end
        end
    end
    return r, g, b, bestQ
end

-- Resolve name FontString and icon Texture on a loot slot button (legacy or ScrollBox).
local function ResolveLootButtonRegions(button)
    local name = button.GetName and button:GetName()
    local text = button.Text or button.Name
    if not text and name then
        text = _G[name .. "Text"]
    end
    local icon = button.Icon or button.icon
    if not icon and name then
        icon = _G[name .. "IconTexture"] or _G[name .. "Icon"]
    end
    return text, icon
end

-- Apply quality-coloured name, style icon pad, and hide default borders on one slot.
local function SkinOneLootButton(button, quality)
    if not button or not button.IsShown or not button:IsShown() then return end
    local fontPath = Y.GetFontPath and Y.GetFontPath() or "Fonts\\FRIZQT__.TTF"
    local text, icon = ResolveLootButtonRegions(button)
    if text and text.SetFont then
        pcall(text.SetFont, text, fontPath, S(13), "OUTLINE")
        Y.SkinApplySlotQuality(text, quality)
    end

    local style = Y.GetToastStyle and Y.GetToastStyle() or "framed"
    local r, g, b = 1, 1, 1
    if ITEM_QUALITY_COLORS and quality and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        r, g, b = c.r, c.g, c.b
    elseif Y.QUALITY_COLORS and Y.QUALITY_COLORS[quality or 1] then
        local c = Y.QUALITY_COLORS[quality or 1]
        r, g, b = c[1] or c.r, c[2] or c.g, c[3] or c.b
    end

    -- Accent/Compact: quality-tinted icon pad behind icon (create once; resize on style change).
    -- Accent padExtra=4 / alpha=0.85 matches ToastStyles ACCENT_PAD_EXTRA fidelity (via S()).
    if style == "accent" or style == "compact" then
        if icon then
            if not button._hsIconPad then
                -- sublevel -1 so pad draws under ItemButtonTemplate icon (also BACKGROUND)
                button._hsIconPad = button:CreateTexture(nil, "BACKGROUND", nil, -1)
            elseif button._hsIconPad.SetDrawLayer then
                button._hsIconPad:SetDrawLayer("BACKGROUND", -1)
            end
            local pad = button._hsIconPad
            local padExtra = S((style == "accent") and 4 or 1)
            if button._hsIconPadExtra ~= padExtra or button._hsIconPadIcon ~= icon then
                pad:ClearAllPoints()
                pad:SetPoint("TOPLEFT", icon, "TOPLEFT", -padExtra, padExtra)
                pad:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", padExtra, -padExtra)
                button._hsIconPadExtra = padExtra
                button._hsIconPadIcon = icon
            end
            pad:SetColorTexture(r, g, b, style == "accent" and 0.85 or 0.8)
            pad:Show()
        end
    elseif button._hsIconPad then
        button._hsIconPad:Hide()
    end

    -- Hide default slot border textures when present; Framed re-shows if we hid them earlier.
    local border = button.IconBorder or button.NormalTexture
    if border and border.Hide and style ~= "framed" then
        RememberRegion(border)
        pcall(border.Hide, border)
    elseif border and border.Show then
        pcall(border.Show, border)
    end
end

-- Best-effort: tint money-line FontStrings; never rewrite coin values.
local function ApplyMoneyLineSkin()
    local frame = _G.LootFrame
    if not frame then return end
    local fontPath = Y.GetFontPath and Y.GetFontPath() or "Fonts\\FRIZQT__.TTF"

    local function SkinMoneyFontString(fs)
        if fs and fs.SetFont then
            pcall(fs.SetFont, fs, fontPath, S(12), "OUTLINE")
        end
    end

    local function SkinMoneyFrame(mf)
        if not mf then return end
        if mf.GetObjectType and mf:GetObjectType() == "FontString" then
            SkinMoneyFontString(mf)
            return
        end
        -- Common MoneyFrame children / named globals
        local labels = {
            mf.Text, mf.Label, mf.GoldText, mf.SilverText, mf.CopperText,
            mf.GoldButton and mf.GoldButton.Text,
            mf.SilverButton and mf.SilverButton.Text,
            mf.CopperButton and mf.CopperButton.Text,
        }
        for i = 1, #labels do
            SkinMoneyFontString(labels[i])
        end
        local name = mf.GetName and mf:GetName()
        if name then
            SkinMoneyFontString(_G[name .. "Text"])
            SkinMoneyFontString(_G[name .. "GoldButtonText"])
            SkinMoneyFontString(_G[name .. "SilverButtonText"])
            SkinMoneyFontString(_G[name .. "CopperButtonText"])
        end
        if mf.GetRegions then
            local regions = { mf:GetRegions() }
            for _, r in ipairs(regions) do
                if r and r.GetObjectType and r:GetObjectType() == "FontString" then
                    SkinMoneyFontString(r)
                end
            end
        end
    end

    SkinMoneyFrame(_G.LootFrameGoldButton)
    SkinMoneyFrame(frame.MoneyFrame)
    SkinMoneyFrame(frame.GoldButton)

    if frame.GetChildren then
        local children = { frame:GetChildren() }
        for _, child in ipairs(children) do
            local cname = child and child.GetName and child:GetName()
            if cname and (cname:find("Money", 1, true) or cname:find("Gold", 1, true)
                or cname:find("Silver", 1, true) or cname:find("Copper", 1, true)) then
                SkinMoneyFrame(child)
            end
        end
    end
end

-- Resolve loot slot for GetLootSlotInfo (ScrollBox slotIndex, legacy slot/GetID, or paged index).
local function ResolveLootSlot(button, fallbackIndex)
    local slot = button.slotIndex or button.slot
    if not slot and button.GetID then
        local id = button:GetID()
        if id and id > 0 then
            slot = id
        end
    end
    if not slot then
        local frame = _G.LootFrame
        local numButtons = _G.LOOTFRAME_NUMBUTTONS
        if frame and frame.page and numButtons and fallbackIndex then
            -- Legacy paged loot: on-screen button index is not the loot slot.
            slot = fallbackIndex + (frame.page - 1) * numButtons
        else
            slot = fallbackIndex
        end
    end
    return slot
end

-- Skin one shown button using slot index for GetLootSlotInfo quality.
local function SkinLootButtonBySlot(button, fallbackIndex)
    if not button or not button.IsShown or not button:IsShown() then return end
    local slot = ResolveLootSlot(button, fallbackIndex)
    local ok, _, _, _, _, quality = pcall(GetLootSlotInfo, slot)
    SkinOneLootButton(button, ok and quality or 1)
end

local function ApplyLootSlotsSkin()
    local skinned = false
    local numButtons = (_G.LOOTFRAME_NUMBUTTONS) or 4
    for index = 1, numButtons do
        local button = _G["LootButton" .. index]
        if button and button.IsShown and button:IsShown() then
            SkinLootButtonBySlot(button, index)
            skinned = true
        end
    end

    -- Midnight may use ScrollBox of loot elements instead of LootButtonN.
    if not skinned then
        local frame = _G.LootFrame
        local scrollBox = frame and frame.ScrollBox
        if scrollBox and scrollBox.GetFrames then
            local frames = scrollBox:GetFrames()
            if frames then
                for index, button in ipairs(frames) do
                    SkinLootButtonBySlot(button, index)
                end
            end
        end
    end

    ApplyMoneyLineSkin()
end

local function ApplyPersonalLootSkin()
    if not skinActive then return end
    local frame = _G.LootFrame
    if not frame then return end

    -- Strip before chrome so BACKGROUND/BORDER hide does not clear our textures.
    Y.SkinStripDefaultArt(frame)
    local ar, ag, ab = GetLootAccentColor()
    local style = Y.GetToastStyle and Y.GetToastStyle() or "framed"
    Y.SkinApplyWindowChrome(frame, style, ar, ag, ab)

    local fontPath = Y.GetFontPath and Y.GetFontPath() or "Fonts\\FRIZQT__.TTF"
    local title = frame.TitleText or _G.LootFrameTitleText
    if not title and frame.TitleContainer then
        title = frame.TitleContainer.TitleText
    end
    if title and title.SetFont then
        pcall(title.SetFont, title, fontPath, S(14), "OUTLINE")
        title:SetTextColor(ar, ag, ab, 1)
    end

    ApplyLootSlotsSkin()
end

local function InstallHooks()
    if hooksInstalled then return end
    local frame = _G.LootFrame
    if not frame then return end

    frame:HookScript("OnShow", function()
        if skinActive then ApplyPersonalLootSkin() end
    end)

    if _G.LootFrame_Update then
        hooksecurefunc("LootFrame_Update", function()
            if skinActive then ApplyPersonalLootSkin() end
        end)
    elseif frame.Update then
        hooksecurefunc(frame, "Update", function()
            if skinActive then ApplyPersonalLootSkin() end
        end)
    end

    hooksInstalled = true
end

--- Re-apply loot window skin (chrome + slot rows) when LootFrame is shown.
--- @return nil
function Y.RefreshLootWindowSkin()
    local frame = _G.LootFrame
    if frame and frame.IsShown and frame:IsShown() then
        ApplyPersonalLootSkin()
    end
end

--- Enable personal loot window skin and install show/update hooks.
--- @return nil
function Y.EnableLootWindowSkin()
    skinActive = true
    if _G.LootFrame then
        InstallHooks()
        if _G.LootFrame:IsShown() then ApplyPersonalLootSkin() end
    end
end

-- Best-effort: hide icon pads and re-Show IconBorder/NormalTexture on loot slots.
local function RestoreLootButtonArt(button)
    if not button then return end
    if button._hsIconPad and button._hsIconPad.Hide then
        button._hsIconPad:Hide()
    end
    local border = button.IconBorder or button.NormalTexture
    if border and border.Show then
        pcall(border.Show, border)
    end
end

local function RestoreLootSlotArt()
    local numButtons = (_G.LOOTFRAME_NUMBUTTONS) or 4
    for index = 1, numButtons do
        RestoreLootButtonArt(_G["LootButton" .. index])
    end
    local frame = _G.LootFrame
    local scrollBox = frame and frame.ScrollBox
    if scrollBox and scrollBox.GetFrames then
        local frames = scrollBox:GetFrames()
        if frames then
            for _, button in ipairs(frames) do
                RestoreLootButtonArt(button)
            end
        end
    end
end

--- Disable personal loot window skin and best-effort restore Blizzard art.
--- hooksInstalled stays true (hooksecurefunc cannot unhook); skinActive gates work.
--- @return nil
function Y.DisableLootWindowSkin()
    skinActive = false
    for region, wasShown in pairs(savedRegions) do
        if wasShown and region and region.Show then pcall(region.Show, region) end
    end
    wipe(savedRegions)
    local frame = _G.LootFrame
    if frame then
        if frame._hsAugmentChromeStrip then frame._hsAugmentChromeStrip:Hide() end
        if frame._hsAugmentChromeBg then frame._hsAugmentChromeBg:Hide() end
        ClearWindowBackdrop(frame)
    end
    RestoreLootSlotArt()
end
