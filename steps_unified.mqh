//+------------------------------------------------------------------+
//|                                               steps_unified.mqh  |
//|                        Unified step threshold caching for orders |
//+------------------------------------------------------------------+

// Cached step thresholds (in pips) for re-entry logic
double g_next_step_buy = 0;
double g_next_step_sell = 0;

// Cached step thresholds (in price units) for line drawing
double g_next_step_buy_px = 0;
double g_next_step_sell_px = 0;

//+------------------------------------------------------------------+
//| Update cached step thresholds based on current strategy         |
//+------------------------------------------------------------------+
void UpdateStepThresholds(double buy_pips, double sell_pips, double buy_px, double sell_px)
{
    g_next_step_buy = buy_pips;
    g_next_step_sell = sell_pips;
    g_next_step_buy_px = buy_px;
    g_next_step_sell_px = sell_px;
}
