//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|        Copyright 2022-2024. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp. and Odiljon T."
#property link      "https://github.com/mql-systems"

#define CHSR_CALC_BARS_MIN 1
#define CHSR_CALC_BARS_MAX 365

//--- errors
#define ERR_CHSR_INITIALIZED     1  // The class has already been initialized with other parameters
#define ERR_CHSR_NOT_INITIALIZED 2  // The init() method is not running
#define ERR_CHSR_PERIOD          3  // Unsupported period. Works only with periods PERIOD_D1, PERIOD_W1, PERIOD_MN1

//--- to collect 4ChannelSR data
struct ChannelSRInfo
{
   double   stepSR;
   double   mainPrice;
   double   high;
   double   low;
   datetime time;
   datetime timeZoneStart;
   datetime timeZoneEnd;
   //---
   double GetSupport(const double price, const int lineNumber = 1)
   {
      double p;
      if (mainPrice > price)
         p = mainPrice - MathFloor((mainPrice - price) / stepSR) * stepSR;
      else
         p = mainPrice + MathCeil((price - mainPrice) / stepSR) * stepSR;
      
      return (p -= (lineNumber < 2) ? stepSR : stepSR * lineNumber);
   }
   //---
   double GetResistance(const double price, const int lineNumber = 1)
   {
      double p;
      if (mainPrice > price)
         p = mainPrice - MathCeil((mainPrice - price) / stepSR) * stepSR;
      else
         p = mainPrice + MathFloor((price - mainPrice) / stepSR) * stepSR;
      
      return (p += (lineNumber < 2) ? stepSR : stepSR * lineNumber);
   }
};