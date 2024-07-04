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
   if (! Chsr.Init(_Symbol, PERIOD_MN1, 5))
   {
      Alert("Error initializing 4ChannelSR");
      return;
   }
   if (! Chsr.Calculate())
   {
      Alert("Error when calculating 4ChannelSR data");
      return;
   }
   
   double high, low;
   ChannelSRInfo ChsrInfo;
   
   for (int i=0;i<Chsr.Total();i++)
   {
      ChsrInfo = Chsr.At(i);
      high = iHigh(_Symbol,_Period,i);
      low = iLow(_Symbol,_Period,i);
      
      Print("------", i, "------");
      Print("stepSR: ", ChsrInfo.stepSR);
      Print("mainPrice: ", ChsrInfo.mainPrice);
      Print("high: ", ChsrInfo.high);
      Print("low: ", ChsrInfo.low);
      Print("time: ", ChsrInfo.time);
      Print("timeZoneStart: ", ChsrInfo.timeZoneStart);
      Print("timeZoneEnd: ", ChsrInfo.timeZoneEnd);
      Print("GetSupport(",high,", 1): ", ChsrInfo.GetSupport(high, 1));
      Print("GetResistance(",low,", 1): ", ChsrInfo.GetResistance(low, i));
   }
}

//+------------------------------------------------------------------+
```

#### Indicator

There is a [real example](https://github.com/mql-systems/4ChannelSR_indicator) for the indicator.