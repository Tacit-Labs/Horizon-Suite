--[[
    Horizon Suite — Vista Drawer Icon Picker
    Searchable icon grid modal for selecting the Vista drawer button icon.
    Exposed as addon.OpenVistaDrawerIconPicker() — called from OptionsVista.lua.
]]

local addon = _G.HorizonSuite
if not addon then return end

local L = addon.L
local Def = addon.OptionsWidgetsDef or {}

local SetTextColor = addon.SetTextColor or function(obj, color)
    if not color or not obj then return end
    obj:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) return addon.OptionsData_SetDB(k, v) end
local function notifyMainAddon() return addon.OptionsData_NotifyMainAddon() end

local vistaDrawerIconPickerFrame
function addon.OpenVistaDrawerIconPicker()
    local icons = {}
    local usingIconBrowserData = false
    local LRPMedia
    if LibStub and LibStub.GetLibrary then
        local ok, lib = pcall(LibStub.GetLibrary, LibStub, "LibRPMedia-1.2", true)
        if ok then LRPMedia = lib end
    end
    if LRPMedia and LRPMedia.EnumerateIcons then
        local ok, iterator = pcall(LRPMedia.EnumerateIcons, LRPMedia, { reuseTable = {} })
        if ok and type(iterator) == "function" then
            for _, info in iterator do
                if info and info.file then
                    icons[#icons + 1] = { file = info.file, name = info.name }
                end
            end
            usingIconBrowserData = #icons > 0
        end
    end
    if #icons == 0 then
        local macroIcons = {}
        if C_Macro and C_Macro.GetMacroIcons then
            local ok, result = pcall(C_Macro.GetMacroIcons)
            if ok and type(result) == "table" then macroIcons = result end
            if #macroIcons == 0 then pcall(C_Macro.GetMacroIcons, macroIcons) end
        end
        if #macroIcons == 0 and GetMacroIcons then
            pcall(GetMacroIcons, macroIcons)
        end
        if #macroIcons == 0 then
            macroIcons = { 134400, 135994, 236884, 132331, 132349, 132350, 132851, 133015, 133446, 134414, 135725, 136011 }
        end
        for _, icon in ipairs(macroIcons) do
            icons[#icons + 1] = { file = icon }
        end
    end

    local function getIconFile(icon)
        return type(icon) == "table" and icon.file or icon
    end

    local function getIconName(icon)
        return type(icon) == "table" and icon.name or nil
    end

    local iconPathAugment = {}
    local function getIconPathText(icon)
        local file = getIconFile(icon)
        local cached = iconPathAugment[file]
        if cached ~= nil then return cached end
        local path
        if type(file) == "number" and C_Texture and C_Texture.GetFilenameFromFileDataID then
            local ok, result = pcall(C_Texture.GetFilenameFromFileDataID, file)
            if ok and result and result ~= "" then
                path = tostring(result)
            end
        elseif type(file) == "string" then
            path = file:gsub("/", "\\")
        end
        iconPathAugment[file] = path or false
        return path
    end

    local iconSearchAugment = {}
    local function getIconSearchText(icon)
        local file = getIconFile(icon)
        local cached = iconSearchAugment[file]
        if cached then return cached end
        local text = tostring(file or "")
        local name = getIconName(icon)
        if name then text = text .. " " .. name end
        local path = getIconPathText(icon)
        if path then text = text .. " " .. path end
        text = text:lower()
        text = text .. " " .. text:gsub("[^%w]+", "")
        iconSearchAugment[file] = text
        return text
    end

    local cols, rows = 8, 6
    local iconSize, gap = 38, 8
    local pageSize = cols * rows
    local filtered = icons
    local offset = 0
    local pendingIcon = getDB("vistaDrawerIcon", nil)

    if not vistaDrawerIconPickerFrame then
        local pf = CreateFrame("Frame", "HorizonSuiteVistaDrawerIconPicker", UIParent, "BackdropTemplate")
        vistaDrawerIconPickerFrame = pf
        pf:SetSize(cols * (iconSize + gap) + 38, rows * (iconSize + gap) + 112)
        pf:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        pf:SetFrameStrata("DIALOG")
        pf:SetFrameLevel(900)
        pf:EnableMouse(true)
        pf:SetMovable(true)
        pf:RegisterForDrag("LeftButton")
        pf:SetClampedToScreen(true)
        pf:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        pf:SetBackdropColor(0.04, 0.04, 0.06, 0.98)
        pf:SetBackdropBorderColor(0.25, 0.28, 0.36, 0.95)
        pf:SetScript("OnDragStart", function(self) self:StartMoving() end)
        pf:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

        pf.title = pf:CreateFontString(nil, "OVERLAY")
        pf.title:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        SetTextColor(pf.title, Def.TextColorTitleBar or { 0.9, 0.92, 0.96, 1 })
        pf.title:SetPoint("TOPLEFT", pf, "TOPLEFT", 14, -12)
        pf.title:SetText(L["VISTA_DRAWER_BUTTON_ICON"])

        pf.close = CreateFrame("Button", nil, pf)
        pf.close:SetSize(22, 22)
        pf.close:SetPoint("TOPRIGHT", pf, "TOPRIGHT", -10, -10)
        pf.close.text = pf.close:CreateFontString(nil, "OVERLAY")
        pf.close.text:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        pf.close.text:SetPoint("CENTER")
        pf.close.text:SetText("x")
        SetTextColor(pf.close.text, Def.TextColorLabel or { 0.84, 0.84, 0.88, 1 })
        pf.close:SetScript("OnClick", function() pf:Hide() end)

        pf.search = CreateFrame("EditBox", nil, pf)
        pf.search:SetHeight(24)
        pf.search:SetPoint("TOPLEFT", pf, "TOPLEFT", 14, -40)
        pf.search:SetPoint("TOPRIGHT", pf, "TOPRIGHT", -24, -40)
        pf.search:SetAutoFocus(false)
        pf.search:SetTextInsets(8, 8, 0, 0)
        pf.search:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
        local tc = Def.TextColorLabel or { 0.84, 0.84, 0.88, 1 }
        pf.search:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
        local searchBg = pf.search:CreateTexture(nil, "BACKGROUND")
        searchBg:SetAllPoints(pf.search)
        local inputBg = Def.InputBg or { 0.07, 0.07, 0.1, 0.96 }
        searchBg:SetColorTexture(inputBg[1], inputBg[2], inputBg[3], inputBg[4])
        if addon.CreateBorder then addon.CreateBorder(pf.search, Def.InputBorder or { 0.2, 0.22, 0.28, 0.3 }) end
        pf.search.placeholder = pf.search:CreateFontString(nil, "OVERLAY")
        pf.search.placeholder:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
        pf.search.placeholder:SetPoint("LEFT", pf.search, "LEFT", 8, 0)
        SetTextColor(pf.search.placeholder, Def.TextColorSection or { 0.58, 0.64, 0.74, 1 })
        pf.searchClear = CreateFrame("Button", nil, pf)
        pf.searchClear:SetSize(18, 18)
        pf.searchClear:SetPoint("RIGHT", pf.search, "RIGHT", -4, 0)
        pf.searchClear:SetFrameLevel((pf.search:GetFrameLevel() or pf:GetFrameLevel() or 1) + 5)
        pf.searchClear.text = pf.searchClear:CreateFontString(nil, "OVERLAY")
        pf.searchClear.text:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        pf.searchClear.text:SetPoint("CENTER")
        pf.searchClear.text:SetText("x")
        SetTextColor(pf.searchClear.text, Def.TextColorSection or { 0.58, 0.64, 0.74, 1 })
        pf.searchClear:SetScript("OnClick", function()
            pf.search:SetText("")
            pf.search:SetFocus()
        end)
        pf.searchClear:SetScript("OnEnter", function()
            SetTextColor(pf.searchClear.text, Def.TextColorLabel or { 0.84, 0.84, 0.88, 1 })
        end)
        pf.searchClear:SetScript("OnLeave", function()
            SetTextColor(pf.searchClear.text, Def.TextColorSection or { 0.58, 0.64, 0.74, 1 })
        end)
        pf.searchClear:Hide()

        pf.grid = CreateFrame("Frame", nil, pf)
        pf.grid:SetPoint("TOPLEFT", pf.search, "BOTTOMLEFT", 0, -14)
        pf.grid:SetPoint("BOTTOMRIGHT", pf, "BOTTOMRIGHT", -24, 42)
        pf.grid:EnableMouseWheel(true)
        pf.scrollTrack = CreateFrame("Frame", nil, pf)
        pf.scrollTrack:SetWidth(12)
        pf.scrollTrack:SetPoint("TOPLEFT", pf.grid, "TOPRIGHT", 6, 0)
        pf.scrollTrack:SetPoint("BOTTOMLEFT", pf.grid, "BOTTOMRIGHT", 6, 0)
        pf.scrollTrack:EnableMouse(true)
        pf.scrollThumb = pf.scrollTrack:CreateTexture(nil, "OVERLAY")
        pf.scrollThumb:SetWidth(4)
        pf.scrollThumb:SetColorTexture(1, 1, 1, 0.2)
        pf.scrollSlider = CreateFrame("Slider", nil, pf.scrollTrack)
        pf.scrollSlider:SetAllPoints(pf.scrollTrack)
        pf.scrollSlider:SetOrientation("VERTICAL")
        pf.scrollSlider:SetMinMaxValues(0, 1)
        pf.scrollSlider:SetValueStep(1)
        pf.scrollSlider:SetObeyStepOnDrag(true)
        pf.scrollSlider:SetThumbTexture(pf.scrollThumb)
        pf.scrollSlider:SetFrameLevel(pf:GetFrameLevel() + 5)
        pf.buttons = {}
        for i = 1, pageSize do
            local b = CreateFrame("Button", nil, pf.grid)
            b:SetSize(iconSize, iconSize)
            local col = (i - 1) % cols
            local rowIdx = math.floor((i - 1) / cols)
            b:SetPoint("TOPLEFT", pf.grid, "TOPLEFT", col * (iconSize + gap), -rowIdx * (iconSize + gap))
            b.bg = b:CreateTexture(nil, "BACKGROUND")
            b.bg:SetAllPoints(b)
            b.bg:SetColorTexture(0.02, 0.02, 0.025, 0.9)
            b.icon = b:CreateTexture(nil, "ARTWORK")
            b.icon:SetPoint("CENTER")
            b.icon:SetSize(iconSize - 6, iconSize - 6)
            b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            b.border = addon.CreateBorder and { addon.CreateBorder(b, Def.InputBorder or { 0.2, 0.22, 0.28, 0.3 }) } or {}
            b:SetScript("OnEnter", function(self)
                if not self._iconValue or not GameTooltip then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local name = getIconName(self._iconRecord)
                GameTooltip:SetText(name or ("Icon ID " .. tostring(self._iconValue)), 1, 1, 1)
                if name then
                    GameTooltip:AddLine("Icon ID " .. tostring(self._iconValue), 0.44, 0.83, 1)
                end
                local path = getIconPathText(self._iconRecord)
                if path and tostring(path) ~= ("FileData ID " .. tostring(self._iconValue)) then
                    GameTooltip:AddLine(path, 0.72, 0.78, 0.9, true)
                end
                GameTooltip:Show()
            end)
            b:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
            pf.buttons[i] = b
        end

        pf.footer = pf:CreateFontString(nil, "OVERLAY")
        pf.footer:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 10, "OUTLINE")
        SetTextColor(pf.footer, Def.TextColorSection or { 0.58, 0.64, 0.74, 1 })
        pf.footer:SetPoint("BOTTOMLEFT", pf, "BOTTOMLEFT", 14, 14)
        pf.footer:SetPoint("RIGHT", pf, "RIGHT", -108, 0)
        pf.footer:SetJustifyH("LEFT")

        pf.apply = CreateFrame("Button", nil, pf)
        pf.apply:SetSize(82, 24)
        pf.apply:SetPoint("BOTTOMRIGHT", pf, "BOTTOMRIGHT", -14, 10)
        pf.apply.bg = pf.apply:CreateTexture(nil, "BACKGROUND")
        pf.apply.bg:SetAllPoints(pf.apply)
        local accent = Def.AccentColor or { 0.34, 0.48, 0.82, 1 }
        pf.apply.bg:SetColorTexture(accent[1], accent[2], accent[3], 0.65)
        if addon.CreateBorder then addon.CreateBorder(pf.apply, Def.InputBorder or { 0.2, 0.22, 0.28, 0.3 }) end
        pf.apply.text = pf.apply:CreateFontString(nil, "OVERLAY")
        pf.apply.text:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
        pf.apply.text:SetPoint("CENTER")
        pf.apply.text:SetText(L["APPLY"])
        SetTextColor(pf.apply.text, Def.TextColorLabel or { 0.84, 0.84, 0.88, 1 })
    end

    local pf = vistaDrawerIconPickerFrame
    pendingIcon = getDB("vistaDrawerIcon", nil)

    local function sameIcon(a, b)
        return tostring(a or "") == tostring(b or "")
    end

    local function updateScrollThumb()
        if not pf.scrollTrack or not pf.scrollThumb then return end
        local totalRows = math.ceil(#filtered / cols)
        if totalRows <= rows then
            pf.scrollTrack:Hide()
            return
        end
        pf.scrollTrack:Show()
        local maxOffset = math.max(1, totalRows - rows)
        if pf.scrollSlider then
            pf._syncingScrollSlider = true
            pf.scrollSlider:SetMinMaxValues(0, maxOffset)
            pf.scrollSlider:SetValueStep(1)
            pf.scrollSlider:SetValue(offset)
            pf._syncingScrollSlider = false
        end
        local trackH = pf.scrollTrack:GetHeight() or 1
        local thumbPct = rows / totalRows
        local thumbH = math.max(24, trackH * thumbPct)
        pf.scrollThumb:SetHeight(thumbH)
    end

    local function updateGrid()
        local maxOffset = math.max(0, math.ceil(#filtered / cols) - rows)
        offset = math.max(0, math.min(offset, maxOffset))
        for i, b in ipairs(pf.buttons) do
            local index = offset * cols + i
            local icon = filtered[index]
            local file = getIconFile(icon)
            b._iconRecord = icon
            b._iconValue = file
            if icon then
                b.icon:SetTexture(file)
                b:Show()
                local isSelected = sameIcon(file, pendingIcon)
                for _, tex in ipairs(b.border or {}) do
                    tex:SetColorTexture(isSelected and 1 or 0.2, isSelected and 0.82 or 0.22, isSelected and 0.15 or 0.28, isSelected and 1 or 0.5)
                end
            else
                b._iconRecord = nil
                b._iconValue = nil
                b:Hide()
            end
        end
        pf.footer:SetText(string.format("%d icons%s%s", #filtered, usingIconBrowserData and " from IconBrowser" or "", #filtered > pageSize and " - mouse wheel to scroll" or ""))
        if pf.apply then
            local changed = not sameIcon(pendingIcon, getDB("vistaDrawerIcon", nil))
            pf.apply:SetAlpha(changed and 1 or 0.55)
        end
        updateScrollThumb()
    end

    local function applyFilter()
        local raw = pf.search:GetText() or ""
        if pf.search.placeholder then
            pf.search.placeholder:SetShown(raw == "")
        end
        if pf.searchClear then
            pf.searchClear:SetShown(raw ~= "")
        end
        local q = raw:gsub("^%s+", ""):gsub("%s+$", "")
        local needle = q:lower()
        local compactNeedle = needle:gsub("[^%w]+", "")
        if needle == "" then
            filtered = icons
        else
            filtered = {}
            for _, icon in ipairs(icons) do
                local searchText = getIconSearchText(icon)
                if searchText:find(needle, 1, true) or (compactNeedle ~= "" and searchText:find(compactNeedle, 1, true)) then
                    filtered[#filtered + 1] = icon
                end
            end
            local numericIcon = tonumber(compactNeedle)
            if numericIcon and #filtered == 0 then
                filtered[1] = { file = numericIcon }
            elseif #filtered == 0 and q ~= "" then
                local iconPath = q:gsub("/", "\\")
                if not iconPath:find("\\", 1, true) then
                    iconPath = "Interface\\Icons\\" .. iconPath
                end
                filtered[1] = { file = iconPath, name = q }
            end
        end
        offset = 0
        updateGrid()
    end

    for _, b in ipairs(pf.buttons) do
        b:SetScript("OnClick", function(self)
            if not self._iconValue then return end
            pendingIcon = self._iconValue
            updateGrid()
        end)
    end
    if pf.apply then
        pf.apply:SetScript("OnClick", function()
            if not pendingIcon then return end
            setDB("vistaDrawerIcon", pendingIcon)
            notifyMainAddon()
            pf:Hide()
        end)
    end
    pf.grid:SetScript("OnMouseWheel", function(_, delta)
        offset = offset - delta
        updateGrid()
    end)
    if pf.scrollSlider then
        pf.scrollSlider:SetScript("OnValueChanged", function(_, value)
            if pf._syncingScrollSlider then return end
            local totalRows = math.ceil(#filtered / cols)
            local maxOffset = math.max(0, totalRows - rows)
            offset = math.max(0, math.min(maxOffset, math.floor((value or 0) + 0.5)))
            updateGrid()
        end)
        pf.scrollSlider:SetScript("OnMouseWheel", function(_, delta)
            offset = offset - delta
            updateGrid()
        end)
    end
    pf.search:SetScript("OnTextChanged", applyFilter)
    pf.search:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        pf:Hide()
    end)
    if pf.search.placeholder then
        pf.search.placeholder:SetText(usingIconBrowserData and "Type name or icon ID" or "Type icon ID")
        pf.search.placeholder:Show()
    end
    if pf.searchClear then
        pf.searchClear:Hide()
    end
    pf.search:SetText("")
    filtered = icons
    offset = 0
    updateGrid()
    pf:Show()
end
