
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_color1 clrSlateGray
#property indicator_width1 1
#property indicator_type1  DRAW_LINE

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 81;

double buffer[];
int    handle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit(void) {

   SetIndexBuffer(0, buffer, INDICATOR_DATA);
   // ArraySetAsSeries(buffer, true);

   handle = iMA(NULL, 0, period, 0, MODE_EMA, PRICE_CLOSE);

   return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason) {

   if (handle != INVALID_HANDLE) IndicatorRelease(handle);
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
   // ArraySetAsSeries(high, true);
   // ArraySetAsSeries(low,  true);

   int to_copy = rates_total - (prev_calculated ? prev_calculated - 1 : 0);

   if (CopyBuffer(handle, 0, 0, to_copy, buffer) <= 0) {
      Print("Getting EMA is failed! Error ", GetLastError());
      return (0);
   }

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

