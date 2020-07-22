from __future__ import print_function, division

import numpy as np
import make_timetables as mp
import subprocess
sim_name = 'MSsim'

ISIs = [-.2,-.1,-.05,-.03,-.02,-0.01,-0.005,0.005,.01,.02,.03,.05,.1,.2]
text_sim_1 = '''include SimParams.g 
  include MScell/globals.g
include MScell/Ca_constants.g
include MScell/SynParamsCtx.g
include MScell/spineParams.g
include MScell/MScellSynSpines	      // access make_MS_cell 
include InOut/add_output.g            //functions for ascii file output
include InOut/IF.g                    //function to create pulse generator for current injection, also IF & IV curves
include InOut/HookUp.g              

setclock 0 {simdt}         
setclock 1 {simdt}

str DA = "UI"
'''

#str Location = "tertdend1_1"

text_sim_11 = '''str jitter = "No"
int jitter_int = 0
int seedvalue = 5757538
GABAYesNo = 0
'''
#here Protocol and Timing

text_sim_2 = """

str diskpath="SimData/"@{Protocol}@"_"@{DA}@"_"@{Timing}@"_"@{Location}@"_randseed_"@{seedvalue}@"_high_res"

int totspine={make_MS_cell_SynSpine {neuronname} {pfile} {spinesYesNo} {DA}}
reset
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
    Gkhead={add_outputGk {comps} {chans} {Gkfile} {neuronname}}
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
step 2.5 -time

fileFLUSH {Vmfile} 
fileFLUSH {Cafile} 
fileFLUSH {Gkfile} 
fileFLUSH {spinefile}
fileFLUSH {somainjfile}
'''
locations = ['tertdend1_1','tertdend1_2','tertdend1_3','tertdend1_4','tertdend1_5','tertdend1_6','tertdend1_8','tertdend1_10','tertdend1_11']
if __name__ == '__main__':
     params = mp.read_file('SimParams.g')
     gabaYesNo = 0#mp.find_value(params,'GABAYesNo','Pre')
     spines = mp.find_string(params,'whichSpines','Pre')
     stim_start = mp.find_value(params,'initSim','Pre')
     too_fast = mp.find_value(params,'TooFast','Pre')
     print(gabaYesNo, spines, stim_start, too_fast)
     protocols = ['InOut/Shen.g']
     timings = ['Pre','Post']
     paradigm_names = ['Shen']
     for location in locations:

        
          for timing in timings:
               for i, protocol in enumerate(protocols):
                    print(protocol)
                    text = mp.read_file(protocol)
                    #find pulseFreq
                    freq = mp.find_value(text, 'pulseFreq',timing)
                    npulses = mp.find_value(text, 'pulses',timing)     
                    nbursts = mp.find_value(text, 'numbursts',timing)
                    burstfreq = mp.find_value(text, 'burstFreq',timing)
                    ntrains = mp.find_value(text, 'numtrains',timing)
                    trainfreq = mp.find_value(text, 'trainFreq',timing)
                    print(freq, npulses, nbursts, burstfreq, ntrains, trainfreq)
                    if npulses == None:
                         npulses = 1
                    
   
                    fname_base = paradigm_names[i]+'_'+timing+'_stimulation_'
                    spine_list = ['spine_1']
    

                    mp.distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start,fname_base,spine_list)
                
        



                    sim_file = sim_name+'_'+paradigm_names[i]+'_timing_'+timing+'_location_'+str(location)+'.g'
                    fil = open(sim_file,'w')
                    fil.write(text_sim_1)
                    fil.write('str Location = "'+location+'"\n')
                    fil.write(text_sim_11)
                    fil.write('str Protocol = "'+paradigm_names[i]+'"\n')
                    fil.write('str Timing = "'+timing+'"\n')
                    fil.write(text_sim_2)
                    fil.write("include "+protocol+'\n')
                    
                    fil.write(text_sim_3)
                    fil.close()
                    
                    #process = subprocess.Popen(['/home/jszmek/genesis-2.4/chemesis','-nox','-notty','-batch',sim_file])
                    #ret = process.wait()

            

            

    
