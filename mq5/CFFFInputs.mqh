//+------------------------------------------------------------------+
//|                                                   CAZSInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include  "Include\DKStdLib\Common\DKStdLib.mqh"


struct CAZSBotInputs {
  // INTERNAL VARS
  int                      IndADRHndl;
  int                      IndVolumeHndl;
  
  // USER INPUTS
  ENUM_MM_TYPE             ENT_MMT;                    // ENT_MMT: Money Managment Type
  double                   ENT_MMV;                    // ENT_MMV: Lot Size
  
  double                   SIG_SGM;                    // SIG_SGM: Threshhold Sigma for Volume & Range
  uint                     SIG_RBC;                    // SIG_RBC: Range Bar Count  
  uint                     SIG_SDC;                    // SIG_SDC: Standart Deviation Bar Count  
  uint                     SIG_ADR_LEN;                // SIG_ADR_LEN: ADR Length  // 14 // (SIG_ADR_LEN > 0)
  ENUM_APPLIED_VOLUME      Inp_SIG_VOL_APL;            // SIG_VOL_APL: Applied Volume // VOLUME_TICK
  
  
  
  
  void                     CAZSBotInputs::CAZSBotInputs():
                             IndADRHndl(-1),
                             IndVolumeHndl(-1),
                             
                             ENT_MMT(ENUM_MM_TYPE_FIXED_LOT),
                             ENT_MMV(0.01),
                             
                             SIG_RBC(5),
                             SIG_SDC(20),
                             SIG_ADR_LEN(14),
                             SIG_SGM(2.0)
                           {};
            
  string                  LastErrorMessage;               
  bool                    CAZSBotInputs::InitAndCheck();
  bool                    CAZSBotInputs::Init();
  bool                    CAZSBotInputs::CheckBeforeInit();
  bool                    CAZSBotInputs::CheckAfterInit();
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CAZSBotInputs::InitAndCheck() {
  LastErrorMessage = "";
  
  if(!CheckBeforeInit()) 
    return false;
  
  if(!Init()) {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }
  
  return CheckAfterInit();  
}

//+------------------------------------------------------------------+
//| Init struc 
//+------------------------------------------------------------------+
bool CAZSBotInputs::Init() {
  IndADRHndl = iCustom(Symbol(), Period(), "AverageDayRange", SIG_ADR_LEN);
  IndVolumeHndl = iVolumes(Symbol(), Period(), Inp_SIG_VOL_APL);
  
  return true;
}

//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CAZSBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(SIG_SGM <= 0.0) LastErrorMessage = "'SIG_SGM' must be possitive";
  if(SIG_RBC <= 0)  LastErrorMessage = "'SIG_RBC' must be possitive";
  if(SIG_SDC <= 0)  LastErrorMessage = "'SIG_SDC' must be possitive";    
  if(SIG_SDC <= SIG_RBC)  LastErrorMessage = "'SIG_SDC' must be greater 'SIG_RBC'";    
  if(SIG_ADR_LEN <= 0) LastErrorMessage = "'SIG_ADR_LEN' must be possitive";

  return LastErrorMessage == "";
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CAZSBotInputs::CheckAfterInit() {
  LastErrorMessage = "";
  if(IndADRHndl <= 0) LastErrorMessage = "Indicators\\ADR custom indicator load error";
  if(IndVolumeHndl <= 0) LastErrorMessage = "Volumes standart indicator load error";

  return LastErrorMessage == "";
}