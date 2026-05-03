--[[
    Horizon Suite - Focus - Scenario Registry
    Registers and retrieves specialized scenario providers based on the current environment.
]]

local addon = _G.HorizonSuite

local providers = {}
local Registry = {}

--- True when the current scenario is Abundance (TWW open-world scenario).
local function IsAbundanceScenario()
    local abundanceLabel = (addon.L and addon.L["UI_ABUNDANCE"]) or "Abundance"
    local lowerLabel = abundanceLabel:lower()
    local ok, name = pcall(C_Scenario.GetInfo)
    if ok and name and type(name) == "string" and name:lower():find(lowerLabel, 1, true) then
        return true
    end

    local siOk, info = pcall(C_ScenarioInfo.GetScenarioInfo)
    if siOk and info and type(info) == "table" then
        local n = (info.name or ""):lower()
        local a = (info.area or ""):lower()
        if n:find(lowerLabel, 1, true) or a:find(lowerLabel, 1, true) then return true end
    end
    return false
end

function Registry:Register(name, provider)
    providers[name] = provider
end

--- Returns true when there are active scenario-like widgets in the global objective tracker set.
--- This captures world events like Singularity that might not be formal scenarios.
local function HasWorldEventWidgets()
    local otID = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()
    if not otID or otID == 0 then return false end
    local ok, widgets = pcall(C_UIWidgetManager.GetAllWidgetsBySetID, otID)
    if not ok or not widgets then return false end

    local function hasText(text)
        return type(text) == "string" and text:gsub("|T.-|t%s*", ""):match("%S") ~= nil
    end
    
    for _, wInfo in pairs(widgets) do
        local wID = type(wInfo) == "table" and wInfo.widgetID or (type(wInfo) == "number" and wInfo)
        if wID then
            local tOk, tInfo = pcall(C_UIWidgetManager.GetScenarioHeaderTimerWidgetVisualizationInfo, wID)
            if tOk and tInfo and tInfo.shownState == 1 then return true end
            
            local sOk, sInfo = pcall(C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo, wID)
            if sOk and sInfo and sInfo.shownState == 1 and sInfo.barMax and sInfo.barMax > 0 then return true end

            local iOk, iInfo = pcall(C_UIWidgetManager.GetIconAndTextWidgetVisualizationInfo, wID)
            if iOk and iInfo and iInfo.shownState ~= 0 and hasText(iInfo.text) then return true end

            local tsOk, tsInfo = pcall(C_UIWidgetManager.GetTextWithStateWidgetVisualizationInfo, wID)
            if tsOk and tsInfo and tsInfo.shownState ~= 0 and hasText(tsInfo.text) then return true end

            if C_UIWidgetManager.GetTextureAndTextVisualizationInfo then
                local txOk, txInfo = pcall(C_UIWidgetManager.GetTextureAndTextVisualizationInfo, wID)
                if txOk and txInfo and txInfo.shownState ~= 0 and hasText(txInfo.text) then return true end
            end

            if C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo then
                local diOk, diInfo = pcall(C_UIWidgetManager.GetDoubleIconAndTextWidgetVisualizationInfo, wID)
                if diOk and diInfo and diInfo.shownState ~= 0
                    and (hasText(diInfo.leftText) or hasText(diInfo.rightText) or hasText(diInfo.label)) then return true end
            end

            if C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo then
                local stOk, stInfo = pcall(C_UIWidgetManager.GetTextWithSubtextWidgetVisualizationInfo, wID)
                if stOk and stInfo and stInfo.shownState ~= 0
                    and (hasText(stInfo.text) or hasText(stInfo.subText)) then return true end
            end

            if C_UIWidgetManager.GetTextColumnRowVisualizationInfo then
                local crOk, crInfo = pcall(C_UIWidgetManager.GetTextColumnRowVisualizationInfo, wID)
                if crOk and crInfo and crInfo.shownState ~= 0 and type(crInfo.entries) == "table" then
                    for _, entry in ipairs(crInfo.entries) do
                        if type(entry) == "table" and (hasText(entry.text) or hasText(entry.subText)) then return true end
                    end
                end
            end

            if C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo then
                local dpOk, dpInfo = pcall(C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo, wID)
                if dpOk and dpInfo and dpInfo.shownState ~= 0 and type(dpInfo.progressMax) == "number" and dpInfo.progressMax > 0 then return true end
            end

            if C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo then
                local ffOk, ffInfo = pcall(C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo, wID)
                if ffOk and ffInfo and ffInfo.shownState ~= 0 and type(ffInfo.fillMax) == "number" and ffInfo.fillMax > 0 then return true end
            end
        end
    end
    return false
end

-- 3. World Scenarios / World Events
local function IsWorldScenario()
    -- If we have active widgets in the OT set, treat as world event (Singularity, etc.)
    if HasWorldEventWidgets() then return true end
    
    -- If we are in a formal scenario, check if it's open-world or instance-based.
    if C_Scenario.IsInScenario() then
        local inInstance, instanceType = IsInInstance()
        -- Only return true for world scenarios (not in an instance).
        -- Instance type "scenario" should fall back to DEFAULT provider.
        return not inInstance
    end
    
    return false
end

function Registry:GetProvider()
    -- 1. Delves
    if addon.IsDelveActive and addon.IsDelveActive() then
        return providers["DELVES"]
    end
    
    -- 2. Abundance
    if IsAbundanceScenario() then
        return providers["ABUNDANCE"]
    end

    -- 3. World Scenarios / World Events
    if IsWorldScenario() then
        return providers["WORLD"]
    end

    return providers["DEFAULT"]
end

-- Export for providers to use during registration
addon.IsAbundanceScenario = IsAbundanceScenario
addon.IsWorldScenario = IsWorldScenario
addon.FocusScenarioRegistry = Registry
