--[[
    Horizon Suite - Cache - Parsing
    Parse CHAT_MSG_LOOT, CHAT_MSG_MONEY, CHAT_MSG_CURRENCY, CHAT_MSG_COMBAT_FACTION_CHANGE.
]]

local addon = _G.HorizonSuite
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

-- Handles %s, %d, and positional tokens (%1$s, %2$d, etc.) used in some locales.
local function BuildPattern(fmtStr)
    if type(fmtStr) ~= "string" or fmtStr == "" then return nil end
    -- Escape all Lua magic chars first
    local s = fmtStr:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    -- Positional: %%1$s, %%2$d, etc.
    s = s:gsub("%%%%(%d+)%$s", "(.+)")
    s = s:gsub("%%%%(%d+)%$d", "(%%d+)")
    -- Simple: %%s, %%d
    s = s:gsub("%%%%s", "(.+)")
    s = s:gsub("%%%%d", "(%%d+)")
    return "^" .. s
end

-- Coin textures are cached and rebuilt only when the font size changes
-- (triggered by Cache.InvalidateCoinTextures called from ApplyScale).
local cachedCoinGold, cachedCoinSilver, cachedCoinCopper
local cachedCoinSz = -1

local function MakeCoinTextures()
    local sz = Y.FONT_SIZE
    if sz ~= cachedCoinSz then
        cachedCoinGold   = format("|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t",   sz, sz)
        cachedCoinSilver = format("|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t", sz, sz)
        cachedCoinCopper = format("|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t", sz, sz)
        cachedCoinSz = sz
    end
    return cachedCoinGold, cachedCoinSilver, cachedCoinCopper
end

function Y.InvalidateCoinTextures()
    cachedCoinSz = -1
end

-- Safe string match — guards against WoW "secret string" crashes in certain lockdown contexts.
local function SafeMatch(s, pat)
    if type(s) ~= "string" or type(pat) ~= "string" then return nil end
    local ok, a, b, c = pcall(string.match, s, pat)
    if not ok then return nil end
    return a, b, c
end

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
        local pat = BuildPattern(str)
        if pat then selfLootPats[#selfLootPats + 1] = pat end
    end

    if GOLD_AMOUNT   then goldPat   = GOLD_AMOUNT:gsub("%%d", "(%%d+)")   end
    if SILVER_AMOUNT then silverPat = SILVER_AMOUNT:gsub("%%d", "(%%d+)") end
    if COPPER_AMOUNT then copperPat = COPPER_AMOUNT:gsub("%%d", "(%%d+)") end

    if FACTION_STANDING_INCREASED         then repGainPat    = BuildPattern(FACTION_STANDING_INCREASED)         end
    if FACTION_STANDING_DECREASED         then repLossPat    = BuildPattern(FACTION_STANDING_DECREASED)         end
    if FACTION_STANDING_INCREASED_GENERIC then repGainGenPat = BuildPattern(FACTION_STANDING_INCREASED_GENERIC) end

    y.patternsOK = true
    y.selfLootPatCount = #selfLootPats
end

function Y.IsSelfLoot(msg)
    for _, pat in ipairs(selfLootPats) do
        if SafeMatch(msg, pat) then return true end
    end
    return false
end

function Y.FormatMoney(gold, silver, copper)
    local goldCoin, silverCoin, copperCoin = MakeCoinTextures()
    local parts = {}
    if gold   > 0 then parts[#parts + 1] = gold   .. " " .. goldCoin   end
    if silver > 0 then parts[#parts + 1] = silver .. " " .. silverCoin end
    if copper > 0 then parts[#parts + 1] = copper .. " " .. copperCoin end
    if #parts == 0 then return "0 " .. copperCoin end
    return table.concat(parts, " ")
end

-- ============================================================================
-- PARSERS
-- ============================================================================

-- Only match |Hitem:...|h[...]|h links, optionally wrapped in |c color codes.
-- The third fallback from the original matched any hyperlink type; removed.
local function ExtractItemLink(msg)
    if type(msg) ~= "string" then return nil end
    local link
    -- With color wrap
    local ok, res = pcall(function()
        return msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
    end)
    if ok and res then return res end
    -- Without color wrap
    ok, res = pcall(function()
        return msg:match("|Hitem:.-|h%[.-%]|h")
    end)
    if ok and res then return res end
    return nil
end

-- Extract quantity from the part of the message after the closing item link tag.
-- WoW loot messages place " x<N>" after |h|r, so we anchor past the link boundary.
local function ExtractQty(msg)
    if type(msg) ~= "string" then return 1 end
    -- Match "x<digits>" that appears after a closing link tag (|h|r or |h alone)
    local ok, qty = pcall(function()
        return msg:match("|h|r%s*x(%d+)") or msg:match("|h%s*x(%d+)")
    end)
    return (ok and tonumber(qty)) or 1
end

function Y.ParseItemLoot(msg)
    local itemLink = ExtractItemLink(msg)

    if y.debugMode then
        print("|cFF00CCFFCache debug PARSE:|r link=" .. tostring(itemLink ~= nil)
            .. " raw=" .. tostring(msg):sub(1, 120))
    end

    if not itemLink then return nil end

    local qty = ExtractQty(msg)
    local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink)

    if not itemName then
        local ok, extracted = pcall(function() return itemLink:match("%[(.-)%]") end)
        itemName = (ok and extracted) or "Unknown Item"
        itemQuality = 1
        itemTexture = nil
    end

    local displayText = qty > 1 and (itemName .. " x" .. qty) or itemName

    local r, g, b = GetQualityColor(itemQuality)
    local br, bg, bb = GetBorderColor(itemQuality)

    return {
        kind    = "item",
        link    = itemLink,
        icon    = itemTexture or Y.UNKNOWN_ICON,
        text    = displayText,
        r = r, g = g, b = b,
        br = br, bg = bg, bb = bb,
        quality = itemQuality,
    }
end

function Y.ParseMoney(msg)
    local gold   = tonumber(goldPat   and SafeMatch(msg, goldPat))   or 0
    local silver = tonumber(silverPat and SafeMatch(msg, silverPat)) or 0
    local copper = tonumber(copperPat and SafeMatch(msg, copperPat)) or 0

    if gold == 0 and silver == 0 and copper == 0 then return nil end

    return {
        kind    = "money",
        icon    = Y.MONEY_ICON,
        text    = Y.FormatMoney(gold, silver, copper),
        r = Y.MONEY_COLOR[1], g = Y.MONEY_COLOR[2], b = Y.MONEY_COLOR[3],
        br = Y.MONEY_COLOR[1], bg = Y.MONEY_COLOR[2], bb = Y.MONEY_COLOR[3],
    }
end

function Y.ParseCurrency(msg)
    local currencyID = tonumber(SafeMatch(msg, "|Hcurrency:(%d+)"))
    if not currencyID then return nil end

    -- Quantity appears after the closing link tag, same anchor as items.
    local qty
    local ok, res = pcall(function()
        return msg:match("|h|r%s*x(%d+)") or msg:match("|h%s*x(%d+)")
    end)
    qty = (ok and tonumber(res)) or 1

    local name, iconFileID

    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if info then
            name       = info.name
            iconFileID = info.iconFileID
        end
    end

    if not name then
        local nameOk, extracted = pcall(function() return msg:match("%[(.-)%]") end)
        name = (nameOk and extracted) or "Unknown Currency"
    end

    local displayText = "+" .. qty .. " " .. name

    return {
        kind    = "currency",
        icon    = iconFileID or Y.UNKNOWN_ICON,
        text    = displayText,
        r = Y.CURRENCY_COLOR[1], g = Y.CURRENCY_COLOR[2], b = Y.CURRENCY_COLOR[3],
        br = Y.CURRENCY_COLOR[1], bg = Y.CURRENCY_COLOR[2], bb = Y.CURRENCY_COLOR[3],
    }
end

function Y.ParseReputation(msg)
    local faction, amount

    if repGainPat then
        faction, amount = SafeMatch(msg, repGainPat)
        if faction then
            amount = tonumber(amount) or 0
            return {
                kind    = "rep",
                icon    = Y.REP_ICON,
                text    = "+" .. amount .. " " .. faction,
                r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
                br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
            }
        end
    end

    if repLossPat then
        faction, amount = SafeMatch(msg, repLossPat)
        if faction then
            amount = tonumber(amount) or 0
            return {
                kind    = "rep",
                icon    = Y.REP_ICON,
                text    = "-" .. amount .. " " .. faction,
                r = Y.REP_LOSS_COLOR[1], g = Y.REP_LOSS_COLOR[2], b = Y.REP_LOSS_COLOR[3],
                br = Y.REP_LOSS_COLOR[1], bg = Y.REP_LOSS_COLOR[2], bb = Y.REP_LOSS_COLOR[3],
            }
        end
    end

    if repGainGenPat then
        faction = SafeMatch(msg, repGainGenPat)
        if faction then
            return {
                kind    = "rep",
                icon    = Y.REP_ICON,
                text    = faction,
                r = Y.REP_GAIN_COLOR[1], g = Y.REP_GAIN_COLOR[2], b = Y.REP_GAIN_COLOR[3],
                br = Y.REP_GAIN_COLOR[1], bg = Y.REP_GAIN_COLOR[2], bb = Y.REP_GAIN_COLOR[3],
            }
        end
    end

    return nil
end
