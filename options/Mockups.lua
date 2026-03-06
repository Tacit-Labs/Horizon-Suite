--[=[
    Horizon Suite - Radical Options Mockups (Not wired up)
    Run via slash commands: /mock1, /mock2, /mock3, /mock4
]=]
local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

local f1, f2, f3, f4

local FONT_PATH = "Fonts\\FRIZQT__.TTF"

-- Helper to make text
local function MakeText(parent, text, size, r,g,b, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetFont(FONT_PATH, size or 14, "OUTLINE")
    fs:SetText(text)
    fs:SetTextColor(r or 1, g or 1, b or 1)
    if justify then fs:SetJustifyH(justify) end
    return fs
end

-- Fake Widget Helpers
local function MakeFakeToggle(parent, label, x, y, state)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 30)
    f:SetPoint("TOPLEFT", x, y)
    local t = MakeText(f, label, 14, 0.8, 0.8, 0.8, "LEFT")
    t:SetPoint("LEFT", 0, 0)
    
    local btn = CreateFrame("Button", nil, f)
    btn:SetSize(40, 20)
    btn:SetPoint("RIGHT", 0, 0)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    btn.state = state or false
    
    local d = btn:CreateTexture(nil, "OVERLAY")
    d:SetSize(16, 16)
    
    local function UpdateVisuals()
        if btn.state then
            bg:SetColorTexture(0.2, 0.6, 1, 1)
            d:SetPoint("CENTER", btn, "RIGHT", -10, 0)
            d:SetColorTexture(1, 1, 1, 1)
        else
            bg:SetColorTexture(0.2, 0.2, 0.2, 1)
            d:SetPoint("CENTER", btn, "LEFT", 10, 0)
            d:SetColorTexture(0.5, 0.5, 0.5, 1)
        end
    end
    UpdateVisuals()
    
    btn:SetScript("OnClick", function()
        btn.state = not btn.state
        UpdateVisuals()
    end)
    return f
end

local function MakeFakeSlider(parent, label, x, y, val)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 40)
    f:SetPoint("TOPLEFT", x, y)
    local t = MakeText(f, label, 14, 0.8, 0.8, 0.8, "LEFT")
    t:SetPoint("TOPLEFT", 0, 0)
    
    local track = CreateFrame("Frame", nil, f)
    track:SetSize(200, 6)
    track:SetPoint("BOTTOMLEFT", 0, 5)
    local bg = track:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints() bg:SetColorTexture(0.2, 0.2, 0.2, 1)
    
    local fill = track:CreateTexture(nil, "ARTWORK")
    fill:SetSize(200 * (val or 0.5), 6)
    fill:SetPoint("LEFT") fill:SetColorTexture(0.2, 0.6, 1, 1)
    
    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 12)
    thumb:SetPoint("CENTER", track, "LEFT", 200 * (val or 0.5), 0)
    thumb:SetColorTexture(1, 1, 1, 1)
    
    local vTxt = MakeText(f, tostring(math.floor((val or 0.5)*100)), 12, 0.5, 0.5, 0.5)
    vTxt:SetPoint("BOTTOMRIGHT", 0, 15)
    
    return f
end

local function MakeFakeDropdown(parent, label, x, y, selected)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 45)
    f:SetPoint("TOPLEFT", x, y)
    local t = MakeText(f, label, 14, 0.8, 0.8, 0.8, "LEFT")
    t:SetPoint("TOPLEFT", 0, 0)
    
    local box = CreateFrame("Frame", nil, f)
    box:SetSize(200, 24)
    box:SetPoint("BOTTOMLEFT", 0, 0)
    local bg = box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints() bg:SetColorTexture(0.15, 0.15, 0.15, 1)
    
    local val = MakeText(box, selected or "Option 1", 13, 1, 1, 1, "LEFT")
    val:SetPoint("LEFT", 8, 0)
    
    local arrow = MakeText(box, "▼", 10, 0.5, 0.5, 0.5)
    arrow:SetPoint("RIGHT", -8, 0)
    
    return f
end

local function CloseAllMocks()
    if f1 then f1:Hide() end
    if f2 then f2:Hide() end
    if f3 then f3:Hide() end
    if f4 then f4:Hide() end
    if addon and addon.OptionsPanel then addon.OptionsPanel:Hide() end
end

-- ==========================================
-- Concept 1: The "Dashboard" Drill-Down
-- ==========================================
SLASH_HSMOCKONE1 = "/mock1"
SlashCmdList["HSMOCKONE"] = function()
    CloseAllMocks()
    if not f1 then
        f1 = CreateFrame("Frame", "HSMock1", UIParent, "BackdropTemplate")
        f1:SetFrameStrata("FULLSCREEN_DIALOG")
        f1:SetSize(900, 650)
        f1:SetPoint("CENTER")
        tinsert(UISpecialFrames, "HSMock1")
        
        -- Inner container to simulate a polished window
        local bg = f1:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.06, 0.06, 0.08, 0.98)
        
        -- Header
        local head = MakeText(f1, " Horizon Suite", 26, 1, 1, 1, "LEFT")
        head:SetPoint("TOPLEFT", 30, -30)
        local headSub = MakeText(f1, "Select a module to configure", 14, 0.5, 0.5, 0.5, "LEFT")
        headSub:SetPoint("TOPLEFT", 32, -60)

        -- Search Bar
        local searchBox = CreateFrame("EditBox", nil, f1)
        searchBox:SetSize(250, 40)
        searchBox:SetPoint("TOPRIGHT", -70, -30)
        searchBox:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
        searchBox:SetTextInsets(45, 10, 0, 0)
        searchBox:SetAutoFocus(false)
        
        local sbBorder = searchBox:CreateTexture(nil, "BACKGROUND")
        sbBorder:SetPoint("TOPLEFT", -2, 2)
        sbBorder:SetPoint("BOTTOMRIGHT", 2, -2)
        sbBorder:SetColorTexture(0.2, 0.2, 0.25, 1)

        local sbBg = searchBox:CreateTexture(nil, "BORDER")
        sbBg:SetAllPoints()
        sbBg:SetColorTexture(0.12, 0.13, 0.16, 1)
        
        local sbPlaceholder = MakeText(searchBox, "Search settings...", 14, 0.5, 0.5, 0.5, "LEFT")
        sbPlaceholder:SetPoint("LEFT", 45, 0)
        
        local sbIcon = searchBox:CreateTexture(nil, "ARTWORK")
        sbIcon:SetSize(18, 18)
        sbIcon:SetPoint("LEFT", 15, 0)
        sbIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
        sbIcon:SetVertexColor(0.5, 0.5, 0.5, 1)

        searchBox:SetScript("OnEditFocusGained", function(self)
            sbBorder:SetColorTexture(0.3, 0.6, 1, 1)
            sbPlaceholder:Hide()
            sbIcon:SetVertexColor(0.8, 0.8, 0.8, 1)
        end)
        searchBox:SetScript("OnEditFocusLost", function(self)
            sbBorder:SetColorTexture(0.2, 0.2, 0.25, 1)
            if self:GetText() == "" then
                sbPlaceholder:Show()
                sbIcon:SetVertexColor(0.5, 0.5, 0.5, 1)
            end
        end)
        searchBox:SetScript("OnTextChanged", function(self)
            if self:GetText() == "" and not self:HasFocus() then
                 sbPlaceholder:Show()
            else
                 sbPlaceholder:Hide()
            end
        end)
        searchBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)

        -- Detail view (hidden initially)
        local detailView = CreateFrame("Frame", nil, f1)
        detailView:SetSize(900, 650)
        detailView:SetPoint("CENTER")
        detailView:Hide()
        
        -- Animation for Detail View (Fade In)
        detailView.anim = detailView:CreateAnimationGroup()
        local dvAlpha = detailView.anim:CreateAnimation("Alpha")
        dvAlpha:SetFromAlpha(0)
        dvAlpha:SetToAlpha(1)
        dvAlpha:SetDuration(0.3)
        dvAlpha:SetSmoothing("OUT")
        detailView.anim:SetScript("OnFinished", function()
            detailView:ClearAllPoints()
            detailView:SetPoint("CENTER", 0, 0)
        end)
                
        -- Dashboard view
        local dashboardView = CreateFrame("Frame", nil, f1)
        dashboardView:SetSize(900, 650)
        dashboardView:SetPoint("CENTER")
        
        -- Animation for Dashboard (Fade Out)
        dashboardView.animOut = dashboardView:CreateAnimationGroup()
        local dbAlphaOut = dashboardView.animOut:CreateAnimation("Alpha")
        dbAlphaOut:SetFromAlpha(1)
        dbAlphaOut:SetToAlpha(0)
        dbAlphaOut:SetDuration(0.25)
        dbAlphaOut:SetSmoothing("OUT")
        dashboardView.animOut:SetScript("OnFinished", function() 
            dashboardView:Hide() 
            dashboardView:ClearAllPoints()
            dashboardView:SetPoint("CENTER", 0, 0)
        end)
        
        -- Animation for Dashboard (Fade In)
        dashboardView.animIn = dashboardView:CreateAnimationGroup()
        local dbAlphaIn = dashboardView.animIn:CreateAnimation("Alpha")
        dbAlphaIn:SetFromAlpha(0)
        dbAlphaIn:SetToAlpha(1)
        dbAlphaIn:SetDuration(0.3)
        dbAlphaIn:SetSmoothing("OUT")
        dashboardView.animIn:SetScript("OnFinished", function()
            dashboardView:ClearAllPoints()
            dashboardView:SetPoint("CENTER", 0, 0)
        end)
        
        -- Detail Top Bar
        local detailTopNav = CreateFrame("Frame", nil, detailView)
        detailTopNav:SetSize(900, 70)
        detailTopNav:SetPoint("TOP")
        local dtnBg = detailTopNav:CreateTexture(nil, "BACKGROUND")
        dtnBg:SetAllPoints() dtnBg:SetColorTexture(0.1, 0.1, 0.12, 1)
        
        local backBtn = CreateFrame("Button", nil, detailTopNav)
        backBtn:SetSize(40, 40)
        backBtn:SetPoint("LEFT", 20, 0)
        local backBg = backBtn:CreateTexture(nil, "BACKGROUND")
        backBg:SetAllPoints() backBg:SetColorTexture(0.15, 0.15, 0.18, 1)
        local backText = MakeText(backBtn, "<", 20)
        backText:SetPoint("CENTER", 0, 1)
        backBtn:SetScript("OnEnter", function() backBg:SetColorTexture(0.2, 0.2, 0.25, 1) end)
        backBtn:SetScript("OnLeave", function() backBg:SetColorTexture(0.15, 0.15, 0.18, 1) end)
        
        local detailTitle = MakeText(detailTopNav, "Module Name", 22, 0.9, 0.9, 0.9)
        detailTitle:SetPoint("LEFT", backBtn, "RIGHT", 20, 0)

        -- Detail Sidebar (Subcategories)
        local detailSidebar = CreateFrame("Frame", nil, detailView)
        detailSidebar:SetSize(220, 580)
        detailSidebar:SetPoint("BOTTOMLEFT", 0, 0)
        local dsBg = detailSidebar:CreateTexture(nil, "BACKGROUND")
        dsBg:SetAllPoints() dsBg:SetColorTexture(0.08, 0.08, 0.1, 1)
        
        local function MakeSideTab(text, yOff, isActive)
            local t = CreateFrame("Button", nil, detailSidebar)
            t:SetSize(220, 40)
            t:SetPoint("TOPLEFT", 0, yOff)
            local tbg = t:CreateTexture(nil, "BACKGROUND")
            tbg:SetAllPoints()
            tbg:SetColorTexture(0.15, 0.25, 0.5, isActive and 0.4 or 0)
            
            local marker = t:CreateTexture(nil, "OVERLAY")
            marker:SetSize(4, 40)
            marker:SetPoint("LEFT", 0,0)
            marker:SetColorTexture(0.3, 0.6, 1, isActive and 1 or 0)
            
            MakeText(t, text, 14, 1, 1, 1, "LEFT"):SetPoint("LEFT", 20,0)
        end
        
        MakeSideTab("Visuals & Scale", -20, true)
        MakeSideTab("Typography", -60, false)
        MakeSideTab("Behavior", -100, false)
        MakeSideTab("Content Filters", -140, false)
        MakeSideTab("Advanced", -180, false)

        local mockContent = CreateFrame("Frame", nil, detailView)
        mockContent:SetSize(680, 580)
        mockContent:SetPoint("BOTTOMRIGHT", 0, 0)
        
        -- Store cards to manage collapse state
        local detailCards = {}
        
        -- Helper to build expandable dashboard-style cards
        local function BuildExpandableCard(parent, title, desc, iconAtlas, collapsedHeight, expandedHeight)
            local card = CreateFrame("Button", nil, parent)
            card:SetSize(620, collapsedHeight)
            -- Anchor will be set by the layout manager later
            
            local cBg = card:CreateTexture(nil, "BACKGROUND")
            cBg:SetAllPoints() cBg:SetColorTexture(0.12, 0.12, 0.14, 1)
            
            local accent = card:CreateTexture(nil, "OVERLAY")
            accent:SetSize(4, collapsedHeight)
            accent:SetPoint("LEFT")
            accent:SetColorTexture(0.12, 0.12, 0.14, 1)
            
            local ic = card:CreateTexture(nil, "ARTWORK")
            ic:SetSize(32, 32)
            ic:SetPoint("TOPLEFT", 20, -14)
            ic:SetTexture("Interface\\Icons\\" .. iconAtlas)
            ic:SetVertexColor(1, 1, 1, 0.7)
            
            local cTitle = MakeText(card, title, 16, 0.9, 0.9, 0.9, "LEFT")
            cTitle:SetPoint("TOPLEFT", 65, -16)
            
            local cDesc = MakeText(card, desc, 12, 0.5, 0.5, 0.5, "LEFT")
            cDesc:SetPoint("TOPLEFT", 65, -36)
            
            local line = card:CreateTexture(nil, "ARTWORK")
            line:SetSize(580, 1)
            line:SetPoint("TOPLEFT", 20, -60)
            line:SetColorTexture(0.2, 0.2, 0.2, 1)
            line:Hide() -- Hidden when collapsed
            
            -- Frame to hold the actual settings widgets (hidden initially)
            local settingsContainer = CreateFrame("Frame", nil, card)
            settingsContainer:SetPoint("TOPLEFT", 0, -70)
            settingsContainer:SetPoint("BOTTOMRIGHT", 0, 0)
            settingsContainer:Hide()
            
            card.expanded = false
            card:SetClipsChildren(true)
            
            -- Size Animation setup (using Alpha as a timer)
            card.anim = card:CreateAnimationGroup()
            local sizeAnim = card.anim:CreateAnimation("Alpha")
            sizeAnim:SetFromAlpha(0)
            sizeAnim:SetToAlpha(1)
            sizeAnim:SetDuration(0.2)
            sizeAnim:SetSmoothing("OUT")
            card.sizeAnim = sizeAnim
            
            card.anim:SetScript("OnPlay", function()
                if card.expanded then
                    line:Show()
                    settingsContainer:Show()
                else
                    -- Ensure it's still visible while collapsing
                    settingsContainer:Show()
                end
            end)
            
            card.anim:SetScript("OnUpdate", function()
                local p = sizeAnim:GetSmoothProgress()
                local startH = card.aniStartH or collapsedHeight
                local endH = card.aniEndH or expandedHeight
                card:SetHeight(startH + (endH - startH) * p)
                
                -- Fade the contents in or out alongside the height change
                if card.expanded then
                    settingsContainer:SetAlpha(p)
                else
                    settingsContainer:SetAlpha(1 - p)
                end
                
                if parent.UpdateLayout then parent:UpdateLayout() end
            end)

            card.anim:SetScript("OnFinished", function()
                if not card.expanded then
                    line:Hide()
                    settingsContainer:Hide()
                end
                card:SetHeight(card.expanded and expandedHeight or collapsedHeight)
                if parent.UpdateLayout then parent:UpdateLayout() end
            end)
            
            card:SetScript("OnEnter", function()
                if not card.expanded then
                    cBg:SetColorTexture(0.16, 0.17, 0.20, 1)
                    accent:SetColorTexture(0.3, 0.6, 1, 1)
                    ic:SetVertexColor(1, 1, 1, 1)
                end
            end)
            card:SetScript("OnLeave", function()
                if not card.expanded then
                    cBg:SetColorTexture(0.12, 0.12, 0.14, 1)
                    accent:SetColorTexture(0.12, 0.12, 0.14, 1)
                    ic:SetVertexColor(1, 1, 1, 0.7)
                end
            end)
            
            card:SetScript("OnClick", function()
                card.expanded = not card.expanded
                
                if card.expanded then
                    cBg:SetColorTexture(0.12, 0.12, 0.14, 1)
                    accent:SetColorTexture(0.3, 0.6, 1, 1)
                    ic:SetVertexColor(1, 1, 1, 1)
                    card.aniStartH = collapsedHeight
                    card.aniEndH = expandedHeight
                    
                    -- Optional: Collapse other cards
                    for _, otherCard in ipairs(detailCards) do
                        if otherCard ~= card and otherCard.expanded then
                            otherCard.expanded = false
                            otherCard.cBg:SetColorTexture(0.12, 0.12, 0.14, 1)
                            otherCard.accent:SetColorTexture(0.12, 0.12, 0.14, 1)
                            otherCard.ic:SetVertexColor(1, 1, 1, 0.7)
                            otherCard.aniStartH = otherCard:GetHeight()
                            otherCard.aniEndH = otherCard.collapsedHeight
                            otherCard.anim:Play()
                        end
                    end
                else
                    accent:SetColorTexture(0.12, 0.12, 0.14, 1)
                    ic:SetVertexColor(1, 1, 1, 0.7)
                    card.aniStartH = expandedHeight
                    card.aniEndH = collapsedHeight
                end
                
                card.anim:Play()
            end)
            
            card.collapsedHeight = collapsedHeight
            card.expandedHeight = expandedHeight
            card.cBg = cBg
            card.accent = accent
            card.ic = ic
            card.settingsContainer = settingsContainer
            
            table.insert(detailCards, card)
            return card, settingsContainer
        end
        
        -- Layout manager
        mockContent.UpdateLayout = function(self)
            local yOffset = -20
            -- Wait a frame or do it manually if animation is playing
            local function Layout()
                for i, card in ipairs(detailCards) do
                    card:ClearAllPoints()
                    card:SetPoint("TOPLEFT", 30, yOffset)
                    yOffset = yOffset - card:GetHeight() - 15 -- 15px gap
                end
            end
            
            -- We update in an OnUpdate if any animation is playing, to make the layout smooth
            local isAnimating = false
            for _, card in ipairs(detailCards) do
                if card.anim:IsPlaying() then isAnimating = true break end
            end
            
            if isAnimating then
                self:SetScript("OnUpdate", function()
                    local anyAnim = false
                    for _, card in ipairs(detailCards) do
                        if card.anim:IsPlaying() then anyAnim = true break end
                    end
                    Layout()
                    if not anyAnim then self:SetScript("OnUpdate", nil) end
                end)
            else
                Layout()
            end
        end
        
        local card1, sc1 = BuildExpandableCard(mockContent, "General", "Module toggle, Global Scaling, Combat visibility", "INV_Misc_Wrench_01", 60, 260)
        MakeFakeToggle(sc1, "Enable Module", 20, -20, true)
        MakeFakeDropdown(sc1, "Display Style", 20, -70, "Minimalistic")
        MakeFakeSlider(sc1, "Global Scale", 300, -20, 0.8)
        MakeFakeToggle(sc1, "Show in Combat", 300, -70, false)
        MakeFakeSlider(sc1, "Spacing Between Items", 20, -120, 0.3)
        
        local card2, sc2 = BuildExpandableCard(mockContent, "Layout Setup", "Headers, Opacity, Progress Bars Styles", "INV_Misc_Map_01", 60, 200)
        MakeFakeToggle(sc2, "Show Section Headers", 20, -20, true)
        MakeFakeToggle(sc2, "Highlight Active Quest", 20, -70, false)
        MakeFakeSlider(sc2, "Panel Opacity", 300, -20, 1.0)
        MakeFakeDropdown(sc2, "Progress Bar Style", 300, -70, "Flat Block")
        
        local card3, sc3 = BuildExpandableCard(mockContent, "Typography", "Fonts, Text sizes, Shadows", "Spell_Shadow_Penance", 60, 200)
        MakeFakeDropdown(sc3, "Header Font", 20, -20, "Friz Quadrata")
        MakeFakeSlider(sc3, "Header Size", 300, -20, 0.6)
        MakeFakeDropdown(sc3, "Objective Font", 20, -70, "Friz Quadrata")
        MakeFakeSlider(sc3, "Objective Size", 300, -70, 0.4)

        -- Initial layout setup
        mockContent:UpdateLayout()

        backBtn:SetScript("OnClick", function()
            detailView:Hide()
            dashboardView:Show()
            
            dashboardView:ClearAllPoints()
            dashboardView:SetPoint("CENTER", 0, 0)
            dashboardView.animIn:Play()
            
            head:Show()
            headSub:Show()
        end)

        -- 4 big tiles
        local function MakeTile(name, atlas, desc, x, y)
            local btn = CreateFrame("Button", nil, dashboardView)
            btn:SetSize(380, 180)
            btn:SetPoint("CENTER", x, y)
            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints() bg:SetColorTexture(0.12, 0.13, 0.16, 1)
            
            -- Accent line
            local accent = btn:CreateTexture(nil, "OVERLAY")
            accent:SetSize(4, 180)
            accent:SetPoint("LEFT")
            accent:SetColorTexture(0.12, 0.13, 0.16, 1)
            
            local ic = btn:CreateTexture(nil, "ARTWORK")
            ic:SetSize(40, 40)
            ic:SetPoint("BOTTOMRIGHT", -20, 20)
            ic:SetTexture("Interface\\Icons\\" .. atlas)
            ic:SetVertexColor(1, 1, 1, 0.7)

            btn:SetScript("OnEnter", function() 
                bg:SetColorTexture(0.18, 0.20, 0.25, 1)
                accent:SetColorTexture(0.3, 0.6, 1, 1)
                ic:SetVertexColor(1, 1, 1, 1)
            end)
            btn:SetScript("OnLeave", function() 
                bg:SetColorTexture(0.12, 0.13, 0.16, 1)
                accent:SetColorTexture(0.12, 0.13, 0.16, 1)
                ic:SetVertexColor(1, 1, 1, 0.7)
            end)
            btn:SetScript("OnClick", function()
                detailTitle:SetText(name)
                
                -- Play outgoing dashboard anim
                dashboardView:ClearAllPoints()
                dashboardView:SetPoint("CENTER", 0, 0)
                dashboardView.animOut:Play()
                head:Hide()
                headSub:Hide()
                
                -- Play incoming detail anim
                detailView:Show()
                detailView:ClearAllPoints()
                detailView:SetPoint("CENTER", 0, 0)
                detailView.anim:Play()
            end)
            
            local t = MakeText(btn, name, 22, 1, 1, 1, "LEFT")
            t:SetPoint("TOPLEFT", 30, -30)
            
            local d = MakeText(btn, desc, 13, 0.6, 0.6, 0.6, "LEFT")
            d:SetPoint("TOPLEFT", 30, -60)
        end

        MakeTile("Core Settings", "INV_Misc_Wrench_01", "Profiles\nModule Toggles\nGlobal UI Scale\nClass Colors", -200, 60)
        MakeTile("Focus (Objective Tracker)", "INV_Misc_Map_01", "Quest Tracking\nLayout & Visuals\nClick Behaviors\nFonts & Spacing", 200, 60)
        MakeTile("Vista (Minimap)", "INV_Misc_Spyglass_02", "Shape & Borders\nCoordinates & Time\nAddon Button Collector", -200, -140)
        MakeTile("Presence (Notifications)", "INV_Misc_Note_01", "Zone transitions\nLoot Toasts\nBoss Emotes", 200, -140)
        
        local close = CreateFrame("Button", nil, f1)
        close:SetSize(30, 30)
        close:SetPoint("TOPRIGHT", -20, -20)
        local cbg = close:CreateTexture(nil,"BACKGROUND") cbg:SetAllPoints() cbg:SetColorTexture(1,0,0,0.5)
        MakeText(close, "X", 16):SetPoint("CENTER")
        close:SetScript("OnClick", function() f1:Hide() end)
    end
    f1:Show()
end

-- ==========================================
-- Concept 2: The WYSIWYG
-- ==========================================
SLASH_HSMOCKTWO1 = "/mock2"
SlashCmdList["HSMOCKTWO"] = function()
    CloseAllMocks()
    if not f2 then
        f2 = CreateFrame("Frame", "HSMock2", UIParent)
        f2:SetFrameStrata("FULLSCREEN_DIALOG")
        f2:SetAllPoints()
        
        f2.bg = f2:CreateTexture(nil, "BACKGROUND")
        f2.bg:SetAllPoints()
        f2.bg:SetColorTexture(0, 0, 0, 0.7)

        local overlayText = MakeText(f2, "WYSIWYG Mode: Click a UI element to configure it", 24, 1, 1, 1)
        overlayText:SetPoint("TOP", 0, -100)

        -- Side settings drawer
        local drawer = CreateFrame("Frame", nil, f2)
        drawer:SetSize(400, GetScreenHeight())
        drawer:SetPoint("RIGHT", 0, 0)
        drawer.bg = drawer:CreateTexture(nil, "BACKGROUND")
        drawer.bg:SetAllPoints()
        drawer.bg:SetColorTexture(0.08, 0.08, 0.08, 0.98)
        drawer:Hide()
        
        local drawerTitle = MakeText(drawer, "Module Settings", 24)
        drawerTitle:SetPoint("TOPLEFT", 30, -40)
        
        -- Tracker specific fake widgets
        local trackerWidgets = CreateFrame("Frame", nil, drawer)
        trackerWidgets:SetAllPoints() trackerWidgets:Hide()
        MakeFakeDropdown(trackerWidgets, "Tracker Theme", 30, -100, "Dark Glass")
        MakeFakeSlider(trackerWidgets, "Width", 30, -160, 0.6)
        MakeFakeSlider(trackerWidgets, "Line Spacing", 30, -220, 0.4)
        MakeFakeToggle(trackerWidgets, "Show Progress Bars within objectives", 30, -280, true)
        MakeFakeToggle(trackerWidgets, "Auto-collapse in Dungeons", 30, -320, true)
        
        -- Minimap specific fake widgets
        local mapWidgets = CreateFrame("Frame", nil, drawer)
        mapWidgets:SetAllPoints() mapWidgets:Hide()
        MakeFakeDropdown(mapWidgets, "Minimap Shape", 30, -100, "Circular")
        MakeFakeToggle(mapWidgets, "Show Zone Text", 30, -160, true)
        MakeFakeSlider(mapWidgets, "Border Thickness", 30, -210, 0.2)
        MakeFakeToggle(mapWidgets, "Collect Addon Buttons", 30, -260, true)

        -- Fake Tracker Model
        local fakeTracker = CreateFrame("Button", nil, f2)
        fakeTracker:SetSize(280, 450)
        fakeTracker:SetPoint("RIGHT", -60, 0)
        fakeTracker.bg = fakeTracker:CreateTexture(nil, "BACKGROUND")
        fakeTracker.bg:SetAllPoints()
        fakeTracker.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
        
        -- Fake Tracker Contents
        MakeText(fakeTracker, "Campaign", 16, 0.8, 0.6, 0.2, "LEFT"):SetPoint("TOPLEFT", 10, -10)
        MakeText(fakeTracker, "0/1 Cool objective", 12, 0.8, 0.8, 0.8, "LEFT"):SetPoint("TOPLEFT", 20, -30)
        MakeText(fakeTracker, "In-Zone Quests", 16, 0.4, 0.7, 1, "LEFT"):SetPoint("TOPLEFT", 10, -60)
        MakeText(fakeTracker, "0/10 Gather things", 12, 0.8, 0.8, 0.8, "LEFT"):SetPoint("TOPLEFT", 20, -80)
        
        fakeTracker:SetScript("OnEnter", function() fakeTracker.bg:SetColorTexture(0.2, 0.3, 0.5, 0.6) end)
        fakeTracker:SetScript("OnLeave", function() fakeTracker.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6) end)
        fakeTracker:SetScript("OnClick", function()
            drawerTitle:SetText("Tracker Setup")
            mapWidgets:Hide()
            trackerWidgets:Show()
            drawer:Show()
            fakeTracker:SetPoint("RIGHT", -440, 0) -- move left to make room
        end)

        -- Fake Minimap Model
        local fakeMap = CreateFrame("Button", nil, f2)
        fakeMap:SetSize(220, 220)
        fakeMap.bg = fakeMap:CreateTexture(nil, "BACKGROUND")
        fakeMap.bg:SetAllPoints()
        fakeMap.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)
        fakeMap:SetPoint("TOPRIGHT", -40, -40)
        MakeText(fakeMap, "Valdrakken", 14, 1, 1, 1):SetPoint("TOP", 0, -10)
        MakeText(fakeMap, "12:00", 12, 0.8,0.8,0.8):SetPoint("BOTTOM", 0, 10)
        
        fakeMap:SetScript("OnEnter", function() fakeMap.bg:SetColorTexture(0.2, 0.4, 0.3, 0.6) end)
        fakeMap:SetScript("OnLeave", function() fakeMap.bg:SetColorTexture(0.1, 0.1, 0.1, 0.6) end)
        fakeMap:SetScript("OnClick", function()
            drawerTitle:SetText("Minimap Setup")
            trackerWidgets:Hide()
            mapWidgets:Show()
            drawer:Show()
            fakeTracker:SetPoint("RIGHT", -60, 0)
        end)

        local close = CreateFrame("Button", nil, f2)
        close:SetSize(120, 40)
        close:SetPoint("BOTTOM", 0, 50)
        local cbg = close:CreateTexture(nil,"BACKGROUND") cbg:SetAllPoints() cbg:SetColorTexture(1,0,0,0.8)
        MakeText(close, "Exit WYSIWYG", 14):SetPoint("CENTER")
        close:SetScript("OnClick", function() 
            f2:Hide() 
            drawer:Hide() 
            fakeTracker:SetPoint("RIGHT", -60, 0) 
        end)
    end
    f2:Show()
end

-- ==========================================
-- Concept 3: Modern Desktop (Horizontal nav + Grid)
-- ==========================================
SLASH_HSMOCKTHREE1 = "/mock3"
SlashCmdList["HSMOCKTHREE"] = function()
    CloseAllMocks()
    if not f3 then
        f3 = CreateFrame("Frame", "HSMock3", UIParent, "BackdropTemplate")
        f3:SetFrameStrata("FULLSCREEN_DIALOG")
        f3:SetSize(900, 640)
        f3:SetPoint("CENTER")
        f3.bg = f3:CreateTexture(nil, "BACKGROUND")
        f3.bg:SetAllPoints()
        f3.bg:SetColorTexture(0.06, 0.06, 0.07, 0.98)

        -- Top Nav
        local navBar = CreateFrame("Frame", nil, f3)
        navBar:SetSize(900, 60)
        navBar:SetPoint("TOP")
        navBar.bg = navBar:CreateTexture(nil, "BACKGROUND")
        navBar.bg:SetAllPoints()
        navBar.bg:SetColorTexture(0.1, 0.1, 0.12, 1)

        local btns = {}
        local function MakeNavBtn(txt, x)
            local b = CreateFrame("Button", nil, navBar)
            b:SetSize(160, 60)
            b:SetPoint("LEFT", x, 0)
            local t = MakeText(b, txt, 16, 0.5,0.5,0.5)
            t:SetPoint("CENTER")
            local activeLine = b:CreateTexture(nil, "OVERLAY")
            activeLine:SetSize(120, 3)
            activeLine:SetPoint("BOTTOM", 0, 0)
            activeLine:SetColorTexture(0.4, 0.7, 1, 1)
            activeLine:Hide()
            
            b:SetScript("OnEnter", function() t:SetTextColor(1,1,1) end)
            b:SetScript("OnLeave", function() if not b.active then t:SetTextColor(0.5,0.5,0.5) end end)
            b:SetScript("OnClick", function()
                for _, other in ipairs(btns) do
                    other.active = false
                    other.text:SetTextColor(0.5, 0.5, 0.5)
                    other.activeLine:Hide()
                end
                b.active = true
                t:SetTextColor(1,1,1)
                activeLine:Show()
            end)
            
            b.text = t
            b.activeLine = activeLine
            table.insert(btns, b)
            return b, activeLine, t
        end

        local b1 = MakeNavBtn("General", 30)
        local b2 = MakeNavBtn("Objective Tracker", 200)
        local b3 = MakeNavBtn("Minimap", 380)
        local b4 = MakeNavBtn("Notifications", 540)

        b2.active = true
        b2.text:SetTextColor(1,1,1)
        b2.activeLine:Show()

        -- Masonry grid of cards (mocking columns)
        local function MakeCard(title, x, y, w, h)
            local c = CreateFrame("Frame", nil, f3)
            c:SetSize(w, h)
            c:SetPoint("TOPLEFT", x, y)
            c.bg = c:CreateTexture(nil, "BACKGROUND")
            c.bg:SetAllPoints()
            c.bg:SetColorTexture(0.12, 0.12, 0.14, 1)
            
            local ct = MakeText(c, title, 16, 0.9, 0.9, 0.9, "LEFT")
            ct:SetPoint("TOPLEFT", 20, -20)
            return c
        end

        -- Populate Col 1
        local c1 = MakeCard("Visuals & Layout", 40, -100, 250, 340)
        MakeFakeToggle(c1, "Minimal Mode", 20, -60, false)
        MakeFakeSlider(c1, "Panel Opacity", 20, -110, 0.8)
        MakeFakeDropdown(c1, "Progress Bar Style", 20, -180, "Flat Block")
        MakeFakeToggle(c1, "Show Section Headers", 20, -240, true)
        MakeFakeToggle(c1, "Highlight Active Quest", 20, -290, true)

        local c2 = MakeCard("Typography", 40, -460, 250, 150)
        MakeFakeDropdown(c2, "Global Font", 20, -60, "Friz Quadrata")
        
        -- Populate Col 2
        local c3 = MakeCard("Behavior", 320, -100, 250, 420)
        local MakeFakeSettingsLabel = MakeText(c3, "Click Actions", 12, 0.5, 0.5, 0.5, "LEFT")
        MakeFakeSettingsLabel:SetPoint("TOPLEFT", 20, -60)
        MakeFakeToggle(c3, "Use Classic Clicks", 20, -80, false)
        MakeFakeToggle(c3, "Require Ctrl to Untrack", 20, -130, true)
        
        MakeText(c3, "Tracking Logic", 12, 0.5, 0.5, 0.5, "LEFT"):SetPoint("TOPLEFT", 20, -200)
        MakeFakeToggle(c3, "Keep Campaign at Top", 20, -220, true)
        MakeFakeToggle(c3, "Auto-track from Log", 20, -270, true)
        MakeFakeDropdown(c3, "Sort Order", 20, -330, "Distance")

        -- Populate Col 3
        local c4 = MakeCard("Content Filters", 600, -100, 250, 250)
        MakeFakeToggle(c4, "Show In-Zone World Quests", 20, -60, true)
        MakeFakeToggle(c4, "Show Scenario Events", 20, -110, true)
        MakeFakeToggle(c4, "Show Related Achievements", 20, -160, false)
        MakeFakeToggle(c4, "Untrack when Complete", 20, -210, true)

        local c5 = MakeCard("Advanced", 600, -370, 250, 180)
        MakeFakeToggle(c5, "Permanently Blacklist", 20, -60, false)
        MakeFakeDropdown(c5, "Floating Item Anchor", 20, -110, "Right of Quest")

        
        local close = CreateFrame("Button", nil, f3)
        close:SetSize(30, 30)
        close:SetPoint("TOPRIGHT", -15, -15)
        local cbg = close:CreateTexture(nil,"BACKGROUND") cbg:SetAllPoints() cbg:SetColorTexture(1,0,0,0.5)
        MakeText(close, "X", 16):SetPoint("CENTER")
        close:SetScript("OnClick", function() f3:Hide() end)
    end
    f3:Show()
end

-- ==========================================
-- Concept 4: Spotlight
-- ==========================================
SLASH_HSMOCKFOUR1 = "/mock4"
SlashCmdList["HSMOCKFOUR"] = function()
    CloseAllMocks()
    if not f4 then
        f4 = CreateFrame("Frame", "HSMock4", UIParent)
        f4:SetFrameStrata("FULLSCREEN_DIALOG")
        f4:SetSize(600, 80)
        f4:SetPoint("CENTER", 0, 150)
        f4.bg = f4:CreateTexture(nil, "BACKGROUND")
        f4.bg:SetAllPoints()
        f4.bg:SetColorTexture(0.08, 0.08, 0.1, 0.98)

        -- Search Bar
        local searchBox = CreateFrame("EditBox", nil, f4)
        searchBox:SetSize(560, 40)
        searchBox:SetPoint("TOPLEFT", 20, -10)
        searchBox:SetFontObject("GameFontNormalLarge")
        searchBox:SetAutoFocus(false)
        searchBox:SetText("Search for a setting... (e.g., 'Scale')")
        searchBox:SetTextColor(0.5, 0.5, 0.5)
        
        -- Tags
        local function MakeTag(txt, x)
            local t = CreateFrame("Button", nil, f4)
            t:SetSize(90, 24)
            t:SetPoint("TOPLEFT", x, -55)
            local tb = t:CreateTexture(nil, "BACKGROUND") tb:SetAllPoints() tb:SetColorTexture(0.15,0.15,0.18,1)
            local tt = MakeText(t, txt, 12, 0.6, 0.8, 1)
            tt:SetPoint("CENTER")
            
            t:SetScript("OnEnter", function() tb:SetColorTexture(0.2,0.2,0.25,1) end)
            t:SetScript("OnLeave", function() tb:SetColorTexture(0.15,0.15,0.18,1) end)
            
            t:SetScript("OnClick", function()
                f4:SetHeight(480)
                searchBox:SetText("Tag: " .. txt)
                searchBox:SetTextColor(1,1,1)
            end)
        end

        MakeTag("#Tracker", 20)
        MakeTag("#Minimap", 120)
        MakeTag("#Colors", 220)
        MakeTag("#Advanced", 320)

        local fakeResults = CreateFrame("Frame", nil, f4)
        fakeResults:SetSize(560, 360)
        fakeResults:SetPoint("BOTTOM", 0, 20)
        fakeResults.bg = fakeResults:CreateTexture(nil, "BACKGROUND")
        fakeResults.bg:SetAllPoints() fakeResults.bg:SetColorTexture(0.05,0.05,0.06,1)
        
        -- Populate fake results list
        MakeText(fakeResults, "Scale Results", 16, 1, 1, 1, "LEFT"):SetPoint("TOPLEFT", 20, -20)
        MakeFakeSlider(fakeResults, "Tracker UI Scale", 20, -60, 1.0)
        MakeFakeSlider(fakeResults, "Minimap Scale", 300, -60, 1.0)
        
        local div = fakeResults:CreateTexture(nil, "ARTWORK")
        div:SetSize(520, 1) div:SetPoint("TOPLEFT", 20, -120) div:SetColorTexture(0.2,0.2,0.2,1)
        
        MakeText(fakeResults, "Typography Scale", 16, 1, 1, 1, "LEFT"):SetPoint("TOPLEFT", 20, -140)
        MakeFakeSlider(fakeResults, "Header Text Size", 20, -180, 0.6)
        MakeFakeSlider(fakeResults, "Objective Text Size", 300, -180, 0.4)
        
        searchBox:SetScript("OnEditFocusGained", function(s) 
            s:SetText("Scale")
            s:SetTextColor(1,1,1)
            f4:SetHeight(480)
        end)

        local btnReset = CreateFrame("Button", nil, f4)
        btnReset:SetSize(80, 20)
        btnReset:SetPoint("TOPRIGHT", -20, -55)
        local btnRTxt = MakeText(btnReset, "Reset View", 12, 0.5,0.5,0.5)
        btnRTxt:SetPoint("CENTER")
        btnReset:SetScript("OnClick", function()
            f4:SetHeight(90)
            searchBox:SetText("Search for a setting... (e.g., 'Scale')")
            searchBox:SetTextColor(0.5,0.5,0.5)
            searchBox:ClearFocus()
        end)

        local close = CreateFrame("Button", nil, f4)
        close:SetSize(30, 30)
        close:SetPoint("TOPRIGHT", -10, -10)
        local cbg = close:CreateTexture(nil,"BACKGROUND") cbg:SetAllPoints() cbg:SetColorTexture(1,0,0,0.5)
        MakeText(close, "X", 16):SetPoint("CENTER")
        close:SetScript("OnClick", function() 
            f4:Hide() 
            f4:SetHeight(90)
            searchBox:ClearFocus()
        end)
    end
    f4:Show()
    f4:SetHeight(90) 
end
