//+------------------------------------------------------------------+
//|                                                  MyCalculate.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Generic\Interfaces\IComparable.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> bool isBetween(T top, T middle, T bottom) {
   if(top - bottom > 0 && top - middle > 0 && middle - bottom > 0) return true;
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> bool isDeadCross(T old_main, T old_signal, T new_main, T new_signal) {
   if(old_main > old_signal && new_main < new_signal) return true;
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> bool isGoldenCross(T old_main, T old_signal, T new_main, T new_signal) {
   if(old_main < old_signal && new_main > new_signal) return true;
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> bool isTurnedToRise(T old_main, T new_main) {
   if(old_main < 0 && new_main > 0) return true;
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T> bool isTurnedToDown(T old_main, T new_main) {
   if(old_main > 0 && new_main < 0) return true;
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NewBarsCount(datetime LastTime, ENUM_TIMEFRAMES Timeframe) {
   return Bars(_Symbol, Timeframe, Timeframe, TimeCurrent());
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+