//+------------------------------------------------------------------+
//|                                             ChartCapture-Scr.mq4 |
//|                               Copyright 2013, Fai Software Corp. |
//|                                        https://twitter.com/faifx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Fai Software Corp."
#property link      "https://twitter.com/faifx"
#property show_inputs


#import "shell32.dll"
int ShellExecuteA(int hWnd,int lpVerb,string lpFile,string lpParameters,string lpDirectory,int nCmdShow);
#import
#define SW_SHOW             5
#define SW_HIDE             0

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
     if (!IsDllsAllowed()) {
      Alert("ERROR: [Allow DLL imports] NOT Checked.");return (0);
   }

   string filename = Symbol()+Period()+".gif";
   WindowScreenShot(filename,400,480,10+1,5,1);
   
   //string smailPATH = "C:\\Downloads\\smail-v4.16\\smailtest.bat";
   string smailPATH = "C:\\Downloads\\smail-v4.16\\smail.exe"; 
   string smailParameter = "-hsmtp.gmail.com -sTEST email2fai@gmail.com -TXXX\nYYY -d -a\""+TerminalPath()+"\\experts\\files\\"+filename+"\"";
   
   ShellExecuteA(0,0, smailPATH,smailParameter,"",SW_SHOW);//SW_HIDE�ł��ǂ��B


   return(0);
  }
//+------------------------------------------------------------------+
/*
smail.exe �͈ȉ��̃T�C�g����ŐV�ł���肷��B
http://dip.picolix.jp/disp2.html

smail.exe ���ADOS���̃R�}���h���C�����琳�퓮�삷�邱�Ƃ��m�F����B


MT4����̌Ăяo���Ɏ��s����ꍇ�́A�ȉ��̂R�s��������
smailtest.bat �Ƃ����t�@�C�����쐬���A
smail.exe �̑���ɌĂԂƃE�B���h�E�����Ȃ��̂Œ����ɕ֗��B
---------------------------------------
cd C:\Downloads\smail-v4.16
smail.exe %*
pause
---------------------------------------

*/


