//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Original\MyPrice.mqh>
#include <Original\MyUtils.mqh>
#include <Original\MyTrade.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Generic\HashMap.mqh>

input double positionCloseMinPow = -1;
input int positions = 1;

class MyPosition {
 public:
   MqlDateTime dt;
   int Total;
   int CloseMin;
   CHashMap<ulong, bool > TrailingTickets, PartialClosedTickets;
   CArrayLong SellTickets, BuyTickets;
   int LotDigit;
   CPositionInfo PositionInfo;


   void MyPosition() {
      CloseMin = 10 * MathPow(2, positionCloseMinPow);
      MyTrade myTrade;
      LotDigit = myTrade.LotDigits;

   }

   void Refresh() {
      Total = PositionsTotal();
      BuyTickets.Clear();
      SellTickets.Clear();
      for(int i = Total - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         PositionInfo.SelectByTicket(ticket);
         if(PositionInfo.PositionType() == POSITION_TYPE_BUY) {
            BuyTickets.Add(ticket);
         } else {
            SellTickets.Add(ticket);
         }
      }
   }

   bool isPositionInRange( ENUM_POSITION_TYPE PositionType, double Range) {
      CArrayLong Tickets = (PositionType == POSITION_TYPE_BUY) ? BuyTickets : SellTickets;
      for(int i = 0; i < Tickets.Total(); i++) {
         PositionInfo.SelectByTicket(Tickets.At(i));
         if(MathAbs(CurrentProfit()) < Range) {
            return true;
         }
      }
      return false;
   }

   bool isAnyPositionHasProfit(ENUM_POSITION_TYPE PositionType, double Range = 0) {
      CArrayLong Tickets = (PositionType == POSITION_TYPE_BUY) ? BuyTickets : SellTickets;
      for(int i = 0; i < Tickets.Total(); i++) {
         PositionInfo.SelectByTicket(Tickets.At(i));
         if(CurrentProfit() > 0) return true;
      }
      return false;
   }

   void CloseAllPositions(ENUM_POSITION_TYPE PositionType) {
      CArrayLong Tickets = (PositionType == POSITION_TYPE_BUY) ? BuyTickets : SellTickets;
      for(int i = 0; i < Tickets.Total(); i++) {
         int ticket = Tickets.At(i);
         PositionInfo.SelectByTicket(ticket);
         itrade.PositionClose(ticket);
      }
   }

   void CloseAllPositionsInMinute() {
      if(positionCloseMinPow == -1) return;
      for(int i = 0; i < BuyTickets.Total(); i++) {
         int ticket = BuyTickets.At(i);
         PositionInfo.SelectByTicket(ticket);
         if( TimeCurrent() - PositionInfo.Time() >= CloseMin * 60 )
            itrade.PositionClose(ticket);
      }
      for(int i = 0; i < SellTickets.Total(); i++) {
         int ticket = SellTickets.At(i);
         PositionInfo.SelectByTicket(ticket);
         if( TimeCurrent() - PositionInfo.Time() >= CloseMin * 60 )
            itrade.PositionClose(ticket);
      }
   }

   void CloseAllPositionsByProfit(ENUM_POSITION_TYPE PositionType, double TP = NULL, double SL = NULL) {
      CTrade itrade;
      for(int i = Total - 1; i >= 0; i--) {
         PositionInfo.SelectByTicket(PositionGetTicket(i));
         if(PositionInfo.Magic() != MagicNumber) continue;
         if(PositionInfo.PositionType() != PositionType) continue;
         double profit = PositionInfo.Profit() * _Point;
         if(profit > TP && TP != 0 )
            itrade.PositionClose(PositionGetTicket(i));
         else if(profit < SL && SL != 0 )
            itrade.PositionClose(PositionGetTicket(i));
      }
   }

   void CloseEachPosition(ulong PositionTicket) {
      PositionInfo.SelectByTicket(PositionTicket);
      if(PositionInfo.Magic() != MagicNumber) return;
      itrade.PositionClose(PositionTicket);
   }

   void CloseEachPosition(ulong ticket, double lotPer) {
      PositionInfo.SelectByTicket(ticket);
      itrade.PositionClosePartial(ticket, PositionInfo.Volume()*lotPer);
   }

   void ClosePartial(ulong ticket, double perVolume) {
      if(PartialClosedTickets.ContainsKey(ticket))
         return;
      double vol = NormalizeDouble(PositionInfo.Volume() * perVolume, LotDigit);
      if(itrade.PositionClosePartial(ticket, NormalizeDouble(PositionInfo.Volume()*perVolume, LotDigit)))
         PartialClosedTickets.Add(ticket, true);
   }

   int TotalEachPositions(ENUM_POSITION_TYPE PositionType) {
      CArrayLong Tickets = (PositionType == POSITION_TYPE_BUY) ? BuyTickets : SellTickets;
      return Tickets.Total();
   }

   bool AddListForTrailings(ulong ticket) {
      if(TrailingTickets.ContainsKey(ticket)) return false;
      TrailingTickets.Add(ticket, true);
      return true;
   }

   void AddListForPartialClose(ulong ticket) {
      if(!PartialClosedTickets.ContainsKey(ticket))
         PartialClosedTickets.Add(ticket, true);
   }

   void Select(ulong ticket) {
      PositionInfo.SelectByTicket(ticket);
   }

   double StopLoss() {
      return MathAbs(PositionInfo.StopLoss() - PositionInfo.PriceOpen());
   }

   double CurrentProfit() {
      double profit = PositionInfo.PriceCurrent() - PositionInfo.PriceOpen();
      if(PositionInfo.PositionType() == POSITION_TYPE_BUY)
         return profit;
      return -profit;
   }

   void Trailings(ENUM_POSITION_TYPE PositionType, double SL, double TP) {
      CArrayLong Tickets = (PositionType == POSITION_TYPE_BUY) ? BuyTickets : SellTickets;
      for(int i = 0; i < Tickets.Total(); i++) {
         ulong ticket = Tickets.At(i);
         if(!TrailingTickets.ContainsKey(ticket)) continue;
         PositionInfo.SelectByTicket(ticket);
         if(StopLoss() < MathAbs(SL - PositionInfo.PriceCurrent())) continue;
         itrade.PositionModify(ticket, SL, TP );
      }

   }

   long CloseByPassedBars(ENUM_POSITION_TYPE PositionType, ENUM_TIMEFRAMES priceTimeframe, int barsCount) {
      for(int i = Total - 1; i >= 0; i--) {
         PositionInfo.SelectByTicket(PositionGetTicket(i));
         if(PositionInfo.PositionType() != PositionType) continue;
         if(PositionInfo.Magic() != MagicNumber) continue;
         if(Bars(_Symbol, priceTimeframe, PositionInfo.Time(), TimeCurrent()) > barsCount) {
            double dwad = PositionInfo.Ticket();
            CloseEachPosition(PositionInfo.Ticket());
         }
      }
      return 0;
   }



 private:
   CTrade itrade;
   MyTrade myTrade;
};
//+------------------------------------------------------------------+
