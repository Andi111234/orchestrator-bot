#property strict

// Compatibility enum (some legacy code expects it)
enum ENUM_TF
{
  current=0,
  M1=PERIOD_M1,
  M5=PERIOD_M5,
  M15=PERIOD_M15,
  M30=PERIOD_M30,
  H1=PERIOD_H1,
  H4=PERIOD_H4,
  D1=PERIOD_D1,
  W1=PERIOD_W1,
  MN1=PERIOD_MN1
};

// Helpers
double PipValue(string name){
  int mult = 1;
  if(MarketInfo(name,MODE_DIGITS)==5 || MarketInfo(name,MODE_DIGITS)==3 || MarketInfo(name,MODE_PROFITCALCMODE)==1)
    mult = 10;
  return mult * MarketInfo(name,MODE_POINT); // pip (not point)
}

double nd(double dd,string name=""){
  if(name=="") name=Symbol();
  return NormalizeDouble(dd,(int)MarketInfo(name,MODE_DIGITS));
}

bool work_check(){
  if(IsTesting() || IsOptimization()) return true;
  if(AccountBalance()==0.0) return false;
  if(!IsTradeAllowed())     return false;
  if(!IsConnected())        return false;
  if(IsTradeContextBusy())  return false;
  if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)==false) return false;
  return true;
}

enum _ORDER_MODE { ORDER_FIRST=1, ORDER_LAST=2 };

class GOrders {
public:
  string  sname;
  long    imagic;
  int     islippage;
  double  p;          // pip size in price
  int     orders[6];  // counts by type

  GOrders(){ ArrayInitialize(orders,0); sname=Symbol(); imagic=-1; islippage=0; p=PipValue(sname); }
  void init(string n,int iimagic,int iislippage){
    sname=n; imagic=iimagic; islippage=iislippage; p=PipValue(n);
    ArrayInitialize(orders,0);
  }

  int Update(){
    ArrayInitialize(orders,0);
    int all=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if((OrderSymbol()==sname || sname==NULL) && (OrderMagicNumber()==imagic || imagic==-1) && OrderType()<6){
        orders[OrderType()]++; all++;
      }
    }
    return all;
  }

  bool OrderSelect(int iticket){
    return ::OrderSelect(iticket,SELECT_BY_TICKET);
  }

  int getLastOrderTicket(int itype,_ORDER_MODE imode){
    double arr[][2]; ArrayResize(arr,0); int c=0;
    for(int i=OrdersTotal()-1;i>=0;i--){
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      if((OrderSymbol()==sname || sname==NULL) && (OrderMagicNumber()==imagic || imagic==-1) && OrderType()==itype){
        ArrayResize(arr,c+1);
        arr[c][0]=OrderOpenPrice();
        arr[c][1]=OrderTicket();
        c++;
      }
    }
    if(c==0) return 0;
    if(itype==OP_BUY){
      ArraySort(arr,WHOLE_ARRAY,0,MODE_ASCEND);
      return (int)arr[(imode==ORDER_LAST?0:c-1)][1];
    }
    if(itype==OP_SELL){
      ArraySort(arr,WHOLE_ARRAY,0,MODE_DESCEND);
      return (int)arr[(imode==ORDER_LAST?0:c-1)][1];
    }
    return 0;
  }

  double get_Average(int itype,int &idirect){
    double dprice[2]={0,0}, m_lots[2]={0,0}, icount[2]={0,0};
    idirect=0;
    double dask=MarketInfo(sname,MODE_ASK);
    double dbid=MarketInfo(sname,MODE_BID);

    for(int i=OrdersTotal()-1;i>=0;i--){
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      if((OrderSymbol()==sname || sname==NULL) && (OrderMagicNumber()==imagic || imagic==-1)){
        if(OrderType()==OP_BUY){  m_lots[0]+=OrderLots(); dprice[0]+=NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap(),2); icount[0]++; }
        if(OrderType()==OP_SELL){ m_lots[1]+=OrderLots(); dprice[1]+=NormalizeDouble(OrderProfit()+OrderCommission()+OrderSwap(),2); icount[1]++; }
      }
    }

    if(NormalizeDouble(m_lots[0],2)-NormalizeDouble(m_lots[1],2)==0.0) return 0;
    if(NormalizeDouble(m_lots[0],2)>NormalizeDouble(m_lots[1],2)) idirect=1; else idirect=-1;

    double PriceLevel=0;
    double TickValue=NormalizeDouble(MarketInfo(sname,MODE_TICKVALUE),2);
    if(TickValue==0.0) return 0;
    double point=MarketInfo(sname,MODE_POINT);
    if(point==0.0) return 0;
    int idigits=(int)MarketInfo(sname,MODE_DIGITS);
    if(MarketInfo(sname,MODE_DIGITS)==5 || MarketInfo(sname,MODE_DIGITS)==3 || MarketInfo(sname,MODE_PROFITCALCMODE)==1)
      idigits=(int)(MarketInfo(sname,MODE_DIGITS)-1);

    if((m_lots[0]-m_lots[1])>0) PriceLevel=dbid-((dprice[0]+dprice[1])/(TickValue*(m_lots[0]-m_lots[1]))*point);
    if((m_lots[1]-m_lots[0])>0) PriceLevel=dask+((dprice[0]+dprice[1])/(TickValue*(m_lots[1]-m_lots[0]))*point);
    return NormalizeDouble(PriceLevel,idigits);
  }

  void groupTrailingStop(int itype,double dstop){
    for(int i=OrdersTotal()-1;i>=0;i--){
      if(!::OrderSelect(i,SELECT_BY_POS)) continue;
      if((OrderSymbol()==sname || sname==NULL) && (OrderMagicNumber()==imagic || imagic==-1)){
        if(OrderType()==OP_BUY && itype==OP_BUY){
          if(dstop>OrderStopLoss() || OrderStopLoss()==0.0){
            bool ok = ::OrderModify(OrderTicket(),-1,dstop,-1,0,clrNONE);
            if(!ok) Print("OrderModify failed for BUY, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
        if(OrderType()==OP_SELL && itype==OP_SELL){
          if(dstop<OrderStopLoss() || OrderStopLoss()==0.0){
            bool ok = ::OrderModify(OrderTicket(),-1,dstop,-1,0,clrNONE);
            if(!ok) Print("OrderModify failed for SELL, ticket=",OrderTicket()," err=",GetLastError());
          }
        }
      }
    }
  }

  double OrderProfitPoint(int iticket=-1){
    if(iticket!=-1){
      if(OrderTicket()!=iticket){
        if(!::OrderSelect(iticket,SELECT_BY_TICKET)) return 0;
      }
    }else return 0;
    string n=OrderSymbol();
    double dpp=PipValue(n);
    if(dpp==0.0) return 0;
    if(OrderCloseTime()==0.0 && OrderType()<2){
      if(OrderType()==OP_BUY)  return NormalizeDouble((MarketInfo(n,MODE_ASK)-OrderOpenPrice())/dpp,1);
      if(OrderType()==OP_SELL) return NormalizeDouble((OrderOpenPrice()-MarketInfo(n,MODE_BID))/dpp,1);
    }
    if(OrderCloseTime()!=0.0 && OrderType()<2){
      if(OrderType()==OP_BUY)  return NormalizeDouble((OrderClosePrice()-OrderOpenPrice())/dpp,1);
      if(OrderType()==OP_SELL) return NormalizeDouble((OrderOpenPrice()-OrderClosePrice())/dpp,1);
    }
    return 0;
  }

  int OrderSend(const int cmd,const double dlot,double dopen,const double dsl=0,const double dtp=0,const string _comment="",const datetime dt=0,const color cl=clrNONE,const bool tpslIsPoint=true){
    if(dlot<=0.0) return 0;
    double ddlot = NormalizeDouble(dlot,2);
    int digit=(int)MarketInfo(sname,MODE_DIGITS);
    int tries=0;
    int ticket=-1;

    while(tries<3 && !IsStopped()){
      tries++;
      double open=dopen;
      if(open==-1){
        RefreshRates();
        if(cmd==OP_BUY)  open=MarketInfo(sname,MODE_ASK);
        if(cmd==OP_SELL) open=MarketInfo(sname,MODE_BID);
      }

      double stop=0,take=0;
      if(cmd<2){
        if(tpslIsPoint){
          if(cmd==OP_BUY){  if(dtp>0) take=open+dtp*p; if(dsl>0) stop=open-dsl*p; }
          if(cmd==OP_SELL){ if(dtp>0) take=open-dtp*p; if(dsl>0) stop=open+dsl*p; }
        }else{
          if(dtp>0) take=dtp;
          if(dsl>0) stop=dsl;
        }
        ticket=::OrderSend(sname,cmd,ddlot,NormalizeDouble(open,digit),islippage,0,0,_comment,(int)imagic,dt,cl);
        if(ticket>0 && (take>0 || stop>0)){
          bool ok = ::OrderModify(ticket,NormalizeDouble(open,digit),NormalizeDouble(stop,digit),NormalizeDouble(take,digit),dt,cl);
          if(!ok) Print("OrderModify(attach SL/TP) failed, ticket=",ticket," err=",GetLastError());
        }
      }else{
        if(tpslIsPoint){
          if(cmd==OP_BUYSTOP || cmd==OP_BUYLIMIT){ if(dtp>0) take=open+dtp*p; if(dsl>0) stop=open-dsl*p; }
          if(cmd==OP_SELLSTOP || cmd==OP_SELLLIMIT){ if(dtp>0) take=open-dtp*p; if(dsl>0) stop=open+dsl*p; }
        }else{
          if(dtp>0) take=dtp; if(dsl>0) stop=dsl;
        }
        ticket=::OrderSend(sname,cmd,ddlot,NormalizeDouble(open,digit),islippage,NormalizeDouble(stop,digit),NormalizeDouble(take,digit),_comment,(int)imagic,dt,cl);
      }

      if(ticket>0) return ticket;
      int err=GetLastError(); Print("OrderSend retry #",tries," err=",err); Sleep(400);
    }
    return ticket;
  }
};