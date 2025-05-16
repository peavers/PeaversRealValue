local addonName, PRV = ...

local PeaversCommons = _G.PeaversCommons
local ConfigManager = PeaversCommons.ConfigManager

local Config = ConfigManager:New(addonName, {
    enabled = true,
    debugMode = false,
    showOnlyWithPrice = true,
    priceThreshold = 0,
    cacheExpiry = 3600,
    targetCurrency = "USD",
    showSymbol = true,
    decimalPlaces = 2,
    priceSource = "auction",
})

PRV.Config = Config

return Config