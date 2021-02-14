//+------------------------------------------------------------------+
//|                                                    MyFractal.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
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
#include <Indicators\BillWilliams.mqh>
#include <Original\MyCalculate.mqh>
#include <Generic\HashMap.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyFractal:public CiFractals
  {
public:
   int MHighestIndex;
   int VaildPeriod;
   CHashMap<int, double > MUpper, MLower;
   
   void MyFractal(int ValidPeriod){
      this.VaildPeriod = VaildPeriod;
   }
   
   void Refresh(){
      Refresh();
      setValue();
   }
   
   void setValue(){
      int i = 0;
      MUpper.Clear();
      MLower.Clear();
      while(MUpper.Count() == VaildPeriod)
        {
         if(Upper(i) != EMPTY_VALUE) MUpper.Add(MUpper.Count(), Upper(i));
         i++;
        }
      i = 0;
      while(MLower.Count() == VaildPeriod)
        {
         if(Lower(i) != EMPTY_VALUE) MLower.Add(MUpper.Count(), Lower(i));
         i++;
        }
   }
  };
//+------------------------------------------------------------------+
