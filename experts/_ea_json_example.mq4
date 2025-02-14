//+------------------------------------------------------------------+
//|                             ZIWOX API and Technical Strategy.mq4 |
//|                                        Copyright 2024, ssabbaghi |
//|                          https://www.mql5.com/en/users/ssabbaghi |
//+------------------------------------------------------------------+
#property   copyright   "Sara Sabbaghi"
#property   link        "https://www.mql5.com/en/users/ssabbaghi"
#property   version     "1.0"
#property   strict

//---- input parameters
input    string      APIKey         =  "";      // Your unic API key
input    string      SymbolPrefix   =  "";      // Your Broker account symbol Prefix
input    string      SymbolSuffiex  =  "";      // Your Broker account symbol Suffiex
input    int         shortMAPeriod  =  50;      // Slow MA Period
input    int         longMAPeriod   =  200;     // Fast MA Period
input    double      Lots           =  0.01;    // Static Order volume


// #include    "JAson.mqh"  // include the JSON librery in our project
#include    <_json.mqh>  // include the JSON librery in our project
CJAVal JsonValue;

string   OBJPREFIX      =  "ZXAPI",
         SymbolRequest  =  "",
         APIJSON[];
bool     APIOK =  false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//----
   EventSetTimer(30);
   ArrayResize(APIJSON,6);
   SymbolRequest  =  PureSymbol(Symbol(),SymbolSuffiex,SymbolPrefix); // Prepair real symbol name is it has suffiex or prefix
   Comment("Wait a sec, to Get API data...");
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   ObjectsDeleteAll(0);
  }


//+------------------------------------------------------------------+
//| Expert tick function    OnTick()                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
   if (!APIOK) return;

   double   shortMA, longMA;
   long     ticket = -1;

   if(IsNewCandle())
     {
      shortMA  = iMA(Symbol(), 0, shortMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
      longMA   = iMA(Symbol(), 0, longMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);

      // Check for crossover signals
      if ( int(APIJSON[3])>=60 ) // if bullish forecast is higher than 60%
         if (shortMA > longMA)   // BUY trend
         {
            if (OrdersTotal() == 0) {
               ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, 0, 0, "Buy Order", 0, 0, Green);
               if (ticket < 0) Print("Error opening buy order: ", GetLastError());
            }
         }
      if ( int(APIJSON[4])>=60 ) // if bearish forecast is higher than 60%
         if (shortMA < longMA)   // Sell trend
         {
            if (OrdersTotal() == 0)
            {
               ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, 0, 0, "Sell Order", 0, 0, Red);
               if (ticket < 0) Print("Error opening sell order: ", GetLastError());
            }
         }
     }
  }
//+------------------------------------------------------------------+
//| Expert OnTimer function                                          |
//+------------------------------------------------------------------+

void OnTimer() {

   string APIfilename = "Q\\_ff_calendar_thisweek.json"; // API store file name
   APIOK = GetAPI(SymbolRequest, APIKey, APIfilename); // Get the API data and save it to  APIfilename
   if (APIOK)
      JsonDataParse(APIfilename, APIJSON); // read the JSON data and store them into the API_DATA array
   Comment((APIOK ? "API OK" : "API FAILED"),
           "\nAPI:\n",
           "\ntitle: ", APIJSON[0],
           "\ncountry: ", APIJSON[1],
           "\ndate: ", APIJSON[2],
           "\nimpact: ", APIJSON[3],
           "\nforecast: ", APIJSON[4],
           "\nprevious: ", APIJSON[5]);
}

//+------------------------------------------------------------------+
//| New candle check function                                        |
//+------------------------------------------------------------------+

datetime NewCandleTime = TimeCurrent();

bool IsNewCandle() {
   if (NewCandleTime == iTime(Symbol(), 0, 0))
      return false;
   else {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string PureSymbol(string symbol, string suffiex, string prefix) {
   string puresymbol = symbol;
   if (prefix != "" || suffiex != "") {
      StringReplace(symbol, suffiex, "");
      StringReplace(symbol, suffiex, "");
   }
   return (puresymbol);
}

//+------------------------------------------------------------------+
//|  Get Fund data from ziwox                                        |
//+------------------------------------------------------------------+

datetime LastWebRequest = 0; // use this datetime var for limit failed request API

bool GetAPI(string symbolname, string apikey, string filename) {
   Print("Get API Update");
   bool NeedToUpdate = false;

   // Check if the API data file available
   if (FileGetInteger(filename, FILE_EXISTS, true) >= 0) {
      // Check the latest update time from file modify date time
      if (TimeLocal() - (datetime)FileGetInteger(filename, FILE_MODIFY_DATE, true) >
          900) // update data every 15 min becasue of API call rate limitation
         NeedToUpdate = true;
   } else
      NeedToUpdate = true;

   if (NeedToUpdate && TimeLocal() - LastWebRequest >
                           300) // retry failed API request every 5 min to avoid firewall IP block
   {
      string cookie = NULL, headers;
      char post[], result[];
      int res;
      string URL = "https://nfs.faireconomy.media/ff_calendar_thisweek.json";
      ResetLastError();
      int timeout = 5000;
      res = WebRequest("GET", URL, cookie, NULL, timeout, post, 0, result, headers);
      if (res == -1) {
         LastWebRequest = TimeLocal();
         int error = GetLastError();
         if (error == 4060)
            Print("API data Webrequest Error ", error,
                  " Check your webrequest on Metatrader Expert option.");
         else if (error == 5203)
            Print("HTTP request for Data failed!");
         else
            Print("Unknow HTTP request error(" + string(error) + ")! Data");
         return (false);
      } else if (res == 200) {
         LastWebRequest = TimeLocal();
         string HTTPString = CharArrayToString(result, 0, 0, CP_UTF8);
         Print("HTTP request for Data successful!");
         Print(HTTPString);
         if (StringFind(HTTPString, "invalid api key", 0) != -1) {
            Alert("invalid api key");
            return (false);
         }
         // Store the API data into a common folder file
         int filehandle = FileOpen(filename, FILE_READ | FILE_SHARE_READ | FILE_WRITE |
                                                 FILE_SHARE_WRITE | FILE_BIN);
         if (filehandle != INVALID_HANDLE) {
            FileWriteArray(filehandle, result, 0, ArraySize(result));
            FileClose(filehandle);
         }
      }
   }
   return (true);
}

//+------------------------------------------------------------------+

void JsonDataParse(string filename, string &_APIJSON[]) {
   bool UpdateData = false;
   for (int arraIn = 0; arraIn < ArraySize(APIJSON); arraIn++)
      APIJSON[arraIn] = "";

   if (FileGetInteger(filename, FILE_EXISTS, true) >= 0) {
      int FileHandle = FileOpen(filename, FILE_READ | FILE_SHARE_READ | FILE_WRITE |
                                              FILE_SHARE_WRITE | FILE_BIN);
      char jsonarray[];
      FileReadArray(FileHandle, jsonarray);
      FileClose(FileHandle);

      JsonValue.Clear();
      JsonValue.Deserialize(CharArrayToString(jsonarray, 0, 0, CP_UTF8));

      _APIJSON[0] = JsonValue[0]["title"].ToStr();
      _APIJSON[1] = JsonValue[0]["country"].ToStr();
      _APIJSON[2] = JsonValue[0]["date"].ToStr();
      _APIJSON[3] = JsonValue[0]["impact"].ToStr();
      _APIJSON[4] = JsonValue[0]["forecast"].ToStr();
      _APIJSON[5] = JsonValue[0]["previous"].ToStr();
   }
}

//+------------------------------------------------------------------+
