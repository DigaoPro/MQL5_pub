//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
struct tradeRequest {
   double                       volume;           // 約定のための要求されたボリューム（ロット単位）
   ENUM_ORDER_TYPE               type;             // 注文の種類
   double                       openPrice;           // Price to open Position
   double                       sl;               // 注文の決済逆指値レベル
   double                       tp;               // 注文の決済指値レベル
   double                       bidOrAsk;       // Bid or Ask
};
//+------------------------------------------------------------------+
