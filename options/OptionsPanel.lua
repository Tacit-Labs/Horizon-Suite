--[[
    Horizon Suite - Focus - Options Panel
    Main panel frame, title bar, search bar, sidebar, content scroll, BuildCategory, FilterBySearch, animations.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.OptionCategories then return end

local L = addon.L
local Def = addon.OptionsWidgetsDef or {}
local PAGE_WIDTH = 720
local PAGE_HEIGHT = 600
local SIDEBAR_WIDTH = 220
local PADDING = Def.Padding or 18
local SCROLL_STEP = 44
local HEADER_HEIGHT = PADDING + (Def.HeaderSize or 16) + 10 + 2
local DIVIDER_HEIGHT = 1
local OptionGap = Def.OptionGap or 14
local SectionGap = Def.SectionGap or 24
local CardPadding = Def.CardPadding or 18
local CardBottomPadding = Def.CardBottomPadding or Def.CardPadding or 26
local RowHeights = { sectionLabel = 14, toggle = 40, slider = 40, dropdown = 52, colorRow = 28, reorder = 24 }

local SetTextColor = addon.SetTextColor or function(obj, color)
    if not color or not obj then return end
    obj:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function getDB(k, d) return addon.OptionsData_GetDB(k, d) end
local function setDB(k, v) return addon.OptionsData_SetDB(k, v) end
local function notifyMainAddon() return addon.OptionsData_NotifyMainAddon() end

-- Card collapse state: default collapsed (true) when key not in table; sectionDefaultCollapsed overrides when key absent
local cardCollapsed = (_G[addon.DB_NAME] and _G[addon.DB_NAME].optionsCardCollapsed) or {}
local sectionDefaultCollapsed = {}
local function GetCardCollapsed(sectionKey)
    if cardCollapsed[sectionKey] ~= nil then return cardCollapsed[sectionKey] end
    return sectionDefaultCollapsed[sectionKey] or true
end
local function SetCardCollapsed(sectionKey, v)
    cardCollapsed[sectionKey] = v
    local db = _G[addon.DB_NAME]
    if db then db.optionsCardCollapsed = cardCollapsed end
end

-- ---------------------------------------------------------------------------
-- Panel frame
-- ---------------------------------------------------------------------------
local panel = CreateFrame("Frame", "HorizonSuiteOptionsPanel", UIParent)
panel.name = "Horizon Suite"
panel:SetSize(PAGE_WIDTH, PAGE_HEIGHT)
panel:SetFrameStrata("DIALOG")
panel:SetClampedToScreen(true)
panel:SetMovable(true)
panel:EnableMouse(true)
-- Drag is owned by titleBar only; panel has no RegisterForDrag to avoid drag from body
panel:Hide()

-- ESC handling: first ESC closes any open dropdown, second ESC closes the panel.
-- When a dropdown opens, we remove the panel from UISpecialFrames so ESC only closes the dropdown.
-- When the dropdown closes, we add the panel back so the next ESC closes the panel.
addon._OpenDropdowns = addon._OpenDropdowns or {}
addon._CloseAnyOpenDropdown = function()
    local toClose = {}
    for closeFunc in next, addon._OpenDropdowns do
        toClose[#toClose + 1] = closeFunc
    end
    addon._OpenDropdowns = {}
    for _, f in ipairs(toClose) do f() end
    return #toClose > 0
end

local panelName = nil
addon._OnDropdownOpened = function(closeFunc)
    addon._OpenDropdowns[closeFunc] = true
    if _G.UISpecialFrames and panelName then
        for i = #_G.UISpecialFrames, 1, -1 do
            if _G.UISpecialFrames[i] == panelName then
                table.remove(_G.UISpecialFrames, i)
                break
            end
        end
    end
end
addon._OnDropdownClosed = function(closeFunc)
    addon._OpenDropdowns[closeFunc] = nil
    if _G.UISpecialFrames and panelName then
        local exists = false
        for i = 1, #_G.UISpecialFrames do
            if _G.UISpecialFrames[i] == panelName then exists = true break end
        end
        if not exists then
            tinsert(_G.UISpecialFrames, 1, panelName)
        end
    end
end

-- Title bar drag: stop helper defined before OnHide so closure can call it
local isDraggingPanel = false
local function StopPanelDrag()
    if not isDraggingPanel then return end
    isDraggingPanel = false
    panel:SetScript("OnUpdate", nil)
    local db = _G[addon.DB_NAME]
    if InCombatLockdown() then
        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_REGEN_ENABLED")
        f:SetScript("OnEvent", function(self, event)
            self:UnregisterEvent(event)
            self:SetScript("OnEvent", nil)
            if not InCombatLockdown() then
                panel:StopMovingOrSizing()
                db = _G[addon.DB_NAME]
                if db then
                    local x, y = panel:GetCenter()
                    local uix, uiy = UIParent:GetCenter()
                    db.optionsLeft = x - uix
                    db.optionsTop = y - uiy
                end
            end
        end)
        return
    end
    panel:StopMovingOrSizing()
    if db then
        local x, y = panel:GetCenter()
        local uix, uiy = UIParent:GetCenter()
        db.optionsLeft = x - uix
        db.optionsTop = y - uiy
    end
end

panel:HookScript("OnHide", function()
    StopPanelDrag()
    if addon._CloseAnyOpenDropdown then addon._CloseAnyOpenDropdown() end
end)

do
    -- Ensure panel is in UISpecialFrames exactly once.
    if _G.UISpecialFrames then
        panelName = panel:GetName()
        local exists = false
        for i = 1, #_G.UISpecialFrames do
            if _G.UISpecialFrames[i] == panelName then exists = true break end
        end
        if not exists then
            tinsert(_G.UISpecialFrames, 1, panelName)
        end
    end
end

local bg = panel:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(panel)
local sb = Def.SectionCardBg or { 0.09, 0.09, 0.11, 0.96 }
bg:SetColorTexture(sb[1], sb[2], sb[3], sb[4] or 0.97)
local bc = Def.BorderColor or Def.SectionCardBorder
addon.CreateBorder(panel, bc)

-- Title bar drag: owned by titleBar only. Defensive stop when mouse released elsewhere.
local function DragStopOnUpdate(self)
    if not isDraggingPanel then self:SetScript("OnUpdate", nil) return end
    if not IsMouseButtonDown("LeftButton") then
        StopPanelDrag()
    end
end

local titleBar = CreateFrame("Frame", nil, panel)
titleBar:SetPoint("TOPLEFT", 0, 0)
titleBar:SetPoint("TOPRIGHT", 0, 0)
titleBar:SetHeight(HEADER_HEIGHT)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function()
    if InCombatLockdown() then return end
    isDraggingPanel = true
    panel:StartMoving()
    panel:SetScript("OnUpdate", DragStopOnUpdate)
end)
titleBar:SetScript("OnDragStop", function()
    StopPanelDrag()
end)
local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
titleBg:SetAllPoints(titleBar)
titleBg:SetColorTexture(0.07, 0.07, 0.09, 0.96)
local titleText = titleBar:CreateFontString(nil, "OVERLAY")
titleText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.HeaderSize or 16, "OUTLINE")
SetTextColor(titleText, Def.TextColorTitleBar or Def.TextColorNormal)
titleText:SetPoint("TOPLEFT", titleBar, "TOPLEFT", PADDING, -PADDING)
titleText:SetText(L["HORIZON SUITE"])
local closeBtn = CreateFrame("Button", nil, panel)
closeBtn:SetSize(28, 28)
closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -10)
closeBtn:SetFrameLevel(titleBar:GetFrameLevel() + 2)
local closeBtnBg = closeBtn:CreateTexture(nil, "BACKGROUND")
closeBtnBg:SetAllPoints(closeBtn)
closeBtnBg:SetColorTexture(0.12, 0.12, 0.15, 0.5)
closeBtnBg:Hide()
local closeLabel = closeBtn:CreateFontString(nil, "OVERLAY")
closeLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
SetTextColor(closeLabel, Def.TextColorSection)
closeLabel:SetText("X")
closeLabel:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
closeBtn:SetScript("OnClick", function()
    if _G.HorizonSuite_OptionsRequestClose then _G.HorizonSuite_OptionsRequestClose()
    elseif addon.OptionsRequestClose then addon.OptionsRequestClose()
    else panel:Hide() end
end)
closeBtn:SetScript("OnEnter", function()
    closeBtnBg:Show()
    SetTextColor(closeLabel, Def.TextColorHighlight)
end)
closeBtn:SetScript("OnLeave", function()
    closeBtnBg:Hide()
    SetTextColor(closeLabel, Def.TextColorSection)
end)
local divider = panel:CreateTexture(nil, "ARTWORK")
divider:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
divider:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
divider:SetHeight(DIVIDER_HEIGHT)
local dc = Def.DividerColor or Def.AccentColor
divider:SetColorTexture(dc[1], dc[2], dc[3], dc[4] or 0.25)

-- Search bar (FilterBySearch defined below after tabFrames/tabButtons exist)
local searchRow = CreateFrame("Frame", nil, panel)
searchRow:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING + SIDEBAR_WIDTH + 12, -(HEADER_HEIGHT + 6))
searchRow:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PADDING, 0)
searchRow:SetHeight(36)

-- Sidebar
local sidebar = CreateFrame("Frame", nil, panel)
sidebar:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING, -(HEADER_HEIGHT + 6))
sidebar:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PADDING, PADDING)
sidebar:SetWidth(SIDEBAR_WIDTH)
local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
sidebarBg:SetAllPoints(sidebar)
sidebarBg:SetColorTexture(0.07, 0.07, 0.09, 0.96)

-- Scrollable sidebar content (category list)
local sidebarScrollFrame = CreateFrame("ScrollFrame", nil, sidebar)
sidebarScrollFrame:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, 0)
sidebarScrollFrame:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", 0, 0)
-- Leave room for the version label at the bottom.
sidebarScrollFrame:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 0, 30)
sidebarScrollFrame:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", 0, 30)
sidebarScrollFrame:EnableMouseWheel(true)
sidebarScrollFrame:SetClipsChildren(true)

local sidebarScrollChild = CreateFrame("Frame", nil, sidebarScrollFrame)
sidebarScrollChild:SetWidth(SIDEBAR_WIDTH)
sidebarScrollChild:SetHeight(1)
sidebarScrollFrame:SetScrollChild(sidebarScrollChild)

local function SidebarScrollBy(delta)
    local cur = sidebarScrollFrame:GetVerticalScroll() or 0
    local childH = sidebarScrollChild:GetHeight() or 0
    local frameH = sidebarScrollFrame:GetHeight() or 0
    local maxScr = math.max(0, childH - frameH)
    sidebarScrollFrame:SetVerticalScroll(math.max(0, math.min(cur - delta * 24, maxScr)))
end
sidebarScrollFrame:SetScript("OnMouseWheel", function(_, delta) SidebarScrollBy(delta) end)
sidebar:SetScript("OnMouseWheel", function(_, delta) SidebarScrollBy(delta) end)

-- Sidebar content parent (all buttons/rows should be parented here)
local sidebarContent = sidebarScrollChild

local tabButtons = {}
local selectedTab = 1
local contentWidth = PAGE_WIDTH - PADDING * 2 - SIDEBAR_WIDTH - 12

-- Scroll + content
local scrollFrame = CreateFrame("ScrollFrame", nil, panel)
scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING + SIDEBAR_WIDTH + 12, -(HEADER_HEIGHT + 6 + 40))
scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PADDING, PADDING)
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(_, delta)
    local cur = scrollFrame:GetVerticalScroll()
    local childH = scrollFrame:GetScrollChild() and scrollFrame:GetScrollChild():GetHeight() or 0
    local frameH = scrollFrame:GetHeight() or 0
    scrollFrame:SetVerticalScroll(math.max(0, math.min(cur - delta * SCROLL_STEP, math.max(0, childH - frameH))))
end)

local tabFrames = {}
for i = 1, #addon.OptionCategories do
    local f = CreateFrame("Frame", nil, panel)
    f:SetSize(contentWidth, 100)  -- height updated after BuildCategory
    local top = CreateFrame("Frame", nil, f)
    top:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    top:SetSize(1, 1)
    f.topAnchor = top
    tabFrames[i] = f
end

-- Recalculate a tab frame's height from its card children so scroll stops at content end.
local function ResizeTabFrame(f)
    if not f then return end
    local maxBottom = 0
    local fTop = f:GetTop()
    if not fTop then return end
    for _, child in ipairs({ f:GetChildren() }) do
        local b = child:GetBottom()
        if b then
            local offset = fTop - b
            if offset > maxBottom then maxBottom = offset end
        end
    end
    f:SetHeight(math.max(100, maxBottom + PADDING))
end
_G.ResizeTabFrame = ResizeTabFrame

scrollFrame:SetScrollChild(tabFrames[1])
for i = 2, #tabFrames do tabFrames[i]:Hide() end

-- Version at bottom of sidebar
-- Resize handle: drag bottom-right corner to resize options panel
local resizeHandle = CreateFrame("Frame", nil, panel)
resizeHandle:SetSize(20, 20)
resizeHandle:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
resizeHandle:EnableMouse(true)
resizeHandle:SetFrameLevel(panel:GetFrameLevel() + 10)
resizeHandle:SetScript("OnEnter", function(self)
    if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(L["Drag to resize"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end
end)
resizeHandle:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
end)
local isResizing = false
local startWidth, startHeight, startMouseX, startMouseY
resizeHandle:RegisterForDrag("LeftButton")
local function ApplyPanelDimensions()
    local width = panel:GetWidth() or PAGE_WIDTH
    local height = panel:GetHeight() or PAGE_HEIGHT
    PAGE_WIDTH = width
    PAGE_HEIGHT = height

    -- Keep tab/card content flush with current panel width.
    local newContentWidth = width - PADDING * 2 - SIDEBAR_WIDTH - 12
    for _, tabFrame in ipairs(tabFrames) do
        if tabFrame then
            tabFrame:SetWidth(newContentWidth)
        end
    end

    -- Update blacklist grid height dynamically when the window size changes.
    if addon.blacklistGridCard then
        local card = addon.blacklistGridCard
        local minHeight = 450
        local dynamicHeight = math.max(minHeight, PAGE_HEIGHT - 300)
        local headerPart = card.headerHeight or (CardPadding + 24)
        card.contentHeight = headerPart + OptionGap + dynamicHeight
        local fullH = card.contentHeight + CardBottomPadding
        card.fullHeight = fullH
        if card.contentContainer then
            local contentH = math.max(1, card.contentHeight - card.headerHeight)
            card.contentContainer:SetHeight(contentH)
        end
        local collapsed = card.sectionKey and GetCardCollapsed and GetCardCollapsed(card.sectionKey)
        card:SetHeight(collapsed and card.headerHeight or fullH)
        if card.updateScrollBars then
            card.updateScrollBars()
        end
    end
end
local function ResizeOnUpdate(self, elapsed)
    if not isResizing then return end
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    local curX = select(1, GetCursorPosition()) / scale
    local curY = select(2, GetCursorPosition()) / scale
    local deltaX = curX - startMouseX
    local deltaY = curY - startMouseY
    local newWidth = math.max(600, math.min(1400, startWidth + deltaX))
    local newHeight = math.max(500, math.min(1200, startHeight - deltaY))
    panel:SetSize(newWidth, newHeight)
    ApplyPanelDimensions()
end
resizeHandle:SetScript("OnDragStart", function(self)
    isResizing = true
    startWidth = panel:GetWidth()
    startHeight = panel:GetHeight()
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    startMouseX = select(1, GetCursorPosition()) / scale
    startMouseY = select(2, GetCursorPosition()) / scale
    self:SetScript("OnUpdate", ResizeOnUpdate)
end)
resizeHandle:SetScript("OnDragStop", function(self)
    if not isResizing then return end
    isResizing = false
    self:SetScript("OnUpdate", nil)
    local db = _G[addon.DB_NAME]
    if db then
        db.optionsPanelWidth = panel:GetWidth()
        db.optionsPanelHeight = panel:GetHeight()
    end
end)

-- Sleek L-shaped corner grip indicator
local gripR, gripG, gripB, gripA = 0.55, 0.56, 0.6, 0.65
local resizeLineH = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeLineH:SetSize(12, 2)
resizeLineH:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)
resizeLineH:SetColorTexture(gripR, gripG, gripB, gripA)
local resizeLineV = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeLineV:SetSize(2, 12)
resizeLineV:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)
resizeLineV:SetColorTexture(gripR, gripG, gripB, gripA)

local versionLabel = sidebar:CreateFontString(nil, "OVERLAY")
versionLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 10, "OUTLINE")
SetTextColor(versionLabel, Def.TextColorSection)
versionLabel:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 10, 10)
local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local versionText = getMetadata and getMetadata(addon.ADDON_NAME or "HorizonSuite", "Version")
if versionText and versionText ~= "" then
    versionLabel:SetText("v" .. versionText)
    versionLabel:Show()
else
    versionLabel:Hide()
end

-- ---------------------------------------------------------------------------
-- Build one category's content
-- ---------------------------------------------------------------------------
local allRefreshers = {}
local allCollapsibleCards = {}

local function FinalizeCard(card)
    if not card or not card.contentHeight then return end
    local fullH = card.contentHeight + CardBottomPadding
    card.fullHeight = fullH
    if card.contentContainer and card.sectionKey then
        allCollapsibleCards[#allCollapsibleCards + 1] = card
        local collapsed = GetCardCollapsed(card.sectionKey)
        local contentH = math.max(1, card.contentHeight - card.headerHeight)
        card.contentContainer:SetHeight(contentH)
        card.contentContainer:SetShown(not collapsed)
        card:SetHeight(collapsed and card.headerHeight or fullH)
    else
        card:SetHeight(fullH)
    end
    -- Deferred re-measurement: after widgets measure their wrapped text heights,
    -- recalculate card height to prevent description overlap.
    C_Timer.After(0.05, function()
        if not card or not card.contentContainer then return end
        local cc = card.contentContainer
        local measuredH = 0
        local children = { cc:GetChildren() }
        for _, child in ipairs(children) do
            if child:IsShown() then
                local bottom = child:GetBottom()
                local ccTop = cc:GetTop()
                if bottom and ccTop then
                    local offset = ccTop - bottom
                    if offset > measuredH then measuredH = offset end
                end
            end
        end
        if measuredH > 0 then
            local headerH = card.headerHeight or (CardPadding + 24)
            local newContentH = headerH + measuredH + 4
            if newContentH > card.contentHeight then
                card.contentHeight = newContentH
                local newFullH = newContentH + CardBottomPadding
                card.fullHeight = newFullH
                cc:SetHeight(math.max(1, newContentH - headerH))
                local collapsed = card.sectionKey and GetCardCollapsed(card.sectionKey)
                if not collapsed then
                    card:SetHeight(newFullH)
                end
                local tab = card:GetParent()
                if tab and ResizeTabFrame then ResizeTabFrame(tab) end
            end
        end
    end)
    -- Resize parent tab frame so scroll stops at actual content end
    C_Timer.After(0, function()
        local tab = card:GetParent()
        if tab and ResizeTabFrame then ResizeTabFrame(tab) end
    end)
end

--- Build one options category: section cards, toggles, sliders, dropdowns, color matrix, reorder list; wires get/set and refreshers.
-- @param tab table Tab frame with topAnchor
-- @param tabIndex number Category index (1-based)
-- @param options table Array of option descriptors (type, name, dbKey, get, set, etc.)
-- @param refreshers table Array to which refreshable widgets are appended
-- @param optionFrames table Registry: optionFrames[optionId] = { tabIndex, frame }
local function BuildCategory(tab, tabIndex, options, refreshers, optionFrames)
    local anchor = tab.topAnchor
    local currentCard = nil
    local currentSection = ""
    for _, opt in ipairs(options) do
        if opt.type == "section" then
            currentSection = opt.name or ""
            if currentCard then FinalizeCard(currentCard) end
            local hasHeader = opt.name and opt.name ~= ""
            local sectionKey = hasHeader and (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_")) or nil
            if opt.defaultCollapsed and sectionKey then
                sectionDefaultCollapsed[sectionKey] = true
            end
            currentCard = OptionsWidgets_CreateSectionCard(tab, anchor, sectionKey, GetCardCollapsed, SetCardCollapsed)
            if hasHeader then
                local lbl = OptionsWidgets_CreateSectionHeader(currentCard, opt.name, sectionKey, GetCardCollapsed, SetCardCollapsed)
                currentCard.contentAnchor = lbl
                currentCard.contentHeight = CardPadding + RowHeights.sectionLabel
            else
                local spacer = currentCard:CreateFontString(nil, "OVERLAY")
                spacer:SetPoint("TOPLEFT", currentCard, "TOPLEFT", CardPadding, -CardPadding)
                spacer:SetHeight(0)
                spacer:SetWidth(1)
                currentCard.contentAnchor = spacer
                currentCard.contentHeight = CardPadding
            end
            anchor = currentCard
        elseif opt.type == "header" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local lbl = cardContent:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 11, "OUTLINE")
            SetTextColor(lbl, Def.TextColorSection or { 0.58, 0.64, 0.74 })
            lbl:SetText(opt.name or "")
            lbl:SetJustifyH("LEFT")
            lbl:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            lbl:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = lbl
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 12
        elseif opt.type == "toggle" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local origSet = opt.set
            local setFn = origSet
            if opt.refreshIds and optionFrames then
                setFn = function(v)
                    origSet(v)
                    for _, k in ipairs(opt.refreshIds) do
                        local f = optionFrames[k]
                        if f and f.frame and f.frame.Refresh then f.frame:Refresh() end
                    end
                end
            end
            local w = OptionsWidgets_CreateToggleSwitch(cardContent, opt.name, opt.desc or opt.tooltip, opt.get, setFn, opt.disabled, opt.tooltip)
            w:SetPoint("TOPLEFT", contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            w:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = w
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + RowHeights.toggle
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = w } end
            table.insert(refreshers, w)
        elseif opt.type == "slider" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local origSet = opt.set
            local setFn = origSet
            if opt.refreshIds and optionFrames then
                setFn = function(v)
                    origSet(v)
                    for _, k in ipairs(opt.refreshIds) do
                        local f = optionFrames[k]
                        if f and f.frame and f.frame.Refresh then f.frame:Refresh() end
                    end
                end
            end
            local w = OptionsWidgets_CreateSlider(cardContent, opt.name, opt.desc or opt.tooltip, opt.get, setFn, opt.min, opt.max, opt.disabled, opt.step, opt.tooltip)
            w:SetPoint("TOPLEFT", contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            w:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = w
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + RowHeights.slider
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = w } end
            table.insert(refreshers, w)
        elseif opt.type == "dropdown" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local searchable = (opt.dbKey == "fontPath") or (opt.searchable == true)
            local origSet = opt.set
            local setFn = origSet
            if opt.refreshIds and optionFrames then
                setFn = function(v)
                    origSet(v)
                    for _, k in ipairs(opt.refreshIds) do
                        local f = optionFrames[k]
                        if f and f.frame and f.frame.Refresh then f.frame:Refresh() end
                    end
                end
            end
            local w = OptionsWidgets_CreateCustomDropdown(cardContent, opt.name, opt.desc or opt.tooltip, opt.options or {}, opt.get, setFn, opt.displayFn, searchable, opt.disabled, opt.tooltip)
            w:SetPoint("TOPLEFT", contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            w:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = w
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + RowHeights.dropdown
            w._card = currentCard
            if type(opt.hidden) == "function" then
                w._hiddenFn = opt.hidden
                w._normalHeight = RowHeights.dropdown
                w._parentCard = currentCard
                w._gapHeight = OptionGap
            end
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = w } end
            table.insert(refreshers, w)
        elseif opt.type == "color" and currentCard then
            local def = (opt.default and type(opt.default) == "table" and #opt.default >= 3) and opt.default or addon.HEADER_COLOR
            local hasAlpha = opt.hasAlpha == true
            local getTbl, setKeyVal
            if opt.get and opt.set then
                -- Custom get/set (e.g. M+ R/G/B keys, or RGBA keys)
                getTbl = function()
                    local r, g, b, a = opt.get()
                    if type(r) == "number" and type(g) == "number" and type(b) == "number" then
                        if hasAlpha and type(a) == "number" then
                            return {r, g, b, a}
                        end
                        return {r, g, b}
                    end
                    return nil
                end
                setKeyVal = function(v)
                    local t = type(v) == "table" and v[1] and v[2] and v[3] and v or nil
                    if t then
                        if hasAlpha then
                            opt.set(t[1], t[2], t[3], t[4])
                        else
                            opt.set(t[1], t[2], t[3])
                        end
                    end
                end
            else
                getTbl = function() return getDB(opt.dbKey, nil) end
                setKeyVal = function(v) setDB(opt.dbKey, v) end
            end
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local row = OptionsWidgets_CreateColorSwatchRow(cardContent, contentAnchor, opt.name or "Color", def, getTbl, setKeyVal, notifyMainAddon, nil, hasAlpha, opt.tooltip)
            currentCard.contentAnchor = row
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + RowHeights.colorRow
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = row } end
            table.insert(refreshers, row)
        elseif opt.type == "button" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local btn = OptionsWidgets_CreateButton(cardContent, opt.name or L["Reset"], function()
                if opt.onClick then opt.onClick() end
                if opt.refreshIds and optionFrames then
                    for _, k in ipairs(opt.refreshIds) do
                        local f = optionFrames[k]
                        if f and f.frame and f.frame.Refresh then f.frame:Refresh() end
                    end
                end
                notifyMainAddon()
            end, { height = 22, tooltip = opt.tooltip })
            btn:SetPoint("TOPLEFT", contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            btn:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = btn
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 22
        elseif opt.type == "editbox" and currentCard then
            local cardContent = currentCard.contentContainer or currentCard
            local contentAnchor = currentCard.contentAnchor
            local EDITBOX_HEIGHT = opt.height or 60
            local wrapper = CreateFrame("Frame", nil, cardContent)
            wrapper:SetHeight(EDITBOX_HEIGHT + (opt.labelText and 16 or 0))
            wrapper:SetPoint("TOPLEFT", contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            wrapper:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            local yOff = 0
            if opt.labelText then
                local lbl = wrapper:CreateFontString(nil, "OVERLAY")
                lbl:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 10, "OUTLINE")
                SetTextColor(lbl, Def.TextColorSection)
                lbl:SetText(opt.labelText)
                lbl:SetPoint("TOPLEFT", wrapper, "TOPLEFT", 0, 0)
                yOff = -14
            end
            local scrollBg = CreateFrame("Frame", nil, wrapper)
            scrollBg:SetPoint("TOPLEFT", wrapper, "TOPLEFT", 0, yOff)
            scrollBg:SetPoint("BOTTOMRIGHT", wrapper, "BOTTOMRIGHT", 0, 0)
            local bg = scrollBg:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(scrollBg)
            bg:SetColorTexture(Def.InputBg[1], Def.InputBg[2], Def.InputBg[3], Def.InputBg[4])
            local bt, bb, bl, br = addon.CreateBorder(scrollBg, Def.InputBorder)
            local function setEditboxBorderColor(c)
                for _, tex in ipairs({ bt, bb, bl, br }) do
                    if tex then tex:SetColorTexture(c[1], c[2], c[3], c[4] or 1) end
                end
            end
            local sf = CreateFrame("ScrollFrame", nil, scrollBg, "UIPanelScrollFrameTemplate")
            sf:SetPoint("TOPLEFT", scrollBg, "TOPLEFT", 4, -4)
            sf:SetPoint("BOTTOMRIGHT", scrollBg, "BOTTOMRIGHT", -22, 4)
            local edit = CreateFrame("EditBox", nil, scrollBg)
            edit:SetMultiLine(true)
            edit:SetAutoFocus(false)
            edit:EnableMouse(true)
            edit:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 10, "OUTLINE")
            local tc = Def.TextColorLabel; edit:SetTextColor(tc[1], tc[2], tc[3], tc[4] or 1)
            edit:SetWidth(200)
            sf:SetScrollChild(edit)
            sf:SetScript("OnSizeChanged", function(self, w)
                if w and w > 0 then edit:SetWidth(w) end
            end)
            edit:SetScript("OnCursorChanged", function(self, x, y, w, h)
                local vs = sf:GetVerticalScroll()
                local sfH = sf:GetHeight()
                local cursorY = -y
                if cursorY < vs then
                    sf:SetVerticalScroll(cursorY)
                elseif cursorY + h > vs + sfH then
                    sf:SetVerticalScroll(cursorY + h - sfH)
                end
            end)
            if opt.storeRef then addon[opt.storeRef] = edit end
            edit:SetScript("OnEditFocusGained", function()
                setEditboxBorderColor(Def.AccentColor)
            end)
            edit:SetScript("OnEditFocusLost", function()
                setEditboxBorderColor(Def.InputBorder)
            end)
            if opt.readonly then
                edit:EnableKeyboard(true)
                edit:SetScript("OnChar", function(self) self:SetText(opt.get and opt.get() or "") end)
                edit:SetScript("OnKeyDown", function(self, key)
                    if IsControlKeyDown and IsControlKeyDown() then
                        if key == "A" then
                            self:HighlightText()
                        end
                    end
                end)
                edit:SetScript("OnMouseUp", function(self)
                    self:HighlightText()
                end)
                edit:SetScript("OnEditFocusGained", function(self)
                    setEditboxBorderColor(Def.AccentColor)
                    self:HighlightText()
                end)
                edit:SetScript("OnEditFocusLost", function(self)
                    setEditboxBorderColor(Def.InputBorder)
                    self:HighlightText(0, 0)
                end)
            else
                edit:EnableKeyboard(true)
                scrollBg:SetScript("OnMouseDown", function()
                    edit:SetFocus()
                end)
            end
            if opt.get then edit:SetText(opt.get() or "") end
            if opt.set then
                edit:SetScript("OnTextChanged", function(self, isUserInput)
                    if isUserInput and opt.set then opt.set(self:GetText()) end
                    if opt.readonly and isUserInput then self:SetText(opt.get and opt.get() or "") end
                end)
            end
            wrapper.Refresh = function(self)
                if opt.get then edit:SetText(opt.get() or "") end
            end
            currentCard.contentAnchor = wrapper
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + wrapper:GetHeight()
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_editbox_" .. (opt.labelText or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = wrapper } end
            table.insert(refreshers, wrapper)
        elseif opt.type == "colorMatrix" then
            if currentCard then FinalizeCard(currentCard) end
            local sectionKey = (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or "Colors"):gsub("%s+", "_"))
            currentCard = OptionsWidgets_CreateSectionCard(tab, anchor, sectionKey, GetCardCollapsed, SetCardCollapsed)
            local lbl = OptionsWidgets_CreateSectionHeader(currentCard, opt.name or L["Colors"], sectionKey, GetCardCollapsed, SetCardCollapsed)
            currentCard.contentAnchor = lbl
            currentCard.contentHeight = CardPadding + RowHeights.sectionLabel
            anchor = currentCard
            local cardContent = currentCard.contentContainer or currentCard
            local keys = opt.keys or addon.COLOR_KEYS_ORDER
            local defaultMap = opt.defaultMap or addon.QUEST_COLORS
            local sub = OptionsWidgets_CreateSectionHeader(cardContent, L["Quest types"])
            sub:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap)
            currentCard.contentAnchor = sub
            currentCard.contentHeight = currentCard.contentHeight + SectionGap + RowHeights.sectionLabel
            local swatches = {}
            for _, key in ipairs(keys) do
                local getTbl = function() local db = getDB(opt.dbKey, nil) return db and db[key] end
                local setKeyVal = function(v) addon.EnsureDB(); local _rdb = _G[addon.DB_NAME]; if not _rdb[opt.dbKey] then _rdb[opt.dbKey] = {} end; _rdb[opt.dbKey][key] = v; if not addon._colorPickerLive then notifyMainAddon() end end
                local row = OptionsWidgets_CreateColorSwatchRow(cardContent, currentCard.contentAnchor, addon.L[(opt.labelMap and opt.labelMap[key]) or key:gsub("^%l", string.upper)], defaultMap[key], getTbl, setKeyVal, notifyMainAddon)
                currentCard.contentAnchor = row
                currentCard.contentHeight = currentCard.contentHeight + 4 + 24
                swatches[#swatches+1] = row
            end
            local resetBtn = OptionsWidgets_CreateButton(cardContent, L["Reset quest types"], function()
                setDB(opt.dbKey, nil)
                setDB("sectionColors", nil)
                for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                notifyMainAddon()
            end, { width = 120, height = 22 })
            resetBtn:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -6)
            currentCard.contentAnchor = resetBtn
            currentCard.contentHeight = currentCard.contentHeight + 6 + 22
            local overridesSub = OptionsWidgets_CreateSectionHeader(cardContent, L["Element overrides"])
            overridesSub:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap)
            currentCard.contentAnchor = overridesSub
            currentCard.contentHeight = currentCard.contentHeight + SectionGap + RowHeights.sectionLabel
            local overrideRows = {}
            for _, ov in ipairs(opt.overrides or {}) do
                local getTbl = function() return getDB(ov.dbKey, nil) end
                local setKeyVal = function(v) setDB(ov.dbKey, v) if not addon._colorPickerLive then notifyMainAddon() end end
                local row = OptionsWidgets_CreateColorSwatchRow(cardContent, currentCard.contentAnchor, ov.name, ov.default, getTbl, setKeyVal, notifyMainAddon)
                currentCard.contentAnchor = row
                currentCard.contentHeight = currentCard.contentHeight + 4 + 24
                overrideRows[#overrideRows+1] = row
            end
            local resetOv = OptionsWidgets_CreateButton(cardContent, L["Reset overrides"], function()
                for _, ov in ipairs(opt.overrides or {}) do setDB(ov.dbKey, nil) end
                for _, r in ipairs(overrideRows) do if r.Refresh then r:Refresh() end end
                notifyMainAddon()
            end, { width = 120, height = 22 })
            resetOv:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -6)
            currentCard.contentAnchor = resetOv
            currentCard.contentHeight = currentCard.contentHeight + 6 + 22
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = currentCard } end
            table.insert(refreshers, { Refresh = function() for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end for _, r in ipairs(overrideRows) do if r.Refresh then r:Refresh() end end end })
        elseif opt.type == "colorMatrixFull" then
            if currentCard then FinalizeCard(currentCard) end

            -- ---------------------------------------------------------------
            -- Color-matrix read helper: never triggers the notification chain
            -- (setDB -> NotifyMainAddon -> FullLayout) on read.  We write
            -- directly to HorizonDB so subsequent reads get the same table
            -- reference, without invoking the full refresh cascade.
            -- ---------------------------------------------------------------
            local function getMatrix()
                if addon.EnsureDB then addon.EnsureDB() end
                local m = addon.GetDB(opt.dbKey, nil)
                if type(m) ~= "table" then
                    m = { categories = {}, overrides = {} }
                    addon.SetDB(opt.dbKey, m)
                else
                    m.categories = m.categories or {}
                    m.overrides = m.overrides or {}
                end
                return m
            end

            local function getOverride(key)
                local m = getMatrix()
                local v = m.overrides and m.overrides[key]
                if key == "useCompletedOverride" and v == nil then return true end  -- Default on
                if key == "useCurrentQuestOverride" and v == nil then return true end  -- Default on
                return v
            end
            local function setOverride(key, v)
                local m = getMatrix()
                m.overrides[key] = v
                setDB(opt.dbKey, m)
                if not addon._colorPickerLive then notifyMainAddon() end
            end

            -- All collapsible group widgets, tracked for card-height recalc.
            local allGroupFrames = {}
            local categoryRows = {}
            local GROUP_HEADER_H = 24
            local GROUP_ROW_H = 24
            local GROUP_ROW_GAP = 4
            local GROUP_ROWS_PER_KEY = 4  -- title, objective, zone, section

            -- Recalculate card height after a group expand / collapse.
            -- Layout: Colors | Per category (header + groups) | Grouping Overrides (header + 2 toggles + groups) | Other
            local numPerCategoryGroups = 0  -- set when we have perCategoryOrder
            local function RecalcCardHeight()
                if not currentCard then return end
                local h = CardPadding + RowHeights.sectionLabel  -- Colors header
                h = h + SectionGap + RowHeights.sectionLabel     -- Per category header
                h = h + 6 + 22                                    -- Reset all button
                local n = numPerCategoryGroups
                for i = 1, n do
                    h = h + OptionGap + allGroupFrames[i]:GetHeight()
                end
                h = h + SectionGap + RowHeights.sectionLabel     -- Grouping Overrides header
                h = h + OptionGap + 38                           -- toggle 1
                h = h + OptionGap + 38                           -- toggle 2
                h = h + OptionGap + 38                           -- toggle 3 (Current Quest)
                for i = n + 1, #allGroupFrames do
                    h = h + OptionGap + allGroupFrames[i]:GetHeight()
                end
                h = h + SectionGap + RowHeights.sectionLabel     -- Other colors header
                h = h + OptionGap + 38                           -- Use distinct color for completed objectives toggle
                h = h + 4 * (GROUP_ROW_GAP + GROUP_ROW_H)        -- Highlight, Completed objective, Progress bar fill, Progress bar text
                currentCard.contentHeight = h
                local fullH = h + CardBottomPadding
                currentCard.fullHeight = fullH
                currentCard:SetHeight(fullH)
                if currentCard.contentContainer and currentCard.headerHeight then
                    currentCard.contentContainer:SetHeight(math.max(1, h - currentCard.headerHeight))
                end
                if tab and ResizeTabFrame then ResizeTabFrame(tab) end
            end

            -- ---------------------------------------------------------------
            -- Build a collapsible group for one category key.
            -- Returns a container frame that is either collapsed (just the
            -- header) or expanded (header + 4 colour-swatch rows).
            -- Rows are created lazily on first expand.
            -- ---------------------------------------------------------------
            local function BuildCollapsibleGroup(parentCard, anchorFrame, key)
                local labelBase = addon.L[(addon.SECTION_LABELS and addon.SECTION_LABELS[key]) or key]
                local container = CreateFrame("Frame", nil, parentCard)
                container:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -OptionGap)
                container:SetPoint("RIGHT", parentCard, "RIGHT", -CardPadding, 0)
                container:SetHeight(GROUP_HEADER_H)

                -- Clickable header
                local hdr = CreateFrame("Button", nil, container)
                hdr:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
                hdr:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, 0)
                hdr:SetHeight(GROUP_HEADER_H)

                local hdrBg = hdr:CreateTexture(nil, "BACKGROUND")
                hdrBg:SetAllPoints(hdr)
                hdrBg:SetColorTexture(0.10, 0.10, 0.12, 0.5)

                local chevron = hdr:CreateFontString(nil, "OVERLAY")
                chevron:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
                SetTextColor(chevron, Def.TextColorSection)
                chevron:SetText("+")
                chevron:SetPoint("LEFT", hdr, "LEFT", 6, 0)

                local hdrLabel = hdr:CreateFontString(nil, "OVERLAY")
                hdrLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
                SetTextColor(hdrLabel, Def.TextColorLabel)
                hdrLabel:SetText(labelBase)
                hdrLabel:SetPoint("LEFT", chevron, "RIGHT", 6, 0)
                hdrLabel:SetJustifyH("LEFT")

                -- Unified default: section, title, and objective share the same color per category.
                -- Matrix keys (ACHIEVEMENTS, RARES) map to QUEST_COLORS keys (ACHIEVEMENT, RARE).
                local questColorKey = (key == "ACHIEVEMENTS" and "ACHIEVEMENT") or (key == "RARES" and "RARE") or key
                local baseColor = (addon.QUEST_COLORS and addon.QUEST_COLORS[questColorKey]) or (addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                local sectionColor = (addon.SECTION_COLORS and addon.SECTION_COLORS[key]) or (addon.SECTION_COLORS and addon.SECTION_COLORS.DEFAULT) or { 0.9, 0.9, 0.9 }
                local unifiedDef = (key == "NEARBY" or key == "CURRENT" or key == "CURRENT_EVENT") and sectionColor or baseColor  -- Current Zone / Current Quest / Current Event: use section color

                -- Reset button (child of container so click does not toggle expand)
                local resetBtn = OptionsWidgets_CreateButton(container, L["Reset"], function()
                    local m = getMatrix()
                    if m.categories and m.categories[key] then
                        m.categories[key] = nil
                        setDB(opt.dbKey, m)
                        notifyMainAddon()
                        container:Refresh()
                    end
                end, { width = 50, height = 22 })
                resetBtn:SetPoint("RIGHT", container, "RIGHT", -8, 0)

                local previewSwatch = hdr:CreateTexture(nil, "ARTWORK")
                previewSwatch:SetSize(14, 14)
                previewSwatch:SetPoint("RIGHT", resetBtn, "LEFT", -8, 0)
                previewSwatch:SetColorTexture(unifiedDef[1], unifiedDef[2], unifiedDef[3], 1)

                -- Highlight on hover
                local hdrHi = hdr:CreateTexture(nil, "HIGHLIGHT")
                hdrHi:SetAllPoints(hdr)
                hdrHi:SetColorTexture(1, 1, 1, 0.03)

                -- State
                container.expanded = false
                container.rows = nil  -- created lazily
                container.groupKey = key

                local catDefs = {
                    { subKey = "section",   suffix = "Section",   def = unifiedDef },
                    { subKey = "title",     suffix = "Title",     def = unifiedDef },
                    { subKey = "zone",      suffix = "Zone",      def = addon.ZONE_COLOR or { 0.55, 0.65, 0.75 } },
                    { subKey = "objective", suffix = "Objective", def = unifiedDef },
                }

                -- Lazy-create the 4 color rows on first expand.
                local function EnsureRows()
                    if container.rows then return end
                    container.rows = {}
                    local prevAnchor = hdr
                    for _, cd in ipairs(catDefs) do
                        local rowLabel = cd.suffix
                        local getTbl = function()
                            local m = getMatrix()
                            local cats = m.categories or {}
                            return cats[key] and cats[key][cd.subKey] or nil
                        end
                        local setKeyVal = function(v)
                            local m = getMatrix()
                            m.categories[key] = m.categories[key] or {}
                            m.categories[key][cd.subKey] = (type(v) == "table" and v[1] and v[2] and v[3]) and { v[1], v[2], v[3] } or v
                            setDB(opt.dbKey, m)
                            if not addon._colorPickerLive then notifyMainAddon() end
                        end
                        local row = OptionsWidgets_CreateColorSwatchRow(container, prevAnchor, rowLabel, cd.def, getTbl, setKeyVal, notifyMainAddon)
                        prevAnchor = row
                        container.rows[#container.rows + 1] = row
                        categoryRows[#categoryRows + 1] = row
                    end
                end

                local function SetExpanded(expand)
                    container.expanded = expand
                    if expand then
                        EnsureRows()
                        chevron:SetText("-")  -- hyphen-minus for locale compatibility (En Dash fails on koKR)
                        for _, r in ipairs(container.rows) do r:Show() end
                        container:SetHeight(GROUP_HEADER_H + GROUP_ROWS_PER_KEY * (GROUP_ROW_GAP + GROUP_ROW_H))
                    else
                        chevron:SetText("+")
                        if container.rows then
                            for _, r in ipairs(container.rows) do r:Hide() end
                        end
                        container:SetHeight(GROUP_HEADER_H)
                    end
                    RecalcCardHeight()
                end

                hdr:SetScript("OnClick", function()
                    SetExpanded(not container.expanded)
                end)

                -- Update preview swatch colour from current DB.
                function container:RefreshPreview()
                    local m = getMatrix()
                    local cats = m.categories or {}
                    local tbl = cats[key] and cats[key].title
                    if tbl and type(tbl) == "table" and type(tbl[1]) == "number" and type(tbl[2]) == "number" and type(tbl[3]) == "number" then
                        previewSwatch:SetColorTexture(tbl[1], tbl[2], tbl[3], 1)
                    else
                        previewSwatch:SetColorTexture(unifiedDef[1], unifiedDef[2], unifiedDef[3], 1)
                    end
                end

                function container:Refresh()
                    self:RefreshPreview()
                    if self.rows then
                        for _, r in ipairs(self.rows) do if r.Refresh then r:Refresh() end end
                    end
                end

                allGroupFrames[#allGroupFrames + 1] = container
                return container
            end

            -- ---------------------------------------------------------------
            -- Assemble the Colors card
            -- ---------------------------------------------------------------
            local sectionKey = (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or "Colors"):gsub("%s+", "_"))
            currentCard = OptionsWidgets_CreateSectionCard(tab, anchor, sectionKey, GetCardCollapsed, SetCardCollapsed)
            local lbl = OptionsWidgets_CreateSectionHeader(currentCard, opt.name or L["Colors"], sectionKey, GetCardCollapsed, SetCardCollapsed)
            currentCard.contentAnchor = lbl
            currentCard.contentHeight = CardPadding + RowHeights.sectionLabel
            anchor = currentCard
            local cardContent = currentCard.contentContainer or currentCard

            local groupOrder = addon.GetGroupOrder and addon.GetGroupOrder() or {}
            if type(groupOrder) ~= "table" or #groupOrder == 0 then
                groupOrder = addon.GROUP_ORDER or {}
            end
            local GROUPING_OVERRIDE_KEYS = { CURRENT = true, NEARBY = true, COMPLETE = true }
            local perCategoryOrder = {}
            local groupingOverrideOrder = {}
            for _, key in ipairs(groupOrder) do
                if GROUPING_OVERRIDE_KEYS[key] then
                    table.insert(groupingOverrideOrder, key)
                else
                    table.insert(perCategoryOrder, key)
                end
            end
            numPerCategoryGroups = #perCategoryOrder

            -- Per-category collapsible groups (excludes NEARBY and COMPLETE)
            local catHdr = OptionsWidgets_CreateSectionHeader(cardContent, L["Per category"])
            catHdr:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap)
            currentCard.contentAnchor = catHdr
            currentCard.contentHeight = currentCard.contentHeight + SectionGap + RowHeights.sectionLabel

            local resetAllBtn = OptionsWidgets_CreateButton(cardContent, L["Reset all to defaults"] or L["Reset to defaults"], function()
                setDB(opt.dbKey, nil)
                setDB("questColors", nil)
                setDB("sectionColors", nil)
                for _, gf in ipairs(allGroupFrames) do
                    if gf.Refresh then gf:Refresh() end
                    if gf.RefreshPreview then gf:RefreshPreview() end
                end
                if otherRows then for _, r in ipairs(otherRows) do if r.Refresh then r:Refresh() end end end
                if ovCompleted and ovCompleted.Refresh then ovCompleted:Refresh() end
                if ovCurrentZone and ovCurrentZone.Refresh then ovCurrentZone:Refresh() end
                if ovCurrentQuest and ovCurrentQuest.Refresh then ovCurrentQuest:Refresh() end
                if ovCompletedObj and ovCompletedObj.Refresh then ovCompletedObj:Refresh() end
                notifyMainAddon()
            end, { width = 140, height = 22 })
            resetAllBtn:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -6)
            currentCard.contentAnchor = resetAllBtn
            currentCard.contentHeight = currentCard.contentHeight + 6 + 22

            for _, key in ipairs(perCategoryOrder) do
                local gf = BuildCollapsibleGroup(cardContent, currentCard.contentAnchor, key)
                currentCard.contentAnchor = gf
                currentCard.contentHeight = currentCard.contentHeight + OptionGap + GROUP_HEADER_H
            end

            local div1 = cardContent:CreateTexture(nil, "ARTWORK")
            div1:SetHeight(1)
            div1:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap/2)
            div1:SetPoint("TOPRIGHT", currentCard, "TOPRIGHT", -CardPadding, 0)
            local dc = Def.DividerColor or { 0.35, 0.4, 0.5, 0.2 }
            div1:SetColorTexture(dc[1], dc[2], dc[3], dc[4] or 0.2)

            -- Grouping Overrides: toggles + NEARBY and COMPLETE collapsible groups
            local goHdr = OptionsWidgets_CreateSectionHeader(cardContent, L["Grouping Overrides"])
            goHdr:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap)
            currentCard.contentAnchor = goHdr
            currentCard.contentHeight = currentCard.contentHeight + SectionGap + RowHeights.sectionLabel

            local ovCompleted = OptionsWidgets_CreateToggleSwitch(cardContent, L["Ready to Turn In overrides base colours"], L["Ready to Turn In uses its colours for quests in that section."], function() return getOverride("useCompletedOverride") end, function(v) setOverride("useCompletedOverride", v) end)
            ovCompleted:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            ovCompleted:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = ovCompleted
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 38

            local ovCurrentZone = OptionsWidgets_CreateToggleSwitch(cardContent, L["Current Zone overrides base colours"], L["Current Zone uses its colours for quests in that section."], function() return getOverride("useCurrentZoneOverride") end, function(v) setOverride("useCurrentZoneOverride", v) end)
            ovCurrentZone:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            ovCurrentZone:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = ovCurrentZone
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 38

            local ovCurrentQuest = OptionsWidgets_CreateToggleSwitch(cardContent, L["Current Quest overrides base colours"], L["Current Quest uses its colours for quests in that section."], function() return getOverride("useCurrentQuestOverride") end, function(v) setOverride("useCurrentQuestOverride", v) end)
            ovCurrentQuest:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            ovCurrentQuest:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = ovCurrentQuest
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 38

            for _, key in ipairs(groupingOverrideOrder) do
                local gf = BuildCollapsibleGroup(cardContent, currentCard.contentAnchor, key)
                currentCard.contentAnchor = gf
                currentCard.contentHeight = currentCard.contentHeight + OptionGap + GROUP_HEADER_H
            end

            local div2 = cardContent:CreateTexture(nil, "ARTWORK")
            div2:SetHeight(1)
            div2:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap/2)
            div2:SetPoint("TOPRIGHT", currentCard, "TOPRIGHT", -CardPadding, 0)
            div2:SetColorTexture(dc[1], dc[2], dc[3], dc[4] or 0.2)

            -- Other global colours (always visible)
            local otherHdr = OptionsWidgets_CreateSectionHeader(cardContent, L["Other colors"])
            otherHdr:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -SectionGap)
            currentCard.contentAnchor = otherHdr
            currentCard.contentHeight = currentCard.contentHeight + SectionGap + RowHeights.sectionLabel

            local ovCompletedObj = OptionsWidgets_CreateToggleSwitch(cardContent, L["Use distinct color for completed objectives"], L["When on, completed objectives (e.g. 1/1) use the color below; when off, they use the same color as incomplete objectives."], function() return getDB("useCompletedObjectiveColor", true) end, function(v) setDB("useCompletedObjectiveColor", v) notifyMainAddon() end)
            ovCompletedObj:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            ovCompletedObj:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
            currentCard.contentAnchor = ovCompletedObj
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + 38

            local otherDefs = {
                { dbKey = "highlightColor", label = L["Highlight"], def = (addon.HIGHLIGHT_COLOR_DEFAULT or { 0.4, 0.7, 1 }) },
                { dbKey = "completedObjectiveColor", label = L["Completed objective"], def = (addon.OBJ_DONE_COLOR or { 0.20, 1.00, 0.40 }) },
                { dbKey = "progressBarFillColor", label = L["Progress bar fill"], def = { 0.40, 0.65, 0.90, 0.85 }, disabled = function() return getDB("progressBarUseCategoryColor", true) end, hasAlpha = true },
                { dbKey = "progressBarTextColor", label = L["Progress bar text"], def = { 0.95, 0.95, 0.95 } },
            }
            local otherRows = {}
            for _, od in ipairs(otherDefs) do
                local getTbl = function() return getDB(od.dbKey, nil) end
                local setKeyVal = function(v) setDB(od.dbKey, v) if not addon._colorPickerLive then notifyMainAddon() end end
                local row = OptionsWidgets_CreateColorSwatchRow(cardContent, currentCard.contentAnchor, od.label, od.def, getTbl, setKeyVal, notifyMainAddon, od.disabled, od.hasAlpha)
                currentCard.contentAnchor = row
                currentCard.contentHeight = currentCard.contentHeight + GROUP_ROW_GAP + GROUP_ROW_H
                otherRows[#otherRows + 1] = row
            end

            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = currentCard } end
            table.insert(refreshers, {
                Refresh = function()
                    for _, gf in ipairs(allGroupFrames) do if gf.Refresh then gf:Refresh() end end
                    for _, r in ipairs(otherRows) do if r.Refresh then r:Refresh() end end
                    if ovCompleted and ovCompleted.Refresh then ovCompleted:Refresh() end
                    if ovCurrentZone and ovCurrentZone.Refresh then ovCurrentZone:Refresh() end
                    if ovCurrentQuest and ovCurrentQuest.Refresh then ovCurrentQuest:Refresh() end
                    if ovCompletedObj and ovCompletedObj.Refresh then ovCompletedObj:Refresh() end
                end,
            })
        elseif opt.type == "blacklistGrid" then
            if currentCard then FinalizeCard(currentCard) end
            local sectionKey = (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or "Blacklist"):gsub("%s+", "_"))
            currentCard = OptionsWidgets_CreateSectionCard(tab, anchor, sectionKey, GetCardCollapsed, SetCardCollapsed)
            local lbl = OptionsWidgets_CreateSectionHeader(currentCard, opt.name or L["Blacklist"], sectionKey, GetCardCollapsed, SetCardCollapsed)
            currentCard.contentAnchor = lbl
            currentCard.contentHeight = CardPadding + RowHeights.sectionLabel
            anchor = currentCard
            local cardContent = currentCard.contentContainer or currentCard

            if opt.desc and opt.desc ~= "" then
                local descText = cardContent:CreateFontString(nil, "OVERLAY")
                descText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 11, "OUTLINE")
                descText:SetTextColor(Def.TextColorSection and Def.TextColorSection[1] or 0.58, Def.TextColorSection and Def.TextColorSection[2] or 0.64, Def.TextColorSection and Def.TextColorSection[3] or 0.74)
                descText:SetJustifyH("LEFT")
                descText:SetWordWrap(true)
                descText:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -4)
                descText:SetPoint("RIGHT", currentCard, "RIGHT", -CardPadding, 0)
                descText:SetText(opt.desc)
                currentCard.contentAnchor = descText
                currentCard.contentHeight = currentCard.contentHeight + 4 + (descText:GetStringHeight() or 12)
            end

            -- Scrollable container for the grid (dynamically sized, scrollbars outside content)
            local gridWrapper = CreateFrame("Frame", nil, cardContent)
            gridWrapper:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -OptionGap)
            gridWrapper:SetPoint("BOTTOMRIGHT", currentCard, "BOTTOMRIGHT", -CardPadding, CardBottomPadding)
            
            local scrollFrame = CreateFrame("ScrollFrame", nil, gridWrapper)
            scrollFrame:SetPoint("TOPLEFT", gridWrapper, "TOPLEFT", 0, 0)
            scrollFrame:SetPoint("BOTTOMRIGHT", gridWrapper, "BOTTOMRIGHT", -14, 14)  -- Space for scrollbars
            scrollFrame:EnableMouseWheel(true)
            
            local scrollChild = CreateFrame("Frame", nil, scrollFrame)
            scrollChild:SetSize(900, 1)  -- Wide enough for all columns
            scrollFrame:SetScrollChild(scrollChild)
            
            -- Vertical scrollbar (outside content area)
            local vScrollBar = CreateFrame("Slider", nil, gridWrapper)
            vScrollBar:SetOrientation("VERTICAL")
            vScrollBar:SetPoint("TOPRIGHT", gridWrapper, "TOPRIGHT", 0, 0)
            vScrollBar:SetPoint("BOTTOMRIGHT", gridWrapper, "BOTTOMRIGHT", 0, 14)
            vScrollBar:SetWidth(12)
            vScrollBar:SetValueStep(1)
            vScrollBar:SetObeyStepOnDrag(true)
            local vScrollBg = vScrollBar:CreateTexture(nil, "BACKGROUND")
            vScrollBg:SetAllPoints(vScrollBar)
            vScrollBg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
            local vScrollThumb = vScrollBar:CreateTexture(nil, "OVERLAY")
            vScrollThumb:SetSize(12, 30)
            vScrollThumb:SetColorTexture(0.3, 0.3, 0.35, 0.9)
            vScrollBar:SetThumbTexture(vScrollThumb)
            vScrollBar:SetScript("OnValueChanged", function(self, value)
                scrollFrame:SetVerticalScroll(value)
            end)
            
            -- Horizontal scrollbar (outside content area)
            local hScrollBar = CreateFrame("Slider", nil, gridWrapper)
            hScrollBar:SetOrientation("HORIZONTAL")
            hScrollBar:SetPoint("BOTTOMLEFT", gridWrapper, "BOTTOMLEFT", 0, 0)
            hScrollBar:SetPoint("BOTTOMRIGHT", gridWrapper, "BOTTOMRIGHT", -14, 0)
            hScrollBar:SetHeight(12)
            hScrollBar:SetValueStep(1)
            hScrollBar:SetObeyStepOnDrag(true)
            local hScrollBg = hScrollBar:CreateTexture(nil, "BACKGROUND")
            hScrollBg:SetAllPoints(hScrollBar)
            hScrollBg:SetColorTexture(0.1, 0.1, 0.12, 0.8)
            local hScrollThumb = hScrollBar:CreateTexture(nil, "OVERLAY")
            hScrollThumb:SetSize(30, 12)
            hScrollThumb:SetColorTexture(0.3, 0.3, 0.35, 0.9)
            hScrollBar:SetThumbTexture(hScrollThumb)
            hScrollBar:SetScript("OnValueChanged", function(self, value)
                scrollFrame:SetHorizontalScroll(value)
            end)
            
            -- Mouse wheel scrolling: up/down = vertical, Ctrl+wheel = horizontal
            scrollFrame:SetScript("OnMouseWheel", function(self, delta)
                if IsControlKeyDown() then
                    -- Horizontal scroll (hold Ctrl)
                    local current = self:GetHorizontalScroll()
                    local maxScroll = math.max(0, scrollChild:GetWidth() - self:GetWidth())
                    local new = math.max(0, math.min(current - (delta * 20), maxScroll))
                    self:SetHorizontalScroll(new)
                    hScrollBar:SetValue(new)
                else
                    -- Vertical scroll (normal)
                    local current = self:GetVerticalScroll()
                    local maxScroll = math.max(0, scrollChild:GetHeight() - self:GetHeight())
                    local new = math.max(0, math.min(current - (delta * 20), maxScroll))
                    self:SetVerticalScroll(new)
                    vScrollBar:SetValue(new)
                end
            end)
            
            -- Update scrollbar ranges when content changes
            local function UpdateScrollBars()
                local maxV = math.max(0, scrollChild:GetHeight() - scrollFrame:GetHeight())
                local maxH = math.max(0, scrollChild:GetWidth() - scrollFrame:GetWidth())
                vScrollBar:SetMinMaxValues(0, maxV)
                hScrollBar:SetMinMaxValues(0, maxH)
                -- Set initial thumb position to force visibility
                vScrollBar:SetValue(scrollFrame:GetVerticalScroll())
                hScrollBar:SetValue(scrollFrame:GetHorizontalScroll())
                vScrollBar:SetShown(maxV > 0)
                hScrollBar:SetShown(maxH > 0)
            end
            
            local gridContainer = scrollChild
            currentCard.contentAnchor = gridWrapper
            -- Dynamic height: header + gap + grid; card height grows with window
            local gridH = math.max(450, PAGE_HEIGHT - 300)
            currentCard.contentHeight = currentCard.contentHeight + OptionGap + gridH
            currentCard.updateScrollBars = UpdateScrollBars
            -- Store reference so resize handler can update this card's height
            addon.blacklistGridCard = currentCard
            
            -- Update scrollbars when wrapper resizes (follows window resize)
            gridWrapper:SetScript("OnSizeChanged", function()
                if currentCard.updateScrollBars then
                    currentCard.updateScrollBars()
                end
            end)
            
            -- Sorting state: column (id, title, type, zone) and direction (asc/desc)
            local sortColumn = "id"
            local sortAscending = false  -- default: ID descending
            
            local function BuildBlacklistGrid()
                -- Clear existing children
                local children = {gridContainer:GetChildren()}
                for _, child in ipairs(children) do child:Hide() end

                local blacklistTbl = addon.GetDB and addon.GetDB("permanentQuestBlacklist", nil) or nil

                -- If no blacklist, just show empty grid (no placeholder text)
                if type(blacklistTbl) ~= "table" or not next(blacklistTbl) then
                    gridContainer:SetSize(900, 40)
                    scrollChild:SetHeight(40)
                    if currentCard.updateScrollBars then currentCard.updateScrollBars() end
                    return
                end

                -- Build blacklist table
                local blacklistData = {}
                for questID in pairs(blacklistTbl) do
                    local title = C_QuestLog.GetTitleForQuestID(questID) or "Unknown Quest"
                    local questType = "Quest"
                    local zone = "Unknown"
                    local color = addon.QUEST_COLORS and addon.QUEST_COLORS.DEFAULT or {0.78, 0.78, 0.78}
                    
                    -- Determine quest type and color
                    if addon.IsQuestWorldQuest and addon.IsQuestWorldQuest(questID) then
                        questType = "World Quest"
                        color = addon.QUEST_COLORS and addon.QUEST_COLORS.WORLD or color
                    elseif addon.IsQuestDailyOrWeekly then
                        local freq = addon.IsQuestDailyOrWeekly(questID)
                        if freq == "weekly" then
                            questType = "Weekly"
                            color = addon.QUEST_COLORS and addon.QUEST_COLORS.WEEKLY or color
                        elseif freq == "daily" then
                            questType = "Daily"
                            color = addon.QUEST_COLORS and addon.QUEST_COLORS.DAILY or color
                        end
                    end
                    
                    -- Get zone info
                    local mapID = C_TaskQuest.GetQuestZoneID and C_TaskQuest.GetQuestZoneID(questID)
                    if not mapID and C_QuestLog.GetQuestInfo then
                        local info = C_QuestLog.GetQuestInfo(questID)
                        if info then zone = info.zoneName or zone end
                    end
                    if mapID then
                        local mapInfo = C_Map.GetMapInfo(mapID)
                        if mapInfo then zone = mapInfo.name end
                    end
                    
                    table.insert(blacklistData, {questID = questID, title = title, questType = questType, zone = zone, color = color})
                end
                
                -- Sort based on current column and direction
                table.sort(blacklistData, function(a, b)
                    if not a or not b then return false end
                    local valA, valB
                    if sortColumn == "id" then
                        valA, valB = a.questID or 0, b.questID or 0
                        return sortAscending and (valA < valB) or (valA > valB)
                    elseif sortColumn == "title" then
                        valA = (a.title or ""):lower()
                        valB = (b.title or ""):lower()
                        return sortAscending and (valA < valB) or (valA > valB)
                    elseif sortColumn == "type" then
                        valA = (a.questType or ""):lower()
                        valB = (b.questType or ""):lower()
                        return sortAscending and (valA < valB) or (valA > valB)
                    elseif sortColumn == "zone" then
                        valA = (a.zone or ""):lower()
                        valB = (b.zone or ""):lower()
                        return sortAscending and (valA < valB) or (valA > valB)
                    end
                    return false
                end)
                
                -- Header row with distinct styling
                local header = CreateFrame("Frame", nil, gridContainer)
                header:SetSize(900, 24)
                header:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 0, 0)
                local headerBg = header:CreateTexture(nil, "BACKGROUND")
                headerBg:SetAllPoints(header)
                headerBg:SetColorTexture(0.18, 0.19, 0.22, 1)
                
                -- Header bottom border
                local headerBorder = header:CreateTexture(nil, "BORDER")
                headerBorder:SetSize(900, 2)
                headerBorder:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
                headerBorder:SetColorTexture(0.3, 0.32, 0.36, 1)
                
                -- Helper to create clickable header with vertical dividers
                local function MakeHeaderButton(parent, text, column, xPos, width)
                    local btn = CreateFrame("Button", nil, parent)
                    btn:SetSize(width, 24)
                    btn:SetPoint("LEFT", parent, "LEFT", xPos, 0)
                    
                    -- Vertical divider (right edge)
                    local divider = btn:CreateTexture(nil, "OVERLAY")
                    divider:SetSize(1, 18)
                    divider:SetPoint("RIGHT", btn, "RIGHT", 0, 0)
                    divider:SetColorTexture(0.25, 0.27, 0.30, 0.8)
                    
                    local lbl = btn:CreateFontString(nil, "OVERLAY")
                    lbl:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13), "OUTLINE")
                    SetTextColor(lbl, {0.85, 0.87, 0.90})
                    lbl:SetPoint("LEFT", btn, "LEFT", 4, 0)
                    btn.label = lbl
                    btn.column = column
                    local arrow = btn:CreateFontString(nil, "OVERLAY")
                    arrow:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
                    arrow:SetPoint("LEFT", lbl, "RIGHT", 3, 0)
                    btn.arrow = arrow
                    btn:SetScript("OnClick", function()
                        if sortColumn == column then
                            sortAscending = not sortAscending
                        else
                            sortColumn = column
                            sortAscending = true
                        end
                        BuildBlacklistGrid()
                    end)
                    btn:SetScript("OnEnter", function() SetTextColor(lbl, Def.TextColorHighlight or {0.4, 0.7, 1}) end)
                    btn:SetScript("OnLeave", function() SetTextColor(lbl, {0.85, 0.87, 0.90}) end)
                    -- Update text and arrow
                    lbl:SetText(text)
                    if sortColumn == column then
                        arrow:SetText(sortAscending and "^" or "v")
                        SetTextColor(arrow, Def.TextColorHighlight or {0.4, 0.7, 1})
                    else
                        arrow:SetText("")
                    end
                    return btn
                end
                
                -- Static checkbox column header
                local cbHeader = header:CreateFontString(nil, "OVERLAY")
                cbHeader:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13), "OUTLINE")
                SetTextColor(cbHeader, {0.85, 0.87, 0.90})
                cbHeader:SetPoint("LEFT", header, "LEFT", 8, 0)
                
                -- Row # column header
                local rowHeader = header:CreateFontString(nil, "OVERLAY")
                rowHeader:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13), "OUTLINE")
                SetTextColor(rowHeader, {0.85, 0.87, 0.90})
                rowHeader:SetText("#")
                rowHeader:SetPoint("LEFT", header, "LEFT", 34, 0)
                
                -- Column dividers
                local divider1 = header:CreateTexture(nil, "OVERLAY")
                divider1:SetSize(1, 18)
                divider1:SetPoint("LEFT", header, "LEFT", 28, 0)
                divider1:SetColorTexture(0.25, 0.27, 0.30, 0.8)
                
                local divider2 = header:CreateTexture(nil, "OVERLAY")
                divider2:SetSize(1, 18)
                divider2:SetPoint("LEFT", header, "LEFT", 62, 0)
                divider2:SetColorTexture(0.25, 0.27, 0.30, 0.8)
                
                MakeHeaderButton(header, "ID", "id", 63, 80)
                MakeHeaderButton(header, "Title", "title", 143, 280)
                MakeHeaderButton(header, "Type", "type", 423, 120)
                MakeHeaderButton(header, "Zone", "zone", 543, 180)
                
                local yOffset = -26
                for i, data in ipairs(blacklistData) do
                    local row = CreateFrame("Button", nil, gridContainer)
                    row:SetSize(900, 26)
                    row:SetPoint("TOPLEFT", gridContainer, "TOPLEFT", 0, yOffset)
                    
                    -- Alternating background
                    local rowBg = row:CreateTexture(nil, "BACKGROUND")
                    rowBg:SetAllPoints(row)
                    rowBg:SetColorTexture(0.08, 0.08, 0.10, i % 2 == 0 and 0.5 or 0.2)
                    
                    -- Row bottom border
                    local rowBorder = row:CreateTexture(nil, "BORDER")
                    rowBorder:SetSize(900, 1)
                    rowBorder:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
                    rowBorder:SetColorTexture(0.12, 0.12, 0.14, 0.6)
                    
                    -- Checkbox
                    local cb = CreateFrame("CheckButton", nil, row)
                    cb:SetSize(16, 16)
                    cb:SetPoint("LEFT", row, "LEFT", 6, 0)
                    cb:SetChecked(true)
                    cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
                    cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
                    cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
                    cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
                    cb:SetScript("OnClick", function(self)
                        if not self:GetChecked() then
                            local bl = addon.GetDB and addon.GetDB("permanentQuestBlacklist", nil) or nil
                            if type(bl) == "table" then
                                bl[data.questID] = nil
                                if addon.SetDB then addon.SetDB("permanentQuestBlacklist", bl) end
                            end
                            BuildBlacklistGrid()
                            if addon.FullLayout then addon.FullLayout() end
                        end
                    end)
                    
                    -- Column dividers
                    local div1 = row:CreateTexture(nil, "OVERLAY")
                    div1:SetSize(1, 22)
                    div1:SetPoint("LEFT", row, "LEFT", 28, 0)
                    div1:SetColorTexture(0.15, 0.15, 0.17, 0.5)
                    
                    local div2 = row:CreateTexture(nil, "OVERLAY")
                    div2:SetSize(1, 22)
                    div2:SetPoint("LEFT", row, "LEFT", 62, 0)
                    div2:SetColorTexture(0.15, 0.15, 0.17, 0.5)
                    
                    local div3 = row:CreateTexture(nil, "OVERLAY")
                    div3:SetSize(1, 22)
                    div3:SetPoint("LEFT", row, "LEFT", 143, 0)
                    div3:SetColorTexture(0.15, 0.15, 0.17, 0.5)
                    
                    local div4 = row:CreateTexture(nil, "OVERLAY")
                    div4:SetSize(1, 22)
                    div4:SetPoint("LEFT", row, "LEFT", 423, 0)
                    div4:SetColorTexture(0.15, 0.15, 0.17, 0.5)
                    
                    local div5 = row:CreateTexture(nil, "OVERLAY")
                    div5:SetSize(1, 22)
                    div5:SetPoint("LEFT", row, "LEFT", 543, 0)
                    div5:SetColorTexture(0.15, 0.15, 0.17, 0.5)
                    
                    -- Row number
                    local rowNum = row:CreateFontString(nil, "OVERLAY")
                    rowNum:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 2, "")
                    SetTextColor(rowNum, {0.5, 0.52, 0.55})
                    rowNum:SetText(tostring(i))
                    rowNum:SetPoint("CENTER", row, "LEFT", 45, 0)
                    
                    -- ID
                    local idText = row:CreateFontString(nil, "OVERLAY")
                    idText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 2, "")
                    SetTextColor(idText, data.color)
                    idText:SetText(tostring(data.questID))
                    idText:SetPoint("LEFT", row, "LEFT", 68, 0)
                    
                    -- Title
                    local titleText = row:CreateFontString(nil, "OVERLAY")
                    titleText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 2, "")
                    SetTextColor(titleText, data.color)
                    titleText:SetText(data.title)
                    titleText:SetPoint("LEFT", row, "LEFT", 148, 0)
                    titleText:SetWidth(270)
                    titleText:SetJustifyH("LEFT")
                    titleText:SetWordWrap(false)
                    
                    -- Type
                    local typeText = row:CreateFontString(nil, "OVERLAY")
                    typeText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 2, "")
                    SetTextColor(typeText, data.color)
                    typeText:SetText(data.questType)
                    typeText:SetPoint("LEFT", row, "LEFT", 428, 0)
                    
                    -- Zone
                    local zoneText = row:CreateFontString(nil, "OVERLAY")
                    zoneText:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 2, "")
                    SetTextColor(zoneText, data.color)
                    zoneText:SetText(data.zone)
                    zoneText:SetPoint("LEFT", row, "LEFT", 548, 0)
                    zoneText:SetWidth(170)
                    zoneText:SetJustifyH("LEFT")
                    zoneText:SetWordWrap(false)
                    
                    -- Hover highlight
                    local origBgColor = {0.08, 0.08, 0.10, i % 2 == 0 and 0.5 or 0.2}
                    row:SetScript("OnEnter", function() rowBg:SetColorTexture(0.2, 0.25, 0.3, 0.7) end)
                    row:SetScript("OnLeave", function() rowBg:SetColorTexture(origBgColor[1], origBgColor[2], origBgColor[3], origBgColor[4]) end)
                    
                    yOffset = yOffset - 27
                end
                
                local totalHeight = math.max(100, math.abs(yOffset) + 27)
                gridContainer:SetSize(900, totalHeight)
                scrollChild:SetHeight(totalHeight)
                
                -- Update scrollbars
                if currentCard.updateScrollBars then currentCard.updateScrollBars() end
            end
            
            BuildBlacklistGrid()
            -- Export refresh function to addon namespace
            addon.RefreshBlacklistGrid = BuildBlacklistGrid
            local oid = opt.name:gsub("%s+", "_")
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = currentCard } end
            table.insert(refreshers, { Refresh = BuildBlacklistGrid })
        elseif opt.type == "colorGroup" then
            if currentCard then FinalizeCard(currentCard) end
            local sectionKey = (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            currentCard = OptionsWidgets_CreateSectionCard(tab, anchor, sectionKey, GetCardCollapsed, SetCardCollapsed)
            local lbl = OptionsWidgets_CreateSectionHeader(currentCard, opt.name, sectionKey, GetCardCollapsed, SetCardCollapsed)
            currentCard.contentAnchor = lbl
            currentCard.contentHeight = CardPadding + RowHeights.sectionLabel
            anchor = currentCard
            local cardContent = currentCard.contentContainer or currentCard
            local keys = type(opt.keys) == "function" and opt.keys() or opt.keys or {}
            local defaultMap = opt.defaultMap or {}
            local swatches = {}
            for _, key in ipairs(keys) do
                local getTbl = function() local db = getDB(opt.dbKey, nil) return db and db[key] end
                local setKeyVal = function(v) addon.EnsureDB(); local _rdb = _G[addon.DB_NAME]; if not _rdb[opt.dbKey] then _rdb[opt.dbKey] = {} end; _rdb[opt.dbKey][key] = v; if not addon._colorPickerLive then notifyMainAddon() end end
                local def = defaultMap[key] or {0.5,0.5,0.5}
                local row = OptionsWidgets_CreateColorSwatchRow(cardContent, currentCard.contentAnchor, addon.L[(opt.labelMap and opt.labelMap[key]) or key:gsub("^%l", string.upper)], def, getTbl, setKeyVal, notifyMainAddon)
                currentCard.contentAnchor = row
                currentCard.contentHeight = currentCard.contentHeight + 4 + 24
                swatches[#swatches+1] = row
            end
            local resetBtn = OptionsWidgets_CreateButton(cardContent, L["Reset to defaults"], function()
                setDB(opt.dbKey, nil)
                setDB("sectionColors", nil)
                for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end
                notifyMainAddon()
            end, { width = 120, height = 22 })
            resetBtn:SetPoint("TOPLEFT", currentCard.contentAnchor, "BOTTOMLEFT", 0, -6)
            currentCard.contentAnchor = resetBtn
            currentCard.contentHeight = currentCard.contentHeight + 6 + 22
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = currentCard } end
            table.insert(refreshers, { Refresh = function() for _, sw in ipairs(swatches) do if sw.Refresh then sw:Refresh() end end end })
        elseif opt.type == "reorderList" then
            local w
            if currentCard then
                local cardContent = currentCard.contentContainer or currentCard
                local contentAnchor = currentCard.contentAnchor
                w = OptionsWidgets_CreateReorderList(cardContent, contentAnchor, opt, scrollFrame, panel, notifyMainAddon)
                currentCard.contentAnchor = w
                currentCard.contentHeight = currentCard.contentHeight + OptionGap + (w:GetHeight() or 0)
            else
                local reorderAnchor = anchor
                w = OptionsWidgets_CreateReorderList(tab, reorderAnchor, opt, scrollFrame, panel, notifyMainAddon)
                anchor = w
                currentCard = nil
            end
            local oid = opt.dbKey or (addon.OptionCategories[tabIndex].key .. "_" .. (opt.name or ""):gsub("%s+", "_"))
            if optionFrames then optionFrames[oid] = { tabIndex = tabIndex, frame = w } end
            table.insert(refreshers, w)
        end
    end
    if currentCard then FinalizeCard(currentCard) end
end

-- Build sidebar grouped by moduleKey (Modules, Focus, Presence)
-- Use "modules" as sentinel for nil (WoW Lua disallows nil as table index)
local MODULE_LABELS = { ["modules"] = L["Modules"], ["focus"] = L["Focus"], ["presence"] = L["Presence"], ["insight"] = L["Insight"] or "Insight", ["yield"] = L["Yield"], ["vista"] = L["Vista"] or "Vista" }
local groups = {}
for i, cat in ipairs(addon.OptionCategories) do
    local mk = cat.moduleKey or "modules"
    if not groups[mk] then groups[mk] = { label = MODULE_LABELS[mk] or L["Other"], categories = {} } end
    table.insert(groups[mk].categories, i)
end
local groupOrder = { "modules", "focus", "presence", "insight", "yield", "vista" }

local function UpdateTabVisuals()
    for _, btn in ipairs(tabButtons) do
        local sel = (btn.categoryIndex == selectedTab)
        btn.selected = sel
        SetTextColor(btn.label, sel and Def.TextColorNormal or Def.TextColorSection)
        if btn.leftAccent then btn.leftAccent:SetShown(sel) end
        if btn.highlight then btn.highlight:SetShown(sel) end
    end
end

local optionFrames = {}
local TAB_ROW_HEIGHT = 32
local HEADER_ROW_HEIGHT = 28
local SIDEBAR_TOP_PAD = 4
local COLLAPSE_ANIM_DUR = 0.18
local easeOut = addon.easeOut or function(t) return 1 - (1-t)*(1-t) end

local lastSidebarRow = nil
-- Sidebar group collapse state: persisted in optionsSidebarGroupCollapsed
local groupCollapsed = (_G[addon.DB_NAME] and _G[addon.DB_NAME].optionsSidebarGroupCollapsed) or {}
local function GetGroupCollapsed(mk) return groupCollapsed[mk] ~= false end
local function SetGroupCollapsed(mk, v)
    groupCollapsed[mk] = v
    local db = _G[addon.DB_NAME]
    if db then db.optionsSidebarGroupCollapsed = groupCollapsed end
end

for _, mk in ipairs(groupOrder) do
    local g = groups[mk]
    if not g or #g.categories == 0 then
        -- skip empty groups
    else
        g.tabButtons = {}
        local isStandalone = (mk == "modules" and #g.categories == 1)

        if isStandalone then
            -- Modules: single tab as standalone, no group header
            local catIdx = g.categories[1]
            local cat = addon.OptionCategories[catIdx]
            local btn = CreateFrame("Button", nil, sidebarContent)
            btn:SetSize(SIDEBAR_WIDTH, TAB_ROW_HEIGHT)
            if not lastSidebarRow then btn:SetPoint("TOPLEFT", sidebarContent, "TOPLEFT", 0, -SIDEBAR_TOP_PAD)
            else btn:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0) end
            lastSidebarRow = btn
            btn.categoryIndex = catIdx
            btn.label = btn:CreateFontString(nil, "OVERLAY")
            btn.label:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
            btn.label:SetPoint("LEFT", btn, "LEFT", 12, 0)
            btn.label:SetText(cat.name)
            btn.highlight = btn:CreateTexture(nil, "BACKGROUND")
            btn.highlight:SetAllPoints(btn)
            btn.highlight:SetColorTexture(1, 1, 1, 0.05)
            btn.hoverBg = btn:CreateTexture(nil, "BACKGROUND")
            btn.hoverBg:SetAllPoints(btn)
            btn.hoverBg:SetColorTexture(1, 1, 1, 0.03)
            btn.hoverBg:Hide()
            btn.leftAccent = btn:CreateTexture(nil, "OVERLAY")
            btn.leftAccent:SetWidth(3)
            btn.leftAccent:SetColorTexture(Def.AccentColor[1], Def.AccentColor[2], Def.AccentColor[3], Def.AccentColor[4] or 0.9)
            btn.leftAccent:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
            btn.leftAccent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
            btn:SetScript("OnClick", function()
                selectedTab = catIdx
                UpdateTabVisuals()
                for j = 1, #tabFrames do tabFrames[j]:SetShown(j == catIdx) end
                scrollFrame:SetScrollChild(tabFrames[catIdx])
                scrollFrame:SetVerticalScroll(0)
            end)
            btn:SetScript("OnEnter", function()
                if not btn.selected then
                    SetTextColor(btn.label, Def.TextColorHighlight)
                    if btn.hoverBg then btn.hoverBg:Show() end
                end
            end)
            btn:SetScript("OnLeave", function()
                if btn.hoverBg then btn.hoverBg:Hide() end
                UpdateTabVisuals()
            end)
            tabButtons[#tabButtons + 1] = btn
            local refreshers = {}
            local catOpts = type(cat.options) == "function" and cat.options() or cat.options
            BuildCategory(tabFrames[catIdx], catIdx, catOpts, refreshers, optionFrames)
            for _, r in ipairs(refreshers) do allRefreshers[#allRefreshers+1] = r end
            C_Timer.After(0, function() ResizeTabFrame(tabFrames[catIdx]) end)
        else
            -- Header row (clickable, collapsible)
            local header = CreateFrame("Button", nil, sidebarContent)
            header:SetSize(SIDEBAR_WIDTH, HEADER_ROW_HEIGHT)
            if not lastSidebarRow then header:SetPoint("TOPLEFT", sidebarContent, "TOPLEFT", 0, -SIDEBAR_TOP_PAD)
            else header:SetPoint("TOPLEFT", lastSidebarRow, "BOTTOMLEFT", 0, 0) end
            lastSidebarRow = header
            header.groupKey = mk
            header.hoverBg = header:CreateTexture(nil, "BACKGROUND")
            header.hoverBg:SetAllPoints(header)
            header.hoverBg:SetColorTexture(1, 1, 1, 0.03)
            header.hoverBg:Hide()
            local chevron = header:CreateFontString(nil, "OVERLAY")
            chevron:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) - 1, "OUTLINE")
            chevron:SetPoint("LEFT", header, "LEFT", 8, 0)
            SetTextColor(chevron, Def.TextColorSection)
            header.chevron = chevron
            local headerLabel = header:CreateFontString(nil, "OVERLAY")
            headerLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", (Def.LabelSize or 13) + 1, "OUTLINE")
            headerLabel:SetPoint("LEFT", chevron, "RIGHT", 4, 0)
            SetTextColor(headerLabel, Def.TextColorSection)
            headerLabel:SetText((g.label or ""):upper())
            -- Container for tab buttons (animates height on collapse)
            local tabsContainer = CreateFrame("Frame", nil, sidebarContent)
            tabsContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
            tabsContainer:SetWidth(SIDEBAR_WIDTH)
            tabsContainer:SetClipsChildren(true)
            local fullHeight = TAB_ROW_HEIGHT * #g.categories
            tabsContainer:SetHeight(GetGroupCollapsed(mk) and 0 or fullHeight)
            g.tabsContainer = tabsContainer
            g.header = header
            g.fullHeight = fullHeight
            -- Spacer anchored to header (not tabsContainer) so layout stays valid when tabsContainer collapses to 0.
            -- WoW can mishandle anchors to zero-height frames; using header + offset avoids that.
            local spacer = CreateFrame("Frame", nil, sidebarContent)
            spacer:SetSize(2, 2)
            spacer:SetAlpha(0)
            local function UpdateSpacerPosition()
                spacer:ClearAllPoints()
                spacer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -tabsContainer:GetHeight())
            end
            header.updateSpacer = UpdateSpacerPosition
            UpdateSpacerPosition()
            lastSidebarRow = spacer
            header:SetScript("OnClick", function()
                local collapsed = not GetGroupCollapsed(mk)
                SetGroupCollapsed(mk, collapsed)
                header.chevron:SetText(collapsed and "+" or "-")
                local fromH = tabsContainer:GetHeight()
                local toH = collapsed and 0 or fullHeight
                if fromH == toH then return end
                tabsContainer.animStart = GetTime()
                tabsContainer.animFrom = fromH
                tabsContainer.animTo = toH
                tabsContainer:SetScript("OnUpdate", function(self)
                    local elapsed = GetTime() - self.animStart
                    local t = math.min(elapsed / COLLAPSE_ANIM_DUR, 1)
                    local h = self.animFrom + (self.animTo - self.animFrom) * easeOut(t)
                    self:SetHeight(math.max(0, h))
                    UpdateSpacerPosition()
                    if t >= 1 then self:SetScript("OnUpdate", nil) end
                end)
            end)
            header:SetScript("OnEnter", function()
                header.hoverBg:Show()
                SetTextColor(headerLabel, Def.TextColorHighlight)
                SetTextColor(chevron, Def.TextColorHighlight)
            end)
            header:SetScript("OnLeave", function()
                header.hoverBg:Hide()
                SetTextColor(headerLabel, Def.TextColorSection)
                SetTextColor(chevron, Def.TextColorSection)
            end)
            local collapsed = GetGroupCollapsed(mk)
            chevron:SetText(collapsed and "+" or "-")
            -- Tab rows for each category in this group (parented to container)
            local containerAnchor = tabsContainer
            for _, catIdx in ipairs(g.categories) do
                local cat = addon.OptionCategories[catIdx]
                local btn = CreateFrame("Button", nil, tabsContainer)
                btn:SetSize(SIDEBAR_WIDTH, TAB_ROW_HEIGHT)
                local anchorPt = (containerAnchor == tabsContainer) and "TOPLEFT" or "BOTTOMLEFT"
                btn:SetPoint("TOPLEFT", containerAnchor, anchorPt, 0, 0)
                containerAnchor = btn
                btn.categoryIndex = catIdx
                btn.label = btn:CreateFontString(nil, "OVERLAY")
                btn.label:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 13, "OUTLINE")
                btn.label:SetPoint("LEFT", btn, "LEFT", 24, 0)
                btn.label:SetText(cat.name)
                btn.highlight = btn:CreateTexture(nil, "BACKGROUND")
                btn.highlight:SetAllPoints(btn)
                btn.highlight:SetColorTexture(1, 1, 1, 0.05)
                btn.hoverBg = btn:CreateTexture(nil, "BACKGROUND")
                btn.hoverBg:SetAllPoints(btn)
                btn.hoverBg:SetColorTexture(1, 1, 1, 0.03)
                btn.hoverBg:Hide()
                btn.leftAccent = btn:CreateTexture(nil, "OVERLAY")
                btn.leftAccent:SetWidth(3)
                btn.leftAccent:SetColorTexture(Def.AccentColor[1], Def.AccentColor[2], Def.AccentColor[3], Def.AccentColor[4] or 0.9)
                btn.leftAccent:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
                btn.leftAccent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
                btn:SetScript("OnClick", function()
                    selectedTab = catIdx
                    UpdateTabVisuals()
                    for j = 1, #tabFrames do tabFrames[j]:SetShown(j == catIdx) end
                    scrollFrame:SetScrollChild(tabFrames[catIdx])
                    scrollFrame:SetVerticalScroll(0)
                end)
                btn:SetScript("OnEnter", function()
                    if not btn.selected then
                        SetTextColor(btn.label, Def.TextColorHighlight)
                        if btn.hoverBg then btn.hoverBg:Show() end
                    end
                end)
                btn:SetScript("OnLeave", function()
                    if btn.hoverBg then btn.hoverBg:Hide() end
                    UpdateTabVisuals()
                end)
                tabButtons[#tabButtons + 1] = btn

                local refreshers = {}
                local catOpts = type(cat.options) == "function" and cat.options() or cat.options
                BuildCategory(tabFrames[catIdx], catIdx, catOpts, refreshers, optionFrames)
                for _, r in ipairs(refreshers) do allRefreshers[#allRefreshers+1] = r end
                C_Timer.After(0, function() ResizeTabFrame(tabFrames[catIdx]) end)
            end
        end
    end
end

-- After building sidebar content, size the scroll child so it can scroll
C_Timer.After(0, function()
    if not sidebarScrollChild or not lastSidebarRow then return end
    local top = sidebarScrollChild:GetTop()
    local bottom = lastSidebarRow:GetBottom()
    if top and bottom then
        local h = math.max(1, top - bottom + SIDEBAR_TOP_PAD)
        sidebarScrollChild:SetHeight(h)
    end
end)

-- ---------------------------------------------------------------------------
-- Class color accent tinting
-- ---------------------------------------------------------------------------
local defaultAccentColor = { Def.AccentColor[1], Def.AccentColor[2], Def.AccentColor[3], Def.AccentColor[4] or 0.9 }
local defaultTrackOn = { Def.TrackOn[1], Def.TrackOn[2], Def.TrackOn[3], Def.TrackOn[4] or 0.85 }

function addon.ApplyOptionsClassColor()
    local cc = addon.GetOptionsClassColor and addon.GetOptionsClassColor()
    if cc then
        Def.AccentColor = { cc[1], cc[2], cc[3], 0.9 }
        Def.TrackOn = { cc[1], cc[2], cc[3], 0.85 }
    else
        Def.AccentColor = { defaultAccentColor[1], defaultAccentColor[2], defaultAccentColor[3], defaultAccentColor[4] }
        Def.TrackOn = { defaultTrackOn[1], defaultTrackOn[2], defaultTrackOn[3], defaultTrackOn[4] }
    end
    -- Update sidebar left-accent bars
    for _, btn in ipairs(tabButtons) do
        if btn.leftAccent then
            btn.leftAccent:SetColorTexture(Def.AccentColor[1], Def.AccentColor[2], Def.AccentColor[3], Def.AccentColor[4])
        end
    end
    -- Update selected tab text color
    UpdateTabVisuals()
    -- Refresh all toggles and sliders so their track fills update
    for _, r in ipairs(allRefreshers) do
        if r and r.Refresh then r:Refresh() end
    end
end
-- Apply once on initial load (deferred so all widgets are built)
C_Timer.After(0.1, function()
    if addon.ApplyOptionsClassColor then addon.ApplyOptionsClassColor() end
end)

-- ---------------------------------------------------------------------------
-- Search: debounced filter, results dropdown, navigate to option
-- ---------------------------------------------------------------------------
local searchQuery = ""
local searchDebounceTimer = nil
local SEARCH_DEBOUNCE_MS = 180
local SEARCH_DROPDOWN_MAX_HEIGHT = 240
local SEARCH_DROPDOWN_ROW_HEIGHT = 34

local function NavigateToOption(entry)
    if not entry or not entry.optionId then return end
    local reg = optionFrames[entry.optionId]
    if not reg or not reg.frame then return end
    selectedTab = reg.tabIndex
    UpdateTabVisuals()
    for j = 1, #tabFrames do tabFrames[j]:SetShown(j == selectedTab) end
    scrollFrame:SetScrollChild(tabFrames[selectedTab])
    local frame = reg.frame
    -- Find the section card (may be frame itself or an ancestor)
    local card = frame
    while card and not card.sectionKey do card = card:GetParent() end
    -- Expand card if collapsed so the selected option is visible
    if card and card.sectionKey and card.contentContainer and GetCardCollapsed(card.sectionKey) then
        if card.header and card.header.Click then
            -- Reuse the same expand path as manual header toggles to keep anchors/animation/state in sync.
            card.header:Click()
        else
            SetCardCollapsed(card.sectionKey, false)
            card.contentContainer:SetShown(true)
            card:SetHeight(card.fullHeight or (card.contentHeight + CardBottomPadding))
            if card.header and card.header.chevron then card.header.chevron:SetText("-") end
            if card.header and card.header.UpdateCollapsedAnchors then card.header.UpdateCollapsedAnchors() end
        end
    end
    local child = scrollFrame:GetScrollChild()
    if child and frame then
        local frameTop = frame:GetTop()
        local childTop = child:GetTop()
        if frameTop and childTop then
            local offsetFromTop = math.max(0, childTop - frameTop)
            scrollFrame:SetVerticalScroll(math.max(0, offsetFromTop - 40))
        end
    end
    if frame and frame.SetAlpha then
        frame:SetAlpha(0.5)
        if C_Timer and C_Timer.After then
            C_Timer.After(0.5, function()
                if frame and frame.SetAlpha then frame:SetAlpha(1) end
            end)
        else
            frame:SetAlpha(1)
        end
    end
end

local searchDropdown = CreateFrame("Frame", nil, panel, "BackdropTemplate")
searchDropdown:SetFrameStrata("DIALOG")
searchDropdown:SetFrameLevel(panel:GetFrameLevel() + 10)
searchDropdown:SetPoint("TOPLEFT", searchRow, "BOTTOMLEFT", 0, -2)
searchDropdown:SetPoint("TOPRIGHT", searchRow, "BOTTOMRIGHT", 0, 0)
searchDropdown:SetHeight(SEARCH_DROPDOWN_MAX_HEIGHT)
searchDropdown:EnableMouse(true)
searchDropdown:Hide()
local sectionCardBackdrop = addon.OptionsWidgetsSectionCardBackdrop
if sectionCardBackdrop then
    searchDropdown:SetBackdrop(sectionCardBackdrop)
    local sdb = Def.SectionCardBg or { 0.09, 0.09, 0.11, 0.96 }
    searchDropdown:SetBackdropColor(sdb[1], sdb[2], sdb[3], 0.98)
    local bc = Def.SectionCardBorder or Def.BorderColor
    searchDropdown:SetBackdropBorderColor(bc[1], bc[2], bc[3], bc[4] or 1)
else
    local searchDropdownBg = searchDropdown:CreateTexture(nil, "BACKGROUND")
    searchDropdownBg:SetAllPoints(searchDropdown)
    local sdb = Def.SectionCardBg or { 0.09, 0.09, 0.11, 0.96 }
    searchDropdownBg:SetColorTexture(sdb[1], sdb[2], sdb[3], 0.98)
    addon.CreateBorder(searchDropdown, Def.SectionCardBorder or Def.BorderColor)
end
local searchDropdownScroll = CreateFrame("ScrollFrame", nil, searchDropdown)
searchDropdownScroll:SetPoint("TOPLEFT", searchDropdown, "TOPLEFT", 6, -6)
searchDropdownScroll:SetPoint("BOTTOMRIGHT", searchDropdown, "BOTTOMRIGHT", -6, 6)
searchDropdownScroll:EnableMouse(true)
searchDropdownScroll:EnableMouseWheel(true)
local searchDropdownContent = CreateFrame("Frame", nil, searchDropdownScroll)
searchDropdownContent:SetSize(1, 1)
searchDropdownContent:EnableMouse(true)
searchDropdownScroll:SetScrollChild(searchDropdownContent)
searchDropdownScroll:SetScript("OnMouseWheel", function(_, delta)
    local cur = searchDropdownScroll:GetVerticalScroll()
    local childH = searchDropdownContent:GetHeight() or 0
    local frameH = searchDropdownScroll:GetHeight() or 0
    searchDropdownScroll:SetVerticalScroll(math.max(0, math.min(cur - delta * 24, math.max(0, childH - frameH))))
end)
local searchDropdownButtons = {}
local searchDropdownSelected = 0

local searchDropdownCatch = CreateFrame("Button", nil, UIParent)
searchDropdownCatch:SetAllPoints(UIParent)
searchDropdownCatch:SetFrameStrata("DIALOG")
searchDropdownCatch:SetFrameLevel(panel:GetFrameLevel() + 5)
searchDropdownCatch:Hide()

local function HideSearchDropdown()
    searchDropdown:Hide()
    if searchDropdownCatch then searchDropdownCatch:Hide() end
end

local function ShowSearchResults(matches)
    if not matches or #matches == 0 then
        HideSearchDropdown()
        return
    end
    local num = math.min(#matches, 12)
    for i = 1, num do
        if not searchDropdownButtons[i] then
            local b = CreateFrame("Button", nil, searchDropdownContent)
            b:SetHeight(SEARCH_DROPDOWN_ROW_HEIGHT)
            b:SetPoint("LEFT", searchDropdownContent, "LEFT", 0, 0)
            b:SetPoint("RIGHT", searchDropdownContent, "RIGHT", 0, 0)
            b.subLabel = b:CreateFontString(nil, "OVERLAY")
            b.subLabel:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.SectionSize or 10, "OUTLINE")
            b.subLabel:SetPoint("TOPLEFT", b, "TOPLEFT", 8, -4)
            b.subLabel:SetJustifyH("LEFT")
            SetTextColor(b.subLabel, Def.TextColorSection)
            b.label = b:CreateFontString(nil, "OVERLAY")
            b.label:SetFont(Def.FontPath or "Fonts\\FRIZQT__.TTF", Def.LabelSize or 12, "OUTLINE")
            b.label:SetPoint("TOPLEFT", b.subLabel, "BOTTOMLEFT", 0, -1)
            b.label:SetJustifyH("LEFT")
            local hi = b:CreateTexture(nil, "BACKGROUND")
            hi:SetAllPoints(b)
            hi:SetColorTexture(1, 1, 1, 0.08)
            hi:Hide()
            b:SetScript("OnEnter", function()
                hi:Show()
                SetTextColor(b.label, Def.TextColorHighlight)
                SetTextColor(b.subLabel, Def.TextColorSection)
            end)
            b:SetScript("OnLeave", function()
                hi:Hide()
                SetTextColor(b.label, Def.TextColorLabel)
                SetTextColor(b.subLabel, Def.TextColorSection)
            end)
            searchDropdownButtons[i] = { btn = b, hi = hi }
        end
        local row = searchDropdownButtons[i]
        local m = matches[i]
        local breadcrumb
        if m.moduleLabel and m.moduleLabel ~= "" and m.moduleLabel ~= (m.categoryName or "") then
            breadcrumb = (m.moduleLabel or "") .. " \194\187 " .. (m.categoryName or "") .. " \194\187 " .. (m.sectionName or "")
        else
            breadcrumb = (m.categoryName or "") .. " \194\187 " .. (m.sectionName or "")
        end
        local rawName = m.option and (type(m.option.name) == "function" and m.option.name() or m.option.name) or nil
        local optionName = tostring(rawName or "")
        row.btn.subLabel:SetText(breadcrumb or "")
        row.btn.label:SetText(optionName)
        row.btn.entry = m
        row.btn:SetPoint("TOP", searchDropdownContent, "TOP", 0, -(i - 1) * SEARCH_DROPDOWN_ROW_HEIGHT)
        row.btn:SetScript("OnClick", function()
            NavigateToOption(row.btn.entry)
            HideSearchDropdown()
            if searchInput and searchInput.edit then searchInput.edit:ClearFocus() end
        end)
        row.btn:Show()
    end
    for i = num + 1, #searchDropdownButtons do
        if searchDropdownButtons[i] then searchDropdownButtons[i].btn:Hide() end
    end
    searchDropdownContent:SetHeight(num * SEARCH_DROPDOWN_ROW_HEIGHT)
    searchDropdownContent:SetWidth((searchDropdown:GetWidth() or 1) - 12)
    searchDropdownScroll:SetVerticalScroll(0)
    searchDropdownSelected = 0
    searchDropdown:Show()
    searchDropdownCatch:SetFrameLevel(panel:GetFrameLevel() + 5)
    searchDropdownCatch:Show()
end

local function FilterBySearch(query)
    searchQuery = query and query:trim():lower() or ""
    if searchQuery == "" then
        HideSearchDropdown()
        for i = 1, #tabFrames do tabFrames[i]:SetShown(i == selectedTab) end
        scrollFrame:SetScrollChild(tabFrames[selectedTab])
        UpdateTabVisuals()
        return
    end
    if #searchQuery < 2 then
        HideSearchDropdown()
        return
    end
    local index = addon.OptionsData_BuildSearchIndex and addon.OptionsData_BuildSearchIndex() or {}
    local matches = {}
    for _, entry in ipairs(index) do
        if entry.searchText and entry.searchText:find(searchQuery, 1, true) then
            matches[#matches + 1] = entry
        end
    end
    ShowSearchResults(matches)
end

local function OnSearchTextChanged(text)
    if searchDebounceTimer and searchDebounceTimer.Cancel then
        searchDebounceTimer:Cancel()
    end
    searchDebounceTimer = nil
    local delay = SEARCH_DEBOUNCE_MS / 1000
    if C_Timer and C_Timer.NewTimer then
        searchDebounceTimer = C_Timer.NewTimer(delay, function()
            searchDebounceTimer = nil
            FilterBySearch(text)
        end)
    elseif C_Timer and C_Timer.After then
        C_Timer.After(delay, function() FilterBySearch(text) end)
    else
        FilterBySearch(text)
    end
end

local searchInput = OptionsWidgets_CreateSearchInput(searchRow, OnSearchTextChanged, L["Search settings..."])
searchInput.clearBtn:SetFrameLevel(searchInput.edit:GetFrameLevel() + 1)
searchInput.edit:SetScript("OnEscapePressed", function()
    searchInput.edit:SetText("")
    if searchInput.edit.placeholder then searchInput.edit.placeholder:Show() end
    if searchInput.clearBtn then searchInput.clearBtn:Hide() end
    FilterBySearch("")
    HideSearchDropdown()
    searchInput.edit:ClearFocus()
end)

searchDropdownCatch:SetScript("OnClick", function() HideSearchDropdown() end)

-- Update panel fonts (called when font option changes or on show)
function updateOptionsPanelFonts()
    if not panel:IsShown() then return end
    local raw = addon.OptionsData_GetDB("fontPath", (addon.GetDefaultFontPath and addon.GetDefaultFontPath()) or "Fonts\\FRIZQT__.TTF")
    local path = (addon.ResolveFontPath and addon.ResolveFontPath(raw)) or raw
    local size = addon.OptionsData_GetDB("headerFontSize", 16)
    if OptionsWidgets_SetDef then OptionsWidgets_SetDef({ FontPath = path, HeaderSize = size }) end
    titleText:SetFont(path, size, "OUTLINE")
    closeLabel:SetFont(path, Def.LabelSize or 13, "OUTLINE")
    versionLabel:SetFont(path, Def.SectionSize or 10, "OUTLINE")
    for _, btn in ipairs(tabButtons) do if btn.label then btn.label:SetFont(path, Def.LabelSize or 13, "OUTLINE") end end
    if searchInput and searchInput.edit then
        searchInput.edit:SetFont(path, Def.LabelSize or 13, "OUTLINE")
        if searchInput.edit.placeholder then searchInput.edit.placeholder:SetFont(path, Def.LabelSize or 13, "OUTLINE") end
    end
    for _, row in ipairs(searchDropdownButtons) do
        if row.btn then
            if row.btn.label then row.btn.label:SetFont(path, Def.LabelSize or 12, "OUTLINE") end
            if row.btn.subLabel then row.btn.subLabel:SetFont(path, Def.SectionSize or 10, "OUTLINE") end
        end
    end
end
addon.OptionsData_SetUpdateFontsRef(updateOptionsPanelFonts)

-- OnShow
local ANIM_DUR = 0.2
local easeOut = addon.easeOut or function(t) return 1 - (1-t)*(1-t) end
panel:SetScript("OnShow", function()
    -- Reset main content and sidebar scroll to top
    if scrollFrame and scrollFrame.SetVerticalScroll then scrollFrame:SetVerticalScroll(0) end
    if sidebarScrollFrame and sidebarScrollFrame.SetVerticalScroll then sidebarScrollFrame:SetVerticalScroll(0) end
    -- Reset section cards to collapsed on each open
    for k in pairs(cardCollapsed) do cardCollapsed[k] = nil end
    local _cdb = _G[addon.DB_NAME]
    if _cdb then _cdb.optionsCardCollapsed = cardCollapsed end
    for _, card in ipairs(allCollapsibleCards) do
        if card and card.sectionKey and card.contentContainer and card.headerHeight then
            card.contentContainer:SetShown(false)
            card:SetHeight(card.headerHeight)
            if card.header and card.header.chevron then card.header.chevron:SetText("+") end
            if card.header and card.header.UpdateCollapsedAnchors then card.header.UpdateCollapsedAnchors() end
        end
    end
    -- Reset sidebar groups to collapsed on each open
    for _, mk in ipairs(groupOrder) do
        local g = groups[mk]
        if g and g.header and g.tabsContainer and g.fullHeight then
            SetGroupCollapsed(mk, true)
            g.header.chevron:SetText("+")
            g.tabsContainer:SetHeight(0)
            if g.header.updateSpacer then g.header.updateSpacer() end
        end
    end
    updateOptionsPanelFonts()
    -- Restore saved dimensions
    local _db = _G[addon.DB_NAME]
    if _db then
        if _db.optionsPanelWidth then
            panel:SetWidth(math.max(600, math.min(1400, _db.optionsPanelWidth)))
        end
        if _db.optionsPanelHeight then
            panel:SetHeight(math.max(500, math.min(1200, _db.optionsPanelHeight)))
        end
    end
    ApplyPanelDimensions()
    -- Restore saved position
    if _db and _db.optionsLeft ~= nil and _db.optionsTop ~= nil then
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", UIParent, "CENTER", _db.optionsLeft, _db.optionsTop)
    else
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    for _, ref in ipairs(allRefreshers) do if ref and ref.Refresh then ref:Refresh() end end
    panel:SetAlpha(0)
    panel.animStart = GetTime()
    panel.animating = "in"
    panel:SetScript("OnUpdate", function(self)
        local elapsed = GetTime() - self.animStart
        if elapsed >= ANIM_DUR then self:SetAlpha(1) self:SetScript("OnUpdate", nil) self.animating = nil return end
        self:SetAlpha(easeOut(elapsed / ANIM_DUR))
    end)
end)

addon.OptionsPanel_Refresh = function()
    local cardDeltas = {}
    for _, ref in ipairs(allRefreshers) do
        if ref and ref.Refresh then ref:Refresh() end
        if ref and ref._hiddenFn then
            local shouldHide = ref._hiddenFn()
            local wasHidden = not ref:IsShown() or (ref:GetHeight() < 1)
            if shouldHide and not wasHidden then
                ref:Hide()
                ref:SetHeight(0.1)
                if ref._parentCard then
                    local delta = (ref._normalHeight or 0) + (ref._gapHeight or 0)
                    cardDeltas[ref._parentCard] = (cardDeltas[ref._parentCard] or 0) - delta
                end
            elseif not shouldHide and wasHidden then
                ref:Show()
                if ref._normalHeight then ref:SetHeight(ref._normalHeight) end
                if ref._parentCard then
                    local delta = (ref._normalHeight or 0) + (ref._gapHeight or 0)
                    cardDeltas[ref._parentCard] = (cardDeltas[ref._parentCard] or 0) + delta
                end
            end
        end
    end
    for card, delta in pairs(cardDeltas) do
        if card.GetHeight and card.SetHeight then
            local h = card:GetHeight() + delta
            if h > 0 then card:SetHeight(h) end
        end
    end
end

function _G.HorizonSuite_OptionsRequestClose()
    if panel.animating == "out" then return end
    panel.animating = "out"
    panel.animStart = GetTime()
    panel:SetScript("OnUpdate", function(self)
        local elapsed = GetTime() - self.animStart
        if elapsed >= ANIM_DUR then self:SetAlpha(1) self:SetScript("OnUpdate", nil) self.animating = nil self:Hide() return end
        self:SetAlpha(1 - easeOut(elapsed / ANIM_DUR))
    end)
end
addon.OptionsRequestClose = _G.HorizonSuite_OptionsRequestClose

function _G.HorizonSuite_ShowOptions()
    local p = _G.HorizonSuiteOptionsPanel or panel
    if p then
        if p:IsShown() then
            if addon.OptionsRequestClose then addon.OptionsRequestClose() else p:Hide() end
        else
            p:Show()
            if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
            C_Timer.After(0.05, function()
                if addon.OptionsPanel_Refresh then addon.OptionsPanel_Refresh() end
                -- Reset scroll after layout; OnShow may run before content is sized
                if scrollFrame and scrollFrame.SetVerticalScroll then scrollFrame:SetVerticalScroll(0) end
                if sidebarScrollFrame and sidebarScrollFrame.SetVerticalScroll then sidebarScrollFrame:SetVerticalScroll(0) end
            end)
        end
    end
end
addon.ShowOptions = _G.HorizonSuite_ShowOptions

-- Rebuild a single options category tab by key (e.g. "VistaButtons")
addon.OptionsPanel_RebuildCategory = function(catKey)
    local cats = addon.OptionCategories
    if not cats then return end
    local catIdx
    for i, cat in ipairs(cats) do
        if cat.key == catKey then catIdx = i; break end
    end
    if not catIdx then return end
    local cat = cats[catIdx]
    local tab = tabFrames[catIdx]
    if not tab then return end

    -- Remove old refreshers belonging to this tab
    local newRefreshers = {}
    for _, r in ipairs(allRefreshers) do
        local belongs = false
        if r and r.GetParent then
            local p = r
            for _ = 1, 10 do
                p = p:GetParent()
                if not p then break end
                if p == tab then belongs = true; break end
            end
        end
        if not belongs then
            newRefreshers[#newRefreshers + 1] = r
        end
    end
    wipe(allRefreshers)
    for _, r in ipairs(newRefreshers) do allRefreshers[#allRefreshers + 1] = r end

    -- Wipe all children of the tab frame
    for _, child in ipairs({ tab:GetChildren() }) do
        child:Hide()
        child:ClearAllPoints()
        child:SetParent(nil)
    end

    -- Re-create top anchor and rebuild
    local top = CreateFrame("Frame", nil, tab)
    top:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, 0)
    top:SetSize(1, 1)
    tab.topAnchor = top

    local catOpts = type(cat.options) == "function" and cat.options() or cat.options
    local refreshers = {}
    BuildCategory(tab, catIdx, catOpts, refreshers, optionFrames)
    for _, r in ipairs(refreshers) do allRefreshers[#allRefreshers + 1] = r end
end

function _G.HorizonSuite_ShowEditPanel()
    if addon.ShowOptions then addon.ShowOptions()
    elseif _G.HorizonSuite_ShowOptions then _G.HorizonSuite_ShowOptions() end
end
addon.ShowEditPanel = _G.HorizonSuite_ShowEditPanel
