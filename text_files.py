text_sim_1 = '''
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

 
include MScell/MScellSynSpines	      // access make_MS_cell 
include InOut/add_output.g            //functions for ascii file output
include InOut/IF.g     
include InOut/HookUp.g

setclock 0 {simdt}         
setclock 1 {simdt}

str DA = "UI"
str jitter = "No"
int jitter_int = 0
int seedvalue = 5757538
'''


#here Protocol and Timing

text_sim_2 = """


if ({GABAtonic})
        diskpath = {diskpath}@"_tonic_gaba"
end
int totspine={make_MS_cell_SynSpine {neuronname} {pfile} {spinesYesNo} {DA}}
reset

if (hsolveYesNo==1)
    create hsolve {neuronname}/solve
    setfield  {neuronname}/solve  chanmode 1 comptmode 1
    setfield {neuronname}/solve path  {neuronname}/##[][TYPE=compartment]
    setmethod {neuronname}/solve 11
        //call {neuronname}/solve SETUP - done later, immediately before simulation
end

Vmhead={add_outputVm {comps} {Vmfile} {neuronname}}
if ({CaOut})
    if ( {calciumdye} == 0)
        Cafile = "Ca_plasticity"
    elif  ( {calciumdye} == 1)
        Cafile = "Ca_Fura_2_plasticity"
    elif  ( {calciumdye} == 2)
        Cafile = "Ca_Fluo_5f_plasticity"
    elif  ( {calciumdye} == 3)
        Cafile = "Ca_Fluo_4_plasticity"
    else
        Cafile = "Ca_unnkown_dye_plasticity"
    end
    Cahead={add_outputCal {comps} {CaBufs} {Cafile} {neuronname}}
else
    Cafile="X_plasticity"
    Cahead=""
end
if ({GkOut})
    Gkfile="Gk_plasticity"
    if ({GABAYesNo})
        Gkhead={add_outputGk {comps} {chans} {Gkfile} {neuronname} {Location}}
    else
        Gkhead={add_outputGk {comps} {chans} {Gkfile} {neuronname}}
    end
else
    Gkfile="X_plasticity"
    Gkhead=""
end

str stimcomp= {Location}
str spinefile="spine_plasticity"


ce /

"""
#here include paradigm
#and change ISI
text_sim_3 = '''

float newTrainFreq = {burstFreq}/{numbursts}
echo {newTrainFreq}
HookUp {prestim} {Protocol} {Timing} {stimcomp} {diskpath} {numAP} {inject} {AP_durtime} {APinterval} {ISI} {pulseFreq} {pulses} {burstFreq} {numbursts} {newTrainFreq} 1 {jitter_int}
reset

if (hsolveYesNo==1)
    call {neuronname}/solve SETUP
end
reset
reset
step 1.5 -time

fileFLUSH {Vmfile} 
fileFLUSH {Cafile} 
fileFLUSH {Gkfile} 
fileFLUSH {spinefile}
fileFLUSH {somainjfile}
'''
