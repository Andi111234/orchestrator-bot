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
      if(countAllSide >= RangesBuy[i].from && countAllSide < RangesBuy[i].to){
        // which pr?
        for(int p=1; p<=5; p++){
          if(pr[p]) return RangesBuy[i].stepByPr[p];
        }
        return RangesBuy[i].stepByPr[5]; // fallback
      }
    }
    return RangesBuy[ArraySize(RangesBuy)-1].stepByPr[5];
  } else {
    for(int i=0;i<ArraySize(RangesSell);i++){
      if(countAllSide >= RangesSell[i].from && countAllSide < RangesSell[i].to){
        for(int p=1; p<=5; p++){
          if(pr[p]) return RangesSell[i].stepByPr[p];
        }
        return RangesSell[i].stepByPr[5];
      }
    }
    return RangesSell[ArraySize(RangesSell)-1].stepByPr[5];
  }
}

void LoadPrFlags(){
  // read str_pr1..str_pr5
  for(int i=1; i<=5; i++){
    string fname = "str_pr"+IntegerToString(i)+".txt";
    g_pr[i] = (FileIsExist(fname,0)>=1);
  }
}

void Steps_OnTimer(int countBuyAll, int countSellAll){
  // recompute only if counts changed
  if(countBuyAll == g_prev_countBuyAll && countSellAll == g_prev_countSellAll){
    return; // no change
  }
  g_prev_countBuyAll = countBuyAll;
  g_prev_countSellAll = countSellAll;
  
  LoadPrFlags();
  
  // compute step in pips
  g_next_step_buy  = ComputeNextStep(true,  countBuyAll,  g_pr);
  g_next_step_sell = ComputeNextStep(false, countSellAll, g_pr);
  
  // convert to price
  double pip = PipValueLocal(Symbol());
  g_next_step_buy_px  = g_next_step_buy  * pip;
  g_next_step_sell_px = g_next_step_sell * pip;
}

#endif
