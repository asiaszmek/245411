def extract(subtext,what):
    subtext = subtext.strip()
    subtext = subtext.split('=')
    h_string = subtext[1].strip()
    
    if ',' in h_string:
        h_string = h_string.split(',')[0]
    elif '\n' in h_string:
        h_string = h_string.split('\n')[0]
  
    if '//' in h_string:
        h_string = h_string.split('//')[0]
    elif '/*' in h_string:
        h_string = h_string.split('/*')[0]
    
    h_string = h_string.strip()
    
    if '.' in h_string:
        return float(h_string)
    else:
        return int(h_string)
 
def extract_string(subtext,what):
    subtext = subtext.strip()
    subtext = subtext.split('=')
    h_string = subtext[1].strip()
    if '"' not in h_string:
        print 'No string'
        return
    return h_string.split('"')[1]

def find_value(text, what,timing):
    subtext = text.split(what)
    if len(subtext) == 1:
        print 'Could not find', what
        return 
    if len(subtext) == 2:
        return extract(subtext[-1],what)
    else:
        if '\"Pre\"' not in text:
            if '\"Post\"' not in text:
                   return extract(subtext[-1],what)
            else:
                if timing == 'Post':
                    pass
        else:
            if timing == 'Pre':
                subtext = text.split('\"Pre\"')
                if 'Post' in subtext[-1]:
                    subtext = subtext[-1].split('\"Post\"')[0]
                elif 'else' in subtext[-1]:
                    subtext = subtext[-1].split('else')[0]
                subtext = subtext.split(what)[-1]
                return extract(subtext,what)
            else:
                pass
    return 
def find_string(text,what,timing):
    subtext = text.split(what)
    if len(subtext) == 1:
        print 'Could not find', what
        return 
    if len(subtext) == 2:
        return extract_string(subtext[-1],what)
    else:
        if '\"Pre\"' not in text:
            if '\"Post\"' not in text:
                   return extract_string(subtext[-1],what)
            else:
                if timing == 'Post':
                    pass
        else:
            if timing == 'Pre':
                subtext = text.split('\"Pre\"')
                if 'Post' in subtext[-1]:
                    subtext = subtext[-1].split('\"Post\"')[0]
                elif 'else' in subtext[-1]:
                    subtext = subtext[-1].split('else')[0]
                subtext = subtext.split(what)[-1]
                return extract_string(subtext,what)
            else:
                pass
    return 

def distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start,fname_base,spine_list):
    how_many = npulses/len(spine_list)
    overlap = npulses%len(spine_list)
    f_spines = []
    f_list = []
    for i in range(len(spine_list)):
        fname = fname_base+spine_list[i]
        if fname not in f_list:
            f_spines.append(open(fname,'w'))
            f_list.append(fname)
        else:
            idx = f_list.index(fname)
            f_spines.append(f_spines[idx])
        #print f_spines[i]
    for t in range(ntrains):
        for b in range(nbursts):    
            for i in range(len(spine_list)):
                for j in range(how_many):
                    time = stim_start + 1./freq*(i+j*len(spine_list)) + t*(1./trainfreq)+b*(1./burstfreq)
                    #print i, time
                    f_spines[i].write(str(time)+'\n')
            for i in range(overlap):
                time = stim_start + 1./freq*how_many*len(spine_list)+i*1./freq+ t*(1./trainfreq)+b*(1./burstfreq)

                f_spines[i].write(str(time)+'\n')


def read_file(fname):
    f = open(fname)
    text = f.read()
    return text

def change_in_file(fname,what,value):
    f = open(fname)
    text = f.read()
    f.close()
    cut = text.split(what)
    to_file = cut[0]

    i = 0
    print to_file
    while True:
        if cut[1][i] == ',' or cut[-1][i] == '\n' or cut[-1][i] == '/':
            break
        i = i+1
    other = ' ' + str(value) +' ' +cut[-1][i:]
    f = open(fname, 'w')
    f.write(to_file+what+other)
    f.close()

if __name__ == '__main__':
    too_fast = 30
    
    params = read_file('SimParams.g')
    gabaYesNo = find_value(params,'GABAYesNo','Pre')
    spines = find_string(params,'whichSpines','Pre')
    stim_start = find_value(params,'initSim','Pre')
    too_fast = find_value(params,'TooFast','Pre')
    print gabaYesNo, spines, stim_start, too_fast
    protocols = ['InOut/Fino.g','InOut/P_K.g','InOut/Shen.g','InOut/1_PSP.g','InOut/Shindou.g','InOut/P_K_1_AP.g']
    timings = ['Pre','Post']
    paradigm_names = ['Fino','P_and_K','Shen','1_PSP','Shindou','P_and_K_1_AP']
    for timing in timings:
        for i, protocol in enumerate(protocols):
            text = read_file(protocol)
            #find pulseFreq
            freq = find_value(text, 'pulseFreq',timing)
            npulses = find_value(text, 'pulses',timing)     
            nbursts = find_value(text, 'numbursts',timing)
            burstfreq = find_value(text, 'burstFreq',timing)
            ntrains = find_value(text, 'numtrains',timing)
            trainfreq = find_value(text, 'trainFreq',timing)
            print freq, npulses, nbursts, burstfreq, ntrains, trainfreq
            if npulses == None:
                npulses = 1
            
   
            fname_base = paradigm_names[i]+'_'+timing+'_stimulation_spine_'
            spine_list = spines.split(',')[0]
            if npulses > 1:
                if freq > too_fast:
                    spine_list = spines.split(',')
    

            distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start,fname_base,spine_list)



            if gabaYesNo:
        
                spine_list = ['']
                fname_base = paradigm_names[i]+'_'+timing+'_gaba'
                delay = find_value(read_file('MScell/SynParamsCtx.g'),'GABA','')
                print delay
                distribute(freq,npulses,burstfreq,nbursts,trainfreq,ntrains,stim_start+delay,fname_base,spine_list)

    # timing = 'Pre'
    # protocol ='InOut/Shen.g'
    # paradigm = 'Shen'
    # sequence = [['1','2'],['2','3'],['3','1']]
    # spine_list = ['1','2','3']
    # text = read_file(protocol)
    # #find pulseFreq
    # freq = find_value(text, 'pulseFreq',timing)
    # npulses = find_value(text, 'pulses',timing)     
    # nbursts = find_value(text, 'numbursts',timing)
    # burstfreq = find_value(text, 'burstFreq',timing)
    # ntrains = find_value(text, 'numtrains',timing)
    # trainfreq = find_value(text, 'trainFreq',timing)
    # print freq, npulses, nbursts, burstfreq, ntrains, trainfreq
      
    # fname_base = paradigm+'_'+timing+'_stimulation_spine_'
    # f_spines = []
    # print spine_list, fname_base
    # for i,spl in enumerate(spine_list):
    #     f_spines.append(open(fname_base+spine_list[i],'w'))
    #     print fname_base+spine_list[i]
    # for t in range(ntrains):
    #     for b in range(nbursts):   
    #         for i in range(npulses):
                
    #             time = stim_start + 1./freq*(i) + t*(1./trainfreq)+b*(1./burstfreq)
                
    #             spines = sequence[i]
    #             for spine in spines:
    #                 ind = spine_list.index(spine)
    #                 f_spines[ind].write(str(time)+'\n')
