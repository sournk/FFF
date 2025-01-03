//+------------------------------------------------------------------+
//|                                                      CAZSBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
#include <Math\Stat\Math.mqh>
#include <Trade\OrderInfo.mqh>

//#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh> 

#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
//#include "Include\DKStdLib\Common\DKStdLib.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CAZSInputs.mqh"


class CADZRates {
public:
  MqlRates     Rate;
  double       Volume;
  double       VolumeThreshold;
  double       ADR;
  double       ADRThreshold;
};

class CAZSBot : public CDKBaseBot<CAZSBotInputs> {
public: // SETTINGS

protected:
  CHashMap <datetime, CADZRates*> Data;
  
  datetime                   LastSignalDTVol;
  datetime                   LastSignalDTADR;
  
public:
  // Constructor & init
  //void                       CAZSBot::CAZSBot(void);
  void                       CAZSBot::~CAZSBot(void);
  void                       CAZSBot::InitChild();
  bool                       CAZSBot::Check(void);

  // Event Handlers
  void                       CAZSBot::OnDeinit(const int reason);
  void                       CAZSBot::OnTick(void);
  void                       CAZSBot::OnTrade(void);
  void                       CAZSBot::OnTimer(void);
  double                     CAZSBot::OnTester(void);
  void                       CAZSBot::OnBar(void);
  
  void                       CAZSBot::OnOrderPlaced(ulong _order);
  void                       CAZSBot::OnOrderModified(ulong _order);
  void                       CAZSBot::OnOrderDeleted(ulong _order);
  void                       CAZSBot::OnOrderExpired(ulong _order);
  void                       CAZSBot::OnOrderTriggered(ulong _order);

  void                       CAZSBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CAZSBot::OnPositionStopLoss(ulong _position, ulong _deal);
  void                       CAZSBot::OnPositionTakeProfit(ulong _position, ulong _deal);
  void                       CAZSBot::OnPositionClosed(ulong _position, ulong _deal);
  void                       CAZSBot::OnPositionCloseBy(ulong _position, ulong _deal);
  void                       CAZSBot::OnPositionModified(ulong _position);  
  
  // Bot's logic
  void                       CAZSBot::UpdateComment(const bool _ignore_interval = false);
  
  ulong                      CAZSBot::OpenPosOnSignal();
  
  void                       CAZSBot::Draw();
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CAZSBot::~CAZSBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CAZSBot::InitChild() {
  LastSignalDTVol = 0;
  LastSignalDTADR = 0;
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CAZSBot::Check(void) {
  if(!CDKBaseBot<CAZSBotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }

  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CAZSBot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CAZSBot::OnTick(void) {
  CDKBaseBot<CAZSBotInputs>::OnTick(); // Check new bar and show comment
  
  // 03. Channels update
  bool need_update = false;

  // 06. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CAZSBot::OnBar(void) {
  OpenPosOnSignal();
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CAZSBot::OnTrade(void) {
  CDKBaseBot<CAZSBotInputs>::OnTrade();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CAZSBot::OnTimer(void) {
  CDKBaseBot<CAZSBotInputs>::OnTimer();
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CAZSBot::OnTester(void) {
  return 0;
}

void CAZSBot::OnOrderPlaced(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnOrderModified(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnOrderDeleted(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnOrderExpired(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnOrderTriggered(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnPositionClosed(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnPositionCloseBy(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CAZSBot::OnPositionModified(ulong _position){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}  
  
//+------------------------------------------------------------------+
//| OnPositionOpened
//+------------------------------------------------------------------+
void CAZSBot::OnPositionOpened(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CAZSBot::OnPositionStopLoss(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CAZSBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CAZSBot::OpenPosOnSignal() {
  int start = 1;
  double buf_vol[]; 
  ArraySetAsSeries(buf_vol, true);
  if(CopyBuffer(Inputs.IndVolumeHndl, 0, start, Inputs.SIG_SDC, buf_vol) <= 0) {
    Logger.Error(LSF("CopyBuffer(Volumes) failed"));
    return 0;
  }

  double buf_adr[]; 
  ArraySetAsSeries(buf_adr, true);
  if(CopyBuffer(Inputs.IndADRHndl, 0, start, Inputs.SIG_SDC, buf_adr) <= 0) {
    Logger.Error(LSF("CopyBuffer(ADR) failed"));
    return 0;
  }
  
  MqlRates rates[];
  ArraySetAsSeries(rates, true);
  if(CopyRates(Sym.Name(), TF, start, 1, rates) <= 0){
    Logger.Error(LSF("CopyRates() failed"));
    return 0;
  }

  double mean_vol = MathMean(buf_vol);
  double mean_adr = MathMean(buf_adr);

  double stddiv_vol = MathStandardDeviation(buf_vol);
  double stddiv_adr = MathStandardDeviation(buf_adr);
  
  double threshhold_vol = mean_vol + Inputs.SIG_SGM * stddiv_vol;
  double threshhold_adr = mean_adr + Inputs.SIG_SGM * stddiv_adr;
  
  CADZRates* data = new CADZRates();
  data.Rate = rates[0];
  data.Volume = buf_vol[0];
  data.VolumeThreshold = threshhold_vol;
  data.ADR = buf_adr[0];
  data.ADRThreshold = threshhold_adr;
  
  if(data.Volume >= data.VolumeThreshold) {
    string name = StringFormat("%s_VOL_TH_%d", Logger.Name, data.Rate.time);
    CChartObjectArrow arrow;    
    arrow.Create(0, name, 2, data.Rate.time, data.VolumeThreshold, char(159));
    arrow.Detach();
  }
  
  if(data.ADR >= data.ADRThreshold) {
    string name = StringFormat("%s_ADR_TH_%d", Logger.Name, data.Rate.time);
    CChartObjectArrow arrow;    
    arrow.Create(0, name, 1, data.Rate.time, data.ADRThreshold, char(159));
    arrow.Detach();
  }
  
  //CChartObjectText label;
  //label.Create(0, name, 2, data.Rate.time, data.VolumeThreshold);
  //label.Description("——");
  //label.Anchor(ANCHOR_CENTER);
  //label.Color(clrRed);
  //label.Detach();      
  
  
  // Leave only Inputs.SIG_RBC values in bufs
  ArrayRemove(buf_vol, 0, Inputs.SIG_SDC-Inputs.SIG_RBC);
  ArrayRemove(buf_adr, 0, Inputs.SIG_SDC-Inputs.SIG_RBC);
  double highest_vol = MathMax(buf_vol);
  double highest_adr = MathMax(buf_adr);

  Logger.Debug(LSF(StringFormat("THRESHOLD_VOL=MEAN(%d)+σ*STDDIV(%d)=%0.0f + %0.2f*%0.0f = %0.0f %s HIGHEST_VOL(%d)=%0.0f", 
                                Inputs.SIG_SDC,
                                Inputs.SIG_SDC,
                                mean_vol,
                                Inputs.SIG_SGM,
                                stddiv_vol,
                                threshhold_vol,
                                (threshhold_vol < highest_vol) ? "<" : ">=",
                                Inputs.SIG_RBC,
                                highest_vol)));

  Logger.Debug(LSF(StringFormat("THRESHOLD_ADR=MEAN(%d)+σ*STDDIV(%d)=%s + %0.2f*%s=%s %s HIGHEST_VOL(%d)=%s", 
                                Inputs.SIG_SDC,
                                Inputs.SIG_SDC,
                                Sym.PriceFormat(mean_adr),
                                Inputs.SIG_SGM,                                
                                Sym.PriceFormat(stddiv_adr),
                                Sym.PriceFormat(threshhold_adr),
                                (threshhold_adr < highest_adr) ? "<" : ">=",
                                Inputs.SIG_RBC,
                                Sym.PriceFormat(highest_adr))));

  
  if(highest_vol >= threshhold_vol) {
    Logger.Info(LSF(StringFormat("New extreme Volume detected: HIGHEST_VOL(%d)=%0.0f >= THRESHOLD_VOL=%0.0f",
                                 Inputs.SIG_RBC,
                                 highest_vol,
                                 threshhold_vol)));
  }

  if(highest_adr >= threshhold_adr) {
    Logger.Info(LSF(StringFormat("New extreme ADR detected: HIGHEST_ADR(%d)=%s >= THRESHOLD_ADR=%s",
                                 Inputs.SIG_RBC,
                                 Sym.PriceFormat(highest_adr),
                                 Sym.PriceFormat(threshhold_adr))));
  }

  if(highest_vol >= threshhold_vol && highest_adr >= threshhold_adr) {
    ArraySetAsSeries(buf_vol, true);
    ArraySetAsSeries(buf_adr, true);
    int highest_vol_idx = ArrayMaximum(buf_vol);
    int highest_adr_idx = ArrayMaximum(buf_adr);
    if(iTime(Sym.Name(), TF, highest_vol_idx+start) > LastSignalDTVol ||
       iTime(Sym.Name(), TF, highest_adr_idx+start) > LastSignalDTADR) {
      LastSignalDTVol = iTime(Sym.Name(), TF, highest_vol_idx+start);
      LastSignalDTADR = iTime(Sym.Name(), TF, highest_adr_idx+start);
      Draw();
      Logger.Warn(LSF(StringFormat("New signal: EXTREME_VOL_DT=%s; EXTREME_ADR_DT=%s",
                                   TimeToString(LastSignalDTVol),
                                   TimeToString(LastSignalDTADR))));
    }
  }

  return 0;
}

void CAZSBot::Draw() {
  if(LastSignalDTVol <= 0 || LastSignalDTADR <= 0) return;
  
  MqlRates rates[];
  if(CopyRates(Sym.Name(), TF, MathMin(LastSignalDTVol, LastSignalDTADR), MathMax(LastSignalDTVol, LastSignalDTADR), rates) <= 0)
    return;
    
  int high_idx = 0;
  int low_idx = 0;
  for(int i=1;i<ArraySize(rates);i++) {
    if(rates[i].high > rates[high_idx].high) high_idx = i;
    if(rates[i].low < rates[low_idx].low) low_idx = i;
  }
  
  CChartObjectTrend line;
  line.Create(0, "LUP", 0, rates[high_idx].time, rates[high_idx].high, rates[high_idx].time+PeriodSeconds(TF), rates[high_idx].high);
  line.RayRight(true);
  line.Detach();
  
  line.Create(0, "LUD", 0, rates[low_idx].time, rates[low_idx].low, rates[low_idx].time+PeriodSeconds(TF), rates[low_idx].low);
  line.RayRight(true);
  line.Detach();
}
