--[[
    Horizon Suite - LoggerPanel
    Generic live-debug panel factory backed by addon.Log.

    Creates a draggable ScrollingMessageFrame panel per log tag.
    Registers a ring-buffer listener with addon.Log automatically so that
    addon.Log.debug(tag, ...) feeds the panel whenever the tag is enabled.

    Usage (in any module's init block):
        local myPanel = addon.Log.createPanel("focus", "Focus Debug", {
            maxLines = 300,
            onClose  = function() SetFocusDebugLive(false) end,
        })
        myPanel.Show()
        myPanel.Hide()
        myPanel.Toggle()
        myPanel.Clear()
        myPanel.GetText()   -- returns ring-buffer as plain text for clipboard

    The shared copy-fallback dialog (an editable scrollable text frame) is
    reused across all panels — only one exists at a time.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Log then return end

-- ============================================================================
-- SHARED COPY FALLBACK  (one frame reused across all panels)
-- ============================================================================

local copyFallbackFrame

local function ShowCopyFallback(text, panelTitle)
    if not text or text == "" then return end
    if not copyFallbackFrame then
        copyFallbackFrame = CreateFrame("Frame", "HorizonSuiteLogCopyFallbackFrame", UIParent)
        copyFallbackFrame:SetSize(520, 380)
        copyFallbackFrame:SetPoint("CENTER")
        copyFallbackFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        copyFallbackFrame:SetClampedToScreen(true)

        local bg = copyFallbackFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(copyFallbackFrame)
        bg:SetColorTexture(0.05, 0.05, 0.08, 0.98)

        local hdr = copyFallbackFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        hdr:SetPoint("TOP", 0, -16)
        copyFallbackFrame.hdr = hdr

        local closeBtn = CreateFrame("Button", nil, copyFallbackFrame, "UIPanelButtonTemplate")
        closeBtn:SetSize(100, 22)
        closeBtn:SetPoint("BOTTOM", 0, 14)
        closeBtn:SetText("Close")
        closeBtn:SetScript("OnClick", function() copyFallbackFrame:Hide() end)

        local scroll = CreateFrame("ScrollFrame", nil, copyFallbackFrame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 14, -42)
        scroll:SetPoint("BOTTOMRIGHT", -28, 46)

        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(true)
        edit:SetFontObject(GameFontNormalSmall)
        edit:SetWidth(440)
        edit:SetTextInsets(6, 6, 6, 6)
        edit:SetMaxLetters(999999)
        edit:SetScript("OnEscapePressed", function() copyFallbackFrame:Hide() end)
        scroll:SetScrollChild(edit)

        local measureFS = copyFallbackFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        measureFS:SetWordWrap(true)
        measureFS:SetAlpha(0)
        measureFS:SetPoint("TOPLEFT", copyFallbackFrame, "TOPLEFT", 0, 0)

        copyFallbackFrame.scroll    = scroll
        copyFallbackFrame.edit      = edit
        copyFallbackFrame.measureFS = measureFS
    end

    copyFallbackFrame.hdr:SetText((panelTitle or "Log") .. " — Ctrl+C, then Close")

    local edit      = copyFallbackFrame.edit
    local scroll    = copyFallbackFrame.scroll
    local scrollW   = scroll and scroll:GetWidth() or 440
    local editWidth = math.max(200, scrollW - 24)
    edit:SetWidth(editWidth)
    edit:SetText(text)

    local innerW    = math.max(50, editWidth - 12)
    local measureFS = copyFallbackFrame.measureFS
    local h = 0
    if measureFS then
        measureFS:SetWidth(innerW)
        measureFS:SetText(text)
        h = measureFS:GetStringHeight() or 0
    end
    edit:SetHeight(h > 0 and math.min(12000, math.max(120, h + 24)) or 280)

    if scroll.UpdateScrollChildRect then scroll:UpdateScrollChildRect() end
    scroll:SetVerticalScroll(0)
    copyFallbackFrame:Show()
    edit:SetFocus()
    edit:HighlightText()
end

-- ============================================================================
-- PANEL FACTORY
-- ============================================================================

-- @param tag     string  log tag (e.g. "focus")
-- @param title   string  panel header text (e.g. "Focus Debug")
-- @param opts    table?  { maxLines=500, onClose=fn }
-- @return table  { Show, Hide, Toggle, Clear, GetText }
local function createPanel(tag, title, opts)
    opts = opts or {}
    local maxLines = opts.maxLines or 500
    local onClose  = opts.onClose

    local buf, head, count = {}, 1, 0
    local frame

    -- Register ring-buffer listener; fires only while the tag is enabled.
    addon.Log.addListener(tag, function(level, ltag, ts, msg, line)
        buf[head] = line
        head  = (head % maxLines) + 1
        if count < maxLines then count = count + 1 end
        if frame and frame.msg then
            frame.msg:AddMessage(line, 0.7, 0.9, 1, 1)
        end
    end)

    local panel = {}

    local function getFrameName()
        local t = tag:sub(1, 1):upper() .. tag:sub(2)
        return "HorizonSuite" .. t .. "DebugFrame"
    end

    local function doCopy()
        local text = panel.GetText()
        if text == "" then
            if addon.HSPrint then addon.HSPrint(title .. ": log is empty.") end
            return
        end
        if C_CopyToClipboard then
            local ok = pcall(C_CopyToClipboard, text)
            if ok then
                if addon.HSPrint then addon.HSPrint(title .. ": copied to clipboard.") end
                return
            end
        end
        ShowCopyFallback(text, title)
    end

    local function ensureFrame()
        if frame then return end

        local f = CreateFrame("Frame", getFrameName(), UIParent)
        f:SetSize(420, 320)
        f:SetPoint("CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")
        f:SetClampedToScreen(true)
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:Hide()

        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(f)
        bg:SetColorTexture(0.05, 0.05, 0.08, 0.95)

        if addon.CreateBorder then
            local border = CreateFrame("Frame", nil, f)
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            addon.CreateBorder(border, { 0.2, 0.2, 0.25, 1 })
        end

        local hdr = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        hdr:SetPoint("TOPLEFT", 10, -10)
        hdr:SetText(title)
        hdr:SetTextColor(0.7, 0.9, 1)

        -- msg declared before clearBtn so clearBtn closure captures it correctly
        local msg = CreateFrame("ScrollingMessageFrame", nil, f)
        msg:SetPoint("TOPLEFT", 8, -36)
        msg:SetPoint("BOTTOMRIGHT", -8, 8)
        msg:SetFontObject(GameFontNormalSmall)
        msg:SetFading(false)
        msg:SetMaxLines(maxLines)
        msg:EnableMouseWheel(true)
        msg:SetScript("OnMouseWheel", function(_, delta)
            msg:SetScrollOffset(msg:GetScrollOffset() - delta)
        end)

        local closeBtn = CreateFrame("Button", nil, f)
        closeBtn:SetSize(24, 24)
        closeBtn:SetPoint("TOPRIGHT", -8, -8)
        closeBtn:SetScript("OnClick", function()
            if onClose then onClose() else panel.Hide() end
        end)
        local closeTex = closeBtn:CreateTexture(nil, "OVERLAY")
        closeTex:SetAllPoints(closeBtn)
        closeTex:SetColorTexture(0.5, 0.2, 0.2, 0.8)

        local copyBtn = CreateFrame("Button", nil, f)
        copyBtn:SetSize(60, 22)
        copyBtn:SetPoint("TOPRIGHT", -105, -10)
        copyBtn:SetScript("OnClick", doCopy)
        local copyTex = copyBtn:CreateTexture(nil, "BACKGROUND")
        copyTex:SetAllPoints(copyBtn)
        copyTex:SetColorTexture(0.15, 0.25, 0.35, 0.9)
        local copyLabel = copyBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        copyLabel:SetPoint("CENTER", 0, 0)
        copyLabel:SetText("Copy")

        local clearBtn = CreateFrame("Button", nil, f)
        clearBtn:SetSize(60, 22)
        clearBtn:SetPoint("TOPRIGHT", -40, -10)
        clearBtn:SetScript("OnClick", function() panel.Clear() end)
        local clearTex = clearBtn:CreateTexture(nil, "BACKGROUND")
        clearTex:SetAllPoints(clearBtn)
        clearTex:SetColorTexture(0.2, 0.2, 0.25, 0.9)
        local clearLabel = clearBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        clearLabel:SetPoint("CENTER", 0, 0)
        clearLabel:SetText("Clear")

        f:SetScript("OnDragStart", function()
            if not InCombatLockdown() then f:StartMoving() end
        end)
        f:SetScript("OnDragStop", function()
            if not InCombatLockdown() then f:StopMovingOrSizing() end
        end)

        frame     = f
        frame.msg = msg
    end

    function panel.Show()
        if not addon.Log.isDevMode() then
            if addon.HSPrint then
                addon.HSPrint("|cFFFFCC00" .. title .. ": debug panel requires DEV_MODE = true in core/Logger.lua|r")
            end
            return
        end
        ensureFrame()
        frame.msg:Clear()
        frame.msg:SetMaxLines(maxLines)
        local start = (count < maxLines) and 1 or head
        for i = 0, count - 1 do
            local idx  = ((start - 1 + i) % maxLines) + 1
            local line = buf[idx]
            if line then frame.msg:AddMessage(line, 0.7, 0.9, 1, 1) end
        end
        frame:Show()
    end

    function panel.Hide()
        if frame then frame:Hide() end
    end

    function panel.Toggle()
        if frame and frame:IsShown() then panel.Hide() else panel.Show() end
    end

    function panel.Clear()
        buf, head, count = {}, 1, 0
        if frame and frame.msg then
            frame.msg:Clear()
            frame.msg:SetMaxLines(maxLines)
        end
    end

    function panel.GetText()
        if count == 0 then return "" end
        local start = (count < maxLines) and 1 or head
        local lines = {}
        for i = 0, count - 1 do
            local idx  = ((start - 1 + i) % maxLines) + 1
            local line = buf[idx]
            if line then lines[#lines + 1] = line end
        end
        return table.concat(lines, "\n")
    end

    return panel
end

addon.Log.createPanel = createPanel
