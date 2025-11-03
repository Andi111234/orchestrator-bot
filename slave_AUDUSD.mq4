//+------------------------------------------------------------------+
//|      Copyright 2019, Andrey Tarasov
//+------------------------------------------------------------------+
#property strict
#include "sovetnikov_light.mqh"
#include "steps_unified.mqh"
#include "graphics_common.mqh"

#define BOT_NAME "Bot_4"  // unique EA name

// =============== VISUALIZATION / TELEGRAM ==================
input bool telegram = true;
string URL="https://api.telegram.org/";
extern string ChannelID="419654265";
extern string BotID=""; // put into .set preferably

// one-action-per-bar helper
datetime LastActiontime_vline=StrToTime(TimeToStr(TimeCurrent(),TIME_SECONDS));

// colors
color col_1=Silver,col_2=PapayaWhip,col_3=DeepSkyBlue,col_4=OrangeRed,col_5=Gray,col_6=Lime,col_8=Chocolate,col_9=Orange,col_10=Red,col_11=LightGray,col_12=DarkOrange,col_13=OrangeRed,col_14=White,col_15=DimGray,col_16=Gold,col_17=Black,col_18=DarkGray,col_19=DodgerBlue;

// font
int    FontSize   =10;
string TextFONT   ="Courier New";
int    CORNER     =0;

// ======================= SETTINGS =========================
input bool master        = false;  // this bot acts as slave when false
input bool standart      = false;  // true=standard, false=cent
input bool delta_dinamic = true;   // kept for compatibility
input int  OpenCooldownSec = 2;    // 0 = disable cooldown

bool AUDCAD_AUDUSD       = true;   // pair switch

// Account / scale
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

double c23=400;  // reverse/equity gates (as in original)
double c24=50;
double c777=200; // profit-close threshold

// Magics
int order_magic=5,order_magic_2=6; // AUDUSD

// ======================= GRID / TRAILING ==================
bool close_profit_buy     = true;
bool close_profit_sell    = true;

bool takeprofit_stoploss  = false;
bool trall_order_all      = true;
bool trall_order_razdelni = true;

double lMinProfit_1=8,lMinProfit_2=10,lMinProfit_3=18,lMinProfit_4=32,lMinProfit_5=42,lMinProfit_6=62;
double lTrailingStop_1=4,lTrailingStep_1=2;

double trailing_stop_pr=6;

// Buffers
double step_buy_11=0,step_sell_11=0,next_step_buy=0,next_step_sell=0,next_step_buy_11=0,next_step_sell_11=0,start_balance=0,max_lot=0,stoploss=0,stoploss1=0,takeprofit=0,takeprofit1=0,koeff_balance=0,t_p=0,s_l=0,HelpAccount=0,minSellPrice=0,maxBuyPrice=0,trr=0;
double par5=1;

int slippage=100;

// --------------- helpers / infra -------------------------
class CMain: public GOrders{
public:
  CMain(){} ~CMain(){}
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

// Counts
int CountBuy(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_BUY)c++;} return c;}
int CountSell(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_SELL)c++;} return c;}
int CountBuy_1(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderType()==OP_BUY)c++;} return c;}
int CountSell_1(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderType()==OP_SELL)c++;} return c;}
int CountBuy_2(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_BUY)c++;} return c;}
int CountSell_2(){int c=0; for(int i=OrdersTotal()-1;i>=0;i--){if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue; if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_SELL)c++;} return c;}

// best min/max open prices for our magic
double bestMinPrice(){
  double minP=1.0e100;
  for(int i=OrdersTotal()-1;i>=0;i--){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderMagicNumber()==order_magic && OrderSymbol()==Symbol()){
      if(OrderOpenPrice()<minP) minP=OrderOpenPrice();
    }
  }
  return (minP==1.0e100? 0.0 : minP);
}
double bestMaxPrice(){
  double maxP=0;
  for(int i=OrdersTotal()-1;i>=0;i--){
    if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
    if(OrderMagicNumber()==order_magic && OrderSymbol()==Symbol()){
      if(OrderOpenPrice()>maxP) maxP=OrderOpenPrice();
    }
  }
  return maxP;
}

bool FileExists(string f){ return (FileIsExist(f,0)>=1); }
double PipValueLocal(string sym){
  int digits = (int)MarketInfo(sym, MODE_DIGITS);
  int mult = 1;
  if(digits==3 || digits==5 || MarketInfo(sym,MODE_PROFITCALCMODE)==1) mult=10;
  return mult*MarketInfo(sym, MODE_POINT);
}

// Telegram helpers
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
  string result_headers="", headers_in="";
  char post[], result[];
  for(int k=0;k<3;k++){
    ResetLastError();
    int res = WebRequest("GET", url, headers_in, 7000, post, result, result_headers);
    if(res==200){ Print("TG OK"); return; }
    Print(StringFormat("TG fail: http=%d err=%d try=%d",res,GetLastError(),k+1));
    Sleep(300);
  }
}
string BuildEquityMessage_buy(){ string text=""; if(OrdersTotal()>0){ text+="\n"+(string)OrderSymbol(); text+=": "+(string)DoubleToStr(NormalizeDouble(OrderLots(),2),2); text+=" \xE2\xAC\x86"; } return text; }
string BuildEquityMessage_sell(){ string text=""; if(OrdersTotal()>0){ text+="\n"+(string)OrderSymbol(); text+=": "+(string)DoubleToStr(NormalizeDouble(OrderLots(),2),2); text+=" \xE2\xAC\x87"; } return text; }
string BuildEquityMessage_7(){ return "Закр.поз Buy"; }
string BuildEquityMessage_8(){ return "Закр.поз Sell"; }

// ---------- Try open (unified) ----------
bool tryOpen(int side, double mult){
  double baseLot = getLot( (side==OP_BUY)? main.orders[OP_BUY] : main.orders[OP_SELL] );
  double lots_to_send = baseLot * mult * par5;
  if(lots_to_send<=0) return false;
  int ticket = main.OrderSend(side, lots_to_send, -1, 0, 0, (string)order_magic);
  if(ticket>0){
    if(telegram){
      if(side==OP_BUY) SendTelegramMessage(BuildEquityMessage_buy());
      else             SendTelegramMessage(BuildEquityMessage_sell());
    }
    return true;
  }
  return false;
}

// ---------- Cooldown ----------
datetime g_lastOpenBuy[6], g_lastOpenSell[6];
int OpToTier(int op){ int a=MathAbs(op); return (a>=10 ? a/11 : a); }
bool CooldownOk(bool isBuy,int tier){
  if(OpenCooldownSec<=0) return true;
  datetime last = isBuy ? g_lastOpenBuy[tier] : g_lastOpenSell[tier];
  if(TimeCurrent() - last < OpenCooldownSec) return false;
  if(isBuy) g_lastOpenBuy[tier] = TimeCurrent();
  else      g_lastOpenSell[tier] = TimeCurrent();
  return true;
}

// =================== TIMER-BASED CACHE ===================
// pr flags (as in master) from str_pr*.txt
bool g_pr[6]; // 1..5

// counters snapshot
int g_countBuyAll=0, g_countSellAll=0;
int g_prev_countBuyAll=-1, g_prev_countSellAll=-1;

// steps cache (now from steps_unified.mqh)
// double g_next_step_buy=0, g_next_step_sell=0;     // pips
// double g_next_step_buy_px=0, g_next_step_sell_px=0; // price

// Master-identical StepRange and ComputeNextStep (now replaced by steps_unified.mqh)
// struct StepRange { int from,to; int stepByPr[6]; };

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
        for(int prn=1; prn<=5; prn++){ if(pr[prn]) return RangesBuy[i].stepByPr[prn]; }
        return 0;
      }
    }
  }else{
    for(int i=0;i<ArraySize(RangesSell);i++){
      if(countAllSide>=RangesSell[i].from && countAllSide<RangesSell[i].to){
        for(int prn=1; prn<=5; prn++){ if(pr[prn]) return RangesSell[i].stepByPr[prn]; }
        return 0;
      }
    }
  }
  return 0;
}

void RecomputeStepsIfNeeded(){
  g_countBuyAll  = CountBuy_1();
  g_countSellAll = CountSell_1();
  bool need = (g_prev_countBuyAll!=g_countBuyAll) || (g_prev_countSellAll!=g_countSellAll);
  if(!need) return;

  g_next_step_buy  = ComputeNextStep(true,  g_countBuyAll,  g_pr);
  g_next_step_sell = ComputeNextStep(false, g_countSellAll, g_pr);
  double pip = PipValueLocal(Symbol());
  g_next_step_buy_px  = g_next_step_buy  * pip;
  g_next_step_sell_px = g_next_step_sell * pip;

  g_prev_countBuyAll  = g_countBuyAll;
  g_prev_countSellAll = g_countSellAll;
}

void OnTimer(){
  // read pr1..pr5 flags
  g_pr[1]=FileExists("str_pr1.txt");
  g_pr[2]=FileExists("str_pr2.txt");
  g_pr[3]=FileExists("str_pr3.txt");
  g_pr[4]=FileExists("str_pr4.txt");
  g_pr[5]=FileExists("str_pr5.txt");

  // recompute steps via unified steps_unified.mqh
  g_countBuyAll  = CountBuy_1();
  g_countSellAll = CountSell_1();
  Steps_OnTimer(g_countBuyAll, g_countSellAll);
}
}

// =================== INIT / DEINIT =======================
int OnInit(){
  main.init(Symbol(),order_magic,slippage);

  // lot table
  lots[0]=lot1;lots[1]=lot2;lots[2]=lot3;lots[3]=lot4;lots[4]=lot5;lots[5]=lot6;lots[6]=lot7;lots[7]=lot8;lots[8]=lot9;lots[9]=lot10;
  lots[10]=lot11;lots[11]=lot12;lots[12]=lot13;lots[13]=lot14;lots[14]=lot15;lots[15]=lot16;lots[16]=lot17;lots[17]=lot18;lots[18]=lot19;lots[19]=lot20;
  lots[20]=lot21;lots[21]=lot22;lots[22]=lot23;lots[23]=lot24;lots[24]=lot25;lots[25]=lot26;lots[26]=lot27;lots[27]=lot28;lots[28]=lot29;lots[29]=lot30;
  lots[30]=lot31;lots[31]=lot32;lots[32]=lot33;lots[33]=lot34;lots[34]=lot35;lots[35]=lot36;lots[36]=lot37;lots[37]=lot38;lots[38]=lot39;lots[39]=lot40;
  lots[40]=lot41;lots[41]=lot42;lots[42]=lot43;lots[43]=lot44;lots[44]=lot45;lots[45]=lot46;lots[46]=lot47;lots[47]=lot48;lots[48]=lot49;lots[49]=lot50;

  // chart defaults
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
  OnTimer(); // warm-up cache
  return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){ EventKillTimer(); }

// ============================ TICK ========================
void OnTick(){
  GlobalVariableSet(BOT_NAME + "_Alive", TimeCurrent());

  // Title label
  if(ObjectFind(0,"name_expert")==-1){
    ObjectCreate("name_expert",OBJ_LABEL,0,0,0);
    ObjectSetString(0,"name_expert",OBJPROP_TOOLTIP,"\n");
    ObjectSet("name_expert", OBJPROP_CORNER, 0);
    ObjectSet("name_expert", OBJPROP_XDISTANCE, 75);
    ObjectSet("name_expert",OBJPROP_YDISTANCE,0);
  }
  ObjectSetText("name_expert",WindowExpertName(),10,TextFONT,col_9);

  // Time (GMT)
  datetime gmt_time=TimeGMT();
  int gmt_hour=TimeHour(gmt_time);

  // Draw/update step lines using cached step distances
  double last_step_buy_11_loc=0, last_step_sell_11_loc=0;
  if(CountBuy()>=1){
    step_buy_11 = bestMaxPrice() + g_next_step_buy_px;
    if(MathAbs(step_buy_11-last_step_buy_11_loc)>Point){
      last_step_buy_11_loc=step_buy_11;
      if(ObjectFind(0,"step_buy_11")==-1) ObjectCreate(0,"step_buy_11",OBJ_HLINE,0,0,step_buy_11);
      else ObjectSetDouble(0,"step_buy_11",OBJPROP_PRICE,step_buy_11);
      ObjectSetString(0,"step_buy_11",OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,"step_buy_11",OBJPROP_COLOR,col_1);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_STYLE,2);
      ObjectSetInteger(0,"step_buy_11",OBJPROP_BACK,true);

      if(ObjectFind(0,"MaxPrice")==-1) ObjectCreate(0,"MaxPrice",OBJ_TEXT,0,TimeCurrent(),step_buy_11);
      ObjectSetDouble(0,"MaxPrice",OBJPROP_PRICE,step_buy_11);
      ObjectSetInteger(0,"MaxPrice",OBJPROP_TIME,TimeCurrent());
      ObjectSetInteger(0,"MaxPrice",OBJPROP_BACK,true);
      ObjectSetText("MaxPrice",DoubleToStr(NormalizeDouble(step_buy_11,5),5),10,TextFONT,col_1);
    }
  }
  if(CountSell()>=1){
    step_sell_11 = bestMinPrice() - g_next_step_sell_px;
    if(MathAbs(step_sell_11-last_step_sell_11_loc)>Point){
      last_step_sell_11_loc=step_sell_11;
      if(ObjectFind(0,"step_sell_11")==-1) ObjectCreate(0,"step_sell_11",OBJ_HLINE,0,0,step_sell_11);
      else ObjectSetDouble(0,"step_sell_11",OBJPROP_PRICE,step_sell_11);
      ObjectSetString(0,"step_sell_11",OBJPROP_TOOLTIP,"\n");
      ObjectSetInteger(0,"step_sell_11",OBJPROP_COLOR,col_1);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_STYLE,2);
      ObjectSetInteger(0,"step_sell_11",OBJPROP_BACK,true);

      if(ObjectFind(0,"MinPrice")==-1) ObjectCreate(0,"MinPrice",OBJ_TEXT,0,TimeCurrent(),step_sell_11);
      ObjectSetDouble(0,"MinPrice",OBJPROP_PRICE,step_sell_11);
      ObjectSetInteger(0,"MinPrice",OBJPROP_TIME,TimeCurrent());
      ObjectSetInteger(0,"MinPrice",OBJPROP_BACK,true);
      ObjectSetText("MinPrice",DoubleToStr(NormalizeDouble(step_sell_11,5),5),10,TextFONT,col_1);
    }
  }

  // Background by position
  if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'10,10,46'));
  if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'51,0,0'));
  if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1) ChartSetInteger(0,CHART_COLOR_BACKGROUND,(C'0,23,0'));
  if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0) ChartSetInteger(0,CHART_COLOR_BACKGROUND,col_17);

  // HelpAccount
  string HelpAcc = "HelpAccount.txt"; string content_HelpAcc = "";
  int fileHandle2 = FileOpen(HelpAcc,FILE_READ);
  if (fileHandle2 != INVALID_HANDLE){
    content_HelpAcc = FileReadString(fileHandle2);
    HelpAccount = StrToDouble(content_HelpAcc);
    FileClose(fileHandle2);
  }

  // Clean objects if needed
  if(CountSell()<=0){
    if(ObjectFind(0,"step_sell_11")!=-1)ObjectDelete(0,"step_sell_11");
    if(ObjectFind(0,"MinPrice")!=-1)ObjectDelete(0,"MinPrice");
    step_sell_11=0;minSellPrice=0;
  }
  if(CountBuy()<=0){
    if(ObjectFind(0,"step_buy_11")!=-1)ObjectDelete(0,"step_buy_11");
    if(ObjectFind(0,"MaxPrice")!=-1)ObjectDelete(0,"MaxPrice");
    step_buy_11=0;maxBuyPrice=0;
  }

  // Balance-based limits
  double balance_real=(standart ? (AccountBalance()+bonus)/100.0 : AccountBalance()+bonus);
  if(balance_real<=100) max_lot=30;
  else if(balance_real<150) max_lot=40;
  else if(balance_real<200) max_lot=60;
  else max_lot=80;

  // Side profits (our magic only)
  double profit_buy=0, profit_sell=0;
  for(int i1=0;i1<OrdersTotal();i1++){
    if(OrderSelect(i1,SELECT_BY_POS,MODE_TRADES)){
      if(OrderMagicNumber()==order_magic){
        if(OrderType()==OP_BUY)  profit_buy += OrderProfit()+OrderCommission()+OrderSwap();
        if(OrderType()==OP_SELL) profit_sell+= OrderProfit()+OrderCommission()+OrderSwap();
      }
    }
  }

  // Equity %
  double tb=AccountBalance()+bonus, tr=AccountProfit(), trr_tr= tr*100.0/tb;
  trr=tr*100.0/tb;
  if(HelpAccount!=0) trr=(AccountEquity()-HelpAccount)/(HelpAccount/100.0);

  // Lot scale by equity
  if(OrdersTotal()<1||(OrdersTotal()>=1&&start_balance==0)) start_balance=AccountEquity();
  double factor=2.0;
  if(start_balance<=start_um*20)factor=1.0;
  else if(start_balance<=start_um*40)factor=1.2;
  else if(start_balance<=start_um*60)factor=1.6;
  par5 = start_balance/(start_um*factor);
  if(par5>200) par5=200;

  // trade environment
  if(!work_check()) return;
  int all=main.Update(),op=0,idirect;
  double p=main.p,lot,avg;

  // Split trailing (BUY)
  if(trall_order_razdelni){
    int cb1=CountBuy_1();
    if(cb1>2){
      double minP = (cb1<=5?lMinProfit_1: cb1<=10?lMinProfit_2: cb1<=15?lMinProfit_3: cb1<=20?lMinProfit_4: cb1<=40?lMinProfit_5: lMinProfit_6)*p;
      double slT = lTrailingStop_1*p;
      double stepCond=(lTrailingStop_1+lTrailingStep_1-1)*p;
      for(int i=0;i<OrdersTotal();i++){
        if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
        if(OrderType()!=OP_BUY) continue;
        if((Bid-OrderOpenPrice())>minP){
          if(OrderStopLoss()<(Bid-stepCond)||OrderStopLoss()==0){
            bool ok = OrderModify(OrderTicket(),OrderOpenPrice(),Bid-slT,OrderTakeProfit(),0,col_3);
            if(!ok) Print("Trailing BUY modify failed, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
      }
    }
    // Split trailing (SELL)
    int cs1=CountSell_1();
    if(cs1>2){
      double minP = (cs1<=5?lMinProfit_1: cs1<=10?lMinProfit_2: cs1<=15?lMinProfit_3: cs1<=20?lMinProfit_4: cs1<=40?lMinProfit_5: lMinProfit_6)*p;
      double slT = lTrailingStop_1*p;
      double stepCond=(lTrailingStop_1+lTrailingStep_1-1)*p;
      for(int i=0;i<OrdersTotal();i++){
        if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
        if(OrderType()!=OP_SELL) continue;
        if((OrderOpenPrice()-Ask)>minP){
          if(OrderStopLoss()>(Ask+stepCond)||OrderStopLoss()==0){
            bool ok = OrderModify(OrderTicket(),OrderOpenPrice(),Ask+slT,OrderTakeProfit(),0,col_3);
            if(!ok) Print("Trailing SELL modify failed, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
      }
    }
  }

  // Common trailing
  if(trall_order_all){
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

  // Profit close triggers
  if(close_profit_buy  && CountBuy_1()>=1  && profit_buy >(c777*par5) && (trr_tr<(-5))) op=-777;
  if(close_profit_sell && CountSell_1()>=1 && profit_sell>(c777*par5) && (trr_tr<(-5))) op= 777;

  // ================= SLAVE ENTRY LOGIC ====================
  if(FileExists("close_all.txt") && !master && AUDCAD_AUDUSD){
    // detect presence of any master-like order (magic 4/5/6)
    bool has_master=false;
    for(int i=0;i<OrdersTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        int m=OrderMagicNumber();
        if(m==4||m==5||m==6){ has_master=true; break; }
      }
    }
    if(has_master){
      double par3 = AccountBalance()+bonus;
      double par21 = AccountEquity();

      // Iterate tiers 1..5 compactly, use same triggers as before
      for(int t=1;t<=5;t++){
        string sfile = (t==1?"str1.txt": t==2?"str2.txt": t==3?"str3.txt": t==4?"str4.txt":"str5.txt");
        if(!FileExists(sfile)) continue;

        bool risk_ok = (t==1 ? ((par21 + c24*par5) <= par3) : true);
        if(!risk_ok) continue;

        if(CountBuy()<1 && CountSell_1()>=1 && CountSell()<=0) op =  t;
        if(CountSell()<1 && CountBuy_1()>=1 && CountBuy() <=0) op = -t;

        if(CountBuy()>=1 && CountBuy()<max_lot && CountSell()<=0 &&
           (CountBuy_1()<CountSell_1() || ((par21 + c23*par5) <= par3))) op =  t;

        if(CountSell()>=1 && CountSell()<max_lot && CountBuy() <=0 &&
           (CountBuy_1()>CountSell_1() || ((par21 + c23*par5) <= par3))) op = -t;

        if(CountBuy() >=1 && CountBuy() <max_lot && CountSell()<=0 && Ask>Highest_m && Ask>step_buy_11)  op =  t*11;
        if(CountSell()>=1 && CountSell()<max_lot && CountBuy() <=0 && Bid<Lowest_m && Bid<step_sell_11) op = -t*11;
      }
    }
  }

  // ================= OPEN POSITIONS =======================
  // Re-entries by step (pips) with cooldown
  if(op==1||op==2||op==3||op==4||op==5){
    int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
    if(main.OrderSelect(t_b) && main.OrderProfitPoint(t_b)<=-g_next_step_buy){
      int tier=OpToTier(op);
      if(CooldownOk(true,tier)){
        double mult=(op==1?st1:(op==2?st2:(op==3?st3:(op==4?st4:st5))));
        tryOpen(OP_BUY,mult);
      }
    }
  }
  if(op==-1||op==-2||op==-3||op==-4||op==-5){
    int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
    if(main.OrderSelect(t_s) && main.OrderProfitPoint(t_s)<=-g_next_step_sell){
      int tier=OpToTier(op);
      if(CooldownOk(false,tier)){
        double mult=(op==-1?st1:(op==-2?st2:(op==-3?st3:(op==-4?st4:st5))));
        tryOpen(OP_SELL,mult);
      }
    }
  }

  // Breakout entries with cooldown
  if(op==11||op==22||op==33||op==44||op==55){
    if(Ask>step_buy_11){
      int tier=OpToTier(op);
      if(CooldownOk(true,tier)){
        double mult=(op==11?st1:(op==22?st2:(op==33?st3:(op==44?st4:st5))));
        tryOpen(OP_BUY,mult);
      }
    }
  }
  if(op==-11||op==-22||op==-33||op==-44||op==-55){
    if(Bid<step_sell_11){
      int tier=OpToTier(op);
      if(CooldownOk(false,tier)){
        double mult=(op==-11?st1:(op==-22?st2:(op==-33?st3:(op==-44?st4:st5))));
        tryOpen(OP_SELL,mult);
      }
    }
  }

  // ================= GROUP CLOSES =========================
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
          if(telegram && CountSell()<=0) SendTelegramMessage(BuildEquityMessage_8());
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
          if(telegram && CountBuy()<=0) SendTelegramMessage(BuildEquityMessage_7());
        }
      }
    }
  }

  // First entries (with cooldown)
  lot = lot1;
  if((op==1||op==11)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st1); }
  if((op==2||op==22)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st2); }
  if((op==3||op==33)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st3); }
  if((op==4||op==44)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st4); }
  if((op==5||op==55)&&main.orders[OP_BUY]==0){ int tier=OpToTier(op); if(CooldownOk(true,tier))  tryOpen(OP_BUY,st5); }

  if((op==-1||op==-11)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st1); }
  if((op==-2||op==-22)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st2); }
  if((op==-3||op==-33)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st3); }
  if((op==-4||op==-44)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st4); }
  if((op==-5||op==-55)&&main.orders[OP_SELL]==0){ int tier=OpToTier(op); if(CooldownOk(false,tier)) tryOpen(OP_SELL,st5); }
}

// Lot from table
double getLot(int i){
  int c=ArraySize(lots);
  if(c==0)return 0;
  if(i<0)i=0;
  if(i>=c-1)i=c-1;
  return lots[i];
}
// EOF