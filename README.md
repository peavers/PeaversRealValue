# PeaversRealValue

[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/peavers/PeaversRealValue)](https://github.com/peavers/PeaversRealValue/commits/master) [![Last commit](https://img.shields.io/github/last-commit/peavers/PeaversRealValue)](https://github.com/peavers/PeaversRealValue/commits/master) [![CurseForge](https://img.shields.io/curseforge/dt/1266922?label=CurseForge&color=F16436)](https://www.curseforge.com/wow/addons/peaversrealvalue)

**A World of Warcraft addon that displays real-world currency values of items in tooltips, converting their gold value based on current WoW Token prices.

### New!
Check out [peavers.io](https://peavers.io) and [bootstrap.peavers.io](https://bootstrap.peavers.io) for all my WoW addons and support.


## Features

- Shows real-world currency value (USD, EUR, etc.) in item tooltips
- Integrates with TSM and Auctionator for auction house pricing
- Falls back to vendor prices when auction data is unavailable
- Supports multiple global currencies
- Caches prices for optimal performance
- Configurable display options

## Installation

1. Download the latest version
2. Extract the folder to your WoW `Interface/AddOns` directory
3. Ensure PeaversCommons and PeaversCurrencyData are also installed
4. Restart WoW if it's running

## Usage

The addon works automatically once installed. Hover over any item to see its real-world value in the tooltip.

### Slash Commands

- `/prv` or `/realvalue` - Open the configuration panel
- `/prv config` - Open settings
- `/prv clear` - Clear the price cache
- `/prv debug` - Toggle debug mode

## Configuration Options

Access settings through the Interface Options or with `/prv config`:

### General Settings
- **Enable/Disable**: Turn the addon on or off
- **Price Threshold**: Only show values for items above this gold amount
- **Show Only With Price**: Hide values for items without known prices

### Currency Settings
- **Target Currency**: Select your preferred currency (USD, EUR, GBP, etc.)
- **Show Symbol**: Display currency symbols ($, €, £)
- **Decimal Places**: Number of decimal places to show

### Price Source
- **Auction House**: Use TSM/Auctionator prices when available
- **Vendor Only**: Always use vendor sell prices

### Performance
- **Cache Expiry**: How long to keep prices in memory
- **Clear Cache**: Manual cache clearing

## Rates Tab

View current exchange rates and WoW Token prices:
- Regional token prices
- Gold to currency conversion rates
- Currency exchange rates

## Dependencies

- PeaversCommons (required)
- PeaversCurrencyData (required)

## Support & Feedback

If you encounter any issues or have suggestions for improvements, please submit them via [GitHub Issues](https://github.com/peavers/PeaversRealValue/issues). Your feedback is valuable in enhancing the addon experience for all players.
