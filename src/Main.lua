local addonName, PRV = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

PRV = PRV or {}
PRV.name = addonName
PRV.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "prv", {
    default = function()
        PRV.ConfigUI:Open()
    end,
    debug = function()
        PRV.Config.debugMode = not PRV.Config.debugMode
        PRV.Config.DEBUG_ENABLED = PRV.Config.debugMode
        PRV.Config:Save()
        Utils.Print(PRV, "Debug mode " .. (PRV.Config.debugMode and "enabled" or "disabled"))
    end,
    clear = function()
        PRV.PriceCache:Clear()
        Utils.Print(PRV, "Price cache cleared")
    end,
    config = function()
        PRV.ConfigUI:Open()
    end,
    help = function()
        Utils.Print(PRV, "Commands:")
        print("  /prv - Open configuration")
        print("  /prv clear - Clear price cache")
        print("  /prv debug - Toggle debug mode")
        print("  /prv config - Open settings")
    end
})

-- Additional slash command
PeaversCommons.SlashCommands:Register(addonName, "realvalue", {
    default = function()
        PRV.ConfigUI:Open()
    end
})

-- Initialize the addon
PeaversCommons.Events:Init(addonName, function()
    PRV.Config:Initialize()
    PRV.ConfigUI:Initialize()
    PRV.PriceCache:Load()
    PRV.TooltipHook:Initialize()
    
    -- Save cache periodically
    PeaversCommons.Events:RegisterOnUpdate(60, function()
        PRV.PriceCache:Save()
    end, "PRV_SaveCache")
    
    -- Create settings pages
    C_Timer.After(0.5, function()
        PeaversCommons.SettingsUI:CreateSettingsPages(
            PRV,
            "PeaversRealValue",
            "Peavers Real Value",
            "Shows the real-world dollar value of items based on their auction house price.",
            {
                "/prv - Open configuration",
                "/prv clear - Clear price cache",
                "/prv debug - Toggle debug mode",
                "/prv config - Open settings"
            }
        )
        
        -- Register the Rates panel as a subcategory
        if PRV.directCategory and PRV.ConfigUI.ratesPanel then
            local ratesCategory = Settings.RegisterCanvasLayoutSubcategory(
                PRV.directCategory, 
                PRV.ConfigUI.ratesPanel, 
                PRV.ConfigUI.ratesPanel.name
            )
            PRV.directRatesCategory = ratesCategory
        end
    end)
end, {
    suppressAnnouncement = true
})

-- Export addon table
_G.PeaversRealValue = PRV

return PRV