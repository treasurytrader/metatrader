//+------------------------------------------------------------------+
//|                                                   Darvas_Box.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Darvas Box indicator"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Box Top"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Box Bottom"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         BufferUP[];
double         BufferDN[];
double         BufferState[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferState,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Darvas Box");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUP,true);
   ArraySetAsSeries(BufferDN,true);
   ArraySetAsSeries(BufferState,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   //--- Проверка и расчёт количества просчитываемых баров
   if (rates_total < 4)
      return 0;
   //--- Проверка и расчёт количества просчитываемых баров
   int limit = rates_total - prev_calculated;
   if (limit > 1) {
      limit = rates_total - 2;
      ArrayInitialize(BufferUP, EMPTY_VALUE);
      ArrayInitialize(BufferDN, EMPTY_VALUE);
      ArrayInitialize(BufferState, 0);
      BufferState[limit] = 1;
   }

   //--- Расчёт индикатора
   for (int i = limit; i >= 0 && !IsStopped(); i--) {
      double box_top    = BufferUP[i + 1];
      double box_bottom = BufferDN[i + 1];
      int    state      = (int)BufferState[i + 1];

      switch (state) {

         case 1 : box_top = high[i];
            break;
         case 2 : if (box_top <= high[i]) box_top = high[i];
            break;
         case 3 : if (box_top > high[i]) box_bottom = low[i];
                  else box_top = high[i];
            break;
         case 4 : if (box_top > high[i]) {
                     if (box_bottom >= low[i]) box_bottom=low[i];
                  }
                  else box_top = high[i];
            break;
         case 5 : {
                     if (box_top > high[i]) {
                        if (box_bottom >= low[i]) box_bottom = low[i];
                     } else box_top = high[i];
                     state = 0;
                  }
      }

      state++;
      BufferState[i] = state;
      BufferUP[i] = box_top;
      BufferDN[i] = box_bottom;
/*
      if (state == 1)
         box_top = high[i];
      else {
         if (state == 2) {
            if (box_top <= high[i]) box_top = high[i];
         } else {
            if (state == 3) {
               if (box_top > high[i]) box_bottom = high[i];
               else box_top = high[i];
            } else {
               if (state == 4) {
                  if (box_top > high[i]) {
                     if (box_bottom >= low[i]) box_bottom = low[i];
                  } else box_top = high[i];
               } else {
                  if (box_top > high[i]) {
                     if (box_bottom >= low[i]) box_bottom = low[i];
                  } else box_top = high[i];
                  state = 0;
               }
            }
         }
      }
      state++;
      BufferState[i] = state;
      BufferUP[i] = box_top;
      BufferDN[i] = box_bottom;
      */
   }

   //--- return value of prev_calculated for next call
   return (rates_total);
}
//+------------------------------------------------------------------+