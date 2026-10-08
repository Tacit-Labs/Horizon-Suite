--[[
    Horizon Suite - News story view and story tag lines.
    The tag line (module chips, posted date, "X is off · Turn on") drawn under story titles,
    and the story view: one story opened inside the News page, with a back link, its art,
    the full body (paragraphs and bullet lists) and its buttons.
    Helpers come from DashboardShowcase.lua (addon.Showcase); wired from
    addon.DashboardShowcase_InitNews(env).
]]

local addon = _G.HorizonSuite
if not addon then return end

local Showcase = addon.Showcase
if not Showcase then return end

local floor, max, min = math.floor, math.max, math.min
local tinsert = table.insert

-- ============================================================================
-- LAYOUT NUMBERS
-- ============================================================================

-- Tag line
local TAG_ROW_H = 16
local TAG_ICON = 13
local TAG_ICON_GAP = 4
local TAG_CHIP_GAP = 10
local TAG_SIZE = 11
local TAG_MAX_CHIPS = 3
local SEP = "  \194\183  "
local MUTED_R, MUTED_G, MUTED_B = 0.58, 0.61, 0.66
local OFF_R, OFF_G, OFF_B = 0.42, 0.43, 0.47

-- Story view
local BACK_H = 20
local BACK_CHEVRON_W = 14     -- chevron box plus the gap before the label
local BACK_TO_PANEL = 12
local STORY_PAD = 28
local STORY_TEXT_MAX_W = 640  -- reading measure for the body column
local STORY_IMG_MAX_H = 260
local STORY_TITLE_SIZE = 20
local STORY_BODY_SIZE = 13
local STORY_LINE_SPACING = 3
local TITLE_TO_TAGS = 8
local TAGS_TO_BODY = 18
local BLOCK_GAP = 12
local LIST_ITEM_GAP = 6
local LIST_INDENT = 18
local LIST_DOT = 5
local LIST_DOT_X = 4
local BODY_TO_BUTTONS = 22
local BUTTON_H = 28
local BUTTON_GAP = 10
local CONTENT_BOTTOM_PAD = 8
local OPEN_FADE = 0.15

local function Loc(key, fallback)
    local L = addon.L
    local v = L and L[key]
    if type(v) == "string" and v ~= "" then return v end
    return fallback
end

local function SingleLine(fs)
    if fs.SetWordWrap then fs:SetWordWrap(false) end
    if fs.SetJustifyV then fs:SetJustifyV("MIDDLE") end
    return fs
end

local function StringW(fs)
    return math.ceil((fs and fs:GetStringWidth() or 0) + 1)
end

-- ============================================================================
-- STORY TEXT
-- ============================================================================

--- The story's short text: its summary, else its first paragraph.
function Showcase.StorySummary(story)
    if not story then return nil end
    if type(story.summary) == "string" and story.summary ~= "" then return story.summary end
    local p = story.paragraphs and story.paragraphs[1]
    if type(p) == "string" and p ~= "" then return p end
    return nil
end

--- The story body as blocks; legacy stories (paragraphs only) become paragraph blocks.
function Showcase.StoryBlocks(story)
    if type(story) ~= "table" then return {} end
    if type(story.blocks) == "table" and #story.blocks > 0 then return story.blocks end
    local out = {}
    for _, p in ipairs(story.paragraphs or {}) do
        if type(p) == "string" and p ~= "" then out[#out + 1] = { kind = "p", text = p } end
    end
    if #out == 0 and type(story.summary) == "string" and story.summary ~= "" then
        out[1] = { kind = "p", text = story.summary }
    end
    return out
end

--- True when opening the story shows more than its summary.
--- Text that only repeats the summary (the summary paragraph itself, or a release
--- story's single bullet) doesn't count.
function Showcase.StoryHasMore(story)
    local summary = Showcase.StorySummary(story)
    for _, b in ipairs(Showcase.StoryBlocks(story)) do
        if b.kind == "list" and type(b.items) == "table" then
            for _, item in ipairs(b.items) do
                if item ~= summary then return true end
            end
        elseif b.text ~= summary then
            return true
        end
    end
    return false
end

-- ============================================================================
-- MODULES
-- ============================================================================

local function ModuleRGB(env, key)
    local colors = env and env.TILE_MODULE_LABEL_COLORS
    local c = colors and colors[key]
    if c then return c[1], c[2], c[3] end
    return Showcase.Accent(env)
end

local function ModuleName(key)
    return (addon.Dashboard_BrandModule and addon.Dashboard_BrandModule(key)) or key
end

local function ModuleIconPath(key)
    local icon = addon.DashboardModuleIcons and addon.DashboardModuleIcons[key]
    if not icon then return nil end
    if addon.DashboardModuleIconPath then return addon.DashboardModuleIconPath(icon) end
    return icon
end

local function IsModuleOn(key)
    if key == "axis" then return true end
    -- Saved on but failed to start still counts as on: "Turn on" couldn't fix that.
    local db = _G[addon.DATABASE or "HorizonDB"]
    local saved = type(db) == "table" and type(db.modules) == "table" and db.modules[key]
    if type(saved) == "table" and saved.enabled == true then return true end
    if addon.IsModuleEnabled then return addon:IsModuleEnabled(key) and true or false end
    return true
end

-- ============================================================================
-- TAG LINE
-- ============================================================================

--- Module chips, then the posted date, then "Vista is off · Turn on" when a tagged
--- module is off. A plain Frame of textures and font strings: only "Turn on" takes the
--- mouse, so clicks elsewhere reach the story block underneath.
--- @return Frame with :Update(story, width) -> height (0 when there is nothing to show)
function Showcase.MakeTagLine(parent, env)
    local line = CreateFrame("Frame", nil, parent)
    line:SetFrameLevel((parent:GetFrameLevel() or 0) + 2)
    line._env = env
    line._chips = {}
    line._texts = {}

    local turnOn = Showcase.MakeButton(line, env, Loc("DASH_NEWS_TURN_ON", "Turn on"), false, TAG_SIZE)
    turnOn:SetHeight(TAG_ROW_H)
    turnOn:SetOnClick(function()
        local f = env and env.f
        if f and f.ShowDashboard then f.ShowDashboard() end
    end)
    turnOn:Hide()
    line._turnOn = turnOn

    local function Chip(i)
        local c = line._chips[i]
        if not c then
            c = {}
            c.icon = line:CreateTexture(nil, "ARTWORK")
            c.icon:SetSize(TAG_ICON, TAG_ICON)
            c.text = SingleLine(Showcase.MakeText(env, line, "", TAG_SIZE, 1, 1, 1, "LEFT"))
            c.text:SetHeight(TAG_ROW_H)
            line._chips[i] = c
        end
        return c
    end

    local function Text(i)
        local fs = line._texts[i]
        if not fs then
            fs = SingleLine(Showcase.MakeText(env, line, "", TAG_SIZE, MUTED_R, MUTED_G, MUTED_B, "LEFT"))
            fs:SetHeight(TAG_ROW_H)
            line._texts[i] = fs
        end
        return fs
    end

    function line:Update(story, width)
        width = max(1, floor(width or 1))
        local x, row, used = 0, 0, false
        local nChips, nTexts = 0, 0

        -- Reserve w on the current row, wrapping when it won't fit. lead is what goes
        -- before the item on the same row: SEP (a separator font string) or a gap in px.
        -- It is reserved together with the item and dropped on a wrap, so a row never
        -- starts with a separator. @return x, y offsets of the item
        local function Reserve(w, lead)
            local sep, leadW = nil, 0
            if x > 0 and lead == SEP then
                nTexts = nTexts + 1
                sep = Text(nTexts)
                sep:SetText(SEP)
                sep:SetTextColor(MUTED_R, MUTED_G, MUTED_B)
                leadW = StringW(sep)
                sep:SetWidth(leadW)
            elseif x > 0 and type(lead) == "number" then
                leadW = lead
            end
            if x > 0 and x + leadW + w > width then
                x = 0
                row = row + 1
                leadW = 0
                if sep then
                    sep:Hide()
                    sep = nil
                end
            end
            if sep then
                sep:ClearAllPoints()
                sep:SetPoint("TOPLEFT", self, "TOPLEFT", x, -(row * TAG_ROW_H))
                sep:Show()
            end
            x = x + leadW
            local px, py = x, row * TAG_ROW_H
            x = x + w
            used = true
            return px, py
        end

        local function PutText(text, r, g, b, lead)
            nTexts = nTexts + 1
            local fs = Text(nTexts)
            fs:SetText(text)
            fs:SetTextColor(r, g, b)
            local w = StringW(fs)
            fs:SetWidth(w)
            local px, py = Reserve(w, lead)
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", self, "TOPLEFT", px, -py)
            fs:Show()
        end

        local offKey
        local keys = (type(story) == "table" and type(story.modules) == "table") and story.modules or {}
        for i = 1, #keys do
            if nChips >= TAG_MAX_CHIPS then break end
            local key = keys[i]
            if type(key) == "string" and key ~= "" then
                nChips = nChips + 1
                local c = Chip(nChips)
                local on = IsModuleOn(key)
                if not on and not offKey then offKey = key end
                local r, g, b = ModuleRGB(env, key)
                if not on then r, g, b = OFF_R, OFF_G, OFF_B end
                local path = ModuleIconPath(key)
                c.text:SetText(ModuleName(key))
                c.text:SetTextColor(r, g, b)
                local tw = StringW(c.text)
                c.text:SetWidth(tw)
                local hasIcon = path ~= nil
                local w = (hasIcon and (TAG_ICON + TAG_ICON_GAP) or 0) + tw
                local px, py = Reserve(w, TAG_CHIP_GAP)
                if hasIcon then
                    c.icon:SetTexture(path)
                    c.icon:SetVertexColor(r, g, b, 1)
                    c.icon:ClearAllPoints()
                    c.icon:SetPoint("TOPLEFT", self, "TOPLEFT", px, -(py + floor((TAG_ROW_H - TAG_ICON) / 2)))
                    c.icon:Show()
                    px = px + TAG_ICON + TAG_ICON_GAP
                else
                    c.icon:Hide()
                end
                c.text:ClearAllPoints()
                c.text:SetPoint("TOPLEFT", self, "TOPLEFT", px, -py)
                c.text:Show()
            end
        end
        for i = nChips + 1, #self._chips do
            self._chips[i].icon:Hide()
            self._chips[i].text:Hide()
        end

        local NL = addon.NewsLogic
        local posted = NL and NL.PostedLabel and type(story) == "table"
            and NL.PostedLabel(story.fromDate, NL.Today and NL.Today() or "")
        if posted then
            PutText(posted, MUTED_R, MUTED_G, MUTED_B, SEP)
        end

        local btn = self._turnOn
        if offKey then
            PutText(Loc("DASH_NEWS_MODULE_OFF_X", "%s is off"):format(ModuleName(offKey)), MUTED_R, MUTED_G, MUTED_B, SEP)
            btn:SetLabel(Loc("DASH_NEWS_TURN_ON", "Turn on"))
            btn:PaintAccent()
            local px, py = Reserve(btn:GetWidth() or 40, SEP)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", self, "TOPLEFT", px, -py)
            btn:Show()
        else
            btn:Hide()
        end
        for i = nTexts + 1, #self._texts do self._texts[i]:Hide() end

        local h = used and ((row + 1) * TAG_ROW_H) or 0
        self:SetSize(width, max(1, h))
        if used then self:Show() else self:Hide() end
        return h
    end

    line:Hide()
    return line
end

-- ============================================================================
-- STORY VIEW
-- ============================================================================

-- "< All news": a drawn chevron (Unicode arrows render as squares in some dashboard
-- fonts) and an accent text link that underlines on hover.
local function MakeBackLink(parent, env)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(BACK_H)
    btn:SetFrameLevel((parent:GetFrameLevel() or 0) + 3)
    btn._env = env

    local chev = CreateFrame("Frame", nil, btn)
    chev:SetSize(8, 10)
    chev:SetPoint("LEFT", btn, "LEFT", 1, 0)
    if chev.CreateLine then
        local l1, l2 = chev:CreateLine(nil, "OVERLAY"), chev:CreateLine(nil, "OVERLAY")
        l1:SetThickness(1.5)
        l2:SetThickness(1.5)
        -- "<": tip at (-2.25, 0), arms out to (2.25, +-4.5).
        l1:SetStartPoint("CENTER", chev, 2.25, 4.5)
        l1:SetEndPoint("CENTER", chev, -2.25, 0)
        l2:SetStartPoint("CENTER", chev, 2.25, -4.5)
        l2:SetEndPoint("CENTER", chev, -2.25, 0)
        btn._lines = { l1, l2 }
    else
        btn._chevText = SingleLine(Showcase.MakeText(env, btn, "<", 12, 1, 1, 1, "LEFT"))
        btn._chevText:SetPoint("LEFT", btn, "LEFT", 0, 0)
    end

    btn._label = SingleLine(Showcase.MakeText(env, btn, "", 12, 1, 1, 1, "LEFT"))
    btn._label:SetPoint("LEFT", btn, "LEFT", BACK_CHEVRON_W, 0)
    local underline = btn:CreateTexture(nil, "OVERLAY")
    underline:SetHeight(1)
    underline:SetPoint("TOPLEFT", btn._label, "BOTTOMLEFT", 0, -1)
    underline:SetPoint("TOPRIGHT", btn._label, "BOTTOMRIGHT", 0, -1)
    underline:Hide()
    btn._underline = underline

    function btn:SetLabel(text)
        self._label:SetText(text or "")
        self:SetWidth(max(40, BACK_CHEVRON_W + StringW(self._label) + 4))
    end

    function btn:PaintAccent()
        local r, g, b = Showcase.Accent(self._env)
        local hover = self._hover
        local tr, tg, tb = Showcase.Lighten(r, g, b, hover and 0.65 or 0.35)
        self._label:SetTextColor(tr, tg, tb)
        if self._lines then
            for _, l in ipairs(self._lines) do l:SetColorTexture(tr, tg, tb, 1) end
        elseif self._chevText then
            self._chevText:SetTextColor(tr, tg, tb)
        end
        self._underline:SetColorTexture(r, g, b, 0.75)
        if hover then self._underline:Show() else self._underline:Hide() end
    end

    btn:SetScript("OnEnter", function(self) self._hover = true; self:PaintAccent() end)
    btn:SetScript("OnLeave", function(self) self._hover = false; self:PaintAccent() end)
    Showcase.RegisterAccent(env, btn)
    btn:SetLabel(Loc("DASH_NEWS_BACK", "All news"))
    btn:PaintAccent()
    return btn
end

local function MakeDot(parent)
    local Round = addon.Echo and addon.Echo.Round
    local tex
    if Round and Round.Dot then
        tex = Round.Dot(parent, LIST_DOT, "ARTWORK")
    else
        tex = parent:CreateTexture(nil, "ARTWORK")
        tex:SetColorTexture(1, 1, 1, 1)
        tex:SetSize(LIST_DOT - 1, LIST_DOT - 1)
    end
    return tex
end

--- Build the story view inside the News page. It has its own scroll frame laid over the
--- list's, so the list keeps its scroll position while a story is open.
--- @param newsView Frame
--- @param env table the News page's story env (f, newsSeen, TILE_MODULE_LABEL_COLORS, ...)
--- @param listScroll ScrollFrame the News list's scroll frame
--- @param hooks table|nil { onOpen = fn(story), onClose = fn() }
--- @return table view with :Open(story), :Close() -> boolean, :IsOpen(), :Layout(width)
function Showcase.CreateStoryView(newsView, env, listScroll, hooks)
    hooks = hooks or {}
    local view = {}
    local BODY_R, BODY_G, BODY_B = Showcase.BODY_RGB[1], Showcase.BODY_RGB[2], Showcase.BODY_RGB[3]

    local scroll = CreateFrame("ScrollFrame", nil, newsView, "UIPanelScrollFrameTemplate")
    scroll:SetFrameLevel(listScroll:GetFrameLevel() or ((newsView:GetFrameLevel() or 0) + 2))
    if scroll.ScrollBar then
        scroll.ScrollBar:Hide()
        scroll.ScrollBar:ClearAllPoints()
    end
    scroll:SetAllPoints(listScroll)
    scroll:Hide()

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(400, 1)
    scroll:SetScrollChild(content)
    if addon.Dashboard_ApplySmoothScroll then
        addon.Dashboard_ApplySmoothScroll(scroll, content, 60, true)
    end
    view.scroll = scroll

    local back = MakeBackLink(content, env)
    back:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    back:SetScript("OnClick", function() view:Close() end)

    local panel = Showcase.MakePanel(content, env)
    local art = panel:CreateTexture(nil, "ARTWORK", nil, 0)
    art:Hide()

    local title = Showcase.MakeText(env, panel, "", STORY_TITLE_SIZE, Showcase.HeadingRGB())
    local refs = env and env.dashAccentRefs
    if refs and refs.headingTexts then tinsert(refs.headingTexts, title) end

    local tags = Showcase.MakeTagLine(panel, env)

    local paras, items = {}, {}   -- pools: paragraph font strings; { dot, fs } list rows

    local function Para(i)
        local fs = paras[i]
        if not fs then
            fs = Showcase.MakeText(env, panel, "", STORY_BODY_SIZE, BODY_R, BODY_G, BODY_B, "LEFT")
            if fs.SetSpacing then fs:SetSpacing(STORY_LINE_SPACING) end
            paras[i] = fs
        end
        return fs
    end

    local function Item(i)
        local it = items[i]
        if not it then
            it = {}
            it.fs = Showcase.MakeText(env, panel, "", STORY_BODY_SIZE, BODY_R, BODY_G, BODY_B, "LEFT")
            if it.fs.SetSpacing then it.fs:SetSpacing(STORY_LINE_SPACING) end
            it.dot = MakeDot(panel)
            items[i] = it
        end
        return it
    end

    local function DispatchButton(action, label)
        Showcase.DispatchAction(env and env.f, action, label)
    end

    local btn1 = Showcase.MakeButton(panel, env, "", true)
    btn1:SetOnClick(function()
        local s = view.story
        if s then DispatchButton(s.action, s.button or s.title) end
    end)
    local btn2 = Showcase.MakeOutline(Showcase.MakeButton(panel, env, "", true))
    btn2:SetOnClick(function()
        local s = view.story
        if s then DispatchButton(s.action2, s.button2 or s.title) end
    end)

    local function ShowButton(btn, label, action)
        if type(label) == "string" and label ~= "" and type(action) == "table" then
            btn:SetLabel(label)
            btn:PaintAccent()
            btn:Show()
            return true
        end
        btn:Hide()
        return false
    end

    -- Vertical offset that centres a list dot on the first line of fs.
    local function DotOffset(fs)
        local _, fontH = fs:GetFont()
        fontH = tonumber(fontH) or STORY_BODY_SIZE
        return max(0, floor((fontH - LIST_DOT) / 2 + 1.5))
    end

    function view:Layout(width)
        local story = self.story
        if not story then return end
        width = max(280, floor(width or self._width or listScroll:GetWidth() or 400))
        self._width = width
        content:SetWidth(width)

        back:SetLabel(Loc("DASH_NEWS_BACK", "All news"))
        back:PaintAccent()

        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(BACK_H + BACK_TO_PANEL))
        panel:SetWidth(width)

        local y = 0
        local image = story.image
        if story.layout == "featured" and type(image) == "string" and image ~= "" then
            local imgH = min(STORY_IMG_MAX_H, floor(width / 2 + 0.5))
            art:SetTexture(image)
            art:ClearAllPoints()
            art:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
            art:SetSize(width, imgH)
            Showcase.CropFill(art, width, imgH, 0.5, 0.5)
            art:Show()
            y = imgH
        else
            art:Hide()
        end

        local x = STORY_PAD
        local colW = max(1, min(width - STORY_PAD * 2, STORY_TEXT_MAX_W))
        y = y + STORY_PAD

        title:SetWidth(colW)
        title:SetText(story.title or "")
        title:SetTextColor(Showcase.HeadingRGB())
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", panel, "TOPLEFT", x, -y)
        y = y + Showcase.TextHeight(title)

        local th = tags:Update(story, colW)
        if th > 0 then
            y = y + TITLE_TO_TAGS
            tags:ClearAllPoints()
            tags:SetPoint("TOPLEFT", panel, "TOPLEFT", x, -y)
            y = y + th
        end

        local blocks = Showcase.StoryBlocks(story)
        local nParas, nItems = 0, 0
        if #blocks > 0 then y = y + TAGS_TO_BODY end
        for bi = 1, #blocks do
            local b = blocks[bi]
            if bi > 1 then y = y + BLOCK_GAP end
            if b.kind == "list" and type(b.items) == "table" then
                for ii = 1, #b.items do
                    if ii > 1 then y = y + LIST_ITEM_GAP end
                    nItems = nItems + 1
                    local it = Item(nItems)
                    it.fs:SetWidth(max(1, colW - LIST_INDENT))
                    it.fs:SetText(tostring(b.items[ii]))
                    it.fs:ClearAllPoints()
                    it.fs:SetPoint("TOPLEFT", panel, "TOPLEFT", x + LIST_INDENT, -y)
                    it.fs:Show()
                    it.dot:SetVertexColor(BODY_R, BODY_G, BODY_B, 0.9)
                    it.dot:ClearAllPoints()
                    it.dot:SetPoint("TOPLEFT", panel, "TOPLEFT", x + LIST_DOT_X, -(y + DotOffset(it.fs)))
                    it.dot:Show()
                    y = y + Showcase.TextHeight(it.fs)
                end
            else
                nParas = nParas + 1
                local fs = Para(nParas)
                fs:SetWidth(colW)
                fs:SetText(tostring(b.text or ""))
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", panel, "TOPLEFT", x, -y)
                fs:Show()
                y = y + Showcase.TextHeight(fs)
            end
        end
        for i = nParas + 1, #paras do paras[i]:Hide() end
        for i = nItems + 1, #items do
            items[i].fs:Hide()
            items[i].dot:Hide()
        end

        local has1 = ShowButton(btn1, story.button, story.action)
        local has2 = ShowButton(btn2, story.button2, story.action2)
        if has1 or has2 then
            y = y + BODY_TO_BUTTONS
            local bx = x
            if has1 then
                btn1:ClearAllPoints()
                btn1:SetPoint("TOPLEFT", panel, "TOPLEFT", bx, -y)
                bx = bx + (btn1:GetWidth() or 96) + BUTTON_GAP
            end
            if has2 then
                btn2:ClearAllPoints()
                btn2:SetPoint("TOPLEFT", panel, "TOPLEFT", bx, -y)
            end
            y = y + BUTTON_H
        end
        y = y + STORY_PAD

        local panelH = floor(y + 0.5)
        panel:SetHeight(panelH)
        content:SetHeight(BACK_H + BACK_TO_PANEL + panelH + CONTENT_BOTTOM_PAD)
        if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
        local maxScroll = max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
        if (scroll:GetVerticalScroll() or 0) > maxScroll then
            scroll:SetVerticalScroll(maxScroll)
            scroll.targetScroll = nil
        end
    end

    function view:IsOpen()
        return self.story ~= nil
    end

    function view:Open(story, width)
        if type(story) ~= "table" then return end
        self.story = story
        if hooks.onOpen then hooks.onOpen(story) end
        self:Layout(width)
        scroll.targetScroll = nil
        scroll:SetScript("OnUpdate", nil)
        scroll:SetVerticalScroll(0)
        listScroll:Hide()
        scroll:Show()
        if UIFrameFadeIn then
            UIFrameFadeIn(scroll, OPEN_FADE, 0, 1)
        else
            scroll:SetAlpha(1)
        end
        -- Text heights settle a frame after first SetText on some clients.
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function() if self.story == story then self:Layout() end end)
        end
    end

    --- @return boolean true when a story was open
    function view:Close()
        if not self.story then return false end
        self.story = nil
        scroll:Hide()
        listScroll:Show()
        if hooks.onClose then hooks.onClose() end
        return true
    end

    return view
end
