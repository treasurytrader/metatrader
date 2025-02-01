
//+------------------------------------------------------------------+
//|                                             ZigAndZagScalpel.mq4 |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+

#property copyright ""
#property link      ""

//----

#property strict
#property indicator_chart_window

#property indicator_buffers 4 // ���ݬ� 8 - �լݬ� testBuffer

#property indicator_color1 clrFireBrick
#property indicator_color2 clrWhite
#property indicator_color3 clrRed
#property indicator_color4 clrRed
//#property indicator_color8 White // ���ݬ� ���լҬ��� ��֬Ԭ�-�߬ڬҬ�լ�

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern int KeelOver = 55; // ���ݬ� M15 : 55
extern int Slalom   = 17; // ���ݬ� M15 : 17

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
   SetIndexStyle(0, DRAW_SECTION/*, STYLE_DOT*/); // DRAW_SECTION �ڬݬ� DRAW_NONE
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
   if (CountBar <= 3 * KeelOver) return (-1); // ���Ѭݬ�ӬѬ�� �Ҭ�լ֬�
   if (KeelOver <= 2 * Slalom)   return (-1); // ����Ѭ�֬ݬ�߬֬� �߬Ѭլ�

   // ���Ѭ�ڬ��ܬ� �߬֬��ѬӬڬݬ�߬�� �ڬ����ڬ�
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

   //+---���֬�Ӭ�� ������ ��� �ڬ����ڬ�----------------------------------------+
   The_First_Crusade(high, low);

   //+---�������� ������� ��� �ڬ����ڬ�֬�ܬڬ� �ެ֬��Ѭ�---------------------------+
   //+---�� ��֬ݬ�� ���լ�ڬ��ܬ� �߬֬Ӭ֬�߬� ���߬���� ���Ҭ��ڬ�----------------------+
   LastKeelOverZig    = -1;
   LastKeelOverZigPos = -1;
   LastKeelOverZag    = -1;
   LastKeelOverZagPos = -1;
   LastSlalomZig      = -1;
   LastSlalomZigPos   = -1;
   LastSlalomZag      = -1;
   LastSlalomZagPos   = -1;
   The_Second_Crusade();

   //+---����֬�ڬ� �ڬ����ڬ�֬�ܬڬ� ��ܬ�ܬ��� - �������֬߬ڬ� "���֬߬լ�"--------------+
   //+---�� ��Ѭ���Ѭ߬�Ӭܬ� "����Ԭ�Ӭ�� ��ڬԬ߬Ѭݬ��"------------------------------+
   LastSlalomZig    = -1;
   LastSlalomZigPos = -1;
   LastSlalomZag    = -1;
   LastSlalomZagPos = -1;
   LastZigOrZag     = "None";
   The_Third_Crusade();

   //+---�� ��֬Ԭ� �ެ� ��֬�֬�� �Ҭ�լ֬� �ڬެ֬�� �٬լ֬�� �� ��֬۬�Ѭ�?-------------------+
   Shift_Zerro();

   return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void The_First_Crusade(const double &high[], const double &low[]) {
   for (Shift = CountBar; Shift > 0; Shift--) {
      // ����ڬ�� ����֬� "�Ӭ��Ѭ� �� ���٬�" - "���֬� �� ���߬ܬ�"
      CurSlalomZig = low[Lowest(NULL, 0, MODE_LOW, Slalom, Shift)];
      CurSlalomZag = high[Highest(NULL, 0, MODE_HIGH, Slalom, Shift)];
      // �����Ӭ֬��֬� Shift �߬� �߬Ѭݬڬ�ڬ� ���֬�֬լ߬�Ԭ� ���ݬѬݬ�ެ��ڬԬ� �լݬ� �Ӭ��լ�
      // �� ���ܬ��ܬ� �ڬݬ� �լݬ� �Ӭ���լ� �ڬ� ����լѬج�
      if (CurSlalomZig == LastSlalomZig)
         CurSlalomZig = 0.0;
      else {
         LastSlalomZig = CurSlalomZig;
         if ((low[Shift] - CurSlalomZig) > LimitPoints)
            CurSlalomZig = 0.0;
         else {
            // ���� �ڬ߬�֬�ӬѬݬ� Backstep �ެ�ج֬� �Ҭ��� ���ݬ�ܬ� ��լڬ� ���ڬ�,
            // ����ѬӬݬ�֬� ���ݬ�ܬ� ����ݬ֬լ߬ڬ�, �Ҭ�ݬ֬� ��Ѭ߬߬ڬ� ��Ҭڬ�Ѭ֬�
            for (Back = 1; Back <= Backstep; Back++) {
               Something = SlalomZigBuffer[Shift + Back];
               if ((Something != 0) && (Something > CurSlalomZig))
                  SlalomZigBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // �����Ӭ֬��֬� Shift �߬� �߬Ѭݬڬ�ڬ� ���֬�֬լ߬�Ԭ� ���ݬѬݬ�ެ��ѬԬ� �լݬ� �Ӭ��լ� �Ӭ߬ڬ�
      // �ڬݬ� �լݬ� �Ӭ���լ� �ڬ� ���ܬ��ܬ�
      if (CurSlalomZag == LastSlalomZag)
         CurSlalomZag = 0.0;
      else {
         LastSlalomZag = CurSlalomZag;
         if ((CurSlalomZag - high[Shift]) > LimitPoints)
            CurSlalomZag = 0.0;
         else {
            // ���� �ڬ߬�֬�ӬѬݬ� Backstep �ެ�ج֬� �Ҭ��� ���ݬ�ܬ� ��լڬ� ���Ѭ�,
            // ����ѬӬݬ�֬� ���ݬ�ܬ� ����ݬ֬լ߬ڬ�, �Ҭ�ݬ֬� ��Ѭ߬߬ڬ� ��Ҭڬ�Ѭ֬�
            for (Back = 1; Back <= Backstep; Back++) {
               Something = SlalomZagBuffer[Shift + Back];
               if ((Something != 0) && (Something < CurSlalomZag))
                  SlalomZagBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // �����, ���� �߬Ѭ�ݬ� �߬�Ӭ֬߬�ܬ�Ԭ� �� �������ܬ� - �ܬݬѬլ֬� �� �Ҭ��֬�� ��ݬѬݬ�ެ�
      SlalomZigBuffer[Shift] = CurSlalomZig;
      SlalomZagBuffer[Shift] = CurSlalomZag;
      // ����֬� ����ܬ� ��Ѭ٬Ӭ����� �լݬ� �������֬߬ڬ� "�ݬڬ߬֬۬߬�Ԭ� ���֬߬լ�", ���� �����
      // �� �Ҭ��֬� ��Ѭ٬Ӭ������ ZigAndZag ���ܬ� ���� �Ҭ�լ֬� �ܬݬѬ��� ���ݬ�ܬ� ���Ӭ֬�ܬڬݬ�ڬԬ�
      CurKeelOverZig = low[Lowest(NULL, 0, MODE_LOW, KeelOver, Shift)];
      CurKeelOverZag = high[Highest(NULL, 0, MODE_HIGH, KeelOver, Shift)];
      // �����Ӭ֬��֬� Shift �߬� �߬Ѭݬڬ�ڬ� ���֬�֬լ߬�Ԭ� ���Ӭ֬�ܬڬݬ�ڬԬ�
      if (CurKeelOverZig == LastKeelOverZig)
         CurKeelOverZig = 0.0;
      else {
         LastKeelOverZig = CurKeelOverZig;
         if ((low[Shift] - CurKeelOverZig) > LimitPoints)
            CurKeelOverZig = 0.0;
         else {
            // ���� �ڬ߬�֬�ӬѬݬ� Backstep �ެ�ج֬� �Ҭ��� ���ݬ�ܬ� ��լڬ� ���ڬ�,
            // ����ѬӬݬ�֬� ���ݬ�ܬ� ����ݬ֬լ߬ڬ�, �Ҭ�ݬ֬� ��Ѭ߬߬ڬ� ��Ҭڬ�Ѭ֬�
            for (Back = 1; Back <= Backstep; Back++) {
               Something = KeelOverZigAndZagSECTION[Shift + Back];
               if ((Something != 0) && (Something > CurKeelOverZig))
                  KeelOverZigAndZagSECTION[Shift + Back] = 0.0;
            }
         }
      }
      // �����Ӭ֬��֬� Shift �߬� �߬Ѭݬڬ�ڬ� ���֬�֬լ߬�Ԭ� ���Ӭ֬�ܬڬݬ�ѬԬ�
      if (CurKeelOverZag == LastKeelOverZag)
         CurKeelOverZag = 0.0;
      else {
         LastKeelOverZag = CurKeelOverZag;
         if ((CurKeelOverZag - high[Shift]) > LimitPoints)
            CurKeelOverZag = 0.0;
         else {
            // ���� �ڬ߬�֬�ӬѬݬ� Backstep �ެ�ج֬� �Ҭ��� ���ݬ�ܬ� ��լڬ� ���Ѭ�,
            // �Ҭ�ݬ֬� ��Ѭ߬߬ڬ� ��Ҭڬ�Ѭ֬�
            for (Back = 1; Back <= Backstep; Back++) {
               Something = KeelOverZagBuffer[Shift + Back];
               if ((Something != 0) && (Something < CurKeelOverZag))
                  KeelOverZagBuffer[Shift + Back] = 0.0;
            }
         }
      }
      // �����, ���� �߬Ѭ�ݬ� �ڬݬ� �߬� �߬Ѭ�ݬ� - �ܬݬѬլ֬� �� �Ҭ��֬�� ��Ѭ٬Ӭ������
      KeelOverZigAndZagSECTION[Shift] = CurKeelOverZig;
      KeelOverZagBuffer[Shift] = CurKeelOverZag;
   }
   return;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void The_Second_Crusade() {
   // �������� ���լ�ڬ��ܬ� �ݬڬ�߬֬Ԭ�
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
      // ���ڬ٬Ӭ֬ԬѬ֬� ���֬ج߬ڬ� ������ܬ��
      LimitOrdersBuffer[Shift] = 0.0;
      BuyOrdersBuffer[Shift] = 0.0;
      SellOrdersBuffer[Shift] = 0.0;
      // ���ѬլѬ֬� ��֬߬�� �ެڬ��٬լѬ߬�� �ڬ߬�֬�ӬѬݬ� Shift (��� �ݬ�Ҭ�ެ� -
      // ������� �Ҭ�ݬ���Ԭ� ���ݬڬ�ڬ�֬�ܬ�Ԭ� �Ӭ֬�� �߬� �ڬެ֬֬�)
      Navel =
          (5 * Close[Shift] + 2 * Open[Shift] + High[Shift] + Low[Shift]) / 9;
      // ����ݬ� ��Ӭ֬�ܬڬݬ� - ��ެ���ڬ�,
      // �ܬ�լ� (�ެ�ج֬� �Ҭ���) �լѬݬ��� ��֬۬ެ�ެ֬߬�߬� ���۬լ֬�: �ӬӬ֬�� �ڬݬ� �Ӭ߬ڬ�
      if (KeelOverZigAndZagSECTION[Shift] != 0.0) {
         TrendUp = true;
         first = false;
      }
      if (KeelOverZagBuffer[Shift] != 0.0) {
         TrendUp = false;
         first = false;
      }
      // ����Ҭڬ�Ѭ֬� �� KeelOverZigAndZagSECTION �� ���Ӭ֬�ܬڬݬ�ڬԬ�, �� ���Ӭ֬�ܬڬݬ�ѬԬ�,
      // �� �������ܬ� - �Ӭ�� �� ��լ߬� �ܬ��ܬ�, ��Ѭܬڬ� ��Ҭ�Ѭ٬�� ���ݬ��Ѭ֬� �լ�ݬԬ�ڬԬ�Ѭ��ڬ�
      // ZigAndZag, �߬Ѭ��ԬڬӬѬ� �߬ڬ�� "���֬߬լ�" �߬� ����ܬ� ��Ѭ٬Ӭ����߬�� ��Ӭ֬�֬�
      if (KeelOverZagBuffer[Shift] != 0.0 ||
          KeelOverZigAndZagSECTION[Shift] != 0.0) {
         KeelOverZigAndZagSECTION[Shift] = Navel;
      } else
         KeelOverZigAndZagSECTION[Shift] = 0.0;
      // �����Ӭ֬��֬� Shift �߬� �߬Ѭݬڬ�ڬ� ���ݬѬݬ�ެ��ڬԬ� �ڬݬ� ���ݬѬݬ�ެ��ѬԬ�
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
      // ��, �֬�ݬ� �߬� ���ݬѬݬ�ެ��ڬԬ�, �߬� ���ݬѬݬ�ެ��ѬԬ� ��ج� �߬֬�,
      // �� ��Ӭ֬�ܬڬݬ� ��ج� �Ҭ�� - ��ެ���ڬ�, �� ���� �֬��� ��� �Ӭ��լ�-�Ӭ���լ�
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
   // �����Ӭ֬��֬� ����֬��Ӭ���ڬ� ��ڬԬ߬Ѭ� �߬� �ڬެ֬֬� ���ѬӬ� �Ҭ���
   // �ڬݬ� �߬� �֬�ݬ� �߬� ����ڬ�, �� ����֬ݬ��� �Ҭ�:
   // �֬�ݬ� ���� ��ڬ��� �ܬ�߬ܬ�֬�߬� ��� �جڬ٬߬� - �٬ѬҬڬӬѬ֬� �����֬ݬܬ� �߬� �լ֬߬�Ԭ�,
   // �֬�ݬ� �����ڬ� - ���ѬӬڬ� �߬� ����֬� ���Ѭ�ڬܬ� ���֬ݬѬ�-����Ԭ�
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

//+--����Ҭ��Ӭ֬߬߬�, �� �Ӭ�� ��ܬѬ٬Ѭ�. ���ѬҬѬӬ߬�, �֬�ݬ� �Ӭ�� ���� ��ѬҬ��Ѭ�� �Ҭ�լ֬�--+
//+------------------------------------------------------------------+
