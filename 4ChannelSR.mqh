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
      string            m_Symbol;
      ENUM_TIMEFRAMES   m_Period;
      //---
      datetime          m_NewBarTime;
      //---
      ChannelSRInfo     m_ChsrData[];
      int               m_ChsrTotal;
   
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
C4ChannelSR::C4ChannelSR():m_Init(false),
                           m_ChsrTotal(0)
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
   
   //--- checking the period
   if (period != PERIOD_D1 && period != PERIOD_W1 && period != PERIOD_MN1)
   {
      SetUserError(ERR_CHSR_INITIALIZED);
      return false;
   }

   //--- set the start time
   int barShift = MathMin(MathMax(calcBarsCount, CHSR_CALC_BARS_MIN), CHSR_CALC_BARS_MAX)-1;
   m_NewBarTime = iTime(symbol, period, barShift);
   if (m_NewBarTime == 0)
      return false;
   
   //--- params
   m_Symbol = symbol;
   m_Period = period;
   m_Init = true;
   
   //--- start calculate
   Calculate();
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
bool C4ChannelSR::Calculate()
{
   if (! m_Init)
   {
      SetUserError(ERR_CHSR_NOT_INITIALIZED);
      return false;
   }
   
   //--- new bar
   datetime newBarTime = iTime(m_Symbol, m_Period, 1);
   if (newBarTime == 0)
      return false;
   if (m_NewBarTime == newBarTime)
      return true;
   
   //--- getting the data of new bars
   MqlRates barRates[];
   int barCnt = CopyRates(m_Symbol, m_Period, m_NewBarTime, newBarTime, barRates);
   if (barCnt < 2 || m_NewBarTime != barRates[0].time)
      return false;
   
   //--- calc
   int i = 1; // the zero element is always calculated
   if (ArrayResize(m_ChsrData, m_ChsrTotal+barCnt-1, 100) == -1)
      return false;
   
   for (; i<barCnt; i++)
   {
      m_ChsrData[m_ChsrTotal].time = barRates[i].time;
      m_ChsrData[m_ChsrTotal].step = (barRates[i].high-barRates[i].low)/4;
      m_ChsrData[m_ChsrTotal].price = m_ChsrData[m_ChsrTotal].step*2+barRates[i].low;
      m_ChsrTotal++;
   }
   
   m_NewBarTime = newBarTime;
   
   return true;
}

//+------------------------------------------------------------------+
