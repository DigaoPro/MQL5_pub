//+------------------------------------------------------------------+
//|                                                    MyAccount.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

input int StopBalance = 1000;
input int StopMarginLevel = 200;
input int spread = -1;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MySymbolAccount {
 public:
   CAccountInfo AI;
   CSymbolInfo SI;
   double balance;
   double MinLot;
   double MaxLot;
   double currentSpread;
   double Ask;
   double Bid;
   int LotDigits;
   bool isTradable;
   double StopsLevel;

   void MySymbolAccount() {
      SI.Name(_Symbol);
      MinLot = SI.LotsMin();
      MaxLot = SI.LotsMax();
      LotDigits = -MathLog10(SI.LotsStep());
      StopsLevel = SI.StopsLevel()*_Point*toPips;
      if(StopsLevel <= 2*toPips) StopsLevel = 2*toPips;

   }
   
   void Refresh(){
      SI.RefreshRates();
      Ask = SI.NormalizePrice(SI.Ask());
      Bid = SI.NormalizePrice(SI.Bid());
   }

   bool isOverSpread() {
      currentSpread = SI.Spread();
      if(spread == -1)
         return false;
      if(currentSpread >= spread)
         return true;
      return false;
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// priceが何pipsに相当するかを返却する
double PriceToPips() {
   double pips = 1;
   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = _Digits;
   // 3桁・5桁のFXブローカーの場合
   if(digits == 3 || digits == 5) {
      pips = MathPow(10, digits) / 10;
   }
   // 2桁・4桁のFXブローカーの場合
   if(digits == 2 || digits == 4) {
      pips = MathPow(10, digits);
   }
   // 少数点以下を１桁に丸める（目的によって桁数は変更する）
   pips = NormalizeDouble(pips, 1);
   
   return(pips);
}

double PipsToPrice(){
   double price = 0;

   // 現在の通貨ペアの小数点以下の桁数を取得
   int digits = _Digits;

   // 3桁・5桁のFXブローカー
   if(digits == 3 || digits == 5){
     price = 1 / MathPow(10, digits) * 10;
   }
   // 2桁・4桁のFXブローカー
   if(digits == 2 || digits == 4){
     price = 1 / MathPow(10, digits);
   }
   // 価格を有効桁数で丸める
   price = NormalizeDouble(price, digits);
   return(price);
}

// 整数に対して補正を掛けることでpointからPips換算の値に直す
double ToPips() {
   return _Point*priceToPips;
}
//+------------------------------------------------------------------+
double priceToPips = PriceToPips();
double pipsToPrice = PipsToPrice();
double toPips = ToPips();
//+------------------------------------------------------------------+
