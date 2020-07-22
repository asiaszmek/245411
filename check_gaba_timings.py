import numpy as np
import make_timetables as mp
import subprocess

synparams_file = 'MScell/SynParamsCtx.g'
gaba_delays = [0.015,0.025,0.04,0.05,0.1]
digits = ['0','1','2','3','4','5','6','7','8','9','.']
sim_name = 'Different_gaba_delay_stimulation'
text_sim_1 = '''        
include SimParams.g                   //simulation control parameters, can be overridden in this file
include MScell/globals.g
include MScell/Ca_constants.g
include MScell/SynParamsCtx.g
include MScell/spineParams.g
include MScell/MScellSynSpines	      // access make_MS_cell 
include InOut/add_output.g            //functions for ascii file output
include InOut/IF.g                    //function to create pulse generator for current injection, also IF & IV curves
include InOut/HookUp.g 


setclock 0 {simdt}         
setclock 1 {outputclock}

str DA = "UI"
str Location = "tertdend1_1"
str jitter = "No"
int jitter_int = 0
int seedvalue = 5757538

'''
#here Protocol and Timing

text_sim_2 = """
GABAYesNo = 1
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

text_sim_3 = '''

float newTrainFreq = {burstFreq}/{numbursts}
echo {newTrainFreq}
HookUp {prestim} {Protocol} {Timing} {stimcomp} {diskpath} {numAP} {inject} {AP_durtime} {APinterval} {ISI} {pulseFreq} {pulses} {burstFreq} {numbursts} {newTrainFreq} 1 {jitter_int}
reset
step 1.5 -time

fileFLUSH {Vmfile} 
fileFLUSH {Cafile} 
fileFLUSH {Gkfile} 
fileFLUSH {spinefile}
fileFLUSH {somainjfile}
'''
if __name__ == '__main__':

    for delay in [0.04]:
        mp.change_in_file(synparams_file,'GABAdelay = ',delay)

        params = mp.read_file('SimParams.g')
        gabaYesNo = mp.find_value(params,'GABAYesNo','Pre')
        spines = mp.find_string(params,'whichSpines','Pre')
        stim_start = mp.find_value(params,'initSim','Pre')
        too_fast = mp.find_value(params,'TooFast','Pre')
        print gabaYesNo, spines, stim_start, too_fast
        protocols = ['InOut/Fino.g']#,'InOut/1_AP.g']
        timings = ['Pre','Post']
        paradigm_names = ['Fino']#,'1_AP']
        for timing in timings:
            for i, protocol in enumerate(protocols):
                text = mp.read_file(protocol)
                #find pulseFreq
                freq = mp.find_value(text, 'pulseFreq',timing)
                npulses = mp.find_value(text, 'pulses',timing)     
                nbursts = mp.find_value(text, 'numbursts',timing)
                burstfreq = mp.find_value(text, 'burstFreq',timing)
                ntrains = mp.find_value(text, 'numtrains',timing)
                trainfreq = mp.find_value(text, 'trainFreq',timing)
                print freq, npulses, nbursts, burstfreq, ntrains, trainfreq
                if npulses == None:
                    npulses = 1
            
   
                fname_base = paradigm_names[i]+'_'+timing+'_stimulation_spine_'
                spine_list = spines.split(',')[0]
                if npulses > 1:
                    if freq > too_fast:
                        spine_list = spines.split(',')
    

                mp.distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start,fname_base,spine_list)
                
        



                if gabaYesNo:
        
                    spine_list = ['']
                    fname_base = paradigm_names[i]+'_'+timing+'_gaba'
                    dela = mp.find_value(mp.read_file('MScell/SynParamsCtx.g'),'GABAdelay =','')
                    print delay, dela
                    mp.distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start+delay,fname_base,spine_list)
                sim_file = sim_name+'_'+paradigm_names[i]+'_timing_'+timing+'_gaba_delay_'+str(delay)+'.g'
                fil = open(sim_file,'w')
                fil.write(text_sim_1)
                fil.write('str Protocol = "'+paradigm_names[i]+'"\n')
                fil.write('str Timing = "'+timing+'"\n')
                fil.write(text_sim_2)
                fil.write("include "+protocol+'\n')
                fil.write(text_sim_3)
                fil.close()
        
                process = subprocess.Popen(['/home/szmek/genesis-2.4/chemesis','-nox','-notty','-batch',sim_file])
                ret = process.wait()

            

            

    
