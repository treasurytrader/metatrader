
// https://www.mql5.com/en/forum/187617
//+------------------------------------------------------------------+
//|                                        ListingFilesDirectory.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.010"

#include <_winfind.mqh>

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  //---
  WIN32_FIND_DATA ffd;
  long hFind;

  ArrayInitialize(ffd.cFileName, 0);
  ArrayInitialize(ffd.cAlternateFileName, 0);

  string mask_path = "Q:\\Temp\\*.*";

  hFind = -100;
  hFind = FindFirstFileW(mask_path, ffd);
  if (hFind == INVALID_HANDLE) {
    PrintFormat("Failed FindFirstFile (hFind) with error: %x", kernel32::GetLastError());
    return;
  }

  // List all the files in the directory with some info about them
  PrintFormat("hFind=%d", hFind);
  bool rezult = 0;
  do {
    string name = "";
    for (int i = 0; i < MAX_PATH; i++) {
      name += ShortToString(ffd.cFileName[i]);
    }

    Print(name, " : File Attribute Constants (dec) : ", ffd.dwFileAttributes);

    //---

    ArrayInitialize(ffd.cFileName, 0);
    ArrayInitialize(ffd.cAlternateFileName, 0);

    ffd.dwFileAttributes = -100;
    ResetLastError();

    rezult = WinAPI_FindNextFile(hFind, ffd);

  } while (rezult != 0);

  if (kernel32::GetLastError() != ERROR_NO_MORE_FILES)
    PrintFormat("Failed WinAPI_FindNextFile (hFind) with error: %x", kernel32::GetLastError());

  WinAPI_FindClose(hFind);
}
//+------------------------------------------------------------------+
