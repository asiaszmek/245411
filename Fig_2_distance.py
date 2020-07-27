from __future__ import print_function, division
import subprocess
import os

import numpy as np


from text_files import text_sim_1,  text_sim_2, text_sim_3
import make_timetables as mp


sim_name = 'MSsim'
fname_info = """str diskpath="SimData/"@{Protocol}@"_"@{DA}@"_"@{Timing}@"_"@{Location}@"_Ca_ext_"@{external_Ca}\n"""

locations = ['tertdend1_1','tertdend1_3','tertdend1_5','tertdend1_7','tertdend1_9','tertdend1_11','tertdend1_13']


if __name__ == '__main__':
     params = mp.read_file('SimParams.g')
     gabaYesNo = 0#mp.find_value(params,'GABAYesNo','Pre')
     spines = mp.find_string(params,'whichSpines','Pre')
     stim_start = mp.find_value(params,'initSim','Pre')
     too_fast = mp.find_value(params,'TooFast','Pre')
     print(gabaYesNo, spines, stim_start, too_fast)
     protocols = ['InOut/Shindou.g']
     timings = ['Pre']
     paradigm_names = ['Shindou']
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
                
        



                    sim_file = sim_name+'_'+paradigm_names[i]+'_'+timing+'_location_'+location+'_phasic.g'
                    fil = open(sim_file,'w')
                    fil.write("""include PSim_Params_Cadye_2.g\n""")
                    fil.write(text_sim_1)
                    fil.write("calciumdye=2\n")
                    fil.write('str Location = "'+location+'"\n')
                    fil.write('str Protocol = "'+paradigm_names[i]+'"\n')
                    fil.write('str Timing = "'+timing+'"\n')
                    fil.write(fname_info)
                    fil.write(text_sim_2)
                    fil.write("include "+protocol+'\n')
                    
                    fil.write(text_sim_3)
                    fil.close()
                    
                    process = subprocess.Popen(['chemesis','-nox','-notty','-batch',sim_file])
                    ret = process.wait()

            

            

    
