#ifndef __STEPS_UNIFIED_MQH__
#define __STEPS_UNIFIED_MQH__

// Unified step calculation (identical to master)

// pr flags loaded from str_pr*.txt
bool   g_pr[6]; // 1..5
// previous counts
int    g_prev_countBuyAll = -1, g_prev_countSellAll = -1;
// cached steps in pips
double g_next_step_buy = 0, g_next_step_sell = 0;
// cached steps in price
double g_next_step_buy_px = 0, g_next_step_sell_px = 0;

inline double PipValueLocal(const string sym){
  int digits = (int)MarketInfo(sym, MODE_DIGITS);
  int mult = 1;
  // For 3/5 digit quotes or PROFIT_CALCMODE_FOREX (value 1), use 10x multiplier
  if(digits==3 || digits==5 || MarketInfo(sym,MODE_PROFITCALCMODE)==1) mult=10;
  return mult*MarketInfo(sym, MODE_POINT);
}

struct StepRange { int from,to; int stepByPr[6]; };

// Tables (same as master)
static StepRange RangesBuy[] = {
  {1,5,    {0,6,5,4,3,2}},
  {5,10,   {0,8,7,6,5,4}},
  {10,15,  {0,16,14,12,10,8}},
  {15,20,  {0,30,28,26,24,22}},
  {20,40,  {0,40,38,36,34,32}},
  {40,1000,{0,60,58,56,54,52}}
};
static StepRange RangesSell[] = {
  {1,5,    {0,6,5,4,3,2}},
  {5,10,   {0,8,7,6,5,4}},
  {10,15,  {0,16,14,12,10,8}},
  {15,20,  {0,30,28,26,24,22}},
  {20,40,  {0,40,38,36,34,32}},
  {40,1000,{0,60,58,56,54,52}}
};

int ComputeNextStep(const bool isBuy, const int countAllSide, bool &pr[]){
  if(isBuy){
    for(int i=0;i<ArraySize(RangesBuy);i++){
      if(countAllSide>=RangesBuy[i].from && countAllSide<RangesBuy[i].to){
        // pr[1..5]
        for(int p=1;p<=5;p++){
          if(pr[p]) return RangesBuy[i].stepByPr[p];
        }
        return RangesBuy[i].stepByPr[5]; // default if none
      }
    }
    return 60; // fallback
  }
  else{
    for(int i=0;i<ArraySize(RangesSell);i++){
      if(countAllSide>=RangesSell[i].from && countAllSide<RangesSell[i].to){
        for(int p=1;p<=5;p++){
          if(pr[p]) return RangesSell[i].stepByPr[p];
        }
        return RangesSell[i].stepByPr[5];
      }
    }
    return 60;
  }
}

void Steps_OnTimer(int countBuyAll, int countSellAll){
  // Only recompute if counts changed
  if(countBuyAll == g_prev_countBuyAll && countSellAll == g_prev_countSellAll)
    return;
  
  g_prev_countBuyAll = countBuyAll;
  g_prev_countSellAll = countSellAll;
  
  // Load pr flags from str_pr*.txt
  for(int i=1;i<=5;i++) g_pr[i] = false;
  if(FileIsExist("str_pr1.txt",0)) g_pr[1]=true;
  if(FileIsExist("str_pr2.txt",0)) g_pr[2]=true;
  if(FileIsExist("str_pr3.txt",0)) g_pr[3]=true;
  if(FileIsExist("str_pr4.txt",0)) g_pr[4]=true;
  if(FileIsExist("str_pr5.txt",0)) g_pr[5]=true;
  
  // Compute next steps in pips
  g_next_step_buy  = ComputeNextStep(true,  countBuyAll,  g_pr);
  g_next_step_sell = ComputeNextStep(false, countSellAll, g_pr);
  
  // Convert to price distance
  double pipVal = PipValueLocal(Symbol());
  g_next_step_buy_px  = g_next_step_buy  * pipVal;
  g_next_step_sell_px = g_next_step_sell * pipVal;
}

#endif
