#ifndef __GRAPHICS_HELPERS_MQH__
#define __GRAPHICS_HELPERS_MQH__

// Graphics helpers to replace direct ObjectCreate/ObjectSet calls

void EnsureHLine(const string name, const double price, const color clr, const int width=1, const int style=2, const bool back=true){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_HLINE,0,0,price);
  }else{
    ObjectSetDouble(0,name,OBJPROP_PRICE,price);
  }
  ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
  ObjectSetInteger(0,name,OBJPROP_STYLE,style);
  ObjectSetInteger(0,name,OBJPROP_BACK,back);
}

void EnsureText(const string name, const datetime time, const double price, const string text, const int fontSize, const string fontName, const color clr, const bool back=true){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_TEXT,0,time,price);
  }
  ObjectSetDouble(0,name,OBJPROP_PRICE,price);
  ObjectSetInteger(0,name,OBJPROP_TIME,time);
  ObjectSetInteger(0,name,OBJPROP_BACK,back);
  ObjectSetText(name,text,fontSize,fontName,clr);
}

void EnsureLabel(const string name, const int x, const int y, const string text, const int fontSize, const string fontName, const color clr, const int corner=0){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_LABEL,0,0,0);
  }
  ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
  ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetString(0,name,OBJPROP_TEXT,text);
  ObjectSetString(0,name,OBJPROP_FONT,fontName);
  ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
  ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
}

void EnsureRectLabel(const string name, const int x, const int y, const int width, const int height, const color bgColor, const color borderColor=clrNONE, const int corner=0){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
  }
  ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
  ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
  ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bgColor);
  ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,borderColor);
}

void EnsureVLine(const string name, const datetime time, const color clr, const int width=1, const int style=2, const bool back=true){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_VLINE,0,time,0);
  }else{
    ObjectSetInteger(0,name,OBJPROP_TIME,time);
  }
  ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
  ObjectSetInteger(0,name,OBJPROP_STYLE,style);
  ObjectSetInteger(0,name,OBJPROP_BACK,back);
}

void EnsureTrendLine(const string name, const datetime time1, const double price1, const datetime time2, const double price2, const color clr, const int width=1, const int style=0, const bool back=false){
  if(ObjectFind(0,name)==-1){
    ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
  }else{
    ObjectSetInteger(0,name,OBJPROP_TIME,0,time1);
    ObjectSetDouble(0,name,OBJPROP_PRICE,0,price1);
    ObjectSetInteger(0,name,OBJPROP_TIME,1,time2);
    ObjectSetDouble(0,name,OBJPROP_PRICE,1,price2);
  }
  ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
  ObjectSetInteger(0,name,OBJPROP_STYLE,style);
  ObjectSetInteger(0,name,OBJPROP_BACK,back);
  ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
}

#endif
