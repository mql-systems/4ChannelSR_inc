//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|             Copyright 2022. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022. Diamond Systems Corp. and Odiljon T."
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
   double   step;
   double   price;
   datetime time;
};