
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_color1 clrFireBrick

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 20;

double buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {
   //---
   IndicatorBuffers(1);
   SetIndexBuffer(0, buffer);
   return (INIT_SUCCEEDED);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {
   //---
   //---
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
   for (int i = rates_total - (prev_calculated ? prev_calculated : period); 0 <= i; i--) {
      buffer[i] = VWMA(close, tick_volume, period, i);
   }

   return (rates_total);
   //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// VWMA - Volume Weighted Moving Average

double VWMA(const double &price[], const long &volume[], int per, int bar) {
   double sum  = 0;
   double vwma = 0;
   long weight = 0;

   for (int i = 0; per > i; i++) {
      sum    += price[bar + i] * volume[bar + i];
      weight += volume[bar + i];
   }

   if (0 < weight) vwma = sum / weight;

   return (vwma);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
