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

local hooksInstalled = false
local skinActive = false
local savedRegions = {}  -- [region] = { shown = bool, ... } for best-effort restore

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
            if savedRegions[region] == nil then
                savedRegions[region] = true
            end
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
                    if savedRegions[r] == nil then savedRegions[r] = true end
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
        strip:SetWidth(3)
        strip:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        strip:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
        frame._hsAugmentChromeStrip = strip
    end
    local strip = frame._hsAugmentChromeStrip

    if style == "framed" then
        ClearWindowBackdrop(frame) -- reset then re-apply framed backdrop below
        if frame._hsAugmentChromeBg then
            frame._hsAugmentChromeBg:Hide()
        end
        local backdropHost = GetBackdropHost(frame)
        if backdropHost.SetBackdrop then
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

-- Slot chrome filled in Task 4.
local function ApplyLootSlotsSkin()
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
        pcall(title.SetFont, title, fontPath, 14, "OUTLINE")
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

--- Re-apply loot window skin (chrome + slots when Task 4 lands).
--- @return nil
function Y.RefreshLootWindowSkin()
    ApplyPersonalLootSkin()
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

--- Disable personal loot window skin (restore in Task 5).
--- @return nil
function Y.DisableLootWindowSkin()
    skinActive = false
    -- restore in Task 5
end
