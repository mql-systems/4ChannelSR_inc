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
   
   protected:
      datetime          CalcNextZoneTime(const datetime dt);
   
   public:
                        C4ChannelSR(void);
                       ~C4ChannelSR(void);
      //---
      bool              Init(const string symbol, const ENUM_TIMEFRAMES period, const int calcBarsCount);
      bool              Calculate();
      //---
      string            Symbol() { return m_Symbol;    };
      ENUM_TIMEFRAMES   Period() { return m_Period;    };
      int               Total()  { return m_ChsrTotal; };
      ChannelSRInfo     At(const int pos) const;
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
   datetime newBarTime = iTime(m_Symbol, m_Period, 0);
   if (newBarTime == 0)
      return false;
   if (m_NewBarTime == newBarTime)
      return true;
   
   //--- getting the data of new bars
   MqlRates barRates[];
   int barCnt = CopyRates(m_Symbol, m_Period, m_NewBarTime, newBarTime, barRates);
   if (barCnt < 3 || m_NewBarTime != barRates[0].time)
      return false;
   
   //--- calc
   int i = 1; // the zero element is always calculated
   int calcBarCnt = barCnt-1;
   if (ArrayResize(m_ChsrData, m_ChsrTotal+calcBarCnt-1, 100) == -1)
      return false;
   
   for (; i<calcBarCnt; i++)
   {
      m_ChsrData[m_ChsrTotal].high = barRates[i].high;
      m_ChsrData[m_ChsrTotal].low = barRates[i].low;
      m_ChsrData[m_ChsrTotal].stepSR = (barRates[i].high-barRates[i].low)/4;
      m_ChsrData[m_ChsrTotal].mainPrice = m_ChsrData[m_ChsrTotal].stepSR*2+barRates[i].low;
      //---
      m_ChsrData[m_ChsrTotal].time = barRates[i].time;
      m_ChsrData[m_ChsrTotal].timeZoneStart = barRates[i+1].time;
      m_ChsrData[m_ChsrTotal].timeZoneEnd = (i+2 < barCnt) ? barRates[i+2].time : CalcNextZoneTime(m_ChsrData[m_ChsrTotal].timeZoneStart);
      //---
      m_ChsrTotal++;
   }
   
   m_NewBarTime = newBarTime;
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate the datetime of the next zone                          |
//+------------------------------------------------------------------+
datetime C4ChannelSR::CalcNextZoneTime(const datetime dt)
{
   switch (m_Period)
   {
      case PERIOD_D1: return dt+86400;
      case PERIOD_W1: return dt+604800;
      default:
      {
         datetime dtMax = dt+2678400; // 32 days
         MqlDateTime dtCheck;
         TimeToStruct(dtMax, dtCheck);
         
         return dtMax-((dtCheck.day-1)*86400);
      }
   }
}

//+------------------------------------------------------------------+
//| Access to data in the specified position                         |
//+------------------------------------------------------------------+
ChannelSRInfo C4ChannelSR::At(const int pos) const
{
   if (pos > -1 && pos < m_ChsrTotal)
      return m_ChsrData[pos];
   
   ChannelSRInfo ChsrEmpty;
   return ChsrEmpty;
}

//+------------------------------------------------------------------+
