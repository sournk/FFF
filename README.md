# DS-AZS
The bot for MetaTrader 5 with Anchor Zone Setup by L.A. Little

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me)
* Version: 1.00

## What's new?
```
1.00: MVP with only zone detection and drawing with no trades.
```

## Strategy

The strategy is based on ideas of articles:
1. https://tlap.com/forum/topic/24817-strategija-torgovli-v-jakornyh-zonah/
2. https://www.tradingsetupsreview.com/anchor-zones-trading-strategy/
3. L.A. Little book [Trend Qualification and Trading](https://www.amazon.com/dp/0470889667?tag=tradseturevi-20&linkCode=ogi&th=1&psc=1)

!!! warning
    This bot is only MVP to test strategy. The article describes a few pages of strategy from Little's book taken out of context. I'm not sure that all the methods from the book can be moulded into an automatic strategy: there are too many of them, they are complex and from very different fields. 
    
    **Therefore, the strategy development has been discontinued.**


## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts`.
3. Open the pair chart.
4. Move the Expert Advisor from the Navigator window to the chart.
5. Check `Allow Auto Trading` in the bot settings.
6. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
7. Load the set of settings by clicking the `Load` button and selecting the set-file.

