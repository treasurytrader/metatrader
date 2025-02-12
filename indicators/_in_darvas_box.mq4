//+------------------------------------------------------------------+
//|                                                 Darvas Boxes.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
//----
double     ind_buffer1[];
double     ind_buffer2[];
//----
bool allow_buy;
bool allow_sell;
double price;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0, ind_buffer1);
   //
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,2);
   SetIndexBuffer(1, ind_buffer2);
   //
   allow_buy=true;
   allow_sell=false;
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
   double box_top=0;
   double box_bottom=0;
   int state=1;
//----
   for(int i=Bars - 1; i > 0; i--)
     { /*
      if (state==1)
        {
         box_top=High[i];
        }
      else if (state==2)
           {
            if (box_top > High[i])
              {
              }
            else
              {
               box_top=High[i];
              }
           }
         else if (state==3)
              {
               if (box_top > High[i])
                 {
                  box_bottom=Low[i];
                 }
               else
                 {
                  box_top=High[i];
                 }
              }
            else if (state==4)
                 {
                  if (box_top > High[i])
                    {
                     if (box_bottom < Low[i])
                       {
                       }
                     else
                       {
                        box_bottom=Low[i];
                       }
                    }
                  else
                    {
                     box_top=High[i];
                    }
                 }
               else if (state==5)
                    {
                     if (box_top > High[i])
                       {
                        if (box_bottom < Low[i])
                          {
                          }
                        else
                          {
                           box_bottom=Low[i];
                          }
                       }
                     else
                       {
                        box_top=High[i];
                       }
                     state=0;
                    } */

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

      ind_buffer1[i]=box_top;
      ind_buffer2[i]=box_bottom;
      state++;
     }
   ind_buffer1[0]=EMPTY_VALUE;
   ind_buffer2[0]=EMPTY_VALUE;
//----
   return(0);
  }
//+------------------------------------------------------------------+----+