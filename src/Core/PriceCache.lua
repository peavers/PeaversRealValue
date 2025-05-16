local addonName, PRV = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

PRV.PriceCache = {}
local PriceCache = PRV.PriceCache

local priceCache = {}

function PriceCache:GetPrice(itemID)
    if not itemID then return nil end
    
    local cached = priceCache[itemID]
    if cached then
        if (GetTime() - cached.timestamp) < PRV.Config.cacheExpiry then
            return cached.price
        else
            priceCache[itemID] = nil
        end
    end
    
    return nil
end

function PriceCache:SetPrice(itemID, price)
    if not itemID or not price then return end
    
    priceCache[itemID] = {
        price = price,
        timestamp = GetTime()
    }
end

function PriceCache:GetMinBuyout(itemID)
    local cachedPrice = self:GetPrice(itemID)
    if cachedPrice then
        return cachedPrice
    end
    
    local price = nil
    
    if PRV.Config.priceSource == "vendor" then
        price = self:GetVendorPrice(itemID)
    else
        if TSM and TSM.API then
            local tsmString = TSM.API.GetCustomPriceValue("dbmarket", "i:" .. itemID)
            if tsmString then
                price = tonumber(tsmString)
            end
        end
        
        if not price and Auctionator and Auctionator.API then
            price = Auctionator.API.v1.GetAuctionPriceByItemID(addonName, itemID)
        end
        
        if not price then
            price = self:GetVendorPrice(itemID)
        end
    end
    
    if price and price > 0 then
        self:SetPrice(itemID, price)
        return price
    end
    
    return nil
end

function PriceCache:GetVendorPrice(itemID)
    if not itemID then return nil end
    
    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
    
    return sellPrice
end

function PriceCache:Clear()
    priceCache = {}
    Utils.Debug(PRV, "Price cache cleared")
end

function PriceCache:GetCacheSize()
    local count = 0
    for _ in pairs(priceCache) do
        count = count + 1
    end
    return count
end

function PriceCache:Save()
    if PeaversRealValueDB then
        PeaversRealValueDB.priceCache = priceCache
    end
end

function PriceCache:Load()
    if PeaversRealValueDB and PeaversRealValueDB.priceCache then
        priceCache = PeaversRealValueDB.priceCache
        
        local currentTime = GetTime()
        for itemID, data in pairs(priceCache) do
            if (currentTime - data.timestamp) > PRV.Config.cacheExpiry then
                priceCache[itemID] = nil
            end
        end
    end
end

return PriceCache