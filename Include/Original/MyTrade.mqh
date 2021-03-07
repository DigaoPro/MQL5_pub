//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Original\MyCalculate.mqh>
#include <Trade\Trade.mqh>

input int spread = -1;
input double risk = 50000;
input double Lot = 0.1;
input bool isLotModified = false;
input int StopBalance = 2000;
input int StopMarginLevel = 300;

class MyTrade: public CTrade {
 public:
   bool isCurrentTradable;
   string signal;
   double lot;
   double Ask;
   double Bid;
   double balance;
   double minlot;
   double maxlot;
   double ContractSize;
   double InitialDeposit;
   int LotDigits;
   bool isTradable;
   double StopLossLevel;

   void MyTrade() {
      minlot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      maxlot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      InitialDeposit = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 1);
      ContractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      SetDeviationInPoints(10);
      LotDigits = -MathLog10(minlot);
      topips = PriceToPips();
      lot = NormalizeDouble(Lot, LotDigits);
      StopLossLevel =  NormalizeDouble(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL), _Digits);
   }

   void Refresh() {
      isCurrentTradable = true;
      signal = "";
      Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
      Ask =  NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   }

   void setSignal(ENUM_ORDER_TYPE OrderType) {
      signal = OrderType;
   }

   void CheckSpread() {
      int currentSpread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread == -1)
         return;
      if(currentSpread >= spread)
         isCurrentTradable = false;
   }

   bool isInvalidTrade(double SL, double TP) {
      if(TP > SL) {
         if((TP - Ask)*topips < 2 || (Ask - SL)*topips < 2) return true;
      } else {
         if( (Bid - TP)*topips < 2  || (SL - Bid)*topips < 2) return true;
      }
      return false;
   }

   bool isLowerBalance() {
      if(NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 1) < StopBalance) return true;
      return false;
   }

   bool isLowerMarginLevel() {
      double marginlevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginlevel < StopMarginLevel && marginlevel != 0 ) return true;
      return false;
   }

   bool Buy(double SL, double TP) {
      if(signal != ORDER_TYPE_BUY) return false;
      if(isInvalidTrade(SL, TP)) return false;
      if(!ModifyLot(SL)) return false;
      if(Buy(lot, NULL, Ask, SL, TP, NULL))
         return true;
      return false;
   }

   bool ForceBuy(double SL, double TP) {
      if(isInvalidTrade(SL, TP)) return false;
      if(!ModifyLot(SL)) return false;
      if(Buy(lot, NULL, Ask, SL, TP, NULL))
         return true;
      return false;
   }

   bool Sell(double SL, double TP) {
      if(signal != ORDER_TYPE_SELL) return false;
      if(isInvalidTrade(SL, TP)) return false;
      if(!ModifyLot(SL)) return false;
      if(Sell(lot, NULL, Bid, SL, TP, NULL))
         return true;
      return false;
   }

   bool ForceSell(double SL, double TP) {
      if(isInvalidTrade(SL, TP)) return false;
      if(!ModifyLot(SL)) return false;
      if(Sell(lot, NULL, Bid, SL, TP, NULL))
         return true;
      return false;
   }

   bool PositionModify(ulong ticket, double SL, double TP) {
      if(isInvalidTrade(SL, TP)) return false;
      if(PositionModify(ticket, SL, TP)) return true;
      return false;
   }

 private:
   double topips;
   bool ModifyLot(double SL) {
      // double TradeRisk = MathAbs(SL - Ask) * topips;
      //if(TradeRisk == 0) return false;
      if(isLotModified) {
         lot = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY) / risk, LotDigits);
         //lot = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY) * risk / (ContractSize * TradeRisk), LotDigits);
      }
      //lot = NormalizeDouble(InitialDeposit / risk / TradeRisk, LotDigits);
      if(lot < minlot) lot = minlot;
      else if(lot > maxlot) lot = maxlot;
      return true;
   }
};
//+------------------------------------------------------------------+
