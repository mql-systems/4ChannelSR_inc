//+------------------------------------------------------------------+
//|                                                   4ChannelSR.mqh |
//|        Copyright 2022-2024. Diamond Systems Corp. and Odiljon T. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022-2024. Diamond Systems Corp. and Odiljon T."
#property link "https://github.com/mql-systems"
#property version "1.02"

#include "Defines.mqh"

//+------------------------------------------------------------------+
//| C4ChannelSR class                                                |
//| ----------------------                                           |
//| Class for calculating strong 4 channel levels                    |
//+------------------------------------------------------------------+
class C4ChannelSR
{
private:
   bool                 m_isInit;
   string               m_symbol;
   ENUM_TIMEFRAMES      m_period;
   //---
   datetime             m_lastBarTime;
   //---
   ChannelSRInfo        m_chsrData[];
   int                  m_chsrTotal;

protected:
   datetime             CalcNextZoneTime(const datetime dt);

public:
                        C4ChannelSR(void);
                       ~C4ChannelSR(void);
   //---
   bool                 Init(const string symbol = NULL, const ENUM_FCHSR_PERIODS periodForCalc = FCHSR_PERIOD_D1, const int calcPeriodsCount = 5);
   bool                 Calculate();
   //---
   string               Symbol() { return m_symbol; };
   ENUM_FCHSR_PERIODS   Period() { return (ENUM_FCHSR_PERIODS)m_period; };
   int                  Total()  { return m_chsrTotal; };
   void                 Clear()  { ArrayFree(m_chsrData); m_chsrTotal = 0; m_lastBarTime = 0; };
   ChannelSRInfo        At(const int pos) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
C4ChannelSR::C4ChannelSR() : m_isInit(false),
                             m_symbol(NULL),
                             m_period(NULL),
                             m_lastBarTime(0),
                             m_chsrTotal(0)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
C4ChannelSR::~C4ChannelSR()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//| ---------------                                                  |
//| @param symbol           Symbol. Default: Current symbol          |
//| @param periodForCalc    Period. Default: FCHSR_PERIOD_D1         |
//| @param calcPeriodsCount The number of billing periods            |
//|                         (from 1 to 365). Default: 5              |
//| @return bool                                                     |
//+------------------------------------------------------------------+
bool C4ChannelSR::Init(const string symbol, const ENUM_FCHSR_PERIODS periodForCalc, const int calcPeriodsCount)
{
   string _symbol = symbol == NULL ? _Symbol : symbol;

   //--- initialization check
   if (m_isInit)
   {
      if (StringCompare(m_symbol, _symbol) == 0 && m_period == (ENUM_TIMEFRAMES)periodForCalc)
         return true;

      SetUserError(ERR_FCHSR_INITIALIZED);
      return false;
   }

   //--- set the start time
   int barShift = MathMin(MathMax(calcPeriodsCount, 1), 365) - 1;
   m_lastBarTime = iTime(_symbol, (ENUM_TIMEFRAMES)periodForCalc, barShift);
   if (m_lastBarTime == 0)
      return false;

   //--- params
   m_symbol = _symbol;
   m_period = (ENUM_TIMEFRAMES)periodForCalc;
   m_isInit = true;

   //--- start calculate
   Calculate();

   return true;
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
bool C4ChannelSR::Calculate()
{
   if (! m_isInit)
   {
      SetUserError(ERR_FCHSR_NOT_INITIALIZED);
      return false;
   }

   //--- new bar
   datetime newBarTime = iTime(m_symbol, m_period, 0);
   if (newBarTime == 0)
      return false;
   if (m_lastBarTime == newBarTime)
      return true;

   //--- getting the data of new bars
   MqlRates barRates[];
   int barCnt = CopyRates(m_symbol, m_period, m_lastBarTime, newBarTime, barRates);
   if (barCnt == -1)
      return false;
   if (barCnt < 2 || m_lastBarTime != barRates[0].time || newBarTime != barRates[barCnt - 1].time)
   {
      SetUserError(ERR_FCHSR_COPYRATES_DATA_DOES_NOT_MATCH);
      return false;
   }

   //--- calc
   int calcBarCnt = barCnt - 1;
   if (ArrayResize(m_chsrData, m_chsrTotal + calcBarCnt, 100) == -1)
      return false;

   for (int i = 0; i < calcBarCnt; i++)
   {
      m_chsrData[m_chsrTotal].high = barRates[i].high;
      m_chsrData[m_chsrTotal].low = barRates[i].low;
      m_chsrData[m_chsrTotal].stepSR = (barRates[i].high - barRates[i].low) / 4;
      m_chsrData[m_chsrTotal].mainPrice = m_chsrData[m_chsrTotal].stepSR * 2 + barRates[i].low;
      //---
      m_chsrData[m_chsrTotal].time = barRates[i].time;
      m_chsrData[m_chsrTotal].timeZoneStart = barRates[i + 1].time;
      m_chsrData[m_chsrTotal].timeZoneEnd = (i + 2 < barCnt) ? barRates[i + 2].time : CalcNextZoneTime(m_chsrData[m_chsrTotal].timeZoneStart);
      //---
      m_chsrTotal++;
   }

   m_lastBarTime = newBarTime;

   return true;
}

//+------------------------------------------------------------------+
//| Calculate the datetime of the next zone                          |
//+------------------------------------------------------------------+
datetime C4ChannelSR::CalcNextZoneTime(const datetime dt)
{
   switch (m_period)
   {
      case PERIOD_D1:
         return dt + 86400;
      case PERIOD_W1:
         return dt + 604800;
      default:
      {
         datetime dtMax = dt + 2678400; // 32 days
         MqlDateTime dtCheck;
         TimeToStruct(dtMax, dtCheck);

         return dtMax - ((dtCheck.day - 1) * 86400);
      }
   }
}

//+------------------------------------------------------------------+
//| Access to data in the specified position                         |
//+------------------------------------------------------------------+
ChannelSRInfo C4ChannelSR::At(const int pos) const
{
   if (pos > -1 && pos < m_chsrTotal)
      return m_chsrData[m_chsrTotal - pos - 1];

   SetUserError(ERR_FCHSR_POSITION_NOT_FOUND);
   ChannelSRInfo ChsrEmpty;
   return ChsrEmpty;
}

//+------------------------------------------------------------------+
