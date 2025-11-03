
        #include "sovetnikov_light.mqh"
        #include "steps_unified.mqh"
        #include "graphics_common.mqh" 
//-----------------------проверяем ботов активен или нет--------------------------------------- 
        #define BOT_NAME "Bot_1"  // Уникальное имя этого советника 
        #define TOTAL_BOTS 12          // Всего ботов
        #define TIMEOUT 30             // Секунд без активности = "не отвечает"
//-----------------------проверяем ботов активен или нет---------------------------------------             
///////////////////////////////////////////////////////////////////////////////////////////////
        static input string VISUALIZATION="========VISUALIZATION========"; //===========================        
//-----------------------включение выключени инфо панели---------------------------------------
        input bool info_0             =true;        // Включение выключение ИНФО панели
//-----------------------включение выключени инфо панели---------------------------------------
      
//-----------------------отправка сообщений в телеграмм----------------------------------------
        input bool telegram           =true;        // Отправка сообщений в телеграмм                 
        string URL="https://api.telegram.org/";
        extern string ChannelID="419654265";
        extern string BotID=""; 
//-----------------------отправка сообщений в телеграмм----------------------------------------

//-----------------------блок реализации одной сделки на одном баре----------------------------
        datetime lastSendTime_0 = 0,lastSendTime_1 = 0,lastSendTime_2 = 0,lastSendTime_3 = 0,lastSendTime_4 = 0,lastSendTime_5 = 0,lastSendTime_6 = 0,lastSendTime_7 = 0,lastSendTime_8 = 0,lastSendTime_9 = 0,lastSendTime_10 = 0,lastSendTime_11 = 0,lastSendTime_12 = 0,lastSendTime_13 = 0,lastSendTime_14 = 0,lastSendTime_15 = 0,lastSendTime_16 = 0,lastSendTime_17 = 0,lastSendTime_18 = 0;
        datetime LastActiontime_vline=StrToTime(TimeToStr(TimeCurrent(),TIME_SECONDS));  
//-----------------------блок реализации одной сделки на одном баре----------------------------

//-----------------------цвета----------------------------------------------------------------
        color col_1=Silver,col_2=PapayaWhip,col_3=DeepSkyBlue,col_4=OrangeRed,col_5=Gray,col_6=Lime,col_8=Chocolate,col_9=Orange,col_10=Red,col_11=LightGray,col_12=DarkOrange,col_13=OrangeRed,col_14=White,col_15=DimGray,col_16=Gold,col_17=Black,col_18=DarkGray,col_19=DodgerBlue;
//-----------------------цвета----------------------------------------------------------------

//-----------------------настройки шрифта------------------------------------------------------
        int FontSize        =10;                  
        string TextFONT     ="Courier New";                           
        int CORNER          =0;                                                                                                                            
//-----------------------настройки шрифта-------------------------------------------------------                                                                
///////////////////////////////////////////////////////////////////////////////////////////////
        static input string SETTING_TRADES="========SETTING TRADES======="; //===========================
        
        input bool master              =true;        // Первый вход осуществляет master, если master=false, то включен slave      
        input bool standart            =false;       // Выбор типа счета-стандарт, цент, если standart=false, то включен cent
        input bool delta_dinamic       =true;        // Включение выключени динамическтй дельты
        input int  OpenCooldownSec     =2;           // Cooldown between re-entries (0=disabled)
        input bool UseMN1FromD1        =true;        // Feed MN1 analytics from D1(20) instead of MN1 bars
        input int  DaysToAnalyze_D1    =20;          // Days of D1 to use for MN1 proxy when UseMN1FromD1=true
//-----------------------назвачение валютных пар для советника--------------------------------        
        bool EURUSD_GBPUSD             =true;//=true        // true включаем кореллирующие пары, false отключаем
        bool AUDCAD_AUDUSD             =false;     
        bool EURAUD_GBPAUD             =false;             
        bool AUDCHF_GBPCHF             =false;    
        bool NZDUSD_NZDCAD             =false;     
        bool USDCHF_CADCHF             =false;
//-----------------------назвачение валютных пар для советника---------------------------------
//-----------------------переменный в зависимости от типа счета цент---------------------------
        double start_um=400000;                    // При данной сумме будет реинвестирование
        double bonus=0;
        
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
        
        double st1=1;
        double st2=1.2;
        double st3=1.4;
        double st4=1.6;
        double st5=1.8;
        
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------        
        double st_delta_1=1;
        double st_delta_2=1.4;
        double st_delta_3=1.8;
        double st_delta_4=2.2;
        double st_delta_5=2.6;
        
        double koeff_delta=1.1; //отклонение дельты
        double delta_average=2; //уменьшаем значение дельты на значение
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------

//-----------------------переменный в зависимости от типа счета цент---------------------------        
        double c22=1000;                             // Сумма для активации тейк профитов
        double spred_1=0.085;                        // Переменная для расчета заработка на спреде
        double c1=0;                                 // Закрытие по профиту
        double c2=0;
        double c3=0;                                 // Закрытие по динамическому тралу
        double c28=0;                                // Закрытие по эквити
        double c29=5;
        double c777=200;                       
        double c888=20;                              // Минимум профит для закрытия 
//-----------------------конец переменный в зависимости от типа счета цент---------------------

//-----------------------назначение мейджиков--------------------------------------------------
        int order_magic=1,order_magic_2=2;           // EURUSD 
  
//-----------------------назначение мейджиков--------------------------------------------------

///////////////////////////////////////////////////////////////////////////////////////////////
        static string SETTING_GRID="========SETTING GRID=========="; //===========================

        bool close_profit_buy          =true;        // Закрытие позиций по профиту бай
        bool close_profit_sell         =true;        // Закрытие позиций по профиту селл
        bool tral_equity               =true;        // Трал эквити
        bool tral_equity_dinamic       =true;        // Трал эквити динамический
        bool close_profit              =true;        // Закрытие позиций по профиту
        bool takeprofit_stoploss       =false;       // Тейк и стоп в зависимости от просадки
        bool trall_order_all           =true;        // Трейлинг стоп общий             
        bool trall_order_razdelni      =true;        // Трал ордеров раздельный  
//---------------------------------------------------------------------------------------------       
        double lMinProfit_1=8,lMinProfit_2=10,lMinProfit_3=18,lMinProfit_4=32,lMinProfit_5=42,lMinProfit_6=62;                       // Трейлинг стоп раздельный
        double lTrailingStop_1=4,lTrailingStep_1=2;//      
//---------------------------------------------------------------------------------------------
        double trailing_stop_pr=6;                   // Трейлинг стоп общий
//---------------------------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////////////////////
//-----------------------буферы----------------------------------------------------------------
        double step_buy_11=0,step_sell_11=0,next_step_buy=0,next_step_sell=0,next_step_buy_11=0,next_step_sell_11=0,start_balance=0,max_lot=0,HelpAccount_down =0,HelpAccount777_down=0,stoploss=0,stoploss1=0,takeprofit=0,takeprofit1=0,order_total=0,count_close=0,count_trall=0,HelpAccount=0,koeff_balance=0,t_p=0,s_l=0;
        double Equity_mn1=0;
        double minSellPrice=0;        // Переменная для хранения минимальной цены SELL ордера
        double maxBuyPrice=0;         // Переменная для хранения максимальной цены BUY ордера
//-----------------------cooldown arrays--------------------------------------------------------
        datetime g_lastOpenBuy[6];    // cooldown per tier [0..5] -> tier 1..6
        datetime g_lastOpenSell[6];   // cooldown per tier [0..5] -> tier 1..6
        double pre_OrdersTotal=0;
        double lastlos=0,lastprof=0,opp=0;
        datetime tm=-1;
        double trr=0;
        datetime firstEntryTime=0;
        int daysSinceFirstEntry=0;
        datetime firstEntryTime_h=0;
        int daysSinceFirstEntry_h=0;
        double r0=0,r1=0,p0=0,p1=0,r2=0,p2=0,r3=0,p3=0,r4=0,p4=0;
        datetime lastSwitchTime = 0;
        int activePoint = 1;
        double flag_4=0;
        double flag_5=0;
        double flag_6=0;

//-----------------------cчитаем закрытый объем------------------------------------------------
        double totalVolume = 0;      // Общий закрытый объём за день
        int currentDay_vol = -1;     // День, за который считали
//-----------------------cчитаем закрытый объем------------------------------------------------

//-----------------------буферы----------------------------------------------------------------
        int slippage=100;                            // Допустимое проскальзывание, 0-не используется
        string alert_0,alert_1,alert_2,alert_3,alert_4,alert_5,alert_6,alert_7; //переменные для сообщений      
//---------------------------------------------------------------------------------------------      
        double koef1=1,koef2=1.1,koef3=1.2,koef4=1.3,koef5=1.4,koef6=1.5,koef7=1.6,koef8=1.7,koef9=1.8,koef10=1.9,koef11=2.0,koef12=2.1,koef13=2.2,koef14=2.3,koef15=2.4,koef16=2.5,koef17=2.6,koef18=2.7,koef19=2.8,koef20=2.9,koef21=3.0,koef22=3.1,koef23=3.2,koef24=3.3,koef25=3.4,koef26=3.5,koef27=3.6,koef28=3.7,koef29=3.8,koef30=3.9,koef31=4.0,koef32=4.1,koef33=4.2,koef34=4.3,koef35=4.4;       
//---------------------------------------------------------------------------------------------
        double ddX1=0.01,ddX2=0.02,ddX3=0.03,ddX4=0.04,ddX5=0.05,ddX6=0.06,ddX7=0.07,ddX8=0.08,ddX9=0.09,ddX10=0.10,ddX11=0.11,ddX12=0.12,ddX13=0.13,ddX14=0.14,ddX15=0.15,ddX16=0.16,ddX17=0.17,ddX18=0.18,ddX19=0.19,ddX20=0.20,ddX21=0.21,ddX22=0.22,ddX23=0.23,ddX24=0.24,ddX25=0.25,ddX26=0.26,ddX27=0.27,ddX28=0.28,ddX29=0.29,ddX30=0.30,ddX31=0.31,ddX32=0.32,ddX33=0.33,ddX34=0.34,ddX35=0.35;
//---------------------------------------------------------------------------------------------

//-----------------------переменные для расчета дельты-----------------------------------------

//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------
        double delta_EURUSD_GBPUSD_d=0;
        double delta_AUDCAD_AUDUSD_d=0;
        double delta_EURAUD_GBPAUD_d=0;
        double delta_AUDCHF_GBPCHF_d=0;
        double delta_NZDUSD_NZDCAD_d=0;
        double delta_USDCHF_CADCHF_d=0;
        
        double delta_EURUSD_GBPUSD_MN1_strong=0;
        double delta_AUDCAD_AUDUSD_MN1_strong=0;
        double delta_EURAUD_GBPAUD_MN1_strong=0;
        double delta_AUDCHF_GBPCHF_MN1_strong=0;
        double delta_NZDUSD_NZDCAD_MN1_strong=0;
        double delta_USDCHF_CADCHF_MN1_strong=0;

        double delta_EURUSD_GBPUSD_MN1_strong1=0;
        double delta_EURUSD_GBPUSD_MN1_strong2=0;
        double delta_EURUSD_GBPUSD_MN1_strong3=0;
        double delta_EURUSD_GBPUSD_MN1_strong4=0;
        double delta_EURUSD_GBPUSD_MN1_strong5=0;
        
        double delta_AUDCAD_AUDUSD_MN1_strong1=0;
        double delta_AUDCAD_AUDUSD_MN1_strong2=0;
        double delta_AUDCAD_AUDUSD_MN1_strong3=0;
        double delta_AUDCAD_AUDUSD_MN1_strong4=0;
        double delta_AUDCAD_AUDUSD_MN1_strong5=0;
        
        double delta_EURAUD_GBPAUD_MN1_strong1=0;
        double delta_EURAUD_GBPAUD_MN1_strong2=0;
        double delta_EURAUD_GBPAUD_MN1_strong3=0;
        double delta_EURAUD_GBPAUD_MN1_strong4=0;
        double delta_EURAUD_GBPAUD_MN1_strong5=0;
        
        double delta_AUDCHF_GBPCHF_MN1_strong1=0;
        double delta_AUDCHF_GBPCHF_MN1_strong2=0;
        double delta_AUDCHF_GBPCHF_MN1_strong3=0;
        double delta_AUDCHF_GBPCHF_MN1_strong4=0;
        double delta_AUDCHF_GBPCHF_MN1_strong5=0;
        
        double delta_NZDUSD_NZDCAD_MN1_strong1=0;
        double delta_NZDUSD_NZDCAD_MN1_strong2=0;
        double delta_NZDUSD_NZDCAD_MN1_strong3=0;
        double delta_NZDUSD_NZDCAD_MN1_strong4=0;
        double delta_NZDUSD_NZDCAD_MN1_strong5=0;
        
        double delta_USDCHF_CADCHF_MN1_strong1=0;
        double delta_USDCHF_CADCHF_MN1_strong2=0;
        double delta_USDCHF_CADCHF_MN1_strong3=0;
        double delta_USDCHF_CADCHF_MN1_strong4=0;
        double delta_USDCHF_CADCHF_MN1_strong5=0;
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------

        double delta_EURUSD_GBPUSD=0,delta_AUDCAD_AUDUSD=0,delta_EURAUD_GBPAUD=0,delta_AUDCHF_GBPCHF=0,delta_NZDUSD_NZDCAD=0,delta_USDCHF_CADCHF=0; // переменная расхождения между USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_1=0,delta_AUDCAD_AUDUSD_1=0,delta_EURAUD_GBPAUD_1=0,delta_AUDCHF_GBPCHF_1=0,delta_NZDUSD_NZDCAD_1=0,delta_USDCHF_CADCHF_1=0; // динамика USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_2=0,delta_AUDCAD_AUDUSD_2=0,delta_EURAUD_GBPAUD_2=0,delta_AUDCHF_GBPCHF_2=0,delta_NZDUSD_NZDCAD_2=0,delta_USDCHF_CADCHF_2=0; // динамика USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_3=0,delta_AUDCAD_AUDUSD_3=0,delta_EURAUD_GBPAUD_3=0,delta_AUDCHF_GBPCHF_3=0,delta_NZDUSD_NZDCAD_3=0,delta_USDCHF_CADCHF_3=0; // динамика USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_4=0,delta_AUDCAD_AUDUSD_4=0,delta_EURAUD_GBPAUD_4=0,delta_AUDCHF_GBPCHF_4=0,delta_NZDUSD_NZDCAD_4=0,delta_USDCHF_CADCHF_4=0; // динамика USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_5=0,delta_AUDCAD_AUDUSD_5=0,delta_EURAUD_GBPAUD_5=0,delta_AUDCHF_GBPCHF_5=0,delta_NZDUSD_NZDCAD_5=0,delta_USDCHF_CADCHF_5=0; // динамика USDCHF_CADCHF
        double delta_EURUSD_GBPUSD_average=0,delta_AUDCAD_AUDUSD_average=0,delta_EURAUD_GBPAUD_average=0,delta_AUDCHF_GBPCHF_average=0,delta_NZDUSD_NZDCAD_average=0,delta_USDCHF_CADCHF_average=0; // динамика USDCHF_CADCHF  
//-----------------------переменные для расчета дельты-----------------------------------------

        double str1_time=0,str2_time=0,str3_time=0,str4_time=0,str5_time=0; // Переменные для расчета времени для сканирование стратегий
//-----------------------значения, переменные функции для панели info--------------------------
        int event_0=0,event_1=0,event_0_s=0,event_2=0,event_3=0,event_4=0,event_5=0,event_6=0,event_7=0,event_11=0,event_12=0,event_13=0,event_20=0,event_21=0,event_22=0,event_23_1=0,event_24_1=0,event_25_1=0,event_26_1=0,event_27_1=0,event_28_1=0; 
        int event_3_s=0,event_4_s=0,event_6_s=0,event_7_s=0,event_12_s=0,event_13_s=0,event_21_1_s=0,event_22_1_s=0,event_24_1_s=0,event_25_1_s=0,event_27_1_s=0,event_28_1_s=0;   
        int event_3_3=0,event_4_4=0,event_6_6=0,event_7_7=0,event_12_12=0,event_13_13=0,event_21_21=0,event_22_22=0,event_24_24_1=0,event_25_25_1=0,event_27_27_1=0,event_28_28_1=0; 
        int event_2_p =0,event_5_p =0,event_11_p=0,event_20_p=0,event_23_p=0,event_26_p=0,event_23=0,event_24=0,event_25=0,event_26=0,event_27=0,event_28=0,event_29=0,event_30=0,event_31=0,event_32=0,event_33=0;
        int event_34=0,event_35=0,event_36=0,event_37=0,event_2_1=0,event_2_p_1=0,event_5_1=0,event_5_p_1=0,event_11_1=0,event_11_p_1=0,event_20_1=0,event_20_p_1=0,event_23_1_1=0,event_23_p_1=0,event_26_1_1=0,event_26_p_1=0;
//-----------------------значения, переменные функции для панели info--------------------------
///////////////////////////////////////////////////////////////////////////////////////////////

//-----------------------переменные для записи файлов------------------------------------------       
        string filename1="str1.txt",content1="str1";
        string filename2="str2.txt",content2="str2";
        string filename3="str3.txt",content3="str3";
        string filename4="str4.txt",content4="str4";
        string filename5="str5.txt",content5="str5";
//-----------------------конец переменные для записи файлов------------------------------------

//-----------------------переменные для записи файлов пред.стратегии---------------------------       
        string filename_pr1="str_pr1.txt",content_pr1="str_pr1";
        string filename_pr2="str_pr2.txt",content_pr2="str_pr2";
        string filename_pr3="str_pr3.txt",content_pr3="str_pr3";
        string filename_pr4="str_pr4.txt",content_pr4="str_pr4";
        string filename_pr5="str_pr5.txt",content_pr5="str_pr5";
//-----------------------конец переменные для записи файлов пред.стратегии---------------------

//-----------------------блок реализации одной сделки на одном баре----------------------------
        bool isNewBar(){static datetime BARflag=0;
        datetime now=(int)SeriesInfoInteger(Symbol(),PERIOD_M1,SERIES_LASTBAR_DATE);//Time[0];
        if(BARflag<now){BARflag=now;return(true);}   
        else return(false);}        
//-----------------------блок реализации одной сделки на одном баре----------------------------

/////////////////////////////////////////////////////////////////////////////////////////////// 
        double par5=1;
        ENUM_TF  tf=0;                      // 0-текущий тф с графика, либо стандартный тф в минутах
        int signal_bar=0;                   // не менять, сигнальный бар, 0-текущий, 1-по закрытию бара
        class CMain: public GOrders{
        public:
        CMain(){};
        ~CMain(){};
        void groupTake(int itype,double dtake){for(int i=OrdersTotal()-1; i>=0; i--){
        if(!OrderSelect(i,SELECT_BY_POS))continue;
        if((OrderSymbol()==sname||sname==NULL)&&(OrderMagicNumber()==imagic||imagic==-1)){
        if(OrderType()==OP_BUY&&itype==OP_BUY){if(nd(dtake)!=nd(OrderTakeProfit())||OrderTakeProfit()==0.0) OrderModify(OrderTicket(),-1,-1,dtake,0,clrNONE);}
        if(OrderType()==OP_SELL&&itype==OP_SELL){if(nd(dtake)!=nd(OrderTakeProfit())||OrderTakeProfit()==0.0) OrderModify(OrderTicket(),-1,-1,dtake,0,clrNONE);}}}}};
        CMain main();double lots[50];

//-----------------------cooldown and tier helpers----------------------------------------------
int OpToTier(int op) {
  // Maps op value to tier [0..5]
  // op: 1,11->0; 2,22->1; 3,33->2; 4,44->3; 5,55->4; initial->5
  if (op == 1 || op == 11) return 0;
  if (op == 2 || op == 22) return 1;
  if (op == 3 || op == 33) return 2;
  if (op == 4 || op == 44) return 3;
  if (op == 5 || op == 55) return 4;
  return 5; // initial entry or other
}

bool CooldownOk(bool isBuy, int tier) {
  if (OpenCooldownSec <= 0) return true;
  if (tier < 0 || tier > 5) return true;
  datetime now = TimeCurrent();
  datetime last = isBuy ? g_lastOpenBuy[tier] : g_lastOpenSell[tier];
  if (now - last >= OpenCooldownSec) {
    if (isBuy) g_lastOpenBuy[tier] = now;
    else g_lastOpenSell[tier] = now;
    return true;
  }
  return false;
}
//-----------------------cooldown and tier helpers----------------------------------------------

//-----------------------Expert initialization function----------------------------------------
        int OnInit(){main.init(Symbol(),order_magic,slippage);
        
        lots[0]=lot1;lots[1]=lot2;lots[2]=lot3;lots[3]=lot4;lots[4]=lot5;lots[5]=lot6;lots[6]=lot7;lots[7]=lot8;lots[8]=lot9;lots[9]=lot10;
        lots[10]=lot11;lots[11]=lot12;lots[12]=lot13;lots[13]=lot14;lots[14]=lot15;lots[15]=lot16;lots[16]=lot17;lots[17]=lot18;lots[18]=lot19;lots[19]=lot20;
        lots[20]=lot21;lots[21]=lot22;lots[22]=lot23;lots[23]=lot24;lots[24]=lot25;lots[25]=lot26;lots[26]=lot27;lots[27]=lot28;lots[28]=lot29;lots[29]=lot30;
        lots[30]=lot31;lots[31]=lot32;lots[32]=lot33;lots[33]=lot34;lots[34]=lot35;lots[35]=lot36;lots[36]=lot37;lots[37]=lot38;lots[38]=lot39;lots[39]=lot40;
        lots[40]=lot41;lots[41]=lot42;lots[42]=lot43;lots[43]=lot44;lots[44]=lot45;lots[45]=lot46;lots[46]=lot47;lots[47]=lot48;lots[48]=lot49;lots[49]=lot50;

//----------------------настройки графика по умолчанию-----------------------------------------   
        ChartSetInteger(0,CHART_MODE,CHART_CANDLES);                // Отображение в виде японских свечей CHART_CANDLES  CHART_LINE);
        ChartSetInteger(0,CHART_SHIFT,1);                           // Режим отступа ценового графика от правого края
        ChartSetInteger(0,CHART_AUTOSCROLL,1);                      // Режим автоматического перехода к правому краю графика
        ChartSetInteger(0,CHART_SHOW_GRID,1);                       // Отображение сетки на графике
        ChartSetInteger(0,CHART_SHOW_OBJECT_DESCR,1);               // Отображение текстовых описаний объектов (не для всех объектов описания показываются)
        //ChartSetInteger(0,CHART_COLOR_BACKGROUND,C'46,46,46');    // Цвет фона графика
        ChartSetInteger(0,CHART_COLOR_GRID,C'45,48,49');            // Цвет сетки
        ChartSetInteger(0,CHART_COLOR_CHART_UP,col_2);              // Цвет бара вверх, тени и окантовки тела бычьей свечи
        ChartSetInteger(0,CHART_COLOR_CHART_DOWN,col_15);           // Цвет бара вниз, тени и окантовки тела медвежьей свечи
        ChartSetInteger(0,CHART_COLOR_CHART_LINE,col_15);           // Цвет линии графика и японских свечей "Доджи"
        ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,col_2);           // Цвет тела бычьей свечи
        ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,col_15);          // Цвет тела медвежьей свечи
        ChartSetInteger(0,CHART_COLOR_BID,col_15);                  // Цвет линии Bid-цены
        ChartSetInteger(0,CHART_COLOR_ASK,0);                       // Цвет линии Ask-цены
        ChartSetInteger(0,CHART_COLOR_LAST,col_3);                  // Цвет линии цены последней совершенной сделки (Last)
        ChartSetInteger(0,CHART_COLOR_STOP_LEVEL,col_6);            // Цвет уровней стоп-ордеров (Stop Loss и Take Profit)
        ChartSetInteger(0,CHART_COLOR_VOLUME,col_18);               // Цвет объемов и уровней открытия ордеров
        ChartSetInteger(0,CHART_SCALE,5);                           // Масштаб свечей на графике
        ChartSetInteger(0,CHART_SHOW_OHLC,0);                       // Отображение OHLC
        ChartSetInteger(0,CHART_SHOW_PERIOD_SEP,0,0);               // Отображение разделителей периодов
        ChartSetInteger(0,CHART_COLOR_FOREGROUND,C'80,85,86');      // Цвет текста на графике
        ChartSetSymbolPeriod(0,Symbol(),PERIOD_D1);                 // Задаем по умолчанию период       
//----------------------настройки графика по умолчанию-----------------------------------------
     
        main.init(Symbol(),order_magic,slippage);
        
        // Initialize cooldown arrays
        ArrayInitialize(g_lastOpenBuy, 0);
        ArrayInitialize(g_lastOpenSell, 0);
        
        // Start timer for step cache updates
        EventSetTimer(60);
        
        return(INIT_SUCCEEDED);}
        
//-----------------------Expert deinitialization function--------------------------------------
void OnDeinit(const int reason) {
  EventKillTimer();
}

//-----------------------Expert timer function-------------------------------------------------
void OnTimer() {
  // Update step cache based on current order counts
  main.Update();
  Steps_OnTimer(main.orders[OP_BUY], main.orders[OP_SELL]);
}
//-----------------------Expert timer function-------------------------------------------------
      
//-----------------------прибыль сегодня вчера месяц-------------------------------------------
        datetime DateBeginQuarter(double nq=0){
        double ye=Year()-MathFloor(nq/4);nq=MathMod(nq,4);
        double mo=Month()-MathMod(Month()+2,3)+3*nq;
        if(mo<1){mo+=12;ye--;}
        if(mo>12){mo-=12;ye++;}
        return(StrToTime((string)ye+"."+(string)mo+".01"));}
        datetime DateOfMonday(int nn=0){
        datetime dt=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE));
        while(TimeDayOfWeek(dt)!=1) dt-=24*60*60;dt+=nn*7*24*60*60;
        return(dt);}double GetProfitFromDateInCurrency(string sy="", int op=-1, int mn=-1, datetime dt=0){
        double p=0;
        int i,k=OrdersHistoryTotal();
        if(sy=="0") sy=Symbol();
        for(i=0;i<k; i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        if((OrderSymbol()==sy||sy=="")&&(op<0||OrderType()==op)){
        if(OrderType()==OP_BUY||OrderType()==OP_SELL){
        if(mn<0||OrderMagicNumber()==mn){
        if(dt<OrderCloseTime()){
        p += OrderProfit()+OrderCommission()+OrderSwap();
        }}}}}}return(p);}
//-----------------------конец прибыль сегодня вчера месяц-------------------------------------

//-----------------------подсчет ордеров-------------------------------------------------------
        int CountBuy(){int count=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_BUY) count++;}return(count);}
        int CountSell(){int count=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_SELL) count++;}return(count);}
//---------------------------------------------------------------------------------------------
        int CountBuy_1(){int count1=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        {if(OrderType()==OP_BUY) count1++;}}return(count1);}
        int CountSell_1(){int count1=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        {if(OrderType()==OP_SELL) count1++;}}return(count1);}
//---------------------------------------------------------------------------------------------
        int CountBuy_2(){int count2=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_BUY) count2++;}return(count2);}
        int CountSell_2(){int count2=0;
        for(int trade=OrdersTotal()-1; trade>=0; trade--){bool result=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
        if(OrderMagicNumber()==order_magic_2&&OrderType()==OP_SELL) count2++;}return(count2);}
//---------------------------------------------------------------------------------------------

        int CountOrders(string symbol, int orderType){
        int count=0;
        for (int trade=OrdersTotal()-1; trade>=0; trade--){
        if(OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)){
        if(OrderSymbol()==symbol&&OrderType()==orderType){
        count++;}}}return count;}

        int buy_EURUSD=CountOrders("EURUSD",OP_BUY);int sell_EURUSD=CountOrders("EURUSD",OP_SELL);
        int buy_GBPUSD=CountOrders("GBPUSD",OP_BUY);int sell_GBPUSD=CountOrders("GBPUSD",OP_SELL);
        int buy_AUDCAD=CountOrders("AUDCAD",OP_BUY);int sell_AUDCAD=CountOrders("AUDCAD",OP_SELL);
        int buy_AUDUSD=CountOrders("AUDUSD",OP_BUY);int sell_AUDUSD=CountOrders("AUDUSD",OP_SELL);
        int buy_EURAUD=CountOrders("EURAUD",OP_BUY);int sell_EURAUD=CountOrders("EURAUD",OP_SELL);
        int buy_GBPAUD=CountOrders("GBPAUD",OP_BUY);int sell_GBPAUD=CountOrders("GBPAUD",OP_SELL);
        int buy_AUDCHF=CountOrders("AUDCHF",OP_BUY);int sell_AUDCHF=CountOrders("AUDCHF",OP_SELL);
        int buy_GBPCHF=CountOrders("GBPCHF",OP_BUY);int sell_GBPCHF=CountOrders("GBPCHF",OP_SELL);
        int buy_NZDUSD=CountOrders("NZDUSD",OP_BUY);int sell_NZDUSD=CountOrders("NZDUSD",OP_SELL);
        int buy_NZDCAD=CountOrders("NZDCAD",OP_BUY);int sell_NZDCAD=CountOrders("NZDCAD",OP_SELL);
        int buy_USDCHF=CountOrders("USDCHF",OP_BUY);int sell_USDCHF=CountOrders("USDCHF",OP_SELL);
        int buy_CADCHF=CountOrders("CADCHF",OP_BUY);int sell_CADCHF=CountOrders("CADCHF",OP_SELL);
//-----------------------конец подсчет ордеров-------------------------------------------------

//-----------------------расчитываем step11----------------------------------------------------
        double bestMinPrice(){
        double oldopenprise=0,prise=9999;
        for(int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        if(OrderMagicNumber()==order_magic)oldopenprise=OrderOpenPrice();
        if(oldopenprise<prise)prise=OrderOpenPrice();}}
        return(prise);}
        
        double bestMaxPrice(){
        double oldopenprise1=0,prise1=0;
        for(int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
        if(OrderMagicNumber()==order_magic)oldopenprise1=OrderOpenPrice();
        if(oldopenprise1>prise1)prise1=OrderOpenPrice();}}
        return(prise1);}   
//-----------------------расчитываем step11----------------------------------------------------

//-----------------------cчитаем дельту--------------------------------------------------------
        
        double CalculateDelta(string symbol, int period, int shift)
        {
        double priceAsk = MarketInfo(symbol, MODE_ASK);
        double priceBid = MarketInfo(symbol, MODE_BID);
        double priceClose = iClose(symbol, period, shift);
   
        // Проверка на нули
        if(priceAsk == 0 || priceBid == 0 || priceClose == 0)
        {
        Print("CalculateDelta: Ошибка - котировки для ", symbol, " недоступны");
        return 0; // Возвращаем 0, чтобы избежать деления на ноль
        }
   
        double priceCurrent = (priceAsk + priceBid) / 2;
        double priceProc = priceClose / 100;
        return (priceCurrent - priceClose) / priceProc;
        } 
//-----------------------cчитаем дельту--------------------------------------------------------

//-----------------------cчитаем открытый объем------------------------------------------------
        double CalculateOpenVolume(){
        double openVolume=0;
        for (int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)&&OrderType()<=OP_SELL){
        openVolume += OrderLots();}}
        return openVolume;}
//-----------------------cчитаем открытый объем------------------------------------------------

//-----------------------считаем комиссию------------------------------------------------------
        double CalculateOpenComiss(){
        double totalComiss=0.0;
        for (int i=OrdersTotal()-1; i>=0; i--)
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        totalComiss += OrderCommission();
        return totalComiss;}
//-----------------------считаем комиссию------------------------------------------------------

//-----------------------считаем свопы---------------------------------------------------------
        double CalculateOpenSwaps(){
        double totalSwaps=0.0;
        for (int i=OrdersTotal()-1; i>=0; i--)
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)&&OrderType()<=OP_SELL)
        totalSwaps += OrderSwap();
        return totalSwaps;}
//-----------------------считаем свопы---------------------------------------------------------

//--------------------удаляем объекты--------------------------------------------------------
        void DeleteObjectsWithText(string text){
        int total=ObjectsTotal();
        for (int i=total-1;i>=0;i--){
        string name=ObjectName(i);  // Получаем имя объекта
        if(StringFind(name,text)!=-1){
        if(ObjectFind(name)!=-1){
        ObjectDelete(name);  // Удаляем объект
        Print("Удален объект: ",name);}}}}
//--------------------удаляем объекты--------------------------------------------------------

//--------------------вывод шестеренок на график---------------------------------------------
        double angleWork1=0;double angleWork2=0;double angleWork3=0;double angleWork4=0;
        void CreateWorkLabel(int index,double angle,int x,int y,int textSize,color textColor){
        string work_="work_"+IntegerToString(index);
        if(ObjectFind(0,work_)==-1){ObjectCreate(work_,OBJ_LABEL,0,0,0);ObjectSetInteger(0,work_,OBJPROP_BACK,false);ObjectSetString(0,work_,OBJPROP_TOOLTIP,"\n");ObjectSet(work_,OBJPROP_CORNER,CORNER);ObjectSetInteger(0,work_,OBJPROP_ANCHOR,ANCHOR_CENTER);}
        
        ObjectSet(work_,OBJPROP_XDISTANCE,x);
        ObjectSet(work_,OBJPROP_YDISTANCE,y);
        ObjectSetText(work_,CharToStr(118),textSize,"Wingdings",textColor);
        ObjectSet(work_,OBJPROP_ANGLE,angle);}

        void UpdateRotation(){
        //Обновляем углы для плавного вращения//Плавное увеличение угла(можно изменитьскорость)
        angleWork1+=5;angleWork2+=5;angleWork3+=5;angleWork4+=5;
        //Ограничение угла от 0 до 360 градусов
        if(angleWork1>=360)angleWork1=0;
        if(angleWork2>=360)angleWork2=0;
        if(angleWork3>=360)angleWork3=0;
        if(angleWork4>=360)angleWork4=0;
        //Применяем новый угол
        ObjectSet("work_1",OBJPROP_ANGLE,angleWork1);ObjectSet("work_2",OBJPROP_ANGLE,angleWork2);ObjectSet("work_3",OBJPROP_ANGLE,angleWork3);ObjectSet("work_4",OBJPROP_ANGLE,angleWork4);}
//--------------------вывод шестеренок на график---------------------------------------------

//-----------------------отправка сообщений в телеграмм-----------------------------------------
        // Функция для отправки сообщения в Telegram
        void SendTelegramMessage(string text) {
        int res = 0;
        char post[], result[];
        
        string headers;
        string url=URL+"bot"+BotID+"/sendMessage?chat_id="+ChannelID+"&text="+text;int k=0;
        if(k<3){ResetLastError();res=WebRequest("GET",url,NULL,NULL,5000,post,0,result,headers);k++;
        if(res<0){Print(url);Print("Error in WebRequest. ERROR: code= ",GetLastError());}}
        
        if (res != 200) {  
        Print("Ошибка WebRequest: код = ", GetLastError());} else {  
        Print("Сообщение успешно отправлено!");}}
        
        // Функция о проверке доступности бота
        string BuildEquityMessage_0() {
        string text = "Счет: ~" + string(AccountNumber()) + "~ ✅";
        return text;}

        // Функция для формирования отчёта о состоянии счёта
        string BuildEquityMessage_1() {
        string text = "Счет: ~" + string(AccountNumber()) + "~\n";
        {text+="                                             ";}
        if(standart==false){text+="\n Тек.эквити: "+string(DoubleToStr(NormalizeDouble(AccountEquity()/100,2),1)+"$");}
        if(standart==true){text+="\n Тек.эквити: "+string(DoubleToStr(NormalizeDouble(AccountEquity(),2),1)+"$");}
        {text+="                                             ";}
        if(standart==false){text+="\n Просад.: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-HelpAccount)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble(trr,2),1)+"%");text+="❗";}
        if(standart==true){text+="\n Просад.: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-HelpAccount),2),1)+"$ ")+string(DoubleToString(NormalizeDouble(trr,2),1)+"%");text+="❗";}
        {text+="                                             ";}
        if(standart==false){text+="\n До.цели: "+string(DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity())/100,2),2)+"$");}
        if(standart==true){text+="\n До.цели: "+string(DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity()),2),2)+"$");}
        return text;}
        
        string BuildEquityMessage_2() {
        string text = "Счет: ~" + string(AccountNumber()) + "~\n";
        {text+="                                             ";}
        if(standart==false) {text+="\n Тек.эквити: "+string(DoubleToStr(NormalizeDouble(AccountEquity()/100,2),1)+"$");}
        if(standart==true) {text+="\n Тек.эквити: "+string(DoubleToStr(NormalizeDouble(AccountEquity(),2),1)+"$");}
        {text+="                                             ";}
        if(standart==false) if(trr<(-2.0)){text+="\n Просад.: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-HelpAccount)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble(trr,2),1)+"%");text+="❗";}
        if(standart==true) if(trr<(-2.0)){text+="\n Просад.: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-HelpAccount),2),1)+"$ ")+string(DoubleToString(NormalizeDouble(trr,2),1)+"%");text+="❗";}
        {text+="                                             ";}
        if(standart==false) if((p0)>=0){text+="\n Сегодня: "+string(DoubleToStr(NormalizeDouble((p0)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r0),2),1)+"%");text+="💰";}
        if(standart==false) if((p0)<0){text+="\n Сегодня: "+string(DoubleToStr(NormalizeDouble((p0)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r0),2),1)+"%");text+="📉";}
        if(standart==true) if((p0)>=0){text+="\n Сегодня: "+string(DoubleToStr(NormalizeDouble((p0),2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r0),2),1)+"%");text+="💰";}
        if(standart==true) if((p0)<0){text+="\n Сегодня: "+string(DoubleToStr(NormalizeDouble((p0),2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r0),2),1)+"%");text+="📉";}
        {text+="                                             ";}
        if(standart==false) if((p1)>=0){text+="\n Вчера: "+string(DoubleToStr(NormalizeDouble((p1)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r1),2),1)+"%");text+="💰";}
        if(standart==false) if((p1)<0){text+="\n Вчера: "+string(DoubleToStr(NormalizeDouble((p1)/100,2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r1),2),1)+"%");text+="📉";}
        if(standart==true) if((p1)>=0){text+="\n Вчера: "+string(DoubleToStr(NormalizeDouble((p1),2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r1),2),1)+"%");text+="💰";}
        if(standart==true) if((p1)<0){text+="\n Вчера: "+string(DoubleToStr(NormalizeDouble((p1),2),1)+"$ ")+string(DoubleToString(NormalizeDouble((r1),2),1)+"%");text+="📉";}
        {text+="                                             ";}
        if(standart==false) if(AccountEquity()-Equity_mn1>=0){text+="\n Месяц: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1)/100,2),1)+"$ ")+DoubleToStr((AccountEquity()-Equity_mn1)/(Equity_mn1/100),1)+"%";text+="💰";}
        if(standart==false) if(AccountEquity()-Equity_mn1<0){text+="\n Месяц: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1)/100,2),1)+"$ ")+DoubleToStr((AccountEquity()-Equity_mn1)/(Equity_mn1/100),1)+"%";text+="📉";}
        if(standart==true) if(AccountEquity()-Equity_mn1>=0){text+="\n Месяц: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1),2),1)+"$ ")+DoubleToStr((AccountEquity()-Equity_mn1)/(Equity_mn1/100),1)+"%";text+="💰";}
        if(standart==true) if(AccountEquity()-Equity_mn1<0){text+="\n Месяц: "+string(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1),2),1)+"$ ")+DoubleToStr((AccountEquity()-Equity_mn1)/(Equity_mn1/100),1)+"%";text+="📉";}
        return text;}
        
        // Функция трал эквити
        string BuildEquityMessage_3() {
        string text;
        if(lastlos>=0){text+="Трал экв.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 💰";text+=" 🚀";}
        if(lastlos<0){text+="Трал экв.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 📉";text+=" 🚀";}
        return text;}
        
        // Функция трал динамический
        string BuildEquityMessage_4() {
        string text;
        if(lastlos>=0){text+="Трал дин.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 💰";text+=" 🚀";}
        if(lastlos<0){text+="Трал дин.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 📉";text+=" 🚀";}
        return text;}
        
        // Функция закр по профиту
        string BuildEquityMessage_5() {
        string text;
        if(lastlos>=0){text+="Закр. проф.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 💰";text+=" 🚀";}
        if(lastlos<0){text+="Закр. проф.: "+string(DoubleToStr(NormalizeDouble(lastlos,2),2))+"$";text+=" 📉";text+=" 🚀";}
        return text;}
        
        // Функция для покупки
        string BuildEquityMessage_buy() {
        string text;
        if(OrdersTotal()>0){text+="\n"+string(OrderSymbol());text+=": "+string(DoubleToStr(NormalizeDouble(OrderLots(),2),2));text+=" ⬆️";}
        return text;}
        
        // Функция для продажи
        string BuildEquityMessage_sell() {
        string text;
        if(OrdersTotal()>0){text+="\n"+string(OrderSymbol());text+=": "+string(DoubleToStr(NormalizeDouble(OrderLots(),2),2));text+=" ⬇️";}
        return text;}
        
        // Функция для тралл
        string BuildEquityMessage_6() {
        string text;
        if(standart==false){ 
        if(OrderProfit()>=0){text+="Тралл: "+string(DoubleToStr(NormalizeDouble(OrderProfit()/100,2),2))+"$ ";text+="💰";}
        if(OrderProfit()<0){text+="Тралл: "+string(DoubleToStr(NormalizeDouble(OrderProfit()/100,2),2))+"$ ";text+="📉";}}
        if(standart==true){ 
        if(OrderProfit()>=0){text+="Тралл: "+string(DoubleToStr(NormalizeDouble(OrderProfit(),2),2))+"$ ";text+="💰";}
        if(OrderProfit()<0){text+="Тралл: "+string(DoubleToStr(NormalizeDouble(OrderProfit(),2),2))+"$ ";text+="📉";}}
        return text;}
        
        // Функция для закр. позици buy
        string BuildEquityMessage_7() {
        string text;
        {text+="Закр.поз Buy";}
        return text;}
        
        // Функция для закр. позици sell
        string BuildEquityMessage_8() {
        string text;
        {text+="Закр.поз Sell";}
        return text;}
//-----------------------отправка сообщений в телеграмм-----------------------------------------

//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------
        //#property strict
        //#property show_inputs
        extern int DaysToAnalyze_D1=60;//Кол-во дней
        #define PAIRS_COUNT 6//Кол-во валютных пар
        extern int DaysToAnalyze_MN1=3;//Кол-во дней
 
        string pairs_D1[PAIRS_COUNT][2]={{"EURUSD","GBPUSD"},{"AUDCAD","AUDUSD"},{"EURAUD","GBPAUD"},{"AUDCHF","GBPCHF"},{"NZDUSD","NZDCAD"},{"USDCHF","CADCHF"}};
        //Буферы для хранения средней корреляции каждой пары
        double avgDiffs_D1[PAIRS_COUNT];
        double CalculatePercentageChange_D1(string symbol,int shift_D1){
        double priceStart_D1=iClose(symbol,PERIOD_D1,shift_D1);
        double priceEnd_D1=iClose(symbol,PERIOD_D1,shift_D1-1);
        if(priceStart_D1==0||priceEnd_D1==0)return 0;
        return((priceEnd_D1-priceStart_D1)/priceStart_D1)*100.0;}
        void AnalyzePair_D1(string symbol1,string symbol2,int pairIndex_D1,int yOffset_D1){
        double totalDiff_D1=0;int count_D1=0;
        for(int i_D1=1;i_D1<=DaysToAnalyze_D1;i_D1++){
        double change1_D1=CalculatePercentageChange_D1(symbol1,i_D1);
        double change2_D1=CalculatePercentageChange_D1(symbol2,i_D1);
        if(change1_D1==0||change2_D1==0)continue;
        double diff_D1=MathAbs(change1_D1-change2_D1);
        totalDiff_D1+=diff_D1;count_D1++;}
        if(count_D1>0){
        double avgDiff_D1=totalDiff_D1/count_D1;avgDiffs_D1[pairIndex_D1]=avgDiff_D1;//Сохраняем среднюю корреляцию в буфер
        }}
        
        string pairs_MN1[PAIRS_COUNT][2]={{"EURUSD","GBPUSD"},{"AUDCAD","AUDUSD"},{"EURAUD","GBPAUD"},{"AUDCHF","GBPCHF"},{"NZDUSD","NZDCAD"},{"USDCHF","CADCHF"}};
        //Буферы для хранения средней корреляции каждой пары
        double avgDiffs_MN1[PAIRS_COUNT];
        double CalculatePercentageChange_MN1(string symbol,int shift_MN1){
        double priceStart_MN1=iClose(symbol,PERIOD_MN1,shift_MN1);
        double priceEnd_MN1=iClose(symbol,PERIOD_MN1,shift_MN1-1);
        if(priceStart_MN1==0||priceEnd_MN1==0)return 0;
        return((priceEnd_MN1-priceStart_MN1)/priceStart_MN1)*100.0;}
        void AnalyzePair_MN1(string symbol1,string symbol2,int pairIndex_MN1,int yOffset_MN1){
        double totalDiff_MN1=0;int count_MN1=0;
        for(int i_MN1=1;i_MN1<=DaysToAnalyze_MN1;i_MN1++){
        double change1_MN1=CalculatePercentageChange_MN1(symbol1,i_MN1);
        double change2_MN1=CalculatePercentageChange_MN1(symbol2,i_MN1);
        if(change1_MN1==0||change2_MN1==0)continue;
        double diff_MN1=MathAbs(change1_MN1-change2_MN1);
        totalDiff_MN1+=diff_MN1;count_MN1++;}
        if(count_MN1>0){
        double avgDiff_MN1=totalDiff_MN1/count_MN1;avgDiffs_MN1[pairIndex_MN1]=avgDiff_MN1;//Сохраняем среднюю корреляцию в буфер
        }}
        
        // Функция для защиты от нулевых значений
        double GetSafeValue(double currentValue, double fallbackValue) {
        if(currentValue == 0) {
        return fallbackValue; // Возвращаем запасное значение, если текущие данные равны нулю
        }
        return currentValue;}
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------

//-----------------------проверяем ботов активен или нет--------------------------------------- 
        int xStart = 320;        // Начальная позиция по X
        int yStart = -2;        // Позиция по Y (одна строка)
        
        void DrawStatusDots(){
        datetime now = TimeCurrent();
        int dotSize = 14;       // Размер точки

        int xSpacing = 16;      // Расстояние между точками по горизонтали

        for (int b = 1; b <= TOTAL_BOTS; b++) {
        string botName = "Bot_" + IntegerToString(b);
        string varName = botName + "_Alive";
        double lastSeen = GlobalVariableGet(varName);
        bool active = (lastSeen != 0 && (now - lastSeen) < TIMEOUT);
        color dotColor = active ? clrLimeGreen : clrRed;

        string labelName = "Dot_" + IntegerToString(b);
        if(ObjectFind(0,labelName)==-1){
        ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, xStart + (b - 1) * xSpacing);
        ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, yStart);
        ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, dotSize);
        ObjectSetString(0, labelName, OBJPROP_FONT, "Wingdings");
        ObjectSetString(0, labelName, OBJPROP_TEXT, CharToStr(110)); // Круглая точка
        }
        ObjectSetInteger(0, labelName, OBJPROP_COLOR, dotColor);
        }}
//-----------------------проверяем ботов активен или нет--------------------------------------- 


        int t1_min=Minute();
//-----------------------распределяем слоты по времени-----------------------------------------
        void CheckCriticalFiles() {
        // 1. Проверяем файлы
        bool fileFlags[5];
        int activeCount = 0;
    
        fileFlags[0] = FileIsExist(filename_pr1);
        fileFlags[1] = FileIsExist(filename_pr2);
        fileFlags[2] = FileIsExist(filename_pr3);
        fileFlags[3] = FileIsExist(filename_pr4);
        fileFlags[4] = FileIsExist(filename_pr5);
        // 2. Собираем активные файлы (без выхода!)
        for(int i = 0; i < 5; i++) {
        if(fileFlags[i]) {
        activeCount++;
        Print("Файл ", i+1, " доступен");
        }}
        // 3. Всегда сбрасываем флаги (но не прерываем работу!)
        str1_time = str2_time = str3_time = str4_time = str5_time = 0;
        // 4. Если есть файлы - распределяем время
        if(activeCount > 0) {
        int slotSize = 60 / activeCount;
        int slotStart = 0;
        
        for(int i = 0; i < activeCount; i++) {
        int slotEnd = (i == activeCount-1) ? 60 : slotStart + slotSize;
            
        if(t1_min >= slotStart && t1_min < slotEnd) {
        switch(i) {  // Используем прямое соответствие
        case 0: str1_time = 1; break;
        case 1: str2_time = 1; break;
        case 2: str3_time = 1; break;
        case 3: str4_time = 1; break;
        case 4: str5_time = 1; break;
        }
        break;
        }
        slotStart = slotEnd;
        }}}
//-----------------------распределяем слоты по времени-----------------------------------------

//---------------------------------------------------------------------------------------------
        void OnTick(){  


//-----------------------работа со временем----------------------------------------------------
        datetime gmt_time=TimeGMT();       // Получаем текущее время по Гринвичу
        int gmt_hour=TimeHour(gmt_time);   // Получаем час по Гринвичу
//-----------------------работа со временем----------------------------------------------------

         if((gmt_hour==00&&Minute()>=10&&Minute()<=20)||(gmt_hour==07&&Minute()>=00&&Minute()<=10)||(gmt_hour==13&&Minute()>=30&&Minute()<=40))flag_4=1;else flag_4=0;
         if(Minute()>20&&Minute()<30)flag_5=1;else flag_5=0; // ставим флаги что бы не пересекался вывод шестеренок графика и дельты
     
//-----------------------расчитываем step11----------------------------------------------------
        double last_step_buy_11=0;
        double last_step_sell_11=0;
        //===BUY===
        if(CountBuy()>=1){
        step_buy_11=bestMaxPrice()+g_next_step_buy_px;
        if(MathAbs(step_buy_11-last_step_buy_11)>Point){
        last_step_buy_11=step_buy_11;
        EnsureHLine("step_buy_11", step_buy_11, col_1, 1, STYLE_DOT, true);

        EnsureText("MaxPrice", TimeCurrent(), step_buy_11, DoubleToStr(NormalizeDouble(step_buy_11,5),5), TextFONT, 10, col_1, true);}}

        //===SELL===
        if(CountSell()>=1){
        step_sell_11=bestMinPrice()-g_next_step_sell_px;
        if(MathAbs(step_sell_11-last_step_sell_11)>Point){
        last_step_sell_11=step_sell_11;
        EnsureHLine("step_sell_11", step_sell_11, col_1, 1, STYLE_DOT, true);

        EnsureText("MinPrice", TimeCurrent(), step_sell_11, DoubleToStr(NormalizeDouble(step_sell_11,5),5), TextFONT, 10, col_1, true);}}
//-----------------------расчитываем step11----------------------------------------------------

//-----------------------получаем время открытия последнего ордера-----------------------------
        //datetime tm=-1; 
        int cnt_123=OrdersTotal();
        for (int i=0; i<cnt_123;i++){
        if(!OrderSelect(i,SELECT_BY_POS, MODE_TRADES)) continue;
        tm=MathMax(tm,OrderOpenTime());}
//-----------------------получаем время открытия последнего ордера-----------------------------
       
//-----------------------считаем профит--------------------------------------------------------
        if(HelpAccount!=0&&OrdersTotal()>=1)lastprof=HelpAccount;
        if(HelpAccount==0&&OrdersTotal()==0)lastprof=lastprof;
        
        if(standart==true) lastlos=(AccountEquity()-lastprof);
        if(standart==false) lastlos=((AccountEquity()-lastprof)/100); 
//-----------------------считаем профит--------------------------------------------------------
      
//-----------------------считаем дни со входа в первую позицию серии---------------------------
        if(OrdersTotal()>=1){                // ищем время самого первого ордера в серии                             
        for(int i=0;i<OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)){
        firstEntryTime = OrderOpenTime();break;}}}

        string daysSinceFirst="daysSinceFirst.txt";
        string content_daysSinceFirst=(string)MathCeil((TimeCurrent() - firstEntryTime) / (60 * 60 * 24)); // 
        if(OrdersTotal()>=1){string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);
        
        if(master==true){
        int fileHandle=FileOpen(daysSinceFirst,FILE_WRITE|FILE_TXT); // Открываем файл для чтения
        if(fileHandle!=INVALID_HANDLE){
        FileWriteString(fileHandle,content_daysSinceFirst);
        FileClose(fileHandle);}}}

        if(OrdersTotal()>=1){string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
        int fileHandle=FileOpen(daysSinceFirst,FILE_READ); // Открываем файл для чтения
        if(fileHandle!=INVALID_HANDLE){
        string fileContents=FileReadString(fileHandle);     // Читаем содержимое файла
        daysSinceFirstEntry=StrToInteger(fileContents);     // Преобразуем содержимое файла в целое число
        FileClose(fileHandle);}}
        if(OrdersTotal()<1&&IsConnected())daysSinceFirstEntry=0;
        if(OrdersTotal()<1&&IsConnected())FileDelete("daysSinceFirst.txt");
//-----------------------считаем дни со входа в первую позицию серии---------------------------

//-----------------------считаем дни со входа в первую позицию серии---------------------------
        if(OrdersTotal()>=1){                // ищем время самого первого ордера в серии                             
        for(int i=0;i<OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS,MODE_TRADES)){
        firstEntryTime_h = OrderOpenTime();break;}}}

        string daysSinceFirst_h="daysSinceFirst_h.txt";
        string content_daysSinceFirst_h=(string)MathCeil((TimeCurrent() - firstEntryTime_h) / (60 * 60)); //  * 24
        if(OrdersTotal()>=1){string terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH);
        
        if(master==true){
        int fileHandle_h=FileOpen(daysSinceFirst_h,FILE_WRITE|FILE_TXT); // Открываем файл для чтения
        if(fileHandle_h!=INVALID_HANDLE){
        FileWriteString(fileHandle_h,content_daysSinceFirst_h);
        FileClose(fileHandle_h);}}}

        if(OrdersTotal()>=1){string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
        int fileHandle_h=FileOpen(daysSinceFirst_h,FILE_READ); // Открываем файл для чтения
        if(fileHandle_h!=INVALID_HANDLE){
        string fileContents_h=FileReadString(fileHandle_h);     // Читаем содержимое файла
        daysSinceFirstEntry_h=StrToInteger(fileContents_h);     // Преобразуем содержимое файла в целое число
        FileClose(fileHandle_h);}}
        if(OrdersTotal()<1&&IsConnected())daysSinceFirstEntry_h=0;
        if(OrdersTotal()<1&&IsConnected())FileDelete("daysSinceFirst_h.txt");
//-----------------------считаем дни со входа в первую позицию серии---------------------------

//-----------------------запись файла для ложного срабатывания при закрытии--------------------
        string filename="close_all.txt";string content_filename="Where is my money?";
        if(OrdersTotal()<1){
        if(!FileIsExist(filename)){ // Записываем только если файла нет
        int fileHandle=FileOpen(filename,FILE_WRITE|FILE_TXT);
        if(fileHandle!=INVALID_HANDLE){
        FileWriteString(fileHandle,content_filename);
        FileClose(fileHandle);}else {
        Print("Ошибка записи в файл: ",filename);}}}
//-----------------------запись файла для ложного срабатывания при закрытии--------------------

//-----------------------записываем HelpAccount------------------------------------------------
        string HelpAcc="HelpAccount.txt";
        string content_HelpAcc="";
        string my_terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
        if((OrdersTotal()>0)){ //||(AccountEquity()-AccountBalance()+bonus<0)||(AccountEquity()-AccountBalance()+bonus>0
        if(!FileIsExist(HelpAcc)){ // Файл создаем только если его нет
        content_HelpAcc=DoubleToStr(NormalizeDouble(AccountBalance()+bonus,2),2);
        int fileHandle=FileOpen(HelpAcc,FILE_WRITE|FILE_TXT);
        if(fileHandle!=INVALID_HANDLE){
        FileWriteString(fileHandle,content_HelpAcc);
        FileClose(fileHandle);}else{Print("Ошибка записи в файл: ",HelpAcc);}}}
        // Читаем файл (если он уже существует)
        int fileHandle2=FileOpen(HelpAcc,FILE_READ);
        if(fileHandle2!=INVALID_HANDLE){
        content_HelpAcc=FileReadString(fileHandle2);
        HelpAccount=StrToDouble(content_HelpAcc);
        FileClose(fileHandle2);}
//-----------------------записываем HelpAccount------------------------------------------------

//-----------------------записываем эквити на 1 число месяца-----------------------------------
        string Fix_Equity_mn1="equity_mn1.txt";
        string content_Fix_Equity_mn1="";
        // Проверяем, существует ли файл, чтобы не перезаписывать его на каждом запуске
        if(!FileIsExist(Fix_Equity_mn1)){ 
        content_Fix_Equity_mn1=DoubleToStr(NormalizeDouble(AccountEquity(),2),2);
        int fileHandle_mn1=FileOpen(Fix_Equity_mn1,FILE_WRITE|FILE_TXT);
        if(fileHandle_mn1!=INVALID_HANDLE){
        FileWriteString(fileHandle_mn1,content_Fix_Equity_mn1);
        FileClose(fileHandle_mn1);}else {Print("Ошибка записи в файл: ",Fix_Equity_mn1);}}
        // Читаем файл (если он уже есть)
        int fileHandle2_mn1=FileOpen(Fix_Equity_mn1,FILE_READ);
        if(fileHandle2_mn1!=INVALID_HANDLE){
        content_Fix_Equity_mn1=FileReadString(fileHandle2_mn1);
        Equity_mn1=StrToDouble(content_Fix_Equity_mn1);
        FileClose(fileHandle2_mn1);}
//-----------------------записываем эквити на 1 число месяца-----------------------------------



//-----------------------записываем count_close------------------------------------------------
        string cc = "count_close.txt";string content_cc = "";
        string my_terminal_data_path_cc = TerminalInfoString(TERMINAL_DATA_PATH);
        
        if (FileIsExist(cc,0)<1){ 
        count_close=0;
        content_cc = DoubleToStr(NormalizeDouble(count_close,2),0);
        int fileHandle = FileOpen(cc, FILE_WRITE | FILE_TXT);
        if (fileHandle != INVALID_HANDLE){
        FileWriteString(fileHandle, content_cc);
        FileClose(fileHandle);
        }}
        
        if (FileIsExist(cc,0)>=1&&count_close!=0){ 
        content_cc = DoubleToStr(NormalizeDouble(count_close,2),0);
        int fileHandle = FileOpen(cc, FILE_WRITE | FILE_TXT);
        if (fileHandle != INVALID_HANDLE){
        FileWriteString(fileHandle, content_cc);
        FileClose(fileHandle);
        }}

        int fileHandle2_cc = FileOpen(cc,FILE_READ);
        if (fileHandle2_cc != INVALID_HANDLE){
        content_cc = FileReadString(fileHandle2_cc);
        count_close = StrToDouble(content_cc);
        FileClose(fileHandle2_cc);}
//-----------------------записываем count_close------------------------------------------------

               
//-----------------------cчитаем закрытый объем------------------------------------------------
        int today = TimeDay(TimeCurrent());
        // Новый день — обнуляем
        if (today != currentDay_vol){
        currentDay_vol = today;
        totalVolume = 0;}
        // Пересчёт объёма за текущий день
        totalVolume = 0; // Сначала сбросим перед пересчётом
        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--){
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
        if (OrderType() <= OP_SELL && TimeDay(OrderCloseTime()) == currentDay_vol){
        totalVolume += OrderLots();}}}
//-----------------------cчитаем закрытый объем------------------------------------------------

//-----------------------цвет графика в зависимости от позиции---------------------------------
       static bool colorSet=false;//Флаг,был ли уже установлен цвет
       static color lastBgColor=col_17;//Храним последний установленный цвет
       color bgColor=col_17;//Цвет по умолчанию

       if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1)bgColor=C'10,10,46';
       else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1)bgColor=C'51,0,0';
       else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1)bgColor=C'0,23,0';

       //Меняем цвет только если они зменился и если он ещё не был установлен
       if(bgColor!=lastBgColor||!colorSet){
       ChartSetInteger(0,CHART_COLOR_BACKGROUND,bgColor);
       lastBgColor=bgColor;colorSet=true;}
//-----------------------цвет графика в зависимости от позиции--------------------------------- 

//-----------------------удаляем объекты, очищаем переменные-----------------------------------
       if(CountSell()<=0){ 
       if(ObjectFind(0,"step_sell_11")!=-1)ObjectDelete(0,"step_sell_11");
       if(ObjectFind(0,"MinPrice")!=-1)ObjectDelete(0,"MinPrice");
       step_sell_11=0;minSellPrice=0;}
        
       if(CountBuy()<=0){
       if(ObjectFind(0,"step_buy_11")!=-1)ObjectDelete(0,"step_buy_11");
       if(ObjectFind(0,"MaxPrice")!=-1)ObjectDelete(0,"MaxPrice");
       step_buy_11=0;maxBuyPrice=0;} 

       if(OrdersTotal()<=0){
       flag_6 = 0;
       if(FileIsExist("HelpAccount.txt")){FileDelete("HelpAccount.txt");}
       if(FileIsExist("str1.txt")){FileDelete("str1.txt");}
       if(FileIsExist("str2.txt")){FileDelete("str2.txt");}
       if(FileIsExist("str3.txt")){FileDelete("str3.txt");}
       if(FileIsExist("str4.txt")){FileDelete("str4.txt");}
       if(FileIsExist("str5.txt")){FileDelete("str5.txt");}
       ObjectsDeleteAll(0,OBJ_TREND);
       ObjectsDeleteAll(0,OBJ_ARROW);
       DeleteObjectsWithText("sl modified");
       DeleteObjectsWithText("tp modified");
       DeleteObjectsWithText("down_arrow");
       HelpAccount777_down=0;HelpAccount_down=0;HelpAccount=0;} 
       
       if(OrdersTotal()>=1){
       if(FileIsExist("str_pr1.txt")){FileDelete("str_pr1.txt");}
       if(FileIsExist("str_pr2.txt")){FileDelete("str_pr2.txt");}
       if(FileIsExist("str_pr3.txt")){FileDelete("str_pr3.txt");}
       if(FileIsExist("str_pr4.txt")){FileDelete("str_pr4.txt");}
       if(FileIsExist("str_pr5.txt")){FileDelete("str_pr5.txt");}} 
       
       if((Minute()==00||Minute()==10||Minute()==20||Minute()==30||Minute()==40||Minute()==50)&&Seconds()>=00&&Seconds()<=05){
       ObjectsDeleteAll(0,OBJ_TREND);
       ObjectsDeleteAll(0,OBJ_ARROW);
       DeleteObjectsWithText("sl modified");
       DeleteObjectsWithText("tp modified");
       DeleteObjectsWithText("down_arrow");} 
        
       if((gmt_hour==20&&Minute()==00)&&Seconds()>=00&&Seconds()<=10){ //+3 часа по Москве
       delta_EURUSD_GBPUSD_average=0;
       delta_AUDCAD_AUDUSD_average=0;
       delta_EURAUD_GBPAUD_average=0;
       delta_AUDCHF_GBPCHF_average=0;
       delta_NZDUSD_NZDCAD_average=0;
       delta_USDCHF_CADCHF_average=0;
       event_34=0;event_35=0;event_36=0;event_1=1;
       count_close=0;count_trall=0;order_total=0;
       ObjectsDeleteAll(0,OBJ_ARROW);
       ObjectsDeleteAll(0,OBJ_TREND);
       ObjectsDeleteAll(0,OBJ_VLINE);
       DeleteObjectsWithText("line");
       if(FileIsExist("count_close.txt")){FileDelete("count_close.txt");}
       count_close = 0;}       
//-----------------------удаляем объекты, очищаем переменные-----------------------------------

//-----------------------расчитываем step ы----------------------------------------------------
       // NOTE: Step computation now handled by OnTimer via steps_unified.mqh
       // The cached values g_next_step_buy, g_next_step_sell, g_next_step_buy_px, g_next_step_sell_px
       // are updated automatically when order counts change.
       // Legacy variables next_step_buy, next_step_sell, next_step_buy_11, next_step_sell_11 
       // are kept for backward compatibility but can be mapped to cache if needed.
       next_step_buy = g_next_step_buy;
       next_step_sell = g_next_step_sell;
       next_step_buy_11 = g_next_step_buy_px;
       next_step_sell_11 = g_next_step_sell_px;
//-----------------------расчитываем step ы----------------------------------------------------
      
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------
       // Переменные для анализа
       int currentDay = 0; // текущий сдвиг для дней
       int currentMonth = 0; // текущий сдвиг для месяцев
       // Анализируем валютные пары для дней (D1)
       for(int i_D1 = 0; i_D1 < PAIRS_COUNT; i_D1++) {
       string symbol1 = pairs_D1[i_D1][0];
       string symbol2 = pairs_D1[i_D1][1];
       // Вызываем функцию анализа для дня (D1)
       AnalyzePair_D1(symbol1, symbol2, i_D1, currentDay);
       // Если в процессе анализа получается ноль, подставляем значение из другого буфера
       if(avgDiffs_D1[i_D1] == 0) {
       avgDiffs_D1[i_D1] = GetSafeValue(avgDiffs_D1[i_D1],0.2); // Пример подстановки значения
       }
       // Записываем в соответствующие буферы
       if (i_D1 == 0) delta_EURUSD_GBPUSD_d = avgDiffs_D1[i_D1];
       if (i_D1 == 1) delta_AUDCAD_AUDUSD_d = avgDiffs_D1[i_D1];
       if (i_D1 == 2) delta_EURAUD_GBPAUD_d = avgDiffs_D1[i_D1];
       if (i_D1 == 3) delta_AUDCHF_GBPCHF_d = avgDiffs_D1[i_D1];
       if (i_D1 == 4) delta_NZDUSD_NZDCAD_d = avgDiffs_D1[i_D1];
       if (i_D1 == 5) delta_USDCHF_CADCHF_d = avgDiffs_D1[i_D1];}
       // Анализируем валютные пары для месяцев (MN1)
       for(int i_MN1 = 0; i_MN1 < PAIRS_COUNT; i_MN1++) {
       string symbol1 = pairs_MN1[i_MN1][0];
       string symbol2 = pairs_MN1[i_MN1][1];
       // Вызываем функцию анализа для месяца (MN1)
       AnalyzePair_MN1(symbol1, symbol2, i_MN1, currentMonth);
       // Если в процессе анализа получается ноль, подставляем значение из другого буфера
       if(avgDiffs_MN1[i_MN1] == 0) {
       avgDiffs_MN1[i_MN1] = GetSafeValue(avgDiffs_MN1[i_MN1],2); // Пример подстановки значения
       }
       // Записываем в соответствующие буферы для месяцев
       if (i_MN1 == 0) delta_EURUSD_GBPUSD_MN1_strong = avgDiffs_MN1[i_MN1];
       if (i_MN1 == 1) delta_AUDCAD_AUDUSD_MN1_strong = avgDiffs_MN1[i_MN1];
       if (i_MN1 == 2) delta_EURAUD_GBPAUD_MN1_strong = avgDiffs_MN1[i_MN1];
       if (i_MN1 == 3) delta_AUDCHF_GBPCHF_MN1_strong = avgDiffs_MN1[i_MN1];
       if (i_MN1 == 4) delta_NZDUSD_NZDCAD_MN1_strong = avgDiffs_MN1[i_MN1];
       if (i_MN1 == 5) delta_USDCHF_CADCHF_MN1_strong = avgDiffs_MN1[i_MN1];}

       delta_EURUSD_GBPUSD_MN1_strong1 = delta_EURUSD_GBPUSD_MN1_strong*st_delta_1*koeff_delta;
       delta_EURUSD_GBPUSD_MN1_strong2 = delta_EURUSD_GBPUSD_MN1_strong*st_delta_2*koeff_delta;
       delta_EURUSD_GBPUSD_MN1_strong3 = delta_EURUSD_GBPUSD_MN1_strong*st_delta_3*koeff_delta;
       delta_EURUSD_GBPUSD_MN1_strong4 = delta_EURUSD_GBPUSD_MN1_strong*st_delta_4*koeff_delta;
       delta_EURUSD_GBPUSD_MN1_strong5 = delta_EURUSD_GBPUSD_MN1_strong*st_delta_5*koeff_delta;

       delta_AUDCAD_AUDUSD_MN1_strong1 = delta_AUDCAD_AUDUSD_MN1_strong*st_delta_1*koeff_delta;
       delta_AUDCAD_AUDUSD_MN1_strong2 = delta_AUDCAD_AUDUSD_MN1_strong*st_delta_2*koeff_delta;
       delta_AUDCAD_AUDUSD_MN1_strong3 = delta_AUDCAD_AUDUSD_MN1_strong*st_delta_3*koeff_delta;
       delta_AUDCAD_AUDUSD_MN1_strong4 = delta_AUDCAD_AUDUSD_MN1_strong*st_delta_4*koeff_delta;
       delta_AUDCAD_AUDUSD_MN1_strong5 = delta_AUDCAD_AUDUSD_MN1_strong*st_delta_5*koeff_delta;
        
       delta_EURAUD_GBPAUD_MN1_strong1 = delta_EURAUD_GBPAUD_MN1_strong*st_delta_1*koeff_delta;
       delta_EURAUD_GBPAUD_MN1_strong2 = delta_EURAUD_GBPAUD_MN1_strong*st_delta_2*koeff_delta;
       delta_EURAUD_GBPAUD_MN1_strong3 = delta_EURAUD_GBPAUD_MN1_strong*st_delta_3*koeff_delta;
       delta_EURAUD_GBPAUD_MN1_strong4 = delta_EURAUD_GBPAUD_MN1_strong*st_delta_4*koeff_delta;
       delta_EURAUD_GBPAUD_MN1_strong5 = delta_EURAUD_GBPAUD_MN1_strong*st_delta_5*koeff_delta;
        
       delta_AUDCHF_GBPCHF_MN1_strong1 = delta_AUDCHF_GBPCHF_MN1_strong*st_delta_1*koeff_delta;
       delta_AUDCHF_GBPCHF_MN1_strong2 = delta_AUDCHF_GBPCHF_MN1_strong*st_delta_2*koeff_delta;
       delta_AUDCHF_GBPCHF_MN1_strong3 = delta_AUDCHF_GBPCHF_MN1_strong*st_delta_3*koeff_delta;
       delta_AUDCHF_GBPCHF_MN1_strong4 = delta_AUDCHF_GBPCHF_MN1_strong*st_delta_4*koeff_delta;
       delta_AUDCHF_GBPCHF_MN1_strong5 = delta_AUDCHF_GBPCHF_MN1_strong*st_delta_5*koeff_delta;
        
       delta_NZDUSD_NZDCAD_MN1_strong1 = delta_NZDUSD_NZDCAD_MN1_strong*st_delta_1*koeff_delta;
       delta_NZDUSD_NZDCAD_MN1_strong2 = delta_NZDUSD_NZDCAD_MN1_strong*st_delta_2*koeff_delta;
       delta_NZDUSD_NZDCAD_MN1_strong3 = delta_NZDUSD_NZDCAD_MN1_strong*st_delta_3*koeff_delta;
       delta_NZDUSD_NZDCAD_MN1_strong4 = delta_NZDUSD_NZDCAD_MN1_strong*st_delta_4*koeff_delta;
       delta_NZDUSD_NZDCAD_MN1_strong5 = delta_NZDUSD_NZDCAD_MN1_strong*st_delta_5*koeff_delta;
        
       delta_USDCHF_CADCHF_MN1_strong1 = delta_USDCHF_CADCHF_MN1_strong*st_delta_1*koeff_delta;
       delta_USDCHF_CADCHF_MN1_strong2 = delta_USDCHF_CADCHF_MN1_strong*st_delta_2*koeff_delta;
       delta_USDCHF_CADCHF_MN1_strong3 = delta_USDCHF_CADCHF_MN1_strong*st_delta_3*koeff_delta;
       delta_USDCHF_CADCHF_MN1_strong4 = delta_USDCHF_CADCHF_MN1_strong*st_delta_4*koeff_delta;
       delta_USDCHF_CADCHF_MN1_strong5 = delta_USDCHF_CADCHF_MN1_strong*st_delta_5*koeff_delta;

       if((gmt_hour>=00&&gmt_hour<07)||(gmt_hour==23&& Minute()>=00&& Minute()<= 59)){
       delta_EURUSD_GBPUSD = delta_EURUSD_GBPUSD_d/st3;
       delta_AUDCAD_AUDUSD = delta_AUDCAD_AUDUSD_d/st3;
       delta_EURAUD_GBPAUD = delta_EURAUD_GBPAUD_d/st3;
       delta_AUDCHF_GBPCHF = delta_AUDCHF_GBPCHF_d/st3;
       delta_NZDUSD_NZDCAD = delta_NZDUSD_NZDCAD_d/st3;
       delta_USDCHF_CADCHF = delta_USDCHF_CADCHF_d/st3;}
        
       if(gmt_hour>=07&&gmt_hour<13){
       delta_EURUSD_GBPUSD = delta_EURUSD_GBPUSD_d/st2;
       delta_AUDCAD_AUDUSD = delta_AUDCAD_AUDUSD_d/st2;
       delta_EURAUD_GBPAUD = delta_EURAUD_GBPAUD_d/st2;
       delta_AUDCHF_GBPCHF = delta_AUDCHF_GBPCHF_d/st2;
       delta_NZDUSD_NZDCAD = delta_NZDUSD_NZDCAD_d/st2;
       delta_USDCHF_CADCHF = delta_USDCHF_CADCHF_d/st2;}
        
       if(gmt_hour>=13&&gmt_hour<23){
       delta_EURUSD_GBPUSD = delta_EURUSD_GBPUSD_d/st1;
       delta_AUDCAD_AUDUSD = delta_AUDCAD_AUDUSD_d/st1;
       delta_EURAUD_GBPAUD = delta_EURAUD_GBPAUD_d/st1;
       delta_AUDCHF_GBPCHF = delta_AUDCHF_GBPCHF_d/st1;
       delta_NZDUSD_NZDCAD = delta_NZDUSD_NZDCAD_d/st1;
       delta_USDCHF_CADCHF = delta_USDCHF_CADCHF_d/st1;}
//-----------------------считаем среднюю дельту за n дней/месяцев------------------------------

//----------------------задаю значение профита по эквити в зависимости от времени--------------
        if(daysSinceFirstEntry<1){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1);c3=c2/10;c1=c2*4;c28=c2*6;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2);c3=c2/10;c1=c2*4;c28=c2*6;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3);c3=c2/10;c1=c2*4;c28=c2*6;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4);c3=c2/10;c1=c2*4;c28=c2*6;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5);c3=c2/10;c1=c2*4;c28=c2*6;}}
        
        if(daysSinceFirstEntry>=1&&daysSinceFirstEntry<4){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1*koef5);c3=c2/10*koef5;c1=c2*4*koef5;c28=c2*6*koef5;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2*koef5);c3=c2/10*koef5;c1=c2*4*koef5;c28=c2*6*koef5;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3*koef5);c3=c2/10*koef5;c1=c2*4*koef5;c28=c2*6*koef5;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4*koef5);c3=c2/10*koef5;c1=c2*4*koef5;c28=c2*6*koef5;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5*koef5);c3=c2/10*koef5;c1=c2*4*koef5;c28=c2*6*koef5;}}
        
        if(daysSinceFirstEntry>=4&&daysSinceFirstEntry<8){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1*koef10);c3=c2/10*koef10;c1=c2*4*koef10;c28=c2*6*koef10;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2*koef10);c3=c2/10*koef10;c1=c2*4*koef10;c28=c2*6*koef10;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3*koef10);c3=c2/10*koef10;c1=c2*4*koef10;c28=c2*6*koef10;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4*koef10);c3=c2/10*koef10;c1=c2*4*koef10;c28=c2*6*koef10;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5*koef10);c3=c2/10*koef10;c1=c2*4*koef10;c28=c2*6*koef10;}}
        
        if(daysSinceFirstEntry>=8&&daysSinceFirstEntry<12){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1*koef15);c3=c2/10*koef15;c1=c2*4*koef15;c28=c2*6*koef15;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2*koef15);c3=c2/10*koef15;c1=c2*4*koef15;c28=c2*6*koef15;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3*koef15);c3=c2/10*koef15;c1=c2*4*koef15;c28=c2*6*koef15;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4*koef15);c3=c2/10*koef15;c1=c2*4*koef15;c28=c2*6*koef15;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5*koef15);c3=c2/10*koef15;c1=c2*4*koef15;c28=c2*6*koef15;}}
        
        if(daysSinceFirstEntry>=12&&daysSinceFirstEntry<16){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1*koef20);c3=c2/10*koef20;c1=c2*4*koef20;c28=c2*6*koef20;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2*koef20);c3=c2/10*koef20;c1=c2*4*koef20;c28=c2*6*koef20;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3*koef20);c3=c2/10*koef20;c1=c2*4*koef20;c28=c2*6*koef20;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4*koef20);c3=c2/10*koef20;c1=c2*4*koef20;c28=c2*6*koef20;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5*koef20);c3=c2/10*koef20;c1=c2*4*koef20;c28=c2*6*koef20;}}
        
        if(daysSinceFirstEntry>=16){
        double multiplier=standart?1:100;
        if(FileIsExist(filename1,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st1*koef25);c3=c2/10*koef25;c1=c2*4*koef25;c28=c2*6*koef25;}
        if(FileIsExist(filename2,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st2*koef25);c3=c2/10*koef25;c1=c2*4*koef25;c28=c2*6*koef25;}
        if(FileIsExist(filename3,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st3*koef25);c3=c2/10*koef25;c1=c2*4*koef25;c28=c2*6*koef25;}
        if(FileIsExist(filename4,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st4*koef25);c3=c2/10*koef25;c1=c2*4*koef25;c28=c2*6*koef25;}
        if(FileIsExist(filename5,0)>=1){
        c2=(CalculateOpenVolume()/c29*multiplier*st5*koef25);c3=c2/10*koef25;c1=c2*4*koef25;c28=c2*6*koef25;}}
//-----------------------конец задаю значение профита по эквити в зависимости от времени-------

//-----------------------количество ордеров в зависимости от баланса---------------------------
        double balance_real=(standart ? (AccountBalance()+bonus) / 100 : AccountBalance()+bonus);
        if(balance_real<=100) max_lot=30;
        else if(balance_real < 150) max_lot=40;
        else if(balance_real < 200) max_lot=60;
        else max_lot=80;
//-----------------------количество ордеров в зависимости от баланса---------------------------

//-----------------------считаем профитные убыточные позиции-----------------------------------     
       double profit_buy_all=0, profit_sell_all=0;
       int ib_all, kb_all=OrdersTotal();for(ib_all=0; ib_all<kb_all; ib_all++){
       if(OrderSelect(ib_all, SELECT_BY_POS, MODE_TRADES)){
       if(OrderType()==OP_BUY) profit_buy_all+=OrderProfit()+OrderCommission()+OrderSwap();}}
       int is_all, ks_all=OrdersTotal();for(is_all=0; is_all<ks_all; is_all++){
       if(OrderSelect(is_all, SELECT_BY_POS, MODE_TRADES)){
       if(OrderType()==OP_SELL) profit_sell_all+=OrderProfit()+OrderCommission()+OrderSwap();}}
//-----------------------считаем профитные убыточные позиции-----------------------------------

//-----------------------считаем профитные убыточные позиции-----------------------------------     
       double profit_buy=0, profit_sell=0;
       int ib, kb=OrdersTotal();for(ib=0; ib<kb; ib++){
       if(OrderSelect(ib, SELECT_BY_POS, MODE_TRADES)){
       if(OrderMagicNumber()==order_magic){
       if(OrderType()==OP_BUY) profit_buy+=OrderProfit()+OrderCommission()+OrderSwap();}}}
       
       int is, ks=OrdersTotal();for(is=0; is<ks; is++){
       if(OrderSelect(is, SELECT_BY_POS, MODE_TRADES)){
       if(OrderMagicNumber()==order_magic){
       if(OrderType()==OP_SELL) profit_sell+=OrderProfit()+OrderCommission()+OrderSwap();}}}
//-----------------------считаем профитные убыточные позиции-----------------------------------


//-----------------------прибыль сегодня вчера месяц-------------------------------------------
        datetime d0,d1,d2,d3,d4;
        double tb=AccountBalance()+bonus,tr=AccountProfit(),trr_tr=tr*100/tb;

        d0=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE));while(TimeDayOfWeek(d0)<1||TimeDayOfWeek(d0)>6)d0-=24*60*60;//пнд
        d1=d0-24*60*60;while(TimeDayOfWeek(d1)<1||TimeDayOfWeek(d1)>6)d1-=24*60*60;//вт
        d2=d1-24*60*60;while(TimeDayOfWeek(d2)<1||TimeDayOfWeek(d2)>6)d2-=24*60*60;//ср
        d3=d2-24*60*60;while(TimeDayOfWeek(d3)<1||TimeDayOfWeek(d3)>6)d3-=24*60*60;//чт
        d4=d3-24*60*60;while(TimeDayOfWeek(d4)<1||TimeDayOfWeek(d4)>6)d4-=24*60*60;//пт
       
        p0=GetProfitFromDateInCurrency("",-1,-1,d0+(int)(OrderCommission()+OrderSwap()));
        p1=GetProfitFromDateInCurrency("",-1,-1,d1+(int)(OrderCommission()+OrderSwap()))-p0;
        p2=GetProfitFromDateInCurrency("",-1,-1,d2+(int)(OrderCommission()+OrderSwap()))-p1-p0;
        p3=GetProfitFromDateInCurrency("",-1,-1,d3+(int)(OrderCommission()+OrderSwap()))-p2-p1-p0;
        p4=GetProfitFromDateInCurrency("",-1,-1,d4+(int)(OrderCommission()+OrderSwap()))-p3-p2-p1-p0;

        if(HelpAccount!=0)trr=(AccountEquity()-HelpAccount)/(HelpAccount/100);
        if(HelpAccount==0)trr=tr*100/tb;

        r0=p0*100/tb;r1=p1*100/tb;r2=p2*100/tb;r3=p3*100/tb;r4=p4*100/tb;          
//-----------------------конец прибыль сегодня вчера месяц-------------------------------------

//-----------------------значения, переменные функции для панели info--------------------------
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        if(info_0==true){ 
//------------------------отправка отчета в телеграмм------------------------------------------
        if (telegram == true) {
        datetime now_0 = TimeCurrent();
        if (TimeMinute(now_0) == 1 && (now_0 - lastSendTime_0) > 60) {
        SendTelegramMessage(BuildEquityMessage_0());
        lastSendTime_0 = now_0;}
        
        datetime now_1 = TimeCurrent();
        if (trr < -2.0 && TimeMinute(now_1) == 2 && (now_1 - lastSendTime_1) > 60) {
        SendTelegramMessage(BuildEquityMessage_1());
        lastSendTime_1 = now_1;}

        datetime now_2 = TimeCurrent();
        if (gmt_hour == 18 && Minute() == 3 && TimeMinute(now_2) == 3 && (now_2 - lastSendTime_2) > 60) {
        SendTelegramMessage(BuildEquityMessage_2());
        lastSendTime_2 = now_2;}
        }
//------------------------отправка отчета в телеграмм------------------------------------------
             
//--------------------------сообщения в панель-------------------------------------------------
       if(gmt_hour==18){
       
       if(standart==false){
       datetime now_3 = TimeCurrent();
       if (TimeMinute(now_3) == 4 && (now_3 - lastSendTime_3) > 60) {
       alert_0=StringConcatenate("Месяц: ",(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1)/100,2),2)),"$");
       lastSendTime_3 = now_3;}
       datetime now_4 = TimeCurrent();
       if (TimeMinute(now_4) == 5 && (now_4 - lastSendTime_4) > 60) {
       alert_0=StringConcatenate("Вчера: ",(DoubleToStr(NormalizeDouble((p1)/100,2),2)),"$");
       lastSendTime_4 = now_4;}
       datetime now_5 = TimeCurrent();
       if (TimeMinute(now_5) == 6 && (now_5 - lastSendTime_5) > 60) {
       alert_0=StringConcatenate("Сегодня: ",(DoubleToStr(NormalizeDouble((p0)/100,2),2)),"$");
       lastSendTime_5 = now_5;}}
       
       if(standart==true){
       datetime now_3 = TimeCurrent();
       if (TimeMinute(now_3) == 4 && (now_3 - lastSendTime_3) > 60) {
       alert_0=StringConcatenate("Месяц: ",(DoubleToStr(NormalizeDouble((AccountEquity()-Equity_mn1),2),2)),"$");
       lastSendTime_3 = now_3;}
       datetime now_4 = TimeCurrent();
       if (TimeMinute(now_4) == 5 && (now_4 - lastSendTime_4) > 60) {
       alert_0=StringConcatenate("Вчера: ",(DoubleToStr(NormalizeDouble((p1),2),2)),"$");
       lastSendTime_4 = now_4;}
       datetime now_5 = TimeCurrent();
       if (TimeMinute(now_5) == 6 && (now_5 - lastSendTime_5) > 60) {
       alert_0=StringConcatenate("Сегодня: ",(DoubleToStr(NormalizeDouble((p0),2),2)),"$");
       lastSendTime_5 = now_5;}}
       
       if(Minute()==07){
       datetime now_6 = TimeCurrent();
       if (TimeMinute(now_6) == 7 && (now_6 - lastSendTime_6) > 60) {
       if(p0>=5*par5)alert_0=StringConcatenate("Отличный день, работаем");
       if(p0>=2.5*par5&&p0<5*par5)alert_0=StringConcatenate("Достойно, но надо лучше");
       if(p0>=0.1*par5&&p0<2.5*par5)alert_0=StringConcatenate("Нормально, прибыль есть");
       if(p0<=-5*par5)alert_0=StringConcatenate("Это катастрофа, иди домой");
       if(p0>-5*par5&&p0<=-2.5*par5)alert_0=StringConcatenate("Очень слабо, не твой день");
       if(p0>-2.5*par5&&p0<0.1*par5)alert_0=StringConcatenate("Так себе денек, не задалось");
       lastSendTime_6 = now_6;
       }}}
            
       
       if(gmt_hour==00){
       datetime now_7 = TimeCurrent();
       if (TimeMinute(now_7) == 3 && (now_7 - lastSendTime_7) > 60) {
       alert_0=StringConcatenate("Открытие Азиатской сессии");
       lastSendTime_7 = now_7;}
       
       datetime now_8 = TimeCurrent();
       if (TimeMinute(now_8) == 2 && (now_8 - lastSendTime_8) > 60) {
       alert_0=StringConcatenate("Высокая волатильность");
       lastSendTime_8 = now_8;}
       
       datetime now_9 = TimeCurrent();
       if (TimeMinute(now_9) == 1 && (now_9 - lastSendTime_9) > 60) {
       if(DayOfWeek()==1){alert_0=StringConcatenate("Стригем хомяков дальше");}
       if(DayOfWeek()==2){alert_0=StringConcatenate("Шкурим хомячков дальше");}
       if(DayOfWeek()==3){alert_0=StringConcatenate("Работаем дальше");}
       if(DayOfWeek()==4){alert_0=StringConcatenate("Делаем бабки дальше");}
       if(DayOfWeek()==5){alert_0=StringConcatenate("Продолжаем генерить профит");}
       lastSendTime_9 = now_9;
       }}
       
       if(gmt_hour==06){
       datetime now_10 = TimeCurrent();
       if (TimeMinute(now_10) == 1 && (now_10 - lastSendTime_10) > 60) {
       if(DayOfWeek()==1){alert_0=StringConcatenate("Пора работать. Новый день!");}
       if(DayOfWeek()==2){alert_0=StringConcatenate("Доброе! Начнем торговлю?");}
       if(DayOfWeek()==3){alert_0=StringConcatenate("Пора зарабатывать бабки!");}
       if(DayOfWeek()==4){alert_0=StringConcatenate("Новый день! Порвем рынок?");}
       if(DayOfWeek()==5){alert_0=StringConcatenate("Начинаем косить рынок?");}
       lastSendTime_10 = now_10;
       }}
       
       if(gmt_hour==07){
       datetime now_11 = TimeCurrent();
       if (TimeMinute(now_11) == 3 && (now_11 - lastSendTime_11) > 60) {
       alert_0=StringConcatenate("Открытие Лондонской сессии");
       lastSendTime_11 = now_11;}
       
       datetime now_12 = TimeCurrent();
       if (TimeMinute(now_12) == 2 && (now_12 - lastSendTime_12) > 60) {
       alert_0=StringConcatenate("Высокая волатильность");
       lastSendTime_12 = now_12;}
       
       datetime now_13 = TimeCurrent();
       if (TimeMinute(now_13) == 1 && (now_13 - lastSendTime_13) > 60) {
       if(DayOfWeek()==1){alert_0=StringConcatenate("Продолжаем торговать");}
       if(DayOfWeek()==2){alert_0=StringConcatenate("Продолжаем стричь хомяков");}
       if(DayOfWeek()==3){alert_0=StringConcatenate("Продолжаем бомбить рынок");}
       if(DayOfWeek()==4){alert_0=StringConcatenate("Продолжаем зарабатывать бабки");}
       if(DayOfWeek()==5){alert_0=StringConcatenate("Продолжаем косить рынок");}
       lastSendTime_13 = now_13;
       }}
       
       if(gmt_hour==13){
       datetime now_14 = TimeCurrent();
       if (TimeMinute(now_14) == 32 && (now_14 - lastSendTime_14) > 60) {
       alert_0=StringConcatenate("Открытие Нью-Йорк");
       lastSendTime_14 = now_14;}
       
       datetime now_15 = TimeCurrent();
       if (TimeMinute(now_15) == 31 && (now_15 - lastSendTime_15) > 60) {
       alert_0=StringConcatenate("Высокая волатильность");
       lastSendTime_15 = now_15;}
       
       datetime now_16 = TimeCurrent();
       if (TimeMinute(now_16) == 30 && (now_16 - lastSendTime_16) > 60) {
       if(DayOfWeek()==1){alert_0=StringConcatenate("Косим рынок дальше");}
       if(DayOfWeek()==2){alert_0=StringConcatenate("Бомбим рынок дальше");}
       if(DayOfWeek()==3){alert_0=StringConcatenate("Продолжаем зарабатывать");}
       if(DayOfWeek()==4){alert_0=StringConcatenate("Продолжаем зарабатывать бабки");}
       if(DayOfWeek()==5){alert_0=StringConcatenate("Продолжаем стричь хомяков");}
       lastSendTime_16 = now_16;
       }}
       
       datetime now_17 = TimeCurrent();
       if (TimeMinute(now_17) == 59 && (now_17 - lastSendTime_17) > 60) {
       alert_0=StringConcatenate("Очищаю график от мусора");
       lastSendTime_17 = now_17;
       }
       
       datetime now_18 = TimeCurrent();
       if (((TimeMinute(now_18) == 10)||(TimeMinute(now_18) == 30)||(TimeMinute(now_18) == 50)) && (now_18 - lastSendTime_18) > 60) {

       if((FileIsExist(filename1,0)<1)&&(FileIsExist(filename2,0)<1)&&(FileIsExist(filename3,0)<1)&&(FileIsExist(filename4,0)<1)&&(FileIsExist(filename5,0)<1)){
       alert_0=StringConcatenate("Сигналов нет, ~Отдыхай~");}
       if(FileIsExist(filename1,0)>=1){alert_0=StringConcatenate("Исп.стратегию: ~Дельта-1~");}
       if(FileIsExist(filename2,0)>=1){alert_0=StringConcatenate("Исп.стратегию: ~Дельта-2~");}
       if(FileIsExist(filename3,0)>=1){alert_0=StringConcatenate("Исп.стратегию: ~Дельта-3~");}
       if(FileIsExist(filename4,0)>=1){alert_0=StringConcatenate("Исп.стратегию: ~Дельта-4~");}
       if(FileIsExist(filename5,0)>=1){alert_0=StringConcatenate("Исп.стратегию: ~Дельта-5~");}
       lastSendTime_18 = now_18;
       } 
       }
//-----------------------сообщения в панель-----------------------------------------------------------------   
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//-----------------------конец значения, переменные функции для панели info--------------------


//-----------------------отправка сообщений при закрытии по траллу и тейку---------------------  
        static bool first=true;
        int _OrdersTotal=OrdersTotal();
        if(first){pre_OrdersTotal=_OrdersTotal;first=false;}
        if(_OrdersTotal<pre_OrdersTotal){
        if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY)){
        if(OrderType()<=OP_SELL){
//-----------------------сообщения в панель-----------------------------------------------------------------         
        double divider= standart?1:100;
        alert_0=StringConcatenate("Тралл: ",DoubleToStr(NormalizeDouble(OrderProfit()/divider,2),2), "$");
//-----------------------сообщения в панель-----------------------------------------------------------------       
//-----------------------отправка сообщений в телеграмм-----------------------------------------        
        if(telegram==true){
        SendTelegramMessage(BuildEquityMessage_6());}
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        if(OrdersTotal()<1)count_trall++;
        }}}pre_OrdersTotal=_OrdersTotal;    
//-----------------------отправка сообщений при закрытии по траллу и тейку---------------------   

//-----------------------объем в зависимости от баланса----------------------------------------
        if(OrdersTotal()<1||(OrdersTotal()>=1&&start_balance==0))start_balance=AccountEquity();
        double factor=2.0;
        if(start_balance<=start_um*20)factor=1.0;
        else if(start_balance<=start_um*40)factor=1.2;
        else if(start_balance<=start_um*60)factor=1.6;
        par5=start_balance/(start_um*factor);
        if(par5>200)par5=200;
//-----------------------конец объем в зависимости от баланса----------------------------------
      
//-----------------------трал эквити фиксированный---------------------------------------------
        if(HelpAccount<AccountEquity()&&OrdersTotal()<=0)HelpAccount=0;
        if(OrdersTotal()>=0&&CountBuy_1()>=1&&CountSell_1()>=1&&AccountEquity()>=(HelpAccount+c28)&&AccountEquity()>=(HelpAccount+c888*par5)&&HelpAccount!=0){
        if(tral_equity&&FileIsExist(HelpAcc,0)>=1&&c28!=0){
        CloseAll();HelpAccount=0;}}
//-----------------------конец трал эквити фиксированный---------------------------------------

//-----------------------трал эквити плавающий-------------------------------------------------
//-----------------------Прокачанный трал эквити плавающий-------------------------------------------------

if(tral_equity_dinamic) {
   // Сброс при закрытии всех ордеров и equity выше порога
   if(HelpAccount_down < AccountEquity() && OrdersTotal() == 0) {
      HelpAccount_down = 0;
      HelpAccount777_down = 0;
   }

   // Инициализация трала после открытия позиции
   if((OrdersTotal() > 0 || AccountEquity() - AccountBalance() + bonus != 0) && HelpAccount_down == 0) {
      HelpAccount_down = NormalizeDouble(HelpAccount, Digits);
      HelpAccount777_down = HelpAccount_down - c3;
   }

   // Обновление максимумов, если equity растёт
   if(OrdersTotal() > 0 && AccountEquity() >= HelpAccount_down + c2) {
      double increase = AccountEquity() - HelpAccount_down;
      HelpAccount_down = AccountEquity();

      // Увеличиваем защитный уровень только вверх
      double new_stop = HelpAccount_down - c3;
      if(new_stop > HelpAccount777_down) HelpAccount777_down = new_stop;
   }

   // Срабатывание защиты по equity
   if(OrdersTotal() > 0 &&
      c2 != 0 &&
      AccountEquity() <= HelpAccount777_down &&
      AccountEquity() >= (HelpAccount + c888 * par5) &&
      HelpAccount777_down != 0)
   {
      CloseAll_tr();
      flag_6 = 0;
      HelpAccount_down = 0;
      HelpAccount777_down = 0;
      FileDelete("close_all.txt");
   }
}
//-----------------------Конец прокачанного трал эквити-----------------------------------------------------
     
//-----------------------конец трал эквити плавающий-------------------------------------------
       

//-----------------------чтото для трала-------------------------------------------------------
        if(!work_check())return;                                                  
        int all=main.Update(),op=0,idirect;                      
        string n=main.sname;double p=main.p,lot,avg;
//-----------------------чтото для трала-------------------------------------------------------

//-----------------------трал ордеров раздельный-----------------------------------------------
        double OSL77=NormalizeDouble(OrderStopLoss(),Digits);{
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>2&&CountBuy_1()<=5){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_1*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>5&&CountBuy_1()<=10){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_2*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>10&&CountBuy_1()<=15){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_3*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>15&&CountBuy_1()<=20){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_4*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>20&&CountBuy_1()<=40){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_5*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------
        if(CountBuy_1()>40){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0;i<cnt2;i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_BUY){
        if((Bid-OrderOpenPrice())>lMinProfit_6*p){
        if(OrderStopLoss()<(Bid-(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}}
//--------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
        if(CountSell_1()>2&&CountSell_1()<=5){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_1*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} 
//---------------------------------------------------------------------------------------------
        if(CountSell_1()>5&&CountSell_1()<=10){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_2*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} 
//---------------------------------------------------------------------------------------------
        if(CountSell_1()>10&&CountSell_1()<=15){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_3*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} 
//---------------------------------------------------------------------------------------------
        if(CountSell_1()>15&&CountSell_1()<=20){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_4*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} 
//---------------------------------------------------------------------------------------------
        if(CountSell_1()>20&&CountSell_1()<=40){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_5*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} 
//---------------------------------------------------------------------------------------------
        if(CountSell_1()>40){
        if(trall_order_razdelni == true){int cnt2 = OrdersTotal();for(int i=0; i<cnt2; i++){
        if(!(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)))continue;
        if(OrderType()==OP_SELL){
        if((OrderOpenPrice()-Ask)>lMinProfit_6*p){
        if(OrderStopLoss()>(Ask+(lTrailingStop_1+lTrailingStep_1-1)*p)||OrderStopLoss()==0){bool modify2=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+lTrailingStop_1*p,OrderTakeProfit(),0,col_3);}}}}}} }
//-----------------------конец трал ордеров раздельный----------------------------------------



//-----------------------общий трал ордеров в зависимости от просадки-------------------------
        if(trall_order_all==true){
        //Для Buy ордеров
        if(CountBuy_1()<=2&&CountBuy()>=1){avg=main.get_Average(OP_BUY,idirect);
        if(avg>0&&idirect==1&&trailing_stop_pr>0&&Bid>avg+trailing_stop_pr*p){
        main.groupTrailingStop(OP_BUY,Bid-trailing_stop_pr*p);}}

        //Для Sell ордеров
        if(CountSell_1()<=2&&CountSell()>=1){avg=main.get_Average(OP_SELL,idirect);
        if(avg>0&&idirect==-1&&trailing_stop_pr>0&&Ask<avg-trailing_stop_pr*p){
        main.groupTrailingStop(OP_SELL,Ask+trailing_stop_pr*p);}}}
//-----------------------конец общий трал ордеров в зависимости от просадки--------------------

//-----------------------мигание точек---------------------------------------------------------    
        int t1_sec=Seconds();

        color Color_tch_ac=(t1_sec % 2 < 1) ? col_14 : col_5;
        color Color_tch=(t1_sec % 2 < 1) ? col_11 : col_5;
        color Color_tch_al=(t1_sec % 2 < 1) ? (C'255,242,170') : col_5;
//-----------------------конец мигание точек---------------------------------------------------

//-----------------------ИНДИКАТОРЫ------------------------------------------------------------
        op=0;
        double fg[100];
        //double rsi=iRSI(NULL,PERIOD_H1,7,PRICE_OPEN,0);
        //double rsi_m1=iRSI(NULL,PERIOD_M1,7,PRICE_OPEN,0);
        double PriceAsk=MarketInfo(NULL,MODE_ASK),PriceBid=MarketInfo(NULL,MODE_BID),Price=((PriceAsk+PriceBid)/2);
        double Highest_m=iHigh(NULL,PERIOD_M1,1),Lowest_m=iLow(NULL,PERIOD_M1,1);
        //double rsi_EURUSD=iRSI("EURUSD",PERIOD_M1,7,PRICE_OPEN,0);       
//-----------------------cчитаем дельту--------------------------------------------------------        
//-----------------------считаем день----------------------------------------------------------        
        double delta_EURUSD_D1=CalculateDelta("EURUSD",PERIOD_D1,1);
        double delta_GBPUSD_D1=CalculateDelta("GBPUSD",PERIOD_D1,1);
        double delta_AUDCAD_D1=CalculateDelta("AUDCAD",PERIOD_D1,1);
        double delta_AUDUSD_D1=CalculateDelta("AUDUSD",PERIOD_D1,1);
        double delta_EURAUD_D1=CalculateDelta("EURAUD",PERIOD_D1,1);
        double delta_GBPAUD_D1=CalculateDelta("GBPAUD",PERIOD_D1,1);
        double delta_AUDCHF_D1=CalculateDelta("AUDCHF",PERIOD_D1,1);
        double delta_GBPCHF_D1=CalculateDelta("GBPCHF",PERIOD_D1,1);
        double delta_NZDUSD_D1=CalculateDelta("NZDUSD",PERIOD_D1,1);
        double delta_NZDCAD_D1=CalculateDelta("NZDCAD",PERIOD_D1,1);
        double delta_USDCHF_D1=CalculateDelta("USDCHF",PERIOD_D1,1);
        double delta_CADCHF_D1=CalculateDelta("CADCHF",PERIOD_D1,1);
//-----------------------конец считаем день----------------------------------------------------
//-----------------------считаем месяц--------------------------------------------------------- 
        double delta_EURUSD_MN1=CalculateDelta("EURUSD",PERIOD_D1,20);
        double delta_GBPUSD_MN1=CalculateDelta("GBPUSD",PERIOD_D1,20);
        double delta_AUDCAD_MN1=CalculateDelta("AUDCAD",PERIOD_D1,20);
        double delta_AUDUSD_MN1=CalculateDelta("AUDUSD",PERIOD_D1,20);
        double delta_EURAUD_MN1=CalculateDelta("EURAUD",PERIOD_D1,20);
        double delta_GBPAUD_MN1=CalculateDelta("GBPAUD",PERIOD_D1,20);
        double delta_AUDCHF_MN1=CalculateDelta("AUDCHF",PERIOD_D1,20);
        double delta_GBPCHF_MN1=CalculateDelta("GBPCHF",PERIOD_D1,20);
        double delta_NZDUSD_MN1=CalculateDelta("NZDUSD",PERIOD_D1,20);
        double delta_NZDCAD_MN1=CalculateDelta("NZDCAD",PERIOD_D1,20);
        double delta_USDCHF_MN1=CalculateDelta("USDCHF",PERIOD_D1,20);
        double delta_CADCHF_MN1=CalculateDelta("CADCHF",PERIOD_D1,20);
//-----------------------конец считаем месяц---------------------------------------------------
//-----------------------cчитаем дельту--------------------------------------------------------

        
//-----------------------закрываем по профиту-------------------------------------------------- 
        if(close_profit_buy==true){ 
        if(CountBuy_1()>=1&&profit_buy>(c777*par5)&&(trr_tr<(-5))) op=-777;}
//-----------------------Конец закрываем по профиту--------------------------------------------
//-----------------------закрываем по профиту-------------------------------------------------- 
        if(close_profit_sell==true){ 
        if(CountSell_1()>=1&&profit_sell>(c777*par5)&&(trr_tr<(-5))) op=777;}
//-----------------------Конец закрываем по профиту--------------------------------------------

        double dlt_EURUSD_GBPUSD=(MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1));
        double dlt_AUDCAD_AUDUSD=(MathAbs(delta_AUDCAD_MN1-delta_AUDUSD_MN1));
        double dlt_EURAUD_GBPAUD=(MathAbs(delta_EURAUD_MN1-delta_GBPAUD_MN1));
        double dlt_AUDCHF_GBPCHF=(MathAbs(delta_AUDCHF_MN1-delta_GBPCHF_MN1));
        double dlt_NZDUSD_NZDCAD=(MathAbs(delta_NZDUSD_MN1-delta_NZDCAD_MN1));
        double dlt_USDCHF_CADCHF=(MathAbs(delta_USDCHF_MN1-delta_CADCHF_MN1));
        
//-----------------------записываем номер стратегии---------------------------------------------
        if(OrdersTotal()<1&&(FileIsExist(filename_pr1,0)<1)){
        if(  (dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong1&&dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong2)||(dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong1&&dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong2)||(dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong1&&dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong2)||(dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong1&&dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong2)||(dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong1&&dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong2)||(dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong1&&dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong2)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{
        int fileHandle=FileOpen(filename_pr1, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content_pr1);FileClose(fileHandle);}}}}
        if( (dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong1||dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong2)&&(dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong1||dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong2)&&(dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong1||dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong2)&&(dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong1||dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong2)&&(dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong1||dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong2)&&(dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong1||dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong2)){ 
        FileDelete("str_pr1.txt");}
//----------------------------------------------------------------------------------------------
        if(OrdersTotal()<1&&(FileIsExist(filename_pr2,0)<1)){
        if(  (dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong2&&dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong3)||(dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong2&&dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong3)||(dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong2&&dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong3)||(dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong2&&dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong3)||(dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong2&&dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong3)||(dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong2&&dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong3)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{
        int fileHandle=FileOpen(filename_pr2, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content_pr2);FileClose(fileHandle);}}}}
        if( (dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong2||dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong3)&&(dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong2||dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong3)&&(dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong2||dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong3)&&(dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong2||dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong3)&&(dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong2||dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong3)&&(dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong2||dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong3)){ 
        FileDelete("str_pr2.txt");}
//----------------------------------------------------------------------------------------------
        if(OrdersTotal()<1&&(FileIsExist(filename_pr3,0)<1)){
        if(  (dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong3&&dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong4)||(dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong3&&dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong4)||(dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong3&&dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong4)||(dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong3&&dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong4)||(dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong3&&dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong4)||(dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong3&&dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong4)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{
        int fileHandle=FileOpen(filename_pr3, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content_pr3);FileClose(fileHandle);}}}}
        if( (dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong3||dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong4)&&(dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong3||dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong4)&&(dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong3||dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong4)&&(dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong3||dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong4)&&(dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong3||dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong4)&&(dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong3||dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong4)){ 
        FileDelete("str_pr3.txt");}
//----------------------------------------------------------------------------------------------
        if(OrdersTotal()<1&&(FileIsExist(filename_pr4,0)<1)){
        if(  (dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong4&&dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong5)||(dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong4&&dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong5)||(dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong4&&dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong5)||(dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong4&&dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong5)||(dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong4&&dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong5)||(dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong4&&dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong5)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{
        int fileHandle=FileOpen(filename_pr4, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content_pr4);FileClose(fileHandle);}}}}
        if( (dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong4||dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong5)&&(dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong4||dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong5)&&(dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong4||dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong5)&&(dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong4||dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong5)&&(dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong4||dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong5)&&(dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong4||dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong5)){ 
        FileDelete("str_pr4.txt");}
//----------------------------------------------------------------------------------------------        
        if(OrdersTotal()<1&&(FileIsExist(filename_pr5,0)<1)){
        if(  (dlt_EURUSD_GBPUSD>=delta_EURUSD_GBPUSD_MN1_strong5)||(dlt_AUDCAD_AUDUSD>=delta_AUDCAD_AUDUSD_MN1_strong5)||(dlt_EURAUD_GBPAUD>=delta_EURAUD_GBPAUD_MN1_strong5)||(dlt_AUDCHF_GBPCHF>=delta_AUDCHF_GBPCHF_MN1_strong5)||(dlt_NZDUSD_NZDCAD>=delta_NZDUSD_NZDCAD_MN1_strong5)||(dlt_USDCHF_CADCHF>=delta_USDCHF_CADCHF_MN1_strong5)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{
        int fileHandle=FileOpen(filename_pr5, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content_pr5);FileClose(fileHandle);}}}}
        if( (dlt_EURUSD_GBPUSD<delta_EURUSD_GBPUSD_MN1_strong5)&&(dlt_AUDCAD_AUDUSD<delta_AUDCAD_AUDUSD_MN1_strong5)&&(dlt_EURAUD_GBPAUD<delta_EURAUD_GBPAUD_MN1_strong5)&&(dlt_AUDCHF_GBPCHF<delta_AUDCHF_GBPCHF_MN1_strong5)&&(dlt_NZDUSD_NZDCAD<delta_NZDUSD_NZDCAD_MN1_strong5)&&(dlt_USDCHF_CADCHF<delta_USDCHF_CADCHF_MN1_strong5)){ 
        FileDelete("str_pr5.txt");}
//-----------------------записываем номер стратегии---------------------------------------------

//-----------------------расчет динамической дельты-------------------------------------------
        //сбрасываем динамическую дельту
        if((gmt_hour==00&&Minute()==10)||(gmt_hour==07&&Minute()==00)||(gmt_hour==13&&Minute()==30)){ 
        delta_EURUSD_GBPUSD_1=0;delta_AUDCAD_AUDUSD_1=0;delta_EURAUD_GBPAUD_1=0;delta_AUDCHF_GBPCHF_1=0;delta_NZDUSD_NZDCAD_1=0;delta_USDCHF_CADCHF_1=0;
        delta_EURUSD_GBPUSD_2=0;delta_AUDCAD_AUDUSD_2=0;delta_EURAUD_GBPAUD_2=0;delta_AUDCHF_GBPCHF_2=0;delta_NZDUSD_NZDCAD_2=0;delta_USDCHF_CADCHF_2=0;
        delta_EURUSD_GBPUSD_3=0;delta_AUDCAD_AUDUSD_3=0;delta_EURAUD_GBPAUD_3=0;delta_AUDCHF_GBPCHF_3=0;delta_NZDUSD_NZDCAD_3=0;delta_USDCHF_CADCHF_3=0;
        delta_EURUSD_GBPUSD_4=0;delta_AUDCAD_AUDUSD_4=0;delta_EURAUD_GBPAUD_4=0;delta_AUDCHF_GBPCHF_4=0;delta_NZDUSD_NZDCAD_4=0;delta_USDCHF_CADCHF_4=0;
        delta_EURUSD_GBPUSD_5=0;delta_AUDCAD_AUDUSD_5=0;delta_EURAUD_GBPAUD_5=0;delta_AUDCHF_GBPCHF_5=0;delta_NZDUSD_NZDCAD_5=0;delta_USDCHF_CADCHF_5=0;
        delta_EURUSD_GBPUSD_average=0;delta_AUDCAD_AUDUSD_average=0;delta_EURAUD_GBPAUD_average=0;delta_AUDCHF_GBPCHF_average=0;delta_NZDUSD_NZDCAD_average=0;delta_USDCHF_CADCHF_average=0;}
//------------------------------------------------------------------------------
        //считаем динамическую дельту
        if((gmt_hour==00&&Minute() >10&&Minute()<12)||(gmt_hour==07&&Minute() >00&&Minute()<02)||(gmt_hour==13&&Minute() >30&&Minute()<32)){
        if(delta_EURUSD_GBPUSD_1==0)delta_EURUSD_GBPUSD_1=MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1);
        if(delta_AUDCAD_AUDUSD_1==0)delta_AUDCAD_AUDUSD_1=MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1);
        if(delta_EURAUD_GBPAUD_1==0)delta_EURAUD_GBPAUD_1=MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1);
        if(delta_AUDCHF_GBPCHF_1==0)delta_AUDCHF_GBPCHF_1=MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1);
        if(delta_NZDUSD_NZDCAD_1==0)delta_NZDUSD_NZDCAD_1=MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1);
        if(delta_USDCHF_CADCHF_1==0)delta_USDCHF_CADCHF_1=MathAbs(delta_USDCHF_D1-delta_CADCHF_D1);}
        if((gmt_hour==00&&Minute()>=12&&Minute()<14)||(gmt_hour==07&&Minute()>=02&&Minute()<04)||(gmt_hour==13&&Minute()>=32&&Minute()<34)){
        if(delta_EURUSD_GBPUSD_2==0)delta_EURUSD_GBPUSD_2=MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1);
        if(delta_AUDCAD_AUDUSD_2==0)delta_AUDCAD_AUDUSD_2=MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1);
        if(delta_EURAUD_GBPAUD_2==0)delta_EURAUD_GBPAUD_2=MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1);
        if(delta_AUDCHF_GBPCHF_2==0)delta_AUDCHF_GBPCHF_2=MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1);
        if(delta_NZDUSD_NZDCAD_2==0)delta_NZDUSD_NZDCAD_2=MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1);
        if(delta_USDCHF_CADCHF_2==0)delta_USDCHF_CADCHF_2=MathAbs(delta_USDCHF_D1-delta_CADCHF_D1);}
        if((gmt_hour==00&&Minute()>=14&&Minute()<16)||(gmt_hour==07&&Minute()>=04&&Minute()<06)||(gmt_hour==13&&Minute()>=34&&Minute()<36)){
        if(delta_EURUSD_GBPUSD_3==0)delta_EURUSD_GBPUSD_3=MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1);
        if(delta_AUDCAD_AUDUSD_3==0)delta_AUDCAD_AUDUSD_3=MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1);
        if(delta_EURAUD_GBPAUD_3==0)delta_EURAUD_GBPAUD_3=MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1);
        if(delta_AUDCHF_GBPCHF_3==0)delta_AUDCHF_GBPCHF_3=MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1);
        if(delta_NZDUSD_NZDCAD_3==0)delta_NZDUSD_NZDCAD_3=MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1);
        if(delta_USDCHF_CADCHF_3==0)delta_USDCHF_CADCHF_3=MathAbs(delta_USDCHF_D1-delta_CADCHF_D1);}
        if((gmt_hour==00&&Minute()>=16&&Minute()<18)||(gmt_hour==07&&Minute()>=06&&Minute()<08)||(gmt_hour==13&&Minute()>=36&&Minute()<38)){
        if(delta_EURUSD_GBPUSD_4==0)delta_EURUSD_GBPUSD_4=MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1);
        if(delta_AUDCAD_AUDUSD_4==0)delta_AUDCAD_AUDUSD_4=MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1);
        if(delta_EURAUD_GBPAUD_4==0)delta_EURAUD_GBPAUD_4=MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1);
        if(delta_AUDCHF_GBPCHF_4==0)delta_AUDCHF_GBPCHF_4=MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1);
        if(delta_NZDUSD_NZDCAD_4==0)delta_NZDUSD_NZDCAD_4=MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1);
        if(delta_USDCHF_CADCHF_4==0)delta_USDCHF_CADCHF_4=MathAbs(delta_USDCHF_D1-delta_CADCHF_D1);}
        if((gmt_hour==00&&Minute()>=18&&Minute()<20)||(gmt_hour==07&&Minute()>=08&&Minute()<10)||(gmt_hour==13&&Minute()>=38&&Minute()<40)){
        if(delta_EURUSD_GBPUSD_5==0)delta_EURUSD_GBPUSD_5=MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1);
        if(delta_AUDCAD_AUDUSD_5==0)delta_AUDCAD_AUDUSD_5=MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1);
        if(delta_EURAUD_GBPAUD_5==0)delta_EURAUD_GBPAUD_5=MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1);
        if(delta_AUDCHF_GBPCHF_5==0)delta_AUDCHF_GBPCHF_5=MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1);
        if(delta_NZDUSD_NZDCAD_5==0)delta_NZDUSD_NZDCAD_5=MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1);
        if(delta_USDCHF_CADCHF_5==0)delta_USDCHF_CADCHF_5=MathAbs(delta_USDCHF_D1-delta_CADCHF_D1);}     
//------------------------------------------------------------------------------  
        //устанавливаем динамическую дельту
        if((gmt_hour==00&&Minute()==20)||(gmt_hour==07&&Minute()==10)||(gmt_hour==13&&Minute()==40)){
        if(delta_EURUSD_GBPUSD_average==0)delta_EURUSD_GBPUSD_average=MathMax(delta_EURUSD_GBPUSD_1,MathMax(delta_EURUSD_GBPUSD_2,MathMax(delta_EURUSD_GBPUSD_3,MathMax(delta_EURUSD_GBPUSD_4,delta_EURUSD_GBPUSD_5)))); // вычисляем максимальное значение EURUSD_GBPUSD
        if(delta_AUDCAD_AUDUSD_average==0)delta_AUDCAD_AUDUSD_average=MathMax(delta_AUDCAD_AUDUSD_1,MathMax(delta_AUDCAD_AUDUSD_2,MathMax(delta_AUDCAD_AUDUSD_3,MathMax(delta_AUDCAD_AUDUSD_4,delta_AUDCAD_AUDUSD_5)))); // динамика AUDCAD_AUDUSD
        if(delta_EURAUD_GBPAUD_average==0)delta_EURAUD_GBPAUD_average=MathMax(delta_EURAUD_GBPAUD_1,MathMax(delta_EURAUD_GBPAUD_2,MathMax(delta_EURAUD_GBPAUD_3,MathMax(delta_EURAUD_GBPAUD_4,delta_EURAUD_GBPAUD_5)))); // динамика EURAUD_GBPAUD
        if(delta_AUDCHF_GBPCHF_average==0)delta_AUDCHF_GBPCHF_average=MathMax(delta_AUDCHF_GBPCHF_1,MathMax(delta_AUDCHF_GBPCHF_2,MathMax(delta_AUDCHF_GBPCHF_3,MathMax(delta_AUDCHF_GBPCHF_4,delta_AUDCHF_GBPCHF_5)))); // динамика AUDCHF_GBPCHF
        if(delta_NZDUSD_NZDCAD_average==0)delta_NZDUSD_NZDCAD_average=MathMax(delta_NZDUSD_NZDCAD_1,MathMax(delta_NZDUSD_NZDCAD_2,MathMax(delta_NZDUSD_NZDCAD_3,MathMax(delta_NZDUSD_NZDCAD_4,delta_NZDUSD_NZDCAD_5)))); // динамика NZDUSD_NZDCAD
        if(delta_USDCHF_CADCHF_average==0)delta_USDCHF_CADCHF_average=MathMax(delta_USDCHF_CADCHF_1,MathMax(delta_USDCHF_CADCHF_2,MathMax(delta_USDCHF_CADCHF_3,MathMax(delta_USDCHF_CADCHF_4,delta_USDCHF_CADCHF_5))));}
//-----------------------если динамическая дельта равна 0-------------------------------------
        //если в процессе торговли динамическая дельта сбросилась, устанавливаем значение по умолчанию
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){
        if(delta_EURUSD_GBPUSD_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_EURUSD_GBPUSD_average=delta_EURUSD_GBPUSD;
        if(delta_AUDCAD_AUDUSD_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_AUDCAD_AUDUSD_average=delta_AUDCAD_AUDUSD;
        if(delta_EURAUD_GBPAUD_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_EURAUD_GBPAUD_average=delta_EURAUD_GBPAUD; 
        if(delta_AUDCHF_GBPCHF_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_AUDCHF_GBPCHF_average=delta_AUDCHF_GBPCHF;
        if(delta_NZDUSD_NZDCAD_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_NZDUSD_NZDCAD_average=delta_NZDUSD_NZDCAD;
        if(delta_USDCHF_CADCHF_average==0&&((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=01&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>00&&Minute()<10)))delta_USDCHF_CADCHF_average=delta_USDCHF_CADCHF;} 
//-----------------------если динамическая дельта равна 0-------------------------------------
//-----------------------расчет динамической дельты-------------------------------------------       
            
//-----------------------вычисляем время для сканирование стратегий-----------------------------
        // сбрасываем время для сканирование стратегий если > 0
        if(OrdersTotal()<=0){
        if((gmt_hour==00&&Minute()==20)||(gmt_hour==07&&Minute()==10)||(gmt_hour==13&&Minute()==40)){
        if(str1_time!=0)str1_time=0;
        if(str2_time!=0)str2_time=0;
        if(str3_time!=0)str3_time=0;
        if(str4_time!=0)str4_time=0;
        if(str5_time!=0)str5_time=0;}
        // если подходит по условие назначаем для работы
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){
//-----------------------------------------------------------------------------------------------        

//-----------------------распределяем слоты по времени-----------------------------------------
        //if(OrdersTotal()<=0){
        //CheckCriticalFiles();}
        static datetime lastCheckTime = 0;
        if(OrdersTotal() <= 0 && TimeCurrent() > lastCheckTime + 10) {  // Не чаще 1 раза в минуту
        CheckCriticalFiles();
        lastCheckTime = TimeCurrent();}
//-----------------------распределяем слоты по времени-----------------------------------------
      
//-----------------------------------------------------------------------------------------------
        }}
        if(OrdersTotal()>=1){str4_time=0;str3_time=0;str2_time=0;str1_time=0;str5_time=0;}
        if(str1_time!=0){str2_time=0;str3_time=0;str4_time=0;str5_time=0;}
        if(str2_time!=0){str1_time=0;str3_time=0;str4_time=0;str5_time=0;}
        if(str3_time!=0){str2_time=0;str1_time=0;str4_time=0;str5_time=0;}
        if(str4_time!=0){str2_time=0;str3_time=0;str1_time=0;str5_time=0;}
        if(str5_time!=0){str2_time=0;str3_time=0;str4_time=0;str1_time=0;}
//-----------------------конец вычисляем время для сканирование стратегий------------------------

//-----------------------значения, переменные функции для панели info--------------------------
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
        if(info_0==true){ 
//-----------------------рисуем рамку---------------------------------------------------------- 
        if(ObjectFind(0,"m_bg_big")==-1){         
        ObjectCreate(0,"m_bg_big",OBJ_RECTANGLE_LABEL,0,0,0);
        ObjectSetString(0,"m_bg_big",OBJPROP_TOOLTIP,"\n");     // отключаем всплывающую подсказку
        ObjectSetInteger(0,"m_bg_big",OBJPROP_XDISTANCE,1);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_YDISTANCE,18);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_YSIZE,696);       // верстикаль
        ObjectSetInteger(0,"m_bg_big",OBJPROP_XSIZE,849);       // горизонталь
        ObjectSet("m_bg_big",OBJPROP_CORNER,CORNER);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_BORDER_TYPE,BORDER_FLAT);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_STYLE,STYLE_SOLID);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_WIDTH,1);
        ObjectSetInteger(0,"m_bg_big",OBJPROP_COLOR,col_17);} 

        //Переменная для хранения предыдущего цвета
        int prevColor=-1;
        if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1){
        int newColor=C'10,10,46';//Цвет для BUY
        if(newColor!=prevColor){//Проверяем,если цвет изменился
        ObjectSetInteger(0,"m_bg_big",OBJPROP_BGCOLOR,newColor);
        prevColor=newColor;}}
        else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1){
        int newColor=C'51,0,0';//Цвет для SELL
        if(newColor!=prevColor){//Проверяем,если цвет изменился
        ObjectSetInteger(0,"m_bg_big",OBJPROP_BGCOLOR,newColor);
        prevColor=newColor;}}
        else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1){
        int newColor=C'0,23,0';//Цвет для BUY и SELL одновременно
        if(newColor!=prevColor){//Проверяем,если цвет изменился
        ObjectSetInteger(0,"m_bg_big",OBJPROP_BGCOLOR,newColor);
        prevColor=newColor;}}
        else if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0){
        int newColor=col_17;//Цвет для обоих ордеров равных 0
        if(newColor!=prevColor){//Проверяем,если цвет изменился
        ObjectSetInteger(0,"m_bg_big",OBJPROP_BGCOLOR,newColor);
        prevColor=newColor;}}
//-----------------------конец рисуем рамку--------------------------------------------------

//-----------------------события------------------------------------------------------------- 
        if(CountBuy_1()>0)event_0=1;else event_0=0;
        if(CountSell_1()>0)event_0_s=1;else event_0_s=0;
        
        if(OrdersTotal()<=0)event_1=0;                            // нет открытые ордера без мейджика
        if(OrdersTotal()>0)event_1=1;                             // есть открытых ордеров без мейджика    
//--------------------------------------------------------------------------------------------- 
        if(((delta_EURUSD_D1>0&&delta_GBPUSD_D1>0&&(delta_EURUSD_D1-delta_GBPUSD_D1)>delta_EURUSD_GBPUSD&&(delta_EURUSD_D1-delta_GBPUSD_D1)>delta_EURUSD_GBPUSD_average))||((delta_EURUSD_D1<0&&delta_GBPUSD_D1<0&&(delta_EURUSD_D1-(delta_GBPUSD_D1))>delta_EURUSD_GBPUSD&&(delta_EURUSD_D1-(delta_GBPUSD_D1))>delta_EURUSD_GBPUSD_average))) event_2=1; else event_2=0;
        if(((delta_EURUSD_D1<0&&delta_GBPUSD_D1<0&&(delta_GBPUSD_D1-(delta_EURUSD_D1))>delta_EURUSD_GBPUSD&&(delta_GBPUSD_D1-(delta_EURUSD_D1))>delta_EURUSD_GBPUSD_average))||((delta_EURUSD_D1>0&&delta_GBPUSD_D1>0&&(delta_GBPUSD_D1-delta_EURUSD_D1)>delta_EURUSD_GBPUSD&&(delta_GBPUSD_D1-delta_EURUSD_D1)>delta_EURUSD_GBPUSD_average))) event_2_p=1;else event_2_p=0;
        if((delta_EURUSD_D1>0&&delta_GBPUSD_D1<0&&(delta_EURUSD_D1>(delta_EURUSD_GBPUSD/2)&&delta_GBPUSD_D1<-(delta_EURUSD_GBPUSD/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1)>delta_EURUSD_GBPUSD_average) event_2_1=1;else event_2_1=0;
        if((delta_EURUSD_D1<0&&delta_GBPUSD_D1>0&&(delta_EURUSD_D1<-(delta_EURUSD_GBPUSD/2)&&delta_GBPUSD_D1>(delta_EURUSD_GBPUSD/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_EURUSD_D1-delta_GBPUSD_D1)>delta_EURUSD_GBPUSD_average) event_2_p_1=1;else event_2_p_1=0;
        if(CountOrders("EURUSD", OP_BUY)>0) event_3=1;else event_3=0;
        if(CountOrders("EURUSD", OP_SELL)>0) event_3_s=1;else event_3_s=0;
        if((CountOrders("EURUSD", OP_BUY)+CountOrders("EURUSD", OP_SELL))>0) event_3_3=1;else event_3_3=0;
        if(CountOrders("GBPUSD", OP_BUY)>0) event_4=1;else event_4=0;                         
        if(CountOrders("GBPUSD", OP_SELL)>0) event_4_s=1;else event_4_s=0;
        if((CountOrders("GBPUSD", OP_BUY)+CountOrders("GBPUSD", OP_SELL))>0) event_4_4=1;else event_4_4=0; 
//---------------------------------------------------------------------------------------------
        if(((delta_AUDCAD_D1>0&&delta_AUDUSD_D1>0&&(delta_AUDCAD_D1-delta_AUDUSD_D1)>delta_AUDCAD_AUDUSD&&(delta_AUDCAD_D1-delta_AUDUSD_D1)>delta_AUDCAD_AUDUSD_average))||((delta_AUDCAD_D1<0&&delta_AUDUSD_D1<0&&(delta_AUDCAD_D1-(delta_AUDUSD_D1))>delta_AUDCAD_AUDUSD&&(delta_AUDCAD_D1-(delta_AUDUSD_D1))>delta_AUDCAD_AUDUSD_average))) event_5=1; else event_5=0;
        if(((delta_AUDCAD_D1<0&&delta_AUDUSD_D1<0&&(delta_AUDUSD_D1-(delta_AUDCAD_D1))>delta_AUDCAD_AUDUSD&&(delta_AUDUSD_D1-(delta_AUDCAD_D1))>delta_AUDCAD_AUDUSD_average))||((delta_AUDCAD_D1>0&&delta_AUDUSD_D1>0&&(delta_AUDUSD_D1-delta_AUDCAD_D1)>delta_AUDCAD_AUDUSD&&(delta_AUDUSD_D1-delta_AUDCAD_D1)>delta_AUDCAD_AUDUSD_average))) event_5_p=1;else event_5_p=0;
        if((delta_AUDCAD_D1>0&&delta_AUDUSD_D1<0&&(delta_AUDCAD_D1>(delta_AUDCAD_AUDUSD/2)&&delta_AUDUSD_D1<-(delta_AUDCAD_AUDUSD/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1)>delta_AUDCAD_AUDUSD_average) event_5_1=1;else event_5_1=0;
        if((delta_AUDCAD_D1<0&&delta_AUDUSD_D1>0&&(delta_AUDCAD_D1<-(delta_AUDCAD_AUDUSD/2)&&delta_AUDUSD_D1>(delta_AUDCAD_AUDUSD/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_AUDCAD_D1-delta_AUDUSD_D1)>delta_AUDCAD_AUDUSD_average) event_5_p_1=1;else event_5_p_1=0;
        if(CountOrders("AUDCAD", OP_BUY)>0) event_6=1;else event_6=0;                         
        if(CountOrders("AUDCAD", OP_SELL)>0) event_6_s=1;else event_6_s=0;
        if((CountOrders("AUDCAD", OP_BUY)+CountOrders("AUDCAD", OP_SELL))>0) event_6_6=1;else event_6_6=0;                             
        if(CountOrders("AUDUSD", OP_BUY)>0) event_7=1;else event_7=0;                         
        if(CountOrders("AUDUSD", OP_SELL)>0) event_7_s=1;else event_7_s=0;
        if((CountOrders("AUDUSD", OP_BUY)+CountOrders("AUDUSD", OP_SELL))>0) event_7_7=1;else event_7_7=0; 
//---------------------------------------------------------------------------------------------
        if(((delta_EURAUD_D1>0&&delta_GBPAUD_D1>0&&(delta_EURAUD_D1-delta_GBPAUD_D1)>delta_EURAUD_GBPAUD&&(delta_EURAUD_D1-delta_GBPAUD_D1)>delta_EURAUD_GBPAUD_average))||((delta_EURAUD_D1<0&&delta_GBPAUD_D1<0&&(delta_EURAUD_D1-(delta_GBPAUD_D1))>delta_EURAUD_GBPAUD&&(delta_EURAUD_D1-(delta_GBPAUD_D1))>delta_EURAUD_GBPAUD_average))) event_11=1; else event_11=0;
        if(((delta_EURAUD_D1<0&&delta_GBPAUD_D1<0&&(delta_GBPAUD_D1-(delta_EURAUD_D1))>delta_EURAUD_GBPAUD&&(delta_GBPAUD_D1-(delta_EURAUD_D1))>delta_EURAUD_GBPAUD_average))||((delta_EURAUD_D1>0&&delta_GBPAUD_D1>0&&(delta_GBPAUD_D1-delta_EURAUD_D1)>delta_EURAUD_GBPAUD&&(delta_GBPAUD_D1-delta_EURAUD_D1)>delta_EURAUD_GBPAUD_average))) event_11_p=1;else event_11_p=0; 
        if((delta_EURAUD_D1>0&&delta_GBPAUD_D1<0&&(delta_EURAUD_D1>(delta_EURAUD_GBPAUD/2)&&delta_GBPAUD_D1<-(delta_EURAUD_GBPAUD/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1)>delta_EURAUD_GBPAUD_average) event_11_1=1; else event_11_1=0;
        if((delta_EURAUD_D1<0&&delta_GBPAUD_D1>0&&(delta_EURAUD_D1<-(delta_EURAUD_GBPAUD/2)&&delta_GBPAUD_D1>(delta_EURAUD_GBPAUD/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_EURAUD_D1-delta_GBPAUD_D1)>delta_EURAUD_GBPAUD_average) event_11_p_1=1; else event_11_p_1=0;
        if(CountOrders("EURAUD", OP_BUY)>0) event_12=1;else event_12=0;                         
        if(CountOrders("EURAUD", OP_SELL)>0) event_12_s=1;else event_12_s=0;
        if((CountOrders("EURAUD", OP_BUY)+CountOrders("EURAUD", OP_SELL))>0) event_12_12=1;else event_12_12=0;                               
        if(CountOrders("GBPAUD", OP_BUY)>0) event_13=1;else event_13=0;                         
        if(CountOrders("GBPAUD", OP_SELL)>0) event_13_s=1;else event_13_s=0; 
        if((CountOrders("GBPAUD", OP_BUY)+CountOrders("GBPAUD", OP_SELL))>0) event_13_13=1;else event_13_13=0;
//---------------------------------------------------------------------------------------------
        if(((delta_AUDCHF_D1>0&&delta_GBPCHF_D1>0&&(delta_AUDCHF_D1-delta_GBPCHF_D1)>delta_AUDCHF_GBPCHF&&(delta_AUDCHF_D1-delta_GBPCHF_D1)>delta_AUDCHF_GBPCHF_average))||((delta_AUDCHF_D1<0&&delta_GBPCHF_D1<0&&(delta_AUDCHF_D1-(delta_GBPCHF_D1))>delta_AUDCHF_GBPCHF&&(delta_AUDCHF_D1-(delta_GBPCHF_D1))>delta_AUDCHF_GBPCHF_average))) event_20=1; else event_20=0;
        if(((delta_AUDCHF_D1<0&&delta_GBPCHF_D1<0&&(delta_GBPCHF_D1-(delta_AUDCHF_D1))>delta_AUDCHF_GBPCHF&&(delta_GBPCHF_D1-(delta_AUDCHF_D1))>delta_AUDCHF_GBPCHF_average))||((delta_AUDCHF_D1>0&&delta_GBPCHF_D1>0&&(delta_GBPCHF_D1-delta_AUDCHF_D1)>delta_AUDCHF_GBPCHF&&(delta_GBPCHF_D1-delta_AUDCHF_D1)>delta_AUDCHF_GBPCHF_average))) event_20_p=1;else event_20_p=0;  
        if((delta_AUDCHF_D1>0&&delta_GBPCHF_D1<0&&(delta_AUDCHF_D1>(delta_AUDCHF_GBPCHF/2)&&delta_GBPCHF_D1<-(delta_AUDCHF_GBPCHF/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1)>delta_AUDCHF_GBPCHF_average) event_20_1=1;  else event_20_1=0;
        if((delta_AUDCHF_D1<0&&delta_GBPCHF_D1>0&&(delta_AUDCHF_D1<-(delta_AUDCHF_GBPCHF/2)&&delta_GBPCHF_D1>(delta_AUDCHF_GBPCHF/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_AUDCHF_D1-delta_GBPCHF_D1)>delta_AUDCHF_GBPCHF_average) event_20_p_1=1; else event_20_p_1=0;
        if(CountOrders("AUDCHF", OP_BUY)>0) event_21=1;else event_21=0;                         
        if(CountOrders("AUDCHF", OP_SELL)>0) event_21_1_s=1;else event_21_1_s=0;
        if((CountOrders("AUDCHF", OP_BUY)+CountOrders("AUDCHF", OP_SELL))>0) event_21_21=1;else event_21_21=0;                               
        if(CountOrders("GBPCHF", OP_BUY)>0) event_22=1;else event_22=0;                         
        if(CountOrders("GBPCHF", OP_SELL)>0) event_22_1_s=1;else event_22_1_s=0; 
        if((CountOrders("GBPCHF", OP_BUY)+CountOrders("GBPCHF", OP_SELL))>0) event_22_22=1;else event_22_22=0; 
//---------------------------------------------------------------------------------------------
        if(((delta_NZDUSD_D1>0&&delta_NZDCAD_D1>0&&(delta_NZDUSD_D1-delta_NZDCAD_D1)>delta_NZDUSD_NZDCAD&&(delta_NZDUSD_D1-delta_NZDCAD_D1)>delta_NZDUSD_NZDCAD_average))||((delta_NZDUSD_D1<0&&delta_NZDCAD_D1<0&&(delta_NZDUSD_D1-(delta_NZDCAD_D1))>delta_NZDUSD_NZDCAD&&(delta_NZDUSD_D1-(delta_NZDCAD_D1))>delta_NZDUSD_NZDCAD_average))) event_23_1=1; else event_23_1=0;
        if(((delta_NZDUSD_D1<0&&delta_NZDCAD_D1<0&&(delta_NZDCAD_D1-(delta_NZDUSD_D1))>delta_NZDUSD_NZDCAD&&(delta_NZDCAD_D1-(delta_NZDUSD_D1))>delta_NZDUSD_NZDCAD_average))||((delta_NZDUSD_D1>0&&delta_NZDCAD_D1>0&&(delta_NZDCAD_D1-delta_NZDUSD_D1)>delta_NZDUSD_NZDCAD&&(delta_NZDCAD_D1-delta_NZDUSD_D1)>delta_NZDUSD_NZDCAD_average))) event_23_p=1;else event_23_p=0;
        if((delta_NZDUSD_D1>0&&delta_NZDCAD_D1<0&&(delta_NZDUSD_D1>(delta_NZDUSD_NZDCAD/2)&&delta_NZDCAD_D1<-(delta_NZDUSD_NZDCAD/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1)>delta_NZDUSD_NZDCAD_average) event_23_1_1=1; else event_23_1_1=0;
        if((delta_NZDUSD_D1<0&&delta_NZDCAD_D1>0&&(delta_NZDUSD_D1<-(delta_NZDUSD_NZDCAD/2)&&delta_NZDCAD_D1>(delta_NZDUSD_NZDCAD/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_NZDUSD_D1-delta_NZDCAD_D1)>delta_NZDUSD_NZDCAD_average) event_23_p_1=1;  else event_23_p_1=0;
        if(CountOrders("NZDUSD", OP_BUY)>0) event_24_1=1;else event_24_1=0;                         
        if(CountOrders("NZDUSD", OP_SELL)>0) event_24_1_s=1;else event_24_1_s=0;
        if((CountOrders("NZDUSD", OP_BUY)+CountOrders("NZDUSD", OP_SELL))>0) event_24_24_1=1;else event_24_24_1=0;                               
        if(CountOrders("NZDCAD", OP_BUY)>0) event_25_1=1;else event_25_1=0;                         
        if(CountOrders("NZDCAD", OP_SELL)>0) event_25_1_s=1;else event_25_1_s=0; 
        if((CountOrders("NZDCAD", OP_BUY)+CountOrders("NZDCAD", OP_SELL))>0) event_25_25_1=1;else event_25_25_1=0; 
//---------------------------------------------------------------------------------------------
        if(((delta_USDCHF_D1>0&&delta_CADCHF_D1>0&&(delta_USDCHF_D1-delta_CADCHF_D1)>delta_USDCHF_CADCHF&&(delta_USDCHF_D1-delta_CADCHF_D1)>delta_USDCHF_CADCHF_average))||((delta_USDCHF_D1<0&&delta_CADCHF_D1<0&&(delta_USDCHF_D1-(delta_CADCHF_D1))>delta_USDCHF_CADCHF&&(delta_USDCHF_D1-(delta_CADCHF_D1))>delta_USDCHF_CADCHF_average))) event_26_1=1; else event_26_1=0;
        if(((delta_USDCHF_D1<0&&delta_CADCHF_D1<0&&(delta_CADCHF_D1-(delta_USDCHF_D1))>delta_USDCHF_CADCHF&&(delta_CADCHF_D1-(delta_USDCHF_D1))>delta_USDCHF_CADCHF_average))||((delta_USDCHF_D1>0&&delta_CADCHF_D1>0&&(delta_CADCHF_D1-delta_USDCHF_D1)>delta_USDCHF_CADCHF&&(delta_CADCHF_D1-delta_USDCHF_D1)>delta_USDCHF_CADCHF_average))) event_26_p=1;else event_26_p=0;  
        if((delta_USDCHF_D1>0&&delta_CADCHF_D1<0&&(delta_USDCHF_D1>(delta_USDCHF_CADCHF/2)&&delta_CADCHF_D1<-(delta_USDCHF_CADCHF/2))&&CountSell()<1&&CountBuy()<1)&&MathAbs(delta_USDCHF_D1-delta_CADCHF_D1)>delta_USDCHF_CADCHF_average) event_26_1_1=1; else event_26_1_1=0;
        if((delta_USDCHF_D1<0&&delta_CADCHF_D1>0&&(delta_USDCHF_D1<-(delta_USDCHF_CADCHF/2)&&delta_CADCHF_D1>(delta_USDCHF_CADCHF/2))&&CountBuy()<1&&CountSell()<1)&&MathAbs(delta_USDCHF_D1-delta_CADCHF_D1)>delta_USDCHF_CADCHF_average) event_26_p_1=1;else event_26_p_1=0;
        if(CountOrders("USDCHF", OP_BUY)>0) event_27_1=1;else event_27_1=0;                         
        if(CountOrders("USDCHF", OP_SELL)>0) event_27_1_s=1;else event_27_1_s=0;
        if((CountOrders("USDCHF", OP_BUY)+CountOrders("USDCHF", OP_SELL))>0) event_27_27_1=1;else event_27_27_1=0;                               
        if(CountOrders("CADCHF", OP_BUY)>0) event_28_1=1;else event_28_1=0;                         
        if(CountOrders("CADCHF", OP_SELL)>0) event_28_1_s=1;else event_28_1_s=0; 
        if((CountOrders("CADCHF", OP_BUY)+CountOrders("CADCHF", OP_SELL))>0) event_28_28_1=1;else event_28_28_1=0;                               
//------------------------------------------------------------------------------------------- 
        if(OrdersTotal()>=1&&OrdersTotal()<=2)event_25=1;else event_25=0;
        if(OrdersTotal()>2&&OrdersTotal()<=4)event_26=1;else event_26=0;
        if(OrdersTotal()>4&&OrdersTotal()<=6)event_27=1;else event_27=0;
        if(OrdersTotal()>6&&OrdersTotal()<=8)event_28=1;else event_28=0;
        if(OrdersTotal()>8&&OrdersTotal()<=10)event_29=1;else event_29=0;
        if(OrdersTotal()>10&&OrdersTotal()<=12)event_30=1;else event_30=0;
        if(OrdersTotal()>12&&OrdersTotal()<=14)event_31=1;else event_31=0;
        if(OrdersTotal()>14&&OrdersTotal()<=16)event_32=1;else event_32=0;
        if(OrdersTotal()>16)event_33=1;else event_33=0;  
//-----------------------конец события---------------------------------------------------------

//-----------------------создаем линии на графике----------------------------------------------
         for (int i=0;i<41;i++){string vlin1e_="vlin1e_"+IntegerToString(i+1);
         
         if(ObjectFind(0,vlin1e_)==-1){
         ObjectCreate(0,vlin1e_,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet(vlin1e_,OBJPROP_CORNER,0);ObjectSetString(0,vlin1e_,OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,vlin1e_,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,vlin1e_,OBJPROP_STYLE,STYLE_SOLID);ObjectSetInteger(0,vlin1e_,OBJPROP_WIDTH,0);ObjectSetInteger(0,vlin1e_,OBJPROP_XSIZE,1);
         if((i>=0&&i<=7)||i==23)ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,846);
         if(i==2||i==6||(i>=17&&i<=22))ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,12);
         if(i==8||i==10||(i>=28&&i<=31))ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,290);
         if((i>=33&&i<=36)||(i>=11&&i<=16))ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,570);
         if(i==9||(i>=24&&i<=27))ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,430);
         if(i==32)ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,4);
         if(i>=37&&i<=40)ObjectSetInteger(0,vlin1e_,OBJPROP_XDISTANCE,709);
         if(i==0||i==14||i==19)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,256);
         if(i==1||i==15||i==20)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,276);
         if(i==2)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,381);
         if(i==3||i==8||i==9)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,397);
         if(i==4)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,417);
         if(i==5)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,437);
         if(i==6)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,590);
         if(i==7)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,656);
         if(i==10||i==11)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,636);
         if(i==12||i==17)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,216);
         if(i==13||i==18)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,236);
         if(i==16||i==21)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,296);
         if(i==22)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,152);
         if(i==24||i==28||i==33||i==37)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,56);
         if(i==25||i==29||i==34||i==38)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,76);
         if(i==23||i==32||i==26||i==30||i==35||i==39)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,96);
         if(i==27||i==31||i==36||i==40)ObjectSetInteger(0,vlin1e_,OBJPROP_YDISTANCE,116);
         if(i==0||i==3||i==4||i==8||i==9||(i>=12&&i<=21)||(i>=24&&i<=31)||(i>=33&&i<=40))ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,22);
         if(i==1)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,108);
         if(i==2||i==23)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,58);
         if(i==7)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,57);
         if(i==5)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,158);
         if(i==6)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,50);
         if(i==8||i==9)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,42);
         if(i==10||i==11)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,64);
         if(i==22)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,66);
         if(i==32)ObjectSetInteger(0,vlin1e_,OBJPROP_YSIZE,618);}
         
                  

         if((i==0)&&event_0==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==0)&&event_0!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==1||i==2||i==8||i==9||i==22||i==23)&&event_1==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==1||i==2||i==8||i==9||i==22||i==23)&&event_1!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==3)&&event_34==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==3)&&(event_1==1||event_34!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==4)&&(event_34==1||event_35==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==4)&&(event_1==1||(event_34!=1&&event_35!=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==5||i==6||i==7||i==10||i==11||i==32)&&(count_close>=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==5||i==6||i==7||i==10||i==11||i==32)&&(count_close<1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);         
         if((i==12)&&(event_3_3==1||event_4_4==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==12)&&(event_3_3!=1&&event_4_4!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==13)&&(event_3_3==1||event_4_4==1||event_6_6==1||event_7_7==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==13)&&(event_3_3!=1&&event_4_4!=1&&event_6_6!=1&&event_7_7!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==14)&&(event_3_s==1||event_4_s==1||event_6_s==1||event_7_s==1||event_12_s==1||event_13_s==1||event_21==1||event_22==1||event_24_1==1||event_25_1==1||event_27_1==1||event_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==14)&&(OrdersTotal()<=0||(event_3_s!=1&&event_4_s!=1&&event_6_s!=1&&event_7_s!=1&&event_12_s!=1&&event_13_s!=1&&event_21!=1&&event_22!=1&&event_24_1!=1&&event_25_1!=1&&event_27_1!=1&&event_28_1!=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==15||i==20)&&(event_24_24_1==1||event_25_25_1==1||event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==15||i==20)&&(event_24_24_1!=1&&event_25_25_1!=1&&event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==16||i==21)&&(event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==16||i==21)&&(event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==17)&&(event_6_6==1||event_7_7==1||event_12_12==1||event_13_13==1||event_21_21==1||event_22_22==1||event_24_24_1==1||event_25_25_1==1||event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==17)&&(event_6_6!=1&&event_7_7!=1&&event_12_12!=1&&event_13_13!=1&&event_21_21!=1&&event_22_22!=1&&event_24_24_1!=1&&event_25_25_1!=1&&event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==18)&&(event_12_12==1||event_13_13==1||event_21_21==1||event_22_22==1||event_24_24_1==1||event_25_25_1==1||event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==18)&&(event_12_12!=1&&event_13_13!=1&&event_21_21!=1&&event_22_22!=1&&event_24_24_1!=1&&event_25_25_1!=1&&event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==19)&&(event_21_21==1||event_22_22==1||event_24_24_1==1||event_25_25_1==1||event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==19)&&(event_21_21!=1&&event_22_22!=1&&event_24_24_1!=1&&event_25_25_1!=1&&event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);         
         if((i==24||i==28)&&DayOfWeek()==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==24||i==28)&&DayOfWeek()!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==25||i==29)&&(DayOfWeek()==1||DayOfWeek()==2))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==25||i==29)&&(DayOfWeek()!=1&&DayOfWeek()!=2))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==26||i==30)&&(DayOfWeek()==4||DayOfWeek()==5))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==26||i==30)&&(DayOfWeek()!=4&&DayOfWeek()!=5))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==27||i==31)&&(DayOfWeek()==5||DayOfWeek()==6||DayOfWeek()==0))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==27||i==31)&&(DayOfWeek()!=5&&DayOfWeek()!=6&&DayOfWeek()!=0))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);

         if(event_1==1)
         {
         if((i==33||i==37)&&(FileIsExist(filename1,0)>=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==33||i==37)&&(FileIsExist(filename1,0)!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         
         if((i==34||i==38)&&((FileIsExist(filename2,0)>=1)||(FileIsExist(filename1,0)>=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==34||i==38)&&((FileIsExist(filename2,0)!=1)&&(FileIsExist(filename1,0)!=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         
         if((i==35||i==39)&&((FileIsExist(filename4,0)>=1)||(FileIsExist(filename5,0)>=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==35||i==39)&&((FileIsExist(filename4,0)!=1)&&(FileIsExist(filename5,0)!=1)))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         
         if((i==36||i==40)&&(FileIsExist(filename5,0)>=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==36||i==40)&&(FileIsExist(filename5,0)!=1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);}
         
         if(event_1==0)
         {
         if((i==33)&&str1_time==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==37)&&str1_time==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==33||i==37)&&str1_time!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==34)&&(str2_time==1||str1_time==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==38)&&(str2_time==1||str1_time==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==34||i==38)&&str2_time!=1&&str1_time!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==35)&&(str4_time==1||str5_time==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==39)&&(str4_time==1||str5_time==1))ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==35||i==39)&&str4_time!=1&&str5_time!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==36)&&str5_time==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==40)&&str5_time==1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==36||i==40)&&str5_time!=1)ObjectSetInteger(0,vlin1e_,OBJPROP_BGCOLOR,col_5);}
         }
//-------------------------------------------------------------------------------------------  
         for (int i=0;i<39;i++){string hlin1e_="hlin1e_"+IntegerToString(i+1);
         
         if(ObjectFind(0,hlin1e_)==-1){
         ObjectCreate(0,hlin1e_,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet(hlin1e_,OBJPROP_CORNER,0);ObjectSetString(0,hlin1e_,OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,hlin1e_,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,hlin1e_,OBJPROP_STYLE,STYLE_SOLID);ObjectSetInteger(0,hlin1e_,OBJPROP_WIDTH,0);ObjectSetInteger(0,hlin1e_,OBJPROP_YSIZE,1);
         if(i==0||i==1||i==2||i==9||i==10||(i>=21&&i<=28))ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,12);
         if(i==14||i==15)ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,4);
         if(i==3||i==4||i==5)ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,429);
         if(i==19||i==20||(i>=34&&i<=38))ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,569);
         if(i==6||i==7||i==8)ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,840);
         if(i==11||i==12||i==13||i==16||(i>=29&&i<=33))ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,290);
         if(i==17)ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,140);
         if(i==18)ObjectSetInteger(0,hlin1e_,OBJPROP_XDISTANCE,707);
         if(i==0||i==3||i==6)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,397);
         if(i==1||i==4||i==7||i==16)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,417);
         if(i==2||i==5||i==8)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,437);
         if(i==9)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,592);
         if(i==10)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,637);
         if(i==14)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,710);
         if(i==15||i==17||i==18||i==31||i==36)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,97);
         if(i==11)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,657);
         if(i==12)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,677);
         if(i==13)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,697);
         if(i==19||i==23)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,257);
         if(i==20||i==24)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,277);
         if(i==21)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,217);
         if(i==22)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,237);
         if(i==25)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,297);
         if(i==26)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,317);
         if(i==27)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,153);
         if(i==28)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,382);
         if(i==29||i==34)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,57);
         if(i==30||i==35)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,77);
         if(i==32||i==37)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,117);
         if(i==33||i==38)ObjectSetInteger(0,hlin1e_,OBJPROP_YDISTANCE,137);
         if(i==0||i==1||i==2||i==20||i==19)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,279);
         if(i==13)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,282);
         if(i==3||i==4||i==5)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,294);
         if(i==6||i==7||i==8)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,8);
         if(i==15)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,22);
         if(i==9||i==27||i==28||i==27||i==28)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,835);
         if(i==14)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,844);
         if(i==16||i==18||(i>=29&&i<=39))ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,141);
         if(i==21||i==22||i==23||i==24||i==25||i==26)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,560);
         if(i==10||i==11||i==12)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,559);
         if(i==17)ObjectSetInteger(0,hlin1e_,OBJPROP_XSIZE,430);
         if(i==17)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);}
         
         
         if(((i>=0&&i<=5)||i==16||i==18||i==27||i==28)&&event_1==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if(((i>=0&&i<=5)||i==16||i==18||i==27||i==28)&&event_1==0)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);                  
         if((i==6)&&event_34==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==6)&&(event_1==1||event_34!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==7)&&event_35==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==7)&&(event_1==1||event_35!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);  
         if((i==8)&&event_36==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==8)&&(event_1==1||event_36!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i>=9&&i<=15)&&count_close>=1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i>=9&&i<=15)&&count_close<1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);            
         if((i==19)&&event_0==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==19)&&event_0==0)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);    
         if((i==20)&&event_0_s==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==20)&&event_0_s==0)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==21)&&(event_3_3==1||event_4_4==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==21)&&(event_3_3!=1&&event_4_4!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==22)&&(event_6_6==1||event_7_7==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==22)&&(event_6_6!=1&&event_7_7!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==23)&&(event_12_12==1||event_13_13==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==23)&&(event_12_12!=1&&event_13_13!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==24)&&(event_21_21==1||event_22_22==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==24)&&(event_21_21!=1&&event_22_22!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==25)&&(event_24_24_1==1||event_25_25_1==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==25)&&(event_24_24_1!=1&&event_25_25_1!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==26)&&(event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==26)&&(event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);       
         if((i==29)&&DayOfWeek()==1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==29)&&DayOfWeek()!=1)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==30)&&DayOfWeek()==2)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==30)&&DayOfWeek()!=2)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==31)&&DayOfWeek()==3)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==31)&&DayOfWeek()!=3)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==32)&&DayOfWeek()==4)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==32)&&DayOfWeek()!=4)ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==33)&&(DayOfWeek()==5||DayOfWeek()==6||DayOfWeek()==0))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==33)&&(DayOfWeek()!=5&&DayOfWeek()!=6&&DayOfWeek()!=0))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);

         if((i==34)&&(event_1==0&&(str1_time==1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==34)&&(event_1==1&&(FileIsExist(filename1,0)>=1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==34)&&((event_1==0&&(str1_time!=1))||((event_1==1&&(FileIsExist(filename1,0)!=1)))))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==35)&&(event_1==0&&(str2_time==1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==35)&&(event_1==1&&(FileIsExist(filename2,0)>=1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==35)&&((event_1==0&&(str2_time!=1))||((event_1==1&&(FileIsExist(filename2,0)!=1)))))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==36)&&(event_1==0&&(str3_time==1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==36)&&(event_1==1&&(FileIsExist(filename3,0)>=1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==36)&&((event_1==0&&(str3_time!=1))||((event_1==1&&(FileIsExist(filename3,0)!=1)))))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==37)&&(event_1==0&&(str4_time==1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==37)&&(event_1==1&&(FileIsExist(filename4,0)>=1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==37)&&((event_1==0&&(str4_time!=1))||((event_1==1&&(FileIsExist(filename4,0)!=1)))))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);
         if((i==38)&&(event_1==0&&(str5_time==1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,Color_tch_ac);
         if((i==38)&&(event_1==1&&(FileIsExist(filename5,0)>=1)))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_14);
         if((i==38)&&((event_1==0&&(str5_time!=1))||((event_1==1&&(FileIsExist(filename5,0)!=1)))))ObjectSetInteger(0,hlin1e_,OBJPROP_BGCOLOR,col_5);}       
//-----------------------конец создаем линии на графике--------------------------------------

//-----------------------создаем рамки на графике--------------------------------------------
         for(int i=0; i<= 78;i++){string frm_="frm_"+IntegerToString(i);
         if(ObjectFind(0,frm_)==-1){
         ObjectCreate(0,frm_,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetString(0,frm_,OBJPROP_TOOLTIP,"\n");ObjectSet(frm_,OBJPROP_CORNER,CORNER);ObjectSetInteger(0,frm_,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,frm_,OBJPROP_STYLE,STYLE_SOLID);ObjectSetInteger(0,frm_,OBJPROP_WIDTH,1); }
         
         if(i>=0&&i<=15)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,20);
         if(i>=16&&i<=26)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,160);
         if(i>=27&&i<=43)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,300);
         if(i>=44&&i<=57)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,440);
         if((i>=58&&i<=69)||i==78)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,580);
         if(i>=70&&i<=77)ObjectSetInteger(0,frm_,OBJPROP_XDISTANCE,720);
         if(i==0)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,20);
         if(i==1||i==16||i==29||i==44||i==60||i==70)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,90);
         if(i==2)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,160);
         if(i==3||i==17||i==32||i==45)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,210);
         if(i==4||i==18||i==33||i==46)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,230);
         if(i==5||i==19||i==34||i==47||i==63||i==71)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,250);
         if(i==6||i==20||i==35||i==48||i==64||i==72)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,270);
         if(i==7||i==21||i==36||i==49)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,290);
         if(i==8||i==22||i==37||i==50)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,310);
         if(i==9)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,360);
         if(i==10||i==23||i==51||i==65||i==73)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,390);
         if(i==11||i==24||i==38||i==52||i==66||i==74)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,410);
         if(i==12||i==25||i==53||i==67||i==75)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,430);
         if(i==13||i==39||i==78)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,450);
         if(i==14)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,600);
         if(i==15||i==26||i==40||i==54)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,630);
         if(i==27||i==58)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,50);
         if(i==28||i==59)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,70);
         if(i==30||i==61)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,110);
         if(i==31||i==62)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,130);
         if(i==41||i==55||i==68||i==76)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,650);
         if(i==42||i==56||i==69||i==77)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,670);
         if(i==43||i==57)ObjectSetInteger(0,frm_,OBJPROP_YDISTANCE,690);
         if((i>=0&&i<=12)||i==14||(i>=15&&i<=38)||(i>=40&&i<=77))ObjectSetInteger(0,frm_,OBJPROP_YSIZE,16); //верстикаль
         if(i==13||i==39||i==78)ObjectSetInteger(0,frm_,OBJPROP_YSIZE,135); //верстикаль
         if(i==0||i==2||i==9||i==14)ObjectSetInteger(0,frm_,OBJPROP_XSIZE,820); //горизонталь
         if(i==1||(i>=3&&i<=8)||i==10||i==11||i==12||(i>=15&&i<=38)||(i>=40&&i<=77))ObjectSetInteger(0,frm_,OBJPROP_XSIZE,120); //горизонталь
         if(i==13||i==39||i==78)ObjectSetInteger(0,frm_,OBJPROP_XSIZE,260); //горизонталь
         if(i==0||i==2||i==9||i==14)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==1||i==16)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==13||i==39||i==78)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_9); 
        

         if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1)ObjectSetInteger(0,frm_,OBJPROP_BGCOLOR,(C'10,10,46'));
         if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1)ObjectSetInteger(0,frm_,OBJPROP_BGCOLOR,(C'51,0,0'));
         if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1)ObjectSetInteger(0,frm_,OBJPROP_BGCOLOR,(C'0,23,0'));
         if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0)ObjectSetInteger(0,frm_,OBJPROP_BGCOLOR,col_17); 
         

         if((i==3||i==17||i==32||i==45)&&(event_3_3==1||event_4_4==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==3||i==17||i==32||i==45)&&(event_3_3!=1&&event_4_4!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==4||i==18||i==33||i==46)&&(event_6_6==1||event_7_7==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==4||i==18||i==33||i==46)&&(event_6_6!=1&&event_7_7!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==5||i==19||i==34||i==47)&&(event_12_12==1||event_13_13==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==5||i==19||i==34||i==47)&&(event_12_12!=1&&event_13_13!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==6||i==20||i==35||i==48)&&(event_21_21==1||event_22_22==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==6||i==20||i==35||i==48)&&(event_21_21!=1&&event_22_22!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==7||i==21||i==36||i==49)&&(event_24_24_1==1||event_25_25_1==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==7||i==21||i==36||i==49)&&(event_24_24_1!=1&&event_25_25_1!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==8||i==22||i==37||i==50)&&(event_27_27_1==1||event_28_28_1==1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==8||i==22||i==37||i==50)&&(event_27_27_1!=1&&event_28_28_1!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==10||i==11||i==12||i==23||i==24||i==25||i==38||i==51||i==52||i==53)&&event_1==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==10||i==11||i==12||i==23||i==24||i==25||i==38||i==51||i==52||i==53)&&event_1==0)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==15||i==26||(i>=40&&i<=43)||(i>=54&&i<=57)||i==68||i==69)&&count_close>=1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==15||i==26||(i>=40&&i<=43)||(i>=54&&i<=57)||i==68||i==69)&&count_close<1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);      
         if((i==27)&&DayOfWeek()==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==27)&&DayOfWeek()!=1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);       
         if((i==28)&&DayOfWeek()==2)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==28)&&DayOfWeek()!=2)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);   
         if((i==29)&&DayOfWeek()==3)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==29)&&DayOfWeek()!=3)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5); 
         if((i==30)&&DayOfWeek()==4)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==30)&&DayOfWeek()!=4)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5); 
         if((i==31)&&(DayOfWeek()==5||DayOfWeek()==6||DayOfWeek()==0))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==31)&&(DayOfWeek()!=5&&DayOfWeek()!=6&&DayOfWeek()!=0))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==44)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==65||i==66||i==67)&&event_1==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==65||i==66||i==67)&&event_1==0)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==58)&&(event_1==0&&(str1_time==1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,Color_tch_ac);
         if((i==58)&&(event_1==1&&(FileIsExist(filename1,0)>=1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==58)&&((event_1==0&&(str1_time!=1))||((event_1==1&&(FileIsExist(filename1,0)!=1)))))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==59)&&(event_1==0&&(str2_time==1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,Color_tch_ac);
         if((i==59)&&(event_1==1&&(FileIsExist(filename2,0)>=1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==59)&&((event_1==0&&(str2_time!=1))||((event_1==1&&(FileIsExist(filename2,0)!=1)))))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==60)&&(event_1==0&&(str3_time==1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,Color_tch_ac);
         if((i==60)&&(event_1==1&&(FileIsExist(filename3,0)>=1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==60)&&((event_1==0&&(str3_time!=1))||((event_1==1&&(FileIsExist(filename3,0)!=1)))))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==61)&&(event_1==0&&(str4_time==1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,Color_tch_ac);
         if((i==61)&&(event_1==1&&(FileIsExist(filename4,0)>=1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==61)&&((event_1==0&&(str4_time!=1))||((event_1==1&&(FileIsExist(filename4,0)!=1)))))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==62)&&(event_1==0&&(str5_time==1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,Color_tch_ac);
         if((i==62)&&(event_1==1&&(FileIsExist(filename5,0)>=1)))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==62)&&((event_1==0&&(str5_time!=1))||((event_1==1&&(FileIsExist(filename5,0)!=1)))))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==63||i==71)&&event_0==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==63||i==71)&&event_0!=1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==70)&&event_1==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==70)&&event_1!=1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if((i==64||i==72)&&event_0_s==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if((i==64||i==72)&&event_0_s!=1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==73&&event_34==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==73&&(event_1==1||event_34!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==74&&event_35==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==74&&(event_1==1||event_35!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==75&&event_36==1)ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==75&&(event_1==1||event_36!=1))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==76&&(count_close>=1&&r0>=0.25))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==76&&(count_close>=1&&r0<0.25))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_9);
         if(i==76&&(count_close<1&&r0>=0.25))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==76&&(count_close<1&&r0<0.25))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==77&&(count_close>=1&&(AccountEquity()-Equity_mn1)/(Equity_mn1/100)>=5))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_14);
         if(i==77&&(count_close>=1&&(AccountEquity()-Equity_mn1)/(Equity_mn1/100)<5))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_9);
         if(i==77&&(count_close<1&&(AccountEquity()-Equity_mn1)/(Equity_mn1/100)>=5))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);
         if(i==77&&(count_close<1&&(AccountEquity()-Equity_mn1)/(Equity_mn1/100)<5))ObjectSetInteger(0,frm_,OBJPROP_COLOR,col_5);} 
//-----------------------конец создаем рамки на графике--------------------------------------

//-----------------------пишем тест----------------------------------------------------------
         for(int i=3; i<= 107; i++){string objectName="text_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName, OBJPROP_CORNER,0);

         ObjectSet("text_3",OBJPROP_XDISTANCE,20);
         ObjectSet("text_3",OBJPROP_YDISTANCE,20);
         ObjectSet("text_4",OBJPROP_XDISTANCE,440);
         ObjectSet("text_4",OBJPROP_YDISTANCE,20);
         ObjectSet("text_5",OBJPROP_XDISTANCE,30);
         ObjectSet("text_5",OBJPROP_YDISTANCE,90);//
         ObjectSet("text_6",OBJPROP_XDISTANCE,310);
         ObjectSet("text_6",OBJPROP_YDISTANCE,50);
         ObjectSet("text_7",OBJPROP_XDISTANCE,310);
         ObjectSet("text_7",OBJPROP_YDISTANCE,70);
         ObjectSet("text_8",OBJPROP_XDISTANCE,310);
         ObjectSet("text_8",OBJPROP_YDISTANCE,90);
         ObjectSet("text_9",OBJPROP_XDISTANCE,310);
         ObjectSet("text_9",OBJPROP_YDISTANCE,110);
         ObjectSet("text_10",OBJPROP_XDISTANCE,310);
         ObjectSet("text_10",OBJPROP_YDISTANCE,130);
         ObjectSet("text_11",OBJPROP_XDISTANCE,20);
         ObjectSet("text_11",OBJPROP_YDISTANCE,160);
         ObjectSet("text_12",OBJPROP_XDISTANCE,440);
         ObjectSet("text_12",OBJPROP_YDISTANCE,160);
         ObjectSet("text_13",OBJPROP_XDISTANCE,20);
         ObjectSet("text_13",OBJPROP_YDISTANCE,360);
         ObjectSet("text_14",OBJPROP_XDISTANCE,440);
         ObjectSet("text_14",OBJPROP_YDISTANCE,360);
         ObjectSet("text_15",OBJPROP_XDISTANCE,20);
         ObjectSet("text_15",OBJPROP_YDISTANCE,600);
         ObjectSet("text_16",OBJPROP_XDISTANCE,440);
         ObjectSet("text_16",OBJPROP_YDISTANCE,600);
         ObjectSet("text_17",OBJPROP_XDISTANCE,20);
         ObjectSet("text_17",OBJPROP_YDISTANCE,210);
         ObjectSet("text_18",OBJPROP_XDISTANCE,20);
         ObjectSet("text_18",OBJPROP_YDISTANCE,210);
         ObjectSet("text_19",OBJPROP_XDISTANCE,170);
         ObjectSet("text_19",OBJPROP_YDISTANCE,210);
         ObjectSet("text_20",OBJPROP_XDISTANCE,220);
         ObjectSet("text_20",OBJPROP_YDISTANCE,210);
         ObjectSet("text_21",OBJPROP_XDISTANCE,310);
         ObjectSet("text_21",OBJPROP_YDISTANCE,210);
         ObjectSet("text_22",OBJPROP_XDISTANCE,450);
         ObjectSet("text_22",OBJPROP_YDISTANCE,210);
         ObjectSet("text_23",OBJPROP_XDISTANCE,500);
         ObjectSet("text_23",OBJPROP_YDISTANCE,210);
         ObjectSet("text_24",OBJPROP_XDISTANCE,20);
         ObjectSet("text_24",OBJPROP_YDISTANCE,230);
         ObjectSet("text_25",OBJPROP_XDISTANCE,20);
         ObjectSet("text_25",OBJPROP_YDISTANCE,230);
         ObjectSet("text_26",OBJPROP_XDISTANCE,170);
         ObjectSet("text_26",OBJPROP_YDISTANCE,230);
         ObjectSet("text_27",OBJPROP_XDISTANCE,220);
         ObjectSet("text_27",OBJPROP_YDISTANCE,230);
         ObjectSet("text_28",OBJPROP_XDISTANCE,310);
         ObjectSet("text_28",OBJPROP_YDISTANCE,230);
         ObjectSet("text_29",OBJPROP_XDISTANCE,450);
         ObjectSet("text_29",OBJPROP_YDISTANCE,230);
         ObjectSet("text_30",OBJPROP_XDISTANCE,500);
         ObjectSet("text_30",OBJPROP_YDISTANCE,230);
         ObjectSet("text_31",OBJPROP_XDISTANCE,20);
         ObjectSet("text_31",OBJPROP_YDISTANCE,250);
         ObjectSet("text_32",OBJPROP_XDISTANCE,20);
         ObjectSet("text_32",OBJPROP_YDISTANCE,250);
         ObjectSet("text_33",OBJPROP_XDISTANCE,170);             
         ObjectSet("text_33",OBJPROP_YDISTANCE,250);
         ObjectSet("text_34",OBJPROP_XDISTANCE,220);             
         ObjectSet("text_34",OBJPROP_YDISTANCE,250);
         ObjectSet("text_35",OBJPROP_XDISTANCE,310);             
         ObjectSet("text_35",OBJPROP_YDISTANCE,250); 
         ObjectSet("text_36",OBJPROP_XDISTANCE,450);
         ObjectSet("text_36",OBJPROP_YDISTANCE,250);
         ObjectSet("text_37",OBJPROP_XDISTANCE,500);
         ObjectSet("text_37",OBJPROP_YDISTANCE,250);
         ObjectSet("text_38", OBJPROP_XDISTANCE,20);
         ObjectSet("text_38",OBJPROP_YDISTANCE,270);
         ObjectSet("text_39", OBJPROP_XDISTANCE,20);
         ObjectSet("text_39",OBJPROP_YDISTANCE,270);
         ObjectSet("text_40",OBJPROP_XDISTANCE,170);             
         ObjectSet("text_40",OBJPROP_YDISTANCE,270);
         ObjectSet("text_41",OBJPROP_XDISTANCE,220);             
         ObjectSet("text_41",OBJPROP_YDISTANCE,270);
         ObjectSet("text_42",OBJPROP_XDISTANCE,310);             
         ObjectSet("text_42",OBJPROP_YDISTANCE,270); 
         ObjectSet("text_43",OBJPROP_XDISTANCE,450);
         ObjectSet("text_43",OBJPROP_YDISTANCE,270);
         ObjectSet("text_44",OBJPROP_XDISTANCE,500);
         ObjectSet("text_44",OBJPROP_YDISTANCE,270);
         ObjectSet("text_45",OBJPROP_XDISTANCE,20);
         ObjectSet("text_45",OBJPROP_YDISTANCE,290);
         ObjectSet("text_46",OBJPROP_XDISTANCE,20);
         ObjectSet("text_46",OBJPROP_YDISTANCE,290);
         ObjectSet("text_47",OBJPROP_XDISTANCE,170);             
         ObjectSet("text_47",OBJPROP_YDISTANCE,290);
         ObjectSet("text_48",OBJPROP_XDISTANCE,220);             
         ObjectSet("text_48",OBJPROP_YDISTANCE,290);
         ObjectSet("text_49",OBJPROP_XDISTANCE,310);             
         ObjectSet("text_49",OBJPROP_YDISTANCE,290);
         ObjectSet("text_50",OBJPROP_XDISTANCE,450);
         ObjectSet("text_50",OBJPROP_YDISTANCE,290);
         ObjectSet("text_51",OBJPROP_XDISTANCE,500);
         ObjectSet("text_51",OBJPROP_YDISTANCE,290);
         ObjectSet("text_52",OBJPROP_XDISTANCE,20);
         ObjectSet("text_52",OBJPROP_YDISTANCE,310);
         ObjectSet("text_53",OBJPROP_XDISTANCE,20);
         ObjectSet("text_53",OBJPROP_YDISTANCE,310);
         ObjectSet("text_54",OBJPROP_XDISTANCE,170);             
         ObjectSet("text_54",OBJPROP_YDISTANCE,310);
         ObjectSet("text_55",OBJPROP_XDISTANCE,220);             
         ObjectSet("text_55",OBJPROP_YDISTANCE,310);
         ObjectSet("text_56",OBJPROP_XDISTANCE,310);             
         ObjectSet("text_56",OBJPROP_YDISTANCE,310);
         ObjectSet("text_57",OBJPROP_XDISTANCE,450);
         ObjectSet("text_57",OBJPROP_YDISTANCE,310);
         ObjectSet("text_58",OBJPROP_XDISTANCE,500);
         ObjectSet("text_58",OBJPROP_YDISTANCE,310);
         ObjectSet("text_59", OBJPROP_XDISTANCE,75);
         ObjectSet("text_59",OBJPROP_YDISTANCE,0);
         ObjectSet("text_60",OBJPROP_YDISTANCE,-2);
         ObjectSet("text_60",OBJPROP_XDISTANCE,4);
         ObjectSet("text_61",OBJPROP_XDISTANCE,730);
         ObjectSet("text_61",OBJPROP_YDISTANCE,250);
         ObjectSet("text_62",OBJPROP_XDISTANCE,730);
         ObjectSet("text_62",OBJPROP_YDISTANCE,270);
         ObjectSet("text_63",OBJPROP_XDISTANCE,580);
         ObjectSet("text_63",OBJPROP_YDISTANCE,250);
         ObjectSet("text_64",OBJPROP_XDISTANCE,580);
         ObjectSet("text_64",OBJPROP_YDISTANCE,270);
         ObjectSet("text_65",OBJPROP_XDISTANCE,640);
         ObjectSet("text_65",OBJPROP_YDISTANCE,250);
         ObjectSet("text_66",OBJPROP_XDISTANCE,640);
         ObjectSet("text_66",OBJPROP_YDISTANCE,270);
         ObjectSet("text_67",OBJPROP_XDISTANCE,20);
         ObjectSet("text_67",OBJPROP_YDISTANCE,390);
         ObjectSet("text_68",OBJPROP_XDISTANCE,20);
         ObjectSet("text_68",OBJPROP_YDISTANCE,410);
         ObjectSet("text_69",OBJPROP_XDISTANCE,20);
         ObjectSet("text_69",OBJPROP_YDISTANCE,430);
         ObjectSet("text_70",OBJPROP_XDISTANCE,170);
         ObjectSet("text_70",OBJPROP_YDISTANCE,390);
         ObjectSet("text_71",OBJPROP_XDISTANCE,170);
         ObjectSet("text_71",OBJPROP_YDISTANCE,410);
         ObjectSet("text_72",OBJPROP_XDISTANCE,170);
         ObjectSet("text_72",OBJPROP_YDISTANCE,430);
         ObjectSet("text_73",OBJPROP_XDISTANCE,230);
         ObjectSet("text_73",OBJPROP_YDISTANCE,430);
         ObjectSet("text_74",OBJPROP_XDISTANCE,720);
         ObjectSet("text_74",OBJPROP_YDISTANCE,430);
         ObjectSet("text_75",OBJPROP_XDISTANCE,300);
         ObjectSet("text_75",OBJPROP_YDISTANCE,410);
         ObjectSet("text_76",OBJPROP_XDISTANCE,450);
         ObjectSet("text_76",OBJPROP_YDISTANCE,390);
         ObjectSet("text_77",OBJPROP_XDISTANCE,590);
         ObjectSet("text_77",OBJPROP_YDISTANCE,390);
         ObjectSet("text_78",OBJPROP_XDISTANCE,450);
         ObjectSet("text_78",OBJPROP_YDISTANCE,410);
         ObjectSet("text_79",OBJPROP_XDISTANCE,450);
         ObjectSet("text_79",OBJPROP_YDISTANCE,430);
         ObjectSet("text_80",OBJPROP_XDISTANCE,590);
         ObjectSet("text_80",OBJPROP_YDISTANCE,410);
         ObjectSet("text_81",OBJPROP_XDISTANCE,720);
         ObjectSet("text_81",OBJPROP_YDISTANCE,390);
         ObjectSet("text_82",OBJPROP_XDISTANCE,720);
         ObjectSet("text_82",OBJPROP_YDISTANCE,410);
         ObjectSet("text_83",OBJPROP_XDISTANCE,170);
         ObjectSet("text_83",OBJPROP_YDISTANCE,630);
         ObjectSet("text_84",OBJPROP_XDISTANCE,30);
         ObjectSet("text_84",OBJPROP_YDISTANCE,630);
         ObjectSet("text_85",OBJPROP_XDISTANCE,300);
         ObjectSet("text_85",OBJPROP_YDISTANCE,630);
         ObjectSet("text_86",OBJPROP_XDISTANCE,300);
         ObjectSet("text_86",OBJPROP_YDISTANCE,650);
         ObjectSet("text_87",OBJPROP_XDISTANCE,300);
         ObjectSet("text_87",OBJPROP_YDISTANCE,670);
         ObjectSet("text_88",OBJPROP_XDISTANCE,300);
         ObjectSet("text_88",OBJPROP_YDISTANCE,690);
         ObjectSet("text_89",OBJPROP_XDISTANCE,590);
         ObjectSet("text_89",OBJPROP_YDISTANCE,650);
         ObjectSet("text_90",OBJPROP_XDISTANCE,590);
         ObjectSet("text_90",OBJPROP_YDISTANCE,670);
         ObjectSet("text_91",OBJPROP_XDISTANCE,720);
         ObjectSet("text_91",OBJPROP_YDISTANCE,650);
         ObjectSet("text_92",OBJPROP_XDISTANCE,720);
         ObjectSet("text_92",OBJPROP_YDISTANCE,670);
         ObjectSet("text_93",OBJPROP_XDISTANCE,450);
         ObjectSet("text_93",OBJPROP_YDISTANCE,630);
         ObjectSet("text_94",OBJPROP_XDISTANCE,450);
         ObjectSet("text_94",OBJPROP_YDISTANCE,650);
         ObjectSet("text_95",OBJPROP_XDISTANCE,510);
         ObjectSet("text_95",OBJPROP_YDISTANCE,650);
         ObjectSet("text_96",OBJPROP_XDISTANCE,450);
         ObjectSet("text_96",OBJPROP_YDISTANCE,670);
         ObjectSet("text_97",OBJPROP_XDISTANCE,510);
         ObjectSet("text_97",OBJPROP_YDISTANCE,670);
         ObjectSet("text_98",OBJPROP_XDISTANCE,450);
         ObjectSet("text_98",OBJPROP_YDISTANCE,690);
         ObjectSet("text_99",OBJPROP_XDISTANCE,510);
         ObjectSet("text_99",OBJPROP_YDISTANCE,690);
         ObjectSet("text_100",OBJPROP_XDISTANCE,170);
         ObjectSet("text_100",OBJPROP_YDISTANCE,90);
         ObjectSet("text_101",OBJPROP_XDISTANCE,360);
         ObjectSet("text_101",OBJPROP_YDISTANCE,210);
         ObjectSet("text_102",OBJPROP_XDISTANCE,360);
         ObjectSet("text_102",OBJPROP_YDISTANCE,230);
         ObjectSet("text_103",OBJPROP_XDISTANCE,360);
         ObjectSet("text_103",OBJPROP_YDISTANCE,250);
         ObjectSet("text_104",OBJPROP_XDISTANCE,360);
         ObjectSet("text_104",OBJPROP_YDISTANCE,270);
         ObjectSet("text_105",OBJPROP_XDISTANCE,360);
         ObjectSet("text_105",OBJPROP_YDISTANCE,290);
         ObjectSet("text_106",OBJPROP_XDISTANCE,360);
         ObjectSet("text_106",OBJPROP_YDISTANCE,310);
         ObjectSet("text_107",OBJPROP_XDISTANCE,590);
         ObjectSet("text_107",OBJPROP_YDISTANCE,430);
         ObjectSet("text_108",OBJPROP_XDISTANCE,650);
         ObjectSet("text_108",OBJPROP_YDISTANCE,430);
         ObjectSet("text_60", OBJPROP_ANGLE, 0);
         ObjectSet("text_60", OBJPROP_CORNER,1);
         }
//------------------------------------------------------------------------------------------- 
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){       
         ObjectSetText("text_3"," Счет              Дата             День недели",10,TextFONT,col_5);} 
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
         ObjectSetText("text_3"," Счет              Время            День недели",10,TextFONT,col_5);} 
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_4"," Статус            Стратегия        Дней в позе",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         ObjectSetText("text_5",DoubleToStr(NormalizeDouble (AccountNumber(),0),0),10,TextFONT,col_14);
//-------------------------------------------------------------------------------------------
         if(DayOfWeek()==1)ObjectSetText("text_6","Понедельник",10,TextFONT,col_14);
         if(DayOfWeek()!=1)ObjectSetText("text_6","Понедельник",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(DayOfWeek()==2)ObjectSetText("text_7","Вторник",10,TextFONT,col_14);
         if(DayOfWeek()!=2)ObjectSetText("text_7","Вторник",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(DayOfWeek()==3)ObjectSetText("text_8","Среда",10,TextFONT,col_14);
         if(DayOfWeek()!=3)ObjectSetText("text_8","Среда",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(DayOfWeek()==4)ObjectSetText("text_9","Четверг",10,TextFONT,col_14);
         if(DayOfWeek()!=4)ObjectSetText("text_9","Четверг",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(DayOfWeek()==5&&DayOfWeek()!=6&&DayOfWeek()!=0)ObjectSetText("text_10","Пятница",10,TextFONT,col_14);
         if(DayOfWeek()!=5&&DayOfWeek()!=6&&DayOfWeek()!=0)ObjectSetText("text_10","Пятница",10,TextFONT,col_5);
         if(DayOfWeek()==6&&DayOfWeek()!=5&&DayOfWeek()!=0)ObjectSetText("text_10","Суббота",10,TextFONT,col_14);
         if(DayOfWeek()==0&&DayOfWeek()!=5&&DayOfWeek()!=6)ObjectSetText("text_10","Воскресенье",10,TextFONT,col_14);
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
         if(OrdersTotal()>=1)ObjectSetText("text_11"," Суб.стратегия     Изм.D1%          Дельта.D1/MN1%",10,TextFONT,col_5);}
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){ 
         if(OrdersTotal()>=1)ObjectSetText("text_11"," Суб.стратегия     Изм.MN1%         Дельта.D1/MN1%",10,TextFONT,col_5);}
         
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
          if(OrdersTotal()<1)ObjectSetText("text_11"," Поиск страт...    Изм.D1%          Дельта.D1/MN1%",10,TextFONT,col_5);}
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){ 
          if(OrdersTotal()<1)ObjectSetText("text_11"," Поиск страт...    Изм.MN1%         Дельта.D1/MN1%",10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_12"," Тек.спред         Ордера           Доход/Убыток",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_13"," Состояние         Сумма   %        Цель",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_14"," Сумма             До цели          Статус",10,TextFONT,col_5); 
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_15"," Кол.закр.D1       Закр.объем.D1    Заработано",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_16"," Сумма   %         Цель             План",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_3==1&&event_3_s==0)ObjectSetText("text_17"," EURUSD",10,TextFONT,col_14);
         if(event_3_s==1&&event_3==0)ObjectSetText("text_17"," EURUSD",10,TextFONT,col_9);
         if(event_3==0&&event_3_s==0)ObjectSetText("text_17"," EURUSD",10,TextFONT,col_5);
         if(event_3==1&&event_3_s==1)ObjectSetText("text_17"," EURUSD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(event_4==1&&event_4_s==0)ObjectSetText("text_18","        GBPUSD",10,TextFONT,col_14);
         if(event_4_s==1&&event_4==0)ObjectSetText("text_18","        GBPUSD",10,TextFONT,col_9);
         if(event_4==0&&event_4_s==0)ObjectSetText("text_18","        GBPUSD",10,TextFONT,col_5);
         if(event_4==1&&event_4_s==1)ObjectSetText("text_18","        GBPUSD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){           
         if(event_3_3==1)ObjectSetText("text_19",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_D1),2),2),10,TextFONT,col_14);
         if(event_3_3!=1)ObjectSetText("text_19",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_D1),2),2),10,TextFONT,col_5);}         
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){           
         if(event_3_3==1)ObjectSetText("text_19",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_MN1),2),2),10,TextFONT,col_14);
         if(event_3_3!=1)ObjectSetText("text_19",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_MN1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_4_4==1)ObjectSetText("text_20",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPUSD_D1),2),2),10,TextFONT,col_14);
         if(event_4_4!=1)ObjectSetText("text_20",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPUSD_D1),2),2),10,TextFONT,col_5);}     
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){           
         if(event_4_4==1)ObjectSetText("text_20",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPUSD_MN1),2),2),10,TextFONT,col_14);
         if(event_4_4!=1)ObjectSetText("text_20",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPUSD_MN1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         if((event_3_3==1||event_4_4==1)&&(OrdersTotal()>=1))ObjectSetText("text_21",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_D1-(delta_GBPUSD_D1)),2),2),10,TextFONT,col_14);
         if((event_3_3!=1||event_4_4!=1||OrdersTotal()<1))ObjectSetText("text_21",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_D1-(delta_GBPUSD_D1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_3_3==1)ObjectSetText("text_22",(DoubleToStr(NormalizeDouble(MarketInfo("EURUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_3_3!=1)ObjectSetText("text_22",(DoubleToStr(NormalizeDouble(MarketInfo("EURUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_4_4==1)ObjectSetText("text_23",(DoubleToStr(NormalizeDouble(MarketInfo("GBPUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_4_4!=1)ObjectSetText("text_23",(DoubleToStr(NormalizeDouble(MarketInfo("GBPUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);  
//----------------------------------------------------------------------------------------------
         if(event_6==1&&event_6_s==0)ObjectSetText("text_24"," AUDCAD",10,TextFONT,col_14);
         if(event_6_s==1&&event_6==0)ObjectSetText("text_24"," AUDCAD",10,TextFONT,col_9);
         if(event_6==0&&event_6_s==0)ObjectSetText("text_24"," AUDCAD",10,TextFONT,col_5);
         if(event_6==1&&event_6_s==1)ObjectSetText("text_24"," AUDCAD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(event_7==1&&event_7_s==0)ObjectSetText("text_25","        AUDUSD",10,TextFONT,col_14);
         if(event_7_s==1&&event_7==0)ObjectSetText("text_25","        AUDUSD",10,TextFONT,col_9);
         if(event_7==0&&event_7_s==0)ObjectSetText("text_25","        AUDUSD",10,TextFONT,col_5);
         if(event_7==1&&event_7_s==1)ObjectSetText("text_25","        AUDUSD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_6_6==1)ObjectSetText("text_26",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_D1),2),2),10,TextFONT,col_14);
         if(event_6_6!=1)ObjectSetText("text_26",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_D1),2),2),10,TextFONT,col_5);}        
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){            
         if(event_6_6==1)ObjectSetText("text_26",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_MN1),2),2),10,TextFONT,col_14);
         if(event_6_6!=1)ObjectSetText("text_26",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_MN1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_7_7==1)ObjectSetText("text_27",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDUSD_D1),2),2),10,TextFONT,col_14);
         if(event_7_7!=1)ObjectSetText("text_27",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDUSD_D1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------        
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){           
         if(event_7_7==1)ObjectSetText("text_27",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDUSD_MN1),2),2),10,TextFONT,col_14);
         if(event_7_7!=1)ObjectSetText("text_27",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDUSD_MN1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         if((event_6_6==1||event_7_7==1)&&(OrdersTotal()>=1))ObjectSetText("text_28",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_D1-(delta_AUDUSD_D1)),2),2),10,TextFONT,col_14);
         if((event_6_6!=1||event_7_7!=1||OrdersTotal()<1))ObjectSetText("text_28",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_D1-(delta_AUDUSD_D1)),2),2),10,TextFONT,col_5);                 
//-------------------------------------------------------------------------------------------
         if(event_6_6==1)ObjectSetText("text_29",(DoubleToStr(NormalizeDouble(MarketInfo("AUDCAD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_6_6!=1)ObjectSetText("text_29",(DoubleToStr(NormalizeDouble(MarketInfo("AUDCAD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_7_7==1)ObjectSetText("text_30",(DoubleToStr(NormalizeDouble(MarketInfo("AUDUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_7_7!=1)ObjectSetText("text_30",(DoubleToStr(NormalizeDouble(MarketInfo("AUDUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//----------------------------------------------------------------------------------------------
         if(event_12==1&&event_12_s==0)ObjectSetText("text_31"," EURAUD",10,TextFONT,col_14);
         if(event_12_s==1&&event_12==0)ObjectSetText("text_31"," EURAUD",10,TextFONT,col_9);
         if(event_12==0&&event_12_s==0)ObjectSetText("text_31"," EURAUD",10,TextFONT,col_5);
         if(event_12==1&&event_12_s==1)ObjectSetText("text_31"," EURAUD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(event_13==1&&event_13_s==0)ObjectSetText("text_32","        GBPAUD",10,TextFONT,col_14);
         if(event_13_s==1&&event_13==0)ObjectSetText("text_32","        GBPAUD",10,TextFONT,col_9);
         if(event_13==0&&event_13_s==0)ObjectSetText("text_32","        GBPAUD",10,TextFONT,col_5);
         if(event_13==1&&event_13_s==1)ObjectSetText("text_32","        GBPAUD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_12_12==1)ObjectSetText("text_33",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_D1),2),2),10,TextFONT,col_14);
         if(event_12_12!=1)ObjectSetText("text_33",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_D1),2),2),10,TextFONT,col_5);}
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){            
         if(event_12_12==1)ObjectSetText("text_33",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_MN1),2),2),10,TextFONT,col_14);
         if(event_12_12!=1)ObjectSetText("text_33",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_MN1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------
         double delta_value_34=(t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 60) ? MathAbs(delta_GBPAUD_D1) : MathAbs(delta_GBPAUD_MN1);
         color textColor_34=(event_13_13==1) ? col_14 : col_5;
         ObjectSetText("text_34", DoubleToStr(NormalizeDouble(delta_value_34, 2), 2), 10, TextFONT, textColor_34);
//-------------------------------------------------------------------------------------------                             
         if((event_12_12==1||event_13_13==1)&&(OrdersTotal()>=1))ObjectSetText("text_35",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_D1-(delta_GBPAUD_D1)),2),2),10,TextFONT,col_14);
         if((event_12_12!=1||event_13_13!=1||OrdersTotal()<1))ObjectSetText("text_35",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_D1-(delta_GBPAUD_D1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_12_12==1)ObjectSetText("text_36",(DoubleToStr(NormalizeDouble(MarketInfo("EURAUD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_12_12!=1)ObjectSetText("text_36",(DoubleToStr(NormalizeDouble(MarketInfo("EURAUD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_13_13==1)ObjectSetText("text_37",(DoubleToStr(NormalizeDouble(MarketInfo("GBPAUD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_13_13!=1)ObjectSetText("text_37",(DoubleToStr(NormalizeDouble(MarketInfo("GBPAUD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//----------------------------------------------------------------------------------------------
         if(event_21==1&&event_21_1_s==0)ObjectSetText("text_38"," AUDCHF",10,TextFONT,col_14);
         if(event_21_1_s==1&&event_21==0)ObjectSetText("text_38"," AUDCHF",10,TextFONT,col_9);
         if(event_21==0&&event_21_1_s==0)ObjectSetText("text_38"," AUDCHF",10,TextFONT,col_5);
         if(event_21==1&&event_21_1_s==1)ObjectSetText("text_38"," AUDCHF",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(event_22==1&&event_22_1_s==0)ObjectSetText("text_39","        GBPCHF",10,TextFONT,col_14);
         if(event_22_1_s==1&&event_22==0)ObjectSetText("text_39","        GBPCHF",10,TextFONT,col_9);
         if(event_22==0&&event_22_1_s==0)ObjectSetText("text_39","        GBPCHF",10,TextFONT,col_5);
         if(event_22==1&&event_22_1_s==1)ObjectSetText("text_39","        GBPCHF",10,TextFONT,White);
         
//-------------------------------------------------------------------------------------------                  
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_21_21==1)ObjectSetText("text_40",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_D1),2),2),10,TextFONT,col_14);
         if(event_21_21!=1)ObjectSetText("text_40",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_D1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------         
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){            
         if(event_21_21==1)ObjectSetText("text_40",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_MN1),2),2),10,TextFONT,col_14);
         if(event_21_21!=1)ObjectSetText("text_40",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_MN1),2),2),10,TextFONT,col_5);}
//------------------------------------------------------------------------------------------- 
     
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){            
         if(event_22_22==1)ObjectSetText("text_41",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPCHF_D1),2),2),10,TextFONT,col_14);
         if(event_22_22!=1)ObjectSetText("text_41",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPCHF_D1),2),2),10,TextFONT,col_5);}
//-------------------------------------------------------------------------------------------        
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){             
         if(event_22_22==1)ObjectSetText("text_41",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPCHF_MN1),2),2),10,TextFONT,col_14);
         if(event_22_22!=1)ObjectSetText("text_41",DoubleToStr(NormalizeDouble(MathAbs(delta_GBPCHF_MN1),2),2),10,TextFONT,col_5);}
//------------------------------------------------------------------------------------------- 
                    
                    
         if((event_21_21==1||event_22_22==1)&&(OrdersTotal()>=1))ObjectSetText("text_42",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_D1-(delta_GBPCHF_D1)),2),2),10,TextFONT,col_14);
         if((event_21_21!=1||event_22_22!=1||OrdersTotal()<1))ObjectSetText("text_42",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_D1-(delta_GBPCHF_D1)),2),2),10,TextFONT,col_5);       
//-------------------------------------------------------------------------------------------
         if(event_21_21==1)ObjectSetText("text_43",(DoubleToStr(NormalizeDouble(MarketInfo("AUDCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_21_21!=1)ObjectSetText("text_43",(DoubleToStr(NormalizeDouble(MarketInfo("AUDCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_22_22==1)ObjectSetText("text_44",(DoubleToStr(NormalizeDouble(MarketInfo("GBPCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_22_22!=1)ObjectSetText("text_44",(DoubleToStr(NormalizeDouble(MarketInfo("GBPCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_24_1==1&&event_24_1_s==0)ObjectSetText("text_45"," NZDUSD",10,TextFONT,col_14);
         if(event_24_1_s==1&&event_24_1==0)ObjectSetText("text_45"," NZDUSD",10,TextFONT,col_9);
         if(event_24_1==0&&event_24_1_s==0)ObjectSetText("text_45"," NZDUSD",10,TextFONT,col_5);
         if(event_24_1==1&&event_24_1_s==1)ObjectSetText("text_45"," NZDUSD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------
         if(event_25_1==1&&event_25_1_s==0)ObjectSetText("text_46","        NZDCAD",10,TextFONT,col_14);
         if(event_25_1_s==1&&event_25_1==0)ObjectSetText("text_46","        NZDCAD",10,TextFONT,col_9);
         if(event_25_1==0&&event_25_1_s==0)ObjectSetText("text_46","        NZDCAD",10,TextFONT,col_5);
         if(event_25_1==1&&event_25_1_s==1)ObjectSetText("text_46","        NZDCAD",10,TextFONT,White);
//-------------------------------------------------------------------------------------------                
         bool isFirstInterval_47=(t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 60);
         double delta_47=isFirstInterval_47 ? delta_NZDUSD_D1 : delta_NZDUSD_MN1;
         color textColor_47=(event_24_24_1==1) ? col_14 : col_5;
         ObjectSetText("text_47", DoubleToStr(NormalizeDouble(MathAbs(delta_47), 2), 2), 10, TextFONT, textColor_47);
//------------------------------------------------------------------------------------------- 
         bool isFirstInterval_48=(t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 60);
         double delta_48=isFirstInterval_48 ? delta_NZDCAD_D1 : delta_NZDCAD_MN1;
         color textColor_48=(event_25_25_1==1) ? col_14 : col_5;
         ObjectSetText("text_48", DoubleToStr(NormalizeDouble(MathAbs(delta_48), 2), 2), 10, TextFONT, textColor_48);
//-------------------------------------------------------------------------------------------                     
         if((event_24_24_1==1||event_25_25_1==1)&&(OrdersTotal()>=1))ObjectSetText("text_49",DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_D1-(delta_NZDCAD_D1)),2),2),10,TextFONT,col_14);
         if((event_24_24_1!=1||event_25_25_1!=1||OrdersTotal()<1))ObjectSetText("text_49",DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_D1-(delta_NZDCAD_D1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_24_24_1==1)ObjectSetText("text_50",(DoubleToStr(NormalizeDouble(MarketInfo("NZDUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_24_24_1!=1)ObjectSetText("text_50",(DoubleToStr(NormalizeDouble(MarketInfo("NZDUSD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_25_25_1==1)ObjectSetText("text_51",(DoubleToStr(NormalizeDouble(MarketInfo("NZDCAD",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_25_25_1!=1)ObjectSetText("text_51",(DoubleToStr(NormalizeDouble(MarketInfo("NZDCAD",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         color textColor_52=col_5;  // Цвет по умолчанию
         if(event_27_1==1&&event_27_1_s==0) textColor_52=col_14;
         if(event_27_1_s==1&&event_27_1==0) textColor_52=col_9;
         if(event_27_1==1&&event_27_1_s==1) textColor_52=White;
         ObjectSetText("text_52", " USDCHF", 10, TextFONT, textColor_52);
//-------------------------------------------------------------------------------------------
         color textColor_53=col_5;  // Цвет по умолчанию
         if(event_28_1==1&&event_28_1_s==0) textColor_53=col_14;
         if(event_28_1_s==1&&event_28_1==0) textColor_53=col_9;
         if(event_28_1==1&&event_28_1_s==1) textColor_53=White;
         ObjectSetText("text_53", "        CADCHF", 10, TextFONT, textColor_53);
//-------------------------------------------------------------------------------------------                   
         bool isFirstInterval_54=(t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 60);
         double delta_54=isFirstInterval_54 ? delta_USDCHF_D1 : delta_USDCHF_MN1;
         color textColor_54=(event_27_27_1==1) ? col_14 : col_5;
         ObjectSetText("text_54", DoubleToStr(NormalizeDouble(MathAbs(delta_54), 2), 2), 10, TextFONT, textColor_54);
//-------------------------------------------------------------------------------------------    
         bool isFirstInterval_55=(t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 60);
         double delta_55=isFirstInterval_55 ? delta_CADCHF_D1 : delta_CADCHF_MN1;
         color textColor_55=(event_28_28_1==1) ? col_14 : col_5;
         ObjectSetText("text_55", DoubleToStr(NormalizeDouble(MathAbs(delta_55), 2), 2), 10, TextFONT, textColor_55);
//-------------------------------------------------------------------------------------------                   
         if((event_27_27_1==1||event_28_28_1==1)&&(OrdersTotal()>=1))ObjectSetText("text_56",DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_D1-(delta_CADCHF_D1)),2),2),10,TextFONT,col_14);
         if((event_27_27_1!=1||event_28_28_1!=1||OrdersTotal()<1))ObjectSetText("text_56",DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_D1-(delta_CADCHF_D1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_27_27_1==1)ObjectSetText("text_57",(DoubleToStr(NormalizeDouble(MarketInfo("USDCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_27_27_1!=1)ObjectSetText("text_57",(DoubleToStr(NormalizeDouble(MarketInfo("USDCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------
         if(event_28_28_1==1)ObjectSetText("text_58",(DoubleToStr(NormalizeDouble(MarketInfo("CADCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_14);
         if(event_28_28_1!=1)ObjectSetText("text_58",(DoubleToStr(NormalizeDouble(MarketInfo("CADCHF",MODE_SPREAD),10000),0)),10,TextFONT,col_5); 
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_59",WindowExpertName(),10,TextFONT,col_9);
//-------------------------------------------------------------------------------------------
         ObjectSetText("text_60", CharToStr(108), 14, "Wingdings", Color_tch_al);
//----------------------------------------------------------------------------------------------
         string profit_text=DoubleToStr(NormalizeDouble(profit_buy_all / (standart ? 1 : 100), 2), 2);
         color profit_color=(profit_buy_all < 0) ? col_9 : (profit_buy_all>0 ? col_14 : col_5);
         ObjectSetText("text_61", profit_text, 10, TextFONT, profit_color);
//------------------------------------------------------------------------------------------- 
         double profit=(standart==false) ? profit_sell_all / 100 : profit_sell_all;
         color textColor_62=(profit < 0) ? col_9 : (profit>0) ? col_14 : col_5;
         ObjectSetText("text_62", DoubleToStr(NormalizeDouble(profit, 2), 2), 10, TextFONT, textColor_62);
//------------------------------------------------------------------------------------------- 
         if(event_0==1)ObjectSetText("text_63"," BUY",10,TextFONT,col_14);
         else if(event_0!=1)ObjectSetText("text_63"," BUY",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_0_s==1)ObjectSetText("text_64"," SELL",10,TextFONT,col_9);
         else if(event_0_s!=1)ObjectSetText("text_64"," SELL",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_0==1)ObjectSetText("text_65",DoubleToStr(NormalizeDouble (CountBuy_1(),2),0),10,TextFONT,col_14);
         else if(event_0!=1)ObjectSetText("text_65",DoubleToStr(NormalizeDouble (CountBuy_1(),2),0),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_0_s==1)ObjectSetText("text_66",DoubleToStr(NormalizeDouble (CountSell_1(),2),0),10,TextFONT,col_9);
         else if(event_0_s!=1)ObjectSetText("text_66",DoubleToStr(NormalizeDouble (CountSell_1(),2),0),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_1==1)ObjectSetText("text_67"," Баланс",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_67"," Баланс",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_1==1)ObjectSetText("text_68"," Эквити",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_68"," Эквити",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
         if(trr>=0){
         if(event_1==1)ObjectSetText("text_69"," Тек.прибыль",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_69"," Тек.прибыль",10,TextFONT,col_5);}
         if(trr<0){
         if(event_1==1)ObjectSetText("text_69"," Тек.убыток",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_69"," Тек.убыток",10,TextFONT,col_5);}}        
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){ 
         if(event_1==1)ObjectSetText("text_69"," Тек.комиссия",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_69"," Тек.комиссия",10,TextFONT,col_5);}              
//------------------------------------------------------------------------------------------- 
         double balance=AccountBalance()+bonus;
         balance=(standart==false) ? balance / 100 : balance;
         color textColor_70=(event_1==1) ? col_14 : col_5;
         ObjectSetText("text_70", DoubleToStr(NormalizeDouble(balance, 2), 2), 10, TextFONT, textColor_70);
//------------------------------------------------------------------------------------------- 
         double equity=AccountEquity();
         double equityValue=(standart==false) ? equity / 100 : equity;
         color textColor_71=(event_1==0) ? col_5 : (equity>=AccountBalance()+bonus ? col_14 : col_9);
         ObjectSetText("text_71", DoubleToStr(NormalizeDouble(equityValue, 2), 2), 10, TextFONT, textColor_71);
//------------------------------------------------------------------------------------------- 
         if((t1_sec>=0&&t1_sec < 10) || (t1_sec>=20&&t1_sec < 30) || (t1_sec>=40&&t1_sec < 50)){
         double total_72=CalculateOpenSwaps()+CalculateOpenComiss();
         string value_72=DoubleToStr(NormalizeDouble(standart ? total_72 : total_72 / 100, 2), 2);
         color textColor_72=(total_72>0) ? col_14 : (total_72 < 0) ? col_9 : col_5;
         ObjectSetText("text_72", value_72, 10, TextFONT, textColor_72);}

         if((t1_sec>=10&&t1_sec < 20) || (t1_sec>=30&&t1_sec < 40) || (t1_sec>=50&&t1_sec < 00)){
         double equityDiff_72=AccountEquity()-HelpAccount;
         string value_72=DoubleToString(standart ? equityDiff_72 : equityDiff_72 / 100, 2);
         color textColor_72=(event_1==1) ? (equityDiff_72>=0 ? col_14 : col_9) : col_5;
         ObjectSetText("text_72", value_72, 10, TextFONT, textColor_72);}
//-------------------------------------------------------------------------------------------   
         if((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00)){
         if(event_1==1&&trr>=0)ObjectSetText("text_73",(""+DoubleToString((trr),2)),10,TextFONT,col_14);
         if(event_1==1&&trr<0)ObjectSetText("text_73",(""+DoubleToString((trr),2)),10,TextFONT,col_9);
         if(event_1==0)ObjectSetText("text_73",""+DoubleToString((trr),2),10,TextFONT,col_5);} 
         if((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50)){
         ObjectSetText("text_73",(""+DoubleToString((trr),1)),10,TextFONT,Black);}      
//------------------------------------------------------------------------------------------- 
         if(event_36==1)ObjectSetText("text_74"," Трал динам.",10,TextFONT,col_14);
         if(event_1==1||event_36!=1)ObjectSetText("text_74"," Трал динам.",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_1==1)ObjectSetText("text_75"," Закрываю",10,TextFONT,col_14);
         else if(event_1==0)ObjectSetText("text_75"," Закрываю",10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------              
         double value_76=HelpAccount+c28;
         double result_76=(standart==false) ? value_76 / 100 : value_76;
         color textColor_76=(event_1==1) ? col_14 : col_5;
         ObjectSetText("text_76", DoubleToStr(NormalizeDouble(result_76, 2), 2), 10, TextFONT, textColor_76);
         if(event_1==0)ObjectSetText("text_76", DoubleToStr(NormalizeDouble(result_76, 2), 2), 10, TextFONT, textColor_76);
//------------------------------------------------------------------------------------------- 
         double value_77=(HelpAccount+c28)-AccountEquity();
         double result_77=(standart==false) ? value_77 / 100 : value_77;
         color textColor_77=(event_1==1) ? col_14 : col_5;
         ObjectSetText("text_77", DoubleToStr(NormalizeDouble(result_77, 2), 2), 10, TextFONT, textColor_77);
         if(event_1==0){ObjectSetText("text_77", DoubleToStr(NormalizeDouble(0, 2), 2), 10, TextFONT, col_5);}
//-------------------------------------------------------------------------------------------      
         double result_78=HelpAccount+c1;
         if(standart==false) result_78 /= 100;  // делим на 100, если standart==false
         color textColor_78=(event_1==1) ? col_14 : col_5;
         ObjectSetText("text_78", DoubleToStr(NormalizeDouble(result_78, 2), 2), 10, TextFONT, textColor_78);
         if(event_1==0){ObjectSetText("text_78", DoubleToStr(NormalizeDouble(0, 2), 2), 10, TextFONT, col_5);}
//-------------------------------------------------------------------------------------------       
         double result_79=HelpAccount_down+c2;
         if(standart==false) result_79 /= 100;  // делим на 100, если standart==false
         color textColor_79=(event_1==1) ? col_14 : col_5;
         ObjectSetText("text_79", DoubleToStr(NormalizeDouble(result_79, 2), 2), 10, TextFONT, textColor_79);
         if(event_1==0){ObjectSetText("text_79", DoubleToStr(NormalizeDouble(0, 2), 2), 10, TextFONT, col_5);}
//------------------------------------------------------------------------------------------- 
         double result_80=HelpAccount+c1-AccountEquity();
         if(standart==false) result_80 /= 100; // если standart==false, делим на 100
         color textColor_80=(event_1==1&&(event_25==1 || event_26==1 || event_27==1 || event_28==1 || event_29==1 || event_30==1 || event_31==1 || event_32==1 || event_33==1)) ? col_14 : col_5;
         if(event_1==0){ObjectSetText("text_80", DoubleToStr(NormalizeDouble(0, 2), 2), 10, TextFONT, col_5);} else {
         ObjectSetText("text_80", DoubleToStr(NormalizeDouble(result_80, 2), 2), 10, TextFONT, textColor_80);}
//------------------------------------------------------------------------------------------- 
         if(event_34==1)ObjectSetText("text_81"," Трал эквити",10,TextFONT,col_14);
         if(event_1==1||event_34!=1)ObjectSetText("text_81"," Трал эквити",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(event_35==1)ObjectSetText("text_82"," Закр.профит",10,TextFONT,col_14);
         if(event_1==1||event_35!=1)ObjectSetText("text_82"," Закр.профит",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_83",DoubleToStr(NormalizeDouble (totalVolume,2),2),10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_83",DoubleToStr(NormalizeDouble (totalVolume,2),2),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_84",DoubleToStr(NormalizeDouble (count_close,0),0),10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_84",DoubleToStr(NormalizeDouble (count_close,0),0),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_85"," На спреде",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_85"," На спреде",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_86"," Сегодня",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_86"," Сегодня",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_87"," Вчера",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_87"," Вчера",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_88"," Месяц",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_88"," Месяц",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_89","День   ~0.25%",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_89","День   ~0.25%",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_90","Месяц  ~5.0%",10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_90","Месяц  ~5.0%",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1&&r0>=0.25)ObjectSetText("text_91"," Выполнен",10,TextFONT,col_14);
         if(count_close>=1&&r0<0.25)ObjectSetText("text_91"," Не выполнен",10,TextFONT,col_9);
         if(count_close<1&&r0>=0.25)ObjectSetText("text_91"," Выполнен",10,TextFONT,col_5);
         if(count_close<1&&r0<0.25)ObjectSetText("text_91"," Не выполнен",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1&&((AccountEquity()-Equity_mn1)/(Equity_mn1/100))>=5)ObjectSetText("text_92"," Выполнен",10,TextFONT,col_14);
         if(count_close>=1&&((AccountEquity()-Equity_mn1)/(Equity_mn1/100))<5)ObjectSetText("text_92"," Не выполнен",10,TextFONT,col_9);
         if(count_close<1&&((AccountEquity()-Equity_mn1)/(Equity_mn1/100))>=5)ObjectSetText("text_92"," Выполнен",10,TextFONT,col_5);
         if(count_close<1&&((AccountEquity()-Equity_mn1)/(Equity_mn1/100))<5)ObjectSetText("text_92"," Не выполнен",10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1)ObjectSetText("text_93",DoubleToStr(NormalizeDouble(totalVolume*spred_1,3),2),10,TextFONT,col_14);
         if(count_close<1)ObjectSetText("text_93",DoubleToStr(NormalizeDouble(totalVolume*spred_1,3),2),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         string value_94=DoubleToString(standart ? p0 : p0 / 100, 2);
         color textColor_94=(count_close>=1) ? (p0>=0 ? col_14 : col_9) : col_5;
         ObjectSetText("text_94", value_94, 10, TextFONT, textColor_94);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1&&p0>=0)ObjectSetText("text_95",(""+DoubleToString((r0),2)),10,TextFONT,col_14);
         if(count_close>=1&&p0<0)ObjectSetText("text_95",(""+DoubleToString((r0),2)),10,TextFONT,col_9);
         if(count_close<1)ObjectSetText("text_95",""+DoubleToString((r0),2),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         string value_96=DoubleToString(standart ? p1 : p1 / 100, 2);
         color textColor_96=(count_close>=1) ? (p0>=0 ? col_14 : col_9) : col_5;
         ObjectSetText("text_96", value_96, 10, TextFONT, textColor_96);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1&&p0>=0)ObjectSetText("text_97",(""+DoubleToString((r1),2)),10,TextFONT,col_14);
         if(count_close>=1&&p0<0)ObjectSetText("text_97",(""+DoubleToString((r1),2)),10,TextFONT,col_9);
         if(count_close<1)ObjectSetText("text_97",""+DoubleToString((r1),2),10,TextFONT,col_5);
//------------------------------------------------------------------------------------------- 
         double equityDiff_98=AccountEquity()-Equity_mn1;
         string value_98=DoubleToString(standart ? equityDiff_98 : equityDiff_98 / 100, 2);
         color textColor_98=(count_close>=1) ? (p0>=0 ? col_14 : col_9) : col_5;
         ObjectSetText("text_98", value_98, 10, TextFONT, textColor_98);
//------------------------------------------------------------------------------------------- 
         if(count_close>=1&&p0>=0)ObjectSetText("text_99",(""+DoubleToString(((AccountEquity()-Equity_mn1)/(Equity_mn1/100)),2)),10,TextFONT,col_14);
         if(count_close>=1&&p0<0)ObjectSetText("text_99",(""+DoubleToString(((AccountEquity()-Equity_mn1)/(Equity_mn1/100)),2)),10,TextFONT,col_9);
         if(count_close<1)ObjectSetText("text_99",""+DoubleToString(((AccountEquity()-Equity_mn1)/(Equity_mn1/100)),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------         
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){ 
         ObjectSetText("text_100",TimeToStr(TimeCurrent(),TIME_DATE),10,TextFONT,col_14);} 
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
         if((Hour()>=00&&Hour() < 15)||(Hour()>=18&&Hour() < 23))ObjectSetText("text_100",TimeToStr(TimeCurrent(),TIME_SECONDS),10,TextFONT,col_14);
         if(Hour()>=15&&Hour() < 18)ObjectSetText("text_100",TimeToStr(TimeCurrent(),TIME_SECONDS),10,TextFONT,DarkOrange);}   
//-------------------------------------------------------------------------------------------   
         if(event_3_3==1||event_4_4==1)ObjectSetText("text_101",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_MN1-(delta_GBPUSD_MN1)),2),2),10,TextFONT,col_14);
         if(event_3_3!=1||event_4_4!=1)ObjectSetText("text_101",DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_MN1-(delta_GBPUSD_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         if(event_6_6==1||event_7_7==1)ObjectSetText("text_102",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_MN1-(delta_AUDUSD_MN1)),2),2),10,TextFONT,col_14);
         if(event_6_6!=1||event_7_7!=1)ObjectSetText("text_102",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_MN1-(delta_AUDUSD_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------   
         if(event_12_12==1||event_13_13==1)ObjectSetText("text_103",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_MN1-(delta_GBPAUD_MN1)),2),2),10,TextFONT,col_14);
         if(event_12_12!=1||event_13_13!=1)ObjectSetText("text_103",DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_MN1-(delta_GBPAUD_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         if(event_21_21==1||event_22_22==1)ObjectSetText("text_104",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_MN1-(delta_GBPCHF_MN1)),2),2),10,TextFONT,col_14);
         if(event_21_21!=1||event_22_22!=1)ObjectSetText("text_104",DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_MN1-(delta_GBPCHF_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         if(event_24_24_1==1||event_25_25_1==1)ObjectSetText("text_105",DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_MN1-(delta_NZDCAD_MN1)),2),2),10,TextFONT,col_14);
         if(event_24_24_1!=1||event_25_25_1!=1)ObjectSetText("text_105",DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_MN1-(delta_NZDCAD_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         if(event_27_27_1==1||event_28_28_1==1)ObjectSetText("text_106",DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_MN1-(delta_CADCHF_MN1)),2),2),10,TextFONT,col_14);
         if(event_27_27_1!=1||event_28_28_1!=1)ObjectSetText("text_106",DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_MN1-(delta_CADCHF_MN1)),2),2),10,TextFONT,col_5);
//-------------------------------------------------------------------------------------------  
         if(OrdersTotal() < 1) {
         flag_6 = 0;
         }
         
         if(AccountEquity() >= (HelpAccount + c2)&&HelpAccount!=0&&c2!=0) {
         flag_6 = 1;
         }

         if(tral_equity_dinamic==true){
         if((CountBuy_1()+CountSell_1())<=0)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(0,2),2),10,TextFONT,col_5);
         if((CountBuy_1()+CountSell_1())>0){
       
         if(standart==true)if(flag_6 == 1)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity()),2),2)+"/"+DoubleToStr(NormalizeDouble(((AccountEquity()-HelpAccount777_down)),2),2),10,TextFONT,col_3);
         if(standart==true)if(flag_6 == 0)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity()),2),2),10,TextFONT,White);
         
         if(standart==true)if(HelpAccount777_down==0)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity()),2),2)+"/"+DoubleToStr(NormalizeDouble(0,2),2),10,TextFONT,col_14);

         if(standart==false)if(flag_6 == 1)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity())/100,2),2)+"/"+DoubleToStr(NormalizeDouble(((AccountEquity()-HelpAccount777_down))/100,2),2),10,TextFONT,col_3);
         if(standart==false)if(flag_6 == 0)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity())/100,2),2),10,TextFONT,White);
         
         if(standart==false)if(HelpAccount777_down==0)ObjectSetText("text_107",DoubleToStr(NormalizeDouble(((HelpAccount_down+(c2))-AccountEquity())/100,2),2)+"/"+DoubleToStr(NormalizeDouble(0,2),2),10,TextFONT,col_14);}}
         }
//-----------------------конец пишем тест----------------------------------------------------


//-----------------------сообщения в панель--------------------------------------------------
         if(alert_1 != alert_0){alert_7=alert_6; alert_6=alert_5; alert_5=alert_4; alert_4=alert_3; alert_3=alert_2; alert_2=alert_1; alert_1=alert_0;}
//-----------------------вывожу в панель входы в рынок-----------------------------------------
         double oldlots;int oldticket;int ticket=0;
         for(int i=OrdersTotal()-1; i>=0; i--){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){oldticket=OrderTicket();
         if(oldticket>ticket){oldlots= OrderLots();ticket=oldticket;
         int total1=OrdersTotal();
         if(total1>0){
         if(OrderSelect(total1-1, SELECT_BY_POS, MODE_TRADES)){
         datetime prevOpenTime=OrderOpenTime();
         datetime currOpenTime=TimeCurrent(); 
         if(OrdersTotal()==1&&(currOpenTime-2<= prevOpenTime)){
         if(OrderType()==OP_SELL&&oldlots!=OrderOpenPrice()) alert_0=StringConcatenate("Найдена,Sell:",(OrderSymbol()),",объем:",(DoubleToStr(NormalizeDouble(OrderLots(),2),2))); //
         if(OrderType()==OP_BUY&&oldlots!=OrderOpenPrice()) alert_0=StringConcatenate("Найдена,Buy:",(OrderSymbol()),",объем:",(DoubleToStr(NormalizeDouble(OrderLots(),2),2)));}
         if(OrdersTotal()>1&&(currOpenTime-2<= prevOpenTime)){
         if(OrderType()==OP_SELL&&oldlots!=OrderOpenPrice()) alert_0=StringConcatenate("Sell:",(OrderSymbol()),",объем:",(DoubleToStr(NormalizeDouble(OrderLots(),2),2)));
         if(OrderType()==OP_BUY&&oldlots!=OrderOpenPrice()) alert_0=StringConcatenate("Buy:",(OrderSymbol()),",объем:",(DoubleToStr(NormalizeDouble(OrderLots(),2),2)));}}}}}}

         for(int i=1; i<= 7; i++){string objectName="alert_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectSet(objectName,OBJPROP_CORNER,0);ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName, OBJPROP_XDISTANCE,30);}
//-------------------------------------------------------------------------------------------               
         ObjectSetText("alert_1",alert_1,10,TextFONT,Color_tch_al);ObjectSet("alert_1",OBJPROP_YDISTANCE,455); 
         ObjectSetText("alert_2",alert_2,10,TextFONT,(C'255,236,128'));ObjectSet("alert_2",OBJPROP_YDISTANCE,470); 
         ObjectSetText("alert_3",alert_3,10,TextFONT,(C'255,230,85'));ObjectSet("alert_3",OBJPROP_YDISTANCE,485); 
         ObjectSetText("alert_4",alert_4,10,TextFONT,(C'255,223,43'));ObjectSet("alert_4",OBJPROP_YDISTANCE,500); 
         ObjectSetText("alert_5",alert_5,10,TextFONT,(C'255,217,0'));ObjectSet("alert_5",OBJPROP_YDISTANCE,515); 
         ObjectSetText("alert_6",alert_6,10,TextFONT,(C'213,181,0'));ObjectSet("alert_6",OBJPROP_YDISTANCE,530); 
         ObjectSetText("alert_7",alert_7,10,TextFONT,(C'170,145,0'));ObjectSet("alert_7",OBJPROP_YDISTANCE,545);}
//-----------------------конец сообщения в панель--------------------------------------------




//--------------------вывод индикации просадки-----------------------------------------------
         if(trr>-1||flag_4==1||flag_5==1){
         if(ObjectFind(0,"delta_sym1_sym2_123")!=-1)ObjectDelete(0,"delta_sym1_sym2_123");
         if(ObjectFind(0,"m_bg179_1")!=-1)ObjectDelete(0,"m_bg179_1");
         if(ObjectFind(0,"correlation3_")!=-1)ObjectDelete(0,"correlation3_");

         for (int i=1; i<=66; i++){string correlation3_="correlation3_"+IntegerToString(i);
         if(ObjectFind(0,correlation3_)!=-1)ObjectDelete(correlation3_);}}
         double delta_sym1_sym2_123=MathAbs(trr);
//-----------------------вывод индикатора просадки-------------------------------------------
         if(trr<(-1)&&flag_4==0&&flag_5==0){
         color gradientColors[]={LightGray,NavajoWhite,Orange,OrangeRed,Crimson};
         int gradientSteps=12;//Через сколько объектов менять цвет
         for(int i=2;i<=65;i++){
         string objectName="correlation3_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(objectName,OBJ_LABEL,0,0,0);
         ObjectSet(objectName,OBJPROP_CORNER,0);
         ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");
         ObjectSet(objectName,OBJPROP_XDISTANCE,584);
         ObjectSet(objectName,OBJPROP_YDISTANCE,565-(i-2)*2);}
         //Определяем цвет по градиенту
         int colorIndex=(i-2)/gradientSteps;//Вычисляем индекс цвета
         colorIndex=(colorIndex<5)?colorIndex:4;//Ограничиваем индексы до 4
         //Вычисляем порог
         double threshold=(i-2)*0.5; 
         //Устанавливаем цвет текста в зависимости от порога
         ObjectSetText(objectName,"______________",10,TextFONT,(delta_sym1_sym2_123>threshold)?gradientColors[colorIndex]:col_5);}
//-----------------------вывод индикатора просадки-------------------------------------------

//-----------------------вывода процентов просадки-------------------------------------------
         ObjectCreate("delta_sym1_sym2_123",OBJ_LABEL,0,0,0);ObjectSetString(0,"delta_sym1_sym2_123",OBJPROP_TOOLTIP,"\n");
         for(int i=0;i<OrdersTotal();i++){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         //Расчёт YDISTANCE (каждое значение снижает на 2, а затем на 20)
         int yBase=567;int yOffset=(int)(delta_sym1_sym2_123/0.5)*2;
         if(delta_sym1_sym2_123<=26)ObjectSet("delta_sym1_sym2_123",OBJPROP_YDISTANCE,yBase-yOffset-20);
         if(delta_sym1_sym2_123>26)ObjectSet("delta_sym1_sym2_123",OBJPROP_YDISTANCE,450);
         //Устанавливаем угол
         ObjectSet("delta_sym1_sym2_123",OBJPROP_CORNER,0);
         //Определяем XDISTANCE
         int xDistance=(delta_sym1_sym2_123>40)?592:(delta_sym1_sym2_123>=9.9?594:604);
         ObjectSet("delta_sym1_sym2_123",OBJPROP_XDISTANCE,xDistance);
         //Форматирование текста
         string displayText;color textColor=col_17;
         if(delta_sym1_sym2_123>40){
         if((t1_sec%20)<10){displayText="ALARM";textColor=Black;}else{
         displayText="-"+DoubleToStr(NormalizeDouble(delta_sym1_sym2_123,2),1)+"%";}}else{
         displayText="-"+DoubleToStr(NormalizeDouble(delta_sym1_sym2_123,2),1)+"%";}
         ObjectSetText("delta_sym1_sym2_123",displayText,18,"Arial Black",textColor);}}}
//--------------------конец вывода процентов просадки----------------------------------------
//--------------------конец вывод индикации просадки-----------------------------------------
      
//--------------------вывод точек на график--------------------------------------------------
         for(int i=1;i<=80;i++){
         string point_="point_"+IntegerToString(i);
         if(ObjectFind(0,point_)==-1){
         ObjectSetInteger(0,point_,OBJPROP_BACK,false);
         ObjectCreate(point_,OBJ_LABEL,0,0,0);
         ObjectSetString(0,point_,OBJPROP_TOOLTIP,"\n");
         ObjectSet(point_,OBJPROP_CORNER,CORNER);}
         //Вычисляем Y координаты
         int y_distance=0;
         if(i>=1&&i<=10)y_distance=650;
         else if(i>=11&&i<=20)y_distance=662;
         else if(i>=21&&i<=30)y_distance=674;
         else if(i>=31&&i<=40)y_distance=686;
         else if(i>=41&&i<=50)y_distance=232;
         else if(i>=51&&i<=60)y_distance=222;
         else if(i>=61&&i<=70)y_distance=290;
         else if(i>=71&&i<=80)y_distance=300;
         ObjectSet(point_,OBJPROP_YDISTANCE,y_distance);
         //Вычисляем X координаты
         int x_distance=30+((i-1)%10)*10;
         if(i>=41){x_distance=590+((i-41)%10)*10;}
         ObjectSet(point_,OBJPROP_XDISTANCE,x_distance);
         //Определение цвета и текста для точек
         int point_color=col_5;//Цвет по умолчанию
         //Для точек с 1 по 40-зависимость от count_close
         if(i<=40){
         if(count_close>=i){point_color=col_14;}}
         //Для точек с 41 по 60-зависимость от CountBuy_1()
         else if(i>=41&&i<=60){
         if(CountBuy_1()>=(i-40)){point_color=col_14;}
         if(CountBuy_1()==1&&i==41){point_color=col_14;}
         else if(CountBuy_1()==1&&i>41){point_color=col_5;}}
         //Для точек с 61по80-зависимость от CountSell_1()
         else if(i>=61&&i<=80){
         if(CountSell_1()>=(i-60)){point_color=col_9;}
         if(CountSell_1()==1&&i==61){point_color=col_9;}
         else if(CountSell_1()==1&&i>61){point_color=col_5;}}
         //Дополнительные условия для точек 60 и 80
         if(CountBuy_1()>20&&i==60){point_color=Color_tch_al;}
         if(CountSell_1()>20&&i==80){point_color=Color_tch_al;}
         //Установка текста для точек
         if(i<=40){ObjectSetText(point_,CharToStr(159),15,"Wingdings",point_color);//Точки с 1 по 40
         }else if(i>=41&&i<=60){ObjectSetText(point_,CharToStr(110),10,"Wingdings",point_color);//Точки с 41 по 60
         }else{ObjectSetText(point_,CharToStr(110),10,"Wingdings",point_color);}
         //Применяем основной цвет
         ObjectSetInteger(0,point_,OBJPROP_COLOR,point_color);}
//--------------------конец вывод точек на график--------------------------------------------

//--------------------вывод скана стратегий пар----------------------------------------------
/*
         if(OrdersTotal()<1){
         for(int i=1;i<=6;i++){
         string pnt_="pnt_"+IntegerToString(i);
         //Проверяем,существует ли объект
         if(ObjectFind(0,pnt_)==-1){
         ObjectCreate(0,pnt_,OBJ_LABEL,0,0,0);//Создаём объект
         ObjectSetInteger(0,pnt_,OBJPROP_BACK,false);
         ObjectSetString(0,pnt_,OBJPROP_TOOLTIP,"\n");
         ObjectSetInteger(0,pnt_,OBJPROP_CORNER,CORNER);}
         //X-координата(фиксированная)
         ObjectSetInteger(0,pnt_,OBJPROP_XDISTANCE,145);
         //Y-координата(вычисляемая)
         int yDist=211+(i-1)*20;//211,231,251,271,...
         ObjectSetInteger(0,pnt_,OBJPROP_YDISTANCE,yDist);
         ObjectSetText(pnt_,CharToStr(110),10,"Wingdings",Color_tch_ac);}}else{
         for(int i=1;i<=6;i++){
         string pnt_="pnt_"+IntegerToString(i);
         if(ObjectFind(0,pnt_)!=-1){
         ObjectDelete(0,pnt_);}}}
         */

         if(OrdersTotal()<1){
         for(int i=1;i<=6;i++){
         string pnt_="pnt_"+IntegerToString(i);
         if(ObjectFind(0,pnt_)==-1){
         ObjectCreate(0,pnt_,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,pnt_,OBJPROP_BACK,false);
         ObjectSetString(0,pnt_,OBJPROP_TOOLTIP,"\n");
         ObjectSetInteger(0,pnt_,OBJPROP_CORNER,CORNER);}
         ObjectSetInteger(0,pnt_,OBJPROP_XDISTANCE,145);
         int yDist=211+(i-1)*20;
         ObjectSetInteger(0,pnt_,OBJPROP_YDISTANCE,yDist);}
         //Обновляем каждые 2 секунды
         if(TimeCurrent()-lastSwitchTime>=2){
         lastSwitchTime=TimeCurrent();
         //Определяем цвета для всех точек
         for(int i=1;i<=6;i++){
         string pnt_="pnt_"+IntegerToString(i);
         color clr=clrDimGray;
         if(i==activePoint){
         clr=clrWhite;
         }else if(i==(activePoint==1?6:activePoint-1)){
         clr=clrDarkGray;}
         ObjectSetText(pnt_,CharToStr(110),10,"Wingdings",clr);}
         activePoint++;
         if(activePoint>6)activePoint=1;}
         }else{
         for(int i=1;i<=6;i++){
         string pnt_="pnt_"+IntegerToString(i);
         if(ObjectFind(0,pnt_)!=-1){
         ObjectDelete(0,pnt_);}}}
//---------------------конец вывод скана стратегий пар---------------------------------------

//---------------------вывод кол-ва дней на графике------------------------------------------
        string day_i="day_i";
        if(ObjectFind(0,day_i)==-1){
        ObjectCreate(day_i,OBJ_LABEL,0,0,0);ObjectSetString(0,day_i,OBJPROP_TOOLTIP,"\n");ObjectSet(day_i,OBJPROP_CORNER, CORNER);}
        if(daysSinceFirstEntry>=0)ObjectSet(day_i,OBJPROP_XDISTANCE,730);ObjectSet(day_i,OBJPROP_YDISTANCE,90);
        if(event_1==0)ObjectSetText(day_i,DoubleToStr(NormalizeDouble(daysSinceFirstEntry,0),0),10,TextFONT,col_5);      
        if(event_1==1)ObjectSetText(day_i,DoubleToStr(NormalizeDouble(daysSinceFirstEntry,0),0),10,TextFONT,col_14);
//---------------------конец вывод кол-ва дней на графике------------------------------------

//--------------------вывод точек подсказок MN1 на график------------------------------------ 
         // Массивы с данными для точек
         string objectNames[]={"point_MN_1", "point_MN_2", "point_MN_3", "point_MN_4", "point_MN_5", "point_MN_6"};
         color colors[]={Black, Lime, Yellow, DarkOrange, Red};
         // Создание объектов точек
         for (int i=0; i < 6; i++){
         string objectName=objectNames[i];
         if(ObjectFind(0, objectName)==-1){
         ObjectSetInteger(0, objectName, OBJPROP_BACK, false);
         ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(0, objectName, OBJPROP_TOOLTIP, "\n");
         ObjectSet(objectName, OBJPROP_CORNER, CORNER);
         ObjectSet(objectName, OBJPROP_XDISTANCE, 398);
         ObjectSet(objectName, OBJPROP_YDISTANCE, 210+(i * 20));}
         // Определение пороговых значений для каждого расчета
         double deltaDiff=0;
         double strong1=0, strong2=0, strong3=0, strong4=0;
         // Устанавливаем пороги для каждого случая
         switch (i){
        case 0:
            deltaDiff=MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1);
            strong1=delta_EURUSD_GBPUSD_MN1_strong1;
            strong2=delta_EURUSD_GBPUSD_MN1_strong2;
            strong3=delta_EURUSD_GBPUSD_MN1_strong3;
            strong4=delta_EURUSD_GBPUSD_MN1_strong4;
            break;
        case 1:
            deltaDiff=MathAbs(delta_AUDCAD_MN1-delta_AUDUSD_MN1);
            strong1=delta_AUDCAD_AUDUSD_MN1_strong1;
            strong2=delta_AUDCAD_AUDUSD_MN1_strong2;
            strong3=delta_AUDCAD_AUDUSD_MN1_strong3;
            strong4=delta_AUDCAD_AUDUSD_MN1_strong4;
            break;
        case 2:
            deltaDiff=MathAbs(delta_EURAUD_MN1-delta_GBPAUD_MN1);
            strong1=delta_EURAUD_GBPAUD_MN1_strong1;
            strong2=delta_EURAUD_GBPAUD_MN1_strong2;
            strong3=delta_EURAUD_GBPAUD_MN1_strong3;
            strong4=delta_EURAUD_GBPAUD_MN1_strong4;
            break;
        case 3:
            deltaDiff=MathAbs(delta_AUDCHF_MN1-delta_GBPCHF_MN1);
            strong1=delta_AUDCHF_GBPCHF_MN1_strong1;
            strong2=delta_AUDCHF_GBPCHF_MN1_strong2;
            strong3=delta_AUDCHF_GBPCHF_MN1_strong3;
            strong4=delta_AUDCHF_GBPCHF_MN1_strong4;
            break;
        case 4:
            deltaDiff=MathAbs(delta_NZDUSD_MN1-delta_NZDCAD_MN1);
            strong1=delta_NZDUSD_NZDCAD_MN1_strong1;
            strong2=delta_NZDUSD_NZDCAD_MN1_strong2;
            strong3=delta_NZDUSD_NZDCAD_MN1_strong3;
            strong4=delta_NZDUSD_NZDCAD_MN1_strong4;
            break;
        case 5:
            deltaDiff=MathAbs(delta_USDCHF_MN1-delta_CADCHF_MN1);
            strong1=delta_USDCHF_CADCHF_MN1_strong1;
            strong2=delta_USDCHF_CADCHF_MN1_strong2;
            strong3=delta_USDCHF_CADCHF_MN1_strong3;
            strong4=delta_USDCHF_CADCHF_MN1_strong4;
            break;}
         // Применение условий и установка текста
         if(deltaDiff<=strong1){
         ObjectSetText(objectName, "D0",10,TextFONT,colors[0]);}else if(deltaDiff<=strong2){
         ObjectSetText(objectName, "D1",10,TextFONT,colors[1]);}else if(deltaDiff<=strong3){
         ObjectSetText(objectName, "D2",10,TextFONT,colors[2]);}else if(deltaDiff<=strong4){
         ObjectSetText(objectName, "D3",10,TextFONT,colors[3]);}else {
         ObjectSetText(objectName, "D4",10,TextFONT,colors[4]);}}
//--------------------конец вывод точек подсказок MN1 на график------------------------------



//--------------------вывод больше-меньше выводим на график----------------------------------
         for(int i=1; i<= 6; i++){string objectName="point_up_dw_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate (objectName,OBJ_LABEL,0,0,0);ObjectSetInteger(0,objectName,OBJPROP_BACK,false);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName,OBJPROP_CORNER,CORNER);
         ObjectSet(objectName,OBJPROP_XDISTANCE,208);
         ObjectSet("point_up_dw_1",OBJPROP_YDISTANCE,210);
         ObjectSet("point_up_dw_2",OBJPROP_YDISTANCE,230);
         ObjectSet("point_up_dw_3",OBJPROP_YDISTANCE,250);
         ObjectSet("point_up_dw_4",OBJPROP_YDISTANCE,270);
         ObjectSet("point_up_dw_5",OBJPROP_YDISTANCE,290);
         ObjectSet("point_up_dw_6",OBJPROP_YDISTANCE,310);}        
//--------------------вывод больше-меньше D1 на график--------------------------------------
         if(((t1_sec>=10&&t1_sec<20)||(t1_sec>=30&&t1_sec<40)||(t1_sec>=50&&t1_sec<00))){
    
         if(event_3_3==1||event_4_4==1){
         if(delta_EURUSD_D1>delta_GBPUSD_D1)ObjectSetText("point_up_dw_1",">",10,TextFONT,col_14);
         if(delta_EURUSD_D1<delta_GBPUSD_D1)ObjectSetText("point_up_dw_1","<",10,TextFONT,col_14);
         if(delta_EURUSD_D1==delta_GBPUSD_D1)ObjectSetText("point_up_dw_1","=",10,TextFONT,col_17);}
         if(event_3_3!=1||event_4_4!=1){
         if(delta_EURUSD_D1>delta_GBPUSD_D1)ObjectSetText("point_up_dw_1",">",10,TextFONT,col_5);
         if(delta_EURUSD_D1<delta_GBPUSD_D1)ObjectSetText("point_up_dw_1","<",10,TextFONT,col_5);
         if(delta_EURUSD_D1==delta_GBPUSD_D1)ObjectSetText("point_up_dw_1","=",10,TextFONT,col_17);}
                 
         if(event_6_6==1||event_7_7==1){
         if(delta_AUDCAD_D1>delta_AUDUSD_D1)ObjectSetText("point_up_dw_2",">",10,TextFONT,col_14);
         if(delta_AUDCAD_D1<delta_AUDUSD_D1)ObjectSetText("point_up_dw_2","<",10,TextFONT,col_14);
         if(delta_AUDCAD_D1==delta_AUDUSD_D1)ObjectSetText("point_up_dw_2","=",10,TextFONT,col_17);}
         if(event_6_6!=1||event_7_7!=1){
         if(delta_AUDCAD_D1>delta_AUDUSD_D1)ObjectSetText("point_up_dw_2",">",10,TextFONT,col_5);
         if(delta_AUDCAD_D1<delta_AUDUSD_D1)ObjectSetText("point_up_dw_2","<",10,TextFONT,col_5);
         if(delta_AUDCAD_D1==delta_AUDUSD_D1)ObjectSetText("point_up_dw_2","=",10,TextFONT,col_17);}
       
         if(event_12_12==1||event_13_13==1){
         if(delta_EURAUD_D1>delta_GBPAUD_D1)ObjectSetText("point_up_dw_3",">",10,TextFONT,col_14);
         if(delta_EURAUD_D1<delta_GBPAUD_D1)ObjectSetText("point_up_dw_3","<",10,TextFONT,col_14);
         if(delta_EURAUD_D1==delta_GBPAUD_D1)ObjectSetText("point_up_dw_3","=",10,TextFONT,col_17);}
         if(event_12_12!=1||event_13_13!=1){
         if(delta_EURAUD_D1>delta_GBPAUD_D1)ObjectSetText("point_up_dw_3",">",10,TextFONT,col_5);
         if(delta_EURAUD_D1<delta_GBPAUD_D1)ObjectSetText("point_up_dw_3","<",10,TextFONT,col_5);
         if(delta_EURAUD_D1==delta_GBPAUD_D1)ObjectSetText("point_up_dw_3","=",10,TextFONT,col_17);}
        
         if(event_21_21==1||event_22_22==1){
         if(delta_AUDCHF_D1>delta_GBPCHF_D1)ObjectSetText("point_up_dw_4",">",10,TextFONT,col_14);
         if(delta_AUDCHF_D1<delta_GBPCHF_D1)ObjectSetText("point_up_dw_4","<",10,TextFONT,col_14);
         if(delta_AUDCHF_D1==delta_GBPCHF_D1)ObjectSetText("point_up_dw_4","=",10,TextFONT,col_17);}
         if(event_21_21!=1||event_22_22!=1){
         if(delta_AUDCHF_D1>delta_GBPCHF_D1)ObjectSetText("point_up_dw_4",">",10,TextFONT,col_5);
         if(delta_AUDCHF_D1<delta_GBPCHF_D1)ObjectSetText("point_up_dw_4","<",10,TextFONT,col_5);
         if(delta_AUDCHF_D1==delta_GBPCHF_D1)ObjectSetText("point_up_dw_4","=",10,TextFONT,col_17);}
                  
         if(event_24_24_1==1||event_25_25_1==1){
         if(delta_NZDUSD_D1>delta_NZDCAD_D1)ObjectSetText("point_up_dw_5",">",10,TextFONT,col_14);
         if(delta_NZDUSD_D1<delta_NZDCAD_D1)ObjectSetText("point_up_dw_5","<",10,TextFONT,col_14);
         if(delta_NZDUSD_D1==delta_NZDCAD_D1)ObjectSetText("point_up_dw_5","=",10,TextFONT,col_17);}
         if(event_24_24_1!=1||event_25_25_1!=1){
         if(delta_NZDUSD_D1>delta_NZDCAD_D1)ObjectSetText("point_up_dw_5",">",10,TextFONT,col_5);
         if(delta_NZDUSD_D1<delta_NZDCAD_D1)ObjectSetText("point_up_dw_5","<",10,TextFONT,col_5);
         if(delta_NZDUSD_D1==delta_NZDCAD_D1)ObjectSetText("point_up_dw_5","=",10,TextFONT,col_17);}
                  
         if(event_27_27_1==1||event_28_28_1==1){
         if(delta_USDCHF_D1>delta_CADCHF_D1)ObjectSetText("point_up_dw_6",">",10,TextFONT,col_14);
         if(delta_USDCHF_D1<delta_CADCHF_D1)ObjectSetText("point_up_dw_6","<",10,TextFONT,col_14);
         if(delta_USDCHF_D1==delta_CADCHF_D1)ObjectSetText("point_up_dw_6","=",10,TextFONT,col_17);}
         if(event_27_27_1!=1||event_28_28_1!=1){
         if(delta_USDCHF_D1>delta_CADCHF_D1)ObjectSetText("point_up_dw_6",">",10,TextFONT,col_5);
         if(delta_USDCHF_D1<delta_CADCHF_D1)ObjectSetText("point_up_dw_6","<",10,TextFONT,col_5);
         if(delta_USDCHF_D1==delta_CADCHF_D1)ObjectSetText("point_up_dw_6","=",10,TextFONT,col_17);}}
//--------------------вывод больше-меньше D1 на график--------------------------------------- 
 
//--------------------вывод больше-меньше MN1 на график--------------------------------------
         if(((t1_sec>=00&&t1_sec<10)||(t1_sec>=20&&t1_sec<30)||(t1_sec>=40&&t1_sec<50))){

         if(event_3_3==1||event_4_4==1){
         if(delta_EURUSD_MN1>delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1",">",10,TextFONT,col_14);
         if(delta_EURUSD_MN1<delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1","<",10,TextFONT,col_14);
         if(delta_EURUSD_MN1==delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1","=",10,TextFONT,col_17);}
         if(event_3_3!=1||event_4_4!=1){
         if(delta_EURUSD_MN1>delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1",">",10,TextFONT,col_5);
         if(delta_EURUSD_MN1<delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1","<",10,TextFONT,col_5);
         if(delta_EURUSD_MN1==delta_GBPUSD_MN1)ObjectSetText("point_up_dw_1","=",10,TextFONT,col_17);}
                   
         if(event_6_6==1||event_7_7==1){
         if(delta_AUDCAD_MN1>delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2",">",10,TextFONT,col_14);
         if(delta_AUDCAD_MN1<delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2","<",10,TextFONT,col_14);
         if(delta_AUDCAD_MN1==delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2","=",10,TextFONT,col_17);}
         if(event_6_6!=1||event_7_7!=1){
         if(delta_AUDCAD_MN1>delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2",">",10,TextFONT,col_5);
         if(delta_AUDCAD_MN1<delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2","<",10,TextFONT,col_5);
         if(delta_AUDCAD_MN1==delta_AUDUSD_MN1)ObjectSetText("point_up_dw_2","=",10,TextFONT,col_17);}

         if(event_12_12==1||event_13_13==1){
         if(delta_EURAUD_MN1>delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3",">",10,TextFONT,col_14);
         if(delta_EURAUD_MN1<delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3","<",10,TextFONT,col_14);
         if(delta_EURAUD_MN1==delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3","=",10,TextFONT,col_17);}
         if(event_12_12!=1||event_13_13!=1){
         if(delta_EURAUD_MN1>delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3",">",10,TextFONT,col_5);
         if(delta_EURAUD_MN1<delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3","<",10,TextFONT,col_5);
         if(delta_EURAUD_MN1==delta_GBPAUD_MN1)ObjectSetText("point_up_dw_3","=",10,TextFONT,col_17);}

         if(event_21_21==1||event_22_22==1){
         if(delta_AUDCHF_MN1>delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4",">",10,TextFONT,col_14);
         if(delta_AUDCHF_MN1<delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4","<",10,TextFONT,col_14);
         if(delta_AUDCHF_MN1==delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4","=",10,TextFONT,col_17);}
         if(event_21_21!=1||event_22_22!=1){
         if(delta_AUDCHF_MN1>delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4",">",10,TextFONT,col_5);
         if(delta_AUDCHF_MN1<delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4","<",10,TextFONT,col_5);
         if(delta_AUDCHF_MN1==delta_GBPCHF_MN1)ObjectSetText("point_up_dw_4","=",10,TextFONT,col_17);}

         if(event_24_24_1==1||event_25_25_1==1){
         if(delta_NZDUSD_MN1>delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5",">",10,TextFONT,col_14);
         if(delta_NZDUSD_MN1<delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5","<",10,TextFONT,col_14);
         if(delta_NZDUSD_MN1==delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5","=",10,TextFONT,col_17);}
         if(event_24_24_1!=1||event_25_25_1!=1){
         if(delta_NZDUSD_MN1>delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5",">",10,TextFONT,col_5);
         if(delta_NZDUSD_MN1<delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5","<",10,TextFONT,col_5);
         if(delta_NZDUSD_MN1==delta_NZDCAD_MN1)ObjectSetText("point_up_dw_5","=",10,TextFONT,col_17);}

         if(event_27_27_1==1||event_28_28_1==1){
         if(delta_USDCHF_MN1>delta_CADCHF_MN1)ObjectSetText("point_up_dw_6",">",10,TextFONT,col_14);
         if(delta_USDCHF_MN1<delta_CADCHF_MN1)ObjectSetText("point_up_dw_6","<",10,TextFONT,col_14);
         if(delta_USDCHF_MN1==delta_CADCHF_MN1)ObjectSetText("point_up_dw_6","=",10,TextFONT,col_17);}
         if(event_27_27_1!=1||event_28_28_1!=1){
         if(delta_USDCHF_MN1>delta_CADCHF_MN1)ObjectSetText("point_up_dw_6",">",10,TextFONT,col_5);
         if(delta_USDCHF_MN1<delta_CADCHF_MN1)ObjectSetText("point_up_dw_6","<",10,TextFONT,col_5);
         if(delta_USDCHF_MN1==delta_CADCHF_MN1)ObjectSetText("point_up_dw_6","=",10,TextFONT,col_17);}}}
//--------------------вывод больше-меньше MN1 на график--------------------------------------
         //if(str5_time==1)ObjectSetText("point_up_dw_1","=",10,TextFONT,col_17);
         //if(str5_time==1)ObjectSetText("point_up_dw_2","=",10,TextFONT,col_17);
         //if(str5_time==1)ObjectSetText("point_up_dw_3","=",10,TextFONT,col_17);
         //if(str5_time==1)ObjectSetText("point_up_dw_4","=",10,TextFONT,col_17);
         //if(str5_time==1)ObjectSetText("point_up_dw_5","=",10,TextFONT,col_17);
         //if(str5_time==1)ObjectSetText("point_up_dw_6","=",10,TextFONT,col_17);   
//--------------------вывод больше-меньше выводим на график----------------------------------

//--------------------скан стратегий---------------------------------------------------------
         for(int i=1; i<= 6; i++){string txt_="txt_"+IntegerToString(i);
         if(ObjectFind(0,txt_)==-1){
         ObjectCreate(txt_,OBJ_LABEL,0,0,0);ObjectSetString(0,txt_,OBJPROP_TOOLTIP,"\n");ObjectSet(txt_, OBJPROP_CORNER,0); 
         ObjectSet(txt_, OBJPROP_XDISTANCE,590);
         ObjectSet("txt_6", OBJPROP_XDISTANCE,450);
         ObjectSet("txt_1",OBJPROP_YDISTANCE,50);
         ObjectSet("txt_2",OBJPROP_YDISTANCE,70);
         ObjectSet("txt_3",OBJPROP_YDISTANCE,90);
         ObjectSet("txt_4",OBJPROP_YDISTANCE,110);
         ObjectSet("txt_5",OBJPROP_YDISTANCE,130);
         ObjectSet("txt_6",OBJPROP_YDISTANCE,90);}

         if(event_1==0){
         if(FileIsExist(filename_pr1,0)>=1)ObjectSetText("txt_1","1",10,TextFONT,col_14);
         if(FileIsExist(filename_pr2,0)>=1)ObjectSetText("txt_2","2",10,TextFONT,col_14);
         if(FileIsExist(filename_pr3,0)>=1)ObjectSetText("txt_3","3",10,TextFONT,col_14);
         if(FileIsExist(filename_pr4,0)>=1)ObjectSetText("txt_4","4",10,TextFONT,col_14);
         if(FileIsExist(filename_pr5,0)>=1)ObjectSetText("txt_5","5",10,TextFONT,col_14);
         if(str1_time==0&&str2_time==0&&str3_time==0&&str4_time==0&&str5_time==0)ObjectSetText("txt_6","Ждем...",10,TextFONT,col_14);
         if(str1_time==1||str2_time==1||str3_time==1||str4_time==1||str5_time==1)ObjectSetText("txt_6","Поиск",10,TextFONT,col_14);

         if(FileIsExist(filename_pr1,0)<1)ObjectSetText("txt_1","1",10,TextFONT,col_5);
         if(FileIsExist(filename_pr2,0)<1)ObjectSetText("txt_2","2",10,TextFONT,col_5);
         if(FileIsExist(filename_pr3,0)<1)ObjectSetText("txt_3","3",10,TextFONT,col_5);
         if(FileIsExist(filename_pr4,0)<1)ObjectSetText("txt_4","4",10,TextFONT,col_5);
         if(FileIsExist(filename_pr5,0)<1)ObjectSetText("txt_5","5",10,TextFONT,col_5);}
         
         if(event_1==1){ 
         if(FileIsExist(filename1,0)>=1)ObjectSetText("txt_1","1",10,TextFONT,col_14);
         if(FileIsExist(filename2,0)>=1)ObjectSetText("txt_2","2",10,TextFONT,col_14);
         if(FileIsExist(filename3,0)>=1)ObjectSetText("txt_3","3",10,TextFONT,col_14);
         if(FileIsExist(filename4,0)>=1)ObjectSetText("txt_4","4",10,TextFONT,col_14);
         if(FileIsExist(filename5,0)>=1)ObjectSetText("txt_5","5",10,TextFONT,col_14);
         
         if(FileIsExist(filename1,0)<1)ObjectSetText("txt_1","1",10,TextFONT,col_5);
         if(FileIsExist(filename2,0)<1)ObjectSetText("txt_2","2",10,TextFONT,col_5);
         if(FileIsExist(filename3,0)<1)ObjectSetText("txt_3","3",10,TextFONT,col_5);
         if(FileIsExist(filename4,0)<1)ObjectSetText("txt_4","4",10,TextFONT,col_5);
         if(FileIsExist(filename5,0)<1)ObjectSetText("txt_5","5",10,TextFONT,col_5);
         ObjectSetText("txt_6","Найдена",10,TextFONT,col_14);}}
//--------------------скан стратегий---------------------------------------------------------
          
//-----------------------прогресс бар выводит расчет быстрой дельты--------------------------
         /*
         if(OrdersTotal()<=0){
         
         double fast_delta=0;
         double fast_proc_delta=0.0;
         fast_proc_delta=120.0/60;
         fast_delta=Seconds()*fast_proc_delta;
         
         for(int i=1;i<=6;i++){string objectName="delta_f_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){              
         ObjectCreate(0,objectName,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,objectName,OBJPROP_YSIZE,2);ObjectSetInteger(0,objectName,OBJPROP_XDISTANCE,300);
         ObjectSetInteger(0,"delta_f_1",OBJPROP_YDISTANCE,224);
         ObjectSetInteger(0,"delta_f_2",OBJPROP_YDISTANCE,244);
         ObjectSetInteger(0,"delta_f_3",OBJPROP_YDISTANCE,264);
         ObjectSetInteger(0,"delta_f_4",OBJPROP_YDISTANCE,284);
         ObjectSetInteger(0,"delta_f_5",OBJPROP_YDISTANCE,304);
         ObjectSetInteger(0,"delta_f_6",OBJPROP_YDISTANCE,324);}
         
         ObjectSetInteger(0,objectName,OBJPROP_XSIZE,(int)fast_delta+2);
         
         if(fast_delta_EURUSD_GBPUSD_buy==1)ObjectSetInteger(0,"delta_f_1",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_EURUSD_GBPUSD_sell==1)ObjectSetInteger(0,"delta_f_1",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_EURUSD_GBPUSD_buy==0&&fast_delta_EURUSD_GBPUSD_sell==0)ObjectSetInteger(0,"delta_f_1",OBJPROP_BGCOLOR,col_5);
//-------------------------------------------------------------------------------------------     
         if(fast_delta_AUDCAD_AUDUSD_buy==1)ObjectSetInteger(0,"delta_f_2",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_AUDCAD_AUDUSD_sell==1)ObjectSetInteger(0,"delta_f_2",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_AUDCAD_AUDUSD_buy==0&&fast_delta_AUDCAD_AUDUSD_sell==0)ObjectSetInteger(0,"delta_f_2",OBJPROP_BGCOLOR,col_5);
//-------------------------------------------------------------------------------------------                      
         if(fast_delta_EURAUD_GBPAUD_buy==1)ObjectSetInteger(0,"delta_f_3",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_EURAUD_GBPAUD_sell==1)ObjectSetInteger(0,"delta_f_3",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_EURAUD_GBPAUD_buy==0&&fast_delta_EURAUD_GBPAUD_sell==0)ObjectSetInteger(0,"delta_f_3",OBJPROP_BGCOLOR,col_5); 
//-------------------------------------------------------------------------------------------                        
         if(fast_delta_AUDCHF_GBPCHF_buy==1)ObjectSetInteger(0,"delta_f_4",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_AUDCHF_GBPCHF_sell==1)ObjectSetInteger(0,"delta_f_4",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_AUDCHF_GBPCHF_buy==0&&fast_delta_AUDCHF_GBPCHF_sell==0)ObjectSetInteger(0,"delta_f_4",OBJPROP_BGCOLOR,col_5); 
//------------------------------------------------------------------------------------------- 
         if(fast_delta_NZDUSD_NZDCAD_buy==1)ObjectSetInteger(0,"delta_f_5",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_NZDUSD_NZDCAD_sell==1)ObjectSetInteger(0,"delta_f_5",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_NZDUSD_NZDCAD_buy==0&&fast_delta_NZDUSD_NZDCAD_sell==0)ObjectSetInteger(0,"delta_f_5",OBJPROP_BGCOLOR,col_5); 
//------------------------------------------------------------------------------------------- 
         if(fast_delta_USDCHF_CADCHF_buy==1)ObjectSetInteger(0,"delta_f_6",OBJPROP_BGCOLOR,col_14);
         if(fast_delta_USDCHF_CADCHF_sell==1)ObjectSetInteger(0,"delta_f_6",OBJPROP_BGCOLOR,col_9);
         if(fast_delta_USDCHF_CADCHF_buy==0&&fast_delta_USDCHF_CADCHF_sell==0)ObjectSetInteger(0,"delta_f_6",OBJPROP_BGCOLOR,col_5);}}
         
         if(OrdersTotal()>0){
         if(ObjectFind(0,"delta_f_1")!=-1)ObjectDelete(0,"delta_f_1");
         if(ObjectFind(0,"delta_f_2")!=-1)ObjectDelete(0,"delta_f_2");
         if(ObjectFind(0,"delta_f_3")!=-1)ObjectDelete(0,"delta_f_3");
         if(ObjectFind(0,"delta_f_4")!=-1)ObjectDelete(0,"delta_f_4");
         if(ObjectFind(0,"delta_f_5")!=-1)ObjectDelete(0,"delta_f_5");
         if(ObjectFind(0,"delta_f_6")!=-1)ObjectDelete(0,"delta_f_6");
         }     
         */
//-----------------------прогресс бар выводит расчет быстрой дельты--------------------------
                          
//-----------------------прогресс бар считаю волатильность-----------------------------------
         double time_cont_proc=0.0,elapsed_time=0,proc_time=0;int progress=0;

         if((gmt_hour==0&&Minute()>=10&&Minute()<=20)||(gmt_hour==7&&Minute()>=0&&Minute()<=10)||(gmt_hour==13&&Minute()>=30&&Minute()<=40)){
         time_cont_proc=254.0/(11*60.0);//Один пиксель на секунду в 11-минутном интервале

         if(gmt_hour==0)elapsed_time=(Minute()-10)*60+Seconds();
         if(gmt_hour==7)elapsed_time=Minute()*60+Seconds();
         if(gmt_hour==13)elapsed_time=(Minute()-30)*60+Seconds();

         //Ограничиваем elapsed_time в диапазоне 0-660
         elapsed_time=fmin(fmax(elapsed_time,0),660);
         progress=(int)(elapsed_time*time_cont_proc);

         //Ограничиваем progress в диапазоне 0-254
         progress=fmin(fmax(progress,0),254);
         proc_time=(progress/(254.0/100.0));

         if(ObjectFind(0,"bar_time1")==-1){
         ObjectCreate(0,"bar_time1",OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet("bar_time1",OBJPROP_CORNER,0);ObjectSetString(0,"bar_time1",OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,"bar_time1",OBJPROP_XDISTANCE,23);ObjectSetInteger(0,"bar_time1",OBJPROP_YDISTANCE,562);ObjectSetInteger(0,"bar_time1",OBJPROP_YSIZE,12);ObjectSetInteger(0,"bar_time1",OBJPROP_BGCOLOR,col_9);}
         ObjectSetInteger(0,"bar_time1",OBJPROP_XSIZE,progress);

         if(ObjectFind(0,"bar_time_t1")==-1){ObjectCreate("bar_time_t1",OBJ_LABEL,0,0,0);ObjectSetString(0,"bar_time_t1",OBJPROP_TOOLTIP,"\n");ObjectSet("bar_time_t1",OBJPROP_CORNER,0);ObjectSet("bar_time_t1",OBJPROP_YDISTANCE,560);}
         int text_x_pos=(progress<40)?progress+30:fmin(progress-30,244);
         ObjectSet("bar_time_t1",OBJPROP_XDISTANCE,text_x_pos);
         string text=(progress>=250)?"100.0%":DoubleToString(proc_time,2)+"%";
         ObjectSetText("bar_time_t1",text,10,TextFONT,(progress>=40)?col_17:col_9);}
//-----------------------прогресс бар считаю волатильность-----------------------------------

//-----------------------Заметка в ручную----------------------------------------------------        
         if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

         if(ObjectFind(0,"bar_time1")!=-1)ObjectDelete(0,"bar_time1");
         if(ObjectFind(0,"bar_time_t1")!=-1)ObjectDelete(0,"bar_time_t1");
         if(time_cont_proc!=0.0)time_cont_proc=0.0;;

         for(int i=1;i<=2;i++){string objectName="alert_admin_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName,OBJPROP_CORNER, CORNER);ObjectSet(objectName,OBJPROP_XDISTANCE,30);ObjectSet(objectName,OBJPROP_YDISTANCE,560);}        
         
         ObjectSetText("alert_admin_1","            Все будет ЗБС...",10,TextFONT,col_9);
         ObjectSetText("alert_admin_2","~ ИНВЕСТ ~",10,TextFONT,Color_tch_al);}}
         
         if((gmt_hour==00&&Minute()>=10&&Minute()<=20)||(gmt_hour==07&&Minute()>=00&&Minute()<=10)||(gmt_hour==13&&Minute()>=30&&Minute()<=40)){
         
         if(ObjectFind(0,"alert_admin_1")!=-1){ObjectDelete(0,"alert_admin_1");}
         if(ObjectFind(0,"alert_admin_2")!=-1){ObjectDelete(0,"alert_admin_2");}
         }  
//-----------------------Заметка в ручную----------------------------------------------------        

//-----------------------прогресс бар выводит цель по счету----------------------------------         
         double time_cont1=0;double time_cont_proc1=0.0;double time_cont_proc21=0.0;double time_cont_txt1=0.0;
         if(standart==false){time_cont_proc1=815.0/1000000.0;time_cont_proc21=1000000.0/100.0;time_cont1=AccountEquity()*time_cont_proc1;time_cont_txt1=AccountEquity()/time_cont_proc21;}
         if(standart==true){time_cont_proc1=815.0/10000.0;time_cont_proc21=10000.0/100.0;time_cont1=AccountEquity()*time_cont_proc1;time_cont_txt1=AccountEquity()/time_cont_proc21;}
//-----------------------рисуем прогресс бар-------------------------------------------------        
         for(int i=1;i<=2;i++){string objectName="bar_profit_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(0,objectName,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet(objectName,OBJPROP_CORNER,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,objectName,OBJPROP_XDISTANCE,23);ObjectSetInteger(0,objectName,OBJPROP_YDISTANCE,720);ObjectSetInteger(0,objectName,OBJPROP_YSIZE,12);ObjectSetInteger(0,objectName,OBJPROP_XSIZE,815);
         ObjectSetInteger(0,"bar_profit_1",OBJPROP_BGCOLOR,(C'80,85,86'));
         ObjectSetInteger(0,"bar_profit_2",OBJPROP_BGCOLOR,LightGray);}       

         if((time_cont_txt1)<100)ObjectSetInteger(0,"bar_profit_2",OBJPROP_XSIZE,(int)time_cont1);
         if((time_cont_txt1)>=100)ObjectSetInteger(0,"bar_profit_2",OBJPROP_XSIZE,815);}             
//-----------------------рисуем прогресс бар------------------------------------------------- 
//-----------------------пишем текст---------------------------------------------------------
         if (ObjectFind(0,"bar_profit_t1")==-1){
         ObjectCreate("bar_profit_t1",OBJ_LABEL,0,0,0);ObjectSetString(0, "bar_profit_t1",OBJPROP_TOOLTIP,"\n");ObjectSet("bar_profit_t1",OBJPROP_CORNER,0);ObjectSet("bar_profit_t1",OBJPROP_YDISTANCE,718);}
         int xDist=(time_cont_txt1<10)?(int)(time_cont1+30.0):(time_cont_txt1<100)?(int)(time_cont1-30.0):780;
         ObjectSet("bar_profit_t1",OBJPROP_XDISTANCE,xDist);
         string displayText;color displayColor=(time_cont_txt1<10)?White:col_17;
         if((t1_sec%10)<5){displayText=DoubleToString((double)time_cont_txt1,0)+"%";}
         else{double equityValue=(standart)?AccountEquity():AccountEquity()/100.0;displayText=DoubleToString(equityValue,0)+"$";}
         ObjectSetText("bar_profit_t1",displayText,10,TextFONT,displayColor);
//-----------------------пишем текст---------------------------------------------------------      
//-----------------------прогресс бар выводит цель  по счету---------------------------------

//-----------------------прогресс бар выводит баланс и эквити--------------------------------
         if(trr<(-1)&&flag_4==0&&flag_5==0){double balance_bar_1=0;double equity_bar_1=0;double help_acc_1=0;
         balance_bar_1=(AccountBalance()+bonus)/130;
         equity_bar_1=((AccountBalance()+bonus)-AccountEquity())/balance_bar_1;
         help_acc_1=((AccountBalance()+bonus)-HelpAccount)/balance_bar_1;
//-----------------------рисуем прогресс бар-------------------------------------------------
         for(int i=1;i<=3;i++){string objectName="balance_equity_bar_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){ 
         ObjectCreate(0,objectName,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet(objectName,OBJPROP_CORNER,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,objectName,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,objectName,OBJPROP_STYLE,STYLE_SOLID);ObjectSetInteger(0,objectName,OBJPROP_WIDTH,0);ObjectSetInteger(0,objectName,OBJPROP_YDISTANCE,580);ObjectSetInteger(0,objectName,OBJPROP_XSIZE,15);
         ObjectSetInteger(0,"balance_equity_bar_1",OBJPROP_XDISTANCE,720);
         ObjectSetInteger(0,"balance_equity_bar_1",OBJPROP_YSIZE,-124); //верстикаль
         ObjectSetInteger(0,"balance_equity_bar_1",OBJPROP_BGCOLOR,col_5);       
         ObjectSetInteger(0,"balance_equity_bar_2",OBJPROP_XDISTANCE,736);
         ObjectSetInteger(0,"balance_equity_bar_2",OBJPROP_BGCOLOR,col_14);
         ObjectSetInteger(0,"balance_equity_bar_3",OBJPROP_XDISTANCE,752);
         ObjectSetInteger(0,"balance_equity_bar_3",OBJPROP_BGCOLOR,col_9);}
         
         ObjectSetInteger(0,"balance_equity_bar_2",OBJPROP_YSIZE,-124+(int)help_acc_1); //верстикаль
         ObjectSetInteger(0,"balance_equity_bar_3",OBJPROP_YSIZE,-124+(int)equity_bar_1);}}
//-----------------------рисуем прогресс бар-------------------------------------------------
//-----------------------пишем текст---------------------------------------------------------
         for(int i=1; i<= 3; i++){string bar_="bar_"+IntegerToString(i);
         if(ObjectFind(0,bar_)==-1){
         ObjectCreate(bar_,OBJ_LABEL,0,0,0);ObjectSetString(0,bar_,OBJPROP_TOOLTIP,"\n");ObjectSet(bar_, OBJPROP_CORNER,0); 
         ObjectSet(bar_, OBJPROP_XDISTANCE, 770);
         ObjectSet("bar_1",OBJPROP_YDISTANCE,455);
         ObjectSet("bar_2",OBJPROP_YDISTANCE,470);
         ObjectSet("bar_3",OBJPROP_YDISTANCE,485);
         ObjectSetText("bar_1","-Баланс",10,TextFONT,col_5);
         ObjectSetText("bar_2","-Цель",10,TextFONT,col_14);
         ObjectSetText("bar_3","-Эквити",10,TextFONT,col_9);}}
//-----------------------пишем текст---------------------------------------------------------       
         if(trr>-1||flag_4==1||flag_5==1){
         if(ObjectFind(0,"balance_equity_bar_1")!=-1)ObjectDelete(0,"balance_equity_bar_1");
         if(ObjectFind(0,"balance_equity_bar_2")!=-1)ObjectDelete(0,"balance_equity_bar_2");
         if(ObjectFind(0,"balance_equity_bar_3")!=-1)ObjectDelete(0,"balance_equity_bar_3");
         if(ObjectFind(0,"bar_1")!=-1)ObjectDelete(0,"bar_1");
         if(ObjectFind(0,"bar_2")!=-1)ObjectDelete(0,"bar_2");
         if(ObjectFind(0,"bar_3")!=-1)ObjectDelete(0,"bar_3");}   
//-----------------------рисуем таблицу------------------------------------------------------      
//-----------------------прогресс бар выводит баланс и эквити--------------------------------

//--------------------вывод шестеренок на график---------------------------------------------
         if(OrdersTotal()<1&&flag_4==0&&flag_5==0){
         CreateWorkLabel(1,angleWork1,690,520,50,DimGray);
         CreateWorkLabel(2,angleWork2,736,510,30,DimGray);
         CreateWorkLabel(3,angleWork3,410,520,50,DimGray);
         CreateWorkLabel(4,angleWork4,456,510,30,DimGray);
         {UpdateRotation();}}
         if(OrdersTotal()>=1||flag_4==1||flag_5==1){
         if(ObjectFind(0,"work_1")!=-1)ObjectDelete(0,"work_1");
         if(ObjectFind(0,"work_2")!=-1)ObjectDelete(0,"work_2");
         if(ObjectFind(0,"work_3")!=-1)ObjectDelete(0,"work_3");
         if(ObjectFind(0,"work_4")!=-1)ObjectDelete(0,"work_4");}   
//--------------------конец вывод шестеренок на график---------------------------------------
   
//--------------------выводим график---------------------------------------------------------
         double delta_1=0,delta_2=0;

         string fr_1="";
         for (int i_1=0;i_1<OrdersTotal();i_1++){
         if(OrderSelect(i_1,SELECT_BY_POS,MODE_TRADES)){
         if(OrderType()==OP_SELL){

         if(OrderMagicNumber()==1)fr_1="EURUSD";      
         if(OrderMagicNumber()==4)fr_1="AUDCAD";
         if(OrderMagicNumber()==7)fr_1="EURAUD";
         if(OrderMagicNumber()==16)fr_1="AUDCHF";
         if(OrderMagicNumber()==19)fr_1="NZDUSD";
         if(OrderMagicNumber()==22)fr_1="USDCHF";
         
         if(OrderMagicNumber()==2)fr_1="GBPUSD";
         if(OrderMagicNumber()==5)fr_1="AUDUSD";
         if(OrderMagicNumber()==8)fr_1="GBPAUD";
         if(OrderMagicNumber()==17)fr_1="GBPCHF";
         if(OrderMagicNumber()==20)fr_1="NZDCAD";
         if(OrderMagicNumber()==23)fr_1="CADCHF";}}}

         double PriceAsk_0_1=MarketInfo(fr_1,MODE_ASK),PriceBid_0_1=MarketInfo(fr_1,MODE_BID);
         double Price_0_1=((PriceAsk_0_1+PriceBid_0_1)/2);
         double PriceClose_1=iClose(fr_1,PERIOD_D1,20);
         double PriceProc_1=PriceClose_1/100; 
         delta_1=(Price_0_1-PriceClose_1)/PriceProc_1; 
         
         string fr_2="";
         for (int i_2=0;i_2<OrdersTotal();i_2++){
         if(OrderSelect(i_2,SELECT_BY_POS,MODE_TRADES)){
         if(OrderType()==OP_BUY){


         if(OrderMagicNumber()==1)fr_2="EURUSD";      
         if(OrderMagicNumber()==4)fr_2="AUDCAD";
         if(OrderMagicNumber()==7)fr_2="EURAUD";
         if(OrderMagicNumber()==16)fr_2="AUDCHF";
         if(OrderMagicNumber()==19)fr_2="NZDUSD";
         if(OrderMagicNumber()==22)fr_2="USDCHF";
         
         if(OrderMagicNumber()==2)fr_2="GBPUSD";
         if(OrderMagicNumber()==5)fr_2="AUDUSD";
         if(OrderMagicNumber()==8)fr_2="GBPAUD";
         if(OrderMagicNumber()==17)fr_2="GBPCHF";
         if(OrderMagicNumber()==20)fr_2="NZDCAD";
         if(OrderMagicNumber()==23)fr_2="CADCHF";}}}
     
         double PriceAsk_0_2=MarketInfo(fr_2,MODE_ASK),PriceBid_0_2=MarketInfo(fr_2,MODE_BID);
         double Price_0_2=((PriceAsk_0_2+PriceBid_0_2)/2);
         double PriceClose_2=iClose(fr_2,PERIOD_D1,20);
         double PriceProc_2=PriceClose_2/100; 
         delta_2=(Price_0_2-PriceClose_2)/PriceProc_2;     
//-------------------------------------------------------------------------------------------
         if(CountSell_1()>=1&&CountBuy_1()>=1&&flag_4==0&&flag_5==0){       
         for(int i=1; i<= 2; i++){string objectName="graf_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(0,objectName,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSet(objectName,OBJPROP_CORNER,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSetInteger(0,objectName,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,objectName,OBJPROP_STYLE,STYLE_SOLID);ObjectSetInteger(0,objectName,OBJPROP_WIDTH,0); }
         ObjectSetInteger(0,"graf_1",OBJPROP_XDISTANCE,360);
         ObjectSetInteger(0,"graf_1",OBJPROP_YDISTANCE,520);
         ObjectSetInteger(0,"graf_1",OBJPROP_YSIZE,(int)(-(delta_1*20))); 
         ObjectSetInteger(0,"graf_1",OBJPROP_XSIZE,80);
         ObjectSetInteger(0,"graf_1",OBJPROP_BGCOLOR,Orange); 
//-------------------------------------------------------------------------------------------         
         ObjectSetInteger(0,"graf_2",OBJPROP_XDISTANCE,400);
         ObjectSetInteger(0,"graf_2",OBJPROP_YDISTANCE,520);
         ObjectSetInteger(0,"graf_2",OBJPROP_YSIZE,(int)(-(delta_2*20)));
         ObjectSetInteger(0,"graf_2",OBJPROP_XSIZE,80);
         ObjectSetInteger(0,"graf_2",OBJPROP_BGCOLOR,DodgerBlue);   
//-------------------------------------------------------------------------------------------
         }
         
         for(int i=3; i<= 6; i++){string objectName="graf_"+IntegerToString(i);
         if(ObjectFind(0,objectName)==-1){
         ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSet(objectName,OBJPROP_CORNER, 0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");
         ObjectSet("graf_3", OBJPROP_XDISTANCE,360);
         ObjectSetText("graf_3","---------------------------",8,TextFONT,Orange);
         ObjectSet("graf_4",OBJPROP_XDISTANCE,310);
         ObjectSet("graf_4",OBJPROP_YDISTANCE,455);
             
         ObjectSet("graf_5", OBJPROP_XDISTANCE,400);
         ObjectSetText("graf_5","---------------------",8,TextFONT,DodgerBlue);
         ObjectSet("graf_6",OBJPROP_XDISTANCE,310);
         ObjectSet("graf_6",OBJPROP_YDISTANCE,470);}

         ObjectSetText("graf_4",fr_1,10,TextFONT,Orange); 
         ObjectSetText("graf_6",fr_2,10,TextFONT,DodgerBlue);
         ObjectSetInteger(0,"graf_3",OBJPROP_YDISTANCE,(int)(512-(delta_1)*20));
         ObjectSetInteger(0,"graf_5",OBJPROP_YDISTANCE,(int)(512-(delta_2)*20));
                 
         if(CountSell_1()>=1&&CountBuy_1()>=1&&flag_4==0&&flag_5==0){ 
         string pr_txt="pr_txt";
         ObjectSet(pr_txt,OBJPROP_CORNER,0);ObjectCreate(pr_txt,OBJ_LABEL,0,0,0);ObjectSetString(0,pr_txt,OBJPROP_TOOLTIP,"\n");
         ObjectSet(pr_txt,OBJPROP_XDISTANCE,500);ObjectSet(pr_txt,OBJPROP_YDISTANCE,((int(512-(delta_1)*20))+int(512-(delta_2)*20))/2);
         if(CountSell_1()>CountBuy_1())ObjectSetText(pr_txt,DoubleToStr(NormalizeDouble(MathAbs(delta_1-(delta_2)),2),2)+"%",10,TextFONT,Orange);
         if(CountSell_1()<CountBuy_1())ObjectSetText(pr_txt,DoubleToStr(NormalizeDouble(MathAbs(delta_1-(delta_2)),2),2)+"%",10,TextFONT,DodgerBlue);
         if(CountSell_1()==CountBuy_1())ObjectSetText(pr_txt,DoubleToStr(NormalizeDouble(MathAbs(delta_1-(delta_2)),2),2)+"%",10,TextFONT,col_5);}}}

         if(CountSell_1()<1||CountBuy_1()<1||flag_4==1||flag_5==1){ 
         if(ObjectFind(0,"graf_1")!=-1)ObjectDelete(0,"graf_1");
         if(ObjectFind(0,"graf_2")!=-1)ObjectDelete(0,"graf_2");
         if(ObjectFind(0,"graf_3")!=-1)ObjectDelete(0,"graf_3");
         if(ObjectFind(0,"graf_4")!=-1)ObjectDelete(0,"graf_4");
         if(ObjectFind(0,"graf_5")!=-1)ObjectDelete(0,"graf_5");
         if(ObjectFind(0,"graf_6")!=-1)ObjectDelete(0,"graf_6");
         if(ObjectFind(0,"pr_txt")!=-1)ObjectDelete(0,"pr_txt");}  
//--------------------конец выводим график---------------------------------------------------

//-----------------------расчет дельты------------------------------------------------------
         if((gmt_hour==00&&Minute()>=20&&Minute()<=59)||(gmt_hour==07&&Minute()>=10&&Minute()<=59)||(gmt_hour==13&&Minute()>=40&&Minute()<=59)){
         if(ObjectFind(0,"m_bg_delta")!=-1)ObjectDelete(0,"m_bg_delta");
         if(ObjectFind(0,"delta_1")!=-1)ObjectDelete(0,"delta_1");
         if(ObjectFind(0,"delta_2")!=-1)ObjectDelete(0,"delta_2");
         if(ObjectFind(0,"delta_3")!=-1)ObjectDelete(0,"delta_3");
         if(ObjectFind(0,"delta_4")!=-1)ObjectDelete(0,"delta_4");
         if(ObjectFind(0,"delta_5")!=-1)ObjectDelete(0,"delta_5");
         if(ObjectFind(0,"delta_6")!=-1)ObjectDelete(0,"delta_6");
         if(ObjectFind(0,"delta_7")!=-1)ObjectDelete(0,"delta_7");
         if(ObjectFind(0,"delta_8")!=-1)ObjectDelete(0,"delta_8");
         if(ObjectFind(0,"delta_9")!=-1)ObjectDelete(0,"delta_9");
         if(ObjectFind(0,"delta_10")!=-1)ObjectDelete(0,"delta_10");
         if(ObjectFind(0,"delta_11")!=-1)ObjectDelete(0,"delta_11");
         if(ObjectFind(0,"delta_12")!=-1)ObjectDelete(0,"delta_12");
         if(ObjectFind(0,"delta_13")!=-1)ObjectDelete(0,"delta_13");
         if(ObjectFind(0,"delta_14")!=-1)ObjectDelete(0,"delta_14");
         if(ObjectFind(0,"delta_15")!=-1)ObjectDelete(0,"delta_15");
         if(ObjectFind(0,"delta_16")!=-1)ObjectDelete(0,"delta_16");
         if(ObjectFind(0,"delta_17")!=-1)ObjectDelete(0,"delta_17");
         if(ObjectFind(0,"delta_18")!=-1)ObjectDelete(0,"delta_18");
         if(ObjectFind(0,"delta_19")!=-1)ObjectDelete(0,"delta_19");
         if(ObjectFind(0,"delta_20")!=-1)ObjectDelete(0,"delta_20");
         if(ObjectFind(0,"delta_21")!=-1)ObjectDelete(0,"delta_21");
         if(ObjectFind(0,"delta_22")!=-1)ObjectDelete(0,"delta_22");
         if(ObjectFind(0,"delta_23")!=-1)ObjectDelete(0,"delta_23");
         if(ObjectFind(0,"delta_24")!=-1)ObjectDelete(0,"delta_24");
         if(ObjectFind(0,"delta_25")!=-1)ObjectDelete(0,"delta_25");
         if(ObjectFind(0,"delta_26")!=-1)ObjectDelete(0,"delta_26");
         if(ObjectFind(0,"delta_27")!=-1)ObjectDelete(0,"delta_27");
         if(ObjectFind(0,"delta_28")!=-1)ObjectDelete(0,"delta_28");
         if(ObjectFind(0,"delta_29")!=-1)ObjectDelete(0,"delta_29");
         if(ObjectFind(0,"delta_30")!=-1)ObjectDelete(0,"delta_30");
         if(ObjectFind(0,"delta_31")!=-1)ObjectDelete(0,"delta_31");
         if(ObjectFind(0,"delta_32")!=-1)ObjectDelete(0,"delta_32");
         if(ObjectFind(0,"delta_33")!=-1)ObjectDelete(0,"delta_33");
         if(ObjectFind(0,"delta_34")!=-1)ObjectDelete(0,"delta_34");
         if(ObjectFind(0,"delta_35")!=-1)ObjectDelete(0,"delta_35");
         if(ObjectFind(0,"delta_36")!=-1)ObjectDelete(0,"delta_36");
         if(ObjectFind(0,"delta_37")!=-1)ObjectDelete(0,"delta_37");
         if(ObjectFind(0,"delta_38")!=-1)ObjectDelete(0,"delta_38");
         if(ObjectFind(0,"delta_39")!=-1)ObjectDelete(0,"delta_39");
         if(ObjectFind(0,"delta_40")!=-1)ObjectDelete(0,"delta_40");
         if(ObjectFind(0,"delta_41")!=-1)ObjectDelete(0,"delta_41");
         if(ObjectFind(0,"delta_42")!=-1)ObjectDelete(0,"delta_42");
         if(ObjectFind(0,"delta_43")!=-1)ObjectDelete(0,"delta_43");
         }
         

         if((gmt_hour==00&&Minute()>=10&&Minute()<=20)||(gmt_hour==07&&Minute()>=00&&Minute()<=10)||(gmt_hour==13&&Minute()>=30&&Minute()<=40)){
         
         int x_delta_=300;
         int y_delta_=450;
         
         if(ObjectFind(0,"m_bg_delta")==-1){         
         ObjectCreate(0,"m_bg_delta",OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetString(0,"m_bg_delta",OBJPROP_TOOLTIP,"\n");     // отключаем всплывающую подсказку
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_XDISTANCE,x_delta_);   //300
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_YDISTANCE,y_delta_);
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_YSIZE,135);       // верстикаль //135
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_XSIZE,540);       // горизонталь
         ObjectSet("m_bg_delta",OBJPROP_CORNER,CORNER);
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_WIDTH,1);
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_COLOR,Orange);
         //ObjectSetInteger(0,"m_bg_delta",OBJPROP_BGCOLOR,Black);
         }
         //Переменная для хранения предыдущего цвета
         int prevColor_delta=-1;
         if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1){
         int newColor_delta=C'10,10,46';//Цвет для BUY
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1){
         int newColor_delta=C'51,0,0';//Цвет для SELL
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1){
         int newColor_delta=C'0,23,0';//Цвет для BUY и SELL одновременно
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0){
         int newColor_delta=col_17;//Цвет для обоих ордеров равных 0
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_delta",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
        
        
         for(int i=1; i<= 43; i++){string delta_="delta_"+IntegerToString(i);

         if(ObjectFind(0,delta_)==-1){
         ObjectCreate(delta_,OBJ_LABEL,0,0,0);ObjectSetString(0,delta_,OBJPROP_TOOLTIP,"\n");ObjectSet(delta_, OBJPROP_CORNER,0); 
         ObjectSet(delta_, OBJPROP_XDISTANCE, x_delta_+10);
         ObjectSet("delta_1",OBJPROP_YDISTANCE,y_delta_+5);
         
         ObjectSet("delta_2",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_3",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_4",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_5",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_6",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_7",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_8",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_9",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_10",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_11",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_12",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_13",OBJPROP_YDISTANCE,y_delta_+35);
         ObjectSet("delta_14",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_15",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_16",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_17",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_18",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_19",OBJPROP_YDISTANCE,y_delta_+50);
         ObjectSet("delta_20",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_21",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_22",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_23",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_24",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_25",OBJPROP_YDISTANCE,y_delta_+65);
         ObjectSet("delta_26",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_27",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_28",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_29",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_30",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_31",OBJPROP_YDISTANCE,y_delta_+80);
         ObjectSet("delta_32",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_33",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_34",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_35",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_36",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_37",OBJPROP_YDISTANCE,y_delta_+95);
         ObjectSet("delta_38",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_39",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_40",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_41",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_42",OBJPROP_YDISTANCE,y_delta_+110);
         ObjectSet("delta_43",OBJPROP_YDISTANCE,y_delta_+110);
         
         ObjectSetText("delta_1","Дельта %         №1      №2      №3      №4      №5      Max",10,TextFONT,Gray);
         
         ObjectSetText("delta_2","EURUSD/GBPUSD",10,TextFONT,Gray);
         ObjectSetText("delta_3","AUDCAD/AUDUSD",10,TextFONT,Gray);
         ObjectSetText("delta_4","EURAUD/GBPAUD",10,TextFONT,Gray);
         ObjectSetText("delta_5","AUDCHF/GBPCHF",10,TextFONT,Gray);
         ObjectSetText("delta_6","NZDUSD/NZDCAD",10,TextFONT,Gray);
         ObjectSetText("delta_7","USDCHF/CADCHF",10,TextFONT,Gray);}
         
         if(delta_EURUSD_GBPUSD_1==0)ObjectSetText("delta_8","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_1),4),4),10,TextFONT,Orange);
         if(delta_EURUSD_GBPUSD_2==0)ObjectSetText("delta_9","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_2),4),4),10,TextFONT,Orange);
        if(delta_EURUSD_GBPUSD_3==0)ObjectSetText("delta_10","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_3),4),4),10,TextFONT,Orange);
        if(delta_EURUSD_GBPUSD_4==0)ObjectSetText("delta_11","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_4),4),4),10,TextFONT,Orange);
        if(delta_EURUSD_GBPUSD_5==0)ObjectSetText("delta_12","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_5),4),4),10,TextFONT,Orange);
        if(delta_EURUSD_GBPUSD_average==0)ObjectSetText("delta_13","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_average),4),4),10,TextFONT,Orange);
        if(delta_EURUSD_GBPUSD_1!=0)ObjectSetText("delta_8","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_1),4),4),10,TextFONT,White);
        if(delta_EURUSD_GBPUSD_2!=0)ObjectSetText("delta_9","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_2),4),4),10,TextFONT,White);
        if(delta_EURUSD_GBPUSD_3!=0)ObjectSetText("delta_10","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_3),4),4),10,TextFONT,White);
        if(delta_EURUSD_GBPUSD_4!=0)ObjectSetText("delta_11","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_4),4),4),10,TextFONT,White);
        if(delta_EURUSD_GBPUSD_5!=0)ObjectSetText("delta_12","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_5),4),4),10,TextFONT,White);
        if(delta_EURUSD_GBPUSD_average!=0)ObjectSetText("delta_13","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_average),4),4),10,TextFONT,White);
          
        if(delta_AUDCAD_AUDUSD_1==0)ObjectSetText("delta_14","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_1),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_2==0)ObjectSetText("delta_15","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_2),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_3==0)ObjectSetText("delta_16","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_3),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_4==0)ObjectSetText("delta_17","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_4),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_5==0)ObjectSetText("delta_18","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_5),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_average==0)ObjectSetText("delta_19","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_average),4),4),10,TextFONT,Orange);
        if(delta_AUDCAD_AUDUSD_1!=0)ObjectSetText("delta_14","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_1),4),4),10,TextFONT,White);
        if(delta_AUDCAD_AUDUSD_2!=0)ObjectSetText("delta_15","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_2),4),4),10,TextFONT,White);
        if(delta_AUDCAD_AUDUSD_3!=0)ObjectSetText("delta_16","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_3),4),4),10,TextFONT,White);
        if(delta_AUDCAD_AUDUSD_4!=0)ObjectSetText("delta_17","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_4),4),4),10,TextFONT,White);
        if(delta_AUDCAD_AUDUSD_5!=0)ObjectSetText("delta_18","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_5),4),4),10,TextFONT,White);
        if(delta_AUDCAD_AUDUSD_average!=0)ObjectSetText("delta_19","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_average),4),4),10,TextFONT,White);
         
        if(delta_EURAUD_GBPAUD_1==0)ObjectSetText("delta_20","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_1),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_2==0)ObjectSetText("delta_21","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_2),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_3==0)ObjectSetText("delta_22","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_3),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_4==0)ObjectSetText("delta_23","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_4),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_5==0)ObjectSetText("delta_24","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_5),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_average==0)ObjectSetText("delta_25","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_average),4),4),10,TextFONT,Orange);
        if(delta_EURAUD_GBPAUD_1!=0)ObjectSetText("delta_20","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_1),4),4),10,TextFONT,White);
        if(delta_EURAUD_GBPAUD_2!=0)ObjectSetText("delta_21","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_2),4),4),10,TextFONT,White);
        if(delta_EURAUD_GBPAUD_3!=0)ObjectSetText("delta_22","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_3),4),4),10,TextFONT,White);
        if(delta_EURAUD_GBPAUD_4!=0)ObjectSetText("delta_23","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_4),4),4),10,TextFONT,White);
        if(delta_EURAUD_GBPAUD_5!=0)ObjectSetText("delta_24","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_5),4),4),10,TextFONT,White);
        if(delta_EURAUD_GBPAUD_average!=0)ObjectSetText("delta_25","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_average),4),4),10,TextFONT,White);
          
        if(delta_AUDCHF_GBPCHF_1==0)ObjectSetText("delta_26","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_1),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_2==0)ObjectSetText("delta_27","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_2),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_3==0)ObjectSetText("delta_28","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_3),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_4==0)ObjectSetText("delta_29","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_4),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_5==0)ObjectSetText("delta_30","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_5),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_average==0)ObjectSetText("delta_31","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_average),4),4),10,TextFONT,Orange);
        if(delta_AUDCHF_GBPCHF_1!=0)ObjectSetText("delta_26","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_1),4),4),10,TextFONT,White);
        if(delta_AUDCHF_GBPCHF_2!=0)ObjectSetText("delta_27","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_2),4),4),10,TextFONT,White);
        if(delta_AUDCHF_GBPCHF_3!=0)ObjectSetText("delta_28","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_3),4),4),10,TextFONT,White);
        if(delta_AUDCHF_GBPCHF_4!=0)ObjectSetText("delta_29","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_4),4),4),10,TextFONT,White);
        if(delta_AUDCHF_GBPCHF_5!=0)ObjectSetText("delta_30","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_5),4),4),10,TextFONT,White);
        if(delta_AUDCHF_GBPCHF_average!=0)ObjectSetText("delta_31","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_average),4),4),10,TextFONT,White);
         
         
        if(delta_NZDUSD_NZDCAD_1==0)ObjectSetText("delta_32","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_1),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_2==0)ObjectSetText("delta_33","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_2),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_3==0)ObjectSetText("delta_34","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_3),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_4==0)ObjectSetText("delta_35","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_4),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_5==0)ObjectSetText("delta_36","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_5),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_average==0)ObjectSetText("delta_37","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_average),4),4),10,TextFONT,Orange);
        if(delta_NZDUSD_NZDCAD_1!=0)ObjectSetText("delta_32","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_1),4),4),10,TextFONT,White);
        if(delta_NZDUSD_NZDCAD_2!=0)ObjectSetText("delta_33","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_2),4),4),10,TextFONT,White);
        if(delta_NZDUSD_NZDCAD_3!=0)ObjectSetText("delta_34","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_3),4),4),10,TextFONT,White);
        if(delta_NZDUSD_NZDCAD_4!=0)ObjectSetText("delta_35","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_4),4),4),10,TextFONT,White);
        if(delta_NZDUSD_NZDCAD_5!=0)ObjectSetText("delta_36","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_5),4),4),10,TextFONT,White);
        if(delta_NZDUSD_NZDCAD_average!=0)ObjectSetText("delta_37","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_average),4),4),10,TextFONT,White);
         
          
        if(delta_USDCHF_CADCHF_1==0)ObjectSetText("delta_38","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_1),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_2==0)ObjectSetText("delta_39","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_2),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_3==0)ObjectSetText("delta_40","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_3),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_4==0)ObjectSetText("delta_41","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_4),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_5==0)ObjectSetText("delta_42","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_5),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_average==0)ObjectSetText("delta_43","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_average),4),4),10,TextFONT,Orange);
        if(delta_USDCHF_CADCHF_1!=0)ObjectSetText("delta_38","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_1),4),4),10,TextFONT,White);
        if(delta_USDCHF_CADCHF_2!=0)ObjectSetText("delta_39","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_2),4),4),10,TextFONT,White);
        if(delta_USDCHF_CADCHF_3!=0)ObjectSetText("delta_40","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_3),4),4),10,TextFONT,White);
        if(delta_USDCHF_CADCHF_4!=0)ObjectSetText("delta_41","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_4),4),4),10,TextFONT,White);
        if(delta_USDCHF_CADCHF_5!=0)ObjectSetText("delta_42","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_5),4),4),10,TextFONT,White);
        if(delta_USDCHF_CADCHF_average!=0)ObjectSetText("delta_43","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_average),4),4),10,TextFONT,White);
        }}

//-----------------------расчет дельты------------------------------------------------------
//-----------------------выводим среднюю дельту------------------------------------------------

         if(Minute()>=30&&Minute()<=40)
         {
         if(ObjectFind(0,"m_bg_dt_av")!=-1)ObjectDelete(0,"m_bg_dt_av");
         if(ObjectFind(0,"dt_av_1")!=-1)ObjectDelete(0,"dt_av_1");
         if(ObjectFind(0,"dt_av_2")!=-1)ObjectDelete(0,"dt_av_2");
         if(ObjectFind(0,"dt_av_3")!=-1)ObjectDelete(0,"dt_av_3");
         if(ObjectFind(0,"dt_av_4")!=-1)ObjectDelete(0,"dt_av_4");
         if(ObjectFind(0,"dt_av_5")!=-1)ObjectDelete(0,"dt_av_5");
         if(ObjectFind(0,"dt_av_6")!=-1)ObjectDelete(0,"dt_av_6");
         if(ObjectFind(0,"dt_av_7")!=-1)ObjectDelete(0,"dt_av_7");
         if(ObjectFind(0,"dt_av_8")!=-1)ObjectDelete(0,"dt_av_8");
         if(ObjectFind(0,"dt_av_9")!=-1)ObjectDelete(0,"dt_av_9");
         if(ObjectFind(0,"dt_av_10")!=-1)ObjectDelete(0,"dt_av_10");
         if(ObjectFind(0,"dt_av_11")!=-1)ObjectDelete(0,"dt_av_11");
         if(ObjectFind(0,"dt_av_12")!=-1)ObjectDelete(0,"dt_av_12");
         if(ObjectFind(0,"dt_av_13")!=-1)ObjectDelete(0,"dt_av_13");
         if(ObjectFind(0,"dt_av_14")!=-1)ObjectDelete(0,"dt_av_14");
         if(ObjectFind(0,"dt_av_15")!=-1)ObjectDelete(0,"dt_av_15");
         if(ObjectFind(0,"dt_av_16")!=-1)ObjectDelete(0,"dt_av_16");
         if(ObjectFind(0,"dt_av_17")!=-1)ObjectDelete(0,"dt_av_17");
         if(ObjectFind(0,"dt_av_18")!=-1)ObjectDelete(0,"dt_av_18");
         if(ObjectFind(0,"dt_av_19")!=-1)ObjectDelete(0,"dt_av_19");
         if(ObjectFind(0,"dt_av_20")!=-1)ObjectDelete(0,"dt_av_20");
         if(ObjectFind(0,"dt_av_21")!=-1)ObjectDelete(0,"dt_av_21");
         if(ObjectFind(0,"dt_av_22")!=-1)ObjectDelete(0,"dt_av_22");
         if(ObjectFind(0,"dt_av_23")!=-1)ObjectDelete(0,"dt_av_23");
         if(ObjectFind(0,"dt_av_24")!=-1)ObjectDelete(0,"dt_av_24");
         if(ObjectFind(0,"dt_av_25")!=-1)ObjectDelete(0,"dt_av_25");
         if(ObjectFind(0,"dt_av_26")!=-1)ObjectDelete(0,"dt_av_26");
         if(ObjectFind(0,"dt_av_27")!=-1)ObjectDelete(0,"dt_av_27");
         if(ObjectFind(0,"dt_av_28")!=-1)ObjectDelete(0,"dt_av_28");
         if(ObjectFind(0,"dt_av_29")!=-1)ObjectDelete(0,"dt_av_29");
         if(ObjectFind(0,"dt_av_30")!=-1)ObjectDelete(0,"dt_av_30");
         if(ObjectFind(0,"dt_av_31")!=-1)ObjectDelete(0,"dt_av_31");
         if(ObjectFind(0,"dt_av_32")!=-1)ObjectDelete(0,"dt_av_32");
         if(ObjectFind(0,"dt_av_33")!=-1)ObjectDelete(0,"dt_av_33");
         if(ObjectFind(0,"dt_av_34")!=-1)ObjectDelete(0,"dt_av_34");
         if(ObjectFind(0,"dt_av_35")!=-1)ObjectDelete(0,"dt_av_35");
         if(ObjectFind(0,"dt_av_36")!=-1)ObjectDelete(0,"dt_av_36");
         if(ObjectFind(0,"dt_av_37")!=-1)ObjectDelete(0,"dt_av_37");
         if(ObjectFind(0,"dt_av_38")!=-1)ObjectDelete(0,"dt_av_38");
         if(ObjectFind(0,"dt_av_39")!=-1)ObjectDelete(0,"dt_av_39");
         if(ObjectFind(0,"dt_av_40")!=-1)ObjectDelete(0,"dt_av_40");
         if(ObjectFind(0,"dt_av_41")!=-1)ObjectDelete(0,"dt_av_41");
         if(ObjectFind(0,"dt_av_42")!=-1)ObjectDelete(0,"dt_av_42");
         if(ObjectFind(0,"dt_av_43")!=-1)ObjectDelete(0,"dt_av_43");
         }
    

         if(Minute()>20&&Minute()<30)
         {
         int x_dt_av_=300; //300
         int y_dt_av_=450; //450 740

         if(ObjectFind(0,"m_bg_dt_av")==-1){         
         ObjectCreate(0,"m_bg_dt_av",OBJ_RECTANGLE_LABEL,0,0,0);
         ObjectSetString(0,"m_bg_dt_av",OBJPROP_TOOLTIP,"\n");     // отключаем всплывающую подсказку
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_XDISTANCE,x_dt_av_);   //300
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_YDISTANCE,y_dt_av_);
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_YSIZE,135);       // верстикаль //135
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_XSIZE,540);       // горизонталь
         ObjectSet("m_bg_dt_av",OBJPROP_CORNER,CORNER);
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_WIDTH,1);
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_COLOR,Orange);
         //ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BGCOLOR,Black);
         }
         
         //Переменная для хранения предыдущего цвета
         int prevColor_delta=-1;
         if(main.orders[OP_BUY]>=1&&main.orders[OP_SELL]<1){
         int newColor_delta=C'10,10,46';//Цвет для BUY
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]<1){
         int newColor_delta=C'51,0,0';//Цвет для SELL
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]>=1&&main.orders[OP_BUY]>=1){
         int newColor_delta=C'0,23,0';//Цвет для BUY и SELL одновременно
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
         else if(main.orders[OP_SELL]<=0&&main.orders[OP_BUY]<=0){
         int newColor_delta=col_17;//Цвет для обоих ордеров равных 0
         if(newColor_delta!=prevColor_delta){//Проверяем,если цвет изменился
         ObjectSetInteger(0,"m_bg_dt_av",OBJPROP_BGCOLOR,newColor_delta);
         prevColor_delta=newColor_delta;}}
        
         for(int i=1; i<= 43; i++){string dt_av_="dt_av_"+IntegerToString(i);

         if(ObjectFind(0,dt_av_)==-1){
         ObjectCreate(dt_av_,OBJ_LABEL,0,0,0);ObjectSetString(0,dt_av_,OBJPROP_TOOLTIP,"\n");ObjectSet(dt_av_, OBJPROP_CORNER,0); 
         ObjectSet(dt_av_, OBJPROP_XDISTANCE, x_dt_av_+10);
         ObjectSet("dt_av_1",OBJPROP_YDISTANCE,y_dt_av_+5);
         
         ObjectSet("dt_av_2",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_3",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_4",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_5",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_6",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_7",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_8",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_9",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_10",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_11",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_12",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_13",OBJPROP_YDISTANCE,y_dt_av_+35);
         ObjectSet("dt_av_14",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_15",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_16",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_17",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_18",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_19",OBJPROP_YDISTANCE,y_dt_av_+50);
         ObjectSet("dt_av_20",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_21",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_22",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_23",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_24",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_25",OBJPROP_YDISTANCE,y_dt_av_+65);
         ObjectSet("dt_av_26",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_27",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_28",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_29",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_30",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_31",OBJPROP_YDISTANCE,y_dt_av_+80);
         ObjectSet("dt_av_32",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_33",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_34",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_35",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_36",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_37",OBJPROP_YDISTANCE,y_dt_av_+95);
         ObjectSet("dt_av_38",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_39",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_40",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_41",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_42",OBJPROP_YDISTANCE,y_dt_av_+110);
         ObjectSet("dt_av_43",OBJPROP_YDISTANCE,y_dt_av_+110);

         ObjectSetText("dt_av_1","Средняя 3 мес.%  D1      MN1-D1  MN1-D2  MN1-D3  MN1-D4  MN1-D5",10,TextFONT,Gray);
         
         ObjectSetText("dt_av_2","EURUSD/GBPUSD",10,TextFONT,Gray);
         ObjectSetText("dt_av_3","AUDCAD/AUDUSD",10,TextFONT,Gray);
         ObjectSetText("dt_av_4","EURAUD/GBPAUD",10,TextFONT,Gray);
         ObjectSetText("dt_av_5","AUDCHF/GBPCHF",10,TextFONT,Gray);
         ObjectSetText("dt_av_6","NZDUSD/NZDCAD",10,TextFONT,Gray);
         ObjectSetText("dt_av_7","USDCHF/CADCHF",10,TextFONT,Gray);}
         
         ObjectSetText("dt_av_8","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_9","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_10","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_11","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_12","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_13","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURUSD_GBPUSD_MN1_strong5),2),2),10,TextFONT,Orange);
          
        ObjectSetText("dt_av_14","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_15","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_16","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_17","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_18","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_19","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCAD_AUDUSD_MN1_strong5),2),2),10,TextFONT,Orange);

        ObjectSetText("dt_av_20","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_21","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_22","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_23","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_24","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_25","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_EURAUD_GBPAUD_MN1_strong5),2),2),10,TextFONT,Orange);
          
        ObjectSetText("dt_av_26","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_27","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_28","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_29","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_30","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_31","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_AUDCHF_GBPCHF_MN1_strong5),2),2),10,TextFONT,Orange);
        
        ObjectSetText("dt_av_32","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_33","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_34","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_35","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_36","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_37","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_NZDUSD_NZDCAD_MN1_strong5),2),2),10,TextFONT,Orange);
        
        ObjectSetText("dt_av_38","                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF),2),2),10,TextFONT,Lime);
        ObjectSetText("dt_av_39","                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_MN1_strong1),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_40","                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_MN1_strong2),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_41","                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_MN1_strong3),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_42","                                                 "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_MN1_strong4),2),2),10,TextFONT,Orange);
        ObjectSetText("dt_av_43","                                                         "+DoubleToStr(NormalizeDouble(MathAbs(delta_USDCHF_CADCHF_MN1_strong5),2),2),10,TextFONT,Orange);
        }}
//-----------------------выводим среднюю дельту------------------------------------------------

    


//-----------------------проверяем ботов активен или нет---------------------------------------
        for(int i=1; i<= 4; i++){string objectName="check_bot_" + IntegerToString(i);
        if(ObjectFind(0,objectName)==-1){
        ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName, OBJPROP_CORNER,0); ObjectSet(objectName,OBJPROP_YDISTANCE,yStart+2);
        
        ObjectSetText("check_bot_1","On",10,TextFONT,clrLimeGreen);
        ObjectSet("check_bot_1", OBJPROP_XDISTANCE,xStart-68);
        ObjectSetText("check_bot_2","/",10,TextFONT,Gray);
        ObjectSet("check_bot_2", OBJPROP_XDISTANCE,xStart-48);
        ObjectSetText("check_bot_3","Off",10,TextFONT,clrRed);
        ObjectSet("check_bot_3", OBJPROP_XDISTANCE,xStart-38);
        }
        if(trr >= 0)
        ObjectSetText("check_bot_4", "Профит: " + DoubleToString(trr, 2) + "%", 10, TextFONT, clrLimeGreen);
        else if(trr >= -2)
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, White);
        else if(trr >= -4)
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, Yellow);
        else if(trr >= -6)
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, DarkOrange);
        else if(trr >= -8)
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, OrangeRed);
        else if(trr >= -10)
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, Red);
        else
        ObjectSetText("check_bot_4", "Просадка: " + DoubleToString(trr, 2) + "%", 10, TextFONT, Crimson);
        ObjectSet("check_bot_4", OBJPROP_XDISTANCE,xStart+200);
        }

        datetime lastDraw = 0; 
        if (TimeCurrent() - lastDraw > 5)  // обновлять раз в 5 секунд
        {
        GlobalVariableSet(BOT_NAME + "_Alive", TimeCurrent()); 
        DrawStatusDots();
        lastDraw = TimeCurrent();
        }
//-----------------------проверяем ботов активен или нет---------------------------------------

//-----------------------выводим время GMT-----------------------------------------------------
        for(int i=1; i<= 1; i++){string objectName="gmt_" + IntegerToString(i);
        if(ObjectFind(0,objectName)==-1){
        ObjectCreate(objectName,OBJ_LABEL,0,0,0);ObjectSetString(0,objectName,OBJPROP_TOOLTIP,"\n");ObjectSet(objectName, OBJPROP_CORNER,0);} 
        
        ObjectSetText("gmt_1","GMT:" +(TimeToStr(TimeGMT(),TIME_SECONDS)),10,TextFONT,White);
        ObjectSet("gmt_1", OBJPROP_XDISTANCE,170);
        ObjectSet("gmt_1",OBJPROP_YDISTANCE,50);}
//-----------------------выводим время GMT-----------------------------------------------------

//-----------------------вывод текста-----------------------------------------------------------
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
         }       
//-----------------------значения, переменные функции для панели info-------------------------

//-----------------------тейк и стоп раздельный------------------------------------------------
        if(takeprofit_stoploss==true){ 

        if((CountBuy_1()>=2&&CountSell_1()>=2)&&CountBuy()<CountSell_1()&&trr_tr<(-2.0)){
        takeprofit1=next_step_buy*40;//stoploss1=s_l;
        int tip,Ticket;
        double SL1,TP1,OOP1,OSL1,OTP1;
        double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL),SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
        if(stoploss1<STOPLEVEL) stoploss1=0;
        if(takeprofit1<STOPLEVEL) takeprofit1=0;
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS)){tip=OrderType();
        if(OrderSymbol()==Symbol()){OSL1=OrderStopLoss();OTP1=OrderTakeProfit();
        if((OSL1==0&&stoploss1!=0)||(OTP1==0&&takeprofit1!=0)){OOP1  =OrderOpenPrice();Ticket=OrderTicket();
        if((tip==OP_BUY || tip==OP_BUYSTOP || tip==OP_BUYLIMIT)){
        if(takeprofit1!=0) TP1=NormalizeDouble(OOP1+takeprofit1*Point,Digits);else TP1=OTP1;
        if(stoploss1!=0) SL1=NormalizeDouble(OOP1-(stoploss1+SPREAD)* Point,Digits);else SL1=OSL1;
        if(OrderModify(Ticket,OOP1,SL1,TP1,0,col_10)) Print("SetStop1 ",Ticket," SL1 ",OSL1," -> ",SL1,"   TP1 ",OTP1," -> ",TP1);
        else Print(Symbol()," Error SetStop1 ",GetLastError(),"  Ticket ",Ticket);}}}}}}

        if((CountBuy_1()>=2&&CountSell_1()>=2)&&CountBuy_1()>CountSell()&&trr_tr<(-2.0)){
        takeprofit=next_step_sell*40;//stoploss=s_l;
        int tip,Ticket;
        double SL2,TP2,OOP2,OSL2,OTP2;
        double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL),SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
        if(stoploss<STOPLEVEL) stoploss=0;
        if(takeprofit<STOPLEVEL) takeprofit=0;
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i, SELECT_BY_POS)){tip=OrderType();
        if(OrderSymbol()==Symbol()){OSL2=OrderStopLoss();OTP2=OrderTakeProfit();
        if((OSL2==0&&stoploss!=0)||(OTP2==0&&takeprofit!=0)){OOP2  =OrderOpenPrice();Ticket=OrderTicket();
        if((tip==OP_SELL || tip==OP_SELLSTOP || tip==OP_SELLLIMIT)){
        if(takeprofit!=0) TP2=NormalizeDouble(OOP2-takeprofit*Point,Digits);else TP2=OTP2;
        if(stoploss!=0) SL2=NormalizeDouble(OOP2+(stoploss+SPREAD)* Point,Digits);else SL2=OSL2;
        if(OrderModify(Ticket,OOP2,SL2,TP2,0,col_10))Print("SetStop2 ",Ticket," SL2 ",OSL2," -> ",SL2,"   TP2 ",OTP2," -> ",TP2); 
        else Print(Symbol()," Error SetStop2 ",GetLastError(),"  Ticket ",Ticket);}}}}}}}
//-----------------------конец тейк и стоп раздельный------------------------------------------

//-----------------------ВХОД------------------------------------------------------------------
        if(FileIsExist(filename,0)>=1){
//-----------------------master bot------------------------------------------------------------
        if(master==true){
        if(EURUSD_GBPUSD==true){ 
//-----------------------master bot str1-------------------------------------------------------     
        if(str1_time==1){ 
        if(OrdersTotal()<1&&FileIsExist(filename1,0)<1){
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

        if((t1_sec>=0&&t1_sec<2)||(t1_sec>=12&&t1_sec<14)||(t1_sec>=24&&t1_sec<26)||(t1_sec>=36&&t1_sec<38)||(t1_sec>=48&&t1_sec<50)){
        if(((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))>=delta_EURUSD_GBPUSD_MN1_strong1)&&(MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))<delta_EURUSD_GBPUSD_MN1_strong2){
        if(delta_EURUSD_MN1>delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=-1;
        if(delta_EURUSD_MN1<delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=1;   
        }}}}}
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
        if(OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3){
        if(FileIsExist(filename1,0)>=1){
        if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-1;
        if((AccountBalance()+bonus>AccountEquity())&&CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<step_sell_11&&Bid<Lowest_m) op=-11;
        if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=1; 
        if((AccountBalance()+bonus>AccountEquity())&&CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>step_buy_11&&Ask>Highest_m) op=11;
        }}}}
//-----------------------конец master bot str1-------------------------------------------------
      
//-----------------------master bot str2-------------------------------------------------------       
        if(str2_time==1){ 
        if(OrdersTotal()<1&&FileIsExist(filename2,0)<1){
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

        if((t1_sec>=0&&t1_sec<2)||(t1_sec>=12&&t1_sec<14)||(t1_sec>=24&&t1_sec<26)||(t1_sec>=36&&t1_sec<38)||(t1_sec>=48&&t1_sec<50)){
        if(((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))>=delta_EURUSD_GBPUSD_MN1_strong2)&&((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))<delta_EURUSD_GBPUSD_MN1_strong3)){
        if(delta_EURUSD_MN1>delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=-2;
        if(delta_EURUSD_MN1<delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=2; 
        }}}}}
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
        if(OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3){
        if(FileIsExist(filename2,0)>=1){
        if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-2;
        if((AccountBalance()+bonus>AccountEquity())&&CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<step_sell_11&&Bid<Lowest_m) op=-22;
        if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=2; 
        if((AccountBalance()+bonus>AccountEquity())&&CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>step_buy_11&&Ask>Highest_m) op=22;
        }}}}
//-----------------------конец master bot str2-------------------------------------------------
     
//-----------------------master bot str3-------------------------------------------------------         
        if(str3_time==1){ 
        if(OrdersTotal()<1&&FileIsExist(filename3,0)<1){
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

        if((t1_sec>=0&&t1_sec<2)||(t1_sec>=12&&t1_sec<14)||(t1_sec>=24&&t1_sec<26)||(t1_sec>=36&&t1_sec<38)||(t1_sec>=48&&t1_sec<50)){
        if(((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))>=delta_EURUSD_GBPUSD_MN1_strong3)&&((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))<delta_EURUSD_GBPUSD_MN1_strong4)){
        if(delta_EURUSD_MN1>delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=-3;
        if(delta_EURUSD_MN1<delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=3; 
        }}}}}
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
        if(OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3){
        if(FileIsExist(filename3,0)>=1){
        if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-3;
        if((AccountBalance()+bonus>AccountEquity())&&CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<step_sell_11&&Bid<Lowest_m) op=-33;
        if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=3; 
        if((AccountBalance()+bonus>AccountEquity())&&CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>step_buy_11&&Ask>Highest_m) op=33;
        }}}}
//-----------------------конец master bot str3------------------------------------------------- 
  
//-----------------------master bot str4-------------------------------------------------------         
        if(str4_time==1){
        if(OrdersTotal()<1&&FileIsExist(filename4,0)<1){
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

        if((t1_sec>=0&&t1_sec<2)||(t1_sec>=12&&t1_sec<14)||(t1_sec>=24&&t1_sec<26)||(t1_sec>=36&&t1_sec<38)||(t1_sec>=48&&t1_sec<50)){
        if(((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))>=delta_EURUSD_GBPUSD_MN1_strong4)&&((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))<delta_EURUSD_GBPUSD_MN1_strong5)){
        if(delta_EURUSD_MN1>delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=-4;
        if(delta_EURUSD_MN1<delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=4; 
        }}}}}
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
        if(OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3){
        if(FileIsExist(filename4,0)>=1){
        if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-4;
        if((AccountBalance()+bonus>AccountEquity())&&CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<step_sell_11&&Bid<Lowest_m) op=-44;
        if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=4; 
        if((AccountBalance()+bonus>AccountEquity())&&CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>step_buy_11&&Ask>Highest_m) op=44;
        }}}}
//-----------------------конец master bot str4-------------------------------------------------

//-----------------------master bot str5-------------------------------------------------------         
        if(str5_time==1){
        if(OrdersTotal()<1&&FileIsExist(filename5,0)<1){
        if((gmt_hour==00&&Minute()>20&&Minute()<=59)||(gmt_hour>=01&&gmt_hour<07)||(gmt_hour==07&&Minute()>10&&Minute()<=59)||(gmt_hour>=08&&gmt_hour<13)||(gmt_hour==13&&Minute()>=00&&Minute()<30)||(gmt_hour==13&&Minute()>40&&Minute()<=59)||(gmt_hour>=14&&gmt_hour<=23)||(gmt_hour==00&&Minute()>=00&&Minute()<10)){

        if((t1_sec>=0&&t1_sec<2)||(t1_sec>=12&&t1_sec<14)||(t1_sec>=24&&t1_sec<26)||(t1_sec>=36&&t1_sec<38)||(t1_sec>=48&&t1_sec<50)){
        if((MathAbs(delta_EURUSD_MN1-delta_GBPUSD_MN1))>=delta_EURUSD_GBPUSD_MN1_strong5){
        if(delta_EURUSD_MN1>delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=-5;
        if(delta_EURUSD_MN1<delta_GBPUSD_MN1&&(MathAbs(delta_EURUSD_D1-delta_GBPCHF_D1))>=delta_EURUSD_GBPUSD_average/delta_average)op=5; 
        }}}}}
        for(int i=0; i<OrdersTotal(); i++){
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
        if(OrderMagicNumber()==1||OrderMagicNumber()==2||OrderMagicNumber()==3){
        if(FileIsExist(filename5,0)>=1){
        if(((CountSell()<1&&CountBuy_2()>=1)||(OrdersTotal()>=1&&CountSell()==0&&CountBuy_2()>=1)||(CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1))) op=-5;
        if((AccountBalance()+bonus>AccountEquity())&&CountSell()>=1&&CountSell()<max_lot&&CountBuy()<1&&Bid<step_sell_11&&Bid<Lowest_m) op=-55;
        if(((CountBuy()<1&&CountSell_2()>=1)||(OrdersTotal()>=1&&CountBuy()==0&&CountSell_2()>=1)||(CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1))) op=5; 
        if((AccountBalance()+bonus>AccountEquity())&&CountBuy()>=1&&CountBuy()<max_lot&&CountSell()<1&&Ask>step_buy_11&&Ask>Highest_m) op=55;
        }}}}
//-----------------------конец master bot str5------------------------------------------------- 
        }}}
//-----------------------конец master bot------------------------------------------------------
      
//-----------------------cкрипт обнуляет стоплосс и тейкпрофит ордеров-------------------------
        if((CountBuy_1()<2||CountSell_1()<2)&&(CountBuy_1()!=0&&CountSell_1()!=0)){  
        int Ticket;
        double OTP,OOP; //OSL,
        RefreshRates();
        for(int i=0; i<OrdersTotal(); i++){  
        if(OrderSelect(i,SELECT_BY_POS)){  
        //OSL=NormalizeDouble(OrderStopLoss(),Digits);
        OTP=NormalizeDouble(OrderTakeProfit(),Digits);
        OOP=NormalizeDouble(OrderOpenPrice(),Digits);
        Ticket=OrderTicket();
        if(OTP!=0){//OSL!=0||
        ObjectsDeleteAll(0,OBJ_ARROW);
        ObjectsDeleteAll(0,"modified"); 
        event_37=1;
        alert_0=StringConcatenate("Снимаю тейк-профиты");       
        if(!OrderModify(Ticket,OOP,0,0,0,col_11))
        Alert(Symbol()," ошибка Modify ",GetLastError()," Ticket ",Ticket);
        }}}}
//-----------------------конец cкрипт обнуляет стоплосс и тейкпрофит ордеров-------------------
      
//-----------------------конец ВХОД------------------------------------------------------------
   
//-----------------------закрываем по профиту-------------------------------------------------- 
        if(close_profit==true){ 
//--------------------------------------------------------------------------------------------- 
        if(OrdersTotal()>=1&&c1!=0&&(CountBuy_1()>=1&&CountSell_1()>=1)&&HelpAccount!=0&&(AccountEquity()>=(HelpAccount+(c1)))&&AccountEquity()>=(HelpAccount+c888*par5)) CloseAll_pr();}
//-----------------------Конец закрываем по профиту--------------------------------------------
   
//-----------------------открытие позиций------------------------------------------------------ 
//-----------------------следующие входы buy---------------------------------------------------
        if(op==1){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){           
        if(main.OrderProfitPoint(t_b)<=-g_next_step_buy && CooldownOk(true, 0)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st1*par5,-1,0,0,(string)order_magic);     
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------
        if(op==2){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){           
        if(main.OrderProfitPoint(t_b)<=-g_next_step_buy && CooldownOk(true, 1)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st2*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------
        if(op==3){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){           
        if(main.OrderProfitPoint(t_b)<=-g_next_step_buy && CooldownOk(true, 2)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st3*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------
        if(op==4){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){           
        if(main.OrderProfitPoint(t_b)<=-g_next_step_buy && CooldownOk(true, 3)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st4*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------
        if(op==5){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){           
        if(main.OrderProfitPoint(t_b)<=-g_next_step_buy && CooldownOk(true, 4)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st5*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//-----------------------конец следующие входы buy---------------------------------------------

//-----------------------следующие входы sell--------------------------------------------------   
        if(op==-1){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(main.OrderProfitPoint(t_s)<=-g_next_step_sell && CooldownOk(false, 0)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st1*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------  
        if(op==-2){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(main.OrderProfitPoint(t_s)<=-g_next_step_sell && CooldownOk(false, 1)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st2*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------  
        if(op==-3){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(main.OrderProfitPoint(t_s)<=-g_next_step_sell && CooldownOk(false, 2)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st3*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------  
        if(op==-4){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(main.OrderProfitPoint(t_s)<=-g_next_step_sell && CooldownOk(false, 3)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st4*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------   
        if(op==-5){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(main.OrderProfitPoint(t_s)<=-g_next_step_sell && CooldownOk(false, 4)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st5*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//-----------------------конец слeдующие входы sell--------------------------------------------

//-----------------------конец слудующий вход buy----------------------------------------------    
        if(op==11){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){
        if(Ask>step_buy_11 && CooldownOk(true, 0)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st1*par5,-1,0,0,(string)order_magic);     
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------   
        if(op==22){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){ 
        if(Ask>step_buy_11 && CooldownOk(true, 1)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st2*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------   
        if(op==33){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){ 
        if(Ask>step_buy_11 && CooldownOk(true, 2)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st3*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------   
        if(op==44){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){
        if(Ask>step_buy_11 && CooldownOk(true, 3)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st4*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//---------------------------------------------------------------------------------------------   
        if(op==55){int t_b=main.getLastOrderTicket(OP_BUY,ORDER_LAST);
        if(main.OrderSelect(t_b)){
        if(Ask>step_buy_11 && CooldownOk(true, 4)){lot=getLot((main.orders[OP_BUY]));main.OrderSend(OP_BUY,lot*st5*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }}}
//-----------------------конец слудующий вход buy----------------------------------------------

//-----------------------следующие входы sell--------------------------------------------------           
        if(op==-11){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(Bid<step_sell_11 && CooldownOk(false, 0)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st1*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------         
        if(op==-22){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(Bid<step_sell_11 && CooldownOk(false, 1)){lot=getLot((main.orders[OP_SELL])); main.OrderSend(OP_SELL,lot*st2*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------          
        if(op==-33){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(Bid<step_sell_11 && CooldownOk(false, 2)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st3*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------          
        if(op==-44){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(Bid<step_sell_11 && CooldownOk(false, 3)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st4*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//---------------------------------------------------------------------------------------------          
        if(op==-55){int t_s=main.getLastOrderTicket(OP_SELL,ORDER_LAST);
        if(main.OrderSelect(t_s)){
        if(Bid<step_sell_11 && CooldownOk(false, 4)){lot=getLot((main.orders[OP_SELL]));main.OrderSend(OP_SELL,lot*st5*par5,-1,0,0,(string)order_magic);
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }}}
//-----------------------конец следующий вход sell---------------------------------------------
//-----------------------конец открытие позиций------------------------------------------------

//-----------------------ФУНКЦИЯ ЗАКРЫТИЯ ПОЛОЖИТЕЛЬНЫХ ОРДЕРОВ-------------------------------
        if(op==999){int ticket=0;RefreshRates();
        for(int cnt=0; cnt<OrdersTotal(); cnt++){
        ticket=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
        if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_SELL&&OrderOpenPrice()>Ask){
        ticket=OrderClose(OrderTicket(),OrderLots(),Ask,0,col_6);
//-----------------------рисуем линию по событию----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(), OBJ_VLINE, 0,  Time[0], 0, 0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");  // отключаем всплывающую подсказку
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_6);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1); 
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);} 
        LastActiontime_vline=Time[0];}      
//-----------------------рисуем линию по событию----------------------------------------------
//-----------------------сообщения в панель---------------------------------------------------       
         alert_0=StringConcatenate("Частично закрываю Sell");
//-----------------------сообщения в панель---------------------------------------------------
        }}}
//--------------------------------------------------------------------------------------------
        if(op==-999){int ticket=0;RefreshRates();
        for(int cnt=0; cnt<OrdersTotal(); cnt++){
        ticket=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
        if(OrderSymbol()==Symbol()&&OrderMagicNumber()==order_magic&&OrderType()==OP_BUY&&Bid>OrderOpenPrice()){
        ticket=OrderClose(OrderTicket(),OrderLots(),Bid,0,col_6);
//-----------------------рисуем линию по событию----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(), OBJ_VLINE, 0,  Time[0], 0, 0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");  // отключаем всплывающую подсказку
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_6);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1); 
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);}
        LastActiontime_vline=Time[0];}           
//-----------------------рисуем линию по событию----------------------------------------------
//-----------------------сообщения в панель---------------------------------------------------      
        alert_0=StringConcatenate("Частично закрываю Buy");
//-----------------------сообщения в панель---------------------------------------------------
        }}}    
//-----------------------КОНЕЦ ФУНКЦИЯ ЗАКРЫТИЯ ПОЛОЖИТЕЛЬНЫХ ОРДЕРОВ-------------------------

//-----------------------ФУНКЦИЯ ЗАКРЫТИЯ BUY/SELL ОРДЕРОВ------------------------------------  
//-----------------------закрываем все sell---------------------------------------------------
        if(op==777){for(int i=OrdersTotal()-1; i>=0; i--){
        if(OrderSelect(i,SELECT_BY_POS)){
        if(OrderMagicNumber()==order_magic&&OrderSymbol()==Symbol()){          
        if(OrderType()==OP_SELL){
        if(!OrderClose(OrderTicket(), OrderLots(), Ask, slippage))printf("SELL Order Close Error", GetLastError()); 
//-----------------------рисуем линию по событию-----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(),OBJ_VLINE,0,Time[0],0,0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_3);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);}
        LastActiontime_vline=Time[0];}          
//-----------------------рисуем линию по событию-----------------------------------------------
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        if(telegram==true&&CountSell()<=0){
        SendTelegramMessage(BuildEquityMessage_8());}
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        }}}}}
//-----------------------конец закрываем все sell---------------------------------------------
//-----------------------закрываем все buy----------------------------------------------------
        if(op==-777){for(int i=OrdersTotal()-1;i>=0;i--){
        if(OrderSelect(i,SELECT_BY_POS)){
        if(OrderMagicNumber()==order_magic&&OrderSymbol()==Symbol()){
        if(OrderType()==OP_BUY){
        if(!OrderClose(OrderTicket(), OrderLots(), Bid, slippage))printf("BUY Order Close Error", GetLastError());
//-----------------------рисуем линию по событию-----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(),OBJ_VLINE,0,Time[0],0,0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_13);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);}
        LastActiontime_vline=Time[0];}          
//-----------------------рисуем линию по событию----------------------------------------------     
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        if(telegram==true&&CountBuy()<=0){
        SendTelegramMessage(BuildEquityMessage_7());}
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        }}}}}
//-----------------------конец закрываем все buy------------------------------------------------ 
//-----------------------КОНЕЦ ФУНКЦИЯ ЗАКРЫТИЯ BUY/SELL ОРДЕРОВ--------------------------------
       
        lot=(lot1);                                             // первый лот равен lot1   

//-----------------------открытие позиций первый вход-------------------------------------------

//-----------------------первый вход buy--------------------------------------------------------
        if((op==1||op==11)&&main.orders[OP_BUY]==0){main.OrderSend(OP_BUY,lot*st1*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename1,FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content1);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------                
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }
//----------------------------------------------------------------------------------------------
        if((op==2||op==22)&&main.orders[OP_BUY]==0){main.OrderSend(OP_BUY,lot*st2*par5,-1,0,0,(string)order_magic);     
//-----------------------отправка сообщений в телеграмм-----------------------------------------
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename2,FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content2);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }
//----------------------------------------------------------------------------------------------
        if((op==3||op==33)&&main.orders[OP_BUY]==0){main.OrderSend(OP_BUY,lot*st3*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename3,FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content3);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------      
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }
//----------------------------------------------------------------------------------------------
        if((op==4||op==44)&&main.orders[OP_BUY]==0){main.OrderSend(OP_BUY,lot*st4*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename4,FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content4);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------     
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }
//----------------------------------------------------------------------------------------------
        if((op==5||op==55)&&main.orders[OP_BUY]==0){main.OrderSend(OP_BUY,lot*st5*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename5,FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content5);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------     
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_buy());} }
//-----------------------конец первый вход buy--------------------------------------------------

//-----------------------первый вход sell-------------------------------------------------------
        if((op==-1||op==-11)&&main.orders[OP_SELL]==0){main.OrderSend(OP_SELL,lot*st1*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename1, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content1);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии--------------------------------------------- 
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }
//----------------------------------------------------------------------------------------------
        if((op==-2||op==-22)&&main.orders[OP_SELL]==0){main.OrderSend(OP_SELL,lot*st2*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename2, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content2);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }
//----------------------------------------------------------------------------------------------
        if((op==-3||op==-33)&&main.orders[OP_SELL]==0){main.OrderSend(OP_SELL,lot*st3*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename3, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content3);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии--------------------------------------------- 
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }
//----------------------------------------------------------------------------------------------
        if((op==-4||op==-44)&&main.orders[OP_SELL]==0){main.OrderSend(OP_SELL,lot*st4*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename4, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content4);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------  
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }
//----------------------------------------------------------------------------------------------
        if((op==-5||op==-55)&&main.orders[OP_SELL]==0){main.OrderSend(OP_SELL,lot*st5*par5,-1,0,0,(string)order_magic);
//-----------------------записываем номер стратегии---------------------------------------------       
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename5, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content5);FileClose(fileHandle);}}
//-----------------------записываем номер стратегии---------------------------------------------  
        if(telegram==true){SendTelegramMessage(BuildEquityMessage_sell());} }
//-----------------------конец первый вход sell-------------------------------------------------

//-----------------------конец открытие позиций первый вход------------------------------------
    
    
//-----------------------записываем номер стратегии если нет файла(ошибка)---------------------     
        if(OrdersTotal()>=1&&(tm!=-1&&tm+10<(TimeCurrent()))&&(FileIsExist(filename1,0)<=0&&FileIsExist(filename2,0)<=0&&FileIsExist(filename3,0)<=0&&FileIsExist(filename4,0)<=0&&FileIsExist(filename5,0)<=0)){      
        string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);{int fileHandle=FileOpen(filename5, FILE_WRITE|FILE_TXT);
        if(fileHandle != INVALID_HANDLE){FileWriteString(fileHandle, content5);FileClose(fileHandle);}}}
//-----------------------записываем номер стратегии если нет файла(ошибка)---------------------


//---------------------------------------------------------------------------------------------
        }
//---------------------------------------------------------------------------------------------
        double getLot(int i){
        int c=ArraySize(lots);
        if(c==0)return 0;
        if(i<0)i=0;
        if(i>=c-1)i=c-1;
        return lots[i];}
//-------------------------закрытие по времени, ордерам, эквити--------------------------------
        int Orders_Total(){int num_orders=0;
        bool res;for(int i= OrdersTotal()-1;i>=0;i--){
        res=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
        if( res )num_orders++;}return(num_orders);}
//-------------------------закрытие по времени, ордерам, эквити--------------------------------

//-------------------------закрываем все ордера без учета magic--------------------------------
        double CloseAll(){  
        bool error=true;int nn=0,OT,Ticket,j;double loss=0;while(true){
        for(j=OrdersTotal()-1; j>=0; j--){
        if(OrderSelect(j, SELECT_BY_POS)){OT=OrderType();Ticket=OrderTicket();
        if(OT>1)error=OrderDelete(Ticket);
        if(OT==OP_BUY){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();}
        if(OT==OP_SELL){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();} 
//-----------------------рисуем линию по событию-----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(), OBJ_VLINE, 0,  Time[0], 0, 0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");  // отключаем всплывающую подсказку
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_9);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);  
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);
        LastActiontime_vline=Time[0];}              
//-----------------------рисуем линию по событию-----------------------------------------------
//-----------------------сообщения в панель----------------------------------------------------        
        if(lastlos>=0) alert_0=StringConcatenate("Трал эквити, ПРОФИТ: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
        if(lastlos<0) alert_0=StringConcatenate("Трал эквити, УБЫТОК: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
//-----------------------сообщения в панель----------------------------------------------------
//-----------------------отправка сообщений в телеграмм----------------------------------------
        if(telegram==true&&OrdersTotal()<=0){SendTelegramMessage(BuildEquityMessage_3());}           
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        }pre_OrdersTotal=0;
        HelpAccount=0;HelpAccount777_down=0;HelpAccount_down=0;FileDelete("close_all.txt");FileDelete("str1.txt");FileDelete("str2.txt");FileDelete("str3.txt");FileDelete("str4.txt");FileDelete("str5.txt");event_34=1;ObjectsDeleteAll(0, OBJ_ARROW);            
        if(OrdersTotal()<=0)count_close++;}}int n=0;for(j=0; j<OrdersTotal(); j++){
        if(OrderSelect(j, SELECT_BY_POS)){
        OT=OrderType();n++;}}if(n==0)break;nn++;if(nn>10){Alert(Symbol()," Не удалось закрыть все сделки, осталось еще ",n);return(loss);}
        Sleep(1000);RefreshRates();}return(loss);}
//-------------------------конец закрываем все ордера без учета magic---------------------------

//-------------------------закрываем все ордера без учета magic по профиту----------------------
        double CloseAll_tr(){  
        bool error=true;int nn=0,OT,Ticket,j;double loss=0;while(true){
        for(j=OrdersTotal()-1; j>=0; j--){
        if(OrderSelect(j, SELECT_BY_POS)){OT=OrderType();Ticket=OrderTicket();
        if(OT>1)error=OrderDelete(Ticket);
        if(OT==OP_BUY){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();}
        if(OT==OP_SELL){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();} 
//-----------------------рисуем линию по событию-----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(), OBJ_VLINE, 0,  Time[0], 0, 0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");  // отключаем всплывающую подсказку
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_9);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);  
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);
        LastActiontime_vline=Time[0];}              
//-----------------------рисуем линию по событию-----------------------------------------------
//-----------------------сообщения в панель----------------------------------------------------        
        if(lastlos>=0) alert_0=StringConcatenate("Трал динам., ПРОФИТ: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
        if(lastlos<0) alert_0=StringConcatenate("Трал динам., УБЫТОК: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
//-----------------------сообщения в панель----------------------------------------------------
//-----------------------отправка сообщений в телеграмм----------------------------------------
        if(telegram==true&&OrdersTotal()<=0){SendTelegramMessage(BuildEquityMessage_4());} 
//-----------------------отправка сообщений в телеграмм-----------------------------------------
        }pre_OrdersTotal=0;
        HelpAccount=0;HelpAccount777_down=0;HelpAccount_down=0;FileDelete("close_all.txt");FileDelete("str1.txt");FileDelete("str2.txt");FileDelete("str3.txt");FileDelete("str4.txt");FileDelete("str5.txt");event_36=1;ObjectsDeleteAll(0, OBJ_ARROW);            
        if(OrdersTotal()<=0)count_close++;}}int n=0;for(j=0; j<OrdersTotal(); j++){
        if(OrderSelect(j, SELECT_BY_POS)){
        OT=OrderType();n++;}}if(n==0)break;nn++;if(nn>10){Alert(Symbol()," Не удалось закрыть все сделки, осталось еще ",n);return(loss);}
        Sleep(1000);RefreshRates();}return(loss);}
//-------------------------конец закрываем все ордера без учета magic---------------------------

//-------------------------закрываем все ордера без учета magic по профиту----------------------
        double CloseAll_pr(){   
        bool error=true;int nn=0,OT,Ticket,j;double loss=0;while(true){
        for(j=OrdersTotal()-1; j>=0; j--){
        if(OrderSelect(j, SELECT_BY_POS)){OT=OrderType();Ticket=OrderTicket();
        if(OT>1)error=OrderDelete(Ticket);
        if(OT==OP_BUY){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();}
        if(OT==OP_SELL){error=OrderClose(Ticket,OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),(int)MarketInfo(OrderSymbol(),MODE_DIGITS)),slippage,col_13);
        if(error)loss+=OrderProfit();} 
//-----------------------рисуем линию по событию-----------------------------------------------
        if(info_0==true){
        if(LastActiontime_vline!=Time[0]){
        ObjectCreate("line"+(string)TimeCurrent(), OBJ_VLINE, 0,  Time[0], 0, 0);
        ObjectSetString(0,"line"+(string)TimeCurrent(),OBJPROP_TOOLTIP,"\n");  // отключаем всплывающую подсказку
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_COLOR,col_9);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_WIDTH,1);  
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_STYLE,3);
        ObjectSet("line"+(string)TimeCurrent(),OBJPROP_BACK,true);
        LastActiontime_vline=Time[0];}              
//-----------------------рисуем линию по событию-----------------------------------------------
//-----------------------сообщения в панель------------------------------------------------------       
        if(lastlos>=0)alert_0=StringConcatenate("Закр. профит, ПРОФИТ: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
        if(lastlos<0)alert_0=StringConcatenate("Закр. профит, УБЫТОК: ",(DoubleToStr(NormalizeDouble(lastlos,2),2)),"$");
//-----------------------сообщения в панель------------------------------------------------------
//-----------------------отправка сообщений в телеграмм------------------------------------------
        if(telegram==true&&OrdersTotal()<=0){SendTelegramMessage(BuildEquityMessage_5());} 
//-----------------------отправка сообщений в телеграмм------------------------------------------
        }pre_OrdersTotal=0;
        HelpAccount=0;HelpAccount777_down=0;HelpAccount_down=0;FileDelete("close_all.txt");FileDelete("str1.txt");FileDelete("str2.txt");FileDelete("str3.txt");FileDelete("str4.txt");FileDelete("str5.txt");event_35=1;ObjectsDeleteAll(0, OBJ_ARROW);
        if(OrdersTotal()<=0)count_close++;            
        ObjectsDeleteAll(0, OBJ_ARROW);}}
        int n=0;for(j=0; j<OrdersTotal(); j++){if(OrderSelect(j, SELECT_BY_POS)){OT=OrderType();n++;}}if(n==0)break;nn++;
        if(nn>10){Alert(Symbol()," Не удалось закрыть все сделки, осталось еще ",n);return(loss);}
        Sleep(1000);RefreshRates();}return(loss);}
//-------------------------конец закрываем все ордера без учета magic по профиту-----------------
//7430
//8538
//11854
