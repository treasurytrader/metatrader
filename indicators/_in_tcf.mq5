
// https://www.mql5.com/ko/code/21267
//+------------------------------------------------------------------+
//|                                                          TCF.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Trend Continuation Factor oscillator"
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   2
//--- plot PTCF
#property indicator_label1  "Pos TCF"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot NTCF
#property indicator_label2  "Neg TCF"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint                 InpPeriodCP       =  1;             // ROC period
input uint                 InpPeriod         =  35;            // Smoothing period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferPTCF[];
double         BufferNTCF[];
double         BufferMA[];
double         BufferPC[];
double         BufferNC[];
double         BufferPCF[];
double         BufferNCF[];
double         BufferAvgPC[];
double         BufferAvgNC[];
double         BufferAvgPCF[];
double         BufferAvgNCF[];
//--- global variables
int            period_sm;
int            period_cp;
int            handle_ma;
//--- includes
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_sm=int(InpPeriod<2 ? 2 : InpPeriod);
   period_cp=int(InpPeriodCP<1 ? 1 : InpPeriodCP);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPTCF,INDICATOR_DATA);
   SetIndexBuffer(1,BufferNTCF,INDICATOR_DATA);
   SetIndexBuffer(2,BufferMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferPC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,BufferNC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,BufferPCF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,BufferNCF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,BufferAvgPC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,BufferAvgNC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,BufferAvgPCF,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferAvgNCF,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Continuation Factor ("+(string)period_cp+","+(string)period_sm+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferPTCF,true);
   ArraySetAsSeries(BufferNTCF,true);
   ArraySetAsSeries(BufferMA,true);
   ArraySetAsSeries(BufferPC,true);
   ArraySetAsSeries(BufferNC,true);
   ArraySetAsSeries(BufferPCF,true);
   ArraySetAsSeries(BufferNCF,true);
   ArraySetAsSeries(BufferAvgPC,true);
   ArraySetAsSeries(BufferAvgNC,true);
   ArraySetAsSeries(BufferAvgPCF,true);
   ArraySetAsSeries(BufferAvgNCF,true);
//--- create MA's handles
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Проверка и расчёт количества просчитываемых баров
   if(rates_total<4) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_cp-2;
      ArrayInitialize(BufferPTCF,EMPTY_VALUE);
      ArrayInitialize(BufferNTCF,EMPTY_VALUE);
      ArrayInitialize(BufferMA,0);
      ArrayInitialize(BufferPC,0);
      ArrayInitialize(BufferNC,0);
      ArrayInitialize(BufferPCF,0);
      ArrayInitialize(BufferNCF,0);
      ArrayInitialize(BufferAvgPC,0);
      ArrayInitialize(BufferAvgNC,0);
      ArrayInitialize(BufferAvgPCF,0);
      ArrayInitialize(BufferAvgNCF,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_ma,0,0,count,BufferMA);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double Pr_CP=BufferMA[i+period_cp];
      double ROC=(Pr_CP!=0 ? 100.0*(BufferMA[i]-Pr_CP)/Pr_CP : 0);

      if(ROC>0)
        {
         BufferPC[i]=ROC;
         BufferNC[i]=0;
         BufferPCF[i]=BufferPCF[i+1]+ROC;
         BufferNCF[i]=0;
        }
      else
        {
         BufferPC[i]=0.;
         BufferNC[i]=-ROC;
         BufferPCF[i]=0.;
         BufferNCF[i]=BufferNCF[i+1]-ROC;
        }
     }
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferPC,BufferAvgPC)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferNC,BufferAvgNC)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferPCF,BufferAvgPCF)==0)
      return 0;
   if(SimpleMAOnBuffer(rates_total,prev_calculated,0,period_sm,BufferNCF,BufferAvgNCF)==0)
      return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      double pc_sum=BufferAvgPC[i]+period_sm;
      double nc_sum=BufferAvgNC[i]+period_sm;
      double pcf_sum=BufferAvgPCF[i]+period_sm;
      double ncf_sum=BufferAvgNCF[i]+period_sm;

      BufferPTCF[i]=pc_sum-ncf_sum;
      BufferNTCF[i]=nc_sum-pcf_sum;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+