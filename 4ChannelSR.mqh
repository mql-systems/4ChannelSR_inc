//+------------------------------------------------------------------+
//|                                                   4ChannelSR.mqh |
//|             Copyright 2022. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022. Diamond Systems Corp. and Odiljon T."
#property link      "https://github.com/mql-systems"
#property version   "1.00"

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| C4ChannelSR class                                                |
//| ----------------------                                           |
//| Class for calculating strong 4 channel levels                    |
//+------------------------------------------------------------------+
class C4ChannelSR
{
   private:
      bool              m_Init;
      int               m_CalcBarsCount;
      string            m_Symbol;
      ENUM_TIMEFRAMES   m_Period;
   
   public:
                        C4ChannelSR(void);
                       ~C4ChannelSR(void);
      //---
      bool              Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount);
      bool              Calculate();
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
C4ChannelSR::C4ChannelSR()
{}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
C4ChannelSR::~C4ChannelSR()
{}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool C4ChannelSR::Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount)
{
   //--- initialization check
   if (m_Init)
   {
      if (StringCompare(m_Symbol, symbol) == 0 && m_Period == period)
         return true;
      
      SetUserError(ERR_CHSR_INITIALIZED);
      return false;
   }
   
   //---
   m_Symbol = symbol;
   m_Period = period;
   m_CalcBarsCount = MathMin(MathMax(calcBarsCount, CHSR_CALC_BARS_MIN), CHSR_CALC_BARS_MAX);
 
   m_Init = true;
   Calculate();
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
bool C4ChannelSR::Calculate()
{
   if (! m_Init)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
