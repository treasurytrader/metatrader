
//+------------------------------------------------------------------+
//|                                             ZigAndZagScalpel.mq4 |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

//----

#property strict
#property indicator_chart_window

#property indicator_buffers 4 // ¬ª¬Ý¬Ú 8 - ¬Õ¬Ý¬ñ testBuffer

#property indicator_color1 clrFireBrick
#property indicator_color2 clrWhite
#property indicator_color3 clrRed
#property indicator_color4 clrRed
//#property indicator_color8 White // ¬¥¬Ý¬ñ ¬á¬à¬Õ¬Ò¬à¬â¬Ñ ¬é¬Ö¬Ô¬à-¬ß¬Ú¬Ò¬å¬Õ¬î

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern int KeelOver = 55; // ¬¥¬Ý¬ñ M15 : 55
extern int Slalom   = 17; // ¬¥¬Ý¬ñ M15 : 17

double KeelOverZigAndZagSECTION[];
double KeelOverZagBuffer[];
double SlalomZigBuffer[];
double SlalomZagBuffer[];
double LimitOrdersBuffer[];
double BuyOrdersBuffer[];
double SellOrdersBuffer[];
//double testBuffer[];

int    Shift, Back, CountBar, Backstep = 3;
int    LastSlalomZagPos, LastSlalomZigPos, LastKeelOverZagPos, LastKeelOverZigPos;
double Something, LimitPoints, Navel;
double CurKeelOverZig, CurKeelOverZag, CurSlalomZig, CurSlalomZag;
double LastSlalomZag, LastSlalomZig, LastKeelOverZag, LastKeelOverZig;
bool   TrendUp, SetBuyOrder, SetLimitOrder, SetSellOrder, Second = false;
string LastZigOrZag = "None";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

   IndicatorBuffers(7);

   SetIndexBuffer(0, KeelOverZigAndZagSECTION);
   SetIndexStyle(0, DRAW_SECTION/*, STYLE_DOT*/); // DRAW_SECTION ¬Ú¬Ý¬Ú DRAW_NONE
   SetIndexEmptyValue(0, 0.0);

   SetIndexBuffer(1, LimitOrdersBuffer);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 108);
   SetIndexEmptyValue(1, 0.0);

   SetIndexBuffer(2, BuyOrdersBuffer);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 233);
   SetIndexEmptyValue(2, 0.0);

   SetIndexBuffer(3, SellOrdersBuffer);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234);
   SetIndexEmptyValue(3, 0.0);

   SetIndexBuffer(4, KeelOverZagBuffer);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexEmptyValue(4, 0.0);

   SetIndexBuffer(5, SlalomZigBuffer);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexEmptyValue(5, 0.0);

   SetIndexBuffer(6, SlalomZagBuffer);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexEmptyValue(6, 0.0);

   // SetIndexStyle(7, DRAW_SECTION);
   // SetIndexBuffer(7, testBuffer);
   // SetIndexEmptyValue(7, 0.0);

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //---
   CountBar    = rates_total - KeelOver;
   LimitPoints = Ask - Bid;
   if (CountBar <= 3 * KeelOver) return (-1); // ¬®¬Ñ¬Ý¬à¬Ó¬Ñ¬ä¬à ¬Ò¬å¬Õ¬Ö¬ä
   if (KeelOver <= 2 * Slalom)   return (-1); // ¬´¬ë¬Ñ¬ä¬Ö¬Ý¬î¬ß¬Ö¬Ö ¬ß¬Ñ¬Õ¬à

   // ¬©¬Ñ¬é¬Ú¬ã¬ä¬Ü¬Ñ ¬ß¬Ö¬á¬â¬Ñ¬Ó¬Ú¬Ý¬î¬ß¬à¬Û ¬Ú¬ã¬ä¬à¬â¬Ú¬Ú
   for (Shift = rates_total - 1; Shift > rates_total - KeelOver; Shift--) {
      KeelOverZigAndZagSECTION[Shift] = 0.0;
      KeelOverZagBuffer[Shift] = 0.0;
      SlalomZigBuffer[Shift]   = 0.0;
      SlalomZagBuffer[Shift]   = 0.0;
      LimitOrdersBuffer[Shift] = 0.0;
      BuyOrdersBuffer[Shift]   = 0.0;
      SellOrdersBuffer[Shift]  = 0.0;
      // testBuffer[Shift]     = 0.0;
   }

   //+---¬±¬Ö¬â¬Ó¬í¬Û ¬á¬à¬ç¬à¬Õ ¬á¬à ¬Ú¬ã¬ä¬à¬â¬Ú¬Ú----------------------------------------+
   The_First_Crusade(high, low);

   //+---¬£¬ä¬à¬â¬à¬Û ¬á¬â¬à¬ç¬à¬Õ ¬á¬à ¬Ú¬ã¬ä¬à¬â¬Ú¬é¬Ö¬ã¬Ü¬Ú¬Þ ¬Þ¬Ö¬ã¬ä¬Ñ¬Þ---------------------------+
   //+---¬ã ¬è¬Ö¬Ý¬î¬ð ¬á¬à¬Õ¬é¬Ú¬ã¬ä¬Ü¬Ú ¬ß¬Ö¬Ó¬Ö¬â¬ß¬à ¬á¬à¬ß¬ñ¬ä¬í¬ç ¬ã¬à¬Ò¬í¬ä¬Ú¬Û----------------------+
   LastKeelOverZig    = -1;
   LastKeelOverZigPos = -1;
   LastKeelOverZag    = -1;
   LastKeelOverZagPos = -1;
   LastSlalomZig      = -1;
   LastSlalomZigPos   = -1;
   LastSlalomZag      = -1;
   LastSlalomZagPos   = -1;
   The_Second_Crusade();

   //+---¬´¬â¬Ö¬ä¬Ú¬Û ¬Ú¬ã¬ä¬à¬â¬Ú¬é¬Ö¬ã¬Ü¬Ú¬Û ¬ï¬Ü¬ã¬Ü¬å¬â¬ã - ¬á¬à¬ã¬ä¬â¬à¬Ö¬ß¬Ú¬Ö "¬ä¬â¬Ö¬ß¬Õ¬Ñ"--------------+
   //+---¬Ú ¬â¬Ñ¬ã¬ã¬ä¬Ñ¬ß¬à¬Ó¬Ü¬Ñ "¬ä¬à¬â¬Ô¬à¬Ó¬í¬ç ¬ã¬Ú¬Ô¬ß¬Ñ¬Ý¬à¬Ó"------------------------------+
   LastSlalomZig    = -1;
   LastSlalomZigPos = -1;
   LastSlalomZag    = -1;
   LastSlalomZagPos = -1;
   LastZigOrZag     = "None";
   The_Third_Crusade();

   //+---¬¡ ¬é¬Ö¬Ô¬à ¬Þ¬í ¬ä¬Ö¬á¬Ö¬â¬î ¬Ò¬å¬Õ¬Ö¬Þ ¬Ú¬Þ¬Ö¬ä¬î ¬Ù¬Õ¬Ö¬ã¬î ¬Ú ¬ã¬Ö¬Û¬é¬Ñ¬ã?-------------------+
   Shift_Zerro();

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void The_First_Crusade(const double &high[], const double &low[]) {
   for (Shift = CountBar; Shift > 0; Shift--) {
      // ¬±¬à¬Ú¬ã¬Ü ¬ä¬à¬é¬Ö¬Ü "¬Ó¬ã¬ä¬Ñ¬Ý ¬Ó ¬á¬à¬Ù¬å" - "¬å¬ê¬Ö¬Ý ¬ã ¬â¬í¬ß¬Ü¬Ñ"
      CurSlalomZig = low[Lowest(NULL, 0, MODE_LOW, Slalom, Shift)];
      CurSlalomZag = high[Highest(NULL, 0, MODE_HIGH, Slalom, Shift)];
      // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ Shift ¬ß¬Ñ ¬ß¬Ñ¬Ý¬Ú¬é¬Ú¬Ö ¬à¬é¬Ö¬â¬Ö¬Õ¬ß¬à¬Ô¬à ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ú¬Ô¬Ñ ¬Õ¬Ý¬ñ ¬Ó¬ç¬à¬Õ¬Ñ
      // ¬Ó ¬á¬à¬Ü¬å¬á¬Ü¬å ¬Ú¬Ý¬Ú ¬Õ¬Ý¬ñ ¬Ó¬í¬ç¬à¬Õ¬Ñ ¬Ú¬Ù ¬á¬â¬à¬Õ¬Ñ¬Ø¬Ú
      if (CurSlalomZig == LastSlalomZig)
         CurSlalomZig = 0.0;
      else {
         LastSlalomZig = CurSlalomZig;
         if ((low[Shift] - CurSlalomZig) > LimitPoints)
            CurSlalomZig = 0.0;
         else {
            // ¬¯¬Ñ ¬Ú¬ß¬ä¬Ö¬â¬Ó¬Ñ¬Ý¬Ö Backstep ¬Þ¬à¬Ø¬Ö¬ä ¬Ò¬í¬ä¬î ¬ä¬à¬Ý¬î¬Ü¬à ¬à¬Õ¬Ú¬ß ¬©¬Ú¬Ô,
            // ¬à¬ã¬ä¬Ñ¬Ó¬Ý¬ñ¬Ö¬Þ ¬ä¬à¬Ý¬î¬Ü¬à ¬á¬à¬ã¬Ý¬Ö¬Õ¬ß¬Ú¬Û, ¬Ò¬à¬Ý¬Ö¬Ö ¬â¬Ñ¬ß¬ß¬Ú¬Ö ¬å¬Ò¬Ú¬â¬Ñ¬Ö¬Þ
            for (Back = 1; Back <= Backstep; Back++) {
               Something = SlalomZigBuffer[Shift + Back];
               if ((Something != 0) && (Something > CurSlalomZig))
                  SlalomZigBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ Shift ¬ß¬Ñ ¬ß¬Ñ¬Ý¬Ú¬é¬Ú¬Ö ¬à¬é¬Ö¬â¬Ö¬Õ¬ß¬à¬Ô¬à ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ñ¬Ô¬Ñ ¬Õ¬Ý¬ñ ¬Ó¬ç¬à¬Õ¬Ñ ¬Ó¬ß¬Ú¬Ù
      // ¬Ú¬Ý¬Ú ¬Õ¬Ý¬ñ ¬Ó¬í¬ç¬à¬Õ¬Ñ ¬Ú¬Ù ¬á¬à¬Ü¬å¬á¬Ü¬Ú
      if (CurSlalomZag == LastSlalomZag)
         CurSlalomZag = 0.0;
      else {
         LastSlalomZag = CurSlalomZag;
         if ((CurSlalomZag - high[Shift]) > LimitPoints)
            CurSlalomZag = 0.0;
         else {
            // ¬¯¬Ñ ¬Ú¬ß¬ä¬Ö¬â¬Ó¬Ñ¬Ý¬Ö Backstep ¬Þ¬à¬Ø¬Ö¬ä ¬Ò¬í¬ä¬î ¬ä¬à¬Ý¬î¬Ü¬à ¬à¬Õ¬Ú¬ß ¬©¬Ñ¬Ô,
            // ¬à¬ã¬ä¬Ñ¬Ó¬Ý¬ñ¬Ö¬Þ ¬ä¬à¬Ý¬î¬Ü¬à ¬á¬à¬ã¬Ý¬Ö¬Õ¬ß¬Ú¬Û, ¬Ò¬à¬Ý¬Ö¬Ö ¬â¬Ñ¬ß¬ß¬Ú¬Ö ¬å¬Ò¬Ú¬â¬Ñ¬Ö¬Þ
            for (Back = 1; Back <= Backstep; Back++) {
               Something = SlalomZagBuffer[Shift + Back];
               if ((Something != 0) && (Something < CurSlalomZag))
                  SlalomZagBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // ¬£¬ã¬Ö, ¬é¬ä¬à ¬ß¬Ñ¬ê¬Ý¬Ú ¬ß¬à¬Ó¬Ö¬ß¬î¬Ü¬à¬Ô¬à ¬Ú ¬á¬å¬ã¬ä¬í¬ê¬Ü¬Ú - ¬Ü¬Ý¬Ñ¬Õ¬Ö¬Þ ¬Ó ¬Ò¬å¬æ¬Ö¬â¬Ñ ¬ã¬Ý¬Ñ¬Ý¬à¬Þ¬Ñ
      SlalomZigBuffer[Shift] = CurSlalomZig;
      SlalomZagBuffer[Shift] = CurSlalomZag;
      // ¬ª¬ë¬Ö¬Þ ¬ä¬à¬é¬Ü¬Ú ¬â¬Ñ¬Ù¬Ó¬à¬â¬à¬ä¬Ñ ¬Õ¬Ý¬ñ ¬á¬à¬ã¬ä¬â¬à¬Ö¬ß¬Ú¬ñ "¬Ý¬Ú¬ß¬Ö¬Û¬ß¬à¬Ô¬à ¬ä¬â¬Ö¬ß¬Õ¬Ñ", ¬á¬â¬Ú ¬ï¬ä¬à¬Þ
      // ¬Ó ¬Ò¬å¬æ¬Ö¬â ¬â¬Ñ¬Ù¬Ó¬à¬â¬à¬ä¬à¬Ó ZigAndZag ¬á¬à¬Ü¬Ñ ¬é¬ä¬à ¬Ò¬å¬Õ¬Ö¬Þ ¬Ü¬Ý¬Ñ¬ã¬ä¬î ¬ä¬à¬Ý¬î¬Ü¬à ¬°¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î¬©¬Ú¬Ô¬Ú
      CurKeelOverZig = low[Lowest(NULL, 0, MODE_LOW, KeelOver, Shift)];
      CurKeelOverZag = high[Highest(NULL, 0, MODE_HIGH, KeelOver, Shift)];
      // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ Shift ¬ß¬Ñ ¬ß¬Ñ¬Ý¬Ú¬é¬Ú¬Ö ¬à¬é¬Ö¬â¬Ö¬Õ¬ß¬à¬Ô¬à ¬°¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î¬©¬Ú¬Ô¬Ñ
      if (CurKeelOverZig == LastKeelOverZig)
         CurKeelOverZig = 0.0;
      else {
         LastKeelOverZig = CurKeelOverZig;
         if ((low[Shift] - CurKeelOverZig) > LimitPoints)
            CurKeelOverZig = 0.0;
         else {
            // ¬¯¬Ñ ¬Ú¬ß¬ä¬Ö¬â¬Ó¬Ñ¬Ý¬Ö Backstep ¬Þ¬à¬Ø¬Ö¬ä ¬Ò¬í¬ä¬î ¬ä¬à¬Ý¬î¬Ü¬à ¬à¬Õ¬Ú¬ß ¬©¬Ú¬Ô,
            // ¬à¬ã¬ä¬Ñ¬Ó¬Ý¬ñ¬Ö¬Þ ¬ä¬à¬Ý¬î¬Ü¬à ¬á¬à¬ã¬Ý¬Ö¬Õ¬ß¬Ú¬Û, ¬Ò¬à¬Ý¬Ö¬Ö ¬â¬Ñ¬ß¬ß¬Ú¬Ö ¬å¬Ò¬Ú¬â¬Ñ¬Ö¬Þ
            for (Back = 1; Back <= Backstep; Back++) {
               Something = KeelOverZigAndZagSECTION[Shift + Back];
               if ((Something != 0) && (Something > CurKeelOverZig))
                  KeelOverZigAndZagSECTION[Shift + Back] = 0.0;
            }
         }
      }
      // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ Shift ¬ß¬Ñ ¬ß¬Ñ¬Ý¬Ú¬é¬Ú¬Ö ¬à¬é¬Ö¬â¬Ö¬Õ¬ß¬à¬Ô¬à ¬°¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î¬©¬Ñ¬Ô¬Ñ
      if (CurKeelOverZag == LastKeelOverZag)
         CurKeelOverZag = 0.0;
      else {
         LastKeelOverZag = CurKeelOverZag;
         if ((CurKeelOverZag - high[Shift]) > LimitPoints)
            CurKeelOverZag = 0.0;
         else {
            // ¬¯¬Ñ ¬Ú¬ß¬ä¬Ö¬â¬Ó¬Ñ¬Ý¬Ö Backstep ¬Þ¬à¬Ø¬Ö¬ä ¬Ò¬í¬ä¬î ¬ä¬à¬Ý¬î¬Ü¬à ¬à¬Õ¬Ú¬ß ¬©¬Ñ¬Ô,
            // ¬Ò¬à¬Ý¬Ö¬Ö ¬â¬Ñ¬ß¬ß¬Ú¬Ö ¬å¬Ò¬Ú¬â¬Ñ¬Ö¬Þ
            for (Back = 1; Back <= Backstep; Back++) {
               Something = KeelOverZagBuffer[Shift + Back];
               if ((Something != 0) && (Something < CurKeelOverZag))
                  KeelOverZagBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // ¬£¬ã¬Ö, ¬é¬ä¬à ¬ß¬Ñ¬ê¬Ý¬Ú ¬Ú¬Ý¬Ú ¬ß¬Ö ¬ß¬Ñ¬ê¬Ý¬Ú - ¬Ü¬Ý¬Ñ¬Õ¬Ö¬Þ ¬Ó ¬Ò¬å¬æ¬Ö¬â¬Ñ ¬â¬Ñ¬Ù¬Ó¬à¬â¬à¬ä¬à¬Ó
      KeelOverZigAndZagSECTION[Shift] = CurKeelOverZig;
      KeelOverZagBuffer[Shift] = CurKeelOverZag;
   }
   return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void The_Second_Crusade() {
   // ¬±¬â¬à¬ã¬ä¬à ¬á¬à¬Õ¬é¬Ú¬ã¬ä¬Ü¬Ñ ¬Ý¬Ú¬ê¬ß¬Ö¬Ô¬à
   for (Shift = CountBar; Shift > 0; Shift--) {
      CurSlalomZig = SlalomZigBuffer[Shift];
      CurSlalomZag = SlalomZagBuffer[Shift];
      if ((CurSlalomZig == 0) && (CurSlalomZag == 0))
         continue;
      if (CurSlalomZag != 0) {
         if (LastSlalomZag > 0) {
            if (LastSlalomZag < CurSlalomZag)
               SlalomZagBuffer[LastSlalomZagPos] = 0;
            else
               SlalomZagBuffer[Shift] = 0;
         }
         if (LastSlalomZag < CurSlalomZag || LastSlalomZag < 0) {
            LastSlalomZag = CurSlalomZag;
            LastSlalomZagPos = Shift;
         }
         LastSlalomZig = -1;
      }
      if (CurSlalomZig != 0) {
         if (LastSlalomZig > 0) {
            if (LastSlalomZig > CurSlalomZig)
               SlalomZigBuffer[LastSlalomZigPos] = 0;
            else
               SlalomZigBuffer[Shift] = 0;
         }
         if ((CurSlalomZig < LastSlalomZig) || (LastSlalomZig < 0)) {
            LastSlalomZig = CurSlalomZig;
            LastSlalomZigPos = Shift;
         }
         LastSlalomZag = -1;
      }
      CurKeelOverZig = KeelOverZigAndZagSECTION[Shift];
      CurKeelOverZag = KeelOverZagBuffer[Shift];
      if ((CurKeelOverZig == 0) && (CurKeelOverZag == 0))
         continue;
      if (CurKeelOverZag != 0) {
         if (LastKeelOverZag > 0) {
            if (LastKeelOverZag < CurKeelOverZag)
               KeelOverZagBuffer[LastKeelOverZagPos] = 0;
            else
               KeelOverZagBuffer[Shift] = 0.0;
         }
         if (LastKeelOverZag < CurKeelOverZag || LastKeelOverZag < 0) {
            LastKeelOverZag = CurKeelOverZag;
            LastKeelOverZagPos = Shift;
         }
         LastKeelOverZig = -1;
      }
      if (CurKeelOverZig != 0) {
         if (LastKeelOverZig > 0) {
            if (LastKeelOverZig > CurSlalomZig)
               KeelOverZigAndZagSECTION[LastKeelOverZigPos] = 0;
            else
               KeelOverZigAndZagSECTION[Shift] = 0;
         }
         if ((CurKeelOverZig < LastKeelOverZig) || (LastKeelOverZig < 0)) {
            LastKeelOverZig = CurKeelOverZig;
            LastKeelOverZigPos = Shift;
         }
         LastKeelOverZag = -1;
      }
   }
   return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void The_Third_Crusade() {

   bool first = true;
   for (Shift = CountBar; Shift > 0; Shift--) {
      // ¬¯¬Ú¬Ù¬Ó¬Ö¬Ô¬Ñ¬Ö¬Þ ¬á¬â¬Ö¬Ø¬ß¬Ú¬ç ¬á¬â¬à¬â¬à¬Ü¬à¬Ó
      LimitOrdersBuffer[Shift] = 0.0;
      BuyOrdersBuffer[Shift] = 0.0;
      SellOrdersBuffer[Shift] = 0.0;
      // ¬©¬Ñ¬Õ¬Ñ¬Ö¬Þ ¬è¬Ö¬ß¬ä¬â ¬Þ¬Ú¬â¬à¬Ù¬Õ¬Ñ¬ß¬î¬ñ ¬Ú¬ß¬ä¬Ö¬â¬Ó¬Ñ¬Ý¬Ñ Shift (¬á¬à ¬Ý¬ð¬Ò¬à¬Þ¬å -
      // ¬ã¬á¬à¬ã¬à¬Ò ¬Ò¬à¬Ý¬î¬ê¬à¬Ô¬à ¬á¬à¬Ý¬Ú¬ä¬Ú¬é¬Ö¬ã¬Ü¬à¬Ô¬à ¬Ó¬Ö¬ã¬Ñ ¬ß¬Ö ¬Ú¬Þ¬Ö¬Ö¬ä)
      Navel =
          (5 * Close[Shift] + 2 * Open[Shift] + High[Shift] + Low[Shift]) / 9;
      // ¬¦¬ã¬Ý¬Ú ¬à¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î - ¬ã¬Þ¬à¬ä¬â¬Ú¬Þ,
      // ¬Ü¬å¬Õ¬Ñ (¬Þ¬à¬Ø¬Ö¬ä ¬Ò¬í¬ä¬î) ¬Õ¬Ñ¬Ý¬î¬ê¬Ö ¬ã¬Ö¬Û¬Þ¬à¬Þ¬Ö¬ß¬ä¬ß¬à ¬á¬à¬Û¬Õ¬Ö¬Þ: ¬Ó¬Ó¬Ö¬â¬ç ¬Ú¬Ý¬Ú ¬Ó¬ß¬Ú¬Ù
      if (KeelOverZigAndZagSECTION[Shift] != 0.0) {
         TrendUp = true;
         first = false;
      }
      if (KeelOverZagBuffer[Shift] != 0.0) {
         TrendUp = false;
         first = false;
      }
      // ¬³¬à¬Ò¬Ú¬â¬Ñ¬Ö¬Þ ¬Ó KeelOverZigAndZagSECTION ¬Ú ¬°¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î¬©¬Ú¬Ô¬Ú, ¬Ú ¬°¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î¬©¬Ñ¬Ô¬Ú,
      // ¬Ú ¬á¬å¬ã¬ä¬í¬ê¬Ü¬Ú - ¬Ó¬ã¬Ö ¬Ó ¬à¬Õ¬ß¬å ¬Ü¬å¬é¬Ü¬å, ¬ä¬Ñ¬Ü¬Ú¬Þ ¬à¬Ò¬â¬Ñ¬Ù¬à¬Þ ¬á¬à¬Ý¬å¬é¬Ñ¬Ö¬Þ ¬Õ¬à¬Ý¬Ô¬à¬Ú¬Ô¬â¬Ñ¬ð¬ë¬Ú¬Û
      // ZigAndZag, ¬ß¬Ñ¬ä¬ñ¬Ô¬Ú¬Ó¬Ñ¬ñ ¬ß¬Ú¬ä¬î "¬ä¬â¬Ö¬ß¬Õ¬Ñ" ¬ß¬Ñ ¬á¬å¬á¬Ü¬Ú ¬â¬Ñ¬Ù¬Ó¬à¬â¬à¬ä¬ß¬í¬ç ¬ã¬Ó¬Ö¬é¬Ö¬Ü
      if (KeelOverZagBuffer[Shift] != 0.0 ||
          KeelOverZigAndZagSECTION[Shift] != 0.0) {
         KeelOverZigAndZagSECTION[Shift] = Navel;
      } else
         KeelOverZigAndZagSECTION[Shift] = 0.0;
      // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ Shift ¬ß¬Ñ ¬ß¬Ñ¬Ý¬Ú¬é¬Ú¬Ö ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ú¬Ô¬Ñ ¬Ú¬Ý¬Ú ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ñ¬Ô¬Ñ
      if (SlalomZigBuffer[Shift] != 0.0) {
         LastZigOrZag = "Zig";
         LastSlalomZig = Navel;
         SetBuyOrder = false;
         SetLimitOrder = false;
         SetSellOrder = false;
      }
      if (SlalomZagBuffer[Shift] != 0.0) {
         LastZigOrZag = "Zag";
         LastSlalomZag = Navel;
         SetBuyOrder = false;
         SetLimitOrder = false;
         SetSellOrder = false;
      }
      // ¬Ú, ¬Ö¬ã¬Ý¬Ú ¬ß¬Ú ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ú¬Ô¬Ñ, ¬ß¬Ú ¬³¬Ý¬Ñ¬Ý¬à¬Þ¬©¬Ñ¬Ô¬Ñ ¬å¬Ø¬Ö ¬ß¬Ö¬ä,
      // ¬Ñ ¬à¬Ó¬Ö¬â¬Ü¬Ú¬Ý¬î ¬å¬Ø¬Ö ¬Ò¬í¬Ý - ¬ã¬Þ¬à¬ä¬â¬Ú¬Þ, ¬Ñ ¬é¬ä¬à ¬Ö¬ã¬ä¬î ¬á¬à ¬Ó¬ç¬à¬Õ¬å-¬Ó¬í¬ç¬à¬Õ¬å
      if (SlalomZigBuffer[Shift] == 0.0 && SlalomZagBuffer[Shift] == 0.0 &&
          first == false)
         Slalom_With_A_Scalpel();
   }
   return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Shift_Zerro() {

   Shift = 0;
   Navel = (5 * Close[0] + 2 * Open[0] + High[0] + Low[0]) / 9;
   Slalom_With_A_Scalpel();
   KeelOverZigAndZagSECTION[0] = Navel;
   return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Slalom_With_A_Scalpel() {
   // ¬±¬â¬à¬Ó¬Ö¬â¬ñ¬Ö¬Þ ¬ã¬å¬ë¬Ö¬ã¬ä¬Ó¬å¬ð¬ë¬Ú¬Û ¬ã¬Ú¬Ô¬ß¬Ñ¬Ý ¬ß¬Ñ ¬Ú¬Þ¬Ö¬Ö¬ä ¬á¬â¬Ñ¬Ó¬à ¬Ò¬í¬ä¬î
   // ¬Ú¬Ý¬Ú ¬ß¬Ñ ¬Ö¬ã¬Ý¬Ú ¬ß¬Ö ¬ã¬ä¬à¬Ú¬ä, ¬Ñ ¬ç¬à¬ä¬Ö¬Ý¬à¬ã¬î ¬Ò¬í:
   // ¬Ö¬ã¬Ý¬Ú ¬ç¬à¬Õ ¬é¬Ú¬ã¬ä¬à ¬Ü¬à¬ß¬Ü¬â¬Ö¬ä¬ß¬à ¬á¬à ¬Ø¬Ú¬Ù¬ß¬Ú - ¬Ù¬Ñ¬Ò¬Ú¬Ó¬Ñ¬Ö¬Þ ¬³¬ä¬â¬Ö¬Ý¬Ü¬å ¬ß¬Ñ ¬Õ¬Ö¬ß¬î¬Ô¬Ú,
   // ¬Ö¬ã¬Ý¬Ú ¬á¬â¬à¬ä¬Ú¬Ó - ¬ã¬ä¬Ñ¬Ó¬Ú¬Þ ¬ß¬Ñ ¬ê¬å¬ç¬Ö¬â ¬º¬Ñ¬â¬Ú¬Ü¬Ñ ¬¥¬Ö¬Ý¬Ñ¬Û-¬¯¬à¬Ô¬Ú
   if (LastZigOrZag == "Zig") {
      if (TrendUp == true) {
         if ((Navel - LastSlalomZig) >= LimitPoints && SetBuyOrder == false) {
            SetBuyOrder = true;
            BuyOrdersBuffer[Shift] = Low[Shift + 1];
            LastSlalomZigPos = Shift;
         }
         if (Navel <= LastSlalomZig && SetBuyOrder == true) {
            SetBuyOrder = false;
            BuyOrdersBuffer[LastSlalomZigPos] = 0.0;
            LastSlalomZigPos = -1;
         }
      }
      if (TrendUp == false) {
         if (Navel > LastSlalomZig && SetLimitOrder == false) {
            SetLimitOrder = true;
            LimitOrdersBuffer[Shift] = Navel;
            //            LimitOrdersBuffer[Shift]=Close[Shift];
            LastSlalomZigPos = Shift;
         }
         if (Navel <= LastSlalomZig && SetLimitOrder == true) {
            SetLimitOrder = false;
            LimitOrdersBuffer[LastSlalomZigPos] = 0.0;
            LastSlalomZigPos = -1;
         }
      }
   }
   if (LastZigOrZag == "Zag") {
      if (TrendUp == false) {
         if ((LastSlalomZag - Navel) >= LimitPoints && SetSellOrder == false) {
            SetSellOrder = true;
            SellOrdersBuffer[Shift] = High[Shift + 1];
            LastSlalomZagPos = Shift;
         }
         if (Navel >= LastSlalomZag && SetSellOrder == true) {
            SetSellOrder = false;
            SellOrdersBuffer[LastSlalomZagPos] = 0.0;
            LastSlalomZagPos = -1;
         }
      }
      if (TrendUp == true) {
         if (LastSlalomZag > Navel && SetLimitOrder == false) {
            SetLimitOrder = true;
            LimitOrdersBuffer[Shift] = Navel;
            //            LimitOrdersBuffer[Shift]=Close[Shift];
            LastSlalomZagPos = Shift;
         }
         if (Navel >= LastSlalomZag && SetLimitOrder == true) {
            SetLimitOrder = false;
            LimitOrdersBuffer[LastSlalomZagPos] = 0.0;
            LastSlalomZagPos = -1;
         }
      }
   }
   return;
}

//+--¬³¬à¬Ò¬ã¬ä¬Ó¬Ö¬ß¬ß¬à, ¬ñ ¬Ó¬ã¬Ö ¬ã¬Ü¬Ñ¬Ù¬Ñ¬Ý. ¬©¬Ñ¬Ò¬Ñ¬Ó¬ß¬à, ¬Ö¬ã¬Ý¬Ú ¬Ó¬ã¬Ö ¬ï¬ä¬à ¬â¬Ñ¬Ò¬à¬ä¬Ñ¬ä¬î ¬Ò¬å¬Õ¬Ö¬ä--+
//+------------------------------------------------------------------+
