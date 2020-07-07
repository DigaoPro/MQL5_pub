//+------------------------------------------------------------------+
//|                                            1009ScalpFractals.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Original\prices.mqh>
#include <Original\positions.mqh>
#include <Original\period.mqh>
#include <Original\account.mqh>
#include <Original\Ontester.mqh>
#include <Original\caluculate.mqh>
CTrade trade;

MqlDateTime dt;
input int MIN;
input double BBDev;
input int BBPeriod,BBParam,BBPricetype;
input int positions,denom;
double lot = 0.10;
double  Bid,Ask;

int BBIndicator;
double Main[],Plus[],Minus[];

input int arrayRange;
input double BWLowCri;
int BBandWidthIndicator;
double  BandWidth[];
MqlRates Price[];
input int spread;
string signal;
input int RSICri;


int RSIIndicator;
double RSI[];


bool tradable = true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(300);
   ArraySetAsSeries(Main,true);
   ArraySetAsSeries(Plus,true);
   ArraySetAsSeries(Minus,true);
   ArraySetAsSeries(BandWidth,true);
   ArraySetAsSeries(Price,true);
   ArraySetAsSeries(RSI,true);
   BBIndicator =  iBands(_Symbol,Timeframe(BBPeriod),BBParam,0,BBDev,BBPricetype);
   RSIIndicator =  iRSI(_Symbol,Timeframe(BBPeriod),14,BBPricetype);
   ArrayResize(BandWidth,arrayRange);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {


   Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);


   CopyBuffer(BBIndicator, 0,0,2, Minus);
   CopyBuffer(BBIndicator, 1,0,2, Main);
   CopyBuffer(BBIndicator, 2,0,2, Plus);
   CopyBuffer(RSIIndicator, 0,0,2, RSI);
   CopyRates(_Symbol,Timeframe(BBPeriod),0,2,Price);

   BandWidth[0] = (Main[0] - Plus[0]) *1000;

   signal = "";


   if(tradable == false || isTooBigSpread(spread))
     {
      return;
     }

   if(RSI[0] < 100-RSICri && Price[0].high > Plus[0] && Price[0].close < Plus[0])
     {
      signal = "buy";
     }
   else
      if(RSI[0] > RSICri && Price[0].low < Plus[0] && Price[0].close > Minus[0])
        {
         signal = "sell";
        }

   if(EachPositionsTotal("buy") < positions/2 && signal =="buy")
     {
      if((Main[0] - Ask) > 20*_Point && (Ask - Minus[0]) > 20*_Point)
         trade.Buy(lot,NULL,Ask,Minus[0]-50*_Point,Main[0],NULL);
     }

   if(EachPositionsTotal("sell") < positions/2 && signal =="sell")
     {
      if((Bid - Plus[0]) > 20*_Point  && Minus[0] - Bid > 20*_Point)
         trade.Sell(lot,NULL,Bid,Minus[0],Plus[0],NULL);
     }
  }
//+------------------------------------------------------------------+
double OnTester()
  {
   if(!setVariables())
     {
      return -99999999;
     }
   return testingScalp();

  }
//+------------------------------------------------------------------+
void OnTimer()
  {
   tradable  = true;
//lot =SetLot(denom);
   if(isNotEnoughMoney())
     {
      tradable = false;
      return;
     }




   TimeToStruct(TimeCurrent(),dt);
   if(dt.day_of_week == FRIDAY)
     {
      if((dt.hour == 22 && dt.min > 0) || dt.hour == 23)
        {
         CloseAllBuyPositions();
         CloseAllSellPositions();
         tradable = false;
         return;
        }
     }

   int cant_hour[] = {};
   if(!isTradableJP(cant_hour,dt.hour))
     {
      tradable = false;
      return;
     }

   if(isYearEnd(dt.mon,dt.day))
     {
      tradable = false;
      return;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

/*
     int current = TimeCurrent(); GMT+3 (サーバー時間)
   int gmt = TimeGMT(); GMT+0;
   int gmtoffset = TimeGMTOffset(); local - GMT    ...9hours
   int local = TimeLocal(); GMT+9

*/
//+------------------------------------------------------------------+
