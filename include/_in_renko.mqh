
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#ifndef equal(a, b)
   #define equal(a, b) (fabs((a) - (b)) < 0.000000001)
#endif

class classRenko {
 private:
   double step, size, high, low;
   int    digits, direction;

   bool compare(double number1, double number2, bool plus) {
      if (plus)
         return (number1 < number2 || equal(number1, number2));
      return (number1 > number2 || equal(number1, number2));
   }

 public:
   classRenko(double _step = 0.05, double _size = 20.0, int _digits = 2) {
      step      = _step;
      size      = NormalizeDouble(_step * _size, _digits);
      digits    = _digits;
      low       = iLow(NULL, PERIOD_CURRENT, iBars(NULL, PERIOD_CURRENT) - 1);
      low       = NormalizeDouble(floor(low / size) * size, _digits);
      high      = NormalizeDouble(low + size, _digits);
      direction = 1;
   }

   ~classRenko() {}

   int Renko(double hi, double lo, double bid, bool current) {
      // if (0 < direction) {
      if ((high + low) * 0.5 < (hi + lo + bid) / 3.0) {
         if (compare(high + step, current ? bid : hi, true)) {
            do {
               high = NormalizeDouble(high + step, digits);
               low  = NormalizeDouble(low  + step, digits);
               direction = 1;
            } while (compare(high + step, current ? bid : hi, true));
         } // reversal
         else if (compare(low - step, current ? bid : lo, false)) {
            do {
               high = NormalizeDouble(high - step, digits);
               low  = NormalizeDouble(low  - step, digits);
               direction = -1;
            } while (compare(low - step, current ? bid : lo, false));
         }
      } else {
         if (compare(low - step, current ? bid : lo, false)) {
            do {
               high = NormalizeDouble(high - step, digits);
               low  = NormalizeDouble(low  - step, digits);
               direction = -1;
            } while (compare(low - step, current ? bid : lo, false));
         } // reversal
         else if (compare(high + step, current ? bid : hi, true)) {
            do {
               high = NormalizeDouble(high + step, digits);
               low  = NormalizeDouble(low  + step, digits);
               direction = 1;
            } while (compare(high + step, current ? bid : hi, true));
         }
      }
      return (direction);
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
