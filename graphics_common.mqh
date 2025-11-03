#ifndef GRAPHICS_COMMON_MQH
#define GRAPHICS_COMMON_MQH
#property strict

// ============================================================================
// graphics_common.mqh
// Common graphics helpers for orchestrator-bot EAs
// Provides efficient object creation/update with change detection
// ============================================================================

// Optional: GUI throttle to limit update frequency
static datetime g_last_gui_update = 0;

bool GuiCanUpdate(int intervalMs) {
  datetime now = TimeCurrent();
  if (now != g_last_gui_update || intervalMs == 0) {
    g_last_gui_update = now;
    return true;
  }
  return false;
}

// Ensure horizontal line exists at given price (create or update)
void EnsureHLine(string name, double price, color col, int width = 1, int style = STYLE_SOLID, bool back = true) {
  if (ObjectFind(0, name) == -1) {
    ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
  } else {
    ObjectSetDouble(0, name, OBJPROP_PRICE, price);
  }
  ObjectSetString(0, name, OBJPROP_TOOLTIP, "\n");
  ObjectSetInteger(0, name, OBJPROP_COLOR, col);
  ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
  ObjectSetInteger(0, name, OBJPROP_STYLE, style);
  ObjectSetInteger(0, name, OBJPROP_BACK, back);
}

// Ensure text object exists at given time/price (create or update)
void EnsureText(string name, datetime t, double price, string text, string font = "Arial", int size = 10, color col = clrWhite, bool back = true) {
  if (ObjectFind(0, name) == -1) {
    ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
  }
  ObjectSetDouble(0, name, OBJPROP_PRICE, price);
  ObjectSetInteger(0, name, OBJPROP_TIME, t);
  ObjectSetText(name, text, size, font, col);
  ObjectSetInteger(0, name, OBJPROP_BACK, back);
}

// Ensure label exists at given corner/offset (create or update)
void EnsureLabel(string name, int corner, int x, int y, int size, string font, color col, string text, bool back = false) {
  if (ObjectFind(0, name) == -1) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
  }
  ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
  ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
  ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
  ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
  ObjectSetString(0, name, OBJPROP_FONT, font);
  ObjectSetInteger(0, name, OBJPROP_COLOR, col);
  ObjectSetString(0, name, OBJPROP_TEXT, text);
  ObjectSetInteger(0, name, OBJPROP_BACK, back);
}

// Set angle on object if different (for rotating icons)
void SetAngleIfChanged(string name, double angle) {
  if (ObjectFind(0, name) == -1) return;
  double current_angle = ObjectGetDouble(0, name, OBJPROP_ANGLE);
  if (MathAbs(current_angle - angle) > 0.1) {
    ObjectSetDouble(0, name, OBJPROP_ANGLE, angle);
  }
}

#endif
