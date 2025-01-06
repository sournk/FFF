# Fractal Fibo FVG Indicator
The trading indicator for MetaTrader 5 builds FVG inside Fibo by Fractals

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* Task: https://www.mql5.com/en/job/230436
* Version: 1.02

![Layout](/img/UM001.%20Layou.gif)

## What's new?
```
1.02: Release version with no limits
1.01: [+] GUI_FRC: Draw Fractal
      [+] ALR_PNC: Push Notification Enabled
1.00: Initial testing version
```

## Strategy

- [x] 1. Detect range using 3-candle fractal swing high and 3-candle fractal swing low.

    !!! warning
        The tops of the standard Fractals indicator from MetaTrader 5 might be different to the tops of this indicator because the standard Williams Fractal indicator uses 5 bars instead of 3.

- [x] 2. Draw FVG if FVG is present ABOVE 50% range as shown on the attached image. FVG will only drawn and alert once the swing high/low fractal is close (3rd candle).
- [x] 3. FVG have the option to select color for bearish and bullish FVG.
- [x] 4. Alert message will be "pair, timeframe and whether bearish/bullish FVG" i.e. XauUsd m30 bearish FVG

## User Inputs

##### 1. INDICATOR (IND)
- [x] `IND_DTH`: **Start Depth, bars**: How many bars back will be processed when the indicator starts.
- [x] `IND_LEV`: **Fibo threshold for FVG**: Fibo Level for FVG filter
- [x] `IND_SOD`: **Skip the tops of fractals in Same Direction**: If True, the indicator only builds the first Fibo between a few  same direction tops of the Fractal.  Otherwise, the indicator builds multiple Fibos.
![IND_SOD](/img/UM002.%20IND_SOD.png)

##### 2. GUI
- [x] `GUI_FIB`: Draw Fibo
- [x] `GUI_FVG`: Draw FVG
- [x] `GUI_FRC`: ==Draw Fractals==
- [x] `GUI_COL_BUL`: Color for Bullish
- [x] `GUI_COL_BER`: Color for Bearish

##### 3. ALERTS (ALR)
- [x] `ALR_ENB`: Show alerts
- [x] `ALR_PNC`: ==Push Notification Enabled.== Read [MetaTrader 5 help](https://www.metatrader5.com/en/mobile-trading/iphone/help/settings_messages#my_id) to set notifications up.
- [x] `ALR_LL`: Log Level

## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the indicator executable file `*.ex5` to the terminal data directory `MQL5\Indicators`.
3. Open the pair chart.
4. Move the Expert Advisor from the Navigator window to the chart.
5. Check `Allow Auto Trading` in the bot settings.
6. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
7. Load the set of settings by clicking the `Load` button and selecting the set-file.

