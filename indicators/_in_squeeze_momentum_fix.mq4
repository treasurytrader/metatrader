
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_separate_window

#property indicator_buffers 6

#property indicator_color1 clrDimGray
#property indicator_color2 C'50,50,50'
#property indicator_color3 clrDimGray
#property indicator_color4 C'50,50,50'
#property indicator_color5 clrDimGray
#property indicator_color6 C'50,50,50'
/*
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input int period = 20;

double On[], Off[], linregsrc[];
double upup[], updn[], dndn[], dnup[], linreg[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnInit()
  {
    IndicatorBuffers(8);

    SetIndexBuffer(0, upup);
    SetIndexBuffer(1, updn);
    SetIndexBuffer(2, dndn);
    SetIndexBuffer(3, dnup);
    SetIndexBuffer(4, On);
    SetIndexBuffer(5, Off);
    SetIndexBuffer(6, linregsrc);
    SetIndexBuffer(7, linreg);

    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexStyle(2, DRAW_HISTOGRAM);
    SetIndexStyle(3, DRAW_HISTOGRAM);
    SetIndexStyle(4, DRAW_ARROW);
    SetIndexStyle(5, DRAW_ARROW);
    SetIndexStyle(6, DRAW_NONE);
    SetIndexStyle(7, DRAW_NONE);

    SetIndexArrow(4, 167);
    SetIndexArrow(5, 167);

    SetIndexLabel(0, "upup (1)");
    SetIndexLabel(1, "updn (2)");
    SetIndexLabel(2, "dndn (3)");
    SetIndexLabel(3, "dnup (4)");
    SetIndexLabel(4, "sqzOn (5)");
    SetIndexLabel(5, "sqzOff (6)");

    IndicatorSetString(INDICATOR_SHORTNAME, "\0"/*MQLInfoString(MQL_PROGRAM_NAME)*/);

    return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
  {
    if (!prev_calculated)
      {
        int length = rates_total - period;
        for (int i = rates_total - 1; length <= i; i--)
          {
            double hi = high[iHighest(NULL, 0, MODE_HIGH, rates_total - i, i)];
            double lo = low [ iLowest(NULL, 0,  MODE_LOW, rates_total - i, i)];
            double ma = iMA(NULL, 0, rates_total - i, 0, MODE_SMA, PRICE_CLOSE, i);

            linregsrc[i] = close[i] - ((((hi + lo) / 2.0) + ma) / 2.0);
          }
      }

    for (int i = rates_total - (prev_calculated ? prev_calculated : period + 1); 0 <= i; i--)
      {
        double dev = iStdDev(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);
        double atr = iATR(NULL, PERIOD_CURRENT, period, i);
        bool   sqz = (atr > dev);

        On[i]  = !sqz ? 0 : EMPTY_VALUE;
        Off[i] =  sqz ? 0 : EMPTY_VALUE;

        double hi = high[iHighest(NULL, 0, MODE_HIGH, period, i)];
        double lo = low [ iLowest(NULL, 0,  MODE_LOW, period, i)];
        double ma = iMA(NULL, 0, period, 0, MODE_SMA, PRICE_CLOSE, i);

        linregsrc[i] = close[i] - ((((hi + lo) / 2.0) + ma) / 2.0);
        linreg[i]    = linreg(linregsrc, period, i);

        upup[i] = linreg[i] > 0 && linreg[i] >= nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        updn[i] = linreg[i] > 0 && linreg[i] <  nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        dndn[i] = linreg[i] < 0 && linreg[i] <= nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
        dnup[i] = linreg[i] < 0 && linreg[i] >  nz(linreg[i+1]) ? linreg[i] : EMPTY_VALUE;
      }

    return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double linreg(double &src[], int p, int i)
  {
    double Ey  = 0;
    double Exy = 0;
    double c;

    for (int x = 0; x <= p - 1; x++)
      {
        c    = src[x + i];
        Ey  += c;
        Exy += x * c;
      }

    double Ex   = p * (p - 1) * 0.5;
    double Ex2  = (p - 1) * p * (2 * p - 1) / 6;
    double Sum2 = Ex * Ey;
    double q1 = p * Exy - Sum2;
    double q2 = Ex * Ex - p * Ex2;

    double slope = q2 != 0 ? q1 / q2 : 0;

    double intercept = (Ey - slope * Ex) / p;
    double linregval = intercept + slope * (p - 1);

    return (linregval);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double nz(double check, double val = 0)
  {
    return (check == EMPTY_VALUE ? val : check);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
