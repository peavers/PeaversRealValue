local addonName, PRV = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

PRV.TooltipHook = {}
local TooltipHook = PRV.TooltipHook


function TooltipHook:GetCurrentRegionName()
    local regionID = GetCurrentRegion()
    local regionMap = {
        [1] = "US",
        [2] = "Korea",
        [3] = "EU",
        [4] = "Taiwan",
        [5] = "China"
    }
    return regionMap[regionID] or "US"
end

local function FormatRealValue(goldValue)
    if not goldValue or goldValue <= 0 then
        return nil
    end
    
    local PCD = _G.PeaversCurrencyData
    if not PCD then
        Utils.Debug(PRV, "PeaversCurrencyData not available")
        return nil
    end
    
    local goldAmount = goldValue / 10000
    local region = TooltipHook:GetCurrentRegionName()
    local targetCurrency = PRV.Config.targetCurrency
    local decimalPlaces = PRV.Config.decimalPlaces
    
    local realValue = PCD:GoldToCurrency(goldAmount, region, targetCurrency)
    
    if not realValue then
        Utils.Debug(PRV, "Failed to convert gold to currency")
        return nil
    end
    
    if realValue < 0.01 then
        decimalPlaces = 4
    elseif realValue < 0.10 then
        decimalPlaces = 3
    else
        decimalPlaces = PRV.Config.decimalPlaces
    end
    
    local formattedValue
    if PRV.Config.showSymbol then
        if realValue < 0.01 then
            local symbol = PCD:GetCurrencySymbol(targetCurrency)
            formattedValue = string.format("%s%." .. decimalPlaces .. "f", symbol, realValue)
        else
            formattedValue = PCD:FormatCurrency(realValue, targetCurrency, nil, decimalPlaces)
        end
    else
        formattedValue = string.format("%." .. decimalPlaces .. "f", realValue)
    end
    
    return formattedValue
end

function TooltipHook:ProcessTooltipData(tooltip, tooltipData)
    if not PRV.Config.enabled then return end
    if not tooltipData then return end
    
    local itemID = tooltipData.id
    if not itemID then return end
    
    local price = PRV.PriceCache:GetMinBuyout(itemID)
    
    if not price then
        if not PRV.Config.showOnlyWithPrice then
            return
        end
        return
    end
    
    if price < (PRV.Config.priceThreshold * 10000) then
        return
    end
    
    local realValue = FormatRealValue(price)
    if realValue then
        tooltip:AddDoubleLine(
            "Real Value",           
            realValue,              
            1, 0.82, 0,            
            1, 1, 1                
        )
    end
end

function TooltipHook:Initialize()
    if TooltipDataProcessor then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipData)
            self:ProcessTooltipData(tooltip, tooltipData)
        end)
    else
        local tooltips = {
            GameTooltip,
            ItemRefTooltip,
            _G["ShoppingTooltip1"],
            _G["ShoppingTooltip2"],
            _G["ItemRefShoppingTooltip1"],
            _G["ItemRefShoppingTooltip2"],
        }
        
        for _, tooltip in ipairs(tooltips) do
            if tooltip then
                if tooltip.SetScript then
                    local hookEvents = {"OnShow", "OnUpdate"}
                    for _, event in ipairs(hookEvents) do
                        local originalScript = tooltip:GetScript(event)
                        if originalScript then
                            tooltip:SetScript(event, function(self, ...)
                                originalScript(self, ...)
                                
                                local _, itemLink
                                if self.GetItem then
                                    _, itemLink = self:GetItem()
                                    if itemLink then
                                        self.prvLastItemLink = itemLink
                                    end
                                end
                                
                                if self.prvLastItemLink and event == "OnShow" then
                                    local itemID = tonumber(self.prvLastItemLink:match("item:(%d+)"))
                                    if itemID then
                                        local tooltipData = {id = itemID}
                                        TooltipHook:ProcessTooltipData(self, tooltipData)
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
    
    Utils.Debug(PRV, "Tooltip hooks initialized")
end

return TooltipHook