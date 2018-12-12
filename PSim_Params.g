//genesis
// PSim_Params.g

/***************************		MS Model, Version 12	***************/
//*********** includes - functions for constructing model and outputs, and  doing simulations
include SimParams.g                   //simulation control parameters, can be overridden in this file
simdt=10e-6//50e-6//10e-6//5e-6//2e-5
//outputclock=1e-4
spinesYesNo=1//1
int hsolveYesNo = 1
synYesNo=1
delay= 0.1//0.2
duration = 0.4//.2//0.4
//****** Globals and Parameters that can be changed in this script for the simulation
pfile="MScell/MScelltaperspines_3.p"//"MScell/MScelltaperspines_3.p"//"MScell/MScelltaperspines_subdiv.p"//"MScell/MScellPrimSecSpines.p"//"MScell/MScelltaperspines.p"//"MScell/MScelltaperspines_SingleBranchNarrow.p" //Simplified morphology for tuning
str comps="soma,primdend1,secdend11,tertdend1_1,tertdend1_2,tertdend1_3,tertdend1_4,tertdend1_5,tertdend1_6,tertdend1_7,tertdend1_8,tertdend1_9,tertdend1_10,tertdend1_11"//,tertdend2_1,tertdend2_2,tertdend2_3,tertdend2_4,tertdend2_5,tertdend2_6,tertdend2_7,tertdend2_8,tertdend2_9,tertdend2_10,tertdend2_11" //These should include comps of stim spines to see NMDA
str chans="CaL12_channel,CaL13_channel,CaR_channel,CaN_channel,CaT32_channel,CaT33_channel,BK_channel,KIR_channel,KAf_channel,NaF_channel,SK_channel,KAs_channel,Krp_channel"


include MScell/globals.g //change below

ELEAK =-82e-3//-85e-3// -.072//-.071//-.077 best//-.072//ELEAK*.4985//{ELEAK*.3*1.667}//-.075//-0.029478
RA = .975*1.25//2.0//RA*7.199//{RA*6.9*1.67}//1.5//13.7657
RM = {1*.9*3.0*.625}//70//1.0//1.5//1.5= better IF//1.05//1.05 is best so far//.6//.5//0.8//0.5//0.75//1.0//10.0//RM*.5503//2//{RM*0.99*0.759}//.4//.1//.5//.2//8.97763
CM = .007//.01//.0075//.01//2*CM*.2734//{CM*0.5*0.95*4}//0.035
EREST_ACT = -87e-3//-86e-3//-.086

float qfactorKir = 2//1.2   


gNaFsoma_UI =45000//55000//29000//45000//80000//46000//45000//44000//45000//80000
gNaFprox_UI =1.3*3400//2600//2000//2500//3200//2900//2500
gNaFdist_UI =0*200//600//1200//800//450
//gNaFsoma_UI=44000//{40000} //50000
//gNaFprox_UI={2730}
//gNaFdist_UI={975}
gCaL13soma_UI = {{.5e-7}/{GHKluge}}//2*3e-7
gCaL13dend_UI = {{.25e-7}/{GHKluge}}//.5*.5e-8
gCaT32prox  =  {{1.2e-7}/{GHKluge}}
gCaT32dist  =  {{.8*2.5e-7}/{GHKluge}}//13e-8//.5*8e-8
gCaT33prox  =  {{0e-8}/{GHKluge}}
gCaT33dist  =  {{0.005e-7}/{GHKluge}}//13e-8//.5*8e-8
gCaRsoma  =  {{3e-7}/{GHKluge}}//8e-7//2*8e-7
gCaRdend  ={{1.2*25e-7}/{GHKluge}}//23e-7//.5*10e-7
gCaNsoma =  {{15e-7}/{GHKluge}}//2*12e-7
gCaNdend =   {{0}/{GHKluge}}
gCaL12soma_UI = {{1.5e-7}/{GHKluge}}//2*6e-7
gCaL12dend_UI = {{1.5e-7}/{GHKluge}}//.5*1e-7
gKIRsoma_UI = 2*.7*8.5//10.5//9.5//9 best//14//gKIRsoma_UI*.6826//{gKIRsoma_UI*.67*.867}// {10.0} //25.0658
gKIRdend_UI = 1*.7*8.5//10.5//9.5//4.5//9.5//10//10=best//14//20//gKIRsoma_UI//{15}
gKAfsoma_UI=500//310//220//250//100//150//200//300//218//350//240//217//190//170//100//160= good//50//25//50//100//315//250//{200}
//gKAfdend_UI={gKAfsoma_UI*0.85}//230//gKAfsoma_UI//{90}
gKAfprox_UI =500//.7*195//200//37// 40//310//250//220//250//100//50//250//300//260//{gKAfsoma_UI}
gKAfdist_UI = .4*180//200//.7*195//295//260//200//37//160//20//25//45//40//200//220//250//200// 320//*375//400//700//320//260//150
gKAssoma_UI=70//70//36//6//11//15//5//2//4//16//8//20//22//26//20//30//9//3//13//11//8//40//100//100//25//{100}
gKAsdend_UI=.2*15//15//0.5*5//12//6//15//5//4//3//2//4//6//13//14//20//26//20//30//70//4//3//50//{gKAssoma_UI*0.2}//11//gKAssoma_UI//{10}
//Try based on wolf et al 2005: Total KA conductance in soma = that in dendrites; dendrite gbar = soma gbar*(soma surface area/dend surface area) = soma gbar * 0.1187
gKrpsoma = 10//13//10//35//3//12//6//3//12//20//12//6//3//6//5
gKrpdend=1//4//2//4//3//8//4//6//12//6 //6

gBKdend =2//2//5//10//45//20//2//6//12//8//16////4//3//6//3//5//10//4//10// 5//5
gBKsoma =5//10//45//15//6//12//2//3//3//10//10 //20

gSKdend =.5//1//2//1//0.1//0.0//.5//2//1//1
gSKsoma = 3//2//1//1//2//2//3

qfactorkAs=3//9//6//9//6//9//2//3//9//2
qfactorNaF = 3//3.0//2.5//2.5//2.75//2.5//2.5
//qfactorKrp = 3
qfactorkAf=2.5//3//1.5//3//2//1.8//1.8//1.25//8//2//.1//3//2.25//3//2.75//3//1.5//2.0//1.5 orig//2//3//2smaller means deeper contribution to fast AHP
float qfactCa = 3      //3  2

include MScell/Ca_constants.g

calciumdye = 0//4//0// 1//2

calciuminact = 1
calciumtype=0
if (calciumdye == 0)
    float btotal1 = 80.0e-3 	//4 * 40 uM total
else
    float btotal1 = 0 //If you don't dialize calbindin, soma Ca is too low (Kerr and Plenz 2008)
end

if (calciumdye == 0)
	btotal2 = 15.0e-3 	//was 30.0e-3, but Rodrigo's paper seems to have about half the CaM as Myungs.
else
	btotal2 = 0.0e-3		//CaM is 'dialyzed' when there is a calcium dye present
end
if (calciumdye == 0)
	 btotal4 = 15.0e-3 	//was 30.0e-3, but Rodrigo's paper seems to have about half the CaM as Myungs.
else
	 btotal4 = 0.0e-3		//CaM is 'dialyzed' when there is a calcium dye present
end
if (calciumdye==1)
    btotalfluor={btotal3}
    kffluor={kf3}
    kbfluor={kb3}
    bnamefluor={bname3}
    dfluor={d3}
elif (calciumdye==2)
    btotalfluor={btotal5}
    kffluor={kf5}
    kbfluor={kb5}
    bnamefluor={bname5}
    dfluor={d5}
elif (calciumdye==3)
    float btotalfluor={btotal6}
    float kffluor={kf6}
    float kbfluor={kb6}
    str bnamefluor={bname6}
    float dfluor={d6}
elif (calciumdye==4)
    float btotalfluor={btotal7}
    float kffluor={kf7}
    float kbfluor={kb7}
    str bnamefluor={bname7}
    float dfluor={d7}
end

//kcatsoma = 95e-8//85e-8  //75 pmol ((cm)^(-2)) (s^(-1)) //Markram et al 1998
kcatdend = 10e-8 //12e-8	

include MScell/SynParamsCtx.g
AMPAgmax=0.9e-9//0.86e-9//1.0e-9//1.7e-9 //0.3e-9
N2Aratio=1.0//0.9//1.0//1.0
NMDAgmax   = {AMPAgmax}*{N2Aratio}
float	Kmg       = 18 //18 new //3.57 old overwrites 1/eta in nmda_channel.g
nmdacdiyesno = 1

include MScell/spineParams.g
spinecalcium = 0
str spineCommonParent = "soma"//"soma" // specifies which branches to add spines to; must be "soma" , "primdend1", or "secdend11"

//spineRa= 0.5e15//0.5e9
spineRM = {RM} //10
neckRA ={neckRA}//{RA}//1//1
gCaL12spine       = {gCaL12dend_UI*.61}// Multiplying by .68 made spine/dendrite bAP calcium traces nearly equal//{getglobal gCaL12dend_{DA}} //3.35e-7
gCaL13spine       = {gCaL13dend_UI*.61}//{getglobal gCaL13dend_{DA}} //4.25e-7
gCaRspine         = {gCaRdend*.61}   //13e-7
gCaT32spine         = {gCaT32dist*.61}   //0.235e-7
gCaT33spine         = {gCaT33dist*.61}   //0.235e-7
gSKspine          = 0.5
spineDensity=1.0//1.01//1.01//0.5//0.2//1.12//1.12//0.8//1//0.3 //in units of per micron
float kcatSpine = .6e-8//36e-9//12.0e-9
float kcatSpineNCX=10e-8
