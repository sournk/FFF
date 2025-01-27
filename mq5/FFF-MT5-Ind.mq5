//+------------------------------------------------------------------+
//|                                                  FFF-MT5-Ind.mq5 |
//|                                                  Denis Kislitsyn |
//|                          https://www.kislitsyn.me/personal/algo/ |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://www.kislitsyn.me/personal/algo/"
#property version   "1.02"

#property description "Fractal Fibo FVG Indicator by https://www.mql5.com/en/job/230436"
#property description "1.02: Release with no limits"
#property description "1.01:"
#property description "  [+] GUI_FRC: Draw Fractal"
#property description "  [+] ALR_PNC: Push Notification Enabled"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "FFF FVG High"
#property indicator_type1   DRAW_NONE
#property indicator_width1  1

#property indicator_label2  "FFF FVG Low"
#property indicator_type2   DRAW_NONE
#property indicator_width2  1

#property indicator_label3  "FFF Fractal High"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGreen
#property indicator_width3  1

#property indicator_label4  "FFF Fractal Low"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_width4  1


#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\ChartObjects\CDKChartObjectFibo.mqh"
#include <ChartObjects\ChartObjectsShapes.mqh>


input group    "1. INDICATOR (IND)"
input uint     Inp_IND_DPH       = 500;       // IND_DTH: Start Depth, bars
input double   Inp_IND_LEV       = 0.5;       // IND_LEV: Fibo threshold for FVG
input bool     Inp_IND_SOD       = 0.5;       // IND_SOD: Skip the tops of fractals in One Direction

input group    "2. GUI"
input bool     Inp_GUI_FIB       = true;      // GUI_FIB: Draw Fibo
input bool     Inp_GUI_FVG       = true;      // GUI_FVG: Draw FVG
input bool     Inp_GUI_FRC       = false;     // GUI_FRC: Draw Fractals
input color    Inp_GUI_COL_BUL   = clrGreen;  // GUI_COL_BUL: Color for Bullish
input color    Inp_GUI_COL_BER   = clrRed;    // GUI_COL_BER: Color for Bearish


input group    "3. ALERTS (ALR)"
input bool     Inp_ALR_ENB       = true;      // ALR_ENB: Show alerts
input bool     Inp_ALR_PNE       = true;      // ALR_PNC: Push Notification Enabled
input LogLevel Inp_ALR_LL        = ERROR;     // ALR_LL: Log Level
      string   Inp_ALR_PRF       = "FFF";     // ALR_PRF: Prefix
      long     Inp_PublishDate             = 20250103;                           // Date of publish
      int      Inp_DurationBeforeExpireSec = 7*24*60*60;                         // Duration before expire, sec
      


//--- indicator buffers
double         buf_fvg_h[];
double         buf_fvg_l[];
double         buf_frac_h[];
double         buf_frac_l[];

int            ind_frac_hdnl;

datetime       last_bar_dt;
CDKLogger      logger;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()  {
  logger.Init(Inp_ALR_PRF, Inp_ALR_LL);
  
  //if(TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
  //  logger.Critical("Test version is expired", true);
  //  return(INIT_FAILED);
  //}    
  
  if(Inp_IND_LEV < 0 || Inp_IND_LEV >= 100){
    logger.Critical("'IND_LEV' must be in (0-100)", true);
    return(INIT_FAILED);
  }    
  
  if(Inp_IND_DPH < 4){
    logger.Critical("'IND_DPT must be >=4 ", true);
    return(INIT_FAILED);
  }    
 
  //--- indicator buffers mapping
  SetIndexBuffer(0, buf_fvg_h, INDICATOR_DATA);
  SetIndexBuffer(1, buf_fvg_l, INDICATOR_DATA);
  SetIndexBuffer(2, buf_frac_h, INDICATOR_DATA);
  SetIndexBuffer(3, buf_frac_l, INDICATOR_DATA);
  
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0); 
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0); 
  PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0); 
  PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0); 
  
  PlotIndexSetInteger(2, PLOT_ARROW, (Inp_GUI_FRC) ? 159 : 0); 
  PlotIndexSetInteger(3, PLOT_ARROW, (Inp_GUI_FRC) ? 159 : 0); 
     
  //--- setting buffer arrays as timeseries
  ArraySetAsSeries(buf_fvg_h, true);
  ArraySetAsSeries(buf_fvg_l, true);
  ArraySetAsSeries(buf_frac_h, true);
  ArraySetAsSeries(buf_frac_l, true);  
   
  last_bar_dt = 0;
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
                
  ArraySetAsSeries(time, true);                  
  ArraySetAsSeries(high, true);
  ArraySetAsSeries(low, true);    
  if(last_bar_dt >= time[0]) return prev_calculated;
  
  // New bar detected
  logger.Debug(StringFormat("New bar detected: DT=%s", TimeToString(time[0])));
  last_bar_dt = time[0];
  
  // Init new buf
  if(prev_calculated == 0) {
    ArrayInitialize(buf_frac_h, 0);
    ArrayInitialize(buf_frac_l, 0);
    ArrayInitialize(buf_fvg_h, 0);
    ArrayInitialize(buf_fvg_l, 0);
  }

  buf_fvg_h[0] = 0; 
  buf_fvg_l[0] = 0;
  buf_frac_h[0] = 0;
  buf_frac_l[0] = 0;    

  // Find Fractals using 3 bars    
  int cnt = MathMin((int)Inp_IND_DPH, rates_total-prev_calculated);
  for(int i=3;i<cnt;i++){
    if(high[i-1] > high[i-2] && high[i-1] >= high[i])
      buf_frac_h[i-1] = high[i-1];
      
    if(low[i-1] < low[i-2] && low[i-1] <= low[i])
      buf_frac_l[i-1] = low[i-1];        
  }
  
  for(int i=2;i<cnt;i++)
    FindFVG(i, high, low, time);     
  
  return rates_total-3;
}
  

//+------------------------------------------------------------------+
//| Draw Fibo obj
//+------------------------------------------------------------------+ 
void DrawFibo(datetime _dt1, double _price1, datetime _dt2, double _price2) {
  string name = StringFormat("%s_FIBO_%s_%s", logger.Name, TimeToString(_dt1), TimeToString(_dt2));
  color clr = (_price1 > _price2) ? Inp_GUI_COL_BER : Inp_GUI_COL_BUL;
  
  CDKChartObjectFibo fibo;
  fibo.Create(0, name, 0, _dt1, _price1, _dt2, _price2);  
  fibo.Color(clr);
  fibo.SetLevelNumber(3);
  fibo.SetLevel(0, 0.0, "0.0", clr);
  fibo.SetLevel(1, Inp_IND_LEV, StringFormat("%0.1f", Inp_IND_LEV*100), clr);
  fibo.SetLevel(2, 1.0, "100.0", clr);
  fibo.Detach();    
}

//+------------------------------------------------------------------+
//| Draw FVG
//+------------------------------------------------------------------+
void DrawFVG(datetime _dt1, double _price1, datetime _dt2, double _price2, bool _alert, bool _push) {
  string name = StringFormat("%s_FVG_%s_%s", logger.Name, TimeToString(_dt1), TimeToString(_dt2));
  color clr = (_price1 > _price2) ? Inp_GUI_COL_BER : Inp_GUI_COL_BUL;
  
  CChartObjectRectangle rec;
  rec.Create(0, name, 0, _dt1, _price1, _dt2, _price2);
  rec.Color(clr);
  rec.Detach();
  
  string msg = StringFormat("%s %s %s FVG at %s", 
                       Symbol(), 
                       TimeframeToString(Period()), 
                       (_price1 > _price2) ? "berish" : "bullish", 
                       TimeToString(_dt1+PeriodSeconds(Period())));
                       
  if(_alert) Alert(msg);
  if(_push) SendNotification(msg);
}

//+------------------------------------------------------------------+
//| Find FVG
//+------------------------------------------------------------------+
bool FindFVG(int _idx, const double& _high[], const double& _low[], const datetime& _time[]) {
  int dir = 0;
  int fibo_idx1 = -1;
  int fibo_idx2 = -1;
  if(buf_frac_h[_idx] > 0) {
    dir = +1;
    fibo_idx2 = _idx;
  }
  if(buf_frac_l[_idx] > 0) {
    dir = -1;
    fibo_idx2 = _idx;
  }
  
  // No fractal as Fibo finish here
  if(dir == 0) return false;
  
  for(int i=_idx+2;i<ArraySize(buf_frac_h);i++) 
    if(buf_frac_l[i] > 0 || buf_frac_h[i] > 0) {
      if(dir > 0 && buf_frac_l[i] > 0) {
        fibo_idx1 = i;
        break;
      }
      if(dir < 0 && buf_frac_h[i] > 0) {
        fibo_idx1 = i;
        break;
      }
      if(Inp_IND_SOD)
        break;
    }

  // No fractal as Fibo start here
  if(fibo_idx1 < 0) return false;
  
  double fibo1 = (dir > 0) ? _low[fibo_idx1] : _high[fibo_idx1];
  double fibo2 = (dir > 0) ? _high[fibo_idx2] : _low[fibo_idx2];
  double fibo_level = MathAbs(fibo2-fibo1)*Inp_IND_LEV;
  fibo_level = (dir > 0) ? _high[fibo_idx2]-fibo_level : _low[fibo_idx2]+fibo_level;
  bool has_fvg = false;
  for(int i=fibo_idx1-1;i>fibo_idx2;i--){
    double left  = (dir > 0) ? _high[i+1] : _low[i+1];
    double right = (dir > 0) ? _low[i-1] : _high[i-1];
    if((dir > 0 && left < right && left < fibo_level) ||
       (dir < 0 && left > right && left > fibo_level)) {
      buf_fvg_h[i] = (dir > 0) ? right : left;
      buf_fvg_l[i] = (dir > 0) ? left : right;
      if(Inp_GUI_FVG)
        DrawFVG(_time[i+1], left, _time[i-1], right, 
                Inp_ALR_ENB && _idx == 2,
                Inp_ALR_PNE && _idx == 2);
      has_fvg = true;
    }
  }
    
  if(!has_fvg) return false;
  
  if(Inp_GUI_FIB)
    DrawFibo(_time[fibo_idx1], 
             (dir > 0) ? buf_frac_l[fibo_idx1] : buf_frac_h[fibo_idx1],
             _time[fibo_idx2],
             (dir > 0) ? buf_frac_h[fibo_idx2] : buf_frac_l[fibo_idx2]);

  return true; 
}
