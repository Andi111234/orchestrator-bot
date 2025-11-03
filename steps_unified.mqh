#ifndef STEPS_UNIFIED_MQH
#define STEPS_UNIFIED_MQH
#property strict

// ============================================================================
// steps_unified.mqh
// Unified step computation for orchestrator-bot EAs
// Provides cached step values updated via OnTimer to reduce per-tick overhead
// ============================================================================

// Global cached step values (pips and price units)
double g_next_step_buy = 0;
double g_next_step_sell = 0;
double g_next_step_buy_px = 0;
double g_next_step_sell_px = 0;

// Cache of previous counts to detect changes
int g_cached_count_buy = -1;
int g_cached_count_sell = -1;

// Helper: compute pip value considering digits and profit calc mode
double PipValueLocal(string sym) {
  int digits = (int)MarketInfo(sym, MODE_DIGITS);
  int profitMode = (int)MarketInfo(sym, MODE_PROFITCALCMODE);
  int mult = 1;
  if (digits == 5 || digits == 3 || profitMode == 1)
    mult = 10;
  return mult * MarketInfo(sym, MODE_POINT);
}

// Step lookup tables (6 ranges × 5 PR priority flags)
// Range: [1..5), [5..10), [10..15), [15..20), [20..40), [40+)
// PR flags: str_pr1.txt (highest), str_pr2.txt, str_pr3.txt, str_pr4.txt, str_pr5.txt (lowest)

void ComputeSteps(int count, bool isBuy, double &step_pips, double &step_px) {
  // Default fallback
  step_pips = 2;
  step_px = 0.0002;
  
  // Check PR flag files (priority order: 1 > 2 > 3 > 4 > 5)
  bool pr1 = FileIsExist("str_pr1.txt", 0) >= 1;
  bool pr2 = FileIsExist("str_pr2.txt", 0) >= 1;
  bool pr3 = FileIsExist("str_pr3.txt", 0) >= 1;
  bool pr4 = FileIsExist("str_pr4.txt", 0) >= 1;
  bool pr5 = FileIsExist("str_pr5.txt", 0) >= 1;
  
  // Step tables for BUY and SELL (same values, keeping separate for clarity)
  // Range 1: [1..5)
  if (count >= 1 && count < 5) {
    if (pr1) { step_pips = 6;  step_px = 0.0006; }
    else if (pr2) { step_pips = 5;  step_px = 0.0005; }
    else if (pr3) { step_pips = 4;  step_px = 0.0004; }
    else if (pr4) { step_pips = 3;  step_px = 0.0003; }
    else if (pr5) { step_pips = 2;  step_px = 0.0002; }
  }
  // Range 2: [5..10)
  else if (count >= 5 && count < 10) {
    if (pr1) { step_pips = 8;  step_px = 0.0008; }
    else if (pr2) { step_pips = 7;  step_px = 0.0007; }
    else if (pr3) { step_pips = 6;  step_px = 0.0006; }
    else if (pr4) { step_pips = 5;  step_px = 0.0005; }
    else if (pr5) { step_pips = 4;  step_px = 0.0004; }
  }
  // Range 3: [10..15)
  else if (count >= 10 && count < 15) {
    if (pr1) { step_pips = 16; step_px = 0.0016; }
    else if (pr2) { step_pips = 14; step_px = 0.0014; }
    else if (pr3) { step_pips = 12; step_px = 0.0012; }
    else if (pr4) { step_pips = 10; step_px = 0.0010; }
    else if (pr5) { step_pips = 8;  step_px = 0.0008; }
  }
  // Range 4: [15..20)
  else if (count >= 15 && count < 20) {
    if (pr1) { step_pips = 30; step_px = 0.0030; }
    else if (pr2) { step_pips = 28; step_px = 0.0028; }
    else if (pr3) { step_pips = 26; step_px = 0.0026; }
    else if (pr4) { step_pips = 24; step_px = 0.0024; }
    else if (pr5) { step_pips = 22; step_px = 0.0022; }
  }
  // Range 5: [20..40)
  else if (count >= 20 && count < 40) {
    if (pr1) { step_pips = 40; step_px = 0.0040; }
    else if (pr2) { step_pips = 38; step_px = 0.0038; }
    else if (pr3) { step_pips = 36; step_px = 0.0036; }
    else if (pr4) { step_pips = 34; step_px = 0.0034; }
    else if (pr5) { step_pips = 32; step_px = 0.0032; }
  }
  // Range 6: [40+)
  else if (count >= 40) {
    if (pr1) { step_pips = 60; step_px = 0.0060; }
    else if (pr2) { step_pips = 58; step_px = 0.0058; }
    else if (pr3) { step_pips = 56; step_px = 0.0056; }
    else if (pr4) { step_pips = 54; step_px = 0.0054; }
    else if (pr5) { step_pips = 52; step_px = 0.0052; }
  }
}

// Call from OnTimer: recomputes steps only if counts changed
void Steps_OnTimer(int countBuyAll, int countSellAll) {
  bool changed = false;
  
  if (countBuyAll != g_cached_count_buy) {
    ComputeSteps(countBuyAll, true, g_next_step_buy, g_next_step_buy_px);
    g_cached_count_buy = countBuyAll;
    changed = true;
  }
  
  if (countSellAll != g_cached_count_sell) {
    ComputeSteps(countSellAll, false, g_next_step_sell, g_next_step_sell_px);
    g_cached_count_sell = countSellAll;
    changed = true;
  }
  
  if (changed) {
    Print("[Steps_OnTimer] Buy count=", countBuyAll, " -> step=", g_next_step_buy, " pips (", g_next_step_buy_px, ")");
    Print("[Steps_OnTimer] Sell count=", countSellAll, " -> step=", g_next_step_sell, " pips (", g_next_step_sell_px, ")");
  }
}

#endif
