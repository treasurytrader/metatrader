//+------------------------------------------------------------------+
//| Example of using WinFile.mqh for reading/writing files           |
//| anywhere on the hard disk. WinFile.mqh needs to be present       |
//| in the experts\include directory, and "Allow DLL imports"        |
//| needs to be turned on.                                           |
//|                                                                  |
//| This example is a *script*, which should be put in               |
//| experts\scripts and then compiled                                |
//+------------------------------------------------------------------+

#include <_winfile.mqh>

#property copyright "Copyright 2009 MTIntelligence.com"
#property link "http://www.mtintelligence.com"

void OnStart() {
  string strTestFilename = "Q:\\Temp\\test1.txt";

  //---
  if (!DoesFileExist(strTestFilename)) {
    Print("파일 없음 : ", strTestFilename);
  } else {
    if (DeleteFile(strTestFilename)) {
      Print("파일 삭제 : ", strTestFilename);
    } else {
      Print("파일 삭제 실패 : ", strTestFilename);
    }
  }

  //---
  HANDLE fWrite = OpenNewFileForWriting(strTestFilename, true);
  if (!IsValidFileHandle(fWrite)) {
    Print("파일 열기 실패 : ", strTestFilename);
  } else {
    WriteToFile(fWrite, "Test 1\n");
    WriteToFile(fWrite, "Test 2\n");
    WriteToFile(fWrite, "Test 3");
  }
  CloseFile(fWrite);

  //---
  HANDLE fRead = OpenExistingFileForReading(strTestFilename, true, true);

  if (!IsValidFileHandle(fRead)) {
    Print("파일 열기 실패 : ", strTestFilename);
  } else {
    string strWholeFile = ReadWholeFile(fRead);
    Print("파일 전체 내용 : ", ReadWholeFile(fRead));
  }

  if (!MoveToFileStart(fRead)) {
    Print("포인터 이동 실패 : ", strTestFilename);
  } else {
    while (!IsFileAtEnd(fRead)) {
      Print("라인 읽기 : ", ReadLineFromFile(fRead, "\n"));
    }
  }
  CloseFile(fRead);
  //---
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// 기존 파일에 추가
HANDLE OpenExistingFileForReading(string file_name, bool ShareForReading = true, bool ShareForWriting = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode += FILE_SHARE_READ;
  if (ShareForWriting) ShareMode += FILE_SHARE_WRITE;
  return (WinAPI_FileOpen(file_name, FILE_READ | FILE_WRITE | ShareMode));
}
/*
int OpenExistingFileForReading(string FileName, bool ShareForReading = true, bool ShareForWriting = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode += FILE_SHARE_READ;
  if (ShareForWriting) ShareMode += FILE_SHARE_WRITE;
  return (CreateFileW(FileName, GENERIC_READ, ShareMode, 0, OPEN_EXISTING, 0, 0));
}
*/
// 기존 파일에 추가
HANDLE OpenExistingFileForWriting(string file_name, bool Append = true, bool ShareForReading = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode = FILE_SHARE_READ;
  HANDLE handle = WinAPI_FileOpen(file_name, FILE_READ | FILE_WRITE | ShareMode);
  if (-1 != handle && Append) {
    int movehigh[1] = {0};
    SetFilePointer(handle, 0, movehigh, FILE_END);
  }
  return (handle);
}
/*
int OpenExistingFileForWriting(string FileName, bool Append = true, bool ShareForReading = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode = FILE_SHARE_READ;
  int FileHandle = CreateFileW(FileName, GENERIC_WRITE, ShareMode, 0, OPEN_ALWAYS, 0, 0);
  if (IsValidFileHandle(FileHandle) && Append) {
    int movehigh[1] = {0};
    SetFilePointer(FileHandle, 0, movehigh, FILE_END);
  }
  return (FileHandle);
}
*/
// 새로운 파일 생성
HANDLE OpenNewFileForWriting(string file_name, bool ShareForReading = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode = FILE_SHARE_READ;
  return (WinAPI_FileOpen(file_name, FILE_WRITE | ShareMode));
}
/*
HANDLE OpenNewFileForWriting(string FileName, bool ShareForReading = false) {
  int ShareMode = 0;
  if (ShareForReading) ShareMode = FILE_SHARE_READ;
  return (CreateFileW(FileName, GENERIC_WRITE, ShareMode, 0, CREATE_ALWAYS, 0, 0));
}
*/
bool DoesFileExist(string file_handle) {
  return (WinAPI_FileIsExist(file_handle));
}
bool IsValidFileHandle(HANDLE file_handle) {
  return (-1 != file_handle);
}
bool WriteToFile(HANDLE file_handle, string data) {
  return (0 != WinAPI_FileWrite(file_handle, data));
}
string ReadWholeFile(HANDLE file_handle) {
  return (WinAPI_FileRead(file_handle));
}
string ReadLineFromFile(HANDLE file_handle, string terminator = "\n") {
  return (WinAPI_FileReadString(file_handle, 0, terminator));
}
bool IsFileAtEnd(HANDLE file_handle) {
  return (WinAPI_FileIsEnding(file_handle));
}
bool MoveToFileStart(HANDLE file_handle) {
  return (WinAPI_FileSeek(file_handle, 0, SEEK_SET));
}
bool MoveToFileEnd(HANDLE file_handle) {
  return (WinAPI_FileSeek(file_handle, 0, SEEK_END));
}
void CloseFile(HANDLE FileHandle) {
  WinAPI_FileClose(FileHandle);
}
bool DeleteFile(string FileName) {
  return (WinAPI_FileDelete(FileName));
}
