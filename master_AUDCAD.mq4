//+------------------------------------------------------------------+
//|      Copyright 2019, Andrey Tarasov
//+------------------------------------------------------------------+
#property strict
#include "sovetnikov_light.mqh"
#include "steps_unified.mqh"
#include "graphics_common.mqh"

#define BOT_NAME "Bot_3"

// ========================= VISUALIZATION ===========================
input bool telegram = true;
string URL="https://api.telegram.org/";
extern string ChannelID="419654265";
extern string BotID=""; // put in .set preferably

// ---------------- one-action-per-bar helper ------------------------
datetime LastActiontime_vline=StrToTime(TimeToStr(TimeCurrent(),TIME_SECONDS));

// ---------------- colors -------------------------------------------
color col_1=Silver,col_2=PapayaWhip,col_3=DeepSkyBlue,col_4=OrangeRed,col_5=Gray,col_6=Lime,col_8=Chocolate,col_9=Orange,col_10=Red,col_11=LightGray,col_12=DarkOrange,col_13=OrangeRed,col_14=White,col_15=DimGray,col_16=Gold,col_17=Black,col_18=DarkGray,col_19=DodgerBlue;

// ---------------- font settings ------------------------------------
int    FontSize   =10;
string TextFONT   ="Courier New";
int    CORNER     =0;

// ======================= SETTINGS ===========================
input bool master        =true;
input bool standart      =false;
input bool delta_dinamic =true;
input int  OpenCooldownSec = 2; // 0 = disable cooldown

bool AUDCAD_AUDUSD       =true;

// Account/scale
double start_um=400000;
double bonus=0;

// Lot matrix
double lot1=0.1,lot2=0.1,lot3=0.1,lot4=0.1,lot5=0.1;
double lot6=0.2,lot7=0.2,lot8=0.2,lot9=0.2,lot10=0.2;
double lot11=0.3,lot12=0.3,lot13=0.3,lot14=0.3,lot15=0.3;
double lot16=0.4,lot17=0.4,lot18=0.4,lot19=0.4,lot20=0.4;
double lot21=0.6,lot22=0.6,lot23=0.6,lot24=0.6,lot25=0.6;
double lot26=0.8,lot27=0.8,lot28=0.8,lot29=0.8,lot30=0.8;
double lot31=0.85,lot32=0.85,lot33=0.85,lot34=0.85,lot35=0.85;
double lot36=0.9,lot37=0.9,lot38=0.9,lot39=0.9,lot40=0.9;
double lot41=0.95,lot42=0.95,lot43=0.95,lot44=0.95,lot45=0.95;
double lot46=1.0,lot47=1.0,lot48=1.0,lot49=1.0,lot50=1.0;

double st1=1, st2=1.2, st3=1.4, st4=1.6, st5=1.8;

// Delta params
double st_delta_1=1, st_delta_2=1.4, st_delta_3=1.8, st_delta_4=2.2, st_delta_5=2.6;
double koeff_delta=1.1;
double delta_average=2;

double c777=200; // profit close threshold

// Magic
int order_magic=4,order_magic_2=5;

// ======================= GRID =============================
bool close_profit_buy     =true;
bool close_profit_sell    =true;

bool takeprofit_stoploss  =false;
bool trall_order_all      =true;
bool trall_order_razdelni =true;

double lMinProfit_1=8,lMinProfit_2=10,lMinProfit_3=18,lMinProfit_4=32,lMinProfit_5=42,lMinProfit_6=62;
double lTrailingStop_1=4,lTrailingStep_1=2;

double trailing_stop_pr=6;

// Buffers
double trr=0,HelpAccount=0,start_balance=0,max_lot=0,stoploss=0,stoploss1=0,takeprofit=0,takeprofit1=0,koeff_balance=0,t_p=0,s_l=0,minSellPrice=0,maxBuyPrice=0;
double par5=1;

// Cooldown arrays
datetime g_lastOpenBuy[6];    // cooldown per tier [0..5] -> tier 1..6
datetime g_lastOpenSell[6];   // cooldown per tier [0..5] -> tier 1..6

int slippage=100;

// Deltas
double delta_AUDCAD_AUDUSD_d=0;
double delta_AUDCAD_AUDUSD=0,
       delta_AUDCAD_AUDUSD_1=0,
       delta_AUDCAD_AUDUSD_2=0,
       delta_AUDCAD_AUDUSD_3=0,
       delta_AUDCAD_AUDUSD_4=0,
       delta_AUDCAD_AUDUSD_5=0,
       delta_AUDCAD_AUDUSD_average=0;

// Slot timers (fed from cache)
double str1_time=0,str2_time=0,str3_time=0,str4_time=0,str5_time=0;

// Cache settings
input int DaysForMonthlyProxy = 22;

// Strategy flags and slots (OnTimer managed)
bool g_pr[6];          // 1..5
double g_str_time[6];  // 1..5

// Delta cache
double g_delta_AUDCAD_D1_cache=0, g_delta_AUDUSD_D1_cache=0;
double g_delta_AUDCAD_20D_cache=0, g_delta_AUDUSD_20D_cache=0, g_delta_abs_20D_cache=0;
double g_strong[6];    // strong thresholds 1..5

// Counters snapshot
int g_countBuyAll=0, g_countSellAll=0, g_countBuyMagic2=0, g_countSellMagic2=0;
int g_prev_countBuyAll=-1, g_prev_countSellAll=-1;

// Steps cache (now from steps_unified.mqh)
// double g_next_step_buy=0, g_next_step_sell=0;           // in pips
// double g_next_step_buy_px=0, g_next_step_sell_px=0;     // in price (pip->price)

datetime g_cache_updated_at=0;

// Cooldown storage (now declared earlier)
// datetime g_lastOpenBuy[6], g_lastOpenSell[6];

// ---------- helpers ----------
bool isNewBar(){ static datetime BARflag=0; datetime now=(int)SeriesInfoInteger(Symbol(),PERIOD_M1,SERIES_LASTBAR_DATE); if(BARflag<now){BARflag=now;return(true);} return(false); }

double lastlos(){
  double last=0.0,opp=0.0; int cnt=0; datetime time=0;
  for(int i=OrdersHistoryTotal()-1; i>=0; i--){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderType() <= OP_SELL){
      if(cnt==0&&OrderCloseTime()!=0) time=OrderCloseTime();
      if(OrderCloseTime()+PeriodSeconds()<time) break;
      opp=(standart ? (OrderProfit()+OrderSwap()+OrderCommission()) : ((OrderProfit()+OrderSwap()+OrderCommission())/100.0));
      last=opp;cnt++;if(cnt!=0) cnt++;
    }
  }
  return last;
}

class CMain: public GOrders{
public:
  CMain() {}; ~CMain() {};
  void groupTake(int itype,double dtake){
    for(int i=OrdersTotal()-1; i>=0; i--){
      if(!OrderSelect(i,SELECT_BY_POS))continue;
      if((OrderSymbol()==sname||sname==NULL)&&(OrderMagicNumber()==imagic||imagic==-1)){
        if(OrderType()==OP_BUY&&itype==OP_BUY){
          if(nd(dtake)!=nd(OrderTakeProfit())||OrderTakeProfit()==0.0){
            bool ok = OrderModify(OrderTicket(),-1,-1,dtake,0,clrNONE);
            if(!ok) Print("groupTake BUY modify failed, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
        if(OrderType()==OP_SELL&&itype==OP_SELL){
          if(nd(dtake)!=nd(OrderTakeProfit())||OrderTakeProfit()==0.0){
            bool ok = OrderModify(OrderTicket(),-1,-1,dtake,0,clrNONE);
            if(!ok) Print("groupTake SELL modify failed, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
      }
    }
  }
};
CMain main(); double lots[50];

// ----------- Telegram ----------
string UrlEncode(const string s){
  string out="";
  for(int i=0;i<StringLen(s);i++){
    int ch=StringGetChar(s,i);
    bool plain = ((ch>='A'&&ch<='Z')||(ch>='a'&&ch<='z')||(ch>='0'&&ch<='9')||ch=='-'||ch=='_'||ch=='.'||ch=='~');
    if(plain) out += StringSubstr(s,i,1);
    else if(ch==' ') out += "%20";
    else out += "%" + StringFormat("%02X",ch);
  }
  return out;
}
void SendTelegramMessage(string text){
  if(!telegram) return;
  string url = URL + "bot" + BotID + "/sendMessage?chat_id=" + ChannelID + "&text=" + UrlEncode(text);
  string result_headers=""; string headers_in="";
  char post[]; char result[];
  for(int k=0;k<3;k++){
    ResetLastError();
    int res = WebRequest("GET", url, headers_in, 7000, post, result, result_headers);
    if(res==200){ Print("TG OK"); return; }
    Print(StringFormat("TG fail: http=%d err=%d try=%d",res,GetLastError(),k+1));
    Sleep(500);
  }
}
string BuildOrderMessage(string symbol,double lots_value,bool isBuy){
  return "\n"+symbol+": "+DoubleToStr(NormalizeDouble(lots_value,2),2)+" "+(isBuy?"\xE2\xAC\x86":"\xE2\xAC\x87");
}
string BuildCloseMessage(bool isBuy){ return isBuy?"Close Buy":"Close Sell"; }

// ----------- utils ----------
void DeleteObjectsWithText(string text){
  int total=ObjectsTotal();
  for (int i=total-1;i>=0;i--){
    string name=ObjectName(i);
    if(StringFind(name,text)!=-1){
      if(ObjectFind(name)!=-1) ObjectDelete(name);
    }
  }
}
bool FileExists(string f){ return FileIsExist(f); }
bool InGlobalTradeWindow(int gmt_hour){
  return ((gmt_hour==0 && Minute()>20 && Minute()<=59) ||
          (gmt_hour>=1 && gmt_hour<7) ||
          (gmt_hour==7 && Minute()>10 && Minute()<=59) ||
          (gmt_hour>=8 && gmt_hour<13) ||
          (gmt_hour==13 && Minute()>=0 && Minute()<30) ||
          (gmt_hour==13 && Minute()>40 && Minute()<=59) ||
          (gmt_hour>=14 && gmt_hour<=23) ||
          (gmt_hour==0 && Minute()>=0 && Minute()<10));
}
bool InSecondPulse(int sec){ return ((sec>=2&&sec<4)||(sec>=14&&sec<16)||(sec>=26&&sec<28)||(sec>=38&&sec<40)||(sec>=50&&sec<52)); }
bool InRange(int m, int a, int b){ return (m>=a && m<b); }
double Pip(){ return PipValue(Symbol()); }

// ----------- D1 correlation ----------
extern int DaysToAnalyze_D1=60;
#define PAIRS_COUNT 1
string pairs_D1[PAIRS_COUNT][2]={"AUDCAD","AUDUSD"};
double avgDiffs_D1[PAIRS_COUNT];

double CalculatePercentageChange_D1(string symbol,int shift_D1){
  double priceStart_D1=iClose(symbol,PERIOD_D1,shift_D1);
  double priceEnd_D1=iClose(symbol,PERIOD_D1,shift_D1-1);
  if(priceStart_D1==0||priceEnd_D1==0)return 0;
  return((priceEnd_D1-priceStart_D1)/priceStart_D1)*100.0;
}
void AnalyzePair_D1(string symbol1,string symbol2,int pairIndex_D1,int yOffset_D1){
  double totalDiff_D1=0;int count_D1=0;
  for(int i_D1=1;i_D1<=DaysToAnalyze_D1;i_D1++){
    double change1_D1=CalculatePercentageChange_D1(symbol1,i_D1);
    double change2_D1=CalculatePercentageChange_D1(symbol2,i_D1);
    if(change1_D1==0||change2_D1==0)continue;
    double diff_D1=MathAbs(change1_D1-change2_D1);
    totalDiff_D1+=diff_D1;count_D1++;
  }
  if(count_D1>0){
    double avgDiff_D1=totalDiff_D1/count_D1;avgDiffs_D1[pairIndex_D1]=avgDiff_D1;
  }
}
double GetSafeValue(double currentValue, double fallbackValue) { return (currentValue==0?fallbackValue:currentValue); }

// ----------- Slots for strategies ----------
void ComputeStrategySlots(int t1_min, bool pr1, bool pr2, bool pr3, bool pr4, bool pr5, double &str_time[]){
  for(int i=1;i<=5;i++) str_time[i]=0;
  if(pr1 && !pr2 && !pr3 && !pr4 && !pr5){ str_time[1]=1; return; }
  if(pr1 && pr2 && !pr3 && !pr4 && !pr5){
    if(InRange(t1_min,0,4)||InRange(t1_min,8,12)||InRange(t1_min,16,20)||InRange(t1_min,24,28)||InRange(t1_min,32,36)||InRange(t1_min,40,44)||InRange(t1_min,48,52)||InRange(t1_min,56,58)) str_time[2]=1; else str_time[1]=1; return;
  }
  if(pr1 && pr2 && pr3 && !pr4 && !pr5){
    if(InRange(t1_min,0,4)||InRange(t1_min,12,16)||InRange(t1_min,24,28)||InRange(t1_min,36,40)||InRange(t1_min,48,52)) str_time[3]=1;
    else if(InRange(t1_min,4,8)||InRange(t1_min,16,20)||InRange(t1_min,28,32)||InRange(t1_min,40,44)||InRange(t1_min,52,56)) str_time[2]=1;
    else str_time[1]=1; return;
  }
  if(pr1 && pr2 && pr3 && pr4 && !pr5){
    if(InRange(t1_min,0,4)||InRange(t1_min,16,20)||InRange(t1_min,32,36)||InRange(t1_min,48,52)) str_time[4]=1;
    else if(InRange(t1_min,4,8)||InRange(t1_min,20,24)||InRange(t1_min,36,40)||InRange(t1_min,52,56)) str_time[3]=1;
    else if(InRange(t1_min,8,12)||InRange(t1_min,24,28)||InRange(t1_min,40,44)||InRange(t1_min,56,58)) str_time[2]=1;
    else str_time[1]=1; return;
  }
  if(pr1 && pr2 && pr3 && pr4 && pr5){
    if(InRange(t1_min,0,4)||InRange(t1_min,20,24)||InRange(t1_min,40,44)) str_time[5]=1;
    else if(InRange(t1_min,4,8)||InRange(t1_min,24,28)||InRange(t1_min,44,48)) str_time[4]=1;
    else if(InRange(t1_min,8,12)||InRange(t1_min,28,32)||InRange(t1_min,48,52)) str_time[3]=1;
    else if(InRange(t1_min,12,16)||InRange(t1_min,32,36)||InRange(t1_min,52,56)) str_time[2]=1;
    else str_time[1]=1; return;
  }
}

// ----------- Split trailing ----------
int TrailingCategory(int count){
  if(count>40) return 6;
  if(count>20) return 5;
  if(count>15) return 4;
  if(count>10) return 3;
  if(count>5)  return 2;
  if(count>2)  return 1;
  return 0;
}
double MinProfitByCat(int cat){
  if(cat==1) return lMinProfit_1;
  if(cat==2) return lMinProfit_2;
  if(cat==3) return lMinProfit_3;
  if(cat==4) return lMinProfit_4;
  if(cat==5) return lMinProfit_5;
  if(cat==6) return lMinProfit_6;
  return 0;
}
void ApplySplitTrailingBuy(){
  if(!trall_order_razdelni) return;
  int cat = TrailingCategory(CountBuy_1());
  if(cat==0) return;

  double p=main.p;
  double minProfit = MinProfitByCat(cat)*p;
  double slTarget  = lTrailingStop_1*p;
  double stepCond  = (lTrailingStop_1 + lTrailingStep_1 - 1)*p;

  int cnt2=OrdersTotal();
  for(int i=0;i<cnt2;i++){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()!=OP_BUY) continue;
    if((Bid-OrderOpenPrice()) > minProfit){
      if(OrderStopLoss() < (Bid - stepCond) || OrderStopLoss()==0){
        bool ok=OrderModify(OrderTicket(),OrderOpenPrice(),Bid - slTarget,OrderTakeProfit(),0,col_3);
        if(!ok) Print("Trailing BUY modify failed, ticket=",OrderTicket()," err=",GetLastError());
      }
    }
  }
}
void ApplySplitTrailingSell(){
  if(!trall_order_razdelni) return;
  int cat = TrailingCategory(CountSell_1());
  if(cat==0) return;

  double p=main.p;
  double minProfit = MinProfitByCat(cat)*p;
  double slTarget  = lTrailingStop_1*p;
  double stepCond  = (lTrailingStop_1 + lTrailingStep_1 - 1)*p;

  int cnt2=OrdersTotal();
  for(int i=0;i<cnt2;i++){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderType()!=OP_SELL) continue;
    if((OrderOpenPrice()-Ask) > minProfit){
      if(OrderStopLoss() > (Ask + stepCond) || OrderStopLoss()==0){
        bool ok=OrderModify(OrderTicket(),OrderOpenPrice(),Ask + slTarget,OrderTakeProfit(),0,col_3);
        if(!ok) Print("Trailing SELL modify failed, ticket=",OrderTicket()," err=",GetLastError());
      }
    }
  }
}

// ----------- Open orders (unified) ----------
bool tryOpen(int side, double mult, string strategyFile, string strategyContent){
  double baseLot = getLot( (side==OP_BUY)? main.orders[OP_BUY] : main.orders[OP_SELL] );
  double lots_to_send = baseLot * mult * par5;
  if(lots_to_send<=0) return false;

  int ticket = main.OrderSend(side, lots_to_send, -1, 0, 0, (string)order_magic);
  if(ticket>0){
    if(strategyFile!="" && ((side==OP_BUY && main.orders[OP_BUY]==0) || (side==OP_SELL && main.orders[OP_SELL]==0))){
      int fh=FileOpen(strategyFile,FILE_WRITE|FILE_TXT);
      if(fh!=INVALID_HANDLE){ FileWriteString(fh, strategyContent); FileClose(fh); }
    }
    if(telegram) SendTelegramMessage(BuildOrderMessage(Symbol(),lots_to_send,(side==OP_BUY)));
    return true;
  }
  return false;
}

// ----------- Counters ----------
int CountBuy(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_BUY) c++; } return c; }
int CountSell(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_SELL) c++; } return c; }
int CountBuy_1(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderType()==OP_BUY) c++; } return c; }
int CountSell_1(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderType()==OP_SELL) c++; } return c; }
int CountBuy_2(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_BUY) c++; } return c; }
int CountSell_2(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){ if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue; if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_SELL) c++; } return c; }

// ----------- min/max open price ----------
double bestMinPrice(){
  double minPrice=1.0e100;
  for(int i=OrdersTotal()-1;i>=0;i--){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()==order_magic){
      if(OrderOpenPrice()<minPrice) minPrice=OrderOpenPrice();
    }
  }
  return (minPrice==1.0e100 ? 0.0 : minPrice);
}
double bestMaxPrice(){
  double maxPrice=0;
  for(int i=OrdersTotal()-1;i>=0;i--){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()==order_magic){
      if(OrderOpenPrice()>maxPrice) maxPrice=OrderOpenPrice();
    }
  }
  return maxPrice;
}

// ----------- delta ----------
double CalculateDelta(string symbol, int period, int shift){
  double priceAsk=MarketInfo(symbol, MODE_ASK);
  double priceBid=MarketInfo(symbol, MODE_BID);
  double priceCurrent=(priceAsk+priceBid) / 2;
  double priceClose=iClose(symbol, period, shift);
  if(priceClose<=0) return 0;
  double priceProc=priceClose / 100.0;
  return (priceCurrent-priceClose) / priceProc;
}

// ========================= TIMER ==============================
// Unified type for step tables (avoid duplicate definitions)
struct StepRange { int from,to; int stepByPr[6]; };

void RecomputeStrongThresholdsByTOD(){
  datetime gmt_time=TimeGMT();
  int gmt_hour=TimeHour(gmt_time);

  double base = delta_AUDCAD_AUDUSD_d;
  double baseTOD = base;
  if((gmt_hour>=0&&gmt_hour<7)||gmt_hour==23) baseTOD=base/st3;
  else if(gmt_hour>=7&&gmt_hour<13)          baseTOD=base/st2;
  else                                       baseTOD=base/st1;

  g_strong[1]=baseTOD*st_delta_1*koeff_delta;
  g_strong[2]=baseTOD*st_delta_2*koeff_delta;
  g_strong[3]=baseTOD*st_delta_3*koeff_delta;
  g_strong[4]=baseTOD*st_delta_4*koeff_delta;
  g_strong[5]=baseTOD*st_delta_5*koeff_delta;
}

// Arrays in parameters must be "by reference" in MQL4
int ComputeNextStep(bool isBuy, int countAllSide, bool &pr[]){
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

  if(isBuy){
    for(int i=0;i<ArraySize(RangesBuy);i++){
      if(countAllSide>=RangesBuy[i].from && countAllSide<RangesBuy[i].to){
        for(int prn=1; prn<=5; prn++){
          if(pr[prn]) return RangesBuy[i].stepByPr[prn];
        }
        return 0;
      }
    }
  }else{
    for(int i=0;i<ArraySize(RangesSell);i++){
      if(countAllSide>=RangesSell[i].from && countAllSide<RangesSell[i].to){
        for(int prn=1; prn<=5; prn++){
          if(pr[prn]) return RangesSell[i].stepByPr[prn];
        }
        return 0;
      }
    }
  }
  return 0;
}

void OnTimer(){
  // 1) Flags pr1..pr5
  g_pr[1]=FileExists("str_pr1.txt");
  g_pr[2]=FileExists("str_pr2.txt");
  g_pr[3]=FileExists("str_pr3.txt");
  g_pr[4]=FileExists("str_pr4.txt");
  g_pr[5]=FileExists("str_pr5.txt");

  // 2) Deltas D1 and 20D
  g_delta_AUDCAD_D1_cache = CalculateDelta("AUDCAD",PERIOD_D1,1);
  g_delta_AUDUSD_D1_cache = CalculateDelta("AUDUSD",PERIOD_D1,1);
  g_delta_AUDCAD_20D_cache = CalculateDelta("AUDCAD",PERIOD_D1,DaysForMonthlyProxy);
  g_delta_AUDUSD_20D_cache = CalculateDelta("AUDUSD",PERIOD_D1,DaysForMonthlyProxy);
  g_delta_abs_20D_cache   = MathAbs(g_delta_AUDCAD_20D_cache - g_delta_AUDUSD_20D_cache);

  // 3) Correlation D1 proxy for base
  for(int i=0;i<PAIRS_COUNT;i++){
    AnalyzePair_D1(pairs_D1[i][0], pairs_D1[i][1], i, 0);
    if(avgDiffs_D1[i]==0) avgDiffs_D1[i]=GetSafeValue(avgDiffs_D1[i],0.2);
    if(i==0) delta_AUDCAD_AUDUSD_d = avgDiffs_D1[i];
  }

  // 4) Strong thresholds by time-of-day
  RecomputeStrongThresholdsByTOD();

  // 5) Strategy slots
  ArrayInitialize(g_str_time,0.0);
  int gmt_hour=TimeHour(TimeGMT());
  int tmin = Minute();
  if(InGlobalTradeWindow(gmt_hour)){
    double tmp[6]; ArrayInitialize(tmp,0.0);
    ComputeStrategySlots(tmin, g_pr[1],g_pr[2],g_pr[3],g_pr[4],g_pr[5], tmp);
    for(int i=1;i<=5;i++) g_str_time[i]=tmp[i];
  }

  // 6) Counters and steps via unified steps_unified.mqh
  g_countBuyAll    = CountBuy_1();
  g_countSellAll   = CountSell_1();
  g_countBuyMagic2 = CountBuy_2();
  g_countSellMagic2= CountSell_2();

  // Call unified step computation (updates g_next_step_buy/sell and g_next_step_buy_px/sell_px)
  Steps_OnTimer(g_countBuyAll, g_countSellAll);

  g_cache_updated_at = TimeCurrent();
}

// ========================= INIT/DEINIT =======================
int OnInit(){
  main.init(Symbol(),order_magic,slippage);
  // Lots
  lots[0]=lot1;lots[1]=lot2;lots[2]=lot3;lots[3]=lot4;lots[4]=lot5;lots[5]=lot6;lots[6]=lot7;lots[7]=lot8;lots[8]=lot9;lots[9]=lot10;
  lots[10]=lot11;lots[11]=lot12;lots[12]=lot13;lots[13]=lot14;lots[14]=lot15;lots[15]=lot16;lots[16]=lot17;lots[17]=lot18;lots[18]=lot19;lots[19]=lot20;
  lots[20]=lot21;lots[21]=lot22;lots[22]=lot23;lots[23]=lot24;lots[24]=lot25;lots[25]=lot26;lots[26]=lot27;lots[27]=lot28;lots[28]=lot29;lots[29]=lot30;
  lots[30]=lot31;lots[31]=lot32;lots[32]=lot33;lots[33]=lot34;lots[34]=lot35;lots[35]=lot36;lots[36]=lot37;lots[37]=lot38;lots[38]=lot39;lots[39]=lot40;
  lots[40]=lot41;lots[41]=lot42;lots[42]=lot43;lots[43]=lot44;lots[44]=lot45;lots[45]=lot46;lots[46]=lot47;lots[47]=lot48;lots[48]=lot49;lots[49]=lot50;

  // Chart cosmetics
  ChartSetInteger(0,CHART_MODE,CHART_CANDLES);
  ChartSetInteger(0,CHART_SHIFT,1);
  ChartSetInteger(0,CHART_AUTOSCROLL,1);
  ChartSetInteger(0,CHART_SHOW_GRID,1);
  ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,1);
  ChartSetInteger(0,CHART_COLOR_GRID,C'45,48,49');
  ChartSetInteger(0,CHART_COLOR_CHART_UP,col_2);
  ChartSetInteger(0,CHART_COLOR_CHART_DOWN,col_15);
  ChartSetInteger(0,CHART_COLOR_CHART_LINE,col_15);
  ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,col_2);
  ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,col_15);
  ChartSetInteger(0,CHART_COLOR_BID,col_15);
  ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,col_6);
  ChartSetInteger(0,CHART_COLOR_VOLUME,col_18);
  ChartSetInteger(0,CHART_SCALE,5);
  ChartSetInteger(0,CHART_SHOW_OHLC,0);
  ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,0);
  ChartSetInteger(0,CHART_COLOR_FOREGROUND,C'80,85,86');
  ChartSetSymbolPeriod(0,Symbol(),PERIOD_D1);

  // Initialize cooldown arrays
  ArrayInitialize(g_lastOpenBuy, 0);
  ArrayInitialize(g_lastOpenSell, 0);

  EventSetTimer(60);
  OnTimer(); // warm up cache immediately
  return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
  EventKillTimer();
}

// ========================= TICK ============================
int OpToTier(int op){ int a=MathAbs(op); return (a>=10 ? a/11 : a); }
bool CooldownOk(bool isBuy,int tier){
  if(OpenCooldownSec<=0) return true;
  datetime last = isBuy ? g_lastOpenBuy[tier] : g_lastOpenSell[tier];
  if(TimeCurrent() - last < OpenCooldownSec) return false;
  if(isBuy) g_lastOpenBuy[tier] = TimeCurrent();
  else      g_lastOpenSell[tier] = TimeCurrent();
  return true;
}

void OnTick(){

  GlobalVariableSet(BOT_NAME + "_Alive", TimeCurrent());

  datetime gmt_time=TimeGMT();
  int gmt_hour=TimeHour(gmt_time);

  // Title label
  if(ObjectFind(0,"name_expert")==-1){
    ObjectCreate("name_expert",OBJ_LABEL,0,0,0);
    ObjectSetString(0,"name_expert",OBJPROP_TOOLTIP,"\n");
    ObjectSet("name_expert", OBJPROP_CORNER, 0);
    ObjectSet("name_expert", OBJPROP_XDISTANCE, 75);
    ObjectSet("name_expert",OBJPROP_YDISTANCE,0);
  }
  ObjectSetText("name_expert",WindowExpertName(),10,TextFONT,col_9);

  // Step lines using cached steps
  double last_step_buy_11=0, last_step_sell_11=0;
  if(CountBuy()>=1){
    double step_buy_11_local = bestMaxPrice()+g_next_step_buy_px;
    if(MathAbs(step_buy_11_local-last_step_buy_11)>Point){
      last_step_buy_11=step_buy_11_local;
      if(ObjectFind(0,"step_buy_11")==-1) ObjectCreate(0,"step_buy_11",OBJ_HLINE,0,0,step_buy_11_local);
      else ObjectSetDouble(0,"step_buy_11",OBJPROP_PRICE,step_buy_11_local);
      ObjectSetString(0,"step_buy_11",OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,"step_buy_11",OBJPROP_COLOR,col_1);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_STYLE,2);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_BACK,true);

      if(ObjectFind(0,"MaxPrice")==-1) ObjectCreate(0,"MaxPrice",OBJ_TEXT,0,TimeCurrent(),step_buy_11_local);
      ObjectSetDouble(0,"MaxPrice",OBJPROP_PRICE,step_buy_11_local);
      ObjectSetInteger(0,"MaxPrice",OBJPROP_TIME,TimeCurrent());
      ObjectSetInteger(0,"MaxPrice",OBJPROP_BACK,true);
      ObjectSetText("MaxPrice",DoubleToStr(NormalizeDouble(step_buy_11_local,5),5),10,TextFONT,col_1);
    }
  }
  if(CountSell()>=1){
    double step_sell_11_local = bestMinPrice()-g_next_step_sell_px;
    if(MathAbs(step_sell_11_local-last_step_sell_11)>Point){
      last_step_sell_11=step_sell_11_local;
      if(ObjectFind(0,"step_sell_11")==-1) ObjectCreate(0,"step_sell_11",OBJ_HLINE,0,0,step_sell_11_local);
      else ObjectSetDouble(0,"step_sell_11",OBJPROP_PRICE,step_sell_11_local);
      ObjectSetString(0,"step_sell_11",OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,"step_sell_11",OBJPROP_COLOR,col_1);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_STYLE,2);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_BACK,true);

      if(ObjectFind(0,"MinPrice")==-1) ObjectCreate(0,"MinPrice",OBJ_TEXT,0,TimeCurrent(),step_sell_11_local);
      ObjectSetDouble(0,"MinPrice",OBJPROP_PRICE,step_sell_11_local);
      ObjectSetInteger(0,"MinPrice",OBJPROP_TIME,TimeCurrent());
      ObjectSetInteger(0,"MinPrice",OBJPROP_BACK,true);
      ObjectSetText("MinPrice",DoubleToStr(NormalizeDouble(step_sell_11_local,5),5),10,TextFONT,col_1);
    }
  }

  // Strategy files
  string filename1="str1.txt",content1="str1";
  string filename2="str2.txt",content2="str2";
  string filename3="str3.txt",content3="str3";
  string filename4="str4.txt",content4="str4";
  string filename5="str5.txt",content5="str5";
  string filename="close_all.txt",content_filename="Where is my money?";

  // Background by position
  if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'10,10,46'));
  if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'51,0,0'));
  if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'0,23,0'));
  if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0) ChartSetInteger(0,CHART_COLOR_BACKGROUND,col_17);

  // HelpAccount
  string HelpAcc = "HelpAccount.txt";string content_HelpAcc = "";
  int fh2 = FileOpen(HelpAcc,FILE_READ);
  if (fh2 != INVALID_HANDLE){ content_HelpAcc = FileReadString(fh2); HelpAccount = StrToDouble(content_HelpAcc); FileClose(fh2); }

  // Clean objects when needed
  if(CountSell()<=0){
    if(ObjectFind(0,"step_sell_11")!=-1)ObjectDelete(0,"step_sell_11");
    if(ObjectFind(0,"MinPrice")!=-1)ObjectDelete(0,"MinPrice");
    minSellPrice=0;
  }
  if(CountBuy()<=0){
    if(ObjectFind(0,"step_buy_11")!=-1)ObjectDelete(0,"step_buy_11");
    if(ObjectFind(0,"MaxPrice")!=-1)ObjectDelete(0,"MaxPrice");
    maxBuyPrice=0;
  }

  // Cached deltas and thresholds
  double delta_AUDCAD_D1 = g_delta_AUDCAD_D1_cache;
  double delta_AUDUSD_D1 = g_delta_AUDUSD_D1_cache;
  double delta_AUDCAD_20D = g_delta_AUDCAD_20D_cache;
  double delta_AUDUSD_20D = g_delta_AUDUSD_20D_cache;
  double delta_AUDCAD_AUDUSD_20D_abs = g_delta_abs_20D_cache;
  double strong1 = g_strong[1], strong2=g_strong[2], strong3=g_strong[3], strong4=g_strong[4], strong5=g_strong[5];

  // Slots
  str1_time=g_str_time[1]; str2_time=g_str_time[2]; str3_time=g_str_time[3]; str4_time=g_str_time[4]; str5_time=g_str_time[5];
  if(OrdersTotal()>=1){str1_time=0;str2_time=0;str3_time=0;str4_time=0;str5_time=0;}

  // Balance scaling
  double balance_real=(standart ? (AccountBalance()+bonus)/100.0 : AccountBalance()+bonus);
  if(balance_real<=100) max_lot=30; else if(balance_real<150) max_lot=40; else if(balance_real<200) max_lot=60; else max_lot=80;

  // Side profits
  double profit_buy=0, profit_sell=0;
  for(int ib=0; ib<OrdersTotal(); ib++){
    if(OrderSelect(ib, SELECT_BY_POS, MODE_TRADES)){
      if(OrderMagicNumber()==order_magic){
        if(OrderType()==OP_BUY) profit_buy+=OrderProfit()+OrderCommission()+OrderSwap();
      }
    }
  }
  for(int is=0; is<OrdersTotal(); is++){
    if(OrderSelect(is, SELECT_BY_POS, MODE_TRADES)){
      if(OrderMagicNumber()==order_magic){
        if(OrderType()==OP_SELL) profit_sell+=OrderProfit()+OrderCommission()+OrderSwap();
      }
    }
  }

  // Equity %
  double tb=AccountBalance()+bonus,tr=AccountProfit(),trr_tr=tr*100.0/tb;
  trr=tr*100.0/tb;
  if(HelpAccount!=0) trr=(AccountEquity()-HelpAccount)/(HelpAccount/100.0);

  // Lot scale by equity
  if(OrdersTotal()<1||(OrdersTotal()>=1&&start_balance==0)) start_balance=AccountEquity();
  double factor=2.0;
  if(start_balance<=start_um*20)factor=1.0;
  else if(start_balance<=start_um*40)factor=1.2;
  else if(start_balance<=start_um*60)factor=1.6;
  par5 = start_balance/(start_um*factor);
  if(par5>200)par5=200;

  // Trade environment
  if(!work_check()) return;
  int all=main.Update(),op=0,idirect;
  double p=main.p,lot,avg;

  // Split trailing + common trailing
  ApplySplitTrailingBuy();
  ApplySplitTrailingSell();

  if(trall_order_all==true){
    if(CountBuy_1()<=2){
      avg=main.get_Average(OP_BUY,idirect);
      if(CountBuy()>=1 && avg>0 && idirect==1 && trailing_stop_pr>0 && Bid>avg+trailing_stop_pr*p){
        main.groupTrailingStop(OP_BUY,Bid-trailing_stop_pr*p);
      }
    }
    if(CountSell_1()<=2){
      avg=main.get_Average(OP_SELL,idirect);
      if(CountSell()>=1 && avg>0 && idirect==-1 && trailing_stop_pr>0 && Ask<avg-trailing_stop_pr*p){
        main.groupTrailingStop(OP_SELL,Ask+trailing_stop_pr*p);
      }
    }
  }

  // Heartbeat icon
  int t1_sec=Seconds();
  int t1_min=Minute();
  color Color_tch_al=(t1_sec % 2 < 1) ? (C'255,242,170') : col_5;
  if(ObjectFind(0,"working_t1")==-1){
    ObjectCreate ("working_t1",OBJ_LABEL,0,0,0);
    ObjectSetInteger(0,"working_t1",OBJPROP_BACK,false);
    ObjectSetString(0,"working_t1",OBJPROP_TOOLTIP,"\n");
    ObjectSet("working_t1",OBJPROP_CORNER, 1);ObjectSet("working_t1", OBJPROP_ANGLE, 0);
    ObjectSet("working_t1",OBJPROP_YDISTANCE,-2);ObjectSet("working_t1",OBJPROP_XDISTANCE,4);
  }
  ObjectSetText("working_t1", CharToStr(108), 14, "Wingdings", Color_tch_al);

  double Highest_m=iHigh(NULL,PERIOD_M1,1),Lowest_m=iLow(NULL,PERIOD_M1,1);

  // Profit closes
  if(close_profit_buy && CountBuy_1()>=1 && profit_buy>(c777*par5) && (trr_tr<(-5))) op=-777;
  if(close_profit_sell&& CountSell_1()>=1 && profit_sell>(c777*par5) && (trr_tr<(-5))) op=777;

  // Dynamic delta sampling windows (original logic kept)
  if((gmt_hour==00&&Minute()==10)||(gmt_hour==07&&Minute()==00)||(gmt_hour==13&&Minute()==30)){
    delta_AUDCAD_AUDUSD_1=0; delta_AUDCAD_AUDUSD_2=0; delta_AUDCAD_AUDUSD_3=0; delta_AUDCAD_AUDUSD_4=0; delta_AUDCAD_AUDUSD_5=0; delta_AUDCAD_AUDUSD_average=0;
  }
  if((gmt_hour==00&&Minute() >10&&Minute()<12)||(gmt_hour==07&&Minute() >00&&Minute()<02)||(gmt_hour==13&&Minute() >30&&Minute()<32)){
    if(delta_AUDCAD_AUDUSD_1==0)delta_AUDCAD_AUDUSD_1=MathAbs(g_delta_AUDCAD_D1_cache-g_delta_AUDUSD_D1_cache);
  }
  if((gmt_hour==00&&Minute()>=12&&Minute()<14)||(gmt_hour==07&&Minute()>=02&&Minute()<04)||(gmt_hour==13&&Minute()>=32&&Minute()<34)){
    if(delta_AUDCAD_AUDUSD_2==0)delta_AUDCAD_AUDUSD_2=MathAbs(g_delta_AUDCAD_D1_cache-g_delta_AUDUSD_D1_cache);
  }
  if((gmt_hour==00&&Minute()>=14&&Minute()<16)||(gmt_hour==07&&Minute()>=04&&Minute()<06)||(gmt_hour==13&&Minute()>=34&&Minute()<36)){
    if(delta_AUDCAD_AUDUSD_3==0)delta_AUDCAD_AUDUSD_3=MathAbs(g_delta_AUDCAD_D1_cache-g_delta_AUDUSD_D1_cache);
  }
  if((gmt_hour==00&&Minute()>=16&&Minute()<18)||(gmt_hour==07&&Minute()>=06&&Minute()<08)||(gmt_hour==13&&Minute()>=36&&Minute()<38)){
    if(delta_AUDCAD_AUDUSD_4==0)delta_AUDCAD_AUDUSD_4=MathAbs(g_delta_AUDCAD_D1_cache-g_delta_AUDUSD_D1_cache);
  }
  if((gmt_hour==00&&Minute()>=18&&Minute()<20)||(gmt_hour==07&&Minute()>=08&&Minute()<10)||(gmt_hour==13&&Minute()>=38&&Minute()<40)){
    if(delta_AUDCAD_AUDUSD_5==0)delta_AUDCAD_AUDUSD_5=MathAbs(g_delta_AUDCAD_D1_cache-g_delta_AUDUSD_D1_cache);
  }
  if((gmt_hour==00&&Minute()==20)||(gmt_hour==07&&Minute()==10)||(gmt_hour==13&&Minute()==40)){
    if(delta_AUDCAD_AUDUSD_average==0)delta_AUDCAD_AUDUSD_average=MathMax(delta_AUDCAD_AUDUSD_1,MathMax(delta_AUDCAD_AUDUSD_2,MathMax(delta_AUDCAD_AUDUSD_3,MathMax(delta_AUDCAD_AUDUSD_4,delta_AUDCAD_AUDUSD_5))));
  }
  if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){
    if(delta_AUDCAD_AUDUSD_average==0)delta_AUDCAD_AUDUSD_average=delta_AUDCAD_AUDUSD;
  }

  // Primary op from slots
  int tiers[5]; ArrayInitialize(tiers,0); tiers[0]=1; tiers[1]=2; tiers[2]=3; tiers[3]=4; tiers[4]=5;
  int op_from_slots=0;
  if(FileExists(filename) && master && AUDCAD_AUDUSD){
    if(InGlobalTradeWindow(gmt_hour) && InSecondPulse(t1_sec) && OrdersTotal()<1){
      double lower[5], upper[5];
      lower[0]=strong1; lower[1]=strong2; lower[2]=strong3; lower[3]=strong4; lower[4]=strong5;
      upper[0]=strong2; upper[1]=strong3; upper[2]=strong4; upper[3]=strong5; upper[4]=1.0e9;
      for(int idx=0; idx<5; idx++){
        int t=tiers[idx];
        bool slotOn = ((t==1 && str1_time==1) || (t==2 && str2_time==1) || (t==3 && str3_time==1) || (t==4 && str4_time==1) || (t==5 && str5_time==1));
        string sfile=(t==1?filename1:(t==2?filename2:(t==3?filename3:(t==4?filename4:filename5))));
        if(slotOn && !FileExists(sfile)){
          if(delta_AUDCAD_AUDUSD_20D_abs>=lower[idx] && delta_AUDCAD_AUDUSD_20D_abs<upper[idx]){
            bool dailyOK = (MathAbs(delta_AUDCAD_D1 - delta_AUDUSD_D1) >= delta_AUDCAD_AUDUSD_average/delta_average);
            if(dailyOK){
              if(delta_AUDCAD_20D > delta_AUDUSD_20D) op_from_slots = -t;
              if(delta_AUDCAD_20D < delta_AUDUSD_20D) op_from_slots =  t;
            }
          }
        }
      }
    }
  }

  // Secondary conditions (grid adds and breakouts)
  if(FileExists(filename) && master && AUDCAD_AUDUSD){
    for(int i=0; i<OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        if(OrderMagicNumber()==4||OrderMagicNumber()==5||OrderMagicNumber()==6){
          for(int idx=0; idx<5; idx++){
            int t=tiers[idx];
            string sfile=(t==1?filename1:(t==2?filename2:(t==3?filename3:(t==4?filename4:filename5))));
            if(FileExists(sfile)){
              if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-t;
              if((AccountBalance()+bonus>AccountEquity()) && CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<(bestMinPrice()-g_next_step_sell_px)&&Bid<Lowest_m) op=-(t*11);

              if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=t;
              if((AccountBalance()+bonus>AccountEquity()) && CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>(bestMaxPrice()+g_next_step_buy_px)&&Ask>Highest_m) op=(t*11);
            }
          }
        }
      }
    }
  }

  if(op==0) op=op_from_slots;

  // Re-entries by step (pips) with cooldown
  if(op==1||op==2||op==3||op==4||op==5){
    int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
    if(main.OrderSelect(t_b) && main.OrderProfitPoint(t_b)<=-g_next_step_buy){
      int tier=OpToTier(op);
      if(CooldownOk(true,tier)){
        double mult=(op==1?st1:(op==2?st2:(op==3?st3:(op==4?st4:st5))));
        tryOpen(OP_BUY,mult,"","");
      }
    }
  }
  if(op==-1||op==-2||op==-3||op==-4||op==-5){
    int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
    if(main.OrderSelect(t_s) && main.OrderProfitPoint(t_s)<=-g_next_step_sell){
      int tier=OpToTier(op);
      if(CooldownOk(false,tier)){
        double mult=(op==-1?st1:(op==-2?st2:(op==-3?st3:(op==-4?st4:st5))));
        tryOpen(OP_SELL,mult,"","");
      }
    }
  }

  // Breakout entries with cooldown
  if(op==11||op==22||op==33||op==44||op==55){
    if(Ask>(bestMaxPrice()+g_next_step_buy_px)){
      int tier=OpToTier(op);
      if(CooldownOk(true,tier)){
        double mult=(op==11?st1:(op==22?st2:(op==33?st3:(op==44?st4:st5))));
        tryOpen(OP_BUY,mult,"","");
      }
    }
  }
  if(op==-11||op==-22||op==-33||op==-44||op==-55){
    if(Bid<(bestMinPrice()-g_next_step_sell_px)){
      int tier=OpToTier(op);
      if(CooldownOk(false,tier)){
        double mult=(op==-11?st1:(op==-22?st2:(op==-33?st3:(op==-44?st4:st5))));
        tryOpen(OP_SELL,mult,"","");
      }
    }
  }

  // Group closes
  if(op==777){
    for(int i=OrdersTotal()-1; i>=0; i--){
      if(OrderSelect(i,SELECT_BY_POS)){
        if(OrderMagicNumber()==order_magic&&OrderSymbol()==Symbol()){
          if(OrderType()==OP_SELL){
            if(!OrderClose(OrderTicket(), OrderLots(), Ask, slippage)) printf("SELL Order Close Error %d", GetLastError());
            if(LastActiontime_vline!=Time[0]){
              ObjectCreate("line"+(string)TimeCurrent(),OBJ_VLINE,0,Time[0],0,0);
              ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_3);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);
            }
            LastActiontime_vline=Time[0];
          }
          if(telegram && CountSell()<=0) SendTelegramMessage(BuildCloseMessage(false));
        }
      }
    }
  }
  if(op==-777){
    for(int i=OrdersTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS)){
        if(OrderMagicNumber()==order_magic&&OrderSymbol()==Symbol()){
          if(OrderType()==OP_BUY){
            if(!OrderClose(OrderTicket(), OrderLots(), Bid, slippage)) printf("BUY Order Close Error %d", GetLastError());
            if(LastActiontime_vline!=Time[0]){
              ObjectCreate("line"+(string)TimeCurrent(),OBJ_VLINE,0,Time[0],0,0);
              ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_13);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
              ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);
            }
            LastActiontime_vline=Time[0];
          }
          if(telegram && CountBuy()<=0) SendTelegramMessage(BuildCloseMessage(true));
        }
      }
    }
  }

  // First entries (mark strategy file) with cooldown
  lot=lot1;
  if((op==1||op==11)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st1,filename1,content1); }
  if((op==2||op==22)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st2,filename2,content2); }
  if((op==3||op==33)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st3,filename3,content3); }
  if((op==4||op==44)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st4,filename4,content4); }
  if((op==5||op==55)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st5,filename5,content5); }

  if((op==-1||op==-11)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st1,filename1,content1); }
  if((op==-2||op==-22)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st2,filename2,content2); }
  if((op==-3||op==-33)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st3,filename3,content3); }
  if((op==-4||op==-44)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st4,filename4,content4); }
  if((op==-5||op==-55)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st5,filename5,content5); }
}

// Lot from matrix
double getLot(int idx){
  int c=ArraySize(lots);
  if(c==0)return 0;
  if(idx<0)idx=0;
  if(idx>=c-1)idx=c-1;
  return lots[idx];
}
// EOF