import numpy as np
import matplotlib.pyplot as plt
import sys
import glob
look_at = "head"
do_not_look_at = "neck"
#post_thresh_hi = 0.7e-3 
#post_thresh_lo = 0.35e-3
avca = 'head_Ca1'

min_w = 0.0
max_w = 2.0

def get_fnames(fname_base):
    lista = glob.glob(fname_base+'*')
    result = []
    for l in lista:
        if l.endswith('spine_plasticity.txt'):
            result.append(l)

    return result
def find_nearest(array,value):
    idx = (np.abs(array-value)).argmin()
    return idx

class CaPlasSynapse(object):
    def __init__(self,Ca,time, fname,description,post_thresh_hi,post_thresh_lo,gain_pot=35,gain_dep=75,depr_len=0.00,pot_len = 0.012,min_w=0,max_w=2., avca=avca):
        
        self.dt = time[1]-time[0]
       
        
        self.post_thresh_hi = post_thresh_hi
        self.post_thresh_lo = post_thresh_lo
        self.gain_dep = gain_dep
        self.gain_pot = gain_pot
        self.min_weight = min_w
        self.max_weight = max_w
        
        self.depr_len = depr_len
        self.pot_len = pot_len
        self.max_change = (self.max_weight- self.min_weight) /1000.0
        self.Ca = Ca
        self.time = time
        self.avca = avca
        self.weight = np.zeros(Ca.shape)
        self.max_time = 0
        self.fname = fname
        self.description = description
        self.reset()

    def reset(self):
        self.how_long_lo = 0
        self.how_long_hi = 0
        
    def change_weight_bulk(self):
        pass


    def change_weight(self,weight,avg_Ca):
        """A function calculating weight change of the synapse. Started out
        with how it is calculated in Genesis. Commented out code
        calculating presynaptic activity, which is obsolete considering
        we look at CaMCa4 in the first difshell
        """
        s_change = 0
        if avg_Ca > self.post_thresh_hi:
            post_activity = (avg_Ca-self.post_thresh_hi)
            self.how_long_hi += self.dt
            self.how_long_lo = 0
            if (self.how_long_hi > self.pot_len):
                s_change = 1 
        elif avg_Ca>self.post_thresh_lo:
            post_activity = -(avg_Ca-self.post_thresh_lo)
            self.how_long_hi = 0
            self.how_long_lo += self.dt
            if (self.how_long_lo > self.depr_len):
                s_change = 1 
        else:
            post_activity = 0
            self.how_long_lo = 0
            self.how_long_hi = 0

             
        if not (s_change):
            return weight
        
        change = self.dt*post_activity
        if change > 0:
            change *= self.gain_pot
        else:
            change *= self.gain_dep
        if abs(change) > self.max_change:
            if change > 0 :
                change = self.max_change
            else:
                change = -self.max_change

        norm_weight = (weight - self.min_weight)/(self.max_weight-self.min_weight)
        
        if change < 0 :
            scale = norm_weight**0.5
        else:
            scale = (1-norm_weight)**0.5
            
        weight = weight + change *scale
            

        if weight > self.max_weight:
            weight = self.max_weight
        elif weight<self.min_weight:
            weight = self.min_weight
           
        return weight
    def go(self):
        
        self.weight[0] = self.change_weight(1.0,self.Ca[0])
        for i,ca in enumerate(self.Ca[1:]):
            self.weight[i+1] = self.change_weight(self.weight[i],ca)
       
    def __get__(self,key):
        return self.key

    def to_file(self):
        
        fname = self.fname[:-4]+'_'+self.description+'_'+self.avca+'.txt'
        header = 'time Ca weight'
        data = np.zeros((len(self.time),3))
        data[:,0] = self.time
        data[:,1] = self.Ca
        data[:,2] = self.weight
        np.savetxt(fname,data,header=header,comments='')
        print('Save data to '+fname)

def parse_header(header):
    spines = set()
    for x in header:
        if 'spine' in x:
            part = x.split('spine_')[-1]
            sp = part.split('/')[0]
            spines.add(sp)

    spine_list = []
    for sp in spines:
        spine_list.append('spine_'+sp)

    spines = {}
    for sp in spine_list:
        spines[sp] = {}
        for i,x in enumerate(header):
            
            if sp in x:
                part = x.split(sp)[-1]
               
                if look_at in part:
                    where = part.find(look_at)+len(look_at)+1
                    what = look_at+'_'+part[where:]
                    spines[sp][what] = i
                elif do_not_look_at in part:
                    pass
                
                else:
                    if 'Hd' in part:
                        what = 'head_'+part.split('Hd')[-1][1:]
                        spines[sp][what] = i
    return spines

def go(fnames,gain_pot,gain_dep,post_thresh_hi,post_thresh_lo,depr_len,pot_len,st=0.9):
    res = []
    for fname in fnames:
        try:
            f = open(fname)
        except IOError:
            print('Could not open file ', fname)
            #sys.exit('Could not open file ' +fname)
            continue
        header = f.readline().split()
        try:
            data = np.loadtxt(f)
        except:
            print('Wrong data format ', fname)
            continue
            #sys.exit('Wrong data format '+fname)
        
        time = data[:,0]
        dt = time[1]-time[0]
        synapses = []
        
        
        if len(header) >3:
            ca = np.zeros(time.shape)
            spines = parse_header(header)
            
            if 'Pre' in fname:
                start = int((st-0.25)/dt)
            else:
                start = int((st-0.3)/dt)
            if 'Fino' in fname or 'PandK' in fname: 
                stop = int((st+0.8)/dt)
            else:
                stop =   int((st+1.1)/dt)
 
            time = time[start:stop]
            
            new_fname = fname

            for i,spine in enumerate(spines):
                try:
                    indx = spines[spine][avca]
                    ca = data[start:stop,indx]
                except KeyError:
                    indx = spines[spine][avca+'C']
                    indx1 = spines[spine][avca+'N']
                    ca = np.minimum(data[start:stop,indx],data[start:stop,indx1])#/data[:,indx1]
                syn = CaPlasSynapse(ca,time,new_fname,spine,post_thresh_hi,post_thresh_lo,gain_pot=gain_pot,gain_dep=gain_dep,depr_len=depr_len,pot_len = pot_len)
                synapses.append(syn)
                syn.go()
                syn.to_file()
        else:
            ca = data[:,1]
            spine = ('spine_'+(fname.split('_')[-1])).split('.')[0]
            new_fname = fname.split(spine)[0][:-1]+'.txt'
            syn = CaPlasSynapse(ca,time,new_fname,spine,post_thresh_hi,post_thresh_lo,gain_pot=gain_pot,gain_dep=gain_dep,depr_len=depr_len,pot_len = pot_len)
            synapses.append(syn)
            syn.go()
            syn.to_file()
        if len(synapses) > 1:
            weight = synapses[0].weight.copy()
            for synap in synapses[1:]:
                weight+= synap.weight

            weight = weight/len(synapses)
            f_name = synapses[0].fname[:-4]+'_average_spine_'+synapses[0].avca+'.txt'
            header = 'time Ca weight'
            data = np.zeros((len(synapses[0].time),3))
            data[:,0] = synapses[0].time
            data[:,1] = synapses[0].Ca
            data[:,2] = weight
            np.savetxt(f_name,data,header=header,comments='')
            print('Save data to ', f_name)

            
        res.append(synapses)    
    return res

if __name__ == '__main__':
   
    fnames = [
    'Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_2_Ca_ext_2_no_gaba_Stim_tertdend1_2_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_4_Ca_ext_2_no_gaba_Stim_tertdend1_4_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_5_Ca_ext_2_no_gaba_Stim_tertdend1_5_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_6_Ca_ext_2_no_gaba_Stim_tertdend1_6_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_8_Ca_ext_2_no_gaba_Stim_tertdend1_8_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_10_Ca_ext_2_no_gaba_Stim_tertdend1_10_AP_1_ISI_-0.01_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_1_ISI_-0.01_spine_plasticity.txt',
        'Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_2_Ca_ext_2_no_gaba_Stim_tertdend1_2_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_4_Ca_ext_2_no_gaba_Stim_tertdend1_4_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_5_Ca_ext_2_no_gaba_Stim_tertdend1_5_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_6_Ca_ext_2_no_gaba_Stim_tertdend1_6_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_8_Ca_ext_2_no_gaba_Stim_tertdend1_8_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_10_Ca_ext_2_no_gaba_Stim_tertdend1_10_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Pre_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_1_ISI_0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_2_Ca_ext_2_no_gaba_Stim_tertdend1_2_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_4_Ca_ext_2_no_gaba_Stim_tertdend1_4_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_5_Ca_ext_2_no_gaba_Stim_tertdend1_5_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_6_Ca_ext_2_no_gaba_Stim_tertdend1_6_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_8_Ca_ext_2_no_gaba_Stim_tertdend1_8_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_10_Ca_ext_2_no_gaba_Stim_tertdend1_10_AP_1_ISI_-0.04_spine_plasticity.txt',
    'Fino_UI_Post_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_1_ISI_-0.04_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_2_Ca_ext_2.5_no_gaba_Stim_tertdend1_2_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_3_Ca_ext_2.5_no_gaba_Stim_tertdend1_3_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_4_Ca_ext_2.5_no_gaba_Stim_tertdend1_4_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_5_Ca_ext_2.5_no_gaba_Stim_tertdend1_5_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_6_Ca_ext_2.5_no_gaba_Stim_tertdend1_6_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_8_Ca_ext_2.5_no_gaba_Stim_tertdend1_8_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_10_Ca_ext_2.5_no_gaba_Stim_tertdend1_10_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Pre_tertdend1_11_Ca_ext_2.5_no_gaba_Stim_tertdend1_11_AP_3_ISI_0.01_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_2_Ca_ext_2.5_no_gaba_Stim_tertdend1_2_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_3_Ca_ext_2.5_no_gaba_Stim_tertdend1_3_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_4_Ca_ext_2.5_no_gaba_Stim_tertdend1_4_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_5_Ca_ext_2.5_no_gaba_Stim_tertdend1_5_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_6_Ca_ext_2.5_no_gaba_Stim_tertdend1_6_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_8_Ca_ext_2.5_no_gaba_Stim_tertdend1_8_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_10_Ca_ext_2.5_no_gaba_Stim_tertdend1_10_AP_3_ISI_-0.03_spine_plasticity.txt',
    'P_and_K_UI_Post_tertdend1_11_Ca_ext_2.5_no_gaba_Stim_tertdend1_11_AP_3_ISI_-0.03_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_2_Ca_ext_2_no_gaba_Stim_tertdend1_2_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_4_Ca_ext_2_no_gaba_Stim_tertdend1_4_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_5_Ca_ext_2_no_gaba_Stim_tertdend1_5_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_6_Ca_ext_2_no_gaba_Stim_tertdend1_6_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_8_Ca_ext_2_no_gaba_Stim_tertdend1_8_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_10_Ca_ext_2_no_gaba_Stim_tertdend1_10_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Pre_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_3_ISI_0.005_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_2_Ca_ext_2_no_gaba_Stim_tertdend1_2_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_3_Ca_ext_2_no_gaba_Stim_tertdend1_3_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_4_Ca_ext_2_no_gaba_Stim_tertdend1_4_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_5_Ca_ext_2_no_gaba_Stim_tertdend1_5_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_6_Ca_ext_2_no_gaba_Stim_tertdend1_6_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_8_Ca_ext_2_no_gaba_Stim_tertdend1_8_AP_3_ISI_-0.01_spine_plasticity.txt',
    'Shen_UI_Post_tertdend1_10_Ca_ext_2_no_gaba_Stim_tertdend1_10_AP_3_ISI_-0.01_spine_plasticity.txt',
      'Shen_UI_Post_tertdend1_11_Ca_ext_2_no_gaba_Stim_tertdend1_11_AP_3_ISI_-0.01_spine_plasticity.txt'
    ]
    
    
    fname_bases = [
        'Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
        'No_L_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
        'No_NMDA_Fino_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_1_ISI',
        'P_and_K_UI_Pre_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI',
        'No_L_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2_no_gaba_Stim_tertdend1_1_AP_3_ISI',
        'No_NMDA_P_and_K_UI_Pre_tertdend1_1_Ca_ext_2.5_no_gaba_Stim_tertdend1_1_AP_3_ISI'
    ]

    fnames = []
    for fname_base in fname_bases:
        fnames.extend(get_fnames(fname_base))

    
    gain_pot = 1100
    gain_dep = 4500
    post_thresh_hi = .46e-3
    post_thresh_lo = .2e-3
    depr_len = 0.032
    pot_len = 0.002
    colors = ['b','r','k','g','gray','y','o']
    synapses = go(fnames,gain_pot,gain_dep,post_thresh_hi,post_thresh_lo,depr_len,pot_len,st = 0.5)
    # for l_syn in synapses:
    #     fig = plt.figure()
    #     ax = []
    #     ax.append(fig.add_subplot(2,1,1))
    #     ax.append(fig.add_subplot(2,1,2))
    #     title = l_syn[0].fname.split('UI')[0]+' '+l_syn[0].fname.split('UI')[1].split('_')[1]+' '
    #     if 'tonic' in l_syn[0].fname:
    #         title += ' tonic GABAA'+ ' '
    #     if 'gaba_delay' in l_syn[0].fname:
    #         title += 'phasic GABA '
    #         delay = l_syn[0].fname.split('delay_')[-1].split('_')[0]
    #         title += delay +' '
    #         location = l_syn[0].fname.split('__')[-1].split('_')[0]
    #         title += location
    #     ax[0].set_title(title)
    #     for i,syn in enumerate(l_syn):
    #         print syn.weight[-1]
    #         ax[0].plot(syn.time,syn.Ca,color=colors[i], label = syn.description)
    #         ax[0].set_ylabel('Ca [mM]')
    #         ax[1].plot(syn.time,syn.weight)
    #         ax[1].set_ylabel('Weight [a.u.]')
    #         ax[1].set_xlabel('Time [s]')
    #     ax[0].legend()
    #     plt.savefig(l_syn[0].fname[:-4]+'.png',format='png', bbox_inches='tight',pad_inches=0.1)
    # plt.show()
 
