//+------------------------------------------------------------------+
//|                                                  TileMan[sc].mq4 |
//|                           Copyright (c) 2009, Fai Software Corp. |
//|                                    http://d.hatena.ne.jp/fai_fx/ |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009, Fai Software Corp."
#property link      "http://d.hatena.ne.jp/fai_fx/"
#property show_inputs
#define MAXWINNUM 128

extern int col_TATE = 0;
extern int row_YOKO = 2;

#import "user32.dll"
int  GetWindow(int hWnd,int wCmd);
int  GetParent(int hWnd);
bool ShowWindow(int hWnd,int nCmdShow);
bool MoveWindow(int hWnd,int X,int Y,int nWidth,int nHeight,int bRepaint);
bool GetClientRect(int hWnd,int size[4]);
#import

int start()
  {
   if (!IsDllsAllowed()) {
      Alert("ERROR: [Allow DLL imports] NOT Checked.");return (0);
   }
   int size[4],window[MAXWINNUM],count;
   window[0] = GetParent(WindowHandle(Symbol(),Period()));

   for(count=1;count<MAXWINNUM;count++){
      window[count] = GetWindow(window[count-1],2);
      if(window[count]==0) break;
   }

   if(col_TATE ==0) col_TATE = MathCeil(count*1.0/row_YOKO);
   if(row_YOKO ==0) row_YOKO = MathCeil(count*1.0/col_TATE);
   GetClientRect(GetParent(window[0]),size);
   int width  = size[2]/col_TATE;
   int height = size[3]/row_YOKO;
 
   for(int i=0;i<count;i++){
      ShowWindow(window[i],1);
      MoveWindow(window[i],MathMod(i,col_TATE)*width,i/col_TATE*height,width,height,true);
   }
   PlaySound("tick");
   return(0);
  }
//+------------------------------------------------------------------+-------------------------------------------------------+