#ifndef __GRAPHICS_COMMON_MQH__
#define __GRAPHICS_COMMON_MQH__

bool EnsureHLine(const string name, const double price, const color col, const int width, const int style, const bool back){
  if(ObjectFind(0, name)==-1){
    if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) return false;
    ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
  }
  bool changed=false;
  double curPrice = ObjectGetDouble(0, name, OBJPROP_PRICE);
  if(MathAbs(curPrice - price) > Point){ ObjectSetDouble(0, name, OBJPROP_PRICE, price); changed=true; }
  if((color)ObjectGetInteger(0, name, OBJPROP_COLOR) != col){ ObjectSetInteger(0, name, OBJPROP_COLOR, col); changed=true; }
  if((int)ObjectGetInteger(0, name, OBJPROP_WIDTH) != width){ ObjectSetInteger(0, name, OBJPROP_WIDTH, width); changed=true; }
  if((int)ObjectGetInteger(0, name, OBJPROP_STYLE) != style){ ObjectSetInteger(0, name, OBJPROP_STYLE, style); changed=true; }
  if((bool)ObjectGetInteger(0, name, OBJPROP_BACK) != back){ ObjectSetInteger(0, name, OBJPROP_BACK, back); changed=true; }
  return changed;
}

bool EnsureText(const string name, const datetime t, const double price, const string text, const string font, const int size, const color col, const bool back){
  if(ObjectFind(0, name)==-1){
    if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price)) return false;
    ObjectSetInteger(0, name, OBJPROP_BACK, back);
  }
  bool changed=false;
  if((datetime)ObjectGetInteger(0, name, OBJPROP_TIME) != t){ ObjectSetInteger(0, name, OBJPROP_TIME, t); changed=true; }
  double curPrice = ObjectGetDouble(0, name, OBJPROP_PRICE);
  if(MathAbs(curPrice - price) > Point){ ObjectSetDouble(0, name, OBJPROP_PRICE, price); changed=true; }
  string curText; ObjectGetString(0, name, OBJPROP_TEXT, curText);
  if(curText != text){ ObjectSetText(name, text, size, font, col); changed=true; }
  if((bool)ObjectGetInteger(0, name, OBJPROP_BACK) != back){ ObjectSetInteger(0, name, OBJPROP_BACK, back); changed=true; }
  return changed;
}

bool EnsureLabel(const string name, const int corner, const int x, const int y, const int size, const string font, const color col, const string text, const bool back){
  if(ObjectFind(0, name)==-1){
    if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) return false;
  }
  bool changed=false;
  if((int)ObjectGetInteger(0, name, OBJPROP_CORNER) != corner){ ObjectSetInteger(0, name, OBJPROP_CORNER, corner); changed=true; }
  if((int)ObjectGetInteger(0, name, OBJPROP_XDISTANCE) != x){ ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x); changed=true; }
  if((int)ObjectGetInteger(0, name, OBJPROP_YDISTANCE) != y){ ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y); changed=true; }
  int curSize = (int)ObjectGetInteger(0, name, OBJPROP_FONTSIZE);
  if(curSize != size){ ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size); changed=true; }
  string curFont; ObjectGetString(0, name, OBJPROP_FONT, curFont);
  if(curFont != font){ ObjectSetString(0, name, OBJPROP_FONT, font); changed=true; }
  color curCol = (color)ObjectGetInteger(0, name, OBJPROP_COLOR);
  if(curCol != col){ ObjectSetInteger(0, name, OBJPROP_COLOR, col); changed=true; }
  string curText; ObjectGetString(0, name, OBJPROP_TEXT, curText);
  if(curText != text){ ObjectSetString(0, name, OBJPROP_TEXT, text); changed=true; }
  if((bool)ObjectGetInteger(0, name, OBJPROP_BACK) != back){ ObjectSetInteger(0, name, OBJPROP_BACK, back); changed=true; }
  return changed;
}

void SetAngleIfChanged(const string name, const double angle){
  double cur = ObjectGetDouble(0, name, OBJPROP_ANGLE);
  if(MathAbs(cur - angle) > 0.1) ObjectSet(name, OBJPROP_ANGLE, angle);
}

// Optional: simple throttle helper
static ulong __gui_last = 0;
bool GuiCanUpdate(const int ms){
  ulong now = GetTickCount();
  if(now - __gui_last < (ulong)ms) return false;
  __gui_last = now; return true;
}

#endif // __GRAPHICS_COMMON_MQH__
