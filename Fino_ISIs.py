import numpy as np
import make_timetables as mp
import subprocess
sim_name = 'MSsim'

ISIs = [-.23,-.13,-.08,-.06,-.07,-0.04,-0.005,0.005,.01,.02,.03,.05,.1,.2]
from text_files import text_sim_1, text_sim_2, text_sim_3


#here Protocol and Timing

fname_info = """
str diskpath="SimData/"@{Protocol}@"_"@{DA}@"_"@{Timing}@"_"@{Location}@"_Ca_ext_"@{external_Ca}
"""
location = "tertdend1_1"
#here include paradigm
#and change ISI
if __name__ == '__main__':
     params = mp.read_file('SimParams.g')
     
     gabaYesNo = mp.find_value(params,'GABAYesNo','Pre')
     spines = mp.find_string(params,'whichSpines','Pre')
     stim_start = mp.find_value(params,'initSim','Pre')
     print(stim_start)
     too_fast = mp.find_value(params,'TooFast','Pre')
     print(gabaYesNo, spines, stim_start, too_fast)
     protocols = ['InOut/Fino.g','InOut/P_K.g']
     timings = ['Pre']
     paradigm_names = ['Fino','P_and_K']
     for ISI in ISIs:

        
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
    
                    print(fname_base)
                    mp.distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start,fname_base,spine_list)
                
        

                    
                    for tonicGABA in [0, 1]:
                         if not tonicGABA:
                              sim_file = sim_name+'_'+paradigm_names[i]+'_ISI_'+str(ISI)+'.g'
                         else:
                              sim_file = sim_name+'_'+paradigm_names[i]+'tonic_gaba_ISI_'+str(ISI)+'.g'
                         fil = open(sim_file,'w')
                         fil.write("""include PSim_Params.g\n""")
                         fil.write(text_sim_1)
                         if paradigm_names[i] == 'P_and_K':
                              fil.write("external_Ca = 2.5\n")
                         fil.write('str Protocol = "'+paradigm_names[i]+'"\n')
                         fil.write('str Timing = "'+timing+'"\n')
                         fil.write('str Location = "'+location+'"\n')
                         fil.write("""GABAtonic = %d\n""" %tonicGABA)
                         fil.write(fname_info)
                         fil.write(text_sim_2)
                         fil.write("include "+protocol+'\n')
                         fil.write("ISI = "+str(ISI)+'\n')
                         fil.write(text_sim_3)
                         fil.close()
                    
                         process = subprocess.Popen(['chemesis','-nox','-notty','-batch',sim_file])
                         ret = process.wait()

            

            

    
