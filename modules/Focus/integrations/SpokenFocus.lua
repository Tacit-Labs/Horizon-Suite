--[[
    Horizon Suite - Focus - Spoken Integration
    Spoken's quest Play button on Focus quest rows.

    Spoken (Spoken_Quests) draws Play on Blizzard's objective tracker blocks, and Focus hides
    that tracker, so the button went with it. This draws the same button on Focus's own rows,
    through the functions Spoken's tracker adapter uses for its own button.

    Those functions are Spoken internals, not a public API. Each is checked before use and
    each call is guarded, so a Spoken update that changes them hides the button instead of
    raising an error inside Focus's layout.

    Spoken decides where the button shows: its "Show Play Button: Tracker" setting, and
    whether a voice pack voices the quest.
]]

local addon = _G.HorizonSuite
addon.focus        = addon.focus        or {}
addon.focus.spoken = addon.focus.spoken or {}

local sp = addon.focus.spoken

-- What Spoken's tracker adapter draws: the quest log's tick box, with Play's glyph inside.
local BOX_ATLAS   = "QuestLog-icon-ticksquare"
local BOX_SIZE    = 14
-- Spoken's box button refuses a size under this.
local BOX_MIN     = 12
-- Shown in Spoken's debug log as the screen that queued the line.
local ORIGIN      = "Horizon Suite's Focus tracker Play button"

-- Set once a button fails to build, so a broken Spoken is not retried on every row.
local broken = false

-- ---------------------------------------------------------------------------
-- Spoken lookup
-- ---------------------------------------------------------------------------

--- Spoken's quest overlay and core, or nil when Spoken Quests isn't loaded or no longer
--- has everything this uses.
function sp.GetSpoken()
    if broken then return nil end
    local spoken = rawget(_G, "Spoken")
    local env    = rawget(_G, "VoiceOver")
    if type(spoken) ~= "table" or type(env) ~= "table" then return nil end
    -- VoiceOver is also the global of the older addon Spoken grew from; only Spoken's
    -- environment names this folder.
    if rawget(env, "AddonFolder") ~= "Spoken_Quests" then return nil end
    local ui = rawget(env, "QuestOverlayUI")
    if type(ui) ~= "table" then return nil end
    if type(spoken.DressBoxButton) ~= "function"
        or type(ui.ShowsTrackerButton) ~= "function"
        or type(ui.BindPlayButton) ~= "function"
        or type(ui.SetPlayButtonState) ~= "function"
        or type(ui.FollowQueue) ~= "function" then
        return nil
    end
    return ui, spoken
end

function sp.IsActive()
    return sp.GetSpoken() ~= nil
end

-- ---------------------------------------------------------------------------
-- Which rows
-- ---------------------------------------------------------------------------

--- True for a quest row: a quest ID, and not one of the rows Focus draws for other things.
function sp.IsQuestRow(questData)
    if type(questData) ~= "table" or type(questData.questID) ~= "number" then return false end
    if questData.isRare or questData.isRareLoot or questData.isAchievement
        or questData.isEndeavor or questData.isDecor or questData.isRecipe
        or questData.isAdventureGuide or questData.isAppearance then
        return false
    end
    if questData.category == "APPEARANCE" then return false end
    return true
end

--- Whether this row gets Play: a quest row, Spoken's tracker setting on, and a pack voices it.
function sp.ShouldShow(questData)
    if not sp.IsQuestRow(questData) then return false end
    local ui = sp.GetSpoken()
    if not ui then return false end
    local ok, shows = pcall(ui.ShowsTrackerButton, ui, questData.questID)
    return (ok and shows) and true or false
end

--- The button's side in pixels, scaled with Focus and never below what Spoken accepts.
function sp.GetButtonSize()
    local size = (addon.Scaled and addon.Scaled(BOX_SIZE)) or BOX_SIZE
    return math.max(BOX_MIN, math.floor(size + 0.5))
end

-- ---------------------------------------------------------------------------
-- Button
-- ---------------------------------------------------------------------------

local function MakeButton(entry, ui, spoken, size)
    local button = CreateFrame("Button", nil, entry)
    button:SetSize(size, size)
    button:SetHitRectInsets(1, 1, 1, 1)
    local ok = pcall(spoken.DressBoxButton, spoken, button)
    if ok and type(button.SetBox) == "function" then
        ok = pcall(button.SetBox, button, BOX_ATLAS, size, size)
    else
        ok = false
    end
    if not ok then
        button:Hide()
        broken = true
        return nil
    end
    button._hsSize = size
    -- Play, Stop or Replay, following Spoken's queue as its own tracker button does.
    button.setPlayState = ui.FollowQueue
    -- Dark behind the box: the row sits on the world, not on a panel.
    local back = button:CreateTexture(nil, "BACKGROUND", nil, -1)
    back:SetPoint("TOPLEFT", 1, -1)
    back:SetPoint("BOTTOMRIGHT", -1, 1)
    back:SetColorTexture(0, 0, 0, 0.6)
    return button
end

--- Shows Play on the row's title line, `rightOffset` in from the row's right edge, or hides it.
function sp.Render(entry, questData, show, rightOffset)
    if not entry then return end
    local button = entry.spokenPlayBtn
    local ui, spoken
    if show then ui, spoken = sp.GetSpoken() end
    if not ui then
        if button then button:Hide() end
        return
    end

    local size = sp.GetButtonSize()
    if not button then
        button = MakeButton(entry, ui, spoken, size)
        if not button then return end
        entry.spokenPlayBtn = button
    elseif button._hsSize ~= size then
        pcall(button.SetBox, button, BOX_ATLAS, size, size)
        button._hsSize = size
    end

    -- Centred on the title's first line, whatever offset the highlight style gave the title.
    local ty = 0
    local lineH = addon.TITLE_SIZE or size
    if entry.titleText then
        local _, _, _, _, y = entry.titleText:GetPoint(1)
        if type(y) == "number" then ty = y end
        local _, fontH = entry.titleText:GetFont()
        if type(fontH) == "number" and fontH > 0 then lineH = fontH end
    end
    button:SetFrameLevel(entry:GetFrameLevel() + 3)
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -(rightOffset or 0), ty - math.max(0, (lineH - size) / 2))

    local questID = questData.questID
    -- A pooled row may now show another quest: drop the line it held for the old one.
    if button.questID ~= questID then button.soundData = nil end
    local title = (C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID))
        or questData.title or ""
    if not pcall(ui.BindPlayButton, ui, button, questID, title, ORIGIN) then
        button:Hide()
        return
    end
    button:Show()
    pcall(ui.SetPlayButtonState, ui, button)
end

function sp.Clear(entry)
    if entry and entry.spokenPlayBtn then entry.spokenPlayBtn:Hide() end
end

-- ---------------------------------------------------------------------------
-- Redraw when Spoken's answer changes
-- ---------------------------------------------------------------------------

-- Focus caches each row until its quest data changes, and Spoken's answer is not part of
-- that data, so drop the cache before asking for a layout.
local function Refresh()
    if addon.focus.InvalidatePopulateCache then addon.focus.InvalidatePopulateCache() end
    if addon.ScheduleRefresh then addon.ScheduleRefresh() end
end
sp.Refresh = Refresh

local listening, hooked = false, false

function sp.Listen()
    local ui, spoken = sp.GetSpoken()
    if not ui then return end
    if not listening and type(spoken.RegisterCallback) == "function" then
        listening = true
        -- Packs load after login: until then no quest is voiced.
        pcall(spoken.RegisterCallback, spoken, "VOICE_PACKS_LOADED", Refresh)
        -- Spoken Quests switched on or off in Spoken's settings.
        pcall(spoken.RegisterCallback, spoken, "PART_SWITCHED", function(key)
            if key == "quests" then Refresh() end
        end)
    end
    -- Spoken's "Show Play Button: Tracker" checkbox redraws every tracker through this.
    if not hooked and type(ui.UpdateTrackerButtons) == "function" and hooksecurefunc then
        hooked = true
        hooksecurefunc(ui, "UpdateTrackerButtons", Refresh)
    end
    Refresh()
end

do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(_, event, name)
        if event == "ADDON_LOADED" and name ~= "Spoken_Quests" then return end
        sp.Listen()
    end)
end
