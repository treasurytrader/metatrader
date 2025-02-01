#import "kernel32.dll"
int FindFirstFileW(string path, int &answer[]);
bool FindNextFileW(int handle, int &answer[]);
bool FindClose(int handle);
#import

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int init() {
  //----
  int win32_DATA[79];

  string param = "Q:\\MetaTrader 4\\MQL4\\Files\\*.txt";
  Print(param);

  int cnt = 0;
  int handle = FindFirstFileW(param, win32_DATA);
  Print("file", cnt++, bufferToString(win32_DATA));
  ArrayInitialize(win32_DATA, 0);

  while (FindNextFileW(handle, win32_DATA)) {
    Print("file", cnt++, bufferToString(win32_DATA));
    ArrayInitialize(win32_DATA, 0);
  }

  if (handle > 0)
    FindClose(handle);

  ExpertRemove();
  //----
  return (0);
}

//------------------------------------
int deinit() { return (0); }

//------------------------------------
int start() {
  //----

  //----
  return (0);
}

//+------------------------------------------------------------------+
//|  read text from buffer                                           |
//+------------------------------------------------------------------+
string bufferToString(int buffer[]) {
  string text = "";

  int pos = 10;
  for (int i = 0; i < 64; i++) {
    pos++;
    int curr = buffer[pos];
    text = text + CharToString(curr & 0x000000FF) +
           CharToString(curr >> 16 & 0x000000FF);
  }
  return (text);
}