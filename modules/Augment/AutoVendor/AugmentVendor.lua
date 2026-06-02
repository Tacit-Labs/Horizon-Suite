--[[
    Horizon Suite - Augment - Vendor
    Automatically sells items (AutoSeller) and repairs gear (AutoRepair)
    when a merchant window opens. Each sub-feature is independently toggled.
]]

local addon = _G.HorizonSuite
if not addon or not addon.Augment then return end

local Y = addon.Augment

-- Register this mini-module's DB keys into the shared routing table.
Y.DB_KEYS.augmentVendorEnabled        = true
Y.DB_KEYS.autoSellerEnabled           = true
Y.DB_KEYS.autoSellerGrey              = true
Y.DB_KEYS.autoSellerUnusable          = true
Y.DB_KEYS.autoSellerNonOptimal        = true
Y.DB_KEYS.autoSellerLowLevel          = true
Y.DB_KEYS.autoSellerLowLevelThreshold = true
Y.DB_KEYS.autoSellerFortuneCards      = true
Y.DB_KEYS.autoSellerLegionRelics      = true
Y.DB_KEYS.autoSellerVerbosity         = true
Y.DB_KEYS.autoRepairEnabled           = true
Y.DB_KEYS.autoRepairGuildBank         = true
Y.DB_KEYS.autoRepairVerbosity         = true

local function getDB(k, d)
    if not addon.GetDB then return d end
    local v = addon.GetDB(k, d)
    -- explicit nil-check so a stored `false` is not silently replaced by the default
    if v == nil then return d end
    return v
end

local function Print(msg)
    print("|cff69CCF0HorizonSuite|r " .. msg)
end

-- ============================================================================
-- Item classification tables
-- ============================================================================

local UNUSABLE_ITEMS = {
    DEATHKNIGHT = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Staff, Enum.ItemWeaponSubclass.Unarmed, Enum.ItemWeaponSubclass.Dagger, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Warglaive },
    },
    DEMONHUNTER = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Staff, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Mace1H },
    },
    DRUID = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Axe1H, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Sword1H, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Warglaive },
    },
    EVOKER = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Warglaive, Enum.ItemWeaponSubclass.Polearm },
    },
    HUNTER = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Mace1H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Warglaive },
    },
    MAGE = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Axe1H, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Mace1H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Unarmed, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Warglaive },
    },
    MONK = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Dagger, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Warglaive },
    },
    PALADIN = {
        [Enum.ItemClass.Armor]  = {},
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Staff, Enum.ItemWeaponSubclass.Unarmed, Enum.ItemWeaponSubclass.Dagger, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Warglaive },
    },
    PRIEST = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Axe1H, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Sword1H, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Unarmed, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Warglaive },
    },
    ROGUE = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Staff, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Warglaive },
    },
    SHAMAN = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Plate },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Sword1H, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Warglaive },
    },
    WARLOCK = {
        [Enum.ItemClass.Armor]  = { Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Axe1H, Enum.ItemWeaponSubclass.Axe2H, Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Mace1H, Enum.ItemWeaponSubclass.Mace2H, Enum.ItemWeaponSubclass.Polearm, Enum.ItemWeaponSubclass.Sword2H, Enum.ItemWeaponSubclass.Unarmed, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Warglaive },
    },
    WARRIOR = {
        [Enum.ItemClass.Armor]  = {},
        [Enum.ItemClass.Weapon] = { Enum.ItemWeaponSubclass.Wand, Enum.ItemWeaponSubclass.Bows, Enum.ItemWeaponSubclass.Guns, Enum.ItemWeaponSubclass.Crossbow, Enum.ItemWeaponSubclass.Thrown, Enum.ItemWeaponSubclass.Warglaive },
    },
}

local NON_OPTIMAL_ITEMS = {
    DEATHKNIGHT = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail } },
    DEMONHUNTER = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth } },
    DRUID       = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth } },
    EVOKER      = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather } },
    HUNTER      = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather } },
    MAGE        = { [Enum.ItemClass.Armor] = {} },
    MONK        = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth } },
    PALADIN     = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail } },
    PRIEST      = { [Enum.ItemClass.Armor] = {} },
    ROGUE       = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth } },
    SHAMAN      = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather } },
    WARLOCK     = { [Enum.ItemClass.Armor] = {} },
    WARRIOR     = { [Enum.ItemClass.Armor] = { Enum.ItemArmorSubclass.Cloth, Enum.ItemArmorSubclass.Leather, Enum.ItemArmorSubclass.Mail } },
}

local FORTUNE_CARDS = {
    [62590]=true,[60845]=true,[62606]=true,[60842]=true,[60841]=true,[62602]=true,[62603]=true,
    [62604]=true,[62605]=true,[60839]=true,[62598]=true,[62599]=true,[62600]=true,[62601]=true,
    [62246]=true,[62577]=true,[62578]=true,[62579]=true,[62580]=true,[62581]=true,[62582]=true,
    [62583]=true,[62584]=true,[62585]=true,[62586]=true,[62587]=true,[62588]=true,[62589]=true,
    [60843]=true,[62591]=true,[62247]=true,[62552]=true,[62553]=true,[62554]=true,[62555]=true,
    [62556]=true,[62557]=true,[62558]=true,[62559]=true,[62560]=true,[62561]=true,[62562]=true,
    [62563]=true,[62564]=true,[62565]=true,[62566]=true,[62567]=true,[62568]=true,[62569]=true,
    [62570]=true,[62571]=true,[62572]=true,[62573]=true,[62574]=true,[62575]=true,[62576]=true,
}

-- ============================================================================
-- Tooltip cache + soulbound scanner
-- ============================================================================

local itemsBOP      = {}
local itemsUseEquip = {}
local tooltipFrame

local function ScanTooltip(link)
    if not tooltipFrame then
        tooltipFrame = CreateFrame("GameTooltip", "HorizonSuiteVendorTooltip", UIParent, "GameTooltipTemplate")
    end
    tooltipFrame:SetOwner(UIParent, "ANCHOR_NONE")
    tooltipFrame:SetHyperlink(link)
    local bop, useEquip = false, false
    for i = 1, tooltipFrame:NumLines() do
        local line = _G["HorizonSuiteVendorTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                if string.find(text, ITEM_BIND_ON_PICKUP, 1, true) then bop = true end
                if string.find(text, USE_COLON or "Use:",   1, true) then useEquip = true end
                if string.find(text, "Equip:",               1, true) then useEquip = true end
            end
        end
    end
    tooltipFrame:Hide()
    return bop, useEquip
end

local function GetBOP(itemId, link)
    if itemsBOP[itemId] == nil then
        itemsBOP[itemId], itemsUseEquip[itemId] = ScanTooltip(link)
    end
    return itemsBOP[itemId], itemsUseEquip[itemId]
end

local function CannotUse(class, classId, subClassId)
    local entry = UNUSABLE_ITEMS[class]
    if not entry then return false end
    local list = entry[classId]
    if not list then return false end
    for _, v in ipairs(list) do if subClassId == v then return true end end
    return false
end

local function NonOptimal(class, classId, subClassId)
    local entry = NON_OPTIMAL_ITEMS[class]
    if not entry then return false end
    local list = entry[classId]
    if not list then return false end
    for _, v in ipairs(list) do if subClassId == v then return true end end
    return false
end

-- ============================================================================
-- ShouldSell
-- ============================================================================

local function ShouldSell(link)
    local itemId = tonumber(strmatch(link, "item:(%d+)"))
    if not itemId then return false end

    local D = addon.AUGMENT_DEFAULTS
    local _, _, quality, _, _, _, _, _, equipLoc, _, _, classId, subClassId = C_Item.GetItemInfo(link)
    local itemLevel = C_Item.GetDetailedItemLevelInfo(link)

    -- never sell legendary / artifact / heirloom
    if quality and quality > 4 then return false end

    -- grey: gated by its own flag so disabling it alone stops grey selling
    if quality == 0 then return getDB("autoSellerGrey", D.autoSellerGrey) ~= false end

    -- non-grey item level 1: never sell (vendor trash that looks like gear)
    if itemLevel == 1 then return false end

    local _, class = UnitClass("player")

    if getDB("autoSellerFortuneCards", D.autoSellerFortuneCards) and FORTUNE_CARDS[itemId] then
        return true
    end

    if getDB("autoSellerLegionRelics", D.autoSellerLegionRelics)
    and classId == Enum.ItemClass.Gem
    and subClassId == Enum.ItemGemSubclass.Artifactrelic then
        return true
    end

    if classId == Enum.ItemClass.Weapon or classId == Enum.ItemClass.Armor then
        local bop, useEquip = GetBOP(itemId, link)

        if getDB("autoSellerLowLevel", D.autoSellerLowLevel) and bop and not useEquip and itemLevel then
            local threshold = tonumber(getDB("autoSellerLowLevelThreshold", D.autoSellerLowLevelThreshold)) or D.autoSellerLowLevelThreshold
            if itemLevel < threshold then return true end
        end

        if getDB("autoSellerUnusable", D.autoSellerUnusable) and bop and class then
            if CannotUse(class, classId, subClassId) then return true end
        end

        if getDB("autoSellerNonOptimal", D.autoSellerNonOptimal) and bop and class then
            if classId == Enum.ItemClass.Armor and equipLoc ~= "INVTYPE_CLOAK" then
                if NonOptimal(class, classId, subClassId) then return true end
            end
        end
    end

    return false
end

-- ============================================================================
-- AutoRepair
-- ============================================================================

local function DoRepair()
    if not getDB("autoRepairEnabled", false) then return end
    if not CanMerchantRepair() then return end
    local cost, canRepair = GetRepairAllCost()
    if not canRepair or cost == 0 then return end
    local usedGuild = false
    if getDB("autoRepairGuildBank", false) and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= cost then
        RepairAllItems(true)
        usedGuild = true
    else
        RepairAllItems()
    end
    if getDB("autoRepairVerbosity", "summary") ~= "none" then
        local L = addon.L
        if usedGuild then
            Print(string.format(L["AUGMENT_VENDOR_REPAIRED_GUILD"], C_CurrencyInfo.GetCoinTextureString(cost)))
        else
            Print(string.format(L["AUGMENT_VENDOR_REPAIRED"], C_CurrencyInfo.GetCoinTextureString(cost)))
        end
    end
end

-- ============================================================================
-- AutoSeller
-- ============================================================================

local sellQueue   = {}
local sellSession = { value = 0, count = 0 }

local function SellNextItem()
    if not getDB("autoSellerEnabled", false) then
        sellQueue = {}
        sellSession.value = 0
        sellSession.count = 0
        return
    end
    if #sellQueue == 0 then
        if getDB("autoSellerVerbosity", "summary") ~= "none" and sellSession.count > 0 then
            local L = addon.L
            Print(string.format(L["AUGMENT_VENDOR_SOLD_SUMMARY"], sellSession.count, C_CurrencyInfo.GetCoinTextureString(sellSession.value)))
        end
        sellSession.value = 0
        sellSession.count = 0
        return
    end
    local item = table.remove(sellQueue, 1)
    local info = C_Container.GetContainerItemInfo(item.bag, item.slot)
    if info then
        local count = info.stackCount or 1
        local price = select(11, C_Item.GetItemInfo(item.link)) or 0
        if price > 0 then
            C_Container.UseContainerItem(item.bag, item.slot)
            sellSession.value = sellSession.value + count * price
            sellSession.count = sellSession.count + 1
        end
    end
    C_Timer.After(0.2, SellNextItem)
end

local function DoSell()
    if not getDB("autoSellerEnabled", false) then return end
    sellQueue = {}
    sellSession.value = 0
    sellSession.count = 0
    -- Clear per-session tooltip cache so newly looted items are rescanned
    itemsBOP      = {}
    itemsUseEquip = {}
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local link = C_Container.GetContainerItemLink(bag, slot)
            if link and ShouldSell(link) then
                table.insert(sellQueue, { bag = bag, slot = slot, link = link })
            end
        end
    end
    SellNextItem()
end

-- ============================================================================
-- Event frame
-- ============================================================================

local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        DoRepair()
        DoSell()
    end
end)

-- ============================================================================
-- Public API (addon.Augment.Vendor)
-- ============================================================================

local V = {}
Y.Vendor = V

function V.Enable()
    eventFrame:RegisterEvent("MERCHANT_SHOW")
end

function V.Disable()
    eventFrame:UnregisterAllEvents()
    sellQueue = {}
end
