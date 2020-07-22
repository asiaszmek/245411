import numpy as np
import calculate_weight as cw
import matplotlib.pyplot as plt
th_hi = 0.46e-3
th_lo = 0.2e-3
flists = [
    ['Fino_UI_Pre_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_1_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt'],
    ['Fino_UI_Pre_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Pre_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_1_ISI_0.04_spine_plasticity_spine_1_head_Ca1.txt'],
    ['Fino_UI_Post_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt',
    'Fino_UI_Post_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_1_ISI_-0.04_spine_plasticity_spine_1_head_Ca1.txt'],
    ['P_and_K_UI_Pre_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Pre_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_3_ISI_0.01_spine_plasticity_spine_1_head_Ca1.txt'],
    ['P_and_K_UI_Post_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt',
    'P_and_K_UI_Post_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_3_ISI_-0.03_spine_plasticity_spine_1_head_Ca1.txt'],
    ['Shen_UI_Pre_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt',
    'Shen_UI_Pre_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_3_ISI_0.005_spine_plasticity_average_spine_head_Ca1.txt'],
    ['Shen_UI_Post_tertdend1_1_randseed_5757538_high_res_no_gaba_Stim_tertdend1_1_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_2_randseed_5757538_high_res_no_gaba_Stim_tertdend1_2_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_3_randseed_5757538_high_res_no_gaba_Stim_tertdend1_3_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_4_randseed_5757538_high_res_no_gaba_Stim_tertdend1_4_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_5_randseed_5757538_high_res_no_gaba_Stim_tertdend1_5_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_6_randseed_5757538_high_res_no_gaba_Stim_tertdend1_6_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_8_randseed_5757538_high_res_no_gaba_Stim_tertdend1_8_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
    'Shen_UI_Post_tertdend1_10_randseed_5757538_high_res_no_gaba_Stim_tertdend1_10_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt',
     'Shen_UI_Post_tertdend1_11_randseed_5757538_high_res_no_gaba_Stim_tertdend1_11_AP_3_ISI_-0.01_spine_plasticity_spine_1_head_Ca1.txt']]
avca = 'head_weight'
#avca = 'head_Ca1'
dist_from_soma = 26
tert_dend = 18
repetitions = {'Fino':100, 'PandK':70, 'Shen':10}
gain_pot = 4500
gain_dep = 4500
post_thresh_hi = .46e-3
post_thresh_lo = .25e-3
depr_len = 0.010
pot_len = 0.004
def duration(data,dt):
   
    how_long_hi = 0
    how_long_lo = 0
    how_longhi = []
    how_longlo = []
    for i, ca in enumerate(data):
        if ca > th_hi:
            how_long_hi += dt
            if how_long_lo > 0:
                how_longlo.append(how_long_lo)
                how_long_lo = 0
        elif ca <=th_hi and ca > th_lo:
            how_long_lo += dt
            if how_long_hi > 0:
                how_longhi.append(how_long_hi)
                how_long_hi = 0
        else:
            if how_long_hi > 0:
                how_longhi.append(how_long_hi)
                how_long_hi = 0
            if how_long_lo > 0:
                how_longlo.append(how_long_lo)
                how_long_lo = 0
    if how_longhi!=[]:
        if how_longlo!=[]:
            return max(how_longhi),max(how_longlo)
        
        return max(how_longhi),0
    if how_longlo!=[]:
        return 0, max(how_longlo)
    return 0,0


def dist(fname):
     dend = int(fname.split('tertdend1_')[-1].split('_')[0])
     return dist_from_soma+dend*tert_dend
 
h = "distance weight Ca timeLTP timeLTD"
if __name__ == '__main__':
    cols = 5
    for flist in flists:
        dat_end = np.zeros((len(flist),cols))
        for i,fname in enumerate(flist):
            print(fname)
            
            dat_end[i,0] = dist(fname)
            par = fname.split('_')[0]
            if fname.endswith('_0.04_spine_plasticity_spine_1_head_Ca1.txt'):
                par += '_0.04'
            
            if par == 'P':
                par = 'PandK'
            f = open(fname)
            header = f.readline().split(' ')
            try:
                data = np.loadtxt(f)
            except:
                print('something wrong with the file')
                continue
        
            time = data[:,0]
            dt = time[1]-time[0]
        
            synapses = []
            
            if len(header) >3:
               
                spines = cw.parse_header(header)
                
                if 'Pre' in fname:
                    start = int(0.85/dt)
                else:
                    start = int(0.7/dt)
                if 'Fino' in fname or 'PandK' in fname: 
                    stop = int(1.2/dt)
                else:
                    stop =   int(1.9/dt)
                print(spines)

                new_fname = fname
                w = 0
                for j,spine in enumerate(spines):
                    w+=data[-1,spines[spine][avca]]
            else:
                w = data[-1,2]
            dat_end[i,1] = w
            dat_end[i,2] = max(data[:,1])
            dat_end[i,3],dat_end[i,4] = duration(data[:,1],dt)
        new_fname = par
        
        if 'Pre' in flist[0]:
            new_fname += "_Pre_weights.txt"
        else:
            new_fname += "_Post_weights.txt"
        print(fname)
        print(dat_end)
        np.savetxt(new_fname,dat_end,header=h,comments='')
        plt.show()
    
