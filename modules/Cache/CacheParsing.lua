--[[
    Horizon Suite - Cache - Parsing
    Parse CHAT_MSG_LOOT, CHAT_MSG_MONEY, CHAT_MSG_CURRENCY, CHAT_MSG_COMBAT_FACTION_CHANGE.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite
if not addon or not addon.Cache then return end

local Y = addon.Cache
local y = addon.cache

-- Pattern tables (filled by InitPatterns)
local selfLootPats = {}
local goldPat, silverPat, copperPat
local repGainPat, repLossPat, repGainGenPat

-- ============================================================================
-- HELPERS
-- ============================================================================

local function GetQualityColor(quality)
    if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] then
        local c = ITEM_QUALITY_COLORS[quality]
        return c.r, c.g, c.b
    end
    local c = Y.QUALITY_COLORS[quality or 1] or Y.QUALITY_COLORS[1]
    return c[1], c[2], c[3]
end

local function GetBorderColor(quality)
    local r, g, b = GetQualityColor(quality)
    return math.min(r * 1.2, 1), math.min(g * 1.2, 1), math.min(b * 1.2, 1)
end

local function BuildPattern(fmtStr)
    local temp = fmtStr:gsub("%%s", "\001"):gsub("%%d", "\002")
    temp = temp:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    temp = temp:gsub("\001", "(.-)"):gsub("\002", "(%%d+)")
    return "^" .. temp
end

-- Inline coin textures
local COIN_SZ   = Y.FONT_SIZE
local GOLD_COIN = format("|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t", COIN_SZ, COIN_SZ)
local SILVER_COIN = format("|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t", COIN_SZ, COIN_SZ)
local COPPER_COIN = format("|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t", COIN_SZ, COIN_SZ)

-- ============================================================================
-- INIT PATTERNS
-- ============================================================================

function Y.InitPatterns()
    selfLootPats = {}
    local selfGlobals = {
        "LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE",
        "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
    }
    for _, name in ipairs(selfGlobals) do
        local str = _G[name]
        if str then
            selfLootPats[#selfLootPats + 1] = BuildPattern(str)
        end
    end

    if GOLD_AMOUNT   then goldPat   = GOLD_AMOUNT:gsub("%%d", "(%%d+)")   end
    if SILVER_AMOUNT then silverPat = SILVER_AMOUNT:gsub("%%d", "(%%d+)") end
    if COPPER_AMOUNT then copperPat = COPPER_AMOUNT:gsub("%%d", "(%%d+)") end

    if FACTION_STANDING_INCREASED then
        repGainPat = BuildPattern(FACTION_STANDING_INCREASED)
    end
    if FACTION_STANDING_DECREASED then
        repLossPat = BuildPattern(FACTION_STANDING_DECREASED)
    end
    if FACTION_STANDING_INCREASED_GENERIC then
        repGainGenPat = BuildPattern(FACTION_STANDING_INCREASED_GENERIC)
    end

    y.patternsOK = true
    y.selfLootPatCount = #selfLootPats
end

function Y.IsSelfLoot(msg)
    for _, pat in ipairs(selfLootPats) do
        if msg:match(pat) then return true end
    end
    return false
end

function Y.FormatMoney(gold, silver, copper)
    local parts = {}
    if gold   > 0 then parts[#parts + 1] = gold   .. " " .. GOLD_COIN   end
    if silver > 0 then parts[#parts + 1] = silver .. " " .. SILVER_COIN end
    if copper > 0 then parts[#parts + 1] = copper .. " " .. COPPER_COIN end
    if #parts == 0 then return "0 " .. COPPER_COIN end
    return table.concat(parts, " ")
end

-- ============================================================================
-- PARSERS
-- ============================================================================

local function ExtractItemLink(msg)
    local link = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
    if link then return link end
    link = msg:match("|Hitem:.-|h%[.-%]|h")
    if link then return link end
    link = msg:match("|c%x+|H.-|h%[.-%]|h|r")
    if link then return link end
    return nil
end

function Y.ParseItemLoot(msg)
    local itemLink = ExtractItemLink(msg)

    if y.debugMode then
        print("|cFF00CCFFCache debug PARSE:|r link=" .. tostring(itemLink ~= nil)
            .. " raw=" .. tostring(msg):sub(1, 120))
    end

    if not itemLink then return nil end

    local qty = tonumber(msg:match("|[rh].-x(%d+)")) or 1
    local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)

    if not itemName then
        itemName = itemLink:match("%[(.-)%]") or "Unknown Item"
        itemQuality = 1
        itemTexture = nil
    end

    local displayText = itemName
    if qty > 1 then
        displayText = itemName .. " x" .. qty
    end

    local r, g, b = GetQualityColor(itemQuality)
    local br, bg, bb = GetBorderColor(itemQuality)

    local holdDur = Y.HOLD_ITEM
    if itemQuality == 5 then holdDur = Y.HOLD_LEGENDARY
    elseif itemQuality == 4 then holdDur = Y.HOLD_EPIC
    end

    return {
        icon    = itemTexture or Y.UNKNOWN_ICON,
        text    = displayText,
        r = r, g = g, b = b,
        br = br, bg = bg, bb = bb,
        holdDur = holdDur,
        quality = itemQuality,
    }
end

function Y.ParseMoney(msg)
    local gold   = tonumber(goldPat   and msg:match(goldPat))   or 0
    local silver = tonumber(silverPat and msg:match(silverPat)) or 0
    local copper = tonumber(copperPat and msg:match(copperPat)) or 0

    if gold == 0 and silver == 0 and copper == 0 then return nil end

    return {
        icon    = Y.MONEY_ICON,
        text    = Y.FormatMoney(gold, silver, copper),
        r = Y.MONEY_COLOR[1], g = Y.MONEY_COLOR[2], b = Y.MONEY_COLOR[3],
        br = Y.MONEY_COLOR[1], bg = Y.MONEY_COLOR[2], bb = Y.MONEY_COLOR[3],
        holdDur = Y.HOLD_MONEY,
    }
end

function Y.ParseCurrency(msg)
    local currencyID = tonumber(msg:match("|Hcurrency:(%d+)"))
    if not currencyID then return nil end

    local qty = tonumber(msg:match("|r.-x(%d+)")) or 1
    local name, iconFileID

    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if info then
            name       = info.name
            iconFileID = info.iconFileID
        end
    end

    name = name or (msg:match("%[(.-)%]") or "Unknown Currency")
    local displayText = "+" .. qty .. " " .. name

    return {
        icon    = iconFileID or Y.UNKNOWN_ICON,
        text    = displayText,
        r = Y.CURRENCY_COLOR[1], g = Y.CURRENCY_COLOR[2], b = Y.CURRENCY_COLOR[3],
        br = Y.CURRENCY_COLOR[1], bg = Y.CURRENCY_COLOR[2], bb = Y.CURRENCY_COLOR[3],
        holdDur = Y.HOLD_CURRENCY,
    }
end

function Y.ParseReputation(msg)
    local faction, amount

    if repGainPat then
        faction, amount = msg:match(repGainPat)
        if faction then
            amount = tonumber(amount) or 0
            return {
                icon    = Y.REP_ICON,
                text    = "+" .. amount .. " " .. faction,
                r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
                br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
                holdDur = Y.HOLD_REP,
            }
        end
    end

    if repLossPat then
        faction, amount = msg:match(repLossPat)
        if faction then
            amount = tonumber(amount) or 0
            return {
                icon    = Y.REP_ICON,
                text    = "-" .. amount .. " " .. faction,
                r = Y.REP_LOSS_COLOR[1], g = Y.REP_LOSS_COLOR[2], b = Y.REP_LOSS_COLOR[3],
                br = Y.REP_LOSS_COLOR[1], bg = Y.REP_LOSS_COLOR[2], bb = Y.REP_LOSS_COLOR[3],
                holdDur = Y.HOLD_REP,
            }
        end
    end

    if repGainGenPat then
        faction = msg:match(repGainGenPat)
        if faction then
            return {
                icon    = Y.REP_ICON,
                text    = faction,
                r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
                br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
                holdDur = Y.HOLD_REP,
            }
        end
    end

    return nil
end
