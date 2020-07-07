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
double BBhigh[],BBlow[],BBmiddle[];

input int arrayRange;
input double BWLowCri;
int BBandWidthIndicator;
double  BandWidth[];
MqlRates Price[];
input int trendCri,trendStopCri;
input int spread;
string signal;
input int perBLowCri,perBHighCri;

bool tradable = true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(300);
   ArraySetAsSeries(BBhigh,true);
   ArraySetAsSeries(BBlow,true);
   ArraySetAsSeries(BBmiddle,true);
   ArraySetAsSeries(BandWidth,true);
   ArraySetAsSeries(Price,true);
   BBIndicator =  iBands(_Symbol,Timeframe(BBPeriod),BBParam,0,BBDev,BBPricetype);
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


   CopyBuffer(BBIndicator, 0,0,arrayRange, BBmiddle);
   CopyBuffer(BBIndicator, 1,0,arrayRange, BBhigh);
   CopyBuffer(BBIndicator, 2,0,arrayRange, BBlow);
   CopyRates(_Symbol,Timeframe(BBParam),0,3,Price);

   signal = "";
   double perB = (Price[0].close - BBlow[0]) / (BBhigh[0] - BBlow[0]) * 100;

   double Trend = (BBmiddle[0] - BBmiddle[arrayRange-1])/ arrayRange;
        
   if(tradable == false || isTooBigSpread(spread))
     {
      return;
     }

   if(BandWidth[0] > BWLowCri)
     {
      if(perB > 50 + perBLowCri && perB < 100-perBHighCri && Trend > trendCri*_Point)
        {
         signal = "buy";
        }
      if(perB <  50 - perBLowCri && perB > 0+perBHighCri && Trend < -trendCri*_Point)
        {
         signal = "sell";
        }
     }

     
     if(EachPositionsTotal("buy") < positions/2 && signal =="buy")
     {
      if((BBhigh[0] - Ask) > 20*_Point && (Ask - BBmiddle[0]) > 20*_Point)
         trade.Buy(lot,NULL,Ask,BBmiddle[0],BBhigh[0],NULL);
     }

   if(EachPositionsTotal("sell") < positions/2 && signal =="sell")
     {
      if((Bid - BBlow[0]) > 20*_Point  && BBmiddle[0] - Bid > 20*_Point)
         trade.Sell(lot,NULL,Bid,BBmiddle[0],BBlow[0],NULL);
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
   if(!isTradableJP(cant_hour,dt.hour)){
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
