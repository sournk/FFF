//+------------------------------------------------------------------+
//|                                                  FFF-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CAZSBot.mqh"


input  group                    "1. ENTRY (ENT)"
       ENUM_MM_TYPE             Inp_ENT_MMT                                             = ENUM_MM_TYPE_FIXED_LOT;       // ENT_MMT: Money Managment Type
input  double                   Inp_ENT_MMV                                             = 0.01;                         // ENT_MMV: Lot Size

input  group                    "2. SIGNAL (SIG)"
input  uint                     Inp_SIG_RBC                                             = 5;                    // SIG_RBC: Range Bar Count
input  uint                     Inp_SIG_SDC                                             = 20;                   // SIG_SDC: Standart Deviation Bar Count
input  double                   Inp_SIG_SGM                                             = 2.0;                  // SIG_SGM: Threshhold Sigma for ADR&Volumes
input  uint                     Inp_SIG_ADR_LEN                                         = 14;                   // SIG_ADR_LEN: ADR Length
input  ENUM_APPLIED_VOLUME      Inp_SIG_VOL_APL                                         = VOLUME_TICK;          // SIG_VOL_APL: Applied Volume



input  group                    "3. FILTER (FIL)"


input  group                    "4. EXIT (EXT)"


input  group                    "5. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                                              = 20241230;             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "DSAZS";              // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                                           = "";                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                                           = "";                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                     Inp_MS_PHV                                              = false;                // MS_PHV: Print Historical Event Data
sinput bool                     Inp_MS_COM_EN                                           = true;                 // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                     Inp_MS_COM_IS                                           = 5;                    // MS_COM_IS: Comment Interval, Sec
sinput bool                     Inp_MS_COM_CW                                           = false;                // MS_COM_EW: Comment Custom Window


CAZSBot                         bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CAZSBotInputs inputs;
  inputs.ENT_MMT            = Inp_ENT_MMT;
  inputs.ENT_MMV            = Inp_ENT_MMV;
  
  inputs.SIG_RBC            = Inp_SIG_RBC;
  inputs.SIG_SDC            = Inp_SIG_SDC;
  inputs.SIG_SGM            = Inp_SIG_SGM;
  
  
  bot.CommentEnable         = Inp_MS_COM_EN;
  bot.CommentIntervalSec    = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  bot.OnDeinit(reason);
  EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}