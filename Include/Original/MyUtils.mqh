//+------------------------------------------------------------------+
//|                                                      MyUtils.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
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
#include <Trade\Trade.mqh>

class MyUtils{
   public:
      int magicNum;
      int eventTime;
      void MyUtils(int magicNum = 0,int eventTime = 0){
         this.magicNum = magicNum;
         this.eventTime = eventTime;
         
      }
      void Init(){
         CTrade trade;
         trade.SetExpertMagicNumber(magicNum);
         if(eventTime > 0) EventSetTimer(eventTime);
      }
      
};