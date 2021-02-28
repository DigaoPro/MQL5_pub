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
#include <Original\MyCHart.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyChart myChart;
class MyFractal: public CiFractals {
 public:
   int MHighestIndex;
   int KeySize;
   CArrayDouble SUpper, SLower, MUpper, MLower, LUpper, LLower;
   int UIndex, LIndex;

   void MyFractal(int KeySize) {
      this.KeySize = KeySize;
   }

   void myRefresh() {
      Refresh();
      UIndex = 1;
      LIndex = 1;
      SUpper.Clear();
      SLower.Clear();
      MUpper.Clear();
      MLower.Clear();
      LUpper.Clear();
      LLower.Clear();
   }

   void SearchSUpper(int total) {
      while(SUpper.Total() < total) {
         if(Upper(UIndex) != EMPTY_VALUE)
            SUpper.Add(Upper(UIndex));
         UIndex++;
      }
   }
   void SearchSLower(int total) {
      while(SLower.Total() < total) {
         if(Lower(LIndex) != EMPTY_VALUE)
            SLower.Add(Lower(LIndex));
         LIndex++;
      }
   }

   void SearchMiddle(int total = 1) {
      SearchMUpper(total);
      SearchMLower(total);
   }

   void SearchMUpper(int total = 1) {
      SearchSUpper(3);
      while(MUpper.Total() < total) {
         int STotal = SUpper.Total();
         SearchSUpper(STotal + 1);
         if(SUpper.Maximum(STotal - 3, 3) == STotal - 2)
            MUpper.Add(SUpper.At(STotal - 2));
      }
   }

   void SearchMLower(int total = 1) {
      SearchSLower(3);
      while(MLower.Total() < total) {
         int STotal = SLower.Total();
         SearchSLower(STotal + 1);
         if(SLower.Minimum(STotal - 3, 3) == STotal - 2)
            MLower.Add(SLower.At(STotal - 2));
      }
   }

   void SearchLUpper() {
      SearchMUpper(3);
      while(LUpper.Total() < 1) {
         int MTotal = MUpper.Total();
         SearchMUpper(MTotal + 1);
         if(MUpper.Maximum(MTotal - 3, 3) == MTotal - 2)
            LUpper.Add(MUpper.At(MTotal - 2));
         myChart.HLine(LUpper.At(0), 0, "ULong", clrRed);
         myChart.HLine(MUpper.At(0), 0, "UMiddle", clrAqua);
         myChart.HLine(SUpper.At(0), 0, "UShort", clrAntiqueWhite);
      }
   }

   void SearchLLower() {
      SearchMLower(3);
      while(LLower.Total() < 1) {
         int MTotal = MLower.Total();
         SearchMLower(MTotal + 1);
         if(MLower.Minimum(MTotal - 3, 3) == MTotal - 2)
            LLower.Add(MLower.At(MTotal - 2));
         myChart.HLine(LLower.At(0), 0, "LLong", clrRed);
         myChart.HLine(MLower.At(0), 0, "LMiddle", clrAqua);
         myChart.HLine(SLower.At(0), 0, "LShort", clrAntiqueWhite);
      }
   }

   void SearchLong() {
      SearchLLower();
      SearchLUpper();
   }

   bool isLMLinedCorrectly() {
      if(LUpper.At(0) > MUpper.At(0) && LLower.At(0) < MLower.At(0))
         return true;
      return false;
   }

   bool isMSLinedCorrectly() {
      if(MUpper.At(0) > SUpper.At(0) && MLower.At(0) < SLower.At(0))
         return true;
      return false;
   }

   bool isRecentFractal(bool isUpper, double Val) {
      if(isUpper) {
         if(Upper(2) == Val)
            return true;
      } else {
         if(Lower(2) == Val)
            return true;
      }
      return false;
   }

};
//+------------------------------------------------------------------+
