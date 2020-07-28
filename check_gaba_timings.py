from __future__ import print_function, division
import numpy as np
import make_timetables as mp
from text_files import text_sim_1, text_sim_2, text_sim_3

import subprocess

gaba_delays = [0.015, 0.025, 0.04, 0.05, 0.1]
digits = ['0','1','2','3','4','5','6','7','8','9','.']
sim_name = 'Different_gaba_delay_stimulation'

synparams_file = 'MScell/SynParamsCtx.g'
location = 'tertdend1_1'
text_sim_gaba = """
GABAYesNo = 1
str diskpath="SimData/"@{Protocol}@"_"@{DA}@"_"@{Timing}@"_"@{Location}@"_Ca_ext_"@{external_Ca}

"""
locations = [ 'tertdend1_1', 'tertdend1_2', 'tertdend1_3', 'tertdend1_4',
              'tertdend1_5', 'tertdend1_6', 'tertdend1_7', 'tertdend1_8',
              'tertdend1_9', 'tertdend1_10', 'tertdend1_11', 'tertdend1_12',
              'tertdend1_13']

gabaYesNo = 1
if __name__ == '__main__':
    for gabaYesNo in [0, 1]:
        for delay in [0.04]:
            params = mp.read_file('SimParams.g')
            spines = mp.find_string(params, 'whichSpines', 'Pre')
            stim_start = mp.find_value(params, 'initSim','Pre')
            too_fast = mp.find_value(params, 'TooFast','Pre')
            print("GABA:", gabaYesNo, spines, stim_start, too_fast)
            protocols = ['InOut/Fino.g']
            timings = ['Pre','Post']
            paradigm_names = ['Fino']
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
                    print(freq, npulses, nbursts, burstfreq, ntrains, trainfreq)
                    if npulses == None:
                        npulses = 1
                    fname_base = "%s_%s_stimulation_spine_"%(paradigm_names[i],
                                                             timing)
                    spine_list = spines.split(',')[0]
                    if npulses > 1:
                        if freq > too_fast:
                            spine_list = spines.split(',')
    
                    mp.distribute(freq, npulses, burstfreq,
                                  nbursts, trainfreq, ntrains, stim_start,
                                  fname_base, spine_list)
                    if gabaYesNo:
        
                        spine_list = ['']
                        fname_base = paradigm_names[i]+'_'+timing+'_gaba'
                        mp.distribute(freq,npulses,burstfreq,nbursts,
                                      trainfreq,ntrains,stim_start+delay,
                                      fname_base,spine_list)
                    
                    for tonicGABA in [0, 1]:
                        for location in locations:
                            if not tonicGABA:
                                sim_file = "%s_%s_%s_gaba_delay_%4.2f.g"%(sim_name,
                                                                          paradigm_names[i],
                                                                          timing,
                                                                          delay)
                            else:
                                sim_file = "%s_%s_%s_tonic_gaba_gaba_delay_%4.2f.g"%(sim_name,
                                                                                     paradigm_names[i],
                                                                                     timing,
                                                                                     delay)
                            fil = open(sim_file,'w')
                            fil.write("""include PSim_Params.g\n""")
                            fil.write(text_sim_1)
                            fil.write("""GABAtonic = %d\n""" % tonicGABA)
                            fil.write("""GABAtau2 = %f\n""" % 80.75e-3)
                            
                            fil.write('str Protocol = "%s"\n' % paradigm_names[i])
                            fil.write('str Timing = "%s"\n' % timing)
                            fil.write('str Location = "%s"\n' % location)
                            
                            fil.write(text_sim_gaba)
                            fil.write(text_sim_2)
                            fil.write("include %s\n" % protocol)
                            fil.write(text_sim_3)
                            fil.close()
                            
                            process = subprocess.Popen(['chemesis','-nox',
                                                        '-notty','-batch',
                                                        sim_file])
                            ret = process.wait()

            

            

    
