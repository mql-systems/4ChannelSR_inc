//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|        Copyright 2022-2024. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp. and Odiljon T."
#property link      "https://github.com/mql-systems"

//--- errors
#define ERR_FCHSR_INITIALIZED                   464 + 1001  // The class has already been initialized with other parameters
#define ERR_FCHSR_NOT_INITIALIZED               464 + 1002  // The Init(...) method is not running
#define ERR_FCHSR_POSITION_NOT_FOUND            464 + 1003  // The specified position was not found in C4ChannelSR
#define ERR_FCHSR_COPYRATES_DATA_DOES_NOT_MATCH 464 + 1004  // The data returned by CopyRates() does not match the requested data

//+------------------------------------------------------------------+
//| ENUM_FCHSR_PERIODS - Periods for calculating 4ChanelSR           |
//+------------------------------------------------------------------+
enum ENUM_FCHSR_PERIODS
{
   FCHSR_PERIOD_D1  = PERIOD_D1,
   FCHSR_PERIOD_MN1 = PERIOD_MN1,
   FCHSR_PERIOD_W1  = PERIOD_W1
};

//+------------------------------------------------------------------+
//| ENUM_FCHSR_TYPE - Type of channels (High/Low or Open/Close)      |
//+------------------------------------------------------------------+
enum ENUM_FCHSR_TYPE
{
   FCHSR_TYPE_HL, // High/Low
   FCHSR_TYPE_OC  // Open/Close
};

//+------------------------------------------------------------------+
//| struct ChannelSRInfo - To collect 4ChannelSR data                |
//+------------------------------------------------------------------+
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