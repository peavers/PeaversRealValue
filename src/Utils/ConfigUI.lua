local addonName, PRV = ...

local ConfigUI = {}
PRV.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

function ConfigUI:InitializeOptions()
    local panel = PeaversCommons.ConfigUIUtils.CreateSettingsPanel(
        "Settings",
        "Configuration options for PeaversRealValue"
    )
    
    local content = panel.content
    local yPos = panel.yPos
    local baseSpacing = panel.baseSpacing
    local sectionSpacing = panel.sectionSpacing
    
    yPos = self:CreateGeneralOptions(content, yPos, baseSpacing, sectionSpacing)
    yPos = self:CreateCurrencyOptions(content, yPos, baseSpacing, sectionSpacing)
    yPos = self:CreatePriceSourceOptions(content, yPos, baseSpacing, sectionSpacing)
    yPos = self:CreatePerformanceOptions(content, yPos, baseSpacing, sectionSpacing)
    
    panel:UpdateContentHeight(yPos)
    
    return panel
end

function ConfigUI:InitializeRatesPanel()
    local panel = PeaversCommons.ConfigUIUtils.CreateSettingsPanel(
        "Rates",
        "Current exchange rates and token prices"
    )
    
    local content = panel.content
    local yPos = panel.yPos
    local baseSpacing = panel.baseSpacing
    local sectionSpacing = panel.sectionSpacing
    
    local PCD = _G.PeaversCurrencyData
    if not PCD then
        local errorText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        errorText:SetPoint("TOPLEFT", baseSpacing, yPos)
        errorText:SetText("PeaversCurrencyData not available")
        errorText:SetTextColor(1, 0, 0)
        return panel
    end
    
    -- Last Updated section
    local lastUpdateHeader, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Data Freshness", baseSpacing, yPos)
    yPos = newY - 10
    
    local lastUpdatedLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lastUpdatedLabel:SetPoint("TOPLEFT", baseSpacing + 15, yPos)
    lastUpdatedLabel:SetText("Last Updated:")
    
    local lastUpdatedValue = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    lastUpdatedValue:SetPoint("TOPLEFT", lastUpdatedLabel, "TOPRIGHT", 10, 0)
    lastUpdatedValue:SetText(PCD:GetLastUpdated() or "Unknown")
    yPos = yPos - 25
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15
    
    -- WoW Token Prices section
    local tokenHeader, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "WoW Token Prices", baseSpacing, yPos)
    yPos = newY - 10
    
    local currentRegion = PRV.TooltipHook and PRV.TooltipHook.GetCurrentRegionName and PRV.TooltipHook:GetCurrentRegionName() or "US"
    
    if PCD.TokenPrices and PCD.TokenPrices.regions then
        local regionData = PCD.TokenPrices.regions[currentRegion]
        if regionData then
            -- Current Region Token Price
            local regionLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            regionLabel:SetPoint("TOPLEFT", baseSpacing + 15, yPos)
            regionLabel:SetText(currentRegion .. " Region:")
            regionLabel:SetTextColor(1, 0.82, 0)
            
            local tokenPriceText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            tokenPriceText:SetPoint("TOPLEFT", regionLabel, "TOPRIGHT", 10, 0)
            tokenPriceText:SetText(string.format("%s = %s", 
                PCD:FormatWoWCurrency(regionData.goldPrice), 
                PCD:FormatCurrency(regionData.realPrice, regionData.currency)
            ))
            yPos = yPos - 25
            
            -- Gold to Currency conversion
            local goldValueLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            goldValueLabel:SetPoint("TOPLEFT", baseSpacing + 15, yPos)
            goldValueLabel:SetText("1 Gold =")
            
            local goldValueText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            goldValueText:SetPoint("TOPLEFT", goldValueLabel, "TOPRIGHT", 10, 0)
            local goldValue = regionData.realPrice / regionData.goldPrice
            goldValueText:SetText(PCD:FormatCurrency(goldValue, regionData.currency, nil, 6))
            yPos = yPos - 35
        end
    end
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15
    
    -- Currency Exchange Rates section
    local ratesHeader, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Currency Exchange Rates", baseSpacing, yPos)
    yPos = newY - 10
    
    local commonCurrencies = {"EUR", "GBP", "AUD", "CAD", "JPY", "CNY", "KRW"}
    local baseCurrency = "USD"
    
    for _, currency in ipairs(commonCurrencies) do
        local rate = PCD:GetExchangeRate(baseCurrency, currency)
        if rate then
            local currencyLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            currencyLabel:SetPoint("TOPLEFT", baseSpacing + 15, yPos)
            currencyLabel:SetText(string.format("1 %s =", baseCurrency))
            
            local rateText = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            rateText:SetPoint("TOPLEFT", currencyLabel, "TOPRIGHT", 10, 0)
            rateText:SetText(string.format("%.4f %s", rate, currency))
            
            local symbol = PCD:GetCurrencySymbol(currency)
            if symbol and symbol ~= currency then
                local symbolText = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
                symbolText:SetPoint("TOPLEFT", rateText, "TOPRIGHT", 5, 0)
                symbolText:SetText("(" .. symbol .. ")")
                symbolText:SetTextColor(0.7, 0.7, 0.7)
            end
            
            yPos = yPos - 20
        end
    end
    
    panel:UpdateContentHeight(yPos)
    
    panel.OnRefresh = function()
        if lastUpdatedValue then
            lastUpdatedValue:SetText(PCD:GetLastUpdated() or "Unknown")
        end
    end
    
    return panel
end

function ConfigUI:CreateGeneralOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15
    
    local header, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "General Settings", baseSpacing, yPos)
    yPos = newY - 10
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PRVEnabledCheckbox",
        "Enable real value display",
        controlIndent, yPos,
        PRV.Config.enabled,
        function(checked)
            PRV.Config.enabled = checked
            PRV.Config:Save()
        end
    )
    yPos = newY - 8
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PRVShowOnlyWithPriceCheckbox",
        "Only show value for items with known auction house prices",
        controlIndent, yPos,
        PRV.Config.showOnlyWithPrice,
        function(checked)
            PRV.Config.showOnlyWithPrice = checked
            PRV.Config:Save()
        end
    )
    yPos = newY - 8
    
    local thresholdContainer, thresholdSlider = PeaversCommons.ConfigUIUtils.CreateSlider(
        content, "PRVPriceThresholdSlider",
        "Price Threshold (gold)", 0, 10000, 10,
        PRV.Config.priceThreshold, 400,
        function(value)
            PRV.Config.priceThreshold = value
            PRV.Config:Save()
        end
    )
    thresholdContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    yPos = yPos - 55
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PRVDebugCheckbox",
        "Enable debug messages",
        controlIndent, yPos,
        PRV.Config.debugMode,
        function(checked)
            PRV.Config.debugMode = checked
            PRV.Config.DEBUG_ENABLED = checked
            PRV.Config:Save()
        end
    )
    yPos = newY - 15
    
    return yPos
end


function ConfigUI:CreateCurrencyOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15
    
    local header, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Currency Settings", baseSpacing, yPos)
    yPos = newY - 10
    
    local currencies = {
        USD = "US Dollar ($)",
        EUR = "Euro (€)",
        GBP = "British Pound (£)",
        AUD = "Australian Dollar (A$)",
        CAD = "Canadian Dollar (C$)",
        JPY = "Japanese Yen (¥)",
        CNY = "Chinese Yuan (¥)",
        KRW = "Korean Won (₩)"
    }
    
    local currencyContainer, currencyDropdown = PeaversCommons.ConfigUIUtils.CreateDropdown(
        content, "PRVTargetCurrencyDropdown",
        "Target Currency", currencies,
        currencies[PRV.Config.targetCurrency] or "US Dollar ($)", 400,
        function(value)
            PRV.Config.targetCurrency = value
            PRV.Config:Save()
        end
    )
    currencyContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    yPos = yPos - 65
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateCheckbox(
        content,
        "PRVShowSymbolCheckbox",
        "Show currency symbol",
        controlIndent, yPos,
        PRV.Config.showSymbol,
        function(checked)
            PRV.Config.showSymbol = checked
            PRV.Config:Save()
        end
    )
    yPos = newY - 8
    
    local decimalContainer, decimalSlider = PeaversCommons.ConfigUIUtils.CreateSlider(
        content, "PRVDecimalPlacesSlider",
        "Decimal Places", 0, 4, 1,
        PRV.Config.decimalPlaces, 400,
        function(value)
            PRV.Config.decimalPlaces = value
            PRV.Config:Save()
        end
    )
    decimalContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    yPos = yPos - 55
    
    return yPos
end

function ConfigUI:CreatePriceSourceOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15
    
    local header, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Price Source Settings", baseSpacing, yPos)
    yPos = newY - 10
    
    -- Price source dropdown
    local priceSources = {
        auction = "Auction House (if available)",
        vendor = "Vendor Prices Only"
    }
    
    local sourceContainer, sourceDropdown = PeaversCommons.ConfigUIUtils.CreateDropdown(
        content, "PRVPriceSourceDropdown",
        "Price Source", priceSources,
        priceSources[PRV.Config.priceSource] or "Auction House (if available)", 400,
        function(value)
            PRV.Config.priceSource = value
            PRV.Config:Save()
            PRV.PriceCache:Clear()
            Utils.Print(PRV, "Price source changed - cache cleared")
        end
    )
    sourceContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    yPos = yPos - 65
    
    local infoText = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    infoText:SetPoint("TOPLEFT", controlIndent, yPos)
    infoText:SetText("Auction prices use TSM or Auctionator if available")
    infoText:SetTextColor(0.7, 0.7, 0.7)
    yPos = yPos - 20
    
    return yPos
end

function ConfigUI:CreatePerformanceOptions(content, yPos, baseSpacing, sectionSpacing)
    local controlIndent = baseSpacing + 15
    
    local _, newY = PeaversCommons.ConfigUIUtils.CreateSeparator(content, baseSpacing, yPos)
    yPos = newY - 15
    
    local header, newY = PeaversCommons.ConfigUIUtils.CreateSectionHeader(content, "Performance Settings", baseSpacing, yPos)
    yPos = newY - 10
    
    local cacheContainer, cacheSlider = PeaversCommons.ConfigUIUtils.CreateSlider(
        content, "PRVCacheExpirySlider",
        "Cache Expiry (seconds)", 300, 7200, 60,
        PRV.Config.cacheExpiry, 400,
        function(value)
            PRV.Config.cacheExpiry = value
            PRV.Config:Save()
        end
    )
    cacheContainer:SetPoint("TOPLEFT", controlIndent, yPos)
    yPos = yPos - 55
    
    local clearButton = CreateFrame("Button", "PRVClearCacheButton", content, "UIPanelButtonTemplate")
    clearButton:SetPoint("TOPLEFT", controlIndent, yPos)
    clearButton:SetSize(150, 25)
    clearButton:SetText("Clear Price Cache")
    clearButton:SetScript("OnClick", function()
        PRV.PriceCache:Clear()
        Utils.Print(PRV, "Price cache cleared")
    end)
    yPos = yPos - 35
    
    return yPos
end

function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
    self.ratesPanel = self:InitializeRatesPanel()
end

function ConfigUI:Open()
    if Settings then
        Settings.OpenToCategory(addonName)
    end
end

return ConfigUI