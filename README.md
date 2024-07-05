# 4ChannelSR

MultiMQL library for calculating support/resistance from the previous day, divided by 4.

![4ChannelSR](https://github.com/mql-systems/4ChannelSR_inc/raw/main/image.png)

## Installation

```bash
cd "YourMT4(5)TerminalPath\MQL4(5)\Include"
git clone https://github.com/mql-systems/4ChannelSR_inc.git MqlSystems/4ChannelSR
```

## Examples

#### Script

```mql5
//+------------------------------------------------------------------+
//|                                               4ChannelSRTest.mqh |
//|        Copyright 2022-2024. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp. and Odiljon T."
#property link      "https://github.com/mql-systems"
#property version   "1.00"

#include <MqlSystems/4ChannelSR/4ChannelSR.mqh>

C4ChannelSR Chsr;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   if (! Chsr.Init(_Symbol, FCHSR_PERIOD_W1, 10))
   {
      Alert("Error initializing 4ChannelSR");
      return;
   }
   if (! Chsr.Calculate())
   {
      Alert("Error when calculating 4ChannelSR data");
      return;
   }
   
   ChannelSRInfo ChsrInfo;
   double supportPrice, resistancePrice;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   string bidStr = DoubleToString(bid, _Digits);
   
   for (int i = 0; i < Chsr.Total(); i++)
   {
      ChsrInfo = Chsr.At(i);
      supportPrice = ChsrInfo.GetSupport(bid, 1);          // Support 1
      resistancePrice = ChsrInfo.GetResistance(bid, 1);    // Resistance 1
      
      Print("------", i, "------");
      Print("stepSR: ", ChsrInfo.stepSR);
      Print("mainPrice: ", ChsrInfo.mainPrice);
      Print("high: ", ChsrInfo.high);
      Print("low: ", ChsrInfo.low);
      Print("time: ", ChsrInfo.time);
      Print("timeZoneStart: ", ChsrInfo.timeZoneStart);
      Print("timeZoneEnd: ", ChsrInfo.timeZoneEnd);
      Print(StringFormat("GetSupport(%s, 1): %s", bidStr, DoubleToString(supportPrice, _Digits)));
      Print(StringFormat("GetResistance(%s, 1): %s", bidStr, DoubleToString(resistancePrice, _Digits)));
   }
}

//+------------------------------------------------------------------+
```

#### Indicator

There is a [real example](https://github.com/mql-systems/4ChannelSR_indicator) for the indicator.