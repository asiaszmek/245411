//spineParams.g

str spineCommonParent = "soma" // specifies which branches to add spines to; must be "soma" , "primdend1", or "secdend11"

       // for spine neck:
float   len_neck=0.5e-6                               //0.16-2.13
float   dia_neck=0.12e-6                             //(0.038-0.46)e-6
       // for spine head:
float   dia_head=0.5e-6                              //adopt common size, no exact data are available now
float   len_head=0.5e-6
      
str spcomp1="head"  //label or name of head compartment in spine
str spcomp2=""  //no separate name/label for neck compartment

int neckSlabs=3
int headSlabs=3
float head_thickness_inc=2.0
float neck_thickness_inc=1.0
float PSD_thick=0.07e-6

float spineRA = RA// SpineHEAD
float neckRA = 11.3// Results in spine neck Ra = .5 Gohm
//float spineRa=0.5e9 //DBD: changed from spineRA=4*RA to spineRa .5e9 based on IV/IF tuning
float spineRM=RM
float spineCM=CM

float spineStart=26.1e-6
float spineEnd=300e-6
float spineDensity=0.8//0.3 //in units of per micron

int addCa2Spine = 1		// 0, no VDCC in spine, 
					//1, yes VDCC in spine (non-synaptic)

int spinecalcium = 0   // We have two types of caclium:
                   // 0 : detailed multi-shell model, using "difshell" object
                   // 1 : simple calcium pool adopted from Sabatini's 2001, 2004
if ({spinecalcium<calciumtype})
	echo "bad idea; use difshells for spine or single for dendrites"
end

//for calcium and buffer diffusion messages between spine neck and dendrite.  
str upperShell = {CalciumName} @ 1

//  define spine specific calcium values here, and use them in spines.g

float gCaL12spine       =      {.65 * {getglobal gCaL12dend_{DA}}} //3.35e-7
float gCaL13spine       =      {.65 * {getglobal gCaL13dend_{DA}}} //4.25e-7
float gCaRspine         =      {.65 * {getglobal gCaRdend}}   //13e-7
float gCaT32spine         =      {.65 * {getglobal gCaT32dist}}   //0.235e-7
float gCaT33spine         =      {.65 * {getglobal gCaT33dist}}   //0.235e-7

float gSKspine          =      {gSKdend}

float kcatSpine =  1e-8 //75e-8
float kcatSpineNCX = 8e-8  //300e-8 

