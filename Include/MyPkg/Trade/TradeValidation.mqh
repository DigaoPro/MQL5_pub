//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <MyPkg\Trade\TradeRequest.mqh>

class TradeValidation: public CTrade {
 public:
   bool Check(tradeRequest &tR) {
      bool tpSlCheck = CheckStopLossAndTakeProfit(tR);
      bool volumeCheck = CheckVolumeValue(tR.volume);
      return tpSlCheck && volumeCheck;
   }
 private:
   // prevent invalid stoploss error;
   bool CheckStopLossAndTakeProfit(tradeRequest &tR) {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
      int stopLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      int freezeLevel = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);

      bool slCheck, tpCheck, check = false;

      switch(tR.type) {
      //--- Buy operation
      case ORDER_TYPE_BUY: {
         slCheck = (tR.openPrice - tR.sl > stopLevel * _Point);
         tpCheck = (tR.tp - tR.openPrice > stopLevel * _Point);
         return (slCheck && tpCheck);
      }
      //--- Sell operation
      case ORDER_TYPE_SELL: {
         slCheck = (tR.sl - tR.openPrice > stopLevel * _Point);
         tpCheck = (tR.openPrice - tR.tp > stopLevel * _Point);
         return (slCheck && tpCheck);
      }
      case  ORDER_TYPE_BUY_LIMIT: {
         //--- check the distance from the bidOrAsk to the open price
         check = ((tR.bidOrAsk - tR.openPrice) > freezeLevel * _Point);
         return check;
      }
      case  ORDER_TYPE_SELL_LIMIT: {
         check = ((tR.openPrice - tR.bidOrAsk) > freezeLevel * _Point);
         return check;
      }
      case  ORDER_TYPE_BUY_STOP: {
         check = ((tR.openPrice - tR.bidOrAsk) > freezeLevel * _Point);
         return check;
      }
      case  ORDER_TYPE_SELL_STOP: {
         check = ((tR.bidOrAsk - tR.openPrice) > freezeLevel * _Point);
         return check;
      }
      }
      return true;
   }

   bool CheckVolumeValue(double volume) {
//--- minimal allowed volume for trade operations
      double minVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
      if(volume < minVolume) {
         printf("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f", minVolume);
         return(false);
      }

//--- maximal allowed volume of trade operations
      double maxVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
      if(volume > maxVolume) {
         printf("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f", maxVolume);
         return(false);
      }

//--- get minimal step of volume changing
      double volumeStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);

      int ratio = (int)MathRound(volume / volumeStep);
      if(MathAbs(ratio * volumeStep - volume) > 0.0000001) {
         printf("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                volumeStep, ratio * volumeStep);
         return(false);
      }

      return(true);
   }
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
