//genesis
// MSsimSyn.g

/***************************		MS Model, Version 12	***************/
//*********** includes - functions for constructing model and outputs, and  doing simulations
include PSim_Params.g                   //simulation control parameters, can be overridden in this file

/*Set up blocking experiments here */
gNaFsoma_UI = {gNaFsoma_UI}
gNaFprox_UI = {gNaFprox_UI}
gNaFdist_UI = {gNaFdist_UI}
gCaL13soma_UI = {gCaL13soma_UI}
gCaL13dend_UI = {gCaL13dend_UI}
gCaT32prox = {gCaT32prox}
gCaT32dist = {gCaT32dist}
gCaT33prox = {gCaT33prox}
gCaT33dist = {gCaT33dist}
spineDensity = 1.0
gCaRsoma = {gCaRsoma}
gCaRdend = {gCaRdend}
gCaL12soma_UI = {gCaL12soma_UI}
gCaL12dend_UI = {gCaL12dend_UI}
gKIRsoma_UI = {gKIRsoma_UI}
gKIRdend_UI = {gKIRdend_UI}
gKAfsoma_UI = {gKAfsoma_UI}
gKAfprox_UI = {gKAfprox_UI}
gKAfdist_UI = {gKAfdist_UI}
gKAssoma_UI = {gKAssoma_UI}
gKAsdend_UI = {gKAsdend_UI}
gBKdend = {gBKdend}
gBKsoma = {gBKsoma}
gSKdend = {gSKdend}
gSKsoma = {gSKsoma}
gKrpdend = {gKrpdend}

gCaL12spine = {gCaL12spine}
gCaL13spine = {gCaL13spine}
gCaRspine = {gCaRspine}
gCaT32spine = {gCaT32spine}
gCaT33spine = {gCaT33spine}
gSKspine = {gSKspine}

NMDAgmax = {NMDAgmax}
AMPAgmax = {AMPAgmax}

calciuminact = {calciuminact}
nmdacdiyesno = {nmdacdiyesno}

neckRA = {neckRA}

//GABAtype: 0 for fast kinetics, e.g. LTSI, SPN, FSI; 1 for slow kinetics, e.g. NYP-NGF interneuron
int GABAtype = 1
str GABAname = "GABA"
if ({GABAtype} == 0)
    float GABAtau1 = 1.0e-3
    float GABAtau2 = 14.4e-3
    float GABAgmax = 1200e-12
    str GABAlabel = "GABAAfast"
elif ({GABAtype} == 1)
    float GABAtau1 = 10e-3
    float GABAtau2 = 83e-3
    float GABAgmax = 1200e-12
    str GABAlabel = "GABAAslow"
end
include MScell/MScellSynSpines	      // access make_MS_cell
include InOut/add_output.g            //functions for ascii file output
include InOut/IF.g                    //function to create pulse generator for current injection, also IF & IV curves
include InOut/SpikeMakerFunctions.g   //functions to create randomspikes and connect to synapes
include InOut/PreSynSync.g            //functions for setting up synchronous pre-synaptic stimulation
include InOut/UpState.g               //run upstate simulations - asynchronous synaptic stimulation
include InOut/UpStateSTDP.g           //run upstate simulations
include InOut/PlasStim.g              //run plasticity protocols - pattern of PSPS, no current injection
include InOut/STDP.g                  //run STDP protocols - single PSP with current injection
include InOut/ConstrainUp.g
//include RebekahSims/Store_Parameters.g
include graphics7.g

str prestim = 2
float pulseFreq = 1
int pulses = 1
pulseYN = 0
//Post-synaptic parameters
float inject=1e-9 //1e-9
float burstFreq = 1
int numbursts = 1
float trainFreq=1
int numtrains=1

AP_durtime=0.005
float APinterval={1.0/50.0}
int numAP=1

float isi=0.4

//block spine channels
//gCaL12spine = 0
//gCaL13spine = 0
//gCaRspine = 0
//gCaTspine = 0

//set random seed so for each simulation the randomspike train will be the same
//3 = 5757538
//5 = 9824501
//4 = 2394075
//6 = 492
//7 = 2370
int seedvalue= 5757538

//**************** end of parameters, now contruct model and do simulations

setclock 0 {simdt}
setclock 1 {outputclock}






int totspine={make_MS_cell_SynSpine {neuronname} {pfile} {spinesYesNo} {DA}}	// MS_cell.g
reset

if (hsolveYesNo==1)
    create hsolve {neuronname}/solve
    setfield  {neuronname}/solve  chanmode 1 comptmode 1
    setfield {neuronname}/solve path  {neuronname}/##[][TYPE=compartment]
    setmethod {neuronname}/solve 11
        //call {neuronname}/solve SETUP - done later, immediately before simulation
end

//Set up asc_file outputs and get headers for the files
Vmhead={add_outputVm {comps} {Vmfile} {neuronname}}
if ({CaOut})
    Cafile="Ca"
    Cahead={add_outputCal {comps} {CaBufs} {Cafile} {neuronname}}
else
    Cafile="X"
    Cahead=""
end
if ({GkOut})
    Gkfile="Gk"
    Gkhead={add_outputGk {comps} {chans} {Gkfile} {neuronname}}
else
    Gkfile="X"
    Gkhead=""
end

Ikfile = "Ik"
Ikhead={add_outputIk {comps} {chans} {Ikfile} {neuronname}}

str spinefile="spine"

str multispinefile = "multispines"
//multispinehead={add_outputSpines {substring {comps} 15} {CaBufs} {multispinefile} {neuronname}}

ce /

//Simulation of "upstate" by stimulation of limited number of spines, e.g. Plotkin et al.
//This is specific to a neuron with spines.  Won't work otherwise
int numstim=16
str stimcomp="tertdend1_8"
str startcomp=stimcomp//"tertdend1_9" //tertdend1_1 or 1_5
int parenttype=3
float maxpath= 18e-6
float meanDelay = 0//2e-3//0
float branchoffset = 0
int mirrorYesNo =0
int randDelayYesNo = 0
GABAYesNo=1
str GABAloc = "tertdend1_8"
float GABA_delay = 0e-3
str diskpath="SimData/PSim_ConstrainUp_noGABAcontrol_16spines"
//Note that function call to setup multi spine files is within ConstrainUp
ConstrainUp {numstim} {startcomp} {parenttype} {maxpath} {meanDelay} {diskpath} {mirrorYesNo} {branchoffset} {randDelayYesNo}
//ConstrainUp 1 "tertdend1_2" 3 1e-6 0 {diskpath} 0 0e-3 0
//connectGABA 0 "/cell/"{GABAloc} {precell} {{branchoffset}+{GABA_delay}} 0
runConstrainUp {numstim} {startcomp} {parenttype} {maxpath} {meanDelay} {diskpath} {mirrorYesNo} {branchoffset} {randDelayYesNo}
quit
